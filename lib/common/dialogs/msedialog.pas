{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msedialog;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface

uses
 mseclasses,msegui,mseforms,msedataedits,mseedit,classes,mseevent,msestrings;

type
 tdialogform = class(tmseform)
  protected
   procedure updatewindowinfo(var info: windowinfoty); override;
 end;

 tdialog = class(tmsecomponent)
  public
   function execute: modalresultty; virtual; abstract;
 end;

  tellipsebuttonframe = class(tbuttonframe)
  private
   function getbutton: tframebutton;
   procedure setbutton(const avalue: tframebutton);
  public
   constructor create(const intf: iframe; const buttonintf: ibutton);
  published
   property button: tframebutton read getbutton write setbutton;
 end;

 tdialogstringedit = class(tstringedit,ibutton)
  private
   function getframe: tellipsebuttonframe;
   procedure setframe(const avalue: tellipsebuttonframe);
  protected
   procedure createframe; override;
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure mouseevent(var info: mouseeventinfoty); override;
    //ibutton
   procedure buttonaction(var action: buttonactionty; const buttonindex: integer);

   procedure internalexecute;
   function execute(var avalue: msestring): boolean; virtual;
   procedure setexecresult(var avalue: msestring); virtual;
   function iskeyexecute(const info: keyeventinfoty): boolean; virtual;
  public
   constructor create(aowner: tcomponent); override;
  published 
   //frame is allready published in tedit -> double streamed on fpc
   property frame: tellipsebuttonframe read getframe write setframe;
 end;

implementation
uses
 msestockobjects,msekeyboard,mseguiglob,mseeditglob;

{ tdialogform }

procedure tdialogform.updatewindowinfo(var info: windowinfoty);
begin
 inherited;
 info.options:= [wo_message];
end;

{ tellipsebuttonframe }

constructor tellipsebuttonframe.create(const intf: iframe;
  const buttonintf: ibutton);
begin
 inherited;
 buttons.count:= 1;
 buttons[0].imagelist:= stockobjects.glyphs;
 buttons[0].imagenr:= ord(stg_ellipsesmall);
end;

function tellipsebuttonframe.getbutton: tframebutton;
begin
 result:= buttons[0];
end;

procedure tellipsebuttonframe.setbutton(const avalue: tframebutton);
begin
 buttons[0].assign(avalue);
end;

{ tdialogstringedit }

procedure tdialogstringedit.buttonaction(var action: buttonactionty;
  const buttonindex: integer);
begin
 if action = ba_click then begin
  internalexecute;
 end;
end;

constructor tdialogstringedit.create(aowner: tcomponent);
begin
 inherited;
 createframe;
end;

procedure tdialogstringedit.createframe;
begin
 tellipsebuttonframe.create(iframe(self),ibutton(self));
end;

function tdialogstringedit.execute(var avalue: msestring): boolean;
begin
 result:= false;
end;

procedure tdialogstringedit.setexecresult(var avalue: msestring);
begin
 text:= avalue;
end;

procedure tdialogstringedit.internalexecute;
var
 str1: msestring;
begin
 str1:= text;
 if execute(str1) then begin
  setexecresult(str1);
  checkvalue;
 end;
end;

procedure tdialogstringedit.mouseevent(var info: mouseeventinfoty);
begin
 inherited;
 tcustombuttonframe(fframe).mouseevent(info);
end;

function tdialogstringedit.iskeyexecute(const info: keyeventinfoty): boolean;

begin
 with info do begin
  result:= (oe_keyexecute in foptionsedit) and (key = key_down) and (shiftstate = [ss_shift]);
 end;
end;

procedure tdialogstringedit.dokeydown(var info: keyeventinfoty);
begin
 with info do begin
  if iskeyexecute(info) then begin
   include(info.eventstate,es_processed);
   internalexecute;
  end
  else begin
   inherited;
  end;
 end;
end;

function tdialogstringedit.getframe: tellipsebuttonframe;
begin
 result:= tellipsebuttonframe(inherited getframe);
end;

procedure tdialogstringedit.setframe(const avalue: tellipsebuttonframe);
begin
 inherited setframe(avalue);
end;

end.
