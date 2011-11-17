{ MSEgui Copyright (c) 2004-2008 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseresourcetools;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 msestrings,sysutils;
 
procedure resourcetexttoresourcesource(const sourcefilename: filenamety;
                             const unitname: string; const fpcformat: boolean);
   //FPC resourcestringtable to resourceunit
implementation
uses
 classes,mseformdatatools,msefileutils,mseparser,msestream,msesys,typinfo,
 mseclasses;
 
const
 destfileext = '.pas';
 dataname = 'resourcedata';

procedure resourcetexttoresourcesource(const sourcefilename: filenamety;
                             const unitname: string; const fpcformat: boolean);
var
 instream: ttextstream;
 outstream: ttextstream;
 outfilename: filenamety;
// mstr1: msestring;
 scanner: tscanner;
 parser: tparser;
 ar1: constinfoarty;
 int1: integer;
 int2: integer;
 str1: string;
// po1: pbyte;
begin
 instream:= ttextstream.create(sourcefilename,fm_read);
 try
  scanner:= nil;
  parser:= nil;
  try
   scanner:= tpascalscanner.Create;
   scanner.source:= instream.readdatastring;
   if fpcformat then begin
    parser:= tfpcresstringparser.create(nil);
   end
   else begin
    parser:= tresstringlistparser.Create(nil);
   end;
   parser.scanner:= scanner;
   if fpcformat then begin
    tfpcresstringparser(parser).getconsts(ar1);
   end
   else begin
    tresstringlistparser(parser).getconsts(ar1);
   end;
  finally
   parser.free;
   scanner.free;
  end;
 finally
  instream.free;
 end;
 str1:= '';
 for int1:= 0 to high(ar1) do begin
  with ar1[int1] do begin
   if valuetype = vawstring then begin
    if not fpcformat then begin
     for int2:= 1 to length(name) do begin
      if name[int1] = '_' then begin
       name[int1]:= '.';
       break;
      end;
     end;
    end;
    str1:= str1 + name + #0 + stringtoutf8(value) + #0;
   end;
  end;
 end;
 outfilename:= filedir(sourcefilename) + unitname + destfileext;
 outstream:= ttextstream.create(outfilename,fm_create);
 try
  outstream.writeln('unit ' + unitname + ';');
  outstream.writeln(compilerdefaults);
  outstream.writeln('');
  outstream.writeln('interface');
  outstream.writeln('');
  outstream.writeln('implementation');
  outstream.writeln('uses');
  outstream.writeln(' msei18nglob,mselanglink;');
  writeconstdata(pbyte(pchar(str1)),length(str1),dataname,outstream);
     outstream.writeln('var');
     outstream.writeln(' hookbefore: registerresourcehookty;');
     outstream.writeln('');
     outstream.writeln(
 'procedure registerresource(const registerresourceproc: registerresourcety);');
     outstream.writeln('begin');
     outstream.writeln(
  ' registerresourceproc(@'+dataname+');');
     outstream.writeln(' registerresourcehook:= hookbefore;');
     outstream.writeln('end;');
     outstream.writeln('');
     outstream.writeln('initialization');
     outstream.writeln(' hookbefore:= registerresourcehook;');
     outstream.writeln(' registerresourcehook:= @registerresource;');
  outstream.writeln('end.');
 finally
  outstream.free;
 end;
end;
 
end.
