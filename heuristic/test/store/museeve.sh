#!/bin/bash

tree -i -f | 
while read -r line; do 
     if [[ "${line}" == *"museeve"* ]]; then 
        mv "${line}" "${line%%"museeve"*}""muse.csv"
     fi
done
tree -i 
