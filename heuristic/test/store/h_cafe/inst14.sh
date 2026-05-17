#!/bin/bash

horizon=$1
scenario=$2
#day=$2
#time_slot=$3
#scenario="${day}${time_slot}"


instance_round="Instancesv2_round/"
instance="Instancesv2/"
bounds="../Results_experiments/Task1/bounds.csv" 


#clingcon files
fixed="../instance_fixed.lp "
clingcon="./test/model/constants.lp ./test/model/enc_conf.lp"
delta="./test/model/enc_delta_sum.lp"
input_files=" ${fixed} ${clingcon} ${delta} "
options=" --config=crafty --time-limit=600 "
const_h=" --const horizon="
const_b=" --const bound="

run_instances()
{
    tail -n +2 $bounds | while IFS=',' read -r HORIZON PROBLEM MIN; do
        if [[ "$PROBLEM" == *"$instance"*"$scenario"* ]]; then
           if [[ "$HORIZON" == "$horizon" ]]; then 
              echo $HORIZON $PROBLEM 
              asp_instance="../${PROBLEM}.lp"
              asp_output="${PROBLEM}_asp_bound_${label}_$HORIZON.txt"
              clingcon $asp_instance \
                       $input_files \
                       $const_h$HORIZON \
                       $const_b$MIN \
                       $options > $asp_output 2>/dev/null
    
           fi 
        fi

    done

}

run_instances