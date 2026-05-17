#!/bin/bash

function check_file
{

    tail -n +2 "${record}" | 
    while IFS=',' read -r name lb dot dotunknown; do
          if [[ "${name}" == "${tag_}" && "${label}" == "${lb}" ]]; then
             return 0
          fi
    done
    return 1
}

function add_file
{
    local csv_dot=$1
    local label=$2

    check_file || echo "${tag_},${label},${csv_dot},${dotunkw_inst}" >> "${record}"
}

shopt -s lastpipe
"$@"