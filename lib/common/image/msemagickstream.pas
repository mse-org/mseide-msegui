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
 msetypes{msestrings},msegraphicsmagick,sysutils,mclasses,msebitmap,msegraphutils;
const
 defaultblur = 1.0;
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
 gmoptionty = (
  rgmo_rotmonomask,
  rgmo_rotbeforescale, //rotate before scaling
  rgmo_rotafterscale, //rotate after scaling
  rgmo_sample, //use SampleImage() instead of ScaleImage()
  rgmo_resize  //use ResizeImage() with filtertype instead of ScaleImage()
 ); 
 gmoptionsty = set of gmoptionty;
 
procedure registerformats(const labels: array of string;
                           const filternames: array of msestring;
                           const filemasks: array of msestringarty);
//readgraphic parameters:
  //[index: integer, width: integer, height: integer, rotation: real,
     //sequence nr      0 = default     0 = default   0..2pi CCW
     // -1 = default
  // backgroundcolor: colorty, pixelpermm: real, options: gmoptionsty,
  //  default = cl_transparent  0 = default        default = []
  // filter: filtertypes,       blur: real]
  // default = UndefinedFilter  default = 1
           
//writegraphic parameters:
  //[compressionquality: integer, width: integer, height: integer,
      // 0..100, -1 = default        0 = default      0 = default
  //     rotation: real,        backgroundcolor: colorty, pixelpermm: real,
  //       0..2pi CCW default 0 default = cl_transparent     0 = default
  //  options: gmoptionsty filter: filtertypes,      blur: real]
  //    default = []      default = UndefinedFilter  default = 1

function readgmgraphic(const source: tstream; const dest: tbitmap;
             const aindex: integer = -1; const awidth: integer = 0;
             const aheight: integer = 0; const arotation: real = 0;
             const abackgroundcolor: colorty = cl_transparent;
             const apixelpermm: real = 0;
             const aoptions: gmoptionsty = [];
             const afilter: filtertypes = undefinedfilter;
             const ablur: real = defaultblur): string;
              //returns label
procedure writegmgraphic(const dest: tstream; const source: tbitmap;
             const format: string; const aquality: integer = -1;
             const awidth: integer = 0; const aheight: integer = 0;
             const arotation: real = 0;
             const abackgroundcolor: colorty = cl_transparent;
             const apixelpermm: real = 0;
             const aoptions: gmoptionsty = [];
             const afilter: filtertypes = undefinedfilter;
             const ablur: real = defaultblur);
function pinggmgraphic(const source: tstream; 
                      out ainfo: gminfoty): boolean;

implementation
uses
 msegraphics,msegraphicstream,msestream,msestockobjects,
 msectypes,msebits,mseclasses,mseformatstr,math;

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

function checksnap90(const arotation: double): boolean;
begin
 result:= (abs(frac(arotation / (pi/2.0))) < 0.0000001);
end;

function snap90(const arotation: double): double;
begin
 result:= arotation*(-180/pi);
 if checksnap90(arotation) then begin
  result:= round(result);
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

function rotrect(const avalue: sizety; const rotation: real): dpointty;
                     //calculate rotated dimensions
                     //todo: simplify
var
 si1,co1: double;
 minx: double = 0;
 maxx: double = 0;
 miny: double = 0;
 maxy: double = 0;

 procedure rot(var p: dpointty);
 var
  x,y: double;
 begin
  x:= p.x * co1 + p.y * si1;
  y:= -p.x * si1 + p.y * co1;
  p.x:= x;
  p.y:= y;
 end; //rot

 procedure checkmax(var p: dpointty);
 begin
  if p.x < minx then begin
   minx:= p.x;
  end;
  if p.y < miny then begin
   miny:= p.y;
  end;
  if p.x > maxx then begin
   maxx:= p.x;
  end;
  if p.y > maxy then begin
   maxy:= p.y;
  end;
 end; //checkmax

var
 points: array[0..2] of dpointty;
 int1: integer;

