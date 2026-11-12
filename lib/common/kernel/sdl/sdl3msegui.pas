unit sdl3msegui;
{ SDL2 style names and types on top of SDL3 (through sdl3api), so that
  msesdlgdi.pas and mseguiintf.pas stay unchanged }
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes,msesystypes,mseguiglob,sysutils,ctypes,msekeyboard,msesysutils,msegraphutils,
 sdl3api;
{$i sdl2_types.inc}

const
 sdldebug = true;   // true: print diagnostics of the SDL backend

const
 SDL_INIT_TIMER = $00000001;
 SDL_INIT_AUDIO = $00000010;
 SDL_INIT_VIDEO = $00000020;
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

 SDL_Surface = record           // SDL3 layout
  flags: cardinal;
  format: cardinal;
  w, h: integer;
  pitch: integer;
  pixels: pointer;
  refcount: integer;
  reserved: pointer;
 end;
 CSDL_Surface = ^SDL_Surface;
 PSDL_Surface = pixmapty;

 {$I sdl_EventConsts.inc}

type
 SDL_scancode = 0..SDL_NUM_SCANCODES;

const
 SDL_WINDOWEVENT_NONE = 0;
 SDL_WINDOWEVENT_SHOWN = 1;
 SDL_WINDOWEVENT_HIDDEN = 2;
 SDL_WINDOWEVENT_EXPOSED = 3;
 SDL_WINDOWEVENT_MOVED = 4;
 SDL_WINDOWEVENT_RESIZED = 5;
 SDL_WINDOWEVENT_SIZE_CHANGED = 6;
 SDL_WINDOWEVENT_MINIMIZED = 7;
 SDL_WINDOWEVENT_MAXIMIZED = 8;
 SDL_WINDOWEVENT_RESTORED = 9;
 SDL_WINDOWEVENT_ENTER = 10;
 SDL_WINDOWEVENT_LEAVE = 11;
 SDL_WINDOWEVENT_FOCUS_GAINED = 12;
 SDL_WINDOWEVENT_FOCUS_LOST = 13;
 SDL_WINDOWEVENT_CLOSE = 14;

 TEXT_SIZE = 32;

 SDL_BUTTON_LMASK = (1 << ((1)-1));
 SDL_BUTTON_MMASK = (1 << ((2)-1));
 SDL_BUTTON_RMASK = (1 << ((3)-1));

type
 SDL_KeyCode = longword;
 SDL_KeyMod = longword;

 SDL_Keysym = record
  scancode: SDL_scancode;
  sym: SDL_KeyCode;
  mods: SDL_KeyMod;
  unicode: cardinal;
 end;

 SDL_Window_Event = record
  type_: cardinal;
  timestamp: cardinal;
  window: cardinal;
  event: byte;
  padding1: byte;
  padding2: byte;
  Data1: integer;
  Data2: integer;
 end;

 SDL_KeyboardEvent = record
  type_: cardinal;
  timestamp: cardinal;
  window: cardinal;
  state: byte;
  repeat_: byte;
  padding2: byte;
  padding3: byte;
  keysym: SDL_Keysym;
 end;

 SDL_TextInputEvent = record
  type_: cardinal;
  timestamp: cardinal;
  window: cardinal;
  text: array[0..TEXT_SIZE - 1] of AnsiChar;
 end;

 SDL_MouseMotionEvent = record
  type_: cardinal;
  timestamp: cardinal;
  window: cardinal;
  which: cardinal;
  state: cardinal;
  x: integer;
  y: integer;
  xrel: integer;
  yrel: integer;
 end;

 SDL_MouseButtonEvent = record
  type_: cardinal;
  timestamp: cardinal;
  window: cardinal;
  which: cardinal;
  button: byte;
  state: byte;
  clicks: byte;
  padding: byte;
  x: integer;
  y: integer;
 end;

 SDL_MouseWheelEvent = record
  type_: cardinal;
  timestamp: cardinal;
  window: cardinal;      // SDL window id (32 bit), not a handle
  which: cardinal;
  x: integer;
  y: integer;
  direction: cardinal;
 end;

 SDL_QuitEvent = record
  type_: cardinal;
 end;

 SDL_User_Event = record
  type_: cardinal;
  windowID: cardinal;
  code: integer;
  data1: pointer;
  data2: pointer;
 end;

 SDL_Event = record
  case UInt32 of
   SDL_FIRSTEVENT: (type_: cardinal);
   SDL_QUITEV: (quit: SDL_QuitEvent);
   SDL_WINDOWEVENT: (window: SDL_Window_Event);
   SDL_KEYDOWN,SDL_KEYUP: (key: SDL_KeyboardEvent);
   SDL_TEXTINPUT: (text: SDL_TextInputEvent);
   SDL_MOUSEMOTION: (motion: SDL_MouseMotionEvent);
   SDL_MOUSEBUTTONDOWN,SDL_MOUSEBUTTONUP: (button: SDL_MouseButtonEvent);
   SDL_MOUSEWHEEL: (wheel: SDL_MouseWheelEvent);
   SDL_USEREVENT: (user: SDL_User_Event);
 end;
 PSDL_Event = ^SDL_Event;

const
 SDL_WINDOW_FULLSCREEN = $00000001;
 SDL_WINDOW_OPENGL = $00000002;
 SDL_WINDOW_SHOWN = $00000004;
 SDL_WINDOW_HIDDEN = $00000008;
 SDL_WINDOW_BORDERLESS = $00000010;
 SDL_WINDOW_RESIZABLE = $00000020;
 SDL_WINDOW_MINIMIZED = $00000040;
 SDL_WINDOW_MAXIMIZED = $00000080;
 SDL_WINDOW_INPUT_GRABBED = $00000100;
 SDL_WINDOW_INPUT_FOCUS = $00000200;
 SDL_WINDOW_MOUSE_FOCUS = $00000400;
 SDL_WINDOW_FOREIGN = $00000800;

 SDL_WINDOWPOS_CENTERED_MASK = $2FFF0000;
 SDL_WINDOWPOS_CENTERED = SDL_WINDOWPOS_CENTERED_MASK or 0;

