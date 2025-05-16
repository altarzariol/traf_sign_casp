import argparse
import sys
from clingo import Control, Number, Function, SymbolType, SolveResult
from clingo.ast import parse_string, ProgramBuilder
from clingcon import ClingconTheory

# This global variable 'thy' will hold our ClingconTheory instance.
thy = None

def load_program_from_string(program_string):
    """
    Takes a string containing an ASP program and cleans it up a bit.
    Specifically, it removes any '#const' directives for 'horizon', 'bound', or 'lim'.
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
    Reads multiple ASP program files, cleans their content (like load_program_from_string),
    and then concatenates them into a single string.
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
    """
    A helper function that looks for 'time_step' and 'configuration' predicates
    and collects them into separate lists.
    """
    time_steps_from_model = []
    chosen_configurations_from_model = []

    for sym in model_symbols:
        if sym.name == "time_step" and len(sym.arguments) == 3:
            # Found a time_step(Job, Cycle, Time)
            time_steps_from_model.append(sym)
        elif sym.name == "configuration" and len(sym.arguments) == 4:
            # Found a configuration(Job, Cycle, Time, ConfigValue)
            chosen_configurations_from_model.append(sym)
    return time_steps_from_model, chosen_configurations_from_model

def get_model_counters(model):
    """
    Extracts counter values associated with a given model using the Clingcon theory.
    """
    counters = {}
    if thy:
        assignment = thy.assignment(model.thread_id)
        for k, v in assignment:
            # We're interested in searching counter(Time, Link) atoms
            if k.name == "counter" and len(k.arguments) == 2:
                counters[str(k)] = v
    return counters

def main():
    global thy
    parser = argparse.ArgumentParser(
        description="Run true multi-shot cASP encoding with per-shot optimization and fixed shot duration."
    )
    
    parser.add_argument('enc_file', help='Main ASP encoding file (e.g., enc_multishot.lp)')
    parser.add_argument('instance_files', nargs='+', help='ASP instance files (*.lp)')
    parser.add_argument('--horizon', type=int, default=100, help='Value for horizon (default: 100)')
    parser.add_argument('--bound', type=int, default=0, help='Value for global bound (default: 0)')
    parser.add_argument('--lim', type=int, default=4, help='Value for lim (cycle limit) (default: 4)')
    parser.add_argument('--shot_duration', type=int, default=100, help='Fixed duration for each shot (default: 10)')
    parser.add_argument('--stats', action='store_true', help='Print statistics')
    args = parser.parse_args()

    # Validation for shot_duration
    if args.shot_duration <= 0:
        print("Error: shot_duration must be a positive integer.")
        sys.exit(1)

    # Read the main encoding file
    with open(args.enc_file, 'r', encoding='utf-8') as f:
        main_program_content = f.read()
    
    # Load and clean the main encoding and instance files
    program_body = load_program_from_string(main_program_content)
    instance_program_body = load_program_from_files(args.instance_files)

    # Initialize the Clingo Control object.
    # '0' means we want all models (or optimal ones if optimizing).
    # '--opt-mode=optN' sets the optimization mode.
    # "--config=crafty" might be a specific Clingo configuration.
    ctl = Control(['0', '--opt-mode=optN', "--config=crafty"]) 
    thy = ClingconTheory()
    thy.register(ctl)

    # Define some constants as ASP facts based on command-line arguments.
    # These will be added to the ASP program.
    constants_facts = f"""
    #program constants.
    horizon({args.horizon}).
    bound({args.bound}).
    lim({args.lim}).
    """
    # Now, add all our program parts to the Clingo controller
    with ProgramBuilder(ctl) as builder:
        parse_string(constants_facts, lambda ast: thy.rewrite_ast(ast, builder.add))
        parse_string(program_body, lambda ast: thy.rewrite_ast(ast, builder.add))
        parse_string(instance_program_body, lambda ast: thy.rewrite_ast(ast, builder.add))

    # Ground the 'constants' part of the program.
    ctl.ground([("constants", [])])
    # Ground the 'base' part of the program.
    ctl.ground([("base", [])])
    # Prepare the theory (Clingcon) after initial grounding.
    thy.prepare(ctl)

    print(f"Solving incrementally with fixed shot_duration={args.shot_duration}, up to horizon={args.horizon}")

    # This will track the "current time" in our multi-shot process
    current_time = 0
    # This set will store configuration decisions that have been made and fixed
    fixed_decision_points = set() 
    # This list will store the output/results from each individual shot
    cumulative_shot_outputs = []

    # The main loop for the multi-shot solving process.
    # It continues as long as we haven't reached the overall horizon.
    while current_time < args.horizon:
        print(f"\n--- Starting Shot from T_current={current_time} ---")

        # Calculate the end time for the current shot.
        # It's either the current time plus the shot duration, or the horizon, whichever is smaller.
        T_shot_end = min(current_time + args.shot_duration, args.horizon)

        # Edge case: If T_shot_end isn't actually advancing time,
        # it might mean shot_duration is too small or we're at the very end.
        if T_shot_end <= current_time:
            if current_time < args.horizon:
                T_shot_end = args.horizon
            else:
                print("Global horizon reached or no progress possible.")
                break
        
        print(f"Shot Window: {current_time} -> {T_shot_end}")

        # Ground the parts of the ASP program relevant to the current shot's time window.
        # We only ground for new time steps.
        if T_shot_end > current_time:
            for t_step in range(current_time + 1, T_shot_end + 1):
                # Ground the 'step' part of the program for each time step 't_step' in the window.
                ctl.ground([("step", [Number(t_step)])])
            thy.prepare(ctl) 

            # Ground the 'check' part of the program, parameterized by the end of the current shot.
            ctl.ground([("check", [Number(T_shot_end)])]) 
            thy.prepare(ctl)
        else:
            ctl.ground([("check", [Number(T_shot_end)])])
            thy.prepare(ctl)


        print(f"Solving for shot ending at T={T_shot_end}...")
        # How many models we've found in this shot
        shot_models_found_count = 0 

        # Initialize best objective value for this shot (assuming maximization)
        shot_best_obj_value = -float('inf') 
        best_model_for_shot_symbols = None
        best_model_for_shot_counters = None
        shot_satisfiable = False

        solve_result_current_shot = None

        # This callback function will be called when the solver finishes for the current shot.
        def on_finish_shot(res):
            nonlocal solve_result_current_shot
            solve_result_current_shot = res

        # Start solving. 
        with ctl.solve(yield_=True, on_model=thy.on_model, on_finish=on_finish_shot) as handle:
            for model in handle:
                shot_satisfiable = True
                shot_models_found_count += 1
                model_symbols = model.symbols(shown=True)
                model_counters = get_model_counters(model)

                current_shot_obj_value = 0
                # Calculate the objective value for this specific model within the current shot.
                for counter_atom_str, value in model_counters.items():
                    if f"counter({T_shot_end}," in counter_atom_str: 
                        current_shot_obj_value += value
                
                print(f"   Model {shot_models_found_count} for shot T={T_shot_end}, objective: {current_shot_obj_value}")

                # If this model is better than what we've seen so far in this shot, update.
                if current_shot_obj_value > shot_best_obj_value:
                    shot_best_obj_value = current_shot_obj_value
                    best_model_for_shot_symbols = model_symbols
                    best_model_for_shot_counters = model_counters
            
            
        # If no models were found or the shot was unsatisfiable, we need to handle that.
        if not shot_satisfiable or best_model_for_shot_symbols is None:
            status_message = "unknown"
            if solve_result_current_shot: 
                if solve_result_current_shot.unsatisfiable:
                    status_message = "UNSATISFIABLE"
                elif solve_result_current_shot.interrupted:
                    status_message = "INTERRUPTED"
                elif not solve_result_current_shot.satisfiable:
                    status_message = "NOT SATISFIABLE (unknown reason)"

            print(f"No model found or shot was {status_message} for shot T={T_shot_end}. Aborting multi-shot process.")
            break
        
        print(f"Best model for shot T={T_shot_end} has objective: {shot_best_obj_value}")
        
        # Extract time_steps and configurations from the best model found for this shot
        parsed_shot_time_steps, parsed_shot_configurations = parse_model_symbols(best_model_for_shot_symbols)
        
        # Store the results of this successful shot
        cumulative_shot_outputs.append({
            "T_shot_end": T_shot_end,
            "objective_value": shot_best_obj_value,
            "counters": best_model_for_shot_counters,
            "configurations_chosen": parsed_shot_configurations,
            "time_steps": parsed_shot_time_steps 
        })

        # Define the external atoms for the configurations chosen in this shot.
        for config_atom in parsed_shot_configurations:
            j_sym, c_idx_sym, t_val_sym, conf_sym = config_atom.arguments
            decision_key = (str(j_sym), c_idx_sym.number, t_val_sym.number)

            # Only fix configurations that fall within the current shot's end time (T_shot_end)
            # and haven't already been fixed from previous shots.
            if t_val_sym.number <= T_shot_end and decision_key not in fixed_decision_points:

                is_actual_time_step_for_config = any(
                    ts.arguments[0] == j_sym and 
                    ts.arguments[1] == c_idx_sym and 
                    ts.arguments[2] == t_val_sym 
                    for ts in parsed_shot_time_steps 
                )
                if is_actual_time_step_for_config:
                    print(f"   Fixing configuration via external: fixed_configuration{j_sym, c_idx_sym, t_val_sym, conf_sym}")
                    
                    # Create an external atom representing this fixed configuration.
                    external_atom = Function("fixed_configuration", [j_sym, c_idx_sym, t_val_sym, conf_sym])
                    ctl.assign_external(external_atom, True)
                    fixed_decision_points.add(decision_key)
        
        # Advance our current_time to the end of the shot we just processed
        current_time = T_shot_end
        
        # Clean up parts of the program that are no longer needed.
        # This can help manage memory and grounding size in long incremental runs.
        ctl.cleanup() 

    # --- End of the multi-shot loop ---

    # If requested, print solver statistics
    if args.stats:
        stats = ctl.statistics
        try:
            print("\nSolver Statistics Summary:")
            print("========================")
            
            # Extract and print time information
            times = stats['summary']['times']
            print(f"CPU time: {times['cpu']:.2f}s")
            
            # Extract and print problem size information
            lp_stats = stats['problem']['lp']
            print(f"\nProblem size:")
            print(f"- Atoms: {int(lp_stats['atoms']):,}")
            print(f"- Rules: {int(lp_stats['rules']):,}")
            print(f"- Bodies: {int(lp_stats['bodies']):,}")
            
            # Extract and print solving information
            solving_stats = stats['solving']['solvers']
            print(f"\nSolving process:")
            print(f"- Choices: {int(solving_stats['choices']):,}")
            print(f"- Conflicts: {int(solving_stats['conflicts']):,}")
            print(f"- Restarts: {int(solving_stats['restarts']):,}")
            print("========================")
            
        except KeyError as e:
            print(f"Error retrieving statistics: {e}")


    # Print a summary of the entire multi-shot process
    print("\n--- Multi-shot Process Summary ---")
    if not cumulative_shot_outputs:
        print("No shots were successfully completed.")
    else:
        for i, shot_data in enumerate(cumulative_shot_outputs):
            print(f"Shot {i+1} (ends T={shot_data['T_shot_end']}): Objective = {shot_data['objective_value']}")

        final_shot_data = next((s for s in reversed(cumulative_shot_outputs) if s["T_shot_end"] == args.horizon), None)
        
        if final_shot_data:
            print(f"\nFinal counters at horizon {args.horizon} (from shot ending at T={final_shot_data['T_shot_end']}):")
            if final_shot_data['counters']:
                for k, v in sorted(final_shot_data['counters'].items()):
                    if f"counter({args.horizon}," in k:
                        print(f"   {k} = {v}")
            else:
                print("   No counter data available for the final shot.")
        elif cumulative_shot_outputs:
            last_shot = cumulative_shot_outputs[-1]
            print(f"\nGlobal horizon {args.horizon} not fully reached. Last completed shot ended at T={last_shot['T_shot_end']} with objective {last_shot['objective_value']}")
        

if __name__ == '__main__':
    main()