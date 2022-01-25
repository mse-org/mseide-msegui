{ MSEgui Copyright (c) 2008-2018 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseskin;
{$ifdef FPC}{$mode objfpc}{$h+}{$goto on}{$endif}
interface
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}
uses
 classes,mclasses,mseclasses,msegui,msescrollbar,mseedit,
 msegraphics,msegraphutils,msebitmap,
{$ifdef mse_dynpo}
 msestockobjects_dynpo,
{$else}
 msestockobjects,
{$endif}
 msetabs,msetoolbar,msedataedits,msemenus,msearrayprops,msegraphedits,
 msesimplewidgets,mseshapes,
 msegrids,msewidgets,msetypes,mseglob,msestrings,msedrawtext,mseguiglob;

type
 scrollbarskininfoty = record
  svwidth: int32;        //-2 -> default
  svcolor: colorty;
  svcolorpattern: colorty;
  svcolorpatternclicked: colorty;
  svcolorglyph: colorty;
  svbuttonendlength: int32; //-2 -> default
  svbuttonlength: int32; //-2 -> default
  svbuttonminlength: int32; //-2 -> default
  svindentstart: int32;  //0 -> default
  svindentend: int32;    //0 -> default
  svface: tfacecomp;
  svface1: tfacecomp;
  svface2: tfacecomp;
  svfacebu: tfacecomp;
  svfaceendbu: tfacecomp;
  svframe: tframecomp;
  svframebu: tframecomp;
  svframeendbu1: tframecomp;
  svframeendbu2: tframecomp;
 end;
 widgetcolorinfoty = record
  svcolor: colorty;
  svcolorcaptionframe: colorty;
 end;
 pwidgetcolorinfoty = ^widgetcolorinfoty;
 widgetskininfoty = record
  svface: tfacecomp;
  svframe: tframecomp;
 end;
 containerskininfoty = record
  svwidget: widgetskininfoty;
//  face: tfacecomp;
//  frame: tframecomp;
 end;
 groupboxskininfoty = record
  svwidget: widgetskininfoty;
//  face: tfacecomp;
//  frame: tframecomp;
 end;
 toolbarskininfoty = record
  svwidget: widgetskininfoty;
//  face: tfacecomp;
//  frame: tframecomp;
  svbuttonface: tfacecomp;
  svbuttonfacechecked: tfacecomp;
  svbuttonframe: tframecomp;
  svbuttonframechecked: tframecomp;
  svbuttonframesep: tframecomp;
 end;
 gridpropskininfoty = record
  svface: tfacecomp;
  svframe: tframecomp;
 end;
 gridskininfoty = record
  svwidget: widgetskininfoty;
//  face: tfacecomp;
//  frame: tframecomp;
  svfixrows: gridpropskininfoty;
  svfixcols: gridpropskininfoty;
  svdatacols: gridpropskininfoty;
 end;
 buttonskininfoty = record
  svcolor: colorty;
  svwidget: widgetskininfoty;
  svfont: toptionalfont;
  svoptionsadd: buttonoptionsty;
  svoptionsremove: buttonoptionsty;
 end;
 sliderskininfoty = record
  svcolor: colorty;
  svwidget: widgetskininfoty;
  svsb_vert: scrollbarskininfoty;
  svsb_horz: scrollbarskininfoty;
 end;
 stepbuttonskininfoty = record
  svcolor: colorty;
  svface: tfacecomp;
  svframe: tframecomp;
 end;
 framebuttonskininfoty = record
  svcolor: colorty;
  svcolorglyph: colorty;
  svface: tfacecomp;
  svframe: tframecomp;
 end;
 tabsskininfoty = record
  svcolor: colorty;
  svcoloractive: colorty;
  svframe: tframecomp;
  svface: tfacecomp;
  svfaceactive: tfacecomp;
  svshift: integer;
  svsedge_level: int32;
  svsedge_colordkshadow: colorty;
  svsedge_colorshadow: colorty;
  svsedge_colorlight: colorty;
  svsedge_colorhighlight: colorty;
  svsedge_colordkwidth: int32;
  svsedge_colorhlwidth: int32;
  svsedge_imagelist: timagelist;
  svsedge_imageoffset: int32;
  svsedge_imagepaintshift: int32;
 end;
 tabbarskininfoty = record
  svwidgethorz: widgetskininfoty;
  svwidgetvert: widgetskininfoty;
  svwidgethorzopo: widgetskininfoty;
  svwidgetvertopo: widgetskininfoty;
  svtabhorz: tabsskininfoty;
  svtabvert: tabsskininfoty;
  svtabhorzopo: tabsskininfoty;
  svtabvertopo: tabsskininfoty;
 end;
 tabpageskininfoty = record
  svwidget: widgetskininfoty;
  svcolortab: colorty;
  svcoloractivetab: colorty;
  svfacetab: tfacecomp;
  svfaceactivetab: tfacecomp;
  svfonttab: tfontcomp;
  svfontactivetab: tfontcomp;
 end;
 menuskininfoty = record
  svface: tfacecomp;
  svframe: tframecomp;
  svitemface: tfacecomp;
  svitemframe: tframecomp;
  svitemfaceactive: tfacecomp;
  svitemframeactive: tframecomp;
  svfont: tfontcomp;
  svfontactive: tfontcomp;
  svseparatorframe: tframecomp;
  svcheckboxframe: tframecomp;
//  options: skinmenuoptionsty;
 end;
 mainmenuskininfoty = record
  svmain: menuskininfoty;
  svpopup: menuskininfoty;
 end;
 mainmenuwidgetskininfoty = record
  svwidget: widgetskininfoty;
  svmenu: mainmenuskininfoty;
 end;
 dispwidgetskininfoty = record
  svwidget: widgetskininfoty;
  svcolor: widgetcolorinfoty;
 end;
 editskininfoty = record
  svwidget: widgetskininfoty;
  svempty_text: msestring;
  svempty_textflags: textflagsty;
  svempty_textcolor: colorty;
  svempty_textcolorbackground: colorty;
  svempty_fontstyle: fontstylesty;
  svempty_color: colorty;
 end;
 dataeditskininfoty = record
  svedit: editskininfoty;
 end;
 graphdataeditskininfoty = record
  svwidget: widgetskininfoty;
 end;
 booleaneditskininfoty = record
  svgraphdataedit: graphdataeditskininfoty;
  svoptionsadd: buttonoptionsty;
  svoptionsremove: buttonoptionsty;
 end;
 splitterskininfoty = record
  svwidget: widgetskininfoty;
  svcolor: widgetcolorinfoty;
  svcolorgrip: colorty;
  svgrip: stockbitmapty;
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
   feditfontcolors: editfontcolorinfoty;
   feditfontcolorsbefore: editfontcolorinfoty;
  public
   constructor create;
   class function getitemclasstype: persistentclassty; override;
   procedure setcolors;
   procedure restorecolors;
  published
   property colordkshadow: colorty read fframecolors.edges.shadow.effectcolor
              write fframecolors.edges.shadow.effectcolor default cl_default;
   property colorshadow: colorty read fframecolors.edges.shadow.color
              write fframecolors.edges.shadow.color default cl_default;
   property colorlight: colorty read fframecolors.edges.light.color
              write fframecolors.edges.light.color default cl_default;
   property colorhighlight: colorty read fframecolors.edges.light.effectcolor
              write fframecolors.edges.light.effectcolor default cl_default;
   property colordkwidth: integer read fframecolors.edges.shadow.effectwidth
              write fframecolors.edges.shadow.effectwidth default -1;
   property colorhlwidth: integer read fframecolors.edges.light.effectwidth
              write fframecolors.edges.light.effectwidth default -1;
   property colorframe: colorty read fframecolors.frame
              write fframecolors.frame default cl_default;
   property edittext: colorty read feditfontcolors.text
              write feditfontcolors.text default cl_default;
   property edittextbackground: colorty read feditfontcolors.textbackground
              write feditfontcolors.textbackground default cl_default;
   property editselectedtext: colorty read feditfontcolors.selectedtext
              write feditfontcolors.selectedtext default cl_default;
   property editselectedtextbackground: colorty
               read feditfontcolors.selectedtextbackground
             write feditfontcolors.selectedtextbackground default cl_default;
 end;

 tskinfontalias = class(townedpersistent)
  private
   fname: string;
   falias: string;
   fmode: fontaliasmodety;
   fheight: integer;
   fwidth: integer;
   foptions: fontoptionsty;
   fancestor: string;
   fxscale: real;
   ftemplate: tfontcomp;
   procedure settemplate(const avalue: tfontcomp);
  public
   constructor create(aowner: tobject); override;
  published
   property name: string read fname write fname;
   property alias: string read falias write falias;
   property ancestor: string read fancestor write fancestor;
   property mode: fontaliasmodety read fmode write fmode
                                                      default fam_overwrite;
   property height: integer read fheight write fheight default 0;
   property width: integer read fwidth write fwidth default 0;
   property options: fontoptionsty read foptions write foptions default [];
   property xscale: real read fxscale write fxscale;
   property template: tfontcomp read ftemplate write settemplate;
 end;

 tcustomskincontroller = class;

 tskinfontaliass = class(townedpersistentarrayprop)
  public
   constructor create(const aowner: tcustomskincontroller); reintroduce;
   class function getitemclasstype: persistentclassty; override;
   procedure setfontalias;
 end;

 createprocty = procedure of object;

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
   procedure updateskin(const ainfo: skininfoty; var handled: boolean);
                                        reintroduce; virtual;
   procedure removeskin(const ainfo: skininfoty; var handled: boolean); virtual;
  published
   property master: tcustomskincontroller read fmaster write setmaster;
 end;

 skinextenderarty = array of tskinextender;

 tskinfont = class(tlinkedpersistent)
  private
  {
   fcolor: colorty;
   fshadow_color: colorty;
   fshadow_shiftx: integer;
   fshadow_shifty: integer;
   fgloss_color: colorty;
   fgloss_shiftx: integer;
   fgloss_shifty: integer;
   fgrayed_color: colorty;
   fgrayed_colorshadow: colorty;
   fgrayed_shiftx: integer;
   fgrayed_shifty: integer;
   fextraspace: integer;
   fstyle: fontstylesty;
   fcolorbackground: colorty;
  }
   ftemplate: tfontcomp;
   procedure settemplate(const avalue: tfontcomp);
  public
//   constructor create;
   procedure updatefont(const adest: tfont);
  published
  {
   property color: colorty read fcolor write fcolor default cl_default;
   property colorbackground: colorty read fcolorbackground
                           write fcolorbackground default cl_default;
   property shadow_color: colorty read fshadow_color
                                write fshadow_color default cl_default;
   property shadow_shiftx: integer read fshadow_shiftx write
                fshadow_shiftx default 1;
   property shadow_shifty: integer read fshadow_shifty write
                fshadow_shifty default 1;

   property gloss_color: colorty read fgloss_color
                 write fgloss_color default cl_default;
   property gloss_shiftx: integer read fgloss_shiftx write
                fgloss_shiftx default -1;
   property gloss_shifty: integer read fgloss_shifty write
                fgloss_shifty default -1;

   property grayed_color: colorty read fgrayed_color
                                write fgrayed_color default cl_default;
   property grayed_colorshadow: colorty read fgrayed_colorshadow
                                write fgrayed_colorshadow default cl_default;
   property grayed_shiftx: integer read fgrayed_shiftx write
                fgrayed_shiftx default 1;
   property grayed_shifty: integer read fgrayed_shifty write
                fgrayed_shifty default 1;

   property extraspace: integer read fextraspace write fextraspace default 0;
   property style: fontstylesty read fstyle write fstyle default [];
  }
   property template: tfontcomp read ftemplate write settemplate;
 end;

 groupinfoty = record
                min: integer;
                max: integer;
               end;
 groupinfoarty = array of groupinfoty;

 tcustomskincontroller = class(tmsecomponent)
  private
   fonbeforeupdate: beforeskinupdateeventty;
   fonafterupdate: skincontrollereventty;
   fonactivate: notifyeventty;
   fondeactivate: notifyeventty;
   fcolors: tskincolors;
   ffontalias: tskinfontaliass;
   fupdating: integer;
   factive: boolean;
   factivedesign: boolean;
   fisactive: boolean;
//   fremoving: boolean;
   fskinfonts: array[stockfontty] of tskinfont;
   fgroupinfo: groupinfoarty;
   fgroups: string;
   forder: integer;
   fhotkey_fontstylesadd: fontstylesty;
   fhotkey_fontstylesremove: fontstylesty;
   fhotkey_color: colorty;
   fhotkey_colorbackground: colorty;
   procedure setactive(const avalue: boolean);
   procedure setcolors(const avalue: tskincolors);
   procedure setfontalias(const avalue: tskinfontaliass);
   function getextenders: integer;
   procedure setextenders(const avalue: integer);
   procedure readextendernames(reader: treader);
   procedure writeextendernames(writer: twriter);
   procedure readactivedesign(reader: treader);
//   procedure setactivedesign(const avalue: boolean);
   function getskinfont(const aindex: integer): tskinfont;
   procedure setskinfont(const aindex: integer; const avalue: tskinfont);
   procedure setgroups(const avalue: string);
   procedure checkactive;
   procedure sethotkey_fontstylesadd(const avalue: fontstylesty);
   procedure sethotkey_fontstylesremove(const avalue: fontstylesty);
   procedure sethotkey_colorbackground(const avalue: colorty);
   procedure sethotkey_color(const avalue: colorty);
   procedure checkhotkey();
  protected
   fextendernames: stringarty;
   fextenders: skinextenderarty;
   fhashotkey: boolean;
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
   procedure seteditskin(const instance: tcustomedit;
                                            const ainfo: editskininfoty);
   procedure setdataeditskin(const instance: tdataedit;
                                            const ainfo: dataeditskininfoty);
   procedure setgraphdataeditskin(const instance: tgraphdataedit;
                                         const ainfo: graphdataeditskininfoty);
   procedure setwidgetfont(const instance: twidget; const afont: tfont);
   procedure setwidgetcolor(const instance: twidget; const acolor: colorty);
   function setwidgetcolorcaptionframe(
                   const awidget: twidget; const acolor: colorty): boolean;
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

   procedure handlewidget(const askin: skininfoty;
                          const acolor: pwidgetcolorinfoty = nil); virtual;
   procedure handlecontainer(const ainfo: skininfoty); virtual;
   procedure handlegroupbox(const ainfo: skininfoty); virtual;
   procedure handlesimplebutton(const ainfo: skininfoty); virtual;
   procedure handledatabutton(const ainfo: skininfoty); virtual;
   procedure handleslider(const ainfo: skininfoty); virtual;
   procedure handleuserobject(const ainfo: skininfoty); virtual;
   procedure handletabbar(const ainfo: skininfoty); virtual;
   procedure handletabpage(const ainfo: skininfoty); virtual;
   procedure handletoolbar(const ainfo: skininfoty); virtual;
   procedure handlesplitter(const ainfo: skininfoty); virtual;
   procedure handledispwidget(const ainfo: skininfoty); virtual;
   procedure handleedit(const ainfo: skininfoty); virtual;
   procedure handledataedit(const ainfo: skininfoty); virtual;
   procedure handlebooleanedit(const ainfo: skininfoty); virtual;
   procedure handlemainmenu(const ainfo: skininfoty); virtual;
   procedure handlepopupmenu(const ainfo: skininfoty); virtual;
   procedure handlemainmenuwidget(const ainfo: skininfoty); virtual;
   procedure handlegrid(const ainfo: skininfoty); virtual;
   procedure updateskin1(const ainfo: skininfoty; const remove: boolean);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure updateskin(const ainfo: skininfoty); reintroduce;
 //  procedure removeskin(const ainfo: skininfoty);
//   property removing: boolean read fremoving;
  published
   property order: integer read forder write forder default 0; //first!
              //higher order executed first
   property active: boolean read factive write setactive default false;
