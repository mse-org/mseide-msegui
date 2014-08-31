{ MSEide Copyright (c) 1999-2013 by Martin Schreiber
   
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
 classes,mclasses,mseforms,mseguiglob,msegui,mseevent,msegraphutils,msegraphics,
 msedesignintf,mseclasses,msemenuwidgets,msemenus,msefiledialog,msedesigner,
 typinfo,componentpaletteform,msestrings,msewidgets,
 mseglob{$ifndef mse_no_db}{$ifdef FPC},msereport{$endif}{$endif},msetimer,
 mseact,mseactions,mseifiglob,msestringcontainer,mseificomp,mseificompglob,
 msesimplewidgets,msestat,msedock;

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

 tformdesignerfo = class;

 tformdesignerselections = class(tdesignerselections)
  private
   fowner: tformdesignerfo;
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
   constructor create(const owner: tformdesignerfo);
   function assign(const source: idesignerselections): boolean;
              //true if owned components involved
   function remove(const ainstance: tcomponent): integer; override;
   procedure change; override;
   procedure dochanged; override;
   procedure componentschanged;
   function itempo(const index: integer): pformselectedinfoty;
 end;
 
 selectmodety = (sm_select,sm_add,sm_flip,sm_remove);

 tformcontainer = class(tformscrollbox)
  private
   fdesignfo: tformdesignerfo;
  protected
   function isdesignwidget(): boolean; override;
   procedure widgetregionchanged(const sender: twidget); override;
  public
   constructor create(const aowner: tformdesignerfo);
 end;

 formdesignerstatety = (fds_loaded,fds_sizesyncing);
 formdesignerstatesty = set of formdesignerstatety;
  
 tformdesignerfo = class(tdockform,iformdesigner,idesignnotification)
   popupme: tpopupmenu;
   hidecompact: taction;
   hidewidgetact: taction;
   togglehideact: taction;
   showallact: taction;
   c: tstringcontainer;
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
   procedure calcscrollsize(const sender: tscrollingwidgetnwr; var asize: sizety);
   procedure formdeonclose(const sender: TObject);
   procedure revertexe(const sender: TObject);
   procedure doinsertcomponent(const sender: TObject);
   procedure dotouch(const sender: TObject);
   procedure dosetcreationorder(const sender: TObject);
   procedure doiconify(const sender: TObject);
   procedure dodeiconify(const sender: TObject);
   procedure hidecompexe(const sender: TObject);
   procedure updatewidgethideexe(const sender: tcustomaction); virtual;
   procedure hidewidgetexe(const sender: TObject);
   procedure togglehideexe(const sender: TObject);
   procedure showallexe(const sender: TObject);
   procedure touchallexe(const sender: TObject);
   procedure beffloatexe(const sender: twidget; var arect: rectty);
   procedure floatexe(const sender: TObject);
  private
   fdesigner: tdesigner;
   fform: twidget;
   fmodule: tmsecomponent;
   fmoduleintf: pdesignmoduleintfty;
   fmodulesetting: integer;
   fformcont: tformcontainer;
   fmoduleoptions: moduleoptionsty;
   fsizeerrorcount: integer;
   fmodulepos: pointty;


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
   fselectcomp: tcomponent;
   fclientsizevalid: boolean;
   fcompoffsbefore: pointty;
   procedure drawgrid(const canvas: tcanvas);
   procedure hidexorpic(const canvas: tcanvas);
   procedure showxorpic(const canvas: tcanvas);
   procedure paintxorpic(const canvas: tcanvas);
   procedure checkdelobjs(const aitem: tcomponent);

   procedure doaddcomponent(acomponent: tcomponent);
   procedure doinitcomponent(const acomponent: tcomponent;
                                            const parent: tcomponent);

   procedure setshowgrid(const avalue: boolean);
   procedure setgridsizex(const avalue: integer);
   procedure setgridsizey(const avalue: integer);
   procedure doundelete;
   procedure dodelete;
   procedure dopaste(const usemousepos: boolean; const adata: string);
   procedure docopy(const noclear: boolean);
   procedure docut;
   procedure clientsizechanged;
   procedure adjustchildcomponentpos(var apos: pointty);
   procedure readjustchildcomponentpos(var apos: pointty);


   procedure setmodule(const value: tmsecomponent);
   function getselections: tformdesignerselections;
   function filterfindcomp(const acomponent: tcomponent): boolean;
   function getmodulesize: sizety;
   function getmodulerect: rectty;
  protected
   ffostate: formdesignerstatesty;
   fmoduleinfo: pmoduleinfoty;
    //iformdesigner
   function getmodulepos_x(): integer;
   function getmodulepos_y(): integer;
   procedure setmodulepos_x(const avalue: integer);
   procedure setmodulepos_y(const avalue: integer);
   function getdockcontroller(): tdockcontroller;
   function isdesignwidget(): boolean; override;
 
   function getsnaptogrid: boolean; virtual;
   function getshowgrid: boolean; virtual;
   function getgridsizex: integer; virtual;
   function getgridsizey: integer; virtual;
 
   procedure designmouseevent(var info: moeventinfoty;
                                             capture: twidget); override;
   procedure designkeyevent(const eventkind: eventkindty;
                                          var info: keyeventinfoty); override;

   function getcomponentrect(const component: tcomponent; 
                            const shiftoffset: boolean): rectty;
                                         //embedded

   procedure movewindowrect(const dist: pointty; const rect: rectty);
                                 //todo!
   function dosnaptogrid(const apos: pointty): pointty;
   function snaptogriddelta(const apos: pointty): pointty;

   function iswidgetcomp(const acomp: tcomponent): boolean;
   function getcomponentrect1(const component: tcomponent): rectty;
                                         //top level
   function componentscrollsize: sizety;
   function componentoffset(): pointty;
   function componentatpos(const apos: pointty): tcomponent;
   function widgetatpos(const apos: pointty; onlywidgets: boolean): twidget;
   procedure updateselections;

   procedure setrootpos(const component: tcomponent; const apos: pointty);
   procedure beginselect;
   procedure endselect;
//   procedure updateselections;
   procedure updateclickedcomponent;
   procedure deletecomponent(const component: tcomponent);
   procedure selectcomponent(const component: tcomponent;
                                             mode: selectmodety = sm_select);
                                  //component can be nil
   procedure selectparentwidget(const awidget: twidget);
   procedure clearselection;
   procedure domodified;

   procedure selectchildexec(const sender: tobject);
   procedure dopopup(var info: mouseeventinfoty); reintroduce;

   property selections: tformdesignerselections read getselections;
   procedure formcontainerscrolled();
   procedure updatedockinfo();
   procedure updateformcont();
   procedure checksynctoformsize();
   procedure checksynctomodulepos();
   procedure formcontainerwidgetregionchanged(const sender: twidget);
   procedure parentchanged(); override;
   procedure poschanged; override;
   procedure sizechanged; override;
   procedure clientrectchanged(); override;
   procedure doasyncevent(var atag: integer); override;
   procedure dobeforepaint(const canvas: tcanvas); override;
   procedure doafterpaint(const canvas: tcanvas); override;
//   procedure createwindow; override;
   procedure doactivate; override;
   procedure validaterename(acomponent: tcomponent;
                                      const curname, newname: string); override;
   procedure notification(acomponent: tcomponent;
                                      operation: toperation); override;
   procedure doshow; override;

   procedure componentselected(
                       const aselections: tformdesignerselections); virtual;
   function getmoduleparent: twidget; virtual;
   function insertoffset: pointty; virtual;
   function gridoffset: pointty; virtual;
   function gridrect: rectty; virtual;
   function widgetrefpoint: pointty; virtual;
   function compplacementrect: rectty; virtual;
//   function gridsizex: integer; virtual;
//   function gridsizey: integer; virtual;
//   function showgrid: boolean; virtual;
//   function snaptogrid: boolean; virtual;
   procedure recalcclientsize;
   procedure setcomponentscrollsize(const avalue: sizety); virtual;
   function fixformsize: boolean; virtual;
   function getdesignrect: rectty; virtual;
   procedure setdesignrect(const arect: rectty); virtual;
//   procedure deletecomponent(const comp: tcomponent);
   function candelete(const acomponent: tcomponent): boolean; virtual;
   procedure componentmoving(const apos: pointty); virtual;
   procedure placecomponent(const component: tcomponent; const apos: pointty;
                                 aparent: tcomponent = nil);
   function getmoduleoptions: moduleoptionsty;
   procedure setmoduleoptions(const aoptions: moduleoptionsty); virtual;

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
   procedure moduleactivated(const adesigner: idesigner;
                                           const amodule: tmsecomponent);
   procedure moduledeactivated(const adesigner: idesigner; 
                   const amodule: tmsecomponent);
   procedure moduledestroyed(const adesigner: idesigner;
                                           const amodule: tmsecomponent);
   procedure methodcreated(const adesigner: idesigner;
                          const amodule: tmsecomponent;
                          const aname: string; const atype: ptypeinfo);
   procedure methodnamechanged(const adesigner: idesigner;
                          const amodule: tmsecomponent;
                          const newname,oldname: string;
                          const atypeinfo: ptypeinfo);
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
   constructor create(const aowner: tcomponent; const adesigner: tdesigner;
                      const aintf: pdesignmoduleintfty;
                      const amoduleinfo: pmoduleinfoty); reintroduce; virtual;
                        
   destructor destroy(); override;
   procedure updateprojectoptions();

   function designnotification: idesignnotification;
    //idesignform
   property moduleoptions: moduleoptionsty read getmoduleoptions 
                                                   write setmoduleoptions;
   function clickedcomponent: tcomponent;
   property modulerect: rectty read getmodulerect;
   procedure updatecaption;
   procedure placemodule;
   procedure beginplacement;
   procedure endplacement;
   procedure beginstreaming; virtual;
   procedure endstreaming; virtual;
   procedure findcompdialog();

   property module: tmsecomponent read fmodule write setmodule;
   property form: twidget read fform;

   property snaptogrid: boolean read getsnaptogrid write
                                             fsnaptogrid default true;
   property showgrid: boolean read getshowgrid write setshowgrid default true;
   property gridsizex: integer read getgridsizex write setgridsizex 
                                     default defaultgridsizex;
   property gridsizey: integer read getgridsizey write setgridsizey
                                     default defaultgridsizey;
 end;

 designformclassty = class of tformdesignerfo;
{
 tdesignwindow = class(twindow)
  private
  protected
//   procedure dispatchmouseevent(var info: moeventinfoty;
//                                            capture: twidget); override;
//   procedure dispatchkeyevent(const eventkind: eventkindty;
//                                            var info: keyeventinfoty); override;

  public
   constructor create(const aowner: tformdesignerfo;
                                     const adesigner: tdesigner);
   destructor destroy; override;
 end;
}
procedure registerdesignmoduleclass(const aclass: tcomponentclass;
                               const aintf: pdesignmoduleintfty;
                               const adesignformclass: designformclassty = nil);
function createdesignmodule(const amodule: pmoduleinfoty; designmoduleclassname: string;
                           const aclassname: pshortstring): tmsecomponent;
function createdesignform(const aowner: tdesigner; 
                 const amodule: pmoduleinfoty): tformdesignerfo;
function selectinheritedmodule(const amodule: pmoduleinfoty;
                               const caption: msestring = ''): pmoduleinfoty;

implementation
uses
 formdesigner_mfm,mselist,msekeyboard,msepointer,msebits,sysutils,
 msestockobjects,msedrawtext,selectsubmoduledialogform,mseshapes,settaborderform,
 msedatalist,objectinspector,projectoptionsform,main,msedatamodules,msetypes,
 setcreateorderform,componentstore,msearrayutils,actionsmodule,msecomptree
 {$ifndef FPC},classes_del{$endif};

type
 stringconsts = (
  sc_wishrevert,        //0 Do you wish to revert to inherited
  sc_selectedcomp,      //1 the selected component?
  sc_touchall           //2 Do you want to touch all loaded forms?  
 );
 
 tcomponent1 = class(tcomponent);
 tmsecomponent1 = class(tmsecomponent);
 twidget1 = class(twidget);
 tmseform1 = class(tmseform);
 tframe1 = class(tframe);
 tscrollingwidget1 = class(tscrollingwidget);
 twindow1 = class(twindow);
 tcustomframe1 = class(tcustomframe);

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
                               const aintf: pdesignmoduleintfty;
                               const adesignformclass: designformclassty = nil);
