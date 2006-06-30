#!/bin/sh


function put_file () {
# $1 : updated XML file
# $2 : XML dir 
  local exref; local out_dir;

  [ -f $2/$1 ] && cp -vf -- $fpdocs_from_svn/$1 $2

# copy the expamle files as well
  for exref in `cat $fpdocs_from_svn/$1 | egrep -e "<example file=\"" | sed 's/^.*=\"//' | sed 's/" *\/>//' | tr -d "\r"`; do
    out_dir=`dirname $exref`
    [ -d $2/$out_dir ] || mkdir -p -- $2/$out_dir
    cp -v $fpdocs_from_svn/${exref}.pas $2/$out_dir 2>/dev/null
    cp -v $fpdocs_from_svn/${exref}.pp $2/$out_dir 2>/dev/null
  done
}

cpu=`ppc386 -l | head -1 | awk '{ print $NF }'`
os=`uname | tr "LW" "lw"`

subos=
[ $os == "linux" ] && subos="unix"
[ $os == "win32" ] && subos="win32"
[ $os == "windows" ] && subos="win32"

#fpc_ver=`fpc -l | head -1 | awk '{ print $5; }'`

this_dir=`pwd`

# reading the settings
source ../ini/fplib_doc.ini

[ -d ${fpc_doc_root}/xml ] || {
  echo -e "\n\aThe FPC help directory of XML skeletons supplied ( $fpc_doc_root ) doesn't exist. So, exiting..."
  exit
}

[ -d $fpdocs_from_svn ] || {
  echo -e "\n\aThe FPC directory of XML updates supplied ( $fpdocs_from_svn ) doesn't exist. So, exiting..."
  exit
}

cd ${fpc_doc_root}/xml || exit

put_file fcl.xml fcl

put_file contnrs.xml fcl/inc
put_file dbugintf.xml fcl/inc
put_file iostream.xml fcl/inc
put_file pipes.xml fcl/inc
put_file process.xml fcl/inc
put_file streamio.xml fcl/inc

put_file rtl.xml rtl

put_file dynlibs.xml rtl/inc/
put_file getopts.xml rtl/inc/
put_file heaptrc.xml rtl/inc/
put_file matrix.xml rtl/inc/
put_file objects.xml rtl/inc/
put_file strings.xml rtl/inc/

put_file dateutils.xml rtl/objpas
put_file math.xml rtl/objpas
put_file objpas.xml rtl/objpas
put_file strutils.xml rtl/objpas
put_file typinfo.xml rtl/objpas

put_file system.xml rtl/$os
put_file gpm.xml rtl/$os

put_file baseunix.xml rtl/$subos
put_file classes.xml rtl/$subos
put_file crt.xml rtl/$subos
put_file dos.xml rtl/$subos
put_file ipc.xml rtl/$subos
put_file keyboard.xml rtl/$subos
put_file linux.xml rtl/$subos
put_file mouse.xml rtl/$subos
put_file oldlinux.xml rtl/$subos
put_file ports.xml rtl/$subos
put_file printer.xml rtl/$subos
put_file sockets.xml rtl/$subos
put_file sysutils.xml rtl/$subos
put_file unixtype.xml rtl/$subos
put_file unixutil.xml rtl/$subos
put_file unix.xml rtl/$subos
put_file video.xml rtl/$subos
put_file x86.xml rtl/$subos

put_file mmx.xml rtl/$cpu

put_file graph.xml packages/base/graph/$subos

cd $this_dir
exit 0



