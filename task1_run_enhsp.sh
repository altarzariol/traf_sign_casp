#!/bin/bash
ENHSP=./bin/enhsp-20.jar
PPS=./bin/pps.jar

DOMAIN=./pddl_encoding.pddl

DIR=$1

TEMP="$(mktemp)"


# For all problems in DIR
find "$DIR" -type f -name "*.pddl" | \
    while read -r PROBLEM; do
        # Generate .txt file for plan
        ID_PROBLEM=${PROBLEM#"$DIR"}
        
        # Run Enhsp 
        java -jar "$ENHSP" -o "$DOMAIN" -f "$PROBLEM" > $TEMP

        # Extract plan
        for HOR in 600 660 720 780 840 900; do
            PLAN_OUTPUT="${PROBLEM%.pddl}_enhsp_horizon_${HOR}_plan.txt"
            grep -E "^[0-9]+\\.[0-9]+: \\(changeConfiguration" "$TEMP" |  awk -F': ' -v t="$HOR" '$1+0 > t {exit} {print}' > "$PLAN_OUTPUT"
            printf "$HOR.0: @PlanEND\n" >> "$PLAN_OUTPUT"
        done
            
        
    done