var
 int1: integer;
begin
 with registereddesignmoduleclasses do begin
  for int1:= 0 to high(flist) do begin
   with flist[int1] do begin
    if classtype = aclass then begin
     intf:= aintf;
     formclass:= adesignformclass;
     exit;
    end;
   end;
  end;
  registerclass(aclass);
  setlength(flist,high(flist)+2);
  with flist[high(flist)] do begin
   classtype:= aclass;
   intf:= aintf;
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
 raise exception.Create(actionsmo.c[ord(ac_unknownmodclass)]+ aclassname^ +'": "'+
              designmoduleclassname+'".');
end;

function createdesignform(const aowner: tdesigner; 
                 const amodule: pmoduleinfoty): tformdesignerfo;
begin
 with amodule^ do begin
  if designformclass = nil then begin
   designformclass:= tformdesignerfo;
  end;
  result:= designformclassty(designformclass).create(nil,aowner,
                                                       moduleintf,amodule);
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

{ tformdesignerselections }

constructor tformdesignerselections.create(const owner: tformdesignerfo);
begin
 fowner:= owner;
 inherited create;
end;

function tformdesignerselections.assign(
                          const source: idesignerselections): boolean;
              //true if owned components involved
var
 amodule: tmsecomponent;
 ar1: booleanarty;
 
 procedure checkowned;
 var
  int1: integer;
  comp1: tcomponent;
  po1: pformselectedinfoty;
 begin
  result:= false;
  setlength(ar1,count);
  po1:= datapo;
  for int1:= 0 to count - 1 do begin
   result:= po1^.selectedinfo.instance = amodule;
   comp1:= po1^.selectedinfo.instance;
   while comp1 <> nil do begin
    if comp1 = amodule then begin
     result:= true;
     ar1[int1]:= true;
     break;
    end;
    comp1:= comp1.owner;
   end;
   inc(po1);
  end;
 end;

var
 int1: integer;
 po1: pformselectedinfoty;
 comp1: tcomponent;
 bo1,bo2: boolean;
begin
 result:= false;
 amodule:= fowner.fmodule;
 checkowned;
 inherited assign(source);
 if not result then begin
  checkowned;
 end;
 if result then begin
  bo1:= false;
  bo2:= false;
  po1:= datapo;
  for int1:= 0 to count - 1 do begin   
   comp1:= po1^.selectedinfo.instance;
   while (comp1 <> nil) and (comp1 <> amodule) do begin
    if ar1[int1] then begin
     if (comp1 is tmsedatamodule) and (comp1 <> 
                                   po1^.selectedinfo.instance) then begin
      with tmsedatamodule(comp1) do begin
       options:= options - [dmo_iconic];
      end;
     end;
    
     if fowner.iswidgetcomp(comp1) then begin
      bo1:= true;
     end
     else begin
      bo2:= true;
     end;
    end;
    comp1:= comp1.owner;
   end;
   inc(po1);
  end;
  with fowner do begin
   if bo1 then begin
    hidewidgetact.checked:= false;
   end;
   if bo2 then begin
    hidecompact.checked:= false;
   end;
  end;
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
    if fowner.iswidgetcomp(instance) then begin
     with twidget1(instance) do begin
      nohandles:= ws1_nodesignhandles in fwidgetstate1;
      fcandelete:= fcandelete and not (ws1_nodesigndelete in fwidgetstate1);
      rect:= makerect(translatewidgetpoint(pos,parentwidget,fowner),size);
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
 int1,int2: integer;
 widget1: twidget;
 comp1,comp2: tcomponent;
 rect1,rect2: rectty;
 pt1: pointty;
 ar1: componentarty;
begin
 result:= false;
 if (dist.x <> 0) or (dist.y <> 0) then begin
  setlength(ar1,count);
  for int1:= 0 to high(ar1) do begin
   comp1:= items[int1];
   while fowner.iswidgetcomp(comp1) and 
             (cs_parentwidgetrect in twidget1(comp1).fmsecomponentstate) do begin
    comp1:= twidget(comp1).parentwidget;
   end;
   ar1[int1]:= comp1;
  end;
  for int1:= 0 to high(ar1) do begin
   comp1:= ar1[int1];
   for int2:= int1 + 1 to high(ar1) do begin
    if ar1[int2] = comp1 then begin
     ar1[int2]:= nil; //remove duplicates
    end;
   end;
  end;
  for int1:= 0 to count - 1 do begin
   comp1:= ar1[int1];
   if comp1 <> nil then begin
    with itempo(int1)^,selectedinfo do begin
     if fowner.iswidgetcomp(comp1) and (comp1 <> fowner.module) then begin
      if not nohandles then begin
       widget1:= twidget(comp1).parentwidget;
       while widget1 <> nil do begin
        if (widget1 <> fowner.form) and (indexof(widget1) >= 0) then begin
         break;  //moved by parent
        end;
        widget1:= widget1.parentwidget;
       end;
       if widget1 = nil then begin
        with twidget(comp1) do begin
         pos:= addpoint(pos,dist);
         result:= true;
        end;
       end;
      end;
     end
     else begin
      comp2:= tcomponent(comp1).owner;
      while comp2 <> nil do begin
       if (comp2 <> fowner.module) and 
            (fowner.iswidgetcomp(comp2) or isdatasubmodule(comp2)) and
                                         (indexof(comp2) >= 0) then begin 
        break; //moved by owner
       end;
       comp2:= comp2.owner;
      end;
      if comp2 = nil then begin
       rect1:= fowner.getcomponentrect1(tcomponent(comp1));
       fowner.invalidaterect(rect1);
       pt1:= rect1.pos;
       addpoint1(rect1.pos,dist);
       with fowner do begin
        rect2:= compplacementrect;
        if form <> nil then begin      
         shiftinrect(rect1,rect2);
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
       setcomponentpos(comp1,addpoint(getcomponentpos(comp1),
                                              subpoint(rect1.pos,pt1)));
       fowner.invalidaterect(rect1);
       result:= true;
      end;
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
    if not nohandles then begin
     if fowner.iswidgetcomp(instance) then begin
      with twidget(instance) do begin
       size:= sizety(addpoint(pointty(size),dist));
      end;
     end
     else begin
      if isdatasubmodule(instance) then begin
       with tmsedatamodule(instance) do begin
        size:= sizety(addpoint(pointty(size),dist));
       end;
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
 fowner.invalidate;
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

procedure tformdesignerselections.externalcomponentchanged(
                                                const acomponent: tobject);
begin
 finfovalid:= false;
 if count > 0 then begin
  fowner.invalidate;
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
     if isdatasubmodule(instance) or fowner.iswidgetcomp(instance) and 
                    not (cs_parentwidgetrect in 
                          twidget1(instance).fmsecomponentstate) then begin
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
{
var
 int1: integer;
 int2: integer;
}
begin
{
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
}
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
(*
{ tdesignwindow }

constructor tdesignwindow.create(const aowner: tformdesignerfo; 
                                   const adesigner: tdesigner);
begin
// fdesigner:= adesigner;
{
 fshowgrid:= true;
 fsnaptogrid:= true;
 fgridsizex:= defaultgridsizex;
 fgridsizey:= defaultgridsizey;
 fselections:= tformdesignerselections.create(self);
}
 inherited create(aowner);
// updateprojectoptions;
// designnotifications.registernotification(idesignnotification(self));
end;

destructor tdesignwindow.destroy;
begin
// designnotifications.unregisternotification(idesignnotification(self));
 inherited;
// fselections.free;
end;
*)
(*
procedure tdesignwindow.dispatchkeyevent(const eventkind: eventkindty;
  var info: keyeventinfoty);
var
 po1: pointty;
 comp1: tcomponent;
 shiftstate1: shiftstatesty;
 actareabefore: areaty;
begin
 if module = nil then begin
  inherited;
  exit;
 end;
 shiftstate1:= info.shiftstate * keyshiftstatesmask;
 if eventkind = ek_keypress then begin
  with info do begin
   if shiftstate1 = [] then begin
    include(eventstate,es_processed);
    case key of
     key_return: begin
      if not designer.editcomponent(module) then begin
       exclude(eventstate,es_processed);
      end;
     end;
     key_escape: begin
      if not (factarea in [ar_none,ar_component]) then begin
       hidexorpic(fownerwidget.container.getcanvas(org_widget));
       fxorpicactive:= false;
       factarea:= ar_none;
      end
      else begin      
       if (fselections.count > 1) and (factarea <> ar_component) then begin
        selectcomponent(module);
       end
       else begin
        if fselections.count > 0 then begin
         if factarea = ar_component then begin
          comp1:= fselections[factcompindex];
         end
         else begin
          comp1:= fselections[0];
         end;
         if iswidgetcomp(comp1) then begin
          repeat
           comp1:= twidget(comp1).parentwidget;
          until (comp1 = nil) or (ws_iswidget in twidget(comp1).widgetstate);
          actareabefore:= factarea;
          if (comp1 <> nil) and (comp1 <> fownerwidget) then begin
           if fselections.count > 1 then begin
            selectparentwidget(twidget(comp1));
           end
           else begin
            selectcomponent(comp1);
           end;
          end
          else begin
           selectcomponent(module);
          end;
          factarea:= actareabefore;
         end
         else begin
//          if isdatasubmodule(comp1.owner) then begin
           selectcomponent(comp1.owner);
//          end
//          else begin
//           selectcomponent(module);
//          end;
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
    if (shiftstate1 = [ss_ctrl]) or (shiftstate1 = [ss_shift]) then begin
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
      if shiftstate1 = [ss_ctrl] then begin
       fselections.move(po1);
       if fselections.count > 0 then begin
        fselections.updateinfos;
        tformdesignerfo(fownerwidget).componentmoving(
             rectcenter(fselections.itempo(0)^.handles[ht_topleft]));
       end;
      end
      else begin
       fselections.resize(po1);
       if fselections.count > 0 then begin
        fselections.updateinfos;
        with fselections.itempo(0)^.handles[ht_bottomright] do begin
         tformdesignerfo(fownerwidget).componentmoving(
                             makepoint(x+cx div 2 + 1,y+cy div 2 +1));
        end;
       end;
      end;
      fownerwidget.invalidate;
      clientsizechanged;
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
       dopaste(false,'');
       include(eventstate,es_processed);
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
*)

