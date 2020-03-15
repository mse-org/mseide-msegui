{ MSEgui Copyright (c) 1999-2012 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msestreaming;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}

uses
 classes,mclasses,msetypes,msegraphutils,mseglob;

type
 tasinheritedreader = class;
 tasinheritedobjectreader = class(tbinaryobjectreader)
  protected
//   freader: tasinheritedreader;
   procedure findexistingcomponent(child: tcomponent);
  public
   procedure begincomponent(var flags: tfilerflags; var achildpos: integer;
      var compclassname, compname: string); override;
  public
   constructor create(const areader: tasinheritedreader; const stream: tstream;
                                                       const bufsize: integer);
 end;

 tasinheritedreader = class(treader)
  private
   fnewcomp: boolean;
  protected
   fforceinherited: boolean;
   fexistingcomp: tcomponent;
   fexistingcompname: string;
   function createdriver(stream: tstream;
                 bufsize: integer): tabstractobjectreader; override;
  public
   constructor Create(Stream: TStream; BufSize: Integer;
                    const forceinherited: boolean);
   property existingcomp: tcomponent read fexistingcomp;
   property newcomp: boolean read fnewcomp write fnewcomp;
 end;

function readshortcutarty(const reader: treader): shortcutarty;
procedure writeshortcutarty(const writer: twriter; const avalue: shortcutarty);
function readrealty(const reader: treader): realty;
//procedure writerealty(const writer: twriter; const value: realty);
function readrectty(const reader: treader): rectty;
procedure writerectty(const writer: twriter; const avalue: rectty);
function readmethod(const reader: treader): tmethod;

function readrecordcount(const obj: tpersistent;
    const recordsize: integer; const stream: tstream): integer;
       //erzeugt exception bei ungueltiger laenge;
procedure readrecords(const count,size: integer; const stream: tstream; out data);
procedure writerecords(const count,size: integer; const stream: tstream; const data);

procedure assignpersistent(source,dest: tpersistent);
         //uebertraegt alle published eigenschaften
procedure assigncomponent(source,dest: tcomponent);
         //uebertraegt alle published eigenschaften
procedure writecomponentmse(const astream: tstream; const acomp: tcomponent);

implementation
uses
 sysutils,msereal,mseact,mseclasses,msestrings;
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}
type
 tcomponent1 = class(tcomponent);

{
function findexistingcomponent(const aname: string;
                  const aclassname: string;
                        const areader: tasinheritedreader): boolean;
var
 comp1: tcomponent;
 ar1: componentarty;
 int1: integer;
begin
 areader.fexistingcomp:= nil;
 comp1:= areader.parent;
 if comp1 = nil then begin
  comp1:= areader.lookuproot;
 end;
 if comp1 <> nil then begin
  ar1:= getcomponentchildren(comp1,areader.root,true);
  for int1:= 0 to high(ar1) do begin
   if (ar1[int1].name = aname) and (ar1[int1].classname = aclassname) then begin
    areader.fexistingcomp:= ar1[int1];
    break;
   end;
  end;
 end;
 result:= areader.fexistingcomp <> nil;
// result:= (areader.lookuproot = nil) or
//            (areader.lookuproot.findcomponent(aname) <> nil);
end;
}

{ tasinheritedobjectreader }

constructor tasinheritedobjectreader.create(const areader: tasinheritedreader;
                           const stream: tstream; const bufsize: integer);
begin
 freader:= areader;
 inherited create(stream,bufsize);
end;

procedure tasinheritedobjectreader.findexistingcomponent(child: tcomponent);
begin
 if (tasinheritedreader(freader).fexistingcomp = nil) and
     (stringicompupper(child.name,
              tasinheritedreader(freader).fexistingcompname) = 0) then begin
  tasinheritedreader(freader).fexistingcomp:= child;
 end;
end;

procedure tasinheritedobjectreader.begincomponent(var flags: tfilerflags;
        var achildpos: Integer; var compclassName, compname: string);
var
 comp1: tcomponent;
begin
 inherited;
 tasinheritedreader(freader).fexistingcomp:= nil;
 if (tasinheritedreader(freader).lookuproot = nil) or
          tasinheritedreader(freader).fforceinherited then begin
  include(flags,ffinherited);
 end
 else begin
  comp1:= freader.parent;
  tasinheritedreader(freader).fexistingcomp:= nil;
  tasinheritedreader(freader).fexistingcompname:= struppercase(compname);
  while (tasinheritedreader(freader).fexistingcomp = nil) and (comp1 <> nil) do begin
   tcomponent1(freader.parent).getchildren(
                      {$ifdef FPC}@{$endif}findexistingcomponent,comp1);
   if comp1 = freader.root then begin
    break;
   end;
   comp1:= comp1.owner;
  end;
  if tasinheritedreader(freader).fexistingcomp = nil then begin
   tasinheritedreader(freader).fexistingcomp:= freader.lookuproot.findcomponent(compname);
  end;
  exclude(flags,ffinherited);
  if tasinheritedreader(freader).fexistingcomp <> nil then begin
   include(flags,ffinherited);
  end;
 end;
