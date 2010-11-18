{ MSEgui Copyright (c) 2010 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}

//
// todo: optimize for realtime, remove the OOP approach where
// it degrades performance.
//

unit msesignal;
{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}
interface
uses
 msedatalist,mseclasses,classes,msetypes,msearrayprops,mseevent,msehash,
 msesys;
type
 tcustomsigcomp = class;
 tdoublesigcomp = class;
 tsigcontroller = class;
 
 {
 sigclientinfoty = record
  siginfo: siginfoty;
  client: isigclient;
 end;
}
 tcustomsigcomp = class(tmsecomponent)  
  protected
   procedure coeffchanged(const sender: tdatalist;
                                 const aindex: integer); virtual;
 end;

 tsigcomp = class(tcustomsigcomp)
 end;

 tdoubleinputconn = class;
 tdoubleoutputconn = class;
 
 inputconnarty = array of tdoubleinputconn;
 outputconnarty = array of tdoubleoutputconn;
 
 psighandlerinfoty = ^sighandlerinfoty;
 sighandlerprocty = procedure(const ainfo: psighandlerinfoty) of object;

 isigclient = interface(ievent)
  procedure initmodel;
  procedure clear;
  function getinputar: inputconnarty;
  function getoutputar: outputconnarty;
  function getnamepath: string;
  function gethandler: sighandlerprocty;
  function getzcount: integer;
  function getcomponent: tcomponent;
  procedure modelchange;
  function getsigcontroller: tsigcontroller;
 end;
 sigclientintfarty = array of isigclient;

 tdoublesigcomp = class(tsigcomp,isigclient)
  private
   fcontroller: tsigcontroller;
   procedure setcontroller(const avalue: tsigcontroller);
  protected
//   finfo: siginfoty;
//   procedure setsig1(const sender: tdoubleinputconn;
//                                    var asource: doublearty); virtual;
//   procedure setsig(const sender: tdoubleinputconn;
//                                    const asource: doublearty); virtual;
   procedure modelchange;
   procedure loaded; override;
   procedure lock;
   procedure unlock;
   
    //isigclient  
   procedure initmodel; virtual;
   function getinputar: inputconnarty; virtual;
   function getoutputar: outputconnarty; virtual;
   function gethandler: sighandlerprocty; virtual; abstract;
   function getzcount: integer; virtual;
   function getsigcontroller: tsigcontroller;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure clear; virtual;
  published
   property controller: tsigcontroller read fcontroller write setcontroller;
 end;
 
 tsigconn = class(tmsecomponent)
        //no solution found to link to streamed tpersistent or tobject,
        //fork of classes.pp necessary. :-(
 end;
 
 tdoubleconn = class(tsigconn) 
  protected
   fsigintf: isigclient;
   function getcontroller: tsigcontroller;
   procedure lock;
   procedure unlock;
  public
   constructor create(const aowner: tcomponent;
                     const asigintf: isigclient); reintroduce; virtual;
   property controller: tsigcontroller read getcontroller;
 end;
 
 doubleinputconnarty = array of tdoubleinputconn;
 
 tdoubleoutputconn = class(tdoubleconn)
  protected
   fdestinations: doubleinputconnarty;
  public
   constructor create(const aowner: tcomponent;
                     const asigintf: isigclient); override;
{
    //for systems without recursion
   procedure setsig1(var asource: doublearty); //asource is invalid afterwards
   procedure setsig(const asource: doublearty);
}
 end; 

 tdoubleinputconn = class(tdoubleconn)
  private
   fsource: tdoubleoutputconn;
   foffset: double;
   fgain: double;
   procedure setsource(const avalue: tdoubleoutputconn);
   procedure setoffset(const avalue: double);
   procedure setgain(const avalue: double);
   procedure setvalue(const avalue: double);
  protected
   fvalue: double;
//   fbuffer: doublearty;
//   fhasdata: boolean;
  public
   constructor create(const aowner: tcomponent;
                     const asigintf: isigclient); override;
   destructor destroy; override;
   
    //for systems without recursion
//   procedure setsig1(var asource: doublearty); virtual; 
                       //asource is invalid afterwards
//   procedure setsig(const asource: doublearty); virtual;
  published
   property source: tdoubleoutputconn read fsource write setsource;
   property offset: double read foffset write setoffset;
   property gain: double read fgain write setgain;
   property value: double read fvalue write setvalue;  
 end;

 sighandlerinfoty = record
  dest: pdouble;
 end;

 psiginfoty = ^siginfoty;
 siginfopoarty = array of psiginfoty;
 signahdlerprocty = procedure(siginfo: psiginfoty);
 
 siginfostatety = (sis_checked,sis_input,sis_output{,sis_recursive});
 siginfostatesty = set of siginfostatety;
 
 inputstatety = (ins_checked,ins_recursive);
 inputstatesty = set of inputstatety;
 
 inputinfoty = record
  input: tdoubleinputconn;
  source: psiginfoty;
  state: inputstatesty;
 end;
 inputinfoarty = array of inputinfoty;
 
 siginfoty = record
  intf: isigclient;
  zcount: integer;
//  inp: double;
//  inps: doublearty;
//  inphigh: integer;
//  outps: doublepoarty;
//  outphigh: integer;
//  outpcount: integer;
  inputs: inputinfoarty;
  outputs: outputconnarty;
  destinations: inputconnarty;
  state: siginfostatesty;
  prev: siginfopoarty;
  connectedcount: integer;
  next: siginfopoarty;
 end;
 siginfoarty = array of siginfoty;
 
 destinfoty = record
  dest: pdouble;
  offset: double;
  gain: double;
  hasscale: boolean;
 end;
 destinfoarty = array of destinfoty;
 
 sighandlernodeinfoty = record
  handlerinfo: sighandlerinfoty;
  handler: sighandlerprocty;
  firstdest: destinfoty;
  dest: destinfoarty;
  desthigh: integer;
//  recursivebuffer: double;
 end;
 psighandlernodeinfoty = ^sighandlernodeinfoty;
 sighandlernodeinfoarty = array of sighandlernodeinfoty;
   
 tsigconnection = class(tdoublesigcomp)
 end;
 
 sigineventty = procedure(const sender: tobject;
                               var sig: real) of object; 
 siginbursteventty = procedure(const sender: tobject;
                               var sig: realarty) of object; 

 tsigin = class(tsigconnection)
  private
   foutput: tdoubleoutputconn;
   fvalue: double;
   finp: doublearty;
   foninput: sigineventty;
   foninputburst: siginbursteventty;
   finpindex: integer;
   procedure setvalue(const avalue: double);
  protected
   function getoutputar: outputconnarty; override;
    //isigclient
   function gethandler: sighandlerprocty; override;
   procedure sighandler(const ainfo: psighandlerinfoty);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy;
//   procedure setsig1(var asource: doublearty); //asource is invalid afterwards
   procedure siginput(const asource: doublearty);
   procedure clear; override;
  published
   property value: double read fvalue write setvalue;
   property oninput: sigineventty read foninput write foninput;
   property oninputburst: siginbursteventty read foninputburst write foninputburst;
 end;

 sigouteventty = procedure(const sender: tobject;
                               const sig: real) of object; 
 sigoutbursteventty = procedure(const sender: tobject;
                               const sig: realarty) of object; 
                              
 tsigout = class(tsigconnection)
  private
   finput: tdoubleinputconn;
   finputpo: pdouble;
   fonoutput: sigouteventty;
   fvalue: double;
   fonoutputburst: sigoutbursteventty;
   foutp: doublearty;
   foutpindex: integer;
   fbuffersize: integer;
   procedure setinput(const avalue: tdoubleinputconn);
   function getinput: tdoubleinputconn;
   procedure setbuffersize(const avalue: integer);
   function getvalue: double;
  protected
   function getinputar: inputconnarty; override;
   {
   procedure setsig1(const sender: tdoubleinputconn;
                                 var asource: doublearty); override;
   procedure setsig(const sender: tdoubleinputconn;
                                 const asource: doublearty); override;
   }
    //isigclient
   function gethandler: sighandlerprocty; override;
   procedure sighandler(const ainfo: psighandlerinfoty);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure clear; override;
   procedure sigoutput1(var adest: doublearty); //returns a data copy
   function sigoutput: doublearty;
