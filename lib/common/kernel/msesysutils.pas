{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msesysutils;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
{$ifndef FPC}{$ifdef linux} {$define UNIX} {$endif}{$endif}

interface
uses
 classes,sysutils;

type
 eoserror = class(exception)
  public
   error: integer;
   constructor create(const leadingtext: string = ''); overload;
   constructor create(const errno: integer; const leadingtext: string = ''); overload;
    //shows getlasterror
 end;


{$ifdef mswindows}
type
 timeval = record
  tv_sec: longword;
  tv_usec: longword;
 end;
{$endif}

function stdinputhandle: integer;
function stdoutputhandle: integer;
function stderrorhandle: integer;
procedure writestdout(value: string; newline: boolean = false);
procedure writestderr(value: string; newline: boolean = false);
procedure errorhalt(errortext: string; exitcode: integer = 1);
procedure debugwrite(const value: string);
procedure debugwriteln(const value: string);
procedure debugwritestack(const acount: integer = 30);
procedure debugout(const sender: tcomponent; const atext: ansistring); overload;
procedure debugout(const sender: tobject; const atext: ansistring); overload;

function getlasterror: integer;
function getlasterrortext: string;
function later(ref,act: longword): boolean;
 //true if act > ref, with overflowcorrection
function laterorsame(ref,act: longword): boolean;
 //true if act >= ref, with overflowcorrection

procedure sleepus(const us: longword);
procedure waitus(us: integer);
function timestamp: longword; //us, 0 never reported
function timestep(us: longword): longword;   //bringt aktzeit + us
function timeout(time: longword): boolean;

function createguidstring: string;

implementation
uses
{$ifdef mswindows}
 windows,
{$else}
 mselibc,
{$endif}
 msesysintf,msestrings,mseformatstr,msetypes,msesys;

function createguidstring: string;
var
 id: tguid;
begin
 createguid(id);
 result:= guidtostring(id);
end;

{ eoserror }

constructor eoserror.create(const errno: integer; const leadingtext: string = '');
begin
 error:= errno;
 inherited create(leadingtext + 'OSError ' + inttostr(error) + ': ' + sys_geterrortext(error));
end;

constructor eoserror.create(const leadingtext: string);
begin
 create(getlasterror,leadingtext);
end;


 {$ifdef UNIX}

function timestamp: longword;
var
 t1: timeval;
begin
 gettimeofday(t1,ptimezone(nil));
 result:= t1.tv_sec * 1000000 + t1.tv_usec;
 if result = 0 then begin
  result:= 1;
 end;
end;

procedure waitus(us: integer);
var
 time: longword;
begin
 time:= timestep(us);
 repeat
 until timeout(time);
end;

{$endif unix}

{$ifdef mswindows}

function timestamp: longword;
begin
 result:= gettickcount * 1000;
 if result = 0 then begin
  result:= 1;
 end;
end;

procedure waitperformancecounter(time: int64);
var
 time1: int64;
 len: longword;

begin
 if queryperformancecounter(time1) then begin
  len:= time1 + time;
  repeat
   queryperformancecounter(time1);
  until integer(dword(time1)-len) > 0;          //rollup
 end;
end;

procedure waitus(us: integer);
var
 freq: int64;
begin
 if us > 0 then begin
  queryperformancefrequency(freq);
  waitperformancecounter((freq*us) div 1000000);
 end;
end;

{$endif}

function timestep(us: longword): longword;   //bringt aktzeit + us
begin
 result:= timestamp + us;
end;

function timeout(time: longword): boolean;
begin
 result:= later(time,timestamp);
end;

function later(ref,act: longword): boolean;
var
 ca1: longword;
begin
 ca1:= act-ref;
 result:= integer(ca1) > 0;
// result:= integer(act-ref) > 0; //FPC bug 4768
end;

function laterorsame(ref,act: longword): boolean;
var
 ca1: longword;
begin
 ca1:= act-ref;
 result:= integer(ca1) >= 0;
// result:= integer(act-ref) > 0; //FPC bug 4768
end;

procedure sleepus(const us: longword);
begin
 sys_usleep(us);
end;

{$ifdef mswindows}
function stdinputhandle: integer;
begin
 result:= getstdhandle(std_input_handle);
end;

function stdoutputhandle: integer;
begin
 result:= getstdhandle(std_output_handle);
end;

function stderrorhandle: integer;
begin
 result:= getstdhandle(std_error_handle);
end;

{$else}

function stdinputhandle: integer;
begin
 result:= 0;
end;

function stdoutputhandle: integer;
begin
 result:= 1;
end;

function stderrorhandle: integer;
begin
 result:= 2;
end;

{$endif}
procedure writestdout(value: string; newline: boolean = false);
 {$ifdef mswindows}
var
 ca1: longword;
 {$endif}
begin
 if newline then begin
  value:= value + lineend;
 end;
 {$ifdef UNIX}
  __write(1,pointer(value)^,length(value));
 {$else}
  if getstdhandle(std_output_handle) <= 0 then begin
   allocconsole;
  end;
  writefile(getstdhandle(std_output_handle),pointer(value)^,length(value),ca1,nil);
 {$endif}
end;

procedure writestderr(value: string; newline: boolean = false);
 {$ifdef mswindows}
var
 ca1: longword;
 {$endif}
begin
 if newline then begin
  value:= value + lineend;
 end;
 {$ifdef UNIX}
  __write(2,pointer(value)^,length(value));
 {$else}
  if getstdhandle(std_error_handle) <= 0 then begin
   allocconsole;
  end;
  writefile(getstdhandle(std_error_handle),pointer(value)^,length(value),ca1,nil);
 {$endif}
end;

procedure debugwrite(const value: string);
begin
 writestderr(value,false);
end;

procedure debugwriteln(const value: string);
begin
 writestderr(value,true);
end;

procedure debugwritestack(const acount: integer = 30);
var
 int1: integer;
begin
{$ifdef FPC}
 int1:= raisemaxframecount;
 raisemaxframecount:= acount;
 try
  raise exception.create('');
 except
  debugwriteln(getexceptiontext(exceptobject,
                           exceptaddr,exceptframecount,exceptframes));
 end;
 raisemaxframecount:= int1;
{$endif}
end;

procedure debugout(const sender: tcomponent; const atext: ansistring);
begin
 debugwriteln(hextostr(ptruint(sender),8)+' '+
                      sender.classname+':'+sender.name+' '+atext);
end;

procedure debugout(const sender: tobject; const atext: ansistring);
begin
 debugwriteln(hextostr(ptruint(sender),8)+' '+
                      sender.classname+' '+atext);
end;

procedure errorhalt(errortext: string; exitcode: integer = 1);
begin
 writestderr(errortext,true);
 halt(exitcode);
end;

function getlasterror: integer;
begin
 result:= sys_getlasterror;
end;

function getlasterrortext: string;
var
 int1: integer;
begin
 int1:= sys_getlasterror;
 result:= inttostr(int1) + ': ' + sys_geterrortext(int1);
end;

end.

