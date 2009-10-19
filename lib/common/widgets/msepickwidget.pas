{ MSEgui Copyright (c) 2008 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msepickwidget;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 classes,mseclasses,msesimplewidgets,mseobjectpicker,msegraphutils,msegui,
 mseguiglob,msepointer,msetypes,msegraphics,mseevent,msemenus;

// todo:
// select rect
 
type
 tcustompickwidget = class;
 
 getcursorshapeeventty =  
      procedure (const sender: tcustompickwidget;
          const apos: pointty; const shiftstate: shiftstatesty;
                  var shape: cursorshapety; var found: boolean) of object;
 getpickobjectseventty = procedure (const sender: tcustompickwidget;
                           const rect: rectty; const shiftstate: shiftstatesty;
                           var objects: integerarty) of object;
 beginpickmoveeventty = procedure(const sender: tcustompickwidget;
                           const objects: integerarty) of object;
 endpickmoveeventty = procedure(const sender: tcustompickwidget;
                  const apos: pointty; const ashiftstate: shiftstatesty;
                  const offset: pointty; const objects: integerarty) of object;
 paintxorpiceventty = procedure(const sender: tcustompickwidget;
                           const canvas: tcanvas; const apos,offset: pointty;
                           const objects: integerarty) of object;

 tcustompickwidget = class(teventwidget,iobjectpicker)
  private
   fobjectpicker: tobjectpicker;
   fongetcursorshape: getcursorshapeeventty;
   fongetpickobjects: getpickobjectseventty;
   fonbeginpickmove: beginpickmoveeventty;
   fonendpickmove: endpickmoveeventty;
   fonpaintxorpic: paintxorpiceventty;
  protected
   procedure clientmouseevent(var info: mouseeventinfoty); override;
   //iobjectpicker
   function getcursorshape(const apos: pointty; const shiftstate: shiftstatesty;
                                           var shape: cursorshapety): boolean;
   procedure getpickobjects(const rect: rectty; const shiftstate: shiftstatesty;
                                           var objects: integerarty);
   procedure beginpickmove(const objects: integerarty);
   procedure endpickmove(const apos: pointty; const ashiftstate: shiftstatesty;
                         const offset: pointty; const objects: integerarty);
   procedure paintxorpic(const canvas: tcanvas; const apos,offset: pointty;
                 const objects: integerarty);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property ongetcursorshape: getcursorshapeeventty read fongetcursorshape
                                write fongetcursorshape;
   property ongetpickobjects: getpickobjectseventty read fongetpickobjects
                                write fongetpickobjects;
   property onbeginpickmove: beginpickmoveeventty read fonbeginpickmove 
                                write fonbeginpickmove;
   property onendpickmove: endpickmoveeventty read fonendpickmove
                                write fonendpickmove;
   property onpaintxorpic: paintxorpiceventty read fonpaintxorpic 
                                write fonpaintxorpic;
 end;

 tpickwidget = class(tcustompickwidget)
  published
   property ongetcursorshape;
   property ongetpickobjects;
   property onbeginpickmove;
   property onendpickmove;
   property onpaintxorpic;
 end;
  
implementation

{ tcustompickpickwidget }

constructor tcustompickwidget.create(aowner: tcomponent);
begin
 fobjectpicker:= tobjectpicker.create(iobjectpicker(self));
 inherited;
end;

destructor tcustompickwidget.destroy;
begin
 inherited;
 fobjectpicker.free;
end;

function tcustompickwidget.getcursorshape(const apos: pointty;
               const shiftstate: shiftstatesty;
               var shape: cursorshapety): boolean;
var
 bo1: boolean;
begin
 bo1:= false;
 if canevent(tmethod(fongetcursorshape)) then begin
  fongetcursorshape(self,apos,shiftstate,shape,bo1);
 end;
 result:= bo1;
end;

procedure tcustompickwidget.getpickobjects(const rect: rectty;
               const shiftstate: shiftstatesty; var objects: integerarty);
begin
 if canevent(tmethod(fongetpickobjects)) then begin
  fongetpickobjects(self,rect,shiftstate,objects);
 end;
end;

procedure tcustompickwidget.beginpickmove(const objects: integerarty);
begin
 if canevent(tmethod(fonbeginpickmove)) then begin
  fonbeginpickmove(self,objects);
 end;
end;

procedure tcustompickwidget.endpickmove(const apos: pointty;
                 const ashiftstate: shiftstatesty; const offset: pointty;
                 const objects: integerarty);
begin
 if canevent(tmethod(fonendpickmove)) then begin
  fonendpickmove(self,apos,ashiftstate,offset,objects);
 end;
end;

procedure tcustompickwidget.paintxorpic(const canvas: tcanvas; const apos: pointty;
               const offset: pointty; const objects: integerarty);
begin
 if canevent(tmethod(fonpaintxorpic)) then begin
  fonpaintxorpic(self,canvas,apos,offset,objects);
 end;
end;

procedure tcustompickwidget.clientmouseevent(var info: mouseeventinfoty);
begin
 fobjectpicker.mouseevent(info);
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;

end.