begin
 if rotation <> 0.0 then begin
  si1:= sin(rotation); //todo: simplify
  co1:= cos(rotation);
  fillchar(points,sizeof(points),0);
  points[0].x:= avalue.cx;
  points[1].y:= avalue.cy;
  points[2].x:= avalue.cx;
  points[2].y:= avalue.cy;
  for int1:= 0 to high(points) do begin
   rot(points[int1]);
  end;
  for int1:= 0 to high(points) do begin
   checkmax(points[int1]);
  end;
  result.x:= maxx-minx;
  result.y:= maxy-miny;
 end
 else begin
  result.x:= avalue.cx;
  result.y:= avalue.cy;
 end;
end;

function fitscale(const width: integer; const height: integer;
               const current: sizety; out dest: sizety;
               const rotation: real; const rotafter: boolean;
               const rotcurrent: dpointty): boolean;
                          //true if scaling necessary
var
 {rotcurrent,}rotdest: dpointty;
 sca1: double;
begin
 dest:= current;
 result:= (current.cx > 0) and (current.cy > 0);
 if result then begin
  if rotafter and (rotation <> 0) then begin
  {
   si1:= sin(rotation); //todo: simplify
   co1:= cos(rotation);
   fillchar(points,sizeof(points),0);
   points[0].x:= current.cx;
   points[1].y:= current.cy;
   points[2].x:= current.cx;
   points[2].y:= current.cy;
   for int1:= 0 to high(points) do begin
    rot(points[int1]);
   end;
   for int1:= 0 to high(points) do begin
    checkmax(points[int1]);
   end;
   rotcurrent.x:= maxx-minx;
   rotcurrent.y:= maxy-miny;
   }
   rotdest:= rotcurrent;
   if width <> 0 then begin
    rotdest.x:= width;
   end;
   if height <> 0 then begin
    rotdest.y:= height;
   end;
   if rotdest.x*rotcurrent.y > rotdest.y*rotcurrent.x then begin
    rotdest.x:= (rotcurrent.x*rotdest.y) / rotcurrent.y;
    sca1:= rotdest.x/rotcurrent.x;
   end
   else begin
    rotdest.y:= (rotcurrent.y*rotdest.x) / rotcurrent.x;
    sca1:= rotdest.y/rotcurrent.y;
   end;
   dest.cx:= round(current.cx*sca1);
   dest.cy:= round(current.cy*sca1);
  end
  else begin //scale to fit in destrect
   if width <> 0 then begin
    dest.cx:= width;
   end;
   if height <> 0 then begin
    dest.cy:= height;
   end;
   if dest.cx*current.cy > dest.cy*current.cx then begin
    dest.cx:= (current.cx*dest.cy) div current.cy;
   end
   else begin
    dest.cy:= (current.cy*dest.cx) div current.cx;
   end;
  end;
  result:= (current.cx <> dest.cx) or (current.cy <> dest.cy);
 end;
end;

function checkrotafter(const asize: sizety; const awidth: integer;
                const aheight: integer; const aoptions: gmoptionsty;
                const rotation: real; out rotcurrent: dpointty): boolean;
var
 si1: sizety;
begin
 rotcurrent:= rotrect(asize,rotation);
 if rgmo_rotbeforescale in aoptions then begin
  result:= false;
 end
 else begin
  if rgmo_rotafterscale in aoptions then begin
   result:= true;
  end
  else begin
   si1:= asize;
   if awidth <> 0 then begin
    si1.cx:= awidth;
   end;
   if aheight <> 0 then begin
    si1.cy:= aheight;
   end;
   result:= (si1.cx < rotcurrent.x) or (si1.cy < rotcurrent.y);
  end;
 end;
end;

procedure writegmgraphic(const dest: tstream; const source: tbitmap;
            const format: string; const aquality: integer = -1;
            const awidth: integer = 0; const aheight: integer = 0;
            const arotation: real = 0;
            const abackgroundcolor: colorty = cl_transparent;
            const apixelpermm: real = 0;
            const aoptions: gmoptionsty = [];
            const afilter: filtertypes = undefinedfilter;
            const ablur: real = defaultblur);
