{ MSEgui Copyright (c) 1999-2011 by Martin Schreiber

    See the file COPYING.MSE, included in this Second, where the error is raised from. At the places in that code that call error(gde_invalidsaveindex,...), add this line just before each call, so the call chain is printed:distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}

unit msesdlgdi;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

//{$define sdl8x8font}

interface
uses
 msegraphics,msetypes,msestrings,mseguiglob,sdl4msegui,msebitmap,mseftfontcache,
 msefontcache, msesysutils,sdl2_gfxprimitives;

const
 radtodeg = 360/(2*pi);


procedure init;
procedure deinit;

function sdlgetgdifuncs: pgdifunctionaty;
//function sdlgetgdinum: integer;
procedure sdlinitdefaultfont;
function sdlgetdefaultfontnames: defaultfontnamesty;


implementation
uses
 mseguiintf,msegraphutils,msesysintf1,sysutils,msegenericgdi;

var
fgrgb,bgrgb: rgbtriplety;
 fgraw: longword;
  currentrop: rasteropty;

type
 shapety = (fs_copyarea,fs_rect,fs_ellipse,fs_arc,fs_polygon);

 gcflagty = (gcf_backgroundbrushvalid,
             gcf_colorbrushvalid,gcf_patternbrushvalid,gcf_rasterop,
             gcf_selectforegroundbrush,gcf_selectbackgroundbrush,
             gcf_foregroundpenvalid,
             gcf_selectforegroundpen,gcf_selectnullpen,gcf_selectnullbrush,
             gcf_ispatternpen,gcf_isopaquedashpen,
                          gcf_last = 31);
            //-> longword
 gcflagsty = set of gcflagty;

 tsimplebitmap1 = class(tsimplebitmap);
 tcanvas1 = class(tcanvas);
 tfont1 = class(tfont);

const
 defaultfontname = 'Tahoma';
// defaultfontname = 'MS Sans Serif';
 defaultfontnames: defaultfontnamesty =
  //stf_default           stf_empty stf_unicode stf_menu stf_message stf_hint stf_report
   (defaultfontname,          '',       '',         '',      '',     '', 'Arial',
  //stf_proportional stf_fixed,
   defaultfontname,         'Courier New',
  //stf_helvetica stf_roman          stf_courier
    'Arial',     'Times New Roman', 'Courier New');

type
 tsdlftfontcache = class(tftfontcache)
  protected
   procedure drawglyph(var drawinfo: drawinfoty; const pos: pointty;
                                      const bitmap: pbitmapdataty); override;
  public
   procedure drawstring16(var drawinfo: drawinfoty;
                                    const afont: fontty); override;
 end;

var
 ffontcache: tsdlftfontcache;
 currentfont: fontty;      // set in gdi_changegc

function fontcache: tsdlftfontcache;
begin
 if ffontcache = nil then begin
  tsdlftfontcache.create(tftfontcache(ffontcache));
 end;
 result:= ffontcache;
end;

procedure tsdlftfontcache.drawglyph(var drawinfo: drawinfoty;
                     const pos: pointty; const bitmap: pbitmapdataty);
var
 surf: PSDL_Surface;
 sp: CSDL_Surface;
 tex: SDL_Texture;
 rect1: SDL_Rect;
 x,y: integer;
 src: pbyte;
 dst: PLongword;
 fgpix: longword;
begin
 with bitmap^ do begin
  if (width <= 0) or (height <= 0) then begin
   exit;
  end;
  surf:= SDL_CreateRGBSurface(0,width,height,32,
                  $00FF0000,$0000FF00,$000000FF,$FF000000);
  if surf = 0 then begin
   exit;
  end;
  sp:= CSDL_Surface(ptruint(surf));
  fgpix:= (longword(fgrgb.red) shl 16) or (longword(fgrgb.green) shl 8) or
                                                          fgrgb.blue;
  src:= pbyte(@data);
  for y:= 0 to height-1 do begin
   // rows are stored bottom-up: write them from the last row up
   dst:= PLongword(ptruint(sp^.pixels) + ptruint((height-1-y)*sp^.pitch));
   for x:= 0 to width-1 do begin
    dst^:= (longword(src^) shl 24) or fgpix;
    inc(src);
    inc(dst);
   end;
  end;
  tex:= SDL_CreateTextureFromSurface(drawinfo.gc.handle,surf);
  if tex <> 0 then begin
   SDL_SetTextureBlendMode(tex,SDL_BLENDMODE_BLEND);
   rect1.x:= pos.x;               // already includes origin and left bearing
   rect1.y:= pos.y - height;      // pos.y is the bottom edge of the glyph
   rect1.w:= width;
   rect1.h:= height;

   SDL_RenderCopy(drawinfo.gc.handle,tex,nil,@rect1);
   SDL_DestroyTexture(tex);
  end;
  SDL_FreeSurface(surf);
 end;
end;

procedure tsdlftfontcache.drawstring16(var drawinfo: drawinfoty;
                                                  const afont: fontty);
var
 rect1: rectty;
 rect2: SDL_Rect;
begin
 if df_opaque in drawinfo.gc.drawingflags then begin
  if textbackgroundrect(drawinfo,afont,rect1) then begin
   rect2.x:= rect1.x + drawinfo.origin.x;   // check: see item 2 below
   rect2.y:= rect1.y + drawinfo.origin.y;
   rect2.w:= rect1.cx;
   rect2.h:= rect1.cy;
   SDL_SetRenderDrawBlendMode(drawinfo.gc.handle,SDL_BLENDMODE_NONE);
   SDL_SetRenderDrawColor(drawinfo.gc.handle,bgrgb.red,bgrgb.green,
                                      bgrgb.blue,255 - bgrgb.res);
   SDL_RenderFillRect(drawinfo.gc.handle,@rect2);
  end;
 end;
 inherited;
