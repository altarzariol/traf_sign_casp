#!/bin/bash
rm -r results.txt
rm -r results_inst.txt
#echo "--------------------------------------------"
#bash ./compare.sh clingcon asp_bound asp_bound "900" 
#echo "--------------------------------------------"
#bash ./compare.sh clingcon pddl-bnd_clingcon pddl-bnd_clingcon "900" 
echo "--------------------------------------------"
bash ./compare.sh dhxlinkc cafe-bnd_dhxplink  cafe-bnd_dhxplink "900" "ok" 
echo "--------------------------------------------"
