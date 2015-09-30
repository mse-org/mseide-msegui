#!/bin/sh
MSERUN=/home/mse/packs/standard/git/mseuniverse/tools/mserun/mserun
FPCINSTDIR=/home/mse/packs/standard/svn/fp/builds/fixes_3_0/
#
#FPCUNITDIR=lib/fpc/3.0.1/units/x86_64-linux
#COMPILERBIN=lib/fpc/3.0.1/ppcx64
#OPT="-Fl/usr/local/lib"
FPCUNITDIR=lib/fpc/3.0.1/units/i386-linux
COMPILERBIN=lib/fpc/3.0.1/ppc386
OPT="-Fl/usr/local/lib"
#
TARGET=linux
MSEBASEDIR=/home/mse/packs/standard/git/
echo $OPT
$MSERUN --macrodef=FPCINSTDIR,$FPCINSTDIR --macrodef=COMPILERBIN,$COMPILERBIN --macrodef=MSEBASEDIR,$MSEBASEDIR --macrodef=FPCUNITDIR,$FPCUNITDIR --macrodef=TARGET,$TARGET "--macrodef=OPT,$OPT" makdist.mrp
