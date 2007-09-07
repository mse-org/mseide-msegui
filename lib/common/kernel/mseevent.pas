{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseevent;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 mselist,mseguiglob,msegraphutils,msekeyboard,msetypes,msestrings,msesys;

{$ifdef FPC}
 { $interfaces corba}
{$endif}

const
// eta_timer = 1; //tags for userevents
 eta_release = 2;

type
 eventkindty = (ek_none,ek_focusin,ek_focusout,ek_checkapplicationactive,
                ek_enterwindow,ek_leavewindow,
                ek_buttonpress,ek_buttonrelease,ek_mousewheel,
                ek_mousemove,ek_mousepark,
                ek_mouseenter,ek_mouseleave,{ek_mousecapturebegin,}ek_mousecaptureend,
                ek_clientmouseenter,ek_clientmouseleave,
                ek_expose,ek_configure,
                ek_terminate,ek_abort,ek_destroy,ek_show,ek_hide,ek_close,
                ek_activate,ek_loaded,
                ek_keypress,ek_keyrelease,ek_timer,ek_wakeup,
                ek_release,ek_childscaled,ek_resize,
                ek_dropdown,ek_async,ek_execute,ek_component,
                ek_dbedit,ek_dbupdaterowdata,
                ek_user);
const
 mouseregionevents = [ek_mousepark,ek_mouseenter,ek_mouseleave,
                      {ek_mousecapturebegin,}ek_mousecaptureend,
                      ek_clientmouseenter,ek_clientmouseleave];
 mouseposevents = [ek_buttonpress,ek_buttonrelease,ek_mousemove,ek_mousepark];
 waitignoreevents = [ek_keypress,ek_buttonpress,ek_mousewheel];
 
type
 eventstatety = (es_processed,es_child,es_broadcast,es_modal,es_drag,
                 es_reflected,es_nofocus);
 eventstatesty = set of eventstatety;
 mouseeventinfoty = record //same layout as mousewheeleventinfoty!
  eventkind: eventkindty;
  shiftstate: shiftstatesty;
  pos: pointty;
  eventstate: eventstatesty;
  timestamp: cardinal; //usec, 0 -> invalid
  button: mousebuttonty;
 end;
 pmouseeventinfoty = ^mouseeventinfoty;
 
 mousewheeleventinfoty = record //same layout as mouseeventinfoty!
  eventkind: eventkindty;
  shiftstate: shiftstatesty;
  pos: pointty;
  eventstate: eventstatesty;
  timestamp: cardinal; //usec, 0 -> invalid
  wheel: mousewheelty;
 end;
 pmousewheeleventty = ^mousewheeleventinfoty;
 
 keyeventinfoty = record
  key,keynomod: keyty;
  chars: msestring;
  shiftstate: shiftstatesty;
  eventstate: eventstatesty;
 end;
 pkeyeventinfoty = ^keyeventinfoty;

 tevent = class(tnullinterfacedobject)
  private
   fkind: eventkindty;
  public
   constructor create(const akind: eventkindty);
   property kind: eventkindty read fkind;
 end;

 eventarty = array of tevent;
 eventaty = array[0..0] of tevent;
 peventaty = ^eventaty;
 
 tobjectevent = class;

 ievent = interface(iobjectlink)
  procedure receiveevent(const event: tobjectevent);
 end;

 tobjectevent = class(tevent,iobjectlink)
  private
   finterface: pointer; //ievent;
   procedure link(const source,dest: iobjectlink; valuepo: pointer = nil;
                 ainterfacetype: pointer = nil; once: boolean = false);
   procedure unlink(const source,dest: iobjectlink; valuepo: pointer = nil);
   procedure objevent(const sender: iobjectlink; const event: objecteventty);
   function getinstance: tobject;
  public
   procedure deliver;
   constructor create(const akind: eventkindty; const dest: ievent);
   destructor destroy; override;
 end;

 tuserevent = class(tobjectevent)
   ftag: integer;
  public
   constructor create(const eventinterface: ievent; tag: integer);
   property tag: integer read ftag;
 end;

 tasyncevent = class(tuserevent)
  constructor create(const eventinterface: ievent; atag: integer);
 end;

 teventqueue = class(tobjectqueue)
  private
   fsem: semty;
   fmutex: mutexty;
   fdestroying: boolean;
  public
   constructor create(aownsobjects: boolean);
   destructor destroy; override;
   procedure post(event: tevent);
   function wait(noblock: boolean = true): tevent;
 end;

implementation
uses
 msesysintf;
{ tevent }

constructor tevent.create(const akind: eventkindty);
begin
 fkind:= akind;
end;

{ tobjectevent }

constructor tobjectevent.create(const akind: eventkindty; const dest: ievent);
begin
 finterface:= pointer(dest);
 if finterface <> nil then begin
  ievent(finterface).link(nil,iobjectlink(self));
 end;
 inherited create(akind);
end;

procedure tobjectevent.deliver;
begin
 if finterface <> nil then begin
  ievent(finterface).receiveevent(self);
 end;
end;

destructor tobjectevent.destroy;
begin
 if finterface <> nil then begin
  ievent(finterface).unlink(nil,iobjectlink(self));
 end;
 inherited;
end;

procedure tobjectevent.objevent(const sender: iobjectlink; const event: objecteventty);
begin
 if event = oe_destroyed then begin
  finterface:= nil;
 end;
end;

function tobjectevent.getinstance: tobject;
begin
 result:= self;
end;

procedure tobjectevent.link(const source,dest: iobjectlink; valuepo: pointer = nil;
                ainterfacetype: pointer = nil; once: boolean = false);
begin
 //dummy
end;

procedure tobjectevent.unlink(const source,dest: iobjectlink; valuepo: pointer = nil);
begin
 //dummy
end;

{ tuserevent }

constructor tuserevent.create(const eventinterface: ievent; tag: integer);
begin
 ftag:= tag;
 inherited create(ek_user,eventinterface);
end;

{ tasyncevent }

constructor tasyncevent.create(const eventinterface: ievent; atag: integer);
begin
 inherited;
 fkind:= ek_async;
end;

{ teventqueue }

constructor teventqueue.create(aownsobjects: boolean);
begin
 sys_semcreate(fsem,0);
 sys_mutexcreate(fmutex);
 inherited;
end;

destructor teventqueue.destroy;
begin
 fdestroying:= true;
 while sys_semcount(fsem) < 0 do begin
  sys_sempost(fsem);
 end;
 sys_semdestroy(fsem);
 sys_mutexdestroy(fmutex);
 inherited;
end;

procedure teventqueue.post(event: tevent);
begin
 sys_mutexlock(fmutex);
 if not fdestroying then begin
  add(event);
 end;
 sys_mutexunlock(fmutex);
 sys_sempost(fsem);
end;

function teventqueue.wait(noblock: boolean): tevent;

 procedure get;
 begin
  sys_mutexlock(fmutex);
  if not fdestroying then begin
   result:= tevent(getfirst);
  end;
  sys_mutexunlock(fmutex);
 end;

begin
 result:= nil;
 if noblock then begin
  if sys_semtrywait(fsem) then begin
   get;
  end;
 end
 else begin
  if sys_semwait(fsem,0) = sye_ok then begin
   get;
  end;
 end;
end;

end.
