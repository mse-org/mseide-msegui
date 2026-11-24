{ MSEgui Copyright (c) 1999-2015 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}


{ Pure Wayland backend (no libx11, no SDL).
  Build with -dusewayland, unit path kernel/wayland, include path kernel/sdl
  (for msesdl.inc).

  Windows: winidty = ptruint(twlwindow) (see waylandclient.pas). Window
  positions are virtual: toplevels remember the position MSEgui gave them,
  popups are placed relative to their parent.
  Pixmaps: pixmapty = ptruint(psoftsurfacety) (see msesoftsurface.pas). }
{$warn 5033 on}

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
{$include ../sdl/msesdl.inc}
interface

uses
 math,mseapplication,msetypes,msegraphutils,msesys,
 mseevent,msepointer,mseguiglob,msegraphics,msebitmap,
 msethread,mseformatstr,msestrings,msesystypes,
 msesoftsurface,waylandclient,msewaylandgdi,msegenericgdi;

type
 syseventty = record
  dummy: pointer;
 end;

const
 wheelstep = 120;
 pixel0 = $000000;   //select colorbackground
 pixel1 = $ffffff;   //select colorforeground

{$ifdef FPC}
{$include ../mseguiintf.inc}
{$else}
{$include mseguiintf.inc}
{$endif}

function getapplicationwindow: winidty;
function ismonopixmap(pixmap: pixmapty): boolean;
procedure removemonopixmap(pixmap: pixmapty);
function msedefaultscreenno: integer;
{$ifdef usesdl}
function gui_getrootwindow(id: winidty = 0): winidty;
{$endif}
function msedisplay: pointer;
{$ifdef usesdl}
function gui_getpixel(const id: winidty; const pos: pointty;
                                             out pixel: pixelty): guierrorty;
{$endif}

//used by msewaylandgdi
function waylandbacksurface(id: winidty): psoftsurfacety;
procedure waylandpresent(surf: psoftsurfacety);
function waylandcreatepixmap(const size: sizety; const mono: boolean;
                                    const copyfrom: pixmapty): pixmapty;

var
 sdldebug: boolean;      //set by the environment variable MSEWLDEBUG
{$ifndef mseguibackendunit}
 mse_shapebmp: tmaskedbitmap;   //image of wo_customshape, dark = window
{$endif}

implementation

uses
{$ifdef mseguibackendunit}
 mseguiintf,
{$endif}
 sysutils,mselist,msekeyboard,msebits,msearrayutils,msesysutils,msegui,
 msesysintf1,BaseUnix,ctypes,xkbcommon,mseprocmonitor,
 msedragglob,msesysdnd;

type
 tapplication1 = class(tguiapplication);
 tbitmap1 = class(tbitmap);

var
 mainthread: longword;
 wins: array of twlwindow;        //all windows created by gui_createwindow
 evlist: array of tmseevent;      //translated events, main thread only
 evhead: integer;
 usrq: array of tmseevent;        //posted events, any thread
 usrlock: trtlcriticalsection;
 lockvalid: boolean;              //false after the unit finalization
 wakepipe: array[0..1] of cint;
 timerdue: qword;                 //ms, 0 = no timer
 escapepressed: boolean;
 clipboardtext: msestring;
 terminated: boolean;             //set by the SIGTERM handler
 sigtermbefore: SignalHandler;
 childevent: boolean;             //set by the SIGCHLD handler
 sigchldbefore: SignalHandler;

 //focus and pointer state
 focuswin: twlwindow;             //toplevel with the keyboard focus (posted)
 focusleavepending: boolean;
 pointerwin: twlwindow;
 pointerpx,pointerpy: integer;    //pointer position in pointerwin
 lastpointerwin: twlwindow;       //keeps the position after leave
 buttonmask: integer;             //1 left, 2 middle, 4 right
 lastbutton: mousebuttonty;
 wheelpending: integer;           //steps from axisdiscrete
 wheelaccum: double;
 monopixmaps: array of ptruint;

const
 monomsbfirst = false;   //bit order of mono data
 monoinvert = false;     //polarity of mono data

//windows

function findwin(const id: winidty): twlwindow;
var
 i: integer;
begin
 result:= nil;
 if id <> 0 then begin
  for i:= 0 to high(wins) do begin
   if ptruint(wins[i]) = ptruint(id) then begin
    result:= wins[i];
    break;
   end;
  end;
 end;
end;

function winid(const win: twlwindow): winidty;
begin
 result:= winidty(ptruint(win));
end;

function rootwin(win: twlwindow): twlwindow;
begin
 result:= win;
 while (result <> nil) and (result.kind <> wlk_toplevel) and
                                           (result.parent <> nil) do begin
  result:= result.parent;
 end;
end;

function winrect(const win: twlwindow): rectty;
begin
 result.x:= win.posx;
 result.y:= win.posy;
 result.cx:= win.width;
 result.cy:= win.height;
end;

function waylandbacksurface(id: winidty): psoftsurfacety;
var
 win: twlwindow;
begin
 win:= findwin(id);
 if win <> nil then begin
  result:= win.back;
 end
 else begin
  result:= nil;
 end;
end;



var
 dirtywins: array of twlwindow;       //windows with painted, unpresented content
 dirtytick: qword;                    //time of the first unpresented paint

procedure waylandpresent(surf: psoftsurfacety);
//called by gdi_endpaint, possibly several times in one repaint pass: only
//mark the window, flushpresents shows the finished frame
var
 i,j: integer;
 w: twlwindow;
 found: boolean;
begin
 if surf <> nil then begin
  for i:= 0 to high(wins) do begin
   if wins[i].back = surf then begin
    w:= wins[i];
    found:= false;
    for j:= 0 to high(dirtywins) do begin
     if dirtywins[j] = w then begin
      found:= true;
      break;
     end;
    end;
    if not found then begin
     if length(dirtywins) = 0 then begin
      dirtytick:= GetTickCount64;
     end;
     setlength(dirtywins,length(dirtywins) + 1);
     dirtywins[high(dirtywins)]:= w;
    end;
    break;
   end;
  end;
 end;
end;

procedure flushpresents;
var
 i,j: integer;
 list: array of twlwindow;
begin
 if length(dirtywins) = 0 then begin
  exit;
 end;
 list:= dirtywins;
 dirtywins:= nil;
 for i:= 0 to high(list) do begin
  for j:= 0 to high(wins) do begin
   if wins[j] = list[i] then begin   //still exists
    if sdldebug then begin
     writeln('PRESENT win ',j,' ',list[i].width,'x',list[i].height);
     flush(system.output);
    end;
    wlc_present(list[i]);
    break;
   end;
  end;
 end;
end;

function getapplicationwindow: winidty;
begin
 result:= 0;
end;

function gui_getrootwindow(id: winidty = 0): winidty;
begin
 result:= 0;
end;

function msedisplay: pointer;
begin
 result:= nil;
end;

function msedefaultscreenno: integer;
begin
 result:= 0;
end;

function gui_getpixel(const id: winidty; const pos: pointty;
                                             out pixel: pixelty): guierrorty;
begin
 pixel:= 0;
 result:= gue_error;      //Wayland can not read the screen
end;

{$ifndef usesdl}
//functions of the X11 interface that have no meaning on Wayland

procedure gui_disconnectmaineventqueue();
begin
 //nothing to do, the event loop is not blocked in a connection
end;

procedure gui_connectmaineventqueue();
begin
end;



procedure gui_getppmm(id: winidty; out appmmwidth,appmmheight: flo64);
begin
 appmmwidth:= 0;                  //0.0 = not supported
 appmmheight:= 0;
end;

function gui_graytopixel(gray: byte): pixelty;
begin
 result:= gui_rgbtopixel(longword(gray) * $010101);
end;

function gui_pixeltogray(pixel: pixelty): byte;
var
 rgb: longword;
begin
 rgb:= gui_pixeltorgb(pixel);
 result:= (((rgb shr 16) and $ff) + ((rgb shr 8) and $ff) +
                                                    (rgb and $ff)) div 3;
end;
{$endif}

//event lists

procedure putevent(const event: tmseevent);
begin
 if event <> nil then begin
  setlength(evlist,length(evlist)+1);
  evlist[high(evlist)]:= event;
 end;
end;

function getlistevent: tmseevent;
begin
 result:= nil;
 if evhead < length(evlist) then begin
  result:= evlist[evhead];
  evlist[evhead]:= nil;
  inc(evhead);
  if evhead >= length(evlist) then begin
   setlength(evlist,0);
   evhead:= 0;
  end;
 end;
end;

procedure wakeup;
var
 b: byte;
begin
 if wakepipe[1] < 0 then begin
  exit;                           //not initialized or already closed
 end;
 b:= 1;
 fpwrite(wakepipe[1],b,1);
end;

procedure drainwakepipe;
var
 buf: array[0..63] of byte;
begin
 while fpread(wakepipe[0],buf,sizeof(buf)) > 0 do begin
 end;
end;

procedure sigterminate(signum: cint); cdecl;
begin
 terminated:= true;
 wakeup;                          //leave the poll, async signal safe
end;

procedure sigchild(signum: cint); cdecl;
begin
 childevent:= true;
 mseprocmonitor.sigchildcallback();
 wakeup;
end;

function usrcount: integer;
begin
 if not lockvalid then begin
  result:= 0;                     //application destroyed after our finalization
  exit;
 end;
 entercriticalsection(usrlock);
 result:= length(usrq);
 leavecriticalsection(usrlock);
end;

function getusrevent: tmseevent;
begin
 result:= nil;
 if not lockvalid then begin
  exit;
 end;
 entercriticalsection(usrlock);
 try
  if length(usrq) > 0 then begin
   result:= usrq[0];
   move(usrq[1],usrq[0],(length(usrq)-1)*sizeof(usrq[0]));
   pointer(usrq[high(usrq)]):= nil;
   setlength(usrq,high(usrq));
  end;
 finally
  leavecriticalsection(usrlock);
 end;
