{ MSEgui Copyright (c) 2008-2009 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseskin;
{$ifdef FPC}{$mode objfpc}{$h+}{$goto on}{$endif}
interface
uses
 classes,mseclasses,msegui,msescrollbar,mseedit,msegraphics,msegraphutils,
 msetabs,msetoolbar,msedataedits,msemenus,msearrayprops,msegraphedits,msesimplewidgets,
 msegrids,msewidgets,msetypes,mseglob;
type

// skinmenuoptionty = (smo_noanim);
// skinmenuoptionsty = set of skinmenuoptionty;
 
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
 containerskininfoty = record
  wi: widgetskininfoty;
//  face: tfacecomp;
//  frame: tframecomp;
 end;
 groupboxskininfoty = record
  wi: widgetskininfoty;
//  face: tfacecomp;
//  frame: tframecomp;
 end;
 toolbarskininfoty = record
  wi: widgetskininfoty;
//  face: tfacecomp;
//  frame: tframecomp;
  buttonface: tfacecomp;
 end;
 gridpropskininfoty = record
  face: tfacecomp;
  frame: tframecomp;
 end;
 gridskininfoty = record
  wi: widgetskininfoty;
//  face: tfacecomp;
//  frame: tframecomp;
  fixrows: gridpropskininfoty;
  fixcols: gridpropskininfoty;
  datacols: gridpropskininfoty;
 end;  
 buttonskininfoty = record
  co: colorty;
  wi: widgetskininfoty;
  font: toptionalfont;
 end;  
 stepbuttonskininfoty = record
  co: colorty;
  fa: tfacecomp;
  fra: tframecomp;
 end; 
 framebuttonskininfoty = record
  co: colorty;
  coglyph: colorty;
  fa: tfacecomp;
  fra: tframecomp;
 end;
 tabsskininfoty = record
  color: colorty;
  coloractive: colorty;
  frame: tframecomp;
  face: tfacecomp;
  faceactive: tfacecomp;
  shift: integer;
 end;
 tabbarskininfoty = record
  wihorz: widgetskininfoty;
  wivert: widgetskininfoty;
  wihorzopo: widgetskininfoty;
  wivertopo: widgetskininfoty;
  tahorz: tabsskininfoty;
  tavert: tabsskininfoty;
  tahorzopo: tabsskininfoty;
  tavertopo: tabsskininfoty;
 end;
 tabpageskininfoty = record
  wi: widgetskininfoty;
 end;
 menuskininfoty = record
  face: tfacecomp;
  frame: tframecomp;
  itemface: tfacecomp;
  itemframe: tframecomp;
  itemfaceactive: tfacecomp;
  itemframeactive: tframecomp;
//  options: skinmenuoptionsty;
 end;  
 mainmenuskininfoty = record
  ma: menuskininfoty;
  pop: menuskininfoty;
 end;
 dataeditskininfoty = record
  wi: widgetskininfoty;
//  color: colorty;
//  face: tfacecomp;
//  frame: tframecomp;
 end;
 
 tskincolor = class(tvirtualpersistent)
  private
   fcolor: colorty;
   frgb: colorty;
   frgbbefore: colorty;
   procedure setcolor(const avalue: colorty);
  public
   constructor create; override;
  published
   property color: colorty read fcolor write setcolor default cl_none;
   property rgb: colorty read frgb write frgb;
 end;
 
 tskincolors = class(tpersistentarrayprop)
  private
   fframecolors: framecolorinfoty;
   fframecolorsbefore: framecolorinfoty;
  public
   constructor create;
   class function getitemclasstype: persistentclassty; override;
   procedure setcolors;
   procedure restorecolors;
  published
   property colordkshadow: colorty read fframecolors.shadow.effectcolor
              write fframecolors.shadow.effectcolor default cl_default;
   property colorshadow: colorty read fframecolors.shadow.color
              write fframecolors.shadow.color default cl_default;
   property colorlight: colorty read fframecolors.light.color
              write fframecolors.light.color default cl_default;
   property colorhighlight: colorty read fframecolors.light.effectcolor
              write fframecolors.light.effectcolor default cl_default;
   property colordkwidth: integer read fframecolors.shadow.effectwidth
              write fframecolors.shadow.effectwidth default -1;
   property colorhlwidth: integer read fframecolors.light.effectwidth
              write fframecolors.light.effectwidth default -1;
 end;

 tskinfontalias = class(tvirtualpersistent)
  private
   fname: string;
   falias: string;
   fmode: fontaliasmodety;
   fheight: integer;
   fwidth: integer;
   foptions: fontoptionsty;
  public
   constructor create; override;
  published
   property name: string read fname write fname;
   property alias: string read falias write falias;
   property mode: fontaliasmodety read fmode write fmode default fam_fixnooverwrite;
   property height: integer read fheight write fheight;
   property width: integer read fwidth write fwidth;
   property options: fontoptionsty read foptions write foptions default [];
 end;

 tskinfontaliass = class(tpersistentarrayprop)   
  public
   constructor create;
   class function getitemclasstype: persistentclassty; override;
   procedure setfontalias;
 end;

 createprocty = procedure of object;

 tcustomskincontroller = class;
 
 beforeskinupdateeventty = procedure(const sender: tcustomskincontroller; 
                const ainfo: skininfoty; var handled: boolean) of object;
 skincontrollereventty = procedure(const sender: tcustomskincontroller; 
                                  const ainfo: skininfoty) of object;
                
 tskinextender = class(tmsecomponent)
  private
   fmaster: tcustomskincontroller;
   procedure setmaster(const avalue: tcustomskincontroller);
  protected
   procedure doactivate; virtual;
   procedure dodeactivate; virtual;
  public
   destructor  destroy; override;
   procedure updateskin(const ainfo: skininfoty; var handled: boolean); virtual;
  published
   property master: tcustomskincontroller read fmaster write setmaster;
 end;

 skinextenderarty = array of tskinextender;
   
 tcustomskincontroller = class(tmsecomponent)
  private
   fonbeforeupdate: beforeskinupdateeventty;
   fonafterupdate: skincontrollereventty;
   factive: boolean;
   fonactivate: notifyeventty;
   fondeactivate: notifyeventty;
   fcolors: tskincolors;
   ffontalias: tskinfontaliass;
   fupdating: integer;
   procedure setactive(const avalue: boolean);
   procedure setcolors(const avalue: tskincolors);
   procedure setfontalias(const avalue: tskinfontaliass);
   function getextenders: integer;
   procedure setextenders(const avalue: integer);
   procedure readextendernames(reader: treader);
   procedure writeextendernames(writer: twriter);
  protected
   fextendernames: stringarty;
   fextenders: skinextenderarty;
   function getextendernames: stringarty;
   procedure objectevent(const sender: tobject;
                    const event: objecteventty); override;
   procedure updateorder;
   procedure registerextender(const aextender: tskinextender);
   procedure unregisterextender(const aextender: tskinextender);

   procedure doactivate; virtual;
   procedure dodeactivate; virtual;
   procedure loaded; override;
   procedure defineproperties(filer: tfiler); override;

   procedure setfacetemplate(const face: tfacecomp;
                                        const dest: tcustomface);
   procedure setframetemplate(const frame: tframecomp;
                                        const dest: tcustomframe);

   procedure setwidgetface(const instance: twidget; const aface: tfacecomp);
//   procedure setwidgetfacetemplate(const instance: twidget;
//                                   const aface: tfacecomp);//no face nil test
   procedure setwidgetframe(const instance: twidget; const aframe: tframecomp);
//   procedure setwidgetframetemplate(const instance: twidget;
//                            const aframe: tframecomp); //no fram nil check
   procedure setwidgetskin(const instance: twidget;
                                            const ainfo: widgetskininfoty);
//   procedure setwidgetskintemplate(const instance: twidget;
//                                            const ainfo: widgetskininfoty);
                    //overrides nil frame and face
   procedure setgroupboxskin(const instance: tgroupbox;
                                            const ainfo: groupboxskininfoty);
   procedure setgridpropskin(const instance: tgridprop;
                               const ainfo: gridpropskininfoty);
   procedure setgridskin(const instance: tcustomgrid;
                                            const ainfo: gridskininfoty);
   procedure setdataeditskin(const instance: tdataedit;
                                            const ainfo: dataeditskininfoty);
   procedure setgraphdataeditskin(const instance: tgraphdataedit;
                                            const ainfo: dataeditskininfoty);
   procedure setwidgetfont(const instance: twidget; const afont: tfont);
   procedure setwidgetcolor(const instance: twidget; const acolor: colorty);
   procedure setscrollbarskin(const instance: tcustomscrollbar; 
                const ainfo: scrollbarskininfoty);
   procedure setstepbuttonskin(const instance: tcustomstepframe;
                                          const ainfo: stepbuttonskininfoty);
   procedure setframebuttonskin(const instance: tframebutton;
                const ainfo: framebuttonskininfoty);
   procedure settabsskin(const instance: tcustomtabbar;
                                        const ainfo: tabsskininfoty);
   procedure setpopupmenuskin(const instance: tpopupmenu;
                                    const ainfo: menuskininfoty);
   procedure setmainmenuskin(const instance: tcustommainmenu;
         const ainfo: mainmenuskininfoty);

   procedure handlewidget(const ainfo: skininfoty); virtual;
   procedure handlecontainer(const ainfo: skininfoty); virtual;
   procedure handlegroupbox(const ainfo: skininfoty); virtual;
   procedure handlesimplebutton(const ainfo: skininfoty); virtual;
   procedure handledatabutton(const ainfo: skininfoty); virtual;
   procedure handleuserobject(const ainfo: skininfoty); virtual;
   procedure handletabbar(const ainfo: skininfoty); virtual;
   procedure handletabpage(const ainfo: skininfoty); virtual;
   procedure handletoolbar(const ainfo: skininfoty); virtual;
   procedure handleedit(const ainfo: skininfoty); virtual;
   procedure handledataedit(const ainfo: skininfoty); virtual;
   procedure handlebooleanedit(const ainfo: skininfoty); virtual;
   procedure handlemainmenu(const ainfo: skininfoty); virtual;
   procedure handlepopupmenu(const ainfo: skininfoty); virtual;
   procedure handlegrid(const ainfo: skininfoty); virtual;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure updateskin(const ainfo: skininfoty);
  published
   property active: boolean read factive write setactive default false;
   property extenders: integer read getextenders write setextenders; 
                                  //hook for object inspector
   property onbeforeupdate: beforeskinupdateeventty read fonbeforeupdate
                                 write fonbeforeupdate;
   property onafterupdate: skincontrollereventty read fonafterupdate
                                 write fonafterupdate;
   property onactivate: notifyeventty read fonactivate write fonactivate;
   property ondeactivate: notifyeventty read fondeactivate write fondeactivate;
   property colors: tskincolors read fcolors write setcolors;
   property fontalias: tskinfontaliass read ffontalias write setfontalias;
 end;

 tskincontroller = class(tcustomskincontroller)
  private
   fsb_horz: scrollbarskininfoty;
   fsb_vert: scrollbarskininfoty;
   fgroupbox: groupboxskininfoty;
   fgrid: gridskininfoty;
   fbutton: buttonskininfoty;
   fdatabutton: buttonskininfoty;
   fstepbutton: stepbuttonskininfoty;
   fframebutton: framebuttonskininfoty;
   fcontainer: containerskininfoty;
   fwidget_color: colorty;
   fwidget_colorcaptionframe: colorty;
   ftabbar: tabbarskininfoty;
   ftabpage: tabpageskininfoty;
   ftoolbar: toolbarskininfoty;
   fpopupmenu: menuskininfoty;
   fmainmenu: mainmenuskininfoty;
   fdataedit: dataeditskininfoty;
   fbooleanedit: dataeditskininfoty;
   
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

   procedure setgroupbox_face(const avalue: tfacecomp);
   procedure setgroupbox_frame(const avalue: tframecomp);

   procedure setgrid_face(const avalue: tfacecomp);
   procedure setgrid_frame(const avalue: tframecomp);
   procedure setgrid_fixrows_face(const avalue: tfacecomp);
   procedure setgrid_fixrows_frame(const avalue: tframecomp);
   procedure setgrid_fixcols_face(const avalue: tfacecomp);
   procedure setgrid_fixcols_frame(const avalue: tframecomp);
   procedure setgrid_datacols_face(const avalue: tfacecomp);
   procedure setgrid_datacols_frame(const avalue: tframecomp);

   procedure setbutton_face(const avalue: tfacecomp);
   procedure setbutton_frame(const avalue: tframecomp);
   function getbutton_font: toptionalfont;
   procedure setbutton_font(const avalue: toptionalfont);

   procedure setdatabutton_face(const avalue: tfacecomp);
   procedure setdatabutton_frame(const avalue: tframecomp);
   function getdatabutton_font: toptionalfont;
   procedure setdatabutton_font(const avalue: toptionalfont);

   procedure setframebutton_face(const avalue: tfacecomp);
   procedure setframebutton_frame(const avalue: tframecomp);

   procedure setstepbutton_face(const avalue: tfacecomp);
   procedure setstepbutton_frame(const avalue: tframecomp);

   procedure setdataedit_face(const avalue: tfacecomp);
   procedure setdataedit_frame(const avalue: tframecomp);

   procedure setbooleanedit_face(const avalue: tfacecomp);
   procedure setbooleanedit_frame(const avalue: tframecomp);

   procedure setcontainer_face(const avalue: tfacecomp);
   procedure setcontainer_frame(const avalue: tframecomp);

   procedure settabbar_horz_face(const avalue: tfacecomp);
   procedure settabbar_horz_frame(const avalue: tframecomp);
   procedure settabbar_horz_tab_frame(const avalue: tframecomp);
   procedure settabbar_horz_tab_face(const avalue: tfacecomp);
   procedure settabbar_horz_tab_faceactive(const avalue: tfacecomp);
   procedure settabbar_vert_face(const avalue: tfacecomp);
   procedure settabbar_vert_frame(const avalue: tframecomp);
   procedure settabbar_vert_tab_frame(const avalue: tframecomp);
   procedure settabbar_vert_tab_face(const avalue: tfacecomp);
   procedure settabbar_vert_tab_faceactive(const avalue: tfacecomp);

   procedure settabbar_horzopo_face(const avalue: tfacecomp);
   procedure settabbar_horzopo_frame(const avalue: tframecomp);
   procedure settabbar_horzopo_tab_frame(const avalue: tframecomp);
   procedure settabbar_horzopo_tab_face(const avalue: tfacecomp);
   procedure settabbar_horzopo_tab_faceactive(const avalue: tfacecomp);
   procedure settabbar_vertopo_face(const avalue: tfacecomp);
   procedure settabbar_vertopo_frame(const avalue: tframecomp);
   procedure settabbar_vertopo_tab_frame(const avalue: tframecomp);
   procedure settabbar_vertopo_tab_face(const avalue: tfacecomp);
   procedure settabbar_vertopo_tab_faceactive(const avalue: tfacecomp);

   procedure settabpage_face(const avalue: tfacecomp);
   procedure settabpage_frame(const avalue: tframecomp);

   procedure settoolbar_face(const avalue: tfacecomp);
   procedure settoolbar_frame(const avalue: tframecomp);
   procedure settoolbar_buttonface(const avalue: tfacecomp);
   
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
   procedure handlewidget(const ainfo: skininfoty); override;
   procedure handlecontainer(const ainfo: skininfoty); override;
   procedure handlegroupbox(const ainfo: skininfoty); override;
   procedure handlesimplebutton(const ainfo: skininfoty); override;
   procedure handledatabutton(const ainfo: skininfoty); override;
   procedure handletabbar(const ainfo: skininfoty); override;
   procedure handletabpage(const ainfo: skininfoty); override;
   procedure handletoolbar(const ainfo: skininfoty); override;
   procedure handleedit(const ainfo: skininfoty); override;
   procedure handledataedit(const ainfo: skininfoty); override;
   procedure handlebooleanedit(const ainfo: skininfoty); override;
   procedure handlemainmenu(const ainfo: skininfoty); override;
   procedure handlepopupmenu(const ainfo: skininfoty); override;
   procedure handlegrid(const ainfo: skininfoty); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure createbutton_font;
   procedure createdatabutton_font;
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

   property stepbutton_color: colorty read fstepbutton.co 
                        write fstepbutton.co default cl_default;
   property stepbutton_frame: tframecomp read fstepbutton.fra 
                        write setstepbutton_frame;
   property stepbutton_face: tfacecomp read fstepbutton.fa 
                        write setstepbutton_face;
                        
   property widget_color: colorty read fwidget_color 
                        write fwidget_color default cl_default;
   property widget_colorcaptionframe: colorty read fwidget_colorcaptionframe 
                        write fwidget_colorcaptionframe default cl_default;
                        //overrides widget_color for widgets with frame caption

//   property dataedit_color: colorty read fdataedit.color 
//                        write fdataedit.color default cl_default;
   property dataedit_face: tfacecomp read fdataedit.wi.fa write setdataedit_face;
   property dataedit_frame: tframecomp read fdataedit.wi.fra 
                        write setdataedit_frame;
                        
//   property booleanedit_color: colorty read fbooleanedit.color 
//                        write fbooleanedit.color default cl_default;
   property booleanedit_face: tfacecomp read fbooleanedit.wi.fa write setbooleanedit_face;
   property booleanedit_frame: tframecomp read fbooleanedit.wi.fra 
                        write setbooleanedit_frame;

   property container_face: tfacecomp read fcontainer.wi.fa 
                                              write setcontainer_face;
   property container_ftrame: tframecomp read fcontainer.wi.fra 
                                              write setcontainer_frame;
   property groupbox_face: tfacecomp read fgroupbox.wi.fa write setgroupbox_face;
   property groupbox_frame: tframecomp read fgroupbox.wi.fra write setgroupbox_frame;

   property grid_face: tfacecomp read fgrid.wi.fa write setgrid_face;
   property grid_frame: tframecomp read fgrid.wi.fra write setgrid_frame;
   property grid_fixrows_face: tfacecomp read fgrid.fixrows.face 
                            write setgrid_fixrows_face;
   property grid_fixrows_frame: tframecomp read fgrid.fixrows.frame
                            write setgrid_fixrows_frame;
   property grid_fixcols_face: tfacecomp read fgrid.fixcols.face 
                            write setgrid_fixcols_face;
   property grid_fixcols_frame: tframecomp read fgrid.fixcols.frame
                            write setgrid_fixcols_frame;
   property grid_datacols_face: tfacecomp read fgrid.datacols.face 
                            write setgrid_datacols_face;
   property grid_datacols_frame: tframecomp read fgrid.datacols.frame
                            write setgrid_datacols_frame;
   
   property button_color: colorty read fbutton.co write fbutton.co
                                                  default cl_default;
   property button_face: tfacecomp read fbutton.wi.fa write setbutton_face;
   property button_frame: tframecomp read fbutton.wi.fra write setbutton_frame;
   property button_font: toptionalfont read getbutton_font write setbutton_font;

   property databutton_color: colorty read fdatabutton.co 
                                  write fdatabutton.co default cl_default;
   property databutton_face: tfacecomp read fdatabutton.wi.fa 
                                              write setdatabutton_face;
   property databutton_frame: tframecomp read fdatabutton.wi.fra 
                                              write setdatabutton_frame;
   property databutton_font: toptionalfont read getdatabutton_font 
                                              write setdatabutton_font;

   property framebutton_color: colorty read fframebutton.co 
                           write fframebutton.co default cl_default;
   property framebutton_colorglyph: colorty read fframebutton.coglyph 
                           write fframebutton.coglyph default cl_default;
   property framebutton_face: tfacecomp read fframebutton.fa 
                                              write setframebutton_face;
   property framebutton_frame: tframecomp read fframebutton.fra 
                                              write setframebutton_frame;

   property tabbar_horz_face: tfacecomp read ftabbar.wihorz.fa 
                                            write settabbar_horz_face;
   property tabbar_horz_frame: tframecomp read ftabbar.wihorz.fra 
                                            write settabbar_horz_frame;
   property tabbar_horz_tab_color: colorty read ftabbar.tahorz.color 
                               write ftabbar.tahorz.color default cl_default;
   property tabbar_horz_tab_coloractive: colorty read ftabbar.tahorz.coloractive 
                               write ftabbar.tahorz.coloractive default cl_default;
   property tabbar_horz_tab_frame: tframecomp read ftabbar.tahorz.frame
                               write settabbar_horz_tab_frame;
   property tabbar_horz_tab_face: tfacecomp read ftabbar.tahorz.face
                               write settabbar_horz_tab_face;
   property tabbar_horz_tab_faceactive: tfacecomp read ftabbar.tahorz.faceactive
                               write settabbar_horz_tab_faceactive;
   property tabbar_horz_tab_shift: integer read ftabbar.tahorz.shift
                               write ftabbar.tahorz.shift default defaulttabshift;

   property tabbar_horzopo_face: tfacecomp read ftabbar.wihorzopo.fa 
                                            write settabbar_horzopo_face;
   property tabbar_horzopo_frame: tframecomp read ftabbar.wihorzopo.fra 
                                            write settabbar_horzopo_frame;
   property tabbar_horzopo_tab_color: colorty read ftabbar.tahorzopo.color 
                               write ftabbar.tahorzopo.color default cl_default;
   property tabbar_horzopo_tab_coloractive: colorty read ftabbar.tahorzopo.coloractive 
                               write ftabbar.tahorzopo.coloractive default cl_default;
   property tabbar_horzopo_tab_frame: tframecomp read ftabbar.tahorzopo.frame
                               write settabbar_horzopo_tab_frame;
   property tabbar_horzopo_tab_face: tfacecomp read ftabbar.tahorzopo.face
                               write settabbar_horzopo_tab_face;
   property tabbar_horzopo_tab_faceactive: tfacecomp read ftabbar.tahorzopo.faceactive
                               write settabbar_horzopo_tab_faceactive;
   property tabbar_horzopo_tab_shift: integer read ftabbar.tahorzopo.shift
                               write ftabbar.tahorzopo.shift default defaulttabshift;

   property tabbar_vert_face: tfacecomp read ftabbar.wivert.fa 
                               write settabbar_vert_face;
   property tabbar_vert_frame: tframecomp read ftabbar.wivert.fra 
                               write settabbar_vert_frame;
   property tabbar_vert_tab_color: colorty read ftabbar.tavert.color 
                               write ftabbar.tavert.color default cl_default;
   property tabbar_vert_tab_coloractive: colorty read ftabbar.tavert.coloractive 
                               write ftabbar.tavert.coloractive default cl_default;
   property tabbar_vert_tab_frame: tframecomp read ftabbar.tavert.frame
                               write settabbar_vert_tab_frame;
   property tabbar_vert_tab_face: tfacecomp read ftabbar.tavert.face
                               write settabbar_vert_tab_face;
   property tabbar_vert_tab_faceactive: tfacecomp read ftabbar.tavert.faceactive
                               write settabbar_vert_tab_faceactive;
   property tabbar_vert_tab_shift: integer read ftabbar.tavert.shift
                               write ftabbar.tavert.shift default defaulttabshift;

   property tabbar_vertopo_face: tfacecomp read ftabbar.wivertopo.fa
                               write settabbar_vertopo_face;
   property tabbar_vertopo_frame: tframecomp read ftabbar.wivertopo.fra
                               write settabbar_vertopo_frame;
   property tabbar_vertopo_tab_color: colorty read ftabbar.tavertopo.color 
                         write ftabbar.tavertopo.color default cl_default;
   property tabbar_vertopo_tab_coloractive: colorty 
                         read ftabbar.tavertopo.coloractive 
                         write ftabbar.tavertopo.coloractive default cl_default;
   property tabbar_vertopo_tab_frame: tframecomp read ftabbar.tavertopo.frame
                               write settabbar_vertopo_tab_frame;
   property tabbar_vertopo_tab_face: tfacecomp read ftabbar.tavertopo.face
                         write settabbar_vertopo_tab_face;
   property tabbar_vertopo_tab_faceactive: tfacecomp 
                         read ftabbar.tavertopo.faceactive
                         write settabbar_vertopo_tab_faceactive;
   property tabbar_vertopo_tab_shift: integer read ftabbar.tavertopo.shift
                               write ftabbar.tavertopo.shift default defaulttabshift;

   property toolbar_face: tfacecomp read ftoolbar.wi.fa write settoolbar_face;
   property toolbar_frame: tframecomp read ftoolbar.wi.fra write settoolbar_frame;
   property toolbar_buttonface: tfacecomp read ftoolbar.buttonface 
                            write settoolbar_buttonface;

   property tabpage_face: tfacecomp read ftabpage.wi.fa write settabpage_face;
   property tabpage_frame: tframecomp read ftabpage.wi.fra write settabpage_frame;
{
   property popupmenu_options: skinmenuoptionsty read fpopupmenu.options
                write fpopupmenu.options default [];         
}
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
{            
   property mainmenu_options: skinmenuoptionsty read fmainmenu.ma.options
                write fmainmenu.ma.options default [];         
}
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

function activeskincontroller: tcustomskincontroller;
function activeskincontrollerdesign: tcustomskincontroller;
  
implementation
uses
 msetabsglob,sysutils,mseapplication,msedatalist;
type
 twidget1 = class(twidget);
 tcustomframe1 = class(tcustomframe);
 ttabs1 = class(ttabs);
var
 factiveskincontroller: tcustomskincontroller;
 factiveskincontrollerdesign: tcustomskincontroller;

function activeskincontroller: tcustomskincontroller;
begin
 result:= factiveskincontroller;
end;
   
function activeskincontrollerdesign: tcustomskincontroller;
begin
 result:= factiveskincontrollerdesign;
end;
   
{ tskincolor }

constructor tskincolor.create;
begin
 fcolor:= cl_none;
end;

procedure tskincolor.setcolor(const avalue: colorty);
begin
 if not isvalidmapcolor(avalue) then begin
  raise exception.create('Invalid map color.');
 end;
 fcolor:= avalue;
end;

{ tskincolors }

constructor tskincolors.create;
begin
 with fframecolors do begin
  light.color:= cl_default;
  light.effectcolor:= cl_default;
  light.effectwidth:= -1;
  shadow.color:= cl_default;
  shadow.effectcolor:= cl_default;
  shadow.effectwidth:= -1;
 end;
 inherited create(tskincolor);
end;

class function tskincolors.getitemclasstype: persistentclassty;
begin
 result:= tskincolor;
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
 fframecolorsbefore:= defaultframecolors;
 with fframecolors.light do begin
  if color <> cl_default then begin
   defaultframecolors.light.color:= color;
  end;
  if effectcolor <> cl_default then begin
   defaultframecolors.light.effectcolor:= effectcolor;
  end;
  if effectwidth <> -1 then begin
   defaultframecolors.light.effectwidth:= effectwidth;
  end;
 end;
 with fframecolors.shadow do begin
  if color <> cl_default then begin
   defaultframecolors.shadow.color:= color;
  end;
  if effectcolor <> cl_default then begin
   defaultframecolors.shadow.effectcolor:= effectcolor;
  end;
  if effectwidth <> -1 then begin
   defaultframecolors.shadow.effectwidth:= effectwidth;
  end;
 end
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
 defaultframecolors:= fframecolorsbefore;
end;

{ tskinfontaliass }

constructor tskinfontaliass.create;
begin
 inherited create(tskinfontalias);
end;

class function tskinfontaliass.getitemclasstype: persistentclassty;
begin
 result:= tskinfontalias;
end;

procedure tskinfontaliass.setfontalias;
var
 int1: integer;
begin
 for int1:= 0 to high(fitems) do begin
  with tskinfontalias(fitems[int1]) do begin
   registerfontalias(alias,name,mode,height,width,options);
  end;
 end;
end;

{ tcustomskincontroller }

constructor tcustomskincontroller.create(aowner: tcomponent);
begin
 fcolors:= tskincolors.create;
 ffontalias:= tskinfontaliass.create;
 inherited;
end;

destructor tcustomskincontroller.destroy;
begin
 active:= false;
 inherited;
 fcolors.free;
 ffontalias.free;
end;

procedure tcustomskincontroller.doactivate;
var
 int1: integer;
begin
 fcolors.setcolors;
 ffontalias.setfontalias;
 if canevent(tmethod(fonactivate)) then begin
  fonactivate(self);   
 end;
 updateorder;
 for int1:= 0 to high(fextenders) do begin
  fextenders[int1].doactivate;
 end;
end;

procedure tcustomskincontroller.dodeactivate;
var
 int1: integer;
begin
 if canevent(tmethod(fondeactivate)) then begin
  fondeactivate(self);   
 end;
 updateorder;
 for int1:= 0 to high(fextenders) do begin
  fextenders[int1].dodeactivate;
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
var
 meth1: skineventty;
 methodpo: ^skineventty;
 controllerpo: ^tcustomskincontroller;
begin
 if factive <> avalue then begin
  factive:= avalue;
  if not (csdesigning in componentstate) then begin
   methodpo:= {$ifndef FPC}@{$endif}@oninitskinobject;
   controllerpo:= @factiveskincontroller;
  end
  else begin
   methodpo:= {$ifndef FPC}@{$endif}@oninitskinobjectdesign;
   controllerpo:= @factiveskincontrollerdesign;
  end;
  if avalue then begin
   methodpo^:= {$ifdef FPC}@{$endif}updateskin;
   controllerpo^:= self;
  end
  else begin
   meth1:= {$ifdef FPC}@{$endif}updateskin;
   if (tmethod(methodpo^).code = tmethod(meth1).code) and
                 (tmethod(methodpo^).data = tmethod(meth1).data) then begin
    methodpo^:= nil;
    controllerpo^:= nil;
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

procedure tcustomskincontroller.updateskin(const ainfo: skininfoty);
label
 endlab;
var
 bo1,bo2: boolean;
 int1: integer;
begin
 if factive then begin
  bo1:= false;
  if assigned(fonbeforeupdate) then begin
   fonbeforeupdate(self,ainfo,bo1);
  end;
  if not bo1 then begin
   if fupdating = 0 then begin
    inc(fupdating);
    try
     bo2:= false;
     for int1:= 0 to high(fextenders) do begin
      fextenders[int1].updateskin(ainfo,bo2);
     end;
    finally
     dec(fupdating);
    end;
    if bo2 then begin
     goto endlab;
    end;
   end;
   case ainfo.objectkind of 
    sok_widget: begin
     handlewidget(ainfo);
     if sko_container in ainfo.options then begin
      handlecontainer(ainfo);
     end;
    end;
    sok_edit: begin
     handleedit(ainfo);
    end;
    sok_dataedit: begin
     handledataedit(ainfo);
    end;
    sok_booleanedit: begin
     handlebooleanedit(ainfo);
    end;
    sok_groupbox: begin
     handlegroupbox(ainfo);
    end;
    sok_simplebutton: begin
     handlesimplebutton(ainfo);
    end;
    sok_databutton: begin
     handledatabutton(ainfo);
    end;
    sok_tabbar: begin
     handletabbar(ainfo);
    end;
    sok_tabpage: begin
     handletabpage(ainfo);
    end;
    sok_toolbar: begin
     handletoolbar(ainfo);
    end;
    sok_mainmenu: begin
     handlemainmenu(ainfo);
    end;
    sok_popupmenu: begin
     handlepopupmenu(ainfo);
    end;
    sok_grid: begin
     handlegrid(ainfo);
    end;
    sok_user: begin
     handleuserobject(ainfo);
    end;
   end;
  end;
endlab:
  if assigned(fonafterupdate) then begin
   fonafterupdate(self,ainfo);
  end;
 end;
end;

procedure tcustomskincontroller.handlewidget(const ainfo: skininfoty);
begin
 //dummy
end;

procedure tcustomskincontroller.setfacetemplate(const face: tfacecomp;
                  const dest: tcustomface);   
begin
 if (face <> nil) and (dest.template = nil) then begin
  dest.template:= face;
 end;
end;

procedure tcustomskincontroller.setframetemplate(const frame: tframecomp;
                  const dest: tcustomframe);   
begin
 if (frame <> nil) and (dest.template = nil) then begin
  dest.template:= frame;
 end;
end;

procedure tcustomskincontroller.setwidgetface(const instance: twidget;
               const aface: tfacecomp);
begin
 with instance do begin
  if (aface <> nil) and (optionsskin * 
                       [osk_framebuttononly,osk_noface] = []) then begin
   createface;
   face.template:= aface;
  end;
 end;
end;
{
procedure tcustomskincontroller.setwidgetfacetemplate(const instance: twidget;
               const aface: tfacecomp);
begin
 with instance do begin
  if (aface <> nil) and not (osk_framebuttononly in optionsskin) then begin
   createface;
   face.template:= aface;
  end;
 end;
end;
}
procedure tcustomskincontroller.setwidgetframe(const instance: twidget;
               const aframe: tframecomp);
var
 size1: sizety;
 col1: colorty;
begin
 with twidget1(instance) do begin
  if (aframe <> nil) and (optionsskin * 
                       [osk_framebuttononly,osk_noframe] = []) then begin
   if fframe = nil then begin
    createframe;
    include(tcustomframe1(fframe).fstate,fs_paintposinited);
   end;
   col1:= frame.colorclient;
   size1:= clientsize;
   frame.template:= aframe;
   frame.colorclient:= col1;
   clientsize:= size1;      //same clientsize as before
  end;
 end;
end;
{
procedure tcustomskincontroller.setwidgetframetemplate(const instance: twidget;
               const aframe: tframecomp); //no frame nil check
var
 size1: sizety;
 col1: colorty;
begin
 with twidget1(instance) do begin
  if (aframe <> nil) and not (osk_framebuttononly in optionsskin) then begin
   if fframe = nil then begin
    createframe;
    include(tcustomframe1(fframe).fstate,fs_paintposinited);
   end;
   if  frame.template = nil then begin
    col1:= frame.colorclient;
    size1:= clientsize;
    frame.template:= aframe;
    frame.colorclient:= col1;
    clientsize:= size1;          //same clientsize as before
   end;
  end;
 end;
end;
}
procedure tcustomskincontroller.setwidgetskin(const instance: twidget;
               const ainfo: widgetskininfoty);
begin
 setwidgetface(instance,ainfo.fa);
 setwidgetframe(instance,ainfo.fra);
end;
{
procedure tcustomskincontroller.setwidgetskintemplate(const instance: twidget;
               const ainfo: widgetskininfoty);
begin
 setwidgetfacetemplate(instance,ainfo.fa);
 setwidgetframetemplate(instance,ainfo.fra);
end;
}
procedure tcustomskincontroller.setgroupboxskin(const instance: tgroupbox;
                                            const ainfo: groupboxskininfoty);
begin
 setwidgetskin(instance,ainfo.wi);
// setwidgetface(instance,ainfo.face);
// setwidgetframetemplate(instance,ainfo.frame);
end;

procedure tcustomskincontroller.setgridpropskin(const instance: tgridprop;
                                   const  ainfo: gridpropskininfoty);
begin
 if ainfo.face <> nil then begin
  with instance do begin
   createface;
   setfacetemplate(ainfo.face,face);
  end;
 end;
 if ainfo.frame <> nil then begin
  with instance do begin
   createframe;
   setframetemplate(ainfo.frame,frame);
  end;
 end;
end;

procedure tcustomskincontroller.setgridskin(const instance: tcustomgrid;
                                            const ainfo: gridskininfoty);
var
 int1,int2: integer;
begin
 setwidgetskin(instance,ainfo.wi);
// setwidgetface(instance,ainfo.face);
// setwidgetframetemplate(instance,ainfo.frame);
 with ainfo do begin
  for int1:= -1 downto -instance.fixrows.count do begin
   setgridpropskin(instance.fixrows[int1],ainfo.fixrows);
  end;
  for int1:= -1 downto -instance.fixcols.count do begin
   setgridpropskin(instance.fixcols[int1],ainfo.fixcols);
  end;
  for int1:= 0 to instance.datacols.count - 1 do begin
   setgridpropskin(instance.datacols[int1],ainfo.datacols);
  end;
 end;
end;

procedure tcustomskincontroller.setdataeditskin(const instance: tdataedit;
                                            const ainfo: dataeditskininfoty);
begin
 setwidgetskin(instance,ainfo.wi);
// setwidgetface(instance,ainfo.face);
// setwidgetframetemplate(instance,ainfo.frame);
end;

procedure tcustomskincontroller.setgraphdataeditskin(
           const instance: tgraphdataedit; const ainfo: dataeditskininfoty);
begin
 setwidgetskin(instance,ainfo.wi);
// setwidgetface(instance,ainfo.face);
// setwidgetframetemplate(instance,ainfo.frame);
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

procedure tcustomskincontroller.setstepbuttonskin(
                        const instance: tcustomstepframe;
                        const ainfo: stepbuttonskininfoty);
begin
 with instance,ainfo do begin
  if (colorbutton = cl_default) and 
                (co <> cl_default) then begin
   colorbutton:= co;
  end;
  if fra <> nil then begin
   instance.createbuttonframe;
   setframetemplate(fra,buttonframe);
  end;
  if fa <> nil then begin
   instance.createbuttonface;
   setfacetemplate(fa,buttonface);
  end;
 end;
end;

procedure tcustomskincontroller.setframebuttonskin(const instance: tframebutton;
               const ainfo: framebuttonskininfoty);
begin
 with instance,ainfo do begin
  if (co <> cl_default) and (color = cl_default) then begin
   color:= co;
  end;
  if (coglyph <> cl_default) and (colorglyph = cl_default) then begin
   colorglyph:= coglyph;
  end;
  if (fa <> nil) {and (face = nil)} then begin
   createface;
   setfacetemplate(fa,face);
//   face.template:= fa;
  end;
  if (fra <> nil) {and (frame = nil)} then begin
   createframe;
   setframetemplate(fra,frame);
//   frame.template:= fra;
  end;
 end;
end;

procedure tcustomskincontroller.setscrollbarskin(const instance: tcustomscrollbar;
               const ainfo: scrollbarskininfoty);
begin
 with instance,ainfo do begin
  if (facebu <> nil) {and (facebutton = nil)} then begin
   createfacebutton;
   setfacetemplate(facebu,facebutton);
//   facebutton.template:= facebu;
  end;
  if (faceendbu <> nil) {and (faceendbutton = nil)} then begin
   createfaceendbutton;
   setfacetemplate(faceendbu,faceendbutton);
//   faceendbutton.template:= faceendbu;
  end;
  if (framebu <> nil) {and (framebutton = nil)} then begin
   createframebutton;
   setframetemplate(framebu,framebutton);
//   framebutton.template:= framebu;
  end;
  if (frameendbu1 <> nil) {and (frameendbutton1 = nil)} then begin
   createframeendbutton1;
   setframetemplate(frameendbu1,frameendbutton1);
//   frameendbutton1.template:= frameendbu1;
  end;
  if (frameendbu2 <> nil) {and (frameendbutton2 = nil)} then begin
   createframeendbutton2;
   setframetemplate(frameendbu2,frameendbutton2);
//   frameendbutton2.template:= frameendbu2;
  end;
 end;
end;

procedure tcustomskincontroller.settabsskin(const instance: tcustomtabbar;
                                             const ainfo: tabsskininfoty);
var
 int1: integer;
begin
 with ttabs1(instance.tabs) do begin
  inc(fskinupdating);
  beginupdate;
  try
   if (ainfo.shift <> defaulttabshift) and (shift = defaulttabshift) then begin
    shift:= ainfo.shift;
   end;
   if {(frame = nil) and} (ainfo.frame <> nil) then begin
    createframe;
    setframetemplate(ainfo.frame,frame);
//    frame.template:= ainfo.frame;
   end;
   if {(face = nil) and} (ainfo.face <> nil) then begin
    createface;
    setfacetemplate(ainfo.face,face);
//    face.template:= ainfo.face;
   end;
   if {(faceactive = nil) and} (ainfo.faceactive <> nil) then begin
    createfaceactive;
    setfacetemplate(ainfo.faceactive,faceactive);
//    faceactive.template:= ainfo.faceactive;
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
   dec(fskinupdating);
  end;
 end;
end;

procedure tcustomskincontroller.setpopupmenuskin(const instance: tpopupmenu;
               const ainfo: menuskininfoty);
begin
 with instance do begin
 {
  if smo_noanim in ainfo.options then begin
   options:= options + [mo_noanim];
  end
  else begin
   options:= options - [mo_noanim];
  end;
  }
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

procedure tcustomskincontroller.setfontalias(const avalue: tskinfontaliass);
begin
 ffontalias.assign(avalue);
end;

procedure tcustomskincontroller.handlegroupbox(const ainfo: skininfoty);
begin
 //dummy
end;

procedure tcustomskincontroller.handlesimplebutton(const ainfo: skininfoty);
begin
 //dummy
end;

procedure tcustomskincontroller.handledatabutton(const ainfo: skininfoty);
begin
 //dummy
end;

procedure tcustomskincontroller.handleuserobject(const ainfo: skininfoty);
begin
 //dummy
end;

procedure tcustomskincontroller.handlecontainer(const ainfo: skininfoty);
begin
 //dummy
end;

procedure tcustomskincontroller.handletabbar(const ainfo: skininfoty);
begin
 //dummy
end;

procedure tcustomskincontroller.handletabpage(const ainfo: skininfoty);
begin
 //dummy
end;

procedure tcustomskincontroller.handleedit(const ainfo: skininfoty);
begin
 //dummy
end;

procedure tcustomskincontroller.handledataedit(const ainfo: skininfoty);
begin
 //dummy
end;

procedure tcustomskincontroller.handlebooleanedit(const ainfo: skininfoty);
begin
 //dummy
end;

procedure tcustomskincontroller.handlemainmenu(const ainfo: skininfoty);
begin
 //dummy
end;

procedure tcustomskincontroller.handlepopupmenu(const ainfo: skininfoty);
begin
 //dummy
end;

procedure tcustomskincontroller.handlegrid(const ainfo: skininfoty);
begin
 //dummy
end;

procedure tcustomskincontroller.handletoolbar(const ainfo: skininfoty);
begin
 //dummy
end;

procedure tcustomskincontroller.updateorder;
begin
 updateclientorder(fextendernames,pointerarty(fextenders),
                             {$ifdef FPC}@{$endif}getextendernames);
end;

function tcustomskincontroller.getextendernames: stringarty;
var
 int1: integer;
begin
 setlength(result,length(fextenders));
 for int1:= 0 to high(result) do begin
  result[int1]:= getclientname(fextenders[int1],int1);
 end;
end;

function tcustomskincontroller.getextenders: integer;
begin
 result:= length(fextenders);
end;

procedure tcustomskincontroller.setextenders(const avalue: integer);
begin
 //dummy
end;

procedure tcustomskincontroller.readextendernames(reader: treader);
begin
 readstringar(reader,fextendernames);
end;

procedure tcustomskincontroller.writeextendernames(writer: twriter);
begin
 writestringar(writer,getextendernames);
end;

procedure tcustomskincontroller.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('extendernames',{$ifdef FPC}@{$endif}readextendernames,
            {$ifdef FPC}@{$endif}writeextendernames,high(fextenders) >= 0);
end;

procedure tcustomskincontroller.registerextender(const aextender: tskinextender);
begin
 additem(pointerarty(fextenders),aextender);
end;

procedure tcustomskincontroller.unregisterextender(const aextender: tskinextender);
begin
 removeitem(pointerarty(fextenders),aextender);
end;

procedure tcustomskincontroller.objectevent(const sender: tobject;
               const event: objecteventty);
begin
 if event = oe_destroyed then begin
  removeitem(pointerarty(fextenders),sender);
 end;
 inherited;
end;

{ tskincontroller }

constructor tskincontroller.create(aowner: tcomponent);
begin
 fwidget_color:= cl_default;
 fwidget_colorcaptionframe:= cl_default;
 fstepbutton.co:= cl_default;
 fbutton.co:= cl_default;
 fdatabutton.co:= cl_default;
 fframebutton.co:= cl_default;
 fframebutton.coglyph:= cl_default;
 ftabbar.tahorz.color:= cl_default;
 ftabbar.tahorz.coloractive:= cl_default;
 ftabbar.tahorz.shift:= defaulttabshift;
 ftabbar.tavert.color:= cl_default;
 ftabbar.tavert.coloractive:= cl_default;
 ftabbar.tavert.shift:= defaulttabshift;
 ftabbar.tahorzopo.color:= cl_default;
 ftabbar.tahorzopo.coloractive:= cl_default;
 ftabbar.tahorzopo.shift:= defaulttabshift;
 ftabbar.tavertopo.color:= cl_default;
 ftabbar.tavertopo.coloractive:= cl_default;
 ftabbar.tavertopo.shift:= defaulttabshift;
 inherited;
end;

destructor tskincontroller.destroy;
begin
 inherited;
 fbutton.font.free;
end;

procedure tskincontroller.setdataedit_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fdataedit.wi.fa));
end;

