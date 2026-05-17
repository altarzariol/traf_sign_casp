#!/bin/bash

declare main="./sh/inst2.sh"
declare test_list="./../packgs0.csv"
declare module_func="./parameters/modules.csv"
declare -x fst_line="Encoding,Horizon,Problem,counter wrac1_y_wrbc1,counter wrbc1_b_wrcc1,counter wrcc1_x_wrdc1,counter wrdc1_b_wrec1,counter wrec1_y_wrfc1,Total"

function split_line
{
    local line=$1 
    local -n _input_s=$2 
    local -i start=0
    local -i holder=0
    local -i idx
    local ifs=","
    
    line="${line}stop" 
    until [[ "${line:$holder:4}" == "stop" ]]; do 
          if [[ "${line:$holder:1}" == *"${ifs}"* && $holder -gt $start ]]; then 
             end=$(($holder - $start)) 
             idx="${#_input_s[@]}" 
             _input_s[idx]+="${line:$start:$end}" #;echo "${line:$start:$end}" 
             start=$(($holder+1))  
          fi 
          ((holder++))
    done
    end=$(($holder - $start)) 
    idx="${#_input_s[@]}" 
    _input_s[idx]+="${line:$start:$end}"          #;echo "${line:$start:$end}" 
}

function export_label
{
    tail -n +2 "${test_list}" | 
    while IFS=',' read -r name package _label _tail runtail; do
          if [[ "${tag_}" == "${name}" ]]; then export label="${_label}"; fi
    done
}

function export_parameters
{
    local module=$1
    local func=$2
    local name=$3
    local -a arg_s 
    local -a exp_var_s
    local -i idx

    tail -n +1 "${module}" | read -r line; split_line "${line}" arg_s     #;echo "${arg_s[@]}"
    tail -n +2 "${module}" | read -r line; split_line "${line}" exp_var_s #;echo "${exp_var_s[@]}"
    
    # export variables
    idx=0
    echo "${exp_var_s[@]}" 
    tail -n +2 "${module}" | 
    while IFS=',' read -r "${arg_s[@]}"; do
          if [[ "${tag}" == "${name}" ]]; then
             for var in "${exp_var_s[@]}"; do
                 declare -n value="${arg_s[idx]}";echo "${var}"=${value}
                 export "${var}"=${value}
                 ((idx++))
             done
          fi
    done


    if [[ "${name}" != "null" ]]; then
        export_label
        # call function func
        bash "${main}" "${func}"
    fi
}

function execute
{
    local name_test1=$1
    local procedure=$2
    #local name_test2=""

    tail -n +2 "${module_func}" | 
    while IFS=',' read -r request module function; do
          if [[ "${request}" == "${procedure}" ]]; then
             export_parameters "${module}" "${function}" "${name_test1}"
             #export_parameters "${module}" "${function}" "${name_test2}"
          fi
    done
}

shopt -s lastpipe
"$@" 