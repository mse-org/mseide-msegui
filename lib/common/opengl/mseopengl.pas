{ MSEgui Copyright (c) 2007-2011 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseopengl;
//
// under construction
// 
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 msegl,{$ifdef unix}mseglx,x,xlib,xutil,{$else}windows,{$endif}
 msegraphics,msetypes,mseguiglob,msegraphutils,mseopenglgdi;
 
type  
 topenglcanvas = class(tcanvas)
  private
   fviewport: rectty;
   procedure setviewport(const avalue: rectty);
  protected
   fcontextinfo: contextinfoty;
   function getgdifuncs: pgdifunctionaty; override;
   procedure lock;
   procedure unlock;
   procedure makecurrent; //calls lock
   procedure gdi(const func: gdifuncty); override;
  public
   constructor create(const user: tobject; const intf: icanvas);
   procedure linktopaintdevice(const aparent: winidty;
                          const windowrect: rectty; out aid: winidty);
   procedure init(const acolor: colorty = cl_none); //cl_none -> colorbackground
   procedure swapbuffers;
   property viewport: rectty read fviewport write setviewport;
 end;
 
implementation
uses
 mseguiintf;

const
 defaultcontextattributes: contextattributesty =
  (buffersize: -1;
   level: 0;
   rgba: true;
   stereo: false;
   auxbuffers: -1;
   redsize: 8;
   greensize: 8;
   bluesize: 8;
   alphasize: -1;
   depthsize: -1;
   stencilsize: -1;
   accumredsize: -1;
   accumgreensize: -1;
   accumbluesize: -1;
   accumalphasize: -1
  );
{$ifdef unix}
  defaultvisualattributes: array[0..8] of integer = 
  (GLX_RGBA,GLX_RED_SIZE,8,GLX_GREEN_SIZE,8,GLX_BLUE_SIZE,8,
   GLX_DOUBLEBUFFER,none);
{$endif}

{ topenglcanvas }

constructor topenglcanvas.create(const user: tobject; const intf: icanvas);
begin
 fcontextinfo.attrib:= defaultcontextattributes;
{$ifdef unix}
 fcontextinfo.visualattributes:= defaultvisualattributes;
{$endif}
 inherited;
end;

function topenglcanvas.getgdifuncs: pgdifunctionaty;
begin
 result:= openglgetgdifuncs;
end;

procedure topenglcanvas.linktopaintdevice(const aparent: winidty;
               const windowrect: rectty; out aid: winidty);
var
 gc1: gcty;
begin
 fillchar(gc1,sizeof(gc1),0);
 guierror(createrendercontext(aparent,windowrect,fcontextinfo,gc1,aid));
 inherited linktopaintdevice(paintdevicety(aid),gc1,nullpoint);
end;

procedure topenglcanvas.setviewport(const avalue: rectty);
begin
 fviewport:= avalue;
 if fdrawinfo.gc.handle <> 0 then begin
  makecurrent;
  fdrawinfo.rect.rect:= @fviewport;
  gdi_setviewport(fdrawinfo);
  unlock;
 end;
end;

procedure topenglcanvas.makecurrent;
begin
 if fdrawinfo.gc.handle = 0 then begin
  checkgcstate([cs_gc]);
 end;
 lock;
 gdi_makecurrent(fdrawinfo);
end;

procedure topenglcanvas.swapbuffers;
begin
 makecurrent;
 gdi_swapbuffers(fdrawinfo);
 unlock;
end;

procedure topenglcanvas.init(const acolor: colorty = cl_none);
begin
 makecurrent;
 if acolor = cl_none then begin
  fdrawinfo.color.color:= colorbackground;
 end
 else begin
  fdrawinfo.color.color:= acolor;
 end;
 gdi_clear(fdrawinfo);
 unlock;
end;

procedure topenglcanvas.gdi(const func: gdifuncty);
begin
 fgdifuncs^[func](fdrawinfo);
end;

procedure topenglcanvas.lock;
begin
 //todo
end;

procedure topenglcanvas.unlock;
begin
 //todo
end;

end.
