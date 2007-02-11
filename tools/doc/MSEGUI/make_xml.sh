#!/bin/sh

this_dir=`pwd`

cpu=`ppc386 -l | head -1 | awk '{ print $NF }'`
os=`uname | tr "LW" "lw"`
arch="${cpu}-${os}"

#fpc_ver=`fpc -l | head -1 | awk '{ print $5; }'`

this_dir=`pwd`

# reading the settings
source ../ini/fplib_doc.ini
source ../ini/msegui_doc.ini

[ -d $msegui_doc_root ] || mkdir -p -- $msegui_doc_root || exit
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
#--------------
function do_it () {
# $1 : source unit dirs list
# $2 : subdirectory in the source root dir
# $3 : include dirs
# $4 : defines 

  local inc_dirs1; local dir; local tmp; local out_dir; local pkg_name; local src_dir; local xml_dir;
  
  [ -d $msegui_doc_root/xml/$2 ] || mkdir -p -- $msegui_doc_root/xml/$2
  cp -f -- $this_dir/../xml_templates/msegui_${2}.xml $msegui_doc_root/xml/$2

  for dir in $1; do
#   where to put output XML files
    xml_dir=`echo $dir | awk -v R1="${msegui_src_dir}/" -v R2="$msegui_doc_root/xml/" '{ gsub(R1,R2,$0); print $0; }'`
    
#   recreating the XML dir to empty its contents
    rm -rf -- $xml_dir
    mkdir -p -- $xml_dir || exit 0
    
    inc_dirs1="-Fi./ -Fi${dir} $3"
    tmp=`echo -e $dir | awk -v R=${msegui_src_dir}/$2/ '{ gsub(R,"",$0); print $0; }'`
#   package name may not contain "-" & "+"   
    pkg_name=`echo -e $tmp | tr "+\/-" "_"`

#   the only way to correctly process "../*" path references in the source files
    cd $dir || exit
    echo -e "\nEntering ${dir}..."

    one_dir $xml_dir $pkg_name "$3 $4"

  done
}

#---------- MSEGUI Lib ----------------------------------------

for subdir in $msegui_dirs; do

  cur_dir=$msegui_src_dir/$subdir
  [ -d $cur_dir ] || continue
  
# obtaining the list of directories with msegui source files
  for f in `find $cur_dir/ -iregex '.*\.\(pas\|pp\)'`; do
    tmp=`dirname $f`   
    [ -d $tmp ] && echo -e $tmp; 
  done | sort -ru | sed '/\(regcomponents\|designutils\)/d' > ~/mseguidoc_xml.dirs;
  cur_dirs=
  for dir1 in `cat ~/mseguidoc_xml.dirs`; do
    cur_dirs="$cur_dirs $dir1"
  done
  rm -f -- ~/mseguidoc_xml.dirs

# obtaining the list of directories with msegui include files
  for i in `find $cur_dir/ -iname *.inc`; do
    tmp=`dirname $i` 
    [ -d $tmp ] && echo -e "-Fi$tmp"; 
  done | sort -u | sed '/\(regcomponents\|designutils\)/d' > ~/mseguidoc_xml.inc;
# forming input arguments string for makeskel 
  inc_dirs=""
  for inc_dir1 in `cat ~/mseguidoc_xml.inc`; do
    inc_dirs="$inc_dirs $inc_dir1"
  done
#  rm -f -- ~/mseguidoc_xml.inc

  defs=""
  for def in $msegui_defines; do
    defs="${defs} -d${def}"
  done

  do_it "$cur_dirs" $subdir "$inc_dirs" "$defs"
  
done

cd $this_dir

exit 0


