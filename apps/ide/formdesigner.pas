{ MSEide Copyright (c) 1999-2006 by Martin Schreiber
   
    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
}
unit formdesigner;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 Classes,mseforms,msegui,mseevent,msegraphutils,msegraphics,msedesignintf,
 mseclasses,msemenuwidgets,msemenus,msefiledialog,msedesigner,typinfo,
 componentpaletteform,msestrings,msewidgets;

type
 areaty = (ar_none,ar_component,ar_selectrect,ht_topleft,ht_top,ht_topright,ht_right,
             ht_bottomright,ht_bottom,ht_bottomleft,ht_left);
 markerty = (mt_topleft,mt_topright,mt_bottomright,mt_bottomleft);

const
 firsthandle = ht_topleft;
 lasthandle = ht_left;
 defaultgridsizex = 8;
 defaultgridsizey = 8;
 handlesize = 5;
 componentsize = 24;
 complabelleftmargin = 2;
 complabelrightmargin = 2 + handlesize div 2;

type
 tformdesignerfo = class(tmseform)
   popupme: tpopupmenu;
   procedure doshowobjectinspector(const sender: tobject);
   procedure doshowcomponentpalette(const sender: tobject);
   procedure doshowastext(const sender: tobject);
   procedure doeditcomponent(const sender: tobject);
   procedure doinsertsubmodule(const sender: tobject);
   procedure dobringtofront(const sender: tobject);
   procedure dosendtoback(const sender: tobject);
   procedure dosettaborder(const sender: tobject);
   procedure dosyncfontheight(const sender: tobject);
   procedure copyexe(const sender: TObject);
   procedure pasteexe(const sender: TObject);
   procedure deleteexe(const sender: TObject);
   procedure undeleteexe(const sender: TObject);
   procedure cutexe(const sender: TObject);
   procedure calcscrollsize(const sender: tscrollingwidget; var asize: sizety);
   procedure formdeonclose(const sender: TObject);
   procedure revertexe(const sender: TObject);
  private
   fdesigner: tdesigner;
   fform: twidget;
   fmodule: tmsecomponent;
   fmodulesetting: integer;
   procedure setmodule(const Value: tmsecomponent);
  protected
   procedure widgetregionchanged(const sender: twidget); override;
   procedure sizechanged; override;
   procedure doasyncevent(var atag: integer); override;
   procedure dobeforepaint(const canvas: tcanvas); override;
   procedure doafterpaint(const canvas: tcanvas); override;
   procedure createwindow; override;
   procedure doactivate; override;
   procedure ValidateRename(AComponent: TComponent;
      const CurName, NewName: string); override;
   procedure doshow; override;
  public
   constructor create(aowner: tcomponent; adesigner: tdesigner); reintroduce;
   function designnotification: idesignnotification;
   procedure updatecaption;
   property module: tmsecomponent read fmodule write setmodule;
   property form: twidget read fform;
 end;

 formselectedinfoty = record
  selectedinfo: selectedinfoty;
  rect: rectty;
  handles: array[firsthandle..lasthandle] of rectty;
  markers: array[markerty] of rectty;
 end;

 pformselectedinfoty = ^formselectedinfoty;

 tdesignwindow = class;

 tformdesignerselections = class(tdesignerselections)
  private
   fowner: tdesignwindow;
   finfovalid: boolean;
   fmovingchecked: boolean;
   procedure updateinfos;
   procedure paint(const canvas: tcanvas);
   procedure beforepaintmoving;
   procedure paintmoving(const canvas: tcanvas; const pos: pointty);
   function move(const dist: pointty): boolean;
                  //false if nothing is moved
   procedure resize(const dist: pointty);
   procedure deletecomponents;
   function getareainfo(const pos: pointty; out index: integer): areaty;
  protected
   function getrecordsize: integer; override;
   procedure externalcomponentchanged(const acomponent: tobject);
   procedure removeforeign; //removes form and components in other modules
  public
   constructor create(owner: tdesignwindow);
   function assign(const source: idesignerselections): boolean;
              //true if owned components involved
   function remove(const ainstance: tcomponent): integer; override;
   procedure change; override;
   procedure dochanged; override;
   procedure componentschanged;
   function itempo(const index: integer): pformselectedinfoty;
 end;

 selectmodety = (sm_select,sm_add,sm_flip,sm_remove);

 tdesignwindow = class(twindow,idesignnotification)
  private
   fgridsizex: integer;
   fgridsizey: integer;
   fpickpos: pointty;
   fmousepos: pointty;
   fpickwidget: twidget;
   fsizerect,factsizerect: rectty;
   fxorpicoffset: pointty;
   fxorpicactive: boolean;
   fxorpicshowed: boolean;
   factarea: areaty;
   factcompindex: integer;
   fselecting: integer;
   fselections: tformdesignerselections;
   fdesigner: tdesigner;
   fsnaptogrid: boolean;
   fshowgrid: boolean;
   fdelobjs: objinfoarty;
   fclipinitcomps: boolean;
   fclickedcompbefore: tcomponent;
   procedure drawgrid(const canvas: tcanvas);
   procedure hidexorpic(const canvas: tcanvas);
   procedure showxorpic(const canvas: tcanvas);
   procedure paintxorpic(const canvas: tcanvas);
   procedure checkdelobjs(const aitem: tcomponent);

   procedure doaddcomponent(component: tcomponent);
   procedure doinitcomponent(component: tcomponent; parent: tcomponent);

   procedure setshowgrid(const avalue: boolean);
   procedure setgridsizex(const avalue: integer);
   procedure setgridsizey(const avalue: integer);
   procedure doundelete;
   procedure dodelete;
   procedure dopaste;
   procedure docopy(const noclear: boolean);
   procedure docut;
   procedure recalcclientsize;
  protected
   procedure sizechanged; override;
   procedure poschanged; override;
   procedure dispatchmouseevent(var info: mouseeventinfoty; capture: twidget); override;
   procedure dispatchkeyevent(const eventkind: eventkindty; var info: keyeventinfoty); override;
   procedure dobeforepaint(const canvas: tcanvas);
   procedure doafterpaint(const canvas: tcanvas);
   procedure movewindowrect(const dist: pointty; const rect: rectty); override;
   function dosnaptogrid(const pos: pointty): pointty;
   function snaptogriddelta(const pos: pointty): pointty;
   function form: twidget;
   function module: tmsecomponent;
   function insertoffset: pointty;
   function gridoffset: pointty;
   function componentscrollsize: sizety;

   procedure setrootpos(const component: tcomponent; const apos: pointty);
   procedure beginselect;
   procedure endselect;
   procedure updateselections;
   procedure deletecomponent(const component: tcomponent);
   procedure selectcomponent(const component: tcomponent; mode: selectmodety = sm_select);
   procedure clearselection;
   procedure domodified;

   procedure dopopup(var info: mouseeventinfoty);

   function widgetatpos(const apos: pointty; onlywidgets: boolean): twidget;
   procedure placecomponent(const component: tcomponent; const apos: pointty);

   //idesignnotification
   procedure itemdeleted(const adesigner: idesigner;
                  const amodule: tmsecomponent; const aitem: tcomponent);
   procedure iteminserted(const adesigner: idesigner;
                  const amodule: tmsecomponent; const aitem: tcomponent);
   procedure itemsmodified(const adesigner: idesigner; const aitem: tobject);
   procedure componentnamechanging(const adesigner: idesigner;
                     const amodule: tmsecomponent; const aitem: tcomponent;
                     const newname: string);
   procedure moduleclassnamechanging(const adesigner: idesigner;
                     const amodule: tmsecomponent; const newname: string);
   procedure instancevarnamechanging(const adesigner: idesigner;
                     const amodule: tmsecomponent; const newname: string);
   procedure selectionchanged(const adesigner: idesigner;
                                    const aselection: idesignerselections);
   procedure moduleactivated(const adesigner: idesigner; const amodule: tmsecomponent);
   procedure moduledeactivated(const adesigner: idesigner; 
                   const amodule: tmsecomponent);
   procedure moduledestroyed(const adesigner: idesigner; const amodule: tmsecomponent);
   procedure methodcreated(const adesigner: idesigner;
                          const amodule: tmsecomponent;
                          const aname: string; const atype: ptypeinfo);
   procedure methodnamechanged(const adesigner: idesigner;
                          const amodule: tmsecomponent;
                          const newname,oldname: string; const atypeinfo: ptypeinfo);
   procedure showobjecttext(const adesigner: idesigner;
                  const afilename: filenamety; const backupcreated: boolean);
   procedure closeobjecttext(const adesigner: idesigner;
                    const afilename: filenamety; var cancel: boolean);

  public
   constructor create(aowner: tformdesignerfo; adesigner: tdesigner);
   destructor destroy; override;
   procedure updateprojectoptions;
   property snaptogrid: boolean read fsnaptogrid write fsnaptogrid default true;
   property showgrid: boolean read fshowgrid write setshowgrid default true;
   property gridsizex: integer read fgridsizex write setgridsizex 
                                     default defaultgridsizex;
   property gridsizey: integer read fgridsizey write setgridsizey
                                     default defaultgridsizey;
 end;

