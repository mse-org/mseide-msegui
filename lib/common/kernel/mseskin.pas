{ MSEgui Copyright (c) 2008 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseskin;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 classes,mseclasses,msegui,msescrollbar,mseedit,msegraphics,msegraphutils,
 msetabs,msedataedits,msemenus,msearrayprops;
type
 beforeskinupdateeventty = procedure(const sender: tobject; 
                const ainfo: skininfoty; var handled: boolean) of object;

 skinmenuoptionty = (smo_noanim);
 skinmenuoptionsty = set of skinmenuoptionty;
 
 scrollbarskininfoty = record
  facebu: tfacecomp;
  faceendbu: tfacecomp;
  framebu: tframecomp;
  frameendbu1: tframecomp;
  frameendbu2: tframecomp;
 end;
 widgetskininfoty = record
  fa: tfacecomp;
  fra: tframecomp;
 end;
 buttonskininfoty = record
  wi: widgetskininfoty;
  font: toptionalfont;
 end;  
 framebuttonskininfoty = record
  fa: tfacecomp;
  fra: tframecomp;
 end;
 tabsskininfoty = record
  color: colorty;
  coloractive: colorty;
  face: tfacecomp;
  faceactive: tfacecomp;
 end;
 tabbarskininfoty = record
  wihorz: widgetskininfoty;
  wivert: widgetskininfoty;
  tahorz: tabsskininfoty;
  tavert: tabsskininfoty;
 end;
 menuskininfoty = record
  face: tfacecomp;
  frame: tframecomp;
  itemface: tfacecomp;
  itemframe: tframecomp;
  itemfaceactive: tfacecomp;
  itemframeactive: tframecomp;
  options: skinmenuoptionsty;
 end;  
 mainmenuskininfoty = record
  ma: menuskininfoty;
  pop: menuskininfoty;
 end;
 dataeditskininfoty = record
  color: colorty;
  face: tfacecomp;
  frame: tframecomp;
 end;
 
 tskincolor = class(tvirtualpersistent)
  private
   fcolor: colorty;
   frgb: colorty;
   frgbbefore: colorty;
  public
   constructor create; override;
  published
   property color: colorty read fcolor write fcolor default cl_none;
   property rgb: colorty read frgb write frgb;
 end;
 
 tskincolors = class(tpersistentarrayprop)
  public
   constructor create;
   procedure setcolors;
   procedure restorecolors;
 end;
  
//todo: controller chain for custom components

 tcustomskincontroller = class(tmsecomponent)
  private
   fonbeforeupdate: beforeskinupdateeventty;
   fonafterupdate: skinobjecteventty;
   factive: boolean;
   fonactivate: notifyeventty;
   fondeactivate: notifyeventty;
   fcolors: tskincolors;
   procedure setactive(const avalue: boolean);
   procedure setcolors(const avalue: tskincolors);
  protected
   procedure doactivate; virtual;
   procedure dodeactivate; virtual;
   procedure loaded; override;
   
   procedure setwidgetface(const instance: twidget; const aface: tfacecomp);
   procedure setwidgetframe(const instance: twidget; const aframe: tframecomp);
   procedure setwidgetframetemplate(const instance: twidget;
                            const aframe: tframecomp); //no fram nil check
   procedure setwidgetskin(const instance: twidget;
                                            const ainfo: widgetskininfoty);
   procedure setdataeditskin(const instance: tdataedit;
                                            const ainfo: dataeditskininfoty);
   procedure setwidgetfont(const instance: twidget; const afont: tfont);
   procedure setwidgetcolor(const instance: twidget; const acolor: colorty);
   procedure setscrollbarskin(const instance: tcustomscrollbar; 
                const ainfo: scrollbarskininfoty);
   procedure setframebuttonskin(const instance: tframebutton;
                const ainfo: framebuttonskininfoty);
   procedure settabsskin(const instance: tcustomtabbar;
                                        const ainfo: tabsskininfoty);
   procedure setpopupmenuskin(const instance: tpopupmenu;
                                    const ainfo: menuskininfoty);
   procedure setmainmenuskin(const instance: tcustommainmenu;
         const ainfo: mainmenuskininfoty);

   procedure handlewidget(const sender: twidget; 
                const ainfo: skininfoty); virtual;
   procedure handlecontainer(const sender: twidget; 
                const ainfo: skininfoty); virtual;
   procedure handlesimplebutton(const sender: twidget;
                const ainfo: skininfoty); virtual;
   procedure handleuserobject(const sender: tobject;
                const ainfo: skininfoty); virtual;
   procedure handletabbar(const sender: tcustomtabbar;
                           const ainfo: skininfoty); virtual;
   procedure handleedit(const sender: tedit;
                           const ainfo: skininfoty); virtual;
   procedure handledataedit(const sender: tdataedit;
                           const ainfo: skininfoty); virtual;
   procedure handlemainmenu(const sender: tcustommainmenu;
                           const ainfo: skininfoty); virtual;
   procedure handlepopupmenu(const sender: tpopupmenu;
                           const ainfo: skininfoty); virtual;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure updateskin(const instance: tobject; const ainfo: skininfoty);
  published
   property active: boolean read factive write setactive;
   property onbeforeupdate: beforeskinupdateeventty read fonbeforeupdate
                                 write fonbeforeupdate;
   property onafterupdate: skinobjecteventty read fonafterupdate
                                 write fonafterupdate;
   property onactivate: notifyeventty read fonactivate write fonactivate;
   property ondeactivate: notifyeventty read fondeactivate write fondeactivate;
   property colors: tskincolors read fcolors write setcolors;
 end;

 tskincontroller = class(tcustomskincontroller)
  private
   fsb_horz: scrollbarskininfoty;
   fsb_vert: scrollbarskininfoty;
   fbutton: buttonskininfoty;
   fframebutton: framebuttonskininfoty;
   fcontainer_face: tfacecomp;
   fwidget_color: colorty;
   ftabbar: tabbarskininfoty;
   fpopupmenu: menuskininfoty;
   fmainmenu: mainmenuskininfoty;
   fdataedit: dataeditskininfoty;
   
   procedure setsb_vert_facebutton(const avalue: tfacecomp);
   procedure setsb_vert_faceendbutton(const avalue: tfacecomp);
   procedure setsb_vert_framebutton(const avalue: tframecomp);
   procedure setsb_vert_frameendbutton1(const avalue: tframecomp);
   procedure setsb_vert_frameendbutton2(const avalue: tframecomp);
   procedure setsb_horz_facebutton(const avalue: tfacecomp);
   procedure setsb_horz_faceendbutton(const avalue: tfacecomp);
   procedure setsb_horz_framebutton(const avalue: tframecomp);
   procedure setsb_horz_frameendbutton1(const avalue: tframecomp);
   procedure setsb_horz_frameendbutton2(const avalue: tframecomp);
   procedure setbutton_face(const avalue: tfacecomp);
   procedure setbutton_frame(const avalue: tframecomp);
   function getbutton_font: toptionalfont;
   procedure setbutton_font(const avalue: toptionalfont);
   procedure setframebutton_face(const avalue: tfacecomp);
   procedure setframebutton_frame(const avalue: tframecomp);

   procedure setdataedit_face(const avalue: tfacecomp);
   procedure setdataedit_frame(const avalue: tframecomp);

   procedure setcontainer_face(const avalue: tfacecomp);

   procedure settabbar_horz_face(const avalue: tfacecomp);
   procedure settabbar_horz_frame(const avalue: tframecomp);
   procedure settabbar_horz_tab_face(const avalue: tfacecomp);
   procedure settabbar_horz_tab_faceactive(const avalue: tfacecomp);
   procedure settabbar_vert_face(const avalue: tfacecomp);
   procedure settabbar_vert_frame(const avalue: tframecomp);
   procedure settabbar_vert_tab_face(const avalue: tfacecomp);
   procedure settabbar_vert_tab_faceactive(const avalue: tfacecomp);

   procedure setpopupmenu_face(const avalue: tfacecomp);
   procedure setpopupmenu_frame(const avalue: tframecomp);
   procedure setpopupmenu_itemface(const avalue: tfacecomp);
   procedure setpopupmenu_itemframe(const avalue: tframecomp);
   procedure setpopupmenu_itemfaceactive(const avalue: tfacecomp);
   procedure setpopupmenu_itemframeactive(const avalue: tframecomp);
   
   procedure setmainmenu_face(const avalue: tfacecomp);
   procedure setmainmenu_frame(const avalue: tframecomp);
   procedure setmainmenu_itemface(const avalue: tfacecomp);
   procedure setmainmenu_itemframe(const avalue: tframecomp);
   procedure setmainmenu_itemfaceactive(const avalue: tfacecomp);
   procedure setmainmenu_itemframeactive(const avalue: tframecomp);
   procedure setmainmenu_popupface(const avalue: tfacecomp);
   procedure setmainmenu_popupframe(const avalue: tframecomp);
   procedure setmainmenu_popupitemface(const avalue: tfacecomp);
   procedure setmainmenu_popupitemframe(const avalue: tframecomp);
   procedure setmainmenu_popupitemfaceactive(const avalue: tfacecomp);
   procedure setmainmenu_popupitemframeactive(const avalue: tframecomp);
  protected
   procedure handlewidget(const sender: twidget; 
                                  const ainfo: skininfoty); override;
   procedure handlecontainer(const sender: twidget; 
                                  const ainfo: skininfoty); override;
   procedure handlesimplebutton(const sender: twidget; 
                                  const ainfo: skininfoty); override;
   procedure handletabbar(const sender: tcustomtabbar;
                                  const ainfo: skininfoty); override;
   procedure handleedit(const sender: tedit;
                           const ainfo: skininfoty); override;
   procedure handledataedit(const sender: tdataedit;
                           const ainfo: skininfoty); override;
   procedure handlemainmenu(const sender: tcustommainmenu;
                           const ainfo: skininfoty); override;
   procedure handlepopupmenu(const sender: tpopupmenu;
                           const ainfo: skininfoty); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure createbutton_font;
  published
   property sb_horz_facebutton: tfacecomp read fsb_horz.facebu 
                        write setsb_horz_facebutton;
   property sb_horz_faceendbutton: tfacecomp read fsb_horz.faceendbu 
                        write setsb_horz_faceendbutton;
   property sb_horz_framebutton: tframecomp read fsb_horz.framebu 
                        write setsb_horz_framebutton;
   property sb_horz_frameendbutton1: tframecomp read fsb_horz.frameendbu1 
                        write setsb_horz_frameendbutton1;
   property sb_horz_frameendbutton2: tframecomp read fsb_horz.frameendbu2
                        write setsb_horz_frameendbutton2;
   property sb_vert_facebutton: tfacecomp read fsb_vert.facebu
                        write setsb_vert_facebutton;
   property sb_vert_faceendbutton: tfacecomp read fsb_vert.faceendbu 
                        write setsb_vert_faceendbutton;
   property sb_vert_framebutton: tframecomp read fsb_vert.framebu 
                        write setsb_vert_framebutton;
   property sb_vert_frameendbutton1: tframecomp read fsb_vert.frameendbu1 
                        write setsb_vert_frameendbutton1;
   property sb_vert_frameendbutton2: tframecomp read fsb_vert.frameendbu2 
                        write setsb_vert_frameendbutton2;

   property widget_color: colorty read fwidget_color 
                        write fwidget_color default cl_default;

   property dataedit_color: colorty read fdataedit.color 
                        write fdataedit.color default cl_default;
   property dataedit_face: tfacecomp read fdataedit.face write setdataedit_face;
   property dataedit_frame: tframecomp read fdataedit.frame 
                        write setdataedit_frame;
                        
   property container_face: tfacecomp read fcontainer_face 
                                              write setcontainer_face;
   property button_face: tfacecomp read fbutton.wi.fa write setbutton_face;
   property button_frame: tframecomp read fbutton.wi.fra write setbutton_frame;
   property button_font: toptionalfont read getbutton_font write setbutton_font;

   property framebutton_face: tfacecomp read fframebutton.fa 
                                              write setframebutton_face;
   property framebutton_frame: tframecomp read fframebutton.fra 
                                              write setframebutton_frame;

   property tabbar_horz_face: tfacecomp read ftabbar.wihorz.fa write settabbar_horz_face;
   property tabbar_horz_frame: tframecomp read ftabbar.wihorz.fra write settabbar_horz_frame;
   property tabbar_horz_tab_color: colorty read ftabbar.tahorz.color 
                               write ftabbar.tahorz.color default cl_default;
   property tabbar_horz_tab_coloractive: colorty read ftabbar.tahorz.coloractive 
                               write ftabbar.tahorz.coloractive default cl_default;
   property tabbar_horz_tab_face: tfacecomp read ftabbar.tahorz.face
                               write settabbar_horz_tab_face;
   property tabbar_horz_tab_faceactive: tfacecomp read ftabbar.tahorz.faceactive
                               write settabbar_horz_tab_faceactive;
   property tabbar_vert_face: tfacecomp read ftabbar.wivert.fa write settabbar_vert_face;
   property tabbar_vert_frame: tframecomp read ftabbar.wivert.fra write settabbar_vert_frame;
   property tabbar_vert_tab_color: colorty read ftabbar.tavert.color 
                               write ftabbar.tavert.color default cl_default;
   property tabbar_vert_tab_coloractive: colorty read ftabbar.tavert.coloractive 
                               write ftabbar.tavert.coloractive default cl_default;
   property tabbar_vert_tab_face: tfacecomp read ftabbar.tavert.face
                               write settabbar_vert_tab_face;
   property tabbar_vert_tab_faceactive: tfacecomp read ftabbar.tavert.faceactive
                               write settabbar_vert_tab_faceactive;

   property popupmenu_options: skinmenuoptionsty read fpopupmenu.options
                write fpopupmenu.options default [];         
   property popupmenu_face: tfacecomp read fpopupmenu.face 
                               write setpopupmenu_face;
   property popupmenu_frame: tframecomp read fpopupmenu.frame 
                                      write setpopupmenu_frame;
   property popupmenu_itemface: tfacecomp read fpopupmenu.itemface 
                                      write setpopupmenu_itemface;
   property popupmenu_itemframe: tframecomp read fpopupmenu.itemframe 
                                      write setpopupmenu_itemframe;
   property popupmenu_itemfaceactive: tfacecomp read fpopupmenu.itemfaceactive 
                                      write setpopupmenu_itemfaceactive;
   property popupmenu_itemframeactive: tframecomp 
            read fpopupmenu.itemframeactive write setpopupmenu_itemframeactive;
            
   property mainmenu_options: skinmenuoptionsty read fmainmenu.ma.options
                write fmainmenu.ma.options default [];         
   property mainmenu_face: tfacecomp read fmainmenu.ma.face 
                                 write setmainmenu_face;
   property mainmenu_frame: tframecomp read fmainmenu.ma.frame 
                                 write setmainmenu_frame;
   property mainmenu_itemface: tfacecomp read fmainmenu.ma.itemface 
                                 write setmainmenu_itemface;
   property mainmenu_itemframe: tframecomp read fmainmenu.ma.itemframe 
                                 write setmainmenu_itemframe;
   property mainmenu_itemfaceactive: tfacecomp read fmainmenu.ma.itemfaceactive
                                 write setmainmenu_itemfaceactive;
   property mainmenu_itemframeactive: tframecomp read fmainmenu.ma.itemframeactive 
                                 write setmainmenu_itemframeactive;
   property mainmenu_popupface: tfacecomp read fmainmenu.pop.face 
                                 write setmainmenu_popupface;
   property mainmenu_popupframe: tframecomp read fmainmenu.pop.frame 
                                 write setmainmenu_popupframe;
   property mainmenu_popupitemface: tfacecomp read fmainmenu.pop.itemface 
                                 write setmainmenu_popupitemface;
   property mainmenu_popupitemframe: tframecomp read fmainmenu.pop.itemframe 
                                 write setmainmenu_popupitemframe;
   property mainmenu_popupitemfaceactive: tfacecomp read fmainmenu.pop.itemfaceactive
                                 write setmainmenu_popupitemfaceactive;
   property mainmenu_popupitemframeactive: tframecomp read fmainmenu.pop.itemframeactive 
                                 write setmainmenu_popupitemframeactive;
 end;
  
implementation
uses
 msewidgets,msetabsglob;
type
 twidget1 = class(twidget);
  
{ tskincolor }

constructor tskincolor.create;
begin
 fcolor:= cl_none;
end;

{ tskincolors }

constructor tskincolors.create;
begin
 inherited create(tskincolor);
end;

procedure tskincolors.setcolors;
var
 int1: integer;
begin
 for int1:= 0 to high(fitems) do begin
  with tskincolor(fitems[int1]) do begin
   frgbbefore:= colorty(colortorgb(color));
   setcolormapvalue(fcolor,frgb);
  end;
 end;
end;

procedure tskincolors.restorecolors;
var
 int1: integer;
begin
 for int1:= 0 to high(fitems) do begin
  with tskincolor(fitems[int1]) do begin
   setcolormapvalue(fcolor,frgbbefore);
  end;
 end;
end;

{ tcustomskincontroller }

constructor tcustomskincontroller.create(aowner: tcomponent);
begin
 fcolors:= tskincolors.create;
 inherited;
end;

destructor tcustomskincontroller.destroy;
begin
 active:= false;
 inherited;
 fcolors.free;
end;

procedure tcustomskincontroller.doactivate;
begin
 fcolors.setcolors;
 if canevent(tmethod(fonactivate)) then begin
  fonactivate(self);   
 end;
end;

procedure tcustomskincontroller.dodeactivate;
begin
 if canevent(tmethod(fondeactivate)) then begin
  fondeactivate(self);   
 end;
end;

procedure tcustomskincontroller.loaded;
begin
 inherited;
 if factive and not (csdesigning in componentstate) then begin
  doactivate;
 end;
end;

procedure tcustomskincontroller.setactive(const avalue: boolean);
{$ifndef FPC}
var
 meth1: skinobjecteventty;
{$endif}
begin
 if factive <> avalue then begin
  factive:= avalue;
  if not (csdesigning in componentstate) then begin
   if avalue then begin
    oninitskinobject:= {$ifdef FPC}@{$endif}updateskin;
   end
   else begin
   {$ifdef FPC}
    if oninitskinobject = @updateskin then begin
    {$else}
    meth1:= updateskin;
    if (tmethod(oninitskinobject).code = tmethod(meth1).code) and
                  (tmethod(oninitskinobject).code = tmethod(meth1).code) then begin
    {$endif}
     oninitskinobject:= nil;
    end;
   end;
   if not (csloading in componentstate) then begin
    if avalue then begin
     doactivate;
    end
    else begin
     dodeactivate;
    end;
   end;
  end;
 end;
end;

procedure tcustomskincontroller.updateskin(const instance: tobject;
               const ainfo: skininfoty);
var
 bo1: boolean;
begin
 if factive then begin
  bo1:= false;
  if assigned(fonbeforeupdate) then begin
   fonbeforeupdate(instance,ainfo,bo1);
  end;
  if not bo1 then begin
   case ainfo.objectkind of 
    sok_widget: begin
     handlewidget(twidget(instance),ainfo);
     if sko_container in ainfo.options then begin
      handlecontainer(twidget(instance),ainfo);
     end;
    end;
    sok_edit: begin
     handleedit(tedit(instance),ainfo);
    end;
    sok_dataedit: begin
     handledataedit(tdataedit(instance),ainfo);
    end;
    sok_simplebutton: begin
     handlesimplebutton(tactionsimplebutton(instance),ainfo);
    end;
    sok_tabbar: begin
     handletabbar(tcustomtabbar(instance),ainfo);
    end;
    sok_mainmenu: begin
     handlemainmenu(tcustommainmenu(instance),ainfo);
    end;
    sok_popupmenu: begin
     handlepopupmenu(tpopupmenu(instance),ainfo);
    end;
    sok_user: begin
     handleuserobject(instance,ainfo);
    end;
   end;
  end;
  if assigned(fonafterupdate) then begin
   fonafterupdate(instance,ainfo);
  end;
 end;
end;

procedure tcustomskincontroller.handlewidget(const sender: twidget;
               const ainfo: skininfoty);
begin
 //dummy
end;

procedure tcustomskincontroller.setwidgetface(const instance: twidget;
               const aface: tfacecomp);
begin
 with instance do begin
  if (aface <> nil) and not (osk_framebuttononly in optionsskin) and
                        (face = nil) then begin
   createface;
   face.template:= aface;
  end;
 end;
end;

procedure tcustomskincontroller.setwidgetframe(const instance: twidget;
               const aframe: tframecomp);
var
 size1: sizety;
 col1: colorty;
begin
 with instance do begin
  if (aframe <> nil) and (frame = nil) and 
                 not (osk_framebuttononly in optionsskin) then begin
   createframe;
   col1:= frame.colorclient;
   size1:= clientsize;
   frame.template:= aframe;
   frame.colorclient:= col1;
   clientsize:= size1;
  end;
 end;
end;

procedure tcustomskincontroller.setwidgetframetemplate(const instance: twidget;
               const aframe: tframecomp); //no frame nil check
var
 size1: sizety;
 col1: colorty;
begin
 with instance do begin
  if (aframe <> nil) and not (osk_framebuttononly in optionsskin) then begin
   createframe;
   if  frame.template = nil then begin
    col1:= frame.colorclient;
    size1:= clientsize;
    frame.template:= aframe;
    frame.colorclient:= col1;
    clientsize:= size1;
   end;
  end;
 end;
end;

procedure tcustomskincontroller.setwidgetskin(const instance: twidget;
               const ainfo: widgetskininfoty);
begin
 setwidgetface(instance,ainfo.fa);
 setwidgetframe(instance,ainfo.fra);
end;

procedure tcustomskincontroller.setdataeditskin(const instance: tdataedit;
                                            const ainfo: dataeditskininfoty);
var
 col1: colorty;
begin
 setwidgetface(instance,ainfo.face);
 setwidgetframetemplate(instance,ainfo.frame);
end;

procedure tcustomskincontroller.setwidgetfont(const instance: twidget;
                                            const afont: tfont);
begin
 if afont <> nil then begin
  with twidget1(instance) do begin
   if ffont = nil then begin
    createfont;
    ffont.assign(afont);
   end;
  end;
 end;
end;

procedure tcustomskincontroller.setwidgetcolor(const instance: twidget;
               const acolor: colorty);
begin
 if (acolor <> cl_default) and 
       not (osk_framebuttononly in instance.optionsskin) and
           (instance.color = cl_default) then begin
  instance.color:= acolor;
 end;
end;

procedure tcustomskincontroller.setframebuttonskin(const instance: tframebutton;
               const ainfo: framebuttonskininfoty);
begin
 with instance,ainfo do begin
  if (fa <> nil) and (face = nil) then begin
   createface;
   face.template:= fa;
  end;
  if (fra <> nil) and (frame = nil) then begin
   createframe;
   frame.template:= fra;
  end;
 end;
end;

procedure tcustomskincontroller.setscrollbarskin(const instance: tcustomscrollbar;
               const ainfo: scrollbarskininfoty);
begin
 with instance,ainfo do begin
  if (facebu <> nil) and (facebutton = nil) then begin
   createfacebutton;
   facebutton.template:= facebu;
  end;
  if (faceendbu <> nil) and (faceendbutton = nil) then begin
   createfaceendbutton;
   faceendbutton.template:= faceendbu;
  end;
  if (framebu <> nil) and (framebutton = nil) then begin
   createframebutton;
   framebutton.template:= framebu;
  end;
  if (frameendbu1 <> nil) and (frameendbutton1 = nil) then begin
   createframeendbutton1;
   frameendbutton1.template:= frameendbu1;
  end;
  if (frameendbu2 <> nil) and (frameendbutton2 = nil) then begin
   createframeendbutton2;
   frameendbutton2.template:= frameendbu2;
  end;
 end;
end;

procedure tcustomskincontroller.settabsskin(const instance: tcustomtabbar;
                                             const ainfo: tabsskininfoty);
var
 int1: integer;
begin
 with instance.tabs do begin
  beginupdate;
  try
   if (face = nil) and (ainfo.face <> nil) then begin
    createface;
    face.template:= ainfo.face;
   end;
   if (faceactive = nil) and (ainfo.faceactive <> nil) then begin
    createfaceactive;
    faceactive.template:= ainfo.faceactive;
   end;
   for int1:= 0 to count - 1 do begin
    with items[int1] do begin
     if (ainfo.color <> cl_default) and (color = cl_default) then begin
      color:= ainfo.color;
     end;
     if (ainfo.coloractive <> cl_default) and 
                                     (coloractive = cl_default) then begin
      coloractive:= ainfo.coloractive;
     end;
    end;
   end;
  finally
   endupdate;
  end;
 end;
end;

procedure tcustomskincontroller.setpopupmenuskin(const instance: tpopupmenu;
               const ainfo: menuskininfoty);
begin
 with instance do begin
  if smo_noanim in ainfo.options then begin
   options:= options + [mo_noanim];
  end
  else begin
   options:= options - [mo_noanim];
  end;
  if (ainfo.face <> nil) and (facetemplate = nil) then begin
   facetemplate:= ainfo.face;
  end;
  if (ainfo.frame <> nil) and (frametemplate = nil) then begin
   frametemplate:= ainfo.frame;
  end;
  if (ainfo.itemface <> nil) and (itemfacetemplate = nil) then begin
   itemfacetemplate:= ainfo.itemface;
  end;
  if (ainfo.itemframe <> nil) and (itemframetemplate = nil) then begin
   itemframetemplate:= ainfo.itemframe;
  end;
  if (ainfo.itemfaceactive <> nil) and 
                 (itemfacetemplateactive = nil) then begin
   itemfacetemplateactive:= ainfo.itemfaceactive;
  end;
  if (ainfo.itemframeactive <> nil) and
             (itemframetemplateactive = nil) then begin
   itemframetemplateactive:= ainfo.itemframeactive;
  end;
 end;
end;

procedure tcustomskincontroller.setmainmenuskin(const instance: tcustommainmenu;
                             const ainfo: mainmenuskininfoty);
begin
 setpopupmenuskin(tpopupmenu(instance),ainfo.ma);
 with instance,ainfo do begin
  if (pop.face <> nil) and (popupfacetemplate = nil) then begin
   popupfacetemplate:= pop.face;
  end;
  if (pop.frame <> nil) and (popupframetemplate = nil) then begin
   popupframetemplate:= pop.frame;
  end;
  if (pop.itemface <> nil) and (popupitemfacetemplate = nil) then begin
   popupitemfacetemplate:= pop.itemface;
  end;
  if (pop.itemframe <> nil) and (popupitemframetemplate = nil) then begin
   popupitemframetemplate:= pop.itemframe;
  end;
  if (pop.itemfaceactive <> nil) and 
                 (popupitemfacetemplateactive = nil) then begin
   popupitemfacetemplateactive:= pop.itemfaceactive;
  end;
  if (pop.itemframeactive <> nil) and
             (popupitemframetemplateactive = nil) then begin
   popupitemframetemplateactive:= pop.itemframeactive;
  end;
 end;
end;

procedure tcustomskincontroller.setcolors(const avalue: tskincolors);
begin
 fcolors.assign(avalue);
end;

procedure tcustomskincontroller.handlesimplebutton(const sender: twidget;
               const ainfo: skininfoty);
begin
 //dummy
end;

procedure tcustomskincontroller.handleuserobject(const sender: tobject;
               const ainfo: skininfoty);
begin
 //dummy
end;

procedure tcustomskincontroller.handlecontainer(const sender: twidget;
               const ainfo: skininfoty);
begin
 //dummy
end;

procedure tcustomskincontroller.handletabbar(const sender: tcustomtabbar;
               const ainfo: skininfoty);
begin
 //dummy
end;

procedure tcustomskincontroller.handleedit(const sender: tedit;
               const ainfo: skininfoty);
begin
 //dummy
end;

procedure tcustomskincontroller.handledataedit(const sender: tdataedit;
               const ainfo: skininfoty);
begin
 //dummy
end;

procedure tcustomskincontroller.handlemainmenu(const sender: tcustommainmenu;
               const ainfo: skininfoty);
begin
 //dummy
end;

procedure tcustomskincontroller.handlepopupmenu(const sender: tpopupmenu;
               const ainfo: skininfoty);
begin
 //dummy
end;

{ tskincontroller }

constructor tskincontroller.create(aowner: tcomponent);
begin
 fwidget_color:= cl_default;
 ftabbar.tahorz.color:= cl_default;
 ftabbar.tahorz.coloractive:= cl_default;
 ftabbar.tavert.color:= cl_default;
 ftabbar.tavert.coloractive:= cl_default;
 fdataedit.color:= cl_default;
 inherited;
end;

destructor tskincontroller.destroy;
begin
 inherited;
 fbutton.font.free;
end;

procedure tskincontroller.setdataedit_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fdataedit.face));
end;

