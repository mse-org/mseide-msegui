{ MSEgui Copyright (c) 1999-2011 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msefont;
{$ifdef FPC}{$mode objfpc}{$h+}{$GOTO ON}{$interfaces corba}{$endif}

interface
uses
 mseguiglob,msegraphics;

function getfontnum(const fontinfo: fontinfoty; var drawinfo: drawinfoty;
                     getfont: getfontfuncty): fontnumty;
procedure addreffont(font: fontnumty);
procedure releasefont(font: fontnumty);

procedure checkhighresfont(const afont: pfontdataty; var drawinfo: drawinfoty);
function getfontdata(font: fontnumty): pfontdataty;
function findfontdata(const afont: fontty): pfontdataty;
function registerfontalias(const alias,name: string;
              mode: fontaliasmodety = fam_nooverwrite;
              const height: integer = 0; const width: integer = 0;
              const options: fontoptionsty = [];
              const xscale: real = 1.0;
              const ancestor: string = defaultfontalias): boolean;
              //true if registering ok
function unregisterfontalias(const alias: string): boolean;
              //false if alias does not exist
procedure clearfontalias; //removes all alias which are not fam_fix
function fontaliascount: integer;
procedure setfontaliascount(const acount: integer);
function realfontname(const aliasname: string): string;
function getfontforglyph(const abasefont: fontty; const glyph: unicharty): fontnumty;
function fontoptioncharstooptions(const astring: string): fontoptionsty;

procedure init;
procedure deinit;

implementation
uses
 mselist,sysutils,mseguiintf,msegraphutils,msetypes,msesys,
 msestrings,mseformatstr;
 
const
 maxfontcount = 64;

type
 fontdatarecty = record
  refcount: integer;
  data: pfontdataty;
 end;
 fontdatarecpoty = ^fontdatarecty;

 fontaliasty = record
  alias: string;
  ancestor: string;
  name: string;
  mode: fontaliasmodety;
  height: integer;
  width: integer;
  options: fontoptionsty;
  xscale: real;
 end;
 pfontaliasty = ^fontaliasty;
 fontaliasaty = array[0..0] of fontaliasty;
 pfontaliasaty = ^fontaliasaty;

 tfontaliaslist = class(trecordlist)
  protected
   procedure finalizerecord(var item); override;
   procedure copyrecord(var item); override;
   procedure updatefontdata(var info: fontdataty);
   function find(const alias: string): integer;
  public
   constructor create;
   function registeralias(const alias,name: string;
              mode: fontaliasmodety = fam_nooverwrite;
              const height: integer = 0; const width: integer = 0;
              const options: fontoptionsty = [];
              const xscale: real = 1.0;
              const ancestor: string = ''): boolean;
              //true if registering ok
 end;

var
 fonts: array of fontdatarecty;
 lastreusedfont: integer;
 ffontaliaslist: tfontaliaslist;

function fontaliaslist: tfontaliaslist;
begin
 if ffontaliaslist = nil then begin
  ffontaliaslist:= tfontaliaslist.create;
 end;
 result:= ffontaliaslist;
end;

function registerfontalias(const alias,name: string;
              mode: fontaliasmodety = fam_nooverwrite;
              const height: integer = 0; const width: integer = 0;
              const options: fontoptionsty = [];
              const xscale: real = 1.0;
              const ancestor: string = defaultfontalias): boolean;
              //true if registering ok
begin
 result:= fontaliaslist.registeralias(alias,name,mode,height,width,options,
                                       xscale,ancestor);
end;

function realfontname(const aliasname: string): string;
var                            
 int1: integer;
 str1: string;
begin
 result:= '';
 if ffontaliaslist <> nil then begin
  str1:= aliasname;
  while str1 <> '' do begin
   int1:= ffontaliaslist.find(str1);
   if int1 >= 0 then begin
    with pfontaliasaty(ffontaliaslist.datapo)^[int1] do begin
     if (result = '') and (name <> '') then begin
      result:= name;
      break;
     end;
    end;
   end
   else begin
    break;
   end;
  end;
 end;
 if result = '' then begin
  result:= aliasname;
 end;
end;

function unregisterfontalias(const alias: string): boolean;
              //false if alias does not exist
var
 int1: integer;
begin
 result:= false;
 if ffontaliaslist <> nil then begin
  int1:= ffontaliaslist.find(alias);
  if int1 >= 0 then begin
   ffontaliaslist.delete(int1);
   if ffontaliaslist.count = 0 then begin
    freeandnil(ffontaliaslist);
   end;
  end;
 end;
end;

procedure clearfontalias; //removes all alias which are not fam_fix
var
 int1: integer;
begin
 if ffontaliaslist <> nil then begin
  for int1:= ffontaliaslist.count - 1 downto 0 do begin
   if pfontaliasty(ffontaliaslist.getitempo(int1))^.mode <> fam_fix then begin
    ffontaliaslist.delete(int1);
   end;
  end;
 end;
end;

function fontaliascount: integer;
begin
 result:= ffontaliaslist.count;
end;

procedure setfontaliascount(const acount: integer);
begin
 ffontaliaslist.count:= acount;
end;

function getfontdata(font: fontnumty): pfontdataty;
begin
 dec(font);
 if font >= longword(length(fonts)) then begin
  result:= nil;
 end
 else begin
  result:= fonts[font].data;
 end;
end;

function findfontdata(const afont: fontty): pfontdataty;
var
 int1: integer;
begin
 result:= nil;
 for int1:= 0 to high(fonts) do begin
  with fonts[int1] do begin
   if (refcount > 0) and (data^.font = afont) then begin
    result:= fonts[int1].data;
    break;
   end;
  end;
 end;
end;

procedure freefont(index: integer);
var
 drawinfo: drawinfoty;
begin
 with fonts[index] do begin
  data^.name:= '';
  data^.charset:= '';
  gdi_lock;
  drawinfo.getfont.fontdata:= data;
  gdi_freefontdata(drawinfo);
//  gui_freefontdata(data^);
  gdi_unlock;
  refcount:= 0;
 end;
end;

type
 fontmatrixmodety = (fmm_fix,fmm_linear,fmm_matrix);
 x11fontdatadty = record
  infopo: pointer;
  matrixmode: fontmatrixmodety;
  defaultwidth: integer;
  xftascent,xftdescent: integer;
  rowlength: word;
  xftdirection: graphicdirectionty;
 end;
 px11fontdatadty = ^x11fontdatadty;
 x11fontdataty = record
  case integer of
   0: (d: x11fontdatadty;);
   1: (_bufferspace: fontdatapty;);
 end;
 
function registerfont(var fontdata: fontdataty): fontnumty;

 procedure reusefont(startindex: integer);
 var
  int1: integer;
 begin
  for int1:= startindex to high(fonts) do begin   //reuse oldest
   if fonts[int1].refcount <= 0 then begin
    freefont(int1);
    lastreusedfont:= int1;
    result:= int1+1;
    break;
   end;
  end;
 end;

begin //registerfont
 result:= 0;
 if length(fonts) > maxfontcount then begin
  reusefont(lastreusedfont+1);
  if result = 0 then begin
   reusefont(0);
  end;
 end;
 if result = 0 then begin
  result:= length(fonts)+1;
  setlength(fonts,result);
  with fonts[high(fonts)] do begin
   getmem(data,sizeof(fontdataty));
   fillchar(data^,sizeof(fontdataty),0);
  end;
 end;
 fonts[result-1].data^:= fontdata;
 fonts[result-1].refcount:= 1;
end;

procedure releasefont(font: fontnumty);
begin
 dec(font);
 if integer(font) < 0 then begin
  exit;
 end;
 if integer(font) <= high(fonts) then begin
  with fonts[font] do begin
   if refcount > 0 then begin
    dec(refcount);
   end;
  end;
 end;
end;

procedure addreffont(font: fontnumty);
begin
 if font > 0 then begin
  inc(fonts[font-1].refcount);
 end;
end;

procedure checkhighresfont(const afont: pfontdataty; var drawinfo: drawinfoty);
var
 fontinfobefore: getfontinfoty;
begin
 with afont^ do begin
  if fonthighres = 0 then begin
   fontinfobefore:= drawinfo.getfont;
   with drawinfo.getfont do begin
    fontdata:= afont;
    basefont:= 0;
   end;
   gdi_lock;
   gdi_getfonthighres(drawinfo);
   gdi_unlock;   
   drawinfo.getfont:= fontinfobefore;
  end;
 end;
end;

function getfontnum(const fontinfo: fontinfoty; var drawinfo: drawinfoty;
                     getfont: getfontfuncty): fontnumty;
var
 int1: integer;
 data1: fontdataty;
 style1: {$ifdef FPC}longword{$else}byte{$endif};

 procedure getvalues;
 begin
  with fontinfo do begin           //todo: hash or similar
   data1.name:= name;
   data1.height:= height;
   data1.width:= width;
   data1.familyoptions:= options * fontfamilymask;
   data1.pitchoptions:= options * fontpitchmask;
   data1.antialiasedoptions:= options * fontantialiasedmask;
//   data1.xcoreoptions:= options * fontxcoremask;
   data1.charset:= charset;
   data1.style:= fontstylesty({$ifdef FPC}longword{$else}byte{$endif}(style) and
                            fontstylehandlemask);
   data1.glyph:= glyph;
   data1.rotation:= rotation;
   data1.xscale:= xscale;
  end;
 end; //getvalues
 
label
 endlab;
begin
 gdi_lock;
 with fontinfo do begin           //todo: hash or similar
  style1:= {$ifdef FPC}longword{$else}byte{$endif}(style) and fontstylehandlemask;
  for int1:= 0 to high(fonts) do begin
   with fonts[int1] do begin
    if (refcount >= 0) and
     (data^.glyph = glyph) and           //unicode substitutes
     (data^.height = height) and
     (data^.width = width)  and
     (data^.pitchoptions = options * fontpitchmask) and
     (data^.familyoptions = options * fontfamilymask) and
     (data^.antialiasedoptions = options * fontantialiasedmask) and
//     (data.xcoreoptions = options * fontxcoremask) and
     ({$ifdef FPC}longword{$else}byte{$endif}(data^.style) = style1) and
     (name = data^.name) and
     (charset = data^.charset) and
     (rotation = data^.rotation) and
     (xscale = data^.xscale) then begin
     inc(refcount);
     result:= int1 + 1;
     goto endlab
    end;
   end;
  end;
  fillchar(data1,sizeof(fontdataty),0);
  getvalues;
  if ffontaliaslist <> nil then begin
   ffontaliaslist.updatefontdata(data1);
  end;
  drawinfo.getfont.fontdata:= @data1;
  drawinfo.getfont.basefont:= 0;
  if getfont(drawinfo) then begin
   getvalues;
   data1.basefont:= drawinfo.getfont.basefont;
   result:= registerfont(data1);
  end
  else begin
   result:= 0;
  end;
 end;
endlab:
 gdi_unlock;
end;

function getfontforglyph(const abasefont: fontty; const glyph: unicharty): fontnumty;
var
 info: drawinfoty;
 int1: integer;
begin
 result:= 0;
 info.fonthasglyph.unichar:= glyph;  
 gdi_lock;
 for int1:= 0 to high(fonts) do begin
  with fonts[int1],data^ do begin
   if (refcount >= 0) and (basefont = abasefont) then begin
    info.fonthasglyph.font:= font;
    gui_getgdifuncs^[gdf_fonthasglyph](info);    
    if info.fonthasglyph.hasglyph then begin
     result:= int1 + 1;
    end;
   end;
  end;
 end;
 gdi_unlock;
end;

function fontoptioncharstooptions(const astring: string): fontoptionsty;
var
 int1: integer;
 option1: fontoptionty;
begin
 result:= [];
 for int1:= 1 to length(astring) do begin
  for option1:= low(fontoptionty) to high(fontoptionty) do begin
   if astring[int1] = fontaliasoptionchars[option1] then begin
    include(result,option1);
   end;
  end;
 end;
end;

procedure initfontalias;
//format aliasdef: 
//--FONTALIAS=<alias>,<fontname>[,<fontheight>[,<fontwidth>[,<options>[,<xscale>]
//                    [,<ancestor>]]]
const
 paramname = '--FONTALIAS=';
var
 ar1,ar2: stringarty;
 int1,{int2,}int3,int4,int5: integer;
 ar3: array[0..1] of integer;
 options1: fontoptionsty;
 xscale1: real;
 str1: string;
begin
 ar1:= getcommandlinearguments;
 int3:= 1;
 xscale1:= 1.0;
 for int1:= 1 to high(ar1) do begin
  if strlicomp(pchar(ar1[int1]),pchar(paramname),length(paramname)) = 0 then begin
   ar2:= nil;
   splitstringquoted(copy(ar1[int1],length(paramname)+1,bigint),ar2,'"',',');
   if (high(ar2) >= 1) and (high(ar2) <= 6) then begin
    try
     for int4:= 0 to high(ar3) do begin
      if int4 + 2 > high(ar2) then begin
       ar3[int4]:= 0;
      end
      else begin
       if trim(ar2[int4+2]) <> '' then begin
        ar3[int4]:= strtoint(ar2[int4+2]);
       end
       else begin
        ar3[int4]:= 0;
       end;
      end;
     end;
     options1:= [];
     if high(ar2) >= 4 then begin
      options1:= fontoptioncharstooptions(ar2[4]);
     end;
     if (high(ar2) >= 5) and (trim(ar2[5]) <> '') then begin
      xscale1:= strtoreal(ar2[5]);
     end;
     if high(ar2) >= 6 then begin
      str1:= trim(ar2[6]);
     end
     else begin
      if lowercase(ar2[0]) = defaultfontalias then begin
       str1:= '';
      end
      else begin
       str1:= defaultfontalias;
      end;
     end;
     
     fontaliaslist.registeralias(ar2[0],ar2[1],fam_overwrite,ar3[0],ar3[1],options1,
                                 xscale1,str1);
     deletecommandlineargument(int3);
     dec(int3);
    except
    end;
   end;
  end;
  inc(int3);
 end;
end;

procedure init;
begin
 initfontalias;
end;

procedure deinit;
var
 int1: integer;
begin
 for int1:= 0 to high(fonts) do begin
  with fonts[int1] do begin
   refcount:= 1;
   freefont(int1);
   freemem(data);
  end;
 end;
 freeandnil(ffontaliaslist);
end;

{ tfontaliaslist }

constructor tfontaliaslist.create;
begin
 inherited create(sizeof(fontaliasty),[rels_needsfinalize,rels_needscopy]);
end;

procedure tfontaliaslist.finalizerecord(var item);
begin
 finalize(fontaliasty(item));
end;

procedure tfontaliaslist.copyrecord(var item);
begin
 with fontaliasty(item) do begin
  stringaddref(alias);
  stringaddref(name);
 end;
end;

function tfontaliaslist.find(const alias: string): integer;
var
 str1: string;
 po1: pfontaliasaty;
 int1: integer;
begin
 result:= -1;
 str1:= struppercase(alias);
 po1:= datapo;
 for int1:= 0 to count-1 do begin
  if po1^[int1].alias = str1 then begin
   result:= int1;
   break;
  end;
 end;
end;

procedure tfontaliaslist.updatefontdata(var info: fontdataty);
var
 int1: integer;
 str1: string;
 po1: pchar;
begin
 str1:= info.name;
 po1:= nil;
 while str1 <> '' do begin
  int1:= find(str1);
  if int1 < 0 then begin
   break;
  end;
  with pfontaliasty(getitempo(int1))^ do begin
   str1:= ancestor;
   if (name <> '') and (po1 = nil) then begin
    po1:= pchar(name);
   end;
   if (height <> 0) and (info.height = 0) then begin
    info.height:= height;
   end;
   if (width <> 0) and (info.width = 0) then begin
    info.width:= width;
   end;
   if (xscale <> 1) and (info.xscale = 1) then begin
    info.xscale:= xscale;
   end;
   if (options * fontpitchmask <> []) and 
      (info.pitchoptions * fontpitchmask = []) then begin
    info.pitchoptions:= options * fontpitchmask;
   end;
   if (options * fontfamilymask <> []) and 
      (info.pitchoptions * fontfamilymask = []) then begin
    info.familyoptions:= options * fontfamilymask;
   end;
   if (options * fontantialiasedmask <> []) and 
      (info.pitchoptions * fontantialiasedmask = []) then begin
    info.antialiasedoptions:= options * fontantialiasedmask;
   end;
  end;
 end;
 if po1 <> nil then begin
  info.name:= po1;
 end;
end;

function tfontaliaslist.registeralias(const alias,name: string;
              mode: fontaliasmodety = fam_nooverwrite;
               const height: integer = 0; const width: integer = 0;
               const options: fontoptionsty = [];
               const xscale: real = 1.0;
               const ancestor: string = ''): boolean;
              //true if registering ok
var
 po1: pfontaliasty;

 procedure doupdate;
 begin
  po1^.name:= name;
  po1^.mode:= mode;
  po1^.height:= height shl fontsizeshift;
  po1^.width:= width shl fontsizeshift;
  po1^.options:= options;
  po1^.xscale:= xscale;
  po1^.ancestor:= ancestor;
 end;

var
 int1: integer;
 str1,str2: string;
begin
 result:= false;
 str1:= uppercase(alias);
 str2:= uppercase(ancestor);
 while str2 <> '' do begin
  if str1 = str2 then begin
   raise exception.create('Recursive fontalias "'
                  +alias+'" name "'+name+'" caller "'+str1+'".');
  end;
  int1:= find(str2);
  if int1 >= 0 then begin
   str2:= uppercase(pfontaliasty(getitempo(int1))^.ancestor);
  end
  else begin
   break;
  end;
 end;
 int1:= find(alias);
 if int1 >= 0 then begin
  po1:= pfontaliasty(getitempo(int1));
  if not (mode in [fam_nooverwrite,fam_fixnooverwrite]) then begin
   if po1^.mode <> fam_fix then begin
    doupdate;
   end;
  end;
 end
 else begin
  count:= count + 1;
  po1:= getitempo(count-1);
  po1^.alias:= struppercase(alias);
  doupdate;
 end;
 if mode = fam_fixnooverwrite then begin
  po1^.mode:= fam_fix;
 end;
end;

end.