var
 exceptinf: exceptioninfo;
 image,image2: pointer;
 hasmask,monomask,rotmask: boolean;
 si1,si2: sizety;
 imagebuffer: maskedimagety;
 buf: pointer;
 maskscanstep: integer;
 maskscanpo: pointer;
 rotcurrent: dpointty;
 
 procedure error;
 begin
  raise tmagickexception.create(exceptinf);
 end;

 procedure dorotate();
 begin
  if arotation <> 0 then begin
   image2:= rotateimage(image,snap90(arotation),@exceptinf);
   if image2 = nil then begin
    exit;
   end;
   destroyimage(image);
   image:= image2;
   if rotmask then begin
    pimage8(image)^.a.matte:= magicktrue;
   end;
   si1:= ms(pimage8(image)^.a.columns,pimage8(image)^.a.rows);
  end;
 end; //dorotate
 
 procedure doscale(const rotafter: boolean);
 begin
  if fitscale(awidth,aheight,si1,si2,arotation,rotafter,rotcurrent) then begin
   if rgmo_sample in aoptions then begin
    image2:= sampleimage(image,si2.cx,si2.cy,@exceptinf);
   end
   else begin
    if rgmo_resize in aoptions then begin
     image2:= resizeimage(image,si2.cx,si2.cy,afilter,ablur,@exceptinf);
    end
    else begin
     image2:= scaleimage(image,si2.cx,si2.cy,@exceptinf);
    end;
   end;
   if image2 = nil then begin
    exit;
   end;
   destroyimage(image);
   image:= image2;
   si1:= ms(pimage8(image)^.a.columns,pimage8(image)^.a.rows);
  end;
 end; //doscale

 procedure checkcolormask();
 var
  d,e: pbyte;
  s: prgbtriplety;
 begin
  with imagebuffer.mask do begin
   if kind = bmk_rgb then begin
    getmem(buf,length);
    d:= buf;
    e:= buf + length;
    s:= pointer(imagebuffer.mask.pixels);
    maskscanpo:= buf;
    maskscanstep:= imagebuffer.mask.size.cx;
    repeat
     d^:= (word(s^.red) + word(s^.green) + word(s^.blue)) div 3;
     inc(s);
     inc(d);
    until d = e;
   end
   else begin
    maskscanpo:= imagebuffer.mask.pixels;
    maskscanstep:= imagebuffer.mask.linebytes;
   end;
  end;
  if monomask then begin
   swapbits(imagebuffer.mask);
  end;
 end;