implementation
uses
 formdesigner_mfm,mselist,msekeyboard,mseguiglob,msepointer,msebits,sysutils,
 msestockobjects,msedrawtext,selectsubmoduledialogform,mseshapes,settaborderform,
 msedatalist,objectinspector,projectoptionsform,main,msedatamodules;

type
 tcomponent1 = class(tcomponent);
 twidget1 = class(twidget);
 tmseform1 = class(tmseform);
 tframe1 = class(tframe);

 designerfoeventty = (fde_none,fde_syncsize,fde_updatecaption);

function getcomponentrect(const sender: twidget;
                                    const component: tcomponent): rectty;
begin
 result.pos:= getcomponentpos(component);
 result.cx:= componentsize + complabelleftmargin + 
                 sender.getcanvas.getstringwidth(component.name) +
                  complabelrightmargin;
 result.cy:= componentsize;
end;

function getcomponentrect1(const sender: twidget; const component: tcomponent;
                                     const module: tcomponent): rectty;
var
 comp1: tcomponent;
begin
 result:= getcomponentrect(sender,component);
 comp1:= component;
 while (comp1 <> module) and (comp1 <> nil) do begin
  if comp1 is twidget then begin
   addpoint1(result.pos,twidget(comp1).pos);
  end;
  comp1:= comp1.owner;
 end;
end;

function componentatpos(const sender: twidget; const module: tmsecomponent;
                                      const pos: pointty): tcomponent;

var
 isdatamodule: boolean;
 toplevel: boolean;
                                       
 function checkcomponent(const component: tcomponent; const pos: pointty): tcomponent;
 var
  int1: integer;
  po1: pointty;
  bo1: boolean;
 begin
  result:= nil;
  bo1:= component is twidget;
  if bo1 then begin
   po1:= subpoint(pos,twidget(component).pos);
  end
  else begin
   po1:= pos;
  end;
  if toplevel or 
              not isdatamodule and bo1 and 
              not (cssubcomponent in component.componentstyle) and
              (csinline in component.componentstate) then begin
   toplevel:= false;
   for int1:= component.componentcount - 1 downto 0 do begin
    result:= checkcomponent(component.components[int1],po1);
    if result <> nil then begin
     exit;
    end;
   end;
  end;
  if not bo1 or isdatamodule then begin
   if pointinrect(pos,getcomponentrect(sender,component)) then begin
    result:= component;
   end;
  end;
 end;
 
begin
 isdatamodule:= not (module is twidget);
 toplevel:= true;
 result:= checkcomponent(module,pos);
 if result = module then begin
  result:= nil;
 end;
end;

{ tformdesignerselections }

constructor tformdesignerselections.create(owner: tdesignwindow);
begin
 fowner:= owner;
 inherited create;
end;

function tformdesignerselections.assign(const source: idesignerselections): boolean;
              //true if owned components involved
var
 amodule: tmsecomponent;

 procedure checkowned;
 var
  int1: integer;
  po1: pformselectedinfoty;
 begin
  po1:= datapo;
  for int1:= 0 to count - 1 do begin
   if (po1^.selectedinfo.instance = amodule) or
           (po1^.selectedinfo.instance.Owner = amodule) then begin
    result:= true;
    break;
   end;
   inc(po1);
  end;
 end;

begin
 result:= false;
 amodule:= tformdesignerfo(fowner.fowner).fmodule;
 checkowned;
 inherited assign(source);
 if not result then begin
  checkowned;
 end;
end;

procedure tformdesignerselections.updateinfos;
var
 marker: markerty;
 int1: integer;
begin
 if not finfovalid then begin
  for int1:= 0 to count - 1 do begin
   with itempo(int1)^,selectedinfo do begin
    if (instance is twidget) and (fowner.form <> nil) then begin
     with twidget(instance) do begin
      rect:= makerect(rootpos,size);
     end;
    end
    else begin
     if instance is tcomponent then begin
      rect:= getcomponentrect1(fowner.fowner,tcomponent(instance),fowner.module);
     end
     else begin
      rect:= nullrect;
     end;
    end;
    with rect do begin
     centerrect(pos,handlesize,handles[ht_topleft]);
     centerrect(makepoint(x+cx div 2,y),handlesize,handles[ht_top]);
     centerrect(makepoint(x+cx-1,y),handlesize,handles[ht_topright]);
     centerrect(makepoint(x+cx-1,y+cy div 2),handlesize,handles[ht_right]);
     centerrect(makepoint(x+cx-1,y+cy-1),handlesize,handles[ht_bottomright]);
     centerrect(makepoint(x+cx div 2,y+cy-1),handlesize,handles[ht_bottom]);
     centerrect(makepoint(x,y+cy-1),handlesize,handles[ht_bottomleft]);
     centerrect(makepoint(x,y+cy div 2),handlesize,handles[ht_left]);

     for marker:= low(marker) to high(marker) do begin
      markers[marker].cx:= handlesize;
      markers[marker].cy:= handlesize;
     end;
     markers[mt_topleft].pos:= pos;
     markers[mt_topright].x:= x + cx - handlesize;
     markers[mt_topright].y:= y;
     markers[mt_bottomright].x:= x + cx - handlesize;
     markers[mt_bottomright].y:= y + cy - handlesize;
     markers[mt_bottomleft].x:= x;
     markers[mt_bottomleft].y:= y + cy - handlesize;

    end;
   end;
  end;
 end;
 finfovalid:= true;
end;

procedure tformdesignerselections.beforepaintmoving;
begin
 if not fmovingchecked then begin
  removeforeign;
  fmovingchecked:= true;
 end;
 updateinfos;
end;

procedure tformdesignerselections.paintmoving(const canvas: tcanvas;
                 const pos: pointty);
var
 int1: integer;
 po1: pformselectedinfoty;
begin
 beforepaintmoving;
 with canvas do begin
  save;
  move(pos);
  rasterop:= rop_xor;
  for int1:= 0 to count-1 do begin
   po1:= itempo(int1);
   if po1^.selectedinfo.instance <> fowner.module then begin
    drawframe(itempo(int1)^.rect,-2,cl_white);
   end;
  end;
  restore;
 end;
end;

