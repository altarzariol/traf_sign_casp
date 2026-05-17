#!/bin/bash

declare pack_test="theory_delta"
declare label="classic"
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
    export label
    bash "./${tail}" test_end "${pack_test}"
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

"$@"

shopt -s lastpipe