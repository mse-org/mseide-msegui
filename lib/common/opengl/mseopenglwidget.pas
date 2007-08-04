{ MSEgui Copyright (c) 2007 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseopenglwidget;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 msewindowwidget,msegl,{$ifdef unix}mseglx,x,xlib,{$else}windows,{$endif}
 mseguiintf,msetypes,mseguiglob,mseclasses,
 msegraphutils;
 
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
//   faspect: real;
   fwin: winidty;
   fonrender: openglrendereventty;
  protected
   procedure docreatewinid(const aparent: winidty; const awidgetrect: rectty;
                  var aid: winidty); override;
   procedure dodestroywinid; override;
   procedure doclientpaint(const aupdaterect: rectty); override;
//   procedure clientrectchanged; override;
   procedure updateviewport(const arect: rectty); override;
  public
//   property aspect: real read faspect;
  published
   property onrender: openglrendereventty read fonrender write fonrender;
   
 end;

 topenglwidget = class(tcustomopenglwidget)
  published
   property onrender;
   property optionswidget;
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
   property oncreatewinid;
   property ondestroywinid;
   property onclientpaint;
   property onclientrectchanged;
   property onwindowmouseevent;
   property ondestroy;
 end;
  
implementation
uses
 sysutils{$ifdef unix},xutil{$endif};
 
{ tcustomopenglwidget }

procedure tcustomopenglwidget.doclientpaint(const aupdaterect: rectty);
begin
 {$ifdef unix}
 glxmakecurrent(fdpy,fwin,fcontext);
 {$else}
 wglmakecurrent(fdc,fcontext);
 {$endif}
 if canevent(tmethod(fonrender)) then begin
  fonrender(self,aupdaterect);
 end;
// glflush;
 {$ifdef unix}
 glxswapbuffers(fdpy,fwin);
 {$else}
 swapbuffers(fdc);
 {$endif}
end;

procedure tcustomopenglwidget.dodestroywinid;
begin
 {$ifdef unix}
 if fcontext <> nil then begin
  glxmakecurrent(fdpy,0,nil);
  glxdestroycontext(fdpy,fcontext);
  fcontext:= nil;
 end;
 {$else}
 if fcontext <> 0 then begin
  wglmakecurrent(0,0);
  wgldeletecontext(fcontext);
  releasedc(fwin,fdc);
 end;
 {$endif}
 inherited;
end;

procedure tcustomopenglwidget.updateviewport(const arect: rectty);
begin
{$ifdef unix}
 if fcontext <> nil then begin
  glxmakecurrent(fdpy,fwin,fcontext);
{$else}
 if fcontext <> 0 then begin
  wglmakecurrent(fdc,fcontext);
{$endif}
  with arect do begin
   glviewport(x,y,cx,cy);  
  end;
 end;
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
const
  attr: array[0..8] of integer = 
  (GLX_RGBA,GLX_RED_SIZE,8,GLX_GREEN_SIZE,8,GLX_BLUE_SIZE,8,
   GLX_DOUBLEBUFFER,none);
var
 int1,int2: integer;
 visinfo: pxvisualinfo;
 attributes: txsetwindowattributes;
begin
 if not glxinitialized then begin
  initGlx();
 end;
 fdpy:= msedisplay;
 fscreen:= defaultscreen(fdpy);
 if not glxqueryextension(fdpy,int1,int2) then begin
  raise exception.create('GLX extension not supported.');
 end;
 visinfo:= glxchoosevisual(fdpy,fscreen,attr);
 if visinfo = nil then begin
  raise exception.create('Could not find visual.');
 end;
 fcontext:= glxcreatecontext(fdpy,visinfo,nil,true);
 fcolormap:= xcreatecolormap(fdpy,mserootwindow,visinfo^.visual,allocnone);
 attributes.colormap:= fcolormap;
 with awidgetrect do begin
  aid:= xcreatewindow(fdpy,aparent,x,y,cx,cy,0,visinfo^.depth,
        inputoutput,visinfo^.visual,cwcolormap,@attributes);
 end;
 fwin:= aid;
 xfree(visinfo);
 if fcontext = nil then begin
{$else}
var
 pixeldesc: tpixelformatdescriptor;
 int1: integer; 
begin
 aid:= createchildwindow;
 fwin:= aid;
 fdc:= getdc(fwin);
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
{$endif}
  raise exception.create('Could not create an OpenGL rendering context.');
 end;
// checkviewport;
end;

end.
