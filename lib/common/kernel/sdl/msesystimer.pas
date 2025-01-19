{ MSEgui Copyright (c) 2010 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msesystimer;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseguiglob,mselist,msetypes,dateutils,sysutils,sdl4msegui;
 
function setsystimer(us: longword): guierrorty;
               //send et_timer event after delay or us (micro seconds)
procedure systimerinit(const aeventlist: tobjectqueue; const apphandle: winidty);
procedure systimerdeinit;
function systimerus: longword;
function setmmtimer(const avalue: boolean): boolean;

implementation
uses
 msewinglob,mseevent,msesys,msedynload{,mseguiintf};

const
  MMSYSERR_NOERROR = 0;

  TIME_ONESHOT    = 0;   { program timer for single event }
  TIME_PERIODIC   = 1;   { program for continuous periodic event }
  TIME_CALLBACK_FUNCTION    = $0000;  { callback is function }
  TIME_CALLBACK_EVENT_SET   = $0010;  { callback is event - use SetEvent }
  TIME_CALLBACK_EVENT_PULSE = $0020;  { callback is event - use PulseEvent }

var
 eventlist: tobjectqueue;
 applicationhandle: winidty;

 timer: longword;
 usemmtimer: boolean = false;
 hasmmtimer: boolean = false;
 mmtimerchecked: boolean = false;

function checkmmtimer: boolean;
begin
 result:= hasmmtimer;
end;

function setmmtimer(const avalue: boolean): boolean;
begin
 if avalue then begin
  result:= checkmmtimer;
  if result then begin
   usemmtimer:= true;
  end;
 end
 else begin
  usemmtimer:= false;
  result:= false;
 end;
end;

function systimerus: longword;
begin
 if usemmtimer then begin
  result:= MilliSecondOf(time) * 1000;
 end
 else begin
  result:= SDL_GetTicks * 1000;
 end;
end;

procedure killtimer;
begin
 if timer <> 0 then begin
  SDL_RemoveTimer(timer);
  timer:= 0;
 end;
end;

procedure TimerProc(hwnd: hwnd; uMsg: longword; idEvent: longword;
          dwTime: longword); stdcall;
begin
 killtimer;
 eventlist.add(tmseevent.create(ek_timer));
end;

procedure mmtimerproc(uTimerID, uMessage: UINT;
    dwUser, dw1, dw2: DWORD); stdcall;
begin
 killtimer;
 windows.postmessage(applicationhandle,timermessage,0,0);
end;

function setsystimer(us: longword): guierrorty;
var
 ms: longword;
begin
 killtimer;
 if usemmtimer then begin
  ms:= us div 1000;
  if ms < ticaps.wperiodmin then begin
   ms:= ticaps.wperiodmin;
  end;
  mmtimer:= timesetevent(ms,1,@mmtimerproc,0,time_oneshot);
                        //1ms resolution
  if mmtimer = 0 then begin
   result:= gue_timer;
  end
  else begin
   result:= gue_ok;
  end;
 end
 else begin
  timer:= windows.settimer(0,0,us div 1000,@timerproc);
  if timer = 0 then begin
   result:= gue_timer;
  end
  else begin
   result:= gue_ok;
  end;
 end;
end;

procedure systimerdeinit;
begin
 killtimer;
 eventlist:= nil;
end;

procedure systimerinit(const aeventlist: tobjectqueue; const apphandle: hwnd);
begin
 eventlist:= aeventlist;
 applicationhandle:= apphandle;
end;

end.
