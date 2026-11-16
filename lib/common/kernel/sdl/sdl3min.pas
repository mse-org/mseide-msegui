unit sdl3min;
{ Minimal SDL3 header for MSEgui.
  Only the functions, types and constants used by sdl3api.pas are declared.
  The layouts are copied from the SDL3-for-Pascal headers (SDL3.pas, version
  3.4.x). Replaces SDL3.pas and the SDL_*.inc files.
  No dependency on X11 units. }
{$mode objfpc}{$h+}
{$packrecords C}

interface

uses
 ctypes;

const
{$ifdef windows}
 SDL_LibName = 'SDL3.dll';
{$else}
 {$ifdef darwin}
 SDL_LibName = 'libSDL3.dylib';
 {$else}
 SDL_LibName = 'libSDL3.so';
 {$endif}
{$endif}

type
 PSDL_Window = type Pointer;
 PSDL_Renderer = type Pointer;
 PSDL_Cursor = type Pointer;
 PSDL_Mutex = type Pointer;
 PSDL_Semaphore = type Pointer;
 PSDL_Thread = type Pointer;

 TSDL_WindowID = type cuint32;
 TSDL_DisplayID = type cuint32;
 TSDL_WindowFlags = type cuint64;
 TSDL_InitFlags = type cuint32;
 TSDL_BlendMode = cuint32;
 TSDL_PixelFormat = Integer;
 TSDL_SurfaceFlags = type cuint32;
 TSDL_TimerID = cuint32;
 TSDL_MouseID = cuint32;
 TSDL_KeyboardID = cuint32;
 TSDL_MouseButtonFlags = type cuint32;
 TSDL_MouseWheelDirection = Integer;
 TSDL_Scancode = Integer;
 TSDL_Keycode = cuint32;
 TSDL_Keymod = cuint16;
 TSDL_EventType = type Integer;

 PSDL_Rect = ^TSDL_Rect;
 TSDL_Rect = record
  x: cint;
  y: cint;
  w: cint;
  h: cint;
 end;

 PSDL_FRect = ^TSDL_FRect;
 TSDL_FRect = record
  x: cfloat;
  y: cfloat;
  w: cfloat;
  h: cfloat;
 end;

 PSDL_Surface = ^TSDL_Surface;
 TSDL_Surface = record
  flags: TSDL_SurfaceFlags;
  format: TSDL_PixelFormat;
  w: cint;
  h: cint;
  pitch: cint;
  pixels: Pointer;
  refcount: cint;
  reserved: Pointer;
 end;

 PSDL_Texture = ^TSDL_Texture;
 TSDL_Texture = record
  format: TSDL_PixelFormat;
  w: cint;
  h: cint;
  refcount: cint;
 end;

 TSDL_TimerCallback = function(userdata: Pointer; timerID: TSDL_TimerID;
                                          interval: cuint32): cuint32; cdecl;

 { events }
 TSDL_CommonEvent = record
  type_: cuint32;
  reserved: cuint32;
  timestamp: cuint64;
 end;

 PSDL_WindowEvent = ^TSDL_WindowEvent;
 TSDL_WindowEvent = record
  type_: TSDL_EventType;
  reserved: cuint32;
  timestamp: cuint64;
  windowID: TSDL_WindowID;
  data1: cint32;
  data2: cint32;
 end;

 PSDL_KeyboardEvent = ^TSDL_KeyboardEvent;
 TSDL_KeyboardEvent = record
  type_: TSDL_EventType;
  reserved: cuint32;
  timestamp: cuint64;
  windowID: TSDL_WindowID;
  which: TSDL_KeyboardID;
  scancode: TSDL_Scancode;
  key: TSDL_Keycode;
  mod_: TSDL_Keymod;
  raw: cuint16;
  down: Boolean;
  repeat_: Boolean;
 end;

 PSDL_TextInputEvent = ^TSDL_TextInputEvent;
 TSDL_TextInputEvent = record
  type_: TSDL_EventType;
  reserved: cuint32;
  timestamp: cuint64;
  windowID: TSDL_WindowID;
  text: PAnsiChar;
 end;

 PSDL_MouseMotionEvent = ^TSDL_MouseMotionEvent;
 TSDL_MouseMotionEvent = record
  type_: TSDL_EventType;
  reserved: cuint32;
  timestamp: cuint64;
  windowID: TSDL_WindowID;
  which: TSDL_MouseID;
  state: TSDL_MouseButtonFlags;
  x: cfloat;
  y: cfloat;
  xrel: cfloat;
  yrel: cfloat;
 end;

 PSDL_MouseButtonEvent = ^TSDL_MouseButtonEvent;
 TSDL_MouseButtonEvent = record
  type_: TSDL_EventType;
  reserved: cuint32;
  timestamp: cuint64;
  windowID: TSDL_WindowID;
  which: TSDL_MouseID;
  button: cuint8;
  down: Boolean;
  clicks: cuint8;
  padding: cuint8;
  x: cfloat;
  y: cfloat;
 end;

 PSDL_MouseWheelEvent = ^TSDL_MouseWheelEvent;
 TSDL_MouseWheelEvent = record
  type_: TSDL_EventType;
  reserved: cuint32;
  timestamp: cuint64;
  windowID: TSDL_WindowID;
  which: TSDL_MouseID;
  x: cfloat;
  y: cfloat;
  direction: TSDL_MouseWheelDirection;
  mouse_x: cfloat;
  mouse_y: cfloat;
  integer_x: cint32;
  integer_y: cint32;
 end;

 PSDL_UserEvent = ^TSDL_UserEvent;
 TSDL_UserEvent = record
  type_: cuint32;
  reserved: cuint32;
  timestamp: cuint64;
  windowID: TSDL_WindowID;
  code: cint32;
  data1: Pointer;
  data2: Pointer;
 end;

 { the union is 128 bytes in SDL3, the timestamp member keeps its 8 byte
   alignment }
 PSDL_Event = ^TSDL_Event;
 TSDL_Event = record
  case Integer of
   0: (type_: cuint32);
   1: (common: TSDL_CommonEvent);
   2: (padding: array[0..127] of cuint8);
 end;

