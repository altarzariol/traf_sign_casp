import argparse
import sys
from clingo import Control, Number, Function, SymbolType, SolveResult
from clingo.ast import parse_string, ProgramBuilder
from clingcon import ClingconTheory # Assumendo che clingcon sia ancora usato

# Variabile globale per la teoria clingcon, usata in parse_model
thy = None

def load_program_from_string(program_string):
    cleaned = []
    for line in program_string.splitlines():
        if any(line.lstrip().startswith(f'#const {const}')
               for const in ['horizon', 'bound', 'lim']):
            continue
        cleaned.append(line)
    return '\n'.join(cleaned)

def load_program_from_files(files):
    contents = []
    for path in files:
        with open(path, 'r', encoding='utf-8') as f:
            cleaned_lines = []
            for line in f:
                if any(line.lstrip().startswith(f'#const {const}')
                       for const in ['horizon', 'bound', 'lim']):
                    continue
                cleaned_lines.append(line)
            contents.append(''.join(cleaned_lines))
    return "\n".join(contents)

def parse_model_symbols(model_symbols):
    """Helper per parsare i simboli da un modello."""
    time_steps_from_model = []
    chosen_configurations_from_model = []

    for sym in model_symbols:
        if sym.name == "time_step" and len(sym.arguments) == 3:
            time_steps_from_model.append(sym)
        elif sym.name == "configuration" and len(sym.arguments) == 4:
            chosen_configurations_from_model.append(sym)
    return time_steps_from_model, chosen_configurations_from_model

def get_model_counters(model):
    """Estrae i valori dei contatori dalla teoria clingcon per un dato modello."""
    counters = {}
    if thy: # Assicura che thy sia inizializzato
        assignment = thy.assignment(model.thread_id)
        for k, v in assignment:
            if k.name == "counter" and len(k.arguments) == 2:
                counters[str(k)] = v
    return counters

