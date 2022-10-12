{ MSEgui Copyright (c) 1999-2018 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseguiglob;

{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}

interface
uses
 classes,mclasses,msegraphutils,msetypes,msekeyboard,mseerr,mseevent,msestrings,
 mseglob;
{$ifdef FPC}

{$endif}

type
 unicharty = longword;

 originty = (org_screen,org_widget,org_paint,org_client,org_inner);
 captionposty = (cp_center,cp_rightbottom,cp_right,{cp_rightcenter,}cp_righttop,
                 cp_topright,cp_top,{cp_topcenter,}cp_topleft,
                 cp_lefttop,cp_left,{cp_leftcenter,}cp_leftbottom,
                 cp_bottomleft,cp_bottom,{cp_bottomcenter,}cp_bottomright
                 );
const
 rightcaptionpos = [cp_rightbottom,cp_right,{cp_rightcenter,}cp_righttop];
 bottomcaptionpos = [cp_bottomleft,cp_bottom,{cp_bottomcenter,}cp_bottomright];
type
 imageposty = (ip_center,ip_centervert, //ip_center -> ip_centerhorz
                 ip_rightbottom,ip_right,{ip_rightcenter,}ip_righttop,
                 ip_topright,ip_top,{ip_topcenter,}ip_topleft,
                 ip_lefttop,ip_left,{ip_leftcenter,}ip_leftbottom,
                 ip_bottomleft,ip_bottom,{ip_bottomcenter,}ip_bottomright
                 );
const
 horzimagepos = [ip_center,ip_rightbottom,ip_right,{ip_rightcenter,}ip_righttop,
                 ip_lefttop,ip_left,{ip_leftcenter,}ip_leftbottom];
 vertimagepos = [ip_centervert,ip_topright,ip_top,{ip_topcenter,}ip_topleft,
                 ip_bottomleft,ip_bottom,{ip_bottomcenter,}ip_bottomright];
 rightimagepos = [ip_rightbottom,ip_right,ip_righttop];
 bottomimagepos = [ip_bottomleft,ip_bottom,ip_bottomright];
type
 mousebuttonty = (mb_none,mb_left,mb_right,mb_middle);
 mousewheelty = (mw_none,mw_up,mw_down);

 shiftstatety = (ss_none,ss_shift,ss_alt,ss_ctrl,ss_left,ss_right,ss_middle,
                 ss_double,ss_triple,
                 ss_repeat,    //repeat keydown
                 ss_second);   //right modifier keys, numpad
 shiftstatesty = set of shiftstatety;
 clipboardbufferty = (cbb_clipboard,cbb_primary);
const
 keyshiftstatesmask = [ss_shift,ss_alt,ss_ctrl];
 keyshiftstatesrepeatmask = keyshiftstatesmask + [ss_repeat];
 buttonshiftstatesmask = [ss_left,ss_right,ss_middle,ss_double,ss_triple];
 shiftstatesmask = [ss_shift,ss_alt,ss_ctrl,ss_left,ss_right,ss_middle];
 shiftstatesrepeatmask = shiftstatesmask + [ss_repeat];

type
 mouseeventinfoty = record //same layout as mousewheeleventinfoty!
  eventkind: eventkindty;
  shiftstate: shiftstatesty;
  pos: pointty;
  eventstate: eventstatesty;
  timestamp: longword; //usec, 0 -> invalid
  serial: card32; //0 -> invalid
  button: mousebuttonty;
 end;
 pmouseeventinfoty = ^mouseeventinfoty;

 mousewheeleventinfoty = record //same layout as mouseeventinfoty!
  eventkind: eventkindty;
  shiftstate: shiftstatesty;
  pos: pointty;
  eventstate: eventstatesty;
  timestamp: longword; //usec, 0 -> invalid
  serial: card32; //0 -> invalid
  wheel: mousewheelty;
  delta: real;
 end;
 pmousewheeleventinfoty = ^mousewheeleventinfoty;

 moeventinfoty = record
  case integer of
   0: (mouse: mouseeventinfoty);
   1: (wheel: mousewheeleventinfoty);
 end;

 keyeventinfoty = record
  eventkind: eventkindty;
  key,keynomod: keyty;
  chars: msestring;
  shiftstate: shiftstatesty;
  eventstate: eventstatesty;
  timestamp: longword; //usec
  serial: card32; //0 -> invalid
 end;
 pkeyeventinfoty = ^keyeventinfoty;

 stockfontty = (stf_default,     //0 numbers used in tskincontroller
                stf_empty,       //1
                stf_unicode,     //2
                stf_menu,        //3
                stf_message,     //4
                stf_hint,        //5
                stf_report,      //6
                stf_proportional,//7
                stf_fixed,       //8
                stf_helvetica,   //9
                stf_roman,       //10
                stf_courier);    //11
 defaultfontnamesty = array[stockfontty] of string;

type
 windowoptionty = (wo_popup,wo_message,
                   wo_desktop,wo_dock,wo_toolbar,wo_menu,
                   wo_utility,wo_splash,wo_dialog,wo_dropdownmenu,
                   wo_popupmenu,wo_tooltip,wo_notification,wo_combo,
                   wo_dnd,
                   wo_noframe, //uses motif hints on linux
                   wo_noactivate,wo_overrideredirect,
                   wo_embedded,
                   wo_buttonendmodal,
                   wo_groupleader,
                   wo_taskbar,    //win32 only
                   wo_notaskbar,
                   wo_windowcentermessage, //showmessage centered in window
                   wo_sysdnd, //activate system drag and drop (xdnd on Linux)
                   wo_alwaysontop,
                   wo_ellipse,
                   wo_rounded,
                   wo_transparentbackground,
                   wo_transparentbackgroundellipse,
                   wo_transparentbackgroundround, 
                   wo_onalldesktops
                   );
 windowoptionsty = set of windowoptionty;
 windowtypeoptionty = wo_popup..wo_dnd;

const
 windowtypeoptions = [wo_popup,wo_message,
                      wo_desktop,wo_dock,wo_toolbar,wo_menu,
                      wo_utility,wo_splash,wo_dialog,wo_dropdownmenu,
                      wo_popupmenu,wo_tooltip,wo_notification,wo_combo,
                      wo_dnd];
 noframewindowtypes = [wo_popup,wo_splash,wo_dropdownmenu,wo_popupmenu,
                       wo_tooltip,wo_combo,wo_noframe,wo_overrideredirect];
type
 windowposty = (wp_normal,wp_screencentered,wp_screencenteredvirt,
                wp_transientforcentered,wp_mainwindowcentered,
                wp_minimized,wp_maximized,wp_default,
                wp_fullscreen,wp_fullscreenvirt);
 windowsizety = (wsi_normal,wsi_minimized,wsi_maximized,
                 wsi_fullscreen,wsi_fullscreenvirt);
const
 windowmaximizedstates = [wp_maximized,wp_fullscreen,wp_fullscreenvirt];

type
 syswindowty = (sywi_none,sywi_tray);

 paintdevicety = ptruint;
 fontty = ptruint;
 regionty = ptruint;
 pixmapty = ptruint;
 windowpty = array[0..7] of pointer;
 windowty = record
  id: winidty;
  platformdata: windowpty;
 end;
 pwindowty = ^windowty;

 internalwindowoptionspty = array[0..3] of pointer; //buffer

 internalwindowoptionsty = record
  parent: winidty;
  options: windowoptionsty;
  pos: windowposty;
  transientfor: winidty;
  setgroup: boolean;
  groupleader: winidty;
  icon,iconmask: pixmapty;
  platformdata: internalwindowoptionspty;
 end;
 pinternalwindowoptionsty = ^internalwindowoptionsty;

const
 defaultppmm = 3;      //3 pixel per mm
 sizingtol = 2; //+- pixel
 sizingwidth = 2*sizingtol;

const
 captiontoimagepos: array[captionposty] of imageposty = (
               //cp_center,cp_rightbottom,cp_right,
                 ip_center,ip_lefttop,    ip_left,
               //{cp_rightcenter,}cp_righttop,
                 {ip_leftcenter,} ip_leftbottom,
               //cp_topright,  cp_top,   cp_topcenter,   cp_topleft,
                 ip_bottomleft,ip_bottom,{ip_bottomcenter,}ip_bottomright,
               //cp_lefttop,    cp_left, cp_leftcenter, cp_leftbottom,
                 ip_rightbottom,ip_right,{ip_rightcenter,}ip_righttop,
               //cp_bottomleft,cp_bottom,cp_bottomcenter,cp_bottomright
                 ip_topright,  ip_top,   {ip_topcenter,}   ip_topleft
                 );
 imagetocaptionpos: array[imageposty] of captionposty = (
               //ip_center,ip_centervert,ip_rightbottom,ip_right,
                 cp_center,cp_center,    cp_lefttop,    cp_left,
               //{ip_rightcenter,}ip_righttop,
                 {cp_leftcenter,} cp_leftbottom,
               //ip_topright,  ip_top,   ip_topcenter,   ip_topleft,
                 cp_bottomleft,cp_bottom,{cp_bottomcenter,}cp_bottomright,
               //ip_lefttop,    ip_left, {ip_leftcenter,} ip_leftbottom,
                 cp_rightbottom,cp_right,{cp_rightcenter,}cp_righttop,
               //ip_bottomleft,ip_bottom,ip_bottomcenter,ip_bottomright
                 cp_topright,  cp_top,   {cp_topcenter,}   cp_topleft
                 );

 swapcaptionpos: array[captionposty] of captionposty =
 (//cp_center,cp_rightbottom,cp_right,cp_rightcenter,cp_righttop,
    cp_center,cp_leftbottom,cp_left,{cp_leftcenter,}cp_lefttop,
  //cp_topright,cp_top,cp_topcenter,cp_topleft,
    cp_bottomright,cp_bottom,{cp_bottomcenter,}cp_bottomleft,
  //cp_lefttop,cp_left,cp_leftcenter,cp_leftbottom,
    cp_righttop,cp_right,{cp_rightcenter,}cp_rightbottom,
  //cp_bottomleft,cp_bottom,cp_bottomcenter,cp_bottomright
    cp_topleft,cp_top,{cp_topcenter,}cp_topright
 );
 simplecaptionpos: array[captionposty] of captionposty =
 (//cp_center,cp_rightbottom,cp_right,cp_rightcenter,cp_righttop,
    cp_center,cp_right,      cp_right,{cp_right,}      cp_right,
  //cp_topright,cp_top,cp_topcenter,cp_topleft,
    cp_top,     cp_top,{cp_top,}      cp_top,
  //cp_lefttop,cp_left,cp_leftcenter,cp_leftbottom,
    cp_left,   cp_left,{cp_left,}      cp_left,
  //cp_bottomleft,cp_bottom,cp_bottomcenter,cp_bottomright
    cp_bottom, cp_bottom,   {cp_bottom,}      cp_bottom
 );

 swapimagepos: array[imageposty] of imageposty =
 (//ip_center,ip_centervert,ip_rightbottom,ip_right,ip_rightcenter,ip_righttop,
    ip_centervert,ip_center,ip_leftbottom,ip_left,{ip_leftcenter,}ip_lefttop,
  //ip_topright,   ip_top,   ip_topcenter,ip_topleft,
    ip_bottomright,ip_bottom,{ip_bottomcenter,}ip_bottomleft,
  //ip_lefttop, ip_left, ip_leftcenter,ip_leftbottom,
    ip_righttop,ip_right,{ip_rightcenter,}ip_rightbottom,
  //ip_bottomleft,ip_bottom,ip_bottomcenter,ip_bottomright
    ip_topleft,ip_top,{ip_topcenter,}ip_topright
 );
 simpleimagepos: array[imageposty] of imageposty =
 (//ip_center,ip_centervert,ip_rightbottom,ip_right,ip_rightcenter,ip_righttop,
    ip_center,ip_centervert, ip_right,      ip_right,{ip_right,}ip_right,
  //ip_topright,ip_top,ip_topcenter,ip_topleft,
    ip_top,     ip_top,{ip_top,}      ip_top,
  //ip_lefttop,ip_left,ip_leftcenter,ip_leftbottom,
    ip_left,   ip_left,{ip_left,}ip_left,
  //ip_bottomleft,ip_bottom,ip_bottomcenter,ip_bottomright
    ip_bottom,    ip_bottom,{ip_bottom,}ip_bottom
 );

type
 sysdndactionty = (sdnda_reject,sdnda_accept,sdnda_finished,
                   sdnda_begin,sdnda_check,sdnda_drop,sdnda_destroyed);
 dndactionty = (dnda_copy,dnda_move,dnda_link,dnda_ask,dnda_private);
 dndactionsty = set of dndactionty;
const
 firstdndaction = dnda_copy;
type
 isysdnd = interface(iobjectlink)
  procedure cancelsysdnd;
  function getformats: msestringarty;
  function getformatistext: booleanarty;
  function getactions: dndactionsty;
  function geteventintf: ievent;
  function convertmimedata(const atypeindex: integer): string;
  function convertmimetext(const atypeindex: integer): msestring;
 end;

type
 guierrorty = (gue_ok,gue_error,
               gue_alreadyregistered,gue_notregistered,
               gue_postevent,gue_timer,
               gue_createwindow,gue_resizewindow,gue_destroywindow,
               gue_windoworder,gue_windownotfound,
               gue_windowfocus,gue_illegalstate,
               gue_recursivemodal,gue_notmodaltop,
//               gue_creategc,gue_createprintergc,gue_createmetafilegc,
               gue_destroygc,
               gue_show,gue_hide,gue_modalwindow,
               gue_init,gue_deinit,gue_thread,
               gue_nodisplay,gue_nocolormap,gue_notruecolor,gue_flushgdi,
               gue_cannotfocus,gue_invalidwidget,
               gue_cursor,gue_rootwidget,
               gue_inputmanager,gue_inputcontext,gue_timerlist,
               {gue_resnotfound,}gue_capturemouse,gue_mousepos,
               gue_registerclass,gue_scroll,gue_clipboard,
               gue_recursivetransientfor,gue_notlocked,
               gue_characterencoding,gue_invalidstream,gue_invalidcanvas,
               gue_notimplemented,gue_notsupported,gue_getchildren,gue_reparent,
               gue_docktosyswindow,
               gue_notraywindow,gue_sendevent,gue_noshelllib,
               gue_noglx,gue_novisual,gue_rendercontext,
               gue_nodragpending,gue_index,gue_lockcounterror
               );

 egui = class(eerror)
  private
    function geterror: guierrorty;
  public
   constructor create(aerror: guierrorty; atext: string);
   property error: guierrorty read geterror;
 end;

const
 E_NOINTERFACE = longword($80004002);
var
 zerolineworkaround: boolean;
  //use one pixel line width instead of 0-line, new X11 servers don't
  //draw 0-line endpixels reliable
 nozorderhandling: boolean;
 norestackwindow: boolean;
 stackmodebelowworkaround: boolean;
 noreconfigurewmwindow: boolean;
 toplevelraise: boolean;
 nostaticgravity: boolean;
 mse_radiuscorner : integer = 8;
// exabug: boolean;
// nocreatestaticgravity: boolean;

procedure guierror(error: guierrorty; text: string = ''); overload;
procedure guierror(error: guierrorty; sender: tobject;
                                                  text: string = ''); overload;

implementation

uses
 mseclasses,msestreaming{,mseapplication,msegui,mseguiintf};

const
 errortexts: array[guierrorty] of string =
  ('','Error',
   'Already registered',
   'Not registered',
   'Can not post event',
   'Can not set timer',
   'Can not create window',
   'Can not resize window',
   'Can not destroy window',
   'Can not set window order',
   'Window not found',
   'Can not set window focus',
   'Illegal state',
   'Recursive modal',
   'Not modal top',
   'Can not destroy gc',
   'Can not show window',
   'Can not hide window',
   'Can not show modal window',
   'Init failed',
   'Deinit failed',
   'Can not create thread',
   'Can not connect to display',
   'Can not create colormap',
   'Color mode must be "TrueColor", "DirectColor" or 8 bit "PseudoColor"',
   'Can not flush gdi',
   'Can not focus',
   'Invalid widget',
   'Can not create cursor',
   'Invalid rootwidget',
   'Invalid inputmanager',
   'Invalid inputcontext',
   'Corrupted timerlist',
{   'Resource not found',}
   'Can not capture mouse',
   'Can not set mouse pos',
   'Can not register class',
   'Can not scroll window',
   'Clipboard error',
   'Recursive transientfor window',
   'Application not locked',
   'Error in character encoding',
   'Invalid stream',
   'Invalid canvas',
   'Not implemented.',
   'Not supported.',
   'Can not get children.',
   'Can not reparent window.',
   'Can not dock to syswindow.',
   'No tray window.',
   'Can not send event.',
   'Problem with shell library.',
   'GLX extension not supported.',
   'Could not find visual.',
   'Could not create a rendering context.',
   'No drag operation pending.',
   'Invalid index.',
   'Lock count error.'
   );


procedure guierror(error: guierrorty; text: string); overload;
begin
 if error = gue_ok then begin
  exit;
 end;
 raise egui.create(error,text);
end;

procedure guierror(error: guierrorty; sender: tobject;
                       text: string = ''); overload;
begin
 if error = gue_ok then begin
  exit;
 end;
 if sender <> nil then begin
  text:= sender.classname + ' ' + text;
  if sender is tcomponent then begin
   text:= text + fullcomponentname(tcomponent(sender));
  end;
 end;
 guierror(error,text);
end;

{ egui }

constructor egui.create(aerror: guierrorty;  atext: string);
begin
 inherited create(integer(aerror),atext,errortexts);
end;

function egui.geterror: guierrorty;
begin
 result:= guierrorty(ferror);
end;

end.
