{ MSEgui Copyright (c) 2007 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msewindowwidget;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 classes,msegui,msetypes,msegraphutils,mseguiintf,msewidgets,msegraphics,
 msesimplewidgets,mseevent,msemenus;
 
type
 tcustomwindowwidget = class;

 windowwidgeteventty = procedure(const sender: tcustomwindowwidget) of object; 
 windowwidgetpainteventty = procedure(const sender: tcustomwindowwidget;
                                const aupdaterect: rectty) of object; 
 createwinideventty = procedure(const sender: tcustomwindowwidget; const aparent: winidty;
                       const awidgetrect: rectty; var aid: winidty) of object;
 destroywinideventty = procedure(const sender: tcustomwindowwidget;
                       const aid: winidty) of object;
                        
 tcustomwindowwidget = class(teventwidget)
  private
   fclientwindow: windowty;
   fchildrect: rectty;
   fviewport: rectty;
   faspect: real;
   foncreatewinid: createwinideventty;
   fondestroywinid: destroywinideventty;
   fonclientpaint: windowwidgetpainteventty;
   fonclientrectchanged: windowwidgeteventty;
   fondestroy: windowwidgeteventty;
   fonloaded: windowwidgeteventty;
   fonwindowmouseevent: mouseeventty;
   fwindowmouseentered: boolean;
   fonwindowmousewheelevent: mousewheeleventty;
   function getclientwinid: winidty;
   procedure checkwindowrect;
   procedure windowscrolled(const sender: tobject);
   function getchildrect: rectty;
   function getviewport: rectty;
  protected
   procedure checkclientwinid;
   procedure checkclientvisible;
   procedure destroyclientwindow;
 //  procedure clientrectchanged; override;
//   procedure poschanged; override;
   procedure visiblechanged; override;
   procedure winiddestroyed(const awinid: winidty);
   procedure docreatewinid(const aparent: winidty; const awidgetrect: rectty;
                  var aid: winidty); virtual;
   procedure dodestroywinid; virtual;
   procedure doclientrectchanged; virtual;
   procedure doclientpaint(const aupdaterect: rectty); virtual;
   procedure doonpaint(const acanvas: tcanvas); override;
   procedure doloaded; override;
   procedure updateviewport(const arect: rectty); virtual;
   procedure clientmouseevent(var info: mouseeventinfoty); override;
   procedure domousewheelevent(var info: mousewheeleventinfoty); override;

   procedure clienttoviewport(var apoint: pointty; const arect: rectty);
   procedure viewporttoclient(var apoint: pointty; const arect: rectty);
              
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function createchildwindow: winidty;
   function hasclientwinid: boolean;
   property clientwinid: winidty read getclientwinid;
   property childrect: rectty read getchildrect;
   property viewport: rectty read getviewport;
   property aspect: real read faspect;
   
   property oncreatewinid: createwinideventty read foncreatewinid 
                                     write foncreatewinid;
   property ondestroywinid: destroywinideventty read fondestroywinid 
                                     write fondestroywinid;
   property onclientpaint: windowwidgetpainteventty read fonclientpaint
                                  write fonclientpaint;
   property onclientrectchanged: windowwidgeteventty read fonclientrectchanged 
                                     write fonclientrectchanged;   
   property ondestroy: windowwidgeteventty read fondestroy write fondestroy;     
   property ondloaded: windowwidgeteventty read fonloaded write fonloaded;    
   property onwindowmouseevent: mouseeventty read fonwindowmouseevent 
            write fonwindowmouseevent; //origin viewport.pos
   property onwindowmousewheelevent: mousewheeleventty read 
                fonwindowmousewheelevent write fonwindowmousewheelevent;
 end;

 twindowwidget = class(tcustomwindowwidget)
  published
   property optionswidget;
   property optionsskin;
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
   property onwindowmouseevent;
   property onwindowmousewheelevent;
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
 if fwindow <> nil then begin
  fwindow.unregisteronscroll({$ifdef FPC}@{$endif}windowscrolled);
 end;
 if candestroyevent(tmethod(fondestroy)) then begin
  fondestroy(self);
 end;
 application.unregisteronwiniddestroyed({$ifdef FPC}@{$endif}winiddestroyed);
 destroyclientwindow;
 inherited;
end;

function tcustomwindowwidget.getclientwinid: winidty;
begin
 checkclientwinid;
 result:= fclientwindow.id;
end;

function tcustomwindowwidget.createchildwindow: winidty;
var
 options1: internalwindowoptionsty;
 rect1: rectty;
begin
 rect1:= innerwidgetrect;
 addpoint1(rect1.pos,rootpos);
 fillchar(options1,sizeof(options1),0);
 options1.parent:= window.winid;
 guierror(gui_createwindow(rect1,options1,fclientwindow),self);
 result:= fclientwindow.id;
end;

procedure tcustomwindowwidget.checkclientwinid;
var
 options1: internalwindowoptionsty;
 rect1: rectty;
begin
 if fclientwindow.id = 0 then begin
  rect1:= innerwidgetrect;
  addpoint1(rect1.pos,rootpos);
  docreatewinid(window.winid,rect1,fclientwindow.id);
  if fclientwindow.id = 0 then begin
   createchildwindow;
  end;
  if fwindow <> nil then begin
   fwindow.registeronscroll({$ifdef FPC}@{$endif}windowscrolled);
  end;
  checkclientvisible;
 end;  
end;

procedure tcustomwindowwidget.destroyclientwindow;
begin
 if fclientwindow.id <> 0 then begin
  dodestroywinid;
 end;
 gui_destroywindow(fclientwindow);
 fillchar(fclientwindow,sizeof(fclientwindow),0);
 fchildrect:= nullrect;
end;

procedure tcustomwindowwidget.doclientrectchanged;
begin
 if canevent(tmethod(fonclientrectchanged)) then begin
  fonclientrectchanged(self);
 end;
end;

procedure tcustomwindowwidget.checkwindowrect;
var
 rect1,rect2,rect3: rectty;
 bo1: boolean;
begin
 if fclientwindow.id <> 0 then begin
  bo1:= false;
  rect1:= innerwidgetrect;
  rect2:= intersectrect(rect1,clippedpaintrect);
  rect1.x:= rect1.x - rect2.x;
  rect1.y:= rect2.y + rect2.cy - rect1.y - rect1.cy;
  addpoint1(rect2.pos,rootpos);
  if not rectisequal(rect2,fchildrect) then begin
   bo1:= true;
   fchildrect:= rect2;
   gui_setdecoratedwindowrect(fclientwindow.id,rect2,rect3);
//   gui_reposwindow(fclientwindow.id,rect2,true);
  end;
  if not rectisequal(rect1,fviewport) then begin
   bo1:= true;
   if rect1.cy = 0 then begin
    faspect:= 1;
   end
   else begin
    faspect:= -rect1.cx/rect1.cy;
   end;
   fviewport:= rect1;
   updateviewport(fviewport);
  end;
  if bo1 then begin 
   doclientrectchanged;
  end;
 end;
end;
{
procedure tcustomwindowwidget.clientrectchanged;
begin
 inherited;
// checkwindowrect;
 if canevent(tmethod(fonclientrectchanged)) then begin
  fonclientrectchanged(self);
 end;
end;

procedure tcustomwindowwidget.poschanged;
begin
// checkwindowrect;
 inherited;
end;
}
procedure tcustomwindowwidget.visiblechanged;
begin
 inherited;
 checkclientvisible;
end;

procedure tcustomwindowwidget.checkclientvisible;
begin
 if fclientwindow.id <> 0 then begin
  if isvisible and parentisvisible then begin
   gui_showwindow(fclientwindow.id);
  end
  else begin
   gui_hidewindow(fclientwindow.id);
  end;
 end;
end;

procedure tcustomwindowwidget.winiddestroyed(const awinid: winidty);
begin
 if awinid = fclientwindow.id then begin
  fclientwindow.id:= 0;
 end;
 if (fwindow <> nil) and (fwindow.haswinid) then begin
  destroyclientwindow;
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
  fondestroywinid(self,fclientwindow.id);
 end;
end;

procedure tcustomwindowwidget.doclientpaint(const aupdaterect: rectty);
begin
 if canevent(tmethod(fonclientpaint)) then begin
  fonclientpaint(self,aupdaterect);
 end;
end;

procedure tcustomwindowwidget.doonpaint(const acanvas: tcanvas);
begin
 if not (csdesigning in componentstate) then begin
  checkclientwinid;   
  checkwindowrect;
  doclientpaint(acanvas.clipbox);
 end;
 inherited;
end;

function tcustomwindowwidget.hasclientwinid: boolean;
begin
 result:= fclientwindow.id <> 0;
end;

procedure tcustomwindowwidget.doloaded;
begin
 inherited;
 if canevent(tmethod(fonloaded)) then begin
  fonloaded(self);
 end;
end;

function tcustomwindowwidget.getchildrect: rectty;
begin
 checkwindowrect;
 result:= fchildrect;
end;

function tcustomwindowwidget.getviewport: rectty;
begin
 checkwindowrect;
 result:= fviewport;
end;

procedure tcustomwindowwidget.updateviewport(const arect: rectty);
begin
 //dummy
end;

procedure tcustomwindowwidget.clienttoviewport(var apoint: pointty;
               const arect: rectty);
begin
 apoint.x:= apoint.x - arect.x;
 apoint.y:= arect.cy - apoint.y + arect.y;
end;

procedure tcustomwindowwidget.viewporttoclient(var apoint: pointty;
               const arect: rectty);
begin
 apoint.x:= apoint.x + arect.x;
 apoint.y:=  arect.cy + arect.y - apoint.y;
end;


procedure tcustomwindowwidget.clientmouseevent(var info: mouseeventinfoty);
 procedure enterevent(const aenter: boolean);
 var
  info1: mouseeventinfoty;
 begin
  if aenter xor fwindowmouseentered then begin
   fwindowmouseentered:= aenter;
   info1:= info;
   if aenter then begin
    info1.eventkind:= ek_clientmouseenter;
   end
   else begin
    info1.eventkind:= ek_clientmouseleave;
   end;
  end;
  info1.pos:= nullpoint;
  fonwindowmouseevent(self,info1);
 end;
var
 pt1: pointty;
 rect1: rectty;
begin
 inherited;
 if canevent(tmethod(fonwindowmouseevent)) then begin
  if info.eventkind in mouseposevents then begin
   checkwindowrect;
   rect1:= innerclientrect;
   if pointinrect(info.pos,rect1) or 
           (ws_clientmousecaptured in fwidgetstate) then begin
    enterevent(true);
    clienttoviewport(info.pos,rect1);
    if not (es_processed in info.eventstate) then begin
     try
      fonwindowmouseevent(self,info);
     finally
      viewporttoclient(info.pos,rect1);
     end;
    end;
   end
   else begin
    enterevent(false);
   end;
  end
  else begin
   if info.eventkind = ek_clientmouseleave then begin
    enterevent(false);
   end;
  end;
 end;
end;

procedure tcustomwindowwidget.domousewheelevent(var info: mousewheeleventinfoty);
var
 rect1: rectty;
begin
 if canevent(tmethod(fonwindowmousewheelevent)) then begin
  rect1:= innerclientrect;
  if pointinrect(info.pos,rect1) then begin
   clienttoviewport(info.pos,rect1);
   try
    fonwindowmousewheelevent(self,info);
   finally
    viewporttoclient(info.pos,rect1);
   end;
  end;
 end;
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;

procedure tcustomwindowwidget.windowscrolled(const sender: tobject);
begin
 checkwindowrect;
end;

end.
