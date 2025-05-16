import subprocess
import os
import csv
import re
from pathlib import Path
from datetime import datetime
import sys
import time # Per misurare il tempo di esecuzione wall-clock

# Configurazione degli esperimenti
BASE_SCRIPT_DIR = Path(__file__).parent.resolve() # Directory 'multi_shot'
MULTI_SHOT_SCRIPT = BASE_SCRIPT_DIR / "multi-shot.py"
ENC_FILE = BASE_SCRIPT_DIR / "enc_multishot.lp"
INSTANCE_FIXED_FILE = BASE_SCRIPT_DIR / "instance_fixed.lp"
OUTPUT_CSV_FILE = BASE_SCRIPT_DIR / "experiment_results_wall_clock.csv" # Nuovo nome file per questa versione

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
# HORIZONS = [660, 720, 780, 840,]

# Schema CSV come definito precedentemente
CSV_HEADER = [
    "Time", "Horizon", "Shot_duration", "Problem",
    "NumShotsInSummary",
    "counter wrac1_y_wrbc1", "counter wrbc1_b_wrcc1", "counter wrcc1_x_wrdc1",
    "counter wrdc1_b_wrec1", "counter wrec1_y_wrfc1",
    "Total"
]


# Regex per estrarre informazioni dall'output di multi-shot.py
SHOT_SUMMARY_RE = re.compile(r"Shot \d+ \(ends T=(\d+)\): Objective = (-?\d+)")
# Non è più necessario TOTAL_TIME_RE qui perché misuriamo esternamente

# Mappature per i contatori
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
    Estrae i dati dall'output di multi-shot.py specificamente per le colonne del CSV,
    escluso il tempo di esecuzione (misurato esternamente).
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

    # Determina il successo del parsing interno (basato sui dati che ci aspettiamo di trovare)
    if parsed_data.get("NumShotsInSummary") is not None and \
       parsed_data.get("Total") is not None:
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
                        print(f"Attenzione: Dir '{current_instance_dir_path}' non trovata. Salto.")
                        runs_to_skip = len(INSTANCE_FILE_NAMES)
                        total_runs = max(0, total_runs - runs_to_skip)
                        continue

                    for inst_file_name in INSTANCE_FILE_NAMES:
                        current_run += 1
                        variable_instance_file = current_instance_dir_path / inst_file_name
                        if not variable_instance_file.is_file():
                            print(f"Attenzione: File '{variable_instance_file}' non trovato. Salto.")
                            continue

                        print(f"--- Esecuzione {current_run}/{total_runs}: H={horizon}, Shot_duration={shot_duration}, Dir={inst_subdir_name}, File={inst_file_name} ---")

                        row_data = {key: None for key in CSV_HEADER}
                        row_data["Horizon"] = horizon
                        row_data["Shot_duration"] = shot_duration
                        row_data["Problem"] = f"./Instancesv2/sippv2/fixlen4/{inst_subdir_name}/{inst_file_name}"

                        command = [
                            sys.executable,
                            str(MULTI_SHOT_SCRIPT),
                            str(ENC_FILE),
                            str(INSTANCE_FIXED_FILE),
                            str(variable_instance_file),
                            f"--horizon={horizon}",
                            f"--shot_duration={shot_duration}",
                            "--stats" # Manteniamo --stats perché multi-shot.py potrebbe usarlo per altro output
                                    # o l'utente potrebbe voler vedere le statistiche di Clingo sulla console.
                        ]
                        
                        run_timeout_seconds = 3600 
                        execution_duration_wall_clock = None

                        try:
                            time_before_subprocess = time.perf_counter()
                            process = subprocess.run(
                                command,
                                capture_output=True,
                                text=True,
                                cwd=BASE_SCRIPT_DIR,
                                check=False,
                                timeout=run_timeout_seconds 
                            )
                            time_after_subprocess = time.perf_counter()
                            execution_duration_wall_clock = round(time_after_subprocess - time_before_subprocess, 3)
                            
                            # Assegna sempre il tempo misurato esternamente
                            row_data["Time"] = execution_duration_wall_clock 

                            parsed_data_from_run = parse_output_for_csv(process.stdout, horizon)

                            # Popola le altre colonne di row_data dai risultati parsati
                            row_data["NumShotsInSummary"] = parsed_data_from_run.get("NumShotsInSummary")
                            row_data["Total"] = parsed_data_from_run.get("Total")
                            for suffix in TARGET_COUNTER_KEY_SUFFIXES:
                                col_name = f"counter {suffix}"
                                row_data[col_name] = parsed_data_from_run.get(col_name)
                            

                        except subprocess.TimeoutExpired:
                            row_data["Time"] = run_timeout_seconds # Registra il timeout come durata
                            print(f"    Timeout ({run_timeout_seconds}s) per H={horizon}, Dir={inst_subdir_name}, File={inst_file_name}")
                            # Run_success è già False
                        except FileNotFoundError:
                            row_data["Time"] = 0.0 # Esecuzione non avvenuta
                            print(f"    Errore FileNotFoundError per comando: {' '.join(map(str,command))}")
                            # Run_success è già False
                        except Exception as e:
                            row_data["Time"] = 0.0 # Esecuzione non avvenuta o interrotta
                            print(f"    Eccezione inattesa per H={horizon}, Dir={inst_subdir_name}, File={inst_file_name}: {str(e)}")
                            # Run_success è già False
                        
                        writer.writerow(row_data)
                        csvfile.flush()
    print(f"\n--- Elaborazione completata. Risultati salvati in '{OUTPUT_CSV_FILE}' ---")

if __name__ == "__main__":
    main()
