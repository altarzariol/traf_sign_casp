#!/bin/bash

declare sign="#!/bin/bash"
declare prefix="inst"
declare suffix=".sh"

declare -i curr_num
declare -f instance run delete check set



function instance() for n in {1..9}; do touch $prefix$n$suffix; done
function delete() for n in {1..9}; do rm -r $prefix$n$suffix; done
function check() while [[ $curr_num -le $1 ]]; do ((curr_num++)); done 
function set
{
    local script

    script="${prefix}${curr_num}${suffix}" 
    touch $script
    chmod +x $script
    echo $sign > $script
    echo $script "created!"
}

function run
{
    local -i word_num 
    local -a word_num_s
    
    curr_num=0
    word_num_s=()
    ls | while read -r line; do 

        if [[ "$line" == "$prefix"*"$suffix" ]]; then

            name_file=${line%"$suffix"}      #; echo $name_file
            word_num=${name_file:${#prefix}} #; echo $word_num

            index=${#word_num_s[@]}          #; echo $index
            word_num_s[index]=$word_num      #; echo ${word_num_s[@]}
                 
            check $word_num                  #; echo $curr_num    
        fi
    done   
}

shopt -s lastpipe
run; set;


