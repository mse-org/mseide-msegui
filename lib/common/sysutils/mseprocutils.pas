{ MSEgui Copyright (c) 1999-2012 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseprocutils;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
{$ifndef FPC}{$ifdef linux} {$define UNIX} {$endif}{$endif}

interface
uses
 {$ifdef mswindows}windows{$else}mselibc{$endif},
 msetypes,msestream,msepipestream,sysutils,msesysutils,msesystypes,msesys;
 
type
 pipedescriptorty = record
  readdes: integer;
  writedes: integer;
 end;
 execoptionty = (exo_shell,                    //default on Linux
                 exo_noshell,                  //default on Windows
                          //todo: implement on linux
                 exo_inactive,                 //windows only
                 exo_nostdhandle,              //windows only
                 exo_nowindow,                 //windows only
                 exo_detached,                 //windows only
                 exo_allowsetforegroundwindow, //windows only
                 exo_sessionleader,            //linux only
                 exo_settty,                   //linux only
                 exo_tty,exo_echo,exo_icanon,  //linux only
                 exo_usepipewritehandles,exo_winpipewritehandles                 
                 );         
 execoptionsty = set of execoptionty;
const
 pipewritehandlemask = [exo_usepipewritehandles
                  {$ifdef mswindows},exo_winpipewritehandles{$endif}];
                    
function getprocessexitcode(prochandle: prochandlety; out exitcode: integer;
                              const timeoutus: integer = 0): boolean;
                               //<0 -> no timeout
                 //true if ok, close handle
function waitforprocess(prochandle: prochandlety): integer;

function execmse(const commandline: string; const options: execoptionsty = []
//                    const inactive: boolean = true;    //windows only
//                    const nostdhandle: boolean = false //windows only
                ): boolean;
//starts program, true if OK

function execmse4(const commandline: string; const  options: execoptionsty = []
//                    const inactive: boolean = true;    //windows only
//                    const nostdhandle: boolean = false //windows only
                ): prochandlety;
//starts program, returns processhandle, execerror on error
//don't forget closehandle on windows!

function execmse1(const commandline: ansistring; topipe: pinteger = nil;
             frompipe: pinteger = nil;
             errorpipe: pinteger = nil;
//             sessionleader: boolean = false;
             groupid: integer = -1; //-1 -> keine, 0 = childpid
             const options: execoptionsty = [];
//             inactive: boolean = true; //windows only
             frompipewritehandle: pinteger = nil;
             errorpipewritehandle: pinteger = nil
//             tty: boolean = false;
//             nostdhandle: boolean = false //windows only
                 ): prochandlety;
//starts program, returns processhandle, execerror on error
//don't forget closehandle on windows!
//creates pipes

function execmse2(const commandline: string; topipe: tpipewriter = nil;
                      frompipe: tpipereader = nil;
                      errorpipe: tpipereader = nil;
//             sessionleader: boolean = false;
             groupid: integer = -1; //-1 -> keine, 0 = childpid
             const options: execoptionsty = []
//             inactive: boolean = true; //windows only
//             usepipewritehandles: boolean = false;
//             tty: boolean = false;
//             nostdhandle: boolean = false
                              //windows only
                 ): prochandlety;
//starts program, returns processhandle, execerror on error
//don't forget closehandle on windows!
//creates pipes

function execmse3(const commandline: string; topipe: pinteger = nil;
             frompipe: pinteger = nil;
             errorpipe: pinteger = nil;
//             sessionleader: boolean = false;
             groupid: integer = -1; //-1 -> keine, 0 = childpid
             const options: execoptionsty = [];
//             inactive: boolean = true; //windows only
             frompipewritehandle: pinteger = nil;
             errorpipewritehandle: pinteger = nil
//             tty: boolean = false;
//             nostdhandle: boolean = false
                              //windows only
                 ): prochandlety;
//starts program, returns processhandle, execerror on error
//don't forget closehandle on windows!
//uses existing file handles

function execwaitmse(const commandline: string;
                     const options: execoptionsty = []
//                      const inactive: boolean = true
                      ): integer; overload;
//runs programm, waits for program termination, returns program exitcode
//inactive true -> no console window (win32 only)

procedure killprocess(handle: prochandlety);
function terminateprocess(handle: prochandlety): integer;
           //sendet sigterm, bringt exitresult, -1 on error

function getpid: procidty; 
           
function getprocesstree: procitemarty;
function getprocesschildren(const pid: procidty): procidarty;
function getallprocesschildren(const pid: procidty): procidarty;
{moved to msegui
function activateprocesswindow(const procid: integer; 
                    const araise: boolean = true): boolean;
         //true if ok
}
function pipe(out desc: pipedescriptorty; write: boolean): boolean;
            //true if ok

 {$ifdef UNIX}
function getpseudoterminal(out name: string): integer;

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

function getprocinfo(pid: procidty): procinfoty;
function getchildpid(pid: procidty): procidarty;
function getinnerstpid(pid: procidty): procidty;
function getppid2(pid: procidty): procidty;

 {$endif}
type
 eexecerror = class(msesysutils.eoserror)
 end;

implementation
uses 
 msesysintf1,msesysintf,msestrings,mseprocmonitor,msearrayutils;

function getpid: procidty;
begin
 result:= sys_getpid;
end;

function compprocitem(const l,r): integer;
begin
 result:= procitemty(l).pid - procitemty(r).pid;
end;

function findprocitem(const l,r): integer;
begin
 result:= procidty(l) - procitemty(r).pid;
end;

function getprocesstree: procitemarty;
var
 int1,int2: integer;
begin
 result:= sys_getprocesses;
 sortarray(result,sizeof(procitemty),{$ifdef FPC}@{$endif}compprocitem);
 for int1:= 0 to high(result) do begin
  if findarrayitem(result[int1].ppid,result,sizeof(procitemty),
                      {$ifdef FPC}@{$endif}findprocitem,int2) then begin
   additem(winidarty(result[int2].children),result[int1].pid);
  end;
 end;
end;

function getprocesschildren(const pid: procidty): procidarty;
var
 ar1: procitemarty;
 int2: integer;
begin
 ar1:= getprocesstree;
 if findarrayitem(pid,ar1,sizeof(procitemty),
                         {$ifdef FPC}@{$endif}findprocitem,int2) then begin
  result:= ar1[int2].children;
 end
 else begin
  result:= nil;
 end;
end;

function getallprocesschildren(const pid: procidty): procidarty;
var
 ar1: procitemarty;
 
 procedure addproc(const pid: integer);
 var
  int1,int2: integer;
 begin
  if findarrayitem(pid,ar1,sizeof(procitemty),
                       {$ifdef FPC}@{$endif}findprocitem,int2) then begin
   stackarray(winidarty(ar1[int2].children),winidarty(result));
   for int1:= 0 to high(ar1[int2].children) do begin
    addproc(ar1[int2].children[int1]);
   end;
  end;
 end;
  
begin
 ar1:= getprocesstree;
 setlength(result,1);
 result[0]:= pid;
 addproc(pid);
end;

procedure execerror(const errno: integer; const commandline: string);
begin
 raise eexecerror.Create(errno,'Can not execute "'+commandline+'".'+lineend);
end;

{$ifdef mswindows}
function getprocessexitcode(prochandle: prochandlety; out exitcode: integer;
                  const timeoutus: integer = 0): boolean;
                 //true if ok, close handle
var
 dwo1: longword;
 ca1: longword;
begin
 result:= false;
 exitcode:= -1;
 if prochandle <> invalidprochandle then begin
  if timeoutus < 0 then begin
   exitcode:= waitforprocess(prochandle);
   result:= true;
  end
  else begin
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
      if (timeoutus = 0) or timeout(ca1) then begin
       result:= false;
       break;
      end;
      sys_schedyield;
     end;
    end
    else begin
     exit;
//     raise eoserror.create('');
    end;
   end;
  end;
 end;
end;

function waitforprocess(prochandle: prochandlety): integer;
begin
 result:= -1;
 if waitforsingleobject(prochandle,infinite) = wait_object_0 then begin
  getprocessexitcode(prochandle,result);
 end;
// else begin
//  raise eoserror.create('');
// end;
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
 if createpipe(longword(desc.readdes),longword(desc.writedes),@sa,0) then begin
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

function execmse0(const commandline: string; topipe: pinteger = nil;
             frompipe: pinteger = nil;
             errorpipe: pinteger = nil;
             groupid: integer = -1; //-1 -> keine, 0 = childpid
             const options: execoptionsty = [];
             frompipewritehandle: pinteger = nil;
             errorpipewritehandle: pinteger = nil
             ): prochandlety;
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
 creationflags: dword = 0;
 processinfo: tprocessinformation;
 bo1: boolean;
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
  if topipe^ = invalidfilehandle then begin
   if not pipe(topipehandles,true) then execerr;
   topipe^:= topipehandles.WriteDes;
   startupinfo.hStdInput:= topipehandles.readdes;
  end
  else begin
   startupinfo.hStdInput:= topipe^;
  end;
 end;
 if frompipe <> nil then begin
  if frompipe^ = invalidfilehandle then begin
   if not pipe(frompipehandles,false) then execerr;
   frompipe^:= frompipehandles.readDes;
   startupinfo.hStdoutput:= frompipehandles.writedes;
  end
  else begin
   startupinfo.hStdoutput:= frompipe^;
  end;
 end;
 if errorpipe <> nil then begin
  if errorpipe <> frompipe then begin
   if errorpipe^ = invalidfilehandle then begin
    if not pipe(errorpipehandles,false) then execerr;
    errorpipe^:= errorpipehandles.readdes;
    startupinfo.hStderror:= errorpipehandles.writedes;
   end
   else begin
    startupinfo.hStderror:= errorpipe^;
   end;
  end
  else begin
   if frompipe^ <> invalidfilehandle then begin
    errorpipe^:= frompipehandles.readdes;
    startupinfo.hStderror:= frompipehandles.writedes;
   end
   else begin
    startupinfo.hStderror:= frompipe^;
   end;
  end;
 end;
 if not (exo_nostdhandle in options) then begin
  startupinfo.dwflags:= startupinfo.dwFlags or startf_usestdhandles;
 end;
 if exo_nowindow in options then begin
  creationflags:= creationflags or create_no_window;
 end;
 if exo_detached in options then begin
  creationflags:= creationflags or detached_process;
 end;
 if (exo_allowsetforegroundwindow in options) and 
        assigned(allowsetforegroundwindow) then begin
  allowsetforegroundwindow(asfw_any);
 end;
 if exo_inactive in options then begin
  startupinfo.wShowWindow:= sw_hide;
  startupinfo.dwflags:= startupinfo.dwFlags or startf_useshowwindow;
 end;
 if exo_shell in options then begin
  bo1:= createprocess(nil,pchar('cmd.exe '+'/c'+commandline),
                           nil,nil,true,creationflags,nil,nil,startupinfo,processinfo);
 end
 else begin
  bo1:= createprocess(nil,pchar(commandline),nil,nil,true,creationflags,nil,nil,
                                                  startupinfo,processinfo);
 end;
 if bo1 then begin
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

function execmse(const commandline: string;const options: execoptionsty = []
//                     const inactive: boolean = true; //windows only
//                     const nostdhandle: boolean = false
                               //windows only
                           ): boolean;
var
 prochandle: prochandlety;
begin
 result:= true;
 try
  try
   prochandle:= execmse1(commandline,nil,nil,nil,{false,}-1,options{inactive,
                         nil,nil,false,nostdhandle});
  finally
   if prochandle <> invalidprochandle then begin
    closehandle(prochandle);
   end;
  end;
  except
   result:= false;
 end;
end;

function execmse4(const commandline: string; const options: execoptionsty = []
//                    const inactive: boolean = true; //windows only
//                    const nostdhandle: boolean = false
                               //windows only
                ): prochandlety;
begin
 result:= execmse1(commandline,nil,nil,nil,{false,}-1,options{inactive,
                       nil,nil,false,nostdhandle});
end;

function execwaitmse(const commandline: string;
                     const options: execoptionsty = []
//                      const inactive: boolean = true
                      ): integer;
//startet programm, wartet auf ende, bring exitcode, -1 wenn start nicht moeglich
var
 prochandle: prochandlety;
// bo1: boolean;
// dwo1: dword;
begin
 result:= -1;
   //programm wurde nicht gestartet oder getexitcodeprozessproblem
 prochandle:= execmse1(commandline,nil,nil,nil,{false,}-1,options{inactive});
 if prochandle <> invalidprochandle then begin
  result:= waitforprocess(prochandle);
  {
  repeat
   sys_sched_yield;
   bo1:= getexitcodeprocess(prochandle,dwo1);
   if bo1 then begin
    result:= dwo1;
   end;
  until not bo1 or (dwo1 <> still_active);
  closehandle(prochandle);
  }
 end;
end;

procedure killprocess(handle: prochandlety);
begin
 if handle <> invalidprochandle then begin
  windows.terminateprocess(handle,0);
  closehandle(handle);
 end;
end;

function terminateprocess(handle: prochandlety): integer;
           //bricht process ab, kein exitresult
begin
 result:= -1;
 if handle <> invalidprochandle then begin
  result:= 0;
  killprocess(handle);
 end;
end;

{$endif}

{$ifdef UNIX}
function getprocessexitcode(prochandle: prochandlety; out exitcode: integer;
                               const timeoutus: integer = 0): boolean;
                               //-1 -> no timeout
                 //true if ok, close handle
var
 dwo1: longword;
 cancel: boolean;
  
 function check(const apid: integer): boolean;
 begin
  result:= false;
  if apid <> -1 then begin
   result:= apid = prochandle;
   if result then begin
    exitcode:= wexitstatus(dwo1);
   end;
  end
  else begin
   if sys_getlasterror <> eintr then begin
    cancel:= true;
//    raise eoserror.create('getprocessexitcode: ');
   end;
  end;
 end;

var
 ca1: longword;

begin
 result:= false;
 cancel:= false;
 exitcode:= -1;
 if prochandle <> invalidprochandle then begin
  result:= check(waitpid(prochandle,@dwo1,wnohang));
  if not result and (timeoutus <> 0) then begin
   if timeoutus < 0 then begin
    repeat
     result:= check(waitpid(prochandle,@dwo1,0));
    until result or cancel;
   end
   else begin
    ca1:= timestep(timeoutus);
    while not result and not cancel and not timeout(ca1) do begin
     sys_schedyield;
     sleep(10);       //todo: use better method
     result:= check(waitpid(prochandle,@dwo1,wnohang));
    end;
   end;
  end;
 end;
 {
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
    sys_schedyield;
//    sys_threadschedyield;
   end;
  end
  else begin
   raise eoserror.create('');
  end;
 end;
 }
end;

function waitforprocess(prochandle: prochandlety): integer;
var
 dwo1: longword;
 pid: integer;
begin
 result:= -1;
 while true do begin
  pid:= waitpid(prochandle,@dwo1,0);
  if pid <> -1 then begin
   result:= wexitstatus(dwo1);
   break;
  end
  else begin
   if sys_getlasterror <> eintr then begin
    exit;
//    result:= 0; //compilerwarning
//    raise eoserror.create('');
   end;
  end;
 end;
end;

function execwaitmse(const commandline: string;
                     const options: execoptionsty = []
                      //const inactive: boolean = true
                      ): integer;
begin
 result:= mselibc.{$ifdef FPC}__system{$else}system{$endif}(pchar(commandline));
end;

function pipe(out desc: pipedescriptorty; write: boolean): boolean;
            //returns errorcode, 0 if ok
begin
 result:= mselibc.pipe(tpipedescriptors(desc)) = 0;
 if result then begin
  if write then begin
   setcloexec(desc.writedes);
  end
  else begin
   setcloexec(desc.readdes);
  end;
 end;
end;

function getpseudoterminal(out name: string): integer;
const
 buflen = 256;
var
 buffer: array[0..buflen] of char;
begin
 result:= getpt;
 if result < 0 then begin
  syserror(sye_lasterror);
 end;
 if (grantpt(result) < 0) or (unlockpt(result) < 0) then begin
  syserror(sye_lasterror);
 end;
 if ptsname_r(result,@buffer,buflen) < 0 then begin
  syserror(sye_lasterror);
 end;
 name:= buffer; 
end;

function execmse0(const commandline: string; topipe: pinteger = nil;
             frompipe: pinteger = nil;
             errorpipe: pinteger = nil;
             groupid: integer = -1; //-1 -> keine, 0 = childpid
             const options: execoptionsty = [];
             frompipewritehandle: pinteger = nil;
             errorpipewritehandle: pinteger = nil
             ): prochandlety;
const
 shell = shortstring('/bin/sh');
 buflen = 256;
type
 namebufferty = array[0..buflen] of char;
var
 procid: integer;
 topipehandles,frompipehandles,errorpipehandles: tpipedescriptors;
 ptyout: integer = -1;
 ptyerr: integer = -1;
 ptynameout: namebufferty;
 ptynameerr: namebufferty;
 
{$ifndef FPC}
 params: array[0..3] of pchar;
{$endif}
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

 function dogetpt(var pty: integer; var ptyname: namebufferty): integer;
  procedure ptyerror;
  begin
   __close(pty);
   pty:= -1;
  end; //ptyerror
 var
  ios: termios;  
 begin
  if pty < 0 then begin
   pty:= getpt;
   if msetcgetattr(pty,ios) <> 0 then begin
    ptyerror;
   end
   else begin
    if exo_icanon in options then begin
     ios.c_lflag:= ios.c_lflag or icanon;
    end
    else begin
     ios.c_lflag:= ios.c_lflag and not icanon;
    end;
    if exo_echo in options then begin
     ios.c_lflag:= ios.c_lflag or echo;
    end
    else begin
     ios.c_lflag:= ios.c_lflag and not echo;
    end;
    ios.c_cc[vmin]:= #1;
    ios.c_cc[vtime]:= #0;
    if msetcsetattr(pty,tcsanow,ios) <> 0 then begin
     ptyerror;
    end
    else begin
     if (grantpt(pty) < 0) or (unlockpt(pty) < 0) then begin
      ptyerror;
     end;
    end;
   end;
  end;
  if pty >= 0 then begin
   if ptsname_r(pty,@ptyname,buflen) < 0 then begin
    ptyerror;
   end;
  end;
  result:= pty;
 end; //dogetpt
  
 procedure openpipe(var pipehandles: tpipedescriptors);
 begin
  if exo_tty in options then begin
   with pipehandles do begin
    if @pipehandles = @topipehandles then begin
     writedes:= dogetpt(ptyout,ptynameout);
     readdes:= open(ptynameout,o_rdonly);
     if readdes < 0 then execerr;
    end
    else begin
     if @pipehandles = @frompipehandles then begin
      readdes:= dogetpt(ptyout,ptynameout);
      if readdes < 0 then execerr;
      writedes:= open(ptynameout,o_wronly);
     end
     else begin
      readdes:= dogetpt(ptyerr,ptynameerr);
      if readdes < 0 then execerr;
      writedes:= open(ptynameerr,o_wronly);
     end;
     if writedes < 0 then execerr;
    end;
   end;
  end
  else begin
   if mselibc.pipe(pipehandles) <> 0 then execerr;
  end;
 end;

var
// lockvar: integer; 
 bo1: boolean;
begin
// lockvar:= 0;
 result:= invalidprochandle; //compilerwarnung;
 topipehandles.writedes:= invalidfilehandle;
 topipehandles.readdes:= invalidfilehandle;
 frompipehandles.writedes:= invalidfilehandle;
 frompipehandles.readdes:= invalidfilehandle;
 errorpipehandles.writedes:= invalidfilehandle;
 errorpipehandles.readdes:= invalidfilehandle;

 if topipe <> nil then begin
  if topipe^ = invalidfilehandle then begin
   openpipe(topipehandles);
   setcloexec(topipehandles.writedes);
   topipe^:= topipehandles.writedes;
  end
  else begin
   topipehandles.readdes:= topipe^;
  end;
 end;
 if frompipe <> nil then begin
  if frompipe^ = invalidfilehandle then begin
   openpipe(frompipehandles);
   setcloexec(topipehandles.readdes);
   frompipe^:= frompipehandles.readdes;
  end
  else begin
   frompipehandles.writedes:= frompipe^;
  end;
 end;
 if errorpipe <> nil then begin
  if errorpipe <> frompipe then begin
   if errorpipe^ = invalidfilehandle then begin
    openpipe(errorpipehandles);
    setcloexec(topipehandles.readdes);
    errorpipe^:= errorpipehandles.readdes;
   end
   else begin
    errorpipehandles.writedes:= errorpipe^;
   end;
  end;
 end;
 procid:= mselibc.vfork;
// procid:= mselibc.fork;
 if procid = -1 then execerr;

 if procid = 0 then begin   //child
{$ifdef FPC}{$checkpointer off}{$endif}
  if exo_sessionleader in options then begin
   setsid;
  end
  else begin
   if groupid <> -1 then begin
    if groupid = 0 then begin
     setpgid(procid,procid);
    end
    else begin
     setpgid(procid,groupid);
    end;
   end;
  end;
  if (exo_settty in options) then begin
   bo1:= false;        //search posssible controlling TTY
   if (topipehandles.writedes <> invalidfilehandle) and 
                       (isatty(topipehandles.readdes) <> 0) then begin
    bo1:= ioctl(topipehandles.readdes,TIOCSCTTY,[]) <> -1;
   end;
   if not bo1 and (frompipehandles.writedes <> invalidfilehandle) and 
                           (isatty(frompipehandles.writedes) <> 0) then begin
     bo1:= ioctl(frompipehandles.writedes,TIOCSCTTY,[]) <> -1;
   end;
   if not bo1 and (errorpipehandles.writedes <> invalidfilehandle) and 
                          (isatty(errorpipehandles.writedes) <> 0) then begin
    bo1:= ioctl(errorpipehandles.writedes,TIOCSCTTY,[]) <> -1;
   end;
  end;
  if topipe <> nil then begin
   __close(topipehandles.writedes);
   if dup2(topipehandles.ReadDes,0) = -1 then begin
//    interlockedincrement(lockvar);
    mselibc._exit(exit_failure);
   end;
   __close(topipehandles.readdes);
  end;
  if frompipe <> nil then begin
   __close(frompipehandles.readdes);
   if dup2(frompipehandles.writeDes,1) = -1 then begin
//    interlockedincrement(lockvar);
    mselibc._exit(exit_failure);
   end;
  end;
  if errorpipe <> nil then begin
   if errorpipe <> frompipe then  begin
    __close(errorpipehandles.readdes);
    if dup2(errorpipehandles.writeDes,2) = -1 then begin
//     interlockedincrement(lockvar);
     mselibc._exit(exit_failure);
    end;
    __close(errorpipehandles.writedes);
   end
   else begin
    if dup2(frompipehandles.writeDes,2) = -1 then begin
//     interlockedincrement(lockvar);
     mselibc._exit(exit_failure);
    end;
   end
  end;
  if frompipe <> nil then begin
   __close(frompipehandles.writedes);
  end;
//  interlockedincrement(lockvar);
  {$ifdef FPC}
  mselibc.execl(shell,shell,['-c',pchar(commandline),nil]);
  {$else}
  params[0]:= shell;
  params[1]:= pchar('-c');
  params[2]:= pchar(commandline);
  params[3]:= nil;
 {$warnings off}
  mselibc.syscall(11,pchar(shell),@params,envp); //problems with kylix debugger
 {$warnings on}
{$endif}
  mselibc._exit(exit_failure); //execl misslungen
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
  {
  if groupid <> -1 then begin
   if groupid = 0 then begin
    setpgid(procid,procid);
   end
   else begin
    setpgid(procid,groupid);
   end;
  end;
  }
  result:= procid;
//  while lockvar = 0 do begin
//   usleep(0); //sched_yield
//  end;
 end;
end;

function execmse(const commandline: string; const options: execoptionsty = []
//                    const inactive: boolean = true;
//                    const nostdhandle: boolean = false
                                //windows only
                    ): boolean;
var
 procid: prochandlety;
begin
 result:= true;
 try
  procid:= execmse1(commandline);
  pro_killzombie(procid);
 except
  result:= false;
 end;
end;

function execmse4(const commandline: string; const options: execoptionsty = []
//                    const inactive: boolean = true; //windows only
//                    const nostdhandle: boolean = false
                               //windows only
                ): prochandlety;
begin
 result:= execmse1(commandline,nil,nil,nil,-1,options);
end;

procedure killprocess(handle: prochandlety);
var
 int1: integer;
begin
 if handle <> invalidprochandle then begin
  int1:= kill(handle,sigterm);
  if (int1 <> 0) and (errno <> esrch) then begin
   exit;
//   raise eoserror.create(''); //sigterm nicht moeglich
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
     while waitpid(handle,@int1,0) = -1 do begin
      if sys_getlasterror <> eintr then begin
       raise eoserror.create('');
      end;
     end;
    end;
   end;
  end;
 end;
end;

function terminateprocess(handle: prochandlety): integer;
           //bringt exitresult
var
 int1: integer;
begin
 result:= -1;
 if handle <> invalidprochandle then begin
  int1:= kill(handle,sigterm);
  if (int1 <> 0) and (errno <> esrch) then raise eoserror.create(''); 
              //sigterm nicht moeglich
  while waitpid(handle,@result,0) = -1 do begin
   if sys_getlasterror <> eintr then begin
    break;
//    raise eoserror.create('');
   end;
  end;
 end;
end;

function getppid2(pid: procidty): procidty;
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

function getprocinfo(pid: procidty): procinfoty;
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
   mselibc.sscanf(pchar(str1),'%d (%a[^)]) %c %d %d %d %d %d %lu %lu '+
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
   mselibc.free(commpo);
  end;
 finally
  stream.Free;
 end
end;

function getchildpid(pid: procidty): procidarty;
var
 srec: tsearchrec;
 int1: procidty;
begin
 result:= nil;
 if findfirst('/proc/*',fadirectory,srec) = 0 then begin
  repeat
   if (length(srec.name) > 0) and (srec.name[1] >= '0') and
               (srec.name[1] <= '9') then begin
{$ifdef CPU64}
    if trystrtoint64(srec.name,int1) then begin
{$else}
    if trystrtoint(srec.name,int1) then begin
{$endif}
     if getppid2(int1) = pid then begin
      setlength(result,length(result)+1);
      result[length(result)-1]:= int1;
     end;
    end;
   end;
  until findnext(srec) <> 0;
 end;
end;

function getinnerstpid(pid: procidty): procidty;
var
 intar1: procidarty;
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

function execmse1(const commandline: ansistring; topipe: pinteger = nil;
             frompipe: pinteger = nil;
             errorpipe: pinteger = nil;
//             sessionleader: boolean = false;
             groupid: integer = -1; //-1 -> keine, 0 = childpid
             const options: execoptionsty = [];
//             inactive: boolean = true; //windows only
             frompipewritehandle: pinteger = nil;
             errorpipewritehandle: pinteger = nil
//             tty: boolean = false;
//             nostdhandle: boolean = false
                              //windows only
                 ): prochandlety;
        //creates pipes
begin
 if topipe <> nil then begin
  topipe^:= invalidfilehandle;
 end;
 if frompipe <> nil then begin
  frompipe^:= invalidfilehandle;
 end;
 if errorpipe <> nil then begin
  errorpipe^:= invalidfilehandle;
 end;
 result:= execmse0(commandline,topipe,frompipe,errorpipe,{sessionleader,}
           groupid,options,frompipewritehandle,errorpipewritehandle);
end;

function execmse3(const commandline: string; topipe: pinteger = nil;
             frompipe: pinteger = nil;
             errorpipe: pinteger = nil;
             groupid: integer = -1; //-1 -> keine, 0 = childpid
             const options: execoptionsty = [];
             frompipewritehandle: pinteger = nil;
             errorpipewritehandle: pinteger = nil
                         ): prochandlety;
    //uses existing file handles
begin
 result:= execmse0(commandline,topipe,frompipe,errorpipe,{sessionleader,}
           groupid,options,frompipewritehandle,errorpipewritehandle);
end;

function execmse2(const commandline: string; topipe: tpipewriter = nil;
             frompipe: tpipereader = nil;
             errorpipe: tpipereader = nil;
             groupid: integer = -1; //-1 -> keine, 0 = childpid
             const options: execoptionsty = []
             ): prochandlety;
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
 if options * pipewritehandlemask = [] then begin
  fromwritep:= nil;
  errwritep:= nil;
 end;
 result:= execmse1(commandline,topp,frompp,errpp,{sessionleader,}groupid,
                          options,
                          {inactive,}fromwritep,errwritep{,tty,nostdhandle});
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
