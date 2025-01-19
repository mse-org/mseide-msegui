unit sdl4msegui;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes,msesystypes,mseguiglob,ctypes,msekeyboard,msesysutils,msegraphutils;
{$i sdl2_types.inc}

const
  SDL_INIT_TIMER = $00000001;
  SDL_INIT_AUDIO = $00000010;
  SDL_INIT_VIDEO = $00000020;
  SDL_INIT_CDROM = $00000100;
  SDL_INIT_JOYSTICK = $00000200;
  SDL_INIT_NOPARACHUTE = $00100000;
  SDL_INIT_EVENTTHREAD = $01000000;
  SDL_INIT_EVERYTHING = $0000FFFF;

type
 SDL_Rect = record
  x,y: integer;
  w,h: integer;
 end;
 PSDL_Rect = ^SDL_Rect;
 
 SDL_Point = record
  x: integer;
  y: integer;
 end;
 PSDL_Point = ^SDL_Point;
 
 SDL_Color = record
  r: byte;
  g: byte;
  b: byte;
  unused: byte;
 end;
 PSDL_Color = ^SDL_Color;

 SDL_Palette = record
  ncolors: integer;
  colors: PSDL_Color;
  version: Cardinal;
  refcount: integer;
 end;
 PSDL_Palette = ^SDL_Palette;

 PSDL_PixelFormat = ^SDL_PixelFormat;
 SDL_PixelFormat = record
  format: Cardinal;
  palette: PSDL_Palette;
  BitsPerPixel: byte;
  BytesPerPixel: byte;
  padding: word;
  Rmask, Gmask, Bmask, Amask: Cardinal;
  Rloss, Gloss, Bloss, Aloss: byte;
  Rshift, Gshift, Bshift, Ashift: byte;
  refcount: integer;
  next: PSDL_PixelFormat;
 end;

 SDL_Surface = record
  flags: Cardinal; // Read-only
  format: PSDL_PixelFormat; // Read-only
  w, h: Integer; // Read-only
  pitch: integer; // Read-only
  pixels: Pointer; // Read-write
  offset: Integer; // Private
  hwdata: Pointer; //TPrivate_hwdata;  Hardware-specific surface info
  // clipping information:
  clip_rect: SDL_Rect; // Read-only
  unused1: Cardinal; // for binary compatibility
  // Allow recursive locks
  locked: Cardinal; // Private
  // info for fast blit mapping to other surfaces
  Blitmap: Pointer; // PSDL_BlitMap; //   Private
  // format version, bumped at every change to invalidate blit maps
  format_version: Cardinal; // Private
  refcount: Integer;
 end;
 CSDL_Surface = ^SDL_Surface;
 PSDL_Surface = pixmapty;


 //window type

 {SDL_Window = record
  magic: pointer;
  id: Uint32;
  title: pchar;
  x, y: integer;
  w, h: integer;
  flags: Uint32;
  //* Stored position and size for windowed mode */
  windowed: SDL_Rect;
  SDL_DisplayMode fullscreen_mode;
  
  float brightness;
  Uint16 *gamma;
  Uint16 *saved_gamma;        /* (just offset into gamma) */

  SDL_Surface *surface;
  SDL_bool surface_valid;

  SDL_WindowShaper *shaper;

  SDL_WindowUserData *data;

  void *driverdata;

  SDL_Window *prev;
  SDL_Window *next;
 end;}
 
 // file type

 TStdio = record
   autoclose: Integer;
  // FILE * is only defined in Kylix so we use a simple Pointer
   fp: Pointer;
 end;

 TMem = record
   base: PUInt8;
   here: PUInt8;
   stop: PUInt8;
 end;

 TUnknown = record
   data1: Pointer;
 end;

 // first declare the pointer type
 PSDL_RWops = ^TSDL_RWops;
 // now the pointer to function types
 TSeek = function( context: PSDL_RWops; offset: Integer; whence: Integer ): Integer; cdecl;
 TRead = function( context: PSDL_RWops; Ptr: Pointer; size: Integer; maxnum : Integer ): Integer;  cdecl;
 TWrite = function( context: PSDL_RWops; Ptr: Pointer; size: Integer; num: Integer ): Integer; cdecl;
 TClose = function( context: PSDL_RWops ): Integer; cdecl;
 // the variant record itself
 // Note : TSDL_RWops need to be updated to current revision
 TSDL_RWops = record
   seek: TSeek;
   read: TRead;
   write: TWrite;
   close: TClose;
   // a keyword as name is not allowed
   type_: UInt32;
   // be warned! structure alignment may arise at this point
   case Integer of
     0: (stdio: TStdio);
     1: (mem: TMem);
     2: (unknown: TUnknown);
 end;

 SDL_RWops = TSDL_RWops;

 
 {$I sdl_EventConsts.inc}
 
type
 
 SDL_scancode = 0..SDL_NUM_SCANCODES;

const
 SDL_WINDOWEVENT_NONE = 0;           // Never used */
 SDL_WINDOWEVENT_SHOWN = 1;          // Window has been shown */
 SDL_WINDOWEVENT_HIDDEN = 2;         // Window has been hidden */
 SDL_WINDOWEVENT_EXPOSED = 3;        // Window has been exposed and should be redrawn */
 SDL_WINDOWEVENT_MOVED = 4;          // Window has been moved to data1, data2 
 SDL_WINDOWEVENT_RESIZED = 5;        // Window has been resized to data1xdata2 */
 SDL_WINDOWEVENT_SIZE_CHANGED = 6;   // The window size has changed, either as a result of an API call or through the system or user changing the window size. */
 SDL_WINDOWEVENT_MINIMIZED = 7;      // Window has been minimized */
 SDL_WINDOWEVENT_MAXIMIZED = 8;      // Window has been maximized */
 SDL_WINDOWEVENT_RESTORED = 9;       // Window has been restored to normal size and position */
 SDL_WINDOWEVENT_ENTER = 10;          // Window has gained mouse focus */
 SDL_WINDOWEVENT_LEAVE = 11;          // Window has lost mouse focus */
 SDL_WINDOWEVENT_FOCUS_GAINED = 12;   // Window has gained keyboard focus */
 SDL_WINDOWEVENT_FOCUS_LOST = 13;     // Window has lost keyboard focus */
 SDL_WINDOWEVENT_CLOSE = 14;          // The window manager requests that the window be closed */
 
 TEXT_SIZE = 32;
 
 // mouse button state
 SDL_BUTTON_LMASK = (1 << ((1)-1));
 SDL_BUTTON_MMASK = (1 << ((2)-1));
 SDL_BUTTON_RMASK = (1 << ((3)-1));
 
type
 SDL_KeyCode = longword;
 SDL_KeyMod = longword;
{*
 *  \brief The SDL keysym structure, used in key events.
 }
 SDL_Keysym = record
  scancode: SDL_scancode; //**< SDL physical key code - see ::SDL_Scancode for details */
  sym: SDL_KeyCode; //**< SDL virtual key code - see ::SDL_Keycode for details */
  mods: SDL_KeyMod; //**< current key modifiers */
  unicode: cardinal; //**< \deprecated use SDL_TextInputEvent instead */ 
 end;