(*
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
 bo1,bo2: boolean;
 posbefore: pointty;
 widget1: twidget;
 rect1: rectty;
 selectmode: selectmodety;
 area1: areaty;
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
  isinpaintrect:= pointinrect(pos,tformdesignerfo(fownerwidget).gridrect);
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
        if (form <> nil) and 
                 not tformdesignerfo(fownerwidget).hidewidgetact.checked then begin
         component:= widgetatpos(pos,true);
        end
        else begin
         component:= module;
        end;
       end;
      end;
      if component <> nil then begin
       if (factcompindex < 0) or 
                       (component <> fselections[factcompindex]) then begin
        factarea:= ar_none;
       end;
       bo1:= true;
       if ss_ctrl in ss1 then begin
        selectcomponent(component,sm_flip);
       end
       else begin
        bo2:= fselections.indexof(component) < 0;
        if (component = form) and (fselections.count > 1) or bo2 then begin
         selectcomponent(component,sm_select);
         if projectoptions.e.moveonfirstclick then begin
          factarea:= ar_component;
         end;
        end
        else begin
         if not bo2 then begin
          updateclickedcomponent;
         end;
        end;
        {
        if ss_double in shiftstate then begin
         designer.showobjectinspector;
        end;
        }
       end;
      end
      else begin
       factarea:= ar_none;
      end;
      fclickedcompbefore:= component;
     end
     else begin
      fownerwidget.capturemouse;
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
       not ((fdesigner.hascurrentcomponent or componentstorefo.hasselection) and 
                     (eventkind = ek_buttonpress) and 
       (button = mb_left) and (ss1 = [ss_left])) and 
       not ((area1 = ar_component) and 
           not((fselections[int1] is twidget) or 
               isdatasubmodule(fselections[int1]))) and 
       (factarea <> ar_componentmove) then begin
     inherited;
    end;
    pos:= posbefore;
    if bo1 then begin
     if not (es_processed in eventstate) then begin
      if (capture = nil) or not 
             (ws1_designactive in twidget1(capture).fwidgetstate1) then begin
       fownerwidget.capturemouse; //capture mouse
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
       if (component = nil) and componentstorefo.hasselection then begin
        dopaste(true,componentstorefo.copyselected);
       end;
      end;
      if component <> nil then begin
       tformdesignerfo(fownerwidget).placecomponent(component,pos);
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
        fpickwidget:= fownerwidget;
       end;
      end;
     end;
    end;
    if (eventkind = ek_buttonrelease) and (button = mb_left) then begin
     hidexorpic(fownerwidget.container.getcanvas(org_widget));
     fxorpicactive:= false;
     case factarea of
      firsthandle..lasthandle: begin
       if (factcompindex >= 0) and (factcompindex < fselections.count) then begin
        component:= tcomponent(
                     fselections.itempo(factcompindex)^.selectedinfo.instance);
        if (component is twidget) and (form <> nil) then begin
         with twidget(component) do begin
          subpoint1(factsizerect.pos,parentwidget.rootpos);
          widgetrect:= factsizerect;
         end;
         fselections.componentschanged;
        end
        else begin
         if component is tmsedatamodule then begin
          rect1:= getcomponentrect1(component);          
          with tmsedatamodule(component) do begin
           subpoint1(factsizerect.pos,rect1.pos);
//////           subpoint1(factsizerect.pos,parentwidget.rootpos);
           setcomponentpos(component,
                addpoint(getcomponentpos(component),factsizerect.pos));
           size:= factsizerect.size;
          end;
          fselections.componentschanged;
         end;
        end;
       end;
       fownerwidget.invalidate;
      end;
      ar_componentmove: begin
       if fselections.move(griddelta) then begin
        fownerwidget.invalidate; //redraw handles
        clientsizechanged;
       end;
      end;
      ar_component: begin
       if ss_double in shiftstate then begin
        designer.showobjectinspector;
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
         if fpickwidget <> fownerwidget then begin
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
     if factcompindex >= 0 then begin
      factcompindex:= -1;
      updateclickedcomponent; //update objectionspector componentname
     end;
     fownerwidget.releasemouse;
    end;
 
    if not (es_processed in eventstate) then begin
     if (eventkind = ek_mousemove) or (eventkind = ek_mousepark) then begin
      hidexorpic(fownerwidget.getcanvas(org_widget));
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
       showxorpic(fownerwidget.container.getcanvas(org_widget));
      end;
     end;
    end;
   end;
  end;
1:
  if (eventkind in mouseposevents) and (fselections.count = 1) then begin
   fselections.updateinfos;
   po1:= fselections.itempo(0);
   if po1^.selectedinfo.instance <> tformdesignerfo(fownerwidget).fmodule then begin
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
     tformdesignerfo(fownerwidget).componentmoving(pt1);
    end;
   end;
  end;
 end;
end;
*)
{
function tdesignwindow.form: twidget;
begin
 result:= tformdesignerfo(fownerwidget).fform;
end;

function tdesignwindow.module: tmsecomponent;
begin
 result:= tformdesignerfo(fownerwidget).fmodule;
end;
}



{ tformcontainer }

constructor tformcontainer.create(const aowner: tformdesignerfo);
begin
 fdesignfo:= aowner;
 inherited create(nil,aowner,false);
 with tcustomframe1(fframe),fi.innerframe do begin
  left:= 0;
  top:= 0;
  right:= 0;
  bottom:= 0;
  internalupdatestate();
 end;
 createface();
 face.image.source:= mainfo.formbg;
 face.image.alignment:= [al_tiled];
 color:= cl_background;
 optionsskin:= [osk_framebuttononly];
 updateskin();
end;

procedure tformcontainer.widgetregionchanged(const sender: twidget);
begin
 inherited;
 fdesignfo.formcontainerwidgetregionchanged(sender);
end;

function tformcontainer.isdesignwidget: boolean;
begin
 result:= true;
end;

{ tformdesignerfo }

constructor tformdesignerfo.create(const aowner: tcomponent; 
                                   const adesigner: tdesigner;
                                   const aintf: pdesignmoduleintfty;
                                   const amoduleinfo: pmoduleinfoty);
begin
 fdesigner:= adesigner;
 fmoduleintf:= aintf;
 fmoduleinfo:= amoduleinfo;

 fshowgrid:= true;
 fsnaptogrid:= true;
 fgridsizex:= defaultgridsizex;
 fgridsizey:= defaultgridsizey;
 fselections:= tformdesignerselections.create(self);
 fformcont:= tformcontainer.create(self);

// createwindow;
 inherited create(aowner);
 updateprojectoptions;
 designnotifications.registernotification(idesignnotification(self));
 include(ffostate,fds_loaded);
end;

destructor tformdesignerfo.destroy;
begin
 designer.modules.designformdestroyed(self);
 fmodule.free();
 designnotifications.unregisternotification(idesignnotification(self));
 inherited;
 fformcont.free();
 fselections.free();
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
{
procedure tformdesignerfo.createwindow;
begin
 tdesignwindow.create(self,fdesigner)
end;
}
function tformdesignerfo.designnotification: idesignnotification;
begin
 result:= idesignnotification(self);
end;

function tformdesignerfo.getcomponentrect1(const component: tcomponent): rectty;
var
 comp1: tcomponent;
 bo1: boolean;
begin
 result:= getcomponentrect(component,true);
 comp1:= component.owner;
 while comp1 <> nil do begin
  if isdatasubmodule(comp1) then begin        //adjust submodulepos
   addpoint1(result.pos,getcomponentpos(comp1));
  end;
  comp1:= comp1.owner;
 end;
 if fform <> nil then begin
  comp1:= component.owner;
  bo1:= false;
  while (comp1 <> module) and (comp1 <> nil) do begin
   if iswidgetcomp(comp1) then begin
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

function tformdesignerfo.iswidgetcomp(const acomp: tcomponent): boolean;
begin
 result:= (acomp is twidget) and (form <> nil) and 
                        (twidget(acomp).parentwidget <> nil);
end;

procedure tformdesignerfo.paintxorpic(const canvas: tcanvas);
begin
 if fxorpicactive then begin
  canvas.save;
//  canvas.intersectcliprect(fowner.container.paintrect);
  canvas.intersectcliprect(gridrect);
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

procedure tformdesignerfo.hidexorpic(const canvas: tcanvas);
begin
 if fxorpicshowed then begin
  paintxorpic(canvas);
  fxorpicshowed:= false;
 end;
end;

procedure tformdesignerfo.showxorpic(const canvas: tcanvas);
begin
 if not fxorpicshowed then begin
  paintxorpic(canvas);
  fxorpicshowed:= true;
 end;
end;

procedure tformdesignerfo.movewindowrect(const dist: pointty;
                                               const rect: rectty);
var
 canvas: tcanvas;
begin
{         todo!
 if isnullpoint(dist) then begin
  exit;
 end;
 canvas:= fownerwidget.getcanvas(org_widget);
 hidexorpic(canvas);
 fxorpicactive:= false;
 fselections.change;
 inherited;
 invalidaterect(moverect(rect,dist)); //redraw grid
}
end;

procedure tformdesignerfo.adjustchildcomponentpos(var apos: pointty);
begin
 subpoint1(apos,componentoffset);
 addpoint1(apos,widgetrefpoint);
end;

procedure tformdesignerfo.readjustchildcomponentpos(var apos: pointty);
begin
 addpoint1(apos,componentoffset);
 subpoint1(apos,widgetrefpoint);
end;

function tformdesignerfo.getcomponentrect(const component: tcomponent;
                                         const shiftoffset: boolean): rectty;
var
 bo1: boolean;
begin
 result.pos:= getcomponentpos(component);
 if shiftoffset then begin
  addpoint1(result.pos,componentoffset);
 end;
 bo1:= (component is tmsedatamodule) and 
                 (csinline in tmsedatamodule(component).componentstate);
 if bo1 and not (dmo_iconic in tmsedatamodule(component).options) then begin
  result.size:= tmsedatamodule(component).size;
 end
 else begin
  result.cx:= complabelleftmargin + 
                  getcanvas.getstringwidth(component.name) +
                   complabelrightmargin;
  if not bo1 then begin 
   result.cx:= result.cx + componentsize;
  end;
  result.cy:= componentsize;
 end;
end;

function tformdesignerfo.componentscrollsize: sizety;

 procedure check(const acomponent: tcomponent; const shift: pointty);
 var
  int1,int2: integer;
  component: tcomponent;
  rect1: rectty;
 begin  
  if acomponent <> nil then begin
   with acomponent do begin
    for int1:= 0 to componentcount - 1 do begin
     component:= components[int1];
     if not iswidgetcomp(component) then begin
      rect1:= getcomponentrect(component,false);
      addpoint1(rect1.pos,shift);
      int2:= rect1.x + rect1.cx;
      if int2 > result.cx then begin
       result.cx:= int2;
      end;
      int2:= rect1.y + rect1.cy;
      if int2 > result.cy then begin
       result.cy:= int2;
      end;
      if isdatasubmodule(component) then begin
       check(component,rect1.pos);
      end;
     end;
    end;
   end;
  end;
 end; //check
 
begin
 result:= nullsize;
 check(fmodule,nullpoint);
 inc(result.cx,handlesize);
 inc(result.cy,handlesize);
end;

procedure tformdesignerfo.doaddcomponent(acomponent: tcomponent);
var
 comp1: tcomponent;
 comps: tfplist;
begin
 comp1:= acomponent.owner;
 if (comp1 <> nil) and not issubcomponent(fmodule,comp1) then begin
 {$ifdef FPC}{$warnings off}{$endif}
  with tcomponent1(comp1) do begin
 {$ifdef FPC}{$warnings on}{$endif}
   comps:= fcomponents;
   fcomponents:= nil; //do not propagate freenotifiaction to children
   comp1.removecomponent(acomponent);
   if comps <> nil then begin
    comps.remove(acomponent);
    if comps.count = 0 then begin
     comps.free;
    end
    else begin
     fcomponents:= comps;
    end;
   end;
  end;
 end;
 fdesigner.addcomponent(module,acomponent);
