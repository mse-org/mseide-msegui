{ MSEgui Copyright (c) 1999-2010 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseguiintf; //i386-win32

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 windows,messages,mseapplication,msetypes,msegraphutils,
 mseevent,msepointer,mseguiglob,msegraphics,
 msethread,mseformatstr,msesysintf,msestrings,msesys;

type
 syseventty = record
  hwnd: hwnd;
  umsg: uint;
  wparam: wparam;
  lparam: lparam;
  lresult: lresult;
 end;
  
const
// pixel0 = $000000;
// pixel1 = $ffffff;
 pixel0 = $ffffff;   //select colorbackground
 pixel1 = $000000;   //select colorforeground

 msemessage = wm_user + $3694;
 wakeupmessage = msemessage + 1;
 destroymessage = msemessage + 2;
 traycallbackmessage = msemessage + 3;
 timermessage = msemessage + 4;

{$ifdef FPC}
{$include ../mseguiintf.inc}
{$else}
{$include mseguiintf.inc}
{$endif}

function getapplicationwindow: hwnd;

{$ifdef mse_debuggdi}
var
 pixmapcount: integer;
 fontcount: integer;
 windowcount: integer;
 regioncount: integer;
 gccount: integer;
{$endif}

implementation
//todo: 19.10.03 rasterops for textout
uses
 sysutils,mselist,msekeyboard,msebits,msedatalist,msesysutils,msegui,
 msesystimer;

type

 trayinfoty = record
 end; 
 win32windowdty = record
  trayinfo: trayinfoty;
 end;
 win32windowty = record
  case integer of
   0: (d: win32windowdty;);
   1: (_bufferspace: windowpty;);
 end;

 wndextrainfoty = record
  flags: longword;
  stylebackup: longword;
//  l,t,r,b: integer;
 end;
{$ifndef FPC}
 winbool = bool;
{$endif}

const
 MAPVK_VK_TO_VSC = 0;
 flagsoffs =       0*sizeof(integer); //for setwindowlong
 stylebackupoffs = 1*sizeof(integer);
// loffs =           2*sizeof(integer);
// toffs =           3*sizeof(integer);
// roffs =           4*sizeof(integer);
// boffs =           5*sizeof(integer);
 
 widgetclassname = 'msetoplevelwidget';
 childwidgetclassname = 'msechildwidget';
 wndextrabytes = sizeof(wndextrainfoty);
  
 mouseidletime = 100; //milliseconds
 capstyles: array[capstylety] of longword =
       (ps_endcap_flat,ps_endcap_round,ps_endcap_square);
 joinstyles: array[joinstylety] of longword =
       (ps_join_miter,ps_join_round,ps_join_bevel);

 highresfontshift = 6;  //64
 highresfontfakt = 1 shl highresfontshift;
 highresfontmask = highresfontfakt - 1; 
 {
  cursorshapety = (cr_default,cr_none,cr_arrow,cr_cross,cr_wait,cr_ibeam,
             cr_sizever,cr_sizehor,cr_sizebdiag,cr_sizefdiag,cr_sizeall,
             cr_splitv,cr_splith,cr_pointinghand,cr_forbidden,
             cr_topleftcorner,cr_bottomleftcorner,
             cr_bottomrightcorner,cr_toprightcorner,
             cr_res0,cr_res1,cr_res2,cr_res3,cr_res4,cr_res5,cr_res6,cr_res7,
             cr_user);
  }
 {$ifdef FPC}
  IDC_ARROW = pchar(32512);
  IDC_IBEAM = pchar(32513);
  IDC_WAIT = pchar(32514);
  IDC_CROSS = pchar(32515);
  IDC_UPARROW = pchar(32516);
  IDC_SIZE = pchar(32640);
  IDC_ICON = pchar(32641);
  IDC_SIZENWSE = pchar(32642);
  IDC_SIZENESW = pchar(32643);
  IDC_SIZEWE = pchar(32644);
  IDC_SIZENS = pchar(32645);
  IDC_SIZEALL = pchar(32646);
  IDC_NO = pchar(32648);
  IDC_HAND = pchar(32649);
  IDC_APPSTARTING = pchar(32650);
  IDC_HELP = pchar(32651);

  VK_LWIN = 91;
  VK_RWIN = 92;
 {$endif}

  VK_OEM_PLUS = $BB;    // '+' any country
  VK_OEM_COMMA = $BC;   // ',' any country
  VK_OEM_MINUS = $BD;   // '-' any country
  VK_OEM_PERIOD = $BE;  // '.' any coun {$endif}

 standardcursors: array[cursorshapety] of pchar{makeintresource} =
                     (idc_arrow,idc_arrow,idc_arrow,idc_arrow,
                     idc_cross,idc_wait,idc_ibeam,
                     idc_sizens,idc_sizewe,idc_sizenesw,idc_sizenwse,idc_sizeall,
                     idc_arrow,idc_arrow,idc_hand,idc_no,
                     idc_arrow, //cr_drag
                     idc_sizenwse,idc_sizenesw,
                     idc_sizenwse,idc_sizenesw,
                     idc_arrow,idc_arrow,idc_arrow,idc_arrow,
                     idc_arrow,idc_arrow,idc_arrow,idc_arrow,
                     idc_arrow);
{                                       //        |not dest and source
 rasteropty = (  rop_clear,   rop_and,    rop_andnot, rop_copy,
          //          |not source and dest
                 rop_notand,  rop_nop,    rop_xor,    rop_or,
                 rop_nor,     rop_notxor, rop_not,    rop_ornot,
                 rop_notcopy, rop_notor,  rop_nand,   rop_set);

  source   1 1 0 0
  dest     1 0 1 0
  result   x x x x     code = result + 1
  copy     1 1 0 0 + 1 = 13
  and      1 0 0 0 + 1 = 9
  }

 rasterops2: array[rasteropty] of byte =
               ($01,$09,$05,$0d,
                $03,$0b,$07,$0f,
                $02,$0a,$06,$0e,
                $04,$0c,$08,$10);

 inverserops2: array[rasteropty] of byte =//for 1->foreground in monochromebitmaps
                ($00,$04,$08,$0c,
                 $01,$05,$09,$0d,
                 $02,$06,$0a,$0e,
                 $03,$07,$0b,$0f);

 firstrasterops2: array[rasteropty] of byte = //backgroudcolor = $ffffff,
               ($09,$09,$09,$09,              //textcolor = $000000, and
                $09,$09,$09,$09,
                $09,$09,$09,$09,
                $09,$09,$09,$09);

 secondrasterops2: array[rasteropty] of byte = //colorbackground = $000000,
               ($0f,$0f,$0f,$0f,               //textcolor = $ffffff, or
                $0f,$0f,$0f,$0f,
                $0f,$0f,$0f,$0f,
                $0f,$0f,$0f,$0f);

 rasterops3: array[rasteropty] of longword =
               ($000042,$8800c6,$440328,$cc0020,
                $220326,$aa0029,$660046,$ee0086,
                $1100a6,$990066,$550009,$dd0228,
                $330008,$bb0226,$7700e6,$ff0062);

 patrops3: array[rasteropty] of longword =
               ($000042,$a000c9,$500325,$f00021,
                $0a0329,$aa0029,$5a0049,$fa0089,
                $0500a9,$a50065,$550009,$f50225,
                $0f0001,$af0229,$5f00e2,$ff0062);

 col0: tagrgbquad = (rgbblue: $ff; rgbgreen: $ff; rgbred: $ff; rgbreserved: $00);
 col1: tagrgbquad = (rgbblue: 0; rgbgreen: 0; rgbred: 0; rgbreserved: $00);
// col0: tagrgbquad = (rgbblue: 0; rgbgreen: 0; rgbred: 0);
// col1: tagrgbquad = (rgbblue: $ff; rgbgreen: $ff; rgbred: $ff);

 defaultfontname = 'Tahoma';
// defaultfontname = 'MS Sans Serif';
 defaultfontnames: defaultfontnamesty =
  //stf_default           stf_empty stf_unicode stf_menu stf_message stf_report
   (defaultfontname,          '',       '',         '',      '',      'Arial',
  //stf_proportional stf_fixed,
   defaultfontname,         'Courier',
  //stf_helvetica stf_roman          stf_courier
    'Arial',     'Times New Roman', 'Courier New');

 MONITOR_DEFAULTTONULL = 0;
 MONITOR_DEFAULTTOPRIMARY = 1;
 MONITOR_DEFAULTTONEAREST = 2;
 SM_XVIRTUALSCREEN = 76;
 SM_YVIRTUALSCREEN = 77;
 SM_CXVIRTUALSCREEN = 78;
 SM_CYVIRTUALSCREEN = 79;
 
type
 hmonitor = thandle;
 tMONITORINFO = record
  cbSize: DWORD ;
  rcMonitor: tRECT  ;
  rcWork: tRECT;
  dwFlags: DWORD;
 end;
 pmonitorinfo = ^tmonitorinfo;
 
{$ifdef FPC}
type
  TKeyboardState = array[0..255] of Byte;
  tTEXTMETRICW = record
    tmHeight: Longint;
    tmAscent: Longint;
    tmDescent: Longint;
    tmInternalLeading: Longint;
    tmExternalLeading: Longint;
    tmAveCharWidth: Longint;
    tmMaxCharWidth: Longint;
    tmWeight: Longint;
    tmOverhang: Longint;
    tmDigitizedAspectX: Longint;
    tmDigitizedAspectY: Longint;
    tmFirstChar: WideChar;
    tmLastChar: WideChar;
    tmDefaultChar: WideChar;
    tmBreakChar: WideChar;
    tmItalic: Byte;
    tmUnderlined: Byte;
    tmStruckOut: Byte;
    tmPitchAndFamily: Byte;
    tmCharSet: Byte;
  end;
  tTEXTMETRICA = record
    tmHeight: Longint;
    tmAscent: Longint;
    tmDescent: Longint;
    tmInternalLeading: Longint;
    tmExternalLeading: Longint;
    tmAveCharWidth: Longint;
    tmMaxCharWidth: Longint;
    tmWeight: Longint;
    tmOverhang: Longint;
    tmDigitizedAspectX: Longint;
    tmDigitizedAspectY: Longint;
    tmFirstChar: Char;
    tmLastChar: Char;
    tmDefaultChar: Char;
    tmBreakChar: Char;
    tmItalic: Byte;
    tmUnderlined: Byte;
    tmStruckOut: Byte;
    tmPitchAndFamily: Byte;
    tmCharSet: Byte;
  end;
  tGCPRESULTSW = record
       lStructSize : DWORD;
       lpOutString : pwidechar;
       lpOrder : ^UINT;
       lpDx : ^WINT;
       lpCaretPos : ^WINT;
       lpClass : pwidechar;
       lpGlyphs : ^UINT;
       nGlyphs : UINT;
       nMaxFit : UINT;
    end;
{$else}
function GetCharacterPlacementW(DC: HDC; p2: PWideChar; p3, p4: Integer;
  var p5: TGCPResultsw; p6: DWORD): DWORD; stdcall;
    external gdi32 name 'GetCharacterPlacementW';

{$endif}

var
 canshutdown: integer;
 widgetclass: atom;
 childwidgetclass: atom;
 applicationwindow: winidty;
 desktopwindow: hwnd;
 eventlist: tobjectqueue;
 nullpen: hpen;
 nullbrush: hbrush;
// timer: longword;
 mouseidletimer: longword;
 mainthread: longword;
 mousewindow: hwnd;
 lastfocuswindow: hwnd;
 groupleaderwindow: hwnd;
 mousecursor: hcursor;
 keystate: tkeyboardstate;
 charbuffer: msestring;
 shiftstate: shiftstatesty;

 cursors: array[cursorshapety] of longword;

type
 tapplication1 = class(tguiapplication);
 tsimplebitmap1 = class(tsimplebitmap);
 tcanvas1 = class(tcanvas);
 gcflagty = (gcf_backgroundbrushvalid,
             gcf_colorbrushvalid,gcf_patternbrushvalid,gcf_rasterop,
             gcf_selectforegroundbrush,gcf_selectbackgroundbrush,
             gcf_foregroundpenvalid,
             gcf_selectforegroundpen,gcf_selectnullpen,gcf_selectnullbrush,
             gcf_ispatternpen,gcf_isopaquedashpen,
                          gcf_last = 31);
            //-> longword
 gcflagsty = set of gcflagty;
 win32gcdty = record
  flags: gcflagsty;
  backgroundcol,foregroundcol: longword;
  backgroundbrush: hbrush;
  colorbrush: hbrush;
  patternbrush: hbrush;
  foregroundpen: hpen;
  kind: gckindty;
  bru: pixmapty;
  rop: rasteropty;
  brushorg: pointty;
  peninfo: lineinfoty;
  gccliporigin: pointty;
  selectedpen: hpen;
  selectedbrush: hbrush;
  secondpen: hpen;
 end;
 {$if sizeof(win32gcdty) > sizeof(gcpty)} {$error 'buffer overflow'}{$ifend}
 win32gcty = record
  case integer of
   0: (d: win32gcdty;);
   1: (_bufferspace: gcpty;);
 end;

 charwidthsty = array[0..255] of integer;
 pcharwidthsty = ^charwidthsty;
 win32fontdataty = record
  charwidths: pcharwidthsty;
  overhang: integer;
  xwidth: integer;
  local: array[3..15] of longword; //plattform dependent
 end;
 monochromebitmapinfoty = packed record
  bmiheader: tbitmapinfoheader;
  bmicolors: array[0..1] of trgbquad;
 end;

 shapety = (fs_copyarea,fs_rect,fs_ellipse,fs_arc,fs_polygon);

 bitmapinfoty = packed record
  bmiheader: bitmapinfoheader;
  col0: longword;
  col1: longword;
 end;
 
{$ifdef FPC}
function GetNextWindow(hWnd: HWND; uCmd: UINT): HWND; stdcall;
             external user32 name 'GetWindow';
function CreateRectRgnIndirect(const _para1:tRECT):HRGN; stdcall;
             external gdi32 name 'CreateRectRgnIndirect';
function winFillRect(hDC:HDC; const lprc:tRECT; hbr:HBRUSH):longint; stdcall;
             external user32 name 'FillRect';
function winScrollWindowEx(hWnd: HWND; dx, dy: Integer;
             prcScroll, prcClip: PRect;
             hrgnUpdate: HRGN; prcUpdate: PRect; flags: UINT): BOOL; stdcall;
             external user32 name 'ScrollWindowEx';

function PeekMessage(var lpMsg: TMsg; hWnd: HWND;
  wMsgFilterMin, wMsgFilterMax, wRemoveMsg: UINT): BOOL; stdcall;
             external user32 name 'PeekMessageA';
function TranslateMessage(const lpMsg: TMsg): BOOL; stdcall;
             external user32 name 'TranslateMessage';
function DispatchMessage(const lpMsg: TMsg): Longint; stdcall;
             external user32 name 'DispatchMessageA';
{$endif}

function GetMonitorInfo(hmomitor: hmonitor; lpmu: pmonitorinfo): BOOL; stdcall;
             external user32 name 'GetMonitorInfoA';
function MonitorFromWindow(hwnd: HWND; dwFlags: DWORD): HMONITOR; stdcall;
             external user32 name 'MonitorFromWindow';

type
{$ifndef FPC}
 POINT = tpoint;
 RECT = trect;
 {$endif}
 HIMC = DWORD;
 tagCOMPOSITIONFORM = record
  dwStyle: DWORD;
  ptCurrentPos: POINT;
  rcArea: RECT;
 end;
 COMPOSITIONFORM = tagCOMPOSITIONFORM;
 PCOMPOSITIONFORM = ^COMPOSITIONFORM;
 NPCOMPOSITIONFORM = ^COMPOSITIONFORM;
 LPCOMPOSITIONFORM = ^COMPOSITIONFORM;

const
// bit field for IMC_SETCOMPOSITIONWINDOW, IMC_SETCANDIDATEWINDOW
      CFS_DEFAULT                     = $0000;
      CFS_RECT                        = $0001;
      CFS_POINT                       = $0002;
      CFS_FORCE_POSITION              = $0020;
      CFS_CANDIDATEPOS                = $0040;
      CFS_EXCLUDE                     = $0080;
      
var
 hasimm32: boolean;
 ImmGetContext: function(_hwnd: HWND): HIMC; stdcall;
 ImmReleaseContext: function(_hwnd: HWND; _himc: HIMC): BOOL; stdcall;
 ImmSetCompositionWindow: function(_himc: HIMC; 
                          lpCompForm: LPCOMPOSITIONFORM): BOOL; stdcall;
             
function getapplicationwindow: hwnd;
begin
 result:= applicationwindow;
end;

{$ifndef FPC}
type
      _NOTIFYICONDATAA = record
          cbSize: DWORD;
          Wnd: HWND;
          uID: UINT;
          uFlags: UINT;
          uCallbackMessage: UINT;
          hIcon: HICON;
          szTip: array [0..63] of Char;
     end;
     _NOTIFYICONDATA = _NOTIFYICONDATAA;

     _NOTIFYICONDATAW = record
         cbSize: DWORD;
         Wnd: HWND;
         uID: UINT;
         uFlags: UINT;
         uCallbackMessage: UINT;
         hIcon: HICON;
         szTip: array [0..63] of Word;
     end;
     TNotifyIconDataA = _NOTIFYICONDATAA;
     TNotifyIconDataW = _NOTIFYICONDATAW;
     TNotifyIconData = TNotifyIconDataA;
     NOTIFYICONDATAA = _NOTIFYICONDATAA;
     NOTIFYICONDATAW = _NOTIFYICONDATAW;
     NOTIFYICONDATA = NOTIFYICONDATAA;
     PNotifyIconDataA = ^TNotifyIconDataA;
     PNotifyIconDataW = ^TNotifyIconDataW;
     PNotifyIconData = PNotifyIconDataA;
     
function Shell_NotifyIconA(dwMessage: DWORD; lpData: PNotifyIconDataA): BOOL;
                 external 'shell32.dll' name 'Shell_NotifyIconA';
function Shell_NotifyIconW(dwMessage: DWORD; lpData: PNotifyIconDataW): BOOL;
                 external 'shell32.dll' name 'Shell_NotifyIconW';
{$endif}
{
var
 Shell_NotifyIconA: function (dwMessage: DWORD; lpData: PNotifyIconDataA): BOOL;
 Shell_NotifyIconW: function (dwMessage: DWORD; lpData: PNotifyIconDataW): BOOL;
 
 shellinterfaceerror: guierrorty = gue_noshelllib;
 shellinterfacechecked: boolean;
 
function checkshellinterface: guierrorty;
var
 bo1: boolean;
begin
 if (shellinterfaceerror <> gue_ok) and not shellinterfacechecked then begin
  shellinterfacechecked:= true;
  if iswin95 then begin
   bo1:= checkprocaddresses(['shell32.dll'],
    ['Shell_NotifyIconA'
    ],
    [@Shell_NotifyIconA
    ]);
  end
  else begin
   bo1:= checkprocaddresses(['shell32.dll'],
    ['Shell_NotifyIconW'
    ],
    [@Shell_NotifyIconW
    ]);
  end;
  if bo1 then begin
   shellinterfaceerror:= gue_ok;
  end;
 end;
 result:= shellinterfaceerror;
end;
}
function checkshellinterface: guierrorty;
begin
 result:= gue_ok;
end;
function mrect(aleft,atop,aright,abottom: integer): trect;
begin
 with result do begin
  left:= aleft;
  top:= atop;
  right:= aright;
  bottom:= abottom;
 end;
end;

function gui_sethighrestimer(const avalue: boolean): guierrorty;
begin
 if setmmtimer(avalue) then begin
  result:= gue_ok;
 end
 else begin
  result:= gue_timer;
 end;
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
var
 int1: integer;
 po1: prgndata;
 po2: prect;
begin
 result:= nil;
 if aregion <> 0 then begin
  int1:= getregiondata(aregion,0,nil);
  getmem(po1,int1);
  if getregiondata(aregion,int1,po1) <> 0 then begin
   setlength(result,po1^.rdh.ncount);
   po2:= @po1^.buffer;
   for int1:= 0 to high(result) do begin
    with result[int1],po2^ do begin
     x:= left;
     y:= top;
     cx:= right - left;
     cy:= bottom - top;
    end;
    inc(po2);
   end;
  end;
  freemem(po1);
 end;
end;

function gui_getdefaultfontnames: defaultfontnamesty;
begin
 result:= defaultfontnames;
end;

function gui_canstackunder: boolean;
begin
 result:= true;
end;

procedure gui_cancelshutdown;
begin
 if canshutdown <> 0 then begin
  tapplication1(application).exitloop;
 end;
 canshutdown:= 0;
end;

function gui_copytoclipboard(const value: msestring): guierrorty;
         //todo: copy msechars to clipboard, win95?
var
 mem: thandle;
 po1: pchar;
 po2: pwidechar;
 str1: string;
begin
 result:= gue_clipboard;
 if openclipboard(0) then begin
  if emptyclipboard then begin
   if iswin95 then begin
    str1:= value;
    mem:= globalalloc(GMEM_MOVEABLE or GMEM_DDESHARE,length(str1)+1); //nullterminator
    if mem <> 0 then begin
     po1:= globallock(mem);
     if po1 <> nil then begin
      move(pchar(str1)^,po1^,length(str1)+1);
      globalunlock(mem);
      if setclipboarddata(cf_text,longword(mem)) <> 0 then begin
       result:= gue_ok;
      end;
     end
     else begin
      globalfree(mem);
     end;
    end;
   end
   else begin
    mem:= globalalloc(GMEM_MOVEABLE or GMEM_DDESHARE,(length(value)+1)*2);
                                                     //nullterminator
    if mem <> 0 then begin
     po2:= globallock(mem);
     if po2 <> nil then begin
      move(pwidechar(value)^,po2^,(length(value)+1)*2);
      globalunlock(mem);
      if setclipboarddata(cf_unicodetext,longword(mem)) <> 0 then begin
       result:= gue_ok;
      end;
     end
     else begin
      globalfree(mem);
     end;
    end;
   end;
  end;
  closeclipboard;
 end;
end;

function gui_canpastefromclipboard: boolean;
begin
 result:= isclipboardformatavailable(cf_text);
end;

function gui_pastefromclipboard(out value: msestring): guierrorty;
var               //todo: get msechars from clipboard, win95?
 data: thandle;
 po1: pointer;
 str1: string;
begin
 value:= '';
 result:= gue_clipboard;
 if openclipboard(0) then begin
  if iswin95 then begin
   data:= getclipboarddata(cf_text);
  end
  else begin
   data:= getclipboarddata(cf_unicodetext);
  end;
  closeclipboard;
  if data <> 0 then begin
   po1:= globallock(data);
   if po1 <> nil then begin
    if iswin95 then begin
     setlength(str1,globalsize(data));
     if length(str1) > 0 then begin
      move(po1^,str1[1],length(str1));
      result:= gue_ok;
      setlength(str1,length(pchar(str1)));
     end;
     value:= str1;
    end
    else begin
     setlength(value,globalsize(data) div 2);
     if length(value) > 0 then begin
      move(po1^,value[1],length(value)*2);
      result:= gue_ok;
      setlength(value,length(pwidechar(value)));
      if (value <> '') and (value[length(value)] = #$0d) then begin
       setlength(value,length(value)-1);
      end;
     end;
    end;
    globalunlock(data);
   end;
  end;
 end;
end;

function gui_getwindowsize(id: winidty): windowsizety;
var
 placement: twindowplacement;
begin
 if getwindowlong(id,flagsoffs) <> 0 then begin
  result:= wsi_fullscreen;
 end
 else begin
  result:= wsi_normal;
  placement.length:= sizeof(placement);
  if getwindowplacement(id,{$ifndef FPC}@{$endif}placement) then begin
   case placement.showcmd of
    sw_showmaximized: result:= wsi_maximized;
    sw_showminimized: result:= wsi_minimized;
   end;
  end;
 end;
end;

function gui_windowvisible(id: winidty): boolean;
begin
 result:= iswindowvisible(id);
end;

function gui_setwindowstate(id: winidty; size: windowsizety; visible: boolean): guierrorty;
var
 int1: integer;
 wo1: longword;
// placement: twindowplacement;
begin
 result:= gue_ok;
 int1:= getwindowlong(id,flagsoffs);
 if size = wsi_fullscreen then begin
  if int1 = 0 then begin
   wo1:= getwindowlong(id,gwl_style);
   setwindowlong(id,stylebackupoffs,wo1);
   setwindowlong(id,flagsoffs,1);
   wo1:= wo1 and not 
    (ws_border or ws_dlgframe or ws_overlapped or ws_thickframe) or (ws_popup);
   setwindowlong(id,gwl_style,wo1);
   setwindowpos(id,0,0,0,getsystemmetrics(sm_cxscreen),
                      getsystemmetrics(sm_cyscreen),
                      swp_framechanged {or swp_nomove or swp_nosize} 
                      or swp_nozorder or swp_noownerzorder or swp_noactivate);
  end;
  if visible then begin
   showwindow(id,sw_shownoactivate);
  end;
 end
 else begin
  if int1 <> 0 then begin
   wo1:= getwindowlong(id,stylebackupoffs);
   setwindowlong(id,gwl_style,getwindowlong(id,stylebackupoffs));
   setwindowpos(id,0,0,0,0,0,
           swp_framechanged or swp_nomove or swp_nosize or swp_nozorder or
           swp_noownerzorder or swp_noactivate);
   setwindowlong(id,flagsoffs,0);
  end;   
  case size of
   wsi_maximized: begin
    int1:= sw_maximize;
   end;
   wsi_minimized: begin
    int1:= sw_minimize;
   end;
   else begin
    int1:= sw_shownoactivate;
   end;
  end;
  if visible or (size = wsi_minimized) then begin
   showwindow(id,int1);
  end;
 end;
end;

function gui_getpointerpos: pointty;
begin
 windows.getcursorpos(tpoint(result));
end;

function gui_setpointerpos(const pos: pointty): guierrorty;
begin
 if windows.SetCursorPos(pos.x,pos.y) then begin
  result:= gue_ok;
 end
 else begin
  result:= gue_mousepos;
 end;
end;

function gui_movepointer(const dist: pointty): guierrorty;
var
 po1: tpoint;
begin
 result:= gue_mousepos;
 if windows.getcursorpos(po1) then begin
  if windows.setcursorpos(po1.x+dist.x,po1.y+dist.y) then begin
   result:= gue_ok;
  end;
 end;
end;

function gui_grabpointer(id: winidty): guierrorty;
begin
 setcapture(id);
 if getcapture = id then begin
  result:= gue_ok;
 end
 else begin
  result:= gue_capturemouse;
 end;
end;

function gui_ungrabpointer: guierrorty;
begin
 releasecapture;
 result:= gue_ok;
end;

function gui_createpixmap(const size: sizety; winid: winidty = 0;
                          monochrome: boolean = false;
                          copyfrom: pixmapty = 0): pixmapty;
             //copyfrom does not work if selected in dc!
var
 dc,dc1: hdc;

begin
 if monochrome then begin
  result:= createbitmap(size.cx,size.cy,1,1,nil);
 end
 else begin
  dc:= getdc(winid);
  result:= createcompatiblebitmap(dc,size.cx,size.cy);
  releasedc(winid,dc);
 end;
{$ifdef mse_debuggdi}
 if result <> 0 then begin
  inc(pixmapcount);
 end;
{$endif}
 if (result <> 0) and (copyfrom <> 0) then begin
  dc:= createcompatibledc(0);
  dc1:= createcompatibledc(0);
  selectobject(dc,result);
  selectobject(dc1,copyfrom);
  bitblt(dc,0,0,size.cx,size.cy,dc1,0,0,srccopy);
  deletedc(dc);
  deletedc(dc1);
 {
  dc:= getdc(winid);
  fillchar(bitmapinfo,sizeof(bitmapinfo),0);
  bitmapinfo.bmiHeader.bisize:= sizeof(bitmapinfo.bmiheader);
  if getdibits(dc,copyfrom,0,size.cy,nil,
        windows.bitmapinfo(pointer(@bitmapinfo)^),dib_rgb_colors) <> 0 then begin
   with bitmapinfo.bmiHeader do begin
    if bisizeimage = 0 then begin
     if monochrome then begin
      bisizeimage:= ((size.cx+31) div 32) * 4 * size.cy;
     end
     else begin
      bisizeimage:= size.cx*size.cy*4;
     end;
    end;
    po1:= pointer(localalloc(LMEM_FIXED,bisizeimage));
    getdibits(dc,copyfrom,0,size.cy,po1,
        windows.bitmapinfo(pointer(@bitmapinfo)^),dib_rgb_colors);
    setdibits(dc,result,0,size.cy,po1,
          windows.bitmapinfo(pointer(@bitmapinfo)^),dib_rgb_colors);
    localfree(longword(po1));
   end;
  end;
  releasedc(winid,dc);
  }
 end;
end;

procedure initbitmapinfo(monochrome: boolean; bottomup: boolean; const size: sizety;
         out bitmapinfo: monochromebitmapinfoty);
begin
 fillchar(bitmapinfo,sizeof(bitmapinfo),0);
 with bitmapinfo.bmiHeader do begin
  bisize:= sizeof(tbitmapinfoheader);
  biwidth:= size.cx;
  if bottomup then begin
   biheight:= size.cy;
  end
  else begin
   biheight:= -size.cy;
  end;
  biplanes:= 1;
  if monochrome then begin
   bibitcount:= 1;
   bitmapinfo.bmicolors[0]:= col0;
   bitmapinfo.bmicolors[1]:= col1;
//   bitmapinfo.bmicolors[0]:= col0;
//   bitmapinfo.bmicolors[1]:= col1;
  end
  else begin
   bibitcount:= 32;
  end;
 end;
end;

function gui_createbitmapfromdata(const size: sizety; datapo: pbyte;
             msbitfirst: boolean = false; dwordaligned: boolean = false;
             bottomup: boolean = false): pixmapty;
var
 po1,po2: pbyte;
 bytesperline: integer;
 int1,int2,int3: integer;
 bitmapinfo: monochromebitmapinfoty;
 dc: hdc;

begin
 {$ifdef FPC}{$checkpointer off}{$endif}
 bytesperline:= ((size.cx+31) div 32)*4;
 int3:= bytesperline*size.cy; //total bytecount
 po1:= pointer(localalloc(LMEM_FIXED,int3));
 fillchar(po1^,int3,0);
 if dwordaligned then begin
  move(datapo^,po1^,int3);
 end
 else begin
  int2:= (size.cx+7) div 8; //source bytesperline
  po2:= po1;
  for int1:= 0 to size.cy - 1 do begin
   move(datapo^,po2^,int2);
   inc(po2,bytesperline);
   inc(datapo,int2);
  end;
 end;
 if not msbitfirst then begin
  po2:= po1;
  for int1:= 0 to int3-1 do begin
   po2^:= bitreverse[po2^];
   inc(po2);
  end;
 end;
{setdibits reverses image?!?!}
{
 int1:= int3 div 4 -1;      //delphi: without this lines bits will be inverted
 po3:= pointer(po1);        //by setdibits!?!?!
 for int1:= 0 to int1 do begin
  po3^:= not po3^;          //1-> background
  inc(po3);
 end;
}
 initbitmapinfo(true,bottomup,size,bitmapinfo);
 result:= createbitmap(size.cx,size.cy,1,1,nil);
 dc:= getdc(0);
 setdibits(dc,result,0,size.cy,po1,windows.bitmapinfo(pointer(@bitmapinfo)^),dib_rgb_colors);
 releasedc(0,dc);
 localfree(longword(po1));
 {$ifdef FPC}{$checkpointer default}{$endif}
end;

function gui_freepixmap(pixmap: pixmapty): gdierrorty;
begin
 if not deleteobject(pixmap) then begin
  result:= gde_freepixmap;
 end
 else begin
{$ifdef mse_debuggdi}
  dec(pixmapcount);
{$endif}
  result:= gde_ok;
 end;
end;

function gui_getpixmapinfo(var info: pixmapinfoty): gdierrorty;
var
 bmp: bitmap;
begin
 with info do begin
  if getobject(handle,sizeof(bmp),@bmp) = 0 then begin
   result:= gde_pixmap;
  end
  else begin
   result:= gde_ok;
   size.cx:= bmp.bmwidth;
   size.cy:= bmp.bmheight;
   depth:= bmp.bmbitspixel;
  end;
 end;
end;

procedure transformimageformat(const image: imagety; inverse: boolean = true);
var
 po1: pbyte;
 int1: integer;
begin
 {$ifdef FPC}{$checkpointer off}{$endif}
 if image.monochrome then begin
  po1:= pointer(image.pixels);
  if inverse then begin
   for int1:= 0 to image.length*4-1 do begin
    po1^:= not bitreverse[po1^];
    inc(po1);
   end;
  end
  else begin
   for int1:= 0 to image.length*4-1 do begin
    po1^:= bitreverse[po1^];
    inc(po1);
   end;
  end;
 end;
 {$ifdef FPC}{$checkpointer default}{$endif}
 {
 else begin
  for int1:= 0 to high(image.pixels) do begin
   swaprgb1(image.pixels[int1]);
  end;
 end;
 }
end;

var 
 imagememalloc: integer;
 
function gui_allocimagemem(length: integer): plongwordaty;
begin
 if length = 0 then begin
  result:= nil;
 end
 else begin
  inc(imagememalloc);
  result:= pointer(localalloc(LMEM_FIXED,length*sizeof(longword)));
         //getdibits, setdeibits do not work with normal heap
  if result = nil then begin
   raise exception.Create('Out of memory.');
  end;
 end;
end;

procedure gui_freeimagemem(data: plongwordaty);
begin
 dec(imagememalloc);
 localfree(longword(data));
end;

function gui_pixmaptoimage(pixmap: pixmapty; out image: imagety; gchandle: longword): gdierrorty;
var
 info: pixmapinfoty;
 bitmapinfo: monochromebitmapinfoty;
 dc: hdc;
 int1: integer;
 bmp1: hbitmap;

begin
 if gchandle <> 0 then begin
  bmp1:= createcompatiblebitmap(gchandle,0,0);
  selectobject(gchandle,bmp1);
 end
 else begin
  bmp1:= 0; //compiler warning
 end;
 info.handle:= pixmap;
 result:= gui_getpixmapinfo(info);
 if result = gde_ok then begin
  image.size:= info.size;
  result:= gde_image;
  image.pixels:= nil;
  if info.depth = 1 then begin
   image.length:= ((info.size.cx + 31) div 32) * info.size.cy;
   initbitmapinfo(true,false,info.size,bitmapinfo);
   image.monochrome:= true;
  end
  else begin
   image.monochrome:= false;
   initbitmapinfo(false,false,info.size,bitmapinfo);
   image.length:= info.size.cx * info.size.cy;
  end;
  image.pixels:= gui_allocimagemem(image.length);
         //getdibits does not work with normal heap
  dc:= getdc(0);
  int1:= getdibits(dc,pixmap,0,info.size.cy,image.pixels,
                 pbitmapinfo(@bitmapinfo)^,dib_rgb_colors);
  releasedc(0,dc);
  if int1 <> 0 then begin
   transformimageformat(image);
   result:= gde_ok;
  end;
 end;
 if gchandle <> 0 then begin
  selectobject(gchandle,pixmap);
  deleteobject(bmp1);
 end;
end;

function gui_imagetopixmap(const image: imagety; out pixmap: pixmapty;
                           gchandle: longword): gdierrorty;
var
 int1: integer;
 bitmapinfo: monochromebitmapinfoty;
 dc: hdc;
 bmp1: hbitmap;
begin
 bmp1:= 0; //compiler warning
 result:= gde_pixmap;
 if gchandle <> 0 then begin
  bmp1:= createcompatiblebitmap(gchandle,0,0);
  selectobject(gchandle,bmp1);
 end;
 pixmap:= gui_createpixmap(image.size,0,image.monochrome);
 if pixmap <> 0 then begin
  transformimageformat(image,false); //setdibits reverses image!?!?!
  initbitmapinfo(image.monochrome,false,image.size,bitmapinfo);
  dc:= getdc(0);
  int1:= setdibits(dc,pixmap,0,image.size.cy,image.pixels,
              tbitmapinfo(pbitmapinfo(@bitmapinfo)^),dib_rgb_colors);
  releasedc(0,dc);
  if int1 <> 0 then begin
   result:= gde_ok;
  end;
 end;
 if gchandle <> 0 then begin
  selectobject(gchandle,pixmap);
  deleteobject(bmp1);
 end;
end;

function gui_setwindowfocus(id: winidty): guierrorty;
begin
// setforegroundwindow(applicationwindow);
 setforegroundwindow(id);
 setfocus(id);
 result:= gue_ok;
end;

function gui_setappfocus(id: winidty): guierrorty;
var
 selfthread,otherthread: integer;
begin
 result:= gue_error;
 selfthread:= getcurrentthreadid;
 otherthread:= getwindowthreadprocessid(id,nil);
 if otherthread <> 0 then begin
  if attachthreadinput(selfthread,otherthread,true) then begin
   if windows.setfocus(id) <> 0 then begin
    result:= gue_ok;
   end;
   attachthreadinput(selfthread,otherthread,false)
  end;
 end;
end;

function gui_minimizeapplication: guierrorty;
begin
 result:= gue_ok;
 if iswindowvisible(applicationwindow) then begin
  showwindow(applicationwindow,sw_minimize);
 end;
end;

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

function gui_setcursorshape(winid: winidty; shape: cursorshapety): guierrorty;
var
 cursor: hcursor;
begin
 case shape of
  cr_none: begin
   cursor:= 0;
  end;
  cr_drag: begin
   if cursors[cr_drag] = 0 then begin
    cursors[cr_drag]:= createcursor(hinstance,0,0,curwidth,curheight,
                          @curdragand,@curdragxor);
   end;
   cursor:= cursors[cr_drag];
  end;
  else begin
   cursor:= windows.LoadCursor(0,standardcursors[shape]);
  end;
 end;
 windows.SetCursor(cursor);
 mousecursor:= cursor;
 result:= gue_ok;
end;
{
procedure killtimer;
begin
 if timer <> 0 then begin
  windows.killtimer(0,timer);
  timer:= 0;
 end;
end;

procedure TimerProc(hwnd: hwnd; uMsg: longword; idEvent: longword;
          dwTime: longword); stdcall;
begin
 killtimer;
 eventlist.add(tmseevent.create(ek_timer));
end;

function gui_settimer(us: longword): guierrorty;
               //send et_timer event after delay or us (micro seconds)
begin
 killtimer;
 timer:= windows.settimer(0,0,us div 1000,@timerproc);
 if timer = 0 then begin
  result:= gue_timer;
 end
 else begin
  result:= gue_ok;
 end;
end;
}
function gui_settimer(us: longword): guierrorty;
               //send et_timer event after delay or us (micro seconds)
begin
 setsystimer(us);
end;

procedure gui_beep;
begin
 windows.MessageBeep($ffffffff);
end;

procedure winrecttorect(const rect: rectty); overload;
begin
 dec(pinteger(@rect.cx)^,rect.x);
 dec(pinteger(@rect.cy)^,rect.y);
end;

procedure winrecttorect(po: prectty; count: integer); overload;
begin
 while count > 0 do begin
  dec(po^.cx,po^.x);
  dec(po^.cy,po^.y);
  inc(po);
  dec(count);
 end;
end;

procedure recttowinrect(const rect: rectty); overload;
begin
 inc(pinteger(@rect.cx)^,rect.x);
 inc(pinteger(@rect.cy)^,rect.y);
end;

procedure recttowinrect(po: prectty; count: integer); overload;
begin
 while count > 0 do begin
  inc(po^.cx,po^.x);
  inc(po^.cy,po^.y);
  inc(po);
  dec(count);
 end;
end;

function gui_creategc(paintdevice: paintdevicety; const akind: gckindty; 
              var gc: gcty; const aprintername: msestring = ''): guierrorty;
var
 wrect1: trect;
begin
 gc.gdifuncs:= gui_getgdifuncs;
 case akind of
  gck_pixmap: begin
   result:= gue_creategc;
   gc.handle:= createcompatibledc(0);
   if gc.handle <> 0 then begin
    selectobject(gc.handle,paintdevice);
    win32gcty(gc.platformdata).d.kind:= akind;
   end;
  end;
  gck_printer: begin
   result:= gue_createprintergc;
   gc.handle:= createdc('WINSPOOL',pansichar(ansistring(aprintername)),nil,nil);
   setmapperflags(gc.handle,1); //match font-device aspectratio
  end;
  gck_metafile: begin
   result:= gue_createmetafilegc;
   wrect1.left:= 0;
   wrect1.top:= 0;
   wrect1.right:= round((gc.paintdevicesize.cx*100)/gc.ppmm);
   wrect1.bottom:= round((gc.paintdevicesize.cy*100)/gc.ppmm);
   if aprintername = '' then begin
    gc.handle:= createenhmetafilew(gc.refgc,nil,@wrect1,nil); //memory
   end
   else begin
    gc.handle:= createenhmetafilew(gc.refgc,pmsechar(aprintername),@wrect1,nil); 
                                                   //file
   end;
   setmapperflags(gc.handle,1); //match font-device aspectratio
  end;
  else begin
   result:= gue_creategc;
   gc.handle:= getdc(paintdevice);
  end;
 end;
 if gc.handle <> 0 then begin
{$ifdef mse_debuggdi}
  inc(gccount);
{$endif}
  win32gcty(gc.platformdata).d.kind:= akind;
  settextalign(gc.handle,ta_left or ta_baseline or ta_noupdatecp);
  setbkmode(gc.handle,transparent);
  setmapmode(gc.handle,mm_text);
  result:= gue_ok;
 end;
end;

procedure gdi_destroygc(var drawinfo: drawinfoty);
begin
 with drawinfo,gc,win32gcty(platformdata).d do begin
  selectobject(handle,nullpen);
  selectobject(handle,nullbrush);
{$ifdef mse_debuggdi}
  dec(gccount);
{$endif}
  if handle <> 0 then begin
   case kind of
    gck_pixmap,gck_printer: begin
 //   bmp1:= createcompatiblebitmap(handle,0,0);
 //   bmp2:= selectobject(handle,bmp1); //select actual bitmap out of dc
                                      //really needed?
    deletedc(handle);
 //   deleteobject(bmp1);
    end;
    gck_metafile: begin
     deleteenhmetafile(closeenhmetafile(handle));
    end
    else begin
     releasedc(paintdevice,handle);
    end;
   end;
  end;
  if backgroundbrush <> 0 then begin
   deleteobject(backgroundbrush);
   backgroundbrush:= 0;
  end;
  if colorbrush <> 0 then begin
   deleteobject(colorbrush);
   colorbrush:= 0;
  end;
  if patternbrush <> 0 then begin
   deleteobject(patternbrush);
   patternbrush:= 0;
  end;
  if foregroundpen <> 0 then begin
   deleteobject(foregroundpen);
   foregroundpen:= 0;
  end;
  selectedpen:= 0;
  selectedbrush:= 0;
 end;
end;

var
 defaultfontinfo: logfont;
type
 charsetinfoty = record
  name: string;
  code: integer;
 end;
 charsetinfoaty = array[0..18] of charsetinfoty;

const
 charsets: charsetinfoaty = (
  (name: 'ANSI'; code: 0),
  (name: 'DEFAULT'; code: 1),
  (name: 'SYMBOL'; code: 2),
  (name: 'SHIFTJIS'; code: $80),
  (name: 'HANGEUL'; code: 129),
  (name: 'GB2312'; code: 134),
  (name: 'CHINESEBIG5'; code: 136),
  (name: 'OEM'; code: 255),
  (name: 'JOHAB'; code: 130),
  (name: 'HEBREW'; code: 177),
  (name: 'ARABIC'; code: 178),
  (name: 'GREEK'; code: 161),
  (name: 'TURKISH'; code: 162),
  (name: 'VIETNAMESE'; code: 163),
  (name: 'THAI'; code: 222),
  (name: 'EASTEUROPE'; code: 238),
  (name: 'RUSSIAN'; code: 204),
  (name: 'MAC'; code: 77),
  (name: 'BALTIC'; code: 186));
  
type
 pboolean = ^boolean;
{$ifdef FPC}
function fontenumcallback(var _para1:ENUMLOGFONTEX;
       var _para2:NEWTEXTMETRICEX; _para3:longint; _para4:LPARAM):longint; stdcall;
{$else}
function fontenumcallback(var _para1:ENUMLOGFONTEX;
       var _para2:TNEWTEXTMETRICEXa; _para3:longint; _para4:LPARAM):longint; stdcall;
{$endif}
begin
 pboolean(_para4)^:= true;
 result:= 0;
end;

procedure initdefaultfont;
var
 dc1: hdc;
 bo1: boolean;
begin
 fillchar(defaultfontinfo,sizeof(defaultfontinfo),0);
 defaultfontinfo.lfHeight:= -11;
 bo1:= false;
 defaultfontinfo.lfFaceName:= defaultfontname;
 dc1:= getdc(0);
 {$ifdef FPC}
 enumfontfamiliesex(dc1,@defaultfontinfo,@fontenumcallback,ptruint(@bo1),0);
 {$else}
 enumfontfamiliesex(dc1,defaultfontinfo,@fontenumcallback,ptruint(@bo1),0);
 {$endif}
 if not bo1 then begin
  defaultfontinfo.lfFaceName:= 'MS Sans Serif';
 end;
 releasedc(0,dc1);
end;

function dogetfont(var drawinfo: drawinfoty; const ahighres: boolean): boolean;

var
 dc1: hdc;  //printer gc is invalid -> create temporary gc
 fontbefore: hfont;
 font1: hfont;

 procedure closedc;
 begin
  selectobject(dc1,fontbefore);
  releasedc(0,dc1);
  with drawinfo.getfont.fontdata^ do begin
   if (font1 <> font) and (font1 <> fonthighres) then begin
    deleteobject(font1);
   end;
  end;
 end;
  
var
 fontinfo1: logfont;
// textmetricsw: ttextmetricw;
 textmetricsa: ttextmetrica;
 str1: string;
 int1: integer;
 ar1: array[0..255] of abc;
 height1,width1: integer;
 rea1: real;

label
 endlab;
  
begin
 result:= false;
 with drawinfo.getfont.fontdata^ do begin
  height1:= (height + fontsizeroundvalue) shr fontsizeshift;
  width1:= (width + fontsizeroundvalue) shr fontsizeshift;
  fontinfo1:= defaultfontinfo;
  with fontinfo1 do begin
   if height1 <> 0 then begin
    lfheight:= -height1; //use character height
   end;
   if xscale = 1 then begin
    if width1 <> 0 then begin
     lfwidth:= (width1 + 5) div 10;
     if lfwidth = 0 then begin
      lfwidth:= 1;
     end;
     lfoutprecision:= out_tt_only_precis;
    end;
   end;
   if fs_bold in style then begin
    lfweight:= fw_bold;
   end;
   if fs_italic in style then begin
    lfitalic:= 1;
   end;
   if (pitchoptions <> []) or (familyoptions <> []) then begin
    lffacename[0]:= #0;
   end
   else begin
    if (name <> '') then begin
     strlcopy(@lffacename,pchar(name),sizeof(lffacename)-1);
    end;
   end;
   if charset <> '' then begin
    str1:= uppercase(charset);
    for int1:= 0 to high(charsets) do begin
     if charsets[int1].name = str1 then begin
      lfcharset:= charsets[int1].code;
      break;
     end;
    end;
   end;
   if foo_fixed in pitchoptions then begin
    lfpitchandfamily:= lfpitchandfamily or fixed_pitch;
   end
   else begin
    if foo_proportional in pitchoptions then begin
     lfpitchandfamily:= lfpitchandfamily or variable_pitch;
    end
   end;
   if foo_helvetica in familyoptions then begin
    lfpitchandfamily:= lfpitchandfamily or ff_swiss;
   end
   else begin
    if foo_roman in familyoptions then begin
     lfpitchandfamily:= lfpitchandfamily or ff_roman;
    end
    else begin
     if foo_script in familyoptions then begin
      lfpitchandfamily:= lfpitchandfamily or ff_script;
     end
     else begin
      if foo_decorative in familyoptions then begin
       lfpitchandfamily:= lfpitchandfamily or ff_decorative;
      end
     end;
    end;
   end;
   if foo_antialiased in antialiasedoptions then begin
    lfquality:= antialiased_quality;
   end
   else begin
    if foo_nonantialiased in antialiasedoptions then begin
     lfquality:= nonantialiased_quality;
    end;
   end;
   if rotation <> 0 then begin
    int1:= round(rotation*((10*360)/(2*pi)));
    lfescapement:= int1;
    lforientation:= int1;
    lfoutprecision:= out_tt_only_precis;
   end;
   if ahighres then begin
    lfheight:= lfheight * highresfontfakt;
    lfwidth:= lfwidth * highresfontfakt;
   end;
   
   font1:= createfontindirect({$ifdef FPC}@{$endif}fontinfo1);
  end;
  if font1 = 0 then begin
   fontinfo1.lfFaceName:= defaultfontinfo.lfFaceName;
   font1:= createfontindirect({$ifdef FPC}@{$endif}fontinfo1);
   if font1 = 0 then begin
    if ahighres then begin
     exit; //no highres font available
    end;
    font1:= createfontindirect({$ifdef FPC}@{$endif}defaultfontinfo);
   end;
  end;
  if font1 <> 0 then begin
   dc1:= getdc(0);
   fontbefore:= selectobject(dc1,font1);
   if not gettextmetricsa(dc1,{$ifdef FPC}@{$endif}textmetricsa) then begin
    goto endlab;
   end;
   if xscale <> 1 then begin
    closedc;
    int1:= width;
    rea1:= xscale;
    with win32fontdataty(platformdata) do begin
     if ahighres then begin
      fontinfo1.lfwidth:= ((xwidth+5) div 10) shl highresfontshift;
      //round up
      fonthighres:= createfontindirect({$ifdef FPC}@{$endif}fontinfo1);
      result:= fonthighres <> 0;
     end
     else begin
      xwidth:= round(xscale * textmetricsa.tmavecharwidth*10);
      width:= xwidth shl fontsizeshift; 
      xscale:= 1.0;
      result:= dogetfont(drawinfo,false);
     end;
    end;
    width:= int1;  //restore
    xscale:= rea1; 
    exit;
   end;
   with win32fontdataty(platformdata) do begin
    if ahighres then begin
     fonthighres:= font1;
     goto endlab;
    end;
    font:= font1;
    ascent:= textmetricsa.tmAscent;
    descent:= textmetricsa.tmDescent;
    linespacing:= textmetricsa.tmheight + textmetricsa.tmexternalleading;
    overhang:= textmetricsa.tmOverhang;
    if textmetricsa.tmpitchandfamily and tmpf_truetype <> 0 then begin
     caretshift:= 0;
    end
    else begin
     caretshift:= 1;
    end;
    if iswin95 then begin
     new(charwidths);
     if false {getcharabcwidths(dc1,0,255,ar1)} then begin
      for int1:= 0 to high(ar1) do begin
       with ar1[int1] do begin
        charwidths^[int1]:= abca + integer(abcb) + abcc;
       end;
      end;
     end
     else begin      //no truetype font
      if not getcharwidthw(dc1,0,255,charwidths^) then begin
       dispose(charwidths);
       goto endlab;
      end;
      if Overhang <> 0 then begin
       for int1:= 0 to high(charwidths^) do begin
        dec(charwidths^[int1],Overhang);
       end;
      end;
     end;
    end
    else begin
    {
     new(charwidths);
     if not getcharwidth32w(dc1,0,255,charwidths^) then begin
      dispose(charwidths);
      closedc;
      exit;
     end;
    }
    end;
   end;
   result:= true;
  end;
 end;
endlab:
{$ifdef mse_debuggdi}
 if result then begin
  inc(fontcount);
 end;
{$endif}
 closedc; 
end;

procedure gdi_getfonthighres(var drawinfo: drawinfoty);
begin
 dogetfont(drawinfo,true);
end;

procedure gdi_getfont(var drawinfo: drawinfoty);
begin
 drawinfo.getfont.ok:= dogetfont(drawinfo,false);
end;

procedure gdi_freefontdata(var drawinfo: drawinfoty);
begin
 with drawinfo.getfont.fontdata^,win32fontdataty(platformdata) do begin
  if charwidths <> nil then begin
   dispose(charwidths);
  end;
  if font <> 0 then begin
{$ifdef mse_debuggdi}
   dec(fontcount);
{$endif}
   deleteobject(font);
  end;
  if fonthighres <> 0 then begin
{$ifdef mse_debuggdi}
   dec(fontcount);
{$endif}
   deleteobject(fonthighres);
  end;
 end;
end;

procedure gdi_gettext16width(var drawinfo: drawinfoty);
label                     //todo: kerning?
 endlab;
var
 int1,int2: integer;
 po1: pmsechar;
 wo1: word;
 widths: pcharwidthsty;
 overha: integer;
 fh1: hfont;
 gc1: hdc;
 gcpresults: tgcpresultsw;
begin
 with drawinfo.gettext16width do begin
  if drawinfo.gc.handle = invalidgchandle then begin
   gc1:= getdc(0);  //use default dc
  end
  else begin
   gc1:= drawinfo.gc.handle;
  end;
  fh1:= selectobject(gc1,fontdata^.font);
  if fh1 <> 0 then begin
   if not iswin95 then begin
    fillchar(gcpresults,sizeof(gcpresults),0);
    gcpresults.lstructsize:= sizeof(gcpresults);
    gcpresults.nglyphs:= count;
    {$ifdef FPC}
    result:= getcharacterplacementw(gc1,text,count,0,@gcpresults,0) and $ffff;
    {$else}
    result:= getcharacterplacementw(gc1,text,count,0,gcpresults,0) and $ffff;
    {$endif}
   end
   else begin
    result:= 0;
    int1:= count;
    po1:= text;
    with win32fontdataty(fontdata^.platformdata) do begin
     widths:= charwidths;
     overha:= overhang;
    end;
    while int1 > 0 do begin
     wo1:= word(po1^);
     if wo1 < 256 then begin
      inc(result,widths^[wo1]);
     end
     else begin
      int2:= 0;
      if iswin95 then begin
       if not getcharwidthw(gc1,wo1,wo1,int2) then begin
        result:= -1;
        goto endlab;
       end;
       dec(int2,overha);
      end
      else begin
       if not getcharwidth32w(gc1,wo1,wo1,int2) then begin
        result:= -1;
        goto endlab;
       end;
      end;
      inc(result,int2);
     end;
     dec(int1);
     inc(po1);
    end;
   end;
  end
  else begin
   result:= -1;
  end;
endlab:
  if fh1 <> 0 then begin
   selectobject(gc1,fh1);
  end; 
  if drawinfo.gc.handle = invalidgchandle then begin
   releasedc(0,gc1);
  end;
 end;
end;

procedure gdi_getchar16widths(var drawinfo: drawinfoty);
label                        //todo: kerning?
 endlab;
var
 int1,int2: integer;
 po1: pmsechar;
 po2: {$ifdef FPC}objpas.{$endif}pinteger;
 wo1: word;
 widths: pcharwidthsty;
 overha: integer;
 ahandle: thandle;
 gc1: hdc;
 gcpresults: tgcpresultsw;
 fo1: hfont;
 hires: boolean;
begin
// result:= gde_fontmetrics;
 with drawinfo.getchar16widths do begin
  hires:= (df_highresfont in drawinfo.gc.drawingflags) and 
                          (fontdata^.fonthighres <> 0);
  if (drawinfo.gc.handle = invalidgchandle) or hires then begin
   gc1:= getdc(0);  //use default dc
  end
  else begin
   gc1:= drawinfo.gc.handle;
  end;
  if hires then begin
   ahandle:= selectobject(gc1,fontdata^.fonthighres);
  end
  else begin
   ahandle:= selectobject(gc1,fontdata^.font);
  end;
  if ahandle <> 0 then begin
   if not iswin95 then begin
    fillchar(gcpresults,sizeof(gcpresults),0);
    gcpresults.lstructsize:= sizeof(gcpresults);
    gcpresults.lpdx:= pointer(resultpo);
    gcpresults.nglyphs:= count;
    {$ifdef FPC}
    getcharacterplacementw(gc1,text,count,0,@gcpresults,0);
    {$else}
    getcharacterplacementw(gc1,text,count,0,gcpresults,0);
    {$endif}
    if hires then begin
     po2:= resultpo;
     int2:= highresfontfakt div 2; //round up
     for int1:= 0 to count - 1 do begin
      int2:= int2 + po2^;
      po2^:= int2 shr highresfontshift;
      int2:= int2 and highresfontmask;
      inc(po2);
     end;
    end;
   end
   else begin
    po1:= text;
    po2:= resultpo;
    with win32fontdataty(fontdata^.platformdata) do begin
     widths:= charwidths;
     overha:= overhang;
    end;
    int1:= count;
    while int1 > 0 do begin
     wo1:= word(po1^);
     if wo1 < 256 then begin
      po2^:= widths^[wo1];
     end
     else begin
      if iswin95 then begin
       if not getcharwidthw(gc1,wo1,wo1,po2^) then begin
        goto endlab;
       end;
       dec(po2^,overha);
      end
      else begin
       if not getcharwidth32w(gc1,wo1,wo1,po2^) then begin
        goto endlab;
       end;
      end;
     end;
     inc(po1);
     inc(po2);
     dec(int1);
    end;
   end;
//   selectobject(gc1,ahandle);
//   result:= gde_ok;
  end;
 end;

endlab:
 if ahandle <> 0 then begin
  selectobject(gc1,ahandle);
 end;
 if (drawinfo.gc.handle = invalidgchandle) or hires then begin
  releasedc(0,gc1);
 end;
end;

procedure gdi_getfontmetrics(var drawinfo: drawinfoty);
var
 data: abc;
 bo1: boolean;
 ahandle: thandle;

begin
// result:= gde_fontmetrics;
 with drawinfo,drawinfo.getfontmetrics do begin
  ahandle:= selectobject(gc.handle,fontdata^.font);
  if ahandle <> 0 then begin
   fillchar(data,sizeof(data),0);
   if iswin95 then begin
    bo1:= getcharabcwidthsw(gc.handle,longword(char),longword(char),data);
   {
    if ord(char) < 256 then begin
     bo1:= getcharabcwidthsa(gc.handle,longword(char),longword(char),data);
    end
    else begin
     bo1:= false;
    end;
    }
   end
   else begin
    bo1:= getcharabcwidthsw(gc.handle,longword(char),longword(char),data);
   end;
   if not bo1 then begin
    if iswin95 then begin
     bo1:= getcharwidthw(drawinfo.gc.handle,longword(char),longword(char),data.abcb);
     dec(data.abcB,win32fontdataty(fontdata^.platformdata).overhang);
    end
    else begin
     bo1:= getcharwidth32w(drawinfo.gc.handle,longword(char),longword(char),data.abcb);
    end;
    data.abca:= 0;
    data.abcC:= 0;
   end;
   if bo1 then begin
    with resultpo^ do begin
     leftbearing:= data.abca;
     width:= data.abca + integer(data.abcb) + data.abcc;
     rightbearing:= data.abcc;
    end;
    selectobject(gc.handle,ahandle);
//    result:= gde_ok;
   end;
  end;
 end;
end;

function gui_flushgdi(const synchronize: boolean = false): guierrorty;
begin
 gui_hasevent; //dispachevents
 gdiflush;
 result:= gue_ok;
end;

procedure windowdestroyed(id: winidty);
begin
 if mousewindow = id then begin
  mousewindow:= 0;
 end;
 if lastfocuswindow = id then begin
  lastfocuswindow:= 0;
 end;
 if groupleaderwindow = id then begin
  groupleaderwindow:= 0;
 end;
end;

function gui_destroywindow(var awindow: windowty): guierrorty;
var
 ico1: hicon;
begin
 with awindow do begin
  if id <> 0 then begin
   ico1:= sendmessage(id,wm_seticon,icon_big,0);
   if ico1 <> 0 then begin
    destroyicon(ico1);
   end;
   if windows.DestroyWindow(id) then begin
{$ifdef mse_debuggdi}
    dec(windowcount);
{$endif}
    result:= gue_ok;
   end
   else begin //foreign thread
    if windows.postthreadmessage(mainthread,destroymessage,id,0) then begin
     result:= gue_ok;
    end
    else begin
     result:= gue_destroywindow;
    end;
   end;
   windowdestroyed(id);
  end;
 end;
end;

function gui_showwindow(id: winidty): guierrorty;
begin
 windows.showwindow(id,sw_shownoactivate);
 result:= gue_ok;
end;

function gui_hidewindow(id: winidty): guierrorty;
begin
 windows.showwindow(id,sw_hide);
 result:= gue_ok;
end;

function gui_raisewindow(id: winidty): guierrorty;
begin
 windows.SetWindowPos(id,hwnd_top,0,0,0,0,swp_noactivate or swp_nomove or
                          swp_noownerzorder or swp_nosize);
 result:= gue_ok;
end;

function gui_lowerwindow(id: winidty): guierrorty;
begin
 windows.SetWindowPos(id,hwnd_bottom,0,0,0,0,swp_noactivate or swp_nomove or
                          swp_noownerzorder or swp_nosize);
 result:= gue_ok;
end;

function gui_stackunderwindow(id: winidty; predecessor: winidty): guierrorty;
begin
 if id <> predecessor then begin
  windows.SetWindowPos(id,predecessor,0,0,0,0,swp_noactivate or swp_nomove or
                          swp_noownerzorder or swp_nosize);
 end;
 result:= gue_ok;
end;

function gui_stackoverwindow(id: winidty; predecessor: winidty): guierrorty;
var
 id1: winidty;
begin
 if id <> predecessor then begin
  id1:= windows.GetWindow(predecessor,gw_hwndprev);
  if id1 = 0 then begin
   id1:= hwnd_top;
  end;
  windows.SetWindowPos(id,id1,0,0,0,0,swp_noactivate or swp_nomove or
                           swp_noownerzorder or swp_nosize);
 end;
 result:= gue_ok;
end;

function gui_getzorder(const ids: winidarty; out zorders: integerarty): guierrorty;
    //topevel -> highest, numbers must not be contiguous
var
 int1,foundcount: integer;
 id1: winidty;
begin
 setlength(zorders,length(ids));
 foundcount:= 0;
 id1:= gettopwindow(0);
 while (foundcount <= high(ids)) and (id1 <> 0) do begin
  for int1:= 0 to high(ids) do begin
   if ids[int1] = id1 then begin
    zorders[int1]:= -foundcount;
    inc(foundcount);
    break;
   end;
  end;
  id1:= getnextwindow(id1,gw_hwndnext);
 end;
 if foundcount - 1 = high(ids) then begin
  result:= gue_ok
 end
 else begin
  result:= gue_windownotfound;
 end;
end;

function gui_setwindowcaption(id: winidty; const caption: msestring): guierrorty;
 procedure setcap(const id: winidty);
 var
  str1: string;
 begin
  if iswin95 then begin
   str1:= caption;
   if windows.SetWindowTextA(id,pchar(str1)) then begin
    result:= gue_ok;
   end
  end
  else begin
   if windows.SetWindowTextW(id,pwidechar(caption)) then begin
    result:= gue_ok;
   end
  end;
 end;
begin
 result:= gue_error;
 setcap(id);
 if (id = groupleaderwindow) and (result = gue_ok) then begin
  setcap(applicationwindow);
 end;
end;

function composeicon(const icon,mask: pixmapty): hicon;
var
 iconinfo1: iconinfo;
 maskbmp,iconbmp: hbitmap;
 dc1,dc2,dc3: hdc;
 bmpinfo: bitmapinfo;
 bru1: hbrush;
 rect1: trect;
begin
 result:= 0;
 if icon <> 0 then begin
  fillchar(bmpinfo,sizeof(bmpinfo),0);
  with bmpinfo.bmiHeader do begin
   bisize:= sizeof(bmpinfo.bmiheader);
   dc1:= createcompatibledc(0);
   if getdibits(dc1,icon,0,0,nil,bmpinfo,dib_rgb_colors) <> 0 then begin
    dc2:= createcompatibledc(0);
    maskbmp:= createbitmap(biwidth,biheight,1,1,nil);
    selectobject(dc1,maskbmp);
    if mask = 0 then begin
     bru1:= createsolidbrush(0);
     rect1.Left:= 0;
     rect1.top:= 0;
     rect1.right:= biwidth;
     rect1.bottom:= 0;
     fillrect(dc1,rect1,bru1);
     deleteobject(bru1);
    end
    else begin
     selectobject(dc2,mask); //should not be selected in another dc
     bitblt(dc1,0,0,biwidth,biheight,dc2,0,0,rasterops3[rop_copy]);
     deletedc(dc2);
     dc2:= createcompatibledc(0);
    end;
   end
   else begin
    deletedc(dc1);
    exit;
   end;
   dc3:= createcompatibledc(0);
   selectobject(dc3,icon); //should not be selected in another dc
   iconbmp:= createcompatiblebitmap(dc3,biwidth,biheight);
   selectobject(dc2,iconbmp);
   bitblt(dc2,0,0,biwidth,biheight,dc3,0,0,rasterops3[rop_copy]);
   deletedc(dc3);
   bitblt(dc2,0,0,biwidth,biheight,dc1,0,0,rasterops3[rop_notand]);
               //icon out of mask -> 0;
   deletedc(dc1);
   deletedc(dc2);
   with iconinfo1 do begin
    ficon:= true;
    xhotspot:= 0;
    yhotspot:= 0;
    hbmmask:= maskbmp;
    hbmcolor:= iconbmp;
   end;
   result:= createiconindirect(iconinfo1);
   deleteobject(maskbmp);
   deleteobject(iconbmp);
  end;
 end
 else begin
  result:= 0;
 end;
end;

function gui_setwindowicon(id: winidty; const icon,mask: pixmapty): guierrorty;
var
 ico,ico1: hicon;
begin
 result:= gue_error;
 if icon <> 0 then begin
  ico:= composeicon(icon,mask);
  if ico = 0 then begin
   exit;
  end;
 end
 else begin
  ico:= 0;
 end;
 ico1:= sendmessage(id,wm_seticon,icon_big,ico);
 if ico1 <> 0 then begin
  destroyicon(ico1);
 end;
 result:= gue_ok;
end;

function gui_setapplicationicon(const icon,mask: pixmapty): guierrorty;
begin
 result:= gui_setwindowicon(applicationwindow,icon,mask);
end;

type
 pidinfoty = record
  pids: procidarty;
  winid: winidty;
 end;
 ppidinfoty = ^pidinfoty;

function checkproc(awinid: winidty; po: ptrint): bool; stdcall;
var
 pid: integer;
 int1: integer;
begin
 result:= true;
 if getwindowlong(awinid,gwl_style) and windows.ws_visible <> 0 then begin 
  getwindowthreadprocessid(awinid,@pid);
  with ppidinfoty(po)^ do begin
   for int1:= 0 to high(pids) do begin
    if pids[int1] = pid then begin
     result:= false;
     winid:= awinid;
     break;
    end;
   end;
  end;
 end;
end;

function gui_pidtowinid(const pids: procidarty): winidty;
var
 info: pidinfoty;
begin
 info.pids:= pids;
 info.winid:= 0;
 enumwindows(@checkproc,ptrint(@info));
 result:= info.winid;
end;

function gui_rgbtopixel(rgb: longword): pixelty;
begin
 result:= swaprgb(rgb);
end;

function gui_pixeltorgb(pixel: pixelty): longword;
begin
 result:= swaprgb(pixel);
end;

procedure gdi_changegc(var drawinfo: drawinfoty);
begin
 with drawinfo.gcvalues^,drawinfo.gc,win32gcty(platformdata).d do begin
  if gvm_colorbackground in mask then begin
   exclude(flags,gcf_backgroundbrushvalid);
   backgroundcol:= colorbackground;
  end;
  if gvm_colorforeground in mask then begin
   flags:= flags - [gcf_colorbrushvalid,gcf_foregroundpenvalid];
   foregroundcol:= colorforeground;
  end;
  if mask * [gvm_linewidth,gvm_dashes,gvm_capstyle,gvm_joinstyle] <> [] then begin
   flags:= flags - [gcf_foregroundpenvalid];
   peninfo:= lineinfo;
   peninfo.width:= (peninfo.width + linewidthroundvalue) shr linewidthshift;
  end;
  if gvm_rasterop in mask then begin
   exclude(flags,gcf_rasterop);
   rop:= rasterop;
  end;
  if gvm_brush in mask then begin
   flags:= flags - [gcf_patternbrushvalid];
   bru:= tsimplebitmap1(brush).handle;
  end;
  if gvm_brushorigin in mask then begin
   brushorg:= brushorigin;
   setbrushorgex(handle,brushorigin.x,brushorigin.y,nil);
  end;
  if gvm_clipregion in mask then begin
   gccliporigin:= cliporigin;
   if ((cliporigin.x <> 0) or (cliporigin.y <> 0)) and (clipregion <> 0) then begin
    offsetrgn(clipregion,cliporigin.x,cliporigin.y);
    selectcliprgn(handle,clipregion);
    offsetrgn(clipregion,-cliporigin.x,-cliporigin.y);
   end
   else begin
    selectcliprgn(handle,clipregion);
   end;
  end;
  if gvm_font in mask then begin
   selectobject(handle,font);
  end;
 end;
end;

procedure updateopaquemode(var gc: gcty);
begin
 with gc,win32gcty(platformdata).d do begin
  settextcolor(handle,foregroundcol);
  if df_opaque in drawingflags then begin
   setbkmode(handle,opaque);
   setbkcolor(handle,backgroundcol);
  end
  else begin
   setbkmode(handle,transparent);
  end;
 end;
end;

procedure checkgc2(var gc: gcty);
         //second pass for transparent patternpen
begin
 with gc,win32gcty(platformdata).d do begin
  if gcf_isopaquedashpen in flags then begin
   selectobject(handle,secondpen);
   deleteobject(selectedpen);
   selectedpen:= secondpen;
   foregroundpen:= secondpen;
   exclude(flags,gcf_foregroundpenvalid);
  end
  else begin
   setbkcolor(handle,$000000);
   settextcolor(handle,foregroundcol);
   setrop2(handle,secondrasterops2[rop]);
   exclude(flags,gcf_rasterop);
  end;
 end;
end;

function checkgc(var gc: gcty; aflags: gcflagsty): boolean;
               //true if second drawing needed
var
 flags1: gcflagsty;
 brushinfo: logbrush;
 adashes: array[0..high(dashesstringty)] of longword;
 int1: integer;
 po1: pointer;
 dashlen: integer;
 astyle: longword;
 awidth: integer;

begin
 result:= false;
 with gc,win32gcty(platformdata).d do begin
  exclude(flags,gcf_isopaquedashpen);
  if (df_brush in drawingflags) xor (gcf_ispatternpen in flags) then begin
   exclude(flags,gcf_foregroundpenvalid);
  end;
  if  not (gcf_rasterop in flags) and
   ([gcf_selectforegroundbrush,gcf_selectforegroundpen] * aflags <>
    [gcf_selectforegroundbrush,gcf_selectforegroundpen]) then begin
   exclude(flags,gcf_selectforegroundbrush);   //refresh rasterop
   exclude(flags,gcf_selectforegroundpen);
   if df_canvasismonochrome in drawingflags then begin
    setrop2(handle,inverserops2[rop]);
   end
   else begin
    setrop2(handle,rasterops2[rop]);
   end;
   include(flags,gcf_rasterop);
  end;
  flags1:= gcflagsty((longword(aflags) xor longword(flags)) and longword(aflags));
       //needed objects
  if df_brush in drawingflags then begin
   exclude(flags1,gcf_colorbrushvalid);
  end
  else begin
   exclude(flags1,gcf_patternbrushvalid);
  end;
  if gcf_backgroundbrushvalid in flags1 then begin
   if backgroundbrush <> 0 then begin
    if backgroundbrush = selectedbrush then begin
     selectobject(handle,nullbrush);
    end;
    deleteobject(backgroundbrush);
   end;
   backgroundbrush:= createsolidbrush(backgroundcol);
  end;
  if gcf_colorbrushvalid in flags1 then begin
   if colorbrush <> 0 then begin
    if colorbrush = selectedbrush then begin
     selectobject(handle,nullbrush);
    end;
    deleteobject(colorbrush);
   end;
   colorbrush:= createsolidbrush(foregroundcol);
  end;
  if gcf_patternbrushvalid in flags1 then begin
   if patternbrush <> 0 then begin
    if patternbrush = selectedbrush then begin
     selectobject(handle,nullbrush);
    end;
    deleteobject(patternbrush);
   end;
   patternbrush:= createpatternbrush(bru);
  end;
  if gcf_foregroundpenvalid in flags1 then begin
   if foregroundpen <> 0 then begin
    if selectedpen = foregroundpen then begin
     selectobject(handle,nullpen);
    end;
    deleteobject(foregroundpen);
   end;
                //todo: emulations for win95, opaquemode
   with peninfo do begin
    po1:= nil;
    dashlen:= length(dashes);
    if dashlen > 0 then begin
     if df_opaque in drawingflags then begin
      include(flags,gcf_isopaquedashpen);
      result:= true;
     end;
     if iswin95 then begin
      astyle:= ps_dot;
     end
     else begin
      if dashes = #1#1 then begin
       astyle:= ps_alternate or ps_cosmetic;
       dashlen:= 0;
      end
      else begin
       for int1:= 1 to length(dashes) do begin
        adashes[int1-1]:= ord(dashes[int1]){ div 3};
       end;
       po1:= @adashes;
       astyle:= ps_userstyle or ps_geometric;
      end;
     end;
    end
    else begin
     if (df_brush in drawingflags) or (width > 0) then begin
      astyle:= ps_geometric;
     end
     else begin
      astyle:= ps_cosmetic;
     end;
    end;
    if astyle and ps_geometric <> 0 then begin
     astyle:= astyle or capstyles[capstyle] or joinstyles[joinstyle];
    end;
    with brushinfo do begin
     if df_brush in drawingflags then begin
      lbStyle:= bs_pattern;
      lbhatch:= bru;
      include(flags,gcf_ispatternpen);
     end
     else begin
      lbStyle:= bs_solid;
      lbColor:= foregroundcol;
      exclude(flags,gcf_ispatternpen);
     end;
    end;
    if width = 0 then begin
     awidth:= 1
    end
    else begin
     awidth:= width
    end;
    foregroundpen:= extcreatepen(astyle,awidth,brushinfo,
                    dashlen,po1);
    if gcf_isopaquedashpen in flags then begin
     secondpen:= foregroundpen;
     with brushinfo do begin
      lbStyle:= bs_solid;
      lbColor:= backgroundcol;
     end;
     foregroundpen:= extcreatepen(astyle and 
         not(ps_userstyle or ps_dot or ps_alternate),awidth,brushinfo,
                    0,nil);         
    end;
   end;
  end;
  if gcf_selectbackgroundbrush in aflags then begin
   selectobject(gc.handle,backgroundbrush);
   selectedbrush:= backgroundbrush;
  end;
  if gcf_selectforegroundbrush in aflags then begin
   if df_brush in drawingflags then begin
    selectobject(gc.handle,patternbrush);
    selectedbrush:= patternbrush;
   end
   else begin
    selectobject(gc.handle,colorbrush);
    selectedbrush:= colorbrush;
   end;
  end;
  if gcf_selectforegroundpen in aflags then begin
   if (gcf_ispatternpen in flags) and
    (drawingflags * [df_monochrome,df_opaque] = [df_monochrome]) then begin
    result:= true;
    setbkcolor(handle,$ffffff);
    settextcolor(handle,$000000);
    setrop2(handle,firstrasterops2[rop]);
   end
   else begin
    updateopaquemode(gc);
   end;
   selectobject(gc.handle,foregroundpen);
   selectedpen:= foregroundpen;
  end;
  if gcf_selectnullpen in aflags then begin
   selectobject(gc.handle,nullpen);
   selectedpen:= nullpen;
  end;
  if gcf_selectnullbrush in aflags then begin
   selectobject(gc.handle,nullbrush);
   selectedbrush:= nullbrush;
  end;
  flags:= gcflagsty(longword(flags) or longword(flags1));
//  if (df_monochrome in drawingflags)  then begin
//   updateopaquemode(gc);
//  end;
 end;
end;

function createregion: regionty; overload;
begin
{$ifdef mse_debuggdi}
 inc(regioncount);
{$endif}
 result:= createrectrgnindirect(trect(nullrect));
end;

function createregion(var rect: rectty; const gc: gcty): regionty; overload;
var
 rect1: rectty;
begin
{$ifdef mse_debuggdi}
 inc(regioncount);
{$endif}
 if win32gcty(gc.platformdata).d.kind = gck_printer then begin
  rect1:= rect;
  recttowinrect(rect1);
  lptodp(gc.handle,
     {$ifdef FPC}lppoint(@{$endif}rect1{$ifdef FPC}){$endif},2);
  result:= createrectrgnindirect(trect(rect1));   
 end
 else begin
  recttowinrect(rect);
  result:= createrectrgnindirect(trect(rect));
  winrecttorect(rect);
 end;
end;

procedure gdi_createemptyregion(var drawinfo: drawinfoty);
begin
 with drawinfo.regionoperation do begin
  dest:= createregion;
 end;
end;

procedure gdi_setcliporigin(var drawinfo: drawinfoty);
var
 reg1: hrgn;
 delta: pointty;
begin
 with drawinfo.gc,win32gcty(platformdata).d do begin
  delta:= subpoint(cliporigin,gccliporigin);
  if (delta.x <> 0) or (delta.y <> 0) then begin
   reg1:= createregion;
   if getcliprgn(handle,reg1) > 0 then begin
    offsetrgn(reg1,delta.x,delta.y);
    selectcliprgn(handle,reg1);
   end;
   deleteobject(reg1);
{$ifdef mse_debuggdi}
   dec(regioncount);
{$endif}
  end;
  gccliporigin:= cliporigin;
 end;
// gdierror(gde_notimplemented,'setcliporigin');
end;

procedure gdi_createrectregion(var drawinfo: drawinfoty);
begin
 with drawinfo.regionoperation do begin
  dest:= createregion(rect,drawinfo.gc);
 end;
end;

procedure gdi_createrectsregion(var drawinfo: drawinfoty);
var
 reg1: hrgn;
 int1: integer;
 rect1: rectty;
begin
 with drawinfo.regionoperation do begin
  dest:= createregion;
  if rectscount > 0 then begin
   if win32gcty(drawinfo.gc.platformdata).d.kind = gck_printer then begin
    for int1:= 0 to rectscount - 1 do begin
     rect1:= rectspo^[int1];
     recttowinrect(rect1);
     lptodp(drawinfo.gc.handle,
          {$ifdef FPC}lppoint(@{$endif}rect1{$ifdef FPC}){$endif},2);
     reg1:= createrectrgnindirect(trect(rect1));
     combinergn(dest,dest,reg1,rgn_or);
     deleteobject(reg1);
    end;
   end
   else begin
    recttowinrect(@rectspo^[0],rectscount);
    for int1:= 0 to rectscount - 1 do begin
     reg1:= createrectrgnindirect(trect(rectspo^[int1]));
     combinergn(dest,dest,reg1,rgn_or);
     deleteobject(reg1);
    end;
    winrecttorect(@rectspo^[0],rectscount);
   end;
  end;
 end;
end;

procedure gdi_destroyregion(var drawinfo: drawinfoty);
begin
 with drawinfo.regionoperation do begin
  if source <> 0 then begin
{$ifdef mse_debuggdi}
   dec(regioncount);
{$endif}
   deleteobject(source);
  end;
 end;
end;

procedure gdi_regionisempty(var drawinfo: drawinfoty);
var
 rect1: trect;
begin
 with drawinfo.regionoperation do begin
  if getrgnbox(source,rect1) = nullregion then begin
   dest:= 1;
  end
  else begin
   dest:= 0;
  end;
 end;
end;

procedure gdi_regionclipbox(var drawinfo: drawinfoty);
begin
 with drawinfo.regionoperation do begin
  getrgnbox(source,trect(rect));
  if win32gcty(drawinfo.gc.platformdata).d.kind = gck_printer then begin
   dptolp(drawinfo.gc.handle,
          {$ifdef FPC}lppoint(@{$endif}rect{$ifdef FPC}){$endif},2);
  end;
  winrecttorect(rect);
 end;
end;

procedure gdi_copyregion(var drawinfo: drawinfoty);
begin
 with drawinfo.regionoperation do begin
  if source = 0 then begin
   dest:= 0;
  end
  else begin
   dest:= createregion;
   combinergn(dest,source,0,rgn_copy);
  end;
 end;
end;

procedure gdi_moveregion(var drawinfo: drawinfoty);
begin
 with drawinfo.regionoperation do begin
  offsetrgn(source,rect.x,rect.y);
 end;
end;

procedure gdi_regsubrect(var drawinfo: drawinfoty);
var
 reg1: hrgn;
begin
 with drawinfo.regionoperation do begin
  reg1:= createregion(rect,drawinfo.gc);
  combinergn(dest,dest,reg1,rgn_diff);
  deleteobject(reg1);
{$ifdef mse_debuggdi}
  dec(regioncount);
{$endif}
 end;
end;

procedure gdi_regsubregion(var drawinfo: drawinfoty);
begin
 with drawinfo.regionoperation do begin
  combinergn(dest,dest,source,rgn_diff);
 end;
end;

procedure gdi_regaddrect(var drawinfo: drawinfoty);
var
 reg1: hrgn;
begin
 with drawinfo.regionoperation do begin
  reg1:= createregion(rect,drawinfo.gc);
  combinergn(dest,dest,reg1,rgn_or);
  deleteobject(reg1);
{$ifdef mse_debuggdi}
  dec(regioncount);
{$endif}
 end;
end;

procedure gdi_regaddregion(var drawinfo: drawinfoty);
begin
 with drawinfo.regionoperation do begin
  combinergn(dest,dest,source,rgn_or);
 end;
end;

procedure gdi_regintersectrect(var drawinfo: drawinfoty);
var
 reg1: hrgn;
begin
 with drawinfo.regionoperation do begin
  reg1:= createregion(rect,drawinfo.gc);
  combinergn(dest,dest,reg1,rgn_and);
  deleteobject(reg1);
{$ifdef mse_debuggdi}
  dec(regioncount);
{$endif}
 end;
end;

procedure gdi_regintersectregion(var drawinfo: drawinfoty);
begin
 with drawinfo.regionoperation do begin
  combinergn(dest,dest,source,rgn_and);
 end;
end;

procedure transformrect(var drawinfo: drawinfoty);
begin
 allocbuffer(drawinfo.buffer,sizeof(trect));
 with drawinfo,prect(buffer.buffer)^,rect do begin
  Left:= rect^.x + origin.x;
  right:= Left + rect^.cx;
  top:= rect^.y + origin.y;
  bottom:= top + rect^.cy;
 end;
end;

procedure transformellipseinfo(var drawinfo: drawinfoty; const fill: boolean);
var
 int1: integer;
begin
 allocbuffer(drawinfo.buffer,sizeof(trect));
 int1:= 1;
 if fill then begin
  int1:= 2;
 end;
 with drawinfo,prect(buffer.buffer)^,rect do begin
  Left:= rect^.x + origin.x - drawinfo.rect.rect^.cx div 2;
  right:= Left + rect^.cx+int1;
  top:= rect^.y + origin.y - drawinfo.rect.rect^.cy div 2;
  bottom:= top + rect^.cy+int1;
 end;
end;

procedure offsetrect(var drawinfo: drawinfoty);
begin
 allocbuffer(drawinfo.buffer,sizeof(rectty));
 with drawinfo,prectty(buffer.buffer)^,rect do begin
  x:= rect^.x + origin.x;
  cx:= rect^.cx;
  y:= rect^.y + origin.y;
  cy:= rect^.cy;
 end;
end;

procedure transformpoints(var drawinfo: drawinfoty; const aclose: boolean);
var
 po1: ppointty;
 po2: ppointty;
 int1: integer;
begin
 with drawinfo.points do begin
  int1:= count;
  if aclose then begin
   inc(int1);
  end;
  allocbuffer(drawinfo.buffer,int1*sizeof(pointty));
  po1:= points;
  po2:= drawinfo.buffer.buffer;
  int1:= count;
  with drawinfo.origin do begin
   while int1 > 0 do begin
    po2^.x:= po1^.x + x;
    po2^.y:= po1^.y + y;
    inc(po1);
    inc(po2);
    dec(int1);
   end;
  end;
  if aclose then begin
   move(drawinfo.buffer.buffer^,(pchar(drawinfo.buffer.buffer)+
              count*sizeof(pointty))^,sizeof(pointty));
  end;
 end;
end;

//todo!!!!!: support all rops on win95, test!!!

function win95maskblt(DestDC: HDC; XDest, YDest, Width, Height: Integer; SrcDC: HDC;
  XScr, YScr: Integer; Mask: HBITMAP; amaskdc: hdc; xMask, yMask: Integer; Rop: rasteropty): boolean;
var
 maskdc: hdc;
 bmp: hbitmap;
 dc: hdc;
 textcol,bkcol: longword;

 procedure getcopy(arop: rasteropty);
 begin
  textcol:= gettextcolor(destdc);
  bkcol:= getbkcolor(destdc);
  settextcolor(destdc,$ffffff);
  setbkcolor(destdc,$000000);
  bmp:= createcompatiblebitmap(destdc,width,height);
  dc:= createcompatibledc(destdc);
  selectobject(dc,bmp);
  settextcolor(dc,textcol);
  setbkcolor(dc,bkcol);
  bitblt(dc,0,0,width,height,srcdc,xscr,yscr,rasterops3[rop_copy]);
  settextcolor(dc,$ffffff);
  setbkcolor(dc,$000000);
  bitblt(dc,0,0,width,height,maskdc,xmask,ymask,rasterops3[arop]);
 end;

begin
 result:= true;
 bmp:= 0;
 if amaskdc = 0 then begin
  maskdc:= createcompatibledc(0);
  selectobject(maskdc,mask);
 end
 else begin
  maskdc:= amaskdc;
 end;
 case rop of
  rop_copy,rop_xor,rop_or: begin
   getcopy(rop_and);
   if rop = rop_copy then begin
    bitblt(destdc,xdest,ydest,width,height,maskdc,xmask,ymask,rasterops3[rop_notand]);
    settextcolor(destdc,textcol);
    setbkcolor(destdc,bkcol);
    bitblt(destdc,xdest,ydest,width,height,dc,0,0,rasterops3[rop_or]);
   end
   else begin
    settextcolor(destdc,textcol);
    setbkcolor(destdc,bkcol);
    bitblt(destdc,xdest,ydest,width,height,dc,0,0,rasterops3[rop]);
   end;
  end;
  rop_and: begin
   getcopy(rop_notor);
   settextcolor(destdc,textcol);
   setbkcolor(destdc,bkcol);
   bitblt(destdc,xdest,ydest,width,height,dc,0,0,rasterops3[rop]);
  end;
 end;
 if amaskdc = 0 then begin
  deletedc(maskdc);
 end;
 if bmp <> 0 then begin
  deletedc(dc);
  deleteobject(bmp);
 end;
end;

procedure getarcinfo(const info: drawinfoty; 
                    out xstart,ystart,xend,yend: integer);
var
 stopang: real;
begin
 with info,arc,rect^ do begin
  stopang:= (startang+extentang);
  xstart:= (round(cos(startang)*cx) div 2) + x + origin.x;
  ystart:= (round(-sin(startang)*cy) div 2) + y + origin.y;
  xend:= (round(cos(stopang)*cx) div 2) + x + origin.x;
  yend:= (round(-sin(stopang)*cy) div 2) + y + origin.y;
 end;
end;

procedure fill(var drawinfo: drawinfoty; shape: shapety);

var
 xstart,ystart,xend,yend: integer; 
 
 procedure fill1( adc: hdc; arop: rasteropty);
 begin
  with drawinfo do begin
   if (shape <> fs_rect) and (shape <> fs_copyarea) then begin
    if df_canvasismonochrome in gc.drawingflags then begin
     setrop2(adc,inverserops2[arop]);
    end
    else begin
     setrop2(adc,rasterops2[arop]);
    end;
   end;
   if shape <> fs_copyarea then begin
    with win32gcty(gc.platformdata).d do begin
     if patternbrush <> 0 then begin
      selectobject(adc,patternbrush);
      if adc = gc.handle then begin
       selectedbrush:= patternbrush;
      end;
     end;
    end;
   end;
   case shape of
    fs_copyarea: begin
     with copyarea,sourcerect^ do begin
      if mask = nil then begin
       bitblt(adc,destrect^.x,destrect^.y,cx,cy,tcanvas1(source).fdrawinfo.gc.handle,x,y,rasterops3[arop]);
      end
      else begin
       if iswin95 or (win32gcty(gc.platformdata).d.kind = gck_printer) then begin
//        win95maskblt(adc,destrect^.x,destrect^.y,cx,cy,source^.gc.handle,
//                    x,y,mask,maskgchandle,x,y,arop);
        tcanvas1(mask.canvas).checkgcstate([cs_gc]);
        win95maskblt(adc,destrect^.x,destrect^.y,cx,cy,
                    tcanvas1(source).fdrawinfo.gc.handle,
                    x,y,tsimplebitmap1(mask).handle,
                    tcanvas1(mask.canvas).fdrawinfo.gc.handle,x,y,arop);
       end
       else begin
        maskblt(adc,destrect^.x,destrect^.y,cx,cy,
                    tcanvas1(source).fdrawinfo.gc.handle,
                    x,y,tsimplebitmap1(mask).handle,x,y,
                    makerop4(rasterops3[rop_nop],rasterops3[arop]));
       end;
      end;
     end;
    end;
    fs_rect: begin
     with prectty(buffer.buffer)^ do begin
      windows.patblt(adc,x,y,cx,cy,patrops3[arop]);
     end;
    end;
    fs_ellipse: begin
     with trect(buffer.buffer^) do begin
      windows.ellipse(adc,left,top,right,bottom);
     end;
    end;
    fs_arc: begin
     with trect(buffer.buffer^) do begin
      if arc.pieslice then begin
       windows.pie(adc,left,top,right,bottom,xstart,ystart,xend,yend);
      end
      else begin
       windows.chord(adc,left,top,right,bottom,xstart,ystart,xend,yend);
      end;
     end;
    end;
    fs_polygon: begin
     windows.Polygon(adc,buffer.buffer^,points.count);
    end;
   end;
  end;
 end;

var
 rect1,rect2: rectty;
 po1: ppointty;
 int1: integer;
 bmp: hbitmap;
 dc1: hdc;

begin
 if shape = fs_arc then begin
  getarcinfo(drawinfo,xstart,ystart,xend,yend);
 end;
 with drawinfo do begin
  with gc,win32gcty(platformdata).d do begin
   if (drawingflags * [df_monochrome,df_opaque,df_brush] = 
                                          [df_monochrome,df_brush]) then begin
    if shape <> fs_rect then begin
     if shape <> fs_copyarea then begin
      checkgc(gc,[gcf_patternbrushvalid,gcf_selectnullpen]);
      exclude(flags,gcf_rasterop);
     end;
    end
    else begin
     checkgc(gc,[gcf_patternbrushvalid]);
    end;
    if rop in [rop_or,rop_xor,rop_and,rop_copy,rop_set,rop_clear] then begin
     case rop of
      rop_or,rop_xor: begin
//       setbkcolor(handle,foregroundcol);
       settextcolor(handle,foregroundcol);
//       settextcolor(handle,$00000000);
       setbkcolor(handle,$00000000);
       fill1(handle,rop);
      end;
      rop_and: begin
//       setbkcolor(handle,foregroundcol);
       settextcolor(handle,foregroundcol);
//       settextcolor(handle,$00ffffff);
       setbkcolor(handle,$00ffffff);
       fill1(handle,rop_and);
      end;
      rop_set: begin
//       setbkcolor(handle,$00ffffff);
       settextcolor(handle,$00ffffff);
//       settextcolor(handle,$00000000);
       setbkcolor(handle,$00000000);
       fill1(handle,rop_or); //set pattern
      end
      else begin
//       setbkcolor(handle,$00000000);
       settextcolor(handle,$00000000);
//       settextcolor(handle,$00ffffff);
       setbkcolor(handle,$00ffffff);
       fill1(handle,rop_and);  //clear pattern
       if rop = rop_copy then begin
//        settextcolor(handle,$00000000);
        setbkcolor(handle,$00000000);
//        setbkcolor(handle,foregroundcol);
        settextcolor(handle,foregroundcol);
        fill1(handle,rop_or);  //fill pattern
       end;
      end;
     end;
    end
    else begin //buffer needed
     getclipbox(handle,trect(rect1));
     winrecttorect(rect1);
     if (shape = fs_rect) or (shape = fs_copyarea) then begin
      rect2:= prectty(buffer.buffer)^;
     end
     else begin
      rect2.x:= maxint;
      rect2.y:= maxint;
      rect2.cx:= minint;
      rect2.cy:= minint;
      case shape of           //calculate max. dims
       fs_polygon: begin
        po1:= buffer.buffer;
        for int1:= 0 to points.count - 1 do begin
         if po1^.x < rect2.x then begin
          rect2.x:= po1^.x;
         end;
         if po1^.x > rect2.cx then begin
          rect2.cx:= po1^.x;
         end;
         if po1^.y < rect2.y then begin
          rect2.y:= po1^.y;
         end;
         if po1^.y > rect2.cy then begin
          rect2.cy:= po1^.y;
         end;
         inc(po1);
        end;
       end;
      end;
      winrecttorect(rect2);
     end;
     if msegraphutils.intersectrect(rect1,rect2,rect1) then begin
      bmp:= gui_createpixmap(rect1.size,0,df_canvasismonochrome in drawingflags);
      if bmp <> 0 then begin
       dc1:= createcompatibledc(0);
       if dc1 <> 0 then begin
        selectobject(dc1,bmp);
        setwindoworgex(dc1,rect1.x,rect1.y,nil);
        bitblt(dc1,rect1.x,rect1.y,rect1.cx,rect1.cy,handle,rect1.x,rect1.y,srccopy); //get copy
        setbrushorgex(dc1,brushorg.x-rect1.x,brushorg.y-rect1.y,nil);
//        setbkcolor(dc1,foregroundcol);
        settextcolor(dc1,foregroundcol);
//        settextcolor(dc1,backgroundcol);
        setbkcolor(dc1,backgroundcol);
        fill1(dc1,rop);                //draw pattern
//        setbkcolor(dc1,$00000000);
        settextcolor(dc1,$00000000);
//        settextcolor(dc1,$00ffffff);
        setbkcolor(dc1,$00ffffff);
        fill1(dc1,rop_notand);         //erase background
//        setbkcolor(handle,$00000000);
        settextcolor(handle,$00000000);
//        settextcolor(handle,$00ffffff);
        setbkcolor(handle,$00ffffff);
        fill1(handle,rop_and);         //erase pattern
        bitblt(handle,rect1.x,rect1.y,rect1.cx,rect1.cy,dc1,rect1.x,rect1.y,
                    rasterops3[rop_or]); //combine
        deletedc(dc1);
       end;
       gui_freepixmap(bmp);
//       deleteobject(bmp);
      end;
     end;
    end;
   end
   else begin
    if df_opaque in drawingflags then begin
//     settextcolor(handle,backgroundcol);
     setbkcolor(handle,backgroundcol);
//     setbkcolor(handle,foregroundcol);
     settextcolor(handle,foregroundcol);
    end;
    if shape <> fs_rect then begin
     checkgc(gc,[gcf_colorbrushvalid,gcf_patternbrushvalid,
                            gcf_selectforegroundbrush,gcf_selectnullpen]);
    end;
    case shape of
     fs_rect: begin
      with prectty(buffer.buffer)^ do begin
       if (df_brush in drawingflags) then begin
        checkgc(gc,[gcf_colorbrushvalid,gcf_patternbrushvalid,
                             gcf_selectforegroundbrush]);
        windows.patblt(handle,x,y,cx,cy,patrops3[rop]);
       end
       else begin
        if  rop = rop_copy then begin
         checkgc(gc,[gcf_colorbrushvalid]);
         {$ifdef FPC}
         winfillrect(handle,mrect(x,y,x+cx,y+cy),colorbrush);
         {$else}
         windows.fillrect(handle,mrect(x,y,x+cx,y+cy),colorbrush);
         {$endif}
        end
        else begin
         checkgc(gc,[gcf_colorbrushvalid,gcf_selectforegroundbrush]);
         windows.patblt(handle,x,y,cx,cy,patrops3[rop]);
        end;
       end;
      end;
     end;
     fs_ellipse: begin
      with trect(buffer.buffer^) do begin
       windows.ellipse(gc.handle,left,top,right,bottom);
      end;
     end;
     fs_arc: begin
      with trect(buffer.buffer^) do begin
       if arc.pieslice then begin
        windows.pie(gc.handle,left,top,right,bottom,xstart,ystart,xend,yend);
       end
       else begin
        windows.chord(gc.handle,left,top,right,bottom,xstart,ystart,xend,yend);
       end;
      end;
     end;
     fs_polygon: begin
      windows.Polygon(gc.handle,buffer.buffer^,points.count);
     end;
    end;
   end;
  end;
 end;
end;

procedure gdi_fillrect(var drawinfo: drawinfoty);
begin
 offsetrect(drawinfo);
 fill(drawinfo,fs_rect);
end;

procedure gdi_fillelipse(var drawinfo: drawinfoty);
begin
 transformellipseinfo(drawinfo,true);
 fill(drawinfo,fs_ellipse);
end;

procedure gdi_fillarc(var drawinfo: drawinfoty);
begin
 transformellipseinfo(drawinfo,true);
 fill(drawinfo,fs_arc);
end;

procedure gdi_fillpolygon(var drawinfo: drawinfoty);
begin
 transformpoints(drawinfo,false);
 fill(drawinfo,fs_polygon);
end;

procedure gdi_copyarea(var drawinfo: drawinfoty);

var
 maskbmp,stretchedbmp: pixmapty;
 smaskdc,destdc: hdc;
 bufferbmp: hbitmap;
 rect1: rectty;
 nomaskblt: boolean;

 procedure setintpolmode(const ahandle: hdc);
 var
  pt1: tpoint;
 begin
  with drawinfo.copyarea do begin
   if (al_intpol in alignment) and not iswin95 then begin
    getbrushorgex(ahandle,pt1);
    setstretchbltmode(ahandle,halftone);
    setbrushorgex(ahandle,pt1.x,pt1.y,nil);
   end
   else begin
    if al_or in alignment then begin
     setstretchbltmode(ahandle,blackonwhite);
    end
    else begin
     if al_and in alignment then begin
      setstretchbltmode(ahandle,whiteonblack);
     end
     else begin
      setstretchbltmode(ahandle,coloroncolor);
     end;
    end;
   end;
  end;
 end;
 
 procedure getstretchedbmps;
 var
  po1: pointty;
 begin
  with drawinfo,copyarea,sourcerect^,gc do begin
   po1.x:= destrect^.x - rect1.x;
   po1.y:= destrect^.y - rect1.y;
   if mask <> nil then begin
    tcanvas1(mask.canvas).checkgcstate([cs_gc]);
    smaskdc:= tcanvas1(mask.canvas).fdrawinfo.gc.handle;
    maskbmp:= gui_createpixmap(rect1.size,0,true);
   end
   else begin
    maskbmp:= 0;
   end;
   stretchedbmp:= createcompatiblebitmap(tcanvas1(source).fdrawinfo.gc.handle,
                                                              rect1.cx,rect1.cy);
   destdc:= createcompatibledc(0);
   setintpolmode(destdc);
   if mask <> nil then begin
    selectobject(destdc,maskbmp);
    stretchblt(destdc,po1.x,po1.y,destrect^.cx,destrect^.cy,smaskdc,
                   x,y,cx,cy,rasterops3[rop_copy]);
   end;
   selectobject(destdc,stretchedbmp);
   stretchblt(destdc,po1.x,po1.y,destrect^.cx,destrect^.cy,
                  tcanvas1(source).fdrawinfo.gc.handle,
                  x,y,cx,cy,rasterops3[rop_copy]);
  end;
 end;

 procedure deletestretchedbmps;
 begin
  if maskbmp <> 0 then begin
   if bufferbmp = 0 then begin
    gui_freepixmap(maskbmp);
//    deleteobject(maskbmp);
   end;
  end;
  deletedc(destdc);
  deleteobject(stretchedbmp);
 end;

 procedure transfer(double: boolean = false);
 begin
  with drawinfo,copyarea,sourcerect^,gc,win32gcty(platformdata).d do begin
   if alignment * [al_stretchx,al_stretchy] = [] then begin
    if mask = nil then begin
     bitblt(handle,destrect^.x,destrect^.y,cx,cy,
                    tcanvas1(source).fdrawinfo.gc.handle,
                    x,y,rasterops3[copymode]);
     if double then begin
      setbkcolor(handle,$000000);
      settextcolor(handle,foregroundcol);
      bitblt(handle,destrect^.x,destrect^.y,cx,cy,
                     tcanvas1(source).fdrawinfo.gc.handle,
                     x,y,rasterops3[rop_or]);
     end;
    end
    else begin
     if nomaskblt then begin
      tcanvas1(mask.canvas).checkgcstate([cs_gc]);
      win95maskblt(handle,destrect^.x,destrect^.y,cx,cy,
                    tcanvas1(source).fdrawinfo.gc.handle,
                    x,y,tsimplebitmap1(mask).fhandle,
                    tcanvas1(mask.canvas).fdrawinfo.gc.handle,x,y,copymode);
     end
     else begin
      maskblt(handle,destrect^.x,destrect^.y,cx,cy,
                    tcanvas1(source).fdrawinfo.gc.handle,
                    x,y,tsimplebitmap1(mask).handle,x,y,
                    makerop4(rasterops3[rop_nop],rasterops3[copymode]));
     end;
     if double then begin
      setbkcolor(handle,$000000);
      settextcolor(handle,foregroundcol);
      if nomaskblt then begin
       win95maskblt(handle,destrect^.x,destrect^.y,cx,cy,
                    tcanvas1(source).fdrawinfo.gc.handle,
                    x,y,tsimplebitmap1(mask).fhandle,
                    tcanvas1(mask.canvas).fdrawinfo.gc.handle,x,y,rop_or);
      end
      else begin
       maskblt(handle,destrect^.x,destrect^.y,cx,cy,
                    tcanvas1(source).fdrawinfo.gc.handle,
                    x,y,tsimplebitmap1(mask).fhandle,x,y,
                    makerop4(rasterops3[rop_nop],rasterops3[rop_or]));
      end;
     end;
    end;
   end
   else begin
    if mask = nil then begin
     stretchblt(handle,destrect^.x,destrect^.y,destrect^.cx,destrect^.cy,
                    tcanvas1(source).fdrawinfo.gc.handle,
                    x,y,cx,cy,rasterops3[copymode]);
     if double then begin
      setbkcolor(handle,$000000);
      settextcolor(handle,foregroundcol);
      stretchblt(handle,destrect^.x,destrect^.y,destrect^.cx,destrect^.cy,
                    tcanvas1(source).fdrawinfo.gc.handle,
                    x,y,cx,cy,rasterops3[rop_or]);
     end;
    end
    else begin
     getstretchedbmps;
     if nomaskblt then begin
      win95maskblt(handle,rect1.x,rect1.y,rect1.cx,rect1.cy,destdc,
                    0,0,maskbmp,0,0,0,copymode);
     end
     else begin
      maskblt(handle,rect1.x,rect1.y,rect1.cx,rect1.cy,destdc,
                    0,0,maskbmp,0,0,makerop4(rasterops3[rop_nop],rasterops3[copymode]));
     end;
     if double then begin
      setbkcolor(handle,$000000);
      settextcolor(handle,foregroundcol);
      if nomaskblt then begin
       win95maskblt(handle,rect1.x,rect1.y,rect1.cx,rect1.cy,destdc,
                    0,0,maskbmp,0,0,0,rop_or);
      end
      else begin
       maskblt(handle,rect1.x,rect1.y,rect1.cx,rect1.cy,destdc,
                    0,0,maskbmp,0,0,makerop4(rasterops3[rop_nop],rasterops3[rop_or]));
      end;
     end;
     deletestretchedbmps;
    end;
   end;
  end;
 end;

var
 ropbefore: rasteropty;
 destdcbefore: hdc;
 destpointbefore: pointty;
 rect1posbefore: pointty;
 destbmp,colormaskbmp: hbitmap;
 destbmpdc,maskdc,colormaskdc: hdc;
 destimage,sourceimage,colormaskimage: imagety;
 rs,gs,bs,rd,gd,bd: integer;
 int1: integer;
 colormask: tsimplebitmap1;
 bufferbmpback: hbitmap;
 point1: tpoint;
 maskbefore: tsimplebitmap; 
begin
 with drawinfo,copyarea,gc,win32gcty(platformdata).d do begin
  
  nomaskblt:= iswin95 or (kind = gck_printer);
  setintpolmode(handle);
  getclipbox(handle,trect(rect1));
  winrecttorect(rect1);
  intersectrect(destrect^,rect1,rect1);
  maskbefore:= mask;
  if (mask <> nil) and not mask.monochrome then begin
   colormask:= tsimplebitmap1(mask);
   mask:= nil;
  end
  else begin
   colormask:= nil;
  end;
  if ((longword(transparency) <> 0) or (colormask <> nil))
               and not (df_canvasismonochrome in drawingflags) then begin
   maskbmp:= 0;
   destdcbefore:= handle;
   destpointbefore:= destrect^.pos;
   bufferbmp:= createcompatiblebitmap(handle,rect1.cx,rect1.cy);
   destrect^.pos:= subpoint(destrect^.pos,rect1.pos);
   handle:= createcompatibledc(0);
   setintpolmode(handle);
   selectobject(handle,bufferbmp);
   rect1posbefore:= rect1.pos;
   rect1.pos:= nullpoint;
  end
  else begin
   bufferbmp:= 0;
   destdcbefore:= 0; //compilerwarning
  end;
  if df_colorconvert in drawingflags then begin
   if df_canvasismonochrome in drawingflags then begin
               //convert to monochrome
    setbkcolor(tcanvas1(source).fdrawinfo.gc.handle,transparentcolor);
//    copymode:= rasteropty(inverserops[copymode]);
    transfer;
   end
   else begin
               //convert from monochrome
    if not (df_opaque in drawingflags) then begin
     if copymode = rop_xor then begin
      setbkcolor(handle,$000000);
      settextcolor(handle,foregroundcol);
      transfer;
     end
     else begin
      ropbefore:= copymode;
      setbkcolor(handle,$ffffff);
      settextcolor(handle,$000000);
      copymode:= rop_and;
      transfer(true);
      copymode:= ropbefore;
     end;
//      fill(drawinfo,fs_copyarea);
    end
    else begin
//     settextcolor (handle,backgroundcol);
     setbkcolor(handle,backgroundcol);
//     setbkcolor(handle,foregroundcol);
     settextcolor(handle,foregroundcol);
//     settextcolor(handle,$00ffffff);
     transfer;
    end;
   end;
  end
  else begin //no colorconvert
   if df_canvasismonochrome in drawingflags then begin
    setbkcolor(handle,$ffffff);
    settextcolor(handle,$000000);
//    setbkcolor(handle,backgroundcol);
//    settextcolor(handle,foregroundcol);
   end;
   transfer;
  end;
  if bufferbmp <> 0 then begin //alpha operation  //todo: optimze
   rect1.pos:= rect1posbefore;
   destbmp:= createcompatiblebitmap(handle,rect1.cx,rect1.cy);
   destbmpdc:= createcompatibledc(0);
   setintpolmode(destbmpdc);
   selectobject(destbmpdc,destbmp);
   bitblt(destbmpdc,0,0,rect1.cx,rect1.cy,destdcbefore,rect1.x,rect1.y,srccopy);
   gui_pixmaptoimage(destbmp,destimage,destbmpdc);
   gui_pixmaptoimage(bufferbmp,sourceimage,handle);
   if colormask = nil then begin
    rd:= (transparency.red*256 + 128) div 255;
    gd:= (transparency.green*256 + 128) div 255;
    bd:= (transparency.blue*256 + 128) div 255;
    rs:= 256-rd;
    gs:= 256-gd;
    bs:= 256-bd;
    for int1:= 0 to destimage.length - 1 do begin
     with rgbtriplety(destimage.pixels^[int1]) do begin
      red:= (rd*red + rs*rgbtriplety(sourceimage.pixels^[int1]).red) shr 8;
      green:= (gd*green + gs*rgbtriplety(sourceimage.pixels^[int1]).green) shr 8;
      blue:= (bd*blue + bs*rgbtriplety(sourceimage.pixels^[int1]).blue) shr 8;
     end;
    end;
   end
   else begin
    colormaskbmp:= createcompatiblebitmap(handle,rect1.cx,rect1.cy);
    colormaskdc:= createcompatibledc(0);
    setintpolmode(colormaskdc);
    selectobject(colormaskdc,colormaskbmp);
    tcanvas1(colormask.canvas).checkgcstate([cs_gc]);
    with sourcerect^ do begin
     stretchblt(colormaskdc,destrect^.x,destrect^.y,destrect^.cx,destrect^.cy,
      tcanvas1(colormask.canvas).fdrawinfo.gc.handle,x,y,cx,cy,
                                  rasterops3[rop_copy]);
    end;
    gui_pixmaptoimage(colormaskbmp,colormaskimage,colormaskdc);
    for int1:= 0 to destimage.length - 1 do begin
     with rgbtriplety(destimage.pixels[int1]) do begin
      red:=   (byte(255 - rgbtriplety(colormaskimage.pixels^[int1]).red) * red +
               rgbtriplety(colormaskimage.pixels^[int1]).red *
                rgbtriplety(sourceimage.pixels^[int1]).red) div byte(255);
      green:= (byte(255 - rgbtriplety(colormaskimage.pixels^[int1]).green) * green +
               rgbtriplety(colormaskimage.pixels^[int1]).green *
                rgbtriplety(sourceimage.pixels^[int1]).green) div byte(255);
      blue:=  (byte(255 - rgbtriplety(colormaskimage.pixels^[int1]).blue) * blue +
               rgbtriplety(colormaskimage.pixels^[int1]).blue *
                rgbtriplety(sourceimage.pixels^[int1]).blue) div byte(255);
     end;
    end;
    gui_freeimagemem(colormaskimage.pixels);
    deletedc(colormaskdc);
    deleteobject(colormaskbmp);
   end;
   bufferbmpback:= bufferbmp;
   gui_imagetopixmap(destimage,pixmapty(bufferbmp),handle);
//{$ifdef mse_debuggdi}
//   dec(pixmapcount);
//{$endif}
   gui_freeimagemem(destimage.pixels);
   gui_freeimagemem(sourceimage.pixels);
   if mask <> nil then begin
    if maskbmp <> 0 then begin
     if nomaskblt then begin
      maskdc:= createcompatibledc(0);
      selectobject(maskdc,maskbmp);
      settextcolor(destdcbefore,$000000);
      setbkcolor(destdcbefore,$ffffff);
      bitblt(destdcbefore,rect1.x,rect1.y,rect1.cx,rect1.cy,
                maskdc,0,0,rasterops3[rop_and]);
      settextcolor(handle,$ffffff);
      setbkcolor(handle,$000000);
      bitblt(handle,0,0,rect1.cx,rect1.cy,maskdc,rect1.x,rect1.y,rasterops3[rop_and]);
      bitblt(destdcbefore,rect1.x,rect1.y,rect1.cx,rect1.cy,
                handle,0,0,rasterops3[rop_or]);
      deletedc(maskdc);
     end
     else begin
      maskblt(destdcbefore,rect1.x,rect1.y,
                  rect1.cx,rect1.cy,handle,0,0,maskbmp,0,0,
                      makerop4(rasterops3[rop_nop],srccopy));
     end;
     deleteobject(maskbmp);
    end
    else begin
     if nomaskblt then begin
      tcanvas1(mask.canvas).checkgcstate([cs_gc]);
      smaskdc:= tcanvas1(mask.canvas).fdrawinfo.gc.handle;
      settextcolor(destdcbefore,$000000);
      setbkcolor(destdcbefore,$ffffff);
      bitblt(destdcbefore,rect1.x,rect1.y,rect1.cx,rect1.cy,
                smaskdc,sourcerect^.x-destrect^.x,
                sourcerect^.y-destrect^.y,rasterops3[rop_and]);
      settextcolor(handle,$ffffff);
      setbkcolor(handle,$000000);
      bitblt(handle,0,0,destrect^.cx,destrect^.cy,smaskdc,
                    sourcerect^.x-destrect^.x,sourcerect^.y-destrect^.y,
                    rasterops3[rop_and]);
      bitblt(destdcbefore,rect1.x,rect1.y,rect1.cx,rect1.cy,
                handle,0,0,rasterops3[rop_or]);
     end
     else begin
      maskblt(destdcbefore,rect1.x,rect1.y,
                rect1.cx,rect1.cy,handle,
                    0,0,tsimplebitmap1(mask).handle,
                    sourcerect^.x-destrect^.x,sourcerect^.y-destrect^.y,
                    makerop4(rasterops3[rop_nop],srccopy));
     end;
    end;
   end
   else begin
    bitblt(destdcbefore,rect1.x,rect1.y,rect1.cx,
                 rect1.cy,handle,0,0,srccopy);
   end;
   deletedc(handle);
//   deleteobject(bufferbmp);
   gui_freepixmap(bufferbmp);
   deleteobject(bufferbmpback);
   handle:= destdcbefore;
   destrect^.pos:= destpointbefore;
   deletedc(destbmpdc);
   deleteobject(destbmp);
  end;
  mask:= maskbefore;
 end;
end;

procedure gdi_fonthasglyph(var drawinfo: drawinfoty);
begin
 with drawinfo,fonthasglyph do begin
  hasglyph:= true;
 end;
end;

procedure adjustlineend(po: ppointty); //solve lineto lastpixel problem
var
 po1: ppoint;
 dx,dy,dist: integer;

begin
 po1:= ppoint(pchar(po)-sizeof(pointty));
 dx:= po^.x - po1^.x;
 dy:= po^.y - po1^.y;
 dist:= (abs(dx) + abs(dy)) div 2;
 if dx < 0 then begin
  if dx + dist <= 0 then begin
   dec(po^.x);
  end;
 end
 else begin
  if dx >= dist then begin
   inc(po^.x);
  end;
 end;
 if dy < 0 then begin
  if dy + dist <= 0 then begin
   dec(po^.y);
  end;
 end
 else begin
  if dy >= dist then begin
   inc(po^.y);
  end;
 end;
end;

procedure gdi_drawlines(var drawinfo: drawinfoty);
var
 po1: ppointty;
 bo1: boolean;
begin
 transformpoints(drawinfo,false);
 with drawinfo,points do begin
  if closed then begin
   bo1:= checkgc(gc,[gcf_foregroundpenvalid,gcf_selectforegroundpen,
                        gcf_selectnullbrush]);
   windows.polygon(gc.handle,buffer.buffer^,count);
   if bo1 then begin
    checkgc2(gc);
    windows.polygon(gc.handle,buffer.buffer^,count);
   end;
  end
  else begin
   bo1:= checkgc(gc,[gcf_foregroundpenvalid,gcf_selectforegroundpen]);
   if ((win32gcty(gc.platformdata).d.peninfo.width <= 1) or
           (win32gcty(gc.platformdata).d.peninfo.capstyle = cs_butt)) and 
           (count > 0) then begin
    po1:= @pointarty(buffer.buffer)[count-1]; //endpoint
    if (po1^.x <> pointarty(buffer.buffer)[0].x) or
           (po1^.y <> pointarty(buffer.buffer)[0].y) then  begin
     adjustlineend(po1);
    end;
   end;
   windows.polyline(gc.handle,buffer.buffer^,count);
   if bo1 then begin
    checkgc2(gc);
    windows.polyline(gc.handle,buffer.buffer^,count);
   end;
  end;
 end;
end;

procedure gdi_drawlinesegments(var drawinfo: drawinfoty);
var
 int1,int2: integer;
 po1,po2: pdword;
 po3: ppointty;
 bo1: boolean;
begin
 with drawinfo do begin
  int1:= points.count div 2;
  allocbuffer(buffer,points.count*sizeof(pointty)+int1*sizeof(integer));
      //reserve memory
  transformpoints(drawinfo,false);
  po1:= pointer(pchar(buffer.buffer) + int1*sizeof(segmentty));
  po3:= buffer.buffer; //segments
  inc(po3);            //segmentend
  po2:= po1;           //counts
  int1:= points.count div 2; //segmentcount
//  bo1:= (win32gcty(gc.platformdata).peninfo.width <= 1) or
//          (win32gcty(gc.platformdata).peninfo.capstyle = cs_butt);
  bo1:= (win32gcty(gc.platformdata).d.peninfo.width < 1) {or
          (win32gcty(gc.platformdata).peninfo.capstyle = cs_butt)};
//  bo1:= false;
  for int2:= 0 to int1 - 1 do begin
   if bo1 then begin
    adjustlineend(po3);
    inc(po3,2);
   end;
   po2^:= 2;
   inc(po2);
  end;
  bo1:= checkgc(gc,[gcf_foregroundpenvalid,gcf_selectforegroundpen]);
  windows.polyPolyline(gc.handle,buffer.buffer^,po1^,int1);
  if bo1 then begin
   checkgc2(gc);
   windows.polyPolyline(gc.handle,buffer.buffer^,po1^,int1);
  end;
 end;
end;

procedure gdi_drawellipse(var drawinfo: drawinfoty);
var
 bo1: boolean;
begin
 transformellipseinfo(drawinfo,false);
 with drawinfo do begin
  bo1:= checkgc(gc,[gcf_foregroundpenvalid,gcf_selectforegroundpen,gcf_selectnullbrush]);
  windows.ellipse(gc.handle,trect(buffer.buffer^).Left,
                            trect(buffer.buffer^).top,
                            trect(buffer.buffer^).right,
                            trect(buffer.buffer^).bottom);
  if bo1 then begin
   checkgc2(gc);
   windows.ellipse(gc.handle,trect(buffer.buffer^).Left,
                             trect(buffer.buffer^).top,
                             trect(buffer.buffer^).right,
                             trect(buffer.buffer^).bottom);
  end;
 end;
end;

procedure gdi_drawarc(var drawinfo: drawinfoty);
var                         //todo: optimize
 bo1: boolean;
 xstart,ystart,xend,yend: integer;
begin
 getarcinfo(drawinfo,xstart,ystart,xend,yend);
 with drawinfo,arc,rect^ do begin
  if (xstart = xend) and (ystart = yend) and (abs(extentang) < 1) then begin
   checkgc(gc,[gcf_foregroundpenvalid,gcf_selectforegroundpen,gcf_selectnullbrush]);
   movetoex(gc.handle,xstart,ystart,nil);
   if (win32gcty(gc.platformdata).d.peninfo.width = 0) {and 
           (win32gcty(gc.platformdata).peninfo.capstyle <> cs_butt)} then begin
    inc(xstart);
   end;
   lineto(gc.handle,xstart,ystart);
   exit;
  end;
  if extentang < 0 then begin
   setarcdirection(gc.handle,ad_clockwise);
  end
  else begin
   setarcdirection(gc.handle,ad_counterclockwise);
  end;
 end;
 transformellipseinfo(drawinfo,false);
 with drawinfo do begin
  bo1:= checkgc(gc,[gcf_foregroundpenvalid,gcf_selectforegroundpen,gcf_selectnullbrush]);
  windows.arc(gc.handle,trect(buffer.buffer^).Left,
                            trect(buffer.buffer^).top,
                            trect(buffer.buffer^).right,
                            trect(buffer.buffer^).bottom,
                            xstart,ystart,xend,yend);
  if bo1 then begin
   checkgc2(gc);
   windows.arc(gc.handle,trect(buffer.buffer^).Left,
                             trect(buffer.buffer^).top,
                             trect(buffer.buffer^).right,
                             trect(buffer.buffer^).bottom,
                             xstart,ystart,xend,yend);
  end;
 end;
end;

procedure gdi_drawstring16(var drawinfo: drawinfoty);
begin
 with drawinfo do begin
  updateopaquemode(gc);
  with gc,drawinfo.text16pos do begin
   windows.textoutw(handle,pos^.x + origin.x,pos^.y + origin.y,text,count);
  end;
 end;
end;

function winmousekeyflagstoshiftstate(keys: longword): shiftstatesty;
begin
 result:= [];
 if keys and mk_control <> 0 then begin
  include(result,ss_ctrl);
 end;
 if keys and mk_lbutton <> 0 then begin
  include(result,ss_left);
 end;
 if keys and mk_mbutton <> 0 then begin
  include(result,ss_middle);
 end;
 if keys and mk_rbutton <> 0 then begin
  include(result,ss_right);
 end;
 if keys and mk_shift <> 0 then begin
  include(result,ss_shift);
 end;
 if getkeystate(vk_menu) < 0 then begin
  include(result,ss_alt);
 end;
end;

function shiftstatetowinmousekeyflags(shiftstate: shiftstatesty): longword;
begin
 result:= 0;
 if ss_ctrl in shiftstate then begin
  result:= result or mk_control;
 end;
 if ss_left in shiftstate then begin
  result:= result or mk_lbutton;
 end;
 if ss_middle in shiftstate then begin
  result:= result or mk_mbutton;
 end;
 if ss_right in shiftstate then begin
  result:= result or mk_rbutton;
 end;
 if ss_shift in shiftstate then begin
  result:= result or mk_shift;
 end;
end;

function winmousepostopoint(pos: longword): pointty;
begin
 result.x:= smallint(loword(pos));
 result.y:= smallint(hiword(pos));
end;

function pointtowinmousepos(pos: pointty): longword;
begin
 result:= word(pos.x) + (word(pos.y) shl 16);
end;

function winkeytokey(key: longword; lparam: longword;
                                       var shift: shiftstatesty): keyty;
var
 second: boolean;
begin
 second:= mapvirtualkey(key,mapvk_vk_to_vsc) <> (lparam shr 16) and $ff;

 case key of
  vk_back: result:= key_backspace;
  vk_tab: begin
   if ss_shift in shift then begin
    result:= key_backtab;
   end
   else begin
    result:= key_tab;
   end;
  end;
  vk_clear: result:= key_clear;
  vk_return: result:= key_return;
  vk_shift: begin
   result:= key_shift;
   if second then begin
    include(shiftstate,ss_second);
   end;
  end;
  vk_control: begin
   result:= key_control;
   if second then begin
    include(shiftstate,ss_second);
   end;
  end;
  vk_menu: begin
   result:= key_alt;
   if second then begin
    include(shiftstate,ss_second);
   end;
  end;
  vk_pause: result:= key_pause;
  vk_capital: result:= key_capslock;
  vk_escape: result:= key_escape;
  vk_space: result:= key_space;
  vk_prior: result:= key_pageup;
  vk_next: result:= key_pagedown;
  vk_end: result:= key_end;
  vk_home: result:= key_home;
  vk_left: result:= key_left;
  vk_up: result:= key_up;
  vk_right: result:= key_right;
  vk_down: result:= key_down;
 //  vk_select: result:= key_select;
  vk_execute: result:= key_sysreq;
  vk_snapshot: result:= key_print;
  vk_insert: result:= key_insert;
  vk_delete: result:= key_delete;
  vk_help: result:= key_help;
  longword('0')..longword('9'): result:= keyty(key);
  longword('A')..longword('Z'): result:= keyty(key);
  vk_lwin: result:= key_super;
  vk_rwin: begin
   result:= key_super;
   include(shiftstate,ss_second);
  end;
  vk_apps: result:= key_menu;
  vk_oem_plus: result:= key_plus;
  vk_oem_comma: result:= key_comma;
  vk_oem_minus: result:= key_minus;
  vk_oem_period: result:= key_period;
  vk_numpad0..vk_numpad9: begin
   result:= keyty(longword(key_0) + key - vk_numpad0);
   include(shiftstate,ss_second);
  end;
  vk_add: begin
   result:= key_plus;
   include(shiftstate,ss_second);
  end;
  vk_separator: begin
   result:= key_comma;
   include(shiftstate,ss_second);
  end;
  vk_subtract: begin
   result:= key_minus;
   include(shiftstate,ss_second);
  end;
  vk_decimal: begin
   result:= key_decimal;
   include(shiftstate,ss_second);
  end;
  vk_multiply: begin
   result:= key_asterisk;
   include(shiftstate,ss_second);
  end;
  vk_divide: begin
   result:= key_slash;
   include(shiftstate,ss_second);
  end;
  vk_f1..vk_f24: result:= keyty(longword(key_f1) + key - vk_f1);
  vk_numlock: result:= key_numlock;
  vk_scroll: result:= key_scrolllock;

  else begin
   result:= key_unknown;
  end;
 end;
end;

function winkeystatetoshiftstate(keystate: longword): shiftstatesty;
begin
 result:= [];
 if $20000000 and keystate <> 0 then begin
  include(result,ss_alt);
 end;
 if getkeystate(vk_shift) < 0 then begin
  include(result,ss_shift);
 end;
 if getkeystate(vk_control) < 0 then begin
  include(result,ss_ctrl);
 end;
 if getkeystate(vk_lbutton) < 0 then begin
  include(result,ss_left);
 end;
 if getkeystate(vk_mbutton) < 0 then begin
  include(result,ss_middle);
 end;
 if getkeystate(vk_rbutton) < 0 then begin
  include(result,ss_right);
 end;
end;

function wheelkeystatetoshiftstate(keystate: longword): shiftstatesty;
var
 wo1: word;
begin
 result:= [];
 wo1:= loword(keystate);
 if mk_control and wo1 <> 0 then begin
  include(result,ss_ctrl);
 end;
 if mk_lbutton and wo1 <> 0 then begin
  include(result,ss_left);
 end;
 if mk_mbutton and wo1 <> 0 then begin
  include(result,ss_middle);
 end;
 if mk_rbutton and wo1 <> 0 then begin
  include(result,ss_right);
 end;
 if mk_shift and wo1 <> 0 then begin
  include(result,ss_shift);
 end;
 if getkeystate(vk_menu) < 0 then begin
  include(result,ss_alt);
 end;
end;

function windowvisible(handle: hwnd): boolean;
var
 rect1: trect;
begin
 windows.getclientrect(handle,rect1);
 result:= iswindowvisible(handle) and
  not ((rect1.Left = 0) and (rect1.Top = 0)
                              and (rect1.Bottom = 0) and (rect1.Right = 0)) and
      (gui_getwindowsize(handle) <> wsi_minimized);
end;

procedure checkmousewindow(window: hwnd; const pos: pointty); forward;

procedure mouseidleproc(ahwnd: hwnd; uMsg: longword; idEvent: longword;
          dwTime: longword); stdcall;
var
 po1: tpoint;
 win1: hwnd;
begin
 windows.KillTimer(0,mouseidletimer);
 mouseidletimer:= 0;
 if mousewindow <> 0 then begin
  if windows.GetCursorPos(po1) then begin
   win1:= windowfrompoint(po1);
   if (win1 <> mousewindow) and (getparent(win1) <> mousewindow) then begin
    eventlist.add(twindowevent.create(ek_leavewindow,mousewindow));
   end
   else begin
    if windows.screentoclient(mousewindow,po1) then begin
     checkmousewindow(mousewindow,pointty(po1));
    end;
   end;
  end;
 end;
end;

procedure killmouseidletimer(restart: boolean = false);
begin
 if mouseidletimer <> 0 then begin
  windows.KillTimer(0,mouseidletimer);
 end;
 if restart then begin
  mouseidletimer:= windows.settimer(0,0,mouseidletime,@mouseidleproc);
 end
 else begin
  mouseidletimer:= 0;
 end;
end;

procedure checkmousewindow(window: hwnd; const pos: pointty);
var
 rect1: trect;
begin
 killmouseidletimer(true);
 if (window <> 0) then begin
  windows.getclientrect(window,rect1);
  if (pos.x < 0) or (pos.x >= rect1.Right) or (pos.y < 0) or
            (pos.y > rect1.Bottom) then begin
   window:= 0;
  end
 end;
 if mousewindow <> window then begin
  if mousewindow <> 0 then begin
   eventlist.add(twindowevent.create(ek_leavewindow,mousewindow));
  end;
  if window <> 0 then begin
   eventlist.add(twindowevent.create(ek_enterwindow,window));
  end;
  mousewindow:= window;
 end
 else begin
  if mousecursor <> 0 then begin
   windows.SetCursor(mousecursor); //possible missed et_exitwindow
  end;
 end;
end;

function gui_movewindowrect(id: winidty; const dist: pointty; const rect: rectty): guierrorty;
var
 rect1,rect2: rectty;
begin
 rect1:= rect;
 recttowinrect(rect1);
 if iswin95 then begin
  rect2.x:= -32000;      //trect
  rect2.y:= -32000;
  rect2.cx:= 32000;
  rect2.cy:= 32000;
 end
 else begin
  rect2.x:= -100000;      //trect
  rect2.y:= -100000;
  rect2.cx:= 100000;
  rect2.cy:= 100000;
 end;
 {$ifdef FPC}
 winscrollwindowex(id,dist.x,dist.y,@rect1,@rect2,0,nil,sw_invalidate);
 {$else}
 scrollwindowex(id,dist.x,dist.y,@rect1,@rect2,0,nil,sw_invalidate);
 {$endif}
 result:= gue_ok;
end;

procedure getframe(const outerrect,innerrect: trect; out frame: framety);
var
 int1: integer;
begin
 int1:= (outerrect.Right - outerrect.Left - innerrect.Right +
               innerrect.left) div 2; //i hope so
 with frame do begin
  left:= int1;
  bottom:= int1;
  right:= int1;
  top:= outerrect.Bottom - outerrect.top -
       innerrect.Bottom + innerrect.Top - int1;
 end;
end;

function getclientrect(hwnd: hwnd; windowrect: prectty = nil): rectty;
                     //screen origin
var
 rect1,rect2: trect;
 frame: framety;
begin
 if windows.GetWindowRect(hwnd,rect1) then begin
  if windows.getclientrect(hwnd,rect2) then begin
   getframe(rect1,rect2,frame);
   if windowrect = nil then begin
    result.x:= rect1.left + frame.left;
    result.y:= rect1.top + frame.top;
    result.size:= sizety(rect2.BottomRight);
   end
   else begin
    with windowrect^ do begin
     result.x:= x + frame.left;
     result.y:= y + frame.top;
     result.cx:= cx - frame.left - frame.right;
     result.cy:= cy - frame.top - frame.bottom;
    end;
   end;
  end
  else begin
   result:= nullrect;
  end;
 end
 else begin
  result:= nullrect;
 end;
end;

procedure getwindowrectpa(id: winidty; out rect: rectty; out origin: pointty);
             //parent origin
var
 rect1: rectty;
 win1: winidty;
begin
 rect:= getclientrect(id);
 win1:= getancestor(id,ga_parent);
 if win1 <> 0 then begin
  origin:= getclientrect(win1).pos;
  subpoint1(rect.pos,origin);
 end
 else begin
  origin:= nullpoint;
 end;
end;

function gui_getwindowrect(id: winidty; out rect: rectty): guierrorty;
            //screen origin
begin
 rect:= getclientrect(id);
 result:= gue_ok;
end;

function gui_getwindowpos(id: winidty; out pos: pointty): guierrorty;
var
 rect1: trect;
begin
 result:= gue_error;
 if windows.GetWindowRect(id,rect1) then begin
  pos.x:= rect1.left;
  pos.y:= rect1.top;
  result:= gue_ok;
 end;
end;

function gui_reposwindow(id: winidty; const rect: rectty): guierrorty;
var
 rect1,rect2: trect;
 arect: rectty;
 frame: framety;
begin
 result:= gue_resizewindow;
 if windows.getwindowrect(id,rect1) then begin
  if windows.GetclientRect(id,rect2) then begin
   getframe(rect1,rect2,frame);
   arect:= inflaterect(rect,frame);
   if windows.SetWindowPos(id,0,arect.x,arect.y,arect.cx,arect.cy,
                swp_nozorder or swp_noactivate) then begin
    result:= gue_ok;
   end;
  end;
 end;
end;

function gui_getdecoratedwindowrect(id: winidty; out arect: rectty): guierrorty;
begin
 if windows.getwindowrect(id,trect(arect)) then begin
  winrecttorect(arect);
  result:= gue_ok;
 end
 else begin
  result:= gue_error;
 end;
end;

function gui_setdecoratedwindowrect(id: winidty; const rect: rectty; 
                                    out clientrect: rectty): guierrorty;
var
 rect1: rectty;
begin
 result:= gue_resizewindow;
 clientrect:= rect;
 if windows.SetWindowPos(id,0,rect.x,rect.y,rect.cx,rect.cy,
               swp_nozorder or swp_noactivate) then begin
  clientrect:= getclientrect(id);
  result:= gue_ok;
 end
end;

function gui_setembeddedwindowrect(id: winidty; const rect: rectty): guierrorty;
begin
 result:= gue_resizewindow;
 if windows.SetWindowPos(id,0,rect.x,rect.y,rect.cx,rect.cy,
               swp_nozorder or swp_noactivate) then begin
  result:= gue_ok;
 end
end;

var
 mousewheelpos: integer;
 sizingwindow: hwnd;
 eventlooping: integer;
 escapepressed: boolean;
 
procedure gui_wakeup;
begin
 windows.postmessage(applicationwindow,wakeupmessage,0,0);
// windows.postthreadmessage(mainthread,wakeupmessage,0,0);
end;

function gui_postevent(event: tmseevent): guierrorty;
//var
// int1: integer;
begin
 if windows.postmessage(applicationwindow,msemessage,longword(event),0) then begin
  result:= gue_ok;
 end
 else begin
  result:= gue_postevent;
 end;
{
 if eventlooping > 0 then begin
  result:= gue_ok;
  eventlist.add(event); //threadmessages are lost while window sizing
 end
 else begin
  result:= gue_postevent;
  for int1:= 0 to 15 do begin
   if windows.postthreadmessage(mainthread,msemessage,longword(event),0) then begin
    result:= gue_ok;
    break;
   end;
   sys_threadschedyield;
  end;
 end;
 }
end;

function gui_escapepressed: boolean;
begin
 result:= escapepressed;
end;

procedure gui_resetescapepressed;
begin
 escapepressed:= false;
end;

function WindowProc(ahWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;

 function checkbutton(const amessage: UINT): mousebuttonty;
 begin
  result:= mb_none;
  case amessage of
   wm_lbuttondown,wm_lbuttonup: result:= mb_left;
   wm_mbuttondown,wm_mbuttonup: result:= mb_middle;
   wm_rbuttondown,wm_rbuttonup: result:= mb_right;
  end;
 end;
 
 procedure inittraycallback(const reposition: boolean; out cursorpos: pointty;
                            out shiftstate: uint);
 var
  rect1: rectty;
  pt1: pointty;
 begin
  shiftstate:= 0;
  if getkeystate(vk_control) < 0 then begin
   shiftstate:= shiftstate or mk_control;
  end;
  if getkeystate(vk_shift) < 0 then begin
   shiftstate:= shiftstate or mk_shift;
  end;
  if getkeystate(vk_lbutton) < 0 then begin
   shiftstate:= shiftstate or mk_lbutton;
  end;
  if getkeystate(vk_mbutton) < 0 then begin
   shiftstate:= shiftstate or mk_mbutton;
  end;
  if getkeystate(vk_rbutton) < 0 then begin
   shiftstate:= shiftstate or mk_rbutton;
  end;
  
  windows.getcursorpos(tpoint(pt1));
  gui_getwindowrect(ahwnd,rect1);
  cursorpos.x:= rect1.cx div 2;
  cursorpos.y:= rect1.cy div 2;
  if reposition then begin
   gui_reposwindow(ahwnd,makerect(pt1.x-cursorpos.x,pt1.y-cursorpos.y,
                                                           rect1.cx,rect1.cy));
//   setforegroundwindow(applicationwindow);
  end;
 end;

const
 wheelstep = 120;
var
 rect1,rect2,rect3: rectty;
 pt1,pt2: pointty;
 size1: sizety;
 button: mousebuttonty;
 key1: keyty;
 str1: string;
 int1: integer;
 bo1: boolean;
 sysevent: syseventty;
 shiftstate1: uint;
 imc: himc;
 imminfo: compositionform;
 
begin
 if application.ismainthread then begin
  sysevent.hwnd:= ahwnd;
  sysevent.umsg:= msg;
  sysevent.wparam:= wparam;
  sysevent.lparam:= lparam;
  sysevent.lresult:= 0;
  bo1:= false;
  tapplication1(application).sysevent(ahwnd,sysevent,bo1);
  if bo1 then begin
   result:= sysevent.lresult;
   exit;
  end;
 end;
 result:= 1;
 case msg of
  msemessage: begin
   eventlist.add(tmseevent(wparam));
   exit;
  end;
  wakeupmessage: begin
   eventlist.add(nil);
   exit;
  end;
  timermessage: begin
   eventlist.add(tmseevent.create(ek_timer));
   exit;
  end;
  traycallbackmessage: begin
   case lparam and $ffff of
    wm_lbuttondown,wm_mbuttondown,wm_rbuttondown: begin
     inittraycallback(true,pt1,shiftstate1);
     windowproc(ahwnd,lparam and $ffff,shiftstate1,pointtowinmousepos(pt1));
    end;
    wm_lbuttonup,wm_mbuttonup,wm_rbuttonup: begin
     inittraycallback(true,pt1,shiftstate1);
     windowproc(ahwnd,lparam and $ffff,shiftstate1,pointtowinmousepos(pt1));
    end;
   end;
  end;     
  wm_ime_char: begin
   if iswin95 then begin
    str1:= char(wparam);
    if wparam and $ff00 <> 0 then begin
     str1:= char(wparam shr 8) + str1;
    end;
    charbuffer:= charbuffer + str1;    
   end
   else begin
    charbuffer:= charbuffer + ucs4tostring(wparam);
   end;
   eventlist.add(tkeyevent.create(ahwnd,false,key_none,key_none,shiftstate,
                                    charbuffer,timestamp));
   charbuffer:= '';
  end;
  wm_close: begin
   if ahwnd = applicationwindow then begin
    eventlist.add(tmseevent.create(ek_terminate));
   end
   else begin
    eventlist.add(twindowevent.create(ek_close,ahwnd));
    result:= 0;
   end;
   exit;
  end;
  wm_queryendsession: begin
   canshutdown:= 1;
   eventlist.add(tmseevent.create(ek_terminate));
   tapplication1(application).eventloop;
   result:= canshutdown;
   exit;
  end;
  wm_destroy: begin
  {$ifdef mse_debugwindowfocus}
   debugwindow('wm_destroy ',ahwnd);
  {$endif}
   windowdestroyed(ahwnd);
   eventlist.add(twindowevent.create(ek_destroy,ahwnd));
  end;
  wm_setfocus: begin
   if (ahwnd = applicationwindow) and (lastfocuswindow <> 0) then begin
   {$ifdef mse_debugwindowfocus}
    debugwindow('wm_setfocus applicationwindow ',ahwnd);
   {$endif}
    if windowvisible(lastfocuswindow) then begin
     setfocus(lastfocuswindow);
    end
    else begin
     if application.activewindow <> nil then begin
      setfocus(application.activewindow.winid);
     end
     else begin
      if application.mainwindow <> nil then begin
       setfocus(application.mainwindow.winid);
      end;
     end;
    end;
   end
   else begin
    if windowvisible(ahwnd) then begin
    {$ifdef mse_debugwindowfocus}
     debugwindow('wm_setfocus ',ahwnd);
    {$endif}
     lastfocuswindow:= ahwnd;
     eventlist.add(twindowevent.create(ek_focusin,ahwnd));
    end{$ifndef mse_debugwindowfocus};{$endif}
  {$ifdef mse_debugwindowfocus}
    else begin
     debugwindow('wm_setfocus invisible ',ahwnd);
    end;
  {$endif}
   end;
  end;
  wm_killfocus: begin
  {$ifdef mse_debugwindowfocus}
   debugwindow('wm_killfocus ',ahwnd);
  {$endif}
   eventlist.add(twindowevent.create(ek_focusout,ahwnd));
  end;
  wm_paint: begin
   if getupdaterect(ahwnd,trect(rect1),false) then begin
    winrecttorect(rect1);
    eventlist.add(twindowrectevent.create(ek_expose,ahwnd,rect1,nullpoint));
//    exit;
   end;
  end;
  wm_entersizemove: begin
   sizingwindow:= ahwnd;
  end;
  wm_exitsizemove: begin
   sizingwindow:= 0;
  end;
  wm_sizing: begin
   rect1:= rectty(prect(lparam)^);
   winrecttorect(rect1);
   rect2:= getclientrect(ahwnd,@rect1);
   rect3:= rect2;
   application.checkwindowrect(ahwnd,rect2);
   size1:= subsize(rect3.size,rect2.size);
   if (wparam = wmsz_topleft) or (wparam = wmsz_left) or
                           (wparam = wmsz_bottomleft) then begin
    inc(rect1.x,size1.cx);
   end;
   dec(rect1.cx,size1.cx);
   if (wparam = wmsz_topleft) or (wparam = wmsz_top) or
                           (wparam = wmsz_topright) then begin
    inc(rect1.y,size1.cy);
   end;
   dec(rect1.cy,size1.cy);
   recttowinrect(rect1);
   rect2:= rectty(prect(lparam)^);
   rectty(prect(lparam)^):= rect1;
   if not rectisequal(rect2,rectty(prect(lparam)^)) then begin
    exit;
   end;
  end;
  wm_move,wm_size: begin
   if gui_getwindowsize(ahwnd) <> wsi_minimized then begin
    getwindowrectpa(ahwnd,rect1,pt1);
    eventlist.add(twindowrectevent.create(ek_configure,ahwnd,
                            rect1,pt1));
   end
   else begin
    eventlist.add(twindowevent.create(ek_hide,ahwnd));
   end;
  end;
  wm_queryopen: begin
   eventlist.add(twindowevent.create(ek_show,ahwnd));
  end;
  wm_windowposchanged: begin
   with pwindowpos(lparam)^ do begin
    if swp_hidewindow and flags <> 0 then begin
     eventlist.add(twindowevent.create(ek_hide,ahwnd));
    end;
    if (swp_showwindow and flags <> 0) and (gui_getwindowsize(ahwnd) <> wsi_minimized) then begin
     eventlist.add(twindowevent.create(ek_show,ahwnd));
    end;
    if ((swp_nomove or swp_nosize) and flags <> (swp_nomove or swp_nosize)) and
            windowvisible(ahwnd) then begin
     getwindowrectpa(ahwnd,rect1,pt1); 
     eventlist.add(twindowrectevent.create(ek_configure,ahwnd,rect1,pt1));
      result:= 0;
      exit;
    end;
   end;
  end;
  wm_mousewheel: begin
   if mousewindow <> 0 then begin
    shiftstate:= wheelkeystatetoshiftstate(wparam);
    pt1:= winmousepostopoint(lparam);
    subpoint1(pt1,getclientrect(mousewindow).pos);
    inc(mousewheelpos,smallint(hiword(wparam)));
    while mousewheelpos >= wheelstep do begin
    eventlist.add(tmouseevent.create(mousewindow,false,mb_none,mw_up,pt1,
            winmousekeyflagstoshiftstate(wparam),timestamp));
     dec(mousewheelpos,wheelstep);
    end;
    while mousewheelpos <= -wheelstep do begin
     eventlist.add(tmouseevent.create(mousewindow,false,mb_none,mw_down,pt1,
            winmousekeyflagstoshiftstate(wparam),timestamp));
     inc(mousewheelpos,wheelstep);
    end;
    result:= 0;
    exit;
   end;
  end;
  wm_mousemove,
  wm_lbuttondown,wm_mbuttondown,wm_rbuttondown,
  wm_lbuttonup,wm_mbuttonup,wm_rbuttonup: begin
   pt1:= winmousepostopoint(lparam);
   checkmousewindow(ahwnd,pt1);
   button:= checkbutton(msg);
   eventlist.add(tmouseevent.create(ahwnd,
        (msg = wm_lbuttonup) or (msg = wm_mbuttonup) or (msg = wm_rbuttonup),
         button,mw_none,pt1,
           winmousekeyflagstoshiftstate(wparam),timestamp));
   result:= 0;
   exit;
  end;
  wm_keydown,wm_syskeydown: begin
   shiftstate:= winkeystatetoshiftstate(lparam);
   if lparam and $40000000 <> 0 then begin
    include(shiftstate,ss_repeat);
   end;
   key1:= winkeytokey(wparam,lparam,shiftstate);
   if key1 = key_escape then begin
    escapepressed:= true;
   end;
   eventlist.add(tkeyevent.create(ahwnd,false,key1,key1,shiftstate,
                                    charbuffer,timestamp));
   charbuffer:= '';
  end;
  wm_keyup,wm_syskeyup: begin
   shiftstate:= winkeystatetoshiftstate(lparam);
   key1:= winkeytokey(wparam,lparam,shiftstate);
   if charbuffer <> '' then begin
    eventlist.add(tkeyevent.create(ahwnd,false,key_none,key_none,shiftstate,
                                    charbuffer,timestamp));
    charbuffer:= '';
   end;
   eventlist.add(tkeyevent.create(ahwnd,true,key1,key1,shiftstate,'',timestamp));
  end;
  wm_ime_startcomposition: begin
   if hasimm32 and (application.activewidget <> nil) and 
                            application.activewidget.hascaret then begin
    imc:= immgetcontext(ahwnd);
    fillchar(imminfo,sizeof(imminfo),0);
    with imminfo,application do begin
     dwstyle:= cfs_point;
     ptcurrentpos.x:= caret.pos.x + caret.origin.x;
     ptcurrentpos.y:= caret.pos.y + caret.origin.y{ + caret.size.cy};
//     ptcurrentpos.x:= caret.pos.x + activewidget.rootpos.x;
//     ptcurrentpos.y:= activewidget.rootpos.y + activewidget.bounds_cy;
     immsetcompositionwindow(imc,@imminfo);
    end;
    immreleasecontext(ahwnd,imc);
   end;
  end;
 end;
 if iswin95 then begin
  result:= defwindowproca(ahwnd,msg,wparam,lparam);
 end
 else begin
  result:= defwindowprocw(ahwnd,msg,wparam,lparam);
 end;
 if ahwnd = sizingwindow then begin
  inc(eventlooping);
  try
   tapplication1(application).eventloop(true);
  finally
   dec(eventlooping);
  end;
 end;
end;

function childWindowProc(ahWnd: HWND; Msg: UINT; wParam: WPARAM;
            lParam: LPARAM): LRESULT; stdcall;
var
 parent: hwnd;
 pt1: pointty;
 rect1: trect;
 rect2: rectty;
begin
 parent:= getparent(ahwnd);
 case msg of
  wm_destroy: begin
   windowdestroyed(ahwnd);
   eventlist.add(twindowevent.create(ek_destroy,ahwnd));
  end;
  wm_mousemove,
  wm_lbuttondown,wm_mbuttondown,wm_rbuttondown,
  wm_lbuttonup,wm_mbuttonup,wm_rbuttonup,
  wm_mousewheel: begin
   getwindowrect(ahwnd,rect1);
   rect2:= getclientrect(parent);
   pt1.x:= rect1.left - rect2.x;
   pt1.y:= rect1.top - rect2.y;
   pt1:= addpoint(winmousepostopoint(lparam),pt1);
   result:= windowproc(parent,msg,wparam,pointtowinmousepos(pt1));
   exit;
  end;
 end;
 if iswin95 then begin
  result:= defwindowproca(ahwnd,msg,wparam,lparam);
 end
 else begin
  result:= defwindowprocw(ahwnd,msg,wparam,lparam);
 end;
end;

procedure dispatchevents;
var
 msg,msg1: tmsg;
 str1: string;
begin
 if eventlooping > 0 then begin
  exit;
 end;
 if iswin95 then begin
  while peekmessagea(msg,0,0,0,pm_remove) do begin
   with msg do begin
    case message of
     destroymessage: begin
      windows.destroywindow(msg.wparam);
     end;
     wm_keydown,wm_keyup,wm_syskeydown,wm_syskeyup: begin
      translatemessage(msg);
      str1:= '';
      while peekmessagea(msg1,msg.hwnd,wm_char,wm_char,pm_remove) do begin
       str1:= str1 + char(msg1.wparam);
      end;
      while peekmessagea(msg1,msg.hwnd,wm_syschar,wm_syschar,pm_remove) do begin
       str1:= str1 + char(msg1.wparam);
      end;
      charbuffer:= charbuffer + str1;
      dispatchmessagea(msg);
     end
     else begin
      dispatchmessagea(msg);
     end;
    end;
   end;
  end;
 end
 else begin
  while peekmessagew(msg,0,0,0,pm_remove) do begin
   with msg do begin
    case message of
     destroymessage: begin
      windows.destroywindow(msg.wparam);
     end;
     wm_keydown,wm_keyup,wm_syskeydown,wm_syskeyup: begin
      translatemessage(msg);
      while peekmessagew(msg1,msg.hwnd,wm_char,wm_char,pm_remove) do begin
       charbuffer:= charbuffer + msechar(msg1.wparam);
      end;
      while peekmessagew(msg1,msg.hwnd,wm_syschar,wm_syschar,pm_remove) do begin
       charbuffer:= charbuffer + msechar(msg1.wparam);
      end;
      dispatchmessagew(msg);
     end
     else begin
      dispatchmessagew(msg);
     end;
    end;
   end;
  end;
 end;
end;

function gui_hasevent: boolean;
begin
 dispatchevents;
 result:= eventlist.count > 0;
end;

function gui_getevent: tmseevent;
begin
 result:= nil;
 while true do begin
  dispatchevents;
  if eventlist.count > 0 then begin
   result:= tmseevent(eventlist.getfirst);
   break;
  end
  else begin
   if not application.unlock then begin
    guierror(gue_notlocked);
   end;
   windows.waitmessage;
   application.lock;
  end;
 end;
end;

function createapphandle(out id: winidty): guierrorty;
var
 str1: string;
 menu1: hmenu;
begin
 str1:= application.applicationname;
 id:= windows.CreateWindow(widgetclassname,pchar(str1),
             WS_POPUP or WS_CAPTION or WS_CLIPSIBLINGS or 
             WS_SYSMENU or WS_MINIMIZEBOX,0,0,0,0,0,0,hinstance,nil);
 menu1:= getsystemmenu(id,false);
 deletemenu(menu1,sc_maximize,mf_bycommand);
 deletemenu(menu1,sc_size,mf_bycommand);
 deletemenu(menu1,sc_move,mf_bycommand);
 showwindow(id,sw_shownoactivate);
  
// id:= windows.CreateWindowex(ws_ex_appwindow,widgetclassname,pchar(str1),
//        ws_overlappedwindow,0,0,0,0,0,0,hinstance,nil);
 if id = 0 then begin
  result:= gue_createwindow;
 end
 else begin
  result:= gue_ok;
 end;
end;

function gui_settransientfor(id: winidty; transientfor: winidty): guierrorty;
begin
 setwindowlong(id,gwl_hwndparent,transientfor);
 result:= gue_ok;
end;

function gui_windowatpos(const pos: pointty): winidty;
begin
 result:= windowfrompoint(tpoint(pos));
end;

function gui_setsizeconstraints(id: winidty; const min,max: sizety): guierrorty;
begin
 result:= gue_ok; //nothing to do on win32
end;

function gui_setwindowgroup(id: winidty; group: winidty): guierrorty;
begin
 result:= gue_ok;
end;

function gui_createwindow(const rect: rectty; const options: internalwindowoptionsty;
                             var awindow: windowty): guierrorty;
var
 windowstyle,windowstyleex,ca2: longword;
 rect1: rectty;
 classname: string;
 ownerwindow: winidty;
begin
 with awindow,options do begin
  ownerwindow:= applicationwindow;
  windowstyleex:= 0;
  if wo_popup in options then begin
   windowstyle:= ws_popup;
//   windowstyleex:= windowstyleex or ws_ex_toolwindow;
  end
  else begin
   if wo_message in options then begin
    windowstyle:= ws_overlappedwindow;
    windowstyleex:= windowstyleex or ws_ex_toolwindow;
   end
   else begin
    windowstyle:= ws_overlappedwindow;
    if wo_taskbar in options then begin
     windowstyleex:= windowstyleex or ws_ex_appwindow;
     showwindow(applicationwindow,sw_hide);
     ownerwindow:= 0;
    end;
   end;
   if wo_embedded in options then begin
    windowstyle:= ws_child;
   end;
  end;
  if pos = wp_default then begin
   rect1.x:= integer(cw_usedefault);
   rect1.y:= integer(cw_usedefault);
   rect1.cx:= integer(cw_usedefault);
   rect1.cy:= integer(cw_usedefault);
  end
  else begin
   rect1:= rect;
  end;
  windowstyle:= windowstyle or ws_clipchildren;
  if (transientfor <> 0) or (options * [wo_popup,wo_message,wo_notaskbar] <> []) then begin
   if transientfor <> 0 then begin
    ownerwindow:= transientfor;
   end;
   id:= windows.CreateWindowex(windowstyleex,widgetclassname,nil,windowstyle,
         rect1.x,rect1.y,rect1.cx,rect1.cy,ownerwindow{transientfor},0,hinstance,nil);
   if transientfor = 0 then begin
    setwindowpos(id,hwnd_top,0,0,0,0,swp_noactivate or swp_nomove or 
                                            swp_nosize or swp_noownerzorder);
   end;
  end
  else begin
   if parent <> 0 then begin
    ca2:= parent;
    windowstyle:= ws_child;
    classname:= childwidgetclassname;
   end
   else begin
    ca2:= ownerwindow;
    classname:= widgetclassname;
   end;
   id:= windows.CreateWindowex(windowstyleex,pchar(classname),nil,
         windowstyle,rect1.x,rect1.y,rect1.cx,rect1.cy,ca2,0,hinstance,nil);
   if setgroup and (groupleader = 0) or (wo_groupleader in options) then begin
    groupleaderwindow:= id;
   end;
  end;
  if id = 0 then begin
   result:= gue_createwindow;
  end
  else begin
{$ifdef mse_debuggdi}
   inc(windowcount);
{$endif}
   if not (pos = wp_default) and (parent = 0) then begin
    result:= gui_reposwindow(id,rect);
   end
   else begin
    result:= gue_ok;
   end;
  end;
  if icon <> 0 then begin
   gui_setwindowicon(id,icon,iconmask);
   if (groupleaderwindow = id) then begin
    gui_setwindowicon(applicationwindow,icon,iconmask);
   end;
  end;
 end;
end;

function gui_getparentwindow(const awindow: winidty): winidty;
begin
// result:= getparent(awindow);
 result:= getancestor(awindow,ga_parent);
end;

function gui_reparentwindow(const child: winidty; const parent: winidty;
                            const pos: pointty): guierrorty;
var
 rect1: rectty;
begin
 result:= gue_reparent;
 if setparent(child,parent) <> 0 then begin
  if parent = 0 then begin
   result:= gui_getwindowrect(child,rect1);
   if result = gue_ok then begin
    rect1.pos:= pos;
    result:= gui_reposwindow(child,rect1);
   end;
  end
  else begin
   if setwindowpos(child,0,pos.x,pos.y,0,0,swp_nosize or swp_nozorder or
                               swp_noownerzorder or swp_noactivate) then begin
    result:= gue_ok;
   end;
  end;
 end;
end;

type
 enumchildinfoty = record
  childlist: winidarty;
  count: integer;
  parent: winidty;
 end;
 penumchildinfoty = ^enumchildinfoty;

function getchildren(child: hwnd; data: lparam): winbool; stdcall;
begin
 with penumchildinfoty(data)^ do begin
  if gui_getparentwindow(child) = parent then begin
   additem(childlist,child,count);
  end;
 end;
 result:= true;
end;

function gui_getchildren(const id: winidty; out children: winidarty): guierrorty;
var
 info: enumchildinfoty;
begin
 fillchar(info,sizeof(info),0);
 with info do begin
  parent:= id;
  enumchildwindows(id,@getchildren,ptruint(@info));
  setlength(childlist,count);
  children:= childlist;
 end;
 result:= gue_ok;
end;

function gui_setmainthread: guierrorty; //set mainthread to currentthread
begin
 mainthread:= getcurrentthreadid;
 result:= gue_ok;
end;

function gui_getscreenrect(const id: winidty): rectty; //0 -> virtual screen
var
 info: tmonitorinfo;
begin
 info.cbsize:= sizeof(info);
 if (id = 0) or not getmonitorinfo(monitorfromwindow(id,monitor_defaulttonearest),
                                                       @info) then begin
  result.x:= getsystemmetrics(sm_xvirtualscreen);
  result.y:= getsystemmetrics(sm_yvirtualscreen);
  result.cx:= getsystemmetrics(sm_cxvirtualscreen);
  result.cy:= getsystemmetrics(sm_cyvirtualscreen);
  if result.cx = 0 then begin
   result.cx:= getsystemmetrics(sm_cxscreen)
  end;
  if result.cy = 0 then begin
   result.cy:= getsystemmetrics(sm_cyscreen)
  end;
 end
 else begin
  result:= rectty(info.rcmonitor);
  winrecttorect(result);
 end;
end;

function gui_getworkarea(id: winidty): rectty;
var
 info: tmonitorinfo;
begin
// if systemparametersinfo(spi_getworkarea,0,@result,0) then begin
 info.cbsize:= sizeof(info);
 if getmonitorinfo(monitorfromwindow(id,monitor_defaulttonearest),
                                                       @info) then begin
  result:= rectty(info.rcwork);
  winrecttorect(result);
 end
 else begin
  result:= nullrect;                            
 end;
end;


const
 NIF_MESSAGE = $00000001;
 NIF_ICON = $00000002;
 NIF_TIP = $00000004;
 NIF_STATE = $00000008;
 NIF_INFO = $00000010;
 NIF_GUID = $00000020;

 NIIF_NONE = $00000000;
 NIIF_INFO = $00000001;
 NIIF_WARNING = $00000002;
 NIIF_ERROR = $00000003;
 NIIF_USER = $00000004;
 NIIF_NOSOUND = $00000010;
 NIIF_LARGE_ICON = $00000010;
 NIIF_RESPECT_QUIET_TIME = $00000080;
 NIIF_ICON_MASK = $0000000F;

 NIM_ADD = $00000000;
 NIM_MODIFY = $00000001;
 NIM_DELETE = $00000002;
 NIM_SETFOCUS = $00000003;
 NIM_SETVERSION = $00000004;

type
 iconunionty = record
  case boolean of
   false: (uTimeout: UINT);
   true: (uVersion: UINT); // Used with Shell_NotifyIcon flag NIM_SETVERSION.
 end;
 NOTIFYICONDATAW_2 = record
  cbSize: DWORD;
  Wnd: HWND;
  uID: UINT;
  uFlags: UINT;
  uCallbackMessage: UINT;
  hIcon: HICON;
  szTip: array [0..127] of widechar;
  dwState: DWORD;
  dwStateMask: DWORD;
  szInfo: array[0..255] of widechar;
  u: iconunionty;
  szInfoTitle: array[0..63] of widechar;
  dwInfoFlags: DWORD;
 end;

function traycommand(var child: windowty; 
                       const command: integer; const flags: integer = 0;
                             const CallbackMessage: UINT = 0;
                             const Icon: HICON = 0;
                             const Tip: msestring = '';
                             const State: DWORD = 0;
                             const StateMask: DWORD = 0;
                             const Info: msestring = '';
                             const Timeout: UINT = 0;
                             const Version: UINT = 0;
                             const InfoTitle: msestring = '';
                             const InfoFlags: DWORD = 0): guierrorty;

// traycommand(child,command,flags,0,0,'',0,0,'',0,0,'',0);

 procedure movestr(const source: msestring; var dest; const acount: integer);
 var
  int1: integer;
 begin
  int1:= length(source);
  if int1 > acount then begin
   int1:= acount;
  end;
  move(source[1],dest,int1*sizeof(widechar));
 end;
 
var
 dataa: notifyicondataa;
 dataw: notifyicondataw_2;
 int1: integer;
begin
 result:= checkshellinterface;
 if result = gue_ok then begin
  result:= gue_notraywindow;
  if iswin95 then begin
  end
  else begin
   fillchar(dataw,sizeof(dataw),0);
   with dataw do begin
    cbsize:= sizeof(dataw);
    wnd:= child.id;
    uflags:= flags;
    uCallbackMessage:= CallbackMessage;
    hIcon:= Icon;
    movestr(tip,szTip,sizeof(szTip));
    dwState:= State;
    dwStateMask:= StateMask;
    movestr(Info,szInfo,256);
    if command = nim_setversion then begin
     u.uVersion:= version;
    end
    else begin
     u.uTimeout:= Timeout;
    end;
    movestr(InfoTitle,szInfoTitle,64);
    dwInfoFlags:= InfoFlags;
   end;
   if shell_notifyiconw(command,@dataw) then begin
    result:= gue_ok;
   end;
  end;
 end;
end;

function docktotray(var child: windowty): guierrorty;
begin
 result:= traycommand(child,nim_add,nif_message,traycallbackmessage);
 if result = gue_ok then begin
  result:= traycommand(child,nim_setversion,0,0,0,'',0,0,'',0,0);
 end;
end;

function undockfromtray(var child: windowty): guierrorty;
begin
 result:= traycommand(child,nim_delete);
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
var
 rect1: rectty;
 pt1: pointty;
begin
 gui_hidewindow(child.id);
 if akind = sywi_none then begin
  result:= undockfromtray(child);
  getwindowrectpa(child.id,rect1,pt1);
  result:= gui_reparentwindow(child.id,0,subpoint(rect1.pos,pt1));
 end
 else begin
  result:= gue_windownotfound;
  case akind of
   sywi_tray: begin
    result:= docktotray(child);
   end;
  end;
 end;
end;
{
function gui_undockfromsyswindow(var child: windowty): guierrorty;
                    //hides window
begin
 gui_hidewindow(child.id);
 result:= undockfromtray(child);
end;
}
function gui_traymessage(var awindow: windowty; const message: msestring;
                          out messageid: longword;
                          const timeoutms: longword = 0): guierrorty;
var
 int1: integer;
begin
 messageid:= 1;
 int1:= timeoutms;
 if timeoutms = 0 then begin
  int1:= bigint;
 end;
 result:= traycommand(awindow,nim_modify,nif_info,0,0,'',0,0,
                                                     message,int1,0,'',0);
end;

function gui_canceltraymessage(var awindow: windowty;
                          const messageid: longword): guierrorty;
begin
 result:= traycommand(awindow,nim_modify,nif_info,0,0,'',0,0,
                                                     '',0,0,'',0);
end;

function gui_settrayicon(var awindow: windowty;
                                     const icon,mask: pixmapty): guierrorty;
var
 ico,ico1: hicon;
begin
 ico:= 0;
 if icon <> 0 then begin
  ico:= composeicon(icon,mask);
  if ico = 0 then begin
   exit;
  end;
 end;
 result:= traycommand(awindow,nim_modify,nif_icon,0,ico);
end;

function gui_settrayhint(var awindow: windowty;
                                     const hint: msestring): guierrorty;
begin
 result:= traycommand(awindow,nim_modify,nif_tip,0,0,hint);
end;

function gui_initcolormap: guierrorty;
begin
 result:= gue_ok; //dummy
end;

function gui_init: guierrorty;
const
 classstyle = cs_owndc;
var
 classinfow: twndclassw;
 classinfoa: twndclassa;
 brushinfo: tlogbrush;

begin
 mousewindow:= 0;
 mousecursor:= 0;
 applicationwindow:= 0;
 fillchar(keystate,sizeof(keystate),0);
 shiftstate:= [];
 charbuffer:= '';
 gui_setmainthread;
 eventlist:= tobjectqueue.create(true);
 desktopwindow:= getdesktopwindow;
 nullpen:= createpen(ps_null,0,0);
 fillchar(brushinfo,sizeof(brushinfo),0);
 brushinfo.lbStyle:= bs_null;
 nullbrush:= createbrushindirect(brushinfo);
 fillchar(classinfoa,sizeof(classinfoa),0);
 if iswin95 then begin
  with classinfoa do begin
   lpszclassname:= childwidgetclassname;
   lpfnwndproc:= @childwindowproc;
   hinstance:= {$ifdef FPC}system{$else}sysinit{$endif}.HInstance;
   style:= classstyle;
   cbwndextra:= wndextrabytes;
  end;
  childwidgetclass:= registerclassa(classinfoa);
  fillchar(classinfoa,sizeof(classinfoa),0);
  with classinfoa do begin
   lpszclassname:= widgetclassname;
   lpfnwndproc:= @windowproc;
   hinstance:= {$ifdef FPC}system{$else}sysinit{$endif}.HInstance;
   style:= classstyle;
   cbwndextra:= wndextrabytes;
  end;
  widgetclass:= registerclassa(classinfoa);
 end
 else begin
  fillchar(classinfow,sizeof(classinfow),0);
  with classinfow do begin
   lpszclassname:= childwidgetclassname;
   lpfnwndproc:= @childwindowproc;
   hinstance:= {$ifdef FPC}system{$else}sysinit{$endif}.HInstance;
   style:= classstyle;
   cbwndextra:= wndextrabytes;
//   hbrbackground:= getstockobject(hollow_brush);
  end;
  childwidgetclass:= registerclassw(classinfow);
  fillchar(classinfow,sizeof(classinfow),0);
  with classinfow do begin
   lpszclassname:= widgetclassname;
   lpfnwndproc:= @windowproc;
   hinstance:= {$ifdef FPC}system{$else}sysinit{$endif}.HInstance;
   style:= classstyle;
   cbwndextra:= wndextrabytes;
  end;
  widgetclass:= registerclassw(classinfow);
 end;
 if widgetclass = 0 then begin
  result:= gue_registerclass;
 end
 else begin
  result:= gue_ok;
 end;
 if applicationallocated then begin
  createapphandle(applicationwindow);
 end;
 systimerinit(eventlist);
end;

function gui_deinit: guierrorty;
var
 acursor: cursorshapety;

begin
 systimerdeinit;
// killtimer;
 killmouseidletimer;
 if applicationwindow <> 0 then begin
  destroywindow(applicationwindow);
  applicationwindow:= 0;
 end;
 freeandnil(eventlist);
 unregisterclass(widgetclassname,hinstance);
 widgetclass:= 0;
 deleteobject(nullpen);
 nullpen:= 0;
 deleteobject(nullbrush);
 nullbrush:= 0;
 result:= gue_ok;
 mainthread:= 0;
 mousewindow:= 0;
 mousecursor:= 0;
 for acursor:= low(acursor) to high(acursor) do begin
  if cursors[acursor] <> 0 then begin
   destroycursor(cursors[acursor]);
   cursors[acursor]:= 0;
  end;
 end;
end;

const
 gdifunctions: gdifunctionaty = (
   {$ifdef FPC}@{$endif}gdi_destroygc,
   {$ifdef FPC}@{$endif}gdi_changegc,
   {$ifdef FPC}@{$endif}gdi_drawlines,
   {$ifdef FPC}@{$endif}gdi_drawlinesegments,
   {$ifdef FPC}@{$endif}gdi_drawellipse,
   {$ifdef FPC}@{$endif}gdi_drawarc,
   {$ifdef FPC}@{$endif}gdi_fillrect,
   {$ifdef FPC}@{$endif}gdi_fillelipse,
   {$ifdef FPC}@{$endif}gdi_fillarc,
   {$ifdef FPC}@{$endif}gdi_fillpolygon,
//   {$ifdef FPC}@{$endif}gdi_drawstring,
   {$ifdef FPC}@{$endif}gdi_drawstring16,
   {$ifdef FPC}@{$endif}gdi_setcliporigin,
   {$ifdef FPC}@{$endif}gdi_createemptyregion,
   {$ifdef FPC}@{$endif}gdi_createrectregion,
   {$ifdef FPC}@{$endif}gdi_createrectsregion,
   {$ifdef FPC}@{$endif}gdi_destroyregion,
   {$ifdef FPC}@{$endif}gdi_copyregion,
   {$ifdef FPC}@{$endif}gdi_moveregion,
   {$ifdef FPC}@{$endif}gdi_regionisempty,
   {$ifdef FPC}@{$endif}gdi_regionclipbox,
   {$ifdef FPC}@{$endif}gdi_regsubrect,
   {$ifdef FPC}@{$endif}gdi_regsubregion,
   {$ifdef FPC}@{$endif}gdi_regaddrect,
   {$ifdef FPC}@{$endif}gdi_regaddregion,
   {$ifdef FPC}@{$endif}gdi_regintersectrect,
   {$ifdef FPC}@{$endif}gdi_regintersectregion,
   {$ifdef FPC}@{$endif}gdi_copyarea,
   {$ifdef FPC}@{$endif}gdi_fonthasglyph,
   {$ifdef FPC}@{$endif}gdi_getfont,
   {$ifdef FPC}@{$endif}gdi_getfonthighres,
   {$ifdef FPC}@{$endif}gdi_freefontdata,
   {$ifdef FPC}@{$endif}gdi_gettext16width,
   {$ifdef FPC}@{$endif}gdi_getchar16widths,
   {$ifdef FPC}@{$endif}gdi_getfontmetrics
);

function gui_getgdifuncs: pgdifunctionaty;
begin
 result:= @gdifunctions;
end;

procedure GUI_DEBUGBEGIN;
begin
// setactivewindow(0);
end;

procedure GUI_DEBUGEND;
begin
end;

procedure initlibs;
begin
 hasimm32:= checkprocaddresses(['Imm32.dll'],
 ['ImmGetContext',
  'ImmReleaseContext',
  'ImmSetCompositionWindow'],
 [{$ifndef FPC}@{$endif}@ImmGetContext,
  {$ifndef FPC}@{$endif}@ImmReleaseContext,
  {$ifndef FPC}@{$endif}@ImmSetCompositionWindow]);
end;

initialization
 initlibs;
 initdefaultfont;
end.
