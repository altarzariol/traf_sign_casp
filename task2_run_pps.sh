#!/bin/bash

ENHSP=./bin/enhsp-20.jar
PPS=./bin/pps.jar
DOMAIN=./pddl_encoding.pddl
DIR=$1
TEMP="$(mktemp)"
TEMP_PLAN="$(mktemp)"
path=("wrac1_y_wrbc1" "wrbc1_b_wrcc1" "wrcc1_x_wrdc1" "wrdc1_b_wrec1" "wrec1_y_wrfc1")


process_plan() {
    local PLANNER=$1
    local PROBLEM=$2
    local HORIZON=$3
    local PLAN_FILE="${PROBLEM%.pddl}_${PLANNER}_plan.txt"
    local OUT_FILE="${PROBLEM%.pddl}_${PLANNER}.txt"
    if grep -wq "UNKNOWN" $OUT_FILE; then 
        echo "No plan for $OUT_FILE" >> "timeout_opt.txt"
    else
        printf "$PLANNER,$HORIZON,${PROBLEM%.pddl}" >> "$CSV"
        
        grep -E "^[0-9]+\.[0-9]+: \(changeConfiguration" "$PLAN_FILE" | awk -F': ' -v t="$HORIZON" '$1+0 > t {exit} {print}' > "$TEMP_PLAN"
        printf "$HORIZON.0: @PlanEND\n" >> "$TEMP_PLAN"
        java -jar "$PPS" -d "$DOMAIN" -p "$PROBLEM" -sp "$TEMP_PLAN" -pt > "$TEMP"


        tac "$TEMP" | grep -m 1 "Time: " | while read -r line; do
            jt=()
            for link in "${path[@]}"; do
                val=$(echo "$line" | sed -n "s/.*(counter $link)=\([-0-9.]*\).*/\1/p")
                jt+=("$val")
                printf ",$val" >> "$CSV"
            done

            tot=0
            for val in "${jt[@]}"; do
                [[ -n "$val" ]] && tot=$(echo "$tot + $val" | bc -l)
            done
            printf ",$tot\n" >> "$CSV"
        done
    fi 
}

export -f process_plan
export PPS DOMAIN TEMP TEMP_PLAN CSV path
CSV="result.csv"

echo "Encoding,Horizon,Problem, counter wrac1_y_wrbc1, counter wrbc1_b_wrcc1, counter wrcc1_x_wrdc1, counter wrdc1_b_wrec1, counter wrec1_y_wrfc1,Total" > "$CSV"

for HORIZON in 600 660 720 780 840 900; do
    find "$DIR" -type f -name "*.pddl" | while read -r PROBLEM; do
        process_plan "enhsp" "$PROBLEM" "$HORIZON"
        process_plan "asp" "$PROBLEM" "$HORIZON"
    done
done