// if csinline in component.ComponentState then begin
 if acomponent.ComponentState * [csancestor,csinline] <> [] then begin
  tcomponent1(acomponent).getchildren(
                           {$ifdef FPC}@{$endif}doaddcomponent,acomponent);
  if comp1 <> nil then begin
   tcomponent1(acomponent).getchildren(
                               {$ifdef FPC}@{$endif}doaddcomponent,comp1);
  end;
 end
 else begin
// if comp1 <> nil then begin //else submodule
  tcomponent1(acomponent).getchildren(
                                   {$ifdef FPC}@{$endif}doaddcomponent,comp1);
 end;
end;

procedure tformdesignerfo.doinitcomponent(const acomponent: tcomponent;
                      const parent: tcomponent);
var
 rect1: rectty;
 pt1,pt2: pointty;
begin
 doaddcomponent(acomponent);
 if (acomponent is twidget) and (parent is twidget) then begin
  with twidget(acomponent) do begin
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
  twidget(parent).insertwidget(twidget(acomponent),pt1);
  if fclipinitcomps then begin
   rect1:= twidget(acomponent).widgetrect;
   shiftinrect(rect1,twidget(acomponent).parentwidget.clientwidgetrect);
   twidget(acomponent).widgetrect:= rect1;
  end;
 end
 else begin
  pt2:= getcomponentpos(acomponent);
  if fuseinitcompsoffset then begin  
   pt1:= finitcompsoffset;
   subpoint1(finitcompsoffset,pt2);
   fcompsoffsetused:= true;
   fuseinitcompsoffset:= false;
  end
  else begin 
   pt1:= pt2;
   if fcompsoffsetused then begin
    addpoint1(pt1,finitcompsoffset);
   end;
  end;
  setcomponentpos(acomponent,pt1);
 end;
end;

procedure tformdesignerfo.docopy(const noclear: boolean);
var
 int1: integer;
 widget1: twidget;
begin
 fselections.remove(module);
 fselections.copytoclipboard;
 if not noclear then begin
  if form = nil then begin
   selectcomponent(fmodule);
  end
  else begin
   widget1:= nil;
   if (fselections.count > 0) and iswidgetcomp(fselections[0]) then begin
    widget1:= twidget(fselections[0]).parentofcontainer;
    for int1:= 1 to fselections.count - 1 do begin
     if not iswidgetcomp(fselections[int1]) or 
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

procedure tformdesignerfo.docut();
begin
 docopy(true);
 dodelete();
end;

procedure tformdesignerfo.dopaste(const usemousepos: boolean;
                                                  const adata: string);
var
 comp1: tcomponent;
 bo1: boolean;
begin
 try
//  if form <> nil then begin
  fclipinitcomps:= not usemousepos;
  comp1:= module;
  bo1:= true;
  fuseinitcompsoffset:= usemousepos;
  fcompsoffsetused:= false;
  finitcompsoffset:= dosnaptogrid(fmousepos);
  with fselections do begin
   if count = 1 then begin
    comp1:= items[0];
    if iswidgetcomp(comp1) then begin
     bo1:= form.checkdescendent(twidget(comp1));
     if usemousepos then begin
      finitcompsoffset:= subpoint(dosnaptogrid(fmousepos),
                                          twidget(comp1).rootpos);
     end;
    end;
   end;
   if bo1 then begin
    clear;
    if adata <> '' then begin
     pastefromobjecttext(adata,module,comp1,
                  {$ifdef FPC}@{$endif}doinitcomponent);
    end
    else begin
     pastefromclipboard(module,comp1,{$ifdef FPC}@{$endif}doinitcomponent);
    end;
    updateselections;
    designer.componentmodified(module);
   end;
  end;
 finally
  fclipinitcomps:= false;
 end;
 clientsizechanged;
end;

procedure tformdesignerfo.doundelete();
var
 int1: integer;
 ar1: componentarty;
begin
 if fdelobjs <> nil then begin
  with fselections do begin
   clear;
   for int1:= 0 to high(fdelobjs) do begin
    with fdelobjs[int1] do begin
     ar1:= pastefromobjecttext(objtext,owner,parent,
                    {$ifdef FPC}@{$endif}doinitcomponent);
     if ar1 <> nil then begin
      if (owner <> nil) and (ownerindex >= 0) then begin
       ar1[0].componentindex:= ownerindex;
      end;
      if (parent <> nil) and (parentindex >= 0) then begin
      {$warnings off}
       tcomponent1(parent).setchildorder(ar1[0],parentindex);
      {$warnings on}
      end;
     end;
     if parent <> nil then begin
      
      designer.componentmodified(parent);
     end
     else begin
      designer.componentmodified(owner);
     end;
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
  clientsizechanged;
 end;
end;

procedure tformdesignerfo.dodelete;
var
 int1: integer;
begin
 with fselections do begin  
  for int1:= 0 to count - 1 do begin
   with items[int1] do begin
    if componentstate * [csancestor,csinline] = [csancestor] then begin
     showmessage(actionsmo.c[ord(ac_inheritedcomp)]+name+
                     actionsmo.c[ord(ac_cannotdel)],actionsmo.c[ord(ac_error)]);
     exit;
    end;             
   end;
  end;
  removeforeign;
  fdelobjs:= fselections.getobjinfoar;
  deletecomponents;
 end;
// domodified;
 clientsizechanged;
end;


procedure tformdesignerfo.selectchildexec(const sender: tobject);
var
 ar1: msestringarty;
 comp1: tcomponent;
begin
 with tmenuitem(sender) do begin
  ar1:= splitstring(caption,widechar(' '));
  if fselectwidget <> nil then begin
   comp1:= fselectwidget.findlogicalchild(ar1[0]);
  end
  else begin
   comp1:= fselectcomp.findcomponent(ar1[0]);
  end;
  if comp1 <> nil then begin
   selectcomponent(comp1,sm_select);
  end;
 end;
end;

procedure tformdesignerfo.dopopup(var info: mouseeventinfoty);

var
 bo1,bo2,bo3,bo4: boolean;
 item1: tmenuitem;
 ar1: msestringarty;
 ar2: componentarty;
 int1: integer;
 selectcomp: tcomponent;
 comp1: tcomponent;
begin
 with popupme,menu do begin
  selectcomp:= nil;
  if fselections.count = 1 then begin
   selectcomp:= fselections[0];
  end;
  bo1:= (fselections.count > 0) and (fselections[0] <> module);
  bo2:= bo1 and fselections.candelete;
  itembyname('copy').enabled:= bo1;
  itembyname('cut').enabled:= bo2;
  itembyname('delete').enabled:= bo2;
  itembyname('undelete').enabled:= fdelobjs <> nil;
  itembyname('paste').enabled:= iswidgetcomp(selectcomp) or (fform = nil);
  itembyname('editcomp').enabled:= designer.componentcanedit;
  {
  bo1:= not(
           (fselections.count <> 1) or 
           not(fselections.items[0] is twidget) or
           not fowner.checkdescendent(twidget(fselections.items[0]))
           );
  }
  bo1:= iswidgetcomp(selectcomp) and 
                    checkdescendent(twidget(selectcomp));
  itembyname('insertsub').enabled:= bo1 or (selectcomp = module) or
                                               isdatasubmodule(selectcomp);
                      
  itembyname('revert').enabled:= (fselections.count = 1) and 
          (fselections[0].componentstate * [csinline,csancestor] <> []);
  itembyname('insertcomp').enabled:= designer.hascurrentcomponent and
                                                      (fselections.count = 1);
  itembyname('bringtofro').enabled:= bo1;
  itembyname('sendtoba').enabled:= bo1;

  bo3:= false;
  bo4:= false;
  for int1:= 0 to fselections.count - 1 do begin
   comp1:= fselections[int1];
   if not (comp1 is tmsedatamodule) or 
          not (csinline in comp1.componentstate) then begin
    bo3:= false;
    bo4:= false;
    break;
   end;
   if dmo_iconic in tmsedatamodule(comp1).options then begin
    bo4:= true;
   end
   else begin
    bo3:= true;
   end;
  end;
  itembyname('iconify').enabled:= bo3;
  itembyname('deiconify').enabled:= bo4;
  
  itembyname('settabord').enabled:= bo1 and 
          (twidget(fselections.items[0]).parentwidget.childrencount >= 2);
  itembyname('synctofo').enabled:= fselections.count > 0;
  item1:= itembyname('selectchild');
  item1.enabled:= iswidgetcomp(selectcomp) and
                        (twidget(selectcomp).container.widgetcount > 0) or
                  isdatasubmodule(selectcomp) and 
                        (selectcomp.componentcount > 0);
  if item1.enabled then begin
   if iswidgetcomp(selectcomp) then begin
    fselectwidget:= twidget(selectcomp);
    ar2:= componentarty(fselectwidget.getlogicalchildren);
   end
   else begin
    fselectwidget:= nil;
    fselectcomp:= selectcomp;
    setlength(ar2,fselectcomp.componentcount);
    for int1:= 0 to high(ar2) do begin
     ar2[int1]:= fselectcomp.components[int1];
    end;
   end;
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
  show(self,info);
  item1.submenu.clear; 
 end;
end;

function tformdesignerfo.widgetatpos(const apos: pointty;
                                onlywidgets: boolean): twidget;
var
 widgetinfo: widgetatposinfoty;
begin
 result:= nil;
 if pointinrect(apos,gridrect) then begin
  fillchar(widgetinfo,sizeof(widgetinfo),0);
  with widgetinfo do begin
   pos:= translatewidgetpoint(apos,self,form);
//   pos:= subpoint(apos,form.rootpos);
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

procedure tformdesignerfo.clientsizechanged();
begin
 fclientsizevalid:= false;
end;

procedure tformdesignerfo.poschanged();
begin
 inherited;
 if (fmodulesetting = 0) and (fparentwidget = nil) then begin //not docked
  fmodulepos:= translatewidgetpoint(paintpos,self,nil);
  doModified;
 end;
 updatedockinfo();
end;

procedure tformdesignerfo.sizechanged();
begin
 inherited;
 updatedockinfo();
end;

procedure tformdesignerfo.drawgrid(const canvas: tcanvas);
var
 po1: pointty;
 rect1,rect2: rectty;
 endy: integer;
 offset: pointty;
 points1: pointarty;
 int1,gridcx,gridcy: integer;
begin
 if showgrid then begin
  rect2:= gridrect;
  msegraphutils.intersectrect(canvas.clipbox,rect2,rect1);
  offset:= gridoffset;
  gridcx:= gridsizex;
  gridcy:= gridsizey;
  with rect1 do begin
   po1.x:= ((x - offset.x) div gridcx) * gridcx + offset.x;
   po1.y:= ((y - offset.y) div gridcy) * gridcy + offset.y;
   endy:= y + cy;
  end;
  setlength(points1, rect1.cx div gridcx + 2);
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

procedure tformdesignerfo.clearselection();
begin
 fdesigner.noselection;
end;

procedure tformdesignerfo.deletecomponent(const component: tcomponent);
begin
 fdesigner.selectcomponent(component);
 fdesigner.deleteselection(true);
 domodified;
 clientsizechanged;
