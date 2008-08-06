{ MSEgui Copyright (c) 1999-2008 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msesysintf; //i386-linux

{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}

interface
uses
 msesys,msesetlocale,{$ifdef FPC}cthreads,cwstring,{$endif}msetypes,libc,
 msestrings,msestream,msesysbindings;
var
 thread1: threadty;

{$ifdef msedebug}
var                         //!!!!todo: link with correct location
 _IO_stdin: P_IO_FILE; cvar;
 _IO_stdout: P_IO_FILE; cvar;
 _IO_stderr: P_IO_FILE; cvar;
 __malloc_initialized : longint;cvar;
 h_errno : longint;cvar;
{$endif}
{$ifdef mse_debug_mutex}
var
 mutexcount: integer;
 appmutexcount: integer;
{$endif}

{$include ../msesysintf.inc}

type

 linuxsemty = record
//  outoforder: boolean;
  destroyed: integer;
  sema: tsemaphore;
  platformdata: array[5..7] of cardinal;
 end;

TSigActionHandlerEx = procedure(Signal: Integer; SignalInfo: PSigInfo; P: Pointer); cdecl;

TSigActionEx = packed record
                sa_sigaction: TSigActionHandlerEx;
                sa_mask: __sigset_t;
                sa_flags: Integer;
                sa_restorer: TRestoreHandler;
               end;
function timestampms: cardinal;
function sigactionex(SigNum: Integer; var Action: TSigActionex; OldAction: PSigAction): Integer;
function m_sigprocmask(__how:longint; var SigSet : TSigSet;
            var oldset: Tsigset):longint;cdecl;external clib name 'sigprocmask';
function m_sigismember(var SigSet : TSigSet; SigNum : Longint):longint;cdecl;external clib name 'sigismember';


procedure setcloexec(const fd: integer);

implementation
uses
 sysutils,msesysutils,msefileutils{$ifdef FPC},dateutils{$else},DateUtils{$endif}
 {$ifdef mse_debug_mutex},mseapplication{$endif};
 
function sigactionex(SigNum: Integer; var Action: TSigActionex; OldAction: PSigAction): Integer;
begin
 action.sa_flags:= action.sa_flags or SA_SIGINFO;
 result:= sigaction(signum,@action,oldaction);
end;


type
   tstatbuf64 = packed record
        st_dev : __dev_t;
        __pad1 : dword;
        __st_ino : __ino_t;
        st_mode : __mode_t;
        st_nlink : __nlink_t;
        st_uid : __uid_t;
        st_gid : __gid_t;
        st_rdev : __dev_t;
        __pad2 : dword;
        st_size : __off64_t;
        st_blksize : __blksize_t;
        st_blocks : __blkcnt64_t;
        st_atime : __time_t;
        st_atime_usec : dword;
        st_mtime : __time_t;
        st_mtime_usec : dword;
        st_ctime : __time_t;
        st_ctime_usec : dword;
        st_ino : __ino64_t;
     end;
(*
  tstatbuf64 = packed record // Renamed due to conflict with stat64 function
    st_dev: __dev_t;                    { Device.  }
    __pad1: Word;
    __st_ino: __ino_t;                  { 32bit file serial number.  }
    st_mode: __mode_t;                  { File mode.  }
    st_nlink: __nlink_t;                { Link count.  }
    st_uid: __uid_t;                    { User ID of the file's owner.  }
    st_gid: __gid_t;                    { Group ID of the file's group.  }
    st_rdev: __dev_t;                   { Device number, if device.  }
    __pad2: Word;
    st_size: __off64_t;                 { Size of file, in bytes.  }
    st_blksize: __blksize_t;            { Optimal block size for I/O.  }
    st_blocks: __blkcnt64_t;            { Number 512-byte blocks allocated. }
    st_atime: __time_t;                 { Time of last access.  }
    st_atime_usec: LongWord;
    st_mtime: __time_t;                 { Time of last modification.  }
    st_mtime_usec: LongWord;
    st_ctime: __time_t;                 { Time of last status change.  }
    st_ctime_usec: LongWord;
    st_ino: __ino64_t;                  { File serial number.  }
  end;
*)

const
 stat_ver_mse = 3;

 path_max = 1024;
 filetypes: array[filetypety] of cardinal = (0,s_ifdir,s_ifblk,
                                s_ifchr,s_ifreg,s_iflnk,s_ifsock,s_ififo);
// timeoffset = 0.0;
 datetimeoffset = -25569;
 

type
 linuxmutexty = record
  mutex: pthread_mutex_t;
  platformdata: array[6..7] of cardinal;
 end;

 linuxcondty = record
  cond: tcondvar;
  mutex: pthread_mutex_t;
  platformdata: array[18..31] of cardinal;
 end;

 dirstreamlinuxty = record
  dir: pdirectorystream;
  needsstat: boolean;
  dirpath: pointer;
  platformdata: array[3..7] of cardinal;
 end;

function sys_getpid: procidty;
begin
 result:= libc.getpid;
end;

function sys_stdin: integer;
begin
 result:= stdin;
end;

function sys_stdout: integer;
begin
 result:= stdout;
end;

function sys_stderr: integer;
begin
 result:= stderr;
end;

function sys_getprintcommand: string;
begin
 result:= 'lp -';
end;

function sys_getprocesses: procitemarty;
var
 filelist: tfiledatalist;
 int1,int2: integer;
 stream: ttextstream;
 str1: string;
begin
 filelist:= tfiledatalist.create;
 filelist.adddirectory('/proc',fil_name,nil,[fa_dir]);
 setlength(result,filelist.count);
 int2:= 0;
 for int1:= 0 to filelist.count - 1 do begin
  with filelist[int1] do begin
   if (name[1] >= '0') and (name[1] <= '9') then begin
    stream:= ttextstream.create('/proc/'+name+'/stat',fm_read);
    try
     stream.readln(str1);
     with result[int2] do begin
      if libc.sscanf(pchar(str1),'%d (%*a[^)]) %*c %d',
     {$ifdef FPC}[{$endif}@pid,@ppid{$ifdef FPC}]{$endif}) = 2 then begin
       inc(int2);
      end;
     end;
    finally
     stream.free;
    end;
   end;
  end;
 end; 
 filelist.free;
 setlength(result,int2);
end;

procedure sys_sched_yield;
begin
 sched_yield;
end;

procedure sys_usleep(const us: cardinal);
begin
 libc.usleep(us);
end;

function sys_getlasterror: Integer;
begin
 {$ifdef FPC}{$checkpointer off}{$endif}
 Result := __errno_location()^;
 {$ifdef FPC}{$checkpointer default}{$endif}
end;

procedure sys_setlasterror(const avalue: integer);
begin
 {$ifdef FPC}{$checkpointer off}{$endif}
 __errno_location()^:= avalue;
 {$ifdef FPC}{$checkpointer default}{$endif}
end;

function sys_geterrortext(aerror: integer): string;
const
 buflen = 1024;
var
 buffer: array[0..buflen] of char;
 po1: pchar;
begin
 result:= ''; //compilerwarning
 po1:= strerror_r(aerror,pchar(@buffer),buflen);
 setstring(result,po1,strlen(po1));
end;

function sys_filesystemiscaseinsensitive: boolean;
begin
 result:= false;
end;

function sys_getapplicationpath: filenamety;
begin
 result:= paramstr(0);
end;

function sys_getcommandlinearguments: stringarty;
var
 av: pcharpoaty;
 ac: pinteger;
 int1: integer;
begin
 ac:= {$ifdef FPC}@argc{$else}@argcount{$endif};
 av:= pcharpoaty({$ifdef FPC}argv{$else}argvalues{$endif});
 setlength(result,ac^);
 for int1:= 0 to ac^-1 do begin
  result[int1]:= av^[int1];
 end;
end;

function timestampms: cardinal;
var
 t1: timeval;
begin
 gettimeofday(@t1,ptimezone(nil));
 result:= t1.tv_sec * 1000 + t1.tv_usec div 1000;
end;

function gettimestamp(timeoutusec: integer): timespec;
var
 ti: timeval;
begin
 gettimeofday(@ti,nil);
 ti.tv_usec:= ti.tv_usec + timeoutusec;
 result.tv_sec:= ti.tv_sec + integer(longword(ti.tv_usec) div 1000000);
 result.tv_nsec:= (longword(ti.tv_usec) mod 1000000) * 1000;
end;

procedure initmutex(out mutex: pthread_mutex_t);
var
 attr: tmutexattribute;
begin
 pthread_mutexattr_init(attr);
 pthread_mutexattr_settype(attr,recursive);
// attr.__mutexkind:= recursive;
 pthread_mutex_init(@mutex,@attr);
 pthread_mutexattr_destroy(attr);
end;

procedure destroymutex(var mutex: pthread_mutex_t);
begin
 while pthread_mutex_destroy(mutex) = ebusy do begin
  pthread_mutex_unlock(mutex);
  {$ifdef mse_debug_mutex}
  interlockeddecrement(mutexcount);
  if application.getmutexaddr = @mutex then begin
   interlockeddecrement(appmutexcount);
//   debugwriteln('sys_destroymutex count: '+inttostr(application.getmutexcount)+
//              ' mutexcount: '+inttostr(appmutexcount));
  end;
  {$endif}
 end;
end;

function sys_tosysfilepath(var path: msestring): syserrorty;
begin
 result:= sye_ok;
end;

const
 openmodes: array[fileopenmodety] of cardinal =
     (o_rdonly,o_wronly,o_rdwr,o_rdwr or o_creat or o_trunc,o_rdwr or o_creat or o_trunc);

function getfilerights(const rights: filerightsty): cardinal;
const
 filerights: array[filerightty] of cardinal =
               (libc.s_irusr,libc.s_iwusr,libc.s_ixusr,
                libc.s_irgrp,libc.s_iwgrp,libc.s_ixgrp,
                libc.s_iroth,libc.s_iwoth,libc.s_ixoth,
                libc.s_isuid,libc.s_isgid,libc.s_isvtx);
var
 fr: filerightty;
begin
 result:= 0;
 for fr:= low(filerightty) to high(filerightty) do begin
  if fr in rights then begin
   result:= result or filerights[fr];
  end;
 end;
end;

function sys_createdir(const path: msestring; const rights: filerightsty): syserrorty;
var
 str1: string;
begin
 str1:= path;
 if libc.__mkdir(pchar(str1),getfilerights(rights)) <> 0 then begin
//  result:= sye_createdir;
 result:= syelasterror;
 end
 else begin
  result:= sye_ok;
 end;
end;

procedure setcloexec(const fd: integer);
var
 flags: integer;
begin
 flags:= fcntl(fd,f_getfd); 
 if flags <> -1 then begin
  flags:= flags or fd_cloexec;
  fcntl(fd,f_setfd,flags)
 end;
end;

function sys_openfile(const path: msestring; const openmode: fileopenmodety;
          const accessmode: fileaccessmodesty;
          const rights: filerightsty; out handle: integer): syserrorty;
var
 str1: string;
 str2: msestring;

begin
 str2:= path;
 sys_tosysfilepath(str2);
 str1:= str2;
 handle:= Integer(libc.open(PChar(str1), openmodes[openmode],
        {$ifdef FPC}[{$endif}getfilerights(rights){$ifdef FPC}]{$endif}));
 if handle >= 0 then begin
  setcloexec(handle);
  result:= sye_ok;
 end
 else begin
  result:= syelasterror;
 end;
end;

function sys_closefile(const handle: integer): syserrorty;
begin
 if (handle = invalidfilehandle) or (libc.__close(handle) = 0) then begin
  result:= sye_ok;
 end
 else begin
  result:= syelasterror;
 end;
end;

function sys_dup(const source: integer; out dest: integer): syserrorty;
begin
 dest:= dup(source);
 if dest = -1 then begin
  result:= syelasterror;
 end
 else begin
  result:= sye_ok;
 end;
end;


function sys_read(fd:longint; buf:pointer; nbytes: dword): integer;
begin
 result:= libc.__read(fd,buf^,nbytes);
end;

function sys_write(fd:longint; buf: pointer; nbytes: longword): integer;
var
 int1: integer;
begin
 result:= nbytes;
 repeat
  int1:= libc.__write(fd,buf^,nbytes);
  if int1 = -1 then begin
   result:= int1;
   break;
  end;
  inc(pchar(buf),int1);
  dec(nbytes,int1);
 until integer(nbytes) <= 0;
end;

function sys_errorout(const atext: string): syserrorty;
begin
 if (length(atext) = 0) or
   (libc.__write(2,pchar(atext)^,length(atext)) = length(atext)) then begin
  result:= sye_ok;
 end
 else begin
  result:= syelasterror;
 end;
end;

{$R-}
function sys_gettimeus: cardinal;
var
 time: timeval;
begin
 gettimeofday(@time,ptimezone(nil));
 result:= time.tv_sec * 1000000 + time.tv_usec;
end;

function sys_mutexcreate(out mutex: mutexty): syserrorty;
begin
 initmutex(linuxmutexty(mutex).mutex);
 result:= sye_ok;
end;

function sys_mutexdestroy(var mutex: mutexty): syserrorty;
begin
 destroymutex(linuxmutexty(mutex).mutex);
 result:= sye_ok;
end;

function sys_mutexlock(var mutex: mutexty): syserrorty;
begin
 if pthread_mutex_lock(linuxmutexty(mutex).mutex) = 0 then begin
  result:= sye_ok;
  {$ifdef mse_debug_mutex}
  interlockedincrement(mutexcount);
  if application.getmutexaddr = @mutex then begin
   interlockedincrement(appmutexcount);
//   debugwriteln('sys_mutexlock count: '+inttostr(application.getmutexcount)+
//              ' mutexcount: '+inttostr(appmutexcount));
  end;
  {$endif}
 end
 else begin
  result:= sye_mutex;
 end;
end;

function sys_mutextrylock(var mutex: mutexty): syserrorty;
var
 int1: integer;
begin
 int1:= pthread_mutex_trylock(linuxmutexty(mutex).mutex);
 {$ifdef mse_debug_mutex}
 if int1 = 0 then begin
  interlockedincrement(mutexcount);
  if application.getmutexaddr = @mutex then begin
   interlockedincrement(appmutexcount);
  end;
 end;
 {$endif}
 case int1 of
  0: result:= sye_ok;
  ebusy: result:= sye_busy;
  else result:= sye_mutex;
 end;
end;

function sys_mutexunlock(var mutex: mutexty): syserrorty;
begin
 if pthread_mutex_unlock(linuxmutexty(mutex).mutex) = 0 then begin
  {$ifdef mse_debug_mutex}
  interlockeddecrement(mutexcount);
  if application.getmutexaddr = @mutex then begin
   interlockeddecrement(appmutexcount);
  end;
  {$endif}
  result:= sye_ok;
 end
 else begin
  result:= sye_mutex;
 end;
end;

function sys_semcreate(out sem: semty; count: integer): syserrorty;
begin
 fillchar(sem,sizeof(sem),0);
 with linuxsemty(sem) do begin
  if sem_init(sema,{$ifdef FPC}0{$else}false{$endif},count) = 0 then begin
   result:= sye_ok;
  end
  else begin
   result:= sye_semaphore;
  end;
 end;
end;

function sempost1(var sem: semty): syserrorty;
begin
 with linuxsemty(sem) do begin
  if sem_post(sema) = 0 then begin
   result:= sye_ok;
  end
  else begin
   result:= sye_semaphore;
  end;
 end;
end;

function sys_sempost(var sem: semty): syserrorty;
begin
 with linuxsemty(sem) do begin
  if destroyed <> 0 then begin
   result:= sye_semaphore;
   exit;
  end;
 end;
 result:= sempost1(sem);
end;

function sys_semdestroy(var sem: semty): syserrorty;
var
 int1: integer;
begin
 result:= sye_ok;
 with linuxsemty(sem) do begin
  int1:= interlockedincrement(destroyed);
  if int1 = 1 then begin
   while sys_semcount(sem) = 0 do begin
    if sem_post(sema) <> 0 then begin
     break;
    end;
   end;
   sem_destroy(sema);
  end;
 end;
end;

function sys_semwait(var sem: semty;  timeoutusec: integer): syserrorty;
          //timeoutus = 0 -> no timeout;
var
 time1: ttimespec;
 err: integer;
begin
 result:= sye_semaphore;
 with linuxsemty(sem) do begin
  if destroyed <> 0 then begin
   exit;
  end;
  if timeoutusec = 0 then begin
   while sem_wait(sema) <> 0 do begin
    if sys_getlasterror <> eintr then begin
     exit;
    end;
   end;
  end
  else begin
   time1:= gettimestamp(timeoutusec);
   while sem_timedwait(sema,@time1) <> 0 do begin
    case sys_getlasterror of
     eintr: begin
     end;
     etimedout: begin
      result:= sye_timeout;
      exit;
     end
     else begin
      exit;
     end;
    end;
   end;
  end;
 end;
 result:= sye_ok;
end;

function sys_semtrywait(var sem: semty): boolean;
begin
 with linuxsemty(sem) do begin
  if destroyed <> 0 then begin
   result:= false;
   exit;
  end;
  repeat
   result:= sem_trywait(sema) = 0;
  until result or (sys_getlasterror <> eintr);
 end;
end;

function sys_semcount(var sem: semty): integer;
begin
 with linuxsemty(sem) do begin
  sem_getvalue(sema,{$ifdef FPC}@{$endif}result);
 end;
end;

function sys_condcreate(out cond: condty): syserrorty;
begin
 pthread_cond_init(linuxcondty(cond).cond,nil);
 initmutex(linuxcondty(cond).mutex);
 result:= sye_ok;
end;

function sys_conddestroy(var cond: condty): syserrorty;
begin
 while true do begin
  pthread_mutex_lock(linuxcondty(cond).mutex);
  if pthread_cond_destroy(linuxcondty(cond).cond) = 0 then begin
   pthread_mutex_unlock(linuxcondty(cond).mutex);
   destroymutex(linuxcondty(cond).mutex);
   break;
  end;
  pthread_cond_broadcast(linuxcondty(cond).cond);
  pthread_mutex_unlock(linuxcondty(cond).mutex);
 end;
 result:= sye_ok;
end;

function sys_condlock(var cond: condty): syserrorty;
begin
 pthread_mutex_lock(linuxcondty(cond).mutex);
 result:= sye_ok;
end;

function sys_condunlock(var cond: condty): syserrorty;
begin
 pthread_mutex_unlock(linuxcondty(cond).mutex);
 result:= sye_ok;
end;

function sys_condsignal(var cond: condty): syserrorty;
begin
 pthread_cond_signal(linuxcondty(cond).cond);
 result:= sye_ok;
end;

function sys_condbroadcast(var cond: condty): syserrorty;
begin
 pthread_cond_broadcast(linuxcondty(cond).cond);
 result:= sye_ok;
end;

function sys_condwait(var cond: condty; timeoutusec: integer): syserrorty;
          //timeoutus = 0 -> no timeout;
          //gue_ok -> condition signaled
          //gue_timeout -> timeout
          //gue_cond -> error
var
 time1: ttimespec;
begin
 result:= sye_ok;
 if timeoutusec = 0 then begin
  pthread_cond_wait(linuxcondty(cond).cond,linuxcondty(cond).mutex);
 end
 else begin
  time1:= gettimestamp(timeoutusec);
  if pthread_cond_timedwait(linuxcondty(cond).cond,linuxcondty(cond).mutex,
             @time1) <> 0 then begin
   result:= sye_timeout;
  end;
 end;
end;

{$ifdef FPC}

function threadexec(infopo : pointer) : longint;
begin
 pthread_setcanceltype(pthread_cancel_asynchronous,nil);
 pthread_setcancelstate(pthread_cancel_enable,nil);
 result:= threadinfoty(infopo^).threadproc();
end;

{$else}

function threadexec(infopo: pointer): integer; cdecl;
begin
 pthread_setcanceltype(pthread_cancel_asynchronous,nil);
 pthread_setcancelstate(pthread_cancel_enable,nil);
 result:= threadinfoty(infopo^).threadproc();
end;

{$endif}

function sys_issamethread(const a,b: threadty): boolean;
begin
 result:= pthread_equal(a,b) <> 0;
end;
 
function sys_threadcreate(var info: threadinfoty): syserrorty;
{$ifndef FPC}
var
 attr: tthreadattr;
{$endif}
begin
 {$ifdef FPC}
 with info do begin
  id:= 0;
  id:= beginthread(@threadexec,@info);
  if id = 0 then begin
   result:= sye_thread;
  end
  else begin
   result:= sye_ok;
  end;
 end;
 {$else}
 with info do begin
  ismultithread:= true;
  pthread_attr_init(attr);
  if pthread_create(ppthread_t(@id),
          @attr,{$ifdef FPC}@{$endif}threadexec,@info) <> 0 then begin
   result:= sye_thread;
  end
  else begin
   result:= sye_ok;
  end;
 end;
 {$endif}
end;

function sys_threadwaitfor(var info: threadinfoty): syserrorty;
begin
{$ifdef FPC}
 waitforthreadterminate(info.id,0);
 result:= sye_ok;
{$else}
  result:= syeseterror(pthread_join(info.id,nil));
{$endif}
end;

function sys_threaddestroy(var info: threadinfoty): syserrorty;
begin
 result:= sye_ok;
{$ifdef FPC}
 killthread(info.id);
{$else}
 pthread_detach(info.id);
 pthread_cancel(info.id);
{$endif}
end;

function sys_getcurrentthread: threadty;
begin
 result:= pthread_self;
end;

function sys_copyfile(const oldfile,newfile: msestring): syserrorty;
const
 bufsize = $2000; //8k
var
 str1,str2: string;
 source,dest: integer;
 stat: _stat;
 lwo1: longword;
 po1: pointer;
begin
 str1:= oldfile;
 str2:= newfile;
 result:= sye_copyfile;
 source:= libc.open(pchar(str1),o_rdonly);
 if source <> -1 then begin
  if fstat(source,stat) = 0 then begin
   dest:= libc.open(pchar(str2),
   o_rdwr or o_creat or o_trunc,
   {$ifdef FPC}[{$endif}s_irusr or s_iwusr{$ifdef FPC}]{$endif});
   if dest <> -1 then begin
 // does not work on kernel 2.5+
 //    lwo1:= 0;
 //    if libc.syscall(nr_sendfile,
 //    {$ifdef FPC}[{$endif}dest,source,@lwo1,$ffffffff{$ifdef FPC}]{$endif}) <> -1 then begin
    getmem(po1,bufsize);
    lwo1:= 0; //compiler warning
    while true do begin
     lwo1:= libc.__read(source,po1^,bufsize);
     if (lwo1 = 0) or (lwo1 = longword(-1)) then begin
      break;
     end;
     if libc.__write(dest,po1^,lwo1) <> integer(lwo1) then begin
      break;
     end;
    end;
    freemem(po1);
    if lwo1 = 0 then begin
     if libc.fchmod(dest,stat.st_mode) = 0 then begin
      result:= sye_ok;
     end
     else begin
      result:= syelasterror;
     end;
    end
    else begin
     result:= syelasterror;
    end;
    libc.__close(dest);
   end
   else begin
    result:= syelasterror;
   end;
  end
  else begin
   result:= syelasterror;
  end;
  libc.__close(source);
 end
 else begin
  result:= syelasterror;
 end;
end;

function sys_renamefile(const oldname,newname: filenamety): syserrorty;
var
 str1,str2: string;
begin
 str1:= oldname;
 str2:= newname;
 if libc.__rename(pchar(str1),pchar(str2)) = -1 then begin
  result:= syelasterror;
 end
 else begin
  result:= sye_ok;
 end;
end;

function sys_deletefile(const filename: filenamety): syserrorty;
var
 str1: string;
begin
 str1:= filename;
 if libc.unlink(pchar(str1)) = -1 then begin
  result:= syelasterror;
 end
 else begin
  result:= sye_ok;
 end;
end;

function xstat64(Ver: Integer; FileName: PChar; var StatBuffer: TStatBuf64): Integer; cdecl;
                               external libcmodulename name '__xstat64';

function getfiletype(value: cardinal): filetypety;
var
 count: filetypety;
begin
 result:= ft_unknown;
 value:= value and s_ifmt;
 for count:= low(filetypety) to high(filetypety) do begin
  if value = filetypes[count] then begin
   result:= count;
   break;
  end;
 end;
end;

function getfileattributes(value: __mode_t): fileattributesty;
begin
 result:= [];

 if value and s_irusr <> 0 then include(result,fa_rusr);
 if value and s_iwusr <> 0 then include(result,fa_wusr);
 if value and s_ixusr <> 0 then include(result,fa_xusr);

 if value and s_irgrp <> 0 then include(result,fa_rgrp);
 if value and s_iwgrp <> 0 then include(result,fa_wgrp);
 if value and s_ixgrp <> 0 then include(result,fa_xgrp);

 if value and s_iroth <> 0 then include(result,fa_roth);
 if value and s_iwoth <> 0 then include(result,fa_woth);
 if value and s_ixoth <> 0 then include(result,fa_xoth);

 if value and s_isuid <> 0 then include(result,fa_suid);
 if value and s_isgid <> 0 then include(result,fa_sgid);
 if value and s_isvtx <> 0 then include(result,fa_svtx);

end;

function filetimetodatetime(sec: time_t; usec: cardinal): tdatetime;
begin
 result:= sec / (24.0*60.0*60.0) + usec / (24.0*60.0*60.0*1e6) - datetimeoffset;
end;

function sys_getcurrentdir: msestring;
var
 str1: string;
 po1: pchar;
begin
 str1:= '';
 repeat
  setlength(str1,length(str1) + path_max);
  po1:= getcwd(@str1[1],length(str1));
 until (po1 <> nil) or (sys_getlasterror() <> erange);
 setlength(str1,strlen(po1));
 result:= str1;
end;

function sys_gethomedir: filenamety;
var
 po1: pchar;
begin
 po1:= getenv('HOME');
 if po1 <> nil then begin
  result:= string(po1);
 end
 else begin
  result:= '';
 end;
end;

function sys_setcurrentdir(const dirname: filenamety): syserrorty;
var
 str1: string;
begin
 str1:= dirname;
 if libc.__chdir(pchar(str1)) = 0 then begin
  result:= sye_ok;
 end
 else begin
  result:= syelasterror;
 end;
end;

function sys_opendirstream(var stream: dirstreamty): syserrorty;
var
 str1: string;
begin
 str1:= stream.dirname;
 with stream,dirstreamlinuxty(platformdata) do begin
  dir:= pdir(opendir(pchar(str1)));
  if dir = nil then begin
   result:= sye_dirstream;
  end
  else begin
   if (infolevel > fil_name) or not (fa_all in include) or
                         (exclude <> []) then begin
    needsstat:= true;
    if (str1 <> '') and (str1[length(str1)] <> '/') then begin
     str1:= str1 + '/';
    end;
    string(dirpath):= str1; //stat needed
   end;
   result:= sye_ok;
  end;
 end;
end;

function sys_closedirstream(var stream: dirstreamty): syserrorty;
begin
 with dirstreamlinuxty(stream.platformdata) do begin
  string(dirpath):= '';
  if closedir(pointer(dir)) = 0 then begin
   result:= sye_ok;
  end
  else begin
   result:= sye_dirstream;
  end;
 end;
end;

function sys_readdirstream(var stream: dirstreamty; var info: fileinfoty): boolean;
 //true if valid
var
 dirent: dirent64;
 po1: pdirent64;
 statbuffer: tstatbuf64;
 //stat1: tstatbuf;
 str1: string;
begin
 result:= false;
 with stream,dirstreamlinuxty(platformdata) do begin
  if not ((include <> []) and (fa_all in exclude)) then begin
   while true do begin
    if (readdir64_r(dir,@dirent,@po1) = 0) and
          (po1 <> nil) then begin
     with info do begin
      str1:= dirent.d_name;
      name:= str1;
      if checkfilename(info.name,mask,true) then begin
       if needsstat then begin
        if xstat64(stat_ver_mse,pchar(string(dirpath)+str1),
              statbuffer) = 0 then begin
         with extinfo1,extinfo2,statbuffer do begin
          filetype:= getfiletype(st_mode);
          attributes:= getfileattributes(st_mode);
          if (length(name) > 0) and (info.name[1] = '.') then begin
           system.include(attributes,fa_hidden);
          end;
          if filetype = ft_dir then begin
           system.include(attributes,fa_dir);
          end;
          if ((fa_all in include) or (attributes * include <> [])) and
                 ((attributes * exclude) = []) then begin
           state:= state + [fis_extinfo1valid,fis_extinfo2valid];
           size:= st_size;
           modtime:= filetimetodatetime(st_mtime,st_mtime_usec);
           accesstime:= filetimetodatetime(st_atime,st_atime_usec);
           ctime:= filetimetodatetime(st_ctime,st_ctime_usec);
           id:= st_ino;
           owner:= st_uid;
           group:= st_gid;
           result:= true;
           break;
          end;
         end;
        end;
       end
       else begin
        result:= true;
        break;
       end;
      end;
     end;
    end
    else begin
     break;
    end;
   end;
  end;
 end;
end;

procedure stattofileinfo(const statbuffer: tstatbuf64; var info: fileinfoty);
begin
 with info,extinfo1,extinfo2,statbuffer do begin
  filetype:= getfiletype(st_mode);
  attributes:= getfileattributes(st_mode);
  if (length(name) > 0) and (info.name[1] = '.') then begin
   system.include(attributes,fa_hidden);
  end;
  if filetype = ft_dir then begin
   system.include(attributes,fa_dir);
  end;
  state:= state + [fis_extinfo1valid,fis_extinfo2valid];
  size:= st_size;
  modtime:= filetimetodatetime(st_mtime,st_mtime_usec);
  accesstime:= filetimetodatetime(st_atime,st_atime_usec);
  ctime:= filetimetodatetime(st_ctime,st_ctime_usec);
  id:= st_ino;
  owner:= st_uid;
  group:= st_gid;
 end;
end;

function sys_getfileinfo(const path: filenamety; var info: fileinfoty): boolean;
var
 str1: filenamety;
 statbuffer: tstatbuf64;
begin
 clearfileinfo(info);
 str1:= tosysfilepath(path);
 fillchar(statbuffer,sizeof(statbuffer),0);
 result:= xstat64(stat_ver_mse,pchar(string(str1)),statbuffer) = 0;
 if result then begin
  stattofileinfo(statbuffer,info);
  splitfilepath(filepath(path),str1,info.name);
 end;
end;

var
 lastlocaltime: integer;
 gmtoff: real;
 
function sys_localtimeoffset: tdatetime;
var
 tm: tunixtime;
 int1: integer;
begin
 int1:= __time(nil);
 if int1 <> lastlocaltime then begin
  lastlocaltime:= int1;
  localtime_r(@int1,@tm);
  gmtoff:= tm.__tm_gmtoff / (24.0*60.0*60.0);
 end;
 result:= gmtoff;
end;

function sys_utctolocaltime(const value: tdatetime): tdatetime;
var
 ti1: integer;
 rea1: real;
 tm: tunixtime;
begin
 rea1:= value + datetimeoffset;
 if rea1 < 0 then begin
  ti1:= 0;
 end
 else begin
  ti1:= round(rea1) * 24*60*60; //seconds
 end;
 localtime_r(@ti1,@tm);
 result:= incsecond(value,tm.__tm_gmtoff);
// result:= value + sys_localtimeoffset; 
end;

function sys_localtimetoutc(const value: tdatetime): tdatetime;
var
 year,month,day,hour,minute,second,millisecond: word;
 tm: tunixtime;
begin
 if value < -datetimeoffset then begin
  decodedatetime(-datetimeoffset,year,month,day,hour,minute,second,millisecond);
 end
 else begin
  decodedatetime(value,year,month,day,hour,minute,second,millisecond);
 end;
 with tm do begin
  tm_sec:= second;
  tm_min:= minute;
  tm_hour:= hour;
  tm_mday:= day;
  tm_mon:= month;
  tm_year:= year-1900;
 end;
 timelocal(tm);
 result:= incsecond(value,-tm.__tm_gmtoff);
// result:= value - sys_localtimeoffset; 
end;

function sys_getlangname: string;
var
 po1: pchar;
 ar1: stringarty;
begin
 po1:= setlocale(lc_messages,nil);
 ar1:= splitstring(string(po1),'_');
 if high(ar1) >= 0 then begin
  result:= ar1[0];
 end
 else begin
  result:= string(po1);
 end;
end;

procedure sigtest(SigNum: Integer); cdecl;
begin
end;

procedure sigdummy(SigNum: Integer); cdecl;
begin
end;

procedure setsighandlers;
var
 info: tsigaction;
begin
 fillchar(info,sizeof(info),0);
 with info do begin
 {$ifdef FPC}
  sa_handler:= @sigdummy;
 {$else}
  __sigaction_handler:= @sigdummy;
 {$endif}
  sa_flags:= sa_restart;
 end;
 sigaction(sigio,@info,nil);
end;

initialization
 setsighandlers;
end.