//   property activedesign: boolean read factivedesign
//                                         write setactivedesign default false;
         //removed, too dangerous
   property extenders: integer read getextenders write setextenders;
                                  //hook for object inspector
   property groups: string read fgroups write setgroups;
              //format [<group>[..<groupmax>]{,<group>[..<groupmax>]}]
              //empty -> all
   property onbeforeupdate: beforeskinupdateeventty read fonbeforeupdate
                                 write fonbeforeupdate;
   property onafterupdate: skincontrollereventty read fonafterupdate
                                 write fonafterupdate;
   property onactivate: notifyeventty read fonactivate write fonactivate;
   property ondeactivate: notifyeventty read fondeactivate write fondeactivate;
   property colors: tskincolors read fcolors write setcolors;
   property fontalias: tskinfontaliass read ffontalias write setfontalias;

   property font_default: tskinfont index ord(stf_default)           //0
                         read getskinfont write setskinfont;
   property font_empty: tskinfont index ord(stf_empty)               //1
                         read getskinfont write setskinfont;
   property font_unicode: tskinfont index ord(stf_unicode)           //2
                         read getskinfont write setskinfont;
   property font_menu: tskinfont index ord(stf_menu)                 //3
                         read getskinfont write setskinfont;
   property font_message: tskinfont index ord(stf_message)           //4
                         read getskinfont write setskinfont;
   property font_hint: tskinfont index ord(stf_hint)                 //5
                         read getskinfont write setskinfont;
   property font_report: tskinfont index ord(stf_report)             //6
                         read getskinfont write setskinfont;
   property font_proportional: tskinfont index ord(stf_proportional) //7
                         read getskinfont write setskinfont;
   property font_fixed: tskinfont index ord(stf_fixed)               //8
                         read getskinfont write setskinfont;
   property font_helvetica: tskinfont index ord(stf_helvetica)       //9
                         read getskinfont write setskinfont;
   property font_roman: tskinfont index ord(stf_roman)               //10
                         read getskinfont write setskinfont;
   property font_courier: tskinfont index ord(stf_courier)           //11
                         read getskinfont write setskinfont;

   property hotkey_fontstylesadd: fontstylesty read fhotkey_fontstylesadd
                            write sethotkey_fontstylesadd default [];
   property hotkey_fontstylesremove: fontstylesty read fhotkey_fontstylesremove
                            write sethotkey_fontstylesremove default [];
   property hotkey_color: colorty read fhotkey_color write sethotkey_color
                                                          default cl_default;
   property hotkey_colorbackground: colorty read fhotkey_colorbackground
                             write sethotkey_colorbackground default cl_default;
 end;

 tskincontroller = class(tcustomskincontroller)
  private
   fsb_horz: scrollbarskininfoty;
   fsb_vert: scrollbarskininfoty;
   fgroupbox: groupboxskininfoty;
   fgrid: gridskininfoty;
   fbutton: buttonskininfoty;
   fdatabutton: buttonskininfoty;
   fslider: sliderskininfoty;
   fstepbutton: stepbuttonskininfoty;
   fframebutton: framebuttonskininfoty;
   fcontainer: containerskininfoty;
   fwidgetcolor: widgetcolorinfoty;
   ftabbar: tabbarskininfoty;
   ftabpage: tabpageskininfoty;
   ftoolbar_horz: toolbarskininfoty;
   ftoolbar_vert: toolbarskininfoty;
   fpopupmenu: menuskininfoty;
   fmainmenu: mainmenuskininfoty;
   fmainmenuwidget: mainmenuwidgetskininfoty;
   fdispwidget: dispwidgetskininfoty;
   fedit: editskininfoty;
   fdataedit: dataeditskininfoty;
   fbooleanedit: booleaneditskininfoty;
   fsplitter: splitterskininfoty;

   procedure setsb_vert_face(const avalue: tfacecomp);
   procedure setsb_vert_face1(const avalue: tfacecomp);
   procedure setsb_vert_face2(const avalue: tfacecomp);
   procedure setsb_vert_facebutton(const avalue: tfacecomp);
   procedure setsb_vert_faceendbutton(const avalue: tfacecomp);
   procedure setsb_vert_frame(const avalue: tframecomp);
   procedure setsb_vert_framebutton(const avalue: tframecomp);
   procedure setsb_vert_frameendbutton1(const avalue: tframecomp);
   procedure setsb_vert_frameendbutton2(const avalue: tframecomp);
   procedure setsb_horz_face(const avalue: tfacecomp);
   procedure setsb_horz_face1(const avalue: tfacecomp);
   procedure setsb_horz_face2(const avalue: tfacecomp);
   procedure setsb_horz_facebutton(const avalue: tfacecomp);
   procedure setsb_horz_faceendbutton(const avalue: tfacecomp);
   procedure setsb_horz_frame(const avalue: tframecomp);
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

   procedure setslider_face(const avalue: tfacecomp);
   procedure setslider_frame(const avalue: tframecomp);
   procedure setssb_vert_face(const avalue: tfacecomp);
   procedure setssb_vert_face1(const avalue: tfacecomp);
   procedure setssb_vert_face2(const avalue: tfacecomp);
   procedure setssb_vert_facebutton(const avalue: tfacecomp);
   procedure setssb_vert_faceendbutton(const avalue: tfacecomp);
   procedure setssb_vert_frame(const avalue: tframecomp);
   procedure setssb_vert_framebutton(const avalue: tframecomp);
   procedure setssb_vert_frameendbutton1(const avalue: tframecomp);
   procedure setssb_vert_frameendbutton2(const avalue: tframecomp);
   procedure setssb_horz_face(const avalue: tfacecomp);
   procedure setssb_horz_face1(const avalue: tfacecomp);
   procedure setssb_horz_face2(const avalue: tfacecomp);
   procedure setssb_horz_facebutton(const avalue: tfacecomp);
   procedure setssb_horz_faceendbutton(const avalue: tfacecomp);
   procedure setssb_horz_frame(const avalue: tframecomp);
   procedure setssb_horz_framebutton(const avalue: tframecomp);
   procedure setssb_horz_frameendbutton1(const avalue: tframecomp);
   procedure setssb_horz_frameendbutton2(const avalue: tframecomp);

   procedure setframebutton_face(const avalue: tfacecomp);
   procedure setframebutton_frame(const avalue: tframecomp);

   procedure setstepbutton_face(const avalue: tfacecomp);
   procedure setstepbutton_frame(const avalue: tframecomp);

   procedure setsplitter_face(const avalue: tfacecomp);
   procedure setsplitter_frame(const avalue: tframecomp);

   procedure setdispwidget_face(const avalue: tfacecomp);
   procedure setdispwidget_frame(const avalue: tframecomp);

   procedure setedit_face(const avalue: tfacecomp);
   procedure setedit_frame(const avalue: tframecomp);

   procedure setdataedit_face(const avalue: tfacecomp);
   procedure setdataedit_frame(const avalue: tframecomp);

   procedure setbooleanedit_face(const avalue: tfacecomp);
   procedure setbooleanedit_frame(const avalue: tframecomp);

   procedure setcontainer_face(const avalue: tfacecomp);
   procedure setcontainer_frame(const avalue: tframecomp);

   procedure settabbar_horz_tab_edge_imagelist(const avalue: timagelist);
   procedure settabbar_horz_face(const avalue: tfacecomp);
   procedure settabbar_horz_frame(const avalue: tframecomp);
   procedure settabbar_horz_tab_frame(const avalue: tframecomp);
   procedure settabbar_horz_tab_face(const avalue: tfacecomp);
   procedure settabbar_horz_tab_faceactive(const avalue: tfacecomp);
   procedure settabbar_vert_tab_edge_imagelist(const avalue: timagelist);
   procedure settabbar_vert_face(const avalue: tfacecomp);
   procedure settabbar_vert_frame(const avalue: tframecomp);
   procedure settabbar_vert_tab_frame(const avalue: tframecomp);
   procedure settabbar_vert_tab_face(const avalue: tfacecomp);
   procedure settabbar_vert_tab_faceactive(const avalue: tfacecomp);

   procedure settabbar_horzopo_tab_edge_imagelist(const avalue: timagelist);
   procedure settabbar_horzopo_face(const avalue: tfacecomp);
   procedure settabbar_horzopo_frame(const avalue: tframecomp);
   procedure settabbar_horzopo_tab_frame(const avalue: tframecomp);
   procedure settabbar_horzopo_tab_face(const avalue: tfacecomp);
   procedure settabbar_horzopo_tab_faceactive(const avalue: tfacecomp);
   procedure settabbar_vertopo_tab_edge_imagelist(const avalue: timagelist);
   procedure settabbar_vertopo_face(const avalue: tfacecomp);
   procedure settabbar_vertopo_frame(const avalue: tframecomp);
   procedure settabbar_vertopo_tab_frame(const avalue: tframecomp);
   procedure settabbar_vertopo_tab_face(const avalue: tfacecomp);
   procedure settabbar_vertopo_tab_faceactive(const avalue: tfacecomp);

   procedure settabpage_face(const avalue: tfacecomp);
   procedure settabpage_facetab(const avalue: tfacecomp);
   procedure settabpage_faceactivetab(const avalue: tfacecomp);
   procedure settabpage_frame(const avalue: tframecomp);
   procedure settabpage_fonttab(const avalue: tfontcomp);
   procedure settabpage_fontactivetab(const avalue: tfontcomp);

   procedure settoolbar_horz_face(const avalue: tfacecomp);
   procedure settoolbar_horz_frame(const avalue: tframecomp);
   procedure settoolbar_horz_buttonface(const avalue: tfacecomp);
   procedure settoolbar_horz_buttonfacechecked(const avalue: tfacecomp);
   procedure settoolbar_horz_buttonframe(const avalue: tframecomp);
   procedure settoolbar_horz_buttonframechecked(const avalue: tframecomp);
   procedure settoolbar_horz_buttonframesep(const avalue: tframecomp);
   procedure settoolbar_vert_face(const avalue: tfacecomp);
   procedure settoolbar_vert_frame(const avalue: tframecomp);
   procedure settoolbar_vert_buttonface(const avalue: tfacecomp);
   procedure settoolbar_vert_buttonfacechecked(const avalue: tfacecomp);
   procedure settoolbar_vert_buttonframe(const avalue: tframecomp);
   procedure settoolbar_vert_buttonframechecked(const avalue: tframecomp);
   procedure settoolbar_vert_buttonframesep(const avalue: tframecomp);


   procedure setpopupmenu_face(const avalue: tfacecomp);
   procedure setpopupmenu_frame(const avalue: tframecomp);
   procedure setpopupmenu_itemface(const avalue: tfacecomp);
   procedure setpopupmenu_itemframe(const avalue: tframecomp);
   procedure setpopupmenu_itemfaceactive(const avalue: tfacecomp);
   procedure setpopupmenu_itemframeactive(const avalue: tframecomp);
   procedure setpopupmenu_font(const avalue: tfontcomp);
   procedure setpopupmenu_fontactive(const avalue: tfontcomp);
   procedure setpopupmenu_separatorframe(const avalue: tframecomp);
   procedure setpopupmenu_checkboxframe(const avalue: tframecomp);

   procedure setmainmenu_face(const avalue: tfacecomp);
   procedure setmainmenu_frame(const avalue: tframecomp);
   procedure setmainmenu_itemface(const avalue: tfacecomp);
   procedure setmainmenu_itemframe(const avalue: tframecomp);
   procedure setmainmenu_itemfaceactive(const avalue: tfacecomp);
   procedure setmainmenu_itemframeactive(const avalue: tframecomp);
   procedure setmainmenu_font(const avalue: tfontcomp);
   procedure setmainmenu_fontactive(const avalue: tfontcomp);
   procedure setmainmenu_separatorframe(const avalue: tframecomp);
   procedure setmainmenu_checkboxframe(const avalue: tframecomp);
   procedure setmainmenu_popupface(const avalue: tfacecomp);
   procedure setmainmenu_popupframe(const avalue: tframecomp);
   procedure setmainmenu_popupitemface(const avalue: tfacecomp);
   procedure setmainmenu_popupitemframe(const avalue: tframecomp);
   procedure setmainmenu_popupitemfaceactive(const avalue: tfacecomp);
   procedure setmainmenu_popupitemframeactive(const avalue: tframecomp);
   procedure setmainmenu_popupfont(const avalue: tfontcomp);
   procedure setmainmenu_popupfontactive(const avalue: tfontcomp);
   procedure setmainmenu_popupseparatorframe(const avalue: tframecomp);
   procedure setmainmenu_popupcheckboxframe(const avalue: tframecomp);

   procedure setmainmenuwidget_face(const avalue: tfacecomp);
   procedure setmainmenuwidget_frame(const avalue: tframecomp);
   procedure setmainmenuwidget_itemface(const avalue: tfacecomp);
   procedure setmainmenuwidget_itemframe(const avalue: tframecomp);
   procedure setmainmenuwidget_itemfaceactive(const avalue: tfacecomp);
   procedure setmainmenuwidget_itemframeactive(const avalue: tframecomp);
   procedure setmainmenuwidget_font(const avalue: tfontcomp);
   procedure setmainmenuwidget_fontactive(const avalue: tfontcomp);
   procedure setmainmenuwidget_separatorframe(const avalue: tframecomp);
   procedure setmainmenuwidget_checkboxframe(const avalue: tframecomp);
   procedure setmainmenuwidget_popupface(const avalue: tfacecomp);
   procedure setmainmenuwidget_popupframe(const avalue: tframecomp);
   procedure setmainmenuwidget_popupitemface(const avalue: tfacecomp);
   procedure setmainmenuwidget_popupitemframe(const avalue: tframecomp);
   procedure setmainmenuwidget_popupitemfaceactive(const avalue: tfacecomp);
   procedure setmainmenuwidget_popupitemframeactive(const avalue: tframecomp);
   procedure setmainmenuwidget_popupfont(const avalue: tfontcomp);
   procedure setmainmenuwidget_popupfontactive(const avalue: tfontcomp);
   procedure setmainmenuwidget_popupseparatorframe(const avalue: tframecomp);
   procedure setmainmenuwidget_popupcheckboxframe(const avalue: tframecomp);
  protected
   procedure handlewidget(const askin: skininfoty;
                           const acolor: pwidgetcolorinfoty = nil); override;
   procedure handlecontainer(const ainfo: skininfoty); override;
   procedure handlegroupbox(const ainfo: skininfoty); override;
   procedure handlesimplebutton(const ainfo: skininfoty); override;
   procedure handledatabutton(const ainfo: skininfoty); override;
   procedure handleslider(const ainfo: skininfoty); override;
   procedure handletabbar(const ainfo: skininfoty); override;
   procedure handletabpage(const ainfo: skininfoty); override;
   procedure handletoolbar(const ainfo: skininfoty); override;
   procedure handlesplitter(const ainfo: skininfoty); override;
   procedure handledispwidget(const ainfo: skininfoty); override;
   procedure handleedit(const ainfo: skininfoty); override;
   procedure handledataedit(const ainfo: skininfoty); override;
   procedure handlebooleanedit(const ainfo: skininfoty); override;
   procedure handlemainmenu(const ainfo: skininfoty); override;
   procedure handlepopupmenu(const ainfo: skininfoty); override;
   procedure handlemainmenuwidget(const ainfo: skininfoty); override;
   procedure handlegrid(const ainfo: skininfoty); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure createbutton_font;
   procedure createdatabutton_font;
  published
   property sb_horz_width: int32 read fsb_horz.svwidth
                                 write fsb_horz.svwidth default -2;
   property sb_horz_color: colorty
                      read fsb_horz.svcolor
                    write fsb_horz.svcolor default cl_default;
   property sb_horz_colorpattern: colorty
                      read fsb_horz.svcolorpattern
                    write fsb_horz.svcolorpattern default cl_default;
   property sb_horz_colorpatternclicked: colorty
                      read fsb_horz.svcolorpatternclicked
                    write fsb_horz.svcolorpatternclicked default cl_default;
   property sb_horz_colorglyph: colorty
                        read fsb_horz.svcolorglyph
                      write fsb_horz.svcolorglyph default cl_default;
   property sb_horz_buttonendlength: int32 read fsb_horz.svbuttonendlength
                                 write fsb_horz.svbuttonendlength default -2;
   property sb_horz_buttonlength: int32 read fsb_horz.svbuttonlength
                                 write fsb_horz.svbuttonlength default -2;
   property sb_horz_buttonminlength: int32 read fsb_horz.svbuttonminlength
                                 write fsb_horz.svbuttonminlength default -2;
   property sb_horz_indentstart: int32 read fsb_horz.svindentstart
                                  write fsb_horz.svindentstart default 0;
   property sb_horz_indentend: int32 read fsb_horz.svindentend
                                  write fsb_horz.svindentend default 0;
   property sb_horz_face: tfacecomp read fsb_horz.svface
                        write setsb_horz_face;
   property sb_horz_face1: tfacecomp read fsb_horz.svface1
                        write setsb_horz_face1;
   property sb_horz_face2: tfacecomp read fsb_horz.svface2
                        write setsb_horz_face2;
   property sb_horz_facebutton: tfacecomp read fsb_horz.svfacebu
                        write setsb_horz_facebutton;
   property sb_horz_faceendbutton: tfacecomp read fsb_horz.svfaceendbu
                        write setsb_horz_faceendbutton;
   property sb_horz_frame: tframecomp read fsb_horz.svframe
                        write setsb_horz_frame;
   property sb_horz_framebutton: tframecomp read fsb_horz.svframebu
                        write setsb_horz_framebutton;
   property sb_horz_frameendbutton1: tframecomp read fsb_horz.svframeendbu1
                        write setsb_horz_frameendbutton1;
   property sb_horz_frameendbutton2: tframecomp read fsb_horz.svframeendbu2
                        write setsb_horz_frameendbutton2;

   property sb_vert_width: int32 read fsb_vert.svwidth
                                 write fsb_vert.svwidth default -2;
   property sb_vert_color: colorty read fsb_vert.svcolor
                    write fsb_vert.svcolor default cl_default;
   property sb_vert_colorpattern: colorty read fsb_vert.svcolorpattern
                    write fsb_vert.svcolorpattern default cl_default;
   property sb_vert_colorpatternclicked: colorty
                    read fsb_vert.svcolorpatternclicked
                    write fsb_vert.svcolorpatternclicked default cl_default;
   property sb_vert_colorglyph: colorty
                        read fsb_vert.svcolorglyph
                      write fsb_vert.svcolorglyph default cl_default;
   property sb_vert_buttonendlength: int32 read fsb_vert.svbuttonendlength
                                 write fsb_vert.svbuttonendlength default -2;
   property sb_vert_buttonlength: int32 read fsb_vert.svbuttonlength
                                 write fsb_vert.svbuttonlength default -2;
   property sb_vert_buttonminlength: int32 read fsb_vert.svbuttonminlength
                                 write fsb_vert.svbuttonminlength default -2;
   property sb_vert_indentstart: int32 read fsb_vert.svindentstart
                                  write fsb_vert.svindentstart default 0;
   property sb_vert_indentend: int32 read fsb_vert.svindentend
                                  write fsb_vert.svindentend default 0;
   property sb_vert_face: tfacecomp read fsb_vert.svface
                        write setsb_vert_face;
   property sb_vert_face1: tfacecomp read fsb_vert.svface1
                        write setsb_vert_face1;
   property sb_vert_face2: tfacecomp read fsb_vert.svface2
                        write setsb_vert_face2;
   property sb_vert_facebutton: tfacecomp read fsb_vert.svfacebu
                        write setsb_vert_facebutton;
   property sb_vert_faceendbutton: tfacecomp read fsb_vert.svfaceendbu
                        write setsb_vert_faceendbutton;
   property sb_vert_frame: tframecomp read fsb_vert.svframe
                        write setsb_vert_frame;
   property sb_vert_framebutton: tframecomp read fsb_vert.svframebu
                        write setsb_vert_framebutton;
   property sb_vert_frameendbutton1: tframecomp read fsb_vert.svframeendbu1
                        write setsb_vert_frameendbutton1;
   property sb_vert_frameendbutton2: tframecomp read fsb_vert.svframeendbu2
                        write setsb_vert_frameendbutton2;

   property stepbutton_color: colorty read fstepbutton.svcolor
                        write fstepbutton.svcolor default cl_default;
   property stepbutton_frame: tframecomp read fstepbutton.svframe
                        write setstepbutton_frame;
   property stepbutton_face: tfacecomp read fstepbutton.svface
                        write setstepbutton_face;

   property widget_color: colorty read fwidgetcolor.svcolor
                        write fwidgetcolor.svcolor default cl_default;
   property widget_colorcaptionframe: colorty
                        read fwidgetcolor.svcolorcaptionframe
                 write fwidgetcolor.svcolorcaptionframe default cl_default;
                        //overrides widget_color for widgets with frame caption

   property splitter_color: colorty read fsplitter.svcolor.svcolor
                         write fsplitter.svcolor.svcolor default cl_default;
   property splitter_colorcaptionframe: colorty
                         read fsplitter.svcolor.svcolorcaptionframe
              write fsplitter.svcolor.svcolorcaptionframe default cl_default;
                        //overrides widget_color for widgets with frame caption
   property splitter_colorgrip: colorty read fsplitter.svcolorgrip
                         write fsplitter.svcolorgrip default cl_default;
   property splitter_grip: stockbitmapty read fsplitter.svgrip
                         write fsplitter.svgrip default stb_default;
   property splitter_face: tfacecomp read fsplitter.svwidget.svface
                                            write setsplitter_face;
   property splitter_frame: tframecomp read fsplitter.svwidget.svframe
                                            write setsplitter_frame;

   property dispwidget_color: colorty read fdispwidget.svcolor.svcolor
                         write fdispwidget.svcolor.svcolor default cl_default;
   property dispwidget_colorcaptionframe: colorty
                         read fdispwidget.svcolor.svcolorcaptionframe
              write fdispwidget.svcolor.svcolorcaptionframe default cl_default;
                        //overrides widget_color for widgets with frame caption
   property dispwidget_face: tfacecomp read fdispwidget.svwidget.svface
                                            write setdispwidget_face;
   property dispwidget_frame: tframecomp read fdispwidget.svwidget.svframe
                                            write setdispwidget_frame;

   property dataedit_face: tfacecomp read fdataedit.svedit.svwidget.svface
                                                 write setdataedit_face;
   property dataedit_frame: tframecomp read fdataedit.svedit.svwidget.svframe
                                                    write setdataedit_frame;
   property dataedit_empty_text: msestring read fdataedit.svedit.svempty_text
                                           write fdataedit.svedit.svempty_text;
   property dataedit_empty_color: colorty read fdataedit.svedit.svempty_color
                       write fdataedit.svedit.svempty_color default cl_default;
   property dataedit_empty_fontstyle: fontstylesty
                        read fdataedit.svedit.svempty_fontstyle
                          write fdataedit.svedit.svempty_fontstyle default [];
   property dataedit_empty_textflags: textflagsty
                  read fdataedit.svedit.svempty_textflags
                           write fdataedit.svedit.svempty_textflags default [];
   property dataedit_empty_textcolor: colorty
                          read fdataedit.svedit.svempty_textcolor
                   write fdataedit.svedit.svempty_textcolor default cl_default;
   property dataedit_empty_textcolorbackground: colorty
                     read fdataedit.svedit.svempty_textcolorbackground
        write fdataedit.svedit.svempty_textcolorbackground default cl_default;

   property edit_face: tfacecomp read fedit.svwidget.svface
                                                 write setedit_face;
   property edit_frame: tframecomp read fedit.svwidget.svframe
                                                    write setedit_frame;
   property edit_empty_text: msestring read fedit.svempty_text
                                           write fedit.svempty_text;
   property edit_empty_color: colorty read fedit.svempty_color
                       write fedit.svempty_color default cl_default;
   property edit_empty_fontstyle: fontstylesty
                        read fedit.svempty_fontstyle
                          write fedit.svempty_fontstyle default [];
   property edit_empty_textflags: textflagsty
                  read fedit.svempty_textflags
                           write fedit.svempty_textflags default [];
   property edit_empty_textcolor: colorty
                          read fedit.svempty_textcolor
                   write fedit.svempty_textcolor default cl_default;
   property edit_empty_textcolorbackground: colorty
                     read fedit.svempty_textcolorbackground
        write fedit.svempty_textcolorbackground default cl_default;

   property booleanedit_face: tfacecomp
             read fbooleanedit.svgraphdataedit.svwidget.svface
                                                   write setbooleanedit_face;
   property booleanedit_frame: tframecomp
                read fbooleanedit.svgraphdataedit.svwidget.svframe
                                                write setbooleanedit_frame;
   property booleanedit_optionsadd: buttonoptionsty
                        read fbooleanedit.svoptionsadd
                                write fbooleanedit.svoptionsadd default[];
   property booleanedit_optionsremove: buttonoptionsty
                       read fbooleanedit.svoptionsremove
                                write fbooleanedit.svoptionsremove default[];

   property container_face: tfacecomp read fcontainer.svwidget.svface
                                              write setcontainer_face;
   property container_frame: tframecomp read fcontainer.svwidget.svframe
                                              write setcontainer_frame;
   property groupbox_face: tfacecomp read fgroupbox.svwidget.svface
                                                  write setgroupbox_face;
   property groupbox_frame: tframecomp read fgroupbox.svwidget.svframe
                                                       write setgroupbox_frame;

   property grid_face: tfacecomp read fgrid.svwidget.svface write setgrid_face;
   property grid_frame: tframecomp read fgrid.svwidget.svframe
                                                   write setgrid_frame;
   property grid_fixrows_face: tfacecomp read fgrid.svfixrows.svface
                            write setgrid_fixrows_face;
   property grid_fixrows_frame: tframecomp read fgrid.svfixrows.svframe
                            write setgrid_fixrows_frame;
   property grid_fixcols_face: tfacecomp read fgrid.svfixcols.svface
                            write setgrid_fixcols_face;
   property grid_fixcols_frame: tframecomp read fgrid.svfixcols.svframe
                            write setgrid_fixcols_frame;
   property grid_datacols_face: tfacecomp read fgrid.svdatacols.svface
                            write setgrid_datacols_face;
   property grid_datacols_frame: tframecomp read fgrid.svdatacols.svframe
                            write setgrid_datacols_frame;

   property button_color: colorty read fbutton.svcolor write fbutton.svcolor
                                                  default cl_default;
   property button_face: tfacecomp read fbutton.svwidget.svface
                                                        write setbutton_face;
   property button_frame: tframecomp read fbutton.svwidget.svframe
                                                 write setbutton_frame;
   property button_font: toptionalfont read getbutton_font write setbutton_font;
   property button_optionsadd: buttonoptionsty read fbutton.svoptionsadd
                                write fbutton.svoptionsadd default[];
   property button_optionsremove: buttonoptionsty read fbutton.svoptionsremove
                                write fbutton.svoptionsremove default[];

   property databutton_color: colorty read fdatabutton.svcolor
                                  write fdatabutton.svcolor default cl_default;
   property databutton_face: tfacecomp read fdatabutton.svwidget.svface
                                              write setdatabutton_face;
   property databutton_frame: tframecomp read fdatabutton.svwidget.svframe
                                              write setdatabutton_frame;
   property databutton_font: toptionalfont read getdatabutton_font
                                              write setdatabutton_font;
   property databutton_optionsadd: buttonoptionsty
                               read fdatabutton.svoptionsadd
                                write fdatabutton.svoptionsadd default[];
   property databutton_optionsremove: buttonoptionsty
                       read fbooleanedit.svoptionsremove
                                write fdatabutton.svoptionsremove default[];

   property slider_color: colorty read fslider.svcolor
                                  write fslider.svcolor default cl_default;
   property slider_face: tfacecomp read fslider.svwidget.svface
                                              write setslider_face;
   property slider_frame: tframecomp read fslider.svwidget.svframe
                                                      write setslider_frame;

   property slider_sb_horz_width: int32 read fslider.svsb_horz.svwidth
                                 write fslider.svsb_horz.svwidth default -2;
   property slider_sb_horz_color: colorty
                      read fslider.svsb_horz.svcolor
                    write fslider.svsb_horz.svcolor default cl_default;
   property slider_sb_horz_colorpattern: colorty
                      read fslider.svsb_horz.svcolorpattern
                    write fslider.svsb_horz.svcolorpattern default cl_default;
   property slider_sb_horz_colorpatternclicked: colorty
                      read fslider.svsb_horz.svcolorpatternclicked
             write fslider.svsb_horz.svcolorpatternclicked default cl_default;
   property slider_sb_horz_colorglyph: colorty
                        read fslider.svsb_horz.svcolorglyph
                      write fslider.svsb_horz.svcolorglyph default cl_default;
   property slider_sb_horz_buttonendlength: int32
                         read fslider.svsb_horz.svbuttonendlength
                           write fslider.svsb_horz.svbuttonendlength default -2;
   property slider_sb_horz_buttonlength: int32
                   read fslider.svsb_horz.svbuttonlength
                             write fslider.svsb_horz.svbuttonlength default -2;
   property slider_sb_horz_buttonminlength: int32
                   read fslider.svsb_horz.svbuttonminlength
                          write fslider.svsb_horz.svbuttonminlength default -2;
   property slider_sb_horz_indentstart: int32
                        read fslider.svsb_horz.svindentstart
                               write fslider.svsb_horz.svindentstart default 0;
   property slider_sb_horz_indentend: int32 read fslider.svsb_horz.svindentend
                                  write fslider.svsb_horz.svindentend default 0;
   property slider_sb_horz_face: tfacecomp
                        read fslider.svsb_horz.svface
                        write setssb_horz_face;
   property slider_sb_horz_face1: tfacecomp
                        read fslider.svsb_horz.svface1
                        write setssb_horz_face1;
   property slider_sb_horz_face2: tfacecomp
                        read fslider.svsb_horz.svface2
                        write setssb_horz_face2;
   property slider_sb_horz_facebutton: tfacecomp
                        read fslider.svsb_horz.svfacebu
                        write setssb_horz_facebutton;
   property slider_sb_horz_faceendbutton: tfacecomp
                        read fslider.svsb_horz.svfaceendbu
                        write setssb_horz_faceendbutton;
   property slider_sb_horz_frame: tframecomp
                        read fslider.svsb_horz.svframe
                        write setssb_horz_frame;
   property slider_sb_horz_framebutton: tframecomp
                        read fslider.svsb_horz.svframebu
                        write setssb_horz_framebutton;
   property slider_sb_horz_frameendbutton1: tframecomp
                        read fslider.svsb_horz.svframeendbu1
                        write setssb_horz_frameendbutton1;
   property slider_sb_horz_frameendbutton2: tframecomp
                        read fslider.svsb_horz.svframeendbu2
                        write setssb_horz_frameendbutton2;

   property slider_sb_vert_width: int32 read fslider.svsb_vert.svwidth
                                 write fslider.svsb_vert.svwidth default -2;
   property slider_sb_vert_color: colorty
                      read fslider.svsb_vert.svcolor
                          write fslider.svsb_vert.svcolor default cl_default;
   property slider_sb_vert_colorpattern: colorty
                      read fslider.svsb_vert.svcolorpattern
                    write fslider.svsb_vert.svcolorpattern default cl_default;
   property slider_sb_vert_colorpatternclicked: colorty
                      read fslider.svsb_vert.svcolorpatternclicked
              write fslider.svsb_vert.svcolorpatternclicked default cl_default;
   property slider_sb_vert_colorglyph: colorty
                        read fslider.svsb_vert.svcolorglyph
                      write fslider.svsb_vert.svcolorglyph default cl_default;
   property slider_sb_vert_buttonendlength: int32
                 read fslider.svsb_vert.svbuttonendlength
                          write fslider.svsb_vert.svbuttonendlength default -2;
   property slider_sb_vert_buttonlength: int32
                   read fslider.svsb_vert.svbuttonlength
                             write fslider.svsb_vert.svbuttonlength default -2;
   property slider_sb_vert_buttonminlength: int32
                   read fslider.svsb_vert.svbuttonminlength
                          write fslider.svsb_vert.svbuttonminlength default -2;
   property slider_sb_vert_indentstart: int32
                        read fslider.svsb_vert.svindentstart
                               write fslider.svsb_horz.svindentstart default 0;
   property slider_sb_vert_indentend: int32 read fslider.svsb_vert.svindentend
                                  write fslider.svsb_vert.svindentend default 0;
   property slider_sb_vert_face: tfacecomp
                        read fslider.svsb_vert.svface
                        write setssb_vert_face;
   property slider_sb_vert_face1: tfacecomp
                        read fslider.svsb_vert.svface1
                        write setssb_vert_face1;
   property slider_sb_vert_face2: tfacecomp
                        read fslider.svsb_vert.svface2
                        write setssb_vert_face2;
   property slider_sb_vert_facebutton: tfacecomp
                        read fslider.svsb_vert.svfacebu
                        write setssb_vert_facebutton;
   property slider_sb_vert_faceendbutton: tfacecomp
                        read fslider.svsb_vert.svfaceendbu
                        write setssb_vert_faceendbutton;
   property slider_sb_vert_frame: tframecomp
                        read fslider.svsb_vert.svframe
                        write setssb_vert_frame;
   property slider_sb_vert_framebutton: tframecomp
                        read fslider.svsb_vert.svframebu
                        write setssb_vert_framebutton;
   property slider_sb_vert_frameendbutton1: tframecomp
                        read fslider.svsb_vert.svframeendbu1
                        write setssb_vert_frameendbutton1;
   property slider_sb_vert_frameendbutton2: tframecomp
                        read fslider.svsb_vert.svframeendbu2
                        write setssb_vert_frameendbutton2;


   property framebutton_color: colorty read fframebutton.svcolor
                           write fframebutton.svcolor default cl_default;
   property framebutton_colorglyph: colorty read fframebutton.svcolorglyph
                           write fframebutton.svcolorglyph default cl_default;
   property framebutton_face: tfacecomp read fframebutton.svface
                                              write setframebutton_face;
   property framebutton_frame: tframecomp read fframebutton.svframe
                                              write setframebutton_frame;

   property tabbar_horz_face: tfacecomp read ftabbar.svwidgethorz.svface
                                            write settabbar_horz_face;
   property tabbar_horz_frame: tframecomp read ftabbar.svwidgethorz.svframe
                                            write settabbar_horz_frame;
   property tabbar_horz_tab_color: colorty read ftabbar.svtabhorz.svcolor
                             write ftabbar.svtabhorz.svcolor default cl_default;
   property tabbar_horz_tab_coloractive: colorty
                   read ftabbar.svtabhorz.svcoloractive
                   write ftabbar.svtabhorz.svcoloractive default cl_default;
   property tabbar_horz_tab_frame: tframecomp read ftabbar.svtabhorz.svframe
                               write settabbar_horz_tab_frame;
   property tabbar_horz_tab_face: tfacecomp read ftabbar.svtabhorz.svface
                               write settabbar_horz_tab_face;
   property tabbar_horz_tab_faceactive: tfacecomp
                               read ftabbar.svtabhorz.svfaceactive
                               write settabbar_horz_tab_faceactive;
   property tabbar_horz_tab_shift: integer read ftabbar.svtabhorz.svshift
                     write ftabbar.svtabhorz.svshift default defaulttabshift;
   property tabbar_horz_tab_edge_level: int32
              read ftabbar.svtabhorz.svsedge_level
           write ftabbar.svtabhorz.svsedge_level default defaultedgelevel;
                       //defaultedgelevel (-100) -> -1
   property tabbar_horz_tab_edge_colordkshadow: colorty
              read ftabbar.svtabhorz.svsedge_colordkshadow
              write ftabbar.svtabhorz.svsedge_colordkshadow default cl_default;
   property tabbar_horz_tab_edge_colorshadow: colorty
              read ftabbar.svtabhorz.svsedge_colorshadow
              write ftabbar.svtabhorz.svsedge_colorshadow default cl_default;
   property tabbar_horz_tab_edge_colorlight: colorty
              read ftabbar.svtabhorz.svsedge_colorlight
              write ftabbar.svtabhorz.svsedge_colorlight default cl_default;
   property tabbar_horz_tab_edge_colorhighlight: colorty
              read ftabbar.svtabhorz.svsedge_colorhighlight
              write ftabbar.svtabhorz.svsedge_colorhighlight default cl_default;
   property tabbar_horz_tab_edge_colordkwidth: int32
              read ftabbar.svtabhorz.svsedge_colordkwidth
              write ftabbar.svtabhorz.svsedge_colordkwidth default -1;
                                  //-1 = default
   property tabbar_horz_tab_edge_colorhlwidth: int32
              read ftabbar.svtabhorz.svsedge_colorhlwidth
              write ftabbar.svtabhorz.svsedge_colorhlwidth default -1;
                                  //-1 = default
   property tabbar_horz_tab_edge_imagelist: timagelist
              read ftabbar.svtabhorz.svsedge_imagelist
              write settabbar_horz_tab_edge_imagelist;
                   //imagenr 0 -> startpoint, 1 -> edge, imagenr 2 -> endpoint
   property tabbar_horz_tab_edge_imageoffset: int32
              read ftabbar.svtabhorz.svsedge_imageoffset
              write ftabbar.svtabhorz.svsedge_imageoffset default 0;
   property tabbar_horz_tab_edge_imagepaintshift: int32
              read ftabbar.svtabhorz.svsedge_imagepaintshift
              write ftabbar.svtabhorz.svsedge_imagepaintshift default 0;

   property tabbar_horzopo_face: tfacecomp read ftabbar.svwidgethorzopo.svface
                                            write settabbar_horzopo_face;
   property tabbar_horzopo_frame: tframecomp
                  read ftabbar.svwidgethorzopo.svframe
                                            write settabbar_horzopo_frame;
   property tabbar_horzopo_tab_color: colorty read ftabbar.svtabhorzopo.svcolor
                      write ftabbar.svtabhorzopo.svcolor default cl_default;
   property tabbar_horzopo_tab_coloractive: colorty
                     read ftabbar.svtabhorzopo.svcoloractive
                    write ftabbar.svtabhorzopo.svcoloractive default cl_default;
   property tabbar_horzopo_tab_frame: tframecomp
                             read ftabbar.svtabhorzopo.svframe
                               write settabbar_horzopo_tab_frame;
   property tabbar_horzopo_tab_face: tfacecomp read ftabbar.svtabhorzopo.svface
                               write settabbar_horzopo_tab_face;
   property tabbar_horzopo_tab_faceactive: tfacecomp
                               read ftabbar.svtabhorzopo.svfaceactive
                               write settabbar_horzopo_tab_faceactive;
   property tabbar_horzopo_tab_shift: integer read ftabbar.svtabhorzopo.svshift
                  write ftabbar.svtabhorzopo.svshift default defaulttabshift;
   property tabbar_horzopo_tab_edge_level: int32
              read ftabbar.svtabhorzopo.svsedge_level
           write ftabbar.svtabhorzopo.svsedge_level default defaultedgelevel;
                       //defaultedgelevel (-100) -> -1
   property tabbar_horzopo_tab_edge_colordkshadow: colorty
              read ftabbar.svtabhorzopo.svsedge_colordkshadow
              write ftabbar.svtabhorzopo.svsedge_colordkshadow default cl_default;
   property tabbar_horzopo_tab_edge_colorshadow: colorty
              read ftabbar.svtabhorzopo.svsedge_colorshadow
              write ftabbar.svtabhorzopo.svsedge_colorshadow default cl_default;
   property tabbar_horzopo_tab_edge_colorlight: colorty
              read ftabbar.svtabhorzopo.svsedge_colorlight
              write ftabbar.svtabhorzopo.svsedge_colorlight default cl_default;
   property tabbar_horzopo_tab_edge_colorhighlight: colorty
              read ftabbar.svtabhorzopo.svsedge_colorhighlight
              write ftabbar.svtabhorzopo.svsedge_colorhighlight default cl_default;
   property tabbar_horzopo_tab_edge_colordkwidth: int32
              read ftabbar.svtabhorzopo.svsedge_colordkwidth
              write ftabbar.svtabhorzopo.svsedge_colordkwidth default -1;
                                  //-1 = default
   property tabbar_horzopo_tab_edge_colorhlwidth: int32
              read ftabbar.svtabhorzopo.svsedge_colorhlwidth
              write ftabbar.svtabhorzopo.svsedge_colorhlwidth default -1;
                                  //-1 = default
   property tabbar_horzopo_tab_edge_imagelist: timagelist
              read ftabbar.svtabhorzopo.svsedge_imagelist
              write settabbar_horzopo_tab_edge_imagelist;
                   //imagenr 0 -> startpoint, 1 -> edge, imagenr 2 -> endpoint
   property tabbar_horzopo_tab_edge_imageoffset: int32
              read ftabbar.svtabhorzopo.svsedge_imageoffset
              write ftabbar.svtabhorzopo.svsedge_imageoffset default 0;
   property tabbar_horzopo_tab_edge_imagepaintshift: int32
              read ftabbar.svtabhorzopo.svsedge_imagepaintshift
              write ftabbar.svtabhorzopo.svsedge_imagepaintshift default 0;

   property tabbar_vert_face: tfacecomp read ftabbar.svwidgetvert.svface
                               write settabbar_vert_face;
   property tabbar_vert_frame: tframecomp read ftabbar.svwidgetvert.svframe
                               write settabbar_vert_frame;
   property tabbar_vert_tab_color: colorty read ftabbar.svtabvert.svcolor
                               write ftabbar.svtabvert.svcolor
                               default cl_default;
   property tabbar_vert_tab_coloractive: colorty
                               read ftabbar.svtabvert.svcoloractive
                 write ftabbar.svtabvert.svcoloractive default cl_default;
   property tabbar_vert_tab_frame: tframecomp read ftabbar.svtabvert.svframe
                               write settabbar_vert_tab_frame;
   property tabbar_vert_tab_face: tfacecomp read ftabbar.svtabvert.svface
                               write settabbar_vert_tab_face;
   property tabbar_vert_tab_faceactive: tfacecomp
                             read ftabbar.svtabvert.svfaceactive
                               write settabbar_vert_tab_faceactive;
   property tabbar_vert_tab_shift: integer read ftabbar.svtabvert.svshift
                      write ftabbar.svtabvert.svshift default defaulttabshift;
   property tabbar_vert_tab_edge_level: int32
              read ftabbar.svtabvert.svsedge_level
           write ftabbar.svtabvert.svsedge_level default defaultedgelevel;
                       //defaultedgelevel (-100) -> -1
   property tabbar_vert_tab_edge_colordkshadow: colorty
              read ftabbar.svtabvert.svsedge_colordkshadow
              write ftabbar.svtabvert.svsedge_colordkshadow default cl_default;
   property tabbar_vert_tab_edge_colorshadow: colorty
              read ftabbar.svtabvert.svsedge_colorshadow
              write ftabbar.svtabvert.svsedge_colorshadow default cl_default;
   property tabbar_vert_tab_edge_colorlight: colorty
              read ftabbar.svtabvert.svsedge_colorlight
              write ftabbar.svtabvert.svsedge_colorlight default cl_default;
   property tabbar_vert_tab_edge_colorhighlight: colorty
              read ftabbar.svtabvert.svsedge_colorhighlight
              write ftabbar.svtabvert.svsedge_colorhighlight default cl_default;
   property tabbar_vert_tab_edge_colordkwidth: int32
              read ftabbar.svtabvert.svsedge_colordkwidth
              write ftabbar.svtabvert.svsedge_colordkwidth default -1;
                                  //-1 = default
   property tabbar_vert_tab_edge_colorhlwidth: int32
              read ftabbar.svtabvert.svsedge_colorhlwidth
              write ftabbar.svtabvert.svsedge_colorhlwidth default -1;
                                  //-1 = default
   property tabbar_vert_tab_edge_imagelist: timagelist
              read ftabbar.svtabvert.svsedge_imagelist
              write settabbar_vert_tab_edge_imagelist;
                   //imagenr 0 -> startpoint, 1 -> edge, imagenr 2 -> endpoint
   property tabbar_vert_tab_edge_imageoffset: int32
              read ftabbar.svtabvert.svsedge_imageoffset
              write ftabbar.svtabvert.svsedge_imageoffset default 0;
   property tabbar_vert_tab_edge_imagepaintshift: int32
              read ftabbar.svtabvert.svsedge_imagepaintshift
              write ftabbar.svtabvert.svsedge_imagepaintshift default 0;

   property tabbar_vertopo_face: tfacecomp read ftabbar.svwidgetvertopo.svface
                               write settabbar_vertopo_face;
   property tabbar_vertopo_frame: tframecomp
                 read ftabbar.svwidgetvertopo.svframe
                               write settabbar_vertopo_frame;
   property tabbar_vertopo_tab_color: colorty read ftabbar.svtabvertopo.svcolor
                         write ftabbar.svtabvertopo.svcolor default cl_default;
   property tabbar_vertopo_tab_coloractive: colorty
                         read ftabbar.svtabvertopo.svcoloractive
                   write ftabbar.svtabvertopo.svcoloractive default cl_default;
   property tabbar_vertopo_tab_frame: tframecomp
                     read ftabbar.svtabvertopo.svframe
                               write settabbar_vertopo_tab_frame;
   property tabbar_vertopo_tab_face: tfacecomp
                       read ftabbar.svtabvertopo.svface
                         write settabbar_vertopo_tab_face;
   property tabbar_vertopo_tab_faceactive: tfacecomp
                         read ftabbar.svtabvertopo.svfaceactive
                         write settabbar_vertopo_tab_faceactive;
   property tabbar_vertopo_tab_shift: integer read ftabbar.svtabvertopo.svshift
                write ftabbar.svtabvertopo.svshift default defaulttabshift;
   property tabbar_vertopo_tab_edge_level: int32
              read ftabbar.svtabvertopo.svsedge_level
           write ftabbar.svtabvertopo.svsedge_level default defaultedgelevel;
                       //defaultedgelevel (-100) -> -1
   property tabbar_vertopo_tab_edge_colordkshadow: colorty
              read ftabbar.svtabvertopo.svsedge_colordkshadow
              write ftabbar.svtabvertopo.svsedge_colordkshadow default cl_default;
   property tabbar_vertopo_tab_edge_colorshadow: colorty
              read ftabbar.svtabvertopo.svsedge_colorshadow
              write ftabbar.svtabvertopo.svsedge_colorshadow default cl_default;
   property tabbar_vertopo_tab_edge_colorlight: colorty
              read ftabbar.svtabvertopo.svsedge_colorlight
              write ftabbar.svtabvertopo.svsedge_colorlight default cl_default;
   property tabbar_vertopo_tab_edge_colorhighlight: colorty
              read ftabbar.svtabvertopo.svsedge_colorhighlight
              write ftabbar.svtabvertopo.svsedge_colorhighlight default cl_default;
   property tabbar_vertopo_tab_edge_colordkwidth: int32
              read ftabbar.svtabvertopo.svsedge_colordkwidth
              write ftabbar.svtabvertopo.svsedge_colordkwidth default -1;
                                  //-1 = default
   property tabbar_vertopo_tab_edge_colorhlwidth: int32
              read ftabbar.svtabvertopo.svsedge_colorhlwidth
              write ftabbar.svtabvertopo.svsedge_colorhlwidth default -1;
                                  //-1 = default
   property tabbar_vertopo_tab_edge_imagelist: timagelist
              read ftabbar.svtabvertopo.svsedge_imagelist
              write settabbar_vertopo_tab_edge_imagelist;
                   //imagenr 0 -> startpoint, 1 -> edge, imagenr 2 -> endpoint
   property tabbar_vertopo_tab_edge_imageoffset: int32
              read ftabbar.svtabvertopo.svsedge_imageoffset
              write ftabbar.svtabvertopo.svsedge_imageoffset default 0;
   property tabbar_vertopo_tab_edge_imagepaintshift: int32
              read ftabbar.svtabvertopo.svsedge_imagepaintshift
              write ftabbar.svtabvertopo.svsedge_imagepaintshift default 0;

   property toolbar_horz_face: tfacecomp read ftoolbar_horz.svwidget.svface
                                        write settoolbar_horz_face;
   property toolbar_horz_frame: tframecomp read ftoolbar_horz.svwidget.svframe
                                        write settoolbar_horz_frame;
   property toolbar_horz_buttonface: tfacecomp read ftoolbar_horz.svbuttonface
                            write settoolbar_horz_buttonface;
   property toolbar_horz_buttonframe: tframecomp
                        read ftoolbar_horz.svbuttonframe
                            write settoolbar_horz_buttonframe;
   property toolbar_horz_buttonframesep: tframecomp
                        read ftoolbar_horz.svbuttonframesep
                            write settoolbar_horz_buttonframesep;
   property toolbar_vert_face: tfacecomp read ftoolbar_vert.svwidget.svface
                            write settoolbar_vert_face;
   property toolbar_vert_frame: tframecomp read ftoolbar_vert.svwidget.svframe
                            write settoolbar_vert_frame;
   property toolbar_vert_buttonface: tfacecomp read ftoolbar_vert.svbuttonface
                            write settoolbar_vert_buttonface;
   property toolbar_vert_buttonframe: tframecomp
                        read ftoolbar_vert.svbuttonframe
                            write settoolbar_vert_buttonframe;
   property toolbar_vert_buttonframesep: tframecomp
                        read ftoolbar_vert.svbuttonframesep
                            write settoolbar_vert_buttonframesep;

   property tabpage_face: tfacecomp read ftabpage.svwidget.svface
                                                write settabpage_face;
   property tabpage_frame: tframecomp read ftabpage.svwidget.svframe
                                                 write settabpage_frame;
   property tabpage_colortab: colorty read ftabpage.svcolortab
                               write ftabpage.svcolortab default cl_default;
   property tabpage_coloractive: colorty read ftabpage.svcoloractivetab
                           write ftabpage.svcoloractivetab default cl_default;
   property tabpage_facetab: tfacecomp read ftabpage.svfacetab
                                                write settabpage_facetab;
   property tabpage_faceactivetab: tfacecomp read ftabpage.svfaceactivetab
                                                write settabpage_faceactivetab;
   property tabpage_fonttab: tfontcomp read ftabpage.svfonttab
                                                write settabpage_fonttab;
   property tabpage_fontactivetab: tfontcomp read ftabpage.svfontactivetab
                                                write settabpage_fontactivetab;
{
   property popupmenu_options: skinmenuoptionsty read fpopupmenu.options
                write fpopupmenu.options default [];
}
   property popupmenu_face: tfacecomp read fpopupmenu.svface
                               write setpopupmenu_face;
   property popupmenu_frame: tframecomp read fpopupmenu.svframe
                                      write setpopupmenu_frame;
   property popupmenu_itemface: tfacecomp read fpopupmenu.svitemface
                                      write setpopupmenu_itemface;
   property popupmenu_itemframe: tframecomp read fpopupmenu.svitemframe
                                      write setpopupmenu_itemframe;
   property popupmenu_itemfaceactive: tfacecomp read fpopupmenu.svitemfaceactive
                                      write setpopupmenu_itemfaceactive;
   property popupmenu_itemframeactive: tframecomp
           read fpopupmenu.svitemframeactive write setpopupmenu_itemframeactive;
   property popupmenu_font: tfontcomp read fpopupmenu.svfont
                                 write setpopupmenu_font;
   property popupmenu_fontactive: tfontcomp
                                 read fpopupmenu.svfontactive
                                 write setpopupmenu_fontactive;
   property popupmenu_separatorframe: tframecomp read
                 fpopupmenu.svseparatorframe write setpopupmenu_separatorframe;
   property popupmenu_checkboxframe: tframecomp read fpopupmenu.svcheckboxframe
                                 write setpopupmenu_checkboxframe;
{
   property mainmenu_options: skinmenuoptionsty read fmainmenu.ma.options
                write fmainmenu.ma.options default [];
}
   property mainmenu_face: tfacecomp read fmainmenu.svmain.svface
                                 write setmainmenu_face;
   property mainmenu_frame: tframecomp read fmainmenu.svmain.svframe
                                 write setmainmenu_frame;
   property mainmenu_itemface: tfacecomp read fmainmenu.svmain.svitemface
                                 write setmainmenu_itemface;
   property mainmenu_itemframe: tframecomp read fmainmenu.svmain.svitemframe
                                 write setmainmenu_itemframe;
   property mainmenu_itemfaceactive: tfacecomp
                                 read fmainmenu.svmain.svitemfaceactive
                                 write setmainmenu_itemfaceactive;
   property mainmenu_itemframeactive: tframecomp
                                 read fmainmenu.svmain.svitemframeactive
                                 write setmainmenu_itemframeactive;
   property mainmenu_font: tfontcomp read fmainmenu.svmain.svfont
                                 write setmainmenu_font;
   property mainmenu_fontactive: tfontcomp read fmainmenu.svmain.svfontactive
                                 write setmainmenu_fontactive;
   property mainmenu_separatorframe: tframecomp
                                 read fmainmenu.svmain.svseparatorframe
                                 write setmainmenu_separatorframe;
   property mainmenu_checkboxframe: tframecomp
                                 read fmainmenu.svmain.svcheckboxframe
                                 write setmainmenu_checkboxframe;

   property mainmenu_popupface: tfacecomp read fmainmenu.svpopup.svface
                                 write setmainmenu_popupface;
   property mainmenu_popupframe: tframecomp read fmainmenu.svpopup.svframe
                                 write setmainmenu_popupframe;
   property mainmenu_popupitemface: tfacecomp read fmainmenu.svpopup.svitemface
                                 write setmainmenu_popupitemface;
   property mainmenu_popupitemframe: tframecomp
                                 read fmainmenu.svpopup.svitemframe
                                 write setmainmenu_popupitemframe;
   property mainmenu_popupitemfaceactive: tfacecomp
                                 read fmainmenu.svpopup.svitemfaceactive
                                 write setmainmenu_popupitemfaceactive;
   property mainmenu_popupitemframeactive: tframecomp
                                 read fmainmenu.svpopup.svitemframeactive
                                 write setmainmenu_popupitemframeactive;
   property mainmenu_popupfont: tfontcomp read fmainmenu.svpopup.svfont
                                 write setmainmenu_popupfont;
   property mainmenu_popupfontactive: tfontcomp
                                 read fmainmenu.svpopup.svfontactive
                                 write setmainmenu_popupfontactive;
   property mainmenu_popupseparatorframe: tframecomp
                                 read fmainmenu.svpopup.svseparatorframe
                                 write setmainmenu_popupseparatorframe;
   property mainmenu_popupcheckboxframe: tframecomp
                                 read fmainmenu.svpopup.svcheckboxframe
                                 write setmainmenu_popupcheckboxframe;

   property mainmenuwidget_face: tfacecomp read fmainmenuwidget.svwidget.svface
                                            write setmainmenuwidget_face;
   property mainmenuwidget_frame: tframecomp
                         read fmainmenuwidget.svwidget.svframe
                                            write setmainmenuwidget_frame;
   property mainmenuwidget_itemface: tfacecomp read fmainmenuwidget.svmenu.svmain.svitemface
                                 write setmainmenuwidget_itemface;
   property mainmenuwidget_itemframe: tframecomp read fmainmenuwidget.svmenu.svmain.svitemframe
                                 write setmainmenuwidget_itemframe;
   property mainmenuwidget_itemfaceactive: tfacecomp
                                 read fmainmenuwidget.svmenu.svmain.svitemfaceactive
                                 write setmainmenuwidget_itemfaceactive;
   property mainmenuwidget_itemframeactive: tframecomp
                                 read fmainmenuwidget.svmenu.svmain.svitemframeactive
                                 write setmainmenuwidget_itemframeactive;
   property mainmenuwidget_font: tfontcomp read fmainmenuwidget.svmenu.svmain.svfont
                                 write setmainmenuwidget_font;
   property mainmenuwidget_fontactive: tfontcomp read fmainmenuwidget.svmenu.svmain.svfontactive
                                 write setmainmenuwidget_fontactive;
   property mainmenuwidget_separatorframe: tframecomp
                                 read fmainmenuwidget.svmenu.svmain.svseparatorframe
                                 write setmainmenuwidget_separatorframe;
   property mainmenuwidget_checkboxframe: tframecomp
                                 read fmainmenuwidget.svmenu.svmain.svcheckboxframe
                                 write setmainmenuwidget_checkboxframe;

   property mainmenuwidget_popupface: tfacecomp read fmainmenuwidget.svmenu.svpopup.svface
                                 write setmainmenuwidget_popupface;
   property mainmenuwidget_popupframe: tframecomp read fmainmenuwidget.svmenu.svpopup.svframe
                                 write setmainmenuwidget_popupframe;
   property mainmenuwidget_popupitemface: tfacecomp read fmainmenuwidget.svmenu.svpopup.svitemface
                                 write setmainmenuwidget_popupitemface;
   property mainmenuwidget_popupitemframe: tframecomp
                                 read fmainmenuwidget.svmenu.svpopup.svitemframe
                                 write setmainmenuwidget_popupitemframe;
   property mainmenuwidget_popupitemfaceactive: tfacecomp
                                 read fmainmenuwidget.svmenu.svpopup.svitemfaceactive
                                 write setmainmenuwidget_popupitemfaceactive;
   property mainmenuwidget_popupitemframeactive: tframecomp
                                 read fmainmenuwidget.svmenu.svpopup.svitemframeactive
                                 write setmainmenuwidget_popupitemframeactive;
   property mainmenuwidget_popupfont: tfontcomp read fmainmenuwidget.svmenu.svpopup.svfont
                                 write setmainmenuwidget_popupfont;
   property mainmenuwidget_popupfontactive: tfontcomp
                                 read fmainmenuwidget.svmenu.svpopup.svfontactive
                                 write setmainmenuwidget_popupfontactive;
   property mainmenuwidget_popupseparatorframe: tframecomp
                                 read fmainmenuwidget.svmenu.svpopup.svseparatorframe
                                 write setmainmenuwidget_popupseparatorframe;
   property mainmenuwidget_popupcheckboxframe: tframecomp
                                 read fmainmenuwidget.svmenu.svpopup.svcheckboxframe
                                 write setmainmenuwidget_popupcheckboxframe;
 end;

 skincontrollerarty = array of tcustomskincontroller;

 tskinhandler = class
  protected
   factiveskincontroller: skincontrollerarty;
   procedure setactive(const sender: tcustomskincontroller;
          var controllerar: skincontrollerarty;
          const handleproc: skineventty; var handlevar: skineventty{;
          const removeproc: skineventty; var removevar: skineventty});
   procedure updateactive(const sender: tcustomskincontroller); virtual;
   procedure doactivate(const sender: tcustomskincontroller); virtual;
   procedure dodeactivate(const sender: tcustomskincontroller); virtual;
   procedure updateskin1(const ainfo: skininfoty;
                                  const controllerar: skincontrollerarty);
