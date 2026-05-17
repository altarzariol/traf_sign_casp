#!/bin/bash

declare -g args
declare -a argument_s

instance_fixed=" ./model/instance_fixed.lp "
constants=" ./model/constants.lp "
phase_limit=" ./model/data/phase_limit.lp "
turnrate=" ./model/data/turnrate.lp "
capacity=" ./model/data/capacity.lp "
occupancy=" ./model/data/init_occ.lp "
activation=" ./model/data/activation.lp "

configuration=" ./enc_conf.lp "
counter=" ./enc_counter.lp " 
heuristic=" ./enc_heuristic.lp "
change=" ./enc_change.lp "
##TEST_SCRIPTS
test=" ./test_change.lp "

options=" --config=crafty --time-limit=600 --heuristic=Domain "
const_h=" --const horizon="
const_b=" --const bound="

horizon=$1
day=$2
time_slot=$3
scenario="${day}${time_slot}"

instance_round="Instancesv2_round/"
instance="Instancesv2/"
bounds="../../Results_experiments/Task1/bounds.csv" 

root="./result"
dir_txt="$root""/out_txt/"
dir_lp="$root""/out_lp/"

##ARGUMENTS_TEST
#argument_s=("$instance_fixed" 
#            "$constants"
#            "$phase_limit"
#            "$turnrate"
#            "$activation"
#            "$configuration"
#            "$test")

argument_s=("$instance_fixed"
            "$constants"
            "$configuration"
            "$counter"
            "$heuristic"
            "$change"
            "$options")

#argument_s=("$instance_fixed" 
#            "$constants"
#            "$phase_limit"
#            "$turnrate"
#            "$activation"
#            "$configuration")

#argument_s=("$instance_fixed"
#            "$constants"
#            "$configuration"
#            "$counter"
#            "$heuristic"
#            "$options")
#
function compose 
{
    local -n arg_s=$1

    args=""
    for elem in "${arg_s[@]}"; do
        args="$args ""${elem}"
    done
}

function set_output { ls "${dir_lp}${PROBLEM}.lp" && rm -r "${dir_lp}${PROBLEM}.lp" 
}

function run_test
{
    local key=$1

    tail -n +2 $bounds | while IFS=',' read -r HORIZON PROBLEM MIN; do
        if [[ "$PROBLEM" == *"$instance"*"$scenario"*"$key"* ]]; then
            if [[ "$HORIZON" == "$horizon" ]]; then 
                echo $HORIZON $PROBLEM
                asp_instance="../../${PROBLEM}.lp"
                clingcon $asp_instance \
                         $args \
                         $const_h$HORIZON \
                         $const_b$MIN \
                         > "${dir_txt}${PROBLEM}.lp" 2>/dev/null
                tail -n +1 < "${dir_txt}${PROBLEM}.lp" |
                reorder_result "${PROBLEM}"
            fi
        fi
    done
}

function reorder_result
{
    local PROBLEM=$1
    local lines=""
    local -i start=0
    local -i holder=0
    
    set_output
    while read -r line; do lines="${lines}${line}"; done; lines="${lines}stop" 
    until [[ "${lines:$holder:4}" == "stop" ]]; do 
          if [[ "${lines:$holder:1}" == *" "* && $holder -gt $start ]]; then 
             end=$(($holder - $start)) #; echo "${lines:$k:$end}"
             echo "${lines:$start:$end}" >> "${dir_lp}${PROBLEM}.lp" 
             start=$(($holder+1))  
          fi 
          ((holder++))
    done
    end=$(($holder - $start)) 
    echo "${lines:$start:$end}" >> "${dir_lp}${PROBLEM}.lp" #;echo $holder
                                                            #; pre=$lines" "
                                                            #; echo "${pre:$1:-1}"; 
}


shopt -s lastpipe
compose argument_s
run_test p01
run_test p03

 
            





###works!!
#function run() while read -r line; do echo $line; done; tail -n +1 ./inst19.sh | run  



#clingo $args | tail -n +5 | while read -r line; do
#            stop=$line"stop"
#            until [[ "${stop:$n:4}" == "stop" ]]; do 
#                  if [[ "${line:$n:1}" == *" "* && $n -gt $k ]]; then 
#                     end=$(($n - $k))
#                     echo "${line:$k:$end}" >> $output ; k=$n+1
#                  fi; ((n++))
#            done; end=$(($n - $k)); echo "${line:$k:$end}" >> $output
#            echo $n; ex=$line" "; echo "${ex:$1:-1}"; exit
#        done
       
#clingo $args
