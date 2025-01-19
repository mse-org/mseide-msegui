 
function sigactionex(SigNum: Integer; var Action: TSigActionex;
                              OldAction: PSigAction): Integer;
begin
 action.sa_flags:= action.sa_flags or SA_SIGINFO;
 result:= sigaction(signum,@action,oldaction);
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
// stat_ver_mse = 3;

 path_max = 1024;
 filetypes: array[filetypety] of longword = (0,s_ifdir,s_ifblk,
                                s_ifchr,s_ifreg,s_iflnk,s_ifsock,s_ififo);
// timeoffset = 0.0;
 o_cloexec = $080000;
 
type
 dirstreamlinuxdty = record
  dir: pdirectorystream;
  dirpath: pointer;
  needsstat: boolean;
  needstype: boolean;
 end;
 {$if sizeof(dirstreamlinuxdty) > sizeof(dirstreampty)} 
  {$error 'buffer overflow'}
 {$endif}
 dirstreamlinuxty = record
  case integer of
   0: (d: dirstreamlinuxdty;);
   1: (_bufferspace: dirstreampty;);
 end;

function unblocksignal(const signum: integer): boolean;
              //true if blocked before
var
 set1,set2: __sigset_t;
begin
 sigemptyset(set1);
 sigaddset(set1,signum);
 pthread_sigmask(sig_unblock,@set1,@set2);
 result:= sigismember(set2,signum) <> 0;
end;

function blocksignal(const signum: integer): boolean;
              //true if blocked before
var
 set1,set2: __sigset_t;
begin
 sigemptyset(set1);
 sigaddset(set1,signum);
 pthread_sigmask(sig_block,@set1,@set2);
 result:= sigismember(set2,signum) <> 0;
end;

function sys_getpid: procidty;
begin
 result:= mselibc.getpid;
end;

function sys_terminateprocess(const proc: prochandlety): syserrorty;
begin
 if (kill(proc,sigterm) = 0) or (sys_getlasterror = esrch) then begin
  result:= sye_ok;
 end
 else begin
  result:= syelasterror;
 end;
end;

function sys_killprocess(const proc: prochandlety): syserrorty;
begin
 if (kill(proc,sigkill) = 0) or (sys_getlasterror = esrch) then begin
  result:= sye_ok;
 end
 else begin
  result:= syelasterror;
 end;
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
 result:= defaultprintcommand;
 if result = '' then begin
  result:= 'lp -';
 end;
end;

procedure sys_getenvvars(out names: msestringarty; out values: msestringarty);
var
 str1: string;
 po1: ppchar;
 po2,po3,po4: pchar;
begin
 po1:= environ;
 if po1 <> nil then begin
  while true do begin
   po2:= po1^;
   if po2 = nil then begin
    break;
   end;
   po3:= po2;
   while po3^ <> #0 do begin
    inc(po3);
   end;
   po4:= po2;
   while (po4^ <> '=') and (po4 < po3) do begin
    inc(po4);
   end;
   str1:= psubstr(po2,po4);
   additem(names,msestring(str1));
   str1:= psubstr(po4+1,po3);
   additem(values,msestring(str1));
   inc(po1);
  end;
 end;
end;

var
 connectmutex1: mutexty;
 connectmutex2: mutexty;
 
var
 mainthreadid: threadty;
 connectpipe: tpipedescriptors;
 dummybyte: byte; 
 
procedure gui_connectmaineventqueue();     //called by gdi_unlock()
begin
 sys_mutexunlock(connectmutex1);
 sys_mutexunlock(connectmutex2);
end; 

function gui_raisewindow(id: winidty;
                             const topmost: boolean = false): guierrorty;
begin
{
 gdi_lock;
{$ifdef mse_debugzorder}
 debugwindow('* gui_raisewindow ',id);
{$endif}
 if toplevelraise then begin
//  waitfordecoration(id);
  xraisewindow(appdisp,toplevelwindow(id));
 end
 else begin
  xraisewindow(appdisp,id);
 end;
 result:= gue_ok;
 gdi_unlock;
 }
 result:= gue_ok;
end;

function gui_lowerwindow(id: winidty;
                             const topmost: boolean = false): guierrorty;
