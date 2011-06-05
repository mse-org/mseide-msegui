{ MSEgui Copyright (c) 2007-2011 by Martin Schreiber

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
 classes,mseglob,mseclasses,msesys,msestrings,msepipestream,
 mseapplication,msethread,mseevent,msecryptio,msetypes;

const
 defaultmaxconnections = 16;
 closepipestag = 836915;
 closeconnectiontag = closepipestag + 1;
  
type
 tcustomcommpipes = class;
 tcommreader = class;
 commpipeseventty = procedure(const sender: tcustomcommpipes) of object;

 icommserver = interface(inullinterface)
 end;
 icommclient = interface(iobjectlink)
  procedure setcommserverintf(const aintf: icommserver);
  function getobjectlinker: tobjectlinker;
  procedure dorxchange(const areader: tcommreader);
 end;
 icommclientarty = array of icommclient;
  
 tcommreader = class(tpipereader)
  private
   ftimeoutms: integer;
   fonthreadterminate: proceventty;
  protected
   fowner: tcustomcommpipes;
   fcrypt: pcryptioinfoty;
   fonafterconnect: proceventty;
   procedure settimeoutms(const avalue: integer); virtual;
   function execthread(thread: tmsethread): integer; override;
   function internalread(var buf; const acount: integer;
                    const nonblocked: boolean = false): integer; virtual;
   function doread(var buf; const acount: integer;
                    const nonblocked: boolean = false): integer; override;
   procedure dochange; override;
  public
   constructor create(const aowner: tcustomcommpipes);
   property timeoutms: integer read ftimeoutms write settimeoutms;
 end;
 
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

 tcommwriter = class(tpipewriter)
  private
   ftimeoutms: integer;
   procedure settimeoutms(const avalue: integer); virtual;
  protected
   fowner: tcustomcommpipes;
   fcrypt: pcryptioinfoty;
   function internalwrite(const buffer; count: longint): longint; virtual;
   function dowrite(const buffer; count: longint): longint; override;
  public
   constructor create(const aowner: tcustomcommpipes);
   property timeoutms: integer read ftimeoutms write settimeoutms;
 end;
 
 tsocketwriter = class(tcommwriter)
  protected
   procedure settimeoutms(const avalue: integer); override;
   procedure closehandle(const ahandle: integer); override;
   function internalwrite(const buffer; count: longint): longint; override;
 end;
 
 tcustomcommcomp = class;
 
 socketpipesstatety = (sops_open,sops_closing,sops_detached,sops_releasing);
 socketpipesstatesty = set of socketpipesstatety;
 
 tcustomcommpipes = class(tlinkedpersistent,ievent)
  private
   foninputavailable: commpipeseventty;
   foncommbroken: commpipeseventty;
   fowner: tcustomcommcomp;
   fonbeforeconnect: commpipeseventty;
   fonafterconnect: commpipeseventty;
   fonbeforedisconnect: commpipeseventty;
   fonafterdisconnect: commpipeseventty;
   function gethandle: integer;
   procedure sethandle(const avalue: integer);
   function getoverloadsleepus: integer;
   procedure setoverloadsleepus(const avalue: integer);
   procedure setoninputavailable(const avalue: commpipeseventty);
   procedure doinputavailable(const sender: tpipereader);
   procedure dopipebroken(const sender: tpipereader);   
   procedure internalclose;
   function getoptionsreader: pipereaderoptionsty;
   procedure setoptionsreader(const avalue: pipereaderoptionsty);
   function getrxtimeoutms: integer;
   procedure setrxtimeoutms(const avalue: integer);
   function gettxtimeoutms: integer;
   procedure settxtimeoutms(const avalue: integer);
   procedure dorxchange(const areader: tcommreader);
  protected
   fstate: socketpipesstatesty;
   frx: tcommreader;
   ftx: tcommwriter;
   fcryptio: tcryptio;
   fcryptioinfo: cryptioinfoty;
   procedure createpipes; virtual; abstract;
   procedure doafterconnect; virtual;
   procedure dothreadterminate;
   procedure setcryptio(const acryptio: tcryptio);
   procedure receiveevent(const event: tobjectevent);
   property oncommbroken: commpipeseventty read foncommbroken 
                                                      write foncommbroken;
  public
   constructor create(const aowner: tcustomcommcomp;
                                 const acryptkind: cryptiokindty); reintroduce;
   destructor destroy; override;
   procedure close;
   procedure release;
   {
   procedure runhandlerapp(const commandline: filenamety);
                   //connects to input/output
                   }
   property handle: integer read gethandle write sethandle;
   property rx: tcommreader read frx;
   property tx: tcommwriter read ftx;
   property rxtimeoutms: integer read getrxtimeoutms write setrxtimeoutms;
   property txtimeoutms: integer read gettxtimeoutms write settxtimeoutms;
   
   property overloadsleepus: integer read getoverloadsleepus 
                  write setoverloadsleepus default -1;
            //checks application.checkoverload before calling oninputavaliable
            //if >= 0
   property optionsreader: pipereaderoptionsty read getoptionsreader 
                                 write setoptionsreader default [];
   property onbeforeconnect: commpipeseventty read fonbeforeconnect 
                                                      write fonbeforeconnect;
   property onafterconnect: commpipeseventty read fonafterconnect 
                                                      write fonafterconnect;
   property onbeforedisconnect: commpipeseventty read fonbeforedisconnect 
                                                      write fonbeforedisconnect;
   property onafterdisconnect: commpipeseventty read fonafterdisconnect 
                                                      write fonafterdisconnect;
   property oninputavailable: commpipeseventty read foninputavailable 
                                                   write setoninputavailable;
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
 commcompeventty = procedure(sender: tcustomcommcomp) of object;  
 
 tcustomcommcomp = class(tactcomponent,icommserver)
  private
   fclients: icommclientarty;
   fonbeforeconnect: commcompeventty;
   fonafterconnect: commcompeventty;
   fonbeforedisconnect: commcompeventty;
   fonafterdisconnect: commcompeventty;
   procedure setactive(const avalue: boolean);
   procedure setcryptio(const avalue: tcryptio);
  protected
   fhandle: integer;
   factive: boolean;
   fcryptio: tcryptio;
   procedure doactivated; override;
   procedure dodeactivated; override;
   procedure internalconnect; virtual; abstract;
   procedure internaldisconnect; virtual;
   procedure closepipes(const sender: tcustomcommpipes); virtual; abstract;
   procedure connect;
   procedure disconnect;
   procedure checkinactive;
   procedure doafterconnect(const sender: tcustomcommpipes);
   procedure loaded; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property active: boolean read factive write setactive default false;
   property cryptio: tcryptio read fcryptio write setcryptio;
   
   property onbeforeconnect: commcompeventty read fonbeforeconnect 
                                                write fonbeforeconnect;
   property onafterconnect: commcompeventty read fonafterconnect 
                                                write fonafterconnect;
   property onbeforedisconnect: commcompeventty read fonbeforedisconnect 
                                                write fonbeforedisconnect;
   property onafterdisconnect: commcompeventty read fonafterdisconnect 
                                                write fonafterdisconnect;
 end;

 socketpipesarty = array of tsocketpipes;
 tcustomsocketserver = class;

 tcustomsocketcomp = class(tcustomcommcomp)
 end;
 
 tsocketcomp = class(tcustomsocketcomp)
  published
   property active;
   property activator;
   property cryptio;   
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
   property cryptio;   
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
   property cryptio;   
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
   function getcryptiokind: cryptiokindty;
   procedure setcryptiokind(const avalue: cryptiokindty);
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
   property cryptiokind: cryptiokindty read getcryptiokind write setcryptiokind
                             default cyk_none;
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
   property cryptio;   
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

procedure connectcryptio(const acryptio: tcryptio; const tx: tcommwriter;
                         const rx: tcommreader;
                         var cryptioinfo: cryptioinfoty;
                         txfd: integer = invalidfilehandle;
                         rxfd: integer = invalidfilehandle);
procedure socketerror(const error: syserrorty; const text: string = '');

procedure setcomcomp(const alink: icommclient; const acommcomp: tcustomcommcomp;
                                   var dest: tcustomcommcomp);

implementation
uses
 msefileutils,msesysintf,sysutils,msestream,mseprocutils,msesysutils,
 msesocketintf,msedatalist;

procedure setcomcomp(const alink: icommclient;
               const acommcomp: tcustomcommcomp; var dest: tcustomcommcomp);
begin
 alink.setcommserverintf(nil);
 if dest <> nil then begin
  removeitem(pointerarty(dest.fclients),pointer(alink));
 end;
 alink.getobjectlinker.setlinkedvar(alink,acommcomp,tmsecomponent(dest));
 if dest <> nil then begin
  additem(pointerarty(dest.fclients),pointer(alink));
  alink.setcommserverintf(icommserver(dest));
 end;
end;

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

procedure connectcryptio(const acryptio: tcryptio; const tx: tcommwriter;
                         const rx: tcommreader;
                         var cryptioinfo: cryptioinfoty;
                         txfd: integer = invalidfilehandle;
                         rxfd: integer = invalidfilehandle);
begin
 if (acryptio <> nil) and (cryptioinfo.kind <> cyk_none) then begin
  if txfd = invalidfilehandle then begin
   txfd:= tx.handle;
  end;
  if rxfd = invalidfilehandle then begin
   rxfd:= rx.handle;
  end;
  tx.fcrypt:= @cryptioinfo;
  rx.fcrypt:= @cryptioinfo;
  acryptio.link(txfd,rxfd,cryptioinfo);
  if cryptioinfo.kind = cyk_server then begin
   cryptaccept(cryptioinfo,rx.timeoutms);
  end
  else begin
   cryptconnect(cryptioinfo,rx.timeoutms);
  end;
 end
 else begin
  tx.fcrypt:= nil;
  rx.fcrypt:= nil;
 end;
end;

{ tcustomcommpipes }

constructor tcustomcommpipes.create(const aowner: tcustomcommcomp; 
                                              const acryptkind: cryptiokindty);
begin
 fowner:= aowner;
 createpipes;
// frx:= tsocketreader.create;
 frx.fonafterconnect:= {$ifdef FPC}@{$endif}doafterconnect;
 frx.onpipebroken:= {$ifdef FPC}@{$endif}dopipebroken;
 frx.fonthreadterminate:= {$ifdef FPC}@{$endif}dothreadterminate;
// ftx:= tsocketwriter.create;
 setlinkedvar(aowner.fcryptio,tmsecomponent(fcryptio));
 fcryptioinfo.kind:= acryptkind;
end;

destructor tcustomcommpipes.destroy;
begin
 inherited;
 close;
 frx.free;
 ftx.free;
end;

procedure tcustomcommpipes.release;
begin
 if not (sops_releasing in fstate) then begin
  application.postevent(tobjectevent.create(ek_release,ievent(self)));
  include(fstate,sops_releasing);
 end;
end;

function tcustomcommpipes.gethandle: integer;
begin
 result:= ftx.handle;
end;

procedure tcustomcommpipes.doafterconnect;
begin
 connectcryptio(fcryptio,ftx,frx,fcryptioinfo);
 if assigned(fonafterconnect) then begin
  fonafterconnect(self);
 end;  
end;

procedure tcustomcommpipes.dothreadterminate;
begin
 cryptthreadterminate(fcryptioinfo);
 //dummy
end;

procedure tcustomcommpipes.sethandle(const avalue: integer);
//var
// int1: integer;
begin
 ftx.releasehandle;
 ftx.handle:= avalue;
 frx.handle:= avalue;
 {
 int1:= avalue;
 if avalue <> invalidfilehandle then begin
  syserror(sys_dup(avalue,int1));
 end;
 frx.handle:= int1;
 }
 if avalue <> invalidfilehandle then begin
  include(fstate,sops_open);
 end
 else begin
  setcryptio(nil);
  exclude(fstate,sops_open);
 end;
end;

procedure tcustomcommpipes.setcryptio(const acryptio: tcryptio);
begin
 fcryptio:= acryptio;
 with fcryptioinfo do begin
  cryptunlink(fcryptioinfo);
  ftx.fcrypt:= nil;
  frx.fcrypt:= nil;
 end;
end;

function tcustomcommpipes.getoverloadsleepus: integer;
begin
 result:= frx.overloadsleepus;
end;

procedure tcustomcommpipes.setoverloadsleepus(const avalue: integer);
begin
 frx.overloadsleepus:= avalue;
end;

procedure tcustomcommpipes.setoninputavailable(const avalue: commpipeseventty);
begin
 foninputavailable:= avalue;
 if assigned(avalue) then begin
  frx.oninputavailable:= {$ifdef FPC}@{$endif}doinputavailable;
 end
 else begin
  frx.oninputavailable:= nil;
 end;
end;

procedure tcustomcommpipes.doinputavailable(const sender: tpipereader);
begin
 if fowner.canevent(tmethod(foninputavailable)) then begin
  foninputavailable(self);
 end;
end;

procedure tcustomcommpipes.receiveevent(const event: tobjectevent);
begin
 if (event is tuserevent) and (tuserevent(event).tag = closepipestag) then begin
  if assigned(foncommbroken) then begin
   foncommbroken(self);
  end
  else begin
   close;
  end;
 end
 else begin
  if event.kind = ek_release then begin
   free;
  end;
 end;
end;

procedure tcustomcommpipes.dopipebroken(const sender: tpipereader);
begin
 application.postevent(tuserevent.create(ievent(self),closepipestag));
end;

procedure tcustomcommpipes.internalclose;
begin
 fowner.closepipes(self);
end;

procedure tcustomcommpipes.close;
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

function tcustomcommpipes.getoptionsreader: pipereaderoptionsty;
begin
 result:= frx.options;
end;

procedure tcustomcommpipes.setoptionsreader(const avalue: pipereaderoptionsty);
begin
 frx.options:= avalue;
end;

function tcustomcommpipes.getrxtimeoutms: integer;
begin
 result:= frx.timeoutms;
end;

procedure tcustomcommpipes.setrxtimeoutms(const avalue: integer);
begin
 frx.timeoutms:= avalue;
end;

function tcustomcommpipes.gettxtimeoutms: integer;
begin
 result:= ftx.timeoutms;
end;

procedure tcustomcommpipes.settxtimeoutms(const avalue: integer);
begin
 ftx.timeoutms:= avalue;
end;

procedure tcustomcommpipes.dorxchange(const areader: tcommreader);
var
 int1: integer;
begin
 for int1:= 0 to high(fowner.fclients) do begin
  fowner.fclients[int1].dorxchange(areader);
 end;
end;

{
procedure tcustomcommpipes.runhandlerapp(const commandline: filenamety);
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
{ tcustomcommcomp }

constructor tcustomcommcomp.create(aowner: tcomponent);
begin
 fhandle:= invalidfilehandle;
 inherited;
end;

destructor tcustomcommcomp.destroy;
var
 int1: integer;
begin
 for int1:= 0 to high(fclients) do begin
  fclients[int1].setcommserverintf(nil);
 end;
 fclients:= nil; 
 inherited;
end;

procedure tcustomcommcomp.doactivated;
begin
 active:= true;
// if factive then begin
//  connect;
// end;
end;

procedure tcustomcommcomp.dodeactivated;
begin
 active:= false;
end;

procedure tcustomcommcomp.internaldisconnect;
begin
 fhandle:= invalidfilehandle;
 factive:= false;
end;

procedure tcustomcommcomp.checkinactive;
begin
 if not (csloading in componentstate) and active then begin
  raise exception.create('Socket must be inactive.');
 end;
end;

procedure tcustomcommcomp.setactive(const avalue: boolean);
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

procedure tcustomcommcomp.doafterconnect(const sender: tcustomcommpipes);
begin
 if canevent(tmethod(fonafterconnect)) then begin
  application.lock;
  try
   fonafterconnect(self);
  finally
   application.unlock;
  end;
 end; 
end;

procedure tcustomcommcomp.connect;
begin
 if canevent(tmethod(fonbeforeconnect)) then begin
  fonbeforeconnect(self);
 end;
 internalconnect;
end;

procedure tcustomcommcomp.disconnect;
begin
 if canevent(tmethod(fonbeforedisconnect)) then begin
  fonbeforedisconnect(self);
 end;
 internaldisconnect;
 if canevent(tmethod(fonafterdisconnect)) then begin
  fonafterdisconnect(self);
 end; 
end;

procedure tcustomcommcomp.setcryptio(const avalue: tcryptio);
begin
 setlinkedvar(avalue,tmsecomponent(fcryptio));
end;

procedure tcustomcommcomp.loaded;
begin
 inherited;
 if factive then begin
  connect;
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

function tsocketstdio.getcryptiokind: cryptiokindty;
begin
 result:= fpipes.fcryptioinfo.kind;
end;

procedure tsocketstdio.setcryptiokind(const avalue: cryptiokindty);
begin
 fpipes.fcryptioinfo.kind:= avalue;
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
  fpipes.setcryptio(fcryptio);
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
        setcryptio(fcryptio);
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
  end;
 end;
end;

procedure tcustomsocketserver.closepipes(const sender: tcustomcommpipes);
begin
 if (sender.rx.handle <> invalidfilehandle) or 
             (sops_detached in sender.fstate) then begin
  exclude(sender.fstate,sops_detached);
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

{ tcommreader }

constructor tcommreader.create(const aowner: tcustomcommpipes);
begin
 fowner:= aowner;
 inherited create;
 fstate:= fstate + [tss_haslink];
end;

procedure tcommreader.settimeoutms(const avalue: integer);
begin
 ftimeoutms:= avalue;
end;

function tcommreader.execthread(thread: tmsethread): integer;
var
 int1: integer;
begin                          
{$ifdef mse_debugsockets}
 debugout(self,'socketreader execthread');
{$endif}
 fthread:= tsemthread(thread);
 try
  if assigned(fonafterconnect) then begin
   try
    fonafterconnect;
   except
    include(fstate,tss_error);   
    include(fstate,tss_eof);
    doinputavailable;
    raise;
   end;
  end;
  with fthread do begin
   while not terminated and not (tss_error in fstate) do begin
    int1:= doread(fmsbuf,sizeof(fmsbuf));
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
 finally
  if assigned(fonthreadterminate) then begin
   fonthreadterminate;
  end;
 end;
{$ifdef mse_debugsockets}
 debugout(self,'socketreader exitthread');
{$endif}
end;

function tcommreader.internalread(var buf; const acount: integer;
               const nonblocked: boolean = false): integer;
begin
 result:= inherited doread(buf,acount,nonblocked);
end;

function tcommreader.doread(var buf; const acount: integer;
               const nonblocked: boolean = false): integer;
var
 int1: integer;
begin
 if fcrypt <> nil then begin
  if nonblocked then begin
   int1:= -1;
  end
  else begin
   int1:= 0;
  end;
  result:= cryptread(fcrypt^,@buf,acount,int1);
 end
 else begin  
  result:= internalread(buf,acount,nonblocked);
 end;
end;

procedure tcommreader.dochange;
begin
 fowner.dorxchange(self);
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

{ tcommwriter }

constructor tcommwriter.create(const aowner: tcustomcommpipes);
begin
 fowner:= aowner;
 inherited create;
end;

procedure tcommwriter.settimeoutms(const avalue: integer);
begin
 ftimeoutms:= avalue;
end;

function tcommwriter.internalwrite(const buffer; count: longint): longint;
begin
 result:= inherited dowrite(buffer,count);
end;

function tcommwriter.dowrite(const buffer; count: longint): longint;
begin
 if fcrypt <> nil then begin
  result:= cryptwrite(fcrypt^,@buffer,count,ftimeoutms);
 end
 else begin
  result:= internalwrite(buffer,count);
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
