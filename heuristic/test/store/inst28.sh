#!/bin/bash

declare scenario

function test
{
  [[ "${day}" == "muse" ]] && scenario="${day}" || scenario="${day}${time_slot}"  
  echo $scenario $ciao
}

#test
echo "${day}${time_slot}"