end;

function sdlgetdefaultfontnames: defaultfontnamesty;
begin
 result:= defaultfontnames;
end;

procedure gdi_setcliporigin(var drawinfo: drawinfoty);
begin
// debugwriteln('gde_notimplemented');
end;

procedure gdi_createpixmap(var drawinfo: drawinfoty); //gdifunc
begin
 with drawinfo.createpixmap do begin
  pixmap:= gui_createpixmap(size,0,false,copyfrom);
 end;
end;

procedure gdi_pixmaptoimage(var drawinfo: drawinfoty); //gdifunc
begin
 with drawinfo.pixmapimage do begin
  gui_pixmaptoimage(pixmap,image,drawinfo.gc.handle);
 end;
end;

procedure gdi_imagetopixmap(var drawinfo: drawinfoty); //gdifunc
begin
 with drawinfo.pixmapimage do begin
  error:= gui_imagetopixmap(image,pixmap,drawinfo.gc.handle);
 end;
end;

var
 dummysurface: PSDL_Surface;     // unit level, created on first use
var
 windowrenderer: ptruint;


procedure gdi_creategc(var drawinfo: drawinfoty);
var
 int3: integer;
 arenderer: ptruint;
begin
 with drawinfo.creategc do begin
//  writeln('CREATEGC kind=',ord(kind),
  //        ' paintdevice=',inttohex(ptruint(paintdevice),16));

  gcpo^.gdifuncs:= gui_getgdifuncs;
  error:= gde_creategc;
  case kind of
   gck_pixmap: begin
    gcpo^.handle:= SDL_CreateSoftwareRenderer(paintdevice);
    error:= SDL_CheckErrorGDI('creategc');
   end;
   gck_screen: begin
    if paintdevice = 0 then begin
     // no window: measuring canvas used by fonts, never draws
     if dummysurface = 0 then begin
      dummysurface:= SDL_CreateRGBSurface(0,1,1,32,
                       $00FF0000,$0000FF00,$000000FF,$FF000000);
     end;
     arenderer:= SDL_CreateSoftwareRenderer(dummysurface);
    end
    else begin

     int3:= -1;
     arenderer:= SDL_CreateRenderer(paintdevice,int3,SDL_RENDERER_SOFTWARE);

    end;
    gcpo^.handle:= arenderer;
    if arenderer <> 0 then begin
     windowrenderer:= arenderer;
     error:= gde_ok;
    end;
   end;
   else begin
    // printer/metafile: not supported, same dummy so nothing crashes
    if dummysurface = 0 then begin
     dummysurface:= SDL_CreateRGBSurface(0,1,1,32,
                      $00FF0000,$0000FF00,$000000FF,$FF000000);
    end;
    gcpo^.handle:= SDL_CreateSoftwareRenderer(dummysurface);
    if gcpo^.handle <> 0 then begin
     error:= gde_ok;
    end;
   end;
  end;
 end;
end;

procedure gdi_destroygc(var drawinfo: drawinfoty);
begin
 if drawinfo.gc.handle = windowrenderer then begin
  windowrenderer:= 0;
 end;
 if drawinfo.gc.handle <> 0 then begin
  SDL_DestroyRenderer(drawinfo.gc.handle);
  SDL_CheckError('destroygc');
 end;
end;

procedure gdi_changegc(var drawinfo: drawinfoty);
var
 ar1: rectarty;
 int1: integer;
 rect1: SDL_Rect;
 x1,y1,x2,y2: integer;
 rgbcolor: rgbtriplety;
begin
 with drawinfo.gcvalues^,drawinfo.gc do begin
  if gvm_colorforeground in mask then begin
   rgbcolor:= colortorgb(colorforeground);
   fgrgb.red:= rgbcolor.blue;
   fgrgb.green:= rgbcolor.green;
   fgrgb.blue:= rgbcolor.red;
   fgrgb.res:= rgbcolor.res;
   fgraw:= longword(colorforeground);

  end;
  if gvm_colorbackground in mask then begin
   rgbcolor:= colortorgb(colorbackground);
   bgrgb.red:= rgbcolor.blue;
   bgrgb.green:= rgbcolor.green;
   bgrgb.blue:= rgbcolor.red;
   bgrgb.res:= rgbcolor.res;
  end;
  if mask * [gvm_linewidth,gvm_dashes,gvm_capstyle,gvm_joinstyle] <> [] then begin
  end;
 if gvm_rasterop in mask then begin
   currentrop:= rasterop;
   if sdldebug then begin
    writeln('ROP ',ord(rasterop));
   end;
  end;
  if gvm_brush in mask then begin
  end;
  if gvm_brushorigin in mask then begin
  end;
  if gvm_clipregion in mask then begin
   if clipregion <> 0 then begin
    ar1:= gui_regiontorects(clipregion);
    if ar1 <> nil then begin
     // bounding box of all rects (SDL2 has only one clip rect)
     x1:= ar1[0].pos.x;
     y1:= ar1[0].pos.y;
     x2:= x1 + ar1[0].size.cx;
     y2:= y1 + ar1[0].size.cy;
     for int1:= 1 to high(ar1) do begin
      if ar1[int1].pos.x < x1 then x1:= ar1[int1].pos.x;
      if ar1[int1].pos.y < y1 then y1:= ar1[int1].pos.y;
      if ar1[int1].pos.x + ar1[int1].size.cx > x2 then
                                 x2:= ar1[int1].pos.x + ar1[int1].size.cx;
      if ar1[int1].pos.y + ar1[int1].size.cy > y2 then
                                 y2:= ar1[int1].pos.y + ar1[int1].size.cy;
     end;
     rect1.x:= x1 + cliporigin.x;
     rect1.y:= y1 + cliporigin.y;
     rect1.w:= x2 - x1;
     rect1.h:= y2 - y1;
     SDL_RenderSetClipRect(handle,@rect1);
    end
    else begin
     rect1.x:= 0; rect1.y:= 0; rect1.w:= 0; rect1.h:= 0;   // empty region
     SDL_RenderSetClipRect(handle,@rect1);
    end;
   end
   else begin
    SDL_RenderSetClipRect(handle,nil);                     // no clipping
     if rect1.w >= 200 then begin
       end;
   end;
   SDL_CheckError('SDL_RenderSetClipRect');
  end;
  if gvm_font in mask then begin
   currentfont:= font;
  end;
 end;
