import re
import sys 
import os

def transform_string(input_string):
    pattern_cap = r'\(= \(capacity ([a-zA-Z0-9]{5})_([a-zA-Z])_([a-zA-Z0-9]{5})\)\s*(\d+)\.(\d+)\)'
    match = re.match(pattern_cap, input_string)
    if match:
        jun1, id, jun2, inter, decim = match.groups()
        normal = f"{inter}{decim.ljust(5, '0')}".lstrip('0') 
        if normal=="":
            normal="0" 
        if (normal != "10000000000"):
            return f"capacity(link({jun1},{id},{jun2}),{normal})."
        
    
    pattern_cap = r'\(= \(capacity ([a-zA-Z0-9]{5})_([a-zA-Z])_([a-zA-Z0-9]{5})\)\s*(\d+)\)'
    match = re.match(pattern_cap, input_string)
    if match:
        jun1, id, jun2, inter = match.groups()
        normal = f"{inter}00000".lstrip('0') 
        if normal=="":
            normal="0" 
        if (normal != "10000000000"):
            return f"capacity(link({jun1},{id},{jun2}),{normal})."
            

    pattern_occ = r'\(= \(occupancy ([a-zA-Z0-9]{5})_([a-zA-Z])_([a-zA-Z0-9]{5})\)\s*(\d+)\.(\d+)\)'
    match = re.match(pattern_occ, input_string)
    if match:
        jun1, id, jun2, inter, decim = match.groups()
        normal = f"{inter}{decim.ljust(5, '0')}".lstrip('0') 
        if normal=="":
            normal="0" 
        if normal != "5000000000":
            return f"initial_occ(link({jun1},{id},{jun2}),{normal})."
        
    pattern_occ = r'\(= \(occupancy ([a-zA-Z0-9]{5})_([a-zA-Z])_([a-zA-Z0-9]{5})\)\s*(\d+)\)'
    match = re.match(pattern_occ, input_string)
    if match:
        jun1, id, jun2, inter = match.groups()
        normal = f"{inter}00000".lstrip('0') 
        if normal=="":
            normal="0" 
        if normal != "5000000000":
            return f"initial_occ(link({jun1},{id},{jun2}),{normal})."
    
    pattern_conf = r'\(= \(confgreentime ([a-zA-Z0-9]{5})_stage(\d) conf_([a-zA-Z0-9]{5})_(\d)\)\s*(\d+)\)'
    match = re.match(pattern_conf, input_string)
    
    if match:
        jun1, nstage, jun2, idconf, seconds = match.groups()
        return f"phase_limit(stage({jun1},{nstage}),conf_{jun2}_{idconf},{seconds})."
    
    pattern_turnrate = r'\(= \(turnrate ([a-zA-Z0-9]{5})_stage(\d) ([a-zA-Z0-9]{5})_([a-zA-Z])_([a-zA-Z0-9]{5}) ([a-zA-Z0-9]{5})_([a-zA-Z])_([a-zA-Z0-9]{5})\)\s*(\d+)\.(\d+)\)'
    match = re.match(pattern_turnrate, input_string)
    
    if match:
        jun, nstage, jun1, id1, jun2, jun3, id2, jun4, inter, decim = match.groups()
        normal = f"{inter}{decim.ljust(5, '0')}".lstrip('0') 
        return f"turnrate(stage({jun},{nstage}),link({jun1},{id1},{jun2}),link({jun3},{id2},{jun4}),{normal})."
    
    pattern_turnrate_outside = r'\(= \(turnrate fake outside ([a-zA-Z0-9]{5})_([a-zA-Z])_([a-zA-Z0-9]{5})\)\s*(\d+)\.(\d+)\)'
    match = re.match(pattern_turnrate_outside, input_string)
    
    if match:
        jun1, id, jun2, inter, decim = match.groups()
        normal = f"{inter}{decim.ljust(5, '0')}".lstrip('0') 
        return f"turnrate(stage(outside,1),outside,link({jun1},{id},{jun2}),{normal})."
    

    pattern_active_conf = r'\(activeconf ([a-zA-Z0-9]{5}) conf_([a-zA-Z0-9]{5})_(\d)\)'
    match = re.match(pattern_active_conf, input_string)
    
    if match:
        jun1, jun2, num = match.groups()
        return f"active_conf(0,{jun1},conf_{jun2}_{num})."
    
    pattern_active_stage = r'\(active ([a-zA-Z0-9]{5})_stage(\d)\)'
    match = re.match(pattern_active_stage, input_string)
    
    if match:
        jun, num = match.groups()
        return f"active(stage({jun},{num}))."
    
    pattern_active_inter = r'\(inter ([a-zA-Z0-9]{5})_stage(\d)\)'
    match = re.match(pattern_active_inter, input_string)
    
    if match:
        jun, num = match.groups()
        return f"active(inter({jun},{num}))."
    

    pattern_time1 = r'\(= \(greentime ([a-zA-Z0-9]{5})\)\s+(\d+)\)'
    match = re.match(pattern_time1, input_string)
    
    if match:
        jun, seconds = match.groups()
        if seconds != "0":
            return f"time({jun},{seconds})."
        
    pattern_time2 = r'\(= \(intertime ([a-zA-Z0-9]{5})\)\s+(\d+)\)'
    match = re.match(pattern_time2, input_string)
    
    if match:
        jun, seconds = match.groups()
        if seconds != "0":
            return f"time({jun},{seconds})."
        
        
    goal = r'\(>= \(counter ([a-zA-Z0-9]{5})_([a-zA-Z])_([a-zA-Z0-9]{5})\)\s+(\d+)\)'
    
    
    replaced_text = re.sub(goal, r"goal_count(link(\1,\2,\3),\4).\n", input_string)
    if replaced_text != input_string:
        return replaced_text

    counter_cycles = r'\(= \(countcycle ([a-zA-Z0-9]{5})\)\s+(\d+)\)'
    match = re.match(counter_cycles, input_string)
    if match:
        jun, times = match.groups()
        return f"countcycle({jun},{times})."

    return("No match")


def process_file(input_filename, output_filename):
    with open(input_filename, 'r') as infile, open(output_filename, 'w') as outfile:
        for line in infile:
            transformed_line = transform_string(line.strip())
            if transformed_line != "No match":
                outfile.write(transformed_line + "\n")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python extract_instances.py folder")
        sys.exit(1)
    
    input_folder = sys.argv[1]
    if os.path.isdir(input_folder):
        for root, _, files in os.walk(input_folder):
            for file in files:
                if file.endswith(".pddl"):
                    pddl_path = os.path.join(root, file)
                    lp_path = os.path.join(root, file.replace(".pddl", ".lp"))
                    process_file(pddl_path, lp_path)