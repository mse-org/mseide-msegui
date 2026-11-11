{
  This file is part of:

    SDL3 for Pascal
    (https://github.com/PascalGameDevelopment/SDL3-for-Pascal)
    SPDX-License-Identifier: Zlib
}

{*
 * # CategoryThread
 *
 * SDL offers cross-platform thread management functions. These are mostly
 * concerned with starting threads, setting their priority, and dealing with
 * their termination.
 *
 * In addition, there is support for Thread Local Storage (data that is unique
 * to each thread, but accessed from a single key).
 *
 * On platforms without thread support (such as Emscripten when built without
 * pthreads), these functions still exist, but things like SDL_CreateThread()
 * will report failure without doing anything.
 *
 * If you're going to work with threads, you almost certainly need to have a
 * good understanding of thread safety measures: locking and synchronization
 * mechanisms are handled by the functions in SDL_mutex.h.
  }

{*
 * The SDL thread object.
 *
 * These are opaque data.
 *
 * \since This datatype is available since SDL 3.2.0.
 *
 * \sa SDL_CreateThread
 * \sa SDL_WaitThread
  }
type
  PPSDL_Thread = ^PSDL_Thread;
  PSDL_Thread = type Pointer;

{*
 * A unique numeric ID that identifies a thread.
 *
 * These are different from SDL_Thread objects, which are generally what an
 * application will operate on, but having a way to uniquely identify a thread
 * can be useful at times.
 *
 * \since This datatype is available since SDL 3.2.0.
 *
 * \sa SDL_GetThreadID
 * \sa SDL_GetCurrentThreadID
  }
type
  PPSDL_ThreadID = ^PSDL_ThreadID;
  PSDL_ThreadID = ^TSDL_ThreadID;
  TSDL_ThreadID = cuint64;

{*
 * Thread local storage ID.
 *
 * 0 is the invalid ID. An app can create these and then set data for these
 * IDs that is unique to each thread.
 *
 * \since This datatype is available since SDL 3.2.0.
 *
 * \sa SDL_GetTLS
 * \sa SDL_SetTLS
  }
type
  PPSDL_TLSID = ^PSDL_TLSID;
  PSDL_TLSID = ^TSDL_TLSID;
  TSDL_TLSID = TSDL_AtomicInt;

{*
 * The SDL thread priority.
 *
 * SDL will make system changes as necessary in order to apply the thread
 * priority. Code which attempts to control thread state related to priority
 * should be aware that calling SDL_SetCurrentThreadPriority may alter such
 * state. SDL_HINT_THREAD_PRIORITY_POLICY can be used to control aspects of
 * this behavior.
 *
 * \since This enum is available since SDL 3.2.0.
  }
type
  PPSDL_ThreadPriority = ^PSDL_ThreadPriority;
  PSDL_ThreadPriority = ^TSDL_ThreadPriority;
  TSDL_ThreadPriority = type Integer;
const
  SDL_THREAD_PRIORITY_LOW  = TSDL_ThreadPriority(0);
  SDL_THREAD_PRIORITY_NORMAL  = TSDL_ThreadPriority(1);
  SDL_THREAD_PRIORITY_HIGH  = TSDL_ThreadPriority(2);
  SDL_THREAD_PRIORITY_TIME_CRITICAL  = TSDL_ThreadPriority(3);

{*
 * The SDL thread state.
 *
 * The current state of a thread can be checked by calling SDL_GetThreadState.
 *
 * \since This enum is available since SDL 3.2.0.
 *
 * \sa SDL_GetThreadState
  }
type
  PPSDL_ThreadState = ^PSDL_ThreadState;
  PSDL_ThreadState = ^TSDL_ThreadState;
  TSDL_ThreadState = type Integer;
const
  SDL_THREAD_UNKNOWN  = TSDL_ThreadState(0);   {*< The thread is not valid  }
  SDL_THREAD_ALIVE  = TSDL_ThreadState(1);     {*< The thread is currently running  }
  SDL_THREAD_DETACHED  = TSDL_ThreadState(2);  {*< The thread is detached and can't be waited on  }
  SDL_THREAD_COMPLETE  = TSDL_ThreadState(3);  {*< The thread has finished and should be cleaned up with SDL_WaitThread()  }

{*
 * The function passed to SDL_CreateThread() as the new thread's entry point.
 *
 * \param data what was passed as `data` to SDL_CreateThread().
 * \returns a value that can be reported through SDL_WaitThread().
 *
 * \since This datatype is available since SDL 3.2.0.
  }
type
  TSDL_ThreadFunction = function(data: Pointer): cint; cdecl;

{
 * Note that these aren't the correct function signatures in this block, but
 * this is what the API reference manual should look like for all intents and
 * purposes.
 *
 * Technical details, not for the wiki (hello, header readers!)...
 *
 * On Windows (and maybe other platforms), a program might use a different
 * C runtime than its libraries. Or, in SDL's case, it might use a C runtime
 * while SDL uses none at all.
 *
 * C runtimes expect to initialize thread-specific details when a new thread
 * is created, but to do this in SDL_CreateThread would require SDL to know
 * intimate details about the caller's C runtime, which is not possible.
 *
 * So SDL_CreateThread has two extra parameters, which are
 * hidden at compile time by macros: the C runtime's `_beginthreadex` and
 * `_endthreadex` entry points. If these are not nil, they are used to spin
 * and terminate the new thread; otherwise the standard Win32 `CreateThread`
 * function is used. When `SDL_CreateThread` is called from a compiler that
 * needs this C runtime thread init function, macros insert the appropriate
 * function pointers for SDL_CreateThread's caller (which might be a different
 * compiler with a different runtime in different calls to SDL_CreateThread!).
 *
 * SDL_BeginThreadFunction defaults to `_beginthreadex` on Windows (and nil
 * everywhere else), but apps that have extremely specific special needs can
 * define this to something else and the SDL headers will use it, passing the
 * app-defined value to SDL_CreateThread calls. Redefine this with caution!
 *
 * Platforms that don't need _beginthread stuff (most everything) will fail
 * SDL_CreateThread with an error if these pointers _aren't_ nil.
 *
 * Unless you are doing something extremely complicated, like perhaps a
 * language binding, **you should never deal with this directly**. Let SDL's
 * macros handle this platform-specific detail transparently!
  }

{*
 * Create a new thread with a default stack size.
 *
 * This is a convenience function, equivalent to calling
 * SDL_CreateThreadWithProperties with the following properties set:
 *
 * - `SDL_PROP_THREAD_CREATE_ENTRY_FUNCTION_POINTER`: `fn`
 * - `SDL_PROP_THREAD_CREATE_NAME_STRING`: `name`
 * - `SDL_PROP_THREAD_CREATE_USERDATA_POINTER`: `data`
 *
 * Note that this "function" is actually a macro that calls an internal
 * function with two extra parameters not listed here; they are hidden through
 * preprocessor macros and are needed to support various C runtimes at the
 * point of the function call. Language bindings that aren't using the C
 * headers will need to deal with this.
 *
 * Usually, apps should just call this function the same way on every platform
 * and let the macros hide the details.
 *
 * \param fn the SDL_ThreadFunction function to call in the new thread.
 * \param name the name of the thread.
 * \param data a Pointer that is passed to `fn`.
 * \returns an opaque Pointer to the new thread object on success, nil if the
 *          new thread could not be created; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateThreadWithProperties
 * \sa SDL_WaitThread
  }
{ #todo : SDL3-for-Pascal: According to the description we should use the
          macros directly and take care of different "runtimes" manually.
          Is this correct?  }
//function SDL_CreateThread(fn: TSDL_ThreadFunction; name: PAnsiChar; data: Pointer): PSDL_Thread; cdecl;
//  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CreateThread' {$ENDIF} {$ENDIF};

{*
 * Create a new thread with with the specified properties.
 *
 * These are the supported properties:
 *
 * - `SDL_PROP_THREAD_CREATE_ENTRY_FUNCTION_POINTER`: an SDL_ThreadFunction
 *   value that will be called at the start of the new thread's life.
 *   Required.
 * - `SDL_PROP_THREAD_CREATE_NAME_STRING`: the name of the new thread, which
 *   might be available to debuggers. Optional, defaults to nil.
 * - `SDL_PROP_THREAD_CREATE_USERDATA_POINTER`: an arbitrary app-defined
 *   Pointer, which is passed to the entry function on the new thread, as its
 *   only parameter. Optional, defaults to nil.
 * - `SDL_PROP_THREAD_CREATE_STACKSIZE_NUMBER`: the size, in bytes, of the new
 *   thread's stack. Optional, defaults to 0 (system-defined default).
 *
 * SDL makes an attempt to report `SDL_PROP_THREAD_CREATE_NAME_STRING` to the
 * system, so that debuggers can display it. Not all platforms support this.
 *
 * Thread naming is a little complicated: Most systems have very small limits
 * for the string length (Haiku has 32 bytes, Linux currently has 16, Visual
 * C++ 6.0 has _nine_!), and possibly other arbitrary rules. You'll have to
 * see what happens with your system's debugger. The name should be UTF-8 (but
 * using the naming limits of C identifiers is a better bet). There are no
 * requirements for thread naming conventions, so long as the string is
 * null-terminated UTF-8, but these guidelines are helpful in choosing a name:
 *
 * https://stackoverflow.com/questions/149932/naming-conventions-for-threads
 *
 * If a system imposes requirements, SDL will try to munge the string for it
 * (truncate, etc), but the original string contents will be available from
 * SDL_GetThreadName().
 *
 * The size (in bytes) of the new stack can be specified with
 * `SDL_PROP_THREAD_CREATE_STACKSIZE_NUMBER`. Zero means "use the system
 * default" which might be wildly different between platforms. x86 Linux
 * generally defaults to eight megabytes, an embedded device might be a few
 * kilobytes instead. You generally need to specify a stack that is a multiple
 * of the system's page size (in many cases, this is 4 kilobytes, but check
 * your system documentation).
 *
 * Note that this "function" is actually a macro that calls an internal
 * function with two extra parameters not listed here; they are hidden through
 * preprocessor macros and are needed to support various C runtimes at the
 * point of the function call. Language bindings that aren't using the C
 * headers will need to deal with this.
 *
 * The actual symbol in SDL is `SDL_CreateThreadWithPropertiesRuntime`, so
 * there is no symbol clash, but trying to load an SDL shared library and look
 * for "SDL_CreateThreadWithProperties" will fail.
 *
 * Usually, apps should just call this function the same way on every platform
 * and let the macros hide the details.
 *
 * \param props the properties to use.
 * \returns an opaque Pointer to the new thread object on success, nil if the
 *          new thread could not be created; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateThread
 * \sa SDL_WaitThread
  }
{ #todo : SDL3-for-Pascal: According to the description we should use the
          macros directly and take care of different "runtimes" manually.
          Is this correct?  }
