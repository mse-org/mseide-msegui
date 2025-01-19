{ MSEgui Copyright (c) 1999-2015 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}

function sys_gettimeus: longword;
               //systemtime in microseconds, origin undefined
function sys_getpid: procidty;
function sys_getprocesses: procitemarty;
function sys_terminateprocess(const proc: prochandlety): syserrorty;
function sys_killprocess(const proc: prochandlety): syserrorty;

function sys_threadcreate(var info: threadinfoty): syserrorty;
function sys_threadwaitfor(var info: threadinfoty): syserrorty;
function sys_threaddestroy(var info: threadinfoty): syserrorty;
function sys_threadschedyield: syserrorty;
function sys_getcurrentthread: threadty;
function sys_issamethread(const a,b: threadty): boolean;
function sys_getapplicationpath: filenamety;

{$if defined(usesdl) and defined(windows)}
function sys_getcommandlinearguments: stringarty;
{$else}
function sys_getcommandlinearguments: msestringarty;
{$endif}

{$if not defined(usesdl) and not defined(windows)}
procedure sys_getenvvars(out names: msestringarty; out values: msestringarty);
{$endif}


function sys_getenv(const aname: msestring; out avalue: msestring): boolean;
                          //true if found
function sys_setenv(const aname: msestring;
                                const avalue: msestring): syserrorty;
function sys_unsetenv(const aname: msestring): syserrorty;

function sys_filesystemiscaseinsensitive: boolean;
function sys_tosysfilepath(var path: filenamety): syserrorty;

  //all filenames below are in mseformat!
function sys_getcurrentdir: filenamety;
function sys_getapphomedir: filenamety;
function sys_getuserhomedir: filenamety;
function sys_getusername: msestring;
function sys_gettempdir: filenamety;
function sys_setcurrentdir(const dirname: filenamety): syserrorty;
function sys_copyfile(const oldfile,newfile: filenamety): syserrorty;
function sys_deletefile(const filename: filenamety): syserrorty;
function sys_deletedir(const filename: filenamety): syserrorty;
function sys_renamefile(const oldname,newname: filenamety): syserrorty;
function sys_createdir(const path: msestring;
                  const rights: filerightsty): syserrorty;

function sys_openfile(const path: filenamety; const openmode: fileopenmodety;
          const accessmode: fileaccessmodesty;
          const rights: filerightsty; out handle: longint): syserrorty;
function sys_closefile(const handle: integer): syserrorty;
function sys_flushfile(const handle: integer): syserrorty;
function sys_dup(const source: integer; out dest: integer): syserrorty;

function sys_access(const path: filenamety;
                                const accessmodes: accessmodesty): syserrorty;
function sys_setfilerights(const path: filenamety;
                              const rights: filerightsty): syserrorty;

function sys_truncatefile(const handle: integer; const size: int64): syserrorty;
 
function sys_getfdinfo(const fd: longint; var info: fileinfoty): boolean;    

function sys_setfdrights(const fd: longint;
                      const rights: filerightsty;
                      const filename: filenamety = ''): syserrorty;
                            //filename necessary on windows
                        
                         
function sys_read(fd: longint; buf: pointer; nbytes: longword): integer;
function sys_write(fd: longint; buf: pointer; nbytes: longword): integer;
function sys_errorout(const atext: string): syserrorty;
function sys_stdin: integer;
function sys_stdout: integer;
function sys_stderr: integer;

function sys_getfileinfo(const path: filenamety; var info: fileinfoty): boolean;
function sys_opendirstream(var stream: dirstreamty): syserrorty;
function sys_closedirstream(var stream: dirstreamty): syserrorty;
function sys_readdirstream(var stream: dirstreamty;
                                        var info: fileinfoty): boolean;
 //true if valid

procedure sys_usleep(const us: longword);
procedure sys_schedyield;

function sys_getutctime: tdatetime;
function sys_getlocaltime: tdatetime;
function sys_localtimeoffset: tdatetime;
function sys_getlangname: string;
function sys_getprintcommand: msestring;
(*
function sys_utctolocaltime(const value: tdatetime): tdatetime;
function sys_localtimetoutc(const value: tdatetime): tdatetime;
*)
