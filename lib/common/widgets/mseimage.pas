{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

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
 {$ifdef FPC}classes{$else}Classes{$endif},msegraphics,msegraphutils,msewidgets,
  msebitmap,msegui,msemenus,mseevent,mseguiglob;

type
 timageframe = class(tscrollboxframe)
  protected
   procedure initinnerframe; override;
   procedure dokeydown(var info: keyeventinfoty); override;
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
   procedure dopaint(const canvas: tcanvas); override;
   function calcminscrollsize: sizety; override;
   procedure internalcreateframe; override;
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
   property optionswidget default defaultoptionswidgetnofocus;
   property onmouseevent;
   property onclientmouseevent;
   property onchildmouseevent;
   property onmousewheelevent;
   property onkeydown;
   property onkeyup;
 end;

implementation
uses
 mseguiintf,msebits,msekeyboard;
 
{ timage }

constructor timage.create(aowner: tcomponent);
begin
 fcolorforeground:= cl_black;
 fcolorbackground:= cl_white;
 fbitmap:= tmaskedbitmap.create(false);
 fbitmap.onchange:= {$ifdef FPC}@{$endif}bitmapchanged;
 inherited;
 optionswidget:= defaultoptionswidgetnofocus;
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
var
 col1,col2: colorty;
begin
 col1:= acanvas.color;
 col2:= acanvas.colorbackground;
 acanvas.color:= fcolorforeground;
 acanvas.colorbackground:= fcolorbackground;
// abmp.paint(acanvas,makerect(nullpoint,clientsize));
 abmp.paint(acanvas,innerclientrect);
 acanvas.color:= col1;
 acanvas.colorbackground:= col2;
end;

procedure timage.dopaint(const canvas: tcanvas);
begin
 inherited;
 paintbmp(canvas,fbitmap,makerect(nullpoint,clientsize));
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

procedure timage.internalcreateframe;
begin
 timageframe.create(iscrollframe(self),self);
end;

{ timageframe }

procedure timageframe.initinnerframe;
begin
 //dummy
end;

procedure timageframe.dokeydown(var info: keyeventinfoty);
begin
 with info do begin
  if not (es_processed in info.eventstate) and 
           (((shiftstate * shiftstatesmask) - [ss_ctrl]) = []) then begin
   include(eventstate,es_processed); 
   case key of
    key_pageup: begin
     if ss_ctrl in shiftstate then begin
      fvert.value:= 0;
     end
     else begin
      fvert.pagedown;
     end;
    end;
    key_pagedown: begin
     if ss_ctrl in shiftstate then begin
      fvert.value:= 1;
     end
     else begin
      fvert.pageup;
     end;
    end;
    else begin
     exclude(eventstate,es_processed);
    end;
   end;
   if ss_ctrl in shiftstate then begin
    include(eventstate,es_processed); 
    case key of
     key_right: begin
      fhorz.stepup;
     end;
     key_left: begin
      fhorz.stepdown;
     end;
     key_down: begin
      fvert.stepup;
     end;
     key_up: begin
      fvert.stepdown;
     end;
     else begin
      exclude(eventstate,es_processed);
     end;
    end;
   end;
  end;
 end;
end;

initialization
 registerclass(timage);
end.
