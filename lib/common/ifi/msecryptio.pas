{ MSEgui Copyright (c) 2007 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msecryptio;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 mseclasses,sysutils;
 
type
 
 ecryptio = class(exception)
 end;

 tcryptio = class; 
 cryptioclassty = class of tcryptio;
 
 cryptioinfoty = record
  handler: tcryptio;
  classtype: cryptioclassty;
  rxfd: integer;
  txfd: integer;
  cryptdata: array[0..15] of pointer;
 end;
 pcryptioinfoty = ^cryptioinfoty;

 connectionkiundty = (cok_server,cok_client); 
 
 tcryptio = class(tmsecomponent)
  protected
   class procedure internalunlink(var ainfo: cryptioinfoty); virtual;
   class procedure internalthreadterminate; virtual;
   procedure connect(var ainfo: cryptioinfoty; 
                          const atimeoutms: integer);  virtual; abstract;
   procedure accept(var ainfo: cryptioinfoty; 
                          const atimeoutms: integer);  virtual; abstract;
   function write(var ainfo: cryptioinfoty; const buffer: pointer; 
                  const count: integer; 
                  const atimeoutms: integer): integer; virtual; abstract;
   function read(var ainfo: cryptioinfoty; const buffer: pointer;
                  const count: integer; 
                  const atimeoutms: integer): integer; virtual; abstract;
                    //atimeoutms < 0 -> nonblocked
 public
   procedure link(const atxfd,arxfd: integer; 
                          out ainfo: cryptioinfoty); virtual;
   class procedure unlink(var ainfo: cryptioinfoty);
   class procedure threadterminate(var ainfo: cryptioinfoty);
 end;

procedure cryptconnect(var ainfo: cryptioinfoty; const atimeoutms: integer);
procedure cryptaccept(var ainfo: cryptioinfoty; const atimeoutms: integer);
function cryptwrite(var ainfo: cryptioinfoty; const buffer: pointer;
                    const count: integer; const atimeoutms: integer): integer;
function cryptread(var ainfo: cryptioinfoty; const buffer: pointer;
                    const count: integer; const atimeoutms: integer): integer;
                    //atimeoutms < 0 -> nonblocked

implementation
uses
 msesys;
 
procedure cryptconnect(var ainfo: cryptioinfoty; const atimeoutms: integer);
begin
 ainfo.handler.connect(ainfo,atimeoutms);
end;

procedure cryptaccept(var ainfo: cryptioinfoty; const atimeoutms: integer);
begin
 ainfo.handler.accept(ainfo,atimeoutms);
end;

function cryptwrite(var ainfo: cryptioinfoty; const buffer: pointer;
                 const count: integer; const atimeoutms: integer): integer;
begin
 result:= ainfo.handler.write(ainfo,buffer,count,atimeoutms);
end;

function cryptread(var ainfo: cryptioinfoty; const buffer: pointer;
           const count: integer; const atimeoutms: integer): integer;
begin
 result:= ainfo.handler.read(ainfo,buffer,count,atimeoutms);
end;

{ tcryptio }

class procedure tcryptio.internalunlink(var ainfo: cryptioinfoty);
begin
 with ainfo do begin
  handler:= nil;
  classtype:= nil;
  txfd:= invalidfilehandle;
  rxfd:= invalidfilehandle;
 end;
end;

class procedure tcryptio.internalthreadterminate;
begin
 //dummy
end;

class procedure tcryptio.unlink(var ainfo: cryptioinfoty);
begin
 if ainfo.classtype <> nil then begin
  ainfo.classtype.internalunlink(ainfo);
 end;
end;

class procedure tcryptio.threadterminate(var ainfo: cryptioinfoty);
begin
 if ainfo.classtype <> nil then begin
  ainfo.classtype.internalthreadterminate;
 end;
end;

procedure tcryptio.link(const atxfd,arxfd: integer; 
                          out ainfo: cryptioinfoty);
begin
 ainfo.handler:= self;
 ainfo.classtype:= cryptioclassty(classtype);
 ainfo.rxfd:= arxfd;
 ainfo.txfd:= atxfd;
end;
end.
