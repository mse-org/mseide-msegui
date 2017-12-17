{ MSEgui Copyright (c) 2017 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseassistivehandler;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 classes,mclasses,mseclasses,mseassistiveserver,
 mseguiglob,mseglob,msestrings,mseinterfaces,mseact,mseshapes,
 mseassistiveclient,msemenuwidgets,msegrids;

type
 assistivehandlerstatety = (ahs_active);
 assistivehandlerstatesty = set of assistivehandlerstatety;

 tassistivehandler = class(tmsecomponent,iassistiveserver)
  private
   factive: boolean;
   procedure setactive(const avalue: boolean);
   procedure activate();
   procedure deactivate();
  protected
   fstate: assistivehandlerstatesty;
   procedure loaded() override;
   
    //iassistiveserver
   procedure doenter(const sender: iassistiveclient);
   procedure doitementer(const sender: iassistiveclient; //sender can be nil
                             const items: shapeinfoarty; const aindex: integer);
   procedure doitementer(const sender: iassistiveclient; //sender can be nil
                          const items: menucellinfoarty; const aindex: integer);
   procedure clientmouseevent(const sender: iassistiveclient;
                                           const info: mouseeventinfoty);
   procedure dofocuschanged(const oldwidget,newwidget: iassistiveclient);
   procedure dokeydown(const sender: iassistiveclient;
                                         const info: keyeventinfoty);
   procedure doactionexecute(const sender: tobject; const info: actioninfoty);
   procedure dochange(const sender: iassistiveclient);
   procedure docellevent(const sender: iassistiveclientgrid; 
                                       const info: celleventinfoty);
  published
   property active: boolean read factive write setactive default false;
 end;
 
implementation
uses
 msegui;
 
{ tassistivehandler }

procedure tassistivehandler.setactive(const avalue: boolean);
begin
 if factive <> avalue then begin
  factive:= avalue;
  if not (csloading in componentstate) then begin
   if avalue then begin
    activate();
   end
   else begin
    deactivate();
   end;
  end;
 end;
end;

procedure tassistivehandler.activate();
begin
 if not (csdesigning in componentstate) then begin
  assistiveserver:= iassistiveserver(self);
  include(fstate,ahs_active);
 end;
end;

procedure tassistivehandler.deactivate();
begin
 if not (csdesigning in componentstate) then begin
  assistiveserver:= nil;
  exclude(fstate,ahs_active);
 end;
end;

procedure tassistivehandler.loaded();
begin
 inherited;
 if factive then begin
  factive:= false;
  active:= true;
 end;
end;

procedure tassistivehandler.doenter(const sender: iassistiveclient);
begin
 guibeep();
end;

procedure tassistivehandler.doitementer(const sender: iassistiveclient;
               const items: shapeinfoarty; const aindex: integer);
begin
end;

procedure tassistivehandler.doitementer(const sender: iassistiveclient;
               const items: menucellinfoarty; const aindex: integer);
begin
end;

procedure tassistivehandler.clientmouseevent(const sender: iassistiveclient;
               const info: mouseeventinfoty);
begin
end;

procedure tassistivehandler.dofocuschanged(const oldwidget: iassistiveclient;
               const newwidget: iassistiveclient);
begin
end;

procedure tassistivehandler.dokeydown(const sender: iassistiveclient;
               const info: keyeventinfoty);
begin
end;

procedure tassistivehandler.doactionexecute(const sender: tobject;
               const info: actioninfoty);
begin
end;

procedure tassistivehandler.dochange(const sender: iassistiveclient);
begin
end;

procedure tassistivehandler.docellevent(const sender: iassistiveclientgrid;
               const info: celleventinfoty);
begin
end;

end.
