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
{$if defined(usesdl2) or defined(usesdl3) or defined(usewayland) or defined(usehybrid)}
 {$define offscreengl}   //no native child window: EGL pbuffer, the picture
{$endif}                 //is copied into the widget

interface
uses
 msewindowwidget,msegraphics,mseopengl,classes,mclasses,mseclasses,
 msegraphutils,{$ifdef offscreengl}msebitmap,{$endif}
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
   {$ifdef offscreengl}
   fbitmap: tbitmap;
   fpixels: array of longword;
   frowbuffer: array of longword;
   flinked: boolean;
   fglused: boolean;
   ffailed: boolean;
   ffresh: boolean;
   procedure renderoffscreen;
   {$endif}
   procedure setcanvas(const avalue: topenglwidgetcanvas);
  protected
   {$ifdef offscreengl}
   procedure doonpaint(const acanvas: tcanvas); override;
   {$endif}
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
 mseopenglgdi,msegl,sysutils{$ifdef offscreengl},mseglext{$endif};

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
{$ifdef offscreengl}
 if flinked then begin
  fcanvas.unlink;
  flinked:= false;
 end;
 fbitmap.free;
 if fglused then begin
  releaseopengl;
 end;
{$endif}
 inherited;
 fcanvas.free;
end;

procedure topenglcanvaswidget.setcanvas(const avalue: topenglwidgetcanvas);
begin
 fcanvas.assign(avalue);
end;

procedure topenglcanvaswidget.gcneeded(const sender: tcanvas);
begin
{$ifdef offscreengl}
 //the context is created in renderoffscreen
{$else}
 checkclientwinid;
{$endif}
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
{$ifdef offscreengl}
 if flinked then begin
  fcanvas.updatesize(innerpaintrect.size);
 end;
{$else}
 fcanvas.updatesize(innerpaintrect.size);
{$endif}
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

{$ifdef offscreengl}

procedure topenglcanvaswidget.renderoffscreen;
var
 size1: sizety;
 rect1: rectty;
 id1: winidty;
 int1: integer;
 po1,po2: plongword;
 img: imagety;
begin
 if ffailed then begin
  exit;
 end;
 size1:= innerpaintrect.size;
 if (size1.cx <= 0) or (size1.cy <= 0) then begin
  exit;
 end;
 rect1:= makerect(nullpoint,size1);
 try
  if not flinked then begin
   initializeopengl([]);
   fglused:= true;
   id1:= 0;
   fcanvas.linktopaintdevice(0,rect1,id1);
   if id1 = 0 then begin
    raise exception.create('could not create the EGL context');
   end;
   flinked:= true;
   fcanvas.updatesize(size1);
  end;
  updaterenderstep;
  fcanvas.updatesize(size1);         //new pbuffer if the size has changed
  if canevent(tmethod(fonrender)) then begin
   fcanvas.reset;
   fonrender(self,rect1);
   fcanvas.endpaint;
  end;
  gdi_makecurrent(topenglcanvas1(fcanvas).fdrawinfo);
  glfinish;
  setlength(fpixels,size1.cx*size1.cy);
  glpixelstorei(gl_pack_alignment,1);
  glreadpixels(0,0,size1.cx,size1.cy,gl_bgra,gl_unsigned_byte,@fpixels[0]);
  setlength(frowbuffer,size1.cx);          //OpenGL is bottom up
  for int1:= 0 to size1.cy div 2 - 1 do begin
   po1:= @fpixels[int1*size1.cx];
   po2:= @fpixels[(size1.cy-1-int1)*size1.cx];
   move(po1^,frowbuffer[0],size1.cx*sizeof(longword));
   move(po2^,po1^,size1.cx*sizeof(longword));
   move(frowbuffer[0],po2^,size1.cx*sizeof(longword));
  end;
  fillchar(img,sizeof(img),0);
  img.kind:= bmk_rgb;
  img.bgr:= false;
  img.size:= size1;
  img.length:= size1.cx*size1.cy;
  img.linelength:= size1.cx;
  img.linebytes:= size1.cx*sizeof(longword);
  img.pixels:= plongwordaty(@fpixels[0]);
  if fbitmap = nil then begin
   fbitmap:= tbitmap.create(bmk_rgb);
  end;
  fbitmap.loadfromimage(img);
 except
  on e: exception do begin
   ffailed:= true;
   writeln(stderr,'topenglcanvaswidget: ',e.message);
  end;
 end;
end;

procedure topenglcanvaswidget.doonpaint(const acanvas: tcanvas);
begin
 if not (csdesigning in componentstate) and canclientpaint then begin
  if acanvas = nil then begin               //timer
   renderoffscreen;
   ffresh:= true;
   invalidatewidget;
  end
  else begin
   if not ffresh then begin
    renderoffscreen;
   end;
   ffresh:= false;
   if fbitmap <> nil then begin
    fbitmap.paint(acanvas,innerpaintrect.pos);
   end;
   restarttimer;
  end;
 end;
end;

{$endif}

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
