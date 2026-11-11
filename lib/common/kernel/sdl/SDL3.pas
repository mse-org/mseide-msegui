unit SDL3;

{
                                SDL3-for-Pascal
                               =================
          Pascal units for SDL3 - Simple Direct MediaLayer, Version 3

  (to be extended - todo)

}

{$I sdl.inc}

interface

  {$IFDEF WINDOWS}
    uses
      {$IFDEF FPC}
      ctypes,
      {$ENDIF}
      Windows;
  {$ENDIF}

  {$IF DEFINED(UNIX) AND NOT DEFINED(ANDROID)}
    uses
      {$IFDEF FPC}
      ctypes,
      UnixType,
      {$ENDIF}
      {$IFDEF DARWIN}
      CocoaAll;
      {$ELSE}
      X,
      XLib;
      {$ENDIF}
  {$ENDIF}

  {$IF DEFINED(UNIX) AND DEFINED(ANDROID) AND DEFINED(FPC)}
    uses
      ctypes,
      UnixType;
  {$ENDIF}

const

  {$IFDEF WINDOWS}
    SDL_LibName = 'SDL3.dll';
  {$ENDIF}

  {$IFDEF UNIX}
    {$IFDEF DARWIN}
      SDL_LibName = 'libSDL3.dylib';
      {$IFDEF FPC}
        {$LINKLIB libSDL3}
      {$ENDIF}
    {$ELSE}
      {$IFDEF FPC}
        SDL_LibName = 'libSDL3.so';
      {$ELSE}
        SDL_LibName = 'libSDL3.so.0';
      {$ENDIF}
    {$ENDIF}
  {$ENDIF}

  {$IFDEF MACOS}
    SDL_LibName = 'SDL3';
    {$IFDEF FPC}
      {$linklib libSDL3}
    {$ENDIF}
  {$ENDIF}

{$DEFINE WANT_CWCHAR_T}                   // want wchar_t type in this unit
{$I ctypes.inc}                           // C data types

{ The include file translates
  corresponding C header file.
                                          Inc file was updated against
  SDL_init.inc --> SDL_init.h             this version of the header file: }
{$I SDL_log.inc}                          // 3.4.2
{$I SDL_version.inc}                      // 3.4.2
{$I SDL_revision.inc}                     // 3.4.2
{$I SDL_locale.inc}                       // 3.4.4
{$I SDL_guid.inc}                         // 3.4.2
{$I SDL_hints.inc}                        // 3.4.4
{$I SDL_misc.inc}                         // 3.4.4
{$I SDL_stdinc.inc}                       // 3.1.6-prev (unfinished)
{$I SDL_platform.inc}                     // 3.4.4
{$I SDL_loadso.inc}                       // 3.4.4
{$I SDL_rect.inc}                         // 3.4.2
{$I SDL_properties.inc}                   // 3.4.2
{$I SDL_pixels.inc}                       // 3.4.2
{$I SDL_blendmode.inc}                    // 3.4.2
{$I SDL_iostream.inc}                     // 3.4.4
{$I SDL_asyncio.inc}                      // 3.4.4
{$I SDL_surface.inc}                      // 3.4.4
{$I SDL_video.inc}                        // 3.4.2
{$I SDL_timer.inc}                        // 3.4.4
{$I SDL_error.inc}                        // 3.4.2
{$I SDL_power.inc}                        // 3.4.2
{$I SDL_audio.inc}                        // 3.4.2
{$I SDL_sensor.inc}                       // 3.4.4
{$I SDL_scancode.inc}                     // 3.4.4
{$I SDL_keycode.inc}                      // 3.4.4
{$I SDL_mouse.inc}                        // 3.4.4
{$I SDL_keyboard.inc}                     // 3.4.4
{$I SDL_joystick.inc}                     // 3.4.4
{$I SDL_gamepad.inc}                      // 3.4.4
{$I SDL_haptic.inc}                       // 3.4.4
{$I SDL_touch.inc}                        // 3.4.4
{$I SDL_pen.inc}                          // 3.4.4
{$I SDL_camera.inc}                       // 3.4.4
{$I SDL_events.inc}                       // 3.4.4
{$I SDL_init.inc}                         // 3.4.4
{$I SDL_gpu.inc}                          // 3.4.4
{$I SDL_render.inc}                       // 3.4.4
{$I SDL_clipboard.inc}                    // 3.4.4
{$I SDL_cpuinfo.inc}                      // 3.4.4
{$I SDL_dialog.inc}                       // 3.4.4
{$I SDL_messagebox.inc}                   // 3.4.4
{$I SDL_time.inc}                         // 3.4.4
{$I SDL_filesystem.inc}                   // 3.4.4
{$I SDL_atomic.inc}                       // 3.4.4
{$I SDL_hidapi.inc}                       // 3.4.4
{$I SDL_metal.inc}                        // 3.4.4
{$I SDL_vulkan.inc}                       // 3.4.4
{$I SDL_thread.inc}                       // 3.4.4
{$I SDL_process.inc}                      // 3.4.4
{$I SDL_storage.inc}                      // 3.4.4
{$I SDL_tray.inc}                         // 3.4.4
{$I SDL_mutex.inc}                        // 3.4.4