//   procedure removeskin1(const ainfo: skininfoty;
//                                  const controllerar: skincontrollerarty);
   procedure updateskin(const ainfo: skininfoty);
//   procedure removeskin(const ainfo: skininfoty);
 end;

//function activeskincontroller: skincontrollerarty;
//function activeskincontrollerdesign: skincontrollerarty;
procedure setskinhandler(const avalue: tskinhandler);

implementation
uses
 msetabsglob,sysutils,mseapplication,msearrayutils,msefont,msesplitter,
 msemenuwidgets,mserichstring;
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}

type
 twidget1 = class(twidget);
 tframe1 = class(tcustomframe);
 tcustomframe1 = class(tcustomframe);
 ttabs1 = class(ttabs);
 tmenuitem1 = class(tmenuitem);
var
 fhandler: tskinhandler;

procedure setskinhandler(const avalue: tskinhandler);
begin
 fhandler.free;
 fhandler:= avalue;
end;
{
function activeskincontroller: skincontrollerarty;
begin
 result:= factiveskincontroller;
end;

function activeskincontrollerdesign: skincontrollerarty;
begin
 result:= factiveskincontrollerdesign;
end;
}
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
 with fframecolors,edges do begin
  light.color:= cl_default;
  light.effectcolor:= cl_default;
  light.effectwidth:= -1;
  shadow.color:= cl_default;
  shadow.effectcolor:= cl_default;
  shadow.effectwidth:= -1;
  frame:= cl_default;
 end;
 with feditfontcolors do begin
  text:= cl_default;
  textbackground:= cl_default;
  selectedtext:= cl_default;
  selectedtextbackground:= cl_default;
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
 with fframecolors.edges.light do begin
  if color <> cl_default then begin
   defaultframecolors.edges.light.color:= color;
  end;
  if effectcolor <> cl_default then begin
   defaultframecolors.edges.light.effectcolor:= effectcolor;
  end;
  if effectwidth <> -1 then begin
   defaultframecolors.edges.light.effectwidth:= effectwidth;
  end;
 end;
 with fframecolors.edges.shadow do begin
  if color <> cl_default then begin
   defaultframecolors.edges.shadow.color:= color;
  end;
  if effectcolor <> cl_default then begin
   defaultframecolors.edges.shadow.effectcolor:= effectcolor;
  end;
  if effectwidth <> -1 then begin
   defaultframecolors.edges.shadow.effectwidth:= effectwidth;
  end;
 end;
 if fframecolors.frame <> cl_default then begin
  defaultframecolors.frame:= fframecolors.frame;
 end;
 feditfontcolorsbefore:= defaulteditfontcolors;
 if feditfontcolors.text <> cl_default then begin
  defaulteditfontcolors.text:= feditfontcolors.text;
 end;
 if feditfontcolors.textbackground <> cl_default then begin
  defaulteditfontcolors.textbackground:= feditfontcolors.textbackground;
 end;
 if feditfontcolors.selectedtext <> cl_default then begin
  defaulteditfontcolors.selectedtext:= feditfontcolors.selectedtext;
 end;
 if feditfontcolors.selectedtextbackground <> cl_default then begin
  defaulteditfontcolors.selectedtextbackground:=
                          feditfontcolors.selectedtextbackground;
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
 defaultframecolors:= fframecolorsbefore;
 defaulteditfontcolors:= feditfontcolorsbefore;
