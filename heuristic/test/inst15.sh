#!/bin/bash

#input parameters
declare home=$1
declare label=$2

#variable parameters
declare -a asp_outputs 
declare -a answ_sets
declare -a path
declare utility="./aux0.sh"


asp_outputs=()
answ_sets=()
path=("wrac1,y,wrbc1" 
      "wrbc1,b,wrcc1" 
      "wrcc1,x,wrdc1" 
      "wrdc1,b,wrec1" 
      "wrec1,y,wrfc1")
csv="${dir}${home}/${label}_${horizon}_${scenario}.csv"
task1="../../Results_experiments/Task1/bounds.csv"  

function set_csv { 
    bash "${utility}" search "${dir}","${home}" || mkdir "${dir}${home}"
    bash "${utility}" search "${dir}${home}","${label}_${horizon}_${scenario}.csv" && 
    rm -r "$csv"; printf "$fst_line"$'\n' > "$csv" 
}

function print_elements
{     
    local -n arr_=$1

    echo "The result is "
    for elem in "${arr_[@]}"; do
        echo $elem 
    done 
}

function search
{
    local place=$1
    local item=$2

    tree "${place}" -i -f | 
    while read -r line; do
          if [[ "${line}" == *"${item}"* ]]; then
             return 0   
          fi
    done
    return 1
}

function is_there
{
    local inst_=$1
    local -i len

    len="${#dir}"
    if  search "." "${dir}${inst_:len+2}"; then
        idx=${#asp_outputs[@]}
        asp_outputs[idx]="${dir}${inst_:len+2}"
    fi
}

function select_instances
{
    local -n _asp_outputs=$1
    local -i len

    prefix="./Instancesv2_round/sippv2/"
    len=${#prefix}

    for sufx in "random/" "sipp/" "sippv2/"; do
        tail -n +2 $task1 | while IFS=',' read -r HORIZON PROBLEM MIN; do
            if [[ "$PROBLEM" == *"_round"*"$scenario"*  && "$HORIZON" == "$horizon" ]]; then
               problem="./Instancesv2_round/${sufx}${PROBLEM:len}" #;echo $problem
               #echo "${dir}${problem}_${label}_$HORIZON.txt" 
               is_there "${dir}${problem}_${label}_$HORIZON.txt"               
            fi
        done  
    done
}

function calculate_position
{
    local -n word=$1 _line=$2 _len=$3 _start=$4 _end=$5

    #calculate word's length
    _len=${#word}
    #calculate the starting and ending poisition of the word in line
    _start=0
    until [[ "$word" == "${_line:$_start:$_len}" ]]; do ((_start++)); done
    _end=$(($_start + $_len))   #; echo $_end
}

function calc_atom_value
{   
    local -n _atom_value=$1 _end=$2 _line=$3 
    local digit
    
    #start consifering the first digit of the atom
    digit="${_line:$_end:1}"
    _atom_value=""
    until [[ $(case $digit in 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9) echo -n $digit;;
                              *) echo -n "end";;
               esac) == "end" ]]; do 
        _atom_value=$_atom_value$digit
        ((_end++))
        digit="${_line:$_end:1}" #;echo $_atom_value
    done
}

function find_counter
{
    local -i len start end 
    local -n line_=$1 
    local counter_value

    for link in "${path[@]}"; do 
        if [[ "$line_" == *"counter(${horizon},link(${link}))="* ]]; then    
          counter="counter(${horizon},link(${link}))="
          calculate_position counter line_ len start end
          calc_atom_value counter_value end line_ 
          answ_sets[-1]+=";${line_:$start:$len}${counter_value[@]}"
          #echo "${line_:$start:$len}${counter_value[@]}"
        fi
    done
     
}

function calc_answ_number { calc_atom_value $1 $2 $3
}

function find_answ_sets
{   
    local -i len start end 
    local -n _asp_output=$1 line_=$2 
    local n_answer

    if [[ "$line_" == *"Answer: "* ]]; then
      answer="Answer: "
      calculate_position answer line_ len start end
      calc_answ_number n_answer end line_
       
      idx="${#answ_sets[@]}"
      answ_sets[idx]=$_asp_output"::"${line_:$start:$len}${n_answer[@]}
      #echo "${line_:$start:$len}${n_answer[@]}"
      #print_elements answ_sets
    fi
}

function read_instances
{ 
   for asp_out in "${asp_outputs[@]}"; do
      #echo $asp_out":: opened "
      tail -n +2 $asp_out | while read -r line; do 
          find_answ_sets asp_out line
          find_counter line      
      done
   done 
   #echo $asp_out":: closed "
}

function get_num_link
{
    local word=$1
    local -n _link_n=$2
    local -i n=0

    for link in "${path[@]}"; do
        if [[ "$word" == *"$link"* ]]; then
            _link_n=$n; else
            ((n++))
        fi
    done #; echo $word "number:"$_link_n

}


function go_ahaed
{
    local -n _key=$1 _prefix=$2 _elem=$3 link_n_=$4
    local -i start  

    start=${#_prefix}
    until [[ "$_key" == "${_elem:$start:1}" ]]; do ((start++)); done
    get_num_link "${_elem:${#_prefix}:$(($start - ${#_prefix}))}" link_n_ 

    ((start++))
    _prefix="${_elem:0:$start}"
}


function print_line
{
    local -n _counter_s=$1
    
    line=""
    for item in "${_counter_s[@]}"; do line="$line""$item"; done
    printf "clingcon,${horizon},${asp_out}${line}"$'\n' >> $csv
    
}

function find_best_solution
{
    local asw_num
    local -i len start end 
    local -a asp_answer_s
    local -n _asp_out=$1 _answ_set=$2 _set=$3

    asp_answer_s=()
    for elem in "${answ_sets[@]}"; do
        if [[ "$elem" == "$_asp_out"* ]]; then
            idx="${#asp_answer_s[@]}"
            asp_answer_s[idx]+="$elem"
        fi
    done 

    answer="Answer: "
    if [[ "${#asp_answer_s[@]}" -gt 0 ]]; then
        _set=${asp_answer_s[-1]} 
        calculate_position answer _set len start end
        calc_answ_number asw_num end _set
        _answ_set="${answer}""${asw_num}"
        
    fi
}


function calculate_tot_counter
{
    local key="="
    local prefix
    local answ_set
    local best_set
    local counter_value
    local -i end tot_value link_n
    local -a counter_s 
    
    #echo "------------------------------------------------------------------"
    for asp_out in "${asp_outputs[@]}"; do
        #find for all the asp_outputs only the results of the best answer set
        find_best_solution asp_out answ_set best_set
        prefix="${asp_out}::""${answ_set}"
        #get the value of each counter atom in the answer set 
        tot_value=0 
        end=${#prefix}
        counter_s=(, , , , ,)
        last=${#counter_s[*]}
        if [[ "$best_set" == "$prefix"* ]]; then
           while [[ "${best_set:$end:1}" == ";" ]]; do
                 go_ahaed key prefix best_set link_n
                 end=${#prefix}                         #; echo $prefix
                 calc_atom_value counter_value end best_set
                 #sum all the counter's values 
                 tot_value+=$counter_value              #; echo $tot_value
                 #add values to printout
                 counter_s[$link_n]+=$counter_value     #; echo ${counter_s[*]}
                 counter_s[last]=","$tot_value          #; echo ${counter_s[*]}
           done
           print_line counter_s
        fi
        
    done

}

shopt -s lastpipe
set_csv
select_instances asp_outputs
read_instances
calculate_tot_counter
