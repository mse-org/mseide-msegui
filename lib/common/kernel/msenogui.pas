{ MSEgui Copyright (c) 1999-2013 by Martin Schreiber

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
 sysutils,classes,mclasses,mseapplication,mseevent,msesystypes,msestrings;
type
 tnoguiapplication = class(tcustomapplication)
  private
   feventsem: semty;
   fmodallevel: integer;
  protected
   procedure dopostevent(const aevent: tmseevent); override;
   procedure doeventloop(const once: boolean); override;
   function nextevent: tmseevent;
   procedure dobeforerun; override;
   procedure doafterrun; override;
   procedure internalinitialize; override;
   procedure internaldeinitialize; override;
   procedure sethighrestimer(const avalue: boolean); override;
   function getevents: integer; override;
    //application must be locked
    //returns count of queued events
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure destroymodules();
   function modallevel: integer; override;
   procedure showexception(e: exception; const leadingtext: msestring = '');
                                  override;
   procedure errormessage(const amessage: msestring); override;
   procedure settimer(const us: integer); override;
 end;
 
function application: tnoguiapplication;
 
implementation
uses
 msesysutils,msesysintf1,msetimer,msenoguiintf,msethread;
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
 fmodallevel:= -1;
 appinst:= self;
 sys_semcreate(feventsem,0);
 inherited;
end;

destructor tnoguiapplication.destroy;
begin
 destroymodules();
 inherited;
// deinitialize;
 sys_semdestroy(feventsem);
end;

procedure tnoguiapplication.dopostevent(const aevent: tmseevent);
begin
 eventlist.add(aevent);
 sys_sempost(feventsem);
end;

procedure tnoguiapplication.showexception(e: exception;
               const leadingtext: msestring = '');
begin
 writestderr('EXCEPTION: ');
 writestderr(leadingtext+e.message,true);
end;

procedure tnoguiapplication.errormessage(const amessage: msestring);
begin
 writestderr('ERROR: ');
 writestderr(amessage,true);
end;

procedure tnoguiapplication.settimer(const us: integer);
begin
 if us <= 0 then begin
  inherited;
 end
 else begin
  nogui_settimer(us);
 end;
end;

procedure tnoguiapplication.doeventloop(const once: boolean);
var
 event1: tmseevent;
begin
// lock;
// try
  inc(fmodallevel);
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
     ek_asyncexec: begin
      texecuteevent(event1).deliver;
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
   event1.free1; //do not destroy synchronizeevent
  end;
  dec(fmodallevel);
// finally
//  unlock;
// end;
end;

function tnoguiapplication.nextevent: tmseevent;
begin
 nogui_waitevent;
// sys_semwait(feventsem,0);
 result:= tmseevent(eventlist.getfirst);
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

procedure tnoguiapplication.destroymodules();
begin
 while componentcount > 0 do begin
  components[componentcount-1].free;  //destroy loaded modules
 end;
end;

procedure tnoguiapplication.doafterrun;
begin
 if not (apo_noautodestroymodules in foptions) then begin
  destroymodules();
 end;
end;

function tnoguiapplication.modallevel: integer;
begin
 result:= fmodallevel;
end;

procedure tnoguiapplication.sethighrestimer(const avalue: boolean);
begin
 //dummy
end;

function tnoguiapplication.getevents: integer;
begin
 result:= eventlist.count;
end;

initialization
 registerapplicationclass(tnoguiapplication);
end.