end;

{ tskinfontaliass }

constructor tskinfontaliass.create(const aowner: tcustomskincontroller);
begin
 inherited create(aowner,tskinfontalias);
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
   if fancestor <> '' then begin
    registerfontalias(alias,name,mode,height,width,options,xscale,
                                                           ancestor,template);
   end
   else begin
    registerfontalias(alias,name,mode,height,width,options,xscale,
                                                   defaultfontalias,template);
   end;
  end;
 end;
end;

{ tcustomskincontroller }

constructor tcustomskincontroller.create(aowner: tcomponent);
var
 fo1: stockfontty;
begin
 fcolors:= tskincolors.create;
 ffontalias:= tskinfontaliass.create(self);
 for fo1:= low(stockfontty) to high(stockfontty) do begin
  fskinfonts[fo1]:= tskinfont.create;
 end;
 fhotkey_color:= cl_default;
 fhotkey_colorbackground:= cl_default;
 inherited;
end;

destructor tcustomskincontroller.destroy;
var
 fo1: stockfontty;
begin
 active:= false;
 inherited;
 fcolors.free;
 ffontalias.free;
 for fo1:= low(stockfontty) to high(stockfontty) do begin
  fskinfonts[fo1].free;
 end;
end;

procedure tcustomskincontroller.doactivate;
var
 int1: integer;
 fo1: stockfontty;
