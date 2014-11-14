#!/bin/sh
# parameters:
#1       2         3           4           5            [6]
#HOSTIP, REMOTEIP, REMOTEPORT, REMOTEUSER, TARGETPATH --wait
#
if [[ $6 == "--wait" ]]
then
ssh $4@$2 gdbserver $1:$3 $5 &
echo Please press return key
read
else
ssh $4@$2 gdbserver $1:$3 $5 >/dev/null 2>&1 &
sleep 1 #todo: why is this necessary, remove it, use MSEide delay only
#ssh $4@$2 nohup gdbserver $1:$3 $5 >/dev/null 2>&1 & 
fi