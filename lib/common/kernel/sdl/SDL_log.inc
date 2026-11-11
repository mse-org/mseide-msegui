{
  This file is part of:

    SDL3 for Pascal
    (https://github.com/PascalGameDevelopment/SDL3-for-Pascal)
    SPDX-License-Identifier: Zlib
}

{*
 * # CategoryLog
 *
 * Simple log messages with priorities and categories. A message's
 * SDL_LogPriority signifies how important the message is. A message's
 * SDL_LogCategory signifies from what domain it belongs to. Every category
 * has a minimum priority specified: when a message belongs to that category,
 * it will only be sent out if it has that minimum priority or higher.
 *
 * SDL's own logs are sent below the default priority threshold, so they are
 * quiet by default.
 *
 * You can change the log verbosity programmatically using
 * SDL_SetLogPriority() or with SDL_SetHint(SDL_HINT_LOGGING, ...), or with
 * the "SDL_LOGGING" environment variable. This variable is a comma separated
 * set of category=level tokens that define the default logging levels for SDL
 * applications.
 *
 * The category can be a numeric category, one of "app", "error", "assert",
 * "system", "audio", "video", "render", "input", "test", or `*` for any
 * unspecified category.
 *
 * The level can be a numeric level, one of "trace", "verbose", "debug",
 * "info", "warn", "error", "critical", or "quiet" to disable that category.
 *
 * You can omit the category if you want to set the logging level for all
 * categories.
 *
 * If this hint isn't set, the default log levels are equivalent to:
 *
 * `app=info,assert=warn,test=verbose,*=error`
 *
 * Here's where the messages go on different platforms:
 *
 * - Windows: debug output stream
 * - Android: log output
 * - Others: standard error output (stderr)
 *
 * You don't need to have a newline (`\n`) on the end of messages, the
 * functions will do that for you. For consistent behavior cross-platform, you
 * shouldn't have any newlines in messages, such as to log multiple lines in
 * one call; unusual platform-specific behavior can be observed in such usage.
 * Do one log call per line instead, with no newlines in messages.
 *
 * Each log call is atomic, so you won't see log messages cut off one another
 * when logging from multiple threads.
  }

{*
 * The predefined log categories
 *
 * By default the application and gpu categories are enabled at the INFO
 * level, the assert category is enabled at the WARN level, test is enabled at
 * the VERBOSE level and all other categories are enabled at the ERROR level.
 *
 * \since This enum is available since SDL 3.2.0.
  }
type
  PPSDL_LogCategory = ^PSDL_LogCategory;
  PSDL_LogCategory = ^TSDL_LogCategory;
  TSDL_LogCategory =  Integer;
const
  SDL_LOG_CATEGORY_APPLICATION = TSDL_LogCategory(0);
  SDL_LOG_CATEGORY_ERROR = TSDL_LogCategory(1);
  SDL_LOG_CATEGORY_ASSERT = TSDL_LogCategory(2);
  SDL_LOG_CATEGORY_SYSTEM = TSDL_LogCategory(3);
  SDL_LOG_CATEGORY_AUDIO = TSDL_LogCategory(4);
  SDL_LOG_CATEGORY_VIDEO = TSDL_LogCategory(5);
  SDL_LOG_CATEGORY_RENDER = TSDL_LogCategory(6);
  SDL_LOG_CATEGORY_INPUT = TSDL_LogCategory(7);
  SDL_LOG_CATEGORY_TEST = TSDL_LogCategory(8);
  SDL_LOG_CATEGORY_GPU = TSDL_LogCategory(9);

  { Reserved for future SDL library use  }
  SDL_LOG_CATEGORY_RESERVED2 = TSDL_LogCategory(10);
  SDL_LOG_CATEGORY_RESERVED3 = TSDL_LogCategory(11);
  SDL_LOG_CATEGORY_RESERVED4 = TSDL_LogCategory(12);
  SDL_LOG_CATEGORY_RESERVED5 = TSDL_LogCategory(13);
  SDL_LOG_CATEGORY_RESERVED6 = TSDL_LogCategory(14);
  SDL_LOG_CATEGORY_RESERVED7 = TSDL_LogCategory(15);
  SDL_LOG_CATEGORY_RESERVED8 = TSDL_LogCategory(16);
  SDL_LOG_CATEGORY_RESERVED9 = TSDL_LogCategory(17);
  SDL_LOG_CATEGORY_RESERVED10 = TSDL_LogCategory(18);

  { Beyond this point is reserved for application use, e.g.
       enum
           MYAPP_CATEGORY_AWESOME1 = SDL_LOG_CATEGORY_CUSTOM,
           MYAPP_CATEGORY_AWESOME2,
           MYAPP_CATEGORY_AWESOME3,
           ...
       ;
      }
  SDL_LOG_CATEGORY_CUSTOM = TSDL_LogCategory(19);

{*
 * The predefined log priorities
 *
 * \since This enum is available since SDL 3.2.0.
  }
type
  PPSDL_LogPriority = ^PSDL_LogPriority;
  PSDL_LogPriority = ^TSDL_LogPriority;
  TSDL_LogPriority =  Integer;
const
  SDL_LOG_PRIORITY_INVALID = TSDL_LogPriority(0);
  SDL_LOG_PRIORITY_TRACE = TSDL_LogPriority(1);
  SDL_LOG_PRIORITY_VERBOSE = TSDL_LogPriority(2);
  SDL_LOG_PRIORITY_DEBUG = TSDL_LogPriority(3);
  SDL_LOG_PRIORITY_INFO = TSDL_LogPriority(4);
  SDL_LOG_PRIORITY_WARN = TSDL_LogPriority(5);
  SDL_LOG_PRIORITY_ERROR = TSDL_LogPriority(6);
  SDL_LOG_PRIORITY_CRITICAL = TSDL_LogPriority(7);
  SDL_LOG_PRIORITY_COUNT = TSDL_LogPriority(8);

{*
 * Set the priority of all log categories.
 *
 * \param priority the SDL_LogPriority to assign.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This enum is available since SDL 3.2.0.
 *
 * \sa SDL_ResetLogPriorities
 * \sa SDL_SetLogPriority
  }
procedure SDL_SetLogPriorities(priority: TSDL_LogPriority); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetLogPriorities' {$ENDIF} {$ENDIF};

{*
 * Set the priority of a particular log category.
 *
 * \param category the category to assign a priority to.
 * \param priority the SDL_LogPriority to assign.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetLogPriority
 * \sa SDL_ResetLogPriorities
 * \sa SDL_SetLogPriorities
  }
procedure SDL_SetLogPriority(category: cint; priority: TSDL_LogPriority); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetLogPriority' {$ENDIF} {$ENDIF};

{*
 * Get the priority of a particular log category.
 *
 * \param category the category to query.
 * \returns the SDL_LogPriority for the requested category.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetLogPriority
  }
function SDL_GetLogPriority(category: cint): TSDL_LogPriority; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetLogPriority' {$ENDIF} {$ENDIF};

{*
 * Reset all priorities to default.
 *
 * This is called by SDL_Quit().
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetLogPriorities
 * \sa SDL_SetLogPriority
  }
procedure SDL_ResetLogPriorities; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ResetLogPriorities' {$ENDIF} {$ENDIF};

{*
 * Set the text prepended to log messages of a given priority.
 *
 * By default SDL_LOG_PRIORITY_INFO and below have no prefix, and
 * SDL_LOG_PRIORITY_WARN and higher have a prefix showing their priority, e.g.
 * "WARNING: ".
 *
 * This function makes a copy of its string argument, **prefix**, so it is not
 * necessary to keep the value of **prefix** alive after the call returns.
 *
 * \param priority the SDL_LogPriority to modify.
 * \param prefix the prefix to use for that log priority, or nil to use no
 *               prefix.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetLogPriorities
 * \sa SDL_SetLogPriority
  }
function SDL_SetLogPriorityPrefix(priority: TSDL_LogPriority; prefix: PAnsiChar): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetLogPriorityPrefix' {$ENDIF} {$ENDIF};

{*
 * Log a message with SDL_LOG_CATEGORY_APPLICATION and SDL_LOG_PRIORITY_INFO.
 *
 * \param fmt a printf() style message format string.
 * \param ... additional parameters matching % tokens in the `fmt` string, if
 *            any.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_LogCritical
 * \sa SDL_LogDebug
 * \sa SDL_LogError
 * \sa SDL_LogInfo
 * \sa SDL_LogMessage
 * \sa SDL_LogMessageV
 * \sa SDL_LogVerbose
 * \sa SDL_LogWarn
  }
procedure SDL_Log(fmt: PAnsiChar; Args: array of const); cdecl; overload;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_Log' {$ENDIF} {$ENDIF};
procedure SDL_Log(fmt: PAnsiChar); cdecl; overload;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_Log' {$ENDIF} {$ENDIF};

{*
 * Log a message with SDL_LOG_PRIORITY_TRACE.
 *
 * \param category the category of the message.
 * \param fmt a printf() style message format string.
 * \param ... additional parameters matching % tokens in the **fmt** string,
 *            if any.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_Log
 * \sa SDL_LogCritical
 * \sa SDL_LogDebug
 * \sa SDL_LogError
 * \sa SDL_LogInfo
 * \sa SDL_LogMessage
 * \sa SDL_LogMessageV
 * \sa SDL_LogTrace
 * \sa SDL_LogVerbose
 * \sa SDL_LogWarn
  }
procedure SDL_LogTrace(category: cint; fmt: PAnsiChar; Args: array of const); cdecl; overload;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_LogTrace' {$ENDIF} {$ENDIF};
procedure SDL_LogTrace(category: cint; fmt: PAnsiChar); cdecl; overload;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_LogTrace' {$ENDIF} {$ENDIF};

{*
 * Log a message with SDL_LOG_PRIORITY_VERBOSE.
 *
 * \param category the category of the message.
 * \param fmt a printf() style message format string.
 * \param ... additional parameters matching % tokens in the **fmt** string,
 *            if any.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_Log
 * \sa SDL_LogCritical
 * \sa SDL_LogDebug
 * \sa SDL_LogError
 * \sa SDL_LogInfo
 * \sa SDL_LogMessage
 * \sa SDL_LogMessageV
 * \sa SDL_LogWarn
  }
procedure SDL_LogVerbose(category: cint; fmt: PAnsiChar; Args: array of const); cdecl; overload;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_LogVerbose' {$ENDIF} {$ENDIF};
procedure SDL_LogVerbose(category: cint; fmt: PAnsiChar); cdecl; overload;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_LogVerbose' {$ENDIF} {$ENDIF};

{*
 * Log a message with SDL_LOG_PRIORITY_DEBUG.
 *
 * \param category the category of the message.
 * \param fmt a printf() style message format string.
 * \param ... additional parameters matching % tokens in the **fmt** string,
 *            if any.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_Log
 * \sa SDL_LogCritical
 * \sa SDL_LogError
 * \sa SDL_LogInfo
 * \sa SDL_LogMessage
 * \sa SDL_LogMessageV
 * \sa SDL_LogTrace
 * \sa SDL_LogVerbose
 * \sa SDL_LogWarn
  }
procedure SDL_LogDebug(category: cint; fmt: PAnsiChar; Args: array of const); cdecl; overload;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_LogDebug' {$ENDIF} {$ENDIF};
procedure SDL_LogDebug(category: cint; fmt: PAnsiChar); cdecl; overload;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_LogDebug' {$ENDIF} {$ENDIF};

{*
 * Log a message with SDL_LOG_PRIORITY_INFO.
 *
 * \param category the category of the message.
 * \param fmt a printf() style message format string.
 * \param ... additional parameters matching % tokens in the **fmt** string,
 *            if any.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_Log
 * \sa SDL_LogCritical
 * \sa SDL_LogDebug
 * \sa SDL_LogError
 * \sa SDL_LogMessage
 * \sa SDL_LogMessageV
 * \sa SDL_LogTrace
 * \sa SDL_LogVerbose
 * \sa SDL_LogWarn
  }
procedure SDL_LogInfo(category: cint; fmt: PAnsiChar; Args: array of const); cdecl; overload;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_LogInfo' {$ENDIF} {$ENDIF};
procedure SDL_LogInfo(category: cint; fmt: PAnsiChar); cdecl; overload;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_LogInfo' {$ENDIF} {$ENDIF};

{*
 * Log a message with SDL_LOG_PRIORITY_WARN.
 *
 * \param category the category of the message.
 * \param fmt a printf() style message format string.
 * \param ... additional parameters matching % tokens in the **fmt** string,
 *            if any.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_Log
 * \sa SDL_LogCritical
 * \sa SDL_LogDebug
 * \sa SDL_LogError
 * \sa SDL_LogInfo
 * \sa SDL_LogMessage
 * \sa SDL_LogMessageV
 * \sa SDL_LogTrace
 * \sa SDL_LogVerbose
  }
procedure SDL_LogWarn(category: cint; fmt: PAnsiChar; Args: array of const); cdecl; overload;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_LogWarn' {$ENDIF} {$ENDIF};
procedure SDL_LogWarn(category: cint; fmt: PAnsiChar); cdecl; overload;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_LogWarn' {$ENDIF} {$ENDIF};

{*
 * Log a message with SDL_LOG_PRIORITY_ERROR.
 *
 * \param category the category of the message.
 * \param fmt a printf() style message format string.
 * \param ... additional parameters matching % tokens in the **fmt** string,
 *            if any.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_Log
 * \sa SDL_LogCritical
 * \sa SDL_LogDebug
 * \sa SDL_LogInfo
 * \sa SDL_LogMessage
 * \sa SDL_LogMessageV
 * \sa SDL_LogTrace
 * \sa SDL_LogVerbose
 * \sa SDL_LogWarn
  }
procedure SDL_LogError(category: cint; fmt: PAnsiChar; Args: array of const); cdecl; overload;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_LogError' {$ENDIF} {$ENDIF};
procedure SDL_LogError(category: cint; fmt: PAnsiChar); cdecl; overload;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_LogError' {$ENDIF} {$ENDIF};

{*
 * Log a message with SDL_LOG_PRIORITY_CRITICAL.
 *
 * \param category the category of the message.
 * \param fmt a printf() style message format string.
 * \param ... additional parameters matching % tokens in the **fmt** string,
 *            if any.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_Log
 * \sa SDL_LogDebug
 * \sa SDL_LogError
 * \sa SDL_LogInfo
 * \sa SDL_LogMessage
 * \sa SDL_LogMessageV
 * \sa SDL_LogTrace
 * \sa SDL_LogVerbose
 * \sa SDL_LogWarn
  }
procedure SDL_LogCritical(category: cint; fmt: PAnsiChar; Args: array of const); cdecl; overload;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_LogCritical' {$ENDIF} {$ENDIF};
procedure SDL_LogCritical(category: cint; fmt: PAnsiChar); cdecl; overload;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_LogCritical' {$ENDIF} {$ENDIF};

{*
 * Log a message with the specified category and priority.
 *
 * \param category the category of the message.
 * \param priority the priority of the message.
 * \param fmt a printf() style message format string.
 * \param ... additional parameters matching % tokens in the **fmt** string,
 *            if any.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_Log
 * \sa SDL_LogCritical
 * \sa SDL_LogDebug
 * \sa SDL_LogError
 * \sa SDL_LogInfo
 * \sa SDL_LogMessageV
 * \sa SDL_LogTrace
 * \sa SDL_LogVerbose
 * \sa SDL_LogWarn
  }
procedure SDL_LogMessage(category: cint; priority: TSDL_LogPriority; fmt: PAnsiChar; Args: array of const); cdecl; overload;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_LogMessage' {$ENDIF} {$ENDIF};
procedure SDL_LogMessage(category: cint; priority: TSDL_LogPriority; fmt: PAnsiChar); cdecl; overload;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_LogMessage' {$ENDIF} {$ENDIF};

{*
 * Log a message with the specified category and priority.
 *
 * \param category the category of the message.
 * \param priority the priority of the message.
 * \param fmt a printf() style message format string.
 * \param ap a variable argument list.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_Log
 * \sa SDL_LogCritical
 * \sa SDL_LogDebug
 * \sa SDL_LogError
 * \sa SDL_LogInfo
 * \sa SDL_LogMessage
 * \sa SDL_LogTrace
 * \sa SDL_LogVerbose
 * \sa SDL_LogWarn
  }
{ #todo : SDL3-for-Pascal: Examine how best to translate va_lists. }
//procedure SDL_LogMessageV(category: cint; priority: TSDL_LogPriority; fmt: PAnsiChar; ap: va_list); cdecl;
//  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_LogMessageV' {$ENDIF} {$ENDIF};

{*
 * The prototype for the log output callback function.
 *
 * This function is called by SDL when there is new text to be logged. A mutex
 * is held so that this function is never called by more than one thread at
 * once.
 *
 * \param userdata what was passed as `userdata` to
 *                 SDL_SetLogOutputFunction().
 * \param category the category of the message.
 * \param priority the priority of the message.
 * \param message the message being output.
 *
 * \since This datatype is available since SDL 3.2.0.
  }
type
  PPSDL_LogOutputFunction = ^PSDL_LogOutputFunction;
  PSDL_LogOutputFunction = ^TSDL_LogOutputFunction;
  TSDL_LogOutputFunction = procedure (userdata: Pointer; category: cint; priority: TSDL_LogPriority; message: PAnsiChar); cdecl;

  {*
 * Get the default log output function.
 *
 * \returns the default log output callback.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetLogOutputFunction
 * \sa SDL_GetLogOutputFunction
  }
function SDL_GetDefaultLogOutputFunction: TSDL_LogOutputFunction; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetDefaultLogOutputFunction' {$ENDIF} {$ENDIF};

{*
 * Get the current log output function.
 *
 * \param callback an SDL_LogOutputFunction filled in with the current log
 *                 callback.
 * \param userdata a pointer filled in with the pointer that is passed to
 *                 `callback`.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetDefaultLogOutputFunction
 * \sa SDL_SetLogOutputFunction
  }
procedure SDL_GetLogOutputFunction(callback: PSDL_LogOutputFunction; userdata: PPointer); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetLogOutputFunction' {$ENDIF} {$ENDIF};

{*
 * Replace the default log output function with one of your own.
 *
 * \param callback an SDL_LogOutputFunction to call instead of the default.
 * \param userdata a pointer that is passed to `callback`.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetDefaultLogOutputFunction
 * \sa SDL_GetLogOutputFunction
  }
procedure SDL_SetLogOutputFunction(callback: TSDL_LogOutputFunction; userdata: Pointer); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetLogOutputFunction' {$ENDIF} {$ENDIF};

