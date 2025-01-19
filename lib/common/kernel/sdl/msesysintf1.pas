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
 msesystypes,sdl4msegui;
var
 iswin95: boolean;
 iswin98: boolean;
 cancleartype: boolean;

{$include ..\msesysintf1.inc}

implementation
uses
 sysutils,dateutils,msedynload;
 
type
 condeventsty = (ce_signal,ce_broadcast);
   
function sys_getlasterror: Integer;
begin
 //result:= windows.GetLastError;
end;

procedure sys_setlasterror(const avalue: integer);
begin
 //windows.setlasterror(avalue);
end;

function sys_geterrortext(aerror: integer): string;
const
 maxlen = 1024;
var
 int1: integer;
begin
 setlength(result,maxlen);
 //int1:= formatmessage(format_message_from_system,nil,aerror,0,pchar(result),maxlen,nil);
 setlength(result,int1);
end;

function sys_mutexcreate(out mutex: mutexty): syserrorty;
begin
 mutex:= SDL_CreateMutex;
 result:= sye_ok;
end;

function sys_mutexdestroy(var mutex: mutexty): syserrorty;
begin
 SDL_DestroyMutex(mutex);
 result:= sye_ok;
end;

function sys_mutexlock(var mutex: mutexty): syserrorty;
begin
{$if defined(usesdl) and defined(windows)}
if SDL_mutexP(mutex)=0 then begin
 {$else}
if SDL_LockMutex(mutex)=0 then begin
{$endif}

  result:= sye_ok;
 end else begin
  result:= sye_busy;
 end;
end;

function sys_mutextrylock(var mutex: mutexty): syserrorty;
begin
 result:= sys_mutexlock(mutex);
end;

function sys_mutexunlock(var mutex: mutexty): syserrorty;
begin
{$if defined(usesdl) and defined(windows)}
if SDL_mutexV(mutex)=0 then begin
 {$else}
if SDL_UnlockMutex(mutex)=0 then begin 
{$endif}
  
  result:= sye_ok;
 end else begin
  result:= sye_busy;
 end;
end;

function sys_semcreate(out sem: semty; count: integer): syserrorty;
begin
 fillchar(sem,sizeof(sem),0);
 sem:= SDL_CreateSemaphore(count);
 result:= sye_ok;
end;

function sys_sempost(var sem: semty): syserrorty;
begin
 if SDL_SemPost(sem)=0 then begin
  result:= sye_ok;
 end else begin
  result:= sye_semaphore;
 end;
end;

function sys_semdestroy(var sem: semty): syserrorty;
begin
 SDL_DestroySemaphore(sem);
 result:= sye_ok;
end;

function sys_semwait(var sem: semty; timeoutusec: integer): syserrorty;
var
 int1: integer;
begin
 if SDL_SemWaitTimeout(sem,timeoutusec div 1000)=0 then begin
  result:= sye_ok;
 end else begin
  result:= sye_timeout;
 end;
end;

function sys_semcount(var sem: semty): integer;
begin
 result:= SDL_SemValue(sem);
end;

function sys_semtrywait(var sem: semty): boolean;
begin
 if SDL_SemTryWait(sem)=0 then begin
  result:= true;
 end else begin
  result:= false;
 end;
end;

function sys_condcreate(out cond: condty): syserrorty;
begin
 {with win32condty(cond) do begin
  waiterscount:= 0;
  windows.initializecriticalsection({$ifdef FPC}@{$endif}waiterscountlock);
  windows.initializecriticalsection({$ifdef FPC}@{$endif}mutex);
  events[ce_signal]:= createevent(nil,false,false,nil);
  events[ce_broadcast]:= createevent(nil,true,false,nil);
 end;}
 result:= sye_ok;
end;

function sys_conddestroy(var cond: condty): syserrorty;
begin
 {with win32condty(cond) do begin
  closehandle(events[ce_signal]);
  closehandle(events[ce_broadcast]);
  windows.deletecriticalsection({$ifdef FPC}@{$endif}waiterscountlock);
  windows.deletecriticalsection({$ifdef FPC}@{$endif}mutex);
 end;}
 result:= sye_ok;
end;

function sys_condlock(var cond: condty): syserrorty;
begin
 {with win32condty(cond) do begin
  windows.entercriticalsection({$ifdef FPC}@{$endif}mutex);
 end;}
 result:= sye_ok;
end;

function sys_condunlock(var cond: condty): syserrorty;
begin
 {with win32condty(cond) do begin
  windows.leavecriticalsection({$ifdef FPC}@{$endif}mutex);
 end;}
 result:= sye_ok;
end;

function sys_condsignal(var cond: condty): syserrorty;
var
 bo1: boolean;
begin
 {with win32condty(cond) do begin
  windows.entercriticalsection({$ifdef FPC}@{$endif}waiterscountlock);
  bo1:= waiterscount > 0;
  windows.leavecriticalsection({$ifdef FPC}@{$endif}waiterscountlock);
  if bo1 then begin
   setevent(events[ce_signal]);
  end;
 end;}
 result:= sye_ok;
