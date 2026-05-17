#!/bin/bash

#variable parameters
declare task="../Instancesv2_round"
declare scenario
declare to_csv="./inst21.sh"
declare ENHSP="./../../bin/enhsp-20.jar"
declare PPS="./../../bin/pps.jar"
declare DOMAIN="./../../pddl_encoding.pddl"

function set_scenario
{
    [[ "${day}" == "muse" ]] && scenario="${day}" || scenario="${day}${time_slot}"  
}

function run_csv
{
    export scenario
    bash "${to_csv}" "${test_name}_csv" "${label}"
}

function set_output
{
    local -i len 

    len="${#task}"
    asp_output="${pddl_instance%.pddl}"
    if [[ $1 == "plan" ]]; then
        plan="${dir}Instancesv2_round/${asp_output:len+1}_enhsp_plan.txt"
    else
        asp_output="${dir}Instancesv2_round/${asp_output:len+1}_${label}_$horizon.txt"
    fi
    #echo $asp_output
}

#############
function extract_plan 
{
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
function find_links_in_goal 
{
    local pddl_instance_path="$1"

    sed -n '/:goal/,/)/p' "$pddl_instance_path" \
    | tr '\n' ' ' \
    | perl -nE 'say for /\(>=\s*\(counter\s+([^)]+)\)/g'
}

#############
function evaluate_plan 
{
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


function run_test 
{
    local asp_output 
    local plan
    local -i zero=0
    TEMP="$(mktemp)"

    find "${task}" -type f -name "*.pddl" | \
    while read -r pddl_instance; do
        if [[ "$pddl_instance" == *"$instance"*"$scenario"*"$key"* ]]; then
            # Find links in goal
            links=()
            while IFS= read -r link; do
                links+=("$link")
            done < <(find_links_in_goal $pddl_instance)

            # Run Enhsp
            java -jar "$ENHSP" -o "$DOMAIN" -f "$pddl_instance" > "$TEMP" 2>/dev/null

            set_output "plan"
            extract_plan "$TEMP" "$plan"

            facts=()
            read -ra values <<< "$(evaluate_plan "$pddl_instance" "$plan" "$horizon" "${links[@]}")"
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
            set_output "asp"
            echo $asp_facts > "${asp_output}"
            echo $asp_facts | clingcon $asp_instance \
                                       $args --q=1 \
                                       $const_h$horizon \
                                       $const_b$zero \
                                       >> "${asp_output}" 2>/dev/null 
        fi
    done    
}

function execute
{
    set_scenario
    run_test 
    run_csv    
}

shopt -s lastpipe
execute 
