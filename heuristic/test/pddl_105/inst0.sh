#!/bin/bash
rm -r results.txt
rm -r results_inst.txt
#echo "--------------------------------------------"
#bash ./compare.sh clingcon asp_bound asp_bound "900" 
echo "--------------------------------------------"
bash ./compare.sh clingcon PDDL_clingcon PDDL_clingcon "900" 
echo "--------------------------------------------"
bash ./compare.sh dhlink PDDL_dhxplink PDDL_dhxplink "900" "ok" 
echo "--------------------------------------------"
