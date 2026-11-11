{
  This file is part of:

    SDL3 for Pascal
    (https://github.com/PascalGameDevelopment/SDL3-for-Pascal)
    SPDX-License-Identifier: Zlib
}

{*
* # CategoryKeyboard
*
* SDL keyboard management.
*
* Please refer to the Best Keyboard Practices document for details on how
* best to accept keyboard input in various types of programs:
*
* https://wiki.libsdl.org/SDL3/BestKeyboardPractices
}

{*
 * This is a unique ID for a keyboard for the time it is connected to the
 * system, and is never reused for the lifetime of the application.
 *
 * If the keyboard is disconnected and reconnected, it will get a new ID.
 *
 * The value 0 is an invalid ID.
 *
 * \since This datatype is available since SDL 3.2.0.
  }
type
  PPSDL_KeyboardID = ^PSDL_KeyboardID;
  PSDL_KeyboardID = ^TSDL_KeyboardID;
  TSDL_KeyboardID = cuint32;

{ Function prototypes  }

{*
 * Return whether a keyboard is currently connected.
 *
 * \returns true if a keyboard is connected, false otherwise.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetKeyboards
  }
function SDL_HasKeyboard: Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_HasKeyboard' {$ENDIF} {$ENDIF};

{*
 * Get a list of currently connected keyboards.
 *
 * Note that this will include any device or virtual driver that includes
 * keyboard functionality, including some mice, KVM switches, motherboard
 * power buttons, etc. You should wait for input from a device before you
 * consider it actively in use.
 *
 * \param count a Pointer filled in with the number of keyboards returned, may
 *              be nil.
 * \returns a 0 terminated array of keyboards instance IDs or nil on failure;
 *          call SDL_GetError() for more information. This should be freed
 *          with SDL_free() when it is no longer needed.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetKeyboardNameForID
 * \sa SDL_HasKeyboard
  }
function SDL_GetKeyboards(count: pcint): PSDL_KeyboardID; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetKeyboards' {$ENDIF} {$ENDIF};

{*
 * Get the name of a keyboard.
 *
 * This function returns "" if the keyboard doesn't have a name.
 *
 * \param instance_id the keyboard instance ID.
 * \returns the name of the selected keyboard or nil on failure; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetKeyboards
  }
function SDL_GetKeyboardNameForID(instance_id: TSDL_KeyboardID): PAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetKeyboardNameForID' {$ENDIF} {$ENDIF};

{*
 * Query the window which currently has keyboard focus.
 *
 * \returns the window with keyboard focus.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetKeyboardFocus: PSDL_Window; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetKeyboardFocus' {$ENDIF} {$ENDIF};

{*
 * Get a snapshot of the current state of the keyboard.
 *
 * The Pointer returned is a Pointer to an internal SDL array. It will be
 * valid for the whole lifetime of the application and should not be freed by
 * the caller.
 *
 * A array element with a value of true means that the key is pressed and a
 * value of false means that it is not. Indexes into this array are obtained
 * by using SDL_Scancode values.
 *
 * Use SDL_PumpEvents() to update the state array.
 *
 * This function gives you the current state after all events have been
 * processed, so if a key or button has been pressed and released before you
 * process events, then the pressed state will never show up in the
 * SDL_GetKeyboardState() calls.
 *
 * Note: This function doesn't take into account whether shift has been
 * pressed or not.
 *
 * \param numkeys if non-nil, receives the length of the returned array.
 * \returns a Pointer to an array of key states.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_PumpEvents
 * \sa SDL_ResetKeyboard
  }
function SDL_GetKeyboardState(numkeys: pcint): pBoolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetKeyboardState' {$ENDIF} {$ENDIF};

{*
 * Clear the state of the keyboard.
 *
 * This function will generate key up events for all pressed keys.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetKeyboardState
  }
procedure SDL_ResetKeyboard; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ResetKeyboard' {$ENDIF} {$ENDIF};

{*
 * Get the current key modifier state for the keyboard.
 *
 * \returns an OR'd combination of the modifier keys for the keyboard.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetKeyboardState
 * \sa SDL_SetModState
  }
function SDL_GetModState: TSDL_Keymod; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetModState' {$ENDIF} {$ENDIF};

{*
 * Set the current key modifier state for the keyboard.
 *
 * The inverse of SDL_GetModState(), SDL_SetModState() allows you to impose
 * modifier key states on your application. Simply pass your desired modifier
 * states into `modstate`. This value may be a bitwise, OR'd combination of
 * SDL_Keymod values.
 *
 * This does not change the keyboard state, only the key modifier flags that
 * SDL reports.
 *
 * \param modstate the desired SDL_Keymod for the keyboard.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetModState
  }
procedure SDL_SetModState(modstate: TSDL_Keymod); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetModState' {$ENDIF} {$ENDIF};

{*
 * Get the key code corresponding to the given scancode according to the
 * current keyboard layout.
 *
 * If you want to get the keycode as it would be delivered in key events,
 * including options specified in SDL_HINT_KEYCODE_OPTIONS, then you should
 * pass `key_event` as true. Otherwise this function simply translates the
 * scancode based on the given modifier state.
 *
 * \param scancode the desired SDL_Scancode to query.
 * \param modstate the modifier state to use when translating the scancode to
 *                 a keycode.
 * \param key_event true if the keycode will be used in key events.
 * \returns the SDL_Keycode that corresponds to the given SDL_Scancode.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetKeyName
 * \sa SDL_GetScancodeFromKey
  }
function SDL_GetKeyFromScancode(scancode: TSDL_Scancode; modstate: TSDL_Keymod; key_event: Boolean): TSDL_Keycode; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetKeyFromScancode' {$ENDIF} {$ENDIF};

{*
 * Get the scancode corresponding to the given key code according to the
 * current keyboard layout.
 *
 * Note that there may be multiple scancode+modifier states that can generate
 * this keycode, this will just return the first one found.
 *
 * \param key the desired SDL_Keycode to query.
 * \param modstate a Pointer to the modifier state that would be used when the
 *                 scancode generates this key, may be nil.
 * \returns the SDL_Scancode that corresponds to the given SDL_Keycode.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetKeyFromScancode
 * \sa SDL_GetScancodeName
  }
function SDL_GetScancodeFromKey(key: TSDL_Keycode; modstate: PSDL_Keymod): TSDL_Scancode; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetScancodeFromKey' {$ENDIF} {$ENDIF};

{*
 * Set a human-readable name for a scancode.
 *
 * \param scancode the desired SDL_Scancode.
 * \param name the name to use for the scancode, encoded as UTF-8. The string
 *             is not copied, so the Pointer given to this function must stay
 *             valid while SDL is being used.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetScancodeName
  }
function SDL_SetScancodeName(scancode: TSDL_Scancode; name: PAnsiChar): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetScancodeName' {$ENDIF} {$ENDIF};

{*
 * Get a human-readable name for a scancode.
 *
 * **Warning**: The returned name is by design not stable across platforms,
 * e.g. the name for `SDL_SCANCODE_LGUI` is "Left GUI" under Linux but "Left
 * Windows" under Microsoft Windows, and some scancodes like
 * `SDL_SCANCODE_NONUSBACKSLASH` don't have any name at all. There are even
 * scancodes that share names, e.g. `SDL_SCANCODE_RETURN` and
 * `SDL_SCANCODE_RETURN2` (both called "Return"). This function is therefore
 * unsuitable for creating a stable cross-platform two-way mapping between
 * strings and scancodes.
 *
 * \param scancode the desired SDL_Scancode to query.
 * \returns a Pointer to the name for the scancode. If the scancode doesn't
 *          have a name this function returns an empty string ("").
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetScancodeFromKey
 * \sa SDL_GetScancodeFromName
 * \sa SDL_SetScancodeName
  }
function SDL_GetScancodeName(scancode: TSDL_Scancode): PAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetScancodeName' {$ENDIF} {$ENDIF};

{*
 * Get a scancode from a human-readable name.
 *
 * \param name the human-readable scancode name.
 * \returns the SDL_Scancode, or `SDL_SCANCODE_UNKNOWN` if the name wasn't
 *          recognized; call SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetKeyFromName
 * \sa SDL_GetScancodeFromKey
 * \sa SDL_GetScancodeName
  }
function SDL_GetScancodeFromName(name: PAnsiChar): TSDL_Scancode; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetScancodeFromName' {$ENDIF} {$ENDIF};

{*
 * Get a human-readable name for a key.
 *
 * If the key doesn't have a name, this function returns an empty string ("").
 *
 * Letters will be presented in their uppercase form, if applicable.
 *
 * \param key the desired SDL_Keycode to query.
 * \returns a UTF-8 encoded string of the key name.
 *
 * \threadsafety This function is not thread safe.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetKeyFromName
 * \sa SDL_GetKeyFromScancode
 * \sa SDL_GetScancodeFromKey
  }
function SDL_GetKeyName(key: TSDL_Keycode): PAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetKeyName' {$ENDIF} {$ENDIF};

{*
 * Get a key code from a human-readable name.
 *
 * \param name the human-readable key name.
 * \returns key code, or `SDLK_UNKNOWN` if the name wasn't recognized; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety This function is not thread safe.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetKeyFromScancode
 * \sa SDL_GetKeyName
 * \sa SDL_GetScancodeFromName
  }
function SDL_GetKeyFromName(name: PAnsiChar): TSDL_Keycode; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetKeyFromName' {$ENDIF} {$ENDIF};

{*
 * Start accepting Unicode text input events in a window.
 *
 * This function will enable text input (SDL_EVENT_TEXT_INPUT and
 * SDL_EVENT_TEXT_EDITING events) in the specified window. Please use this
 * function paired with SDL_StopTextInput().
 *
 * Text input events are not received by default.
 *
 * On some platforms using this function shows the screen keyboard and/or
 * activates an IME, which can prevent some key press events from being passed
 * through.
 *
 * \param window the window to enable text input.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function is not thread safe.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetTextInputArea
 * \sa SDL_StartTextInputWithProperties
 * \sa SDL_StopTextInput
 * \sa SDL_TextInputActive
  }
function SDL_StartTextInput(window: PSDL_Window): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_StartTextInput' {$ENDIF} {$ENDIF};

{*
 * Text input type.
 *
 * These are the valid values for SDL_PROP_TEXTINPUT_TYPE_NUMBER. Not every
 * value is valid on every platform, but where a value isn't supported, a
 * reasonable fallback will be used.
 *
 * \since This enum is available since SDL 3.2.0.
 *
 * \sa SDL_StartTextInputWithProperties
  }
type
  PPSDL_TextInputType = ^PSDL_TextInputType;
  PSDL_TextInputType = ^TSDL_TextInputType;
  TSDL_TextInputType = type Integer;
const
  SDL_TEXTINPUT_TYPE_TEXT  = TSDL_TextInputType(0);                    {*< The input is text  }
  SDL_TEXTINPUT_TYPE_TEXT_NAME  = TSDL_TextInputType(1);               {*< The input is a person's name  }
  SDL_TEXTINPUT_TYPE_TEXT_EMAIL  = TSDL_TextInputType(2);              {*< The input is an e-mail address  }
  SDL_TEXTINPUT_TYPE_TEXT_USERNAME  = TSDL_TextInputType(3);           {*< The input is a username  }
  SDL_TEXTINPUT_TYPE_TEXT_PASSWORD_HIDDEN  = TSDL_TextInputType(4);    {*< The input is a secure password that is hidden  }
  SDL_TEXTINPUT_TYPE_TEXT_PASSWORD_VISIBLE  = TSDL_TextInputType(5);   {*< The input is a secure password that is visible  }
  SDL_TEXTINPUT_TYPE_NUMBER  = TSDL_TextInputType(6);                  {*< The input is a number  }
  SDL_TEXTINPUT_TYPE_NUMBER_PASSWORD_HIDDEN  = TSDL_TextInputType(7);  {*< The input is a secure PIN that is hidden  }
  SDL_TEXTINPUT_TYPE_NUMBER_PASSWORD_VISIBLE  = TSDL_TextInputType(8); {*< The input is a secure PIN that is visible  }

{*
 * Auto capitalization type.
 *
 * These are the valid values for SDL_PROP_TEXTINPUT_CAPITALIZATION_NUMBER.
 * Not every value is valid on every platform, but where a value isn't
 * supported, a reasonable fallback will be used.
 *
 * \since This enum is available since SDL 3.2.0.
 *
 * \sa SDL_StartTextInputWithProperties
  }
type
  PPSDL_Capitalization = ^PSDL_Capitalization;
  PSDL_Capitalization = ^TSDL_Capitalization;
  TSDL_Capitalization = type Integer;
const
  SDL_CAPITALIZE_NONE  = TSDL_Capitalization(0);      {*< No auto-capitalization will be done  }
  SDL_CAPITALIZE_SENTENCES  = TSDL_Capitalization(1); {*< The first letter of sentences will be capitalized  }
  SDL_CAPITALIZE_WORDS  = TSDL_Capitalization(2);     {*< The first letter of words will be capitalized  }
  SDL_CAPITALIZE_LETTERS  = TSDL_Capitalization(3);   {*< All letters will be capitalized  }

{*
 * Start accepting Unicode text input events in a window, with properties
 * describing the input.
 *
 * This function will enable text input (SDL_EVENT_TEXT_INPUT and
 * SDL_EVENT_TEXT_EDITING events) in the specified window. Please use this
 * function paired with SDL_StopTextInput().
 *
 * Text input events are not received by default.
 *
 * On some platforms using this function shows the screen keyboard and/or
 * activates an IME, which can prevent some key press events from being passed
 * through.
 *
 * These are the supported properties:
 *
 * - `SDL_PROP_TEXTINPUT_TYPE_NUMBER` - an SDL_TextInputType value that
 *   describes text being input, defaults to SDL_TEXTINPUT_TYPE_TEXT.
 * - `SDL_PROP_TEXTINPUT_CAPITALIZATION_NUMBER` - an SDL_Capitalization value
 *   that describes how text should be capitalized, defaults to
 *   SDL_CAPITALIZE_SENTENCES for normal text entry, SDL_CAPITALIZE_WORDS for
 *   SDL_TEXTINPUT_TYPE_TEXT_NAME, and SDL_CAPITALIZE_NONE for e-mail
 *   addresses, usernames, and passwords.
 * - `SDL_PROP_TEXTINPUT_AUTOCORRECT_BOOLEAN` - true to enable auto completion
 *   and auto correction, defaults to true.
 * - `SDL_PROP_TEXTINPUT_MULTILINE_BOOLEAN` - true if multiple lines of text
 *   are allowed. This defaults to true if SDL_HINT_RETURN_KEY_HIDES_IME is
 *   "0" or is not set, and defaults to false if SDL_HINT_RETURN_KEY_HIDES_IME
 *   is "1".
 *
 * On Android you can directly specify the input type:
 *
 * - `SDL_PROP_TEXTINPUT_ANDROID_INPUTTYPE_NUMBER` - the text input type to
 *   use, overriding other properties. This is documented at
 *   https://developer.android.com/reference/android/text/InputType
 *
 * \param window the window to enable text input.
 * \param props the properties to use.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetTextInputArea
 * \sa SDL_StartTextInput
 * \sa SDL_StopTextInput
 * \sa SDL_TextInputActive
  }
function SDL_StartTextInputWithProperties(window: PSDL_Window; props: TSDL_PropertiesID): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_StartTextInputWithProperties' {$ENDIF} {$ENDIF};

  const
  SDL_PROP_TEXTINPUT_TYPE_NUMBER = 'SDL.textinput.type';
  SDL_PROP_TEXTINPUT_CAPITALIZATION_NUMBER = 'SDL.textinput.capitalization';
  SDL_PROP_TEXTINPUT_AUTOCORRECT_BOOLEAN = 'SDL.textinput.autocorrect';
  SDL_PROP_TEXTINPUT_MULTILINE_BOOLEAN = 'SDL.textinput.multiline';
  SDL_PROP_TEXTINPUT_ANDROID_INPUTTYPE_NUMBER = 'SDL.textinput.android.inputtype';

{*
 * Check whether or not Unicode text input events are enabled for a window.
 *
 * \param window the window to check.
 * \returns true if text input events are enabled else false.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_StartTextInput
  }
function SDL_TextInputActive(window: PSDL_Window): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_TextInputActive' {$ENDIF} {$ENDIF};

{*
 * Stop receiving any text input events in a window.
 *
 * If SDL_StartTextInput() showed the screen keyboard, this function will hide
 * it.
 *
 * \param window the window to disable text input.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_StartTextInput
  }
function SDL_StopTextInput(window: PSDL_Window): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_StopTextInput' {$ENDIF} {$ENDIF};

{*
 * Dismiss the composition window/IME without disabling the subsystem.
 *
 * \param window the window to affect.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_StartTextInput
 * \sa SDL_StopTextInput
  }
function SDL_ClearComposition(window: PSDL_Window): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ClearComposition' {$ENDIF} {$ENDIF};

{*
 * Set the area used to type Unicode text input.
 *
 * Native input methods may place a window with word suggestions near the
 * cursor, without covering the text being entered.
 *
 * \param window the window for which to set the text input area.
 * \param rect the SDL_Rect representing the text input area, in window
 *             coordinates, or nil to clear it.
 * \param cursor the offset of the current cursor location relative to
 *               `rect->x`, in window coordinates.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetTextInputArea
 * \sa SDL_StartTextInput
  }

function SDL_SetTextInputArea(window: PSDL_Window; rect: PSDL_Rect; cursor: cint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetTextInputArea' {$ENDIF} {$ENDIF};

{*
 * Get the area used to type Unicode text input.
 *
 * This returns the values previously set by SDL_SetTextInputArea().
 *
 * \param window the window for which to query the text input area.
 * \param rect a Pointer to an SDL_Rect filled in with the text input area,
 *             may be nil.
 * \param cursor a Pointer to the offset of the current cursor location
 *               relative to `rect->x`, may be nil.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetTextInputArea
  }
function SDL_GetTextInputArea(window: PSDL_Window; rect: PSDL_Rect; cursor: pcint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetTextInputArea' {$ENDIF} {$ENDIF};

{*
 * Check whether the platform has screen keyboard support.
 *
 * \returns true if the platform has some screen keyboard support or false if
 *          not.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_StartTextInput
 * \sa SDL_ScreenKeyboardShown
  }
function SDL_HasScreenKeyboardSupport: Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_HasScreenKeyboardSupport' {$ENDIF} {$ENDIF};

{*
 * Check whether the screen keyboard is shown for given window.
 *
 * \param window the window for which screen keyboard should be queried.
 * \returns true if screen keyboard is shown or false if not.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_HasScreenKeyboardSupport
  }
function SDL_ScreenKeyboardShown(window: PSDL_Window): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ScreenKeyboardShown' {$ENDIF} {$ENDIF};