var
 bo1,bo2: boolean;
 imageinfo: pointer;
 si: size_t;
 blob: pointer;
 int1: integer;
 po1,po2: pointer;
 s,d,e,e1: prgbtriplety;
 sw1,sw2: plongword;
 sb1: pbyte;
 lwo1: longword;

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
     rotmask:= (abackgroundcolor = cl_transparent) and 
                                       not checksnap90(arotation);                           
     monomask:= false;
     hasmask:= (source is tmaskedbitmap) and (tmaskedbitmap(source).masked);
     bo1:= getimageref(imagebuffer.image);
     bo2:= false;
     if hasmask then begin
      bo2:= tbitmap1(tmaskedbitmap(source).mask).getimageref(imagebuffer.mask);
      monomask:= imagebuffer.mask.kind = bmk_mono;
     end;
     case imagebuffer.image.kind of
      bmk_mono: begin                      //mono
       imageinfo:= cloneimageinfo(nil);
       image:= allocateimage(imageinfo);
       allocateimagecolormap(image,2);
       with pimage8(image)^ do begin
        a.storage_class:= pseudoclass;
        a.columns:= imagebuffer.image.size.cx;
        a.rows:= imagebuffer.image.size.cy;
        a.depth:= 1;
        if hasmask then begin
         a.matte:= magicktrue;
         checkcolormask();
        end;
       end;
       case qdepth of
        qd_8: begin
         with pimage8(image)^ do begin
          setcolor(colorbackground,b.colormap,0);
          setcolor(colorforeground,b.colormap,1);
         end;
        end;
        qd_16: begin
         with pimage16(image)^ do begin
          setcolor(colorbackground,b.colormap,0);
          setcolor(colorforeground,b.colormap,1);
         end;
        end;
        else begin
         with pimage32(image)^ do begin
          setcolor(colorbackground,b.colormap,0);
          setcolor(colorforeground,b.colormap,1);
         end;
        end;
       end;
       with imagebuffer.image do begin
        swapbits(imagebuffer.image);
        po1:= pixels;
        po2:= maskscanpo;
        for int1:= 0 to imagebuffer.image.size.cy-1 do begin
         if (setimagepixels(image,0,int1,
                              imagebuffer.image.size.cx,1) = nil) or
             (importimagepixelarea(image,indexquantum,1,po1,
                                              nil,nil) = magickfail) then begin
          error();
         end;
         if hasmask then begin
          if monomask then begin
           if importimagepixelarea(image,alphaquantum,1,po2,
                                               nil,nil) = magickfail then begin
            error();
           end;
          end
          else begin
           if importimagepixelarea(image,alphaquantum,8,po2,
                                               nil,nil) = magickfail then begin
            error();
           end;
          end;
          inc(po2,maskscanstep);
         end;
         if SyncImagePixels(image) = 0 then begin
          error();
         end;
         inc(po1,scanlinestep);
        end;
        if not bo1 then begin          //restore bit order
         swapbits(imagebuffer.image);
        end;
        if hasmask then begin 
         if monomask and not bo2 then begin
          swapbits(imagebuffer.mask);  //restore bit order
         end;
         with pimage8(image)^ do begin
          a.colors:= 0;
          a.storage_class:= directclass;
         end;
         case qdepth of                  //GraphicMagick removes 
          qd_8: begin                    //alpha channel for palette images
           with pimage8(image)^ do begin
            magickfree(b.colormap);
            b.colormap:= nil;
           end;
          end;
          qd_16: begin
           with pimage16(image)^ do begin
            magickfree(b.colormap);
            b.colormap:= nil;
           end;
          end;
          qd_32: begin
           with pimage32(image)^ do begin
            magickfree(b.colormap);
            b.colormap:= nil;
           end;
          end;
         end;
        end;
       end;
      end;
      bmk_gray: begin        //gray
       imageinfo:= cloneimageinfo(nil);
       image:= allocateimage(imageinfo);
       with pimage8(image)^ do begin
        a.storage_class:= directclass;
        a.columns:= imagebuffer.image.size.cx;
        a.rows:= imagebuffer.image.size.cy;
        a.depth:= 8;
        if hasmask then begin
         a.matte:= magicktrue;
         checkcolormask();
        end;
       end;
       with imagebuffer.image do begin
        po1:= pixels;
        po2:= maskscanpo;
        for int1:= 0 to imagebuffer.image.size.cy-1 do begin
         if (setimagepixels(image,0,int1,
                              imagebuffer.image.size.cx,1) = nil) or
            (importimagepixelarea(image,redquantum,8,po1,
                                              nil,nil) = magickfail) or
            (importimagepixelarea(image,greenquantum,8,po1,
                                              nil,nil) = magickfail) or
            (importimagepixelarea(image,bluequantum,8,po1,
                                              nil,nil) = magickfail)
                                              then begin
          error();
         end;
         if hasmask then begin
          if monomask then begin
           if importimagepixelarea(image,alphaquantum,1,po2,
                                               nil,nil) = magickfail then begin
            error();
           end;
          end
          else begin
           if importimagepixelarea(image,alphaquantum,8,po2,
                                               nil,nil) = magickfail then begin
            error();
           end;
          end;
          inc(po2,maskscanstep);
         end;
         if SyncImagePixels(image) = 0 then begin
          error();
         end;
         inc(po1,scanlinestep);
        end;
       end;
       if monomask and not bo2 then begin
        swapbits(imagebuffer.mask);  //restore bit order
       end;
      end;
      bmk_rgb: begin         //color
       if hasmask then begin
        d:= pointer(imagebuffer.image.pixels);
        e:= d + imagebuffer.image.length;
        case imagebuffer.mask.kind of
         bmk_mono: begin
          sw1:= pointer(imagebuffer.mask.pixels);
          repeat
           lwo1:= $00000001;
           sw2:= sw1;
           e1:= d + width;
           repeat
            if sw2^ and lwo1 <> 0 then begin
             d^.res:= $ff;
            end
            else begin
             d^.res:= 0;
            end;
            lwo1:= lwo1 shl 1;
            if lwo1 = 0 then begin
             inc(sw2);
             lwo1:= $00000001;
            end;
            inc(d);
           until d = e1;
           sw1:= pointer(sw1) + imagebuffer.mask.linebytes;
          until d = e;
         end;
         bmk_gray: begin
          sb1:= pointer(imagebuffer.mask.pixels);
          repeat
           d^.res:= sb1^;
           inc(sb1);
           inc(d);
          until d = e;
         end;
         else begin
          s:= pointer(imagebuffer.mask.pixels);
          repeat
           d^.res:= (word(s^.red) + word(s^.green) + word(s^.blue)) div 3;
           inc(s);
           inc(d);
          until d = e;
         end;
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
      end;
     end;
     if image = nil then begin
      raise tmagickexception.create(exceptinf);
     end;
     imageinfo:= cloneimageinfo(nil);
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
     setimagebackgroundcolor(image,abackgroundcolor);
     si1:= imagebuffer.image.size;
     if checkrotafter(si1,awidth,aheight,aoptions,arotation,rotcurrent) then begin
      doscale(true);
      dorotate();
     end
     else begin
      dorotate();
      doscale(false);
     end;
     if apixelpermm > 0 then begin
      with pimageinfo8(imageinfo)^ do begin
       a.units:= pixelsperinchresolution;
       a.density:= gmstring(ansistring(formatfloatmse(apixelpermm*ppmmtoppi,
                                                                     '',true)));
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
       const aoptions: gmoptionsty = [];
       const afilter: filtertypes = undefinedfilter;
       const ablur: real = defaultblur): string;
              //returns label
