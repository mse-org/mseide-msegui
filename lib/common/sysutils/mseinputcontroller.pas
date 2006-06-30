{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseinputcontroller;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface

uses
 Classes,msethread,msetypes,mseclasses;

type

  tinputcontroller = class;

  fileinputeventty = procedure (sender: tinputcontroller;
                const activefiles: integerarty) of object;

 tinputcontroller = class(tmsethread)
  private
   factive: boolean;
   finputfiles: integerarty;
   ainputfiles: integerarty;
   foninputavailable: fileinputeventty;
   fchanged: boolean;
   readyfiles: integerarty;
   procedure inputavailable;
   procedure getfiles;
   procedure setactive(const Value: boolean);
   procedure psetinputfiles(const Value: integerarty);
  protected
   function execute(thread: tmsethread): integer; override;
  public
   constructor create;
   procedure setinputfiles(files: array of integer);
   property active: boolean read factive write setactive;
   property inputfiles: integerarty read finputfiles write psetinputfiles;
   property oninputavailable: fileinputeventty read foninputavailable
               write foninputavailable;
 end;

 tinputcontrollercomp = class(tmsecomponent)
  private
   fcontroller: tinputcontroller;
   function getinputfiles: integerarty;
   function getoninputavailable: fileinputeventty;
   procedure psetinputfiles(const Value: integerarty);
   procedure setactive(const Value: boolean);
   procedure setoninputavailable(const Value: fileinputeventty);
   function getactive: boolean;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;

   procedure setinputfiles(files: array of integer);
  published
   property active: boolean read getactive write setactive default false;
   property inputfiles: integerarty read getinputfiles write psetinputfiles;
   property oninputavailable: fileinputeventty read getoninputavailable
               write setoninputavailable;
 end;


implementation
uses
 msegui,
{$ifdef LINUX}
 Libc;
{$else}
 msesysutils;

type
 tfdset = integer; //dummys
 tfdsetpoty = ^tfdset;
const
 fd_setsize = 1;

procedure fd_zero(fdset: tfdset);
begin
end;
procedure fd_set(index: integer;fdset: tfdset);
begin
end;
function fd_isset(index: integer; fdset: tfdset): boolean;
begin
 result:= false;
end;
function select(size: integer; fdset: tfdsetpoty; po1,po2,po3: pointer): integer;
begin
 result:= 0;
end;
{$endif}

{ tinputcontroller }

function tinputcontroller.execute(thread: tmsethread): integer;
var
 fdset: tfdset;
 timeout: timeval;
 int1,int2: integer;
begin
 fd_zero(fdset);
 repeat
  if factive then begin
   timeout.tv_sec:= 0;
   timeout.tv_usec:= 100000;
   if fchanged then begin
    application.synchronize(getfiles);
    fd_zero(fdset);
   end;
   for int1:= 0 to length(ainputfiles) - 1 do begin
    fd_set(ainputfiles[int1],fdset);
   end;
   int1:= select(fd_setsize,@fdset,nil,nil,@timeout);
   if not fchanged then begin
    if (int1 > 0) then begin
     int2:= 0;
     setlength(readyfiles,length(ainputfiles));
     for int1:= 0 to length(ainputfiles) - 1 do begin
      if fd_isset(ainputfiles[int1],fdset) then begin
       readyfiles[int2]:= ainputfiles[int1];
       inc(int2);
      end;
     end;
     setlength(readyfiles,int2);
     application.synchronize(inputavailable);
    end;
   end;
  end;
  if not factive then begin
   usleep(0);
  end;
 until terminated;
 result:= 0;
end;

procedure tinputcontroller.getfiles;
begin
 ainputfiles:= finputfiles;
 fchanged:= false;
end;

procedure tinputcontroller.setactive(const Value: boolean);
begin
 factive := Value;
end;

procedure tinputcontroller.psetinputfiles(const Value: integerarty);
var
 bo1: boolean;
begin
 bo1:= factive;
 factive:= false;
 finputfiles:= Value;
 fchanged:= true;
 factive:= bo1;
end;

procedure tinputcontroller.inputavailable;
begin
 if factive and not fchanged and assigned(foninputavailable) then begin
  foninputavailable(self,readyfiles);
 end;
end;

procedure tinputcontroller.setinputfiles(files: array of integer);
var
 intar: integerarty;
 int1: integer;
begin
 setlength(intar,length(files));
 for int1:= 0 to length(intar)-1 do begin
  intar[int1]:= files[int1];
 end;
 psetinputfiles(intar);
end;

constructor tinputcontroller.create;
begin
 inherited create(execute);
end;

{ tinputcontrollercomp }

constructor tinputcontrollercomp.create(aowner: tcomponent);
begin
 inherited;
 fcontroller:= tinputcontroller.create;
end;

destructor tinputcontrollercomp.destroy;
begin
 fcontroller.free;
 inherited;
end;

function tinputcontrollercomp.getactive: boolean;
begin
 result:= fcontroller.active;
end;

function tinputcontrollercomp.getinputfiles: integerarty;
begin
 result:= fcontroller.inputfiles;
end;

function tinputcontrollercomp.getoninputavailable: fileinputeventty;
begin
 result:= fcontroller.oninputavailable;
end;

procedure tinputcontrollercomp.psetinputfiles(const Value: integerarty);
begin
 fcontroller.inputfiles:= value;
end;

procedure tinputcontrollercomp.setactive(const Value: boolean);
begin
  fcontroller.active:= Value;
end;

procedure tinputcontrollercomp.setinputfiles(files: array of integer);
begin
 fcontroller.setinputfiles(files);
end;

procedure tinputcontrollercomp.setoninputavailable(
  const Value: fileinputeventty);
begin
 fcontroller.oninputavailable:= value;
end;

end.
 
