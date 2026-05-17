#!/bin/bash
rm -r results.txt
rm -r results_inst.txt
echo "--------------------------------------------"
bash ./compare.sh clingcon asp_bound asp_bound "900" "ok"
echo "--------------------------------------------"

