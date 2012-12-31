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
 msesystypes;
var
 iswin95: boolean;
 iswin98: boolean;
 cancleartype: boolean;

{$include ..\msesysintf1.inc}

type
 win32semty = record
  event: cardinal;
  semacount: integer;
  destroyed: integer;
  platformdata: array[3..7] of cardinal;
 end;

implementation
uses
 windows,sysutils,dateutils,msedynload;
 
type
 {$ifdef FPC}
 PCRITICAL_SECTION_DEBUG = ^CRITICAL_SECTION_DEBUG;
     //bug in struct.inc
     CRITICAL_SECTION = record
          DebugInfo : PCRITICAL_SECTION_DEBUG;
          LockCount : LONG;
          RecursionCount : LONG;
          OwningThread : HANDLE;
          LockSemaphore : HANDLE;
          Reserved : DWORD;
       end;
 {$endif}
 win32mutexty = record
  mutex: trtlcriticalsection;
  trycount: integer;
  lockco: integer; 
  owningth: threadty;
  platformdata: array[7..7] of cardinal;
 end;

 condeventsty = (ce_signal,ce_broadcast);
 win32condty = record
  events: array[condeventsty] of cardinal;
  waiterscount: integer;
  waiterscountlock: trtlcriticalsection;
  mutex: trtlcriticalsection;
  platformdata: array[15..31] of cardinal;
 end;

var
 TryEnterCriticalSection: function (
                 var lpCriticalSection: TRTLCriticalSection): BOOL; stdcall;
   
function sys_getlasterror: Integer;
begin
 result:= windows.GetLastError;
end;

procedure sys_setlasterror(const avalue: integer);
begin
 windows.setlasterror(avalue);
end;

function sys_geterrortext(aerror: integer): string;
const
 maxlen = 1024;
var
 int1: integer;
begin
 setlength(result,maxlen);
 int1:= formatmessage(format_message_from_system,nil,aerror,0,pchar(result),maxlen,nil);
 setlength(result,int1);
end;

function sys_mutexcreate(out mutex: mutexty): syserrorty;
begin
 with win32mutexty(mutex) do begin
  windows.initializecriticalsection(mutex);
  trycount:= 0;
  lockco:= 0;
  owningth:= 0;
 end;
 result:= sye_ok;
end;

function sys_mutexdestroy(var mutex: mutexty): syserrorty;
begin
 result:= sye_ok;
 windows.deletecriticalsection(win32mutexty(mutex).mutex);
end;

function lockmutex(var mutex: mutexty; const noblock: boolean): syserrorty;
var
// bo1: boolean;
 id: threadty;
begin
 with win32mutexty(mutex) do begin
  if not iswin95 then begin
   if noblock then begin
    if not tryentercriticalsection(mutex) then begin
     result:= sye_busy;
     exit;
    end;
   end
   else begin
    windows.entercriticalsection(mutex);
   end;
  end
  else begin
   while interlockedincrement(trycount) > 1 do begin
    interlockeddecrement(trycount);
    windows.sleep(0);
   end;
   id:= windows.getcurrentthreadid;
   if noblock and not((lockco = 0) or (owningth = id)) then begin
    interlockeddecrement(trycount);
    result:= sye_busy;
    exit;
   end;
   inc(lockco);
   interlockeddecrement(trycount);
   windows.entercriticalsection(mutex);
   owningth:= id;
  end;
 end;
 result:= sye_ok;
end;

function sys_mutexlock(var mutex: mutexty): syserrorty;
begin
 result:= lockmutex(mutex,false);
end;

function sys_mutextrylock(var mutex: mutexty): syserrorty;
begin
 result:= lockmutex(mutex,true);
end;

function sys_mutexunlock(var mutex: mutexty): syserrorty;
begin
 with win32mutexty(mutex) do begin
  if iswin95 then begin
   while interlockedincrement(trycount) > 1 do begin
    interlockeddecrement(trycount);
    windows.sleep(0);
   end;
   dec(lockco);
   if lockco = 0 then begin
    owningth:= 0;
   end;
   interlockeddecrement(trycount);
  end;
  windows.leavecriticalsection(mutex); 
 end;
 result:= sye_ok;
