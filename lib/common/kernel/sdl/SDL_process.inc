{
  This file is part of:

    SDL3 for Pascal
    (https://github.com/PascalGameDevelopment/SDL3-for-Pascal)
    SPDX-License-Identifier: Zlib
}

{*
 * # CategoryProcess
 *
 * Process control support.
 *
 * These functions provide a cross-platform way to spawn and manage OS-level
 * processes.
 *
 * You can create a new subprocess with SDL_CreateProcess() and optionally
 * read and write to it using SDL_ReadProcess() or SDL_GetProcessInput() and
 * SDL_GetProcessOutput(). If more advanced functionality like chaining input
 * between processes is necessary, you can use
 * SDL_CreateProcessWithProperties().
 *
 * You can get the status of a created process with SDL_WaitProcess(), or
 * terminate the process with SDL_KillProcess().
 *
 * Don't forget to call SDL_DestroyProcess() to clean up, whether the process
 * process was killed, terminated on its own, or is still running!
  }

{*
 * An opaque handle representing a system process.
 *
 * \since This datatype is available since SDL 3.2.0.
 *
 * \sa SDL_CreateProcess
  }
type
  PPSDL_Process = ^PSDL_Process;
  PSDL_Process = type Pointer;

{*
 * Create a new process.
 *
 * The path to the executable is supplied in args[0]. args[1..N] are
 * additional arguments passed on the command line of the new process, and the
 * argument list should be terminated with a nil, e.g.:
 *
 * ```c
 * const char *args* =  "myprogram", "argument", nil ;
 * ```
 *
 * Setting pipe_stdio to true is equivalent to setting
 * `SDL_PROP_PROCESS_CREATE_STDIN_NUMBER` and
 * `SDL_PROP_PROCESS_CREATE_STDOUT_NUMBER` to `SDL_PROCESS_STDIO_APP`, and
 * will allow the use of SDL_ReadProcess() or SDL_GetProcessInput() and
 * SDL_GetProcessOutput().
 *
 * See SDL_CreateProcessWithProperties() for more details.
 *
 * \param args the path and arguments for the new process.
 * \param pipe_stdio true to create pipes to the process's standard input and
 *                   from the process's standard output, false for the process
 *                   to have no input and inherit the application's standard
 *                   output.
 * \returns the newly created and running process, or nil if the process
 *          couldn't be created.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateProcessWithProperties
 * \sa SDL_GetProcessProperties
 * \sa SDL_ReadProcess
 * \sa SDL_GetProcessInput
 * \sa SDL_GetProcessOutput
 * \sa SDL_KillProcess
 * \sa SDL_WaitProcess
 * \sa SDL_DestroyProcess
  }
function SDL_CreateProcess(args: PPAnsiChar; pipe_stdio: Boolean): PSDL_Process; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CreateProcess' {$ENDIF} {$ENDIF};

{*
 * Description of where standard I/O should be directed when creating a
 * process.
 *
 * If a standard I/O stream is set to SDL_PROCESS_STDIO_INHERITED, it will go
 * to the same place as the application's I/O stream. This is the default for
 * standard output and standard error.
 *
 * If a standard I/O stream is set to SDL_PROCESS_STDIO_NULL, it is connected
 * to `NUL:` on Windows and `/dev/null` on POSIX systems. This is the default
 * for standard input.
 *
 * If a standard I/O stream is set to SDL_PROCESS_STDIO_APP, it is connected
 * to a new SDL_IOStream that is available to the application. Standard input
 * will be available as `SDL_PROP_PROCESS_STDIN_POINTER` and allows
 * SDL_GetProcessInput(), standard output will be available as
 * `SDL_PROP_PROCESS_STDOUT_POINTER` and allows SDL_ReadProcess() and
 * SDL_GetProcessOutput(), and standard error will be available as
 * `SDL_PROP_PROCESS_STDERR_POINTER` in the properties for the created
 * process.
 *
 * If a standard I/O stream is set to SDL_PROCESS_STDIO_REDIRECT, it is
 * connected to an existing SDL_IOStream provided by the application. Standard
 * input is provided using `SDL_PROP_PROCESS_CREATE_STDIN_POINTER`, standard
 * output is provided using `SDL_PROP_PROCESS_CREATE_STDOUT_POINTER`, and
 * standard error is provided using `SDL_PROP_PROCESS_CREATE_STDERR_POINTER`
 * in the creation properties. These existing streams should be closed by the
 * application once the new process is created.
 *
 * In order to use an SDL_IOStream with SDL_PROCESS_STDIO_REDIRECT, it must
 * have `SDL_PROP_IOSTREAM_WINDOWS_HANDLE_POINTER` or
 * `SDL_PROP_IOSTREAM_FILE_DESCRIPTOR_NUMBER` set. This is true for streams
 * representing files and process I/O.
 *
 * \since This enum is available since SDL 3.2.0.
 *
 * \sa SDL_CreateProcessWithProperties
 * \sa SDL_GetProcessProperties
 * \sa SDL_ReadProcess
 * \sa SDL_GetProcessInput
 * \sa SDL_GetProcessOutput
  }
type
  PPSDL_ProcessIO = ^PSDL_ProcessIO;
  PSDL_ProcessIO = ^TSDL_ProcessIO;
  TSDL_ProcessIO = type Integer;
const
  SDL_PROCESS_STDIO_INHERITED  = TSDL_ProcessIO(0); {*< The I/O stream is inherited from the application.  }
  SDL_PROCESS_STDIO_NULL  = TSDL_ProcessIO(1);      {*< The I/O stream is ignored.  }
  SDL_PROCESS_STDIO_APP  = TSDL_ProcessIO(2);       {*< The I/O stream is connected to a new SDL_IOStream that the application can read or write  }
  SDL_PROCESS_STDIO_REDIRECT  = TSDL_ProcessIO(3);  {*< The I/O stream is redirected to an existing SDL_IOStream.  }

{*
 * Create a new process with the specified properties.
 *
 * These are the supported properties:
 *
 * - `SDL_PROP_PROCESS_CREATE_ARGS_POINTER`: an array of strings containing
 *   the program to run, any arguments, and a NULL pointer, e.g. const char
 *   *args[] = ( "myprogram", "argument", NULL ). This is a required property.
 * - `SDL_PROP_PROCESS_CREATE_ENVIRONMENT_POINTER`: an SDL_Environment
 *   pointer. If this property is set, it will be the entire environment for
 *   the process, otherwise the current environment is used.
 * - `SDL_PROP_PROCESS_CREATE_WORKING_DIRECTORY_STRING`: a UTF-8 encoded
 *   string representing the working directory for the process, defaults to
 *   the current working directory.
 * - `SDL_PROP_PROCESS_CREATE_STDIN_NUMBER`: an SDL_ProcessIO value describing
 *   where standard input for the process comes from, defaults to
 *   `SDL_PROCESS_STDIO_NULL`.
 * - `SDL_PROP_PROCESS_CREATE_STDIN_POINTER`: an SDL_IOStream pointer used for
 *   standard input when `SDL_PROP_PROCESS_CREATE_STDIN_NUMBER` is set to
 *   `SDL_PROCESS_STDIO_REDIRECT`.
 * - `SDL_PROP_PROCESS_CREATE_STDOUT_NUMBER`: an SDL_ProcessIO value
 *   describing where standard output for the process goes to, defaults to
 *   `SDL_PROCESS_STDIO_INHERITED`.
 * - `SDL_PROP_PROCESS_CREATE_STDOUT_POINTER`: an SDL_IOStream pointer used
 *   for standard output when `SDL_PROP_PROCESS_CREATE_STDOUT_NUMBER` is set
 *   to `SDL_PROCESS_STDIO_REDIRECT`.
 * - `SDL_PROP_PROCESS_CREATE_STDERR_NUMBER`: an SDL_ProcessIO value
 *   describing where standard error for the process goes to, defaults to
 *   `SDL_PROCESS_STDIO_INHERITED`.
 * - `SDL_PROP_PROCESS_CREATE_STDERR_POINTER`: an SDL_IOStream pointer used
 *   for standard error when `SDL_PROP_PROCESS_CREATE_STDERR_NUMBER` is set to
 *   `SDL_PROCESS_STDIO_REDIRECT`.
 * - `SDL_PROP_PROCESS_CREATE_STDERR_TO_STDOUT_BOOLEAN`: true if the error
 *   output of the process should be redirected into the standard output of
 *   the process. This property has no effect if
 *   `SDL_PROP_PROCESS_CREATE_STDERR_NUMBER` is set.
 * - `SDL_PROP_PROCESS_CREATE_BACKGROUND_BOOLEAN`: true if the process should
 *   run in the background. In this case the default input and output is
 *   `SDL_PROCESS_STDIO_NULL` and the exitcode of the process is not
 *   available, and will always be 0.
 * - `SDL_PROP_PROCESS_CREATE_CMDLINE_STRING`: a string containing the program
 *   to run and any parameters. This string is passed directly to
 *   `CreateProcess` on Windows, and does nothing on other platforms. This
 *   property is only important if you want to start programs that does
 *   non-standard command-line processing, and in most cases using
 *   `SDL_PROP_PROCESS_CREATE_ARGS_POINTER` is sufficient.
 *
 * On POSIX platforms, wait() and waitpid(-1, ...) should not be called, and
 * SIGCHLD should not be ignored or handled because those would prevent SDL
 * from properly tracking the lifetime of the underlying process. You should
 * use SDL_WaitProcess() instead.
 *
 * \param props the properties to use.
 * \returns the newly created and running process, or nil if the process
 *          couldn't be created.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateProcess
 * \sa SDL_GetProcessProperties
 * \sa SDL_ReadProcess
 * \sa SDL_GetProcessInput
 * \sa SDL_GetProcessOutput
 * \sa SDL_KillProcess
 * \sa SDL_WaitProcess
 * \sa SDL_DestroyProcess
  }
function SDL_CreateProcessWithProperties(props: TSDL_PropertiesID): PSDL_Process; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CreateProcessWithProperties' {$ENDIF} {$ENDIF};

const
  SDL_PROP_PROCESS_CREATE_ARGS_POINTER = 'SDL.process.create.args';
  SDL_PROP_PROCESS_CREATE_ENVIRONMENT_POINTER = 'SDL.process.create.environment';
  SDL_PROP_PROCESS_CREATE_WORKING_DIRECTORY_STRING = 'SDL.process.create.working_directory';
  SDL_PROP_PROCESS_CREATE_STDIN_NUMBER = 'SDL.process.create.stdin_option';
  SDL_PROP_PROCESS_CREATE_STDIN_POINTER = 'SDL.process.create.stdin_source';
  SDL_PROP_PROCESS_CREATE_STDOUT_NUMBER = 'SDL.process.create.stdout_option';
  SDL_PROP_PROCESS_CREATE_STDOUT_POINTER = 'SDL.process.create.stdout_source';
  SDL_PROP_PROCESS_CREATE_STDERR_NUMBER = 'SDL.process.create.stderr_option';
  SDL_PROP_PROCESS_CREATE_STDERR_POINTER = 'SDL.process.create.stderr_source';
  SDL_PROP_PROCESS_CREATE_STDERR_TO_STDOUT_BOOLEAN = 'SDL.process.create.stderr_to_stdout';
  SDL_PROP_PROCESS_CREATE_BACKGROUND_BOOLEAN = 'SDL.process.create.background';
  SDL_PROP_PROCESS_CREATE_CMDLINE_STRING = 'SDL.process.create.cmdline';

{*
 * Get the properties associated with a process.
 *
 * The following read-only properties are provided by SDL:
 *
 * - `SDL_PROP_PROCESS_PID_NUMBER`: the process ID of the process.
 * - `SDL_PROP_PROCESS_STDIN_POINTER`: an SDL_IOStream that can be used to
 *   write input to the process, if it was created with
 *   `SDL_PROP_PROCESS_CREATE_STDIN_NUMBER` set to `SDL_PROCESS_STDIO_APP`.
 * - `SDL_PROP_PROCESS_STDOUT_POINTER`: a non-blocking SDL_IOStream that can
 *   be used to read output from the process, if it was created with
 *   `SDL_PROP_PROCESS_CREATE_STDOUT_NUMBER` set to `SDL_PROCESS_STDIO_APP`.
 * - `SDL_PROP_PROCESS_STDERR_POINTER`: a non-blocking SDL_IOStream that can
 *   be used to read error output from the process, if it was created with
 *   `SDL_PROP_PROCESS_CREATE_STDERR_NUMBER` set to `SDL_PROCESS_STDIO_APP`.
 * - `SDL_PROP_PROCESS_BACKGROUND_BOOLEAN`: true if the process is running in
 *   the background.
 *
 * \param process the process to query.
 * \returns a valid property ID on success or 0 on failure; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateProcess
 * \sa SDL_CreateProcessWithProperties
  }
function SDL_GetProcessProperties(process: PSDL_Process): TSDL_PropertiesID; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetProcessProperties' {$ENDIF} {$ENDIF};

const
  SDL_PROP_PROCESS_PID_NUMBER = 'SDL.process.pid';
  SDL_PROP_PROCESS_STDIN_POINTER = 'SDL.process.stdin';
  SDL_PROP_PROCESS_STDOUT_POINTER = 'SDL.process.stdout';
  SDL_PROP_PROCESS_STDERR_POINTER = 'SDL.process.stderr';
  SDL_PROP_PROCESS_BACKGROUND_BOOLEAN = 'SDL.process.background';

{*
 * Read all the output from a process.
 *
 * If a process was created with I/O enabled, you can use this function to
 * read the output. This function blocks until the process is complete,
 * capturing all output, and providing the process exit code.
 *
 * The data is allocated with a zero byte at the end (null terminated) for
 * convenience. This extra byte is not included in the value reported via
 * `datasize`.
 *
 * The data should be freed with SDL_free().
 *
 * \param process The process to read.
 * \param datasize a Pointer filled in with the number of bytes read, may be
 *                 nil.
 * \param exitcode a Pointer filled in with the process exit code if the
 *                 process has exited, may be nil.
 * \returns the data or nil on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function is not thread safe.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateProcess
 * \sa SDL_CreateProcessWithProperties
 * \sa SDL_DestroyProcess
  }
function SDL_ReadProcess(process: PSDL_Process; datasize: pcsize_t; exitcode: pcint): Pointer; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ReadProcess' {$ENDIF} {$ENDIF};

{*
 * Get the SDL_IOStream associated with process standard input.
 *
 * The process must have been created with SDL_CreateProcess() and pipe_stdio
 * set to true, or with SDL_CreateProcessWithProperties() and
 * `SDL_PROP_PROCESS_CREATE_STDIN_NUMBER` set to `SDL_PROCESS_STDIO_APP`.
 *
 * Writing to this stream can return less data than expected if the process
 * hasn't read its input. It may be blocked waiting for its output to be read,
 * if so you may need to call SDL_GetProcessOutput() and read the output in
 * parallel with writing input.
 *
 * \param process The process to get the input stream for.
 * \returns the input stream or nil on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateProcess
 * \sa SDL_CreateProcessWithProperties
 * \sa SDL_GetProcessOutput
  }
function SDL_GetProcessInput(process: PSDL_Process): PSDL_IOStream; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetProcessInput' {$ENDIF} {$ENDIF};

{*
 * Get the SDL_IOStream associated with process standard output.
 *
 * The process must have been created with SDL_CreateProcess() and pipe_stdio
 * set to true, or with SDL_CreateProcessWithProperties() and
 * `SDL_PROP_PROCESS_CREATE_STDOUT_NUMBER` set to `SDL_PROCESS_STDIO_APP`.
 *
 * Reading from this stream can return 0 with SDL_GetIOStatus() returning
 * SDL_IO_STATUS_NOT_READY if no output is available yet.
 *
 * \param process The process to get the output stream for.
 * \returns the output stream or nil on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateProcess
 * \sa SDL_CreateProcessWithProperties
 * \sa SDL_GetProcessInput
  }
function SDL_GetProcessOutput(process: PSDL_Process): PSDL_IOStream; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetProcessOutput' {$ENDIF} {$ENDIF};

{*
 * Stop a process.
 *
 * \param process The process to stop.
 * \param force true to terminate the process immediately, false to try to
 *              stop the process gracefully. In general you should try to stop
 *              the process gracefully first as terminating a process may
 *              leave it with half-written data or in some other unstable
 *              state.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function is not thread safe.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateProcess
 * \sa SDL_CreateProcessWithProperties
 * \sa SDL_WaitProcess
 * \sa SDL_DestroyProcess
  }
function SDL_KillProcess(process: PSDL_Process; force: Boolean): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_KillProcess' {$ENDIF} {$ENDIF};

{*
 * Wait for a process to finish.
 *
 * This can be called multiple times to get the status of a process.
 *
 * The exit code will be the exit code of the process if it terminates
 * normally, a negative signal if it terminated due to a signal, or -255
 * otherwise. It will not be changed if the process is still running.
 *
 * If you create a process with standard output piped to the application
 * (`pipe_stdio` being true) then you should read all of the process output
 * before calling SDL_WaitProcess(). If you don't do this the process might be
 * blocked indefinitely waiting for output to be read and SDL_WaitProcess()
 * will never return true;
 *
 * \param process The process to wait for.
 * \param block If true, block until the process finishes; otherwise, report
 *              on the process' status.
 * \param exitcode a Pointer filled in with the process exit code if the
 *                 process has exited, may be nil.
 * \returns true if the process exited, false otherwise.
 *
 * \threadsafety This function is not thread safe.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateProcess
 * \sa SDL_CreateProcessWithProperties
 * \sa SDL_KillProcess
 * \sa SDL_DestroyProcess
  }
function SDL_WaitProcess(process: PSDL_Process; block: Boolean; exitcode: pcint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_WaitProcess' {$ENDIF} {$ENDIF};

{*
 * Destroy a previously created process object.
 *
 * Note that this does not stop the process, just destroys the SDL object used
 * to track it. If you want to stop the process you should use
 * SDL_KillProcess().
 *
 * \param process The process object to destroy.
 *
 * \threadsafety This function is not thread safe.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateProcess
 * \sa SDL_CreateProcessWithProperties
 * \sa SDL_KillProcess
  }
procedure SDL_DestroyProcess(process: PSDL_Process); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_DestroyProcess' {$ENDIF} {$ENDIF};

