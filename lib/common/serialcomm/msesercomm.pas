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
 msecryptio,msethread,mseevent,mseapplication,msesystypes,msetimer;
 
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
   fpipes: tcustomcommpipes;
   fcrypto: pcryptoioinfoty;
   fonafterconnect: proceventty;
   procedure settimeoutms(const avalue: integer); virtual;
   function execthread(thread: tmsethread): integer; override;
   function internalread(var buf; const acount: integer; out readcount: integer;
                    const nonblocked: boolean = false): boolean; virtual;
   function doread(var buf; const acount: integer; out readcount: integer;
                    const nonblocked: boolean = false): boolean; override;
   procedure dochange; override;
  public
   constructor create(const apipes: tcustomcommpipes);
   property timeoutms: integer read ftimeoutms write settimeoutms;
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
  protected
   function internalwrite(const buffer; count: longint): longint; override;
 end;
 
 tsercommreader = class(tcommreader)
  protected
   function internalread(var buf; const acount: integer; out readcount: integer;
                    const nonblocked: boolean = false): boolean; override;
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
   factiveafterload: boolean;
   fcryptoio: tcryptoio;
   procedure setactive(const avalue: boolean); override;
   procedure doactivated; override;
   procedure dodeactivated; override;
   procedure internalconnect; virtual; abstract;
   procedure internaldisconnect; virtual;
   procedure closepipes(const sender: tcustomcommpipes); virtual; abstract;
   procedure writedata(const adata: string);
   function trywritedata(const adata: string): syserrorty; virtual; abstract;
   procedure connect;
   procedure disconnect;
   procedure checkinactive;
   procedure doafterconnect(const sender: tcustomcommpipes);
   procedure loaded; override;
   function gethalfduplex: boolean; virtual;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function calctransmissiontime(const alength: integer): integer; virtual;
                    //us, 0 if not supported
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

 tasyncserport = class(tcustomrs232)
  protected
   
  public
   constructor create(const aowner: tmsecomponent;  //aowner can be nil
                                  const aoncheckabort: checkeventty = nil);
  published
   property commnr;
   property commname;
   property baud;
   property databits;
   property stopbit;
   property parity;
 end;

 sercommoptionty = (sco_halfduplex,sco_nopipe);
 sercommoptionsty = set of sercommoptionty;
  
 tcustomsercommcomp = class(tcustomcommcomp)
  private
   foptions: sercommoptionsty;
   procedure setpipes(const avalue: tsercommpipes);
   procedure setport(const avalue: tasyncserport);
   procedure setoptions(const avalue: sercommoptionsty);
  protected
   fpipes: tsercommpipes;
   fport: tasyncserport;
