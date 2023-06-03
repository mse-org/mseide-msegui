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
 mseguiglob,msegraphics,mseclasses;

function getfontnum(const fontinfo: fontinfoty; var drawinfo: drawinfoty;
                 getfont: getfontfuncty; var atemplate: tfontcomp): fontnumty;
procedure addreffont(font: fontnumty);
procedure releasefont(font: fontnumty);

procedure checkhighresfont(const afont: pfontdataty; var drawinfo: drawinfoty);
procedure getchar16widths(var drawinfo: drawinfoty);
procedure getfontmetrics(var drawinfo: drawinfoty);

function getfontdata(font: fontnumty): pfontdataty;
function findfontdata(const afont: fontty): pfontdataty;
function registerfontalias(const alias,name: string;
              mode: fontaliasmodety = fam_nooverwrite;
              const height: integer = 0; const width: integer = 0;
              const options: fontoptionsty = [];
              const xscale: real = 1.0;
              ancestor: string = defaultfontalias;
              const template: tfontcomp = nil): boolean;
              //true if registering ok
function unregisterfontalias(const alias: string): boolean;
              //false if alias does not exist
procedure clearfontalias; //removes all alias which are not fam_fix
function fontaliascount: integer;
procedure setfontaliascount(const acount: integer);
function realfontname(const aliasname: string): string;
function getfontforglyph(const abasefont: fontty;
                                          const glyph: unicharty): fontnumty;
function fontoptioncharstooptions(const astring: string): fontoptionsty;

procedure init;
procedure deinit;

const
 defaultmaxfontcachecount = 64;
var
 maxfontcachecount: integer = defaultmaxfontcachecount;

implementation
uses
 mselist,sysutils,mseguiintf,msegraphutils,msetypes,msesys,
 msestrings,mseformatstr,msehash,mseglob;

type
 fontnumdataty = record
  num: integer;
 end;
 fontnumhashdataty = record
  header: hashheaderty;
  data: fontnumdataty;
 end;
 pfontnumhashdataty = ^fontnumhashdataty;

 tfonthashlist = class(thashdatalist)
  protected
   function hashkey(const akey): hashvaluety; override;
   function checkkey(const akey; const aitem: phashdataty): boolean override;
   function getrecordsize(): int32 override;
  public
//   constructor create;
   function find(const afont: fonthashdataty): integer;
   procedure add(const afont: fontnumty);
   procedure delete(const afont: fontnumty);
 end;

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
  template: tfontcomp;
 end;
 pfontaliasty = ^fontaliasty;
 fontaliasaty = array[0..0] of fontaliasty;
 pfontaliasaty = ^fontaliasaty;

 tfontaliaslist = class(tlinkedrecordlist)
  protected
   procedure finalizerecord(var item); override;
   procedure copyrecord(var item); override;
   procedure updatefontdata(var info: fontdataty; var atemplate: tfontcomp);
   function find(const alias: string): integer;
   procedure objectevent(const sender: tobject;
                            const event: objecteventty); override;
  public
   constructor create;
   function registeralias(const alias,name: string;
              mode: fontaliasmodety = fam_nooverwrite;
              const height: integer = 0; const width: integer = 0;
              const options: fontoptionsty = [];
              const xscale: real = 1.0;
              const ancestor: string = '';
              const template: tfontcomp = nil): boolean;
              //true if registering ok
 end;

var
 fonts: array of fontdatarecty;
 lastreusedfont: integer;
 ffontaliaslist: tfontaliaslist;
 ffonthashlist: tfonthashlist;

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
              ancestor: string = defaultfontalias;
              const template: tfontcomp = nil): boolean;
              //true if registering ok
begin
 if (alias = defaultfontalias) and (ancestor = defaultfontalias) then begin
  ancestor:= '';
 end;
 result:= fontaliaslist.registeralias(alias,name,mode,height,width,options,
                                       xscale,ancestor,template);
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
   result:= true;
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
 ffonthashlist.delete(index);
 with fonts[index] do begin
  gdi_lock;
  drawinfo.getfont.fontdata:= data;
  freefontdata(drawinfo);
  finalize(data^);
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
var
 int1: integer;
begin //registerfont
 result:= 0;
 if length(fonts) > maxfontcachecount then begin
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
 int1:= result-1;
 fonts[int1].data^:= fontdata;
// move(fontdata,fonts[int1].data^,sizeof(fontdata));
 fonts[int1].refcount:= 1;
 ffonthashlist.add(int1);
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
//   gdi_getfonthighres(drawinfo);
   h.d.gdifuncs^[gdf_getfonthighres](drawinfo);
   gdi_unlock;
   drawinfo.getfont:= fontinfobefore;
  end;
 end;
end;

