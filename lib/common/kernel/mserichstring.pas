{ MSEgui Copyright (c) 1999-2017 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mserichstring;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 SysUtils,msetypes,msekeyboard,mseevent,msedatalist,msegraphutils,
 classes,mclasses,msestrings;

const
 fsboldmask = $01;
 fsitalicmask = $02;
 fsunderlinemask = $04;
 fsstrikeoutmask = $08;

type
 newinfoty = (ni_bold=ord(fs_bold),ni_italic=ord(fs_italic),
              ni_underline=ord(fs_underline),ni_strikeout=ord(fs_strikeout),
              ni_selected=ord(fs_selected),ni_blank=ord(fs_blank),
              //same order as in fontstylety
              ni_fontcolor,ni_colorbackground,ni_delete);
 newinfosty = set of newinfoty;

const
 fonthandleflags = [ni_bold,ni_italic];
 fontlayoutflags = [ni_bold,ni_italic,ni_blank];
 fontstyleflags = [ni_bold,ni_italic,ni_underline,ni_strikeout,ni_selected,
                   ni_blank];

type
 charstylety = record
  fontcolor,colorbackground: colorty; //bits inversed, 0 -> not set
  fontstyle: fontstylesty;
 end;
 pcharstylety = ^charstylety;

 charstylearty = array of charstylety;

 formatinfoty = record
  index: integer;            //0-> from first char
  newinfos: newinfosty;
  style: charstylety;
 end;

 pformatinfoty = ^formatinfoty;
 formatinfoarty = array of formatinfoty;
 pformatinfoarty = ^formatinfoarty;

 richflagty = (rf_noparagraph);
 richflagsty = set of richflagty;
 
 richstringty = record
  text: msestring;
  format: formatinfoarty;
  flags: richflagsty;
 end;

 prichstringty = ^richstringty;
 richstringarty = array of richstringty;

 richstringaty = array[0..0] of richstringty;
 prichstringaty = ^richstringaty;

 updaterichstringeventty = procedure(const sender: tobject; 
                                        var avalue: richstringty) of object;

 trichstringdatalist = class(tmsestringdatalist)
  private
   fposition: pointty;
   function Getformats(index: integer): formatinfoarty;
   procedure Setformats(index: integer; const Value: formatinfoarty);
   procedure setnoparagraphs(index: integer; const avalue: boolean);
   function getrichitems(index: integer): richstringty;
   procedure setrichitems(index: integer; const Value: richstringty);
   function getrichitemspo(index: integer): prichstringty;
   procedure setasarray(const data: richstringarty);
   function getasarray: richstringarty;
   procedure setasmsestringarray(const data: msestringarty);
   function getasmsestringarray: msestringarty;
  protected
   function getnoparagraphs(index: integer): boolean; override;
   procedure freedata(var data); override;      //gibt daten frei
   procedure aftercopy(var data); override;
   function compare(const l,r): integer; override;
   procedure setstatdata(const index: integer; const value: msestring); override;
   function getstatdata(const index: integer): msestring; override;
  public
   constructor create; override;
   procedure insert(const index: integer; const item: msestring); override;
   function add(const value: msestring): integer; override;
   function add(const avalue: msestring; 
                    const anoparagraph: boolean): integer; override;
   function nextword(out value: lmsestringty): boolean;
              //true bei new line
   function getformatpo(index: integer): pformatinfoarty;
   function getparagraph(const index: integer;
                               const aseparator: msestring = ''): msestring;

   property formats[index: integer]: formatinfoarty read Getformats write Setformats;
   property noparagraphs[index : integer]: boolean read getnoparagraphs
                                                         write setnoparagraphs;
   property richitems[index: integer]: richstringty read getrichitems write setrichitems;
   property richitemspo[index: integer]: prichstringty read getrichitemspo;
   property position: pointty read fposition write fposition;
                //x = 0 fuer zeilenbeginn
   property asarray: richstringarty read getasarray write setasarray;
   property asmsestringarray: msestringarty read getasmsestringarray
               write setasmsestringarray;
 end;

 tcharstyledatalist = class(tdatalist)
  private
   function Getitems(index: integer): charstylety;
   procedure Setitems(index: integer; const Value: charstylety);
  public
   constructor create; override;
   procedure clear; override;
   function add(const value: charstylety): integer; overload;
   function add(style: fontstylesty = []; fontcolor: pcolorty = nil;
                       colorbackground: pcolorty = nil): integer; overload;
   function add(const value: string): integer; overload;
                //'bius' fontcolor colorbackground
   property items[index: integer]: charstylety read Getitems write Setitems;
                                                                       default;
 end;

const
 emptyrichstring: richstringty = (text: ''; format: nil; flags: []);
 richlineend: richstringty = (text: lineend; format: nil; flags: []);
 
function setfontcolor1(var formats: formatinfoarty; aindex: integer; 
                       len: halfinteger; color: colorty): boolean;
                                 //true if changed
function setfontcolor(const formats: formatinfoarty; aindex: integer; 
                       len: halfinteger; color: colorty): formatinfoarty;
function setcolorbackground1(var formats: formatinfoarty; aindex: integer;
                              len: halfinteger;
                              color: colorty): boolean;
                                 //true if changed
function setcolorbackground(const formats: formatinfoarty; aindex: integer;
                              len: halfinteger;
                              color: colorty): formatinfoarty;

function updatefontstyle1(var formats: formatinfoarty; aindex: integer;
                              len: halfinteger;
                              astyle: fontstylety; aset: boolean): boolean;
                                 //true if changed
function updatefontstyle(const formats: formatinfoarty; aindex: integer;
                len: halfinteger;
                astyle: fontstylety; aset: boolean): formatinfoarty;
function updatefontstyle1(var formats: formatinfoarty; aindex: integer;
                              len: halfinteger;
                              astyles: fontstylesty; aset: boolean): boolean;
                                 //true if changed
function updatefontstyle(const formats: formatinfoarty; aindex: integer;
                len: halfinteger;
                astyles: fontstylesty; aset: boolean): formatinfoarty;

function setcharstyle1(var formats: formatinfoarty; aindex,len: halfinteger;
                            const style: charstylety): boolean;
                                  //true if changed
function setcharstyle(const formats: formatinfoarty; aindex,len: halfinteger;
                            const style: charstylety): formatinfoarty;
function getcharstyle(const formats: formatinfoarty;
           const aindex: integer): charstylety; //zero based
function getfontstyle(const formats: formatinfoarty;
           const aindex: integer): fontstylesty; //zero based

procedure setselected1(var text: richstringty; start,len: halfinteger);
function setselected(const text: richstringty;
                                        start,len: halfinteger): richstringty;

function isequalrichstring(const a,b: richstringty): boolean;
function isequalformat(const a,b: formatinfoarty): boolean;
function isequalformatinfo(const a,b: formatinfoty): boolean;

procedure richdelete(var value: richstringty; aindex,count: integer);
procedure richinsert(const source: msestring; var value: richstringty;
                                                             aindex: integer);
function richcopy(const source: richstringty; index, count: halfinteger): richstringty;
function richconcat(const a,b: richstringty): richstringty; overload;
function richconcat(const a: richstringty; const b: msestring;
              const fontstyle: fontstylesty = [];
              const fontcolor: colorty = cl_none;
              const colorbackground: colorty = cl_none): richstringty; overload;
function richconcat(const a: msestring; const b: richstringty;
              const fontstyle: fontstylesty = [];
              const fontcolor: colorty = cl_none;
              const colorbackground: colorty = cl_none): richstringty; overload;
procedure richconcat1(var dest: richstringty; const b: richstringty); overload;
procedure richconcat1(var dest: richstringty; const b: msestring;
              const fontstyle: fontstylesty = [];
              const fontcolor: colorty = cl_none;
              const colorbackground: colorty = cl_none); overload;
                                                         

procedure additem(const value: richstringty; var dest: richstringarty;
                             var count: integer; step: integer = 32); overload;
function splitrichstring(const avalue: richstringty; const separator: msechar): richstringarty;
function breakrichlines(const source: richstringty): richstringarty;

procedure captiontorichstring(const caption: captionty; var dest: richstringty);
//procedure captiontorichstring(const caption: captionty; out result: richstringty);
function richstringtocaption(const caption: richstringty): captionty;
function isshortcut(key: keyty; const caption: msestring): boolean; overload;
function isshortcut(key: msechar; const caption: msestring): boolean; overload;
//function checkshortcut(var info: keyeventinfoty;
//          const caption: richstringty; const checkalt: boolean): boolean; overload;
      //moved to msegui
//function checkshortcut(var info: keyeventinfoty;
//          const key: keyty; const shiftstate: shiftstatesty): boolean; overload;

function expandtabs(const s: richstringty; const tabcharcount: integer): richstringty;

{$ifdef FPC}
function richformatinfotostring(const aformat: formatinfoty): ansistring;
{$endif}

var
 hotkeyfontstylesadd: fontstylesty;    //default [fs_underline]
 hotkeyfontstylesremove: fontstylesty; //default []
 hotkeycolor: colorty;                 //default cl_none
 hotkeycolorbackground: colorty;       //default cl_none

implementation
uses
 typinfo,msearrayutils,msegraphics;

type
 tpoorstringdatalist1 = class(tpoorstringdatalist);
 
{$ifdef FPC} 
function richformatinfotostring(const aformat: formatinfoty): ansistring;
begin
 with aformat do begin
  result:= inttostr(index)+' '+settostring(ptypeinfo(typeinfo(newinfosty)),
              integer(newinfos),true)+
           ' ' + settostring(ptypeinfo(typeinfo(fontstylesty)),
              integer(style.fontstyle),true);
 end;
end;
{$endif}

function splitrichstring(const avalue: richstringty; const separator: msechar): richstringarty;
var
 int1: integer;
 ar1: integerarty;
begin
 ar1:= getcharpos(avalue.text,separator);
 setlength(result,high(ar1)+2);
 if ar1 = nil then begin
  result[0].text:= avalue.text;
  result[0].format:= copy(avalue.format);
 end
 else begin
  result[0]:= richcopy(avalue,1,ar1[0]-1);
  for int1:= 0 to high(ar1) - 1 do begin
   result[int1+1]:= richcopy(avalue,ar1[int1]+1,ar1[int1+1]-ar1[int1]-1);
  end;
  result[high(result)]:= richcopy(avalue,ar1[high(ar1)]+1,bigint);
 end;
end;

function breakrichlines(const source: richstringty): richstringarty;
var
 int1,int2: integer;
begin
 result:= splitrichstring(source,c_linefeed);
 for int1:= 0 to high(result) do begin
  int2:= length(result[int1].text);
  if (int2 > 0) and (result[int1].text[int2] = c_return) then begin
   setlength(result[int1].text,int2-1);
  end;
 end;
end;

procedure captiontorichstring(const caption: captionty; var dest: richstringty);
var
 int1: integer;
 ch1: msechar;
 po1: pmsechar;

 procedure sethotstyle();
 begin
  with dest do begin
   updatefontstyle1(format,po1-pmsechar(pointer(text)),1,
                                              hotkeyfontstylesadd,true);
   updatefontstyle1(format,po1-pmsechar(pointer(text)),1,
                                              hotkeyfontstylesremove,false);
   if hotkeycolor <> cl_none then begin
    setfontcolor1(format,po1-pmsechar(pointer(text)),1,hotkeycolor);
   end;
   if hotkeycolorbackground <> cl_none then begin
    setcolorbackground1(format,po1-pmsechar(pointer(text)),1,
                                                  hotkeycolorbackground);
   end;
  end;
 end;//sethotstyle
 
begin
 with dest do begin
  setlength(text,length(caption)); //max
  format:= nil;
  po1:= pointer(text);
  int1:= 1;
  while int1 <= length(caption) do begin
   ch1:= caption[int1];
   if (ch1 = '&') {and (format = nil)} then begin
    if caption[int1+1] = '&' then begin
     po1^:= ch1;
     inc(int1);
     if caption[int1+1] = '&' then begin    //there is a trailing #0
      sethotstyle();
      inc(int1);
     end;
     inc(po1);
    end
    else begin
     sethotstyle();
    end;
   end
   else begin
    po1^:= ch1;
    inc(po1);
   end;
   inc(int1);
  end;
  setlength(text,po1-pmsechar(pointer(text)));
 end;
end;

function richstringtocaption(const caption: richstringty): captionty;
 function checkhotkey(const astyle: charstylety): boolean;
 begin
  result:= (astyle.fontstyle * hotkeyfontstylesadd = hotkeyfontstylesadd) and
            (astyle.fontstyle * hotkeyfontstylesremove = []) and
            ((hotkeycolor = cl_none) or (astyle.fontcolor = hotkeycolor)) and
            ((hotkeycolorbackground = cl_none) or 
                     (astyle.colorbackground = hotkeycolorbackground));
            ;
 end;//checkhotkey
 
var
 int1: integer;
 po1: pmsechar;
 ch1: msechar;
begin
 with caption do begin
  setlength(result,length(text)*2+1);
  po1:= pmsechar(pointer(result));
  for int1:= 1 to length(text) do begin
//   if fs_underline in getfontstyle(format,int1-1) then begin
   if checkhotkey(getcharstyle(format,int1-1)) then begin
    po1^:= '&';
    inc(po1);
   end;
   ch1:= text[int1];
   po1^:= ch1;
   inc(po1);
   if (ch1 = '&') then begin
    po1^:= ch1;
    inc(po1);
   end;
  end;
  if checkhotkey(getcharstyle(format,length(text))) then begin
   po1^:= '&';
   inc(po1);
  end;
 end;
 setlength(result,po1-pmsechar(pointer(result)));
end;

function isshortcut(key: msechar; const caption: msestring): boolean;
var
 p1: pmsechar;
begin
 result:= false;
 if caption <> '' then begin
  p1:= pointer(caption);
  while p1^ <> #0  do begin
   if p1^ = '&' then begin
    inc(p1);
    if p1^ <> '&' then begin
     result:= msecomparetext(p1^,key) = 0;
     break;
    end;
   end;
   inc(p1);
  end;
 end;
{
 with caption do begin
  if (format = nil) or (format[0].index >= length(text)) or (length(key) < 1) then begin
   result:= false;
  end
  else begin
   result:= mseuppercase(text[format[0].index+1]) = mseuppercase(key);
//   result:= charuppercase(text[format[0].index+1]) = charuppercase(key);
  end;
 end;
 }
end;
{
function isshortcut(key: msechar; const caption: richstringty): boolean;
begin
 with caption do begin
  if (format = nil) or (format[0].index >= length(text)) or (length(key) < 1) then begin
   result:= false;
  end
  else begin
   result:= mseuppercase(text[format[0].index+1]) = mseuppercase(key);
//   result:= charuppercase(text[format[0].index+1]) = charuppercase(key);
  end;
 end;
end;
}
function isshortcut(key: keyty; const caption: msestring): boolean;
begin
 result:= isshortcut(keytomsechar(key),caption);
end;

procedure insertfontinfo(var infoar: formatinfoarty; aindex: integer);
begin
 setlength(infoar,length(infoar)+1);
 if aindex > 0 then begin
  move(infoar[aindex-1],infoar[aindex],
         (length(infoar)-aindex)*sizeof(formatinfoty));
  infoar[aindex].newinfos:= [];
 end
 else begin
  move(infoar[aindex],infoar[aindex+1],
         (length(infoar)-aindex-1)*sizeof(formatinfoty));
  fillchar(infoar[0],sizeof(formatinfoty),0);
 end;
end;

function getnewfontinfo(var fontinfoar: formatinfoarty; aindex: integer;
                  out num: integer): pformatinfoty;
var
 int1,int2: integer;
begin
 int1:= 0;
 if length(fontinfoar) = 0 then begin
  insertfontinfo(fontinfoar,0);
 end
 else begin
  int2:= high(fontinfoar);
  while int1 <= int2 do begin
   with fontinfoar[int1] do begin
    if index >= aindex then begin
     if index > aindex then begin
      insertfontinfo(fontinfoar,int1);
     end;
     break;
    end;
   end;
   inc(int1);
  end;
  if int1 > int2 then begin
   insertfontinfo(fontinfoar,int1);
  end;
 end;
 result:= @fontinfoar[int1];
 result^.index:= aindex;
 num:= int1;
end;

procedure packfontformats(var formats: formatinfoarty);
var
 int1,int2: integer;
 focopo,bacopo: colorty;
 fontstyles,fontstylesdelta: fontstylesty;
begin
 int2:= 0;
 int1:= 0;
 focopo:= 0;
 bacopo:= 0;
 fontstyles:= [];
 while int1 < length(formats) do begin
  with formats[int1] do begin
   if not(ni_delete in newinfos) then begin
    if style.fontcolor = focopo then begin
     exclude(newinfos,ni_fontcolor);
    end
    else begin
     include(newinfos,ni_fontcolor);
    end;
    if style.colorbackground = bacopo then begin
     exclude(newinfos,ni_colorbackground);
    end
    else begin
     include(newinfos,ni_colorbackground);
    end;
    fontstylesdelta:= fontstylesty(
     {$ifdef FPC}longword{$else}byte{$endif}(fontstyles) xor
     {$ifdef FPC}longword{$else}byte{$endif}(style.fontstyle));
    newinfos:= newinfos -
           newinfosty(not
             {$ifdef FPC}longword({$else}
                         word(byte{$endif}(fontstylesdelta))) * fontstyleflags +
           newinfosty(
             {$ifdef FPC}longword({$else}
                         word(byte{$endif}(fontstylesdelta))) * fontstyleflags;
    if ni_fontcolor in newinfos then begin
     focopo:= style.fontcolor;
    end;
    if ni_colorbackground in newinfos then begin
     bacopo:= style.colorbackground;
    end;
    fontstyles:= fontstylesty({$ifdef FPC}longword{$else}byte{$endif}(fontstyles) xor
            {$ifdef FPC}longword{$else}byte{$endif}(fontstylesdelta) and
               {$ifdef FPC}longword({$else}byte(word{$endif}(newinfos)));
    if newinfos <> [] then begin
     if int1 <> int2 then begin
      formats[int2]:= formats[int1];
     end;
     inc(int2);
    end;
   end;
  end;
  inc(int1);
 end;
 if int1 <> int2 then begin
  setlength(formats,int2);
 end;
end;

function setfontinfolen(var formats: formatinfoarty; aindex: integer; len: halfinteger;
                            const astyle: charstylety; flags: newinfosty): boolean;
     //true wenn geaendert

 function updatestyle(var style: charstylety): boolean;
 var
  afontstyle: fontstylesty;
 begin
  result:= false;
//  style.newinfos:= newinfos+flags;
  if ni_fontcolor in flags then begin
   result:= result or (style.fontcolor <> astyle.fontcolor);
   style.fontcolor:= astyle.fontcolor;
  end;
  if ni_colorbackground in flags then begin
   result:= result or (style.colorbackground <> astyle.colorbackground);
   style.colorbackground:= astyle.colorbackground;
  end;
  afontstyle:= style.fontstyle;
  style.fontstyle:= style.fontstyle -
            fontstylesty({$ifdef FPC}longword({$else}
                         byte(word{$endif}(flags * fontstyleflags))) +
            astyle.fontstyle * fontstylesty(
            {$ifdef FPC}longword({$else}byte(word{$endif}(flags)));
  result:= result or (afontstyle <> style.fontstyle);
 end;

var
 int1,int2: integer;
 isempty: boolean;
 lastnum: integer;
 bo1: boolean;

begin
 result:= false;
 isempty:= length(formats) = 0;
 if len > 0 then begin
  int2:= high(formats);
  getnewfontinfo(formats,aindex,int1);
  getnewfontinfo(formats,aindex + len,lastnum);
  for int1:= int1 to lastnum - 1 do begin
   bo1:= updatestyle(formats[int1].style);
   result:= result or bo1;
  end;
  if result or (high(formats) > int2) then begin
   packfontformats(formats);
  end;
 end;
 result:= result and not (isempty and (length(formats) = 0));
end;

function setfontcolor1(var formats: formatinfoarty; aindex: integer;
                             len: halfinteger;
                             color: colorty): boolean;
     //true if changed
var
 style: charstylety;
begin
 style.fontcolor:= not color;
 result:= setfontinfolen(formats,aindex,len,style,[ni_fontcolor]);
end;

function setfontcolor(const formats: formatinfoarty; aindex: integer;
                                  len: halfinteger;
                                  color: colorty): formatinfoarty;
begin
 result:= copy(formats);
 setfontcolor1(result,aindex,len,color);
end;

function setcolorbackground1(var formats: formatinfoarty; aindex: integer;
                                  len: halfinteger;
                                  color: colorty): boolean;
     //true if changed
var
 style: charstylety;
begin
 style.colorbackground:= not color;
 result:= setfontinfolen(formats,aindex,len,style,[ni_colorbackground]);
end;

function setcolorbackground(const formats: formatinfoarty; aindex: integer;
                                  len: halfinteger;
                                  color: colorty): formatinfoarty;
begin
 result:= copy(formats);
 setcolorbackground1(result,aindex,len,color);
end;

procedure setselected1(var text: richstringty; start,len: halfinteger);
begin
 updatefontstyle1(text.format,0,bigint,fs_selected,false);
 updatefontstyle1(text.format,start,len,fs_selected,true);
end;

function setselected(const text: richstringty;
                      start,len: halfinteger): richstringty;
begin
 result:= text;
 setlength(result.format,length(result.format));
 setselected1(result,start,len);
end;

function updatefontstyle1(var formats: formatinfoarty; aindex: integer; len: halfinteger;
                              astyles: fontstylesty; aset: boolean): boolean;
                              //true if changed
var
 style: charstylety;
 newinfos: newinfosty;
begin
 if aset then begin
  style.fontstyle:= astyles;
 end
 else begin
  style.fontstyle:= [];
 end;
 newinfos:= newinfosty({$ifdef FPC}longword({$else}word(byte{$endif}(astyles)));
 result:= setfontinfolen(formats,aindex,len,style,newinfos);
end;

function updatefontstyle1(var formats: formatinfoarty; aindex: integer; len: halfinteger;
                              astyle: fontstylety; aset: boolean): boolean;
                              //true if changed
begin
 result:= updatefontstyle1(formats,aindex,len,[astyle],aset);
end;

function updatefontstyle(const formats: formatinfoarty; aindex: integer;
                len: halfinteger;
                astyles: fontstylesty; aset: boolean): formatinfoarty;
begin
 result:= copy(formats);
 updatefontstyle1(result,aindex,len,astyles,aset);
end;

function updatefontstyle(const formats: formatinfoarty; aindex: integer;
                len: halfinteger;
                astyle: fontstylety; aset: boolean): formatinfoarty;
begin
 result:= updatefontstyle(formats,aindex,len,[astyle],aset);
end;

function setcharstyle1(var formats: formatinfoarty;
               aindex,len: halfinteger; const style: charstylety): boolean;
                                  //true if changed
begin
 result:= setfontinfolen(formats,aindex,len,style,
     [ni_fontcolor,ni_colorbackground,ni_bold,ni_italic,ni_underline,ni_strikeout]);
end;

function setcharstyle(const formats: formatinfoarty;
               aindex,len: halfinteger; const style: charstylety): formatinfoarty;
begin
 result:= copy(formats);
 setcharstyle1(result,aindex,len,style);
end;

function getcharstyle(const formats: formatinfoarty;
                                 const aindex: integer): charstylety;
var
 int1: integer;
 foundindex: integer;
begin
 if length(formats) > 0 then begin
  foundindex:= -1;
  for int1:= 0 to high(formats) do begin
   with formats[int1] do begin
    if index > aindex then begin
     foundindex:= int1;
     break;
    end;
   end;
  end;
  if foundindex >= 0 then begin
   if foundindex > 0 then begin
    result:= formats[foundindex-1].style;
   end
   else begin
    fillchar(result,sizeof(charstylety),0);
   end;
  end
  else begin
   result:= formats[high(formats)].style;
  end
 end
 else begin
  fillchar(result,sizeof(charstylety),0);
 end;
end;

function getfontstyle(const formats: formatinfoarty;
                 const aindex: integer): fontstylesty;
var
 int1: integer;
 foundindex: integer;
begin
 result:= [];
 if formats <> nil then begin
  foundindex:= -1;
  for int1:= 0 to high(formats) do begin
   with formats[int1] do begin
    if index > aindex then begin
     foundindex:= int1;
     break;
    end;
   end;
  end;
  if foundindex >= 0 then begin
   if foundindex > 0 then begin
    result:= formats[foundindex-1].style.fontstyle;
   end;
  end
  else begin
   result:= formats[high(formats)].style.fontstyle;
  end
 end;
end;

function isequalformatinfo(const a,b: formatinfoty): boolean;
begin
 result:= (a.index = b.index) and (a.newinfos = b.newinfos) and
  (a.style.fontcolor = b.style.fontcolor) and
  (a.style.colorbackground = b.style.colorbackground) and
  (a.style.fontstyle = b.style.fontstyle);
end;

function isequalformat(const a,b: formatinfoarty): boolean;
var
 int1: integer;
begin
 if pointer(a) = pointer(b) then begin
  result:= true;
  exit;
 end;
 result:= length(a) = length(b);
 if result then begin
  for int1:= 0 to high(a) do begin
   if not isequalformatinfo(a[int1],b[int1]) then begin
    result:= false;
    break;
   end;
  end;
//  result:= comparemem(pointer(a),pointer(b),length(a)*sizeof(fontinfoty));
 end;
end;

function isequalrichstring(const a,b: richstringty): boolean;
begin
 result:= (a.text = b.text) and isequalformat(a.format,b.format);
end;

procedure richdelete(var value: richstringty; aindex,count: integer);
var
 int1: integer;
 needspack,all: boolean;
begin
 if (aindex > 0) then begin
  delete(value.text,aindex,count);
  if length(value.format) > 0 then begin
   setlength(value.format,length(value.format)); //unique
   needspack:= false;
   all:= count >= bigint;
   dec(aindex);
   for int1:= 0 to high(value.format) do begin
    with value.format[int1] do begin
     if index >= aindex then begin
      index:= index - count;
      if all or (index < aindex) then begin
       needspack:= true;
       newinfos:= [ni_delete];
      end;
     end;
    end;
   end;
   if needspack then begin
    packfontformats(value.format);
   end;
  end;
 end;
end;

procedure formatinsertchars(var format: formatinfoarty; const aindex: integer;
                            const count: integer);
var
 int1: integer;
begin
 setlength(format,length(format)); //unique
 for int1:= 0 to high(format) do begin
  with format[int1] do begin
   if index >= aindex then begin
    index:= index + count;
   end;
  end;
 end;
end;

function expandtabs(const s: richstringty; const tabcharcount: integer): richstringty;
var
 int1,int2,int3,int4: integer;
begin
 int1:= tabcharcount;
 if int1 <= 0 then begin
  int1:= 1;
 end;
 setlength(result.text,length(s.text)*int1); //max
 result.format:= copy(s.format);
 int2:= 1;
 for int1:= 1 to length(s.text) do begin
  if s.text[int1] = c_tab then begin
   if tabcharcount > 0 then begin
    int3:= tabcharcount - ((int2-1) mod tabcharcount) - 1;
    formatinsertchars(result.format,int2,int3);
    for int4:= 0 to int3 do begin
     result.text[int2]:= ' ';
     inc(int2);
    end;
   end;
  end
  else begin
   result.text[int2]:= s.text[int1];
   inc(int2);
  end;
 end;
 setlength(result.text,int2-1);
end;

procedure richinsert(const source: msestring; var value: richstringty; aindex: integer);
begin
 insert(source,value.text,aindex);
 formatinsertchars(value.format,aindex,length(source));
end;

function richcopy(const source: richstringty; index, count: halfinteger): richstringty;
var
 int1,int2: integer;
 startindex,endindex: integer;
 res: richstringty;
begin
 if count = 0 then begin
  result:= emptyrichstring;
 end
 else begin
  res.text:= copy(source.text,index,count);
  res.format:= nil;
  if length(source.format) > 0 then begin
   startindex:= -1;
   endindex:= -1;
   for int1:= 0 to high(source.format) do begin
    if source.format[int1].index >= index then begin
     startindex:= int1;
     break;
    end;
   end;
   if startindex < 0 then begin
    int1:= 0;
   end
   else begin
    int1:= startindex;
   end;
   for int1:= int1 to high(source.format) do begin
    if source.format[int1].index >= index + count then begin
     endindex:= int1;
     break;
    end;
   end;
   if startindex > 0 then begin
    dec(startindex);
   end
   else begin
    startindex:= 0;
   end;
   if endindex >= 0 then begin
    res.format:= copy(source.format,startindex,endindex-startindex);
   end
   else begin
    res.format:= copy(source.format,startindex,bigint);
   end;
   if length(res.format) > 0 then begin
    with res.format[0] do begin
     newinfos:= [];
     if style.fontcolor <> 0 then include(newinfos,ni_fontcolor);
     if style.colorbackground <> 0 then include(newinfos,ni_colorbackground);
     if fs_bold in style.fontstyle then include(newinfos,ni_bold);
     if fs_italic in style.fontstyle then include(newinfos,ni_italic);
     if fs_underline in style.fontstyle then include(newinfos,ni_underline);
     if fs_strikeout in style.fontstyle then include(newinfos,ni_strikeout);
     if fs_selected in style.fontstyle then include(newinfos,ni_selected);
    end;
    for int1:= 0 to high(res.format) do begin
     int2:= res.format[int1].index - index + 1;
     if int2 < 0 then begin
      int2:= 0;
     end;
     res.format[int1].index:= int2;
    end;
   end;
  end;
  result:= res;
 end;
end;

function richconcat(const a,b: richstringty): richstringty;
var
 i1,i2,i3: integer;
 res: richstringty;
begin
 res.format:= a.format;
 res.text:= a.text + b.text;
 i2:= length(res.format);
 i3:= length(a.text);
 setlength(res.format,i2 + length(b.format));
 for i1:= 0 to high(b.format) do begin
  with res.format[i1+i2] do begin
   index:= b.format[i1].index + i3;
   newinfos:= b.format[i1].newinfos;
   style:= b.format[i1].style;
  end;
 end;
 result:= res;
end;

function richconcat(const a: richstringty; const b: msestring;
               const fontstyle: fontstylesty = [];
               const fontcolor: colorty = cl_none;
               const colorbackground: colorty = cl_none): richstringty;
var
 rstr1: richstringty;
begin
 if (fontstyle <> []) or (fontcolor <> cl_none) or 
                       (colorbackground <> cl_none) then begin
  setlength(rstr1.format,1);
  with rstr1.format[0] do begin
   index:= 0;
   if fontstyle <> [] then begin
    style.fontstyle:= fontstyle;
    newinfos:= fontstyleflags;
   end;
   if fontcolor <> cl_none then begin
    style.fontcolor:= not fontcolor;
    include(newinfos,ni_fontcolor);
   end;
   if colorbackground <> cl_none then begin
    style.colorbackground:= not colorbackground;
    include(newinfos,ni_colorbackground);
   end;
  end
 end
 else begin
  rstr1.format:= nil;
 end;
 rstr1.text:= b;
 result:= richconcat(a,rstr1);
end;

function richconcat(const a: msestring; const b: richstringty;
              const fontstyle: fontstylesty = [];
              const fontcolor: colorty = cl_none;
              const colorbackground: colorty = cl_none): richstringty; overload;
var
 rstr1: richstringty;
begin
 if (fontstyle <> []) or (fontcolor <> cl_none) or 
                       (colorbackground <> cl_none) then begin
  setlength(rstr1.format,1);
  with rstr1.format[0] do begin
   index:= 0;
   if fontstyle <> [] then begin
    style.fontstyle:= fontstyle;
    newinfos:= fontstyleflags;
   end;
   if fontcolor <> cl_none then begin
    style.fontcolor:= not fontcolor;
    include(newinfos,ni_fontcolor);
   end;
   if colorbackground <> cl_none then begin
    style.colorbackground:= not colorbackground;
    include(newinfos,ni_colorbackground);
   end;
  end
 end
 else begin
  rstr1.format:= nil;
 end;
 rstr1.text:= a;
 result:= richconcat(rstr1,b);
end;

procedure richconcat1(var dest: richstringty; const b: richstringty);
begin
 dest:= richconcat(dest,b);
end;

procedure richconcat1(var dest: richstringty; const b: msestring;
              const fontstyle: fontstylesty = [];
              const fontcolor: colorty = cl_none;
              const colorbackground: colorty = cl_none);
begin
 dest:= richconcat(dest,b,fontstyle,fontcolor,colorbackground);
end;

{
function uniqueformatinfoarty(const value: formatinfoarty): formatinfoarty;
begin
 result:= value;
 setlength(result,length(result));
end;

function uniquerichstringty(const value: richstringty): richstringty;
begin
 result:= value;
 setlength(result.format,length(result.format));
end;
}
procedure additem(const value: richstringty; var dest: richstringarty;
                             var count: integer; step: integer = 32);
begin
 if length(dest) <= count then begin
  setlength(dest,count+step);
 end;
 dest[count]:= value;
 inc(count);
end;

{ tcharstyledatalist }

constructor tcharstyledatalist.create;
begin
 inherited;
 fsize:= sizeof(charstylety);
end;

function tcharstyledatalist.add(const value: charstylety): integer;
begin
 result:= adddata(value);
end;

function tcharstyledatalist.add(style: fontstylesty = []; fontcolor: pcolorty = nil;
                      colorbackground: pcolorty = nil): integer;
var
 value: charstylety;
begin
 value.fontstyle:= style;
 if fontcolor = nil then begin
  value.fontcolor:= 0;
 end
 else begin
  value.fontcolor:= not fontcolor^;
 end;
 if colorbackground = nil then begin
  value.colorbackground:= 0;
 end
 else begin
  value.colorbackground:= not colorbackground^;
 end;
// value.colorbackground:= colorbackground;
 result:= add(value);
end;

function tcharstyledatalist.add(const value: string): integer;

 function getcolor(const name: string): colorty;
// var
//  col1: colorty;
//  int1,int2: integer;
//  po1: pcolorty;
 begin
  if name = '' then begin
   result:= 0;
  end
  else begin
   result:= not stringtocolor(name);
   (*
   col1:= stringtocolor(name);
   for int1:= 0 to high(fcolors) do begin
    if fcolors[int1] = col1 then begin
     result:= @fcolors[int1];
     exit;
    end;
   end;
   po1:= pointer(fcolors);
   for int1:= 1 to length(fcolors) do begin
    for int2:= 0 to fcount-1 do begin
     with pcharstylety(getitempo(int2))^{licharstylearty(fdaten^)[int2]} do begin
      if fontcolor = po1 then begin
       fontcolor:= pointer(int1);
      end;
      if colorbackground = po1 then begin
       colorbackground:= pointer(int1);
      end;
     end;
    end;
    inc(po1);
   end;
   setlength(fcolors,length(fcolors)+1);
   po1:= pointer(fcolors);
   for int1:= 1 to length(fcolors) do begin
    for int2:= 0 to fcount-1 do begin
     with pcharstylety(getitempo(int2))^{licharstylearty(fdaten^)[int2]} do begin
      if fontcolor = pointer(int1) then begin
       fontcolor:= po1;
      end;
      if colorbackground = pointer(int1) then begin
       colorbackground:= po1;
      end;
     end;
    end;
    inc(po1);
   end;
   fcolors[high(fcolors)]:= col1;
   result:= @fcolors[high(fcolors)];
   *)
  end;
 end;

var
 lstr1: lstringty;
 str1,str2,str3: string;
 st: charstylety;
begin
 fillchar(st,sizeof(charstylety),0);
 stringtolstring(value,lstr1);
 nextquotedstring(lstr1,str1);
 nextword(lstr1,str2);
 nextword(lstr1,str3);
 str1:= struppercase(str1);
 if strlscan(pointer(str1),'B',length(str1)) <> nil then begin
  include(st.fontstyle,fs_bold);
 end;
 if strlscan(pointer(str1),'I',length(str1)) <> nil then begin
  include(st.fontstyle,fs_italic);
 end;
 if strlscan(pointer(str1),'U',length(str1)) <> nil then begin
  include(st.fontstyle,fs_underline);
 end;
 if strlscan(pointer(str1),'S',length(str1)) <> nil then begin
  include(st.fontstyle,fs_strikeout);
 end;
 st.fontcolor:= getcolor(str2);
 st.colorbackground:= getcolor(str3);
 result:= add(st);
end;

function tcharstyledatalist.Getitems(index: integer): charstylety;
begin
 internalgetdata(index,result);
// checkindex(index);
// result:= licharstylearty(fdaten^)[index];
end;

procedure tcharstyledatalist.Setitems(index: integer; const Value: charstylety);
begin
 internalsetdata(index,value);
// checkindex(index);
// licharstylearty(fdaten^)[index]:= value;
end;

procedure tcharstyledatalist.clear;
begin
 inherited;
// fcolors:= nil;
end;

{ trichstringdatalist }

constructor trichstringdatalist.create;
begin
 inherited;
 fsize:= sizeof(richstringty);
end;

procedure trichstringdatalist.freedata(var data);
begin
 inherited;
 richstringty(data).format:= nil;
end;

procedure trichstringdatalist.aftercopy(var data);
begin
 inherited;
 reallocarray(richstringty(data).format,sizeof(richstringty(data).format[0]));
end;

function trichstringdatalist.add(const value: msestring): integer;
var
 ristr1: richstringty;
begin
 ristr1.text:= value;
 ristr1.format:= nil;
 ristr1.flags:= [];
 result:= adddata(ristr1);
end;

function trichstringdatalist.add(const avalue: msestring; 
                                           const anoparagraph: boolean): integer;
begin
 result:= inherited add(avalue,anoparagraph);
 if anoparagraph then begin
  noparagraphs[result]:= true;
 end;
end;

procedure trichstringdatalist.insert(const index: integer; const item: msestring);
var
 ristr1: richstringty;
begin
 ristr1.text:= item;
 ristr1.format:= nil;
 ristr1.flags:= [];
 insertdata(index,ristr1);
end;

function trichstringdatalist.compare(const l,r): integer;
begin
 result:= msecomparestr(richstringty(l).text,richstringty(r).text);
end;

function trichstringdatalist.getformatpo(index: integer): pformatinfoarty;
begin
 checkindex(index);
 result:= @prichstringty(fdatapo+index*sizeof(richstringty))^.format;
end;

function trichstringdatalist.getparagraph(const index: integer; 
                          const aseparator: msestring = ''): msestring;
var
 int1,int2: integer;
 start{,stop}: integer;
begin
 start:= index;
 while start >= 0 do begin
  int2:= start;
  checkindex(int2);
  if not (rf_noparagraph in 
           prichstringty(fdatapo+int2*sizeof(richstringty))^.flags) then begin
   break;
  end;
  dec(start);
 end;
 int2:= start;
 checkindex(int2);
 result:= prichstringty(fdatapo+int2*sizeof(richstringty))^.text;
 for int1:= start+1 to count-1 do begin
  int2:= int1;
  checkindex(int2);
  with prichstringty(fdatapo+int2*sizeof(richstringty))^ do begin
   if not (rf_noparagraph in flags) then begin
    break;
   end;
   result:= result + aseparator + text; 
  end;
 end;
end;

function trichstringdatalist.Getformats(index: integer): formatinfoarty;
begin
 checkindex(index);
 result:= prichstringty(fdatapo+index*sizeof(richstringty))^.format;
end;

procedure trichstringdatalist.Setformats(index: integer;
                      const Value: formatinfoarty);
begin
 checkindex(index);
// prichstringty(fdatapo+index*sizeof(richstringty))^.format:= uniqueformatinfoarty(value);
 prichstringty(fdatapo+index*sizeof(richstringty))^.format:= copy(value);
end;

function trichstringdatalist.getnoparagraphs(index: integer): boolean;
begin
 checkindex(index);
 result:= rf_noparagraph in 
                prichstringty(fdatapo+index*sizeof(richstringty))^.flags;
end;

procedure trichstringdatalist.setnoparagraphs(index: integer;
                      const avalue: boolean);
begin
 checkindex(index);
 if avalue then begin
  include(prichstringty(fdatapo+index*sizeof(richstringty))^.flags,
                                                            rf_noparagraph);
 end
 else begin
  exclude(prichstringty(fdatapo+index*sizeof(richstringty))^.flags,
                                                            rf_noparagraph);
 end;
end;

function trichstringdatalist.getrichitems(index: integer): richstringty;
begin
 checkindex(index);
 result:= prichstringty(fdatapo+index*sizeof(richstringty))^;
end;

procedure trichstringdatalist.setrichitems(index: integer; const Value: richstringty);
var
 po1: prichstringty;
begin
 checkindex(index);
 po1:= prichstringty(fdatapo+index*sizeof(richstringty));
 po1^.text:= value.text;
 po1^.format:= copy(value.format);
// prichstringty(fdatapo+index*sizeof(richstringty))^:= uniquerichstringty(value);
end;

function trichstringdatalist.getrichitemspo(index: integer): prichstringty;
begin
 checkindex(index);
 result:= prichstringty(fdatapo+index*sizeof(richstringty));
end;

procedure trichstringdatalist.setasarray(const data: richstringarty);
begin
 internalsetasarray(pointer(data),sizeof(richstringty),length(data));
end;

function trichstringdatalist.getasarray: richstringarty;
begin
 result:= nil;
 allocuninitedarray(fcount,sizeof(result[0]),result);
// setlength(result,fcount);
 internalgetasarray(pointer(result),sizeof(richstringty));
end;

procedure trichstringdatalist.setasmsestringarray(const data: msestringarty);
var
 po1: prichstringty;
 int1: integer;
 s1: integer;
begin
 newbuffer(length(data),true,true);
 po1:= pointer(fdatapo);
 s1:= size;
 for int1:= 0 to fcount - 1 do begin
  po1^.text:= data[int1];
  po1^.format:= nil;
  po1^.flags:= [];
  inc(pchar(po1),s1);
 end;
 change(-1);
end;

function trichstringdatalist.getasmsestringarray: msestringarty;
var
 po1: prichstringty;
 int1: integer;
begin
 setlength(result,fcount);
 po1:= datapo;
 for int1:= 0 to fcount - 1 do begin
  result[int1]:= po1^.text;
  inc(po1);
 end;
end;

function trichstringdatalist.nextword(out value: lmsestringty): boolean;
var
 po1: pmsechar;
 int1: integer;
begin
 if fposition.Y >= fcount then begin
  result:= false;
  value.po:= nil;
  value.len:= 0;
 end
 else begin
  with prichstringty(fdatapo+fposition.y*sizeof(richstringty))^ do begin
   int1:= length(text) - fposition.X;
   if int1 > 0 then begin
    value.po:= msestrlnscan(@text[fposition.x+1],' ',int1);
   end
   else begin
    value.po:= nil;
   end;
   if value.po = nil then begin
    result:= true;
    value.len:= 0;
    inc(fposition.Y);
    fposition.X:= 0;
   end
   else begin
    result:= false;
    int1:= length(text)-(value.po - pmsechar(pointer(text)));
    po1:= msestrlscan(value.po,' ',int1);
    if po1 = nil then begin
     value.len:= int1;
    end
    else begin
     value.len:= po1-value.po;
    end;
    fposition.X:= (value.po - pmsechar(pointer(text))) + value.len;
   end;
  end;
 end;
end;
{
procedure trichstringdatalist.assign(source: tpersistent);
begin
 if not assigndata(source) then begin
  if source is tpoorstringdatalist then begin
   tpoorstringdatalist1(source).assigntodata(self);
  end
  else begin
   inherited;
  end;
 end;
end;
}
procedure trichstringdatalist.setstatdata(const index: integer; const value: msestring);
var
 po1: prichstringty;
begin
 po1:= getitempo(index);
 po1^.text:= value;
 po1^.format:= nil;
end;

function trichstringdatalist.getstatdata(const index: integer): msestring;
begin
 result:= items[index];
end;

initialization
 hotkeyfontstylesadd:= [fs_underline];
 hotkeyfontstylesremove:= [];
 hotkeycolor:= cl_none;
 hotkeycolorbackground:= cl_none;
end.