{*
 *  \brief Window state change event data (event.window.*)
 }
 SDL_Window_Event = record
  type_: cardinal;
  timestamp: cardinal;
  window: cardinal;
  event: byte; //**< ::SDL_WindowEventID */
  padding1: byte;
  padding2: byte;
  Data1: integer;
  Data2: integer;
 end;

{*
 *  \brief Keyboard button event structure (event.key.*)
 *}
 SDL_KeyboardEvent = record
  type_: cardinal; //**< ::SDL_KEYDOWN or ::SDL_KEYUP */
  timestamp: cardinal;
  window: cardinal;
  state: byte; //**< ::SDL_PRESSED or ::SDL_RELEASED */
  repeat_: byte; //**< Non-zero if this is a key repeat */
  padding2: byte;
  padding3: byte;
  keysym: SDL_Keysym; //**< The key that was pressed or released */       
 end;

{*
 *  \brief Keyboard text editing event structure (event.edit.*)
 }
 SDL_TextEditingEvent = record
  type_: cardinal;
  timestamp: cardinal;
  window: cardinal;
  text: array[0..TEXT_SIZE - 1] of AnsiChar; //**< The editing text */
  start: integer; //**< The start cursor of selected editing text */
  length: integer; //**< The length of selected editing text */
 end;

 SDL_TextInputEvent = record
  type_: cardinal;
  timestamp: cardinal;
  window: cardinal;
  text: array[0..TEXT_SIZE - 1] of AnsiChar;
 end;

{*
 *  \brief Mouse motion event structure (event.motion.*)
 }
 SDL_MouseMotionEvent = record
  type_: cardinal;
  timestamp: cardinal;
  window: cardinal;
  state: byte; //**< The current button state */
  padding1: byte;
  padding2: byte;
  padding3: byte;
  x: integer; //**< X coordinate, relative to window */
  y: integer; //**< Y coordinate, relative to window */
  xrel: integer; //**< The relative motion in the X direction */
  yrel: integer; //**< The relative motion in the Y direction */
 end;

{*
 *  \brief Mouse button event structure (event.button.*)
 }
 SDL_MouseButtonEvent = record
  type_: cardinal; //**< ::SDL_MOUSEBUTTONDOWN or ::SDL_MOUSEBUTTONUP */
  timestamp: cardinal;
  window: cardinal;
  button: byte; //**< The mouse button index */
  state: byte; //**< ::SDL_PRESSED or ::SDL_RELEASED */
  padding1: byte;
  padding2: byte;
  x: integer; //**< X coordinate, relative to window */
  y: integer; //**< Y coordinate, relative to window */  
 end;

{*
 *  \brief Mouse wheel event structure (event.wheel.*)
 }
  SDL_MouseWheelEvent = record
   type_ : cardinal;        //**< ::SDL_MOUSEWHEEL */
   timestamp : cardinal;
   window : winidty;        //**< The window with mouse focus, if any */
   x: integer;              //**< The amount scrolled horizontally */
   y: integer;              //**< The amount scrolled vertically */
  end;

{*
 *  \brief Joystick axis motion event structure (event.jaxis.*)
 }
  SDL_JoyAxisEvent = record
   type_: cardinal; //**< ::SDL_JOYAXISMOTION */
   timestamp : cardinal;
   which: byte; //**< The joystick device index */
   axis: byte; //**< The joystick axis index */
   padding1: byte;
   padding2: byte;
   value: integer; //**< The axis value (range: -32768 to 32767) */
  end;

{*
 *  \brief Joystick trackball motion event structure (event.jball.*)
 }
  SDL_JoyBallEvent = record
   type_: cardinal;
   which: byte;
   ball: byte;
   pad: word;
   xrel: integer;
   yrel: integer;
  end;

 SDL_HatPosition = set of (sdlhUp, sdlhRight, sdlhDown, sdlhLeft);

{*
 *  \brief Joystick hat position change event structure (event.jhat.*)
 }
  SDL_JoyHatEvent = record
   type_: cardinal;
   which: byte;
   hat: byte;
   value: SDL_HatPosition;
   pad: byte;
  end;

{*
 *  \brief Joystick button event structure (event.jbutton.*)
 }
  SDL_JoyButtonEvent = record
   type_: cardinal;
   which: byte;
   buton: byte;
   stte: byte;
   pad: byte;
  end;

  SDL_TouchFingerEvent = record
   type_ : cardinal;        //**< ::SDL_FINGERMOTION OR SDL_FINGERDOWN OR SDL_FINGERUP*/
   timestamp: cardinal;
   window: cardinal;    //**< The window with mouse focus, if any */
   touchID: cuint64;        //**< The touch device id */
   fingerId: cuint64;
   state: byte;        //**< The current button state */
   padding1: byte;
   padding2: byte;
   padding3: byte;
   x: Uint16;
   y: Uint16;
   dx: Uint16;
   dy: Uint16;
   pressure: Uint16;
 end;

 SDL_TouchButtonEvent = record
  type_ : cardinal;        //**< ::SDL_TOUCHBUTTONUP OR SDL_TOUCHBUTTONDOWN */
  timestamp: cardinal;
  window: cardinal;         //**< The window with mouse focus, if any */
  touchID: cuint64;        //**< The touch device id */
  state: byte;             //**< The current button state */
  button: byte;            //**< The button changing state */
  padding1: byte;
 end; 

 SDL_MultiGestureEvent = record
  type_ : cardinal;        //**< ::SDL_MULTIGESTURE */
  timestamp: cardinal;
  window: cardinal;         //**< The window with mouse focus, if any */
  touchID: cuint64;        //**< The touch device id */
  dTheta: double;
  dDist: double;
  x: double;  //currently 0...1. Change to screen coords?
  y: double;  
  numFingers: Uint16;
  padding: Uint16;
 end;

 //* (event.dgesture.*) */
 SDL_DollarGestureEvent = record
  type_ : cardinal;        //**< ::SDL_DOLLARGESTURE */
  timestamp: cardinal;
  window: cardinal;         //**< The window with mouse focus, if any */
  touchID: cuint64;        //**< The touch device id */
  gestureId: cuint64;
  numFingers: cardinal;
  error: double;
  {//TODO: Enable to give location?
  float x;  //currently 0...1. Change to screen coords?
  float y;}
 end;

 SDL_DropEvent = record
  type_ : cardinal;        //**< ::SDL_DROPFILE */
  timestamp: cardinal;
  filename: pchar;         //**< The file name, which should be freed with SDL_free() */
 end;

{*
 *  \brief The "quit requested" event
 }
  SDL_QuitEvent = record
    type_: cardinal;
  end;

