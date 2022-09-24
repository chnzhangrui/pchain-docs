#!/bin/bash

tar xvf *tar
nloop=4

if [[ $1 -ge $nloop ]]; then
    to_continue='false'
else
    to_continue='true'
fi

python /ATLASMLHPO/module/active_learning_zz.py -s parameter_space.json -l limit_stage/output.json -pv myparamMZD $3 myparamMHD $4 -c $to_continue;
