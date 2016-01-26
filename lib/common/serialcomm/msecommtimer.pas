{ MSEgui Copyright (c) 1999-2016 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msecommtimer;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
{$ifndef FPC}{$ifdef linux} {$define UNIX} {$endif}{$endif}

interface
uses
 {$ifdef mswindows}
 windows,{$ifndef FPC}mmsystem,{$endif}
 {$endif}
 {$ifdef UNIX}
 mselibc,
 {$endif}
 Classes;
{$ifdef mswindows}
type
 {$ifdef FPC}
  PTimeCaps = ^TTimeCaps;
  timecaps_tag = record
    wPeriodMin: UINT;     { minimum period supported  }
    wPeriodMax: UINT;     { maximum period supported  }
  end;
  TTimeCaps = timecaps_tag;
  TIMECAPS = timecaps_tag;
  TFNTimeCallBack = procedure(uTimerID, uMessage: UINT;
    dwUser, dw1, dw2: DWORD) stdcall;
 {$endif}

 tmmtimermse = class     //mindeszeit bei nt ca 10ms,
                         // ungestoerte zeit meistens 10ms zu klein
  private
   fevent: thandle;
   fontimer: tnotifyevent;
   ftimecaps: timecaps;
   fresolution: integer;
   ftimehandle: integer;
  protected
   fid: int32; //index in instance array
  public
   constructor create;
   destructor destroy; override;
   procedure wait(us: longword; aontimer: tnotifyevent = nil); overload;
   procedure wait; overload;
   procedure start(us: longword; aontimer: tnotifyevent = nil);
   procedure abort;
 end;

 {$ifdef FPC}
const
  TIME_ONESHOT    = 0;   { program timer for single event }
  TIME_PERIODIC   = 1;   { program for continuous periodic event }
  TIME_CALLBACK_FUNCTION    = $0000;  { callback is function }
  TIME_CALLBACK_EVENT_SET   = $0010;  { callback is event - use SetEvent }
  TIME_CALLBACK_EVENT_PULSE = $0020;  { callback is event - use PulseEvent }
  mmsyst = 'winmm.dll';
function timeKillEvent(uTimerID: UINT): MMRESULT; stdcall;
             external mmsyst name 'timeKillEvent';
function timeGetDevCaps(lpTimeCaps: PTimeCaps; uSize: UINT): MMRESULT; stdcall;
             external mmsyst name 'timeGetDevCaps';
function timeBeginPeriod(uPeriod: UINT): MMRESULT; stdcall;
             external mmsyst name 'timeBeginPeriod';
function timeEndPeriod(uPeriod: UINT): MMRESULT; stdcall;
             external mmsyst name 'timeEndPeriod';
function timeSetEvent(uDelay, uResolution: UINT;
  lpFunction: TFNTimeCallBack; dwUser: DWORD; uFlags: UINT): MMRESULT; stdcall;
             external mmsyst name 'timeSetEvent';
 {$endif}
{$endif mswindows}

implementation
uses
 {$ifdef mswindows}msesystypes,msesysintf1,{$endif}sysutils;

{$ifdef mswindows}
var
 timerinstances: array of tmmtimermse;
 timerlock: mutexty;

procedure locktimer();
begin
 sys_mutexlock(timerlock);
end;

procedure unlocktimer();
begin
 sys_mutexunlock(timerlock);
end;
 
procedure mmtimerevent(uTimerID, uMessage: UINT;
    dwUser, dw1, dw2: DWORD); stdcall;
var
 ti1: tmmtimermse;
begin
 locktimer();
 ti1:= timerinstances[dwuser];
 unlocktimer();
 with ti1 do begin
  if assigned(fontimer) then begin
   fontimer(ti1);
  end;
  setevent(fevent);
 end;
end;

procedure tmmtimermse.abort;
begin
 if ftimehandle <> 0 then begin
  timekillevent(ftimehandle);
  ftimehandle:= 0;
 end;
end;

constructor tmmtimermse.create;
var
 i1: int32;
begin
 fevent:= createevent(nil,false,false,nil);
 timegetdevcaps(@ftimecaps,sizeof(timecaps));
 fresolution:= ftimecaps.wPeriodMin;
 if fresolution < 1 then begin
  fresolution:= 1;
 end;
 timebeginperiod(fresolution);
 inherited;
 fid:= -1;
 locktimer();
 for i1:= 0 to high(timerinstances) do begin
  if timerinstances[i1] = nil then begin
   fid:= i1;
  end;
 end;
 if fid < 0 then begin
  fid:= length(timerinstances);
  setlength(timerinstances,fid+1);
 end;
 timerinstances[fid]:= self;
 unlocktimer();
end;

destructor tmmtimermse.destroy;
begin
 abort;
 closehandle(fevent);
 timeendperiod(fresolution);
 locktimer();
 timerinstances[fid]:= nil;
 unlocktimer();
 inherited;
end;

procedure tmmtimermse.start(us: longword; aontimer: tnotifyevent = nil);
var
 ms: longword;
begin
 abort;
 fontimer:= aontimer;
 ms:= us div 1000;
 if ms >= ftimecaps.wPeriodMin then begin
  ftimehandle:= timesetevent(ms,1,@mmtimerevent,fid,time_oneshot);
  if ftimehandle = 0 then begin
   raise exception.Create('timererror');
  end;
 end
 else begin
  mmtimerevent(0,0,fid,0,0);
 end;
end;

procedure tmmtimermse.wait;
begin
 waitforsingleobject(fevent,infinite{ms+20});
 abort;
end;

procedure tmmtimermse.wait(us: longword; aontimer: tnotifyevent = nil);
begin
 start(us,aontimer);
 wait;
end;

initialization
 sys_mutexcreate(timerlock);
finalization
 sys_mutexdestroy(timerlock);
{$endif}

end.
