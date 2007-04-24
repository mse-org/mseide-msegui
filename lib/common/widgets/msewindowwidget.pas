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
 classes,msegui,msetypes,msegraphutils,mseguiintf,msewidgets,msegraphics;
 
type
 tcustomwindowwidget = class;

 windowwidgeteventty = procedure(const sender: tcustomwindowwidget) of object; 
 createwinideventty = procedure(const sender: tcustomwindowwidget; const aparent: winidty;
                       const awidgetrect: rectty; var aid: winidty) of object;
 destroywinideventty = procedure(const sender: tcustomwindowwidget;
                       const aid: winidty) of object;
                        
 tcustomwindowwidget = class(tactionwidget)
  private
   fclientwinid: winidty;
   foncreatewinid: createwinideventty;
   fondestroywinid: destroywinideventty;
   fonclientpaint: windowwidgeteventty;
   fonclientrectchanged: windowwidgeteventty;
   fondestroy: windowwidgeteventty;
   fonloaded: windowwidgeteventty;
   function getclientwinid: winidty;
  protected
   procedure checkclientwinid;
   procedure checkclientvisible;
   procedure destroyclientwindow;
   procedure clientrectchanged; override;
   procedure visiblechanged; override;
   procedure winiddestroyed(const awinid: winidty);
   procedure docreatewinid(const aparent: winidty; const awidgetrect: rectty;
                  var aid: winidty); virtual;
   procedure dodestroywinid; virtual;
   procedure doclientpaint; virtual;
   procedure doonpaint(const acanvas: tcanvas); override;
   procedure doloaded; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function hasclientwinid: boolean;
   property clientwinid: winidty read getclientwinid;
   property oncreatewinid: createwinideventty read foncreatewinid 
                                     write foncreatewinid;
   property ondestroywinid: destroywinideventty read fondestroywinid 
                                     write fondestroywinid;
   property onclientpaint: windowwidgeteventty read fonclientpaint write fonclientpaint;
   property onclientrectchanged: windowwidgeteventty read fonclientrectchanged 
                                     write fonclientrectchanged;   
   property ondestroy: windowwidgeteventty read fondestroy write fondestroy;     
   property ondloaded: windowwidgeteventty read fonloaded write fonloaded;     
 end;

 twindowwidget = class(tcustomwindowwidget)
  published
   property optionswidget;
   property bounds_x;
   property bounds_y;
   property bounds_cx;
   property bounds_cy;
   property bounds_cxmin;
   property bounds_cymin;
   property bounds_cxmax;
   property bounds_cymax;
   property color;
   property cursor;
   property frame;
   property face;
   property anchors;
   property taborder;
   property hint;
   property popupmenu;
   property onpopup;
   property onshowhint;
   property enabled;
   property visible;
   property oncreatewinid;
   property ondestroywinid;
   property onclientpaint;
   property onclientrectchanged;
   property ondestroy;
 end;
 
implementation
uses
 mseguiglob;
 
type
 twindow1 = class(twindow);
  
{ tcustomwindowwidget }

constructor tcustomwindowwidget.create(aowner: tcomponent);
begin
 application.registeronwiniddestroyed({$ifdef FPC}@{$endif}winiddestroyed);
 inherited;
end;

destructor tcustomwindowwidget.destroy;
begin
 if candestroyevent(tmethod(fondestroy)) then begin
  fondestroy(self);
 end;
 application.unregisteronwiniddestroyed({$ifdef FPC}@{$endif}winiddestroyed);
 if (fwindow <> nil) and (twindow1(fwindow).haswinid) then begin
  destroyclientwindow;
 end;
 inherited;
end;

function tcustomwindowwidget.getclientwinid: winidty;
begin
 checkclientwinid;
 result:= fclientwinid;
end;

procedure tcustomwindowwidget.checkclientwinid;
var
 options1: internalwindowoptionsty;
 rect1: rectty;
begin
 if fclientwinid = 0 then begin
  rect1:= innerwidgetrect;
  addpoint1(rect1.pos,rootpos);
  docreatewinid(window.winid,rect1,fclientwinid);
  if fclientwinid = 0 then begin
   fillchar(options1,sizeof(options1),0);
   options1.parent:= window.winid;
   guierror(gui_createwindow(rect1,options1,fclientwinid),self);
  end;
  checkclientvisible;
 end;  
end;

procedure tcustomwindowwidget.destroyclientwindow;
begin
 if fclientwinid <> 0 then begin
  dodestroywinid;
  gui_destroywindow(fclientwinid);
  fclientwinid:= 0;
 end;
end;

procedure tcustomwindowwidget.clientrectchanged;
var
 rect1: rectty;
begin
 inherited;
 if fclientwinid <> 0 then begin
  rect1:= innerwidgetrect;
  addpoint1(rect1.pos,rootpos);
  gui_reposwindow(fclientwinid,rect1,true);
 end;
 if canevent(tmethod(fonclientrectchanged)) then begin
  fonclientrectchanged(self);
 end;
end;

procedure tcustomwindowwidget.visiblechanged;
begin
 inherited;
 checkclientvisible;
end;

procedure tcustomwindowwidget.checkclientvisible;
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

procedure tcustomwindowwidget.winiddestroyed(const awinid: winidty);
begin
 if awinid = fclientwinid then begin
  fclientwinid:= 0;
 end;
end;

procedure tcustomwindowwidget.docreatewinid(const aparent: winidty;
               const awidgetrect: rectty; var aid: winidty);
begin
 if canevent(tmethod(foncreatewinid)) then begin
  foncreatewinid(self,aparent,awidgetrect,aid);
 end;
end;

procedure tcustomwindowwidget.dodestroywinid;
begin
 if canevent(tmethod(fondestroywinid)) then begin
  fondestroywinid(self,fclientwinid);
 end;
end;

procedure tcustomwindowwidget.doclientpaint;
begin
 if canevent(tmethod(fonclientpaint)) then begin
  fonclientpaint(self);
 end;
end;

procedure tcustomwindowwidget.doonpaint(const acanvas: tcanvas);
begin
 doclientpaint;
 inherited;
end;

function tcustomwindowwidget.hasclientwinid: boolean;
begin
 result:= fclientwinid <> 0;
end;

procedure tcustomwindowwidget.doloaded;
begin
 inherited;
 if canevent(tmethod(fonloaded)) then begin
  fonloaded(self);
 end;
end;

end.
