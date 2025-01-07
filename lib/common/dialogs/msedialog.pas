{ MSEgui Copyright (c) 1999-2015 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msedialog;

{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}

interface

uses

 classes,mclasses,mseclasses,msegui,mseglob,mseguiglob,mseforms,
 msedataedits,mseedit,mseevent,msestat,msestatfile,msemenus,msestrings,
 mseeditglob,msegraphutils, msetypes;

////////////////////////////////////////////
const
 acceptingResults: modalresultsty = [mr_ok,mr_none,mr_canclose,mr_f10,mr_yes,mr_yesall];
 assertingResults: modalresultsty = [mr_ok,mr_f10,mr_yes,mr_yesall];
////////////////////////////////////////////
type
 mseDialogEventty =    PROCEDURE (CONST Sender: tmsecomponent) OF Object;
 mseDialogResEventty = PROCEDURE (CONST Sender: tmsecomponent;
                                  VAR res: modalresultty) OF Object;
////////////////////////////////////////////
// ATTENTION: On dynamic dialogs, "dp_mousepos" needs form option "fo_defaultpos" set!
 dialogposty = (dp_none, dp_mousepos = ord (fo_windowclosecancel),
                dp_defaultpos, dp_screencentered, dp_screencenteredvirt,
                dp_transientforcentered, dp_mainwindowcentered);
////////////////////////////////////////////

 tdialogform = class (tmseform)
  protected
////////////////////////////////////////////
   doPrepareDialog:  mseDialogEventty;
   doEvaluateDialog: mseDialogResEventty;
////////////////////////////////////////////
   procedure updatewindowinfo (var info: windowinfoty); override;
   class function hasresource: boolean; override;
////////////////////////////////////////////
  private
////////////////////////////////////////////
   StatFileName: msestring;
////////////////////////////////////////////
  public
////////////////////////////////////////////
   CONSTRUCTOR Create (Sender: TComponent; CONST StatName: msestring;
                       where: dialogposty = dp_none); OVERLOAD;

   CONSTRUCTOR Create (Sender: TComponent; where: dialogposty = dp_none); OVERLOAD;
////////////////////////////////////////////
//    PROCEDURE DialogPrepare; VIRTUAL;
//    PROCEDURE DialogEvaluate (VAR what: modalresultty); VIRTUAL;
   FUNCTION  Execute: modalresultty; VIRTUAL;
////////////////////////////////////////////
   PROCEDURE showat (Position: PointTy);       VIRTUAL;  // show at specified position
   PROCEDURE showatmouse;                      VIRTUAL;  // show at mouse pos
   PROCEDURE setPosition (where: dialogposty); VIRTUAL;  // set selected position option
////////////////////////////////////////////
  published
   PROPERTY PrepareDialog:  mseDialogEventty    READ doPrepareDialog  WRITE doPrepareDialog;
   PROPERTY EvaluateDialog: mseDialogResEventty READ doEvaluateDialog WRITE doEvaluateDialog;
////////////////////////////////////////////
 end;

///////////// ??????????????? //////////////
tdialog = class (tmsecomponent)
 public
  function execute: modalresultty; virtual; abstract;
end;

 tellipsebuttonframe = class(tmultibuttonframe)
  private
   function getbutton: tstockglyphframebutton;
   procedure setbutton (const avalue: tstockglyphframebutton);
  public
   constructor create (const aintf: icaptionframe;
                       const buttonintf: ibutton); reintroduce;
  published
   property button: tstockglyphframebutton read getbutton write setbutton;
 end;

 tdataeditcontroller = class(teventpersistent)
 end;

 tdialogcontroller = class (tdataeditcontroller, ibutton, idataeditcontroller)
  protected
   fowner: tcustomdataedit;
   procedure internalexecute; virtual; abstract;
   function iskeyexecute(const info: keyeventinfoty): boolean; virtual;
     //ibutton
   procedure buttonaction(var action: buttonactionty; const buttonindex: integer);

    //idataeditcontroller
   procedure mouseevent(var info: mouseeventinfoty); virtual;
   procedure domousewheelevent(var info: mousewheeleventinfoty); virtual;
   procedure dokeydown(var info: keyeventinfoty); virtual;
   procedure updatereadonlystate; virtual;
   procedure internalcreateframe; virtual;
   procedure editnotification(var info: editnotificationinfoty); virtual;
  public
   constructor create(const aowner: tcustomdataedit); reintroduce;
 end;

 stringdialogexeceventty = procedure(const sender: tcustomdataedit;
            var avalue:msestring; var modresult: modalresultty) of object;
                                       //default mr_ok
 tstringdialogcontroller = class(tdialogcontroller)
  protected
   fonexecute: stringdialogexeceventty;
   procedure internalexecute; override;
   function execute(var avalue: msestring): boolean; virtual;
   procedure setexecresult(var avalue: msestring); virtual;
  public
   constructor create(const aowner: tcustomstringedit);
   property onexecute: stringdialogexeceventty read fonexecute write fonexecute;
 end;

 tcustomdialogstringed = class(tstringedit)
  private
   function getframe: tellipsebuttonframe;
   procedure setframe(const avalue: tellipsebuttonframe);
  protected
   fdialogcontroller: tdialogcontroller;
   function createdialogcontroller: tstringdialogcontroller; virtual;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property frame: tellipsebuttonframe read getframe write setframe;
 end;

 tdialogstringed = class(tcustomdialogstringed)
  published
   property frame;
   property passwordchar;
   property maxlength;
   property value;
   property onsetvalue;
 end;

 tcustomdialogstringedit = class(tcustomdialogstringed)
  private
   function getonexecute: stringdialogexeceventty;
   procedure setonexecute(const avalue: stringdialogexeceventty);
  protected
//   function execute(var avalue: msestring): boolean; override;
  public
   property onexecute: stringdialogexeceventty read getonexecute
                                                          write setonexecute;
 end;

 tdialogstringedit = class(tcustomdialogstringedit)
  published
   property onexecute;
 end;

 realdialogexeceventty = procedure(const sender: tcustomdataedit;
            var avalue: realty; var modresult: modalresultty) of object;
                                       //default mr_ok
 trealdialogcontroller = class(tdialogcontroller)
  private
  protected
   fonexecute: realdialogexeceventty;
   procedure internalexecute; override;
   function execute(var avalue: realty): boolean; virtual;
   procedure setexecresult(var avalue: realty); virtual;
  public
   constructor create(const aowner: tcustomrealedit);
   property onexecute: realdialogexeceventty read fonexecute write fonexecute;
 end;

 tdialogrealedit = class(trealedit)
  private
   function getframe: tellipsebuttonframe;
   procedure setframe(const avalue: tellipsebuttonframe);
   function getonexecute: realdialogexeceventty;
   procedure setonexecute(const avalue: realdialogexeceventty);
  protected
   fdialogcontroller: trealdialogcontroller;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property frame: tellipsebuttonframe read getframe write setframe;
   property onexecute: realdialogexeceventty read getonexecute
                                                        write setonexecute;
 end;

 datetimedialogexeceventty = procedure(const sender: tcustomdataedit;
                  var avalue: tdatetime; var modresult: modalresultty) of object;
                                       //default mr_ok
 tdatetimedialogcontroller = class(tdialogcontroller)
  private
  protected
   fonexecute: datetimedialogexeceventty;
   procedure internalexecute; override;
   function execute(var avalue: tdatetime): boolean; virtual;
   procedure setexecresult(var avalue: tdatetime); virtual;
  public
   constructor create(const aowner: tcustomdatetimeedit);
   property onexecute: datetimedialogexeceventty read fonexecute write fonexecute;
 end;

 tdialogdatetimeedit = class(tdatetimeedit)
  private
   function getframe: tellipsebuttonframe;
   procedure setframe(const avalue: tellipsebuttonframe);
   function getonexecute: datetimedialogexeceventty;
   procedure setonexecute(const avalue: datetimedialogexeceventty);
  protected
   fdialogcontroller: tdatetimedialogcontroller;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property frame: tellipsebuttonframe read getframe write setframe;
   property onexecute: datetimedialogexeceventty read getonexecute
                                                        write setonexecute;
 end;

 integerdialogexeceventty = procedure(const sender: tcustomdataedit;
            var avalue: integer; var modresult: modalresultty) of object;
                                       //default mr_ok
 tintegerdialogcontroller = class(tdialogcontroller)
  private
  protected
   fonexecute: integerdialogexeceventty;
   procedure internalexecute; override;
   function execute(var avalue: integer): boolean; virtual;
   procedure setexecresult(var avalue: integer); virtual;
  public
   constructor create(const aowner: tcustomintegeredit);
   property onexecute: integerdialogexeceventty read fonexecute write fonexecute;
 end;

 tdialogintegeredit = class(tintegeredit)
  private
   function getframe: tellipsebuttonframe;
   procedure setframe(const avalue: tellipsebuttonframe);
   function getonexecute: integerdialogexeceventty;
   procedure setonexecute(const avalue: integerdialogexeceventty);
  protected
   fdialogcontroller: tintegerdialogcontroller;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property frame: tellipsebuttonframe read getframe write setframe;
   property onexecute: integerdialogexeceventty read getonexecute
                                                        write setonexecute;
 end;

////////////////////////////////////////////
FUNCTION keepOnScreen (CONST Sender: tcustommseform{twidget}; shift: PointTy): PointTy;
//// Calulate MODIFIED "shift" vector to keep window on screen
////////////////////////////////////////////

implementation
uses
 sysutils,msestockobjects,msekeyboard,mseformatstr,msereal,
 TypInfo, msevectors;

type
 tcustomdataedit1 = class(tcustomdataedit);
 tcustomrealedit1 = class(tcustomrealedit);
 tcustomdatetimeedit1 = class(tcustomdatetimeedit);
 tcustomintegeredit1 = class(tcustomintegeredit);
 tcustomstringedit1 = class(tcustomstringedit);


////////////////////////////////////////////
FUNCTION keepOnScreen (CONST Sender: tcustommseform{twidget}; shift: PointTy): PointTy;
//// Calulate MODIFIED "shift" vector to keep window on screen
 VAR
   Screenrect: RectTy;
 BEGIN
   Screenrect:= Application.Screenrect (NIL);
   Result:= Sender.Window.{decoratedPos}screenPos+ shift;

   WITH Result DO BEGIN
     IF x < Screenrect.x THEN x:= Screenrect.x;
     IF y < Screenrect.y THEN y:= Screenrect.y;

     Screenrect.Pos:= Screenrect.Pos+ PointTy (Screenrect.Size);                // calculate other limits
     Screenrect.Size:= SizeTy (Result+ PointTy (Sender.Window.decoratedSize));  // find lower right corner
     IF Screenrect.cx > Screenrect.x THEN x:= Screenrect.x- Sender.Window.decoratedSize.cx;
     IF Screenrect.cy > Screenrect.y THEN y:= Screenrect.y- Sender.Window.decoratedSize.cy;
   END;
   Result:= Result- Sender.Window.{decoratedPos}screenPos;
 END;
////////////////////////////////////////////

{ tdialogform }
(*
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
*)
procedure tdialogform.updatewindowinfo (var info: windowinfoty);
 begin
  inherited;
  info.options:= [wo_message];
 end;

class function tdialogform.hasresource: boolean;
 begin
   result:= self <> tdialogform;
 end;

////////////////////////////////////////////
CONSTRUCTOR tdialogform.Create (Sender: TComponent; CONST StatName: msestring; where: dialogposty);
 VAR
   StatHost:    TComponent;
   RefStatfile: TStatfile;
 BEGIN
   StatFileName:= StatName; Name:= StatFilename;
   StatHost:= Sender.findcomponent (StatFileName);

   IF (StatHost IS tstatfile) AND (StatHost.Name = StatFileName)
   THEN statfile:= StatHost AS TStatfile
   ELSE BEGIN
     statfile.free; statfile:= NIL;
   END;
   IF Self.statvarname = '' THEN Self.statvarname:= StatFilename;

   IF statfile = NIL THEN BEGIN
     statfile:= TStatfile.create (Self);

     WITH statfile DO BEGIN
       IF StatFilename = '' THEN StatFilename:= StatHost.Name;
       Name:= StatFilename;
       filename:= uppercase (StatFilename+ StatExt);
       options:= options+ [sfo_memory, sfo_autoreadstat, sfo_autowritestat];
     END;
   END;
   Create (Sender, where);

   IF (Sender <> NIL) AND (getPropInfo (Sender, 'statfile') <> NIL)
   THEN BEGIN
     RefStatfile:= GetObjectProp (Sender, 'statfile') AS TStatfile;
     registerNewMemoryFile (RefStatFile, statfile.filename);
     statfile.statfile:= RefStatFile;
   END;
 END;

CONSTRUCTOR tdialogform.Create (Sender: TComponent; where: dialogposty);
 BEGIN

   Options:= Options+ [fo_modal,fo_createmodal];  ////????

   INHERITED Create (Sender);
   IF (Sender <> NIL) OR
      NOT (where IN [dp_transientforcentered, dp_mainwindowcentered])
     THEN setPosition (where)
     ELSE setPosition (dp_screencentered);   //// would crash otherwise!?
{$ifdef listMemoryStreams}
   IF statfile <> NIL THEN listmemorystreams (statfile.name{statname});
{$endif}
 END;
////////////////////////////////////////////
FUNCTION tdialogform.Execute: modalresultty;
// main part copied from dialog function definition
 BEGIN
   Application.lock;
   TRY
     IF assigned (doPrepareDialog) THEN doPrepareDialog (Self);
     Result:= Show (TRUE, Self.Window); //NIL);
     IF Result IN acceptingResults THEN BEGIN
      Result:= mr_Ok;
      IF assigned (doEvaluateDialog) THEN doEvaluateDialog (self, Result);
     END;
   FINALLY
     Application.unlock;
   end;
 END;
////////////////////////////////////////////
PROCEDURE tdialogform.showat (Position: PointTy);  // show at specified position
 VAR
   shift: PointTy;
 BEGIN
   WITH Window DO BEGIN
     shift:= keepOnScreen (Self, Position- {decorated}{Self.}Pos{screenPos});
     decoratedPos:= screenPos+ shift; // 
   END;
   screenPos:= screenPos+ shift;
 END;

PROCEDURE tdialogform.showatmouse;
 BEGIN
   showat (Application.Mouse.Pos- (PointTy (Self.Size) DIV 2));
 END;

////////////////////////////////////////////
////////////////////////////////////////////
//
// FROM msegui.pas:
//
// procedure translateclientpoint1(var point: pointty; const source,dest: twidget);
//     //translates from source client to dest client, to screen if dest = nil
//     //source = nil -> screen
//
// function translateclientpoint(const point: pointty; const source,dest: twidget): pointty;
//
// procedure translatewidgetpoint1(var point: pointty; const source,dest: twidget);
//     //translates from source widget to dest widget, to screen if dest = nil
//     //source = nil -> screen
//
// function translatewidgetpoint(const point: pointty; const source,dest: twidget): pointty;
//
////////////////////////////////////////////
////////////////////////////////////////////

PROCEDURE tdialogform.setPosition (where: dialogposty);
 BEGIN
   if where <> dp_none then
     Options:= Options+ [formoptionty (ord (where))];

   CASE where OF
     dp_mousepos:                 // MUST RELOCATE WINDOW itself too!
       showatmouse;    // ATTENTION: Needs form option "fo_defaultpos" set!

     dp_defaultpos:
       showat (Pos);

     dp_screencentered,
     dp_screencenteredvirt:       // NOT TESTED, may need modification for multi monitor set up!
       showat ((PointTy (Application.Screenrect (NIL).Size)- PointTy (Size)) DIV 2);

     dp_mainwindowcentered,
     dp_transientforcentered:     // NOT TESTED, may need modification for correct function!
       WITH Application.MainWindow DO
         showat (PointTy (Application.MainWindow.decoratedPos)+
                 ((PointTy (Application.MainWindow.decoratedSize)-
                   PointTy (Size))
                    DIV 2));

     ELSE { do nothing };
   END;
 END;
////////////////////////////////////////////

{ tellipsebuttonframe }

constructor tellipsebuttonframe.create(const aintf: icaptionframe;
  const buttonintf: ibutton);
begin
 inherited;
// buttons.count:= 1;
 with buttons[0] do begin
  imagelist:= stockobjects.glyphs;
  imagenr:= ord(stg_ellipsesmall);
 end;
end;

function tellipsebuttonframe.getbutton: tstockglyphframebutton;
begin
 result:= tstockglyphframebutton(inherited getbutton());
end;

procedure tellipsebuttonframe.setbutton(const avalue: tstockglyphframebutton);
begin
 inherited setbutton(avalue);
end;

{ tdialogcontroller }

constructor tdialogcontroller.create(const aowner: tcustomdataedit);
begin
 fowner:= aowner;
 tcustomdataedit1(fowner).fcontrollerintf:= idataeditcontroller(self);
 internalcreateframe;
end;

procedure tdialogcontroller.buttonaction(var action: buttonactionty;
               const buttonindex: integer);
begin
 with fowner do begin
  if action = ba_click then begin
   if canfocus and not setfocus then begin
    exit;
   end;
   internalexecute;
  end;
 end;
end;

procedure tdialogcontroller.dokeydown(var info: keyeventinfoty);
begin
 with info do begin
  if iskeyexecute(info) then begin
   include(info.eventstate,es_processed);
   internalexecute;
  end;
 end;
end;

function tdialogcontroller.iskeyexecute(const info: keyeventinfoty): boolean;
begin
 with fowner,info do begin
  result:= (not readonly or (oe1_readonlydialog in optionsedit1)) and
                (oe1_keyexecute in optionsedit1) and (key = key_down) and
           (shiftstate = [ss_alt]);
 end;
end;

procedure tdialogcontroller.updatereadonlystate;
begin
 with tcustomdataedit1(fowner) do begin
  if fframe <> nil then begin
   with tcustombuttonframe(fframe) do begin
    if buttons.count > 0 then begin
     buttons[0].enabled:= not (oe_readonly in getoptionsedit) or
                     (oe1_readonlydialog in optionsedit1);
    end;
   end;
  end;
 end;
end;

procedure tdialogcontroller.internalcreateframe;
begin
 tellipsebuttonframe.create(iscrollframe(fowner),ibutton(self));
 updatereadonlystate;
end;

procedure tdialogcontroller.mouseevent(var info: mouseeventinfoty);
begin
 with tcustomdataedit1(fowner) do begin
  tcustombuttonframe(fframe).mouseevent(info);
 end;
end;

procedure tdialogcontroller.domousewheelevent(var info: mousewheeleventinfoty);
begin
 //dummy
end;

procedure tdialogcontroller.editnotification(var info: editnotificationinfoty);
begin
 //dummy
end;

{ tstringdialogcontroller }

constructor tstringdialogcontroller.create(const aowner: tcustomstringedit);
begin
 inherited create(aowner);
end;

procedure tstringdialogcontroller.internalexecute;
var
 str1: msestring;
begin
 with tcustomstringedit(fowner) do begin
  str1:= text;
  if execute(str1) and not readonly then begin
   setexecresult(str1);
   checkvalue;
  end;
 end;
end;

function tstringdialogcontroller.execute(var avalue: msestring): boolean;
var
 mr1: modalresultty;
begin
 if fowner.canevent(tmethod(fonexecute)) then begin
  mr1:= mr_ok;
  fonexecute(fowner,avalue,mr1);
  result:= mr1 = mr_ok;
 end
 else begin
  result:= false;
 end;
end;

procedure tstringdialogcontroller.setexecresult(var avalue: msestring);
begin
 with tcustomstringedit1(fowner) do begin
  text:= avalue; //setcurrenttext(avalue);
 end;
end;

{ tcustomdialogstringed }

constructor tcustomdialogstringed.create(aowner: tcomponent);
begin
 inherited;
 if fdialogcontroller = nil then begin
  fdialogcontroller:= createdialogcontroller;
 end;
// fbuttonintf:= ibutton(fcontroller);
// inherited;
// internalcreateframe;
end;

destructor tcustomdialogstringed.destroy;
begin
 inherited;
 fdialogcontroller.free;
end;

function tcustomdialogstringed.createdialogcontroller: tstringdialogcontroller;
begin
 result:= tstringdialogcontroller.create(self);
end;

function tcustomdialogstringed.getframe: tellipsebuttonframe;
begin
 result:= tellipsebuttonframe(inherited getframe);
end;

procedure tcustomdialogstringed.setframe(const avalue: tellipsebuttonframe);
begin
 inherited setframe(avalue);
end;

function tcustomdialogstringedit.getonexecute: stringdialogexeceventty;
begin
 result:= tstringdialogcontroller(fdialogcontroller).onexecute;
end;

procedure tcustomdialogstringedit.setonexecute(const avalue: stringdialogexeceventty);
begin
 tstringdialogcontroller(fdialogcontroller).onexecute:= avalue;
end;

{ trealdialogcontroller }

constructor trealdialogcontroller.create(const aowner: tcustomrealedit);
begin
 inherited create(aowner);
end;

procedure trealdialogcontroller.internalexecute;
var
 rea1: realty;
 bo1: boolean;
begin
 with tcustomrealedit1(fowner) do begin
  bo1:= true;
  rea1:= gettextvalue(bo1,false);
  if bo1 and execute(rea1) then begin
   setexecresult(rea1);
   checkvalue;
  end;
 end;
end;

function trealdialogcontroller.execute(var avalue: realty): boolean;
var
 mr1: modalresultty;
begin
 if fowner.canevent(tmethod(fonexecute)) then begin
  mr1:= mr_ok;
  fonexecute(fowner,avalue,mr1);
  result:= mr1 = mr_ok;
 end
 else begin
  result:= false;
 end;
end;

procedure trealdialogcontroller.setexecresult(var avalue: realty);
begin
 with tcustomrealedit(fowner) do begin
  text:= realtytostrrange(avalue,formatedit,valuerange,valuestart);
 end;
end;

{ tdialogrealedit }

constructor tdialogrealedit.create(aowner: tcomponent);
begin
 inherited;
 if fdialogcontroller = nil then begin
  fdialogcontroller:= trealdialogcontroller.create(self);
 end;
end;

destructor tdialogrealedit.destroy;
begin
 inherited;
 fdialogcontroller.free;
end;

function tdialogrealedit.getframe: tellipsebuttonframe;
begin
 result:= tellipsebuttonframe(inherited getframe);
end;

procedure tdialogrealedit.setframe(const avalue: tellipsebuttonframe);
begin
 inherited setframe(avalue);
end;

function tdialogrealedit.getonexecute: realdialogexeceventty;
begin
 result:= fdialogcontroller.onexecute;
end;

procedure tdialogrealedit.setonexecute(const avalue: realdialogexeceventty);
begin
 fdialogcontroller.onexecute:= avalue;
end;

{ tdatetimedialogcontroller }

constructor tdatetimedialogcontroller.create(const aowner: tcustomdatetimeedit);
begin
 inherited create(aowner);
end;

procedure tdatetimedialogcontroller.internalexecute;
var
 dat1: tdatetime;
 bo1: boolean;
begin
 with tcustomdatetimeedit1(fowner) do begin
  bo1:= true;
  dat1:= gettextvalue(bo1,false);
  if bo1 and execute(dat1) then begin
   setexecresult(dat1);
   checkvalue;
  end;
 end;
end;

function tdatetimedialogcontroller.execute(var avalue: tdatetime): boolean;
var
 mr1: modalresultty;
begin
 if fowner.canevent(tmethod(fonexecute)) then begin
  mr1:= mr_ok;
  fonexecute(fowner,avalue,mr1);
  result:= mr1 = mr_ok;
 end
 else begin
  result:= false;
 end;
end;

procedure tdatetimedialogcontroller.setexecresult(var avalue: tdatetime);
begin
 with tcustomdatetimeedit(fowner) do begin
  case kind of
   dtk_time: begin
    text:= mseformatstr.timetostring(avalue,formatedit);
   end;
   dtk_date: begin
    text:= mseformatstr.datetostring(avalue,formatedit);
   end;
   else begin
    text:= mseformatstr.datetimetostring(avalue,formatedit);
   end;
  end;
 end;
end;

{ tdialogdatetimeedit }

constructor tdialogdatetimeedit.create(aowner: tcomponent);
begin
 inherited;
 if fdialogcontroller = nil then begin
  fdialogcontroller:= tdatetimedialogcontroller.create(self);
 end;
end;

destructor tdialogdatetimeedit.destroy;
begin
 inherited;
 fdialogcontroller.free;
end;

function tdialogdatetimeedit.getframe: tellipsebuttonframe;
begin
 result:= tellipsebuttonframe(inherited getframe);
end;

procedure tdialogdatetimeedit.setframe(const avalue: tellipsebuttonframe);
begin
 inherited setframe(avalue);
end;

function tdialogdatetimeedit.getonexecute: datetimedialogexeceventty;
begin
 result:= fdialogcontroller.onexecute;
end;

procedure tdialogdatetimeedit.setonexecute(const avalue: datetimedialogexeceventty);
begin
 fdialogcontroller.onexecute:= avalue;
end;

{ tintegerdialogcontroller }

constructor tintegerdialogcontroller.create(const aowner: tcustomintegeredit);
begin
 inherited create(aowner);
end;

procedure tintegerdialogcontroller.internalexecute;
var
 int1: integer;
 bo1: boolean;
begin
 with tcustomintegeredit1(fowner) do begin
  bo1:= true;
  int1:= gettextvalue(bo1,false);
  if bo1 and execute(int1) then begin
   setexecresult(int1);
   checkvalue;
  end;
 end;
end;

function tintegerdialogcontroller.execute(var avalue: integer): boolean;
var
 mr1: modalresultty;
begin
 if fowner.canevent(tmethod(fonexecute)) then begin
  mr1:= mr_ok;
  fonexecute(fowner,avalue,mr1);
  result:= mr1 = mr_ok;
 end
 else begin
  result:= false;
 end;
end;

procedure tintegerdialogcontroller.setexecresult(var avalue: integer);
begin
 with tcustomintegeredit(fowner) do begin
  text:= inttostrmse(avalue);
 end;
end;

{ tdialogintegeredit }

constructor tdialogintegeredit.create(aowner: tcomponent);
begin
 inherited;
 if fdialogcontroller = nil then begin
  fdialogcontroller:= tintegerdialogcontroller.create(self);
 end;
end;

destructor tdialogintegeredit.destroy;
begin
 inherited;
 fdialogcontroller.free;
end;

function tdialogintegeredit.getframe: tellipsebuttonframe;
begin
 result:= tellipsebuttonframe(inherited getframe);
end;

procedure tdialogintegeredit.setframe(const avalue: tellipsebuttonframe);
begin
 inherited setframe(avalue);
end;

function tdialogintegeredit.getonexecute: integerdialogexeceventty;
begin
 result:= fdialogcontroller.onexecute;
end;

procedure tdialogintegeredit.setonexecute(const avalue: integerdialogexeceventty);
begin
 fdialogcontroller.onexecute:= avalue;
end;

end.
