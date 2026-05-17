#!/bin/bash

#Test for exporting arrays
_horizon_s=("600" "660" "720" "780" "840" "900")
_time_slot_s=("morn" "noon" "eve")
_day_s=("26" "30")

declare horizon_s
declare time_slot_s
declare day_s

for hor in "${_horizon_s[@]}"; do
    for day in "${_day_s[@]}"; do
        for time in "${_time_slot_s[@]}"; do
            export horizon_s="${hor}"
            export day_s="${day}"
            export time_slot_s="${time}"
            bash ./manager2.sh
        done
    done
done 