procedure tformdesignerselections.paint(const canvas: tcanvas);
var
 int1: integer;
 handle: areaty;
 marker: markerty;
begin
 updateinfos;
 with canvas do begin
  if count > 1 then begin
   for int1:= 0 to count - 1 do begin
    with itempo(int1)^,selectedinfo do begin
     if (instance <> fowner.module) and fowner.module.checkowned(instance) then begin
      for marker:= low(markerty) to high(markerty) do begin
       fillrect(markers[marker],cl_dkgray);
      end;
     end;
    end;
   end;
  end
  else begin
   for int1:= 0 to count - 1 do begin
    with itempo(int1)^,selectedinfo do begin
     if (instance <> fowner.module) and fowner.module.checkowned(instance) then begin
      for handle:= firsthandle to lasthandle do begin
       fillrect(handles[handle],cl_black);
      end;
     end;
    end;
   end;
  end;
 end;
end;

function tformdesignerselections.move(const dist: pointty): boolean;
var
 int1: integer;
 widget1: twidget;
 comp1: tcomponent;
begin
 result:= false;
 if (dist.x <> 0) or (dist.y <> 0) then begin
  for int1:= 0 to count - 1 do begin
   with itempo(int1)^,selectedinfo do begin
    if (fowner.form <> nil) and (instance is twidget) and
         (instance <> fowner.module) then begin
     widget1:= twidget(instance).parentwidget;
     while widget1 <> nil do begin
      if (widget1 <> fowner.form) and (indexof(widget1) >= 0) then begin
       break;  //moved by parent
      end;
      widget1:= widget1.parentwidget;
     end;
     if widget1 = nil then begin
      with twidget(instance) do begin
       pos:= addpoint(pos,dist);
       result:= true;
      end;
     end;
    end
    else begin
     comp1:= tcomponent(instance).owner;
     while comp1 <> nil do begin
      if (comp1 <> fowner.module) and (comp1 is twidget) and
                                        (indexof(comp1) >= 0) then begin 
       break; //moved by owner
      end;
      comp1:= comp1.owner;
     end;
     if comp1 = nil then begin
      fowner.fowner.invalidaterect(getcomponentrect1(
                                         fowner.fowner,tcomponent(instance),
                                         fowner.module));
      setcomponentpos(tcomponent(instance),
             addpoint(getcomponentpos(tcomponent(instance)),dist));
      fowner.fowner.invalidaterect(getcomponentrect1(
                                         fowner.fowner,tcomponent(instance),
                                         fowner.module));
      result:= true;
     end;
    end;
   end;
  end;
  componentschanged;
 end;
end;

procedure tformdesignerselections.resize(const dist: pointty);
var
 int1: integer;
begin
 if (dist.x <> 0) or (dist.y <> 0) then begin
  for int1:= 0 to count - 1 do begin
   with itempo(int1)^,selectedinfo do begin
    if instance is twidget then begin
     with twidget(instance) do begin
      size:= sizety(addpoint(pointty(size),dist));
     end;
    end;
   end;
  end;
  componentschanged;
 end;
end;

procedure tformdesignerselections.change;
begin
 finfovalid:= false;
 fmovingchecked:= false;
 inherited;
end;

procedure tformdesignerselections.dochanged;
begin
 inherited;
 fowner.fowner.invalidate;
end;

procedure tformdesignerselections.componentschanged;
var
 int1: integer;
begin
 change;
 for int1:= 0 to count - 1 do begin
  fowner.fdesigner.componentmodified(items[int1]);
 end;
end;

procedure tformdesignerselections.externalcomponentchanged(const acomponent: tobject);
begin
 finfovalid:= false;
 if count > 0 then begin
  fowner.fowner.invalidate;
 end;
end;

function tformdesignerselections.getareainfo(const pos: pointty;
                out index: integer): areaty;
var
 handle: areaty;
 int1: integer;
begin
 result:= ar_none;
 index:= -1;
 if count = 1 then begin
  with itempo(0)^,selectedinfo do begin
   if instance is tcomponent then begin
    if instance is twidget then begin
     for handle:= firsthandle to lasthandle do begin
      if pointinrect(pos,handles[handle]) then begin
       result:= handle;
       index:= 0;
       exit;
      end;
     end;
    end;
    if pointinrect(pos,rect) then begin
     result:= ar_component;
     index:= 0;
     exit;
    end;
   end;
  end;
 end
 else begin
  for int1:= 0 to count - 1 do begin
   with itempo(int1)^,selectedinfo do begin
    if pointinrect(pos,rect) and (instance is tcomponent) then begin
     result:= ar_component;
     index:= int1;
     break;
    end;
   end;
  end;
 end;
end;

procedure tformdesignerselections.deletecomponents;
var
 int1: integer;
 int2: integer;
begin
 int2:= count;
 beginupdate;
 for int1:= count-1 downto 0 do begin
  if isembedded(items[int1]) then begin
   delete(int1);
  end;
 end;
 endupdate;
 if count <> int2 then begin
  fowner.updateselections;
 end;
 fowner.fDesigner.DeleteSelection;
end;

function tformdesignerselections.getrecordsize: integer;
begin
 result:= sizeof(formselectedinfoty);
end;

function tformdesignerselections.itempo(
  const index: integer): pformselectedinfoty;
begin
 result:= pformselectedinfoty(getitempo(index));
end;

function tformdesignerselections.remove(
  const ainstance: tcomponent): integer;
begin
 if ainstance = fowner.fpickwidget then begin
  fowner.fpickwidget:= nil;
 end;
 result:= inherited remove(ainstance);
end;

procedure tformdesignerselections.removeforeign; 
    //removes form and components in other modules
var
 int1: integer;
 co1: tcomponent;
begin
 beginupdate;
 for int1:= count - 1 downto 0 do begin
  co1:= items[int1];
  if (co1 = fowner.module) or not fowner.module.checkowned(co1) then begin
   delete(int1);
  end;
 end;
 endupdate;
 fowner.updateselections;
end;

{ tdesignwindow }

constructor tdesignwindow.create(aowner: tformdesignerfo; adesigner: tdesigner);
begin
 fdesigner:= adesigner;
 fshowgrid:= true;
 fsnaptogrid:= true;
 fgridsizex:= defaultgridsizex;
 fgridsizey:= defaultgridsizey;
 fselections:= tformdesignerselections.create(self);
 inherited create(aowner);
 updateprojectoptions;
 designnotifications.registernotification(idesignnotification(self));
end;

destructor tdesignwindow.destroy;
begin
 designnotifications.unregisternotification(idesignnotification(self));
 inherited;
 fselections.free;
end;

procedure tdesignwindow.paintxorpic(const canvas: tcanvas);
begin
 if fxorpicactive then begin
  canvas.save;
  canvas.intersectcliprect(fowner.container.paintrect);
  canvas.move(fowner.container.clientpos);
  case factarea of
   firsthandle..lasthandle: begin
    with canvas do begin
     save;
     rasterop:= rop_xor;
     drawframe(factsizerect,-2,cl_white);
     restore;
    end;
   end;
   ar_component: begin
    fselections.paintmoving(canvas,fxorpicoffset);
   end;
   ar_selectrect: begin
    with canvas do begin
     drawxorframe(fpickpos,fxorpicoffset,1,stockobjects.bitmaps[stb_block3]);
    end;
   end;
  end;
  canvas.restore;
 end;
end;

procedure tdesignwindow.hidexorpic(const canvas: tcanvas);
begin
 if fxorpicshowed then begin
  paintxorpic(canvas);
  fxorpicshowed:= false;
 end;
end;

procedure tdesignwindow.showxorpic(const canvas: tcanvas);
begin
 if not fxorpicshowed then begin
  paintxorpic(canvas);
  fxorpicshowed:= true;
 end;
