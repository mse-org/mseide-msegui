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
  data: record
  end;
 end;
 pbitmapdataty= ^bitmapdataty;
 
 tftfontcache = class(tfontcache)
  protected
   procedure internalfreefont(const afont: ptruint); override;
   function internalgetfont(const ainfo: getfontinfoty;
                   var aheight: integer): boolean; override;
   procedure updatefontinfo(var adata: fontcachedataty); override;
   procedure drawglyph(var drawinfo: drawinfoty; const pos: pointty;
                       const bitmap: pbitmapdataty); virtual; abstract;
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
 msefreetype;

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
  bitmap: bitmapdataty;
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
   function getbuffer(const asize: integer; const ainit: boolean): longword;
  public
   constructor create(const aface: pft_face);
   destructor destroy; override;
   function getglyph(const achar: msechar): pglyphinfoty;
 end;

{ tftfontcache }

constructor tftfontcache.create(var ainstance: tftfontcache);
begin
 initializefreetype([]);
 inherited create(tfontcache(ainstance));
end;

destructor tftfontcache.destroy;
begin
 inherited;
 releasefreetype;
end;

procedure tftfontcache.internalfreefont(const afont: ptruint);
begin
 tftface(pointer(afont)).free;
end;

function tftfontcache.internalgetfont(const ainfo: getfontinfoty;
                                            var aheight: integer): boolean;
var
 ftface: pft_face;
begin
 result:= false;
 with ainfo do begin
  if ft_new_face(ftlib,
               '/usr/share/fonts/truetype/arial.ttf',0,ftface) = 0 then begin
   if aheight <= 0 then begin
    aheight:= 14;
   end;
   if ft_set_pixel_sizes(ftface,0,aheight) = 0 then begin
    pointer(fontdata^.font):= tftface.create(ftface);
    result:= true;
   end;
  end;
 end;
end;

procedure tftfontcache.updatefontinfo(var adata: fontcachedataty);
var
 scale: real;
begin
 with tftface(pointer(adata.font)).fface^ do begin
  scale:= adata.height/units_per_em;
  adata.ascent:= round(ascender*scale);
  adata.descent:= -round(descender*scale);
//  adata.height:= height;
  adata.linespacing:= adata.ascent + adata.descent;
  adata.caretshift:= 0;
 end;
end;

procedure tftfontcache.gettext16width(var drawinfo: drawinfoty);
begin
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
   po3:= face1.getglyph(po1^[int1]);
   po2^[int1]:= po3^.width;   
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
  po1:= face.getglyph(char);
  with resultpo^ do begin
   width:= po1^.width;
   leftbearing:= po1^.leftbearing;
   rightbearing:= po1^.rightbearing; //correct???
  end;
 end;
end;

procedure tftfontcache.drawstring16(var drawinfo: drawinfoty;
                                                     const afont: fontty);
var
 face: tftface;
 po1: pglyphinfoty;
 po2: pmsecharaty;
 int1: integer;
 pt1: pointty;
begin
 with drawinfo.text16pos do begin
  pt1:= pos^;
  face:= tftface(pointer(afont));
  po2:= pointer(text);
  for int1:= 0 to count-1 do begin
   po1:= face.getglyph(po2^[int1]);
   pt1.x:= pt1.x + po1^.leftbearing;
   drawglyph(drawinfo,pt1,@po1^.bitmap);
   pt1.x:= pt1.x - po1^.leftbearing + po1^.width;
  end;
 end;
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

function tftface.getglyph(const achar: msechar): pglyphinfoty;
var
 int1,int2,int3,int4: integer;
 po1: pcharrowty;
begin
 int1:= word(achar) shr bucketshift;
 int2:= word(achar) and charrowmask;
 if fbuckets[int1] = 0 then begin
  fbuckets[int1]:= getbuffer(sizeof(charrowty),true);
 end;
 po1:= pcharrowty(pchar(fbuffer)+fbuckets[int1]);
 int3:= po1^[int2];
 if int3 = 0 then begin
  if ft_load_glyph(fface,ft_get_char_index(fface,ord(achar)),
                                          ft_load_render) <> 0 then begin
   ftcheckerror(ft_load_glyph(fface,0,ft_load_render));
      //try to load defaultglyph, exception if not possible
  end;   
  with fface^.glyph^ do begin
//todo: check bitmap format
   int4:= bitmap.pitch * bitmap.rows;
   int3:= getbuffer(sizeof(glyphinfoty)+int4,false);
   po1^[int2]:= int3;
   result:= pglyphinfoty(pchar(fbuffer)+int3);
   result^.width:= ftpostopixel(advance.x);
   result^.leftbearing:= ftpostopixel(metrics.horibearingx);
   result^.rightbearing:= ftpostopixel(metrics.horiadvance-metrics.width);
   with bitmap do begin
    result^.bitmap.width:= width;
    result^.bitmap.height:= rows;
    move(buffer^,result^.bitmap.data,int4);
   end;
  end;
 end
 else begin
  result:= pglyphinfoty(pchar(fbuffer)+int3);
 end;
end;

end.