procedure tskincontroller.setdataedit_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fdataedit.frame));
end;

procedure tskincontroller.setcontainer_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fcontainer_face));
end;

procedure tskincontroller.setsb_vert_facebutton(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fsb_vert.facebu));
end;

procedure tskincontroller.setsb_vert_faceendbutton(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fsb_vert.faceendbu));
end;

procedure tskincontroller.setsb_vert_framebutton(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fsb_vert.framebu));
end;

procedure tskincontroller.setsb_vert_frameendbutton1(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fsb_vert.frameendbu1));
end;

procedure tskincontroller.setsb_vert_frameendbutton2(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fsb_vert.frameendbu2));
end;

procedure tskincontroller.setsb_horz_facebutton(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fsb_horz.facebu));
end;

procedure tskincontroller.setsb_horz_faceendbutton(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fsb_horz.faceendbu));
end;

procedure tskincontroller.setsb_horz_framebutton(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fsb_horz.framebu));
end;

procedure tskincontroller.setsb_horz_frameendbutton1(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fsb_horz.frameendbu1));
end;

procedure tskincontroller.setsb_horz_frameendbutton2(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fsb_horz.frameendbu2));
end;

procedure tskincontroller.setbutton_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fbutton.wi.fa));
end;

procedure tskincontroller.setbutton_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fbutton.wi.fra));
end;