const
 SDL_INIT_VIDEO = TSDL_InitFlags($00000020);

 SDL_PIXELFORMAT_XRGB8888 = TSDL_PixelFormat($16161804);
 SDL_PIXELFORMAT_ARGB8888 = TSDL_PixelFormat($16362004);
 SDL_PIXELFORMAT_ABGR8888 = TSDL_PixelFormat($16762004);

{ init, error, hints }
function SDL_Init(flags: TSDL_InitFlags): Boolean; cdecl;
                                                      external SDL_LibName;
procedure SDL_Quit; cdecl; external SDL_LibName;
function SDL_SetHint(name: PAnsiChar; value: PAnsiChar): Boolean; cdecl;
                                                      external SDL_LibName;
function SDL_GetError: PAnsiChar; cdecl; external SDL_LibName;
function SDL_ClearError: Boolean; cdecl; external SDL_LibName;
function SDL_GetCurrentVideoDriver: PAnsiChar; cdecl; external SDL_LibName;

{ windows }
function SDL_CreateWindow(title: PAnsiChar; w: cint; h: cint;
              flags: TSDL_WindowFlags): PSDL_Window; cdecl; external SDL_LibName;
function SDL_CreatePopupWindow(parent: PSDL_Window; offset_x: cint;
              offset_y: cint; w: cint; h: cint; flags: TSDL_WindowFlags):
              PSDL_Window; cdecl; external SDL_LibName;
procedure SDL_DestroyWindow(window: PSDL_Window); cdecl; external SDL_LibName;
function SDL_ShowWindow(window: PSDL_Window): Boolean; cdecl;
                                                      external SDL_LibName;
function SDL_HideWindow(window: PSDL_Window): Boolean; cdecl;
                                                      external SDL_LibName;
function SDL_RaiseWindow(window: PSDL_Window): Boolean; cdecl;
                                                      external SDL_LibName;
function SDL_MinimizeWindow(window: PSDL_Window): Boolean; cdecl;
                                                      external SDL_LibName;
function SDL_MaximizeWindow(window: PSDL_Window): Boolean; cdecl;
                                                      external SDL_LibName;
function SDL_GetWindowPosition(window: PSDL_Window; x: pcint; y: pcint):
                                  Boolean; cdecl; external SDL_LibName;
function SDL_SetWindowPosition(window: PSDL_Window; x: cint; y: cint):
                                  Boolean; cdecl; external SDL_LibName;
function SDL_GetWindowSize(window: PSDL_Window; w: pcint; h: pcint): Boolean;
                                  cdecl; external SDL_LibName;
function SDL_SetWindowSize(window: PSDL_Window; w: cint; h: cint): Boolean;
                                  cdecl; external SDL_LibName;
function SDL_GetWindowFlags(window: PSDL_Window): TSDL_WindowFlags; cdecl;
                                                      external SDL_LibName;
function SDL_SetWindowFullscreen(window: PSDL_Window; fullscreen: Boolean):
                                  Boolean; cdecl; external SDL_LibName;
