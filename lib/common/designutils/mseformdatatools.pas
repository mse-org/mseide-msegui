{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseformdatatools;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 msetypes,msestrings,msestream,Classes,mseclasses;
type
 objformatty = (of_default,of_delphi,of_fp);

procedure componentstoobjsource(components: componentarty;
                outfilename: filenamety;
                   usesnames: string; //',' between names: 'unit1,unit2'
                 unitname: string = ''; objformat: objformatty = of_default);

procedure formtexttoobjsource(sourcefilename: filenamety;
                            formclass: string = '';
                            unitname: string = ''; 
                            objformat: objformatty = of_default;
                            langmodule: boolean = false);
   //converts objecttext to linkdata,
   //if formclass = '' -> extracted from sourcefile,
   //if unitname = '' -> unitname = filename

procedure getobjforminfo(instream: ttextstream; var formname,formclass: string);
                    //!!!!todo var -> out (fpcbug 3221)
procedure createlanglib(const libfilename: filenamety;
                 const langmodules,resourcemodules: stringarty);
procedure writeconstdata(po1: pbyte; length: integer; const dataname: string;
             const outstream: ttextstream);

implementation
uses
 msefileutils,sysutils,msesys;
const
 formdataext = '_mfm';
 objdataname = 'objdata';
 
procedure createlanglib(const libfilename: filenamety;
           const langmodules,resourcemodules: stringarty);
var
 outstream: ttextstream;
 str1: string;
 int1: integer;
begin
 outstream:= ttextstream.create(libfilename,fm_create);
 try
  outstream.writeln('library ' + filenamebase(libfilename) + ';');
  outstream.writeln(compilerdefaults);
  outstream.writeln('uses');
  str1:= ' mselanglink';
  for int1:= 0 to high(langmodules) do begin
   str1:= str1 + ',' + langmodules[int1]+formdataext;
  end;
  for int1:= 0 to high(resourcemodules) do begin
   str1:= str1 + ',' + resourcemodules[int1];
  end;
  outstream.writeln(str1+';');
  outstream.writeln('exports');
  outstream.writeln(' registerlang,unregisterlang;');
  outstream.writeln('end.');
 finally
  outstream.free;
 end;
end;

var
 format: objformatty;

procedure getobjforminfo(instream: ttextstream; var formname,formclass: string);
var
 str1: string;
 ar1: stringarty;
 posbefore: cardinal;
begin
 posbefore:= instream.position;
 instream.readln(str1);
 instream.position:= posbefore;
 splitstring(str1,ar1,' ',true);
 if (length(ar1) <> 3) or (ar1[0] <> 'object') or
           (ar1[1][length(ar1[1])] <> ':') then begin
  raise exception.Create('Invalid format: "'+str1+'".');
 end;
 formname:= copy(ar1[1],1,length(ar1[1])-1);
 formclass:= ar1[2];
end;

function getbytestring(var data: pbyte; var count: integer): string;
var
 int1: integer;
 strings: stringarty;
begin
 int1:= count;
 if int1 > 20 then begin
  int1:= 20;
 end;
 dec(count,int1);
 setlength(strings,int1);
 for int1:= 0 to int1 - 1 do begin
  strings[int1]:= inttostr(data^);
  inc(data);
 end;
 result:= concatstrings(strings,',');
end;

function getnameext(name: string): string;
begin
 if name = '' then begin
  result:= ''
 end
 else begin
  result:= '_'+name;
 end;
end;

procedure writeconstdata(po1: pbyte; length: integer; const dataname: string;
             const outstream: ttextstream);
begin
 outstream.writeln('const');
 outstream.writeln(' '+dataname+': record size: integer; data: array[0..'+
  inttostr(length-1)+'] of byte end =');
 outstream.writeln('      (size: '+inttostr(length)+'; data: (');
 while length > 0 do begin
  outstream.write('  '+getbytestring(po1,length));
  if length > 0 then begin
   outstream.writeln(',');
  end;
 end;
 outstream.writeln(')');
 outstream.writeln(' );');
 outstream.writeln('');
end;

procedure writeobjdata(datastream: tmemorystream; outstream: ttextstream;
               name: string; objformat: objformatty);
var
 int1: integer;
 po1: pbyte;
 str1: string;
begin
 int1:= datastream.Size;
 po1:= datastream.Memory;
 str1:= getnameext(name);
 writeconstdata(po1,int1,objdataname+getnameext(name),outstream);
end;

procedure writeobjregister(outstream: ttextstream; aclass,name: string);
begin
 outstream.writeln(' registerobjectdata(@'+objdataname+getnameext(name)+','+aclass+
      ','''+name+''');');
end;

procedure componentstoobjsource(components: componentarty;
                outfilename: filenamety; usesnames: string;
                unitname: string = ''; objformat: objformatty = of_default);
var
 outstream: ttextstream;
 memstream: tmemorystream;
 int1: integer;
 str1: string;
begin
 if objformat = of_default then begin
  objformat:= format;
 end;
 if unitname = '' then begin
  unitname:= removefileext(filename(outfilename));
 end;
 outstream:= ttextstream.Create(outfilename,fm_create);
 try
  outstream.writeln('unit ' + unitname + ';');
  outstream.writeln(compilerdefaults);
  outstream.writeln('');
  outstream.writeln('interface');
  outstream.writeln('');
  outstream.writeln('implementation');
  outstream.writeln('uses');
  if usesnames <> '' then begin
   str1:= ',' + usesnames;
  end
  else begin
   str1:= '';
  end;
  outstream.writeln(' mseclasses'+str1+';');
  outstream.writeln('');
  for int1:= 0 to high(components) do begin
   memstream:= tmemorystream.Create;
   try
    memstream.WriteComponent(components[int1]);
    writeobjdata(memstream,outstream,components[int1].Name,objformat)
   finally
    memstream.Free;
   end;
  end;
  outstream.writeln('initialization');
  for int1:= 0 to high(components) do begin
   with components[int1] do begin
    writeobjregister(outstream,classname,name);
   end;
  end;
  outstream.writeln('end.');
 finally
  outstream.Free;
 end;
end;

procedure formtexttoobjsource(sourcefilename: filenamety;
                                  formclass: string = '';
                                  unitname: string = '';
                                  objformat: objformatty = of_default;
                                  langmodule: boolean = false);
   //converts objectext to linkdata
var
 instream: ttextstream;
 outstream: ttextstream;
 memstream: tmemorystream;
 outname: string;
 str1: string;

begin
 if objformat = of_default then begin
  objformat:= format;
 end;
 instream:= ttextstream.create(sourcefilename,fm_read);
 try
  if formclass = '' then begin
   getobjforminfo(instream,str1,formclass);
   instream.position:= 0;
  end;
  if unitname = '' then begin
   unitname:= removefileext(filename(sourcefilename));
  end;
  outname:= removefileext(sourcefilename) + formdataext;
  memstream:= tmemorystream.Create;
  try
   objecttexttobinary(instream,memstream);
   outstream:= ttextstream.Create(outname+'.pas',fm_create);
   try
    outstream.writeln('unit ' + unitname + formdataext+';');
    outstream.writeln(compilerdefaults);
    outstream.writeln('');
    outstream.writeln('interface');
    outstream.writeln('');
    outstream.writeln('implementation');
    outstream.writeln('uses');
    if langmodule then begin
     outstream.writeln(' msei18nglob,mselanglink;');
     outstream.writeln('');
     writeobjdata(memstream,outstream,'',objformat);
     outstream.writeln('var');
     outstream.writeln(' hookbefore: registermodulehookty;');
     outstream.writeln('');
     outstream.writeln(
 'procedure registermodule(const registermoduleproc: registermodulety);');
     outstream.writeln('begin');
     outstream.writeln(
  ' registermoduleproc(@'+objdataname+','''+formclass+''','''');');
     outstream.writeln(' registermodulehook:= hookbefore;');
     outstream.writeln('end;');
     outstream.writeln('');
     outstream.writeln('initialization');
     outstream.writeln(' hookbefore:= registermodulehook;');
     outstream.writeln(' registermodulehook:= @registermodule;');
    end
    else begin
     outstream.writeln(' mseclasses,'+unitname+';');
     outstream.writeln('');
     writeobjdata(memstream,outstream,'',objformat);
     outstream.writeln('initialization');
     writeobjregister(outstream,formclass,'');
    end;
    outstream.writeln('end.');
   finally
    outstream.Free;
   end;
  finally
   memstream.Free;
  end;
 finally
  instream.Free;
 end;
end;

initialization
{$ifdef FPC}
 format:= of_fp;
{$else}
 format:= of_delphi;
{$endif}
end.
