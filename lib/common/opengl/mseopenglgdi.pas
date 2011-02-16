{ MSEgui Copyright (c) 2011 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseopenglgdi;
//
//under construction
//
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 msegl,{$ifdef unix}mseglx,x,xlib,xutil,{$else}windows,{$endif}
 msegraphics,msetypes,msegraphutils,mseguiglob;

type
 contextattributesty = record
  buffersize: integer;
  level: integer;
  rgba: boolean;
  stereo: boolean;
  auxbuffers: integer;
  redsize: integer;
  greensize: integer;
  bluesize: integer;
  alphasize: integer;
  depthsize: integer;
  stencilsize: integer;
  accumredsize: integer;
  accumgreensize: integer;
  accumbluesize: integer;
  accumalphasize: integer;
 end;

 contextinfoty = record
  attrib: contextattributesty;
 {$ifdef unix}
  visualattributes: integerarty;
 {$endif}
 end;
 
 
function createrendercontext(const aparent: winidty; const windowrect: rectty;
                                   const ainfo: contextinfoty;
                                   var gc: gcty; out aid: winidty): guierrorty;
function openglgetgdifuncs: pgdifunctionaty;

procedure gdi_makecurrent(var drawinfo: drawinfoty);
procedure gdi_setviewport(var drawinfo: drawinfoty);
procedure gdi_swapbuffers(var drawinfo: drawinfoty);
procedure gdi_clear(var drawinfo: drawinfoty);

implementation
uses
 mseguiintf,mseftgl;
 
type
 oglgcdty = record
  {$ifdef unix}
  fcontext: glxcontext;
  fdpy: pdisplay;
  fcolormap: tcolormap;
  fscreen: integer;
  {$else}
  fdc: hdc;
  fcontext: hglrc;
  {$endif}
  pd: paintdevicety;
  gclineoptions: lineoptionsty;
 end;

 {$if sizeof(oglgcdty) > sizeof(gcpty)} {$error 'buffer overflow'}{$endif}

 oglgcty =  record
  case integer of
   0: (d: oglgcdty;);
   1: (_bufferspace: gcpty;);
 end;
 glcolorty = record
  r,g,b,a: glclampf;
 end;
  
procedure notimplemented;
begin
 guierror(gue_notimplemented);
end;


procedure putboolean(var ar1: integerarty; var index: integer;
                             const atag: integer; const avalue: boolean);
begin
 if avalue then begin
  if index > high(ar1) then begin
   setlength(ar1,19+high(ar1)*2);
  end;
  ar1[index]:= atag;
  inc(index);
 end;
end; 

procedure putvalue(var ar1: integerarty; var index: integer;
                             const atag,avalue,defaultvalue: integer);
begin
 if avalue <> defaultvalue then begin
  if index > high(ar1) then begin
   setlength(ar1,19+high(ar1)*2);
  end;
  ar1[index]:= atag;
  inc(index);
  ar1[index]:= avalue;
  inc(index);
 end;
end;

procedure makecurrent(const gc: gcty);
begin
 with oglgcty(gc.platformdata).d do begin
{$ifdef unix}
  glxmakecurrent(fdpy,pd,fcontext);
{$else}
  wglmakecurrent(fdc,fcontext);
{$endif}
 end;
end;

procedure initcontext(const winid: winidty; var gc: gcty);
begin
 with oglgcty(gc.platformdata).d do begin
  pd:= winid;
 end;
 makecurrent(gc);
 glclearstencil(0);
 glclear(gl_stencil_buffer_bit);
end;
 
{$ifdef unix}

function createrendercontext(const aparent: winidty; const windowrect: rectty;
                                   const ainfo: contextinfoty;
                                   var gc: gcty; out aid: winidty): guierrorty;
var
 index: integer;
 ar1: integerarty;
 int1,int2: integer;
 visinfo: pxvisualinfo;
 attributes: txsetwindowattributes;
 
begin
 result:= gue_ok;
 if not glxinitialized then begin
  initGlx();
 end;
 with oglgcty(gc.platformdata).d do begin
  fdpy:= msedisplay;
  fscreen:= defaultscreen(fdpy);
  if not glxqueryextension(fdpy,int1,int2) then begin
   result:= gue_noglx;
   exit;
  end;
  index:= 0;
  with ainfo.attrib do begin
   putboolean(ar1,index,glx_doublebuffer,true);
   putvalue(ar1,index,glx_buffer_size,buffersize,-1);
   putvalue(ar1,index,glx_level,level,0);
   putboolean(ar1,index,glx_rgba,rgba);
   putboolean(ar1,index,glx_stereo,stereo);
   putvalue(ar1,index,glx_aux_buffers,auxbuffers,-1);
   putvalue(ar1,index,glx_red_size,redsize,-1);
   putvalue(ar1,index,glx_green_size,greensize,-1);
   putvalue(ar1,index,glx_blue_size,bluesize,-1);
   putvalue(ar1,index,glx_alpha_size,alphasize,-1);
   putvalue(ar1,index,glx_depth_size,depthsize,-1);
   putvalue(ar1,index,glx_stencil_size,stencilsize,-1);
   putvalue(ar1,index,glx_accum_red_size,accumredsize,-1);
   putvalue(ar1,index,glx_accum_green_size,accumgreensize,-1);
   putvalue(ar1,index,glx_accum_blue_size,accumbluesize,-1);
   putvalue(ar1,index,glx_accum_alpha_size,accumalphasize,-1);
   setlength(ar1,index+1); //none
  end;
  visinfo:= glxchoosevisual(fdpy,fscreen,pinteger(ar1));
  if visinfo = nil then begin
   result:= gue_novisual;
   exit;
  end;
  try
   fcontext:= glxcreatecontext(fdpy,visinfo,nil,true);
   if fcontext = nil then begin
    result:= gue_rendercontext;
    exit;
   end;
   gc.handle:= ptruint(fcontext);
   fcolormap:= xcreatecolormap(fdpy,mserootwindow,visinfo^.visual,allocnone);
   attributes.colormap:= fcolormap;
   with windowrect do begin
    aid:= xcreatewindow(fdpy,aparent,x,y,cx,cy,0,visinfo^.depth,
          inputoutput,visinfo^.visual,cwcolormap,@attributes);
    xselectinput(fdpy,aid,exposuremask); //will be mapped to parent
   end;
   if aid = 0 then begin
    result:= gue_createwindow;
    exit;
   end;
  // fwin:= aid;
  finally
   xfree(visinfo);
  end;
 end;
 initcontext(aid,gc);
end;
{$endif}

{$ifdef mswindows}
function createrendercontext(const aparent: winidty; const windowrect: rectty;
                                   const ainfo: contextinfoty;
                                   var gc: gcty; out aid: winidty): guierrorty;
var
 pixeldesc: tpixelformatdescriptor;
 int1: integer; 
 options1: internalwindowoptionsty;
 wi1: windowty;
begin
 result:= gue_ok;
 fillchar(options1,sizeof(options1),0);
 options1.parent:= aparent;
 guierror(gui_createwindow(windowrect,options1,wi1));
 aid:= wi1.id;
 if aid = 0 then begin
  result:= gue_createwindow;
  exit;
 end;
 with oglgcty(gc.platformdata).d do begin
  fdc:= getdc(aid);
  fillchar(pixeldesc,sizeof(pixeldesc),0);
  with pixeldesc do begin
   nsize:= sizeof(pixeldesc);
   nversion:= 1;
   dwflags:= pfd_draw_to_window or pfd_support_opengl or pfd_doublebuffer;
   ipixeltype:= pfd_type_rgba;
   ccolorbits:= 24;
   cdepthbits:= 32;
  end;
  int1:= choosepixelformat(fdc,@pixeldesc);
  setpixelformat(fdc,int1,@pixeldesc);
  fcontext:= wglcreatecontext(fdc);
  if fcontext = 0 then begin
   result:= gue_rendercontext;
   exit;
  end;
  gc.handle:= ptruint(fcontext);
 end;
 initcontext(aid,gc);
end;
{$endif}

procedure colortogl(const source: colorty; out dest: glcolorty);
var
 co1: rgbtriplety;
begin
 co1:= colortorgb(source);
 dest.r:= co1.red/255;
 dest.g:= co1.green/255;
 dest.b:= co1.blue/255;
 dest.a:= 0;
end;

procedure sendrect(const arect: rectty);
var
 endx,endy: integer;
begin
 with arect do begin
  endx:= x+cx-1;
  endy:= y+cy-1;
  glvertex2iv(@pos);
  glvertex2i(endx,y);
  glvertex2i(endx,endy);
  glvertex2i(x,endy);
 end;
end;

procedure gdi_makecurrent(var drawinfo: drawinfoty);
begin
 with oglgcty(drawinfo.gc.platformdata).d do begin
{$ifdef unix}
  glxmakecurrent(fdpy,drawinfo.paintdevice,fcontext);
{$else}
  wglmakecurrent(fdc,fcontext);
{$endif}
 end;
end;

procedure gdi_destroygc(var drawinfo: drawinfoty); //gdifunc
begin
 with oglgcty(drawinfo.gc.platformdata).d do begin
{$ifdef unix}
  glxmakecurrent(fdpy,0,nil);
  glxdestroycontext(fdpy,fcontext);
  xfreecolormap(fdpy,fcolormap);
{$else}
  wglmakecurrent(0,0);
  wgldeletecontext(fcontext);
  releasedc(drawinfo.paintdevice,fdc);
{$endif}
 end;
end;

procedure gdi_setviewport(var drawinfo: drawinfoty);
begin
 with drawinfo.rect.rect^ do begin
  glviewport(x,y,cx,cy);
  glloadidentity;
  if (cx > 0) and (cy > 0) then begin
   glortho(-1,cx-1,cy-1,-1,-1,1);
  end;
 end;
end;

procedure gdi_swapbuffers(var drawinfo: drawinfoty);
begin
 with oglgcty(drawinfo.gc.platformdata).d do begin
 {$ifdef unix}
  glxswapbuffers(fdpy,drawinfo.paintdevice);
 {$else}
  swapbuffers(fdc);
 {$endif}
 end;
end;

procedure gdi_clear(var drawinfo: drawinfoty);
var
 co1: glcolorty;
begin
 with oglgcty(drawinfo.gc.platformdata).d do begin
  colortogl(drawinfo.color.color,co1);
  glclearcolor(co1.r,co1.g,co1.b,co1.a);
  glclear(gl_color_buffer_bit);
 end;
end;

{***************}

procedure gdi_changegc(var drawinfo: drawinfoty); //gdifunc
begin
 with drawinfo.gcvalues^,oglgcty(drawinfo.gc.platformdata).d do begin
  if gvm_colorforeground in mask then begin
   with rgbtriplety(colorforeground) do begin
    glcolor3ub(red,green,blue);
   end;
  end;
  if gvm_lineoptions in mask then begin
   if (lio_antialias in lineinfo.options) xor 
                (lio_antialias in gclineoptions) then begin
    if lio_antialias in lineinfo.options then begin
     glenable(gl_line_smooth);
     glenable(gl_blend);
     glblendfunc(gl_src_alpha,gl_one_minus_src_alpha);
    end
    else begin
     gldisable(gl_line_smooth);
     gldisable(gl_blend);
    end;
   end;
   gclineoptions:= lineinfo.options;
  end;
 end;
end;

procedure gdi_drawlines(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;

procedure gdi_drawlinesegments(var drawinfo: drawinfoty); //gdifunc
var
 po1: ppointty;
 int1: integer;
begin
 glbegin(gl_lines);
 with drawinfo.points do begin
  po1:= points;
  for int1:= count-1 downto 0 do begin
   glvertex2iv(pglint(po1));
   inc(po1);
  end;
 end;
 glend;
end;

procedure gdi_drawellipse(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;

procedure gdi_drawarc(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;

procedure gdi_fillrect(var drawinfo: drawinfoty); //gdifunc
begin 
 glbegin(gl_quads);
 sendrect(drawinfo.rect.rect^);
 glend;
end;

procedure gdi_fillelipse(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;

procedure gdi_fillarc(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;

procedure gdi_fillpolygon(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;

procedure gdi_drawstring16(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;

procedure gdi_setcliporigin(var drawinfo: drawinfoty); //gdifunc
begin
end;

procedure gdi_createemptyregion(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;

procedure gdi_createrectregion(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;

procedure gdi_createrectsregion(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;

procedure gdi_destroyregion(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;

procedure gdi_copyregion(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;

procedure gdi_moveregion(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;

procedure gdi_regionisempty(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;

procedure gdi_regionclipbox(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;

procedure gdi_regsubrect(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;

procedure gdi_regsubregion(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;

procedure gdi_regaddrect(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;

procedure gdi_regaddregion(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;

procedure gdi_regintersectrect(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;

procedure gdi_regintersectregion(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;

procedure gdi_copyarea(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;

procedure gdi_fonthasglyph(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;

const
 gdifunctions: gdifunctionaty = (
   {$ifdef FPC}@{$endif}gdi_destroygc,
   {$ifdef FPC}@{$endif}gdi_changegc,
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
   {$ifdef FPC}@{$endif}gdi_createemptyregion,
   {$ifdef FPC}@{$endif}gdi_createrectregion,
   {$ifdef FPC}@{$endif}gdi_createrectsregion,
   {$ifdef FPC}@{$endif}gdi_destroyregion,
   {$ifdef FPC}@{$endif}gdi_copyregion,
   {$ifdef FPC}@{$endif}gdi_moveregion,
   {$ifdef FPC}@{$endif}gdi_regionisempty,
   {$ifdef FPC}@{$endif}gdi_regionclipbox,
   {$ifdef FPC}@{$endif}gdi_regsubrect,
   {$ifdef FPC}@{$endif}gdi_regsubregion,
   {$ifdef FPC}@{$endif}gdi_regaddrect,
   {$ifdef FPC}@{$endif}gdi_regaddregion,
   {$ifdef FPC}@{$endif}gdi_regintersectrect,
   {$ifdef FPC}@{$endif}gdi_regintersectregion,
   {$ifdef FPC}@{$endif}gdi_copyarea,
   {$ifdef FPC}@{$endif}gdi_fonthasglyph
 );

function openglgetgdifuncs: pgdifunctionaty;
begin
 result:= @gdifunctions;
end;

end.