begin
{
 gdi_lock;
{$ifdef mse_debugzorder}
 debugwindow('* gui_lowerwindow ',id);
{$endif}
 xlowerwindow(appdisp,id);
 result:= gue_ok;
 gdi_unlock;
} 
result:= gue_ok;
end;

procedure gui_disconnectmaineventqueue(); //called by gdi_lock()
begin
 sys_mutexlock(connectmutex2);
 if sys_mutextrylock(connectmutex1) <> sye_ok then begin
  sys_write(connectpipe.writedes,@dummybyte,1);
  sys_mutexlock(connectmutex1);
 end;
end;

type
 pollinfoarty = array of pollfd;
 pollinfoty = record
  callback: pollcallbackty;
  data: pointer;
 end;
 pollinfodestarty = array of pollinfoty;
 pollinfty = record
  pollinfo: pollinfoarty;
  pollinfodest: pollinfodestarty;
 end;
 ppollinfty = ^pollinfty;

var
// pollinfo: array[0..2] of pollfd;
             //0 connection, 1 sessionmanagement
 pollinf: ppollinfty;

function gui_addpollfd(var id: int32; const afd: int32;
                           const aflags: pollflagsty;
                                const acallback: pollcallbackty = nil;
                                      const adata: pointer = nil): guierrorty;
begin
 result:= gue_ok;
 with pollinf^ do begin
  setlength(pollinfo,high(pollinfo)+2);
  setlength(pollinfodest,length(pollinfo));
  id:= high(pollinfo);
  with pollinfo[id] do begin
   fd:= afd;
   events:= int32(aflags * [pf_in,pf_pri,pf_out]);
   with pollinfodest[id] do begin
    callback:= acallback;
    data:= adata;
   end;
  end;
 end;
end;

function gui_removepollfd(const id: int32): guierrorty;
begin
 with pollinf^ do begin
  if (id < 0) or (id > high(pollinfo)) then begin
   result:= gue_index;
  end
  else begin
   deleteitem(pollinfo,typeinfo(pollinfo),id);
   deleteitem(pollinfodest,typeinfo(pollinfodest),id);
   result:= gue_ok;
  end;
 end;
end;

function gui_setpollfdactive(const id: int32;
                       const aactive: boolean): guierrorty;
begin
 with pollinf^ do begin
  if (id < 0) or (id > high(pollinfo)) then begin
   result:= gue_index;
  end
  else begin
   with pollinfo[id] do begin
    if (fd >= 0) xor aactive then begin
     if fd = 0 then begin
      fd:= minint;
     end
     else begin
      if fd = minint then begin
       fd:= 0;
      end
      else begin
       fd:= -fd;
      end;
     end;
    end;
   end;
   result:= gue_ok;
  end;
 end;
end;