end;

procedure tformdesignerfo.selectcomponent(const component: tcomponent;
//                       const bymouse: boolean;
                       mode: selectmodety = sm_select);
begin
 if component <> nil then begin
  if mode = sm_remove then begin
   fselections.remove(component);
   factcompindex:= -1;
  end
  else begin
   if mode = sm_select then begin
    fselections.clear;
   end;
   factcompindex:= fselections.indexof(component);
   if factcompindex < 0 then begin
    factcompindex:= fselections.add(component);
   end
   else begin
    if mode = sm_flip then begin
     fselections.remove(component);
     factcompindex:= -1;
    end;
   end;
  end;
  if factcompindex < 0 then begin
   factarea:= ar_none;
  end;
  updateselections;
 end;
end;

procedure tformdesignerfo.selectparentwidget(const awidget: twidget);
var
 int1: integer;
begin
 with fselections do begin
  beginupdate;
  try
   for int1:= count-1 downto 0 do begin
    with itempo(int1)^ do begin
     if (selectedinfo.instance is twidget) and 
             awidget.checkdescendent(twidget(selectedinfo.instance)) then begin
      delete(int1);
     end;
    end;
   end;
   add(awidget);
   factcompindex:= indexof(awidget);
  finally
   endupdate;
  end;
 end;
 updateselections;
end;

procedure tformdesignerfo.setrootpos(const component: tcomponent;
  const apos: pointty);
begin
 setcomponentpos(component,apos);
end;

procedure tformdesignerfo.updateselections;
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

procedure tformdesignerfo.updateclickedcomponent;
begin           
 objectinspectorfo.clickedcomponentchanged(clickedcomponent);
end;

procedure tformdesignerfo.beginselect;
begin
 inc(fselecting);
 fselections.beginupdate;
end;

procedure tformdesignerfo.endselect;
begin
 dec(fselecting);
 fselections.endupdate;
 if fselecting = 0 then begin
  updateselections;
 end;
end;

procedure tformdesignerfo.domodified;
begin
 invalidate;
 if fds_loaded in ffostate then begin
  fdesigner.componentmodified(fmodule);
 end;
end;

procedure tformdesignerfo.methodcreated(const adesigner: idesigner;
  const amodule: tmsecomponent; const aname: string;
  const atype: ptypeinfo);
begin
 //dummy
end;

procedure tformdesignerfo.methodnamechanged(const adesigner: idesigner;
  const amodule: tmsecomponent; const newname, oldname: string; 
                      const atypeinfo: ptypeinfo);
begin
 //dummy
end;

procedure tformdesignerfo.showobjecttext(const adesigner: idesigner; 
              const afilename: filenamety; const backupcreated: boolean);
begin
 //dummy
end;

procedure tformdesignerfo.closeobjecttext(const adesigner: idesigner; 
                           const afilename: filenamety; var cancel: boolean);
begin
 //dummy
end;

procedure tformdesignerfo.moduleactivated(const adesigner: idesigner;
                      const amodule: tmsecomponent);
begin
 //dummy
end;

procedure tformdesignerfo.moduledeactivated(const adesigner: idesigner; const amodule: tmsecomponent);
begin
 //dummy
end;

procedure tformdesignerfo.checkdelobjs(const aitem: tcomponent);
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

procedure tformdesignerfo.moduledestroyed(const adesigner: idesigner;
  const amodule: tmsecomponent);
begin
 checkdelobjs(amodule);
end;

procedure tformdesignerfo.ItemDeleted(const ADesigner: IDesigner;
            const amodule: tmsecomponent; const AItem: tcomponent);
begin
 fselections.remove(aitem);
 checkdelobjs(aitem);
end;

procedure tformdesignerfo.ItemInserted(const ADesigner: IDesigner;
            const amodule: tmsecomponent; const AItem: tcomponent);
begin
 //dummy
end;

procedure tformdesignerfo.ItemsModified(const ADesigner: IDesigner;
           const AItem: tobject);
begin
 fselections.externalcomponentchanged(aitem);
 if isdatasubmodule(aitem,false,true) then begin //iconic state could be changed
  clientsizechanged;
 end;
end;

procedure tformdesignerfo.componentnamechanging(const adesigner: idesigner;
                     const amodule: tmsecomponent; const aitem: tcomponent;
                     const newname: string);
begin
 if (amodule = fmodule) and not (aitem is twidget) then begin
  fclientsizevalid:= false;
 end;
end;

procedure tformdesignerfo.moduleclassnamechanging(const adesigner: idesigner;
                    const amodule: tmsecomponent; const newname: string);
begin
 //dummy
end;

procedure tformdesignerfo.instancevarnamechanging(const adesigner: idesigner;
                     const amodule: tmsecomponent; const newname: string);
begin
 //dummy
end;

procedure tformdesignerfo.setshowgrid(const avalue: boolean);
begin
 if fshowgrid <> avalue then begin
  fshowgrid:= avalue;
  invalidate();
 end;
end;

procedure tformdesignerfo.setgridsizex(const avalue: integer);
begin
 if fgridsizex <> avalue then begin
  fgridsizex:= avalue;
  invalidate();
 end;
end;

procedure tformdesignerfo.setgridsizey(const avalue: integer);
begin
 if fgridsizey <> avalue then begin
  fgridsizey:= avalue;
  invalidate();
 end;
end;

procedure tformdesignerfo.updateprojectoptions();
begin
 showgrid:= projectoptions.e.showgrid;
 snaptogrid:= projectoptions.e.snaptogrid;
 gridsizex:= projectoptions.e.gridsizex;
 gridsizey:= projectoptions.e.gridsizey;
 invalidate();
end;

procedure tformdesignerfo.beforemake(const adesigner: idesigner;
               const maketag: integer; var abort: boolean);
begin
 //dummy
end;

procedure tformdesignerfo.aftermake(const adesigner: idesigner;
                                   const exitcode: integer);
begin
 //dummy
end;

procedure tformdesignerfo.beforefilesave(const adesigner: idesigner;
               const afilename: filenamety);
begin
 //dummy
end;

function tformdesignerfo.componentoffset: pointty;
begin
// result:= tformdesignerfo(fowner).gridrect.pos;
 result:= gridoffset;
end;

function tformdesignerfo.snaptogriddelta(const apos: pointty): pointty;
begin
 if snaptogrid then begin
  result.x:= roundint(apos.x,gridsizex);
  result.y:= roundint(apos.y,gridsizey);
 end
 else begin
  result:= apos;
 end;
end;

function tformdesignerfo.dosnaptogrid(const apos: pointty): pointty;
begin
 if snaptogrid then begin
  result:= snaptogriddelta(subpoint(apos,gridoffset));
  addpoint1(result,gridoffset);
 end
 else begin
  result:= apos;
 end;
end;


procedure tformdesignerfo.selectionchanged(const adesigner: idesigner;
      const aselection: idesignerselections);
begin
 try
  fselections.beginupdate;   
  if fselections.assign(aselection) then begin
   componentselected(fselections);
   invalidate();
  end;
 finally
  fselections.decupdate;
 end;
end;

function tformdesignerfo.componentatpos(const apos: pointty): tcomponent;

var
 isdatamodule: boolean;
 toplevel: boolean;
 compoff,widoff: boolean;
                                       
 function checkcomponent(const component: tcomponent;
                const pos: pointty; const shiftoffset: boolean): tcomponent;
 var
  int1: integer;
  pt1: pointty;
  bo1,bo2: boolean;
  shift1: boolean;
  rect1: rectty;
  comp1: tcomponent;
 begin
  result:= nil;
  bo2:= iswidgetcomp(component);
  if ((bo2 and widoff) or (not bo2 and compoff)) and 
                                          (component.owner <> nil) then begin
   exit;
  end;
  bo1:=  not isdatamodule and bo2 and 
                               (twidget(component).parentwidget <> nil);
  bo2:= false;
  shift1:= shiftoffset; //for chidren
  pt1:= pos;
  rect1:= getcomponentrect(component,shiftoffset);
  if bo1 and not toplevel then begin
   subpoint1(pt1,twidget(component).pos);
   if (component.owner = module) and (module is twidget) then begin
//    tdesignwindow(twidget(component).window).readjustchildcomponentpos(pt1);
    readjustchildcomponentpos(pt1);
   end;
  end
  else begin
   if isdatasubmodule(component) then begin
    bo2:= pointinrect(pt1,rect1);
    subpoint1(pt1,rect1.pos);
    shift1:= false;
   end;
  end;
  if toplevel or 
              (not isdatamodule and bo1 or bo2) and 
              not (cssubcomponent in component.componentstyle) and
              (component.componentstate * [csinline,csancestor] <> []) then begin
   toplevel:= false;
   for int1:= component.componentcount - 1 downto 0 do begin
    comp1:= component.components[int1];
    if isdatasubmodule(comp1) then begin
     result:= checkcomponent(comp1,pt1,shift1);
     if result <> nil then begin
      exit;
     end;
    end;
   end;
   for int1:= component.componentcount - 1 downto 0 do begin
    comp1:= component.components[int1];
    if not isdatasubmodule(comp1) then begin
     result:= checkcomponent(comp1,pt1,shift1);
     if result <> nil then begin
      exit;
     end;
    end;
   end;
  end;
  if not bo1 {or isdatamodule} then begin
   if pointinrect(pos,rect1) then begin
    result:= component;
   end;
  end;
 end;
 
begin
 isdatamodule:= fform = nil;
 widoff:= hidewidgetact.checked;
 compoff:= hidecompact.checked;
 toplevel:= true;
 result:= checkcomponent(fmodule,apos,true);
 if result = fmodule then begin
  result:= nil;
 end;
end;


procedure tformdesignerfo.doafterpaint(const canvas: tcanvas);
var
 offs: pointty;
 gridrect1: rectty;
 
 procedure clipchildren(const acomp: tcomponent; const aindex: integer;
                        const shiftoffset: boolean);
 var
  int1: integer;
  comp1: tcomponent;
  rect1: rectty;
 begin
  for int1:= aindex to acomp.componentcount - 1 do begin
   comp1:= acomp.components[int1];
   if isdatasubmodule(comp1) then begin
    rect1:= mr(getcomponentpos(comp1),tmsedatamodule(comp1).size);
    if shiftoffset then begin
     addpoint1(rect1.pos,offs);
    end;
    canvas.subcliprect(rect1);
   end;
  end;
 end;

var
 level: integer;
  
 procedure drawcomponent(const component: tcomponent);
 var
  rect1: rectty;
  int1: integer;
  isroot,iswidget,issub: boolean;
  comp1: tcomponent;
