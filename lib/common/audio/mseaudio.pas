{ MSEgui Copyright (c) 2010 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseaudio;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 classes,mseclasses,msethread,msetypes,msepulseglob,msepulsesimple,
 msesys,msestrings;
 
type

 toutstreamthread = class(tmsethread)
 end;

 send8eventty = procedure(var data: bytearty) of object;
 erroreventty = procedure(const sender: tobject; const errorcode: integer;
                  const errortext: msestring) of object;
  
 taudioout = class(tmsecomponent)
  private
   fthread: toutstreamthread;
   factive: boolean;
   fstacksizekb: integer;
   fonsend8: send8eventty;
   fmutex: mutexty;
   fonerror: erroreventty;
   procedure setactive(const avalue: boolean);
  protected
   fpulsestream: ppa_simple;
   procedure loaded; override;
   procedure run;
   procedure stop;
   function threadproc(sender: tmsethread): integer;   
   procedure raiseerror(const aerror: integer);
   procedure doerror(const aerror: integer);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function lock: boolean;
   procedure unlock;
  published
   property active: boolean read factive write setactive default false;
   property stacksizekb: integer read fstacksizekb write fstacksizekb default 0;
   property onsend8: send8eventty read fonsend8 write fonsend8;
   property onerror: erroreventty read fonerror write fonerror;
 end;
 
implementation
uses
 sysutils,msesysintf,mseapplication,msepulse;
 
{ taudioout }

constructor taudioout.create(aowner: tcomponent);
begin
 syserror(sys_mutexcreate(fmutex),self);
 inherited;
end;

destructor taudioout.destroy;
begin
 active:= false;
 inherited;
 sys_mutexdestroy(fmutex);
end;

procedure taudioout.setactive(const avalue: boolean);
begin
 if factive <> avalue then begin
  if componentstate * [csloading,csdesigning] = [] then begin
   if not avalue then begin
    stop;
   end
   else begin
    run;
   end;
  end
  else begin
   factive:= avalue;
  end;
 end;
end;

procedure taudioout.stop;
begin
 freeandnil(fthread);
 pa_simple_free(fpulsestream);
 releasepulsesimple;
 factive:= false;
end;

procedure taudioout.run;
var
 ss: pa_sample_spec;
 int1: integer;
begin
 initializepulsesimple([]);
 fillchar(ss,sizeof(ss),0);
 ss.format:= pa_sample_u8;
 ss.rate:= 44100;
 ss.channels:= 1;
 fpulsestream:= pa_simple_new(nil,'msetest',pa_stream_playback,nil,'stream1',
        @ss,nil,nil,@int1);
 if fpulsestream = nil then begin
  raiseerror(int1);
 end;
 fthread:= toutstreamthread.create({$ifdef FPC}@{$endif}threadproc,false,
                                      fstacksizekb);
 factive:= true;
end;

procedure taudioout.loaded;
begin
 inherited;
 if not (csdesigning in componentstate) and factive and 
                                       (fthread = nil) then begin
  run;
 end;
end;

function taudioout.lock: boolean;
begin
 result:= sys_mutexlock(fmutex) = sye_ok;
end;

procedure taudioout.unlock;
begin
 sys_mutexunlock(fmutex);
end;

function taudioout.threadproc(sender: tmsethread): integer;
var
 data: pointer;
 int1: integer;
begin
 result:= 0;
 if canevent(tmethod(fonsend8)) then begin
  factive:= true;
  while not sender.terminated do begin
   data:= nil;
   lock;
   try
    fonsend8(data);
   finally
    unlock;
   end;
   if data <> nil then begin
    if pa_simple_write(fpulsestream,data,length(bytearty(data)),
                                                  @int1) <> 0 then begin
     doerror(int1);
     break;
    end;     
   end;
  end;
 end;
end;

procedure taudioout.raiseerror(const aerror: integer);
begin
 raise exception.create(pa_strerror(aerror));
end;

procedure taudioout.doerror(const aerror: integer);
begin
 application.lock;
 try
  if canevent(tmethod(fonerror)) then begin
   fonerror(self,aerror,pa_strerror(aerror));
  end;
 finally
  application.unlock;
 end;
end;

end.
