#!/bin/bash

function add
{
    local -n lst=$1
    local -i idx

    idx="${#lst[@]}"
    lst[idx]+="${input}"
    echo "${lst[@]}"
}

function check_input
{
    local -n lst=$1

    #first check list
    for l in "${lst[@]}"; do
        if [[ "$l" == "${input}" ]];then
            echo "this input exists!"
            return 1
        fi
    done
    #then check horizon
    for h in "${horz_s[@]}"; do
        if [[ "$h" == "${input}" ]];then
            return 0
        fi
    done
    return 1
}

function insert
{
    local -n list_=$1

    echo "horizon: ""${horz_s[@]}"
    echo -e "choose::\c"
    read -e input
    check_input list_ && echo "valid input!" && add list_ ||
    (echo "input not valid")
}

function change
{
    local -n swap_s=$1
    local -n _output=$2
 
    #echo "ciao"
    for sw in "${swap_s[@]}"; do
        has_item "${sw}" _output &&
        addi "${sw}" _output
    done

}

function addi
{
    local in_=$1
    local -n lst=$2
    local -i idx

    idx="${#lst[@]}"
    lst[idx]+="${in_}" #;echo "${lst[@]}"
}

function has_item
{
    local item=$1
    local -n out=$2
    for elem in "${out[@]}"; do
        if [[ "${elem}" == "${item}" ]]; then
            return 1
        fi
    done
    return 0
}