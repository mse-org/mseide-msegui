{ MSEgui Copyright (c) 2007 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msewindowwidget;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 classes,msegui,msetypes,msegraphutils,mseguiintf,msewidgets;
 
type
 twindowwidget = class(tpublishedwidget)
  private
   fclientwinid: winidty;
   function getclientwinid: winidty;
  protected
   procedure checkclientwinid;
   procedure checkclientvisible;
   procedure destroyclientwindow;
   procedure clientrectchanged; override;
   procedure visiblechanged; override;
   procedure winiddestroyed(const awinid: winidty);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property clientwinid: winidty read getclientwinid;
 end;
 
implementation
uses
 mseguiglob;
 
type
 twindow1 = class(twindow);
  
{ twindowwidget }

constructor twindowwidget.create(aowner: tcomponent);
begin
 application.registeronwiniddestroyed({$ifdef FPC}@{$endif}winiddestroyed);
 inherited;
end;

destructor twindowwidget.destroy;
begin
 application.unregisteronwiniddestroyed({$ifdef FPC}@{$endif}winiddestroyed);
 if (fwindow <> nil) and (twindow1(fwindow).haswinid) then begin
  destroyclientwindow;
 end;
 inherited;
end;

function twindowwidget.getclientwinid: winidty;
begin
 checkclientwinid;
 result:= fclientwinid;
end;

procedure twindowwidget.checkclientwinid;
var
 options1: internalwindowoptionsty;
 rect1: rectty;
begin
 if fclientwinid = 0 then begin
  rect1:= innerwidgetrect;
  addpoint1(rect1.pos,rootpos);
  fillchar(options1,sizeof(options1),0);
  options1.parent:= window.winid;
  guierror(gui_createwindow(rect1,options1,fclientwinid),self);
  checkclientvisible;
 end;  
end;

procedure twindowwidget.destroyclientwindow;
begin
 if fclientwinid <> 0 then begin
  gui_destroywindow(fclientwinid);
  fclientwinid:= 0;
 end;
end;

procedure twindowwidget.clientrectchanged;
var
 rect1: rectty;
begin
 inherited;
 if fclientwinid <> 0 then begin
  rect1:= innerwidgetrect;
  addpoint1(rect1.pos,rootpos);
  gui_reposwindow(fclientwinid,rect1,true);
 end;  
end;

procedure twindowwidget.visiblechanged;
begin
 inherited;
 checkclientvisible;
end;

procedure twindowwidget.checkclientvisible;
begin
 if fclientwinid <> 0 then begin
  if isvisible and parentisvisible then begin
   gui_showwindow(fclientwinid);
  end
  else begin
   gui_hidewindow(fclientwinid);
  end;
 end;
end;

procedure twindowwidget.winiddestroyed(const awinid: winidty);
begin
 if awinid = fclientwinid then begin
  fclientwinid:= 0;
 end;
end;

end.