end;

procedure gdi_getcanvasclass(var drawinfo: drawinfoty); //gdifunc
begin
 //dummy
end;

function firstredrow(sp: CSDL_Surface): integer;
var
 y: integer;
 p: PLongword;
begin
 result:= -1;
 for y:= 0 to sp^.h-1 do begin
  p:= PLongword(ptruint(sp^.pixels) + ptruint(y*sp^.pitch) + 40); // x = 10
  if (p^ and $00FFFFFF) = $00FF0000 then begin
   result:= y;
   exit;
  end;
 end;
end;

procedure gdi_endpaint(var drawinfo: drawinfoty); //gdifunc
var
 rw,rh,ww,wh: integer;
begin
 rw:= 0;
 rh:= 0;
 ww:= 0;
 wh:= 0;
 SDL_GetRendererOutputSize(drawinfo.gc.handle,@rw,@rh);
 SDL_GetWindowSize(winidty(drawinfo.paintdevice),ww,wh);
 SDL_RenderPresent(drawinfo.gc.handle);
end;

procedure gdi_flush(var drawinfo: drawinfoty); //gdifunc
begin
 if windowrenderer <> 0 then begin
  SDL_RenderPresent(windowrenderer);
 end;
end;

procedure gdi_movewindowrect(var drawinfo: drawinfoty); //gdifunc
begin
 with drawinfo.moverect do begin
  gui_movewindowrect(drawinfo.paintdevice,dist^,rect^);
 end;
end;

procedure drawsingleline(renderer: SDL_Renderer; const origin: pointty;
                 x1,y1,x2,y2,awidth: integer; acolor: rgbtriplety);
var
 i,half,dx,dy: integer;
begin
 inc(x1,origin.x); inc(y1,origin.y);
 inc(x2,origin.x); inc(y2,origin.y);
 SDL_SetRenderDrawColor(renderer,acolor.red,acolor.green,acolor.blue,
                                                         255-acolor.res);
 if awidth <= 1 then begin
  SDL_RenderDrawLine(renderer,x1,y1,x2,y2);
 end
 else begin
  dx:= abs(x2-x1);
  dy:= abs(y2-y1);
  half:= awidth div 2;
  for i:= -half to awidth-1-half do begin
   if dx >= dy then begin
    SDL_RenderDrawLine(renderer,x1,y1+i,x2,y2+i);
   end
   else begin
    SDL_RenderDrawLine(renderer,x1+i,y1,x2+i,y2);
   end;
  end;
 end;
 SDL_CheckError('drawsingleline');
end;

procedure drawdottedline(renderer: SDL_Renderer; const origin: pointty;
                 x1,y1,x2,y2: integer; acolor: rgbtriplety);
var
 i,n,dx,dy: integer;
 xx,yy: real;
begin
 inc(x1,origin.x); inc(y1,origin.y);
 inc(x2,origin.x); inc(y2,origin.y);
 SDL_SetRenderDrawColor(renderer,acolor.red,acolor.green,acolor.blue,
                                                         255-acolor.res);
 dx:= x2-x1;
 dy:= y2-y1;
 if abs(dx) > abs(dy) then begin
  n:= abs(dx);
 end
 else begin
  n:= abs(dy);
 end;
 if n = 0 then begin
  SDL_RenderDrawPoint(renderer,x1,y1);
 end
 else begin
  for i:= 0 to n do begin
   if (i and 1) = 0 then begin
    xx:= x1 + dx*i/n;
    yy:= y1 + dy*i/n;
    SDL_RenderDrawPoint(renderer,round(xx),round(yy));
   end;
  end;
 end;
 SDL_CheckError('drawdottedline');
end;

procedure gdi_drawlines(var drawinfo: drawinfoty);
var
 int1,lwidth: integer;
 rgb: rgbtriplety;
 pp: ppointaty;
 org: pointty;
 dotted: boolean;
