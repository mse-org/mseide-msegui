{ MSEgui Copyright (c) 1999-2007 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msesocketintf;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 msesystypes,msesys;
{$include ..\msesocketintf.inc}

implementation
uses
 {$ifdef FPC}winsock2{$else}winsock2_del{$endif},sysutils,msestrings,msetypes;
type
 paddrinfo = ^addrinfo;
 addrinfo = record
  ai_flags: longint;
  ai_family: longint;
  ai_socktype: longint;
  ai_protocol: longint;
  ai_addrlen: size_t;
  ai_addr: psockaddr;
  ai_canonname: pchar;
  ai_next: paddrinfo;
 end;
 ppaddrinfo= ^paddrinfo;

 datarecty = record
  //dummy
 end;
 
 win32sockadty = record
  case integer of
   0: (addr: sockaddr_in);
   1: (addr6: sockaddr_in6);
 end;
 
 win32sockaddrty = record
  ad: win32sockadty;
  platformdata: array[7..32] of longword;
 end;

//function getaddrinfo(__name:Pchar; __service:Pchar; __req:Paddrinfo;
//          __pai:PPaddrinfo):longint; stdcall;external WINSOCK2_DLL name 'getaddrinfo';
//procedure freeaddrinfo(__ai:Paddrinfo); stdcall;external WINSOCK2_DLL name 'freeaddrinfo';

function setsocketerror: syserrorty;
begin
 result:= sye_socket;
 mselasterror:= wsagetlasterror;
end;

function checkerror(const aerror: integer): syserrorty;
begin
 if aerror = 0 then begin
  result:= sye_ok;
 end
 else begin
  result:= setsocketerror;
 end;
end;

function sa_len(const family: integer): integer;
begin
 case family of
  af_inet: begin
   result:= sizeof(tsockaddrin);
//   result:= sizeof(tsockaddrin.sin_family) + sizeof(tsockaddrin.sin_port) +
//                        sizeof(tinaddr);
  end;
  af_inet6: begin
   result:= sizeof(tsockaddrin6);
//   result:= sizeof(tsockaddrin6.sin6_family) + sizeof(tsockaddrin6.sin6_port) +
//                   sizeof(tsockaddrin6.sin6_flowinfo) +
//                        sizeof(tin6addr);
  end;
  else begin
   result:= 0;
  end;
 end;
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
// protocol1: integer;
 
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
 if handle = integer(invalid_socket) then begin
  handle:= invalidfilehandle;
  result:= setsocketerror;
 end
 else begin
  result:= soc_setnonblock(handle,nonblock);
 end;
end;

function soc_shutdown(const handle: integer;
                            const kind: socketshutdownkindty): syserrorty;
begin
 result:= checkerror(shutdown(handle,ord(kind)));
end;

function soc_close(const handle: integer): syserrorty;
begin
 if closesocket(handle) <> 0 then begin
  result:= setsocketerror;
 end
 else begin
  result:= sye_ok;
 end;
end;

function soc_bind(const handle: integer;
                                  const addr: socketaddrty): syserrorty;
begin
 if addr.kind in [sok_inet,sok_inet6] then begin
  with win32sockaddrty(addr.platformdata) do begin
   result:= checkerror(bind(handle,@ad,sa_len(ad.addr.sin_family)));
  end;
 end
 else begin
  result:= sye_notimplemented;
 end;
end;

function soc_connect(const handle: integer; const addr: socketaddrty;
                               const timeoutms: integer): syserrorty;
var
// str1: string;
 int1{,int2}: integer;
 pollres: pollkindsty;
begin
 result:= sye_ok;
 with addr do begin
  if kind = sok_local then begin
   result:= sye_notimplemented;
  end
  else begin
   with win32sockaddrty(platformdata) do begin
    int1:= sa_len(ad.addr.sa_family);
    if connect(handle,ad.addr,int1) <> 0 then begin
     if wsagetlasterror = wsaewouldblock then begin
      result:= soc_poll(handle,[poka_write,poka_except],timeoutms,pollres);
      if (result = sye_ok) and (poka_except in pollres) then begin
//       connect(handle,ad.addr,int1);
       result:= setsocketerror;
      end;
     end
     else begin
      result:= setsocketerror;
     end;
    end;
   end;
  end;
 end;
end;

function soc_read(const fd: longint; const buf: pointer;
            const nbytes: longword; out readbytes: integer;
            const timeoutms: integer): syserrorty;
var
 pollres: pollkindsty;
// err: integer;
begin
 result:= sye_ok;
 if timeoutms >= 0 then begin
  result:= soc_poll(fd,[poka_read],timeoutms,pollres);
 end;
 if result = sye_ok then begin
  readbytes:= recv(fd,buf^,nbytes,0);
  if readbytes < 0 then begin
   result:= setsocketerror;
  end;
 end
 else begin
  readbytes:= -1;
 end;
end;

function soc_write(const fd: longint; buf: pointer;
                        nbytes: longword; out writebytes: integer;
                        const timeoutms: integer): syserrorty;
var        //todo: correct timeout value for multiple runs
 int1,int2: integer;
 pollres: pollkindsty;
begin
 writebytes:= -1;
 int2:= 0;
 repeat
  result:= soc_poll(fd,[poka_write],timeoutms,pollres);  
  if result <> sye_ok then begin
   exit;
  end;
  int1:= send(fd,buf,nbytes,0);
  if int1 <= 0 then begin
   writebytes:= int1;
   break;
  end;
  inc(int2,int1);
  inc(pchar(buf),int1);
  dec(nbytes,int1);
 until integer(nbytes) <= 0;
 if nbytes = 0 then begin
  result:= sye_ok;
  writebytes:= int2;
 end
 else begin
  result:= setsocketerror;
 end;
end;

function soc_listen(const handle: integer; const maxconnections: integer): syserrorty;
begin
 result:= checkerror(listen(handle,maxconnections));
end;

function soc_accept(const handle: integer;  const nonblock: boolean;                 
                  out conn: integer; out addr: socketaddrty;
                  const timeoutms: integer): syserrorty;
var
 pollres: pollkindsty;
begin
 result:= soc_poll(handle,[poka_read],timeoutms,pollres);
 if result = sye_ok then begin
  addr.size:= sizeof(win32sockadty);
  conn:= accept(handle,@addr.platformdata,@addr.size);
  if conn = -1 then begin
   result:= syelasterror;
  end
  else begin
   result:= soc_setnonblock(conn,nonblock);
  end;
 end;
end;

function soc_urltoaddr(var addr: socketaddrty): syserrorty;
//todo: name resolution, inet6
var
 str1: string;
 int1,int2,int3: integer;
 ar1: stringarty;
 bo1: boolean;
begin
 result:= sye_sockaddr;
 with addr,win32sockaddrty(platformdata) do begin
  if kind = sok_inet then begin
   str1:= url;
   ar1:= splitstring(str1,'.');
   if high(ar1) = 3 then begin
    bo1:= true;
    int2:= 0;
    for int1:= 0 to 3 do begin
     try
      int3:= strtoint(ar1[int1]);
     except
      bo1:= false;
      break;
     end;
     if (int3 < 0) or (int3 > 255) then begin
      bo1:= false;
      break;
     end;
     int2:= (int2 shl 8) or int3;
    end;
    if bo1 then begin
     fillchar(ad,sizeof(ad),0);
     with ad.addr do begin
      sin_family:= af_inet;
      sin_port:= htons(port);
      sin_addr.s_addr:= htonl(int2);
     end;     
     size:= sizeof(ad.addr);
     result:= sye_ok;
    end;
   end;
  end;
 end;
end;

function soc_getaddr(const addr: socketaddrty): string;
begin
 result:= ''; //todo
end;

function soc_getport(const addr: socketaddrty): integer;
begin
 result:= 0; //todo
end;

function soc_setnonblock(const handle: integer; const nonblock: boolean): syserrorty;
var
 int1: u_long;
begin
 result:= sye_ok;
 if nonblock then begin
  int1:= 1;
 end
 else begin
  int1:= 0;
 end;
 if ioctlsocket(tsocket(handle),longint(fionbio),pu_long(@int1)) <> 0 then begin
  result:= setsocketerror;
 end;
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
                            const timeoutms: longword;
                            out pollres: pollkindsty): syserrorty;
                             //0 -> no timeout
                             //for blocking mode
