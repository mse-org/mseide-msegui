{ MSEgui Copyright (c) 1999-2008 by Martin Schreiber

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
 Classes,msegraphutils,msetypes,msekeyboard,mseerr,mseevent,msestrings;
{$ifdef FPC}
 
{$endif}

type
 unicharty = longword;
 
 originty = (org_screen,org_widget,org_client,org_inner);
 captionposty = (cp_center,cp_rightbottom,cp_right,cp_rightcenter,cp_righttop,
                 cp_topright,cp_top,cp_topcenter,cp_topleft,
                 cp_lefttop,cp_left,cp_leftcenter,cp_leftbottom,
                 cp_bottomleft,cp_bottom,cp_bottomcenter,cp_bottomright
                 );
                 
 mousebuttonty = (mb_none,mb_left,mb_right,mb_middle);
 mousewheelty = (mw_none,mw_up,mw_down);

 shiftstatety = (ss_shift,ss_alt,ss_ctrl,ss_left,ss_right,ss_middle,ss_double,
                 ss_repeat); //repeat keydown
 shiftstatesty = set of shiftstatety;

const
 keyshiftstatesmask: shiftstatesty = [ss_shift,ss_alt,ss_ctrl];
 buttonshiftstatesmask: shiftstatesty = [ss_left,ss_right,ss_middle,ss_double];
 shiftstatesmask = [ss_shift,ss_alt,ss_ctrl,ss_left,ss_right,ss_middle];

type
 mouseeventinfoty = record //same layout as mousewheeleventinfoty!
  eventkind: eventkindty;
  shiftstate: shiftstatesty;
  pos: pointty;
  eventstate: eventstatesty;
  timestamp: longword; //usec, 0 -> invalid
  button: mousebuttonty;
 end;
 pmouseeventinfoty = ^mouseeventinfoty;
 
 mousewheeleventinfoty = record //same layout as mouseeventinfoty!
  eventkind: eventkindty;
  shiftstate: shiftstatesty;
  pos: pointty;
  eventstate: eventstatesty;
  timestamp: longword; //usec, 0 -> invalid
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
 end;
 pkeyeventinfoty = ^keyeventinfoty;

 stockfontty = (stf_default,stf_empty,stf_unicode,stf_menu,stf_report,stf_proportional,
                stf_fixed,
                stf_helvetica,stf_roman,stf_courier); //scaleable fonts
 defaultfontnamesty = array[stockfontty] of string;

 windowoptionty = (wo_popup,wo_message,wo_embedded,
                   wo_buttonendmodal,wo_groupleader,
                   wo_taskbar,    //win32 only
                   wo_notaskbar,  //linux only
                   wo_windowcentermessage); //showmessage centered in window
 windowoptionsty = set of windowoptionty;
 windowposty = (wp_normal,wp_screencentered,wp_minimized,wp_maximized,wp_default,
                wp_fullscreen);
 windowsizety = (wsi_normal,wsi_minimized,wsi_maximized,wsi_fullscreen);

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
 
 internalwindowoptionsty = record
  parent: winidty;
  options: windowoptionsty;
  pos: windowposty;
  transientfor: winidty;
  setgroup: boolean;
  groupleader: winidty;
  icon,iconmask: pixmapty;
 end;
 pinternalwindowoptionsty = ^internalwindowoptionsty;

const
 defaultppmm = 3;      //3 pixel per mm
 sizingtol = 2; //+- pixel
 sizingwidth = 2*sizingtol;                                        

 swapcaptionpos: array[captionposty] of captionposty =
 (//cp_center,cp_rightbottom,cp_right,cp_rightcenter,cp_righttop,
    cp_center,cp_leftbottom,cp_left,cp_leftcenter,cp_lefttop,
  //cp_topright,cp_top,cp_topcenter,cp_topleft,
    cp_bottomright,cp_bottom,cp_bottomcenter,cp_bottomleft,
  //cp_lefttop,cp_left,cp_leftcenter,cp_leftbottom,
    cp_righttop,cp_right,cp_rightcenter,cp_rightbottom,
  //cp_bottomleft,cp_bottom,cp_bottomcenter,cp_bottomright
    cp_topleft,cp_top,cp_topcenter,cp_topright
 );
 simplecaptionpos: array[captionposty] of captionposty =
 (//cp_center,cp_rightbottom,cp_right,cp_rightcenter,cp_righttop,
    cp_center,cp_right,cp_right,cp_right,cp_right,
  //cp_topright,cp_top,cp_topcenter,cp_topleft,
    cp_top,cp_top,cp_top,cp_top,
  //cp_lefttop,cp_left,cp_leftcenter,cp_leftbottom,
    cp_left,cp_left,cp_left,cp_left,
  //cp_bottomleft,cp_bottom,cp_bottomcenter,cp_bottomright
    cp_bottom,cp_bottom,cp_bottom,cp_bottom
 );

type
 guierrorty = (gue_ok,gue_error,
               gue_alreadyregistered,gue_notregistered,
               gue_postevent,gue_timer,
               gue_createwindow,gue_resizewindow,gue_destroywindow,
               gue_windoworder,gue_windownotfound,
               gue_windowfocus,gue_illegalstate,
               gue_recursivemodal,gue_notmodaltop,
               gue_creategc,gue_createprintergc,gue_createmetafilegc,
               gue_destroygc,
               gue_show,gue_hide,gue_modalwindow,
               gue_init,gue_deinit,gue_thread,
               gue_nodisplay,gue_nocolormap,gue_notruecolor,gue_flushgdi,
               gue_cannotfocus,gue_invalidwidget,
               gue_cursor,gue_rootwidget,
               gue_inputmanager,gue_inputcontext,gue_timerlist,
               {gue_resnotfound,}gue_capturemouse,gue_mousepos,
               gue_registerclass,gue_scroll,gue_clipboard,gue_recursivetransientfor,
               gue_notlocked,
               gue_characterencoding,gue_invalidstream,gue_invalidcanvas,
               gue_notimplemented,gue_getchildren
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
 nozorderhandling: boolean;

procedure guierror(error: guierrorty; text: string = ''); overload;
procedure guierror(error: guierrorty; sender: tobject; text: string = ''); overload;

implementation

uses
 mseglob,mseclasses,msestreaming;

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
   'Can not create gc',
   'Can not create printer gc',
   'Can not create metafile gc',
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
   'Not implemnted.',
   'Can not get children.'
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
