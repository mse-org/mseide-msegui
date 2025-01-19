{ MSEgui Copyright (c) 1999-2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msesocketintf;
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
 msesystypes,msesys;
{$ifdef FPC}
 {$include ../msesocketintf.inc}
{$else}
 {$include msesocketintf.inc}
{$endif}

implementation
uses
 mselibc,msefileutils,msesysintf1,msesysintf,msesysutils,sysutils;
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}

type
 datarecty = record
  //dummy
 end;

 locsockaddrty = record
                  sa_family: sa_family_t;
                  sa_data: datarecty;
                 end;
 plocsockaddrty = ^locsockaddrty;

 linuxsockadty = record
  case integer of
   0: (addr: sockaddr_in);
   1: (addr6: sockaddr_in6);
 end;

 linuxsockaddrty = record
  ad: linuxsockadty;
  platformdata: array[7..32] of longword;
 end;

function soc_getaddrerrortext(aerror: integer): string;
begin
 result:= strpas(gai_strerror(aerror));
end;

function soc_geterrortext(aerror: integer): string;
begin
 result:= inttostr(aerror);
end;

function soc_setnonblock(const handle: integer; const nonblock: boolean): syserrorty;
var
 int1: integer;
begin
 result:= sye_ok;
 int1:= fcntl(handle,f_getfl,[0]);
 if int1 = -1 then begin
  result:= syelasterror
 end
 else begin
  if nonblock then begin
   int1:= int1 or o_nonblock;
  end
  else begin
   int1:= int1 and not o_nonblock;
  end;
  if fcntl(handle,f_setfl,[int1]) = -1 then begin
   result:= sye_lasterror;
  end;
 end;
end;

function soc_open(const kind: socketkindty; const nonblock: boolean;
                                 out handle: integer): syserrorty;
var
 int1: integer;
begin
 case kind of
  sok_inet: int1:= pf_inet;
  sok_inet6: int1:= pf_inet6;
  else int1:= pf_local; //sok_local
 end;
 handle:= socket(int1,sock_stream,0);
 if handle = -1 then begin
  result:= syelasterror;
 end
 else begin
  result:= soc_setnonblock(handle,nonblock);
 end;
end;

function soc_shutdown(const handle: integer;
                           const kind: socketshutdownkindty): syserrorty;
begin
 if mselibc.shutdown(handle,ord(kind)) <> 0 then begin
  result:= syelasterror;
 end
 else begin
  result:= sye_ok;
 end;
end;

function soc_close(const handle: integer): syserrorty;
begin
 if mselibc.__close(handle) = 0 then begin
  result:= sye_ok;
 end
 else begin
  result:= syelasterror;
 end;
end;

function soc_connect(const handle: integer; const addr: socketaddrty;
                               const timeoutms: integer): syserrorty;
var
 str1: string;
 po1: plocsockaddrty;
 int1{,int2}: integer;
 pollres: pollkindsty;
begin
 result:= sye_ok;
 with addr do begin
  if kind = sok_local then begin
   str1:= ansistring(tosysfilepath(url));
   int1:= sizeof(locsockaddrty)+length(str1)+1;
   getmem(po1,int1);
   po1^.sa_family:= af_local;
   move(str1[1],po1^.sa_data,length(str1));
   pchar(@po1^.sa_data)[length(str1)]:= #0;
   {$ifdef FPC}
   if connect(handle,pointer(po1),int1) <> 0 then begin
   {$else}
   if connect(handle,psockaddr(po1)^,int1) <> 0 then begin
   {$endif}
    result:= soc_poll(handle,[poka_write],timeoutms,pollres);
    if result = sye_ok then begin
    {$ifdef FPC}
     if connect(handle,pointer(po1),int1) <> 0 then begin
    {$else}
     if connect(handle,psockaddr(po1)^,int1) <> 0 then begin
    {$endif}
      result:= syelasterror;
     end;
    end;
   end;
   freemem(po1);
  end
  else begin
   with linuxsockaddrty(platformdata) do begin
   {$ifdef linux}
    int1:= __libc_sa_len(ad.addr.sa_family);
   {$else}
    int1:= ad.addr.sa_len;
   {$endif}
    po1:= @ad.addr;
    {$ifdef FPC}
    if connect(handle,pointer(po1),int1) <> 0 then begin
    {$else}
    if connect(handle,psockaddr(po1)^,int1) <> 0 then begin
    {$endif};
     result:= soc_poll(handle,[poka_write],timeoutms,pollres);
     if result = sye_ok then begin
      {$ifdef FPC}
      if connect(handle,pointer(po1),int1) <> 0 then begin
      {$else}
      if connect(handle,psockaddr(po1)^,int1) <> 0 then begin
      {$endif}
       result:= syelasterror;
      end;
     end;
    end;
   end;
  end;
 end;
