{ MSEgui Copyright (c) 1999-2014 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msethread;

{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}
{$ifndef FPC}{$ifdef linux} {$define UNIX} {$endif}{$endif}

interface
uses
 {$ifdef FPC}{$ifdef UNIX}cthreads,{$endif}classes{$else}Classes{$endif},
 mseclasses,mselist,mseevent,msesystypes,msesys,msetypes,sysutils;

{$ifndef FPC}
const
  DefaultStackSize = 4*1024*1024;
{$endif}
type
 tmsethread = class;

 threadprocty = function(thread: tmsethread): integer of object;

 threadstatety = (ts_started,ts_running,ts_terminated,ts_freeonterminate,
                  ts_norun); //no run by create()
 threadstatesty = set of threadstatety;

 tmsethread = class
  protected
   finfo: threadinfoty;
   fthreadproc: threadprocty;
   fexecresult: integer;
   fstate: threadstatesty;
   fwaitforsem: semty;
   function internalthreadproc: integer;
   function getrunning: boolean;
   function getterminated: boolean;
   function getfreeonterminate: boolean;
   procedure setfreeonterminate(const avalue: boolean);
   function execute(thread: tmsethread): integer; virtual;
   procedure run(); virtual;
  public
   constructor create; overload;
   constructor create(const afreeonterminate: boolean;
                      const astacksizekb: integer = 0); overload;
   constructor create(const athreadproc: threadprocty;
                const afreeonterminate: boolean = false;
                const astacksizekb: integer = 0); overload; virtual;
   destructor destroy; override;
   procedure afterconstruction; override;
   function waitfor: integer; virtual;
   procedure terminate; virtual;
   procedure kill; //killing a running thread will loose resources!
   property running: boolean read getrunning;
   property terminated: boolean read getterminated;
   property id: threadty read finfo.id;
   property freeonterminate: boolean read getfreeonterminate 
                                          write setfreeonterminate; 
           //do not change the value if the thread is running
 end;

 tmutexthread = class(tmsethread)
  protected
   fmutex: mutexty;
  public
   constructor create(const athreadproc: threadprocty;
                      const afreeonterminate: boolean = false;
                      const astacksizekb: integer = 0); override;
   destructor destroy; override;
   function lock: boolean; //true if ok
   procedure unlock;
 end;

 tsemthread = class(tmutexthread)
  protected
   fsem: semty;
  public
   constructor create(const athreadproc: threadprocty;
                      const afreeonterminate: boolean = false;
                      const astacksizekb: integer = 0); override;
   destructor destroy; override;
   function semwait(const atimeoutus: integer = 0): boolean;
   function sempost: boolean; //true if not destroyed
   function semtrywait: boolean;
   function semcount: integer;
 end;

 teventthread = class(tsemthread)
  protected
   feventlist: teventqueue;
  public
   constructor create(const athreadproc: threadprocty;
                     const afreeonterminate: boolean = false;
                     const astacksizekb: integer = 0); overload; override;
   destructor destroy; override;
   procedure terminate; override;
   procedure postevent(event: tmseevent);
   procedure clearevents;
   function waitevent(const timeoutus: integer = -1): tmseevent;
                 // -1 infinite, 0 no block
   function eventcount: integer;
 end;

 tsynchronizeevent = class(texecuteevent)
  protected
   fsem: semty;
   fsuccess: boolean;
   fexceptionclass: exceptclass;
   fexceptionmessage: string;
   fquiet: boolean;
   procedure internalfree1; override;
  public
   constructor create(const aquiet: boolean);
         //quiet -> show no exceptions
   destructor destroy; override; 
   procedure deliver; override;
   function waitfor: boolean;
   property quiet: boolean read fquiet;
   property success: boolean read fsuccess;
   property exeptionclass: exceptclass read fexceptionclass;
   property exceptionmessage: string read fexceptionmessage;
 end;

function synchronizeevent(const aevent: tsynchronizeevent;
                             const aoptions: posteventoptionsty = []): boolean;
          //true if not aborted, does not free aevent

implementation

uses
 msesysintf1,msesysintf,mseapplication;
 
function synchronizeevent(const aevent: tsynchronizeevent;
                             const aoptions: posteventoptionsty = []): boolean;
          //true if not aborted, does not free aevent
var
 int1: integer;
begin
 if not application.terminated then begin
  if application.ismainthread then begin
   try
    aevent.execute;
    result:= true;
   except
    if not aevent.quiet then begin
     raise;
    end;
    result:= false;
   end;
  end
  else begin
   result:= false;
   int1:= application.unlockall;
   try
    application.postevent(aevent,aoptions);
    result:= aevent.waitfor and aevent.success;
     //wait until main eventloop calls tevent.free1
   finally
    application.relockall(int1);
   end;
  end;
 end;
end;

procedure createthread(var info: threadinfoty);
begin
 syserror(sys_threadcreate(info));
end;

{ tsynchronizeevent }

constructor tsynchronizeevent.create(const aquiet: boolean);
begin
 fquiet:= aquiet;
 sys_semcreate(fsem,0);
 inherited create;
end;

destructor tsynchronizeevent.destroy;
begin
 sys_semdestroy(fsem);
 inherited;
end;

procedure tsynchronizeevent.deliver;
begin
 try
  inherited;
//  execute;
  fsuccess:= true;
 except
  on e: exception do begin
   fexceptionclass:= exceptclass(e.classinfo);
   fexceptionmessage:= e.message;
   if not fquiet then begin
//    sys_sempost(fsem);
    raise;
   end;
  end;
 end;
// sys_sempost(fsem);
end;

function tsynchronizeevent.waitfor: boolean;
begin
 result:= sys_semwait(fsem,0) = sye_ok;
end;

procedure tsynchronizeevent.internalfree1;
begin
 sys_sempost(fsem); //no inherited, don't free in main eventloop
end;

{ tmsethread }

constructor tmsethread.create;
begin
 create(false);
end;

constructor tmsethread.create(const afreeonterminate: boolean;
                                              const astacksizekb: integer = 0);
begin
 create({$ifdef FPC}@{$endif}execute,afreeonterminate,astacksizekb);
end;

constructor tmsethread.create(const athreadproc: threadprocty;
                                 const afreeonterminate: boolean = false;
                                 const astacksizekb: integer = 0);
begin
 sys_semcreate(fwaitforsem,0);
 fthreadproc:= athreadproc;
// fstate:= [ts_running,ts_started];
 if afreeonterminate then begin
  include(fstate,ts_freeonterminate);
 end;
 with finfo do begin
  if astacksizekb = 0 then begin
   stacksize:= defaultstacksize;
  end
  else begin
   stacksize:= astacksizekb * 1024;
  end;
  threadproc:= {$ifdef FPC}@{$endif}internalthreadproc;
 end;
{
 if not (ts_norun in fstate) then begin
  run();
 end;
}
end;

procedure tmsethread.afterconstruction;
begin
 if not (ts_norun in fstate) then begin
  run();
 end;
 if ts_freeonterminate in fstate then begin
  sys_sempost(fwaitforsem);
 end;
end;

procedure tmsethread.run();
begin
 fstate:= fstate + [ts_running,ts_started];
 createthread(finfo);
end;

destructor tmsethread.destroy;
begin
 if finfo.id <> 0 then begin
  terminate;
  waitfor;
  sys_threadwaitfor(finfo);
  kill;
 end;
 inherited;
end;

procedure tmsethread.terminate;
begin
 include(fstate,ts_terminated);
end;

function tmsethread.waitfor: integer;
begin
 if ts_started in fstate then begin
  if ts_freeonterminate in fstate then begin
   raise exception.create('No waitfor() if ts_freeonterminate set.');
  end;
  exclude(fstate,ts_started);
  sys_semwait(fwaitforsem,0);
 end;
 result:= fexecresult;
end;

procedure tmsethread.kill;
begin
 if (self <> nil) and (finfo.id <> 0) then begin
  exclude(fstate,ts_running);
  sys_threaddestroy(finfo);
  finfo.id:= 0;
  sys_semdestroy(fwaitforsem);
 end;
end;

function tmsethread.getrunning: boolean;
begin
 result:= ts_running in fstate;
end;

function tmsethread.getterminated: boolean;
begin
 result:= ts_terminated in fstate;
end;

function tmsethread.execute(thread: tmsethread): integer;
begin
 result:= 0;
end;

function tmsethread.internalthreadproc: integer;
var
 info1: threadinfoty;
begin
 try
  result:= fthreadproc(self);
 except
  result:= -1;
  application.handleexception(self);
 end;
 fexecresult:= result;
 exclude(fstate,ts_running);
 if not freeonterminate then begin
  sys_sempost(fwaitforsem);
 end
 else begin
  sys_semwait(fwaitforsem,0);
  info1:= finfo;
  finfo.id:= 0;
  free();
  sys_threaddestroy(info1);
 end;
end;

function tmsethread.getfreeonterminate: boolean;
begin
 result:= ts_freeonterminate in fstate;
end;

procedure tmsethread.setfreeonterminate(const avalue: boolean);
begin
 if avalue then begin
  include(fstate,ts_freeonterminate);
  sys_semtrywait(fwaitforsem); //remove possible afterconstruction post
 end
 else begin
  exclude(fstate,ts_freeonterminate);
 end;
end;

{ tmutexthread }

constructor tmutexthread.create(const athreadproc: threadprocty;
                               const afreeonterminate: boolean = false;
                               const astacksizekb: integer = 0);
begin
 syserror(sys_mutexcreate(fmutex),self);
 inherited;
end;

destructor tmutexthread.destroy;
begin
 inherited;
 sys_mutexdestroy(fmutex);
end;

function tmutexthread.lock: boolean;
begin
 result:= sys_mutexlock(fmutex) = sye_ok;
end;

procedure tmutexthread.unlock;
begin
 sys_mutexunlock(fmutex);
end;

{ teventthread }

constructor teventthread.create(const athreadproc: threadprocty;
                       const afreeonterminate: boolean = false;
                       const astacksizekb: integer = 0);
begin
 feventlist:= teventqueue.create(true);
 inherited;
end;

destructor teventthread.destroy;
begin
 inherited;
 feventlist.Free;
end;

function teventthread.eventcount: integer;
begin
 result:= feventlist.count;
end;

procedure teventthread.postevent(event: tmseevent);
begin
 feventlist.post(event);
end;

procedure teventthread.terminate;
begin
 inherited;
 postevent(tmseevent.create(ek_terminate));
end;

function teventthread.waitevent(const timeoutus: integer = -1): tmseevent;
begin
 result:= feventlist.wait(timeoutus);
 if (result <> nil) and (result.kind = ek_terminate) then begin
  freeandnil(result);
 end;
end;

procedure teventthread.clearevents;
begin
 feventlist.clear;
end;

{ tsemthread }

constructor tsemthread.create(const athreadproc: threadprocty;
                              const afreeonterminate: boolean = false;
                              const astacksizekb: integer = 0);
begin
 sys_semcreate(fsem,0);
 inherited;
end;

destructor tsemthread.destroy;
begin
 terminate;
 sys_semdestroy(fsem);
 inherited;
end;

function tsemthread.semcount: integer;
begin
 result:= sys_semcount(fsem);
end;

function tsemthread.sempost: boolean;
begin
 result:= sys_sempost(fsem) = sye_ok;
end;

function tsemthread.semtrywait: boolean;
begin
 result:= sys_semtrywait(fsem);
end;

function tsemthread.semwait(const atimeoutus: integer = 0): boolean;
begin
 result:= sys_semwait(fsem,atimeoutus) = sye_ok;
end;

end.
