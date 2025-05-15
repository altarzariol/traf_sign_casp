import argparse
import sys
from clingo import Control, Number, Function, SymbolType, SolveResult
from clingo.ast import parse_string, ProgramBuilder
from clingcon import ClingconTheory # type: ignore

# Variabile globale per la teoria clingcon, usata in parse_model
thy = None

def load_program_from_string(program_string):
    """
    Pulisce una stringa di programma ASP rimuovendo le direttive #const specifiche.
    """
    cleaned = []
    for line in program_string.splitlines():
        if any(line.lstrip().startswith(f'#const {const}')
               for const in ['horizon', 'bound', 'lim']):
            continue
        cleaned.append(line)
    return '\n'.join(cleaned)

def load_program_from_files(files):
    """
    Carica e pulisce il contenuto di più file di programma ASP.
    """
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
    """Helper per parsare i simboli da un modello (time_step e configuration)."""
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
        description="Run true multi-shot cASP encoding with per-shot optimization and fixed shot duration."
    )
    parser.add_argument('enc_file', help='Main ASP encoding file (e.g., enc_multishot.lp)')
    parser.add_argument('instance_files', nargs='+', help='ASP instance files (*.lp)')
    parser.add_argument('--horizon', type=int, default=100, help='Value for horizon (default: 100)')
    parser.add_argument('--bound', type=int, default=0, help='Value for global bound (default: 0)')
    parser.add_argument('--lim', type=int, default=4, help='Value for lim (cycle limit) (default: 4)')
    parser.add_argument('--shot_duration', type=int, default=10, help='Fixed duration for each shot (default: 10)')
    parser.add_argument('--models_per_shot', type=int, default=1, help='Maximum number of models to compute per shot (default: 1)')
    parser.add_argument('--stats', action='store_true', help='Print statistics')
    args = parser.parse_args()

    if args.shot_duration <= 0:
        print("Error: shot_duration must be a positive integer.")
        sys.exit(1)

    with open(args.enc_file, 'r', encoding='utf-8') as f:
        main_program_content = f.read()
    
    program_body = load_program_from_string(main_program_content)
    instance_program_body = load_program_from_files(args.instance_files)

    ctl = Control(['0', '--opt-mode=optN', '--config=crafty', '--stats']) 
    thy = ClingconTheory()
    thy.register(ctl)

    # Definisce costanti globali per il programma ASP
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

    ctl.ground([("constants", [])]) # Ground delle costanti
    ctl.ground([("base", [])])      # Ground del programma base iniziale
    thy.prepare(ctl)

    print(f"Solving incrementally with fixed shot_duration={args.shot_duration}, up to horizon={args.horizon}")

    current_time = 0
    fixed_decision_points = set() # Tiene traccia delle decisioni di configurazione già fissate
    cumulative_shot_outputs = []  # Salva l'output di ogni shot

    while current_time < args.horizon:
        print(f"\n--- Starting Shot from T_current={current_time} ---")

        # Calcola T_shot_end con durata fissa
        T_shot_end = min(current_time + args.shot_duration, args.horizon)

        # Se T_shot_end non avanza current_time, e non siamo ancora all'orizzonte,
        # potrebbe significare che shot_duration è troppo piccolo o siamo alla fine.
        # In tal caso, si forza T_shot_end all'orizzonte per l'ultimo shot o si esce.
        if T_shot_end <= current_time:
            if current_time < args.horizon: # Tentativo di fare un ultimo piccolo passo
                 T_shot_end = args.horizon
            else: # current_time >= args.horizon
                print("Global horizon reached or no progress possible.")
                break
        
        print(f"Shot Window: {current_time} -> {T_shot_end}")

        # Grounding del programma per gli step temporali specifici di questo shot
        # Vengono groundati solo i nuovi step temporali da current_time + 1 a T_shot_end
        # Se current_time è 0, il range parte da 1.
        # Se T_shot_end è uguale a current_time (caso limite, es. ultimo shot), il range è vuoto.
        if T_shot_end > current_time:
            for t_step in range(current_time + 1, T_shot_end + 1):
                ctl.ground([("step", [Number(t_step)])])
            thy.prepare(ctl) # Prepara la teoria dopo il grounding incrementale

            # Grounding del programma di 'check' per la fine dello shot corrente
            ctl.ground([("check", [Number(T_shot_end)])]) 
            thy.prepare(ctl) # Prepara la teoria
        else: # current_time == T_shot_end, probabilmente l'ultimo "punto"
            ctl.ground([("check", [Number(T_shot_end)])])
            thy.prepare(ctl)


        print(f"Solving for shot ending at T={T_shot_end}...")
        shot_models_found_count = 0
        shot_best_obj_value = -float('inf') # Inizializza a meno infinito per problemi di massimizzazione
        best_model_for_shot_symbols = None
        best_model_for_shot_counters = None
        shot_satisfiable = False

        solve_result_current_shot = None
        def on_finish_shot(res):
            nonlocal solve_result_current_shot
            solve_result_current_shot = res

        with ctl.solve(yield_=True, on_model=thy.on_model, on_finish=on_finish_shot) as handle:
            for model in handle:
                shot_satisfiable = True
                shot_models_found_count += 1
                model_symbols = model.symbols(shown=True)
                model_counters = get_model_counters(model)

                current_shot_obj_value = 0
                # Calcola il valore obiettivo per lo shot corrente basato sui contatori a T_shot_end
                for counter_atom_str, value in model_counters.items():
                    # Assumiamo che i contatori rilevanti per l'obiettivo siano quelli a T_shot_end
                    if f"counter({T_shot_end}," in counter_atom_str: 
                        current_shot_obj_value += value
                
                print(f"  Model {shot_models_found_count} for shot T={T_shot_end}, objective: {current_shot_obj_value}")

                if current_shot_obj_value > shot_best_obj_value:
                    shot_best_obj_value = current_shot_obj_value
                    best_model_for_shot_symbols = model_symbols
                    best_model_for_shot_counters = model_counters
                
                if shot_models_found_count >= args.models_per_shot:
                    print(f"  Reached models_per_shot limit ({args.models_per_shot}).")
                    break # Esce dal loop dei modelli per questo shot
        
        if not shot_satisfiable or best_model_for_shot_symbols is None:
            status_message = "unknown"
            if solve_result_current_shot:
                if solve_result_current_shot.unsatisfiable:
                    status_message = "UNSATISFIABLE"
                elif solve_result_current_shot.interrupted:
                    status_message = "INTERRUPTED"
                elif not solve_result_current_shot.satisfiable: # Generico non-SAT
                     status_message = "NOT SATISFIABLE (unknown reason)"

            print(f"No model found or shot was {status_message} for shot T={T_shot_end}. Aborting multi-shot process.")
            break 
        
        print(f"Best model for shot T={T_shot_end} has objective: {shot_best_obj_value}")
        
        # Estrae time_steps e configurations dal miglior modello dello shot
        parsed_shot_time_steps, parsed_shot_configurations = parse_model_symbols(best_model_for_shot_symbols)
        
        # Salva i risultati dello shot
        cumulative_shot_outputs.append({
            "T_shot_end": T_shot_end,
            "objective_value": shot_best_obj_value,
            "counters": best_model_for_shot_counters,
            "configurations_chosen": parsed_shot_configurations,
            "time_steps": parsed_shot_time_steps 
        })

        # Fissa le configurazioni scelte in questo shot come atomi esterni per i successivi
        for config_atom in parsed_shot_configurations:
            # config_atom è un simbolo clingo.Function, es: configuration(J,C_idx,T_val,Conf)
            j_sym, c_idx_sym, t_val_sym, conf_sym = config_atom.arguments
            decision_key = (str(j_sym), c_idx_sym.number, t_val_sym.number)

            # Fissa solo le decisioni che cadono entro la fine dello shot corrente (T_shot_end)
            # e che non sono già state fissate.
            if t_val_sym.number <= T_shot_end and decision_key not in fixed_decision_points:
                # Verifica se questa configurazione corrisponde a un time_step effettivo nel modello corrente.
                # Questo aiuta a fissare solo decisioni "significative".
                is_actual_time_step_for_config = any(
                    ts.arguments[0] == j_sym and 
                    ts.arguments[1] == c_idx_sym and 
                    ts.arguments[2] == t_val_sym 
                    for ts in parsed_shot_time_steps 
                )
                if is_actual_time_step_for_config:
                    print(f"  Fixing configuration via external: fixed_configuration{j_sym, c_idx_sym, t_val_sym, conf_sym}")
                    # Crea l'atomo esterno da fissare
                    external_atom = Function("fixed_configuration", [j_sym, c_idx_sym, t_val_sym, conf_sym])
                    ctl.assign_external(external_atom, True)
                    fixed_decision_points.add(decision_key)
        
        # Avanza il tempo corrente alla fine dello shot appena completato
        current_time = T_shot_end
        
        # Esegue il cleanup per ottimizzare il grounding del prossimo shot
        ctl.cleanup() 

    # Stampa un riassunto del processo multi-shot
    print("\n--- Multi-shot Process Summary ---")
    if not cumulative_shot_outputs:
        print("No shots were successfully completed.")
    else:
        for i, shot_data in enumerate(cumulative_shot_outputs):
            print(f"Shot {i+1} (ends T={shot_data['T_shot_end']}): Objective = {shot_data['objective_value']}")
        
        # Cerca i dati dell'ultimo shot che ha raggiunto l'orizzonte (se esiste)
        final_shot_data = next((s for s in reversed(cumulative_shot_outputs) if s["T_shot_end"] == args.horizon), None)
        
        if final_shot_data:
            print(f"\nFinal counters at horizon {args.horizon} (from shot ending at T={final_shot_data['T_shot_end']}):")
            total_counter_value_at_horizon = 0
            counters_at_horizon_found = False
            if final_shot_data['counters']:
                for k, v in sorted(final_shot_data['counters'].items()):
                     # Mostra solo i contatori relativi all'orizzonte finale
                     if f"counter({args.horizon}," in k:
                        print(f"  {k} = {v}")
                        total_counter_value_at_horizon += v
                        counters_at_horizon_found = True
                
                if counters_at_horizon_found:
                    print(f"  -----------------------------------")
                    print(f"  Total Counter Value at Horizon {args.horizon}: {total_counter_value_at_horizon}")
                else:
                    print(f"  No counters specifically for horizon {args.horizon} found in the final shot data.")

            else:
                print("  No counter data available for the final shot.")
        elif cumulative_shot_outputs: # Se l'orizzonte non è stato raggiunto ma ci sono stati shot
            last_shot = cumulative_shot_outputs[-1]
            print(f"\nGlobal horizon {args.horizon} not fully reached. Last completed shot ended at T={last_shot['T_shot_end']} with objective {last_shot['objective_value']}")
        # else: (già gestito sopra con "No shots were successfully completed.")


    if args.stats:
        stats = ctl.statistics
        print("\nSolver Statistics (Cumulative):")
        # Accede alle statistiche in modo sicuro, gestendo chiavi mancanti
        summary_stats = stats.get('summary', {})
        times_stats = summary_stats.get('times', {})
        models_stats = summary_stats.get('models', {}) # 'models' potrebbe non essere in summary, ma direttamente in stats
        if not models_stats and 'models' in stats: models_stats = stats['models']
        
        solving_stats = summary_stats.get('solving', {})
        if not solving_stats and 'solving' in stats: solving_stats = stats['solving']


        print(f"  Total Time: {times_stats.get('total', 0):.3f}s")
        print(f"  Solve Time: {times_stats.get('solve', 0):.3f}s")
        print(f"  Models Enumerated: {models_stats.get('enumerated', 0)}") # o 'number' a seconda della versione di clingo
        print(f"  Choices: {solving_stats.get('choices', 0)}")
        print(f"  Conflicts: {solving_stats.get('conflicts', 0)}")

if __name__ == '__main__':
    main()
