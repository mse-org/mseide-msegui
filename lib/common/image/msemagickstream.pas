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
 msestrings,msegraphicsmagick,sysutils,mclasses,msebitmap,msegraphutils;
type
 tmagickexception = class(exception)
  public
   constructor create(const ainfo: exceptioninfo);
 end;
 gminfoty = record
  formatlabel: string;
  size: sizety;
  depth: integer;
 end;
 readgmoptionty = (rgmo_rotmonomask);
 readgmoptionsty = set of readgmoptionty;
 
procedure registerformats(const labels: array of string;
                           const filternames: array of msestring;
                           const filemasks: array of msestringarty);
//readgraphic parameters:
  //[index: integer, width: integer, height: integer, rotation: real,
     //sequence nr      0 = default     0 = default   0..2pi CCW
     // -1 = default
  // backgroundcolor: colorty, pixelpermm: real, options: readgmoptionsty]
  //  default = cl_transparent  0 = default        default = []
           
//writegraphic parameters:
  //[compressionquality: integer, width: integer, height: integer,
      // 0..100, -1 = default        0 = default      0 = default
  //     rotation: real,        backgroundcolor: colorty, pixelpermm: real]
  //       0..2pi CCW default 0 default = cl_transparent     0 = default

function readgmgraphic(const source: tstream; const dest: tbitmap;
       const aindex: integer = -1; const awidth: integer = 0;
        const aheight: integer = 0; const arotation: real = 0;
         const abackgroundcolor: colorty = cl_transparent;
         const apixelpermm: real = 0;
         const aoptions: readgmoptionsty = []): string;
              //returns label
procedure writegmgraphic(const dest: tstream; const source: tbitmap;
           const format: string; const aquality: integer = -1;
             const awidth: integer = 0; const aheight: integer = 0;
             const rotation: real = 0;
              const backgroundcolor: colorty = cl_transparent;
              const pixelpermm: real = 0);
function pinggmgraphic(const source: tstream; 
                      out ainfo: gminfoty): boolean;

implementation
uses
 msegraphics,msegraphicstream,msestream,msestockobjects,
 msetypes,msectypes,msebits,mseclasses,mseformatstr;

type
 tbitmap1 = class(tbitmap);
const
 ppmmtoppi = 25.4; 
var
 inited: boolean;
 qdepth: quantumdepthty; 

procedure checkinit;
begin
 if not inited then begin
  initializegraphicsmagick([],[]);
  qdepth:= quantumdepth();
  inited:= true;
 end;
end;

procedure setcolor(const acolor: colorty; const dest: pointer;
                                            const index: integer = 0);
var
 rgb: rgbtriplety;
 opac: card32;
begin
 if acolor = cl_transparent then begin
  opac:= $ffffffff;
 end
 else begin
  opac:= 0;
 end;
 rgb:= colortorgb(acolor);
 case qdepth of 
  qd_8: begin
   with ppixelpacket8(dest)[index] do begin
    red:= rgb.red;
    green:= rgb.green;
    blue:= rgb.blue;
    opacity:= opac;
   end;
  end;
  qd_16: begin
   with ppixelpacket16(dest)[index] do begin
    red:= rgb.red + (rgb.red shl 8);
    green:= rgb.green + (rgb.green shl 8);
    blue:= rgb.blue + (rgb.blue shl 8);
    opacity:= opac;
   end;
  end;
  qd_32: begin
   with ppixelpacket32(dest)[index] do begin
    red:= rgb.red + (rgb.red shl 8)+ (rgb.red shl 16)+ (rgb.red shl 24);
    green:= rgb.green + (rgb.green shl 8) + (rgb.green shl 16) +
                                                         (rgb.green shl 24);
    blue:= rgb.blue + (rgb.blue shl 8) + (rgb.blue shl 16) + (rgb.blue shl 24);
    opacity:= opac;
   end;
  end;
 end;
end;

procedure setimagebackgroundcolor(const image: pointer; color: colorty);
begin
 case qdepth of
  qd_8: begin
   with pimage8(image)^ do begin
    setcolor(color,@b.background_color);
   end;
  end;
  qd_16: begin
   with pimage16(image)^ do begin
    setcolor(color,@b.background_color);
   end;
  end;
  else begin
   with pimage32(image)^ do begin
    setcolor(color,@b.background_color);
   end;
  end;
 end;
end;

procedure swapbits(var aimage: imagety);
var
 po1,e: pbyte;
begin
 with aimage do begin
  po1:= pointer(pixels);
  e:= po1 + length*4-1;
  repeat
   po1^:= bitreverse[po1^];
   inc(po1);
  until po1 = e;
 end;
