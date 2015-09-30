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
unit mseftfontcache;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

//todo: limit buffer size

interface
uses
 msefontcache,msegraphics,msestrings,msetypes,mseguiglob,msegraphutils;
 
type
 bitmapdataty = record
  width: smallint;
  height: smallint;
  left: smallint;
  top: smallint;
  data: record
  end;
 end;
 pbitmapdataty= ^bitmapdataty;
 
 tftfontcache = class(tfontcache)
  protected
   procedure internalfreefont(const afont: ptruint); override;
   function internalgetfont(const ainfo: getfontinfoty;
                              out aheight: integer): boolean; override;
   procedure updatefontinfo(const adataoffset: longword;
                                var adata: fontcachedataty); override;
   procedure drawglyph(var drawinfo: drawinfoty; const pos: pointty;
                       const bitmap: pbitmapdataty); virtual; abstract;
   function getdataoffs(const afont: fontty): longword; override;
   function textbackgroundrect(const drawinfo: drawinfoty;
                        const afont: fontty; out arect: rectty): boolean;
  public
   constructor create(var ainstance: tftfontcache);
   destructor destroy; override;
   procedure gettext16width(var drawinfo: drawinfoty); override;
   procedure getchar16widths(var drawinfo: drawinfoty); override;
   procedure getfontmetrics(var drawinfo: drawinfoty); override;
   procedure drawstring16(var drawinfo: drawinfoty;
                                    const afont: fontty); override;
 end;
 
implementation
uses
 msefreetype,msefontconfig,msefcfontselect,math;

const
 charcount = $10000; //UCS2
 bucketshift = 9;    //charrowlength = 128
 charbucketcount = 1 shl bucketshift;
 charrowlength = charcount div charbucketcount;
 charrowmask = charrowlength - 1;

type
 glyphinfoty = record
  width: smallint;
  leftbearing: smallint;
  rightbearing: smallint;
  bitmap: longword; //buffer offset to bitmapdatatyty 0->not rendered yet
 end;
 
 pglyphinfoty = ^glyphinfoty;
 charrowty = array[0..charrowlength-1] of longword; //offset in buffer
 pcharrowty = ^charrowty; 
 charbucketty = array[0..charbucketcount-1] of longword; 
                              //offset to charrowty in buffer
 tftface = class
  private
   fface: pft_face;
   fbuckets: charbucketty;
   fbuffer: pointer;
   fsize: longword;
   fcapacity: longword;
  protected
   fdataoffset: longword;
   fascent: integer;
   fdescent: integer;
   fglyphheight: integer;
   flinespacing: integer;
   function getbuffer(const asize: integer; const ainit: boolean): longword;
  public
   constructor create(const aface: pft_face);
   destructor destroy; override;
   function getglyph(const achar: msechar; out ainfo: pglyphinfoty;
               const forceload: boolean): boolean;
                            //true if found
   procedure renderglyph(var ainfo: pglyphinfoty);
 end;

{ tftfontcache }

constructor tftfontcache.create(var ainstance: tftfontcache);
begin
 initializefreetype([]);
 initializefontconfig([]);
 inherited create(tfontcache(ainstance));
end;

destructor tftfontcache.destroy;
begin
 inherited;
 releasefreetype;
 releasefontconfig;
end;

procedure tftfontcache.internalfreefont(const afont: ptruint);
begin
 tftface(pointer(afont)).free;
end;

function tftfontcache.internalgetfont(const ainfo: getfontinfoty;
                                            out aheight: integer): boolean;
var
 ftface: pft_face;
 str1: string;
 int1: integer;
begin
 result:= false;
 with ainfo do begin
  if getfcfontfile(ainfo,str1,int1,aheight) then begin
   if ft_new_face(ftlib,pchar(str1),int1,ftface) = 0 then begin
    if ft_set_pixel_sizes(ftface,0,aheight) = 0 then begin
     pointer(fontdata^.font):= tftface.create(ftface);
     result:= true;
    end;
   end;
  end;
 end;
end;

procedure tftfontcache.updatefontinfo(const adataoffset: longword;
                                              var adata: fontcachedataty);
var
 scale: real;
