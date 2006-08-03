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

[ -d $fpc_doc_root ] || {
  echo -e "Directory $fpc_doc_root does not exist but should be created by a make_xml.sh. So, exiting..."
  exit
}

InputFileList=inputfile.txt
DescrFileList=descrfile.txt

function do_it () {
# $1 = $ref
# $2 = PkgName
# $3 = inc_dirs
# $4 = defines
# $5 = external imports

  local inc_dirs; local defs; local imports;
  local src_dir; local xml_dir; local html_dir;
  local DescrFiles; local UnitListPp; local UnitListPas; local UnitList;
  local CurInputFileList; local CurDescrFileList;
  local unit_file; local pas_file; local pp_file; local cur_dir_inc;

  src_dir="$fpc_src_dir/$1"
  xml_dir=${fpc_doc_root}/xml/$1
  [ -d $xml_dir ] || {
    echo -e "Directory $xml_dir does not exist. So, skipping..."
    return
  }
  html_dir=${fpc_doc_root}/html/$1
  
# recreating the HTML dir to empty its contents
  rm -rf -- $html_dir
  mkdir -p -- $html_dir || exit 0
# cp -f -- $this_dir/../xml_templates/$2.xml.start $xml_dir/$2.xml

# create description file list
  DescrFiles=`find $xml_dir -name *.xml`

# create unit file list
  UnitListPp=`find  $src_dir -name *.pp`
  UnitListPas=`find $src_dir -name *.pas`
  UnitList=`echo -e $UnitListPp" "$UnitListPas | sort -ru`

  inc_dirs=
  for id in $3; do
    inc_dirs="${inc_dirs} -Fi${fpc_src_dir}/$1/${id}"
  done

  defs=
  for def in $4; do
    defs="${defs} -d${def}"
  done

  imports=
  for imp in $5; do
    imports="${imports} --import=${imp}"
  done

# [re]create input file list
  CurInputFileList=$html_dir/$InputFileList
  [ -f $CurInputFileList ] && rm -f $CurInputFileList

# [re]create description file list
  CurDescrFileList=$html_dir/$DescrFileList
  [ -f $CurDescrFileList ] && rm -f $CurDescrFileList

  for descr in $DescrFiles; do
    echo $descr >> $CurDescrFileList  

#   only existing XMLs -> *.(pas|pp)   
    unit_file=`echo $descr | awk -v R1="${fpc_doc_root}/xml/" -v R2="$fpc_src_dir/" '{ gsub(R1,R2,$0); print $0; }' | sed 's/.\xml//g'`
  
    pas_file="${unit_file}.pas"
    if [ -f $pas_file ]; then
      cur_dir_inc="-Fi"`dirname $pas_file`
      echo $pas_file $cur_dir_inc "$inc_dirs" >> $CurInputFileList  
    fi
  
    pp_file="${unit_file}.pp"
    if [ -f $pp_file ]; then
      cur_dir_inc="-Fi"`dirname $pp_file`
      echo $pp_file $cur_dir_inc "$inc_dirs" >> $CurInputFileList  
    fi

  done

  FPDocParams="--content=${fpc_doc_root}/html/$1/$2.xct --package=$2 --descr=$xml_dir/$2.xml --format=html $imports"

  cd $html_dir
  fpdoc --descr=@$DescrFileList --input=@$InputFileList $FPDocParams
  rm -f -- $CurInputFileList $CurDescrFileList $html_dir/$2.xml
}

# ========== RTL ==============
do_it "rtl" "rtl" "$rtl_inc_dirs" "$rtl_defines"
do_it "fcl" "fcl" "$fcl_inc_dirs" "$fcl_defines" "$fcl_imports"

# Uncomment the below lines to make HTML docs for the FPC packages as well - It may take a long !
#
#do_it "packages/base" "packages_base" "$base_pkg_inc_dirs" "$base_pkg_defines"
#do_it "packages/extra" "packages_extra" "$extra_pkg_inc_dirs" "$extra_pkg_defines"

cd $this_dir
#===============================

exit 0