type
 SDL_WindowFlags = UInt32;

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
 SDL_Texture = ptruint;
 SDL_Renderer = ptruint;
 SDL_BlendMode = (SDL_BLENDMODE_NONE = $00000000,
                  SDL_BLENDMODE_BLEND = $00000001,
                  SDL_BLENDMODE_ADD = $00000002,
                  SDL_BLENDMODE_MOD = $00000004);

const
 SDL_RENDERER_SOFTWARE = $00000001;
 SDL_RENDERER_ACCELERATED = $00000002;
 SDL_RENDERER_PRESENTVSYNC = $00000004;
 SDL_RENDERER_TARGETTEXTURE = $00000008;

function SDL_Init(flags: Cardinal): Integer;
procedure SDL_Quit;
function SDL_SetHint(name, value: pchar): boolean;

function SDL_CreateWindow(title: PChar; x, y, w, h: integer;
                                      flags: SDL_WindowFlags): winidty;
procedure SDL_DestroyWindow(window: winidty);
procedure SDL_ShowWindow(window: winidty);
procedure SDL_HideWindow(window: winidty);
procedure SDL_RaiseWindow(window: winidty);
procedure SDL_GetWindowPosition(window: winidty; var x, y: integer);
procedure SDL_SetWindowPosition(window: winidty; x, y: integer);
procedure SDL_GetWindowSize(window: winidty; var w, h: integer);
procedure SDL_SetWindowSize(window: winidty; w, h: integer);
function SDL_GetWindowFlags(window: winidty): SDL_WindowFlags;
procedure SDL_MinimizeWindow(window: winidty);
procedure SDL_MaximizeWindow(window: winidty);
function SDL_SetWindowFullscreen(window: winidty; fullscreen: boolean): integer;
procedure SDL_SetWindowTitle(window: winidty; const title: PChar);
procedure SDL_SetWindowIcon(window: winidty; icon: PSDL_Surface);
function SDL_UpdateWindowSurface(window: winidty): integer;

function SDL_DestroyWindowSurface(window: winidty): integer;

function SDL_GetWindowFromID(id: cardinal): winidty;

function SDL_CreatePopupWindow(parent: winidty; x, y, w, h: integer;
                                      flags: SDL_WindowFlags): winidty;

function SDL_GetWindowSurface(window: winidty): PSDL_Surface;
function SDL_GetDisplayBounds(displayIndex: integer; rect: PSDL_Rect): integer;

function SDL_GetError: pchar;
procedure SDL_ClearError;
function SDL_CheckError(ref: string): guierrorty;
function SDL_CheckErrorGDI(ref: string): gdierrorty;

function SDL_CreateMutex: mutexty;
procedure SDL_DestroyMutex(varmutex: mutexty);
function SDL_LockMutex(mutex: mutexty): integer;
function SDL_UnlockMutex(mutex: mutexty): integer;
function SDL_mutexP(mutex: mutexty): integer;
function SDL_mutexV(mutex: mutexty): integer;
function SDL_CreateSemaphore(initial_value: cardinal): semty;
function SDL_SemPost(sem: semty): integer;
procedure SDL_DestroySemaphore(sem: semty);
function SDL_SemWaitTimeout(sem: semty; ms: cardinal): integer;
function SDL_SemValue(sem: semty): cardinal;
function SDL_SemTryWait(sem: semty): integer;
procedure SDL_WaitThread(thread: pointer; status: pinteger);

function SDL_GetGlobalMouseState(x,y: pinteger): cardinal;
function SDL_GetMouseState(x,y: pinteger): byte;
procedure SDL_WarpMouseInWindow(window: winidty; x, y: integer);
function SDL_CreateCursor(const data: pbyte; const Umask: pbyte;
                                  w,h,hot_x,hot_y: integer): SDL_Cursor;
procedure SDL_SetCursor(cursor: SDL_Cursor);
function SDL_CaptureMouse(enabled: integer): integer;

function SDL_GetCurrentVideoDriver: pchar;
function SDL_CreateRenderer(window: winidty; index: integer;
                                      flags: Cardinal): SDL_Renderer;
function SDL_GetRenderer(window: winidty): SDL_Renderer;
function SDL_GetRendererOutputSize(renderer: SDL_Renderer;
                                                  w, h: pinteger): integer;
function SDL_RenderSetClipRect(renderer: SDL_Renderer;
                                                  rect: PSDL_Rect): LongInt;
function SDL_CreateSoftwareRenderer(surface: PSDL_Surface): SDL_Renderer;
procedure SDL_DestroyRenderer(renderer: SDL_Renderer);
function SDL_CreateTextureFromSurface(renderer: SDL_Renderer;
                                          surface: PSDL_Surface): SDL_Texture;
function SDL_SetRenderDrawColor(renderer: SDL_Renderer;
                                            r, g, b, a: byte): integer;
function SDL_RenderReadPixels(renderer: SDL_Renderer; const rect: PSDL_Rect;
                  format: Uint32; pixels: pointer; pitch: integer): integer;
function SDL_SetRenderDrawBlendMode(renderer: SDL_Renderer;
                                            blendMode: SDL_BlendMode): integer;
function SDL_RenderClear(renderer: SDL_Renderer): Integer;
function SDL_RenderDrawLine(renderer: SDL_Renderer;
                                            x1, y1, x2, y2: integer): integer;
