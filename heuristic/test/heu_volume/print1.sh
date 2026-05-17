#!/bin/bash

#variable parameters
declare scenario
declare utility="./aux0.sh"

function set_scenario
{
    [[ "${day}" == "muse" ]] && scenario="${day}" || scenario="${day}${time_slot}"  
}

function run_test
{   
    local root="./heu_volume/result/"

    tail -n +2 "$task" | 
    while IFS=',' read -r HORIZON PROBLEM MIN; do
          if [[ "$PROBLEM" == *"$instance"*"$scenario"*"$key"* && 
                "$HORIZON" == "$horizon" ]]; then 
             echo $HORIZON $PROBLEM
             asp_instance="../../${PROBLEM}.lp"
             output="_${instance%'/'}_${key}_${scenario}_${label}_bound_$HORIZON.txt"  
             clingcon $asp_instance \
                      $args \
                      $const_h$HORIZON \
                      $const_b$MIN | 
             bash "${utility}" reorder_result "${root},${output}"     
          fi
    done

}

function execute
{
    set_scenario
    run_test    
}

shopt -s lastpipe
execute 