end;

function gmstring(const avalue: string): pcchar;
begin
 result:= magickmalloc(length(avalue)+1);
 move(pchar(avalue)^,result^,length(avalue)+1);
end;

function fitscale(const width: integer; const height: integer;
                          const current: sizety; out dest: sizety): boolean;
                          //true if scaling necessary
begin
 dest:= current;
 if width <> 0 then begin
  dest.cx:= width;
 end;
 if height <> 0 then begin
  dest.cy:= height;
 end;
 result:= (current.cx > 0) and (current.cy > 0);
 if result then begin
  if dest.cx*current.cy > dest.cy*current.cx then begin
   dest.cx:= (current.cx*dest.cy) div current.cy;
  end
  else begin
   dest.cy:= (current.cy*dest.cx) div current.cx;
  end;
  result:= (current.cx <> dest.cx) or (current.cy <> dest.cy);
 end;
end;

procedure writegmgraphic(const dest: tstream; const source: tbitmap;
            const format: string; const aquality: integer = -1;
            const awidth: integer = 0; const aheight: integer = 0;
            const rotation: real = 0;
            const backgroundcolor: colorty = cl_transparent;
            const pixelpermm: real = 0);
var
 exceptinf: exceptioninfo;
 procedure error;
 begin
  raise tmagickexception.create(exceptinf);
 end;

var
 bo1,bo2,hasmask,monomask: boolean;
 imagebuffer: imagebufferinfoty;
 imageinfo: pointer;
 image,image2: pointer;
 si: size_t;
 blob: pointer;
 int1: integer;
 po1,po2: pointer;
 s,d,e,e1: prgbtriplety;
 s1,s2: plongword;
 lwo1: longword;
 buf: pointer;
 bd,be,be1: pbyte;
 si1,si2: sizety;
