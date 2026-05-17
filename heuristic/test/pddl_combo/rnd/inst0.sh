#!/bin/bash

horizon_s=("600" "660" "720" "780" "840" "900")
random="./../Instancesv2_round/random"
clingcon="combine_pddl_clingcon.sh"
heulink="combine_pddl_dhxplink.sh"

function exe_clingcon
{
    for hrz in "${horizon_s[@]}"; do
        bash "${clingcon}" "${random}" "${hrz}" 
    done
}

function exe_heulink
{
    for hrz in "${horizon_s[@]}"; do
        bash "${heulink}" "${random}" "${hrz}" 
    done
}

function execute
{
    exe_clingcon &
    exe_heulink &
}

"$@"