//   property outp: doublearty read foutp;
   property value: double read getvalue;
  published
   property input: tdoubleinputconn read getinput write setinput;
   property buffersize: integer read fbuffersize 
                                              write setbuffersize default 0;
   property onoutput: sigouteventty read fonoutput write fonoutput;
   property onoutputburst: sigoutbursteventty read fonoutputburst 
                                              write fonoutputburst;
 end;
 
 trealcoeff = class(trealdatalist)
  protected
   fowner: tcustomsigcomp;
   procedure change(const aindex: integer); override;
  public
   constructor create(const aowner: tcustomsigcomp);
 end; 

 tcomplexcoeff = class(tcomplexdatalist)
  protected
   fowner: tcustomsigcomp;
   procedure change(const aindex: integer); override;
  public
   constructor create(const aowner: tcustomsigcomp); reintroduce;
 end; 

 tdoublezcomp = class(tdoublesigcomp) //single input, single output
  private
   procedure setinput(const avalue: tdoubleinputconn);
   procedure setoutput(const avalue: tdoubleoutputconn);
  protected
   fzcount: integer;
   fzhigh: integer;
   fdoublez: doublearty;
   fzindex: integer;
   finputindex: integer;
   fdoubleinputdata: doubleararty;
   finput: tdoubleinputconn;
   foutput: tdoubleoutputconn;
   function getinputar: inputconnarty; override;
   function getoutputar: outputconnarty; override;
   procedure setzcount(const avalue: integer);
//   procedure processinout(const acount: integer;
//                    var ainp,aoutp: pdouble); virtual; abstract;
   procedure zcountchanged; virtual;
   {
   procedure setsig1(const sender: tdoubleinputconn;
                                    var asource: doublearty); overload; override;
   procedure setsig(const sender: tdoubleinputconn;
                                    const asource: doublearty); overload; override;
   }
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure clear; override;
//   procedure setsig(const source: doublearty); overload;
//   procedure getsig1(var dest: doublearty); overload;
//   function getsig: doublearty;
//   procedure updatesig(var inout: doublearty);
   property zcount: integer read getzcount default 0;
   property output: tdoubleoutputconn read foutput write setoutput;
  published
   property input: tdoubleinputconn read finput write setinput;
 end;
{                           
 tdoubleinpconnitem = class(tsubcomponentitem)
  private
   function getitem: tdoubleinputconn;
   procedure setitem(const avalue: tdoubleinputconn);
  protected
   function createitem: tcomponent; override;
  published
   property item: tdoubleinputconn read getitem write setitem;
 end;
 }
 tdoubleinpconnarrayprop = class(tpersistentarrayprop)
  private
   fsigintf: isigclient;
   function getitems(const index: integer): tdoubleinputconn;
  protected
   procedure createitem(const index: integer; var item: tpersistent); override;
   procedure dosizechanged; override;
  public
   constructor create(const asigintf: isigclient); reintroduce;
   property items[const index: integer]: tdoubleinputconn read getitems; default;
 end;
 
 tsigmultiinp = class(tdoublesigcomp)
  private
   finputs: tdoubleinpconnarrayprop;
   procedure setinputs(const avalue: tdoubleinpconnarrayprop);
  protected
   finps: doublepoarty;
   finphigh: integer;
//   finpdatacount: integer;
   function getinputar: inputconnarty; override;
   procedure initmodel; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
//   procedure clear; override;
  published
   property inputs: tdoubleinpconnarrayprop read finputs write setinputs;
 end;

 tsigmultiinpout = class(tsigmultiinp)
  private
   foutput: tdoubleoutputconn;
    //local variables
//   dar: doublearty;
//   pdar: doublepoarty;
   procedure setoutput(const avalue: tdoubleoutputconn);
  protected
   function getoutputar: outputconnarty; override;
  public
   constructor create(aowner: tcomponent); override;
//   destructor destroy; override;
   property output: tdoubleoutputconn read foutput write setoutput;
 end;
 
 tsigadd = class(tsigmultiinpout)
  protected
//   procedure processinout(const acount: integer;
//             var ainp: doublepoarty; var aoutp: pdouble); override;
    //isigclient
   function gethandler: sighandlerprocty; override;
   procedure sighandler(const ainfo: psighandlerinfoty);
 end;

 tsigdelay = class(tsigadd)
  private
  protected
   fz: double;
   function getzcount: integer; override;
    //isigclient
   function gethandler: sighandlerprocty; override;
   procedure sighandler(const ainfo: psighandlerinfoty);
  public
   procedure clear; override;
 end;

 tsigdelayn = class(tsigadd)
  private
   fdelay: integer;
   finppo: integer;
   procedure setdelay(const avalue: integer);
  protected
   fz: doublearty;
   procedure initmodel; override;
   function getzcount: integer; override;
    //isigclient
   function gethandler: sighandlerprocty; override;
   procedure sighandler(const ainfo: psighandlerinfoty);
  public
   constructor create(aowner: tcomponent); override;
   procedure clear; override;
  published
   property delay: integer read fdelay write setdelay default 1;
 end;
  
 tdoublesigoutcomp = class(tdoublesigcomp)
  private
   foutput: tdoubleoutputconn;
   procedure setoutput(const avalue: tdoubleoutputconn);
  protected
   function getoutputar: outputconnarty; override;
  public
   constructor create(aowner: tcomponent); override;
   property output: tdoubleoutputconn read foutput write setoutput;
  published
 end;

 sigwavetableoptionty = (siwto_intpol);
 sigwavetableoptionsty = set of sigwavetableoptionty;
 
 tsigwavetable = class(tdoublesigoutcomp)
  private
   ffrequency: tdoubleinputconn;
   fphase: tdoubleinputconn;
   famplitude: tdoubleinputconn;
   ftable: doublearty;
   ftablelength: integer;
   ftime: double;
   ffrequencypo: pdouble;
   fphasepo: pdouble;
   famplitudepo: pdouble;
   foninittable: siginbursteventty;
   foptions: sigwavetableoptionsty;
   procedure setfrequency(const avalue: tdoubleinputconn);
   procedure setphase(const avalue: tdoubleinputconn);
   procedure setamplitude(const avalue: tdoubleinputconn);
   procedure settable(const avalue: doublearty);
   procedure setoptions(const avalue: sigwavetableoptionsty);
  protected
   procedure checktable;
   procedure sighandler(const ainfo: psighandlerinfoty);
   procedure sighandlerintpol(const ainfo: psighandlerinfoty);
    //isigclient
   function gethandler: sighandlerprocty; override;
   procedure initmodel; override;
   function getinputar: inputconnarty; override;
   function getzcount: integer; override;
  public
   constructor create(aowner: tcomponent); override;
   procedure clear; override;
   property table: doublearty read ftable write settable;
  published
   property frequency: tdoubleinputconn read ffrequency write setfrequency;
   property phase: tdoubleinputconn read fphase write setphase;
   property amplitude: tdoubleinputconn read famplitude write setamplitude;
   property oninittable: siginbursteventty read foninittable write foninittable;
   property options: sigwavetableoptionsty read foptions 
                                           write setoptions default [];
 end;
 
 tsigmult = class(tsigmultiinpout)
  protected
