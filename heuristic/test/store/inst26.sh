#!/bin/bash

tree -i -v -f | 
while read -r line; do 
      if [[ "${line}" == *".sh" ]]; then
         echo $line 
      fi
done