begin
 
  if sdldebug then begin
  writeln('DRAWLINES brush=',df_brush in drawinfo.gc.drawingflags,
          ' rop=',ord(currentrop));
 end;
 
 with drawinfo do begin
  if points.count < 2 then exit;
  pp:= ppointaty(points.points);
  org:= origin;
  rgb:= colortorgb(acolorforeground);
  dotted:= df_brush in gc.drawingflags;
  lwidth:= (gcvalues^.lineinfo.width + linewidthroundvalue) shr linewidthshift;
  for int1:= 1 to points.count-1 do begin
   if dotted then begin
    drawdottedline(gc.handle,org,pp^[int1-1].x,pp^[int1-1].y,
                                 pp^[int1].x,pp^[int1].y,rgb);
   end
   else begin
    drawsingleline(gc.handle,org,pp^[int1-1].x,pp^[int1-1].y,
                                 pp^[int1].x,pp^[int1].y,lwidth,rgb);
   end;
  end;
  if points.closed then begin
   if dotted then begin
    drawdottedline(gc.handle,org,pp^[points.count-1].x,pp^[points.count-1].y,
                                 pp^[0].x,pp^[0].y,rgb);
   end
   else begin
    drawsingleline(gc.handle,org,pp^[points.count-1].x,pp^[points.count-1].y,
                                 pp^[0].x,pp^[0].y,lwidth,rgb);
   end;
  end;
 end;
end;

procedure gdi_drawlinesegments(var drawinfo: drawinfoty);
var
 int1,lwidth: integer;
 rgb: rgbtriplety;
 pp: ppointaty;
 org: pointty;
 dotted: boolean;
begin
 
  if sdldebug then begin
  writeln('DRAWSEGMENTS brush=',df_brush in drawinfo.gc.drawingflags,
          ' rop=',ord(currentrop));
 end;
 with drawinfo do begin
  pp:= ppointaty(points.points);
  org:= origin;
  rgb:= colortorgb(acolorforeground);
  dotted:= df_brush in gc.drawingflags;
  lwidth:= (gcvalues^.lineinfo.width + linewidthroundvalue) shr linewidthshift;
  for int1:= 0 to points.count div 2 - 1 do begin
   if dotted then begin
    drawdottedline(gc.handle,org,pp^[2*int1].x,pp^[2*int1].y,
                                 pp^[2*int1+1].x,pp^[2*int1+1].y,rgb);
   end
   else begin
    drawsingleline(gc.handle,org,pp^[2*int1].x,pp^[2*int1].y,
                                 pp^[2*int1+1].x,pp^[2*int1+1].y,lwidth,rgb);
   end;
  end;
 end;
end;

procedure gdi_drawellipse(var drawinfo: drawinfoty);
var
 rgb: rgbtriplety;
begin
 with drawinfo, rect.rect^ do begin
  rgb:= colortorgb(acolorforeground);
  // MSEgui: x,y is the CENTER of the ellipse, cx,cy the full size
  aaellipseRGBA(gc.handle,
                origin.x + x,
                origin.y + y,
                cx div 2, cy div 2,
                rgb.red,rgb.green,rgb.blue,255-rgb.res);
 end;
end;

procedure gdi_fillelipse(var drawinfo: drawinfoty);
var
 yy,rx,ry,hw: integer;
 cx0,cy0: integer;
 d: real;
 rect1: SDL_Rect;
begin
 with drawinfo, rect.rect^ do begin
  // MSEgui: x,y is the CENTER of the ellipse, cx,cy the full size
  rx:= cx div 2;
  ry:= cy div 2;
  if (rx <= 0) or (ry <= 0) then begin
   exit;
  end;
  cx0:= origin.x + x;
  cy0:= origin.y + y;
  SDL_SetRenderDrawColor(gc.handle,fgrgb.red,fgrgb.green,fgrgb.blue,
                                                           255-fgrgb.res);
  for yy:= -ry to ry do begin
   d:= 1.0 - (yy*yy)/(ry*ry);
   if d < 0 then begin
    d:= 0;
   end;
   hw:= round(rx*sqrt(d));
   rect1.x:= cx0 - hw;
   rect1.y:= cy0 + yy;
   rect1.w:= 2*hw + 1;
   rect1.h:= 1;
   SDL_RenderFillRect(gc.handle,@rect1);
  end;
  SDL_CheckError('fillellipse');
 end;
end;

procedure getarcinfo(const info: drawinfoty;
                    out xstart,ystart,xend,yend: integer);
var
 stopang: real;
begin
 with info,arc,rect^ do begin
  stopang:= (startang+extentang);
  xstart:= (round(cos(startang)*cx) div 2) + x + origin.x;
  ystart:= (round(-sin(startang)*cy) div 2) + y + origin.y;
  xend:= (round(cos(stopang)*cx) div 2) + x + origin.x;
  yend:= (round(-sin(stopang)*cy) div 2) + y + origin.y;
 end;
end;



procedure gdi_fillrect(var drawinfo: drawinfoty);
var
 rect1: SDL_Rect;
 buf: array of longword;
 xx,yy,x0,y0,x1,y1,w,h,outw,outh: integer;
 p: longword;
