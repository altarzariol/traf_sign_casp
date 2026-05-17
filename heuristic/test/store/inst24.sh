#!/bin/bash

declare -a prefix_s=("inst"
                     "aux")
declare utility="./${prefix_s[1]}0.sh"

flp=./result/out_lp/Instancesv2/sippv2/fixlen4/muse/"p01[count=350].lp"
ftxt=./result/out_txt/Instancesv2/sippv2/fixlen4/muse/"p01[count=350].lp"

tail -n +1  < "${ftxt}" |
bash "${utility}" reorder_result "${flp%"p01[count=350].lp"}","p01[count=350].lp"
#echo "${flp%%"p0"*}" $(ls "${flp%%"p0"*}" | while read -r line; do 
#                                                  if [[ "${flp%%"p0"*}${line}" == "${flp}" ]];then
#                                                     echo "${line}"
#                                                  fi
#                                            done)
#
par="${flp%%"p0"*}"                                            
echo "${#par}"
declare -i l="${#par}"
echo "${flp:l}"

function split
{
    local origin=$1 k=$2
    local -n _root=$3 _tail=$4
    _root="${origin%%"$k"*}"
    local -i len="${#_root}"
    _tail="${origin:len}"
}

declare root tail
split $flp "p01" root tail
echo $root $tail
#bash "${utility}" set_output "${flp%"p01[count=350].lp"}","p01[count=350].lp"

