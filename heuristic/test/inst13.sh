#!/bin/bash

declare test_list="packgs0.csv"
declare utility="./aux0.sh"

function move
{
    cp -r "./${pack_test}/${tail}" "."
    cp -r "./${pack_test}/${test_run}" "."
}

function delete
{
    export label
    bash "./${tail}" test_end "${pack_test}" 
}

function execute
{   
    export label
    export test_run
    bash "./${tail}" test_start "${pack_test}" 
}

function unknown
{
  export label
  bash "./${tail}" unknown_results "${pack_test}"       

}

function print
{
    export label
    bash "./${tail}" print_all "${pack_test}"
}


function get_tails
{
    tail -n +2 "${test_list}" | 
    while IFS=',' read -r name package _label _tail runtail; do
          if [[ "${tag}" == "${name}" ]]; then
             pack_test="${package}"
             label="${_label}"
             tail="${_tail}"
             test_run="${runtail}"
             "$@"  
          fi
    done
}

shopt -s lastpipe
get_tails "$@"