begin
 fcolors.setcolors;
 ffontalias.setfontalias;
 for fo1:= low(stockfontty) to high(stockfontty) do begin
  fskinfonts[fo1].updatefont(stockobjects.fonts[fo1]);
 end;
 checkhotkey();
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

procedure tcustomskincontroller.checkactive;
var
 bo1: boolean;
begin
 factivedesign:= factivedesign and factive;
 bo1:= factive and (factivedesign or not (csdesigning in componentstate));
 if (fisactive <> bo1) and (fhandler <> nil) then begin
  fisactive:= bo1;
  if not (csloading in componentstate) and not fisactive then begin
   dodeactivate;
   fhandler.dodeactivate(self);
  end;
  fhandler.updateactive(self);
  if not (csloading in componentstate) and fisactive then begin
   doactivate;
   fhandler.doactivate(self);
  end;
 end;
end;

procedure tcustomskincontroller.sethotkey_fontstylesadd(
              const avalue: fontstylesty);
begin
 fhotkey_fontstylesadd:= avalue;
 checkhotkey();
end;

procedure tcustomskincontroller.sethotkey_fontstylesremove(
              const avalue: fontstylesty);
begin
 fhotkey_fontstylesremove:= avalue;
 checkhotkey();
end;

procedure tcustomskincontroller.sethotkey_color(const avalue: colorty);
begin
 fhotkey_color:= avalue;
 checkhotkey();
end;

procedure tcustomskincontroller.sethotkey_colorbackground(
              const avalue: colorty);
begin
 fhotkey_colorbackground:= avalue;
 checkhotkey();
end;

procedure tcustomskincontroller.checkhotkey();
begin
 fhashotkey:= false;
 if factive and
            (factivedesign or not (csdesigning in componentstate)) then begin
  if fhotkey_fontstylesadd <> [] then begin
   hotkeyfontstylesadd:= fhotkey_fontstylesadd;
   fhashotkey:= true;
  end;
  if fhotkey_fontstylesremove <> [] then begin
   hotkeyfontstylesremove:= fhotkey_fontstylesremove;
   fhashotkey:= true;
  end;
  if fhotkey_color <> cl_default then begin
   hotkeycolor:= fhotkey_color;
   fhashotkey:= true;
  end;
  if fhotkey_colorbackground <> cl_default then begin
   hotkeycolorbackground:= fhotkey_colorbackground;
   fhashotkey:= true;
  end;
 end;
end;

procedure tcustomskincontroller.setactive(const avalue: boolean);
begin
 factive:= avalue;
 checkactive;
end;
{
procedure tcustomskincontroller.setactivedesign(const avalue: boolean);
begin
 factivedesign:= avalue;
 checkactive;
end;
}
procedure tcustomskincontroller.updateskin1(const ainfo: skininfoty;
             const remove: boolean);
label
 endlab;
var
 bo1,bo2: boolean;
 int1: integer;
begin
 if factive then begin
//  fremoving:= remove;
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
   case ainfo.objectkind of  //todo: use table
    sok_widget: begin
     handlewidget(ainfo);
    end;
    sok_splitter: begin
     handlesplitter(ainfo);
    end;
    sok_dispwidget: begin
     handledispwidget(ainfo);
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
    sok_slider: begin
     handleslider(ainfo);
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
    sok_mainmenuwidget: begin
     handlemainmenuwidget(ainfo);
    end;
    sok_grid: begin
     handlegrid(ainfo);
    end;
    sok_user: begin
     handleuserobject(ainfo);
    end;
     else; // For case statment added to make compiler happy.
   end;
   if (sko_container in ainfo.options) and
                              (ainfo.instance is twidget) then begin
    handlecontainer(ainfo);
   end;
  end;
endlab:
  if assigned(fonafterupdate) then begin
   fonafterupdate(self,ainfo);
  end;
 end;
end;

procedure tcustomskincontroller.updateskin(const ainfo: skininfoty);
begin
 updateskin1(ainfo,false);
end;
{
procedure tcustomskincontroller.removeskin(const ainfo: skininfoty);
begin
 updateskin1(ainfo,true);
end;
}
procedure tcustomskincontroller.handlewidget(const askin: skininfoty;
                              const acolor: pwidgetcolorinfoty = nil);
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
   if face.template = nil then begin
    face.template:= aface;
   end;
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
 frame1: framety;
 opt1: frameskincontrolleroptionsty;
begin
 with twidget1(instance) do begin
  if (aframe <> nil) and (optionsskin *
                       [osk_framebuttononly,osk_noframe] = []) then begin
   if fframe = nil then begin
    createframe;
    include(tcustomframe1(fframe).fstate,fs_paintposinited);
   end;
   if frame.template <> nil then begin
    exit;
   end;
   col1:= frame.colorclient;
   size1:= clientsize;
   addsize1(size1,aframe.template.clientsizeextend);
   with tframe1(frame).fpaintframedelta do begin
    size1.cx:= size1.cx + left + right;
    size1.cy:= size1.cy + top + bottom;
   end;
   frame1:= innerclientframe;
   fframe.template:= aframe;
   opt1:= aframe.template.optionsskincontroller;
   if not (fsco_colorclient in opt1) then begin
//    tframe1(frame).fi.colorclient:= col1; //restore
    frame.colorclient:= col1;
   end;
   with tframe1(frame).fi.innerframe do begin
    if fsco_frameirightsize in opt1 then begin
     size1.cx:= size1.cx + right - frame1.right;
    end;
    if fsco_frameileftsize in opt1 then begin
     size1.cx:= size1.cx + left - frame1.left;
    end;
    if fsco_frameitopsize in opt1 then begin
     size1.cy:= size1.cy + top - frame1.top;
    end;
    if fsco_frameibottomsize in opt1 then begin
     size1.cy:= size1.cy + bottom - frame1.bottom;
    end;
   end;
   with tframe1(frame).fpaintframedelta do begin
    size1.cx:= size1.cx - left - right;
    size1.cy:= size1.cy - top - bottom;
   end;
   if not (osk_noclientsize in optionsskin) and
                         not (fsco_noclientsize in opt1) then begin
    clientsize:= size1;      //same clientsize as before
   end;
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
 setwidgetface(instance,ainfo.svface);
 setwidgetframe(instance,ainfo.svframe);
// if fhashotkey then begin
//  instance.updatehotkeys();
// end;
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
 setwidgetskin(instance,ainfo.svwidget);
// setwidgetface(instance,ainfo.face);
// setwidgetframetemplate(instance,ainfo.frame);
end;

procedure tcustomskincontroller.setgridpropskin(const instance: tgridprop;
                                   const  ainfo: gridpropskininfoty);
begin
 if ainfo.svface <> nil then begin
  with instance do begin
   createface;
   setfacetemplate(ainfo.svface,face);
  end;
 end;
 if ainfo.svframe <> nil then begin
  with instance do begin
   createframe;
   setframetemplate(ainfo.svframe,frame);
  end;
 end;
end;

procedure tcustomskincontroller.setgridskin(const instance: tcustomgrid;
                                            const ainfo: gridskininfoty);
var
 int1{,int2}: integer;
begin
 setwidgetskin(instance,ainfo.svwidget);
// setwidgetface(instance,ainfo.face);
// setwidgetframetemplate(instance,ainfo.frame);
 with ainfo do begin
  for int1:= -1 downto -instance.fixrows.count do begin
   setgridpropskin(instance.fixrows[int1],ainfo.svfixrows);
  end;
  for int1:= -1 downto -instance.fixcols.count do begin
   setgridpropskin(instance.fixcols[int1],ainfo.svfixcols);
  end;
  for int1:= 0 to instance.datacols.count - 1 do begin
   setgridpropskin(instance.datacols[int1],ainfo.svdatacols);
  end;
 end;
end;

procedure tcustomskincontroller.seteditskin(const instance: tcustomedit;
                                            const ainfo: editskininfoty);
begin
 setwidgetskin(instance,ainfo.svwidget);
 with instance do begin
  if (ainfo.svempty_text <> '') and (empty_text = '') and
         (eo_defaulttext in empty_options) then begin
   empty_text:= ainfo.svempty_text;
  end;
  if (ainfo.svempty_textflags <> []) and
                        not(tf_force in empty_textflags) then begin
   empty_textflags:= ainfo.svempty_textflags;
  end;
  if (ainfo.svempty_textcolor <> cl_default) and
                               (empty_textcolor = cl_none) then begin
   empty_textcolor:= ainfo.svempty_textcolor;
  end;
  if (ainfo.svempty_textcolorbackground <> cl_default) and
                         (empty_textcolorbackground = cl_none) then begin
   empty_textcolorbackground:= ainfo.svempty_textcolor;
  end;
  if (ainfo.svempty_fontstyle <> []) and
                        not(fs_force in empty_fontstyle) then begin
   empty_fontstyle:= ainfo.svempty_fontstyle;
  end;
  if (ainfo.svempty_color <> cl_default) and
                               (empty_color = cl_none) then begin
   empty_color:= ainfo.svempty_color;
  end;
 end;
end;

procedure tcustomskincontroller.setdataeditskin(const instance: tdataedit;
                                            const ainfo: dataeditskininfoty);
begin
 seteditskin(instance,ainfo.svedit);
end;

procedure tcustomskincontroller.setgraphdataeditskin(
          const instance: tgraphdataedit; const ainfo: graphdataeditskininfoty);
begin
 setwidgetskin(instance,ainfo.svwidget);
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

function tcustomskincontroller.setwidgetcolorcaptionframe(
                   const awidget: twidget; const acolor: colorty): boolean;
begin
 result:= false;
 with twidget1(awidget) do begin
  if (osk_colorcaptionframe in optionsskin) or
       not (osk_nocolorcaptionframe in optionsskin) and
         (fframe is tcustomcaptionframe) and
       (tcustomcaptionframe(fframe).caption <> '') then begin
   setwidgetcolor(awidget,acolor);
   result:= true;
  end
 end;
end;

procedure tcustomskincontroller.setstepbuttonskin(
                        const instance: tcustomstepframe;
                        const ainfo: stepbuttonskininfoty);
