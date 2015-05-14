#!/bin/sh
MSERUN=/home/mse/packs/standard/git/mseuniverse/tools/mserun/mserun
FPCINSTDIR=/home/mse/packs/standard/svn/fp/install/
#
#FPCUNITDIR=lib/fpc/2.6.5/units/x86_64-linux
#COMPILERBIN=lib/fpc/2.6.5/ppcx64
#OPT="-X- -Xs"
FPCUNITDIR=lib/fpc/2.6.5/units/i386-linux
COMPILERBIN=lib/fpc/2.6.5/ppc386
OPT=
#
TARGET=linux
MSEBASEDIR=/home/mse/packs/standard/git/
echo $OPT
$MSERUN --macrodef=FPCINSTDIR,$FPCINSTDIR --macrodef=COMPILERBIN,$COMPILERBIN --macrodef=MSEBASEDIR,$MSEBASEDIR --macrodef=FPCUNITDIR,$FPCUNITDIR --macrodef=TARGET,$TARGET "--macrodef=OPT,$OPT" makdist.mrp