end;

function timerisdue: boolean;
begin
 result:= (timerdue <> 0) and (GetTickCount64 >= timerdue);
end;

function gui_postevent(event: tmseevent): guierrorty;
begin
 if not lockvalid then begin
  event.free;
  result:= gue_ok;
  exit;
 end;
 entercriticalsection(usrlock);
 try
  setlength(usrq,length(usrq)+1);
  usrq[high(usrq)]:= event;
 finally
  leavecriticalsection(usrlock);
 end;
 wakeup;
 result:= gue_ok;
end;

function gui_settimer(us: longword): guierrorty;
begin
 timerdue:= GetTickCount64 + us div 1000;
 if timerdue = 0 then begin
  timerdue:= 1;
 end;
 if mainthread <> getcurrentthreadid then begin
  wakeup;
 end;
 result:= gue_ok;
end;

//key translation, xkb keysyms are the same as the X11 keysyms

function keysymtokey(const key: cuint32; var shiftstate: shiftstatesty): keyty;
begin
 if (key >= $61) and (key <= $7a) then begin //a..z
  result:= keyty(key - $20);
 end
 else begin
  case key of
   $ff08: result:= key_backspace;
   $ff09: result:= key_tab;
   $fe20: result:= key_backtab;
   $ff0d: result:= key_return;
   $ff13: result:= key_pause;
   $ff14: result:= key_scrolllock;
   $ff15: result:= key_sysreq;
   $ff1b: result:= key_escape;
   $ffff: result:= key_delete;
   $ff50: result:= key_home;
   $ff51: result:= key_left;
   $ff52: result:= key_up;
   $ff53: result:= key_right;
   $ff54: result:= key_down;
   $ff55: result:= key_pageup;
   $ff56: result:= key_pagedown;
   $ff57: result:= key_end;
   $ff61: result:= key_print;
   $ff63: result:= key_insert;
   $ff67: result:= key_menu;
   $ff6a: result:= key_help;
   $ff6b: result:= key_pause;
   $ff7f: result:= key_numlock;

   $ff80: begin result:= key_space; include(shiftstate,ss_second); end;
   $ff89: begin result:= key_tab; include(shiftstate,ss_second); end;
   $ff8d: begin result:= key_return; include(shiftstate,ss_second); end;
   $ff91..$ff94: begin
    result:= keyty(longword(key_f1) + key - $ff91);
    include(shiftstate,ss_second);
   end;
   $ff95: begin result:= key_home; include(shiftstate,ss_second); end;
   $ff96: begin result:= key_left; include(shiftstate,ss_second); end;
   $ff97: begin result:= key_up; include(shiftstate,ss_second); end;
   $ff98: begin result:= key_right; include(shiftstate,ss_second); end;
   $ff99: begin result:= key_down; include(shiftstate,ss_second); end;
   $ff9a: begin result:= key_pageup; include(shiftstate,ss_second); end;
   $ff9b: begin result:= key_pagedown; include(shiftstate,ss_second); end;
   $ff9c: begin result:= key_end; include(shiftstate,ss_second); end;
   $ff9e: begin result:= key_insert; include(shiftstate,ss_second); end;
   $ff9f: begin result:= key_delete; include(shiftstate,ss_second); end;
   $ffbd: begin result:= key_equal; include(shiftstate,ss_second); end;
   $ffaa: begin result:= key_asterisk; include(shiftstate,ss_second); end;
   $ffab: begin result:= key_plus; include(shiftstate,ss_second); end;
   $ffac: begin result:= key_comma; include(shiftstate,ss_second); end;
   $ffad: begin result:= key_minus; include(shiftstate,ss_second); end;
   $ffae: begin result:= key_decimal; include(shiftstate,ss_second); end;
   $ffaf: begin result:= key_slash; include(shiftstate,ss_second); end;
   $ffb0..$ffb9: begin
    result:= keyty(longword(key_0) + key - $ffb0);
    include(shiftstate,ss_second);
   end;

   $ffbe..$ffe0: result:= keyty(longword(key_f1) + key - $ffbe);

   $ffe1: result:= key_shift;
   $ffe2: begin result:= key_shift; include(shiftstate,ss_second); end;
   $ffe3: result:= key_control;
   $ffe4: begin result:= key_control; include(shiftstate,ss_second); end;
   $ffe5: result:= key_capslock;
   $ffe7: result:= key_meta;
   $ffe8: begin result:= key_meta; include(shiftstate,ss_second); end;
   $ffe9: result:= key_alt;
   $ffea: begin result:= key_alt; include(shiftstate,ss_second); end;
   $ffeb: result:= key_super;
   $ffec: begin result:= key_super; include(shiftstate,ss_second); end;
   $ffed: result:= key_hyper;
   $ffee: begin result:= key_hyper; include(shiftstate,ss_second); end;

   $fe03: result:= key_altgr;

   else result:= keyty(key and $ffff);
  end;
 end;
end;

function modstoshiftstate(const mods: twlmods): shiftstatesty;
begin
 result:= [];
 if wlm_shift in mods then begin
  include(result,ss_shift);
 end;
 if wlm_ctrl in mods then begin
  include(result,ss_ctrl);
 end;
 if wlm_alt in mods then begin
  include(result,ss_alt);
 end;
 if buttonmask and 1 <> 0 then begin
  include(result,ss_left);
 end;
 if buttonmask and 2 <> 0 then begin
  include(result,ss_middle);
 end;
 if buttonmask and 4 <> 0 then begin
  include(result,ss_right);
 end;
end;

function timestamp(const ms: cuint32): longword;
begin
 result:= longword((qword(ms) * 1000) and $ffffffff);
end;

function utf8tomsestring(const s: string): msestring;
begin
 if s = '' then begin
  result:= '';
 end
 else begin
  result:= utf8tostring(pchar(s),length(s));
 end;
end;

//translation of the Wayland client events

procedure postwheel(const win: twlwindow; const steps: integer;
                               const ev: twlevent);
var
 wh: mousewheelty;
 n: integer;
 pt: pointty;
begin
 if steps <> 0 then begin
  if steps > 0 then begin          //Wayland: positive = scroll down
   wh:= mw_down;
   n:= steps;
  end
  else begin
   wh:= mw_up;
   n:= -steps;
  end;
  pt.x:= ev.x;
  pt.y:= ev.y;
  while n > 0 do begin
   putevent(tmouseevent.create(winid(win),false,mb_none,wh,pt,
                             modstoshiftstate(ev.mods),timestamp(ev.time)));
   dec(n);
  end;
 end;
end;

//drag and drop, receiving: the events become tsysdndevent like with xdnd

procedure translatednd(const ev: twlevent);
var
 kind: drageventkindty;
 mimes: twlstrings;
 fmts: msestringarty;
 ist: booleanarty;
 acts: dndactionsty;
 pt: pointty;
 i: integer;
 win: twlwindow;
begin
 win:= ev.window;
 case ev.kind of
  wle_dndmotion: begin
   kind:= dek_check;
  end;
  wle_dnddrop: begin
   kind:= dek_drop;
  end;
  else begin
   kind:= dek_leavesysdnd;
  end;
 end;
 fmts:= nil;
 ist:= nil;
 acts:= [dnda_copy];
 if kind <> dek_leavesysdnd then begin
  mimes:= wlc_dndmimes;
  setlength(fmts,length(mimes));
  setlength(ist,length(mimes));
  for i:= 0 to high(mimes) do begin
   fmts[i]:= utf8tomsestring(mimes[i]);
   ist[i]:= false;                    //like xdnd
  end;
  case wlc_dndaction of
   WLDND_MOVE: begin
    acts:= [dnda_move];
   end;
   WLDND_ASK: begin
    acts:= [dnda_ask];
   end;
  end;
 end;
 pt.x:= ev.x + win.posx;               //like xdnd: screen position
 pt.y:= ev.y + win.posy;
 if sdldebug then begin
  writeln('dnd event kind=',ord(kind),' pos=',pt.x,',',pt.y,
                       ' formats=',length(fmts));
  flush(system.output);
 end;
 putevent(tsysdndevent.create(kind,winid(win),pt,modstoshiftstate(ev.mods),
                                                  false,fmts,ist,acts));
end;

procedure translateevent(const ev: twlevent);
var
 win,root: twlwindow;
 id: winidty;
 key1: keyty;
 shiftstate1: shiftstatesty;
 chars: msestring;
 btn: mousebuttonty;
 pt: pointty;
 rect1: rectty;
 steps: integer;
