{ MSEgui Copyright (c) 2008 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseprocmonitor;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msesys,mseevent;
{$include ../mseprocmonitor.inc}

implementation
uses 
 msethread,msetypes,windows,sysutils,msedatalist,mseapplication;
type
 handlearty = array of thandle;

 tprocmonitor = class(tmutexthread)
  private
   fwakeupevent: thandle;
   fhandles: handlearty;
   fcallbacks: array of ievent;
   fdata: pointerarty;
   fcount: integer;
   procedure wakeup;
  public
   constructor create;
   destructor destroy; override;
   function listentoprocess(const prochandle: prochandlety; const dest: ievent;
                              const data: pointer): boolean;
   procedure unlistentoprocess(const prochandle: prochandlety; const dest: ievent);
   function execute(thread: tmsethread): integer; override;
 end;

var
 monitor: tprocmonitor;
 
procedure checkinit;
begin
 if monitor = nil then begin
  monitor:= tprocmonitor.create;
 end;
end;

function pro_listentoprocess(const aprochandle: prochandlety; const adest: ievent;
                             const adata: pointer): boolean;
begin
 checkinit;
 result:= monitor.listentoprocess(aprochandle,adest,adata);
end;

procedure pro_unlistentoprocess(const aprochandle: prochandlety; const adest: ievent);
begin
 if monitor <> nil then begin
  monitor.unlistentoprocess(aprochandle,adest);
 end;
end;

{ tprocmonitor }

constructor tprocmonitor.create;
begin
 fwakeupevent:= createevent(nil,false,false,nil);
 setlength(fhandles,1);
 fhandles[0]:= fwakeupevent;
 inherited;
end;

destructor tprocmonitor.destroy;
begin
 terminate;
 setevent(fwakeupevent);
 inherited;
 closehandle(fwakeupevent);
end;

procedure tprocmonitor.wakeup;
begin
 setevent(fwakeupevent);
end;

function tprocmonitor.execute(thread: tmsethread): integer;
var
 event: tevent;
 int1: integer;
 handles1: handlearty;
 handle1: thandle;
 execresult1: integer;
begin
 with tprocmonitor(thread) do begin
  repeat
   lock;
   handles1:= copy(fhandles);
   unlock;
   int1:= waitformultipleobjects(length(handles1),
                                     pwohandlearray(handles1),false,INFINITE);
   if not terminated then begin
    int1:= int1 - wait_object_0;
    if (int1 > 0) and (int1 <= high(handles1)) then begin
     handle1:= fhandles[int1];
     getexitcodeprocess(handle1,longword(execresult1));
     lock;
     for int1:= high(fhandles) downto 1 do begin
      if fhandles[int1] = handle1 then begin
       application.postevent(tchildprocevent.create(fcallbacks[int1-1],handle1,
                      execresult1,fdata[int1-1]));
       deleteitem(pointerarty(fcallbacks),int1-1);
       deleteitem(fhandles,typeinfo(handlearty),int1);
       deleteitem(fdata,int1-1);
      end;
     end;
     closehandle(handle1);
     unlock;
    end;
   end;
  until terminated;
 end;
 result:= 0;
end;

function tprocmonitor.listentoprocess(const prochandle: prochandlety;
                        const dest: ievent; const data: pointer): boolean;
begin
 result:= false;
 lock;
 if length(fhandles) < maximum_wait_objects then begin
  setlength(fhandles,high(fhandles)+2);
  fhandles[high(fhandles)]:= prochandle;
  setlength(fcallbacks,high(fhandles));
  fcallbacks[high(fcallbacks)]:= dest;
  setlength(fdata,high(fhandles));
  fdata[high(fdata)]:= data;
  result:= true;
 end;
 wakeup;
 unlock;
end;

procedure tprocmonitor.unlistentoprocess(const prochandle: prochandlety; 
                     const dest: ievent);
var
 int1: integer;
begin
 lock;
 for int1:= high(fcallbacks) downto 0 do begin
  if (fcallbacks[int1] = dest) and (fhandles[int1+1] = prochandle) then begin
   deleteitem(pointerarty(fcallbacks),int1);
   deleteitem(fhandles,typeinfo(handlearty),int1+1);
   deleteitem(fdata,int1);
  end;
 end;
 wakeup;
 unlock;
end;

initialization
finalization
 freeandnil(monitor);
end.
