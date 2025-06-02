import subprocess
import os
import csv
import re
from pathlib import Path
from datetime import datetime
import sys
import time # To measure wall-clock execution time

# Experiment Configuration
BASE_SCRIPT_DIR = Path(__file__).parent.resolve()
CLINGCON_EXE = "clingcon"

ENC_CLINGCON_LP = BASE_SCRIPT_DIR / "enc_clingcon.lp"
INSTANCE_FIXED_FILE = BASE_SCRIPT_DIR / "instance_fixed.lp"

OUTPUT_CSV_CLINGCON_FILE = BASE_SCRIPT_DIR / "experiment_results_clingcon_models2.csv"

# Instance configurations
INSTANCES_ROOT_PATH = BASE_SCRIPT_DIR / "Instancesv2" / "sippv2" / "fixlen4"
INSTANCE_SUBDIRECTORIES = [
    "26eve",
    "muse"
    # "26morn", "26noon",
    # "30eve", "30morn", "30noon",
]
INSTANCE_FILE_NAMES = [
    "p01[count=350].lp", "p02[count=350].lp", "p03[count=350].lp",
    "p04[count=350].lp", "p05[count=350].lp"
]

HORIZONS = [600, 900]
# HORIZONS = [600, 660, 720, 780, 840, 900]

MODELS_PER_SHOT_VALUES = [1, 2, 0] 

# Clingcon Parameters
CLINGCON_BOUND = 0
CLINGCON_CONFIG = "crafty"
RUN_TIMEOUT_SECONDS = 900 # Timeout for each clingcon execution (in seconds)

# CSV Schema for clingcon results
CSV_HEADER_CLINGCON = [
    "Time", "Horizon", "Models", "Problem",
    "counter wrac1_y_wrbc1", "counter wrbc1_b_wrcc1", "counter wrcc1_x_wrdc1",
    "counter wrdc1_b_wrec1", "counter wrec1_y_wrfc1",
    "Total"
]

# Mappings for counters
TARGET_COUNTER_KEY_SUFFIXES = [
    "wrac1_y_wrbc1", "wrbc1_b_wrcc1", "wrcc1_x_wrdc1",
    "wrdc1_b_wrec1", "wrec1_y_wrfc1"
]
TARGET_LINKS_FULL_NAMES = {
    "wrac1_y_wrbc1": "link(wrac1,y,wrbc1)",
    "wrbc1_b_wrcc1": "link(wrbc1,b,wrcc1)",
    "wrcc1_x_wrdc1": "link(wrcc1,x,wrdc1)",
    "wrdc1_b_wrec1": "link(wrdc1,b,wrec1)",
    "wrec1_y_wrfc1": "link(wrec1,y,wrfc1)"
}

# Regex to extract information from clingcon output
CLINGCON_TIME_RE = re.compile(r"Time\s*:\s*([\d.]+s?)")
GENERAL_COUNTER_RE = re.compile(r"counter\(\s*\d+\s*,\s*(link\(.+?\))\s*\)\s*=\s*(-?\d+)")
SATISFIABLE_RE = re.compile(r"SATISFIABLE")

