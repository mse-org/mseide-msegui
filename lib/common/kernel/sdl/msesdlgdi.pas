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

procedure gdi_creategc(var drawinfo: drawinfoty);
var
 int1, int2, int3: integer;
 arenderer: ptruint;
 pinfo: PSDL_RendererInfo;
begin
 with drawinfo.creategc do begin
  gcpo^.gdifuncs:= gui_getgdifuncs;
  error:= gde_creategc;
  case kind of
   gck_pixmap: begin
    //SDL_SaveBMP_toFile(paintdevice,'creategc.bmp');
    gcpo^.handle:= SDL_CreateSoftwareRenderer(paintdevice);
    error:= SDL_CheckErrorGDI('creategc');
   end;
   gck_screen: begin
    //choose the best renderer supported
    int3:= -1;
    arenderer:= SDL_CreateRenderer(paintdevice,int3,SDL_RENDERER_SOFTWARE{SDL_RENDERER_ACCELERATED});
    error:= gde_ok;
    {//wait for final release SDL 2, we use software renderer only
     //at the moment some bugs in SDL 2 with DirectX and OpenGL/ES
    if (arenderer=0) or (SDL_GetError<>'') then begin
     SDL_DestroyRenderer(arenderer);
     int1:= SDL_GetNumRenderDrivers;
     for int2:= 1 to int1 do begin
      if SDL_GetRenderDriverInfo(int2,pinfo)=0 then begin
       debugwriteln(pinfo^.name+' w = '+inttostr(pinfo^.max_texture_width)+' h = '+inttostr(pinfo^.max_texture_width));
       arenderer:= SDL_CreateRenderer(paintdevice,int2,SDL_RENDERER_ACCELERATED);
       if (arenderer=0) or (SDL_GetError<>'') then begin
        error:= SDL_CheckErrorGDI('creategc');
        SDL_DestroyRenderer(arenderer);
       end else begin
        break;
       end;
      end;
     end;
    end;}
    gcpo^.handle:= arenderer;
   end;
  end;
 end;
end;

procedure gdi_destroygc(var drawinfo: drawinfoty);
begin 
 SDL_DestroyRenderer(drawinfo.gc.handle);
 SDL_CheckError('destroygc');
end;

procedure gdi_changegc(var drawinfo: drawinfoty);
var
 rgbcolor: rgbtriplety;
 ar1: rectarty;
 int1: integer;
 rect1: SDL_Rect;
 pt1: pointty;
begin
 with drawinfo.gcvalues^,drawinfo.gc do begin
  if gvm_colorbackground in mask then begin
   rgbcolor:= colortorgb(colorbackground);
   SDL_SetRenderDrawColor(handle,rgbcolor.red,rgbcolor.green,rgbcolor.blue,255-rgbcolor.res);
   SDL_CheckError('SetRenderDrawColor');
  end;
  if gvm_colorforeground in mask then begin
   rgbcolor:= colortorgb(colorforeground);
   SDL_SetRenderDrawColor(handle,rgbcolor.red,rgbcolor.green,rgbcolor.blue,255-rgbcolor.res);
   SDL_CheckError('SetRenderDrawColor');
  end;
  if mask * [gvm_linewidth,gvm_dashes,gvm_capstyle,gvm_joinstyle] <> [] then begin
  end;
  if gvm_rasterop in mask then begin
  end;
  if gvm_brush in mask then begin
  end;
  if gvm_brushorigin in mask then begin
  end;
  if gvm_clipregion in mask then begin
   if clipregion <> 0 then begin
    ar1:= gui_regiontorects(clipregion);
    if ar1<>nil then begin
     //pt1:= addpoint(ar1[0].pos,cliporigin);
     //rect1.x:= pt1.x;
     //rect1.y:= pt1.y;
     //rect1.w:= ar1[0].size.cx;
     //rect1.h:= ar1[0].size.cy;
     //cliporigin:= ar1[0].pos;
     //SDL_RenderSetViewport(drawinfo.gc.handle,@rect1);
    end;
   end;
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
 //SDL_RenderClear(drawinfo.gc.handle);
 //SDL_CheckError('flush');
end;

procedure gdi_movewindowrect(var drawinfo: drawinfoty); //gdifunc
begin
 with drawinfo.moverect do begin
  gui_movewindowrect(drawinfo.paintdevice,dist^,rect^);  
 end;
end;

procedure drawsingleline(renderer: SDL_Renderer; x1,y1,x2,y2,awidth: integer; acolor: rgbtriplety);
begin
 //choose the best performance method
 if awidth=0 then begin
  if (x1=x2) or (y1=y2) then
   lineRGBA(renderer, x1, y1, x2, y2, acolor.red, acolor.green, acolor.blue, 255-acolor.res)
  else
   aalineRGBA(renderer, x1, y1, x2, y2, acolor.red, acolor.green, acolor.blue, 255-acolor.res);
 end else begin
  thickLineRGBA(renderer, x1, y1, x2, y2, awidth, acolor.red, acolor.green, acolor.blue, 255-acolor.res);
 end;
end;

procedure gdi_drawlines(var drawinfo: drawinfoty);
var
 int1,lwidth: integer;
 startpoint: pointty;
 rgb: rgbtriplety;
begin
 with drawinfo, points do begin
  startpoint.x:= points^.x;
  startpoint.y:= points^.y;
  rgb:= colortorgb(acolorforeground);
  lwidth:= (gcvalues^.lineinfo.width + linewidthroundvalue) shr linewidthshift;
  for int1:= 1 to count-1 do begin
   drawsingleline(drawinfo.gc.handle, ppointaty(points)^[int1-1].x, ppointaty(points)^[int1-1].y,
     ppointaty(points)^[int1].x, ppointaty(points)^[int1].y, lwidth, rgb);
  end;
  if closed then begin
   drawsingleline(drawinfo.gc.handle, ppointaty(points)^[int1].x, ppointaty(points)^[int1].y,
     startpoint.x, startpoint.y, lwidth, rgb);
  end;
 end;
