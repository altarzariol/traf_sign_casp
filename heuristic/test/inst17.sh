#!/bin/bash
declare get_result="./inst15.sh"

horizon_s=("600" "660" "720" "780" "840" "900")
time_slot_s=("morn" "noon" "eve")
day_s=("26" "30")

function print_all
{
    for hrz in "${horizon_s[@]}"; do
        export horizon="${hrz}"
        export scenario="muse"
        bash "${get_result}" "${test_name}_csv" "${label}"
        for day in "${day_s[@]}"; do
            for time_slot in "${time_slot_s[@]}"; do
                export scenario="${day}""${time_slot}"
                bash "${get_result}" "${test_name}_csv" "${label}"
            done
        done
    done
}

"$@"
