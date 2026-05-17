#!/bin/bash

### Directory management

declare -a path1_s path2_s
declare -a time_slot_s
declare -a day_s
declare -g root

declare unknown="./inst11.sh"
declare csv="./inst22.sh"
declare group_csv="./inst5.sh"
declare utility="./aux0.sh"
export test_name="heurate"
export fst_line="Encoding,Horizon,Problem,counter wrac1_y_wrbc1,counter wrbc1_b_wrcc1,counter wrcc1_x_wrdc1,counter wrdc1_b_wrec1,counter wrec1_y_wrfc1,Total"

function set_root {
   root="./$1/result"
}

function set_paths
{
    set_root $1
    dir1="/Instancesv2_round/random/fixlen4"
    dir2="/Instancesv2_round/sipp/fixlen4"
    dir3="/Instancesv2_round/sippv2/fixlen4"

    path1_s=("$root"
             "/Instancesv2_round"
             "/random"
             "/fixlen4")
    path2_s=("$root"
             "/Instancesv2_round"
             "/sipp"
             "/fixlen4")
    path3_s=("$root"
             "/Instancesv2_round"
             "/sippv2"
             "/fixlen4")

    time_slot_s=("morn" 
                 "noon" 
                 "eve")
    day_s=("26" 
           "30")

    muse="/muse"
}

function search
{
    local place=$1
    local item=$2

    tree "${place}" -i -f | 
    while read -r line; do
          if [[ "${line}" == *"${item}"* ]]; then
             return 0   
          fi
    done
    return 1
}

function check_folder {   

    search "." $1 || mkdir $1
}

function create_folders
{
    local path1="" 
    local path2=""
    local path3=""

    set_paths $1
    for dir in "${path1_s[@]}"; do path1="$path1""$dir"; check_folder $path1; done
    for dir in "${path2_s[@]}"; do path2="$path2""$dir"; check_folder $path2; done
    for dir in "${path3_s[@]}"; do path3="$path3""$dir"; check_folder $path3; done

    for scenario in {/26,/30}{morn,noon,eve}; do
        check_folder "$path1""$scenario"
        check_folder "$path2""$scenario"  
        check_folder "$path3""$scenario"     
    done

    #muse
    check_folder "$path1""$muse"
    check_folder "$path2""$muse"
    check_folder "$path3""$muse"
}

function delete_folders
{
    set_root $1
    rm -r "${root}"
}

function file_cleaning
{
    set_root $1
    tree "${root}" -i -f | 
    while read -r line; do 
      if [[ "${line}" == *$2*".txt" ]]; then
         rm -r "${line}"
      fi
    done

}

function unknown_results
{
    set_root $1
    export dir="${root}/" 
    bash "${unknown}" unknown
}

function test_start
{
    create_folders $1
    export dir="${root}/"
    bash "${test_run}" 
}

function test_end
{
    set_root $1
    export dir="${root}/"
    bash "${group_csv}" group_all 
}

function print_all 
{
    set_root $1
    export dir="${root}/"
    bash "${csv}" print_all
}

#create_folders main_folder
#delete_folders main_folder
#files_cleaning main_folder
#test_start main_folder

shopt -s lastpipe
"$@"

