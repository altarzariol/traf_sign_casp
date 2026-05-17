#!/bin/bash

### Directory management

declare -a path1_s path2_s
declare -a time_slot_s
declare -a day_s
declare -g root

declare unknown="./inst20.sh"
declare csv="./inst19.sh"
declare group_csv="./inst5.sh"
declare utility="./aux0.sh"
export test_name="heurate"
### -- modified -- ###
#export fst_line="Encoding,Horizon,Problem,counter wrac1_y_wrbc1,counter wrbc1_b_wrcc1,counter wrcc1_x_wrdc1,counter wrdc1_b_wrec1,counter wrec1_y_wrfc1,Total"
export fst_line="Encoding,Horizon,Problem,counter n43121_d_n43221,counter n43221_d_n42111,counter n42111_d_n44121,counter n44121_h_n44131,counter n44131_h_n44151,counter n44151_h_n44211,counter n44211_d_n44221,Total"

function set_root {
   root="./$1/result"
}

function set_paths
{
    set_root $1

    path1_s=("$root"
             "/hull"
             "/fixed-test-5")
    path2_s=("$root"
             "/hull"
             "/fixed-test-10")
    path3_s=("$root"
             "/hull"
             "/fixed-test-14")
    path4_s=("$root"
             "/hull"
             "/fixed-test-15")
    path5_s=("$root"
             "/hull"
             "/fixed-test-17")
    path6_s=("$root"
             "/hull"
             "/fixed-test-18")

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
    local path4="" 
    local path5="" 
    local path6="" 

    set_paths $1
    for dir in "${path1_s[@]}"; do path1="$path1""$dir"; check_folder $path1; done
    for dir in "${path2_s[@]}"; do path2="$path2""$dir"; check_folder $path2; done
    for dir in "${path3_s[@]}"; do path3="$path3""$dir"; check_folder $path3; done
    for dir in "${path4_s[@]}"; do path4="$path4""$dir"; check_folder $path4; done
    for dir in "${path5_s[@]}"; do path5="$path5""$dir"; check_folder $path5; done
    for dir in "${path6_s[@]}"; do path6="$path6""$dir"; check_folder $path6; done

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


shopt -s lastpipe
"$@"

