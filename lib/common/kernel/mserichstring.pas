{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mserichstring;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 msegraphics,SysUtils,msetypes,msekeyboard,mseevent,mseguiglob,msedatalist,
   msegraphutils,Classes,msestrings;

const
 fsboldmask = $01;
 fsitalicmask = $02;
 fsunderlinemask = $04;
 fsstrikeoutmask = $08;

type
 newinfoty = (ni_bold=ord(fs_bold),ni_italic=ord(fs_italic),
              ni_underline=ord(fs_underline),ni_strikeout=ord(fs_strikeout),
              ni_selected=ord(fs_selected),
              //same order as in fontstylety
                 ni_fontcolor,ni_backgroundcolor,ni_delete);
 newinfosty = set of newinfoty;

const
 fonthandleflags = [ni_bold,ni_italic];
 fontstyleflags = [ni_bold,ni_italic,ni_underline,ni_strikeout,ni_selected];

type
 charstylety = record
  fontcolor,backgroundcolor: pcolorty;
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

 richstringty = record
  text: msestring;
  format: formatinfoarty;
 end;

 prichstringty = ^richstringty;
 richstringarty = array of richstringty;

 richstringaty = array[0..0] of richstringty;
 prichstringaty = ^richstringaty;

// lirichstrarty = array[0..0] of richstringty;
 trichstringdatalist = class(tmsestringdatalist)
  private
   fposition: pointty;
   function Getformats(index: integer): formatinfoarty;
   procedure Setformats(index: integer; const Value: formatinfoarty);
   function getrichitems(index: integer): richstringty;
   procedure setrichitems(index: integer; const Value: richstringty);
   function getrichitemspo(index: integer): prichstringty;
   procedure setasarray(const data: richstringarty);
   function getasarray: richstringarty;
   procedure setasmsestringarray(const data: msestringarty);
   function getasmsestringarray: msestringarty;
  protected
   procedure freedata(var data); override;      //gibt daten frei
   procedure copyinstance(var data); override;  //nach blockcopy aufgerufen
   procedure compare(const l,r; var result: integer); override;
   procedure setstatdata(const index: integer; const value: msestring); override;
   function getstatdata(const index: integer): msestring; override;
  public
   constructor create; override;
   procedure assign(source: tpersistent); override;
   procedure insert(index: integer; const item: msestring); override;
   function add(const value: msestring): integer; override;
   function nextword(out value: lmsestringty): boolean;
              //true bei new line
   function getformatpo(index: integer): pformatinfoarty;

   property formats[index: integer]: formatinfoarty read Getformats write Setformats;
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
   fcolors: colorarty;
   function Getitems(index: integer): charstylety;
   procedure Setitems(index: integer; const Value: charstylety);
  public
   constructor create; override;
   procedure clear; override;
   function add(const value: charstylety): integer; overload;
   function add(style: fontstylesty = []; fontcolor: pcolorty = nil;
                       backgroundcolor: pcolorty = nil): integer; overload;
   function add(const value: string): integer; overload;
                //'bius' fontcolor backgroundcolor
   property items[index: integer]: charstylety read Getitems write Setitems; default;
 end;


function setfontcolor(var formats: formatinfoarty; aindex: integer; len: halfinteger;
                    colorpo: pcolorty): boolean;
                                 //true if changed
function setbackgroundcolor(var formats: formatinfoarty; aindex: integer; len: halfinteger;
                    colorpo: pcolorty): boolean;
                                 //true if changed

function updatefontstyle(var formats: formatinfoarty; aindex: integer; len: halfinteger;
                              astyle: fontstylety; aset: boolean): boolean;
                                 //true if changed
function setcharstyle(var formats: formatinfoarty; aindex,len: halfinteger;
                            const style: charstylety): boolean;
                                  //true if changed
function getcharstyle(const formats: formatinfoarty; aindex: integer): charstylety;

procedure setselected(var text: richstringty; start,len: halfinteger);

function isequalrichstring(const a,b: richstringty): boolean;
function isequalformat(const a,b: formatinfoarty): boolean;
function isequalformatinfo(const a,b: formatinfoty): boolean;

procedure richdelete(var value: richstringty; aindex,count: integer);
procedure richinsert(const source: msestring; var value: richstringty; aindex: integer);
function richcopy(const source: richstringty; index, count: halfinteger): richstringty;
function richconcat(const a,b: richstringty): richstringty; overload;
function richconcat(const a: richstringty; const b: msestring): richstringty; overload;
{
function uniqueformatinfoarty(const value: formatinfoarty): formatinfoarty;
function uniquerichstringty(const value: richstringty): richstringty;
}
procedure additem(const value: richstringty; var dest: richstringarty;
                             var count: integer; step: integer = 32); overload;
function splitrichstring(const avalue: richstringty; const separator: msechar): richstringarty;
function breakrichlines(const source: richstringty): richstringarty;

procedure captiontorichstring(const caption: captionty; var dest: richstringty);
//procedure captiontorichstring(const caption: captionty; out result: richstringty);
function richstringtocaption(const caption: richstringty): captionty;
function isshortcut(key: keyty; const caption: richstringty): boolean; overload;
function isshortcut(key: msechar; const caption: richstringty): boolean; overload;
function checkshortcut(var info: keyeventinfoty;
          const caption: richstringty; const checkalt: boolean): boolean; overload;
function checkshortcut(var info: keyeventinfoty;
          const key: keyty; const shiftstate: shiftstatesty): boolean; overload;

function expandtabs(const s: richstringty; const tabcharcount: integer): richstringty;

implementation

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
 int1,int2: integer;
 ch1: msechar;
begin
 with dest do begin
  setlength(text,length(caption));
  format:= nil;
  int1:= 1;
  int2:= 0;
  while int1 <= length(caption) do begin
   ch1:= caption[int1];
   if ch1 = '&' then begin
    if (int1 < length(caption)) and (caption[int1+1] = '&') then begin
     pmsecharaty(text)^[int2]:= ch1;
     inc(int2);
     inc(int1);
    end
    else begin
     if format = nil then begin
      updatefontstyle(format,int2,1,fs_underline,true);
     end;
    end;
   end
   else begin
    pmsecharaty(text)^[int2]:= ch1;
    inc(int2);
   end;
   inc(int1);
  end;
  setlength(text,int2);
 end;
end;
{
//procedure captiontorichstring(const caption: captionty; out result: richstringty);
function captiontorichstring(const caption: captionty): richstringty;
var
 int1,int2: integer;
 ch1: msechar;
begin
// with result do begin
  setlength(result.text,length(caption));
  result.format:= nil; ch1:= 'A'; result.text:= 'abc'+ch1; exit;
  int1:= 1;
  int2:= 0;
  while int1 <= length(caption) do begin
   ch1:= caption[int1];
   if ch1 = '&' then begin
    if (int1 < length(caption)) and (caption[int1+1] = '&') then begin
     inc(int2);
     result.text[int2]:= ch1;
     inc(int1);
    end
    else begin
     if result.format = nil then begin
      updatefontstyle(result.format,int2,1,fs_underline,true);
     end;
    end;
   end
   else begin
    inc(int2);
    result.text[int2]:= ch1;
   end;
   inc(int1);
  end;
  setlength(result.text,int2);
// end;
end;
}

function richstringtocaption(const caption: richstringty): captionty;
begin
 with caption do begin
  if format <> nil then begin
   result:= copy(text,1,format[0].index) + '&' + copy(text,format[0].index+1,bigint);
  end
  else begin
   result:= text;
  end;
 end;
end;

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

function isshortcut(key: keyty; const caption: richstringty): boolean;
begin
 result:= isshortcut(keytomsechar(key),caption);
end;

function checkshortcut(var info: keyeventinfoty; const caption: richstringty;
                         const checkalt: boolean): boolean;
begin
 with info do begin
  if not (es_processed in eventstate) and 
    (not checkalt and (shiftstate -[ss_alt] = []) or (shiftstate = [ss_alt])) and
                         (length(info.chars) > 0) then begin
   result:= isshortcut(info.chars[1],caption);
   if result then begin
    include(eventstate,es_processed);
   end;
  end
  else begin
   result:= false;
  end;
 end;
end;

function checkshortcut(var info: keyeventinfoty;
          const key: keyty; const shiftstate: shiftstatesty): boolean;
begin
 result:= (key = info.key) and (shiftstate = info.shiftstate);
 if result then begin
  include(info.eventstate,es_processed);
 end;
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
 focopo,bacopo: pcolorty;
 fontstyles,fontstylesdelta: fontstylesty;
begin
 int2:= 0;
 int1:= 0;
 focopo:= nil;
 bacopo:= nil;
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
    if style.backgroundcolor = bacopo then begin
     exclude(newinfos,ni_backgroundcolor);
    end
    else begin
     include(newinfos,ni_backgroundcolor);
    end;
    fontstylesdelta:= fontstylesty(
     {$ifdef FPC}longword{$else}byte{$endif}(fontstyles) xor
     {$ifdef FPC}longword{$else}byte{$endif}(style.fontstyle));
    newinfos:= newinfos -
           newinfosty(not {$ifdef FPC}longword{$else}byte{$endif}(fontstylesdelta)) * fontstyleflags +
           newinfosty({$ifdef FPC}longword{$else}byte{$endif}(fontstylesdelta)) * fontstyleflags;
    if ni_fontcolor in newinfos then begin
     focopo:= style.fontcolor;
    end;
    if ni_backgroundcolor in newinfos then begin
     bacopo:= style.backgroundcolor;
    end;
    fontstyles:= fontstylesty({$ifdef FPC}longword{$else}byte{$endif}(fontstyles) xor
            {$ifdef FPC}longword{$else}byte{$endif}(fontstylesdelta) and
               {$ifdef FPC}longword{$else}byte{$endif}(newinfos));
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
  if ni_backgroundcolor in flags then begin
   result:= result or (style.backgroundcolor <> astyle.backgroundcolor);
   style.backgroundcolor:= astyle.backgroundcolor;
  end;
  afontstyle:= style.fontstyle;
  style.fontstyle:= style.fontstyle -
            fontstylesty({$ifdef FPC}longword{$else}byte{$endif}(flags * fontstyleflags)) +
            astyle.fontstyle * fontstylesty({$ifdef FPC}longword{$else}byte{$endif}(flags));
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

function setfontcolor(var formats: formatinfoarty; aindex: integer; len: halfinteger;
                                        colorpo: pcolorty): boolean;
     //true if changed
var
 style: charstylety;
begin
 style.fontcolor:= colorpo;
 result:= setfontinfolen(formats,aindex,len,style,[ni_fontcolor]);
end;

function setbackgroundcolor(var formats: formatinfoarty; aindex: integer; len: halfinteger;
                                        colorpo: pcolorty): boolean;
     //true if changed
var
 style: charstylety;
begin
 style.backgroundcolor:= colorpo;
 result:= setfontinfolen(formats,aindex,len,style,[ni_backgroundcolor]);
end;

procedure setselected(var text: richstringty; start,len: halfinteger);
begin
 updatefontstyle(text.format,0,bigint,fs_selected,false);
 updatefontstyle(text.format,start,len,fs_selected,true);
end;

function updatefontstyle(var formats: formatinfoarty; aindex: integer; len: halfinteger;
                              astyle: fontstylety; aset: boolean): boolean;
                              //true if changed
var
 style: charstylety;
 newinfos: newinfosty;
begin
 if aset then begin
  style.fontstyle:= [astyle];
 end
 else begin
  style.fontstyle:= [];
 end;
 newinfos:= newinfosty({$ifdef FPC}longword{$else}byte{$endif}([astyle]));
 result:= setfontinfolen(formats,aindex,len,style,newinfos);
end;

function setcharstyle(var formats: formatinfoarty;
               aindex,len: halfinteger; const style: charstylety): boolean;
                                  //true if changed
begin
 result:= setfontinfolen(formats,aindex,len,style,
     [ni_fontcolor,ni_backgroundcolor,ni_bold,ni_italic,ni_underline,ni_strikeout]);
end;

function getcharstyle(const formats: formatinfoarty; aindex: integer): charstylety;
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

function isequalformatinfo(const a,b: formatinfoty): boolean;
begin
 result:= (a.index = b.index) and (a.newinfos = b.newinfos) and
  (a.style.fontcolor = b.style.fontcolor) and
  (a.style.backgroundcolor = b.style.backgroundcolor) and
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
 needspack: boolean;
begin
 if (aindex > 0) then begin
  delete(value.text,aindex,count);
  if length(value.format) > 0 then begin
   needspack:= false;
   dec(aindex);
   for int1:= 0 to high(value.format) do begin
    with value.format[int1] do begin
     if index >= aindex then begin
      index:= index - count;
      if index < aindex then begin
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
    if style.fontcolor <> nil then include(newinfos,ni_fontcolor);
    if style.backgroundcolor <> nil then include(newinfos,ni_backgroundcolor);
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

function richconcat(const a,b: richstringty): richstringty;
var
 int1,int2: integer;
 res: richstringty;
begin
 res.format:= a.format;
 res.text:= a.text + b.text;
 int2:= length(res.format);
 setlength(res.format,int2 + length(b.format));
 for int1:= 0 to high(b.format) do begin
  with res.format[int1+int2] do begin
   index:= b.format[int1].index + length(a.text);
   newinfos:= b.format[int1].newinfos;
   style:= b.format[int1].style;
  end;
 end;
 result:= res;
end;

function richconcat(const a: richstringty; const b: msestring): richstringty;
var
 rstr1: richstringty;
begin
 rstr1.format:= nil;
 rstr1.text:= b;
 result:= richconcat(a,rstr1);
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
                      backgroundcolor: pcolorty = nil): integer;
