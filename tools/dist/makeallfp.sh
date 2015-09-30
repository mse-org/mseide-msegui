#!/bin/sh
BASEDIR=/home/mse/packs/standard/svn/fp/
FPCDIR=/fixes_3_0
INSTALLDIR=$BASEDIR/builds/fixes_3_0
PWDBEFORE=$PWD
cd  $BASEDIR/$FPCDIR
make clean all install INSTALL_PREFIX=$INSTALLDIR
cd $PWDBEFORE