end;

procedure tdesignwindow.movewindowrect(const dist: pointty; const rect: rectty);
var
 canvas: tcanvas;
begin
 if isnullpoint(dist) then begin
  exit;
 end;
 canvas:= fowner.getcanvas(org_widget);
 hidexorpic(canvas);
 fxorpicactive:= false;
 fselections.change;
 inherited;
 invalidaterect(moverect(rect,dist)); //redraw grid
end;

procedure tdesignwindow.dobeforepaint(const canvas: tcanvas);
begin
 hidexorpic(canvas);
 inherited;
end;

procedure tdesignwindow.doafterpaint(const canvas: tcanvas);

 procedure drawcomponent(const component: tcomponent);
 var
  rect1: rectty;
  int1: integer;
  bo1: boolean;
 begin
  if ((form = nil) or not (component is twidget)) and 
           not (cssubcomponent in component.componentstyle) then begin
   rect1:= getcomponentrect(fowner,component);
   rect1.cx:= rect1.cx - complabelrightmargin;
   drawtext(canvas,component.name,rect1,[tf_ycentered,tf_right],
                      stockobjects.fonts[stf_default]);
   rect1.cx:= rect1.cy;
   registeredcomponents.drawcomponenticon(component,canvas,rect1);
  end;
  if (form <> nil) and (component is twidget) and 
                      not (cssubcomponent in component.componentstyle) and 
                      (csinline in component.componentstate) then begin
   canvas.move(twidget(component).pos);
   for int1:= 0 to component.componentcount - 1 do begin
    drawcomponent(component.components[int1]);        //components of submodule
   end;
   canvas.remove(twidget(component).pos);
  end;
 end;
 
var
 int1: integer;
begin
 canvas.intersectcliprect(fowner.container.paintrect);
 canvas.move(fowner.container.clientpos);
 with tformdesignerfo(fowner).fmodule do begin
  for int1:= 0 to componentcount - 1 do begin
   drawcomponent(components[int1]);
  end;
 end;
 if form <> nil then begin
  drawgrid(canvas);
 end;
 fselections.paint(canvas);
 canvas.remove(fowner.container.clientpos);
 showxorpic(canvas);
end;

function tdesignwindow.componentscrollsize: sizety;
var
 int1,int2: integer;
 component: tcomponent;
 rect1: rectty;
begin
 result:= nullsize;
 if tformdesignerfo(fowner).fmodule <> nil then begin
  with tformdesignerfo(fowner).fmodule do begin
   for int1:= 0 to componentcount - 1 do begin
    component:= Components[int1];
    if (form = nil) or not (component is twidget) then begin
     rect1:= getcomponentrect(fowner,component);
     int2:= rect1.x + rect1.cx;
     if int2 > result.cx then begin
      result.cx:= int2;
     end;
     int2:= rect1.y + rect1.cy;
     if int2 > result.cy then begin
      result.cy:= int2;
     end;
    end;
   end;
  end;
 end;
 inc(result.cx,handlesize);
 inc(result.cy,handlesize);
end;

procedure tdesignwindow.doaddcomponent(component: tcomponent);
var
 comp1: tcomponent;
begin
 comp1:= component.owner;
 fdesigner.addcomponent(module,component);
 if csinline in component.ComponentState then begin
  tcomponent1(component).getchildren({$ifdef FPC}@{$endif}doaddcomponent,component);
 end
 else begin
// if comp1 <> nil then begin //else submodule
  tcomponent1(component).getchildren({$ifdef FPC}@{$endif}doaddcomponent,comp1);
 end;
end;

procedure tdesignwindow.doinitcomponent(component: tcomponent; parent: tcomponent);
var
 rect1: rectty;
 size1: sizety;
 int1: integer;
begin
 doaddcomponent(component);
 if (component is twidget) and (parent is twidget) then begin
  twidget(parent).insertwidget(twidget(component));
  if fclipinitcomps then begin
   rect1:= twidget(component).widgetrect;
   shiftinrect(rect1,makerect(nullpoint,twidget(component).parentwidget.size));
   twidget(component).widgetrect:= rect1;
  end;
 end;
end;

procedure tdesignwindow.docopy(const noclear: boolean);
begin
 fselections.remove(module);
 fselections.copytoclipboard;
 if not noclear then begin
  fselections.clear;
  selectcomponent(module);
 end;
end;

procedure tdesignwindow.docut;
begin
 docopy(true);
 dodelete;
end;

procedure tdesignwindow.dopaste;
var
 widget1: twidget;
begin
 try
  if form <> nil then begin
   fclipinitcomps:= true;
   with fselections do begin
    if count = 1 then begin
     widget1:= twidget(items[0]);
     if (widget1 is twidget) and form.checkdescendent(widget1) then begin
      clear;
      pastefromclipboard(module,widget1,{$ifdef FPC}@{$endif}doinitcomponent);
      updateselections;
     end;
    end;
   end;
  end
  else begin
   fselections.clear;
   fselections.pastefromclipboard(module,module,{$ifdef FPC}@{$endif}doinitcomponent);
   updateselections;
   //todo
  end;
 finally
  fclipinitcomps:= false;
 end;
 recalcclientsize;
end;

procedure tdesignwindow.doundelete;
var
 int1: integer;
begin
 if fdelobjs <> nil then begin
  with fselections do begin
   clear;
   for int1:= 0 to high(fdelobjs) do begin
    with fdelobjs[int1] do begin
     pastefromobjecttext(objtext,owner,parent,
                    {$ifdef FPC}@{$endif}doinitcomponent);
    end;
   end;
   for int1:= count-1 downto 0 do begin
    if isembedded(items[int1]) then begin
     delete(int1);
    end;
   end;
  end;
  updateselections;
  fdelobjs:= nil;
 end;
end;

procedure tdesignwindow.dodelete;
var
 int1: integer;
begin
 with fselections do begin
  removeforeign;
  fdelobjs:= fselections.getobjinfoar;
  deletecomponents;
 end;
 domodified;
 recalcclientsize;
end;

procedure tdesignwindow.dispatchkeyevent(const eventkind: eventkindty;
  var info: keyeventinfoty);


var
 po1: pointty;
 widget1: twidget;
// component1: tcomponent;

begin
 if eventkind = ek_keypress then begin
  with info do begin
   if shiftstate = [] then begin
    include(eventstate,es_processed);
    case key of
     key_escape: begin
      if (fselections.count > 1) or (form = nil) then begin
       selectcomponent(module);
      end
      else begin
       if fselections.count = 1 then begin
        widget1:= twidget(fselections[0]);
        if widget1 is twidget then begin
         repeat
          widget1:= widget1.parentwidget;
         until (widget1 = nil) or (ws_iswidget in widget1.widgetstate);
         if (widget1 <> nil) and (widget1 <> fowner) then begin
          selectcomponent(widget1);
         end
         else begin
          selectcomponent(module);
         end;
        end
        else begin
         selectcomponent(module);
        end;
       end;
      end;
     end;
     key_delete: begin
      dodelete;
     end;
     else begin
      exclude(eventstate,es_processed);
     end;
    end;
   end
   else begin
    if (shiftstate = [ss_ctrl]) or (shiftstate = [ss_shift]) then begin
     include(eventstate,es_processed);
     po1:= nullpoint;
     case key of
      key_right: po1.x:= 1;
      key_up: po1.y:= -1;
      key_left: po1.x:= -1;
      key_down: po1.y:= 1;
      else exclude(eventstate,es_processed);
     end;
     if (es_processed in eventstate) then begin
      if shiftstate = [ss_ctrl] then begin
       fselections.move(po1);
      end
      else begin
       fselections.resize(po1);
      end;
      fowner.invalidate;
      recalcclientsize;
