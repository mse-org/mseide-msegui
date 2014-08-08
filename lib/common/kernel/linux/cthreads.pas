{
    This file is part of the Free Pascal run time library.
    Copyright (c) 2002 by Peter Vreman,
    member of the Free Pascal development team.

    pthreads threading support implementation

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

    Modified 2014 by Martin Schreiber
    
 **********************************************************************}
{$mode objfpc}
{$ifdef linux}

{ we can combine both compile-time linking and dynamic loading, in order to:
    a) solve a problem on some systems with dynamically loading libpthread if
       it's not linked at compile time
    b) still enabling dynamically checking whether or not certain functions
       are available (could also be implemented via weak linking)
}
{$linklib pthread}
{$define dynpthreads} // Useless on BSD, since they are in libc
{$endif}


{ sem_init is best, since it does not consume any file descriptors.    }
{ sem_open is second best, since it consumes only one file descriptor  }
{ per semaphore.                                                       }
{ If neither is available, pipe is used as fallback, which consumes 2  }
{ file descriptors per semaphore.                                      }

{ Darwin doesn't support nameless semaphores in at least }
{ Mac OS X 10.4.8/Darwin 8.8                             }
{$if not defined(darwin) and not defined(iphonesim)}
{$define has_sem_init}
{$define has_sem_getvalue}
{$else }
{$if defined(darwin) or defined(iphonesim)}
{$define has_sem_open}
{$endif}
{$endif}

{$ifdef linux}
{$define has_sem_timedwait}
{$endif}

unit cthreads;
interface
{$S-}

{$ifndef dynpthreads}   // If you have problems compiling this on FreeBSD 5.x
 {$linklib c}           // try adding -Xf
 {$if not defined(Darwin) and not defined(iphonesim)}
   {$ifndef haiku}
     {$linklib pthread}
   {$endif haiku}
 {$endif darwin}
{$endif}

{$define basicevents_with_pthread_cond}

Procedure SetCThreadManager;

implementation

Uses
  BaseUnix,
  unix,
  unixtype,
  initc
{$ifdef dynpthreads}
  ,dl
{$endif}
  ;

{*****************************************************************************
                             System unit import
*****************************************************************************}

procedure fpc_threaderror; [external name 'FPC_THREADERROR'];

{*****************************************************************************
                             Generic overloaded
*****************************************************************************}

{ Include OS specific parts. }
//{$i pthread.inc}

{$ifdef linux}
  { Attributes  }
  const
     THREAD_PRIORITY_IDLE               = 1;
     THREAD_PRIORITY_LOWEST             = 15;
     THREAD_PRIORITY_BELOW_NORMAL       = 30;
     THREAD_PRIORITY_NORMAL             = 50;
     THREAD_PRIORITY_ABOVE_NORMAL       = 70;
     THREAD_PRIORITY_HIGHEST            = 80;
     THREAD_PRIORITY_TIME_CRITICAL      = 99;
//     PTHREAD_RECURSIVE_MUTEX_INITIALIZER_NP : array [0..5]of Integer = (0, 0, 0, 1, 0, 0);

Type
   psem_t = ^sem_t;
   TSemaphore = sem_t;
   PSemaphore = ^TSemaphore;

{$ifndef FPC_USE_LIBC}
   tlibc_sigset = array[0..(1024 div 32)-1] of cuLong;
   plibc_sigset = ^tlibc_sigset;
{$else not FPC_USE_LIBC}
   tlibc_sigset = tsigset;
   plibc_sigset = psigset;
{$endif not FPC_USE_LIBC}

     TThreadPriority = (tpIdle, tpLowest, tpLower, tpNormal, tpHigher, tpHighest, tpTimeCritical);
{
  const
     Priorities: array [TThreadPriority] of Integer = (
       THREAD_PRIORITY_IDLE, THREAD_PRIORITY_LOWEST, THREAD_PRIORITY_BELOW_NORMAL,
       THREAD_PRIORITY_NORMAL, THREAD_PRIORITY_ABOVE_NORMAL,
       THREAD_PRIORITY_HIGHEST, THREAD_PRIORITY_TIME_CRITICAL
     );
}
  const
     _POSIX_THREAD_THREADS_MAX = 64;
     PTHREAD_THREADS_MAX = 512;
     _POSIX_THREAD_KEYS_MAX = 128;
     PTHREAD_KEYS_MAX = 128;

  type
    ppthread_t = ^pthread_t;
{
     p_pthread_queue = ^_pthread_queue;
}
     ppthread_mutex_t = ^pthread_mutex_t;

     ppthread_cond_t = ^pthread_cond_t;

     { Attributes  }

    const
      PTHREAD_CREATE_JOINABLE = 0;
      PTHREAD_CREATE_DETACHED = 1;
      PTHREAD_INHERIT_SCHED   = 0;
      PTHREAD_EXPLICIT_SCHED  = 1;
      PTHREAD_SCOPE_SYSTEM    = 0;
      PTHREAD_SCOPE_PROCESS   = 1;

    type
       psched_param = ^sched_param;

       ppthread_attr_t = ^pthread_attr_t;

       ppthread_mutexattr_t = ^pthread_mutexattr_t;

       ppthread_condattr_t = ^pthread_condattr_t;

       ppthread_key_t = ^pthread_key_t;

{      pthread_once_t = cint;
       ppthread_once_t = ^pthread_once_t;}

    const
       PTHREAD_ONCE_INIT = 0;

    type
(*
       tpcb_routine = Procedure(P:Pointer); cdecl;

       p_pthread_cleanup_buffer = ^_pthread_cleanup_buffer;
       _pthread_cleanup_buffer = record
          routine : tpcb_routine;             { Function to call. }
          arg : Pointer;                      { Its argument.  }
          canceltype:LongInt;                 { Saved cancellation type. }
          prev : p_pthread_cleanup_buffer; { Chaining of cleanup functions.  }
       end;
*)

     __start_routine_t = function (_para1:pointer):pointer;cdecl;
     __destr_function_t = procedure (_para1:pointer);cdecl;
{     t_pthread_cleanup_push_routine = procedure (_para1:pointer);
     t_pthread_cleanup_push_defer_routine = procedure (_para1:pointer);}

    function pthread_create(__thread:ppthread_t; __attr:ppthread_attr_t;__start_routine: __start_routine_t;__arg:pointer):longint;cdecl;external;
    function pthread_self:pthread_t;cdecl;external;
    function pthread_equal(__thread1:pthread_t; __thread2:pthread_t):longint;cdecl;external;
    procedure pthread_exit(__retval:pointer);cdecl;external;
    function pthread_join(__th:pthread_t; __thread_return:ppointer):longint;cdecl;external;
    function pthread_detach(__th:pthread_t):longint;cdecl;external;
    function pthread_attr_init(__attr:ppthread_attr_t):longint;cdecl;external;
    function pthread_attr_destroy(__attr:ppthread_attr_t):longint;cdecl;external;
    function pthread_attr_setdetachstate(__attr:ppthread_attr_t; __detachstate:longint):longint;cdecl;external;
    function pthread_attr_getdetachstate(__attr:ppthread_attr_t; __detachstate:plongint):longint;cdecl;external;
    function pthread_attr_setschedparam(__attr:ppthread_attr_t; __param:psched_param):longint;cdecl;external;
    function pthread_attr_getschedparam(__attr:ppthread_attr_t; __param:psched_param):longint;cdecl;external;
    function pthread_attr_setschedpolicy(__attr:ppthread_attr_t; __policy:longint):longint;cdecl;external;
    function pthread_attr_getschedpolicy(__attr:ppthread_attr_t; __policy:plongint):longint;cdecl;external;
    function pthread_attr_setinheritsched(__attr:ppthread_attr_t; __inherit:longint):longint;cdecl;external;
    function pthread_attr_getinheritsched(__attr:ppthread_attr_t; __inherit:plongint):longint;cdecl;external;
    function pthread_attr_setstacksize(p: ppthread_attr_t;s:size_t):cint;cdecl;external;
    function pthread_attr_getstacksize(p: ppthread_attr_t;s:psize_t):cint;cdecl;external;
    function pthread_attr_setscope(__attr:ppthread_attr_t; __scope:longint):longint;cdecl;external;
    function pthread_attr_getscope(__attr:ppthread_attr_t; __scope:plongint):longint;cdecl;external;
    function pthread_setschedparam(__target_thread:pthread_t; __policy:longint; __param:psched_param):longint;cdecl;external;
    function pthread_getschedparam(__target_thread:pthread_t; __policy:plongint; __param:psched_param):longint;cdecl;external;
    function pthread_mutex_init(__mutex:ppthread_mutex_t; __mutex_attr:ppthread_mutexattr_t):longint;cdecl;external;
    function pthread_mutex_destroy(__mutex:ppthread_mutex_t):longint;cdecl;external;
    function pthread_mutex_trylock(__mutex:ppthread_mutex_t):longint;cdecl;external;
    function pthread_mutex_lock(__mutex:ppthread_mutex_t):longint;cdecl;external;
    function pthread_mutex_unlock(__mutex:ppthread_mutex_t):longint;cdecl;external;
    function pthread_mutexattr_init(__attr:ppthread_mutexattr_t):longint;cdecl;external;
    function pthread_mutexattr_destroy(__attr:ppthread_mutexattr_t):longint;cdecl;external;
    function pthread_mutexattr_setkind_np(__attr:ppthread_mutexattr_t; __kind:longint):longint;cdecl;external;
    function pthread_mutexattr_getkind_np(__attr:ppthread_mutexattr_t; __kind:plongint):longint;cdecl;external;
    function pthread_cond_init(__cond:ppthread_cond_t; __cond_attr:ppthread_condattr_t):longint;cdecl;external;
    function pthread_cond_destroy(__cond:ppthread_cond_t):longint;cdecl;external;
    function pthread_cond_signal(__cond:ppthread_cond_t):longint;cdecl;external;
    function pthread_cond_broadcast(__cond:ppthread_cond_t):longint;cdecl;external;
    function pthread_cond_wait(__cond:ppthread_cond_t; __mutex:ppthread_mutex_t):longint;cdecl;external;
    function pthread_cond_timedwait(__cond:ppthread_cond_t; __mutex:ppthread_mutex_t; __abstime:ptimespec):longint;cdecl;external;
    function pthread_condattr_init(__attr:ppthread_condattr_t):longint;cdecl;external;
    function pthread_condattr_destroy(__attr:ppthread_condattr_t):longint;cdecl;external;
    function pthread_key_create(__key:ppthread_key_t; __destr_function:__destr_function_t):longint;cdecl;external;
    function pthread_key_delete(__key:pthread_key_t):longint;cdecl;external;
    function pthread_setspecific(__key:pthread_key_t; __pointer:pointer):longint;cdecl;external;
    function pthread_getspecific(__key:pthread_key_t):pointer;cdecl;external;
{    function pthread_once(__once_control:ppthread_once_t; __init_routine:tprocedure ):longint;cdecl;external;}
    function pthread_setcancelstate(__state:longint; __oldstate:plongint):longint;cdecl;external;
    function pthread_setcanceltype(__type:longint; __oldtype:plongint):longint;cdecl;external;
    function pthread_cancel(__thread:pthread_t):longint;cdecl;external;
    procedure pthread_testcancel;cdecl;external;
{    procedure _pthread_cleanup_push(__buffer:p_pthread_cleanup_buffer;__routine:t_pthread_cleanup_push_routine; __arg:pointer);cdecl;external; }
{    procedure _pthread_cleanup_push_defer(__buffer:p_pthread_cleanup_buffer;__routine:t_pthread_cleanup_push_defer_routine; __arg:pointer);cdecl;external;}
{    function pthread_sigmask(__how:longint; __newmask:plibc_sigset; __oldmask:plibc_sigset):longint;cdecl;external;}
    function pthread_kill(__thread:pthread_t; __signo:longint):longint;cdecl;external;
{    function sigwait(__set:plibc_sigset; __sig:plongint):longint;cdecl;external;}
    function pthread_atfork(__prepare:tprocedure ; __parent:tprocedure ; __child:tprocedure ):longint;cdecl;external;
    procedure pthread_kill_other_threads_np;cdecl;external;
    function pthread_sigmask(how: cint; nset: plibc_sigset; oset: plibc_sigset): cint; cdecl; external;

    function sem_init (__sem:Psem_t; __pshared:longint; __value:dword):longint;cdecl;external;
    function sem_destroy  (__sem:Psem_t):longint;cdecl;external;
    function sem_close (__sem:Psem_t):longint;cdecl;external;
    function sem_unlink (__name:Pchar):longint;cdecl;external;
    function sem_wait (__sem:Psem_t):longint;cdecl;external;
    function sem_timedwait (__sem:Psem_t; __abs_timeout:ptimespec):longint;cdecl;external;
    function sem_trywait  (__sem:Psem_t):longint;cdecl;external;
    function sem_post     (__sem:Psem_t):longint;cdecl;external;
    function sem_getvalue (__sem:Psem_t; __sval:Plongint):longint;cdecl;external;

    function pthread_mutexattr_settype (__attr: Ppthread_mutexattr_t; Kind:Integer): Integer; cdecl;external;
{$else} //freebsd
CONST PTHREAD_EXPLICIT_SCHED       = 0;
      PTHREAD_CREATE_DETACHED      = 1;
      PTHREAD_SCOPE_PROCESS        = 0;
      SEM_SAFE = 255;

 TYPE
    ppthread_t      = ^pthread_t;
    ppthread_key_t  = ^pthread_key_t;
    ppthread_mutex_t= ^pthread_mutex_t;
    ppthread_attr_t = ^pthread_attr_t;
    ppthread_cond_t            = ^pthread_cond_t;
    ppthread_condattr_t        = ^pthread_condattr_t;

    __destr_func_t  = procedure (p :pointer);cdecl;
    __startroutine_t= function (p :pointer):pointer;cdecl;
    ppthread_mutexattr_t = ^pthread_mutexattr_t;
    ppthread_mutex_attr_t = ^pthread_mutexattr_t;

{
  From FreeBSD 8.2 sys/_semaphore.h
}

(*
struct sem {
#define SEM_MAGIC       ((u_int32_t) 0x09fa4012)
        u_int32_t       magic;
        pthread_mutex_t lock;
        pthread_cond_t  gtzero;
        u_int32_t       count;
        u_int32_t       nwaiters;
#define SEM_USER        (NULL)
        semid_t         semid;  /* semaphore id if kernel (shared) semaphore */
        int             syssem; /* 1 if kernel (shared) semaphore */
        LIST_ENTRY(sem) entry;
        struct sem      **backpointer;
}; *)
    semid_t        = pointer;
    psem_t         = ^sem_t;
    ppsem_t        = ^psem_t;
    sem_t = record
       magic   : cuint32;
       lock    : pthread_mutex_t;
       gtzero  : pthread_cond_t;
       count   : cuint32;
       nwaiters: cuint32;
       semid   : semid_t;
       sysse   : cint;
       entry   : psem_t;
       backpointer : ppsem_t;
       spare   : array[0..SEM_SAFE] of char;

    end;

    TSemaphore         = sem_t;
    PSemaphore         = ^TSemaphore;

function  pthread_getspecific      (t : pthread_key_t):pointer; cdecl; external;
function  pthread_setspecific      (t : pthread_key_t;p:pointer):cint; cdecl; external;
function  pthread_key_create       (p : ppthread_key_t;f: __destr_func_t):cint; cdecl;external;
function  pthread_attr_init           (p : ppthread_attr_t):cint; cdecl; external;
function  pthread_attr_setinheritsched(p : ppthread_attr_t;i:cint):cint; cdecl; external;
function  pthread_attr_setscope      (p : ppthread_attr_t;i:cint):cint;cdecl;external;
function  pthread_attr_setdetachstate (p : ppthread_attr_t;i:cint):cint;cdecl;external;
function  pthread_attr_setstacksize(p: ppthread_attr_t; stacksize: size_t):cint;cdecl;external;
function  pthread_create ( p: ppthread_t;attr : ppthread_attr_t;f:__startroutine_t;arg:pointer):cint;cdecl;external;
procedure pthread_exit  ( p: pointer); cdecl;external;
function  pthread_self:pthread_t; cdecl;external;
function  pthread_mutex_init (p:ppthread_mutex_t;o:ppthread_mutex_attr_t):cint; cdecl;external;
function  pthread_mutex_destroy (p:ppthread_mutex_attr_t):cint; cdecl;external;
function  pthread_mutex_lock    (p:ppthread_mutex_attr_t):cint; cdecl;external;
function  pthread_mutex_trylock    (p:ppthread_mutex_attr_t):cint; cdecl;external;
function  pthread_mutex_unlock  (p:ppthread_mutex_attr_t):cint; cdecl;external;
function  pthread_cancel(_para1:pthread_t):cint;cdecl;external;
function  pthread_detach(_para1:pthread_t):cint;cdecl;external;
function  pthread_join(_para1:pthread_t; _para2:Ppointer):cint;cdecl;external;
function pthread_cond_destroy(_para1:Ppthread_cond_t):cint;cdecl;external;
function pthread_cond_init(_para1:Ppthread_cond_t;_para2:Ppthread_condattr_t):cint;cdecl;external;
function pthread_cond_signal(_para1:Ppthread_cond_t):cint;cdecl;external;
function pthread_cond_broadcast(_para1:Ppthread_cond_t):cint;cdecl;external;
function pthread_cond_wait(_para1:Ppthread_cond_t;_para2:Ppthread_mutex_t):cint;cdecl;external;
function pthread_kill(__thread:pthread_t; __signo:cint):cint;cdecl;external;
function pthread_sigmask(how: cint; nset: psigset; oset: psigset): cint; cdecl; external;

function sem_init(__sem:Psem_t; __pshared:cint;__value:dword):cint;cdecl; external;
function sem_destroy(__sem:Psem_t):cint;cdecl;external ;
function sem_close(__sem:Psem_t):cint;cdecl;external ;
function sem_unlink(__name:Pchar):cint;cdecl;external ;
function sem_wait(__sem:Psem_t):cint;cdecl;external ;
function sem_trywait(__sem:Psem_t):cint;cdecl;external ;
function sem_post(__sem:Psem_t):cint;cdecl;external ;
function sem_getvalue(__sem:Psem_t; __sval:Pcint):cint;cdecl;external;
function pthread_mutexattr_init(_para1:Ppthread_mutexattr_t):cint;cdecl;external;
function pthread_mutexattr_destroy(_para1:Ppthread_mutexattr_t):cint;cdecl;external;
function pthread_mutexattr_gettype(_para1:Ppthread_mutexattr_t; _para2:Pcint):cint;cdecl;external;
function pthread_mutexattr_settype(_para1:Ppthread_mutexattr_t; _para2:cint):cint;cdecl;external;
function pthread_cond_timedwait(__cond:ppthread_cond_t; __mutex:ppthread_mutex_t; __abstime:ptimespec):longint;cdecl;external;

{$endif}

Type  PINTRTLEvent = ^TINTRTLEvent;
      TINTRTLEvent = record
        condvar: pthread_cond_t;
        mutex: pthread_mutex_t;
        isset: boolean;
       end;

      TTryWaitResult = (tw_error, tw_semwasunlocked, tw_semwaslocked);

{*****************************************************************************
                             Threadvar support
*****************************************************************************}

    const
      threadvarblocksize : dword = 0;


    var
      TLSKey,
      CleanupKey : pthread_key_t;

    procedure CInitThreadvar(var offset : dword;size : dword);
      begin
        {$ifdef cpusparc}
        threadvarblocksize:=align(threadvarblocksize,16);
        {$endif cpusparc}

        {$ifdef cpupowerpc}
        threadvarblocksize:=align(threadvarblocksize,8);
        {$endif cpupowerc}

        {$ifdef cpui386}
        threadvarblocksize:=align(threadvarblocksize,8);
        {$endif cpui386}

        {$ifdef cpuarm}
        threadvarblocksize:=align(threadvarblocksize,4);
        {$endif cpuarm}

        {$ifdef cpum68k}
        threadvarblocksize:=align(threadvarblocksize,2);
        {$endif cpum68k}

        {$ifdef cpux86_64}
        threadvarblocksize:=align(threadvarblocksize,16);
        {$endif cpux86_64}

        {$ifdef cpupowerpc64}
        threadvarblocksize:=align(threadvarblocksize,16);
        {$endif cpupowerpc64}

        offset:=threadvarblocksize;

        inc(threadvarblocksize,size);
      end;



    procedure CAllocateThreadVars;
      var
        dataindex : pointer;
      begin
        { we've to allocate the memory from system  }
        { because the FPC heap management uses      }
        { exceptions which use threadvars but       }
        { these aren't allocated yet ...            }
        { allocate room on the heap for the thread vars }
        DataIndex:=Pointer(Fpmmap(nil,threadvarblocksize,3,MAP_PRIVATE+MAP_ANONYMOUS,-1,0));
        FillChar(DataIndex^,threadvarblocksize,0);
        pthread_setspecific(tlskey,dataindex);
      end;


    procedure CthreadCleanup(p: pointer); cdecl;
    {$ifdef DEBUG_MT}
      var
        s: string[100]; // not an ansistring
{$endif DEBUG_MT}
      begin
{$ifdef DEBUG_MT}
        s := 'finishing externally started thread'#10;
        fpwrite(0,s[1],length(s));
{$endif DEBUG_MT}
        { clean up }
        DoneThread;
        { the pthread routine that calls us is supposed to do this, but doesn't
          at least on Mac OS X 10.6 }
        pthread_setspecific(CleanupKey,nil);
      end;


    procedure HookThread;
      begin
        { Allocate local thread vars, this must be the first thing,
          because the exception management and io depends on threadvars }
        CAllocateThreadVars;
        { we cannot know the stack size of the current thread, so pretend it
          is really large to prevent spurious stack overflow errors }
        InitThread(1000000000);
        { instruct the pthreads system to clean up this thread when it exits }
        pthread_setspecific(CleanupKey,pointer(1));
      end;


    function CRelocateThreadvar(offset : dword) : pointer;
      var
        P : Pointer;
      begin
        P:=pthread_getspecific(tlskey);
        { a thread which we did not create? }
        if (P=Nil) then
          begin
            HookThread;
            // If this also goes wrong: bye bye threadvars...
            P:=pthread_getspecific(tlskey);
          end;
        CRelocateThreadvar:=P+Offset;
      end;


    procedure CReleaseThreadVars;
      begin
        Fpmunmap(pointer(pthread_getspecific(tlskey)),threadvarblocksize);
      end;

{ Include OS independent Threadvar initialization }



{*****************************************************************************
                            Thread starting
*****************************************************************************}

    type
      pthreadinfo = ^tthreadinfo;
      tthreadinfo = record
        f : tthreadfunc;
        p : pointer;
        stklen : cardinal;
      end;

    function ThreadMain(param : pointer) : pointer;cdecl;
      var
        ti : tthreadinfo;
//        nset: tsigset;
{$if defined(linux) and not defined(FPC_USE_LIBC)}
//        nlibcset: tlibc_sigset;
{$endif linux/no FPC_USE_LIBC}
{$ifdef DEBUG_MT}
        // in here, don't use write/writeln before having called
        // InitThread! I wonder if anyone ever debugged these routines,
        // because they will have crashed if DEBUG_MT was enabled!
        // this took me the good part of an hour to figure out
        // why it was crashing all the time!
        // this is kind of a workaround, we simply write(2) to fd 0
        s: string[100]; // not an ansistring
{$endif DEBUG_MT}
      begin
{$ifdef DEBUG_MT}
        s := 'New thread started, initing threadvars'#10;
        fpwrite(0,s[1],length(s));
{$endif DEBUG_MT}
(* mse: do not change signal blocking, user must have full control because signals
   should be sent to main thread only for example
   
        { unblock all signals we are interested in (may be blocked by }
        { default in new threads on some OSes, see #9073)             }
        fpsigemptyset(nset);
        fpsigaddset(nset,SIGSEGV);
        fpsigaddset(nset,SIGBUS);
        fpsigaddset(nset,SIGFPE);
        fpsigaddset(nset,SIGILL);
{$if defined(linux) and not defined(FPC_USE_LIBC)}
        { sigset_t has a different size for linux/kernel and linux/libc }
        fillchar(nlibcset,sizeof(nlibcset),0);
        if (sizeof(nlibcset)>sizeof(nset)) then
          move(nset,nlibcset,sizeof(nset))
        else
          move(nset,nlibcset,sizeof(nlibcset));
        pthread_sigmask(SIG_UNBLOCK,@nlibcset,nil);
{$else linux}
        pthread_sigmask(SIG_UNBLOCK,@nset,nil);
{$endif linux}
*)
        { Allocate local thread vars, this must be the first thing,
          because the exception management and io depends on threadvars }
        CAllocateThreadVars;
        { Copy parameter to local data }
{$ifdef DEBUG_MT}
        s := 'New thread started, initialising ...'#10;
        fpwrite(0,s[1],length(s));
{$endif DEBUG_MT}
        ti:=pthreadinfo(param)^;
        dispose(pthreadinfo(param));
        { Initialize thread }
        InitThread(ti.stklen);
        { Start thread function }
{$ifdef DEBUG_MT}
        writeln('Jumping to thread function');
{$endif DEBUG_MT}
        ThreadMain:=pointer(ti.f(ti.p));
        DoneThread;
        pthread_exit(ThreadMain);
      end;


  function CBeginThread(sa : Pointer;stacksize : PtrUInt;
                       ThreadFunction : tthreadfunc;p : pointer;
                       creationFlags : dword; var ThreadId : TThreadId) : TThreadID;
    var
      ti : pthreadinfo;
      thread_attr : pthread_attr_t;
    begin
{$ifdef DEBUG_MT}
      writeln('Creating new thread');
{$endif DEBUG_MT}
      { Initialize multithreading if not done }
      if not IsMultiThread then
        begin
          if (InterLockedExchange(longint(IsMultiThread),ord(true)) = 0) then
            begin
              { We're still running in single thread mode, setup the TLS }
              pthread_key_create(@TLSKey,nil);
              InitThreadVars(@CRelocateThreadvar);
              { used to clean up threads that we did not create ourselves:
                 a) the default value for a key (and hence also this one) in
                    new threads is NULL, and if it's still like that when the
                    thread terminates, nothing will happen
                 b) if it's non-NULL, the destructor routine will be called
                    when the thread terminates
               -> we will set it to 1 if the threadvar relocation routine is
                  called from a thread we did not create, so that we can
                  clean up everything at the end }
              pthread_key_create(@CleanupKey,@CthreadCleanup);
            end
        end;
      { the only way to pass data to the newly created thread
        in a MT safe way, is to use the heap }
      new(ti);
      ti^.f:=ThreadFunction;
      ti^.p:=p;
      ti^.stklen:=stacksize;
      { call pthread_create }
{$ifdef DEBUG_MT}
      writeln('Starting new thread');
{$endif DEBUG_MT}
      pthread_attr_init(@thread_attr);
      {$ifndef HAIKU}
      {$ifdef solaris}
      pthread_attr_setinheritsched(@thread_attr, PTHREAD_INHERIT_SCHED);
      {$else not solaris}
      pthread_attr_setinheritsched(@thread_attr, PTHREAD_EXPLICIT_SCHED);
      {$endif not solaris}
      {$endif}

      // will fail under linux -- apparently unimplemented
      pthread_attr_setscope(@thread_attr, PTHREAD_SCOPE_PROCESS);

      // don't create detached, we need to be able to join (waitfor) on
      // the newly created thread!
      //pthread_attr_setdetachstate(@thread_attr, PTHREAD_CREATE_DETACHED);

      // set the stack size
      if (pthread_attr_setstacksize(@thread_attr, stacksize)<>0) or
         // and create the thread
         (pthread_create(ppthread_t(@threadid), @thread_attr, @ThreadMain,ti) <> 0) then

        begin
          dispose(ti);
          threadid := TThreadID(0);
        end;
      CBeginThread:=threadid;
{$ifdef DEBUG_MT}
      writeln('BeginThread returning ',ptrint(CBeginThread));
{$endif DEBUG_MT}
    end;


  procedure CEndThread(ExitCode : DWord);
    begin
      DoneThread;
      pthread_detach(pthread_t(pthread_self()));
      pthread_exit(pointer(ptrint(ExitCode)));
    end;



  function  CSuspendThread (threadHandle : TThreadID) : dword;
    begin
    {  pthread_kill(SIGSTOP) cannot be used, because posix-compliant
       implementations then freeze the entire process instead of only
       the target thread. Suspending a particular thread is not
       supported by posix nor by most *nix implementations, presumably
       because of concerns mentioned in E.4 at
       http://pauillac.inria.fr/~xleroy/linuxthreads/faq.html#E and in
       http://java.sun.com/j2se/1.4.2/docs/guide/misc/threadPrimitiveDeprecation.html
    }
//      result := pthread_kill(threadHandle,SIGSTOP);
      result:=dword(-1);
    end;


  function  CResumeThread  (threadHandle : TThreadID) : dword;
    begin
//      result := pthread_kill(threadHandle,SIGCONT);
      result:=dword(-1);
    end;


  procedure sched_yield; cdecl; external 'c' name 'sched_yield';

  procedure CThreadSwitch;  {give time to other threads}
    begin
      { At least on Mac OS X, the pthread_yield_np calls through to this. }
      { Further, sched_yield is in POSIX and supported on FreeBSD 4+,     }
      { Linux, Mac OS X and Solaris, while the thread-specific yield      }
      { routines are called differently everywhere and non-standard.      }
      sched_yield;
    end;


  function  CKillThread (threadHandle : TThreadID) : dword;
    begin
      pthread_detach(pthread_t(threadHandle));
      CKillThread := pthread_cancel(pthread_t(threadHandle));
    end;

  function CCloseThread (threadHandle : TThreadID) : dword;
    begin
      result:=0;
    end;

  function  CWaitForThreadTerminate (threadHandle : TThreadID; TimeoutMs : longint) : dword;  {0=no timeout}
    var
      LResultP: Pointer;
    begin
      pthread_join(pthread_t(threadHandle), @LResultP);
      CWaitForThreadTerminate := dword(ptruint(LResultP));
    end;

    function  CThreadSetPriority (threadHandle : TThreadID; Prio: longint): boolean; {-15..+15, 0=normal}
    begin
//      {$Warning ThreadSetPriority needs to be implemented}
      result:=false;
    end;


  function  CThreadGetPriority (threadHandle : TThreadID): Integer;
    begin
//      {$Warning ThreadGetPriority needs to be implemented}
      result:=0;
    end;


  function  CGetCurrentThreadId : TThreadID;
    begin
      CGetCurrentThreadId := TThreadID (pthread_self());
    end;


{*****************************************************************************
                          Delphi/Win32 compatibility
*****************************************************************************}

    procedure CInitCriticalSection(var CS);

    var
      MAttr : pthread_mutexattr_t;
      res: longint;
    begin
      res:=pthread_mutexattr_init(@MAttr);
      if res=0 then
        begin
          res:=pthread_mutexattr_settype(@MAttr,longint(_PTHREAD_MUTEX_RECURSIVE));
          if res=0 then
            res := pthread_mutex_init(@CS,@MAttr)
          else
            { No recursive mutex support :/ }
            res := pthread_mutex_init(@CS,NIL);
        end
      else
        res:= pthread_mutex_init(@CS,NIL);
      pthread_mutexattr_destroy(@MAttr);
      if res <> 0 then
        fpc_threaderror;
    end;

    procedure CEnterCriticalSection(var CS);
      begin
         if pthread_mutex_lock(@CS) <> 0 then
           fpc_threaderror
      end;

    function CTryEnterCriticalSection(var CS):longint;
      begin
         if pthread_mutex_Trylock(@CS)=0 then
           result:=1  // succes
         else
           result:=0; // failure
      end;

    procedure CLeaveCriticalSection(var CS);
      begin
         if pthread_mutex_unlock(@CS) <> 0 then
           fpc_threaderror
      end;

    procedure CDoneCriticalSection(var CS);
      begin
         { unlock as long as unlocking works to unlock it if it is recursive
           some Delphi code might call this function with a locked mutex      }
         while pthread_mutex_unlock(@CS)=0 do
           ;

         if pthread_mutex_destroy(@CS) <> 0 then
           fpc_threaderror;
      end;


{*****************************************************************************
                           Semaphore routines
*****************************************************************************}
  
procedure cSemaphoreWait(const FSem: Pointer);
var
  res: cint;
  err: cint;
{$if not defined(has_sem_init) and not defined(has_sem_open)}
  b: byte;
{$endif}
begin
{$if defined(has_sem_init) or defined(has_sem_open)}
  repeat
    res:=sem_wait(PSemaphore(FSem));
    err:=fpgetCerrno;
  until (res<>-1) or (err<>ESysEINTR);
{$else}
  repeat
    res:=fpread(PFilDes(FSem)^[0], b, 1);
    err:=fpgeterrno;
  until (res<>-1) or ((err<>ESysEINTR) and (err<>ESysEAgain));
{$endif}
end;

{$if defined(has_sem_timedwait)}

function cSemaphoreTimedWait(const FSem: Pointer; const Timeout: ttimespec): cint;
var
  res: cint;
  err: cint;
begin
  repeat
    res:=sem_timedwait(PSemaphore(FSem), @Timeout);
    if res=0 then exit(0);
    err:=fpgetCerrno;
  until err<>ESysEINTR;
  result:=err;
end;

{$endif}

procedure cSemaphorePost(const FSem: Pointer);
{$if defined(has_sem_init) or defined(has_sem_open)}
begin
  sem_post(PSemaphore(FSem));
end;
{$else}
var
  writeres: cint;
  err: cint;
  b : byte;
begin
  b:=0;
  repeat
    writeres:=fpwrite(PFilDes(FSem)^[1], b, 1);
    err:=fpgeterrno;
  until (writeres<>-1) or ((err<>ESysEINTR) and (err<>ESysEAgain));
end;
{$endif}


function cSemaphoreTryWait(const FSem: pointer): TTryWaitResult;
var
  res: cint;
  err: cint;
{$if defined(has_sem_init) or defined(has_sem_open)}
begin
  repeat
    res:=sem_trywait(FSem);
    err:=fpgetCerrno;
  until (res<>-1) or (err<>ESysEINTR);
  if (res=0) then
    result:=tw_semwasunlocked
  else if (err=ESysEAgain) then
    result:=tw_semwaslocked
  else
    result:=tw_error;
{$else has_sem_init or has_sem_open}
var
  fds: TFDSet;
  tv : timeval;
begin
  tv.tv_sec:=0;
  tv.tv_usec:=0;
  fpFD_ZERO(fds);
  fpFD_SET(PFilDes(FSem)^[0],fds);
  repeat
    res:=fpselect(PFilDes(FSem)^[0]+1,@fds,nil,nil,@tv);
    err:=fpgeterrno;
  until (res>=0) or ((res=-1) and (err<>ESysEIntr));
  if (res>0) then
    begin
      cSemaphoreWait(FSem);
      result:=tw_semwasunlocked
    end
  else if (res=0) then
    result:=tw_semwaslocked
  else
    result:=tw_error;
{$endif has_sem_init or has_sem_open}
end;




{$if defined(has_sem_open) and not defined(has_sem_init)}
function cIntSemaphoreOpen(const name: pchar; initvalue: boolean): Pointer;
var
  err: cint;
begin
  repeat
    cIntSemaphoreOpen := sem_open(name,O_CREAT,0,ord(initvalue));
    err:=fpgetCerrno;
  until (ptrint(cIntSemaphoreOpen) <> SEM_FAILED) or (err <> ESysEINTR);
  if (ptrint(cIntSemaphoreOpen) <> SEM_FAILED) then
    { immediately unlink so the semaphore will be destroyed when the }
    { the process exits                                              }
    sem_unlink(name)
  else
    cIntSemaphoreOpen:=NIL;
end;
{$endif}


function cIntSemaphoreInit(initvalue: boolean): Pointer;
{$if defined(has_sem_open) and not defined(has_sem_init)}
var
  tid: string[31];
  semname: string[63];
{$endif}
begin
{$ifdef has_sem_init}
  cIntSemaphoreInit := GetMem(SizeOf(TSemaphore));
  if sem_init(PSemaphore(cIntSemaphoreInit), 0, ord(initvalue)) <> 0 then
    begin
      FreeMem(cIntSemaphoreInit);
      cIntSemaphoreInit:=NIL;
    end;
{$else}
{$ifdef has_sem_open}
  { avoid a potential temporary nameclash with another process/thread }
  str(fpGetPid,semname);
  str(ptruint(pthread_self()),tid);
  semname:='/FPC'+semname+'T'+tid+#0;
  cIntSemaphoreInit:=cIntSemaphoreOpen(@semname[1],initvalue);
{$else}
  cIntSemaphoreInit := GetMem(SizeOf(TFilDes));
  if (fppipe(PFilDes(cIntSemaphoreInit)^) <> 0) then
    begin
      FreeMem(cIntSemaphoreInit);
      cIntSemaphoreInit:=nil;
    end
  else if initvalue then
    cSemaphorePost(cIntSemaphoreInit);
{$endif}
{$endif}
end;


function cSemaphoreInit: Pointer;
begin
  cSemaphoreInit:=cIntSemaphoreInit(false);
end;


procedure cSemaphoreDestroy(const FSem: Pointer);
begin
{$ifdef has_sem_init}
  sem_destroy(PSemaphore(FSem));
  FreeMem(FSem);
{$else}
{$ifdef has_sem_open}
  sem_close(PSemaphore(FSem));
{$else has_sem_init}
  fpclose(PFilDes(FSem)^[0]);
  fpclose(PFilDes(FSem)^[1]);
  FreeMem(FSem);
{$endif}
{$endif}
end;


type
     TPthreadCondition = pthread_cond_t;
     TPthreadMutex = pthread_mutex_t;
     Tbasiceventstate=record
         FCondVar: TPthreadCondition;
         FEventSection: TPthreadMutex;
         FWaiters: longint;
         FIsSet,
         FManualReset,
         FDestroying : Boolean;
        end;
     plocaleventstate = ^tbasiceventstate;
//     peventstate=pointer;

Const
        wrSignaled = 0;
        wrTimeout  = 1;
        wrAbandoned= 2;
        wrError    = 3;

function IntBasicEventCreate(EventAttributes : Pointer; AManualReset,InitialState : Boolean;const Name : ansistring):pEventState;
var
  MAttr : pthread_mutexattr_t;
  res   : cint;
begin
  new(plocaleventstate(result));
  plocaleventstate(result)^.FManualReset:=AManualReset;
  plocaleventstate(result)^.FWaiters:=0;
  plocaleventstate(result)^.FDestroying:=False;
  plocaleventstate(result)^.FIsSet:=InitialState;
  res := pthread_cond_init(@plocaleventstate(result)^.FCondVar, nil);
  if (res <> 0) then
  begin
    FreeMem(result);
    fpc_threaderror;
  end;

  res:=pthread_mutexattr_init(@MAttr);
  if res=0 then
    begin
      res:=pthread_mutexattr_settype(@MAttr,longint(_PTHREAD_MUTEX_RECURSIVE));
      if Res=0 then
        Res:=pthread_mutex_init(@plocaleventstate(result)^.feventsection,@MAttr)
      else
        res:=pthread_mutex_init(@plocaleventstate(result)^.feventsection,nil);
    end
  else
    res:=pthread_mutex_init(@plocaleventstate(result)^.feventsection,nil);

  pthread_mutexattr_destroy(@MAttr);
  if res <> 0 then
    begin
      pthread_cond_destroy(@plocaleventstate(result)^.FCondVar);
      FreeMem(result);
      fpc_threaderror;
    end;
end;

procedure Intbasiceventdestroy(state:peventstate);
begin
  { safely mark that we are destroying this event }
  pthread_mutex_lock(@plocaleventstate(state)^.feventsection);
  plocaleventstate(state)^.FDestroying:=true;

  { send a signal to all threads that are waiting }
  pthread_cond_broadcast(@plocaleventstate(state)^.FCondVar);
  pthread_mutex_unlock(@plocaleventstate(state)^.feventsection);

  { now wait until they've finished their business }
  while (plocaleventstate(state)^.FWaiters <> 0) do
    cThreadSwitch;

  { and clean up }
  pthread_cond_destroy(@plocaleventstate(state)^.Fcondvar);
  pthread_mutex_destroy(@plocaleventstate(state)^.FEventSection);
  dispose(plocaleventstate(state));
end;


procedure IntbasiceventResetEvent(state:peventstate);
begin
  pthread_mutex_lock(@plocaleventstate(state)^.feventsection);
  plocaleventstate(state)^.fisset:=false;
  pthread_mutex_unlock(@plocaleventstate(state)^.feventsection);
end;

procedure IntbasiceventSetEvent(state:peventstate);
begin
  pthread_mutex_lock(@plocaleventstate(state)^.feventsection);
  Try
    plocaleventstate(state)^.Fisset:=true;
    if not(plocaleventstate(state)^.FManualReset) then
      pthread_cond_signal(@plocaleventstate(state)^.Fcondvar)
    else
      pthread_cond_broadcast(@plocaleventstate(state)^.Fcondvar);
  finally
    pthread_mutex_unlock(@plocaleventstate(state)^.feventsection);
  end;
end;

function IntbasiceventWaitFor(Timeout : Cardinal;state:peventstate) : longint;
var
  timespec: ttimespec;
  errres: cint;
  isset: boolean;
  tnow : timeval;
begin
  { safely check whether we are being destroyed, if so immediately return. }
  { otherwise (under the same mutex) increase the number of waiters        }
  pthread_mutex_lock(@plocaleventstate(state)^.feventsection);
  if (plocaleventstate(state)^.FDestroying) then
    begin
      pthread_mutex_unlock(@plocaleventstate(state)^.feventsection);
      result := wrAbandoned;
      exit;
    end;
  { not a regular inc() because it may happen simulatneously with the }
  { interlockeddecrement() at the end                                 }
  interlockedincrement(plocaleventstate(state)^.FWaiters);

  //Wait without timeout using pthread_cond_wait
  if Timeout = $FFFFFFFF then
    begin
      while (not plocaleventstate(state)^.FIsSet) and (not plocaleventstate(state)^.FDestroying) do
        pthread_cond_wait(@plocaleventstate(state)^.Fcondvar, @plocaleventstate(state)^.feventsection);
    end
  else
    begin
      //Wait with timeout using pthread_cont_timedwait
      fpgettimeofday(@tnow,nil);
      timespec.tv_sec  := tnow.tv_sec + (clong(timeout) div 1000);
      timespec.tv_nsec := (clong(timeout) mod 1000)*1000000 + tnow.tv_usec*1000;
      if timespec.tv_nsec >= 1000000000 then
        begin
          inc(timespec.tv_sec);
          dec(timespec.tv_nsec, 1000000000);
        end;
      errres:=0;
      while (not plocaleventstate(state)^.FDestroying) and (not plocaleventstate(state)^.FIsSet) and (errres<>ESysETIMEDOUT) do
        errres:=pthread_cond_timedwait(@plocaleventstate(state)^.Fcondvar, @plocaleventstate(state)^.feventsection, @timespec);
    end;

  isset := plocaleventstate(state)^.FIsSet;

  { if ManualReset=false, reset the event immediately. }
  if (plocaleventstate(state)^.FManualReset=false) then
    plocaleventstate(state)^.FIsSet := false;

  //check the results...
  if plocaleventstate(state)^.FDestroying then
    Result := wrAbandoned
  else
    if IsSet then
      Result := wrSignaled
    else
      begin
        if errres=ESysETIMEDOUT then
          Result := wrTimeout
        else
          Result := wrError;
      end;

  pthread_mutex_unlock(@plocaleventstate(state)^.feventsection);

  { don't put this above the previous pthread_mutex_unlock, because    }
  { otherwise we can get errors in case an object is destroyed between }
  { end of the wait/sleep loop and the signalling above.               }
  { The pthread_mutex_unlock above takes care of the memory barrier    }
  interlockeddecrement(plocaleventstate(state)^.FWaiters);
end;

function intRTLEventCreate: PRTLEvent;

var p:pintrtlevent;

begin
  new(p);
  pthread_cond_init(@p^.condvar, nil);
  pthread_mutex_init(@p^.mutex, nil);
  p^.isset:=false;
  result:=PRTLEVENT(p);
end;

procedure intRTLEventDestroy(AEvent: PRTLEvent);

var p:pintrtlevent;

begin
  p:=pintrtlevent(aevent);
  pthread_cond_destroy(@p^.condvar);
  pthread_mutex_destroy(@p^.mutex);
  dispose(p);
end;

procedure intRTLEventSetEvent(AEvent: PRTLEvent);
var p:pintrtlevent;

begin
  p:=pintrtlevent(aevent);
  pthread_mutex_lock(@p^.mutex);
  p^.isset:=true;
  pthread_cond_signal(@p^.condvar);
  pthread_mutex_unlock(@p^.mutex);
end;


procedure intRTLEventResetEvent(AEvent: PRTLEvent);
var p:pintrtlevent;

begin
  p:=pintrtlevent(aevent);
  pthread_mutex_lock(@p^.mutex);
  p^.isset:=false;
  pthread_mutex_unlock(@p^.mutex);
end;


procedure intRTLEventWaitFor(AEvent: PRTLEvent);
var p:pintrtlevent;

begin
  p:=pintrtlevent(aevent);
  pthread_mutex_lock(@p^.mutex);
  while not p^.isset do pthread_cond_wait(@p^.condvar, @p^.mutex);
  p^.isset:=false;
  pthread_mutex_unlock(@p^.mutex);
end;

procedure intRTLEventWaitForTimeout(AEvent: PRTLEvent;timeout : longint);
  var
    p : pintrtlevent;
    errres : cint;
    timespec : ttimespec;
    tnow : timeval;

  begin
    p:=pintrtlevent(aevent);
    fpgettimeofday(@tnow,nil);
    timespec.tv_sec:=tnow.tv_sec+(timeout div 1000);
    timespec.tv_nsec:=(timeout mod 1000)*1000000 + tnow.tv_usec*1000;
    if timespec.tv_nsec >= 1000000000 then
    begin
      inc(timespec.tv_sec);
      dec(timespec.tv_nsec, 1000000000);
    end;
    errres:=0;
    pthread_mutex_lock(@p^.mutex);
    while (not p^.isset) and
          (errres <> ESysETIMEDOUT) do
      begin
        errres:=pthread_cond_timedwait(@p^.condvar, @p^.mutex, @timespec);
      end;
    p^.isset:=false;
    pthread_mutex_unlock(@p^.mutex);
  end;


type
  threadmethod = procedure of object;


Function CInitThreads : Boolean;

begin
{$ifdef DEBUG_MT}
  Writeln('Entering InitThreads.');
{$endif}
//{$ifndef dynpthreads}
  Result:=True;
//{$else}
//  Result:=LoadPthreads;
//{$endif}
  ThreadID := TThreadID (pthread_self());
{$ifdef DEBUG_MT}
  Writeln('InitThreads : ',Result);
{$endif DEBUG_MT}
end;

Function CDoneThreads : Boolean;

begin
//{$ifndef dynpthreads}
  Result:=True;
//{$else}
//  Result:=UnloadPthreads;
//{$endif}
end;


Var
  CThreadManager : TThreadManager;

Procedure SetCThreadManager;

begin
  With CThreadManager do begin
    InitManager            :=@CInitThreads;
    DoneManager            :=@CDoneThreads;
    BeginThread            :=@CBeginThread;
    EndThread              :=@CEndThread;
    SuspendThread          :=@CSuspendThread;
    ResumeThread           :=@CResumeThread;
    KillThread             :=@CKillThread;
    ThreadSwitch           :=@CThreadSwitch;
    CloseThread	           :=@CCloseThread;
    WaitForThreadTerminate :=@CWaitForThreadTerminate;
    ThreadSetPriority      :=@CThreadSetPriority;
    ThreadGetPriority      :=@CThreadGetPriority;
    GetCurrentThreadId     :=@CGetCurrentThreadId;
    InitCriticalSection    :=@CInitCriticalSection;
    DoneCriticalSection    :=@CDoneCriticalSection;
    EnterCriticalSection   :=@CEnterCriticalSection;
    TryEnterCriticalSection:=@CTryEnterCriticalSection;
    LeaveCriticalSection   :=@CLeaveCriticalSection;
    InitThreadVar          :=@CInitThreadVar;
    RelocateThreadVar      :=@CRelocateThreadVar;
    AllocateThreadVars     :=@CAllocateThreadVars;
    ReleaseThreadVars      :=@CReleaseThreadVars;
    BasicEventCreate       :=@intBasicEventCreate;
    BasicEventDestroy      :=@intBasicEventDestroy;
    BasicEventResetEvent   :=@intBasicEventResetEvent;
    BasicEventSetEvent     :=@intBasicEventSetEvent;
    BasiceventWaitFor      :=@intBasiceventWaitFor;
    rtlEventCreate         :=@intrtlEventCreate;
    rtlEventDestroy        :=@intrtlEventDestroy;
    rtlEventSetEvent       :=@intrtlEventSetEvent;
    rtlEventResetEvent     :=@intrtlEventResetEvent;
    rtleventWaitForTimeout :=@intrtleventWaitForTimeout;
    rtleventWaitFor        :=@intrtleventWaitFor;
    // semaphores
    SemaphoreInit          :=@cSemaphoreInit;
    SemaphoreDestroy       :=@cSemaphoreDestroy;
    SemaphoreWait          :=@cSemaphoreWait;
    SemaphorePost          :=@cSemaphorePost;
  end;
  SetThreadManager(CThreadManager);
end;


initialization
  if ThreadingAlreadyUsed then
    begin
      writeln('Threading has been used before cthreads was initialized.');
      writeln('Make cthreads one of the first units in your uses clause.');
      runerror(211);
    end;
  SetCThreadManager;
finalization
end.
