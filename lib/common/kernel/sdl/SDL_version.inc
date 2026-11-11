{
  This file is part of:

    SDL3 for Pascal
    (https://github.com/PascalGameDevelopment/SDL3-for-Pascal)
    SPDX-License-Identifier: Zlib
}

{*
 * # CategoryVersion
 *
 * Functionality to query the current SDL version, both as headers the app was
 * compiled against, and a library the app is linked to.
  }

{*
 * The current major version of SDL headers.
 *
 * If this were SDL version 3.2.1, this value would be 3.
 *
 * \since This macro is available since SDL 3.2.0.
  }
const
  SDL_MAJOR_VERSION = 3;

{*
 * The current minor version of the SDL headers.
 *
 * If this were SDL version 3.2.1, this value would be 2.
 *
 * \since This macro is available since SDL 3.2.0.
  }
  SDL_MINOR_VERSION = 4;

{*
 * The current micro (or patchlevel) version of the SDL headers.
 *
 * If this were SDL version 3.2.1, this value would be 1.
 *
 * \since This macro is available since SDL 3.2.0.
  }
  SDL_MICRO_VERSION = 4;

{*
 * This macro turns the version numbers into a numeric value.
 *
 * (1,2,3) becomes 1002003.
 *
 * \param major the major version number.
 * \param minor the minorversion number.
 * \param patch the patch version number.
 *
 * \since This macro is available since SDL 3.2.0.
  }
function SDL_VERSIONNUM(major,minor,patch: Integer): Integer;

{*
 * This macro extracts the major version from a version number
 *
 * 1002003 becomes 1.
 *
 * \param version the version number.
 *
 * \threadsafety It is safe to call this macro from any thread.
 *
 * \since This macro is available since SDL 3.2.0.
  }
function SDL_VERSIONNUM_MAJOR(version: Integer): Integer;

{*
 * This macro extracts the minor version from a version number
 *
 * 1002003 becomes 2.
 *
 * \param version the version number.
 *
 * \threadsafety It is safe to call this macro from any thread.
 *
 * \since This macro is available since SDL 3.2.0.
  }
function SDL_VERSIONNUM_MINOR(version: Integer): Integer;

{*
 * This macro extracts the micro version from a version number
 *
 * 1002003 becomes 3.
 *
 * \param version the version number.
 *
 * \threadsafety It is safe to call this macro from any thread.
 *
 * \since This macro is available since SDL 3.2.0.
  }
function SDL_VERSIONNUM_MICRO(version: Integer): Integer;

{*
 * This is the version number macro for the current SDL version.
 *
 * \since This macro is available since SDL 3.2.0.
 *
 * \threadsafety It is safe to call this macro from any thread.
 *
 * \sa SDL_GetVersion
  }
function SDL_VERSION: Integer;

{*
 * This macro will evaluate to true if compiled with SDL at least X.Y.Z.
 *
 * \threadsafety It is safe to call this macro from any thread.
 *
 * \since This macro is available since SDL 3.2.0.
  }
function SDL_VERSION_ATLEAST(X, Y, Z: Integer): Boolean;

{*
 * Get the version of SDL that is linked against your program.
 *
 * If you are linking to SDL dynamically, then it is possible that the current
 * version will be different than the version you compiled against. This
 * function returns the current version, while SDL_VERSION is the version you
 * compiled with.
 *
 * This function may be called safely at any time, even before SDL_Init().
 *
 * \returns the version of the linked library.
 *
 * \threadsafety It is safe to call this macro from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetRevision
  }
function SDL_GetVersion: cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetVersion' {$ENDIF} {$ENDIF};

{*
 * Get the code revision of the SDL library that is linked against your
 * program.
 *
 * This value is the revision of the code you are linking against and may be
 * different from the code you are compiling with, which is found in the
 * constant SDL_REVISION if you explicitly include SDL_revision.h
 *
 * The revision is an arbitrary string (a hash value) uniquely identifying the
 * exact revision of the SDL library in use, and is only useful in comparing
 * against other revisions. It is NOT an incrementing number.
 *
 * If SDL wasn't built from a git repository with the appropriate tools, this
 * will return an empty string.
 *
 * You shouldn't use this function for anything but logging it for debugging
 * purposes. The string is not intended to be reliable in any way.
 *
 * \returns an arbitrary string, uniquely identifying the exact revision of
 *          the SDL library in use.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetVersion
  }
function SDL_GetRevision: PAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetRevision' {$ENDIF} {$ENDIF};

