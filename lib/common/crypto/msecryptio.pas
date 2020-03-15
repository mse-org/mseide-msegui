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

 ecryptoio = class(exception)
 end;

 tcryptoio = class;
 cryptoioclassty = class of tcryptoio;
 cryptoiokindty = (cyk_none,cyk_server,cyk_client);

 cryptodataty = array[0..17] of pointer;
 cryptoioinfoty = record
//  handler: tcryptio;
  kind: cryptoiokindty;
  classtype: cryptoioclassty;
  rxfd: integer;
  txfd: integer;
  cryptodata: cryptodataty;
 end;
 pcryptoioinfoty = ^cryptoioinfoty;

 connectionkindty = (cok_server,cok_client);

 tcryptoio = class(tmsecomponent)
  protected
   class procedure internalunlink(var ainfo: cryptoioinfoty); virtual;
   class procedure internalthreadterminate; virtual;
   class procedure connect(var ainfo: cryptoioinfoty;
                          const atimeoutms: integer);  virtual; abstract;
   class procedure accept(var ainfo: cryptoioinfoty;
                          const atimeoutms: integer);  virtual; abstract;
   class function write(var ainfo: cryptoioinfoty; const buffer: pointer;
                  const count: integer;
                  const atimeoutms: integer): integer; virtual; abstract;
   class function read(var ainfo: cryptoioinfoty; const buffer: pointer;
                  const count: integer;
                  const atimeoutms: integer): integer; virtual; abstract;
                    //atimeoutms < 0 -> nonblocked
 public
   procedure link(const atxfd,arxfd: integer;
                          out ainfo: cryptoioinfoty); virtual;
   {
   class procedure unlink(var ainfo: cryptioinfoty);
   class procedure threadterminate(var ainfo: cryptioinfoty);
   }
 end;

procedure cryptoconnect(var ainfo: cryptoioinfoty; const atimeoutms: integer);
procedure cryptoaccept(var ainfo: cryptoioinfoty; const atimeoutms: integer);
function cryptowrite(var ainfo: cryptoioinfoty; const buffer: pointer;
                    const count: integer; const atimeoutms: integer): integer;
function cryptoread(var ainfo: cryptoioinfoty; const buffer: pointer;
                    const count: integer; const atimeoutms: integer): integer;
                    //atimeoutms < 0 -> nonblocked
procedure cryptounlink(var ainfo: cryptoioinfoty);
procedure cryptothreadterminate(var ainfo: cryptoioinfoty);

implementation
uses
 msesystypes;

procedure cryptoconnect(var ainfo: cryptoioinfoty; const atimeoutms: integer);
begin
 if ainfo.classtype <> nil then begin
  ainfo.classtype.connect(ainfo,atimeoutms);
 end;
end;

procedure cryptoaccept(var ainfo: cryptoioinfoty; const atimeoutms: integer);
begin
 if ainfo.classtype <> nil then begin
  ainfo.classtype.accept(ainfo,atimeoutms);
 end;
end;

function cryptowrite(var ainfo: cryptoioinfoty; const buffer: pointer;
                 const count: integer; const atimeoutms: integer): integer;
begin
 result:= 0;
 if ainfo.classtype <> nil then begin
  result:= ainfo.classtype.write(ainfo,buffer,count,atimeoutms);
 end;
end;

function cryptoread(var ainfo: cryptoioinfoty; const buffer: pointer;
           const count: integer; const atimeoutms: integer): integer;
begin
 result:= 0;
 if ainfo.classtype <> nil then begin
  result:= ainfo.classtype.read(ainfo,buffer,count,atimeoutms);
 end;
end;

procedure cryptounlink(var ainfo: cryptoioinfoty);
begin
 if ainfo.classtype <> nil then begin
  ainfo.classtype.internalunlink(ainfo);
 end;
end;

procedure cryptothreadterminate(var ainfo: cryptoioinfoty);
begin
 if ainfo.classtype <> nil then begin
  ainfo.classtype.internalthreadterminate;
 end;
end;

{ tcryptoio }

class procedure tcryptoio.internalunlink(var ainfo: cryptoioinfoty);
begin
 with ainfo do begin
//  handler:= nil;
  classtype:= nil;
  txfd:= invalidfilehandle;
  rxfd:= invalidfilehandle;
 end;
end;

class procedure tcryptoio.internalthreadterminate;
begin
 //dummy
end;

procedure tcryptoio.link(const atxfd,arxfd: integer;
                          out ainfo: cryptoioinfoty);
begin
// ainfo.handler:= self;
 ainfo.classtype:= cryptoioclassty(classtype);
 ainfo.rxfd:= arxfd;
 ainfo.txfd:= atxfd;
end;
end.