function SDL_RenderFillRect(renderer: SDL_Renderer;
                                            const rect: PSDL_Rect): integer;
function SDL_RenderDrawPoint(renderer: SDL_Renderer; x: integer;
                                                         y: integer): integer;
function SDL_RenderCopy(renderer: SDL_Renderer; texture: SDL_Texture;
                          const srcrect, dstrect: PSDL_Rect): integer;
procedure SDL_RenderPresent(renderer: SDL_Renderer);
procedure SDL_DestroyTexture(textureID: SDL_Texture);
function SDL_SetTextureBlendMode(texture: SDL_Texture;
                                            blendMode: SDL_BlendMode): Integer;

function SDL_CreateRGBSurface(flags: cardinal; width: integer; height: integer;
                depth: integer; Rmask: Uint32; Gmask: Uint32; Bmask: Uint32;
                Amask: Uint32): PSDL_Surface;
function SDL_CreateRGBSurfaceFrom(pixels: pointer; width: integer;
                height: integer; depth: integer; pitch: integer;
                Rmask: Uint32; Gmask: Uint32; Bmask: Uint32;
                Amask: Uint32): PSDL_Surface;
procedure SDL_FreeSurface(surface: PSDL_Surface);
function SDL_UpperBlit(src: PSDL_Surface; const srcrect: PSDL_Rect;
                              dst: PSDL_Surface; dstrect: PSDL_Rect): integer;
procedure SDL_UnlockSurface(surface: PSDL_Surface);
function SDL_SetSurfaceBlendMode(surface: PSDL_Surface;
                                            blendMode: SDL_BlendMode): integer;

procedure SDL_PumpEvents;
function SDL_HasEvents(minType, maxType: Cardinal): boolean;
function SDL_PollEvent(event: PSDL_Event): integer;
function SDL_PushEvent(const event: PSDL_Event): integer;
function SDL_RegisterEvents(numevents: integer): cardinal;

function SDL_AddTimer(interval: UInt32; callback: pointer;
                                                param: Pointer): integer;
procedure SDL_RemoveTimer(id: integer);
function SDL_GetTicks: UInt32;

function SDL_SetClipboardText(const text: pchar): integer;
function SDL_HasClipboardText: boolean;
function SDL_GetClipboardText: pchar;

function checkbutton(const mousestate: byte): mousebuttonty;
function checkbuttonindex(const buttonindex: byte): mousebuttonty;
function sdlmousetoshiftstate(keys: byte): shiftstatesty;
function SDL_KeyCodeToKey(acode: SDL_KeyCode): keyty;
function SDL_GetShiftState(akeyevent: SDL_KeyboardEvent): shiftstatesty;

implementation

function w3(win: winidty): pointer; inline;
begin
 result:= pointer(ptruint(win));
end;

function s3(surface: PSDL_Surface): pointer; inline;
begin
 result:= pointer(ptruint(surface));
end;

function r3(renderer: SDL_Renderer): pointer; inline;
begin
 result:= pointer(ptruint(renderer));
end;

function ok(value: boolean): integer; inline;
begin
 if value then begin
  result:= 0;
 end
 else begin
  result:= -1;
 end;
end;



type
  wininfoty = record
  id: winidty;
  parent: winidty;       // parent of a popup, 0 for top level windows
  ispopup: boolean;
  hidden: boolean;       // popup created hidden, shown when its size is set
  showdue: qword;        // tick count after which a hidden popup is shown anyway
  x,y: integer;          // position in MSEgui screen coordinates
 end; 
 
var
 wins: array of wininfoty;
 waylanddriver: boolean;

function findwin(id: winidty): integer;
var
 i: integer;
begin
 result:= -1;
 for i:= 0 to high(wins) do begin
  if wins[i].id = id then begin
   result:= i;
   break;
  end;
 end;
end;

procedure addwin(id,parent: winidty; popup: boolean; x,y: integer);
var
 n: integer;
begin
 if id = 0 then begin
  exit;
 end;
 n:= findwin(id);
 if n < 0 then begin
  n:= length(wins);
  setlength(wins,n+1);
 end;
 wins[n].id:= id;
 wins[n].parent:= parent;
 wins[n].ispopup:= popup;
 wins[n].hidden:= false;
 wins[n].showdue:= 0;
 wins[n].x:= x;
 wins[n].y:= y;
end;

type
 popupexposety = record
  win: cardinal;
  due: qword;
  left: integer;
 end;

var
 popupexposes: array[0..15] of popupexposety;

const
 popupexposedelay = 80; //ms between repeated repaints
 popupexposecount = 1;

procedure schedulepopupexpose(const awin: cardinal);
var
 i,slot: integer;
begin
 slot:= -1;
 for i:= 0 to high(popupexposes) do begin
  if popupexposes[i].win = awin then begin
   slot:= i;
   break;
  end;
  if (slot < 0) and (popupexposes[i].left <= 0) then begin
   slot:= i;
  end;
 end;
 if slot >= 0 then begin
  with popupexposes[slot] do begin
   win:= awin;
   left:= popupexposecount;
   due:= gettickcount64 + popupexposedelay;
  end;
 end;
end;


procedure showpopup(const i: integer); forward;

procedure showduepopups;
var
 i: integer;
 t: qword;
begin
 t:= gettickcount64;
 for i:= 0 to high(wins) do begin
  if wins[i].hidden and (t >= wins[i].showdue) then begin
   showpopup(i);
  end;
 end;
end;

function popupexposedue: boolean;
var
 i: integer;
 t: qword;
