#!/bin/bash

declare -a arr_=("pippo_p01"
                 "pluto_p02"
                 "topolina_p03")
shopt -s extglob 

for ar in "${arr_[@]}"; do
    if [[ "${ar}" == *'_'!(*"p01") ]]; then
        echo "${ar}"
    fi
done