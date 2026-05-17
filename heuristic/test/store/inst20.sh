#!/bin/bash

###TEST FOLDER
declare -a path1_txt_s path2_txt_s
declare -a path1_lp_s path2_lp_s
declare -a time_slot_s
declare -a day_s

root="./result"
clingcon_out_txt="/out_txt"
clingcon_out_lp="/out_lp"
dir1="/Instancesv2/sippv2/fixlen4"
dir2="/Instancesv2_round/sippv2/fixlen4"

path1_txt_s=("$root"
             "$clingcon_out_txt"
             "/Instancesv2"
             "/sippv2"
             "/fixlen4")
path2_txt_s=("$root"
             "$clingcon_out_txt"
             "/Instancesv2_round"
             "/sippv2"
             "/fixlen4")

path1_lp_s=("$root"
            "$clingcon_out_lp"
            "/Instancesv2"
            "/sippv2"
            "/fixlen4")

path2_lp_s=("$root"
            "$clingcon_out_lp"
            "/Instancesv2_round"
            "/sippv2"
            "/fixlen4")

time_slot_s=("morn" 
             "noon" 
             "eve")
day_s=("26" 
       "30")


function create_folders
{
    local path1_txt="" 
    local path2_txt=""
    local path1_lp="" 
    local path2_lp=""

    for dir in "${path1_txt_s[@]}"; do path1_txt="$path1_txt""$dir"; mkdir $path1_txt; done
    for dir in "${path2_txt_s[@]}"; do path2_txt="$path2_txt""$dir"; mkdir $path2_txt; done
    for dir in "${path1_lp_s[@]}"; do path1_lp="$path1_lp""$dir"; mkdir $path1_lp; done
    for dir in "${path2_lp_s[@]}"; do path2_lp="$path2_lp""$dir"; mkdir $path2_lp; done

    for scenario in {/26,/30}{morn,noon,eve}; do
        mkdir "$path1_txt""$scenario"
        mkdir "$path2_txt""$scenario"
        mkdir "$path1_lp""$scenario"
        mkdir "$path2_lp""$scenario"        
    done
}

create_folders