begin
 result:= false;
 t:= gettickcount64;
 for i:= 0 to high(wins) do begin
  if wins[i].hidden and (t >= wins[i].showdue) then begin
   result:= true;
   break;
  end;
 end;
 if not result then begin
  for i:= 0 to high(popupexposes) do begin
   if (popupexposes[i].left > 0) and (t >= popupexposes[i].due) then begin
    result:= true;
    break;
   end;
  end;
 end;
end;

function takepopupexpose: cardinal; //0 if none is due
var
 i: integer;
 t: qword;
begin
 showduepopups;
 result:= 0;
 t:= gettickcount64;
 for i:= 0 to high(popupexposes) do begin
  with popupexposes[i] do begin
   if (left > 0) and (t >= due) then begin
    result:= win;
    dec(left);
    due:= t + popupexposedelay;
    break;
   end;
  end;
 end;
end;

procedure windowscreenpos(id: winidty; out ax,ay: integer);
var
 i: integer;
 lx,ly: longint;
begin
 i:= findwin(id);
 if (i >= 0) and (wins[i].ispopup or waylanddriver) then begin
  ax:= wins[i].x;
  ay:= wins[i].y;
 end
 else begin
  lx:= 0;
  ly:= 0;
  x3_getwindowposition(w3(id),lx,ly);
  ax:= lx;
  ay:= ly;
 end;
end;

procedure removewin(id: winidty);
var
 i: integer;
begin
 i:= high(wins);
 while i >= 0 do begin
  if (wins[i].id = id) or (wins[i].parent = id) then begin
   wins[i]:= wins[high(wins)];
   setlength(wins,high(wins));
  end;
  dec(i);
 end;
end;

var
 dbgcount: integer;
 pendingresize: cardinal;    // window id that needs a synthetic resize event
 exposeafterresize: cardinal;// window id: send an expose event after that resize
 pendingexpose: cardinal;    // window id that needs a synthetic expose event


function dbgok: boolean;
begin
 result:= sdldebug and (dbgcount < 60);
 if result then begin
  inc(dbgcount);
 end;
end;

function p2sem(p: pointer): semty;
begin
 fillchar(result,sizeof(result),0);
 move(p,result,sizeof(pointer));      // semty wraps the SDL semaphore pointer
end;

function sem2p(const sem: semty): pointer;
begin
 move(sem,result,sizeof(pointer));
end;

procedure SDL_Quit;
begin
 x3_quit;
end;

function SDL_SetHint(name, value: pchar): boolean;
begin
 if string(name) = 'SDL_VIDEODRIVER' then begin
  result:= x3_sethint('SDL_VIDEO_DRIVER',value);   // renamed in SDL3
 end
 else begin
  result:= x3_sethint(name,value);
 end;
end;


function SDL_Init(flags: Cardinal): Integer;
begin
 result:= ok(x3_init);
 waylanddriver:= string(x3_videodriver) = 'wayland';
end;

function SDL_CreateWindow(title: PChar; x, y, w, h: integer;
                                      flags: SDL_WindowFlags): winidty;
var
 win: pointer;
 r: x3rect;
 f: cardinal;
begin
 // SDL3: no SHOWN and no OPENGL flag, tooltip and popup windows need
 // SDL_CreatePopupWindow
 f:= flags and $FFF3FFF9;
 if (cardinal(x) and $FFFF0000) = SDL_WINDOWPOS_CENTERED_MASK then begin
  if x3_getdisplaybounds(r) then begin
   x:= r.x + (r.w - w) div 2;
   y:= r.y + (r.h - h) div 2;
  end
  else begin
   x:= 0;
   y:= 0;
  end;
 end;
 win:= x3_createwindow(title,w,h,f);
 if sdldebug then begin
  writeln('CREATEWINDOW pos=',x,',',y,' size=',w,'x',h,' flags=',flags,
          ' win=',ptruint(win),' err=',string(SDL_GetError));
  flush(output);
 end;
 if win <> nil then begin
  x3_setwindowposition(win,x,y);
  x3_starttextinput(win);      // SDL3: text input is off by default
 end;
 result:= winidty(ptruint(win));
 addwin(result,0,false,x,y);
end;

procedure showpopup(const i: integer);
var
 px,py: integer;
begin
 if wins[i].hidden then begin
  wins[i].hidden:= false;
  windowscreenpos(wins[i].parent,px,py);
  x3_setwindowposition(w3(wins[i].id),wins[i].x-px,wins[i].y-py);
  x3_showwindow(w3(wins[i].id));
  schedulepopupexpose(x3_getwindowid(w3(wins[i].id)));
  if sdldebug then begin
   writeln('SHOWPOPUP id=',ptruint(wins[i].id),' at ',wins[i].x,',',wins[i].y);
   flush(output);
  end;
 end;
end;

function SDL_CreatePopupWindow(parent: winidty; x, y, w, h: integer;
                                      flags: SDL_WindowFlags): winidty;
var
 win: pointer;
 px,py,n: integer;
begin
 windowscreenpos(parent,px,py);
 // created hidden: an xdg_popup can not be resized once it is mapped,
 // it is shown after MSEgui has set the final size
 win:= x3_createpopup(w3(parent),x-px,y-py,w,h,
               (flags and ($00080000 or $00040000)) or SDL_WINDOW_HIDDEN);
 if sdldebug then begin
  writeln('CREATEPOPUP parent=',ptruint(parent),' parentpos=',px,',',py,
          ' at ',x,',',y,' offset=',x-px,',',y-py,' size=',w,'x',h,
          ' win=',ptruint(win),' err=',string(SDL_GetError));
  flush(output);
 end;
 result:= winidty(ptruint(win));
 addwin(result,parent,true,x,y);
 if result <> 0 then begin
  n:= findwin(result);
  if n >= 0 then begin
   wins[n].hidden:= true;
   wins[n].showdue:= gettickcount64 + 150;
  end;
 end;
