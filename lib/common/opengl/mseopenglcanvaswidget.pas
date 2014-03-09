{ MSEgui Copyright (c) 2011-2013 by Martin Schreiber

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
 msewindowwidget,msegraphics,mseopengl,classes,mclasses,msegraphutils,
 msegui,msemenus,mseguiglob,msetypes;
 
type

 topenglwidgetcanvas = class(topenglcanvas)
  protected
   procedure linktopaintdevice(const aparent: winidty;
             const awindowrect: rectty; out aid: winidty); reintroduce;
  public
   constructor create(const user: tobject; const intf: icanvas); override;
  published
   property options;
 {
   property monochrome;
   property color;
   property colorbackground;
   property rasterop;
   property font;
   property brush;

   property linewidth;
   property linewidthmm;
   
   property dashes;
     //last byte 0 -> opaque dash  //todo: dashoffset
   property capstyle;
   property joinstyle;
   property lineoptions;

   property ppmm; 
                   //used for linewidth mm, value not saved/restored
  }
 end;

 topenglcanvaswidget = class;
 openglcanvasrendereventty = procedure(const sender: topenglcanvaswidget;
                                 const aupdaterect: rectty) of object;

 topenglcanvaswidget = class(tcustomwindowwidget,icanvas)
  private
   fcanvas: topenglwidgetcanvas;
   fonrender: openglcanvasrendereventty;
   procedure setcanvas(const avalue: topenglwidgetcanvas);
  protected
   procedure readstate(reader: treader); override;
   procedure doclientrectchanged; override;
   procedure docreatewinid(const aparent: winidty; const awidgetrect: rectty;
                  var aid: winidty); override;
   procedure dodestroywinid; override;
   function canclientpaint: boolean; override;
   procedure doclientpaint(const aupdaterect: rectty); override;
   procedure updateviewport(const arect: rectty); override;
     //icanvas
   procedure gcneeded(const sender: tcanvas);
//   function getmonochrome: boolean;
   function getkind: bitmapkindty;
   function getsize: sizety;
   procedure getcanvasimage(const bgr: boolean; var aimage: maskedimagety);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property canvas: topenglwidgetcanvas read fcanvas write setcanvas;
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
uses
 mseopenglgdi,msegl;
 
type
 topenglcanvas1 = class(topenglcanvas);
 
{ topenglcanvaswidget }

constructor topenglcanvaswidget.create(aowner: tcomponent);
begin
 fcanvas:= topenglwidgetcanvas.create(self,icanvas(self));
 inherited;
end;

destructor topenglcanvaswidget.destroy;
begin
 inherited;
 fcanvas.free;
end;

procedure topenglcanvaswidget.setcanvas(const avalue: topenglwidgetcanvas);
begin
 fcanvas.assign(avalue);
end;

procedure topenglcanvaswidget.gcneeded(const sender: tcanvas);
begin
 checkclientwinid;
end;
{
function topenglcanvaswidget.getmonochrome: boolean;
begin
 result:= false;
end;
}
function topenglcanvaswidget.getkind: bitmapkindty;
begin
 result:= bmk_rgb;
end;

function topenglcanvaswidget.getsize: sizety;
begin
 result:= paintsize;
end;

procedure topenglcanvaswidget.docreatewinid(const aparent: winidty;
               const awidgetrect: rectty; var aid: winidty);
begin
 initializeopengl([]);
 fcanvas.linktopaintdevice(aparent,awidgetrect,aid);
 checkwindowrect;
end;

procedure topenglcanvaswidget.updateviewport(const arect: rectty);
begin
 fcanvas.viewport:= arect;
 inherited;
end;

procedure topenglcanvaswidget.doclientrectchanged;
begin
 fcanvas.updatesize(innerpaintrect.size);
 inherited;
end;

procedure topenglcanvaswidget.dodestroywinid;
begin
 fcanvas.unlink;
 inherited;
 releaseopengl;
end;

procedure topenglcanvaswidget.doclientpaint(const aupdaterect: rectty);
begin
 if canevent(tmethod(fonrender)) then begin
  fcanvas.reset;
  fonrender(self,aupdaterect);
  fcanvas.endpaint;
 end;
end;

function topenglcanvaswidget.canclientpaint: boolean;
begin
 result:= assigned(fonrender);
end;

procedure topenglcanvaswidget.getcanvasimage(const bgr: boolean;
               var aimage: maskedimagety);
begin
 //dummy
end;

procedure topenglcanvaswidget.readstate(reader: treader);
begin
 fcanvas.beforeread;
 try
  inherited;
 finally
  fcanvas.afterread;
 end; 
end;

{ topenglwidgetcanvas }

procedure topenglwidgetcanvas.linktopaintdevice(const aparent: winidty;
               const awindowrect: rectty; out aid: winidty);
var
 gc1: gcty;
 info: drawinfoty;
begin
 fillchar(gc1,sizeof(gc1),0);
 fillchar(info,sizeof(info),0);
 gc1.kind:= bmk_rgb;
 with info.creategc do begin
  gcpo:= @gc1;
  contextinfopo:= @fcontextinfo;
  windowrect:= @awindowrect;
  parent:= aparent;
  kind:= gck_screen;
  createpaintdevice:= true;
  gdi_lock;
  fdrawinfo.gc.gdifuncs^[gdf_creategc](info);
  gdi_unlock;
  aid:= paintdevice;
 end;
 gc1.paintdevicesize:= awindowrect.size;
 inherited linktopaintdevice(paintdevicety(aid),gc1,nullpoint);
end;

constructor topenglwidgetcanvas.create(const user: tobject;
               const intf: icanvas);
begin
 inherited;
// if not flushgdi then begin
//  fcontextinfo.attrib.doublebuffer:= true;
// end;
end;

end.
