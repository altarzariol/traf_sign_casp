#!/bin/bash

declare -g dotunkw_test
declare -g dotunkw_ref
declare -g imprv_test
declare -g imprv_ref
declare -a arg_s 

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

function check_file
{

    tail -n +2 "${record}" | 
    while IFS=',' read -r name test ref; do
          if [[ "${name}" == "${tag_}" ]]; then
             return 0
          fi
    done
    return 1
}

function add_file
{
    local i_test=$1
    local i_ref=$2

    check_file || echo "${tag_},${i_test},${i_ref}" >> "${record}"
}

function check_comparison
{
    local -n _dotunkw=$1

    if [[ "${compare}" == "all" ]]; then _dotunkw="${unk_csv}";
    elif [[ "${compare}" == "peer" ]]; then _dotunkw="${dot_csv}"; fi
}

function check_double
{
    if [[ "${double_encoding}" == "true" ]]; then
        tail -n +2 "${unkn_csv}" | 
        while IFS=',' read -r name_ lb dot_csv unk_csv; do
              if [[ "${name_}" == "${tag_}" && "${lb}" == "${encoding_test}_${label}" ]]; then
                 check_comparison dotunkw_test
                 imprv_test="${dir_}/result_${lb}_imprv.csv"
              elif [[ "${name_}" == "${tag_}" && "${lb}" == "${encoding_reference}_${label}" ]]; then
                   check_comparison dotunkw_ref
                   imprv_ref="${dir_}/result_${lb}_imprv.csv"
              fi
        done
       
    fi
}

function get_parameters
{
 
    tail -n +1 "${dotunkn_csv}" | read -r line; split_line "${line}" arg_s  #;echo "${arg_s[@]}"
    tail -n +2 "${dotunkn_csv}" | 
    while IFS=',' read -r "${arg_s[@]}"; do
          if [[ "${tag}" == "${tag_}" ]]; then
              check_double
          fi
    done
    add_file "${imprv_test}" "${imprv_ref}"
    echo "${dotunkw_test},${dotunkw_ref},${imprv_test},${imprv_ref}"
    
    
}

function get_improvements
{
    local imprv_test
    local imprv_ref

    tail -n +2 "${imprvs}" | 
    while IFS=',' read -r name test ref; do
          if [[ "${name}" == "${tag_}" ]]; then
             imprv_test="${test}"
             imprv_ref="${ref}"
          fi 
    done
    echo "${imprv_test},${imprv_ref}"
}

function add_data
{
    add_file $1 $2
}

function get_data_plot
{
    imprvs="${data_aggr}"
    get_improvements
}

function get_name_plot
{
    local test
    local ref
    tail -n +2 "${name_aggr}" |
    while IFS=',' read -r name test_ ref_ w x y z a b c d; do
          if [[ "${name}" == "${tag_}" ]]; then
              test="${test_}"
              ref="${ref_}"
          fi
    done
    echo "${test},${ref}"

}

shopt -s lastpipe
"$@"


