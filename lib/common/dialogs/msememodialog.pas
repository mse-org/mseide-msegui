{ MSEgui Copyright (c) 1999-2016 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msememodialog;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseglob,mseguiglob,mseapplication,msestat,msemenus,msegui,msegraphics,
 msegraphutils,mseevent,mseclasses,mseforms,msedataedits,mseedit,msestrings,
 msetypes,msestatfile,msesimplewidgets,msewidgets,msedialog,classes,mclasses,
 msedropdownlist,msesplitter;

type
 tmemodialogcontroller = class(tstringdialogcontroller)
  protected
   function execute(var avalue: msestring): boolean; override;
 end;

 tmemodialogedit = class(tcustomdialogstringed)
  protected
   function createdialogcontroller: tstringdialogcontroller; override;
  public
   constructor create(aowner: tcomponent); override;
  published
   property textflags default defaulttextflagsnoycentered;
   property textflagsactive default defaulttextflagsactivenoycentered;
 end;

 tmsememodialogfo = class(tmseform)
   memo: tmemoedit;
   tstatfile1: tstatfile;
   tlayouter1: tlayouter;
   tbutton2: tbutton;
   tbutton1: tbutton;
  public
   constructor create(const aowner: tcomponent; const readonly: boolean);
                                                                  reintroduce;
 end;

 tdialogdropdownbuttonframe = class(tdropdownmultibuttonframe)
  private
   function getbuttondialog: tdropdownbutton;
   procedure setbuttondialog(const avalue: tdropdownbutton);
  public
   constructor create(const aintf: icaptionframe;
                                         const buttonintf: ibutton); override;
  published
   property buttondialog: tdropdownbutton read getbuttondialog
                                       write setbuttondialog;
 end;

 tdialoghistorycontroller = class(thistorycontroller)
  protected
   function getbuttonframeclass: dropdownbuttonframeclassty; override;
 end;

 tmemodialoghistoryedit = class(thistoryedit,ibutton)
  private
//   function getframe: tellipsebuttonframe;
//   procedure setframe(const avalue: tellipsebuttonframe);
  protected
   function createdropdowncontroller: tcustomdropdowncontroller; override;
//   procedure internalcreateframe; override;
//   procedure dokeydown(var info: keyeventinfoty); override;
//   procedure mouseevent(var info: mouseeventinfoty); override;
//   procedure updatereadonlystate; override;
    //ibutton
   procedure buttonaction(var action: buttonactionty;
                      const buttonindex: integer); override;

   procedure internalexecute;
   function execute(var avalue: msestring): boolean; virtual;
   procedure setexecresult(var avalue: msestring); virtual;
//   function iskeyexecute(const info: keyeventinfoty): boolean; virtual;
  public
   constructor create(aowner: tcomponent); override;
//   property frame: tellipsebuttonframe read getframe write setframe;
 end;

function memodialog(var avalue: msestring; const readonly: boolean): modalresultty;

implementation
uses
 msestockobjects,
 msememodialog_mfm,mseeditglob,msekeyboard;

function memodialog(var avalue: msestring; const readonly: boolean): modalresultty;
var
 dia1: tmsememodialogfo;
begin
 dia1:= tmsememodialogfo.create(nil,readonly);
 try
  dia1.memo.value:= avalue;
  result:= dia1.show(true);
  if result = mr_ok then begin
   avalue:= dia1.memo.value;
  end;
 finally
  dia1.free;
 end;
end;

{ tmemodialogcontroller }

function tmemodialogcontroller.execute(var avalue: msestring): boolean;
begin
 result:= memodialog(avalue,not fowner.editor.canedit) = mr_ok;
end;

{ tmemodialogedit }

constructor tmemodialogedit.create(aowner: tcomponent);
begin
 inherited;
 ftextflags:= defaulttextflagsnoycentered;
 ftextflagsactive:= defaulttextflagsactivenoycentered;
 updatetextflags();
end;

function tmemodialogedit.createdialogcontroller: tstringdialogcontroller;
begin
 result:= tmemodialogcontroller.create(self);
end;


{
function tmemodialogedit.execute(var avalue: msestring): boolean;
begin
 result:= memodialog(avalue) = mr_ok;
end;
}
{ tmemodialoghistoryedit }

constructor tmemodialoghistoryedit.create(aowner: tcomponent);
begin
 inherited;
// internalcreateframe;
end;

procedure tmemodialoghistoryedit.buttonaction(var action: buttonactionty;
  const buttonindex: integer);
begin
 if buttonindex = 1 then begin
  if action = ba_click then begin
   if canfocus and not setfocus then begin
    exit;
   end;
   internalexecute;
  end;
 end
 else begin
  inherited;
 end;
end;
{
procedure tmemodialoghistoryedit.internalcreateframe;
begin
 tellipsebuttonframe.create(iscrollframe(self),ibutton(self));
 updatereadonlystate;
end;
}
function tmemodialoghistoryedit.execute(var avalue: msestring): boolean;
begin
 result:= memodialog(avalue,readonly) = mr_ok;
end;

procedure tmemodialoghistoryedit.setexecresult(var avalue: msestring);
begin
 text:= avalue;
end;

procedure tmemodialoghistoryedit.internalexecute;
var
 str1: msestring;
begin
 str1:= text;
 if execute(str1) then begin
  setexecresult(str1);
  checkvalue;
 end;
end;

function tmemodialoghistoryedit.createdropdowncontroller: tcustomdropdowncontroller;
begin
 result:= tdialoghistorycontroller.create(idropdownlist(self));
end;

{ tdialoghistorycontroller }

function tdialoghistorycontroller.getbuttonframeclass: dropdownbuttonframeclassty;
begin
 result:= tdialogdropdownbuttonframe;
end;

{ tdialogdropdownbuttonframe }

constructor tdialogdropdownbuttonframe.create(const aintf: icaptionframe;
               const buttonintf: ibutton);
begin
 inherited;
 buttons.count:= 2;
 buttons[1].imagenr:= ord(stg_ellipsesmall);
end;

function tdialogdropdownbuttonframe.getbuttondialog: tdropdownbutton;
begin
 result:= tdropdownbutton(buttons[1]);
end;

procedure tdialogdropdownbuttonframe.setbuttondialog(const avalue: tdropdownbutton);
begin
 tdropdownbutton(buttons[1]).assign(avalue);
end;

{ tmsememodialogfo }

constructor tmsememodialogfo.create(const aowner: tcomponent;
               const readonly: boolean);
begin
 inherited create(aowner);
 if readonly then begin
  caption:= 'Memo text';
 end;
 memo.readonly:= readonly;
end;

end.
