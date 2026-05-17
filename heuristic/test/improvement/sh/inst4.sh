#!/bin/bash
declare task="../../../Results_experiments/Task1/bounds.csv" 
declare utility="./../aux0.sh"

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
 
    if  search "${root_}" "${root_}/${inst_:2}"; then
        _asp_output="${root_}/${inst_:2}" #;echo "${_asp_output}"
        return 0
    else
        return 1
    fi
}

function clean_file
{
    bash "${utility}" search3 ".,${unknown_inst}" && rm -r "${unknown_inst}"
    bash "${utility}" search3 ".,${dotunkw_inst}" && { rm -r "${dotunkw_inst}"; printf "$fst_line"$'\n' > "${dotunkw_inst}"; } 
}

function unknown
{
    local asp_output

    clean_file
    if [[ "${encoding}" == "clingcon" ]]; then      
        tail -n +2 $task | 
        while IFS=',' read -r horizon problem min; do
              #echo "${home_}/${problem:2}_${label}_$horizon.txt"
              is_there asp_output "${home_}/${problem:2}_${label}_$horizon.txt" &&
              tail -n +1 "${asp_output}" | while read -r line; do    
                      if [[ "${line}" == *"UNKNOWN"* ]]; then
                         echo "${asp_output}" >> "${unknown_inst}"
                         echo "${encoding},${horizon},${root_:3}${home_:1}${problem:1},,,,,,0" >> "${dotunkw_inst}"
                      fi
              done
        done
    fi
 
}

shopt -s lastpipe
unknown