//   procedure writedata(const adata: string); override;
   function trywritedata(const adata: string): syserrorty; override;
   procedure internalconnect; override;
   procedure internaldisconnect; override;
   procedure closepipes(const sender: tcustomcommpipes); override;
   procedure doasyncevent(var atag: integer); override;
   function gethalfduplex: boolean; override;
  protected
   procedure doportopen;
   procedure doportclose;
 public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function calctransmissiontime(const alength: integer): integer; override;
   property pipes: tsercommpipes read fpipes write setpipes;
   property port: tasyncserport read fport write setport;
   property options: sercommoptionsty read foptions
                                        write setoptions default [];
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
 
 commresponseflagty = (crf_error,crf_timeout,crf_eof,crf_trunc,crf_writeerror);
 commresponseflagsty = set of commresponseflagty;
 tcustomsercommchannel = class;
 commresponseeventty = procedure(const sender: tcustomsercommchannel;
                var adata: string; var aflags: commresponseflagsty) of object;
 sercommchannelstatety = (sccs_pending,sccs_sync,sccs_eor);
 sercommchannelstatesty = set of sercommchannelstatety;
 
 tcustomsercommchannel = class(tmsecomponent,icommclient)
  private
   fsercomm: tcustomcommcomp;
   fserverintf: icommserver;
   fonresponse: commresponseeventty;
   ftimer: tsimpletimer;
   ftimeoutus: integer;
   fsem: semty;
   feor: string;
   procedure setsercomm(const avalue: tcustomcommcomp);
   procedure dotimer(const sender: tobject);
  protected
   fstate: sercommchannelstatesty;
   fexpected: integer;
   fsent: integer;
   fdata: string;
   fflags: commresponseflagsty;
   function internaltransmit(const adata: string;
           const aresponselength: integer; const atimeoutus: integer;
                     const sync: boolean; const aeor: boolean): syserrorty;
   procedure checksercomm;
   procedure doresponse; virtual;
    //icommclient
   procedure setcommserverintf(const aintf: icommserver);
   procedure dorxchange(const areader: tcommreader);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure clear;
   function transmit(const adata: string; const aresponselength: integer;
            const atimeoutus: integer = -1): syserrorty; virtual; overload; 
                                                                 //threadsafe
     //async, answer by onresponse
                      //0 -> timeoutus property,
                      //-1 -> timeoutus + guessed transmission time,
                      //-2 unlimited
   function transmiteor(const adata: string; const aresponselength: integer = 0;
            const atimeoutus: integer = -1): syserrorty; virtual; overload; 
                  //use EOR, async
   function transmit(const adata: string; const aresponselength: integer;
                                                       out aresult: string;
      const atimeoutus: integer = -1): commresponseflagsty; virtual; overload;
                        //synchronous, threadsafe
   function transmiteor(const adata: string; out aresult: string;
      const aresponselength: integer = 0; 
      const atimeoutus: integer = -1): commresponseflagsty; virtual; overload;
                        //use EOR, synchronous, threadsafe
   property sercomm: tcustomcommcomp read fsercomm write setsercomm;
   property timeoutus: integer read ftimeoutus write ftimeoutus default 0;
                        //0 -> unlimited,
   property onresponse: commresponseeventty read fonresponse write fonresponse;
   property eor: string read feor write feor; //end of record, default $0a
 end;

 tsercommchannel = class(tcustomsercommchannel)
  published
   property sercomm;
   property timeoutus;
   property eor;
   property onresponse;
 end;

 setupcommeventty = procedure(const sender: tobject;
                           const acomm: tcustomsercommcomp) of object;

 tasynsercommchannel = class(tcustomsercommchannel)
  private
   fonconnect: notifyeventty;
   fondisconnect: notifyeventty;
   fonsetupcomm: setupcommeventty;
   fconnected: boolean;
   fconnectafterload: boolean;
   function getsercomm: tcustomsercommcomp;
   procedure setsercomm(const avalue: tcustomsercommcomp);
   procedure setconnected(const avalue: boolean);
  protected
   procedure loaded; override;
   procedure setupcomm(const acomm: tcustomsercommcomp); virtual;
   procedure doconnect; virtual;
   procedure dodisconnect; virtual;
   property onconnect: notifyeventty read fonconnect write fonconnect;
   property ondisconnect: notifyeventty read fondisconnect write fondisconnect;
  public
   procedure connect; virtual;
   procedure disconnect; virtual;
  published
   property sercomm: tcustomsercommcomp read getsercomm write setsercomm;
   property onsetupcomm: setupcommeventty read fonsetupcomm write fonsetupcomm;
   property timeoutus;
   property eor;
   property onresponse;
   property connected: boolean read fconnected write setconnected
                                                           default false;
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
 msesys,msestream,msearrayutils,sysutils,msebits,msesysintf1,msestrings;
 
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
 fport.fnoclosehandle:= true;
 fport.fonopen:= @doportopen;
 fport.fonclose:= @doportclose;
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

procedure tcustomsercommcomp.doportopen;
begin
 if (fpipes.handle = invalidfilehandle) and 
               not (sco_nopipe in foptions) then begin
  fpipes.handle:= fport.handle;
 end;
 factive:= true;
end;

procedure tcustomsercommcomp.doportclose;
begin
 fpipes.handle:= msesystypes.invalidfilehandle;
 factive:= false;
