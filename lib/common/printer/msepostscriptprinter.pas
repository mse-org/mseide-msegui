{ MSEgui Copyright (c) 1999-2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msepostscriptprinter;
{$ifdef FPC}{$mode objfpc}{$h+}{$GOTO ON}{$endif}

interface

uses
 msegraphics,mseclasses,classes,mclasses,msegraphutils,
 msestream,msestrings,msetypes,
 msedrawtext,mserichstring,mseprinter,mseguiglob;

const
 defaultimagecachesize = 500000;
 defaultimagecachemaxitemsize = 100000;

type
 pspointty = record
              x: real;
              y: real;
             end;
 psmatrixty = array [0..2] of array [0..1] of real;

const
 psunitymatrix: psmatrixty = ((1,0),  //1 0 0
                              (0,1),  //0 1 0
                              (0,0)); //0 0 1

type                 
 tpostscriptcanvas = class;

 tpostscriptprinter = class(tstreamprinter,icanvas)
  private
   function getcanvas: tpostscriptcanvas;
   //icanvas
   procedure gcneeded(const sender: tcanvas);
   function getkind: bitmapkindty;
   procedure getcanvasimage(const bgr: boolean; var aimage: maskedimagety);
  public
   constructor create(aowner: tcomponent); override;
   property canvas: tpostscriptcanvas read getcanvas;
  published
   property options default [pro_tempfile];
 end;

 psfontinfoty = record
  handle: fontnumty;  
  namenum: integer;
  size: integer;
  scalestring1: ansistring;
  scalestringfull: ansistring;
  rotated: boolean;
  codepages: integerarty;
 end; 
 psfontinfoarty = array of psfontinfoty;

 psalignty = (pa_center,pa_lefttop,pa_top,pa_righttop,pa_right,
                pa_rightbottom,pa_bottom,pa_leftbottom,pa_left);
 pslevelty = (psl_1,psl_2,psl_3);

 imagecachekindty = (ick_1,ick_2,ick_3,ick_4);
 imagecachety = record
  source: tcanvas;
  mask: tcanvas;
  kind: imagecachekindty;
  sourcerect: rectty;
  bytecount: integer;
//  rowbytes: integer;
  statestamp: longword;
  maskstatestamp: longword;
 end;
 imagecachearty = array of imagecachety;
 
 tpostscriptcanvas = class(tstreamprintercanvas)
  private
   ffonts: psfontinfoarty;
   ffontnames: stringarty;
   fps_pagenumber: integer;
   fmapnames: array[0..255] of string;
   factfont,factcodepage: integer;
   fstarted: boolean;
   fpslevel: pslevelty;
   fimagecache: imagecachearty;
   fcacheorder: integerarty;
   fimagecacheused: integer;
   fimagecachesize: integer;
   fimagecachemaxitemsize: integer;
   procedure setimagecachesize(const avalue: integer);
   procedure setimagecachemaxitemsize(const avalue: integer);
  protected
   procedure gcdestroyed(const sender: tcanvas); override;
   procedure freeimagecache(const index: integer);
   procedure touchimagecache(const index: integer);
   function getimagecache(const akind: imagecachekindty; const asource: tcanvas;
                          const asourcerect: rectty; out varname: string{;
                          out arowbytes: integer}): boolean; 
                                       //true if found
   function setimagecache(const akind: imagecachekindty;
               const asource: tcanvas;
               const asourcerect: rectty; out varname: string;
               const bytes: bytearty; {const arowbytes: integer;}
               const amask: tcanvas = nil): boolean; 
                                       //true if stored

   function getgdifuncs: pgdifunctionaty; override;
   procedure updatescale; override;
   procedure initgcstate; override;
   procedure initgcvalues; override;
   procedure finalizegcstate; override;
   procedure checkscale;
   function encodefontname(const namenum,codepage: integer): string;
   function checkfont(const afont: fontnumty; const acodepage: integer): integer;
               //returns index in ffonts
   function getscalestring(const astyle: fontstylesty): ansistring;
   procedure selectfont(const afont: fontnumty; const acodepage: integer);
   procedure definefont(const adata: fontnumty; const acodepage: integer);
   procedure setpslinewidth(const avalue: integer);
   function strokestr: string;
   function rectscalestring(const arect: rectty): string; 
                 //transform unity cell to arect
   function imagematrixstring(const asize: sizety): string;
   
   function getcolorstring(const acolor: colorty): string;
   function setcolorstring(const acolor: colorty): string;
   procedure writebinhex(const data: bytearty);
   function psencode(const text: pchar; const count: integer): string;
   function getshowstring(const avalue: pmsechar; const count: integer;
                   fontneeded: boolean = false;
                   const acolor: colorty = cl_none;
                   const acolorbackground: colorty = cl_none;
                   const fontstyle: fontstylesty = []): string;
   function createpattern(const sourcerect,destrect: rectty; 
                   const acolorbackground,acolorforeground: colorty;
                   const acanvas: tcanvas;
//                   const pixmap: pixmapty; const agchandle: ptruint;
                   const patname: string): boolean;
              //true if ok
   procedure handlepoly(const points: ppointty; const lastpoint: integer;
                     const closed: boolean; const fill: boolean);
   procedure handleellipse(const rect: rectty; const fill: boolean);
   procedure checkcolorspace;
   procedure ps_drawstring16;
   procedure ps_drawarc;
   procedure ps_destroygc;
   procedure ps_changegc;
   procedure ps_drawlines;
   procedure ps_drawlinesegments;
   
   procedure ps_fillpolygon;
   procedure ps_fillarc;
   procedure ps_fillrect;
   procedure ps_copyarea;
   procedure textout(const text: richstringty; const dest: rectty;
                        const flags: textflagsty; const tabdist: real); override;
   procedure begintextclip(const arect: rectty); override;
   procedure endtextclip; override;
   procedure beginpage; override;
   procedure endpage; override;
   function registermap(const acodepage: integer): string;
                 //returns mapname ('E00' for latin 1)  
   procedure checkmap(const acodepage: integer);
   function gcposstring(const apos: pointty): string;
  public
   constructor create(const user: tprinter; const intf: icanvas);

   function devpos(const apos: pointty): pspointty;
   function posstring(const apos: pointty): string;  
   function matrixstring(const mat: psmatrixty): string;
   function transrotate(const sourcecenter,destcenter: pointty;
                                                const angle: real): string;  
   function diststring(const adist: integer): string;
   function rectsizestring(const asize: sizety): string;
   function sizestring(const asize: sizety): string;
   function rectstring(const arect: rectty): string;
   procedure pscommand(const atext: string); // writes atext to postscript stream
  published
   property pslevel: pslevelty read fpslevel write fpslevel default psl_3;
   property imagecachesize: integer read fimagecachesize write setimagecachesize 
                                                  default defaultimagecachesize;
   property imagecachemaxitemsize: integer read fimagecachemaxitemsize 
                                   write setimagecachemaxitemsize 
                                           default defaultimagecachemaxitemsize;
 end;
 
function psrealtostr(const avalue: real): string;
procedure pstranslate(var mat: psmatrixty; const dist: pspointty);
procedure psretranslate(var mat: psmatrixty; const dist: pspointty);
procedure psrotate(var mat: psmatrixty; const angle: real); //radiant
function pstransform(const mat: psmatrixty;
              const apoint: pspointty): pspointty; overload;
function pstransform(const mat: psmatrixty;
              const apoint: pointty): pspointty; overload;
function psdist(const source,dest: pspointty): pspointty; overload;
//function psdist(const source,dest: pointty): pspointty; overload;
function pspoint(const apoint: pointty): pspointty;
 
implementation
uses
 msegui,msesys,sysutils,msedatalist,mseformatstr,mseunicodeps,
 mseguiintf,msebits,msefloattostr,msefont,msearrayutils;
type
 tsimplebitmap1 = class(tsimplebitmap); 
 tcanvas1 = class(tcanvas);
var
 gdifuncs: pgdifunctionaty;
 
procedure pstranslate(var mat: psmatrixty; const dist: pspointty);
begin
 mat[2,0]:= mat[2,0] + dist.x;
 mat[2,1]:= mat[2,1] + dist.y;
end;

procedure psretranslate(var mat: psmatrixty; const dist: pspointty);
begin
 mat[2,0]:= mat[2,0] - dist.x;
 mat[2,1]:= mat[2,1] - dist.y;
end;

procedure psrotate(var mat: psmatrixty; const angle: real); //radiant
var
 si,co: real;
 m00,m01,m10,m11,m20,m21: real;
begin
 si:= sin(angle);
 co:= cos(angle);
 m00:= mat[0,0]*co+mat[0,1]*-si;
 m01:= mat[0,0]*si+mat[0,1]*co;
 m10:= mat[1,0]*co+mat[1,1]*-si;
 m11:= mat[1,0]*si+mat[1,1]*co;
 m20:= mat[2,0]*co+mat[2,1]*-si;
 m21:= mat[2,0]*si+mat[2,1]*co;
 mat[0,0]:= m00;
 mat[0,1]:= m01;
 mat[1,0]:= m10;
 mat[1,1]:= m11;
 mat[2,0]:= m20;
 mat[2,1]:= m21;
end;

function pstransform(const mat: psmatrixty; const apoint: pspointty): pspointty;
begin
 result.x:= mat[0,0]*apoint.x + mat[1,0]*apoint.y + mat[2,0];
 result.y:= mat[0,1]*apoint.x + mat[1,1]*apoint.y + mat[2,1];
end;

function pstransform(const mat: psmatrixty; const apoint: pointty): pspointty;
begin
 result.x:= mat[0,0]*apoint.x + mat[1,0]*apoint.y + mat[2,0];
 result.y:= mat[0,1]*apoint.x + mat[1,1]*apoint.y + mat[2,1];
end;

function psdist(const source,dest: pspointty): pspointty;
begin
 result.x:= dest.x - source.x;
 result.y:= dest.y - source.y;
end;
{
function psdist(const source,dest: pointty): pspointty;
begin
 result.x:= dest.x - source.x;
 result.y:= dest.y - source.y;
end;
}
function pspoint(const apoint: pointty): pspointty;
begin
 result.x:= apoint.x;
 result.y:= apoint.y;
end;

const
 pageorientations: array[pageorientationty] of string = ('Portrait','Landscape');
 
 imagepatname = 'impat';
 patpatname = 'pat';
 radtodeg = 360/(2*pi);
 nl = lineend;  
 maxlinecharcount = 80;
 preamble = 
'/rf {'+nl+        //register font: alias,encoding,origname->
'findfont'+nl+         //alias,encoding,font
'dup length dict '+    //alias,encoding,font,dict
'begin '+nl+           //alias,encoding,font  dict is on top of dictstack
 '{ 1 index /FID ne'+nl+  //alias,encoding,font,key,value
  '{def}'+nl+             //alias,encoding,font
  '{pop pop}'+nl+         //alias,encoding,font
  'ifelse'+nl+
 '} forall'+nl+           //alias,encoding
 '/Encoding exch def'+nl+ //alias
 'currentdict'+nl+        //alias,dict 
'end'+nl+                 //alias,dict       dict is removed from dictstack
'definefont '+            //dict 
'pop'+nl+                 //
'} bind def'+nl+
                             //                    
'/sf {'+nl+         //select font:    |-> optional
                    //[alias,scale(x),scaley,rotation,underline,stroke]->
'dup'+              //[bak],[alias,scale(x),scaley,rotation]
' length 2 ge'   +     //[bak], length >= 2
 ' {dup'+           //[bak][alias,scale(x),scaley]
 ' dup length 3 ge'+nl+ //[bak],[alias,scale(x),scaley],length >= 3
  '{1 2 getinterval aload pop}'+ //[bak],scalex,scaley
  ' {1 get dup}'+       //[bak],scale,scale
 ' ifelse'+nl+
 'matrix scale'+           //[bak],smatrix
 ' }'+
 ' {matrix}'+              //[bak],umatrix
' ifelse'+nl+

' 1 index'+         //[bak],smatrix,[alias,scale(x),scaley,rotation]
' length 4 ge'+     //[bak],smatrix, length >= 4
 ' {1 index'+        //[bak],smatrix,[alias,scale(x),scaley,rotation]
 ' 3 get'+           //[bak],smatrix,rotation
 ' matrix rotate'+   //[bak],smatrix,rmatrix
 ' matrix concatmatrix}'+
' if'+nl+   

'1 index'+             //[bak],rmatrix,[alias,scale(x),scaley,rotation,underline,stroke]
' dup length 5 ge'   + //[bak],rmatrix,
                       //[alias,scale(x),scaley,rotation,underline,stroke], length >= 5
' {dup 4 get}'+        //[bak],rmatrix,[bak],underline
' {0} ifelse'+         //[bak],rmatrix,[bak],0
' /uli exch def'+nl+
'dup length 6 ge'   + //[bak],rmatrix,[bak]
                      //[alias,scale(x),scaley,rotation,underline,stroke], length >= 6
' {5 get}'+           //[bak],rmatrix,strokeout
' {pop 0} ifelse'+    //[bak],rmatrix,0
' /sou exch def'+nl+  //

'exch '+               //matrix,[alias]
' 0 get'+              //matrix,alias
' findfont'+           //matrix,font
' exch makefont'+            //font
' dup /FontMatrix get exch'+ //matrix,font 
' dup /FontBBox get'+nl+
                       //matrix,font,bbox
'aload pop'+ //matrix,font,llx,lly,urx,ury
' 5 index'+   //matrix,font,llx,lly,urx,ury,matrix
' transform'+ //matrix,font,llx,lly,urx',ury'
' /asc exch def pop'+ //matrix,font,llx,lly
' 3 index'+   //matrix,font,llx,lly,matrix
' transform'+ //matrix,font,llx',lly'
' -1 mul'+nl+' /desc exch def pop'+ //matrix,font
' setfont pop'+nl+
'} bind def'+nl+

'/w {'+nl+    //[[text,[font],color,colorbackground],...]-> cx
              //[[text,[font],color],...]-> cx
              //[[text,[font]],...]-> cx
              //[[text],...]-> cx
              //calc stringwidth
' currentfont exch'+            //fontbak,inputarray
' 0 exch'+    //fontback,0,inputarray
' {'+         //fontback,sum,[text,[font],color,colorbackground]
 ' dup length 2 ge'+ //fontback,sum,[text,[font],color,colorbackground],length>=2
  '{ dup 1 get sf}'+nl+
 'if'+    //fontback,sum,[text,[font],color,colorbackground]
                            //set font
 ' 0 get'+              //fontback,sum,text
 ' stringwidth pop add'+//fontback,sum
' } forall'+
' exch setfont'+nl+
'} bind def'+nl+

'/s {'+nl+    //[[text,[font],color,colorbackground],...]-> cx
              //[[text,[font],color,colorbackground],...]-> cx
              //[[text,[font],color],...]-> cx
              //[[text,[font]],...]-> cx
              //[[text],...]-> cx
              //select font, print text, ...
' {'+
   ' currentpoint /ay exch def /ax exch def'+ //backup for underline
   ' dup'+
   ' dup length 3 ge'+nl+     //[bak],
                           //[text,[font],color,colorbackground],length >= 3
   '{dup 2 get'+          //[bak],
                           //[text,[font],color,colorbackground],[color]
    ' aload pop setcolor'+ //[bak],
                           //[text,[font],color,colorbackground]
    ' 0 2 getinterval'+    //[bak],
                           //[text,[font]]     remove color
   ' } if'+nl+  
  ' dup length 2 eq'+ //array,arraylength = 5
  ' {aload pop sf}'+  //[bak],text
  ' {aload pop}'+     //[bak],text
  ' ifelse '+nl+
  
  ' exch dup length 4 eq'+ //text,[bak],length = 4
  ' {'+ //text,[text,[font],color,colorbackground]
   ' [currentcolor] exch'+ //text,[colbackup],[text,[font],color,colorbackground]
   ' 3 get'+ //text,[colbackup],[colorbackground]
   ' aload pop setcolor exch'+   //[colbackup],text
   ' dup stringwidth pop'+nl+//[colbackup],text,width
   ' currentpoint currentpoint asc add'+nl+ //[colbackup],text,width,x,y,x,y+asc
   ' newpath moveto'+                    //[colbackup],text,width,x,y    
   ' 2 index 0 rlineto'+
   ' 0 0 asc sub desc sub rlineto'+
   ' 0 3 index sub 0 rlineto'+nl+
   ' closepath fill'+                    //[colbackup],text,width,x,y
   ' moveto'+                            //[colbackup],text,width 
   ' pop'+                               //[colbackup],text
   ' exch aload pop setcolor'+           //text 
   ' show'+         
  ' }'+nl+
  ' {'+    //text,[text,font,rot,scalex,scaley,color]
   ' pop'+ //text
   ' show'+
  ' }'+
  ' ifelse'+nl+
  ' uli 0 ne {ul} if'+          //underline
  ' sou 0 ne {so} if'+          //strokeout
' } forall'+nl+
'} bind def'+nl+

'/slt {'+nl+ //print lefttop text,llx,lly,urx,ury ->
' asc sub'+  //text,llx,lly,urx,ury-asc
' 3 index'+  //text,llx,lly,urx,ury-asc,llx
' exch moveto currentpoint /ay exch def /ax exch def'+ //backup for underline
             //text,llx,lly,urx
' pop pop pop s'+nl+
'} bind def'+nl+

'/cy {'+nl+      //center y text,llx,lly,urx,ury-> text,llx,lly,urx,centeredy
' 2 index sub'+  //text,llx,lly,urx,ury-lly
' dup 0 eq'+nl+  //text,llx,lly,urx,ury-lly,bool 

' {pop 1 index}'+nl+  //text,llx,lly,urx,lly

' {asc sub desc sub'+//text,llx,lly,urx,ury-lly-asc-desc
' 2 div 2 index'+//text,llx,lly,urx,ury-lly-asc-desc/2,lly
' add desc add}'+nl+ //text,llx,lly,urx,ury-lly-asc-desc/2+lly+desc

' ifelse'+
'} bind def'+nl+

'/sl {'+nl+     //print left text,llx,lly,urx,ury
' cy'+          //text,llx,lly,urx,centeredy 
' 3 index exch'+ //text,llx,lly,urx,llx,ury-lly-asc-desc/2+lly+desc
' moveto '+nl+
//' currentpoint /ay exch def /ax exch def'+ //backup for underline
                       //text,llx,lly,urx
' pop pop pop s'+nl+
'} bind def'+nl+

'/sr {'+ //print right text: text,llx,lly,urx,ury->
' cy'+          //text,llx,lly,urx,centeredy 
' exch'+             //text,llx,lly,newy,urx
' 4 index'+nl+       //text,llx,lly,newy,urx,text
' w'+            //text,llx,lly,newy,urx,cx
' sub'+          //text,llx,lly,newy,urx-cx
' exch moveto'+      //text,llx,lly
//' currentpoint /ay exch def /ax exch def'+ //text,llx,lly
' pop pop s'+nl+
'} bind def'+nl+

'/sc {'+nl+     //print center text: text,llx,lly,urx,ury ->
' cy'+          //text,llx,lly,urx,centeredy 
' 4 index'+     //text,llx,lly,urx,centeredy,text
' w'+           //text,llx,lly,urx,centeredy,cx
' 4 index'+     //text,llx,lly,urx,centeredy,cx,llx
' 3 index'+     //text,llx,lly,urx,centeredy,cx,llx,urx
' exch sub'+    //text,llx,lly,urx,centeredy,cx,urx-llx
' exch sub'+    //text,llx,lly,urx,centeredy,urx-llx-cx 
' 2 div'+       //text,llx,lly,urx,centeredy,(urx-llx-cx)/2
' 4 index add'+nl+ //text,llx,lly,urx,centeredy,(urx-llx-cx)/2+llx
' exch'+        //text,llx,lly,urx,newx,centeredy
' moveto'+nl+   //text,llx,lly,urx
//' currentpoint /ay exch def /ax exch def'+ //text,llx,lly,urx
' pop pop pop s'+nl+
' } bind def'+nl+

'/slb {'+nl+ //print lefttop text,llx,lly,urx,ury ->
' pop pop'+  //text,llx,lly
' desc add'+ //text,llx,lly+desc
' moveto'+
//' currentpoint /ay exch def /ax exch def'+ //backup for underline
             //text
' s'+nl+
'} bind def'+nl+

'/srb {'+nl+    //print rightbottom text: text,llx,lly,urx,ury ->
' 4 index'+     //text,llx,lly,urx,ury,text
' w'+           //text,llx,lly,urx,ury,cx
' 2 index'+     //text,llx,lly,urx,ury,cx,urx
' exch'+        //text,llx,lly,urx,ury,urx,cx
' sub'+         //text,llx,lly,urx,ury,urx-cx
' 3 index'+     //text,llx,lly,urx,ury,urx-cx,lly
' desc add'+    //text,llx,lly,urx,ury,urx-cx,lly+desc
' moveto'+nl+
//' currentpoint /ay exch def /ax exch def'+ //text,llx,lly,urx,ury
' pop pop pop pop s'+
'} bind def'+nl+

'/srt {'+nl+ //print righttoptext: text,llx,lly,urx,ury ->
' 4 index'+      //text,llx,lly,urx,ury,text
' w'+            //text,llx,lly,urx,ury,cx
' 2 index'+    //text,llx,lly,urx,ury,cx,urx
' exch'+       //text,llx,lly,urx,ury,urx,cx
' sub'+        //text,llx,lly,urx,ury,urx-cx
' exch'+       //text,llx,lly,urx,urx-cx,ury
' asc sub'+    //text,llx,lly,urx,urx-cx,ury-asc
' moveto'+nl+
//' currentpoint /ay exch def /ax exch def'+ //text,llx,lly,urx
' pop pop pop s'+
'} bind def'+nl+
 
'/st {'+nl+     //print top text: text,llx,lly,urx,ury ->
' 4 index'+     //text,llx,lly,urx,ury,text
' w'+           //text,llx,lly,urx,ury,cx
' 4 index'+     //text,llx,lly,urx,ury,cx,llx
' 3 index'+     //text,llx,lly,urx,ury,cx,llx,urx
' exch sub'+    //text,llx,lly,urx,ury,cx,urx-llx
' exch sub'+    //text,llx,lly,urx,ury,urx-llx-cx 
' 2 div'+       //text,llx,lly,urx,ury,(urx-llx-cx)/2
' 4 index add'+nl+//text,llx,lly,urx,ury,(urx-llx-cx)/2+llx
' exch'+        //text,llx,lly,urx,newx,ury
' asc sub'+     //text,llx,lly,urx,newx,ury-asc
' moveto'+      //text,llx,lly,urx
//' currentpoint /ay exch def /ax exch def'+ //text,llx,lly,urx
' pop pop pop s'+nl+
'} bind def'+nl+

'/sb {'+nl+     //print bottom text: text,llx,lly,urx,ury ->
' 4 index'+     //text,llx,lly,urx,ury,text
' w'+           //text,llx,lly,urx,ury,cx
' 4 index'+     //text,llx,lly,urx,ury,cx,llx
' 3 index'+     //text,llx,lly,urx,ury,cx,llx,urx
' exch sub'+    //text,llx,lly,urx,ury,cx,urx-llx
' exch sub'+    //text,llx,lly,urx,ury,urx-llx-cx 
' 2 div'+       //text,llx,lly,urx,ury,(urx-llx-cx)/2
' 4 index add'+nl+ //text,llx,lly,urx,ury,(urx-llx-cx)/2+llx
' 3 index'+     //text,llx,lly,urx,ury,newx,lly
' desc add'+    //text,llx,lly,urx,ury,newx,lly+desc
' moveto'+      //text,llx,lly,urx,ury
//' currentpoint /ay exch def /ax exch def'+ //text,llx,lly,urx,ury
' pop pop pop pop s'+nl+
'} bind def'+nl+

'/ul {'+nl+ //underline
' gsave'+
' desc 4 div setlinewidth'+
' 0 setlinecap'+
' [] 0 setdash'+
' currentpoint'+    //x,y
' desc 2 div sub'+nl+  //x,y-desc/2
' dup'+             //x,newy,newy
' 2 index exch'+    //x,newy,x,newy  
' moveto'+          //x,newy
' ax exch'+         //x,ax,newy
' lineto stroke'+   //x
' pop'+
' grestore'+
'} bind def'+nl+

'/so {'+ //strokeout
' gsave'+
' desc 4 div setlinewidth'+
' 0 setlinecap'+
' [] 0 setdash'+
' currentpoint'+nl+  //x,y
' asc desc add 2 div add desc sub'+ //x,y+asc+desc/2-desc
' dup'+             //x,newy,newy
' 2 index exch'+    //x,newy,x,newy  
' moveto'+          //x,newy
' ax exch'+         //x,ax,newy
' lineto stroke'+   //x
' pop'+
' grestore'+nl+
'} bind def'+nl+

'/tab {'+ //get tabulatorpos: taboffset,tabwidth -> tabx
' currentpoint'+      //o,w,x,y
' pop 2 index sub'+   //o,w,x-o
' 1 index 0.01 add'+  //o,w,x-o,w+0.01 force overflow on equal pos
' add '+              //o,w,x-o+w+0.01
' 1 index div floor'+ //o,w,tabnum
' mul add'+nl+        //tabbedx
'} bind def'+nl+
 nl;
 
 alignmentsubs: array[psalignty] of string = (
 //pa_center,pa_lefttop,pa_top,pa_righttop,pa_right,
    'sc',     'slt',     'st',  'srt',      'sr',
 //pa_rightbottom,pa_bottom,pa_leftbottom,pa_left
    'srb',         'sb',     'slb',        'sl');
 
 tftopa: array [0..15] of psalignty = (//tf_xcentered,tf_right,tf_ycentered,tf_bottom,
  pa_lefttop,                          //   0            0        0            0 
  pa_top,                              //   1            0        0            0
  pa_righttop,                         //   0            1        0            0  
  pa_center, //invalid                 //   1            1        0            0 
  pa_left,                             //   0            0        1            0
  pa_center,                           //   1            0        1            0
  pa_right,                            //   0            1        1            0
  pa_center, //invalid                 //   1            1        1            0
  pa_leftbottom,                       //   0            0        0            1
  pa_bottom,                           //   1            0        0            1
  pa_rightbottom,                      //   0            1        0            1
  pa_center, //invalid                 //   1            1        0            1
  pa_center, //invalid                 //   0            0        1            1
  pa_center, //invalid                 //   1            0        1            1
  pa_center, //invalid                 //   0            1        1            1
  pa_center  //invalid                 //   1            1        1            1
          );

type
 postscriptgcdty = record
  canvas: tpostscriptcanvas;
 end;
 postscriptgcty = record
  case integer of
   0: (d: postscriptgcdty);
   1: (_bufferspace: gcpty;);
//  res: array[1..23] of longword;
 end;

 
procedure gdi_destroygc(var drawinfo: drawinfoty);
begin
 try
  postscriptgcty(drawinfo.gc.platformdata).d.canvas.ps_destroygc;
 except //trap for stream write errors
 end;
end;
 
procedure gdi_changegc(var drawinfo: drawinfoty);
begin
 postscriptgcty(drawinfo.gc.platformdata).d.canvas.ps_changegc;
end;

procedure gdi_drawlines(var drawinfo: drawinfoty);
begin
 postscriptgcty(drawinfo.gc.platformdata).d.canvas.ps_drawlines;
end;

procedure gdi_drawlinesegments(var drawinfo: drawinfoty);
begin
 postscriptgcty(drawinfo.gc.platformdata).d.canvas.ps_drawlinesegments;
end;

procedure gdi_drawellipse(var drawinfo: drawinfoty);
begin
 postscriptgcty(drawinfo.gc.platformdata).d.canvas.handleellipse(
                        drawinfo.rect.rect^,false);
end;

procedure gdi_drawarc(var drawinfo: drawinfoty);
begin
 postscriptgcty(drawinfo.gc.platformdata).d.canvas.ps_drawarc;
end;

procedure gdi_fillrect(var drawinfo: drawinfoty);
begin
 postscriptgcty(drawinfo.gc.platformdata).d.canvas.ps_fillrect;
end;

procedure gdi_fillellipse(var drawinfo: drawinfoty);
begin
 postscriptgcty(drawinfo.gc.platformdata).d.canvas.handleellipse(
                        drawinfo.rect.rect^,true);
end;

procedure gdi_fillarc(var drawinfo: drawinfoty);
begin
 postscriptgcty(drawinfo.gc.platformdata).d.canvas.ps_fillarc;
end;

procedure gdi_fillpolygon(var drawinfo: drawinfoty);
begin
 postscriptgcty(drawinfo.gc.platformdata).d.canvas.ps_fillpolygon;
end;

procedure gdi_drawstring16(var drawinfo: drawinfoty);
begin
 postscriptgcty(drawinfo.gc.platformdata).d.canvas.ps_drawstring16;
end;

procedure gdi_setcliporigin(var drawinfo: drawinfoty);
begin
// gdierror(gde_notimplemented);
end;

procedure gdi_copyarea(var drawinfo: drawinfoty);
begin
 postscriptgcty(drawinfo.gc.platformdata).d.canvas.ps_copyarea;
end;

var
 gdifunctions: gdifunctionaty;
 
function psrealtostr(const avalue: real): string;
begin
// result:= replacechar(formatfloat('0.###',avalue),decimalseparator,'.');
          //todo: optimize
 result:= ansistring(doubletostring(avalue,-3,fsm_default,'.',#0));
// result:= formatfloatmse(avalue,'0.000');
end;

{ tpostscriptcanvas }

constructor tpostscriptcanvas.create(const user: tprinter; const intf: icanvas);
begin
 fimagecachesize:= defaultimagecachesize;
 fimagecachemaxitemsize:= defaultimagecachemaxitemsize;
 fpslevel:= psl_3;
 inherited create(user,intf);
 fdrawinfo.gc.fontgdifuncs:= tcanvas.getclassgdifuncs;
end;

function tpostscriptcanvas.getgdifuncs: pgdifunctionaty;
begin
 result:= @gdifunctions;
end;

procedure tpostscriptcanvas.checkscale;
begin
 if fstarted then begin
  streamwrite('initmatrix ');
  if printorientation = pao_landscape then begin
   streamwrite(' 90 rotate');
  end;
  streamwriteln('');
 end;
end;

procedure tpostscriptcanvas.initgcstate;
begin
 updatescale;
 fps_pagenumber:= 0;
 ffonts:= nil;
 ffontnames:= nil;
 finalize(fmapnames);
 with postscriptgcty(fdrawinfo.gc.platformdata).d do begin
  canvas:= self;
 end;
 inherited;
 streamwrite(
'%!PS-Adobe-3.0'+nl+
'%%BoundingBox: '+inttostr(fboundingbox.left)+' '+
                  inttostr(fboundingbox.bottom)+' '+
                  inttostr(fboundingbox.right)+' '+
                  inttostr(fboundingbox.top)+nl+
'%%Creator: '+ansistring(application.applicationname)+nl+
'%%Title: '+ansistring(ftitle)+nl+
'%%DocumentMedia: '+stdpagesizes[fprinter.pa_size].name+' '+
                  inttostr(fpapersize.cx)+' '+
                  inttostr(fpapersize.cy)+' 0 () ()'+nl+
'%%Pages: (atend)'+nl+
'%%PageOrder: Ascend'+nl+
'%%EndComments'+nl+
'%%BeginProlog'+nl+
 preamble+fpreamble+nl,true);
 if fdeststream = fpreamblestream then begin
  streamwrite(
'%%EndProlog'+nl,true);
 end;
 fpreamble:= '';
 fstarted:= true;
 beginpage;
end;

procedure tpostscriptcanvas.initgcvalues;
begin
 inherited;
 fimagecache:= nil;
end;

procedure tpostscriptcanvas.finalizegcstate;
begin
 if fdeststream <> fpreamblestream then begin
  streamwrite(
'%%EndProlog'+nl,true);
 end;
 fstarted:= false;
 inherited;
end;

function tpostscriptcanvas.encodefontname(const namenum,codepage: integer): string;
begin
 result:= '/F' + hextostr(longword(codepage),2)+inttostr(namenum)+' ';
end;

procedure tpostscriptcanvas.definefont(const adata: fontnumty;
                                 const acodepage: integer);
var
 str1: string;
 int1,int2: integer;
 rea1: real;
begin
 with getfontdata(adata)^,realfont do begin
  str1:= name;
  if (str1 = '') or (h.name = 'stf_default') and (str1 = 'sans') then begin
   str1:= 'Helvetica';
  end
  else begin
   str1:= psencode(pchar(str1),length(str1));
  end;
  if d.style * [fs_bold,fs_italic] <> [] then begin
   str1:= str1 + '-';
   if fs_bold in d.style then begin
    str1:= str1 + 'Bold';
   end;
   if fs_italic in d.style then begin
    str1:= str1 + 'Italic';
   end;
  end;
  int2:= -1;
  for int1:= 0 to high(ffontnames) do begin
   if ffontnames[int1] = str1 then begin
    int2:= int1;
    break;
   end;
  end;
  if int2 < 0 then begin
   checkmap(acodepage);
   additem(ffontnames,str1);
   int2:= high(ffontnames);
                  //alias,encoding,origname
   streamwrite(encodefontname(int2,acodepage)+fmapnames[acodepage]+
                  ' ('+str1+') rf' + nl,true);
            //register font
  end;
  setlength(ffonts,high(ffonts)+2);
  with ffonts[high(ffonts)] do begin
   handle:= adata;
   namenum:= int2;
   additem(codepages,acodepage);
   if d.height = 0 then begin
    size:= round(defaultfontheight*ppmm);
   end
   else begin
    size:= (d.height + fontsizeroundvalue) shr fontsizeshift;
   end;
   rea1:= (size / ppmm) * mmtoprintscale;
   scalestring1:= psrealtostr(rea1 * d.xscale);     //xscale
   scalestringfull:= scalestring1;
   str1:= ' ' + psrealtostr(rea1);                //yscale
   scalestringfull:= scalestringfull + str1;
   if (d.xscale <> 1) or (d.rotation <> 0) then begin
    scalestring1:= scalestring1 + str1;
   end;
   str1:= ' ' + psrealtostr(d.rotation*radtodeg);
   scalestringfull:= scalestringfull + str1;
   if d.rotation <> 0 then begin 
    scalestring1:= scalestring1 + str1;
   end;
  end;
 end;
end;

function tpostscriptcanvas.checkfont(const afont: fontnumty;
                                     const acodepage: integer): integer;
var
 int1,int2: integer;
 bo1: boolean;
begin
 int2:= -1;
 for int1:= 0 to high(ffonts) do begin
  if ffonts[int1].handle = afont then begin
   int2:= int1;
   break;
  end;
 end;
 if int2 < 0 then begin
  definefont(afont,acodepage);
  int2:= high(ffonts);
 end
 else begin
  with ffonts[int2] do begin
   bo1:= false;
   for int1:= 0 to high(codepages) do begin
    if codepages[int1] = acodepage then begin
     bo1:= true;
     break;
    end;
   end;
   if not bo1 then begin
    checkmap(acodepage);
    streamwrite(encodefontname(namenum,acodepage)+fmapnames[acodepage]+
           ' ('+ffontnames[namenum]+') rf' + nl,true);
            //register font
    additem(codepages,acodepage);
   end;
  end;
 end;
 result:= int2;
 factfont:= int2;
 factcodepage:= acodepage;
end;

function tpostscriptcanvas.getscalestring(const astyle: fontstylesty): ansistring;
begin
 with ffonts[factfont] do begin
  if (astyle * [fs_underline,fs_strikeout] <> []) then begin
   result:= scalestringfull;
   if fs_underline in astyle then begin
    result:= result + ' 1';
   end
   else begin
    result:= result + ' 0';
   end;
   if fs_strikeout in astyle then begin
    result:= result + ' 1';
   end;
  end
  else begin
   result:= scalestring1;
  end;
 end;
end;

procedure tpostscriptcanvas.selectfont(const afont: fontnumty; const acodepage: integer);
begin
 checkfont(afont,acodepage);
 streamwrite('['+encodefontname(ffonts[factfont].namenum,acodepage)+
                            getscalestring(font.style) + '] sf'+nl);
end;

procedure tpostscriptcanvas.ps_destroygc;
begin
 endpage;
 streamwrite(
  '%%Trailer'+nl+
  '%%Pages: '+inttostr(fps_pagenumber)+nl+
  '%%EOF'+nl);
end;

procedure tpostscriptcanvas.ps_changegc;
var
 str1: string;
 int1,int2: integer;
 rect1,rect2: rectty;
 ar1: rectarty;
begin
 ar1:= nil; //compiler warning
 with fdrawinfo,gcvalues^ do begin
  if gvm_dashes in mask then begin
   int2:= length(lineinfo.dashes);
   if (int2 > 0) and (lineinfo.dashes[int2] = #0) then begin
    dec(int2);
   end;
   str1:= '[';
   for int1:= 1 to int2 do begin
    str1:= str1 +
         psrealtostr(mmtoprintscale*(byte(lineinfo.dashes[int1])/ppmm))+' ';
   end;
   str1:= str1+'] 0 setdash'+nl;
   streamwrite(str1);
  end;
  if (self.brush <> nil) and 
            ([gvm_brush,gvm_brushorigin] * mask <> []) then begin
   with tsimplebitmap1(self.brush) do begin
    rect1:= makerect(nullpoint,size);
    rect2:= makerect(self.brushorigin,size);
    if createpattern(rect1,rect2,acolorbackground,acolorforeground,
                   canvas{handle,canvas.gchandle},patpatname) then begin
     streamwrite('/bru exch def'+nl);
    end;
   end;
  end;
  if df_brush in gc.drawingflags then begin
   streamwrite('bru setpattern'+nl);
  end
  else begin
   if gvm_colorforeground in mask then begin
    streamwrite(setcolorstring(acolorforeground)+nl);
   end;
  end;
  if gvm_font in mask then begin
   selectfont(fontnum,0);
  end;
  if gvm_linewidth in mask then begin
   setpslinewidth(lineinfo.width);
  end;
  if gvm_capstyle in mask then begin
   case lineinfo.capstyle of
    cs_round: str1:= '1';
    cs_projecting: str1:= '2';
    else str1:= '0'; //cs_butt
   end;
   streamwrite(str1+' setlinecap'+nl);
  end;
  if gvm_joinstyle in mask then begin
   case lineinfo.joinstyle of
    js_round: str1:= '1';
    js_bevel: str1:= '2';
    else str1:= '0'; //js_miter
   end;
   streamwrite(str1+' setlinejoin'+nl);
  end;
  if gvm_clipregion in mask then begin
   str1:= 'initclip';
   if clipregion <> 0 then begin
    ar1:= gui_regiontorects(clipregion);
    str1:= str1 + ' [';
    int2:= 3;
    for int1:= 0 to high(ar1) do begin
     str1:= str1 + ' '+
      gcposstring(addpoint(ar1[int1].pos,gc.cliporigin)) +
                   ' ' + rectsizestring(ar1[int1].size);
     dec(int2);
     if int2 <= 0 then begin
      int2:= 3;
      str1:= str1 + nl;
     end;
    end;
    str1:= str1 + '] rectclip';
   end;
   streamwrite(str1+nl);
  end;
 end;
end;

function tpostscriptcanvas.gcposstring(const apos: pointty): string;
begin
 result:= 
  psrealtostr(apos.x*fgcscale+fgcoffsetx)+' '+
  psrealtostr(fgcoffsety-apos.y*fgcscale);
end;

function tpostscriptcanvas.devpos(const apos: pointty): pspointty;
begin
 if not (cs_origin in fstate) then begin
  checkgcstate([cs_origin]);
 end;
 result.x:= apos.x*fgcscale+foriginx;
 result.y:= foriginy-apos.y*fgcscale;
end;

function tpostscriptcanvas.posstring(const apos: pointty): string;
var
 pt1: pspointty;
begin
 pt1:= devpos(apos);
 result:= psrealtostr(pt1.x)+' '+ psrealtostr(pt1.y);
end;

function tpostscriptcanvas.matrixstring(const mat: psmatrixty): string;
begin
 result:= '['+psrealtostr(mat[0,0])+' '+psrealtostr(mat[0,1])+' '+
              psrealtostr(mat[1,0])+' '+psrealtostr(mat[1,1])+' '+
              psrealtostr(mat[2,0])+' '+psrealtostr(mat[2,1])+']';
end;

function tpostscriptcanvas.transrotate(const sourcecenter,destcenter: pointty;
                                                const angle: real): string;
var
 mat1: psmatrixty;
begin
 mat1:= psunitymatrix;
 psrotate(mat1,angle);
 pstranslate(mat1,psdist(pstransform(mat1,devpos(sourcecenter)),
                                                devpos(destcenter)));
 result:= matrixstring(mat1) + ' concat';
end;

function tpostscriptcanvas.diststring(const adist: integer): string;
begin
 result:= psrealtostr(adist*fgcscale);
end;

function tpostscriptcanvas.sizestring(const asize: sizety): string;
begin
 result:= psrealtostr(asize.cx*fgcscale)+' '+psrealtostr(asize.cy*fgcscale);
end;

function tpostscriptcanvas.rectsizestring(const asize: sizety): string;
begin
 result:= psrealtostr(asize.cx*fgcscale)+' '+psrealtostr(-asize.cy*fgcscale);
end;

function tpostscriptcanvas.rectstring(const arect: rectty): string;
begin
 with arect do begin
  result:= 
   psrealtostr(x*fgcscale+foriginx)+' '+
   psrealtostr(foriginy-y*fgcscale)+' '+
   psrealtostr(cx*fgcscale)+' '+psrealtostr(-cy*fgcscale)
 end;
end;

function tpostscriptcanvas.getcolorstring(const acolor: colorty): string;
var
 co1: rgbtriplety;
begin
 co1:= colortorgb(acolor);
 if fcolorspace = cos_rgb then begin
  result:= psrealtostr(co1.red/255)+' '+psrealtostr(co1.green/255)+' '+
             psrealtostr(co1.blue/255);
 end
 else begin
  result:= psrealtostr((word(co1.red)+co1.green+co1.blue)/(3.0*255));
 end;
end;

function tpostscriptcanvas.setcolorstring(const acolor: colorty): string;
begin
 if fcolorspace = cos_rgb then begin
  result:= getcolorstring(acolor)+' setrgbcolor';
 end
 else begin
  result:= getcolorstring(acolor)+' setgray';
 end;
end;

function tpostscriptcanvas.psencode(const text: pchar; const count: integer): string;
var
 int1,int2: integer;
 ch1: char;
 po1: pchar;
begin
 setlength(result,count*4); //max
 po1:= pchar(pointer(result));
 int2:= 0;
 for int1:= 0 to count-1 do begin
  ch1:= (text+int1)^;
  if (ch1 >= #128) or (ch1 < #32) then begin
   if ch1 = #0 then begin
    dec(int2);        //remove zeroes
   end
   else begin
    (po1+int2)^:= '\';             //octal  
    (po1+int2+3)^:= char((byte(ch1) and $07) + ord('0'));
    ch1:= char(byte(ch1) shr 3);
    (po1+int2+2)^:= char((byte(ch1) and $07) + ord('0'));
    ch1:= char(byte(ch1) shr 3);
    (po1+int2+1)^:= char((byte(ch1) and $03) + ord('0'));
    inc(int2,3);
   end;
  end 
  else begin
   case ch1 of
    '\','(',')': begin
     (po1+int2)^:= '\';
     inc(int2);
     (po1+int2)^:= ch1;
    end;
    else begin
     (po1+int2)^:= ch1;
    end;
   end;
  end;
  inc(int2);
 end;
 setlength(result,int2);
end;

function tpostscriptcanvas.getshowstring(const avalue: pmsechar; 
          const count: integer; fontneeded: boolean = false; 
          const acolor: colorty = cl_none;
          const acolorbackground: colorty = cl_none;
          const fontstyle: fontstylesty = []): string;
var
 int1: integer;
 wo1,wo2: word;
 po1,po2: pchar;
 colback: colorty;
 
 procedure pushsubstring;
 begin
  result:= result + '[('+psencode(po2,po1-po2)+')';
  if fontneeded then begin
   with ffonts[factfont] do begin
//    result:= result + ' ['+encodefontname(namenum,factcodepage) + scalestring1+']';
    result:= result + ' ['+encodefontname(namenum,factcodepage) + 
                                             getscalestring(fontstyle)+']';
   end;
  end;
  if acolor <> cl_none then begin
   result:= result+'['+getcolorstring(acolor)+']';
  end;
  if colback <> cl_transparent then begin
   if acolor = cl_none then begin
    result:= result + '[currentcolor]';
   end;
   result:= result+'['+getcolorstring(colback)+']';
  end;
  result:= result +']';
  po1:= po2;
 end;
 
begin
 if acolorbackground <> cl_none then begin
  colback:= acolorbackground;
 end
 else begin
  colback:= font.colorbackground;
 end;
 if (acolor <> cl_none) or (colback <> cl_transparent) then begin
  fontneeded:= true;
 end;
 getmem(po1,count);
 po2:= po1;
 wo1:= factcodepage shl 8;
 result:= '';
 for int1:= 0 to count -1 do begin
  wo2:= word(pmsecharaty(avalue)^[int1]);
  if (wo2 xor wo1) and $ff00 <> 0 then begin
   if int1 <> 0 then begin
    pushsubstring;
   end;
   fontneeded:= true;
   wo1:= wo2 and $ff00;
   checkfont(ffonts[factfont].handle,wo1 shr 8);
  end;
  po1^:= char(wo2);
  inc(po1);
 end;
 pushsubstring;
 freemem(po2);
end;

procedure tpostscriptcanvas.ps_drawstring16;
begin
 if active then begin
  with fdrawinfo.text16pos do begin
   streamwrite(posstring(pos^)+' moveto ['+getshowstring(text,count)+'] s'+nl);
  end;
 end;
end;

procedure tpostscriptcanvas.textout(const text: richstringty; const dest: rectty;
         const flags: textflagsty; const tabdist: real);
const
 fontstylemask{: newinfosty} = [ni_bold,ni_italic,ni_underline,ni_strikeout];
 mask1 = [tf_xcentered,tf_right];
 mask2 = [tf_ycentered,tf_bottom];
var
 str1: ansistring;
 int1,int2,int3: integer;
 co1,co2: colorty;
 colorchanged: boolean;
 style1: fontstylesty;
 lastbreak: integer;
 rect1: rectty;
 
 procedure addstring(const astring: ansistring);
 begin
  if (length(str1) - lastbreak) + length(astring) > maxlinecharcount then begin
   str1:= str1+ nl;
   lastbreak:= length(str1);
  end;
  str1:= str1+astring;
 end;
var
 pt1: pointty; 
 rea1: real;
begin
 if not active {or (text.text = '')} then begin
  exit;
 end;
 colorchanged:= false;
 str1:= '';
 if flags * [tf_rotate90,tf_rotate180] <> [] then begin
  str1:= 'matrix currentmatrix'+nl; //backup
  pt1:= dest.pos;
  if tf_rotate90 in flags then begin
   if tf_rotate180 in flags then begin
    rea1:= pi*3.0/2.0;
    pt1.x:= pt1.x+dest.cx;
   end
   else begin
    rea1:= pi/2.0;
    pt1.y:= pt1.y+dest.cy;
   end;
  end
  else begin
   rea1:= pi;
   pt1.x:= pt1.x+dest.cx;
   pt1.y:= pt1.y+dest.cy;
  end;
  str1:= str1+transrotate(dest.pos,pt1,rea1)+nl;
 end;
 lastbreak:= 0;
 str1:= str1+'['; 
 if (text.format = nil) or (text.text = '') then begin
  addstring(getshowstring(pmsechar(text.text),length(text.text),
                true,cl_none,cl_none,font.style)+'] ');
 end
 else begin
  gcfonthandle1:= 0; //invalid after print
  with text.format[0] do begin
   if index > 0 then begin
    addstring(getshowstring(pmsechar(pointer(text.text)),index));
   end;
  end;
  co1:= cl_none;
  co2:= cl_none;
  style1:= font.style;
  for int1:= 0 to high(text.format) do begin
   with text.format[int1] do begin
    if int1 = high(text.format) then begin
     int3:= bigint;
    end
    else begin
     int3:= text.format[int1+1].index;
    end;
    if int3 > length(text.text) then begin
     int3:= length(text.text);
    end;
    int2:= index + 1;
    if int2 > length(text.text) then begin
     int2:= length(text.text);
    end;
    if newinfos * fontstylemask <> [] then begin
     style1:= style1 * fontstylesty(
       {$ifndef FPC}byte({$endif}
           not {$ifdef FPC}longword{$else}word{$endif}(newinfos))
           {$ifndef FPC}){$endif} + style.fontstyle;
    end;
    font.style:= style1;
    checkfont(font.handle,(word(text.text[int2]) and $ff00) shr 8);
    int2:= int3 - index;
    if int2 > 0 then begin
     if ni_fontcolor in newinfos then begin
      if style.fontcolor = 0 then begin
       co1:= font.color;
       colorchanged:= false;
      end
      else begin
       co1:= not style.fontcolor;
       colorchanged:= true;
      end;
     end;
     if ni_colorbackground in newinfos then begin
      if style.colorbackground = 0 then begin
       co2:= cl_none;
      end
      else begin
       co2:= not style.colorbackground;
      end;
     end;
     addstring(getshowstring(pmsechar(pointer(text.text))+index,int2,true,co1,co2,
                               style1));
    end;
   end;   
  end;
  str1:= str1 + '] ';
 end;
 if tf_rotate90 in flags then begin
  rect1.pos:= dest.pos;
  rect1.cx:= dest.cy;
  rect1.cy:= dest.cx;
 end
 else begin
  rect1:= dest;
 end;
 if tabdist = 0 then begin
  str1:= str1 + posstring(makepoint(rect1.x,rect1.y+rect1.cy))+' '+   //lower left
                posstring(makepoint(rect1.x+rect1.cx,rect1.y))+ ' ';  //upper right
 end
 else begin
  if tabdist < 0 then begin //last pos
   str1:= str1 + 'currentpoint pop '; //oldx (llx)
  end
  else begin //defaulttab
   str1:= str1 + psrealtostr(foriginx)+' '+psrealtostr(tabdist) + ' tab ';
                 //tabbedx (llx)
  end;
  str1:= str1 + psrealtostr(foriginy-(rect1.y+rect1.cy)*fgcscale)+
                      //llx,lly
   ' 1 index '+       //llx,lly,urx
   psrealtostr(foriginy-(rect1.y)*fgcscale)+' '; //llx,lly,urx,ury
 end;
 int1:= {$ifdef FPC}longword{$else}longword{$endif}(flags*mask1) or
        ({$ifdef FPC}longword{$else}longword{$endif}(flags*mask2) shr 1); 
        //remove tf_xjustify
 str1:= str1+alignmentsubs[tftopa[int1]];
{
 if fs_underline in font.style then begin
  str1:= str1 + ' ul';
 end;
 if fs_strikeout in font.style then begin
  str1:= str1 + ' so';
 end;
}
 if colorchanged then begin
  str1:= str1 + ' '+setcolorstring(font.color);
 end;
 if flags * [tf_rotate90,tf_rotate180] <> [] then begin
  str1:= str1+nl+'setmatrix'; //restore CTM
 end;
 streamwrite(str1+nl);
end;

procedure tpostscriptcanvas.begintextclip(const arect: rectty);
begin
 streamwrite('gsave '+rectstring(arect)+' rectclip'+nl);
end;

procedure tpostscriptcanvas.endtextclip;
begin
 streamwrite('grestore'+nl);
end;

procedure tpostscriptcanvas.setpslinewidth(const avalue: integer);
var
 rea1: real;
begin
 if avalue = 0 then begin
  rea1:= nulllinewidth;
 end
 else begin
  rea1:= avalue/(ppmm*(1 shl linewidthshift)) * mmtoprintscale;
 end;
 streamwrite(psrealtostr(rea1)+' setlinewidth'+nl);
end;

function tpostscriptcanvas.strokestr: string;
begin
 if (length(dashes) > 0) and (df_opaque in fdrawinfo.gc.drawingflags) then begin 
                                    //(dashes[length(dashes)] = #0) then begin
  result:= 'gsave [] 0 setdash ' + setcolorstring(fdrawinfo.acolorbackground) +
           ' stroke grestore stroke'; //draw background 
 end
 else begin
  result:= 'stroke';
 end;
end;

procedure tpostscriptcanvas.handlepoly(const points: ppointty; 
             const lastpoint: integer; const closed: boolean; const fill: boolean);
var
 int1: integer;
 str1,str2: string;
begin
 if active then begin
  str1:= '';
  str2:= 'newpath '+ posstring(points^) + ' moveto '+nl;
  for int1:= 1 to lastpoint do begin
   if length(str1) > 80 then begin
    str2:= str2 + str1 + nl;
    str1:= '';
   end;
   str1:= str1 + posstring(ppointaty(points)^[int1])+' lineto ';
  end;
  str2:= str2 + str1 + nl;
  if closed then begin
   str2:= str2 + 'closepath ';
  end;
  if fill then begin
   str2:= str2 + 'fill';
  end
  else begin
   str2:= str2 + strokestr;
  end;
  streamwrite(str2+nl);
 end;
end;

procedure tpostscriptcanvas.handleellipse(const rect: rectty; const fill: boolean);
var
 str1: string;
begin
 with rect do begin
  str1:= 'newpath ';
  if cy = cx then begin
   str1:= str1+posstring(pos)+' '+diststring(cx div 2)+' 0 360 arc ';
  end
  else begin
   str1:= str1 + 'matrix currentmatrix '+ posstring(pos) + ' translate '+nl+
              sizestring(size)+' scale 0 0 0.5 0 360 arc setmatrix ';
  end;
 end;
 str1:= str1 + 'closepath ';
 if fill then begin
  str1:= str1 + 'fill';
 end
 else begin
  str1:= str1 + strokestr;
 end;
 streamwrite(str1+nl);
end;

procedure tpostscriptcanvas.ps_drawarc;
var
 str1: string;
begin
 with fdrawinfo.arc,rect^ do begin
  str1:= 'newpath ';
  if cy = cx then begin
   str1:= str1+posstring(pos)+' '+diststring(cx div 2)+' '+
     psrealtostr(startang*radtodeg)+' '+psrealtostr((startang+extentang)*radtodeg)+
     ' arc ';
  end
  else begin
   str1:= str1 + 'matrix currentmatrix '+ posstring(pos) + ' translate '+nl+
              sizestring(size)+' scale 0 0 0.5 '+
     psrealtostr(startang*radtodeg)+' '+psrealtostr((startang+extentang)*radtodeg)+
      ' arc setmatrix ';
  end;
 end;
 str1:= str1 + strokestr;
 streamwrite(str1+nl);
end;

procedure tpostscriptcanvas.ps_fillarc;
var
 str1: string;
begin
 with fdrawinfo.arc,rect^ do begin
  str1:= 'newpath ';
  if pieslice then begin
   str1:= str1+posstring(pos)+' moveto ';
  end;
  if cy = cx then begin
   str1:= str1+posstring(pos)+' '+diststring(cx div 2)+' '+
     psrealtostr(startang*radtodeg)+' '+psrealtostr((startang+extentang)*radtodeg)+
     ' arc ';
  end
  else begin
   str1:= str1 + 'matrix currentmatrix '+ posstring(pos) + ' translate '+nl+
              sizestring(size)+' scale 0 0 0.5 '+
     psrealtostr(startang*radtodeg)+' '+psrealtostr((startang+extentang)*radtodeg)+
      ' arc setmatrix ';
  end;
 end;
 str1:= str1 + 'closepath fill';
 streamwrite(str1+nl);
end;

procedure tpostscriptcanvas.ps_drawlines;
begin
 with fdrawinfo.points do begin
  handlepoly(points,count-1,closed,false);
 end;
end;

procedure tpostscriptcanvas.ps_drawlinesegments;
var
 int1: integer;
begin
 with fdrawinfo.points do begin
  for int1:= 0 to count div 2 - 1 do begin
   handlepoly(points,1,false,false);
   inc(points,2);
  end;
 end;
end;

procedure tpostscriptcanvas.ps_fillpolygon;
begin
 with fdrawinfo.points do begin
  handlepoly(points,count-1,true,true);
 end;
end;

procedure tpostscriptcanvas.ps_fillrect;
var
 points1: array[0..3] of pointty;
begin
 with fdrawinfo.rect.rect^ do begin
  points1[0].x:= x;
  points1[0].y:= y;
  points1[1].x:= x+cx;
  points1[1].y:= y;
  points1[2].x:= x+cx;
  points1[2].y:= y+cy;
  points1[3].x:= x;
  points1[3].y:= y+cy;
  handlepoly(@points1,high(points1),true,true);
 end;
end;

procedure tpostscriptcanvas.writebinhex(const data: bytearty);
var
 int1,int2,int3: integer;
 po1: pbyte;
 po2: pchar;
 str1: string;
begin
 po1:= pointer(data);
 int2:= length(data);
 setlength(str1,80);
 repeat
  int1:= 40;
  if int1 > int2 then begin
   int1:= int2;
   setlength(str1,2*int1);
  end;
  po2:= pchar(str1);
  for int3:= int1 - 1 downto 0 do begin
   po2^:= charhex[po1^ shr 4];
   inc(po2);
   po2^:= charhex[po1^ and $0f];
   inc(po2);
   inc(po1);
  end;
  dec(int2,40);
  streamwriteln(str1);
 until int2 <= 0;
end;

function tpostscriptcanvas.rectscalestring(const arect: rectty): string; 
                 //transform unity cell to arect
begin
 with arect do begin
  result:= psrealtostr(x*fgcscale+foriginx)+' '+
           psrealtostr(foriginy-(y+cy{-1})*fgcscale)+' translate '+ 
           psrealtostr(cx*fgcscale)+' '+psrealtostr(cy*fgcscale)+' scale';
 end;
end;

function tpostscriptcanvas.imagematrixstring(const asize: sizety): string;
var
 str1: string;
begin
 with asize do begin
  str1:= inttostr(cy);
  result:= '['+inttostr(cx)+' 0 0 -'+str1+' 0 '+str1+']';
 end;
end;

const
 unityrectpath = 'newpath 0 0 moveto 1 0 lineto 1 1 lineto 0 1 lineto closepath';
 
procedure convertrgb(const sourcerect: rectty; const image: imagety;
                     out data: bytearty; out rowbytes: integer);
var
 po1: prgbtriplety;
 po2,po3: pbyte;
 int1,int2: integer;
begin
 with sourcerect do begin
  rowbytes:= cx*3;
  setlength(data,rowbytes*cy);
  po2:= pointer(data);
  if image.kind = bmk_rgb then begin
   for int1:= y to y + cy - 1 do begin
    po1:= @image.pixels^[int1*image.size.cx+x];
    for int2:= x to x + cx - 1 do begin
     po2^:= po1^.red;
     inc(po2);
     po2^:= po1^.green;
     inc(po2);
     po2^:= po1^.blue;
     inc(po2);
     inc(po1);
    end;
   end;
  end
  else begin //bmk_gray
   for int1:= y to y + cy - 1 do begin
    po3:= pointer(image.pixels)+ int1*image.linebytes + x;
    for int2:= x to x + cx - 1 do begin
     po2^:= po3^;
     inc(po2);
     po2^:= po3^;
     inc(po2);
     po2^:= po3^;
     inc(po2);
     inc(po3);
    end;
   end;
  end;
 end;
end;

procedure convertgray(const sourcerect: rectty; const image: imagety;
                     out data: bytearty; out rowbytes: integer);
var
 po1: prgbtriplety;
 po2,po3: pbyte;
 int1,int2: integer;
begin
 with sourcerect do begin
  rowbytes:= cx;
  setlength(data,rowbytes*cy);
  po2:= pointer(data);
  if image.kind = bmk_rgb then begin
   for int1:= y to y + cy - 1 do begin
    po1:= @image.pixels^[int1*image.size.cx+x];
    for int2:= x to x + cx - 1 do begin
     po2^:= (po1^.red + po1^.green + po1^.blue) div 3;
     inc(po2);
     inc(po1);
    end;
   end;
  end
  else begin //bmk_gray
   for int1:= y to y + cy - 1 do begin
    po3:= pointer(image.pixels) + int1*image.linebytes + x;
    for int2:= x to x + cx - 1 do begin
     po2^:= po3^;
     inc(po2);
     inc(po3);
    end;
   end;
  end;
 end;
end;

procedure convertmono(const sourcerect: rectty; const image: imagety;
                      out data: bytearty; out rowbytes: integer);
var
 sourcerowstep: integer;
 rowshiftleft,rowshiftright: byte;
 po1,po2: pbyte;
 int1,int2: integer;
begin
 with sourcerect do begin
  rowbytes:= (cx + 7) div 8;
  setlength(data,rowbytes*cy);
  rowshiftright:= x and $7;
  rowshiftleft:= 8-rowshiftright;
  sourcerowstep:= ((image.size.cx + 31) div 32)*4;
  po1:= @pbyteaty(image.pixels)^[y * sourcerowstep + x div 8];
  sourcerowstep:= sourcerowstep - rowbytes;
  po2:= pointer(data);
  for int1:= cy - 1 downto 0 do begin
   for int2:= rowbytes - 1 downto 0 do begin
    po2^:= (po1^ shr rowshiftright);
    inc(po1);
    po2^:= bitreverse[po2^ or byte(po1^ shl rowshiftleft)];
                           //byte(... needed for FPC!
    inc(po2);
   end;
   inc(po1,sourcerowstep);
  end;
 end;
end;

procedure convertmonotogray(const sourcerect: rectty; var image: imagety;
                      out data: bytearty; out rowbytes: integer;
                      const colorforeground,colorbackground: colorty);
var
 grf,grb: byte;
 po1: pbyte;
 po2: pbyte;
 int1,int2: integer;
 ar1: bytearty;
 rowb: integer;
 by1: byte;
begin
 convertmono(sourcerect,image,ar1,rowb);
// image.monochrome:= false;
 image.kind:= bmk_rgb;
 with colortorgb(colorforeground) do begin
  grf:= (red + green + blue) div 3;
 end;
 with colortorgb(colorbackground) do begin
  grb:= (red + green + blue) div 3;
 end;
 with sourcerect do begin
  rowbytes:= cx;
  setlength(data,rowbytes*cy);
  po2:= pointer(data);
  for int1:= 0 to cy - 1 do begin
   po1:= @ar1[int1*rowb];
   for int2:= 0 to cx - 1 do begin
    by1:= bytebitsreverse[int2 and $7];
    if po1^ and by1 = 0 then begin
     po2^:= grb;
    end
    else begin
     po2^:= grf;
    end;
    inc(po2);
    if by1 = $01 then begin
     inc(po1);
    end;
   end;
  end;
 end;
end;

procedure convertmonotorgb(const sourcerect: rectty; var image: imagety;
                      out data: bytearty; out rowbytes: integer;
                      const colorforeground,colorbackground: colorty);
var
 rgbf,rgbb: rgbtriplety;
 po1: pbyte;
 po2: pbyte;
 int1,int2: integer;
 ar1: bytearty;
 rowb: integer;
 by1: byte;
 po3: prgbtriplety;
begin
 convertmono(sourcerect,image,ar1,rowb);
// image.monochrome:= false;
 image.kind:= bmk_rgb;
 rgbf:= colortorgb(colorforeground);
 rgbb:= colortorgb(colorbackground);
 with sourcerect do begin
  rowbytes:= cx*3;
  setlength(data,rowbytes*cy);
  po2:= pointer(data);
  for int1:= 0 to cy - 1 do begin
   po1:= @ar1[int1*rowb];
   for int2:= 0 to cx - 1 do begin
    by1:= bytebitsreverse[int2 and $7];
    if po1^ and by1 = 0 then begin
     po3:= @rgbb;
    end
    else begin
     po3:= @rgbf;
    end;
    po2^:= po3^.red;
    inc(po2);
    po2^:= po3^.green;
    inc(po2);
    po2^:= po3^.blue;
    inc(po2);
    if by1 = $01 then begin
     inc(po1);
    end;
   end;
  end;
 end;
end;

function tpostscriptcanvas.createpattern(const sourcerect,destrect: rectty;
                   const acolorbackground,acolorforeground: colorty;
                   const acanvas: tcanvas;
                   {const pixmap: pixmapty; const agchandle: ptruint;}
                   const patname: string): boolean;
         //returns pattern dict on ps stack
var
 ar1: bytearty;
 str1: string;
// components: integer;
 rowbytes: integer;
 varname: string;
 image: imagety;
 cached: boolean;
begin
 result:= true;
 rowbytes:= 0;
 ar1:= nil;
 cached:= getimagecache(ick_3,acanvas,sourcerect,varname{,rowbytes});
 if not cached then begin
  gdi_lock;
 // result:= gdi_pixmaptoimage(pixmap,image,agchandle) = gde_ok;
  result:= gui_pixmaptoimage(acanvas.paintdevice,image,acanvas.gchandle) = gde_ok;
  gdi_unlock;
  if not result then begin
   exit;
  end;
//  components:= 1;
  if acanvas.kind = bmk_mono then begin
   convertmono(sourcerect,image,ar1,rowbytes);
  end
  else begin
   if colorspace = cos_gray then begin
    convertgray(sourcerect,image,ar1,rowbytes);
   end
   else begin
//    components:= 3;
    convertrgb(sourcerect,image,ar1,rowbytes);
   end;
  end;
  gui_freeimagemem(image.pixels);
  if length(ar1) > 60000 then begin
   result:= false;
   exit;
  end;
  cached:= setimagecache(ick_3,acanvas,sourcerect,varname,ar1{,rowbytes});
 end;
 if cached then begin
  str1:= '/'+patname+' '+varname+' def ';
 end
 else begin
  str1:= '/'+patname+' '+inttostr(rowbytes*sourcerect.cy)+' string def'+nl+
         'currentfile '+patname+' readhexstring'+nl;
  streamwrite(str1);
  writebinhex(ar1);
  str1:= 'pop pop ';
 end;
 str1:= str1+'gsave '+rectscalestring(destrect)+nl+
'<< /PatternType 1 /PaintType 1 /TilingType 1 /BBox [0 0 1 1] /XStep 1 /YStep 1'+nl+ 
'/PaintProc {' + nl;
 if acanvas.kind = bmk_mono then begin
  if acolorbackground <> cl_transparent then begin
   str1:= str1 + unityrectpath + nl + 
         setcolorstring(acolorbackground) + ' fill ';   
  end;
  str1:= str1 + setcolorstring(acolorforeground) + nl;
 end;
 str1:= str1 +
      inttostr(sourcerect.size.cx) + ' ' + inttostr(sourcerect.size.cy);
 if acanvas.kind = bmk_mono then begin
  str1:= str1 + ' true ';
 end
 else begin
  str1:= str1 + ' 8';
 end;
 str1:= str1 + imagematrixstring(sourcerect.size)+ ' '+patname+' ';
 if acanvas.kind = bmk_mono then begin
  str1:= str1 + 'imagemask';
 end
 else begin
  if colorspace = cos_gray then begin
   str1:= str1 + 'image';
  end
  else begin
   str1:= str1 + 'false 3 colorimage';
  end;
 end;
 str1:= str1+' } bind >> matrix makepattern grestore'+nl;
 streamwrite(str1);
end;
  
procedure tpostscriptcanvas.checkcolorspace;
begin
 if not (cs_acolorforeground in fstate) then begin
  streamwrite(setcolorstring(color)+nl); //init colorspace
  include(fstate,cs_acolorforeground);
 end;
end;

procedure tpostscriptcanvas.ps_copyarea;
var
 mono: boolean;
 cached: boolean;
 varname: string;
 
 function imagedict: string;
 begin
  with fdrawinfo.copyarea.sourcerect^ do begin
   result:= setcolorstring(fdrawinfo.acolorforeground)+nl+
   ' << /ImageType 1 /Width '+inttostr(size.cx)+
   ' /Height '+inttostr(size.cy)+' /ImageMatrix '+imagematrixstring(size)+nl;
   if cached then begin
    result:= result + '/DataSource '+varname+nl;
   end
   else begin
    result:= result + '/DataSource {currentfile picstr readhexstring pop}'+nl;
   end;
   result:= result + '/BitsPerComponent ';
  end;
  if mono{image.monochrome} then begin
   result:= result+'1 ';
  end
  else begin
   result:= result+'8 ';
  end;
  result:= result+'/Decode ';
  if mono{image.monochrome} then begin
   result:= result + '[1 0] ';
  end
  else begin
   if colorspace = cos_gray then begin
    result:= result + '[0 1] ';
   end
   else begin
    result:= result + '[0 1 0 1 0 1] ';
   end;
  end;
  if al_intpol in fdrawinfo.copyarea.alignment then begin
   result:= result + '/Interpolate true ';
  end;
  result:= result + '>>'+nl;
 end;

var 
 ar1,ar2,ar3: bytearty;
 str1: string;
// components: integer;
 rowbytes,maskrowbytes: integer;
 masked: boolean;
 maskcopy: boolean;
 maskbefore: tsimplebitmap;
 po1,po2,po3: pbyte;
 int1: integer;
 image: imagety;
label
 endlab;
begin
 with fdrawinfo,copyarea do begin
  if not (df_canvasispixmap in tcanvas1(source).fdrawinfo.gc.drawingflags) then begin
   exit;
  end;
  mono:= source.kind = bmk_mono;
  subpoint1(destrect^.pos,origin); //map to pd origin
  maskcopy:= mono and (mask <> nil) and (mask.kind = bmk_mono) and
             ((acolorforeground = cl_transparent) or
              (acolorbackground = cl_transparent));
  maskbefore:= mask; //compiler warning
  if maskcopy then begin
   mask:= tsimplebitmap.create(bmk_mono{true});
   mask.size:= sourcerect^.size;
   mask.canvas.copyarea(maskbefore.canvas,sourcerect^,nullpoint);
   if acolorbackground = cl_transparent then begin
    mask.canvas.copyarea(source,sourcerect^,nullpoint,rop_and);
   end;
   if acolorforeground = cl_transparent then begin
    mask.canvas.copyarea(source,sourcerect^,nullpoint,rop_notand);
   end;
  end;
  try
   checkcolorspace;
   masked:= (mask <> nil) and ((mask.kind = bmk_mono) {or (fpslevel >= psl_3)});
                                //color masks not implemented in postscript
   if masked then begin
    if (fpslevel >= psl_3) then begin
     cached:= not maskcopy and getimagecache(ick_4,source,sourcerect^,varname);
     if not cached then begin
      with tcanvas1(source).fdrawinfo do begin
       gdi_lock;
       if gui_pixmaptoimage(tsimplebitmap1(mask).handle,image,
                                     mask.canvas.gchandle) <> gde_ok then begin
        goto endlab;   
       end;
       gdi_unlock;
       if mask.kind = bmk_mono then begin
        convertmono(sourcerect^,image,ar2,maskrowbytes);
       end
       else begin
        if colorspace = cos_gray then begin
         convertgray(sourcerect^,image,ar2,maskrowbytes);
        end
        else begin
         convertrgb(sourcerect^,image,ar2,maskrowbytes);
        end;
       end;
       gui_freeimagemem(image.pixels);
       gdi_lock;
       if gui_pixmaptoimage(paintdevice,image,gc.handle) <> gde_ok then begin
        goto endlab;
       end;
       gdi_unlock;
      end;
      if mono{image.monochrome} then begin
       if colorspace = cos_gray then begin
        convertmonotogray(sourcerect^,image,ar3,rowbytes,
                   acolorforeground,acolorbackground);
       end
       else begin
        convertmonotorgb(sourcerect^,image,ar3,rowbytes,
                   acolorforeground,acolorbackground);
       end;
      end
      else begin
       if colorspace = cos_gray then begin
        convertgray(sourcerect^,image,ar3,rowbytes);
       end
       else begin
        convertrgb(sourcerect^,image,ar3,rowbytes);
       end;
      end;
      gui_freeimagemem(image.pixels);
      setlength(ar1,length(ar2)+length(ar3));
      po1:= pointer(ar1);
      po2:= pointer(ar2);
      po3:= pointer(ar3);
      for int1:= sourcerect^.cy - 1 downto 0 do begin
       system.move(po2^,po1^,maskrowbytes);
       inc(po1,maskrowbytes);
       inc(po2,maskrowbytes);
       system.move(po3^,po1^,rowbytes);
       inc(po1,rowbytes);
       inc(po3,rowbytes);
      end;
      rowbytes:= rowbytes + maskrowbytes;
      cached:= not maskcopy and setimagecache(ick_4,source,sourcerect^,varname,
                                                ar1,mask.canvas);
     end;
     mono:= false; //has been converted to color
     str1:= 'gsave ';
     if not cached then begin
      str1:= str1 + '/picstr '+inttostr(rowbytes)+' string def ';
     end;
     str1:= str1 + rectscalestring(destrect^) + nl;
     str1:= str1 + '/imdict '+imagedict+' def ';
     with sourcerect^ do begin
      str1:= str1 + '/madict  << /ImageType 1 /Width '+inttostr(size.cx)+
      ' /Height '+inttostr(size.cy)+' /ImageMatrix '+imagematrixstring(size)+nl;
      if mask.kind = bmk_mono then begin
       str1:= str1 + '/BitsPerComponent 1 /Decode [1 0] ';
      end
      else begin
       if colorspace = cos_gray then begin
        str1:= str1 + '/BitsPerComponent 8 /Decode [0 1] ';
       end
       else begin
        str1:= str1 + '/BitsPerComponent 1 /Decode [0 1 0 1 0 1] ';
       end;
      end;
     end;
     if al_intpol in alignment then begin
      str1:= str1 +  '/Interpolate true ';
     end;
     str1:= str1 + ' >> def'+nl+
     '<< /ImageType 3 /DataDict imdict /MaskDict madict /InterleaveType 2 >>'+nl;
     str1:= str1 + 'image';
    end
    else begin
     cached:= not maskcopy and getimagecache(ick_2,mask.canvas,sourcerect^,varname);
     gdi_lock;
     if not (createpattern(sourcerect^,destrect^,acolorbackground,acolorforeground,
          source,imagepatname) and 
           (cached or (gui_pixmaptoimage(tsimplebitmap1(mask).handle,image,
                                    mask.canvas.gchandle) = gde_ok))) then begin
      goto endlab;
     end;
     gdi_unlock;
     if not cached then begin
      convertmono(sourcerect^,image,ar1,rowbytes);
      gui_freeimagemem(image.pixels);
      cached:= not maskcopy and
                     setimagecache(ick_2,mask.canvas,sourcerect^,varname,ar1);
     end;
     str1:= 'gsave setpattern';
     if cached then begin
      str1:= str1 + ' /bo1 0 def ';
     end
     else begin
      str1:= str1 + ' /picstr ' + inttostr(rowbytes) + ' string def ';
     end;
     str1:= str1 + rectscalestring(destrect^) + nl;
     str1:= str1 + inttostr(sourcerect^.size.cx) + ' ' + 
                   inttostr(sourcerect^.size.cy);
     str1:= str1 + ' true ';
     str1:= str1 + imagematrixstring(sourcerect^.size)+nl;
     if cached then begin
      str1:= str1 + '{bo1 0 ne{()}{/b1 1 def '+varname+'}ifelse} ';
     end
     else begin
      str1:= str1 + '{currentfile picstr readhexstring pop} ';
     end;
     str1:= str1 + 'imagemask' + nl;
     streamwrite(str1);
     if cached then begin
      str1:= '/bo1 null def ';
     end
     else begin
      writebinhex(ar1);
      str1:= '/picstr null def '
     end;
     str1:= str1+'/'+imagepatname+' null def grestore'+nl;
     streamwrite(str1);
     exit;
    end;
   end
   else begin
    cached:= getimagecache(ick_1,source,sourcerect^,varname{,rowbytes});
    if not cached then begin
     with tcanvas1(source).fdrawinfo do begin
      gdi_lock;
      if gui_pixmaptoimage(paintdevice,image,gc.handle) <> gde_ok then begin
       goto endlab;
      end;
      gdi_unlock;
     end;
//     components:= 1;
     if mono{image.monochrome} then begin
      convertmono(sourcerect^,image,ar1,rowbytes);
     end
     else begin
      if colorspace = cos_gray then begin
       convertgray(sourcerect^,image,ar1,rowbytes);
      end
      else begin
//       components:= 3;
       convertrgb(sourcerect^,image,ar1,rowbytes);
      end;
     end;
     gui_freeimagemem(image.pixels);
     cached:= setimagecache(ick_1,source,sourcerect^,varname,
                                                ar1{,rowbytes});
    end;
    str1:= 'gsave ';
    if not cached then begin
     str1:= str1 + '/picstr '+inttostr(rowbytes)+' string def ';
    end;
    str1:= str1 + rectscalestring(destrect^) + nl;
    if mono{image.monochrome} then begin
     if acolorbackground <> cl_transparent then begin
      str1:= str1 + unityrectpath + nl + 
            setcolorstring(acolorbackground) + ' fill ';   
     end;
    end;
    if fpslevel >= psl_2 then begin
     str1:= str1 + imagedict;
     if mono{image.monochrome} then begin
      str1:= str1 + 'imagemask';
     end
     else begin
      str1:= str1 + 'image';
     end;
    end
    else begin
     if cached then begin
      str1:= str1 + '/bo1 0 def ';
     end;
     str1:= str1 + setcolorstring(acolorforeground) + nl;
     with sourcerect^ do begin
      str1:= str1 +
           inttostr(size.cx) + ' ' + inttostr(size.cy);
      if mono{image.monochrome} then begin
       str1:= str1 + ' true ';
      end
      else begin
       str1:= str1 + ' 8';
      end;
      str1:= str1 + imagematrixstring(size)+nl;
      if cached then begin
       str1:= str1 + '{bo1 0 ne{()}{/b1 1 def '+varname+'}ifelse} ';
      end
      else begin
       str1:= str1 + '{currentfile picstr readhexstring pop} ';
      end;
     end;
     if mono{image.monochrome} then begin
      str1:= str1 + 'imagemask';
     end
     else begin
      if colorspace = cos_gray then begin
       str1:= str1 + 'image';
      end
      else begin
       str1:= str1 + 'false 3 colorimage';
      end;
     end;
     if cached then begin
      str1:= str1 + ' /bo1 null def';
     end;
    end;
   end;
   streamwrite(str1+nl);
   if cached then begin
    str1:= '';
   end
   else begin
    writebinhex(ar1);
    str1:= '/picstr null def ';
   end;
   str1:= str1 + 'grestore';
   if masked then begin
    str1:= str1 + ' /imdict null def /madict null def ';
   end;
   streamwrite(str1+nl);
   exit;
endlab:
   gdi_unlock;
  finally
   addpoint1(destrect^.pos,origin); //map to origin
   if maskcopy then begin
    mask.free;
    mask:= maskbefore;
   end;
  end;
 end;
end;

procedure tpostscriptcanvas.endpage;
var
 int1: integer;
begin
 inherited;
 if active then begin
  for int1:= 0 to high(fimagecache) do begin
   freeimagecache(int1);
  end;
  streamwrite('showpage'+nl);
  inc(fps_pagenumber);
 end;
end;

procedure tpostscriptcanvas.beginpage;
var
 str1: string;
begin
 initgcvalues; //init state on every page, necessary for gv
 if active then begin
  str1:= ' '+inttostr(fps_pagenumber+1);
  streamwrite('%%Page:'+str1+str1+nl+
              '%%PageOrientation: '+pageorientations[printorientation]+nl);
  checkscale;
 end;
 inherited;
end;

function tpostscriptcanvas.registermap(const acodepage: integer): string;

 procedure defpage(const glyphnames: string);
 begin
  streamwrite('/'+result+' ['+nl+glyphnames+'] def'+nl,true);
 end;
 
var
 map1: unicodepagety;
 str1: string;
 int1,int2,int3: integer;
begin
 result:= '';
 for map1:= low(unicodepagety) to high(unicodepagety) do begin
  with encodings[map1] do begin
   if codepage = acodepage then begin
    result:= name;
    defpage(encodings[map1].glyphnames);
    break;
   end;
  end;
 end;
 if result = '' then begin
  result:= 'E'+hextostr(longword(acodepage),2);
  int3:= 256*acodepage;
  str1:= '';
  for int1:= 0 to 31 do begin
   for int2:= 0 to 7 do begin
    str1:= str1 + '/uni'+hextostr(longword(int3),4)+' ';
    inc(int3);
   end;
   if int1 = 31 then begin
    setlength(str1,length(str1)-1);  //remove last comma
   end;
   str1:= str1 + nl;
  end;
  defpage(str1);
 end;
end;

procedure tpostscriptcanvas.checkmap(const acodepage: integer);
begin
 if fmapnames[acodepage] = '' then begin
  fmapnames[acodepage]:= registermap(acodepage);
 end;
end;

procedure tpostscriptcanvas.updatescale;
begin
 inherited;
 checkscale;
end;

procedure tpostscriptcanvas.pscommand(const atext: string);
begin
 fdrawinfo.acolorforeground:= color;
 fdrawinfo.acolorbackground:= colorbackground;
 checkgcstate(changedmask);
 streamwrite(atext);
 initgcvalues;
end;

procedure tpostscriptcanvas.freeimagecache(const index: integer);
begin
 with fimagecache[index] do begin
  if source <> nil then begin
   streamwrite('/'+'picstr'+inttostr(index)+' null def'+nl);
                        //delete dict entry
   unregistergclink(source);
   if mask <> nil then begin
    unregistergclink(mask);
    mask:= nil;
   end;
   source:= nil;
   fimagecacheused:= fimagecacheused - bytecount;
  end;
 end;
 removeitem(fcacheorder,index);
end;

procedure tpostscriptcanvas.touchimagecache(const index: integer);
var
 int1: integer;
begin
 for int1:= high(fcacheorder) - 1 downto 0 do begin
  if fcacheorder[int1] = index then begin
   system.move(fcacheorder[int1+1],fcacheorder[int1],
                  (high(fcacheorder)-index)*sizeof(integer));
   fcacheorder[high(fcacheorder)]:= index;
  end;
 end;
end;

procedure tpostscriptcanvas.gcdestroyed(const sender: tcanvas);
var
 int1: integer;
begin
 for int1:= 0 to high(fimagecache) do begin
  with fimagecache[int1] do begin
   if (source = sender) or (mask = sender) then begin
    freeimagecache(int1);
    break;
   end;
  end;
 end;
end;

function tpostscriptcanvas.getimagecache(const akind: imagecachekindty;
               const asource: tcanvas;
               const asourcerect: rectty; out varname: string{;
               out arowbytes: integer}): boolean;
var
 int1: integer;
begin
 result:= false;
 for int1:= 0 to high(fimagecache) do begin
  with fimagecache[int1] do begin
   if (kind = akind) and (source = asource) and 
                                 rectisequal(sourcerect,asourcerect) then begin
    varname:= 'picstr'+inttostr(int1);
    result:= (statestamp = asource.statestamp) and 
              ((mask = nil) or (maskstatestamp = mask.statestamp));
    if not result then begin
     freeimagecache(int1);
    end
    else begin
     touchimagecache(int1);
    end;
   end;
  end;
 end;
end;
 
function tpostscriptcanvas.setimagecache(const akind: imagecachekindty;
               const asource: tcanvas;
               const asourcerect: rectty; out varname: string;
               const bytes: bytearty; {const arowbytes: integer;}
               const amask: tcanvas = nil): boolean;
var
 int1,int2: integer;
 str1: string;
begin
 result:= (fimagecachemaxitemsize > 0) and (high(bytes) < fimagecachemaxitemsize);
 if result then begin
  int1:= fimagecachesize - length(bytes);
  while (fimagecacheused > int1) do begin
   freeimagecache(fcacheorder[0]);
  end;
  int2:= length(fimagecache);
  for int1:= 0 to high(fimagecache) do begin
   if fimagecache[int1].source = nil then begin
    int2:= int1;
    break;
   end;
  end;
  if int2 = length(fimagecache) then begin
   setlength(fimagecache,int2 + 1);
  end;
  varname:= 'picstr'+inttostr(int2);
  additem(fcacheorder,int2);
  with fimagecache[int2] do begin
   kind:= akind;
   source:= asource;
   mask:= amask;
   sourcerect:= asourcerect;
   statestamp:= asource.statestamp;
   bytecount:= length(bytes);
//   rowbytes:= arowbytes;
   fimagecacheused:= fimagecacheused + bytecount;
  end;
  if asource <> nil then begin
   registergclink(asource);
//   tcanvas1(asource).registergclink(self);
  end;
  if amask <> nil then begin
   registergclink(amask);
//   tcanvas1(amask).registergclink(self);
  end;
  str1:='/'+varname+' '+inttostr(length(bytes))+' string def currentfile '+
           varname + ' readhexstring'+nl;
  streamwrite(str1);
  writebinhex(bytes);
  streamwrite('pop pop'+nl);
 end;
end;

procedure tpostscriptcanvas.setimagecachesize(const avalue: integer);
begin
 fimagecachesize:= avalue;
 if fimagecachemaxitemsize < avalue then begin
  fimagecachemaxitemsize:= avalue;
 end;
end;

procedure tpostscriptcanvas.setimagecachemaxitemsize(const avalue: integer);
begin
 fimagecachemaxitemsize:= avalue;
 if fimagecachesize < avalue then begin
  fimagecachesize:= avalue;
 end;
end;

{ tpostscriptprinter }

constructor tpostscriptprinter.create(aowner: tcomponent);
begin
 fcanvas:= tpostscriptcanvas.create(self,icanvas(self));
 inherited;
 options:= [pro_tempfile];
end;

function tpostscriptprinter.getcanvas: tpostscriptcanvas;
begin
 result:= tpostscriptcanvas(fcanvas);
end;

procedure tpostscriptprinter.gcneeded(const sender: tcanvas);
var
 gc1: gcty;
begin
 if not (sender is tpostscriptcanvas) then begin
  guierror(gue_invalidcanvas);
 end;
 with tpostscriptcanvas(sender) do begin
  fillchar(gc1,sizeof(gc1),0);
  gc1.kind:= bmk_rgb;
  gc1.handle:= invalidgchandle;
  gc1.drawingflags:= [df_highresfont];
  gc1.paintdevicesize:= getwindowsize;
  linktopaintdevice(ptrint(self),gc1,{getwindowsize,}nullpoint);
 end;
end;
{
function tpostscriptprinter.getmonochrome: boolean;
begin
 result:= false;
end;
}
function tpostscriptprinter.getkind: bitmapkindty;
begin
 result:= bmk_rgb;
end;
procedure tpostscriptprinter.getcanvasimage(const bgr: boolean;
               var aimage: maskedimagety);
begin
 //dummy
end;

initialization
 gdifuncs:= gui_getgdifuncs;
 gdifunctions:= gdifuncs^; //default
 gdifunctions[gdf_destroygc]:= {$ifdef FPC}@{$endif}gdi_destroygc;
 gdifunctions[gdf_changegc]:= {$ifdef FPC}@{$endif}gdi_changegc;
 gdifunctions[gdf_drawlines]:= {$ifdef FPC}@{$endif}gdi_drawlines;
 gdifunctions[gdf_drawlinesegments]:= {$ifdef FPC}@{$endif}gdi_drawlinesegments;
 gdifunctions[gdf_drawellipse]:= {$ifdef FPC}@{$endif}gdi_drawellipse;
 gdifunctions[gdf_drawarc]:= {$ifdef FPC}@{$endif}gdi_drawarc;
 gdifunctions[gdf_fillrect]:= {$ifdef FPC}@{$endif}gdi_fillrect;
 gdifunctions[gdf_fillellipse]:= {$ifdef FPC}@{$endif}gdi_fillellipse;
 gdifunctions[gdf_fillarc]:= {$ifdef FPC}@{$endif}gdi_fillarc;
 gdifunctions[gdf_fillpolygon]:= {$ifdef FPC}@{$endif}gdi_fillpolygon;
 gdifunctions[gdf_drawstring16]:= {$ifdef FPC}@{$endif}gdi_drawstring16;
 gdifunctions[gdf_setcliporigin]:= {$ifdef FPC}@{$endif}gdi_setcliporigin;

// gdifunctions[gdf_createemptyregion]:= {$ifdef FPC}@{$endif}gdi_createemptyregion;
// gdifunctions[gdf_createrectregion]:= {$ifdef FPC}@{$endif}gdi_createrectregion;
// gdifunctions[gdf_createrectsregion]:= {$ifdef FPC}@{$endif}gdi_createrectsregion;
// gdifunctions[gdf_destroyregion]:= {$ifdef FPC}@{$endif}gdi_destroyregion;
// gdifunctions[gdf_copyregion]:= {$ifdef FPC}@{$endif}gdi_copyregion;
// gdifunctions[gdf_moveregion]:= {$ifdef FPC}@{$endif}gdi_moveregion;
// gdifunctions[gdf_regionisempty]:= {$ifdef FPC}@{$endif}gdi_regionisempty;
// gdifunctions[gdf_regionclipbox]:= {$ifdef FPC}@{$endif}gdi_regionclipbox;
// gdifunctions[gdf_regsubrect]:= {$ifdef FPC}@{$endif}gdi_regsubrect;
// gdifunctions[gdf_regsubregion]:= {$ifdef FPC}@{$endif}gdi_regsubregion;
// gdifunctions[gdf_regaddrect]:= {$ifdef FPC}@{$endif}gdi_regaddrect;
// gdifunctions[gdf_regaddregion]:= {$ifdef FPC}@{$endif}gdi_regaddregion;
// gdifunctions[gdf_regintersectrect]:= {$ifdef FPC}@{$endif}gdi_regintersectrect;
// gdifunctions[gdf_regintersectregion]:= {$ifdef FPC}@{$endif}gdi_regintersectregion;

 gdifunctions[gdf_copyarea]:= {$ifdef FPC}@{$endif}gdi_copyarea;

// gdifunctions[gdf_fonthasglyph]:= {$ifdef FPC}@{$endif}gdi_fonthasglyph;
// gdifunctions[gdf_getfont]:= {$ifdef FPC}@{$endif}gdi_getfont;
// gdifunctions[gdf_getfonthighres]:= {$ifdef FPC}@{$endif}gdi_getfonthighres;
// gdifunctions[gdf_freefontdata]:= {$ifdef FPC}@{$endif}gdi_freefontdata;
// gdifunctions[gdf_gettext16width]:= {$ifdef FPC}@{$endif}gdi_gettext16width;
// gdifunctions[gdf_getchar16widths]:= {$ifdef FPC}@{$endif}gdi_getchar16widths;
// gdifunctions[gdf_gdi_getfontmetrics]:= {$ifdef FPC}@{$endif}gdi_getfontmetrics

 {$if high(gdifuncty) <> gdf_getfontmetrics}
  {$error missing gdi function}
 {$ifend}
end.
