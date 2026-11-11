{
  This file is part of:

    SDL3 for Pascal
    (https://github.com/PascalGameDevelopment/SDL3-for-Pascal)
    SPDX-License-Identifier: Zlib
}

{*
 * A signed 8-bit integer type.
 *
 * \since This macro is available since SDL 3.2.0.
  }
type
  ppcint8_t=^pcint8_t;
  pcint8_t=^cint8_t;
  cint8_t=cint8;
const
  SDL_MAX_SINT8=cint8($7F);                 { 127  }
  SDL_MIN_SINT8=cint8(not ($7F));           { -128  }

{*
 * An unsigned 8-bit integer type.
 *
 * \since This macro is available since SDL 3.2.0.
  }
type
  ppcuint8_t=^pcuint8_t;
  pcuint8_t=^cuint8_t;
  cuint8_t=cuint8;
const
  SDL_MAX_UINT8=cuint8($FF);                { 255  }
  SDL_MIN_UINT8=cuint8($00);                { 0  }

{*
 * A signed 16-bit integer type.
 *
 * \since This macro is available since SDL 3.2.0.
  }
type
  ppcint16_t=^pcint16_t;
  pcint16_t=^cint16_t;
  cint16_t=cint16;
const
  SDL_MAX_SINT16=cint16($7FFF);             { 32767  }
  SDL_MIN_SINT16=cint16(not ($7FFF));      { -32768  }

{*
 * An unsigned 16-bit integer type.
 *
 * \since This macro is available since SDL 3.2.0.
  }
type
  ppcuint16_t=^pcuint16_t;
  pcuint16_t=^cuint16_t;
  cuint16_t=cuint16;
const
  SDL_MAX_UINT16=cuint16($FFFF);           { 65535  }
  SDL_MIN_UINT16=cuint16($0000);           { 0  }

{*
 * A signed 32-bit integer type.
 *
 * \since This macro is available since SDL 3.2.0.
  }
type
  ppcint32_t=^pcint32_t;
  pcint32_t=^cint32_t;
  cint32_t=cint32;
const
  SDL_MAX_SINT32=cint32($7FFFFFFF);        { 2147483647  }
  SDL_MIN_SINT32=cint32(not ($7FFFFFFF));  { -2147483648  }

{*
 * An unsigned 32-bit integer type.
 *
 * \since This macro is available since SDL 3.2.0.
  }
type
  ppcuint32_t=^pcuint32_t;
  pcuint32_t=^cuint32_t;
  cuint32_t=cuint32;
const
  SDL_MAX_UINT32=cuint32($FFFFFFFF);   { 4294967295  }
  SDL_MIN_UINT32=cuint32($00000000);   { 0  }

{*
 * A signed 64-bit integer type.
 *
 * \since This macro is available since SDL 3.2.0.
 *
 * \sa SDL_SINT64_C
  }
type
  ppcint64_t=^pcint64_t;
  pcint64_t=^cint64_t;
  cint64_t=cint64;
const
  { #note : SDL3-for-Pascal:
            The macro SDL_SINT64_C converts the values to guarantee their size.
            We do this simply by converting to cint64 here. }
  SDL_MAX_SINT64=cint64($7FFFFFFFFFFFFFFF);         { 9223372036854775807  }
  SDL_MIN_SINT64= not (cint64($7FFFFFFFFFFFFFFF));  { -9223372036854775808  }

{*
 * An unsigned 64-bit integer type.
 *
 * \since This macro is available since SDL 3.2.0.
 *
 * \sa SDL_UINT64_C
  }
type
  ppcuint64_t=^pcuint64_t;
  pcuint64_t=^cuint64_t;
  cuint64_t=cuint64;
const
  { #note : SDL3-for-Pascal:
            The macro SDL_SUINT64_C converts the values to guarantee their size.
            We do this simply by converting to cuint64 here. }
  SDL_MAX_UINT64=cuint64($FFFFFFFFFFFFFFFF);  { 18446744073709551615  }
  SDL_MIN_UINT64=cuint64($0000000000000000);  { 0  }

{*
 * SDL times are signed, 64-bit integers representing nanoseconds since the
 * Unix epoch (Jan 1, 1970).
 *
 * They can be converted between POSIX time_t values with SDL_NS_TO_SECONDS()
 * and SDL_SECONDS_TO_NS(), and between Windows FILETIME values with
 * SDL_TimeToWindows() and SDL_TimeFromWindows().
 *
 * \since This macro is available since SDL 3.2.0.
 *
 * \sa SDL_MAX_SINT64
 * \sa SDL_MIN_SINT64
  }
type
  PPSDL_Time = ^PSDL_Time;
  PSDL_Time = ^TSDL_Time;
  TSDL_Time = cint64;

const
  SDL_MAX_TIME = SDL_MAX_SINT64;
  SDL_MIN_TIME = SDL_MIN_SINT64;

{*
 * Epsilon constant, used for comparing floating-point numbers.
 *
 * Equals by default to platform-defined `FLT_EPSILON`, or
 * `1.1920928955078125e-07F` if that's not available.
 *
 * \since This macro is available since SDL 3.1.3.
  }
const
  SDL_FLT_EPSILON = cfloat(1.1920928955078125e-07);

(* -- Memory management functions -- *)

{*
 * Allocate uninitialized memory.
 *
 * The allocated memory returned by this function must be freed with
 * SDL_free().
 *
 * If `size` is 0, it will be set to 1.
 *
 * If the allocation is successful, the returned pointer is guaranteed to be
 * aligned to either the *fundamental alignment* (`alignof(max_align_t)` in
 * C11 and later) or `2 * sizeof(Pointer)`, whichever is smaller. Use
 * SDL_aligned_alloc() if you need to allocate memory aligned to an alignment
 * greater than this guarantee.
 *
 * \param size the size to allocate.
 * \returns a pointer to the allocated memory, or NIL if allocation failed.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_free
 * \sa SDL_calloc
 * \sa SDL_realloc
 * \sa SDL_aligned_alloc
 *}
function SDL_malloc(size: csize_t): Pointer; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_malloc' {$ENDIF} {$ENDIF};

{*
 * Allocate a zero-initialized array.
 *
 * The memory returned by this function must be freed with SDL_free().
 *
 * If either of `nmemb` or `size` is 0, they will both be set to 1.
 *
 * If the allocation is successful, the returned pointer is guaranteed to be
 * aligned to either the *fundamental alignment* (`alignof(max_align_t)` in
 * C11 and later) or `2 * sizeof(Pointer)`, whichever is smaller.
 *
 * \param nmemb the number of elements in the array.
 * \param size the size of each element of the array.
 * \returns a pointer to the allocated array, or NIL if allocation failed.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_free
 * \sa SDL_malloc
 * \sa SDL_realloc
 *}
function SDL_calloc(nmemb, size: csize_t): Pointer; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_calloc' {$ENDIF} {$ENDIF};

{*
 * Change the size of allocated memory.
 *
 * The memory returned by this function must be freed with SDL_free().
 *
 * If `size` is 0, it will be set to 1. Note that this is unlike some other C
 * runtime `realloc` implementations, which may treat `realloc(mem, 0)` the
 * same way as `free(mem)`.
 *
 * If `mem` is NIL, the behavior of this function is equivalent to
 * SDL_malloc(). Otherwise, the function can have one of three possible
 * outcomes:
 *
 * - If it returns the same pointer as `mem`, it means that `mem` was resized
 *   in place without freeing.
 * - If it returns a different non-NIL pointer, it means that `mem` was freed
 *   and cannot be dereferenced anymore.
 * - If it returns NIL (indicating failure), then `mem` will remain valid and
 *   must still be freed with SDL_free().
 *
 * If the allocation is successfully resized, the returned pointer is
 * guaranteed to be aligned to either the *fundamental alignment*
 * (`alignof(max_align_t)` in C11 and later) or `2 * sizeof(Pointer)`,
 * whichever is smaller.
 *
 * \param mem a pointer to allocated memory to reallocate, or NIL.
 * \param size the new size of the memory.
 * \returns a pointer to the newly allocated memory, or NIL if allocation
 *          failed.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_free
 * \sa SDL_malloc
 * \sa SDL_calloc
 *}
function SDL_realloc(mem: Pointer; size: csize_t): Pointer; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_realloc' {$ENDIF} {$ENDIF};

{*
 * Free allocated memory.
 *
 * The pointer is no longer valid after this call and cannot be dereferenced
 * anymore.
 *
 * If `mem` is NIL, this function does nothing.
 *
 * \param mem a pointer to allocated memory, or NIL.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_malloc
 * \sa SDL_calloc
 * \sa SDL_realloc
 *}
procedure SDL_free(mem: Pointer); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_free' {$ENDIF} {$ENDIF};

type
  PPSDL_malloc_func = ^PSDL_malloc_func;
  PSDL_malloc_func = ^TSDL_malloc_func;
  {*
   * A callback used to implement SDL_malloc().
   *
   * SDL will always ensure that the passed `size` is greater than 0.
   *
   * \param size the size to allocate.
   * \returns a pointer to the allocated memory, or NIL if allocation failed.
   *
   * \threadsafety It should be safe to call this callback from any thread.
   *
   * \since This datatype is available since SDL 3.2.0.
   *
   * \sa SDL_malloc
   * \sa SDL_GetOriginalMemoryFunctions
   * \sa SDL_GetMemoryFunctions
   * \sa SDL_SetMemoryFunctions
   *}
  TSDL_malloc_func = function(size: csize_t): Pointer; cdecl;

  PPSDL_calloc_func = ^PSDL_calloc_func;
  PSDL_calloc_func = ^TSDL_calloc_func;
  {*
   * A callback used to implement SDL_calloc().
   *
   * SDL will always ensure that the passed `nmemb` and `size` are both greater
   * than 0.
   *
   * \param nmemb the number of elements in the array.
   * \param size the size of each element of the array.
   * \returns a pointer to the allocated array, or NIL if allocation failed.
   *
   * \threadsafety It should be safe to call this callback from any thread.
   *
   * \since This datatype is available since SDL 3.2.0.
   *
   * \sa SDL_calloc
   * \sa SDL_GetOriginalMemoryFunctions
   * \sa SDL_GetMemoryFunctions
   * \sa SDL_SetMemoryFunctions
   *}
  TSDL_calloc_func = function(nmemb, size: csize_t): Pointer; cdecl;

  PPSDL_realloc_func = ^PSDL_realloc_func;
  PSDL_realloc_func = ^TSDL_realloc_func;
  {*
   * A callback used to implement SDL_realloc().
   *
   * SDL will always ensure that the passed `size` is greater than 0.
   *
   * \param mem a pointer to allocated memory to reallocate, or NIL.
   * \param size the new size of the memory.
   * \returns a pointer to the newly allocated memory, or NIL if allocation
   *          failed.
   *
   * \threadsafety It should be safe to call this callback from any thread.
   *
   * \since This datatype is available since SDL 3.2.0.
   *
   * \sa SDL_realloc
   * \sa SDL_GetOriginalMemoryFunctions
   * \sa SDL_GetMemoryFunctions
   * \sa SDL_SetMemoryFunctions
   *}
  TSDL_realloc_func = function(mem: Pointer; size: csize_t): Pointer; cdecl;

  PPSDL_free_func = ^PSDL_free_func;
  PSDL_free_func = ^TSDL_free_func;
  {*
   * A callback used to implement SDL_free().
   *
   * SDL will always ensure that the passed `mem` is a non-NIL pointer.
   *
   * \param mem a pointer to allocated memory.
   *
   * \threadsafety It should be safe to call this callback from any thread.
   *
   * \since This datatype is available since SDL 3.2.0.
   *
   * \sa SDL_free
   * \sa SDL_GetOriginalMemoryFunctions
   * \sa SDL_GetMemoryFunctions
   * \sa SDL_SetMemoryFunctions
   *}
  TSDL_free_func = procedure(mem: Pointer); cdecl;

{*
 * Get the original set of SDL memory functions.
 *
 * This is what SDL_malloc and friends will use by default, if there has been
 * no call to SDL_SetMemoryFunctions. This is not necessarily using the C
 * runtime's `malloc` functions behind the scenes! Different platforms and
 * build configurations might do any number of unexpected things.
 *
 * \param malloc_func filled with malloc function.
 * \param calloc_func filled with calloc function.
 * \param realloc_func filled with realloc function.
 * \param free_func filled with free function.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *}
procedure SDL_GetOriginalMemoryFunctions(
  malloc_func: PSDL_malloc_func;
  calloc_func: PSDL_calloc_func;
  realloc_func: PSDL_realloc_func;
  free_func: PSDL_free_func
); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetOriginalMemoryFunctions' {$ENDIF} {$ENDIF};

{*
 * Get the current set of SDL memory functions.
 *
 * \param malloc_func filled with malloc function.
 * \param calloc_func filled with calloc function.
 * \param realloc_func filled with realloc function.
 * \param free_func filled with free function.
 *
 * \threadsafety This does not hold a lock, so do not call this in the
 *               unlikely event of a background thread calling
 *               SDL_SetMemoryFunctions simultaneously.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetMemoryFunctions
 * \sa SDL_GetOriginalMemoryFunctions
 *}
procedure SDL_GetMemoryFunctions(
  malloc_func: PSDL_malloc_func;
  calloc_func: PSDL_calloc_func;
  realloc_func: PSDL_realloc_func;
  free_func: PSDL_free_func
); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetMemoryFunctions' {$ENDIF} {$ENDIF};

{*
 * Replace SDL's memory allocation functions with a custom set.
 *
 * It is not safe to call this function once any allocations have been made,
 * as future calls to SDL_free will use the new allocator, even if they came
 * from an SDL_malloc made with the old one!
 *
 * If used, usually this needs to be the first call made into the SDL library,
 * if not the very first thing done at program startup time.
 *
 * \param malloc_func custom malloc function.
 * \param calloc_func custom calloc function.
 * \param realloc_func custom realloc function.
 * \param free_func custom free function.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread, but one
 *               should not replace the memory functions once any allocations
 *               are made!
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetMemoryFunctions
 * \sa SDL_GetOriginalMemoryFunctions
 *}
function SDL_SetMemoryFunctions(
  malloc_func: TSDL_malloc_func;
  calloc_func: TSDL_calloc_func;
  realloc_func: TSDL_realloc_func;
  free_func: TSDL_free_func
): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetMemoryFunctions' {$ENDIF} {$ENDIF};

{*
 * Allocate memory aligned to a specific alignment.
 *
 * The memory returned by this function must be freed with SDL_aligned_free(),
 * _not_ SDL_free().
 *
 * If `alignment` is less than the size of `void *`, it will be increased to
 * match that.
 *
 * The returned memory address will be a multiple of the alignment value, and
 * the size of the memory allocated will be a multiple of the alignment value.
 *
 * \param alignment the alignment of the memory.
 * \param size the size to allocate.
 * \returns a pointer to the aligned memory, or NIL if allocation failed.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_aligned_free
 *}
function SDL_aligned_alloc(alignment, size: csize_t): Pointer; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_aligned_alloc' {$ENDIF} {$ENDIF};

{*
 * Free memory allocated by SDL_aligned_alloc().
 *
 * The pointer is no longer valid after this call and cannot be dereferenced
 * anymore.
 *
 * If `mem` is NIL, this function does nothing.
 *
 * \param mem a pointer previously returned by SDL_aligned_alloc(), or NIL.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_aligned_alloc
 *}
procedure SDL_aligned_free(mem: Pointer); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_aligned_free' {$ENDIF} {$ENDIF};

{*
 * Get the number of outstanding (unfreed) allocations.
 *
 * \returns the number of allocations or -1 if allocation counting is
 *          disabled.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *}
function SDL_GetNumAllocations(): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetNumAllocations' {$ENDIF} {$ENDIF};

(* -- Environment variables manipulation functions -- *)

type
  PPSDL_Environment = ^PSDL_Environment;
  {*
   * A thread-safe set of environment variables
   *
   * \since This struct is available since SDL 3.2.0.
   *
   * \sa SDL_GetEnvironment
   * \sa SDL_CreateEnvironment
   * \sa SDL_GetEnvironmentVariable
   * \sa SDL_GetEnvironmentVariables
   * \sa SDL_SetEnvironmentVariable
   * \sa SDL_UnsetEnvironmentVariable
   * \sa SDL_DestroyEnvironment
   *}
  PSDL_Environment = type Pointer;

{*
 * Get the process environment.
 *
 * This is initialized at application start and is not affected by setenv()
 * and unsetenv() calls after that point. Use SDL_SetEnvironmentVariable() and
 * SDL_UnsetEnvironmentVariable() if you want to modify this environment, or
 * SDL_setenv_unsafe() or SDL_unsetenv_unsafe() if you want changes to persist
 * in the C runtime environment after SDL_Quit().
 *
 * \returns a pointer to the environment for the process or NIL on failure;
 *          call SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetEnvironmentVariable
 * \sa SDL_GetEnvironmentVariables
 * \sa SDL_SetEnvironmentVariable
 * \sa SDL_UnsetEnvironmentVariable
 *}
function SDL_GetEnvironment(): PSDL_Environment; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetEnvironment' {$ENDIF} {$ENDIF};

{**
 * Create a set of environment variables
 *
 * \param populated true to initialize it from the C runtime environment,
 *                  false to create an empty environment.
 * \returns a pointer to the new environment or NIL on failure; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety If `populated` is false, it is safe to call this function
 *               from any thread, otherwise it is safe if no other threads are
 *               calling setenv() or unsetenv()
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetEnvironmentVariable
 * \sa SDL_GetEnvironmentVariables
 * \sa SDL_SetEnvironmentVariable
 * \sa SDL_UnsetEnvironmentVariable
 * \sa SDL_DestroyEnvironment
 *}
function SDL_CreateEnvironment(populated: Boolean): PSDL_Environment; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CreateEnvironment' {$ENDIF} {$ENDIF};

{*
 * Get the value of a variable in the environment.
 *
 * \param env the environment to query.
 * \param name the name of the variable to get.
 * \returns a pointer to the (read-only) value of the variable
 *          or NIL if it can't be found.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetEnvironment
 * \sa SDL_CreateEnvironment
 * \sa SDL_GetEnvironmentVariables
 * \sa SDL_SetEnvironmentVariable
 * \sa SDL_UnsetEnvironmentVariable
 *}
function SDL_GetEnvironmentVariable(env: PSDL_Environment; const name: PAnsiChar): PAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetEnvironmentVariable' {$ENDIF} {$ENDIF};

{*
 * Get all variables in the environment.
 *
 * \param env the environment to query.
 * \returns a NIL terminated array of pointers to environment variables in
 *          the form "variable=value" or NIL on failure; call SDL_GetError()
 *          for more information. This is a single allocation that should be
 *          freed with SDL_free() when it is no longer needed.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetEnvironment
 * \sa SDL_CreateEnvironment
 * \sa SDL_GetEnvironmentVariables
 * \sa SDL_SetEnvironmentVariable
 * \sa SDL_UnsetEnvironmentVariable
 *}
function SDL_GetEnvironmentVariables(env: PSDL_Environment): PPAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetEnvironmentVariables' {$ENDIF} {$ENDIF};

{**
 * Set the value of a variable in the environment.
 *
 * \param env the environment to modify.
 * \param name the name of the variable to set.
 * \param value the value of the variable to set.
 * \param overwrite true to overwrite the variable if it exists, false to
 *                  return success without setting the variable if it already
 *                  exists.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetEnvironment
 * \sa SDL_CreateEnvironment
 * \sa SDL_GetEnvironmentVariable
 * \sa SDL_GetEnvironmentVariables
 * \sa SDL_UnsetEnvironmentVariable
 *}
function SDL_SetEnvironmentVariable(env: PSDL_Environment; const name, value: PAnsiChar; overwrite: Boolean): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetEnvironmentVariable' {$ENDIF} {$ENDIF};

{*
 * Clear a variable from the environment.
 *
 * \param env the environment to modify.
 * \param name the name of the variable to unset.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetEnvironment
 * \sa SDL_CreateEnvironment
 * \sa SDL_GetEnvironmentVariable
 * \sa SDL_GetEnvironmentVariables
 * \sa SDL_SetEnvironmentVariable
 * \sa SDL_UnsetEnvironmentVariable
 *}
function SDL_UnsetEnvironmentVariable(env: PSDL_Environment; const name: PAnsiChar): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_UnsetEnvironmentVariable' {$ENDIF} {$ENDIF};

{*
 * Destroy a set of environment variables.
 *
 * \param env the environment to destroy.
 *
 * \threadsafety It is safe to call this function from any thread, as long as
 *               the environment is no longer in use.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateEnvironment
 *}
procedure SDL_DestroyEnvironment(env: PSDL_Environment); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_DestroyEnvironment' {$ENDIF} {$ENDIF};

{*
 * Get the value of a variable in the environment.
 *
 * This function uses SDL's cached copy of the environment and is thread-safe.
 *
 * \param name the name of the variable to get.
 * \returns a pointer to the (read-only) value of the variable
 *          or NIL if it can't be found.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *}
function SDL_getenv(const name: PAnsiChar): PAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_getenv' {$ENDIF} {$ENDIF};

{*
 * Get the value of a variable in the environment.
 *
 * This function bypasses SDL's cached copy of the environment and is not
 * thread-safe.
 *
 * \param name the name of the variable to get.
 * \returns a pointer to the (read-only) value of the variable
 *          or NIL if it can't be found.
 *
 * \threadsafety This function is not thread safe, consider using SDL_getenv()
 *               instead.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_getenv
 *}
function SDL_getenv_unsafe(const name: PAnsiChar): PAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_getenv_unsafe' {$ENDIF} {$ENDIF};

{*
 * Set the value of a variable in the environment.
 *
 * \param name the name of the variable to set.
 * \param value the value of the variable to set.
 * \param overwrite 1 to overwrite the variable if it exists, 0 to return
 *                  success without setting the variable if it already exists.
 * \returns 0 on success, -1 on error.
 *
 * \threadsafety This function is not thread safe, consider using
 *               SDL_SetEnvironmentVariable() instead.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetEnvironmentVariable
 *}
function SDL_setenv_unsafe(const name, value: PAnsiChar; overwrite: cint): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_setenv_unsafe' {$ENDIF} {$ENDIF};

{*
 * Clear a variable from the environment.
 *
 * \param name the name of the variable to unset.
 * \returns 0 on success, -1 on error.
 *
 * \threadsafety This function is not thread safe, consider using
 *               SDL_UnsetEnvironmentVariable() instead.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_UnsetEnvironmentVariable
 *}
function SDL_unsetenv_unsafe(const name: PAnsiChar): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_unsetenv_unsafe' {$ENDIF} {$ENDIF};

(* -- Character classification functions -- *)

{*
 * Query if a character is alphabetic (a letter).
 *
 * **WARNING**: Regardless of system locale, this will only treat ASCII values
 * for English 'a-z' and 'A-Z' as true.
 *
 * \param x character value to check.
 * \returns non-zero if x falls within the character class, zero otherwise.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *}
function SDL_isalpha(x: cint): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_isalpha' {$ENDIF} {$ENDIF};

{*
 * Query if a character is alphabetic (a letter) or a number.
 *
 * **WARNING**: Regardless of system locale, this will only treat ASCII values
 * for English 'a-z', 'A-Z', and '0-9' as true.
 *
 * \param x character value to check.
 * \returns non-zero if x falls within the character class, zero otherwise.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *}
function SDL_isalnum(x: cint): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_isalnum' {$ENDIF} {$ENDIF};

{*
 * Report if a character is blank (a space or tab).
 *
 * **WARNING**: Regardless of system locale, this will only treat ASCII values
 * 0x20 (space) or 0x9 (tab) as true.
 *
 * \param x character value to check.
 * \returns non-zero if x falls within the character class, zero otherwise.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *}
function SDL_isblank(x: cint): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_isblank' {$ENDIF} {$ENDIF};

{*
 * Report if a character is a control character.
 *
 * **WARNING**: Regardless of system locale, this will only treat ASCII values
 * 0 through 0x1F, and 0x7F, as true.
 *
 * \param x character value to check.
 * \returns non-zero if x falls within the character class, zero otherwise.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *}
function SDL_iscntrl(x: cint): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_iscntrl' {$ENDIF} {$ENDIF};

{*
 * Report if a character is a numeric digit.
 *
 * **WARNING**: Regardless of system locale, this will only treat ASCII values
 * '0' (0x30) through '9' (0x39), as true.
 *
 * \param x character value to check.
 * \returns non-zero if x falls within the character class, zero otherwise.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *}
function SDL_isdigit(x: cint): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_isdigit' {$ENDIF} {$ENDIF};

{*
 * Report if a character is a hexadecimal digit.
 *
 * **WARNING**: Regardless of system locale, this will only treat ASCII values
 * 'A' through 'F', 'a' through 'f', and '0' through '9', as true.
 *
 * \param x character value to check.
 * \returns non-zero if x falls within the character class, zero otherwise.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *}
function SDL_isxdigit(x: cint): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_isxdigit' {$ENDIF} {$ENDIF};

{*
 * Report if a character is a punctuation mark.
 *
 * **WARNING**: Regardless of system locale, this is equivalent to
 * `((SDL_isgraph(x)) && (!SDL_isalnum(x)))`.
 *
 * \param x character value to check.
 * \returns non-zero if x falls within the character class, zero otherwise.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_isgraph
 * \sa SDL_isalnum
 *}
function SDL_ispunct(x: cint): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ispunct' {$ENDIF} {$ENDIF};

{*
 * Report if a character is whitespace.
 *
 * **WARNING**: Regardless of system locale, this will only treat the
 * following ASCII values as true:
 *
 * - space (0x20)
 * - tab (0x09)
 * - newline (0x0A)
 * - vertical tab (0x0B)
 * - form feed (0x0C)
 * - return (0x0D)
 *
 * \param x character value to check.
 * \returns non-zero if x falls within the character class, zero otherwise.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *}
function SDL_isspace(x: cint): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_isspace' {$ENDIF} {$ENDIF};

{*
 * Report if a character is upper case.
 *
 * **WARNING**: Regardless of system locale, this will only treat ASCII values
 * 'A' through 'Z' as true.
 *
 * \param x character value to check.
 * \returns non-zero if x falls within the character class, zero otherwise.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *}
function SDL_isupper(x: cint): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_isupper' {$ENDIF} {$ENDIF};

{*
 * Report if a character is lower case.
 *
 * **WARNING**: Regardless of system locale, this will only treat ASCII values
 * 'a' through 'z' as true.
 *
 * \param x character value to check.
 * \returns non-zero if x falls within the character class, zero otherwise.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *}
function SDL_islower(x: cint): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_islower' {$ENDIF} {$ENDIF};

{*
 * Report if a character is "printable".
 *
 * Be advised that "printable" has a definition that goes back to text
 * terminals from the dawn of computing, making this a sort of special case
 * function that is not suitable for Unicode (or most any) text management.
 *
 * **WARNING**: Regardless of system locale, this will only treat ASCII values
 * ' ' (0x20) through '~' (0x7E) as true.
 *
 * \param x character value to check.
 * \returns non-zero if x falls within the character class, zero otherwise.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *}
function SDL_isprint(x: cint): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_isprint' {$ENDIF} {$ENDIF};

{*
 * Report if a character is any "printable" except space.
 *
 * Be advised that "printable" has a definition that goes back to text
 * terminals from the dawn of computing, making this a sort of special case
 * function that is not suitable for Unicode (or most any) text management.
 *
 * **WARNING**: Regardless of system locale, this is equivalent to
 * `(SDL_isprint(x)) && ((x) != ' ')`.
 *
 * \param x character value to check.
 * \returns non-zero if x falls within the character class, zero otherwise.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_isprint
 *}
function SDL_isgraph(x: cint): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_isgraph' {$ENDIF} {$ENDIF};

(* -- Character manipulation functions -- *)

{*
 * Convert low-ASCII English letters to uppercase.
 *
 * **WARNING**: Regardless of system locale, this will only convert ASCII
 * values 'a' through 'z' to uppercase.
 *
 * This function returns the uppercase equivalent of `x`. If a character
 * cannot be converted, or is already uppercase, this function returns `x`.
 *
 * \param x character value to check.
 * \returns capitalized version of x, or x if no conversion available.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *}
function SDL_toupper(x: cint): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_toupper' {$ENDIF} {$ENDIF};

{*
 * Convert low-ASCII English letters to lowercase.
 *
 * **WARNING**: Regardless of system locale, this will only convert ASCII
 * values 'A' through 'Z' to lowercase.
 *
 * This function returns the lowercase equivalent of `x`. If a character
 * cannot be converted, or is already lowercase, this function returns `x`.
 *
 * \param x character value to check.
 * \returns lowercase version of x, or x if no conversion available.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *}
function SDL_tolower(x: cint): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_tolower' {$ENDIF} {$ENDIF};

(* -- Hash functions -- *)

{*
 * Calculate a CRC-16 value.
 *
 * https://en.wikipedia.org/wiki/Cyclic_redundancy_check
 *
 * This function can be called multiple times, to stream data to be
 * checksummed in blocks. Each call must provide the previous CRC-16 return
 * value to be updated with the next block. The first call to this function
 * for a set of blocks should pass in a zero CRC value.
 *
 * \param crc the current checksum for this data set, or 0 for a new data set.
 * \param data a new block of data to add to the checksum.
 * \param len the size, in bytes, of the new block of data.
 * \returns a CRC-16 checksum value of all blocks in the data set.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *}
function SDL_crc16(crc: cuint16; const data: Pointer; len: csize_t): cuint16; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_crc16' {$ENDIF} {$ENDIF};

{*
 * Calculate a CRC-32 value.
 *
 * https://en.wikipedia.org/wiki/Cyclic_redundancy_check
 *
 * This function can be called multiple times, to stream data to be
 * checksummed in blocks. Each call must provide the previous CRC-32 return
 * value to be updated with the next block. The first call to this function
 * for a set of blocks should pass in a zero CRC value.
 *
 * \param crc the current checksum for this data set, or 0 for a new data set.
 * \param data a new block of data to add to the checksum.
 * \param len the size, in bytes, of the new block of data.
 * \returns a CRC-32 checksum value of all blocks in the data set.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *}
function SDL_crc32(crc: cuint32; const data: Pointer; len: csize_t): cuint32; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_crc32' {$ENDIF} {$ENDIF};

{*
 * Calculate a 32-bit MurmurHash3 value for a block of data.
 *
 * https://en.wikipedia.org/wiki/MurmurHash
 *
 * A seed may be specified, which changes the final results consistently, but
 * this does not work like SDL_crc16 and SDL_crc32: you can't feed a previous
 * result from this function back into itself as the next seed value to
 * calculate a hash in chunks; it won't produce the same hash as it would if
 * the same data was provided in a single call.
 *
 * If you aren't sure what to provide for a seed, zero is fine. Murmur3 is not
 * cryptographically secure, so it shouldn't be used for hashing top-secret
 * data.
 *
 * \param data the data to be hashed.
 * \param len the size of data, in bytes.
 * \param seed a value that alters the final hash value.
 * \returns a Murmur3 32-bit hash value.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *}
function SDL_murmur3_32(const data: Pointer; len: csize_t; seed: cuint32): cuint32;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_murmur3_32' {$ENDIF} {$ENDIF};

(* -- PRNG functions -- *)

{*
 * Seeds the pseudo-random number generator.
 *
 * Reusing the seed number will cause SDL_rand() to repeat the same stream of
 * 'random' numbers.
 *
 * \param seed the value to use as a random number seed, or 0 to use
 *             SDL_GetPerformanceCounter().
 *
 * \threadsafety This should be called on the same thread that calls
 *               SDL_rand()
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_rand
 * \sa SDL_rand_bits
 * \sa SDL_randf
 *}
procedure SDL_srand(seed: cuint64); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_srand' {$ENDIF} {$ENDIF};

{*
 * Generate a pseudo-random number less than n for positive n
 *
 * The method used is faster and of better quality than `rand() % n`. Odds are
 * roughly 99.9% even for n = 1 million. Evenness is better for smaller n, and
 * much worse as n gets bigger.
 *
 * Example: to simulate a d6 use `SDL_rand(6) + 1` The +1 converts 0..5 to
 * 1..6
 *
 * If you want to generate a pseudo-random number in the full range of Sint32,
 * you should use: (Sint32)SDL_rand_bits()
 *
 * If you want reproducible output, be sure to initialize with SDL_srand()
 * first.
 *
 * There are no guarantees as to the quality of the random sequence produced,
 * and this should not be used for security (cryptography, passwords) or where
 * money is on the line (loot-boxes, casinos). There are many random number
 * libraries available with different characteristics and you should pick one
 * of those to meet any serious needs.
 *
 * \param n the number of possible outcomes. n must be positive.
 * \returns a random value in the range of [0 .. n-1].
 *
 * \threadsafety All calls should be made from a single thread
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_srand
 * \sa SDL_randf
 *}
function SDL_rand(n: cint32): cint32; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_rand' {$ENDIF} {$ENDIF};

{*
 * Generate a uniform pseudo-random floating point number less than 1.0
 *
 * If you want reproducible output, be sure to initialize with SDL_srand()
 * first.
 *
 * There are no guarantees as to the quality of the random sequence produced,
 * and this should not be used for security (cryptography, passwords) or where
 * money is on the line (loot-boxes, casinos). There are many random number
 * libraries available with different characteristics and you should pick one
 * of those to meet any serious needs.
 *
 * \returns a random value in the range of [0.0, 1.0).
 *
 * \threadsafety All calls should be made from a single thread
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_srand
 * \sa SDL_rand
 *}
function SDL_randf(): cfloat; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_randf' {$ENDIF} {$ENDIF};

{*
 * Generate 32 pseudo-random bits.
 *
 * You likely want to use SDL_rand() to get a psuedo-random number instead.
 *
 * There are no guarantees as to the quality of the random sequence produced,
 * and this should not be used for security (cryptography, passwords) or where
 * money is on the line (loot-boxes, casinos). There are many random number
 * libraries available with different characteristics and you should pick one
 * of those to meet any serious needs.
 *
 * \returns a random value in the range of [0-SDL_MAX_UINT32].
 *
 * \threadsafety All calls should be made from a single thread
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_rand
 * \sa SDL_randf
 * \sa SDL_srand
 *}
function SDL_rand_bits(): cuint32; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_rand_bits' {$ENDIF} {$ENDIF};

{*
 * Generate a pseudo-random number less than n for positive n
 *
 * The method used is faster and of better quality than `rand() % n`. Odds are
 * roughly 99.9% even for n = 1 million. Evenness is better for smaller n, and
 * much worse as n gets bigger.
 *
 * Example: to simulate a d6 use `SDL_rand_r(state, 6) + 1` The +1 converts
 * 0..5 to 1..6
 *
 * If you want to generate a pseudo-random number in the full range of Sint32,
 * you should use: (Sint32)SDL_rand_bits_r(state)
 *
 * There are no guarantees as to the quality of the random sequence produced,
 * and this should not be used for security (cryptography, passwords) or where
 * money is on the line (loot-boxes, casinos). There are many random number
 * libraries available with different characteristics and you should pick one
 * of those to meet any serious needs.
 *
 * \param state a pointer to the current random number state.
 *              This may not be NIL.
 * \param n the number of possible outcomes. n must be positive.
 * \returns a random value in the range of [0 .. n-1].
 *
 * \threadsafety This function is thread-safe, as long as the state pointer
 *               isn't shared between threads.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_rand
 * \sa SDL_rand_bits_r
 * \sa SDL_randf_r
 *}
function SDL_rand_r(state: pcuint64; n: cint32): cint32; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_rand_r' {$ENDIF} {$ENDIF};

{*
 * Generate a uniform pseudo-random floating point number less than 1.0
 *
 * If you want reproducible output, be sure to initialize with SDL_srand()
 * first.
 *
 * There are no guarantees as to the quality of the random sequence produced,
 * and this should not be used for security (cryptography, passwords) or where
 * money is on the line (loot-boxes, casinos). There are many random number
 * libraries available with different characteristics and you should pick one
 * of those to meet any serious needs.
 *
 * \param state a pointer to the current random number state.
 *              This may not be NIL.
 * \returns a random value in the range of [0.0, 1.0).
 *
 * \threadsafety This function is thread-safe, as long as the state pointer
 *               isn't shared between threads.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_rand_bits_r
 * \sa SDL_rand_r
 * \sa SDL_randf
 *}
function SDL_randf_r(state: pcuint64): cfloat; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_randf_r' {$ENDIF} {$ENDIF};

{*
 * Generate 32 pseudo-random bits.
 *
 * You likely want to use SDL_rand_r() to get a psuedo-random number instead.
 *
 * There are no guarantees as to the quality of the random sequence produced,
 * and this should not be used for security (cryptography, passwords) or where
 * money is on the line (loot-boxes, casinos). There are many random number
 * libraries available with different characteristics and you should pick one
 * of those to meet any serious needs.
 *
 * \param state a pointer to the current random number state.
 *              This may not be NIL.
 * \returns a random value in the range of [0-SDL_MAX_UINT32].
 *
 * \threadsafety This function is thread-safe, as long as the state pointer
 *               isn't shared between threads.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_rand_r
 * \sa SDL_randf_r
 *}
function SDL_rand_bits_r(state: pcuint64): cuint32; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_rand_bits_r' {$ENDIF} {$ENDIF};

(* -- Floating-point arithmetic functions -- *)

const
  {*
   * The value of Pi, as a double-precision floating point literal.
   *
   * \since This const is available since SDL 3.2.0.
   *
   * \sa SDL_PI_F
   *}
  SDL_PI_D = cdouble(3.141592653589793238462643383279502884);

  {*
   * The value of Pi, as a single-precision floating point literal.
   *
   * \since This const is available since SDL 3.2.0.
   *
   * \sa SDL_PI_D
   *}
  SDL_PI_F = cfloat(3.141592653589793238462643383279502884);

{*
 * Compute the arc cosine of `x`.
 *
 * The definition of `y = acos(x)` is `x = cos(y)`.
 *
 * Domain: `-1 <= x <= 1`
 *
 * Range: `0 <= y <= Pi`
 *
 * This function operates on double-precision floating point values, use
 * SDL_acosf for single-precision floats.
 *
 * This function may use a different approximation across different versions,
 * platforms and configurations. i.e, it can return a different value given
 * the same input on different machines or operating systems, or if SDL is
 * updated.
 *
 * \param x floating point value.
 * \returns arc cosine of `x`, in radians.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_acosf
 * \sa SDL_asin
 * \sa SDL_cos
 *}
function SDL_acos(x: cdouble): cdouble; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_acos' {$ENDIF} {$ENDIF};

{*
 * Compute the arc cosine of `x`.
 *
 * The definition of `y = acos(x)` is `x = cos(y)`.
 *
 * Domain: `-1 <= x <= 1`
 *
 * Range: `0 <= y <= Pi`
 *
 * This function operates on single-precision floating point values, use
 * SDL_acos for double-precision floats.
 *
 * This function may use a different approximation across different versions,
 * platforms and configurations. i.e, it can return a different value given
 * the same input on different machines or operating systems, or if SDL is
 * updated.
 *
 * \param x floating point value.
 * \returns arc cosine of `x`, in radians.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_acos
 * \sa SDL_asinf
 * \sa SDL_cosf
 *}
function SDL_acosf(x: cfloat): cfloat; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_acosf' {$ENDIF} {$ENDIF};

{*
 * Compute the arc sine of `x`.
 *
 * The definition of `y = asin(x)` is `x = sin(y)`.
 *
 * Domain: `-1 <= x <= 1`
 *
 * Range: `-Pi/2 <= y <= Pi/2`
 *
 * This function operates on double-precision floating point values, use
 * SDL_asinf for single-precision floats.
 *
 * This function may use a different approximation across different versions,
 * platforms and configurations. i.e, it can return a different value given
 * the same input on different machines or operating systems, or if SDL is
 * updated.
 *
 * \param x floating point value.
 * \returns arc sine of `x`, in radians.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_asinf
 * \sa SDL_acos
 * \sa SDL_sin
 *}
function SDL_asin(x: cdouble): cdouble; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_asin' {$ENDIF} {$ENDIF};

{*
 * Compute the arc sine of `x`.
 *
 * The definition of `y = asin(x)` is `x = sin(y)`.
 *
 * Domain: `-1 <= x <= 1`
 *
 * Range: `-Pi/2 <= y <= Pi/2`
 *
 * This function operates on single-precision floating point values, use
 * SDL_asin for double-precision floats.
 *
 * This function may use a different approximation across different versions,
 * platforms and configurations. i.e, it can return a different value given
 * the same input on different machines or operating systems, or if SDL is
 * updated.
 *
 * \param x floating point value.
 * \returns arc sine of `x`, in radians.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_asin
 * \sa SDL_acosf
 * \sa SDL_sinf
 *}
function SDL_asinf(x: cfloat): cfloat; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_asinf' {$ENDIF} {$ENDIF};

{*
 * Compute the arc tangent of `x`.
 *
 * The definition of `y = atan(x)` is `x = tan(y)`.
 *
 * Domain: `-INF <= x <= INF`
 *
 * Range: `-Pi/2 <= y <= Pi/2`
 *
 * This function operates on double-precision floating point values, use
 * SDL_atanf for single-precision floats.
 *
 * To calculate the arc tangent of y / x, use SDL_atan2.
 *
 * This function may use a different approximation across different versions,
 * platforms and configurations. i.e, it can return a different value given
 * the same input on different machines or operating systems, or if SDL is
 * updated.
 *
 * \param x floating point value.
 * \returns arc tangent of of `x` in radians, or 0 if `x = 0`.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_atanf
 * \sa SDL_atan2
 * \sa SDL_tan
 *}
function SDL_atan(x: cdouble): cdouble; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_atan' {$ENDIF} {$ENDIF};

{*
 * Compute the arc tangent of `x`.
 *
 * The definition of `y = atan(x)` is `x = tan(y)`.
 *
 * Domain: `-INF <= x <= INF`
 *
 * Range: `-Pi/2 <= y <= Pi/2`
 *
 * This function operates on single-precision floating point values, use
 * SDL_atan for dboule-precision floats.
 *
 * To calculate the arc tangent of y / x, use SDL_atan2f.
 *
 * This function may use a different approximation across different versions,
 * platforms and configurations. i.e, it can return a different value given
 * the same input on different machines or operating systems, or if SDL is
 * updated.
 *
 * \param x floating point value.
 * \returns arc tangent of of `x` in radians, or 0 if `x = 0`.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_atan
 * \sa SDL_atan2f
 * \sa SDL_tanf
 *}
function SDL_atanf(x: cfloat): cfloat; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_atanf' {$ENDIF} {$ENDIF};

{*
 * Compute the arc tangent of `y / x`, using the signs of x and y to adjust
 * the result's quadrant.
 *
 * The definition of `z = atan2(x, y)` is `y = x tan(z)`, where the quadrant
 * of z is determined based on the signs of x and y.
 *
 * Domain: `-INF <= x <= INF`, `-INF <= y <= INF`
 *
 * Range: `-Pi <= y <= Pi`
 *
 * This function operates on double-precision floating point values, use
 * SDL_atan2f for single-precision floats.
 *
 * To calculate the arc tangent of a single value, use SDL_atan.
 *
 * This function may use a different approximation across different versions,
 * platforms and configurations. i.e, it can return a different value given
 * the same input on different machines or operating systems, or if SDL is
 * updated.
 *
 * \param y floating point value of the numerator (y coordinate).
 * \param x floating point value of the denominator (x coordinate).
 * \returns arc tangent of of `y / x` in radians, or, if `x = 0`, either
 *          `-Pi/2`, `0`, or `Pi/2`, depending on the value of `y`.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_atan2f
 * \sa SDL_atan
 * \sa SDL_tan
 *}
function SDL_atan2(y, x: cdouble): cdouble; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_atan2' {$ENDIF} {$ENDIF};

{*
 * Compute the arc tangent of `y / x`, using the signs of x and y to adjust
 * the result's quadrant.
 *
 * The definition of `z = atan2(x, y)` is `y = x tan(z)`, where the quadrant
 * of z is determined based on the signs of x and y.
 *
 * Domain: `-INF <= x <= INF`, `-INF <= y <= INF`
 *
 * Range: `-Pi <= y <= Pi`
 *
 * This function operates on single-precision floating point values, use
 * SDL_atan2 for double-precision floats.
 *
 * To calculate the arc tangent of a single value, use SDL_atanf.
 *
 * This function may use a different approximation across different versions,
 * platforms and configurations. i.e, it can return a different value given
 * the same input on different machines or operating systems, or if SDL is
 * updated.
 *
 * \param y floating point value of the numerator (y coordinate).
 * \param x floating point value of the denominator (x coordinate).
 * \returns arc tangent of of `y / x` in radians, or, if `x = 0`, either
 *          `-Pi/2`, `0`, or `Pi/2`, depending on the value of `y`.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_atan2
 * \sa SDL_atan
 * \sa SDL_tan
 *}
function SDL_atan2f(y, x: cfloat): cfloat; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_atan2f' {$ENDIF} {$ENDIF};

{*
 * Compute the ceiling of `x`.
 *
 * The ceiling of `x` is the smallest integer `y` such that `y > x`, i.e `x`
 * rounded up to the nearest integer.
 *
 * Domain: `-INF <= x <= INF`
 *
 * Range: `-INF <= y <= INF`, y integer
 *
 * This function operates on double-precision floating point values, use
 * SDL_ceilf for single-precision floats.
 *
 * \param x floating point value.
 * \returns the ceiling of `x`.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_ceilf
 * \sa SDL_floor
 * \sa SDL_trunc
 * \sa SDL_round
 * \sa SDL_lround
 *}
function SDL_ceil(x: cdouble): cdouble; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ceil' {$ENDIF} {$ENDIF};

{*
 * Compute the ceiling of `x`.
 *
 * The ceiling of `x` is the smallest integer `y` such that `y > x`, i.e `x`
 * rounded up to the nearest integer.
 *
 * Domain: `-INF <= x <= INF`
 *
 * Range: `-INF <= y <= INF`, y integer
 *
 * This function operates on single-precision floating point values, use
 * SDL_ceil for double-precision floats.
 *
 * \param x floating point value.
 * \returns the ceiling of `x`.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_ceil
 * \sa SDL_floorf
 * \sa SDL_truncf
 * \sa SDL_roundf
 * \sa SDL_lroundf
 *}
function SDL_ceilf(x: cfloat): cfloat; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ceilf' {$ENDIF} {$ENDIF};

{*
 * Copy the sign of one floating-point value to another.
 *
 * The definition of copysign is that ``copysign(x, y) = abs(x) * sign(y)``.
 *
 * Domain: `-INF <= x <= INF`, ``-INF <= y <= f``
 *
 * Range: `-INF <= z <= INF`
 *
 * This function operates on double-precision floating point values, use
 * SDL_copysignf for single-precision floats.
 *
 * \param x floating point value to use as the magnitude.
 * \param y floating point value to use as the sign.
 * \returns the floating point value with the sign of y and the magnitude of
 *          x.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_copysignf
 * \sa SDL_fabs
 *}
function SDL_copysign(x, y: cdouble): cdouble; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_copysign' {$ENDIF} {$ENDIF};

{*
 * Copy the sign of one floating-point value to another.
 *
 * The definition of copysign is that ``copysign(x, y) = abs(x) * sign(y)``.
 *
 * Domain: `-INF <= x <= INF`, ``-INF <= y <= f``
 *
 * Range: `-INF <= z <= INF`
 *
 * This function operates on single-precision floating point values, use
 * SDL_copysign for double-precision floats.
 *
 * \param x floating point value to use as the magnitude.
 * \param y floating point value to use as the sign.
 * \returns the floating point value with the sign of y and the magnitude of
 *          x.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_copysign
 * \sa SDL_fabsf
 *}
function SDL_copysignf(x, y: cfloat): cfloat; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_copysignf' {$ENDIF} {$ENDIF};

{*
 * Compute the cosine of `x`.
 *
 * Domain: `-INF <= x <= INF`
 *
 * Range: `-1 <= y <= 1`
 *
 * This function operates on double-precision floating point values, use
 * SDL_cosf for single-precision floats.
 *
 * This function may use a different approximation across different versions,
 * platforms and configurations. i.e, it can return a different value given
 * the same input on different machines or operating systems, or if SDL is
 * updated.
 *
 * \param x floating point value, in radians.
 * \returns cosine of `x`.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_cosf
 * \sa SDL_acos
 * \sa SDL_sin
 *}
function SDL_cos(x: cdouble): cdouble; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_cos' {$ENDIF} {$ENDIF};

{*
 * Compute the cosine of `x`.
 *
 * Domain: `-INF <= x <= INF`
 *
 * Range: `-1 <= y <= 1`
 *
 * This function operates on single-precision floating point values, use
 * SDL_cos for double-precision floats.
 *
 * This function may use a different approximation across different versions,
 * platforms and configurations. i.e, it can return a different value given
 * the same input on different machines or operating systems, or if SDL is
 * updated.
 *
 * \param x floating point value, in radians.
 * \returns cosine of `x`.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_cos
 * \sa SDL_acosf
 * \sa SDL_sinf
 *}
function SDL_cosf(x: cfloat): cfloat; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_cosf' {$ENDIF} {$ENDIF};

{*
 * Compute the exponential of `x`.
 *
 * The definition of `y = exp(x)` is `y = e^x`, where `e` is the base of the
 * natural logarithm. The inverse is the natural logarithm, SDL_logn.
 *
 * Domain: `-INF <= x <= INF`
 *
 * Range: `0 <= y <= INF`
 *
 * The output will overflow if `exp(x)` is too large to be represented.
 *
 * This function operates on double-precision floating point values, use
 * SDL_expf for single-precision floats.
 *
 * This function may use a different approximation across different versions,
 * platforms and configurations. i.e, it can return a different value given
 * the same input on different machines or operating systems, or if SDL is
 * updated.
 *
 * \param x floating point value.
 * \returns value of `e^x`.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_expf
 * \sa SDL_logn
 *}
function SDL_exp(x: cdouble): cdouble; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_exp' {$ENDIF} {$ENDIF};

{*
 * Compute the exponential of `x`.
 *
 * The definition of `y = exp(x)` is `y = e^x`, where `e` is the base of the
 * natural logarithm. The inverse is the natural logarithm, SDL_lognf.
 *
 * Domain: `-INF <= x <= INF`
 *
 * Range: `0 <= y <= INF`
 *
 * The output will overflow if `exp(x)` is too large to be represented.
 *
 * This function operates on single-precision floating point values, use
 * SDL_exp for double-precision floats.
 *
 * This function may use a different approximation across different versions,
 * platforms and configurations. i.e, it can return a different value given
 * the same input on different machines or operating systems, or if SDL is
 * updated.
 *
 * \param x floating point value.
 * \returns value of `e^x`.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_exp
 * \sa SDL_lognf
 *}
function SDL_expf(x: cfloat): cfloat; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_expf' {$ENDIF} {$ENDIF};

{*
 * Compute the absolute value of `x`
 *
 * Domain: `-INF <= x <= INF`
 *
 * Range: `0 <= y <= INF`
 *
 * This function operates on double-precision floating point values, use
 * SDL_fabsf for single-precision floats.
 *
 * \param x floating point value to use as the magnitude.
 * \returns the absolute value of `x`.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_fabsf
  }
function SDL_fabs(x: cdouble): cdouble; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_fabs' {$ENDIF} {$ENDIF};

{*
 * Compute the absolute value of `x`
 *
 * Domain: `-INF <= x <= INF`
 *
 * Range: `0 <= y <= INF`
 *
 * This function operates on single-precision floating point values, use
 * SDL_fabs for double-precision floats.
 *
 * \param x floating point value to use as the magnitude.
 * \returns the absolute value of `x`.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_fabs
  }
function SDL_fabsf(x: cfloat): cfloat; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_fabsf' {$ENDIF} {$ENDIF};

{*
 * Compute the floor of `x`.
 *
 * The floor of `x` is the largest integer `y` such that `y > x`, i.e `x`
 * rounded down to the nearest integer.
 *
 * Domain: `-INF <= x <= INF`
 *
 * Range: `-INF <= y <= INF`, y integer
 *
 * This function operates on double-precision floating point values, use
 * SDL_floorf for single-precision floats.
 *
 * \param x floating point value.
 * \returns the floor of `x`.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_floorf
 * \sa SDL_ceil
 * \sa SDL_trunc
 * \sa SDL_round
 * \sa SDL_lround
 *}
function SDL_floor(x: cdouble): cdouble; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_floor' {$ENDIF} {$ENDIF};

{*
 * Compute the floor of `x`.
 *
 * The floor of `x` is the largest integer `y` such that `y > x`, i.e `x`
 * rounded down to the nearest integer.
 *
 * Domain: `-INF <= x <= INF`
 *
 * Range: `-INF <= y <= INF`, y integer
 *
 * This function operates on single-precision floating point values, use
 * SDL_floor for double-precision floats.
 *
 * \param x floating point value.
 * \returns the floor of `x`.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_floor
 * \sa SDL_ceilf
 * \sa SDL_truncf
 * \sa SDL_roundf
 * \sa SDL_lroundf
 *}
function SDL_floorf(x: cfloat): cfloat; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_floorf' {$ENDIF} {$ENDIF};

{*
 * Truncate `x` to an integer.
 *
 * Rounds `x` to the next closest integer to 0. This is equivalent to removing
 * the fractional part of `x`, leaving only the integer part.
 *
 * Domain: `-INF <= x <= INF`
 *
 * Range: `-INF <= y <= INF`, y integer
 *
 * This function operates on double-precision floating point values, use
 * SDL_truncf for single-precision floats.
 *
 * \param x floating point value.
 * \returns `x` truncated to an integer.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_truncf
 * \sa SDL_fmod
 * \sa SDL_ceil
 * \sa SDL_floor
 * \sa SDL_round
 * \sa SDL_lround
 *}
function SDL_trunc(x: cdouble): cdouble; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_trunc' {$ENDIF} {$ENDIF};

{*
 * Truncate `x` to an integer.
 *
 * Rounds `x` to the next closest integer to 0. This is equivalent to removing
 * the fractional part of `x`, leaving only the integer part.
 *
 * Domain: `-INF <= x <= INF`
 *
 * Range: `-INF <= y <= INF`, y integer
 *
 * This function operates on single-precision floating point values, use
 * SDL_trunc for double-precision floats.
 *
 * \param x floating point value.
 * \returns `x` truncated to an integer.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_trunc
 * \sa SDL_fmodf
 * \sa SDL_ceilf
 * \sa SDL_floorf
 * \sa SDL_roundf
 * \sa SDL_lroundf
 *}
function SDL_truncf(x: cfloat): cfloat; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_truncf' {$ENDIF} {$ENDIF};

{*
 * Return the floating-point remainder of `x / y`
 *
 * Divides `x` by `y`, and returns the remainder.
 *
 * Domain: `-INF <= x <= INF`, `-INF <= y <= INF`, `y != 0`
 *
 * Range: `-y <= z <= y`
 *
 * This function operates on double-precision floating point values, use
 * SDL_fmodf for single-precision floats.
 *
 * \param x the numerator.
 * \param y the denominator. Must not be 0.
 * \returns the remainder of `x / y`.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_fmodf
 * \sa SDL_modf
 * \sa SDL_trunc
 * \sa SDL_ceil
 * \sa SDL_floor
 * \sa SDL_round
 * \sa SDL_lround
 *}
function SDL_fmod(x, y: cdouble): cdouble; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_fmod' {$ENDIF} {$ENDIF};

{*
 * Return the floating-point remainder of `x / y`
 *
 * Divides `x` by `y`, and returns the remainder.
 *
 * Domain: `-INF <= x <= INF`, `-INF <= y <= INF`, `y != 0`
 *
 * Range: `-y <= z <= y`
 *
 * This function operates on single-precision floating point values, use
 * SDL_fmod for double-precision floats.
 *
 * \param x the numerator.
 * \param y the denominator. Must not be 0.
 * \returns the remainder of `x / y`.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_fmod
 * \sa SDL_truncf
 * \sa SDL_modff
 * \sa SDL_ceilf
 * \sa SDL_floorf
 * \sa SDL_roundf
 * \sa SDL_lroundf
 *}
function SDL_fmodf(x, y: cfloat): cfloat; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_fmodf' {$ENDIF} {$ENDIF};

{*
 * Return whether the value is infinity.
 *
 * \param x double-precision floating point value.
 * \returns non-zero if the value is infinity, 0 otherwise.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_isinff
 *}
function SDL_isinf(x: cdouble): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_isinf' {$ENDIF} {$ENDIF};

{*
 * Return whether the value is infinity.
 *
 * \param x floating point value.
 * \returns non-zero if the value is infinity, 0 otherwise.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_isinf
 *}
function SDL_isinff(x: cfloat): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_isinff' {$ENDIF} {$ENDIF};

{*
 * Return whether the value is NaN.
 *
 * \param x double-precision floating point value.
 * \returns non-zero if the value is NaN, 0 otherwise.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_isnanf
 *}
function SDL_isnan(x: cdouble): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_isnan' {$ENDIF} {$ENDIF};

{*
 * Return whether the value is NaN.
 *
 * \param x floating point value.
 * \returns non-zero if the value is NaN, 0 otherwise.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_isnan
 *}
function SDL_isnanf(x: cfloat): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_isnanf' {$ENDIF} {$ENDIF};

{*
 * Compute the natural logarithm of `x`.
 *
 * Domain: `0 < x <= INF`
 *
 * Range: `-INF <= y <= INF`
 *
 * It is an error for `x` to be less than or equal to 0.
 *
 * This function operates on double-precision floating point values, use
 * SDL_lognf for single-precision floats.
 *
 * This function may use a different approximation across different versions,
 * platforms and configurations. i.e, it can return a different value given
 * the same input on different machines or operating systems, or if SDL is
 * updated.
 *
 * (SDL3-for-Pascal) NOTE: In the original SDL3 API, this function is called
 * `SDL_log`. Because function names are case-insensitive in Pascal, this
 * causes a duplicate identifier conflict with `SDL_Log`, the logging function.
 * Hence, this function has been renamed in the Pascal units.
 *
 * \param x floating point value. Must be greater than 0.
 * \returns the natural logarithm of `x`.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_lognf
 * \sa SDL_log10
 * \sa SDL_exp
 *}
function SDL_logn(x: cdouble): cdouble; cdecl;
  external SDL_LibName
  name {$IF DEFINED(DELPHI) AND DEFINED(MACOS)} '_SDL_log' {$ELSE} 'SDL_log' {$ENDIF};

{*
 * Compute the natural logarithm of `x`.
 *
 * Domain: `0 < x <= INF`
 *
 * Range: `-INF <= y <= INF`
 *
 * It is an error for `x` to be less than or equal to 0.
 *
 * This function operates on single-precision floating point values, use
 * SDL_logn for double-precision floats.
 *
 * This function may use a different approximation across different versions,
 * platforms and configurations. i.e, it can return a different value given
 * the same input on different machines or operating systems, or if SDL is
 * updated.
 *
 * (SDL3-for-Pascal) NOTE: In the original SDL3 API, this function is called
 * `SDL_logf`. In the Pascal units, it has been renamed to match `SDL_logn`.
 *
 * \param x floating point value. Must be greater than 0.
 * \returns the natural logarithm of `x`.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_logn
 * \sa SDL_expf
 *}
function SDL_lognf(x: cfloat): cfloat; cdecl;
  external SDL_LibName
  name {$IF DEFINED(DELPHI) AND DEFINED(MACOS)} '_SDL_logf' {$ELSE} 'SDL_logf' {$ENDIF};

{*
 * Compute the base-10 logarithm of `x`.
 *
 * Domain: `0 < x <= INF`
 *
 * Range: `-INF <= y <= INF`
 *
 * It is an error for `x` to be less than or equal to 0.
 *
 * This function operates on double-precision floating point values, use
 * SDL_log10f for single-precision floats.
 *
 * This function may use a different approximation across different versions,
 * platforms and configurations. i.e, it can return a different value given
 * the same input on different machines or operating systems, or if SDL is
 * updated.
 *
 * \param x floating point value. Must be greater than 0.
 * \returns the logarithm of `x`.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_log10f
 * \sa SDL_logn
 * \sa SDL_pow
 *}
function SDL_log10(x: cdouble): cdouble;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_log10' {$ENDIF} {$ENDIF};

{*
 * Compute the base-10 logarithm of `x`.
 *
 * Domain: `0 < x <= INF`
 *
 * Range: `-INF <= y <= INF`
 *
 * It is an error for `x` to be less than or equal to 0.
 *
 * This function operates on single-precision floating point values, use
 * SDL_log10 for double-precision floats.
 *
 * This function may use a different approximation across different versions,
 * platforms and configurations. i.e, it can return a different value given
 * the same input on different machines or operating systems, or if SDL is
 * updated.
 *
 * \param x floating point value. Must be greater than 0.
 * \returns the logarithm of `x`.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_log10
 * \sa SDL_lognf
 * \sa SDL_powf
 *}
function SDL_log10f(x: cfloat): cfloat; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_log10f' {$ENDIF} {$ENDIF};

{*
 * Split `x` into integer and fractional parts
 *
 * This function operates on double-precision floating point values, use
 * SDL_modff for single-precision floats.
 *
 * \param x floating point value.
 * \param y output pointer to store the integer part of `x`.
 * \returns the fractional part of `x`.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_modff
 * \sa SDL_trunc
 * \sa SDL_fmod
 *}
function SDL_modf(x: cdouble; y: pcdouble): cdouble; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_modf' {$ENDIF} {$ENDIF};

{*
 * Split `x` into integer and fractional parts
 *
 * This function operates on single-precision floating point values, use
 * SDL_modf for double-precision floats.
 *
 * \param x floating point value.
 * \param y output pointer to store the integer part of `x`.
 * \returns the fractional part of `x`.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_modf
 * \sa SDL_truncf
 * \sa SDL_fmodf
 *}
function SDL_modff(x: cfloat; y: pcfloat): cfloat; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_modff' {$ENDIF} {$ENDIF};

{*
 * Raise `x` to the power `y`
 *
 * Domain: `-INF <= x <= INF`, `-INF <= y <= INF`
 *
 * Range: `-INF <= z <= INF`
 *
 * If `y` is the base of the natural logarithm (e), consider using SDL_exp
 * instead.
 *
 * This function operates on double-precision floating point values, use
 * SDL_powf for single-precision floats.
 *
 * This function may use a different approximation across different versions,
 * platforms and configurations. i.e, it can return a different value given
 * the same input on different machines or operating systems, or if SDL is
 * updated.
 *
 * \param x the base.
 * \param y the exponent.
 * \returns `x` raised to the power `y`.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_powf
 * \sa SDL_exp
 * \sa SDL_logn
 *}
function SDL_pow(x, y: cdouble): cdouble; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_pow' {$ENDIF} {$ENDIF};

{*
 * Raise `x` to the power `y`
 *
 * Domain: `-INF <= x <= INF`, `-INF <= y <= INF`
 *
 * Range: `-INF <= z <= INF`
 *
 * If `y` is the base of the natural logarithm (e), consider using SDL_exp
 * instead.
 *
 * This function operates on single-precision floating point values, use
 * SDL_pow for double-precision floats.
 *
 * This function may use a different approximation across different versions,
 * platforms and configurations. i.e, it can return a different value given
 * the same input on different machines or operating systems, or if SDL is
 * updated.
 *
 * \param x the base.
 * \param y the exponent.
 * \returns `x` raised to the power `y`.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_pow
 * \sa SDL_expf
 * \sa SDL_lognf
 *}
function SDL_powf(x, y: cfloat): cfloat; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_powf' {$ENDIF} {$ENDIF};

{*
 * Round `x` to the nearest integer.
 *
 * Rounds `x` to the nearest integer. Values halfway between integers will be
 * rounded away from zero.
 *
 * Domain: `-INF <= x <= INF`
 *
 * Range: `-INF <= y <= INF`, y integer
 *
 * This function operates on double-precision floating point values, use
 * SDL_roundf for single-precision floats. To get the result as an integer
 * type, use SDL_lround.
 *
 * \param x floating point value.
 * \returns the nearest integer to `x`.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_roundf
 * \sa SDL_lround
 * \sa SDL_floor
 * \sa SDL_ceil
 * \sa SDL_trunc
 *}
function SDL_round(x: cdouble): cdouble; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_round' {$ENDIF} {$ENDIF};

{*
 * Round `x` to the nearest integer.
 *
 * Rounds `x` to the nearest integer. Values halfway between integers will be
 * rounded away from zero.
 *
 * Domain: `-INF <= x <= INF`
 *
 * Range: `-INF <= y <= INF`, y integer
 *
 * This function operates on single-precision floating point values, use
 * SDL_round for double-precision floats. To get the result as an integer
 * type, use SDL_lroundf.
 *
 * \param x floating point value.
 * \returns the nearest integer to `x`.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_round
 * \sa SDL_lroundf
 * \sa SDL_floorf
 * \sa SDL_ceilf
 * \sa SDL_truncf
 *}
function SDL_roundf(x: cfloat): cfloat; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_roundf' {$ENDIF} {$ENDIF};

{*
 * Round `x` to the nearest integer representable as a long
 *
 * Rounds `x` to the nearest integer. Values halfway between integers will be
 * rounded away from zero.
 *
 * Domain: `-INF <= x <= INF`
 *
 * Range: `MIN_LONG <= y <= MAX_LONG`
 *
 * This function operates on double-precision floating point values, use
 * SDL_lroundf for single-precision floats. To get the result as a
 * floating-point type, use SDL_round.
 *
 * \param x floating point value.
 * \returns the nearest integer to `x`.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_lroundf
 * \sa SDL_round
 * \sa SDL_floor
 * \sa SDL_ceil
 * \sa SDL_trunc
 *}
function SDL_lround(x: cdouble): clong; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_lround' {$ENDIF} {$ENDIF};

{*
 * Round `x` to the nearest integer representable as a long
 *
 * Rounds `x` to the nearest integer. Values halfway between integers will be
 * rounded away from zero.
 *
 * Domain: `-INF <= x <= INF`
 *
 * Range: `MIN_LONG <= y <= MAX_LONG`
 *
 * This function operates on single-precision floating point values, use
 * SDL_lround for double-precision floats. To get the result as a
 * floating-point type, use SDL_roundf.
 *
 * \param x floating point value.
 * \returns the nearest integer to `x`.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_lround
 * \sa SDL_roundf
 * \sa SDL_floorf
 * \sa SDL_ceilf
 * \sa SDL_truncf
 *}
function SDL_lroundf(x: cfloat): clong; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_lroundf' {$ENDIF} {$ENDIF};

{*
 * Scale `x` by an integer power of two.
 *
 * Multiplies `x` by the `n`th power of the floating point radix (always 2).
 *
 * Domain: `-INF <= x <= INF`, `n` integer
 *
 * Range: `-INF <= y <= INF`
 *
 * This function operates on double-precision floating point values, use
 * SDL_scalbnf for single-precision floats.
 *
 * \param x floating point value to be scaled.
 * \param n integer exponent.
 * \returns `x * 2^n`.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_scalbnf
 * \sa SDL_pow
 *}
function SDL_scalbn(x: cdouble; n: cint): cdouble; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_scalbn' {$ENDIF} {$ENDIF};

{*
 * Scale `x` by an integer power of two.
 *
 * Multiplies `x` by the `n`th power of the floating point radix (always 2).
 *
 * Domain: `-INF <= x <= INF`, `n` integer
 *
 * Range: `-INF <= y <= INF`
 *
 * This function operates on single-precision floating point values, use
 * SDL_scalbn for double-precision floats.
 *
 * \param x floating point value to be scaled.
 * \param n integer exponent.
 * \returns `x * 2^n`.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_scalbn
 * \sa SDL_powf
 *}
function SDL_scalbnf(x: cfloat; n: cint): cfloat; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_scalbnf' {$ENDIF} {$ENDIF};

{*
 * Compute the sine of `x`.
 *
 * Domain: `-INF <= x <= INF`
 *
 * Range: `-1 <= y <= 1`
 *
 * This function operates on double-precision floating point values, use
 * SDL_sinf for single-precision floats.
 *
 * This function may use a different approximation across different versions,
 * platforms and configurations. i.e, it can return a different value given
 * the same input on different machines or operating systems, or if SDL is
 * updated.
 *
 * \param x floating point value, in radians.
 * \returns sine of `x`.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_sinf
 * \sa SDL_asin
 * \sa SDL_cos
 *}
function SDL_sin(x: cdouble): cdouble; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_sin' {$ENDIF} {$ENDIF};

{*
 * Compute the sine of `x`.
 *
 * Domain: `-INF <= x <= INF`
 *
 * Range: `-1 <= y <= 1`
 *
 * This function operates on single-precision floating point values, use
 * SDL_sin for double-precision floats.
 *
 * This function may use a different approximation across different versions,
 * platforms and configurations. i.e, it can return a different value given
 * the same input on different machines or operating systems, or if SDL is
 * updated.
 *
 * \param x floating point value, in radians.
 * \returns sine of `x`.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_sin
 * \sa SDL_asinf
 * \sa SDL_cosf
 *}
function SDL_sinf(x: cfloat): cfloat; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_sinf' {$ENDIF} {$ENDIF};

{*
 * Compute the square root of `x`.
 *
 * Domain: `0 <= x <= INF`
 *
 * Range: `0 <= y <= INF`
 *
 * This function operates on double-precision floating point values, use
 * SDL_sqrtf for single-precision floats.
 *
 * This function may use a different approximation across different versions,
 * platforms and configurations. i.e, it can return a different value given
 * the same input on different machines or operating systems, or if SDL is
 * updated.
 *
 * \param x floating point value. Must be greater than or equal to 0.
 * \returns square root of `x`.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_sqrtf
 *}
function SDL_sqrt(x: cdouble): cdouble; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_sqrt' {$ENDIF} {$ENDIF};

{*
 * Compute the square root of `x`.
 *
 * Domain: `0 <= x <= INF`
 *
 * Range: `0 <= y <= INF`
 *
 * This function operates on single-precision floating point values, use
 * SDL_sqrt for double-precision floats.
 *
 * This function may use a different approximation across different versions,
 * platforms and configurations. i.e, it can return a different value given
 * the same input on different machines or operating systems, or if SDL is
 * updated.
 *
 * \param x floating point value. Must be greater than or equal to 0.
 * \returns square root of `x`.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_sqrt
 *}
function SDL_sqrtf(x: cfloat): cfloat; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_sqrtf' {$ENDIF} {$ENDIF};

{*
 * Compute the tangent of `x`.
 *
 * Domain: `-INF <= x <= INF`
 *
 * Range: `-INF <= y <= INF`
 *
 * This function operates on double-precision floating point values, use
 * SDL_tanf for single-precision floats.
 *
 * This function may use a different approximation across different versions,
 * platforms and configurations. i.e, it can return a different value given
 * the same input on different machines or operating systems, or if SDL is
 * updated.
 *
 * \param x floating point value, in radians.
 * \returns tangent of `x`.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_tanf
 * \sa SDL_sin
 * \sa SDL_cos
 * \sa SDL_atan
 * \sa SDL_atan2
 *}
function SDL_tan(x: cdouble): cdouble; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_tan' {$ENDIF} {$ENDIF};

{*
 * Compute the tangent of `x`.
 *
 * Domain: `-INF <= x <= INF`
 *
 * Range: `-INF <= y <= INF`
 *
 * This function operates on single-precision floating point values, use
 * SDL_tan for double-precision floats.
 *
 * This function may use a different approximation across different versions,
 * platforms and configurations. i.e, it can return a different value given
 * the same input on different machines or operating systems, or if SDL is
 * updated.
 *
 * \param x floating point value, in radians.
 * \returns tangent of `x`.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_tan
 * \sa SDL_sinf
 * \sa SDL_cosf
 * \sa SDL_atanf
 * \sa SDL_atan2f
 *}
function SDL_tanf(x: cfloat): cfloat; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_tanf' {$ENDIF} {$ENDIF};

{*
 * A generic function pointer.
 *
 * In theory, generic function pointers should use this, instead of `void *`,
 * since some platforms could treat code addresses differently than data
 * addresses. Although in current times no popular platforms make this
 * distinction, it is more correct and portable to use the correct type for a
 * generic pointer.
 *
 * If for some reason you need to force this typedef to be an actual `void *`,
 * perhaps to work around a compiler or existing code, you can define
 * `SDL_FUNCTION_POINTER_IS_VOID_POINTER` before including any SDL headers.
 *
 * \since This datatype is available since SDL 3.1.3.
  }
type
  TSDL_FunctionPointer = procedure(parameter:Pointer); cdecl;

