{ MSEgui Copyright (c) 2007 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msecryptio;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseclasses,sysutils;
 
type
 
 ecryptio = class(exception)
 end;

 tcryptio = class; 
 cryptioclassty = class of tcryptio;
 cryptiokindty = (cyk_none,cyk_server,cyk_client);

 cryptdataty = array[0..17] of pointer;  
 cryptioinfoty = record
//  handler: tcryptio;
  kind: cryptiokindty;
  classtype: cryptioclassty;
  rxfd: integer;
  txfd: integer;
  cryptdata: cryptdataty;
 end;
 pcryptioinfoty = ^cryptioinfoty;

 connectionkindty = (cok_server,cok_client); 
 
 tcryptio = class(tmsecomponent)
  protected
   class procedure internalunlink(var ainfo: cryptioinfoty); virtual;
   class procedure internalthreadterminate; virtual;
   class procedure connect(var ainfo: cryptioinfoty; 
                          const atimeoutms: integer);  virtual; abstract;
   class procedure accept(var ainfo: cryptioinfoty; 
                          const atimeoutms: integer);  virtual; abstract;
   class function write(var ainfo: cryptioinfoty; const buffer: pointer; 
                  const count: integer; 
                  const atimeoutms: integer): integer; virtual; abstract;
   class function read(var ainfo: cryptioinfoty; const buffer: pointer;
                  const count: integer; 
                  const atimeoutms: integer): integer; virtual; abstract;
                    //atimeoutms < 0 -> nonblocked
 public
   procedure link(const atxfd,arxfd: integer; 
                          out ainfo: cryptioinfoty); virtual;
   {
   class procedure unlink(var ainfo: cryptioinfoty);
   class procedure threadterminate(var ainfo: cryptioinfoty);
   }
 end;

procedure cryptconnect(var ainfo: cryptioinfoty; const atimeoutms: integer);
procedure cryptaccept(var ainfo: cryptioinfoty; const atimeoutms: integer);
function cryptwrite(var ainfo: cryptioinfoty; const buffer: pointer;
                    const count: integer; const atimeoutms: integer): integer;
function cryptread(var ainfo: cryptioinfoty; const buffer: pointer;
                    const count: integer; const atimeoutms: integer): integer;
                    //atimeoutms < 0 -> nonblocked
procedure cryptunlink(var ainfo: cryptioinfoty);
procedure cryptthreadterminate(var ainfo: cryptioinfoty);

implementation
uses
 msesystypes;
 
procedure cryptconnect(var ainfo: cryptioinfoty; const atimeoutms: integer);
begin
 if ainfo.classtype <> nil then begin
  ainfo.classtype.connect(ainfo,atimeoutms);
 end;
end;

procedure cryptaccept(var ainfo: cryptioinfoty; const atimeoutms: integer);
begin
 if ainfo.classtype <> nil then begin
  ainfo.classtype.accept(ainfo,atimeoutms);
 end;
end;

function cryptwrite(var ainfo: cryptioinfoty; const buffer: pointer;
                 const count: integer; const atimeoutms: integer): integer;
begin
 if ainfo.classtype <> nil then begin
  result:= ainfo.classtype.write(ainfo,buffer,count,atimeoutms);
 end;
end;

function cryptread(var ainfo: cryptioinfoty; const buffer: pointer;
           const count: integer; const atimeoutms: integer): integer;
begin
 if ainfo.classtype <> nil then begin
  result:= ainfo.classtype.read(ainfo,buffer,count,atimeoutms);
 end;
end;

procedure cryptunlink(var ainfo: cryptioinfoty);
begin
 if ainfo.classtype <> nil then begin
  ainfo.classtype.internalunlink(ainfo);
 end;
end;

procedure cryptthreadterminate(var ainfo: cryptioinfoty);
begin
 if ainfo.classtype <> nil then begin
  ainfo.classtype.internalthreadterminate;
 end;
end;

{ tcryptio }

class procedure tcryptio.internalunlink(var ainfo: cryptioinfoty);
begin
 with ainfo do begin
//  handler:= nil;
  classtype:= nil;
  txfd:= invalidfilehandle;
  rxfd:= invalidfilehandle;
 end;
end;

class procedure tcryptio.internalthreadterminate;
begin
 //dummy
end;

procedure tcryptio.link(const atxfd,arxfd: integer; 
                          out ainfo: cryptioinfoty);
begin
// ainfo.handler:= self;
 ainfo.classtype:= cryptioclassty(classtype);
 ainfo.rxfd:= arxfd;
 ainfo.txfd:= atxfd;
end;
end.