procedure tskincontroller.setframebutton_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fframebutton.fa));
end;

procedure tskincontroller.setframebutton_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fframebutton.fra));
end;

procedure tskincontroller.settabbar_horz_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabbar.wihorz.fa));
end;

procedure tskincontroller.settabbar_horz_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabbar.wihorz.fra));
end;

procedure tskincontroller.settabbar_horz_tab_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabbar.tahorz.face));
end;

procedure tskincontroller.settabbar_horz_tab_faceactive(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabbar.tahorz.faceactive));
end;

procedure tskincontroller.settabbar_vert_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabbar.wivert.fa));
end;

procedure tskincontroller.settabbar_vert_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabbar.wivert.fra));
end;

procedure tskincontroller.settabbar_vert_tab_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabbar.tavert.face));
end;

procedure tskincontroller.settabbar_vert_tab_faceactive(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabbar.tavert.faceactive));
end;

procedure tskincontroller.setpopupmenu_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fpopupmenu.face));
end;

procedure tskincontroller.setpopupmenu_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fpopupmenu.frame));
end;

procedure tskincontroller.setpopupmenu_itemface(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fpopupmenu.itemface));
end;

procedure tskincontroller.setpopupmenu_itemframe(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fpopupmenu.itemframe));
end;

procedure tskincontroller.setpopupmenu_itemfaceactive(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fpopupmenu.itemfaceactive));
end;

