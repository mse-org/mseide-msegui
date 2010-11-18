{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseobjectpicker;

{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}

interface
uses
 mseevent,mseglob,mseguiglob,mseclasses,msegui,msegraphics,msegraphutils,msepointer,
 msetypes;
{$ifdef FPC}
 { $interfaces corba}
{$endif}

type
 ihintcontroller = interface(inullinterface)
  function getwidget: twidget;
 end;

 thintcontroller = class
  private
   fintf: ihintcontroller;
  public
   constructor create(const intf: ihintcontroller);
   procedure mouseevent(var info: mouseeventinfoty);
 end;

 iobjectpicker = interface(inullinterface)
  function getwidget: twidget;
  function getcursorshape(const apos: pointty; const ashiftstate: shiftstatesty; 
               const objects: integerarty; var ashape: cursorshapety): boolean;
                            //true if object found
  procedure getpickobjects(const arect: rectty;  const ashiftstate: shiftstatesty;
                                    var objects: integerarty);
  procedure beginpickmove(const apos: pointty; const ashiftstate: shiftstatesty;
                    const aobjects: integerarty);
  procedure endpickmove(const apos: pointty; const ashiftstate: shiftstatesty;
                    const aoffset: pointty; const aobjects: integerarty);
  procedure paintxorpic(const acanvas: tcanvas; const apos,aoffset: pointty;
                const aobjects: integerarty);
 end;

 objectpickerstatety = (ops_moving,ops_xorpicpainted{,ops_cursorchanged});
 objectpickerstatesty = set of objectpickerstatety;
 objectpickeroptionty = (opo_mousemoveobjectquery);
 objectpickeroptionsty = set of objectpickeroptionty;
 
 tobjectpicker = class      //todo: area selecting, area deselecting
  private
   fintf: iobjectpicker;
   fobjects: integerarty;
   fpickpos: pointty;
   fpickoffset: pointty;
   fstate: objectpickerstatesty;
   forigin: originty;
   foptions: objectpickeroptionsty;
   procedure removexorpic;
   procedure paintxorpic;
   procedure dokeypress(const sender: twidget; var info: keyeventinfoty);
   procedure endmoving(const resetflag: boolean);
   procedure initxorcanvas(const acanvas: tcanvas);
  public
   constructor create(const intf: iobjectpicker; aorigin: originty = org_client);
   destructor destroy; override;
   procedure mouseevent(var info: mouseeventinfoty);
   procedure restorexorpic(const canvas: tcanvas);
   property objects: integerarty read fobjects;
   property options: objectpickeroptionsty read foptions write foptions;
   property state: objectpickerstatesty read fstate;
 end;

implementation
uses
 msekeyboard,msedatalist;
 
type
 twidget1 = class(twidget);

{ tobjectpicker }

constructor tobjectpicker.create(const intf: iobjectpicker;
           aorigin: originty = org_client);
begin
 fintf:= intf;
 forigin:= aorigin;
end;

destructor tobjectpicker.destroy;
begin
 application.unregisteronkeypress({$ifdef FPC}@{$endif}dokeypress);
 inherited;
end;

procedure tobjectpicker.endmoving(const resetflag: boolean);
var
 widget1: twidget;
begin
 application.unregisteronkeypress({$ifdef FPC}@{$endif}dokeypress);
 removexorpic;
 widget1:= twidget1(fintf.getwidget);
// widget1.cursor:= fcursorbefore;
 widget1.releasemouse;
 application.widgetcursorshape:= cr_default;
 if resetflag then begin
  exclude(fstate,ops_moving);
 end;
end;

procedure tobjectpicker.mouseevent(var info: mouseeventinfoty);
var
 shape: cursorshapety;
 widget1: twidget1;

 procedure doend;
 begin
  endmoving(false);
  fintf.endpickmove(info.pos,info.shiftstate,fpickoffset,fobjects);
  exclude(fstate,ops_moving);
  
  with fintf.getwidget do begin
   shape:= actualcursor(widgetmousepos(info));
  end;
  fintf.getcursorshape(info.pos,info.shiftstate,fobjects,shape);
  application.widgetcursorshape:= shape;
         //restore pick cursor
  include(info.eventstate,es_processed);
 end; //doend

 procedure checkcursorshape;
 begin
  with fintf.getwidget do begin
   shape:= actualcursor(widgetmousepos(info));
  end;
  if fintf.getcursorshape(info.pos,info.shiftstate,fobjects,shape) then begin
   include(info.eventstate,es_processed);
   application.widgetcursorshape:= shape;
  end
  else begin
   application.widgetcursorshape:= cr_default;
  end;
 end; //checkcursorshape
 
var
 ar1: integerarty;
 po1: pointer;
begin
 case info.eventkind of
  ek_buttonpress: begin
   if info.button = mb_left then begin
    fobjects:= nil;
    exclude(fstate,ops_moving);
    fintf.getpickobjects(makerect(info.pos,nullsize),info.shiftstate,fobjects);
    checkcursorshape;
//    fintf.getcursorshape(info.pos,info.shiftstate,fobjects,shape);
    fpickpos:= info.pos;
    fpickoffset:= nullpoint;
    if length(fobjects) > 0 then begin
     removexorpic;
     application.registeronkeypress({$ifdef FPC}@{$endif}dokeypress);
     include(fstate,ops_moving);
     widget1:= twidget1(fintf.getwidget);
     widget1.capturemouse(true);
     fintf.beginpickmove(info.pos,info.shiftstate,fobjects);
     paintxorpic;
     include(info.eventstate,es_processed);
    end;
   end;
  end;
  ek_buttonrelease: begin
   if (info.button = mb_left) and (ops_moving in fstate) then begin
    doend;
   end;
  end;
  ek_mousemove,ek_mousepark: begin
   if ops_moving in fstate then begin
    removexorpic;
    fpickoffset:= subpoint(info.pos,fpickpos);
    paintxorpic;
    include(info.eventstate,es_processed);
   end
   else begin
    checkcursorshape;
    if opo_mousemoveobjectquery in foptions then begin
     ar1:= copy(fobjects);
     fintf.getpickobjects(makerect(info.pos,nullsize),info.shiftstate,fobjects);
     if not isequalarray(ar1,fobjects) then begin
      po1:= pointer(fobjects);
      pointer(fobjects):= pointer(ar1);
      removexorpic;
      pointer(fobjects):= po1;
      if fobjects <> nil then begin
       fpickpos:= info.pos;
       fpickoffset:= nullpoint;
       paintxorpic;
      end;
     end;
    end;
   end;
  end;
  ek_mouseleave,ek_clientmouseleave: begin
   removexorpic;
  end;
 end;
end;

procedure tobjectpicker.initxorcanvas(const acanvas: tcanvas);
begin
 with acanvas do begin
  rasterop:= rop_xor;
  color:= cl_white;
  dashes:= #1#1;
 end;
end;

procedure tobjectpicker.paintxorpic;
var
 canvas1: tcanvas;
 widget1: twidget;
begin
 if not (ops_xorpicpainted in fstate) then begin
  widget1:= fintf.getwidget;
  widget1.update;
  canvas1:= widget1.getcanvas(forigin);
  initxorcanvas(canvas1);
  fintf.paintxorpic(canvas1,addpoint(fpickoffset,fpickpos),fpickoffset,fobjects);
  include(fstate,ops_xorpicpainted);
 end;
end;

procedure tobjectpicker.removexorpic;
var
 canvas1: tcanvas;
begin
 if ops_xorpicpainted in fstate then begin
  canvas1:= fintf.getwidget.getcanvas(forigin);
  initxorcanvas(canvas1);
  fintf.paintxorpic(canvas1,addpoint(fpickoffset,fpickpos),fpickoffset,fobjects);
  exclude(fstate,ops_xorpicpainted);
 end;
end;

procedure tobjectpicker.restorexorpic(const canvas: tcanvas);
var
 int1: integer;
begin
 if ops_moving in fstate then begin
  int1:= canvas.save;
  initxorcanvas(canvas);
  if not (forigin = org_widget) then begin //todo org_screen
   canvas.intersectcliprect(fintf.getwidget.clientrect);
   canvas.move(fintf.getwidget.clientwidgetpos);
  end;
  fintf.paintxorpic(canvas,addpoint(fpickoffset,fpickpos),fpickoffset,fobjects);
  include(fstate,ops_xorpicpainted);
  canvas.restore(int1);
 end;
end;

procedure tobjectpicker.dokeypress(const sender: twidget;
               var info: keyeventinfoty);
begin
 if (ops_moving in fstate) and (info.key = key_escape) then begin
  endmoving(false);
  include(info.eventstate,es_processed);
 end;
end;

{ thintcontroller }

constructor thintcontroller.create(const intf: ihintcontroller);
begin
 fintf:= intf;
end;

procedure thintcontroller.mouseevent(var info: mouseeventinfoty);
begin

end;

end.
