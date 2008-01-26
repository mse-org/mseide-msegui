{ MSEgui Copyright (c) 1999-2007 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msethread;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
{$ifndef FPC}{$ifdef linux} {$define UNIX} {$endif}{$endif}

interface
uses
 {$ifdef FPC}{$ifdef UNIX}cthreads,{$endif}classes{$else}Classes{$endif},
 mseclasses,mselist,mseevent,msesys,msetypes,sysutils;

type
 tmsethread = class;

 threadprocty = function(thread: tmsethread): integer of object;

 threadstatety = (ts_started,ts_running,ts_terminated);
 threadstatesty = set of threadstatety;

 tmsethread = class
  private
   finfo: threadinfoty;
   fthreadproc: threadprocty;
   fexecresult: integer;
   fstate: threadstatesty;
   fwaitforsem: semty;
   function internalthreadproc: integer;
   function getrunning: boolean;
   function getterminated: boolean;
  protected
   function execute(thread: tmsethread): integer; virtual;
  public
   constructor create; overload;
   constructor create(athreadproc: threadprocty); overload; virtual;
   destructor destroy; override;
   function waitfor: integer; virtual;
   procedure terminate; virtual;
   procedure kill; //killing a running thread will loose resources!
   property running: boolean read getrunning;
   property terminated: boolean read getterminated;
   property id: threadty read finfo.id;
 end;

 tmutexthread = class(tmsethread)
  private
   fmutex: mutexty;
  public
   constructor create(athreadproc: threadprocty); overload; override;
   destructor destroy; override;
   function lock: boolean; //true if ok
   procedure unlock;
 end;

 tsemthread = class(tmutexthread)
  private
   fsem: semty;
  public
   constructor create(athreadproc: threadprocty); overload; override;
   destructor destroy; override;
   function semwait: boolean; //true if not destroyed
   function sempost: boolean; //true if not destroyed
   function semtrywait: boolean;
   function semcount: integer;
 end;

 teventthread = class(tsemthread)
  private
   feventlist: teventqueue;
  public
   constructor create(athreadproc: threadprocty); overload; override;
   destructor destroy; override;
   procedure terminate; override;
   procedure postevent(event: tevent);
   function waitevent(noblock: boolean = false): tevent;
   function eventcount: integer;
 end;

 tsynchronizeevent = class(tevent)
  private
   fsem: semty;
   fsuccess: boolean;
   fexceptionclass: exceptclass;
   fexceptionmessage: string;
   fquiet: boolean;
  protected
   procedure execute; virtual; abstract;
  public
   constructor create(const aquiet: boolean);
         //quiet -> show no exceptions
   destructor destroy; override; 
   procedure free1; override; //do nothing
   procedure deliver;
   function waitfor: boolean;
   property success: boolean read fsuccess;
   property exeptionclass: exceptclass read fexceptionclass;
   property exceptionmessage: string read fexceptionmessage;
 end;

function synchronizeevent(const aevent: tsynchronizeevent): boolean;
          //true if not aborted

implementation

uses
 msesysintf,mseapplication;
 
function synchronizeevent(const aevent: tsynchronizeevent): boolean;
          //true if not aborted
var
 int1: integer;
begin
 result:= false;
 if not application.terminated then begin
  int1:= application.unlockall;
  try
   application.postevent(aevent);
   result:= aevent.waitfor and aevent.success;
  finally
   application.relockall(int1);
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
 inherited create(ek_synchronize);
end;

destructor tsynchronizeevent.destroy;
begin
 sys_semdestroy(fsem);
 inherited;
end;

procedure tsynchronizeevent.deliver;
begin
 try
  execute;
  fsuccess:= true;
 except
  on e: exception do begin
   fexceptionclass:= exceptclass(e.classinfo);
   fexceptionmessage:= e.message;
   if not fquiet then begin
    sys_sempost(fsem);
    raise;
   end;
  end;
 end;
 sys_sempost(fsem);
end;

function tsynchronizeevent.waitfor: boolean;
begin
 result:= sys_semwait(fsem,0) = sye_ok;
end;

procedure tsynchronizeevent.free1;
begin
 if application.terminated then begin
  sys_sempost(fsem);
 end;
end;

{ tmsethread }

constructor tmsethread.create;
begin
 create({$ifdef FPC}@{$endif}execute);
end;

constructor tmsethread.create(athreadproc: threadprocty);
begin
 sys_semcreate(fwaitforsem,0);
 fthreadproc:= athreadproc;
 fstate:= [ts_running,ts_started];
 with finfo do begin
  threadproc:= {$ifdef FPC}@{$endif}internalthreadproc;
 end;
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
begin
 try
  result:= fthreadproc(self);
 except
  result:= -1;
  application.handleexception(self);
 end;
 fexecresult:= result;
 exclude(fstate,ts_running);
 sys_sempost(fwaitforsem);
end;

{ tmutexthread }

constructor tmutexthread.create(athreadproc: threadprocty);
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

constructor teventthread.create(athreadproc: threadprocty);
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

procedure teventthread.postevent(event: tevent);
begin
 feventlist.post(event);
end;

procedure teventthread.terminate;
begin
 inherited;
 postevent(tevent.create(ek_terminate));
end;

function teventthread.waitevent(noblock: boolean = false): tevent;
begin
 result:= feventlist.wait(noblock);
 if (result <> nil) and (result.kind = ek_terminate) then begin
  freeandnil(result);
 end;
end;

{ tsemthread }

constructor tsemthread.create(athreadproc: threadprocty);
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

function tsemthread.semwait: boolean;
begin
 result:= sys_semwait(fsem,0) = sye_ok;
end;

end.
