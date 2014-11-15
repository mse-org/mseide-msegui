#!/bin/sh
# parameters:
#1       2         3           4           5                 6              7          [8]
#HOSTIP, REMOTEIP, REMOTEPORT, REMOTEUSER, TARGETXAUTHORITY, TARGETDISPLAY, TARGETPATH --wait
#
#RUNGDBSERVER= ssh $4@$2 gdbserver --wrapper env XAUTHORITY=/home/pi/.Xauthority DISPLAY=:0.0 -- $1:$3 $5
#RUNGDBSERVER1= ${RUNGDBSERVER}
#RUNGDBSERVER2= ${RUNGDBSERVER} >/dev/null 2>&1
# does not work, & not recognized
if [[ $8 == "--wait" ]]
then
#ssh $4@$2 gdbserver --wrapper env XAUTHORITY=/home/pi/.Xauthority DISPLAY=:0.0 -- $1:$3 $5 &
ssh $4@$2 gdbserver --wrapper env XAUTHORITY=$5 DISPLAY=$6 -- $1:$3 $7 &
#${RUNGDBSERVER1} & # does not work, & not recognized
echo Please press return key
read
else
ssh $4@$2 gdbserver --wrapper env XAUTHORITY=$5 DISPLAY=$6 -- $1:$3 $7 >/dev/null 2>&1 &
#${RUNGDBSERVER2} &
sleep 1 #todo: why is this necessary, remove it, use MSEide delay only
#ssh $4@$2 nohup gdbserver $1:$3 $5 >/dev/null 2>&1 & 
fi