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
 mseevent,mseglob,mseguiglob,mseclasses,msegui,msegraphics,msegraphutils,
 msepointer,msetypes;

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

 tobjectpicker = class;
 
 iobjectpicker = interface(inullinterface)
  function getwidget: twidget;
  function getcursorshape(const sender: tobjectpicker;
                                    var ashape: cursorshapety): boolean;
                            //true if object found
  procedure getpickobjects(const sender: tobjectpicker; var objects: integerarty);
  procedure beginpickmove(const sender: tobjectpicker);
  procedure endpickmove(const sender: tobjectpicker);
  procedure paintxorpic(const sender: tobjectpicker; const acanvas: tcanvas);
 end;

 objectpickerstatety = (ops_moving,ops_rectselecting,ops_xorpicpainted);
 objectpickerstatesty = set of objectpickerstatety;
 objectpickeroptionty = (opo_mousemoveobjectquery,opo_rectselect);
 objectpickeroptionsty = set of objectpickeroptionty;
 
 tobjectpicker = class      //todo: area selecting, area deselecting
  private
   fintf: iobjectpicker;
   fobjects: integerarty;
   fpickrect: rectty;
   fpickoffset: pointty;
   fstate: objectpickerstatesty;
   forigin: originty;
   foptions: objectpickeroptionsty;
   fmouseeventinfopo: pmouseeventinfoty;
   fkeyeventinfopo: pkeyeventinfoty;
   procedure dopaint(const acanvas: tcanvas);
   procedure removexorpic;
   procedure paintxorpic;
   procedure dokeypress(const sender: twidget; var info: keyeventinfoty);
   procedure endmoving(const resetflag: boolean);
   procedure initxorcanvas(const acanvas: tcanvas);
   function getpos: pointty;
   function getshiftstate: shiftstatesty;
  public
   constructor create(const intf: iobjectpicker; aorigin: originty = org_client);
   destructor destroy; override;
   procedure mouseevent(var info: mouseeventinfoty);
   procedure restorexorpic(const canvas: tcanvas);
   procedure clear;
   function hasobjects: boolean;
   function moving: boolean;
   function rectselecting: boolean;
   
   property objects: integerarty read fobjects;
   property options: objectpickeroptionsty read foptions write foptions;
   property state: objectpickerstatesty read fstate;
   property pickoffset: pointty read fpickoffset;
   property pickpos: pointty read fpickrect.pos;
   property pickrect: rectty read fpickrect;
   property mouseeventinfopo: pmouseeventinfoty read fmouseeventinfopo;
   property keyeventinfopo: pkeyeventinfoty read fkeyeventinfopo;
   property shiftstate: shiftstatesty read getshiftstate;
   property pos: pointty read getpos;
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
 widget1.releasemouse;
 application.widgetcursorshape:= cr_default;
 if resetflag then begin
  fpickoffset:= nullpoint;
  exclude(fstate,ops_moving);
 end;
 exclude(fstate,ops_rectselecting);
 fpickrect.size:= nullsize;
end;

procedure tobjectpicker.mouseevent(var info: mouseeventinfoty);
var
 shape: cursorshapety;
 widget1: twidget1;

 procedure domousemovequery(const force: boolean);
 var
  ar1: integerarty;
  po1: pointer;
  pt1,pt2: pointty;
 begin
  if opo_mousemoveobjectquery in foptions then begin
   ar1:= copy(fobjects);
   pt1:= fpickrect.pos;
   pt2:= fpickoffset;
   fpickrect.pos:= info.pos;
   fpickoffset:= nullpoint;
   fintf.getpickobjects(self,fobjects);
   if force or not isequalarray(ar1,fobjects) then begin
    po1:= pointer(fobjects);
    pointer(fobjects):= pointer(ar1);
    fpickrect.pos:= pt1;
    fpickoffset:= pt2;
    removexorpic;
    fpickrect.pos:= info.pos;
    fpickoffset:= nullpoint;
    pointer(fobjects):= po1;
    if fobjects <> nil then begin
     paintxorpic;
    end;
   end;
  end;
 end; //domousemovequery
 
 procedure doend;
 begin
  endmoving(false);
  fintf.endpickmove(self);
  exclude(fstate,ops_moving);
  fpickoffset:= nullpoint;
  
  with fintf.getwidget do begin
   shape:= actualcursor(widgetmousepos(info));
  end;
  fintf.getcursorshape(self,shape);
  application.widgetcursorshape:= shape; //restore pick cursor
  include(info.eventstate,es_processed);
  domousemovequery(true);
 end; //doend

 procedure checkcursorshape;
 begin
  with fintf.getwidget do begin
   shape:= actualcursor(widgetmousepos(info));
  end;
  if fintf.getcursorshape(self,shape) then begin
   include(info.eventstate,es_processed);
   application.widgetcursorshape:= shape;
  end
  else begin
   application.widgetcursorshape:= cr_default;
  end;
 end; //checkcursorshape

var
 shiftstates1: shiftstatesty;
 ar1: integerarty;
 bo1: boolean;
 int1,int2,int3: integer;
 
