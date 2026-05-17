#!/bin/bash

#input parameters
declare help=$* # -h option about the script

#variable parameters
declare -g sign="#!/bin/bash"
declare -g prefix="inst"
declare -g suffix=".sh"
declare -g root="."

declare -i curr_num
declare -f instance run delete check set



function instance() for n in {1..9}; do touch $prefix$n$suffix; done
function delete() for n in {1..9}; do rm -r $prefix$n$suffix; done
function check() while [[ $curr_num -le $1 ]]; do ((curr_num++)); done 
function search
{
    local place=$1
    local item=$2

    ls "${place}" | 
    while read -r line; do
          if [[ "${line}" == *"${item}"* ]]; then
             return 0
          fi
    done
    return 1
}

function print_elements
{     
    local -n arr_=$1

    echo "The result is "
    for elem in "${arr_[@]}"; do
        echo $elem 
    done 
}

function split_line
{
    local -n _line=$1 _input_s=$2
    local -i start=0
    local -i holder=0
    local -i idx
    
    _line="${_line}stop" 
    until [[ "${_line:$holder:4}" == "stop" ]]; do 
          if [[ "${_line:$holder:1}" == *" "* && $holder -gt $start ]]; then 
             end=$(($holder - $start)) 
             idx="${#_input_s[@]}" 
             _input_s[idx]+="${_line:$start:$end}" #;echo "${_line:$start:$end}" 
             start=$(($holder+1))  
          fi 
          ((holder++))
    done
    end=$(($holder - $start)) 
    idx="${#_input_s[@]}" 
    _input_s[idx]+="${_line:$start:$end}"          #;echo "${_line:$start:$end}" 
}

function set
{
    local script

    script="${prefix}${curr_num}${suffix}" 
    touch $script
    chmod +x $script
    echo $sign > $script
    echo $script "created!"
    search "." "${root}" || mkdir "${root}"
    mv $script "${root}/${script}"
}

function run
{
    local -i word_num 
    local -a word_num_s
    
    curr_num=0
    word_num_s=()
    ls "${root}" | 
    while read -r line; do 

          if [[ "$line" == "$prefix"*"$suffix" ]]; then
  
              name_file=${line%"$suffix"}      #; echo $name_file
              word_num=${name_file:${#prefix}} #; echo $word_num
  
              index=${#word_num_s[@]}          #; echo $index
              word_num_s[index]=$word_num      #; echo ${word_num_s[@]}
                   
              check $word_num                  #; echo $curr_num    
          fi
    done   
}


function expand_cmd
{

    printf %b \
           "bash cmd_name [parameters]\v\r" \
           "paramters (in order):\v\r" \
           "prefix: file prefix. If it is not specified is \"inst\"\v\r" \
           "suffix: file extension. If it is not specified is \".sh\"\v\r" \
           "folder: folder where the file will be.  If it is not specified is\v\r"\
           "the current directory\n" 

    printf %b \
           "\ndescription:\v\r" \
           "this program generates file in sequence specifying a prefix, a suffix\v\r" \
           "and a folder. If not, it prints out a classical script bash file in the\v\r" \
           "current directory.\n"
}


function check_input
{
    local -n param_s=$1
    local -i s_pos=$2
    
    if [[ "${#param_s[@]}" -ge 2 ]]; then
        prefix=${param_s[s_pos]}
        suffix=${param_s[s_pos+1]}
        if [[ "${suffix}" != ".sh" ]]; then
            sign=""
        fi
        if [[ "${param_s[s_pos+2]}" == "-f" ]]; then
            root=${param_s[s_pos+3]}
        fi
    fi

}

function secure_exec
{
    local -i start=$1
    local _input_s
    
    read -e -a _input_s
    check_input _input_s "${start}"

}

function fast_run
{
    local -a input_s=()

    echo "bash filename [prefix] [suffix] [-f foldername]"
    echo -e "bash ./create_scripts.sh\c"

    #input assignment
    secure_exec input_s '0'
    #run program
    execute "no-check" input_s

}

function menu
{   
    select opt in "${options[@]}"; do
           case $opt in continue...) expand_cmd 
                                     menu;;
                        run) fast_run;;
                        exit) echo "bye";;
                        *) echo "non valid option!"
                           menu;;
           esac
    break;
    done
}

function show_cmd
{
    local -a options=("continue..."
                      "run"
                      "exit")

    echo "bash filename [prefix] [suffix] [-f foldername]"
    menu    
}

function execute 
{ 
    local check=$1
    local -n _input_s=$2

    if [[ "${check}" != "no_check" ]]; then   
       check_input _input_s '0'
    fi  
        
    run; set
}

function prompt
{
    local -a input

    case "${help}" in -h) show_cmd;;
                       *) split_line help input
                          execute check input;;
    esac 
}

shopt -s lastpipe
prompt