//      domodified;
     end;
    end;
   end;
   if not (es_processed in eventstate) then begin
    if shiftstate = [ss_ctrl] then begin
     include(eventstate,es_processed);
     case key of
      key_c: begin
       docopy(false);
      end;
      key_x: begin
       docut;
      end;
      key_v: begin
       dopaste;
      end;
      else begin
       exclude(eventstate,es_processed);
      end;
     end;
    end;
   end;
  end;
 end;
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;

procedure tdesignwindow.dopopup(var info: mouseeventinfoty);

var
 bo1: boolean;
begin
 with tformdesignerfo(fowner).popupme,menu do begin
  bo1:= (fselections.count > 0) and (fselections[0] <> module);
  itembyname('copy').enabled:= bo1;
  itembyname('cut').enabled:= bo1;
  itembyname('delete').enabled:= bo1;
  itembyname('undelete').enabled:= fdelobjs <> nil;
  itembyname('paste').enabled:= true;
  itembyname('editcomp').enabled:= designer.componentcanedit;
  bo1:= not((fselections.count <> 1) or not(fselections.items[0] is twidget) or
           not fowner.checkdescendent(twidget(fselections.items[0])));
  itembyname('insertsub').enabled:= bo1;
  itembyname('revert').enabled:= (fselections.count = 1) and 
          (fselections[0].componentstate * [csinline,csancestor] <> []);
  itembyname('bringtofro').enabled:= bo1;
  itembyname('sendtoba').enabled:= bo1;
  itembyname('settabord').enabled:= bo1 and 
          (twidget(fselections.items[0]).parentwidget.childrencount >= 2);
  itembyname('synctofo').enabled:= fselections.count > 0;
  show(fowner,info);
 end;
end;

function tdesignwindow.widgetatpos(const apos: pointty; onlywidgets: boolean): twidget;
var
 widgetinfo: widgetatposinfoty;
begin
 fillchar(widgetinfo,sizeof(widgetinfo),0);
 with widgetinfo do begin
  pos:= apos;
  if onlywidgets then begin
   childstate:= [ws_iswidget,ws_isvisible];
  end
  else begin
   childstate:= [ws_isvisible];
  end;
  parentstate:= [ws_isvisible];
 end;
 result:= form.widgetatpos(widgetinfo);
end;

procedure tdesignwindow.placecomponent(const component: tcomponent;
                                                      const apos: pointty);
var
 widget1: twidget;
 po1: pointty;
begin
 try
  if component is tmsecomponent then begin
   tmsecomponent(component).initnewcomponent;
  end;
  if (component is twidget) and (form <> nil) then begin
   widget1:= widgetatpos(apos,true);
//   while (widget1 <> nil) and ((csancestor in widget1.componentstate) or
//                not (ws_iswidget in widget1.widgetstate)) do begin
//      //regular components can not be streamed in inherited modules
//    widget1:= widget1.parentwidget;
//   end;
   if widget1 <> nil then begin
    po1:= dosnaptogrid(apos);
    widget1.insertwidget(twidget(component),translatewidgetpoint(po1,form,
                                                  widget1));
   end;
  end
  else begin
   if form <> nil then begin
    setrootpos(component,form.clientpostowidgetpos(
          dosnaptogrid(form.widgetpostoclientpos(apos))));
   end
   else begin
    setrootpos(component,dosnaptogrid(apos));
   end;
  end;
  tcomponent1(component).loaded;
  domodified;
 except
  deletecomponent(component);
  raise;
 end;
 selectcomponent(component);
end;

procedure tdesignwindow.recalcclientsize;
begin
 if tformdesignerfo(fowner).fform = nil then begin
  with twidget1(fowner.container) do begin
   exclude(fwidgetstate,ws_minclientsizevalid);
   tframe1(frame).updatestate;
  end;
 end;
end;

procedure tdesignwindow.dispatchmouseevent(var info: mouseeventinfoty;
                         capture: twidget);

 function griddelta: pointty;
 begin
  result:= snaptogriddelta(subpoint(info.pos,fpickpos));
 end;

 procedure updatesizerect;
 var
  pos1,posbefore: pointty;
 begin
  pos1:= griddelta;
  posbefore:= pos1;
  with fsizerect,pos1 do begin
   case factarea of
    ht_topleft,ht_left,ht_bottomleft: begin
     if x > size.cx then begin
      x:= size.cx
     end;
     factsizerect.pos.x:= pos.x + x;
     factsizerect.size.cx:= size.cx - x;
    end;
    ht_topright,ht_right,ht_bottomright: begin
     if x < -size.cx then begin
      x:= -size.cx;
     end;
     factsizerect.size.cx:= size.cx + x;
    end;
   end;
   case factarea of
    ht_topleft,ht_top,ht_topright: begin
     if y > size.cy then begin
      y:= size.cy
     end;
     factsizerect.pos.y:= pos.y + y;
     factsizerect.size.cy:= size.cy - y;
    end;
    ht_bottomleft,ht_bottom,ht_bottomright: begin
     if y < -size.cy then begin
      y:= -size.cy;
     end;
     factsizerect.size.cy:= size.cy + y;
    end;
   end;
  end;
  case factarea of
   ht_top,ht_bottom: begin
    info.pos.x:= fpickpos.x;
   end;
   ht_left,ht_right: begin
    info.pos.y:= fpickpos.y;
   end;
  end;
  application.mouse.move(subpoint(pos1,posbefore));
 end;

 procedure updatecursorshape(area: areaty);
 var
  shape: cursorshapety;
 begin
  case area of
   ht_topleft: shape:= cr_topleftcorner;
   ht_bottomright: shape:= cr_bottomrightcorner;
   ht_topright: shape:= cr_toprightcorner;
   ht_bottomleft: shape:= cr_bottomleftcorner;
   ht_top,ht_bottom: shape:= cr_sizever;
   ht_left,ht_right: shape:= cr_sizehor;
   else shape:= cr_arrow;
  end;
  application.cursorshape:= shape;
 end;


var
 component: tcomponent;
 int1: integer;
 bo1: boolean;
 posbefore: pointty;
 widget1: twidget;
 rect1: rectty;
 selectmode: selectmodety;
 area1: areaty;
 clipo: pointty;
 isinpaintrect: boolean;
 ss1: shiftstatesty;
label
 1;
