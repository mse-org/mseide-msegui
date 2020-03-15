#!/bin/sh

# Assumes that "/usr/local/bin" contains symlinks to:
# {$mse_dir}/tools/form2pas (shouldn't be renamed!)
# {$mse_dir}/tools/msedirclear.sh (this script)

[ -z $1 ] && {
  echo "A directory must be supplied!"
  exit -1
}

[ -d $1 ] || {
  echo "$1 must be an existing directory!"
  exit -1
}

DIRS=`for d in \`find $1 -iregex '.*\.\(ppu\|o\|a\|mfm\)' 2>/dev/null\`;
do
  tmp=\`dirname $d\`
  [ -d $tmp ] && echo -e $tmp
done | sort -ru`

CURDIR=`pwd`

for d in $DIRS; do
  cd $CURDIR && cd $d 2>/dev/null && {
    rm -f -- *.a *.o *.ppu *.A *.O *.PPU
    for f in `ls -A1 *.mfm *.MFM 2>/dev/null`; do
      [ -f $f ] && form2pas $f
    done
  }
done

cd $CURDIR
exit 0