{*
 *  \brief A user-defined event type (event.user.*)
 }
  SDL_User_Event = record
    type_: cardinal;
    windowID: cardinal;
    code: integer;
    data1: pointer;
    data2: pointer;
  end;

{*
 *  \brief A video driver dependent system event (event.syswm.*)
 }
  SDL_SysWM_Event = record
     type_: cardinal;
     msg: pointer;
  end;

  SDL_Event = record
   case UInt32 of
    SDL_FIRSTEVENT: (type_: cardinal); //**< Unused (do not remove) */
    //application
    SDL_QUITEV: (quit: SDL_QuitEvent ); //**< User-requested quit */
    //window
    SDL_WINDOWEVENT: (window: SDL_Window_Event); //**< Window state change */
    SDL_SYSWMEVENT: (syswin: SDL_SysWM_Event); //**< System specific event */
    //keyboard
    SDL_KEYDOWN,SDL_KEYUP: (key: SDL_KeyboardEvent); //**< Key pressed */
    SDL_TEXTEDITING: (edit: SDL_TextEditingEvent); //**< Keyboard text editing (composition) */
    SDL_TEXTINPUT: (text: SDL_TextInputEvent); //**< Keyboard text input */
    //mouse
    SDL_MOUSEMOTION: (motion: SDL_MouseMotionEvent); //**< Mouse moved */
    SDL_MOUSEBUTTONDOWN,SDL_MOUSEBUTTONUP: (button: SDL_MouseButtonEvent); //**< Mouse button pressed */
    SDL_MOUSEWHEEL: (wheel: SDL_MouseWheelEvent); //**< Mouse wheel motion */
    //* Joystick events */
    SDL_JOYAXISMOTION: (jaxis: SDL_JoyAxisEvent );
    SDL_JOYBALLMOTION: (jball: SDL_JoyBallEvent );
    SDL_JOYHATMOTION: (jhat: SDL_JoyHatEvent );
    SDL_JOYBUTTONDOWN, SDL_JOYBUTTONUP: (jbutton: SDL_JoyButtonEvent );
    //* Touch events */
    SDL_FINGERDOWN,SDL_FINGERUP: (tfinger: SDL_TouchFingerEvent);
    //SDL_FINGERMOTION,
    SDL_TOUCHBUTTONDOWN,SDL_TOUCHBUTTONUP: (tbutton: SDL_TouchButtonEvent);  
    //* Gesture events */
    SDL_DOLLARGESTURE: (dgesture: SDL_DollarGestureEvent);
    SDL_MULTIGESTURE: (mgesture: SDL_MultiGestureEvent);
    SDL_DROPFILE : (drop: SDL_DropEvent);  
    SDL_USEREVENT: (user: SDL_User_Event);
  end;
  PSDL_Event = ^SDL_Event;

  SDL_EventAction = (SdlAddEvent, SdlPeekEvent, SdlGetEvent);

  SDL_EventFilter = function (userdata: pointer; event: PSDL_Event): integer;

  SDL_EventArray = array of SDL_Event; 

 function SDL_Init( flags : Cardinal ) : Integer; cdecl; external SDLLibName;
 procedure SDL_Quit; cdecl; external SDLLibName;

// window management
const
 SDL_WINDOW_FULLSCREEN = $00000001;         //**< fullscreen window *//
 SDL_WINDOW_OPENGL = $00000002;             //**< window usable with OpenGL context *//
 SDL_WINDOW_SHOWN = $00000004;              //**< window is visible *//
 SDL_WINDOW_HIDDEN = $00000008;             //**< window is not visible *//
 SDL_WINDOW_BORDERLESS = $00000010;         //**< no window decoration *//
 SDL_WINDOW_RESIZABLE = $00000020;          //**< window can be resized *//
 SDL_WINDOW_MINIMIZED = $00000040;          //**< window is minimized *//
 SDL_WINDOW_MAXIMIZED = $00000080;          //**< window is maximized *//
 SDL_WINDOW_INPUT_GRABBED = $00000100;      //**< window has grabbed input focus *//
 SDL_WINDOW_INPUT_FOCUS = $00000200;        //**< window has input focus *//
 SDL_WINDOW_MOUSE_FOCUS = $00000400;        //**< window has mouse focus *//
 SDL_WINDOW_FOREIGN = $00000800;             //**< window not created by SDL *//

// window pos center
 SDL_WINDOWPOS_CENTERED_MASK = $2FFF0000;
 SDL_WINDOWPOS_CENTERED = SDL_WINDOWPOS_CENTERED_MASK or 0;

type
 SDL_WindowFlags = UInt32;

 function SDL_CreateWindow(title: PChar; x, y, w, h: integer; flags: SDL_WindowFlags): winidty; 
   cdecl; external SDLLibName;
 procedure SDL_DestroyWindow(window: winidty); cdecl; external SDLLibName;
 procedure SDL_ShowWindow(window: winidty); cdecl; external SDLLibName;
 procedure SDL_HideWindow(window: winidty); cdecl; external SDLLibName;
 procedure SDL_RaiseWindow(window: winidty); cdecl; external SDLLibName;
 procedure SDL_GetWindowPosition(window: winidty; var x, y: integer); cdecl; external SDLLibName;
 procedure SDL_SetWindowPosition(window: winidty; x, y: integer); cdecl; external SDLLibName;
 procedure SDL_GetWindowSize(window: winidty; var w, h: integer); cdecl; external SDLLibName;
 procedure SDL_SetWindowSize(window: winidty; w, h: integer); cdecl; external SDLLibName;
 function SDL_GetWindowFlags(window: winidty): SDL_WindowFlags; cdecl; external SDLLibName;
 procedure SDL_RestoreWindow(window: winidty); cdecl; external SDLLibName;
 procedure SDL_MinimizeWindow(window: winidty); cdecl; external SDLLibName;
 procedure SDL_MaximizeWindow(window: winidty); cdecl; external SDLLibName;
 function SDL_SetWindowFullscreen(window: winidty; fullscreen: boolean): integer; cdecl; external SDLLibName;
 procedure SDL_SetWindowTitle(window: winidty; const title: PChar); cdecl; external SDLLibName;
 procedure SDL_SetWindowIcon(window: winidty; icon: PSDL_Surface); cdecl; external SDLLibName;
 procedure SDL_UpdateWindowSurface(window: winidty); cdecl; external SDLLibName;
 function SDL_GetWindowFromID(id: cardinal): winidty; cdecl; external SDLLibName;
 function SDL_GetWindowSurface(window: winidty): PSDL_Surface; cdecl; external SDLLibName;
 function SDL_UpdateWindowSurface(window: winidty): integer; cdecl; external SDLLibName;
 function SDL_GetDisplayBounds(displayIndex: integer; rect: PSDL_Rect): integer; cdecl; external SDLLibName;

// error 
 function SDL_GetError: pchar; cdecl; external SDLLibName;
 procedure SDL_ClearError; cdecl; external SDLLibName;
 function SDL_CheckError(ref: string): guierrorty;
 function SDL_CheckErrorGDI(ref: string): gdierrorty;