end;
procedure SDL_DestroyWindow(window: winidty);
begin
 removewin(window);
 x3_destroywindow(w3(window));
end;

procedure SDL_GetWindowPosition(window: winidty; var x, y: integer);
var
 ax,ay: integer;
begin
 windowscreenpos(window,ax,ay);
 x:= ax;
 y:= ay;
end;

procedure SDL_SetWindowPosition(window: winidty; x, y: integer);
var
 i,px,py: integer;
begin
 if dbgok then begin
  writeln('SETPOS ',x,',',y);
  flush(output);
 end;
 i:= findwin(window);
 if i >= 0 then begin
  wins[i].x:= x;
  wins[i].y:= y;
  if wins[i].ispopup then begin
   windowscreenpos(wins[i].parent,px,py);
   x3_setwindowposition(w3(window),x-px,y-py);
   exit;
  end;
 end;
 x3_setwindowposition(w3(window),x,y);
end;

procedure SDL_SetWindowSize(window: winidty; w, h: integer);
var
 n: integer;
begin
 if dbgok then begin
  writeln('SETSIZE ',w,'x',h,' err=',string(SDL_GetError));
  flush(output);
 end;
 x3_setwindowsize(w3(window),w,h);
 n:= findwin(window);
 if n >= 0 then begin
  if wins[n].hidden then begin
   showpopup(n);       // size and position are final now
  end;
  // SDL3 may send neither a resize nor an expose event to popup windows
  pendingresize:= x3_getwindowid(w3(window));
  exposeafterresize:= pendingresize;
 end;
end;

procedure SDL_ShowWindow(window: winidty);
begin
 if (SDL_GetWindowFlags(window) and $00000008) = 0 then begin
  //not hidden: showing it again would re-map the window and make it flash
  if sdldebug then begin
   writeln('SHOWWINDOW skipped id=',ptruint(window));
   flush(output);
  end;
  exit;
 end;
 if sdldebug then begin
  writeln('SHOWWINDOW id=',ptruint(window));
  flush(output);
 end;
 x3_showwindow(w3(window));
end;

procedure SDL_HideWindow(window: winidty);
begin
 x3_hidewindow(w3(window));
end;

procedure SDL_RaiseWindow(window: winidty);
begin
 x3_raisewindow(w3(window));
end;





procedure SDL_GetWindowSize(window: winidty; var w, h: integer);
var
 aw,ah: longint;
begin
 aw:= 0;
 ah:= 0;
 x3_getwindowsize(w3(window),aw,ah);
 w:= aw;
 h:= ah;
 if dbgok then begin
  writeln('GETWINDOWSIZE ',aw,'x',ah);
  flush(output);
 end;
end;


function SDL_GetWindowFlags(window: winidty): SDL_WindowFlags;
var
 f: qword;
begin
 f:= x3_getwindowflags(w3(window));
 result:= cardinal(f and $FFFFFFFF) and $FFFFFFFB;   // bit 4 is "occluded"
 if (f and SDL_WINDOW_HIDDEN) = 0 then begin
  result:= result or SDL_WINDOW_SHOWN;               // SDL2 style flag
 end;
end;

procedure SDL_MinimizeWindow(window: winidty);
begin
 x3_minimizewindow(w3(window));
end;

procedure SDL_MaximizeWindow(window: winidty);
begin
 x3_maximizewindow(w3(window));
end;

function SDL_SetWindowFullscreen(window: winidty; fullscreen: boolean): integer;
begin
 result:= ok(x3_setwindowfullscreen(w3(window),fullscreen));
end;

procedure SDL_SetWindowTitle(window: winidty; const title: PChar);
begin
 x3_setwindowtitle(w3(window),title);
end;

procedure SDL_SetWindowIcon(window: winidty; icon: PSDL_Surface);
begin
 x3_setwindowicon(w3(window),s3(icon));
end;

function SDL_UpdateWindowSurface(window: winidty): integer;
begin
 result:= ok(x3_updatewindowsurface(w3(window)));
end;

function SDL_DestroyWindowSurface(window: winidty): integer;
begin
 result:= ok(x3_destroywindowsurface(w3(window)));
end;

function SDL_GetWindowFromID(id: cardinal): winidty;
begin
 result:= winidty(ptruint(x3_getwindowfromid(id)));
end;

function SDL_GetWindowSurface(window: winidty): PSDL_Surface;
begin
 result:= PSDL_Surface(ptruint(x3_getwindowsurface(w3(window))));
 if dbgok then begin
  writeln('GETWINDOWSURFACE ',ptruint(result),' err=',string(SDL_GetError));
  flush(output);
 end;
end;

function SDL_GetDisplayBounds(displayIndex: integer; rect: PSDL_Rect): integer;
begin
 result:= ok(x3_getdisplaybounds(px3rect(rect)^));
end;

function SDL_GetError: pchar;
begin
 result:= x3_geterror;
end;

procedure SDL_ClearError;
begin
 x3_clearerror;
end;

function SDL_CheckError(ref: string): guierrorty;
var
 err: pchar;
begin
 result:= gue_ok;
 err:= SDL_GetError;
 if err<>'' then begin
  SDL_ClearError;
 end;
end;

function SDL_CheckErrorGDI(ref: string): gdierrorty;
var
 err: pchar;
begin
 result:= gde_ok;
 err:= SDL_GetError;
 if err<>'' then begin
  SDL_ClearError;
 end;
end;

function SDL_CreateMutex: mutexty;
begin
 result:= mutexty(ptruint(x3_createmutex));
end;

procedure SDL_DestroyMutex(varmutex: mutexty);
begin
 x3_destroymutex(pointer(ptruint(varmutex)));
end;

