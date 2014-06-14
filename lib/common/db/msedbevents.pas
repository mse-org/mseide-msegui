{ MSEgui Copyright (c) 1999-2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msedbevents;
{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}

interface
uses
 classes,mclasses,msearrayprops,mseclasses,msqldb,mdb,mseglob,msetimer,
 msedatabase;

const
 defaultdbeventinterval = 1000000; //us 
type
 tdbevent = class;
 idbevent = interface(inullinterface)['QA.mse']{2}
  procedure listen(const sender: tdbevent);  
  procedure unlisten(const sender: tdbevent);  
  procedure fire(const sender: tdbevent);
 end;
 idbeventcontroller = interface(inullinterface)
  function getdbevent(var aname: string; var aid: int64): boolean;
              //false if none
  procedure dolisten(const sender: tdbevent);
  procedure dounlisten(const sender: tdbevent);
 end;
  
 dbeventty = procedure(const sender: tdbevent; const aid: int64) of object;

 tdbevent = class(tmsecomponent)
  private
   feventname: string;
   fonexecute: dbeventty;
   flisten: boolean;
   fdatabase: tmdatabase;
   fintf: idbevent;
   procedure seteventname(const avalue: string);
   procedure setlisten(const avalue: boolean);
   procedure setdatabase(const avalue: tmdatabase);
  protected
   procedure doexecute(const aid: int64); virtual;
   procedure checkinactive;
   procedure checkactive;
   procedure loaded; override;
   procedure notification(acomponent: tcomponent; operation: toperation); override;
  public
   destructor destroy; override;
   procedure fire;
  published
   property database: tmdatabase read fdatabase write setdatabase;
   property eventname: string read feventname write seteventname;
   property listen: boolean read flisten write setlisten default false;
   property onexecute: dbeventty read fonexecute write fonexecute;
 end;

 dbeventarty = array of tdbevent;
 
 tdbeventcontroller = class
  private
   fintf: idbeventcontroller;
   ftimer: tsimpletimer;
   fevents: dbeventarty;
   function geteventinterval: integer;
   procedure seteventinterval(const avalue: integer);
  protected
   procedure dotimer(const sender: tobject);
  public
   constructor create(const aintf: idbeventcontroller);
   destructor destroy; override;
   procedure register(const sender: tdbevent);
   procedure unregister(const sender: tdbevent);
   procedure connect;
   procedure disconnect;
   procedure getevents;
   property eventinterval: integer read geteventinterval write seteventinterval;
 end;
 
implementation
uses
 msearrayutils,msetypes;

{ tdbevent }

destructor tdbevent.destroy;
begin
 listen:= false;
 inherited;
end;

procedure tdbevent.checkinactive;
begin
 if (fdatabase <> nil) and fdatabase.connected and listen then begin
  databaseerror('Not inactive.',self);
 end;
end;

procedure tdbevent.checkactive;
begin
 if fdatabase = nil then begin
  databaseerror('Database not assigned.',self);
 end;
 if not fdatabase.connected then begin
  databaseerror('Database not connected.',self);
 end;
end;

procedure tdbevent.seteventname(const avalue: string);
begin
 if avalue <> feventname then begin
  if componentstate*[csloading,csdesigning] = [] then begin
   checkinactive;
  end;
  feventname:= avalue;
 end;
end;

procedure tdbevent.setlisten(const avalue: boolean);
begin
 if avalue <> flisten then begin
  if (componentstate * [csloading,csdesigning] = []) and (fdatabase <> nil) then begin
   if eventname = '' then begin
    databaseerror('No eventname.',self);
   end;
   if avalue then begin
    fintf.listen(self);
   end
   else begin
    fintf.unlisten(self);
   end;
  end;
  flisten:= avalue;
 end;
end;

procedure tdbevent.setdatabase(const avalue: tmdatabase);
begin
 if avalue <> nil then begin
  if not mseclasses.getcorbainterface(avalue,typeinfo(idbevent),fintf) then begin
   databaseerror('Invalid Database.',self);
  end;
 end;
 if fdatabase <> nil then begin
  fdatabase.removefreenotification(self);
 end;
 fdatabase:= avalue;
 if fdatabase <> nil then begin
  fdatabase.freenotification(self);
 end;
end;

procedure tdbevent.fire;
begin
 checkactive;
 fintf.fire(self);
end;

procedure tdbevent.doexecute(const aid: int64);
begin
 if canevent(tmethod(fonexecute)) then begin
  fonexecute(self,aid);
 end;
end;

procedure tdbevent.loaded;
begin
 inherited;
 if flisten and not (csdesigning in componentstate) then begin
  flisten:= false;
  listen:= true;
 end;
end;

procedure tdbevent.notification(acomponent: tcomponent; operation: toperation);
begin
 if (operation = opremove) and (acomponent = fdatabase) then begin
  fdatabase:= nil;
  fintf:= nil;
 end;
 inherited;
end;

{ tdbeventcontroller }

constructor tdbeventcontroller.create(const aintf: idbeventcontroller);
begin
 fintf:= aintf;
 ftimer:= tsimpletimer.create(defaultdbeventinterval,
                 {$ifdef FPC}@{$endif}dotimer,false,[]);
 inherited create;
end;

destructor tdbeventcontroller.destroy;
begin
 ftimer.free;
 inherited;
end;

procedure tdbeventcontroller.register(const sender: tdbevent);
begin
 if finditem(pointerarty(fevents),sender) < 0 then begin
  additem(pointerarty(fevents),sender);
 end;
end;

procedure tdbeventcontroller.unregister(const sender: tdbevent);
begin
 removeitem(pointerarty(fevents),sender);
end;

procedure tdbeventcontroller.connect;
var
 int1: integer;
begin
 for int1:= 0 to high(fevents) do begin
  fintf.dolisten(fevents[int1]);
 end;
 ftimer.enabled:= ftimer.interval <> 0;
end;

procedure tdbeventcontroller.disconnect;
var
 int1: integer;
begin
 ftimer.enabled:= false;
 for int1:= 0 to high(fevents) do begin
  try
   fintf.dounlisten(fevents[int1]);
  except
  end;
 end;
end;

procedure tdbeventcontroller.dotimer(const sender: tobject);
var
 str1: string;
 lint1: int64;
 int1: integer;
begin
 while fintf.getdbevent(str1,lint1) do begin
  for int1:= 0 to high(fevents) do begin
   if fevents[int1].eventname = str1 then begin
    fevents[int1].doexecute(lint1);
   end;
  end;
 end;
end;

function tdbeventcontroller.geteventinterval: integer;
begin
 result:= ftimer.interval;
end;

procedure tdbeventcontroller.seteventinterval(const avalue: integer);
begin
 ftimer.interval:= abs(avalue);
 if avalue < 0 then begin
  ftimer.singleshot:= true;
  ftimer.enabled:= true; //trigger oneshot
 end
 else begin
  ftimer.singleshot:= false;
 end; 
end;

procedure tdbeventcontroller.getevents;
begin
 dotimer(nil);
end;

end.
