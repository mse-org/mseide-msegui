unit sdl3api;
{ thin layer over the SDL3 Pascal headers (SDL3.pas).
  Only simple types are exported and all names start with x3, so this unit
  can be used next to the SDL2 style names of sdl3msegui without a clash. }
{$mode objfpc}{$h+}

interface
uses
 ctypes;

type
 x3rect = record
  x,y,w,h: longint;
 end;
 px3rect = ^x3rect;

 x3event = record
  kind: longint;           // x3k_ constants
  window: cardinal;        // SDL window id
  timestampms: cardinal;
  sub: longint;            // window event code, SDL2 numbering
  d1,d2: longint;
  key: cardinal;
  scancode: longint;
  mods: cardinal;
  down: boolean;
  repeated: boolean;
  btn: longint;
  clicks: longint;
  x,y,xrel,yrel: longint;
  mstate: cardinal;
  wx,wy: longint;          // wheel ticks
  wdir: longint;
  text: array[0..31] of ansichar;
  code: longint;
  data1,data2: pointer;
 end;

 x3timercb = function(interval: cardinal; param: pointer): cardinal; cdecl;

const
 x3k_none = 0;
 x3k_quit = 1;
 x3k_window = 2;
 x3k_keydown = 3;
 x3k_keyup = 4;
 x3k_text = 5;
 x3k_motion = 6;
 x3k_btndown = 7;
 x3k_btnup = 8;
 x3k_wheel = 9;
 x3k_user = 10;

function x3_init: boolean;
procedure x3_quit;
function x3_sethint(name,value: pchar): boolean;
function x3_geterror: pchar;
procedure x3_clearerror;
function x3_videodriver: pchar;

function x3_createwindow(title: pchar; w,h: longint; flags: qword): pointer;
function x3_createpopup(parent: pointer; ox,oy,w,h: longint;
                                                flags: qword): pointer;
procedure x3_destroywindow(win: pointer);
procedure x3_showwindow(win: pointer);
procedure x3_hidewindow(win: pointer);
procedure x3_raisewindow(win: pointer);
procedure x3_minimizewindow(win: pointer);
procedure x3_maximizewindow(win: pointer);
procedure x3_getwindowposition(win: pointer; var x,y: longint);
procedure x3_setwindowposition(win: pointer; x,y: longint);
procedure x3_getwindowsize(win: pointer; var w,h: longint);
procedure x3_setwindowsize(win: pointer; w,h: longint);
function x3_getwindowflags(win: pointer): qword;
function x3_setwindowfullscreen(win: pointer; fullscreen: boolean): boolean;
procedure x3_setwindowtitle(win: pointer; title: pchar);
procedure x3_setwindowicon(win: pointer; icon: pointer);
function x3_getwindowsurface(win: pointer): pointer;
function x3_updatewindowsurface(win: pointer): boolean;

function x3_getwindowid(win: pointer): cardinal;
function x3_destroywindowsurface(win: pointer): boolean;

function x3_getwindowfromid(id: cardinal): pointer;
function x3_getdisplaybounds(var r: x3rect): boolean;
function x3_setwindowparent(win,parent: pointer): boolean;
function x3_setwindowmodal(win: pointer; modal: boolean): boolean;
procedure x3_starttextinput(win: pointer);

function x3_getmousestate(var x,y: longint): cardinal;
function x3_getglobalmousestate(var x,y: longint): cardinal;
procedure x3_warpmouse(win: pointer; x,y: longint);
function x3_capturemouse(enabled: boolean): boolean;
function x3_createcursor(data,mask: pointer; w,h,hx,hy: longint): pointer;
procedure x3_setcursor(cursor: pointer);

function x3_createsurface(w,h: longint; bgr: boolean): pointer;
function x3_createsurfacefrom(pixels: pointer; w,h,pitch: longint;
                                                    bgr: boolean): pointer;
procedure x3_destroysurface(surface: pointer);
function x3_setsurfaceblend(surface: pointer; mode: cardinal): boolean;
function x3_blit(src: pointer; srcrect: px3rect; dst: pointer;
                                                  dstrect: px3rect): boolean;