function SDL_LockMutex(mutex: mutexty): integer;
begin
 x3_lockmutex(pointer(ptruint(mutex)));
 result:= 0;
end;

function SDL_UnlockMutex(mutex: mutexty): integer;
begin
 x3_unlockmutex(pointer(ptruint(mutex)));
 result:= 0;
end;

function SDL_mutexP(mutex: mutexty): integer;
begin
 result:= SDL_LockMutex(mutex);
end;

function SDL_mutexV(mutex: mutexty): integer;
begin
 result:= SDL_UnlockMutex(mutex);
end;

function SDL_CreateSemaphore(initial_value: cardinal): semty;
begin
 result:= p2sem(x3_createsemaphore(initial_value));
end;

function SDL_SemPost(sem: semty): integer;
begin
 x3_signalsemaphore(sem2p(sem));
 result:= 0;
end;

procedure SDL_DestroySemaphore(sem: semty);
begin
 x3_destroysemaphore(sem2p(sem));
end;

function SDL_SemWaitTimeout(sem: semty; ms: cardinal): integer;
begin
 if x3_waitsemaphoretimeout(sem2p(sem),longint(ms)) then begin
  result:= 0;
 end
 else begin
  result:= 1;                    // SDL_MUTEX_TIMEDOUT
 end;
end;

function SDL_SemValue(sem: semty): cardinal;
begin
 result:= x3_getsemaphorevalue(sem2p(sem));
end;

function SDL_SemTryWait(sem: semty): integer;
begin
 if x3_trywaitsemaphore(sem2p(sem)) then begin
  result:= 0;
 end
 else begin
  result:= 1;                    // SDL_MUTEX_TIMEDOUT
 end;
end;

procedure SDL_WaitThread(thread: pointer; status: pinteger);
begin
 x3_waitthread(thread,plongint(status));
end;

function SDL_GetGlobalMouseState(x,y: pinteger): cardinal;
var
 ax,ay: longint;
begin
 result:= x3_getglobalmousestate(ax,ay);
 if x <> nil then begin
  x^:= ax;
 end;
 if y <> nil then begin
  y^:= ay;
 end;
end;

function SDL_GetMouseState(x,y: pinteger): byte;
var
 ax,ay: longint;
begin
 result:= byte(x3_getmousestate(ax,ay));
 if x <> nil then begin
  x^:= ax;
 end;
 if y <> nil then begin
  y^:= ay;
 end;
end;

procedure SDL_WarpMouseInWindow(window: winidty; x, y: integer);
begin
 x3_warpmouse(w3(window),x,y);
end;

function SDL_CreateCursor(const data: pbyte; const Umask: pbyte;
                                  w,h,hot_x,hot_y: integer): SDL_Cursor;
begin
 result:= SDL_Cursor(ptruint(x3_createcursor(data,Umask,w,h,hot_x,hot_y)));
end;

procedure SDL_SetCursor(cursor: SDL_Cursor);
begin
 x3_setcursor(pointer(ptruint(cursor)));
end;

function SDL_CaptureMouse(enabled: integer): integer;
begin
 result:= ok(x3_capturemouse(enabled <> 0));
end;

function SDL_GetCurrentVideoDriver: pchar;
begin
 result:= x3_videodriver;
end;

function SDL_CreateRenderer(window: winidty; index: integer;
                                      flags: Cardinal): SDL_Renderer;
begin
 result:= SDL_Renderer(ptruint(x3_createrenderer(w3(window))));
end;

function SDL_GetRenderer(window: winidty): SDL_Renderer;
begin
 result:= SDL_Renderer(ptruint(x3_getrenderer(w3(window))));
end;

function SDL_GetRendererOutputSize(renderer: SDL_Renderer;
                                                  w, h: pinteger): integer;
var
 aw,ah: longint;
begin
 aw:= 0;
 ah:= 0;
 result:= ok(x3_getrenderoutputsize(r3(renderer),aw,ah));
 if w <> nil then begin
  w^:= aw;
 end;
 if h <> nil then begin
  h^:= ah;
 end;
end;

function SDL_RenderSetClipRect(renderer: SDL_Renderer;
                                                  rect: PSDL_Rect): LongInt;
begin
 result:= ok(x3_setrenderclip(r3(renderer),px3rect(rect)));
end;

function SDL_CreateSoftwareRenderer(surface: PSDL_Surface): SDL_Renderer;
begin
 result:= SDL_Renderer(ptruint(x3_createsoftwarerenderer(s3(surface))));
 if dbgok then begin
  writeln('CREATESOFTRENDERER surface=',ptruint(surface),
          ' result=',ptruint(result),' err=',string(SDL_GetError));
  flush(output);
 end;
end;

procedure SDL_DestroyRenderer(renderer: SDL_Renderer);
begin
 x3_destroyrenderer(r3(renderer));
end;

function SDL_CreateTextureFromSurface(renderer: SDL_Renderer;
                                          surface: PSDL_Surface): SDL_Texture;
begin
 result:= SDL_Texture(ptruint(x3_createtexture(r3(renderer),s3(surface))));
end;

function SDL_SetRenderDrawColor(renderer: SDL_Renderer;
                                            r, g, b, a: byte): integer;
begin
 result:= ok(x3_setrenderdrawcolor(r3(renderer),r,g,b,a));
end;

function SDL_RenderReadPixels(renderer: SDL_Renderer; const rect: PSDL_Rect;
                  format: Uint32; pixels: pointer; pitch: integer): integer;
begin
 // the format is always ARGB8888 ($16362004) in this backend
 result:= ok(x3_renderreadpixels(r3(renderer),px3rect(rect),pixels,pitch));
end;

