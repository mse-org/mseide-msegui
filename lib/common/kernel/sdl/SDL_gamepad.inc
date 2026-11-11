{
  This file is part of:

    SDL3 for Pascal
    (https://github.com/PascalGameDevelopment/SDL3-for-Pascal)
    SPDX-License-Identifier: Zlib
}

{*
 * # CategoryGamepad
 *
 * SDL provides a low-level joystick API, which just treats joysticks as an
 * arbitrary pile of buttons, axes, and hat switches. If you're planning to
 * write your own control configuration screen, this can give you a lot of
 * flexibility, but that's a lot of work, and most things that we consider
 * "joysticks" now are actually console-style gamepads. So SDL provides the
 * gamepad API on top of the lower-level joystick functionality.
 *
 * The difference betweena joystick and a gamepad is that a gamepad tells you
 * _where_ a button or axis is on the device. You don't speak to gamepads in
 * terms of arbitrary numbers like "button 3" or "axis 2" but in standard
 * locations: the d-pad, the shoulder buttons, triggers, A/B/X/Y (or
 * X/O/Square/Triangle, if you will).
 *
 * One turns a joystick into a gamepad by providing a magic configuration
 * string, which tells SDL the details of a specific device: when you see this
 * specific hardware, if button 2 gets pressed, this is actually D-Pad Up,
 * etc.
 *
 * SDL has many popular controllers configured out of the box, and users can
 * add their own controller details through an environment variable if it's
 * otherwise unknown to SDL.
 *
 * In order to use these functions, SDL_Init() must have been called with the
 * SDL_INIT_GAMEPAD flag. This causes SDL to scan the system for gamepads, and
 * load appropriate drivers.
 *
 * If you're using SDL gamepad support in a Steam game, you must call
 * SteamAPI_InitEx() before calling SDL_Init().
 *
 * If you would like to receive gamepad updates while the application is in
 * the background, you should set the following hint before calling
 * SDL_Init(): SDL_HINT_JOYSTICK_ALLOW_BACKGROUND_EVENTS
 *
 * Gamepads support various optional features such as rumble, color LEDs,
 * touchpad, gyro, etc. The support for these features varies depending on the
 * controller and OS support available. You can check for LED and rumble
 * capabilities at runtime by calling SDL_GetGamepadProperties() and checking
 * the various capability properties. You can check for touchpad by calling
 * SDL_GetNumGamepadTouchpads() and check for gyro and accelerometer by
 * calling SDL_GamepadHasSensor().
 *
 * By default SDL will try to use the most capable driver available, but you
 * can tune which OS drivers to use with the various joystick hints in
 * SDL_hints.h.
 *
 * Your application should always support gamepad hotplugging. On some
 * platforms like Xbox, Steam Deck, etc., this is a requirement for
 * certification. On other platforms, like macOS and Windows when using
 * Windows.Gaming.Input, controllers may not be available at startup and will
 * come in at some point after you've started processing events.
  }

{*
 * The structure used to identify an SDL gamepad
 *
 * \since This struct is available since SDL 3.2.0.
  }
type
  PPSDL_Gamepad = ^PSDL_Gamepad;
  PSDL_Gamepad = type Pointer;

{*
 * Standard gamepad types.
 *
 * This type does not necessarily map to first-party controllers from
 * Microsoft/Sony/Nintendo; in many cases, third-party controllers can report
 * as these, either because they were designed for a specific console, or they
 * simply most closely match that console's controllers (does it have A/B/X/Y
 * buttons or X/O/Square/Triangle? Does it have a touchpad? etc).
  }
type
  PPSDL_GamepadType = ^PSDL_GamepadType;
  PSDL_GamepadType = ^TSDL_GamepadType;
  TSDL_GamepadType = type Integer;
const
  SDL_GAMEPAD_TYPE_UNKNOWN  = TSDL_GamepadType(0);
  SDL_GAMEPAD_TYPE_STANDARD  = TSDL_GamepadType(1);
  SDL_GAMEPAD_TYPE_XBOX360  = TSDL_GamepadType(2);
  SDL_GAMEPAD_TYPE_XBOXONE  = TSDL_GamepadType(3);
  SDL_GAMEPAD_TYPE_PS3  = TSDL_GamepadType(4);
  SDL_GAMEPAD_TYPE_PS4  = TSDL_GamepadType(5);
  SDL_GAMEPAD_TYPE_PS5  = TSDL_GamepadType(6);
  SDL_GAMEPAD_TYPE_NINTENDO_SWITCH_PRO  = TSDL_GamepadType(7);
  SDL_GAMEPAD_TYPE_NINTENDO_SWITCH_JOYCON_LEFT  = TSDL_GamepadType(8);
  SDL_GAMEPAD_TYPE_NINTENDO_SWITCH_JOYCON_RIGHT  = TSDL_GamepadType(9);
  SDL_GAMEPAD_TYPE_NINTENDO_SWITCH_JOYCON_PAIR  = TSDL_GamepadType(10);
  SDL_GAMEPAD_TYPE_GAMECUBE = TSDL_GamepadType(11);
  SDL_GAMEPAD_TYPE_COUNT  = TSDL_GamepadType(12);

{*
 * The list of buttons available on a gamepad
 *
 * For controllers that use a diamond pattern for the face buttons, the
 * south/east/west/north buttons below correspond to the locations in the
 * diamond pattern. For Xbox controllers, this would be A/B/X/Y, for Nintendo
 * Switch controllers, this would be B/A/Y/X, for GameCube controllers this
 * would be A/X/B/Y, for PlayStation controllers this would be
 * Cross/Circle/Square/Triangle.
 *
 * For controllers that don't use a diamond pattern for the face buttons, the
 * south/east/west/north buttons indicate the buttons labeled A, B, C, D, or
 * 1, 2, 3, 4, or for controllers that aren't labeled, they are the primary,
 * secondary, etc. buttons.
 *
 * The activate action is often the south button and the cancel action is
 * often the east button, but in some regions this is reversed, so your game
 * should allow remapping actions based on user preferences.
 *
 * You can query the labels for the face buttons using
 * SDL_GetGamepadButtonLabel()
 *
 * \since This enum is available since SDL 3.2.0.
  }
type
  PPSDL_GamepadButton = ^PSDL_GamepadButton;
  PSDL_GamepadButton = ^TSDL_GamepadButton;
  TSDL_GamepadButton = type Integer;