begin
 if info.eventkind in [ek_mouseleave,ek_mouseenter] then begin
  fclickedcompbefore:= nil;
  exit;
 end;
 checkmousewidget(info,capture);
 with info do begin
  ss1:= shiftstate * shiftstatesmask;
  isinpaintrect:= pointinrect(pos,fowner.container.paintrect);
  clipo:= fowner.container.clientpos;
  subpoint1(pos,clipo);
  posbefore:= pos;
  if eventkind in [ek_buttonpress,ek_buttonrelease] then begin
   fmousepos:= pos;
  end;
  component:= nil;
  if not (es_processed in eventstate) then begin
   bo1:= false;
   if (eventkind = ek_buttonpress) and (button = mb_left) then begin
    fpickpos:= pos;
    if (ss1 = [ss_left]) or (ss1 = [ss_left,ss_ctrl]) or 
                (ss1 = [ss_left,ss_double]) then begin
     factarea:= fselections.getareainfo(pos,factcompindex);
     if factcompindex >= 0 then begin
      fsizerect:= fselections.itempo(factcompindex)^.rect;
      factsizerect:= fsizerect;
     end;
     if (factarea in [ar_component,ar_none]) then begin
      if isinpaintrect then begin
       component:= componentatpos(fowner,module,pos);
       if (component = nil) then begin
        if form <> nil then begin
         component:= widgetatpos(pos,true);
        end
        else begin
         component:= module;
        end;
       end;
      end;
      if component <> nil then begin
       if (component = module) and (fclickedcompbefore = module) and
                  (ss_double in shiftstate) and isinpaintrect then begin
        mainfo.loadsourcebyform(fdesigner.actmodulepo^.filename,true);
        include(eventstate,es_processed);
        goto 1;
       end;
       if (factcompindex < 0) or (component <> fselections[factcompindex]) then begin
        factarea:= ar_none;
       end;
       bo1:= true;
       if ss_ctrl in ss1 then begin
        selectcomponent(component,sm_flip);
       end
       else begin
        if (component = form) and (fselections.count > 1) or 
               (fselections.indexof(component) < 0) then begin
         selectcomponent(component,sm_select);
        end;
       end;
      end
      else begin
       factarea:= ar_none;
      end;
      fclickedcompbefore:= component;
     end
     else begin
      fowner.capturemouse;
      include(eventstate,es_processed);
     end;
    end
   end;
   if (eventkind = ek_buttonrelease) and (button = mb_right) and
           not (es_processed in eventstate) then begin
    dopopup(info);
   end;
   if not (es_processed in eventstate) then begin
    area1:= fselections.getareainfo(pos,int1);
    if ((area1 < firsthandle) or (area1 > lasthandle)) and
       ((factarea < firsthandle) or (factarea > lasthandle)) and 
       not (fdesigner.hascurrentcomponent and (eventkind = ek_buttonpress) and 
           (button = mb_left) and (ss1 = [ss_left])) then begin
     addpoint1(pos,clipo);
     inherited;
     subpoint1(pos,clipo);
    end;
    pos:= posbefore;
    if bo1 then begin
     if not (es_processed in eventstate) then begin
      fowner.capturemouse; //capture mouse
      updatecursorshape(factarea);
     end
     else begin
      factarea:= ar_none;
     end;
    end;
   end;
   if not (es_processed in eventstate) then begin
    if (eventkind = ek_buttonpress) and (button = mb_left) then begin
     if ss1 = [ss_left] then begin
      if isinpaintrect then begin
       component:= fdesigner.createcurrentcomponent(module);
      end;
      if component <> nil then begin
       placecomponent(component,pos);
       recalcclientsize;
      end;
     end
     else begin
      if (ss1 = [ss_left,ss_shift]) and isinpaintrect then begin
       factarea:= ar_selectrect;
       fxorpicoffset:= pos;
       if form <> nil then begin
        fpickwidget:= widgetatpos(pos,false);
       end
       else begin
        fpickwidget:= fowner;
       end;
      end;
     end;
    end;
    if (eventkind = ek_buttonrelease) and (button = mb_left) then begin
     hidexorpic(fowner.container.getcanvas(org_widget));
     fxorpicactive:= false;
     case factarea of
      firsthandle..lasthandle: begin
       if (factcompindex >= 0) and (factcompindex < fselections.count) then begin
        component:= tcomponent(fselections.itempo(factcompindex)^.selectedinfo.instance);
        if component is twidget then begin
         with twidget(component) do begin
          subpoint1(factsizerect.pos,parentwidget.rootpos);
          widgetrect:= factsizerect;
         end;
         fselections.componentschanged;
        end;
       end;
 //      doModified;
       fowner.invalidate;
      end;
      ar_component: begin
       if fselections.move(griddelta) then begin
        fowner.invalidate; //redraw handles
        recalcclientsize;
       end;
 //      doModified;
      end;
      ar_selectrect: begin
       if fpickwidget <> nil then begin
        rect1.pos:= fpickpos;
        rect1.cx:= pos.x - fpickpos.x;
        rect1.cy:= pos.y - fpickpos.y;
        if (rect1.cx < 0) or (rect1.cy < 0) then begin
         selectmode:= sm_remove;
        end
        else begin
         selectmode:= sm_add;
        end;
        beginselect;
        try
         if (selectmode = sm_add) and (fselections.count = 1) and
               (fselections[0] = module) then begin
          fselections.clear; //remove underlaying form
         end;
         for int1:= 0 to module.componentcount - 1 do begin
          component:= module.Components[int1];
          if not (component is twidget) then begin
           if rectinrect(getcomponentrect1(fowner,component,module),
                                            rect1) then begin
            selectcomponent(component,selectmode);
           end;
          end;
         end;
         if fpickwidget <> fowner then begin
          rect1.pos:= subpoint(fpickpos,fpickwidget.rootpos);
          for int1:= 0 to fpickwidget.widgetcount -1 do begin
           widget1:= fpickwidget[int1];
           if rectinrect(widget1.widgetrect,rect1) then begin
            selectcomponent(widget1,selectmode);
           end;
          end;
         end;
        finally
         endselect;
        end;
       end;
      end;
     end;
     fpickwidget:= nil;
     factarea:= ar_none;
     factcompindex:= -1;
     fowner.releasemouse;
    end;
 
    if not (es_processed in eventstate) then begin
     if (eventkind = ek_mousemove) then begin
      hidexorpic(fowner.getcanvas(org_widget));
      bo1:= true;
      case factarea of
       firsthandle..lasthandle: begin
        updatesizerect;
       end;
       ar_component: begin
        fxorpicoffset:= griddelta;
       end;
       ar_selectrect: begin
        fxorpicoffset:= pos;
       end;
       else begin
        bo1:= false;
        updatecursorshape(fselections.getareainfo(pos,int1));
       end;
      end;
      if bo1 then begin
       fxorpicactive:= true;
       fselections.beforepaintmoving; //resets canvas
       showxorpic(fowner.container.getcanvas(org_widget));
      end;
     end;
    end;
   end;
  end;
1:
  addpoint1(pos,clipo);
 end;
end;

procedure tdesignwindow.selectionchanged(const adesigner: idesigner;
      const aselection: idesignerselections);
begin
 if fselections.assign(aselection) then begin
  fowner.invalidate;
 end;
end;

procedure tdesignwindow.sizechanged;
begin
 inherited;
 {
 if (form <> nil) then begin
  if not sizeisequal(form.size,fowner.size) then begin
   form.size:= fowner.size;
   fowner.size:= form.size;
   doModified;
  end;
 end;
 }
end;

procedure tdesignwindow.poschanged;
begin
 inherited;
// if (form <> nil) then begin
  doModified;
// end;
end;

function tdesignwindow.insertoffset: pointty;
begin
 if form = nil then begin
  result:= fowner.clientpos;
 end
 else begin
  result:= translateclientpoint(nullpoint,form.container,form);
  addpoint1(result,form.paintpos);
 end;
end;

function tdesignwindow.gridoffset: pointty;
begin
 result:= insertoffset;
// addpoint1(result,scrollbox.clientpos);
end;

function tdesignwindow.snaptogriddelta(const pos: pointty): pointty;
begin
 if fsnaptogrid then begin
  result.x:= roundint(pos.x,fgridsizex);
  result.y:= roundint(pos.y,fgridsizey);
 end
 else begin
  result:= pos;
 end;
end;

function tdesignwindow.dosnaptogrid(const pos: pointty): pointty;
begin
 if fsnaptogrid then begin
  result:= snaptogriddelta(subpoint(pos,gridoffset));
  addpoint1(result,gridoffset);
 end
 else begin
  result:= pos;
 end;
end;

procedure tdesignwindow.drawgrid(const canvas: tcanvas);
var
 po1: pointty;
 rect1,rect2: rectty;
 endy: integer;
 offset: pointty;
 points1: pointarty;
 int1: integer;
