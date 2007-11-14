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
 winsock2;
 
function soc_opensocket(const kind: socketkindty; const nonblock: boolean;
                          out handle: integer): syserrorty;
var
 af1: integer;
 type1: integer;
 protocol1: integer;
 
begin
 type1:= sock_stream;
 case kind of 
  sok_inet: begin
  end;
  sok_inet6: begin
  end;
  else begin
   result:= sye_notimplemented;
   exit;
  end;
 end;
end;

function soc_shutdownsocket(const handle: integer;
                            const kind: socketshutdownkindty): syserrorty;
begin
 result:= sye_notimplemented;
end;

function soc_closesocket(const handle: integer): syserrorty;
begin
 result:= sye_notimplemented;
end;

function soc_bindsocket(const handle: integer;
                                  const addr: socketaddrty): syserrorty;
begin
 result:= sye_notimplemented;
end;

function soc_connectsocket(const handle: integer; const addr: socketaddrty;
                               const timeoutms: integer): syserrorty;
begin
 result:= sye_notimplemented;
end;

function soc_readsocket(const fd: longint; const buf: pointer;
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

function soc_getsockaddrerrortext(aerror: integer): string;
begin
end;

function soc_getsockaddr(const addr: socketaddrty): string;
begin
end;

function soc_getsockport(const addr: socketaddrty): integer;
begin
end;

function soc_setnonblocksocket(const handle: integer; const nonblock: boolean): syserrorty;
begin
 result:= sye_notimplemented;
end;

function soc_setsockrxtimeout(const handle: integer; const ms: integer): syserrorty;
begin
 result:= sye_notimplemented;
end;

function soc_setsocktxtimeout(const handle: integer; const ms: integer): syserrorty;
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

end.
