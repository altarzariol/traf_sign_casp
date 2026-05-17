#!/bin/bash
declare task="../../../Results_experiments/Task1/bounds.csv" 
declare unkw="./result/unknown/result_clingcon_asp_bound_dotunkw.csv"
declare -g flag="" 

function where
{
    tail -n +2 "${task}" | 
    while IFS=',' read -r HORIZON PROBLEM MIN; do
          tail -n +2 "${unkw}" | 
          while read -r line; do
                if [[ "${line}" == *"${HORIZON}"*"${PROBLEM:1}"* ]]; then
                   flag="ok"
                fi
          done
          
          if [[ "${flag}" == "ok" ]]; then
             flag="not-ok"
          else
             echo "${HORIZON},${PROBLEM:2}"
          fi
    done

}

shopt -s lastpipe
where