end;

procedure tcustomsercommcomp.internalconnect;
begin
 if not (csdesigning in componentstate) then begin
  if not fport.open then begin
   componentexception(self,'Can not open comm port "'+fport.commpath+'".');
  end;
  {$ifdef unix}
  setfilenonblock(fport.handle,sco_nopipe in foptions);
  {$endif};
//  if not (sco_nopipe in foptions) then begin
//   fpipes.handle:= fport.handle;
//  end;
 end;
 factive:= true;
 doafterconnect(fpipes);
end;

procedure tcustomsercommcomp.internaldisconnect;
begin
 fpipes.handle:= msesystypes.invalidfilehandle;
 inherited;
 fport.close;
end;

procedure tcustomsercommcomp.closepipes(const sender: tcustomcommpipes);
begin
// if (csdestroying in componentstate) and application.ismainthread then begin
  disconnect;
// end
// else begin
//  asyncevent(closepipestag);
// end;
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

function tcustomsercommcomp.trywritedata(const adata: string): syserrorty;
begin
 result:= fpipes.tx.trywritebuffer(pointer(adata)^,length(adata));
end;

function tcustomsercommcomp.gethalfduplex: boolean;
begin
 result:= sco_halfduplex in foptions;
end;

function tcustomsercommcomp.calctransmissiontime(
                                         const alength: integer): integer;
begin
 result:= fport.transmissiontime(alength);
end;

procedure tcustomsercommcomp.setoptions(const avalue: sercommoptionsty);
begin
 foptions:= avalue;
 fport.fnoclosehandle:= not (sco_nopipe in foptions);
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
 inherited create(aowner,aoncheckabort);
 fvmin:= #1; //blocking until first byte
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
  if not (csreading in componentstate) then begin
   if avalue then begin
    connect;
   end
   else begin
    disconnect;
   end;
  end
  else begin
   factiveafterload:= avalue;
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
 if factiveafterload then begin
  active:= true;
 end;
end;

function tcustomcommcomp.gethalfduplex: boolean;
begin
 result:= false;
end;

function tcustomcommcomp.calctransmissiontime(const alength: integer): integer;
begin
 result:= 0;
end;

procedure tcustomcommcomp.writedata(const adata: string);
begin
 syserror(trywritedata(adata));
end;

{ tcommreader }

constructor tcommreader.create(const apipes: tcustomcommpipes);
begin
 fpipes:= apipes;
 inherited create;
 fstate:= fstate + [tss_haslink];
end;

procedure tcommreader.settimeoutms(const avalue: integer);
begin
 ftimeoutms:= avalue;
end;

function tcommreader.execthread(thread: tmsethread): integer;
var
 bo1: boolean;
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
    bo1:= doread(fmsbuf,sizeof(fmsbuf),fmsbufcount);
    if not terminated then begin
     if not bo1 then begin
      include(fstate,tss_error); //broken socket
     end;
     if (fmsbufcount > 0) or (tss_error in fstate) then begin
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
               out readcount: integer;
               const nonblocked: boolean = false): boolean;
begin
 result:= inherited doread(buf,acount,readcount,nonblocked);
end;

function tcommreader.doread(var buf; const acount: integer;
               out readcount: integer;
               const nonblocked: boolean = false): boolean;
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
  readcount:= cryptoread(fcrypto^,@buf,acount,int1);
  result:= readcount >= 0;
  if not result then begin
   readcount:= 0;
  end;
 end
 else begin  
  result:= internalread(buf,acount,readcount,nonblocked);
 end;
end;

procedure tcommreader.dochange;
begin
 fpipes.dorxchange(self);
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

{ tcustomsercommchannel }

constructor tcustomsercommchannel.create(aowner: tcomponent);
begin
 feor:= c_linefeed;
 sys_semcreate(fsem,0);
 ftimer:= tsimpletimer.create(0,{$ifdef FPC}@{$endif}dotimer,false,[to_single]);
 inherited;
end;

