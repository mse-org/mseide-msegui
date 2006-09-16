{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseimage;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 Classes,msegraphics,msegraphutils,msewidgets,msebitmap;

type
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
   procedure dopaint(const canvas: tcanvas); override;
   function calcminscrollsize: sizety; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure changed;
  published
   property bitmap: tmaskedbitmap read fbitmap write setbitmap;
   property colorforeground: colorty read fcolorforeground //for monochrome bitmaps
                  write setcolorforeground default cl_black;
   property colorbackground: colorty read fcolorbackground //for monochrome bitmaps
                  write setcolorbackground default cl_white;
 end;

implementation
uses
 mseguiintf,msegui,msebits;

{ timage }

constructor timage.create(aowner: tcomponent);
begin
 fcolorforeground:= cl_black;
 fcolorbackground:= cl_white;
 fbitmap:= tmaskedbitmap.create(false);
 fbitmap.onchange:= {$ifdef FPC}@{$endif}bitmapchanged;
 inherited;
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

procedure timage.dopaint(const canvas: tcanvas);
var
 col1,col2: colorty;
begin
 inherited;
 col1:= canvas.color;
 col2:= canvas.colorbackground;
 canvas.color:= fcolorforeground;
 canvas.colorbackground:= fcolorbackground;
 fbitmap.paint(canvas,makerect(nullpoint,clientsize));
 canvas.color:= col1;
 canvas.colorbackground:= col2;
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
 if not (al_fit in fbitmap.alignment) then begin
  size1:= fbitmap.size;
  if (result.cx < size1.cx) and not (al_stretchx in fbitmap.alignment) then begin
   result.cx:= size1.cx;
  end;
  if (result.cy < size1.cy) and not (al_stretchy in fbitmap.alignment) then begin
   result.cy:= size1.cy;
  end;
 end;
end;

initialization
 registerclass(timage);
end.
