{
  This file is part of:

    SDL3 for Pascal
    (https://github.com/PascalGameDevelopment/SDL3-for-Pascal)
    SPDX-License-Identifier: Zlib
}

{*
 * # CategoryTime
 *
 * SDL realtime clock and date/time routines.
 *
 * There are two data types that are used in this category: SDL_Time, which
 * represents the nanoseconds since a specific moment (an "epoch"), and
 * SDL_DateTime, which breaks time down into human-understandable components:
 * years, months, days, hours, etc.
 *
 * Much of the functionality is involved in converting those two types to
 * other useful forms.
  }
{*
 * A structure holding a calendar date and time broken down into its
 * components.
 *
 * \since This struct is available since SDL 3.2.0.
  }
type
  PPSDL_DateTime = ^PSDL_DateTime;
  PSDL_DateTime = ^TSDL_DateTime;
  TSDL_DateTime = record
      year: cint;              {*< Year  }
      month: cint;             {*< Month [01-12]  }
      day: cint;               {*< Day of the month [01-31]  }
      hour: cint;              {*< Hour [0-23]  }
      minute: cint;            {*< Minute [0-59]  }
      second: cint;            {*< Seconds [0-60]  }
      nanosecond: cint;        {*< Nanoseconds [0-999999999]  }
      day_of_week: cint;       {*< Day of the week [0-6] (0 being Sunday)  }
      utc_offset: cint;        {*< Seconds east of UTC  }
    end;

{*
 * The preferred date format of the current system locale.
 *
 * \since This enum is available since SDL 3.2.0.
 *
 * \sa SDL_GetDateTimeLocalePreferences
  }
type
  PPSDL_DateFormat = ^PSDL_DateFormat;
  PSDL_DateFormat = ^TSDL_DateFormat;
  TSDL_DateFormat = type Integer;
const
  SDL_DATE_FORMAT_YYYYMMDD  = TSDL_DateFormat(0); {*< Year/Month/Day  }
  SDL_DATE_FORMAT_DDMMYYYY  = TSDL_DateFormat(1); {*< Day/Month/Year  }
  SDL_DATE_FORMAT_MMDDYYYY  = TSDL_DateFormat(2); {*< Month/Day/Year  }

{*
 * The preferred time format of the current system locale.
 *
 * \since This enum is available since SDL 3.2.0.
 *
 * \sa SDL_GetDateTimeLocalePreferences
  }
type
  PPSDL_TimeFormat = ^PSDL_TimeFormat;
  PSDL_TimeFormat = ^TSDL_TimeFormat;
  TSDL_TimeFormat = type Integer;
const
  SDL_TIME_FORMAT_24HR  = TSDL_TimeFormat(0); {*< 24 hour time  }
  SDL_TIME_FORMAT_12HR  = TSDL_TimeFormat(1); {*< 12 hour time  }

{*
 * Gets the current preferred date and time format for the system locale.
 *
 * This might be a "slow" call that has to query the operating system. It's
 * best to ask for this once and save the results. However, the preferred
 * formats can change, usually because the user has changed a system
 * preference outside of your program.
 *
 * \param dateFormat a Pointer to the SDL_DateFormat to hold the returned date
 *                   format, may be nil.
 * \param timeFormat a Pointer to the SDL_TimeFormat to hold the returned time
 *                   format, may be nil.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function is not thread safe.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetDateTimeLocalePreferences(dateFormat: PSDL_DateFormat; timeFormat: PSDL_TimeFormat): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetDateTimeLocalePreferences' {$ENDIF} {$ENDIF};

{*
 * Gets the current value of the system realtime clock in nanoseconds since
 * Jan 1, 1970 in Universal Coordinated Time (UTC).
 *
 * \param ticks the SDL_Time to hold the returned tick count.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetCurrentTime(ticks: PSDL_Time): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetCurrentTime' {$ENDIF} {$ENDIF};

{*
 * Converts an SDL_Time in nanoseconds since the epoch to a calendar time in
 * the SDL_DateTime format.
 *
 * \param ticks the SDL_Time to be converted.
 * \param dt the resulting SDL_DateTime.
 * \param localTime the resulting SDL_DateTime will be expressed in local time
 *                  if true, otherwise it will be in Universal Coordinated
 *                  Time (UTC).
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_TimeToDateTime(ticks: TSDL_Time; dt: PSDL_DateTime; localTime: Boolean): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_TimeToDateTime' {$ENDIF} {$ENDIF};

{*
 * Converts a calendar time to an SDL_Time in nanoseconds since the epoch.
 *
 * This function ignores the day_of_week member of the SDL_DateTime struct, so
 * it may remain unset.
 *
 * \param dt the source SDL_DateTime.
 * \param ticks the resulting SDL_Time.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_DateTimeToTime(dt: PSDL_DateTime; ticks: PSDL_Time): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_DateTimeToTime' {$ENDIF} {$ENDIF};

{*
 * Converts an SDL time into a Windows FILETIME (100-nanosecond intervals
 * since January 1, 1601).
 *
 * This function fills in the two 32-bit values of the FILETIME structure.
 *
 * \param ticks the time to convert.
 * \param dwLowDateTime a Pointer filled in with the low portion of the
 *                      Windows FILETIME value.
 * \param dwHighDateTime a Pointer filled in with the high portion of the
 *                       Windows FILETIME value.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
procedure SDL_TimeToWindows(ticks: TSDL_Time; dwLowDateTime: pcuint32; dwHighDateTime: pcuint32); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_TimeToWindows' {$ENDIF} {$ENDIF};

{*
 * Converts a Windows FILETIME (100-nanosecond intervals since January 1,
 * 1601) to an SDL time.
 *
 * This function takes the two 32-bit values of the FILETIME structure as
 * parameters.
 *
 * \param dwLowDateTime the low portion of the Windows FILETIME value.
 * \param dwHighDateTime the high portion of the Windows FILETIME value.
 * \returns the converted SDL time.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_TimeFromWindows(dwLowDateTime: cuint32; dwHighDateTime: cuint32): TSDL_Time; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_TimeFromWindows' {$ENDIF} {$ENDIF};

{*
 * Get the number of days in a month for a given year.
 *
 * \param year the year.
 * \param month the month [1-12].
 * \returns the number of days in the requested month or -1 on failure; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetDaysInMonth(year: cint; month: cint): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetDaysInMonth' {$ENDIF} {$ENDIF};

{*
 * Get the day of year for a calendar date.
 *
 * \param year the year component of the date.
 * \param month the month component of the date.
 * \param day the day component of the date.
 * \returns the day of year [0-365] if the date is valid or -1 on failure;
 *          call SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetDayOfYear(year: cint; month: cint; day: cint): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetDayOfYear' {$ENDIF} {$ENDIF};

{*
 * Get the day of week for a calendar date.
 *
 * \param year the year component of the date.
 * \param month the month component of the date.
 * \param day the day component of the date.
 * \returns a value between 0 and 6 (0 being Sunday) if the date is valid or
 *          -1 on failure; call SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetDayOfWeek(year: cint; month: cint; day: cint): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetDayOfWeek' {$ENDIF} {$ENDIF};