const
  SDL_GAMEPAD_BUTTON_INVALID = TSDL_GamepadButton(-1);
  SDL_GAMEPAD_BUTTON_SOUTH  = TSDL_GamepadButton(0);    {*< Bottom face button (e.g. Xbox A button)  }
  SDL_GAMEPAD_BUTTON_EAST  = TSDL_GamepadButton(1);     {*< Right face button (e.g. Xbox B button)  }
  SDL_GAMEPAD_BUTTON_WEST  = TSDL_GamepadButton(2);     {*< Left face button (e.g. Xbox X button)  }
  SDL_GAMEPAD_BUTTON_NORTH  = TSDL_GamepadButton(3);    {*< Top face button (e.g. Xbox Y button)  }
  SDL_GAMEPAD_BUTTON_BACK  = TSDL_GamepadButton(4);
  SDL_GAMEPAD_BUTTON_GUIDE  = TSDL_GamepadButton(5);
  SDL_GAMEPAD_BUTTON_START  = TSDL_GamepadButton(6);
  SDL_GAMEPAD_BUTTON_LEFT_STICK  = TSDL_GamepadButton(7);
  SDL_GAMEPAD_BUTTON_RIGHT_STICK  = TSDL_GamepadButton(8);
  SDL_GAMEPAD_BUTTON_LEFT_SHOULDER  = TSDL_GamepadButton(9);
  SDL_GAMEPAD_BUTTON_RIGHT_SHOULDER  = TSDL_GamepadButton(10);
  SDL_GAMEPAD_BUTTON_DPAD_UP  = TSDL_GamepadButton(11);
  SDL_GAMEPAD_BUTTON_DPAD_DOWN  = TSDL_GamepadButton(12);
  SDL_GAMEPAD_BUTTON_DPAD_LEFT  = TSDL_GamepadButton(13);
  SDL_GAMEPAD_BUTTON_DPAD_RIGHT  = TSDL_GamepadButton(14);
  SDL_GAMEPAD_BUTTON_MISC1  = TSDL_GamepadButton(15);           {*< Additional button (e.g. Xbox Series X share button, PS5 microphone button, Nintendo Switch Pro capture button, Amazon Luna microphone button, Google Stadia capture button)  }
  SDL_GAMEPAD_BUTTON_RIGHT_PADDLE1  = TSDL_GamepadButton(16);   {*< Upper or primary paddle, under your right hand (e.g. Xbox Elite paddle P1, DualSense Edge RB button, Right Joy-Con SR button)  }
  SDL_GAMEPAD_BUTTON_LEFT_PADDLE1  = TSDL_GamepadButton(17);    {*< Upper or primary paddle, under your left hand (e.g. Xbox Elite paddle P3, DualSense Edge LB button, Left Joy-Con SL button)  }
  SDL_GAMEPAD_BUTTON_RIGHT_PADDLE2  = TSDL_GamepadButton(18);   {*< Lower or secondary paddle, under your right hand (e.g. Xbox Elite paddle P2, DualSense Edge right Fn button, Right Joy-Con SL button)  }
  SDL_GAMEPAD_BUTTON_LEFT_PADDLE2  = TSDL_GamepadButton(19);    {*< Lower or secondary paddle, under your left hand (e.g. Xbox Elite paddle P4, DualSense Edge left Fn button, Left Joy-Con SR button)  }
  SDL_GAMEPAD_BUTTON_TOUCHPAD  = TSDL_GamepadButton(20);        {*< PS4/PS5 touchpad button  }
  SDL_GAMEPAD_BUTTON_MISC2  = TSDL_GamepadButton(21);           {*< Additional button  }
  SDL_GAMEPAD_BUTTON_MISC3  = TSDL_GamepadButton(22);           {*< Additional button (e.g. Nintendo GameCube left trigger click)  }
  SDL_GAMEPAD_BUTTON_MISC4  = TSDL_GamepadButton(23);           {*< Additional button (e.g. Nintendo GameCube right trigger click)  }
  SDL_GAMEPAD_BUTTON_MISC5  = TSDL_GamepadButton(24);           {*< Additional button  }
  SDL_GAMEPAD_BUTTON_MISC6  = TSDL_GamepadButton(25);           {*< Additional button  }
  SDL_GAMEPAD_BUTTON_COUNT  = TSDL_GamepadButton(26);

{*
 * The set of gamepad button labels
 *
 * This isn't a complete set, just the face buttons to make it easy to show
 * button prompts.
 *
 * For a complete set, you should look at the button and gamepad type and have
 * a set of symbols that work well with your art style.
 *
 * \since This enum is available since SDL 3.2.0.
  }
type
  PPSDL_GamepadButtonLabel = ^PSDL_GamepadButtonLabel;
  PSDL_GamepadButtonLabel = ^TSDL_GamepadButtonLabel;
  TSDL_GamepadButtonLabel = type Integer;
const
  SDL_GAMEPAD_BUTTON_LABEL_UNKNOWN  = TSDL_GamepadButtonLabel(0);
  SDL_GAMEPAD_BUTTON_LABEL_A  = TSDL_GamepadButtonLabel(1);
  SDL_GAMEPAD_BUTTON_LABEL_B  = TSDL_GamepadButtonLabel(2);
  SDL_GAMEPAD_BUTTON_LABEL_X  = TSDL_GamepadButtonLabel(3);
  SDL_GAMEPAD_BUTTON_LABEL_Y  = TSDL_GamepadButtonLabel(4);
  SDL_GAMEPAD_BUTTON_LABEL_CROSS  = TSDL_GamepadButtonLabel(5);
  SDL_GAMEPAD_BUTTON_LABEL_CIRCLE  = TSDL_GamepadButtonLabel(6);
  SDL_GAMEPAD_BUTTON_LABEL_SQUARE  = TSDL_GamepadButtonLabel(7);
  SDL_GAMEPAD_BUTTON_LABEL_TRIANGLE  = TSDL_GamepadButtonLabel(8);

{*
 * The list of axes available on a gamepad
 *
 * Thumbstick axis values range from SDL_JOYSTICK_AXIS_MIN to
 * SDL_JOYSTICK_AXIS_MAX, and are centered within ~8000 of zero, though
 * advanced UI will allow users to set or autodetect the dead zone, which
 * varies between gamepads.
 *
 * Trigger axis values range from 0 (released) to SDL_JOYSTICK_AXIS_MAX (fully
 * pressed) when reported by SDL_GetGamepadAxis(). Note that this is not the
 * same range that will be reported by the lower-level SDL_GetJoystickAxis().
 *
 * \since This enum is available since SDL 3.2.0.
  }
type
  PSDL_GamepadAxis = ^TSDL_GamepadAxis;
  TSDL_GamepadAxis =  Longint;
Const
  SDL_GAMEPAD_AXIS_INVALID = TSDL_GamepadAxis(-1);
  SDL_GAMEPAD_AXIS_LEFTX  = TSDL_GamepadAxis(0);
  SDL_GAMEPAD_AXIS_LEFTY  = TSDL_GamepadAxis(1);
  SDL_GAMEPAD_AXIS_RIGHTX  = TSDL_GamepadAxis(2);
  SDL_GAMEPAD_AXIS_RIGHTY  = TSDL_GamepadAxis(3);
  SDL_GAMEPAD_AXIS_LEFT_TRIGGER  = TSDL_GamepadAxis(4);
  SDL_GAMEPAD_AXIS_RIGHT_TRIGGER  = TSDL_GamepadAxis(5);
  SDL_GAMEPAD_AXIS_COUNT  = TSDL_GamepadAxis(6);

{*
 * Types of gamepad control bindings.
 *
 * A gamepad is a collection of bindings that map arbitrary joystick buttons,
 * axes and hat switches to specific positions on a generic console-style
 * gamepad. This enum is used as part of SDL_GamepadBinding to specify those
 * mappings.
 *
 * \since This enum is available since SDL 3.2.0.
  }
type
  PSDL_GamepadBindingType = ^TSDL_GamepadBindingType;
  TSDL_GamepadBindingType =  Longint;
Const
  SDL_GAMEPAD_BINDTYPE_NONE  = TSDL_GamepadBindingType(0);
  SDL_GAMEPAD_BINDTYPE_BUTTON  = TSDL_GamepadBindingType(1);
  SDL_GAMEPAD_BINDTYPE_AXIS  = TSDL_GamepadBindingType(2);
  SDL_GAMEPAD_BINDTYPE_HAT  = TSDL_GamepadBindingType(3);

