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
 msestrings,sysutils,classes,mclasses,mseparser;

function rsjgetconsts(const astream: tstream): constinfoarty; 
procedure resourcetexttoresourcesource(const sourcefilename: filenamety;
                             const unitname: string; const fpcformat: boolean);
   //FPC resourcestringtable to resourceunit
implementation
uses
 mseformdatatools,msefileutils,msestream,msesys,typinfo,
 mseclasses,msejson;
 
const
 destfileext = '.pas';
 dataname = 'resourcedata';

procedure rsjarraystart(var adata; const acount: int32);
begin
 setlength(constinfoarty(adata),acount);
end;

procedure rsjarrayitem(var adata; const aindex: int32;
               const avalue: jsonvaluety);
begin
 with constinfoarty(adata)[aindex] do begin
  name:= stringtoutf8ansi(jsonasstring(avalue,['name']));
  value:= jsonasstring(avalue,['value']);
  hash:= jsonasint32(avalue,['hash']);
  valuetype:= vawstring;
 end;
end;

function rsjgetconsts(const astream: tstream): constinfoarty;
var
 json: tjsoncontainer;
begin
 json:= nil;
 try
  try
   json:= tjsoncontainer.create(astream.readdatastring);
   json.iteratearray(['strings'],result,@rsjarraystart,@rsjarrayitem);
  except
   on e: exception do begin
    if astream is tmsefilestream then begin
     e.message:= tmsefilestream(astream).filename+':'+lineend+e.message;
    end;
    raise;
   end;
  end;
 finally
  json.free();
 end;
end;

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
  if fpcformat and (fileext(sourcefilename) = 'rsj') then begin
   ar1:= rsjgetconsts(instream);
  end
  else begin 
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
    str1:= str1 + name + #0 + stringtoutf8ansi(value) + #0;
   end;
  end;
 end;
 outfilename:= filedir(sourcefilename) + msestring(unitname) + destfileext;
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