end;

function soc_read(const fd: longint; const buf: pointer;
                    const nbytes: longword; out readbytes: integer;
                    const timeoutms: integer): syserrorty;
                    //atimeoutms < 0 -> nonblocked
var
 pollres: pollkindsty;
begin
 result:= sye_ok;
 if timeoutms >= 0 then begin
  result:= soc_poll(fd,[poka_read],timeoutms,pollres);
 end;
 if result = sye_ok then begin
  readbytes:= __read(fd,buf^,nbytes);
  if readbytes <= 0 then begin
   if (timeoutms < 0) then begin
    if not ((sys_getlasterror = ewouldblock) or
             (sys_getlasterror = eagain)) then begin
     result:= syelasterror;
    end
    else begin
     readbytes:= 0;
    end;
   end
   else begin
    result:= syelasterror;
   end;
  end;
 end
 else begin
  readbytes:= -1;
 end;
end;

function soc_write(const fd: longint; buf: pointer;
                        nbytes: longword; out writebytes: integer;
                        const timeoutms: integer): syserrorty;
begin
 writebytes:= sys_write(fd,buf,nbytes);
 if writebytes > 0 then begin
  result:= sye_ok;
 end
 else begin
  result:= syelasterror;
 end;
end;

function soc_bind(const handle: integer;
                                     const addr: socketaddrty): syserrorty;
var
 str1: string;
 po1: plocsockaddrty;
 int1,int2: integer;
begin
 result:= sye_ok;
 with addr do begin
  if kind = sok_local then begin
   str1:= ansistring(tosysfilepath(url));
   int1:= sizeof(locsockaddrty)+length(str1)+1;
   getmem(po1,int1);
   po1^.sa_family:= af_local;
   move(str1[1],po1^.sa_data,length(str1));
   pchar(@po1^.sa_data)[length(str1)]:= #0;
   int2:= bind(handle,pointer(po1),int1);
   if (int2 <> 0) and (sys_getlasterror = EADDRINUSE) then begin
    mselibc.unlink(pchar(str1));
    int2:= bind(handle,pointer(po1),int1);
   end;
   if int2 <> 0 then begin
    result:= syelasterror;
   end;
   freemem(po1);
  end
  else begin
   with linuxsockaddrty(platformdata) do begin
   {$ifdef linux}
    if bind(handle,@ad,__libc_sa_len(ad.addr.sa_family)) <> 0 then begin
   {$else}
    if bind(handle,@ad,ad.addr.sa_len) <> 0 then begin
   {$endif}
     result:= syelasterror;
    end;
   end;
  end;
 end;
end;

function soc_listen(const handle: integer; const maxconnections: integer): syserrorty;
begin
 if listen(handle,maxconnections) <> 0 then begin
  result:= syelasterror;
 end
 else begin
  result:= sye_ok;
 end;
end;

function soc_accept(const handle: integer; const nonblock: boolean; out conn: integer;
             out addr: socketaddrty; const timeoutms: integer): syserrorty;
var
 pollres: pollkindsty;
begin
 result:= soc_poll(handle,[poka_read],timeoutms,pollres);
 if result = sye_ok then begin
  addr.size:= sizeof(linuxsockadty);
  conn:= accept(handle,@addr.platformdata,@addr.size);
  if conn = -1 then begin
   result:= syelasterror;
  end
  else begin
   result:= soc_setnonblock(conn,nonblock);
  end;
 end;
end;

function setsocktimeout(const handle: integer; const ms: integer;
      const optname: integer): syserrorty;
var
 ti: ttimeval;
begin
 ti.tv_sec:= ms div 1000;
 ti.tv_usec:= (ms mod 1000) * 1000;
 if setsockopt(handle,sol_socket,optname,@ti,sizeof(ti)) <> 0 then begin
  result:= syelasterror;
 end
 else begin
  result:= sye_ok;
 end;
end;

