#!/bin/bash

for sh in $(ls ./{manager,data,inst6}*.sh); do 
    mv "${sh}" ./store/"${sh}"
done