procedure tskincontroller.setdataedit_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fdataedit.wi.fra));
end;

procedure tskincontroller.setbooleanedit_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fbooleanedit.wi.fa));
end;

procedure tskincontroller.setbooleanedit_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fbooleanedit.wi.fra));
end;

procedure tskincontroller.setcontainer_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fcontainer.wi.fa));
end;

procedure tskincontroller.setcontainer_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fcontainer.wi.fra));
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

procedure tskincontroller.setgroupbox_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fgroupbox.wi.fa));
end;

procedure tskincontroller.setgroupbox_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fgroupbox.wi.fra));
end;

procedure tskincontroller.setgrid_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fgrid.wi.fa));
end;

procedure tskincontroller.setgrid_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fgrid.wi.fra));
end;

procedure tskincontroller.setgrid_fixrows_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fgrid.fixrows.face));
end;

procedure tskincontroller.setgrid_fixrows_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fgrid.fixrows.frame));
end;

procedure tskincontroller.setgrid_fixcols_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fgrid.fixcols.face));
end;

procedure tskincontroller.setgrid_fixcols_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fgrid.fixcols.frame));
end;

procedure tskincontroller.setgrid_datacols_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fgrid.datacols.face));
end;

procedure tskincontroller.setgrid_datacols_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fgrid.datacols.frame));
end;

