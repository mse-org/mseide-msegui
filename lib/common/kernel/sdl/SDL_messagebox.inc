{
  This file is part of:

    SDL3 for Pascal
    (https://github.com/PascalGameDevelopment/SDL3-for-Pascal)
    SPDX-License-Identifier: Zlib
}

{*
 * # CategoryMessagebox
 *
 * SDL offers a simple message box API, which is useful for simple alerts,
 * such as informing the user when something fatal happens at startup without
 * the need to build a UI for it (or informing the user _before_ your UI is
 * ready).
 *
 * These message boxes are native system dialogs where possible.
 *
 * There is both a customizable function (SDL_ShowMessageBox()) that offers
 * lots of options for what to display and reports on what choice the user
 * made, and also a much-simplified version (SDL_ShowSimpleMessageBox()),
 * merely takes a text message and title, and waits until the user presses a
 * single "OK" UI button. Often, this is all that is necessary.
  }

{*
 * Message box flags.
 *
 * If supported will display warning icon, etc.
 *
 * \since This datatype is available since SDL 3.2.0.
  }
type
  PPSDL_MessageBoxFlags = ^PSDL_MessageBoxFlags;
  PSDL_MessageBoxFlags = ^TSDL_MessageBoxFlags;
  TSDL_MessageBoxFlags = type cuint32;
const
  SDL_MESSAGEBOX_ERROR  = TSDL_MessageBoxFlags($00000010);                 {*< error dialog  }
  SDL_MESSAGEBOX_WARNING  = TSDL_MessageBoxFlags($00000020);               {*< warning dialog  }
  SDL_MESSAGEBOX_INFORMATION  = TSDL_MessageBoxFlags($00000040);           {*< informational dialog  }
  SDL_MESSAGEBOX_BUTTONS_LEFT_TO_RIGHT  = TSDL_MessageBoxFlags($00000080); {*< buttons placed left to right  }
  SDL_MESSAGEBOX_BUTTONS_RIGHT_TO_LEFT  = TSDL_MessageBoxFlags($00000100); {*< buttons placed right to left  }

{*
 * SDL_MessageBoxButtonData flags.
 *
 * \since This datatype is available since SDL 3.2.0.
  }
type
  PPSDL_MessageBoxButtonFlags = ^PSDL_MessageBoxButtonFlags;
  PSDL_MessageBoxButtonFlags = ^TSDL_MessageBoxButtonFlags;
  TSDL_MessageBoxButtonFlags = type cuint32;
const
  SDL_MESSAGEBOX_BUTTON_RETURNKEY_DEFAULT  = TSDL_MessageBoxButtonFlags($00000001); {*< Marks the default button when return is hit  }
  SDL_MESSAGEBOX_BUTTON_ESCAPEKEY_DEFAULT  = TSDL_MessageBoxButtonFlags($00000002); {*< Marks the default button when escape is hit  }

{*
 * Individual button data.
 *
 * \since This struct is available since SDL 3.2.0.
  }
type
  PPSDL_MessageBoxButtonData = ^PSDL_MessageBoxButtonData;
  PSDL_MessageBoxButtonData = ^TSDL_MessageBoxButtonData;
  TSDL_MessageBoxButtonData = record
      flags: TSDL_MessageBoxButtonFlags;
      buttonID: cint;                    {*< User defined button id (value returned via SDL_ShowMessageBox)  }
      text: PAnsiChar;                   {*< The UTF-8 button text  }
    end;

{*
 * RGB value used in a message box color scheme
 *
 * \since This struct is available since SDL 3.2.0.
  }
type
  PPSDL_MessageBoxColor = ^PSDL_MessageBoxColor;
  PSDL_MessageBoxColor = ^TSDL_MessageBoxColor;
  TSDL_MessageBoxColor = record
      r: cuint8;
      g: cuint8;
      b: cuint8;
    end;

{*
 * An enumeration of indices inside the colors array of
 * SDL_MessageBoxColorScheme.
  }
type
  PPSDL_MessageBoxColorType = ^PSDL_MessageBoxColorType;
  PSDL_MessageBoxColorType = ^TSDL_MessageBoxColorType;
  TSDL_MessageBoxColorType = type Integer;
const
  SDL_MESSAGEBOX_COLOR_BACKGROUND  = TSDL_MessageBoxColorType(0);
  SDL_MESSAGEBOX_COLOR_TEXT  = TSDL_MessageBoxColorType(1);
  SDL_MESSAGEBOX_COLOR_BUTTON_BORDER  = TSDL_MessageBoxColorType(2);
  SDL_MESSAGEBOX_COLOR_BUTTON_BACKGROUND  = TSDL_MessageBoxColorType(3);
  SDL_MESSAGEBOX_COLOR_BUTTON_SELECTED  = TSDL_MessageBoxColorType(4);
  SDL_MESSAGEBOX_COLOR_COUNT  = TSDL_MessageBoxColorType(5);             {*< Size of the colors array of SDL_MessageBoxColorScheme.  }

{*
 * A set of colors to use for message box dialogs
 *
 * \since This struct is available since SDL 3.2.0.
  }
type
  PPSDL_MessageBoxColorScheme = ^PSDL_MessageBoxColorScheme;
  PSDL_MessageBoxColorScheme = ^TSDL_MessageBoxColorScheme;
  TSDL_MessageBoxColorScheme = record
      colors: array[0..SDL_MESSAGEBOX_COLOR_COUNT-1] of TSDL_MessageBoxColor;
    end;

{*
 * MessageBox structure containing title, text, window, etc.
 *
 * \since This struct is available since SDL 3.2.0.
  }
type
  PPSDL_MessageBoxData = ^PSDL_MessageBoxData;
  PSDL_MessageBoxData = ^TSDL_MessageBoxData;
  TSDL_MessageBoxData = record
      flags: TSDL_MessageBoxFlags;
      window: PSDL_Window;            {*< Parent window, can be nil  }
      title: PAnsiChar;               {*< UTF-8 title  }
      message: PAnsiChar;             {*< UTF-8 message text  }

      numbuttons: cint;
      buttons: PSDL_MessageBoxButtonData;

      colorScheme: PSDL_MessageBoxColorScheme; {*< SDL_MessageBoxColorScheme, can be nil to use system settings  }
    end;

{*
 * Create a modal message box.
 *
 * If your needs aren't complex, it might be easier to use
 * SDL_ShowSimpleMessageBox.
 *
 * This function should be called on the thread that created the parent
 * window, or on the main thread if the messagebox has no parent. It will
 * block execution of that thread until the user clicks a button or closes the
 * messagebox.
 *
 * This function may be called at any time, even before SDL_Init(). This makes
 * it useful for reporting errors like a failure to create a renderer or
 * OpenGL context.
 *
 * On X11, SDL rolls its own dialog box with X11 primitives instead of a
 * formal toolkit like GTK+ or Qt.
 *
 * Note that if SDL_Init() would fail because there isn't any available video
 * target, this function is likely to fail for the same reasons. If this is a
 * concern, check the return value from this function and fall back to writing
 * to stderr if you can.
 *
 * \param messageboxdata the SDL_MessageBoxData structure with title, text and
 *                       other options.
 * \param buttonid the Pointer to which user id of hit button should be
 *                 copied.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_ShowSimpleMessageBox
  }
function SDL_ShowMessageBox(messageboxdata: PSDL_MessageBoxData; buttonid: pcint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ShowMessageBox' {$ENDIF} {$ENDIF};

{*
 * Display a simple modal message box.
 *
 * If your needs aren't complex, this function is preferred over
 * SDL_ShowMessageBox.
 *
 * `flags` may be any of the following:
 *
 * - `SDL_MESSAGEBOX_ERROR`: error dialog
 * - `SDL_MESSAGEBOX_WARNING`: warning dialog
 * - `SDL_MESSAGEBOX_INFORMATION`: informational dialog
 *
 * This function should be called on the thread that created the parent
 * window, or on the main thread if the messagebox has no parent. It will
 * block execution of that thread until the user clicks a button or closes the
 * messagebox.
 *
 * This function may be called at any time, even before SDL_Init(). This makes
 * it useful for reporting errors like a failure to create a renderer or
 * OpenGL context.
 *
 * On X11, SDL rolls its own dialog box with X11 primitives instead of a
 * formal toolkit like GTK+ or Qt.
 *
 * Note that if SDL_Init() would fail because there isn't any available video
 * target, this function is likely to fail for the same reasons. If this is a
 * concern, check the return value from this function and fall back to writing
 * to stderr if you can.
 *
 * \param flags an SDL_MessageBoxFlags value.
 * \param title UTF-8 title text.
 * \param message UTF-8 message text.
 * \param window the parent window, or nil for no parent.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_ShowMessageBox
  }
function SDL_ShowSimpleMessageBox(flags: TSDL_MessageBoxFlags; title: PAnsiChar; message: PAnsiChar; window: PSDL_Window): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ShowSimpleMessageBox' {$ENDIF} {$ENDIF};