var
 rset,wset,eset: tfdset;
 prset,pwset,peset: pfdset;
 ti: timeval;
 pti: ptimeval;
 int1: integer;
begin
 pollres:= [];
 if timeoutms <> 0 then begin
  ti.tv_sec:= timeoutms div 1000;
  ti.tv_usec:= (timeoutms mod 1000) * 1000;
  pti:= @ti;
 end
 else begin
  pti:= nil;
 end;
 if poka_read in kind then begin
  fd_zero(rset);
  fd_set(handle,rset);
  prset:= @rset;
 end
 else begin
  prset:= nil;
 end;
 if poka_write in kind then begin
  fd_zero(wset);
  fd_set(handle,wset);
  pwset:= @wset;
 end
 else begin
  pwset:= nil;
 end;
 if poka_except in kind then begin
  fd_zero(eset);
  fd_set(handle,eset);
  peset:= @eset;
 end
 else begin
  peset:= nil;
 end;
 int1:= select(0,prset,pwset,peset,pti);
 if int1 > 0 then begin
  if (poka_read in kind) and fd_isset(handle,rset) then begin
   include(pollres,poka_read);
  end;
  if (poka_write in kind) and fd_isset(handle,wset) then begin
   include(pollres,poka_write);
  end;
  if (poka_except in kind) and fd_isset(handle,eset) then begin
   include(pollres,poka_except);
  end;
  result:= sye_ok;
 end
 else begin
  if int1 = 0 then begin
   result:= sye_timeout;
  end
  else begin
   result:= setsocketerror;
  end;
 end;
end;

var
 wsadata: twsadata;
 
initialization
 wsastartup((2 shl 8) or 2,wsadata);
finalization
 wsacleanup;
end.