begin
 win:= ev.window;
 if win = nil then begin
  exit;
 end;
 id:= winid(win);
 case ev.kind of
  wle_configure: begin
   putevent(twindowrectevent.create(ek_configure,id,winrect(win),nullpoint));
  end;
  wle_expose: begin
   rect1:= winrect(win);
   rect1.x:= 0;
   rect1.y:= 0;
   putevent(twindowrectevent.create(ek_expose,id,rect1,nullpoint));
  end;
  wle_close: begin
   putevent(twindowevent.create(ek_close,id));
  end;
  wle_popupdone: begin
   wlc_hide(win);
   putevent(twindowevent.create(ek_close,id));
  end;
  wle_keyboardenter: begin
   root:= rootwin(win);
   if focusleavepending and (root = focuswin) then begin
    focusleavepending:= false;       //leave/enter pair of a popup grab
   end
   else begin
    if focuswin <> root then begin
     if focuswin <> nil then begin
      putevent(twindowevent.create(ek_focusout,winid(focuswin)));
     end;
     focuswin:= root;
     putevent(twindowevent.create(ek_focusin,winid(root)));
    end;
    focusleavepending:= false;
   end;
  end;
  wle_keyboardleave: begin
   focusleavepending:= true;         //decided after the event batch
  end;
  wle_pointerenter: begin
   pointerwin:= win;
   lastpointerwin:= win;
   pointerpx:= ev.x;
   pointerpy:= ev.y;
   putevent(twindowevent.create(ek_enterwindow,id));
  end;
  wle_pointerleave: begin
   if pointerwin = win then begin
    pointerwin:= nil;
   end;
   putevent(twindowevent.create(ek_leavewindow,id));
  end;
  wle_pointermotion: begin
   pointerwin:= win;
   lastpointerwin:= win;
   pointerpx:= ev.x;
   pointerpy:= ev.y;
   pt.x:= ev.x;
   pt.y:= ev.y;
   putevent(tmouseevent.create(id,false,mb_none,mw_none,pt,
                    modstoshiftstate(ev.mods),timestamp(ev.time)));
  end;
  wle_button: begin
   case ev.button of
    BTN_LEFT: begin
     btn:= mb_left;
    end;
    BTN_RIGHT: begin
     btn:= mb_right;
    end;
    BTN_MIDDLE: begin
     btn:= mb_middle;
    end;
    else begin
     btn:= mb_none;
    end;
   end;
   if btn <> mb_none then begin
    pointerpx:= ev.x;
    pointerpy:= ev.y;
    lastpointerwin:= win;
    case btn of
     mb_left: begin
      if ev.pressed then buttonmask:= buttonmask or 1
                    else buttonmask:= buttonmask and not 1;
     end;
     mb_middle: begin
      if ev.pressed then buttonmask:= buttonmask or 2
                    else buttonmask:= buttonmask and not 2;
     end;
     mb_right: begin
      if ev.pressed then buttonmask:= buttonmask or 4
                    else buttonmask:= buttonmask and not 4;
     end;
    end;
    pt.x:= ev.x;
    pt.y:= ev.y;
    putevent(tmouseevent.create(id,not ev.pressed,btn,mw_none,pt,
                    modstoshiftstate(ev.mods),timestamp(ev.time)));
   end;
  end;
  wle_axisdiscrete: begin
   if ev.axis = 0 then begin
    wheelpending:= wheelpending + round(ev.value);
   end;
  end;
  wle_axis: begin
   if ev.axis = 0 then begin
    if wheelpending <> 0 then begin       //wheel: the discrete steps count
     steps:= wheelpending;
     wheelpending:= 0;
     wheelaccum:= 0;
    end
    else begin                            //touchpad: 10 units = 1 step
     wheelaccum:= wheelaccum + ev.value;
     steps:= trunc(wheelaccum / 10);
     wheelaccum:= wheelaccum - steps * 10;
    end;
    postwheel(win,steps,ev);
   end;
  end;
  wle_dndmotion,wle_dnddrop,wle_dndleave: begin
   translatednd(ev);
  end;
  wle_key: begin
   shiftstate1:= modstoshiftstate(ev.mods);
   key1:= keysymtokey(ev.keysym0,shiftstate1);
   if ev.pressed then begin
    chars:= utf8tomsestring(ev.utf8);
    if key1 = key_escape then begin
     escapepressed:= true;
    end;
   end
   else begin
    chars:= '';
   end;
   putevent(tkeyevent.create(id,not ev.pressed,key1,key1,shiftstate1,chars,
                                                       timestamp(ev.time)));
  end;
 end;
end;

procedure processwayland;
var
 ev: twlevent;
begin
 while wlc_nextevent(ev) do begin
  translateevent(ev);
 end;
 if focusleavepending then begin     //keyboard left and did not come back
  focusleavepending:= false;
  if focuswin <> nil then begin
   putevent(twindowevent.create(ek_focusout,winid(focuswin)));
   focuswin:= nil;
  end;
 end;
end;

//registered poll fds, polled together with the Wayland connection

type
 wlpollinfoty = record
  fd: int32;
  events: int32;
  callback: pollcallbackty;
  data: pointer;
 end;

var
 wlpoll: array of wlpollinfoty;

type
 wlpendingpollty = record
  flags: pollflagsty;
  callback: pollcallbackty;
  data: pointer;
 end;

var
 wlpending: array of wlpendingpollty;   //polled, callbacks not yet called

function gui_addpollfd(var id: int32; const afd: int32;
                           const aflags: pollflagsty;
                                const acallback: pollcallbackty = nil;
                                      const adata: pointer = nil): guierrorty;
begin
 result:= gue_ok;
 setlength(wlpoll,length(wlpoll)+1);
 id:= high(wlpoll);
 with wlpoll[id] do begin
  fd:= afd;
  events:= int32(aflags * [pf_in,pf_pri,pf_out]);
  callback:= acallback;
  data:= adata;
 end;
end;

function gui_removepollfd(const id: int32): guierrorty;
var
 i: integer;
begin
 if (id < 0) or (id > high(wlpoll)) then begin
  result:= gue_index;
 end
 else begin
  for i:= id to high(wlpoll)-1 do begin
   wlpoll[i]:= wlpoll[i+1];       //later ids shift down, as on Linux
  end;
  setlength(wlpoll,high(wlpoll));
  result:= gue_ok;
 end;
end;

function gui_setpollfdactive(const id: int32;
                       const aactive: boolean): guierrorty;
begin
 if (id < 0) or (id > high(wlpoll)) then begin
  result:= gue_index;
 end
 else begin
  with wlpoll[id] do begin
   if (fd >= 0) xor aactive then begin
    if fd = 0 then begin
     fd:= minint;
    end
    else begin
     if fd = minint then begin
      fd:= 0;
     end
     else begin
      fd:= -fd;
     end;
    end;
   end;
  end;
  result:= gue_ok;
 end;
end;

procedure dispatchpolls;       //calls the callbacks, application is locked
var
 list: array of wlpendingpollty;
 i: integer;
begin
 if length(wlpending) > 0 then begin
  list:= wlpending;
  wlpending:= nil;
  for i:= 0 to high(list) do begin
   if assigned(list[i].callback) then begin
    list[i].callback(list[i].flags,list[i].data);
   end;
  end;
 end;
end;

function pollrevents(const revents: integer): pollflagsty;
begin
 result:= [];
 if revents and POLLIN <> 0 then begin
  include(result,pf_in);
 end;
 if revents and POLLPRI <> 0 then begin
  include(result,pf_pri);
 end;
 if revents and POLLOUT <> 0 then begin
  include(result,pf_out);
 end;
 if revents and POLLERR <> 0 then begin
  include(result,pf_err);
 end;
 if revents and POLLHUP <> 0 then begin
  include(result,pf_hup);
 end;
 if revents and POLLNVAL <> 0 then begin
  include(result,pf_nval);
 end;
end;

//waits for Wayland events, the wake up pipe and the registered poll fds,
//application is not locked. The poll fd callbacks are called later by
//dispatchpolls
procedure waitwayland(const timeoutms: integer);
var
 fds: array of tpollfd;
 snap: array of wlpollinfoty;
 fd,res: cint;
 readable: boolean;
 i,n: integer;
begin
 fd:= wlc_pollprepare;
 if wlc_hasevents then begin
  wlc_pollfinish(false);
  exit;
 end;
 snap:= copy(wlpoll,0,length(wlpoll));
 setlength(fds,2 + length(snap));
 fds[0].fd:= fd;
 fds[0].events:= POLLIN;
 fds[0].revents:= 0;
 fds[1].fd:= wakepipe[0];
 fds[1].events:= POLLIN;
 fds[1].revents:= 0;
 for i:= 0 to high(snap) do begin
  fds[2+i].fd:= snap[i].fd;          //negative fd = inactive, ignored
  fds[2+i].events:= snap[i].events;
  fds[2+i].revents:= 0;
 end;
 res:= fpPoll(@fds[0],length(fds),wlc_timeout(timeoutms));
 readable:= (res > 0) and (fds[0].revents and POLLIN <> 0);
 wlc_pollfinish(readable);
 wlc_timers;
 if res > 0 then begin
  if fds[1].revents and POLLIN <> 0 then begin
   drainwakepipe;
  end;
  for i:= 0 to high(snap) do begin
   if (snap[i].fd >= 0) and (fds[2+i].revents <> 0) then begin
    n:= length(wlpending);
    setlength(wlpending,n + 1);
    wlpending[n].flags:= pollrevents(fds[2+i].revents);
    wlpending[n].callback:= snap[i].callback;
    wlpending[n].data:= snap[i].data;
   end;
  end;
 end;
end;


function gui_hasevent: boolean;
begin
 if not wlc_connected then begin   //called while the application is destroyed
  result:= evhead < length(evlist);
  exit;
 end;
 if childevent then begin
  childevent:= false;
  handlesigchld;                  //child process state changed
 end;
 result:= (evhead < length(evlist)) or (usrcount > 0) or timerisdue or
                                                                terminated;
 if not result then begin
  flushpresents;                  //idle: show the finished frame
  waitwayland(0);
  dispatchpolls;
  processwayland;
  result:= (evhead < length(evlist)) or (usrcount > 0) or timerisdue or
                                                                terminated;
 end;
end;


function gui_getevent: tmseevent;
var
 locked: boolean;
 timeout: integer;
 now: qword;