begin
 with drawinfo do begin
  rect1.x:= rect.rect^.x + origin.x;
  rect1.y:= rect.rect^.y + origin.y;
  rect1.w:= rect.rect^.cx;
  rect1.h:= rect.rect^.cy;

  if (currentrop = rop_xor) and (df_brush in gc.drawingflags) then begin
   // dotted xor frame (focus rectangle): invert every second pixel
   outw:= 0;
   outh:= 0;
   SDL_GetRendererOutputSize(gc.handle,@outw,@outh);
   x0:= rect1.x;
   y0:= rect1.y;
   x1:= rect1.x + rect1.w;
   y1:= rect1.y + rect1.h;
   if x0 < 0 then begin
    x0:= 0;
   end;
   if y0 < 0 then begin
    y0:= 0;
   end;
   if x1 > outw then begin
    x1:= outw;
   end;
   if y1 > outh then begin
    y1:= outh;
   end;
   w:= x1 - x0;
   h:= y1 - y0;
   if (w > 0) and (h > 0) then begin
    rect1.x:= x0;
    rect1.y:= y0;
    rect1.w:= w;
    rect1.h:= h;
    setlength(buf,w*h);
    SDL_RenderReadPixels(gc.handle,@rect1,$16362004,@buf[0],w*4);
    for yy:= 0 to h-1 do begin
     for xx:= 0 to w-1 do begin
      if ((x0+xx+y0+yy) and 1) = 0 then begin
       p:= buf[yy*w+xx] xor $00FFFFFF;
       SDL_SetRenderDrawColor(gc.handle,(p shr 16) and $FF,(p shr 8) and $FF,
                                                           p and $FF,255);
       SDL_RenderDrawPoint(gc.handle,x0+xx,y0+yy);
      end;
     end;
    end;
   end;
   SDL_CheckError('fillrect xor');
   exit;
  end;

  SDL_SetRenderDrawColor(gc.handle,fgrgb.red,fgrgb.green,fgrgb.blue,255-fgrgb.res);
  SDL_RenderFillRect(gc.handle,@rect1);
  SDL_CheckError('SDL_RenderFillRect');
 end;
end;

procedure gdi_getfont(var drawinfo: drawinfoty);
begin
{$ifdef sdl8x8font}
 with drawinfo.getfont,fontdata^ do begin
  font:= 1;
  fonthighres:= 0;
  basefont:= 1;
  ascent:= 7;
  descent:= 1;
  linespacing:= 8;
  realheight:= 8;
  caretshift:= 0;
  linewidth:= 1;
 end;
 drawinfo.getfont.ok:= true;
{$else}
 fontcache.getfont(drawinfo);
{$endif}
end;

procedure gdi_freefontdata(var drawinfo: drawinfoty);
begin
{$ifndef sdl8x8font}
 // left empty on purpose (freeing here crashed at exit)
{$endif}
end;

procedure gdi_gettext16width(var drawinfo: drawinfoty);
begin
{$ifdef sdl8x8font}
 drawinfo.gettext16width.result:= drawinfo.gettext16width.count * 8;
{$else}
 fontcache.gettext16width(drawinfo);
{$endif}
end;

procedure gdi_getchar16widths(var drawinfo: drawinfoty);
{$ifdef sdl8x8font}
var
 int1: integer;
 po1: pinteger;
{$endif}
begin
{$ifdef sdl8x8font}
 with drawinfo.getchar16widths do begin
  po1:= resultpo;
  for int1:= 0 to count-1 do begin
   po1^:= 8;
   inc(po1);
  end;
 end;
{$else}
 fontcache.getchar16widths(drawinfo);
{$endif}
end;

procedure gdi_getfontmetrics(var drawinfo: drawinfoty);
begin
{$ifdef sdl8x8font}
 with drawinfo.getfontmetrics.resultpo^ do begin
  leftbearing:= 0;
  width:= 8;
  rightbearing:= 0;
  sum:= 8;
 end;
{$else}
 fontcache.getfontmetrics(drawinfo);
{$endif}
end;

procedure gdi_drawstring16(var drawinfo: drawinfoty);
{$ifdef sdl8x8font}
var
 s: ansistring;
 i,c: integer;
 ptext: pwidechar;
 rect1: SDL_Rect;
{$endif}
begin
{$ifdef sdl8x8font}
 with drawinfo, text16pos do begin
  if count > 0 then begin
   if df_opaque in gc.drawingflags then begin
    rect1.x:= pos^.x + origin.x;
    rect1.y:= pos^.y + origin.y - 7;
    rect1.w:= count * 8;
    rect1.h:= 8;
    SDL_SetRenderDrawBlendMode(gc.handle,SDL_BLENDMODE_NONE);
    SDL_SetRenderDrawColor(gc.handle,bgrgb.red,bgrgb.green,bgrgb.blue,
                                                           255 - bgrgb.res);
    SDL_RenderFillRect(gc.handle,@rect1);
   end;
   setlength(s,count);
   ptext:= pwidechar(text);
   for i:= 0 to count-1 do begin
    c:= ord(ptext[i]);
    if c > 127 then c:= ord('?');
    s[i+1]:= char(c);
   end;
   stringRGBA(gc.handle,pos^.x + origin.x,pos^.y + origin.y - 7,pchar(s),
              fgrgb.red,fgrgb.green,fgrgb.blue,255 - fgrgb.res);
  end;
 end;
{$else}
 if currentfont <> 0 then begin
  fontcache.drawstring16(drawinfo,currentfont);
 end;
{$endif}
 SDL_CheckError('drawstring16');
end;


procedure gdi_drawarc(var drawinfo: drawinfoty);
var
 i,n,rx,ry,rr,lwidth: integer;
 ang,step: real;
 rgb: rgbtriplety;
 xa,ya,xb,yb: integer;
begin
 with drawinfo,arc,rect^ do begin
  rx:= cx div 2;
  ry:= cy div 2;
  if (rx <= 0) or (ry <= 0) then begin
   exit;
  end;
  if rx > ry then begin
   rr:= rx;
  end
  else begin
   rr:= ry;
  end;
  rgb:= colortorgb(acolorforeground);
  lwidth:= (gcvalues^.lineinfo.width + linewidthroundvalue) shr linewidthshift;
  n:= round(abs(extentang)*rr/2) + 4;     // about 2 pixels per segment
  if n > 720 then begin
   n:= 720;
  end;
  step:= extentang/n;
  xa:= x + round(cos(startang)*rx);
  ya:= y - round(sin(startang)*ry);
  for i:= 1 to n do begin
   ang:= startang + i*step;
   xb:= x + round(cos(ang)*rx);
   yb:= y - round(sin(ang)*ry);
   drawsingleline(gc.handle,origin,xa,ya,xb,yb,lwidth,rgb);
   xa:= xb;
   ya:= yb;
  end;
  SDL_CheckError('drawarc');
 end;
