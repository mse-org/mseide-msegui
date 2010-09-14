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
program bmp2pas;

// commandline: bmp2pas -oDESTFILE BITMAPFILE ...
// 'bmp2pas -oregcomps_bmp.pas tcomp1.bmp tcomp2.bmp tcomp3.bmp'
// -> bitmapunit for tcomp1,tcomp2,tcomp3

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
{$ifndef FPC}
{$APPTYPE CONSOLE}
{$endif}

uses
  {$ifdef FPC}{$ifdef linux}cthreads,{$endif}{$endif}
  SysUtils,
  msetypes,
  msesysenv,
  msestrings,
  msefileutils,
  msesysutils,
  msebitmap,
  mseclasses,
  mseformdatatools,mseguiintf,
  mseformatpngread,mseformatbmpicoread,
  msegraphutils;

type
 argty = (arg_dest,arg_names);

const
 arguments: array[argty] of argumentdefty =
      ((kind: ak_pararg; name: 'o'; anames: nil; flags: []; initvalue: ''),
       (kind: ak_arg; name: ''; anames: nil; flags: []; initvalue: '')
      );

var
 sysenv: tsysenvmanager;
 ar1,ar2: msestringarty;
 int1: integer;
 bmps: array of tbitmapcomp;
 str1,str2: msestring;

begin
 gui_init; //pixmap needed
 try
  sysenv:= tsysenvmanager.create(nil);
  sysenv.init(arguments);
  str1:= sysenv.value[ord(arg_dest)];
  ar1:= sysenv.values[ord(arg_names)];
  try
   setlength(bmps,length(ar1));
   try
    for int1:= 0 to high(ar1) do begin
     if ar1[int1] <> '' then begin
      bmps[int1]:= tbitmapcomp.create(nil);
      ar2:= nil;
      splitstring(ar1[int1],ar2,widechar(','));
      if (length(ar2) < 1) or (length(ar2)>2) then begin
       errorhalt('Invalid parameter: '+ar1[int1]);
      end;
      if length(ar2) > 1 then begin
       bmps[int1].name:= ar2[1];
      end
      else begin
       bmps[int1].name:= removefileext(filename(ar2[0]));
      end;
      writestdout(
      'Converting file "'+ar2[0]+'" componentname "'+bmps[int1].name+'".',true);
      with bmps[int1].bitmap do begin
       loadfromfile(ar2[0]);
       if fileext(ar2[0]) = 'png' then begin
        transparentcolor:= cl_none;
        colormask:= true;
        masked:= true;
       end;
      end;
     end;
    end;
    str2:= removefileext(filename(str1));
    writestdout(
      'Write unitfile "'+str1+'".',true);
    componentstoobjsource(componentarty(bmps),str1,'msebitmap',str2);
   finally
    for int1:= 0 to high(bmps) do begin
     bmps[int1].Free;
    end;
   end;
  except
   on e: exception do begin
    errorhalt(e.message);
   end;
  end;
 finally
//  gui_deinit; stockdata finalize needs GDI
 end;
end.