begin
 result:= nil;
 if not wlc_connected then begin
  result:= getlistevent;
  exit;
 end;
 if (length(dirtywins) > 0) and (GetTickCount64 - dirtytick >= 16) then begin
  flushpresents;       //events keep coming: show the frame at most 16 ms late
 end;
 while true do begin
  result:= getlistevent;
  if result <> nil then begin
   break;
  end;
  result:= getusrevent;
  if result <> nil then begin
   break;
  end;
  if timerisdue then begin
   timerdue:= 0;
   result:= tmseevent.create(ek_timer);
   break;
  end;
  if terminated then begin
   terminated:= false;
   result:= tmseevent.create(ek_terminate);
   break;
  end;
  if childevent then begin
   childevent:= false;
   handlesigchld;
   continue;
  end;
  timeout:= 10000;
  if timerdue <> 0 then begin
   now:= GetTickCount64;
   if timerdue > now then begin
    if timerdue - now < qword(timeout) then begin
     timeout:= integer(timerdue - now);
    end;
   end
   else begin
    timeout:= 0;
   end;
  end;
  flushpresents;                   //idle: show the finished frame
  locked:= application.unlock();
  try
   waitwayland(timeout);
  finally
   if locked then begin
    application.lock();
   end;
  end;
  dispatchpolls;
  processwayland;
  if (evhead >= length(evlist)) and (usrcount = 0) and not timerisdue and
                                    not terminated and not childevent then begin
   break;                  //wake up or timeout, MSEgui rechecks its state
  end;
 end;
 if sdldebug then begin
  if result <> nil then begin
   writeln('GETEVENT ',result.classname,' kind=',ord(result.kind));
  end
  else begin
   writeln('GETEVENT nil');
  end;
  flush(output);
 end;
end;


function gui_escapepressed: boolean;
begin
 result:= escapepressed;
end;

procedure gui_resetescapepressed;
begin
 escapepressed:= false;
end;

//title text of the client side decoration

function rendertitle(const atitle: string; const w,h: integer;
                                 const bg,fg: longword): psoftsurfacety;
var
 bmp: tbitmap1;
 src,src1: psoftsurfacety;
 x,y,minx,maxx,miny,yb,dx,dy,inkw: integer;
 po: plongword;
 bgpix: longword;
begin
 result:= nil;
 waylandpushgcstate;                 //nested drawing must not disturb the
 try                                 //state of the running canvas
  bmp:= tbitmap1.create(bmk_rgb);
  try
   bmp.size:= makesize(w,h);
   bmp.init(rgbtocolor((bg shr 16) and $ff,(bg shr 8) and $ff,bg and $ff));
   yb:= 0;
   with bmp.canvas do begin
    font.height:= 14;
    color:= rgbtocolor((fg shr 16) and $ff,(fg shr 8) and $ff,fg and $ff);
    yb:= (h + font.ascent - font.descent) div 2;   //first guess of the baseline
    drawstring(utf8tomsestring(atitle),makepoint(0,yb));
   end;
   src:= psoftsurfacety(ptruint(bmp.handle));
   if src <> nil then begin
    result:= createsoftsurface(w,h);
    softcopy(result,0,0,src,softrect(0,0,w,h),false);
    for y:= 0 to h-1 do begin
     po:= plongword(ptruint(result^.pixels) + ptruint(y*result^.pitch));
     for x:= 0 to w-1 do begin
      po^:= po^ or $ff000000;
      inc(po);
     end;
    end;
    //find the extent of the text, the background is the color of the first
    //pixel
    bgpix:= plongword(result^.pixels)^;
    minx:= w;
    maxx:= -1;
    miny:= h;
    for y:= 0 to h-1 do begin
     po:= plongword(ptruint(result^.pixels) + ptruint(y*result^.pitch));
     for x:= 0 to w-1 do begin
      if po^ <> bgpix then begin
       if x < minx then begin
        minx:= x;
       end;
       if x > maxx then begin
        maxx:= x;
       end;
       if y < miny then begin
        miny:= y;
       end;
      end;
      inc(po);
     end;
    end;
    if maxx >= minx then begin
     inkw:= maxx - minx + 1;
     dx:= (w - inkw) div 2;                 //centered horizontally
     //vertical: center the box from the top of the letters to the baseline
     dy:= (h - (yb - miny)) div 2 - miny;
     if miny + dy < 1 then begin
      dy:= 1 - miny;                        //keep the outline row free
     end;
     src1:= createsoftsurface(w,h);
     softfillrect(src1,softrect(0,0,w,h),bgpix and $ffffff,255);
     softcopy(src1,dx,dy,result,softrect(minx,0,inkw,h),false);
     freesoftsurface(result);
     result:= src1;
    end;
   end;
  finally
   bmp.free;
  end;
 finally
  waylandpopgcstate;
 end;
end;

//small stubs

function gui_sethighrestimer(const avalue: boolean): guierrorty;
begin
 result:= gue_ok;
end;

function gui_grouphideminimizedwindows: boolean;
begin
 result:= true;
end;

function gui_setimefocus(var awindow: windowty): guierrorty;
begin
 result:= gue_ok;
end;

function gui_unsetimefocus(var awindow: windowty): guierrorty;
begin
 result:= gue_ok;
end;

function gui_regiontorects(const aregion: regionty): rectarty;
begin
 result:= gdi_regiontorects(aregion);
end;

function gui_getdefaultfontnames: defaultfontnamesty;
begin
 result:= waylandgetdefaultfontnames;
end;

function gui_canstackunder: boolean;
begin
 result:= false;
end;

procedure gui_cancelshutdown;
begin
end;

function gui_flushgdi(const synchronize: boolean = false): guierrorty;
begin
 wlc_flush;
 result:= gue_ok;
end;

procedure gui_beep;
begin
end;

function gui_setmainthread: guierrorty;
begin
 mainthread:= getcurrentthreadid;
 result:= gue_ok;
end;

function gui_initcolormap: guierrorty;
begin
 result:= gue_ok;
end;

function gui_rgbtopixel(rgb: longword): pixelty;
begin
 result:= swaprgb(rgb);
end;

function gui_pixeltorgb(pixel: pixelty): longword;
begin
 result:= swaprgb(pixel);
end;

function gui_pidtowinid(const pids: procidarty): winidty;
begin
 result:= 0;
end;

function gui_setapplicationicon(const icon,mask: pixmapty): guierrorty;
begin
 result:= gue_ok;
end;

function gui_setwindowicon(id: winidty; const icon,mask: pixmapty): guierrorty;
begin
 result:= gue_ok;
end;

function gui_setwindowgroup(id: winidty; group: winidty): guierrorty;
begin
 result:= gue_ok;
end;

function gui_settransientfor(var awindow: windowty;
                                  const transientfor: winidty): guierrorty;
begin
 result:= gue_ok;
end;

function gui_setcursorshape(winid: winidty; shape: cursorshapety): guierrorty;
var
 win: twlwindow;
 aname: string;
begin
 win:= findwin(winid);
 case shape of
  cr_none: aname:= 'none';
  cr_cross: aname:= 'crosshair';
  cr_wait: aname:= 'watch';
  cr_ibeam: aname:= 'xterm';
  cr_sizever,cr_splitv: aname:= 'sb_v_double_arrow';
  cr_sizehor,cr_splith: aname:= 'sb_h_double_arrow';
  cr_sizebdiag: aname:= 'top_right_corner';
  cr_sizefdiag: aname:= 'top_left_corner';
  cr_sizeall: aname:= 'fleur';
  cr_pointinghand: aname:= 'hand2';
  cr_forbidden: aname:= 'crossed_circle';
  cr_topleftcorner: aname:= 'top_left_corner';
  cr_bottomleftcorner: aname:= 'bottom_left_corner';
  cr_bottomrightcorner: aname:= 'bottom_right_corner';
  cr_toprightcorner: aname:= 'top_right_corner';
  cr_drag: aname:= 'dnd-copy';
  else aname:= '';
 end;
 if win <> nil then begin
  wlc_setcursor(win,aname);
 end;
 result:= gue_ok;
end;

function gui_setappfocus(id: winidty): guierrorty;
begin
 result:= gue_ok;
end;

function gui_setwindowfocus(id: winidty): guierrorty;
begin
 result:= gue_ok;                 //only the compositor can set the focus
end;

function gui_minimizeapplication: guierrorty;
var
 i: integer;
begin
 for i:= 0 to high(wins) do begin
  if wins[i].kind = wlk_toplevel then begin
   wlc_setminimized(wins[i]);
  end;
 end;
 result:= gue_ok;
end;

function gui_windowatpos(const pos: pointty): winidty;
begin
 result:= 0;
end;

function gui_setsizeconstraints(id: winidty; const min,max: sizety): guierrorty;
var
 win: twlwindow;
begin
 win:= findwin(id);
 if win <> nil then begin
  wlc_setsizeconstraints(win,min.cx,min.cy,max.cx,max.cy);
 end;
 result:= gue_ok;
end;


function gui_movewindowrect(id: winidty; const dist: pointty;
                                             const rect: rectty): guierrorty;
var
 win: twlwindow;
 surf: psoftsurfacety;
 saveclip: softrectty;
 r: rectty;
begin
 result:= gue_ok;
 win:= findwin(id);
 if win <> nil then begin
  surf:= win.back;
  if surf <> nil then begin
   if sdldebug then begin
    writeln('movewindowrect ',rect.x,',',rect.y,' ',rect.cx,'x',rect.cy,
                                  ' dist ',dist.x,',',dist.y);
    flush(system.output);
   end;
   //rect is the SOURCE area, it lands at rect + dist (like XCopyArea on
   //X11). The destination is only limited by the surface, not by rect.
   //softcopy handles overlapping rows and columns of the same surface.
   r:= intersectrect(rect,makerect(0,0,surf^.width,surf^.height));
   if (r.cx > 0) and (r.cy > 0) then begin
    saveclip:= surf^.clip;
    softresetclip(surf);
    softcopy(surf,r.x + dist.x,r.y + dist.y,surf,
                           softrect(r.x,r.y,r.cx,r.cy),false);
    surf^.clip:= saveclip;
   end;
  end;
 end;
end;


function gui_stackunderwindow(id: winidty; predecessor: winidty): guierrorty;
begin
 result:= gue_ok;
end;

function gui_stackoverwindow(id: winidty; predecessor: winidty): guierrorty;
begin
 result:= gue_ok;
end;

{$ifdef usesdl}
function gui_raisewindow(id: winidty): guierrorty;
{$else}
function gui_raisewindow(id: winidty; const topmost: boolean = false): guierrorty;
{$endif}
begin
 result:= gue_ok;                 //not possible with Wayland