function x3_createsoftwarerenderer(surface: pointer): pointer;
function x3_createrenderer(win: pointer): pointer;
function x3_getrenderer(win: pointer): pointer;
procedure x3_destroyrenderer(r: pointer);
function x3_getrenderoutputsize(r: pointer; var w,h: longint): boolean;
function x3_setrenderclip(r: pointer; rc: px3rect): boolean;
function x3_setrenderdrawcolor(r: pointer; red,green,blue,alpha: byte): boolean;
function x3_setrenderdrawblend(r: pointer; mode: cardinal): boolean;
function x3_renderclear(r: pointer): boolean;
function x3_renderline(r: pointer; x1,y1,x2,y2: longint): boolean;
function x3_renderpoint(r: pointer; x,y: longint): boolean;
function x3_renderfillrect(r: pointer; rc: px3rect): boolean;
function x3_rendertexture(r,tex: pointer; src,dst: px3rect): boolean;
function x3_renderreadpixels(r: pointer; rc: px3rect; dest: pointer;
                                              destpitch: longint): boolean;
procedure x3_renderpresent(r: pointer);
function x3_createtexture(r,surface: pointer): pointer;
procedure x3_destroytexture(tex: pointer);
function x3_settextureblend(tex: pointer; mode: cardinal): boolean;

function x3_pollevent(var ev: x3event): boolean;
function x3_pushuser(win: cardinal; acode: longint; d1,d2: pointer): boolean;
function x3_hasevents: boolean;
procedure x3_pumpevents;
function x3_registerevents(count: longint): cardinal;

function x3_addtimer(interval: cardinal; cb: x3timercb;
                                             param: pointer): cardinal;
procedure x3_removetimer(id: cardinal);
function x3_getticks: qword;

function x3_setclipboardtext(text: pchar): boolean;
function x3_hasclipboardtext: boolean;
function x3_getclipboardtext: pchar;

function x3_createmutex: pointer;
procedure x3_lockmutex(m: pointer);
procedure x3_unlockmutex(m: pointer);
procedure x3_destroymutex(m: pointer);
function x3_createsemaphore(initial: cardinal): pointer;
procedure x3_destroysemaphore(sem: pointer);
procedure x3_signalsemaphore(sem: pointer);
function x3_trywaitsemaphore(sem: pointer): boolean;
function x3_waitsemaphoretimeout(sem: pointer; ms: longint): boolean;
function x3_getsemaphorevalue(sem: pointer): cardinal;
procedure x3_waitthread(thread: pointer; status: plongint);

implementation
uses
 SDL3;

type
 ptimerrec = ^timerrec;
 timerrec = record
  id: cardinal;
  active: boolean;
  cb: x3timercb;
  param: pointer;
 end;

var
 timers: array of ptimerrec;

procedure flushr(r: pointer);
begin
 SDL_FlushRenderer(PSDL_Renderer(r));   // SDL3 queues render commands
end;

function x3_init: boolean;
begin
 result:= SDL_Init(SDL_INIT_VIDEO);
end;

procedure x3_quit;
begin
 SDL_Quit;
end;

function x3_sethint(name,value: pchar): boolean;
begin
 result:= SDL_SetHint(name,value);
end;

function x3_geterror: pchar;
begin
 result:= SDL_GetError;
end;

procedure x3_clearerror;
begin
 SDL_ClearError;
end;

function x3_videodriver: pchar;
begin
 result:= SDL_GetCurrentVideoDriver;
end;

function x3_createwindow(title: pchar; w,h: longint; flags: qword): pointer;
begin
 result:= SDL_CreateWindow(title,w,h,TSDL_WindowFlags(flags));
end;

function x3_createpopup(parent: pointer; ox,oy,w,h: longint;
                                                flags: qword): pointer;
begin
 result:= SDL_CreatePopupWindow(PSDL_Window(parent),ox,oy,w,h,
                                                  TSDL_WindowFlags(flags));
end;

procedure x3_destroywindow(win: pointer);
begin
 SDL_DestroyWindow(PSDL_Window(win));
end;

procedure x3_showwindow(win: pointer);
begin
 SDL_ShowWindow(PSDL_Window(win));
