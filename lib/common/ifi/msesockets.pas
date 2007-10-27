unit msesockets;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 classes,mseguiglob,mseclasses,msesys,msestrings,msepipestream,mseapplication,msethread,
 mseevent;

const
 defaultmaxconnections = 16;
 closepipestag = 836915;
  
type
 tcustomsocketpipes = class;
 socketpipeseventty = procedure(const sender: tcustomsocketpipes) of object;

 tsocketreader = class(tpipereader)
  private
   ftimeoutms: integer;
   procedure settimeoutms(const avalue: integer);
  protected
   procedure closehandle(const ahandle: integer); override;
   function execthread(thread: tmsethread): integer; override;
   procedure sethandle(value: integer); override;
  public
   constructor create;
   property timeoutms: integer read ftimeoutms write settimeoutms;
 end;
 
 tsocketwriter = class(tpipewriter)
  private
   ftimeoutms: integer;
   procedure settimeoutms(const avalue: integer);
  protected
   procedure closehandle(const ahandle: integer); override;
  public
   property timeoutms: integer read ftimeoutms write settimeoutms;
 end;
 
 tsocketcomp = class;
 
 socketpipesstatety = (sops_open,sops_closing,sops_detached);
 socketpipesstatesty = set of socketpipesstatety;
 
 tcustomsocketpipes = class(tlinkedpersistent,ievent)
  private
   frx: tsocketreader;
   ftx: tsocketwriter;
   foninputavailable: socketpipeseventty;
   fonsocketbroken: socketpipeseventty;
   fowner: tsocketcomp;
   fonbeforeconnect: socketpipeseventty;
   fonafterconnect: socketpipeseventty;
   fonbeforedisconnect: socketpipeseventty;
   fonafterdisconnect: socketpipeseventty;
   fstate: socketpipesstatesty;
   function gethandle: integer;
   procedure sethandle(const avalue: integer);
   function getoverloadsleepus: integer;
   procedure setoverloadsleepus(const avalue: integer);
   procedure setoninputavailable(const avalue: socketpipeseventty);
   procedure doinputavailable(const sender: tpipereader);
   procedure dopipebroken(const sender: tpipereader);   
   procedure internalclose;
   function getoptionsreader: pipereaderoptionsty;
   procedure setoptionsreader(const avalue: pipereaderoptionsty);
   function getrxtimeoutms: integer;
   procedure setrxtimeoutms(const avalue: integer);
   function gettxtimeoutms: integer;
   procedure settxtimeoutms(const avalue: integer);
  protected
   procedure receiveevent(const event: tobjectevent);
   property onsocketbroken: socketpipeseventty read fonsocketbroken write fonsocketbroken;
  public
   constructor create(const aowner: tsocketcomp);
   destructor destroy; override;
   procedure close;
   {
   procedure runhandlerapp(const commandline: filenamety);
                   //connects to input/output
                   }
   property handle: integer read gethandle write sethandle;
   property rx: tsocketreader read frx;
   property tx: tsocketwriter read ftx;
   property rxtimeoutms: integer read getrxtimeoutms write setrxtimeoutms;
   property txtimeoutms: integer read gettxtimeoutms write settxtimeoutms;
   
   property overloadsleepus: integer read getoverloadsleepus 
                  write setoverloadsleepus default -1;
            //checks application.checkoverload before calling oninputavaliable
            //if >= 0
   property optionsreader: pipereaderoptionsty read getoptionsreader write setoptionsreader;
   property onbeforeconnect: socketpipeseventty read fonbeforeconnect 
                                                      write fonbeforeconnect;
   property onafterconnect: socketpipeseventty read fonafterconnect 
                                                      write fonafterconnect;
   property onbeforedisconnect: socketpipeseventty read fonbeforedisconnect 
                                                      write fonbeforedisconnect;
   property onafterdisconnect: socketpipeseventty read fonafterdisconnect 
                                                      write fonafterdisconnect;
   property oninputavailable: socketpipeseventty read foninputavailable write setoninputavailable;
 end;

 tsocketclient = class;
 
 tsocketpipes = class(tcustomsocketpipes)
  published
   property optionsreader;
   property overloadsleepus;
   property oninputavailable;
   property onsocketbroken;
 end;
 
 tclientsocketpipes = class(tsocketpipes)
 end;
 
 tsocketserver = class;
  
 tserversocketpipes = class(tcustomsocketpipes)
 end;
 socketpipesarty = array of tserversocketpipes;

 socketeventty = procedure(sender: tsocketcomp) of object;  
 
 tsocketcomp = class(tactcomponent)
  private
   fhandle: integer;
   furl: msestring;
   factive: boolean;
   fonbeforeconnect: socketeventty;
   fonafterconnect: socketeventty;
   fonbeforedisconnect: socketeventty;
   fonafterdisconnect: socketeventty;
   fkind: socketkindty;
   fport: word;
   procedure seturl(const avalue: filenamety);
   procedure setactive(const avalue: boolean);
  protected
   function getsockaddr: socketaddrty;
   procedure doactivated; override;
   procedure dodeactivated; override;
   procedure internalconnect; virtual; abstract;
   procedure internaldisconnect; virtual;
   procedure closepipes(const sender: tcustomsocketpipes); virtual; abstract;
   procedure connect;
   procedure disconnect;
   procedure checkinactive;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property active: boolean read factive write setactive;
   property kind: socketkindty read fkind write fkind;
   property url: filenamety read furl write seturl;
   property port: word read fport write fport;
   property activator;
   property onbeforeconnect: socketeventty read fonbeforeconnect 
                                                write fonbeforeconnect;
   property onafterconnect: socketeventty read fonafterconnect 
                                                write fonafterconnect;
   property onbeforedisconnect: socketeventty read fonbeforedisconnect 
                                                write fonbeforedisconnect;
   property onafterdisconnect: socketeventty read fonafterdisconnect 
                                                write fonafterdisconnect;
 end;

 tsocketclient = class(tsocketcomp)
  private
   procedure setpipes(const avalue: tclientsocketpipes);
  protected
   fpipes: tclientsocketpipes;
   procedure internalconnect; override;
   procedure internaldisconnect; override;
   procedure closepipes(const sender: tcustomsocketpipes); override;
   procedure doasyncevent(var atag: integer); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property pipes: tclientsocketpipes read fpipes write setpipes;
 end;

 tsocketstdio = class(tsocketcomp)
  private
   procedure setpipes(const avalue: tsocketpipes);
  protected
   fpipes: tsocketpipes;
   procedure internalconnect; override;
   procedure internaldisconnect; override;
   procedure closepipes(const sender: tcustomsocketpipes); override;
   procedure doasyncevent(var atag: integer); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property pipes: tsocketpipes read fpipes write setpipes;
 end;
 
 socketaccepteventty = procedure(const sender: tsocketserver;
                     const asocket: integer;
                     const addr: socketaddrty; var accept: boolean) of object;
 socketserverconnecteventty = procedure(const sender: tsocketserver;
                     const apipes: tcustomsocketpipes) of object;

 socketserverstatety = (sss_closepipespending);
 socketserverstatesty = set of socketserverstatety;
 
 tsocketserver = class(tsocketcomp)
  private
   fstate: socketserverstatesty;
   fthread: tmsethread;
   fmaxconnections: integer;
   fonaccept: socketaccepteventty;
   fonbeforechconnect: socketserverconnecteventty;
   fonafterchconnect: socketserverconnecteventty;
   fonbeforechdisconnect: socketserverconnecteventty;
   fonafterchdisconnect: socketserverconnecteventty;
   fpipes: socketpipesarty;
   foverloadsleepus: integer;
   foninputavailable: socketpipeseventty;
   fonsocketbroken: socketpipeseventty;
   fconnectioncount: integer;
   foptionsreader: pipereaderoptionsty;
   frxtimeoutms: integer;
   ftxtimeoutms: integer;
   function execthread(thread: tmsethread): integer;
  protected
   procedure internalconnect; override;
   procedure internaldisconnect; override;
   procedure closepipes(const sender: tcustomsocketpipes); override;
   procedure doasyncevent(var atag: integer); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure runhandlerapp(const asocket: integer; const acommandline: filenamety);
   property connectioncount: integer read fconnectioncount;
  published
   property maxconnections: integer read fmaxconnections write fmaxconnections 
                             default defaultmaxconnections;
   property rxtimeoutms: integer read frxtimeoutms write frxtimeoutms;
   property txtimeoutms: integer read ftxtimeoutms write ftxtimeoutms;
   
   property onaccept: socketaccepteventty read fonaccept write fonaccept;
   property onbeforechconnect: socketserverconnecteventty read fonbeforechconnect
                               write fonbeforechconnect;
   property onafterchconnect: socketserverconnecteventty read fonafterchconnect
                               write fonafterchconnect;
   property onbeforechdisconnect: socketserverconnecteventty read fonbeforechdisconnect
                               write fonbeforechconnect;
   property onafterchdisconnect: socketserverconnecteventty read fonafterchdisconnect
                               write fonafterchdisconnect;
   property overloadsleepus: integer read foverloadsleepus 
                  write foverloadsleepus default -1;
            //checks application.checkoverload before calling oninputavaliable
            //if >= 0
   property optionsreader: pipereaderoptionsty read foptionsreader write foptionsreader;
   property oninputavailable: socketpipeseventty read foninputavailable 
                                 write foninputavailable;
   property onsocketbroken: socketpipeseventty read fonsocketbroken 
                                 write fonsocketbroken;
 end;
   