end;

function sys_semcreate(out sem: semty; count: integer): syserrorty;
begin
 fillchar(sem,sizeof(sem),0);
 with win32semty(sem) do begin
  semacount:= count;
  event:= createevent(nil,false,false,nil);
  result:= sye_ok;
 end;
end;

function sempost1(var sem: semty): syserrorty;
begin
 with win32semty(sem) do begin
  if interlockedincrement(semacount) <= 0 then begin
   setevent(event);
  end;
  result:= sye_ok;
 end;
end;

function sys_sempost(var sem: semty): syserrorty;
begin
 with win32semty(sem) do begin
  if destroyed <> 0 then begin
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
 with win32semty(sem) do begin
  int1:= interlockedincrement(destroyed);
  if int1 = 1 then begin
   while semacount < 0 do begin
    sempost1(sem);
   end;
   closehandle(event);
  end;
 end;
 result:= sye_ok;
end;

function sys_semwait(var sem: semty; timeoutusec: integer): syserrorty;
var
 int1: integer;
begin
 result:= sye_semaphore;
 with win32semty(sem) do begin
  if destroyed <> 0 then begin
   exit;
  end;
  if interlockeddecrement(semacount) < 0 then begin
   if timeoutusec <= 0 then begin
    timeoutusec:= integer(infinite);
   end
   else begin
    timeoutusec:= timeoutusec div 1000;
   end;
   int1:= waitforsingleobject(event,timeoutusec);
   if int1 = wait_object_0 then begin
    result:= sye_ok;
   end
   else begin
    if int1 = wait_timeout then begin
     result:= sye_timeout;
    end;
   end;
  end
  else begin
   result:= sye_ok;
  end;
 end;
end;

function sys_semcount(var sem: semty): integer;
begin
 with win32semty(sem) do begin
  result:= semacount;
  if result < 0 then begin
   result:= 0;
  end;
 end;
end;

function sys_semtrywait(var sem: semty): boolean;
begin
 with win32semty(sem) do begin
  if destroyed <> 0 then begin
   result:= false;
   exit;
  end;
  result:= semacount > 0;
  if result then begin
   result:= interlockeddecrement(semacount) >= 0;
   if not result then begin
    interlockeddecrement(semacount);
   end;
  end;
 end;
end;

function sys_condcreate(out cond: condty): syserrorty;
begin
 with win32condty(cond) do begin
  waiterscount:= 0;
  windows.initializecriticalsection({$ifdef FPC}@{$endif}waiterscountlock);
  windows.initializecriticalsection({$ifdef FPC}@{$endif}mutex);
  events[ce_signal]:= createevent(nil,false,false,nil);
  events[ce_broadcast]:= createevent(nil,true,false,nil);
 end;
 result:= sye_ok;
end;

function sys_conddestroy(var cond: condty): syserrorty;
begin
 with win32condty(cond) do begin
  closehandle(events[ce_signal]);
  closehandle(events[ce_broadcast]);
  windows.deletecriticalsection({$ifdef FPC}@{$endif}waiterscountlock);
  windows.deletecriticalsection({$ifdef FPC}@{$endif}mutex);
 end;
 result:= sye_ok;
end;

function sys_condlock(var cond: condty): syserrorty;
begin
 with win32condty(cond) do begin
  windows.entercriticalsection({$ifdef FPC}@{$endif}mutex);
 end;
 result:= sye_ok;
end;

function sys_condunlock(var cond: condty): syserrorty;
begin
 with win32condty(cond) do begin
  windows.leavecriticalsection({$ifdef FPC}@{$endif}mutex);
 end;
 result:= sye_ok;
end;

function sys_condsignal(var cond: condty): syserrorty;
var
 bo1: boolean;