// thread
 function SDL_CreateMutex: mutexty; cdecl; external SDLLibName;
 procedure SDL_DestroyMutex(varmutex: mutexty); cdecl; external SDLLibName;
 function SDL_LockMutex(mutex: mutexty): integer; cdecl; external SDLLibName;
 function SDL_UnlockMutex(mutex: mutexty): integer; cdecl; external SDLLibName;
 function SDL_mutexP(mutex: mutexty): integer; cdecl; external SDLLibName;
 function SDL_mutexV(mutex: mutexty): integer; cdecl; external SDLLibName;
 function SDL_CreateSemaphore(initial_value: cardinal): semty; cdecl; external SDLLibName;
 function SDL_SemPost(sem: semty): integer; cdecl; external SDLLibName;
 procedure SDL_DestroySemaphore(sem: semty); cdecl; external SDLLibName;
 function SDL_SemWait(sem: semty): integer; cdecl; external SDLLibName;
 function SDL_SemWaitTimeout(sem: semty; ms:cardinal): integer; cdecl; external SDLLibName;
 function SDL_SemValue(sem: semty): cardinal; cdecl; external SDLLibName;
 function SDL_SemTryWait(sem: semty): integer; cdecl; external SDLLibName;
 procedure SDL_WaitThread(thread: pointer; status:pinteger); cdecl; external SDLLibName;
 
// mouse
const
 curwidth = 32;
 curheight = 32;
 curlength = ((curwidth+15) div 16)*2*curheight;
 curdragxor: array[0..curlength-1] of byte =
 (
      $00,$00,$00,$00,
      $40,$00,$00,$00,
      $60,$00,$00,$00,
      $70,$00,$00,$00,
      $78,$00,$00,$00,
      $7c,$00,$00,$00,
      $7e,$00,$00,$00,
      $7f,$00,$00,$00,
      $7f,$80,$00,$00,
      $7f,$80,$00,$00,
      $7f,$00,$00,$00,
      $7e,$00,$00,$00,
      $6e,$00,$00,$00,
      $46,$00,$00,$00,
      $06,$Fc,$00,$00,
      $03,$7c,$00,$00,
      $03,$7c,$00,$00,
      $05,$bc,$00,$00,
      $05,$bc,$00,$00,
      $06,$7c,$00,$00,
      $07,$Fc,$00,$00,
      $07,$Fc,$00,$00,
      $07,$Fc,$00,$00,
      $07,$Fc,$00,$00,
      $07,$Fc,$00,$00,
      $00,$00,$00,$00,
      $00,$00,$00,$00,
      $00,$00,$00,$00,
      $00,$00,$00,$00,
      $00,$00,$00,$00,
      $00,$00,$00,$00,
      $00,$00,$00,$00);
 curdragand: array[0..curlength-1] of byte =
  (
      $3f,$ff,$ff,$ff,
      $1f,$ff,$ff,$ff,
      $0f,$ff,$ff,$ff,
      $07,$ff,$ff,$ff,
      $03,$ff,$ff,$ff,
      $01,$ff,$ff,$ff,
      $00,$ff,$ff,$ff,
      $00,$7f,$ff,$ff,
      $00,$3f,$ff,$ff,
      $00,$1f,$ff,$ff,
      $00,$0f,$ff,$ff,
      $00,$ff,$ff,$ff,
      $00,$ff,$ff,$ff,
      $10,$01,$ff,$ff,
      $30,$01,$ff,$ff,
      $70,$01,$ff,$ff,
      $f0,$01,$ff,$ff,
      $f0,$01,$ff,$ff,
      $f0,$01,$ff,$ff,
      $f0,$01,$ff,$ff,
      $f0,$01,$ff,$ff,
      $f0,$01,$ff,$ff,
      $f0,$01,$ff,$ff,
      $f0,$01,$ff,$ff,
      $f0,$01,$ff,$ff,
      $f0,$01,$ff,$ff,
      $ff,$ff,$ff,$ff,
      $ff,$ff,$ff,$ff,
      $ff,$ff,$ff,$ff,
      $ff,$ff,$ff,$ff,
      $ff,$ff,$ff,$ff,
      $ff,$ff,$ff,$ff
   );
   
type
 SDL_Cursor = ptruint;

 function SDL_GetMouseState(x,y: pinteger): byte; cdecl; external SDLLibName;
 function SDL_GetRelativeMouseState(x,y: pinteger): byte; cdecl; external SDLLibName;
 procedure SDL_WarpMouseInWindow(window: cardinal; x, y: integer); cdecl; external SDLLibName;
 function SDL_CreateCursor(const data: pbyte; const Umask: pbyte; w,h,hot_x,hot_y: integer): SDL_Cursor; cdecl; external SDLLibName;
 function SDL_CreateColorCursor(surface: PSDL_Surface; hot_x, hot_y: integer): SDL_Cursor; cdecl; external SDLLibName;

 procedure SDL_SetCursor(cursor: SDL_Cursor); cdecl; external SDLLibName;

// 2D renderer
const
 SDL_RENDERER_SOFTWARE = $00000001;         //**< The renderer is a software fallback */ 
 SDL_RENDERER_ACCELERATED = $00000002;      //**< The renderer uses hardware 
                                            //      acceleration */
 SDL_RENDERER_PRESENTVSYNC = $00000004;     //**< Present is synchronized 
                                            //      with the refresh rate */
 SDL_RENDERER_TARGETTEXTURE = $00000008;     //**< The renderer supports

