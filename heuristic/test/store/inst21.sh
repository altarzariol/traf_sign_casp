#!/bin/bash

declare -a horizon_s
declare -a time_slot_s
declare -a day_s

prefix="inst"
clingo_run="./${prefix}19.sh"


horizon_s=("600" "660" "720" "780" "840" "900")
time_slot_s=("morn" "noon" "eve")
day_s=("26" "30")

function run_all
{
    for horizon in "${horizon_s[@]}"; do
        bash $clingo_run $horizon "muse" 
        for day in "${day_s[@]}"; do
            for time_slot in "${time_slot_s}"; do
                bash $clingo_run $horizon $day $time_slot
            done
        done
    done
}

function single_run
{
    horizon="600"
    day="30"
    time_slot="noon"

    bash $clingo_run $horizon $day $time_slot
}

single_run
