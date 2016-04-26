{ MSEgui Copyright (c) 2016 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msesizingform;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseforms,mseclasses,mseobjectpicker,msegui,mseguiglob,msepointer,msetypes,
 msegraphics,msegraphutils;
 
type
 tsizingform = class(tmseform,iobjectpicker)
  private
   foptionssizing: optionssizingty;
   fobjectpicker: tobjectpicker;
   procedure setoptionssizing(const avalue: optionssizingty);
  protected
   fpickedges: optionssizingty;
   fpickedgesrect: rectty;
   class function getmoduleclassname: string; override;
   class function hasresource: boolean; override;
   procedure mousepreview(const sender: twidget;
                                         var info: mouseeventinfoty); override;
    //iobjectpicker
   function getcursorshape(const sender: tobjectpicker;
                                var ashape: cursorshapety): boolean;
                                      //true if found
   procedure getpickobjects(const sender: tobjectpicker;
                                        var aobjects: integerarty);
   procedure beginpickmove(const sender: tobjectpicker);
   procedure pickthumbtrack(const sender: tobjectpicker);
   procedure endpickmove(const sender: tobjectpicker);
   procedure cancelpickmove(const sender: tobjectpicker);
   procedure paintxorpic(const sender: tobjectpicker; const acanvas: tcanvas);
  public
   destructor destroy(); override;
  published
   property optionssizing: optionssizingty read foptionssizing 
                                          write setoptionssizing default [];
 end;
   
 sizingformclassty = class of tsizingform;

function createsizingform(const aclass: tclass; 
                   const aclassname: pshortstring): tmsecomponent;

implementation
uses
 sysutils,mseevent;
type
 tmsecomponent1 = class(tmsecomponent);
 
function createsizingform(const aclass: tclass; 
                    const aclassname: pshortstring): tmsecomponent;

begin
 result:= sizingformclassty(aclass).create(nil,false);
 tmsecomponent1(result).factualclassname:= aclassname;
end;

{ tsizingform }

class function tsizingform.getmoduleclassname: string;
begin
 result:= 'tsizingform';
end;

class function tsizingform.hasresource: boolean;
begin
 result:= self <> tsizingform;
end;

procedure tsizingform.setoptionssizing(const avalue: optionssizingty);
begin
 foptionssizing:= avalue;
 if avalue = [] then begin
  freeandnil(fobjectpicker);
 end
 else begin
  if fobjectpicker = nil then begin
   fobjectpicker:= tobjectpicker.create(iobjectpicker(self),org_widget);
   fobjectpicker.thumbtrack:= true;
  end;
 end;
end;

procedure tsizingform.mousepreview(const sender: twidget;
                                                  var info: mouseeventinfoty);
begin
 if (fobjectpicker <> nil) then begin
  translatewidgetpoint1(info.pos,sender,self);
  fobjectpicker.mouseevent(info);
  translatewidgetpoint1(info.pos,self,sender);
  if not (es_processed in info.eventstate) then begin
   inherited;
  end;
 end
 else begin
  inherited;
 end;
end;

const
 shapes: array[0..15] of cursorshapety = (
 cr_default,   //        ,       ,         ,          
 cr_sizehor,   //osi_left,       ,         ,          
 cr_sizever,   //        ,osi_top,         ,          
 cr_topleftcorner, //osi_left,osi_top,         ,          
 cr_sizehor,   //        ,       ,osi_right,          
 cr_default,   //osi_left,       ,osi_right,          
 cr_toprightcorner, //        ,osi_top,osi_right,          
 cr_default,   //osi_left,osi_top,osi_right,          
 cr_sizever,   //        ,       ,         ,osi_bottom
 cr_bottomleftcorner, //osi_left,       ,         ,osi_bottom
 cr_default,   //        ,osi_top,         ,osi_bottom
 cr_default,   //osi_left,osi_top,         ,osi_bottom
 cr_bottomrightcorner,   //        ,       ,osi_right,osi_bottom
 cr_default,   //osi_left,       ,osi_right,osi_bottom
 cr_default,   //        ,osi_top,osi_right,osi_bottom
 cr_default    //osi_left,osi_top,osi_right,osi_bottom
 );
 
function tsizingform.getcursorshape(const sender: tobjectpicker;
               var ashape: cursorshapety): boolean;
const
 sitol = 2*sizingtol;
var
 pt1: pointty;
begin
 result:= false;
 fpickedges:= [];
 pt1:= sender.pickpos;
 if (sender.shiftstate * keyshiftstatesmask = []) and 
                         pointinrect(pt1,mr(nullpoint,size)) then begin
  if pt1.x < sitol then begin
   include(fpickedges,osi_left);
  end;
  if pt1.y < sitol then begin
   include(fpickedges,osi_top);
  end;
  if pt1.x >= fwidgetrect.cx-sitol then begin
   include(fpickedges,osi_right);
  end;
  if pt1.y >= fwidgetrect.cy-sitol then begin
   include(fpickedges,osi_bottom);
  end;
  fpickedges:= fpickedges * foptionssizing;
  result:= fpickedges <> [];
  if result then begin
   ashape:= shapes[int32(fpickedges)];
  end;
 end;
end;

procedure tsizingform.getpickobjects(const sender: tobjectpicker;
               var aobjects: integerarty);
begin
 if fpickedges <> [] then begin
  setlength(aobjects,1);
 end;
end;

procedure tsizingform.beginpickmove(const sender: tobjectpicker);
begin
 fpickedgesrect:= fwidgetrect;
 //dummy
end;

procedure tsizingform.pickthumbtrack(const sender: tobjectpicker);
var
 rect1: rectty;
begin
 rect1:= fpickedgesrect;
 if osi_left in fpickedges then begin
  rect1.x:= rect1.x + sender.pickoffset.x;
  rect1.cx:= rect1.cx - sender.pickoffset.x;
 end;
 if osi_top in fpickedges then begin
  rect1.y:= rect1.y + sender.pickoffset.y;
  rect1.cy:= rect1.cy - sender.pickoffset.y;
 end;
 if osi_right in fpickedges then begin
  rect1.cx:= rect1.cx + sender.pickoffset.x;
 end;
 if osi_top in fpickedges then begin
  rect1.cy:= rect1.cy + sender.pickoffset.y;
 end;
 widgetrect:= rect1;
end;

procedure tsizingform.endpickmove(const sender: tobjectpicker);
begin
 //dummy
end;

procedure tsizingform.cancelpickmove(const sender: tobjectpicker);
begin
 widgetrect:= fpickedgesrect;
end;

procedure tsizingform.paintxorpic(const sender: tobjectpicker;
               const acanvas: tcanvas);
begin
 //dummy
end;

destructor tsizingform.destroy();
begin
 fobjectpicker.free;
 inherited;
end;

end.
