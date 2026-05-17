#!/bin/bash
rm -r results.txt
echo "--------------------------------------------"
bash ./compare.sh ophrate OPT_heurate "900" 
echo "--------------------------------------------"
bash ./compare.sh ophphse OPT_heuphase "900" 
echo "--------------------------------------------"
bash ./compare.sh bndhphse BND_dhphase 
echo "--------------------------------------------"
bash ./compare.sh bnlngrate BND_longrate 
echo "--------------------------------------------"
bash ./compare.sh bnheuphse NotOpt_heuphase_bound 
echo "--------------------------------------------"
bash ./compare.sh bnphlngr BND_phlongr 
echo "--------------------------------------------"
bash ./compare.sh opdhphse OPT_dhphase "900" 
echo "--------------------------------------------"
#bash ./compare2.sh fire "" ""
