#!/bin/bash
#coproc sweag { echo ciao; }


declare -g -i end=2

function parallel
{
    print $1 & check $2 sofia gioca & check $2 massimo perde & 
}

function check
{
   print $1; if [[ $end == 0 ]]; then exit; else ((end--)); parallel $2 $3 ; fi;
}

function print
{
    echo $1
}

#read -u ${sweag[0]} result
#echo $result
parallel ciao pippo