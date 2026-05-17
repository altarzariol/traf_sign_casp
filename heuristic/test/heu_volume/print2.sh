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

    output="anonymous.txt"  
             clingcon $args | 
             bash "${utility}" reorder_result "${root},${output}"     

}

function execute
{
    set_scenario
    run_test    
}

shopt -s lastpipe
execute 