procedure tskincontroller.setpopupmenu_itemframeactive(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fpopupmenu.itemframeactive));
end;

procedure tskincontroller.setmainmenu_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenu.ma.face));
end;

procedure tskincontroller.setmainmenu_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenu.ma.frame));
end;

procedure tskincontroller.setmainmenu_itemface(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenu.ma.itemface));
end;

procedure tskincontroller.setmainmenu_itemframe(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenu.ma.itemframe));
end;

procedure tskincontroller.setmainmenu_itemfaceactive(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenu.ma.itemfaceactive));
end;

procedure tskincontroller.setmainmenu_itemframeactive(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenu.ma.itemframeactive));
end;

procedure tskincontroller.setmainmenu_popupface(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenu.pop.face));
end;

procedure tskincontroller.setmainmenu_popupframe(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenu.pop.frame));
end;

procedure tskincontroller.setmainmenu_popupitemface(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenu.pop.itemface));
end;

procedure tskincontroller.setmainmenu_popupitemframe(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenu.pop.itemframe));
end;

procedure tskincontroller.setmainmenu_popupitemfaceactive(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenu.pop.itemfaceactive));
end;

procedure tskincontroller.setmainmenu_popupitemframeactive(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenu.pop.itemframeactive));
end;

procedure tskincontroller.handlewidget(const sender: twidget;
               const ainfo: skininfoty);
