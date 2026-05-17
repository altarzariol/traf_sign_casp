#!/bin/bash
rm -r results.txt
bash ./compare0.sh opdelta OPT_aggrel1
echo "--------------------------------------------"
bash ./compare0.sh bndelta det_bound_NotOpt_aggregatel1
echo "--------------------------------------------"
bash ./compare0.sh opdeltime OPT_deltime