procedure getchar16widths(var drawinfo: drawinfoty);
begin
 with drawinfo.getchar16widths.fontdata^ do begin
  h.d.gdifuncs^[gdf_getchar16widths](drawinfo);
 end;
end;

procedure getfontmetrics(var drawinfo: drawinfoty);
begin
 with drawinfo.getfontmetrics.fontdata^ do begin
  h.d.gdifuncs^[gdf_getfontmetrics](drawinfo);
 end;
end;

function comparefont(const s: fontinfoty; const d: fontdataty): boolean;
begin
 result:=
     (d.h.d.glyph = s.glyph) and           //unicode substitutes
     (d.h.d.gdifuncs = s.gdifuncs) and
     (d.h.d.height = s.baseinfo.height) and
     (d.h.d.width = s.baseinfo.width)  and
     (d.h.d.pitchoptions = s.baseinfo.options * fontpitchmask) and
     (d.h.d.familyoptions = s.baseinfo.options * fontfamilymask) and
     (d.h.d.antialiasedoptions = s.baseinfo.options * fontantialiasedmask) and
     ({$ifdef FPC}longword{$else}byte{$endif}(d.h.d.style) xor
      {$ifdef FPC}longword{$else}byte{$endif}(s.baseinfo.style) and
                                          fontstylehandlemask = 0) and
     (d.h.name = s.baseinfo.name) and
     (d.h.charset = s.baseinfo.charset) and
     (d.h.d.rotation = s.rotation) and
     (d.h.d.xscale = s.baseinfo.xscale);

end;

{ tfonthashlist }
{
constructor tfonthashlist.create;
begin
 inherited create(sizeof(fontnumdataty));
end;
}
function tfonthashlist.hashkey(const akey): hashvaluety;
begin
 with fontdataty(akey) do begin
  result:= stringhash(h.name) xor stringhash(h.charset) xor
              datahash(h.d,sizeof(h.d));
 end;
end;

function tfonthashlist.checkkey(const akey; const aitem: phashdataty): boolean;
var
 po1: pfontdataty;
begin
 po1:= fonts[pfontnumhashdataty(aitem)^.data.num].data;
 with fontdataty(akey) do begin
  result:= comparemem(@po1^.h.d,@h.d,sizeof(h.d)) and
                      (po1^.h.name = h.name) and (po1^.h.charset = h.charset);
 end;
end;

function tfonthashlist.getrecordsize(): int32;
begin
 result:= sizeof(fontnumhashdataty);
end;

function tfonthashlist.find(const afont: fonthashdataty): integer;
var
 po1: pfontnumhashdataty;
begin
 result:= -1;
 po1:= pfontnumhashdataty(internalfind(afont));
 if po1 <> nil then begin
  result:= po1^.data.num;
 end;
end;

procedure tfonthashlist.add(const afont: fontnumty);
var
 po1: pfontnumhashdataty;
begin
 po1:= pfontnumhashdataty(internaladd(fonts[afont].data^.h));
 po1^.data.num:= afont;
end;

procedure tfonthashlist.delete(const afont: fontnumty);
begin
 internaldeleteitem(internalfind(fonts[afont].data^.h));
end;

procedure getfontvalues(const s: fontinfoty; var d: fontdataty);
begin
 fillchar(d.h.d,sizeof(d.h.d),0);
 d.h.d.gdifuncs:= s.gdifuncs;
 d.h.d.height:= s.baseinfo.height;
 d.h.d.width:= s.baseinfo.width;
 d.h.d.familyoptions:= s.baseinfo.options * fontfamilymask;
 d.h.d.pitchoptions:= s.baseinfo.options * fontpitchmask;
 d.h.d.antialiasedoptions:= s.baseinfo.options * fontantialiasedmask;
 d.h.d.style:= fontstylesty({$ifdef FPC}longword{$else}byte{$endif}
                                  (s.baseinfo.style) and fontstylehandlemask);
 d.h.d.glyph:= s.glyph;
 d.h.d.rotation:= s.rotation;
 d.h.d.xscale:= s.baseinfo.xscale;
 d.h.name:= s.baseinfo.name;
 d.h.charset:= s.baseinfo.charset;
end;

function getfontnum(const fontinfo: fontinfoty; var drawinfo: drawinfoty;
                  getfont: getfontfuncty; var atemplate: tfontcomp): fontnumty;
var
 int1: integer;
 data1: fontdataty;
