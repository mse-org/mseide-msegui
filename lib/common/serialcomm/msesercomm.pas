{ MSEgui Copyright (c) 2011-2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msesercomm;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 classes,mclasses,msecommport,mseclasses,mseglob,msepipestream,msetypes,
 msecryptio,msethread,mseevent,mseapplication,msesystypes;
 
const
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
   fcrypto: pcryptoioinfoty;
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


 tasyncserport = class(tcustomrs232)
  public
   constructor create(const aowner: tmsecomponent;  //aowner can be nil
                                  const aoncheckabort: checkeventty = nil);
  published
   property commnr;
   property baud;
   property databits;
   property stopbit;
   property parity;
 end;

 tcommwriter = class(tpipewriter)
  private
   ftimeoutms: integer;
  protected
   fowner: tcustomcommpipes;
   fcrypto: pcryptoioinfoty;
   procedure settimeoutms(const avalue: integer); virtual;
   function internalwrite(const buffer; count: longint): longint; virtual;
   function dowrite(const buffer; count: longint): longint; override;
  public
   constructor create(const aowner: tcustomcommpipes);
   property timeoutms: integer read ftimeoutms write settimeoutms;
 end;
  
 tsercommwriter = class(tcommwriter)
 end;
 
 tsercommreader = class(tcommreader)
 end;

 tcustomcommcomp = class;

 commpipesstatety = (cps_open,cps_closing,cps_detached,cps_releasing);
 commpipesstatesty = set of commpipesstatety;
    
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
   procedure dorxchange(const areader: tcommreader); virtual;
  protected
   fstate: commpipesstatesty;
   frx: tcommreader;
   ftx: tcommwriter;
   fcryptoio: tcryptoio;
   fcryptoioinfo: cryptoioinfoty;
   procedure createpipes; virtual; abstract;
   procedure doafterconnect; virtual;
   procedure dothreadterminate;
   procedure setcryptoio(const acryptoio: tcryptoio);
   procedure receiveevent(const event: tobjectevent);
   property oncommbroken: commpipeseventty read foncommbroken 
                                                      write foncommbroken;
  public
   constructor create(const aowner: tcustomcommcomp;
                                 const acryptkind: cryptoiokindty); reintroduce;
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

 tsercommpipes = class(tcustomcommpipes)
  protected
   procedure createpipes; override;
  published
   property optionsreader;
   property overloadsleepus;
   property oninputavailable;
   property oncommbroken;
 end;

 commcompeventty = procedure(sender: tcustomcommcomp) of object;  
 
 tcustomcommcomp = class(tactcomponent,icommserver)
  private
   fclients: icommclientarty;
   fonbeforeconnect: commcompeventty;
   fonafterconnect: commcompeventty;
   fonbeforedisconnect: commcompeventty;
   fonafterdisconnect: commcompeventty;
   procedure setcryptoio(const avalue: tcryptoio);
  protected
   fhandle: integer;
   factive: boolean;
   fcryptoio: tcryptoio;
   procedure setactive(const avalue: boolean); override;
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
   property cryptoio: tcryptoio read fcryptoio write setcryptoio;
   
   property onbeforeconnect: commcompeventty read fonbeforeconnect 
                                                write fonbeforeconnect;
   property onafterconnect: commcompeventty read fonafterconnect 
                                                write fonafterconnect;
   property onbeforedisconnect: commcompeventty read fonbeforedisconnect 
                                                write fonbeforedisconnect;
   property onafterdisconnect: commcompeventty read fonafterdisconnect 
                                                write fonafterdisconnect;
 end;

 sercommoptionty = (sco_halfduplex);
 sercommoptionsty = set of sercommoptionty;
  
 tcustomsercommcomp = class(tcustomcommcomp)
  private
   foptions: sercommoptionsty;
   procedure setpipes(const avalue: tsercommpipes);
   procedure setport(const avalue: tasyncserport);
  protected
   fpipes: tsercommpipes;
   fport: tasyncserport;
   procedure internalconnect; override;
   procedure internaldisconnect; override;
   procedure closepipes(const sender: tcustomcommpipes); override;
   procedure doasyncevent(var atag: integer); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property pipes: tsercommpipes read fpipes write setpipes;
   property port: tasyncserport read fport write setport;
   property options: sercommoptionsty read foptions write foptions;
 end;
 
 tsercommcomp = class(tcustomsercommcomp)
  published
   property pipes;
   property port;
   property active;
   property activator;
   property cryptoio;
   property options;
   property onbeforeconnect;
   property onafterconnect;
   property onbeforedisconnect;
   property onafterdisconnect;
 end;

procedure setcomcomp(const alink: icommclient; const acommcomp: tcustomcommcomp;
                                   var dest: tcustomcommcomp);
procedure connectcryptoio(const acryptoio: tcryptoio; const tx: tcommwriter;
                         const rx: tcommreader;
                         var cryptoioinfo: cryptoioinfoty;
                         txfd: integer = invalidfilehandle;
                         rxfd: integer = invalidfilehandle);
 
implementation
uses
 msesys,msestream,msearrayutils,sysutils;
 
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

procedure connectcryptoio(const acryptoio: tcryptoio; const tx: tcommwriter;
                         const rx: tcommreader;
                         var cryptoioinfo: cryptoioinfoty;
                         txfd: integer = invalidfilehandle;
                         rxfd: integer = invalidfilehandle);
begin
 if (acryptoio <> nil) and (cryptoioinfo.kind <> cyk_none) then begin
  if txfd = invalidfilehandle then begin
   txfd:= tx.handle;
  end;
  if rxfd = invalidfilehandle then begin
   rxfd:= rx.handle;
  end;
  tx.fcrypto:= @cryptoioinfo;
  rx.fcrypto:= @cryptoioinfo;
  acryptoio.link(txfd,rxfd,cryptoioinfo);
  if cryptoioinfo.kind = cyk_server then begin
   cryptoaccept(cryptoioinfo,rx.timeoutms);
  end
  else begin
   cryptoconnect(cryptoioinfo,rx.timeoutms);
  end;
 end
 else begin
  tx.fcrypto:= nil;
  rx.fcrypto:= nil;
 end;
end;

{ tcustomsercommcomp }

constructor tcustomsercommcomp.create(aowner: tcomponent);
begin
 if fpipes = nil then begin
  fpipes:= tsercommpipes.create(self,cyk_none); //todo: cyk_sercomm
 end;
 fport:= tasyncserport.create(self);
 inherited;
end;

destructor tcustomsercommcomp.destroy;
begin
 fport.free;
 fpipes.free;
 inherited;
end;

procedure tcustomsercommcomp.setpipes(const avalue: tsercommpipes);
begin
 fpipes.assign(avalue);
end;

procedure tcustomsercommcomp.internalconnect;
begin
 if not (csdesigning in componentstate) then begin
  fport.open;
  {$ifdef unix}
  setfilenonblock(fport.handle,false);
  {$endif};
  fpipes.handle:= fport.handle;
 end;
 factive:= true;
end;

procedure tcustomsercommcomp.internaldisconnect;
begin
 fpipes.handle:= msesystypes.invalidfilehandle;
 inherited;
 fport.close;
end;

procedure tcustomsercommcomp.closepipes(const sender: tcustomcommpipes);
begin
 if (csdestroying in componentstate) and application.ismainthread then begin
  disconnect;
 end
 else begin
  asyncevent(closepipestag);
 end;
end;

procedure tcustomsercommcomp.doasyncevent(var atag: integer);
begin
 if atag = closepipestag then begin
  disconnect;
 end;
end;

procedure tcustomsercommcomp.setport(const avalue: tasyncserport);
begin
 fport.assign(avalue);
end;

{ tsercommpipes }

procedure tsercommpipes.createpipes;
begin
 ftx:= tsercommwriter.create(self);
 frx:= tsercommreader.create(self);
end;

{ tasyncserport }

constructor tasyncserport.create(const aowner: tmsecomponent;
               const aoncheckabort: checkeventty = nil);
begin
 inherited;
 fvmin:= #1; //blocking
end;

{ tcustomcommpipes }

constructor tcustomcommpipes.create(const aowner: tcustomcommcomp; 
                                              const acryptkind: cryptoiokindty);
begin
 fowner:= aowner;
 createpipes;
// frx:= tsocketreader.create;
 frx.fonafterconnect:= {$ifdef FPC}@{$endif}doafterconnect;
 frx.onpipebroken:= {$ifdef FPC}@{$endif}dopipebroken;
 frx.fonthreadterminate:= {$ifdef FPC}@{$endif}dothreadterminate;
// ftx:= tsocketwriter.create;
 setlinkedvar(aowner.fcryptoio,tmsecomponent(fcryptoio));
 fcryptoioinfo.kind:= acryptkind;
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
 if not (cps_releasing in fstate) then begin
  application.postevent(tobjectevent.create(ek_release,ievent(self)));
  include(fstate,cps_releasing);
 end;
end;

function tcustomcommpipes.gethandle: integer;
begin
 result:= ftx.handle;
end;

procedure tcustomcommpipes.doafterconnect;
begin
 connectcryptoio(fcryptoio,ftx,frx,fcryptoioinfo);
 if assigned(fonafterconnect) then begin
  fonafterconnect(self);
 end;  
end;

procedure tcustomcommpipes.dothreadterminate;
begin
 cryptothreadterminate(fcryptoioinfo);
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
  include(fstate,cps_open);
 end
 else begin
  setcryptoio(nil);
  exclude(fstate,cps_open);
 end;
end;

procedure tcustomcommpipes.setcryptoio(const acryptoio: tcryptoio);
begin
 fcryptoio:= acryptoio;
 with fcryptoioinfo do begin
  cryptounlink(fcryptoioinfo);
  ftx.fcrypto:= nil;
  frx.fcrypto:= nil;
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
 if fstate * [cps_open,cps_closing] = [cps_open] then begin
  include(fstate,cps_closing);
  try
   if fowner.canevent(tmethod(fonbeforedisconnect)) then begin
    fonbeforedisconnect(self);
   end;
   internalclose;
   if fowner.canevent(tmethod(fonafterdisconnect)) then begin
    fonafterdisconnect(self);
   end; 
  finally
   fstate:= fstate - [cps_closing,cps_open];
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

procedure tcustomcommcomp.setcryptoio(const avalue: tcryptoio);
begin
 setlinkedvar(avalue,tmsecomponent(fcryptoio));
end;

procedure tcustomcommcomp.loaded;
begin
 inherited;
 if factive then begin
  connect;
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
 if fcrypto <> nil then begin
  if nonblocked then begin
   int1:= -1;
  end
  else begin
   int1:= 0;
  end;
  result:= cryptoread(fcrypto^,@buf,acount,int1);
 end
 else begin  
  result:= internalread(buf,acount,nonblocked);
 end;
end;

procedure tcommreader.dochange;
begin
 fowner.dorxchange(self);
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
 if fcrypto <> nil then begin
  result:= cryptowrite(fcrypto^,@buffer,count,ftimeoutms);
 end
 else begin
  result:= internalwrite(buffer,count);
 end;
end;

end.