var
 int1: integer;
begin
 if sender.frame <> nil then begin
  if sender.frame is tcustomscrollframe then begin
   setscrollbarskin(tcustomscrollframe(sender.frame).sbvert,fsb_vert);
   setscrollbarskin(tcustomscrollframe(sender.frame).sbhorz,fsb_horz);
  end
  else begin
   if sender.frame is tcustombuttonframe then begin
    with tcustombuttonframe(sender.frame) do begin
     for int1:= 0 to buttons.count - 1 do begin
      setframebuttonskin(buttons[int1],fframebutton);
     end;
    end;
   end;
  end; 
 end;
 setwidgetcolor(sender,fwidget_color);
end;

procedure tskincontroller.handlesimplebutton(const sender: twidget;
               const ainfo: skininfoty);
begin
 setwidgetskin(sender,fbutton.wi);
 setwidgetfont(sender,fbutton.font);
end;

procedure tskincontroller.handlecontainer(const sender: twidget;
               const ainfo: skininfoty);
begin
 setwidgetface(sender,fcontainer_face);
end;

procedure tskincontroller.createbutton_font;
begin
 if fbutton.font = nil then begin
  fbutton.font:= toptionalfont.create;
 end;
end;

procedure tskincontroller.setbutton_font(const avalue: toptionalfont);
begin
 setoptionalobject(avalue,fbutton.font,{$ifdef FPC}@{$endif}createbutton_font);