var
 value: charstylety;
begin
 value.fontstyle:= style;
 value.fontcolor:= fontcolor;
 value.backgroundcolor:= backgroundcolor;
 result:= add(value);
end;

function tcharstyledatalist.add(const value: string): integer;

 function getcolor(const name: string): pcolorty;
 var
  col1: colorty;
  int1,int2: integer;
  po1: pcolorty;
 begin
  if name = '' then begin
   result:= nil;
  end
  else begin
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
      if backgroundcolor = po1 then begin
       backgroundcolor:= pointer(int1);
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
      if backgroundcolor = pointer(int1) then begin
       backgroundcolor:= po1;
      end;
     end;
    end;
    inc(po1);
   end;
   fcolors[high(fcolors)]:= col1;
   result:= @fcolors[high(fcolors)];
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
 st.backgroundcolor:= getcolor(str3);
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
 fcolors:= nil;
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

procedure trichstringdatalist.copyinstance(var data);
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
 result:= adddata(ristr1);
end;

procedure trichstringdatalist.insert(index: integer; const item: msestring);
var
 ristr1: richstringty;
begin
 ristr1.text:= item;
 ristr1.format:= nil;
 insertdata(index,ristr1);
end;

procedure trichstringdatalist.compare(const l, r; var result: integer);
begin
 result:= msecomparestr(richstringty(l).text,richstringty(r).text);