procedure tskincontroller.setbutton_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fbutton.wi.fa));
end;

procedure tskincontroller.setbutton_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fbutton.wi.fra));
end;

procedure tskincontroller.setdatabutton_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fdatabutton.wi.fa));
end;

procedure tskincontroller.setdatabutton_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fdatabutton.wi.fra));
end;

procedure tskincontroller.setframebutton_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fframebutton.fa));
end;

procedure tskincontroller.setframebutton_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fframebutton.fra));
end;

procedure tskincontroller.setstepbutton_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fstepbutton.fa));
end;

procedure tskincontroller.setstepbutton_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fstepbutton.fra));
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

procedure tskincontroller.settabbar_horz_tab_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabbar.tahorz.frame));
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

procedure tskincontroller.settabbar_vert_tab_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabbar.tavert.frame));
end;

procedure tskincontroller.settabbar_vert_tab_faceactive(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabbar.tavert.faceactive));
end;

procedure tskincontroller.settabbar_horzopo_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabbar.wihorzopo.fa));
end;

procedure tskincontroller.settabbar_horzopo_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabbar.wihorzopo.fra));
end;

procedure tskincontroller.settabbar_horzopo_tab_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabbar.tahorzopo.face));
end;

procedure tskincontroller.settabbar_horzopo_tab_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabbar.tahorzopo.frame));
end;

