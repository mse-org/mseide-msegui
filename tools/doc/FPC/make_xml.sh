#!/bin/sh

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

[ -d $fpc_doc_root ] || mkdir -p -- $fpc_doc_root || exit
#*******************************************************************************************
function one_dir () {
# $1 : output directory for XML-files
# $2 : package name to write in XML-files
# $3 : -Fi<include_dir>-s & -d<define>-s 

  local in_file; local out_file;

  for in_file in `ls -A1 *.pas *.pp 2>/dev/null`; do
    cat ./$in_file | head -40 | egrep -ie "^[ \t]*program[[:space:]]+[[:alpha:]]+[_[:alnum:]]*[[:space:]]*;" >/dev/null && continue  
    out_file=$1"/"`echo $in_file | sed "s/\.\(pas\|pp\)$/\.xml/"`
    echo "  ${in_file} -> ${out_file}"
    [ -f $out_file ] || rm -f -- $out_file

    if ! makeskel --package=$2 --input=./${in_file}" $3" --output=${out_file} --disable-private --disable-protected; then
      rm -f -- ${out_file}
    fi

  done
}
#---------- RTL start ----------------------------------------
ref=
defs=
inc_dirs=
xml_descr=
#--------------
function do_it () {
  local inc_dirs1;

# if docs dir does not exist then to create it  
  xml_dir="${fpc_doc_root}/xml/$ref"
  rm -rf -- $xml_dir
  mkdir -p -- $xml_dir || exit 0
  cp -f -- $this_dir/../xml_templates/${xml_descr}.xml $xml_dir/

  for dir in $1; do
    src_dir=${fpc_src_dir}/$ref/${dir}
    inc_dirs1="-Fi./ -Fi${src_dir} ${inc_dirs}"
    tmp=`echo -e $dir | awk -v R=$fpc_src_dir/ '{ gsub(R,"",$0); print $0; }'`
    out_dir="${xml_dir}/${tmp}"
#   package name may not contain "-"    
    pkg_name=`echo -e $tmp | tr "+\/-" "_"`
    mkdir -p -- $out_dir

#   the only way to correctly process "../*" path references in the source files
    cd $src_dir || exit
    echo -e "\nEntering ${src_dir}..."
    one_dir $out_dir $pkg_name "$inc_dirs1 $defs"
  done
}

#---------- RTL ----------------------------------------
function do_rtl () {
  ref="rtl"
  xml_descr="rtl"

  for id in $rtl_inc_dirs; do
    inc_dirs="${inc_dirs} -Fi${fpc_src_dir}/$ref/${id}"
  done

  for def in $rtl_defines; do
    defs="${defs} -d${def}"
  done

  do_it "$rtl_dirs"
}
#---------- FCL ----------------------------------------
function do_fcl () {
  ref="fcl"
  xml_descr="fcl"
  defs=
  inc_dirs=

  for id in $fcl_inc_dirs; do
    inc_dirs="${inc_dirs} -Fi${fpc_src_dir}/$ref/${id}"
  done

  for def in $fcl_defines; do
    defs="${defs} -d${def}"
  done

  do_it "$fcl_dirs"
}
#---------- BASE PKG ----------------------------------------
function do_base_pkg () {
  ref="packages/base"
  xml_descr="packages_base"
  defs=
  inc_dirs=

  for id in $base_pkg_inc_dirs; do
    inc_dirs="${inc_dirs} -Fi${fpc_src_dir}/$ref/${id}"
  done

  for def in $base_pkg_defines; do
    defs="${defs} -d${def}"
  done

  do_it "$base_pkg_dirs"
}
#---------- EXTRA PKG ----------------------------------------
function do_extra_pkg () {
  ref="packages/extra"
  xml_descr="packages_extra"
  defs=
  inc_dirs=

  for id in $extra_pkg_inc_dirs; do
    inc_dirs="${inc_dirs} -Fi${fpc_src_dir}/$ref/${id}"
  done

  for def in $extra_pkg_defines; do
    defs="${defs} -d${def}"
  done

  do_it "$extra_pkg_dirs"
}
#--------------------------------------------------
do_rtl;
do_fcl;

# Uncomment the below lines to make XML skeletons for the FPC packages as well
#
#do_base_pkg;
#do_extra_pkg;

cd $this_dir; exit 0
