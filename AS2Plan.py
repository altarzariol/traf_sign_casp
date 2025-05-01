import re
import sys
from pathlib import Path

def convert_AS_2_plan(clingcon_AS, plan,horiz):
    with open(clingcon_AS, 'r') as f:
        content = f.read()

    actions = []
    pattern = r"sol\((\d+),inter\((\w+),(\d+)\),(conf_\w+),(conf_\w+)\)"
    matches = re.findall(pattern, content)

    for match in matches:
        timestamp, junction, stage, conf_from, conf_to = match
        line = f"{timestamp}.0: (changeConfiguration {junction}_stage{stage} {junction} {conf_from} {conf_to})"
        actions.append(line)
    actions.append(f"{horiz}.0: @PlanEND")
    actions.sort(key=lambda line: int(line.split(".0:")[0]))

    with open(plan, 'w') as f:
        for line in actions:
            f.write(line + '\n')


def convert_AS_2_pddl_problem(clingcon_AS, pddl_problem, new_pddl_problem):
    with open(clingcon_AS, 'r') as file:
        content = file.read()


    goals = []
    pattern = r'counter\(\d+,link\((\w+),(\w),(\w+)\)\)=(\d+)'
    matches = re.findall(pattern, content)

    for in_jun, id, out_jun, value in matches:
        counter = int(int(value) / 100000) 
        line = f"(>= (counter {in_jun}_{id}_{out_jun}) {counter})"
        goals.append(line)
        line = f"(< (counter {in_jun}_{id}_{out_jun}) {counter+1})"
        goals.append(line)
    new_goals='\n'.join(goals)
    
  
    with open(pddl_problem, 'r') as f:
        content = f.read()
    
    pattern = r'(:goal\s*\(and\s*\n)(.*?)(\n\s*\)\s*\))'  
    new_problem=re.sub(pattern, rf'\1{new_goals}\3', content, flags=re.DOTALL)

    with open(new_pddl_problem, 'w') as f:
        f.write(new_problem)


    
def main():
    if len(sys.argv) != 4:
        print("Usage: python AS2Plan.py horizon ASP_output_file PDDL_domain")
        sys.exit(1)
    horiz = sys.argv[1]
    ASP_file = sys.argv[2]
    PDDL_file = sys.argv[3]
    input_path = Path(ASP_file)
    ASP_plan = input_path.with_name(f"{input_path.stem}_plan{input_path.suffix}")
    new_PDDL_file = input_path.with_name(f"{input_path.stem}_pddl{input_path.suffix}")


    convert_AS_2_plan(ASP_file, ASP_plan,horiz)
    convert_AS_2_pddl_problem(ASP_file, PDDL_file, new_PDDL_file)

if __name__ == "__main__":
    main()



