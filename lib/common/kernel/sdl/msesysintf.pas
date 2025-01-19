{ MSEgui Copyright (c) 1999-2011 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msesysintf;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 msesys,msetypes,msesystypes, msestrings{$ifdef windows},windows{$endif},sdl4msegui, mseguiglob,
 {$ifdef unix}cthreads,cwstring,mselibc, msectypes, baseunix,{$endif}msestream, classes;
 
{$include ..\msesysintf.inc}
{$ifdef windows}
 {$include msesysintfhwin32.inc}
{$endif}

{$ifdef linux}
 {$include msesysintfhlinux.inc}
{$endif}

{$ifdef windows}
function procidfromprochandle(const ahandle: prochandlety): procidty;
{$endif}

implementation
uses
 sysutils,msebits,msesysutils,msefileutils{$ifdef FPC},dateutils{$else},DateUtils{$endif},
 msearrayutils,msesysintf1,msedynload,msedate{$ifdef mse_debugmutex},mseapplication{$endif};

//todo: correct unicode implementation, long filepaths, stubs for win95

{$ifdef windows}
 {$include msesysintfwin32.inc}
{$endif}

{$ifdef linux}
 {$include msesysintflinux.inc}
{$endif}

function sys_gettimeus: longword;
begin
 result:= SDL_GetTicks * 1000;
end;

initialization
{$ifdef FPC}
// winwidestringalloc:= false;
 {$endif}
// initformatsettings;
 doinit;
//iswin95:= true;
//iswin98:= true;
end.
