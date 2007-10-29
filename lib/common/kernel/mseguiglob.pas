{ MSEgui Copyright (c) 1999-2007 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseguiglob;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 Classes,msegraphutils,msetypes,msekeyboard,mseerr;
{$ifdef FPC}
 {$interfaces corba}
{$endif}

type
 unicharty = longword;
 
 originty = (org_screen,org_widget,org_client,org_inner);
 captionposty = (cp_center,cp_rightbottom,cp_right,cp_righttop,
                 cp_topright,cp_top,cp_topleft,
                 cp_lefttop,cp_left,cp_leftbottom,
                 cp_bottomleft,cp_bottom,cp_bottomright
                 );
                 
 mousebuttonty = (mb_none,mb_left,mb_right,mb_middle);
 mousewheelty = (mw_none,mw_up,mw_down);

 shiftstatety = (ss_shift,ss_alt,ss_ctrl,ss_left,ss_right,ss_middle,ss_double);
 shiftstatesty = set of shiftstatety;

const
 defaultppmm = 3;      //3 pixel per mm
// shiftstatemask = [ss_shift,ss_alt,ss_ctrl];
 sizingtol = 2; //+- pixel
 sizingwidth = 2*sizingtol;                                        
 keyshiftstatesmask: shiftstatesty = [ss_shift,ss_alt,ss_ctrl];
 buttonshiftstatesmask: shiftstatesty = [ss_left,ss_right,ss_middle,ss_double];
 shiftstatesmask = [ss_shift,ss_alt,ss_ctrl,ss_left,ss_right,ss_middle];
// keybuttonshiftstatesmask: shiftstatesty = [ss_shift,ss_alt,ss_ctrl,
//                   ss_left,ss_right,ss_middle,ss_double];

type
 guierrorty = (gue_ok,gue_error,
               gue_alreadyregistered,gue_notregistered,
               gue_postevent,gue_timer,
               gue_createwindow,gue_resizewindow,gue_destroywindow,
               gue_windoworder,gue_windownotfound,
               gue_windowfocus,gue_illegalstate,
               gue_recursivemodal,gue_notmodaltop,
               gue_creategc,gue_createprintergc,gue_destroygc,
               gue_show,gue_hide,gue_modalwindow,
               gue_init,gue_deinit,gue_thread,
               gue_nodisplay,gue_nocolormap,gue_notruecolor,gue_flushgdi,
               gue_cannotfocus,gue_invalidwidget,
               gue_cursor,gue_rootwidget,
               gue_inputmanager,gue_inputcontext,gue_timerlist,
               {gue_resnotfound,}gue_capturemouse,gue_mousepos,
               gue_registerclass,gue_scroll,gue_clipboard,gue_recursivetransientfor,
               gue_notlocked,
               gue_characterencoding,gue_invalidstream,gue_invalidcanvas
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
   'Invalid canvas'
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
