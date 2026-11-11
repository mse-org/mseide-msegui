{
  This file is part of:

    SDL3 for Pascal
    (https://github.com/PascalGameDevelopment/SDL3-for-Pascal)
    SPDX-License-Identifier: Zlib
}

{*
 * # CategoryError
 *
 * Simple error message routines for SDL.
 *
 * Most apps will interface with these APIs in exactly one function: when
 * almost any SDL function call reports failure, you can get a human-readable
 * string of the problem from SDL_GetError().
 *
 * These strings are maintained per-thread, and apps are welcome to set their
 * own errors, which is popular when building libraries on top of SDL for
 * other apps to consume. These strings are set by calling SDL_SetError().
 *
 * A common usage pattern is to have a function that returns true for success
 * and false for failure, and do this when something fails:
 *
 * ```c
 * if (something_went_wrong)
 *    return SDL_SetError("The thing broke in this specific way: %d", errcode);
 *
 * ```
 *
 * It's also common to just return `false` in this case if the failing thing
 * is known to call SDL_SetError(), so errors simply propagate through.
  }

{*
 * Set the SDL error message for the current thread.
 *
 * Calling this function will replace any previous error message that was set.
 *
 * This function always returns false, since SDL frequently uses false to
 * signify a failing result, leading to this idiom:
 *
 * ```c
 * if (error_code)
 *     return SDL_SetError("This operation has failed: %d", error_code);
 *
 * ```
 *
 * \param fmt a printf()-style message format string.
 * \param ... additional parameters matching % tokens in the `fmt` string, if
 *            any.
 * \returns false.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_ClearError
 * \sa SDL_GetError
 * \sa SDL_SetErrorV
  }
function SDL_SetError(fmt: PAnsiChar; Args: array of const): Boolean; cdecl; overload;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetError' {$ENDIF} {$ENDIF};
function SDL_SetError(fmt: PAnsiChar): Boolean; cdecl; overload;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetError' {$ENDIF} {$ENDIF};

{*
 * Set the SDL error message for the current thread.
 *
 * Calling this function will replace any previous error message that was set.
 *
 * \param fmt a printf()-style message format string.
 * \param ap a variable argument list.
 * \returns false.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_ClearError
 * \sa SDL_GetError
 * \sa SDL_SetError
  }
{ #todo : SDL3-for-Pascal: How to handle va_list? }
//function SDL_SetErrorV(fmt: PAnsiChar; ap: va_list): Boolean; cdecl;
//  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetErrorV' {$ENDIF} {$ENDIF};

{*
 * Set an error indicating that memory allocation failed.
 *
 * This function does not do any memory allocation.
 *
 * \returns false.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_OutOfMemory: Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_OutOfMemory' {$ENDIF} {$ENDIF};

{*
 * Retrieve a message about the last error that occurred on the current
 * thread.
 *
 * It is possible for multiple errors to occur before calling SDL_GetError().
 * Only the last error is returned.
 *
 * The message is only applicable when an SDL function has signaled an error.
 * You must check the return values of SDL function calls to determine when to
 * appropriately call SDL_GetError(). You should *not* use the results of
 * SDL_GetError() to decide if an error has occurred! Sometimes SDL will set
 * an error string even when reporting success.
 *
 * SDL will *not* clear the error string for successful API calls. You *must*
 * check return values for failure cases before you can assume the error
 * string applies.
 *
 * Error strings are set per-thread, so an error set in a different thread
 * will not interfere with the current thread's operation.
 *
 * The returned value is a thread-local string which will remain valid until
 * the current thread's error string is changed. The caller should make a copy
 * if the value is needed after the next SDL API call.
 *
 * \returns a message with information about the specific error that occurred,
 *          or an empty string if there hasn't been an error message set since
 *          the last call to SDL_ClearError().
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_ClearError
 * \sa SDL_SetError
  }
function SDL_GetError: PAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetError' {$ENDIF} {$ENDIF};

{*
 * Clear any previous error message for this thread.
 *
 * \returns true.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetError
 * \sa SDL_SetError
  }
function SDL_ClearError: Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ClearError' {$ENDIF} {$ENDIF};