destructor tcustomsercommchannel.destroy;
begin
 clear;
 ftimer.free;
 sercomm:= nil;
 sys_semdestroy(fsem);
 inherited;
end;

procedure tcustomsercommchannel.setsercomm(const avalue: tcustomcommcomp);
begin
 if fsercomm <> avalue then begin
  setcomcomp(icommclient(self),avalue,fsercomm);
 end;
end;

procedure tcustomsercommchannel.setcommserverintf(const aintf: icommserver);
begin
 fserverintf:= aintf;
end;

procedure tcustomsercommchannel.doresponse;
begin
 if canevent(tmethod(fonresponse)) then begin
  fonresponse(self,fdata,fflags);
 end;
end;

procedure tcustomsercommchannel.dorxchange(const areader: tcommreader);
var
 bo1: boolean;
 int1: integer;
begin
 if sccs_pending in fstate then begin
  fdata:= fdata + areader.readdatastring;
  fflags:= [];
  if areader.eof then begin
   include(fflags,crf_eof);
  end;
  if sccs_eor in fstate then begin
   int1:= pos(feor,fdata);
   bo1:= int1 > 0;
   if bo1 then begin
    setlength(fdata,int1-1);
   end;
  end
  else begin
   bo1:= length(fdata) >= fexpected;
  end;
  if (fflags <> []) or bo1 then begin
   exclude(fstate,sccs_pending);
   if fsercomm.gethalfduplex then begin
    fdata:= copy(fdata,fsent+1,bigint);
    fexpected:= fexpected - fsent;
   end;
   if length(fdata) < fexpected then begin
    include(fflags,crf_trunc);
   end;
   ftimer.enabled:= false;
   if sccs_sync in fstate then begin
    sys_sempost(fsem);
   end
   else begin
    doresponse;
   end;
  end;
 end
 else begin
  areader.readdatastring; //drop the data
 end;
end;

procedure tcustomsercommchannel.dotimer(const sender: tobject);
begin
 fflags:= [crf_timeout];
 doresponse;
end;

function tcustomsercommchannel.internaltransmit(const adata: string;
               const aresponselength: integer; const atimeoutus: integer;
               const sync: boolean; const aeor: boolean): syserrorty;
var
 int1: integer;
begin
 result:= sye_ok;
 application.lock;
 try
  clear;
  checksercomm;
  if aeor and (feor = '') then begin
   componentexception(self,'No end of record marker');
  end;
  fsent:= length(adata);
  fexpected:= aresponselength;
  if fsercomm.gethalfduplex then begin
   fexpected:= fexpected+fsent;
  end;
  int1:= ftimeoutus;
  if atimeoutus <> 0 then begin
   int1:= atimeoutus;
  end;
  if atimeoutus = -2 then begin
   int1:= 0;
  end;
  if int1 = -1 then begin
   int1:= 2*fsercomm.calctransmissiontime(fexpected+fsent)+ftimeoutus;
  end;
  updatebit({$ifdef FPC}longword{$else}byte{$endif}(fstate),
                                                          ord(sccs_sync),sync);
  updatebit({$ifdef FPC}longword{$else}byte{$endif}(fstate),ord(sccs_eor),aeor);
  include(fstate, sccs_pending);
  result:= fsercomm.trywritedata(adata);
  if result = sye_ok then begin
   if sync then begin
    sys_semtrywait(fsem); //clear
    result:= application.semwait(fsem,int1);
    exclude(fstate, sccs_pending);
   end
   else begin  
    if int1 > 0 then begin
     ftimer.interval:= int1;
     ftimer.enabled:= true;
    end;
   end;
  end;
 finally
  application.unlock;
 end;
end;

function tcustomsercommchannel.transmit(const adata: string;
                  const aresponselength: integer; 
                  const atimeoutus: integer = -1): syserrorty;
begin
 result:= internaltransmit(adata,aresponselength,atimeoutus,false,false);
end;

function tcustomsercommchannel.transmit(const adata: string;
                      const aresponselength: integer;
                      out aresult: string;
                      const atimeoutus: integer = -1): commresponseflagsty;
                                                       //synchronous