begin
 with tftface(pointer(adata.font)),fface^ do begin
  fdataoffset:= adataoffset;
  scale:= adata.height/units_per_em;
  fascent:= round(ascender*scale);
  fdescent:= -round(descender*scale);
  fglyphheight:= fascent+fdescent;
  flinespacing:= ceil(height*scale);
  adata.ascent:= fascent;
  adata.descent:= fdescent;
  adata.height:= fglyphheight;
  adata.linespacing:= flinespacing;
  adata.caretshift:= 0;
 end;
end;

procedure tftfontcache.gettext16width(var drawinfo: drawinfoty);
var
 po1: pmsecharaty;
 po3: pglyphinfoty;
 face1: tftface;
 int1,int2: integer;
begin
 with drawinfo.gettext16width do begin
  face1:= tftface(pointer(fontdata^.font));
  po1:= pointer(text);
  face1:= tftface(pointer(fontdata^.font));
  int2:= 0;
  for int1:= count-1 downto 0 do begin
   if face1.getglyph(po1^[int1],po3,false) then begin
    int2:= int2 + po3^.width;
   end
  end;
  result:= int2;
 end;
end;

procedure tftfontcache.getchar16widths(var drawinfo: drawinfoty);
var
 int1: integer;
 po1: pmsecharaty;
 po2: pintegeraty;
 po3: pglyphinfoty;
 face1: tftface;
begin
 with drawinfo.getchar16widths do begin
  face1:= tftface(pointer(fontdata^.font));
  po1:= pointer(text);
  po2:= pointer(resultpo);
  for int1:= count-1 downto 0 do begin
   if face1.getglyph(po1^[int1],po3,false) then begin
    po2^[int1]:= po3^.width;
   end
   else begin
    po2^[int1]:= 0;
   end;
  end;
 end;
end;

procedure tftfontcache.getfontmetrics(var drawinfo: drawinfoty);
var
 face: tftface;
 po1: pglyphinfoty;
begin
 with drawinfo.getfontmetrics do begin
  face:= tftface(pointer(fontdata^.font));
  if face.getglyph(msechar(char),po1,false) then begin //todo: 32bit
   with resultpo^ do begin
    width:= po1^.width;
    leftbearing:= po1^.leftbearing;
    rightbearing:= po1^.rightbearing; //correct???
   end;
  end
  else begin
   with resultpo^ do begin
    width:= 0;
    leftbearing:= 0;
    rightbearing:= 0;
   end;
  end;
 end;
end;

function tftfontcache.textbackgroundrect(const drawinfo: drawinfoty;
                               const afont: fontty; out arect: rectty): boolean;
                          
var
 face: tftface;
 po1: pglyphinfoty;
 po2: pmsecharaty;
 int1,int2: integer;
begin
 result:= false;
 with drawinfo,text16pos do begin
  if count = 0 then begin
   arect:= nullrect;
   exit;
  end;
  face:= tftface(pointer(afont));
  po2:= pointer(text);
  if face.getglyph(po2^[0],po1,false) then begin
   with arect do begin
    x:= text16pos.pos^.x {+ po1^.leftbearing};
    int2:= po1^.width {- po1^.leftbearing};
    for int1:= 1 to count - 1 do begin
     if face.getglyph(po2^[int1],po1,false) then begin
      int2:= int2+po1^.width;
     end;
    end;
    cx:= int2 {+ po1^.rightbearing};
    y:= text16pos.pos^.y - face.fascent;
    cy:= face.fglyphheight;
   end;
   result:= true;
  end;
 end;
end;

procedure tftfontcache.drawstring16(var drawinfo: drawinfoty;
                                                     const afont: fontty);
var
 face: tftface;
 po1: pglyphinfoty;
 po2: pmsecharaty;
 po3: pbitmapdataty;
 int1: integer;
// rect1: rectty;
 pt1: pointty;
 y1: integer;
begin
 with drawinfo,text16pos do begin
  if count = 0 then begin
   exit;
  end;
  pt1.x:= pos^.x + origin.x;
  y1:= pos^.y + origin.y - 1;
  face:= tftface(pointer(afont));
  po2:= pointer(text);
  for int1:= 0 to count-1 do begin
   if face.getglyph(po2^[int1],po1,true) then begin
    if po1^.bitmap = 0 then begin
     face.renderglyph(po1);
    end;
    if po1^.bitmap <> 0 then begin //render error otherwise
     po3:= pointer(pchar(face.fbuffer)+po1^.bitmap);
     pt1.x:= pt1.x + po3^.left;
     pt1.y:= y1 - po3^.top;
     drawglyph(drawinfo,pt1,po3);
    end;
    pt1.x:= pt1.x - po3^.left + po1^.width;
   end;
  end;
 end;
