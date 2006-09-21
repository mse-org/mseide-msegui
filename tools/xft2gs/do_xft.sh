#!/bin/sh

SHORTPATHS=1
AUTOSHORTGS=1
PSF_ONLYALIASES=1
TTF_ONLYALIASES=0

LANG_NAME=`basename $LANG .$(locale charmap) | sed -e s/_.*//`

function prefer_list {
cat /etc/fonts/fonts.conf | \
  egrep -v -e "^[ \t]*$" | sed -e "s/^[ \t]\+//g" | sed -e "s/[ \t]\+$//g" | \
  egrep -e "<prefer>" -B 1 -A 25 | \
  egrep "<family>$1</family>" -A 25 | \
  egrep -e "</alias>" -B 25 | \
  egrep -v "</*alias>|</*prefer>" | sed -e "s/<\/*family>//g" | sed 1d > /tmp/$1-pref.txt
}

[ -f /tmp/Fontmap.GS-1 ] && rm -f -- /tmp/Fontmap.GS-1
[ -f /tmp/Fontmap.GS-2 ] && rm -f -- /tmp/Fontmap.GS-2
[ -f /tmp/serif-pref.txt  ] && rm -f -- /tmp/serif-pref.txt
[ -f /tmp/sans-serif-pref.txt  ] && rm -f -- /tmp/sans-serif-pref.txt
[ -f /tmp/monospace-pref.txt ] && rm -f -- /tmp/monospace-pref.txt
[ -f /tmp/fc-list.txt ] && rm -f -- /tmp/fc-list.txt

prefer_list serif
prefer_list sans-serif
prefer_list monospace

fc-list :lang=: file family slant weight > /tmp/fc-list.txt
fc-list :lang=$LANG_NAME file family slant weight >> /tmp/fc-list.txt

