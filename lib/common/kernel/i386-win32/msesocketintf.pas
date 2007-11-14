{ MSEgui Copyright (c) 1999-2007 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msesocketintf;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 msesys;
{$include ..\msesocketintf}

implementation
uses
 winsock2,sysutils;

function setsocketerror: syserrorty;
begin
 result:= sye_socket;
 mselasterror:= wsagetlasterror;
end;

function soc_geterrortext(aerror: integer): string;
begin
 result:= inttostr(aerror);
end;
  
function soc_getaddrerrortext(aerror: integer): string;
begin
 result:= inttostr(aerror);
end;

function soc_open(const kind: socketkindty; const nonblock: boolean;
                          out handle: integer): syserrorty;
var
 af1: integer;
 type1: integer;
 protocol1: integer;
 
begin
 result:= sye_ok;
 type1:= sock_stream;
 case kind of 
  sok_inet: begin
   af1:= af_inet;
  end;
  sok_inet6: begin
   af1:= af_inet6;
  end;
  else begin
   result:= sye_notimplemented;
   exit;
  end;
 end;
 handle:= socket(af1,type1,ipproto_tcp);
 if handle = invalid_socket then begin
  handle:= invalidfilehandle;
  result:= setsocketerror;
 end;
end;

function soc_shutdown(const handle: integer;
                            const kind: socketshutdownkindty): syserrorty;
begin
 result:= sye_notimplemented;
end;

function soc_close(const handle: integer): syserrorty;
begin
 result:= sye_notimplemented;
end;

function soc_bind(const handle: integer;
                                  const addr: socketaddrty): syserrorty;
begin
 result:= sye_notimplemented;
end;

function soc_connect(const handle: integer; const addr: socketaddrty;
                               const timeoutms: integer): syserrorty;
begin
 result:= sye_notimplemented;
end;

function soc_read(const fd: longint; const buf: pointer;
            const nbytes: longword; out readbytes: integer;
            const timeoutms: integer): syserrorty;
begin
 result:= sye_notimplemented;
end;

function soc_listen(const handle: integer; const maxconnections: integer): syserrorty;
begin
 result:= sye_notimplemented;
end;

function soc_accept(const handle: integer;  const nonblock: boolean;                 
                  out conn: integer; out addr: socketaddrty;
                  const timeoutms: integer): syserrorty;
begin
 result:= sye_notimplemented;
end;

function soc_urltoaddr(var addr: socketaddrty): syserrorty;
begin
 result:= sye_notimplemented;
end;

function soc_getaddr(const addr: socketaddrty): string;
begin
end;

function soc_getport(const addr: socketaddrty): integer;
begin
end;

function soc_setnonblock(const handle: integer; const nonblock: boolean): syserrorty;
begin
 result:= sye_notimplemented;
end;

function soc_setrxtimeout(const handle: integer; const ms: integer): syserrorty;
begin
 result:= sye_notimplemented;
end;

function soc_settxtimeout(const handle: integer; const ms: integer): syserrorty;
begin
 result:= sye_notimplemented;
end;

function soc_poll(const handle: integer; const kind: pollkindsty;
                            const timeoutms: longword): syserrorty;
                             //0 -> no timeout
                             //for blocking mode
begin
 result:= sye_notimplemented;
end;
var
 testvar: integer;
 wsadata: twsadata;
 
initialization
 wsastartup((2 shl 8) or 2,wsadata);
end.
