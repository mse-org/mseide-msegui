#!/bin/sh
# parameters:
#1       2     [3]
#SOURCE, DEST, --wait
#
cp $1 $2
if [[ $3=="--wait" ]]
then
echo Please press return key
read
fi

