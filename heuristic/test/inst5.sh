#!/bin/bash

#variable parameters
declare utility="./aux0.sh"
declare home="${test_name}_csv"

csv_tot="${dir}result_${label}.csv"

function set_csv { 
    bash "${utility}" search "${dir}","result_${label}.csv" &&  
    rm -r $csv_tot; printf "$fst_line"$'\n' > $csv_tot 
}

function group_all
{
    set_csv
    ls "${dir}${home}/" | 
    while read -r line; do
          if [[ "${line}" == *"${label}"* ]]; then
             tail -n +2 "${dir}${home}/${line}" | 
             while read -r ln; do 
                   printf "${ln}"$'\n' >> "${csv_tot}"
             done
          fi
    done
}

"$@"

