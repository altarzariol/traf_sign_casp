#!/bin/bash

horizon_s=("600" "660" "720" "780" "840" "900")
sipp="./../result/Instancesv2_round/sipp"
sippv2="./../result/Instancesv2_round/sippv2"
heulink="combine_pddl_dhxplink.sh"


function exe_heulink
{
    for hrz in "${horizon_s[@]}"; do
        bash "${heulink}" "${sipp}" "${hrz}" 
        bash "${heulink}" "${sippv2}" "${hrz}" 
    done
}

function execute
{
    exe_heulink &
}

"$@"