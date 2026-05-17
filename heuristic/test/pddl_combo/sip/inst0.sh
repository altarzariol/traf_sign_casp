#!/bin/bash

horizon_s=("600" "660" "720" "780" "840" "900")
sipp="./../Instancesv2_round/sipp"
sippv2="./../Instancesv2_round/sippv2"
clingcon="combine_pddl_clingcon.sh"
heulink="combine_pddl_dhxplink.sh"

function exe_clingcon
{
    for hrz in "${horizon_s[@]}"; do
        bash "${clingcon}" "${sipp}" "${hrz}" 
        bash "${clingcon}" "${sippv2}" "${hrz}" 
    done
}

function exe_heulink
{
    for hrz in "${horizon_s[@]}"; do
        bash "${heulink}" "${sipp}" "${hrz}" 
        bash "${heulink}" "${sippv2}" "${hrz}" 
    done
}

function execute
{
    exe_clingcon &
    exe_heulink &
}

"$@"