end;

procedure fillpointsarray(renderer: SDL_Renderer; const origin: pointty;
                          const pts: array of pointty; n: integer);
var
 i,j,yy,miny,maxy,cnt,tmp,k: integer;
 y1,y2,x1,x2: integer;
 xs: array of integer;
 rect1: SDL_Rect;
begin
 if n < 3 then begin
  exit;
 end;
 miny:= pts[0].y;
 maxy:= miny;
 for i:= 1 to n-1 do begin
  if pts[i].y < miny then begin
   miny:= pts[i].y;
  end;
  if pts[i].y > maxy then begin
   maxy:= pts[i].y;
  end;
 end;
 SDL_SetRenderDrawColor(renderer,fgrgb.red,fgrgb.green,fgrgb.blue,255-fgrgb.res);
 setlength(xs,n);
 for yy:= miny to maxy do begin
  cnt:= 0;
  j:= n-1;
  for i:= 0 to n-1 do begin
   y1:= pts[j].y;
   y2:= pts[i].y;
   x1:= pts[j].x;
   x2:= pts[i].x;
   if ((y1 <= yy) and (y2 > yy)) or ((y2 <= yy) and (y1 > yy)) then begin
    xs[cnt]:= x1 + ((yy - y1) * (x2 - x1)) div (y2 - y1);
    inc(cnt);
   end;
   j:= i;
  end;
  for i:= 1 to cnt-1 do begin       // insertion sort of the crossings
   tmp:= xs[i];
   k:= i-1;
   while (k >= 0) and (xs[k] > tmp) do begin
    xs[k+1]:= xs[k];
    dec(k);
   end;
   xs[k+1]:= tmp;
  end;
  i:= 0;
  while i+1 < cnt do begin
   rect1.x:= xs[i] + origin.x;
   rect1.y:= yy + origin.y;
   rect1.w:= xs[i+1] - xs[i] + 1;
   rect1.h:= 1;
   SDL_RenderFillRect(renderer,@rect1);
   inc(i,2);
  end;
 end;
 SDL_CheckError('fillpoints');
end;



procedure gdi_fillarc(var drawinfo: drawinfoty);
var
 i,n,rx,ry,rr,first,total: integer;
 ang,step: real;
 pts: array of pointty;
begin
 with drawinfo,arc,rect^ do begin
  rx:= cx div 2;
  ry:= cy div 2;
  if (rx <= 0) or (ry <= 0) then begin
   exit;
  end;
  if rx > ry then begin
   rr:= rx;
  end
  else begin
   rr:= ry;
  end;
  n:= round(abs(extentang)*rr/2) + 4;     // about 2 pixels per segment
  if n > 720 then begin
   n:= 720;
  end;
  step:= extentang/n;
  if pieslice then begin
   first:= 1;                             // pts[0] is the center
   total:= n+2;
   setlength(pts,total);
   pts[0].x:= x;
   pts[0].y:= y;
  end
  else begin
   first:= 0;                             // chord: arc points only
   total:= n+1;
   setlength(pts,total);
  end;
  for i:= 0 to n do begin
   ang:= startang + i*step;
   pts[first+i].x:= x + round(cos(ang)*rx);
   pts[first+i].y:= y - round(sin(ang)*ry);
  end;
  fillpointsarray(gc.handle,origin,pts,total);
  SDL_CheckError('fillarc');
 end;
end;

procedure gdi_fillpolygon(var drawinfo: drawinfoty);
var
 pts: array of pointty;
 i: integer;
 pp: ppointaty;
begin
 with drawinfo do begin
  if points.count < 3 then begin
   exit;
  end;
  pp:= ppointaty(points.points);
  setlength(pts,points.count);
  for i:= 0 to points.count-1 do begin
   pts[i]:= pp^[i];
  end;
  fillpointsarray(gc.handle,origin,pts,points.count);
 end;
end;

var
 invertblend: cardinal;


procedure gdi_copyarea(var drawinfo: drawinfoty);
var
 rect1,rect2: SDL_rect;
 atexture: SDL_Texture;
 asurface,msurface,dsurface: PSDL_Surface;
 sp,mp,dp,dsp: CSDL_Surface;
 p,pm,pd: PLongword;
 x,y: integer;
 mono: boolean;
 fgpix,bgpix: longword;
 rgbcolor1,rgbcolor2: rgbtriplety;
