#!/bin/bash

declare utility="./../aux0.sh"

# aggregate over horizons
declare horizon_s=("600" "660" "720" "780" "840" "900")
# aggregate over instance
declare inst900="900"

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
    _input_s[idx]+="${line:$start:$end}"          #;echo "${line:$start:$end}" 
}

function add_dot
{ 
    local lb_=$1

    tail -n +2 "${root_}/${home_}/result_${lb_}_dot.csv" | 
    while read -r line; do 
          echo "${line}" >> "${dotunkw_inst}"
    done
}

function create_dotunkw
{
    # pick the unknown results
    export csv_dot="${root_}/${home_:2}/result_${label}_dot.csv"
    if [[ "${double_enc}" == "true" ]]; then
        export csv_test="${root_}/${home_:2}/result_${enc_test}_${label}_dot.csv"
        export csv_ref="${root_}/${home_:2}/result_${enc_ref}_${label}_dot.csv"
        bash "${split}" 
        for lb in "${enc_test}_${label}" "${enc_ref}_${label}"; do
             export encoding="${lb%'_'$label}"
             echo "${encoding}"
             export unknown_inst="${dir_}/unknown_${lb}.txt"
             export dotunkw_inst="${dir_}/result_${lb}_dotunkw.csv" 
             bash "${unknw}"          
             add_dot "${lb}"
             csv_="${csv_dot%'_'${label}'_dot.csv'}_${lb}_dot.csv"
             echo $csv_
             bash "${enc_record}" add_file "${csv_}" "${lb}"
        done
    else
         export encoding="${enc_test}"
         export unknown_inst="${dir_}/unknown_${label}.txt"
         export dotunkw_inst="${dir_}/result_${label}_dotunkw.csv" 
         bash "${unknw}"           
         add_dot "${label}"
         bash "${enc_record}" add_file "${csv_dot}" "${label}"
    fi
    
}


function improvement
{
    split_line "$(bash "${get}" get_parameters)" arg_s ;echo "${arg_s[@]}"
    export dotunkw_test="${arg_s[0]}"
    export dotunkw_ref="${arg_s[1]}"
    export imprv_test="${arg_s[2]}"
    export imprv_ref="${arg_s[3]}"
    bash "${diff}" 
}


function aggregate
{
    bash "${utility}" search3 ".,${result_hor}" && rm -r "${result_hor}"  
    bash "${utility}" search3 ".,${result_inst}" && rm -r "${result_inst}"
    bash "${get}" add_data "${result_hor}" "${result_inst}"

    split_line "$(bash "${get}" get_improvements)" arg_s #;echo "${arg_s[@]}"
    csv_test_dot="${arg_s[0]}"
    csv_ref_dot="${arg_s[1]}"

    echo "-------------------------" 
    # horizon aggregation
    for horizon in "${horizon_s[@]}"; do 
        python3 "${py_aggr}" \
                "${csv_ref_dot}" \
                "${csv_test_dot}" \
                "${name_ref}" \
                "${name_test}" \
                "${horizon}" \
                "" \
                "${enc_ref}" \
                "${enc_test}" >> "${result_hor}"
    done
    echo "-------------------------" >> "${result_hor}"

    cat "${result_hor}"
    # instance aggregation
    if [[ $inst900 == "900" ]]; then
      echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
      for k in "p01" "p02" "p03" "p04" "p05"; do
          python3 "${py_aggr}" \
                  "${csv_ref_dot}" \
                  "${csv_test_dot}" \
                  "${name_ref}" \
                  "${name_test}" \
                  "900" \
                  $k  \
                  "${enc_ref}" \
                  "${enc_test}"   >> "${result_inst}"
      done
    fi
    echo "-------------------------" >> "${result_inst}"

}

function plot
{

    split_line "$(bash "${get}" get_data_plot)" arg_s #;echo "${arg_s[@]}"
    data_plot="${arg_s[0]}"
    split_line "$(bash "${get}" get_name_plot)" arg_s #;echo "${arg_s[@]}"
    name_test="${arg_s[2]}"
    name_ref="${arg_s[3]}"
    
    echo "${py_plot}" "${data_plot}" "${name_test}" target "${tag_}" "${name_ref}"
    python3 "${py_plot}" \
            "${data_plot}" \
            "${name_test}" \
            target \
            "${tag_}" \
            "${name_ref}" \
            "${name_plot}" \
            "${place}"
  

}

shopt -s lastpipe
"$@"