begin
 if fshowgrid then begin
  if form = nil then begin
   rect2:= fowner.clientrect;
  end
  else begin
   rect2:= form.container.paintrect;
   addpoint1(rect2.pos,form.container.rootpos);
  end;
  msegraphutils.intersectrect(canvas.clipbox,rect2,rect1);
  offset:= gridoffset;
  with rect1 do begin
   po1.x:= ((x - offset.x) div fgridsizex) * fgridsizex + offset.x;
   po1.y:= ((y - offset.y) div fgridsizey) * fgridsizey + offset.y;
   endy:= y + cy;
  end;
  setlength(points1, rect1.cx div fgridsizex + 1);
  for int1:= 0 to high(points1) do begin
   points1[int1].x:= po1.x;
   inc(po1.x,fgridsizex);
  end;
  while po1.y < endy do begin
   for int1:= 0 to high(points1) do begin
    points1[int1].y:= po1.y;
   end;
   canvas.drawpoints(points1,cl_black);
   inc(po1.y,fgridsizey);
  end;
 end;
end;

procedure tdesignwindow.clearselection;
begin
 fdesigner.noselection;
end;

procedure tdesignwindow.deletecomponent(const component: tcomponent);
begin
 fdesigner.selectcomponent(component);
 fdesigner.deleteselection(true);
 domodified;
 recalcclientsize;
end;

function tdesignwindow.form: twidget;
begin
 result:= tformdesignerfo(fowner).fform;
end;

function tdesignwindow.module: tmsecomponent;
begin
 result:= tformdesignerfo(fowner).fmodule;
end;

procedure tdesignwindow.selectcomponent(const component: tcomponent;
                       mode: selectmodety = sm_select);
begin
 if mode = sm_remove then begin
  fselections.remove(component);
 end
 else begin
  if mode = sm_select then begin
   fselections.clear;
  end;
  if fselections.indexof(component) < 0 then begin
   fselections.add(component);
  end
  else begin
   if mode = sm_flip then begin
    fselections.remove(component);
   end;
  end;
 end;
 updateselections;
end;

procedure tdesignwindow.setrootpos(const component: tcomponent;
  const apos: pointty);
begin
 setcomponentpos(component,apos);
end;

procedure tdesignwindow.updateselections;
begin
 if fselecting = 0 then begin
  case fselections.count of
   0: begin
    fdesigner.SelectComponent(nil);
   end;
   1: begin
    designer.SelectComponent(fselections[0]);
   end
   else begin
    fdesigner.SetSelections(idesignerselections(fselections));
   end;
  end;
 end;
end;

procedure tdesignwindow.beginselect;
begin
 inc(fselecting);
 fselections.beginupdate;
end;

procedure tdesignwindow.endselect;
begin
 dec(fselecting);
 fselections.endupdate;
 if fselecting = 0 then begin
  updateselections;
 end;
end;

procedure tdesignwindow.domodified;
begin
 fowner.invalidate;
 fdesigner.componentmodified(tformdesignerfo(fowner).fmodule);
end;

procedure tdesignwindow.methodcreated(const adesigner: idesigner;
  const amodule: tmsecomponent; const aname: string;
  const atype: ptypeinfo);
begin
 //dummy
end;

procedure tdesignwindow.methodnamechanged(const adesigner: idesigner;
  const amodule: tmsecomponent; const newname, oldname: string; 
                      const atypeinfo: ptypeinfo);
begin
 //dummy
end;

procedure tdesignwindow.showobjecttext(const adesigner: idesigner; 
              const afilename: filenamety; const backupcreated: boolean);
begin
 //dummy
end;

procedure tdesignwindow.closeobjecttext(const adesigner: idesigner; 
                           const afilename: filenamety; var cancel: boolean);
begin
 //dummy
end;

procedure tdesignwindow.moduleactivated(const adesigner: idesigner;
                      const amodule: tmsecomponent);
begin
 //dummy
end;

procedure tdesignwindow.moduledeactivated(const adesigner: idesigner; const amodule: tmsecomponent);
begin
 //dummy
end;

procedure tdesignwindow.checkdelobjs(const aitem: tcomponent);
var
 int1: integer;
begin
 for int1:= 0 to high(fdelobjs) do begin
  with fdelobjs[int1] do begin
   if (owner = aitem) or (parent = aitem) then begin
    owner:= nil;
    parent:= nil;
    objtext:= '';
   end;
  end;
 end;
end;

procedure tdesignwindow.moduledestroyed(const adesigner: idesigner;
  const amodule: tmsecomponent);
begin
 checkdelobjs(amodule);
end;

procedure tdesignwindow.ItemDeleted(const ADesigner: IDesigner;
            const amodule: tmsecomponent; const AItem: tcomponent);
begin
 fselections.remove(aitem);
 checkdelobjs(aitem);
end;

procedure tdesignwindow.ItemInserted(const ADesigner: IDesigner;
            const amodule: tmsecomponent; const AItem: tcomponent);
begin
 //dummy
end;

procedure tdesignwindow.ItemsModified(const ADesigner: IDesigner;
           const AItem: tobject);
begin
 fselections.externalcomponentchanged(aitem);
end;

procedure tdesignwindow.componentnamechanging(const adesigner: idesigner;
                     const amodule: tmsecomponent; const aitem: tcomponent;
                     const newname: string);
begin
 //dummy
end;

procedure tdesignwindow.moduleclassnamechanging(const adesigner: idesigner;
                    const amodule: tmsecomponent; const newname: string);
begin
 //dummy
end;

procedure tdesignwindow.instancevarnamechanging(const adesigner: idesigner;
                     const amodule: tmsecomponent; const newname: string);
begin
 //dummy
end;

procedure tdesignwindow.setshowgrid(const avalue: boolean);
begin
 if fshowgrid <> avalue then begin
  fshowgrid:= avalue;
  fowner.invalidate;
 end;
end;

procedure tdesignwindow.setgridsizex(const avalue: integer);
begin
 if fgridsizex <> avalue then begin
  fgridsizex:= avalue;
  fowner.invalidate;
 end;
end;

procedure tdesignwindow.setgridsizey(const avalue: integer);
begin
 if fgridsizey <> avalue then begin
  fgridsizey:= avalue;
  fowner.invalidate;
 end;
end;

procedure tdesignwindow.updateprojectoptions;
begin
 showgrid:= projectoptions.showgrid;
 snaptogrid:= projectoptions.snaptogrid;
 gridsizex:= projectoptions.gridsizex;
 gridsizey:= projectoptions.gridsizey;
end;

procedure tformdesignerfo.ValidateRename(AComponent: TComponent;
  const CurName, NewName: string);
begin
  inherited;
  if (acomponent <> nil) and not (csdestroying in acomponent.componentstate) then begin
   fdesigner.validaterename(acomponent,curname,newname);
  end;
end;

{ tformdesignerfo }

constructor tformdesignerfo.create(aowner: tcomponent; adesigner: tdesigner);
begin
 fdesigner:= adesigner;
// createwindow;
 inherited create(aowner);
end;

procedure tformdesignerfo.createwindow;
begin
 tdesignwindow.create(self,fdesigner)
end;

function tformdesignerfo.designnotification: idesignnotification;
begin
 result:= idesignnotification(tdesignwindow(fwindow));
end;

procedure tformdesignerfo.doafterpaint(const canvas: tcanvas);
begin
 inherited;
 tdesignwindow(fwindow).doafterpaint(canvas);
end;

procedure tformdesignerfo.dobeforepaint(const canvas: tcanvas);
begin
 inherited;
 tdesignwindow(fwindow).dobeforepaint(canvas);
end;

procedure tformdesignerfo.doactivate;
begin
 fdesigner.setactivemodule(self);
 inherited;