begin
 with instance,ainfo do begin
  if (colorbutton = cl_default) and
                (svcolor <> cl_default) then begin
   colorbutton:= svcolor;
  end;
  if svframe <> nil then begin
   instance.createbuttonframe;
   setframetemplate(svframe,buttonframe);
  end;
  if svface <> nil then begin
   instance.createbuttonface;
   setfacetemplate(svface,buttonface);
  end;
 end;
end;

procedure tcustomskincontroller.setframebuttonskin(const instance: tframebutton;
               const ainfo: framebuttonskininfoty);
begin
 with instance,ainfo do begin
  if (svcolor <> cl_default) and (color = cl_default) then begin
   color:= svcolor;
  end;
  if (svcolorglyph <> cl_default) and (colorglyph = cl_default) then begin
   colorglyph:= svcolorglyph;
  end;
  if (svface <> nil) {and (face = nil)} then begin
   createface;
   setfacetemplate(svface,face);
//   face.template:= fa;
  end;
  if (svframe <> nil) {and (frame = nil)} then begin
   createframe;
   setframetemplate(svframe,frame);
//   frame.template:= fra;
  end;
 end;
end;

procedure tcustomskincontroller.setscrollbarskin(
                const instance: tcustomscrollbar;
               const ainfo: scrollbarskininfoty);
begin
 with instance,ainfo do begin
  if svwidth <> -2 then begin
   width:= svwidth;
  end;
  if (svcolor <> cl_default) and (color = cl_default) then begin
   color:= svcolor;
  end;
  if (svcolorpattern <> cl_default) and (colorpattern = cl_default) then begin
   colorpattern:= svcolorpattern;
  end;
  if (svcolorpatternclicked <> cl_default) and
                         (colorpatternclicked = cl_default) then begin
   colorpatternclicked:= svcolorpatternclicked;
  end;
  if svcolorglyph <> cl_default then begin
   colorglyph:= svcolorglyph;
  end;
  if svbuttonendlength <> -2 then begin
   buttonendlength:= svbuttonendlength;
  end;
  if svbuttonlength <> -2 then begin
   buttonlength:= svbuttonlength;
  end;
  if svbuttonminlength <> -2 then begin
   buttonminlength:= svbuttonminlength;
  end;
  if svindentstart <> 0 then begin
   indentstart:= svindentstart;
  end;
  if svindentend <> 0 then begin
   indentend:= svindentend;
  end;
  if (svface <> nil) then begin
   createface();
   setfacetemplate(svface,face);
  end;
  if (svface1 <> nil) then begin
   createface1();
   setfacetemplate(svface1,face1);
  end;
  if (svface2 <> nil) then begin
   createface2();
   setfacetemplate(svface2,face2);
  end;
  if (svfacebu <> nil) {and (facebutton = nil)} then begin
   createfacebutton;
   setfacetemplate(svfacebu,facebutton);
//   facebutton.template:= facebu;
  end;
  if (svfaceendbu <> nil) {and (faceendbutton = nil)} then begin
   createfaceendbutton;
   setfacetemplate(svfaceendbu,faceendbutton);
//   faceendbutton.template:= faceendbu;
  end;
  if (svframe <> nil) {and (framebutton = nil)} then begin
   createframe;
   setframetemplate(svframe,frame);
//   framebutton.template:= framebu;
  end;
  if (svframebu <> nil) {and (framebutton = nil)} then begin
   createframebutton;
   setframetemplate(svframebu,framebutton);
//   framebutton.template:= framebu;
  end;
  if (svframeendbu1 <> nil) {and (frameendbutton1 = nil)} then begin
   createframeendbutton1;
   setframetemplate(svframeendbu1,frameendbutton1);
//   frameendbutton1.template:= frameendbu1;
  end;
  if (svframeendbu2 <> nil) {and (frameendbutton2 = nil)} then begin
   createframeendbutton2;
   setframetemplate(svframeendbu2,frameendbutton2);
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
   if (ainfo.svshift <> defaulttabshift) and
                               (shift = defaulttabshift) then begin
    shift:= ainfo.svshift;
   end;
   if (ainfo.svsedge_level <> defaultedgelevel) and
                  (edge_level = defaultedgelevel) then begin
    edge_level:= ainfo.svsedge_level;
   end;
   if (ainfo.svsedge_colordkshadow <> cl_default) and
                  (edge_colordkshadow = cl_default) then begin
    edge_colordkshadow:= ainfo.svsedge_colordkshadow;
   end;
   if (ainfo.svsedge_colorshadow <> cl_default) and
                  (edge_colorshadow = cl_default) then begin
    edge_colorshadow:= ainfo.svsedge_colorshadow;
   end;
   if (ainfo.svsedge_colorlight <> cl_default) and
                  (edge_colorlight = cl_default) then begin
    edge_colorlight:= ainfo.svsedge_colorlight;
   end;
   if (ainfo.svsedge_colorhighlight <> cl_default) and
                  (edge_colorhighlight = cl_default) then begin
    edge_colorhighlight:= ainfo.svsedge_colorhighlight;
   end;
   if (ainfo.svsedge_colordkwidth <> -1) and
                  (edge_colordkwidth = -1) then begin
    edge_colordkwidth:= ainfo.svsedge_colordkwidth;
   end;
   if (ainfo.svsedge_colorhlwidth <> -1) and
                  (edge_colorhlwidth = -1) then begin
    edge_colorhlwidth:= ainfo.svsedge_colorhlwidth;
   end;
   if (ainfo.svsedge_imagelist <> nil) and
                  (edge_imagelist = nil) then begin
    edge_imagelist:= ainfo.svsedge_imagelist;
   end;
   if (ainfo.svsedge_imageoffset <> 0) and
                  (edge_imageoffset = -1) then begin
    edge_imageoffset:= ainfo.svsedge_imageoffset;
   end;
   if (ainfo.svsedge_imagepaintshift <> 0) and
                  (edge_imagepaintshift = 0) then begin
    edge_imagepaintshift:= ainfo.svsedge_imagepaintshift;
   end;

   if {(frame = nil) and} (ainfo.svframe <> nil) then begin
    createframe;
    setframetemplate(ainfo.svframe,frame);
//    frame.template:= ainfo.frame;
   end;
   if {(face = nil) and} (ainfo.svface <> nil) then begin
    createface;
    setfacetemplate(ainfo.svface,face);
//    face.template:= ainfo.face;
   end;
   if {(faceactive = nil) and} (ainfo.svfaceactive <> nil) then begin
    createfaceactive;
    setfacetemplate(ainfo.svfaceactive,faceactive);
//    faceactive.template:= ainfo.faceactive;
   end;
   for int1:= 0 to count - 1 do begin
    with items[int1] do begin
     if (ainfo.svcolor <> cl_default) and (color = cl_default) then begin
      color:= ainfo.svcolor;
     end;
     if (ainfo.svcoloractive <> cl_default) and
                                     (coloractive = cl_default) then begin
      coloractive:= ainfo.svcoloractive;
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
  if (ainfo.svface <> nil) and (facetemplate = nil) then begin
   facetemplate:= ainfo.svface;
  end;
  if (ainfo.svframe <> nil) and (frametemplate = nil) then begin
   frametemplate:= ainfo.svframe;
  end;
  if (ainfo.svitemface <> nil) and (itemfacetemplate = nil) then begin
   itemfacetemplate:= ainfo.svitemface;
  end;
  if (ainfo.svitemframe <> nil) and (itemframetemplate = nil) then begin
   itemframetemplate:= ainfo.svitemframe;
  end;
  if (ainfo.svitemfaceactive <> nil) and
                 (itemfacetemplateactive = nil) then begin
   itemfacetemplateactive:= ainfo.svitemfaceactive;
  end;
  if (ainfo.svitemframeactive <> nil) and
             (itemframetemplateactive = nil) then begin
   itemframetemplateactive:= ainfo.svitemframeactive;
  end;
  if menu <> nil then begin
   with tmenuitem1(menu) do begin;
    if (ainfo.svfont <> nil) and
               ((ffont = nil) or (ffont.template = nil)) then begin
     createfont();
     ffont.template:= ainfo.svfont;
    end;
    if (ainfo.svfontactive <> nil) and
         ((ffontactive = nil) or (ffontactive.template = nil)) then begin
     createfontactive();
     ffontactive.template:= ainfo.svfontactive;
    end;
   end;
  end;
  if (ainfo.svseparatorframe <> nil) and
             (separatorframetemplate = nil) then begin
   separatorframetemplate:= ainfo.svseparatorframe;
  end;
  if (ainfo.svcheckboxframe <> nil) and
             (checkboxframetemplate = nil) then begin
   checkboxframetemplate:= ainfo.svcheckboxframe;
  end;
 end;
 if fhashotkey then begin
  instance.updatehotkeys();
 end;
end;

procedure tcustomskincontroller.setmainmenuskin(const instance: tcustommainmenu;
                             const ainfo: mainmenuskininfoty);
var
 i1,i2: int32;
begin
{$warnings off}
 setpopupmenuskin(tpopupmenu(instance),ainfo.svmain);
{$warnings on}
 with instance,ainfo do begin
  if (svpopup.svface <> nil) and (popupfacetemplate = nil) then begin
   popupfacetemplate:= svpopup.svface;
  end;
  if (svpopup.svframe <> nil) and (popupframetemplate = nil) then begin
   popupframetemplate:= svpopup.svframe;
  end;
  if (svpopup.svitemface <> nil) and (popupitemfacetemplate = nil) then begin
   popupitemfacetemplate:= svpopup.svitemface;
  end;
  if (svpopup.svitemframe <> nil) and (popupitemframetemplate = nil) then begin
   popupitemframetemplate:= svpopup.svitemframe;
  end;
  if (svpopup.svitemfaceactive <> nil) and
                 (popupitemfacetemplateactive = nil) then begin
   popupitemfacetemplateactive:= svpopup.svitemfaceactive;
  end;
  if (svpopup.svitemframeactive <> nil) and
             (popupitemframetemplateactive = nil) then begin
   popupitemframetemplateactive:= svpopup.svitemframeactive;
  end;
  if (svpopup.svseparatorframe <> nil) and
             (popupseparatorframetemplate = nil) then begin
   popupseparatorframetemplate:= svpopup.svseparatorframe;
  end;
  if (svpopup.svcheckboxframe <> nil) and
             (popupcheckboxframetemplate = nil) then begin
   popupcheckboxframetemplate:= svpopup.svcheckboxframe;
  end;
  if menu <> nil then begin
   if svpopup.svfont <> nil then begin
    for i1:= 0 to menu.count-1 do begin
     with tmenuitem1(menu[i1]) do begin;
      for i2:= 0 to submenu.count - 1 do begin
       with tmenuitem1(submenu[i2]) do begin;
        if ((ffont = nil) or (ffont.template = nil)) then begin
         createfont();
         ffont.template:= svpopup.svfont;
        end;
       end;
      end;
     end;
    end;
   end;
   if svpopup.svfontactive <> nil then begin
    for i1:= 0 to menu.count-1 do begin
     with tmenuitem1(menu[i1]) do begin;
      for i2:= 0 to submenu.count - 1 do begin
       with tmenuitem1(submenu[i2]) do begin;
        if ((ffontactive = nil) or (ffontactive.template = nil)) then begin
         createfontactive();
         ffontactive.template:= svpopup.svfontactive;
        end;
       end;
      end;
     end;
    end;
   end;
  end;
 end;
 if fhashotkey then begin
  instance.updatehotkeys();
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

procedure tcustomskincontroller.handleslider(const ainfo: skininfoty);
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

procedure tcustomskincontroller.handledispwidget(const ainfo: skininfoty);
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

procedure tcustomskincontroller.handlemainmenuwidget(const ainfo: skininfoty);
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

procedure tcustomskincontroller.handlesplitter(const ainfo: skininfoty);
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

procedure tcustomskincontroller.readactivedesign(reader: treader);
begin
 reader.readboolean; //dummy
end;

procedure tcustomskincontroller.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('extendernames',{$ifdef FPC}@{$endif}readextendernames,
            {$ifdef FPC}@{$endif}writeextendernames,high(fextenders) >= 0);
 filer.defineproperty('activedesign',{$ifdef FPC}@{$endif}readactivedesign,nil,
                                                false);
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

function tcustomskincontroller.getskinfont(const aindex: integer): tskinfont;
begin
 result:= fskinfonts[stockfontty(aindex)];
end;

procedure tcustomskincontroller.setskinfont(const aindex: integer;
               const avalue: tskinfont);
begin
 fskinfonts[stockfontty(aindex)].assign(avalue);
end;

procedure tcustomskincontroller.setgroups(const avalue: string);
var
 ar1: stringarty;
 ar2: groupinfoarty;
 int1,int2: integer;
begin
 if avalue = '' then begin
  fgroupinfo:= nil;
 end
 else begin
  ar1:= splitstring(avalue,',');
  setlength(ar2,length(ar1));
  for int1:= 0 to high(ar1) do begin
//   int2:= msestrings.strscan(ar1[int1],'.');
   int2:= msestrings.findchar(ar1[int1],'.');
   if int2 > 0 then begin
    ar2[int1].min:= strtoint(copy(ar1[int1],1,int2-1));
    if ar1[int1][int2+1] <> '.' then begin
     raise exception.create('Invalid groups format');
    end;
    ar2[int1].max:= strtoint(copy(ar1[int1],int2+2,bigint));
   end
   else begin
    ar2[int1].min:= strtoint(ar1[int1]);
    ar2[int1].max:= ar2[int1].min;
   end;
  end;
  fgroupinfo:= ar2;
 end;
 fgroups:= avalue;
end;

{ tskincontroller }

procedure inittabsskininfo(var info: tabsskininfoty);
begin
 info.svcolor:= cl_default;
 info.svcoloractive:= cl_default;
 info.svshift:= defaulttabshift;
 info.svsedge_level:= defaultedgelevel;
 info.svsedge_colordkshadow:= cl_default;
 info.svsedge_colorshadow:= cl_default;
 info.svsedge_colorlight:= cl_default;
 info.svsedge_colorhighlight:= cl_default;
 info.svsedge_colordkwidth:= -1;
 info.svsedge_colorhlwidth:= -1;
end;

procedure initscrollbarskininfo(var ascrollbar: scrollbarskininfoty);
begin
 with ascrollbar do begin
  svwidth:= -2;
  svcolor:= cl_default;
  svcolorpattern:= cl_default;
  svcolorpatternclicked:= cl_default;
  svcolorglyph:= cl_default;
  svbuttonendlength:= -2;
  svbuttonlength:= -2;
  svbuttonminlength:= -2;
//  svindentstart:= -2; //default 0
//  svindentend:= -2;
 end;
end;

constructor tskincontroller.create(aowner: tcomponent);
begin
 fwidgetcolor.svcolor:= cl_default;
 fwidgetcolor.svcolorcaptionframe:= cl_default;
 fstepbutton.svcolor:= cl_default;

 initscrollbarskininfo(fsb_horz);
 initscrollbarskininfo(fsb_vert);

 fsplitter.svcolor.svcolor:= cl_default;
 fsplitter.svcolor.svcolorcaptionframe:= cl_default;
 fsplitter.svcolorgrip:= cl_default;
 fsplitter.svgrip:= stb_default;

 fdispwidget.svcolor.svcolor:= cl_default;
 fdispwidget.svcolor.svcolorcaptionframe:= cl_default;

 fedit.svempty_color:= cl_default;
 fedit.svempty_textcolor:= cl_default;
 fedit.svempty_textcolorbackground:= cl_default;

 fdataedit.svedit.svempty_color:= cl_default;
 fdataedit.svedit.svempty_textcolor:= cl_default;
 fdataedit.svedit.svempty_textcolorbackground:= cl_default;

 fbutton.svcolor:= cl_default;
 fdatabutton.svcolor:= cl_default;
 fslider.svcolor:= cl_default;
 initscrollbarskininfo(fslider.svsb_horz);
 initscrollbarskininfo(fslider.svsb_vert);
 fframebutton.svcolor:= cl_default;
 fframebutton.svcolorglyph:= cl_default;
 inittabsskininfo(ftabbar.svtabhorz);
 inittabsskininfo(ftabbar.svtabvert);
 inittabsskininfo(ftabbar.svtabhorzopo);
 inittabsskininfo(ftabbar.svtabvertopo);
{
 ftabbar.svtabhorz.svcolor:= cl_default;
 ftabbar.svtabhorz.svcoloractive:= cl_default;
 ftabbar.svtabhorz.svshift:= defaulttabshift;
 ftabbar.svtabvert.svcolor:= cl_default;
 ftabbar.svtabvert.svcoloractive:= cl_default;
 ftabbar.svtabvert.svshift:= defaulttabshift;
 ftabbar.svtabhorzopo.svcolor:= cl_default;
 ftabbar.svtabhorzopo.svcoloractive:= cl_default;
 ftabbar.svtabhorzopo.svshift:= defaulttabshift;
 ftabbar.svtabvertopo.svcolor:= cl_default;
 ftabbar.svtabvertopo.svcoloractive:= cl_default;
 ftabbar.svtabvertopo.svshift:= defaulttabshift;
}
 ftabpage.svcolortab:= cl_default;
 ftabpage.svcoloractivetab:= cl_default;
 inherited;
end;

destructor tskincontroller.destroy;
begin
 inherited;
 fbutton.svfont.free;
end;

procedure tskincontroller.setsplitter_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fsplitter.svwidget.svface));
end;

procedure tskincontroller.setsplitter_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fsplitter.svwidget.svframe));
end;

procedure tskincontroller.setdispwidget_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fdispwidget.svwidget.svface));
end;

procedure tskincontroller.setdispwidget_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fdispwidget.svwidget.svframe));
end;

procedure tskincontroller.setedit_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fedit.svwidget.svface));
end;

procedure tskincontroller.setedit_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fedit.svwidget.svframe));
end;

