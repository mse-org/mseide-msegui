{ MSEgui Copyright (c) 1999-2011 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msesdlgdi;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msegraphics,msetypes,msestrings,mseguiglob,sdl4msegui,msebitmap,
 msesysutils,sdl2_gfxprimitives;

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
    end;
 
    if arenderer <> 0 then begin
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
 rgbcolor: rgbtriplety;   // add to the var section

begin
 with drawinfo.gcvalues^,drawinfo.gc do begin
 
  if gvm_colorforeground in mask then begin
 rgbcolor:= colortorgb(colorforeground);
 fgrgb.red:= rgbcolor.blue;
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
  if mask * [gvm_linewidth,gvm_dashes,gvm_capstyle,gvm_joinstyle] <> [] then begin
  end;
  if gvm_rasterop in mask then begin
  //writeln('rasterop=',ord(rasterop));
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
   end;
   SDL_CheckError('SDL_RenderSetClipRect');
  end;
  if gvm_font in mask then begin
  end;
 end;
end;

procedure gdi_getcanvasclass(var drawinfo: drawinfoty); //gdifunc
begin
 //dummy
end;

procedure gdi_endpaint(var drawinfo: drawinfoty); //gdifunc
begin
 SDL_RenderPresent(drawinfo.gc.handle);
 //SDL_CheckError('endpaint');
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
begin
 inc(x1,origin.x); inc(y1,origin.y);
 inc(x2,origin.x); inc(y2,origin.y);
 //choose the best performance method
 if awidth = 0 then begin
  if (x1 = x2) or (y1 = y2) then
   lineRGBA(renderer,x1,y1,x2,y2,acolor.red,acolor.green,acolor.blue,255-acolor.res)
  else
   aalineRGBA(renderer,x1,y1,x2,y2,acolor.red,acolor.green,acolor.blue,255-acolor.res);
 end
 else begin
  thickLineRGBA(renderer,x1,y1,x2,y2,awidth,
                      acolor.red,acolor.green,acolor.blue,255-acolor.res);
 end;
end;

procedure gdi_drawlines(var drawinfo: drawinfoty);
var
 int1,lwidth: integer;
 rgb: rgbtriplety;
 pp: ppointaty;
 org: pointty;
begin
//writeln('gdi_drawlines lines count=',drawinfo.points.count,
  //      ' fg=',fgrgb.red,',',fgrgb.green,',',fgrgb.blue);
 with drawinfo do begin
  if points.count < 2 then exit;
  pp:= ppointaty(points.points);
  org:= origin;
  rgb:= colortorgb(acolorforeground);
  lwidth:= (gcvalues^.lineinfo.width + linewidthroundvalue) shr linewidthshift;
  for int1:= 1 to points.count-1 do begin
   drawsingleline(gc.handle,org,pp^[int1-1].x,pp^[int1-1].y,
                                pp^[int1].x,pp^[int1].y,lwidth,rgb);
  end;
  if points.closed then begin
   drawsingleline(gc.handle,org,pp^[points.count-1].x,pp^[points.count-1].y,
                                pp^[0].x,pp^[0].y,lwidth,rgb);
  end;
 end;
end;

procedure gdi_drawlinesegments(var drawinfo: drawinfoty);
var
 int1,lwidth: integer;
 rgb: rgbtriplety;
 pp: ppointaty;
 org: pointty;
begin
{
writeln('gdi_drawlinesegments lines count=',drawinfo.points.count,
        ' fg=',fgrgb.red,',',fgrgb.green,',',fgrgb.blue);
writeln('drawlines acolorfg=',inttohex(longword(drawinfo.acolorforeground),8),
        ' gcfg=',inttohex(longword(drawinfo.gcvalues^.colorforeground),8),
        ' cachedfg=',fgrgb.red,',',fgrgb.green,',',fgrgb.blue);
}
//writeln('gdi_drawlinesegments');
 with drawinfo do begin
  pp:= ppointaty(points.points);
  org:= origin;
  rgb:= colortorgb(acolorforeground);
  lwidth:= (gcvalues^.lineinfo.width + linewidthroundvalue) shr linewidthshift;
  for int1:= 0 to points.count div 2 - 1 do begin
   drawsingleline(gc.handle,org,pp^[2*int1].x,pp^[2*int1].y,
                                pp^[2*int1+1].x,pp^[2*int1+1].y,lwidth,rgb);
  end;
 end;
end;

procedure gdi_drawellipse(var drawinfo: drawinfoty);
var
 rgb: rgbtriplety;
begin
//writeln('gdi_drawellipse');
 with drawinfo, rect.rect^ do begin
  rgb:= colortorgb(acolorforeground);
  // aaellipseRGBA wants center + radii, rect is the bounding box
  aaellipseRGBA(gc.handle,
                origin.x + pos.x + cx div 2,
                origin.y + pos.y + cy div 2,
                cx div 2, cy div 2,
                rgb.red,rgb.green,rgb.blue,255-rgb.res);
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

procedure gdi_drawarc(var drawinfo: drawinfoty);
begin
 SDL_CheckError('drawarc');
end;

procedure gdi_drawstring16(var drawinfo: drawinfoty);
var
 s: ansistring;
 i,c: integer;
 ptext: pwidechar;
 rect1: SDL_Rect;
begin
 with drawinfo, text16pos do begin
 {
writeln('DRAWSTR count=',drawinfo.text16pos.count,
        ' opaque=',df_opaque in drawinfo.gc.drawingflags,
        ' x=',drawinfo.text16pos.pos^.x);
    }    
         if count > 0 then begin
   if df_opaque in gc.drawingflags then begin
    // selected text etc.: fill the background first (8x8 font: ascent 7, descent 1)
    rect1.x:= pos^.x + origin.x;
    rect1.y:= pos^.y + origin.y - 7;
    rect1.w:= count * 8;
    rect1.h:= 8;
    SDL_SetRenderDrawBlendMode(gc.handle,SDL_BLENDMODE_NONE);
    SDL_SetRenderDrawColor(gc.handle,bgrgb.red,bgrgb.green,bgrgb.blue,
                                                           255 - bgrgb.res);
    SDL_RenderFillRect(gc.handle,@rect1);
   end;
   setlength(s, count);
   ptext:= pwidechar(text);
   for i:= 0 to count - 1 do begin
    c:= ord(ptext[i]);
    if c > 127 then c:= ord('?');
    s[i + 1]:= char(c);
   end;
   stringRGBA(gc.handle, pos^.x + origin.x, pos^.y + origin.y - 7, pchar(s),
              fgrgb.red, fgrgb.green, fgrgb.blue, 255 - fgrgb.res);
  end;
 end;
 SDL_CheckError('drawstring16');
end;
procedure gdi_fillrect(var drawinfo: drawinfoty);
var
 rect1: SDL_Rect;
begin
with drawinfo do begin
  rect1.x:= rect.rect^.x + origin.x;
  rect1.y:= rect.rect^.y + origin.y;
  rect1.w:= rect.rect^.cx;
  rect1.h:= rect.rect^.cy;
 { 
  if rect1.w <= 2 then begin
 writeln('thin fill x=',rect1.x,' y=',rect1.y,' w=',rect1.w,' h=',rect1.h,
         ' fg=',fgrgb.red,',',fgrgb.green,',',fgrgb.blue);
end;
}
//  writeln('fillrect x=',rect1.x,' y=',rect1.y,' w=',rect1.w,' h=',rect1.h,
  //      ' fg=',fgrgb.red,',',fgrgb.green,',',fgrgb.blue);
 
 // if (fgrgb.red = 0) and (fgrgb.green = 0) and (fgrgb.blue = 0) then exit;
  
  SDL_SetRenderDrawColor(gc.handle,fgrgb.red,fgrgb.green,fgrgb.blue,255-fgrgb.res);
  SDL_RenderFillRect(gc.handle,@rect1);
  SDL_CheckError('SDL_RenderFillRect');
 end;
end;

procedure gdi_fillelipse(var drawinfo: drawinfoty);
var
 rgb: rgbtriplety;
begin
//writeln('gdi_fillelipse');
 with drawinfo, rect.rect^ do begin
  rgb:= colortorgb(acolorforeground);
  filledEllipseRGBA(gc.handle, pos.x + origin.x, pos.y + origin.y, round(cx/2), round(cy/2), 
  rgb.red, rgb.green, rgb.blue, 255-rgb.res);
 end;
end;

procedure gdi_fillarc(var drawinfo: drawinfoty);
begin
 SDL_CheckError('fillarc');
end;

procedure gdi_fillpolygon(var drawinfo: drawinfoty);
begin
 with drawinfo.points do begin
  //handlepoly(drawinfo,points,count-1,true);
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
{
  if rect1.w <= 2 then begin
   writeln('CARET mode=',ord(drawinfo.copyarea.copymode),
     ' srcispixmap=',df_canvasispixmap in tcanvas1(source).fdrawinfo.gc.drawingflags,
     ' dstispixmap=',df_canvasispixmap in drawinfo.gc.drawingflags,
     ' src=',rect1.x,',',rect1.y,' dest=',rect2.x,',',rect2.y);
  end;
}
  if not (df_canvasispixmap in tcanvas1(source).fdrawinfo.gc.drawingflags) then begin
   // source is the window: read its pixels into the destination pixmap
   if df_canvasispixmap in drawinfo.gc.drawingflags then begin
    dsp:= CSDL_Surface(ptruint(drawinfo.paintdevice));
    SDL_RenderReadPixels(tcanvas1(source).fdrawinfo.gc.handle,@rect1,$16362004,
         pointer(ptruint(dsp^.pixels) + ptruint(rect2.y*dsp^.pitch + rect2.x*4)),
         dsp^.pitch);
   end;
   exit;
  end;

  asurface:= SDL_CreateRGBSurface(0,rect2.w,rect2.h,32,
                       $00FF0000,$0000FF00,$000000FF,$FF000000);
  SDL_unlockSurface(tcanvas1(source).fdrawinfo.paintdevice);
  SDL_unlockSurface(asurface);
  SDL_SetSurfaceBlendMode(tcanvas1(source).fdrawinfo.paintdevice,
                                                    SDL_BLENDMODE_NONE);
  SDL_UpperBlit(tcanvas1(source).fdrawinfo.paintdevice,@rect1,asurface,nil);
  sp:= CSDL_Surface(ptruint(asurface));

  if drawinfo.copyarea.mask <> nil then begin
   msurface:= SDL_CreateRGBSurface(0,rect2.w,rect2.h,32,
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

  if drawinfo.copyarea.copymode = rop_xor then begin
   dsurface:= SDL_CreateRGBSurface(0,rect2.w,rect2.h,32,
                        $00FF0000,$0000FF00,$000000FF,$FF000000);
   dp:= CSDL_Surface(ptruint(dsurface));
   SDL_RenderReadPixels(drawinfo.gc.handle,@rect2,$16362004,dp^.pixels,dp^.pitch);
 //  writeln('XOR src0=',inttohex(PLongword(sp^.pixels)^,8),
   //        ' dest0=',inttohex(PLongword(dp^.pixels)^,8));
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
    SDL_RenderPresent(drawinfo.gc.handle);   // test: show caret steps at once
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

procedure gdi_getfont(var drawinfo: drawinfoty);
begin
 with drawinfo.getfont,fontdata^ do begin
  font:= 1;               // nonzero fake handle, there is only one font
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
end;

procedure gdi_freefontdata(var drawinfo: drawinfoty);
begin
end;

procedure gdi_gettext16width(var drawinfo: drawinfoty);
begin
 with drawinfo.gettext16width do begin
  result:= count * 8;
 end;
end;

procedure gdi_getchar16widths(var drawinfo: drawinfoty);
var
 int1: integer;
 po1: pinteger;
begin
 with drawinfo.getchar16widths do begin
  po1:= resultpo;
  for int1:= 0 to count-1 do begin
   po1^:= 8;
   inc(po1);
  end;
 end;
end;

procedure gdi_getfontmetrics(var drawinfo: drawinfoty);
begin
 with drawinfo.getfontmetrics.resultpo^ do begin
  leftbearing:= 0;
  width:= 8;
  rightbearing:= 0;
  sum:= 8;
 end;
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