procedure tskincontroller.settabbar_horzopo_tab_faceactive(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabbar.tahorzopo.faceactive));
end;

procedure tskincontroller.settabbar_vertopo_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabbar.wivertopo.fa));
end;

procedure tskincontroller.settabbar_vertopo_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabbar.wivertopo.fra));
end;

procedure tskincontroller.settabbar_vertopo_tab_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabbar.tavertopo.face));
end;

procedure tskincontroller.settabbar_vertopo_tab_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabbar.tavertopo.frame));
end;

procedure tskincontroller.settabbar_vertopo_tab_faceactive(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabbar.tavertopo.faceactive));
end;

procedure tskincontroller.settabpage_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabpage.wi.fa));
end;

procedure tskincontroller.settabpage_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabpage.wi.fra));
end;

procedure tskincontroller.settoolbar_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftoolbar.wi.fa));
end;

procedure tskincontroller.settoolbar_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftoolbar.wi.fra));
end;

procedure tskincontroller.settoolbar_buttonface(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftoolbar.buttonface));
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

procedure tskincontroller.handlewidget(const ainfo: skininfoty);
var
 int1: integer;
 wi1: twidget1;
begin
 wi1:= twidget1(ainfo.instance);
 with wi1 do begin
  if fframe <> nil then begin
   if fframe is tcustomscrollframe then begin
    setscrollbarskin(tcustomscrollframe(fframe).sbvert,fsb_vert);
    setscrollbarskin(tcustomscrollframe(fframe).sbhorz,fsb_horz);
   end
   else begin
    if fframe is tcustombuttonframe then begin
     with tcustombuttonframe(fframe) do begin
      for int1:= 0 to buttons.count - 1 do begin
       setframebuttonskin(buttons[int1],fframebutton);
      end;
     end;
    end
    else begin
     if fframe is tcustomstepframe then begin
      setstepbuttonskin(tcustomstepframe(fframe),fstepbutton);
     end;
    end; 
   end; 
  end;
  if (osk_colorcaptionframe in optionsskin) or 
       not (osk_nocolorcaptionframe in optionsskin) and
         (fframe is tcustomcaptionframe) and 
       (tcustomcaptionframe(fframe).caption <> '') then begin
   setwidgetcolor(wi1,fwidget_colorcaptionframe);
  end
  else begin
   setwidgetcolor(wi1,fwidget_color);
  end;
 end;