def parse_clingcon_output(output_text, horizon_val_expected):
    """
    Extracts data from the clingcon output.
    - Time: From the "Time : Xs" line.
    - Specific counters: Values for links defined in TARGET_LINKS_FULL_NAMES.
    - Total: Sum of *all* counter(H,link)=V values found in the output.
    """
    parsed_data = {}

    for suffix in TARGET_COUNTER_KEY_SUFFIXES:
        parsed_data[f"counter {suffix}"] = None

    time_match = CLINGCON_TIME_RE.search(output_text)
    if time_match:
        time_str = time_match.group(1).replace('s', '')
        try:
            parsed_data["Time"] = float(time_str)
        except ValueError:
            parsed_data["Time"] = None
            print(f"Warning: Could not parse time string '{time_match.group(1)}' from clingcon output.")
    else:
        parsed_data["Time"] = None

    total_sum_of_all_counters = 0
    found_any_counter_for_total = False
    
    for match in GENERAL_COUNTER_RE.finditer(output_text):
        link_full_name_from_output = match.group(1)
        value_str = match.group(2)
        try:
            value = int(value_str)
            total_sum_of_all_counters += value
            found_any_counter_for_total = True

            for suffix, target_full_name in TARGET_LINKS_FULL_NAMES.items():
                if target_full_name == link_full_name_from_output:
                    parsed_data[f"counter {suffix}"] = value
                    break
        except ValueError:
            print(f"Warning: Could not parse counter value '{value_str}' for link '{link_full_name_from_output}'.")

    if SATISFIABLE_RE.search(output_text):
        if found_any_counter_for_total:
            parsed_data["Total"] = total_sum_of_all_counters
        else:
            parsed_data["Total"] = 0 # SATISFIABLE but no counters, Total is 0
    else:
        # Not SATISFIABLE (UNSAT, UNKNOWN, ERROR)
        parsed_data["Total"] = None

    return parsed_data

