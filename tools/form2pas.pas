{ MSEide Copyright (c) 1999-2006 by Martin Schreiber

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
}
program form2pas;

//convert form files (*.mfm) to pascal files (*_mfm.pas)
//commandline: form2pas FORMFILE[,UNITNAME] ...
//Default UNITNAME is FORMFILE without extension.
//
//'form2pas main.mfm formdesigner.mfm' ->
//convert main.mfm to main_mfm.pas, formdesigner.mfm to formdesigner_mfm.pas

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
{$ifndef FPC}
{$APPTYPE CONSOLE}
{$endif}

uses
 {$ifdef FPC}{$ifdef unix}cthreads,{$endif}{$endif}
  SysUtils,
  msetypes,
  msesysenv,
  msestrings,
  msefileutils,
  msestream,
  msesysutils,
  msesys,
  mseformdatatools;

const
 arguments: array[0..0] of argumentdefty =
      ((kind: ak_arg; name: ''; anames: nil; flags: []; initvalue: ''));

var
 sysenv: tsysenvmanager;
 ar1,ar2: msestringarty;
 int1: integer;
 formname,formclass,unitname: string;
 stream: ttextstream;
begin
 sysenv:= tsysenvmanager.create(nil);
 sysenv.init(arguments);
 ar1:= sysenv.values[0];
 try
  for int1:= 0 to high(ar1) do begin
   if ar1[int1] <> '' then begin
    {$ifdef msefp}
    setlength(ar2,0); //ar2:= nil -> av!
    {$else}
    ar2:= nil;
    {$endif}
    splitstring(ar1[int1],ar2,widechar(','));
    if (length(ar2) < 1) or (length(ar2)>2) then begin
     errorhalt('Invalid parameter: '+ar1[int1]);
    end;
    if length(ar2) > 1 then begin
     unitname:= ar2[1];
    end
    else begin
     unitname:= removefileext(filename(ar2[0]));
    end;
    stream:= ttextstream.Create(ar2[0],fm_read);
    try
     getobjforminfo(stream,formname,formclass);
    finally
     stream.free;
    end;
    writestdout(
    'Converting file "'+ar2[0]+'" class "'+formclass+'" unit "'+unitname+'"''.',true);
    formtexttoobjsource(ar2[0],formclass,unitname);
   end;
  end;
 except
  on e: exception do begin
   errorhalt(e.message);
  end;
 end;
end.
