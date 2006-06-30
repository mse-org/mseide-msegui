{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msecommtimer;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 {$ifdef mswindows}
 windows,{$ifndef FPC}mmsystem,{$endif}
 {$endif}
 {$ifdef LINUX}
 Libc,
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
  public
   constructor create;
   destructor destroy; override;
   procedure wait(us: cardinal; aontimer: tnotifyevent = nil); overload;
   procedure wait; overload;
   procedure start(us: cardinal; aontimer: tnotifyevent = nil);
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
 sysutils;

{$ifdef mswindows}

procedure mmtimerevent(uTimerID, uMessage: UINT;
    dwUser, dw1, dw2: DWORD); stdcall;
begin
 with tmmtimermse(dwuser) do begin
  if assigned(fontimer) then begin
   fontimer(tmmtimermse(dwuser));
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
begin
 fevent:= createevent(nil,false,false,nil);
 timegetdevcaps(@ftimecaps,sizeof(timecaps));
 fresolution:= ftimecaps.wPeriodMin;
 if fresolution < 1 then begin
  fresolution:= 1;
 end;
 timebeginperiod(fresolution);
 inherited;
end;

destructor tmmtimermse.destroy;
begin
 abort;
 closehandle(fevent);
 timeendperiod(fresolution);
 inherited;
end;

procedure tmmtimermse.start(us: cardinal; aontimer: tnotifyevent = nil);
var
 ms: cardinal;
begin
 abort;
 fontimer:= aontimer;
 ms:= us div 1000;
 if ms >= ftimecaps.wPeriodMin then begin
  ftimehandle:= timesetevent(ms,1,@mmtimerevent,cardinal(self),time_oneshot);
  if ftimehandle = 0 then begin
   raise exception.Create('timererror');
  end;
 end
 else begin
  mmtimerevent(0,0,integer(self),0,0);
 end;
end;

procedure tmmtimermse.wait;
begin
 waitforsingleobject(fevent,infinite{ms+20});
 abort;
end;

procedure tmmtimermse.wait(us: cardinal; aontimer: tnotifyevent = nil);
begin
 start(us,aontimer);
 wait;
end;

{$endif}

end.