procedure tskincontroller.setdataedit_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fdataedit.svedit.svwidget.svface));
end;

procedure tskincontroller.setdataedit_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fdataedit.svedit.svwidget.svframe));
end;

procedure tskincontroller.setbooleanedit_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(
                                fbooleanedit.svgraphdataedit.svwidget.svface));
end;

procedure tskincontroller.setbooleanedit_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(
                               fbooleanedit.svgraphdataedit.svwidget.svframe));
end;

procedure tskincontroller.setcontainer_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fcontainer.svwidget.svface));
end;

procedure tskincontroller.setcontainer_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fcontainer.svwidget.svframe));
end;

procedure tskincontroller.settabbar_horz_tab_edge_imagelist(
                                          const avalue: timagelist);
begin
 setlinkedvar(avalue,tmsecomponent(ftabbar.svtabhorz.svsedge_imagelist));
end;

procedure tskincontroller.settabbar_vert_tab_edge_imagelist(
                                          const avalue: timagelist);
begin
 setlinkedvar(avalue,tmsecomponent(ftabbar.svtabvert.svsedge_imagelist));
end;

procedure tskincontroller.settabbar_horzopo_tab_edge_imagelist(
                                          const avalue: timagelist);
begin
 setlinkedvar(avalue,tmsecomponent(ftabbar.svtabhorzopo.svsedge_imagelist));
end;

procedure tskincontroller.settabbar_vertopo_tab_edge_imagelist(
                                          const avalue: timagelist);
begin
 setlinkedvar(avalue,tmsecomponent(ftabbar.svtabvertopo.svsedge_imagelist));
end;

procedure tskincontroller.setsb_vert_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fsb_vert.svface));
end;

procedure tskincontroller.setsb_vert_face1(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fsb_vert.svface1));
end;

procedure tskincontroller.setsb_vert_face2(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fsb_vert.svface2));
end;

procedure tskincontroller.setsb_vert_facebutton(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fsb_vert.svfacebu));
end;

procedure tskincontroller.setsb_vert_faceendbutton(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fsb_vert.svfaceendbu));
end;

procedure tskincontroller.setsb_vert_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fsb_vert.svframe));
end;

procedure tskincontroller.setsb_vert_framebutton(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fsb_vert.svframebu));
end;

procedure tskincontroller.setsb_vert_frameendbutton1(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fsb_vert.svframeendbu1));
end;

procedure tskincontroller.setsb_vert_frameendbutton2(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fsb_vert.svframeendbu2));
end;

procedure tskincontroller.setsb_horz_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fsb_horz.svface));
end;

procedure tskincontroller.setsb_horz_face1(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fsb_horz.svface1));
end;

procedure tskincontroller.setsb_horz_face2(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fsb_horz.svface2));
end;

procedure tskincontroller.setsb_horz_facebutton(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fsb_horz.svfacebu));
end;

procedure tskincontroller.setsb_horz_faceendbutton(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fsb_horz.svfaceendbu));
end;

procedure tskincontroller.setsb_horz_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fsb_horz.svframe));
end;

procedure tskincontroller.setsb_horz_framebutton(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fsb_horz.svframebu));
end;

procedure tskincontroller.setsb_horz_frameendbutton1(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fsb_horz.svframeendbu1));
end;

procedure tskincontroller.setsb_horz_frameendbutton2(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fsb_horz.svframeendbu2));
end;

procedure tskincontroller.setgroupbox_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fgroupbox.svwidget.svface));
end;

procedure tskincontroller.setgroupbox_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fgroupbox.svwidget.svframe));
end;

procedure tskincontroller.setgrid_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fgrid.svwidget.svface));
end;

procedure tskincontroller.setgrid_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fgrid.svwidget.svframe));
end;

procedure tskincontroller.setgrid_fixrows_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fgrid.svfixrows.svface));
end;

procedure tskincontroller.setgrid_fixrows_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fgrid.svfixrows.svframe));
end;

procedure tskincontroller.setgrid_fixcols_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fgrid.svfixcols.svface));
end;

procedure tskincontroller.setgrid_fixcols_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fgrid.svfixcols.svframe));
end;

procedure tskincontroller.setgrid_datacols_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fgrid.svdatacols.svface));
end;

procedure tskincontroller.setgrid_datacols_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fgrid.svdatacols.svframe));
end;

procedure tskincontroller.setbutton_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fbutton.svwidget.svface));
end;

procedure tskincontroller.setbutton_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fbutton.svwidget.svframe));
end;

procedure tskincontroller.setdatabutton_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fdatabutton.svwidget.svface));
end;

procedure tskincontroller.setdatabutton_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fdatabutton.svwidget.svframe));
end;

procedure tskincontroller.setslider_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fslider.svwidget.svface));
end;

procedure tskincontroller.setslider_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fslider.svwidget.svframe));
end;

procedure tskincontroller.setssb_vert_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fslider.svsb_vert.svface));
end;

procedure tskincontroller.setssb_vert_face1(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fslider.svsb_vert.svface1));
end;

procedure tskincontroller.setssb_vert_face2(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fslider.svsb_vert.svface2));
end;

procedure tskincontroller.setssb_vert_facebutton(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fslider.svsb_vert.svfacebu));
end;

procedure tskincontroller.setssb_vert_faceendbutton(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fslider.svsb_vert.svfaceendbu));
end;

procedure tskincontroller.setssb_vert_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fslider.svsb_vert.svframe));
end;

procedure tskincontroller.setssb_vert_framebutton(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fslider.svsb_vert.svframebu));
end;

procedure tskincontroller.setssb_vert_frameendbutton1(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fslider.svsb_vert.svframeendbu1));
end;

procedure tskincontroller.setssb_vert_frameendbutton2(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fslider.svsb_vert.svframeendbu2));
end;

procedure tskincontroller.setssb_horz_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fslider.svsb_horz.svface));
end;

procedure tskincontroller.setssb_horz_face1(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fslider.svsb_horz.svface1));
end;

procedure tskincontroller.setssb_horz_face2(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fslider.svsb_horz.svface2));
end;

procedure tskincontroller.setssb_horz_facebutton(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fslider.svsb_horz.svfacebu));
end;

procedure tskincontroller.setssb_horz_faceendbutton(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fslider.svsb_horz.svfaceendbu));
end;

procedure tskincontroller.setssb_horz_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fslider.svsb_horz.svframe));
end;

procedure tskincontroller.setssb_horz_framebutton(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fslider.svsb_horz.svframebu));
end;

procedure tskincontroller.setssb_horz_frameendbutton1(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fslider.svsb_horz.svframeendbu1));
end;

procedure tskincontroller.setssb_horz_frameendbutton2(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fslider.svsb_horz.svframeendbu2));
end;

procedure tskincontroller.setframebutton_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fframebutton.svface));
end;

procedure tskincontroller.setframebutton_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fframebutton.svframe));
end;

procedure tskincontroller.setstepbutton_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fstepbutton.svface));
end;

procedure tskincontroller.setstepbutton_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fstepbutton.svframe));
end;

procedure tskincontroller.settabbar_horz_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabbar.svwidgethorz.svface));
end;

procedure tskincontroller.settabbar_horz_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabbar.svwidgethorz.svframe));
end;

procedure tskincontroller.settabbar_horz_tab_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabbar.svtabhorz.svface));
end;

procedure tskincontroller.settabbar_horz_tab_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabbar.svtabhorz.svframe));
end;

procedure tskincontroller.settabbar_horz_tab_faceactive(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabbar.svtabhorz.svfaceactive));
end;

procedure tskincontroller.settabbar_vert_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabbar.svwidgetvert.svface));
end;

procedure tskincontroller.settabbar_vert_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabbar.svwidgetvert.svframe));
end;

procedure tskincontroller.settabbar_vert_tab_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabbar.svtabvert.svface));
end;

procedure tskincontroller.settabbar_vert_tab_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabbar.svtabvert.svframe));
end;

procedure tskincontroller.settabbar_vert_tab_faceactive(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabbar.svtabvert.svfaceactive));
end;

procedure tskincontroller.settabbar_horzopo_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabbar.svwidgethorzopo.svface));
end;

procedure tskincontroller.settabbar_horzopo_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabbar.svwidgethorzopo.svframe));
end;

procedure tskincontroller.settabbar_horzopo_tab_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabbar.svtabhorzopo.svface));
end;

procedure tskincontroller.settabbar_horzopo_tab_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabbar.svtabhorzopo.svframe));
end;

procedure tskincontroller.settabbar_horzopo_tab_faceactive(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabbar.svtabhorzopo.svfaceactive));
end;

procedure tskincontroller.settabbar_vertopo_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabbar.svwidgetvertopo.svface));
end;

procedure tskincontroller.settabbar_vertopo_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabbar.svwidgetvertopo.svframe));
end;

procedure tskincontroller.settabbar_vertopo_tab_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabbar.svtabvertopo.svface));
end;

procedure tskincontroller.settabbar_vertopo_tab_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabbar.svtabvertopo.svframe));
end;

procedure tskincontroller.settabbar_vertopo_tab_faceactive(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabbar.svtabvertopo.svfaceactive));
end;

procedure tskincontroller.settabpage_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabpage.svwidget.svface));
end;

procedure tskincontroller.settabpage_facetab(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabpage.svfacetab));
end;

procedure tskincontroller.settabpage_faceactivetab(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabpage.svfaceactivetab));
end;

procedure tskincontroller.settabpage_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabpage.svwidget.svframe));
end;

procedure tskincontroller.settabpage_fonttab(const avalue: tfontcomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabpage.svfonttab));
end;

procedure tskincontroller.settabpage_fontactivetab(const avalue: tfontcomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftabpage.svfontactivetab));
end;

procedure tskincontroller.settoolbar_horz_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftoolbar_horz.svwidget.svface));
end;

procedure tskincontroller.settoolbar_horz_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftoolbar_horz.svwidget.svframe));
end;

procedure tskincontroller.settoolbar_horz_buttonface(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftoolbar_horz.svbuttonface));
end;

procedure tskincontroller.settoolbar_horz_buttonfacechecked(
              const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftoolbar_horz.svbuttonfacechecked));
end;

procedure tskincontroller.settoolbar_horz_buttonframe(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftoolbar_horz.svbuttonframe));
end;

procedure tskincontroller.settoolbar_horz_buttonframechecked(
              const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftoolbar_horz.svbuttonframechecked));
end;

procedure tskincontroller.settoolbar_horz_buttonframesep(
                                                    const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftoolbar_horz.svbuttonframesep));
end;

procedure tskincontroller.settoolbar_vert_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftoolbar_vert.svwidget.svface));
end;

procedure tskincontroller.settoolbar_vert_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftoolbar_vert.svwidget.svframe));
end;

procedure tskincontroller.settoolbar_vert_buttonface(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftoolbar_vert.svbuttonface));
end;

procedure tskincontroller.settoolbar_vert_buttonfacechecked(
              const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftoolbar_vert.svbuttonfacechecked));
end;

procedure tskincontroller.settoolbar_vert_buttonframe(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftoolbar_vert.svbuttonframe));
end;

procedure tskincontroller.settoolbar_vert_buttonframechecked(
              const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftoolbar_vert.svbuttonframechecked));
end;

procedure tskincontroller.settoolbar_vert_buttonframesep(
                                                    const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftoolbar_vert.svbuttonframesep));
end;

procedure tskincontroller.setpopupmenu_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fpopupmenu.svface));
end;

procedure tskincontroller.setpopupmenu_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fpopupmenu.svframe));
end;

procedure tskincontroller.setpopupmenu_itemface(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fpopupmenu.svitemface));
end;

procedure tskincontroller.setpopupmenu_itemframe(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fpopupmenu.svitemframe));
end;

procedure tskincontroller.setpopupmenu_itemfaceactive(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fpopupmenu.svitemfaceactive));
end;

procedure tskincontroller.setpopupmenu_itemframeactive(
                                                 const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fpopupmenu.svitemframeactive));
end;

procedure tskincontroller.setpopupmenu_font(const avalue: tfontcomp);
begin
 setlinkedvar(avalue,tmsecomponent(fpopupmenu.svfont));
end;

procedure tskincontroller.setpopupmenu_fontactive(const avalue: tfontcomp);
begin
 setlinkedvar(avalue,tmsecomponent(fpopupmenu.svfontactive));
end;

procedure tskincontroller.setpopupmenu_separatorframe(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fpopupmenu.svseparatorframe));
end;

procedure tskincontroller.setpopupmenu_checkboxframe(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fpopupmenu.svcheckboxframe));
end;

procedure tskincontroller.setmainmenu_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenu.svmain.svface));
end;

procedure tskincontroller.setmainmenu_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenu.svmain.svframe));
end;

procedure tskincontroller.setmainmenu_itemface(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenu.svmain.svitemface));
end;

procedure tskincontroller.setmainmenu_itemframe(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenu.svmain.svitemframe));
end;

procedure tskincontroller.setmainmenu_itemfaceactive(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenu.svmain.svitemfaceactive));
end;

procedure tskincontroller.setmainmenu_itemframeactive(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenu.svmain.svitemframeactive));
end;

procedure tskincontroller.setmainmenu_font(const avalue: tfontcomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenu.svmain.svfont));
end;

procedure tskincontroller.setmainmenu_fontactive(const avalue: tfontcomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenu.svmain.svfontactive));
end;

procedure tskincontroller.setmainmenu_separatorframe(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenu.svmain.svseparatorframe));
end;

procedure tskincontroller.setmainmenu_checkboxframe(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenu.svmain.svcheckboxframe));
end;

procedure tskincontroller.setmainmenu_popupface(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenu.svpopup.svface));
end;

procedure tskincontroller.setmainmenu_popupframe(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenu.svpopup.svframe));
end;

procedure tskincontroller.setmainmenu_popupitemface(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenu.svpopup.svitemface));
end;

procedure tskincontroller.setmainmenu_popupitemframe(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenu.svpopup.svitemframe));
end;

procedure tskincontroller.setmainmenu_popupitemfaceactive(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenu.svpopup.svitemfaceactive));
end;

procedure tskincontroller.setmainmenu_popupitemframeactive(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenu.svpopup.svitemframeactive));
end;

procedure tskincontroller.setmainmenu_popupfont(const avalue: tfontcomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenu.svpopup.svfont));
end;

procedure tskincontroller.setmainmenu_popupfontactive(const avalue: tfontcomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenu.svpopup.svfontactive));
end;

procedure tskincontroller.setmainmenu_popupseparatorframe(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenu.svpopup.svseparatorframe));
end;

procedure tskincontroller.setmainmenu_popupcheckboxframe(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenu.svpopup.svcheckboxframe));
end;

procedure tskincontroller.setmainmenuwidget_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenuwidget.svwidget.svface));
end;

procedure tskincontroller.setmainmenuwidget_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenuwidget.svwidget.svframe));
end;

procedure tskincontroller.setmainmenuwidget_itemface(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenuwidget.svmenu.svmain.svitemface));
end;

procedure tskincontroller.setmainmenuwidget_itemframe(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenuwidget.svmenu.svmain.svitemframe));
end;

procedure tskincontroller.setmainmenuwidget_itemfaceactive(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenuwidget.svmenu.svmain.svitemfaceactive));
end;

procedure tskincontroller.setmainmenuwidget_itemframeactive(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenuwidget.svmenu.svmain.svitemframeactive));
end;

procedure tskincontroller.setmainmenuwidget_font(const avalue: tfontcomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenuwidget.svmenu.svmain.svfont));
end;

procedure tskincontroller.setmainmenuwidget_fontactive(const avalue: tfontcomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenuwidget.svmenu.svmain.svfontactive));
end;

procedure tskincontroller.setmainmenuwidget_separatorframe(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenuwidget.svmenu.svmain.svseparatorframe));
end;

procedure tskincontroller.setmainmenuwidget_checkboxframe(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenuwidget.svmenu.svmain.svcheckboxframe));
end;

procedure tskincontroller.setmainmenuwidget_popupface(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenuwidget.svmenu.svpopup.svface));
end;

procedure tskincontroller.setmainmenuwidget_popupframe(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenuwidget.svmenu.svpopup.svframe));
end;

procedure tskincontroller.setmainmenuwidget_popupitemface(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenuwidget.svmenu.svpopup.svitemface));
end;

procedure tskincontroller.setmainmenuwidget_popupitemframe(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenuwidget.svmenu.svpopup.svitemframe));
end;

procedure tskincontroller.setmainmenuwidget_popupitemfaceactive(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenuwidget.svmenu.svpopup.svitemfaceactive));
end;

procedure tskincontroller.setmainmenuwidget_popupitemframeactive(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenuwidget.svmenu.svpopup.svitemframeactive));
end;

procedure tskincontroller.setmainmenuwidget_popupfont(const avalue: tfontcomp);
begin
 setlinkedvar(avalue,tmsecomponent(fmainmenuwidget.svmenu.svpopup.svfont));
end;

procedure tskincontroller.setmainmenuwidget_popupfontactive(
                                                     const avalue: tfontcomp);
begin
 setlinkedvar(avalue,tmsecomponent(
                                fmainmenuwidget.svmenu.svpopup.svfontactive));
end;

procedure tskincontroller.setmainmenuwidget_popupseparatorframe(
                                                const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(
                              fmainmenuwidget.svmenu.svpopup.svseparatorframe));
end;

procedure tskincontroller.setmainmenuwidget_popupcheckboxframe(
                                             const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(
                            fmainmenuwidget.svmenu.svpopup.svcheckboxframe));
end;

procedure tskincontroller.handlewidget(const askin: skininfoty;
            const acolor: pwidgetcolorinfoty);
var
 int1: integer;
 wi1: twidget1;
 co1,co2: colorty;
