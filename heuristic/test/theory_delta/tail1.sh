#!/bin/bash

#variable parameters
declare scenario
declare to_csv="./inst4.sh"

function set_scenario
{
    [[ "${day}" == "muse" ]] && scenario="${day}" || scenario="${day}${time_slot}"  
}

function run_csv
{
    export scenario
    bash "${to_csv}" "${test_name}_csv" "${label}"
}

function run_test
{   
    tail -n +2 "$task" | while IFS=',' read -r HORIZON PROBLEM MIN; do
        if [[ "$PROBLEM" == *"$instance"*"$scenario"*"$key"* ]]; then
            if [[ "$HORIZON" == "$horizon" ]]; then 
                echo $HORIZON $PROBLEM
                asp_instance="../../${PROBLEM}.lp"
                clingcon $asp_instance \
                         $args \
                         $const_h$HORIZON \
                         $const_b$MIN \
                         > "${dir}${PROBLEM}_${label}_$HORIZON.txt" 2>/dev/null
            fi
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