def main():
    global thy # Rende thy accessibile globalmente

    parser = argparse.ArgumentParser(
        description="Run true multi-shot cASP encoding with per-shot optimization."
    )
    parser.add_argument('enc_file', help='Main ASP encoding file (e.g., enc_multishot.lp)')
    parser.add_argument('instance_files', nargs='+', help='ASP instance files (*.lp)')
    parser.add_argument('--horizon', type=int, default=100, help='Value for horizon')
    parser.add_argument('--bound', type=int, default=0, help='Value for global bound (for final check if any)')
    parser.add_argument('--lim', type=int, default=4, help='Value for lim (cycle limit)')
    parser.add_argument('--models_per_shot', type=int, default=1, help='Maximum number of models to compute per shot')
    parser.add_argument('--stats', action='store_true', help='Print statistics')
    args = parser.parse_args()

    with open(args.enc_file, 'r', encoding='utf-8') as f:
        main_program_content = f.read()
    
    program_body = load_program_from_string(main_program_content)
    instance_program_body = load_program_from_files(args.instance_files)

    ctl = Control(['0', '--opt-mode=optN']) 
    thy = ClingconTheory()
    thy.register(ctl)

    constants_facts = f"""
    #program constants.
    horizon({args.horizon}).
    bound({args.bound}).
    lim({args.lim}).
    """
    with ProgramBuilder(ctl) as builder:
        parse_string(constants_facts, lambda ast: thy.rewrite_ast(ast, builder.add))
        parse_string(program_body, lambda ast: thy.rewrite_ast(ast, builder.add))
        parse_string(instance_program_body, lambda ast: thy.rewrite_ast(ast, builder.add))

    ctl.ground([("constants", [])])
    ctl.ground([("base", [])]) 
    thy.prepare(ctl)

    print(f"Solving incrementally, shot by shot, up to horizon={args.horizon}")

    current_time = 0
    fixed_decision_points = set()
    cumulative_shot_outputs = []
    initial_time_steps = []
    
    solve_result_initial = None
    def on_finish_initial(res):
        nonlocal solve_result_initial
        solve_result_initial = res

    print("Initial solve to get first time_steps...")
    with ctl.solve(yield_=True, on_model=thy.on_model, on_finish=on_finish_initial) as handle:
        for model in handle: 
            # La tua modifica: _timesteps, _ = parse_model_symbols(model.symbols(shown=True))
            # Assumendo che parse_model_symbols restituisca (time_steps, configurations)
            _timesteps, _ = parse_model_symbols(model.symbols(shown=True)) 
            initial_time_steps = _timesteps
            print(f"Initial time_steps found: {len(initial_time_steps)}")
            break 
    
    if not initial_time_steps:
        if solve_result_initial and not solve_result_initial.satisfiable:
            print("Initial problem is unsatisfiable. Cannot determine time_steps.")
        else:
            print("No model found in initial solve (or solve did not finish as expected). Cannot determine time_steps.")
        return

    while current_time < args.horizon:
        print(f"\n--- Starting Shot from T_current={current_time} ---")

        source_time_steps = initial_time_steps if not cumulative_shot_outputs else cumulative_shot_outputs[-1]["time_steps"] # CORREZIONE QUI
        
        relevant_time_values = sorted(list(set(
            ts.arguments[2].number for ts in source_time_steps
            if ts.arguments[2].number > current_time and
               (str(ts.arguments[0]), ts.arguments[1].number, ts.arguments[2].number) not in fixed_decision_points
        )))

        if relevant_time_values:
            T_shot_end = min(relevant_time_values[0], args.horizon)
        else:
            T_shot_end = args.horizon
        
        if T_shot_end <= current_time and current_time < args.horizon:
            T_shot_end = current_time + 1
            if T_shot_end > args.horizon: T_shot_end = args.horizon
        
        if current_time >= args.horizon:
             print("Global horizon reached.")
             break
        
        print(f"Shot Window: {current_time} -> {T_shot_end}")

        for t_step in range(current_time + 1, T_shot_end + 1):
            ctl.ground([("step", [Number(t_step)])])
        thy.prepare(ctl)

        ctl.ground([("check", [Number(T_shot_end)])]) 
        thy.prepare(ctl)

        print(f"Solving for shot ending at T={T_shot_end}...")
        shot_models_found_count = 0
        shot_best_obj_value = -float('inf')
        best_model_for_shot_symbols = None
        best_model_for_shot_counters = None

        with ctl.solve(yield_=True, on_model=thy.on_model) as handle:
            for model in handle:
                shot_models_found_count += 1
                model_symbols = model.symbols(shown=True)
                model_counters = get_model_counters(model)

                current_shot_obj_value = 0
                for counter_atom_str, value in model_counters.items():
                    if f"counter({T_shot_end}," in counter_atom_str: 
                        current_shot_obj_value += value
                
                print(f"  Model {shot_models_found_count} for shot T={T_shot_end}, objective: {current_shot_obj_value}")

                if current_shot_obj_value > shot_best_obj_value:
                    shot_best_obj_value = current_shot_obj_value
                    best_model_for_shot_symbols = model_symbols
                    best_model_for_shot_counters = model_counters
                
                if shot_models_found_count >= args.models_per_shot:
                    break
        
        if best_model_for_shot_symbols is None:
            print(f"No model found for shot T={T_shot_end}. Aborting multi-shot process.")
            break 
        
        print(f"Best model for shot T={T_shot_end} has objective: {shot_best_obj_value}")
        
        parsed_shot_time_steps, parsed_shot_configurations = parse_model_symbols(best_model_for_shot_symbols)
        
        cumulative_shot_outputs.append({
            "T_shot_end": T_shot_end,
            "objective_value": shot_best_obj_value,
            "counters": best_model_for_shot_counters,
            "configurations_chosen": parsed_shot_configurations,
            "time_steps": parsed_shot_time_steps # CORREZIONE: chiave usata per salvare
        })

        for config_atom in parsed_shot_configurations:
            j_sym, c_idx_sym, t_val_sym, conf_sym = config_atom.arguments
            decision_key = (str(j_sym), c_idx_sym.number, t_val_sym.number)

            if t_val_sym.number <= T_shot_end and decision_key not in fixed_decision_points:
                # Solo se la decisione è rilevante per lo shot corrente o precedente
                # e il T della configurazione è un T di un time_step
                is_actual_time_step = any(
                    ts.arguments[0] == j_sym and 
                    ts.arguments[1] == c_idx_sym and 
                    ts.arguments[2] == t_val_sym 
                    for ts in parsed_shot_time_steps # o source_time_steps per essere più precisi sui punti di decisione
                )
                if is_actual_time_step: # Fissa solo se configuration/4 corrisponde a un time_step effettivo
                    print(f"  Fixing configuration via external: fixed_configuration{j_sym, c_idx_sym, t_val_sym, conf_sym}")
                    ctl.assign_external(Function("fixed_configuration", [j_sym, c_idx_sym, t_val_sym, conf_sym]), True)
                    fixed_decision_points.add(decision_key)

        current_time = T_shot_end
        ctl.cleanup() 

    print("\n--- Multi-shot Process Summary ---")
    for i, shot_data in enumerate(cumulative_shot_outputs):
        print(f"Shot {i+1} (ends T={shot_data['T_shot_end']}): Objective = {shot_data['objective_value']}")
    
    final_shot_data = next((s for s in reversed(cumulative_shot_outputs) if s["T_shot_end"] == args.horizon), None)
    if final_shot_data:
        print(f"\nFinal counters at horizon {args.horizon} (from shot ending at T={final_shot_data['T_shot_end']}):")
        for k, v in sorted(final_shot_data['counters'].items()):
             if f"counter({args.horizon}," in k:
                print(f"  {k} = {v}")
    elif cumulative_shot_outputs:
        last_shot = cumulative_shot_outputs[-1]
        print(f"\nGlobal horizon not fully reached. Last completed shot ended at T={last_shot['T_shot_end']} with objective {last_shot['objective_value']}")
    else:
        print("\nNo shots were successfully completed.")


    if args.stats:
        stats = ctl.statistics
        print("\nSolver Statistics (Cumulative):")
        summary_stats = stats.get('summary', {})
        times_stats = summary_stats.get('times', {})
        models_stats = summary_stats.get('models', {})
        solving_stats = summary_stats.get('solving', {})
        
        print(f"  Total Time: {times_stats.get('total', 0):.3f}s")
        print(f"  Solve Time: {times_stats.get('solve', 0):.3f}s")
        print(f"  Models Enumerated: {models_stats.get('enumerated', 0)}")
        print(f"  Choices: {solving_stats.get('choices', 0)}")
        print(f"  Conflicts: {solving_stats.get('conflicts', 0)}")

if __name__ == '__main__':
    main()