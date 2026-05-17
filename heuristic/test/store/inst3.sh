#!/bin/bash

file=./text.txt
declare -i idx del succ=0
declare -a pers tmp pos
#echo " " > $file
echo $(<$file)
#tail -n +1 $file | 
#while read -r line; do echo "pippo" >> $file; done
#for p in "${pers[@]}"; do
#    echo $p >> $file
#done
#echo $(<$file)

#tail -n +0 $file | 
#while read -r line; do 
#      idx="${#pers[@]}"
#      pers[idx]+=$line
#      echo "${#pers[@]} ${pers[@]}"
#done
#echo "${#pers[@]} ${pers[@]}"

select elem in $(<$file) "bye"; do
       case $elem in bye) break;;
       esac
       idx="${#pers[@]}"
       #del="${#pos[@]}"
       pers[idx]+=$elem
       echo $elem >> $file
       #pos[del]+=$REPLY
       #echo "${#pos[@]} ${pos[@]}"
       echo "${#pers[@]} ${pers[@]}"
done
echo "${#pers[@]} ${pers[@]}"

#tail -n +1 $file | 
#while read -r line; do 
#      ((succ++))
#              idx="${#tmp[@]}"
#              tmp[idx]+=$line 
#              echo "${#tmp[@]} ${tmp[@]}"    
#          fi
#      done  
#done
#echo "${#tmp[@]} ${tmp[@]}" 
for sh in $(ls ./inst3.sh text.txt); do 
    mv "${sh}" ./store/"${sh}"
done