//   procedure processinout(const acount: integer;
//             var ainp: doublepoarty; var aoutp: pdouble); override;
    //isigclient
   function gethandler: sighandlerprocty; override;
   procedure sighandler(const ainfo: psighandlerinfoty);
 end;

 sigcontrollerstatety = (scs_modelvalid);
 sigcontrollerstatesty = set of sigcontrollerstatety;
 
 tsiginfohash = class(tpointerptruinthashdatalist)
 end;

 tsigcontroller = class(tmsecomponent)
  private
   finphash: tsiginfohash;
   foutphash: tsiginfohash;
   fvaluedummy: double;
   fmutex: mutexty;
  protected
   fstate: sigcontrollerstatesty;
   fclients: sigclientintfarty;
   finfos: siginfoarty;
   finputnodes: siginfopoarty;
   foutputnodes: siginfopoarty;
   fexecinfo: sighandlernodeinfoarty;
   fexechigh: integer;
  {$ifdef mse_debugsignal}
   procedure debugnodeinfo(const atext: string; const anode: psiginfoty);
   procedure debugpointer(const atext: string; const apointer: pointer);
  {$endif}
   procedure addclient(const aintf: isigclient);
   procedure removeclient(const aintf: isigclient);
   procedure updatemodel;
   function findinplink(const dest,source: psiginfoty): integer;
   procedure internalstep;
   procedure loaded; override;
   function findinp(const aconn: tsigconn): psiginfoty;
   function findoutp(const aconn: tsigconn): psiginfoty;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure modelchange;
   procedure checkmodel;
   procedure step(const acount: integer=1);
   procedure clear;
   procedure lock;
   procedure unlock;
 end;
 
procedure createsigbuffer(var abuffer: doublearty; const asize: integer);
procedure createsigarray(out abuffer: doublearty; const asize: integer);
procedure setsourceconn(const sender: tmsecomponent;
              const avalue: tdoubleoutputconn; var dest: tdoubleoutputconn);
procedure setsigcontroller(const linker: tobjectlinker; 
          const intf: isigclient; 
          const source: tsigcontroller; var dest: tsigcontroller);
 
implementation
uses
 sysutils,mseformatstr,msesysutils,msesysintf;
type
 tmsecomponent1 = class(tmsecomponent);
  
procedure createsigbuffer(var abuffer: doublearty; const asize: integer);
begin
 if (length(abuffer) < asize) or 
         (psizeint(pchar(pointer(abuffer))-2*sizeof(sizeint))^ > 1) then begin
  abuffer:= nil;
  allocuninitedarray(asize,sizeof(double),abuffer);
 end
 else begin
  setlength(abuffer,asize);
 end;
end;

procedure createsigarray(out abuffer: doublearty; const asize: integer);
begin
 abuffer:= nil;
 allocuninitedarray(asize,sizeof(double),abuffer);
end;

procedure setsourceconn(const sender: tmsecomponent;
              const avalue: tdoubleoutputconn; var dest: tdoubleoutputconn);
begin
 if dest <> nil then begin
  if csdestroying in dest.componentstate then begin
   dest.fdestinations:= nil;
  end
  else begin
   removeitem(pointerarty(dest.fdestinations),sender);
  end;
 end;
 tmsecomponent1(sender).setlinkedvar(avalue,tmsecomponent(dest));
 if dest <> nil then begin
  additem(pointerarty(dest.fdestinations),sender);
 end;
end;

{ trealcoeff }

constructor trealcoeff.create(const aowner: tcustomsigcomp);
begin
 fowner:= aowner;
 inherited create;
end;

procedure trealcoeff.change(const aindex: integer);
begin
 fowner.coeffchanged(self,aindex);
 inherited;
end;

{ tcomplexcoeff }

constructor tcomplexcoeff.create(const aowner: tcustomsigcomp);
begin
 fowner:= aowner;
 inherited create;
end;

procedure tcomplexcoeff.change(const aindex: integer);
begin
 fowner.coeffchanged(self,aindex);
 inherited;
end;

{ tcustomsigcomp }

procedure tcustomsigcomp.coeffchanged(const sender: tdatalist;
               const aindex: integer);
begin
 //dummy
end;

{ tdoublconn }

constructor tdoubleconn.create(const aowner: tcomponent;
                     const asigintf: isigclient);
begin
 fsigintf:= asigintf;
 inherited create(aowner);
 setsubcomponent(true);
end;

//{$ifndef FPC}
function tdoubleconn.getcontroller: tsigcontroller;
begin
 result:= fsigintf.getsigcontroller;
end;

procedure tdoubleconn.lock;
var
 cont1: tsigcontroller;
begin
 cont1:= fsigintf.getsigcontroller;
 if cont1 <> nil then begin
  cont1.lock;
 end;
end;

procedure tdoubleconn.unlock;
var
 cont1: tsigcontroller;
begin
 cont1:= fsigintf.getsigcontroller;
 if cont1 <> nil then begin
  cont1.unlock;
 end;
end;
//{$endif}

{ tdoubleoutputconn }

constructor tdoubleoutputconn.create(const aowner: tcomponent;
                     const asigintf: isigclient);
begin
 inherited;
 include (fmsecomponentstate,cs_subcompref);
 name:= 'output';
end;
{
procedure tdoubleoutputconn.setsig1(var asource: doublearty);
var
 int1: integer;
begin
 int1:= high(fdestinations);
 if int1 = 0 then begin
  fdestinations[0].setsig1(asource);
 end
 else begin
  for int1:= 0 to int1 do begin
   fdestinations[int1].setsig(asource);
  end;
 end;
end;

procedure tdoubleoutputconn.setsig(const asource: doublearty);
var
 int1: integer;
begin
 for int1:= 0 to high(fdestinations) do begin
  fdestinations[int1].setsig(asource);
 end;
end;
}
{ tdoubleinputconn }

constructor tdoubleinputconn.create(const aowner: tcomponent;
                     const asigintf: isigclient);
begin
 fgain:= 1;
 inherited;
 name:= 'input';
end;

destructor tdoubleinputconn.destroy;
begin
 source:= nil;
 inherited;
end;

procedure tdoubleinputconn.setsource(const avalue: tdoubleoutputconn);
begin
 if fsource <> avalue then begin
  setsourceconn(self,avalue,fsource);
  fsigintf.modelchange;
 end;
end;

procedure tdoubleinputconn.setoffset(const avalue: double);
begin
 lock;
 foffset:= avalue;
 unlock;
end;

procedure tdoubleinputconn.setgain(const avalue: double);
begin
 lock;
 fgain:= avalue;
 unlock;
end;

procedure tdoubleinputconn.setvalue(const avalue: double);
begin
 lock;
 fvalue:= avalue;
 unlock;
end;

{
procedure tdoubleinputconn.setsig1(var asource: doublearty);
begin
 fowner.setsig1(self,asource);
end;

procedure tdoubleinputconn.setsig(const asource: doublearty);
begin
 fowner.setsig(self,asource);
end;
}
{ tdoublesigcomp }

constructor tdoublesigcomp.create(aowner: tcomponent);
begin
 inherited;
end;
 
destructor tdoublesigcomp.destroy;
begin
 clear;
 inherited;
end;

procedure tdoublesigcomp.clear;
begin
 //dummy
end;
(*
procedure tdoublesigcomp.setsig1(const sender: tdoubleinputconn;
               var asource: doublearty);
begin
 //dummy
end;

procedure tdoublesigcomp.setsig(const sender: tdoubleinputconn;
               const asource: doublearty);
begin
 //dummy
end;
*)
procedure setsigcontroller(const linker: tobjectlinker; 
          const intf: isigclient; 
          const source: tsigcontroller; var dest: tsigcontroller);
begin
 if dest <> nil then begin
  dest.removeclient(intf);
 end;
 linker.setlinkedvar(intf,source,tmsecomponent(dest));
 if dest <> nil then begin
  dest.addclient(intf);
 end;
end;

procedure tdoublesigcomp.setcontroller(const avalue: tsigcontroller);
begin
 setsigcontroller(getobjectlinker,isigclient(self),avalue,fcontroller);
end;

procedure tdoublesigcomp.modelchange;
begin
 if ([csdestroying,csloading]*componentstate = []) then begin
  if (fcontroller <> nil) then begin
   if ([csdestroying,csloading]*fcontroller.componentstate = []) then begin
    fcontroller.modelchange;
   end;
  end
 end;
end;

function tdoublesigcomp.getinputar: inputconnarty;
begin
 result:= nil;
