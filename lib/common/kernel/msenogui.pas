{ MSEgui Copyright (c) 1999-2007 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msenogui;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 sysutils,classes,mseapplication,mseevent,msesys,msestrings;
type
 tnoguiapplication = class(tcustomapplication)
  private
   feventsem: semty;
  protected
   procedure dopostevent(const aevent: tevent); override;
   procedure doeventloop(const once: boolean); override;
   function nextevent: tevent;
   procedure dobeforerun; override;
   procedure doafterrun; override;
   procedure internalinitialize; override;
   procedure internaldeinitialize; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure showexception(e: exception; const leadingtext: msestring = '');
                                  override;
   procedure errormessage(const amessage: msestring); override;
   procedure settimer(const us: integer); override;
 end;
 
function application: tnoguiapplication;
 
implementation
uses
 msesysutils,msesysintf,msetimer,msenoguiintf;
var
 appinst: tnoguiapplication;
 
function application: tnoguiapplication;
begin
 if appinst = nil then begin
  tnoguiapplication.create(nil);
//  appinst.initialize;
 end;
 result:= appinst;
end;

{ tnoguiapplication }

constructor tnoguiapplication.create(aowner: tcomponent);
begin
 appinst:= self;
 sys_semcreate(feventsem,0);
 inherited;
end;

destructor tnoguiapplication.destroy;
begin
 inherited;
// deinitialize;
 sys_semdestroy(feventsem);
end;

procedure tnoguiapplication.dopostevent(const aevent: tevent);
begin
 eventlist.add(aevent);
 sys_sempost(feventsem);
end;

procedure tnoguiapplication.showexception(e: exception;
               const leadingtext: msestring = '');
begin
 writestderr('EXCEPTION:');
 writestderr(leadingtext+e.message,true);
end;

procedure tnoguiapplication.errormessage(const amessage: msestring);
begin
 writestderr('ERROR:');
 writestderr(amessage,true);
end;

procedure tnoguiapplication.settimer(const us: integer);
begin
 nogui_settimer(us);
end;

procedure tnoguiapplication.doeventloop(const once: boolean);
var
 event1: tevent;
begin
 lock;
 try
  while not terminated do begin
   if eventlist.count = 0 then begin
    try
     doidle;
    except
     handleexception(self);
    end;
    if once then begin
     break;
    end;
   end;
   event1:= nextevent;
   try
    case event1.kind of
     ek_timer: begin
      tick(self);
     end;
     ek_terminate: begin
      terminated:= true;
     end;
     else begin
      if event1 is tobjectevent then begin
       with tobjectevent(event1) do begin
        deliver;
       end;
      end;
     end;
    end;
   except
    handleexception(self);
   end;
   event1.free;
  end;
 finally
  unlock;
 end;
end;

function tnoguiapplication.nextevent: tevent;
begin
 nogui_waitevent;
// sys_semwait(feventsem,0);
 result:= tevent(eventlist.getfirst);
end;

procedure tnoguiapplication.dobeforerun;
begin
 if running then begin
  raise exception.create('Already running.');
 end;
end;

procedure tnoguiapplication.internalinitialize;
begin
 nogui_init(@feventsem); 
 msetimer.init;
end;

procedure tnoguiapplication.internaldeinitialize;
begin
 msetimer.deinit;
 nogui_deinit; 
end;

procedure tnoguiapplication.doafterrun;
begin
 while componentcount > 0 do begin
  components[0].free;  //destroy loaded modules
 end;
end;

initialization
 registerapplicationclass(tnoguiapplication);
end.
