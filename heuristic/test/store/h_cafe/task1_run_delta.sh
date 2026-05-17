#!/bin/bash
declare -a horizon_s
declare -a time_slot_s
declare -a day_s

label="aggregate"
prefix="inst"
clingo_run="./${prefix}14.sh"
get_result="./${prefix}15.sh"

horizon_s=("600" "660" "720" "780" "840" "900")
time_slot_s=("morn" "noon" "eve")
day_s=("26" "30")

function run_all
{
    for horizon in "${horizon_s[@]}"; do
        bash $clingo_run $horizon "muse" && \
        bash $get_result $horizon "muse"
        for day in "${day_s[@]}"; do
            for time_slot in "${time_slot_s}"; do
                bash $clingo_run $horizon "${day}""${time_slot}" && \
                bash $get_result $horizon "${day}""${time_slot}"
            done
        done
    done
}

function print_all
{
    for horizon in "${horizon_s[@]}"; do
        bash $get_result $horizon "muse"
        for day in "${day_s[@]}"; do
            for time_slot in "${time_slot_s[@]}"; do
                bash $get_result $horizon "${day}""${time_slot}"
            done
        done
    done
}

function clean_all
{
    local dir1="./Instancesv2/sippv2/fixlen4"
    local dir2="./Instancesv2_round/sippv2/fixlen4"

    rm -r $dir1/26eve/* $dir1/26morn/* $dir1/26noon/* $dir1/30eve/*  $dir1/30morn/* $dir1/30noon/* $dir1/muse/*
    rm -r $dir2/26eve/* $dir2/26morn/* $dir2/26noon/* $dir2/30eve/*  $dir2/30morn/* $dir2/30noon/* $dir2/muse/*
}

fst_line="Encoding,Horizon,Problem,counter wrac1_y_wrbc1,counter wrbc1_b_wrcc1,counter wrcc1_x_wrdc1,counter wrdc1_b_wrec1,counter wrec1_y_wrfc1,Total"
csv_tot="./result_det_bound_${label}.csv"


function set_csv { ls $csv_tot && rm -r $csv_tot; printf "$fst_line"$'\n' > $csv_tot 
}

function group_all
{
    set_csv
    for horizon in "${horizon_s[@]}"; do
        csv="./results_delta/result_det_bound_${label}_${horizon}_muse.csv"
        tail -n +2 $csv | while read -r line; do printf "$line"$'\n' >> $csv_tot; done
        for day in "${day_s[@]}"; do
            for time_slot in "${time_slot_s[@]}"; do
                scenario="${day}${time_slot}"
                csv="./results_delta/result_det_bound_${label}_${horizon}_${scenario}.csv"
                tail -n +2 $csv | while read -r line; do printf "$line"$'\n' >> $csv_tot; done
            done
        done
    done 
}


function muse
{
    #run&print&group
    for horizon in "${horizon_s[@]}"; do
        bash $clingo_run $horizon "muse" && \
        bash $get_result $horizon "muse"
        csv="./results_delta/result_det_bound_${label}_${horizon}_muse.csv"
        tail -n +2 $csv | while read -r line; do printf "$line"$'\n' >> $csv_tot; done
    done;
    
}

export label
clean_all
run_all
group_all



 