end;

function sys_condbroadcast(var cond: condty): syserrorty;
var
 bo1: boolean;
begin
 {with win32condty(cond) do begin
  windows.entercriticalsection({$ifdef FPC}@{$endif}waiterscountlock);
  bo1:= waiterscount > 0;
  windows.leavecriticalsection({$ifdef FPC}@{$endif}waiterscountlock);
  if bo1 then begin
   setevent(events[ce_broadcast]);
  end;
 end;}
 result:= sye_ok;
end;

function sys_condwait(var cond: condty; timeoutusec: integer): syserrorty;
          //timeoutusec = 0 -> no timeout
          //sye_ok -> condition signaled
          //sye_timeout -> timeout
          //sye_cond -> error
var
 int1: integer;
 bo1: boolean;

begin
 result:= sye_cond;
 {with win32condty(cond) do begin
  windows.entercriticalsection({$ifdef FPC}@{$endif}waiterscountlock);
  inc(waiterscount);
  windows.leavecriticalsection({$ifdef FPC}@{$endif}waiterscountlock);
  windows.leavecriticalsection({$ifdef FPC}@{$endif}mutex);
  if timeoutusec = 0 then begin
   timeoutusec:= integer(infinite);
  end
  else begin
   timeoutusec:= timeoutusec div 1000;
  end;
  int1:= waitformultipleobjects(2,@events,false,timeoutusec);
  windows.entercriticalsection({$ifdef FPC}@{$endif}waiterscountlock);
  dec(waiterscount);
  bo1:= (int1 = wait_object_0 + ord(ce_broadcast)) and (waiterscount = 0);
  windows.leavecriticalsection({$ifdef FPC}@{$endif}waiterscountlock);
  if bo1 then begin
   resetevent(events[ce_broadcast]);
  end;
  if int1 = wait_timeout then begin
   result:= sye_timeout;
  end
  else begin
   if (int1 < wait_abandoned_0) or (int1 > wait_abandoned_0 + 1) then begin
    result:= sye_ok;
   end;
  end;
  windows.entercriticalsection({$ifdef FPC}@{$endif}mutex);
 end;}
end;

function localtimeshift(value: tdatetime; const tolocal: boolean) : integer;
             //todo: optimize
 {function systitodatetime(const ayear: word; const systi: systemtime): tdatetime;
 var
  wo1,wo2,wo3: word;
  dt1: tdatetime;
  int1: integer;
 begin
  with systi do begin
   dt1:= encodedate(ayear,wmonth,1);
   wo1:= dayoftheweek(dt1);
   if wo1 = 7 then begin
    wo1:= 0;               //0 -> so
   end;
   wo2:= wday; //n't occurence
   wo3:= 0; //compiler warning
   for int1:= 1 to daysinamonth(ayear,wmonth) do begin
    if wo1 = wdayofweek then begin
     wo3:= int1;
     dec(wo2);
     if wo2 = 0 then begin
      break;
     end;
    end;
    wo1:= (wo1 + 1) mod 7;
   end;
   result:= encodedate(ayear,wmonth,wo3) + encodetime(whour,wminute,0,0);
  end;
 end;}
 
var                                  
 //tinfo: time_zone_information;
 year: word;
 stddate,dldate: tdatetime;
 bo1: boolean; 
begin
 {$ifdef FPC}
 //if gettimezoneinformation(@tinfo) = time_zone_id_invalid then begin
 {$else}
 //if gettimezoneinformation(tinfo) = time_zone_id_invalid then begin
 {$endif}
 { result:= 0;
 end
 else begin
  with tinfo do begin
   result:= bias;
   if tolocal then begin
    value:= incminute(value,-bias); //->localtime
   end;
   if (standarddate.wmonth <> daylightdate.wmonth) and (value > 0) then begin
    try
     year:= yearof(value);
     stddate:= systitodatetime(year,standarddate);
     dldate:= systitodatetime(year,daylightdate);
     if stddate > dldate then begin
      bo1:= (value >= dldate) and (value < stddate);
     end
     else begin
      bo1:= (value <= dldate) and (value > stddate);
     end;
     if bo1 then begin
      result:= result + daylightbias;
     end
     else begin
      result:= result + standardbias;
     end;
    except
    end;
   end;
  end;
 end;
 if tolocal then begin
  result:= -result;
 end;}
end;

function sys_utctolocaltime(const value: tdatetime): tdatetime;  
begin
 result:= incminute(value,localtimeshift(value,true));
// result:= value + sys_localtimeoffset; //todo
end;

function sys_localtimetoutc(const value: tdatetime): tdatetime;
begin
 result:= incminute(value,localtimeshift(value,false));
// result:= value - sys_localtimeoffset; //todo
end;

end.