procedure checksyserror(const aresult: integer);

implementation
uses
 msefileutils,msesysintf,sysutils,msestream,mseprocutils;
  
procedure checksyserror(const aresult: integer);
begin
 if aresult <> 0 then begin
  syserror(syelasterror);
 end;
end;

{ tcustomsocketpipes }

constructor tcustomsocketpipes.create(const aowner: tsocketcomp);
begin
 fowner:= aowner;
 frx:= tsocketreader.create;
 frx.onpipebroken:= @dopipebroken;
 ftx:= tsocketwriter.create;
end;

destructor tcustomsocketpipes.destroy;
begin
 inherited;
 close;
 frx.free;
 ftx.free;
end;

function tcustomsocketpipes.gethandle: integer;
begin
 result:= ftx.handle;
end;

procedure tcustomsocketpipes.sethandle(const avalue: integer);
var
 int1: integer;
begin
 ftx.handle:= avalue;
 int1:= avalue;
 if avalue <> invalidfilehandle then begin
  syserror(sys_dup(avalue,int1));
 end;
 frx.handle:= int1;
 if avalue <> invalidfilehandle then begin
  include(fstate,sops_open);
 end
 else begin
  exclude(fstate,sops_open);
 end;
end;

function tcustomsocketpipes.getoverloadsleepus: integer;
begin
 result:= frx.overloadsleepus;