end;

procedure x3_hidewindow(win: pointer);
begin
 SDL_HideWindow(PSDL_Window(win));
end;

procedure x3_raisewindow(win: pointer);
begin
 SDL_RaiseWindow(PSDL_Window(win));
end;

procedure x3_minimizewindow(win: pointer);
begin
 SDL_MinimizeWindow(PSDL_Window(win));
end;

procedure x3_maximizewindow(win: pointer);
begin
 SDL_MaximizeWindow(PSDL_Window(win));
end;

procedure x3_getwindowposition(win: pointer; var x,y: longint);
begin
 SDL_GetWindowPosition(PSDL_Window(win),@x,@y);
end;

procedure x3_setwindowposition(win: pointer; x,y: longint);
begin
 SDL_SetWindowPosition(PSDL_Window(win),x,y);
end;

procedure x3_getwindowsize(win: pointer; var w,h: longint);
begin
 SDL_GetWindowSize(PSDL_Window(win),@w,@h);
end;

procedure x3_setwindowsize(win: pointer; w,h: longint);
begin
 SDL_SetWindowSize(PSDL_Window(win),w,h);
end;

function x3_getwindowflags(win: pointer): qword;
begin
 result:= qword(SDL_GetWindowFlags(PSDL_Window(win)));
end;

function x3_setwindowfullscreen(win: pointer; fullscreen: boolean): boolean;
begin
 result:= SDL_SetWindowFullscreen(PSDL_Window(win),fullscreen);
end;

procedure x3_setwindowtitle(win: pointer; title: pchar);
begin
 SDL_SetWindowTitle(PSDL_Window(win),title);
end;

procedure x3_setwindowicon(win: pointer; icon: pointer);
begin
 SDL_SetWindowIcon(PSDL_Window(win),PSDL_Surface(icon));
end;

function x3_getwindowsurface(win: pointer): pointer;
begin
 result:= SDL_GetWindowSurface(PSDL_Window(win));
end;

function x3_updatewindowsurface(win: pointer): boolean;
begin
 result:= SDL_UpdateWindowSurface(PSDL_Window(win));
end;

function x3_getwindowid(win: pointer): cardinal;
begin
 result:= SDL_GetWindowID(PSDL_Window(win));
end;

function x3_destroywindowsurface(win: pointer): boolean;
begin
 result:= SDL_DestroyWindowSurface(PSDL_Window(win));
end;

function x3_getwindowfromid(id: cardinal): pointer;
begin
 result:= SDL_GetWindowFromID(id);
end;

function x3_getdisplaybounds(var r: x3rect): boolean;
begin
 result:= SDL_GetDisplayBounds(SDL_GetPrimaryDisplay,PSDL_Rect(@r));
end;

function x3_setwindowparent(win,parent: pointer): boolean;
begin
 result:= SDL_SetWindowParent(PSDL_Window(win),PSDL_Window(parent));
end;

function x3_setwindowmodal(win: pointer; modal: boolean): boolean;
begin
 result:= SDL_SetWindowModal(PSDL_Window(win),modal);
end;

procedure x3_starttextinput(win: pointer);
begin
 SDL_StartTextInput(PSDL_Window(win));
end;

function x3_getmousestate(var x,y: longint): cardinal;
var
 fx,fy: cfloat;
begin
 fx:= 0;
 fy:= 0;
 result:= SDL_GetMouseState(@fx,@fy);
 x:= trunc(fx);
 y:= trunc(fy);
end;

function x3_getglobalmousestate(var x,y: longint): cardinal;
var
 fx,fy: cfloat;
begin
 fx:= 0;
 fy:= 0;
 result:= SDL_GetGlobalMouseState(@fx,@fy);
 x:= trunc(fx);
 y:= trunc(fy);
end;

procedure x3_warpmouse(win: pointer; x,y: longint);
begin
 SDL_WarpMouseInWindow(PSDL_Window(win),x,y);
end;

function x3_capturemouse(enabled: boolean): boolean;
begin
 result:= SDL_CaptureMouse(enabled);
end;

