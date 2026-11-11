{
  This file is part of:

    SDL3 for Pascal
    (https://github.com/PascalGameDevelopment/SDL3-for-Pascal)
    SPDX-License-Identifier: Zlib
}

{*
 * # CategoryPower
 *
 * SDL power management routines.
 *
 * There is a single function in this category: SDL_GetPowerInfo().
 *
 * This function is useful for games on the go. This allows an app to know if
 * it's running on a draining battery, which can be useful if the app wants to
 * reduce processing, or perhaps framerate, to extend the duration of the
 * battery's charge. Perhaps the app just wants to show a battery meter when
 * fullscreen, or alert the user when the power is getting extremely low, so
 * they can save their game.
  }

{*
 * The basic state for the system's power supply.
 *
 * These are results returned by SDL_GetPowerInfo().
 *
 * \since This enum is available since SDL 3.2.0
  }
type
  PPSDL_PowerState = ^PSDL_PowerState;
  PSDL_PowerState = ^TSDL_PowerState;
  TSDL_PowerState = type Integer;
const
  SDL_POWERSTATE_ERROR = TSDL_PowerState(-1);        {*< error determining power status  }
  SDL_POWERSTATE_UNKNOWN  = TSDL_PowerState(0);      {*< cannot determine power status  }
  SDL_POWERSTATE_ON_BATTERY  = TSDL_PowerState(1);   {*< Not plugged in, running on the battery  }
  SDL_POWERSTATE_NO_BATTERY  = TSDL_PowerState(2);   {*< Plugged in, no battery available  }
  SDL_POWERSTATE_CHARGING  = TSDL_PowerState(3);     {*< Plugged in, charging battery  }
  SDL_POWERSTATE_CHARGED  = TSDL_PowerState(4);      {*< Plugged in, battery charged  }

{*
 * Get the current power supply details.
 *
 * You should never take a battery status as absolute truth. Batteries
 * (especially failing batteries) are delicate hardware, and the values
 * reported here are best estimates based on what that hardware reports. It's
 * not uncommon for older batteries to lose stored power much faster than it
 * reports, or completely drain when reporting it has 20 percent left, etc.
 *
 * Battery status can change at any time; if you are concerned with power
 * state, you should call this function frequently, and perhaps ignore changes
 * until they seem to be stable for a few seconds.
 *
 * It's possible a platform can only report battery percentage or time left
 * but not both.
 *
 * On some platforms, retrieving power supply details might be expensive. If
 * you want to display continuous status you could call this function every
 * minute or so.
 *
 * \param seconds a pointer filled in with the seconds of battery life left,
 *                or NULL to ignore. This will be filled in with -1 if we
 *                can't determine a value or there is no battery.
 * \param percent a pointer filled in with the percentage of battery life
 *                left, between 0 and 100, or NULL to ignore. This will be
 *                filled in with -1 when we can't determine a value or there
 *                is no battery.
 * \returns the current battery state or `SDL_POWERSTATE_ERROR` on failure;
 *          call SDL_GetError() for more information.
 *
 * \threadsafety This function is not thread safe.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetPowerInfo(seconds: pcint; percent: pcint): TSDL_PowerState; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetPowerInfo' {$ENDIF} {$ENDIF};