end;

procedure tskincontroller.handlegroupbox(const ainfo: skininfoty);
begin
 handlewidget(ainfo);
 setgroupboxskin(tgroupbox(ainfo.instance),fgroupbox);
end;

procedure tskincontroller.handlesimplebutton(const ainfo: skininfoty);
begin
 handlewidget(ainfo);
 setwidgetcolor(twidget(ainfo.instance),fbutton.co);
 setwidgetskin(twidget(ainfo.instance),fbutton.wi);
 setwidgetfont(twidget(ainfo.instance),fbutton.font);
end;

procedure tskincontroller.handledatabutton(const ainfo: skininfoty);
begin
 handlewidget(ainfo);
 setwidgetcolor(twidget(ainfo.instance),fdatabutton.co);
 setwidgetskin(twidget(ainfo.instance),fdatabutton.wi);
 setwidgetfont(twidget(ainfo.instance),fdatabutton.font);
end;

procedure tskincontroller.handlecontainer(const ainfo: skininfoty);
begin
 setwidgetskin(twidget(ainfo.instance),fcontainer.wi);
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

procedure tskincontroller.createdatabutton_font;
begin
 if fdatabutton.font = nil then begin
  fdatabutton.font:= toptionalfont.create;
 end;
end;

procedure tskincontroller.setdatabutton_font(const avalue: toptionalfont);
begin
 setoptionalobject(avalue,fdatabutton.font,{$ifdef FPC}@{$endif}createbutton_font);
