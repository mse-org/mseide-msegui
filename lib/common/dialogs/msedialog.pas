{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msedialog;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface

uses
 mseclasses,msegui,mseglob,mseguiglob,
 mseforms,msedataedits,mseedit,classes,mseevent,
 msemenus,msestrings;

type
 tdialogform = class(tmseform)
  protected
   procedure updatewindowinfo(var info: windowinfoty); override;
   class function hasresource: boolean; override;
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
   constructor create(const intf: icaptionframe;
                       const buttonintf: ibutton); reintroduce;
  published
   property button: tframebutton read getbutton write setbutton;
 end;

 tcustomdialogstringed = class(tstringedit,ibutton)
  private
   function getframe: tellipsebuttonframe;
   procedure setframe(const avalue: tellipsebuttonframe);
  protected
   procedure internalcreateframe; override;
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure mouseevent(var info: mouseeventinfoty); override;
   procedure updatereadonlystate; override;
    //ibutton
   procedure buttonaction(var action: buttonactionty; const buttonindex: integer);

   procedure internalexecute;
   function execute(var avalue: msestring): boolean; virtual;
   procedure setexecresult(var avalue: msestring); virtual;
   function iskeyexecute(const info: keyeventinfoty): boolean; virtual;
  public
   constructor create(aowner: tcomponent); override;
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

 tcustomdialogstringedit = class; 
 dialogexeceventty = procedure(const sender: tcustomdialogstringedit;
            var avalue:msestring; var modresult: modalresultty) of object;
                                       //default mr_ok 
 tcustomdialogstringedit = class(tcustomdialogstringed)
  private
   fonexecute: dialogexeceventty;
  protected
   function execute(var avalue: msestring): boolean; override;
  public
   property onexecute: dialogexeceventty read fonexecute write fonexecute;
 end;

 tdialogstringedit = class(tcustomdialogstringedit)
  published
   property onexecute;
 end;
 
implementation
uses
 msestockobjects,msekeyboard,mseeditglob;

{ tdialogform }

procedure tdialogform.updatewindowinfo(var info: windowinfoty);
begin
 inherited;
 info.options:= [wo_message];
end;

class function tdialogform.hasresource: boolean;
begin
 result:= false;
end;

{ tellipsebuttonframe }

constructor tellipsebuttonframe.create(const intf: icaptionframe;
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

{ tcustomdialogstringed }

constructor tcustomdialogstringed.create(aowner: tcomponent);
begin
 inherited;
 internalcreateframe;
end;

procedure tcustomdialogstringed.buttonaction(var action: buttonactionty;
  const buttonindex: integer);
begin
 if action = ba_click then begin
  if canfocus and not setfocus then begin
   exit;
  end;
  internalexecute;
 end;
end;

procedure tcustomdialogstringed.internalcreateframe;
begin
 tellipsebuttonframe.create(iscrollframe(self),ibutton(self));
 updatereadonlystate;
end;

function tcustomdialogstringed.execute(var avalue: msestring): boolean;
begin
 result:= false;
end;

procedure tcustomdialogstringed.setexecresult(var avalue: msestring);
begin
 text:= avalue;
end;

procedure tcustomdialogstringed.internalexecute;
var
 str1: msestring;
begin
 str1:= text;
 if execute(str1) then begin
  setexecresult(str1);
  checkvalue;
 end;
end;

procedure tcustomdialogstringed.mouseevent(var info: mouseeventinfoty);
begin
 inherited;
 tcustombuttonframe(fframe).mouseevent(info);
end;

function tcustomdialogstringed.iskeyexecute(const info: keyeventinfoty): boolean;

begin
 with info do begin
  result:= (oe_keyexecute in foptionsedit) and (key = key_down) and 
           (shiftstate = [ss_alt]);
 end;
end;

procedure tcustomdialogstringed.dokeydown(var info: keyeventinfoty);
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

function tcustomdialogstringed.getframe: tellipsebuttonframe;
begin
 result:= tellipsebuttonframe(inherited getframe);
end;

procedure tcustomdialogstringed.setframe(const avalue: tellipsebuttonframe);
begin
 inherited setframe(avalue);
end;

procedure tcustomdialogstringed.updatereadonlystate;
begin
 inherited;
 if fframe <> nil then begin
  with frame do begin
   if buttons.count > 0 then begin
    frame.buttons[0].enabled:= not (oe_readonly in getoptionsedit);
   end;
  end;
 end;
end;

{ tcustomdialogstringedit }

function tcustomdialogstringedit.execute(var avalue: msestring): boolean;
var
 mr1: modalresultty;
begin
 if canevent(tmethod(fonexecute)) then begin
  mr1:= mr_ok;
  fonexecute(self,avalue,mr1);
  result:= mr1 = mr_ok;
 end
 else begin
  result:= false;
 end;
end;

end.
