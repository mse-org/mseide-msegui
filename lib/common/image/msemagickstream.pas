{ MSEgui Copyright (c) 2014 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msemagickstream;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msestrings,msegraphicsmagick,sysutils;
type
 tmagickexception = class(exception)
  public
   constructor create(const ainfo: exceptioninfo);
 end;
  
procedure registerformats(const labels: array of string;
                           const filternames: array of msestring;
                           const filemasks: array of msestringarty);
implementation
uses
 msegraphicstream,msestream,mclasses,msebitmap,msestockobjects,
 msegraphics,msegraphutils,msetypes,msectypes;

type
 tbitmap1 = class(tbitmap);
 
var
 inited: boolean;
 qdepth: quantumdepthty; 

procedure checkinit;
begin
 if not inited then begin
  inited:= true;
  initializegraphicsmagick([]);
  qdepth:= quantumdepth();
 end;
end;

procedure writegraphic(const dest: tstream;
                               const source: tobject; const format: string;
                               const params: array of const);
var
 exceptinf: exceptioninfo;
 procedure error;
 begin
  raise tmagickexception.create(exceptinf);
 end;

var
 bo1,bo2,hasmask: boolean;
 imagebuffer: imagebufferinfoty;
 imageinfo: pointer;
 image: pointer;
 si: size_t;
 blob: pointer;
 int1: integer;
 po1: pointer;
 pp8: pixelpacket8;
 pp16: pixelpacket16;
 pp32: pixelpacket32;
 
begin
 if source is tbitmap then begin
  with tbitmap1(source) do begin
   if hasimage then begin
    checkinit;
    getexceptioninfo(@exceptinf);
    imageinfo:= nil;
    image:= nil;
    blob:= nil;
    try
     hasmask:= (source is tmaskedbitmap) and (tmaskedbitmap(source).masked);
     bo1:= getimageref(imagebuffer.image);
     bo2:= false;
     if hasmask then begin
      bo2:= tbitmap1(tmaskedbitmap(source).mask).getimageref(imagebuffer.mask);
     end;
     if imagebuffer.image.monochrome then begin
      imageinfo:= cloneimageinfo(nil);
      image:= allocateimage(imageinfo);
      allocateimagecolormap(image,2);
      case qdepth of
       qd_8: begin
        with pimage8(image)^ do begin
         a.columns:= imagebuffer.image.size.cx;
         a.rows:= imagebuffer.image.size.cy;
         a.depth:= 1;
         pp8:= ppixelpacket8(b.colormap)[0]; //swap black and white
         ppixelpacket8(b.colormap)[0]:= ppixelpacket8(b.colormap)[1];
         ppixelpacket8(b.colormap)[1]:= pp8;
        end;
       end;
       qd_16: begin
        with pimage16(image)^ do begin
         a.columns:= imagebuffer.image.size.cx;
         a.rows:= imagebuffer.image.size.cy;
         a.depth:= 1;
        end;
       end;
       else begin
        with pimage32(image)^ do begin
         a.columns:= imagebuffer.image.size.cx;
         a.rows:= imagebuffer.image.size.cy;
         a.depth:= 1;
        end;
       end;
      end;
      po1:= imagebuffer.image.pixels;
      for int1:= 0 to imagebuffer.image.size.cy-1 do begin
       if setimagepixels(image,0,int1,
                            imagebuffer.image.size.cx,1) = nil then begin
        error();
       end;
       if importimagepixelarea(image,indexquantum,1,po1,
                                            nil,nil) = magickfail then begin
        error();
       end;
       if SyncImagePixels(image) = 0 then begin
        error();
       end;
       inc(po1,scanlinestep);
      end;
     end
     else begin
      image:= constituteimage(imagebuffer.image.size.cx,
                imagebuffer.image.size.cy,'BGRP',charpixel,
                                imagebuffer.image.pixels,@exceptinf);
      if image = nil then begin
       raise tmagickexception.create(exceptinf);
      end;
      imageinfo:= cloneimageinfo(nil);
     end;
     case qdepth of
      qd_8: begin
       with pimage8(image)^ do begin
        c.magick:= uppercase(format);
       end;
      end;
      qd_16: begin
       with pimage16(image)^ do begin
        c.magick:= uppercase(format);
       end;
      end;
      else begin
       with pimage32(image)^ do begin
        c.magick:= uppercase(format);
       end;
      end;
     end;
     blob:= imagetoblob(imageinfo,image,@si,@exceptinf);
     if blob = nil then begin
      error();
     end;
     dest.writebuffer(blob^,si);
    finally
     if blob <> nil then begin
      magickfree(blob);
     end;
     if imageinfo <> nil then begin
      destroyimageinfo(imageinfo);
     end;
     if image <> nil then begin
      destroyimage(image);
     end;
     destroyexceptioninfo(@exceptinf);
     if bo1 then begin
      freeimage(imagebuffer.image);
     end;
     if bo2 then begin
      freeimage(imagebuffer.mask);
     end;
    end;
   end;
  end;
 end;
end;
 
function readgraphic(const source: tstream;
                const dest: tobject; var format: string;
                const params: array of const): boolean;
var
 imageinfo: pointer;
 exceptinf: exceptioninfo;
 image: pointer;
 imagebuffer: imagebufferinfoty;
 str1: string; //todo: use tstream -> c-stream adaptor
 bo1,bo2: boolean;
 si1: sizety;
begin
 result:= false;
 if dest is tbitmap then begin
  imagebuffer.image.pixels:= nil;
  imagebuffer.mask.pixels:= nil;
  checkinit;
  str1:= source.readdatastring;
  getexceptioninfo(@exceptinf);
  bo2:= dest is tmaskedbitmap;
  imageinfo:= cloneimageinfo(nil);
  image:= blobtoimage(imageinfo,pointer(str1),length(str1),@exceptinf);
  if image <> nil then begin
   case qdepth of
    qd_8: begin
     with pimage8(image)^ do begin
      bo1:= a.matte = magicktrue;
      si1:= ms(a.columns,a.rows);
      format:= lowercase(c.magick);
      if format = '' then begin
       format:= lowercase(c.magick_filename);
      end;
     end;
    end;
    qd_16: begin
     with pimage16(image)^ do begin
      bo1:= a.matte = magicktrue;
      si1:= ms(a.columns,a.rows);
      format:= lowercase(c.magick);
      if format = '' then begin
       format:= lowercase(c.magick_filename);
      end;
     end;
    end;
    else begin
     with pimage32(image)^ do begin
      bo1:= a.matte = magicktrue;
      si1:= ms(a.columns,a.rows);
      format:= lowercase(c.magick);
      if format = '' then begin
       format:= lowercase(c.magick_filename);
      end;
     end;
    end;
   end;
   allocimage(imagebuffer.image,si1,false);
   if dispatchimage(image,0,0,si1.cx,si1.cy,'BGRP',charpixel,
            imagebuffer.image.pixels,@exceptinf) = magickpass then begin
    if bo1 and bo2 then begin
     allocimage(imagebuffer.mask,si1,false);
     if dispatchimage(image,0,0,si1.cx,si1.cy,'AAAP',charpixel,
            imagebuffer.mask.pixels,@exceptinf) = magickpass then begin
      result:= true;
     end;
    end
    else begin
     result:= true;
    end;
   end;
   destroyimage(image);
  end;
  destroyimageinfo(imageinfo);
  destroyexceptioninfo(@exceptinf);
  if result then begin
   if bo2 then begin
    tmaskedbitmap(dest).loadfromimagebuffer(imagebuffer);
   end
   else begin
    tbitmap(dest).loadfromimage(imagebuffer.image);
   end;
   tbitmap(dest).change;
  end;
  freeimage(imagebuffer.image);
  freeimage(imagebuffer.mask);
 end;
end;

procedure registerformats(const labels: array of string;
                           const filternames: array of msestring;
                           const filemasks: array of msestringarty);
var
 int1: integer;
begin
 for int1:= 0 to high(labels) do begin
  registergraphicformat(labels[int1],@readgraphic,@writegraphic,
                           filternames[int1],filemasks[int1]);
 end;
end;

{ tmagickexception }

constructor tmagickexception.create(const ainfo: exceptioninfo);
begin
 inherited create('GraphicsMagick exception'+lineend+ainfo.reason+lineend+
                         ainfo.description);
end;

initialization
finalization
 if inited then begin
  releasegraphicsmagick();
  inited:= false;
 end;
end.