end;

{$ifdef usesdl}
function gui_lowerwindow(id: winidty): guierrorty;
{$else}
function gui_lowerwindow(id: winidty; const topmost: boolean = false): guierrorty;
{$endif}
begin
 result:= gue_ok;
end;

function gui_getzorder(const ids: winidarty; out zorders: integerarty): guierrorty;
var
 i: integer;
begin
 setlength(zorders,length(ids));
 for i:= 0 to high(ids) do begin
  zorders[i]:= i;
 end;
 result:= gue_ok;
end;

function gui_getparentwindow(const awindow: winidty): winidty;
begin
 result:= awindow;
end;

function gui_reparentwindow(const child: winidty; const parent: winidty;
                            const pos: pointty): guierrorty;
begin
 result:= gue_reparent;
end;

function gui_getchildren(const id: winidty; out children: winidarty): guierrorty;
begin
 children:= nil;
 result:= gue_ok;
end;

function gui_showsysdock(var awindow: windowty): guierrorty;
begin
 result:= gui_hidewindow(awindow.id);
end;

function gui_hidesysdock(var awindow: windowty): guierrorty;
begin
 result:= gui_hidewindow(awindow.id);
end;

function gui_docktosyswindow(var child: windowty;
                                   const akind: syswindowty): guierrorty;
begin
 result:= gue_notraywindow;
end;

function gui_traymessage(var awindow: windowty; const message: msestring;
                          out messageid: longword;
                          const timeoutms: longword = 0): guierrorty;
begin
 messageid:= 1;
 result:= gue_notraywindow;
end;

function gui_canceltraymessage(var awindow: windowty;
                          const messageid: longword): guierrorty;
begin
 result:= gue_notraywindow;
end;

function gui_settrayicon(var awindow: windowty;
                                     const icon,mask: pixmapty): guierrorty;
begin
 result:= gue_notraywindow;
end;

function gui_settrayhint(var awindow: windowty;
                                     const hint: msestring): guierrorty;
begin
 result:= gue_notraywindow;
end;

procedure GUI_DEBUGBEGIN;
begin
end;

procedure GUI_DEBUGEND;
begin
end;

//clipboard, text through wl_data_device

{$ifdef usesdl}
function gui_copytoclipboard(const value: msestring): guierrorty;
begin
 clipboardtext:= value;
 wlc_clipboardset(stringtoutf8ansi(value));
 result:= gue_ok;
end;

function gui_canpastefromclipboard(): boolean;
begin
 result:= wlc_clipboardcanpaste or (clipboardtext <> '');
end;

function gui_pastefromclipboard(out value: msestring): guierrorty;
var
 s: string;
begin
 if wlc_clipboardget(s) then begin
  value:= utf8tomsestring(s);
 end
 else begin
  value:= clipboardtext;
 end;
 result:= gue_ok;
end;
{$else}
var
 localbuffertext: msestring;     //buffers other than cbb_clipboard

function gui_copytoclipboard(const value: msestring;
                             const buffer: clipboardbufferty): guierrorty;
begin
 if buffer = cbb_clipboard then begin
  clipboardtext:= value;
  wlc_clipboardset(stringtoutf8ansi(value));
 end
 else begin
  localbuffertext:= value;
 end;
 result:= gue_ok;
end;

function gui_canpastefromclipboard(const buffer: clipboardbufferty): boolean;
begin
 if buffer = cbb_clipboard then begin
  result:= wlc_clipboardcanpaste or (clipboardtext <> '');
 end
 else begin
  result:= localbuffertext <> '';
 end;
end;

function gui_pastefromclipboard(out value: msestring;
                             const buffer: clipboardbufferty): guierrorty;
var
 s: string;
begin
 if buffer = cbb_clipboard then begin
  if wlc_clipboardget(s) then begin
   value:= utf8tomsestring(s);
  end
  else begin
   value:= clipboardtext;
  end;
 end
 else begin
  value:= localbuffertext;
 end;
 result:= gue_ok;
end;
{$endif}

//drag and drop

var
 dndintf: isysdnd;               //source object of the drag in progress
 dndstarted: boolean;            //the compositor does the drag

function dndactionmask(const aactions: dndactionsty): cuint32;
begin
 result:= 0;
 if dnda_copy in aactions then begin
  result:= result or WLDND_COPY;
 end;
 if dnda_move in aactions then begin
  result:= result or WLDND_MOVE;
 end;
 if dnda_ask in aactions then begin
  result:= result or WLDND_ASK;
 end;
 if result = 0 then begin
  result:= WLDND_COPY;
 end;
end;

function startdnd: boolean;
var
 fmts: msestringarty;
 mimes,data: twlstrings;
 i: integer;
begin
 result:= false;
 if dndintf <> nil then begin
  fmts:= dndintf.getformats;
  mimes:= nil;
  data:= nil;
  setlength(mimes,length(fmts));
  setlength(data,length(fmts));
  for i:= 0 to high(fmts) do begin      //data is converted now, the drag
   mimes[i]:= stringtoutf8ansi(fmts[i]);  //object can be gone when it is read
   data[i]:= dndintf.convertmimedata(i);
  end;
  result:= wlc_dndstart(mimes,data,dndactionmask(dndintf.getactions));
 end;
end;

function gui_sysdnd(const action: sysdndactionty;
                         const aintf: isysdnd; const arect: rectty;
                                         out aresult: boolean): guierrorty;
begin
 aresult:= false;
 result:= gue_ok;
 case action of
  sdnda_begin: begin                 //source
   dndintf:= aintf;
   dndstarted:= false;
  end;
  sdnda_check: begin                 //pointer is outside of our windows
   if dndstarted then begin
    aresult:= true;
   end
   else begin
    if startdnd then begin
     dndstarted:= true;
     aresult:= true;
    end;
   end;
  end;
  sdnda_drop: begin
   aresult:= dndstarted;
  end;
  sdnda_destroyed: begin             //the compositor keeps the started drag
   if (aintf <> nil) and (dndintf = aintf) then begin
    dndintf:= nil;
   end;
  end;
  sdnda_accept: begin                //target
   if wlc_dndactive then begin
    wlc_dndaccept(true);
   end
   else begin
    result:= gue_nodragpending;
   end;
  end;
  sdnda_reject: begin
   if wlc_dndactive then begin
    wlc_dndaccept(false);
   end
   else begin
    result:= gue_nodragpending;
   end;
  end;
  sdnda_finished: begin
   if wlc_dndactive then begin
    wlc_dndfinish;
   end
   else begin
    result:= gue_nodragpending;
   end;
  end;
  else begin
   result:= gue_error;
  end;
 end;
end;

function gui_sysdndreaddata(var adata: string;
                              const typeindex: integer): guierrorty;
begin
 result:= gue_nodragpending;
 if wlc_dndactive then begin
  if wlc_dndread(typeindex,adata) then begin
   result:= gue_ok;
  end
  else begin
   result:= gue_error;
  end;
 end;
end;

function gui_sysdndreadtext(var atext: msestring;
                              const typeindex: integer): guierrorty;
var
 s: string;
begin
 result:= gue_nodragpending;
 if wlc_dndactive then begin
  if wlc_dndread(typeindex,s) then begin
   atext:= utf8tomsestring(s);
   result:= gue_ok;
  end
  else begin
   result:= gue_error;
  end;
 end;
end;

//pointer

function gui_getpointerpos: pointty;
begin
 result.x:= pointerpx;
 result.y:= pointerpy;
 if (lastpointerwin <> nil) and (findwin(winid(lastpointerwin)) <> nil) then begin
  result.x:= result.x + lastpointerwin.posx;
  result.y:= result.y + lastpointerwin.posy;
 end;
end;

function gui_setpointerpos(const pos: pointty): guierrorty;
begin
 result:= gue_ok;           //Wayland can not warp the pointer
end;

function gui_movepointer(const dist: pointty): guierrorty;
begin
 result:= gue_ok;
end;

function gui_grabpointer(id: winidty): guierrorty;
begin
 result:= gue_ok;           //implicit grab while a button is pressed
end;

function gui_ungrabpointer: guierrorty;
begin
 result:= gue_ok;
end;

//screen

function gui_getscreenrect(const id: winidty): rectty; //0 -> virtual screen
var
 w,h: integer;
begin
 wlc_screensize(w,h);
 result.x:= 0;
 result.y:= 0;
 result.cx:= w;
 result.cy:= h;
end;

function gui_getworkarea(id: winidty): rectty;
begin
 result:= gui_getscreenrect(id);
end;

//pixmaps

procedure addmonopixmap(pixmap: pixmapty);
begin
 setlength(monopixmaps,length(monopixmaps)+1);
 monopixmaps[high(monopixmaps)]:= ptruint(pixmap);
end;

procedure removemonopixmap(pixmap: pixmapty);
var
 i: integer;
begin
 for i:= 0 to high(monopixmaps) do begin
  if monopixmaps[i] = ptruint(pixmap) then begin
   monopixmaps[i]:= monopixmaps[high(monopixmaps)];
   setlength(monopixmaps,high(monopixmaps));
   break;
  end;
 end;
end;

function ismonopixmap(pixmap: pixmapty): boolean;
var
 i: integer;
begin
 result:= false;
 for i:= 0 to high(monopixmaps) do begin
  if monopixmaps[i] = ptruint(pixmap) then begin
   result:= true;
   break;
  end;
 end;
end;

//
function waylandcreatepixmap(const size: sizety; const mono: boolean;
                                    const copyfrom: pixmapty): pixmapty;
var
 surf: psoftsurfacety;
begin
 result:= 0;
 surf:= createsoftsurface(size.cx,size.cy);
 if surf <> nil then begin
  result:= pixmapty(ptruint(surf));
  if mono then begin
   addmonopixmap(result);
  end;
  if copyfrom <> 0 then begin
   softcopy(surf,0,0,psoftsurfacety(ptruint(copyfrom)),
                       softrect(0,0,size.cx,size.cy),false);
  end;
 end;