end;

procedure tcustomsocketpipes.setoverloadsleepus(const avalue: integer);
begin
 frx.overloadsleepus:= avalue;
end;

procedure tcustomsocketpipes.setoninputavailable(const avalue: socketpipeseventty);
begin
 foninputavailable:= avalue;
 if assigned(avalue) then begin
  frx.oninputavailable:= @doinputavailable;
 end
 else begin
  frx.oninputavailable:= nil;
 end;
end;

procedure tcustomsocketpipes.doinputavailable(const sender: tpipereader);
begin
 if fowner.canevent(tmethod(foninputavailable)) then begin
  foninputavailable(self);
 end;
end;

procedure tcustomsocketpipes.receiveevent(const event: tobjectevent);
begin
 if (event is tuserevent) and (tuserevent(event).tag = closepipestag) then begin
  if assigned(fonsocketbroken) then begin
   fonsocketbroken(self);
  end
  else begin
   close;
  end;
 end;
end;

procedure tcustomsocketpipes.dopipebroken(const sender: tpipereader);
begin
 application.postevent(tuserevent.create(ievent(self),closepipestag));
end;

procedure tcustomsocketpipes.internalclose;
begin
 fowner.closepipes(self);
end;

procedure tcustomsocketpipes.close;
begin
 if fstate * [sops_open,sops_closing] = [sops_open] then begin
  include(fstate,sops_closing);
  try
   if fowner.canevent(tmethod(fonbeforedisconnect)) then begin
    fonbeforedisconnect(self);
   end;
   internalclose;
   if fowner.canevent(tmethod(fonafterdisconnect)) then begin
    fonafterdisconnect(self);
   end; 
  finally
   fstate:= fstate - [sops_closing,sops_open];
  end;
 end;