implementation

{ Macros from SDL_version.h }
function SDL_VERSIONNUM(major, minor, patch: Integer): Integer;
begin
  Result:=(major*1000000)+(minor*1000)+patch;
end;

function SDL_VERSIONNUM_MAJOR(version: Integer): Integer;
begin
  Result:=version div 1000000;
end;

function SDL_VERSIONNUM_MINOR(version: Integer): Integer;
begin
  Result:=(version div 1000) mod 1000;
end;

function SDL_VERSIONNUM_MICRO(version: Integer): Integer;
begin
  Result:=version mod 1000;
end;

function SDL_VERSION: Integer;
begin
  Result:=SDL_VERSIONNUM(SDL_MAJOR_VERSION, SDL_MINOR_VERSION, SDL_MICRO_VERSION);
end;

function SDL_VERSION_ATLEAST(X, Y, Z: Integer): Boolean;
begin
  if (SDL_VERSION >= SDL_VERSIONNUM(X, Y, Z)) then
    Result:=True
  else
    Result:=False;
end;

{ Macros from SDL_rect.h }
procedure SDL_RectToFRect(const rect: PSDL_Rect; frect: PSDL_FRect);
begin
  frect^.x:=cfloat(rect^.x);
  frect^.y:=cfloat(rect^.y);
  frect^.w:=cfloat(rect^.w);
  frect^.h:=cfloat(rect^.h);
end;

function SDL_PointInRect(const p: PSDL_Point; const r: PSDL_Rect): Boolean;
begin
  Result :=
    (p <> nil) and (r <> nil) and (p^.x >= r^.x) and (p^.x < (r^.x + r^.w)) and
    (p^.y >= r^.y) and (p^.y < (r^.y + r^.h));
end;

function SDL_RectEmpty(const r: PSDL_Rect): Boolean;
begin
  Result := (r = nil) or (r^.w <= 0) or (r^.h <= 0);
end;

function SDL_RectsEqual(const a: PSDL_Rect; const b: PSDL_Rect): Boolean;
begin
  Result := (a <> nil) and (b <> nil) and (a^.x = b^.x) and (a^.y = b^.y) and
    (a^.w = b^.w) and (a^.h = b^.h);
end;

function SDL_PointInRectFloat(const p: PSDL_FPoint; const r: PSDL_FRect): Boolean;
begin
  Result :=
    (p <> nil) and (r <> nil) and (p^.x >= r^.x) and (p^.x <= (r^.x + r^.w)) and
    (p^.y >= r^.y) and (p^.y <= (r^.y + r^.h));
end;

function SDL_RectEmptyFloat(const r: PSDL_FRect): Boolean;
begin
  Result := (r = nil) or (r^.w < cfloat(0.0)) or (r^.h < cfloat(0.0));
end;

function SDL_RectsEqualEpsilon(const a: PSDL_Frect; const b: PSDL_FRect;
  epsilon: cfloat): Boolean;
begin
  Result :=
    (a <> nil) and (b <> nil) and ((a = b) or
    ((SDL_fabsf(a^.x - b^.x) <= epsilon) and
    (SDL_fabsf(a^.y - b^.y) <= epsilon) and
    (SDL_fabsf(a^.w - b^.w) <= epsilon) and
    (SDL_fabsf(a^.h - b^.h) <= epsilon)));
end;

function SDL_RectsEqualFloat(const a: PSDL_FRect; b: PSDL_FRect): Boolean;
begin
  Result := SDL_RectsEqualEpsilon(a, b, SDL_FLT_EPSILON);
end;

{ Macros from SDL_timer.h }
function SDL_SECONDS_TO_NS(S: Integer): Integer;
begin
  SDL_SECONDS_TO_NS:=(cuint64(S))*SDL_NS_PER_SECOND;
end;

function SDL_NS_TO_SECONDS(NS: Integer): Integer;
begin
  SDL_NS_TO_SECONDS:=NS div SDL_NS_PER_SECOND;
end;

function SDL_MS_TO_NS(MS: Integer): Integer;
begin
  SDL_MS_TO_NS:=(cuint64(MS))*SDL_NS_PER_MS;
end;

function SDL_NS_TO_MS(NS: Integer): Integer;
begin
  SDL_NS_TO_MS:=NS div SDL_NS_PER_MS;
end;

function SDL_US_TO_NS(US: Integer): Integer;
begin
  SDL_US_TO_NS:=(cuint64(US))*SDL_NS_PER_US;
