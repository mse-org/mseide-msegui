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
   class function getclassgdifuncs: pgdifunctionaty; override;
   function lock: boolean; override;
   function getcontextinfopo: pointer; override;
//   procedure linktopaintdevice(apaintdevice: paintdevicety; const gc: gcty;
//                {const size: sizety;} const cliporigin: pointty); override;
  public
   constructor create(const user: tobject; const intf: icanvas); override;
   destructor destroy; override;
   procedure updatewindowoptions(var aoptions: internalwindowoptionsty); override;
   procedure init(const acolor: colorty = cl_none); //cl_none -> colorbackground
   procedure swapbuffers;
   property viewport: rectty read fviewport write setviewport;
 end;
 
 topenglbitmapcanvas = class(topenglcanvas)
 end;

 topenglwindowcanvas = class(topenglcanvas)
  public
   procedure linktopaintdevice(apaintdevice: paintdevicety; const gc: gcty;
              {const size: sizety;} const cliporigin: pointty); override;
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
   stencilsize: 1;
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
 initializeopengl([]);
 fgdinum:= openglgetgdinum;
 fcontextinfo.attrib:= defaultcontextattributes;
{$ifdef unix}
 fcontextinfo.visualattributes:= defaultvisualattributes;
{$endif}
 inherited;
end;

destructor topenglcanvas.destroy;
begin
 inherited;
 releaseopengl;
end;

class function topenglcanvas.getclassgdifuncs: pgdifunctionaty;
begin
 result:= openglgetgdifuncs;
end;

procedure topenglcanvas.setviewport(const avalue: rectty);
var
 bo1: boolean;
begin
 fviewport:= avalue;
 fdrawinfo.gc.paintdevicesize:= fviewport.size;
 if fdrawinfo.gc.handle <> 0 then begin
  bo1:= lock;
  fdrawinfo.rect.rect:= @fviewport;
  gdi_setviewport(fdrawinfo);
  if bo1 then begin
   unlock;
  end;
 end;
end;

procedure topenglcanvas.swapbuffers;
var
 bo1: boolean;
begin
 bo1:= lock;
 gdi_swapbuffers(fdrawinfo);
 if bo1 then begin
  unlock;
 end;
end;

procedure topenglcanvas.init(const acolor: colorty = cl_none);
var
 bo1: boolean;
begin
 bo1:= lock;
 if acolor = cl_none then begin
  fdrawinfo.color.color:= colorbackground;
 end
 else begin
  fdrawinfo.color.color:= acolor;
 end;
 gdi_clear(fdrawinfo);
 if bo1 then begin
  unlock;
 end;
end;

function topenglcanvas.lock: boolean;
begin
 result:= inherited lock;
 if fdrawinfo.gc.handle = 0 then begin
  checkgcstate([cs_gc]);
 end; 
 gdi_makecurrent(fdrawinfo);
end;

function topenglcanvas.getcontextinfopo: pointer;
begin
 result:= @fcontextinfo;
end;

procedure topenglcanvas.updatewindowoptions(var aoptions: internalwindowoptionsty);
var
 gc1: gcty;
begin
 inherited;
 fillchar(gc1,sizeof(gc1),0);
 gdi_choosevisual(gc1,fcontextinfo);
{$ifdef unix}
 with x11internalwindowoptionsty(aoptions.platformdata).d,
                                oglgcty(gc1.platformdata).d do begin
  if fvisinfo <> nil then begin
   depth:= fvisinfo^.depth;
   visual:= fvisinfo^.visual;
   xfree(fvisinfo);
   fvisinfo:= nil;
  end
  else begin
   depth:= 0;
   visual:= nil;
  end;
 end;
{$endif}
end;

{ topenglwindowcanvas }

procedure topenglwindowcanvas.linktopaintdevice(apaintdevice: paintdevicety;
               const gc: gcty; const cliporigin: pointty);
begin
 inherited;
 viewport:= mr(nullpoint,gc.paintdevicesize);
end;

end.