function soc_setrxtimeout(const handle: integer; const ms: integer): syserrorty;
begin
 result:= setsocktimeout(handle,ms,so_rcvtimeo);
end;

function soc_settxtimeout(const handle: integer; const ms: integer): syserrorty;
begin
 result:= setsocktimeout(handle,ms,so_sndtimeo);
end;

function soc_urltoaddr(var addr: socketaddrty): syserrorty;
var
 str1: string;
 int1: integer;
// str2: string;
// err: integer;
 info1: addrinfo;
 po1: paddrinfo;
begin
 result:= sye_ok;
 with addr,linuxsockaddrty(platformdata) do begin
  if kind = sok_local then begin
   str1:= ansistring(tosysfilepath(url));
  end
  else begin
   str1:= ansistring(url);
  end;
  fillchar(info1,sizeof(addrinfo),0);
  with info1 do begin
   ai_socktype:= ord(sock_stream);
   case kind of
    sok_local: begin
     ai_family:= af_local;
    end;
    sok_inet: begin
     ai_family:= af_inet;
    end;
    sok_inet6: begin
     ai_family:= af_inet6;
    end;
   end;
  end;
  int1:= getaddrinfo(pchar(str1),nil,@info1,@po1);
  if int1 <> 0 then begin
   mselasterror:= int1;
   result:= sye_sockaddr;
  end
  else begin
   with po1^ do begin
    move(ai_addr^,ad,ai_addrlen);
    if port <> 0 then begin
     case ai_family of
      af_inet: begin
       ad.addr.sin_port:= htons(port);
      end;
      af_inet6: begin
       ad.addr6.sin6_port:= htons(port);
      end;
     end;
    end;
   end;
   freeaddrinfo(po1);
  end;
 end;
end;

function soc_getaddr(const addr: socketaddrty): string;
begin
 with linuxsockaddrty(addr.platformdata).ad do begin
  case addr.sa_family of
   af_inet: begin
    setlength(result,sizeof(addr.sin_addr));
    move(addr.sin_addr,result[1],length(result));
   end;
   af_inet6: begin
    setlength(result,sizeof(addr6.sin6_addr));
    move(addr6.sin6_addr,result[1],length(result));
   end;
   else begin
    result:= '';
   end;
  end;
 end;
end;

function soc_poll(const handle: integer; const kind: pollkindsty;
                            const timeoutms: longword;
                            out pollres: pollkindsty): syserrorty;
                             //0 -> no timeout
                             //for blocking mode
var
 int1,int2: integer;
 lwo1,lwo2: longword;
 info: pollfd;
begin
 lwo1:= 0;
 pollres:= [];
 fillchar(info,sizeof(info),0);
 with info do begin
  fd:= handle;
  if poka_read in kind then begin
   events:= events or pollin;
  end;
  if poka_write in kind then begin
   events:= events or pollout;
  end;
  if poka_except in kind then begin
   events:= events or pollpri;
  end;
 end;
 if timeoutms > 0 then begin
  lwo1:= timestampms + timeoutms;
  int2:= timeoutms;
 end
 else begin
  int2:= -1;
 end;
 while true do begin
  int1:= poll(@info,1,int2);
  if (int1 >= 0) or (sys_getlasterror <> eintr) then begin
   break;
  end;
  if timeoutms > 0 then begin
   lwo2:= lwo1 - timestampms;
   if integer(lwo2) <= 0 then begin
    int1:= 0;
    break;
   end;
   int2:= lwo2;
  end;
 end;
 if int1 < 0 then begin
  result:= syelasterror;
 end
 else begin
  if int1 = 0 then begin
   result:= sye_timeout;
  end
  else begin
   with info do begin
    if revents and not pollin <> 0 then begin
     include(pollres,poka_read);
    end;
    if revents and not pollout <> 0 then begin
     include(pollres,poka_write);
    end;
    if revents and not pollpri <> 0 then begin
     include(pollres,poka_except);
    end;
   end;
   result:= sye_ok;
  end;
 end;
end;

function soc_getport(const addr: socketaddrty): integer;
begin
 with linuxsockaddrty(addr.platformdata).ad do begin
  case addr.sa_family of
   af_inet: begin
    result:= ntohs(addr.sin_port);
   end;
   af_inet6: begin
    result:= ntohs(addr6.sin6_port);
   end;
   else begin
    result:= 0;
   end;
  end;
 end;
end;

end.
