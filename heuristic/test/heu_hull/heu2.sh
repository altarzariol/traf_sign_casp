#!/bin/bash

#variable parameters
declare task="../hull"
declare to_csv="./inst18.sh"

function run_csv
{
    bash "${to_csv}" "${test_name}_csv" "${label}"
}

function set_output
{
    local -i len 

    len="${#task}"
    asp_output="${problem%.pddl}"
    asp_output="${dir}hull/${asp_output:len+1}_${label}_$horizon.txt"
    #echo $asp_output
}

function run_test
{   
    local asp_output
    local -i zero=0

    find "${task}" -type f -name "*.pddl" | while read -r problem; do
        if [[ "$problem" == *"$instance"*"$fixtest"*"$key"* ]]; then
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
    run_test 
    run_csv    
}

shopt -s lastpipe
execute 
