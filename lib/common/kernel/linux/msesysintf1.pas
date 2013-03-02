{ MSEgui Copyright (c) 1999-2011 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msesysintf1;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msesystypes,mselibc;
type
 linuxmutexty = record
  case integer of
   0: (mutex: pthread_mutex_t;);
   1: (_bufferspace: mutexty;);
 end;
 linuxconddty = record
  cond: tcondvar;
  mutex: pthread_mutex_t;
 end;
 linuxcondty = record
  case integer of
   0: (d: linuxconddty;);
   1: (_bufferspace: condty;);
 end;

 linuxsemdty = record
  destroyed: integer;
  sema: tsemaphore;
 end;
 linuxsemty = record
  case integer of
   0: (d: linuxsemdty;);
   1: (_bufferspace: semty;);
 end;

{$ifdef FPC}
 {$include ..\msesysintf1.inc}
{$else}
 {$include msesysintf1.inc}
{$endif}
 
function unigettimestamp(timeoutusec: integer): timespec;

implementation

uses
 {$ifdef FPC}dateutils,{$endif}msedate;

{$ifdef mse_debugmutex}
var
 mutexsequ: integer;
 mutexcount: integer;
 appmutexcount: integer;
 appmutexlockth: threadty;
 appmutexlockc: integer;
 appmutexlocks: integer;
 appmutexunlockth: threadty;
 appmutexunlockc: integer;
 appmutexunlocks: integer;
{$endif}
 
function unigettimestamp(timeoutusec: integer): timespec;
var
 ti: timeval;
begin
 gettimeofday(@ti,nil);
 ti.tv_usec:= ti.tv_usec + timeoutusec;
 result.tv_sec:= ti.tv_sec + integer(longword(ti.tv_usec) div 1000000);
 result.tv_nsec:= (longword(ti.tv_usec) mod 1000000) * 1000;
end;

function sys_getlasterror: Integer;
begin
 {$ifdef FPC}{$checkpointer off}{$endif}
 Result := __errno_location()^;
 {$ifdef FPC}{$checkpointer default}{$endif}
end;

procedure sys_setlasterror(const avalue: integer);
begin
 {$ifdef FPC}{$checkpointer off}{$endif}
 __errno_location()^:= avalue;
 {$ifdef FPC}{$checkpointer default}{$endif}
end;

function sys_geterrortext(aerror: integer): string;
const
 buflen = 1024;
var
 buffer: array[0..buflen] of char;
 po1: pchar;
begin
 result:= ''; //compilerwarning
 po1:= strerror_r(aerror,pchar(@buffer),buflen);
 setstring(result,po1,strlen(po1));
end;

procedure initmutex(out mutex: pthread_mutex_t);
var
 attr: tmutexattribute;
begin
 pthread_mutexattr_init(attr);
 pthread_mutexattr_settype(attr,recursive);
// attr.__mutexkind:= recursive;
 pthread_mutex_init(@mutex,@attr);
 pthread_mutexattr_destroy(attr);
end;

procedure destroymutex(var mutex: pthread_mutex_t);
begin
 while pthread_mutex_destroy(mutex) = ebusy do begin
  pthread_mutex_unlock(mutex);
  {$ifdef mse_debugmutex}
  interlockeddecrement(mutexcount);
  if application.getmutexaddr = @mutex then begin
   interlockeddecrement(appmutexcount);
  end;
  {$endif}
 end;
end;

function sys_mutexcreate(out mutex: mutexty): syserrorty;
begin
 initmutex(linuxmutexty(mutex).mutex);
 result:= sye_ok;
end;

function sys_mutexdestroy(var mutex: mutexty): syserrorty;
begin
 destroymutex(linuxmutexty(mutex).mutex);
 result:= sye_ok;
end;

function sys_mutexlock(var mutex: mutexty): syserrorty;
begin
 if pthread_mutex_lock(linuxmutexty(mutex).mutex) = 0 then begin
  result:= sye_ok;
  {$ifdef mse_debugmutex}
  interlockedincrement(mutexsequ);
  interlockedincrement(mutexcount);
  if application.getmutexaddr = @mutex then begin
   interlockedincrement(appmutexcount);
   appmutexlockth:= sys_getcurrentthread;
   appmutexlockc:= appmutexcount;
   appmutexlocks:= mutexsequ;
  end;
  {$endif}
 end
 else begin
  result:= sye_mutex;
 end;
end;

function sys_mutextrylock(var mutex: mutexty): syserrorty;
var
 int1: integer;
begin
 int1:= pthread_mutex_trylock(linuxmutexty(mutex).mutex);
 {$ifdef mse_debugmutex}
 if int1 = 0 then begin
  interlockedincrement(mutexsequ);
  interlockedincrement(mutexcount);
  if application.getmutexaddr = @mutex then begin
   interlockedincrement(appmutexcount);
   appmutexlockth:= sys_getcurrentthread;
   appmutexlockc:= appmutexcount;
   appmutexlocks:= mutexsequ;
  end;
 end;
 {$endif}
 case int1 of
  0: result:= sye_ok;
  ebusy: result:= sye_busy;
  else result:= sye_mutex;
 end;
end;

function sys_mutexunlock(var mutex: mutexty): syserrorty;
begin
 {$ifdef mse_debugmutex}
 interlockedincrement(mutexsequ);
 interlockeddecrement(mutexcount);
 if application.getmutexaddr = @mutex then begin
  interlockeddecrement(appmutexcount);
  appmutexunlockth:= sys_getcurrentthread;
  appmutexunlockc:= appmutexcount;
  appmutexunlocks:= mutexsequ;
 end;
 {$endif}
 if pthread_mutex_unlock(linuxmutexty(mutex).mutex) = 0 then begin
  result:= sye_ok;
 end
 else begin
  result:= sye_mutex;
 end;
end;

function sys_semcreate(out sem: semty; count: integer): syserrorty;
begin
 fillchar(sem,sizeof(sem),0);
 with linuxsemty(sem) do begin
  if sem_init(d.sema,{$ifdef FPC}0{$else}false{$endif},count) = 0 then begin
   result:= sye_ok;
  end
  else begin
   result:= sye_semaphore;
  end;
 end;
end;

function sempost1(var sem: semty): syserrorty;
begin
 with linuxsemty(sem) do begin
  if sem_post(d.sema) = 0 then begin
   result:= sye_ok;
  end
  else begin
   result:= sye_semaphore;
  end;
 end;
end;

function sys_sempost(var sem: semty): syserrorty;
begin
 with linuxsemty(sem) do begin
  if d.destroyed <> 0 then begin
   result:= sye_semaphore;
   exit;
  end;
 end;
 result:= sempost1(sem);
end;

function sys_semdestroy(var sem: semty): syserrorty;
var
 int1: integer;
begin
 result:= sye_ok;
 with linuxsemty(sem) do begin
  int1:= interlockedincrement(d.destroyed);
  if int1 = 1 then begin
   while sys_semcount(sem) = 0 do begin
    if sem_post(d.sema) <> 0 then begin
     break;
    end;
   end;
   sem_destroy(d.sema);
  end;
 end;
end;

function sys_semwait(var sem: semty;  timeoutusec: integer): syserrorty;
          //timeoutus = 0 -> no timeout;
var
 time1: ttimespec;
// err: integer;
begin
 result:= sye_semaphore;
 with linuxsemty(sem) do begin
  if d.destroyed <> 0 then begin
   exit;
  end;
  if timeoutusec <= 0 then begin
   while sem_wait(d.sema) <> 0 do begin
    if sys_getlasterror <> eintr then begin
     exit;
    end;
   end;
  end
  else begin
   time1:= unigettimestamp(timeoutusec);
   while sem_timedwait(d.sema,@time1) <> 0 do begin
    case sys_getlasterror of
     eintr: begin
     end;
     etimedout: begin
      result:= sye_timeout;
      exit;
     end
     else begin
      exit;
     end;
    end;
   end;
  end;
 end;
 result:= sye_ok;
end;

function sys_semtrywait(var sem: semty): boolean;
begin
 with linuxsemty(sem) do begin
  if d.destroyed <> 0 then begin
   result:= false;
   exit;
  end;
  repeat
   result:= sem_trywait(d.sema) = 0;
  until result or (sys_getlasterror <> eintr);
 end;
end;

function sys_semcount(var sem: semty): integer;
begin
 with linuxsemty(sem) do begin
  sem_getvalue(d.sema,{$ifdef FPC}@{$endif}result);
 end;
end;

function sys_condcreate(out cond: condty): syserrorty;
begin
 pthread_cond_init(linuxcondty(cond).d.cond,nil);
 initmutex(linuxcondty(cond).d.mutex);
 result:= sye_ok;
end;

function sys_conddestroy(var cond: condty): syserrorty;
begin
 while true do begin
  pthread_mutex_lock(linuxcondty(cond).d.mutex);
  if pthread_cond_destroy(linuxcondty(cond).d.cond) = 0 then begin
   pthread_mutex_unlock(linuxcondty(cond).d.mutex);
   destroymutex(linuxcondty(cond).d.mutex);
   break;
  end;
  pthread_cond_broadcast(linuxcondty(cond).d.cond);
  pthread_mutex_unlock(linuxcondty(cond).d.mutex);
 end;
 result:= sye_ok;
end;

function sys_condlock(var cond: condty): syserrorty;
begin
 pthread_mutex_lock(linuxcondty(cond).d.mutex);
 result:= sye_ok;
end;

function sys_condunlock(var cond: condty): syserrorty;
begin
 pthread_mutex_unlock(linuxcondty(cond).d.mutex);
 result:= sye_ok;
end;

function sys_condsignal(var cond: condty): syserrorty;
begin
 pthread_cond_signal(linuxcondty(cond).d.cond);
 result:= sye_ok;
end;

function sys_condbroadcast(var cond: condty): syserrorty;
begin
 pthread_cond_broadcast(linuxcondty(cond).d.cond);
 result:= sye_ok;
end;

function sys_condwait(var cond: condty; timeoutusec: integer): syserrorty;
          //timeoutus = 0 -> no timeout;
          //gue_ok -> condition signaled
          //gue_timeout -> timeout
          //gue_cond -> error
var
 time1: ttimespec;
begin
 result:= sye_ok;
 if timeoutusec = 0 then begin
  pthread_cond_wait(linuxcondty(cond).d.cond,linuxcondty(cond).d.mutex);
 end
 else begin
  time1:= unigettimestamp(timeoutusec);
  if pthread_cond_timedwait(linuxcondty(cond).d.cond,linuxcondty(cond).d.mutex,
             @time1) <> 0 then begin
   result:= sye_timeout;
  end;
 end;
end;

function sys_utctolocaltime(const value: tdatetime): tdatetime;
var
 ti1: integer;
 rea1: real;
 tm: tunixtime;
begin
 rea1:= value + unidatetimeoffset;
 if rea1 < 0 then begin
  ti1:= 0;
 end
 else begin
  ti1:= round(rea1) * 24*60*60; //seconds
 end;
 localtime_r(@ti1,@tm);
 result:= incsecond(value,tm.__tm_gmtoff);
// result:= value + sys_localtimeoffset; 
end;

function sys_localtimetoutc(const value: tdatetime): tdatetime;
var
 year,month,day,hour,minute,second,millisecond: word;
 tm: tunixtime;
begin
 if value < -unidatetimeoffset then begin
  decodedatetime(-unidatetimeoffset,year,month,day,hour,minute,second,millisecond);
 end
 else begin
  decodedatetime(value,year,month,day,hour,minute,second,millisecond);
 end;
 with tm do begin
  tm_sec:= second;
  tm_min:= minute;
  tm_hour:= hour;
  tm_mday:= day;
  tm_mon:= month;
  tm_year:= year-1900;
 end;
 timelocal(tm);
 result:= incsecond(value,-tm.__tm_gmtoff);
// result:= value - sys_localtimeoffset; 
end;

end.