begin
 gdi_lock;
 with fontinfo do begin
  getfontvalues(fontinfo,data1);
  int1:= ffonthashlist.find(data1.h);
  if int1 >= 0 then begin
   with fonts[int1] do begin
    inc(refcount);
    result:= int1 + 1;
   end;
  end
  else begin               //todo: do not load same substitute multiple times
   finalize(data1);
   fillchar(data1,sizeof(data1),0);
   getfontvalues(fontinfo,data1);
   if ffontaliaslist <> nil then begin
    ffontaliaslist.updatefontdata(data1,atemplate);
   end;
   drawinfo.getfont.fontdata:= @data1;
   drawinfo.getfont.basefont:= 0;
   if getfont(drawinfo) then begin
    data1.realfont:= data1.h;
    if data1.realfont.d.height = 0 then begin
     if data1.realheight = 0 then begin
      data1.realheight:= data1.linespacing;
     end;
     data1.realfont.d.height:= data1.realheight shl fontsizeshift;
    end;
    getfontvalues(fontinfo,data1);
    data1.basefont:= drawinfo.getfont.basefont;
    result:= registerfont(data1);
   end
   else begin
    result:= 0;
   end;
  end;
 end;
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
    getdefaultgdifuncs^[gdf_fonthasglyph](info);
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
 ar1,ar2: msestringarty;
 int1,{int2,}int3,int4{,int5}: integer;
 ar3: array[0..1] of integer;
 options1: fontoptionsty;
 xscale1: real;
 str1: string;
 bo1: boolean;
begin
 ar1:= getcommandlinearguments;
 int3:= 1;
 xscale1:= 1.0;
 for int1:= 1 to high(ar1) do begin
  if msestrlicomp(pmsechar(ar1[int1]),pmsechar(paramname),
                                           length(paramname)) = 0 then begin
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
      options1:= fontoptioncharstooptions(ansistring(ar2[4]));
     end;
     if (high(ar2) >= 5) and (trim(ar2[5]) <> '') then begin
      xscale1:= strtoreal(ar2[5]);
     end;
     bo1:= lowercase(ar2[0]) = defaultfontalias;
     if bo1 and (ar2[1] = '') then begin
      ar2[1]:= msestring(gui_getdefaultfontnames[stf_default]);
     end;
     if high(ar2) >= 6 then begin
      str1:= ansistring(trim(ar2[6]));
     end
     else begin
      if bo1 then begin
       str1:= '';
      end
      else begin
       str1:= defaultfontalias;
      end;
     end;

     fontaliaslist.registeralias(ansistring(ar2[0]),ansistring(ar2[1]),
                         fam_overwrite,ar3[0],ar3[1],options1,xscale1,str1);
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
 ffonthashlist:= tfonthashlist.create;
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
 freeandnil(ffonthashlist);
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

procedure tfontaliaslist.updatefontdata(var info: fontdataty;
                                               var atemplate: tfontcomp);
var
 int1: integer;
 str1: string;
 po1: pchar;
begin
 str1:= info.h.name;
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
   if (height <> 0) and (info.h.d.height = 0) then begin
    info.h.d.height:= height;
   end;
   if (width <> 0) and (info.h.d.width = 0) then begin
    info.h.d.width:= width;
   end;
   if (xscale <> 1) and (info.h.d.xscale = 1) then begin
    info.h.d.xscale:= xscale;
   end;
   if (options * fontpitchmask <> []) and
      (info.h.d.pitchoptions * fontpitchmask = []) then begin
    info.h.d.pitchoptions:= options * fontpitchmask;
   end;
   if (options * fontfamilymask <> []) and
      (info.h.d.pitchoptions * fontfamilymask = []) then begin
    info.h.d.familyoptions:= options * fontfamilymask;
   end;
   if (options * fontantialiasedmask <> []) and
      (info.h.d.pitchoptions * fontantialiasedmask = []) then begin
    info.h.d.antialiasedoptions:= options * fontantialiasedmask;
   end;
   if (template <> nil) and (atemplate = nil) then begin
    atemplate:= template;
   end;
  end;
 end;
 if po1 <> nil then begin
  info.h.name:= po1;
 end;
end;

function tfontaliaslist.registeralias(const alias,name: string;
              mode: fontaliasmodety = fam_nooverwrite;
               const height: integer = 0; const width: integer = 0;
               const options: fontoptionsty = [];
               const xscale: real = 1.0;
               const ancestor: string = '';
               const template: tfontcomp = nil): boolean;
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
  if template <> po1^.template then begin
   getobjectlinker.setlink(iobjectlink(self),template,
                                   tmsecomponent(po1^.template));
  end;
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

procedure tfontaliaslist.objectevent(const sender: tobject;
               const event: objecteventty);
var
 po1,pe: pfontaliasty;
begin
 inherited;
 if event = oe_destroyed then begin
  po1:= datapo;
  pe:= po1 + count;
  while po1 < pe do begin
   if po1^.template = sender then begin
    po1^.template:= nil;
   end;
   inc(po1);
  end;
 end;
end;

end.