//  bo1: boolean;
 label
  endlab;
 begin
  isroot:= level = 0;
  inc(level);
  if not (cssubcomponent in component.componentstyle) then begin
   iswidget:= false;
   issub:= false;
   if isroot then begin
    iswidget:= true;
   end
   else begin
    iswidget:= iswidgetcomp(component);
    if not iswidget then begin
     issub:= isdatasubmodule(component);
    end;
   end;
   if iswidget then begin
    if isroot then begin
     rect1:= gridrect1;
    end
    else begin
     if hidewidgetact.checked then begin
      goto endlab;
     end;
     rect1:= twidget(component).widgetrect;
     if level = 2 then begin
      addpoint1(rect1.pos,gridrect1.pos);
     end;
    end
   end
   else begin
    rect1:= getcomponentrect(component,level <= 2);
   end;
   if not (iswidget or issub) then begin
    if isdatasubmodule(component,true) then begin
     canvas.fillrect(rect1,cl_ltgray);
     drawtext(canvas,component.name,rect1,[tf_ycentered,tf_xcentered],
                       stockobjects.fonts[stf_default]);
    end
    else begin
     rect1.cx:= rect1.cx - complabelrightmargin;
     drawtext(canvas,component.name,rect1,[tf_ycentered,tf_right],
                        stockobjects.fonts[stf_default]);
     rect1.cx:= rect1.cy;
     registeredcomponents.drawcomponenticon(component,canvas,rect1);
    end;
   end
   else begin
    if component.componentcount > 0 then begin
     canvas.save;
     if not issub then begin
      canvas.intersectcliprect(rect1);
     end;
     if not isroot then begin
      canvas.move(rect1.pos);
     end;
     clipchildren(component,0,isroot);

     for int1:= 0 to component.componentcount - 1 do begin
      comp1:= component.components[int1];
      if not isdatasubmodule(comp1) then begin
       drawcomponent(comp1);
      end;
     end;
     canvas.restore;
     if not isroot then begin
      canvas.move(rect1.pos);
     end;
     for int1:= 0 to component.componentcount - 1 do begin
      comp1:= component.components[int1];
      if isdatasubmodule(comp1) then begin
       canvas.save;
       clipchildren(component,int1+1,isroot);
       drawcomponent(comp1);
       canvas.restore;
      end;
     end;
     if not isroot then begin
      canvas.remove(rect1.pos);
     end;
    end;
    if issub then begin
     canvas.dashes:= #3#3;
     dec(rect1.cx);
     dec(rect1.cy);
     canvas.drawrect(rect1);
     canvas.dashes:= '';
    end;
   end;
  end;
 endlab:
  dec(level);
 end;

begin
 inherited;
 offs:= componentoffset;
 if not pointisequal(offs,fcompoffsbefore) then begin
  fcompoffsbefore:= offs;
  fselections.finfovalid:= false;
 end;
 gridrect1:= gridrect();
 if fmodule <> nil then begin
  canvas.intersectcliprect(gridrect1);
  if not hidecompact.checked then begin
   level:= 0;
   drawcomponent(fmodule);
  end;
  if form <> nil then begin
   drawgrid(canvas);
  end;
  fselections.paint(canvas);
  showxorpic(canvas);
 end;
end;

procedure tformdesignerfo.dobeforepaint(const canvas: tcanvas);
begin
 inherited;
 hidexorpic(canvas);
 if not fclientsizevalid then begin
  recalcclientsize();
  fclientsizevalid:= true;
  fselections.finfovalid:= false;
 end;
end;

procedure tformdesignerfo.doactivate;
begin
 fdesigner.setactivemodule(self);
 inherited;
end;

function tformdesignerfo.fixformsize: boolean;
begin
 result:= parentwidget <> nil; //docked
end;

procedure tformdesignerfo.doasyncevent(var atag: integer);
var
 mstr1: msestring;
 rect1: rectty;
begin
 case designerfoeventty(atag) of
  fde_updatecaption: begin
   if fmodule <> nil then begin
    mstr1:= fmodule.name;
    if fmoduleoptions <> [] then begin
     mstr1:= '-'+mstr1;
    end;
    if fdesigner.modules.findmodule(fmodule)^.modified then begin
     mstr1:= '*'+mstr1;
    end;
    caption:= mstr1;
    dragdock.caption:= mstr1;
   end;
  end;
  fde_syncsize: begin
   if not fixformsize then begin
    rect1:= paintrect;
    if form <> nil then begin
     form.widgetrect:= rect1;
     if sizeisequal(form.size,rect1.size) then begin
      fsizeerrorcount:= 0;
     end;
     if fsizeerrorcount < 4 then begin
      inc(fsizeerrorcount);
      include(ffostate,fds_sizesyncing);
      try
       paintsize:= form.size;
      finally
       exclude(ffostate,fds_sizesyncing);
      end;
     end;
    end
    else begin
     if module is tmsedatamodule then begin
      tmsedatamodule(module).size:= rect1.size; 
     end;
    end;
    if parentwidget = nil then begin //not docked
     fmodulepos:= translatewidgetpoint(rect1.pos,self,nil);
    end;
    domodified();
   end;
  end;
  fde_scrolled: begin
   fselections.change();
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

procedure tformdesignerfo.checksynctoformsize();
begin
 if (fparentwidget = nil) and (fds_loaded in ffostate) then begin
  if fform <> nil then begin
   fformcont.size:= fform.size;   //not docked
   paintsize:= fformcont.size;
  end
  else begin
   paintsize:= getmodulesize();
  end;
 end;
end;

procedure tformdesignerfo.checksynctomodulepos();
begin
 if (fparentwidget = nil) and (fds_loaded in ffostate) then begin
  if fform <> nil then begin
   pos:= translatewidgetpoint(fmodulepos,fform.parentwidget,self);
  end
  else begin
   pos:= translatewidgetpoint(fmodulepos,fscrollbox,self);
  end;
 end;
end;

procedure tformdesignerfo.updateformcont();
var
 si1: sizety;

 function updatesi(const source: sizety): sizety;
 begin
  result:= source;
  if result.cx <> 0 then begin
   inc(result.cx,si1.cx);
  end;
  if result.cy <> 0 then begin
   inc(result.cy,si1.cy);
  end;
 end; //updatesi

begin
 if (fparentwidget = nil) and (form <> nil) then begin
  si1:= framedim;
  minsize:= updatesi(form.minsize);
  maxsize:= updatesi(form.maxsize);
 end
 else begin
  minsize:= nullsize;
  maxsize:= nullsize;
 end;
 fformcont.widgetrect:= paintrect;
end;

procedure tformdesignerfo.formcontainerwidgetregionchanged(
                                                   const sender: twidget);
begin 
 if (fform <> nil) and (sender = fform) and 
        not(ws1_anchorsizing in fform.widgetstate1) and 
        not (csdestroying in fform.componentstate) and
        not (csdestroying in componentstate) then begin
  checksynctoformsize();
 end;
end;

procedure tformdesignerfo.parentchanged();
begin
 inherited;
// checksynctoformsize();
 updateformcont();
 updatedockinfo();
end;

procedure tformdesignerfo.beffloatexe(const sender: twidget;
               var arect: rectty);
begin
 inc(fmodulesetting);
 visible:= false;
end;

procedure tformdesignerfo.floatexe(const sender: TObject);
begin
 checksynctoformsize();
 if fform <> nil then begin
  pos:= translatewidgetpoint(fmodulepos,fform.parentwidget,self);
 end
 else begin
  pos:= translatewidgetpoint(fmodulepos,fscrollbox,self);
 end;
 visible:= true;
 dec(fmodulesetting);
end;

procedure tformdesignerfo.clientrectchanged();
 
begin
 inherited;
 updateformcont();
 if not (ws_loadedproc in widgetstate) and (fmodulesetting = 0) and
            (ffostate * [fds_sizesyncing,fds_loaded] = [fds_loaded]) then begin
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
 rect1: rectty;
begin
 beginplacement;
 try
  name:= '_'+fmodule.name;
  if fmodule is twidget then begin
   fmodulepos:= twidget(fmodule).pos;
   setlinkedvar(fmodule,tmsecomponent(fform));
   rect1:= getdesignrect;
   widgetrect:= inflaterect(rect1,frame.paintframe);
   twidget(fmodule).parentwidget:= getmoduleparent;
   twidget(fmodule).pos:= nullpoint;
   twidget(fmodule).taborder:= 0;
  end
  else begin
   fform:= nil;
   fmodulepos:= getcomponentpos(fmodule);
   widgetrect:= inflaterect(modulerect,frame.paintframe);
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
 designer.showobjectinspector;
// objectinspectorfo.activate;
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
   ar2:= designer.descendentinstancelist.getancestorsandchildren(amodule^.instance);
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
// with tdesignwindow(window) do begin
  try
   rea1:= 1.0;
   if component is tmsecomponent then begin
    with fmoduleintf^ do begin
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
// end;
end;

procedure tformdesignerfo.doinsertsubmodule(const sender: tobject);
var
 comp: tmsecomponent;
 po1: pmoduleinfoty;
begin
 po1:= selectinheritedmodule(fdesigner.modules.findmodulebyinstance(module));
 if po1 <> nil then begin
  comp:= fdesigner.copycomponent(po1^.instance,po1^.instance,false,false);
  initinline(comp);
  comp.name:= po1^.instance.name;
  fdesigner.addancestorinfo(comp,po1^.instance);
//  with tdesignwindow(window) do begin
   doaddcomponent(comp);
   placecomponent(comp,fmousepos,fselections[0]);
//  end;
 end;
end;

procedure tformdesignerfo.doinsertcomponent(const sender: TObject);
var
 comp1: tcomponent;
begin
 comp1:= fdesigner.createcurrentcomponent(module);
// with tdesignwindow(window) do begin
  placecomponent(comp1,fmousepos,fselections[0]);
// end;  
end;

procedure tformdesignerfo.dotouch(const sender: TObject);
begin
 fdesigner.touch(fmodule);
// tdesignwindow(window).domodified;
end;

procedure tformdesignerfo.touchallexe(const sender: TObject);
begin
 if askconfirmation(c[ord(sc_touchall)]) then begin
  fdesigner.touchall;
 end;
end;

procedure tformdesignerfo.dobringtofront(const sender: tobject);
begin
// with tdesignwindow(window) do begin
  twidget(fselections[0]).bringtofront;
  domodified;
// end;
end;

procedure tformdesignerfo.dosendtoback(const sender: tobject);
begin
// with tdesignwindow(window) do begin
  twidget(fselections[0]).sendtoback;
  domodified;
// end;
end;

procedure tformdesignerfo.doiconify(const sender: TObject);
var
 int1: integer;
begin
// with tdesignwindow(window) do begin
  for int1:= 0 to fselections.count - 1 do begin
   with tmsedatamodule(fselections[int1]) do begin
    options:= options + [dmo_iconic];
   end;
  end;
// end;
end;

procedure tformdesignerfo.dodeiconify(const sender: TObject);
var
 int1: integer;
begin
// with tdesignwindow(window) do begin
  for int1:= 0 to fselections.count - 1 do begin
   with tmsedatamodule(fselections[int1]) do begin
    options:= options - [dmo_iconic];
   end;
  end;
// end;
end;

procedure tformdesignerfo.dosettaborder(const sender: tobject);
var
 fo: tsettaborderfo;
begin
// with tdesignwindow(window) do begin
  fo:= tsettaborderfo.create(twidget(fselections.items[0]),fdesigner);
  try
   fo.show(true,window);
  finally
   fo.Free;
  end;
// end;
end;

procedure tformdesignerfo.dosetcreationorder(const sender: TObject);
var
 fo: tsetcreateorderfo;
 str1: string;
 comp1: tcomponent;
begin
// with tdesignwindow(window) do begin
  comp1:= nil;
  str1:= '';
  if (fselections.count = 1) then begin
   comp1:= selections[0].owner;
  end;
  if comp1 = nil then begin
   comp1:= module;
  end
  else begin
   str1:= fselections[0].name;
  end;
// end;
 fo:= tsetcreateorderfo.create(comp1,str1);
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
// with tdesignwindow(window) do begin
  for int1:= 0 to fselections.count - 1 do begin
   comp1:= fselections[int1];
   if comp1 is twidget then begin
    twidget(comp1).synctofontheight;
    fdesigner.componentmodified(comp1);
   end;
  end;