begin
 if source is tbitmap then begin
  with tbitmap1(source) do begin
   if hasimage then begin
    checkinit;
    getexceptioninfo(@exceptinf);
    imageinfo:= nil;
    image:= nil;
    blob:= nil;
    buf:= nil;
    try
     monomask:= false;
     hasmask:= (source is tmaskedbitmap) and (tmaskedbitmap(source).masked);
     if hasmask then begin
      with tmaskedbitmap(source).mask do begin
       monomask:= monochrome;
      end;
     end;
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
         if hasmask then begin
          a.matte:= magicktrue;
         end;
         setcolor(colorbackground,b.colormap,0);
         setcolor(colorforeground,b.colormap,1);
        end;
       end;
       qd_16: begin
        with pimage16(image)^ do begin
         a.columns:= imagebuffer.image.size.cx;
         a.rows:= imagebuffer.image.size.cy;
         a.depth:= 1;
         if hasmask then begin
          a.matte:= magicktrue;
         end;
         setcolor(colorbackground,b.colormap,0);
         setcolor(colorforeground,b.colormap,1);
        end;
       end;
       else begin
        with pimage32(image)^ do begin
         a.columns:= imagebuffer.image.size.cx;
         a.rows:= imagebuffer.image.size.cy;
         a.depth:= 1;
         if hasmask then begin
          a.matte:= magicktrue;
         end;
         setcolor(colorbackground,b.colormap,0);
         setcolor(colorforeground,b.colormap,1);
        end;
       end;
      end;
      with imagebuffer.image do begin
       swapbits(imagebuffer.image);
       if hasmask then begin
        int1:= scanhigh+1;
        getmem(buf,int1);
        bd:= buf;
        be:= buf + int1;
        if monomask then begin
         s1:= pointer(imagebuffer.mask.pixels);
         repeat
          lwo1:= $00000001;
          s2:= s1;
          be1:= bd + width;
          repeat
           if s2^ and lwo1 <> 0 then begin
            bd^:= $ff;
           end
           else begin
            bd^:= 0;
           end;
           lwo1:= lwo1 shl 1;
           if lwo1 = 0 then begin
            inc(s2);
            lwo1:= $00000001;
           end;
           inc(bd);
          until bd = be1;
          s1:= pointer(s1) + imagebuffer.mask.linebytes;
         until bd = be;
        end
        else begin
         s:= pointer(imagebuffer.mask.pixels);
         repeat
          bd^:= (s^.red + s^.green + s^.blue) div 3;
          inc(s);
          inc(bd);
         until bd = be;
        end;
       end;
       po1:= pixels;
       po2:= buf;
       for int1:= 0 to imagebuffer.image.size.cy-1 do begin
        if setimagepixels(image,0,int1,
                             imagebuffer.image.size.cx,1) = nil then begin
         error();
        end;
        if importimagepixelarea(image,indexquantum,1,po1,
                                             nil,nil) = magickfail then begin
         error();
        end;
        if hasmask then begin
         if importimagepixelarea(image,alphaquantum,8,po2,
                                             nil,nil) = magickfail then begin
          error();
         end;
         inc(po2,width);
        end;
        if SyncImagePixels(image) = 0 then begin
         error();
        end;
        inc(po1,scanlinestep);
       end;
       if not bo1 then begin //restore pixel order
        swapbits(imagebuffer.image);
       end;
       if {ispng and} hasmask then begin //GraphicMagick removes 
                                       //alpha channel for palette images
        case qdepth of
         qd_8: begin
          with pimage8(image)^ do begin
           a.colors:= 0;
           magickfree(b.colormap);
           b.colormap:= nil;
           a.storage_class:= directclass;
          end;
         end;
         qd_16: begin
          with pimage16(image)^ do begin
           a.colors:= 0;
           magickfree(b.colormap);
           b.colormap:= nil;
           a.storage_class:= directclass;
          end;
         end;
         qd_32: begin
          with pimage32(image)^ do begin
           a.colors:= 0;
           magickfree(b.colormap);
           b.colormap:= nil;
           a.storage_class:= directclass;
          end;
         end;
        end;
       end;
      end;
     end
     else begin //color
      if hasmask then begin
       d:= pointer(imagebuffer.image.pixels);
       e:= d + imagebuffer.image.length;
       if monomask then begin
        s1:= pointer(imagebuffer.mask.pixels);
        repeat
         lwo1:= $00000001;
         s2:= s1;
         e1:= d + width;
         repeat
          if s2^ and lwo1 <> 0 then begin
           d^.res:= $ff;
          end
          else begin
           d^.res:= 0;
          end;
          lwo1:= lwo1 shl 1;
          if lwo1 = 0 then begin
           inc(s2);
           lwo1:= $00000001;
          end;
          inc(d);
         until d = e1;
         s1:= pointer(s1) + imagebuffer.mask.linebytes;
        until d = e;
       end
       else begin
        s:= pointer(imagebuffer.mask.pixels);
        repeat
         d^.res:= (s^.red + s^.green + s^.blue) div 3;
         inc(s);
         inc(d);
        until d = e;
       end;
       image:= constituteimage(imagebuffer.image.size.cx,
                imagebuffer.image.size.cy,'BGRA',charpixel,
                                imagebuffer.image.pixels,@exceptinf);
       if not bo1 then begin //restore res byte
        s:= pointer(imagebuffer.mask.pixels);
        d:= pointer(imagebuffer.image.pixels);
        repeat
         d^.res:= 0;
         inc(d);
        until d = e;
       end;
      end
      else begin
       image:= constituteimage(imagebuffer.image.size.cx,
                imagebuffer.image.size.cy,'BGRP',charpixel,
                                imagebuffer.image.pixels,@exceptinf);
      end;
      if image = nil then begin
       raise tmagickexception.create(exceptinf);
      end;
      imageinfo:= cloneimageinfo(nil);
     end;
     with pimageinfo8(imageinfo)^ do begin
      if aquality >= 0 then begin
       a.quality:= aquality;
      end;
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
     si1:= imagebuffer.image.size;
     if rotation <> 0 then begin
      image2:= rotateimage(image,rotation*(-180/pi),@exceptinf);
      if image2 = nil then begin
       exit;
      end;
      destroyimage(image);
      image:= image2;
      si1:= ms(pimage8(image)^.a.columns,pimage8(image)^.a.rows);
     end;

     if fitscale(awidth,aheight,si1,si2) then begin
      image2:= scaleimage(image,si2.cx,si2.cy,@exceptinf);
      if image2 = nil then begin
       exit;
      end;
      destroyimage(image);
      image:= image2;
     end;
     if pixelpermm > 0 then begin
      with pimageinfo8(imageinfo)^ do begin
       a.units:= pixelsperinchresolution;
       a.density:= gmstring(formatfloatmse(pixelpermm*ppmmtoppi,'',true));
      end;
     end;

     blob:= imagetoblob(imageinfo,image,@si,@exceptinf);
     if blob = nil then begin
      error();
     end;
     dest.writebuffer(blob^,si);
    finally
     if buf <> nil then begin
      freemem(buf);
     end;
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

function pinggmgraphic(const source: tstream; 
                      out ainfo: gminfoty): boolean;
var
 imageinfo: pointer;
 exceptinf: exceptioninfo;
 image: pointer;
 str1: string;
 datapo: pointer;
 datalen: card32;
