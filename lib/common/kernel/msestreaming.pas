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

uses
 {$ifdef FPC}Classes{$else}classes{$endif},msetypes,msegraphutils,mseglob;

type
{$ifdef FPC}
 tasinheritedreader = class;
 tasinheritedobjectreader = class(tbinaryobjectreader)
  protected
   freader: tasinheritedreader;
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

{$else}

 tasinheritedreader = class(treader)
  private
   fnewcomp: boolean;
  protected
   fforceinherited: boolean;
   fexistingcomp: tcomponent;
  public
   constructor Create(Stream: TStream; BufSize: Integer;
                    const forceinherited: boolean);
   procedure readprefix(var flags: tfilerflags; var achildpos: integer); override;
   property existingcomp: tcomponent read fexistingcomp;
   property newcomp: boolean read fnewcomp write fnewcomp);
                                
 end;

{$endif}

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
type
 tcomponent1 = class(tcomponent);
  
{$ifdef FPC} 
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
 if (freader.fexistingcomp = nil) and 
     (stringicompupper(child.name,freader.fexistingcompname) = 0) then begin
  freader.fexistingcomp:= child;
 end;
end;

procedure tasinheritedobjectreader.begincomponent(var flags: tfilerflags;
        var achildpos: Integer; var compclassName, compname: string);
var
 comp1: tcomponent;
begin
 inherited;
 freader.fexistingcomp:= nil;
 if (freader.lookuproot = nil) or freader.fforceinherited then begin
  include(flags,ffinherited);
 end
 else begin
  comp1:= freader.parent;
  freader.fexistingcomp:= nil;
  freader.fexistingcompname:= struppercase(compname);
  while (freader.fexistingcomp = nil) and (comp1 <> nil) do begin
   tcomponent1(freader.parent).getchildren(@findexistingcomponent,comp1);
   if comp1 = freader.root then begin
    break;
   end;
   comp1:= comp1.owner;
  end;
  if freader.fexistingcomp = nil then begin
   freader.fexistingcomp:= freader.lookuproot.findcomponent(compname);
  end;
  exclude(flags,ffinherited);
  if freader.fexistingcomp <> nil then begin
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

{$else}

constructor tasinheritedreader.Create(Stream: TStream; BufSize: Integer;
                    const forceinherited: boolean);
begin
 fforceinherited:= forceinherited;
 inherited create(stream,bufsize);
end;

procedure tasinheritedreader.readprefix(var flags: tfilerflags;
                                              var achildpos: integer);
var
 pos1: integer;
 comp1: tcomponent;
begin
 inherited;
 fexistingcomp:= nil;
 if (lookuproot = nil) or fforceinherited then begin
  include(flags,ffinherited);
 end
 else begin
  pos1:= position;
  readstr; //type
  fexistingcompname:= struppercase(readstr);
  flushbuffer;
  treadercracker(self).fstream.position:= pos1;
  fexistingcomp:= 0;
  comp1:= parent.owner;
  if comp1 = nil then begin
   comp1:= parent;
  end;
  parent.getchildren(@findexisting,comp1);
  exclude(flags,ffinherited);
  if fexistingcomp <> nil then begin
   include(flags,ffinherited);
  end;
 end;
 {
 inherited;
// if findinheritedcomponent(compname,compclassname,self) then begin
 //todo!!!!
 include(flags,ffinherited);
 }
end;

{$endif}

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
