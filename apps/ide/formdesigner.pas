{ MSEide Copyright (c) 1999-2008 by Martin Schreiber
   
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

{$ifdef FPC}{$mode objfpc}{$h+}{$GOTO ON}{$interfaces corba}{$endif}

interface
uses
 classes,mseforms,msegui,mseevent,msegraphutils,msegraphics,msedesignintf,
 mseclasses,msemenuwidgets,msemenus,msefiledialog,msedesigner,typinfo,
 componentpaletteform,msestrings,msewidgets,mseglob
  {$ifdef FPC}{$ifndef mse_withoutdb},msereport{$endif}{$endif};

type
 areaty = (ar_none,ar_component,ar_componentmove,ar_selectrect,ht_topleft,
             ht_top,ht_topright,ht_right,
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
 movethreshold = 3;

type
 formselectedinfoty = record
  selectedinfo: selectedinfoty;
  rect: rectty;
  nohandles: boolean;
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
   fcandelete: boolean;
   procedure paint(const canvas: tcanvas);
   procedure beforepaintmoving;
   procedure paintmoving(const canvas: tcanvas; const pos: pointty);
   function move(const dist: pointty): boolean;
                  //false if nothing is moved
   procedure resize(const dist: pointty);
   procedure deletecomponents;
   function getareainfo(const pos: pointty; out index: integer): areaty;
   function getcandelete: boolean;
   procedure updateinfos;
  protected
   function getrecordsize: integer; override;
   procedure externalcomponentchanged(const acomponent: tobject);
   procedure removeforeign; //removes form and components in other modules
   property candelete: boolean read getcandelete;
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
   procedure doinsertcomponent(const sender: TObject);
   procedure dotouch(const sender: TObject);
   procedure dosetcreationorder(const sender: TObject);
  private
   fdesigner: tdesigner;
   fform: twidget;
   fmodule: tmsecomponent;
   fmoduleintf: pdesignmoduleintfty;
   fmodulesetting: integer;
   fformsizesetting: integer;
   procedure setmodule(const Value: tmsecomponent);
   function getselections: tformdesignerselections;
  protected
   property selections: tformdesignerselections read getselections;
   procedure formcontainerscrolled;
   procedure widgetregionchanged(const sender: twidget); override;
   procedure sizechanged; override;
   procedure doasyncevent(var atag: integer); override;
   procedure dobeforepaint(const canvas: tcanvas); override;
   procedure doafterpaint(const canvas: tcanvas); override;
   procedure createwindow; override;
   procedure doactivate; override;
   procedure validaterename(acomponent: tcomponent;
                                      const curname, newname: string); override;
   procedure notification(acomponent: tcomponent;
                                      operation: toperation); override;
   procedure doshow; override;

   procedure componentselected(const aselections: tformdesignerselections); virtual;
   function getmoduleparent: twidget; virtual;
   function insertoffset: pointty; virtual;
   function gridoffset: pointty; virtual;
   function gridrect: rectty; virtual;
   function widgetrefpoint: pointty; virtual;
   function compplacementrect: rectty; virtual;
   function gridsizex: integer; virtual;
   function gridsizey: integer; virtual;
   function showgrid: boolean; virtual;
   function snaptogrid: boolean; virtual;
   procedure recalcclientsize;
   procedure setcomponentscrollsize(const avalue: sizety); virtual;
   class function fixformsize: boolean; virtual;
   function getdesignrect: rectty; virtual;
   procedure setdesignrect(const arect: rectty); virtual;
   procedure deletecomponent(const comp: tcomponent);
   function candelete(const acomponent: tcomponent): boolean; virtual;
   procedure componentmoving(const apos: pointty); virtual;
   procedure placecomponent(const component: tcomponent; const apos: pointty;
                                 aparent: tcomponent = nil);
  public
   constructor create(const aowner: tcomponent; const adesigner: tdesigner;
                      const aintf: pdesignmoduleintfty); reintroduce; virtual;
                        
   destructor destroy; override;
   function designnotification: idesignnotification;
   property modulerect: rectty read fwidgetrect;
   procedure updatecaption;
   procedure placemodule;
   procedure beginplacement;
   procedure endplacement;
   procedure beginstreaming; virtual;
   procedure endstreaming; virtual;
   property module: tmsecomponent read fmodule write setmodule;
   property form: twidget read fform;
 end;

 designformclassty = class of tformdesignerfo;

 tdesignwindow = class(twindow,idesignnotification)
  private
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
   fgridsizex: integer;
   fgridsizey: integer;
   fsnaptogrid: boolean;
   fshowgrid: boolean;
   fdelobjs: objinfoarty;
   fclipinitcomps: boolean;
   finitcompsoffset: pointty;
   fuseinitcompsoffset: boolean;
   fcompsoffsetused: boolean;
   fclickedcompbefore: tcomponent;
   fselectwidget: twidget;
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
   procedure dopaste(const usemousepos: boolean);
   procedure docopy(const noclear: boolean);
   procedure docut;
   procedure recalcclientsize;
   procedure adjustchildcomponentpos(var apos: pointty);
   procedure readjustchildcomponentpos(var apos: pointty);
  protected
   function getcomponentrect(const component: tcomponent): rectty;
   function getcomponentrect1(const component: tcomponent): rectty;
   function componentatpos(const pos: pointty): tcomponent;
 
   procedure sizechanged; override;
   procedure poschanged; override;
   procedure dispatchmouseevent(var info: moeventinfoty; capture: twidget); override;
   procedure dispatchkeyevent(const eventkind: eventkindty; var info: keyeventinfoty); override;
   procedure dobeforepaint(const canvas: tcanvas);
   procedure doafterpaint(const canvas: tcanvas);
   procedure movewindowrect(const dist: pointty; const rect: rectty); override;
   function dosnaptogrid(const pos: pointty): pointty;
   function snaptogriddelta(const pos: pointty): pointty;
   function form: twidget;
   function module: tmsecomponent;
   function componentscrollsize: sizety;
   function componentoffset: pointty;

   procedure setrootpos(const component: tcomponent; const apos: pointty);
   procedure beginselect;
   procedure endselect;
   procedure updateselections;
   procedure deletecomponent(const component: tcomponent);
   procedure selectcomponent(const component: tcomponent; mode: selectmodety = sm_select);
   procedure clearselection;
   procedure domodified;

   procedure selectchildexec(const sender: tobject);
   procedure dopopup(var info: mouseeventinfoty);

   function widgetatpos(const apos: pointty; onlywidgets: boolean): twidget;

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
   procedure beforefilesave(const adesigner: idesigner;
                                    const afilename: filenamety);
   procedure beforemake(const adesigner: idesigner; const maketag: integer;
                         var abort: boolean);
   procedure aftermake(const adesigner: idesigner; const exitcode: integer);

  public
   constructor create(const aowner: tformdesignerfo; const adesigner: tdesigner);
   destructor destroy; override;
   procedure updateprojectoptions;
   property snaptogrid: boolean read fsnaptogrid write fsnaptogrid default true;
   property showgrid: boolean read fshowgrid write setshowgrid default true;
   property gridsizex: integer read fgridsizex write setgridsizex 
                                     default defaultgridsizex;
   property gridsizey: integer read fgridsizey write setgridsizey
                                     default defaultgridsizey;
 end;

procedure registerdesignmoduleclass(const aclass: tcomponentclass;
                               const aintf: designmoduleintfty;
                               const adesignformclass: designformclassty = nil);
function createdesignmodule(const amodule: pmoduleinfoty; designmoduleclassname: string;
                           const aclassname: pshortstring): tmsecomponent;
function createdesignform(const aowner: tdesigner; 
                 const amodule: pmoduleinfoty): tformdesignerfo;
function selectinheritedmodule(const amodule: pmoduleinfoty;
                               const caption: msestring = ''): pmoduleinfoty;

implementation
uses
 formdesigner_mfm,mselist,msekeyboard,mseguiglob,msepointer,msebits,sysutils,
 msestockobjects,msedrawtext,selectsubmoduledialogform,mseshapes,settaborderform,
 msedatalist,objectinspector,projectoptionsform,main,msedatamodules,msetypes,
 setcreateorderform,mseactions;

type
 tcomponent1 = class(tcomponent);
 twidget1 = class(twidget);
 tmseform1 = class(tmseform);
 tframe1 = class(tframe);
 tscrollingwidget1 = class(tscrollingwidget);

 designerfoeventty = (fde_none,fde_syncsize,fde_updatecaption,fde_scrolled,
                      fde_showastext);

 designmoduleinfoty = record
  classtype: tcomponentclass;
  intf: pdesignmoduleintfty;
  formclass: designformclassty;
 end;
 designmoduleinfoarty = array of designmoduleinfoty;

 tdesignmoduleinfoar = class
  private
   flist: designmoduleinfoarty;
 end;
 
var
 fregistereddesignmoduleclasses: tdesignmoduleinfoar;

function registereddesignmoduleclasses: tdesignmoduleinfoar;
begin
 if fregistereddesignmoduleclasses = nil then begin
  fregistereddesignmoduleclasses:= tdesignmoduleinfoar.create;
 end;
 result:= fregistereddesignmoduleclasses;
end;
 
procedure registerdesignmoduleclass(const aclass: tcomponentclass;
                               const aintf: designmoduleintfty;
                               const adesignformclass: designformclassty = nil);
var
 int1: integer;
begin
 with registereddesignmoduleclasses do begin
  for int1:= 0 to high(flist) do begin
   with flist[int1] do begin
    if classtype = aclass then begin
     intf:= @aintf;
     formclass:= adesignformclass;
     exit;
    end;
   end;
  end;
  registerclass(aclass);
  setlength(flist,high(flist)+2);
  with flist[high(flist)] do begin
   classtype:= aclass;
   intf:= @aintf;
   formclass:= adesignformclass;
  end;
 end;
end;

function createdesignmodule(const amodule: pmoduleinfoty; designmoduleclassname: string;
              const aclassname: pshortstring): tmsecomponent;
var
 int1: integer;
begin
 with amodule^ do begin
  if designmoduleclassname = '' then begin
   designmoduleclassname:= defaultmoduleclassname;
  end;
  designmoduleclassname:= uppercase(designmoduleclassname);
  with registereddesignmoduleclasses do begin
   for int1:= 0 to high(flist) do begin
    with flist[int1] do begin
     if uppercase(classtype.classname) = designmoduleclassname then begin
      designformclass:= formclass;
      moduleintf:= intf;
      result:= intf^.createfunc(classtype,aclassname);
      exit;
     end;
    end;
   end;
  end;
 end;
 raise exception.Create('Unknown moduleclass for "'+ aclassname^ +'": "'+
              designmoduleclassname+'".');
end;

function createdesignform(const aowner: tdesigner; 
                 const amodule: pmoduleinfoty): tformdesignerfo;
begin
 with amodule^ do begin
  if designformclass = nil then begin
   designformclass:= tformdesignerfo;
  end;
  result:= designformclassty(designformclass).create(nil,aowner,moduleintf);
  result.module:= instance;
 end;
end;
{
function getcomponentrect(const sender: twidget;
                                    const component: tcomponent): rectty;
begin
 result.pos:= getcomponentpos(component);
 addpoint1(result.pos,tdesignwindow(sender.window).componentoffset);
 result.cx:= componentsize + complabelleftmargin + 
                 sender.getcanvas.getstringwidth(component.name) +
                  complabelrightmargin;
 result.cy:= componentsize;
end;

function getcomponentrect1(const sender: twidget; const component: tcomponent;
                                     const module: tcomponent): rectty;
var
 comp1: tcomponent;
 bo1: boolean;
begin
 result:= getcomponentrect(sender,component);
 if module is twidget then begin
  comp1:= component;
  bo1:= false;
  while (comp1 <> module) and (comp1 <> nil) do begin
   if comp1 is twidget then begin
    if not bo1 then begin
     tdesignwindow(sender.window).adjustchildcomponentpos(result.pos);
     bo1:= true;
    end;
    addpoint1(result.pos,twidget(comp1).pos);
   end;
   comp1:= comp1.owner;
  end;
 end;
end;
}

function tdesignwindow.getcomponentrect(const component: tcomponent): rectty;
begin
 result.pos:= getcomponentpos(component);
 addpoint1(result.pos,componentoffset);
 result.cx:= componentsize + complabelleftmargin + 
                 fowner.getcanvas.getstringwidth(component.name) +
                  complabelrightmargin;
 result.cy:= componentsize;
end;

function tdesignwindow.getcomponentrect1(const component: tcomponent): rectty;
var
 comp1: tcomponent;
 bo1: boolean;
begin
 result:= getcomponentrect(component);
 if tformdesignerfo(fowner).fform <> nil then begin
  comp1:= component;
  bo1:= false;
  while (comp1 <> module) and (comp1 <> nil) do begin
   if comp1 is twidget then begin
    if not bo1 then begin
     adjustchildcomponentpos(result.pos);
     bo1:= true;
    end;
    addpoint1(result.pos,twidget(comp1).pos);
   end;
   comp1:= comp1.owner;
  end;
 end;
end;

function tdesignwindow.componentatpos(const pos: pointty): tcomponent;

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
  bo1:= (component is twidget) and not isdatamodule;
  if bo1 and not toplevel then begin
   po1:= subpoint(pos,twidget(component).pos);
   if (component.owner = module) and (module is twidget) then begin
    tdesignwindow(twidget(component).window).readjustchildcomponentpos(po1);
   end;
  end
  else begin
   po1:= pos;
  end;
  if toplevel or 
              not isdatamodule and bo1 and 
              not (cssubcomponent in component.componentstyle) and
              (component.componentstate * [csinline,csancestor] <> []) then begin
   toplevel:= false;
   for int1:= component.componentcount - 1 downto 0 do begin
    result:= checkcomponent(component.components[int1],po1);
    if result <> nil then begin
     exit;
    end;
   end;
  end;
  if not bo1 {or isdatamodule} then begin
   if pointinrect(pos,getcomponentrect(component)) then begin
    result:= component;
   end;
  end;
 end;
 
begin
 isdatamodule:= tformdesignerfo(fowner).fform = nil;
 toplevel:= true;
 result:= checkcomponent(tformdesignerfo(fowner).fmodule,pos);
 if result = tformdesignerfo(fowner).fmodule then begin
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
  fcandelete:= count > 0;
  for int1:= 0 to count - 1 do begin
   with itempo(int1)^,selectedinfo do begin
    if (instance is twidget) and (fowner.form <> nil) then begin
     with twidget1(instance) do begin
      nohandles:= ws1_nodesignhandles in fwidgetstate1;
      fcandelete:= fcandelete and not (ws1_nodesigndelete in fwidgetstate1);
      rect:= makerect(rootpos,size);
     end;
    end
    else begin
     nohandles:= false;
     if instance is tcomponent then begin
      rect:= fowner.getcomponentrect1(tcomponent(instance));
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
     if not nohandles and (instance <> fowner.module) and 
                            fowner.module.checkowned(instance) then begin
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
     if not nohandles and (instance <> fowner.module) and 
                               fowner.module.checkowned(instance) then begin
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
 rect1,rect2: rectty;
 pt1: pointty;
begin
 result:= false;
 if (dist.x <> 0) or (dist.y <> 0) then begin
  for int1:= 0 to count - 1 do begin
   with itempo(int1)^,selectedinfo do begin
    if (fowner.form <> nil) and (instance is twidget) and
                                    (instance <> fowner.module) then begin
     if not nohandles then begin
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
      rect1:= fowner.getcomponentrect1(tcomponent(instance));
      fowner.fowner.invalidaterect(rect1);
      pt1:= rect1.pos;
      addpoint1(rect1.pos,dist);
      with tformdesignerfo(fowner.fowner) do begin
       rect2:= compplacementrect;
       if form <> nil then begin      
        shiftinrect(rect1,rect2);
//        subpoint1(rect1.pos,rect2.pos);
       end
       else begin
        if rect1.x < rect2.x then begin
         rect1.x:= rect2.x;
        end;
        if rect1.y < rect2.y then begin
         rect1.y:= rect2.y;
        end;
       end;
      end;
      setcomponentpos(tcomponent(instance),
                addpoint(getcomponentpos(tcomponent(instance)),
                subpoint(rect1.pos,pt1)));
      fowner.fowner.invalidaterect(rect1);
{                                         
      setcomponentpos(tcomponent(instance),
             addpoint(getcomponentpos(tcomponent(instance)),dist));
      fowner.fowner.invalidaterect(getcomponentrect1(
                                         fowner.fowner,tcomponent(instance),
                                         fowner.module));
                                         }
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
      if not nohandles then begin
       size:= sizety(addpoint(pointty(size),dist));
      end;
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
 updateinfos;
 result:= ar_none;
 index:= -1;
 if count = 1 then begin
  with itempo(0)^,selectedinfo do begin
   if not nohandles then begin
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
  end;
 end
 else begin
  for int1:= 0 to count - 1 do begin
   with itempo(int1)^,selectedinfo do begin
    if not nohandles then begin
     if pointinrect(pos,rect) and (instance is tcomponent) then begin
      result:= ar_component;
      index:= int1;
      break;
     end;
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

function tformdesignerselections.getcandelete: boolean;
begin
 updateinfos;
 result:= fcandelete;
end;

{ tdesignwindow }

constructor tdesignwindow.create(const aowner: tformdesignerfo; 
                                   const adesigner: tdesigner);
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
//  canvas.intersectcliprect(fowner.container.paintrect);
  canvas.intersectcliprect(tformdesignerfo(fowner).gridrect);
//  canvas.move(fowner.container.clientpos);
  case factarea of
   firsthandle..lasthandle: begin
    with canvas do begin
     save;
     rasterop:= rop_xor;
     drawframe(factsizerect,-2,cl_white);
     restore;
    end;
   end;
   ar_componentmove: begin
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

procedure tdesignwindow.adjustchildcomponentpos(var apos: pointty);
begin
 subpoint1(apos,componentoffset);
 addpoint1(apos,tformdesignerfo(fowner).widgetrefpoint);
// addpoint1(apos,tformdesignerfo(fowner).insertoffset);
// addpoint1(apos,tformdesignerfo(fowner).gridrect.pos);
end;

procedure tdesignwindow.readjustchildcomponentpos(var apos: pointty);
begin
 addpoint1(apos,componentoffset);
 subpoint1(apos,tformdesignerfo(fowner).widgetrefpoint);
// subpoint1(apos,tformdesignerfo(fowner).insertoffset);
// subpoint1(apos,tformdesignerfo(fowner).gridrect.pos);
end;

procedure tdesignwindow.doafterpaint(const canvas: tcanvas);

 procedure drawcomponent(const component: tcomponent);
 var
  rect1: rectty;
  int1: integer;
  pt1: pointty;
 begin
  if ((form = nil) or not (component is twidget)) and 
           not (cssubcomponent in component.componentstyle) then begin
   rect1:= getcomponentrect(component);
   rect1.cx:= rect1.cx - complabelrightmargin;
   drawtext(canvas,component.name,rect1,[tf_ycentered,tf_right],
                      stockobjects.fonts[stf_default]);
   rect1.cx:= rect1.cy;
   registeredcomponents.drawcomponenticon(component,canvas,rect1);
  end;
  if (form <> nil) and (component is twidget) and 
                      not (cssubcomponent in component.componentstyle){ and 
                      (csinline in component.componentstate)} then begin
   pt1:= twidget(component).pos;
   if component.owner = tformdesignerfo(fowner).fmodule then begin
    adjustchildcomponentpos(pt1);
   end;
   canvas.move(pt1);
   for int1:= 0 to component.componentcount - 1 do begin
    drawcomponent(component.components[int1]);        //components of submodule
   end;
   canvas.remove(pt1);
  end;
 end;
 
var
 int1: integer;
 rect1: rectty;
begin
 if tformdesignerfo(fowner).fmodule <> nil then begin
  canvas.intersectcliprect(tformdesignerfo(fowner).gridrect);
//  canvas.move(fowner.container.clientpos);
//  canvas.move(tformdesignerfo(fowner).gridoffset);
  with tformdesignerfo(fowner).fmodule do begin
   for int1:= 0 to componentcount - 1 do begin
    drawcomponent(components[int1]);
   end;
  end;
//  canvas.remove(tformdesignerfo(fowner).gridoffset);
  if form <> nil then begin
   drawgrid(canvas);
  end;
  fselections.paint(canvas);
//  canvas.remove(fowner.container.clientpos);
  showxorpic(canvas);
 end;
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
    component:= components[int1];
    if (form = nil) or not (component is twidget) then begin
     rect1:= getcomponentrect(component);
     subpoint1(rect1.pos,componentoffset);
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
  subsize1(result,sizety(tformdesignerfo(fowner).gridrect.pos));
 end;
 inc(result.cx,handlesize);
 inc(result.cy,handlesize);
end;

procedure tdesignwindow.doaddcomponent(component: tcomponent);
var
 comp1: tcomponent;
begin
 comp1:= component.owner;
 if (comp1 <> nil) and not 
            issubcomponent(tformdesignerfo(fowner).fmodule,comp1) then begin
  comp1.removecomponent(component);
 end;
 fdesigner.addcomponent(module,component);
// if csinline in component.ComponentState then begin
 if component.ComponentState * [csancestor,csinline] <> [] then begin
  tcomponent1(component).getchildren({$ifdef FPC}@{$endif}doaddcomponent,component);
  if comp1 <> nil then begin
   tcomponent1(component).getchildren({$ifdef FPC}@{$endif}doaddcomponent,comp1);
  end;
 end
 else begin
// if comp1 <> nil then begin //else submodule
  tcomponent1(component).getchildren({$ifdef FPC}@{$endif}doaddcomponent,comp1);
 end;
end;

procedure tdesignwindow.doinitcomponent(component: tcomponent; parent: tcomponent);
var
 rect1: rectty;
 pt1: pointty;
begin
 doaddcomponent(component);
 if (component is twidget) and (parent is twidget) then begin
  with twidget(component) do begin
   if fuseinitcompsoffset then begin
    pt1:= finitcompsoffset;
    subpoint1(finitcompsoffset,pos);
    fcompsoffsetused:= true;
    fuseinitcompsoffset:= false;
   end
   else begin 
    if fcompsoffsetused then begin
     pt1:= addpoint(pos,finitcompsoffset);
    end
    else begin
     pt1:= addpoint(pos,twidget(parent).containeroffset);
    end;
   end;
  end;
  twidget(parent).insertwidget(twidget(component),pt1);
  if fclipinitcomps then begin
   rect1:= twidget(component).widgetrect;
//   if fuseinitcompsoffset then begin
//    addpoint1(rect1.pos,finitcompsoffset);
//   end;
   shiftinrect(rect1,twidget(component).parentwidget.clientwidgetrect);
//   shiftinrect(rect1,makerect(nullpoint,twidget(component).parentwidget.size));
   twidget(component).widgetrect:= rect1;
  end;
 end;
end;

procedure tdesignwindow.docopy(const noclear: boolean);
var
 int1: integer;
 widget1: twidget;
begin
 fselections.remove(module);
 fselections.copytoclipboard;
 if not noclear then begin
  if form = nil then begin
   selectcomponent(module);
  end
  else begin
   widget1:= nil;
   if (fselections.count > 0) and (fselections[0] is twidget) then begin
    widget1:= twidget(fselections[0]).parentofcontainer;
    for int1:= 1 to fselections.count - 1 do begin
     if not (fselections[int1] is twidget) or 
       (twidget(fselections[int1]).parentofcontainer <> widget1) then begin
      widget1:= nil; //no common parent
      break;
     end;
    end;
   end;
   if widget1 = nil then begin
    selectcomponent(module);
   end
   else begin
    selectcomponent(widget1);
   end;
  end;
 end;
end;

procedure tdesignwindow.docut;
begin
 docopy(true);
 dodelete;
end;

procedure tdesignwindow.dopaste(const usemousepos: boolean);
var
 widget1: twidget;
begin
 try
  if form <> nil then begin
   fclipinitcomps:= not usemousepos;
   with fselections do begin
    if count = 1 then begin
     widget1:= twidget(items[0]);
     if (widget1 is twidget) and form.checkdescendent(widget1) then begin
      fuseinitcompsoffset:= usemousepos;
      fcompsoffsetused:= false;
      if usemousepos then begin
       finitcompsoffset:= subpoint(dosnaptogrid(fmousepos),widget1.rootpos);
      end;
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
  for int1:= 0 to count - 1 do begin
   with items[int1] do begin
    if componentstate * [csancestor,csinline] = [csancestor] then begin
     showmessage('Inherited component "'+name+
                     '" can not be deleted.','ERROR');
     exit;
    end;             
   end;
  end;
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
 if module = nil then begin
  inherited;
  exit;
 end;
 if eventkind = ek_keypress then begin
  with info do begin
   if shiftstate * keyshiftstatesmask = [] then begin
    include(eventstate,es_processed);
    case key of
     key_escape: begin
      if factarea <> ar_none then begin
       hidexorpic(fowner.container.getcanvas(org_widget));
       fxorpicactive:= false;
       factarea:= ar_none;
      end
      else begin      
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
     end;
     key_delete: begin
      if fselections.candelete then begin
       dodelete;
      end;
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
       if fselections.count > 0 then begin
        fselections.updateinfos;
        tformdesignerfo(fowner).componentmoving(
             rectcenter(fselections.itempo(0)^.handles[ht_topleft]));
       end;
      end
      else begin
       fselections.resize(po1);
       if fselections.count > 0 then begin
        fselections.updateinfos;
        with fselections.itempo(0)^.handles[ht_bottomright] do begin
         tformdesignerfo(fowner).componentmoving(
                             makepoint(x+cx div 2 + 1,y+cy div 2 +1));
        end;
       end;
      end;
      fowner.invalidate;
      recalcclientsize;
     end;
    end;
   end;
   if not (es_processed in eventstate) then begin
    if issysshortcut(sho_copy,info) then begin
     docopy(false);
     include(eventstate,es_processed);
    end
    else begin
     if issysshortcut(sho_cut,info) then begin
      docut;
      include(eventstate,es_processed);
     end
     else begin
      if issysshortcut(sho_paste,info) then begin
       dopaste(false);
       include(eventstate,es_processed);
      end;
     end;
    end;
    (*
    if shiftstate = [ss_ctrl] then begin
     include(eventstate,es_processed);
     case key of
      key_c{,key_insert}: begin
       docopy(false);
      end;
      key_x: begin
       if fselections.candelete then begin
        docut;
       end;
      end;
      key_v: begin
       dopaste(false);
      end;
      else begin
       exclude(eventstate,es_processed);
      end;
     end;
    end;
    *)
   end;
  end;
 end;
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;

procedure tdesignwindow.selectchildexec(const sender: tobject);
var
 ar1: msestringarty;
begin
 with tmenuitem(sender) do begin
  ar1:= splitstring(caption,widechar(' '));
  fselections.clear;
  fselections.add(fselectwidget.findlogicalchild(ar1[0]));
 end;
end;

procedure tdesignwindow.dopopup(var info: mouseeventinfoty);

var
 bo1,bo2: boolean;
 item1: tmenuitem;
 ar1: msestringarty;
 ar2: widgetarty;
 int1: integer;
begin
 with tformdesignerfo(fowner),popupme,menu do begin
  bo1:= (fselections.count > 0) and (fselections[0] <> module);
  bo2:= bo1 and fselections.candelete;
  itembyname('copy').enabled:= bo1;
  itembyname('cut').enabled:= bo2;
  itembyname('delete').enabled:= bo2;
  itembyname('undelete').enabled:= fdelobjs <> nil;
  itembyname('paste').enabled:= true;
  itembyname('editcomp').enabled:= designer.componentcanedit;
  bo1:= not((fselections.count <> 1) or not(fselections.items[0] is twidget) or
           not fowner.checkdescendent(twidget(fselections.items[0])));
  itembyname('insertsub').enabled:= bo1;
  itembyname('revert').enabled:= (fselections.count = 1) and 
          (fselections[0].componentstate * [csinline,csancestor] <> []);
  itembyname('insertcomp').enabled:= designer.hascurrentcomponent and
           (fselections.count = 1);
  itembyname('bringtofro').enabled:= bo1;
  itembyname('sendtoba').enabled:= bo1;
  itembyname('settabord').enabled:= bo1 and 
          (twidget(fselections.items[0]).parentwidget.childrencount >= 2);
  itembyname('synctofo').enabled:= fselections.count > 0;
  item1:= itembyname('selectchild');
  item1.enabled:= (fselections.count = 1) and (fselections[0] is twidget) and
                   (twidget(fselections[0]).container.widgetcount > 0);  
  if item1.enabled then begin
   fselectwidget:= twidget(fselections[0]);
   ar2:= fselectwidget.getlogicalchildren;
   setlength(ar1,length(ar2));
   for int1:= 0 to high(ar1) do begin
    with ar2[int1] do begin
     ar1[int1]:= name + ' (' + classname+')';
    end;
   end;
   sortarray(ar1);
   item1.submenu.count:= length(ar1);
   for int1:= 0 to high(ar1) do begin
    with item1.submenu[int1] do begin
     caption:= ar1[int1];
     onexecute:= {$ifdef FPC}@{$endif}selectchildexec;
    end;
   end;
  end;
  show(fowner,info);
  item1.submenu.clear; 
 end;
end;

function tdesignwindow.widgetatpos(const apos: pointty; onlywidgets: boolean): twidget;
var
 widgetinfo: widgetatposinfoty;
begin
 result:= nil;
 if pointinrect(apos,tformdesignerfo(fowner).gridrect) then begin
  fillchar(widgetinfo,sizeof(widgetinfo),0);
  with widgetinfo do begin
   pos:= subpoint(apos,form.rootpos);
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
end;

procedure tdesignwindow.recalcclientsize;
begin
 tformdesignerfo(fowner).recalcclientsize;
end;

procedure tdesignwindow.dispatchmouseevent(var info: moeventinfoty;
                         capture: twidget);

 function griddelta: pointty;
 begin
  result:= snaptogriddelta(subpoint(info.mouse.pos,fpickpos));
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
    info.mouse.pos.x:= fpickpos.x;
   end;
   ht_left,ht_right: begin
    info.mouse.pos.y:= fpickpos.y;
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
  application.widgetcursorshape:= shape;
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
// clipo: pointty;
 isinpaintrect: boolean;
 ss1: shiftstatesty;
 po1: pformselectedinfoty;
 pt1: pointty; 
label
 1;
begin
 if module = nil then begin
  inherited;
  exit;
 end;
 if info.mouse.eventkind in [ek_mouseleave,ek_mouseenter] then begin
  fclickedcompbefore:= nil;
  exit;
 end;
 checkmousewidget(info.mouse,capture);
 with info.mouse do begin
  ss1:= shiftstate * shiftstatesmask;
  isinpaintrect:= pointinrect(pos,tformdesignerfo(fowner).gridrect);
//  clipo:= fowner.container.clientpos;
//  subpoint1(pos,clipo);
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
                (ss1 = [ss_left,ss_ctrl,ss_shift]) or
                (ss1 = [ss_left,ss_double]) then begin
     factarea:= fselections.getareainfo(pos,factcompindex);
     if factcompindex >= 0 then begin
      fsizerect:= fselections.itempo(factcompindex)^.rect;
      factsizerect:= fsizerect;
     end;
     if (factarea in [ar_component,ar_none]) and 
                                     not (ss_shift in ss1) then begin
      if isinpaintrect then begin
       component:= componentatpos(pos);
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
         if projectoptions.moveonfirstclick then begin
          factarea:= ar_component;
         end;
        end;
        if ss_double in shiftstate then begin
         designer.showobjectinspector;
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
    dopopup(info.mouse);
   end;
   if not (es_processed in eventstate) then begin
    area1:= fselections.getareainfo(pos,int1);
    if ((area1 < firsthandle) or (area1 > lasthandle)) and
       ((factarea < firsthandle) or (factarea > lasthandle)) and 
       not (fdesigner.hascurrentcomponent and (eventkind = ek_buttonpress) and 
       (button = mb_left) and (ss1 = [ss_left])) and 
       not ((area1 = ar_component) and 
           not(fselections[int1] is twidget)) and 
       (factarea <> ar_componentmove) then begin
//     addpoint1(pos,clipo);
     inherited;
//     subpoint1(pos,clipo);
    end;
    pos:= posbefore;
    if bo1 then begin
     if not (es_processed in eventstate) then begin
      if (capture = nil) or not 
             (ws1_designactive in twidget1(capture).fwidgetstate1) then begin
       fowner.capturemouse; //capture mouse
      end;
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
       tformdesignerfo(fowner).placecomponent(component,pos);
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
        if (component is twidget) and (form <> nil) then begin
         with twidget(component) do begin
          subpoint1(factsizerect.pos,parentwidget.rootpos);
          widgetrect:= factsizerect;
         end;
         fselections.componentschanged;
        end;
       end;
       fowner.invalidate;
      end;
      ar_componentmove: begin
       if fselections.move(griddelta) then begin
        fowner.invalidate; //redraw handles
        recalcclientsize;
       end;
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
          if (form = nil) or (not (component is twidget)) then begin
           if rectinrect(getcomponentrect1(component),rect1) then begin
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
        if distance(fpickpos,pos) > movethreshold then begin
         fxorpicoffset:= griddelta;
         factarea:= ar_componentmove;
        end
        else begin
         bo1:= false;
        end;
       end;
       ar_componentmove: begin
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
       if factarea <> ar_component then begin
        fselections.beforepaintmoving; //resets canvas
       end;
       showxorpic(fowner.container.getcanvas(org_widget));
      end;
     end;
    end;
   end;
  end;
1:
  if (eventkind in mouseposevents) and (fselections.count = 1) then begin
   fselections.updateinfos;
   po1:= fselections.itempo(0);
   if po1^.selectedinfo.instance <> tformdesignerfo(fowner).fmodule then begin
    bo1:= true;
    case factarea of
     ar_component: begin
      if (eventkind = ek_buttonpress) and (button = mb_left) then begin
       pt1:= rectcenter(po1^.handles[ht_topleft]);
      end
      else begin
       bo1:= false;
      end;
     end;
     ht_topleft: begin
      pt1:= factsizerect.pos;
     end;
     ht_left: begin
      with factsizerect do begin
       pt1.x:= x;
       pt1.y:= y + cy div 2;
      end;
     end;
     ht_bottomleft: begin
      with factsizerect do begin
       pt1.x:= x;
       pt1.y:= y + cy;
      end;
     end;
     ht_bottom: begin
      with factsizerect do begin
       pt1.x:= x + cx div 2;
       pt1.y:= y + cy ;
      end;
     end;
     ht_bottomright: begin
      with factsizerect do begin
       pt1.x:= x + cx;
       pt1.y:= y + cy;
      end;
     end;
     ht_right: begin
      with factsizerect do begin
       pt1.x:= x + cx;
       pt1.y:= y + cy div 2;
      end;
     end;
     ht_topright: begin
      with factsizerect do begin
       pt1.x:= x + cx;
       pt1.y:= y;
      end;
     end;
     ht_top: begin
      with factsizerect do begin
       pt1.x:= x + cx div 2;
       pt1.y:= y;
      end;
     end;
     ar_componentmove: begin
      pt1:= addpoint(rectcenter(po1^.handles[ht_topleft]),fxorpicoffset);
     end;
     else begin
      bo1:= false;
     end;
    end;
    if bo1 then begin
     tformdesignerfo(fowner).componentmoving(pt1);
    end;
   end;
  end;
//  addpoint1(pos,clipo);
 end;
end;

procedure tdesignwindow.selectionchanged(const adesigner: idesigner;
      const aselection: idesignerselections);
begin
 if fselections.assign(aselection) then begin
  tformdesignerfo(fowner).componentselected(fselections);
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
 if tformdesignerfo(fowner).fmodulesetting = 0 then begin
  doModified;
 end;
end;
{
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
}
function tdesignwindow.snaptogriddelta(const pos: pointty): pointty;
begin
 if tformdesignerfo(fowner).snaptogrid then begin
  result.x:= roundint(pos.x,tformdesignerfo(fowner).gridsizex);
  result.y:= roundint(pos.y,tformdesignerfo(fowner).gridsizey);
 end
 else begin
  result:= pos;
 end;
end;

function tdesignwindow.dosnaptogrid(const pos: pointty): pointty;
begin
 if tformdesignerfo(fowner).snaptogrid then begin
  result:= snaptogriddelta(subpoint(pos,tformdesignerfo(fowner).gridoffset));
  addpoint1(result,tformdesignerfo(fowner).gridoffset);
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
 int1,gridcx,gridcy: integer;
begin
 if tformdesignerfo(fowner).showgrid then begin
  rect2:= tformdesignerfo(fowner).gridrect;
  msegraphutils.intersectrect(canvas.clipbox,rect2,rect1);
  offset:= tformdesignerfo(fowner).gridoffset;
  with tformdesignerfo(fowner) do begin
   gridcx:= gridsizex;
   gridcy:= gridsizey;
  end;
  with rect1 do begin
   po1.x:= ((x - offset.x) div gridcx) * gridcx + offset.x;
   po1.y:= ((y - offset.y) div gridcy) * gridcy + offset.y;
   endy:= y + cy;
  end;
  setlength(points1, rect1.cx div gridcx + 1);
  for int1:= 0 to high(points1) do begin
   points1[int1].x:= po1.x;
   inc(po1.x,gridcx);
  end;
  while po1.y < endy do begin
   for int1:= 0 to high(points1) do begin
    points1[int1].y:= po1.y;
   end;
   canvas.drawpoints(points1,cl_black);
   inc(po1.y,gridcy);
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
 fowner.invalidate;
end;

procedure tdesignwindow.beforemake(const adesigner: idesigner;
               const maketag: integer; var abort: boolean);
begin
 //dummy
end;

procedure tdesignwindow.aftermake(const adesigner: idesigner;
                                   const exitcode: integer);
begin
 //dummy
end;

procedure tdesignwindow.beforefilesave(const adesigner: idesigner;
               const afilename: filenamety);
begin
 //dummy
end;

function tdesignwindow.componentoffset: pointty;
begin
// result:= tformdesignerfo(fowner).gridrect.pos;
 with tformdesignerfo(fowner) do begin
  result:= gridoffset;
 end;
end;

{ tformdesignerfo }

constructor tformdesignerfo.create(const aowner: tcomponent; 
                                   const adesigner: tdesigner;
                                   const aintf: pdesignmoduleintfty);
begin
 fdesigner:= adesigner;
 fmoduleintf:= aintf;
// createwindow;
 inherited create(aowner);
end;

destructor tformdesignerfo.destroy;
begin
 designer.modules.designformdestroyed(self);
 fmodule.free;
 inherited;
end;

procedure tformdesignerfo.ValidateRename(AComponent: TComponent;
  const CurName, NewName: string);
begin
  inherited;
  if (fdesigner <> nil) and (acomponent <> nil) and 
                  not (csdestroying in acomponent.componentstate) then begin
   fdesigner.validaterename(acomponent,curname,newname);
  end;
end;

procedure tformdesignerfo.notification(acomponent: tcomponent;
                                      operation: toperation); 
begin
 if (operation = opremove) and (acomponent = fmodule) then begin
  fmodule:= nil;
 end;
 inherited;
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
 if (fform <> nil) and (sender = fform) and 
        not(ws1_anchorsizing in fform.widgetstate1) and 
        not (csdestroying in fform.componentstate) and
        not (csdestroying in componentstate) then begin
  size:= fform.size; //syc with modulesize
 end;
end;

class function tformdesignerfo.fixformsize: boolean;
begin
 result:= false;
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
   if not fixformsize then begin
    if form <> nil then begin
     form.widgetrect:= makerect(nullpoint,size);
//     form.size:= size;
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
  fde_scrolled: begin
   tdesignwindow(window).fselections.change;
  end;
  fde_showastext: begin
   fdesigner.showastext(fdesigner.modules.findmodule(fmodule));
  end;
 end;
end;  

procedure tformdesignerfo.formcontainerscrolled;
begin
 asyncevent(ord(fde_scrolled));
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

procedure tformdesignerfo.beginplacement;
begin
 inc(fmodulesetting);
end;

procedure tformdesignerfo.endplacement;
begin
 dec(fmodulesetting);
end;

function tformdesignerfo.getdesignrect: rectty;
begin
 result:= twidget(fmodule).widgetrect;
end;

procedure tformdesignerfo.setdesignrect(const arect: rectty);
begin
end;

procedure tformdesignerfo.placemodule;
var
 asize: sizety;
 po1: pointty;
 int1: integer;
begin
 beginplacement;
 try
  if fmodule is twidget then begin
   fform:= twidget(fmodule);
   widgetrect:= getdesignrect;
   twidget(fmodule).parentwidget:= getmoduleparent;
   twidget(fmodule).pos:= nullpoint;
  end
  else begin
   fform:= nil;
   if fmodule is tmsedatamodule then begin
    asize:= tmsedatamodule(fmodule).size;
   end
   else begin
    asize:= nullsize;
    for int1:= 0 to fmodule.ComponentCount - 1 do begin
     po1:= getcomponentpos(fmodule.Components[int1]);
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
   widgetrect:= makerect(getcomponentpos(fmodule),asize);
  end;
 finally
  endplacement;
 end;
end;

procedure tformdesignerfo.setmodule(const Value: tmsecomponent);
begin
 if fmodule <> value then begin
  fmodule.free;
  fmodule:= Value;
  if fmodule <> nil then begin
   fmodule.freenotification(self);
//   insertcomponent(value);
   placemodule;
  end;
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
 asyncevent(ord(fde_showastext));
end;

procedure tformdesignerfo.doeditcomponent(const sender: tobject);
begin
 designer.getcomponenteditor.edit;
end;

function selectinheritedmodule(const amodule: pmoduleinfoty;
                          const caption: msestring = ''): pmoduleinfoty;
var
 fo: tselectsubmoduledialogfo;
 ar1: msestringarty;
 int1: integer;
 ar2: componentarty;
begin
 result:= nil;
 fo:= tselectsubmoduledialogfo.create(nil);
 try
  if caption <> '' then begin
   fo.caption:= caption;
  end;
  if amodule <> nil then begin
   ar2:= designer.descendentinstancelist.getancestors(amodule^.instance);
   additem(pointerarty(ar2),amodule^.instance);
  end
  else begin
   ar2:= nil;
  end;
  ar1:= nil;
  with designer.modules do begin
   for int1:= 0 to count - 1 do begin
    with itempo[int1]^ do begin
     if finditem(pointerarty(ar2),instance) < 0 then begin
      additem(ar1,filename);
     end;
    end;
   end;
  end;
  fo.submodule.dropdown.cols[0].asarray:= ar1;
  if fo.show(true) = mr_ok then begin
   result:= designer.modules.findmodule(fo.submodule.value);
  end;
 finally
  fo.Free;
 end;
end;

procedure tformdesignerfo.placecomponent(const component: tcomponent;
                        const apos: pointty; aparent: tcomponent = nil);
var
// widget1: twidget;
 po1: pointty;
 rea1: real;
 str1,str2: string;
 int1,int2: integer;
 ar1: componentarty;
 bo1: boolean;
 comp1: tcomponent;
begin
 with tdesignwindow(window) do begin
  try
   rea1:= 1.0;
   if component is tmsecomponent then begin
    with tformdesignerfo(fowner).fmoduleintf^ do begin
     if assigned(getscale) then begin
      rea1:= getscale(module);
     end;
    end;
    tmsecomponent(component).initnewcomponent(rea1);
   end;
   if (component is twidget) and (form <> nil) then begin
    if (aparent = nil) or not (aparent is twidget) then begin
     aparent:= widgetatpos(apos,true);
    end;
    if aparent <> nil then begin
     comp1:= aparent.findcomponent(component.name);
     if (comp1 <> nil) and (comp1 <> component) then begin
      str1:= component.name;
      int1:= length(str1);
      while (int1 > 1) and (str1[int1] >= '0') and (str1[int1] <= '9') do begin
       dec(int1);
      end;
      setlength(str1,int1);     //remove trailing nums
      int1:= 1;
      ar1:= designer.descendentinstancelist.getdescendents(fmodule);
      additem(pointerarty(ar1),module);
      additem(pointerarty(ar1),aparent);
      str2:= str1+'1';
      repeat
       bo1:= true;
       for int2:= 0 to high(ar1) do begin
        if ar1[int2].findcomponent(str2) <> nil then begin
         inc(int1);
         str2:= str1 + inttostr(int1);
         bo1:= false;
         break;
        end;
       end;
      until bo1;
      component.name:= str2;
     end;
     po1:= subpoint(dosnaptogrid(apos),form.rootpos);
     twidget(aparent).insertwidget(twidget(component),
             translatewidgetpoint(po1,form,twidget(aparent)));
     twidget(component).initnewwidget(rea1);
    end;
   end
   else begin
    setrootpos(component,subpoint(dosnaptogrid(apos),insertoffset));
   end;
   tcomponent1(component).loaded;
   domodified;
  except
   deletecomponent(component);
   raise;
  end;
  selectcomponent(component);
  recalcclientsize;
 end;
end;

procedure tformdesignerfo.doinsertsubmodule(const sender: tobject);
var
 comp: tmsecomponent;
 po1: pmoduleinfoty;
begin
 po1:= selectinheritedmodule(fdesigner.modules.findmodulebyinstance(module));
 if po1 <> nil then begin
  comp:= fdesigner.copycomponent(po1^.instance,po1^.instance);
  initinline(comp);
//  checkinline(comp);
  comp.name:= po1^.instance.name;
  fdesigner.addancestorinfo(comp,po1^.instance);
  with tdesignwindow(window) do begin
   doaddcomponent(comp);
   placecomponent(comp,fmousepos,fselections[0]);
  end;
 end;
end;

procedure tformdesignerfo.doinsertcomponent(const sender: TObject);
var
 comp1: tcomponent;
begin
 comp1:= fdesigner.createcurrentcomponent(module);
 with tdesignwindow(window) do begin
  placecomponent(comp1,fmousepos,fselections[0]);
 end;  
end;

procedure tformdesignerfo.dotouch(const sender: TObject);
begin
 tdesignwindow(window).domodified;
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

procedure tformdesignerfo.dosetcreationorder(const sender: TObject);
var
 fo: tsetcreateorderfo;
 str1: string;
begin
 with tdesignwindow(window) do begin
  if (fselections.count = 1) and (selections[0].owner = module) then begin
   str1:= fselections[0].name;
  end
  else begin
   str1:= '';
  end;
 end;
 fo:= tsetcreateorderfo.create(module,str1);
 try
  fo.show(true,window);
 finally
  fo.free;
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
 tdesignwindow(twidget(tmenuitem(sender).owner.owner).window).dopaste(true);
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

procedure tformdesignerfo.setcomponentscrollsize(const avalue: sizety);
begin
 if fform is tcustommseform then begin
  with tscrollingwidget1(tcustommseform(fform).container) do begin
   fminminclientsize:= avalue;
   clientsize:= clientsize;
  end;
 end;
end;

procedure tformdesignerfo.calcscrollsize(const sender: tscrollingwidget;
               var asize: sizety);
var
 size1: sizety;
begin
 size1:= tdesignwindow(window).componentscrollsize;
 setcomponentscrollsize(size1);
 if asize.cx < size1.cx then begin
  asize.cx:= size1.cx;
 end;
 if asize.cy < size1.cy then begin
  asize.cy:= size1.cy;
 end;
end;

procedure tformdesignerfo.recalcclientsize;
begin
 if fform = nil then begin
  with twidget1(container) do begin
   exclude(fwidgetstate,ws_minclientsizevalid);
   tframe1(frame).updatestate;
  end;
 end
 else begin
  setcomponentscrollsize(tdesignwindow(window).componentscrollsize);
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

function tformdesignerfo.insertoffset: pointty;
begin
 if form = nil then begin
  result:= container.clientpos;
 end
 else begin
  result:= translateclientpoint(nullpoint,form.container,form);
  addpoint1(result,form.paintpos);
 end;
end;

function tformdesignerfo.gridoffset: pointty;
begin
 result:= insertoffset;
end;

function tformdesignerfo.gridrect: rectty;
begin
 if form = nil then begin
  result:= container.paintrect;
 end
 else begin
  result:= form.container.paintrect;
  addpoint1(result.pos,form.container.rootpos);
 end;
end;

function tformdesignerfo.widgetrefpoint: pointty;
begin
 if form = nil then begin
  result:= nullpoint;
 end
 else begin
  result:= form.container.rootpos;
 end;
end;

function tformdesignerfo.compplacementrect: rectty;
begin
 if form = nil then begin
  result:= container.clientrect;
 end
 else begin
  result:= form.container.clientwidgetrect;
  addpoint1(result.pos,form.container.rootpos);
 end;
end;

function tformdesignerfo.getmoduleparent: twidget;
begin
 result:= self;
 fscrollbox.visible:= false;
end;

procedure tformdesignerfo.componentselected(const aselections: tformdesignerselections);
begin
 //dummy
end;

procedure tformdesignerfo.beginstreaming;
begin
 if fmodule is twidget then begin
  twidget1(fmodule).fwidgetrect.pos:= modulerect.pos;
 end
 else begin
  setcomponentpos(fmodule,modulerect.pos);
 end;
 if fform is tcustommseform then begin
  tcustommseform(fform).container.scrollpos:= nullpoint;
 end;
end;

procedure tformdesignerfo.endstreaming;
begin
 if fmodule is twidget then begin
  with twidget1(fmodule) do begin
   fwidgetrect.pos:= nullpoint;
   rootchanged;
  end;
 end;
end;

function tformdesignerfo.candelete(const acomponent: tcomponent): boolean;
begin
 result:= true;
end;

function tformdesignerfo.gridsizex: integer;
begin
 result:= tdesignwindow(window).fgridsizex;
end;

function tformdesignerfo.gridsizey: integer;
begin
 result:= tdesignwindow(window).fgridsizey;
end;

function tformdesignerfo.showgrid: boolean;
begin
 result:= tdesignwindow(window).fshowgrid;
end;

function tformdesignerfo.snaptogrid: boolean;
begin
 result:= tdesignwindow(window).fsnaptogrid;
end;

procedure tformdesignerfo.componentmoving(const apos: pointty);
begin
 //dummy
end;

function tformdesignerfo.getselections: tformdesignerselections;
begin
 result:= tdesignwindow(fwindow).fselections;
end;

procedure tformdesignerfo.deletecomponent(const comp: tcomponent);
begin
 with tdesignwindow(fwindow) do begin
  fselections.clear;
  fselections.add(comp);
  dodelete;
 end;
end;

initialization
finalization
 freeandnil(fregistereddesignmoduleclasses);
end.