function SDL_SetRenderDrawBlendMode(renderer: SDL_Renderer;
                                            blendMode: SDL_BlendMode): integer;
begin
 result:= ok(x3_setrenderdrawblend(r3(renderer),cardinal(ord(blendMode))));
end;

function SDL_RenderClear(renderer: SDL_Renderer): Integer;
begin
 result:= ok(x3_renderclear(r3(renderer)));
end;

function SDL_RenderDrawLine(renderer: SDL_Renderer;
                                            x1, y1, x2, y2: integer): integer;
begin
 result:= ok(x3_renderline(r3(renderer),x1,y1,x2,y2));
end;

function SDL_RenderFillRect(renderer: SDL_Renderer;
                                            const rect: PSDL_Rect): integer;
begin
 result:= ok(x3_renderfillrect(r3(renderer),px3rect(rect)));
end;

function SDL_RenderDrawPoint(renderer: SDL_Renderer; x: integer;
                                                         y: integer): integer;
begin
 result:= ok(x3_renderpoint(r3(renderer),x,y));
end;

function SDL_RenderCopy(renderer: SDL_Renderer; texture: SDL_Texture;
                          const srcrect, dstrect: PSDL_Rect): integer;
begin
 result:= ok(x3_rendertexture(r3(renderer),pointer(ptruint(texture)),
                                       px3rect(srcrect),px3rect(dstrect)));
end;

procedure SDL_RenderPresent(renderer: SDL_Renderer);
begin
 x3_renderpresent(r3(renderer));
end;

procedure SDL_DestroyTexture(textureID: SDL_Texture);
begin
 x3_destroytexture(pointer(ptruint(textureID)));
end;

function SDL_SetTextureBlendMode(texture: SDL_Texture;
                                            blendMode: SDL_BlendMode): Integer;
begin
 result:= ok(x3_settextureblend(pointer(ptruint(texture)),
                                                cardinal(ord(blendMode))));
end;

function SDL_CreateRGBSurface(flags: cardinal; width: integer; height: integer;
                depth: integer; Rmask: Uint32; Gmask: Uint32; Bmask: Uint32;
                Amask: Uint32): PSDL_Surface;
begin
 // SDL3 uses pixel formats instead of masks: red in the low byte = ABGR
 result:= PSDL_Surface(ptruint(x3_createsurface(width,height,
                                                      Rmask = $000000FF)));
 if dbgok then begin
  writeln('CREATESURFACE ',width,'x',height,' result=',ptruint(result),
          ' err=',string(SDL_GetError));
  flush(output);
 end;
end;

function SDL_CreateRGBSurfaceFrom(pixels: pointer; width: integer;
                height: integer; depth: integer; pitch: integer;
                Rmask: Uint32; Gmask: Uint32; Bmask: Uint32;
                Amask: Uint32): PSDL_Surface;
begin
 result:= PSDL_Surface(ptruint(x3_createsurfacefrom(pixels,width,height,pitch,
                                                      Rmask = $000000FF)));
end;

procedure SDL_FreeSurface(surface: PSDL_Surface);
begin
 x3_destroysurface(s3(surface));
end;

function SDL_UpperBlit(src: PSDL_Surface; const srcrect: PSDL_Rect;
                              dst: PSDL_Surface; dstrect: PSDL_Rect): integer;
begin
 result:= ok(x3_blit(s3(src),px3rect(srcrect),s3(dst),px3rect(dstrect)));
end;

procedure SDL_UnlockSurface(surface: PSDL_Surface);
begin
 // nothing to do: surfaces of this backend never need locking
end;

function SDL_SetSurfaceBlendMode(surface: PSDL_Surface;
                                            blendMode: SDL_BlendMode): integer;
begin
 result:= ok(x3_setsurfaceblend(s3(surface),cardinal(ord(blendMode))));
end;

procedure SDL_PumpEvents;
begin
 x3_pumpevents;
end;

function SDL_HasEvents(minType, maxType: Cardinal): boolean;
begin
 result:= (pendingexpose <> 0) or (pendingresize <> 0) or x3_hasevents;
end;

function SDL_PollEvent(event: PSDL_Event): integer;
var
 e3: x3event;
 i,aw,ah,wi: integer;