function SDL_SetWindowTitle(window: PSDL_Window; title: PAnsiChar): Boolean;
                                  cdecl; external SDL_LibName;
function SDL_SetWindowIcon(window: PSDL_Window; icon: PSDL_Surface): Boolean;
                                  cdecl; external SDL_LibName;
function SDL_GetWindowSurface(window: PSDL_Window): PSDL_Surface; cdecl;
                                                      external SDL_LibName;
function SDL_UpdateWindowSurface(window: PSDL_Window): Boolean; cdecl;
                                                      external SDL_LibName;
function SDL_DestroyWindowSurface(window: PSDL_Window): Boolean; cdecl;
                                                      external SDL_LibName;
function SDL_GetWindowID(window: PSDL_Window): TSDL_WindowID; cdecl;
                                                      external SDL_LibName;
function SDL_GetWindowFromID(id: TSDL_WindowID): PSDL_Window; cdecl;
                                                      external SDL_LibName;
function SDL_GetPrimaryDisplay: TSDL_DisplayID; cdecl; external SDL_LibName;
function SDL_GetDisplayBounds(displayID: TSDL_DisplayID; rect: PSDL_Rect):
                                  Boolean; cdecl; external SDL_LibName;
function SDL_SetWindowParent(window: PSDL_Window; parent: PSDL_Window):
                                  Boolean; cdecl; external SDL_LibName;
function SDL_SetWindowModal(window: PSDL_Window; modal: Boolean): Boolean;
                                  cdecl; external SDL_LibName;
function SDL_StartTextInput(window: PSDL_Window): Boolean; cdecl;
                                                      external SDL_LibName;

{ mouse and cursor }
function SDL_GetMouseState(x: pcfloat; y: pcfloat): TSDL_MouseButtonFlags;
                                  cdecl; external SDL_LibName;
function SDL_GetGlobalMouseState(x: pcfloat; y: pcfloat):
                    TSDL_MouseButtonFlags; cdecl; external SDL_LibName;
procedure SDL_WarpMouseInWindow(window: PSDL_Window; x: cfloat; y: cfloat);
                                  cdecl; external SDL_LibName;
function SDL_CaptureMouse(enabled: Boolean): Boolean; cdecl;
                                                      external SDL_LibName;
function SDL_CreateCursor(data: pcuint8; mask: pcuint8; w: cint; h: cint;
              hot_x: cint; hot_y: cint): PSDL_Cursor; cdecl;
                                                      external SDL_LibName;
function SDL_SetCursor(cursor: PSDL_Cursor): Boolean; cdecl;
                                                      external SDL_LibName;

{ surfaces }
function SDL_CreateSurface(width: cint; height: cint; format: TSDL_PixelFormat):
                                  PSDL_Surface; cdecl; external SDL_LibName;
function SDL_CreateSurfaceFrom(width: cint; height: cint;
              format: TSDL_PixelFormat; pixels: Pointer; pitch: cint):
                                  PSDL_Surface; cdecl; external SDL_LibName;
procedure SDL_DestroySurface(surface: PSDL_Surface); cdecl;
                                                      external SDL_LibName;
function SDL_SetSurfaceBlendMode(surface: PSDL_Surface;
              blendMode: TSDL_BlendMode): Boolean; cdecl; external SDL_LibName;
function SDL_BlitSurface(src: PSDL_Surface; srcrect: PSDL_Rect;
              dst: PSDL_Surface; dstrect: PSDL_Rect): Boolean; cdecl;
                                                      external SDL_LibName;

{ renderer }
function SDL_CreateSoftwareRenderer(surface: PSDL_Surface): PSDL_Renderer;
                                  cdecl; external SDL_LibName;
function SDL_CreateRenderer(window: PSDL_Window; name: PAnsiChar):
                                  PSDL_Renderer; cdecl; external SDL_LibName;
function SDL_GetRenderer(window: PSDL_Window): PSDL_Renderer; cdecl;
                                                      external SDL_LibName;
procedure SDL_DestroyRenderer(renderer: PSDL_Renderer); cdecl;
                                                      external SDL_LibName;
function SDL_GetRenderOutputSize(renderer: PSDL_Renderer; w: pcint;
              h: pcint): Boolean; cdecl; external SDL_LibName;
function SDL_SetRenderClipRect(renderer: PSDL_Renderer; rect: PSDL_Rect):
                                  Boolean; cdecl; external SDL_LibName;
function SDL_SetRenderDrawColor(renderer: PSDL_Renderer; r: cuint8; g: cuint8;
              b: cuint8; a: cuint8): Boolean; cdecl; external SDL_LibName;