end;

{$ifdef usesdl}
function gui_createpixmap(const size: sizety; winid: winidty = 0;
                          monochrome: boolean = false;
                          copyfrom: pixmapty = 0): pixmapty;
begin
 result:= waylandcreatepixmap(size,monochrome,copyfrom);
end;
{$else}
function gui_createpixmap(const size: sizety; winid: winidty = 0;
                          kind: bitmapkindty = bmk_rgb;
                          copyfrom: pixmapty = 0): pixmapty;
begin
 result:= waylandcreatepixmap(size,kind = bmk_mono,copyfrom); //gray = rgb
end;
{$endif}
//


function gui_freepixmap(pixmap: pixmapty): gdierrorty;
var
 surf: psoftsurfacety;
begin
 removemonopixmap(pixmap);
 surf:= psoftsurfacety(ptruint(pixmap));
 if surf <> nil then begin
  freesoftsurface(surf);
 end;
 result:= gde_ok;
end;

function gui_getpixmapinfo(var info: pixmapinfoty): gdierrorty;
var
 surf: psoftsurfacety;
begin
 with info do begin
  if (handle = 0) or not softvalid(psoftsurfacety(ptruint(handle))) then begin
   result:= gde_pixmap;
  end
  else begin
   surf:= psoftsurfacety(ptruint(handle));
   result:= gde_ok;
   size.cx:= surf^.width;
   size.cy:= surf^.height;
   if ismonopixmap(handle) then begin
    depth:= 1;        //like X11, so tsimplebitmap.sethandle keeps bmk_mono
   end
   else begin
    depth:= 32;
   end;
  end;
 end;
end;

function gui_allocimagemem(length: integer): plongwordaty;
begin
 if length = 0 then begin
  result:= nil;
 end
 else begin
  getmem(result,length * sizeof(longword));
 end;
end;

procedure gui_freeimagemem(data: plongwordaty);
begin
 freemem(data);
end;

function gui_pixmaptoimage(pixmap: pixmapty; out image: imagety;
                                       gchandle: longword): gdierrorty;
var
 sp: psoftsurfacety;
 x,y: integer;
 src: plongword;
 dst: plongwordaty;
begin
 sp:= psoftsurfacety(ptruint(pixmap));
 if (pixmap = 0) or not softvalid(sp) or (sp^.pixels = nil) or
                       (sp^.width <= 0) or (sp^.height <= 0) then begin
  result:= gde_pixmap;
  exit;
 end;
 if ismonopixmap(pixmap) then begin     //packed bits like the X11 backend
  allocimage(image,makesize(sp^.width,sp^.height),bmk_mono);
  fillchar(image.pixels^,image.length*sizeof(longword),0);
  for y:= 0 to sp^.height-1 do begin
   src:= plongword(ptruint(sp^.pixels) + ptruint(y*sp^.pitch));
   dst:= plongwordaty(ptruint(image.pixels) + ptruint(y*image.linebytes));
   for x:= 0 to sp^.width-1 do begin
    if (src^ and $00ffffff) <> 0 then begin
     dst^[x shr 5]:= dst^[x shr 5] or (longword(1) shl (x and 31));
    end;
    inc(src);
   end;
  end;
  result:= gde_ok;
  exit;
 end;
 image.kind:= bmk_rgb;
 image.bgr:= false;
 image.size.cx:= sp^.width;
 image.size.cy:= sp^.height;
 image.linelength:= sp^.width;             //longwords per row
 image.linebytes:= sp^.width*4;
 image.length:= sp^.width*sp^.height;      //longwords in total
 image.pixels:= gui_allocimagemem(image.length);
 for y:= 0 to sp^.height-1 do begin
  move(pointer(ptruint(sp^.pixels) + ptruint(y*sp^.pitch))^,
       pointer(ptruint(image.pixels) + ptruint(y*image.linebytes))^,
       image.linebytes);
 end;
 result:= gde_ok;
end;

function gui_imagetopixmap(const image: imagety; out pixmap: pixmapty;
                           gchandle: longword): gdierrorty;
var
 sp: psoftsurfacety;
 x,y,lb: integer;
 src: pbyte;
 srcl,dst: plongword;
 b: byte;
 bit: boolean;
 v: longword;
begin
 result:= gde_pixmap;
 pixmap:= 0;
 sp:= createsoftsurface(image.size.cx,image.size.cy);
 if sp = nil then begin
  exit;
 end;
 pixmap:= pixmapty(ptruint(sp));
 if image.kind = bmk_mono then begin
  addmonopixmap(pixmap);
 end;
 lb:= image.linebytes;
 for y:= 0 to image.size.cy-1 do begin
  src:= pbyte(ptruint(image.pixels) + ptruint(y*lb));
  dst:= plongword(ptruint(sp^.pixels) + ptruint(y*sp^.pitch));
  case image.kind of
   bmk_rgb: begin
    srcl:= plongword(src);
    for x:= 0 to image.size.cx-1 do begin
     v:= srcl^;
     if image.bgr then begin
      v:= (v and $ff00ff00) or ((v and $ff) shl 16) or ((v shr 16) and $ff);
     end;
     dst^:= v or $ff000000;
     inc(srcl);
     inc(dst);
    end;
   end;
   bmk_gray: begin
    for x:= 0 to image.size.cx-1 do begin
     b:= src^;
     dst^:= $ff000000 or (longword(b) shl 16) or (longword(b) shl 8) or b;
     inc(src);
     inc(dst);
    end;
   end;
   bmk_mono: begin
    for x:= 0 to image.size.cx-1 do begin
     b:= pbyte(ptruint(src) + ptruint(x shr 3))^;
     if monomsbfirst then begin
      bit:= ((b shr (7 - (x and 7))) and 1) <> 0;
     end
     else begin
      bit:= ((b shr (x and 7)) and 1) <> 0;
     end;
     if bit <> monoinvert then begin
      dst^:= $ffffffff;
     end
     else begin
      dst^:= $ff000000;
     end;
     inc(dst);
    end;
   end;
  end;
 end;
 result:= gde_ok;
end;

function gui_createbitmapfromdata(const size: sizety; datapo: pbyte;
             msbitfirst: boolean = false; dwordaligned: boolean = false;
             bottomup: boolean = false): pixmapty;
var
 sp: psoftsurfacety;
 x,y,bytesperline,srcy: integer;
 src: pbyte;
 dst: plongword;
 b: byte;
 bit: boolean;
begin
 result:= 0;
 sp:= createsoftsurface(size.cx,size.cy);
 if sp = nil then begin
  exit;
 end;
 result:= pixmapty(ptruint(sp));
 if dwordaligned then begin
  bytesperline:= ((size.cx + 31) div 32) * 4;
 end
 else begin
  bytesperline:= (size.cx + 7) div 8;
 end;
 for y:= 0 to size.cy-1 do begin
  if bottomup then begin
   srcy:= size.cy - 1 - y;
  end
  else begin
   srcy:= y;
  end;
  src:= pbyte(ptruint(datapo) + ptruint(srcy*bytesperline));
  dst:= plongword(ptruint(sp^.pixels) + ptruint(y*sp^.pitch));
  for x:= 0 to size.cx-1 do begin
   b:= pbyte(ptruint(src) + ptruint(x shr 3))^;
   if msbitfirst then begin
    bit:= ((b shr (7 - (x and 7))) and 1) <> 0;
   end
   else begin
    bit:= ((b shr (x and 7)) and 1) <> 0;
   end;
   if bit then begin
    dst^:= $ffffffff;
   end
   else begin
    dst^:= $ff000000;
   end;
   inc(dst);
  end;
 end;
 addmonopixmap(result);
end;

//windows

procedure forgetwindow(const win: twlwindow);
var
 i: integer;
begin
 if pointerwin = win then begin
  pointerwin:= nil;
 end;
 if lastpointerwin = win then begin
  lastpointerwin:= nil;
 end;
 if focuswin = win then begin
  focuswin:= nil;
 end;
 for i:= 0 to high(wins) do begin
  if wins[i] = win then begin
   wins[i]:= wins[high(wins)];
   setlength(wins,high(wins));
   break;
  end;
 end;
end;

type
 shapemaskty = array of byte;

const
 shapewindowoptions = [wo_rounded,wo_ellipse,wo_customshape,
                       wo_transparentbackground,wo_transparentbackgroundround];
 shapevisibledark = true;  //dark pixels of mse_shapebmp are the window, like
                           //on Windows. false = light pixels.

procedure fillshape(var mask: shapemaskty; const w,h: integer;
                         const r: rectty; const kind: integer);
                         //kind 0 = rectangle, 1 = rounded, 2 = ellipse
var
 x,y,x1,y1,x2,y2: integer;
 rad,dx,dy,px,py,hx,hy: double;
 inside: boolean;
begin
 x1:= r.x;
 if x1 < 0 then begin
  x1:= 0;
 end;
 y1:= r.y;
 if y1 < 0 then begin
  y1:= 0;
 end;
 x2:= r.x + r.cx;
 if x2 > w then begin
  x2:= w;
 end;
 y2:= r.y + r.cy;
 if y2 > h then begin
  y2:= h;
 end;
 rad:= mse_radiuscorner / 2;        //mse_radiuscorner = diameter of the corner
 if rad > r.cx / 2 then begin
  rad:= r.cx / 2;
 end;
 if rad > r.cy / 2 then begin
  rad:= r.cy / 2;
 end;
 for y:= y1 to y2-1 do begin
  py:= y - r.y + 0.5;
  for x:= x1 to x2-1 do begin
   px:= x - r.x + 0.5;
   inside:= true;
   case kind of
    1: begin
     dx:= 0;
     dy:= 0;
     if px < rad then begin
      dx:= rad - px;
     end
     else begin
      if px > r.cx - rad then begin
       dx:= px - (r.cx - rad);
      end;
     end;
     if py < rad then begin
      dy:= rad - py;
     end
     else begin
      if py > r.cy - rad then begin
       dy:= py - (r.cy - rad);
      end;
     end;
     if (dx > 0) and (dy > 0) then begin
      inside:= dx*dx + dy*dy <= rad*rad;
     end;
    end;
    2: begin
     hx:= r.cx / 2;
     hy:= r.cy / 2;
     dx:= (px - hx) / hx;
     dy:= (py - hy) / hy;
     inside:= dx*dx + dy*dy <= 1;
    end;
   end;
   if inside then begin
    mask[y*w + x]:= 1;
   end;
  end;
 end;