end;

{ tasinheritedreader }

constructor tasinheritedreader.Create(Stream: TStream; BufSize: Integer;
                    const forceinherited: boolean);
begin
 fforceinherited:= forceinherited;
 inherited create(stream,bufsize);
end;

function tasinheritedreader.createdriver(stream: tstream;
                   bufsize: integer): tabstractobjectreader;
begin
 result:= tasinheritedobjectreader.create(self,stream, bufsize);
end;

type
 treader1 = class(treader);
 twriter1 = class(twriter);

procedure writecomponentmse(const astream: tstream; const acomp: tcomponent);
var
 writer1: twritermse;
begin
 writer1:= twritermse.create(astream,4096,false);
 try
  writer1.writerootcomponent(acomp);
 finally
  writer1.free;
 end;
end;

function readshortcutarty(const reader: treader): shortcutarty;
var
 int1: integer;
begin
 reader.readlistbegin;
 setlength(result,reader.readinteger);
 for int1:= 0 to high(result) do begin
  result[int1]:= reader.readinteger;
  translateshortcut1(result[int1]);
 end;
 reader.readlistend;
end;

procedure writeshortcutarty(const writer: twriter; const avalue: shortcutarty);
var
 int1: integer;
begin
 writer.writelistbegin;
 writer.writeinteger(length(avalue));
 for int1:= 0 to high(avalue) do begin
  writer.writeinteger(avalue[int1]);
 end;
 writer.writelistend;
end;

function readrealty(const reader: treader): realty;
begin
 with reader do begin
  if nextvalue = valist then begin
   readlistbegin;
   result:= readfloat;
   if readboolean then begin
    result:= emptyreal;
   end;
   readlistend;
  end
  else begin
   result:= readfloat;
  end;
 end;
end;

procedure writerealty(const writer: twriter; const value: realty);
begin
 with writer do begin
  if value = emptyreal then begin
   writelistbegin;
   writefloat(0.0);
   writeboolean(true);
   writelistend;
  end
  else begin
   writefloat(value);
  end;
 end;
end;

function readrectty(const reader: treader): rectty;
begin
 with reader,result do begin
  readlistbegin;
  x:= readinteger;
  y:= readinteger;
  cx:= readinteger;
  cy:= readinteger;
  readlistend;
 end;
end;

procedure writerectty(const writer: twriter; const avalue: rectty);
begin
 with writer,avalue do begin
  writelistbegin;
  writeinteger(x);
  writeinteger(y);
  writeinteger(cx);
  writeinteger(cy);
  writelistend;
 end;
end;

function readmethod(const reader: treader): tmethod;
var
 str1: string;
begin
 with treader1(reader) do begin
  if nextvalue = vanil then begin
   result.code:= nil;
   result.data:= nil;
   readident;
  end
  else begin
   str1:= readident;
   result.code:= findmethod(root,str1);
   result.data:= root;
  end;
 end;
end;

function readrecordcount(const obj: tpersistent;
    const recordsize: integer; const stream: tstream): integer;
       //erzeugt exception bei ungueltiger laenge;
var
 bytecount: longint;
begin
 stream.ReadBuffer(bytecount,sizeof(bytecount));
 if bytecount mod recordsize <> 0 then begin
  raise ereaderror.Create(obj.GetNamePath+' readrecorderror.');
 end;
 result:= bytecount div recordsize;
end;

procedure readrecords(const count,size: integer; const stream: tstream; out data);
begin
 stream.ReadBuffer(data,count*size);
end;

procedure writerecords(const count,size: integer; const stream: tstream; const data);
var
 bytecount: longint;
begin
 bytecount:= count*size;
 stream.WriteBuffer(bytecount,sizeof(bytecount));
 stream.WriteBuffer(data,bytecount);
end;

procedure assignpersistent(source,dest: tpersistent);
var
 writer: twritermse;
 reader: treader;
 stream: tmemorystream;
begin
 writer:= nil;
 reader:= nil;
 stream:= tmemorystream.Create;
 try
  writer:= twritermse.Create(stream,1024,false);
  writer.WriteListBegin;
{$warnings off}
  twriter1(writer).WriteProperties(source);
{$warnings on}
  writer.WriteListEnd;
  freeandnil(writer);
  stream.Position:= 0;
  reader:= treader.Create(stream,1024);
  reader.ReadListBegin;
  while not reader.endoflist do begin
   treader1(reader).Readproperty(dest);
  end;
 finally
  reader.free;
  writer.free;
  stream.Free;
 end;
end;

procedure assigncomponent(source,dest: tcomponent);
var
 stream1: tmemorystream;
begin
 stream1:= tmemorystream.Create;
 try
  writecomponentmse(stream1,source);
  stream1.Position:= 0;
  stream1.ReadComponent(dest);
 finally
  stream1.Free;
 end;
end;
end.
