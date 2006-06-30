{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msesysutils;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 SysUtils;

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

function getlasterror: integer;
function getlasterrortext: string;
function later(ref,act: cardinal): boolean;
 //true if act > ref, with overflowcorrection

procedure sleepus(const us: cardinal);
procedure waitus(us: integer);
function timestamp: cardinal; //us
function timestep(us: cardinal): longword;   //bringt aktzeit + us
function timeout(time: longword): boolean;

function createguidstring: string;

implementation
uses
{$ifdef mswindows}
 windows,
{$else}
 Libc,
{$endif}
 msesysintf,msestrings;

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


 {$ifdef LINUX}

function timestamp: cardinal;
var
 t1: timeval;
begin
 gettimeofday(@t1,ptimezone(nil));
 result:= t1.tv_sec * 1000000 + t1.tv_usec;
end;

procedure waitus(us: integer);
var
 time: cardinal;
begin
 time:= timestep(us);
 repeat
 until timeout(time);
end;

{$endif linux}

{$ifdef mswindows}

function timestamp: cardinal;
begin
 result:= gettickcount * 1000;
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

function timestep(us: cardinal): cardinal;   //bringt aktzeit + us
begin
 result:= timestamp + us;
end;

function timeout(time: cardinal): boolean;
begin
 result:= later(time,timestamp);
end;

function later(ref,act: cardinal): boolean;
var
 ca1: cardinal;
begin
 ca1:= act-ref;
 result:= integer(ca1) > 0;
// result:= integer(act-ref) > 0; //FPC bug 4768
end;

procedure sleepus(const us: cardinal);
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
 ca1: cardinal;
 {$endif}
begin
 if newline then begin
  value:= value + lineend;
 end;
 {$ifdef linux}
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
 ca1: cardinal;
 {$endif}
begin
 if newline then begin
  value:= value + lineend;
 end;
 {$ifdef linux}
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
 writestderr(value,true);
end;

procedure debugwriteln(const value: string);
begin
 debugwrite(value+lineend);
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

