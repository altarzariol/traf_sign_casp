#!/bin/bash

#Remember: some functions need to have export-variables
# split_line: export var :: input
# compose: export var :: args

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
    _input_s[idx]+="${line:$start:$end}"           #;echo "${line:$start:$end}" 
}

function compose 
{
    local -n arg_s=$1

    args=""
    for elem in "${arg_s[@]}"; do
        args="$args ""${elem}"
    done
}

function search
{
    local place=$1
    local item=$2
    
    ls "${place}" | 
    while read -r line; do
          if [[ "${line}" == *"${item}"* ]]; then
             return 0   
          fi
    done
    return 1
}

function search3
{
    local place=$1
    local item=$2
    
    tree -i -f "${place}" | 
    while read -r line; do
          if [[ "${line}" == *"${item}"* ]]; then
             return 0   
          fi
    done
    return 1
}

function set_output { search $1 $2 && rm -r $1$2; }

function reorder_result
{
    local root=$1
    local out=$2
    local lines=""
    local -i start=0
    local -i holder=0
    
    set_output "${root}" "${out}"
    while read -r line; do lines="${lines}${line}"; done; lines="${lines}stop" 
    until [[ "${lines:$holder:4}" == "stop" ]]; do 
          if [[ "${lines:$holder:1}" == *" "* && $holder -gt $start ]]; then 
             end=$(($holder - $start)) 
             echo "${lines:$start:$end}" >> "${root}${out}" 
             start=$(($holder+1))  
          fi 
          ((holder++))
    done
    end=$(($holder - $start)) 
    echo "${lines:$start:$end}" >> "${root}${out}" 
}

function get_parameters
{
    local -n _param_s=$2

    #prepare function's parameters
    split_line $1 _param_s
}

function add
{
    local -n _arr=$1
    local -i idx

    idx="${#_arr[@]}"
    _arr[idx]+=$2  #;echo "${_arr[@]}"
}

function check_item
{
    local item=$1
    local -n _ref=$2

    for elem in "${_ref[@]}"; do
        if [[ "${elem}" == "${item}" ]]; then
            return 0
        fi
    done
    return 1
}

function check_input
{   
    local -n _lst=$1 _reference=$2
    local -a tmp_s
    
    #check the correctness of the input
    for elem in "${input_s[@]}";do
        check_item "${elem}" _reference && 
        add tmp_s "${elem}" || return 1
    done
    #set the main list with the current input
    for t in "${tmp_s[@]}"; do
        add _lst "${t}"
    done
    return 0
}

function insert
{
    local type=$1
    local -n _list=$2 _choice_s=$3
    local -a input_s

    echo "${type}: ""${_choice_s[@]}"
    echo -e "choose::\c"
    #read input
    read -e -a input_s
    #validation input
    check_input _list _choice_s ||
    (echo "input not valid")
}

function set_var
{
    local -n _var=$1
    local name=$2
    local input

    echo "${_var:-$name}"
    echo -e "choose::[y/n]\c"
    #read input
    read -e input
    #validate input
    case "${input}" in y) _var="muse"; echo $_var >> tmp.txt;; ##message passing via file
                       n) echo "${_var:-$name not set}";;
                       *) echo "input not valid";;
    esac 
}

function general_answer
{
    local input
    read -e input
    case "${input}" in y) return 0;;
                       n) return 1;;
                       *) echo "bad option"
                          general_answer;;
    esac
}

#interface
function aux
{
    local func=$1
    local commas=$2
    local -a param_s

    get_parameters "${commas:-unset}" param_s
    case "${func}" in split_line) split_line $2 input;;
                      search) search "${param_s[0]}" "${param_s[1]}";;
                      search3) search3 "${param_s[0]}" "${param_s[1]}";;
                      set_output) set_output "${param_s[0]}" "${param_s[1]}";;
                      compose) compose param_s;;
                      reorder_result) reorder_result "${param_s[0]}" "${param_s[1]}";;
                      insert) insert "${param_s[0]}" "${param_s[1]}" "${param_s[2]}";;
                      set_var) set_var "${param_s[0]}" "${param_s[1]}";;
                      general_answer) general_answer;;
                      *) echo "function not found!"
                    
    esac
}

shopt -s lastpipe
aux $@
#reorder_result
#set_output