function x3_createcursor(data,mask: pointer; w,h,hx,hy: longint): pointer;
begin
 result:= SDL_CreateCursor(pcuint8(data),pcuint8(mask),w,h,hx,hy);
end;

procedure x3_setcursor(cursor: pointer);
begin
 SDL_SetCursor(PSDL_Cursor(cursor));
end;

function x3_createsurface(w,h: longint; bgr: boolean): pointer;
begin
 if bgr then begin
  result:= SDL_CreateSurface(w,h,SDL_PIXELFORMAT_ABGR8888);
 end
 else begin
  result:= SDL_CreateSurface(w,h,SDL_PIXELFORMAT_ARGB8888);
 end;
end;

function x3_createsurfacefrom(pixels: pointer; w,h,pitch: longint;
                                                    bgr: boolean): pointer;
begin
 if bgr then begin
  result:= SDL_CreateSurfaceFrom(w,h,SDL_PIXELFORMAT_ABGR8888,pixels,pitch);
 end
 else begin
  result:= SDL_CreateSurfaceFrom(w,h,SDL_PIXELFORMAT_ARGB8888,pixels,pitch);
 end;
end;

procedure x3_destroysurface(surface: pointer);
begin
 SDL_DestroySurface(PSDL_Surface(surface));
end;

function x3_setsurfaceblend(surface: pointer; mode: cardinal): boolean;
begin
 result:= SDL_SetSurfaceBlendMode(PSDL_Surface(surface),TSDL_BlendMode(mode));
end;

function x3_blit(src: pointer; srcrect: px3rect; dst: pointer;
                                                  dstrect: px3rect): boolean;
begin
 result:= SDL_BlitSurface(PSDL_Surface(src),PSDL_Rect(srcrect),
                                     PSDL_Surface(dst),PSDL_Rect(dstrect));
end;

function x3_createsoftwarerenderer(surface: pointer): pointer;
begin
 result:= SDL_CreateSoftwareRenderer(PSDL_Surface(surface));
end;

function x3_createrenderer(win: pointer): pointer;
begin
 result:= SDL_CreateRenderer(PSDL_Window(win),nil);
end;

function x3_getrenderer(win: pointer): pointer;
begin
 result:= SDL_GetRenderer(PSDL_Window(win));
end;

procedure x3_destroyrenderer(r: pointer);
begin
 SDL_DestroyRenderer(PSDL_Renderer(r));
end;

function x3_getrenderoutputsize(r: pointer; var w,h: longint): boolean;
begin
 result:= SDL_GetRenderOutputSize(PSDL_Renderer(r),@w,@h);
end;

function x3_setrenderclip(r: pointer; rc: px3rect): boolean;
begin
 result:= SDL_SetRenderClipRect(PSDL_Renderer(r),PSDL_Rect(rc));
end;

function x3_setrenderdrawcolor(r: pointer; red,green,blue,alpha: byte): boolean;
begin
 result:= SDL_SetRenderDrawColor(PSDL_Renderer(r),red,green,blue,alpha);
end;

function x3_setrenderdrawblend(r: pointer; mode: cardinal): boolean;
begin
 result:= SDL_SetRenderDrawBlendMode(PSDL_Renderer(r),TSDL_BlendMode(mode));
end;

function x3_renderclear(r: pointer): boolean;
begin
 result:= SDL_RenderClear(PSDL_Renderer(r));
 flushr(r);
end;

function x3_renderline(r: pointer; x1,y1,x2,y2: longint): boolean;
begin
 result:= SDL_RenderLine(PSDL_Renderer(r),x1,y1,x2,y2);
 flushr(r);
end;

function x3_renderpoint(r: pointer; x,y: longint): boolean;
begin
 result:= SDL_RenderPoint(PSDL_Renderer(r),x,y);
 flushr(r);
end;

function x3_renderfillrect(r: pointer; rc: px3rect): boolean;
var
 fr: TSDL_FRect;
begin
 if rc = nil then begin
  result:= SDL_RenderFillRect(PSDL_Renderer(r),nil);
 end
 else begin
  fr.x:= rc^.x;
  fr.y:= rc^.y;
  fr.w:= rc^.w;
  fr.h:= rc^.h;
  result:= SDL_RenderFillRect(PSDL_Renderer(r),@fr);
 end;
 flushr(r);
