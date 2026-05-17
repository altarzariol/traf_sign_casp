#!/bin/bash
declare test="fixed-test-"
declare tnum_s=("5" "10" "14" "15" "17" "18")
declare horizon_s=("600" "660" "720" "780" "840" "900")
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
    for sufx in "${tnum_s[@]}"; do
        for p in "p01" "p02" "p03" "p04" "p05" "p06" "p07"; do
            for hrz in "${horizon_s[@]}"; do
               problem="./hull/${test}${sufx}${p}[count=350]" #;echo $problem
               is_there asp_output "${dir}${problem}_${label}_$hrz.txt" &&
               tail -n +1 "${asp_output}" | while read -r line; do    
                       if [[ "${line}" == *"UNKNOWN"* ]]; then
                          echo "${asp_output}" >> "${unknown_inst}"
                       fi
            done
        done
    done

    #tail -n +1 "${unknown_inst}" | while read -r line; do cat "${line}"; done
 
}

shopt -s lastpipe

"$@"