end;

function tskincontroller.getdatabutton_font: toptionalfont;
begin
 getoptionalobject(fdatabutton.font,{$ifdef FPC}@{$endif}createbutton_font);
 result:= fdatabutton.font;
end;

procedure tskincontroller.handletabbar(const ainfo: skininfoty);
var
 ta1: tcustomtabbar;
begin
 handlewidget(ainfo);
 ta1:= tcustomtabbar(ainfo.instance);
 if tabo_vertical in ta1.options then begin
  if tabo_opposite in ta1.options then begin
   setwidgetskin(ta1,ftabbar.wivertopo);
   settabsskin(ta1,ftabbar.tavertopo);
  end
  else begin
   setwidgetskin(ta1,ftabbar.wivert);
   settabsskin(ta1,ftabbar.tavert);
  end;
 end
 else begin
  if tabo_opposite in ta1.options then begin
   setwidgetskin(ta1,ftabbar.wihorzopo);
   settabsskin(ta1,ftabbar.tahorzopo);
  end
  else begin
   setwidgetskin(ta1,ftabbar.wihorz);
   settabsskin(ta1,ftabbar.tahorz);
  end;
 end;
 setstepbuttonskin(ta1.frame,fstepbutton);
end;

procedure tskincontroller.handletabpage(const ainfo: skininfoty);
begin
 handlewidget(ainfo);
 setwidgetskin(ttabpage(ainfo.instance),ftabpage.wi);