{*
 * A mapping between one joystick input to a gamepad control.
 *
 * A gamepad has a collection of several bindings, to say, for example, when
 * joystick button number 5 is pressed, that should be treated like the
 * gamepad's "start" button.
 *
 * SDL has these bindings built-in for many popular controllers, and can add
 * more with a simple text string. Those strings are parsed into a collection
 * of these structs to make it easier to operate on the data.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_GetGamepadBindings
  }
type
  PPSDL_GamepadBinding = ^PSDL_GamepadBinding;
  PSDL_GamepadBinding = ^TSDL_GamepadBinding;
  TSDL_GamepadBinding = record
    input_type : TSDL_GamepadBindingType;
    input : record
        case longint of
          0 : ( button : cint );
          1 : ( axis : record
              axis : cint;
              axis_min : cint;
              axis_max : cint;
            end );
          2 : ( hat : record
              hat : cint;
              hat_mask : cint;
            end );
        end;
    output_type : TSDL_GamepadBindingType;
    output : record
        case longint of
          0 : ( button : TSDL_GamepadButton );
          1 : ( axis : record
              axis : TSDL_GamepadAxis;
              axis_min : cint;
              axis_max : cint;
            end );
        end;
  end;

{*
 * Add support for gamepads that SDL is unaware of or change the binding of an
 * existing gamepad.
 *
 * The mapping string has the format "GUID,name,mapping", where GUID is the
 * string value from SDL_GUIDToString(), name is the human readable string for
 * the device and mappings are gamepad mappings to joystick ones. Under
 * Windows there is a reserved GUID of "xinput" that covers all XInput
 * devices. The mapping format for joystick is:
 *
 * - `bX`: a joystick button, index X
 * - `hX.Y`: hat X with value Y
 * - `aX`: axis X of the joystick
 *
 * Buttons can be used as a gamepad axes and vice versa.
 *
 * If a device with this GUID is already plugged in, SDL will generate an
 * SDL_EVENT_GAMEPAD_ADDED event.
 *
 * This string shows an example of a valid mapping for a gamepad:
 *
 * ```c
 * "341a3608000000000000504944564944,Afterglow PS3 Controller,a: b1,b: b2,y: b3,x: b0,start: b9,guide: b12,back: b8,dpup: h0.1,dpleft: h0.8,dpdown: h0.4,dpright: h0.2,leftshoulder: b4,rightshoulder: b5,leftstick: b10,rightstick: b11,leftx: a0,lefty: a1,rightx: a2,righty: a3,lefttrigger: b6,righttrigger: b7"
 * ```
 *
 * \param mapping the mapping string.
 * \returns 1 if a new mapping is added, 0 if an existing mapping is updated,
 *          -1 on failure; call SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_AddGamepadMappingsFromFile
 * \sa SDL_AddGamepadMappingsFromIO
 * \sa SDL_GetGamepadMapping
 * \sa SDL_GetGamepadMappingForGUID
 * \sa SDL_HINT_GAMECONTROLLERCONFIG
 * \sa SDL_HINT_GAMECONTROLLERCONFIG_FILE
 * \sa SDL_EVENT_GAMEPAD_ADDED
  }
function SDL_AddGamepadMapping(mapping: PAnsiChar): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_AddGamepadMapping' {$ENDIF} {$ENDIF};

{*
 * Load a set of gamepad mappings from an SDL_IOStream.
 *
 * You can call this function several times, if needed, to load different
 * database files.
 *
 * If a new mapping is loaded for an already known gamepad GUID, the later
 * version will overwrite the one currently loaded.
 *
 * Any new mappings for already plugged in controllers will generate
 * SDL_EVENT_GAMEPAD_ADDED events.
 *
 * Mappings not belonging to the current platform or with no platform field
 * specified will be ignored (i.e. mappings for Linux will be ignored in
 * Windows, etc).
 *
 * This function will load the text database entirely in memory before
 * processing it, so take this into consideration if you are in a memory
 * constrained environment.
 *
 * \param src the data stream for the mappings to be added.
 * \param closeio if true, calls SDL_CloseIO() on `src` before returning, even
 *                in the case of an error.
 * \returns the number of mappings added or -1 on failure; call SDL_GetError()
 *          for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_AddGamepadMapping
 * \sa SDL_AddGamepadMappingsFromFile
 * \sa SDL_GetGamepadMapping
 * \sa SDL_GetGamepadMappingForGUID
 * \sa SDL_HINT_GAMECONTROLLERCONFIG
 * \sa SDL_HINT_GAMECONTROLLERCONFIG_FILE
 * \sa SDL_EVENT_GAMEPAD_ADDED
  }
function SDL_AddGamepadMappingsFromIO(src: PSDL_IOStream; closeio: Boolean): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_AddGamepadMappingsFromIO' {$ENDIF} {$ENDIF};

{*
 * Load a set of gamepad mappings from a file.
 *
 * You can call this function several times, if needed, to load different
 * database files.
 *
 * If a new mapping is loaded for an already known gamepad GUID, the later
 * version will overwrite the one currently loaded.
 *
 * Any new mappings for already plugged in controllers will generate
 * SDL_EVENT_GAMEPAD_ADDED events.
 *
 * Mappings not belonging to the current platform or with no platform field
 * specified will be ignored (i.e. mappings for Linux will be ignored in
 * Windows, etc).
 *
 * \param file the mappings file to load.
 * \returns the number of mappings added or -1 on failure; call SDL_GetError()
 *          for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_AddGamepadMapping
 * \sa SDL_AddGamepadMappingsFromIO
 * \sa SDL_GetGamepadMapping
 * \sa SDL_GetGamepadMappingForGUID
 * \sa SDL_HINT_GAMECONTROLLERCONFIG
 * \sa SDL_HINT_GAMECONTROLLERCONFIG_FILE
 * \sa SDL_EVENT_GAMEPAD_ADDED
  }
function SDL_AddGamepadMappingsFromFile(file_: PAnsiChar): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_AddGamepadMappingsFromFile' {$ENDIF} {$ENDIF};