end;

function tdoublesigcomp.getoutputar: outputconnarty;
begin
 result:= nil;
end;

procedure tdoublesigcomp.loaded;
begin
 inherited;
 modelchange;
end;

procedure tdoublesigcomp.initmodel;
begin
 //dummy
end;

function tdoublesigcomp.getzcount: integer;
begin
 result:= 0;
end;

function tdoublesigcomp.getsigcontroller: tsigcontroller;
begin
 result:= fcontroller;
end;

procedure tdoublesigcomp.lock;
begin
 if fcontroller <> nil then begin
  fcontroller.lock;
 end;
end;

procedure tdoublesigcomp.unlock;
begin
 if fcontroller <> nil then begin
  fcontroller.unlock;
 end;
end;

{ tdoublezcomp }

constructor tdoublezcomp.create(aowner: tcomponent);
begin
 fzhigh:= -1;
 finput:= tdoubleinputconn.create(self,isigclient(self));
 foutput:= tdoubleoutputconn.create(self,isigclient(self));
 inherited;
end;

destructor tdoublezcomp.destroy;
begin
 inherited;
end;

procedure tdoublezcomp.zcountchanged;
begin
 //dummy
end;

procedure tdoublezcomp.clear;
begin
 inherited;
 fdoubleinputdata:= nil;
 finputindex:= 0;
 fillchar(pointer(fdoublez)^,fzcount*sizeof(double),0);
 fzindex:= 0; 
end;
{
procedure tdoublezcomp.setsig(const source: doublearty);
begin
 if finputindex > high(fdoubleinputdata) then begin
  setlength(fdoubleinputdata,finputindex+1);
 end;
 fdoubleinputdata[finputindex]:= source;
 inc(finputindex);
end;

procedure tdoublezcomp.updatesig(var inout: doublearty);
var
 po1,po2: pdouble;
begin
 po1:= pointer(inout);
 po2:= po1;
 processinout(length(inout),po1,po2);
end;

procedure tdoublezcomp.getsig1(var dest: doublearty);
var
 int1,int3: integer;
 po1,po2: pdouble;
begin
 int3:= 0;
 for int1:= 0 to finputindex-1 do begin
  int3:= int3 + high(fdoubleinputdata[int1]);
 end;
 int3:= int3 + finputindex;
 createsigbuffer(dest,int3);
 po2:= pointer(dest);
 for int1:= 0 to finputindex-1 do begin
  po1:= pointer(fdoubleinputdata[int1]);
  processinout(length(fdoubleinputdata[int1]),po1,po2);
 end;  
 for int1:= 0 to finputindex-1 do begin
  fdoubleinputdata[int1]:= nil;
 end;
 finputindex:= 0;
end;

function tdoublezcomp.getsig: doublearty;
begin
 getsig1(result);
end;

procedure tdoublezcomp.setsig1(const sender: tdoubleinputconn;
               var asource: doublearty);
var
 po1,po2: pdouble;
begin
 po1:= pointer(asource);
 po2:= po1;
 processinout(length(asource),po1,po2);
 foutput.setsig1(asource);
end;

procedure tdoublezcomp.setsig(const sender: tdoubleinputconn;
               const asource: doublearty);
var
 int1: integer;
 ar1: doublearty;
 po1,po2: pdouble;
begin
 int1:= length(asource);
 createsigarray(ar1,int1);
 po1:= pointer(asource);
 po2:= pointer(ar1);
 processinout(int1,po1,po2);
 foutput.setsig1(ar1);
end;
}
procedure tdoublezcomp.setzcount(const avalue: integer);
begin
 if fzcount <> avalue then begin
  if avalue < 0 then begin
   raise exception.create('Invalid coeffcount.');
  end;
  clear;
  fzcount:= avalue;
  fzhigh:= avalue - 1;
  setlength(fdoublez,avalue);
  zcountchanged;
 end;
end;

procedure tdoublezcomp.setinput(const avalue: tdoubleinputconn);
begin
 finput.assign(avalue);
end;

procedure tdoublezcomp.setoutput(const avalue: tdoubleoutputconn);
begin
 foutput.assign(avalue);
end;

function tdoublezcomp.getinputar: inputconnarty;
begin
 setlength(result,1);
 result[0]:= finput;
end;

function tdoublezcomp.getoutputar: outputconnarty;
begin
 setlength(result,1);
 result[0]:= foutput;
end;

{ tsigout }

constructor tsigout.create(aowner: tcomponent);
begin
 finput:= tdoubleinputconn.create(self,isigclient(self));
 finputpo:= @finput.fvalue;
 inherited;
end;

destructor tsigout.destroy;
begin
 inherited;
end;

procedure tsigout.setinput(const avalue: tdoubleinputconn);
begin
 finput.assign(avalue);
end;

function tsigout.getinput: tdoubleinputconn;
begin
 result:= finput;
end;
{
procedure tsigout.setsig1(const sender: tdoubleinputconn;
               var asource: doublearty);
begin
 foutp:= asource;
 if assigned(fonoutput) then begin
  fonoutput(self,foutp);
 end;
end;

procedure tsigout.setsig(const sender: tdoubleinputconn;
               const asource: doublearty);
begin
 foutp:= asource;
 if assigned(fonoutput) then begin
  fonoutput(self,foutp);
 end;
end;
}
function tsigout.getinputar: inputconnarty;
begin
 setlength(result,1);
 result[0]:= finput;
end;

function tsigout.gethandler: sighandlerprocty;
begin
 result:= {$ifdef FPC}@{$endif}sighandler;
end;

procedure tsigout.sighandler(const ainfo: psighandlerinfoty);
var
 po1: psizeint;
begin
 fvalue:= finputpo^;
 if assigned(fonoutput) then begin
  fonoutput(self,fvalue);
 end;
 if fbuffersize > 0 then begin
  if foutpindex = fbuffersize then begin
   foutpindex:= 0;
  end;
  po1:= psizeint(pchar(foutp)-2*sizeof(sizeint));
  if po1^ > 1 then begin //new buffer necessary
   dec(po1^); //no thread safety
  (*
  {$ifdef CPU64}
   interlockeddecrement64(po1^);
  {$else}
   interlockeddecrement(po1^);
  {$endif}
   if po1^ = 0 then begin
    freemem(po1);
   end;
  *)
   getmem(po1,fbuffersize * sizeof(double) + 2 * sizeof(sizeint));
   po1^:= 1; //refcount
   inc(po1);
   {$ifdef FPC}
   po1^:= fbuffersize - 1; //high
   {$else}
   po1^:= fbuffersize;     //count
   {$endif}
   inc(po1);
   if foutpindex > 0 then begin
    move(foutp[0],po1^,foutpindex*sizeof(double));
   end;
   pointer(foutp):= po1;
  end;
  foutp[foutpindex]:= fvalue;
  inc(foutpindex);
  if foutpindex = fbuffersize then begin
//   foutpindex:= 0;
   if assigned(fonoutputburst) then begin
    fonoutputburst(self,realarty(foutp));
   end;
  end;
 end;
end;

procedure tsigout.sigoutput1(var adest: doublearty);
var
 po1: psizeint;
