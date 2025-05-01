#!/bin/bash
ENHSP=./bin/enhsp-20.jar
PPS=./bin/pps.jar

DOMAIN=./pddl_encoding.pddl

DIR=$1
HOR=900

TEMP="$(mktemp)"


# For all PDDL+ problems in DIR
find "$DIR" -type f -name "*.pddl" | \
    while read -r PROBLEM; do
        ASP_INSTANCE="${PROBLEM%.pddl}.lp"
        ASP_OUTPUT="${PROBLEM%.pddl}_asp.txt"
        
        clingcon $ASP_INSTANCE ./instance_fixed.lp ./enc_clingcon.lp --const horizon=$HOR --const bound=0 --config=crafty --time-limit=600 --q=1 > $ASP_OUTPUT 2>/dev/null

        python3 AS2Plan.py $HOR $ASP_OUTPUT $PROBLEM

        ASP_PLAN="${ASP_OUTPUT%.txt}_plan.txt"
        PROBLEM_V="${ASP_OUTPUT%.txt}_pddl.txt"

        java -jar "$PPS" -d "$DOMAIN" -p "$PROBLEM_V" -sp "$ASP_PLAN" -pt > $TEMP

        if grep -q "Goal Reached!" $TEMP; then
            echo "Goal Reached for $PROBLEM!" 
        else
            echo "Error with problem $PROBLEM" 
        fi
        
    done
