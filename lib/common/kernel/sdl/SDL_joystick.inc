{
  This file is part of:

    SDL3 for Pascal
    (https://github.com/PascalGameDevelopment/SDL3-for-Pascal)
    SPDX-License-Identifier: Zlib
}

{*
  * # CategoryJoystick
  *
  * SDL joystick support.
  *
  * This is the lower-level joystick handling. If you want the simpler option,
  * where what each button does is well-defined, you should use the gamepad API
  * instead.
  *
  * The term "instance_id" is the current instantiation of a joystick device in
  * the system. If the joystick is removed and then re-inserted then it will
  * get a new instance_id. instance_id's are monotonically increasing
  * identifiers of a joystick plugged in.
  *
  * The term "player_index" is the number assigned to a player on a specific
  * controller. For XInput controllers this returns the XInput user index. Many
  * joysticks will not be able to supply this information.
  *
  * SDL_GUID is used as a stable 128-bit identifier for a joystick device that
  * does not change over time. It identifies class of the device (a X360 wired
  * controller for example). This identifier is platform dependent.
  *
  * In order to use these functions, SDL_Init() must have been called with the
  * SDL_INIT_JOYSTICK flag. This causes SDL to scan the system for joysticks,
  * and load appropriate drivers.
  *
  * If you would like to receive joystick updates while the application is in
  * the background, you should set the following hint before calling
  * SDL_Init(): SDL_HINT_JOYSTICK_ALLOW_BACKGROUND_EVENTS
  *
  * SDL can provide virtual joysticks as well: the app defines an imaginary
  * controller with SDL_AttachVirtualJoystick(), and then can provide inputs
  * for it via SDL_SetJoystickVirtualAxis(), SDL_SetJoystickVirtualButton(),
  * etc. As this data is supplied, it will look like a normal joystick to SDL,
  * just not backed by a hardware driver. This has been used to make unusual
  * devices, like VR headset controllers, look like normal joysticks, or
  * provide recording/playback of game inputs, etc.
  }

{*
 * The joystick structure used to identify an SDL joystick.
 *
 * This is opaque data.
 *
 * \since This struct is available since SDL 3.2.0.
  }
type
  PPSDL_Joystick = ^PSDL_Joystick;
  PSDL_Joystick = type Pointer;

{*
 * This is a unique ID for a joystick for the time it is connected to the
 * system, and is never reused for the lifetime of the application.
 *
 * If the joystick is disconnected and reconnected, it will get a new ID.
 *
 * The value 0 is an invalid ID.
 *
 * \since This datatype is available since SDL 3.2.0.
  }
type
  PPSDL_JoystickID = ^PSDL_JoystickID;
  PSDL_JoystickID = ^TSDL_JoystickID;
  TSDL_JoystickID = cuint32;

{*
 * An enum of some common joystick types.
 *
 * In some cases, SDL can identify a low-level joystick as being a certain
 * type of device, and will report it through SDL_GetJoystickType (or
 * SDL_GetJoystickTypeForID).
 *
 * This is by no means a complete list of everything that can be plugged into
 * a computer.
 *
 * You may refer to
 * [XInput Controller Types](https://learn.microsoft.com/en-us/windows/win32/xinput/xinput-and-controller-subtypes)
 * table for a general understanding of each joystick type.
 *
 * \since This enum is available since SDL 3.2.0.
  }
type
  PPSDL_JoystickType = ^PSDL_JoystickType;
  PSDL_JoystickType = ^TSDL_JoystickType;
  TSDL_JoystickType =  Integer;
const
  SDL_JOYSTICK_TYPE_UNKNOWN  = TSDL_JoystickType(0);
  SDL_JOYSTICK_TYPE_GAMEPAD  = TSDL_JoystickType(1);
  SDL_JOYSTICK_TYPE_WHEEL  = TSDL_JoystickType(2);
  SDL_JOYSTICK_TYPE_ARCADE_STICK  = TSDL_JoystickType(3);
  SDL_JOYSTICK_TYPE_FLIGHT_STICK  = TSDL_JoystickType(4);
  SDL_JOYSTICK_TYPE_DANCE_PAD  = TSDL_JoystickType(5);
  SDL_JOYSTICK_TYPE_GUITAR  = TSDL_JoystickType(6);
  SDL_JOYSTICK_TYPE_DRUM_KIT  = TSDL_JoystickType(7);
  SDL_JOYSTICK_TYPE_ARCADE_PAD  = TSDL_JoystickType(8);
  SDL_JOYSTICK_TYPE_THROTTLE  = TSDL_JoystickType(9);
  SDL_JOYSTICK_TYPE_COUNT  = TSDL_JoystickType(10);

{*
 * Possible connection states for a joystick device.
 *
 * This is used by SDL_GetJoystickConnectionState to report how a device is
 * connected to the system.
 *
 * \since This enum is available since SDL 3.2.0.
  }
type
  PPSDL_JoystickConnectionState = ^PSDL_JoystickConnectionState;
  PSDL_JoystickConnectionState = ^TSDL_JoystickConnectionState;
  TSDL_JoystickConnectionState =  Integer;
const
  SDL_JOYSTICK_CONNECTION_INVALID = TSDL_JoystickConnectionState(-1);
  SDL_JOYSTICK_CONNECTION_UNKNOWN  = TSDL_JoystickConnectionState(0);
  SDL_JOYSTICK_CONNECTION_WIRED  = TSDL_JoystickConnectionState(1);
  SDL_JOYSTICK_CONNECTION_WIRELESS  = TSDL_JoystickConnectionState(2);

{*
 * The largest value an SDL_Joystick's axis can report.
 *
 * \since This macro is available since SDL 3.2.0.
 *
 * \sa SDL_JOYSTICK_AXIS_MIN
  }
  SDL_JOYSTICK_AXIS_MAX = 32767;

{*
 * The smallest value an SDL_Joystick's axis can report.
 *
 * This is a negative number!
 *
 * \since This macro is available since SDL 3.2.0.
 *
 * \sa SDL_JOYSTICK_AXIS_MAX
  }
  SDL_JOYSTICK_AXIS_MIN = -32768;

{ Function prototypes  }

{*
 * Locking for atomic access to the joystick API.
 *
 * The SDL joystick functions are thread-safe, however you can lock the
 * joysticks while processing to guarantee that the joystick list won't change
 * and joystick and gamepad events will not be delivered.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
{ #todo : SDL3-for-Pascal: Translate }
{void SDL_LockJoysticks(void) SDL_ACQUIRE(SDL_joystick_lock);}

{*
 * Unlocking for atomic access to the joystick API.
 *
 * \threadsafety This should be called from the same thread that called
 *               SDL_LockJoysticks().
 *
 * \since This function is available since SDL 3.2.0.
  }
 { #todo : SDL3-for-Pascal: Translate}
{void SDL_UnlockJoysticks(void) SDL_RELEASE(SDL_joystick_lock);}

{*
 * Return whether a joystick is currently connected.
 *
 * \returns true if a joystick is connected, false otherwise.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetJoysticks
  }
function SDL_HasJoystick: Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_HasJoystick' {$ENDIF} {$ENDIF};

{*
 * Get a list of currently connected joysticks.
 *
 * \param count a Pointer filled in with the number of joysticks returned, may
 *              be nil.
 * \returns a 0 terminated array of joystick instance IDs or nil on failure;
 *          call SDL_GetError() for more information. This should be freed
 *          with SDL_free() when it is no longer needed.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_HasJoystick
 * \sa SDL_OpenJoystick
  }
function SDL_GetJoysticks(count: pcint): PSDL_JoystickID; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetJoysticks' {$ENDIF} {$ENDIF};

{*
 * Get the implementation dependent name of a joystick.
 *
 * This can be called before any joysticks are opened.
 *
 * \param instance_id the joystick instance ID.
 * \returns the name of the selected joystick. If no name can be found, this
 *          function returns nil; call SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetJoystickName
 * \sa SDL_GetJoysticks
  }
function SDL_GetJoystickNameForID(instance_id: TSDL_JoystickID): PAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetJoystickNameForID' {$ENDIF} {$ENDIF};

{*
 * Get the implementation dependent path of a joystick.
 *
 * This can be called before any joysticks are opened.
 *
 * \param instance_id the joystick instance ID.
 * \returns the path of the selected joystick. If no path can be found, this
 *          function returns nil; call SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetJoystickPath
 * \sa SDL_GetJoysticks
  }
function SDL_GetJoystickPathForID(instance_id: TSDL_JoystickID): PAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetJoystickPathForID' {$ENDIF} {$ENDIF};

{*
 * Get the player index of a joystick.
 *
 * This can be called before any joysticks are opened.
 *
 * \param instance_id the joystick instance ID.
 * \returns the player index of a joystick, or -1 if it's not available.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetJoystickPlayerIndex
 * \sa SDL_GetJoysticks
  }
function SDL_GetJoystickPlayerIndexForID(instance_id: TSDL_JoystickID): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetJoystickPlayerIndexForID' {$ENDIF} {$ENDIF};

{*
 * Get the implementation-dependent GUID of a joystick.
 *
 * This can be called before any joysticks are opened.
 *
 * \param instance_id the joystick instance ID.
 * \returns the GUID of the selected joystick. If called with an invalid
 *          instance_id, this function returns a zero GUID.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetJoystickGUID
 * \sa SDL_GUIDToString
  }
function SDL_GetJoystickGUIDForID(instance_id: TSDL_JoystickID): TSDL_GUID; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetJoystickGUIDForID' {$ENDIF} {$ENDIF};

{*
 * Get the USB vendor ID of a joystick, if available.
 *
 * This can be called before any joysticks are opened. If the vendor ID isn't
 * available this function returns 0.
 *
 * \param instance_id the joystick instance ID.
 * \returns the USB vendor ID of the selected joystick. If called with an
 *          invalid instance_id, this function returns 0.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetJoystickVendor
 * \sa SDL_GetJoysticks
  }
function SDL_GetJoystickVendorForID(instance_id: TSDL_JoystickID): cuint16; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetJoystickVendorForID' {$ENDIF} {$ENDIF};

{*
 * Get the USB product ID of a joystick, if available.
 *
 * This can be called before any joysticks are opened. If the product ID isn't
 * available this function returns 0.
 *
 * \param instance_id the joystick instance ID.
 * \returns the USB product ID of the selected joystick. If called with an
 *          invalid instance_id, this function returns 0.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetJoystickProduct
 * \sa SDL_GetJoysticks
  }
function SDL_GetJoystickProductForID(instance_id: TSDL_JoystickID): cuint16; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetJoystickProductForID' {$ENDIF} {$ENDIF};

{*
 * Get the product version of a joystick, if available.
 *
 * This can be called before any joysticks are opened. If the product version
 * isn't available this function returns 0.
 *
 * \param instance_id the joystick instance ID.
 * \returns the product version of the selected joystick. If called with an
 *          invalid instance_id, this function returns 0.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetJoystickProductVersion
 * \sa SDL_GetJoysticks
  }
function SDL_GetJoystickProductVersionForID(instance_id: TSDL_JoystickID): cuint16; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetJoystickProductVersionForID' {$ENDIF} {$ENDIF};

{*
 * Get the type of a joystick, if available.
 *
 * This can be called before any joysticks are opened.
 *
 * \param instance_id the joystick instance ID.
 * \returns the SDL_JoystickType of the selected joystick. If called with an
 *          invalid instance_id, this function returns
 *          `SDL_JOYSTICK_TYPE_UNKNOWN`.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetJoystickType
 * \sa SDL_GetJoysticks
  }
function SDL_GetJoystickTypeForID(instance_id: TSDL_JoystickID): TSDL_JoystickType; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetJoystickTypeForID' {$ENDIF} {$ENDIF};

{*
 * Open a joystick for use.
 *
 * The joystick subsystem must be initialized before a joystick can be opened
 * for use.
 *
 * \param instance_id the joystick instance ID.
 * \returns a joystick identifier or nil on failure; call SDL_GetError() for
 *          more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CloseJoystick
  }
function SDL_OpenJoystick(instance_id: TSDL_JoystickID): PSDL_Joystick; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_OpenJoystick' {$ENDIF} {$ENDIF};

{*
 * Get the SDL_Joystick associated with an instance ID, if it has been opened.
 *
 * \param instance_id the instance ID to get the SDL_Joystick for.
 * \returns an SDL_Joystick on success or nil on failure or if it hasn't been
 *          opened yet; call SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetJoystickFromID(instance_id: TSDL_JoystickID): PSDL_Joystick; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetJoystickFromID' {$ENDIF} {$ENDIF};

{*
 * Get the SDL_Joystick associated with a player index.
 *
 * \param player_index the player index to get the SDL_Joystick for.
 * \returns an SDL_Joystick on success or nil on failure; call SDL_GetError()
 *          for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetJoystickPlayerIndex
 * \sa SDL_SetJoystickPlayerIndex
  }
function SDL_GetJoystickFromPlayerIndex(player_index: cint): PSDL_Joystick; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetJoystickFromPlayerIndex' {$ENDIF} {$ENDIF};

{*
 * The structure that describes a virtual joystick touchpad.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_VirtualJoystickDesc
  }
type
  PPSDL_VirtualJoystickTouchpadDesc = ^PSDL_VirtualJoystickTouchpadDesc;
  PSDL_VirtualJoystickTouchpadDesc = ^TSDL_VirtualJoystickTouchpadDesc;
  TSDL_VirtualJoystickTouchpadDesc = record
      nfingers: cuint16;      {*< the number of simultaneous fingers on this touchpad  }
      padding: array[0..2] of cuint16;
    end;

{*
 * The structure that describes a virtual joystick sensor.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_VirtualJoystickDesc
  }
  PPSDL_VirtualJoystickSensorDesc = ^PSDL_VirtualJoystickSensorDesc;
  PSDL_VirtualJoystickSensorDesc = ^TSDL_VirtualJoystickSensorDesc;
  TSDL_VirtualJoystickSensorDesc = record
      type_: TSDL_SensorType;  {*< the type of this sensor  }
      rate: cfloat;            {*< the update frequency of this sensor, may be 0.0f  }
    end;

{*
 * The structure that describes a virtual joystick.
 *
 * This structure should be initialized using SDL_INIT_INTERFACE(). All
 * elements of this structure are optional.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_AttachVirtualJoystick
 * \sa SDL_INIT_INTERFACE
 * \sa SDL_VirtualJoystickSensorDesc
 * \sa SDL_VirtualJoystickTouchpadDesc
  }
type
  PPSDL_VirtualJoystickDesc = ^PSDL_VirtualJoystickDesc;
  PSDL_VirtualJoystickDesc = ^TSDL_VirtualJoystickDesc;
  TSDL_VirtualJoystickDesc = record
      version: cuint32;                 {*< the version of this interface  }
      type_: cuint16;                   {*< `SDL_JoystickType`  }
      padding: cuint16;                 {*< unused  }
      vendor_id: cuint16;               {*< the USB vendor ID of this joystick  }
      product_id: cuint16;              {*< the USB product ID of this joystick  }
      naxes: cuint16;                   {*< the number of axes on this joystick  }
      nbuttons: cuint16;                {*< the number of buttons on this joystick  }
      nballs: cuint16;                  {*< the number of balls on this joystick  }
      nhats: cuint16;                   {*< the number of hats on this joystick  }
      ntouchpads: cuint16;              {*< the number of touchpads on this joystick, requires `touchpads` to point at valid descriptions  }
      nsensors: cuint16;                {*< the number of sensors on this joystick, requires `sensors` to point at valid descriptions  }
      padding2: array[0..1] of cuint16; {*< unused  }
      button_mask: cuint32;             {*< A mask of which buttons are valid for this controller
                                                                     e.g. (1 << SDL_GAMEPAD_BUTTON_SOUTH)  }
      axis_mask: cuint32;               {*< A mask of which axes are valid for this controller
                                                                     e.g. (1 << SDL_GAMEPAD_AXIS_LEFTX)  }
      name: PAnsiChar;                  {*< the name of the joystick  }
      touchpads: PSDL_VirtualJoystickTouchpadDesc; {*< A Pointer to an array of touchpad descriptions, required if `ntouchpads` is > 0  }
      sensors: PSDL_VirtualJoystickSensorDesc;     {*< A Pointer to an array of sensor descriptions, required if `nsensors` is > 0  }
      { #todo : SDL3-for-Pascal: Should the following function defs. be cdecl or not? }
      userdata: Pointer;                                                        {*< User data Pointer passed to callbacks  }
      Update: procedure (userdata: Pointer); cdecl;                             {*< Called when the joystick state should be updated  }
      SetPlayerIndex: procedure (userdata: Pointer; player_index: cint); cdecl; {*< Called when the player index is set  }
      Rumble: function (userdata: Pointer; low_frequency_rumble: cuint16; high_frequency_rumble: cuint16): Boolean; cdecl; {*< Implements SDL_RumbleJoystick()  }
      RumbleTriggers: function (userdata: Pointer; left_rumble: cuint16; right_rumble: cuint16): Boolean; cdecl;           {*< Implements SDL_RumbleJoystickTriggers()  }
      SetLED: function (userdata: Pointer; red: cuint8; green: cuint8; blue: cuint8): Boolean; cdecl;                      {*< Implements SDL_SetJoystickLED()  }
      SendEffect: function (userdata: Pointer; data: Pointer; size: cint): Boolean; cdecl;                                 {*< Implements SDL_SendJoystickEffect()  }
      SetSensorsEnabled: function (userdata: Pointer; enabled: Boolean): Boolean; cdecl;                                   {*< Implements SDL_SetGamepadSensorEnabled()  }
      Cleanup: procedure (userdata: Pointer); cdecl;                                     {*< Cleans up the userdata when the joystick is detached  }
    end;

{ Check the size of SDL_VirtualJoystickDesc
 *
 * If this assert fails, either the compiler is padding to an unexpected size,
 * or the interface has been updated and this should be updated to match and
 * the code using this interface should be updated to handle the old version.
  }
{ #todo : SDL3-for-Pascal: Translate }
{SDL_COMPILE_TIME_ASSERT(SDL_VirtualJoystickDesc_SIZE,...}

{*
 * Attach a new virtual joystick.
 *
 * Apps can create virtual joysticks, that exist without hardware directly
 * backing them, and have program-supplied inputs. Once attached, a virtual
 * joystick looks like any other joystick that SDL can access. These can be
 * used to make other things look like joysticks, or provide pre-recorded
 * input, etc.
 *
 * Once attached, the app can send joystick inputs to the new virtual joystick
 * using SDL_SetJoystickVirtualAxis(), etc.
 *
 * When no longer needed, the virtual joystick can be removed by calling
 * SDL_DetachVirtualJoystick().
 *
 * \param desc joystick description, initialized using SDL_INIT_INTERFACE().
 * \returns the joystick instance ID, or 0 on failure; call SDL_GetError() for
 *          more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_DetachVirtualJoystick
 * \sa SDL_SetJoystickVirtualAxis
 * \sa SDL_SetJoystickVirtualButton
 * \sa SDL_SetJoystickVirtualBall
 * \sa SDL_SetJoystickVirtualHat
 * \sa SDL_SetJoystickVirtualTouchpad
 * \sa SDL_SetJoystickVirtualSensorData
  }
function SDL_AttachVirtualJoystick(desc: PSDL_VirtualJoystickDesc): TSDL_JoystickID; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_AttachVirtualJoystick' {$ENDIF} {$ENDIF};

{*
 * Detach a virtual joystick.
 *
 * \param instance_id the joystick instance ID, previously returned from
 *                    SDL_AttachVirtualJoystick().
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_AttachVirtualJoystick
  }
function SDL_DetachVirtualJoystick(instance_id: TSDL_JoystickID): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_DetachVirtualJoystick' {$ENDIF} {$ENDIF};

{*
 * Query whether or not a joystick is virtual.
 *
 * \param instance_id the joystick instance ID.
 * \returns true if the joystick is virtual, false otherwise.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_IsJoystickVirtual(instance_id: TSDL_JoystickID): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_IsJoystickVirtual' {$ENDIF} {$ENDIF};

{*
 * Set the state of an axis on an opened virtual joystick.
 *
 * Please note that values set here will not be applied until the next call to
 * SDL_UpdateJoysticks, which can either be called directly, or can be called
 * indirectly through various other SDL APIs, including, but not limited to
 * the following: SDL_PollEvent, SDL_PumpEvents, SDL_WaitEventTimeout,
 * SDL_WaitEvent.
 *
 * Note that when sending trigger axes, you should scale the value to the full
 * range of Sint16. For example, a trigger at rest would have the value of
 * `SDL_JOYSTICK_AXIS_MIN`.
 *
 * \param joystick the virtual joystick on which to set state.
 * \param axis the index of the axis on the virtual joystick to update.
 * \param value the new value for the specified axis.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetJoystickVirtualButton
 * \sa SDL_SetJoystickVirtualBall
 * \sa SDL_SetJoystickVirtualHat
 * \sa SDL_SetJoystickVirtualTouchpad
 * \sa SDL_SetJoystickVirtualSensorData
  }
function SDL_SetJoystickVirtualAxis(joystick: PSDL_Joystick; axis: cint; value: cint16): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetJoystickVirtualAxis' {$ENDIF} {$ENDIF};

{*
 * Generate ball motion on an opened virtual joystick.
 *
 * Please note that values set here will not be applied until the next call to
 * SDL_UpdateJoysticks, which can either be called directly, or can be called
 * indirectly through various other SDL APIs, including, but not limited to
 * the following: SDL_PollEvent, SDL_PumpEvents, SDL_WaitEventTimeout,
 * SDL_WaitEvent.
 *
 * \param joystick the virtual joystick on which to set state.
 * \param ball the index of the ball on the virtual joystick to update.
 * \param xrel the relative motion on the X axis.
 * \param yrel the relative motion on the Y axis.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetJoystickVirtualAxis
 * \sa SDL_SetJoystickVirtualButton
 * \sa SDL_SetJoystickVirtualHat
 * \sa SDL_SetJoystickVirtualTouchpad
 * \sa SDL_SetJoystickVirtualSensorData
  }
function SDL_SetJoystickVirtualBall(joystick: PSDL_Joystick; ball: cint; xrel: cint16; yrel: cint16): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetJoystickVirtualBall' {$ENDIF} {$ENDIF};

{*
 * Set the state of a button on an opened virtual joystick.
 *
 * Please note that values set here will not be applied until the next call to
 * SDL_UpdateJoysticks, which can either be called directly, or can be called
 * indirectly through various other SDL APIs, including, but not limited to
 * the following: SDL_PollEvent, SDL_PumpEvents, SDL_WaitEventTimeout,
 * SDL_WaitEvent.
 *
 * \param joystick the virtual joystick on which to set state.
 * \param button the index of the button on the virtual joystick to update.
 * \param down true if the button is pressed, false otherwise.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetJoystickVirtualAxis
 * \sa SDL_SetJoystickVirtualBall
 * \sa SDL_SetJoystickVirtualHat
 * \sa SDL_SetJoystickVirtualTouchpad
 * \sa SDL_SetJoystickVirtualSensorData
  }
function SDL_SetJoystickVirtualButton(joystick: PSDL_Joystick; button: cint; down: Boolean): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetJoystickVirtualButton' {$ENDIF} {$ENDIF};

{*
 * Set the state of a hat on an opened virtual joystick.
 *
 * Please note that values set here will not be applied until the next call to
 * SDL_UpdateJoysticks, which can either be called directly, or can be called
 * indirectly through various other SDL APIs, including, but not limited to
 * the following: SDL_PollEvent, SDL_PumpEvents, SDL_WaitEventTimeout,
 * SDL_WaitEvent.
 *
 * \param joystick the virtual joystick on which to set state.
 * \param hat the index of the hat on the virtual joystick to update.
 * \param value the new value for the specified hat.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetJoystickVirtualAxis
 * \sa SDL_SetJoystickVirtualButton
 * \sa SDL_SetJoystickVirtualBall
 * \sa SDL_SetJoystickVirtualTouchpad
 * \sa SDL_SetJoystickVirtualSensorData
  }
function SDL_SetJoystickVirtualHat(joystick: PSDL_Joystick; hat: cint; value: cuint8): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetJoystickVirtualHat' {$ENDIF} {$ENDIF};

{*
 * Set touchpad finger state on an opened virtual joystick.
 *
 * Please note that values set here will not be applied until the next call to
 * SDL_UpdateJoysticks, which can either be called directly, or can be called
 * indirectly through various other SDL APIs, including, but not limited to
 * the following: SDL_PollEvent, SDL_PumpEvents, SDL_WaitEventTimeout,
 * SDL_WaitEvent.
 *
 * \param joystick the virtual joystick on which to set state.
 * \param touchpad the index of the touchpad on the virtual joystick to
 *                 update.
 * \param finger the index of the finger on the touchpad to set.
 * \param down true if the finger is pressed, false if the finger is released.
 * \param x the x coordinate of the finger on the touchpad, normalized 0 to 1,
 *          with the origin in the upper left.
 * \param y the y coordinate of the finger on the touchpad, normalized 0 to 1,
 *          with the origin in the upper left.
 * \param pressure the pressure of the finger.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetJoystickVirtualAxis
 * \sa SDL_SetJoystickVirtualButton
 * \sa SDL_SetJoystickVirtualBall
 * \sa SDL_SetJoystickVirtualTouchpad
 * \sa SDL_SetJoystickVirtualSensorData
  }
function SDL_SetJoystickVirtualTouchpad(joystick: PSDL_Joystick; touchpad: cint; finger: cint; down: Boolean; x: cfloat;
           y: cfloat; pressure: cfloat): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetJoystickVirtualTouchpad' {$ENDIF} {$ENDIF};

{*
 * Send a sensor update for an opened virtual joystick.
 *
 * Please note that values set here will not be applied until the next call to
 * SDL_UpdateJoysticks, which can either be called directly, or can be called
 * indirectly through various other SDL APIs, including, but not limited to
 * the following: SDL_PollEvent, SDL_PumpEvents, SDL_WaitEventTimeout,
 * SDL_WaitEvent.
 *
 * \param joystick the virtual joystick on which to set state.
 * \param type the type of the sensor on the virtual joystick to update.
 * \param sensor_timestamp a 64-bit timestamp in nanoseconds associated with
 *                         the sensor reading.
 * \param data the data associated with the sensor reading.
 * \param num_values the number of values pointed to by `data`.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetJoystickVirtualAxis
 * \sa SDL_SetJoystickVirtualButton
 * \sa SDL_SetJoystickVirtualBall
 * \sa SDL_SetJoystickVirtualTouchpad
 * \sa SDL_SetJoystickVirtualSensorData
  }
function SDL_SendJoystickVirtualSensorData(joystick: PSDL_Joystick; type_: TSDL_SensorType; sensor_timestamp: cuint64; data: pcfloat; num_values: cint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SendJoystickVirtualSensorData' {$ENDIF} {$ENDIF};

{*
 * Get the properties associated with a joystick.
 *
 * The following read-only properties are provided by SDL:
 *
 * - `SDL_PROP_JOYSTICK_CAP_MONO_LED_BOOLEAN`: true if this joystick has an
 *   LED that has adjustable brightness
 * - `SDL_PROP_JOYSTICK_CAP_RGB_LED_BOOLEAN`: true if this joystick has an LED
 *   that has adjustable color
 * - `SDL_PROP_JOYSTICK_CAP_PLAYER_LED_BOOLEAN`: true if this joystick has a
 *   player LED
 * - `SDL_PROP_JOYSTICK_CAP_RUMBLE_BOOLEAN`: true if this joystick has
 *   left/right rumble
 * - `SDL_PROP_JOYSTICK_CAP_TRIGGER_RUMBLE_BOOLEAN`: true if this joystick has
 *   simple trigger rumble
 *
 * \param joystick the SDL_Joystick obtained from SDL_OpenJoystick().
 * \returns a valid property ID on success or 0 on failure; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetJoystickProperties(joystick: PSDL_Joystick): TSDL_PropertiesID; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetJoystickProperties' {$ENDIF} {$ENDIF};

const
  SDL_PROP_JOYSTICK_CAP_MONO_LED_BOOLEAN = 'SDL.joystick.cap.mono_led';
  SDL_PROP_JOYSTICK_CAP_RGB_LED_BOOLEAN = 'SDL.joystick.cap.rgb_led';
  SDL_PROP_JOYSTICK_CAP_PLAYER_LED_BOOLEAN = 'SDL.joystick.cap.player_led';
  SDL_PROP_JOYSTICK_CAP_RUMBLE_BOOLEAN = 'SDL.joystick.cap.rumble';
  SDL_PROP_JOYSTICK_CAP_TRIGGER_RUMBLE_BOOLEAN = 'SDL.joystick.cap.trigger_rumble';

{*
 * Get the implementation dependent name of a joystick.
 *
 * \param joystick the SDL_Joystick obtained from SDL_OpenJoystick().
 * \returns the name of the selected joystick. If no name can be found, this
 *          function returns nil; call SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetJoystickNameForID
  }
function SDL_GetJoystickName(joystick: PSDL_Joystick): PAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetJoystickName' {$ENDIF} {$ENDIF};

{*
 * Get the implementation dependent path of a joystick.
 *
 * \param joystick the SDL_Joystick obtained from SDL_OpenJoystick().
 * \returns the path of the selected joystick. If no path can be found, this
 *          function returns nil; call SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetJoystickPathForID
  }
function SDL_GetJoystickPath(joystick: PSDL_Joystick): PAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetJoystickPath' {$ENDIF} {$ENDIF};

{*
 * Get the player index of an opened joystick.
 *
 * For XInput controllers this returns the XInput user index. Many joysticks
 * will not be able to supply this information.
 *
 * \param joystick the SDL_Joystick obtained from SDL_OpenJoystick().
 * \returns the player index, or -1 if it's not available.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetJoystickPlayerIndex
  }
function SDL_GetJoystickPlayerIndex(joystick: PSDL_Joystick): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetJoystickPlayerIndex' {$ENDIF} {$ENDIF};

{*
 * Set the player index of an opened joystick.
 *
 * \param joystick the SDL_Joystick obtained from SDL_OpenJoystick().
 * \param player_index player index to assign to this joystick, or -1 to clear
 *                     the player index and turn off player LEDs.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetJoystickPlayerIndex
  }
function SDL_SetJoystickPlayerIndex(joystick: PSDL_Joystick; player_index: cint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetJoystickPlayerIndex' {$ENDIF} {$ENDIF};

{*
 * Get the implementation-dependent GUID for the joystick.
 *
 * This function requires an open joystick.
 *
 * \param joystick the SDL_Joystick obtained from SDL_OpenJoystick().
 * \returns the GUID of the given joystick. If called on an invalid index,
 *          this function returns a zero GUID; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetJoystickGUIDForID
 * \sa SDL_GUIDToString
  }
function SDL_GetJoystickGUID(joystick: PSDL_Joystick): TSDL_GUID; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetJoystickGUID' {$ENDIF} {$ENDIF};

{*
 * Get the USB vendor ID of an opened joystick, if available.
 *
 * If the vendor ID isn't available this function returns 0.
 *
 * \param joystick the SDL_Joystick obtained from SDL_OpenJoystick().
 * \returns the USB vendor ID of the selected joystick, or 0 if unavailable.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetJoystickVendorForID
  }
function SDL_GetJoystickVendor(joystick: PSDL_Joystick): cuint16; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetJoystickVendor' {$ENDIF} {$ENDIF};

{*
 * Get the USB product ID of an opened joystick, if available.
 *
 * If the product ID isn't available this function returns 0.
 *
 * \param joystick the SDL_Joystick obtained from SDL_OpenJoystick().
 * \returns the USB product ID of the selected joystick, or 0 if unavailable.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetJoystickProductForID
  }
function SDL_GetJoystickProduct(joystick: PSDL_Joystick): cuint16; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetJoystickProduct' {$ENDIF} {$ENDIF};

{*
 * Get the product version of an opened joystick, if available.
 *
 * If the product version isn't available this function returns 0.
 *
 * \param joystick the SDL_Joystick obtained from SDL_OpenJoystick().
 * \returns the product version of the selected joystick, or 0 if unavailable.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetJoystickProductVersionForID
  }
function SDL_GetJoystickProductVersion(joystick: PSDL_Joystick): cuint16; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetJoystickProductVersion' {$ENDIF} {$ENDIF};

{*
 * Get the firmware version of an opened joystick, if available.
 *
 * If the firmware version isn't available this function returns 0.
 *
 * \param joystick the SDL_Joystick obtained from SDL_OpenJoystick().
 * \returns the firmware version of the selected joystick, or 0 if
 *          unavailable.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetJoystickFirmwareVersion(joystick: PSDL_Joystick): cuint16; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetJoystickFirmwareVersion' {$ENDIF} {$ENDIF};

{*
 * Get the serial number of an opened joystick, if available.
 *
 * Returns the serial number of the joystick, or nil if it is not available.
 *
 * \param joystick the SDL_Joystick obtained from SDL_OpenJoystick().
 * \returns the serial number of the selected joystick, or nil if
 *          unavailable.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetJoystickSerial(joystick: PSDL_Joystick): PAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetJoystickSerial' {$ENDIF} {$ENDIF};

{*
 * Get the type of an opened joystick.
 *
 * \param joystick the SDL_Joystick obtained from SDL_OpenJoystick().
 * \returns the SDL_JoystickType of the selected joystick.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetJoystickTypeForID
  }
function SDL_GetJoystickType(joystick: PSDL_Joystick): TSDL_JoystickType; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetJoystickType' {$ENDIF} {$ENDIF};

{*
 * Get the device information encoded in a SDL_GUID structure.
 *
 * \param guid the SDL_GUID you wish to get info about.
 * \param vendor a Pointer filled in with the device VID, or 0 if not
 *               available.
 * \param product a Pointer filled in with the device PID, or 0 if not
 *                available.
 * \param version a Pointer filled in with the device version, or 0 if not
 *                available.
 * \param crc16 a Pointer filled in with a CRC used to distinguish different
 *              products with the same VID/PID, or 0 if not available.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetJoystickGUIDForID
  }
procedure SDL_GetJoystickGUIDInfo(guid: TSDL_GUID; vendor: pcuint16; product: pcuint16; version: pcuint16; crc16: pcuint16); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetJoystickGUIDInfo' {$ENDIF} {$ENDIF};

{*
 * Get the status of a specified joystick.
 *
 * \param joystick the joystick to query.
 * \returns true if the joystick has been opened, false if it has not; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_JoystickConnected(joystick: PSDL_Joystick): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_JoystickConnected' {$ENDIF} {$ENDIF};

{*
 * Get the instance ID of an opened joystick.
 *
 * \param joystick an SDL_Joystick structure containing joystick information.
 * \returns the instance ID of the specified joystick on success or 0 on
 *          failure; call SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetJoystickID(joystick: PSDL_Joystick): TSDL_JoystickID; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetJoystickID' {$ENDIF} {$ENDIF};

{*
 * Get the number of general axis controls on a joystick.
 *
 * Often, the directional pad on a game controller will either look like 4
 * separate buttons or a POV hat, and not axes, but all of this is up to the
 * device and platform.
 *
 * \param joystick an SDL_Joystick structure containing joystick information.
 * \returns the number of axis controls/number of axes on success or -1 on
 *          failure; call SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetJoystickAxis
 * \sa SDL_GetNumJoystickBalls
 * \sa SDL_GetNumJoystickButtons
 * \sa SDL_GetNumJoystickHats
  }
function SDL_GetNumJoystickAxes(joystick: PSDL_Joystick): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetNumJoystickAxes' {$ENDIF} {$ENDIF};

{*
 * Get the number of trackballs on a joystick.
 *
 * Joystick trackballs have only relative motion events associated with them
 * and their state cannot be polled.
 *
 * Most joysticks do not have trackballs.
 *
 * \param joystick an SDL_Joystick structure containing joystick information.
 * \returns the number of trackballs on success or -1 on failure; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetJoystickBall
 * \sa SDL_GetNumJoystickAxes
 * \sa SDL_GetNumJoystickButtons
 * \sa SDL_GetNumJoystickHats
  }
function SDL_GetNumJoystickBalls(joystick: PSDL_Joystick): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetNumJoystickBalls' {$ENDIF} {$ENDIF};

{*
 * Get the number of POV hats on a joystick.
 *
 * \param joystick an SDL_Joystick structure containing joystick information.
 * \returns the number of POV hats on success or -1 on failure; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetJoystickHat
 * \sa SDL_GetNumJoystickAxes
 * \sa SDL_GetNumJoystickBalls
 * \sa SDL_GetNumJoystickButtons
  }
function SDL_GetNumJoystickHats(joystick: PSDL_Joystick): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetNumJoystickHats' {$ENDIF} {$ENDIF};

{*
 * Get the number of buttons on a joystick.
 *
 * \param joystick an SDL_Joystick structure containing joystick information.
 * \returns the number of buttons on success or -1 on failure; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetJoystickButton
 * \sa SDL_GetNumJoystickAxes
 * \sa SDL_GetNumJoystickBalls
 * \sa SDL_GetNumJoystickHats
  }
function SDL_GetNumJoystickButtons(joystick: PSDL_Joystick): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetNumJoystickButtons' {$ENDIF} {$ENDIF};

{*
 * Set the state of joystick event processing.
 *
 * If joystick events are disabled, you must call SDL_UpdateJoysticks()
 * yourself and check the state of the joystick when you want joystick
 * information.
 *
 * \param enabled whether to process joystick events or not.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_JoystickEventsEnabled
 * \sa SDL_UpdateJoysticks
  }
procedure SDL_SetJoystickEventsEnabled(enabled: Boolean); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetJoystickEventsEnabled' {$ENDIF} {$ENDIF};

{*
 * Query the state of joystick event processing.
 *
 * If joystick events are disabled, you must call SDL_UpdateJoysticks()
 * yourself and check the state of the joystick when you want joystick
 * information.
 *
 * \returns true if joystick events are being processed, false otherwise.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetJoystickEventsEnabled
  }
function SDL_JoystickEventsEnabled: Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_JoystickEventsEnabled' {$ENDIF} {$ENDIF};

{*
 * Update the current state of the open joysticks.
 *
 * This is called automatically by the event loop if any joystick events are
 * enabled.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
procedure SDL_UpdateJoysticks; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_UpdateJoysticks' {$ENDIF} {$ENDIF};

{*
 * Get the current state of an axis control on a joystick.
 *
 * SDL makes no promises about what part of the joystick any given axis refers
 * to. Your game should have some sort of configuration UI to let users
 * specify what each axis should be bound to. Alternately, SDL's higher-level
 * Game Controller API makes a great effort to apply order to this lower-level
 * interface, so you know that a specific axis is the "left thumb stick," etc.
 *
 * The value returned by SDL_GetJoystickAxis() is a signed integer (-32768 to
 * 32767) representing the current position of the axis. It may be necessary
 * to impose certain tolerances on these values to account for jitter.
 *
 * \param joystick an SDL_Joystick structure containing joystick information.
 * \param axis the axis to query; the axis indices start at index 0.
 * \returns a 16-bit signed integer representing the current position of the
 *          axis or 0 on failure; call SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetNumJoystickAxes
  }
function SDL_GetJoystickAxis(joystick: PSDL_Joystick; axis: cint): cint16; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetJoystickAxis' {$ENDIF} {$ENDIF};

{*
 * Get the initial state of an axis control on a joystick.
 *
 * The state is a value ranging from -32768 to 32767.
 *
 * The axis indices start at index 0.
 *
 * \param joystick an SDL_Joystick structure containing joystick information.
 * \param axis the axis to query; the axis indices start at index 0.
 * \param state upon return, the initial value is supplied here.
 * \returns true if this axis has any initial value, or false if not.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetJoystickAxisInitialState(joystick: PSDL_Joystick; axis: cint; state: pcint16): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetJoystickAxisInitialState' {$ENDIF} {$ENDIF};

{*
 * Get the ball axis change since the last poll.
 *
 * Trackballs can only return relative motion since the last call to
 * SDL_GetJoystickBall(), these motion deltas are placed into `dx` and `dy`.
 *
 * Most joysticks do not have trackballs.
 *
 * \param joystick the SDL_Joystick to query.
 * \param ball the ball index to query; ball indices start at index 0.
 * \param dx stores the difference in the x axis position since the last poll.
 * \param dy stores the difference in the y axis position since the last poll.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetNumJoystickBalls
  }
function SDL_GetJoystickBall(joystick: PSDL_Joystick; ball: cint; dx: pcint; dy: pcint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetJoystickBall' {$ENDIF} {$ENDIF};

{*
 * Get the current state of a POV hat on a joystick.
 *
 * The returned value will be one of the `SDL_HAT_*` values.
 *
 * \param joystick an SDL_Joystick structure containing joystick information.
 * \param hat the hat index to get the state from; indices start at index 0.
 * \returns the current hat position.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetNumJoystickHats
  }
function SDL_GetJoystickHat(joystick: PSDL_Joystick; hat: cint): cuint8; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetJoystickHat' {$ENDIF} {$ENDIF};

const
  SDL_HAT_CENTERED = $00;
  SDL_HAT_UP = $01;
  SDL_HAT_RIGHT = $02;
  SDL_HAT_DOWN = $04;
  SDL_HAT_LEFT = $08;
  SDL_HAT_RIGHTUP = SDL_HAT_RIGHT or SDL_HAT_UP;
  SDL_HAT_RIGHTDOWN = SDL_HAT_RIGHT or SDL_HAT_DOWN;
  SDL_HAT_LEFTUP = SDL_HAT_LEFT or SDL_HAT_UP;
  SDL_HAT_LEFTDOWN = SDL_HAT_LEFT or SDL_HAT_DOWN;

{*
 * Get the current state of a button on a joystick.
 *
 * \param joystick an SDL_Joystick structure containing joystick information.
 * \param button the button index to get the state from; indices start at
 *               index 0.
 * \returns true if the button is pressed, false otherwise.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetNumJoystickButtons
  }
function SDL_GetJoystickButton(joystick: PSDL_Joystick; button: cint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetJoystickButton' {$ENDIF} {$ENDIF};

{*
 * Start a rumble effect.
 *
 * Each call to this function cancels any previous rumble effect, and calling
 * it with 0 intensity stops any rumbling.
 *
 * This function requires you to process SDL events or call
 * SDL_UpdateJoysticks() to update rumble state.
 *
 * \param joystick the joystick to vibrate.
 * \param low_frequency_rumble the intensity of the low frequency (left)
 *                             rumble motor, from 0 to 0xFFFF.
 * \param high_frequency_rumble the intensity of the high frequency (right)
 *                              rumble motor, from 0 to 0xFFFF.
 * \param duration_ms the duration of the rumble effect, in milliseconds.
 * \returns true, or false if rumble isn't supported on this joystick.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_RumbleJoystick(joystick: PSDL_Joystick; low_frequency_rumble: cuint16; high_frequency_rumble: cuint16; duration_ms: cuint32): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_RumbleJoystick' {$ENDIF} {$ENDIF};

{*
 * Start a rumble effect in the joystick's triggers.
 *
 * Each call to this function cancels any previous trigger rumble effect, and
 * calling it with 0 intensity stops any rumbling.
 *
 * Note that this is rumbling of the _triggers_ and not the game controller as
 * a whole. This is currently only supported on Xbox One controllers. If you
 * want the (more common) whole-controller rumble, use SDL_RumbleJoystick()
 * instead.
 *
 * This function requires you to process SDL events or call
 * SDL_UpdateJoysticks() to update rumble state.
 *
 * \param joystick the joystick to vibrate.
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
 * \sa SDL_RumbleJoystick
  }
function SDL_RumbleJoystickTriggers(joystick: PSDL_Joystick; left_rumble: cuint16; right_rumble: cuint16; duration_ms: cuint32): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_RumbleJoystickTriggers' {$ENDIF} {$ENDIF};

{*
 * Update a joystick's LED color.
 *
 * An example of a joystick LED is the light on the back of a PlayStation 4's
 * DualShock 4 controller.
 *
 * For joysticks with a single color LED, the maximum of the RGB values will
 * be used as the LED brightness.
 *
 * \param joystick the joystick to update.
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
function SDL_SetJoystickLED(joystick: PSDL_Joystick; red: cuint8; green: cuint8; blue: cuint8): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetJoystickLED' {$ENDIF} {$ENDIF};

{*
 * Send a joystick specific effect packet.
 *
 * \param joystick the joystick to affect.
 * \param data the data to send to the joystick.
 * \param size the size of the data to send to the joystick.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_SendJoystickEffect(joystick: PSDL_Joystick; data: Pointer; size: cint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SendJoystickEffect' {$ENDIF} {$ENDIF};

{*
 * Close a joystick previously opened with SDL_OpenJoystick().
 *
 * \param joystick the joystick device to close.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_OpenJoystick
  }
procedure SDL_CloseJoystick(joystick: PSDL_Joystick); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CloseJoystick' {$ENDIF} {$ENDIF};

{*
 * Get the connection state of a joystick.
 *
 * \param joystick the joystick to query.
 * \returns the connection state on success or
 *          `SDL_JOYSTICK_CONNECTION_INVALID` on failure; call SDL_GetError()
 *          for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetJoystickConnectionState(joystick: PSDL_Joystick): TSDL_JoystickConnectionState; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetJoystickConnectionState' {$ENDIF} {$ENDIF};

{*
 * Get the battery state of a joystick.
 *
 * You should never take a battery status as absolute truth. Batteries
 * (especially failing batteries) are delicate hardware, and the values
 * reported here are best estimates based on what that hardware reports. It's
 * not uncommon for older batteries to lose stored power much faster than it
 * reports, or completely drain when reporting it has 20 percent left, etc.
 *
 * \param joystick the joystick to query.
 * \param percent a Pointer filled in with the percentage of battery life
 *                left, between 0 and 100, or nil to ignore. This will be
 *                filled in with -1 we can't determine a value or there is no
 *                battery.
 * \returns the current battery state or `SDL_POWERSTATE_ERROR` on failure;
 *          call SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetJoystickPowerInfo(joystick: PSDL_Joystick; percent: pcint): TSDL_PowerState; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetJoystickPowerInfo' {$ENDIF} {$ENDIF};

