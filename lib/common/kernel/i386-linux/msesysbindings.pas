{ MSEgui Copyright (c) 2008 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msesysbindings;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 {$ifdef FPC}cthreads,cwstring,{$endif}
  mselibc;

{$ifdef FPC}
const
 recursive = PTHREAD_MUTEX_RECURSIVE;
 libcmodulename = 'c';
{$endif}
const
 NR_sendfile = 187;
type
 tcondvar = array[0..47] of byte;

{$ifndef FPC}
type
 dword=longword;
  P_pthread_fastlock = ^_pthread_fastlock;
  _pthread_fastlock = record
    __status : longint;
    __spinlock : longint;
  end;

  P_pthread_descr = ^_pthread_descr;
  _pthread_descr = pointer; // Opaque type.

  P__pthread_attr_s = ^__pthread_attr_s;
  __pthread_attr_s = record
       __detachstate : longint;
       __schedpolicy : longint;
       __schedparam : __sched_param;
       __inheritsched : longint;
       __scope : longint;
       __guardsize : size_t;
       __stackaddr_set : longint;
       __stackaddr : pointer;
       __stacksize : size_t;
    end;
  pthread_attr_t = __pthread_attr_s;
  Ppthread_attr_t = ^pthread_attr_t;

  Ppthread_cond_t = ^pthread_cond_t;
  pthread_cond_t = record
       __c_lock : _pthread_fastlock;
       __c_waiting : _pthread_descr;
    end;

  Ppthread_condattr_t = ^pthread_condattr_t;
  pthread_condattr_t = record
       __dummy : longint;
    end;

  Ppthread_key_t = ^pthread_key_t;
  pthread_key_t = dword;

  Ppthread_mutex_t = ^pthread_mutex_t;
  pthread_mutex_t = record
       __m_reserved : longint;
       __m_count : longint;
       __m_owner : _pthread_descr;
       __m_kind : longint;
       __m_lock : _pthread_fastlock;
    end;

  Ppthread_mutexattr_t = ^pthread_mutexattr_t;
  pthread_mutexattr_t = record
       __mutexkind : longint;
    end;

  Ppthread_once_t = ^pthread_once_t;
  pthread_once_t = longint;

  P_pthread_rwlock_t = ^_pthread_rwlock_t;
  _pthread_rwlock_t = record
       __rw_lock : _pthread_fastlock;
       __rw_readers : longint;
       __rw_writer : _pthread_descr;
       __rw_read_waiting : _pthread_descr;
       __rw_write_waiting : _pthread_descr;
       __rw_kind : longint;
       __rw_pshared : longint;
    end;
  pthread_rwlock_t = _pthread_rwlock_t;
  Ppthread_rwlock_t = ^pthread_rwlock_t;

  Ppthread_rwlockattr_t = ^pthread_rwlockattr_t;
  pthread_rwlockattr_t = record
       __lockkind : longint;
       __pshared : longint;
    end;

  Ppthread_spinlock_t = ^pthread_spinlock_t;
  pthread_spinlock_t = longint;

  Ppthread_barrier_t = ^pthread_barrier_t;
  pthread_barrier_t = record
       __ba_lock : _pthread_fastlock;
       __ba_required : longint;
       __ba_present : longint;
       __ba_waiting : _pthread_descr;
    end;

  Ppthread_barrierattr_t = ^pthread_barrierattr_t;
  pthread_barrierattr_t = record
       __pshared : longint;
    end;

  Ppthread_t = ^pthread_t;
  pthread_t = dword;

  TStartRoutine = function (_para1:pointer): integer; cdecl;
   DIR = record end;
   __dirstream = DIR;
  PDIR = ^DIR;
  pdirectorystream = pdir;
   Ptm = ^tm;
   tm = record
        tm_sec : longint;
        tm_min : longint;
        tm_hour : longint;
        tm_mday : longint;
        tm_mon : longint;
        tm_year : longint;
        tm_wday : longint;
        tm_yday : longint;
        tm_isdst : longint;
        tm_gmtoff : longint;
        tm_zone : Pchar;
        __tm_gmtoff : longint;
        __tm_zone : Pchar;
     end;

  Paddrinfo = ^addrinfo;
  addrinfo = record
       ai_flags : longint;
       ai_family : longint;
       ai_socktype : longint;
       ai_protocol : longint;
       ai_addrlen : socklen_t;
       ai_addr : Psockaddr;
       ai_canonname : Pchar;
       ai_next : Paddrinfo;
    end;

 const
  threadslib = libpthreadmodulename;
  clib = libcmodulename;
{$endif}
 
function gettimeofday(__tv:Ptimeval; __tz:ptimezone):longint;cdecl;
                                           external clib name 'gettimeofday';
function  msetcgetattr(filedes: longint;
         var msetermios: termios{ty}): longint;cdecl;external clib name 'tcgetattr';
function  msetcsetattr(filedes: longint; when: longint;
         var msetermios: termios{ty}): longint;cdecl;external clib name 'tcsetattr';

function pthread_create(__thread:Ppthread_t; __attr:Ppthread_attr_t;
      __start_routine:TStartRoutine; __arg:pointer):longint;cdecl;
                        external threadslib name 'pthread_create';
function pthread_join(__th:pthread_t; __thread_return:Ppointer):longint;cdecl;
                        external threadslib name 'pthread_join';

function pthread_cond_init(var Cond: TCondVar;
          CondAttr: PPthreadCondattr): Integer; cdecl;
           external threadslib name 'pthread_cond_init';
function pthread_cond_destroy(var Cond: TCondVar): Integer; cdecl;
           external threadslib name 'pthread_cond_destroy';
function pthread_cond_wait(var Cond: TCondVar;
  var Mutex: pthread_mutex_t): Integer; cdecl;
           external threadslib name 'pthread_cond_wait';
function pthread_cond_timedwait(var Cond: TCondVar;
  var Mutex: pthread_mutex_t; AbsTime: pTimeSpec): Integer; cdecl;
           external threadslib name 'pthread_cond_timedwait';
function pthread_cond_broadcast(var Cond: TCondVar): Integer; cdecl;
           external threadslib name 'pthread_cond_broadcast';
function pthread_cond_signal(var Cond: TCondVar): Integer; cdecl;
           external threadslib name 'pthread_cond_signal';
function sem_timedwait(var __sem: TSemaphore; __abstime: ptimespec): Integer; cdecl;
            external threadslib name 'sem_timedwait';


function pthread_mutex_init(__mutex:Ppthread_mutex_t;
               __mutex_attr:Ppthread_mutexattr_t):longint;cdecl;
            external threadslib name 'pthread_mutex_init';
function pthread_mutex_destroy(var Mutex: pthread_mutex_t): Integer; cdecl;
            external threadslib name 'pthread_mutex_destroy';
function pthread_mutex_lock(var Mutex: pthread_mutex_t): Integer; cdecl;
            external threadslib name 'pthread_mutex_lock';
function pthread_mutex_trylock(var Mutex: pthread_mutex_t): Integer; cdecl;
            external threadslib name 'pthread_mutex_trylock';
function pthread_mutex_unlock(var Mutex: pthread_mutex_t): Integer; cdecl;
            external threadslib name 'pthread_mutex_unlock';

function readdir64_r(__dirp:PDIR; __entry:Pdirent64;
          __result:PPdirent64):longint;cdecl;external clib name 'readdir64_r';
function localtime_r(__timer:Ptime_t; __tp:Ptm):Ptm;cdecl;
            external clib name 'localtime_r';

implementation
end.
