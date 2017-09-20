{ MSEgui Copyright (c) 1999-2016 by Martin Schreiber

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
 timeroptionty = (to_single,    //single shot
                  to_leak,      //do not catch up missed timeouts
                  to_highres,   //call application.beginhighrestimer/
                                //endhighrestimer, necessary on windows in order
                                //to get 1ms jitter
                  to_absolute,  //use absolute time (timestamp()) for to_single
                                //disabled for ttimer
                  to_autostart);//set enabled for to_single by setting interval,
                                //disabled for ttimer
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
   procedure setoptions(const avalue: timeroptionsty);
   function gethighres: boolean;
   procedure sethighres(const avalue: boolean);
   function getleak: boolean;
   procedure setleak(const avalue: boolean);
  protected
   procedure dotimer; virtual;
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
   property options: timeroptionsty read foptions write setoptions;
   property singleshot: boolean read getsingleshot write setsingleshot;
   property highres: boolean read gethighres write sethighres;
   property leak: boolean read getleak write setleak;
   property ontimer: notifyeventty read fontimer write fontimer;
   property enabled: boolean read fenabled write setenabled default true;
             //last!
 end;

 trepeater = class(tsimpletimer)
  private
   finterval2: longword;
  protected
   procedure dotimer; override;
  public
   constructor create(const adelay: longword; const ainterval: longword;
                      const aontimer: notifyeventty);
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

const
 defaultanimtick = 100000; //microseconds
 
type
 animkindty = (ank_single,ank_sawtooth,ank_triangle);
 animoptionty = (ano_enabled,
                 ano_autodestroy //animitem destroyed if enable set to false
                                 //or ank_single terminates
                );
 animoptionsty = set of animoptionty;
 
 tanimtimer = class;
 tanimitem = class;
 
 animtickeventty = procedure(const sender: tanimitem; 
                                         const value: flo64) of object;
 animstatety = (ans_down,ans_finished);
 animstatesty = set of animstatety;
 
 tanimitem = class(tlinkedobject)
  private
   fontick: animtickeventty;
   fondisable: notifyeventty;
   procedure setenabled(const avalue: boolean);
   procedure settickus(const avalue: int32);
   procedure setkind(const avalue: animkindty);
   procedure setoptions(const avalue: animoptionsty);
  protected
   fowner: tobject;
   ftimer: tanimtimer;
   fenabled: boolean;
   fref: card32;
   fnexttick: card32;
   ftickus: int32;
   ftickref: card32;
   fkind: animkindty;
   fstate: animstatesty;
   foptions: animoptionsty;
   finterval: flo64;
   ftime: flo64;
   procedure tick(); virtual;
   procedure objectevent(const sender: tobject;
                            const event: objecteventty); override;
   procedure settimer(const atimer: tanimtimer);
   procedure setnexttick();
   procedure setnexttick1();
  public
   constructor create(const aowner: iobjectlink; const atimer: tanimtimer;
                    const aontick: animtickeventty;
                    const ainterval: flo64; //seconds
                    const akind: animkindty = ank_single;
                    const aoptions: animoptionsty = [ano_enabled];
                                   const atickus: int32 = 0); //0 = default
   constructor create(const aowner: tmsecomponent; const atimer: tanimtimer; 
                    const aontick: animtickeventty;
                    const ainterval: flo64; //seconds
                    const akind: animkindty = ank_single;
                    const aoptions: animoptionsty = [ano_enabled];
                                   const atickus: int32 = 0); //0 = default
   destructor destroy(); override;
   procedure reset();
   property kind: animkindty read fkind write setkind;
   property options: animoptionsty read foptions write setoptions;
   property enabled: boolean read fenabled write setenabled;
   property tickus: int32 read ftickus write settickus default 0;
   property time: flo64 read ftime write ftime;
   property interval: flo64 read finterval write finterval;
   property timer: tanimtimer read ftimer write settimer;
   property ontick: animtickeventty read fontick write fontick;
   property ondisable: notifyeventty read fondisable write fondisable;
 end;
 panimitem = ^tanimitem;
 animitemarty = array of tanimitem;
  
 tanimtimer = class(tmsecomponent)
  private
   ftouched: boolean;
   function gettickus: int32;
   procedure settickus(const avalue: int32);
   function gethighres: boolean;
   procedure sethighres(const avalue: boolean);
   procedure setenabled(const avalue: boolean);
  protected
   fenabledcount: int32;
   fitems: animitemarty;
   ftimer: tsimpletimer;
   fenabled: boolean;
   procedure dotimer(const sender: tobject);
   procedure add(const aitem: tanimitem);
   procedure remove(const aitem: tanimitem);
   procedure itemenabled(const avalue: boolean);
   procedure checkenabled();
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property enabledcount: int32 read fenabledcount;
  published
   property tickus: int32 read gettickus write settickus default defaultanimtick;
   property highres: boolean read gethighres write sethighres default false;
   property enabled: boolean read fenabled write setenabled default false;
 end;
 
 tanimitemcomp = class(tmsecomponent)
  private
   fitem: tanimitem;
   fenabled: boolean;
   function getkind: animkindty;
   procedure setkind(const avalue: animkindty);
   function getoptions: animoptionsty;
   procedure setoptions(const avalue: animoptionsty);
   function gettimer: tanimtimer;
   procedure settimer(const avalue: tanimtimer);
   function getenabled: boolean;
   procedure setenabled(const avalue: boolean);
   function gettickus: int32;
   procedure settickus(const avalue: int32);
   function gettime: flo64;
   procedure settime(const avalue: flo64);
   function getontick: animtickeventty;
   procedure setontick(const avalue: animtickeventty);
   function getondisable: notifyeventty;
   procedure setondisable(const avalue: notifyeventty);
   function getinterval: flo64;
   procedure setinterval(const avalue: flo64);
  protected
   procedure loaded() override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy(); override;
   procedure reset();
   procedure restart();
   property time: flo64 read gettime write settime;
  published
   property kind: animkindty read getkind write setkind default ank_single;
//   property options: animoptionsty read getoptions write setoptions;
   property interval: flo64 read getinterval write setinterval;
   property enabled: boolean read getenabled write setenabled default false;
   property timer: tanimtimer read gettimer write settimer;
   property tickus: int32 read gettickus write settickus default defaultanimtick;
   property ontick: animtickeventty read getontick write setontick;
   property ondisable: notifyeventty read getondisable write setondisable;
 end;
 
procedure tick(sender: tobject);
procedure init;
procedure deinit;

implementation
uses
 msesysintf1,msesysintf,SysUtils,mseapplication,msesystypes,msesysutils,
 msearrayutils,
 mseformatstr{$ifndef mswindows},mselibc{$endif};

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
   if to_highres in foptions then begin
    application.endhighrestimer();
   end;
   killtimertick({$ifdef FPC}@{$endif}dotimer);
  end
  else begin
   if to_highres in foptions then begin
    application.beginhighrestimer();
   end;
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
 if assigned(fontimer) then begin //do not clear fenabled
  fontimer(self);
 end;
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

procedure tsimpletimer.setoptions(const avalue: timeroptionsty);
var
 opt1: timeroptionsty;
begin
 opt1:= foptions >< avalue;
 if opt1 <> [] then begin
  foptions:= avalue;
  if enabled then begin
   if to_highres in opt1 then begin
    if to_highres in avalue then begin
     application.beginhighrestimer();
    end
    else begin
     application.endhighrestimer();
    end;
   end;
  end;
 end;
end;

function tsimpletimer.gethighres: boolean;
begin
 result:= to_highres in foptions;
end;

procedure tsimpletimer.sethighres(const avalue: boolean);
begin
 if avalue then begin
  options:= foptions + [to_highres];
 end
 else begin
  options:= foptions - [to_highres];
 end;
end;

function tsimpletimer.getleak: boolean;
begin
 result:= to_leak in foptions;
end;

procedure tsimpletimer.setleak(const avalue: boolean);
begin
 if avalue then begin
  options:= foptions + [to_leak];
 end
 else begin
  options:= foptions - [to_leak];
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

{ trepeater }

constructor trepeater.create(const adelay: longword; const ainterval: longword;
                             const aontimer: notifyeventty);
begin
 finterval2:= ainterval;
 inherited create(adelay,aontimer,true,[]);
end;

procedure trepeater.dotimer;
begin
 if finterval <> finterval2 then begin
  interval:= finterval2;
 end;
 inherited;
end;

{ tanimitem }

constructor tanimitem.create(const aowner: iobjectlink;
               const atimer: tanimtimer;
               const aontick: animtickeventty;
               const ainterval: flo64;
               const akind: animkindty = ank_single;
               const aoptions: animoptionsty = [ano_enabled];
                                             const atickus: int32 = 0);
begin
 ftickus:= atickus;
 fontick:= aontick;
 finterval:= ainterval;
 fkind:= akind;
 foptions:= aoptions;
 if aowner <> nil then begin
  fowner:= aowner.getinstance();
  getobjectlinker.link(iobjectlink(self),aowner);
 end;
 settimer(atimer);
 inherited create();
 enabled:= ano_enabled in aoptions;
end;

constructor tanimitem.create(const aowner: tmsecomponent; 
               const atimer: tanimtimer;
               const aontick: animtickeventty;
               const ainterval: flo64;
               const akind: animkindty = ank_single;
               const aoptions: animoptionsty = [ano_enabled];
                                            const atickus: int32 = 0);
var
 ev1: ievent;
begin
 ev1:= nil;
 if aowner <> nil then begin
  ev1:= ievent(aowner);
 end;
 create(ev1,atimer,aontick,ainterval,akind,aoptions,atickus);
end;

destructor tanimitem.destroy();
begin
 settimer(nil);
 inherited;
end;

procedure tanimitem.reset();
begin
 ftime:= 0;
 fstate:= fstate - [ans_down,ans_finished];
end;

procedure tanimitem.setnexttick();
begin
 fref:= timebefore;
 setnexttick1;
end;

procedure tanimitem.setnexttick1();
begin
 if ftickus = 0 then begin
  fnexttick:= timebefore+ftimer.tickus;
 end
 else begin
  fnexttick:= timebefore+ftickus;
 end;
end;

procedure tanimitem.tick();
var
 c1: card32;
 f1: flo64;
 b1: boolean;
begin
 if (ftickus = 0) or (ftickus = ftimer.tickus) or 
                          laterorsame(fnexttick,timebefore) then begin
  c1:= timebefore-fref;
//  if int32(c1) >= 0 then begin
   if finterval > 0 then begin
    ftime:= ftime + (c1/1000000)/finterval; //seconds
   end;
   b1:= false;
   while ftime > 1 do begin
    if fkind = ank_single then begin
     b1:= true;
     ftime:= 1;
     break;
    end;
    ftime:= ftime-1;
    fstate:= fstate >< [ans_down];
   end;
   f1:= ftime;
   if (fkind = ank_triangle) and (ans_down in fstate) then begin
    f1:= 1-f1;
   end;
   fref:= timebefore;
   setnexttick1();
   if assigned(fontick) then begin
    fontick(self,f1);
   end;
   if b1 then begin
    enabled:= false;
    include(fstate,ans_finished);
   end;
//  end
//  else begin
   setnexttick1;
//  end;
 end;
end;

procedure tanimitem.objectevent(const sender: tobject;
               const event: objecteventty);
begin
 if (event = oe_destroyed) then begin
  if sender = ftimer then begin
   ftimer:= nil;
  end;
  if sender = fowner then begin
   destroy();
  end;
 end;
end;

procedure tanimitem.setenabled(const avalue: boolean);
begin
 if fenabled <> avalue then begin
  if not avalue or not(ans_finished in fstate) then begin
   fenabled:= avalue;
   if ftimer <> nil then begin
    if avalue then begin
     fref:= timebefore;
     fnexttick:= fref;
     tick(); //immediately
    end;
    ftimer.itemenabled(avalue);
   end;
   if not enabled then begin
    if assigned(fondisable) then begin
     fondisable(self);
    end;
    if ano_autodestroy in foptions then begin
     destroy();
    end;
   end;
  end;
 end;
end;

procedure tanimitem.settickus(const avalue: int32);
begin
 if ftickus <> avalue then begin
  ftickus:= avalue;
  setnexttick();
 end;
end;

procedure tanimitem.setkind(const avalue: animkindty);
begin
 fkind:= avalue;
end;

procedure tanimitem.setoptions(const avalue: animoptionsty);
begin
 foptions:= avalue;
end;

procedure tanimitem.settimer(const atimer: tanimtimer);
begin
 if ftimer <> atimer then begin
  if ftimer <> nil then begin
   ftimer.remove(self);
  end;
  ftimer:= atimer;
  if ftimer <> nil then begin
   ftimer.add(self);
  end;
 end;
end;

{ tanimtimer }

constructor tanimtimer.create(aowner: tcomponent);
begin
 ftimer:= tsimpletimer.create(defaultanimtick,@dotimer,false,[to_leak]);
 inherited;
end;

destructor tanimtimer.destroy;
begin
 enabled:= false;
 ftimer.free;
 inherited;
end;

function tanimtimer.gettickus: int32;
begin
 result:= ftimer.interval;
end;

procedure tanimtimer.settickus(const avalue: int32);
begin
 ftimer.interval:= avalue;
end;

function tanimtimer.gethighres: boolean;
begin
 result:= ftimer.highres;
end;

procedure tanimtimer.sethighres(const avalue: boolean);
begin
 ftimer.highres:= avalue;
end;

procedure tanimtimer.setenabled(const avalue: boolean);
begin
 fenabled:= avalue;
 checkenabled();
end;

procedure tanimtimer.dotimer(const sender: tobject);
var
 p1,pe: panimitem;
 i1: int32;
label
 loopstart;
begin
 i1:= 0;
 while i1 < 8 do begin //emergency brake
loopstart:
  if fenabledcount > 0 then begin
   p1:= pointer(fitems);
   pe:= p1+high(fitems);
   while p1 <= pe do begin
    if p1^.enabled then begin
     ftouched:= false;
     p1^.tick(); 
     if ftouched then begin
      goto loopstart;
     end;
    end;
    inc(p1);
   end;
   break;
  end
  else begin
   break;
  end;
  inc(i1);
 end;
end;

procedure tanimtimer.add(const aitem: tanimitem);
begin
 if addnewitem(pointerarty(fitems),aitem) >= 0 then begin
  ftouched:= true;
  aitem.getobjectlinker.link(self);
  if aitem.enabled then begin
   itemenabled(true);
  end;
 end;
end;

procedure tanimtimer.remove(const aitem: tanimitem);
begin
 if removeitem(pointerarty(fitems),aitem) >= 0 then begin
  ftouched:= true;
  aitem.getobjectlinker.unlink(self);
  if aitem.enabled then begin
   itemenabled(false);
  end;
 end;
end;

procedure tanimtimer.itemenabled(const avalue: boolean);
begin
 if avalue then begin
  inc(fenabledcount);
  checkenabled();
 end
 else begin
  dec(fenabledcount);
  if fenabledcount <= 0 then begin
   ftimer.enabled:= false;
  end;
 end;
end;

procedure tanimtimer.checkenabled();
var
 p1,pe: panimitem;
begin
 if fenabled and (fenabledcount > 0) then begin
  if not ftimer.enabled then begin
   p1:= pointer(fitems);
   pe:= p1+high(fitems);
   while p1 <= pe do begin
    if p1^.enabled then begin
     p1^.setnexttick();
    end;
    inc(p1);
   end;
   ftimer.enabled:= true;
  end;
 end
 else begin
  ftimer.enabled:= false;
 end;
end;

{ tanimitemcomp }

constructor tanimitemcomp.create(aowner: tcomponent);
begin
 fitem:= tanimitem.create(self,nil,nil,1.0,ank_single,[],defaultanimtick);
 inherited;
end;

destructor tanimitemcomp.destroy();
begin
 fitem.free;
 inherited;
end;

function tanimitemcomp.getkind: animkindty;
begin
 result:= fitem.kind;
end;

procedure tanimitemcomp.setkind(const avalue: animkindty);
begin
 fitem.kind:= avalue;
end;

function tanimitemcomp.getoptions: animoptionsty;
begin
 result:= fitem.options;
end;

procedure tanimitemcomp.setoptions(const avalue: animoptionsty);
begin
 fitem.options:= avalue - [ano_autodestroy];
end;

function tanimitemcomp.gettimer: tanimtimer;
begin
 result:= fitem.timer;
end;

procedure tanimitemcomp.settimer(const avalue: tanimtimer);
begin
 fitem.timer:= avalue;
end;

function tanimitemcomp.getenabled: boolean;
begin
 result:= fitem.enabled;
end;

procedure tanimitemcomp.setenabled(const avalue: boolean);
begin
 fenabled:= avalue;
 if not (csreading in componentstate) then begin
  fitem.enabled:= avalue;
 end;
end;

function tanimitemcomp.gettickus: int32;
begin
 result:= fitem.tickus;
end;

procedure tanimitemcomp.settickus(const avalue: int32);
begin
 fitem.tickus:= avalue;
end;

function tanimitemcomp.gettime: flo64;
begin
 result:= fitem.time;
end;

procedure tanimitemcomp.settime(const avalue: flo64);
begin
 fitem.time:= avalue;
end;

function tanimitemcomp.getontick: animtickeventty;
begin
 result:= fitem.ontick;
end;

procedure tanimitemcomp.setontick(const avalue: animtickeventty);
begin
 fitem.ontick:= avalue;
end;

function tanimitemcomp.getondisable: notifyeventty;
begin
 result:= fitem.ondisable;
end;

procedure tanimitemcomp.setondisable(const avalue: notifyeventty);
begin
 fitem.ondisable:= avalue;
end;

function tanimitemcomp.getinterval: flo64;
begin
 result:= fitem.interval;
end;

procedure tanimitemcomp.setinterval(const avalue: flo64);
begin
 fitem.interval:= avalue;
end;

procedure tanimitemcomp.reset();
begin
 fitem.reset;
end;

procedure tanimitemcomp.restart();
begin
 reset();
 enabled:= true;
end;

procedure tanimitemcomp.loaded();
begin
 inherited;
 if fenabled then begin
  fitem.enabled:= true;
 end;
end;

initialization
{$ifndef mswindows}
 initlibc(); //clock_gettime must be inited
{$endif}
 timebefore:= sys_gettimeus;
end.
