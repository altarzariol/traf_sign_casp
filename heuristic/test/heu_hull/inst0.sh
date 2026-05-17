#!/bin/bash
rm -r results.txt
rm -r results_inst.txt
echo "--------------------------------------------"
bash ./compare.sh opdhphse OPT_dhphase OPT_clingcon "900" "ok"
echo "--------------------------------------------"