begin
 result:= 0;
  if pendingexpose = 0 then begin
  pendingexpose:= takepopupexpose;
 end;
 if pendingexpose <> 0 then begin       // repaint after a resize
  fillchar(event^,sizeof(event^),0);
  event^.type_:= SDL_WINDOWEVENT;
  event^.window.window:= pendingexpose;
  event^.window.event:= SDL_WINDOWEVENT_EXPOSED;
  if sdldebug then begin
   writeln('SYNTHETIC EXPOSE win=',pendingexpose);
   flush(output);
  end;
  pendingexpose:= 0;
  result:= 1;
  exit;
 end;
 if pendingresize <> 0 then begin       // SDL3 sends no size event at show
  aw:= 0;
  ah:= 0;
  SDL_GetWindowSize(SDL_GetWindowFromID(pendingresize),aw,ah);
  fillchar(event^,sizeof(event^),0);
  event^.type_:= SDL_WINDOWEVENT;
  event^.window.window:= pendingresize;
  event^.window.event:= SDL_WINDOWEVENT_RESIZED;
  event^.window.Data1:= aw;
  event^.window.Data2:= ah;
  if sdldebug then begin
   writeln('SYNTHETIC RESIZE win=',pendingresize,' ',aw,'x',ah);
   flush(output);
  end;
  if exposeafterresize = pendingresize then begin
   pendingexpose:= pendingresize;
   exposeafterresize:= 0;
  end;
  pendingresize:= 0;
  result:= 1;
  exit;
 end;
 if x3_pollevent(e3) then begin
  fillchar(event^,sizeof(event^),0);
  case e3.kind of
   x3k_quit: begin
    event^.type_:= SDL_QUITEV;
   end;
   x3k_window: begin
    event^.type_:= SDL_WINDOWEVENT;
    event^.window.timestamp:= e3.timestampms;
    event^.window.window:= e3.window;
    event^.window.event:= byte(e3.sub);
    event^.window.Data1:= e3.d1;
    event^.window.Data2:= e3.d2;
    if e3.sub = SDL_WINDOWEVENT_SHOWN then begin
     pendingresize:= e3.window;
    end
    else if (e3.sub = SDL_WINDOWEVENT_RESIZED) or
                                (e3.sub = SDL_WINDOWEVENT_MOVED) then begin
     // a popup is configured by the compositor after its creation: the
     // first picture is lost, so paint again after the real size and move
     wi:= findwin(SDL_GetWindowFromID(e3.window));
     if (wi >= 0) and wins[wi].ispopup then begin
      pendingexpose:= e3.window;
     end;
    end;
   end;
   x3k_keydown,x3k_keyup: begin
    if e3.kind = x3k_keydown then begin
     event^.type_:= SDL_KEYDOWN;
    end
    else begin
     event^.type_:= SDL_KEYUP;
    end;
    event^.key.timestamp:= e3.timestampms;
    event^.key.window:= e3.window;
    event^.key.state:= ord(e3.down);
    event^.key.repeat_:= ord(e3.repeated);
    event^.key.keysym.scancode:= e3.scancode;
    event^.key.keysym.sym:= e3.key;
    event^.key.keysym.mods:= e3.mods;
   end;
   x3k_text: begin
    event^.type_:= SDL_TEXTINPUT;
    event^.text.timestamp:= e3.timestampms;
    event^.text.window:= e3.window;
    for i:= 0 to high(event^.text.text) do begin
     event^.text.text[i]:= e3.text[i];
    end;
   end;
   x3k_motion: begin
    event^.type_:= SDL_MOUSEMOTION;
    event^.motion.timestamp:= e3.timestampms;
    event^.motion.window:= e3.window;
    event^.motion.state:= e3.mstate;
    event^.motion.x:= e3.x;
    event^.motion.y:= e3.y;
    event^.motion.xrel:= e3.xrel;
    event^.motion.yrel:= e3.yrel;
   end;
   x3k_btndown,x3k_btnup: begin
    if e3.kind = x3k_btndown then begin
     event^.type_:= SDL_MOUSEBUTTONDOWN;
    end
    else begin
     event^.type_:= SDL_MOUSEBUTTONUP;
    end;
    event^.button.timestamp:= e3.timestampms;
    event^.button.window:= e3.window;
    event^.button.button:= byte(e3.btn);
    event^.button.state:= ord(e3.down);
    event^.button.clicks:= byte(e3.clicks);
    event^.button.x:= e3.x;
    event^.button.y:= e3.y;
   end;
   x3k_wheel: begin
    event^.type_:= SDL_MOUSEWHEEL;
    event^.wheel.timestamp:= e3.timestampms;
    event^.wheel.window:= e3.window;
    event^.wheel.x:= e3.wx;
    event^.wheel.y:= e3.wy;
    event^.wheel.direction:= cardinal(e3.wdir);
   end;
   x3k_user: begin
    event^.type_:= SDL_USEREVENT;
    event^.user.windowID:= e3.window;
    event^.user.code:= e3.code;
    event^.user.data1:= e3.data1;
    event^.user.data2:= e3.data2;
   end;
  end;
  if sdldebug and (e3.kind <> x3k_motion) and (e3.kind <> x3k_user) then begin
   writeln('EVENT kind=',e3.kind,' sub=',e3.sub,' win=',e3.window,
           ' d1=',e3.d1,' d2=',e3.d2);
   flush(output);
  end;
  result:= 1;
 end;
end;

function SDL_PushEvent(const event: PSDL_Event): integer;
begin
 if event^.type_ = SDL_USEREVENT then begin
  result:= ok(x3_pushuser(event^.user.windowID,event^.user.code,
                                      event^.user.data1,event^.user.data2));
 end
 else begin
  result:= -1;
 end;
end;

function SDL_RegisterEvents(numevents: integer): cardinal;
begin
 result:= x3_registerevents(numevents);
end;

function SDL_AddTimer(interval: UInt32; callback: pointer;
                                                param: Pointer): integer;
begin
 result:= integer(x3_addtimer(interval,x3timercb(callback),param));
end;

procedure SDL_RemoveTimer(id: integer);
begin
 x3_removetimer(cardinal(id));
end;

function SDL_GetTicks: UInt32;
begin
 result:= cardinal(x3_getticks and $FFFFFFFF);
end;

function SDL_SetClipboardText(const text: pchar): integer;
begin
 result:= ok(x3_setclipboardtext(text));
end;

function SDL_HasClipboardText: boolean;
begin
 result:= x3_hasclipboardtext;
end;

function SDL_GetClipboardText: pchar;
begin
 result:= x3_getclipboardtext;
end;

function SDL_KeyCodeToKey(acode: SDL_KeyCode): keyty;
begin
 result:= key_unknown;
 case acode of
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
  SDLK_CURRENCYSUBUNIT : result:= key_cent;
  SDLK_CURRENCYUNIT : result:= key_currency;
  SDLK_KP_PLUSMINUS : result:= key_plusminus;
  SDLK_ESCAPE : result:= key_Escape;
  SDLK_TAB, SDLK_KP_TAB : result:= key_Tab;
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
  SDLK_MENU : result:= key_Menu;
  SDLK_HELP : result:= key_Help;
  SDLK_UNKNOWN : result:= key_unknown;
 end;
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
