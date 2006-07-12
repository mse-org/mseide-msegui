{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msepostscriptprinter;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface

uses
 msegraphics,mseclasses,classes,msegraphutils,msestream,msestrings,msetypes,
 msedrawtext,mserichstring,mseprinter;

type
  
 tpostscriptcanvas = class;

 tpostscriptprinter = class(tprinter,icanvas)
  private
   function getcanvas: tpostscriptcanvas;
   //icanvas
   procedure gcneeded(const sender: tcanvas);
   function getmonochrome: boolean;
   function getsize: sizety;
  protected
   fsize: sizety; 
  public
   constructor create(aowner: tcomponent); override;
   property canvas: tpostscriptcanvas read getcanvas;
  published
 end;

 psfontinfoty = record
  handle: fontnumty;  
  namenum: integer;
  size: integer;
  scalestring: string;
  codepages: integerarty;
 end; 
 psfontinfoarty = array of psfontinfoty;

 psalignty = (pa_center,pa_lefttop,pa_top,pa_righttop,pa_right,
                pa_rightbottom,pa_bottom,pa_leftbottom,pa_left);

 tpostscriptcanvas = class(tprintercanvas)
  private
   ffonts: psfontinfoarty;
   ffontnames: stringarty;
   fps_pagenumber: integer;
   fmapnames: array[0..255] of string;
   factfont,factcodepage: integer;
   fstarted: boolean;
  protected
   function getgdifuncs: pgdifunctionaty; override;
   procedure updatescale; override;
   procedure initgcstate; override;
   procedure finalizegcstate; override;
   procedure checkscale;
   function encodefontname(const namenum,codepage: integer): string;
   function checkfont(const afont: fontnumty; const acodepage: integer): integer;
               //returns index in ffonts
   procedure selectfont(const afont: fontnumty; const acodepage: integer);
   procedure definefont(const adata: fontnumty; const acodepage: integer);
   procedure setpslinewidth(const avalue: integer);
   function posstring(const apos: pointty): string;
   function getcolorstring(const acolor: colorty): string;
   function setcolorstring(const acolor: colorty): string;
   function psencode(const text: pchar; const count: integer): string;
   function getshowstring(const avalue: pmsechar; const count: integer;
                   fontneeded: boolean = false; const acolor: colorty = cl_none): string;
   procedure ps_drawstring16;
   procedure ps_destroygc(var drawinfo: drawinfoty);
   procedure ps_changegc(var drawinfo: drawinfoty);
   procedure ps_drawlines(var drawinfo: drawinfoty);
   procedure ps_drawlinesegments(var drawinfo: drawinfoty);
   procedure ps_drawpoly(const points: ppointty; const lastpoint: integer;
                     const closed: boolean);
   procedure textout(const text: richstringty; const dest: rectty;
                        const flags: textflagsty; const tabdist: real); override;
   procedure beginpage; override;
   procedure endpage; override;
   function registermap(const acodepage: integer): string;
                 //returns mapname ('E00' for latin 1)  
   procedure checkmap(const acodepage: integer);
  public
 end;
 
implementation
uses
 msegui,mseguiglob,msesys,sysutils,msedatalist,mseformatstr,mseunicodeps;
 
const
 nl = lineend;  
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

'/sf {'+nl+                     //select font: alias,scale->
' exch findfont exch scalefont dup /FontMatrix get exch dup /FontBBox get'+nl+
//matrix,font,bbox
' aload pop'+ //matrix,font,llx,lly,urx,ury
' 5 index'+   //matrix,font,llx,lly,urx,ury,matrix
' transform'+ //matrix,font,llx,lly,urx',ury'
' /asc exch def pop'+ //matrix,font,llx,lly
' 3 index'+   //matrix,font,llx,lly,matrix
' transform'+ //matrix,font,llx',lly'
' -1 mul'+nl+' /desc exch def pop'+ //matrix,font
' setfont pop'+nl+
'} bind def'+nl+
              
'/w {'+nl+    //[[text,font,scale,color],...]-> cx
              //[[text,font,scale],...]-> cx or
              //[[text],...]-> cx
              //calc stringwidth
' 0 exch'+
' {dup length 4 eq {0 3 getinterval} if'+nl+  //remove color
'  dup length 3 eq'+ //array,arraylength = 3
 ' {aload pop selectfont}'+
 ' {aload pop}'+
  ' ifelse stringwidth pop add'+
  '} forall'+nl+
'} bind def'+nl+

'/s {'+nl+    //[[text,font,scale,color],...]-> cx
              //[[text,font,scale],...]-> or
              //[[text],...]-> cx
              //select font, print text, ...
' {dup length 4 eq '+
   '{dup 3 get '+ //[text,font,scale,color],[color]
    'dup length 3 eq '+ //[text,font,scale,color],[color],length = 3
    '{aload pop setrgbcolor} '+
    '{aload pop setgray} '+
    'ifelse '+          //[text,font,scale,color] 
    '0 3 getinterval'+  //[text,font,scale] remove color
   '} if'+nl+  
'  dup length 3 eq'+ //array,arraylength = 3
 ' {aload pop selectfont}'+
 ' {aload pop}'+
  ' ifelse show'+
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
' currentpoint /ay exch def /ax exch def'+ //backup for underline
                       //text,llx,lly,urx
' pop pop pop s'+nl+
'} bind def'+nl+

'/sr {'+ //print right text: text,llx,lly,urx,ury->
' cy'+          //text,llx,lly,urx,centeredy 
' exch'+             //%text,llx,lly,newy,urx
' 4 index'+nl+       //%text,llx,lly,newy,urx,text
' w'+            //%text,llx,lly,newy,urx,cx
' sub'+          //%text,llx,lly,newy,urx-cx
' exch moveto'+      //%text,llx,lly
' currentpoint /ay exch def /ax exch def'+ //%text,llx,lly
' pop pop s'+nl+
'} bind def'+nl+

'/sc {'+nl+     //%print center text: text,llx,lly,urx,ury ->
' cy'+          //text,llx,lly,urx,centeredy 
' 4 index'+     //%text,llx,lly,urx,centeredy,text
' w'+           //%text,llx,lly,urx,centeredy,cx
' 4 index'+     //%text,llx,lly,urx,centeredy,cx,llx
' 3 index'+     //%text,llx,lly,urx,centeredy,cx,llx,urx
' exch sub'+    //%text,llx,lly,urx,centeredy,cx,urx-llx
' exch sub'+    //%text,llx,lly,urx,centeredy,urx-llx-cx 
' 2 div'+       //%text,llx,lly,urx,centeredy,(urx-llx-cx)/2
' 4 index add'+nl+ //%text,llx,lly,urx,centeredy,(urx-llx-cx)/2+llx
' exch'+        //%text,llx,lly,urx,newx,centeredy
' moveto'+nl+   //%text,llx,lly,urx
' currentpoint /ay exch def /ax exch def'+ //%text,llx,lly,urx
' pop pop pop s'+nl+
' } bind def'+nl+

'/slb {'+nl+ //print lefttop text,llx,lly,urx,ury ->
' pop pop'+  //text,llx,lly
' desc add'+ //text,llx,lly+desc
' moveto currentpoint /ay exch def /ax exch def'+ //backup for underline
             //text
' s'+nl+
'} bind def'+nl+

'/srb {'+nl+    //print rightbottom text: text,llx,lly,urx,ury ->
' 4 index'+     //%text,llx,lly,urx,ury,text
' w'+           //%text,llx,lly,urx,ury,cx
' 2 index'+     //%text,llx,lly,urx,ury,cx,urx
' exch'+        //%text,llx,lly,urx,ury,urx,cx
' sub'+         //%text,llx,lly,urx,ury,urx-cx
' 3 index'+     //%text,llx,lly,urx,ury,urx-cx,lly
' desc add'+    //%text,llx,lly,urx,ury,urx-cx,lly+desc
' moveto'+nl+
' currentpoint /ay exch def /ax exch def'+ //%text,llx,lly,urx,ury
' pop pop pop pop s'+
'} bind def'+nl+

'/srt {'+nl+ //print righttoptext: text,llx,lly,urx,ury ->
' 4 index'+      //%text,llx,lly,urx,ury,text
' w'+            //%text,llx,lly,urx,ury,cx
' 2 index'+    //%text,llx,lly,urx,ury,cx,urx
' exch'+       //%text,llx,lly,urx,ury,urx,cx
' sub'+        //%text,llx,lly,urx,ury,urx-cx
' exch'+       //%text,llx,lly,urx,urx-cx,ury
' asc sub'+    //%text,llx,lly,urx,urx-cx,ury-asc
' moveto'+nl+
' currentpoint /ay exch def /ax exch def'+ //%text,llx,lly,urx
' pop pop pop s'+
'} bind def'+nl+
 
'/st {'+nl+     //%print top text: text,llx,lly,urx,ury ->
' 4 index'+     //%text,llx,lly,urx,ury,text
' w'+           //%text,llx,lly,urx,ury,cx
' 4 index'+     //%text,llx,lly,urx,ury,cx,llx
' 3 index'+     //%text,llx,lly,urx,ury,cx,llx,urx
' exch sub'+    //%text,llx,lly,urx,ury,cx,urx-llx
' exch sub'+    //%text,llx,lly,urx,ury,urx-llx-cx 
' 2 div'+       //%text,llx,lly,urx,ury,(urx-llx-cx)/2
' 4 index add'+nl+//%text,llx,lly,urx,ury,(urx-llx-cx)/2+llx
' exch'+        //%text,llx,lly,urx,newx,ury
' asc sub'+     //%text,llx,lly,urx,newx,ury-asc
' moveto'+      //%text,llx,lly,urx
' currentpoint /ay exch def /ax exch def'+ //%text,llx,lly,urx
' pop pop pop s'+nl+
'} bind def'+nl+

'/sb {'+nl+     //%print bottom text: text,llx,lly,urx,ury ->
' 4 index'+     //%text,llx,lly,urx,ury,text
' w'+           //%text,llx,lly,urx,ury,cx
' 4 index'+     //%text,llx,lly,urx,ury,cx,llx
' 3 index'+     //%text,llx,lly,urx,ury,cx,llx,urx
' exch sub'+    //%text,llx,lly,urx,ury,cx,urx-llx
' exch sub'+    //%text,llx,lly,urx,ury,urx-llx-cx 
' 2 div'+       //%text,llx,lly,urx,ury,(urx-llx-cx)/2
' 4 index add'+nl+ //%text,llx,lly,urx,ury,(urx-llx-cx)/2+llx
' 3 index'+     //%text,llx,lly,urx,ury,newx,lly
' desc add'+    //%text,llx,lly,urx,ury,newx,lly+desc
' moveto'+      //%text,llx,lly,urx,ury
' currentpoint /ay exch def /ax exch def'+ //%text,llx,lly,urx,ury
' pop pop pop pop s'+nl+
'} bind def'+nl+

'/ul {'+nl+ //%underline
' gsave'+
' desc 4 div setlinewidth'+
' 0 setlinecap'+
' [] 0 setdash'+
' currentpoint'+    //%x,y
' desc 2 div sub'+nl+  //%x,y-desc/2
' dup'+             //%x,newy,newy
' 2 index exch'+    //%x,newy,x,newy  
' moveto'+          //%x,newy
' ax exch'+         //%x,ax,newy
' lineto stroke'+   //%x
' pop'+
' grestore'+
'} bind def'+nl+

'/so {'+ //%strokeout
' gsave'+
' desc 4 div setlinewidth'+
' 0 setlinecap'+
' [] 0 setdash'+
' currentpoint'+nl+  //%x,y
' asc desc add 2 div add desc sub'+ //%x,y+asc+desc/2-desc
' dup'+             //%x,newy,newy
' 2 index exch'+    //%x,newy,x,newy  
' moveto'+          //%x,newy
' ax exch'+         //%x,ax,newy
' lineto stroke'+   //%x
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
 postscriptgcty = record
  canvas: tpostscriptcanvas;
  res: array[1..23] of cardinal;
 end;

 
procedure gui_destroygc(var drawinfo: drawinfoty);
begin
 try
  postscriptgcty(drawinfo.gc.platformdata).canvas.ps_destroygc(drawinfo);
 except //trap for stream write errors
 end;
end;
 
procedure gui_changegc(var drawinfo: drawinfoty);
begin
 postscriptgcty(drawinfo.gc.platformdata).canvas.ps_changegc(drawinfo);
end;

procedure gui_drawlines(var drawinfo: drawinfoty);
begin
 postscriptgcty(drawinfo.gc.platformdata).canvas.ps_drawlines(drawinfo);
end;

procedure gui_drawlinesegments(var drawinfo: drawinfoty);
begin
 postscriptgcty(drawinfo.gc.platformdata).canvas.ps_drawlinesegments(drawinfo);
end;

procedure gui_drawellipse(var drawinfo: drawinfoty);
begin
 gdierror(gde_notimplemented);
end;

procedure gui_drawarc(var drawinfo: drawinfoty);
begin
 gdierror(gde_notimplemented);
end;

procedure gui_fillrect(var drawinfo: drawinfoty);
begin
 gdierror(gde_notimplemented);
end;

procedure gui_fillelipse(var drawinfo: drawinfoty);
begin
 gdierror(gde_notimplemented);
end;

procedure gui_fillpolygon(var drawinfo: drawinfoty);
begin
 gdierror(gde_notimplemented);
end;

procedure gui_drawstring16(var drawinfo: drawinfoty);
begin
 postscriptgcty(drawinfo.gc.platformdata).canvas.ps_drawstring16;
end;

procedure gui_setcliporigin(var drawinfo: drawinfoty);
begin
// gdierror(gde_notimplemented);
end;

procedure gui_createemptyregion(var drawinfo: drawinfoty);
begin
 gdierror(gde_notimplemented);
end;

procedure gui_createrectregion(var drawinfo: drawinfoty);
begin
 gdierror(gde_notimplemented);
end;

procedure gui_createrectsregion(var drawinfo: drawinfoty);
begin
 gdierror(gde_notimplemented);
end;

procedure gui_destroyregion(var drawinfo: drawinfoty);
begin
 with drawinfo.regionoperation do begin
  if source <> 0 then begin;
   gdierror(gde_notimplemented);
  end;
 end;
end;

procedure gui_copyregion(var drawinfo: drawinfoty);
begin
 gdierror(gde_notimplemented);
end;

procedure gui_moveregion(var drawinfo: drawinfoty);
begin
 gdierror(gde_notimplemented);
end;

procedure gui_regionisempty(var drawinfo: drawinfoty);
begin
 gdierror(gde_notimplemented);
end;

procedure gui_regionclipbox(var drawinfo: drawinfoty);
begin
 gdierror(gde_notimplemented);
end;

procedure gui_regsubrect(var drawinfo: drawinfoty);
begin
 gdierror(gde_notimplemented);
end;

procedure gui_regsubregion(var drawinfo: drawinfoty);
begin
 gdierror(gde_notimplemented);
end;

procedure gui_regaddrect(var drawinfo: drawinfoty);
begin
 gdierror(gde_notimplemented);
end;

procedure gui_regaddregion(var drawinfo: drawinfoty);
begin
 gdierror(gde_notimplemented);
end;

procedure gui_regintersectrect(var drawinfo: drawinfoty);
begin
 gdierror(gde_notimplemented);
end;

procedure gui_regintersectregion(var drawinfo: drawinfoty);
begin
 gdierror(gde_notimplemented);
end;
   
const
 gdifunctions: gdifunctionaty = (
   {$ifdef FPC}@{$endif}gui_destroygc,
   {$ifdef FPC}@{$endif}gui_changegc,
   {$ifdef FPC}@{$endif}gui_drawlines,
   {$ifdef FPC}@{$endif}gui_drawlinesegments,
   {$ifdef FPC}@{$endif}gui_drawellipse,
   {$ifdef FPC}@{$endif}gui_drawarc,
   {$ifdef FPC}@{$endif}gui_fillrect,
   {$ifdef FPC}@{$endif}gui_fillelipse,
   {$ifdef FPC}@{$endif}gui_fillpolygon,
//   {$ifdef FPC}@{$endif}gui_drawstring,
   {$ifdef FPC}@{$endif}gui_drawstring16,
   {$ifdef FPC}@{$endif}gui_setcliporigin,
   {$ifdef FPC}@{$endif}gui_createemptyregion,
   {$ifdef FPC}@{$endif}gui_createrectregion,
   {$ifdef FPC}@{$endif}gui_createrectsregion,
   {$ifdef FPC}@{$endif}gui_destroyregion,
   {$ifdef FPC}@{$endif}gui_copyregion,
   {$ifdef FPC}@{$endif}gui_moveregion,
   {$ifdef FPC}@{$endif}gui_regionisempty,
   {$ifdef FPC}@{$endif}gui_regionclipbox,
   {$ifdef FPC}@{$endif}gui_regsubrect,
   {$ifdef FPC}@{$endif}gui_regsubregion,
   {$ifdef FPC}@{$endif}gui_regaddrect,
   {$ifdef FPC}@{$endif}gui_regaddregion,
   {$ifdef FPC}@{$endif}gui_regintersectrect,
   {$ifdef FPC}@{$endif}gui_regintersectregion
 );

function psrealtostr(const avalue: real): string;
begin
 result:= formatfloatmse(avalue,'0.000');
end;

{ tpostscriptcanvas }

function tpostscriptcanvas.getgdifuncs: pgdifunctionaty;
begin
 result:= @gdifunctions;
end;

procedure tpostscriptcanvas.checkscale;
begin
 if fstarted then begin
  fstream.write('initmatrix ');
  if printorientation = pao_landscape then begin
   fstream.write(' 90 rotate');
  end;
  fstream.writeln('');
 end;
end;

procedure tpostscriptcanvas.initgcstate;
begin
 updatescale;
 fps_pagenumber:= 0;
 ffonts:= nil;
 ffontnames:= nil;
 finalize(fmapnames);
 with postscriptgcty(fdrawinfo.gc.platformdata) do begin
  canvas:= self;
 end;
 inherited;
 fstream.write(
'%!PS-Adobe-3.0'+nl+
'%%BoundingBox: '+inttostr(fboundingbox.left)+' '+
                  inttostr(fboundingbox.bottom)+' '+
                  inttostr(fboundingbox.right)+' '+
                  inttostr(fboundingbox.top)+nl+
'%%Creator: '+application.applicationname+nl+
'%%Title: '+ftitle+nl+
'%%Pages: (atend)'+nl+
'%%PageOrder: Ascend'+nl+
 preamble);
 fstarted:= true;
 beginpage;
end;

procedure tpostscriptcanvas.finalizegcstate;
begin
 fstarted:= false;
 inherited;
end;

function tpostscriptcanvas.encodefontname(const namenum,codepage: integer): string;
begin
 result:= '/F' + hextostr(codepage,2)+inttostr(namenum)+' ';
end;

procedure tpostscriptcanvas.definefont(const adata: fontnumty; const acodepage: integer);
var
 str1: string;
 int1,int2: integer;
begin
 with getfontdata(adata)^ do begin
  str1:= realfontname(name);
  if str1 = '' then begin
   str1:= 'Helvetica';
  end
  else begin
   str1:= psencode(pchar(str1),length(str1));
  end;
  if style * [fs_bold,fs_italic] <> [] then begin
   str1:= str1 + '-';
   if fs_bold in style then begin
    str1:= str1 + 'Bold';
   end;
   if fs_italic in style then begin
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
   fstream.write(encodefontname(int2,acodepage)+fmapnames[acodepage]+' ('+str1+') rf' + nl);
            //register font
  end;
  setlength(ffonts,high(ffonts)+2);
  with ffonts[high(ffonts)] do begin
   handle:= adata;
   namenum:= int2;
   if height = 0 then begin
    size:= round(defaultfontheight*fprinter.ppmm);
   end
   else begin
    size:= height;
   end;
   scalestring:= psrealtostr((size / fprinter.ppmm)*mmtoprintscale);
   additem(codepages,acodepage);
  end;
 end;
end;

function tpostscriptcanvas.checkfont(const afont: fontnumty; const acodepage: integer): integer;
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
    fstream.write(encodefontname(namenum,acodepage)+fmapnames[acodepage]+
           ' ('+ffontnames[namenum]+') rf' + nl);
            //register font
    additem(codepages,acodepage);
   end;
  end;
 end;
 result:= int2;
 factfont:= int2;
 factcodepage:= acodepage;
end;

procedure tpostscriptcanvas.selectfont(const afont: fontnumty; const acodepage: integer);
begin
 checkfont(afont,acodepage);
 with ffonts[factfont] do begin
  fstream.write(encodefontname(namenum,acodepage)+scalestring+' sf'+nl);
 end;
end;

procedure tpostscriptcanvas.ps_destroygc(var drawinfo: drawinfoty);
begin
 endpage;
 fstream.write(
  '%%Pages: '+inttostr(fps_pagenumber)+nl);
end;

procedure tpostscriptcanvas.ps_changegc(var drawinfo: drawinfoty);
var
 str1: string;
 int1,int2: integer;
begin
 with drawinfo,gcvalues^ do begin
  if gvm_dashes in mask then begin
   int2:= length(lineinfo.dashes);
   if int2 > 0 then begin
    if lineinfo.dashes[int2] = #0 then begin
     dec(int2);
    end;
    str1:= '[';
    for int1:= 1 to int2 do begin
     str1:= str1 + psrealtostr(mmtoprintscale*(byte(lineinfo.dashes[int1])/10))+' ';
    end;
    str1:= str1+'] 0 setdash'+nl;
    fstream.write(str1);
   end;
  end;
  if gvm_foregroundcolor in mask then begin
   fstream.write(setcolorstring(aforegroundcolor)+nl);
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
   fstream.write(str1+' setlinecap'+nl);
  end;
  if gvm_joinstyle in mask then begin
   case lineinfo.joinstyle of
    js_round: str1:= '1';
    js_bevel: str1:= '2';
    else str1:= '0'; //js_miter
   end;
   fstream.write(str1+' setlinejoin'+nl);
  end;
 end;
end;

function tpostscriptcanvas.posstring(const apos: pointty): string;
begin
 result:= 
  psrealtostr(apos.x*fgcscale+foriginx)+' '+
  psrealtostr(foriginy-apos.y*fgcscale);
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
   (po1+int2)^:= '\';             //octal  
   (po1+int2+3)^:= char((byte(ch1) and $07) + ord('0'));
   ch1:= char(byte(ch1) shr 3);
   (po1+int2+2)^:= char((byte(ch1) and $07) + ord('0'));
   ch1:= char(byte(ch1) shr 3);
   (po1+int2+1)^:= char((byte(ch1) and $03) + ord('0'));
   inc(int2,3);
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
          const acolor: colorty = cl_none): string;