end;

function tcustomsocketpipes.getoptionsreader: pipereaderoptionsty;
begin
 result:= frx.options;
end;

procedure tcustomsocketpipes.setoptionsreader(const avalue: pipereaderoptionsty);
begin
 frx.options:= avalue;
end;

function tcustomsocketpipes.getrxtimeoutms: integer;
begin
 result:= frx.timeoutms;
end;

procedure tcustomsocketpipes.setrxtimeoutms(const avalue: integer);
begin
 frx.timeoutms:= avalue;
end;

function tcustomsocketpipes.gettxtimeoutms: integer;
begin
 result:= ftx.timeoutms;
end;

procedure tcustomsocketpipes.settxtimeoutms(const avalue: integer);
begin
 ftx.timeoutms:= avalue;
end;
{
procedure tcustomsocketpipes.runhandlerapp(const commandline: filenamety);
var
 rxha,txha: integer;
 str1: string;
begin
 rxha:= frx.handle;
 txha:= ftx.handle;
 frx.releasehandle;
 ftx.releasehandle;
 include(fstate,sops_detached);
 internalclose;
 execmse1(commandline,@rxha,@txha);
end;
}

{ tsocketcomp }

constructor tsocketcomp.create(aowner: tcomponent);
begin
 fhandle:= invalidfilehandle;
 inherited;
end;

destructor tsocketcomp.destroy;
begin
 inherited;
end;

procedure tsocketcomp.doactivated;
begin
 if factive then begin
  connect;
 end;
end;

procedure tsocketcomp.dodeactivated;
begin
 active:= false;
end;

procedure tsocketcomp.seturl(const avalue: filenamety);
begin
 checkinactive;
 furl:= avalue;
end;

procedure tsocketcomp.internaldisconnect;
begin
 fhandle:= invalidfilehandle;
 factive:= false;
end;

procedure tsocketcomp.checkinactive;
begin
 if not (csloading in componentstate) and active then begin
  raise exception.create('Socket must be inactive.');
 end;
end;

procedure tsocketcomp.setactive(const avalue: boolean);
begin
 if factive <> avalue then begin
  if not (csloading in componentstate) then begin
   if avalue then begin
    connect;
   end
   else begin
    disconnect;
   end;
  end
  else begin
   factive:= avalue;
  end;
 end;
end;

procedure tsocketcomp.connect;
begin
 if canevent(tmethod(fonbeforeconnect)) then begin
  fonbeforeconnect(self);
 end;
 internalconnect;
 if canevent(tmethod(fonafterconnect)) then begin
  fonafterconnect(self);
 end; 
end;

procedure tsocketcomp.disconnect;
begin
 if canevent(tmethod(fonbeforedisconnect)) then begin
  fonbeforedisconnect(self);
 end;
 internaldisconnect;
 if canevent(tmethod(fonafterdisconnect)) then begin
  fonafterdisconnect(self);
 end; 