// end;
end;

procedure tformdesignerfo.copyexe(const sender: TObject);
begin
// tdesignwindow(twidget(tmenuitem(sender).owner.owner).window).docopy(false);
 docopy(false);
end;

procedure tformdesignerfo.pasteexe(const sender: TObject);
begin
// tdesignwindow(twidget(tmenuitem(sender).owner.owner).window).dopaste(true,'');
 dopaste(true,'');
end;

procedure tformdesignerfo.deleteexe(const sender: TObject);
begin
// tdesignwindow(twidget(tmenuitem(sender).owner.owner).window).dodelete;
 dodelete();
end;

procedure tformdesignerfo.undeleteexe(const sender: TObject);
begin
// tdesignwindow(twidget(tmenuitem(sender).owner.owner).window).doundelete;
 doundelete();
end;

procedure tformdesignerfo.cutexe(const sender: TObject);
begin
// tdesignwindow(twidget(tmenuitem(sender).owner.owner).window).docut;
 docut();
end;

procedure tformdesignerfo.setcomponentscrollsize(const avalue: sizety);
begin
 if fform is tcustommseform then begin
{$warnings off}
  with tscrollingwidget1(tcustommseform(fform).container) do begin
{$warnings on}
   fminminclientsize:= avalue;
   clientsize:= clientsize;
  end;
 end;
end;

procedure tformdesignerfo.calcscrollsize(const sender: tscrollingwidgetnwr;
               var asize: sizety);
var
 size1: sizety;
begin
 size1:= componentscrollsize();
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
 if (fform = nil) or not fformcont.visible then begin
{$warnings off}
  with twidget1(container) do begin
{$warnings on}
   exclude(fwidgetstate,ws_minclientsizevalid);
   tframe1(frame).updatestate;
  end;
 end
 else begin
  setcomponentscrollsize(componentscrollsize);
 end;
end;

procedure tformdesignerfo.formdeonclose(const sender: TObject);
var
 int1: integer;
 bo1: boolean;
begin
 with {tdesignwindow(window),}fselections do begin
  bo1:= false;
  for int1:= count - 1 downto 0 do begin
   if (items[int1] = fmodule) or (items[int1].owner = fmodule) then begin
    delete(int1);
    bo1:= true;
   end;
  end;
  if bo1 then begin
   updateselections;
  end;
 end;
end;

procedure tformdesignerfo.revertexe(const sender: TObject);
begin
 if askok(c[ord(sc_wishrevert)]+lineend+c[ord(sc_selectedcomp)]) then begin
  fdesigner.revert(fselections[0]);
  objectinspectorfo.refresh;
 end;
end;

function tformdesignerfo.insertoffset: pointty;
begin
 if (form = nil) or not fformcont.visible then begin
  result:= container.clientpos;
 end
 else begin
  result:= translateclientpoint(nullpoint,form.container,form);
  addpoint1(result,form.paintpos);
  addpoint1(result,fformcont.clientpos);
 end;
end;

function tformdesignerfo.gridoffset: pointty;
begin
 result:= insertoffset;
end;

function tformdesignerfo.gridrect: rectty;
begin
 if (form = nil) or hidewidgetact.checked then begin
  result:= container.paintrect;
 end
 else begin
  result:= form.container.paintrect;
  translatewidgetpoint1(result.pos,form.container,self);
//  subpoint1(result.pos,fformcont.clientpos);
 end;
end;

function tformdesignerfo.widgetrefpoint: pointty;
begin
 if form = nil then begin
  result:= paintpos;
 end
 else begin
  result:= translatewidgetpoint(form.container.pos,form.container,self);
//  result:= form.container.rootpos;
 end;
end;

function tformdesignerfo.compplacementrect: rectty;
begin
 if form = nil then begin
  result:= container.clientrect;
 end
 else begin
  result:= form.container.clientwidgetrect;
  translatewidgetpoint1(result.pos,form.container,self);
//  addpoint1(result.pos,form.container.rootpos);
 end;
end;

function tformdesignerfo.getmoduleparent: twidget;
begin
// result:= self;
 result:= fformcont;
 fscrollbox.visible:= false;
end;

procedure tformdesignerfo.componentselected(const aselections: tformdesignerselections);
begin
 //dummy
end;

procedure tformdesignerfo.beginstreaming;
var
 pt1: pointty;
begin
 pt1:= modulerect.pos; //screen pos
 if fmodule is twidget then begin
  twidget1(fmodule).fwidgetrect.pos:= pt1;
 end
 else begin
  setcomponentpos(fmodule,pt1);
 end;
 if fform is tcustommseform then begin
  tcustommseform(fform).container.frame.scrollpos:= nullpoint;
 end;
 fformcont.frame.scrollpos:= nullpoint;
end;

procedure tformdesignerfo.endstreaming;
begin
 if fmodule is twidget then begin
  with twidget1(fmodule) do begin
   fwidgetrect.pos:= paintpos;
   rootchanged(true);
  end;
 end;
end;

function tformdesignerfo.candelete(const acomponent: tcomponent): boolean;
begin
 result:= true;
end;
{
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
}
procedure tformdesignerfo.componentmoving(const apos: pointty);
begin
 //dummy
end;

function tformdesignerfo.getselections: tformdesignerselections;
begin
 result:= fselections;
end;
{
procedure tformdesignerfo.deletecomponent(const comp: tcomponent);
begin
 with tdesignwindow(fwindow) do begin
  fselections.clear;
  fselections.add(comp);
  dodelete;
 end;
end;
}
function tformdesignerfo.clickedcomponent: tcomponent;
begin
 result:= nil;
// with tdesignwindow(fwindow) do begin
  if (factcompindex >= 0) and (factcompindex < fselections.count) then begin
   result:= fselections[factcompindex];
  end;
// end;
end;

procedure tformdesignerfo.setmoduleoptions(const aoptions: moduleoptionsty);
var
 changes: moduleoptionsty;
begin
 if fform <> nil then begin
 {$ifdef FPC}
  changes:= aoptions><fmoduleoptions;
 {$else}
  changes:= moduleoptionsty(byte(aoptions) xor byte(fmoduleoptions));
 {$endif}
  if changes <> [] then begin
   fmoduleoptions:= aoptions;
   hidewidgetact.checked:= mo_hidewidgets in aoptions;
   hidecompact.checked:= mo_hidecomp in aoptions;
   updatecaption;
   if mo_hidecomp in changes then begin
    clientrectchanged;
    if mo_hidecomp in fmoduleoptions then begin
     designer.noselection;
    end;
   end;
   if mo_hidewidgets in changes then begin
    if mo_hidewidgets in fmoduleoptions then begin
     designer.noselection;
     fscrollbox.visible:= true;
    end
    else begin
     fscrollbox.visible:= false;
    end;
    fformcont.visible:= not fscrollbox.visible;
   end;  
  end;
 end;
end;

procedure tformdesignerfo.hidecompexe(const sender: TObject);
begin
 clientrectchanged;
 if hidecompact.checked then begin
  moduleoptions:= moduleoptions + [mo_hidecomp];
 end
 else begin
  moduleoptions:= moduleoptions - [mo_hidecomp];
 end;
end;

procedure tformdesignerfo.hidewidgetexe(const sender: TObject);
begin
 if hidewidgetact.checked then begin
  moduleoptions:= moduleoptions + [mo_hidewidgets];
 end
 else begin
  moduleoptions:= moduleoptions - [mo_hidewidgets];
 end;
end;

procedure tformdesignerfo.updatewidgethideexe(const sender: tcustomaction);
begin
 hidecompact.enabled:= fform <> nil;
 hidewidgetact.enabled:= fform <> nil;
 togglehideact.enabled:= fform <> nil;
 showallact.enabled:= fform <> nil;
end;

function tformdesignerfo.getmoduleoptions: moduleoptionsty;
begin
 result:= fmoduleoptions;
end;

procedure tformdesignerfo.togglehideexe(const sender: TObject);
begin
 if hidewidgetact.checked then begin
  if hidecompact.enabled then begin
   hidecompact.checked:= true;
  end;
  hidewidgetact.checked:= false;
 end
 else begin
  if hidecompact.checked then begin
   if hidewidgetact.enabled then begin
    hidewidgetact.checked:= true;
   end;
   hidecompact.checked:= false;
  end
  else begin
   if hidecompact.enabled then begin
    hidecompact.checked:= true;
   end;
  end;
 end;
end;

procedure tformdesignerfo.showallexe(const sender: TObject);
begin
 moduleoptions:= moduleoptions - [mo_hidewidgets,mo_hidecomp];
end;

function tformdesignerfo.filterfindcomp(
                                 const acomponent: tcomponent): boolean;
begin
 result:= not (cssubcomponent in acomponent.componentstyle) and
          (not (acomponent is twidget) or 
                (ws_iswidget in twidget(acomponent).widgetstate));
end;

procedure tformdesignerfo.findcompdialog;
var
 name1: msestring;
begin
 name1:= '';
// with tdesignwindow(fwindow) do begin
  if fselections.count > 0 then begin
   name1:= ownernamepath(fselections[0]);
  end;
  if compnamedialog(designer.getcomponentnametree(nil,true,true,nil,
                      @filterfindcomp,fmodule),name1,true) = mr_ok then begin
   if name1 = fmodule.name then begin
    designer.selectcomponent(fmodule);
   end
   else begin
    replacechar1(name1,':','.');
    designer.selectcomponent(
      designer.modules.findmodule(fmodule)^.components.getcomponent(name1,
                                                                        true));
   end;
  end;
// end;
end;

function tformdesignerfo.getsnaptogrid: boolean;
begin
 result:= fsnaptogrid;
end;

function tformdesignerfo.getshowgrid: boolean;
begin
 result:= fshowgrid;
end;

function tformdesignerfo.getgridsizex: integer;
begin
 result:= fgridsizex;
end;

function tformdesignerfo.getgridsizey: integer;
begin
 result:= fgridsizey;
end;

procedure tformdesignerfo.designmouseevent(var info: moeventinfoty;
                                                         capture: twidget);
var
 mousepos1: pointty;

 function griddelta: pointty;
 begin
  result:= snaptogriddelta(subpoint(mousepos1,fpickpos));
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
    mousepos1.x:= fpickpos.x;
//    info.mouse.pos.x:= fpickpos.x;
   end;
   ht_left,ht_right: begin
    mousepos1.y:= fpickpos.y;
  //  info.mouse.pos.y:= fpickpos.y;
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
 bo1,bo2: boolean;
// posbefore: pointty;
 widget1: twidget;
 rect1: rectty;
 selectmode: selectmodety;
 area1: areaty;
 isinpaintrect: boolean;
 ss1: shiftstatesty;
 po1: pformselectedinfoty;
 pt1: pointty; 
label
 1;
begin
 if module = nil then begin
  exit; //continue nornal handling
 end;
 if info.mouse.eventkind in [ek_mouseleave,ek_mouseenter] then begin
  fclickedcompbefore:= nil;
  include(info.mouse.eventstate,es_processed);
  exit;
 end;
 twindow1(window).checkmousewidget(info.mouse,capture);
 with info.mouse do begin
  mousepos1:= translatewidgetpoint(pos,window.owner,self);
  ss1:= shiftstate * shiftstatesmask;
  isinpaintrect:= pointinrect(mousepos1,gridrect);
