#!/bin/bash
declare task="../../Results_experiments/Task1/bounds.csv" 
declare utility="./aux0.sh"
declare unknown_inst="${dir}unknown_${label}.txt"

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

function is_there
{
    local -n _asp_output=$1
    local inst_=$2
    local -i len

    len="${#dir}"
    if  search "." "${dir}${inst_:len+2}"; then
        _asp_output="${dir}${inst_:len+2}"
        return 0
    else
        return 1
    fi
}

function clean_file
{
    bash "${utility}" search ".,${unknown_inst}" && rm -r "${unknown_inst}"
}

function unknown
{
    local asp_output

    clean_file
    tail -n +2 $task | while IFS=',' read -r HORIZON PROBLEM MIN; do
           is_there asp_output "${dir}${PROBLEM}_${label}_$HORIZON.txt" &&
           tail -n +1 "${asp_output}" | while read -r line; do    
                   if [[ "${line}" == *"UNKNOWN"* ]]; then
                      echo "${asp_output}" >> "${unknown_inst}"
                   fi
           done
    done

    #tail -n +1 "${unknown_inst}" | while read -r line; do cat "${line}"; done
 
}

shopt -s lastpipe

"$@"