begin
 if foutpindex > 0 then begin
  if adest = nil then begin
   getmem(po1,foutpindex * sizeof(double) + 2 * sizeof(sizeint));
   po1^:= 1; //referencount;
   inc(po1);
  {$ifdef FPC}
   po1^:= foutpindex-1; //high
  {$else}
   po1^:= foutpindex;   //length
  {$endif}
   inc(po1);
   pointer(adest):= po1;
  end
  else begin
   po1:= psizeint(pchar(adest)-2*sizeof(sizeint));
   if po1^ = 1 then begin
   {$ifdef FPC}
    if psizeint(pchar(po1)+1*sizeof(sizeint))^ < foutpindex - 1 then begin
   {$else}
    if psizeint(pchar(po1)+1*sizeof(sizeint))^ < foutpindex then begin
   {$endif}
     freemem(po1);  //new buffer
     getmem(po1,foutpindex * sizeof(double) + 2 * sizeof(sizeint)); 
     po1^:= 1; //referencount;
     inc(po1);
    {$ifdef FPC}
     po1^:= foutpindex-1; //high
    {$else}
     po1^:= foutpindex;   //length
    {$endif}
     inc(po1);
     pointer(adest):= po1;
    end
    else begin           //reduce buffer
    {$ifdef FPC}
     if psizeint(pchar(po1)+1*sizeof(sizeint))^ > foutpindex - 1 then begin
    {$else}
     if psizeint(pchar(po1)+1*sizeof(sizeint))^ > foutpindex then begin
    {$endif}
      reallocmem(po1,foutpindex * sizeof(double) + 2 * sizeof(sizeint));
      pointer(adest):= pchar(po1)+2*sizeof(sizeint);
     end;
    end;
   end
   else begin 
    getmem(po1,foutpindex * sizeof(double) + 2 * sizeof(sizeint)); //new buffer
    po1^:= 1; //referencount;
    inc(po1);
   {$ifdef FPC}
    po1^:= foutpindex-1; //high
   {$else}
    po1^:= foutpindex;   //length
   {$endif}
    inc(po1);
    pointer(adest):= po1;
   end;
  end;
  move(foutp[0],adest[0],foutpindex*sizeof(double));
 end
 else begin
  adest:= nil;
 end;
end;

function tsigout.sigoutput: doublearty;
begin
 sigoutput1(result);
end;

procedure tsigout.setbuffersize(const avalue: integer);
begin
 if fbuffersize <> avalue then begin
  fbuffersize:= avalue;
  clear;
 end;
end;

procedure tsigout.clear;
begin
 inherited;
 setlength(foutp,fbuffersize);
 foutpindex:= 0;
end;

function tsigout.getvalue: double;
begin
 lock;
 result:= fvalue;
 unlock;
end;

{ tsigin }

constructor tsigin.create(aowner: tcomponent);
begin
 foutput:= tdoubleoutputconn.create(self,isigclient(self));
 inherited;
end;

destructor tsigin.destroy;
begin
 inherited;
end;

procedure tsigin.siginput(const asource: doublearty);
var
 int1,int2,int3: integer;
 po1: psizeint;
begin
 int1:= length(finp);
 if int1 = 0 then begin
  finp:= asource;
 end
 else begin
  int1:= int1 - finpindex;
  if int1 > 0 then begin
   setlength(finp,length(finp)); //unique reference
   move(finp[finpindex],finp[0],int1*sizeof(double));
  end;
  finpindex:= 0;
  if asource <> finp then begin
   int2:= length(asource);
   int3:= int1+int2;
   po1:= psizeint(pchar(finp)-2*sizeof(sizeint));
   if po1^ <> 1 then begin
    dec(po1^); //no thread safety
    getmem(po1,int3*sizeof(double)+2*sizeof(sizeint));
    po1^:= 1;
    move(finp[0],(pchar(po1)+2*sizeof(sizeint))^,int1*sizeof(double));
   end
   else begin
   {$ifdef FPC}
    if psizeint(pchar(po1)+sizeof(sizeint))^ <> int3-1 then begin
   {$else}
    if psizeint(pchar(po1)+sizeof(sizeint))^ <> int3 then begin
   {$endif}
     reallocmem(po1,int3*sizeof(double)+2*sizeof(sizeint));
    end;
   end;
   inc(po1);
   {$ifdef FPC}
   po1^:= int3-1;   //high
   {$else}
   po1^:= int3; //length
   {$endif}
   inc(po1);
   pointer(finp):= po1;
   move(asource[0],finp[int1],int2*sizeof(double));
  end;
 end;
// foutput.setsig(asource);
end;
{
procedure tsigin.setsig1(var asource: doublearty);
begin
 foutput.setsig1(asource);
end;
}
function tsigin.getoutputar: outputconnarty;
begin
 setlength(result,1);
 result[0]:= foutput;
end;

function tsigin.gethandler: sighandlerprocty;
begin
 result:= {$ifdef FPC}@{$endif}sighandler;
end;

procedure tsigin.sighandler(const ainfo: psighandlerinfoty);
begin
 if finpindex <= high(finp) then begin
  fvalue:= finp[finpindex];
  inc(finpindex);
 end
 else begin
  if assigned(foninputburst) then begin
   foninputburst(self,realarty(finp));
   finpindex:= 0;
   if finp <> nil then begin
    fvalue:= finp[0];
    inc(finpindex);
   end;
  end;
 end;
 if assigned(foninput) then begin
  foninput(self,real(fvalue));
 end;
 ainfo^.dest^:= fvalue;
end;

procedure tsigin.clear;
begin
 inherited;
 finp:= nil;
 finpindex:= 0;
end;

procedure tsigin.setvalue(const avalue: double);
begin
 lock;
 fvalue:= avalue;
 unlock;
end;

{ tsigmultiinp }

constructor tsigmultiinp.create(aowner: tcomponent);
begin
// foutput:= tdoubleoutputconn.create(self);
 inherited;
 finputs:= tdoubleinpconnarrayprop.create(self);
end;

destructor tsigmultiinp.destroy;
begin
 inherited;
 finputs.free;
end;
(*
procedure tsigmultiinp.clear;
//var
// int1: integer;
begin
 dar:= nil;
 pdar:= nil;
// finpdatacount:= 0;
 inherited;
 {
 for int1:= 0 to high(finputs.fitems) do begin
  tdoubleinputconn(finputs.fitems[int1]).fbuffer:= nil;
 end;
 }
end;
*)

procedure tsigmultiinp.setinputs(const avalue: tdoubleinpconnarrayprop);
begin
 finputs.assign(avalue);
end;

{
procedure tsigmultiinp.setsig(const sender: tdoubleinputconn;
               const asource: doublearty);
begin
 dar:= copy(asource);
 setsig1(sender,dar);
end;

procedure tsigmultiinp.setsig1(const sender: tdoubleinputconn;
               var asource: doublearty);
var
 int1,int2,int3: integer;
 po1: pdouble;
begin
//todo: optimize
 stackarray(realarty(asource),realarty(sender.fbuffer));
 if not sender.fhasdata then begin
  sender.fhasdata:= true;
  inc(finpdatacount);
  if finpdatacount >= finputs.count then begin
   int2:= bigint;
   setlength(pdar,finputs.count);
   for int1:= 0 to high(finputs.fitems) do begin
    with tdoubleinputconn(finputs.fitems[int1]) do begin
     int3:= high(fbuffer);
     if int3 < int2 then begin
      int2:= int3;
     end;
     pdar[int1]:= pointer(fbuffer);
    end;
   end;
   inc(int2);
//   createsigbuffer(asource,int2);
   po1:= pointer(asource);
   processinout(int2,pdar,po1);
   for int1:= 0 to high(finputs.fitems) do begin
    with tdoubleinputconn(finputs.fitems[int1]) do begin
     if length(fbuffer) <= int2 then begin
      fbuffer:= nil;
      fhasdata:= false;
      dec(finpdatacount);
     end
     else begin
      move(fbuffer[int2],fbuffer[0],(length(fbuffer)-int2)*sizeof(double));
     end;
    end;
   end;
   foutput.setsig1(asource);
  end;
 end;
end;
}
function tsigmultiinp.getinputar: inputconnarty;
begin
 result:= inputconnarty(finputs.fitems);
end;

procedure tsigmultiinp.initmodel;
var
 int1: integer;
begin
 finphigh:= finputs.count-1;
 setlength(finps,finphigh+1);
 for int1:= 0 to finphigh do begin
  finps[int1]:= @tdoubleinputconn(finputs.fitems[int1]).fvalue;
 end;
end;

{ tsigmultiinpout }

constructor tsigmultiinpout.create(aowner: tcomponent);
begin
 foutput:= tdoubleoutputconn.create(self,isigclient(self));
 inherited;
end;

procedure tsigmultiinpout.setoutput(const avalue: tdoubleoutputconn);
begin
 foutput.assign(avalue);
