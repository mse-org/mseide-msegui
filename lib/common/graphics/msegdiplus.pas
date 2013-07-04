{ MSEgui Copyright (c) 2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msegdiplus;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 windows,msestrings,msectypes,sysutils;
 
const
 gdipluslib: array[0..0] of filenamety = ('gdiplus.dll');

type
{$packrecords c}{$packenum 4}

 GpStatus = (
    Ok = 0,
    GenericError = 1,
    InvalidParameter = 2,
    OutOfMemory = 3,
    ObjectBusy = 4,
    InsufficientBuffer = 5,
    NotImplemented = 6,
    Win32Error = 7,
    WrongState = 8,
    Aborted = 9,
    FileNotFound = 10,
    ValueOverflow = 11,
    AccessDenied = 12,
    UnknownImageFormat = 13,
    FontFamilyNotFound = 14,
    FontStyleNotFound = 15,
    NotTrueTypeFont = 16,
    UnsupportedGdiplusVersion = 17,
    GdiplusNotInitialized = 18,
    PropertyNotFound = 19,
    PropertyNotSupported = 20
  );
  
const
 gdipluserrormessages: array[GpStatus] of string = (
    'Ok',
    'GenericError',
    'InvalidParameter',
    'OutOfMemory',
    'ObjectBusy',
    'InsufficientBuffer',
    'NotImplemented',
    'Win32Error',
    'WrongState',
    'Aborted',
    'FileNotFound',
    'ValueOverflow',
    'AccessDenied',
    'UnknownImageFormat',
    'FontFamilyNotFound',
    'FontStyleNotFound',
    'NotTrueTypeFont',
    'UnsupportedGdiplusVersion',
    'GdiplusNotInitialized',
    'PropertyNotFound',
    'PropertyNotSupported'
 );
type
 egdiplus = class(exception)
  public
   constructor create(const aerror: GpStatus);
 end;
  
  DebugEventLevel = (
   DebugEventLevelFatal,
   DebugEventLevelWarning
  );

 DebugEventProc = procedure(level: DebugEventLevel; 
                                              message: pchar); stdcall;
 GdiplusStartupInput = record
  GdiplusVersion: cUINT32;
  DebugEventCallback: DebugEventProc;
  SuppressBackgroundThread: BOOL;
  SuppressExternalCodecs: BOOL;
 end;
 pGdiplusStartupinput = ^GdiplusStartupinput;
 
 NotificationHookProc = function(token: ppointer): GpStatus; stdcall;
 NotificationUnhookProc = procedure(token: pointer); stdcall;
 
 GdiplusStartupOutput = record
  NotificationHook: NotificationHookProc;
  NotificationUnhook: NotificationUnhookProc;
 end;
 pGdiplusStartupoutput = ^GdiplusStartupoutput;

 GpGraphics = record //opaque
 end;
 PGpGraphics = ^GpGraphics;
 PPGpGraphics = ^PGpGraphics;
 
var
 GdiplusStartup: function(token: ppointer; input: pGdiplusStartupInput;
                          output: pGdiplusStartupOutput): GpStatus; stdcall;
 GdiplusShutdown: function(token: pointer): GpStatus; stdcall;

 GdipCreateFromHDC: function(hdc: HDC;
                 graphics: PPGpGraphics): GpStatus; stdcall;
 GdipDeleteGraphics: function(graphics: PGpGraphics): GpStatus; stdcall;

function initializegdiplus(
                     const sonames: array of filenamety): boolean;
           //false if not available
procedure releasegdiplus;
 
implementation
uses
 msesys,msedynload;
var
 libinfo: dynlibinfoty;
 instance: pointer;

function checkgdipluserror(const aerror: gpstatus): boolean; //true if ok
begin
 result:= aerror = ok;
 if not result then begin
  raise egdiplus.create(aerror);
 end;
end;

procedure initgdiplus;
var
 startupin: gdiplusstartupinput;
// startupout: gdiplusstartupoutput;
begin
 fillchar(startupin,sizeof(startupin),0);
 startupin.gdiplusversion:= 1;
 instance:= nil;
 checkgdipluserror(gdiplusstartup(@instance,@startupin,nil{@startupout}));
end;

procedure deinitgdiplus;
begin
 if instance <> nil then begin
  gdiplusshutdown(instance);
  instance:= nil;
 end;
end;

function initializegdiplus(const sonames: array of filenamety): boolean;
const
 funcs: array[0..3] of funcinfoty = (
  (n: 'GdiplusStartup'; d: @GdiplusStartup),            //0
  (n: 'GdiplusShutdown'; d: @GdiplusShutdown),          //1
  (n: 'GdipCreateFromHDC'; d: @GdipCreateFromHDC),      //2
  (n: 'GdipDeleteGraphics'; d: @GdipDeleteGraphics)     //3
 );
 errormessage = 'Can not load gdi+ library. ';
begin
 result:= initializedynlib(libinfo,sonames,gdipluslib,funcs,[],errormessage,
                                                @initgdiplus,true);
end;

procedure releasegdiplus;
begin
 releasedynlib(libinfo,@deinitgdiplus);
end;

{ egdiplus }

constructor egdiplus.create(const aerror: GpStatus);
var
 str1: string;
begin
 str1:= 'gdi+ error '+inttostr(ord(aerror));
 if aerror <= high(gdipluserrormessages) then begin
  str1:= str1+': '+gdipluserrormessages[aerror];
 end;
 inherited create(str1);
end;

initialization
 initializelibinfo(libinfo);
finalization
 finalizelibinfo(libinfo);
end.
