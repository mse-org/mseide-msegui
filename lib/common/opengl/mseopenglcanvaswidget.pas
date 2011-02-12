{ MSEgui Copyright (c) 2011 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseopenglcanvaswidget;
//
// under construction
//
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 msewindowwidget,msegraphics,mseopengl,classes,msegraphutils,mseguiglob,msetypes;
 
type

 topenglcanvaswidget = class;
 openglcanvasrendereventty = procedure(const sender: topenglcanvaswidget;
                                 const aupdaterect: rectty) of object;

 topenglcanvaswidget = class(tcustomwindowwidget,icanvas)
  private
   fcanvas: topenglcanvas;
   fonrender: openglcanvasrendereventty;
   procedure setcanvas(const avalue: topenglcanvas);
  protected
   procedure doclientrectchanged; override;
   procedure docreatewinid(const aparent: winidty; const awidgetrect: rectty;
                  var aid: winidty); override;
   procedure dodestroywinid; override;
   procedure doclientpaint(const aupdaterect: rectty); override;
   procedure updateviewport(const arect: rectty); override;
     //icanvas
   procedure gcneeded(const sender: tcanvas);
   function getmonochrome: boolean;
   function getsize: sizety;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property canvas: topenglcanvas read fcanvas write setcanvas;
  published
   property onrender: openglcanvasrendereventty read fonrender write fonrender;
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
//   property onclientpaint;
   property onclientrectchanged;
   property onwindowmouseevent;
   property onwindowmousewheelevent;
   property ondestroy;
 end;
 
implementation
type
 topenglcanvas1 = class(topenglcanvas);
 
{ topenglcanvaswidget }

constructor topenglcanvaswidget.create(aowner: tcomponent);
begin
 fcanvas:= topenglcanvas.create(self,icanvas(self));
 inherited;
end;

destructor topenglcanvaswidget.destroy;
begin
 fcanvas.free;
 inherited;
end;

procedure topenglcanvaswidget.setcanvas(const avalue: topenglcanvas);
begin
 fcanvas.assign(avalue);
end;

procedure topenglcanvaswidget.gcneeded(const sender: tcanvas);
begin
 checkclientwinid;
end;

function topenglcanvaswidget.getmonochrome: boolean;
begin
 result:= false;
end;

function topenglcanvaswidget.getsize: sizety;
begin
 result:= paintsize;
end;

procedure topenglcanvaswidget.docreatewinid(const aparent: winidty;
               const awidgetrect: rectty; var aid: winidty);
begin
 fcanvas.linktopaintdevice(aparent,awidgetrect,aid);
end;

procedure topenglcanvaswidget.updateviewport(const arect: rectty);
begin
 fcanvas.viewport:= arect;
 inherited;
end;

procedure topenglcanvaswidget.doclientrectchanged;
begin
 inherited;
end;

procedure topenglcanvaswidget.dodestroywinid;
begin
 fcanvas.unlink;
 inherited;
end;

procedure topenglcanvaswidget.doclientpaint(const aupdaterect: rectty);
begin
 if canevent(tmethod(fonrender)) then begin
  fcanvas.reset;
  fonrender(self,aupdaterect);
  fcanvas.swapbuffers;
 end;
end;

end.