begin
 with win32condty(cond) do begin
  windows.entercriticalsection({$ifdef FPC}@{$endif}waiterscountlock);
  bo1:= waiterscount > 0;
  windows.leavecriticalsection({$ifdef FPC}@{$endif}waiterscountlock);
  if bo1 then begin
   setevent(events[ce_signal]);
  end;
 end;
 result:= sye_ok;
end;

function sys_condbroadcast(var cond: condty): syserrorty;
var
 bo1: boolean;
begin
 with win32condty(cond) do begin
  windows.entercriticalsection({$ifdef FPC}@{$endif}waiterscountlock);
  bo1:= waiterscount > 0;
  windows.leavecriticalsection({$ifdef FPC}@{$endif}waiterscountlock);
  if bo1 then begin
   setevent(events[ce_broadcast]);
  end;
 end;
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
 with win32condty(cond) do begin
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
 end;
end;

function localtimeshift(value: tdatetime; const tolocal: boolean) : integer;
             //todo: optimize
 function systitodatetime(const ayear: word; const systi: systemtime): tdatetime;
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
 end;                 
 
var                                  
 tinfo: time_zone_information;
 year: word;
 stddate,dldate: tdatetime;
 bo1: boolean; 
begin
 {$ifdef FPC}
 if gettimezoneinformation(@tinfo) = time_zone_id_invalid then begin
 {$else}
 if gettimezoneinformation(tinfo) = time_zone_id_invalid then begin
 {$endif}
  result:= 0;
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
 end;
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

{$ifdef FPC}
function DoCompareStringA(const s1, s2: unicodestring; Flags: DWORD): PtrInt;
  var
    a1, a2: AnsiString;
  begin
    a1:=s1;
    a2:=s2;
    SetLastError(0);
    Result:=CompareStringA(LOCALE_USER_DEFAULT,Flags,pchar(a1),
      length(a1),pchar(a2),length(a2))-2;
  end;

function DoCompareStringW(const s1, s2: unicodestring; Flags: DWORD): PtrInt;
  begin
    SetLastError(0);
    Result:=CompareStringW(LOCALE_USER_DEFAULT,Flags,pwidechar(s1),
      length(s1),pwidechar(s2),length(s2))-2;
    if GetLastError=0 then
      Exit;
    if GetLastError=ERROR_CALL_NOT_IMPLEMENTED then  // Win9x case
      Result:=DoCompareStringA(s1, s2, Flags);
    if GetLastError<>0 then
      RaiseLastOSError;
  end;

function Win32CompareunicodeString(const s1, s2 : unicodestring) : PtrInt;
  begin
    Result:=DoCompareStringW(s1, s2, 0);
  end;

function Win32CompareTextunicodeString(const s1, s2 : unicodestring) : PtrInt;
  begin
    Result:=DoCompareStringW(s1, s2, NORM_IGNORECASE);
  end;
{$endif}

procedure doinit;
var
 info: osversioninfo;
 int1: integer;
 
begin
{$ifdef FPC}
 widestringmanager.CompareUnicodeStringProc:=@win32CompareUnicodeString;
 widestringmanager.CompareTextUnicodeStringProc:=@win32CompareTextUnicodeString;
{$endif}

 info.dwOSVersionInfoSize:= sizeof(info);
 if getversionex(info) then begin
  with info do begin
   int1:= dwmajorversion*1000+dwminorversion;
   cancleartype:= int1 >= 5001;
   iswin95:= dwPlatformId = ver_platform_win32_windows;
   if iswin95 then begin
    iswin98:= (dwMajorVersion >= 4) or
                (dwMajorVersion = 4) and (dwminorVersion > 0);
   end;
  end;
 end;
 checkprocaddresses(['kernel32.dll'],
      ['TryEnterCriticalSection'],
      [{$ifndef FPC}@{$endif}@TryEnterCriticalSection]);
 
end;

initialization
 doinit;
end.
