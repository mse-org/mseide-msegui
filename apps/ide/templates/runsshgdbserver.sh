#!/bin/sh
# parameters:
#1       2         3           4           5            [6]
#HOSTIP, REMOTEIP, REMOTEPORT, REMOTEUSER, TARGETPATH --wait
#
ssh $4@$2 gdbserver $1:$3 $5 &
if [[ $6=="--wait" ]]
then
echo Please press return key
read
fi