end;

function trichstringdatalist.getformatpo(index: integer): pformatinfoarty;
begin
 checkindex(index);
 result:= @prichstringty(fdatapo+index*sizeof(richstringty))^.format;
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
 internalsetasarray(length(data),pointer(data));
end;

function trichstringdatalist.getasarray: richstringarty;
begin
 setlength(result,fcount);
 internalgetasarray(pointer(result));
end;

procedure trichstringdatalist.setasmsestringarray(const data: msestringarty);
var
 po1: prichstringty;
 int1: integer;
begin
 beginupdate;
  count:= length(data);
  po1:= datapo;
  for int1:= 0 to fcount - 1 do begin
   po1^.text:= data[int1];
   po1^.format:= nil;
   inc(po1);
  end;
 endupdate;
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
    int1:= length(text)-(value.po - @text[1]);
    po1:= msestrlscan(value.po,' ',int1);
    if po1 = nil then begin
     value.len:= int1;
    end
    else begin
     value.len:= po1-value.po;
    end;
    fposition.X:= (value.po - @text[1]) + value.len;
   end;
  end;
 end;
end;

procedure trichstringdatalist.assign(source: tpersistent);
var
 int1: integer;
 po1,po2: prichstringty;
begin
 if source is tdoublemsestringdatalist then begin
  beginupdate;
  try
   with source as tdoublemsestringdatalist do begin
    po2:= prichstringty(fdatapo);
    self.clear;
    self.count:= count;
    po1:= prichstringty(self.fdatapo);
    for int1:= 0 to count - 1 do begin
     po1^:= po2^;
     setlength(po1^.format,length(po1^.format));
     inc(pchar(po1),self.fsize);
     inc(pchar(po2),fsize);
    end;
   end;
  finally
   endupdate;
  end
 end
 else begin
  inherited;
 end;
end;

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

end.