end;

function tsocketcomp.getsockaddr: socketaddrty;
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
    syserror(sys_urltoaddr(result));
   end;
  end;
 end;  
end;

{ tsocketstdio }

constructor tsocketstdio.create(aowner: tcomponent);
begin
 if fpipes = nil then begin
  fpipes:= tsocketpipes.create(self);
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

procedure tsocketstdio.closepipes(const sender: tcustomsocketpipes);
begin
 asyncevent(closepipestag);
end;

procedure tsocketstdio.doasyncevent(var atag: integer);
begin
 if atag = closepipestag then begin
  disconnect;
 end;
end;

{ tsocketclient }

constructor tsocketclient.create(aowner: tcomponent);
begin
 if fpipes = nil then begin
  fpipes:= tclientsocketpipes.create(self);
 end;
 inherited;
end;

destructor tsocketclient.destroy;
begin
 fpipes.free;
 inherited;
end;

procedure tsocketclient.setpipes(const avalue: tclientsocketpipes);
begin
 fpipes.assign(avalue);
end;

procedure tsocketclient.internalconnect;
begin
 syserror(sys_opensocket(fkind,true,fhandle));
 try
  syserror(sys_connectsocket(fhandle,getsockaddr,fpipes.tx.timeoutms));
 except
  sys_closefile(fhandle);
  fhandle:= invalidfilehandle;
  raise;
 end;
 try
  fpipes.handle:= fhandle;
 except
  internaldisconnect;
  raise;
 end;
 factive:= true;
end;

procedure tsocketclient.internaldisconnect;
begin
 fpipes.handle:= invalidfilehandle;
 inherited
end;

procedure tsocketclient.closepipes(const sender: tcustomsocketpipes);
begin
 asyncevent(closepipestag);
end;

procedure tsocketclient.doasyncevent(var atag: integer);
begin
 if atag = closepipestag then begin
  disconnect;
 end;
end;

{ tsocketserver }

constructor tsocketserver.create(aowner: tcomponent);
begin
 fmaxconnections:= defaultmaxconnections;
 foverloadsleepus:= -1;
 inherited;
end;

destructor tsocketserver.destroy;
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

procedure tsocketserver.internalconnect;
begin
 syserror(sys_opensocket(sok_local,true,fhandle));
 try
  syserror(sys_bindsocket(fhandle,getsockaddr));
 except
  sys_closefile(fhandle);
  fhandle:= invalidfilehandle;
  raise;
 end;
 try
  syserror(sys_listen(fhandle,fmaxconnections));
 except
  internaldisconnect;
  raise;
 end;
 factive:= true;
 fthread:= tmsethread.create(@execthread);
end;

function tsocketserver.execthread(thread: tmsethread): integer;
var
 addr: socketaddrty;
 conn: integer;
 bo1: boolean;
 int1,int2: integer;
begin
 result:= 0;
 addr.kind:= fkind;
 addr.size:= sizeof(addr.platformdata);
 while not thread.terminated and (sys_accept(fhandle,true,conn,addr,0) = sye_ok) do begin
  if not thread.terminated then begin
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
      fpipes[int2]:= tserversocketpipes.create(self);
      inc(fconnectioncount);
      with fpipes[int2] do begin
       rx.timeoutms:= frxtimeoutms;
       tx.timeoutms:= ftxtimeoutms;
       optionsreader:= self.foptionsreader;
       overloadsleepus:= self.foverloadsleepus;
       oninputavailable:= self.foninputavailable;
       onsocketbroken:= self.fonsocketbroken;
       if canevent(tmethod(fonbeforechconnect)) then begin
        fonbeforechconnect(self,fpipes[int2]);
       end;
       handle:= conn;
       if canevent(tmethod(fonafterchconnect)) then begin
        fonafterchconnect(self,fpipes[int2]);
       end;
      end;
     end
     else begin