end;

function x3_rendertexture(r,tex: pointer; src,dst: px3rect): boolean;
var
 fs,fd: TSDL_FRect;
 ps,pd: PSDL_FRect;
begin
 ps:= nil;
 pd:= nil;
 if src <> nil then begin
  fs.x:= src^.x;
  fs.y:= src^.y;
  fs.w:= src^.w;
  fs.h:= src^.h;
  ps:= @fs;
 end;
 if dst <> nil then begin
  fd.x:= dst^.x;
  fd.y:= dst^.y;
  fd.w:= dst^.w;
  fd.h:= dst^.h;
  pd:= @fd;
 end;
 result:= SDL_RenderTexture(PSDL_Renderer(r),PSDL_Texture(tex),ps,pd);
 flushr(r);
end;

function x3_renderreadpixels(r: pointer; rc: px3rect; dest: pointer;
                                              destpitch: longint): boolean;
var
 surf: PSDL_Surface;
 y,rowbytes: longint;
 sp,dp: pbyte;
 xrgb: boolean;
 px: pcardinal;
 x: longint;
begin
 result:= false;
 surf:= SDL_RenderReadPixels(PSDL_Renderer(r),PSDL_Rect(rc));
 if surf = nil then begin
  exit;
 end;
 xrgb:= surf^.format = SDL_PIXELFORMAT_XRGB8888;
 if (surf^.format = SDL_PIXELFORMAT_ARGB8888) or xrgb then begin
  rowbytes:= surf^.w * 4;
  for y:= 0 to surf^.h-1 do begin
   sp:= pbyte(surf^.pixels) + y*surf^.pitch;
   dp:= pbyte(dest) + y*destpitch;
   move(sp^,dp^,rowbytes);
   if xrgb then begin
    px:= pcardinal(dp);
    for x:= 0 to surf^.w-1 do begin
     px^:= px^ or $FF000000;
     inc(px);
    end;
   end;
  end;
  result:= true;
 end;
 SDL_DestroySurface(surf);
end;

procedure x3_renderpresent(r: pointer);
begin
 SDL_RenderPresent(PSDL_Renderer(r));    // also flushes the queued commands
end;

function x3_createtexture(r,surface: pointer): pointer;
begin
 result:= SDL_CreateTextureFromSurface(PSDL_Renderer(r),PSDL_Surface(surface));
end;

procedure x3_destroytexture(tex: pointer);
begin
 SDL_DestroyTexture(PSDL_Texture(tex));
end;

function x3_settextureblend(tex: pointer; mode: cardinal): boolean;
begin
 result:= SDL_SetTextureBlendMode(PSDL_Texture(tex),TSDL_BlendMode(mode));
end;

function windowsub(t: cardinal): longint;
begin
 case t of
  514: result:= 1;    // shown
  515: result:= 2;    // hidden
  516: result:= 3;    // exposed
  517: result:= 4;    // moved
  518: result:= 5;    // resized
  521: result:= 7;    // minimized
  522: result:= 8;    // maximized
  523: result:= 9;    // restored
  524: result:= 10;   // mouse enter
  525: result:= 11;   // mouse leave
  526: result:= 12;   // focus gained
  527: result:= 13;   // focus lost
  528: result:= 14;   // close requested
  else result:= 0;
 end;
end;


var
 pendev: x3event;
 haspend: boolean;

function rawpoll(var ev: x3event): boolean;
var
 e: TSDL_Event;
 t: cardinal;
 pw: PSDL_WindowEvent;
 pk: PSDL_KeyboardEvent;
 pt: PSDL_TextInputEvent;
 pm: PSDL_MouseMotionEvent;
 pb: PSDL_MouseButtonEvent;
 pwh: PSDL_MouseWheelEvent;
 pu: PSDL_UserEvent;
 i,sub: longint;
