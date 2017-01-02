{ MSEgui Copyright (c) 2011 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
//
//under construction
//
unit msefontcache;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msehash,msegraphics,mseguiglob;
 
type
 fontcachedataty = record
//  h: fontcachehdataty;
  keyname: string;
  keyheight: integer;
  refcount: integer;

  height: integer;
  ascent: integer;
  descent: integer;
  linespacing: integer;
  caretshift: integer;
  
  font: ptruint;
//  handle: pcachefontty;
 end;
 pfontcachedataty = ^fontcachedataty;
 fontcachehashdataty = record
  header: hashheaderty;
  data: fontcachedataty;
 end;
 pfontcachehashdataty = ^fontcachehashdataty;
 
 pfontcache = ^tfontcache;
 
 tfontcache = class(thashdatalist)
  private
   finstancepo: pfontcache;
  protected
   function hashkey(const akey): hashvaluety; override;
   function checkkey(const akey; 
                       const aitem: phashdataty): boolean; override;
   procedure finalizeitem(const aitem: phashdataty); override;
   function find(const afont: fontdataty): pfontcachehashdataty;

   procedure internalfreefont(const afont: ptruint); virtual;
   function internalgetfont(const ainfo: getfontinfoty;
                             out aheight: integer): boolean; virtual; abstract;
   procedure updatefontinfo(const adataoffset: hashoffsetty;
                     var adata: fontcachedataty); virtual; abstract;
   function getdataoffsfont(const afont: fontty): hashoffsetty; virtual; abstract;
   function getrecordsize(): int32 override;
   public
   constructor create(var ainstance: tfontcache); 
   procedure getfont(var drawinfo: drawinfoty);
   procedure freefontdata(var drawinfo: drawinfoty);
   procedure gettext16width(var drawinfo: drawinfoty); virtual; abstract;
   procedure getchar16widths(var drawinfo: drawinfoty); virtual; abstract;
   procedure getfontmetrics(var drawinfo: drawinfoty); virtual; abstract;
   procedure drawstring16(var drawinfo: drawinfoty;
                                   const afont: fontty); virtual; abstract;
 end;

implementation
uses
 sysutils,msedynload; //release dynload needed in finalization
 
{ tfontcache }

constructor tfontcache.create(var ainstance: tfontcache);
begin
 finstancepo:= @ainstance;
 ainstance:= self;
 inherited create();
 fstate:= fstate + [hls_needsnull,hls_needsfinalize];
end;

procedure tfontcache.finalizeitem(const aitem: phashdataty);
begin
 finalize(pfontcachehashdataty(aitem)^.data);
end;

function tfontcache.hashkey(const akey): hashvaluety;
begin
 with fontdataty(akey) do begin
  result:= stringhash(h.name) xor h.d.height;
 end;
end;

function tfontcache.checkkey(const akey; const aitem: phashdataty): boolean;
begin
 with fontdataty(akey),pfontcachehashdataty(aitem)^.data do begin
  result:= (h.name = keyname) and (h.d.height = keyheight);
 end;
end;

function tfontcache.find(const afont: fontdataty): pfontcachehashdataty;
begin
 result:= pfontcachehashdataty(internalfind(afont));
end;

procedure tfontcache.getfont(var drawinfo: drawinfoty);
var
 po1: pfontcachehashdataty;
 h1: integer;
begin
 with drawinfo.getfont do begin
  ok:= true;
  po1:= find(fontdata^);
  with fontdata^ do begin 
   if po1 = nil then begin
    if not internalgetfont(drawinfo.getfont,h1) then begin
     font:= 0;
     ok:= false;
     exit;
    end;
    po1:= pfontcachehashdataty(internaladd(fontdata^));
    po1^.data.keyname:= fontdata^.h.name;
    po1^.data.keyheight:= fontdata^.h.d.height;
    po1^.data.font:= font;
    po1^.data.height:= h1;
    updatefontinfo(getdataoffs(@po1^.data),po1^.data);
   end;
   inc(po1^.data.refcount);
   font:= po1^.data.font;
   ascent:= po1^.data.ascent;
   descent:= po1^.data.descent;
   linespacing:= po1^.data.linespacing;
   realheight:= po1^.data.height;
   caretshift:= po1^.data.caretshift;
  end;
 end;
end;

(*
procedure tfontcache.getfont(var drawinfo: drawinfoty);
var
 po1: pfontcachedataty;
 po2: pftglfont;
begin
 with drawinfo.getfont do begin
  ok:= true;
  po1:= find(fontdata^);
  with fontdata^ do begin 
   getmem(pointer(font),ffontdatasize);
   with pftglfontty(font)^ do begin
    if po1 = nil then begin
     po2:= ftglcreatepixmapfont('/usr/share/fonts/truetype/arial.ttf');
     if po2 = nil then begin
      freemem(pointer(font));
      pointer(font):= nil;
      ok:= false;
      exit;
     end;
     po1:= @((internaladd(fontdata^)^.data));
     po1^.h.name:= fontdata^.h.name;
     po1^.h.height:= fontdata^.h.d.height;
     po1^.handle:= pointer(po2);
     ftglsetfontcharmap(po1^.handle,ft_encoding_unicode);
     ftglsetfontfacesize(po1^.handle,20,72);
    end;
    inc(po1^.refcount);
    handle:= po1^.handle;
    ascent:= round(ftglgetfontascender(handle));
    descent:= -round(ftglgetfontdescender(handle));
    linespacing:= round(ftglgetfontlineheight(handle));
    caretshift:= 0;
   end;
  end;
 end;
end;
*)
procedure tfontcache.internalfreefont(const afont: ptruint);
begin
 //dummy
end;

function tfontcache.getrecordsize(): int32;
begin
 result:= sizeof(fontcachehashdataty);
end;

procedure tfontcache.freefontdata(var drawinfo: drawinfoty);
var
 po1: pfontcachehashdataty;
begin
 with drawinfo.getfont.fontdata^ do begin
  if font <> 0 then begin
   po1:= getdatapo(getdataoffsfont(font));
   dec(po1^.data.refcount);
   if po1^.data.refcount = 0 then begin
    internalfreefont(font);
   end;
   internaldeleteitem(phashdataty(po1));
  end;
 end;
 if count = 0 then begin
  freeandnil(finstancepo^);
 end;
end;

end.