//      sys_shutdownsocket(conn,ssk_both);
      sys_closesocket(conn);
     end;
    finally
     application.unlock;
    end;
   except
    application.handleexception(self);
   end;
  end;
 end;
end;

procedure tsocketserver.internaldisconnect;
var
 int1: integer;
begin
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
  sys_shutdownsocket(fhandle,ssk_rx);
 end;
 if fthread <> nil then begin
  application.waitforthread(fthread);
 end;
 freeandnil(fthread);
 sys_closesocket(fhandle);
 inherited;
end;

procedure tsocketserver.closepipes(const sender: tcustomsocketpipes);
begin
 if (sender.rx.handle <> invalidfilehandle) or 
             (sops_detached in sender.fstate) then begin
  exclude(sender.fstate,sops_detached);
  if canevent(tmethod(fonbeforechdisconnect)) then begin
   fonbeforechdisconnect(self,sender);
  end;
  sender.tx.handle:= invalidfilehandle;
  dec(fconnectioncount);
  if not (sss_closepipespending in fstate) then begin
   include(fstate,sss_closepipespending);  
   asyncevent(closepipestag);
  end;
  if canevent(tmethod(fonafterchdisconnect)) then begin
   fonafterchdisconnect(self,sender);
  end;
 end;
end;

procedure tsocketserver.doasyncevent(var atag: integer);
var
 int1: integer;
begin
 if atag = closepipestag then begin
  exclude(fstate,sss_closepipespending);
  for int1:= 0 to high(fpipes) do begin
   if (fpipes[int1] <> nil) and 
               (fpipes[int1].tx.handle = invalidfilehandle) then begin
    freeandnil(fpipes[int1]);
   end;
  end;
 end;
end;

procedure tsocketserver.runhandlerapp(const asocket: integer;
               const acommandline: filenamety);
var
 int1,int2: integer;
begin
 syserror(sys_dup(asocket,int1));
 syserror(sys_dup(asocket,int2));
 execmse3(acommandline,@int1,@int2);
end;

{ tsocketreader }

constructor tsocketreader.create;
begin
 inherited;
 fstate:= fstate + [tss_nosigio,tss_unblocked];
end;

procedure tsocketreader.closehandle(const ahandle: integer);
begin
 sys_shutdownsocket(ahandle,ssk_rx);
 inherited;
end;

procedure tsocketreader.settimeoutms(const avalue: integer);
begin
 ftimeoutms:= avalue;
 if handle <> invalidfilehandle then begin
  sys_setsockrxtimeout(handle,avalue);
 end;
end;

function tsocketreader.execthread(thread: tmsethread): integer;
var
 int1: integer;
begin                          
 fthread:= tsemthread(thread);
 with fthread do begin
  while not terminated and not (tss_error in fstate) do begin
   sys_readsocket(handle,@fmsbuf,buflen,int1,ftimeoutms);
   if not terminated then begin
    if int1 <= 0 then begin
     include(fstate,tss_error); //broken socket
    end
    else begin
     fmsbufcount:= int1;
    end;
    if (int1 > 0) or (tss_error in fstate) then begin
     include(fstate,tss_pipeactive);
     doinputavailable;
     if not terminated and not (tss_error in fstate) then begin
      semwait;
     end;
    end;
   end;
  end;
  include(fstate,tss_eof);
 end;
 result:= 0;
end;

procedure tsocketreader.sethandle(value: integer);
begin
 if value <> invalidfilehandle then begin
  sys_setnonblocksocket(value,true);
 end;
 inherited;
end;

{ tsocketwriter }

procedure tsocketwriter.closehandle(const ahandle: integer);
begin
// sys_shutdownsocket(ahandle,ssk_tx);
 inherited;
end;

procedure tsocketwriter.settimeoutms(const avalue: integer);
begin
 ftimeoutms:= avalue;
 if handle <> invalidfilehandle then begin
  sys_setsocktxtimeout(handle,avalue);
 end;
end;

end.
