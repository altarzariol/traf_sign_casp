#!/bin/bash

export a=pippo
export b=pluto

#echo $( export -p)

declare -a list=("pippo"
                 "giustino")

for l in "${list[@]}"; do
    echo "${l@A}"
    done