//  posbefore:= pos;
  if eventkind in [ek_buttonpress,ek_buttonrelease] then begin
   fmousepos:= mousepos1;
  end;
  component:= nil;
  if not (es_processed in eventstate) then begin
   bo1:= false;
   if (eventkind = ek_buttonpress) and (button = mb_left) then begin
    fpickpos:= mousepos1;
    if (ss1 = [ss_left]) or (ss1 = [ss_left,ss_ctrl]) or 
                (ss1 = [ss_left,ss_ctrl,ss_shift]) or
                (ss1 = [ss_left,ss_double]) then begin
     factarea:= fselections.getareainfo(mousepos1,factcompindex);
     if factcompindex >= 0 then begin
      fsizerect:= fselections.itempo(factcompindex)^.rect;
      factsizerect:= fsizerect;
     end;
     if (factarea in [ar_component,ar_none]) and 
                                     not (ss_shift in ss1) then begin
      if isinpaintrect then begin
       component:= componentatpos(mousepos1);
       if (component = nil) then begin
        if (form <> nil) and 
                 not hidewidgetact.checked then begin
         component:= widgetatpos(mousepos1,true);
        end
        else begin
         component:= module;
        end;
       end;
      end;
      if component <> nil then begin
       if (factcompindex < 0) or 
                       (component <> fselections[factcompindex]) then begin
        factarea:= ar_none;
       end;
       bo1:= true;
       if ss_ctrl in ss1 then begin
        selectcomponent(component,sm_flip);
       end
       else begin
        bo2:= fselections.indexof(component) < 0;
        if (component = form) and (fselections.count > 1) or bo2 then begin
         selectcomponent(component,sm_select);
         if projectoptions.e.moveonfirstclick then begin
          factarea:= ar_component;
         end;
        end
        else begin
         if not bo2 then begin
          updateclickedcomponent;
         end;
        end;
        {
        if ss_double in shiftstate then begin
         designer.showobjectinspector;
        end;
        }
       end;
      end
      else begin
       factarea:= ar_none;
      end;
      fclickedcompbefore:= component;
     end
     else begin
      capturemouse;
      include(eventstate,es_processed);
     end;
    end
   end;
   if (eventkind = ek_buttonrelease) and (button = mb_right) and
           not (es_processed in eventstate) then begin
    dopopup(info.mouse);
   end;
   if not (es_processed in eventstate) then begin
    area1:= fselections.getareainfo(mousepos1,int1);
    if ((area1 < firsthandle) or (area1 > lasthandle)) and
       ((factarea < firsthandle) or (factarea > lasthandle)) and 
       not ((fdesigner.hascurrentcomponent or componentstorefo.hasselection) and 
                     (eventkind = ek_buttonpress) and 
       (button = mb_left) and (ss1 = [ss_left])) and 
       not ((area1 = ar_component) and 
           not((fselections[int1] is twidget) or 
               isdatasubmodule(fselections[int1]))) and 
       (factarea <> ar_componentmove) then begin
     twindow1(window).dispatchmouseevent(info,capture); //"inherited"
    end;
//    pos:= posbefore;
    if bo1 then begin
     if not (es_processed in eventstate) then begin
      if (capture = nil) or not 
             (ws1_designactive in twidget1(capture).fwidgetstate1) then begin
       capturemouse; //capture mouse
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
       if (component = nil) and componentstorefo.hasselection then begin
        dopaste(true,componentstorefo.copyselected);
       end;
      end;
      if component <> nil then begin
       placecomponent(component,mousepos1);
      end;
     end
     else begin
      if (ss1 = [ss_left,ss_shift]) and isinpaintrect then begin
       factarea:= ar_selectrect;
       fxorpicoffset:= mousepos1;
       if form <> nil then begin
        fpickwidget:= widgetatpos(mousepos1,false);
       end
       else begin
        fpickwidget:= self;
       end;
      end;
     end;
    end;
    if (eventkind = ek_buttonrelease) and (button = mb_left) then begin
     hidexorpic(container.getcanvas(org_widget));
     fxorpicactive:= false;
     case factarea of
      firsthandle..lasthandle: begin
       if (factcompindex >= 0) and (factcompindex < fselections.count) then begin
        component:= tcomponent(
                     fselections.itempo(factcompindex)^.selectedinfo.instance);
        if (component is twidget) and (form <> nil) then begin
         with twidget(component) do begin
          translatewidgetpoint1(factsizerect.pos,self,parentwidget);
//          subpoint1(factsizerect.pos,parentwidget.rootpos);
          widgetrect:= factsizerect;
         end;
         fselections.componentschanged;
        end
        else begin
         if component is tmsedatamodule then begin
          rect1:= getcomponentrect1(component);          
          with tmsedatamodule(component) do begin
           subpoint1(factsizerect.pos,rect1.pos);
//////           subpoint1(factsizerect.pos,parentwidget.rootpos);
           setcomponentpos(component,
                addpoint(getcomponentpos(component),factsizerect.pos));
           size:= factsizerect.size;
          end;
          fselections.componentschanged;
         end;
        end;
       end;
       invalidate();
      end;
      ar_componentmove: begin
       if fselections.move(griddelta) then begin
        invalidate(); //redraw handles
        clientsizechanged;
       end;
      end;
      ar_component: begin
       if ss_double in shiftstate then begin
        designer.showobjectinspector;
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
         if fpickwidget <> self then begin
          rect1.pos:= translatewidgetpoint(fpickpos,self,
                                        fpickwidget.parentwidget);
//          rect1.pos:= subpoint(fpickpos,fpickwidget.rootpos);
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
     if factcompindex >= 0 then begin
      factcompindex:= -1;
      updateclickedcomponent; //update objectionspector componentname
     end;
     releasemouse();
    end;
 
    if not (es_processed in eventstate) then begin
     if (eventkind = ek_mousemove) or (eventkind = ek_mousepark) then begin
      hidexorpic(getcanvas(org_widget));
      bo1:= true;
      case factarea of
       firsthandle..lasthandle: begin
        updatesizerect;
       end;
       ar_component: begin
        if distance(fpickpos,mousepos1) > movethreshold then begin
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
        fxorpicoffset:= mousepos1;
       end;
       else begin
        bo1:= false;
        updatecursorshape(fselections.getareainfo(mousepos1,int1));
       end;
      end;
      if bo1 then begin
       fxorpicactive:= true;
       if factarea <> ar_component then begin
        fselections.beforepaintmoving; //resets canvas
       end;
       showxorpic(container.getcanvas(org_widget));
      end;
     end;
    end;
   end;
  end;
1:
  if (eventkind in mouseposevents) and (fselections.count = 1) then begin
   fselections.updateinfos;
   po1:= fselections.itempo(0);
   if po1^.selectedinfo.instance <> fmodule then begin
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
     componentmoving(pt1);
    end;
   end;
  end;
 end;
 include(info.mouse.eventstate,es_processed);
end;

procedure tformdesignerfo.designkeyevent(const eventkind: eventkindty;
               var info: keyeventinfoty);
var
 po1: pointty;
 comp1: tcomponent;
 shiftstate1: shiftstatesty;
 actareabefore: areaty;
begin
 if module = nil then begin
  exit;
 end;
 shiftstate1:= info.shiftstate * keyshiftstatesmask;
 if eventkind = ek_keypress then begin
  with info do begin
   if shiftstate1 = [] then begin
    include(eventstate,es_processed);
    case key of
     key_return: begin
      if not designer.editcomponent(module) then begin
       exclude(eventstate,es_processed);
      end;
     end;
     key_escape: begin
      if not (factarea in [ar_none,ar_component]) then begin
       hidexorpic(container.getcanvas(org_widget));
       fxorpicactive:= false;
       factarea:= ar_none;
      end
      else begin      
       if (fselections.count > 1) and (factarea <> ar_component) then begin
        selectcomponent(module);
       end
       else begin
        if fselections.count > 0 then begin
         if factarea = ar_component then begin
          comp1:= fselections[factcompindex];
         end
         else begin
          comp1:= fselections[0];
         end;
         if iswidgetcomp(comp1) then begin
          repeat
           comp1:= twidget(comp1).parentwidget;
          until (comp1 = nil) or (ws_iswidget in twidget(comp1).widgetstate);
          actareabefore:= factarea;
          if (comp1 <> nil) and (comp1 <> self) then begin
           if fselections.count > 1 then begin
            selectparentwidget(twidget(comp1));
           end
           else begin
            selectcomponent(comp1);
           end;
          end
          else begin
           selectcomponent(module);
          end;
          factarea:= actareabefore;
         end
         else begin
//          if isdatasubmodule(comp1.owner) then begin
           selectcomponent(comp1.owner);
//          end
//          else begin
//           selectcomponent(module);
//          end;
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
    if (shiftstate1 = [ss_ctrl]) or (shiftstate1 = [ss_shift]) then begin
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
      if shiftstate1 = [ss_ctrl] then begin
       fselections.move(po1);
       if fselections.count > 0 then begin
        fselections.updateinfos;
        componentmoving(rectcenter(fselections.itempo(0)^.handles[ht_topleft]));
       end;
      end
      else begin
       fselections.resize(po1);
       if fselections.count > 0 then begin
        fselections.updateinfos;
        with fselections.itempo(0)^.handles[ht_bottomright] do begin
         componentmoving(makepoint(x+cx div 2 + 1,y+cy div 2 +1));
        end;
       end;
      end;
      invalidate();
      clientsizechanged();
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
       dopaste(false,'');
       include(eventstate,es_processed);
      end;
     end;
    end;
   end;
  end;
 end;
end;

function tformdesignerfo.isdesignwidget(): boolean;
begin
 result:= true;
end;

function tformdesignerfo.getmodulesize: sizety;
var
 asize: sizety;
 int1: integer;
 pt1: pointty;
begin
 if fform <> nil then begin
  result:= fform.size;
 end
 else begin
  if fmodule is tmsedatamodule then begin
   result:= tmsedatamodule(fmodule).size;
  end
  else begin
   asize:= nullsize;
   for int1:= 0 to fmodule.ComponentCount - 1 do begin
    pt1:= getcomponentpos(fmodule.Components[int1]);
    if pt1.x > asize.cx then begin
     asize.cx:= pt1.x;
    end;
    if pt1.y > asize.cy then begin
     asize.cy:= pt1.y;
    end;
   end;
   inc(asize.cx,80);
   inc(asize.cy,30); //todo: correct size, scrollbox
   result:= asize;
  end;
 end;
end;

function tformdesignerfo.getmodulerect: rectty;
begin
 result.pos:= fmodulepos;
 result.size:= getmodulesize();
end;

function tformdesignerfo.getmodulepos_x: integer;
begin
 result:= fmodulepos.x;
end;

function tformdesignerfo.getmodulepos_y: integer;
begin
 result:= fmodulepos.y;
end;

procedure tformdesignerfo.setmodulepos_x(const avalue: integer);
begin
 if fmodulepos.x <> avalue then begin
  fmodulepos.x:= avalue;
  checksynctomodulepos();
 end;
end;

procedure tformdesignerfo.setmodulepos_y(const avalue: integer);
begin
 if fmodulepos.y <> avalue then begin
  fmodulepos.y:= avalue;
  checksynctomodulepos();
 end;
end;

function tformdesignerfo.getdockcontroller(): tdockcontroller;
begin
 result:= dragdock;
end;

procedure tformdesignerfo.updatedockinfo();
begin
 with fmoduleinfo^.dockinfo do begin
  panelname:= dragdock.dockparentname();
  rect:= widgetrect;
 end;
end;

initialization
finalization
 freeandnil(fregistereddesignmoduleclasses);
end.
