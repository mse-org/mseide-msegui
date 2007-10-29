{ MSEgui Copyright (c) 1999-2007 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msestreaming;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface

uses
 {$ifdef FPC}Classes{$else}classes{$endif},msetypes,msegraphutils;

function readrealty(const reader: treader): realty;
procedure writerealty(const writer: twriter; const value: realty);
function readrectty(const reader: treader): rectty;
procedure writerectty(const writer: twriter; const avalue: rectty);

function readrecordcount(const obj: tpersistent;
    const recordsize: integer; const stream: tstream): integer;
       //erzeugt exception bei ungueltiger laenge;
procedure readrecords(const count,size: integer; const stream: tstream; out data);
procedure writerecords(const count,size: integer; const stream: tstream; const data);

procedure assignpersistent(source,dest: tpersistent);
         //uebertraegt alle published eigenschaften
procedure assigncomponent(source,dest: tcomponent);
         //uebertraegt alle published eigenschaften


implementation
uses
 sysutils,msereal;
 
type
 treader1 = class(treader);
 twriter1 = class(twriter);

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
// stream.ReadBuffer(result,sizeof(result));
end;

procedure writerealty(const writer: twriter; const value: realty);
begin
 with writer do begin
  if isemptyreal(value) then begin
   writelistbegin;
   writefloat(0.0);
   writeboolean(true);
   writelistend;
  end
  else begin
   writefloat(value);
  end;
 end;
// stream.WriteBuffer(value,sizeof(value));
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
 writer: twriter;
 reader: treader;
 stream: tmemorystream;
begin
 writer:= nil;
 reader:= nil;
 stream:= tmemorystream.Create;
 try
  writer:= twriter.Create(stream,1024);
  writer.WriteListBegin;
  twriter1(writer).WriteProperties(source);
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
 stream: tmemorystream;
begin
 stream:= tmemorystream.Create;
 try
  stream.WriteComponent(source);
  stream.Position:= 0;
  stream.ReadComponent(dest);
 finally
  stream.Free;
 end;
end;
end.