type
 SDL_Texture = ptruint;
 SDL_Renderer = ptruint;
 PSdlTextureAccess = ^SDL_TextureAccess;
 SDL_TextureAccess = (sdltaStatic, sdltaStreaming, sdltaRenderTarget);

 SDL_BlendMode = (SDL_BLENDMODE_NONE = $00000000,
                  SDL_BLENDMODE_BLEND = $00000001,
                  SDL_BLENDMODE_ADD = $00000002,
                  SDL_BLENDMODE_MOD = $00000004);

 SDL_RendererInfo = record
  name: pchar;                              //**< The name of the renderer */
  flags: Uint32;                             //**< Supported ::SDL_RendererFlags */
  num_texture_formats: Uint32;               //**< The number of available texture formats */
  texture_formats: array[0..16] of Uint32;   //**< The available texture formats */
  max_texture_width: integer;                //**< The maximimum texture width */
  max_texture_height: integer;               //**< The maximimum texture height */
 end;
 PSDL_RendererInfo = ^SDL_RendererInfo;
 
 function SDL_CreateRenderer(window: cardinal; index: integer; flags: Cardinal): SDL_Renderer; cdecl; external SDLLibName;
 function SDL_CreateTexture(renderer: SDL_Renderer; format: Cardinal; access: SDL_TextureAccess; w,h: integer): SDL_Texture; cdecl; external SDLLibName;
 function SDL_GetRenderer(window: cardinal): SDL_Renderer; cdecl; external SDLLibName;
 function SDL_CreateSoftwareRenderer(surface: PSDL_Surface): SDL_Renderer; cdecl; external SDLLibName;
 procedure SDL_DestroyRenderer(renderer: SDL_Renderer); cdecl; external SDLLibName;
 function SDL_CreateTextureFromSurface(renderer: SDL_Renderer; surface: PSDL_Surface): SDL_Texture; cdecl; external SDLLibName;
 function SDL_QueryTexture(texture: SDL_Texture; format: PCardinal;
                           access: PSdlTextureAccess; w, h: PInteger): integer; cdecl; external SDLLibName;
 function SDL_QueryTexturePixels(texture: SDL_Texture; pixels: pointer; pitch: pinteger): integer; cdecl; external SDLLibName;
 function SDL_SetTextureColorMod(texture: SDL_Texture; r, g, b: Uint8): Integer; cdecl; external SDLLibName;
 function SDL_GetTextureColorMod(texture: SDL_Texture; var r, g, b: Uint8): Integer; cdecl; external SDLLibName;
 function SDL_SetTextureAlphaMod(textureID: SDL_Texture; alpha: byte): integer; cdecl; external SDLLibName;
 function SDL_GetTextureAlphaMod(textureID: SDL_Texture; var alpha: byte): integer; cdecl; external SDLLibName;
 function SDL_GetTextureHandle(texture: SDL_Texture): integer; cdecl; external SDLLibName;
 function SDL_SetTextureBlendMode(texture: SDL_Texture; blendMode: SDL_BlendMode): Integer; cdecl; external SDLLibName;
 function SDL_GetTextureBlendMode(texture: SDL_Texture; var blendMode: SDL_BlendMode): Integer; cdecl; external SDLLibName;
 function SDL_SetRenderDrawColor(renderer: SDL_Renderer; r, g, b, a: byte): integer; cdecl; overload; external SDLLibName;
 function SDL_RenderReadPixels(renderer: SDL_Renderer; const rect: PSDL_Rect; format: Uint32; pixels: pointer; pitch: integer): integer; cdecl; external SDLLibName;
 function SDL_SetRenderDrawBlendMode(renderer: SDL_Renderer; blendMode: SDL_BlendMode): integer; cdecl; external SDLLibName;
 function SDL_GetRenderDrawBlendMode(renderer: SDL_Renderer; var blendMode: SDL_BlendMode): integer; cdecl; external SDLLibName;
 function SDL_RenderClear(renderer: SDL_Renderer): Integer; cdecl; external SDLLibName;
 function SDL_RenderDrawLine(renderer: SDL_Renderer; x1, y1, x2, y2: integer): integer; cdecl; external SDLLibName;
 function SDL_RenderDrawLines(renderer: SDL_Renderer; const points: PSDL_Point; count: integer): integer; cdecl; external SDLLibName;

 function SDL_RenderDrawRect(renderer: SDL_Renderer; const rect: PSDL_Rect): integer; cdecl; external SDLLibName;
 function SDL_RenderFillRect(renderer: SDL_Renderer; const rect: PSDL_Rect): integer; cdecl; external SDLLibName;
 function SDL_RenderDrawPoint(renderer: SDL_Renderer; x: integer; y: integer): integer; cdecl; external SDLLibName;
 function SDL_RenderCopy(renderer: SDL_Renderer; texture: SDL_Texture; const srcrect, dstrect: PSDL_Rect): integer; cdecl; external SDLLibName;
 procedure SDL_RenderPresent(renderer: SDL_Renderer); cdecl; external SDLLibName;
 function SDL_SetRenderTarget(renderer: SDL_Renderer; texture: SDL_Texture): integer; cdecl; external SDLLibName;
 procedure SDL_DestroyTexture(textureID: SDL_Texture); cdecl; external SDLLibName;
 function SDL_RenderSetViewport(renderer: SDL_Renderer; const rect: PSDL_Rect): integer; cdecl; external SDLLibName;
 function SDL_GetNumRenderDrivers: integer; cdecl; external SDLLibName;
 function SDL_GetRenderDriverInfo(index: integer; info: PSDL_RendererInfo): integer; cdecl; external SDLLibName;
 function SDL_GetRendererInfo(renderer: SDL_Renderer; info: PSDL_RendererInfo): integer; cdecl; external SDLLibName;
 function SDL_LockTexture(texture: SDL_Texture; const rect: PSDL_Rect; pixels: pointer; pitch: pinteger): integer; cdecl; external SDLLibName;
 procedure SDL_UnlockTexture(texture: SDL_Texture); cdecl; external SDLLibName;
// surface
 function SDL_CreateRGBSurface (flags: cardinal;
                                   width: integer;
                                   height: integer;
                                   depth: integer;
                                   Rmask: Uint32;
                                   Gmask: Uint32;
                                   Bmask: Uint32;
                                   Amask: Uint32): PSDL_Surface; cdecl; external SDLLibName;
 function SDL_CreateRGBSurfaceFrom (pixels: pointer;
                                       width: integer;
                                       height: integer;
                                       depth: integer;
                                       pitch: integer;
                                       Rmask: Uint32;
                                       Gmask: Uint32;
                                       Bmask: Uint32;
                                       Amask: Uint32): PSDL_Surface; cdecl; external SDLLibName;
 function SDL_LoadBMP_RW(src: PSDL_RWops; freesrc: integer): PSDL_Surface; cdecl; external SDLLibName;
 function SDL_LoadBMPFromFile(filename: PAnsiChar): PSDL_Surface;
 procedure SDL_FreeSurface(surface: PSDL_Surface); cdecl; external SDLLibName;
 function SDL_UpperBlit(src: PSDL_Surface; const srcrect: PSDL_Rect; dst: PSDL_Surface; dstrect: PSDL_Rect): integer; cdecl; external SDLLibName;
 function SDL_LowerBlit(src: PSDL_Surface; const srcrect: PSDL_Rect; dst: PSDL_Surface; dstrect: PSDL_Rect): integer; cdecl; external SDLLibName;
 function SDL_LockSurface(surface: PSDL_Surface): integer; cdecl; external SDLLibName;
 procedure SDL_UnlockSurface(surface: PSDL_Surface); cdecl; external SDLLibName;
 function SDL_ConvertPixels(width: integer; 
                            height: integer;
                            src_format: Uint32;
                            const src: pointer;
                            src_pitch: integer;
                            dst_format: Uint32;
                            dst: pointer;
                            dst_pitch: integer): integer; cdecl; external SDLLibName;
 procedure SDL_SaveBMP_RW(surface: PSDL_Surface; dst: PSDL_RWops; freedst: integer); cdecl; external SDLLibName;
 procedure SDL_SaveBMP_toFile(surface: PSDL_Surface; filename: PAnsiChar);
 function SDL_SetClipRect(surface: PSDL_Surface; const rect: PSDL_Rect): boolean; cdecl; external SDLLibName;
 procedure SDL_GetClipRect(surface: PSDL_Surface; var rect: PSDL_Rect); cdecl; external SDLLibName;
 function SDL_SetSurfaceBlendMode(surface: PSDL_Surface; blendMode: SDL_BlendMode): integer; cdecl; external SDLLibName;
 function SDL_UpperBlitScaled(src: PSDL_Surface; const srcrect: PSDL_Rect; dst: PSDL_Surface; dstrect: PSDL_Rect): integer; cdecl; external SDLLibName;