end;


procedure shapefromsurface(var shp: shapemaskty; const w,h: integer;
                      const apixmap: pixmapty; const ismask: boolean);
                      //reads the soft surface of the pixmap directly, like
                      //X11 which uses the mask pixmap as shape
var
 sp: psoftsurfacety;
 x,y,cx,cy: integer;
 po: plongword;
 c: longword;
 mono,vis: boolean;
begin
 sp:= psoftsurfacety(ptruint(apixmap));
 if (apixmap = 0) or not softvalid(sp) or (sp^.pixels = nil) then begin
  exit;
 end;
 mono:= ismonopixmap(apixmap);
 cx:= sp^.width;
 if cx > w then begin
  cx:= w;
 end;
 cy:= sp^.height;
 if cy > h then begin
  cy:= h;
 end;
 for y:= 0 to cy-1 do begin
  po:= plongword(ptruint(sp^.pixels) + ptruint(y*sp^.pitch));
  for x:= 0 to cx-1 do begin
   c:= po^ and $00ffffff;
   if ismask then begin
    if mono then begin
     vis:= c <> 0;                  //set bit = opaque
    end
    else begin
     vis:= (c and $ff) >= $80;      //gray mask
    end;
   end
   else begin
    vis:= (c <= $7f7f7f) = shapevisibledark;     //like Windows
   end;
   if vis then begin
    shp[y*w + x]:= 1;
   end;
   inc(po);
  end;
 end;
end;

procedure setwindowshape(const win: twlwindow; const aoptions: windowoptionsty;
                                                        const w,h: integer);
var
 shp: shapemaskty;
 i: integer;
begin
 shp:= nil;
 setlength(shp,w*h);
 fillchar(shp[0],w*h,0);
 if wo_ellipse in aoptions then begin
  fillshape(shp,w,h,makerect(0,0,w,h),2);
 end
 else begin
  if wo_transparentbackground in aoptions then begin
   if length(mse_formchild) = 0 then begin
    fillshape(shp,w,h,makerect(0,0,w,h),0);
   end
   else begin
    for i:= 0 to high(mse_formchild) do begin
     with mse_formchild[i] do begin
      fillshape(shp,w,h,makerect(left,top,width,height),0);
     end;
    end;
   end;
  end
  else begin
   if wo_customshape in aoptions then begin
    if mse_shapebmp = nil then begin
     fillshape(shp,w,h,makerect(0,0,w,h),0);
    end
    else begin
     if mse_shapebmp.masked then begin      //like X11: the mask is the shape
      shapefromsurface(shp,w,h,mse_shapebmp.mask.handle,true);
     end
     else begin                             //like Windows: dark pixels
      shapefromsurface(shp,w,h,mse_shapebmp.handle,false);
     end;
    end;
   end
   else begin
    if wo_transparentbackgroundround in aoptions then begin
     if length(mse_formchild) = 0 then begin
      fillshape(shp,w,h,makerect(0,0,w,h),1);
     end
     else begin
      for i:= 0 to high(mse_formchild) do begin
       with mse_formchild[i] do begin
        fillshape(shp,w,h,makerect(left,top,width,height),1);
       end;
      end;
     end;
    end
    else begin
     fillshape(shp,w,h,makerect(0,0,w,h),1);       //wo_rounded
    end;
   end;
  end;
 end;
 wlc_setshape(win,w,h,@shp[0]);
end;



function gui_createwindow(const rect: rectty;
                             var options: internalwindowoptionsty;
                             var awindow: windowty): guierrorty;
var
 win,parentwin: twlwindow;
 akind: twlwindowkind;
 w,h,i: integer;
 shaped: boolean;
begin
 fillchar(awindow,sizeof(awindow),0);
 result:= gue_createwindow;
 with awindow,options do begin
  w:= rect.cx;
  h:= rect.cy;
  if w <= 0 then begin
   w:= 1;
  end;
  if h <= 0 then begin
   h:= 1;
  end;
  parentwin:= findwin(transientfor);
  if wo_popup in options then begin
   if parentwin = nil then begin
    parentwin:= focuswin;
   end;
   if parentwin = nil then begin
    parentwin:= lastpointerwin;
   end;
   for i:= high(wins) downto 0 do begin    //xdg: the parent of a popup must
    if (wins[i].kind <> wlk_toplevel) and wins[i].visible and   //be the
                         (wins[i].popup <> nil) then begin   //topmost popup
     parentwin:= wins[i];
     break;
    end;
   end;
   if wo_tooltip in options then begin
    akind:= wlk_tooltip;
   end
   else begin
    akind:= wlk_popup;
   end;
   if parentwin = nil then begin
    akind:= wlk_toplevel;       //no parent: can not be a Wayland popup
   end;
  end
  else begin
   akind:= wlk_toplevel;
  end;
  if sdldebug then begin
   write('createwindow rect=',rect.x,',',rect.y,',',rect.cx,',',rect.cy,
        ' transientfor=',transientfor,' popup=',wo_popup in options,
        ' tooltip=',wo_tooltip in options,' kind=',ord(akind),' options=');
   for i:= 0 to sizeof(options) - 1 do begin
    write(hexstr(pbyte(@options)[i],2));
   end;
   if parentwin <> nil then begin
    write(' parent posx,posy=',parentwin.posx,',',parentwin.posy,
                                         ' parentkind=',ord(parentwin.kind));
   end;
   writeln;
   flush(system.output);
  end;
  if akind = wlk_toplevel then begin
   win:= wlc_createwindow(akind,parentwin,0,0,w,h);
  end
  else begin
   win:= wlc_createwindow(akind,parentwin,rect.x - parentwin.posx,
                                         rect.y - parentwin.posy,w,h);
  end;
  if win = nil then begin
   exit;
  end;
  win.posx:= rect.x;
  win.posy:= rect.y;
  win.sysdnd:= wo_sysdnd in options;
  shaped:= options * shapewindowoptions <> [];
  //like X11: only the no-frame window types remove the frame. A shape applies
  //to the client area, the title bar stays.
  wlc_setdecorated(win,(akind = wlk_toplevel) and
              (options * noframewindowtypes = []));
  if shaped then begin               //window shape, like the X11 and Windows
   setwindowshape(win,options,w,h);  //backends: set once with the creation size
  end;
  if pos = wp_maximized then begin
   win.maximized:= true;
  end
  else begin
   if (pos = wp_fullscreen) or (pos = wp_fullscreenvirt) then begin
    win.fullscreen:= true;
   end;
  end;
  setlength(wins,length(wins)+1);
  wins[high(wins)]:= win;
  id:= winid(win);
  result:= gue_ok;
 end;
end;


function gui_destroywindow(var awindow: windowty): guierrorty;
var
 win: twlwindow;
begin
 win:= findwin(awindow.id);
 if win <> nil then begin
  forgetwindow(win);
  wlc_destroywindow(win);
 end;
 result:= gue_ok;
end;

function gui_setwindowopacity(id: winidty; const opacity: real): guierrorty;
var
 win: twlwindow;
 int1: integer;
begin
 result:= gue_ok;
 win:= findwin(id);
 if win = nil then begin
  exit;
 end;
 if opacity >= 1 then begin
  int1:= 0;                         //opaque
 end
 else begin
  if opacity <= 0 then begin
   int1:= 256;                      //invisible
  end
  else begin
   int1:= round((1 - opacity) * 256);
  end;
 end;
 if int1 <> win.fade then begin
  win.fade:= int1;
  if win.visible then begin
   wlc_present(win);                //show the new opacity at once
  end;
 end;
end;

function gui_showwindow(id: winidty): guierrorty;
var
 win: twlwindow;
begin
 win:= findwin(id);
 result:= gue_ok;
 if (win <> nil) and not win.visible then begin
  if (win.kind <> wlk_toplevel) and (win.parent <> nil) then begin
   win.popupx:= win.posx - win.parent.posx;    //position set after creation
   win.popupy:= win.posy - win.parent.posy;
  end;
  wlc_show(win);
  if win.toplevel <> nil then begin
   if win.maximized then begin
    wlc_setmaximized(win,true);
   end;
   if win.fullscreen then begin
    wlc_setfullscreen(win,true);
   end;
  end;
  putevent(twindowevent.create(ek_show,id));
  putevent(twindowrectevent.create(ek_configure,id,winrect(win),nullpoint));
 end;
end;

function gui_hidewindow(id: winidty): guierrorty;
var
 win: twlwindow;
begin
 win:= findwin(id);
 result:= gue_ok;
 if (win <> nil) and win.visible then begin
  wlc_hide(win);
  if pointerwin = win then begin
   pointerwin:= nil;
  end;
  putevent(twindowevent.create(ek_hide,id));
 end;
end;

function gui_windowvisible(id: winidty): boolean;
var
 win: twlwindow;
begin
 win:= findwin(id);
 result:= (win <> nil) and win.visible;
end;

function gui_getwindowsize(id: winidty): windowsizety;
var
 win: twlwindow;
