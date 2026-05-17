#!/bin/bash

#variable parameters
declare -a scripts_s #list of scripts

function pick_scripts
{
    local -i idx
    ls "." | 
    while read -r line; do 
          if [[ "${line}" == *".sh" &&
                "${line}" != "info.sh" ]]; then
             idx="${#scripts_s[@]}"
             scripts_s[idx]+="${line}"
          fi
    
    done
}

function search_info
{
    local script=$1

    tail -n +1 "${script}" | 
    while read -r line; do
          if [[ "${line}" == *"help=$"* ]]; then
             return 0
          fi  
    done
    return 1
}

function print_info
{
    local f_info=$1

    (search_info "${f_info}" && bash "${f_info}" -h) ||
    (echo -e "information not available.") 
}

function general_info
{
    
    select file in "${scripts_s[@]}" "exit"; do
           case "${file}" in *.sh) print_info "${file}"
                                   general_info;;
                             exit) echo "bye";;
                             *) echo "no valid option!"
                                general_info;;                    
           esac                 
    break;
    done
}

function prompt
{
    pick_scripts
    general_info
}

shopt -s lastpipe
prompt
         
