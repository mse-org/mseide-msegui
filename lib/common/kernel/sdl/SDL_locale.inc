{
  This file is part of:

    SDL3 for Pascal
    (https://github.com/PascalGameDevelopment/SDL3-for-Pascal)
    SPDX-License-Identifier: Zlib
}

{*
 * # CategoryLocale
 *
 * SDL locale services.
 *
 * This provides a way to get a list of preferred locales (language plus
 * country) for the user. There is exactly one function:
 * SDL_GetPreferredLocales(), which handles all the heavy lifting, and offers
 * documentation on all the strange ways humans might have configured their
 * language settings.
  }

{*
 * A struct to provide locale data.
 *
 * Locale data is split into a spoken language, like English, and an optional
 * country, like Canada. The language will be in ISO-639 format (so English
 * would be "en"), and the country, if not nil, will be an ISO-3166 country
 * code (so Canada would be "CA").
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetPreferredLocales
  }
type
  PPSDL_Locale = ^PSDL_Locale;
  PSDL_Locale = ^TSDL_Locale;
  TSDL_Locale = record
      language: PAnsiChar; {*< A language name, like "en" for English.  }
      country: PAnsiChar;  {*< A country, like "US" for America. Can be nil.  }
    end;

{*
 * Report the user's preferred locale.
 *
 * Returned language strings are in the format xx, where 'xx' is an ISO-639
 * language specifier (such as "en" for English, "de" for German, etc).
 * Country strings are in the format YY, where "YY" is an ISO-3166 country
 * code (such as "US" for the United States, "CA" for Canada, etc). Country
 * might be nil if there's no specific guidance on them (so you might get
 * "en", "US"  for American English, but  "en", nil  means "English
 * language, generically"). Language strings are never nil, except to
 * terminate the array.
 *
 * Please note that not all of these strings are 2 characters; some are three
 * or more.
 *
 * The returned list of locales are in the order of the user's preference. For
 * example, a German citizen that is fluent in US English and knows enough
 * Japanese to navigate around Tokyo might have a list like:  "de", "en_US",
 * "jp", nil . Someone from England might prefer British English (where
 * "color" is spelled "colour", etc), but will settle for anything like it:
 * "en_GB", "en", nil .
 *
 * This function returns nil on error, including when the platform does not
 * supply this information at all.
 *
 * This might be a "slow" call that has to query the operating system. It's
 * best to ask for this once and save the results. However, this list can
 * change, usually because the user has changed a system preference outside of
 * your program; SDL will send an SDL_EVENT_LOCALE_CHANGED event in this case,
 * if possible, and you can call this function again to get an updated copy of
 * preferred locales.
 *
 * \param count a Pointer filled in with the number of locales returned, may
 *              be nil.
 * \returns a nil terminated array of locale pointers, or nil on failure;
 *          call SDL_GetError() for more information. This is a single
 *          allocation that should be freed with SDL_free() when it is no
 *          longer needed.
 *
 * \threadsafety This function is not thread safe.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetPreferredLocales(count: pcint):PPSDL_Locale; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetPreferredLocales' {$ENDIF} {$ENDIF};

