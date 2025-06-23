{

  Translation of the Mesa GLX headers for FreePascal
  Copyright (C) 1999 Sebastian Guenther


  Mesa 3-D graphics library
  Version:  3.0
  Copyright (C) 1995-1998  Brian Paul

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Library General Public
  License as published by the Free Software Foundation; either
  version 2 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Library General Public License for more details.

  You should have received a copy of the GNU Library General Public
  License along with this library; if not, write to the Free
  Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
}
//
// modified 2011 by Martin Schreiber
//
//{$MODE delphi}  // objfpc would not work because of direct proc var assignments

{You have to enable Macros (compiler switch "-Sm") for compiling this unit!
 This is necessary for supporting different platforms with different calling
 conventions via a single unit.}

{$ifdef FPC}{$mode objfpc} {$h+}{$endif}

unit mseglx;

interface
{$ifdef linux}{$define unix}{$endif}
{$IFDEF Unix}
  uses
   mxlib,mseglextglob;
  {$DEFINE HasGLX}  // Activate GLX stuff
{$ELSE}
  {$MESSAGE Unsupported platform.}
{$ENDIF}

{$IFNDEF HasGLX}
  {$MESSAGE GLX not present on this platform.}
{$ENDIF}


//*)
// =======================================================
//   GLX consts, types and functions
// =======================================================

// Tokens for glXChooseVisual and glXGetConfig:
const
  GLX_USE_GL                            = 1;
  GLX_BUFFER_SIZE                       = 2;
  GLX_LEVEL                             = 3;
  GLX_RGBA                              = 4;
  GLX_DOUBLEBUFFER                      = 5;
  GLX_STEREO                            = 6;
  GLX_AUX_BUFFERS                       = 7;
  GLX_RED_SIZE                          = 8;
  GLX_GREEN_SIZE                        = 9;
  GLX_BLUE_SIZE                         = 10;
  GLX_ALPHA_SIZE                        = 11;
  GLX_DEPTH_SIZE                        = 12;
  GLX_STENCIL_SIZE                      = 13;
  GLX_ACCUM_RED_SIZE                    = 14;
  GLX_ACCUM_GREEN_SIZE                  = 15;
  GLX_ACCUM_BLUE_SIZE                   = 16;
  GLX_ACCUM_ALPHA_SIZE                  = 17;

  // GLX_EXT_visual_info extension
  GLX_X_VISUAL_TYPE_EXT                 = $22;
  GLX_TRANSPARENT_TYPE_EXT              = $23;
  GLX_TRANSPARENT_INDEX_VALUE_EXT       = $24;
  GLX_TRANSPARENT_RED_VALUE_EXT         = $25;
  GLX_TRANSPARENT_GREEN_VALUE_EXT       = $26;
  GLX_TRANSPARENT_BLUE_VALUE_EXT        = $27;
  GLX_TRANSPARENT_ALPHA_VALUE_EXT       = $28;


  // Error codes returned by glXGetConfig:
  GLX_BAD_SCREEN                        = 1;
  GLX_BAD_ATTRIBUTE                     = 2;
  GLX_NO_EXTENSION                      = 3;
  GLX_BAD_VISUAL                        = 4;
  GLX_BAD_CONTEXT                       = 5;
  GLX_BAD_VALUE                         = 6;
  GLX_BAD_ENUM                          = 7;

  // GLX 1.1 and later:
  GLX_VENDOR                            = 1;
  GLX_VERSION                           = 2;
  GLX_EXTENSIONS                        = 3;

  // GLX_visual_info extension
  GLX_TRUE_COLOR_EXT                    = $8002;
  GLX_DIRECT_COLOR_EXT                  = $8003;
  GLX_PSEUDO_COLOR_EXT                  = $8004;
  GLX_STATIC_COLOR_EXT                  = $8005;
  GLX_GRAY_SCALE_EXT                    = $8006;
  GLX_STATIC_GRAY_EXT                   = $8007;
  GLX_NONE_EXT                          = $8000;
  GLX_TRANSPARENT_RGB_EXT               = $8008;
  GLX_TRANSPARENT_INDEX_EXT             = $8009;

type
{$ifndef FPC}
  txid = xid;
{$endif}
  // From XLib:
  XPixmap = TXID;
  XFont = TXID;
  XColormap = TXID;

  GLXContext = Pointer;
  GLXPixmap = TXID;
  GLXDrawable = TXID;
  GLXContextID = TXID;

  TXPixmap = XPixmap;
  TXFont = XFont;
  TXColormap = XColormap;

  TGLXContext = GLXContext;
  TGLXPixmap = GLXPixmap;
  TGLXDrawable = GLXDrawable;
  TGLXContextID = GLXContextID;

