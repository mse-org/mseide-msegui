{ MSEgui Copyright (c) 1999-2011 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msesysintf; //i386-win32

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 msesys,{msethread,}msetypes,msesystypes,msestrings,windows,msectypes;

{$include ..\msesysintf.inc}

type
 NTSTATUS = longword;

const
 ASFW_ANY = dword(-1);
         //PROCESSINFOCLASS
 ProcessBasicInformation = 0;
 ProcessDebugPort = 7;
 ProcessWow64Information = 26;
 ProcessImageFileName = 27;
 ProcessBreakOnTermination = 29;

var
 AllowSetForegroundWindow: function(dwProcessId: DWORD):WINBOOL; stdcall;

function procidfromprochandle(const ahandle: prochandlety): procidty;

implementation
uses
 sysutils,msebits,msefileutils,{msedatalist,}dateutils,
 msesystimer,msearrayutils,msesysintf1,msedynload;

//todo: correct unicode implementation, long filepaths, stubs for win95
type
{$packrecords c}
 PROCESS_BASIC_INFORMATION = record
     Reserved1: PVOID;
     PebBaseAddress: pointer;//PPEB;
     Reserved2: array[0..1] of PVOID;
     UniqueProcessId: ULONG_PTR;
     Reserved3: PVOID;
 end;
 pPROCESS_BASIC_INFORMATION = ^PROCESS_BASIC_INFORMATION;

var
 ZwQueryInformationProcess: function(ProcessHandle: HANDLE;
                  ProcessInformationClass: cint{PROCESSINFOCLASS};
                  ProcessInformation: PVOID;
                  ProcessInformationLength: ULONG;
                  ReturnLength: PULONG): NTSTATUS; stdcall;
 NtQueryInformationProcess: function(
                  ProcessHandle: HANDLE;
                  ProcessInformationClass: cint{PROCESSINFOCLASS};
                  ProcessInformation: PVOID;
                  ProcessInformationLength: cULONG;
                  ReturnLength: PULONG): NTSTATUS; stdcall;
 GetProcessId: function(Process: HANDLE): DWORD; stdcall;

function procidfromprochandle(const ahandle: prochandlety): procidty;
var
 info: PROCESS_BASIC_INFORMATION;
 len1: culong;
begin
 result:= invalidprocid;
 if getprocessid <> nil then begin
  result:= getprocessid(ahandle);
 end
 else begin
  if NtQueryInformationProcess <> nil then begin
   if NtQueryInformationProcess(ahandle,processbasicinformation,@info,
                                           sizeof(info),@len1) = 0 then begin
    result:= info.uniqueprocessid;
   end;
  end
  else begin
   if ZwQueryInformationProcess <> nil then begin
    if ZwQueryInformationProcess(ahandle,processbasicinformation,@info,
                                            sizeof(info),@len1) = 0 then begin
     result:= info.uniqueprocessid;
    end;
   end;
  end;
 end;
end;

var
 apphomedir: filenamety;
 userhomedir: filenamety;

const
 FILE_ATTRIBUTE_ENCRYPTED	= $0040;
 FILE_ATTRIBUTE_REPARSE_POINT = $0400;
 FILE_ATTRIBUTE_SPARSE_FILE = $0200;
 {$ifdef FPC}
 FILE_ATTRIBUTE_OFFLINE              = $00001000;
 {$endif}
 filetimeoffset = -109205.0;

type
 win32threadinfoty = record                //64bit
  handle: thandle;                         //8
  platformdata: array[1..3] of pointer;
 end;

 winfileinfoty = record
  dwFileAttributes: DWORD;
  ftCreationTime: TFileTime;
  ftLastAccessTime: TFileTime;
  ftLastWriteTime: TFileTime;
 end;
 winfilesizety = record
  nFileSizeHigh: DWORD;
  nFileSizeLow: DWORD;
 end;
 winfilenameaty = array[0..MAX_PATH - 1] of Char;
 pwinfilenameaty = ^winfilenameaty;
 WIN32_FIND_DATAA = record
   winfo: winfileinfoty;
   wsize: winfilesizety;
   dwReserved0: DWORD;
   dwReserved1: DWORD;
   cFileName: winfilenameaty;
   cAlternateFileName: array[0..13] of Char;
 end;
 pwin32_find_dataa = ^win32_find_dataa;
 WIN32_FIND_DATAW = record
   winfo: winfileinfoty;
   wsize: winfilesizety;
   dwReserved0: DWORD;
   dwReserved1: DWORD;
   cFileName: array[0..MAX_PATH - 1] of WideChar;
   cAlternateFileName: array[0..13] of WideChar;
 end;
 pwin32_find_dataw = ^win32_find_dataw;

 BY_HANDLE_FILE_INFORMATION = record
  winfo: winfileinfoty;
  dwVolumeSerialNumber: DWORD;
  wsize: winfilesizety;
  nNumberOfLinks: DWORD;
  nFileIndexHigh: DWORD;
  nFileIndexLow: DWORD;
 end;

 dirstreamwin32ty = record                //64bit
  handle: thandle;                        //8
  finddatapo: pwin32_find_dataw;          //8
  last: boolean;                          //4
  drivenum: integer; //for root directory //4 total 24
 {$ifdef cpu64}                           //platformdata = 64
  platformdata: array[3..7] of pointer;
 {$else}
  platformdata: array[4..7] of pointer;
 {$endif}
 end;

const
 TH32CS_SNAPHEAPLIST = $00000001;
 TH32CS_SNAPPROCESS  = $00000002;
 TH32CS_SNAPTHREAD   = $00000004;
 TH32CS_SNAPMODULE   = $00000008;
 TH32CS_SNAPALL      = TH32CS_SNAPHEAPLIST or TH32CS_SNAPPROCESS or
                       TH32CS_SNAPTHREAD or TH32CS_SNAPMODULE;
 TH32CS_INHERIT      = $80000000;
type
 {$ifndef FPC}
 LONG = integer;
 {$endif}
 PROCESSENTRY32 = record
  dwSize: DWORD;
  cntUsage: DWORD;
  th32ProcessID: DWORD;
  th32DefaultHeapID: pointer;
  th32ModuleID: DWORD;
  cntThreads: DWORD;
  th32ParentProcessID: DWORD;
  pcPriClassBase: LONG;
  dwFlags: DWORD;
  szExeFile: array[0..MAX_PATH-1] of char;
 end;
 PPROCESSENTRY32 = ^PROCESSENTRY32;

function CreateToolhelp32Snapshot(dwFlags: dword; th32ProcessId: dword): thandle;
              stdcall; external kernel32 name 'CreateToolhelp32Snapshot';
function Process32First(hSnapshot: thandle; lppe: PPROCESSENTRY32): BOOL;
              stdcall; external kernel32 name 'Process32First';
function Process32Next(hSnapshot: thandle; lppe: PPROCESSENTRY32): BOOL;
              stdcall; external kernel32 name 'Process32Next';
function GetFileInformationByHandle(hFile: THandle;
                    var lpFileInformation: By_Handle_File_Information): BOOL;
              stdcall; external 'kernel32' name 'GetFileInformationByHandle';

var
 GetLongPathNameW: function(lpszShortPath: LPCWSTR; lpszLongPath: LPCWSTR;
                                           cchBuffer: DWORD):DWORD; stdcall;

function sys_getpid: procidty;
begin
 result:= getcurrentprocessid;
end;

function sys_terminateprocess(const proc: prochandlety): syserrorty;
begin
 result:= sye_notimplemented;
end;

function sys_killprocess(const proc: prochandlety): syserrorty;
begin
 result:= sye_ok;
 if not windows.terminateprocess(proc,0) then begin
  result:= syelasterror;
 end;
end;

function sys_stdin: integer;
begin
 result:= getstdhandle(std_input_handle);
end;

function sys_stdout: integer;
begin
 result:= getstdhandle(std_output_handle);
end;

function sys_stderr: integer;
begin
 result:= getstdhandle(std_error_handle);
end;

function sys_getprintcommand: msestring;
begin
 result:= defaultprintcommand;
 if result = '' then begin
  result:= 'gswin32c.exe -dNOPAUSE -sDEVICE=mswinpr2 -';
 end;
end;

{
function sys_towupper(char: msechar): msechar;
begin
 result:= windows.charupperw(ord(char)); //win95?
end;

function sys_toupper(char: char): char;
begin
 result:= windows.charupper(ord(char));
end;
}

function sys_getprocesses: procitemarty;
var
 int1: integer;
 th: thandle;
 info: processentry32;
begin
 result:= nil;
 th:= createtoolhelp32snapshot(th32cs_snapprocess,0);
 int1:= 0;
 if th <> invalid_handle_value then begin
  info.dwsize:= sizeof(info);
  if process32first(th,@info) then begin
   repeat
    additem(result,typeinfo(procitemarty),int1);
    with result[int1-1] do begin
     pid:= info.th32processid;
     ppid:= info.th32parentprocessid;
    end;
   until not process32next(th,@info);
  end;
  closehandle(th);
  setlength(result,int1);
 end;
end;

procedure sys_schedyield;
begin
 windows.sleep(0);
end;

procedure sys_usleep(const us: cardinal);
begin
 windows.sleep(us div 1000);
end;

function sys_getapplicationpath: filenamety;
const
 bufsize = 1024;
var
 int1: integer;
 str1: string;
begin
 setlength(str1,bufsize);
 int1:= getmodulefilename(hinstance,@str1[1],bufsize-1);
 setlength(str1,int1);
 result:= tomsefilepath(msestring(str1));
end;

function sys_getcommandlinearguments: msestringarty;
begin
 {$ifdef FPC}{$checkpointer off}{$endif}
 result:= parsecommandline(msestring(cmdline)); //todo: use unicode
 {$ifdef FPC}{$checkpointer default}{$endif}
end;

procedure sys_getenvvars(out names: msestringarty; out values: msestringarty);
var
 po0,po1,po2,po3: pmsechar;
 po0a,po1a,po2a,po3a: pchar;
 str1: ansistring;
begin
 if iswin95 then begin
  po0a:= getenvironmentstringsa();
  po1a:= po0a;
  while po1a^ <> #0 do begin
   po2a:= po1a;
   while po2a^ <> #0 do begin
    inc(po2a);
   end;
   po3a:= po1a;
   while (po3a^ <> '=') and (po3a < po2a) do begin
    inc(po3a);
   end;
   str1:= psubstr(po1a,po3a);
   oemtoansibuff(pointer(str1),pointer(str1),length(str1));
   additem(names,msestring(str1));
   str1:= psubstr(po3a+1,po2a);
   oemtoansibuff(pointer(str1),pointer(str1),length(str1));
   additem(values,msestring(str1));
   po1a:= po2a+1;
  end;
  freeenvironmentstringsa(po0a);
 end
 else begin
  po0:= getenvironmentstringsw();
  po1:= po0;
  while po1^ <> #0 do begin
   po2:= po1;
   while po2^ <> #0 do begin
    inc(po2);
   end;
   po3:= po1;
   while (po3^ <> '=') and (po3 < po2) do begin
    inc(po3);
   end;
   additem(names,psubstr(po1,po3));
   additem(values,psubstr(po3+1,po2));
   po1:= po2+1;
  end;
  freeenvironmentstringsw(po0);
 end;
end;

function sys_getenv(const aname: msestring; out avalue: msestring): boolean;
                          //true if found
var
 str1,str2: string;
 lwo1: longword;
begin
 avalue:= '';
 if iswin95 then begin
  str2:= ansistring(aname);
  lwo1:= getenvironmentvariablea(pchar(str2),nil,0);
  result:= lwo1 > 0;
  if result then begin
   if lwo1 > 1 then begin
    setlength(str1,lwo1-1);
    lwo1:= getenvironmentvariablea(pchar(str2),pointer(str1),lwo1);
    result:= lwo1 > 0;
    setlength(str1,lwo1);
    avalue:= msestring(str1);
   end;
  end;
 end
 else begin
  lwo1:= getenvironmentvariablew(pmsechar(aname),nil,0);
  result:= lwo1 > 0;
  if result then begin
   if lwo1 > 1 then begin
    setlength(avalue,lwo1-1);
    lwo1:= getenvironmentvariablew(pmsechar(aname),pointer(avalue),lwo1);
    result:= lwo1 > 0;
    setlength(avalue,lwo1);
   end;
  end;
 end;
end;

function sys_setenv(const aname: msestring; const avalue: msestring): syserrorty;
begin
 result:= sye_ok;
 if iswin95 then begin
  if not setenvironmentvariablea(pchar(ansistring(aname)),
                                     pchar(ansistring(avalue))) then begin
   result:= syelasterror;
  end;
 end
 else begin
  if not setenvironmentvariablew(pmsechar(aname),
                                     pmsechar(avalue)) then begin
   result:= syelasterror;
  end;
 end;
end;

function sys_unsetenv(const aname: msestring): syserrorty;
begin
 result:= sye_ok;
 if iswin95 then begin
  if not setenvironmentvariablea(pchar(ansistring(aname)),nil) then begin
   result:= syelasterror;
  end;
 end
 else begin
  if not setenvironmentvariablew(pmsechar(aname),nil) then begin
   result:= syelasterror;
  end;
 end;
end;

function winfilepath(dirname,filename: msestring): msestring;
begin
 replacechar1(dirname,msechar('/'),msechar('\'));
 replacechar1(filename,msechar('/'),msechar('\'));
 if (length(dirname) >= 3) and (dirname[1] = '\') and (dirname[3] = ':') then begin
  dirname[1]:= dirname[2]; // '/c:' -> 'c:\'
  dirname[2]:= ':';
  dirname[3]:= '\';
  if (length(dirname) > 3) and (dirname[4] = '\')  then begin
   move(dirname[5],dirname[4],(length(dirname) - 4)*sizeof(msechar));
   setlength(dirname,length(dirname) - 1);
  end;
 end;
 if filename <> '' then begin
  if dirname = '' then begin
   result:= '.\'+filename;
  end
  else begin
   if dirname[length(dirname)] <> '\' then begin
    result:= dirname + '\' + filename;
   end
   else begin
    result:= dirname + filename;
   end;
  end;
 end
 else begin
  result:= dirname;
 end;
end;

function sys_filesystemiscaseinsensitive: boolean;
begin
 result:= true;
end;

function sys_tosysfilepath(var path: msestring): syserrorty;
begin
 path:= winfilepath(path,'');
 result:= sye_ok;
end;

function sys_read(fd:longint; buf:pointer; nbytes: dword): integer;
begin
 result:= -1; //compilerwarning;
 if not windows.readfile(fd,buf^,nbytes,dword(result),nil) then begin
  result:= -1;
 end;
 {
 if nbytes > 0 then begin
  repeat
   if not windows.readfile(fd,buf^,nbytes,dword(result),nil) then begin
    result:= -1;
   end;
  until result <> 0;
 end
 else begin
  result:= 0;
 end;
 }
end;

function sys_write(fd:longint; buf:pointer; nbytes: dword): integer;
begin
 result:= -1; //compilerwarning;
 if nbytes > 0 then begin
  repeat
   if not windows.WriteFile(fd,buf^,nbytes,dword(result),nil) then begin
    result:= -1;
   end;
  until result <> 0;
 end
 else begin
  result:= 0;
 end;
end;

function sys_errorout(const atext: string): syserrorty;
var
 ca1: cardinal;
begin
 if length(atext) > 0 then begin
  if isconsole then begin
   if windows.writefile(getstdhandle(std_input_handle),pchar(atext)^,
      length(atext),ca1,nil) then begin
    result:= sye_ok;
   end
   else begin
    result:= syelasterror;
   end;
  end
  else begin
   result:= sye_noconsole;
  end;
 end
 else begin
  result:= sye_ok;
 end;
end;

function sys_openfile(const path: msestring; const openmode: fileopenmodety;
          const accessmode: fileaccessmodesty;
          const rights: filerightsty; out handle: integer): syserrorty;
const
 openmodes: array[fileopenmodety] of cardinal =
//    fm_none,fm_read,     fm_write,     fm_readwrite,
     (0,      generic_read,generic_write,generic_read or generic_write,
//    fm_create,                    fm_append
      generic_read or generic_write,generic_read or generic_write);
var
 ca1: cardinal;
 str1: string;
 mstr2: msestring;

begin
 if not (fa_denyread in accessmode) then begin
  ca1:= file_share_read;
 end
 else begin
  ca1:= 0;
 end;
 if not (fa_denywrite in accessmode) then begin
  ca1:= ca1 or file_share_write;
 end;

 mstr2:= winfilepath(path,'');
 if iswin95 then begin
  str1:= ansistring(mstr2);
  if openmode = fm_Create then begin
   handle:= CreateFilea(PChar(str1),openmodes[openmode], //todo: rights -> securityattributes
      ca1, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
  end
  else begin
   handle:= CreateFilea(PChar(str1),openmodes[openmode],
      ca1, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  end;
 end
 else begin
  if openmode = fm_Create then begin
   handle:= CreateFilew(PmseChar(mstr2),openmodes[openmode], //todo: rights -> securityattributes
      ca1, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
  end
  else begin
   handle:= CreateFilew(PmseChar(mstr2),openmodes[openmode],
      ca1, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  end;
 end;
 if handle = invalidfilehandle then begin
  result:= syelasterror;
 end
 else begin
  result:= sye_ok;
 end;
end;

function sys_closefile(const handle: integer): syserrorty;
begin
 if (handle = invalidfilehandle) or closehandle(handle) then begin
  result:= sye_ok;
 end
 else begin
  result:= syelasterror;
 end;
end;

function sys_flushfile(const handle: integer): syserrorty;
begin
 if flushfilebuffers(handle) then begin
  result:= sye_ok;
 end
 else begin
  result:= syelasterror;
 end;
end;

function sys_dup(const source: integer; out dest: integer): syserrorty;
begin
 result:= sye_notimplemented;
end;

const
 invalid_set_file_pointer = dword(-1);

function sys_truncatefile(const handle: integer; const size: int64): syserrorty;
var
 res: dword;
 lo1: clong;
begin
 result:= sye_ok;
 lo1:= size shr 32;
 res:= setfilepointer(handle,size,@lo1,file_begin);
 if (res = invalid_set_file_pointer) and (getlasterror <> no_error) then begin
  result:= syelasterror;
 end;
end;

function sys_poll(const handle: integer; const kind: pollkindsty;
                            const timeoutms: longword): syserrorty;
                             //0 -> no timeout
                             //for blocking mode
begin
 result:= sye_notimplemented;
end;

function sys_copyfile(const oldfile,newfile: msestring): syserrorty;
var
 str1,str2: string;
begin
 if iswin95 then begin
  str1:= ansistring(winfilepath(oldfile,''));
  str2:= ansistring(winfilepath(newfile,''));
  if windows.copyfilea(pchar(str1),pchar(str2),false) then begin
   result:= sye_ok;
  end
  else begin
   result:= syelasterror;
  end;
 end
 else begin
  if windows.copyfilew(pmsechar(winfilepath(oldfile,'')),
                         pmsechar(winfilepath(newfile,'')),false) then begin
   result:= sye_ok;
  end
  else begin
   result:= syelasterror;
  end;
 end;
end;

function sys_renamefile(const oldname,newname: filenamety): syserrorty;
var
 str1,str2: string;
begin
 if iswin95 then begin
  str1:= ansistring(winfilepath(oldname,''));
  str2:= ansistring(winfilepath(newname,''));
  if windows.copyfilea(pchar(str1),pchar(str2),false) then begin
   if windows.deletefilea(pchar(str1)) then begin
    result:= sye_ok;
   end
   else begin
    result:= syelasterror;
   end;
  end
  else begin
   result:= syelasterror;
  end;
 end
 else begin
  if windows.movefileexw(pmsechar(winfilepath(oldname,'')),
        pmsechar(winfilepath(newname,'')),movefile_replace_existing) then begin
   result:= sye_ok;
  end
  else begin
   result:= syelasterror;
  end;
 end;
end;

function sys_deletefile(const filename: filenamety): syserrorty;
var
 str1: string;
begin
 if iswin95 then begin
  str1:= ansistring(winfilepath(filename,''));
  if windows.deletefilea(pchar(str1)) then begin
   result:= sye_ok;
  end
  else begin
   result:= syelasterror;
  end;
 end
 else begin
  if windows.deletefilew(pmsechar(winfilepath(filename,''))) then begin
   result:= sye_ok;
  end
  else begin
   result:= syelasterror;
  end;
 end;
end;

function sys_deletedir(const filename: filenamety): syserrorty;
var
 str1: string;
begin
 if iswin95 then begin
  str1:= ansistring(winfilepath(filename,''));
  if windows.removedirectorya(pchar(str1)) then begin
   result:= sye_ok;
  end
  else begin
   result:= syelasterror;
  end;
 end
 else begin
  if windows.removedirectoryw(pmsechar(winfilepath(filename,''))) then begin
   result:= sye_ok;
  end
  else begin
   result:= syelasterror;
  end;
 end;
end;


function sys_createdir(const path: msestring;
                 const rights: filerightsty): syserrorty;
var
 str1: string;
 str2: msestring;
 bo1: boolean;
begin
 if iswin95 then begin
  str1:= ansistring(winfilepath(path,''));
  bo1:= windows.createdirectorya(pchar(str1),nil);
                           //todo: rights -> securityattributes
 end
 else begin
  str2:= winfilepath(path,'');
  bo1:= windows.createdirectoryw(pmsechar(str2),nil);
                           //todo: rights -> securityattributes
 end;
 if bo1 then begin
  result:= sye_ok;
 end
 else begin
  result:= syelasterror;
 end;
end;

function sys_gettimeus: longword;
begin
 result:= systimerus;
// result:= gettickcount * 1000;
end;
{
function sys_getlastsyserror: integer;
begin
 result:= getlasterror;
end;
}
{$ifdef FPC}

function threadexec(infopo : pointer) : ptrint;
begin
//result:= 0;
//exit;
 threadinfoty(infopo^).id:= threadty(getcurrentthreadid);
 result:= threadinfoty(infopo^).threadproc();
 endthread();
end;

{$else}

function threadexec(infopo: pointer): integer; stdcall;
begin
 threadinfoty(infopo^).id:= threadty(getcurrentthreadid);
 result:= threadinfoty(infopo^).threadproc();
end;

{$endif}

function sys_threadcreate(var info: threadinfoty): syserrorty;
begin
{$ifdef FPC}
 with info,win32threadinfoty(platformdata) do begin
  handle:= beginthread(@threadexec,@info,id,stacksize);
  
  if handle = 0 then begin
   result:= sye_thread;
  end
  else begin
   result:= sye_ok;
  end;
 end;
{$else}
 ismultithread:= true;
 with info,win32threadinfoty(platformdata) do begin
  handle:= windows.CreateThread(nil,info.stacksize,@threadexec,@info,0,id);
  if handle = 0 then begin
   result:= sye_thread;
   id:= 0;
  end
  else begin
   result:= sye_ok;
  end;
 end;
{$endif}
end;

function sys_threadwaitfor(var info: threadinfoty): syserrorty;
begin
 with info,win32threadinfoty(platformdata) do begin
  if waitforsingleobject(handle,infinite) = wait_object_0 then begin
   result:= sye_ok;
  end
  else begin
   result:= sye_thread;
  end;
 end;
end;

function sys_getcurrentthread: threadty;
begin
 result:= threadty(getcurrentthreadid);
end;

function sys_issamethread(const a,b: threadty): boolean;
begin
 result:= a = b;
end;

function sys_threaddestroy(var info: threadinfoty): syserrorty;
var
 ca1: cardinal;
begin
 result:= sye_ok;
 with win32threadinfoty(info.platformdata) do begin
  if getexitcodethread(handle,ca1) then begin
   if ca1 = still_active then begin
    terminatethread(handle,exitcode);
   end;
  end;
  closehandle(handle);
 end;
end;

function sys_threadschedyield: syserrorty;
begin
 result:= sye_ok;
 windows.sleep(0);
end;

function filetimetotime(const wtime: tfiletime): tdatetime;
begin
 with wtime do begin
  if (dwLowDateTime = 0) and (dwhighdatetime = 0) then begin
   result:= 0;
  end
  else begin
   result:= (dwhighdatetime*twoexp32 + dwLowDateTime) /
                   (24.0*60.0*60.0*1000000.0*10.0) + filetimeoffset;
  end;
 end;
end;

function sys_getutctime: tdatetime;
var
 ft1: tfiletime;
begin
 getsystemtimeasfiletime(ft1);
 result:= filetimetotime(ft1);
end;

var
 lastlocaltime: integer;
 gmtoff: real;

function sys_localtimeoffset: tdatetime;
var
 tinfo: time_zone_information;
 int1: integer;
begin
 with tinfo do begin
  {$ifdef FPC}
  case gettimezoneinformation(@tinfo) of
  {$else}
  case gettimezoneinformation(tinfo) of
  {$endif}
   time_zone_id_unknown: int1:= bias;
   time_zone_id_standard: int1:= bias + standardbias;
   time_zone_id_daylight: int1:= bias + daylightbias;
   else int1:= 0;
  end;
 end;
 result:= -int1 / (24*60.0);
end;

function sys_getlocaltime: tdatetime;
var
 ft1: tfiletime;
 lint1: int64;
 lwo1: longword;
begin
 getsystemtimeasfiletime(ft1);
 lint1:= (int64(ft1.dwhighdatetime) shl 32) + ft1.dwlowdatetime;
 lwo1:= lint1 div 10000000; //seconds
 if lwo1 <> longword(lastlocaltime) then begin
  lastlocaltime:= lwo1;
  gmtoff:= sys_localtimeoffset;
 end;
 {$ifdef FPC}
 result:= real(lint1)/(24.0*60.0*60.0*1000000.0*10.0) + filetimeoffset + gmtoff;
 {$else}
 result:= lint1/(24.0*60.0*60.0*1000000.0*10.0) + filetimeoffset + gmtoff;
 {$endif}
end;
{
function sys_getlocaltime: tdatetime;
var
 ti1: tsystemtime;
begin
 getlocaltime(ti1);
 result:= systemtimetodatetime(ti1);
end;
}
(*
function sys_localtimeoffset: tdatetime;
var
 ti1,ti2: tfiletime;
begin
 ti1.dwhighdatetime:= $40000000;
 ti1.dwlowdatetime:= 0;
 {$ifdef FPC}
 filetimetolocalfiletime(@ti1,@ti2);
 {$else}
 filetimetolocalfiletime(ti1,ti2);
 {$endif}
 ti2.dwhighdatetime:= ti2.dwhighdatetime - $40000000;
 result:= int64(ti2) / (24*60*60*1e7); //100ns
end;
*)
{
function sys_localtimeoffset: tdatetime;
var
 info: _time_zone_information;
begin
 if gettimezoneinformation(info) = $ffffffff then begin
  result:= 0;
 end
 else begin
  result:= - info.Bias / (24.0*60.0);    //does not check daylightsaving
 end;
end;
}
function sys_getlangname: string;
type
 langty =
 (L_AFRIKAANS,L_ALBANIAN,L_ARABIC,L_ARMENIAN,L_ASSAMESE,
  L_AZERI,L_BASQUE,L_BELARUSIAN,L_BENGALI,L_BULGARIAN,
  L_CATALAN,L_CHINESE,L_CROATIAN,L_CZECH,L_DANISH,
  L_DIVEHI,L_DUTCH,L_ENGLISH,L_ESTONIAN,L_FAEROESE,
  L_FARSI,L_FINNISH,L_FRENCH,L_GALICIAN,L_GEORGIAN,
  L_GERMAN,L_GREEK,L_GUJARATI,L_HEBREW,L_HINDI,
  L_HUNGARIAN,L_ICELANDIC,L_INDONESIAN,L_ITALIAN,
  L_JAPANESE,L_KANNADA,L_KASHMIRI,L_KAZAK,L_KONKANI,
  L_KOREAN,L_KYRGYZ,L_LATVIAN,L_LITHUANIAN,L_MACEDONIAN,
  L_MALAY,L_MALAYALAM,L_MANIPURI,L_MARATHI,L_MONGOLIAN,
  L_NEPALI,L_NORWEGIAN,L_ORIYA,L_POLISH,L_PORTUGUESE,
  L_PUNJABI,L_ROMANIAN,L_RUSSIAN,L_SANSKRIT,L_SERBIAN,
  L_SINDHI,L_SLOVAK,L_SLOVENIAN,L_SPANISH,L_SWAHILI,
  L_SWEDISH,L_SYRIAC,L_TAMIL,L_TATAR,L_TELUGU,L_THAI,
  L_TURKISH,L_UKRAINIAN,L_URDU,L_UZBEK,L_VIETNAMESE);

 langinfoty = record
  lang: word; name: string;
 end;
const
{$ifndef FPC}
     LANG_AFRIKAANS  = $36;
     LANG_ALBANIAN   = $1c;
     LANG_ARABIC     = $01;
     LANG_ARMENIAN   = $2b;
     LANG_ASSAMESE   = $4d;
     LANG_AZERI      = $2c;
     LANG_BASQUE     = $2d;
     LANG_BELARUSIAN = $23;
     LANG_BENGALI    = $45;
     LANG_BULGARIAN  = $02;
     LANG_CATALAN    = $03;
     LANG_CHINESE    = $04;
     LANG_CROATIAN   = $1a;
     LANG_CZECH      = $05;
     LANG_DANISH     = $06;
     LANG_DIVEHI     = $65;
     LANG_DUTCH      = $13;
     LANG_ENGLISH    = $09;
     LANG_ESTONIAN   = $25;
     LANG_FAEROESE   = $38;
     LANG_FARSI      = $29;
     LANG_FINNISH    = $0b;
     LANG_FRENCH     = $0c;
     LANG_GALICIAN   = $56;
     LANG_GEORGIAN   = $37;
     LANG_GERMAN     = $07;
     LANG_GREEK      = $08;
     LANG_GUJARATI   = $47;
     LANG_HEBREW     = $0d;
     LANG_HINDI      = $39;
     LANG_HUNGARIAN  = $0e;
     LANG_ICELANDIC  = $0f;
     LANG_INDONESIAN = $21;
     LANG_ITALIAN    = $10;
     LANG_JAPANESE   = $11;
     LANG_KANNADA    = $4b;
     LANG_KASHMIRI   = $60;
     LANG_KAZAK      = $3f;
     LANG_KONKANI    = $57;
     LANG_KOREAN     = $12;
     LANG_KYRGYZ     = $40;
     LANG_LATVIAN    = $26;
     LANG_LITHUANIAN = $27;
     LANG_MACEDONIAN = $2f;
     LANG_MALAY      = $3e;
     LANG_MALAYALAM  = $4c;
     LANG_MANIPURI   = $58;
     LANG_MARATHI    = $4e;
     LANG_MONGOLIAN  = $50;
     LANG_NEPALI     = $61;
     LANG_NORWEGIAN  = $14;
     LANG_ORIYA      = $48;
     LANG_POLISH     = $15;
     LANG_PORTUGUESE = $16;
     LANG_PUNJABI    = $46;
     LANG_ROMANIAN   = $18;
     LANG_RUSSIAN    = $19;
     LANG_SANSKRIT   = $4f;
     LANG_SERBIAN    = $1a;
     LANG_SINDHI     = $59;
     LANG_SLOVAK     = $1b;
     LANG_SLOVENIAN  = $24;
     LANG_SPANISH    = $0a;
     LANG_SWAHILI    = $41;
     LANG_SWEDISH    = $1d;
     LANG_SYRIAC     = $5a;
     LANG_TAMIL      = $49;
     LANG_TATAR      = $44;
     LANG_TELUGU     = $4a;
     LANG_THAI       = $1e;
     LANG_TURKISH    = $1f;
     LANG_UKRAINIAN  = $22;
     LANG_URDU       = $20;
     LANG_UZBEK      = $43;
     LANG_VIETNAMESE = $2a;

function PRIMARYLANGID(LangId: WORD): WORD;
begin
  PRIMARYLANGID := LangId and $3FF;
end;

const
{$endif}

 langs: array[langty] of langinfoty = (
     (lang: LANG_AFRIKAANS;  name: 'af'),
     (lang: LANG_ALBANIAN;   name: 'sq'),
     (lang: LANG_ARABIC;     name: 'ar'),
     (lang: LANG_ARMENIAN;   name: 'hy'),
     (lang: LANG_ASSAMESE;   name: 'as'),
     (lang: LANG_AZERI;      name: 'az'),
     (lang: LANG_BASQUE;     name: 'eu'),
     (lang: LANG_BELARUSIAN; name: 'be'),
     (lang: LANG_BENGALI;    name: 'bn'),
     (lang: LANG_BULGARIAN;  name: 'bg'),
     (lang: LANG_CATALAN;    name: 'ca'),
     (lang: LANG_CHINESE;    name: 'zh'),
     (lang: LANG_CROATIAN;   name: 'hr'),
     (lang: LANG_CZECH;      name: 'cs'),
     (lang: LANG_DANISH;     name: 'da'),
     (lang: LANG_DIVEHI;     name: 'dv'),
     (lang: LANG_DUTCH;      name: 'nl'),
     (lang: LANG_ENGLISH;    name: 'en'),
     (lang: LANG_ESTONIAN;   name: 'et'),
     (lang: LANG_FAEROESE;   name: 'fo'),
     (lang: LANG_FARSI;      name: 'fa'),
     (lang: LANG_FINNISH;    name: 'fi'),
     (lang: LANG_FRENCH;     name: 'fr'),
     (lang: LANG_GALICIAN;   name: 'gl'),
     (lang: LANG_GEORGIAN;   name: 'ka'),
     (lang: LANG_GERMAN;     name: 'de'),
     (lang: LANG_GREEK;      name: 'el'),
     (lang: LANG_GUJARATI;   name: 'gu'),
     (lang: LANG_HEBREW;     name: 'he'),
     (lang: LANG_HINDI;      name: 'hi'),
     (lang: LANG_HUNGARIAN;  name: 'hu'),
     (lang: LANG_ICELANDIC;  name: 'is'),
     (lang: LANG_INDONESIAN; name: 'id'),
     (lang: LANG_ITALIAN;    name: 'it'),
     (lang: LANG_JAPANESE;   name: 'ja'),
     (lang: LANG_KANNADA;    name: 'kn'),
     (lang: LANG_KASHMIRI;   name: '??'),
     (lang: LANG_KAZAK;      name: 'kk'),
     (lang: LANG_KONKANI;    name: 'kok'),
     (lang: LANG_KOREAN;     name: 'ko'),
     (lang: LANG_KYRGYZ;     name: 'ky'),
     (lang: LANG_LATVIAN;    name: 'lv'),
     (lang: LANG_LITHUANIAN; name: 'lt'),
     (lang: LANG_MACEDONIAN; name: 'mk'),
     (lang: LANG_MALAY;      name: 'ms'),
     (lang: LANG_MALAYALAM;  name: 'ml'),
     (lang: LANG_MANIPURI;   name: '??'),
     (lang: LANG_MARATHI;    name: 'mr'),
     (lang: LANG_MONGOLIAN;  name: 'mn'),
     (lang: LANG_NEPALI;     name: 'ne'),
     (lang: LANG_NORWEGIAN;  name: 'no'),
     (lang: LANG_ORIYA;      name: 'or'),
     (lang: LANG_POLISH;     name: 'pl'),
     (lang: LANG_PORTUGUESE; name: 'pt'),
     (lang: LANG_PUNJABI;    name: 'pa'),
     (lang: LANG_ROMANIAN;   name: 'ro'),
     (lang: LANG_RUSSIAN;    name: 'ru'),
     (lang: LANG_SANSKRIT;   name: 'sa'),
     (lang: LANG_SERBIAN;    name: 'sr'),
     (lang: LANG_SINDHI;     name: '??'),
     (lang: LANG_SLOVAK;     name: 'sk'),
     (lang: LANG_SLOVENIAN;  name: 'sl'),
     (lang: LANG_SPANISH;    name: 'es'),
     (lang: LANG_SWAHILI;    name: 'sw'),
     (lang: LANG_SWEDISH;    name: 'sv'),
     (lang: LANG_SYRIAC;     name: 'syr'),
     (lang: LANG_TAMIL;      name: 'ta'),
     (lang: LANG_TATAR;      name: 'tt'),
     (lang: LANG_TELUGU;     name: 'te'),
     (lang: LANG_THAI;       name: 'th'),
     (lang: LANG_TURKISH;    name: 'tr'),
     (lang: LANG_UKRAINIAN;  name: 'uk'),
     (lang: LANG_URDU;       name: 'ur'),
     (lang: LANG_UZBEK;      name: 'uz'),
     (lang: LANG_VIETNAMESE; name: 'vi'));
var
 id: word;
 l1: langty;
begin
 result:= '';
 id:= primarylangid(getuserdefaultlangid);
 for l1:= low(langty) to high(langty) do begin
  if langs[l1].lang = id then begin
   result:= langs[l1].name;
   break;
  end;
 end;
end;

procedure winfileinfotofileinfo(const winfo: winfileinfoty;
                     const wsize: winfilesizety; var info: fileinfoty);
begin
 with winfo,info,extinfo1 do begin
  if file_attribute_directory and dwfileattributes <> 0 then begin
   info.extinfo1.filetype:= ft_dir;
  end
  else begin
   info.extinfo1.filetype:= ft_reg;
  end;
  state:= state + [fis_typevalid,fis_extinfo1valid];
  if filetype = ft_dir then begin
   attributes:= [fa_dir];
  end
  else begin
   attributes:= [];
  end;
  if file_attribute_archive and dwfileattributes <> 0 then begin
   include(attributes,fa_archive);
  end;
  if file_attribute_compressed and dwfileattributes <> 0 then begin
   include(attributes,fa_compressed);
  end;
  if file_attribute_encrypted and dwfileattributes <> 0 then begin
   include(attributes,fa_encrypted);
  end;
  if file_attribute_hidden and dwfileattributes <> 0 then begin
   include(attributes,fa_hidden);
  end;
  if file_attribute_offline and dwfileattributes <> 0 then begin
   include(attributes,fa_offline);
  end;
  attributes:= attributes + [fa_rusr,fa_xusr,fa_rgrp,fa_xgrp,fa_roth,fa_xoth];
  if file_attribute_readonly and dwfileattributes = 0 then begin
   attributes:= attributes + [fa_wusr,fa_wgrp,fa_woth];
  end;
  if file_attribute_reparse_point and dwfileattributes <> 0 then begin
   include(attributes,fa_reparsepoint);
  end;
  if file_attribute_sparse_file and dwfileattributes <> 0 then begin
   include(attributes,fa_sparsefile);
  end;
  if file_attribute_system and dwfileattributes <> 0 then begin
   include(attributes,fa_system);
  end;
  if file_attribute_temporary and dwfileattributes <> 0 then begin
   include(attributes,fa_temporary);
  end;
  with int64recty(size) do begin
   lsw:= wsize.nfilesizelow;
   msw:= wsize.nfilesizehigh;
  end;
  modtime:= filetimetotime(ftlastwritetime);
  accesstime:= filetimetotime(ftlastaccesstime);
  ctime:= filetimetotime(ftcreationtime);
 end;
end;

function rembackslash(po: pchar): pchar;
begin
 result:= po;
 while result^ = '\' do begin
  inc(result);
 end;
end;

//todo: network errormessages
function networkerror(const aerror: longword): syserrorty;
var
 wo1,wo2: dword;
 buffer1,buffer2: array[0..1024] of msechar;
begin
 if aerror = error_extended_error then begin
  wo1:= wnetgetlasterrorw({$ifdef FPC}@{$endif}wo2,@buffer1,1024,@buffer2,1024);
  if wo1 = no_error then begin
   result:= syesetextendederror(pmsechar(@buffer2)+': '+
                                         pmsechar(@buffer1));
  end
  else begin
   result:= sye_network;
  end;
 end
 else begin
  result:= syeseterror(aerror);
 end;
end;

function findservers(const resource: pnetresource; var names: msestringarty): syserrorty;
var
 wo1: longword;
 handle: thandle;
 po1:  pnetresource;
 ca1,ca2: cardinal;
begin
 result:= sye_network;
 wo1:= wnetopenenum(resource_globalnet,resourcetype_disk,0,resource,handle);
 if wo1 <> no_error then begin
  result:= networkerror(wo1);
  exit;
 end;
 getmem(po1,sizeof(tnetresource));
 ca2:= sizeof(tnetresource);
 wo1:= 0; //compilerwarning
 repeat
  while true do begin
   ca1:= 1;
   wo1:= wnetenumresource(handle,ca1,po1,ca2);
   if wo1 = error_more_data then begin
    reallocmem(po1,ca2);
   end
   else begin
    break;
   end;
  end;
  if wo1 = no_error then begin
   if (po1^.dwtype = resourcetype_disk) and
        (po1^.dwdisplaytype = resourcedisplaytype_server) and
             (po1^.lpRemoteName <> nil) then begin
    setlength(names,high(names)+2);
    names[high(names)]:= rembackslash(po1^.lpRemoteName);
    result:= sye_ok;
   end
   else begin
    if po1^.dwUsage and resourceusage_container <> 0 then begin
     if findservers(po1,names) = sye_ok then begin
      result:= sye_ok;
     end;
    end
   end;
  end
  else begin
   result:= networkerror(wo1);
  end;
 until wo1 <> no_error;
 wnetcloseenum(handle);
 freemem(po1);
// result:= sye_ok;
end;

function findserver(const name: string; var resource: pnetresource): syserrorty;

var
 wo1: longword;
 handle: thandle;
 ca1,ca2: cardinal;
 po1: pnetresource;
begin
 result:= sye_network;
 wo1:= wnetopenenum(resource_globalnet,resourcetype_disk,0,resource,handle);
 resource:= nil;
 if wo1 <> no_error then begin
  result:= networkerror(wo1);
  exit;
 end;
 getmem(po1,sizeof(tnetresource));
 ca2:= sizeof(tnetresource);
 wo1:= 0; //compilerwarning
 repeat
  while true do begin
   ca1:= 1;
   wo1:= wnetenumresource(handle,ca1,po1,ca2);
   if wo1 = error_more_data then begin
    reallocmem(po1,ca2);
   end
   else begin
    break;
   end;
  end;
  if wo1 = no_error then begin
   if (po1^.dwtype = resourcetype_disk) and (po1^.lpremotename <> nil) and
         (strcomp(pchar(name),rembackslash(po1^.lpremotename)) = 0)  then begin
    resource:= po1;
    result:= sye_ok;
    break;
   end
   else begin
    if po1^.dwUsage and resourceusage_container <> 0 then begin
     resource:= po1;
     result:= findserver(name,resource);
    end
   end;
  end
  else begin
   result:= networkerror(wo1);
  end;
 until (wo1 <> no_error) or (result = sye_ok);
 wnetcloseenum(handle);
 if resource <> po1 then begin
  freemem(po1);
 end;
end;

function sys_opendirstream(var stream: dirstreamty): syserrorty;
var
 wo1: longword;
 int1: integer;
begin
 with stream,dirinfo,dirstreamwin32ty(platformdata) do begin
  checkdirstreamdata(stream);
  result:= sye_ok;
  if dirname <> '/' then begin
   if msestartsstr('//',dirname) then begin //UNC
    if length(dirname) = 2 then begin
     finddatapo:= nil;
     result:= findservers(nil,msestringarty(finddatapo));
     if finddatapo <> nil then begin
      result:= sye_ok;
     end;
     drivenum:= -3;     //network root
     handle:= 0;
     {
     wo1:= wnetopenenum(resource_globalnet,resourcetype_disk,0,nil,handle);
     if wo1 <> no_error then begin
      result:= sye_dirstream;
     end;
     }
     exit;
    end
    else begin
     if countchars(dirname,msechar('/')) = 2 then begin //list shares
      drivenum:= -2;
      finddatapo:= nil;
      result:= findserver(copy(ansiuppercase(ansistring(dirname)),3,bigint),
                              pnetresource(finddatapo));
      if finddatapo <> nil then begin
       result:= sye_ok;
      end;
      if result = sye_ok then begin
       wo1:= wnetopenenum(resource_globalnet,resourcetype_disk,0,
                    pnetresource(finddatapo),handle);
       if wo1 <> no_error then begin
        result:= networkerror(wo1);
       end;
       freemem(finddatapo);
      end;
      exit;
     end;
    end;
   end;
   drivenum:= -1;
   last:= true;
   new(finddatapo);
   if iswin95 then begin
    handle:= findfirstfilea(pchar(string(winfilepath(stream.dirinfo.dirname,'*'))),
    {$ifdef FPC}
     lpwin32_find_data(finddatapo));
    {$else}
     _win32_find_dataa(pointer(finddatapo)^));
    {$endif}
   end
   else begin
    handle:= findfirstfilew(pmsechar(winfilepath(stream.dirinfo.dirname,'*')),
   {$ifdef FPC}
    lpwin32_find_dataw(finddatapo));
   {$else}
    _win32_find_dataw(finddatapo^));
   {$endif}
   end;
   if handle = invalid_handle_value then begin
    int1:= getlasterror;
    if int1 <> error_file_not_found then begin
     dispose(finddatapo);
     setlasterror(int1);
     result:= syelasterror;
    end;
   end
   else begin
    last:= false;
   end;
  end;
 end;
end;

function sys_closedirstream(var stream: dirstreamty): syserrorty;
begin
 with dirstreamwin32ty(stream.platformdata) do begin
  case drivenum of
   -3: begin
    finalize(msestringarty(finddatapo));
   end;
   -2: begin
     wnetcloseenum(handle);
   end;
   -1: begin
    dispose(finddatapo);
    if handle <> invalid_handle_value then begin
     windows.findclose(handle);
    end;
   end;
  end;
 end;
 result:= sye_ok;
end;

function sys_readdirstream(var stream: dirstreamty; var info: fileinfoty): boolean;

 procedure checkinfo;
 begin
  result:= ((fa_all in stream.dirinfo.include) or
                    (info.extinfo1.attributes * stream.dirinfo.include <> [])) and
             (info.extinfo1.attributes * stream.dirinfo.exclude = []) and
             checkfilename(info.name,stream);
 end;

var
 ca1,ca2: cardinal;
 wo1: longword;
 po1:  pnetresource;
 po2: pchar;

begin
 with stream,dirinfo,dirstreamwin32ty(platformdata),finddatapo^,winfo do begin
  result:= false;
  if (include <> []) and not (fa_all in exclude) then begin
   case drivenum of
    -3: begin          //network root
     info.state:= [fis_typevalid,fis_extinfo1valid];
     info.extinfo1.attributes:= [fa_dir];
     info.extinfo1.filetype:= ft_dir;
     if integer(handle) <= high(msestringarty(finddatapo)) then begin
      repeat
       info.name:= msestringarty(finddatapo)[handle];
       checkinfo;
       inc(handle);
      until result or (integer(handle) > high(msestringarty(finddatapo)));
     end;
    end;
    -2: begin       //network share
     info.state:= [fis_typevalid,fis_extinfo1valid];
     info.extinfo1.attributes:= [fa_dir];
     info.extinfo1.filetype:= ft_dir;
     getmem(po1,sizeof(tnetresource));
     fillchar(po1^,sizeof(tnetresource),0);
     ca2:= sizeof(tnetresource);
     wo1:= 0; //compilerwarning
     repeat
      while true do begin
       ca1:= 1;
       wo1:= wnetenumresource(handle,ca1,po1,ca2);
       if wo1 = error_more_data then begin
        reallocmem(po1,ca2);
       end
       else begin
        break;
       end;
      end;
      if wo1 = no_error then begin
       po2:= strrscan(po1^.lpRemoteName,'\');
       if po2 <> nil then begin
        info.name:= msestring(
                    copy(po1^.lpRemoteName,po2-po1^.lpRemoteName+2,bigint));
        checkinfo;
       end
       else begin
        break;
       end;
      end
      else begin
       break;
      end;
     until result;
     freemem(po1);
    end;
    -1: begin          //local root dir
     if not last then begin
      repeat
       if iswin95 then begin
        info.name:= pwinfilenameaty(@cfilename)^;
       end
       else begin
        info.name:= cfilename;
       end;
{
       if file_attribute_directory and dwfileattributes <> 0 then begin
        info.extinfo1.filetype:= ft_dir;
       end
       else begin
        info.extinfo1.filetype:= ft_reg;
       end;
}
       winfileinfotofileinfo(winfo,wsize,info);
       if infolevel = fil_ext2 then begin
        //read security level
       end;
       checkinfo;
       if iswin95 then begin
        last:= not findnextfilea(handle,
        {$ifdef FPC}
        lpwin32_find_data(finddatapo));
        {$else}
        _win32_find_dataa(pointer(finddatapo)^));
        {$endif}
       end
       else begin
        last:= not findnextfilew(handle,
        {$ifdef FPC}
        lpwin32_find_dataw(finddatapo));
        {$else}
        _win32_find_dataw(finddatapo^));
        {$endif}
       end;
      until result or last;
     end;
    end
    else begin
     ca1:= getlogicaldrives;
     info.extinfo1.filetype:= ft_dir;
     info.state:= info.state + [fis_typevalid,fis_extinfo1valid];
     info.extinfo1.attributes:= [fa_dir];
     while (drivenum < 32) and not result do begin
      if ca1 and bits[drivenum] <> 0 then begin
       setlength(info.name,2);
       info.name[1]:= msechar(ord('A') + drivenum);
       info.name[2]:= ':';
       checkinfo;
      end;
      inc(drivenum);
     end;
    end;
   end;
  end;
 end;
end;

function sys_getfileinfo(const path: filenamety; var info: fileinfoty): boolean;
var
 handle: integer;
 wstr1: filenamety;
 finddata: win32_find_dataw;
 lwo1: longword;
begin
 clearfileinfo(info);
 wstr1:= tosysfilepath(path);
 if iswin95 then begin
  handle:= findfirstfilea(pchar(string(wstr1)),
            {$ifdef FPC}@win32_find_dataa
            {$else}twin32finddataa{$endif}(pointer(@finddata)^));
 end
 else begin
  handle:= findfirstfilew(pmsechar(wstr1),
             {$ifdef FPC}@finddata
             {$else}twin32finddataw(finddata){$endif});
 end;
 if thandle(handle) <> invalid_handle_value then begin
  with win32_find_dataw(finddata) do begin
{
   if winfo.dwfileattributes and file_attribute_directory <> 0 then begin
    info.extinfo1.filetype:= ft_dir;
   end
   else begin
    info.extinfo1.filetype:= ft_reg;
   end;
}
   winfileinfotofileinfo(winfo,wsize,info);
   if iswin95 then begin
    info.name:= pwinfilenameaty(@cfilename)^;
   end
   else begin
    info.name:= cfilename;
   end;
  end;
  windows.findclose(handle);
  result:= true;
 end
 else begin   //possibly a drive name
  if iswin95 then begin
   lwo1:= getfileattributes(pchar(string(wstr1)));
  end
  else begin
   lwo1:= getfileattributesw(pmsechar(wstr1));
  end;
  if lwo1 = $ffffffff then begin
   result:= false;
  end
  else begin
   if lwo1 and file_attribute_directory <> 0 then begin
    info.extinfo1.filetype:= ft_dir;
   end
   else begin
    info.extinfo1.filetype:= ft_reg;
   end;
   result:= true;
  end;
 end;
end;

function sys_getfdinfo(const fd: longint; var info: fileinfoty): boolean;
var
 info1: by_handle_file_information;
begin
 clearfileinfo(info);
 result:= getfileinformationbyhandle(fd,info1);
 if result then begin
  winfileinfotofileinfo(info1.winfo,info1.wsize,info);
 end;
end;

function sys_setfdrights(const fd: longint;
                         const rights: filerightsty;
                         const filename: filenamety = ''): syserrorty;
var                           //todo: use security attributes
 info1: by_handle_file_information;
 fname: filenamety;
 bo1: boolean;
 {
 fmap: thandle;
 pmem: pointer;
 abuf: array[0..max_path] of char;
 wbuf: array[0..max_path] of widechar;
 dwo1: dword;
 }
begin
 if getfileinformationbyhandle(fd,info1) then begin
  if s_iwusr in rights then begin
   info1.winfo.dwfileattributes:= info1.winfo.dwfileattributes and
                                                not file_attribute_readonly;
  end
  else begin
   info1.winfo.dwfileattributes:= info1.winfo.dwfileattributes or
                                                    file_attribute_readonly;
  end;
  {
  fmap:= createfilemapping(fd,nil,page_readonly,0,1,nil);
  if fmap = 0 then begin
   result:= syelasterror();
  end
  else begin
   pmem:= mapviewoffile(fmap,file_map_read,0,0,1);
   if pmem = nil then begin
    result:= syelasterror();
   end
   else begin
    if iswin95 then begin
     dwo1:= getmappedfilenamea(getcurrentprocess(),pmem,@abuf,max_path);
    end
    else begin
     dwo1:= getmappedfilenamew(getcurrentprocess(),pmem,@wbuf,max_path);
    end;
    if dwo1 = 0 then begin
     result:= syelasterror();
    end
    else begin

    end;
    unmapviewoffile(pmem);
   end;
   closehandle(fmap);
  end;
  //how to set file attributes from handle on pre XP?
  }
  fname:= tosysfilepath(filename);
  if iswin95 then begin
   bo1:= setfileattributesa(pchar(string(fname)),info1.winfo.dwfileattributes);
  end
  else begin
   bo1:= setfileattributesw(pwidechar(fname),info1.winfo.dwfileattributes);
  end;
  if not bo1 then begin
   result:= syelasterror();
  end
  else begin
   result:= sye_ok;
  end;
 end
 else begin
  result:= syelasterror();
 end;
end;

function sys_access(const path: filenamety;
                                const accessmodes: accessmodesty): syserrorty;
begin
 result:= sye_notimplemented;
end;

function sys_setfilerights(const path: filenamety;
                                       const rights: filerightsty): syserrorty;
var
 fname: filenamety;
 dwo1: dword;
 bo1: boolean;
begin
 fname:= tosysfilepath(path);
 if iswin95 then begin
  dwo1:= getfileattributesa(pchar(string(fname)));
 end
 else begin
  dwo1:= getfileattributesw(pwidechar(fname));
 end;
 if dwo1 = 0 then begin
  result:= syelasterror();
 end
 else begin
  if s_iwusr in rights then begin
   dwo1:= dwo1 and not file_attribute_readonly;
  end
  else begin
   dwo1:= dwo1 or file_attribute_readonly;
  end;
  if iswin95 then begin
   bo1:= setfileattributesa(pchar(string(fname)),dwo1);
  end
  else begin
   bo1:= setfileattributesw(pwidechar(fname),dwo1);
  end;
  if not bo1 then begin
   result:= syelasterror();
  end
  else begin
   result:= sye_ok;
  end;
 end;
end;
{
function sys_setfdrights(const rights: filerightsty;
                                       const fd: longint): syserrorty;
begin
end;
}
function sys_getcurrentdir: msestring;
var
 ca1: cardinal;
 str1: string;
begin
 if iswin95 then begin
  repeat
   ca1:= getcurrentdirectorya(0,nil);
   setlength(str1,ca1-1);
  until (ca1 < 2) or (getcurrentdirectorya(ca1,@str1[1]) = ca1-1);
  result:= msestring(str1);
 end
 else begin
  repeat
   ca1:= getcurrentdirectoryw(0,nil);
   setlength(result,ca1-1);
  until (ca1 < 2) or (getcurrentdirectoryw(ca1,@result[1]) = ca1-1);
 end;
 tomsefilepath1(result);
end;

function sys_getapphomedir: filenamety;
begin
 result:= apphomedir;
end;

function sys_getuserhomedir: filenamety;
begin
 result:= userhomedir;
end;

function sys_getusername: msestring;
var
 s1: ansistring;
 ms1: msestring;
 i1: DWORD;
begin
 result:= '';
 i1:= 256;
 if iswin95 then begin
  setlength(s1,i1);
  if getusernamea(pointer(s1),@i1) then begin
   setlength(s1,i1-1);
   result:= msestring(s1);
  end;
 end
 else begin
  setlength(ms1,i1);
  if getusernamew(pointer(ms1),@i1) then begin
   setlength(ms1,i1-1);
   result:= ms1;
  end;
 end;
end;


function sys_gettempdir: filenamety;
var
 int1: integer;
 fna1: filenamety;
// po1: pfilenamechar;
begin
 setlength(fna1,max_path+10);
 fna1[1]:= #0;
 int1:= gettemppathw(length(fna1),pointer(fna1));
 if int1 > length(fna1) then begin
  setlength(result,int1);
  int1:= gettemppathw(length(fna1),pointer(fna1));
 end;
 if assigned(getlongpathnamew) then begin
  setlength(result,max_path+10);
  int1:= getlongpathnamew(pointer(fna1),pointer(result),length(result));
  if int1 > length(result) then begin
   setlength(result,int1);
   int1:= getlongpathnamew(pointer(fna1),pointer(result),length(result));
  end;
  setlength(result,int1);
 end
 else begin
  setlength(fna1,int1);
  result:= fna1;
 end;
 tomsefilepath1(result);
end;

function sys_setcurrentdir(const dirname: filenamety): syserrorty;
var
 str1: string;
begin
 if iswin95 then begin
  str1:= ansistring(tosysfilepath(dirname));
  if not setcurrentdirectorya(pchar(str1)) then begin
   result:= syelasterror;
  end
  else begin
   result:= sye_ok;
  end;
 end
 else begin
  if not setcurrentdirectoryw(pmsechar(tosysfilepath(dirname))) then begin
   result:= syelasterror;
  end
  else begin
   result:= sye_ok;
  end;
 end;
end;

const
  CSIDL_PROGRAMS                = $0002; { %SYSTEMDRIVE%\Program Files                                      }
  CSIDL_PERSONAL                = $0005; { %USERPROFILE%\My Documents                                       }
  CSIDL_FAVORITES               = $0006; { %USERPROFILE%\Favorites                                          }
  CSIDL_STARTUP                 = $0007; { %USERPROFILE%\Start menu\Programs\Startup                        }
  CSIDL_RECENT                  = $0008; { %USERPROFILE%\Recent                                             }
  CSIDL_SENDTO                  = $0009; { %USERPROFILE%\Sendto                                             }
  CSIDL_STARTMENU               = $000B; { %USERPROFILE%\Start menu                                         }
  CSIDL_MYMUSIC                 = $000D; { %USERPROFILE%\Documents\My Music                                 }
  CSIDL_MYVIDEO                 = $000E; { %USERPROFILE%\Documents\My Videos                                }
  CSIDL_DESKTOPDIRECTORY        = $0010; { %USERPROFILE%\Desktop                                            }
  CSIDL_NETHOOD                 = $0013; { %USERPROFILE%\NetHood                                            }
  CSIDL_TEMPLATES               = $0015; { %USERPROFILE%\Templates                                          }
  CSIDL_COMMON_STARTMENU        = $0016; { %PROFILEPATH%\All users\Start menu                               }
  CSIDL_COMMON_PROGRAMS         = $0017; { %PROFILEPATH%\All users\Start menu\Programs                      }
  CSIDL_COMMON_STARTUP          = $0018; { %PROFILEPATH%\All users\Start menu\Programs\Startup              }
  CSIDL_COMMON_DESKTOPDIRECTORY = $0019; { %PROFILEPATH%\All users\Desktop                                  }
  CSIDL_APPDATA                 = $001A; { %USERPROFILE%\Application Data (roaming)                         }
  CSIDL_PRINTHOOD               = $001B; { %USERPROFILE%\Printhood                                          }
  CSIDL_LOCAL_APPDATA           = $001C; { %USERPROFILE%\Local Settings\Application Data (non roaming)      }
  CSIDL_COMMON_FAVORITES        = $001F; { %PROFILEPATH%\All users\Favorites                                }
  CSIDL_INTERNET_CACHE          = $0020; { %USERPROFILE%\Local Settings\Temporary Internet Files            }
  CSIDL_COOKIES                 = $0021; { %USERPROFILE%\Cookies                                            }
  CSIDL_HISTORY                 = $0022; { %USERPROFILE%\Local settings\History                             }
  CSIDL_COMMON_APPDATA          = $0023; { %PROFILESPATH%\All Users\Application Data                        }
  CSIDL_WINDOWS                 = $0024; { %SYSTEMROOT%                                                     }
  CSIDL_SYSTEM                  = $0025; { %SYSTEMROOT%\SYSTEM32 (may be system on 95/98/ME)                }
  CSIDL_PROGRAM_FILES           = $0026; { %SYSTEMDRIVE%\Program Files                                      }
  CSIDL_MYPICTURES              = $0027; { %USERPROFILE%\My Documents\My Pictures                           }
  CSIDL_PROFILE                 = $0028; { %USERPROFILE%                                                    }
  CSIDL_PROGRAM_FILES_COMMON    = $002B; { %SYSTEMDRIVE%\Program Files\Common                               }
  CSIDL_COMMON_TEMPLATES        = $002D; { %PROFILEPATH%\All Users\Templates                                }
  CSIDL_COMMON_DOCUMENTS        = $002E; { %PROFILEPATH%\All Users\Documents                                }
  CSIDL_COMMON_ADMINTOOLS       = $002F; { %PROFILEPATH%\All Users\Start Menu\Programs\Administrative Tools }
  CSIDL_ADMINTOOLS              = $0030; { %USERPROFILE%\Start Menu\Programs\Administrative Tools           }
  CSIDL_COMMON_MUSIC            = $0035; { %PROFILEPATH%\All Users\Documents\my music                       }
  CSIDL_COMMON_PICTURES         = $0036; { %PROFILEPATH%\All Users\Documents\my pictures                    }
  CSIDL_COMMON_VIDEO            = $0037; { %PROFILEPATH%\All Users\Documents\my videos                      }
  CSIDL_CDBURN_AREA             = $003B; { %USERPROFILE%\Local Settings\Application Data\Microsoft\CD Burning }
  CSIDL_PROFILES                = $003E; { %PROFILEPATH%                                                    }

  CSIDL_FLAG_CREATE             = $8000; { (force creation of requested folder if it doesn't exist yet)     }

type
 SHGetFolderPathW = function (hwndowner: HWND; nFolder: integer; hToken: thandle;
                                 dwFlags: DWORD; pszPath: LPTSTR): HRESULT; stdcall;
procedure doinit;
var
 libhandle: thandle;
 po1: SHGetFolderPathW;
 buffer: array[0..max_path] of widechar;
// int1: integer;

begin
 gmtoff:= sys_localtimeoffset;
 po1:= nil; //compiler warning
 libhandle:= loadlibrary('shell32.dll');
 if libhandle <> 0 then begin
  {$ifdef FPC}pointer(po1){$else}po1{$endif}:=
                             getprocaddress(libhandle,'SHGetFolderPathW');
  if not assigned(po1) then begin
   freelibrary(libhandle);
   libhandle:= loadlibrary('shfolder.dll');
   if libhandle <> 0 then begin
      {$ifdef FPC}pointer(po1){$else}po1{$endif}:=
                             getprocaddress(libhandle,'SHGetFolderPathW');
   end;
  end;
 end;
 if libhandle <> 0 then begin
  if assigned(po1) then begin
   if po1(0,CSIDL_APPDATA or CSIDL_FLAG_CREATE,0,0,@buffer) = 0 then begin
    apphomedir:= filepath(buffer,fk_file);
   end;
   if po1(0,CSIDL_PROFILE or CSIDL_FLAG_CREATE,0,0,@buffer) = 0 then begin
    userhomedir:= filepath(buffer,fk_file);
   end;
  end;
  freelibrary(libhandle);
 end;
 checkprocaddresses(['kernel32.dll'],
      ['GetLongPathNameW'],
      [{$ifndef FPC}@{$endif}@GetLongPathNameW]);
 checkprocaddresses(['user32.dll'],
      ['AllowSetForegroundWindow'],
      [{$ifndef FPC}@{$endif}@AllowSetForegroundWindow]);
 checkprocaddresses(['ntdll.dll'],['ZwQueryInformationProcess'],
      [@ZwQueryInformationProcess]);
 checkprocaddresses(['ntdll.dll'],['NtQueryInformationProcess'],
      [@NtQueryInformationProcess]);
 checkprocaddresses(['kernel32.dll'],['GetProcessId'],
      [@GetProcessId]);
end;
{
procedure initformatsettings;
begin
 thousandseparatormse:= thousandseparator;
 decimalseparatormse:= decimalseparator;
 dateseparatormse:= dateseparator;
 timeseparatormse:= timeseparator;
end;
}
initialization
{$ifdef FPC}
// winwidestringalloc:= false;
 {$endif}
// initformatsettings;
 doinit;
//iswin95:= true;
//iswin98:= true;
end.
