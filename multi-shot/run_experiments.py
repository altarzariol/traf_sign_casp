import subprocess
import os
import csv
import re
from pathlib import Path
from datetime import datetime 
import sys
import time # To measure wall-clock execution time

# Experiment Configuration
BASE_SCRIPT_DIR = Path(__file__).parent.resolve() # 'multi_shot' directory
MULTI_SHOT_SCRIPT = BASE_SCRIPT_DIR / "multi-shot.py"
ENC_FILE = BASE_SCRIPT_DIR / "enc_multishot.lp"
INSTANCE_FIXED_FILE = BASE_SCRIPT_DIR / "instance_fixed.lp"
OUTPUT_CSV_FILE = BASE_SCRIPT_DIR / "experiment_results_multi_shot.csv" # Filename for output CSV

INSTANCES_ROOT_PATH = BASE_SCRIPT_DIR.parent / "Instancesv2" / "sippv2" / "fixlen4"
INSTANCE_SUBDIRECTORIES = [
    "26eve",
    "muse"
]
# "26morn", "26noon",
#     "30eve", "30morn", "30noon",

INSTANCE_FILE_NAMES = [
    "p01[count=350].lp", "p02[count=350].lp", "p03[count=350].lp",
    "p04[count=350].lp", "p05[count=350].lp"
]
HORIZONS = [600, 900]
# HORIZONS = [660, 720, 780, 840]

# CSV Schema as previously defined
CSV_HEADER = [
    "Time", "Horizon", "Shot_duration", "Problem",
    "NumShotsInSummary",
    "counter wrac1_y_wrbc1", "counter wrbc1_b_wrcc1", "counter wrcc1_x_wrdc1",
    "counter wrdc1_b_wrec1", "counter wrec1_y_wrfc1",
    "Total"
]


# Regex to extract information from multi-shot.py output
SHOT_SUMMARY_RE = re.compile(r"Shot \d+ \(ends T=(\d+)\): Objective = (-?\d+)")

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

# SHOT_DURATIONS = [50, 100, 150, 300, 450]
SHOT_DURATIONS = [150, 300]


def parse_output_for_csv(output_text, horizon_val):
    """
    Extracts data from the multi-shot.py output specifically for CSV columns,
    excluding execution time (measured externally and no longer parsed here).
    """
    parsed_data = {}
    parsed_data["_parsing_successful_internally"] = False # Default

    shot_summary_matches = []
    for match in SHOT_SUMMARY_RE.finditer(output_text):
        shot_summary_matches.append({
            "t_end": int(match.group(1)),
            "objective": int(match.group(2))
        })

    if shot_summary_matches:
        parsed_data["NumShotsInSummary"] = len(shot_summary_matches)
        parsed_data["Total"] = shot_summary_matches[-1]["objective"]

    final_counters_section_re = re.compile(
        rf"Final counters at horizon {horizon_val}.*?\n(.*?)(?=\n\n|\Z)", re.DOTALL
    )
    final_counters_match = final_counters_section_re.search(output_text)
    if final_counters_match:
        counters_text = final_counters_match.group(1)
        for suffix in TARGET_COUNTER_KEY_SUFFIXES:
            link_full_name = TARGET_LINKS_FULL_NAMES[suffix]
            csv_column_name = f"counter {suffix}"
            link_re = re.compile(rf"counter\({horizon_val},{re.escape(link_full_name)}\)\s*=\s*(-?\d+)")
            match = link_re.search(counters_text)
            if match:
                parsed_data[csv_column_name] = int(match.group(1))


    # Determine internal parsing success (based on data we expect to find)
    if parsed_data.get("NumShotsInSummary") is not None and \
       parsed_data.get("Total") is not None:
        # We could add a check for the presence of counters if they are always expected
        parsed_data["_parsing_successful_internally"] = True
    
    return parsed_data