begin
 if acolor = nil then begin
  co1:= fwidgetcolor.svcolor;
  co2:= fwidgetcolor.svcolorcaptionframe
 end
 else begin
  co1:= acolor^.svcolor;
  if co1 = cl_default then begin
   co1:= fwidgetcolor.svcolor;
  end;
  co2:= acolor^.svcolorcaptionframe;
  if co2 = cl_default then begin
   co2:= fwidgetcolor.svcolorcaptionframe;
  end;
 end;
 wi1:= twidget1(askin.instance);
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
  if not setwidgetcolorcaptionframe(wi1,co2) then begin
   setwidgetcolor(wi1,co1);
  end;
  if fhashotkey then begin
   updatehotkeys();
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
 setwidgetcolor(twidget(ainfo.instance),fbutton.svcolor);
 setwidgetskin(twidget(ainfo.instance),fbutton.svwidget);
 setwidgetfont(twidget(ainfo.instance),fbutton.svfont);
 with tsimplebutton(ainfo.instance) do begin
  if not (osk_nooptions in optionsskin) then begin
   if fbutton.svoptionsadd <> [] then begin
    options:= options + fbutton.svoptionsadd;
   end;
   if fbutton.svoptionsremove <> [] then begin
    options:= options - fbutton.svoptionsremove;
   end;
  end;
 end;
end;

procedure tskincontroller.handledatabutton(const ainfo: skininfoty);
begin
 handlewidget(ainfo);
 setwidgetcolor(twidget(ainfo.instance),fdatabutton.svcolor);
 setwidgetskin(twidget(ainfo.instance),fdatabutton.svwidget);
 setwidgetfont(twidget(ainfo.instance),fdatabutton.svfont);
 with tcustomdatabutton(ainfo.instance) do begin
  if not (osk_nooptions in optionsskin) then begin
   if fdatabutton.svoptionsadd <> [] then begin
    options:= options + fdatabutton.svoptionsadd;
   end;
   if fdatabutton.svoptionsremove <> [] then begin
    options:= options - fdatabutton.svoptionsremove;
   end;
  end;
 end;
end;

procedure tskincontroller.handleslider(const ainfo: skininfoty);
begin
 handlewidget(ainfo);
 setwidgetcolor(twidget(ainfo.instance),fslider.svcolor);
 setwidgetskin(twidget(ainfo.instance),fslider.svwidget);
 with tcustomslider(ainfo.instance) do begin
  if direction in [gd_left,gd_right] then begin
   setscrollbarskin(scrollbar,fslider.svsb_horz);
  end
  else begin
   setscrollbarskin(scrollbar,fslider.svsb_vert);
  end;
 end;
end;

procedure tskincontroller.handlecontainer(const ainfo: skininfoty);
begin
 setwidgetskin(twidget(ainfo.instance),fcontainer.svwidget);
end;

procedure tskincontroller.createbutton_font;
begin
 if fbutton.svfont = nil then begin
  fbutton.svfont:= toptionalfont.create;
 end;
end;

procedure tskincontroller.setbutton_font(const avalue: toptionalfont);
begin
 setoptionalobject(avalue,fbutton.svfont,{$ifdef FPC}@{$endif}createbutton_font);
end;

function tskincontroller.getbutton_font: toptionalfont;
begin
 getoptionalobject(fbutton.svfont,{$ifdef FPC}@{$endif}createbutton_font);
 result:= fbutton.svfont;
end;

procedure tskincontroller.createdatabutton_font;
begin
 if fdatabutton.svfont = nil then begin
  fdatabutton.svfont:= toptionalfont.create;
 end;
end;

procedure tskincontroller.setdatabutton_font(const avalue: toptionalfont);
begin
 setoptionalobject(avalue,fdatabutton.svfont,
                                {$ifdef FPC}@{$endif}createbutton_font);
end;

function tskincontroller.getdatabutton_font: toptionalfont;
begin
 getoptionalobject(fdatabutton.svfont,{$ifdef FPC}@{$endif}createbutton_font);
 result:= fdatabutton.svfont;
end;

procedure tskincontroller.handletabbar(const ainfo: skininfoty);
var
 ta1: tcustomtabbar;
begin
 handlewidget(ainfo);
 ta1:= tcustomtabbar(ainfo.instance);
 if tabo_vertical in ta1.options then begin
  if tabo_opposite in ta1.options then begin
   setwidgetskin(ta1,ftabbar.svwidgetvertopo);
   settabsskin(ta1,ftabbar.svtabvertopo);
  end
  else begin
   setwidgetskin(ta1,ftabbar.svwidgetvert);
   settabsskin(ta1,ftabbar.svtabvert);
  end;
 end
 else begin
  if tabo_opposite in ta1.options then begin
   setwidgetskin(ta1,ftabbar.svwidgethorzopo);
   settabsskin(ta1,ftabbar.svtabhorzopo);
  end
  else begin
   setwidgetskin(ta1,ftabbar.svwidgethorz);
   settabsskin(ta1,ftabbar.svtabhorz);
  end;
 end;
 setstepbuttonskin(ta1.frame,fstepbutton);
end;

procedure tskincontroller.handletabpage(const ainfo: skininfoty);
var
 intf1: itabpage;
 font1: tfont;
begin
 handlewidget(ainfo);
 setwidgetskin(twidget(ainfo.instance),ftabpage.svwidget);
 if {((ftabpage.svcolortab <> cl_default) or
               (ftabpage.svcoloractivetab <> cl_default)) and}
    twidget(ainfo.instance).getcorbainterface(typeinfo(itabpage),
                                                      intf1) then begin
  if (ftabpage.svcolortab <> cl_default) and
                            (intf1.getcolortab = cl_default) then begin
   intf1.setcolortab(ftabpage.svcolortab);
  end;
  if (ftabpage.svcoloractivetab <> cl_default) and
                            (intf1.getcoloractivetab = cl_default) then begin
   intf1.setcoloractivetab(ftabpage.svcoloractivetab);
  end;
  if (ftabpage.svfacetab <> nil) and (intf1.getfacetab() = nil) then begin
   intf1.setfacetab(ftabpage.svfacetab);
  end;
  if (ftabpage.svfaceactivetab <> nil) and
                            (intf1.getfaceactivetab() = nil) then begin
   intf1.setfaceactivetab(ftabpage.svfaceactivetab);
  end;
  if (ftabpage.svfonttab <> nil) then begin
   font1:= intf1.getfonttab();
   if font1 = nil then begin
    intf1.setfonttab(tfont(pointer(1))); //create font
    font1:= intf1.getfonttab();
   end;
   if font1.template = nil then begin
    font1.template:= ftabpage.svfonttab;
   end;
  end;
  if (ftabpage.svfontactivetab <> nil) then begin
   font1:= intf1.getfontactivetab();
   if font1 = nil then begin
    intf1.setfontactivetab(tfont(pointer(1))); //create font
    font1:= intf1.getfontactivetab();
   end;
   if font1.template = nil then begin
    font1.template:= ftabpage.svfontactivetab;
   end;
  end;
 end;
end;

procedure tskincontroller.handletoolbar(const ainfo: skininfoty);
var
 tb1: tcustomtoolbar;
begin
 handlewidget(ainfo);
 tb1:= tcustomtoolbar(ainfo.instance);
 if ftoolbar_horz.svbuttonframesep <> nil then begin
  with tb1.buttons do begin
   createframesephorz();
   setframetemplate(ftoolbar_horz.svbuttonframesep,framesephorz);
  end;
 end;
 if ftoolbar_vert.svbuttonframesep <> nil then begin
  with tb1.buttons do begin
   createframesepvert();
   setframetemplate(ftoolbar_vert.svbuttonframesep,framesepvert);
  end;
 end;
 if tb1.width >= tb1.height then begin
  setwidgetskin(tb1,ftoolbar_horz.svwidget);
  setstepbuttonskin(tb1.frame,fstepbutton);
  if ftoolbar_horz.svbuttonface <> nil then begin
   with tb1.buttons do begin
    createface();
    setfacetemplate(ftoolbar_horz.svbuttonface,face);
   end;
  end;
  if ftoolbar_horz.svbuttonfacechecked <> nil then begin
   with tb1.buttons do begin
    createfacechecked();
    setfacetemplate(ftoolbar_horz.svbuttonfacechecked,facechecked);
   end;
  end;
  if ftoolbar_horz.svbuttonframe <> nil then begin
   with tb1.buttons do begin
    createframe();
    setframetemplate(ftoolbar_horz.svbuttonframe,frame);
   end;
  end;
  if ftoolbar_horz.svbuttonframechecked <> nil then begin
   with tb1.buttons do begin
    createframechecked();
    setframetemplate(ftoolbar_horz.svbuttonframechecked,framechecked);
   end;
  end;
 end
 else begin
  setwidgetskin(tb1,ftoolbar_vert.svwidget);
  setstepbuttonskin(tb1.frame,fstepbutton);
  if ftoolbar_vert.svbuttonface <> nil then begin
   with tb1.buttons do begin
    createface();
    setfacetemplate(ftoolbar_vert.svbuttonface,face);
   end;
  end;
  if ftoolbar_vert.svbuttonfacechecked <> nil then begin
   with tb1.buttons do begin
    createfacechecked();
    setfacetemplate(ftoolbar_vert.svbuttonfacechecked,facechecked);
   end;
  end;
  if ftoolbar_vert.svbuttonframe <> nil then begin
   with tb1.buttons do begin
    createframe();
    setframetemplate(ftoolbar_vert.svbuttonframe,frame);
   end;
  end;
  if ftoolbar_vert.svbuttonframechecked <> nil then begin
   with tb1.buttons do begin
    createframechecked();
    setframetemplate(ftoolbar_vert.svbuttonframechecked,framechecked);
   end;
  end;
 end;
end;

procedure tskincontroller.handlesplitter(const ainfo: skininfoty);
begin
 handlewidget(ainfo,@fsplitter.svcolor);
 setwidgetskin(twidget(ainfo.instance),fsplitter.svwidget);
 with fsplitter,tcustomsplitter(ainfo.instance) do begin
  if (svcolorgrip <> cl_default) and (colorgrip = cl_default) then begin
   colorgrip:= svcolorgrip;
  end;
  if (svgrip <> stb_default) and (grip = stb_default) then begin
   grip:= svgrip;
  end;
 end;
end;

procedure tskincontroller.handledispwidget(const ainfo: skininfoty);
begin
 handlewidget(ainfo,@fdispwidget.svcolor);
 setwidgetskin(twidget(ainfo.instance),fdispwidget.svwidget);
end;

procedure tskincontroller.handleedit(const ainfo: skininfoty);
begin
 handlewidget(ainfo);
 seteditskin(tcustomedit(ainfo.instance),fedit);
end;

procedure tskincontroller.handledataedit(const ainfo: skininfoty);
begin
 handlewidget(ainfo);
 setdataeditskin(tdataedit(ainfo.instance),fdataedit);
end;

procedure tskincontroller.handlebooleanedit(const ainfo: skininfoty);
begin
 handlewidget(ainfo);
 setwidgetskin(twidget(ainfo.instance),fbooleanedit.svgraphdataedit.svwidget);
 with tcustombooleanedit(ainfo.instance) do begin
  if not (osk_nooptions in optionsskin) then begin
   if fbooleanedit.svoptionsadd <> [] then begin
    options:= options + fbooleanedit.svoptionsadd;
   end;
   if fbooleanedit.svoptionsremove <> [] then begin
    options:= options - fbooleanedit.svoptionsremove;
   end;
  end;
 end;
// setgraphdataeditskin(tgraphdataedit(ainfo.instance),fbooleanedit);
end;

procedure tskincontroller.handlemainmenu(const ainfo: skininfoty);
begin
 setmainmenuskin(tcustommainmenu(ainfo.instance),fmainmenu);
end;

procedure tskincontroller.handlepopupmenu(const ainfo: skininfoty);
begin
 setpopupmenuskin(tpopupmenu(ainfo.instance),fpopupmenu);
end;

procedure tskincontroller.handlemainmenuwidget(const ainfo: skininfoty);
begin
 handlewidget(ainfo);
 setwidgetskin(twidget(ainfo.instance),fmainmenuwidget.svwidget);
 setmainmenuskin(tmainmenuwidget(ainfo.instance).menu,fmainmenuwidget.svmenu);
end;

procedure tskincontroller.handlegrid(const ainfo: skininfoty);
begin
 handlewidget(ainfo);
 setgridskin(tcustomgrid(ainfo.instance),fgrid);
end;

{ tskinfontalias }

constructor tskinfontalias.create(aowner: tobject);
begin
 fmode:= fam_overwrite;
 fxscale:= 1;
 inherited;
end;

procedure tskinfontalias.settemplate(const avalue: tfontcomp);
begin
 tcustomskincontroller(fowner).setlinkedvar(avalue,tmsecomponent(ftemplate));
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

procedure tskinextender.removeskin(const ainfo: skininfoty;
                                             var handled: boolean);
begin
 //dummy
end;

{ tskinfont }
(*
constructor tskinfont.create;
begin
{
 fcolor:= cl_default;
 fcolorbackground:= cl_default;
 fshadow_color:= cl_default;
 fshadow_shiftx:= 1;
 fshadow_shifty:= 1;
 fgloss_color:= cl_default;
 fgloss_shiftx:= -1;
 fgloss_shifty:= -1;
 fgrayed_color:= cl_default;
 fgrayed_colorshadow:= cl_default;
 fgrayed_shiftx:= 1;
 fgrayed_shifty:= 1;
}
end;
*)
procedure tskinfont.updatefont(const adest: tfont);
begin
 if ftemplate <> nil then begin
  with adest do begin
   if template = nil then begin
    template:= ftemplate;
   end;
 {
  if fcolor <> cl_default then begin
   color:= fcolor;
  end;
  if fcolorbackground <> cl_default then begin
   colorbackground:= fcolorbackground;
  end;
  if fshadow_color <> cl_default then begin
   shadow_color:= fshadow_color;
  end;
  if fshadow_shiftx <> 1 then begin
   shadow_shiftx:= fshadow_shiftx;
  end;
  if fshadow_shifty <> 1 then begin
   shadow_shifty:= fshadow_shifty;
  end;
  if fgloss_color <> cl_default then begin
   gloss_color:= fgloss_color;
  end;
  if fgloss_shiftx <> -1 then begin
   gloss_shiftx:= fgloss_shiftx;
  end;
  if fgloss_shifty <> -1 then begin
   gloss_shifty:= fgloss_shifty;
  end;
  if fgrayed_color <> cl_default then begin
   grayed_color:= fgrayed_color;
  end;
  if fgrayed_colorshadow <> cl_default then begin
   grayed_colorshadow:= fgrayed_colorshadow;
  end;
  if fgrayed_shiftx <> 1 then begin
   grayed_shiftx:= fgrayed_shiftx;
  end;
  if fgrayed_shifty <> 1 then begin
   grayed_shifty:= fgrayed_shifty;
  end;
  if fextraspace <> 0 then begin
   extraspace:= extraspace;
  end;
  if fstyle <> [] then begin
   style:= fstyle;
  end;
 }
  end;
 end;
end;

procedure tskinfont.settemplate(const avalue: tfontcomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftemplate));
end;

{ tskinhandler }

procedure tskinhandler.updateskin1(const ainfo: skininfoty;
                                            const controllerar: skincontrollerarty);
var
 int1,int2: integer;
begin
 for int1:= 0 to high(controllerar) do begin
  if controllerar[int1].fgroupinfo = nil then begin
   controllerar[int1].updateskin(ainfo);
  end
  else begin
   for int2:= 0 to high(controllerar[int1].fgroupinfo) do begin
    with controllerar[int1].fgroupinfo[int2] do begin
     if (ainfo.group >= min) and (ainfo.group <= max) then begin
      controllerar[int1].updateskin(ainfo);
      break;
     end;
    end;
   end;
  end;
 end;
end;
{
procedure tskinhandler.removeskin1(const ainfo: skininfoty;
                                            const controllerar: skincontrollerarty);
var
 int1,int2: integer;
begin
 for int1:= 0 to high(controllerar) do begin
  if controllerar[int1].fgroupinfo = nil then begin
   controllerar[int1].removeskin(ainfo);
  end
  else begin
   for int2:= 0 to high(controllerar[int1].fgroupinfo) do begin
    with controllerar[int1].fgroupinfo[int2] do begin
     if (ainfo.group >= min) and (ainfo.group <= max) then begin
      controllerar[int1].removeskin(ainfo);
      break;
     end;
    end;
   end;
  end;
 end;
end;
}
procedure tskinhandler.updateskin(const ainfo: skininfoty);
begin
 updateskin1(ainfo,factiveskincontroller);
end;
{
procedure tskinhandler.removeskin(const ainfo: skininfoty);
begin
 removeskin1(ainfo,factiveskincontroller);
end;
}
function comparecontroller(const l,r): integer;
begin
 result:= tcustomskincontroller(r).order-tcustomskincontroller(l).order;
end;

procedure tskinhandler.setactive(const sender: tcustomskincontroller;
          var controllerar: skincontrollerarty;
          const handleproc: skineventty; var handlevar: skineventty{;
          const removeproc: skineventty; var removevar: skineventty});
begin
 with sender do begin
  if fisactive then begin
   adduniqueitem(pointerarty(controllerar),sender);
   sortarray(pointerarty(controllerar),@comparecontroller)
  end
  else begin
   removeitem(pointerarty(controllerar),sender);
  end;
  if controllerar <> nil then begin
   handlevar:= handleproc;
//   removevar:= removeproc;
  end
  else begin
   handlevar:= nil;
//   removevar:= nil;
  end;
 end;
end;

procedure tskinhandler.updateactive(const sender: tcustomskincontroller);
begin
 setactive(sender,factiveskincontroller,
             {$ifdef FPC}@{$endif}updateskin,oninitskinobject{,
                                        @removeskin,onremoveskinobject});
end;

procedure tskinhandler.doactivate(const sender: tcustomskincontroller);
begin
 //dummy
end;

procedure tskinhandler.dodeactivate(const sender: tcustomskincontroller);
begin
 //dummy
end;

initialization
 setskinhandler(tskinhandler.create);
finalization
 freeandnil(fhandler);
end.