var
 int1: integer;
 wo1,wo2: word;
 po1,po2: pchar;
 
 procedure pushsubstring;
 begin
  result:= result + '[('+psencode(po2,po1-po2)+')';
  if fontneeded then begin
   with ffonts[factfont] do begin
    result:= result + ' '+encodefontname(namenum,factcodepage) + scalestring;
   end;
  end;
  if acolor <> cl_none then begin
   result:= result+'['+getcolorstring(acolor)+']';
  end;
  result:= result +']';
  po1:= po2;
 end;
 
begin
 if acolor <> cl_none then begin
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
   fstream.write(posstring(pos^)+' moveto ['+getshowstring(text,count)+'] s'+nl);
  end;
 end;
end;

procedure tpostscriptcanvas.textout(const text: richstringty; const dest: rectty;
         const flags: textflagsty; const tabdist: real);
const
 mask: textflagsty = [tf_xcentered,tf_right,tf_ycentered,tf_bottom];
var
 str1: string;
 int1,int2,int3: integer;
 co1: colorty;
 colorchanged: boolean;
 
begin
 if not active then begin
  exit;
 end;
 colorchanged:= false;
 str1:= '['; 
 if (text.format = nil) or (text.text = '') then begin
  str1:= str1 + getshowstring(pmsechar(text.text),length(text.text))+'] ';
 end
 else begin
  gcfonthandle1:= 0; //invalid after print
  with text.format[0] do begin
   if index > 0 then begin
    str1:= str1 + getshowstring(pmsechar(pointer(text.text)),index);
   end;
  end;
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
    font.style:= style.fontstyle;
    checkfont(font.handle,(word(text.text[int2]) and $ff00) shr 8);
    int2:= int3 - index;
    if int2 > 0 then begin
     if ni_fontcolor in newinfos then begin
      if style.fontcolor = nil then begin
       co1:= font.color;
       colorchanged:= false;
      end
      else begin
       co1:= style.fontcolor^;
       colorchanged:= true;
      end;
     end
     else begin
      co1:= cl_none;
     end;
     str1:= str1 + getshowstring(pmsechar(pointer(text.text))+index,int2,true,co1);
    end;
   end;   
  end;
  str1:= str1 + '] ';
 end;
 if tabdist = 0 then begin
  str1:= str1 + posstring(makepoint(dest.x,dest.y+dest.cy))+' '+     //lower left
                posstring(makepoint(dest.x+dest.cx,dest.y))+ ' ';  //upper right
 end
 else begin
  if tabdist < 0 then begin //last pos
   str1:= str1 + 'currentpoint pop '; //oldx (llx)
  end
  else begin //defaulttab
   str1:= str1 + psrealtostr(foriginx)+' '+psrealtostr(tabdist) + ' tab ';
                 //tabbedx (llx)
  end;
  str1:= str1 + psrealtostr(foriginy-(dest.y+dest.cy)*fgcscale)+
                      //llx,lly
   ' 1 index '+       //llx,lly,urx
   psrealtostr(foriginy-(dest.y)*fgcscale)+' '; //llx,lly,urx,ury
 end;
 str1:= str1+alignmentsubs[
       tftopa[{$ifdef FPC}longword{$else}word{$endif}(flags) and
       {$ifdef FPC}longword{$else}word{$endif}(mask)]];
 if fs_underline in font.style then begin
  str1:= str1 + ' ul';
 end;
 if fs_strikeout in font.style then begin
  str1:= str1 + ' so';
 end;
 if colorchanged then begin
  str1:= str1 + ' '+setcolorstring(font.color);
 end;
 fstream.write(str1+nl);
