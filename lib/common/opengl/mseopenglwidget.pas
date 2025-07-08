{ MSEgui Copyright (c) 2007-2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseopenglwidget;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
{$ifdef linux} {$define unix}{$endif}
interface
uses
 classes,mclasses,msewindowwidget,msegl,
 {$ifdef unix}mseglx,mxlib,{$else}windows,{$endif}
 mseguiintf,msetypes,mseguiglob,mseclasses,msemenus,mseevent,msegui,msegraphics,
 msegraphutils;

{$ifdef unix}
{$ifdef FPC}
 {$macro on}
 {$define xchar2b:=txchar2b}
 {$define xcharstruct:=txcharstruct}
 {$define xfontstruct:=txfontstruct}
 {$define xfontprop:=txfontprop}
 {$define xpoint:=txpoint}
 {$define xgcvalues:=txgcvalues}
 {$define region:=tregion}
 {$define ximage:=tximage}
 {$define xwindowattributes:=txwindowattributes}
 {$define xclientmessageevent:=txclientmessageevent}
 {$define xtype:=_type}
 {$define xrectangle:=txrectangle}
 {$define keysym:=tkeysym}
 {$define xsetwindowattributes:=txsetwindowattributes}
 {$define xwindowchanges:=txwindowchanges}
 {$define xevent:=txevent}
 {$define xfunction:=_function}
 {$define xwindow:=window}
 {$define xlookupkeysym_:=xlookupkeysymval}
 {$define c_class:= _class}
 {$define xtextproperty:= txtextproperty}
{$endif}
const
  defaultvisualattributes: array[0..8] of integer =
  (GLX_RGBA,GLX_RED_SIZE,8,GLX_GREEN_SIZE,8,GLX_BLUE_SIZE,8,
   GLX_DOUBLEBUFFER,none);
{$endif}

type
 tcustomopenglwidget = class;
 openglwidgeteventty = procedure(const sender: tcustomopenglwidget) of object;
 openglrendereventty = procedure(const sender: tcustomopenglwidget;
                 const aupdaterect: rectty) of object;

 tcustomopenglwidget = class(tcustomwindowwidget)
  private
   {$ifdef unix}
   fcontext: glxcontext;
   fdpy: pdisplay;
   fcolormap: tcolormap;
   fscreen: integer;
   {$else}
   fdc: hdc;
   fcontext: hglrc;
   {$endif}
   fwin: winidty;
   fonrender: openglrendereventty;
  {$ifdef unix}
   fvisualattributes: integerarty;
  {$endif}
   fattrib_buffersize: integer;
   fattrib_level: integer;
   fattrib_rgba: boolean;
   fattrib_doublebuffer: boolean;
   fattrib_dri: boolean;
   fattrib_stereo: boolean;
   fattrib_auxbuffers: integer;
   fattrib_redsize: integer;
   fattrib_greensize: integer;
   fattrib_bluesize: integer;
   fattrib_alphasize: integer;
   fattrib_depthsize: integer;
   fattrib_stencilsize: integer;
   fattrib_accumredsize: integer;
   fattrib_accumgreensize: integer;
   fattrib_accumbluesize: integer;
   fattrib_accumalphasize: integer;
   function setcurrent: boolean;
  protected
   procedure doclientrectchanged; override;
   procedure docreatewinid(const aparent: winidty; const awidgetrect: rectty;
                  var aid: winidty); override;
   procedure dodestroywinid; override;
   function canclientpaint: boolean; override;
   procedure doclientpaint(const aupdaterect: rectty); override;
   procedure updateviewport(const arect: rectty); override;
  public
   constructor create(aowner: tcomponent); override;
   {$ifdef unix}
   property visualattributes: integerarty read fvisualattributes
                                                   write fvisualattributes;
   {$endif}
  published
   property onrender: openglrendereventty read fonrender write fonrender;
   property attrib_buffersize: integer read fattrib_buffersize
                  write fattrib_buffersize default -1;
   property attrib_level: integer read fattrib_level
                  write fattrib_level default 0;
   property attrib_rgba: boolean read fattrib_rgba
                  write fattrib_rgba default true;
   property attrib_doublebuffer: boolean read fattrib_doublebuffer
                  write fattrib_doublebuffer default true;
   property attrib_dri: boolean read fattrib_dri
                  write fattrib_dri default true;
   property attrib_stereo: boolean read fattrib_stereo
                  write fattrib_stereo default false;
   property attrib_auxbuffers: integer read fattrib_auxbuffers
                  write fattrib_auxbuffers default -1;
   property attrib_redsize: integer read fattrib_redsize
                  write fattrib_redsize default 8;
   property attrib_greensize: integer read fattrib_greensize
                  write fattrib_greensize default 8;
   property attrib_bluesize: integer read fattrib_bluesize
                  write fattrib_bluesize default 8;
   property attrib_alphasize: integer read fattrib_alphasize
                  write fattrib_alphasize default -1;
   property attrib_depthsize: integer read fattrib_depthsize
                  write fattrib_depthsize default -1;
   property attrib_stencilsize: integer read fattrib_stencilsize
                  write fattrib_stencilsize default -1;
   property attrib_accumredsize: integer read fattrib_accumredsize
                  write fattrib_accumredsize default -1;
   property attrib_accumgreensize: integer read fattrib_accumgreensize
                  write fattrib_accumgreensize default -1;
   property attrib_accumbluesize: integer read fattrib_accumbluesize
                  write fattrib_accumbluesize default -1;
   property attrib_accumalphasize: integer read fattrib_accumalphasize
                  write fattrib_accumalphasize default -1;
 end;

 topenglwidget = class(tcustomopenglwidget)
  published
   property onrender;
   property optionswidget;
   property optionsskin;
   property bounds_x;
   property bounds_y;
   property bounds_cx;
   property bounds_cy;
   property bounds_cxmin;
   property bounds_cymin;
   property bounds_cxmax;
   property bounds_cymax;
   property color;
   property cursor;
   property frame;
   property face;
   property anchors;
   property taborder;
   property hint;
   property popupmenu;
   property onpopup;
   property onshowhint;
   property enabled;
   property visible;
   property fpsmax;
   property oncreatewinid;
   property ondestroywinid;
//   property onclientpaint;
   property onclientrectchanged;
   property onwindowmouseevent;
   property onwindowmousewheelevent;
   property ondestroy;
 end;

implementation
uses
 sysutils,mseglextglob;

{ tcustomopenglwidget }

constructor tcustomopenglwidget.create(aowner: tcomponent);
begin
 fattrib_buffersize:= -1;
 fattrib_level:= 0;
 fattrib_rgba:= true;
 fattrib_doublebuffer:= true;
 fattrib_dri:= true;
 fattrib_stereo:= false;
 fattrib_auxbuffers:= -1;
 fattrib_redsize:= 8;
 fattrib_greensize:= 8;
 fattrib_bluesize:= 8;
 fattrib_alphasize:= -1;
 fattrib_depthsize:= -1;
 fattrib_stencilsize:= -1;
 fattrib_accumredsize:= -1;
 fattrib_accumgreensize:= -1;
 fattrib_accumbluesize:= -1;
 fattrib_accumalphasize:= -1;
 inherited;
end;

procedure tcustomopenglwidget.dodestroywinid;
begin
 {$ifdef unix}
 if fcontext <> nil then begin
  glxmakecurrent(fdpy,0,nil);
  glxdestroycontext(fdpy,fcontext);
  fcontext:= nil;
  xfreecolormap(fdpy,fcolormap);
 end;
 {$else}
 if fcontext <> 0 then begin
  wglmakecurrent(0,0);
  wgldeletecontext(fcontext);
  releasedc(fwin,fdc);
 end;
 {$endif}
 inherited;
 releaseopengl;
end;

{
procedure tcustomopenglwidget.clientrectchanged;
begin
 inherited;
 checkviewport;
end;
}
procedure tcustomopenglwidget.docreatewinid(const aparent: winidty;
               const awidgetrect: rectty; var aid: winidty);
{$ifdef unix}
var
 index: integer;
 ar1: integerarty;

 procedure putboolean(const atag: integer; avalue: boolean);
 begin
  if index > high(ar1) then begin
   setlength(ar1,19+high(ar1)*2);
  end;
  if avalue then begin
   ar1[index]:= atag;
   inc(index);
  end;
 end;

 procedure putvalue(const atag,avalue,defaultvalue: integer);
 begin
  if index > high(ar1) then begin
   setlength(ar1,19+high(ar1)*2);
  end;
  if avalue <> defaultvalue then begin
   ar1[index]:= atag;
   inc(index);
   ar1[index]:= avalue;
   inc(index);
  end;
 end;

var
 int1,int2: integer;
 visinfo: pxvisualinfo;
 attributes: xsetwindowattributes;

begin
 fdpy:= msedisplay;
 fscreen:= xdefaultscreen(fdpy);
 initializeopengl([]);
 if not glxqueryextension(fdpy,int1,int2) then begin
  raise exception.create('GLX extension not supported.');
 end;
 if fvisualattributes = nil then begin
  setlength(ar1,34);
  index:= 0;
  putboolean(glx_doublebuffer,fattrib_doublebuffer);
  putvalue(glx_buffer_size,fattrib_buffersize,-1);
  putvalue(glx_level,fattrib_level,0);
  putboolean(glx_rgba,fattrib_rgba);
  putboolean(glx_stereo,fattrib_stereo);
  putvalue(glx_aux_buffers,fattrib_auxbuffers,-1);
  putvalue(glx_red_size,fattrib_redsize,-1);
  putvalue(glx_green_size,fattrib_greensize,-1);
  putvalue(glx_blue_size,fattrib_bluesize,-1);
  putvalue(glx_alpha_size,fattrib_alphasize,-1);
  putvalue(glx_depth_size,fattrib_depthsize,-1);
  putvalue(glx_stencil_size,fattrib_stencilsize,-1);
  putvalue(glx_accum_red_size,fattrib_accumredsize,-1);
  putvalue(glx_accum_green_size,fattrib_accumgreensize,-1);
  putvalue(glx_accum_blue_size,fattrib_accumbluesize,-1);
  putvalue(glx_accum_alpha_size,fattrib_accumalphasize,-1);
  setlength(ar1,index+1); //none
 end
 else begin
  ar1:= copy(fvisualattributes);
  setlength(ar1,high(ar1)+3); //add security nulls
 end;
 visinfo:= glxchoosevisual(fdpy,fscreen,pinteger(ar1));
 if visinfo = nil then begin
  raise exception.create('Could not find visual.');
 end;
 fcontext:= glxcreatecontext(fdpy,visinfo,nil,true);
 fcolormap:= xcreatecolormap(fdpy,gui_getrootwindow(),
                                       visinfo^.visual,allocnone);
 attributes.colormap:= fcolormap;
 with awidgetrect do begin
  aid:= xcreatewindow(fdpy,aparent,x,y,cx,cy,0,visinfo^.depth,
        inputoutput,visinfo^.visual,cwcolormap,@attributes);
  xselectinput(fdpy,aid,exposuremask); //will be mapped to parent
 end;
 fwin:= aid;
 xfree(visinfo);
 if fcontext = nil then begin
{$else}
var
 pixeldesc: tpixelformatdescriptor;
 int1: integer;
begin
 initializeopengl([]);
 aid:= createchildwindow;
 fwin:= aid;
 fdc:= getdc(fwin);
 fillchar(pixeldesc,sizeof(pixeldesc),0);
 with pixeldesc do begin
  nsize:= sizeof(pixeldesc);
  nversion:= 1;
  dwflags:= pfd_draw_to_window or pfd_support_opengl;
  if fattrib_doublebuffer then begin
   dwflags:= dwflags or pfd_doublebuffer;
  end;
  ipixeltype:= pfd_type_rgba;
  ccolorbits:= 24;
  cdepthbits:= 32;
 end;
 int1:= choosepixelformat(fdc,@pixeldesc);
 setpixelformat(fdc,int1,@pixeldesc);
 fcontext:= wglcreatecontext(fdc);
 if fcontext = 0 then begin
{$endif}
  raise exception.create('Could not create an OpenGL rendering context.');
 end;
 setcurrent;
 inherited;
// checkviewport;
end;

function tcustomopenglwidget.setcurrent: boolean;
begin
{$ifdef unix}
 result:= fcontext <> nil;
{$else}
 result:= fcontext <> 0;
{$endif}
 if result then begin
  {$ifdef unix}
  glxmakecurrent(fdpy,fwin,fcontext);
  {$else}
  wglmakecurrent(fdc,fcontext);
  {$endif}
 end;
end;

procedure tcustomopenglwidget.updateviewport(const arect: rectty);
begin
 if setcurrent then begin
  with arect do begin
   glviewport(x,y,cx,cy);
  end;
 end;
end;

procedure tcustomopenglwidget.doclientpaint(const aupdaterect: rectty);
begin
 setcurrent;
 if canevent(tmethod(fonrender)) then begin
  fonrender(self,aupdaterect);
 end;
// glflush;
 if fattrib_doublebuffer then begin
  {$ifdef unix}
  glxswapbuffers(fdpy,fwin);
  {$else}
  swapbuffers(fdc);
  {$endif}
 end
 else begin
  glflush;
//  glfinish;
 end;
end;

procedure tcustomopenglwidget.doclientrectchanged;
begin
 setcurrent;
 inherited;
end;

function tcustomopenglwidget.canclientpaint: boolean;
begin
 result:= assigned(fonrender);
end;

end.