function sys_truncatefile(const handle: integer; const size: int64): syserrorty;
begin
 result:= sye_ok;
 while mselibc.ftruncate64(handle,size) <> 0 do begin
  if sys_getlasterror <> eintr then begin
   result:= syelasterror;
   break;
  end;
 end;
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
      if mselibc.sscanf(pchar(str1),'%d (%*a[^)]) %*c %d',
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

procedure sys_schedyield;
begin
 sched_yield;
end;

procedure sys_usleep(const us: longword);
begin
 if us = 0 then begin
  sched_yield;
 end
 else begin
  mselibc.usleep(us);
 end;
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

function sys_getenv(const aname: msestring; out avalue: msestring): boolean;
                          //true if found
var
 po1: pchar;
 str1: ansistring;
begin
 avalue:= '';
 po1:= getenv(pchar(ansistring(aname)));
 result:= po1 <> nil;
 if result then begin
  str1:= po1;
  avalue:= str1;
 end;
end;

function sys_setenv(const aname: msestring; const avalue: msestring): syserrorty;
begin
 result:= sye_ok;
 if setenv(pchar(ansistring(aname)),pchar(ansistring(avalue)),1) <> 0 then begin
  result:= syelasterror;
 end;
end;

function sys_unsetenv(const aname: msestring): syserrorty;
begin
 result:= sye_ok;
 if unsetenv(pchar(ansistring(aname))) <> 0 then begin
  result:= syelasterror;
 end;
end;

function timestampms: longword;
var
 t1: timeval;
begin
 gettimeofday(@t1,mselibc.ptimezone(nil));
 result:= t1.tv_sec * 1000 + t1.tv_usec div 1000;
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

function sys_getutctime: tdatetime;
var
 ti: timeval;
begin
 gettimeofday(@ti,nil);
 result:= ti.tv_sec / (double(24.0)*60.0*60.0) + 
          ti.tv_usec / (double(24.0)*60.0*60.0*1e6) - unidatetimeoffset;
end;

function sys_getlocaltime: tdatetime;
var
 ti: timeval;
begin
 gettimeofday(@ti,nil);
 result:= ti.tv_sec / (double(24.0)*60.0*60.0) + 
          ti.tv_usec / (double(24.0)*60.0*60.0*1e6) - unidatetimeoffset;
 if ti.tv_sec = lastlocaltime then begin
  result:= result + gmtoff;
 end
 else begin
  result:= result + sys_localtimeoffset;
 end;
end;

function sys_tosysfilepath(var path: msestring): syserrorty;
begin
 result:= sye_ok;
end;

const
 openmodes: array[fileopenmodety] of longword =
//    fm_none,fm_read, fm_write,fm_readwrite,fm_create,
     (0,      o_rdonly,o_wronly,o_rdwr,      o_rdwr or o_creat or o_trunc,
//    fm_append
      o_rdwr or o_creat {or o_trunc});

function getfilerights(const rights: filerightsty): longword;
const
 filerights: array[filerightty] of longword =
               (mselibc.s_irusr,mselibc.s_iwusr,mselibc.s_ixusr,
                mselibc.s_irgrp,mselibc.s_iwgrp,mselibc.s_ixgrp,
                mselibc.s_iroth,mselibc.s_iwoth,mselibc.s_ixoth,
                mselibc.s_isuid,mselibc.s_isgid,mselibc.s_isvtx);
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
 if mselibc.__mkdir(pchar(str1),
                 getfilerights(rights)) <> 0 then begin
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
 stat1: _stat;
const
 defaultopenflags = o_cloexec; 
begin
 str2:= path;
 sys_tosysfilepath(str2);
 str1:= str2;
 handle:= Integer(mselibc.open(PChar(str1), openmodes[openmode] or 
                            defaultopenflags,
        {$ifdef FPC}[{$endif}getfilerights(rights){$ifdef FPC}]{$endif}));
 if handle >= 0 then begin
  if fstat(handle,@stat1) = 0 then begin  
   if s_isdir(stat1.st_mode) then begin
    mselibc.__close(handle);
    handle:= -1;
    result:= sye_isdir;
   end
   else begin
    setcloexec(handle);
    result:= sye_ok;
   end;    
  end
  else begin
   mselibc.__close(handle);
   handle:= -1;
   result:= syelasterror;
  end;
 end
 else begin
  result:= syelasterror;
 end;
end;

function sys_closefile(const handle: integer): syserrorty;
begin
 if (handle = invalidfilehandle) or 
   (mselibc.__close(handle) = 0) then begin
  result:= sye_ok;
 end
 else begin
  result:= syelasterror;
 end;
end;


function sys_flushfile(const handle: integer): syserrorty;
begin
 result:= sye_ok;
 while mselibc.fsync(handle) <> 0 do begin
  if sys_getlasterror <> eintr then begin
   result:= syelasterror;
   break;
  end;
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
 result:= mselibc.__read(fd,buf^,nbytes);
end;

function sys_write(fd:longint; buf: pointer; nbytes: longword): integer;
var
 int1: integer;
begin
 result:= nbytes;
 repeat
  int1:= mselibc.__write(fd,buf^,nbytes);
  if int1 = -1 then begin
   if sys_getlasterror <> eintr then begin
    result:= int1;
    break;
   end;
   continue;
  end;
  inc(pchar(buf),int1);
  dec(nbytes,int1);
 until integer(nbytes) <= 0;
end;

function sys_errorout(const atext: string): syserrorty;
begin
 if (length(atext) = 0) or
   (mselibc.__write(2,
              pchar(atext)^,length(atext)) = length(atext)) then begin
  result:= sye_ok;
 end
 else begin
  result:= syelasterror;
 end;
end;

{$R-}

{$ifdef FPC}

function threadexec(infopo : pointer) : ptrint{longint};
begin
 threadinfoty(infopo^).id:= getcurrentthreadid;
 pthread_setcanceltype(pthread_cancel_asynchronous,nil);
 pthread_setcancelstate(pthread_cancel_enable,nil);
 result:= threadinfoty(infopo^).threadproc();
end;

{$else}

function threadexec(infopo: pointer): integer; cdecl;
begin
 threadinfoty(infopo^).id:= getcurrentthreadid;
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
var
{$ifndef FPC}
 attr: tthreadattr;
{$else}
 id1: threadty;
{$endif}
begin
 {$ifdef FPC}
 with info do begin
  id:= 0;
  id:= beginthread(@threadexec,@info,id1,info.stacksize);
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

function sys_threadschedyield: syserrorty;
begin
 result:= sye_ok;
 sched_yield;
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
 stat: _stat64;
 lwo1: longword;
 po1: pointer;
begin
 str1:= oldfile;
 str2:= newfile;
 result:= sye_copyfile;
 source:= mselibc.open(pchar(str1),o_rdonly);
 if source <> -1 then begin
  if fstat64(source,@stat) = 0 then begin
   dest:= mselibc.open(pchar(str2),
   o_rdwr or o_creat or o_trunc,
   {$ifdef FPC}[{$endif}s_irusr or s_iwusr{$ifdef FPC}]{$endif});
   if dest <> -1 then begin
    getmem(po1,bufsize);
    lwo1:= 0; //compiler warning
    while true do begin
     lwo1:= mselibc.__read(source,po1^,bufsize);
     if (lwo1 = 0) or (lwo1 = longword(-1)) then begin
      break;
     end;
     if mselibc.__write(dest,po1^,lwo1) <> integer(lwo1) then begin
      break;
     end;
    end;
    freemem(po1);
    if lwo1 = 0 then begin
     if mselibc.fchmod(dest,stat.st_mode) = 0 then begin
      result:= sye_ok;
     end
     else begin
      result:= syelasterror;
     end;
    end
    else begin
     result:= syelasterror;
    end;
    mselibc.__close(dest);
   end
   else begin
    result:= syelasterror;
   end;
  end
  else begin
   result:= syelasterror;
  end;
  mselibc.__close(source);
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
 if mselibc.__rename(pchar(str1),pchar(str2)) = -1 then begin
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
 if mselibc.unlink(pchar(str1)) = -1 then begin
  result:= syelasterror;
 end
 else begin
  result:= sye_ok;
 end;
end;

function getfiletype(value: longword): filetypety;
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

function filetimetodatetime(sec: time_t; nsec: longword): tdatetime;
begin
 result:= sec / (double(24.0)*60.0*60.0) + 
          nsec / (double(24.0)*60.0*60.0*1e9) - unidatetimeoffset;
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

function sys_getuserhomedir: filenamety;
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

function sys_getapphomedir: filenamety;
begin
 result:= sys_getuserhomedir;
end;

function sys_gettempdir: filenamety;
var
 str1: string;
begin
 str1:= getenvironmentvariable('temp');
 if str1 = '' then begin
  str1:= getenvironmentvariable('tmp');
 end;
 if str1 = '' then begin
  str1:= '/tmp/'
 end;
 str1:= includetrailingpathdelimiter(str1);
 result:= tomsefilepath(str1);
end;

function sys_setcurrentdir(const dirname: filenamety): syserrorty;
var
 str1: string;
begin
 str1:= dirname;
 if mselibc.__chdir(pchar(str1)) = 0 then begin
  result:= sye_ok;
 end
 else begin
  result:= syelasterror;
 end;
end;

const
 nameattributes = [fa_hidden];
 typeattributes = nameattributes + [fa_dir];
 
function sys_opendirstream(var stream: dirstreamty): syserrorty;
var
 str1: string;
begin
 checkdirstreamdata(stream);
 str1:= tosysfilepath(stream.dirinfo.dirname);
 with stream,dirinfo,dirstreamlinuxty(platformdata) do begin
{$ifdef FPC}
  d.dir:= pdirectorystream(opendir(pchar(str1)));
{$else}
  pointer(d.dir):= pdir(opendir(pchar(str1)));
{$endif}
  if d.dir = nil then begin
   result:= syelasterror;
  end
  else begin
   if (str1 <> '') and (str1[length(str1)] <> '/') then begin
    str1:= str1 + '/';
   end;
   string(d.dirpath):= str1; //for stat
   d.needsstat:= (infolevel >= fil_ext1) or
              not (fa_all in include) and (include-typeattributes <> []) or
                                                 (exclude-typeattributes <> []);
   d.needstype:= not d.needsstat and
       ((infolevel >= fil_type) or
             not (fa_all in include) and (include-nameattributes <> []) or
                                                 (exclude-nameattributes <> []));
   result:= sye_ok;
  end;
 end;
end;

function sys_closedirstream(var stream: dirstreamty): syserrorty;
begin
 with dirstreamlinuxty(stream.platformdata) do begin
  string(d.dirpath):= '';
  if closedir(pointer(d.dir)) = 0 then begin
   result:= sye_ok;
  end
  else begin
   result:= sye_dirstream;
  end;
 end;
end;

function sys_deletedir(const filename: filenamety): syserrorty;
var
 str1: string;
begin
  str1:= tosysfilepath(filename);
 if mselibc.rmdir(pchar(str1)) = -1 then begin
  result:= syelasterror;
 end
 else begin
  result:= sye_ok;
 end;
end;

function getmodebits(const value: fileattributesty): __mode_t;
begin
 result:= 0;

 if fa_rusr in value then result:= result or s_irusr;
 if fa_wusr in value then result:= result or s_iwusr;
 if fa_xusr in value then result:= result or s_ixusr;

 if fa_rgrp in value then result:= result or s_irgrp;
 if fa_wgrp in value then result:= result or s_iwgrp;
 if fa_xgrp in value then result:= result or s_ixgrp;

 if fa_roth in value then result:= result or s_iroth;
 if fa_woth in value then result:= result or s_iwoth;
 if fa_xoth in value then result:= result or s_ixoth;

 if fa_suid in value then result:= result or s_isuid;
 if fa_sgid in value then result:= result or s_isgid;
 if fa_svtx in value then result:= result or s_isvtx;

end;

function sys_getcommandlinearguments: msestringarty;
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

function sys_getprintcommand: msestring;
begin
 result:= defaultprintcommand;
 if result = '' then begin
  result:= 'lp -';
 end;
end;

procedure fpstattofileinfo(statbuffer: stat; var info: fileinfoty);
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
  state:= state + [fis_typevalid,fis_extinfo1valid,fis_extinfo2valid];
  size:= st_size;
  modtime:= filetimetodatetime(st_mtime,st_mtime_nsec);
  accesstime:= filetimetodatetime(st_atime,st_atime_nsec);
  {$if fpc_fullversion >= 030100}
  ctime:= filetimetodatetime(st_ctime,st_ctime_nsec);
  {$else} 
  ctime:= st_ctime;
  {$endif}
  id:= st_ino;
  owner:= st_uid;
  group:= st_gid;
 end;
end;

function sys_getfdinfo(const fd: longint; var info: fileinfoty): boolean;
var
 {$ifdef linux}
  fpstatbuffer : baseunix.stat;
 {$else} // for bsd
  statbuffer: _stat64;
  {$endif}
begin
 clearfileinfo(info);

 {$ifdef linux}
 fillchar(fpstatbuffer,sizeof(fpstatbuffer),0);
 result := fpfstat(fd,fpstatbuffer) = 0;
 {$else}
 fillchar(statbuffer,sizeof(statbuffer),0);
 result:= fstat64(fd,@statbuffer) = 0;
 {$endif}

 if result then begin
   {$ifdef linux}
   fpstattofileinfo(fpstatbuffer,info);
   {$else}
   stattofileinfo(statbuffer,info);
   {$endif}
 end;
end;


function sys_setfilerights(const path: filenamety;
                                      const rights: filerightsty): syserrorty;
var
 str1: filenamety;
begin
 str1:= tosysfilepath(path);
 if chmod(pchar((str1)),
               getmodebits(fileattributesty(rights))) = 0 then begin
  result:= sye_ok;
 end
 else begin
  result:= syelasterror();
 end;
end;

function sys_setfdrights(const fd: longint;
                         const rights: filerightsty;
                         const filename: filenamety = ''): syserrorty;
begin
 if fchmod(fd,getmodebits(fileattributesty(rights))) = 0 then begin
  result:= sye_ok;
 end
 else begin
  result:= syelasterror();
 end;
end;

function getaccessbits(const value: accessmodesty): integer;
begin
 result:= 0;
 if am_read in value then result:= result or r_ok;
 if am_write in value then result:= result or w_ok;
 if am_execute in value then result:= result or x_ok;
 if am_exist in value then result:= result or f_ok;
end;

function sys_access(const path: filenamety;
                               const accessmodes: accessmodesty): syserrorty;
var
 str1: filenamety;
begin
 str1:= tosysfilepath(path);
 if mselibc.access(pchar(string(str1)),
                                  getaccessbits(accessmodes)) = 0 then begin
  result:= sye_ok;
 end
 else begin
  result:= syelasterror();
 end;
end;

function sys_getusername: msestring;
var
 po1: pchar;
 s1: string;
 pwd: passwd;
 res: ppasswd;
 i1: integer;
begin
 result:= '';
 if getpwuid_r <> nil then begin
  setlength(s1,10000);
  while true do begin
   i1:= getpwuid_r(getuid(),@pwd,pointer(s1),length(s1),@res);
   case i1 of
    0: begin
     if res <> nil then begin
      result:= msestring(ansistring(pwd.pw_name));
     end;
     break;
    end;
    eintr: begin
     //try again
    end;
    erange: begin
     setlength(s1,length(s1)*2);
    end;
    else begin
     break; //error
    end;
   end;
  end;
 end
 else begin
  if cuserid <> nil then begin
   po1:= cuserid(nil);
   result:= msestring(ansistring(po1));
  end;
 end;
end;

function sys_readdirstream(var stream: dirstreamty; var info: fileinfoty): boolean;
 //true if valid
var
 dirent: dirent64;
 po1: pdirent64;
 statbuffer: _stat64;
 //stat1: tstatbuf;
 str1: string;
 error: boolean;
begin
 result:= false;
 with stream,dirinfo,dirstreamlinuxty(platformdata) do begin
  if not ((include <> []) and (fa_all in exclude)) then begin
   while true do begin
  //    if (readdir64_r(d.dir,@dirent,@po1) = 0) and
      if (readdir64_r(d.dir) <> nil) and
          (po1 <> nil) then begin
     with info do begin
      str1:= dirent.d_name;
      name:= str1;
      if checkfilename(info.name,stream) then begin
       if d.needsstat or d.needstype and 
       ((dirent.d_type = dt_unknown) or (dirent.d_type = dt_lnk)) then begin
        error:= stat64(pchar(string(d.dirpath)+str1),@statbuffer) <> 0;
       end
       else begin
        error:= false;
        statbuffer.st_mode:= dirent.d_type shl 12;
       end;
       with extinfo1,extinfo2,statbuffer do begin
        if not error then begin
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
          if d.needstype then begin
           system.include(state,fis_typevalid);
          end;
          if d.needsstat then begin
           state:= state + [fis_typevalid,fis_extinfo1valid,fis_extinfo2valid];
           size:= st_size;
           modtime:= filetimetodatetime(st_mtime,st_mtime_nsec);
           accesstime:= filetimetodatetime(st_atime,st_atime_nsec);
           ctime:= filetimetodatetime(st_ctime,st_ctime_nsec);
           id:= st_ino;
           owner:= st_uid;
           group:= st_gid;
          end;
          result:= true;
          break;
         end;
        end;
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

procedure stattofileinfo(const statbuffer: _stat64; var info: fileinfoty);
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
  state:= state + [fis_typevalid,fis_extinfo1valid,fis_extinfo2valid];
  size:= st_size;
  modtime:= filetimetodatetime(st_mtime,st_mtime_nsec);
  accesstime:= filetimetodatetime(st_atime,st_atime_nsec);
  ctime:= filetimetodatetime(st_ctime,st_ctime_nsec);
  id:= st_ino;
  owner:= st_uid;
  group:= st_gid;
 end;
end;

function sys_getfileinfo(const path: filenamety; var info: fileinfoty): boolean;
var
 str1: filenamety;
 statbuffer: _stat64;
begin
 clearfileinfo(info);
 str1:= tosysfilepath(path);
 fillchar(statbuffer,sizeof(statbuffer),0);
 result:= stat64(pchar(string(str1)),@statbuffer) = 0;
 if result then begin
  stattofileinfo(statbuffer,info);
  splitfilepath(filepath(path),str1,info.name);
 end;
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

procedure doinit;
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