end;

function tsigmultiinpout.getoutputar: outputconnarty;
begin
 setlength(result,1);
 result[0]:= foutput;
end;

{ tdoublesigoutcomp }

constructor tdoublesigoutcomp.create(aowner: tcomponent);
begin
 foutput:= tdoubleoutputconn.create(self,isigclient(self));
 inherited;
end;

procedure tdoublesigoutcomp.setoutput(const avalue: tdoubleoutputconn);
begin
 foutput.assign(avalue);
end;

function tdoublesigoutcomp.getoutputar: outputconnarty;
begin
 setlength(result,1);
 result[0]:= foutput;
end;

{ tdoubleinpconnarrayprop }

constructor tdoubleinpconnarrayprop.create(const asigintf: isigclient);
begin
 fsigintf:= asigintf;
 inherited create(nil);
end;

procedure tdoubleinpconnarrayprop.createitem(const index: integer;
               var item: tpersistent);
begin
 item:= tdoubleinputconn.create(nil,fsigintf);
end;

function tdoubleinpconnarrayprop.getitems(const index: integer): tdoubleinputconn;
begin
 result:= tdoubleinputconn(inherited getitems(index));
end;

procedure tdoubleinpconnarrayprop.dosizechanged;
begin
 inherited;
 fsigintf.modelchange;
end;

(*
{ tdoubleinpconnitem }

function tdoubleinpconnitem.createitem: tcomponent;
begin
 result:= tdoubleinputconn.create(tdoublesigcomp(fowner));
end;

function tdoubleinpconnitem.getitem: tdoubleinputconn;
begin
 result:= tdoubleinputconn(fitem);
end;

procedure tdoubleinpconnitem.setitem(const avalue: tdoubleinputconn);
begin
 fitem.assign(avalue);
end;
*)
{ tsigadd }
{
procedure tsigadd.processinout(const acount: integer; var ainp: doublepoarty;
               var aoutp: pdouble);
var
 int1,int2: integer;
 rea1: real;
begin
 for int1:= 0 to acount - 1 do begin
  rea1:= 0;
  for int2:= 0 to high(ainp) do begin
   rea1:= rea1 + ainp[int2]^;
   inc(ainp[int2]);
  end;
  aoutp^:= rea1;
  inc(aoutp);
 end;
end;
}
function tsigadd.gethandler: sighandlerprocty;
begin
 result:= {$ifdef FPC}@{$endif}sighandler;
end;

procedure tsigadd.sighandler(const ainfo: psighandlerinfoty);
var
 int1: integer;
begin
 ainfo^.dest^:= 0;
 for int1:= 0 to finphigh do begin
  ainfo^.dest^:= ainfo^.dest^ + finps[int1]^;
 end;
end;

{ tsigdelay }

function tsigdelay.getzcount: integer;
begin
 result:= 1;
end;

function tsigdelay.gethandler: sighandlerprocty;
begin
 result:= {$ifdef FPC}@{$endif}sighandler;
end;

procedure tsigdelay.sighandler(const ainfo: psighandlerinfoty);
var
 int1: integer;
begin
 ainfo^.dest^:= fz;
 fz:= 0;
 for int1:= 0 to finphigh do begin
  fz:= fz + finps[int1]^;
 end;
end;

procedure tsigdelay.clear;
begin
 fz:= 0;
end;

{ tsigdelayn }

constructor tsigdelayn.create(aowner: tcomponent);
begin
 fdelay:= 1;
 inherited;
end;

procedure tsigdelayn.initmodel;
begin
 inherited;
 finppo:= 0;
 setlength(fz,fdelay);
end;

procedure tsigdelayn.clear;
begin
 inherited;
 fillchar(fz[0],sizeof(fz[0])*length(fz),0);
end;

function tsigdelayn.getzcount: integer;
begin
 result:= fdelay;
end;

function tsigdelayn.gethandler: sighandlerprocty;
begin
 result:= {$ifdef FPC}@{$endif}sighandler;
end;

procedure tsigdelayn.sighandler(const ainfo: psighandlerinfoty);
var
 int1: integer;
 po1: pdouble;
begin
 if fdelay = 0 then begin
  ainfo^.dest^:= 0;
  for int1:= 0 to finphigh do begin
   ainfo^.dest^:= ainfo^.dest^ + finps[int1]^;
  end;
 end
 else begin
  po1:= @fz[finppo];
  po1^:= 0;
  for int1:= 0 to finphigh do begin
   po1^:= po1^ + finps[int1]^;
  end;
  inc(finppo);
  if finppo = fdelay then begin
   finppo:= 0;
  end;
 end;
end;

procedure tsigdelayn.setdelay(const avalue: integer);
begin
 if fdelay <> avalue then begin
  lock;
  modelchange;
  fdelay:= avalue;
  unlock;
 end;
end;

{ tsigmult }
{
procedure tsigmult.processinout(const acount: integer; var ainp: doublepoarty;
               var aoutp: pdouble);
var
 int1,int2: integer;
 rea1: real;
begin
 for int1:= 0 to acount - 1 do begin
  rea1:= 1;
  for int2:= 0 to high(ainp) do begin
   rea1:= rea1 * ainp[int2]^;
   inc(ainp[int2]);
  end;
  aoutp^:= rea1;
  inc(aoutp);
 end;
end;
}
function tsigmult.gethandler: sighandlerprocty;
begin
 result:= {$ifdef FPC}@{$endif}sighandler;
end;

procedure tsigmult.sighandler(const ainfo: psighandlerinfoty);
var
 int1: integer;
begin
 ainfo^.dest^:= 1;
 for int1:= 0 to finphigh do begin
  ainfo^.dest^:= ainfo^.dest^ * finps[int1]^;
 end;
end;

{ tsigcontroller }

constructor tsigcontroller.create(aowner: tcomponent);
begin
 syserror(sys_mutexcreate(fmutex),self);
 finphash:= tsiginfohash.create;
 foutphash:= tsiginfohash.create;
 inherited;
end;

destructor tsigcontroller.destroy;
begin
 inherited;
 finphash.free;
 foutphash.free;
 sys_mutexdestroy(fmutex);
end;

procedure tsigcontroller.addclient(const aintf: isigclient);
begin
 adduniqueitem(pointerarty(fclients),pointer(aintf));
 modelchange;
end;

procedure tsigcontroller.removeclient(const aintf: isigclient);
begin
 removeitem(pointerarty(fclients),pointer(aintf));
 modelchange;
end;

procedure tsigcontroller.modelchange;
begin
 exclude(fstate,scs_modelvalid);
end;

function tsigcontroller.findinp(const aconn: tsigconn): psiginfoty;
begin
 result:= finphash.find(ptruint(aconn));
end;

function tsigcontroller.findoutp(const aconn: tsigconn): psiginfoty;
begin
 result:= foutphash.find(ptruint(aconn));
end;

 {$ifdef mse_debugsignal}
procedure tsigcontroller.debugnodeinfo(const atext: string;
                                                   const anode: psiginfoty);
var
 str1: string;
begin
 if anode = nil then begin
  str1:= '<NIL>';
 end
 else begin
  str1:= anode^.intf.getnamepath + 
             ' conncount: '+inttostr(anode^.connectedcount);
 end; 
 debugwriteln(atext+str1);
end;

procedure tsigcontroller.debugpointer(const atext: string;
                                                   const apointer: pointer);
begin
 debugwriteln(atext+hextostr(apointer));
end;
{$endif}

function tsigcontroller.findinplink(const dest,source: psiginfoty): integer;
var
 int1: integer;
begin
 result:= -1;
 for int1:= 0 to high(dest^.inputs) do begin
  if dest^.inputs[int1].source = source then begin
   result:= int1;
   break;
  end;
 end;
end;

