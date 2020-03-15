{ MSEgui Copyright (c) 1999-2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseimage;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 classes,mclasses,msegraphics,msegraphutils,msewidgets,
  msebitmap,msegui,msemenus,mseevent,mseguiglob;
const
 defaultimageoptionswidget = defaultoptionswidgetnofocus + [ow_mousewheel];
type
 timageframe = class(tscrollboxframe)
  protected
   procedure initinnerframe; override;
  published
   property framei_left default 0;
   property framei_top default 0;
   property framei_right default 0;
   property framei_bottom default 0;
 end;

 timage = class(tscrollingwidget)
  private
   fbitmap: tmaskedbitmap;
   fcolorforeground: colorty;
   fcolorbackground: colorty;
   procedure setbitmap(const Value: tmaskedbitmap);
   procedure bitmapchanged(const sender: tobject);
   procedure setcolorbackground(const Value: colorty);
   procedure setcolorforeground(const Value: colorty);
  protected
   procedure paintbmp(const acanvas: tcanvas; const abmp: tmaskedbitmap;
                          const dest: rectty);
   procedure dopaintforeground(const canvas: tcanvas); override;
   function calcminscrollsize: sizety; override;
   procedure internalcreateframe; override;
   procedure getautopaintsize(var asize: sizety); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure changed; virtual;
  published
   property bitmap: tmaskedbitmap read fbitmap write setbitmap;
   property colorforeground: colorty read fcolorforeground //for monochrome bitmaps
                  write setcolorforeground default cl_black;
   property colorbackground: colorty read fcolorbackground //for monochrome bitmaps
                  write setcolorbackground default cl_white;
   property optionswidget default defaultimageoptionswidget;
   property onmouseevent;
   property onclientmouseevent;
   property onchildmouseevent;
   property onmousewheelevent;
   property onkeydown;
   property onkeyup;
   property onbeforepaint;
   property onpaintbackground;
   property onpaint;
   property onafterpaint;
end;

implementation
uses
 mseguiintf,msebits,msekeyboard;

{ timage }

constructor timage.create(aowner: tcomponent);
begin
 fcolorforeground:= cl_black;
 fcolorbackground:= cl_white;
 fbitmap:= tmaskedbitmap.create(bmk_rgb);
 fbitmap.onchange:= {$ifdef FPC}@{$endif}bitmapchanged;
 inherited;
 optionswidget:= defaultimageoptionswidget;
end;

destructor timage.destroy;
begin
 inherited;
 fbitmap.Free;
end;

procedure timage.changed;
begin
 invalidate;
 minscrollsizechanged;
end;

procedure timage.paintbmp(const acanvas: tcanvas; const abmp: tmaskedbitmap;
                          const dest: rectty);
//var
// col1,col2: colorty;
begin
// col1:= acanvas.color;
// col2:= acanvas.colorbackground;
// acanvas.color:= fcolorforeground;
// acanvas.colorbackground:= fcolorbackground;
// abmp.paint(acanvas,makerect(nullpoint,clientsize));
// abmp.paint(acanvas,innerclientrect);
 abmp.paint(acanvas,dest,fcolorforeground,fcolorbackground);
// acanvas.color:= col1;
// acanvas.colorbackground:= col2;
end;

procedure timage.dopaintforeground(const canvas: tcanvas);
begin
 inherited;
// paintbmp(canvas,fbitmap,makerect(nullpoint,clientsize));
 paintbmp(canvas,fbitmap,innerclientrect);
end;

procedure timage.setbitmap(const Value: tmaskedbitmap);
begin
 fbitmap.assign(Value);
end;

procedure timage.bitmapchanged(const sender: tobject);
begin
 changed;
// invalidate;
end;

procedure timage.setcolorbackground(const Value: colorty);
begin
 if fcolorbackground <> value then begin
  fcolorbackground := Value;
  changed;
 end;
end;

procedure timage.setcolorforeground(const Value: colorty);
begin
 if fcolorforeground <> value then begin
  fcolorforeground := Value;
  changed;
 end;
end;

function timage.calcminscrollsize: sizety;
var
 size1: sizety;
begin
 result:= inherited calcminscrollsize;
 if fbitmap.alignment * [al_fit,al_thumbnail] = [] then begin
  size1:= result;
  if not (al_stretchx in fbitmap.alignment) then begin
   size1.cx:= fbitmap.bitmap.width+innerframewidth.cx;
  end;
  if not (al_stretchy in fbitmap.alignment) then begin
   size1.cy:= fbitmap.bitmap.height+innerframewidth.cy;
  end;
  if (result.cx < size1.cx) then begin
   result.cx:= size1.cx;
  end;
  if (result.cy < size1.cy) then begin
   result.cy:= size1.cy;
  end;
 end;
end;

procedure timage.internalcreateframe;
begin
 timageframe.create(iscrollframe(self),self);
end;

procedure timage.getautopaintsize(var asize: sizety);
begin
 asize:= fbitmap.size;
 innertopaintsize(asize);
end;

{ timageframe }

procedure timageframe.initinnerframe;
begin
 //dummy
end;

end.
