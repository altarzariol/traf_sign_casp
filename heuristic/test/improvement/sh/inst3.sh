#!/bin/bash

declare utility="./../aux0.sh"
declare diff_line="Encoding,Horizon,Problem,counter wrac1_y_wrbc1,counter wrbc1_b_wrcc1,counter wrcc1_x_wrdc1,counter wrdc1_b_wrec1,counter wrec1_y_wrfc1,Total,Diff"

function clean_file
{
    bash "${utility}" search3 ".,${imprv_test}" && { rm -r "${imprv_test}"; printf "$diff_line"$'\n' > "${imprv_test}"; }
    bash "${utility}" search3 ".,${imprv_ref}" && { rm -r "${imprv_ref}"; printf "$diff_line"$'\n' > "${imprv_ref}"; }
}

function calculate_improvement
{
    local asp_output
    local -i num
   
    num=0
    clean_file
    echo "${dotunkw_test}" "${dotunkw_ref}"
    tail -n +2 "${dotunkw_test}" | 
    while IFS=',' read -r ENC HOR PROBLEM l1 l2 l3 l4 l5 TOT; do
        tot1=$(echo "$TOT" | bc -l)
        tail -n +2 "${dotunkw_ref}" | 
        while IFS=',' read -r enc hor problem l1 l2 l3 l4 l5 tot; do
              if [[ "$PROBLEM" == "$problem" && "$HOR" == "$hor" ]]; then
                 tot2=$(echo "$tot" | bc -l)
                 #diff=$(echo "($tot2 - $tot1)*100/$tot1" | bc -l) ;echo $diff
                 diff=$(echo "$tot2 - $tot1" | bc -l) #;echo $diff
                 if (( $(echo "$diff > 0" | bc -l) )); then 
                    #echo "${enc},${hor},${problem},${l1},${l2},${l3},${l4},${l5},${tot},${diff}"
                    echo "${enc},${hor},${problem},${l1},${l2},${l3},${l4},${l5},${tot},${diff}" >> "${imprv_ref}"
                 elif (( $(echo "$diff < 0" | bc -l) )); then 
                      diff=$(echo "- $diff" | bc -l)
                      #echo "${enc},${hor},${problem},${l1},${l2},${l3},${l4},${l5},${tot},${diff}"
                      echo "${ENC},${HOR},${PROBLEM},${l1},${l2},${l3},${l4},${l5},${TOT},${diff}" >> "${imprv_test}"
                 fi
             fi
        done
    done

    
 
}

shopt -s lastpipe
calculate_improvement