//function SDL_CreateThreadWithProperties(props: TSDL_PropertiesID): PSDL_Thread; cdecl;
//  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CreateThreadWithProperties' {$ENDIF} {$ENDIF};

{ #note : SDL3-for-Pascal: These constants are defined again at the macro
          definitions. }
//const
//  SDL_PROP_THREAD_CREATE_ENTRY_FUNCTION_POINTER = 'SDL.thread.create.entry_function';
//  SDL_PROP_THREAD_CREATE_NAME_STRING = 'SDL.thread.create.name';
//  SDL_PROP_THREAD_CREATE_USERDATA_POINTER = 'SDL.thread.create.userdata';
//  SDL_PROP_THREAD_CREATE_STACKSIZE_NUMBER = 'SDL.thread.create.stacksize';


{ The real implementation, hidden from the wiki, so it can show this as real functions that don't have macro magic.  }

{ #note : SDL3-for-Pascal:

    In Windows begin/end thread functions are defined by _beginthreadex
    and _endthreadex. On other systems they are not defined, hence NIL.

  #todo : SDL3-for-Pascal:

    We treat them as nil constants on other systems AND for Windows.
    Implementation for Windows is needed.

    A starting point and source are added.
    Unfortunately, if (T)SDL_BeginThreadFunction is typed,
    the calling macro functions SDL_CreateThread and
    SDL_CreateThreadWithProperties stop working, as they expect a
    cast of TSDL_FunctionPointer; which is possible for a nil constant
    but not for another type in Pascal.
    }
{$IFDEF SDL_PLATFORM_WINDOWS}
  {$IFNDEF SDL_BeginThreadFunction}
    { Source: https://learn.microsoft.com/de-de/cpp/c-runtime-library/reference/beginthread-beginthreadex?view=msvc-170 }
    { NATIVE CODE: uintptr_t _beginthreadex(void *security, unsigned stack_size, unsigned ( __stdcall *start_address )( void * ), void *arglist, unsigned initflag, unsigned *thrdaddr); }
    //type
    //  start_address_func = function(parameter:Pointer):cuint; stdcall;
    //  _beginthreadex = function(security:Pointer; stack_size:cuint; start_address: start_address_func; arglist: Pointer; initflat:cuint; thrdaddr:pcuint): cuintptr_t; cdecl;
    //  TSDL_BeginThreadFunction = _beginthreadex;
    const
      SDL_BeginThreadFunction = nil;
  {$DEFINE SDL_BeginThreadFunction}
  {$ENDIF}
  {$IFNDEF SDL_EndThreadFunction}
    { Source: https://learn.microsoft.com/de-de/cpp/c-runtime-library/reference/endthread-endthreadex?view=msvc-170 }
    { void _endthreadex(unsigned retval); }
    //type
    //  _endthreadex = procedure(retval:cuint); cdecl;
    //  TSDL_EndThreadFunction = _endthreadex;
    const
      SDL_EndThreadFunction = nil;
  {$DEFINE SDL_EndThreadFunction}
  {$ENDIF}
{$ENDIF}

{ currently no other platforms than Windows use _beginthreadex/_endthreadex things.  }
{$IFNDEF SDL_BeginThreadFunction}
  const
    SDL_BeginThreadFunction = nil;
{$DEFINE SDL_BeginThreadFunction}
{$ENDIF}

{$IFNDEF SDL_EndThreadFunction}
  const
    SDL_EndThreadFunction = nil;
{$DEFINE SDL_BeginThreadFunction}
{$ENDIF}

{ These are the actual functions exported from SDL! Don't use them directly! Use the SDL_CreateThread and SDL_CreateThreadWithProperties macros!  }
{*
 * The actual entry point for SDL_CreateThread.
 *
 * \param fn the SDL_ThreadFunction function to call in the new thread
 * \param name the name of the thread
 * \param data a Pointer that is passed to `fn`
 * \param pfnBeginThread the C runtime's _beginthreadex (or whatnot). Can be nil.
 * \param pfnEndThread the C runtime's _endthreadex (or whatnot). Can be nil.
 * \returns an opaque Pointer to the new thread object on success, nil if the
 *          new thread could not be created; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_CreateThreadRuntime(fn: TSDL_ThreadFunction; name: PAnsiChar; data: Pointer; pfnBeginThread: TSDL_FunctionPointer; pfnEndThread: TSDL_FunctionPointer): PSDL_Thread; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CreateThreadRuntime' {$ENDIF} {$ENDIF};

{*
 * The actual entry point for SDL_CreateThreadWithProperties.
 *
 * \param props the properties to use
 * \param pfnBeginThread the C runtime's _beginthreadex (or whatnot). Can be nil.
 * \param pfnEndThread the C runtime's _endthreadex (or whatnot). Can be nil.
 * \returns an opaque Pointer to the new thread object on success, nil if the
 *          new thread could not be created; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_CreateThreadWithPropertiesRuntime(props: TSDL_PropertiesID; pfnBeginThread: TSDL_FunctionPointer; pfnEndThread: TSDL_FunctionPointer): PSDL_Thread; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CreateThreadWithPropertiesRuntime' {$ENDIF} {$ENDIF};


function SDL_CreateThread(fn: TSDL_ThreadFunction; name: PAnsiChar; data: Pointer): PSDL_Thread;
function SDL_CreateThreadWithProperties(props: TSDL_PropertiesID): PSDL_Thread;
const
  SDL_PROP_THREAD_CREATE_ENTRY_FUNCTION_POINTER = 'SDL.thread.create.entry_function';
  SDL_PROP_THREAD_CREATE_NAME_STRING = 'SDL.thread.create.name';
  SDL_PROP_THREAD_CREATE_USERDATA_POINTER = 'SDL.thread.create.userdata';
  SDL_PROP_THREAD_CREATE_STACKSIZE_NUMBER = 'SDL.thread.create.stacksize';

{*
 * Get the thread name as it was specified in SDL_CreateThread().
 *
 * \param thread the thread to query.
 * \returns a Pointer to a UTF-8 string that names the specified thread, or
 *          nil if it doesn't have a name.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetThreadName(thread: PSDL_Thread): PAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetThreadName' {$ENDIF} {$ENDIF};

{*
 * Get the thread identifier for the current thread.
 *
 * This thread identifier is as reported by the underlying operating system.
 * If SDL is running on a platform that does not support threads the return
 * value will always be zero.
 *
 * This function also returns a valid thread ID when called from the main
 * thread.
 *
 * \returns the ID of the current thread.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetThreadID
  }
function SDL_GetCurrentThreadID: TSDL_ThreadID; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetCurrentThreadID' {$ENDIF} {$ENDIF};

{*
 * Get the thread identifier for the specified thread.
 *
 * This thread identifier is as reported by the underlying operating system.
 * If SDL is running on a platform that does not support threads the return
 * value will always be zero.
 *
 * \param thread the thread to query.
 * \returns the ID of the specified thread, or the ID of the current thread if
 *          `thread` is nil.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetCurrentThreadID
  }
function SDL_GetThreadID(thread: PSDL_Thread): TSDL_ThreadID; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetThreadID' {$ENDIF} {$ENDIF};

{*
 * Set the priority for the current thread.
 *
 * Note that some platforms will not let you alter the priority (or at least,
 * promote the thread to a higher priority) at all, and some require you to be
 * an administrator account. Be prepared for this to fail.
 *
 * \param priority the SDL_ThreadPriority to set.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_SetCurrentThreadPriority(priority: TSDL_ThreadPriority): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetCurrentThreadPriority' {$ENDIF} {$ENDIF};

{*
 * Wait for a thread to finish.
 *
 * Threads that haven't been detached will remain until this function cleans
 * them up. Not doing so is a resource leak.
 *
 * Once a thread has been cleaned up through this function, the SDL_Thread
 * that references it becomes invalid and should not be referenced again. As
 * such, only one thread may call SDL_WaitThread() on another.
 *
 * The return code from the thread function is placed in the area pointed to
 * by `status`, if `status` is not nil.
 *
 * You may not wait on a thread that has been used in a call to
 * SDL_DetachThread(). Use either that function or this one, but not both, or
 * behavior is undefined.
 *
 * It is safe to pass a nil thread to this function; it is a no-op.
 *
 * Note that the thread Pointer is freed by this function and is not valid
 * afterward.
 *
 * \param thread the SDL_Thread Pointer that was returned from the
 *               SDL_CreateThread() call that started this thread.
 * \param status a Pointer filled in with the value returned from the thread
 *               function by its 'return', or -1 if the thread has been
 *               detached or isn't valid, may be nil.
 *
 * \threadsafety It is safe to call this function from any thread, but only a
 *               single thread can wait any specific thread to finish.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateThread
 * \sa SDL_DetachThread
  }
procedure SDL_WaitThread(thread: PSDL_Thread; status: pcint); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_WaitThread' {$ENDIF} {$ENDIF};

{*
 * Get the current state of a thread.
 *
 * \param thread the thread to query.
 * \returns the current state of a thread, or SDL_THREAD_UNKNOWN if the thread
 *          isn't valid.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_ThreadState
  }
function SDL_GetThreadState(thread: PSDL_Thread): TSDL_ThreadState; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetThreadState' {$ENDIF} {$ENDIF};

{*
 * Let a thread clean up on exit without intervention.
 *
 * A thread may be "detached" to signify that it should not remain until
 * another thread has called SDL_WaitThread() on it. Detaching a thread is
 * useful for long-running threads that nothing needs to synchronize with or
 * further manage. When a detached thread is done, it simply goes away.
 *
 * There is no way to recover the return code of a detached thread. If you
 * need this, don't detach the thread and instead use SDL_WaitThread().
 *
 * Once a thread is detached, you should usually assume the SDL_Thread isn't
 * safe to reference again, as it will become invalid immediately upon the
 * detached thread's exit, instead of remaining until someone has called
 * SDL_WaitThread() to finally clean it up. As such, don't detach the same
 * thread more than once.
 *
 * If a thread has already exited when passed to SDL_DetachThread(), it will
 * stop waiting for a call to SDL_WaitThread() and clean up immediately. It is
 * not safe to detach a thread that might be used with SDL_WaitThread().
 *
 * You may not call SDL_WaitThread() on a thread that has been detached. Use
 * either that function or this one, but not both, or behavior is undefined.
 *
 * It is safe to pass nil to this function; it is a no-op.
 *
 * \param thread the SDL_Thread Pointer that was returned from the
 *               SDL_CreateThread() call that started this thread.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateThread
 * \sa SDL_WaitThread
  }
procedure SDL_DetachThread(thread: PSDL_Thread); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_DetachThread' {$ENDIF} {$ENDIF};

{*
 * Get the current thread's value associated with a thread local storage ID.
 *
 * \param id a Pointer to the thread local storage ID, may not be nil.
 * \returns the value associated with the ID for the current thread or nil if
 *          no value has been set; call SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetTLS
  }
function SDL_GetTLS(id: PSDL_TLSID): Pointer; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetTLS' {$ENDIF} {$ENDIF};

{*
 * The callback used to cleanup data passed to SDL_SetTLS.
 *
 * This is called when a thread exits, to allow an app to free any resources.
 *
 * \param value a Pointer previously handed to SDL_SetTLS.
 *
 * \since This datatype is available since SDL 3.2.0.
 *
 * \sa SDL_SetTLS
  }
type
  TSDL_TLSDestructorCallback = procedure(value: Pointer); cdecl;

{*
 * Set the current thread's value associated with a thread local storage ID.
 *
 * If the thread local storage ID is not initialized (the value is 0), a new
 * ID will be created in a thread-safe way, so all calls using a Pointer to
 * the same ID will refer to the same local storage.
 *
 * Note that replacing a value from a previous call to this function on the
 * same thread does _not_ call the previous value's destructor!
 *
 * `destructor` can be nil; it is assumed that `value` does not need to be
 * cleaned up if so.
 *
 * \param id a Pointer to the thread local storage ID, may not be nil.
 * \param value the value to associate with the ID for the current thread.
 * \param destructor a function called when the thread exits, to free the
 *                   value, may be nil.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetTLS
  }
function SDL_SetTLS(id: PSDL_TLSID; value: Pointer; destructor_: TSDL_TLSDestructorCallback): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetTLS' {$ENDIF} {$ENDIF};

{*
 * Cleanup all TLS data for this thread.
 *
 * If you are creating your threads outside of SDL and then calling SDL
 * functions, you should call this function before your thread exits, to
 * properly clean up SDL memory.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
procedure SDL_CleanupTLS; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CleanupTLS' {$ENDIF} {$ENDIF};

