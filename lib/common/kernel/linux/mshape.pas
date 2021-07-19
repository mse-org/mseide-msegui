(************************************************************

Copyright 1989, 1998  The Open Group

Permission to use, copy, modify, distribute, and sell this software and its
documentation for any purpose is hereby granted without fee, provided that
the above copyright notice appear in all copies and that both that
copyright notice and this permission notice appear in supporting
documentation.

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
OPEN GROUP BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Except as contained in this notice, the name of The Open Group shall not be
used in advertising or otherwise to promote the sale, use or other dealings
in this Software without prior written authorization from The Open Group.

********************************************************)

// Translated into Pascal by Nikolay Nikolov 2021
// Dynamic loading by Fred vS 2021

unit mshape;

{$ifdef FPC}{$mode objfpc}{$h+}{$GOTO ON}{$interfaces corba}{$endif}

{$PACKRECORDS C}

interface

uses
  dynlibs, ctypes, x, xlib, xutil;


const
  libXext = 'libXext.so.6';
  
var
  mse_hasxext : boolean = false;  

{$I mshapeconst.inc}

//#include <X11/Xutil.h>

type
  PXShapeEvent = ^TXShapeEvent;
  TXShapeEvent = record
    _type: cint;               { of event }
    serial: culong;            { # of last request processed by server }
    send_event: TBool;         { true if this came frome a SendEvent request }
    display: PDisplay;         { Display the event was read from }
    window: TWindow;           { window of event }
    kind: cint;                { ShapeBounding or ShapeClip }
    x, y: cint;                { extents of new region }
    width, height: cunsigned;
    time: TTime;               { server timestamp when region changed }
    shaped: TBool;             { true if the region exists }
  end;

var XShapeQueryExtension: function(
    display: PDisplay;
    event_base,
    error_base: Pcint
): TBoolResult; cdecl; 

var XShapeQueryVersion: function(
    display: PDisplay;
    major_version,
    minor_version: Pcint
): TStatus; cdecl; 

var XShapeCombineRegion: procedure(
    display: PDisplay;
    dest: TWindow;
    dest_kind: cint;
    x_off,
    y_off: cint;
    region: TRegion;
    op: cint
); cdecl; 

var XShapeCombineRectangles: procedure (
    display: PDisplay;
    dest: TWindow;
    dest_kind: cint;
    x_off,
    y_off: cint;
    rectangles: PXRectangle;
    n_rects: cint;
    op: cint;
    ordering: cint
); cdecl; 

var XShapeCombineMask: procedure(
    display: PDisplay;
    dest: TWindow;
    dest_kind: cint;
    x_off,
    y_off: cint;
    src: TPixmap;
    op: cint
); cdecl;

var XShapeCombineShape: procedure(
    display: PDisplay;
    dest: TWindow;
    dest_kind: cint;
    x_off,
    y_off: cint;
    src: TWindow;
    src_kind: cint;
    op: cint
); cdecl;

var XShapeOffsetShape: procedure(
    display: PDisplay;
    dest: TWindow;
    dest_kind: cint;
    x_off,
    y_off: cint
); cdecl;

var XShapeQueryExtents: function(
    display: PDisplay;
    window: TWindow;
    bounding_shaped: PBool;
    x_bounding,
    y_bounding: Pcint;
    w_bounding,
    h_bounding: Pcuint;
    clip_shaped: PBool;
    x_clip,
    y_clip: Pcint;
    w_clip,
    h_clip: Pcuint
): TStatus; cdecl; 

var XShapeSelectInput: procedure(
    display: PDisplay;
    window: TWindow;
    mask: culong
); cdecl; 

var XShapeInputSelected: function(
    display: PDisplay;
    window: TWindow
): culong; cdecl;

var XShapeGetRectangles: function(
    display: PDisplay;
    window: TWindow;
    kind: cint;
    count,
    ordering: Pcint
): PXRectangle; cdecl;

    {Special function for dynamic loading of lib ...}

    var sh_Handle:TLibHandle=dynlibs.NilHandle; // this will hold our handle for the lib; it functions nicely as a mutli-lib prevention unit as well...

    var ReferenceCounter : cardinal = 0;  // Reference counter
         
    function sh_IsLoaded : boolean; inline; 

    Function sh_Load(const libfilename:string) :boolean; // load the lib

    Procedure sh_Unload(); // unload and frees the lib from memory : do not forget to call it before close application.


implementation

function sh_IsLoaded: boolean;
begin
 Result := (sh_Handle <> dynlibs.NilHandle);
end;

Function sh_Load(const libfilename:string) :boolean;
var
thelib: string; 
begin
  Result := False;
  if sh_Handle<>0 then 
begin
 Inc(ReferenceCounter);
 result:=true {is it already there ?}
end  else 
begin {go & load the library}
   if Length(libfilename) = 0 then thelib := libXext else thelib := libfilename;
    sh_Handle:=DynLibs.SafeLoadLibrary(thelib); // obtain the handle we want
  	if sh_Handle <> DynLibs.NilHandle then
begin {now we tie the functions to the VARs from above}
mse_hasxext := true;
Pointer(XShapeQueryExtension):=DynLibs.GetProcedureAddress(sh_Handle,PChar('XShapeQueryExtension'));
Pointer(XShapeQueryVersion):=DynLibs.GetProcedureAddress(sh_Handle,PChar('XShapeQueryVersion'));
Pointer(XShapeCombineRegion):=DynLibs.GetProcedureAddress(sh_Handle,PChar('XShapeCombineRegion'));
Pointer(XShapeCombineRectangles):=DynLibs.GetProcedureAddress(sh_Handle,PChar('XShapeCombineRectangles'));
Pointer(XShapeCombineMask):=DynLibs.GetProcedureAddress(sh_Handle,PChar('XShapeCombineMask'));
Pointer(XShapeCombineShape):=DynLibs.GetProcedureAddress(sh_Handle,PChar('XShapeCombineShape'));
Pointer(XShapeOffsetShape):=DynLibs.GetProcedureAddress(sh_Handle,PChar('XShapeOffsetShape'));
Pointer(XShapeQueryExtents):=DynLibs.GetProcedureAddress(sh_Handle,PChar('XShapeQueryExtents'));
Pointer(XShapeSelectInput):=DynLibs.GetProcedureAddress(sh_Handle,PChar('XShapeSelectInput'));
Pointer(XShapeInputSelected):=DynLibs.GetProcedureAddress(sh_Handle,PChar('XShapeInputSelected'));
Pointer(XShapeGetRectangles):=DynLibs.GetProcedureAddress(sh_Handle,PChar('XShapeGetRectangles'));
 Result := sh_IsLoaded;
 ReferenceCounter:=1;   
end;
end;
end;

Procedure sh_Unload;
begin
// < Reference counting
  if ReferenceCounter > 0 then
    dec(ReferenceCounter);
  if ReferenceCounter > 0 then
    exit;
  // >
  if sh_IsLoaded then
  begin
    DynLibs.UnloadLibrary(sh_Handle);
    sh_Handle:=DynLibs.NilHandle;
  end;
end;

initialization
sh_Load('');

finalization
sh_unLoad;

end.
