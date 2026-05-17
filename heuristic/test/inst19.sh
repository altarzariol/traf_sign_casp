#!/bin/bash
declare get_result="./inst18.sh"
horizon_s=("600" "660" "720" "780" "840" "900")


function print_all
{
    for hrz in "${horizon_s[@]}"; do
        export horizon="${hrz}"
        bash "${get_result}" "${test_name}_csv" "${label}"
    done
}

"$@"
