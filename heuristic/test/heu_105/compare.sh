#!/bin/bash 

#input parameters
declare name=$1
declare label=$2
declare label_ref=$3
declare inst900=$4
#declare tag=$5
declare go=$5

#variable parameters

## -- python utilities -- ##
declare -g py_dot="  ./inst0.py "   # dot-convertitor
declare -g py_aggr=" ./inst1.py "   # results aggregator
declare -g py_plot="./inst6.py"     # plotter

## -- csv files -- ##
declare -g csv_host     # host: experiment
declare -g csv_host_dot # dot-host: after dot-conversion

declare -g csv_ref      # reference: to compare with experiment
declare -g csv_ref_dot  # dot-reference: after dot-conversion

# aggregate over horizons
declare horizon_s=("600" "660" "720" "780" "840" "900")
declare -g data_plot="./results.txt" # data for the plotter
declare -g data_plot_inst="./results_inst.txt" # data for the plotter

### -- DOT CONVERSION -- ###
function set_csv_host
{
    csv_host=" ./result/result_${label}.csv "
    csv_host_dot=" ./result/result_${label}_dot.csv "

    # dot-conversion
    args="${py_dot}""${csv_host}" 
    python3 $args $label
    
}

function set_csv_reference
{
    csv_ref=" ./result/result_${label_ref}.csv "
    csv_ref_dot=" ./result/result_${label_ref}_dot.csv "

    # dot-conversion
    args="${py_dot}""${csv_ref}" 
    python3 $args $label_ref
}

### -- AGGREGATION PROCESS -- ###
function aggregate
{
    # horizon aggregation
    args="${py_aggr}""${csv_ref_dot}""${csv_host_dot}" 
    for horizon in "${horizon_s[@]}"; do 
        python3 $args $name $horizon "" >> "${data_plot}"
    done
    echo "-------------------------" >> "${data_plot}"

    
    # instance aggregation
    if [[ $inst900 == "900" ]]; then
      echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
      for k in "p01" "p02" "p03" "p04" "p05"; do
          python3 $args $name "900" $k  >> "${data_plot_inst}"
      done
    fi
    echo "-------------------------" >> "${data_plot_inst}"
}

function plot
{
    python3 "${py_plot}" "${data_plot}" $name target "${label}"
}

function print
{
  if [[ $go == *"ok"* ]];then cat "${data_plot}"; fi 
  
}

set_csv_host
set_csv_reference
aggregate
print
#plot







