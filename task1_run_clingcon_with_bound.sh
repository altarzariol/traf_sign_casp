#!/bin/bash
PPS=./bin/pps.jar
DOMAIN=./pddl_encoding.pddl
KEY=$1
Bounds_file="Results_experiments/Task1/bounds.csv" 
TEMP="$(mktemp)" 

##
## NOTE for experiment: remove the optimization statement from enc_clingcon.lp
##

tail -n +2 "$Bounds_file" | while IFS=',' read -r HORIZON PROBLEM MIN; do
    ASP_INSTANCE="${PROBLEM}.lp"
    ASP_OUTPUT="${PROBLEM%.pddl}_asp_det_bound_$HORIZON.txt"
    if [[ "$PROBLEM" == *"$KEY"* ]]; then
        echo $ASP_INSTANCE
        clingcon ./instance_fixed.lp ./enc_clingcon.lp $ASP_INSTANCE --const horizon=$HORIZON --const bound=$MIN --config=crafty --time-limit=600 > $ASP_OUTPUT 2>/dev/null

        python3 AS2Plan.py $HORIZON $ASP_OUTPUT "${PROBLEM}.pddl"
 
    fi
    
done
