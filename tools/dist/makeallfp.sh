#!/bin/sh
BASEDIR=/home/mse/packs/standard/svn/fp/
FPCDIR=/fixes_2_6
INSTALLDIR=$BASEDIR/install
PWDBEFORE=$PWD
cd  $BASEDIR/$FPCDIR
make clean all install INSTALL_PREFIX=$INSTALLDIR
cd $PWDBEFORE
