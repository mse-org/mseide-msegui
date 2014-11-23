#!/bin/sh
# parameters:
#1       2         3           4           5          6           7            
#HOSTIP, REMOTEIP, REMOTEPORT, REMOTEUSER, TARGETENV, TARGETPATH, TARGETPARAMS,
if ! ssh -t $4@$2 gdbserver --wrapper env $5 -- $1:$3 $6 $7 ; then
 echo Please press enter
 read
fi