#!/bin/bash

ENHSP="./bin/enhsp-20.jar"
PPS="./bin/pps.jar"
DOMAIN="./pddl_encoding.pddl"

#############
extract_plan() {
    local temp_file="$1"
    local plan_output="$2"
    local last_time=0.0

    > "$plan_output"
    while IFS= read -r line; do
        if [[ "$line" =~ ^[0-9]+\.[0-9]+:\ \(changeConfiguration ]]; then
            echo "$line" >> "$plan_output"
        elif [[ "$line" =~ ^[0-9]+\.[0-9]+:\ -----waiting----\ \[([0-9]+\.[0-9]+)\] ]]; then
            last_time="${BASH_REMATCH[1]}"
        fi
    done < "$temp_file"

    echo "${last_time}: @PlanEND" >> "$plan_output"
}

#############
find_links_in_goal() {
    local pddl_instance_path="$1"

    sed -n '/:goal/,/)/p' "$pddl_instance_path" \
    | tr '\n' ' ' \
    | perl -nE 'say for /\(>=\s*\(counter\s+([^)]+)\)/g'
}

#############
evaluate_plan() {
    local problem="$1"
    local plan="$2"
    local horizon="$3"
    shift 3
    local links=("$@")

    local TEMP
    TEMP=$(mktemp)
    java -jar "$PPS" -d "$DOMAIN" -p "$problem" -sp "$plan" -pt > "$TEMP" 2>/dev/null

    local values=()
    local line
    line=$(tac "$TEMP" | grep -m 1 "Time: $horizon")

    for link in "${links[@]}"; do
        value=$(echo "$line" | perl -nE "if (/\(counter $link\)=(-?[0-9]+(?:\.[0-9]+)?)/) { say \$1 }" || echo "")
        values+=("$value")
    done

    echo "${values[@]}"
}


main() {
    if [ "$#" -lt 1 ]; then
        echo "Usage: $0 <directory>"
        exit 1
    fi

    DIR="$1"
    TEMP="$(mktemp)"

    find "$DIR" -type f -name "*.pddl" | \
    while read -r pddl_instance; do
        # Find links in goal
        links=()
        while IFS= read -r link; do
            links+=("$link")
        done < <(find_links_in_goal $pddl_instance)

        # Run Enhsp
        java -jar "$ENHSP" -o "$DOMAIN" -f "$pddl_instance" > "$TEMP" 2>/dev/null

        plan="${pddl_instance%.pddl}_enhsp_plan.txt"
        extract_plan "$TEMP" "$plan"

        for hor in 600 660 720 780 840 900; do
            facts=()
            read -ra values <<< "$(evaluate_plan "$pddl_instance" "$plan" "$hor" "${links[@]}")"
            # Converts values in ASP facts
            for i in "${!links[@]}"; do
                link="${links[$i]}"
                value="${values[$i]}"
                if [[ -n "$value" ]]; then
                    scaled_value=$(echo "$value * 100000" | bc -l)
                    norm_val="${scaled_value%%.*}"
                    asp_link="${link//_/,}"
                    facts+=("pddl_solution(link(${asp_link}),${norm_val}).")
                fi
            done
            asp_facts=""
            for link in "${facts[@]}"; do
                asp_facts+="$link "
            done
            
            asp_instance="${pddl_instance%.pddl}.lp"
            clingcon_output="${pddl_instance%.pddl}_asp_bound_$hor.txt"
            echo $asp_facts > $clingcon_output
            echo $asp_facts | clingcon $asp_instance ./instance_fixed.lp ./enc_clingcon.lp - --const horizon=$hor --const bound=0 --config=crafty --heuristic=Domain --time-limit=600 --q=1  >> $clingcon_output 2>/dev/null
            
        done
    done
}

main "$@"