begin
 result:= false;
 checkinit;
 datapo:= source.memory;
 datalen:= source.size;
 if datapo = nil then begin
  str1:= source.readdatastring;
  datapo:= pointer(str1);
  datalen:= length(str1);
 end;
 getexceptioninfo(@exceptinf);
 imageinfo:= cloneimageinfo(nil);
 image:= pingblob(imageinfo,datapo,datalen,@exceptinf);
 if image <> nil then begin
  with pimage8(image)^ do begin
   ainfo.size.cx:= a.columns;
   ainfo.size.cy:= a.rows;
   ainfo.depth:= a.depth;
  end;
  case qdepth of
   qd_8: begin
    with pimage8(image)^ do begin
     ainfo.formatlabel:= lowercase(c.magick);
    end;
   end;
   qd_16: begin
    with pimage16(image)^ do begin
     ainfo.formatlabel:= lowercase(c.magick);
    end;
   end;
   else begin
    with pimage32(image)^ do begin
     ainfo.formatlabel:= lowercase(c.magick);
    end;
   end;
  end;
  result:= true;
  destroyimage(image);
 end;
 destroyimageinfo(imageinfo);
 destroyexceptioninfo(@exceptinf);
end;

function readgmgraphic(const source: tstream; const dest: tbitmap;
       const aindex: integer = -1;
       const awidth: integer = 0; const aheight: integer = 0;
       const arotation: real = 0;
       const abackgroundcolor: colorty = cl_transparent;
       const apixelpermm: real = 0;
       const aoptions: readgmoptionsty = []): string;
              //returns label
var
 imageinfo: pointer;
 exceptinf: exceptioninfo;
 image,image2: pointer;
 imagebuffer: imagebufferinfoty;
 str1: string; //todo: use tstream -> c-stream adaptor
 hasmask,monomask,rotmask: boolean;
 bo2: boolean;
 si1,si2: sizety;
 datapo: pointer;
 datalen: card32;
 po1: pointer;
 int1: integer;
