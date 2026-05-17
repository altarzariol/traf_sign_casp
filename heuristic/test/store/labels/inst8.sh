#!/bin/bash
#!/bin/bash

declare pack_test="heu_volume"
declare label="anonymous"
declare prefix="print"
declare tail="${prefix}1.sh"
declare utility="./aux0.sh"

function move
{
     cp -r "./${pack_test}/${prefix}"*.sh "."
}

function delete
{
    echo -e "\rDo you want to remove these files?[y/n]\c"
    bash "${utility}" general_answer && rm -r "./${prefix}"*.sh
}

function execute
{   
    export label
    bash "./${tail}"
}

"$@"

shopt -s lastpipe