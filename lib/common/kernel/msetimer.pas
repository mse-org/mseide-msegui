{ MSEgui Copyright (c) 1999-2012 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msetimer;

{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$goto on}{$endif}

interface
uses
 classes,mclasses,msetypes,mseevent,mseclasses,mseglob;

type
 timeroptionty = (to_single,   //single shot
                  to_absolute, //use absolute time (timestamp()) for to_single
                               //disabled for ttimer
                  to_autostart,//set enabled for to_single by setting interval,
                               //disabled for ttimer
                  to_leak);    //do not catch up missed timeouts
 timeroptionsty = set of timeroptionty;
 
 tsimpletimer = class(tnullinterfacedobject)
  private
   fenabled: boolean;
   finterval: longword;
   fontimer: notifyeventty;
   foptions: timeroptionsty;
//   fpending: boolean;
   procedure setenabled(const Value: boolean);
   procedure setinterval(const avalue: longword);
   function getsingleshot: boolean;
   procedure setsingleshot(const avalue: boolean);
  protected
   procedure dotimer;
  public
   constructor create(const interval: longword = 0; 
                const ontimer: notifyeventty = nil;
                const active: boolean = false;
                const aoptions: timeroptionsty = []);
             //activates timer
   destructor destroy; override;
   procedure firependingandstop;
   procedure fireandstop;
   procedure fire;
   procedure restart;
   property interval: longword read finterval write setinterval;
             //in microseconds, max +2000 seconds
             //restarts timer if enabled
             //0 -> fire once in mainloop idle
   property singleshot: boolean read getsingleshot write setsingleshot;
   property options: timeroptionsty read foptions write foptions;
   property ontimer: notifyeventty read fontimer write fontimer;
   property enabled: boolean read fenabled write setenabled default true;
             //last!
 end;

 ttimer = class(tmsecomponent)
  private
   ftimer: tsimpletimer;
   fenabled: boolean; //for design
//   foptions: timeroptionsty;
   fontimer: notifyeventty;
   function getenabled: boolean;
   procedure setenabled(const avalue: boolean);
   function getinterval: integer;
   procedure setinterval(avalue: integer);
   function getontimer: notifyeventty;
   procedure setontimer(const Value: notifyeventty);
   function getoptions: timeroptionsty;
   procedure setoptions(const avalue: timeroptionsty);
   function getsingleshot: boolean;
   procedure setsingleshot(const avalue: boolean);
   procedure dotimer(const sender: tobject);
  protected
   procedure doasyncevent(var atag: integer); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure restart;
   procedure firependingandstop;
   procedure fireandstop;
   procedure fire;
   property singleshot: boolean read getsingleshot write setsingleshot;
  published
   property interval: integer read getinterval write setinterval default 1000000;
             //in microseconds, max 2000 seconds
             //restarts timer if enabled
             //0 -> fire once in main loop idle
   property options: timeroptionsty read getoptions write setoptions default [];
   property ontimer: notifyeventty read fontimer write fontimer;
   property enabled: boolean read getenabled write setenabled default false;
             //last!
 end;

procedure tick(sender: tobject);
procedure init;
procedure deinit;

implementation
uses
 msesysintf1,msesysintf,SysUtils,mseapplication,msesystypes,msesysutils,
 mseformatstr;

const
 enabletimertag = 8346320;
 
type
 tapplication1 = class(tcustomapplication);
 ptimerinfoty = ^timerinfoty;
 timerinfoty = record
  nexttime: longword;
  interval: longword;
  prevpo,nextpo: ptimerinfoty;
  ontimer: proceventty;
  options: timeroptionsty
  {$ifdef mse_debugtimer}
  ;checked: boolean
  {$endif}
 end;
 
var
 first: ptimerinfoty;
 mutex: mutexty;
{$ifdef mse_debugtimer}
 timeitemcount: integer;

procedure checktimer;
var
 int1: integer;
 po1,po2: ptimerinfoty;
begin
 int1:= 0;
 po1:= first;
 while po1 <> nil do begin
  inc(int1);
  if po1^.checked then begin
   raise exception.create('Recursion in timer list.');
  end;
  po1^.checked := true;
  if (po1^.nextpo <> nil) and (po1^.nextpo^.prevpo <> po1) then begin
   raise exception.create('Invalid back link in timer list');
  end;
  po1:= po1^.nextpo;
 end;
 if int1 <> timeitemcount then begin
  raise exception.create('Invalid timer item count.');
 end;
 po1:= first;
 while po1 <> nil do begin
  po1^.checked:= false;
  po1:= po1^.nextpo;
 end;
end;
{$endif}

var
 timeraccesscount: integer;
 
procedure extract(po: ptimerinfoty);
          //mutex has to be locked
begin
 if not application.ismainthread then begin
  inc(timeraccesscount);
 end;
 if first = po then begin
  first:= po^.nextpo;
  if first <> nil then begin
   first^.prevpo:= nil;
  end;
 end;
 if po^.prevpo <> nil then begin
  po^.prevpo^.nextpo:= po^.nextpo;
 end;
 if po^.nextpo <> nil then begin
  po^.nextpo^.prevpo:= po^.prevpo;
 end;
{$ifdef mse_debugtimer}
 dec(timeitemcount);
 checktimer;
 inc(timeitemcount);
{$endif}
end;

procedure insert(po: ptimerinfoty); //mutex has to be locked
var
 po1,po2: ptimerinfoty;
 ca1: longword;
begin
 if not application.ismainthread then begin
  inc(timeraccesscount);
 end;
 ca1:= po^.nexttime;
 po2:= po;
 po1:= po^.nextpo;
 if po1 = nil then begin
  po1:= first;
 end;
// while (po1 <> nil) and (integer(po1^.nexttime-ca1) < 0) do begin //todo!!!!!: FPC bug 4768
 while (po1 <> nil) and later(po1^.nexttime,ca1) do begin
  po2:= po1;
  po1:= po1^.nextpo;
 end;
 if po1 = nil then begin //last
  if po2 = po then begin //single
   po^.prevpo:= nil;
   first:= po;
  end
  else begin //last
   po^.prevpo:= po2;
   po2^.nextpo:= po;
  end;
  po^.nextpo:= nil;
 end
 else begin
  if po1^.prevpo = nil then begin //first
   po^.prevpo:= nil;
   po1^.prevpo:= po;
   first:= po;
   po^.nextpo:= po1;
  end
  else begin
   po^.prevpo:= po1^.prevpo;
   po^.prevpo^.nextpo:= po;
   po1^.prevpo:= po;
   po^.nextpo:= po1;
  end;
 end;
{$ifdef mse_debugtimer}
 checktimer;
{$endif}
end;

procedure killtimertick(aontimer: proceventty);
var
 po1{,po2}: ptimerinfoty;
begin
 sys_mutexlock(mutex);
 po1:= first;
 while po1 <> nil do begin
  if issamemethod(tmethod(po1^.ontimer),tmethod(aontimer)) then begin
   po1^.ontimer:= nil;
  end;
  po1:= po1^.nextpo;
 end;
 sys_mutexunlock(mutex);
end;

procedure starttimer(const reftime: longword);
var
 int1: integer;
begin
 int1:= first^.nexttime-reftime;
 application.settimer(int1);
end;

procedure settimertick(ainterval: integer;
     const aontimer: proceventty; const aoptions: timeroptionsty);
var
 po: ptimerinfoty;
 time: longword;
begin
 new(po);
 sys_mutexlock(mutex);
 {$ifdef mse_debugtimer}
 inc(timeitemcount);
{$endif}
 time:= sys_gettimeus;
 if to_absolute in aoptions then begin
  ainterval:= ainterval - time;
  if integer(ainterval) < 0 then begin
   ainterval:= 0; //on idle
  end;
 end;
 fillchar(po^,sizeof(timerinfoty),0);
 with po^ do begin
  nexttime:= time + longword(ainterval);
  interval:= ainterval;
  options:= aoptions;
  if ainterval = 0 then begin
   include(options,to_leak); //on idle
  end;
//  if to_single in aoptions{ainterval < 0} then begin
//   interval:= 0;
//  end;
  ontimer:= aontimer;
 end;
 insert(po);
 if first = po then begin
  starttimer(time);
 end
 else begin
  if later(first^.nexttime,time) then begin
   application.postevent(tmseevent.create(ek_timer));
              //timerevent is possibly lost
  end;
 end;
 sys_mutexunlock(mutex);
end;

var
 timebefore: longword;

procedure tick(sender: tobject);
var
 time: longword;
 ca1: longword;
 po,po2: ptimerinfoty;
 ontimer: proceventty;
 int1: integer;
 timeraccesscountbefore: integer;
label
 endlab;
begin
 sys_mutexlock(mutex);
 tapplication1(application).resettimertrigger;
 if first <> nil then begin
{$ifdef mse_debugtimer}
  checktimer;
{$endif}
  time:= sys_gettimeus;
  inc(timeraccesscount);
  timeraccesscountbefore:= timeraccesscount;
  ca1:= time-timebefore;
  timebefore:= time;
  if integer(ca1) < 0 then begin              //clock has been changed
   po:= first;
   while po <> nil do begin
    po^.nexttime:= po^.nexttime + ca1;        //shift timeouts
    po:= po^.nextpo;
   end;
  end;
  po:= first;
  while (po <> nil) and laterorsame(po^.nexttime,time) do begin
   extract(po);
   ontimer:= po^.ontimer;
   po2:= po^.nextpo;
   if (to_single in po^.options) or not assigned(ontimer) then begin
                  //single shot or killed, remove item
    dispose(po);
   {$ifdef mse_debugtimer}
    dec(timeitemcount);
   {$endif}
    if assigned(ontimer) then begin
     sys_mutexunlock(mutex);
     try
      ontimer;
     except
      application.handleexception(sender);
     end;
     sys_mutexlock(mutex);
     if timeraccesscount <> timeraccesscountbefore then begin
      goto endlab; //processmessages called
     end;
    end;
   end
   else begin
    if to_leak in po^.options then begin
     int1:= 1;
     inc(po^.nexttime,po^.interval);
     if later(po^.nexttime,time) then begin
      po^.nexttime:= time + po^.interval;
     end;
    end
    else begin
     int1:= 0;
     repeat
      inc(int1);
      inc(po^.nexttime,po^.interval)
     until later(time,po^.nexttime);
    end;
    insert(po);
    for int1:= int1 - 1 downto 0 do begin
     if assigned(po^.ontimer) then begin
      sys_mutexunlock(mutex);
      try
       po^.ontimer;
      except
       application.handleexception(sender);
      end;
      sys_mutexlock(mutex);
      if timeraccesscount <> timeraccesscountbefore then begin
       goto endlab; //processmessages called,
                    // tick leak possible for current item
      end;
     end;
    end;
   end;
   po:= po2;
  end;
  if first <> nil then begin
   starttimer(time);
  end;
 end;
endlab:
{$ifdef mse_debugtimer}
 checktimer;
{$endif}
 sys_mutexunlock(mutex);
end;

procedure init;
begin
 sys_mutexcreate(mutex);
end;

procedure deinit;
var
 po1,po2: ptimerinfoty;
begin
 sys_mutexlock(mutex);
 po1:= first;
 while po1 <> nil do begin
  po2:= po1;
  po1:= po1^.nextpo;
  dispose(po2);
 end;
 first:= nil;
 sys_mutexunlock(mutex);
 sys_mutexdestroy(mutex);
end;

{ tsimpletimer }

constructor tsimpletimer.create(const interval: longword; 
                const ontimer: notifyeventty; const active: boolean;
                const aoptions: timeroptionsty);
begin
 finterval:= interval;
 fontimer:= ontimer;
 foptions:= aoptions;
 setenabled(active);
end;

destructor tsimpletimer.destroy;
begin
 enabled:= false;
 inherited;
end;

procedure tsimpletimer.dotimer;
begin
 if (to_single in foptions) {or (finterval = 0)} then begin
  fenabled:= false;
 end;
// if finterval <= 0 then begin
//  fenabled:= false;
// end;
 if assigned(fontimer) then begin
  fontimer(self);
 end;
end;

procedure tsimpletimer.setenabled(const Value: boolean);
begin
 if fenabled <> value then begin
  sys_mutexlock(mutex);
  fenabled:= Value;
  if not value then begin
   killtimertick({$ifdef FPC}@{$endif}dotimer);
  end
  else begin
   settimertick(finterval,{$ifdef FPC}@{$endif}dotimer,foptions);
  end;
  sys_mutexunlock(mutex);
 end;
end;

procedure tsimpletimer.setinterval(const avalue: longword);
begin
 if not (to_absolute in foptions) and (avalue > 2000000000) then begin
  raise exception.create('Invalid timer interval ' + inttostr(avalue));
 end;
 finterval:= avalue;
 if fenabled then begin
  sys_mutexlock(mutex);
  killtimertick({$ifdef FPC}@{$endif}dotimer);
  settimertick(finterval,{$ifdef FPC}@{$endif}dotimer,foptions);
  sys_mutexunlock(mutex);
 end
 else begin
  if foptions * [to_single,to_autostart] = [to_single,to_autostart] then begin
   enabled:= true;
  end;
 end;
end;

procedure tsimpletimer.firependingandstop;
begin
 if fenabled then begin
  enabled:= false;
  dotimer;
 end;
end;

procedure tsimpletimer.fireandstop;
begin
 enabled:= false;
 dotimer;
end;

procedure tsimpletimer.fire;
begin
 dotimer;
end;

procedure tsimpletimer.restart;
begin
 interval:= interval;
 enabled:= true;
end;

function tsimpletimer.getsingleshot: boolean;
begin
 result:= to_single in foptions;
end;

procedure tsimpletimer.setsingleshot(const avalue: boolean);
begin
 if avalue then begin
  options:= options + [to_single];
 end
 else begin
  options:= options - [to_single];
 end;
end;

{ ttimer }

constructor ttimer.create(aowner: tcomponent);
begin
 ftimer:= tsimpletimer.create(1000000,{$ifdef FPC}@{$endif}dotimer,false,[]);
 inherited;
end;

destructor ttimer.destroy;
begin
 ftimer.Free;
 inherited;
end;

function ttimer.getenabled: boolean;
begin
 if csdesigning in componentstate then begin
  result:= fenabled;
 end
 else begin
  result:= ftimer.enabled;
 end;
end;

procedure ttimer.setenabled(const avalue: boolean);
begin
 if not (csdesigning in componentstate) then begin
  if not application.ismainthread then begin
   sys_mutexlock(mutex);
   fenabled:= avalue;
   if avalue and not ftimer.enabled then begin
    asyncevent(enabletimertag); //win32 settimer must be in mainthread
    sys_mutexunlock(mutex);
   end
   else begin
    sys_mutexunlock(mutex);
    ftimer.enabled:= avalue;
   end;
  end
  else begin
   ftimer.enabled:= avalue;
  end;
 end
 else begin
  fenabled:= avalue;
 end;
end;

procedure ttimer.doasyncevent(var atag: integer);
begin
 if fenabled and (atag = enabletimertag) then begin
  ftimer.enabled:= true;
 end;
end;

function ttimer.getinterval: integer;
begin
 result:= ftimer.interval;
end;

procedure ttimer.setinterval(avalue: integer);
begin
 if avalue < 0 then begin
  include(ftimer.foptions,to_single);
  avalue:= -avalue;
 end;
 if not application.ismainthread and ftimer.enabled then begin
  enabled:= false;
  ftimer.interval:= avalue; //win32 settimer must be in main thread
  enabled:= true;
 end
 else begin
  ftimer.interval:= avalue;
 end;
end;

function ttimer.getontimer: notifyeventty;
begin
 result:= ftimer.ontimer;
end;

procedure ttimer.setontimer(const Value: notifyeventty);
begin
 ftimer.ontimer:= value;
end;

procedure ttimer.restart;
begin
 interval:= ftimer.interval;
 enabled:= true;
end;

procedure ttimer.firependingandstop;
begin
 ftimer.firependingandstop;
end;

procedure ttimer.fireandstop;
begin
 ftimer.fireandstop;
end;

procedure ttimer.fire;
begin
 ftimer.fire;
end;

function ttimer.getoptions: timeroptionsty;
begin
 result:= ftimer.options;
end;

procedure ttimer.setoptions(const avalue: timeroptionsty);
begin
 ftimer.options:= avalue - [to_autostart,to_absolute];
end;

function ttimer.getsingleshot: boolean;
begin
 result:= ftimer.singleshot;
end;

procedure ttimer.setsingleshot(const avalue: boolean);
begin
 ftimer.singleshot:= avalue;
end;

procedure ttimer.dotimer(const sender: tobject);
begin
 if canevent(tmethod(fontimer)) then begin
  fontimer(self);
 end;
end;

initialization
 timebefore:= sys_gettimeus;
end.