def main():
    if not ENC_CLINGCON_LP.is_file():
        print(f"Error: Encoding file for clingcon '{ENC_CLINGCON_LP}' not found. Create it or check the path.")
        sys.exit(1)
    if not INSTANCE_FIXED_FILE.is_file():
        print(f"Error: Fixed instance file '{INSTANCE_FIXED_FILE}' not found. Check the path.")
        sys.exit(1)

    write_header_flag = not OUTPUT_CSV_CLINGCON_FILE.exists() or OUTPUT_CSV_CLINGCON_FILE.stat().st_size == 0

    with open(OUTPUT_CSV_CLINGCON_FILE, 'a', newline='', encoding='utf-8') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=CSV_HEADER_CLINGCON)
        if write_header_flag:
            writer.writeheader()

        initial_total_runs = len(HORIZONS) * len(INSTANCE_SUBDIRECTORIES) * len(INSTANCE_FILE_NAMES)
        actual_total_runs = initial_total_runs
        current_run = 0

        for horizon in HORIZONS:
            for models_per_shot_val in MODELS_PER_SHOT_VALUES: 
                for inst_subdir_name in INSTANCE_SUBDIRECTORIES:
                    current_instance_dir_path = INSTANCES_ROOT_PATH / inst_subdir_name
                    if not current_instance_dir_path.is_dir():
                        print(f"Warning: Directory '{current_instance_dir_path}' not found. Skipping runs for this directory.")
                        runs_to_skip_for_dir = len(INSTANCE_FILE_NAMES)
                        actual_total_runs = max(0, actual_total_runs - runs_to_skip_for_dir)
                        continue

                    for inst_file_name in INSTANCE_FILE_NAMES:
                        current_run += 1
                        variable_instance_file = current_instance_dir_path / inst_file_name
                        if not variable_instance_file.is_file():
                            print(f"Warning: File '{variable_instance_file}' not found. Skipping.")
                            actual_total_runs = max(0, actual_total_runs - 1)
                            continue

                        print(f"--- Running {current_run}/{actual_total_runs} (Initial Total: {initial_total_runs}): H={horizon}, Dir={inst_subdir_name}, File={inst_file_name} ---")

                        row_data = {key: None for key in CSV_HEADER_CLINGCON}
                        row_data["Horizon"] = horizon
                        row_data["Models"] = models_per_shot_val
                        try:
                            # Create a relative path from the parent directory of BASE_SCRIPT_DIR
                            relative_problem_path = variable_instance_file.relative_to(BASE_SCRIPT_DIR.parent)

                            # Remove the "traf_sign_casp/" substring from the path (POSIX string format)
                            cleaned_path_str = str(relative_problem_path).replace("traf_sign_casp/", "")

                            # Set the value in the data row
                            row_data["Problem"] = f"./{cleaned_path_str}"
                        except ValueError:
                            # Fallback if creating the relative path fails
                            row_data["Problem"] = str(variable_instance_file)


                        command = [
                            CLINGCON_EXE,
                            str(INSTANCE_FIXED_FILE),
                            str(ENC_CLINGCON_LP),
                            str(variable_instance_file),
                            "--const", f"horizon={horizon}",
                            "--const", f"bound={CLINGCON_BOUND}",
                            f"--config={CLINGCON_CONFIG}",
                            "--models", str(models_per_shot_val),
                        ]
                        
                        execution_duration_wall_clock = None
                        process_output_text = ""
                        
                        try:
                            start_time = time.time()
                            process = subprocess.run(
                                command,
                                capture_output=True,
                                text=True,
                                timeout=RUN_TIMEOUT_SECONDS,
                                check=False,
                                env={**os.environ, 'PYTHONUNBUFFERED': '1'}  # Forza unbuffered output

                            )
                            end_time = time.time()
                            execution_duration_wall_clock = end_time - start_time
                            
                            process_output_text = process.stdout
                            parsed_run_data = parse_clingcon_output(process_output_text, horizon)

                            if parsed_run_data.get("Time") is not None:
                                row_data["Time"] = f"{parsed_run_data['Time']:.3f}"
                            elif execution_duration_wall_clock is not None:
                                row_data["Time"] = f"{execution_duration_wall_clock:.2f}"
                            else:
                                row_data["Time"] = "ERROR_NO_TIME"

                            row_data["Total"] = parsed_run_data.get("Total")
                            for suffix in TARGET_COUNTER_KEY_SUFFIXES:
                                col_name = f"counter {suffix}"
                                row_data[col_name] = parsed_run_data.get(col_name)
                            
                            # Check Clingcon exit codes (10=SAT, 20=UNSAT, 30=SAT+OPTIMAL)
                            # Other codes usually indicate errors.
                            if process.returncode not in [10, 20, 30] and process.returncode !=0 : 
                                print(f"    Warning: Clingcon process finished with exit code {process.returncode}")
                                if process.stderr:
                                    print(f"    Clingcon stderr:\n{process.stderr}")

                        except subprocess.TimeoutExpired:
                            end_time = time.time() 
                            execution_duration_wall_clock = end_time - start_time
                            row_data["Time"] = 0.0 # Actual time until timeout
                            print(f"    Timeout ({RUN_TIMEOUT_SECONDS}s) for H={horizon}, Dir={inst_subdir_name}, File={inst_file_name}. Wall clock: {execution_duration_wall_clock:.2f}s")
                        except FileNotFoundError:
                            row_data["Time"] = "ERROR_FNF" 
                            print(f"    FileNotFoundError for command: {' '.join(map(str,command))}. Is '{CLINGCON_EXE}' in PATH?")
                        except Exception as e:
                            if execution_duration_wall_clock is not None:
                                row_data["Time"] = f"{execution_duration_wall_clock:.2f}"
                            else:
                                row_data["Time"] = "ERROR_EXC"
                            print(f"    Unexpected exception for H={horizon}, Dir={inst_subdir_name}, File={inst_file_name}: {str(e)}")
                        
                        # Final formatting for numeric fields for CSV
                        for key_csv in CSV_HEADER_CLINGCON:
                            if isinstance(row_data[key_csv], (int, float)):
                                if key_csv == "Time": # Already formatted as string with precision
                                    pass
                                else:
                                    row_data[key_csv] = str(row_data[key_csv])
                            elif row_data[key_csv] is None:
                                row_data[key_csv] = "" # Represent None as empty string in CSV

                        writer.writerow(row_data)
                        csvfile.flush()
    print(f"\n--- Clingcon processing complete. Results saved to '{OUTPUT_CSV_CLINGCON_FILE}' ---")

if __name__ == "__main__":
    main()