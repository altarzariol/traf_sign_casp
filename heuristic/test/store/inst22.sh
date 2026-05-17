#!/bin/bash

for sh in $(ls ./inst*.sh); do 
    mv "${sh}" ./store/"${sh}"
done