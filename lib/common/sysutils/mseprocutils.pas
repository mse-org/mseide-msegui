{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseprocutils;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
{$ifndef FPC}{$ifdef linux} {$define UNIX} {$endif}{$endif}

interface
uses
 msetypes,msestream,msepipestream,sysutils,msesysutils,msesys;

const
 invalidprochandle = -1;
 
type
 pipedescriptorty = record
  readdes: integer;
  writedes: integer;
 end;
 
function getprocessexitcode(prochandle: integer; out exitcode: integer;
                              const timeoutus: cardinal = 0): boolean;
                 //true if ok, close handle
function waitforprocess(prochandle: integer): integer;

function execmse(const commandline: string): boolean;
//startet programm, true wenn gelungen
function execmse1(const commandline: string; topipe: pinteger = nil;
             frompipe: pinteger = nil;
             errorpipe: pinteger = nil;
             sessionleader: boolean = false;
             groupid: integer = -1; //-1 -> keine, 0 = childpid
             inactive: boolean = true; //windows only
             frompipewritehandle: pinteger = nil;
             errorpipewritehandle: pinteger = nil;
             tty: boolean = false): integer;
//startet programm, bringt processhandle, execerror wenn misslungen
//fuer windows invalidprochandle, closehandle nicht vergessen!
function execmse2(const commandline: string; topipe: tpipewriter = nil;
                      frompipe: tpipereader = nil;
                      errorpipe: tpipereader = nil;
             sessionleader: boolean = false;
             groupid: integer = -1; //-1 -> keine, 0 = childpid
             inactive: boolean = true; //windows only
             usepipewritehandles: boolean = false;
             tty: boolean = false): integer;
//startet programm, bringt processhandle, execerror wenn misslungen
//fuer windows invalidprochandle, closehandle nicht vergessen!

function execwaitmse(const commandline: string): integer;
//startet programm, wartet auf ende, bringt exitcode
procedure killprocess(handle: integer);
function terminateprocess(handle: integer): integer;
           //sendet sigterm, bringt exitresult
           
function getprocesstree: procitemarty;
function getprocesschildren(const pid: integer): integerarty;
function getallprocesschildren(const pid: integer): integerarty;
function activateprocesswindow(const procid: integer; 
                    const araise: boolean = true): boolean;
         //true if ok

 {$ifdef UNIX}
type
 procinfoty = record
  pid: integer;
  comm: string;
  state: char;
  ppid: integer;
  pgrp: integer;
  session: integer;
  tty_nr: integer;
  tpgid: integer;
  flags: longword;
  minflt: longword;
  cminflt: longword;
  majflt: longword;
  cmajflt: longword;
  utime: longword;
  stime: longword;
  cutime: longint;
  cstime: longint;
  priority: longint;
  nice: longint;
  null: longint;
  itrealvalue: longint;
  starttime: longword;
  vsize: longword;
  rss: longint;
  rlim: longword;
  startcode: longword;
  endcode: longword;
  startstack: longword;
  kstkesp: longword;
  kstkeip: longword;
  signal: longword;
  blocked: longword;
  sigignore: longword;
  sigcatch: longword;
  wchan: longword;
  nswap: longword;
  cnswap: longword;
  exitsignal: integer;
  processor: integer;
 end;

function getprocinfo(pid: integer): procinfoty;
function getchildpid(pid: integer): integerarty;
function getinnerstpid(pid: integer): integer;
function getppid2(pid: integer): integer;
function pipe(out desc: pipedescriptorty; write: boolean): boolean;
            //true if ok

 {$endif}
type
 eexecerror = class(msesysutils.eoserror)
 end;

implementation
uses 
 {$ifdef mswindows}windows{$else}libc{$endif},msesysintf,msestrings,msedatalist,
 mseguiintf,mseguiglob;

function compprocitem(const l,r): integer;
begin
 result:= procitemty(l).pid - procitemty(r).pid;
end;

function findprocitem(const l,r): integer;
begin
 result:= integer(l) - procitemty(r).pid;
end;

function getprocesstree: procitemarty;
var
 int1,int2: integer;
begin
 result:= sys_getprocesses;
 sortarray(result,{$ifdef FPC}@{$endif}compprocitem,sizeof(procitemty));
 for int1:= 0 to high(result) do begin
  if findarrayitem(result[int1].ppid,result,{$ifdef FPC}@{$endif}findprocitem,
                sizeof(procitemty),int2) then begin
   additem(result[int2].children,result[int1].pid);
  end;
 end;
end;

function getprocesschildren(const pid: integer): integerarty;
var
 ar1: procitemarty;
 int2: integer;
begin
 ar1:= getprocesstree;
 if findarrayitem(pid,ar1,{$ifdef FPC}@{$endif}findprocitem,
                sizeof(procitemty),int2) then begin
  result:= ar1[int2].children;
 end
 else begin
  result:= nil;
 end;
end;

function getallprocesschildren(const pid: integer): integerarty;
var
 ar1: procitemarty;
 
 procedure addproc(const pid: integer);
 var
  int1,int2: integer;
 begin
  if findarrayitem(pid,ar1,{$ifdef FPC}@{$endif}findprocitem,
                sizeof(procitemty),int2) then begin
   stackarray(ar1[int2].children,result);
   for int1:= 0 to high(ar1[int2].children) do begin
    addproc(ar1[int2].children[int1]);
   end;
  end;
 end;
  
var
 int2: integer;
begin
 ar1:= getprocesstree;
 setlength(result,1);
 result[0]:= pid;
 addproc(pid);
end;

function activateprocesswindow(const procid: integer; 
                    const araise: boolean = true): boolean;
         //true if ok
var
 winid: winidty;
 ar1: integerarty;
begin
 result:= false;
 ar1:= getallprocesschildren(procid);
 winid:= gui_pidtowinid(ar1);
 if winid <> 0 then begin
  if gui_showwindow(winid) = gue_ok then begin
   if araise and (gui_raisewindow(winid) <> gue_ok) then begin
    exit;
   end;
   if gui_setappfocus(winid) = gue_ok then begin
    result:= true;
   end;
  end;
 end;
end;

procedure execerror(const errno: integer; const commandline: string);
begin
 raise eexecerror.Create(errno,'Can not execute "'+commandline+'".'+lineend);
end;
{$ifdef mswindows}

function getprocessexitcode(prochandle: integer; out exitcode: integer;
                  const timeoutus: cardinal = 0): boolean;
                 //true if ok, close handle
var
 dwo1: cardinal;
 ca1: cardinal;
begin
 ca1:= timestep(timeoutus);
 while true do begin
  result:= getexitcodeprocess(prochandle,dwo1);
  if result then begin
   if dwo1 <> still_active then begin
    exitcode:= dwo1;
    closehandle(prochandle);
    break;
   end
   else begin
    if timeout(ca1) then begin
     result:= false;
     break;
    end;
    sleep(0);
   end;
  end
  else begin
   raise eoserror.create('');
  end;
 end;
end;

function waitforprocess(prochandle: integer): integer;
begin
 if waitforsingleobject(prochandle,infinite) = wait_object_0 then begin
  getprocessexitcode(prochandle,result);
 end
 else begin
  raise eoserror.create('');
 end;
end;

function pipe(out desc: pipedescriptorty; write: boolean): boolean;
            //true if ok

 procedure error;
 begin
  closehandle(desc.writedes);
  closehandle(desc.readdes);
 end;

var
 sa: security_attributes;
 hdup: integer;
 po1: pinteger;
begin
 result:= false;
 fillchar(sa,sizeof(sa),0);
 sa.nlength:= sizeof(sa);
 sa.bInheritHandle:= true;
 if createpipe(cardinal(desc.readdes),cardinal(desc.writedes),@sa,0) then begin
  if write then begin
   po1:= @desc.writedes;
  end
  else begin
   po1:= @desc.readdes;
  end;
  if not duplicatehandle(getcurrentprocess,po1^,getcurrentprocess,@hdup,0,
           false,duplicate_same_access) then begin //non inheritable
    error;
  end
  else begin
   closehandle(po1^);
   po1^:= hdup;
  end;
  result:= true;
 end;
end;

function execmse1(const commandline: string; topipe: pinteger = nil;
             frompipe: pinteger = nil;
             errorpipe: pinteger = nil;
             sessionleader: boolean = false;
             groupid: integer = -1; //-1 -> keine, 0 = childpid
             inactive: boolean = true; //windows only
             frompipewritehandle: pinteger = nil;
             errorpipewritehandle: pinteger = nil;
             tty: boolean = false
             ): integer;
//startet programm, bringt processhandle, execerror wenn misslungen
//closehandle nicht vergessen!

var
 topipehandles,frompipehandles,errorpipehandles: pipedescriptorty;

 procedure execerr;
 var
  errorbefore: integer;
 begin
  errorbefore:= sys_getlasterror;
  if errorbefore = 0 then begin
   errorbefore:= 2; //filenotfound
  end;
  if topipehandles.writedes <> invalidfilehandle then closehandle(topipehandles.writedes);
  if topipehandles.readdes <> invalidfilehandle then closehandle(topipehandles.readdes);
  if frompipehandles.writedes <> invalidfilehandle then closehandle(frompipehandles.writedes);
  if frompipehandles.readdes <> invalidfilehandle then closehandle(frompipehandles.readdes);
  if errorpipehandles.writedes <> invalidfilehandle then closehandle(errorpipehandles.writedes);
  if errorpipehandles.readdes <> invalidfilehandle then closehandle(errorpipehandles.readdes);
  execerror(errorbefore,commandline);
 end;

var
 startupinfo: tstartupinfo;
 processinfo: tprocessinformation;

begin
 result:= invalidprochandle;
 fillchar(startupinfo,sizeof(startupinfo),0);
 startupinfo.hStdInput:= stdinputhandle;
 startupinfo.hStdoutput:= stdoutputhandle;
 startupinfo.hStderror:= stderrorhandle;

 topipehandles.writedes:= invalidfilehandle;
 topipehandles.readdes:= invalidfilehandle;
 frompipehandles.writedes:= invalidfilehandle;
 frompipehandles.readdes:= invalidfilehandle;
 errorpipehandles.writedes:= invalidfilehandle;
 errorpipehandles.readdes:= invalidfilehandle;

 if topipe <> nil then begin
  if not pipe(topipehandles,true) then execerr;
  topipe^:= topipehandles.WriteDes;
  startupinfo.hStdInput:= topipehandles.readdes;
 end;
 if frompipe <> nil then begin
  if not pipe(frompipehandles,false) then execerr;
  frompipe^:= frompipehandles.readDes;
  startupinfo.hStdoutput:= frompipehandles.writedes;
 end;
 if errorpipe <> nil then begin
  if errorpipe <> frompipe then begin
   if not pipe(errorpipehandles,false) then execerr;
   errorpipe^:= errorpipehandles.readdes;
   startupinfo.hStderror:= errorpipehandles.writedes;
  end
  else begin
   errorpipe^:= frompipehandles.readdes;
   startupinfo.hStderror:= frompipehandles.writedes;
  end;
 end;
 startupinfo.dwflags:= startf_usestdhandles;
 if inactive then begin
  startupinfo.wShowWindow:= sw_hide;
  startupinfo.dwflags:= startupinfo.dwFlags or startf_useshowwindow;
 end;
 if createprocess(nil,pchar(commandline),nil,nil,true,0,nil,nil,
     startupinfo,processinfo) then begin
  if topipehandles.readdes <> invalidfilehandle then closehandle(topipehandles.readdes);
  if frompipehandles.writedes <> invalidfilehandle then begin
   if frompipewritehandle <> nil then begin
    frompipewritehandle^:= frompipehandles.writedes;
   end
   else begin
    closehandle(frompipehandles.writedes);
   end;
  end;
  if errorpipehandles.writedes <> invalidfilehandle then begin
   if errorpipewritehandle <> nil then begin
    errorpipewritehandle^:= errorpipehandles.writedes;
   end
   else begin
    closehandle(errorpipehandles.writedes);
   end;
  end;
  result:= processinfo.hProcess;
  closehandle(processinfo.hThread);
 end
 else begin
  execerr;
 end;
end;

function execmse(const commandline: string): boolean;
var
 prochandle: integer;
begin
 result:= false;
 prochandle:= execmse1(commandline);
 if prochandle <> invalidprochandle then begin
  closehandle(prochandle);
  result:= true;
 end;
end;

function execwaitmse(const commandline: string): integer;
//startet programm, wartet auf ende, bring exitcode, -1 wenn start nicht moeglich
var
 prochandle: integer;
 bo1: boolean;
 dwo1: dword;
begin
 result:= -1;
   //programm wurde nicht gestartet oder getexitcodeprozessproblem
 prochandle:= execmse1(commandline);
 if prochandle <> invalidprochandle then begin
  repeat
   sleep(0);
   bo1:= getexitcodeprocess(prochandle,dwo1);
   if bo1 then begin
    result:= dwo1;
   end;
  until bo1 or (dwo1 <> still_active);
  closehandle(prochandle);
 end;
end;

procedure killprocess(handle: integer);
begin
 windows.terminateprocess(handle,0);
 closehandle(handle);
end;

function terminateprocess(handle: integer): integer;
           //bricht process ab, kein exitresult
begin
 result:= 0;
 killprocess(handle);
end;

{$endif}

{$ifdef UNIX}
function getprocessexitcode(prochandle: integer; out exitcode: integer;
                               const timeoutus: cardinal = 0): boolean;
                 //true if ok, close handle
var
 dwo1: cardinal;
 pid: integer;
 ca1: cardinal;
begin
 result:= false;
 ca1:= timestep(timeoutus);
 exitcode:= -1;
 while true do begin
  pid:= waitpid(prochandle,@dwo1,wnohang);
  if pid <> -1 then begin
   result:= pid = prochandle;
   if result then begin
    exitcode:= wexitstatus(dwo1);
    break;
   end
   else begin
    if timeout(ca1) then begin
     break;
    end;
    sleep(0);
   end;
  end
  else begin
   raise eoserror.create('');
  end;
 end;
end;

function waitforprocess(prochandle: integer): integer;
var
 dwo1: cardinal;
 pid: integer;
begin
 pid:= waitpid(prochandle,@dwo1,0);
 if pid <> -1 then begin
  result:= wexitstatus(dwo1);
 end
 else begin
  result:= 0; //compilerwarning
  raise eoserror.create('');
 end;
end;

function execwaitmse(const commandline: string): integer;
begin
 result:= libc.{$ifdef FPC}__system{$else}system{$endif}(pchar(commandline));
end;

function pipe(out desc: pipedescriptorty; write: boolean): boolean;
            //returns errorcode, 0 if ok
begin
 result:= libc.pipe(tpipedescriptors(desc)) = 0;
end;

function execmse1(const commandline: string; topipe: pinteger = nil;
             frompipe: pinteger = nil;
             errorpipe: pinteger = nil;
             sessionleader: boolean = false;
             groupid: integer = -1; //-1 -> keine, 0 = childpid
             inactive: boolean = true; //windows only
             frompipewritehandle: pinteger = nil;
             errorpipewritehandle: pinteger = nil;
             tty: boolean = false): integer;
const
 shell = shortstring('/bin/sh');
var
 procid: integer;
 topipehandles,frompipehandles,errorpipehandles: tpipedescriptors;
 params: array[0..3] of pchar;

 procedure execerr;
 var
  errorbefore: integer;
 begin
  errorbefore:= sys_getlasterror;
  if topipehandles.writedes <> invalidfilehandle then __close(topipehandles.writedes);
  if topipehandles.readdes <> invalidfilehandle then __close(topipehandles.readdes);
  if frompipehandles.writedes <> invalidfilehandle then __close(frompipehandles.writedes);
  if frompipehandles.readdes <> invalidfilehandle then __close(frompipehandles.readdes);
  if errorpipehandles.writedes <> invalidfilehandle then __close(errorpipehandles.writedes);
  if errorpipehandles.readdes <> invalidfilehandle then __close(errorpipehandles.readdes);
  execerror(errorbefore,commandline);
 end;
 
 procedure openpipe(var pipehandles: tpipedescriptors);
 const
  buflen = 80;
 var
  buffer: array[0..buflen] of char;
 begin
  if tty then begin
   with pipehandles do begin
    if @pipehandles = @topipehandles then begin
     if libc.pipe(pipehandles) <> 0 then execerr;
     {
     writedes:= getpt;
     if writedes < 0 then execerr;
     if (grantpt(writedes) < 0) or (unlockpt(writedes) < 0) then execerr;
     if ptsname_r(writedes,@buffer,buflen) < 0 then execerr;
     readdes:= open(buffer,o_rdonly);
     if readdes < 0 then execerr;
     }
    end
    else begin
     readdes:= getpt;
     if readdes < 0 then execerr;
     if (grantpt(readdes) < 0) or (unlockpt(readdes) < 0) then execerr;
     if ptsname_r(readdes,@buffer,buflen) < 0 then execerr;
     writedes:= open(buffer,o_wronly);
     if writedes < 0 then execerr;
    end;
   end;
  end
  else begin
   if libc.pipe(pipehandles) <> 0 then execerr;
  end;
 end;
 
begin
 result:= 0; //compilerwarnung;
 topipehandles.writedes:= invalidfilehandle;
 topipehandles.readdes:= invalidfilehandle;
 frompipehandles.writedes:= invalidfilehandle;
 frompipehandles.readdes:= invalidfilehandle;
 errorpipehandles.writedes:= invalidfilehandle;
 errorpipehandles.readdes:= invalidfilehandle;

 if topipe <> nil then begin
  openpipe(topipehandles);
  setcloexec(topipehandles.writedes);
  topipe^:= topipehandles.writedes;
 end;
 if frompipe <> nil then begin
  openpipe(frompipehandles);
  setcloexec(topipehandles.readdes);
  frompipe^:= frompipehandles.readdes;
 end;
 if errorpipe <> nil then begin
  if errorpipe <> frompipe then begin
   openpipe(errorpipehandles);
   setcloexec(topipehandles.readdes);
   errorpipe^:= errorpipehandles.readdes;
  end;
 end;
 procid:= libc.vfork;
// procid:= libc.fork;
 if procid = -1 then execerr;

 if procid = 0 then begin   //child
{$ifdef FPC}{$checkpointer off}{$endif}
  if sessionleader then begin
   setsid;
  end
  else begin
   if groupid <> -1 then begin
    setpgid(0,groupid);
   end;
  end;
  if topipe <> nil then begin
   __close(topipehandles.writedes);
   if dup2(topipehandles.ReadDes,0) = -1 then begin
    libc._exit(exit_failure);
   end;
   __close(topipehandles.readdes);
  end;
  if frompipe <> nil then begin
   __close(frompipehandles.readdes);
   if dup2(frompipehandles.writeDes,1) = -1 then begin
    libc._exit(exit_failure);
   end;
  end;
  if errorpipe <> nil then begin
   if errorpipe <> frompipe then  begin
    __close(errorpipehandles.readdes);
    if dup2(errorpipehandles.writeDes,2) = -1 then begin
     libc._exit(exit_failure);
    end;
    __close(errorpipehandles.writedes);
   end
   else begin
    if dup2(frompipehandles.writeDes,2) = -1 then begin
     libc._exit(exit_failure);
    end;
   end
  end;
  if frompipe <> nil then begin
   __close(frompipehandles.writedes);
  end;
  {$ifdef FPC}
  libc.execl(shell,shell,['-c',pchar(commandline),nil]);
  {$else}
  params[0]:= shell;
  params[1]:= pchar('-c');
  params[2]:= pchar(commandline);
  params[3]:= nil;
 {$warnings off}
  libc.syscall(11,pchar(shell),@params,envp); //problems with kylix debugger
 {$warnings on}
{$endif}
  libc._exit(exit_failure); //execl misslungen
{$ifdef FPC}{$checkpointer default}{$endif}
 end
 else begin //parent
  if topipe <> nil then begin
   __close(topipehandles.readDes);
  end;
  if frompipe <> nil then begin
   if frompipewritehandle <> nil then begin
    frompipewritehandle^:= frompipehandles.writedes;
   end
   else begin
    __close(frompipehandles.writeDes);
   end;
  end;
  if (errorpipe <> nil) and (errorpipe <> frompipe) then begin
   if errorpipewritehandle <> nil then begin
    errorpipewritehandle^:= errorpipehandles.writedes;
   end
   else begin
    __close(errorpipehandles.writeDes);
   end;
  end;
  if groupid <> -1 then begin
   if groupid = 0 then begin
    setpgid(procid,procid);
   end
   else begin
    setpgid(procid,groupid);
   end;
  end;
  result:= procid;
 end;
end;

function execmse(const commandline: string): boolean;
begin
 result:= true;
 try
  execmse1(commandline);
 except
  result:= false;
 end;
end;

procedure killprocess(handle: integer);
var
 int1: integer;
begin
 int1:= kill(handle,sigterm);
 if (int1 <> 0) and (errno <> esrch) then begin
  raise eoserror.create(''); //sigterm nicht moeglich
 end;
 if waitpid(handle,@int1,wnohang) = 0 then begin
  sleep(100);
  if waitpid(handle,@int1,wnohang) = 0 then begin
   sleep(1000);
   if waitpid(handle,@int1,wnohang) = 0 then begin
    int1:= kill(handle,sigkill);
    if (int1 <> 0) and (errno <> esrch) then begin
     raise eoserror.create(''); //sigkill nicht moeglich
    end;
    if waitpid(handle,@int1,0) = -1 then begin
     raise eoserror.create('');
    end;
   end;
  end;
 end;
end;

function terminateprocess(handle: integer): integer;
           //bringt exitresult
var
 int1: integer;
begin
 int1:= kill(handle,sigterm);
 if (int1 <> 0) and (errno <> esrch) then raise eoserror.create(''); 
             //sigterm nicht moeglich
 if waitpid(handle,@result,0) = -1 then raise eoserror.create('');
end;

function getppid2(pid: integer): integer;
var
 stream: ttextstream;
 str1: string;
begin
 stream:= ttextstream.create('/proc/'+inttostr(pid)+'/stat',fm_read);
 try
  fillchar(result,sizeof(result),0);
  stream.readln(str1);
  {$ifdef FPC}
  sscanf(pchar(str1),'%*d (%*a[^)]) %*c %d',[@result]);
  {$else}
  sscanf(pchar(str1),'%*d (%*a[^)]) %*c %d',@result);
  {$endif}
 finally
  stream.free;
 end;
end;

function getprocinfo(pid: integer): procinfoty;
var
 stream: ttextstream;
 str1: string;
 commpo: pchar;
begin
 stream:= ttextstream.create('/proc/'+inttostr(pid)+'/stat',fm_read);
 try
  fillchar(result,sizeof(result),0);
  stream.readln(str1);
  with result do begin
   libc.sscanf(pchar(str1),'%d (%a[^)]) %c %d %d %d %d %d %lu %lu '+
    '%lu %lu %lu %lu %lu %ld %ld %ld %ld %ld %ld %lu %lu %ld %lu %lu %lu %lu %lu '+
    '%lu %lu %lu %lu %lu %lu %lu %lu %d %d',
    {$ifdef FPC}[{$endif}
    @pid,
    @commpo,
    @state,
    @ppid,
    @pgrp,
    @session,
    @tty_nr,
    @tpgid,
    @flags,
    @minflt,
    @cminflt,
    @majflt,
    @cmajflt,
    @utime,
    @stime,
    @cutime,
    @cstime,
    @priority,
    @nice,
    @null,
    @itrealvalue,
    @starttime,
    @vsize,
    @rss,
    @rlim,
    @startcode,
    @endcode,
    @startstack,
    @kstkesp,
    @kstkeip,
    @signal,
    @blocked,
    @sigignore,
    @sigcatch,
    @wchan,
    @nswap,
    @cnswap,
    @exitsignal,
    @processor
    {$ifdef FPC}]{$endif}
                   );
   comm:= string(commpo);
   libc.free(commpo);
  end;
 finally
  stream.Free;
 end
end;

function getchildpid(pid: integer): integerarty;
var
 srec: tsearchrec;
 int1: integer;
begin
 result:= nil;
 if findfirst('/proc/*',fadirectory,srec) = 0 then begin
  repeat
   try
    if (length(srec.name) > 0) and (srec.name[1] >= '0') and
                (srec.name[1] <= '9') then begin
     int1:= strtoint(srec.name);
     if getppid2(int1) = pid then begin
      setlength(result,length(result)+1);
      result[length(result)-1]:= int1;
     end;
    end;
   except
   end;
  until findnext(srec) <> 0;
 end;
end;

function getinnerstpid(pid: integer): integer;
var
 intar1: integerarty;
 int1,int2: integer;
begin
 result:= pid;
 intar1:= getchildpid(pid);
 for int1:= 0 to length(intar1) - 1 do begin
  int2:= getinnerstpid(intar1[int1]);
  if int2 > result then begin
   result:= int2;
  end;
 end;
end;

{$endif}

function execmse2(const commandline: string; topipe: tpipewriter = nil;
             frompipe: tpipereader = nil;
             errorpipe: tpipereader = nil;
             sessionleader: boolean = false;
             groupid: integer = -1; //-1 -> keine, 0 = childpid
             inactive: boolean = true; //windows only
             usepipewritehandles: boolean = false;
             tty: boolean = false): integer;
 //bringt procid
var
 top,fromp,errp,fromwrite,errwrite: integer;
 topp,frompp,errpp,fromwritep,errwritep: pinteger;
begin
 if topipe <> nil then begin
  topp:= @top;
  topipe.close;
 end
 else begin
  topp:= nil;
 end;
 if frompipe <> nil then begin
  frompipe.close;
  frompp:= @fromp;
  fromwritep:= @fromwrite;
 end
 else begin
  frompp:= nil;
  fromwritep:= nil;
 end;
 if errorpipe <> nil then begin
  if errorpipe <> frompipe then begin
   errorpipe.close;
   errpp:= @errp;
   errwritep:= @errwrite;
  end
  else begin
   errpp:= @fromp;
   errwritep:= nil;
  end;
 end
 else begin
  errpp:= nil;
  errwritep:= nil;
 end;
 if not usepipewritehandles then begin
  fromwritep:= nil;
  errwritep:= nil;
 end;
 result:= execmse1(commandline,topp,frompp,errpp,sessionleader,groupid,
                          inactive,fromwritep,errwritep,tty);
 if topp <> nil then begin
  topipe.Handle:= topp^;
 end;
 if frompp <> nil then begin
  frompipe.Handle:= frompp^;
  if fromwritep <> nil then begin
   frompipe.writehandle:= fromwritep^;
  end;
 end;
 if errpp <> nil then begin
  if errorpipe <> frompipe then begin
   errorpipe.Handle:= errpp^;
   if errwritep <> nil then begin
    errorpipe.writehandle:= errwritep^;
   end;
  end;
 end;
end;

end.