begin
 result:= wsi_normal;
 win:= findwin(id);
 if win <> nil then begin
  if win.minimized then begin
   result:= wsi_minimized;
  end
  else begin
   if win.fullscreen then begin
    result:= wsi_fullscreen;
   end
   else begin
    if win.maximized then begin
     result:= wsi_maximized;
    end;
   end;
  end;
 end;
end;

function gui_getwindowdesktop(const id: winidty): integer;
begin
 result:= 0;
end;

function gui_setwindowstate(id: winidty; size: windowsizety;
                                           visible: boolean): guierrorty;
var
 win: twlwindow;
begin
 result:= gue_ok;
 win:= findwin(id);
 if win = nil then begin
  exit;
 end;
 if visible then begin
  case size of
   wsi_minimized: begin
    win.minimized:= true;
    if not win.visible then begin
     gui_showwindow(id);
    end;
    wlc_setminimized(win);
   end;
   wsi_maximized: begin
    win.maximized:= true;
    win.minimized:= false;
    if not win.visible then begin
     gui_showwindow(id);
    end
    else begin
     wlc_setmaximized(win,true);
    end;
   end;
   wsi_fullscreen,wsi_fullscreenvirt: begin
    win.fullscreen:= true;
    win.minimized:= false;
    if not win.visible then begin
     gui_showwindow(id);
    end
    else begin
     wlc_setfullscreen(win,true);
    end;
   end;
   else begin
    if win.maximized then begin
     win.maximized:= false;
     wlc_setmaximized(win,false);
    end;
    if win.fullscreen then begin
     win.fullscreen:= false;
     wlc_setfullscreen(win,false);
    end;
    win.minimized:= false;
    if not win.visible then begin
     gui_showwindow(id);
    end;
   end;
  end;
 end
 else begin
  gui_hidewindow(id);
 end;
end;

function gui_setwindowcaption(id: winidty; const caption: msestring): guierrorty;
var
 win: twlwindow;
begin
 win:= findwin(id);
 if win <> nil then begin
  wlc_settitle(win,stringtoutf8ansi(caption));
 end;
 result:= gue_ok;
end;

function gui_getwindowrect(id: winidty; out rect: rectty): guierrorty;
var
 win: twlwindow;
begin
 fillchar(rect,sizeof(rect),0);
 win:= findwin(id);
 if win <> nil then begin
  rect:= winrect(win);
  result:= gue_ok;
 end
 else begin
  result:= gue_windownotfound;
 end;
end;

function gui_getwindowpos(id: winidty; out pos: pointty): guierrorty;
var
 win: twlwindow;
begin
 pos:= nullpoint;
 win:= findwin(id);
 if win <> nil then begin
  pos.x:= win.posx;
  pos.y:= win.posy;
  result:= gue_ok;
 end
 else begin
  result:= gue_windownotfound;
 end;
end;

procedure resizewindowshape(const win: twlwindow; const w,h: integer);
//keeps the shape corners, repeats the middle (like a nine-patch)
var
 shp: shapemaskty;
 ow,oh,hx,hy,x,y,sx,sy: integer;
begin
 ow:= win.shapew;
 oh:= win.shapeh;
 if (ow <= 0) or (oh <= 0) or (w <= 0) or (h <= 0) or
                                       ((ow = w) and (oh = h)) then begin
  exit;
 end;
 shp:= nil;
 setlength(shp,w*h);
 hx:= ow div 2;
 hy:= oh div 2;
 for y:= 0 to h-1 do begin
  if y < hy then begin
   sy:= y;
  end
  else begin
   if y >= h - (oh - hy) then begin
    sy:= y - (h - oh);
   end
   else begin
    sy:= hy;
   end;
  end;
  if sy < 0 then begin
   sy:= 0;
  end;
  if sy >= oh then begin
   sy:= oh - 1;
  end;
  for x:= 0 to w-1 do begin
   if x < hx then begin
    sx:= x;
   end
   else begin
    if x >= w - (ow - hx) then begin
     sx:= x - (w - ow);
    end
    else begin
     sx:= hx;
    end;
   end;
   if sx < 0 then begin
    sx:= 0;
   end;
   if sx >= ow then begin
    sx:= ow - 1;
   end;
   shp[y*w + x]:= win.shape[sy*ow + sx];
  end;
 end;
 if sdldebug then begin
  writeln('resizewindowshape ',ow,'x',oh,' -> ',w,'x',h);
  flush(system.output);
 end;
 wlc_setshape(win,w,h,@shp[0]);
end;

function gui_reposwindow(id: winidty; const rect: rectty): guierrorty;
var
 win: twlwindow;
 changed: boolean;
begin
 result:= gue_ok;
 win:= findwin(id);
 if (win = nil) or (rect.cx <= 0) or (rect.cy <= 0) then begin
  exit;
 end;
 if (win.kind = wlk_toplevel) and (win.width = rect.cx) and
        (win.height = rect.cy) and ((win.posx <> rect.x) or
                  (win.posy <> rect.y)) and (wlc_buttonsdown > 0) then begin
  wlc_startmove(win);       //application drags its frameless window
 end;
 changed:= false;
 if (win.posx <> rect.x) or (win.posy <> rect.y) then begin
  win.posx:= rect.x;
  win.posy:= rect.y;
  changed:= true;
 end;
 if (win.width <> rect.cx) or (win.height <> rect.cy) then begin
  wlc_setsize(win,rect.cx,rect.cy);
  if win.shapew > 0 then begin          //shaped window: the shape follows
   resizewindowshape(win,rect.cx,rect.cy);  //the new client size
  end;
  changed:= true;
 end;
 if changed then begin
  putevent(twindowrectevent.create(ek_configure,id,winrect(win),nullpoint));
  putevent(twindowrectevent.create(ek_expose,id,
                           makerect(0,0,win.width,win.height),nullpoint));
 end;
end;

function gui_getdecoratedwindowrect(id: winidty; out arect: rectty): guierrorty;
begin
 result:= gui_getwindowrect(id,arect);
end;

function gui_setdecoratedwindowrect(id: winidty; const rect: rectty;
                                    out clientrect: rectty): guierrorty;
var
 win: twlwindow;
begin
 win:= findwin(id);
 if win <> nil then begin
  if (win.kind = wlk_toplevel) and ((win.posx <> rect.x) or
                  (win.posy <> rect.y)) and (wlc_buttonsdown > 0) then begin
   wlc_startmove(win);
  end;
  win.posx:= rect.x;
  win.posy:= rect.y;
 end;
 result:= gui_getwindowrect(id,clientrect);
end;

function gui_setembeddedwindowrect(id: winidty; const rect: rectty): guierrorty;
var
 win: twlwindow;
begin
 win:= findwin(id);
 if win <> nil then begin
  win.posx:= rect.x;
  win.posy:= rect.y;
 end;
 result:= gue_ok;
end;

//init

function gui_init: guierrorty;
begin
 SetExceptionMask([exInvalidOp,exDenormalized,exZeroDivide,exOverflow,
                                                     exUnderflow,exPrecision]);
 sdldebug:= getenvironmentvariable('MSEWLDEBUG') <> '';
 guisoftbackend:= true;     //behaviour of the soft backends
 flushgdi:= true;
 result:= gue_error;
 if fppipe(wakepipe) <> 0 then begin
  exit;
 end;
 fpfcntl(wakepipe[0],F_SETFL,fpfcntl(wakepipe[0],F_GETFL) or O_NONBLOCK);
 fpfcntl(wakepipe[1],F_SETFL,fpfcntl(wakepipe[1],F_GETFL) or O_NONBLOCK);
 if not wlc_connect then begin
  if sdldebug then begin
   writeln('Wayland: can not connect to the compositor');
   flush(output);
  end;
  exit;
 end;
 gui_setmainthread;
 terminated:= false;
 sigtermbefore:= fpsignal(SIGTERM,@sigterminate);
 childevent:= false;
 sigchldbefore:= fpsignal(SIGCHLD,@sigchild);
 wlc_titlerenderer:= @rendertitle;
 wlc_debug:= sdldebug;
 result:= gue_ok;
end;

function gui_deinit: guierrorty;
var
 i: integer;
begin
 timerdue:= 0;
 fpsignal(SIGTERM,sigtermbefore);
 fpsignal(SIGCHLD,sigchldbefore);
 wlc_disconnect;
 softfreeall;                              //pixmaps not freed by the gui
 for i:= evhead to high(evlist) do begin   //events never processed
  evlist[i].free;                          //(e.g. ek_hide posted at shutdown)
  evlist[i]:= nil;
 end;
 setlength(evlist,0);
 evhead:= 0;
 setlength(wins,0);
 fpclose(wakepipe[0]);
 fpclose(wakepipe[1]);
 wakepipe[0]:= -1;
 wakepipe[1]:= -1;
 mainthread:= 0;
 result:= gue_ok;
end;

function gui_getgdifuncs: pgdifunctionaty;
begin
 result:= waylandgetgdifuncs;
end;

function gui_registergdi: guierrorty;
begin
 registergdi(waylandgetgdifuncs);
 result:= gue_ok;
end;

procedure freependingevents;
var
 i: integer;
begin
 for i:= evhead to high(evlist) do begin   //events never processed
  evlist[i].free;                          //(e.g. ek_hide posted at shutdown)
  evlist[i]:= nil;
 end;
 setlength(evlist,0);
 evhead:= 0;
 if lockvalid then begin
  entercriticalsection(usrlock);
  try
   for i:= 0 to high(usrq) do begin        //posted from other threads or
    usrq[i].free;                          //by settimer, never taken
    pointer(usrq[i]):= nil;
   end;
   setlength(usrq,0);
  finally
   leavecriticalsection(usrlock);
  end;
 end;
end;

initialization
 wakepipe[0]:= -1;
 wakepipe[1]:= -1;
 initcriticalsection(usrlock);
 lockvalid:= true;
finalization
 freependingevents;
 lockvalid:= false;
 donecriticalsection(usrlock);
end.