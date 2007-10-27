{ MSEgui Copyright (c) 1999-2007 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseguiactions;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 mseactions,msegui,mseevent,mseclasses,msebitmap;
type
 taction = class(tcustomaction)
  private
   function getimagelist: timagelist;
   procedure setimagelist(const Value: timagelist);
  protected
   procedure registeronshortcut(const avalue: boolean); override;
   procedure doshortcut(const sender: twidget; var info: keyeventinfoty);
   procedure doafterunlink; override;
  published
   property imagelist: timagelist read getimagelist write setimagelist;
   property caption;
   property state;
   property group;
   property tagaction;
//   property imagelist;
   property imagenr;
   property imagenrdisabled;
   property colorglyph;
   property color;
   property imagecheckedoffset;
   property hint;
   property shortcut;
   property statfile;
   property statvarname;
   property options;
   property onexecute;
   property onupdate;
   property onchange;
   property onasyncevent;
 end;

procedure setactionimagelist(const sender: iactionlink; const value: timagelist);
function isactionimageliststored(const info: actioninfoty): boolean;
 
implementation

procedure setactionimagelist(const sender: iactionlink; const value: timagelist);
begin
 with sender.getactioninfopo^ do begin
  if not (as_localimagelist in state) then begin
   imagelist:= nil; //do not unink,imagelist is owned by action
  end;
  setlinkedcomponent(sender,value,tmsecomponent(imagelist));
  include(state,as_localimagelist);
 end;
 sender.actionchanged;
end;

function isactionimageliststored(const info: actioninfoty): boolean;
begin
 with info do begin
  result:= (as_localimagelist in state) and
         not ((action = nil) and (imagelist = nil));
 end;
end;

 
{ taction }

function taction.getimagelist: timagelist;
begin
 result:= timagelist(finfo.imagelist);
end;

procedure taction.setimagelist(const Value: timagelist);
begin
 if value <> finfo.imagelist then begin
  setlinkedvar(value,tmsecomponent(finfo.imagelist));
  changed;
 end;
end;

procedure taction.registeronshortcut(const avalue: boolean);
begin
 if avalue then begin
  application.registeronshortcut({$ifdef FPC}@{$endif}doshortcut);
 end
 else begin
  application.unregisteronshortcut({$ifdef FPC}@{$endif}doshortcut);
 end;
end;

procedure taction.doshortcut(const sender: twidget; var info: keyeventinfoty);
begin
 if not (es_local in info.eventstate) and (ao_globalshortcut in foptions) or 
        (es_local in info.eventstate) and (ao_localshortcut in foptions) and
                (owner <> nil) and issubcomponent(owner,sender) then begin
  doupdate;
  if doactionshortcut(self,finfo,info) then begin
   changed;
  end;
 end;
end;

procedure taction.doafterunlink;
begin
 imagelist:= nil;
end;

end.
