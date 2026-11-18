{ MSEgui Copyright (c) 1999-2011 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msewaylandgdi;
{ gdi of the pure Wayland backend, drawing into software surfaces
  (msesoftsurface). Ported from msesdlgdi.pas.

  gcty.handle is a psoftsurfacety:
   window canvas:  the backing store of the window (kept by mseguiintf),
   pixmap canvas:  the pixmap itself (pixmapty = psoftsurfacety).
  A window is shown by gdi_endpaint -> waylandpresent(), which copies the
  backing store into a wl_shm buffer and commits. }
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 msegraphics,msetypes,msestrings,mseguiglob,msebitmap,mseftfontcache,
 msefontcache,msesysutils,msesoftsurface;

const
 radtodeg = 360/(2*pi);

procedure init;
procedure deinit;

function waylandgetgdifuncs: pgdifunctionaty;
procedure waylandpushgcstate;   //saves the global drawing state
procedure waylandpopgcstate;    //restores it (nested drawing)
procedure waylandinitdefaultfont;
function waylandgetdefaultfontnames: defaultfontnamesty;

implementation
uses
 mseguiintf,msegraphutils,msesysintf1,sysutils,msegenericgdi;

var
 fgrgb,bgrgb: rgbtriplety;
 currentrop: rasteropty;

type
 tsimplebitmap1 = class(tsimplebitmap);
 tcanvas1 = class(tcanvas);
 tfont1 = class(tfont);

const
 defaultfontname = 'Tahoma';
 defaultfontnames: defaultfontnamesty =
  //stf_default           stf_empty stf_unicode stf_menu stf_message stf_hint stf_report
   (defaultfontname,          '',       '',         '',      '',     '', 'Arial',
  //stf_proportional stf_fixed,
   defaultfontname,         'Courier New',
  //stf_helvetica stf_roman          stf_courier
    'Arial',     'Times New Roman', 'Courier New');

type
 twaylandftfontcache = class(tftfontcache)
  protected
   procedure drawglyph(var drawinfo: drawinfoty; const pos: pointty;
                                      const bitmap: pbitmapdataty); override;
  public
   procedure drawstring16(var drawinfo: drawinfoty;
                                    const afont: fontty); override;
 end;

var
 ffontcache: twaylandftfontcache;
 currentfont: fontty;      //set in gdi_changegc
 dummysurf: psoftsurfacety;

function fontcache: twaylandftfontcache;
begin
 if ffontcache = nil then begin
  twaylandftfontcache.create(tftfontcache(ffontcache));
 end;
 result:= ffontcache;
end;

function getdummysurface: psoftsurfacety;
begin
 if dummysurf = nil then begin
  dummysurf:= createsoftsurface(1,1);      //measuring canvas, never shown
 end;
 result:= dummysurf;
end;

function gcsurf(const drawinfo: drawinfoty): psoftsurfacety;
begin
 result:= psoftsurfacety(ptruint(drawinfo.gc.handle));
end;

function rgbvalue(const acolor: rgbtriplety): longword;
begin
 result:= (longword(acolor.red) shl 16) or (longword(acolor.green) shl 8) or
                                                          acolor.blue;
end;

function rgbalpha(const acolor: rgbtriplety): byte;
begin
 result:= 255 - acolor.res;
end;

//fonts

procedure twaylandftfontcache.drawglyph(var drawinfo: drawinfoty;
                     const pos: pointty; const bitmap: pbitmapdataty);
begin
 with bitmap^ do begin
  if (width <= 0) or (height <= 0) then begin
   exit;
  end;
  //rows are stored bottom up, pos.x already includes origin and left bearing,
  //pos.y is the bottom edge of the glyph
  softblendmask(gcsurf(drawinfo),pos.x,pos.y - height,pbyte(@data),
                                       width,height,true,rgbvalue(fgrgb));
 end;
end;

procedure twaylandftfontcache.drawstring16(var drawinfo: drawinfoty;
                                                  const afont: fontty);
var
 rect1: rectty;
begin
 if df_opaque in drawinfo.gc.drawingflags then begin
  if textbackgroundrect(drawinfo,afont,rect1) then begin
   softfillrect(gcsurf(drawinfo),
        softrect(rect1.x + drawinfo.origin.x,rect1.y + drawinfo.origin.y,
                                                      rect1.cx,rect1.cy),
        rgbvalue(bgrgb),rgbalpha(bgrgb));
  end;
 end;
 inherited;
end;

function waylandgetdefaultfontnames: defaultfontnamesty;
begin
 result:= defaultfontnames;
end;

//gc

procedure gdi_setcliporigin(var drawinfo: drawinfoty);
begin
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

procedure gdi_creategc(var drawinfo: drawinfoty);
var
 surf: psoftsurfacety;
begin
 with drawinfo.creategc do begin
  gcpo^.gdifuncs:= gui_getgdifuncs;
  error:= gde_creategc;
  case kind of
   gck_pixmap: begin
    surf:= psoftsurfacety(ptruint(paintdevice));
    if surf <> nil then begin
     gcpo^.handle:= ptruint(surf);
     error:= gde_ok;
    end;
   end;
   gck_screen: begin
    surf:= nil;
    if paintdevice <> 0 then begin
     surf:= waylandbacksurface(winidty(paintdevice));
    end;
    if surf = nil then begin
     surf:= getdummysurface;     //no window: measuring canvas used by fonts
    end;
    gcpo^.handle:= ptruint(surf);
    error:= gde_ok;
   end;
   else begin                    //printer, metafile: not supported
    gcpo^.handle:= ptruint(getdummysurface);
    error:= gde_ok;
   end;
  end;
 end;
end;

procedure gdi_destroygc(var drawinfo: drawinfoty);
begin
 //the surfaces belong to the windows and pixmaps, nothing to free
 drawinfo.gc.handle:= 0;
end;

procedure gdi_changegc(var drawinfo: drawinfoty);
var
 ar1: rectarty;
 int1: integer;
 x1,y1,x2,y2: integer;
 rgbcolor: rgbtriplety;
 surf: psoftsurfacety;
begin
 with drawinfo.gcvalues^,drawinfo.gc do begin
  surf:= psoftsurfacety(ptruint(handle));
  if gvm_colorforeground in mask then begin
   rgbcolor:= colortorgb(colorforeground);
   fgrgb.red:= rgbcolor.blue;       //same swap as in the SDL gdi
   fgrgb.green:= rgbcolor.green;
   fgrgb.blue:= rgbcolor.red;
   fgrgb.res:= rgbcolor.res;
  end;
  if gvm_colorbackground in mask then begin
   rgbcolor:= colortorgb(colorbackground);
   bgrgb.red:= rgbcolor.blue;
   bgrgb.green:= rgbcolor.green;
   bgrgb.blue:= rgbcolor.red;
   bgrgb.res:= rgbcolor.res;
  end;
  if gvm_rasterop in mask then begin
   currentrop:= rasterop;
  end;
  if (gvm_clipregion in mask) and (surf <> nil) then begin
   if clipregion <> 0 then begin
    ar1:= gui_regiontorects(clipregion);
    if ar1 <> nil then begin
     //bounding box of all rects, like the SDL gdi (one clip rectangle)
     x1:= ar1[0].pos.x;
     y1:= ar1[0].pos.y;
     x2:= x1 + ar1[0].size.cx;
     y2:= y1 + ar1[0].size.cy;
     for int1:= 1 to high(ar1) do begin
      if ar1[int1].pos.x < x1 then begin
       x1:= ar1[int1].pos.x;
      end;
      if ar1[int1].pos.y < y1 then begin
       y1:= ar1[int1].pos.y;
      end;
      if ar1[int1].pos.x + ar1[int1].size.cx > x2 then begin
       x2:= ar1[int1].pos.x + ar1[int1].size.cx;
      end;
      if ar1[int1].pos.y + ar1[int1].size.cy > y2 then begin
       y2:= ar1[int1].pos.y + ar1[int1].size.cy;
      end;
     end;
     softsetclip(surf,softrect(x1 + cliporigin.x,y1 + cliporigin.y,
                                                         x2 - x1,y2 - y1));
    end
    else begin
     softsetclip(surf,softrect(0,0,0,0));     //empty region
    end;
   end
   else begin
    softresetclip(surf);                      //no clipping
   end;
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

procedure gdi_endpaint(var drawinfo: drawinfoty); //gdifunc
begin
 waylandpresent(gcsurf(drawinfo));  //does nothing if it is not a window
end;

procedure gdi_movewindowrect(var drawinfo: drawinfoty); //gdifunc
begin
 with drawinfo.moverect do begin
  gui_movewindowrect(drawinfo.paintdevice,dist^,rect^);
 end;
end;

procedure gdi_flush(var drawinfo: drawinfoty); //gdifunc
begin
 //nothing to do, the window is presented in gdi_endpaint
end;

//lines

procedure drawsingleline(const surf: psoftsurfacety; const origin: pointty;
                 x1,y1,x2,y2,awidth: integer; const acolor: rgbtriplety);
var
 i,half,dx,dy: integer;
 col: longword;
 alpha: byte;
begin
 inc(x1,origin.x);
 inc(y1,origin.y);
 inc(x2,origin.x);
 inc(y2,origin.y);
 col:= rgbvalue(acolor);
 alpha:= rgbalpha(acolor);
 if awidth <= 1 then begin
  softdrawline(surf,x1,y1,x2,y2,col,alpha);
 end
 else begin
  dx:= abs(x2-x1);
  dy:= abs(y2-y1);
  half:= awidth div 2;
  for i:= -half to awidth-1-half do begin
   if dx >= dy then begin
    softdrawline(surf,x1,y1+i,x2,y2+i,col,alpha);
   end
   else begin
    softdrawline(surf,x1+i,y1,x2+i,y2,col,alpha);
   end;
  end;
 end;
end;

procedure drawdottedline(const surf: psoftsurfacety; const origin: pointty;
                 x1,y1,x2,y2: integer; const acolor: rgbtriplety);
var
 i,n,dx,dy: integer;
 col: longword;
 alpha: byte;
begin
 inc(x1,origin.x);
 inc(y1,origin.y);
 inc(x2,origin.x);
 inc(y2,origin.y);
 col:= rgbvalue(acolor);
 alpha:= rgbalpha(acolor);
 dx:= x2-x1;
 dy:= y2-y1;
 if abs(dx) > abs(dy) then begin
  n:= abs(dx);
 end
 else begin
  n:= abs(dy);
 end;
 if n = 0 then begin
  softdrawpoint(surf,x1,y1,col,alpha);
 end
 else begin
  for i:= 0 to n do begin
   if (i and 1) = 0 then begin
    softdrawpoint(surf,round(x1 + dx*i/n),round(y1 + dy*i/n),col,alpha);
   end;
  end;
 end;
end;

procedure gdi_drawlines(var drawinfo: drawinfoty);
var
 int1,lwidth: integer;
 rgb: rgbtriplety;
 pp: ppointaty;
 org: pointty;
 dotted: boolean;
 surf: psoftsurfacety;
begin
 with drawinfo do begin
  if points.count < 2 then begin
   exit;
  end;
  surf:= gcsurf(drawinfo);
  pp:= ppointaty(points.points);
  org:= origin;
  rgb:= colortorgb(acolorforeground);
  dotted:= df_brush in gc.drawingflags;
  lwidth:= (gcvalues^.lineinfo.width + linewidthroundvalue) shr linewidthshift;
  for int1:= 1 to points.count-1 do begin
   if dotted then begin
    drawdottedline(surf,org,pp^[int1-1].x,pp^[int1-1].y,
                                 pp^[int1].x,pp^[int1].y,rgb);
   end
   else begin
    drawsingleline(surf,org,pp^[int1-1].x,pp^[int1-1].y,
                                 pp^[int1].x,pp^[int1].y,lwidth,rgb);
   end;
  end;
  if points.closed then begin
   if dotted then begin
    drawdottedline(surf,org,pp^[points.count-1].x,pp^[points.count-1].y,
                                 pp^[0].x,pp^[0].y,rgb);
   end
   else begin
    drawsingleline(surf,org,pp^[points.count-1].x,pp^[points.count-1].y,
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
 surf: psoftsurfacety;
begin
 with drawinfo do begin
  surf:= gcsurf(drawinfo);
  pp:= ppointaty(points.points);
  org:= origin;
  rgb:= colortorgb(acolorforeground);
  dotted:= df_brush in gc.drawingflags;
  lwidth:= (gcvalues^.lineinfo.width + linewidthroundvalue) shr linewidthshift;
  for int1:= 0 to points.count div 2 - 1 do begin
   if dotted then begin
    drawdottedline(surf,org,pp^[2*int1].x,pp^[2*int1].y,
                                 pp^[2*int1+1].x,pp^[2*int1+1].y,rgb);
   end
   else begin
    drawsingleline(surf,org,pp^[2*int1].x,pp^[2*int1].y,
                                 pp^[2*int1+1].x,pp^[2*int1+1].y,lwidth,rgb);
   end;
  end;
 end;
end;

//ellipses, arcs, polygons

procedure gdi_drawellipse(var drawinfo: drawinfoty);
var
 i,n,rx,ry,rr,lwidth: integer;
 ang,step: real;
 rgb: rgbtriplety;
 xa,ya,xb,yb: integer;
 surf: psoftsurfacety;
begin
 with drawinfo,rect.rect^ do begin
  //MSEgui: x,y is the CENTER of the ellipse, cx,cy the full size
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
  surf:= gcsurf(drawinfo);
  rgb:= colortorgb(acolorforeground);
  lwidth:= (gcvalues^.lineinfo.width + linewidthroundvalue) shr linewidthshift;
  n:= round(pi*rr) + 8;
  if n > 720 then begin
   n:= 720;
  end;
  step:= 2*pi/n;
  xa:= x + rx;
  ya:= y;
  for i:= 1 to n do begin
   ang:= i*step;
   xb:= x + round(cos(ang)*rx);
   yb:= y - round(sin(ang)*ry);
   drawsingleline(surf,origin,xa,ya,xb,yb,lwidth,rgb);
   xa:= xb;
   ya:= yb;
  end;
 end;
end;

procedure gdi_fillelipse(var drawinfo: drawinfoty);
var
 yy,rx,ry,hw: integer;
 cx0,cy0: integer;
 d: real;
 surf: psoftsurfacety;
begin
 with drawinfo, rect.rect^ do begin
  //MSEgui: x,y is the CENTER of the ellipse, cx,cy the full size
  rx:= cx div 2;
  ry:= cy div 2;
  if (rx <= 0) or (ry <= 0) then begin
   exit;
  end;
  surf:= gcsurf(drawinfo);
  cx0:= origin.x + x;
  cy0:= origin.y + y;
  for yy:= -ry to ry do begin
   d:= 1.0 - (yy*yy)/(ry*ry);
   if d < 0 then begin
    d:= 0;
   end;
   hw:= round(rx*sqrt(d));
   softfillrect(surf,softrect(cx0 - hw,cy0 + yy,2*hw + 1,1),
                                          rgbvalue(fgrgb),rgbalpha(fgrgb));
  end;
 end;
end;

procedure gdi_drawarc(var drawinfo: drawinfoty);
var
 i,n,rx,ry,rr,lwidth: integer;
 ang,step: real;
 rgb: rgbtriplety;
 xa,ya,xb,yb: integer;
 surf: psoftsurfacety;
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
  surf:= gcsurf(drawinfo);
  rgb:= colortorgb(acolorforeground);
  lwidth:= (gcvalues^.lineinfo.width + linewidthroundvalue) shr linewidthshift;
  n:= round(abs(extentang)*rr/2) + 4;     //about 2 pixels per segment
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
   drawsingleline(surf,origin,xa,ya,xb,yb,lwidth,rgb);
   xa:= xb;
   ya:= yb;
  end;
 end;
end;

procedure fillpointsarray(const surf: psoftsurfacety; const origin: pointty;
                          const pts: array of pointty; n: integer);
var
 i,j,yy,miny,maxy,cnt,tmp,k: integer;
 y1,y2,x1,x2: integer;
 xs: array of integer;
 col: longword;
 alpha: byte;
begin
 if n < 3 then begin
  exit;
 end;
 col:= rgbvalue(fgrgb);
 alpha:= rgbalpha(fgrgb);
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
  for i:= 1 to cnt-1 do begin       //insertion sort of the crossings
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
   softfillrect(surf,softrect(xs[i] + origin.x,yy + origin.y,
                                    xs[i+1] - xs[i] + 1,1),col,alpha);
   inc(i,2);
  end;
 end;
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
  n:= round(abs(extentang)*rr/2) + 4;     //about 2 pixels per segment
  if n > 720 then begin
   n:= 720;
  end;
  step:= extentang/n;
  if pieslice then begin
   first:= 1;                             //pts[0] is the center
   total:= n+2;
   setlength(pts,total);
   pts[0].x:= x;
   pts[0].y:= y;
  end
  else begin
   first:= 0;                             //chord: arc points only
   total:= n+1;
   setlength(pts,total);
  end;
  for i:= 0 to n do begin
   ang:= startang + i*step;
   pts[first+i].x:= x + round(cos(ang)*rx);
   pts[first+i].y:= y - round(sin(ang)*ry);
  end;
  fillpointsarray(gcsurf(drawinfo),origin,pts,total);
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
  fillpointsarray(gcsurf(drawinfo),origin,pts,points.count);
 end;
end;

//rectangles

procedure gdi_fillrect(var drawinfo: drawinfoty);
var
 surf: psoftsurfacety;
 r: softrectty;
 xx,yy,x0,y0,x1,y1: integer;
 p: longword;
begin
 with drawinfo do begin
  surf:= gcsurf(drawinfo);
  r:= softrect(rect.rect^.x + origin.x,rect.rect^.y + origin.y,
                                         rect.rect^.cx,rect.rect^.cy);
  if (currentrop = rop_xor) and (df_brush in gc.drawingflags) then begin
   //dotted xor frame (focus rectangle): invert every second pixel
   x0:= r.x;
   y0:= r.y;
   x1:= r.x + r.cx;
   y1:= r.y + r.cy;
   if x0 < 0 then begin
    x0:= 0;
   end;
   if y0 < 0 then begin
    y0:= 0;
   end;
   if x1 > surf^.width then begin
    x1:= surf^.width;
   end;
   if y1 > surf^.height then begin
    y1:= surf^.height;
   end;
   for yy:= y0 to y1-1 do begin
    for xx:= x0 to x1-1 do begin
     if ((xx + yy) and 1) = 0 then begin
      p:= softgetpixel(surf,xx,yy) xor $00FFFFFF;
      softdrawpoint(surf,xx,yy,p and $00FFFFFF,255);
     end;
    end;
   end;
   exit;
  end;
  softfillrect(surf,r,rgbvalue(fgrgb),rgbalpha(fgrgb));
 end;
end;

//copyarea

procedure gdi_copyarea(var drawinfo: drawinfoty);
var
 r1,r2: softrectty;
 dst,srcsurf,tmp,msurface: psoftsurfacety;
 sp,mp,dp: plongword;
 x,y: integer;
 mono: boolean;
 fgpix,bgpix,p,alpha: longword;
 rgbcolor1,rgbcolor2: rgbtriplety;
begin
 with drawinfo,copyarea do begin
  r1:= softrect(sourcerect^.x,sourcerect^.y,sourcerect^.cx,sourcerect^.cy);
  r2:= softrect(destrect^.x,destrect^.y,destrect^.cx,destrect^.cy);
  dst:= gcsurf(drawinfo);

  if not (df_canvasispixmap in tcanvas1(source).fdrawinfo.gc.drawingflags) then
  begin
   //source is a window: only copying into pixmaps is supported
   if df_canvasispixmap in drawinfo.gc.drawingflags then begin
    srcsurf:= psoftsurfacety(ptruint(tcanvas1(source).fdrawinfo.gc.handle));
    softcopy(dst,r2.x,r2.y,srcsurf,r1,false);
   end;
   exit;
  end;

  if (r1.cx <= 0) or (r1.cy <= 0) or (r2.cx <= 0) or (r2.cy <= 0) then begin
   exit;
  end;
  srcsurf:= psoftsurfacety(ptruint(tcanvas1(source).fdrawinfo.paintdevice));
  if srcsurf = nil then begin
   exit;
  end;
  mono:= ismonopixmap(tcanvas1(source).fdrawinfo.paintdevice);

  //temporary copy at the SOURCE size, scaled to r2 when drawn
  tmp:= createsoftsurface(r1.cx,r1.cy);
  softcopy(tmp,0,0,srcsurf,r1,false);

  if mono then begin
   //colors requested by MSEgui for this copy (may be symbolic colors)
   rgbcolor1:= colortorgb(drawinfo.acolorforeground);
   rgbcolor2:= colortorgb(drawinfo.acolorbackground);
   fgpix:= $FF000000 or rgbvalue(rgbcolor1);
   bgpix:= $FF000000 or rgbvalue(rgbcolor2);
   for y:= 0 to tmp^.height-1 do begin
    sp:= plongword(pbyte(tmp^.pixels) + y*tmp^.pitch);
    for x:= 0 to tmp^.width-1 do begin
     if (sp^ and $00FFFFFF) <> 0 then begin
      sp^:= fgpix;
     end
     else begin
      if df_opaque in drawinfo.gc.drawingflags then begin
       sp^:= bgpix;
      end
      else begin
       sp^:= 0;
      end;
     end;
     inc(sp);
    end;
   end;
  end
  else begin
   if drawinfo.copyarea.mask <> nil then begin
    msurface:= createsoftsurface(r1.cx,r1.cy);
    softcopy(msurface,0,0,
       psoftsurfacety(ptruint(drawinfo.copyarea.mask.handle)),r1,false);
    for y:= 0 to tmp^.height-1 do begin
     sp:= plongword(pbyte(tmp^.pixels) + y*tmp^.pitch);
     mp:= plongword(pbyte(msurface^.pixels) + y*msurface^.pitch);
     for x:= 0 to tmp^.width-1 do begin
      alpha:= mp^ and $FF;               //gray mask = alpha, mono mask = 0/255
      if alpha = 255 then begin
       sp^:= sp^ or $FF000000;
      end
      else begin
       sp^:= (sp^ and $00FFFFFF) or (alpha shl 24);
      end;
      inc(sp);
      inc(mp);
     end;
    end;
    freesoftsurface(msurface);
   end
   else begin
    for y:= 0 to tmp^.height-1 do begin
     sp:= plongword(pbyte(tmp^.pixels) + y*tmp^.pitch);
     for x:= 0 to tmp^.width-1 do begin
      sp^:= sp^ or $FF000000;
      inc(sp);
     end;
    end;
   end;
  end;

  if (drawinfo.copyarea.copymode = rop_xor) and
              (r1.cx = r2.cx) and (r1.cy = r2.cy) then begin
   for y:= 0 to tmp^.height-1 do begin
    sp:= plongword(pbyte(tmp^.pixels) + y*tmp^.pitch);
    for x:= 0 to tmp^.width-1 do begin
     p:= softgetpixel(dst,r2.x + x,r2.y + y);
     sp^:= ((sp^ xor p) and $00FFFFFF) or $FF000000;
     inc(sp);
    end;
   end;
  end;

  if (r1.cx = r2.cx) and (r1.cy = r2.cy) then begin
   softcopy(dst,r2.x,r2.y,tmp,softrect(0,0,r1.cx,r1.cy),true);
  end
  else begin
   softcopyscaled(dst,r2,tmp,softrect(0,0,r1.cx,r1.cy),true);
  end;
  freesoftsurface(tmp);
  if (r2.cx <= 2) and
        not (df_canvasispixmap in drawinfo.gc.drawingflags) then begin
   waylandpresent(dst);       //caret and similar, drawn outside of a paint
  end;
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

//font functions

procedure gdi_getfont(var drawinfo: drawinfoty);
begin
 fontcache.getfont(drawinfo);
end;

procedure gdi_freefontdata(var drawinfo: drawinfoty);
begin
 if ffontcache <> nil then begin
  fontcache.freefontdata(drawinfo);
 end;
end;

procedure gdi_gettext16width(var drawinfo: drawinfoty);
begin
 fontcache.gettext16width(drawinfo);
end;

procedure gdi_getchar16widths(var drawinfo: drawinfoty);
begin
 fontcache.getchar16widths(drawinfo);
end;

procedure gdi_getfontmetrics(var drawinfo: drawinfoty);
begin
 fontcache.getfontmetrics(drawinfo);
end;

procedure gdi_drawstring16(var drawinfo: drawinfoty);
begin
 if currentfont <> 0 then begin
  fontcache.drawstring16(drawinfo,currentfont);
 end;
end;

procedure gdi_getfonthighres(var drawinfo: drawinfoty);
begin
end;

var
 savedfg,savedbg: rgbtriplety;
 savedrop: rasteropty;
 savedfont: fontty;

procedure waylandpushgcstate;
begin
 savedfg:= fgrgb;
 savedbg:= bgrgb;
 savedrop:= currentrop;
 savedfont:= currentfont;
end;

procedure waylandpopgcstate;
begin
 fgrgb:= savedfg;
 bgrgb:= savedbg;
 currentrop:= savedrop;
 currentfont:= savedfont;
end;

procedure waylandinitdefaultfont;
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

function waylandgetgdifuncs: pgdifunctionaty;
begin
 result:= @gdifunctions;
end;

initialization
 fgrgb.red:= 0;   fgrgb.green:= 0;   fgrgb.blue:= 0;   fgrgb.res:= 0;
 bgrgb.red:= 255; bgrgb.green:= 255; bgrgb.blue:= 255; bgrgb.res:= 0;
end.
