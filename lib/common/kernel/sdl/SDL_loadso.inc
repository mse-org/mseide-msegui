{
  This file is part of:

    SDL3 for Pascal
    (https://github.com/PascalGameDevelopment/SDL3-for-Pascal)
    SPDX-License-Identifier: Zlib
}

{*
 * # CategorySharedObject
 *
 * System-dependent library loading routines.
 *
 * Shared objects are code that is programmatically loadable at runtime.
 * Windows calls these "DLLs", Linux calls them "shared libraries", etc.
 *
 * To use them, build such a library, then call SDL_LoadObject() on it. Once
 * loaded, you can use SDL_LoadFunction() on that object to find the address
 * of its exported symbols. When done with the object, call SDL_UnloadObject()
 * to dispose of it.
 *
 * Some things to keep in mind:
 *
 * - These functions only work on C function names. Other languages may have
 *   name mangling and intrinsic language support that varies from compiler to
 *   compiler.
 * - Make sure you declare your function pointers with the same calling
 *   convention as the actual library function. Your code will crash
 *   mysteriously if you do not do this.
 * - Avoid namespace collisions. If you load a symbol from the library, it is
 *   not defined whether or not it goes into the global symbol namespace for
 *   the application. If it does and it conflicts with symbols in your code or
 *   other shared libraries, you will not get the results you expect.:)
 * - Once a library is unloaded, all pointers into it obtained through
 *   SDL_LoadFunction() become invalid, even if the library is later reloaded.
 *   Don't unload a library if you plan to use these pointers in the future.
 *   Notably: beware of giving one of these pointers to atexit(), since it may
 *   call that Pointer after the library unloads.
  }

{*
 * An opaque datatype that represents a loaded shared object.
 *
 * \since This datatype is available since SDL 3.2.0.
 *
 * \sa SDL_LoadObject
 * \sa SDL_LoadFunction
 * \sa SDL_UnloadObject
  }
type
  PPSDL_SharedObject = ^PSDL_SharedObject;
  PSDL_SharedObject = type Pointer;

{*
 * Dynamically load a shared object.
 *
 * \param sofile a system-dependent name of the object file.
 * \returns an opaque Pointer to the object handle or nil on failure; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_LoadFunction
 * \sa SDL_UnloadObject
  }
function SDL_LoadObject(sofile: PAnsiChar): PSDL_SharedObject; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_LoadObject' {$ENDIF} {$ENDIF};

{*
 * Look up the address of the named function in a shared object.
 *
 * This function Pointer is no longer valid after calling SDL_UnloadObject().
 *
 * This function can only look up C function names. Other languages may have
 * name mangling and intrinsic language support that varies from compiler to
 * compiler.
 *
 * Make sure you declare your function pointers with the same calling
 * convention as the actual library function. Your code will crash
 * mysteriously if you do not do this.
 *
 * If the requested function doesn't exist, nil is returned.
 *
 * \param handle a valid shared object handle returned by SDL_LoadObject().
 * \param name the name of the function to look up.
 * \returns a Pointer to the function or nil on failure; call SDL_GetError()
 *          for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_LoadObject
  }
function SDL_LoadFunction(handle: PSDL_SharedObject; name: PAnsiChar): TSDL_FunctionPointer; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_LoadFunction' {$ENDIF} {$ENDIF};

{*
 * Unload a shared object from memory.
 *
 * Note that any pointers from this object looked up through
 * SDL_LoadFunction() will no longer be valid.
 *
 * \param handle a valid shared object handle returned by SDL_LoadObject().
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_LoadObject
  }
procedure SDL_UnloadObject(handle: PSDL_SharedObject); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_UnloadObject' {$ENDIF} {$ENDIF};

