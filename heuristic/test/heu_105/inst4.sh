#!/bin/bash 
echo "--------------------------------------------"
bash ./inst5.sh hphase hlink OPT_dhxphase OPT_dhxplink OPT_clingcon heuristic_nodelta hphase hlink
echo "--------------------------------------------"
bash ./inst5.sh "hphase(-theory)" "hlink(-theory)" OPT_dhxphase_plus OPT_dhxphase OPT_clingcon heuristic_original hphase hlink
echo "--------------------------------------------"