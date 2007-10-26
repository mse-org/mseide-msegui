{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseguithread;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 mseclasses,msethread,classes,mseevent,msetypes,msestrings;

type
 tthreadcomp = class;
 threadcompeventty = procedure(const sender: tthreadcomp) of object;

 tthreadcomp = class(tmsecomponent)
  private
   fthread: teventthread;
   fonstart: threadcompeventty;
   fonterminate: threadcompeventty;
   fonexecute: threadcompeventty;
   factive: boolean;
   fdatapo: pointer;
   fdialogtext: msestring;
   fdialogcaption: msestring;
   function getthread: teventthread;
   function getterminated: boolean;
   function threadproc(sender: tmsethread): integer;
   procedure terminateandwait;
   function getactive: boolean;
   procedure setactive(const Value: boolean);
  protected
   procedure loaded; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;

   property datapo: pointer read fdatapo;
   procedure run(const adatapo: pointer = nil);
   function runwithwaitdialog: boolean;
        //true if not canceled
   procedure terminate;
   procedure waitfor;  //does unlock,relock before waiting

   function lock: boolean;
   procedure unlock;
   procedure postevent(event: tevent);
   function waitevent(noblock: boolean = false): tevent;

   property thread: teventthread read getthread;
   property terminated: boolean read getterminated;

  published
   property active: boolean read getactive write setactive default false;
   property dialogtext: msestring read fdialogtext write fdialogtext;
   property dialogcaption: msestring read fdialogcaption write fdialogcaption;
   property onstart: threadcompeventty read fonstart write fonstart;
   property onexecute: threadcompeventty read fonexecute write fonexecute;
   property onterminate: threadcompeventty read fonterminate write fonterminate;
 end;

implementation
uses
 sysutils,mseapplication,msesys;

{ tthreadcomp }

constructor tthreadcomp.create(aowner: tcomponent);
begin
 inherited;
end;

destructor tthreadcomp.destroy;
begin
 terminateandwait;
 inherited;
end;

procedure tthreadcomp.terminateandwait;
begin
 if fthread <> nil then begin
  terminate;
  waitfor;
 end;
 fthread.free;
 fthread:= nil;
end;

procedure tthreadcomp.run(const adatapo: pointer = nil);
begin
 terminateandwait;
 fdatapo:= adatapo;
 fthread:= teventthread.create({$ifdef FPC}@{$endif}threadproc);
end;

function tthreadcomp.runwithwaitdialog: boolean;
begin
 result:= application.waitdialog(self,fdialogtext,fdialogcaption);
end;

function tthreadcomp.lock: boolean;
begin
 result:= thread.lock;
end;

procedure tthreadcomp.unlock;
begin
 thread.unlock;
end;

function tthreadcomp.threadproc(sender: tmsethread): integer;
begin
 fthread:= teventthread(sender);
 if assigned(fonstart) then begin
  application.lock;
  try
   fonstart(self);
  finally
   application.unlock;
  end;
 end;
 if assigned(fonexecute) then begin
  fonexecute(self);
 end;
 if assigned(fonterminate) then begin
  application.lock;
  try
   fonterminate(self);
  finally
   application.unlock;
  end;
 end;
 result:= 0;
end;

function tthreadcomp.getthread: teventthread;
begin
 if fthread = nil then begin
  syserror(sye_thread,self);
 end;
 result:= fthread;
end;

function tthreadcomp.getterminated: boolean;
begin
 result:= thread.terminated;
end;

procedure tthreadcomp.terminate;
begin
 thread.terminate;
end;

procedure tthreadcomp.waitfor;
begin
 application.waitforthread(fthread);
end;

procedure tthreadcomp.postevent(event: tevent);
begin
 fthread.postevent(event);
end;

function tthreadcomp.waitevent(noblock: boolean): tevent;
begin
 result:= fthread.waitevent(noblock);
end;

function tthreadcomp.getactive: boolean;
begin
 result:= factive;
end;

procedure tthreadcomp.loaded;
begin
 inherited;
 if not (csdesigning in componentstate) and factive and (fthread = nil) then begin
  run;
 end;
end;

procedure tthreadcomp.setactive(const Value: boolean);
begin
 if factive <> value then begin
  factive:= value;
  if not value then begin
   terminateandwait;
  end
  else begin
   if componentstate * [csloading,csdesigning] = [] then begin
    run;
   end;
  end;
 end;
end;

end.

