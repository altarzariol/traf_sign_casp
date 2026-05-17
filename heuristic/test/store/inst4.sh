#!/bin/bash

export args
declare -a argument_s

argument_s=("ciao"
            " pippo"
            ","
            "sono"
            " pippa")

function compose 
{
    local -n arg_s=$1

    args=""
    for elem in "${arg_s[@]}"; do
        args="$args ""${elem}"
    done
}

export -f compose

bash ./inst3.sh "${argument_s[@]}"