def main():
    write_header_flag = False
    if not os.path.isfile(OUTPUT_CSV_FILE):
        write_header_flag = True
    elif os.path.getsize(OUTPUT_CSV_FILE) == 0:
        write_header_flag = True

    with open(OUTPUT_CSV_FILE, 'a', newline='', encoding='utf-8') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=CSV_HEADER)
        if write_header_flag:
            writer.writeheader()

        total_runs = len(HORIZONS) * len(SHOT_DURATIONS) * len(INSTANCE_SUBDIRECTORIES) * len(INSTANCE_FILE_NAMES)
        current_run = 0

        for horizon in HORIZONS:
            for shot_duration in SHOT_DURATIONS:
                for inst_subdir_name in INSTANCE_SUBDIRECTORIES:
                    current_instance_dir_path = INSTANCES_ROOT_PATH / inst_subdir_name
                    if not current_instance_dir_path.is_dir():
                        print(f"Warning: Directory '{current_instance_dir_path}' not found. Skipping.")
                        continue

                    for inst_file_name in INSTANCE_FILE_NAMES:
                        current_run += 1
                        variable_instance_file = current_instance_dir_path / inst_file_name
                        if not variable_instance_file.is_file():
                            print(f"Warning: File '{variable_instance_file}' not found. Skipping.")
                            continue

                        print(f"--- Running {current_run}/{total_runs}: H={horizon}, Shot_duration={shot_duration}, Dir={inst_subdir_name}, File={inst_file_name} ---")

                        row_data = {key: None for key in CSV_HEADER}
                        row_data["Horizon"] = horizon
                        row_data["Shot_duration"] = shot_duration
                        row_data["Problem"] = f"./Instancesv2/sippv2/fixlen4/{inst_subdir_name}/{inst_file_name}" # Relative path as in example

                        command = [
                            sys.executable,
                            str(MULTI_SHOT_SCRIPT),
                            str(INSTANCE_FIXED_FILE),
                            str(variable_instance_file),
                            str(ENC_FILE),
                            f"--horizon={horizon}",
                            f"--shot_duration={shot_duration}"
                        ]
                        
                        run_timeout_seconds = 3600 
                        execution_duration_wall_clock = None # Initialize

                        try:
                            start_time = time.time()
                            process = subprocess.run(
                                command,
                                capture_output=True,
                                text=True,
                                timeout=run_timeout_seconds,
                                check=False # Do not raise exception for non-zero exit code, handle output
                            )
                            end_time = time.time()
                            execution_duration_wall_clock = end_time - start_time
                            
                            # Assign the measured WALL CLOCK TIME
                            row_data["Time"] = execution_duration_wall_clock
                            
                            # Parse output for other data
                            parsed_data_from_run = parse_output_for_csv(process.stdout, horizon)
                            
                            row_data["NumShotsInSummary"] = parsed_data_from_run.get("NumShotsInSummary")
                            row_data["Total"] = parsed_data_from_run.get("Total")
                            for suffix in TARGET_COUNTER_KEY_SUFFIXES:
                                col_name = f"counter {suffix}"
                                row_data[col_name] = parsed_data_from_run.get(col_name)
                            
                            if process.returncode != 0:
                                print(f"    Warning: Subprocess finished with exit code {process.returncode}")
                                if process.stderr:
                                    print(f"    Subprocess stderr:\n{process.stderr}")


                        except subprocess.TimeoutExpired:
                            row_data["Time"] = run_timeout_seconds # Record timeout as duration
                            print(f"    Timeout ({run_timeout_seconds}s) for H={horizon}, Shot_duration={shot_duration}, Dir={inst_subdir_name}, File={inst_file_name}")
                        except FileNotFoundError:
                            row_data["Time"] = 0.0 # Execution did not occur
                            print(f"    FileNotFoundError for command: {' '.join(map(str,command))}")
                        except Exception as e:
                            # If another exception occurs, execution_duration_wall_clock might have been partially calculated
                            # or might not be significant. Record what we have or 0.0.
                            if execution_duration_wall_clock is not None: # If error is after measurement
                                row_data["Time"] = execution_duration_wall_clock
                            else: # If error is before or during measurement
                                row_data["Time"] = 0.0 
                            print(f"    Unexpected exception for H={horizon}, Shot_duration={shot_duration}, Dir={inst_subdir_name}, File={inst_file_name}: {str(e)}")
                        
                        # Format time to two decimal places before writing
                        if row_data["Time"] is not None:
                            try:
                                # Ensure it's a float before formatting,
                                # though it should already be (or a convertible int)
                                row_data["Time"] = f"{float(row_data['Time']):.2f}"
                            except (ValueError, TypeError):
                                # Fallback in the (unlikely) event row_data["Time"] is not numeric
                                print(f"Warning: Could not format time '{row_data['Time']}' for the row.")
                                # Leave original value or set to a placeholder if preferred
                                pass
                        
                        writer.writerow(row_data)
                        csvfile.flush() # Ensure data is written to disk periodically
    print(f"\n--- Processing complete. Results saved to '{OUTPUT_CSV_FILE}' ---")

if __name__ == "__main__":
    main()