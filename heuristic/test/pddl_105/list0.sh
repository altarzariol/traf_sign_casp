#!/bin/bash

tree -i -f | while read -r line; do if [[ "${line}" == *$1* ]]; then echo $line; fi; done
