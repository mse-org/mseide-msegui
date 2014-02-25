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
 msestrings;
 
procedure registerformats(const labels: array of string;
                           const filternames: array of msestring;
                           const filemasks: array of msestringarty);

implementation
uses
 msegraphicstream,msestream,mclasses,msebitmap,msestockobjects,
 msegraphicsmagick,msegraphics,msegraphutils;
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
 
function readgraphic(const source: tstream; const index: integer; 
                const dest: tobject): boolean;
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
   case quantumdepth of
    qd_8: begin
     with pimage8(image)^ do begin
      bo1:= a.matte = magicktrue;
      si1:= ms(a.rows,a.columns);
     end;
    end;
    qd_16: begin
     with pimage16(image)^ do begin
      bo1:= a.matte = magicktrue;
      si1:= ms(a.rows,a.columns);
     end;
    end;
    else begin
     with pimage32(image)^ do begin
      bo1:= a.matte = magicktrue;
      si1:= ms(a.rows,a.columns);
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
  magickfree(imageinfo);
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
  registergraphicformat(labels[int1],@readgraphic,nil,
                           filternames[int1],filemasks[int1]);
 end;
end;


initialization
finalization
 if inited then begin
  releasegraphicsmagick();
  inited:= false;
 end;
end.