begin
 result:= false;
 while SDL_PollEvent(@e) do begin
  fillchar(ev,sizeof(ev),0);
  t:= PCardinal(@e)^;
  case t of
   $100: begin                              // quit
    ev.kind:= x3k_quit;
    result:= true;
   end;
   514..528: begin                          // window events
    sub:= windowsub(t);
    if sub <> 0 then begin
     pw:= PSDL_WindowEvent(@e);
     ev.kind:= x3k_window;
     ev.sub:= sub;
     ev.window:= pw^.windowID;
     ev.timestampms:= cardinal(pw^.timestamp div 1000000);
     ev.d1:= pw^.data1;
     ev.d2:= pw^.data2;
     result:= true;
    end;
   end;
   $300,$301: begin                         // key down, key up
    pk:= PSDL_KeyboardEvent(@e);
    if t = $300 then begin
     ev.kind:= x3k_keydown;
    end
    else begin
     ev.kind:= x3k_keyup;
    end;
    ev.window:= pk^.windowID;
    ev.timestampms:= cardinal(pk^.timestamp div 1000000);
    ev.key:= pk^.key;
    ev.scancode:= longint(pk^.scancode);
    ev.mods:= pk^.mod_;
    ev.down:= pk^.down;
    ev.repeated:= pk^.repeat_;
    result:= true;
   end;
   $303: begin                              // text input
    pt:= PSDL_TextInputEvent(@e);
    ev.kind:= x3k_text;
    ev.window:= pt^.windowID;
    ev.timestampms:= cardinal(pt^.timestamp div 1000000);
    i:= 0;
    if pt^.text <> nil then begin
     while (pt^.text[i] <> #0) and (i < 31) do begin
      ev.text[i]:= pt^.text[i];
      inc(i);
     end;
    end;
    result:= true;
   end;
   $400: begin                              // mouse motion
    pm:= PSDL_MouseMotionEvent(@e);
    ev.kind:= x3k_motion;
    ev.window:= pm^.windowID;
    ev.timestampms:= cardinal(pm^.timestamp div 1000000);
    ev.mstate:= cardinal(pm^.state);
    ev.x:= trunc(pm^.x);
    ev.y:= trunc(pm^.y);
    ev.xrel:= trunc(pm^.xrel);
    ev.yrel:= trunc(pm^.yrel);
    result:= true;
   end;
   $401,$402: begin                         // mouse button down, up
    pb:= PSDL_MouseButtonEvent(@e);
    if t = $401 then begin
     ev.kind:= x3k_btndown;
    end
    else begin
     ev.kind:= x3k_btnup;
    end;
    ev.window:= pb^.windowID;
    ev.timestampms:= cardinal(pb^.timestamp div 1000000);
    ev.btn:= pb^.button;
    ev.clicks:= pb^.clicks;
    ev.down:= pb^.down;
    ev.x:= trunc(pb^.x);
    ev.y:= trunc(pb^.y);
    result:= true;
   end;
   $403: begin                              // mouse wheel
    pwh:= PSDL_MouseWheelEvent(@e);
    ev.kind:= x3k_wheel;
    ev.window:= pwh^.windowID;
    ev.timestampms:= cardinal(pwh^.timestamp div 1000000);
    ev.wx:= pwh^.integer_x;
    ev.wy:= pwh^.integer_y;
    ev.wdir:= longint(pwh^.direction);
    result:= true;
   end;
   $8000: begin                             // user event
    pu:= PSDL_UserEvent(@e);
    ev.kind:= x3k_user;
    ev.window:= pu^.windowID;
    ev.code:= pu^.code;
    ev.data1:= pu^.data1;
    ev.data2:= pu^.data2;
    result:= true;
   end;
  end;
  if result then begin
   exit;                                    // other events are skipped
  end;
 end;
end;

function x3_pollevent(var ev: x3event): boolean;
begin
 if haspend then begin
  ev:= pendev;
  haspend:= false;
  result:= true;
 end
 else begin
  result:= rawpoll(ev);
 end;
end;

function x3_hasevents: boolean;
begin
 // true only if an event can really be delivered by x3_pollevent
 if not haspend then begin
  haspend:= rawpoll(pendev);
 end;
 result:= haspend;
end;

function x3_pushuser(win: cardinal; acode: longint; d1,d2: pointer): boolean;
var
 e: TSDL_Event;
begin
 fillchar(e,sizeof(e),0);
 with PSDL_UserEvent(@e)^ do begin
  type_:= TSDL_EventType($8000);
  windowID:= win;
  code:= acode;
  data1:= d1;
  data2:= d2;
 end;
 result:= SDL_PushEvent(@e);
end;

procedure x3_pumpevents;
begin
 SDL_PumpEvents;
end;

function x3_registerevents(count: longint): cardinal;
begin
 result:= SDL_RegisterEvents(count);
end;

function timertramp(userdata: pointer; timerID: TSDL_TimerID;
                                      interval: cuint32): cuint32; cdecl;
var
 p: ptimerrec;
begin
 p:= ptimerrec(userdata);
 if p^.active then begin
  result:= p^.cb(interval,p^.param);
  if result = 0 then begin
   p^.active:= false;                       // one shot timer is finished
  end;
 end
 else begin
  result:= 0;
 end;
end;

function x3_addtimer(interval: cardinal; cb: x3timercb;
                                             param: pointer): cardinal;
var
 i: integer;
 p: ptimerrec;
begin
 p:= nil;
 for i:= 0 to high(timers) do begin
  if not timers[i]^.active then begin
   p:= timers[i];
   break;
  end;
 end;
 if p = nil then begin
  new(p);
  setlength(timers,length(timers)+1);
  timers[high(timers)]:= p;
 end;
 p^.cb:= cb;
 p^.param:= param;
 p^.id:= 0;
 p^.active:= true;
 result:= SDL_AddTimer(interval,@timertramp,p);
 p^.id:= result;
 if result = 0 then begin
  p^.active:= false;
 end;
end;

procedure x3_removetimer(id: cardinal);
var
 i: integer;
begin
 for i:= 0 to high(timers) do begin
  if timers[i]^.active and (timers[i]^.id = id) then begin
   timers[i]^.active:= false;
  end;
 end;
 SDL_RemoveTimer(id);
end;

function x3_getticks: qword;
begin
 result:= SDL_GetTicks;
end;

function x3_setclipboardtext(text: pchar): boolean;
begin
 result:= SDL_SetClipboardText(text);
end;

function x3_hasclipboardtext: boolean;
begin
 result:= SDL_HasClipboardText;
end;

function x3_getclipboardtext: pchar;
begin
 result:= SDL_GetClipboardText;
end;

function x3_createmutex: pointer;
begin
 result:= SDL_CreateMutex();
end;

procedure x3_lockmutex(m: pointer);
begin
 SDL_LockMutex(PSDL_Mutex(m));
end;

procedure x3_unlockmutex(m: pointer);
begin
 SDL_UnlockMutex(PSDL_Mutex(m));
end;

procedure x3_destroymutex(m: pointer);
begin
 SDL_DestroyMutex(PSDL_Mutex(m));
end;

function x3_createsemaphore(initial: cardinal): pointer;
begin
 result:= SDL_CreateSemaphore(initial);
end;

procedure x3_destroysemaphore(sem: pointer);
begin
 SDL_DestroySemaphore(PSDL_Semaphore(sem));
end;

procedure x3_signalsemaphore(sem: pointer);
begin
 SDL_SignalSemaphore(PSDL_Semaphore(sem));
end;

function x3_trywaitsemaphore(sem: pointer): boolean;
begin
 result:= SDL_TryWaitSemaphore(PSDL_Semaphore(sem));
end;

function x3_waitsemaphoretimeout(sem: pointer; ms: longint): boolean;
begin
 result:= SDL_WaitSemaphoreTimeout(PSDL_Semaphore(sem),ms);
end;

function x3_getsemaphorevalue(sem: pointer): cardinal;
begin
 result:= SDL_GetSemaphoreValue(PSDL_Semaphore(sem));
end;

procedure x3_waitthread(thread: pointer; status: plongint);
begin
 SDL_WaitThread(PSDL_Thread(thread),pcint(status));
end;

finalization
 while length(timers) > 0 do begin
  dispose(timers[high(timers)]);
  setlength(timers,high(timers));
 end;
end.