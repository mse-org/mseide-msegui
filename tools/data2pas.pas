{ MSEide Copyright (c) 2017 by Martin Schreiber

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
program data2pas;

// commandline: data2pas -oDESTFILE SOURCEFILE
// 'data2pas -odata.pas data.bin
// -> dataunit for data.bin

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
{$ifndef FPC}
{$APPTYPE CONSOLE}
{$endif}

uses
  {$ifdef FPC}{$ifdef unix}cthreads,{$endif}{$endif}
  SysUtils,msesys,msesysutils,
  msetypes,
  msesysenv,
  msestrings,
  msefileutils,
  mseformdatatools,msestream;

type
 argty = (arg_dest,arg_names);

const
 arguments: array[argty] of argumentdefty =
      ((kind: ak_pararg; name: 'o'; anames: nil; flags: [arf_mandatory];
                                                              initvalue: ''),
       (kind: ak_arg; name: ''; anames: nil; flags: []; initvalue: '')
      );

var
 sysenv: tsysenvmanager;
 s1,s2: msestring;
 source1: tmsefilestream;
 dest1: ttextstream;
 dir1,file1,ext1: filenamety;
begin
 source1:= nil;
 dest1:= nil;
 sysenv:= tsysenvmanager.create(nil);
 try
  if sysenv.init(arguments) then begin
   s1:= sysenv.value[ord(arg_dest)];
   s2:= sysenv.value[ord(arg_names)];
   splitfilepath(s1,dir1,file1,ext1);
   if ext1 = '' then begin
    ext1:= '.pas';
   end;
   s1:= filepath(dir1,file1+ext1);
   dest1:= ttextstream.create(s1,fm_create);
   source1:= tmsefilestream.create(s2,fm_read);
   datatoobjsource(source1,dest1,file1);
  end;
 finally
  sysenv.destroy();
  source1.free();
  dest1.free();
 end;
end.
