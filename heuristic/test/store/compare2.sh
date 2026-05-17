#!/bin/bash 
horizon_s=("600" "660" "720" "780" "840" "900")
name=$1
label=$2
#csv=" ./result/result_${label}.csv "
csv="./label.csv"
py=" ./inst0.py "
py_=" ./inst1.py "
#csv_=" ./../../../Results_experiments/Task1/result_det_bound.csv " 
csv_="./new_bound.csv"
#csv_dot=" ./result/result_${label}_dot.csv "
csv_dot=" ./label_dot.csv "
args="${py}""${csv}" 
args_="${py_}"" ${csv} "" ${csv_}" 


function sift()
{
    local prefix="./heu_volume/result/"
    local i len="${#prefix}"
    local csv_l="./result/result_${label}.csv"
    local csv_t="./../../../Results_experiments/Task1/result_det_bound.csv" 

    tail -n +2 "${csv_t}"| while IFS=',' read -r encoding horizon problem C1 C2 C3 C4 C5 T; do
            tail -n +2 "${csv_t}" | while IFS=',' read -r ENC HOR PRO c1 c2 c3 c4 c5 tot; do
                    if [[ "${encoding}" == "clingcon" && "${ENC}" == "fire" &&
                          "${HOR}" == "${horizon}" &&
                          "${problem}" == "${PRO}" ]]; then #"./${problem:len}" == "${PRO}"*
                        echo "${ENC},${HOR},${PRO},${c1},${c2},${c3},${c4},${c5},${tot}" >> "${csv_}"
                        echo "${encoding},${horizon},${problem},${C1},${C2},${C3},${C4},${C5},${T}" >> "${csv}"
                    #else
                    #    echo "${encoding}" != "${ENC}" >> text.txt
                    #    echo "${horizon}" == "${HOR}" >> text.txt
                    #    echo "${problem}" == "${PRO}" >> text.txt
                    fi
                    #echo "./${problem:len}" >> text.txt
                    #"${PRO}"
                    #"./${problem:len}"
            done
            #echo "caip"
    done
}

#sift

#python3 $args $label

for horizon in "${horizon_s[@]}"; do 
    python3 $args_ $name $horizon ""
done

if [[ $3 == "900" ]]; then
   echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
   for k in "p01" "p02" "p03" "p04" "p05"; do
       python3 $args_ $name "900" $k
   done
fi