end;

procedure gdi_drawlinesegments(var drawinfo: drawinfoty);
var
 int1,lwidth: integer;
 rgb: rgbtriplety;
begin
 with drawinfo, drawinfo.points do begin
  rgb:= colortorgb(acolorforeground);
  lwidth:= (gcvalues^.lineinfo.width + linewidthroundvalue) shr linewidthshift;
  for int1:= 0 to count div 2 - 1 do begin
   drawsingleline(drawinfo.gc.handle, ppointaty(points)^[int1-1].x, ppointaty(points)^[int1-1].y,
     ppointaty(points)^[int1].x, ppointaty(points)^[int1].y, lwidth, rgb);
   inc(points,2);
  end;
 end;
end;

procedure gdi_drawellipse(var drawinfo: drawinfoty);
var
 rgb: rgbtriplety;
begin
 with drawinfo, rect.rect^ do begin
  rgb:= colortorgb(acolorforeground);
  aaellipseRGBA(gc.handle, pos.x, pos.y, round(cx/2), round(cy/2), 
    rgb.red, rgb.green, rgb.blue, 255-rgb.res);
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
begin
 SDL_CheckError('drawstring16');
end;

procedure gdi_fillrect(var drawinfo: drawinfoty);
var
 rect1: SDL_Rect;
begin
 rect1.x:= drawinfo.rect.rect^.x;
 rect1.y:= drawinfo.rect.rect^.y;
 rect1.w:= drawinfo.rect.rect^.cx;
 rect1.h:= drawinfo.rect.rect^.cy;
 SDL_RenderFillRect(drawinfo.gc.handle,@rect1);
 SDL_CheckError('SDL_RenderFillRect');
end;

procedure gdi_fillelipse(var drawinfo: drawinfoty);
var
 rgb: rgbtriplety;
begin
 with drawinfo, rect.rect^ do begin
  rgb:= colortorgb(acolorforeground);
  filledEllipseRGBA(gc.handle, pos.x, pos.y, round(cx/2), round(cy/2), 
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

procedure gdi_copyarea(var drawinfo: drawinfoty);
var
 rect1,rect2: SDL_rect;
 maskbefore: tsimplebitmap;
 atexture: SDL_Texture;
 asurface: PSDL_Surface;
 pt1: pointty;
begin
 with drawinfo,copyarea,gcvalues^ do begin
  if not (df_canvasispixmap in tcanvas1(source).fdrawinfo.gc.drawingflags) then begin
   exit;
  end;
  rect1.x:= sourcerect^.x;
  rect1.y:= sourcerect^.y;
  rect1.w:= sourcerect^.cx;
  rect1.h:= sourcerect^.cy;
  rect2.x:= destrect^.x;
  rect2.y:= destrect^.y;
  rect2.w:= destrect^.cx;
  rect2.h:= destrect^.cy;


  //pt1:= addpoint(makepoint(destrect^.x,destrect^.y),origin);
  //SDL_SaveBMP_toFile(tcanvas1(source).fdrawinfo.paintdevice,'source.bmp');
  //SDL_SaveBMP_toFile(drawinfo.paintdevice,'target.bmp');
  asurface:= SDL_CreateRGBSurface(0,rect2.w,rect2.h,32,0,0,0,0);
  SDL_unlockSurface(tcanvas1(source).fdrawinfo.paintdevice);
  SDL_unlockSurface(asurface);
  SDL_UpperBlit(tcanvas1(source).fdrawinfo.paintdevice,@rect1, asurface, nil);
  //SDL_SaveBMP_toFile(asurface,'clip.bmp');
  atexture:= SDL_CreateTextureFromSurface(drawinfo.gc.handle,asurface);
  if atexture<>0 then begin
   if SDL_RenderCopy(drawinfo.gc.handle, atexture, nil, @rect2)=0 then begin
    //SDL_RenderPresent(drawinfo.gc.handle);
    SDL_CheckError('rendercopy');
    //SDL_SaveBMP_toFile(drawinfo.paintdevice,'result.bmp');
   end;
  end;
  SDL_DestroyTexture(atexture);
  SDL_FreeSurface(asurface);
  {if mask<>nil then begin
   asurface:= SDL_CreateRGBSurface(0,rect2.w,rect2.h,32,0,0,0,0);
   SDL_unlockSurface(mask.handle);
   SDL_unlockSurface(asurface);
   SDL_UpperBlit(mask.handle,@rect1, asurface, nil);
   //SDL_UpperBlitScaled(mask.handle,@rect1, asurface, nil);
   atexture:= SDL_CreateTextureFromSurface(drawinfo.gc.handle,asurface);
   SDL_SetRenderDrawBlendMode(atexture,SDL_BLENDMODE_ADD);
   if atexture<>0 then begin
    if SDL_RenderCopy(drawinfo.gc.handle, atexture, nil, @rect2)=0 then begin
     SDL_RenderPresent(drawinfo.gc.handle);
     SDL_CheckError('rendercopy');
    end;
   end;
   SDL_DestroyTexture(atexture);
   SDL_FreeSurface(asurface); 
  end;}
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
 
end;

procedure gdi_freefontdata(var drawinfo: drawinfoty);
begin
end;

procedure gdi_gettext16width(var drawinfo: drawinfoty);
begin
end;

procedure gdi_getchar16widths(var drawinfo: drawinfoty);
begin
end;

procedure gdi_getfontmetrics(var drawinfo: drawinfoty);
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
end.
