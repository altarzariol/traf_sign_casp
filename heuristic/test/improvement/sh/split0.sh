#!/bin/bash
declare utility="./../aux0.sh"

function clean_file
{
    bash "${utility}" search3 "${root_},${csv_test}" && { rm -r "${csv_test}"; printf "$fst_line"$'\n' > "${csv_test}"; } 
    bash "${utility}" search3 "${root_},${csv_ref}" && { rm -r "${csv_ref}"; printf "$fst_line"$'\n' > "${csv_ref}"; } 
}

function split
{
    clean_file
    tail -n +2 "${csv_dot}" | 
    while IFS=',' read -r ENC HOR PROBLEM l1 l2 l3 l4 l5 TOT; do
          if [[ "${ENC}" == "${enc_test}" ]]; then
             echo "${ENC},${HOR},${PROBLEM},${l1},${l2},${l3},${l4},${l5},${TOT}" >> "${csv_test}"
          else
             echo "${ENC},${HOR},${PROBLEM},${l1},${l2},${l3},${l4},${l5},${TOT}" >> "${csv_ref}"  
          fi
    done
}

shopt -s lastpipe
split