begin
 with drawinfo,copyarea,gcvalues^ do begin
  rect1.x:= sourcerect^.x;
  rect1.y:= sourcerect^.y;
  rect1.w:= sourcerect^.cx;
  rect1.h:= sourcerect^.cy;
  rect2.x:= destrect^.x;
  rect2.y:= destrect^.y;
  rect2.w:= destrect^.cx;
  rect2.h:= destrect^.cy;

  if not (df_canvasispixmap in tcanvas1(source).fdrawinfo.gc.drawingflags) then begin
   if df_canvasispixmap in drawinfo.gc.drawingflags then begin
    dsp:= CSDL_Surface(ptruint(drawinfo.paintdevice));
    SDL_RenderReadPixels(tcanvas1(source).fdrawinfo.gc.handle,@rect1,$16362004,
         pointer(ptruint(dsp^.pixels) + ptruint(rect2.y*dsp^.pitch + rect2.x*4)),
         dsp^.pitch);
   end;
   exit;
  end;

  if (rect1.w <= 0) or (rect1.h <= 0) or (rect2.w <= 0) or (rect2.h <= 0) then begin
   exit;
  end;

  mono:= ismonopixmap(tcanvas1(source).fdrawinfo.paintdevice);

  // surface at the SOURCE size: SDL_RenderCopy scales it to rect2
  asurface:= SDL_CreateRGBSurface(0,rect1.w,rect1.h,32,
                       $00FF0000,$0000FF00,$000000FF,$FF000000);
  SDL_unlockSurface(tcanvas1(source).fdrawinfo.paintdevice);
  SDL_unlockSurface(asurface);
  SDL_SetSurfaceBlendMode(tcanvas1(source).fdrawinfo.paintdevice,
                                                    SDL_BLENDMODE_NONE);
  SDL_UpperBlit(tcanvas1(source).fdrawinfo.paintdevice,@rect1,asurface,nil);
  sp:= CSDL_Surface(ptruint(asurface));

  if mono then begin
   // colors requested by MSEgui for this copy (may be symbolic colors)
   rgbcolor1:= colortorgb(drawinfo.acolorforeground);
   rgbcolor2:= colortorgb(drawinfo.acolorbackground);
   fgpix:= $FF000000 or (longword(rgbcolor1.red) shl 16) or
                        (longword(rgbcolor1.green) shl 8) or rgbcolor1.blue;
   bgpix:= $FF000000 or (longword(rgbcolor2.red) shl 16) or
                        (longword(rgbcolor2.green) shl 8) or rgbcolor2.blue;
   if (rect2.w <= 24) and (rect2.h <= 24) then begin

   end;
   for y:= 0 to sp^.h-1 do begin
    p:= PLongword(ptruint(sp^.pixels) + ptruint(y*sp^.pitch));
    for x:= 0 to sp^.w-1 do begin
     if (p^ and $00FFFFFF) <> 0 then begin
      p^:= fgpix;
     end
     else if df_opaque in drawinfo.gc.drawingflags then begin
      p^:= bgpix;
     end
     else begin
      p^:= 0;
     end;
     inc(p);
    end;
   end;
  end
  else if drawinfo.copyarea.mask <> nil then begin
   msurface:= SDL_CreateRGBSurface(0,rect1.w,rect1.h,32,
                        $00FF0000,$0000FF00,$000000FF,$FF000000);
   SDL_unlockSurface(drawinfo.copyarea.mask.handle);
   SDL_unlockSurface(msurface);
   SDL_SetSurfaceBlendMode(drawinfo.copyarea.mask.handle,SDL_BLENDMODE_NONE);
   SDL_UpperBlit(drawinfo.copyarea.mask.handle,@rect1,msurface,nil);
   mp:= CSDL_Surface(ptruint(msurface));
   for y:= 0 to sp^.h-1 do begin
    p:= PLongword(ptruint(sp^.pixels) + ptruint(y*sp^.pitch));
    pm:= PLongword(ptruint(mp^.pixels) + ptruint(y*mp^.pitch));
    for x:= 0 to sp^.w-1 do begin
     if (pm^ and $00FFFFFF) <> 0 then begin
      p^:= p^ or $FF000000;
     end
     else begin
      p^:= p^ and $00FFFFFF;
     end;
     inc(p);
     inc(pm);
    end;
   end;
   SDL_FreeSurface(msurface);
  end
  else begin
   for y:= 0 to sp^.h-1 do begin
    p:= PLongword(ptruint(sp^.pixels) + ptruint(y*sp^.pitch));
    for x:= 0 to sp^.w-1 do begin
     p^:= p^ or $FF000000;
     inc(p);
    end;
   end;
  end;

  if (drawinfo.copyarea.copymode = rop_xor) and
              (rect1.w = rect2.w) and (rect1.h = rect2.h) then begin
   dsurface:= SDL_CreateRGBSurface(0,rect2.w,rect2.h,32,
                        $00FF0000,$0000FF00,$000000FF,$FF000000);
   dp:= CSDL_Surface(ptruint(dsurface));
   SDL_RenderReadPixels(drawinfo.gc.handle,@rect2,$16362004,dp^.pixels,dp^.pitch);
   for y:= 0 to sp^.h-1 do begin
    p:= PLongword(ptruint(sp^.pixels) + ptruint(y*sp^.pitch));
    pd:= PLongword(ptruint(dp^.pixels) + ptruint(y*dp^.pitch));
    for x:= 0 to sp^.w-1 do begin
     p^:= ((p^ xor pd^) and $00FFFFFF) or $FF000000;
     inc(p);
     inc(pd);
    end;
   end;
   SDL_FreeSurface(dsurface);
  end;

  atexture:= SDL_CreateTextureFromSurface(drawinfo.gc.handle,asurface);
  if atexture<>0 then begin
   SDL_SetTextureBlendMode(atexture,SDL_BLENDMODE_BLEND);
   SDL_RenderCopy(drawinfo.gc.handle, atexture, nil, @rect2);
   if (rect2.w <= 2) and
        not (df_canvasispixmap in drawinfo.gc.drawingflags) then begin
    SDL_RenderPresent(drawinfo.gc.handle);
   end;
  end;
  SDL_DestroyTexture(atexture);
  SDL_FreeSurface(asurface);
 end;
end;

procedure gdi_getimage(var drawinfo: drawinfoty); //gdifunc
begin
 //dummy
end;

