#!/usr/bin/env python3
import argparse
import sys
from clingo import Control, Number
from clingo.ast import parse_string, ProgramBuilder
from clingcon import ClingconTheory

def load_program(files):
    contents = []
    for path in files:
        with open(path, 'r', encoding='utf-8') as f:
            cleaned = []
            for line in f:
                if any(line.lstrip().startswith(f'#const {const}') 
                       for const in ['horizon', 'bound', 'lim']):
                    continue
                cleaned.append(line)
            contents.append(''.join(cleaned))
    return "\n".join(contents)


def main():
    parser = argparse.ArgumentParser(
        description="Run multi-shot cASP encoding and collect counter assignments only."
    )
    parser.add_argument('files', nargs='+', help='ASP encoding files (*.lp)')
    parser.add_argument('--horizon', type=int, default=100, help='Value for horizon')
    parser.add_argument('--bound', type=int, default=0, help='Value for bound')
    parser.add_argument('--lim', type=int, default=4, help='Value for lim (cycle limit)')
    parser.add_argument('--opt', action='store_true', help='Enable optimization')
    parser.add_argument('--stats', action='store_true', help='Print statistics')
    parser.add_argument('--models', type=int, default=1, help='Maximum number of models to compute')
    args = parser.parse_args()

    # Load program and setup Clingo
    program_body = load_program(args.files)
    ctl_args = ['0']
    if args.opt:
        ctl_args.append('--opt-mode=opt')
    ctl = Control(ctl_args)
    thy = ClingconTheory()
    thy.register(ctl)

    # Add constants as facts
    constants = f"""
    #program base.
    horizon({args.horizon}).
    bound({args.bound}).
    lim({args.lim}).
    """

    # Parse all program blocks once
    with ProgramBuilder(ctl) as builder:
        parse_string(constants, lambda ast: thy.rewrite_ast(ast, builder.add))
        parse_string(program_body, lambda ast: thy.rewrite_ast(ast, builder.add))

    best_model = None
    best_value = None
    found_models = 0

    # Ground base initially
    ctl.ground([("base", [])])
    thy.prepare(ctl)

    print(f"Solving incrementally with horizon={args.horizon}, bound={args.bound}, lim={args.lim}")
    
    # Use a proper incremental approach
    for t in range(1, args.horizon + 1):
        # Ground step program for this time step
        ctl.ground([("step", [Number(t)])])
        thy.prepare(ctl)
        
        # Only ground check program at the target horizons
        if t == args.horizon:
            ctl.ground([("check", [Number(t)])])
            thy.prepare(ctl)
            
            print(f"Attempting solve at time step {t}")
            
            with ctl.solve(yield_=True, on_model=thy.on_model) as handle:
                for model in handle:
                    found_models += 1
                    assignment = thy.assignment(model.thread_id)
                    # Filter only counter assignments
                    counters = { str(k): v for k, v in assignment if k.name == "counter" }

                    '''
                    # 1) Prendi tutti i simboli mostrati (shown) nel modello ASP
                    asp_syms = model.symbols(shown=True)

                    # 2) Stampa
                    print(f"Model {found_models} at time step {t}")
                    print("  >> ASP atoms:")
                    for sym in asp_syms:
                        print("    ", sym)
                    '''

                    # Track best if optimizing
                    if args.opt:
                        opt_val = sum(counters.values())
                        if best_value is None or opt_val > best_value:
                            best_value, best_model = opt_val, counters
                    else:
                        best_model = counters

                    print(f"Model {found_models} at time step {t}")
                    #for k, v in sorted(counters.items()):
                        #print(f"  {k} = {v}")

                    if found_models >= args.models:
                        break
                
            if found_models > 0 and not args.opt:
                break

    if best_model is not None:
        print("\nCollected counter assignments at horizon:")
        for k, v in sorted(best_model.items()):
            # Expect k like 'counter(100,link(wrfc1,r,broad))'
            if k.startswith(f"counter({args.horizon},"):
                print(f"  {k} = {v}")
    else:
        print("No model found or no counters assigned.")

    if args.stats:
        stats = ctl.statistics
        print("\nSolver Statistics:")
        print(f"  Time: {stats['summary']['times']['total']:.2f}s")
        print(f"  Models: {stats['summary']['models']['enumerated']}")
        print(f"  Choices: {stats['summary']['solving']['choices']}")
        print(f"  Conflicts: {stats['summary']['solving']['conflicts']}")

if __name__ == '__main__':
    main()