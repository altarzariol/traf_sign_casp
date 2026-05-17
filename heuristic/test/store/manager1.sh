#!/bin/bash

function activate
{
    
    declare -a horizon_s=("600" "660")
    declare -a time_slot_s=("morn")
    declare -a day_s=("26")
}

function print
{
    for horizon in "${horizon_s[@]}"; do
        echo $horizon
        for day in "${day_s[@]}"; do
            for time_slot in "${time_slot_s}"; do
                echo $horizon $day $time_slot
            done
        done
    done
}

print