var
 exceptinf: exceptioninfo;
 image,image2: pointer;
 hasmask,monomask,rotmask: boolean;
 si1,si2: sizety;
 rotcurrent: dpointty;

 procedure dorotate();
 begin
  if arotation <> 0 then begin
   setimagebackgroundcolor(image,abackgroundcolor);
   image2:= rotateimage(image,snap90(arotation),@exceptinf);
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
 end; //dorotate

 procedure doscale(const rotafter: boolean);
 begin
  if fitscale(awidth,aheight,si1,si2,arotation,rotafter,rotcurrent) then begin
   if rgmo_sample in aoptions then begin
    image2:= sampleimage(image,si2.cx,si2.cy,@exceptinf);
   end
   else begin
    if rgmo_resize in aoptions then begin
     image2:= resizeimage(image,si2.cx,si2.cy,afilter,ablur,@exceptinf);
    end
    else begin
     image2:= scaleimage(image,si2.cx,si2.cy,@exceptinf);
    end;
   end;
//    image2:= scaleimage(image,si2.cx,si2.cy,@exceptinf);
   if image2 = nil then begin
    exit;
   end;
   destroyimage(image);
   image:= image2;
   si1:= ms(pimage8(image)^.a.columns,pimage8(image)^.a.rows);
  end;
 end; //doscale