end;

procedure tpostscriptcanvas.setpslinewidth(const avalue: integer);
var
 rea1: real;
begin
 if avalue = 0 then begin
  rea1:= nulllinewidth;
 end
 else begin
  rea1:= (avalue/fprinter.ppmm) * mmtoprintscale;
 end;
 fstream.write(psrealtostr(rea1)+' setlinewidth'+nl);
end;

procedure tpostscriptcanvas.ps_drawpoly(const points: ppointty; 
             const lastpoint: integer; const closed: boolean);
var
 int1: integer;
 str1: string;
begin
 if active then begin
  str1:= 'newpath '+ posstring(points^) + ' moveto';
  for int1:= 1 to lastpoint do begin
   str1:= str1 + ' '+posstring(ppointaty(points)^[int1])+' lineto';
  end;
  if closed then begin
   str1:= str1 + ' closepath';
  end;
  if (length(dashes) > 0) and (dashes[length(dashes)] = #0) then begin
   str1:= str1 + ' gsave [] 0 setdash ' + setcolorstring(fdrawinfo.abackgroundcolor) +
             ' stroke grestore'
   
  end;
  str1:= str1 + ' stroke'+nl;
  fstream.write(str1);
 end;
end;

procedure tpostscriptcanvas.ps_drawlines(var drawinfo: drawinfoty);
begin
 with drawinfo.points do begin
  ps_drawpoly(points,count-1,closed);
 end;
end;

procedure tpostscriptcanvas.ps_drawlinesegments(var drawinfo: drawinfoty);
var
 int1: integer;
begin
 with drawinfo.points do begin
  for int1:= 0 to count div 2 - 1 do begin
   ps_drawpoly(points,1,false);
   inc(points,2);
  end;
 end;
end;

procedure tpostscriptcanvas.endpage;
begin
 inherited;
 if active then begin
  fstream.write('showpage'+nl);
  inc(fps_pagenumber);
 end;
end;

procedure tpostscriptcanvas.beginpage;
var
 str1: string;
begin
 if active then begin
  str1:= ' '+inttostr(fps_pagenumber+1);
  fstream.write('%%Page:'+str1+str1+nl);
  checkscale;
 end;
 inherited;
end;

function tpostscriptcanvas.registermap(const acodepage: integer): string;

 procedure defpage(const avalue: encodingty);
 begin
  with avalue do begin
   fstream.write('/'+result+' ['+nl+glyphnames+'] def'+nl);
  end;
 end;
 
var
 map1: unicodepagety;
begin
 result:= '';
 for map1:= low(unicodepagety) to high(unicodepagety) do begin
  with encodings[map1] do begin
   if codepage = acodepage then begin
    result:= name;
    defpage(encodings[map1]);
    break;
   end;
  end;
 end;
 if result = '' then begin
  result:= undefmap.name;
  defpage(undefmap);
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

{ tpostscriptprinter }

constructor tpostscriptprinter.create(aowner: tcomponent);
begin
 fcanvas:= tpostscriptcanvas.create(self,icanvas(self));
 inherited;
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
  if fstream = nil then begin
   guierror(gue_invalidstream);
  end;
  fillchar(gc1,sizeof(gc1),0);
  gc1.handle:= cardinal(invalidgchandle);
  linktopaintdevice(ptrint(self),gc1,makesize(round(pa_width*fprinter.ppmm),
                       round(pa_height*fprinter.ppmm)),nullpoint);
 end;
end;

function tpostscriptprinter.getmonochrome: boolean;
begin
 result:= false;
end;

function tpostscriptprinter.getsize: sizety;
begin
 result:= fsize;
end;

end.
