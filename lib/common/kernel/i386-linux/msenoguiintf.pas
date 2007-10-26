{ MSEgui Copyright (c) 1999-2007 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msenoguiintf;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 msesys;
{$include ../msenoguiintf.inc}

implementation
uses
 libc,mseevent,msesysintf,msenogui;
type
 tapplication1 = class(tnoguiapplication);
var
 sigtimerbefore: sighandler_t;
 sigtermbefore: sighandler_t;
 timerevent: boolean;
 terminated: boolean;
 sempo: psemty;

procedure settimer1(us: cardinal);
               //send et_timer event after delay of us (micro seconds)
var
 timerval: itimerval;
begin
 fillchar(timerval,sizeof(timerval),0);
 timerval.it_value.tv_sec:= us div 1000000;
 timerval.it_value.tv_usec:= us mod 1000000;
 libc.setitimer(itimer_real,{$ifdef FPC}@{$endif}timerval,nil);
end;

procedure nogui_waitevent;
 procedure checkevents;
 begin
  if timerevent then  begin
   timerevent:= false;
   application.postevent(tevent.create(ek_timer));
  end;
  if terminated then  begin
   timerevent:= false;
   application.postevent(tevent.create(ek_terminate));
  end;
 end;
 
begin
 checkevents;
 while tapplication1(application).eventlist.count = 0 do begin
  with linuxsemty(sempo^) do begin
   application.unlock;
   sem_wait(sema);
   application.lock;
   checkevents;
  end;
 end;
end;

procedure nogui_settimer(us: cardinal);
begin
 if us = 0 then begin
  us:= 1;
 end;
 settimer1(us);
end;

procedure sigtimer(SigNum: Integer); cdecl;
begin
 timerevent:= true;
 sem_post(linuxsemty(sempo^).sema);
end;

procedure sigterminate(SigNum: Integer); cdecl;
begin
 terminated:= true;
 sem_post(linuxsemty(sempo^).sema);
end;

procedure nogui_init(const asempo: psemty);
begin
 sempo:= asempo;
 sigtimerbefore:= signal(sigalrm,{$ifdef FPC}@{$endif}sigtimer);
 sigtermbefore:= signal(sigterm,{$ifdef FPC}@{$endif}sigterminate);
end;

procedure nogui_deinit;
begin
 terminated:= true;
 settimer1(0);
 signal(sigalrm,sigtimerbefore);
end;
 
end.
