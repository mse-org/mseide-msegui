{
  This file is part of:

    SDL3 for Pascal
    (https://github.com/PascalGameDevelopment/SDL3-for-Pascal)
    SPDX-License-Identifier: Zlib
}

{*
 * # CategoryPlatform
 *
 * SDL provides a means to identify the app's platform, both at compile time
 * and runtime.
  }

{*
 * Get the name of the platform.
 *
 * Here are the names returned for some (but not all) supported platforms:
 *
 * - "Windows"
 * - "macOS"
 * - "Linux"
 * - "iOS"
 * - "Android"
 *
 * \returns the name of the platform. If the correct platform name is not
 *          available, returns a string beginning with the text "Unknown".
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetPlatform: PAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetPlatform' {$ENDIF} {$ENDIF};

