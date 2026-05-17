#!/bin/bash

#variable parameters
declare task="../Instancesv2_round"
declare scenario
declare to_csv="./inst15.sh"

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
    asp_output="${problem%.pddl}"
    asp_output="${dir}Instancesv2_round/${asp_output:len+1}_${label}_$horizon.txt"
    #echo $asp_output
}

function run_test
{   
    local asp_output
    local -i zero=0

    find "${task}" -type f -name "*.pddl" | while read -r problem; do
        if [[ "$problem" == *"$instance"*"$scenario"*"$key"* ]]; then
           asp_instance="${problem%.pddl}.lp"
           set_output
           #echo $horizon $asp_instance
           clingcon $asp_instance \
                    $args --q=1 \
                    $const_h$horizon \
                    $const_b$zero \
                    > "${asp_output}" 2>/dev/null 
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
