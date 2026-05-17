#!/bin/bash
declare run="./run0.sh"
declare -a tag_s=("OPTCAFE_DHXplink"
                  "OPTFIRE_DHXplink")
declare -a wload_s=("improve"
                    "aggrega"
                    "plotter")


for tag in "${tag_s[@]}"; do
    for wload in "${wload_s[@]}"; do
        bash "${run}" execute "${tag}" "${wload}"
    done
done