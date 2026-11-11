{
  This file is part of:

    SDL3 for Pascal
    (https://github.com/PascalGameDevelopment/SDL3-for-Pascal)
    SPDX-License-Identifier: Zlib
}

{*
 * # CategoryEvents
 *
 * Event queue management.
 *
 * It's extremely common--often required--that an app deal with SDL's event
 * queue. Almost all useful information about interactions with the real world
 * flow through here: the user interacting with the computer and app, hardware
 * coming and going, the system changing in some way, etc.
 *
 * An app generally takes a moment, perhaps at the start of a new frame, to
 * examine any events that have occurred since the last time and process or
 * ignore them. This is generally done by calling SDL_PollEvent() in a loop
 * until it returns false (or, if using the main callbacks, events are
 * provided one at a time in calls to SDL_AppEvent() before the next call to
 * SDL_AppIterate(); in this scenario, the app does not call SDL_PollEvent()
 * at all).
 *
 * There is other forms of control, too: SDL_PeepEvents() has more
 * functionality at the cost of more complexity, and SDL_WaitEvent() can block
 * the process until something interesting happens, which might be beneficial
 * for certain types of programs on low-power hardware. One may also call
 * SDL_AddEventWatch() to set a callback when new events arrive.
 *
 * The app is free to generate their own events, too: SDL_PushEvent allows the
 * app to put events onto the queue for later retrieval; SDL_RegisterEvents
 * can guarantee that these events have a type that isn't in use by other
 * parts of the system.
  }

{ General keyboard/mouse/pen state definitions  }

{*
 * The types of events that can be delivered.
 *
 * \since This enum is available since SDL 3.2.0.
  }
type
  PPSDL_EventType = ^PSDL_EventType;
  PSDL_EventType = ^TSDL_EventType;
  TSDL_EventType =  type Integer;
const
  SDL_EVENT_FIRST = 0;                                                {*< Unused (do not remove)  }

  { Application events  }                                             {*< User-requested quit  }
  SDL_EVENT_QUIT  = TSDL_EventType($100);

  { These application events have special meaning on iOS and Android, see README-ios.md and README-android.md for details  }
  SDL_EVENT_TERMINATING  = TSDL_EventType(257);                                        {*< The application is being terminated by the OS. This event must be handled in a callback set with SDL_AddEventWatch().
                                                                                                           Called on iOS in applicationWillTerminate()
                                                                                                           Called on Android in onDestroy()
                                                                                                       }
  SDL_EVENT_LOW_MEMORY  = TSDL_EventType(258);                                         {*< The application is low on memory, free memory if possible. This event must be handled in a callback set with SDL_AddEventWatch().
                                                                                                           Called on iOS in applicationDidReceiveMemoryWarning()
                                                                                                           Called on Android in onTrimMemory()
                                                                                                       }
  SDL_EVENT_WILL_ENTER_BACKGROUND  = TSDL_EventType(259);                              {*< The application is about to enter the background. This event must be handled in a callback set with SDL_AddEventWatch().
                                                                                                           Called on iOS in applicationWillResignActive()
                                                                                                           Called on Android in onPause()
                                                                                                       }
  SDL_EVENT_DID_ENTER_BACKGROUND  = TSDL_EventType(260);                               {*< The application did enter the background and may not get CPU for some time. This event must be handled in a callback set with SDL_AddEventWatch().
                                                                                                           Called on iOS in applicationDidEnterBackground()
                                                                                                           Called on Android in onPause()
                                                                                                       }
  SDL_EVENT_WILL_ENTER_FOREGROUND  = TSDL_EventType(261);                              {*< The application is about to enter the foreground. This event must be handled in a callback set with SDL_AddEventWatch().
                                                                                                           Called on iOS in applicationWillEnterForeground()
                                                                                                           Called on Android in onResume()
                                                                                                       }
  SDL_EVENT_DID_ENTER_FOREGROUND  = TSDL_EventType(262);                               {*< The application is now interactive. This event must be handled in a callback set with SDL_AddEventWatch().
                                                                                                           Called on iOS in applicationDidBecomeActive()
                                                                                                           Called on Android in onResume()
                                                                                                       }

  SDL_EVENT_LOCALE_CHANGED  = TSDL_EventType(263);                                     {*< The user's locale preferences have changed.  }

  SDL_EVENT_SYSTEM_THEME_CHANGED  = TSDL_EventType(264);                               {*< The system theme changed  }

  { Display events  }
  { 0x150 was SDL_DISPLAYEVENT, reserve the number for sdl2-compat  }
  SDL_EVENT_DISPLAY_ORIENTATION  = TSDL_EventType($151);                               {*< Display orientation has changed to data1  }
  SDL_EVENT_DISPLAY_ADDED  = TSDL_EventType(338);                                      {*< Display has been added to the system  }
  SDL_EVENT_DISPLAY_REMOVED  = TSDL_EventType(339);                                    {*< Display has been removed from the system  }
  SDL_EVENT_DISPLAY_MOVED  = TSDL_EventType(340);                                      {*< Display has changed position  }
  SDL_EVENT_DISPLAY_DESKTOP_MODE_CHANGED  = TSDL_EventType(341);                       {*< Display has changed desktop mode  }
  SDL_EVENT_DISPLAY_CURRENT_MODE_CHANGED  = TSDL_EventType(342);                       {*< Display has changed current mode  }
  SDL_EVENT_DISPLAY_CONTENT_SCALE_CHANGED  = TSDL_EventType(343);                      {*< Display has changed content scale  }
  SDL_EVENT_DISPLAY_USABLE_BOUNDS_CHANGED  = TSDL_EventType(344);                      {*< Display has changed usable bounds  }
  SDL_EVENT_DISPLAY_FIRST  = TSDL_EventType(SDL_EVENT_DISPLAY_ORIENTATION);
  SDL_EVENT_DISPLAY_LAST  = TSDL_EventType(SDL_EVENT_DISPLAY_USABLE_BOUNDS_CHANGED);

  { Window events  }
  { 0x200 was SDL_WINDOWEVENT, reserve the number for sdl2-compat  }
  { 0x201 was SDL_SYSWMEVENT, reserve the number for sdl2-compat  }
  SDL_EVENT_WINDOW_SHOWN  = TSDL_EventType($202);                                      {*< Window has been shown  }
  SDL_EVENT_WINDOW_HIDDEN  = TSDL_EventType(515);                                      {*< Window has been hidden  }
  SDL_EVENT_WINDOW_EXPOSED  = TSDL_EventType(516);                                     {*< Window has been exposed and should be redrawn, and can be redrawn directly from event watchers for this event.
                                                                                           data1 is 1 for live-resize expose events, 0 otherwise.  }
  SDL_EVENT_WINDOW_MOVED  = TSDL_EventType(517);                                       {*< Window has been moved to data1, data2  }
  SDL_EVENT_WINDOW_RESIZED  = TSDL_EventType(518);                                     {*< Window has been resized to data1xdata2  }
  SDL_EVENT_WINDOW_PIXEL_SIZE_CHANGED  = TSDL_EventType(519);                          {*< The pixel size of the window has changed to data1xdata2  }
  SDL_EVENT_WINDOW_METAL_VIEW_RESIZED  = TSDL_EventType(520);                          {*< The pixel size of a Metal view associated with the window has changed  }
  SDL_EVENT_WINDOW_MINIMIZED  = TSDL_EventType(521);                                   {*< Window has been minimized  }
  SDL_EVENT_WINDOW_MAXIMIZED  = TSDL_EventType(522);                                   {*< Window has been maximized  }
  SDL_EVENT_WINDOW_RESTORED  = TSDL_EventType(523);                                    {*< Window has been restored to normal size and position  }
  SDL_EVENT_WINDOW_MOUSE_ENTER  = TSDL_EventType(524);                                 {*< Window has gained mouse focus  }
  SDL_EVENT_WINDOW_MOUSE_LEAVE  = TSDL_EventType(525);                                 {*< Window has lost mouse focus  }
  SDL_EVENT_WINDOW_FOCUS_GAINED  = TSDL_EventType(526);                                {*< Window has gained keyboard focus  }
  SDL_EVENT_WINDOW_FOCUS_LOST  = TSDL_EventType(527);                                  {*< Window has lost keyboard focus  }
  SDL_EVENT_WINDOW_CLOSE_REQUESTED  = TSDL_EventType(528);                             {*< The window manager requests that the window be closed  }
  SDL_EVENT_WINDOW_HIT_TEST  = TSDL_EventType(529);                                    {*< Window had a hit test that wasn't SDL_HITTEST_NORMAL  }
  SDL_EVENT_WINDOW_ICCPROF_CHANGED  = TSDL_EventType(530);                             {*< The ICC profile of the window's display has changed  }
  SDL_EVENT_WINDOW_DISPLAY_CHANGED  = TSDL_EventType(531);                             {*< Window has been moved to display data1  }
  SDL_EVENT_WINDOW_DISPLAY_SCALE_CHANGED  = TSDL_EventType(532);                       {*< Window display scale has been changed  }
  SDL_EVENT_WINDOW_SAFE_AREA_CHANGED  = TSDL_EventType(533);                           {*< The window safe area has been changed  }
  SDL_EVENT_WINDOW_OCCLUDED  = TSDL_EventType(534);                                    {*< The window has been occluded  }
  SDL_EVENT_WINDOW_ENTER_FULLSCREEN  = TSDL_EventType(535);                            {*< The window has entered fullscreen mode  }
  SDL_EVENT_WINDOW_LEAVE_FULLSCREEN  = TSDL_EventType(536);                            {*< The window has left fullscreen mode  }
  SDL_EVENT_WINDOW_DESTROYED  = TSDL_EventType(537);                                   {*< The window with the associated ID is being or has been destroyed. If this message is being handled
                                                                                                                   in an event watcher, the window handle is still valid and can still be used to retrieve any properties
                                                                                                                   associated with the window. Otherwise, the handle has already been destroyed and all resources
                                                                                                                   associated with it are invalid  }
  SDL_EVENT_WINDOW_HDR_STATE_CHANGED  = TSDL_EventType(538);                           {*< Window HDR properties have changed  }
  SDL_EVENT_WINDOW_FIRST  = TSDL_EventType(SDL_EVENT_WINDOW_SHOWN);
  SDL_EVENT_WINDOW_LAST  = TSDL_EventType(SDL_EVENT_WINDOW_HDR_STATE_CHANGED);

  { Keyboard events  }
  SDL_EVENT_KEY_DOWN  = TSDL_EventType($300);                                          {*< Key pressed  }
  SDL_EVENT_KEY_UP  = TSDL_EventType(769);                                             {*< Key released  }
  SDL_EVENT_TEXT_EDITING  = TSDL_EventType(770);                                       {*< Keyboard text editing (composition)  }
  SDL_EVENT_TEXT_INPUT  = TSDL_EventType(771);                                         {*< Keyboard text input  }
  SDL_EVENT_KEYMAP_CHANGED  = TSDL_EventType(772);                                     {*< Keymap changed due to a system event such as an
                                                                                                                  input language or keyboard layout change.  }
  SDL_EVENT_KEYBOARD_ADDED  = TSDL_EventType(773);                                     {*< A new keyboard has been inserted into the system  }
  SDL_EVENT_KEYBOARD_REMOVED  = TSDL_EventType(774);                                   {*< A keyboard has been removed  }
  SDL_EVENT_TEXT_EDITING_CANDIDATES  = TSDL_EventType(775);                            {*< Keyboard text editing candidates  }
  SDL_EVENT_SCREEN_KEYBOARD_SHOWN  = TSDL_EventType(776);                              {*< The on-screen keyboard has been shown  }
  SDL_EVENT_SCREEN_KEYBOARD_HIDDEN  = TSDL_EventType(777);                             {*< The on-screen keyboard has been hidden  }

  { Mouse events  }
  SDL_EVENT_MOUSE_MOTION  = TSDL_EventType($400);                                      {*< Mouse moved  }
  SDL_EVENT_MOUSE_BUTTON_DOWN  = TSDL_EventType(1025);                                 {*< Mouse button pressed  }
  SDL_EVENT_MOUSE_BUTTON_UP  = TSDL_EventType(1026);                                   {*< Mouse button released  }
  SDL_EVENT_MOUSE_WHEEL  = TSDL_EventType(1027);                                       {*< Mouse wheel motion  }
  SDL_EVENT_MOUSE_ADDED  = TSDL_EventType(1028);                                       {*< A new mouse has been inserted into the system  }
  SDL_EVENT_MOUSE_REMOVED  = TSDL_EventType(1029);                                     {*< A mouse has been removed  }

  { Joystick events  }
  SDL_EVENT_JOYSTICK_AXIS_MOTION  = TSDL_EventType($600);                              {*< Joystick axis motion  }
  SDL_EVENT_JOYSTICK_BALL_MOTION  = TSDL_EventType(1537);                              {*< Joystick trackball motion  }
  SDL_EVENT_JOYSTICK_HAT_MOTION  = TSDL_EventType(1538);                               {*< Joystick hat position change  }
  SDL_EVENT_JOYSTICK_BUTTON_DOWN  = TSDL_EventType(1539);                              {*< Joystick button pressed  }
  SDL_EVENT_JOYSTICK_BUTTON_UP  = TSDL_EventType(1540);                                {*< Joystick button released  }
  SDL_EVENT_JOYSTICK_ADDED  = TSDL_EventType(1541);                                    {*< A new joystick has been inserted into the system  }
  SDL_EVENT_JOYSTICK_REMOVED  = TSDL_EventType(1542);                                  {*< An opened joystick has been removed  }
  SDL_EVENT_JOYSTICK_BATTERY_UPDATED  = TSDL_EventType(1543);                          {*< Joystick battery level change  }
  SDL_EVENT_JOYSTICK_UPDATE_COMPLETE  = TSDL_EventType(1544);                          {*< Joystick update is complete  }

  { Gamepad events  }
  SDL_EVENT_GAMEPAD_AXIS_MOTION  = TSDL_EventType($650);                               {*< Gamepad axis motion  }
  SDL_EVENT_GAMEPAD_BUTTON_DOWN  = TSDL_EventType(1617);                               {*< Gamepad button pressed  }
  SDL_EVENT_GAMEPAD_BUTTON_UP  = TSDL_EventType(1618);                                 {*< Gamepad button released  }
  SDL_EVENT_GAMEPAD_ADDED  = TSDL_EventType(1619);                                     {*< A new gamepad has been inserted into the system  }
  SDL_EVENT_GAMEPAD_REMOVED  = TSDL_EventType(1620);                                   {*< A gamepad has been removed  }
  SDL_EVENT_GAMEPAD_REMAPPED  = TSDL_EventType(1621);                                  {*< The gamepad mapping was updated  }
  SDL_EVENT_GAMEPAD_TOUCHPAD_DOWN  = TSDL_EventType(1622);                             {*< Gamepad touchpad was touched  }
  SDL_EVENT_GAMEPAD_TOUCHPAD_MOTION  = TSDL_EventType(1623);                           {*< Gamepad touchpad finger was moved  }
  SDL_EVENT_GAMEPAD_TOUCHPAD_UP  = TSDL_EventType(1624);                               {*< Gamepad touchpad finger was lifted  }
  SDL_EVENT_GAMEPAD_SENSOR_UPDATE  = TSDL_EventType(1625);                             {*< Gamepad sensor was updated  }
  SDL_EVENT_GAMEPAD_UPDATE_COMPLETE  = TSDL_EventType(1626);                           {*< Gamepad update is complete  }
  SDL_EVENT_GAMEPAD_STEAM_HANDLE_UPDATED  = TSDL_EventType(1627);                      {*< Gamepad Steam handle has changed  }

  { Touch events  }
  SDL_EVENT_FINGER_DOWN  = TSDL_EventType($700);
  SDL_EVENT_FINGER_UP  = TSDL_EventType(1793);
  SDL_EVENT_FINGER_MOTION  = TSDL_EventType(1794);
  SDL_EVENT_FINGER_CANCELED  = TSDL_EventType(1795);

  { Pinch events  }
  SDL_EVENT_PINCH_BEGIN  = TSDL_EventType($710);     { Pinch gesture started }
  SDL_EVENT_PINCH_UPDATE  = TSDL_EventType($711);    { Pinch gesture updated }
  SDL_EVENT_PINCH_END  = TSDL_EventType($712);       { Pinch gesture ended }

  { 0x800, 0x801, and 0x802 were the Gesture events from SDL2. Do not reuse these values! sdl2-compat needs them!  }

  { Clipboard events  }
  SDL_EVENT_CLIPBOARD_UPDATE  = TSDL_EventType($900);                                  {*< The clipboard changed  }

  { Drag and drop events  }
  SDL_EVENT_DROP_FILE  = TSDL_EventType($1000);                                        {*< The system requests a file open  }
  SDL_EVENT_DROP_TEXT  = TSDL_EventType(4097);                                         {*< text/plain drag-and-drop event  }
  SDL_EVENT_DROP_BEGIN  = TSDL_EventType(4098);                                        {*< A new set of drops is beginning (nil filename)  }
  SDL_EVENT_DROP_COMPLETE  = TSDL_EventType(4099);                                     {*< Current set of drops is now complete (nil filename)  }
  SDL_EVENT_DROP_POSITION  = TSDL_EventType(4100);                                     {*< Position while moving over the window  }

  { Audio hotplug events  }
  SDL_EVENT_AUDIO_DEVICE_ADDED  = TSDL_EventType($1100);                               {*< A new audio device is available  }
  SDL_EVENT_AUDIO_DEVICE_REMOVED  = TSDL_EventType(4353);                              {*< An audio device has been removed.  }
  SDL_EVENT_AUDIO_DEVICE_FORMAT_CHANGED  = TSDL_EventType(4354);                       {*< An audio device's format has been changed by the system.  }

  { Sensor events  }
  SDL_EVENT_SENSOR_UPDATE  = TSDL_EventType($1200);                                    {*< A sensor was updated  }

  { Pressure-sensitive pen events  }
  SDL_EVENT_PEN_PROXIMITY_IN  = TSDL_EventType($1300);                                 {*< Pressure-sensitive pen has become available  }
  SDL_EVENT_PEN_PROXIMITY_OUT  = TSDL_EventType(4865);                                 {*< Pressure-sensitive pen has become unavailable  }
  SDL_EVENT_PEN_DOWN  = TSDL_EventType(4866);                                          {*< Pressure-sensitive pen touched drawing surface  }
  SDL_EVENT_PEN_UP  = TSDL_EventType(4867);                                            {*< Pressure-sensitive pen stopped touching drawing surface  }
  SDL_EVENT_PEN_BUTTON_DOWN  = TSDL_EventType(4868);                                   {*< Pressure-sensitive pen button pressed  }
  SDL_EVENT_PEN_BUTTON_UP  = TSDL_EventType(4869);                                     {*< Pressure-sensitive pen button released  }
  SDL_EVENT_PEN_MOTION  = TSDL_EventType(4870);                                        {*< Pressure-sensitive pen is moving on the tablet  }
  SDL_EVENT_PEN_AXIS  = TSDL_EventType(4871);                                          {*< Pressure-sensitive pen angle/pressure/etc changed  }

  { Camera hotplug events  }
  SDL_EVENT_CAMERA_DEVICE_ADDED  = TSDL_EventType($1400);                              {*< A new camera device is available  }
  SDL_EVENT_CAMERA_DEVICE_REMOVED  = TSDL_EventType(5121);                             {*< A camera device has been removed.  }
  SDL_EVENT_CAMERA_DEVICE_APPROVED  = TSDL_EventType(5122);                            {*< A camera device has been approved for use by the user.  }
  SDL_EVENT_CAMERA_DEVICE_DENIED  = TSDL_EventType(5123);                              {*< A camera device has been denied for use by the user.  }

  { Render events  }
  SDL_EVENT_RENDER_TARGETS_RESET  = TSDL_EventType($2000);                             {*< The render targets have been reset and their contents need to be updated  }
  SDL_EVENT_RENDER_DEVICE_RESET  = TSDL_EventType(8193);                               {*< The device has been reset and all textures need to be recreated  }
  SDL_EVENT_RENDER_DEVICE_LOST  = TSDL_EventType(8194);                                {*< The device has been lost and can't be recovered.  }

  { Reserved events for private platforms  }
  SDL_EVENT_PRIVATE0  = TSDL_EventType($4000);
  SDL_EVENT_PRIVATE1  = TSDL_EventType(16385);
  SDL_EVENT_PRIVATE2  = TSDL_EventType(16386);
  SDL_EVENT_PRIVATE3  = TSDL_EventType(16387);

  { Internal events  }
  SDL_EVENT_POLL_SENTINEL  = TSDL_EventType($7F00);                                    {*< Signals the end of an event poll cycle  }

  {* Events SDL_EVENT_USER through SDL_EVENT_LAST are for your use,
   *  and should be allocated with SDL_RegisterEvents()
   }
  SDL_EVENT_USER  = TSDL_EventType($8000);

  {*
       *  This last event is only for bounding internal arrays
        }
  SDL_EVENT_LAST  = TSDL_EventType($FFFF);

  { This just makes sure the enum is the size of Uint32  }
  SDL_EVENT_ENUM_PADDING  = TSDL_EventType($7FFFFFFF);

{*
 * Fields shared by every event
 *
 * \since This struct is available since SDL 3.2.0.
  }
type
  PPSDL_CommonEvent = ^PSDL_CommonEvent;
  PSDL_CommonEvent = ^TSDL_CommonEvent;
  TSDL_CommonEvent = record
    type_: cuint32;               {*< Event type, shared with all events, Uint32 to cover user events which are not in the SDL_EventType enumeration  }
    reserved: cuint32;
    timestamp: cuint64;           {*< In nanoseconds, populated using SDL_GetTicksNS()  }
  end;

{*
 * Display state change event data (event.display.*)
 *
 * \since This struct is available since SDL 3.2.0.
  }
  PPSDL_DisplayEvent = ^PSDL_DisplayEvent;
  PSDL_DisplayEvent = ^TSDL_DisplayEvent;
  TSDL_DisplayEvent = record
      type_: TSDL_EventType;          {*< SDL_EVENT_DISPLAY_*  }
      reserved: cuint32;
      timestamp: cuint64;             {*< In nanoseconds, populated using SDL_GetTicksNS()  }
      displayID: TSDL_DisplayID;      {*< The associated display  }
      data1: cint32;                  {*< event dependent data  }
      data2: cint32;                  {*< event dependent data  }
    end;

{*
 * Window state change event data (event.window.*)
 *
 * \since This struct is available since SDL 3.2.0.
  }
  PPSDL_WindowEvent = ^PSDL_WindowEvent;
  PSDL_WindowEvent = ^TSDL_WindowEvent;
  TSDL_WindowEvent = record
      type_: TSDL_EventType;        {*< SDL_EVENT_WINDOW_*  }
      reserved: cuint32;
      timestamp: cuint64;           {*< In nanoseconds, populated using SDL_GetTicksNS()  }
      windowID: TSDL_WindowID;      {*< The associated window  }
      data1: cint32;                {*< event dependent data  }
      data2: cint32;                {*< event dependent data  }
    end;

{*
 * Keyboard device event structure (event.kdevice.*)
 *
 * \since This struct is available since SDL 3.2.0.
  }
  PPSDL_KeyboardDeviceEvent = ^PSDL_KeyboardDeviceEvent;
  PSDL_KeyboardDeviceEvent = ^TSDL_KeyboardDeviceEvent;
  TSDL_KeyboardDeviceEvent = record
      type_: TSDL_EventType;      {*< SDL_EVENT_KEYBOARD_ADDED or SDL_EVENT_KEYBOARD_REMOVED  }
      reserved: cuint32;
      timestamp: cuint64;         {*< In nanoseconds, populated using SDL_GetTicksNS()  }
      which: TSDL_KeyboardID;     {*< The keyboard instance id  }
    end;

{*
 * Keyboard button event structure (event.key.*)
 *
 * The `key` is the base SDL_Keycode generated by pressing the `scancode`
 * using the current keyboard layout, applying any options specified in
 * SDL_HINT_KEYCODE_OPTIONS. You can get the SDL_Keycode corresponding to the
 * event scancode and modifiers directly from the keyboard layout, bypassing
 * SDL_HINT_KEYCODE_OPTIONS, by calling SDL_GetKeyFromScancode().
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_GetKeyFromScancode
 * \sa SDL_HINT_KEYCODE_OPTIONS
  }
  PPSDL_KeyboardEvent = ^PSDL_KeyboardEvent;
  PSDL_KeyboardEvent = ^TSDL_KeyboardEvent;
  TSDL_KeyboardEvent = record
      type_: TSDL_EventType;        {*< SDL_EVENT_KEY_DOWN or SDL_EVENT_KEY_UP  }
      reserved: cuint32;
      timestamp: cuint64;           {*< In nanoseconds, populated using SDL_GetTicksNS()  }
      windowID: TSDL_WindowID;      {*< The window with keyboard focus, if any  }
      which: TSDL_KeyboardID;       {*< The keyboard instance id, or 0 if unknown or virtual  }
      scancode: TSDL_Scancode;      {*< SDL physical key code  }
      key: TSDL_Keycode;            {*< SDL virtual key code  }
      mod_: TSDL_Keymod;            {*< current key modifiers  }
      raw: cuint16;                 {*< The platform dependent scancode for this event  }
      down: Boolean;                {*< true if the key is pressed  }
      repeat_: Boolean;             {*< true if this is a key repeat  }
    end;

{*
 * Keyboard text editing event structure (event.edit.*)
 *
 * The start cursor is the position, in UTF-8 characters, where new typing
 * will be inserted into the editing text. The length is the number of UTF-8
 * characters that will be replaced by new typing.
 *
 * \since This struct is available since SDL 3.2.0.
  }
  PPSDL_TextEditingEvent = ^PSDL_TextEditingEvent;
  PSDL_TextEditingEvent = ^TSDL_TextEditingEvent;
  TSDL_TextEditingEvent = record
      type_: TSDL_EventType;        {*< SDL_EVENT_TEXT_EDITING  }
      reserved: cuint32;
      timestamp: cuint64;           {*< In nanoseconds, populated using SDL_GetTicksNS()  }
      windowID: TSDL_WindowID;      {*< The window with keyboard focus, if any  }
      text: PAnsiChar;              {*< The editing text  }
      start: cint32;                {*< The start cursor of selected editing text, or -1 if not set  }
      length: cint32;               {*< The length of selected editing text, or -1 if not set  }
    end;

{*
 * Keyboard IME candidates event structure (event.edit_candidates.*)
 *
 * \since This struct is available since SDL 3.2.0.
  }
  PPSDL_TextEditingCandidatesEvent = ^PSDL_TextEditingCandidatesEvent;
  PSDL_TextEditingCandidatesEvent = ^TSDL_TextEditingCandidatesEvent;
  TSDL_TextEditingCandidatesEvent = record
      type_: TSDL_EventType;          {*< SDL_EVENT_TEXT_EDITING_CANDIDATES  }
      reserved: cuint32;
      timestamp: cuint64;             {*< In nanoseconds, populated using SDL_GetTicksNS()  }
      windowID: TSDL_WindowID;        {*< The window with keyboard focus, if any  }
      candidates: ^PAnsiChar;         {*< The list of candidates, or nil if there are no candidates available  }
      num_candidates: cint32;         {*< The number of strings in `candidates`  }
      selected_candidate: cint32;     {*< The index of the selected candidate, or -1 if no candidate is selected  }
      horizontal: Boolean;            {*< true if the list is horizontal, false if it's vertical  }
      padding1: cuint8;
      padding2: cuint8;
      padding3: cuint8;
    end;

{*
 * Keyboard text input event structure (event.text.*)
 *
 * This event will never be delivered unless text input is enabled by calling
 * SDL_StartTextInput(). Text input is disabled by default!
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_StartTextInput
 * \sa SDL_StopTextInput
  }
  PPSDL_TextInputEvent = ^PSDL_TextInputEvent;
  PSDL_TextInputEvent = ^TSDL_TextInputEvent;
  TSDL_TextInputEvent = record
      type_: TSDL_EventType;       {*< SDL_EVENT_TEXT_INPUT  }
      reserved: cuint32;
      timestamp: cuint64;          {*< In nanoseconds, populated using SDL_GetTicksNS()  }
      windowID: TSDL_WindowID;     {*< The window with keyboard focus, if any  }
      text: PAnsiChar;             {*< The input text, UTF-8 encoded  }
    end;

{*
 * Mouse device event structure (event.mdevice.*)
 *
 * \since This struct is available since SDL 3.2.0.
  }
  PPSDL_MouseDeviceEvent = ^PSDL_MouseDeviceEvent;
  PSDL_MouseDeviceEvent = ^TSDL_MouseDeviceEvent;
  TSDL_MouseDeviceEvent = record
      type_: TSDL_EventType;     {*< SDL_EVENT_MOUSE_ADDED or SDL_EVENT_MOUSE_REMOVED  }
      reserved: cuint32;
      timestamp: cuint64;        {*< In nanoseconds, populated using SDL_GetTicksNS()  }
      which: TSDL_MouseID;       {*< The mouse instance id  }
    end;

{*
 * Mouse motion event structure (event.motion.*)
 *
 * \since This struct is available since SDL 3.2.0.
  }
  PPSDL_MouseMotionEvent = ^PSDL_MouseMotionEvent;
  PSDL_MouseMotionEvent = ^TSDL_MouseMotionEvent;
  TSDL_MouseMotionEvent = record
      type_: TSDL_EventType;            {*< SDL_EVENT_MOUSE_MOTION  }
      reserved: cuint32;
      timestamp: cuint64;               {*< In nanoseconds, populated using SDL_GetTicksNS()  }
      windowID: TSDL_WindowID;          {*< The window with mouse focus, if any  }
      which: TSDL_MouseID;              {*< The mouse instance id or SDL_TOUCH_MOUSEID  }
      state: TSDL_MouseButtonFlags;     {*< The current button state  }
      x: cfloat;                        {*< X coordinate, relative to window  }
      y: cfloat;                        {*< Y coordinate, relative to window  }
      xrel: cfloat;                     {*< The relative motion in the X direction  }
      yrel: cfloat;                     {*< The relative motion in the Y direction  }
    end;

{*
 * Mouse button event structure (event.button.*)
 *
 * \since This struct is available since SDL 3.2.0.
  }
  PPSDL_MouseButtonEvent = ^PSDL_MouseButtonEvent;
  PSDL_MouseButtonEvent = ^TSDL_MouseButtonEvent;
  TSDL_MouseButtonEvent = record
      type_: TSDL_EventType;         {*< SDL_EVENT_MOUSE_BUTTON_DOWN or SDL_EVENT_MOUSE_BUTTON_UP  }
      reserved: cuint32;
      timestamp: cuint64;            {*< In nanoseconds, populated using SDL_GetTicksNS()  }
      windowID: TSDL_WindowID;       {*< The window with mouse focus, if any  }
      which: TSDL_MouseID;           {*< The mouse instance id in relative mode, SDL_TOUCH_MOUSEID for touch events, or 0  }
      button: cuint8;                {*< The mouse button index  }
      down: Boolean;                 {*< true if the button is pressed  }
      clicks: cuint8;                {*< 1 for single-click, 2 for double-click, etc.  }
      padding: cuint8;
      x: cfloat;                     {*< X coordinate, relative to window  }
      y: cfloat;                     {*< Y coordinate, relative to window  }
    end;

{*
 * Mouse wheel event structure (event.wheel.*)
 *
 * \since This struct is available since SDL 3.2.0.
  }
  PPSDL_MouseWheelEvent = ^PSDL_MouseWheelEvent;
  PSDL_MouseWheelEvent = ^TSDL_MouseWheelEvent;
  TSDL_MouseWheelEvent = record
      type_: TSDL_EventType;                 {*< SDL_EVENT_MOUSE_WHEEL  }
      reserved: cuint32;
      timestamp: cuint64;                    {*< In nanoseconds, populated using SDL_GetTicksNS()  }
      windowID: TSDL_WindowID;               {*< The window with mouse focus, if any  }
      which: TSDL_MouseID;                   {*< The mouse instance id in relative mode or 0  }
      x: cfloat;                             {*< The amount scrolled horizontally, positive to the right and negative to the left  }
      y: cfloat;                             {*< The amount scrolled vertically, positive away from the user and negative toward the user  }
      direction: TSDL_MouseWheelDirection;   {*< Set to one of the SDL_MOUSEWHEEL_* defines. When FLIPPED the values in X and Y will be opposite. Multiply by -1 to change them back  }
      mouse_x: cfloat;                       {*< X coordinate, relative to window  }
      mouse_y: cfloat;                       {*< Y coordinate, relative to window  }
      integer_x: cint32;                     {*< The amount scrolled horizontally, accumulated to whole scroll "ticks" (added in 3.2.12) *}
      integer_y: cint32;                     {*< The amount scrolled vertically, accumulated to whole scroll "ticks" (added in 3.2.12) *}
    end;

{*
 * Joystick axis motion event structure (event.jaxis.*)
 *
 * \since This struct is available since SDL 3.2.0.
  }
  PPSDL_JoyAxisEvent = ^PSDL_JoyAxisEvent;
  PSDL_JoyAxisEvent = ^TSDL_JoyAxisEvent;
  TSDL_JoyAxisEvent = record
      type_: TSDL_EventType;    {*< SDL_EVENT_JOYSTICK_AXIS_MOTION  }
      reserved: cuint32;
      timestamp: cuint64;       {*< In nanoseconds, populated using SDL_GetTicksNS()  }
      which: TSDL_JoystickID;   {*< The joystick instance id  }
      axis: cuint8;             {*< The joystick axis index  }
      padding1: cuint8;
      padding2: cuint8;
      padding3: cuint8;
      value: cint16;            {*< The axis value (range: -32768 to 32767)  }
      padding4: cuint16;
    end;

{*
 * Joystick trackball motion event structure (event.jball.*)
 *
 * \since This struct is available since SDL 3.2.0.
  }
  PPSDL_JoyBallEvent = ^PSDL_JoyBallEvent;
  PSDL_JoyBallEvent = ^TSDL_JoyBallEvent;
  TSDL_JoyBallEvent = record
      type_: TSDL_EventType;    {*< SDL_EVENT_JOYSTICK_BALL_MOTION  }
      reserved: cuint32;
      timestamp: cuint64;       {*< In nanoseconds, populated using SDL_GetTicksNS()  }
      which: TSDL_JoystickID;   {*< The joystick instance id  }
      ball: cuint8;             {*< The joystick trackball index  }
      padding1: cuint8;
      padding2: cuint8;
      padding3: cuint8;
      xrel: cint16;             {*< The relative motion in the X direction  }
      yrel: cint16;             {*< The relative motion in the Y direction  }
    end;

{*
 * Joystick hat position change event structure (event.jhat.*)
 *
 * \since This struct is available since SDL 3.2.0.
  }
  PPSDL_JoyHatEvent = ^PSDL_JoyHatEvent;
  PSDL_JoyHatEvent = ^TSDL_JoyHatEvent;
  TSDL_JoyHatEvent = record
      type_: TSDL_EventType;          {*< SDL_EVENT_JOYSTICK_HAT_MOTION  }
      reserved: cuint32;
      timestamp: cuint64;             {*< In nanoseconds, populated using SDL_GetTicksNS()  }
      which: TSDL_JoystickID;         {*< The joystick instance id  }
      hat: cuint8;                    {*< The joystick hat index  }
      value: cuint8;                  {*< The hat position value.
                                                               *   \sa SDL_HAT_LEFTUP SDL_HAT_UP SDL_HAT_RIGHTUP
                                                               *   \sa SDL_HAT_LEFT SDL_HAT_CENTERED SDL_HAT_RIGHT
                                                               *   \sa SDL_HAT_LEFTDOWN SDL_HAT_DOWN SDL_HAT_RIGHTDOWN
                                                               *
                                                               *   Note that zero means the POV is centered.
                                                                }
      padding1: cuint8;
      padding2: cuint8;
    end;
{*
 * Joystick button event structure (event.jbutton.*)
 *
 * \since This struct is available since SDL 3.2.0.
  }
  PPSDL_JoyButtonEvent = ^PSDL_JoyButtonEvent;
  PSDL_JoyButtonEvent = ^TSDL_JoyButtonEvent;
  TSDL_JoyButtonEvent = record
      type_: TSDL_EventType;     {*< SDL_EVENT_JOYSTICK_BUTTON_DOWN or SDL_EVENT_JOYSTICK_BUTTON_UP  }
      reserved: cuint32;
      timestamp: cuint64;        {*< In nanoseconds, populated using SDL_GetTicksNS()  }
      which: TSDL_JoystickID;    {*< The joystick instance id  }
      button: cuint8;            {*< The joystick button index  }
      down: Boolean;             {*< true if the button is pressed  }
      padding1: cuint8;
      padding2: cuint8;
    end;

{*
 * Joystick device event structure (event.jdevice.*)
 *
 * SDL will send JOYSTICK_ADDED events for devices that are already plugged in
 * during SDL_Init.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_GamepadDeviceEvent
  }
  PPSDL_JoyDeviceEvent = ^PSDL_JoyDeviceEvent;
  PSDL_JoyDeviceEvent = ^TSDL_JoyDeviceEvent;
  TSDL_JoyDeviceEvent = record
      type_: TSDL_EventType;      {*< SDL_EVENT_JOYSTICK_ADDED or SDL_EVENT_JOYSTICK_REMOVED or SDL_EVENT_JOYSTICK_UPDATE_COMPLETE  }
      reserved: cuint32;
      timestamp: cuint64;         {*< In nanoseconds, populated using SDL_GetTicksNS()  }
      which: TSDL_JoystickID;     {*< The joystick instance id  }
    end;

{*
 * Joystick battery level change event structure (event.jbattery.*)
 *
 * \since This struct is available since SDL 3.2.0.
  }
  PPSDL_JoyBatteryEvent = ^PSDL_JoyBatteryEvent;
  PSDL_JoyBatteryEvent = ^TSDL_JoyBatteryEvent;
  TSDL_JoyBatteryEvent = record
      type_: TSDL_EventType;      {*< SDL_EVENT_JOYSTICK_BATTERY_UPDATED  }
      reserved: cuint32;
      timestamp: cuint64;         {*< In nanoseconds, populated using SDL_GetTicksNS()  }
      which: TSDL_JoystickID;     {*< The joystick instance id  }
      state: TSDL_PowerState;     {*< The joystick battery state  }
      percent: cint;              {*< The joystick battery percent charge remaining  }
    end;

{*
 * Gamepad axis motion event structure (event.gaxis.*)
 *
 * \since This struct is available since SDL 3.2.0.
  }
  PPSDL_GamepadAxisEvent = ^PSDL_GamepadAxisEvent;
  PSDL_GamepadAxisEvent = ^TSDL_GamepadAxisEvent;
  TSDL_GamepadAxisEvent = record
      type_: TSDL_EventType;    {*< SDL_EVENT_GAMEPAD_AXIS_MOTION  }
      reserved: cuint32;
      timestamp: cuint64;       {*< In nanoseconds, populated using SDL_GetTicksNS()  }
      which: TSDL_JoystickID;   {*< The joystick instance id  }
      axis: cuint8;             {*< The gamepad axis (SDL_GamepadAxis)  }
      padding1: cuint8;
      padding2: cuint8;
      padding3: cuint8;
      value: cint16;            {*< The axis value (range: -32768 to 32767)  }
      padding4: cuint16;
    end;

{*
 * Gamepad button event structure (event.gbutton.*)
 *
 * \since This struct is available since SDL 3.2.0.
  }
  PPSDL_GamepadButtonEvent = ^PSDL_GamepadButtonEvent;
  PSDL_GamepadButtonEvent = ^TSDL_GamepadButtonEvent;
  TSDL_GamepadButtonEvent = record
      type_: TSDL_EventType;    {*< SDL_EVENT_GAMEPAD_BUTTON_DOWN or SDL_EVENT_GAMEPAD_BUTTON_UP  }
      reserved: cuint32;
      timestamp: cuint64;       {*< In nanoseconds, populated using SDL_GetTicksNS()  }
      which: TSDL_JoystickID;   {*< The joystick instance id  }
      button: cuint8;           {*< The gamepad button (SDL_GamepadButton)  }
      down: Boolean;            {*< true if the button is pressed  }
      padding1: cuint8;
      padding2: cuint8;
    end;

{*
 * Gamepad device event structure (event.gdevice.*)
 *
 * Joysticks that are supported gamepads receive both an SDL_JoyDeviceEvent
 * and an SDL_GamepadDeviceEvent.
 *
 * SDL will send GAMEPAD_ADDED events for joysticks that are already plugged
 * in during SDL_Init() and are recognized as gamepads. It will also send
 * events for joysticks that get gamepad mappings at runtime.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_JoyDeviceEvent
  }
  PPSDL_GamepadDeviceEvent = ^PSDL_GamepadDeviceEvent;
  PSDL_GamepadDeviceEvent = ^TSDL_GamepadDeviceEvent;
  TSDL_GamepadDeviceEvent = record
      type_: TSDL_EventType;     {*< SDL_EVENT_GAMEPAD_ADDED, SDL_EVENT_GAMEPAD_REMOVED, or SDL_EVENT_GAMEPAD_REMAPPED, SDL_EVENT_GAMEPAD_UPDATE_COMPLETE or SDL_EVENT_GAMEPAD_STEAM_HANDLE_UPDATED  }
      reserved: cuint32;
      timestamp: cuint64;        {*< In nanoseconds, populated using SDL_GetTicksNS()  }
      which: TSDL_JoystickID;    {*< The joystick instance id  }
    end;

{*
 * Gamepad touchpad event structure (event.gtouchpad.*)
 *
 * \since This struct is available since SDL 3.2.0.
  }
  PPSDL_GamepadTouchpadEvent = ^PSDL_GamepadTouchpadEvent;
  PSDL_GamepadTouchpadEvent = ^TSDL_GamepadTouchpadEvent;
  TSDL_GamepadTouchpadEvent = record
      type_: TSDL_EventType;      {*< SDL_EVENT_GAMEPAD_TOUCHPAD_DOWN or SDL_EVENT_GAMEPAD_TOUCHPAD_MOTION or SDL_EVENT_GAMEPAD_TOUCHPAD_UP  }
      reserved: cuint32;
      timestamp: cuint64;         {*< In nanoseconds, populated using SDL_GetTicksNS()  }
      which: TSDL_JoystickID;     {*< The joystick instance id  }
      touchpad: cint32;           {*< The index of the touchpad  }
      finger: cint32;             {*< The index of the finger on the touchpad  }
      x: cfloat;                  {*< Normalized in the range 0...1 with 0 being on the left  }
      y: cfloat;                  {*< Normalized in the range 0...1 with 0 being at the top  }
      pressure: cfloat;           {*< Normalized in the range 0...1  }
    end;

{*
 * Gamepad sensor event structure (event.gsensor.*)
 *
 * \since This struct is available since SDL 3.2.0.
  }
  PPSDL_GamepadSensorEvent = ^PSDL_GamepadSensorEvent;
  PSDL_GamepadSensorEvent = ^TSDL_GamepadSensorEvent;
  TSDL_GamepadSensorEvent = record
      type_: TSDL_EventType;            {*< SDL_EVENT_GAMEPAD_SENSOR_UPDATE  }
      reserved: cuint32;
      timestamp: cuint64;               {*< In nanoseconds, populated using SDL_GetTicksNS()  }
      which: TSDL_JoystickID;           {*< The joystick instance id  }
      sensor: cint32;                   {*< The type of the sensor, one of the values of SDL_SensorType  }
      data: array[0..2] of cfloat;      {*< Up to 3 values from the sensor, as defined in SDL_sensor.h  }
      sensor_timestamp: cuint64;        {*< The timestamp of the sensor reading in nanoseconds, not necessarily synchronized with the system clock  }
    end;

{*
 * Audio device event structure (event.adevice.*)
 *
 * Note that SDL will send a SDL_EVENT_AUDIO_DEVICE_ADDED event for every
 * device it discovers during initialization. After that, this event will only
 * arrive when a device is hotplugged during the program's run.
 *
 * \since This struct is available since SDL 3.2.0.
  }
  PPSDL_AudioDeviceEvent = ^PSDL_AudioDeviceEvent;
  PSDL_AudioDeviceEvent = ^TSDL_AudioDeviceEvent;
  TSDL_AudioDeviceEvent = record
      type_: TSDL_EventType;       {*< SDL_EVENT_AUDIO_DEVICE_ADDED, or SDL_EVENT_AUDIO_DEVICE_REMOVED, or SDL_EVENT_AUDIO_DEVICE_FORMAT_CHANGED  }
      reserved: cuint32;
      timestamp: cuint64;          {*< In nanoseconds, populated using SDL_GetTicksNS()  }
      which: TSDL_AudioDeviceID;   {*< SDL_AudioDeviceID for the device being added or removed or changing  }
      recording: Boolean;          {*< false if a playback device, true if a recording device.  }
      padding1: cuint8;
      padding2: cuint8;
      padding3: cuint8;
    end;

{*
 * Camera device event structure (event.cdevice.*)
 *
 * \since This struct is available since SDL 3.2.0.
  }
  PPSDL_CameraDeviceEvent = ^PSDL_CameraDeviceEvent;
  PSDL_CameraDeviceEvent = ^TSDL_CameraDeviceEvent;
  TSDL_CameraDeviceEvent = record
      type_: TSDL_EventType;    {*< SDL_EVENT_CAMERA_DEVICE_ADDED, SDL_EVENT_CAMERA_DEVICE_REMOVED, SDL_EVENT_CAMERA_DEVICE_APPROVED, SDL_EVENT_CAMERA_DEVICE_DENIED  }
      reserved: cuint32;
      timestamp: cuint64;       {*< In nanoseconds, populated using SDL_GetTicksNS()  }
      which: TSDL_CameraID;     {*< SDL_CameraID for the device being added or removed or changing  }
    end;

{*
 * Renderer event structure (event.render.*)
 *
 * \since This struct is available since SDL 3.2.0.
 *}
  PPSDL_RenderEvent = ^PSDL_RenderEvent;
  PSDL_RenderEvent = ^TSDL_RenderEvent;
  TSDL_RenderEvent = record
    type_: TSDL_EventType;   {*< SDL_EVENT_RENDER_TARGETS_RESET, SDL_EVENT_RENDER_DEVICE_RESET, SDL_EVENT_RENDER_DEVICE_LOST }
    reserved: cuint32;
    timestamp: cuint64;      {*< In nanoseconds, populated using SDL_GetTicksNS() }
    windowID: TSDL_WindowID; {*< The window containing the renderer in question. }
  end;

{*
 * Touch finger event structure (event.tfinger.*)
 *
 * Coordinates in this event are normalized. `x` and `y` are normalized to a
 * range between 0.0f and 1.0f, relative to the window, so (0,0) is the top
 * left and (1,1) is the bottom right. Delta coordinates `dx` and `dy` are
 * normalized in the ranges of -1.0f (traversed all the way from the bottom or
 * right to all the way up or left) to 1.0f (traversed all the way from the
 * top or left to all the way down or right).
 *
 * Note that while the coordinates are _normalized_, they are not _clamped_,
 * which means in some circumstances you can get a value outside of this
 * range. For example, a renderer using logical presentation might give a
 * negative value when the touch is in the letterboxing. Some platforms might
 * report a touch outside of the window, which will also be outside of the
 * range.
 *
 * \since This struct is available since SDL 3.2.0.
  }
  PPSDL_TouchFingerEvent = ^PSDL_TouchFingerEvent;
  PSDL_TouchFingerEvent = ^TSDL_TouchFingerEvent;
  TSDL_TouchFingerEvent = record
      type_: TSDL_EventType;     {*< SDL_EVENT_FINGER_DOWN, SDL_EVENT_FINGER_UP, SDL_EVENT_FINGER_MOTION, or SDL_EVENT_FINGER_CANCELED  }
      reserved: cuint32;
      timestamp: cuint64;        {*< In nanoseconds, populated using SDL_GetTicksNS()  }
      touchID: TSDL_TouchID;     {*< The touch device id  }
      fingerID: TSDL_FingerID;   {*< Normalized in the range 0...1  }
      x: cfloat;                 {*< Normalized in the range 0...1  }
      y: cfloat;                 {*< Normalized in the range -1...1  }
      dx: cfloat;                {*< Normalized in the range -1...1  }
      dy: cfloat;                {*< Normalized in the range 0...1  }
      pressure: cfloat;          {*< The window underneath the finger, if any  }
      windowID: TSDL_WindowID;
    end;

{*
 * Pinch event structure (event.pinch.*)
  }
  PPSDL_PinchFingerEvent = ^PSDL_PinchFingerEvent;
  PSDL_PinchFingerEvent = ^TSDL_PinchFingerEvent;
  TSDL_PinchFingerEvent = record
      type_: TSDL_EventType;     {*<:: SDL_EVENT_PINCH_BEGIN or:: SDL_EVENT_PINCH_UPDATE or:: SDL_EVENT_PINCH_END  }
      reserved: cuint32;
      timestamp: cuint64;        {*< In nanoseconds, populated using SDL_GetTicksNS()  }
      scale: cfloat;             {*< The scale change since the last SDL_EVENT_PINCH_UPDATE. Scale < 1 is "zoom out". Scale > 1 is "zoom in".  }
      windowID: TSDL_WindowID;   {*< The window underneath the finger, if any  }
    end;

{*
 * Pressure-sensitive pen proximity event structure (event.pproximity.*)
 *
 * When a pen becomes visible to the system (it is close enough to a tablet,
 * etc), SDL will send an SDL_EVENT_PEN_PROXIMITY_IN event with the new pen's
 * ID. This ID is valid until the pen leaves proximity again (has been removed
 * from the tablet's area, the tablet has been unplugged, etc). If the same
 * pen reenters proximity again, it will be given a new ID.
 *
 * Note that "proximity" means "close enough for the tablet to know the tool
 * is there." The pen touching and lifting off from the tablet while not
 * leaving the area are handled by SDL_EVENT_PEN_DOWN and SDL_EVENT_PEN_UP.
 *
 * Not all platforms have a window associated with the pen during proximity
 * events. Some wait until motion/button/etc events to offer this info.
 *
 * \since This struct is available since SDL 3.2.0.
  }
  PPSDL_PenProximityEvent = ^PSDL_PenProximityEvent;
  PSDL_PenProximityEvent = ^TSDL_PenProximityEvent;
  TSDL_PenProximityEvent = record
      type_: TSDL_EventType;    {*< SDL_EVENT_PEN_PROXIMITY_IN or SDL_EVENT_PEN_PROXIMITY_OUT  }
      reserved: cuint32;
      timestamp: cuint64;       {*< In nanoseconds, populated using SDL_GetTicksNS()  }
      windowID: TSDL_WindowID;  {*< The window with pen focus, if any  }
      which: TSDL_PenID;        {*< The pen instance id  }
    end;

{*
 * Pressure-sensitive pen motion event structure (event.pmotion.*)
 *
 * Depending on the hardware, you may get motion events when the pen is not
 * touching a tablet, for tracking a pen even when it isn't drawing. You
 * should listen for SDL_EVENT_PEN_DOWN and SDL_EVENT_PEN_UP events, or check
 * `pen_state & SDL_PEN_INPUT_DOWN` to decide if a pen is "drawing" when
 * dealing with pen motion.
 *
 * \since This struct is available since SDL 3.2.0.
  }
  PPSDL_PenMotionEvent = ^PSDL_PenMotionEvent;
  PSDL_PenMotionEvent = ^TSDL_PenMotionEvent;
  TSDL_PenMotionEvent = record
      type_: TSDL_EventType;           {*< SDL_EVENT_PEN_MOTION  }
      reserved: cuint32;
      timestamp: cuint64;              {*< In nanoseconds, populated using SDL_GetTicksNS()  }
      windowID: TSDL_WindowID;         {*< The window with mouse focus, if any  }
      which: TSDL_PenID;               {*< The pen instance id  }
      pen_state: TSDL_PenInputFlags;   {*< Complete pen input state at time of event  }
      x: cfloat;                       {*< X coordinate, relative to window  }
      y: cfloat;                       {*< Y coordinate, relative to window  }
    end;

{*
 * Pressure-sensitive pen touched event structure (event.ptouch.*)
 *
 * These events come when a pen touches a surface (a tablet, etc), or lifts
 * off from one.
 *
 * \since This struct is available since SDL 3.2.0.
  }
  PPSDL_PenTouchEvent = ^PSDL_PenTouchEvent;
  PSDL_PenTouchEvent = ^TSDL_PenTouchEvent;
  TSDL_PenTouchEvent = record
      type_: TSDL_EventType;          {*< SDL_EVENT_PEN_DOWN or SDL_EVENT_PEN_UP  }
      reserved: cuint32;
      timestamp: cuint64;             {*< In nanoseconds, populated using SDL_GetTicksNS()  }
      windowID: TSDL_WindowID;        {*< The window with pen focus, if any  }
      which: TSDL_PenID;              {*< The pen instance id  }
      pen_state: TSDL_PenInputFlags;  {*< Complete pen input state at time of event  }
      x: cfloat;                      {*< X coordinate, relative to window  }
      y: cfloat;                      {*< Y coordinate, relative to window  }
      eraser: Boolean;                {*< true if eraser end is used (not all pens support this).  }
      down: Boolean;                  {*< true if the pen is touching or false if the pen is lifted off  }
    end;

{*
 * Pressure-sensitive pen button event structure (event.pbutton.*)
 *
 * This is for buttons on the pen itself that the user might click. The pen
 * itself pressing down to draw triggers a SDL_EVENT_PEN_DOWN event instead.
 *
 * \since This struct is available since SDL 3.2.0.
  }
  PPSDL_PenButtonEvent = ^PSDL_PenButtonEvent;
  PSDL_PenButtonEvent = ^TSDL_PenButtonEvent;
  TSDL_PenButtonEvent = record
      type_: TSDL_EventType;          {*< SDL_EVENT_PEN_BUTTON_DOWN or SDL_EVENT_PEN_BUTTON_UP  }
      reserved: cuint32;
      timestamp: cuint64;             {*< In nanoseconds, populated using SDL_GetTicksNS()  }
      windowID: TSDL_WindowID;        {*< The window with mouse focus, if any  }
      which: TSDL_PenID;              {*< The pen instance id  }
      pen_state: TSDL_PenInputFlags;  {*< Complete pen input state at time of event  }
      x: cfloat;                      {*< X coordinate, relative to window  }
      y: cfloat;                      {*< Y coordinate, relative to window  }
      button: cuint8;                 {*< The pen button index (first button is 1).  }
      down: Boolean;                  {*< true if the button is pressed  }
    end;

{*
 * Pressure-sensitive pen pressure / angle event structure (event.paxis.*)
 *
 * You might get some of these events even if the pen isn't touching the
 * tablet.
 *
 * \since This struct is available since SDL 3.2.0.
  }
  PPSDL_PenAxisEvent = ^PSDL_PenAxisEvent;
  PSDL_PenAxisEvent = ^TSDL_PenAxisEvent;
  TSDL_PenAxisEvent = record
      type_: TSDL_EventType;           {*< SDL_EVENT_PEN_AXIS  }
      reserved: cuint32;
      timestamp: cuint64;              {*< In nanoseconds, populated using SDL_GetTicksNS()  }
      windowID: TSDL_WindowID;         {*< The window with pen focus, if any  }
      which: TSDL_PenID;               {*< The pen instance id  }
      pen_state: TSDL_PenInputFlags;   {*< Complete pen input state at time of event  }
      x: cfloat;                       {*< X coordinate, relative to window  }
      y: cfloat;                       {*< Y coordinate, relative to window  }
      axis: TSDL_PenAxis;              {*< Axis that has changed  }
      value: cfloat;                   {*< New value of axis  }
    end;

{*
 * An event used to drop text or request a file open by the system
 * (event.drop.*)
 *
 * \since This struct is available since SDL 3.2.0.
  }
  PPSDL_DropEvent = ^PSDL_DropEvent;
  PSDL_DropEvent = ^TSDL_DropEvent;
  TSDL_DropEvent = record
      type_: TSDL_EventType;    {*< SDL_EVENT_DROP_BEGIN or SDL_EVENT_DROP_FILE or SDL_EVENT_DROP_TEXT or SDL_EVENT_DROP_COMPLETE or SDL_EVENT_DROP_POSITION  }
      reserved: cuint32;
      timestamp: cuint64;       {*< In nanoseconds, populated using SDL_GetTicksNS()  }
      windowID: TSDL_WindowID;  {*< The window that was dropped on, if any  }
      x: cfloat;                {*< X coordinate, relative to window (not on begin)  }
      y: cfloat;                {*< Y coordinate, relative to window (not on begin)  }
      source: PAnsiChar;        {*< The source app that sent this drop event, or nil if that isn't available  }
      data: PAnsiChar;          {*< The text for SDL_EVENT_DROP_TEXT and the file name for SDL_EVENT_DROP_FILE, nil for other events  }
    end;

{*
 * An event triggered when the clipboard contents have changed
 * (event.clipboard.*)
 *
 * \since This struct is available since SDL 3.2.0.
  }
  PPSDL_ClipboardEvent = ^PSDL_ClipboardEvent;
  PSDL_ClipboardEvent = ^TSDL_ClipboardEvent;
  TSDL_ClipboardEvent = record
      type_: TSDL_EventType;  {*< SDL_EVENT_CLIPBOARD_UPDATE  }
      reserved: cuint32;
      timestamp: cuint64;     {*< In nanoseconds, populated using SDL_GetTicksNS()  }
      owner: Boolean;         {*< are we owning the clipboard (internal update)  }
      n_mime_types: cint32;   {*< number of mime types  }
      mime_types: ^PAnsiChar; {*< current mime types  }
    end;

{*
 * Sensor event structure (event.sensor.*)
 *
 * \since This struct is available since SDL 3.2.0.
  }
  PPSDL_SensorEvent = ^PSDL_SensorEvent;
  PSDL_SensorEvent = ^TSDL_SensorEvent;
  TSDL_SensorEvent = record
      type_: TSDL_EventType;         {*< SDL_EVENT_SENSOR_UPDATE  }
      reserved: cuint32;
      timestamp: cuint64;            {*< In nanoseconds, populated using SDL_GetTicksNS()  }
      which: TSDL_SensorID;          {*< The instance ID of the sensor  }
      data: array[0..5] of cfloat;   {*< Up to 6 values from the sensor - additional values can be queried using SDL_GetSensorData()  }
      sensor_timestamp: cuint64;     {*< The timestamp of the sensor reading in nanoseconds, not necessarily synchronized with the system clock  }
    end;

{*
 * The "quit requested" event
 *
 * \since This struct is available since SDL 3.2.0.
  }
  PPSDL_QuitEvent = ^PSDL_QuitEvent;
  PSDL_QuitEvent = ^TSDL_QuitEvent;
  TSDL_QuitEvent = record
      type_: TSDL_EventType;  {*< SDL_EVENT_QUIT  }
      reserved: cuint32;
      timestamp: cuint64;     {*< In nanoseconds, populated using SDL_GetTicksNS()  }
    end;

{*
 * A user-defined event type (event.user.*)
 *
 * This event is unique; it is never created by SDL, but only by the
 * application. The event can be pushed onto the event queue using
 * SDL_PushEvent(). The contents of the structure members are completely up to
 * the programmer; the only requirement is that '''type''' is a value obtained
 * from SDL_RegisterEvents().
 *
 * \since This struct is available since SDL 3.2.0.
  }
  PPSDL_UserEvent = ^PSDL_UserEvent;
  PSDL_UserEvent = ^TSDL_UserEvent;
  TSDL_UserEvent = record
      type_: cuint32;           {*< SDL_EVENT_USER through SDL_EVENT_LAST, Uint32 because these are not in the SDL_EventType enumeration  }
      reserved: cuint32;
      timestamp: cuint64;       {*< In nanoseconds, populated using SDL_GetTicksNS()  }
      windowID: TSDL_WindowID;  {*< The associated window if any  }
      code: cint32;             {*< User defined event code  }
      data1: Pointer;           {*< User defined data Pointer  }
      data2: Pointer;           {*< User defined data Pointer  }
    end;

{*
 * The structure for all events in SDL.
 *
 * The SDL_Event structure is the core of all event handling in SDL. SDL_Event
 * is a union of all event structures used in SDL.
 *
 * \since This struct is available since SDL 3.2.0.
  }
type
  PPSDL_Event = ^PSDL_Event;
  PSDL_Event = ^TSDL_Event;
  TSDL_Event = record
      case Integer of
        0: (type_: cuint32);                                     {*< Event type, shared with all events, Uint32 to cover user events which are not in the SDL_EventType enumeration  }
        1: (common: TSDL_CommonEvent);                           {*< Common event data  }
        2: (display: TSDL_DisplayEvent);                         {*< Display event data  }
        3: (window: TSDL_WindowEvent);                           {*< Window event data  }
        4: (kdevice: TSDL_KeyboardDeviceEvent);                  {*< Keyboard device change event data  }
        5: (key: TSDL_KeyboardEvent);                            {*< Keyboard event data  }
        6: (edit: TSDL_TextEditingEvent);                        {*< Text editing event data  }
        7: (edit_candidates: TSDL_TextEditingCandidatesEvent);   {*< Text editing candidates event data  }
        8: (text: TSDL_TextInputEvent);                          {*< Text input event data  }
        9: (mdevice: TSDL_MouseDeviceEvent);                     {*< Mouse device change event data  }
        10: (motion: TSDL_MouseMotionEvent);                     {*< Mouse motion event data  }
        11: (button: TSDL_MouseButtonEvent);                     {*< Mouse button event data  }
        12: (wheel: TSDL_MouseWheelEvent);                       {*< Mouse wheel event data  }
        13: (jdevice: TSDL_JoyDeviceEvent);                      {*< Joystick device change event data  }
        14: (jaxis: TSDL_JoyAxisEvent);                          {*< Joystick axis event data  }
        15: (jball: TSDL_JoyBallEvent);                          {*< Joystick ball event data  }
        16: (jhat: TSDL_JoyHatEvent);                            {*< Joystick hat event data  }
        17: (jbutton: TSDL_JoyButtonEvent);                      {*< Joystick button event data  }
        18: (jbattery: TSDL_JoyBatteryEvent);                    {*< Joystick battery event data  }
        19: (gdevice: TSDL_GamepadDeviceEvent);                  {*< Gamepad device event data  }
        20: (gaxis: TSDL_GamepadAxisEvent);                      {*< Gamepad axis event data  }
        21: (gbutton: TSDL_GamepadButtonEvent);                  {*< Gamepad button event data  }
        22: (gtouchpad: TSDL_GamepadTouchpadEvent);              {*< Gamepad touchpad event data  }
        23: (gsensor: TSDL_GamepadSensorEvent);                  {*< Gamepad sensor event data  }
        24: (adevice: TSDL_AudioDeviceEvent);                    {*< Audio device event data  }
        25: (cdevice: TSDL_CameraDeviceEvent);                   {*< Camera device event data  }
        26: (sensor: TSDL_SensorEvent);                          {*< Sensor event data  }
        27: (quit: TSDL_QuitEvent);                              {*< Quit request event data  }
        28: (user: TSDL_UserEvent);                              {*< Custom event data  }
        29: (tfinger: TSDL_TouchFingerEvent);                    {*< Touch finger event data  }
        30: (pinch: TSDL_PinchFingerEvent);                      {   Pinch event data }
        31: (pproximity: TSDL_PenProximityEvent);                {*< Pen proximity event data  }
        32: (ptouch: TSDL_PenTouchEvent);                        {*< Pen tip touching event data  }
        33: (pmotion: TSDL_PenMotionEvent);                      {*< Pen motion event data  }
        34: (pbutton: TSDL_PenButtonEvent);                      {*< Pen button event data  }
        35: (paxis: TSDL_PenAxisEvent);                          {*< Pen axis event data  }
        36: (render: TSDL_RenderEvent);                          {*< Render event data  }
        37: (drop: TSDL_DropEvent);                              {*< Drag and drop event data  }
        38: (clipboard: TSDL_ClipboardEvent);                    {*< Clipboard event data  }

        { This is necessary for ABI compatibility between Visual C++ and GCC.
               Visual C++ will respect the push pack pragma and use 52 bytes (size of
               SDL_TextEditingEvent, the largest structure for 32-bit and 64-bit
               architectures) for this union, and GCC will use the alignment of the
               largest datatype within the union, which is 8 bytes on 64-bit
               architectures.

               So... we'll add padding to force the size to be the same for both.

               On architectures where pointers are 16 bytes, this needs rounding up to
               the next multiple of 16, 64, and on architectures where pointers are
               even larger the size of SDL_UserEvent will dominate as being 3 pointers.
             }
        39: (padding: array[0..127] of cuint8);
      end;

{ #todo : SDL3-for-Pascal: Translation of SDL_COMPILE_TIME_ASSERT necessary? Looks like an internal test function. }
{ Make sure we haven't broken binary compatibility  }
{ C code: SDL_COMPILE_TIME_ASSERT(SDL_Event, sizeof(SDL_Event) == sizeof(((SDL_Event *)NULL)->padding)); }

{ Function prototypes  }

{*
 * Pump the event loop, gathering events from the input devices.
 *
 * This function updates the event queue and internal input device state.
 *
 * SDL_PumpEvents() gathers all the pending input information from devices and
 * places it in the event queue. Without calls to SDL_PumpEvents() no events
 * would ever be placed on the queue. Often the need for calls to
 * SDL_PumpEvents() is hidden from the user since SDL_PollEvent() and
 * SDL_WaitEvent() implicitly call SDL_PumpEvents(). However, if you are not
 * polling or waiting for events (e.g. you are filtering them), then you must
 * call SDL_PumpEvents() to force an event queue update.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_PollEvent
 * \sa SDL_WaitEvent
  }
procedure SDL_PumpEvents; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_PumpEvents' {$ENDIF} {$ENDIF};

{*
 * The type of action to request from SDL_PeepEvents().
 *
 * \since This enum is available since SDL 3.2.0.
  }
type
  PPSDL_EventAction = ^PSDL_EventAction;
  PSDL_EventAction = ^TSDL_EventAction;
  TSDL_EventAction = type Integer;
  const
    SDL_ADDEVENT  = TSDL_EventAction(0);   {*< Add events to the back of the queue.  }
    SDL_PEEKEVENT  = TSDL_EventAction(1);  {*< Check but don't remove events from the queue front.  }
    SDL_GETEVENT  = TSDL_EventAction(2);   {*< Retrieve/remove events from the front of the queue.  }

{*
 * Check the event queue for messages and optionally return them.
 *
 * `action` may be any of the following:
 *
 * - `SDL_ADDEVENT`: up to `numevents` events will be added to the back of the
 *   event queue.
 * - `SDL_PEEKEVENT`: `numevents` events at the front of the event queue,
 *   within the specified minimum and maximum type, will be returned to the
 *   caller and will _not_ be removed from the queue. If you pass nil for
 *   `events`, then `numevents` is ignored and the total number of matching
 *   events will be returned.
 * - `SDL_GETEVENT`: up to `numevents` events at the front of the event queue,
 *   within the specified minimum and maximum type, will be returned to the
 *   caller and will be removed from the queue.
 *
 * You may have to call SDL_PumpEvents() before calling this function.
 * Otherwise, the events may not be ready to be filtered when you call
 * SDL_PeepEvents().
 *
 * \param events destination buffer for the retrieved events, may be nil to
 *               leave the events in the queue and return the number of events
 *               that would have been stored.
 * \param numevents if action is SDL_ADDEVENT, the number of events to add
 *                  back to the event queue; if action is SDL_PEEKEVENT or
 *                  SDL_GETEVENT, the maximum number of events to retrieve.
 * \param action action to take; see [Remarks](#remarks) for details.
 * \param minType minimum value of the event type to be considered;
 *                SDL_EVENT_FIRST is a safe choice.
 * \param maxType maximum value of the event type to be considered;
 *                SDL_EVENT_LAST is a safe choice.
 * \returns the number of events actually stored or -1 on failure; call
 *          SDL_GetError() for more information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_PollEvent
 * \sa SDL_PumpEvents
 * \sa SDL_PushEvent
  }
function SDL_PeepEvents(events: PSDL_Event; numevents: cint; action: TSDL_EventAction; minType: cuint32; maxType: cuint32): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_PeepEvents' {$ENDIF} {$ENDIF};

{*
 * Check for the existence of a certain event type in the event queue.
 *
 * If you need to check for a range of event types, use SDL_HasEvents()
 * instead.
 *
 * \param type the type of event to be queried; see SDL_EventType for details.
 * \returns true if events matching `type` are present, or false if events
 *          matching `type` are not present.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_HasEvents
  }
function SDL_HasEvent(type_: cuint32): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_HasEvent' {$ENDIF} {$ENDIF};

{*
 * Check for the existence of certain event types in the event queue.
 *
 * If you need to check for a single event type, use SDL_HasEvent() instead.
 *
 * \param minType the low end of event type to be queried, inclusive; see
 *                SDL_EventType for details.
 * \param maxType the high end of event type to be queried, inclusive; see
 *                SDL_EventType for details.
 * \returns true if events with type >= `minType` and <= `maxType` are
 *          present, or false if not.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_HasEvents
  }
function SDL_HasEvents(minType: cuint32; maxType: cuint32): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_HasEvents' {$ENDIF} {$ENDIF};

{*
 * Clear events of a specific type from the event queue.
 *
 * This will unconditionally remove any events from the queue that match
 * `type`. If you need to remove a range of event types, use SDL_FlushEvents()
 * instead.
 *
 * It's also normal to just ignore events you don't care about in your event
 * loop without calling this function.
 *
 * This function only affects currently queued events. If you want to make
 * sure that all pending OS events are flushed, you can call SDL_PumpEvents()
 * on the main thread immediately before the flush call.
 *
 * If you have user events with custom data that needs to be freed, you should
 * use SDL_PeepEvents() to remove and clean up those events before calling
 * this function.
 *
 * \param type the type of event to be cleared; see SDL_EventType for details.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_FlushEvents
  }
procedure SDL_FlushEvent(type_: cuint32); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_FlushEvent' {$ENDIF} {$ENDIF};

{*
 * Clear events of a range of types from the event queue.
 *
 * This will unconditionally remove any events from the queue that are in the
 * range of `minType` to `maxType`, inclusive. If you need to remove a single
 * event type, use SDL_FlushEvent() instead.
 *
 * It's also normal to just ignore events you don't care about in your event
 * loop without calling this function.
 *
 * This function only affects currently queued events. If you want to make
 * sure that all pending OS events are flushed, you can call SDL_PumpEvents()
 * on the main thread immediately before the flush call.
 *
 * \param minType the low end of event type to be cleared, inclusive; see
 *                SDL_EventType for details.
 * \param maxType the high end of event type to be cleared, inclusive; see
 *                SDL_EventType for details.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_FlushEvent
  }
procedure SDL_FlushEvents(minType: cuint32; maxType: cuint32); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_FlushEvents' {$ENDIF} {$ENDIF};

{*
 * Poll for currently pending events.
 *
 * If `event` is not NULL, the next event is removed from the queue and stored
 * in the SDL_Event structure pointed to by `event`.
 *
 * If `event` is NULL, it simply returns true if there is an event in the
 * queue, but will not remove it from the queue.
 *
 * As this function may implicitly call SDL_PumpEvents(), you can only call
 * this function in the thread that initialized the video subsystem.
 *
 * SDL_PollEvent() is the favored way of receiving system events since it can
 * be done from the main loop and does not suspend the main loop while waiting
 * on an event to be posted.
 *
 * The common practice is to fully process the event queue once every frame,
 * usually as a first step before updating the game's state:
 *
 * ```c
 * while (game_is_still_running)
 *     SDL_Event event;
 *     while (SDL_PollEvent(&event))   // poll until all events are handled!
 *         // decide what to do with this event.
 *
 *
 *     // update game state, draw the current frame
 *
 * ```
 *
 * Note that Windows (and possibly other platforms) has a quirk about how it
 * handles events while dragging/resizing a window, which can cause this
 * function to block for significant amounts of time. Technical explanations
 * and solutions are discussed on the wiki:
 *
 * https://wiki.libsdl.org/SDL3/AppFreezeDuringDrag
 *
 * \param event the SDL_Event structure to be filled with the next event from
 *              the queue, or nil.
 * \returns true if this got an event or false if there are none available.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_PushEvent
 * \sa SDL_WaitEvent
 * \sa SDL_WaitEventTimeout
  }
function SDL_PollEvent(event: PSDL_Event): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_PollEvent' {$ENDIF} {$ENDIF};

{*
 * Wait indefinitely for the next available event.
 *
 * If `event` is not nil, the next event is removed from the queue and stored
 * in the SDL_Event structure pointed to by `event`.
 *
 * As this function may implicitly call SDL_PumpEvents(), you can only call
 * this function in the thread that initialized the video subsystem.
 *
 * \param event the SDL_Event structure to be filled in with the next event
 *              from the queue, or nil.
 * \returns true on success or false if there was an error while waiting for
 *          events; call SDL_GetError() for more information.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_PollEvent
 * \sa SDL_PushEvent
 * \sa SDL_WaitEventTimeout
  }
function SDL_WaitEvent(event: PSDL_Event): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_WaitEvent' {$ENDIF} {$ENDIF};

{*
 * Wait until the specified timeout (in milliseconds) for the next available
 * event.
 *
 * If `event` is not nil, the next event is removed from the queue and stored
 * in the SDL_Event structure pointed to by `event`.
 *
 * As this function may implicitly call SDL_PumpEvents(), you can only call
 * this function in the thread that initialized the video subsystem.
 *
 * The timeout is not guaranteed, the actual wait time could be longer due to
 * system scheduling.
 *
 * \param event the SDL_Event structure to be filled in with the next event
 *              from the queue, or nil.
 * \param timeoutMS the maximum number of milliseconds to wait for the next
 *                  available event.
 * \returns true if this got an event or false if the timeout elapsed without
 *          any events available.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_PollEvent
 * \sa SDL_PushEvent
 * \sa SDL_WaitEvent
  }
function SDL_WaitEventTimeout(event: PSDL_Event; timeoutMS: cint32): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_WaitEventTimeout' {$ENDIF} {$ENDIF};

{*
 * Add an event to the event queue.
 *
 * The event queue can actually be used as a two way communication channel.
 * Not only can events be read from the queue, but the user can also push
 * their own events onto it. `event` is a Pointer to the event structure you
 * wish to push onto the queue. The event is copied into the queue, and the
 * caller may dispose of the memory pointed to after SDL_PushEvent() returns.
 *
 * Note: Pushing device input events onto the queue doesn't modify the state
 * of the device within SDL.
 *
 * Note: Events pushed onto the queue with SDL_PushEvent() get passed through
 * the event filter but events added with SDL_PeepEvents() do not.
 *
 * For pushing application-specific events, please use SDL_RegisterEvents() to
 * get an event type that does not conflict with other code that also wants
 * its own custom event types.
 *
 * \param event the SDL_Event to be added to the queue.
 * \returns true on success, false if the event was filtered or on failure;
 *          call SDL_GetError() for more information. A common reason for
 *          error is the event queue being full.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_PeepEvents
 * \sa SDL_PollEvent
 * \sa SDL_RegisterEvents
  }
function SDL_PushEvent(event: PSDL_Event): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_PushEvent' {$ENDIF} {$ENDIF};

{*
 * A function Pointer used for callbacks that watch the event queue.
 *
 * \param userdata what was passed as `userdata` to SDL_SetEventFilter() or
 *                 SDL_AddEventWatch, etc.
 * \param event the event that triggered the callback.
 * \returns true to permit event to be added to the queue, and false to
 *          disallow it. When used with SDL_AddEventWatch, the return value is
 *          ignored.
 *
 * \threadsafety SDL may call this callback at any time from any thread; the
 *               application is responsible for locking resources the callback
 *               touches that need to be protected.
 *
 * \since This datatype is available since SDL 3.1.3.
 *
 * \sa SDL_SetEventFilter
 * \sa SDL_AddEventWatch
  }
type
  PSDL_EventFilter = ^TSDL_EventFilter;
  TSDL_EventFilter = function(userdata: Pointer; event: PSDL_Event): Boolean; cdecl;

{*
 * Set up a filter to process all events before they are added to the internal
 * event queue.
 *
 * If you just want to see events without modifying them or preventing them
 * from being queued, you should use SDL_AddEventWatch() instead.
 *
 * If the filter function returns true when called, then the event will be
 * added to the internal queue. If it returns false, then the event will be
 * dropped from the queue, but the internal state will still be updated. This
 * allows selective filtering of dynamically arriving events.
 *
 * **WARNING**: Be very careful of what you do in the event filter function,
 * as it may run in a different thread! The exception is handling of
 * SDL_EVENT_WINDOW_EXPOSED, which is guaranteed to be sent from the OS on the
 * main thread and you are expected to redraw your window in response to this
 * event.
 *
 * On platforms that support it, if the quit event is generated by an
 * interrupt signal (e.g. pressing Ctrl-C), it will be delivered to the
 * application at the next event poll.
 *
 * Note: Disabled events never make it to the event filter function; see
 * SDL_SetEventEnabled().
 *
 * Note: Events pushed onto the queue with SDL_PushEvent() get passed through
 * the event filter, but events pushed onto the queue with SDL_PeepEvents() do
 * not.
 *
 * \param filter a function to call when an event happens.
 * \param userdata a Pointer that is passed to `filter`.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_AddEventWatch
 * \sa SDL_SetEventEnabled
 * \sa SDL_GetEventFilter
 * \sa SDL_PeepEvents
 * \sa SDL_PushEvent
  }
procedure SDL_SetEventFilter(filter: TSDL_EventFilter; userdata: Pointer); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetEventFilter' {$ENDIF} {$ENDIF};

{*
 * Query the current event filter.
 *
 * This function can be used to "chain" filters, by saving the existing filter
 * before replacing it with a function that will call that saved filter.
 *
 * \param filter the current callback function will be stored here.
 * \param userdata the Pointer that is passed to the current event filter will
 *                 be stored here.
 * \returns true on success or false if there is no event filter set.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetEventFilter
  }
function SDL_GetEventFilter(filter: PSDL_EventFilter; userdata: PPointer): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetEventFilter' {$ENDIF} {$ENDIF};

{*
 * Add a callback to be triggered when an event is added to the event queue.
 *
 * `filter` will be called when an event happens, and its return value is
 * ignored.
 *
 * **WARNING**: Be very careful of what you do in the event filter function,
 * as it may run in a different thread!
 *
 * If the quit event is generated by a signal (e.g. SIGINT), it will bypass
 * the internal queue and be delivered to the watch callback immediately, and
 * arrive at the next event poll.
 *
 * Note: the callback is called for events posted by the user through
 * SDL_PushEvent(), but not for disabled events, nor for events by a filter
 * callback set with SDL_SetEventFilter(), nor for events posted by the user
 * through SDL_PeepEvents().
 *
 * \param filter an SDL_EventFilter function to call when an event happens.
 * \param userdata a Pointer that is passed to `filter`.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_RemoveEventWatch
 * \sa SDL_SetEventFilter
  }
function SDL_AddEventWatch(filter: TSDL_EventFilter; userdata: Pointer): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_AddEventWatch' {$ENDIF} {$ENDIF};

{*
 * Remove an event watch callback added with SDL_AddEventWatch().
 *
 * This function takes the same input as SDL_AddEventWatch() to identify and
 * delete the corresponding callback.
 *
 * \param filter the function originally passed to SDL_AddEventWatch().
 * \param userdata the Pointer originally passed to SDL_AddEventWatch().
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_AddEventWatch
  }
procedure SDL_RemoveEventWatch(filter: TSDL_EventFilter; userdata: Pointer); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_RemoveEventWatch' {$ENDIF} {$ENDIF};

{*
 * Run a specific filter function on the current event queue, removing any
 * events for which the filter returns false.
 *
 * See SDL_SetEventFilter() for more information. Unlike SDL_SetEventFilter(),
 * this function does not change the filter permanently, it only uses the
 * supplied filter until this function returns.
 *
 * \param filter the SDL_EventFilter function to call when an event happens.
 * \param userdata a Pointer that is passed to `filter`.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetEventFilter
 * \sa SDL_SetEventFilter
  }
procedure SDL_FilterEvents(filter: TSDL_EventFilter; userdata: Pointer); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_FilterEvents' {$ENDIF} {$ENDIF};

{*
 * Set the state of processing events by type.
 *
 * \param type the type of event; see SDL_EventType for details.
 * \param enabled whether to process the event or not.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_EventEnabled
  }
procedure SDL_SetEventEnabled(type_: cuint32; enabled: Boolean); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetEventEnabled' {$ENDIF} {$ENDIF};

{*
 * Query the state of processing events by type.
 *
 * \param type the type of event; see SDL_EventType for details.
 * \returns true if the event is being processed, false otherwise.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_SetEventEnabled
  }
function SDL_EventEnabled(type_: cuint32): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_EventEnabled' {$ENDIF} {$ENDIF};

{*
 * Allocate a set of user-defined events, and return the beginning event
 * number for that set of events.
 *
 * \param numevents the number of events to be allocated.
 * \returns the beginning event number, or 0 if numevents is invalid or if
 *          there are not enough user-defined events left.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_PushEvent
  }
function SDL_RegisterEvents(numevents: cint): cuint32; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_RegisterEvents' {$ENDIF} {$ENDIF};

{*
 * Get window associated with an event.
 *
 * \param event an event containing a `windowID`.
 * \returns the associated window on success or nil if there is none.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_PollEvent
 * \sa SDL_WaitEvent
 * \sa SDL_WaitEventTimeout
  }
function SDL_GetWindowFromEvent(event: PSDL_Event): PSDL_Window; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetWindowFromEvent' {$ENDIF} {$ENDIF};

{*
 * Generate an English description of an event.
 *
 * This will fill `buf` with a null-terminated string that might look
 * something like this:
 *
 * ```
 * SDL_EVENT_MOUSE_MOTION (timestamp=1140256324 windowid=2 which=0 state=0 x=492.99 y=139.09 xrel=52 yrel=6)
 * ```
 *
 * The exact format of the string is not guaranteed; it is intended for
 * logging purposes, to be read by a human, and not parsed by a computer.
 *
 * The returned value follows the same rules as SDL_snprintf(): `buf` will
 * always be nil-terminated (unless `buflen` is zero), and will be truncated
 * if `buflen` is too small. The return code is the number of bytes needed for
 * the complete string, not counting the nil-terminator, whether the string
 * was truncated or not. Unlike SDL_snprintf(), though, this function never
 * returns -1.
 *
 * \param event an event to describe. May be nil.
 * \param buf the buffer to fill with the description string. May be nil.
 * \param buflen the maximum bytes that can be written to `buf`.
 * \returns number of bytes needed for the full string, not counting the
 *          null-terminator byte.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.4.0.
  }
function SDL_GetEventDescription(event: PSDL_Event; buf: PAnsiChar; buflen: cint): cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetEventDescription' {$ENDIF} {$ENDIF};

