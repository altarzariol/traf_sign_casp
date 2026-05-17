#!/bin/bash

### Directory management

#variable parameters
declare -g root
declare utility="./aux0.sh"

function set_root {
   root="./$1/result"
}

function set_paths
{
    set_root $1
}

function search
{
    local place=$1
    local item=$2

    tree "${place}" -i -f | 
    while read -r line; do
          if [[ "${line}" == *"${item}"* ]]; then
             return 0   
          fi
    done
    return 1
}

function check_folder {   

    search "." $1 || mkdir $1
}

function create_folders
{
    local path1="" 
    local path2=""

    set_paths $1
    check_folder "result"
}

function delete_folders
{
    set_root $1
    rm -r "${root}"
}

function file_cleaning
{
    set_root $1
    tree "${root}" -i -f | 
    while read -r line; do 
      if [[ "${line}" == *".txt" ]]; then
         rm -r "${line}"
      fi
    done

}

#create_folders main_folder
#delete_folders main_folder
#files_cleaning main_folder
#test_start main_folder

shopt -s lastpipe
"$@"