procedure tsigcontroller.updatemodel;
{$ifdef mse_debugsignal}
var
 indent: string;
{$endif}
 procedure resetchecked;
 var 
  int1,int2: integer;
 begin
  for int1:= 0 to high(finfos) do begin
   with finfos[int1] do begin
    exclude(state,sis_checked);
    for int2:= 0 to high(inputs) do begin
     exclude(inputs[int2].state,ins_checked);
    end;
   end;
  end;
 end; //resetchecked

var
 visited: pointerarty;
 
 procedure checkrecursion(const anode: psiginfoty);
 var
  int1,int2: integer;
  po1: psiginfoty;
  visitedbefore: pointerarty;
 {$ifdef mse_debugsignal}
  indentbefore: string;
 {$endif}
 begin
 {$ifdef mse_debugsignal}
  indentbefore:= indent;
  indent:= indent+' ';
  debugnodeinfo(indent+'node ',anode);
 {$endif}  
  additem(visited,anode);
  visitedbefore:= visited;
  with anode^ do begin
   for int1:= 0 to high(destinations) do begin
    visited:= visitedbefore;
    po1:= findinp(destinations[int1]);
    int2:= findinplink(po1,anode);
    if finditem(visited,po1) >= 0 then begin
     if zcount = 0 then begin
      raise exception.create('No Z-delay in recursion node '+intf.getnamepath+
             ' -> '+po1^.intf.getnamepath+'.');
     end
     else begin
      include(po1^.inputs[int2].state,ins_recursive);
      dec(po1^.connectedcount);
     end;
    end
    else begin
     include(po1^.inputs[int2].state,ins_checked);
     checkrecursion(po1);
    end;
   end;
  end;
  visited:= visitedbefore;
 {$ifdef mse_debugsignal}
  indent:= indentbefore;
 {$endif}  
 end; //checkrecursion

var
 execorder: siginfopoarty;
 execindex: integer;
 
 procedure processcalcorder(const anode: psiginfoty);
 var
  int1: integer;
  po1,po2: psiginfoty;
 {$ifdef mse_debugsignal}
  indentbefore: string;
 {$endif}
 begin
 {$ifdef mse_debugsignal}
  indentbefore:= indent;
  indent:= indent+' ';
  debugnodeinfo(inttostr(execindex)+indent+'calcnode ',anode);
 {$endif}   
  if execindex > high(execorder) then begin
   internalerror('SIG20100916-0');
  end;
  execorder[execindex]:= anode;
  inc(execindex);
  with anode^ do begin
   include(state,sis_checked);
   for int1:= 0 to high(next) do begin
    po1:= next[int1];
   {$ifdef mse_debugsignal}
    debugnodeinfo(indent+' dest '+booltostr(sis_checked in po1^.state)+' ',po1);
   {$endif}   
    if not (sis_checked in po1^.state) then begin
     if not (ins_recursive in po1^.inputs[findinplink(po1,anode)].state) then begin
      dec(po1^.connectedcount);
      if po1^.connectedcount <= 0 then begin
       processcalcorder(po1);
      end;
     end;
    end;
   end;
  end;
 {$ifdef mse_debugsignal}
  indent:= indentbefore;
 {$endif}  
 end; //processcalcorder

 procedure updatedestinfo(const ainput: tdoubleinputconn;
                                        var ainfo: destinfoty);
 begin
  ainfo.dest:= @ainput.fvalue;
  ainfo.offset:= ainput.offset;
  ainfo.gain:= ainput.gain;
  ainfo.hasscale:= (ainfo.offset <> 0) or (ainfo.gain <> 1);
 end; //updatedestinfo

 function isopeninput(const ainputs: inputinfoarty): boolean;
 var
  int1: integer;
 begin
  result:= true;
  for int1:= 0 to high(ainputs) do begin
   if ainputs[int1].source <> nil then begin
    result:= false;
    break;
   end;
  end;
 end;
 
 function isopenoutput(const aoutputs: outputconnarty): boolean;
 var
  int1: integer;
 begin
  result:= true;
  for int1:= 0 to high(aoutputs) do begin
   if aoutputs[int1].fdestinations <> nil then begin
    result:= false;
    break;
   end;
  end;
 end;
  
var
 int1,int2,int3,int4: integer;
 po1,po2: psiginfoty;
 inputnodecount: integer;
 outputnodecount: integer;
 recursivenodecount: integer;
 ar1,ar2: siginfopoarty;
 ar3: inputconnarty;
begin
 finfos:= nil;
 finphash.clear;
 foutphash.clear;
 finputnodes:= nil;
 foutputnodes:= nil;
 fexecinfo:= nil;
 outputnodecount:= 0;
 inputnodecount:= 0;
 setlength(finfos,length(fclients));
{$ifdef mse_debugsignal}
 debugwriteln('**updatemodel '+name);
 debugwriteln('*get info');
{$endif}

 for int1:= 0 to high(fclients) do begin //get basic info
  po1:= @finfos[int1];
  with po1^ do begin
   intf:= fclients[int1];
   intf.initmodel;
   intf.clear;
   zcount:= intf.getzcount;
  {$ifdef mse_debugsignal}
   debugwriteln('client '+intf.getnamepath);
  {$endif}
   ar3:= fclients[int1].getinputar;
   setlength(inputs,length(ar3));
   for int2:= 0 to high(ar3) do begin
    inputs[int2].input:= ar3[int2];
   end;
   outputs:= fclients[int1].getoutputar;
   destinations:= nil;
   for int2:= 0 to high(inputs) do begin
  {$ifdef mse_debugsignal}
    debugpointer(' inp ',inputs[int2].input);
  {$endif}
    finphash.add(ptruint(inputs[int2].input),po1);
   end;
   for int2:= 0 to high(outputs) do begin
  {$ifdef mse_debugsignal}
    debugpointer(' outp ',outputs[int2]);
  {$endif}
    foutphash.add(ptruint(outputs[int2]),po1);
    with outputs[int2] do begin
     stackarray(pointerarty(fdestinations),pointerarty(po1^.destinations));
   {$ifdef mse_debugsignal}
     for int3:= 0 to high(fdestinations) do begin
      debugpointer('  dest ',fdestinations[int3]);
     end;
   {$endif}
    end;
   end;
  end;
 end;
  
{$ifdef mse_debugsignal}
  debugwriteln('*link items');
{$endif}
 for int1:= 0 to high(fclients) do begin //link the items
  po1:= @finfos[int1];
  with po1^ do begin
   if not (sis_checked in state) then begin
   {$ifdef mse_debugsignal}
    debugnodeinfo('node ',po1);
   {$endif}
    include(state,sis_checked);
    for int2:= 0 to high(outputs) do begin
     with outputs[int2] do begin
      for int3:= 0 to high(fdestinations) do begin
      {$ifdef mse_debugsignal}
       debugpointer('lookup inp ',fdestinations[int3]);
      {$endif}
       po2:= findinp(fdestinations[int3]);
      {$ifdef mse_debugsignal}
       debugnodeinfo(' ',po2);
      {$endif}
       if po2 = nil then begin
        raise exception.create(
         'Destination not found. Controller: '+self.name+ ', Node: '+
                     fclients[int1].getnamepath +
                 ', Dest: '+fdestinations[int3].fsigintf.getcomponent.name+'.');
       end;
       if finditem(pointerarty(po2^.prev),po1) < 0 then begin
        inc(po2^.connectedcount);
       {$ifdef mse_debugsignal}
        debugnodeinfo(' new link ',po2);
       {$endif}
        additem(pointerarty(po2^.prev),po1);
        additem(pointerarty(po1^.next),po2);
       end;
       for int4:= 0 to high(po2^.inputs) do begin
        if po2^.inputs[int4].input = fdestinations[int3] then begin
         po2^.inputs[int4].source:= po1;
         break;
        end;
       end;
      end;
     end;
    end;      
   end;
  end;
 end; 

