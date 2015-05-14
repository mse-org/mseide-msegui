#!/bin/sh
DESTDIR=/home/mse/proj/mseguidist/bin
MSELINUXDIR=/home/mse/packs/standard/git
MSEWINDOWSDIR=/windows/F/git
MSELINUX64DIR=/opensuse_64/home/mse/packs/standard/git
MSEBSDDIR=/freebsd/home/mse/packs/standard/git
sudo mount -t ufs -o ufstype=ufs2,ro /dev/sda2 /freebsd

set -e

#exeext, sourcedir, destdir
docopy(){
echo DEST: $3
 TMP=$2/mseide-msegui/apps/ide/mseide$1
 echo " Copying $TMP"
 cp $TMP ${DESTDIR}/$3
 TMP=$2/mseuniverse/tools/msespice/msespice$1
 echo " Copying $TMP"
 cp $TMP ${DESTDIR}/$3
 TMP=$2/mseuniverse/tools/msegit/msegit$1
 echo " Copying $TMP"
 cp $TMP ${DESTDIR}/$3
 TMP=$2/mseuniverse/tools/mserun/mserun$1
 echo " Copying $TMP"
 cp $TMP ${DESTDIR}/$3
}

docopy "" ${MSELINUXDIR} i386-linux
docopy "" ${MSELINUX64DIR} x86_64-linux
docopy "" ${MSEBSDDIR} x86_64-bsd
docopy ".exe" ${MSEWINDOWSDIR} i386-win32