begin
 result:= '';
 monomask:= false;
 bo2:= dest is tmaskedbitmap;
 rotmask:= bo2 and (abackgroundcolor = cl_transparent) and 
                                (abs(frac(arotation / (pi/2.0))) > 0.0000001);
 imagebuffer.image.pixels:= nil;
 imagebuffer.mask.pixels:= nil;
 checkinit;
 datapo:= source.memory;
 datalen:= source.size;
 if datapo = nil then begin
  str1:= source.readdatastring;
  datapo:= pointer(str1);
  datalen:= length(str1);
 end;
 getexceptioninfo(@exceptinf);
 image:= nil;
 imageinfo:= cloneimageinfo(nil);
 try
  with pimageinfo8(imageinfo)^ do begin //a identical for all dephts
   if apixelpermm > 0 then begin
    a.units:= pixelsperinchresolution;
    a.density:= gmstring(formatfloatmse(apixelpermm*ppmmtoppi,'',true));
   end;
   if aindex >= 0 then begin
    a.subimage:= aindex;
   end;
   if (awidth <> 0) and (aheight <> 0) then begin
    a.size:= gmstring(inttostr(awidth)+'x'+inttostr(aheight));
   end;
  end;
  case qdepth of
   qd_8: begin
    with pimageinfo8(imageinfo)^ do begin
    end;
   end;
   qd_16: begin
    with pimageinfo16(imageinfo)^ do begin
    end;
   end;
   else begin
    with pimageinfo32(imageinfo)^ do begin
    end;
   end;
  end;
 
  image:= blobtoimage(imageinfo,datapo,datalen,@exceptinf);
  if image <> nil then begin
   with pimage8(image)^ do begin //a is identical for all depths
    hasmask:= a.matte = magicktrue;
    si1:= ms(a.columns,a.rows);
   end;
   if arotation <> 0 then begin
    setimagebackgroundcolor(image,abackgroundcolor);
    image2:= rotateimage(image,arotation*(-180/pi),@exceptinf);
    if image2 = nil then begin
     exit;
    end;
    destroyimage(image);
    image:= image2;
    if rotmask then begin
     pimage8(image)^.a.matte:= magicktrue;
     monomask:= not hasmask and (rgmo_rotmonomask in aoptions);
     hasmask:= true;
    end;
    si1:= ms(pimage8(image)^.a.columns,pimage8(image)^.a.rows);
   end;
   if fitscale(awidth,aheight,si1,si2) then begin
    image2:= scaleimage(image,si2.cx,si2.cy,@exceptinf);
    if image2 = nil then begin
     exit;
    end;
    destroyimage(image);
    image:= image2;
    si1:= ms(pimage8(image)^.a.columns,pimage8(image)^.a.rows);
   end;
   case qdepth of
    qd_8: begin
     with pimage8(image)^ do begin
      result:= lowercase(c.magick);
      if result = '' then begin
       result:= lowercase(c.magick_filename);
      end;
     end;
    end;
    qd_16: begin
     with pimage16(image)^ do begin
      result:= lowercase(c.magick);
      if result = '' then begin
       result:= lowercase(c.magick_filename);
      end;
     end;
    end;
    else begin
     with pimage32(image)^ do begin
      result:= lowercase(c.magick);
      if result = '' then begin
       result:= lowercase(c.magick_filename);
      end;
     end;
    end;
   end;
   allocimage(imagebuffer.image,si1,false);
   if dispatchimage(image,0,0,si1.cx,si1.cy,'BGRP',charpixel,
            imagebuffer.image.pixels,@exceptinf) = magickpass then begin
    if hasmask and bo2 then begin
     if monomask then begin
      allocimage(imagebuffer.mask,si1,true);
      po1:= imagebuffer.mask.pixels;
      for int1:= 0 to si1.cy-1 do begin
       if setimagepixels(image,0,int1,si1.cx,1) = nil then begin
        result:= '';
        break;
       end;
       if exportimagepixelarea(image,alphaquantum,1,po1,
                                            nil,nil) = magickfail then begin
        result:= '';
        break;
       end;
       if SyncImagePixels(image) = 0 then begin
        result:= '';
        break;
       end;
       inc(po1,imagebuffer.mask.linebytes);
      end;
      swapbits(imagebuffer.mask);
     end
     else begin
      allocimage(imagebuffer.mask,si1,false);
      if not dispatchimage(image,0,0,si1.cx,si1.cy,'AAAP',charpixel,
             imagebuffer.mask.pixels,@exceptinf) = magickpass then begin
       result:= '';
      end;
     end;
    end;
   end
   else begin
    result:= '';
   end;
  end;
  if result <> '' then begin
   if bo2 then begin
    tmaskedbitmap(dest).loadfromimagebuffer(imagebuffer);
   end
   else begin
    tbitmap(dest).loadfromimage(imagebuffer.image);
   end;
   tbitmap(dest).change;
  end;
 finally
  freeimage(imagebuffer.image);
  freeimage(imagebuffer.mask);
  destroyimageinfo(imageinfo);
  destroyexceptioninfo(@exceptinf);
  if image <> nil then begin
   destroyimage(image);
  end;
 end;
end;

function readgraphic(const source: tstream;
                const dest: tobject; var format: string;
                const params: array of const): boolean;
var
 index: integer = -1;
 width: integer = 0;
 height: integer = 0;
 rotation: extended = 0;
 backgroundcolor: colorty = cl_transparent;
 density: extended = 0;
 options: readgmoptionsty = [];
begin
 result:= false;
 if dest is tbitmap then begin
  matchparams(params,[index,width,height,rotation,backgroundcolor,density,
                      longword(options)],
                 [@index,@width,@height,@rotation,@backgroundcolor,@density,
                  @options]);
  format:= readgmgraphic(source,tbitmap(dest),index,width,height,rotation,
                                      backgroundcolor,density,options);
  result:= format <> '';
 end;
end;

procedure writegraphic(const dest: tstream; const source: tobject;
                 const format: string; const params: array of const);
var
 quality: integer = -1;
 width: integer = 0;
 height: integer = 0;
 rotation: extended = 0;
 backgroundcolor: colorty = cl_transparent;
 density: extended = 0;
begin
 if source is tbitmap then begin
  matchparams(params,[quality,width,height,rotation,backgroundcolor,density],
             [@quality,@width,@height,@rotation,@backgroundcolor,@density]);
  writegmgraphic(dest,tbitmap(source),format,quality,width,height,
                                            rotation,backgroundcolor,density);
 end;
end;

procedure registerformats(const labels: array of string;
                           const filternames: array of msestring;
                           const filemasks: array of msestringarty);
var
 int1: integer;
 fname: msestring;
 fmask: msestringarty;
begin
 checkinit();
 for int1:= 0 to high(labels) do begin
  fname:= '';
  fmask:= nil;
  if int1 <= high(filternames) then begin
   fname:= filternames[int1];
  end;
  if int1 <= high(filemasks) then begin
   fmask:= filemasks[int1];
  end;
  registergraphicformat(labels[int1],@readgraphic,@writegraphic,fname,fmask);
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
