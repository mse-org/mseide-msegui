#!/bin/sh
# parameters:
#1       2         3           4           5                 6              7         
#HOSTIP, REMOTEIP, REMOTEPORT, REMOTEUSER, TARGETXAUTHORITY, TARGETDISPLAY, TARGETPATH
ssh $4@$2 gdbserver --wrapper env XAUTHORITY=$5 DISPLAY=$6 -- $1:$3 $7