{$ifdef mse_debugsignal}
 debugwriteln('*check input/output');
{$endif}
 for int1:= 0 to high(fclients) do begin
  po1:= @finfos[int1];
  with po1^ do begin
   state:= [];
   if not isopeninput(inputs) then begin
    include(state,sis_input);
   end
   else begin
    additem(pointerarty(finputnodes),po1,inputnodecount);
   {$ifdef mse_debugsignal}
    debugnodeinfo(' input node ',po1);
   {$endif}
   end;
   if not isopenoutput(outputs) then begin
    include(state,sis_output);
   end
   else begin
    additem(pointerarty(foutputnodes),po1,outputnodecount);
   {$ifdef mse_debugsignal}
    debugnodeinfo(' output node ',po1);
   {$endif}
   end;
  end;
 end;
 setlength(finputnodes,inputnodecount);
 setlength(foutputnodes,outputnodecount);
  
{$ifdef mse_debugsignal}
  debugwriteln('*check recursion');
{$endif}

 for int1:= 0 to high(finputnodes) do begin //check recursion
 {$ifdef mse_debugsignal}
  debugnodeinfo('input ',finputnodes[int1]);
 {$endif}
  visited:= nil;
  checkrecursion(finputnodes[int1]);
 end;

{$ifdef mse_debugsignal}
 debugwriteln('*processcalcorder');  
{$endif}
 setlength(execorder,length(finfos));
 execindex:= 0;
// resetchecked;
 for int1:= 0 to high(finputnodes) do begin
 {$ifdef mse_debugsignal}
  debugnodeinfo('input ',finputnodes[int1]);  
 {$endif}
  resetchecked;
  processcalcorder(finputnodes[int1]);
 end;

{$ifdef mse_debugsignal}
 debugwriteln('*execorder '+inttostr(length(execorder))+' '+inttostr(execindex));
 for int1:= 0 to high(execorder) do begin
  debugnodeinfo(' ',execorder[int1]);
 end;
 for int1:= 0 to high(finfos) do begin
  po1:= @finfos[int1];
  with po1^ do begin
   if connectedcount <> 0 then begin
    debugnodeinfo('! '+inttostr(connectedcount)+ ' ',po1);
   end;
  end;
 end;
{$endif}
 if execindex <> length(execorder) then begin
  internalerror('SIG20100916-2'); //unprocessed nodes
 end;
 setlength(fexecinfo,execindex);
 fexechigh:= execindex-1;
 for int1:= 0 to high(fexecinfo) do begin
  po1:= execorder[int1];
  with fexecinfo[int1] do begin
   handler:= po1^.intf.gethandler;
   desthigh:= high(po1^.destinations)-1;
   if length(po1^.destinations) > 0 then begin
    handlerinfo.dest:= @po1^.destinations[0].fvalue;
    updatedestinfo(po1^.destinations[0],firstdest);
//    firstdest.dest:= handlerinfo.dest;
    setlength(dest,desthigh+1);
    for int2:= 0 to desthigh do begin
     updatedestinfo(po1^.destinations[int2+1],dest[int2]);
//     dest[int2].dest:= @po1^.destinations[int2+1].fvalue;
    end;
   end
   else begin
    handlerinfo.dest:= @fvaluedummy;
   end;
  end;
 end;
 include(fstate,scs_modelvalid);
 clear;
end;

procedure tsigcontroller.internalstep;
var
 int1,int2: integer;
 po1: psighandlernodeinfoty;
begin
 po1:= pointer(fexecinfo);
 for int1:= 0 to fexechigh do begin
  po1^.handler(psighandlerinfoty(po1));
  with po1^.firstdest do begin
   if hasscale then begin
    dest^:= dest^*gain+offset;
   end;
  end;
  for int2:= 0 to po1^.desthigh do begin //multi inputs on output
   with po1^.dest[int2] do begin
    dest^:= po1^.handlerinfo.dest^;
    if hasscale then begin
     dest^:= dest^*gain+offset;
    end;
   end;    
  end;
  inc(po1);
 end;
end;

procedure tsigcontroller.step(const acount: integer);
var
 int1: integer;
begin
 if not (scs_modelvalid in fstate) then begin
  updatemodel;
 end;
 for int1:= acount-1 downto 0 do begin
  internalstep;
 end;
end;

procedure tsigcontroller.checkmodel;
begin
 if not (scs_modelvalid in fstate) then begin
  updatemodel;
 end;
end;

procedure tsigcontroller.loaded;
begin
 inherited;
 modelchange;
end;

procedure tsigcontroller.clear;
var
 int1: integer;
begin
 for int1:= 0 to high(fclients) do begin
  fclients[int1].clear;
 end;
end;

procedure tsigcontroller.lock;
begin
 sys_mutexlock(fmutex);
end;

procedure tsigcontroller.unlock;
begin
 sys_mutexunlock(fmutex);
end;

{ tsigwavetable }

constructor tsigwavetable.create(aowner: tcomponent);
begin
 inherited;
 ffrequency:= tdoubleinputconn.create(self,isigclient(self));
 ffrequency.name:= 'frequency';
 fphase:= tdoubleinputconn.create(self,isigclient(self));
 fphase.name:= 'phase';
 famplitude:= tdoubleinputconn.create(self,isigclient(self));
 famplitude.name:= 'amplitude';
end;

procedure tsigwavetable.setfrequency(const avalue: tdoubleinputconn);
begin
 ffrequency.assign(avalue);
end;

procedure tsigwavetable.setphase(const avalue: tdoubleinputconn);
begin
 fphase.assign(avalue);
end;

procedure tsigwavetable.setamplitude(const avalue: tdoubleinputconn);
begin
 famplitude.assign(avalue);
end;

function tsigwavetable.gethandler: sighandlerprocty;
begin
 if siwto_intpol in foptions then begin
  result:= {$ifdef FPC}@{$endif}sighandlerintpol;
 end
 else begin
  result:= {$ifdef FPC}@{$endif}sighandler;
 end;
end;

procedure tsigwavetable.sighandler(const ainfo: psighandlerinfoty);
var
 int1: integer;
begin
 int1:= trunc((ftime+fphasepo^)*ftablelength) mod ftablelength;
 if int1 < 0 then begin
  int1:= int1 + ftablelength;
 end;
 ainfo^.dest^:= ftable[int1] * famplitudepo^;
 ftime:= frac(ftime+ffrequencypo^);
end;

procedure tsigwavetable.sighandlerintpol(const ainfo: psighandlerinfoty);
var
 int1: integer;
 do1: double;
begin
 do1:= (ftime+fphasepo^)*ftablelength;
 int1:= trunc(do1) mod ftablelength;
 if int1 < 0 then begin
  int1:= int1 + ftablelength;
 end;
 ainfo^.dest^:= (ftable[int1] + 
                 (ftable[(int1+1) mod ftablelength] - ftable[int1]) * 
                 ((do1-int1)/ftablelength)
                ) * famplitudepo^;
 ftime:= frac(ftime+ffrequencypo^);
end;


procedure tsigwavetable.settable(const avalue: doublearty);
begin
 ftable:= avalue;
 checktable;
end;

procedure tsigwavetable.clear;
begin
 inherited;
 if canevent(tmethod(foninittable)) then begin
  foninittable(self,realarty(ftable));
 end;
 checktable;
end;

procedure tsigwavetable.checktable;
begin
 lock;
 ftime:= 0;
 if ftable = nil then begin
  setlength(ftable,1);
 end;
 ftablelength:= length(ftable);
 unlock;
end;

procedure tsigwavetable.initmodel;
begin
 ffrequencypo:= @ffrequency.fvalue;
 fphasepo:= @fphase.fvalue;
 famplitudepo:= @famplitude.fvalue;
 inherited;
end;

function tsigwavetable.getinputar: inputconnarty;
begin
 setlength(result,3);
 result[0]:= ffrequency;
 result[1]:= fphase;
 result[2]:= famplitude;
end;

function tsigwavetable.getzcount: integer;
begin
 result:= 1;
end;

procedure tsigwavetable.setoptions(const avalue: sigwavetableoptionsty);
begin
 if avalue <> foptions then begin
  foptions:= avalue;
  if fcontroller <> nil then begin
   fcontroller.modelchange;
  end;
 end;
end;

end.