cat /tmp/fc-list.txt | egrep -v "^[ \t]*$" | awk \
  -v OPT1=$SHORTPATHS \
  -v OPT2=$AUTOSHORTGS \
  -v OPT3=$PSF_ONLYALIASES \
  -v OPT4=$TTF_ONLYALIASES 'BEGIN {
  sans_n=0;
  delete SANS;
  while (getline SANS[++sans_n] < "/tmp/sans-serif-pref.txt") {;}
  SANS1=sans_n; 
  sans_styles_n=0;
  delete SANS_STYLES;
  delete SANS_TYPES;
  
  serif_n=0;
  delete SERIF;
  while (getline SERIF[++serif_n] < "/tmp/serif-pref.txt") {;}
  SERIF1=serif_n;
  serif_styles_n=0; 
  delete SERIF_STYLES;
  delete SERIF_TYPES;
  
  mono_n=0;
  delete MONO;
  while (getline MONO[++mono_n] < "/tmp/monospace-pref.txt") {;}
  MONO1=mono_n; 
  mono_styles_n=0;
  delete MONO_STYLES;
  delete MONO_TYPES;
  
  print "" > "/tmp/Fontmap.GS-2";
} {
  n1=split($0,A,":");

  gsub("^[ ]+|[ ]+$","",A[1]);
  gsub("^[ ]+|[ ]+$","",A[2]);
  gsub("^[ ]+|[ ]+$","",A[3]);
  gsub("^[ ]+|[ ]+$","",A[4]);  

  style="";
# weight :
#
# 50 = Light
# 75 = Book
# 80,100 = Regular,Normal,Medium
# 180 = Demi
# 200 = Bold
#
  gsub("weight=","",A[4]);
  if ( (A[4]+0) > 170) { style="Bold"; }

# slant :
#
# 100 = Italic
# 110 = Oblique  
#
  gsub("slant=","",A[3]);
  if ( (A[3]+0) > 90 ) {
    if ( style != "" ) {
      style=style" Italic";
    } else {
      style="Italic";
    }
  }
  
  famname= A[2];

  fstyle= style;
  fstyle1= style;
   
  gsub(" ","",fstyle);
  if (fstyle != "") { fstyle="-"fstyle; }
  if (fstyle1 != "") { fstyle1=" "fstyle1; }
  
  gsub(" ","-",style);
  if ( style != "" ) { style="-"style; }
  gsub("--","-",style);  

  if (( OPT1 == 1 ) || (( OPT2 == 1 ) && ( A[1] ~ /\/gsfonts|defoma|cups|ghostscript\//) ) ) 
  {
    n2= split(A[1],B,"/");
    A[1]=B[n2];
  } 
  
  ft="";  
  if ( A[1] ~ /\.(ttf|TTF)$/) {
    ft="TTF-";
  } else if ( A[1] ~ /\.(pf(a|b))|(PF(A|B))$/ ) {
    ft="PSF-"; 
  } else if ( A[1] ~ /\.(gsf|GSF)$/ ) {
    ft="GSF-"; 
  }
    
# B[n2] - short file name
# A[2] - concatenated family name  
# fam - original family name
# style - concatenated style c "-"
  
  for (i=1; i<= sans_n; i++) {
#-- Font name match -----        
    if (SANS[i] == A[2] ) {
#---- at higher priority ---            
      if (i < SANS1) {
#------ set the new priority as current ---      
        SANS1=i;
#------ restart the style info for the font
#------ with the higher priority
	sans_styles_n= 0;
	delete SANS_STYLES;
	delete SANS_TYPES;
        SANS_STYLES[++sans_styles_n]=style;
        SANS_TYPES[sans_styles_n]=ft;
#------ continue on the current priority
      } else if (i == SANS1)  {
        SANS_STYLES[++sans_styles_n]=style;
        SANS_TYPES[sans_styles_n]=ft;
      }
    } 
  }

  for (i=1; i <= serif_n; i++) {
    if (SERIF[i] == A[2] ) {
      if (i < SERIF1) {
        SERIF1=i;
	serif_styles_n= 0;
	delete SERIF_STYLES;
	delete SERIF_TYPES;
        SERIF_STYLES[++serif_styles_n]=style;
        SERIF_TYPES[serif_styles_n]=ft;
      } else if (i == SERIF1) { 
	SERIF_STYLES[++serif_styles_n]=style;
	SERIF_TYPES[serif_styles_n]=ft;
      }
    } 
  }

  for (i=1; i <= mono_n; i++) {
  
    if (MONO[i] == A[2] ) {
      if (i < MONO1) {
        MONO1=i;
	mono_styles_n= 0;
	delete MONO_STYLES;
	delete MONO_TYPES;
        MONO_STYLES[++mono_styles_n]=style;
        MONO_TYPES[mono_styles_n]=ft;
      } else if (i == MONO1) { 
	MONO_STYLES[++mono_styles_n]=style;
	MONO_TYPES[mono_styles_n]=ft;
      }
    } 
  }
 
  gsub(" ","-",A[2]);
  if ((( OPT3 != 1 ) && ((ft == "PSF-") || (ft == "GSF-"))) || (( OPT4 != 1 ) && (ft == "TTF-"))) {
    print "/"ft""A[2]""style"\t("A[1]")\t;"; 
    print "("famname""fstyle")\t/"ft""A[2]""style"\t;" >> "/tmp/Fontmap.GS-2";
  }
  
} END {
  print "" > "/tmp/Fontmap.GS-1";
  
  for (i=1; i <= sans_styles_n; i++) {
    SANS_TYPE=""
    if ((( OPT3 != 1 ) && ((SANS_TYPES[i] == "PSF-") || (SANS_TYPES[i] == "GSF-"))) || (( OPT4 != 1 ) && (SANS_TYPES[i] == "TTF-"))) {
      SANS_TYPE=SANS_TYPES[i]; 
    }
    SANS_STYLE=SANS_STYLES[i];
    if ( SANS_STYLE != "" ) {
      gsub("-","",SANS_STYLE);
      SANS_STYLE="-"SANS_STYLE;
    }
    gsub(" ","-",SANS[SANS1]);
    print "/Sans"SANS_STYLE"\t/"SANS_TYPE""SANS[SANS1]""SANS_STYLES[i]"\t;" >> "/tmp/Fontmap.GS-1";
    print "/Helvetica"SANS_STYLE"\t/"SANS_TYPE""SANS[SANS1]""SANS_STYLES[i]"\t;" >> "/tmp/Fontmap.GS-1";    
  }

  for (i=1; i <= serif_styles_n; i++) {
    SERIF_TYPE=""
    if ((( OPT3 != 1 ) && ((SERIF_TYPES[i] == "PSF-") || (SERIF_TYPES[i] == "GSF-"))) || (( OPT4 != 1 ) && (SERIF_TYPES[i] == "TTF-"))) {
      SERIF_TYPE=SERIF_TYPES[i]; 
    }
    SERIF_STYLE=SERIF_STYLES[i];
    if ( SERIF_STYLE != "" ) {
      gsub("-","",SERIF_STYLE);
      SERIF_STYLE="-"SERIF_STYLE;
    }
    gsub(" ","-",SERIF[SERIF1]);
    print "/Serif"SERIF_STYLE"\t/"SERIF_TYPE""SERIF[SERIF1]""SERIF_STYLES[i]"\t;" >> "/tmp/Fontmap.GS-1";
    print "/Times"SERIF_STYLE"\t/"SERIF_TYPE""SERIF[SERIF1]""SERIF_STYLES[i]"\t;" >> "/tmp/Fontmap.GS-1";
  }

  for (i=1; i <= mono_styles_n; i++) {
    MONO_TYPE=""
    if ((( OPT3 != 1 ) && ((MONO_TYPES[i] == "PSF-") || (MONO_TYPES[i] == "GSF-"))) || (( OPT4 != 1 ) && (MONO_TYPES[i] == "TTF-"))) {
      MONO_TYPE=MONO_TYPES[i]; 
    }
    MONO_STYLE=MONO_STYLES[i];
    if ( MONO_STYLE != "" ) {
      gsub("-","",MONO_STYLE);
      MONO_STYLE="-"MONO_STYLE;
    }
    gsub(" ","-",MONO[MONO1]);
    print "/Mono"MONO_STYLE"\t/"MONO_TYPE""MONO[MONO1]""MONO_STYLES[i]"\t;" >> "/tmp/Fontmap.GS-1";
    print "/Fixed"MONO_STYLE"\t/"MONO_TYPE""MONO[MONO1]""MONO_STYLES[i]"\t;" >> "/tmp/Fontmap.GS-1";
    print "/Courier"MONO_STYLE"\t/"MONO_TYPE""MONO[MONO1]""MONO_STYLES[i]"\t;" >> "/tmp/Fontmap.GS-1";    
  }

}' | sort -u > ./Fontmap.GS.xft

cat /tmp/Fontmap.GS-2 | sort -u >> ./Fontmap.GS.xft
cat /tmp/Fontmap.GS-1 | sort -u >> ./Fontmap.GS.xft

rm -f -- \
  /tmp/Fontmap.GS-1 \
  /tmp/Fontmap.GS-2 \
  /tmp/serif-pref.txt \
  /tmp/sans-serif-pref.txt \
  /tmp/monospace-pref.txt \
  /tmp/fc-list.txt


exit 0
