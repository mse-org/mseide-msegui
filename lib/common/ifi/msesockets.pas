{ MSEgui Copyright (c) 2007-2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msesockets;
//todo: separate comm base code and sockets

{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}
interface
uses
 classes,mclasses,mseglob,mseclasses,msesystypes,msesys,msestrings,msepipestream,
 mseapplication,msethread,mseevent,msecryptio,msetypes,msesercomm;

const
 defaultmaxconnections = 16;
  
type
 
 tsocketreader = class(tcommreader)
  protected
   procedure settimeoutms(const avalue: integer); override;
   procedure sethandle(value: integer); override;
   function internalread(var buf; const acount: integer;
                    const nonblocked: boolean = false): integer; override;
   procedure closehandle(const ahandle: integer); override;
  public
   constructor create(const aowner: tcustomcommpipes);
 end;

 tsocketwriter = class(tcommwriter)
  protected
   procedure settimeoutms(const avalue: integer); override;
   procedure closehandle(const ahandle: integer); override;
   function internalwrite(const buffer; count: longint): longint; override;
 end;
 
 tcustomsocketclient = class;

 tcustomsocketpipes = class(tcustomcommpipes)
  protected
   procedure createpipes; override;
 end;
 
 tsocketpipes = class(tcustomsocketpipes)
  published
   property optionsreader;
   property overloadsleepus;
   property oninputavailable;
   property oncommbroken;
 end;
{ 
 tclientsocketpipes = class(tsocketpipes)
  protected
   procedure doafterconnect; override;
 end;
 
  
 tserversocketpipes = class(tcustomsocketpipes)
  protected
   procedure doafterconnect; override;
 end;
}

 socketpipesarty = array of tsocketpipes;
 tcustomsocketserver = class;

 tcustomsocketcomp = class(tcustomcommcomp)
 end;
 
 tsocketcomp = class(tcustomsocketcomp)
  published
   property active;
   property activator;
   property cryptoio;   
   property onbeforeconnect;
   property onafterconnect;
   property onbeforedisconnect;
   property onafterdisconnect;
 end;
 
 tcustomurlsocketcomp = class(tcustomsocketcomp)
  private
   fkind: socketkindty;
   furl: msestring;
   fport: word;
   procedure seturl(const avalue: filenamety);
  protected
   function getsockaddr: socketaddrty;
   property kind: socketkindty read fkind write fkind default sok_local;
   property url: filenamety read furl write seturl;
   property port: word read fport write fport default 0;
 end;

 turlsocketcomp = class(tcustomurlsocketcomp)
  published
   property active;
   property activator;
   property cryptoio;   
   property onbeforeconnect;
   property onafterconnect;
   property onbeforedisconnect;
   property onafterdisconnect;

   property kind;
   property url;
   property port;
 end;
  
 tcustomsocketclient = class(tcustomurlsocketcomp)
  private
   procedure setpipes(const avalue: tsocketpipes);
  protected
   fpipes: tsocketpipes;
   procedure internalconnect; override;
   procedure internaldisconnect; override;
   procedure closepipes(const sender: tcustomcommpipes); override;
   procedure doasyncevent(var atag: integer); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property pipes: tsocketpipes read fpipes write setpipes;
 end;

 tsocketclient = class(tcustomsocketclient)
  published
   property pipes;
   property active;
   property activator;
   property cryptoio;   
   property onbeforeconnect;
   property onafterconnect;
   property onbeforedisconnect;
   property onafterdisconnect;

   property kind;
   property url;
   property port;
 end;
 
 tsocketstdio = class(tsocketcomp)
  private
   procedure setpipes(const avalue: tsocketpipes);
   function getcryptoiokind: cryptoiokindty;
   procedure setcryptoiokind(const avalue: cryptoiokindty);
  protected
   fpipes: tsocketpipes;
   procedure internalconnect; override;
   procedure internaldisconnect; override;
   procedure closepipes(const sender: tcustomcommpipes); override;
   procedure doasyncevent(var atag: integer); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property pipes: tsocketpipes read fpipes write setpipes;
   property cryptiokind: cryptoiokindty read getcryptoiokind 
                        write setcryptoiokind default cyk_none;
 end;
 
  
 socketaccepteventty = procedure(const sender: tcustomsocketserver;
                     const asocket: integer;
                     const addr: socketaddrty; var accept: boolean) of object;
 socketserverconnecteventty = procedure(const sender: tcustomsocketserver;
                     const apipes: tcustomcommpipes) of object;

 socketserverstatety = (sss_closepipespending);
 socketserverstatesty = set of socketserverstatety;
 
 tcustomsocketserver = class(tcustomurlsocketcomp)
  private
   fstate: socketserverstatesty;
   fthread: tmsethread;
   fmaxconnections: integer;
   faccepttimeoutms: integer;
   fonaccept: socketaccepteventty;
   fonbeforechconnect: socketserverconnecteventty;
   fonafterchconnect: socketserverconnecteventty;
   fonbeforechdisconnect: socketserverconnecteventty;
   fonafterchdisconnect: socketserverconnecteventty;
   fpipes: socketpipesarty;
   foverloadsleepus: integer;
   foninputavailable: commpipeseventty;
   fonsocketbroken: commpipeseventty;
   fconnectioncount: integer;
   foptionsreader: pipereaderoptionsty;
   frxtimeoutms: integer;
   ftxtimeoutms: integer;
   function execthread(thread: tmsethread): integer;
  protected
   procedure internaldisconnect; override;
   procedure doclosepipes;
   procedure closepipes(const sender: tcustomcommpipes); override;
   procedure doasyncevent(var atag: integer); override;
   procedure doafterchconnect(const sender: tcustomcommpipes);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure runhandlerapp(const asocket: integer; const acommandline: filenamety);
   property connectioncount: integer read fconnectioncount;
  published
   property maxconnections: integer read fmaxconnections write fmaxconnections 
                             default defaultmaxconnections;
   property accepttimeoutms: integer read faccepttimeoutms 
                             write faccepttimeoutms default 0;
   property rxtimeoutms: integer read frxtimeoutms write frxtimeoutms default 0;
   property txtimeoutms: integer read ftxtimeoutms write ftxtimeoutms default 0;
   
   property onaccept: socketaccepteventty read fonaccept write fonaccept;
   property onbeforechconnect: socketserverconnecteventty read fonbeforechconnect
                               write fonbeforechconnect;
   property onafterchconnect: socketserverconnecteventty read fonafterchconnect
                               write fonafterchconnect;
   property onbeforechdisconnect: socketserverconnecteventty read fonbeforechdisconnect
                               write fonbeforechdisconnect;
   property onafterchdisconnect: socketserverconnecteventty read fonafterchdisconnect
                               write fonafterchdisconnect;
   property overloadsleepus: integer read foverloadsleepus 
                  write foverloadsleepus default -1;
            //checks application.checkoverload before calling oninputavaliable
            //if >= 0
   property optionsreader: pipereaderoptionsty read foptionsreader
                               write foptionsreader default [];
   property oninputavailable: commpipeseventty read foninputavailable 
                                 write foninputavailable;
   property onsocketbroken: commpipeseventty read fonsocketbroken 
                                 write fonsocketbroken;
 end;

 tsocketserver = class(tcustomsocketserver)
  protected
   procedure internalconnect; override;
  published
   property active;
   property activator;
   property cryptoio;   
   property onbeforeconnect;
   property onafterconnect;
   property onbeforedisconnect;
   property onafterdisconnect;

   property kind;
   property url;
   property port;
 end;

 tsocketserverstdio = class(tcustomsocketserver)
  protected
   procedure internalconnect; override;
  public
   constructor create(aowner: tcomponent); override;  
  published
   property active;
 end;
     
procedure checksyserror(const aresult: integer);

procedure socketerror(const error: syserrorty; const text: string = '');

implementation
uses
 msefileutils,msesysintf,sysutils,msestream,mseprocutils,msesysutils,
 msesocketintf,msearrayutils;

type
 tcustompipes1 = class(tcustomcommpipes);
 
procedure socketerror(const error: syserrorty; const text: string = '');
begin
 case error of
  sye_ok: begin
  end;
  sye_sockaddr: begin
   raise esys.create(error,text+soc_getaddrerrortext(mselasterror));
  end;
  sye_socket: begin
   raise esys.create(error,text+soc_geterrortext(mselasterror));
  end;
  else begin
   syserror(error,text);
  end;
 end;
end;
  
procedure checksyserror(const aresult: integer);
begin
 if aresult <> 0 then begin
  syserror(syelasterror);
 end;
end;

{ tcustomurlsocketcomp}

procedure tcustomurlsocketcomp.seturl(const avalue: filenamety);
begin
 checkinactive;
 furl:= avalue;
end;

function tcustomurlsocketcomp.getsockaddr: socketaddrty;
begin
 with result do begin
  kind:= fkind;
  port:= fport;
  fillchar(platformdata,sizeof(platformdata),0);
  size:= 0;
  url:= furl;
  case fkind of
   sok_local: begin
   end;
   sok_inet,sok_inet6: begin
    socketerror(soc_urltoaddr(result));
   end;
  end;
 end;  
end;

{ tsocketstdio }

constructor tsocketstdio.create(aowner: tcomponent);
begin
 if fpipes = nil then begin
  fpipes:= tsocketpipes.create(self,cyk_none);
 end;
 inherited;
end;

destructor tsocketstdio.destroy;
begin
 fpipes.free;
 inherited;
end;

procedure tsocketstdio.setpipes(const avalue: tsocketpipes);
begin
 fpipes.assign(avalue);
end;

procedure tsocketstdio.internalconnect;
begin
 fpipes.tx.handle:= sys_stdout;
 fpipes.rx.handle:= sys_stdin;
 factive:= true;
end;

procedure tsocketstdio.internaldisconnect;
begin
 fpipes.handle:= invalidfilehandle;
 inherited
end;

procedure tsocketstdio.closepipes(const sender: tcustomcommpipes);
begin
 asyncevent(closepipestag);
end;

procedure tsocketstdio.doasyncevent(var atag: integer);
begin
 if atag = closepipestag then begin
  disconnect;
 end;
end;

function tsocketstdio.getcryptoiokind: cryptoiokindty;
begin
 result:= fpipes.fcryptoioinfo.kind;
end;

procedure tsocketstdio.setcryptoiokind(const avalue: cryptoiokindty);
begin
 fpipes.fcryptoioinfo.kind:= avalue;
end;

{ tclientsocketpipes }
{
procedure tclientsocketpipes.doafterconnect;
begin
 if fcryptioinfo.handler <> nil then begin
  ftx.fcrypt:= @fcryptioinfo;
  frx.fcrypt:= @fcryptioinfo;
  fcryptioinfo.handler.link(ftx.handle,frx.handle,fcryptioinfo);
  cryptconnect(fcryptioinfo,frx.timeoutms);
 end;
 inherited;
end;
}
{ tcustomsocketclient }

constructor tcustomsocketclient.create(aowner: tcomponent);
begin
 if fpipes = nil then begin
  fpipes:= tsocketpipes.create(self,cyk_client);
 end;
 inherited;
end;

destructor tcustomsocketclient.destroy;
begin
 fpipes.free;
 inherited;
end;

procedure tcustomsocketclient.setpipes(const avalue: tsocketpipes);
begin
 fpipes.assign(avalue);
end;

procedure tcustomsocketclient.internalconnect;
begin
 socketerror(soc_open(fkind,true,fhandle));
 try
  socketerror(soc_connect(fhandle,getsockaddr,fpipes.tx.timeoutms));
 except
  sys_closefile(fhandle);
  fhandle:= invalidfilehandle;
  raise;
 end;
 try
  fpipes.onafterconnect:= {$ifdef FPC}@{$endif}doafterconnect;
  fpipes.setcryptoio(fcryptoio);
  fpipes.handle:= fhandle;
 except
  internaldisconnect;
  raise;
 end;
 factive:= true;
end;

procedure tcustomsocketclient.internaldisconnect;
begin
 fpipes.handle:= invalidfilehandle;
 inherited
end;

procedure tcustomsocketclient.closepipes(const sender: tcustomcommpipes);
begin
 if (csdestroying in componentstate) and application.ismainthread then begin
  disconnect;
 end
 else begin
  asyncevent(closepipestag);
 end;
end;

procedure tcustomsocketclient.doasyncevent(var atag: integer);
begin
 if atag = closepipestag then begin
  disconnect;
 end;
end;

{ tserversocketpipes }
{
procedure tserversocketpipes.doafterconnect;
begin
 if fcryptioinfo.handler <> nil then begin
  ftx.fcrypt:= @fcryptioinfo;
  frx.fcrypt:= @fcryptioinfo;
  fcryptioinfo.handler.link(ftx.handle,frx.handle,fcryptioinfo);
  cryptaccept(fcryptioinfo,frx.timeoutms);
 end;
 inherited;
end;
}
{ tcustomsocketserver }

constructor tcustomsocketserver.create(aowner: tcomponent);
begin
 fmaxconnections:= defaultmaxconnections;
 foverloadsleepus:= -1;
 inherited;
end;

destructor tcustomsocketserver.destroy;
var
 int1: integer;
begin
 disconnect;
 inherited;
 freeandnil(fthread);
 for int1:= 0 to high(fpipes) do begin
  fpipes[int1].free;
 end;
end;

procedure tcustomsocketserver.doafterchconnect(const sender: tcustomcommpipes);
begin
 if canevent(tmethod(fonafterchconnect)) then begin
  application.lock;
  try
   fonafterchconnect(self,sender);
  finally
   application.unlock;
  end;
 end;
end;

function tcustomsocketserver.execthread(thread: tmsethread): integer;
var
 addr: socketaddrty;
 conn: integer;
 bo1: boolean;
 int1,int2: integer;
 err: syserrorty;
// cryptioinfo: cryptioinfoty;
begin
{$ifdef mse_debugsockets}
 debugout(self,'server execthread');
{$endif}
 result:= 0;
 addr.kind:= fkind;
 addr.size:= sizeof(addr.platformdata);
 while not thread.terminated do begin
  err:= soc_accept(fhandle,true,conn,addr,0);
{$ifdef mse_debugsockets}
 debugout(self,'accept error:' + inttostr(ord(err)));
{$endif}
  if not thread.terminated then begin
   if err = sye_ok then begin
    try
     application.lock;
     try
      if canevent(tmethod(fonaccept)) then begin
       bo1:= false;
       fonaccept(self,conn,addr,bo1);
      end
      else begin
       bo1:= true;
      end;
      if bo1 then begin
       int2:= -1;
       for int1:= 0 to high(fpipes) do begin
        if fpipes[int1] = nil then begin
         int2:= int1;
         break;
        end;
       end;
       if int2 < 0 then begin
        setlength(fpipes,high(fpipes)+2);
        int2:= high(fpipes);
       end;
       fpipes[int2]:= tsocketpipes.create(self,cyk_server);
       inc(fconnectioncount);
       with fpipes[int2] do begin
        rx.timeoutms:= frxtimeoutms;
        tx.timeoutms:= ftxtimeoutms;
        optionsreader:= self.foptionsreader;
        overloadsleepus:= self.foverloadsleepus;
        oninputavailable:= self.foninputavailable;
        onsocketbroken:= self.fonsocketbroken;
        onafterconnect:= {$ifdef FPC}@{$endif}self.doafterchconnect;
        if canevent(tmethod(fonbeforechconnect)) then begin
         fonbeforechconnect(self,fpipes[int2]);
        end;
        setcryptoio(fcryptoio);
        handle:= conn;
       end;
      end
      else begin
 //      sys_shutdownsocket(conn,ssk_both);
       soc_close(conn);
      end;
     finally
      application.unlock;
     end;
    except
     application.handleexception(self);
    end;
   end
   else begin
    if (err <> sye_timeout) or (fconnectioncount = 0) then begin
     asyncevent(closeconnectiontag);
     break;
    end;
   end;
  end;
 {$ifdef mse_debugsockets}
  debugout(self,'server exitthread');
 {$endif}
 end;
end;

procedure tcustomsocketserver.internaldisconnect;
var
 int1: integer;
begin
{$ifdef mse_debugsockets}
 debugout(self,'internaldisconnect');
{$endif}
 if fthread <> nil then begin
  fthread.terminate;
 end;
 for int1:= 0 to high(fpipes) do begin
  if fpipes[int1] <> nil then begin
   try
    closepipes(fpipes[int1]);
   except
   end;
  end;
 end;
 if fhandle <> invalidfilehandle then begin
  soc_shutdown(fhandle,ssk_rx);
  soc_close(fhandle);
 end;
 if fthread <> nil then begin
  application.waitforthread(fthread);
 end;
 freeandnil(fthread);
// soc_close(fhandle);
 inherited;
end;

procedure tcustomsocketserver.doclosepipes;
var
 int1: integer;
begin
 for int1:= 0 to high(fpipes) do begin
  if (fpipes[int1] <> nil) and 
              (fpipes[int1].tx.handle = invalidfilehandle) then begin
   fpipes[int1].release;
   if not (csdestroying in application.componentstate) and 
                not application.terminated then begin
    fpipes[int1]:= nil;     //destroying can be delayed
   end;
  end;
 end;
end;

procedure tcustomsocketserver.closepipes(const sender: tcustomcommpipes);
begin
 if (sender.rx.handle <> invalidfilehandle) or 
             (cps_detached in tcustompipes1(sender).fstate) then begin
  exclude(tcustompipes1(sender).fstate,cps_detached);
  if canevent(tmethod(fonbeforechdisconnect)) then begin
   try
    fonbeforechdisconnect(self,sender);
   except
    application.handleexception(self);
   end;
  end;
  sender.tx.handle:= invalidfilehandle;
  dec(fconnectioncount);
  if (csdestroying in componentstate) and application.ismainthread then begin
   doclosepipes;
  end
  else begin
   if not (sss_closepipespending in fstate) then begin
    include(fstate,sss_closepipespending);  
    asyncevent(closepipestag);
   end;
  end;
  if canevent(tmethod(fonafterchdisconnect)) then begin
   fonafterchdisconnect(self,sender);
  end;
 end;
end;

procedure tcustomsocketserver.doasyncevent(var atag: integer);
begin
 case atag of
  closepipestag: begin
   exclude(fstate,sss_closepipespending);
   doclosepipes;
  end;
  closeconnectiontag: begin
   active:= false;
  end;
 end;
end;

procedure tcustomsocketserver.runhandlerapp(const asocket: integer;
               const acommandline: filenamety);
var
 int1,int2: integer;
begin
 syserror(sys_dup(asocket,int1));
 syserror(sys_dup(asocket,int2));
 execmse3(acommandline,@int1,@int2);
end;

{ tsocketserver }

procedure tsocketserver.internalconnect;
begin
 if not (csdesigning in componentstate) then begin
  syserror(soc_open(fkind,true,fhandle));
  try
   syserror(soc_bind(fhandle,getsockaddr));
  except
   sys_closefile(fhandle);
   fhandle:= invalidfilehandle;
   raise;
  end;
  try
   syserror(soc_listen(fhandle,fmaxconnections));
  except
   internaldisconnect;
   raise;
  end;
  factive:= true;
  fthread:= tmsethread.create({$ifdef FPC}@{$endif}execthread);
 end;
 factive:= true;
end;

{ tsocketserverstdio }

constructor tsocketserverstdio.create(aowner: tcomponent);
begin
 inherited;
 fkind:= sok_inet;
end;

procedure tsocketserverstdio.internalconnect;
begin
 if not (csdesigning in componentstate) then begin
  syserror(sys_dup(sys_stdin,fhandle));
  factive:= true;
  fthread:= tmsethread.create({$ifdef FPC}@{$endif}execthread);
 end
 else begin
  factive:= true;
 end;
end;

{ tsocketreader }

constructor tsocketreader.create(const aowner: tcustomcommpipes);
begin
 inherited;
 fstate:= fstate + [tss_nosigio,tss_unblocked];
end;

procedure tsocketreader.sethandle(value: integer);
begin
 if value <> invalidfilehandle then begin
  soc_setnonblock(value,true);
 end;
 inherited;
end;

function tsocketreader.internalread(var buf; const acount: integer;
                   const nonblocked: boolean = false): integer;
var
 int1: integer;
begin
 if nonblocked then begin
  int1:= -1;
 end
 else begin
  int1:= 0;
 end;
 soc_read(handle,@buf,acount,result,int1);
end;

procedure tsocketreader.closehandle(const ahandle: integer);
begin
 soc_shutdown(ahandle,ssk_rx);
 inherited;
end;

procedure tsocketreader.settimeoutms(const avalue: integer);
begin
 inherited;
 if handle <> invalidfilehandle then begin
  soc_setrxtimeout(handle,avalue);
 end;
end;

{ tsocketwriter }

procedure tsocketwriter.closehandle(const ahandle: integer);
begin
// sys_shutdownsocket(ahandle,ssk_tx);
 inherited;
end;

procedure tsocketwriter.settimeoutms(const avalue: integer);
begin
 inherited;
 if handle <> invalidfilehandle then begin
  soc_settxtimeout(handle,avalue);
 end;
end;

function tsocketwriter.internalwrite(const buffer; count: longint): longint;
begin
 soc_write(handle,@buffer,count,result,0);
end;

{ tcustomsocketpipes }

procedure tcustomsocketpipes.createpipes;
begin
 frx:= tsocketreader.create(self);
 ftx:= tsocketwriter.create(self);
end;

end.