procedure gdi_fonthasglyph(var drawinfo: drawinfoty);
begin
 with drawinfo,fonthasglyph do begin
  hasglyph:= true;
 end;
end;

{var
 defaultfontinfo: logfont;
type
 charsetinfoty = record
  name: string;
  code: integer;
 end;
 charsetinfoaty = array[0..18] of charsetinfoty;

const
 charsets: charsetinfoaty = (
  (name: 'ANSI'; code: 0),
  (name: 'DEFAULT'; code: 1),
  (name: 'SYMBOL'; code: 2),
  (name: 'SHIFTJIS'; code: $80),
  (name: 'HANGEUL'; code: 129),
  (name: 'GB2312'; code: 134),
  (name: 'CHINESEBIG5'; code: 136),
  (name: 'OEM'; code: 255),
  (name: 'JOHAB'; code: 130),
  (name: 'HEBREW'; code: 177),
  (name: 'ARABIC'; code: 178),
  (name: 'GREEK'; code: 161),
  (name: 'TURKISH'; code: 162),
  (name: 'VIETNAMESE'; code: 163),
  (name: 'THAI'; code: 222),
  (name: 'EASTEUROPE'; code: 238),
  (name: 'RUSSIAN'; code: 204),
  (name: 'MAC'; code: 77),
  (name: 'BALTIC'; code: 186));}

type
 pboolean = ^boolean;


procedure sdlinitdefaultfont;
begin
end;

procedure gdi_getfonthighres(var drawinfo: drawinfoty);
begin
end;

procedure init;
begin
end;

procedure deinit;
begin
end;

const
 gdifunctions: gdifunctionaty = (
   {$ifdef FPC}@{$endif}gdi_creategc,
   {$ifdef FPC}@{$endif}gdi_destroygc,
   {$ifdef FPC}@{$endif}gdi_changegc,
   {$ifdef FPC}@{$endif}gdi_createpixmap,
   {$ifdef FPC}@{$endif}gdi_pixmaptoimage,
   {$ifdef FPC}@{$endif}gdi_imagetopixmap,
   {$ifdef FPC}@{$endif}gdi_getcanvasclass,
   {$ifdef FPC}@{$endif}gdi_endpaint,
   {$ifdef FPC}@{$endif}gdi_flush,
   {$ifdef FPC}@{$endif}gdi_movewindowrect,
   {$ifdef FPC}@{$endif}gdi_drawlines,
   {$ifdef FPC}@{$endif}gdi_drawlinesegments,
   {$ifdef FPC}@{$endif}gdi_drawellipse,
   {$ifdef FPC}@{$endif}gdi_drawarc,
   {$ifdef FPC}@{$endif}gdi_fillrect,
   {$ifdef FPC}@{$endif}gdi_fillelipse,
   {$ifdef FPC}@{$endif}gdi_fillarc,
   {$ifdef FPC}@{$endif}gdi_fillpolygon,
//   {$ifdef FPC}@{$endif}gdi_drawstring,
   {$ifdef FPC}@{$endif}gdi_drawstring16,
   {$ifdef FPC}@{$endif}gdi_setcliporigin,
   {$ifdef FPC}@{$endif}msegenericgdi.gdi_createemptyregion,
   {$ifdef FPC}@{$endif}msegenericgdi.gdi_createrectregion,
   {$ifdef FPC}@{$endif}msegenericgdi.gdi_createrectsregion,
   {$ifdef FPC}@{$endif}msegenericgdi.gdi_destroyregion,
   {$ifdef FPC}@{$endif}msegenericgdi.gdi_copyregion,
   {$ifdef FPC}@{$endif}msegenericgdi.gdi_moveregion,
   {$ifdef FPC}@{$endif}msegenericgdi.gdi_regionisempty,
   {$ifdef FPC}@{$endif}msegenericgdi.gdi_regionclipbox,
   {$ifdef FPC}@{$endif}msegenericgdi.gdi_regsubrect,
   {$ifdef FPC}@{$endif}msegenericgdi.gdi_regsubregion,
   {$ifdef FPC}@{$endif}msegenericgdi.gdi_regaddrect,
   {$ifdef FPC}@{$endif}msegenericgdi.gdi_regaddregion,
   {$ifdef FPC}@{$endif}msegenericgdi.gdi_regintersectrect,
   {$ifdef FPC}@{$endif}msegenericgdi.gdi_regintersectregion,
   {$ifdef FPC}@{$endif}gdi_copyarea,
   {$ifdef FPC}@{$endif}gdi_getimage,
   {$ifdef FPC}@{$endif}gdi_fonthasglyph,
   {$ifdef FPC}@{$endif}gdi_getfont,
   {$ifdef FPC}@{$endif}gdi_getfonthighres,
   {$ifdef FPC}@{$endif}gdi_freefontdata,
   {$ifdef FPC}@{$endif}gdi_gettext16width,
   {$ifdef FPC}@{$endif}gdi_getchar16widths,
   {$ifdef FPC}@{$endif}gdi_getfontmetrics
);

//var
// gdinumber: integer;

function sdlgetgdifuncs: pgdifunctionaty;
begin
 result:= @gdifunctions;
end;
{
function sdlgetgdinum: integer;
begin
 result:= gdinumber;
end;

initialization
 gdinumber:= registergdi(sdlgetgdifuncs);
}

initialization
 fgrgb.red:= 0;   fgrgb.green:= 0;   fgrgb.blue:= 0;   fgrgb.res:= 0;
 bgrgb.red:= 255; bgrgb.green:= 255; bgrgb.blue:= 255; bgrgb.res:= 0;
end.