function SDL_SetRenderDrawBlendMode(renderer: PSDL_Renderer;
              blendMode: TSDL_BlendMode): Boolean; cdecl; external SDL_LibName;
function SDL_RenderClear(renderer: PSDL_Renderer): Boolean; cdecl;
                                                      external SDL_LibName;
function SDL_RenderLine(renderer: PSDL_Renderer; x1: cfloat; y1: cfloat;
              x2: cfloat; y2: cfloat): Boolean; cdecl; external SDL_LibName;
function SDL_RenderPoint(renderer: PSDL_Renderer; x: cfloat; y: cfloat):
                                  Boolean; cdecl; external SDL_LibName;
function SDL_RenderFillRect(renderer: PSDL_Renderer; rect: PSDL_FRect):
                                  Boolean; cdecl; external SDL_LibName;
function SDL_RenderTexture(renderer: PSDL_Renderer; texture: PSDL_Texture;
              srcrect: PSDL_FRect; dstrect: PSDL_FRect): Boolean; cdecl;
                                                      external SDL_LibName;
function SDL_RenderReadPixels(renderer: PSDL_Renderer; rect: PSDL_Rect):
                                  PSDL_Surface; cdecl; external SDL_LibName;
function SDL_RenderPresent(renderer: PSDL_Renderer): Boolean; cdecl;
                                                      external SDL_LibName;
function SDL_FlushRenderer(renderer: PSDL_Renderer): Boolean; cdecl;
                                                      external SDL_LibName;
function SDL_CreateTextureFromSurface(renderer: PSDL_Renderer;
              surface: PSDL_Surface): PSDL_Texture; cdecl; external SDL_LibName;
procedure SDL_DestroyTexture(texture: PSDL_Texture); cdecl;
                                                      external SDL_LibName;
function SDL_SetTextureBlendMode(texture: PSDL_Texture;
              blendMode: TSDL_BlendMode): Boolean; cdecl; external SDL_LibName;

{ events }
function SDL_PollEvent(event: PSDL_Event): Boolean; cdecl;
                                                      external SDL_LibName;
procedure SDL_PumpEvents; cdecl; external SDL_LibName;
function SDL_PushEvent(event: PSDL_Event): Boolean; cdecl;
                                                      external SDL_LibName;
function SDL_RegisterEvents(numevents: cint): cuint32; cdecl;
                                                      external SDL_LibName;

{ timer }
function SDL_AddTimer(interval: cuint32; callback: TSDL_TimerCallback;
              userdata: Pointer): TSDL_TimerID; cdecl; external SDL_LibName;
function SDL_RemoveTimer(id: TSDL_TimerID): Boolean; cdecl;
                                                      external SDL_LibName;
function SDL_GetTicks: cuint64; cdecl; external SDL_LibName;

{ clipboard }
function SDL_SetClipboardText(text: PAnsiChar): Boolean; cdecl;
                                                      external SDL_LibName;
function SDL_HasClipboardText: Boolean; cdecl; external SDL_LibName;
function SDL_GetClipboardText: PAnsiChar; cdecl; external SDL_LibName;

{ mutex, semaphore, thread }
function SDL_CreateMutex(): PSDL_Mutex; cdecl; external SDL_LibName;
procedure SDL_LockMutex(mutex: PSDL_Mutex); cdecl; external SDL_LibName;
procedure SDL_UnlockMutex(mutex: PSDL_Mutex); cdecl; external SDL_LibName;
procedure SDL_DestroyMutex(mutex: PSDL_Mutex); cdecl; external SDL_LibName;
function SDL_CreateSemaphore(initial_value: cuint32): PSDL_Semaphore; cdecl;
                                                      external SDL_LibName;
procedure SDL_DestroySemaphore(sem: PSDL_Semaphore); cdecl;
                                                      external SDL_LibName;
procedure SDL_SignalSemaphore(sem: PSDL_Semaphore); cdecl;
                                                      external SDL_LibName;
function SDL_TryWaitSemaphore(sem: PSDL_Semaphore): Boolean; cdecl;
                                                      external SDL_LibName;
function SDL_WaitSemaphoreTimeout(sem: PSDL_Semaphore; timeoutMS: cint32):
                                  Boolean; cdecl; external SDL_LibName;
function SDL_GetSemaphoreValue(sem: PSDL_Semaphore): cuint32; cdecl;
                                                      external SDL_LibName;
procedure SDL_WaitThread(thread: PSDL_Thread; status: pcint); cdecl;
                                                      external SDL_LibName;

implementation

end.
