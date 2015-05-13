#!/bin/sh
MSERUN=/home/mse/packs/standard/git/mseuniverse/tools/mserun/mserun
FPCINSTDIR=/home/mse/packs/standard/svn/fp/install/
COMPILERBIN=ppc386
MSEBASEDIR=/home/mse/packs/standard/git/
$MSERUN --macrodef=FPCINSTDIR,$FPCINSTDIR --macrodef=COMPILERBIN,$COMPILERBIN --macrodef=MSEBASEDIR,$MSEBASEDIR
