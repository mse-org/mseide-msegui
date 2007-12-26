{ MSEgui Copyright (c) 1999-2007 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseapplication;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 classes,mseclasses,mseevent,mseglob,sysutils,msetypes,mselist,
     msethread,msesys,mseguithread,msestrings;
 
type
 activatoroptionty = (avo_activateonloaded,avo_activatedelayed,
                avo_deactivateonterminated,
                avo_handleexceptions,avo_quietexceptions,
                avo_abortonexception);
 activatoroptionsty = set of activatoroptionty;
const
 defaultactivatoroptions = [avo_handleexceptions,avo_quietexceptions];
 
type
 iactivator = interface(inullinterface)
 end;
 iactivatorclient = interface(inullinterface)
 end;

 tactivator = class;
 
 activateerroreventty = procedure(const sender: tactivator; 
                 const aclient: tobject; const aexception: exception;
                 var handled: boolean) of object;

 actcomponentstatety = (acs_releasing);
 actcomponentstatesty = set of actcomponentstatety;
  
 tactcomponent = class(tmsecomponent,iactivator)
  private
   factivator: tactivator;
   fstate: actcomponentstatesty;
   procedure setactivator(const avalue: tactivator);
  protected
   fdesignchangedlock: integer;
//   procedure receiveevent(const event: tobjectevent); override;
   procedure designchanged; //for designer notify
   procedure loaded; override;
   procedure doactivated; virtual;
   procedure dodeactivated; virtual;
   procedure objectevent(const sender: tobject;
                          const event: objecteventty); override;
   procedure receiveevent(const event: tobjectevent); override;
  public
   procedure release; virtual;
   function releasing: boolean;
   property activator: tactivator read factivator write setactivator;
 end;

 tactivator = class(tactcomponent)
  private
   foptions: activatoroptionsty;
   fonbeforeactivate: notifyeventty;
   fonafteractivate: notifyeventty;
   fonbeforedeactivate: notifyeventty;
   fonafterdeactivate: notifyeventty;
   factive: boolean;
   factivated: boolean;
   fonactivateerror: activateerroreventty;
   procedure readclientnames(reader: treader);
   procedure writeclientnames(writer: twriter);
   function getclients: integer;
   procedure setclients(const avalue: integer);
   procedure setoptions(const avalue: activatoroptionsty);
   procedure setactive(const avalue: boolean);
  protected
   fclientnames: stringarty;
   fclients: pointerarty;
   procedure registerclient(const aclient: iobjectlink);
   procedure unregisterclient(const aclient: iobjectlink);
   procedure updateorder;
   function getclientname(const avalue: tobject; const aindex: integer): string;
   function getclientnames: stringarty;
   procedure defineproperties(filer: tfiler); override;
   procedure doasyncevent(var atag: integer); override;
   procedure loaded; override;
   procedure unlink(const source,dest: iobjectlink; valuepo: pointer = nil); override;
   procedure objevent(const sender: iobjectlink;
                         const event: objecteventty); override;
   procedure doterminated(const sender: tobject);   
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   class procedure addclient(const aactivator: tactivator; 
              const aclient: iobjectlink; var dest: tactivator);
   procedure activateclients;
   procedure deactivateclients;
   property activated: boolean read factivated;
  published
   property clients: integer read getclients write setclients; 
                                  //hook for object inspector
   property options: activatoroptionsty read foptions write setoptions 
                    default defaultactivatoroptions;
   property active: boolean read factive write setactive;
   property onbeforeactivate: notifyeventty read fonbeforeactivate
                           write fonbeforeactivate;
   property onactivateerror: activateerroreventty read fonactivateerror 
                                   write fonactivateerror;                              
   property onafteractivate: notifyeventty read fonafteractivate 
                           write fonafteractivate;
   property onbeforedeactivate: notifyeventty read fonbeforedeactivate 
                            write fonbeforedeactivate;
   property onafterdeactivate: notifyeventty read fonafterdeactivate 
                            write fonafterdeactivate;
   property activator;
 end;

 exceptioneventty = procedure (sender: tobject; e: exception) of object;
 terminatequeryeventty = procedure (var terminate: boolean) of object;
 idleeventty = procedure (var again: boolean) of object;
 
 tonterminatequerylist = class(tmethodlist)
  protected
  public
   function doterminatequery: boolean;
           //true if accepted
 end;
 
 tonidlelist = class(tmethodlist)
  protected
  public
   function doidle: boolean; //true if again requested
  public
 end;

 applicationstatety = 
        (aps_inited,aps_running,aps_terminated,aps_mousecaptured,
         aps_invalidated,aps_zordervalid,aps_needsupdatewindowstack,
         aps_focused,aps_activewindowchecked,aps_exitloop,
         aps_active,aps_waiting,aps_terminating,aps_deinitializing,
         aps_waitstarted,aps_waitcanceled,aps_waitterminated,aps_waitok);
 applicationstatesty = set of applicationstatety;

 tcustomapplication = class(tmsecomponent)
  private
   fapplicationname: filenamety;
   flockthread: threadty;
   flockcount: integer;
   fmutex: mutexty;
   feventlist: tobjectqueue;
   feventlock: mutexty;
   fpostedevents: eventarty;
   fidlecount: integer;
   fcheckoverloadlock: integer;
   fexceptionactive: integer;
   fexceptioncount: longword;
   fonexception: exceptioneventty;
   function dolock: boolean;
   function internalunlock(count: integer): boolean;
   function getterminated: boolean;
   procedure setterminated(const Value: boolean);
  protected
   fthread: threadty;
   fstate: applicationstatesty;
   fwaitcount: integer;
   fonterminatedlist: tnotifylist;
   fonterminatequerylist: tonterminatequerylist;
   fonidlelist: tonidlelist;
   procedure flusheventbuffer;
   procedure doidle;
   procedure dopostevent(const aevent: tevent); virtual; abstract;
   function getevents: integer; virtual; abstract;
    //application must be locked
    //returns count of queued events
   procedure doeventloop(const once: boolean); virtual; abstract;
   procedure incidlecount;
   procedure dobeforerun; virtual;
   procedure doafterrun; virtual;
   procedure dowakeup(sender: tobject);
   property eventlist: tobjectqueue read feventlist;
  public
   {$ifdef mse_debug_mutex}
   function getmutexaddr: pointer;
   function getmutexcount: integer;
   procedure checklockcount;
   {$endif}
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure createdatamodule(instanceclass: msecomponentclassty; var reference);
   procedure run;
   function running: boolean; //true if eventloop entered
   procedure processmessages; virtual; //handle with care!
   function idle: boolean; virtual;
   property applicationname: msestring read fapplicationname write fapplicationname;
   
   procedure postevent(event: tevent);
   function checkoverload(const asleepus: integer = 100000): boolean;
              //true if never idle since last call,
              // unlocks application and calls sleep if not mainthread and asleepus >= 0
   function waitdialog(const athread: tthreadcomp = nil; const atext: msestring = '';
                   const caption: msestring = '';
                   const acancelaction: notifyeventty = nil;
                   const aexecuteaction: notifyeventty = nil): boolean; virtual;
   procedure handleexception(sender: tobject; const leadingtext: string = '');
   procedure showexception(e: exception; const leadingtext: string = '');
                                  virtual; abstract;
   procedure errormessage(const amessage: msestring); virtual; abstract;
   procedure registeronterminated(const method: notifyeventty);
   procedure unregisteronterminated(const method: notifyeventty);
   procedure registeronterminate(const method: terminatequeryeventty);
   procedure unregisteronterminate(const method: terminatequeryeventty);
   procedure registeronidle(const method: idleeventty);
   procedure unregisteronidle(const method: idleeventty);
   procedure settimer(const us: integer); virtual; abstract;
{
   procedure setlinkedvar(const source: tmsecomponent; var dest: tmsecomponent;
              const linkintf: iobjectlink = nil); overload;
   procedure setlinkedvar(const source: tlinkedobject; var dest: tlinkedobject;
              const linkintf: iobjectlink = nil); overload;
   procedure setlinkedvar(const source: tlinkedpersistent;
              var dest: tlinkedpersistent;
              const linkintf: iobjectlink = nil); overload;
}
   function trylock: boolean;
   function lock: boolean;
    //synchronizes calling thread with main event loop (mutex),
    //false if calling thread allready holds the mutex
    //mutex is recursive
   function unlock: boolean;
    //release mutex if calling thread holds the mutex,
    //false if no unlock done
   function unlockall: integer;
    //release mutex recursive if calling thread holds the mutex,
    //returns count for relockall
   procedure relockall(count: integer);
   procedure synchronize(proc: objectprocty);
   function ismainthread: boolean;
   procedure waitforthread(athread: tmsethread); //does unlock-relock before waiting
   procedure wakeupmainthread;
   procedure langchanged; virtual;
   procedure beginwait; virtual;
   procedure endwait; virtual;
   property terminated: boolean read getterminated write setterminated;
   property exceptioncount: longword read fexceptioncount;
   property onexception: exceptioneventty read fonexception write fonexception;
 end;
 applicationclassty = class of tcustomapplication;
 
function application: tcustomapplication;
function applicationallocated: boolean;

procedure registerapplicationclass(const aclass: applicationclassty);

var
 ondesignchanged: notifyeventty;
 onfreedesigncomponent: componenteventty;
 
implementation
uses
 msedatalist,msebits,msesysintf,msesysutils,msefileutils;

var
 appinst: tcustomapplication;
 appclass: applicationclassty;

function application: tcustomapplication;
begin
 if appinst = nil then begin
  if appclass = nil then begin
   raise exception.create('No application class registered.');
  end;
  appclass.create(nil);
 end;
 result:= appinst;
end;

function applicationallocated: boolean;
begin
 result:= appinst <> nil;
end;

procedure registerapplicationclass(const aclass: applicationclassty);
begin
 if appclass <> nil then begin
  raise exception.create('Application class already registered.');
 end;
 appclass:= aclass;
end;

{ tactcomponent }

procedure tactcomponent.designchanged; //for designer notify
begin
 if assigned(ondesignchanged) and (fdesignchangedlock = 0) and
       (componentstate*[csdesigning,csloading] = [csdesigning]) then begin
  ondesignchanged(self);
 end;
end;

procedure tactcomponent.setactivator(const avalue: tactivator);
begin
 tactivator.addclient(avalue,ievent(self),factivator);
end;

procedure tactcomponent.loaded;
begin
 inherited;
 if (factivator <> nil) and factivator.activated then begin
  doactivated;
 end;
end;

procedure tactcomponent.doactivated;
begin
 //dummy;
end;

procedure tactcomponent.dodeactivated;
begin
 //dummy;
end;

procedure tactcomponent.objectevent(const sender: tobject; 
                               const event: objecteventty);
begin
 inherited;
 if (sender = factivator) then begin
  case event of
   oe_activate: begin
    doactivated;
   end;
   oe_deactivate: begin
    dodeactivated;
   end;
  end;
 end;
end;

procedure tactcomponent.release;
begin
 if not (acs_releasing in fstate) then begin
  appinst.postevent(tobjectevent.create(ek_release,ievent(self)));
  include(fstate,acs_releasing);
 end;
end;

function tactcomponent.releasing: boolean;
begin
 result:= acs_releasing in fstate;
end;

procedure tactcomponent.receiveevent(const event: tobjectevent);
begin
 inherited;
 case event.kind of
  ek_release: begin
   free;
  end;
 end;
end;

{ tactivator }

constructor tactivator.create(aowner: tcomponent);
begin
 foptions:= defaultactivatoroptions;
 inherited;
 application.registeronterminated({$ifdef FPC}@{$endif}doterminated);
end;

destructor tactivator.destroy;
begin
 application.unregisteronterminated({$ifdef FPC}@{$endif}doterminated);
 inherited;
end;

class procedure tactivator.addclient(const aactivator: tactivator; 
                    const aclient: iobjectlink; var dest: tactivator);
var
 act1: tactivator;
begin
 if dest <> nil then begin
  dest.unregisterclient(aclient);
 end;
 if aactivator <> nil then begin
  act1:= tactivator(aclient.getinstance);
  if act1 is tactivator then begin
   repeat  
    if act1 = aactivator then begin
     raise exception.create('Circular reference.');
    end;
    act1:= act1.activator;
   until act1 = nil;
  end;
  aclient.link(aclient,ievent(aactivator),@dest);
  aactivator.registerclient(aclient);
 end;
 dest:= aactivator;
end;

procedure tactivator.registerclient(const aclient: iobjectlink);
begin
 additem(fclients,pointer(aclient));
end;

procedure tactivator.unregisterclient(const aclient: iobjectlink);
begin
 removeitem(fclients,pointer(aclient));
end;

procedure tactivator.updateorder;
var
 int1,int2: integer;
 ar1: stringarty;
 ar2,ar3: integerarty;
begin
 ar1:= nil; //compilerwarning
 if fclientnames <> nil then begin
  ar1:= getclientnames;
  setlength(ar2,length(ar1));
  for int1:= 0 to high(fclientnames) do begin
   for int2:= 0 to high(ar1) do begin
    if ar1[int2] = fclientnames[int1] then begin
     ar2[int2]:= int1-bigint; //not found items last
     ar1[int2]:= '';
    end;
   end;
  end;
  sortarray(ar2,ar3);
  orderarray(ar3,fclients);
 end;
end;

procedure tactivator.doasyncevent(var atag: integer);
begin
 activateclients;
end;

procedure tactivator.loaded;
begin
 inherited;
 if not (csdesigning in componentstate) or factive then begin
  if avo_activateonloaded in foptions then begin   
   if csdesigning in componentstate then begin
    try
     activateclients;
    except
     application.handleexception(self);
    end;
   end
   else begin
    activateclients;
   end;   
  end;
  if avo_activatedelayed in foptions then begin
   asyncevent;
  end;
 end;
end;

procedure tactivator.doterminated(const sender: tobject);
begin
 if avo_deactivateonterminated in foptions then begin
  deactivateclients;
 end;
end;

function tactivator.getclientname(const avalue: tobject;
                   const aindex: integer): string;
begin
 if avalue is tcomponent then begin
  with tcomponent(avalue) do begin
   if owner <> nil then begin
    if not (csdesigning in componentstate) or 
             ((owner.owner <> nil) and (owner.owner.owner = nil)) then begin
     result:= owner.name+'.'+name;
    end
    else begin
     result:= name;
    end;
   end
   else begin
    result:= '';
   end;
  end;
 end
 else begin
  result:= inttostr(aindex)+'<'+avalue.classname+'>';
 end;
end;

function tactivator.getclientnames: stringarty;
var
 int1: integer;
begin
 setlength(result,length(fclients));
 for int1:= 0 to high(result) do begin 
  result[int1]:= getclientname(iobjectlink(fclients[int1]).getinstance,int1);
 end;
end;

procedure tactivator.readclientnames(reader: treader);
begin
 readstringar(reader,fclientnames);
end;

procedure tactivator.writeclientnames(writer: twriter);
begin
 writestringar(writer,getclientnames);
end;

procedure tactivator.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('clientnames',{$ifdef FPC}@{$endif}readclientnames,
            {$ifdef FPC}@{$endif}writeclientnames,high(fclients) >= 0);
end;

procedure tactivator.objevent(const sender: iobjectlink; const event: objecteventty);
begin
 inherited;
 if (event = oe_activate) and (sender.getinstance = activator) then begin
  activateclients;
 end;
end;

procedure tactivator.unlink(const source,dest: iobjectlink; valuepo: pointer = nil);
begin
 removeitem(fclients,pointer(dest));
 inherited;
end;

function tactivator.getclients: integer;
begin
 result:= length(fclients);
end;

procedure tactivator.setclients(const avalue: integer);
begin
 // dummy;
end;

procedure tactivator.activateclients;
var
 int1: integer;
 bo1,bo2: boolean;
begin
 factive:= true;
 factivated:= true;
 if canevent(tmethod(fonbeforeactivate)) then begin
  fonbeforeactivate(self);
 end;
 if factive then begin
  bo2:= canevent(tmethod(fonactivateerror));
  for int1:= 0 to high(fclients) do begin
   try
    iobjectlink(fclients[int1]).objevent(ievent(self),oe_activate);
   except
    on e: exception do begin
     bo1:= false;
     if bo2 then begin
      fonactivateerror(self,iobjectlink(fclients[int1]).getinstance,e,bo1);
     end;
     if not bo1 then begin
      if avo_handleexceptions in foptions then begin
       if not (avo_quietexceptions in foptions) then begin
        application.showexception(e);
       end;
      end
      else begin
       raise;
      end;
     end;
     if avo_abortonexception in foptions then begin
      break;
     end;
    end;
   end;
  end;
  if canevent(tmethod(fonafteractivate)) then begin
   fonafteractivate(self);
  end;
 end;
end;

procedure tactivator.deactivateclients;
var
 int1: integer;
begin
 factive:= false;
 if canevent(tmethod(fonbeforedeactivate)) then begin
  fonbeforedeactivate(self);
 end;
 if not active then begin
  for int1:= high(fclients) downto 0 do begin
   iobjectlink(fclients[int1]).objevent(ievent(self),oe_deactivate);
  end;
  if canevent(tmethod(fonafterdeactivate)) then begin
   fonafterdeactivate(self);
  end;
 end;
end;

procedure tactivator.setactive(const avalue: boolean);
begin
 if avalue <> factive then begin
  if componentstate * [csloading,csdesigning] = [csloading,csdesigning] then begin
   factive:= avalue;
  end
  else begin
   if not (csloading in componentstate) then begin
    if avalue then begin
     activateclients;
    end
    else begin
     deactivateclients;
    end;
   end;
  end;
 end;
end;

procedure tactivator.setoptions(const avalue: activatoroptionsty);
const 
 mask: activatoroptionsty = [avo_activateonloaded,avo_activatedelayed];
begin
 foptions:= activatoroptionsty(setsinglebit(
                         {$ifdef FPC}longword{$else}byte{$endif}(avalue),
                         {$ifdef FPC}longword{$else}byte{$endif}(foptions),
                         {$ifdef FPC}longword{$else}byte{$endif}(mask)));
end;

{ tonterminatequerylist }

function tonterminatequerylist.doterminatequery: boolean;
begin
 factitem:= 0;
 result:= true;
 while (factitem < fcount) and result do begin
  terminatequeryeventty(getitempo(factitem)^)(result);
  inc(factitem);
 end;
end;

{ tonidlelist}

function tonidlelist.doidle: boolean;
var
 bo1: boolean;
begin
 result:= false;
 factitem:= 0;
 while factitem < fcount do begin
  bo1:= false;
  idleeventty(getitempo(factitem)^)(bo1);
  result:= result or bo1;
  inc(factitem);
 end;
end;

{ tcustomapplication }

{$ifdef mse_debug_mutex}
function tcustomapplication.getmutexaddr: pointer;
begin
 result:= @fmutex;
end;
function tcustomapplication.getmutexcount: integer;
begin
 result:= flockcount;
end;
procedure tcustomapplication.checklockcount;
begin
 if appmutexcount <> flockcount then begin
  debugout(self,'appmutexerror, lockcount: '+inttostr(flockcount)+
                ' mutexcount: '+inttostr(appmutexcount));
 end;
end;
{$endif}

constructor tcustomapplication.create(aowner: tcomponent);
begin
 if appinst <> nil then begin
  raise exception.create('Application already created.');
 end;
 appinst:= self;
 fapplicationname:= filename(sys_getapplicationpath);
 fthread:= sys_getcurrentthread;
 feventlist:= tobjectqueue.create(true);
 fonterminatedlist:= tnotifylist.create;
 fonterminatequerylist:= tonterminatequerylist.create;
 fonidlelist:= tonidlelist.create;
 sys_mutexcreate(fmutex);
 sys_mutexcreate(feventlock);
 classes.wakemainthread:= {$ifdef FPC}@{$endif}dowakeup;
end;

destructor tcustomapplication.destroy;
begin
 inherited;
 fonidlelist.free;
 fonterminatedlist.free;
 fonterminatequerylist.free;
 feventlist.free;
 sys_mutexdestroy(fmutex);
 sys_mutexdestroy(feventlock);
end;

procedure tcustomapplication.registeronterminated(const method: notifyeventty);
begin
 fonterminatedlist.add(tmethod(method));
end;

procedure tcustomapplication.unregisteronterminated(const method: notifyeventty);
begin
 fonterminatedlist.remove(tmethod(method));
end;

procedure tcustomapplication.registeronterminate(const method: terminatequeryeventty);
begin
 fonterminatequerylist.add(tmethod(method));
end;

procedure tcustomapplication.unregisteronterminate(const method: terminatequeryeventty);
begin
 fonterminatequerylist.remove(tmethod(method));
end;

procedure tcustomapplication.registeronidle(const method: idleeventty);
begin
 fonidlelist.add(tmethod(method));
end;

procedure tcustomapplication.unregisteronidle(const method: idleeventty);
begin
 fonidlelist.remove(tmethod(method));
end;

function tcustomapplication.dolock: boolean;
var
 athread: threadty;
begin
 inc(flockcount);
 athread:= sys_getcurrentthread;
 if not sys_issamethread(flockthread,athread) then begin
  result:= true;
  flockthread:= athread;
 end
 else begin
  result:= false;
 end;
 {$ifdef mse_debug_lock}
 debugout(self,'lock, count: '+inttostr(flockcount) + ' thread: '+
                    inttostr(flockthread));
 checklockcount;
 {$endif}
end;

function tcustomapplication.lock: boolean;
begin
 syserror(sys_mutexlock(fmutex));
 result:= dolock;
end;

function tcustomapplication.trylock: boolean;
begin
 result:= sys_mutextrylock(fmutex) = sye_ok;
 {$ifdef mse_debug_lock}
 debugout(self,'trylock, result: '+booltostr(result)+' count: '+
                  inttostr(flockcount) + ' thread: '+
                    inttostr(flockthread));
 {$endif}
 if result then begin
  dolock;
 end;
end;

function tcustomapplication.internalunlock(count: integer): boolean;
begin
 result:= sys_issamethread(flockthread,sys_getcurrentthread);
 if result then begin
  if count > flockcount then begin
   raise exception.create('tcustomapplication.internalunlock lock count error.');
  end;
  flusheventbuffer;
  while count > 0 do begin
   dec(count);
   dec(flockcount);
   if flockcount = 0 then begin
    flockthread:= 0;
   end;
   sys_mutexunlock(fmutex);
  end;
  {$ifdef mse_debug_lock}
  debugout(self,'unlock, result: '+booltostr(result)+
                     ' count: '+inttostr(flockcount) + ' thread: '+
                     inttostr(flockthread));
  checklockcount;
  {$endif}
 end;
end;

function tcustomapplication.unlock: boolean;
begin
 result:= internalunlock(1);
end;

function tcustomapplication.unlockall: integer;
begin
 if ismainthread then begin
  inc(fcheckoverloadlock);
 end;
 result:= flockcount;
 if not internalunlock(flockcount) then begin
  result:= 0;
 end;
end;

procedure tcustomapplication.relockall(count: integer);
begin
 if count > 0 then begin
  lock;
  dec(count);
  while count > 0 do begin
   sys_mutexlock(fmutex);
   dec(count);
  end;
  inc(flockcount,count);
  if ismainthread then begin
   dec(fcheckoverloadlock);
  end;
 end;
end;

procedure tcustomapplication.synchronize(proc: objectprocty);
begin
 lock;
 try
  proc;
 finally
  unlock;
 end;
end;

function tcustomapplication.ismainthread: boolean;
begin
 result:= sys_getcurrentthread = fthread;
end;

procedure tcustomapplication.waitforthread(athread: tmsethread);
         //does unlock-relock before waiting
var
 int1: integer;
begin
 int1:= unlockall;
 try
  athread.waitfor;
 finally
  relockall(int1);
 end;
end;

procedure tcustomapplication.incidlecount;
begin
 inc(fidlecount);
end;

procedure tcustomapplication.flusheventbuffer;
var
 int1: integer;
begin
 sys_mutexlock(feventlock);
 for int1:= 0 to high(fpostedevents) do begin
  dopostevent(fpostedevents[int1]);
 end;
 fpostedevents:= nil;
 sys_mutexunlock(feventlock);
end;

procedure tcustomapplication.postevent(event: tevent);
begin
 if csdestroying in componentstate then begin
  event.free;
 end
 else begin
  if trylock then begin
   try
    flusheventbuffer;
    dopostevent(event);
   except
    event.free;
    unlock;
    raise;
   end;
   unlock;
  end
  else begin
   sys_mutexlock(feventlock);
   setlength(fpostedevents,high(fpostedevents) + 2);
   fpostedevents[high(fpostedevents)]:= event;
   sys_mutexunlock(feventlock);
  end;
 end;
end;

function tcustomapplication.checkoverload(const asleepus: integer = 100000): boolean;
              //true if never idle since last call,
              // unlocks application and calls sleep if not mainthread and asleepus >= 0
var
 int1: integer;
begin
 result:= (fidlecount = 0) and not (aps_waiting in fstate) and 
                                                 (fcheckoverloadlock = 0);
 fidlecount:= 0;
 if result and (asleepus >= 0) and not ismainthread then begin
  int1:= unlockall;
  repeat
   sleepus(asleepus);
  until (fidlecount > 0) or (aps_waiting in fstate) or (fcheckoverloadlock <> 0);
  relockall(int1);
 end;
end;

function tcustomapplication.getterminated: boolean;
begin
 result:= aps_terminated in fstate;
end;

procedure tcustomapplication.setterminated(const Value: boolean);
begin
 if value then begin
  lock;
  include(fstate,aps_terminated);
  if not ismainthread then begin
   wakeupmainthread;
  end;
  unlock;
 end;
end;

procedure tcustomapplication.wakeupmainthread;
begin
 if aps_running in fstate then begin
  postevent(tevent.create(ek_wakeup));
 end;
end;

procedure tcustomapplication.langchanged;
begin
 //dummy
end;

procedure tcustomapplication.beginwait;
begin
 //dummy
end;

procedure tcustomapplication.endwait;
begin
 //dummy
end;

function tcustomapplication.waitdialog(const athread: tthreadcomp = nil;
               const atext: msestring = ''; const caption: msestring = '';
               const acancelaction: notifyeventty = nil;
               const aexecuteaction: notifyeventty = nil): boolean;
begin
 //dummy
end;

procedure tcustomapplication.handleexception(sender: tobject;
                              const leadingtext: string = '');
begin
 if fexceptionactive = 0 then begin //do not handle subsequent exceptions
  if exceptobject is exception then begin
   inc(fexceptionactive);
   try
    if not (exceptobject is eabort) then begin
     inc(fexceptioncount);
     if assigned(fonexception) then begin
      fonexception(sender, exception(exceptobject))
     end
     else begin
      showexception(exception(exceptobject),leadingtext);
     end;
    end
    else begin
//     sysutils.showexception(exceptobject, exceptaddr);
    end;
   finally
    dec(fexceptionactive);
   end;
  end;
 end;
end;

procedure tcustomapplication.run;
var
 threadbefore: threadty;
begin
 dobeforerun;
 threadbefore:= fthread;
 fthread:= sys_getcurrentthread;
 include(fstate,aps_running);
 try
  doeventloop(false);
  fonterminatedlist.notify(application);
 finally
  fthread:= threadbefore;
  exclude(fstate,aps_running);
 end;
 doafterrun;
end;

function tcustomapplication.running: boolean;
begin
 result:= aps_running in fstate;
end;

procedure tcustomapplication.processmessages;
begin
 if not ismainthread then begin
  raise exception.create('processmessages must be called from main thread.');
 end;
 doeventloop(true);
end;

procedure tcustomapplication.dobeforerun;
begin
 //dummy
end;

procedure tcustomapplication.doafterrun;
begin
 //dummy
end;

procedure tcustomapplication.doidle;
var
 int1: integer;
begin
 while true do begin
  if not fonidlelist.doidle then begin
   break;
  end;
  int1:= getevents;
  if int1 <> 0 then begin
   break;
  end;
 end;
 checksynchronize;
end;

procedure tcustomapplication.createdatamodule(instanceclass: msecomponentclassty;
                                                          var reference);
begin
 mseclasses.createmodule(self,instanceclass,reference);
end;
{
procedure tcustomapplication.setlinkedvar(const source: tmsecomponent;
               var dest: tmsecomponent; const linkintf: iobjectlink = nil);
begin
 inherited;
end;

procedure tcustomapplication.setlinkedvar(const source: tlinkedobject;
               var dest: tlinkedobject; const linkintf: iobjectlink = nil);
begin
 inherited;
end;

procedure tcustomapplication.setlinkedvar(const source: tlinkedpersistent;
               var dest: tlinkedpersistent; const linkintf: iobjectlink = nil);
begin
 inherited;
end;
}
procedure tcustomapplication.dowakeup(sender: tobject);
begin
 wakeupmainthread;
end;

function tcustomapplication.idle: boolean;
begin
 result:= (high(fpostedevents) < 0) and (feventlist.count = 0);
end;

initialization
finalization
 appinst.Free;
 appinst:= nil;
end.
