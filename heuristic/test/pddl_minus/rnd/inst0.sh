#!/bin/bash

horizon_s=("600" "660" "720" "780" "840" "900")
random="./../result/Instancesv2_round/random"
heulink="combine_pddl_dhxplink.sh"


function exe_heulink
{
    for hrz in "${horizon_s[@]}"; do
        bash "${heulink}" "${random}" "${hrz}" 
    done
}

function execute
{
    exe_heulink &
}

"$@"