#!/bin/bash

#input parameters
declare name=$1
declare label=$2

#variable parameters
declare horizon_s=("600" "660" "720" "780" "840" "900")
declare csv=" ./result/result_${label}.csv "
declare py=" ./inst0.py "
declare py_=" ./inst1.py "
declare csv_dot=" ./result/result_${label}_dot.csv "
declare args="${py}""${csv}" 
declare -g csv_
declare -g args_

function set_args
{
    if [[ "${label}" == *"OPT"* ]]; then
        csv_=" ./../../../Results_experiments/Task2/result.csv "
    else
        csv_=" ./../../../Results_experiments/Task1/result_det_bound.csv " 
    fi
    args_="${py_}""${csv_}""${csv_dot}" 
}

set_args
python3 $args $label

out="./results.txt"
for horizon in "${horizon_s[@]}"; do 
    python3 $args_ $name $horizon  >> "${out}"
done
echo "-------------------------" >> "${out}"
tag=$4
plot="./inst3.py"
python3 "${plot}" "${out}" $name target "${label}"

if [[ $3 == "900" ]]; then
   echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
   for k in "p01" "p02" "p03" "p04" "p05"; do
       python3 $args_ $name "900" $k
   done
fi
