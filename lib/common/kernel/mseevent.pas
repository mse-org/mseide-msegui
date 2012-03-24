{ MSEgui Copyright (c) 1999-2010 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseevent;

{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}

interface
uses
 mselist,mseglob,msegraphutils,msekeyboard,msetypes,msestrings,msesystypes;

const
// eta_timer = 1; //tags for userevents
 eta_release = 2;

type
 eventkindty = (ek_none,ek_focusin,ek_focusout,ek_checkapplicationactive,
                ek_enterwindow,ek_leavewindow,
                ek_buttonpress,ek_buttonrelease,ek_mousewheel,
                ek_mousemove,ek_mousepark,
                ek_mouseenter,ek_mouseleave,ek_mousecaptureend,
                ek_clientmouseenter,ek_clientmouseleave,
                ek_expose,ek_configure,
                ek_terminate,ek_abort,ek_destroy,ek_show,ek_hide,ek_close,
                ek_activate,ek_loaded,
                ek_keypress,ek_keyrelease,ek_timer,ek_wakeup,
                ek_release,{ek_releasedefer,}ek_closeform,ek_checkscreenrange,
                ek_childscaled,ek_resize,
                ek_dropdown,ek_async,ek_execute,ek_component,ek_synchronize,
                ek_connect,
                ek_dbedit,ek_dbupdaterowdata,ek_data,ek_objectdata,ek_childproc,
                ek_dbinsert, //for tdscontroller
                ek_mse,
                ek_user);
const
 mouseregionevents = [ek_mousepark,ek_mouseenter,ek_mouseleave,
                      ek_mousecaptureend,
                      ek_clientmouseenter,ek_clientmouseleave];
 mouseposevents = [ek_buttonpress,ek_buttonrelease,ek_mousemove,ek_mousepark];
 waitignoreevents = [ek_keypress,ek_buttonpress,ek_mousewheel];
 
type
 eventstatety = (es_processed,es_child,es_parent,es_preview,es_client,
                 es_transientfor, //mousewheel from upper modal window
                 es_local,es_broadcast,es_modal,es_drag,
                 es_reflected,es_nofocus);
 eventstatesty = set of eventstatety;
 tmseevent = class(tnullinterfacedobject)
  private
  protected
   fkind: eventkindty;
   procedure internalfree1; virtual;
  public
   constructor create(const akind: eventkindty);
   property kind: eventkindty read fkind;
   procedure free1; //do nothing for ownedevents
 end;

 eventarty = array of tmseevent;
 eventaty = array[0..0] of tmseevent;
 peventaty = ^eventaty;

 tstringevent = class(tmseevent)
  private
   fdata: ansistring;
  public
   constructor create(const adata: string);
   property data: ansistring read fdata write fdata;
 end;
  
 tobjectevent = class;

 ievent = interface(iobjectlink)
  procedure receiveevent(const event: tobjectevent);
 end;

 objeventstatety = (oes_islinked,oes_modaldeferred);
 objeventstatesty = set of objeventstatety;
 
 tobjectevent = class(tmseevent,iobjectlink)
  private
   finterface: pointer; //ievent;
   procedure link(const source,dest: iobjectlink; valuepo: pointer = nil;
                 ainterfacetype: pointer = nil; once: boolean = false);
   procedure unlink(const source,dest: iobjectlink; valuepo: pointer = nil);
   procedure objevent(const sender: iobjectlink; const event: objecteventty);
   function getinstance: tobject;
  protected
   fstate: objeventstatesty;
   fmodallevel: integer;
  public
   constructor create(akind: eventkindty; const dest: ievent;
                                           const modaldefer: boolean = false);
   destructor destroy; override;
   procedure deliver;
   property modallevel: integer read fmodallevel;
 end;

 tchildprocevent = class(tobjectevent)
  public
   prochandle: prochandlety;
   execresult: integer;
   data: pointer;
   constructor create(const dest: ievent; const aprochandle: prochandlety;
                      const aexecresult: integer; const adata: pointer);   
 end;

 tstringobjectevent = class(tobjectevent)
  private
  public
   fdata: ansistring;
   constructor create(const adata: ansistring; const dest: ievent);
   property data: ansistring read fdata write fdata;
 end;
 
 tuserevent = class(tobjectevent)
   ftag: integer;
  public
   constructor create(const dest: ievent; tag: integer);
   property tag: integer read ftag;
 end;

 tasyncevent = class(tuserevent)
  constructor create(const dest: ievent; atag: integer);
 end;

 teventqueue = class(tobjectqueue)
  private
   fsem: semty;
   fmutex: mutexty;
   fdestroying: boolean;
  public
   constructor create(aownsobjects: boolean);
   destructor destroy; override;
   procedure post(event: tmseevent);
   function wait(const timeoutus: integer = 0): tmseevent;
                 // -1 infinite, 0 no block
 end;

implementation
uses
 msesysintf1,mseapplication;
type
 tapplication1 = class(tcustomapplication);
 
{ tmseevent }

constructor tmseevent.create(const akind: eventkindty);
begin
 fkind:= akind;
end;

procedure tmseevent.free1;
begin
 if (self <> nil) then begin
  internalfree1;
 end;
end;

procedure tmseevent.internalfree1;
begin
 self.destroy;
end;

{ tstringevent }

constructor tstringevent.create(const adata: string);
begin
 fdata:= adata;
 inherited create(ek_data);
end;

{ tobjectevent }

constructor tobjectevent.create(akind: eventkindty; const dest: ievent;
                                const modaldefer: boolean = false);
{$ifndef FPC}
var
 po1: pointer;
{$endif}
begin
 finterface:= pointer(dest);
 fmodallevel:= -1;
// if akind = ek_releasedefer then begin
 if modaldefer then begin
  include(fstate,oes_modaldeferred);
	 end;
 if (finterface <> nil) then begin
  if application.locked then begin
   include(fstate,oes_islinked);
 {$ifndef FPC}
   po1:= pointer(1);
   ievent(finterface).link(iobjectlink(po1),iobjectlink(self));
 {$else}
   ievent(finterface).link(iobjectlink(pointer(1)),iobjectlink(self));
 {$endif}
  end;
 end;
 inherited create(akind);
end;

destructor tobjectevent.destroy;
{$ifndef FPC}
var
 po1: pointer;
{$endif}
begin
 if (fmodallevel >= 0) then begin
  tapplication1(application).objecteventdestroyed(self);
 end;
 if (oes_islinked in fstate) and (finterface <> nil) then begin
{$ifndef FPC}
  po1:= pointer(1);
  ievent(finterface).unlink(iobjectlink(po1),iobjectlink(self));
{$else}
  ievent(finterface).unlink(iobjectlink(pointer(1)),iobjectlink(self));
{$endif}
 end;
 inherited;
end;

procedure tobjectevent.deliver;
begin
 if finterface <> nil then begin
  ievent(finterface).receiveevent(self);
 end;
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

{ tstringobjectevent }

constructor tstringobjectevent.create(const adata: ansistring; const dest: ievent);
begin
 fdata:= adata;
 inherited create(ek_objectdata,dest);
end;

{ tuserevent }

constructor tuserevent.create(const dest: ievent; tag: integer);
begin
 ftag:= tag;
 inherited create(ek_user,dest);
end;

{ tasyncevent }

constructor tasyncevent.create(const dest: ievent; atag: integer);
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

procedure teventqueue.post(event: tmseevent);
begin
 sys_mutexlock(fmutex);
 if not fdestroying then begin
  add(event);
 end;
 sys_mutexunlock(fmutex);
 sys_sempost(fsem);
end;

function teventqueue.wait(const timeoutus: integer = 0): tmseevent;

 procedure get;
 begin
  sys_mutexlock(fmutex);
  if not fdestroying then begin
   result:= tmseevent(getfirst);
  end;
  sys_mutexunlock(fmutex);
 end;

begin
 result:= nil;
 if timeoutus = 0 then begin
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

{ tchildprocevent }

constructor tchildprocevent.create(const dest: ievent;
          const aprochandle: prochandlety; const aexecresult: integer;
          const adata: pointer);
begin
 prochandle:= aprochandle;
 execresult:= aexecresult;
 data:= adata;
 inherited create(ek_childproc,dest);
end;

end.