begin
 case internaltransmit(adata,aresponselength,atimeoutus,true,false) of
  sye_ok: begin
   result:= fflags;
  end;
  sye_write: begin
   result:= [crf_writeerror];
  end;
  else begin  
   result:= [crf_timeout];
  end;
 end;
 aresult:= fdata;
end;

procedure tcustomsercommchannel.checksercomm;
begin
 if fsercomm = nil then begin
  componentexception(self,'No sercomm.');
 end;
 if not fsercomm.active then begin
  componentexception(self,'sercomm inactive.');
 end;  
end;

procedure tcustomsercommchannel.clear;
begin
 ftimer.enabled:= false;
 fdata:= '';
 fstate:= fstate-[sccs_pending];
end;

function tcustomsercommchannel.transmiteor(const adata: string;
               const aresponselength: integer = 0;
               const atimeoutus: integer = -1): syserrorty;
begin
 result:= internaltransmit(adata+feor,aresponselength,atimeoutus,false,true);
end;

function tcustomsercommchannel.transmiteor(const adata: string;
               out aresult: string; const aresponselength: integer = 0;
               const atimeoutus: integer = -1): commresponseflagsty;
begin
 case internaltransmit(adata+feor,aresponselength,atimeoutus,true,true) of
  sye_ok: begin
   result:= fflags;
  end;
  sye_write: begin
   result:= [crf_writeerror];
  end;
  else begin  
   result:= [crf_timeout];
  end;
 end;
 aresult:= fdata;
end;

{ tsercommreader }

function tsercommreader.internalread(var buf; const acount: integer;
               out readcount: integer;
               const nonblocked: boolean = false): boolean;
begin
 result:= tcustomsercommcomp(fpipes.fowner).port.piperead(buf,acount,readcount,
                                    nonblocked);
// result:= inherited internalread(buf,acount,readcount,nonblocked);
end;

{ tsercommwriter }

function tsercommwriter.internalwrite(const buffer; count: longint): longint;
begin
 result:= tcustomsercommcomp(fowner.fowner).port.pipewrite(buffer,count);
end;

{ tasynsercommchannel }

function tasynsercommchannel.getsercomm: tcustomsercommcomp;
begin
 result:= tcustomsercommcomp(inherited sercomm);
end;

procedure tasynsercommchannel.setsercomm(const avalue: tcustomsercommcomp);
begin
 if avalue = nil then begin
  connected:= false;
 end;
 inherited setsercomm(avalue);
 if (avalue <> nil) and not (csloading in componentstate) then begin
  setupcomm(avalue);
 end;
end;

procedure tasynsercommchannel.doconnect;
begin
 if canevent(tmethod(fonconnect)) then begin
  fonconnect(self);
 end;
end;

procedure tasynsercommchannel.dodisconnect;
begin
 if canevent(tmethod(fondisconnect)) then begin
  fondisconnect(self);
 end;
end;

procedure tasynsercommchannel.setconnected(const avalue: boolean);
begin
 if csloading in componentstate then begin
  fconnectafterload:= avalue;
 end
 else begin
  if fconnected <> avalue then begin
   if avalue then begin
    connect;
   end
   else begin
    disconnect;
   end;
  end;
 end;
end;

procedure tasynsercommchannel.loaded;
begin
 inherited;
 if fsercomm <> nil then begin
  setupcomm(tcustomsercommcomp(fsercomm));
 end;
 if fconnectafterload then begin
  connect;
 end;
end;

procedure tasynsercommchannel.setupcomm(const acomm: tcustomsercommcomp);
begin
 if canevent(tmethod(fonsetupcomm)) then begin
  fonsetupcomm(self,acomm);
 end;
end;

procedure tasynsercommchannel.connect;
begin
 if fsercomm <> nil then begin
  fsercomm.active:= true;
 end;
 fconnected:= true;
end;

procedure tasynsercommchannel.disconnect;
begin
 fconnected:= false;
end;

end.
