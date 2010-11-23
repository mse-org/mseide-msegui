{ MSEgui Copyright (c) 2008-2010 by Martin Schreiber

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
      procedure (const sender: tcustompickwidget; const picker: tobjectpicker;
                    var shape: cursorshapety; var found: boolean) of object;
 getpickobjectseventty = procedure (const sender: tcustompickwidget;
                            const picker: tobjectpicker;
                            var objects: integerarty) of object;
 beginpickmoveeventty = procedure(const sender: tcustompickwidget;
                                  const picker: tobjectpicker) of object;
 endpickmoveeventty = procedure(const sender: tcustompickwidget;
                                  const picker: tobjectpicker) of object;
 paintxorpiceventty = procedure(const sender: tcustompickwidget;
                                       const picker: tobjectpicker;
                                       const canvas: tcanvas) of object;

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
   function getcursorshape(const sender: tobjectpicker;
                           var shape: cursorshapety): boolean;
   procedure getpickobjects(const sender: tobjectpicker; 
                                         var objects: integerarty);
   procedure beginpickmove(const sender: tobjectpicker);
   procedure pickthumbtrack(const sender: tobjectpicker);
   procedure endpickmove(const sender: tobjectpicker);
   procedure paintxorpic(const sender: tobjectpicker; const canvas: tcanvas);
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

function tcustompickwidget.getcursorshape(const sender: tobjectpicker;
                                             var shape: cursorshapety): boolean;
var
 bo1: boolean;
begin
 bo1:= false;
 if canevent(tmethod(fongetcursorshape)) then begin
  fongetcursorshape(self,sender,shape,bo1);
 end;
 result:= bo1;
end;

procedure tcustompickwidget.getpickobjects(const sender: tobjectpicker;
                                                  var objects: integerarty);
begin
 if canevent(tmethod(fongetpickobjects)) then begin
  fongetpickobjects(self,sender,objects);
 end;
end;

procedure tcustompickwidget.beginpickmove(const sender: tobjectpicker);
begin
 if canevent(tmethod(fonbeginpickmove)) then begin
  fonbeginpickmove(self,sender);
 end;
end;

procedure tcustompickwidget.pickthumbtrack(const sender: tobjectpicker);
begin
 //dummy
end;

procedure tcustompickwidget.endpickmove(const sender: tobjectpicker);
begin
 if canevent(tmethod(fonendpickmove)) then begin
  fonendpickmove(self,sender);
 end;
end;

procedure tcustompickwidget.paintxorpic(const sender: tobjectpicker;
                          const canvas: tcanvas);
begin
 if canevent(tmethod(fonpaintxorpic)) then begin
  fonpaintxorpic(self,sender,canvas);
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
