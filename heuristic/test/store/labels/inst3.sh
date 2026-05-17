#!/bin/bash

declare pack_test="theory_delta"
declare label="NotOpt_aggregatel1"
declare prefix="tail"
declare tail="/${prefix}0.sh"
declare test_run="./tail1.sh"
declare utility="./aux0.sh"

function move
{
    cp -r "./${pack_test}/${prefix}"*.sh "."
}

function delete
{
    local only_print=$1
    
    export label
    bash "./${tail}" test_end "${pack_test}" 
    "${only_print}"
    echo "$(ls "./${prefix}"*.sh)"
    echo -e "\rDo you want to remove these files?[y/n]\c"
    bash "${utility}" general_answer && rm -r "./${prefix}"*.sh
    
}

function execute
{   
    export label
    export test_run
    bash "./${tail}" test_start "${pack_test}" 
}

function unknown
{
  export label
  bash "./${tail}" unknown_results "${pack_test}"	

}

function print
{
    export label
    bash "./${tail}" print_all "${pack_test}"
}

"$@"

shopt -s lastpipe