// event

 procedure SDL_PumpEvents; cdecl; external SDLLibName;
 function SDL_PeepEvents(events: PSDL_Event; var numevents: integer; action: SDL_EventAction;
                        minType, maxType: cardinal): integer; cdecl; external SDLLibName;
 function SDL_GetEvents(minType: cardinal = 0; maxType: cardinal = SDL_LASTEVENT): SDL_EventArray; cdecl; external SDLLibName;
 function SDL_HasEvent(type_: Cardinal): boolean; cdecl; external SDLLibName;
 function SDL_HasEvents(minType, maxType: Cardinal): boolean; cdecl; external SDLLibName;
 procedure SDL_FlushEvent(type_: Cardinal); cdecl; external SDLLibName;
 procedure SDL_FlushEvents(minType, maxType: Cardinal); cdecl; external SDLLibName;
 function SDL_PollEvent(event: PSDL_Event): integer; cdecl; external SDLLibName;
 function SDL_WaitEvent(event: PSDL_Event): integer; cdecl; external SDLLibName;
 function SDL_WaitEventTimeout(event: PSDL_Event; timeout: integer): integer; cdecl; external SDLLibName;
 function SDL_PushEvent(const event: PSDL_Event): integer; cdecl; external SDLLibName;
 procedure SDL_SetEventFilter(filter: SDL_EventFilter; userdata: pointer);cdecl; external SDLLibName;
 function SDL_GetEventFilter(out filter: SDL_EventFilter; out userdata: pointer): boolean; cdecl; external SDLLibName;
 procedure SDL_FilterEvents(filter: SDL_EventFilter; userdata: pointer); cdecl; external SDLLibName;
 function SDL_EventState(type_: cardinal; state: integer): byte; cdecl; external SDLLibName;
 function SDL_GetEventState(type_:cardinal): byte;  cdecl; external SDLLibName;
 function SDL_RegisterEvents(numevents: integer): cardinal;  cdecl; external SDLLibName;

//keyboard
 procedure SDL_StartTextInput; cdecl; external SDLLibName;
 function SDL_GetKeyName(key: SDL_KeyCode): pchar; cdecl; external SDLLibName;
 function SDL_GetKeyFromScancode(scancode: SDL_Scancode): SDL_KeyCode; cdecl; external SDLLibName;

//mouse
 function checkbutton(const mousestate: byte): mousebuttonty;
 function checkbuttonindex(const buttonindex: byte): mousebuttonty;
 function sdlmousetoshiftstate(keys: byte): shiftstatesty;

// timer
type
 TSDL_NewTimerCallback = function( interval: UInt32; param: Pointer ): UInt32; cdecl;

 procedure SDL_Delay(ms: Cardinal); cdecl; external SDLLibName;
 function SDL_AddTimer(interval: UInt32; callback: pointer{TSDL_NewTimerCallback}; param : Pointer): integer; cdecl; external SDLLibName;
 procedure SDL_RemoveTimer(id: integer); cdecl; external SDLLibName;
 function SDL_GetTicks: UInt32; cdecl; external SDLLibName;

// clipboard
 function SDL_SetClipboardText(const text: pchar): integer; cdecl; external SDLLibName;
 function SDL_HasClipboardText: boolean; cdecl; external SDLLibName;
 function SDL_GetClipboardText: pchar; cdecl; external SDLLibName;

//file I/O

 function SDL_RWFromFile(filename, mode: PAnsiChar): PSDL_RWops; cdecl; external SDLLibName;
 procedure SDL_FreeRW(area: PSDL_RWops); cdecl; external SDLLibName;
 function SDL_RWFromFP(fp: Pointer; autoclose: Integer): PSDL_RWops; cdecl; external SDLLibName;
 function SDL_RWFromMem(mem: Pointer; size: Integer): PSDL_RWops; cdecl; external SDLLibName;
 function SDL_RWFromConstMem(const mem: Pointer; size: Integer) : PSDL_RWops; cdecl; external SDLLibName;
 function SDL_AllocRW: PSDL_RWops; cdecl; external SDLLibName;
 function SDL_RWSeek(context: PSDL_RWops; offset: Integer; whence: Integer) : Integer; cdecl; external SDLLibName;
 function SDL_RWTell(context: PSDL_RWops): Integer; cdecl; external SDLLibName;
 function SDL_RWRead(context: PSDL_RWops; ptr: Pointer; size: Integer; n : Integer): Integer; cdecl; external SDLLibName;
 function SDL_RWWrite(context: PSDL_RWops; ptr: Pointer; size: Integer; n : Integer): Integer; cdecl; external SDLLibName;
 function SDL_RWClose(context: PSDL_RWops): Integer; cdecl; external SDLLibName;

 function SDL_KeyCodeToKey(acode: SDL_KeyCode): keyty;
 function SDL_GetShiftState(akeyevent: SDL_KeyboardEvent): shiftstatesty;