{*
 * Reinitialize the SDL mapping database to its initial state.
 *
 * This will generate gamepad events as needed if device mappings change.
 *
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_ReloadGamepadMappings: Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ReloadGamepadMappings' {$ENDIF} {$ENDIF};

{*
 * Get the current gamepad mappings.
 *
 * \param count a Pointer filled in with the number of mappings returned, can
 *              be nil.
 * \returns an array of the mapping strings, nil-terminated, or nil on
 *          failure; call SDL_GetError() for more information. This is a
 *          single allocation that should be freed with SDL_free() when it is
 *          no longer needed.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetGamepadMappings(count: pcint):PPAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepadMappings' {$ENDIF} {$ENDIF};

{*
 * Get the gamepad mapping string for a given GUID.
 *
 * \param guid a structure containing the GUID for which a mapping is desired.
 * \returns a mapping string or nil on failure; call SDL_GetError() for more
 *          information. This should be freed with SDL_free() when it is no
 *          longer needed.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetJoystickGUIDForID
 * \sa SDL_GetJoystickGUID
  }
function SDL_GetGamepadMappingForGUID(guid: TSDL_GUID): PAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepadMappingForGUID' {$ENDIF} {$ENDIF};

{*
 * Get the current mapping of a gamepad.
 *
 * Details about mappings are discussed with SDL_AddGamepadMapping().
 *
 * \param gamepad the gamepad you want to get the current mapping for.
 * \returns a string that has the gamepad's mapping or nil if no mapping is
 *          available; call SDL_GetError() for more information. This should
 *          be freed with SDL_free() when it is no longer needed.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_AddGamepadMapping
 * \sa SDL_GetGamepadMappingForID
 * \sa SDL_GetGamepadMappingForGUID
 * \sa SDL_SetGamepadMapping
  }
function SDL_GetGamepadMapping(gamepad: PSDL_Gamepad): PAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepadMapping' {$ENDIF} {$ENDIF};

{*
 * Set the current mapping of a joystick or gamepad.
 *
 * Details about mappings are discussed with SDL_AddGamepadMapping().
 *
 * \param instance_id the joystick instance ID.
 * \param mapping the mapping to use for this device, or nil to clear the
 *                mapping.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_AddGamepadMapping
 * \sa SDL_GetGamepadMapping
  }
function SDL_SetGamepadMapping(instance_id: TSDL_JoystickID; mapping: PAnsiChar): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetGamepadMapping' {$ENDIF} {$ENDIF};

{*
 * Return whether a gamepad is currently connected.
 *
 * \returns true if a gamepad is connected, false otherwise.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetGamepads
  }
function SDL_HasGamepad: Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_HasGamepad' {$ENDIF} {$ENDIF};

{*
 * Get a list of currently connected gamepads.
 *
 * \param count a Pointer filled in with the number of gamepads returned, may
 *              be nil.
 * \returns a 0 terminated array of joystick instance IDs or nil on failure;
 *          call SDL_GetError() for more information. This should be freed
 *          with SDL_free() when it is no longer needed.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_HasGamepad
 * \sa SDL_OpenGamepad
  }
function SDL_GetGamepads(count: pcint): PSDL_JoystickID; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepads' {$ENDIF} {$ENDIF};

{*
 * Check if the given joystick is supported by the gamepad interface.
 *
 * \param instance_id the joystick instance ID.
 * \returns true if the given joystick is supported by the gamepad interface,
 *          false if it isn't or it's an invalid index.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetJoysticks
 * \sa SDL_OpenGamepad
  }
function SDL_IsGamepad(instance_id: TSDL_JoystickID): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_IsGamepad' {$ENDIF} {$ENDIF};

{*
 * Get the implementation dependent name of a gamepad.
 *
 * This can be called before any gamepads are opened.
 *
 * \param instance_id the joystick instance ID.
 * \returns the name of the selected gamepad. If no name can be found, this
 *          function returns nil; call SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetGamepadName
 * \sa SDL_GetGamepads
  }
function SDL_GetGamepadNameForID(instance_id: TSDL_JoystickID): PAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepadNameForID' {$ENDIF} {$ENDIF};

{*
 * Get the implementation dependent path of a gamepad.
 *
 * This can be called before any gamepads are opened.
 *
 * \param instance_id the joystick instance ID.
 * \returns the path of the selected gamepad. If no path can be found, this
 *          function returns nil; call SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetGamepadPath
 * \sa SDL_GetGamepads
  }
function SDL_GetGamepadPathForID(instance_id: TSDL_JoystickID): PAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepadPathForID' {$ENDIF} {$ENDIF};

{*
 * Get the player index of a gamepad.
 *
 * This can be called before any gamepads are opened.
 *
 * \param instance_id the joystick instance ID.
 * \returns the player index of a gamepad, or -1 if it's not available.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetGamepadPlayerIndex
 * \sa SDL_GetGamepads
  }
function SDL_GetGamepadPlayerIndexForID(instance_id: TSDL_JoystickID): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepadPlayerIndexForID' {$ENDIF} {$ENDIF};

{*
 * Get the implementation-dependent GUID of a gamepad.
 *
 * This can be called before any gamepads are opened.
 *
 * \param instance_id the joystick instance ID.
 * \returns the GUID of the selected gamepad. If called on an invalid index,
 *          this function returns a zero GUID.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GUIDToString
 * \sa SDL_GetGamepads
  }
function SDL_GetGamepadGUIDForID(instance_id: TSDL_JoystickID): TSDL_GUID; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepadGUIDForID' {$ENDIF} {$ENDIF};

{*
 * Get the USB vendor ID of a gamepad, if available.
 *
 * This can be called before any gamepads are opened. If the vendor ID isn't
 * available this function returns 0.
 *
 * \param instance_id the joystick instance ID.
 * \returns the USB vendor ID of the selected gamepad. If called on an invalid
 *          index, this function returns zero.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetGamepadVendor
 * \sa SDL_GetGamepads
  }
function SDL_GetGamepadVendorForID(instance_id: TSDL_JoystickID): cuint16; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepadVendorForID' {$ENDIF} {$ENDIF};

{*
 * Get the USB product ID of a gamepad, if available.
 *
 * This can be called before any gamepads are opened. If the product ID isn't
 * available this function returns 0.
 *
 * \param instance_id the joystick instance ID.
 * \returns the USB product ID of the selected gamepad. If called on an
 *          invalid index, this function returns zero.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetGamepadProduct
 * \sa SDL_GetGamepads
  }
function SDL_GetGamepadProductForID(instance_id: TSDL_JoystickID): cuint16; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepadProductForID' {$ENDIF} {$ENDIF};

{*
 * Get the product version of a gamepad, if available.
 *
 * This can be called before any gamepads are opened. If the product version
 * isn't available this function returns 0.
 *
 * \param instance_id the joystick instance ID.
 * \returns the product version of the selected gamepad. If called on an
 *          invalid index, this function returns zero.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetGamepadProductVersion
 * \sa SDL_GetGamepads
  }
function SDL_GetGamepadProductVersionForID(instance_id: TSDL_JoystickID): cuint16; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepadProductVersionForID' {$ENDIF} {$ENDIF};

{*
 * Get the type of a gamepad.
 *
 * This can be called before any gamepads are opened.
 *
 * \param instance_id the joystick instance ID.
 * \returns the gamepad type.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetGamepadType
 * \sa SDL_GetGamepads
 * \sa SDL_GetRealGamepadTypeForID
  }
function SDL_GetGamepadTypeForID(instance_id: TSDL_JoystickID): TSDL_GamepadType; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepadTypeForID' {$ENDIF} {$ENDIF};

{*
 * Get the type of a gamepad, ignoring any mapping override.
 *
 * This can be called before any gamepads are opened.
 *
 * \param instance_id the joystick instance ID.
 * \returns the gamepad type.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetGamepadTypeForID
 * \sa SDL_GetGamepads
 * \sa SDL_GetRealGamepadType
  }
function SDL_GetRealGamepadTypeForID(instance_id: TSDL_JoystickID): TSDL_GamepadType; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetRealGamepadTypeForID' {$ENDIF} {$ENDIF};

{*
 * Get the mapping of a gamepad.
 *
 * This can be called before any gamepads are opened.
 *
 * \param instance_id the joystick instance ID.
 * \returns the mapping string. Returns nil if no mapping is available. This
 *          should be freed with SDL_free() when it is no longer needed.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetGamepads
 * \sa SDL_GetGamepadMapping
  }
function SDL_GetGamepadMappingForID(instance_id: TSDL_JoystickID): PAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepadMappingForID' {$ENDIF} {$ENDIF};

{*
 * Open a gamepad for use.
 *
 * \param instance_id the joystick instance ID.
 * \returns a gamepad identifier or nil if an error occurred; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CloseGamepad
 * \sa SDL_IsGamepad
  }
function SDL_OpenGamepad(instance_id: TSDL_JoystickID): PSDL_Gamepad; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_OpenGamepad' {$ENDIF} {$ENDIF};

{*
 * Get the SDL_Gamepad associated with a joystick instance ID, if it has been
 * opened.
 *
 * \param instance_id the joystick instance ID of the gamepad.
 * \returns an SDL_Gamepad on success or nil on failure or if it hasn't been
 *          opened yet; call SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetGamepadFromID(instance_id: TSDL_JoystickID): PSDL_Gamepad; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepadFromID' {$ENDIF} {$ENDIF};

{*
 * Get the SDL_Gamepad associated with a player index.
 *
 * \param player_index the player index, which different from the instance ID.
 * \returns the SDL_Gamepad associated with a player index.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetGamepadPlayerIndex
 * \sa SDL_SetGamepadPlayerIndex
  }
function SDL_GetGamepadFromPlayerIndex(player_index: cint): PSDL_Gamepad; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepadFromPlayerIndex' {$ENDIF} {$ENDIF};

{*
 * Get the properties associated with an opened gamepad.
 *
 * These properties are shared with the underlying joystick object.
 *
 * The following read-only properties are provided by SDL:
 *
 * - `SDL_PROP_GAMEPAD_CAP_MONO_LED_BOOLEAN`: true if this gamepad has an LED
 *   that has adjustable brightness
 * - `SDL_PROP_GAMEPAD_CAP_RGB_LED_BOOLEAN`: true if this gamepad has an LED
 *   that has adjustable color
 * - `SDL_PROP_GAMEPAD_CAP_PLAYER_LED_BOOLEAN`: true if this gamepad has a
 *   player LED
 * - `SDL_PROP_GAMEPAD_CAP_RUMBLE_BOOLEAN`: true if this gamepad has
 *   left/right rumble
 * - `SDL_PROP_GAMEPAD_CAP_TRIGGER_RUMBLE_BOOLEAN`: true if this gamepad has
 *   simple trigger rumble
 *
 * \param gamepad a gamepad identifier previously returned by
 *                SDL_OpenGamepad().
 * \returns a valid property ID on success or 0 on failure; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetGamepadProperties(gamepad: PSDL_Gamepad): TSDL_PropertiesID; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepadProperties' {$ENDIF} {$ENDIF};

const
  SDL_PROP_GAMEPAD_CAP_MONO_LED_BOOLEAN = SDL_PROP_JOYSTICK_CAP_MONO_LED_BOOLEAN;
  SDL_PROP_GAMEPAD_CAP_RGB_LED_BOOLEAN = SDL_PROP_JOYSTICK_CAP_RGB_LED_BOOLEAN;
  SDL_PROP_GAMEPAD_CAP_PLAYER_LED_BOOLEAN = SDL_PROP_JOYSTICK_CAP_PLAYER_LED_BOOLEAN;
  SDL_PROP_GAMEPAD_CAP_RUMBLE_BOOLEAN = SDL_PROP_JOYSTICK_CAP_RUMBLE_BOOLEAN;
  SDL_PROP_GAMEPAD_CAP_TRIGGER_RUMBLE_BOOLEAN = SDL_PROP_JOYSTICK_CAP_TRIGGER_RUMBLE_BOOLEAN;

{*
 * Get the instance ID of an opened gamepad.
 *
 * \param gamepad a gamepad identifier previously returned by
 *                SDL_OpenGamepad().
 * \returns the instance ID of the specified gamepad on success or 0 on
 *          failure; call SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetGamepadID(gamepad: PSDL_Gamepad): TSDL_JoystickID; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepadID' {$ENDIF} {$ENDIF};

{*
 * Get the implementation-dependent name for an opened gamepad.
 *
 * \param gamepad a gamepad identifier previously returned by
 *                SDL_OpenGamepad().
 * \returns the implementation dependent name for the gamepad, or nil if
 *          there is no name or the identifier passed is invalid.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetGamepadNameForID
  }

function SDL_GetGamepadName(gamepad: PSDL_Gamepad): PAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepadName' {$ENDIF} {$ENDIF};

{*
 * Get the implementation-dependent path for an opened gamepad.
 *
 * \param gamepad a gamepad identifier previously returned by
 *                SDL_OpenGamepad().
 * \returns the implementation dependent path for the gamepad, or nil if
 *          there is no path or the identifier passed is invalid.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetGamepadPathForID
  }

function SDL_GetGamepadPath(gamepad: PSDL_Gamepad): PAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepadPath' {$ENDIF} {$ENDIF};

{*
 * Get the type of an opened gamepad.
 *
 * \param gamepad the gamepad object to query.
 * \returns the gamepad type, or SDL_GAMEPAD_TYPE_UNKNOWN if it's not
 *          available.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetGamepadTypeForID
  }
function SDL_GetGamepadType(gamepad: PSDL_Gamepad): TSDL_GamepadType; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepadType' {$ENDIF} {$ENDIF};

{*
 * Get the type of an opened gamepad, ignoring any mapping override.
 *
 * \param gamepad the gamepad object to query.
 * \returns the gamepad type, or SDL_GAMEPAD_TYPE_UNKNOWN if it's not
 *          available.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetRealGamepadTypeForID
  }
function SDL_GetRealGamepadType(gamepad: PSDL_Gamepad): TSDL_GamepadType; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetRealGamepadType' {$ENDIF} {$ENDIF};

{*
 * Get the player index of an opened gamepad.
 *
 * For XInput gamepads this returns the XInput user index.
 *
 * \param gamepad the gamepad object to query.
 * \returns the player index for gamepad, or -1 if it's not available.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetGamepadPlayerIndex
  }
function SDL_GetGamepadPlayerIndex(gamepad: PSDL_Gamepad): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepadPlayerIndex' {$ENDIF} {$ENDIF};

{*
 * Set the player index of an opened gamepad.
 *
 * \param gamepad the gamepad object to adjust.
 * \param player_index player index to assign to this gamepad, or -1 to clear
 *                     the player index and turn off player LEDs.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetGamepadPlayerIndex
  }
function SDL_SetGamepadPlayerIndex(gamepad: PSDL_Gamepad; player_index: cint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetGamepadPlayerIndex' {$ENDIF} {$ENDIF};

{*
 * Get the USB vendor ID of an opened gamepad, if available.
 *
 * If the vendor ID isn't available this function returns 0.
 *
 * \param gamepad the gamepad object to query.
 * \returns the USB vendor ID, or zero if unavailable.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetGamepadVendorForID
  }
function SDL_GetGamepadVendor(gamepad: PSDL_Gamepad): cuint16; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepadVendor' {$ENDIF} {$ENDIF};

{*
 * Get the USB product ID of an opened gamepad, if available.
 *
 * If the product ID isn't available this function returns 0.
 *
 * \param gamepad the gamepad object to query.
 * \returns the USB product ID, or zero if unavailable.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetGamepadProductForID
  }
function SDL_GetGamepadProduct(gamepad: PSDL_Gamepad): cuint16; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepadProduct' {$ENDIF} {$ENDIF};

{*
 * Get the product version of an opened gamepad, if available.
 *
 * If the product version isn't available this function returns 0.
 *
 * \param gamepad the gamepad object to query.
 * \returns the USB product version, or zero if unavailable.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetGamepadProductVersionForID
  }
function SDL_GetGamepadProductVersion(gamepad: PSDL_Gamepad): cuint16; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepadProductVersion' {$ENDIF} {$ENDIF};

{*
 * Get the firmware version of an opened gamepad, if available.
 *
 * If the firmware version isn't available this function returns 0.
 *
 * \param gamepad the gamepad object to query.
 * \returns the gamepad firmware version, or zero if unavailable.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetGamepadFirmwareVersion(gamepad: PSDL_Gamepad): cuint16; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepadFirmwareVersion' {$ENDIF} {$ENDIF};

{*
 * Get the serial number of an opened gamepad, if available.
 *
 * Returns the serial number of the gamepad, or nil if it is not available.
 *
 * \param gamepad the gamepad object to query.
 * \returns the serial number, or nil if unavailable.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetGamepadSerial(gamepad: PSDL_Gamepad): PAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepadSerial' {$ENDIF} {$ENDIF};

{*
 * Get the Steam Input handle of an opened gamepad, if available.
 *
 * Returns an InputHandle_t for the gamepad that can be used with Steam Input
 * API: https://partner.steamgames.com/doc/api/ISteamInput
 *
 * \param gamepad the gamepad object to query.
 * \returns the gamepad handle, or 0 if unavailable.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetGamepadSteamHandle(gamepad: PSDL_Gamepad): cuint64; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepadSteamHandle' {$ENDIF} {$ENDIF};

{*
 * Get the connection state of a gamepad.
 *
 * \param gamepad the gamepad object to query.
 * \returns the connection state on success or
 *          `SDL_JOYSTICK_CONNECTION_INVALID` on failure; call SDL_GetError()
 *          for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetGamepadConnectionState(gamepad: PSDL_Gamepad): TSDL_JoystickConnectionState; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepadConnectionState' {$ENDIF} {$ENDIF};

{*
 * Get the battery state of a gamepad.
 *
 * You should never take a battery status as absolute truth. Batteries
 * (especially failing batteries) are delicate hardware, and the values
 * reported here are best estimates based on what that hardware reports. It's
 * not uncommon for older batteries to lose stored power much faster than it
 * reports, or completely drain when reporting it has 20 percent left, etc.
 *
 * \param gamepad the gamepad object to query.
 * \param percent a Pointer filled in with the percentage of battery life
 *                left, between 0 and 100, or nil to ignore. This will be
 *                filled in with -1 we can't determine a value or there is no
 *                battery.
 * \returns the current battery state.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetGamepadPowerInfo(gamepad: PSDL_Gamepad; percent: pcint): TSDL_PowerState; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepadPowerInfo' {$ENDIF} {$ENDIF};

{*
 * Check if a gamepad has been opened and is currently connected.
 *
 * \param gamepad a gamepad identifier previously returned by
 *                SDL_OpenGamepad().
 * \returns true if the gamepad has been opened and is currently connected, or
 *          false if not.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GamepadConnected(gamepad: PSDL_Gamepad): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GamepadConnected' {$ENDIF} {$ENDIF};

{*
 * Get the underlying joystick from a gamepad.
 *
 * This function will give you a SDL_Joystick object, which allows you to use
 * the SDL_Joystick functions with a SDL_Gamepad object. This would be useful
 * for getting a joystick's position at any given time, even if it hasn't
 * moved (moving it would produce an event, which would have the axis' value).
 *
 * The Pointer returned is owned by the SDL_Gamepad. You should not call
 * SDL_CloseJoystick() on it, for example, since doing so will likely cause
 * SDL to crash.
 *
 * \param gamepad the gamepad object that you want to get a joystick from.
 * \returns an SDL_Joystick object, or nil on failure; call SDL_GetError()
 *          for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetGamepadJoystick(gamepad: PSDL_Gamepad): PSDL_Joystick; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepadJoystick' {$ENDIF} {$ENDIF};

{*
 * Set the state of gamepad event processing.
 *
 * If gamepad events are disabled, you must call SDL_UpdateGamepads() yourself
 * and check the state of the gamepad when you want gamepad information.
 *
 * \param enabled whether to process gamepad events or not.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GamepadEventsEnabled
 * \sa SDL_UpdateGamepads
  }
procedure SDL_SetGamepadEventsEnabled(enabled: Boolean); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetGamepadEventsEnabled' {$ENDIF} {$ENDIF};

{*
 * Query the state of gamepad event processing.
 *
 * If gamepad events are disabled, you must call SDL_UpdateGamepads() yourself
 * and check the state of the gamepad when you want gamepad information.
 *
 * \returns true if gamepad events are being processed, false otherwise.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetGamepadEventsEnabled
  }
function SDL_GamepadEventsEnabled: Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GamepadEventsEnabled' {$ENDIF} {$ENDIF};

{*
 * Get the SDL joystick layer bindings for a gamepad.
 *
 * \param gamepad a gamepad.
 * \param count a Pointer filled in with the number of bindings returned.
 * \returns a nil terminated array of pointers to bindings or nil on
 *          failure; call SDL_GetError() for more information. This is a
 *          single allocation that should be freed with SDL_free() when it is
 *          no longer needed.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetGamepadBindings(gamepad: PSDL_Gamepad; count: pcint):PPSDL_GamepadBinding; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepadBindings' {$ENDIF} {$ENDIF};

{*
 * Manually pump gamepad updates if not using the loop.
 *
 * This function is called automatically by the event loop if events are
 * enabled. Under such circumstances, it will not be necessary to call this
 * function.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
procedure SDL_UpdateGamepads; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_UpdateGamepads' {$ENDIF} {$ENDIF};

{*
 * Convert a string into SDL_GamepadType enum.
 *
 * This function is called internally to translate SDL_Gamepad mapping strings
 * for the underlying joystick device into the consistent SDL_Gamepad mapping.
 * You do not normally need to call this function unless you are parsing
 * SDL_Gamepad mappings in your own code.
 *
 * \param str string representing a SDL_GamepadType type.
 * \returns the SDL_GamepadType enum corresponding to the input string, or
 *          `SDL_GAMEPAD_TYPE_UNKNOWN` if no match was found.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetGamepadStringForType
  }
function SDL_GetGamepadTypeFromString(str: PAnsiChar): TSDL_GamepadType; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepadTypeFromString' {$ENDIF} {$ENDIF};

{*
 * Convert from an SDL_GamepadType enum to a string.
 *
 * \param type an enum value for a given SDL_GamepadType.
 * \returns a string for the given type, or nil if an invalid type is
 *          specified. The string returned is of the format used by
 *          SDL_Gamepad mapping strings.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetGamepadTypeFromString
  }
function SDL_GetGamepadStringForType(type_: TSDL_GamepadType): PAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepadStringForType' {$ENDIF} {$ENDIF};

{*
 * Convert a string into SDL_GamepadAxis enum.
 *
 * This function is called internally to translate SDL_Gamepad mapping strings
 * for the underlying joystick device into the consistent SDL_Gamepad mapping.
 * You do not normally need to call this function unless you are parsing
 * SDL_Gamepad mappings in your own code.
 *
 * Note specially that "righttrigger" and "lefttrigger" map to
 * `SDL_GAMEPAD_AXIS_RIGHT_TRIGGER` and `SDL_GAMEPAD_AXIS_LEFT_TRIGGER`,
 * respectively.
 *
 * \param str string representing a SDL_Gamepad axis.
 * \returns the SDL_GamepadAxis enum corresponding to the input string, or
 *          `SDL_GAMEPAD_AXIS_INVALID` if no match was found.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetGamepadStringForAxis
  }
function SDL_GetGamepadAxisFromString(str: PAnsiChar): TSDL_GamepadAxis; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepadAxisFromString' {$ENDIF} {$ENDIF};

{*
 * Convert from an SDL_GamepadAxis enum to a string.
 *
 * \param axis an enum value for a given SDL_GamepadAxis.
 * \returns a string for the given axis, or nil if an invalid axis is
 *          specified. The string returned is of the format used by
 *          SDL_Gamepad mapping strings.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetGamepadAxisFromString
  }
function SDL_GetGamepadStringForAxis(axis: TSDL_GamepadAxis): PAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepadStringForAxis' {$ENDIF} {$ENDIF};

{*
 * Query whether a gamepad has a given axis.
 *
 * This merely reports whether the gamepad's mapping defined this axis, as
 * that is all the information SDL has about the physical device.
 *
 * \param gamepad a gamepad.
 * \param axis an axis enum value (an SDL_GamepadAxis value).
 * \returns true if the gamepad has this axis, false otherwise.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GamepadHasButton
 * \sa SDL_GetGamepadAxis
  }
function SDL_GamepadHasAxis(gamepad: PSDL_Gamepad; axis: TSDL_GamepadAxis): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GamepadHasAxis' {$ENDIF} {$ENDIF};

{*
 * Get the current state of an axis control on a gamepad.
 *
 * The axis indices start at index 0.
 *
 * For thumbsticks, the state is a value ranging from -32768 (up/left) to
 * 32767 (down/right).
 *
 * Triggers range from 0 when released to 32767 when fully pressed, and never
 * return a negative value. Note that this differs from the value reported by
 * the lower-level SDL_GetJoystickAxis(), which normally uses the full range.
 *
 * Note that for invalid gamepads or axes, this will return 0. Zero is also a
 * valid value in normal operation; usually it means a centered axis.
 *
 * \param gamepad a gamepad.
 * \param axis an axis index (one of the SDL_GamepadAxis values).
 * \returns axis state.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GamepadHasAxis
 * \sa SDL_GetGamepadButton
  }
function SDL_GetGamepadAxis(gamepad: PSDL_Gamepad; axis: TSDL_GamepadAxis): cint16; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepadAxis' {$ENDIF} {$ENDIF};

{*
 * Convert a string into an SDL_GamepadButton enum.
 *
 * This function is called internally to translate SDL_Gamepad mapping strings
 * for the underlying joystick device into the consistent SDL_Gamepad mapping.
 * You do not normally need to call this function unless you are parsing
 * SDL_Gamepad mappings in your own code.
 *
 * \param str string representing a SDL_Gamepad button.
 * \returns the SDL_GamepadButton enum corresponding to the input string, or
 *          `SDL_GAMEPAD_BUTTON_INVALID` if no match was found.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetGamepadStringForButton
  }
function SDL_GetGamepadButtonFromString(str: PAnsiChar): TSDL_GamepadButton; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepadButtonFromString' {$ENDIF} {$ENDIF};

{*
 * Convert from an SDL_GamepadButton enum to a string.
 *
 * \param button an enum value for a given SDL_GamepadButton.
 * \returns a string for the given button, or nil if an invalid button is
 *          specified. The string returned is of the format used by
 *          SDL_Gamepad mapping strings.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetGamepadButtonFromString
  }
function SDL_GetGamepadStringForButton(button: TSDL_GamepadButton): PAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepadStringForButton' {$ENDIF} {$ENDIF};

{*
 * Query whether a gamepad has a given button.
 *
 * This merely reports whether the gamepad's mapping defined this button, as
 * that is all the information SDL has about the physical device.
 *
 * \param gamepad a gamepad.
 * \param button a button enum value (an SDL_GamepadButton value).
 * \returns true if the gamepad has this button, false otherwise.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GamepadHasAxis
  }
function SDL_GamepadHasButton(gamepad: PSDL_Gamepad; button: TSDL_GamepadButton): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GamepadHasButton' {$ENDIF} {$ENDIF};

{*
 * Get the current state of a button on a gamepad.
 *
 * \param gamepad a gamepad.
 * \param button a button index (one of the SDL_GamepadButton values).
 * \returns true if the button is pressed, false otherwise.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GamepadHasButton
 * \sa SDL_GetGamepadAxis
  }
function SDL_GetGamepadButton(gamepad: PSDL_Gamepad; button: TSDL_GamepadButton): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepadButton' {$ENDIF} {$ENDIF};

{*
 * Get the label of a button on a gamepad.
 *
 * \param type the type of gamepad to check.
 * \param button a button index (one of the SDL_GamepadButton values).
 * \returns the SDL_GamepadButtonLabel enum corresponding to the button label.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetGamepadButtonLabel
  }
function SDL_GetGamepadButtonLabelForType(type_: TSDL_GamepadType; button: TSDL_GamepadButton): TSDL_GamepadButtonLabel; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepadButtonLabelForType' {$ENDIF} {$ENDIF};

{*
 * Get the label of a button on a gamepad.
 *
 * \param gamepad a gamepad.
 * \param button a button index (one of the SDL_GamepadButton values).
 * \returns the SDL_GamepadButtonLabel enum corresponding to the button label.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetGamepadButtonLabelForType
  }
function SDL_GetGamepadButtonLabel(gamepad: PSDL_Gamepad; button: TSDL_GamepadButton): TSDL_GamepadButtonLabel; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepadButtonLabel' {$ENDIF} {$ENDIF};

{*
 * Get the number of touchpads on a gamepad.
 *
 * \param gamepad a gamepad.
 * \returns number of touchpads.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetNumGamepadTouchpadFingers
  }
function SDL_GetNumGamepadTouchpads(gamepad: PSDL_Gamepad): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetNumGamepadTouchpads' {$ENDIF} {$ENDIF};

{*
 * Get the number of supported simultaneous fingers on a touchpad on a game
 * gamepad.
 *
 * \param gamepad a gamepad.
 * \param touchpad a touchpad.
 * \returns number of supported simultaneous fingers.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetGamepadTouchpadFinger
 * \sa SDL_GetNumGamepadTouchpads
  }
function SDL_GetNumGamepadTouchpadFingers(gamepad: PSDL_Gamepad; touchpad: cint): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetNumGamepadTouchpadFingers' {$ENDIF} {$ENDIF};

{*
 * Get the current state of a finger on a touchpad on a gamepad.
 *
 * \param gamepad a gamepad.
 * \param touchpad a touchpad.
 * \param finger a finger.
 * \param down a Pointer filled with true if the finger is down, false
 *             otherwise, may be nil.
 * \param x a Pointer filled with the x position, normalized 0 to 1, with the
 *          origin in the upper left, may be nil.
 * \param y a Pointer filled with the y position, normalized 0 to 1, with the
 *          origin in the upper left, may be nil.
 * \param pressure a Pointer filled with pressure value, may be nil.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetNumGamepadTouchpadFingers
  }
function SDL_GetGamepadTouchpadFinger(gamepad: PSDL_Gamepad; touchpad: cint; finger: cint; down: pBoolean; x: pcfloat; y: pcfloat; pressure: pcfloat): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepadTouchpadFinger' {$ENDIF} {$ENDIF};

{*
 * Return whether a gamepad has a particular sensor.
 *
 * \param gamepad the gamepad to query.
 * \param type the type of sensor to query.
 * \returns true if the sensor exists, false otherwise.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetGamepadSensorData
 * \sa SDL_GetGamepadSensorDataRate
 * \sa SDL_SetGamepadSensorEnabled
  }
function SDL_GamepadHasSensor(gamepad: PSDL_Gamepad; type_: TSDL_SensorType): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GamepadHasSensor' {$ENDIF} {$ENDIF};

{*
 * Set whether data reporting for a gamepad sensor is enabled.
 *
 * \param gamepad the gamepad to update.
 * \param type the type of sensor to enable/disable.
 * \param enabled whether data reporting should be enabled.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GamepadHasSensor
 * \sa SDL_GamepadSensorEnabled
  }
function SDL_SetGamepadSensorEnabled(gamepad: PSDL_Gamepad; type_: TSDL_SensorType; enabled: Boolean): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetGamepadSensorEnabled' {$ENDIF} {$ENDIF};

{*
 * Query whether sensor data reporting is enabled for a gamepad.
 *
 * \param gamepad the gamepad to query.
 * \param type the type of sensor to query.
 * \returns true if the sensor is enabled, false otherwise.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetGamepadSensorEnabled
  }
function SDL_GamepadSensorEnabled(gamepad: PSDL_Gamepad; type_: TSDL_SensorType): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GamepadSensorEnabled' {$ENDIF} {$ENDIF};

{*
 * Get the data rate (number of events per second) of a gamepad sensor.
 *
 * \param gamepad the gamepad to query.
 * \param type the type of sensor to query.
 * \returns the data rate, or 0.0f if the data rate is not available.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetGamepadSensorDataRate(gamepad: PSDL_Gamepad; type_: TSDL_SensorType): cfloat; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepadSensorDataRate' {$ENDIF} {$ENDIF};

{*
 * Get the current state of a gamepad sensor.
 *
 * The number of values and interpretation of the data is sensor dependent.
 * See the remarks in SDL_SensorType for details for each type of sensor.
 *
 * \param gamepad the gamepad to query.
 * \param type the type of sensor to query.
 * \param data a Pointer filled with the current sensor state.
 * \param num_values the number of values to write to data.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetGamepadSensorData(gamepad: PSDL_Gamepad; type_: TSDL_SensorType; data: pcfloat; num_values: cint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepadSensorData' {$ENDIF} {$ENDIF};

{*
 * Start a rumble effect on a gamepad.
 *
 * Each call to this function cancels any previous rumble effect, and calling
 * it with 0 intensity stops any rumbling.
 *
 * This function requires you to process SDL events or call
 * SDL_UpdateJoysticks() to update rumble state.
 *
 * \param gamepad the gamepad to vibrate.
 * \param low_frequency_rumble the intensity of the low frequency (left)
 *                             rumble motor, from 0 to 0xFFFF.
 * \param high_frequency_rumble the intensity of the high frequency (right)
 *                              rumble motor, from 0 to 0xFFFF.
 * \param duration_ms the duration of the rumble effect, in milliseconds.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_RumbleGamepad(gamepad: PSDL_Gamepad; low_frequency_rumble: cuint16; high_frequency_rumble: cuint16; duration_ms: cuint32): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_RumbleGamepad' {$ENDIF} {$ENDIF};

{*
 * Start a rumble effect in the gamepad's triggers.
 *
 * Each call to this function cancels any previous trigger rumble effect, and
 * calling it with 0 intensity stops any rumbling.
 *
 * Note that this is rumbling of the _triggers_ and not the gamepad as a
 * whole. This is currently only supported on Xbox One gamepads. If you want
 * the (more common) whole-gamepad rumble, use SDL_RumbleGamepad() instead.
 *
 * This function requires you to process SDL events or call
 * SDL_UpdateJoysticks() to update rumble state.
 *
 * \param gamepad the gamepad to vibrate.
 * \param left_rumble the intensity of the left trigger rumble motor, from 0
 *                    to 0xFFFF.
 * \param right_rumble the intensity of the right trigger rumble motor, from 0
 *                     to 0xFFFF.
 * \param duration_ms the duration of the rumble effect, in milliseconds.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_RumbleGamepad
  }
function SDL_RumbleGamepadTriggers(gamepad: PSDL_Gamepad; left_rumble: cuint16; right_rumble: cuint16; duration_ms: cuint32): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_RumbleGamepadTriggers' {$ENDIF} {$ENDIF};

{*
 * Update a gamepad's LED color.
 *
 * An example of a joystick LED is the light on the back of a PlayStation 4's
 * DualShock 4 controller.
 *
 * For gamepads with a single color LED, the maximum of the RGB values will be
 * used as the LED brightness.
 *
 * \param gamepad the gamepad to update.
 * \param red the intensity of the red LED.
 * \param green the intensity of the green LED.
 * \param blue the intensity of the blue LED.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_SetGamepadLED(gamepad: PSDL_Gamepad; red: cuint8; green: cuint8; blue: cuint8): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetGamepadLED' {$ENDIF} {$ENDIF};

{*
 * Send a gamepad specific effect packet.
 *
 * \param gamepad the gamepad to affect.
 * \param data the data to send to the gamepad.
 * \param size the size of the data to send to the gamepad.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_SendGamepadEffect(gamepad: PSDL_Gamepad; data: Pointer; size: cint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SendGamepadEffect' {$ENDIF} {$ENDIF};

{*
 * Close a gamepad previously opened with SDL_OpenGamepad().
 *
 * \param gamepad a gamepad identifier previously returned by
 *                SDL_OpenGamepad().
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_OpenGamepad
  }
procedure SDL_CloseGamepad(gamepad: PSDL_Gamepad); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CloseGamepad' {$ENDIF} {$ENDIF};

{*
 * Return the sfSymbolsName for a given button on a gamepad on Apple
 * platforms.
 *
 * \param gamepad the gamepad to query.
 * \param button a button on the gamepad.
 * \returns the sfSymbolsName or nil if the name can't be found.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetGamepadAppleSFSymbolsNameForAxis
  }
function SDL_GetGamepadAppleSFSymbolsNameForButton(gamepad: PSDL_Gamepad; button: TSDL_GamepadButton): PAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepadAppleSFSymbolsNameForButton' {$ENDIF} {$ENDIF};

{*
 * Return the sfSymbolsName for a given axis on a gamepad on Apple platforms.
 *
 * \param gamepad the gamepad to query.
 * \param axis an axis on the gamepad.
 * \returns the sfSymbolsName or nil if the name can't be found.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetGamepadAppleSFSymbolsNameForButton
  }

function SDL_GetGamepadAppleSFSymbolsNameForAxis(gamepad: PSDL_Gamepad; axis: TSDL_GamepadAxis): PAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetGamepadAppleSFSymbolsNameForAxis' {$ENDIF} {$ENDIF};
