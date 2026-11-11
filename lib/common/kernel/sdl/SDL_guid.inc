{
  This file is part of:

    SDL3 for Pascal
    (https://github.com/PascalGameDevelopment/SDL3-for-Pascal)
    SPDX-License-Identifier: Zlib
}

{*
 * # CategoryGUID
 *
 * A GUID is a 128-bit value that represents something that is uniquely
 * identifiable by this value: "globally unique."
 *
 * SDL provides functions to convert a GUID to/from a string.
  }

{*
 * An SDL_GUID is a 128-bit identifier for an input device that identifies
 * that device across runs of SDL programs on the same platform.
 *
 * If the device is detached and then re-attached to a different port, or if
 * the base system is rebooted, the device should still report the same GUID.
 *
 * GUIDs are as precise as possible but are not guaranteed to distinguish
 * physically distinct but equivalent devices. For example, two game
 * controllers from the same vendor with the same product ID and revision may
 * have the same GUID.
 *
 * GUIDs may be platform-dependent (i.e., the same device may report different
 * GUIDs on different operating systems).
 *
 * \since This struct is available since SDL 3.2.0.
  }
type
  PPSDL_GUID = ^PSDL_GUID;
  PSDL_GUID = ^TSDL_GUID;
  TSDL_GUID = record
      data: array[0..15] of cuint8;
    end;

{ Function prototypes  }

{*
 * Get an ASCII string representation for a given SDL_GUID.
 *
 * \param guid the SDL_GUID you wish to convert to string.
 * \param pszGUID buffer in which to write the ASCII string.
 * \param cbGUID the size of pszGUID, should be at least 33 bytes.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_StringToGUID
  }
procedure SDL_GUIDToString(guid: TSDL_GUID; pszGUID: PAnsiChar; cbGUID: cint); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GUIDToString' {$ENDIF} {$ENDIF};

{*
 * Convert a GUID string into a SDL_GUID structure.
 *
 * Performs no error checking. If this function is given a string containing
 * an invalid GUID, the function will silently succeed, but the GUID generated
 * will not be useful.
 *
 * \param pchGUID string containing an ASCII representation of a GUID.
 * \returns a SDL_GUID structure.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GUIDToString
  }
function SDL_StringToGUID(pchGUID: PAnsiChar): TSDL_GUID; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_StringToGUID' {$ENDIF} {$ENDIF};

