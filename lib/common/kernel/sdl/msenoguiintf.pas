{ MSEgui Copyright (c) 1999-2010 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msenoguiintf;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 msesystypes;
 
{$include ../msenoguiintf.inc}

implementation
uses
 windows,{$ifndef FPC}messages,{$endif}msesysintf1,msesysintf,msenogui,mseevent,
 mseapplication;
type
 tapplication1 = class(tnoguiapplication);
const
 widgetclassname = 'msenonguiwindow';
var
 widgetclass: atom;
 sempo: psemty;
 applicationwindow: hwnd;
 timer: cardinal;
 timerevent: boolean;
 terminated: boolean;

procedure killtimer;
begin
 if timer <> 0 then begin
  windows.killtimer(0,timer);
  timer:= 0;
 end;
end;

procedure nogui_settimer(us: cardinal); 
begin
 killtimer;
 timer:= windows.settimer(applicationwindow,0,us div 1000,nil);
end;
 
function WindowProc(ahWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
begin
 if ahwnd = applicationwindow then begin
  result:= 0;
  case msg of
   wm_timer: begin
    timerevent:= true;
   end;
   wm_close,wm_destroy: begin
    terminated:= true;
   end;
   else begin
    result:= 1;
   end;
  end;
 end
 else begin
  result:= 1;
 end;
 if result <> 0 then begin
  if iswin95 then begin
   result:= defwindowproca(ahwnd,msg,wparam,lparam);
  end
  else begin
   result:= defwindowprocw(ahwnd,msg,wparam,lparam);
  end;
 end;
end;

procedure nogui_waitevent;
 procedure checkevents;
 begin
  if timerevent then  begin
   timerevent:= false;
   application.postevent(tmseevent.create(ek_timer));
  end;
  if terminated then  begin
   timerevent:= false;
   application.postevent(tmseevent.create(ek_terminate));
  end;
 end;

var
 msg1: {$ifdef FPC}msg{$else}tmsg{$endif}; 
 
begin
 with tapplication1(application) do begin
  include(fstate,aps_waiting);
  checkevents;
  while eventlist.count = 0 do begin
   application.unlock;
   msgwaitformultipleobjects(1,{$ifdef FPC}@{$endif}win32semty(sempo^).event,
                                      false,infinite,qs_allinput);
   application.lock;
   if iswin95 then begin
    while peekmessagea(msg1,0,0,0,pm_remove) do begin
     dispatchmessagea(msg1);
    end;
   end
   else begin
    while peekmessagew(msg1,0,0,0,pm_remove) do begin
     dispatchmessagew(msg1);
    end;
   end;
   checkevents;
  end;
  fstate:= fstate -[aps_waiting,aps_woken];
 end;
end;

procedure nogui_init(const asempo: psemty);
const
 classstyle = cs_owndc;
var
 classinfow: twndclassw;
 classinfoa: twndclassa;
 str1: string;
begin
 sempo:= asempo;
 if iswin95 then begin
  fillchar(classinfoa,sizeof(classinfoa),0);
  with classinfoa do begin
   lpszclassname:= widgetclassname;
   lpfnwndproc:= @windowproc;
   hinstance:= {$ifdef FPC}system{$else}sysinit{$endif}.HInstance;
   style:= classstyle;
//   cbwndextra:= wndextrabytes;
  end;
  widgetclass:= registerclassa(classinfoa);
 end
 else begin
  fillchar(classinfow,sizeof(classinfow),0);
  with classinfow do begin
   lpszclassname:= widgetclassname;
   lpfnwndproc:= @windowproc;
   hinstance:= {$ifdef FPC}system{$else}sysinit{$endif}.HInstance;
   style:= classstyle;
//   cbwndextra:= wndextrabytes;
  end;
  widgetclass:= registerclassw(classinfow);
 end;
 str1:= application.applicationname;
 applicationwindow:= windows.CreateWindowex(ws_ex_appwindow,widgetclassname,pchar(str1),
        ws_overlappedwindow,0,0,0,0,0,0,hinstance,nil);
end;

procedure nogui_deinit;
begin
 killtimer;
 destroywindow(applicationwindow);
 applicationwindow:= 0;
 unregisterclass(widgetclassname,hinstance);
end;

end.
