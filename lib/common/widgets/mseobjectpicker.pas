{ MSEgui Copyright (c) 1999-2015 by Martin Schreiber

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
//  procedure getmouseoverobjects(const sender: tobjectpicker; var objects: integerarty);
  procedure beginpickmove(const sender: tobjectpicker);
  procedure pickthumbtrack(const sender: tobjectpicker);
  procedure endpickmove(const sender: tobjectpicker);
  procedure cancelpickmove(const sender: tobjectpicker);
  procedure paintxorpic(const sender: tobjectpicker; const acanvas: tcanvas);
 end;

 objectpickerstatety = (ops_picking,ops_rectselecting,
                        ops_multiselecting,ops_moving,
                        ops_xorpicpainted,ops_xorpicremoved,
                        ops_newwidgetgrab,ops_newwindowgrab);
 objectpickerstatesty = set of objectpickerstatety;
const
 activestates = [ops_picking,ops_rectselecting,ops_multiselecting,ops_moving];
type
 objectpickeroptionty = (opo_mousemoveobjectquery,opo_rectselect,
                         opo_multiselect,opo_thumbtrack);
 objectpickeroptionsty = set of objectpickeroptionty;
 
 tobjectpicker = class      //todo: area selecting, area deselecting
  private
   fintf: iobjectpicker;
   fmouseoverobjects: integerarty;
   fselectobjects: integerarty;
   fpickrect: rectty;
   fpickoffset: pointty;
   fstate: objectpickerstatesty;
   forigin: originty;
   foptions: objectpickeroptionsty;
   fmouseeventinfopo: pmouseeventinfoty;
   fkeyeventinfopo: pkeyeventinfoty;
   fcursorshape: cursorshapety;
   procedure dopaint(const acanvas: tcanvas);
   procedure dokeypress(const sender: twidget; var info: keyeventinfoty);
   procedure endmoving(const resetflag: boolean);
   procedure initxorcanvas(const acanvas: tcanvas);
   function getpos: pointty;
   function getshiftstate: shiftstatesty;
   function getcurrentobjects: integerarty;
  public
   constructor create(const intf: iobjectpicker; aorigin: originty = org_client);
   destructor destroy; override;
   procedure mouseevent(var info: mouseeventinfoty);
   procedure dokeydown(var ainfo: keyeventinfoty);
   function removexorpic: boolean;
   function paintxorpic: boolean;
   procedure dobeforepaint(const acanvas: tcanvas);
   procedure doafterpaint(const acanvas: tcanvas);
   
//   procedure restorexorpic(const canvas: tcanvas);
   procedure clear;
   function hasselectobjects: boolean;
   function hasmouseoverobjects: boolean;
   function hascurrentobjects: boolean;
   function picking: boolean;
   function rectselecting: boolean;
   function multiselecting: boolean;
   function moving: boolean;
   function active: boolean;
   
   property mouseoverobjects: integerarty read fmouseoverobjects;
   property selectobjects: integerarty read fselectobjects;
   property currentobjects: integerarty read getcurrentobjects;
             //mouseoverobjects or selectobjects dependent on state
   property options: objectpickeroptionsty read foptions write foptions;
   property state: objectpickerstatesty read fstate;
   property pickoffset: pointty read fpickoffset;
   property pickpos: pointty read fpickrect.pos;
   property pickrect: rectty read fpickrect;
   property cursor: cursorshapety read fcursorshape;
   property mouseeventinfopo: pmouseeventinfoty read fmouseeventinfopo;
   property keyeventinfopo: pkeyeventinfoty read fkeyeventinfopo;
   property shiftstate: shiftstatesty read getshiftstate;
   property pos: pointty read getpos;
 end;

implementation
uses
 msekeyboard,msearrayutils;
 
type
 twidget1 = class(twidget);

{ tobjectpicker }

constructor tobjectpicker.create(const intf: iobjectpicker;
           aorigin: originty = org_client);
begin
 fintf:= intf;
 forigin:= aorigin;
 fcursorshape:= cr_default;
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
 if ops_newwidgetgrab in fstate then begin
  widget1.releasemouse(not (ops_newwindowgrab in fstate));
 end
 else begin
  if ops_newwindowgrab in fstate then begin
   widget1.window.releasemouse;
  end;
 end;
 application.widgetcursorshape:= cr_default;
 if resetflag then begin
  addpoint1(fpickrect.pos,fpickoffset);
  fpickrect.size:= nullsize;
  fpickoffset:= nullpoint;
  if opo_thumbtrack in foptions then begin
   fintf.pickthumbtrack(self);
  end;
  exclude(fstate,ops_moving);
 end;
 exclude(fstate,ops_rectselecting);
 fpickrect.size:= nullsize;
end;

procedure tobjectpicker.mouseevent(var info: mouseeventinfoty);
var
// shape: cursorshapety;
 widget1: twidget1;
 shiftstates1: shiftstatesty;

 procedure domousemovequery(const force: boolean);
 var
  ar1: integerarty;
  po1: pointer;
  pt1,pt2: pointty;
 begin
  if opo_mousemoveobjectquery in foptions then begin
   ar1:= copy(fmouseoverobjects);
   pt1:= fpickrect.pos;
   pt2:= fpickoffset;
   fpickrect.pos:= info.pos;
   fpickoffset:= nullpoint;
   fintf.getpickobjects(self,fmouseoverobjects);
   if (force or not isequalarray(ar1,fmouseoverobjects)) and 
      ((fselectobjects = nil) or (ops_multiselecting in fstate)) then begin
    po1:= pointer(fmouseoverobjects);
    pointer(fmouseoverobjects):= pointer(ar1);
    fpickrect.pos:= pt1;
    fpickoffset:= pt2;
    removexorpic;
    fpickrect.pos:= info.pos;
    fpickoffset:= nullpoint;
    pointer(fmouseoverobjects):= po1;
    if (fmouseoverobjects <> nil) or (fselectobjects <> nil) and 
                                      (ops_multiselecting in fstate) then begin
     paintxorpic;
    end;
   end;
  end;
 end; //domousemovequery
 
 procedure doend;
 var
  bo1: boolean;
  pt1: pointty;
  widget1: twidget;
 begin
  widget1:= fintf.getwidget;
  pt1:=  widget1.refpos(forigin);   
  endmoving(false);
  fintf.endpickmove(self);
  exclude(fstate,ops_moving);
  addpoint1(fpickrect.pos,fpickoffset);
  addpoint1(fpickrect.pos,subpoint(pt1,widget1.refpos(forigin)));
  fpickrect.size:= nullsize;
  fpickoffset:= nullpoint;

  with fintf.getwidget do begin
   fcursorshape:= actualcursor(widgetmousepos(info));
  end;
  bo1:= fintf.getcursorshape(self,fcursorshape);
  application.widgetcursorshape:= fcursorshape; //restore pick cursor
  if not bo1 then begin
   fcursorshape:= cr_default;
  end;
  info.eventstate:= info.eventstate+[es_processed,es_objectpicking];
//   include(info.eventstate,es_processed);
  fmouseoverobjects:= nil;
  domousemovequery(true);
 end; //doend

 procedure checkcursorshape;
 begin
  with fintf.getwidget do begin
   fcursorshape:= actualcursor(widgetmousepos(info));
  end;
  if fintf.getcursorshape(self,fcursorshape) then begin
   info.eventstate:= info.eventstate+[es_processed,es_objectpicking];
//   include(info.eventstate,es_processed);
  end
  else begin
   fcursorshape:= cr_default;
  end;
  application.widgetcursorshape:= fcursorshape;
 end; //checkcursorshape

 function hasintersection(const ar1: integerarty): boolean;
 var 
  int1,int2: integer;
 begin       
  result:= false;
  for int1:= 0 to high(ar1) do begin
   for int2:= 0 to high(fselectobjects) do begin  //check intersection
    if ar1[int1] = fselectobjects[int2] then begin
     result:= true;
     break;
    end;
   end;
   if result then begin
    break;
   end;
  end;
 end; //hasintersection
 
 procedure removeintersection(const ar1: integerarty);
 var
  int1: integer;
 begin
  for int1:= 0 to high(ar1) do begin
   removeitem(fselectobjects,ar1[int1]);
  end;
 end; //removeintersection

 procedure addintersection(const ar1: integerarty);
 var
  int1,int2,int3: integer;
 begin
  for int1:= 0 to high(ar1) do begin
   int3:= length(fselectobjects);
   for int2:= 0 to high(fselectobjects) do begin
    if fselectobjects[int2] = ar1[int1] then begin
     int3:= -1;
     break; //no duplicates;
    end;
    if fselectobjects[int2] > ar1[int1] then begin
     int3:= int2;
     break;
    end;
   end;
   if int3 >= 0 then begin
    insertitem(fselectobjects,int3,ar1[int1]);
   end;
  end;
 end; //addintersection
  
var
 ar1: integerarty;
 bo1: boolean;
 infopobefore: pmouseeventinfoty;
// int1,int2,int3: integer;
 
begin
 infopobefore:= fmouseeventinfopo;
 fmouseeventinfopo:= @info;
 try
  shiftstates1:= info.shiftstate * shiftstatesmask;
  if (opo_multiselect in foptions) and 
          (shiftstates1*keyshiftstatesmask = [ss_ctrl]) xor 
                    (ops_multiselecting in fstate) then begin
   bo1:= removexorpic;
   if (shiftstates1*keyshiftstatesmask = [ss_ctrl]) then begin
    include(fstate,ops_multiselecting);
   end
   else begin
    exclude(fstate,ops_multiselecting);
   end;
   if bo1 then begin
    paintxorpic;
   end;
  end;
  case info.eventkind of
   ek_buttonpress: begin
    if info.button = mb_left then begin
     removexorpic;
     fstate:= fstate - [ops_moving,ops_rectselecting];
     fpickrect.pos:= info.pos;
     fpickrect.size:= nullsize;
     fpickoffset:= nullpoint;
     ar1:= nil;
     include(fstate,ops_picking);
     try
      fintf.getpickobjects(self,ar1);
     finally
      exclude(fstate,ops_picking);
     end;
     if shiftstates1 = [ss_left] then begin
      fmouseoverobjects:= ar1;
      if (ar1 = nil) then begin
       if fselectobjects <> nil then begin
        info.eventstate:= info.eventstate+[es_processed,es_objectpicking];
//        include(info.eventstate,es_processed);
        fselectobjects:= nil;
       end;
      end
      else begin
       if not hasintersection(ar1) then begin
        fselectobjects:= nil;
       end;
       application.registeronkeypress({$ifdef FPC}@{$endif}dokeypress);
       include(fstate,ops_moving);
       widget1:= twidget1(fintf.getwidget);
       fstate:= fstate - [ops_newwidgetgrab,ops_newwindowgrab];
       if not widget1.window.mousecaptured then begin
        include(fstate,ops_newwindowgrab);
       end;
       if (ws_newmousecapture in widget1.fwidgetstate) or 
                                 not widget1.mousecaptured then begin
        include(fstate,ops_newwidgetgrab);
       end;
       widget1.capturemouse(true);
       fintf.beginpickmove(self);
       widget1.window.update;
       paintxorpic;
       info.eventstate:= info.eventstate+[es_processed,es_objectpicking];
//       include(info.eventstate,es_processed);
       checkcursorshape;
      end;
     end
     else begin
      if (shiftstates1 = [ss_shift,ss_left]) and 
                          (opo_rectselect in foptions) then begin
       application.registeronkeypress({$ifdef FPC}@{$endif}dokeypress);
       include(fstate,ops_rectselecting);
       info.eventstate:= info.eventstate+[es_processed,es_objectpicking];
       //include(info.eventstate,es_processed);
      end
      else begin
       if (shiftstates1 = [ss_ctrl,ss_left]) and 
                   (opo_multiselect in foptions) and (ar1 <> nil) then begin
        fmouseoverobjects:= ar1;
        if hasintersection(ar1) then begin
         removeintersection(ar1);
        end
        else begin
         addintersection(ar1);
        end;
        paintxorpic;
        info.eventstate:= info.eventstate+[es_processed,es_objectpicking];
      //  include(info.eventstate,es_processed);
        checkcursorshape;
       end;
      end;
     end;
    end;
   end;
   ek_buttonrelease: begin
    if (info.button = mb_left) then begin
     if ops_moving in fstate then begin
      doend;
      if opo_mousemoveobjectquery in foptions then begin
       fintf.getpickobjects(self,fmouseoverobjects);
      end;
      if hascurrentobjects then begin
       paintxorpic;
      end;
      checkcursorshape;
     end
     else begin
      if ops_rectselecting in fstate then begin
       removexorpic;
       fpickrect.size:= sizety(subpoint(info.pos,fpickrect.pos));
       ar1:= nil;
       bo1:= (fpickrect.cx < 0) or (fpickrect.cy < 0);
       normalizerect1(fpickrect);
       fintf.getpickobjects(self,ar1);
       if (ar1 <> nil) then begin
        if bo1 then begin
         removeintersection(ar1);
        end
        else begin
         addintersection(ar1);
        end;
       end;
       exclude(fstate,ops_rectselecting);
       fpickrect.size:= nullsize;
       if fselectobjects <> nil then begin
        paintxorpic;
       end;
      end;
     end;
    end;
   end;
   ek_mousemove,ek_mousepark: begin
    if ops_moving in fstate then begin
     removexorpic;
     fpickoffset:= subpoint(info.pos,fpickrect.pos);
     if opo_thumbtrack in foptions then begin
      fintf.pickthumbtrack(self);
     end;
     paintxorpic;
     info.eventstate:= info.eventstate+[es_processed,es_objectpicking];
   //  include(info.eventstate,es_processed);
    end
    else begin
     if ops_rectselecting in fstate then begin
      removexorpic;
      fpickrect.size:= sizety(subpoint(info.pos,fpickrect.pos));
      paintxorpic;
     end
     else begin
      if shiftstate * buttonshiftstatesmask = [] then begin
       fpickrect.pos:= info.pos;
       fpickoffset:= nullpoint;
       checkcursorshape;
       domousemovequery(false);
      end;
     end;
    end;
   end;
   ek_mouseleave,ek_clientmouseleave: begin
    if fselectobjects = nil then begin
     removexorpic;
    end;
    fmouseoverobjects:= nil;
   end;
  end;
 finally
  fmouseeventinfopo:= infopobefore;
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
 if not (opo_thumbtrack in foptions) then begin
  fintf.paintxorpic(self,acanvas);
 end;
 if ops_rectselecting in fstate then begin
  acanvas.dashes:= #3#3;
  acanvas.drawrect(fpickrect);
 end;
end;

function tobjectpicker.paintxorpic: boolean;
var
 canvas1: tcanvas;
 widget1: twidget;
begin
 result:= not (ops_xorpicpainted in fstate);
 if result then begin
  widget1:= fintf.getwidget;
//  widget1.update;
  canvas1:= widget1.getcanvas(forigin);
  initxorcanvas(canvas1);
  dopaint(canvas1);
  include(fstate,ops_xorpicpainted);
 end;
end;

function tobjectpicker.removexorpic: boolean;
var
 canvas1: tcanvas;
begin
 result:= ops_xorpicpainted in fstate;
 if result then begin
  canvas1:= fintf.getwidget.getcanvas(forigin);
  initxorcanvas(canvas1);
  dopaint(canvas1);
  exclude(fstate,ops_xorpicpainted);
 end;
end;
{
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
}
procedure tobjectpicker.dokeypress(const sender: twidget;
               var info: keyeventinfoty);
begin
 case info.key of
  key_escape: begin
   if (fstate * [ops_moving,ops_rectselecting] <> []) then begin
    fkeyeventinfopo:= @info;
    try
     endmoving(true);
     if fselectobjects <> nil then begin
      paintxorpic;
     end;
     include(info.eventstate,es_processed);
     fintf.cancelpickmove(self);
    finally
     fkeyeventinfopo:= nil;
    end;
   end;
  end;
 end
end;

procedure tobjectpicker.dokeydown(var ainfo: keyeventinfoty);
begin
 case ainfo.key of
  key_escape: begin
   if (fstate * [ops_moving,ops_rectselecting] = []) and
    (fselectobjects <> nil) and (ainfo.shiftstate*shiftstatesmask = []) then begin
    removexorpic;
    fselectobjects:= nil;
    include(ainfo.eventstate,es_processed);
   end;
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
 fselectobjects:= nil;
 fmouseoverobjects:= nil;
// exclude(fstate,ops_moving);
end;

function tobjectpicker.hasselectobjects: boolean;
begin
 result:= fselectobjects <> nil;
end;

function tobjectpicker.hasmouseoverobjects: boolean;
begin
 result:= fselectobjects <> nil;
end;

function tobjectpicker.picking: boolean;
begin
 result:= ops_picking in fstate;
end;

function tobjectpicker.rectselecting: boolean;
begin
 result:= ops_rectselecting in fstate;
end;

function tobjectpicker.multiselecting: boolean;
begin
 result:= ops_multiselecting in fstate;
end;

function tobjectpicker.moving: boolean;
begin
 result:= ops_moving in fstate;
end;

function tobjectpicker.active: boolean;
begin
 result:= fstate*activestates <> [];
end;

function tobjectpicker.getcurrentobjects: integerarty;
//var
// int1: integer;
begin
{
 if ops_multiselecting in fstate then begin
  result:= fselectobjects;
  for int1:= 0 to high(fmouseoverobjects) do begin
   if finditem(result,fmouseoverobjects[int1]) < 0 then begin
    additem(result,fmouseoverobjects[int1]);
   end;
  end;
 end
 else begin
}
  if (fselectobjects <> nil) or (ops_multiselecting in fstate) then begin
   result:= fselectobjects;
  end
  else begin
   result:= fmouseoverobjects;
  end;
// end;
end;

function tobjectpicker.hascurrentobjects: boolean;
begin
 result:= getcurrentobjects <> nil;
end;

procedure tobjectpicker.dobeforepaint(const acanvas: tcanvas);
var
 int1: integer;
begin
 if ops_xorpicpainted in fstate then begin
  include(fstate,ops_xorpicremoved);
  int1:= acanvas.save;
  if not (forigin = org_widget) then begin //todo org_screen
   acanvas.intersectcliprect(fintf.getwidget.clientrect);
   acanvas.move(fintf.getwidget.clientwidgetpos);
  end;
  initxorcanvas(acanvas);
  dopaint(acanvas);
  exclude(fstate,ops_xorpicpainted);
  acanvas.restore(int1);
 end;
end;

procedure tobjectpicker.doafterpaint(const acanvas: tcanvas);
var
 int1: integer;
begin
 if ops_xorpicremoved in fstate then begin
  exclude(fstate,ops_xorpicremoved);
  int1:= acanvas.save;
  if not (forigin = org_widget) then begin //todo org_screen
   acanvas.intersectcliprect(fintf.getwidget.clientrect);
   acanvas.move(fintf.getwidget.clientwidgetpos);
  end;
  initxorcanvas(acanvas);
  dopaint(acanvas);
  include(fstate,ops_xorpicpainted);
  acanvas.restore(int1);
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
