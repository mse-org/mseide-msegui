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
 msehash,msegraphics;
 
type
 fontcachedataty = record
//  h: fontcachehdataty;
  height: integer;
  name: string;
  refcount: integer;

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
   function checkkey(const akey; const aitemdata): boolean; override;
   procedure finalizeitem(var aitemdata); override;
   function find(const afont: fontdataty): pfontcachedataty;
   procedure internalfreefont(const afont: ptruint); virtual;
   function internalgetfont(const ainfo: getfontinfoty): boolean;
                                                    virtual; abstract;
   procedure updatefontinfo(var adata: fontcachedataty); virtual; abstract;
  public
   constructor create(var ainstance: tfontcache); 
   procedure getfont(var drawinfo: drawinfoty);
   procedure freefontdata(var drawinfo: drawinfoty);
   procedure gettext16width(var drawinfo: drawinfoty); virtual; abstract;
   procedure getchar16widths(var drawinfo: drawinfoty); virtual; abstract;
   procedure getfontmetrics(var drawinfo: drawinfoty); virtual; abstract;
 end;

implementation
uses
 sysutils;
 
{ tfontcache }

constructor tfontcache.create(var ainstance: tfontcache);
begin
 finstancepo:= @ainstance;
 ainstance:= self;
 inherited create(sizeof(fontcachedataty));
 fstate:= fstate + [hls_needsnull,hls_needsfinalize];
end;

procedure tfontcache.finalizeitem(var aitemdata);
begin
 finalize(fontcachedataty(aitemdata));
end;

function tfontcache.hashkey(const akey): hashvaluety;
begin
 with fontdataty(akey) do begin
  result:= stringhash(h.name) xor h.d.height;
 end;
end;

function tfontcache.checkkey(const akey; const aitemdata): boolean;
begin
 with fontdataty(akey),fontcachedataty(aitemdata) do begin
  result:= (h.name = name) and (h.d.height = height);
 end;
end;

function tfontcache.find(const afont: fontdataty): pfontcachedataty;
begin
 result:= pointer(internalfind(afont));
 if result <> nil then begin
  result:= @pfontcachehashdataty(result)^.data;
 end;
end;

procedure tfontcache.getfont(var drawinfo: drawinfoty);
var
 po1: pfontcachedataty;
begin
 with drawinfo.getfont do begin
  ok:= true;
  po1:= find(fontdata^);
  with fontdata^ do begin 
   font:= 0;
   if po1 = nil then begin
    if not internalgetfont(drawinfo.getfont) then begin
     ok:= false;
     exit;
    end;
    po1:= @((internaladd(fontdata^)^.data));
    po1^.name:= fontdata^.h.name;
    po1^.height:= fontdata^.h.d.height;
    po1^.font:= font;
    updatefontinfo(po1^);
   end;
   inc(po1^.refcount);
   ascent:= po1^.ascent;
   descent:= po1^.descent;
   linespacing:= po1^.linespacing;
   caretshift:= po1^.caretshift;
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

procedure tfontcache.freefontdata(var drawinfo: drawinfoty);
var
 po1: pfontcachedataty;
begin
 with drawinfo.getfont do begin
  po1:= find(fontdata^);
  dec(po1^.refcount);
  with fontdata^ do begin 
   if po1^.refcount = 0 then begin
    internalfreefont(font);
   end;
   internaldeleteitem(phashdatadataty(po1));
  end;
 end;
 if count = 0 then begin
  freeandnil(finstancepo^);
 end;
end;

end.
