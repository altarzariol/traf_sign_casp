#!/bin/bash

echo "${pippo}"

function func() for i in {1..2}; do echo "ciao"; done

function print
{
    echo $1
}


declare f="func"
$f

print $((1+3))