end;

function SDL_NS_TO_US(NS: Integer): Integer;
begin
  SDL_NS_TO_US:=NS div SDL_NS_PER_US;
end;

{ Macros from SDL_audio.h }
function SDL_DEFINE_AUDIO_FORMAT(signed: cuint16; bigendian: cuint16;
  float: cuint16; size: Integer): TSDL_AudioFormat;
begin
  Result:=(signed shl 15) or (bigendian shl 12) or (float shl 8) or (size and SDL_AUDIO_MASK_BITSIZE);
end;

function SDL_AUDIO_BITSIZE(x: TSDL_AudioFormat): Integer;
begin
  Result:=x and SDL_AUDIO_MASK_BITSIZE;
end;

function SDL_AUDIO_BYTESIZE(x: TSDL_AudioFormat): Integer;
begin
  Result:=SDL_AUDIO_BITSIZE(x) div 8;
end;

function SDL_AUDIO_ISFLOAT(x: TSDL_AudioFormat): Integer;
begin
  Result:=x and SDL_AUDIO_MASK_FLOAT;
end;

function SDL_AUDIO_ISBIGENDIAN(x: TSDL_AudioFormat): Integer;
begin
  Result:=x and SDL_AUDIO_MASK_BIG_ENDIAN;
end;

function SDL_AUDIO_ISLITTLEENDIAN(x: TSDL_AudioFormat): Integer;
begin
  Result:=not(x) and SDL_AUDIO_MASK_BIG_ENDIAN;
end;

function SDL_AUDIO_ISSIGNED(x: TSDL_AudioFormat): Integer;
begin
  Result:=x and SDL_AUDIO_MASK_SIGNED;
end;

function SDL_AUDIO_ISINT(x: TSDL_AudioFormat): Integer;
begin
  Result:=not(x) and SDL_AUDIO_MASK_FLOAT;
end;

function SDL_AUDIO_ISUNSIGNED(x: TSDL_AudioFormat): Integer;
begin
  Result:=not(x) and SDL_AUDIO_MASK_SIGNED;
end;

function SDL_AUDIO_FRAMESIZE(x: TSDL_AudioSpec): Integer;
begin
  Result:=SDL_AUDIO_BYTESIZE(x.format * x.channels);
end;

{ Macros from SDL_keycode.h }
function SDL_SCANCODE_TO_KEYCODE(X: TSDL_Scancode): TSDL_Keycode;
begin
  Result:=X or SDLK_SCANCODE_MASK;
end;

{ Macros from SDL_surface.h }
function SDL_MUSTLOCK(Const S: PSDL_Surface): Boolean;
begin
  Result:=(S^.flags and SDL_SURFACE_LOCK_NEEDED)=SDL_SURFACE_LOCK_NEEDED;
end;

{ Macros from SDL_video.h }
function SDL_WINDOWPOS_UNDEFINED_DISPLAY(X: Integer): Integer;
begin
  Result := (SDL_WINDOWPOS_UNDEFINED_MASK or X);
end;

function SDL_WINDOWPOS_ISUNDEFINED(X: Integer): Boolean;
begin
  Result := (X and $FFFF0000) = SDL_WINDOWPOS_UNDEFINED_MASK;
end;

function SDL_WINDOWPOS_CENTERED_DISPLAY(X: Integer): Integer;
begin
  Result := (SDL_WINDOWPOS_CENTERED_MASK or X);
end;

function SDL_WINDOWPOS_ISCENTERED(X: Integer): Boolean;
begin
  Result := (X and $FFFF0000) = SDL_WINDOWPOS_CENTERED_MASK;
end;

{ Macros from SDL_atomic.h }
function SDL_AtomicIncRef(a: PSDL_AtomicInt): cint;
begin
  SDL_AtomicIncRef:=SDL_AddAtomicInt(a,1);
end;

function SDL_AtomicDecRef(a: PSDL_AtomicInt): Boolean;
begin
  SDL_AtomicDecRef:=(SDL_AddAtomicInt(a,-1)=1);
end;

{ Macros from SDL_thread.h }
function SDL_CreateThread(fn: TSDL_ThreadFunction; name: PAnsiChar; data: Pointer): PSDL_Thread;
begin
  SDL_CreateThread:=SDL_CreateThreadRuntime(fn,name,data,TSDL_FunctionPointer(SDL_BeginThreadFunction),TSDL_FunctionPointer(SDL_EndThreadFunction));
end;

function SDL_CreateThreadWithProperties(props: TSDL_PropertiesID): PSDL_Thread;
begin
  SDL_CreateThreadWithProperties:=SDL_CreateThreadWithPropertiesRuntime(props,TSDL_FunctionPointer(SDL_BeginThreadFunction),TSDL_FunctionPointer(SDL_EndThreadFunction));
end;

end.