implementation

 function SDL_KeyCodeToKey(acode: SDL_KeyCode): keyty;
 begin
  case acode of
   //key_none
   SDLK_SPACE, SDLK_KP_SPACE : result:= key_Space;
   SDLK_EXCLAIM, SDLK_KP_EXCLAM : result:= key_Exclam;
   SDLK_QUOTEDBL : result:= key_QuoteDbl;
   SDLK_HASH, SDLK_KP_HASH : result:= key_NumberSign;
   SDLK_DOLLAR : result:= key_Dollar;
   SDLK_PERCENT, SDLK_KP_PERCENT : result:= key_Percent;
   SDLK_AMPERSAND, SDLK_KP_AMPERSAND : result:= key_Ampersand;
   SDLK_QUOTE : result:= key_Apostrophe;
   SDLK_LEFTPAREN, SDLK_KP_LEFTPAREN : result:= key_ParenLeft;
   SDLK_RIGHTPAREN, SDLK_KP_RIGHTPAREN : result:= key_ParenRight;
   SDLK_ASTERISK, SDLK_KP_MULTIPLY, SDLK_KP_MEMMULTIPLY : result:= key_Asterisk;
   SDLK_PLUS, SDLK_KP_PLUS, SDLK_KP_MEMADD : result:= key_Plus;
   SDLK_COMMA, SDLK_KP_COMMA : result:= key_Comma;
   SDLK_MINUS, SDLK_KP_MINUS, SDLK_KP_MEMSUBTRACT : result:= key_Minus;
   SDLK_PERIOD, SDLK_KP_PERIOD : result:= key_Period;
   SDLK_SLASH, SDLK_KP_DIVIDE, SDLK_KP_MEMDIVIDE : result:= key_Slash;
   SDLK_0, SDLK_KP_0 : result:= key_0;
   SDLK_1, SDLK_KP_1 : result:= key_1;
   SDLK_2, SDLK_KP_2 : result:= key_2;
   SDLK_3, SDLK_KP_3 : result:= key_3;
   SDLK_4, SDLK_KP_4 : result:= key_4;
   SDLK_5, SDLK_KP_5 : result:= key_5;
   SDLK_6, SDLK_KP_6 : result:= key_6;
   SDLK_7, SDLK_KP_7 : result:= key_7;
   SDLK_8, SDLK_KP_8 : result:= key_8;
   SDLK_9, SDLK_KP_9 : result:= key_9;
   SDLK_COLON, SDLK_KP_COLON : result:= key_Colon;
   SDLK_SEMICOLON : result:= key_Semicolon;
   SDLK_LESS, SDLK_KP_LESS : result:= key_Less;
   SDLK_EQUALS, SDLK_KP_EQUALS, SDLK_KP_EQUALSAS400 : result:= key_Equal;
   SDLK_GREATER, SDLK_KP_GREATER : result:= key_Greater;
   SDLK_QUESTION : result:= key_Question;
   SDLK_AT, SDLK_KP_AT : result:= key_At;
   SDLK_a, SDLK_KP_A : result:= key_A;
   SDLK_b, SDLK_KP_B : result:= key_B;
   SDLK_c, SDLK_KP_C : result:= key_C;
   SDLK_d, SDLK_KP_D : result:= key_D;
   SDLK_e, SDLK_KP_E : result:= key_E;
   SDLK_f, SDLK_KP_F : result:= key_F;
   SDLK_g : result:= key_G;
   SDLK_h : result:= key_H;
   SDLK_i : result:= key_I;
   SDLK_j : result:= key_J;
   SDLK_k : result:= key_K;
   SDLK_l : result:= key_L;
   SDLK_m : result:= key_M;
   SDLK_n : result:= key_N;
   SDLK_o : result:= key_O;
   SDLK_p : result:= key_P;
   SDLK_q : result:= key_Q;
   SDLK_r : result:= key_R;
   SDLK_s : result:= key_S;
   SDLK_t : result:= key_T;
   SDLK_u : result:= key_U;
   SDLK_v : result:= key_V;
   SDLK_w : result:= key_W;
   SDLK_x : result:= key_X;
   SDLK_y : result:= key_Y;
   SDLK_z : result:= key_Z;
   SDLK_LEFTBRACKET : result:= key_BracketLeft;
   SDLK_BACKSLASH : result:= key_Backslash;
   SDLK_RIGHTBRACKET : result:= key_BracketRight;
   SDLK_CARET : result:= key_AsciiCircum;
   SDLK_UNDERSCORE : result:= key_Underscore;
   SDLK_BACKQUOTE : result:= key_QuoteLeft;
   SDLK_KP_LEFTBRACE : result:= key_BraceLeft;
   SDLK_SEPARATOR : result:= key_Bar;
   SDLK_KP_RIGHTBRACE : result:= key_BraceRight;
   //key_AsciiTilde
   //key_nobreakspace
   //key_exclamdown
   SDLK_CURRENCYSUBUNIT : result:= key_cent;
   //key_sterling
   SDLK_CURRENCYUNIT : result:= key_currency;
   //key_yen
   //key_brokenbar
   //key_section
   //key_diaeresis
   //key_copyright
   //key_ordfeminine
   //key_guillemotleft
   //key_notsign
   //key_hyphen
   //key_registered
   //key_macron
   //key_degree
   SDLK_KP_PLUSMINUS : result:= key_plusminus;
   //key_twosuperior
   //key_threesuperior
   //key_acute
   //key_mu
   //key_paragraph
   //key_periodcentered
   //key_cedilla
   //key_onesuperior
   //key_masculine
   //key_guillemotright
   //key_onequarter
   //key_onehalf
   //key_threequarters
   //key_questiondown
   //key_Agrave
   //key_Aacute
   //key_Acircumflex
   //key_Atilde
   //key_Adiaeresis
   //key_Aring
   //key_AE
   //key_Ccedilla
   //key_Egrave
   //key_Eacute
   //key_Ecircumflex
   //key_Ediaeresis
   //key_Igrave
   //key_Iacute
   //key_Icircumflex
   //key_Idiaeresis
   //key_ETH
   //key_Ntilde
   //key_Ograve
   //key_Oacute
   //key_Ocircumflex
   //key_Otilde
   //key_Odiaeresis
   //key_Ooblique
   //key_Ugrave
   //key_Uacute
   //key_Ucircumflex
   //key_Udiaeresis
   //key_Yacute
   //key_THORN
   //key_ssharp
   //key_agrave_lower
   //key_aacute_lower
   //key_acircumflex_lower
   //key_atilde_lower
   //key_adiaeresis_lower
   //key_aring_lower
   //key_ae_lower
   //key_ccedilla_lower
   //key_egrave_lower
   //key_eacute_lower
   //key_ecircumflex_lower
   //key_ediaeresis_lower
   //key_igrave_lower
   //key_iacute_lower
   //key_icircumflex_lower
   //key_idiaeresis_lower
   //key_eth_lower
   //key_ntilde_lower
   //key_ograve_lower
   //key_oacute_lower
   //key_ocircumflex_lower
   //key_otilde_lower
   //key_odiaeresis_lower
   //key_division
   //key_oslash
   //key_ugrave_lower
   //key_uacute_lower
   //key_ucircumflex_lower
   //key_udiaeresis_lower
   //key_yacute_lower
   //key_thorn_lower
   //key_ydiaeresis
   SDLK_ESCAPE : result:= key_Escape;
   SDLK_TAB, SDLK_KP_TAB : result:= key_Tab;
   //key_Backtab
   SDLK_BACKSPACE, SDLK_KP_BACKSPACE : result:= key_Backspace;
   SDLK_RETURN, SDLK_KP_ENTER , SDLK_RETURN2 : result:= key_Return;
   SDLK_INSERT : result:= key_Insert;
   SDLK_DELETE : result:= key_Delete;
   SDLK_PAUSE : result:= key_Pause;
   SDLK_PRINTSCREEN : result:= key_Print;
   SDLK_SYSREQ : result:= key_SysReq;
   SDLK_HOME : result:= key_Home;
   SDLK_END : result:= key_End;
   SDLK_LEFT : result:= key_Left;
   SDLK_UP : result:= key_Up;
   SDLK_RIGHT : result:= key_Right;
   SDLK_DOWN : result:= key_Down;
   SDLK_PRIOR : result:= key_Prior;
   SDLK_PAGEUP : result:= Key_PageUp;
   //key_Next
   SDLK_PAGEDOWN : result:= Key_PageDown;
   SDLK_KP_CLEAR, SDLK_KP_CLEARENTRY, SDLK_CLEAR : result:= key_clear;
   SDLK_KP_DECIMAL, SDLK_DECIMALSEPARATOR : result:= key_decimal;
   SDLK_RSHIFT, SDLK_LSHIFT : result:= key_Shift;
   SDLK_LCTRL, SDLK_RCTRL : result:= key_Control;
   SDLK_LGUI : result:= key_Meta;
   SDLK_LALT : result:= key_Alt;
   SDLK_CAPSLOCK : result:= key_CapsLock;
   SDLK_NUMLOCKCLEAR : result:= key_NumLock;
   SDLK_SCROLLLOCK : result:= key_ScrollLock;
   SDLK_RALT : result:= key_AltGr;
   SDLK_F1 : result:= key_F1;
   SDLK_F2 : result:= key_F2;
   SDLK_F3 : result:= key_F3;
   SDLK_F4 : result:= key_F4;
   SDLK_F5 : result:= key_F5;
   SDLK_F6 : result:= key_F6;
   SDLK_F7 : result:= key_F7;
   SDLK_F8 : result:= key_F8;
   SDLK_F9 : result:= key_F9;
   SDLK_F10 : result:= key_F10;
   SDLK_F11 : result:= key_F11;
   SDLK_F12 : result:= key_F12;
   SDLK_F13 : result:= key_F13;
   SDLK_F14 : result:= key_F14;
   SDLK_F15 : result:= key_F15;
   SDLK_F16 : result:= key_F16;
   SDLK_F17 : result:= key_F17;
   SDLK_F18 : result:= key_F18;
   SDLK_F19 : result:= key_F19;
   SDLK_F20 : result:= key_F20;
   SDLK_F21 : result:= key_F21;
   SDLK_F22 : result:= key_F22;
   SDLK_F23 : result:= key_F23;
   SDLK_F24 : result:= key_F24;
   //key_F25
   //key_F26
   //key_F27
   //key_F28
   //key_F29
   //key_F30
   //key_F31
   //key_F32
   //key_F33
   //key_F34
   //key_F35
   //key_Super
   SDLK_MENU : result:= key_Menu;
   //key_Hyper
   SDLK_HELP : result:= key_Help;
   SDLK_UNKNOWN : result:= key_unknown;
  end;
  {
  //SDL_KeyCode not yet used
  SDLK_APPLICATION
  SDLK_POWER
  SDLK_EXECUTE
  SDLK_SELECT
  SDLK_STOP
  SDLK_AGAIN
  SDLK_UNDO
  SDLK_CUT
  SDLK_COPY
  SDLK_PASTE
  SDLK_FIND
  SDLK_MUTE
  SDLK_VOLUMEUP
  SDLK_VOLUMEDOWN
  SDLK_ALTERASE
  SDLK_CANCEL
  SDLK_OUT
  SDLK_OPER
  SDLK_CLEARAGAIN
  SDLK_CRSEL
  SDLK_EXSEL
  SDLK_KP_00
  SDLK_KP_000
  SDLK_THOUSANDSSEPARATOR
  SDLK_KP_MEMSTORE
  SDLK_KP_MEMRECALL
  SDLK_KP_MEMCLEAR
  SDLK_KP_BINARY
  SDLK_KP_OCTAL
  SDLK_KP_HEXADECIMAL
  SDLK_RGUI
  SDLK_MODE
  SDLK_AUDIONEXT
  SDLK_AUDIOPREV
  SDLK_AUDIOSTOP
  SDLK_AUDIOPLAY
  SDLK_AUDIOMUTE
  SDLK_MEDIASELECT
  SDLK_WWW
  SDLK_MAIL
  SDLK_CALCULATOR
  SDLK_COMPUTER
  SDLK_AC_SEARCH
  SDLK_AC_HOME
  SDLK_AC_BACK
  SDLK_AC_FORWARD
  SDLK_AC_STOP
  SDLK_AC_REFRESH
  SDLK_AC_BOOKMARKS
  SDLK_BRIGHTNESSDOWN
  SDLK_BRIGHTNESSUP
  SDLK_DISPLAYSWITCH
  SDLK_KBDILLUMTOGGLE
  SDLK_KBDILLUMDOWN
  SDLK_KBDILLUMUP
  SDLK_EJECT
  SDLK_SLEEP}
 end;

 function SDL_GetShiftState(akeyevent: SDL_KeyboardEvent): shiftstatesty;
 begin
  result:= [];
  if (akeyevent.keysym.mods and KMOD_SHIFT)<>0 then begin
   include(result,ss_shift);
  end;
  if (akeyevent.keysym.mods and KMOD_ALT)<>0 then begin
   include(result,ss_alt);
  end;
  if (akeyevent.keysym.mods and KMOD_CTRL)<>0 then begin
   include(result,ss_ctrl);
  end;
  if (akeyevent.repeat_<>0) then begin
   include(result,ss_repeat);
  end;
 end;
 
 function SDL_LoadBMPFromFile(filename: PAnsiChar): PSDL_Surface;
 begin
  SDL_LoadBMP_RW(SDL_RWFromFile(filename, 'rb'), 1)
 end;

 procedure SDL_SaveBMP_toFile(surface: PSDL_Surface; filename: PAnsiChar);
 begin
  SDL_SaveBMP_RW(surface,SDL_RWFromFile(filename, 'wb'), 1)
 end;
 
 function SDL_CheckError(ref: string): guierrorty;
 var
  err: pchar;
 begin
  err:= SDL_GetError;
  if err<>'' then begin
   debugwriteln('SDL error = ' + ref + ' : ' + err);
   SDL_ClearError;
  end else begin
   debugwriteln('Success = ' + ref);
   result:= gue_ok;
  end;
 end;

 function SDL_CheckErrorGDI(ref: string): gdierrorty;
 var
  err: pchar;
 begin
  err:= SDL_GetError;
  if err<>'' then begin
   debugwriteln('SDL error = ' + ref + ' : ' + err);
   SDL_ClearError;
  end else begin
   debugwriteln('Success = ' + ref);
   result:= gde_ok;
  end;
 end;

 function checkbutton(const mousestate: byte): mousebuttonty;
 begin
  result:= mb_none;
  case mousestate of
   SDL_BUTTON_LMASK: result:= mb_left;
   SDL_BUTTON_MMASK: result:= mb_middle;
   SDL_BUTTON_RMASK: result:= mb_right;
  end;
 end;

 function checkbuttonindex(const buttonindex: byte): mousebuttonty;
 begin
  result:= mb_none;
  case buttonindex of
   1: result:= mb_left;
   2: result:= mb_middle;
   3: result:= mb_right;
  end;
 end;

 function sdlmousetoshiftstate(keys: byte): shiftstatesty;
 begin
  result:= [];
  case keys of
   SDL_BUTTON_LMASK: include(result,ss_left);
   SDL_BUTTON_MMASK: include(result,ss_middle);
   SDL_BUTTON_RMASK: include(result,ss_right);
  end;
 end;
 
end.