end;

procedure tskincontroller.handletoolbar(const ainfo: skininfoty);
var
 tb1: tcustomtoolbar;
begin
 handlewidget(ainfo);
 tb1:= tcustomtoolbar(ainfo.instance);
 setwidgetskin(tb1,ftoolbar.wi);
 setstepbuttonskin(tb1.frame,fstepbutton);
 if ftoolbar.buttonface <> nil then begin
  with tb1.buttons do begin
   createface;
   setfacetemplate(ftoolbar.buttonface,face);
  end;
 end;
end;

procedure tskincontroller.handleedit(const ainfo: skininfoty);
begin
 handlewidget(ainfo);
end;

procedure tskincontroller.handledataedit(const ainfo: skininfoty);
begin
 handlewidget(ainfo);
 setdataeditskin(tdataedit(ainfo.instance),fdataedit);
end;

procedure tskincontroller.handlebooleanedit(const ainfo: skininfoty);
begin
 handlewidget(ainfo);
 setgraphdataeditskin(tgraphdataedit(ainfo.instance),fbooleanedit);
end;

procedure tskincontroller.handlemainmenu(const ainfo: skininfoty);
begin
 setmainmenuskin(tcustommainmenu(ainfo.instance),fmainmenu);
end;

procedure tskincontroller.handlepopupmenu(const ainfo: skininfoty);
begin
 setpopupmenuskin(tpopupmenu(ainfo.instance),fpopupmenu);
end;

procedure tskincontroller.handlegrid(const ainfo: skininfoty);
begin
 handlewidget(ainfo);
 setgridskin(tcustomgrid(ainfo.instance),fgrid);
end;

{ tskinfontalias }

constructor tskinfontalias.create;
begin
 fmode:= fam_fixnooverwrite;
 inherited;
end;

{ tskinextender }

destructor tskinextender.destroy;
begin
 master:= nil; //unlink
 inherited;
end;

procedure tskinextender.setmaster(const avalue: tcustomskincontroller);
begin
 if fmaster <> nil then begin
  fmaster.unregisterextender(self);
 end;
 setlinkedvar(avalue,tmsecomponent(fmaster));
 if avalue <> nil then begin
  avalue.registerextender(self);
 end;
end;

procedure tskinextender.doactivate;
begin
 //dummy
end;

procedure tskinextender.dodeactivate;
begin
 //dummy
end;

procedure tskinextender.updateskin(const ainfo: skininfoty;
                                             var handled: boolean);
begin
 //dummy
end;

end.