begin
 fmouseeventinfopo:= @info;
 try
  shiftstates1:= info.shiftstate * shiftstatesmask;
  case info.eventkind of
   ek_buttonpress: begin
    if info.button = mb_left then begin
     if shiftstates1 = [ss_left] then begin
      fobjects:= nil;
      fstate:= fstate - [ops_moving,ops_rectselecting];
      fpickrect.pos:= info.pos;
      fpickrect.size:= nullsize;
      fpickoffset:= nullpoint;
      fintf.getpickobjects(self,fobjects);
      checkcursorshape;
      if length(fobjects) > 0 then begin
       removexorpic;
       application.registeronkeypress({$ifdef FPC}@{$endif}dokeypress);
       include(fstate,ops_moving);
       widget1:= twidget1(fintf.getwidget);
       widget1.capturemouse(true);
       fintf.beginpickmove(self);
       paintxorpic;
       include(info.eventstate,es_processed);
      end;
     end
     else begin
      if (shiftstates1 = [ss_shift,ss_left]) and 
                          (opo_rectselect in foptions) then begin
       application.registeronkeypress({$ifdef FPC}@{$endif}dokeypress);
       include(fstate,ops_rectselecting);
       fpickrect.pos:= info.pos;
       fpickrect.size:= nullsize;
      end;
     end;
    end;
   end;
   ek_buttonrelease: begin
    if (info.button = mb_left) then begin
     if ops_moving in fstate then begin
      doend;
     end
     else begin
      if ops_rectselecting in fstate then begin
       removexorpic;
       fpickrect.size:= sizety(subpoint(info.pos,fpickrect.pos));
       ar1:= nil;
       bo1:= (fpickrect.cx < 0) or (fpickrect.cy < 0);
       normalizerect(fpickrect);
       fintf.getpickobjects(self,ar1);
       if (ar1 <> nil) then begin
        if bo1 then begin
         for int1:= 0 to high(ar1) do begin
          removeitem(fobjects,ar1[int1]);
         end;
        end
        else begin
         for int1:= 0 to high(ar1) do begin
          int3:= length(fobjects);
          for int2:= 0 to high(fobjects) do begin
           if fobjects[int2] = ar1[int1] then begin
            int3:= -1;
            break; //no duplicates;
           end;
           if fobjects[int2] > ar1[int1] then begin
            int3:= int2;
            break;
           end;
          end;
          if int3 >= 0 then begin
           insertitem(fobjects,int3,ar1[int1]);
          end;
         end;
        end;
       end;
       exclude(fstate,ops_rectselecting);
       fpickrect.size:= nullsize;
      end;
     end;
    end;
   end;
   ek_mousemove,ek_mousepark: begin
    if ops_moving in fstate then begin
     removexorpic;
     fpickoffset:= subpoint(info.pos,fpickrect.pos);
     paintxorpic;
     include(info.eventstate,es_processed);
    end
    else begin
     if ops_rectselecting in fstate then begin
      removexorpic;
      fpickrect.size:= sizety(subpoint(info.pos,fpickrect.pos));
      paintxorpic;
     end
     else begin
      fpickrect.pos:= info.pos;
      fpickoffset:= nullpoint;
      checkcursorshape;
      domousemovequery(false);
     end;
    end;
   end;
   ek_mouseleave,ek_clientmouseleave: begin
    removexorpic;
   end;
  end;
 finally
  fmouseeventinfopo:= nil;
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

procedure tobjectpicker.dopaint(const acanvas: tcanvas);
begin
 if ops_rectselecting in fstate then begin
  acanvas.dashes:= #3#3;
  acanvas.drawrect(fpickrect);
 end
 else begin
  fintf.paintxorpic(self,acanvas);
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
  dopaint(canvas1);
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
  dopaint(canvas1);
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
  fintf.paintxorpic(self,canvas);
  include(fstate,ops_xorpicpainted);
  canvas.restore(int1);
 end;
end;

procedure tobjectpicker.dokeypress(const sender: twidget;
               var info: keyeventinfoty);
begin
 if (fstate * [ops_moving,ops_rectselecting] <> []) and 
                                   (info.key = key_escape) then begin
  fkeyeventinfopo:= @info;
  try
   endmoving(true);
   include(info.eventstate,es_processed);
  finally
   fkeyeventinfopo:= nil;
  end;
 end;
end;

function tobjectpicker.getpos: pointty;
begin
 result:= addpoint(fpickrect.pos,fpickoffset);
end;

function tobjectpicker.getshiftstate: shiftstatesty;
begin
 result:= [];
 if fmouseeventinfopo <> nil then begin
  result:= fmouseeventinfopo^.shiftstate;
 end
 else begin
  if fkeyeventinfopo <> nil then begin
   result:= fkeyeventinfopo^.shiftstate;
  end
 end;
end;

procedure tobjectpicker.clear;
begin
 fobjects:= nil;
end;

function tobjectpicker.hasobjects: boolean;
begin
 result:= fobjects <> nil;
end;

function tobjectpicker.moving: boolean;
begin
 result:= ops_moving in fstate;
end;

function tobjectpicker.rectselecting: boolean;
begin
 result:= ops_rectselecting in fstate;
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