var
  glXChooseVisual: function(dpy: PDisplay; screen: Integer; attribList: PInteger): PXVisualInfo; cdecl;
  glXCreateContext: function(dpy: PDisplay; vis: PXVisualInfo; shareList: GLXContext; direct: Boolean): GLXContext; cdecl;
  glXDestroyContext: procedure(dpy: PDisplay; ctx: GLXContext); cdecl;
  glXMakeCurrent: function(dpy: PDisplay; drawable: GLXDrawable; ctx: GLXContext): Boolean; cdecl;
  glXCopyContext: procedure(dpy: PDisplay; src, dst: GLXContext; mask: LongWord); cdecl;
  glXSwapBuffers: procedure(dpy: PDisplay; drawable: GLXDrawable); cdecl;
  glXCreateGLXPixmap: function(dpy: PDisplay; visual: PXVisualInfo; pixmap: XPixmap): GLXPixmap; cdecl;
  glXDestroyGLXPixmap: procedure(dpy: PDisplay; pixmap: GLXPixmap); cdecl;
  glXQueryExtension: function(dpy: PDisplay; var errorb, event: Integer): Boolean; cdecl;
  glXQueryVersion: function(dpy: PDisplay; var maj, min: Integer): Boolean; cdecl;
  glXIsDirect: function(dpy: PDisplay; ctx: GLXContext): Boolean; cdecl;
  glXGetConfig: function(dpy: PDisplay; visual: PXVisualInfo; attrib: Integer; var value: Integer): Integer; cdecl;
  glXGetCurrentContext: function: GLXContext; cdecl;
  glXGetCurrentDrawable: function: GLXDrawable; cdecl;
  glXWaitGL: procedure; cdecl;
  glXWaitX: procedure; cdecl;
  glXUseXFont: procedure(font: XFont; first, count, list: Integer); cdecl;

  // GLX 1.1 and later
  glXQueryExtensionsString: function(dpy: PDisplay; screen: Integer): PChar; cdecl;
  glXQueryServerString: function(dpy: PDisplay; screen, name: Integer): PChar; cdecl;
  glXGetClientString: function(dpy: PDisplay; name: Integer): PChar; cdecl;

  // Mesa GLX Extensions
  glXCreateGLXPixmapMESA: function(dpy: PDisplay; visual: PXVisualInfo; pixmap: XPixmap; cmap: XColormap): GLXPixmap; cdecl;
  glXReleaseBufferMESA: function(dpy: PDisplay; d: GLXDrawable): Boolean; cdecl;
  glXCopySubBufferMESA: procedure(dpy: PDisplay; drawbale: GLXDrawable; x, y, width, height: Integer); cdecl;
  glXGetVideoSyncSGI: function(var counter: LongWord): Integer; cdecl;
  glXWaitVideoSyncSGI: function(divisor, remainder: Integer; var count: LongWord): Integer; cdecl;


// =======================================================
//
// =======================================================

function load_glx: boolean;
function load_glx_mesa: boolean;

implementation
{$ifdef FPC}{$LINKLIB m}{$endif}

uses
 msegl,msedynload,msesys{$ifdef FPC},dynlibs{$endif};

function load_glx: boolean;
const
 funcs: array[0..19] of funcinfoty =
   (
    (n: 'glXChooseVisual'; d: {$ifndef FPC}@{$endif}@glXChooseVisual),
    (n: 'glXCreateContext'; d: {$ifndef FPC}@{$endif}@glXCreateContext),
    (n: 'glXDestroyContext'; d: {$ifndef FPC}@{$endif}@glXDestroyContext),
    (n: 'glXMakeCurrent'; d: {$ifndef FPC}@{$endif}@glXMakeCurrent),
    (n: 'glXCopyContext'; d: {$ifndef FPC}@{$endif}@glXCopyContext),
    (n: 'glXSwapBuffers'; d: {$ifndef FPC}@{$endif}@glXSwapBuffers),
    (n: 'glXCreateGLXPixmap'; d: {$ifndef FPC}@{$endif}@glXCreateGLXPixmap),
    (n: 'glXDestroyGLXPixmap'; d: {$ifndef FPC}@{$endif}@glXDestroyGLXPixmap),
    (n: 'glXQueryExtension'; d: {$ifndef FPC}@{$endif}@glXQueryExtension),
    (n: 'glXQueryVersion'; d: {$ifndef FPC}@{$endif}@glXQueryVersion),
    (n: 'glXIsDirect'; d: {$ifndef FPC}@{$endif}@glXIsDirect),
    (n: 'glXGetConfig'; d: {$ifndef FPC}@{$endif}@glXGetConfig),
    (n: 'glXGetCurrentContext'; d: {$ifndef FPC}@{$endif}@glXGetCurrentContext),
    (n: 'glXGetCurrentDrawable'; d: {$ifndef FPC}@{$endif}@glXGetCurrentDrawable),
    (n: 'glXWaitGL'; d: {$ifndef FPC}@{$endif}@glXWaitGL),
    (n: 'glXWaitX'; d: {$ifndef FPC}@{$endif}@glXWaitX),
    (n: 'glXUseXFont'; d: {$ifndef FPC}@{$endif}@glXUseXFont),
    // GLX 1.1 and later
    (n: 'glXQueryExtensionsString'; d: {$ifndef FPC}@{$endif}@glXQueryExtensionsString),
    (n: 'glXQueryServerString'; d: {$ifndef FPC}@{$endif}@glXQueryServerString),
    (n: 'glXGetClientString'; d: {$ifndef FPC}@{$endif}@glXGetClientString)
   );
begin
 result:= getprocaddresses(libgl,funcs,true);
end;

function load_glx_mesa: boolean;
const
 funcs: array[0..4] of funcinfoty =
   (
    (n: 'glXCreateGLXPixmapMESA'; d: {$ifndef FPC}@{$endif}@glXCreateGLXPixmapMESA),
    (n: 'glXReleaseBufferMESA'; d: {$ifndef FPC}@{$endif}@glXReleaseBufferMESA),
    (n: 'glXCopySubBufferMESA'; d: {$ifndef FPC}@{$endif}@glXCopySubBufferMESA),
    (n: 'glXGetVideoSyncSGI'; d: {$ifndef FPC}@{$endif}@glXGetVideoSyncSGI),
    (n: 'glXWaitVideoSyncSGI'; d: {$ifndef FPC}@{$endif}@glXWaitVideoSyncSGI)
   );
begin
 result:= getprocaddresses(libgl,funcs,true);
end;

end.