var
 imageinfo: pointer;
 imagebuffer: maskedimagety;
 str1: string; //todo: use tstream -> c-stream adaptor
 bo2: boolean;
 datapo: pointer;
 datalen: card32;
 po1: pointer;
 int1: integer;
 cx1,cy1: integer;
 
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
    a.density:= gmstring(ansistring(formatfloatmse(apixelpermm*ppmmtoppi,
                                                                 '',true)));
   end;
   if aindex >= 0 then begin
    a.subimage:= aindex;
   end;
   image:= pingblob(imageinfo,datapo,datalen,@exceptinf);
   if image = nil then begin
    exit;
   end;
   if (pimage8(image)^.a.columns > 0) and (pimage8(image)^.a.rows > 0) then begin
               //limit to necessary size
    if (awidth <> 0) and (pimage8(image)^.a.columns > awidth) or 
               (aheight <> 0) and (pimage8(image)^.a.rows > aheight) then begin
     cx1:= awidth;
     if cx1 = 0 then begin
      cx1:= (pimage8(image)^.a.columns * aheight) div pimage8(image)^.a.rows;
     end;
     cy1:= aheight;
     if cy1 = 0 then begin
      cy1:= (pimage8(image)^.a.rows * awidth) div pimage8(image)^.a.columns;
     end;
     a.size:= gmstring(inttostr(cx1)+'x'+inttostr(cy1));
    end;
   end;
   destroyimage(image);
   image:= nil;
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
   if checkrotafter(si1,awidth,aheight,aoptions,arotation,rotcurrent) then begin
    doscale(true);
    dorotate();
   end
   else begin
    dorotate();
    doscale(false);
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
   allocimage(imagebuffer.image,si1,bmk_rgb);
   if dispatchimage(image,0,0,si1.cx,si1.cy,'BGRP',charpixel,
            imagebuffer.image.pixels,@exceptinf) = magickpass then begin
    if hasmask and bo2 then begin
     if monomask then begin
      allocimage(imagebuffer.mask,si1,bmk_mono);
      po1:= imagebuffer.mask.pixels;
      for int1:= 0 to si1.cy-1 do begin
       if getimagepixels(image,0,int1,si1.cx,1) = nil then begin
        result:= '';
        break;
       end;
       if exportimagepixelarea(image,alphaquantum,1,po1,
                                            nil,nil) = magickfail then begin
        result:= '';
        break;
       end;
       inc(po1,imagebuffer.mask.linebytes);
      end;
      swapbits(imagebuffer.mask);
     end
     else begin
      allocimage(imagebuffer.mask,si1,bmk_gray);
      po1:= imagebuffer.mask.pixels;
      for int1:= 0 to si1.cy-1 do begin
       if getimagepixels(image,0,int1,si1.cx,1) = nil then begin
        result:= '';
        break;
       end;
       if exportimagepixelarea(image,alphaquantum,8,po1,
                                            nil,nil) = magickfail then begin
        result:= '';
        break;
       end;
       inc(po1,imagebuffer.mask.linebytes);
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
    tmaskedbitmap(dest).loadfrommaskedimage(imagebuffer);
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
 options: gmoptionsty = [];
 filter: filtertypes = undefinedfilter;
 blur: extended = defaultblur;
begin
 result:= false;
 if dest is tbitmap then begin
  matchparams(params,
  [index,width,height,rotation,backgroundcolor,density,longword(options),
                                                                  filter,blur],
  [@index,@width,@height,@rotation,@backgroundcolor,@density,@options,
                                                                @filter,@blur]);
  format:= readgmgraphic(source,tbitmap(dest),index,width,height,rotation,
                                   backgroundcolor,density,options,filter,blur);
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
 options: gmoptionsty = [];
 filter: filtertypes = undefinedfilter;
 blur: extended = defaultblur;
begin
 if source is tbitmap then begin
  matchparams(params,
   [quality,width,height,rotation,backgroundcolor,density,
                                       longword(options),filter,blur],
   [@quality,@width,@height,@rotation,@backgroundcolor,@density,@filter,@blur]);
  writegmgraphic(dest,tbitmap(source),format,quality,width,height,
                          rotation,backgroundcolor,density,options,filter,blur);
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