end;

function tftfontcache.getdataoffs(const afont: fontty): longword;
begin
 result:= tftface(pointer(afont)).fdataoffset;
end;

{ tftface }

constructor tftface.create(const aface: pft_face);
begin
 fface:= aface;
 fsize:= sizeof(longword); //dummy
 fcapacity:= 1024;
 getmem(fbuffer,fcapacity); 
end;

destructor tftface.destroy;
begin
 inherited;
 freemem(fbuffer);
 ft_done_face(fface);
end;

function tftface.getbuffer(const asize: integer;
               const ainit: boolean): longword;
begin
 result:= fsize;
 fsize:= (fsize + asize + 3) and not 3; //4 byte align
 if fsize > fcapacity then begin
  fcapacity:= fcapacity * 2 - fcapacity div 2; //* 1.5
  reallocmem(fbuffer,fcapacity);
 end;
 if ainit then begin
  fillchar((pchar(fbuffer)+result)^,asize,0);
 end;
end;

procedure tftface.renderglyph(var ainfo: pglyphinfoty); 
           //must be called after getglyph
var
 po1: pchar;
 so,de: pbyteaty;
 int1,int2,int3: integer;
 bm1: pbitmapdataty;
begin
 if ft_render_glyph(fface^.glyph,ft_render_mode_normal) = 0 then begin
  with fface^.glyph^,bitmap do begin
//todo: check bitmap format
   po1:= fbuffer;
   int3:= getbuffer(sizeof(bitmapdataty) + width * rows,false);
   ainfo:= pointer(pchar(ainfo) + 
                     (pchar(fbuffer) - pchar(po1)));
   ainfo^.bitmap:= int3;
   bm1:= pointer(pchar(fbuffer)+int3);
   bm1^.width:= width;
   bm1^.height:= rows;
   bm1^.left:= bitmap_left;
   bm1^.top:= bitmap_top-rows;
   de:= @bm1^.data;
   if pitch < 0 then begin
    so:= buffer;
   end
   else begin
    so:= pointer(pchar(buffer)+(rows-1)*pitch);
   end;
   for int1:= rows - 1 downto 0 do begin
    for int2:= width-1 downto 0 do begin
     de[int2]:= so[int2];
    end;
    de:= pointer(pchar(de)+width);
    so:= pointer(pchar(so)-pitch);
   end;
  end;
 end
end;
                         //todo: 32bit
function tftface.getglyph(const achar: msechar; out ainfo: pglyphinfoty; 
                        const forceload: boolean): boolean;
var
 int1,int2,int3: integer;
 po1: pcharrowty;
begin
 result:= true;
 int1:= word(achar) shr bucketshift;
 int2:= word(achar) and charrowmask;
 if fbuckets[int1] = 0 then begin
  fbuckets[int1]:= getbuffer(sizeof(charrowty),true);
 end;
 po1:= pcharrowty(pchar(fbuffer)+fbuckets[int1]);
 int3:= po1^[int2];
 if int3 = 0 then begin
  if ft_load_glyph(fface,ft_get_char_index(fface,ord(achar)),
                                          ft_load_default) = 0 then begin
   int3:= getbuffer(sizeof(glyphinfoty),false);
   po1^[int2]:= int3;
   ainfo:= pglyphinfoty(pchar(fbuffer)+int3);
   with fface^.glyph^ do begin
    ainfo^.width:= ftpostopixel(advance.x);
    ainfo^.leftbearing:= ftpostopixel(metrics.horibearingx);
    ainfo^.rightbearing:= ftpostopixel(metrics.horiadvance-metrics.width);
   end;
   ainfo^.bitmap:= 0; //not rendered yet
  end
  else begin
   ainfo:= nil;
   result:= false;
  end;
 end
 else begin
  if forceload then begin
   if ft_load_glyph(fface,ft_get_char_index(fface,ord(achar)),
                                              ft_load_default) <> 0 then begin
    result:= false;
   end;                                   
  end;
  ainfo:= pglyphinfoty(pchar(fbuffer)+int3);
 end;
end;

end.