end;

function tskincontroller.getbutton_font: toptionalfont;
begin
 getoptionalobject(fbutton.font,{$ifdef FPC}@{$endif}createbutton_font);
 result:= fbutton.font;
end;

procedure tskincontroller.handletabbar(const sender: tcustomtabbar;
               const ainfo: skininfoty);
begin
 if tabo_vertical in sender.options then begin
  setwidgetskin(sender,ftabbar.wivert);
  settabsskin(sender,ftabbar.tavert);
 end
 else begin
  setwidgetskin(sender,ftabbar.wihorz);
  settabsskin(sender,ftabbar.tahorz);
 end;
end;

procedure tskincontroller.handleedit(const sender: tedit;
               const ainfo: skininfoty);
begin
 handlewidget(sender,ainfo);
end;

procedure tskincontroller.handledataedit(const sender: tdataedit;
               const ainfo: skininfoty);
begin
 handlewidget(sender,ainfo);
 setdataeditskin(sender,fdataedit);
end;

procedure tskincontroller.handlemainmenu(const sender: tcustommainmenu;
               const ainfo: skininfoty);
begin
 setmainmenuskin(sender,fmainmenu);
end;

procedure tskincontroller.handlepopupmenu(const sender: tpopupmenu;
               const ainfo: skininfoty);
begin
 setpopupmenuskin(sender,fpopupmenu);
end;

end.