end;

procedure tformdesignerfo.widgetregionchanged(const sender: twidget);
begin
 inherited;
 if (fform <> nil) and (sender = fform) then begin
  size:= fform.size; //syc with modulesize
 end;
end;

procedure tformdesignerfo.doasyncevent(var atag: integer);
begin
 case designerfoeventty(atag) of
  fde_updatecaption: begin
   if fmodule <> nil then begin
    if fdesigner.modules.findmodule(fmodule)^.modified then begin
     caption:= '*'+fmodule.name;
    end
    else begin
     caption:= fmodule.name;
    end;
   end;
  end;
  fde_syncsize: begin
   if form <> nil then begin
    form.size:= size;
    size:= form.size;
   end
   else begin
    if module is tmsedatamodule then begin
     tmsedatamodule(module).size:= size; 
    end;
   end;
   tdesignwindow(window).domodified;
  end;
 end;
end;  

procedure tformdesignerfo.sizechanged;
begin
 inherited;
 if form <> nil then begin
  minsize:= form.minsize;
  maxsize:= form.maxsize;
 end;
 if not (ws_loadedproc in widgetstate) and (fmodulesetting = 0) then begin
  asyncevent(ord(fde_syncsize));
 end;
end;

procedure tformdesignerfo.updatecaption;
begin
 asyncevent(integer(fde_updatecaption));
end;

procedure tformdesignerfo.doshow;
begin
 inherited;
 updatecaption;
end;

procedure tformdesignerfo.setmodule(const Value: tmsecomponent);
var
 asize: sizety;
 po1: pointty;
 int1: integer;
begin
 inc(fmodulesetting);
 try
  fmodule := Value;
  InsertComponent(value);
  if value is twidget then begin
   widgetrect:= twidget(value).widgetrect;
   twidget(value).parentwidget:= self;
   twidget(value).pos:= nullpoint;
   fform:= twidget(value);
  end
  else begin
   fform:= nil;
   if value is tmsedatamodule then begin
    asize:= tmsedatamodule(value).size;
   end
   else begin
    asize:= nullsize;
    for int1:= 0 to value.ComponentCount - 1 do begin
     po1:= getcomponentpos(value.Components[int1]);
     if po1.x > asize.cx then begin
      asize.cx:= po1.x;
     end;
     if po1.y > asize.cy then begin
      asize.cy:= po1.y;
     end;
    end;
    inc(asize.cx,80);
    inc(asize.cy,30); //todo: correct size, scrollbox
   end;
   widgetrect:= makerect(getcomponentpos(value),asize);
  end;
 finally
  dec(fmodulesetting);
 end;
end;

procedure tformdesignerfo.doshowobjectinspector(const sender: tobject);
begin
 objectinspectorfo.activate;
end;

procedure tformdesignerfo.doshowcomponentpalette(const sender: tobject);
begin
 componentpalettefo.window.bringtofront;
 componentpalettefo.show;
end;

procedure tformdesignerfo.doshowastext(const sender: tobject);
begin
 fdesigner.showastext(fdesigner.modules.findmodule(fmodule));
end;

procedure tformdesignerfo.doeditcomponent(const sender: tobject);
begin
 designer.getcomponenteditor.edit;
end;

procedure tformdesignerfo.doinsertsubmodule(const sender: tobject);
var
 fo: tselectsubmoduledialogfo;
 comp: tmsecomponent;
 po1: pmoduleinfoty;
 ar1: msestringarty;
 mstr1: msestring;
 int1: integer;
begin
 fo:= tselectsubmoduledialogfo.create(nil);
 try
  ar1:= fdesigner.modules.filenames;
  mstr1:= fdesigner.modules.findmodulebyinstance(module)^.filename;
  for int1:= 0 to high(ar1) do begin
   if ar1[int1] = mstr1 then begin
    deleteitem(ar1,int1);
    break;
   end;
  end;
  fo.submodule.dropdown.cols[0].asarray:= ar1;
  if fo.show(true,window) = mr_ok then begin
   po1:= fdesigner.modules.findmodule(fo.submodule.value);
   if po1 <> nil then begin
    comp:= fdesigner.copycomponent(po1^.instance,nil);
    {$ifdef FPC}
    comp.setinline(true);
    comp.setancestor(true);
    {$else}
    tcomponent1(comp).setinline(true);
    tcomponent1(comp).setancestor(true);
    {$endif}
    comp.name:= po1^.instance.name;
    fdesigner.addancestorinfo(comp,po1^.instance);
    with tdesignwindow(window) do begin
     doaddcomponent(comp);
     placecomponent(comp,fmousepos);
    end;
   end;
  end;
 finally
  fo.Free;
 end;
end;

procedure tformdesignerfo.dobringtofront(const sender: tobject);
begin
 with tdesignwindow(window) do begin
  twidget(fselections[0]).bringtofront;
  domodified;
 end;
end;

procedure tformdesignerfo.dosendtoback(const sender: tobject);
begin
 with tdesignwindow(window) do begin
  twidget(fselections[0]).sendtoback;
  domodified;
 end;
end;

procedure tformdesignerfo.dosettaborder(const sender: tobject);
var
 fo: tsettaborderfo;
begin
 with tdesignwindow(window) do begin
  fo:= tsettaborderfo.create(twidget(fselections.items[0]),fdesigner);
  try
   fo.show(true,window);
  finally
   fo.Free;
  end;
 end;
end;

procedure tformdesignerfo.dosyncfontheight(const sender: tobject);
var
 int1: integer;
 comp1: tcomponent;
begin
 with tdesignwindow(window) do begin
  for int1:= 0 to fselections.count - 1 do begin
   comp1:= fselections[int1];
   if comp1 is twidget then begin
    twidget(comp1).synctofontheight;
    fdesigner.componentmodified(comp1);
   end;
  end;
 end;
end;

procedure tformdesignerfo.copyexe(const sender: TObject);
begin
 tdesignwindow(twidget(tmenuitem(sender).owner.owner).window).docopy(false);
end;

procedure tformdesignerfo.pasteexe(const sender: TObject);
begin
 tdesignwindow(twidget(tmenuitem(sender).owner.owner).window).dopaste;
end;

procedure tformdesignerfo.deleteexe(const sender: TObject);
begin
 tdesignwindow(twidget(tmenuitem(sender).owner.owner).window).dodelete;
end;

procedure tformdesignerfo.undeleteexe(const sender: TObject);
begin
 tdesignwindow(twidget(tmenuitem(sender).owner.owner).window).doundelete;
end;

procedure tformdesignerfo.cutexe(const sender: TObject);
begin
 tdesignwindow(twidget(tmenuitem(sender).owner.owner).window).docut;
end;

procedure tformdesignerfo.calcscrollsize(const sender: tscrollingwidget;
               var asize: sizety);
var
 size1: sizety;
begin
 size1:= tdesignwindow(window).componentscrollsize;
 if asize.cx < size1.cx then begin
  asize.cx:= size1.cx;
 end;
 if asize.cy < size1.cy then begin
  asize.cy:= size1.cy;
 end;
end;

procedure tformdesignerfo.formdeonclose(const sender: TObject);
var
 int1: integer;
begin
 with tdesignwindow(window),fselections do begin
  for int1:= count - 1 downto 0 do begin
   if (items[int1] = fmodule) or (items[int1].owner = fmodule) then begin
    delete(int1);
   end;
  end;
  updateselections;
 end;
end;

procedure tformdesignerfo.revertexe(const sender: TObject);
begin
 if askok('Do you wish to revert to inherited'+lineend+
          'the selected component?') then begin
  fdesigner.revert(tdesignwindow(window).fselections[0]);
 end;
end;

end.
