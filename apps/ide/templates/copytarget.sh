#!/bin/sh
# parameters:
#1       2     [3]
#SOURCE, DEST, --wait
#
if cp $1 $2
then
 if [[ $3 == "--wait" ]]
 then
 echo Please press return key
 read
 fi
else
 echo Please press return key
 read
fi
read