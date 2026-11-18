{ MSEgui Copyright (c) 2026 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseegl;
{ Minimal EGL binding, loaded at run time from libEGL.so.1, for offscreen
  desktop OpenGL (pbuffer). It does not depend on X11, SDL or Wayland, so
  it is used by the SDL2, SDL3 and pure Wayland backends where the GLX
  window of mseopenglwidget is not available.

  The display is the EGL "surfaceless" platform (Mesa) if possible,
  otherwise the default EGL display. }
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 ctypes,sysutils;

const
 EGL_NONE = $3038;
 EGL_SURFACE_TYPE = $3033;
 EGL_PBUFFER_BIT = $0001;
 EGL_RENDERABLE_TYPE = $3040;
 EGL_OPENGL_BIT = $0008;
 EGL_RED_SIZE = $3024;
 EGL_GREEN_SIZE = $3023;
 EGL_BLUE_SIZE = $3022;
 EGL_ALPHA_SIZE = $3021;
 EGL_DEPTH_SIZE = $3025;
 EGL_STENCIL_SIZE = $3026;
 EGL_WIDTH = $3057;
 EGL_HEIGHT = $3056;
 EGL_OPENGL_API = $30A2;
 EGL_PLATFORM_SURFACELESS_MESA = $31DD;

type
 teglcontext = class
  private
   fdpy: pointer;
   fconfig: pointer;
   fcontext: pointer;
   fsurface: pointer;
   fwidth,fheight: integer;
   procedure destroysurface;
  public
   constructor create(const adepthsize,astencilsize,aalphasize: integer);
                       //-1 = none, raises an exception if EGL is not usable
   destructor destroy; override;
   procedure resize(const awidth,aheight: integer);
                       //creates a new pbuffer if the size has changed
   procedure makecurrent;
   procedure release;
   property width: integer read fwidth;
   property height: integer read fheight;
 end;

function eglavailable: boolean;
                //true if libEGL can be loaded

implementation
uses
 dynlibs;

type
 eglbooleanty = cuint;
 eglintty = cint32;

var
 libegl: tlibhandle;
 egldisplay: pointer;
 eglrefcount: integer;
 egltried: boolean;
 eglok: boolean;

 eglGetDisplay: function(native: pointer): pointer; cdecl;
 eglGetPlatformDisplay: function(platform: cuint; native: pointer;
                                          attribs: pointer): pointer; cdecl;
 eglInitialize: function(dpy: pointer; major,minor: pcint): eglbooleanty; cdecl;
 eglBindAPI: function(api: cuint): eglbooleanty; cdecl;
 eglChooseConfig: function(dpy: pointer; attribs: pcint; configs: ppointer;
                       configsize: eglintty; numconfig: pcint): eglbooleanty;
                                                                       cdecl;
 eglCreateContext: function(dpy: pointer; config: pointer; share: pointer;
                                           attribs: pcint): pointer; cdecl;
 eglDestroyContext: function(dpy: pointer; ctx: pointer): eglbooleanty; cdecl;
 eglCreatePbufferSurface: function(dpy: pointer; config: pointer;
                                           attribs: pcint): pointer; cdecl;
 eglDestroySurface: function(dpy: pointer; surface: pointer): eglbooleanty;
                                                                       cdecl;
 eglMakeCurrent: function(dpy: pointer; draw,read: pointer;
                                        ctx: pointer): eglbooleanty; cdecl;
 eglGetError: function: eglintty; cdecl;

function loadegl: boolean;

 function getproc(const aname: string): pointer;
 begin
  result:= getprocaddress(libegl,aname);
 end;

begin
 if not egltried then begin
  egltried:= true;
  libegl:= loadlibrary('libEGL.so.1');
  if libegl = nilhandle then begin
   libegl:= loadlibrary('libEGL.so');
  end;
  if libegl <> nilhandle then begin
   pointer(eglGetDisplay):= getproc('eglGetDisplay');
   pointer(eglGetPlatformDisplay):= getproc('eglGetPlatformDisplay');
                                 //can be nil, EGL < 1.5
   pointer(eglInitialize):= getproc('eglInitialize');
   pointer(eglBindAPI):= getproc('eglBindAPI');
   pointer(eglChooseConfig):= getproc('eglChooseConfig');
   pointer(eglCreateContext):= getproc('eglCreateContext');
   pointer(eglDestroyContext):= getproc('eglDestroyContext');
   pointer(eglCreatePbufferSurface):= getproc('eglCreatePbufferSurface');
   pointer(eglDestroySurface):= getproc('eglDestroySurface');
   pointer(eglMakeCurrent):= getproc('eglMakeCurrent');
   pointer(eglGetError):= getproc('eglGetError');
   eglok:= assigned(eglGetDisplay) and assigned(eglInitialize) and
           assigned(eglBindAPI) and assigned(eglChooseConfig) and
           assigned(eglCreateContext) and assigned(eglDestroyContext) and
           assigned(eglCreatePbufferSurface) and assigned(eglDestroySurface) and
           assigned(eglMakeCurrent) and assigned(eglGetError);
  end;
 end;
 result:= eglok;
end;

function eglavailable: boolean;
begin
 result:= loadegl;
end;

function getdisplay: pointer;
var
 major,minor: cint;
begin
 if egldisplay = nil then begin
  if not loadegl then begin
   raise exception.create('EGL (libEGL.so.1) is not available.');
  end;
  if assigned(eglGetPlatformDisplay) then begin       //no window system
   egldisplay:= eglGetPlatformDisplay(EGL_PLATFORM_SURFACELESS_MESA,nil,nil);
   if (egldisplay <> nil) and
                (eglInitialize(egldisplay,@major,@minor) = 0) then begin
    egldisplay:= nil;
   end;
  end;
  if egldisplay = nil then begin
   egldisplay:= eglGetDisplay(nil);
   if (egldisplay <> nil) and
                (eglInitialize(egldisplay,@major,@minor) = 0) then begin
    egldisplay:= nil;
   end;
  end;
  if egldisplay = nil then begin
   raise exception.create('Could not initialize an EGL display.');
  end;
 end;
 result:= egldisplay;
end;

{ teglcontext }

constructor teglcontext.create(const adepthsize,astencilsize,aalphasize: integer);
var
 attribs: array[0..19] of cint;
 num: cint;
 index: integer;

 procedure put(const atag,avalue: cint);
 begin
  attribs[index]:= atag;
  inc(index);
  attribs[index]:= avalue;
  inc(index);
 end;

 function sizeof1(const avalue: integer): cint;
 begin
  if avalue < 0 then begin
   result:= 0;
  end
  else begin
   result:= avalue;
  end;
 end;

begin
 inherited create;
 fdpy:= getdisplay;
 if eglBindAPI(EGL_OPENGL_API) = 0 then begin
  raise exception.create('EGL: desktop OpenGL is not available.');
 end;
 index:= 0;
 put(EGL_SURFACE_TYPE,EGL_PBUFFER_BIT);
 put(EGL_RENDERABLE_TYPE,EGL_OPENGL_BIT);
 put(EGL_RED_SIZE,8);
 put(EGL_GREEN_SIZE,8);
 put(EGL_BLUE_SIZE,8);
 put(EGL_ALPHA_SIZE,sizeof1(aalphasize));
 put(EGL_DEPTH_SIZE,sizeof1(adepthsize));
 put(EGL_STENCIL_SIZE,sizeof1(astencilsize));
 attribs[index]:= EGL_NONE;
 num:= 0;
 if (eglChooseConfig(fdpy,@attribs[0],@fconfig,1,@num) = 0) or
                                                     (num < 1) then begin
  raise exception.create('EGL: no suitable pbuffer configuration.');
 end;
 attribs[0]:= EGL_NONE;
 fcontext:= eglCreateContext(fdpy,fconfig,nil,@attribs[0]);
 if fcontext = nil then begin
  raise exception.create('EGL: could not create an OpenGL context.');
 end;
end;

destructor teglcontext.destroy;
begin
 if fdpy <> nil then begin
  eglMakeCurrent(fdpy,nil,nil,nil);
  destroysurface;
  if fcontext <> nil then begin
   eglDestroyContext(fdpy,fcontext);
  end;
 end;
 inherited;
end;

procedure teglcontext.destroysurface;
begin
 if fsurface <> nil then begin
  eglDestroySurface(fdpy,fsurface);
  fsurface:= nil;
 end;
end;

procedure teglcontext.resize(const awidth,aheight: integer);
var
 attribs: array[0..4] of cint;
begin
 if (fsurface = nil) or (awidth <> fwidth) or (aheight <> fheight) then begin
  eglMakeCurrent(fdpy,nil,nil,nil);
  destroysurface;
  fwidth:= awidth;
  fheight:= aheight;
  if fwidth < 1 then begin
   fwidth:= 1;
  end;
  if fheight < 1 then begin
   fheight:= 1;
  end;
  attribs[0]:= EGL_WIDTH;
  attribs[1]:= fwidth;
  attribs[2]:= EGL_HEIGHT;
  attribs[3]:= fheight;
  attribs[4]:= EGL_NONE;
  fsurface:= eglCreatePbufferSurface(fdpy,fconfig,@attribs[0]);
  if fsurface = nil then begin
   raise exception.create('EGL: could not create a pbuffer ('+
                                inttostr(fwidth)+'x'+inttostr(fheight)+').');
  end;
 end;
end;

procedure teglcontext.makecurrent;
begin
 if fsurface <> nil then begin
  eglBindAPI(EGL_OPENGL_API);
  eglMakeCurrent(fdpy,fsurface,fsurface,fcontext);
 end;
end;

procedure teglcontext.release;
begin
 eglMakeCurrent(fdpy,nil,nil,nil);
end;

end.
