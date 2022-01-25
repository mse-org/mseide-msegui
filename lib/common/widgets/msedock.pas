{ MSEgui Copyright (c) 1999-2018 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msedock;

{$ifdef FPC}{$mode objfpc}{$h+}{$GOTO ON}{$interfaces corba}{$endif}

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
 msewidgets,classes,mclasses,msedrag,msegui,msegraphutils,mseevent,mseclasses,
 msegraphics,
{$ifdef mse_dynpo}
 msestockobjects_dynpo,
{$else}
 msestockobjects,
{$endif}
 mseglob,mseguiglob,msestat,msestatfile,msepointer,
 msesplitter,msesimplewidgets,msetypes,msestrings,msebitmap,mseobjectpicker,
 msetabsglob,msemenus,msedrawtext,mseshapes,msedragglob,mseinterfaces,msetabs;

//todo: optimize

const
 defaultgripsize = 10;
 defaultgripgrip = stb_none;
 defaultgripcolor = cl_white;
 defaultgripcoloractive = cl_activegrip;
 defaultgrippos = cp_right;
 defaultsplittersize = 3;

type
 optiondockty = (od_savepos,od_savezorder,od_savechildren,
            od_canmove,od_cansize,od_canfloat,od_candock,od_acceptsdock,
            od_dockparent,od_expandforfixsize,
            od_splitvert,od_splithorz,od_tabed,od_proportional,
            od_propsize,od_fixsize,od_top,od_background,
            od_alignbegin,od_aligncenter,od_alignend,
            od_nofit,od_banded,od_nosplitsize,od_nosplitmove,
            od_lock,od_nolock,od_thumbtrack,od_captionhint,{od_buttonhints,}
            od_childicons); //use odf_childicons instead
 optionsdockty = set of optiondockty;

 dockbuttonrectty = (dbr_none,dbr_handle,dbr_close,dbr_maximize,dbr_normalize,
                     dbr_minimize,dbr_fixsize,dbr_float,
                     dbr_top,dbr_background,dbr_lock,dbr_nolock);
const
 defaultoptionsdock = [od_savepos,od_savezorder,od_savechildren,
                       od_captionhint];
 defaultoptionsdocknochildren = defaultoptionsdock - [od_savechildren];
 deprecatedoptionsdock = [od_childicons];

 dbr_first = dbr_handle;
 dbr_last = dbr_nolock;
 dbr_firstbutton = dockbuttonrectty(ord(dbr_first)+1);
 dbr_lastbutton = dbr_last;
 defaulttaboptions= [tabo_dragdest,tabo_dragsource];

type
 twidgetdragobject = class(tdragobject)
  private
   function getwidget: twidget;
  public
   constructor create(const asender: twidget; var instance: tdragobject;
                       const apickpos: pointty);
  property widget: twidget read getwidget;
 end;

 tdockcontroller = class;

 tdockdragobject = class(twidgetdragobject)
  private
   fxorwidget: twidget;
   fxorrect: rectty; //screen origin
   fdock: tdockcontroller;
   findex: integer;
   fcheckeddockcontroller: tdockcontroller;
  protected
   procedure drawxorpic;
   procedure setxorwidget(const awidget: twidget; const screenrect: rectty);
  public
   constructor create(const adock: tdockcontroller; const asender: twidget;
          var instance: tdragobject; const apickpos: pointty);
   destructor destroy; override;
   procedure refused(const apos: pointty); override;
 end;

 idockcontroller = interface(idragcontroller)[miid_idockcontroller]
  function checkdock(var info: draginfoty): boolean;
  function getbuttonrects(const index: dockbuttonrectty): rectty;
                                      //origin = clientrect.pos
  function getplacementrect: rectty;  //origin = container.pos
  function getminimizedsize(out apos: captionposty): sizety;
                     //cx = 0 -> normalwidth, cy = 0 -> normalheight
  function getcaption: msestring;
  function getchildicon: tmaskedbitmap; //own or first icon of dockchildren,
                                        //can return nil
  procedure dolayoutchanged(const sender: tdockcontroller);
  procedure dodockcaptionchanged(const sender: tdockcontroller);
 end;

 checkdockeventty = procedure(const sender: tobject; const apos: pointty;
                      const dockdragobject: tdockdragobject;
                      var accept: boolean) of object;

 tdockhandle = class(tpublishedwidget)
  private
   fcontroller: tdockcontroller;
   fgrip_pos: captionposty;
   fgrip_color: colorty;
   fgrip_grip: stockbitmapty;
   procedure setgrip_color(const Value: colorty);
   procedure setgrip_grip(const Value: stockbitmapty);
   procedure setgrip_pos(const Value: captionposty);
  protected
   function gethandlerect: rectty;
   procedure clientmouseevent(var info: mouseeventinfoty); override;
   procedure dopaintforeground(const canvas: tcanvas); override;
   function gethint: msestring; override;
  public
   constructor create(aowner: tcomponent); override;
  published
   property grip_pos: captionposty read fgrip_pos write setgrip_pos default cp_bottomright;
   property grip_grip: stockbitmapty read fgrip_grip write setgrip_grip default stb_none;
   property grip_color: colorty read fgrip_color write setgrip_color default defaultgripcolor;
   property bounds_cx default 15;
   property bounds_cy default 15;
   property anchors default [an_right,an_bottom];
   property color default cl_transparent;
   property optionswidget default defaultoptionswidget + [ow_top{,ow_noautosizing}];
   property optionswidget1 default defaultoptionswidget1 + [ow1_noautosizing];
 end;

 dockstatety = (dos_layoutvalid,dos_sizing,
                dos_updating1,dos_updating2,dos_updating3,
                 dos_updating4,dos_updating5,dos_tabedending,
                 {
                    dos_closebuttonclicked,dos_maximizebuttonclicked,
                    dos_normalizebuttonclicked,dos_minimizebuttonclicked,
                    dos_fixsizebuttonclicked,dos_floatbuttonclicked,
                    dos_topbuttonclicked,dos_backgroundbuttonclicked,
                    dos_lockbuttonclicked,dos_nolockbuttonclicked,
                 }
                    dos_moving,dos_hasfloatbutton,
                    {dos_proprefvalid,}dos_showed,dos_xorpic);
 dockstatesty = set of dockstatety;

 splitdirty = (sd_none,sd_vert,sd_horz,sd_tabed);
 mdistatety = (mds_normal,mds_maximized,mds_minimized,mds_floating);

 dockcontrollereventty = procedure(const sender: tdockcontroller) of object;

 docklayouteventty = procedure(const sender: twidget;
                                        const achildren: widgetarty) of object;
 mdistatechangedeventty = procedure(const sender: twidget;
                             const oldvalue,newvalue: mdistatety) of object;
 dockrecteventty = procedure(const sender: twidget;
                                          var arect: rectty) of object;

 bandinfoty = record
  first: integer;
  last: integer;
  size: integer;
 end;

 bandinfoarty = array of bandinfoty;

 tdockcontroller = class(tdragcontroller)
  private
   foncalclayout: docklayouteventty;
   fonlayoutchanged: dockcontrollereventty;
   fonboundschanged: dockcontrollereventty;
   foncaptionchanged: dockcontrollereventty;
   fonfloat: notifyeventty;
   fondock: notifyeventty;
   fonchilddock: widgeteventty;
   fonchildfloat: widgeteventty;
   foncheckdock: checkdockeventty;
   fdockhandle: tdockhandle;
   fsplitter_size: integer;
   fcursorbefore: cursorshapety;
   fsizeindex: integer;
   fmoveindex: integer;
   fsizingrect: rectty;
   fsizeoffset: integer;
   fdockstate: dockstatesty;
   fcaption: msestring;
   fsize: sizety;
   fsplitter_color: colorty;
   fsplitter_colorgrip: colorty;
   fsplitter_grip: stockbitmapty;
   fsplitterrects: rectarty;
   frecalclevel: integer;
   fsplitdir,fasplitdir: splitdirty;
   fmdistate: mdistatety;
   fnormalrect: rectty;
   ftabwidget: ttabwidget; //tdocktabwidget
   ftabpage: ttabpage;     //tdocktabpage
   ftaborder: msestringarty;
   factivetab: integer; //used only for statreading
   fuseroptions: optionsdockty;
   floatdockcount: integer;
   fonmdistatechanged: mdistatechangedeventty;
   ftab_options: tabbaroptionsty;
   ftab_size: integer;
   ftab_sizemin: integer;
   ftab_sizemax: integer;
   ftab_color: colorty;
   ftab_colortab: colorty;
   ftab_coloractivetab: colorty;
   ftab_frame: tframecomp;
   ftab_face: tfacecomp;
   ftab_facetab: tfacecomp;
   ftab_faceactivetab: tfacecomp;
   ftab_frametab: tframecomp;
   fplacementrect: rectty;
   fhiddensizeref: sizety;
   fbands: bandinfoarty;
   fbandstart: integer;
   fbandgap: integer;
   fsizes: integerarty;
   frefsize: integer;
   fwidgetsbefore: widgetarty;
   fwidgetrectsbefore: rectarty;
   ftab_textflags: textflagsty;
   ftab_width: integer;
   ftab_widthmin: integer;
   ftab_widthmax: integer;
   fdefaultsplitdir: splitdirty;
   fchildren: stringarty;
   ffocusedchild: integer;
   fonbeforefloat: dockrecteventty;
   fcolortab: colorty;
   fcoloractivetab: colorty;
   ffacetab: tfacecomp;
   ffaceactivetab: tfacecomp;
   procedure updaterefsize;
   procedure setdockhandle(const avalue: tdockhandle);
   function checksplit(const awidgets: widgetarty;
                 out propsize,varsize,fixsize,fixcount: integer;
                 out isprop,isfix: booleanarty;
                 const fixedareprop: boolean): widgetarty; overload;
   function checksplit(out propsize,fixsize: integer;
                 out isprop,isfix: booleanarty;
                 const fixedareprop: boolean): widgetarty; overload;
   function checksplit: widgetarty; overload;
   procedure setcaption(const Value: msestring);
   procedure setsplitter_size(const Value: integer);
   procedure setsplitter_setgrip(const Value: stockbitmapty);
   procedure setsplitter_color(const Value: colorty);
   procedure setsplitter_colorgrip(const Value: colorty);
   procedure splitterchanged;
   procedure updategrip(const asplitdir: splitdirty; const awidget: twidget);
   procedure setuseroptions(const avalue: optionsdockty);
   function placementrect: rectty;
   procedure settab_options(const avalue: tabbaroptionsty);
   procedure settab_frame(const avalue: tframecomp);
   procedure settab_face(const avalue: tfacecomp);
   procedure settab_color(const avalue: colorty);
   procedure settab_colortab(const avalue: colorty);
   procedure settab_coloractivetab(const avalue: colorty);
   procedure settab_facetab(const avalue: tfacecomp);
   procedure settab_faceactivetab(const avalue: tfacecomp);
   procedure settab_size(const avalue: integer);
   procedure settab_sizemin(const avalue: integer);
   procedure settab_sizemax(const avalue: integer);
   procedure setbandgap(const avalue: integer);

   procedure settab_textflags(const avalue: textflagsty);
   procedure settab_width(const avalue: integer);
   procedure settab_widthmin(const avalue: integer);
   procedure settab_widthmax(const avalue: integer);
   procedure setsplitdir(const avalue: splitdirty);
   procedure setcurrentsplitdir(const avalue: splitdirty);
   function getdockrect: rectty;
   procedure settab_frametab(const avalue: tframecomp);
   function getactivetabpage: ttabpage;
   procedure setcolortab(const avalue: colorty);
   procedure setcoloractivetab(const avalue: colorty);
   procedure setfacetab(const avalue: tfacecomp);
   procedure setfaceactivetab(const avalue: tfacecomp);
  protected
   foptionsdock: optionsdockty;
   fr: prectaccessty;
   fw: pwidgetaccessty;
   fplacing: integer;
   fclickedbutton: dockbuttonrectty;
   fwidgetstate: widgetstatesty;

   procedure checkdirection;
   procedure objectevent(const sender: tobject;
                                      const event: objecteventty) override;
   function checkclickstate(const info: mouseeventinfoty): boolean override;
   procedure dokeypress(const sender: twidget; var info: keyeventinfoty)
                                                                     override;

   procedure drawxorpic(const ashow: boolean; var canvas1: tcanvas);
   procedure endmouseop1();
   procedure endmouseop2();
   procedure cancelsizing();

   function doclose(const awidget: twidget): boolean;
   procedure setmdistate(const avalue: mdistatety); virtual;
   procedure domdistatechanged(const oldstate,newstate: mdistatety); virtual;
   function dofloat(const adist: pointty): boolean; virtual;
   function dodock(const oldparent: tdockcontroller): boolean; virtual;
   procedure dochilddock(const awidget: twidget); virtual;
   procedure dochildfloat(const awidget: twidget); virtual;
   function docheckdock(const info: draginfoty): boolean; virtual;
   function dockdrag(const dragobj: tdockdragobject): boolean;
   procedure childstatechanged(const sender: twidget;
                         const newstate,oldstate: widgetstatesty); virtual;

   property useroptions: optionsdockty read fuseroptions write setuseroptions
                     default defaultoptionsdock;

   function nogrip: boolean;
   function canfloat: boolean;
   procedure refused(const apos: pointty);
   function calclayout(const dragobject: tdockdragobject;
                      const nonewplace: boolean): boolean; //false if canceled
   procedure setpickshape(const ashape: cursorshapety);
   procedure restorepickshape;
   function checkbuttonarea(const apos: pointty): dockbuttonrectty;
   procedure updatesplitterrects(const awidgets: widgetarty);
   procedure checksplitdir(var asplitdir: splitdirty);
   procedure setoptionsdock(const avalue: optionsdockty); virtual;
   function isfullarea: boolean;
   function istabed: boolean;
   function ismdi: boolean;
   function isfloating: boolean;
   function canmdisize: boolean;
   procedure dolayoutchanged; virtual;
   procedure doboundschanged;
   procedure docaptionchanged;
   function findbandpos(const apos: integer; out aindex: integer;
                                     out arect: rectty): boolean;
             //false if not found, band index and band rect
   function findbandwidget(const apos: pointty; out aindex: integer;
                                     out arect: rectty): boolean;
             //false if not found. widget index and widget rect
   function findbandindex(const widgetindex: integer; out aindex: integer;
                                     out arect: rectty): boolean;
   function nofit: boolean;
   function writechild(const index: integer): msestring;
   procedure readchildrencount(const acount: integer);
   procedure readchild(const index: integer; const avalue: msestring);
   procedure receiveevent(const aevent: tobjectevent); override;
   function canbegindrag: boolean; override;
   procedure dostatplace(const aparent: twidget;
                              const avisible: boolean; arect: rectty); virtual;
   procedure updatetabpage(const sender: ttabpage);
  public
   constructor create(aintf: idockcontroller);
   destructor destroy; override;

   function beforedragevent(var info: draginfoty): boolean; override;
   procedure enddrag; override;
   procedure mouseevent(var info: mouseeventinfoty); override;
   procedure clientmouseevent(var info: mouseeventinfoty); override;
   procedure childormouseevent(const sender: twidget;
                                     var info: mouseeventinfoty); override;
   procedure checkmouseactivate(const sender: twidget;
                                      var info: mouseeventinfoty);
   procedure dopaint(const acanvas: tcanvas);
                                       //canvasorigin = container.clientpos;
   procedure doactivate;
   procedure sizechanged(force: boolean = false;
            scalefixedalso: boolean = false; const awidgets: widgetarty = nil);
   procedure parentchanged(const sender: twidget);
   procedure poschanged;
   procedure statechanged(const astate: widgetstatesty); virtual;
   procedure widgetregionchanged(const sender: twidget);
   procedure updateminscrollsize(var asize: sizety);
   procedure beginclientrectchanged;
   procedure endclientrectchanged;
   procedure beginplacement();
   procedure endplacement();
   procedure layoutchanged; //force layout calcualation
    //istatfile
   procedure dostatread(const reader: tstatreader);
   procedure dostatwrite(const writer: tstatwriter;
                                  const bounds: prectty = nil);
   procedure statreading;
   procedure statread;
   function getdockcaption: msestring;
   function getfloatcaption: msestring;
   function getitems: widgetarty; //reference count = 1
   function getwidget: twidget;
   function activewidget: twidget; //focused child
   property tabwidget: ttabwidget read ftabwidget; //can be nil
   property activetabpage: ttabpage read getactivetabpage;

   function getparentcontroller(
                     out acontroller: tdockcontroller): boolean; overload;
   function getparentcontroller: tdockcontroller; overload;
   function dockparentname(): string; //'' if none
   function childicon(): tmaskedbitmap virtual;

   property mdistate: mdistatety read fmdistate write setmdistate;
   property currentsplitdir: splitdirty read fsplitdir
                                              write setcurrentsplitdir;
   property dockrect: rectty read getdockrect;
                             //origin = getwidget.container.pos
   function close: boolean; //simulates mr_windowclosed for owner
   function closeactivewidget: boolean;
                   //simulates mr_windowclosed for active widget, true if ok
   function float(): boolean; //false if canceled
   function dockto(const dest: tdockcontroller; const apos: pointty): boolean;
   procedure dock(const source: tdockcontroller; const arect: rectty);
        //simulates dostatread, use in beginplacement()/endplacement()
  published
   property dockhandle: tdockhandle read fdockhandle write setdockhandle;
   property splitter_size: integer read fsplitter_size
                            write setsplitter_size default defaultsplittersize;
   property splitter_grip: stockbitmapty read fsplitter_grip
                        write setsplitter_setgrip default defaultsplittergrip;
   property splitter_color: colorty read fsplitter_color
                        write setsplitter_color default defaultsplittercolor;
   property splitter_colorgrip: colorty read fsplitter_colorgrip
                  write setsplitter_colorgrip default defaultsplittercolorgrip;
   property tab_options: tabbaroptionsty read ftab_options write settab_options
                                   default defaulttaboptions;
   property tab_textflags: textflagsty read ftab_textflags write
                          settab_textflags default defaultcaptiontextflags;
   property tab_width: integer read ftab_width write settab_width default 0;
   property tab_widthmin: integer read ftab_widthmin
                                               write settab_widthmin default 0;
   property tab_widthmax: integer read ftab_widthmax
                                               write settab_widthmax default 0;

   property tab_frame: tframecomp read ftab_frame write settab_frame;
   property tab_face: tfacecomp read ftab_face write settab_face;
   property tab_color: colorty read ftab_color write settab_color
                                               default cl_default;
   property tab_colortab: colorty read ftab_colortab
                        write settab_colortab default cl_transparent;
   property tab_coloractivetab: colorty read ftab_coloractivetab
                        write settab_coloractivetab default cl_active;
   property tab_frametab: tframecomp read ftab_frametab write settab_frametab;
   property tab_facetab: tfacecomp read ftab_facetab write settab_facetab;
   property tab_faceactivetab: tfacecomp read ftab_faceactivetab
                                                 write settab_faceactivetab;
   property tab_size: integer read ftab_size write settab_size default 0;
   property tab_sizemin: integer read ftab_sizemin write settab_sizemin
                            default defaulttabsizemin;
   property tab_sizemax: integer read ftab_sizemax write settab_sizemax
                            default defaulttabsizemax;
   property colortab: colorty read fcolortab
                                     write setcolortab default cl_default;
   property coloractivetab: colorty read fcoloractivetab
                                     write setcoloractivetab default cl_default;
   property facetab: tfacecomp read ffacetab write setfacetab;
   property faceactivetab: tfacecomp read ffaceactivetab write setfaceactivetab;
   property caption: msestring read fcaption write setcaption;
   property splitdir: splitdirty read fdefaultsplitdir write setsplitdir
                      default sd_none; //sets default and current splitdir,
                                       //returns default
   property optionsdock: optionsdockty read foptionsdock write setoptionsdock
                      default defaultoptionsdock;
   property bandgap: integer read fbandgap write setbandgap default 0;

   property oncalclayout: docklayouteventty read foncalclayout
                                                          write foncalclayout;
   property onlayoutchanged: dockcontrollereventty read fonlayoutchanged
                                                       write fonlayoutchanged;
   property onboundschanged: dockcontrollereventty read fonboundschanged
                                                       write fonboundschanged;
   property oncaptionchanged: dockcontrollereventty read foncaptionchanged
                                                       write foncaptionchanged;
   property onbeforefloat: dockrecteventty read fonbeforefloat
                                                     write fonbeforefloat;
   property onfloat: notifyeventty read fonfloat write fonfloat;
   property ondock: notifyeventty read fondock write fondock;
   property onchilddock: widgeteventty read fonchilddock write fonchilddock;
   property onchildfloat: widgeteventty read fonchildfloat write fonchildfloat;
   property oncheckdock: checkdockeventty read foncheckdock write foncheckdock;
   property onmdistatechanged: mdistatechangedeventty read fonmdistatechanged
                              write fonmdistatechanged;
 end;

 tnochildrendockcontroller = class(tdockcontroller)
  public
   constructor create(aintf: idockcontroller);
  published
   property optionsdock default defaultoptionsdocknochildren;
 end;

 idocktarget = interface(inullinterface)[miid_idocktarget]
  function getdockcontroller: tdockcontroller;
 end;

type
 gripoptionty = (go_closebutton,go_minimizebutton,go_normalizebutton,
                 go_maximizebutton,
                 go_fixsizebutton,
                 go_floatbutton,go_topbutton,go_backgroundbutton,
                 go_lockbutton,go_nolockbutton,go_buttonframe,
                 go_buttonhints,
                 go_horz,go_vert,go_opposite,go_showsplitcaption,
                 go_showfloatcaption);
 gripoptionsty = set of gripoptionty;

const
 defaultgripoptions = [go_closebutton,go_buttonhints];
 defaultdockpaneloptionswidget = defaultoptionswidget + [ow_subfocus];
 defaulttextflagstop = [tf_ycentered,tf_clipo];
 defaulttextflagsleft = [tf_ycentered,tf_rotate90,tf_clipo];
 defaulttextflagsbottom = [tf_ycentered,tf_clipo];
 defaulttextflagsright = [tf_ycentered,tf_rotate90,tf_clipo];

type
 gripstatety = (grps_sizevalid);
 gripstatesty = set of gripstatety;

 tgripframe = class(tcaptionframe,iobjectpicker,iface)
  private
   fgrip_pos: captionposty;
   fgrip_color: colorty;
   fgrip_size: integer;
   fgrip_grip: stockbitmapty;
   fgrip_options: gripoptionsty;
   fgrip_colorglyph: colorty;
   fcontroller: tdockcontroller;
   fgrip_coloractive: colorty;
   fobjectpicker: tobjectpicker;
   fgrip_colorbutton: colorty;
   fgrip_colorbuttonactive: colorty;
   fgrip_colorglyphactive: colorty;
   fgrip_face: tface;
   fgrip_faceactive: tface;
   fgrip_textflagstop: textflagsty;
   fgrip_textflagsleft: textflagsty;
   fgrip_textflagsbottom: textflagsty;
   fgrip_textflagsright: textflagsty;
   fgrip_captiondist: integer;
   fgrip_captionoffset: integer;
   fgrip_hint: msestring;
   procedure setgrip_color(const avalue: colorty);
   procedure setgrip_grip(const avalue: stockbitmapty);
   procedure setgrip_size(const avalue: integer);
   procedure setgrip_options(avalue: gripoptionsty);
   procedure setgrip_colorglyph(const avalue: colorty);
   function getbuttonrects(const index: dockbuttonrectty): rectty;
   procedure setgrip_coloractive(const avalue: colorty);
   procedure setgrip_colorbutton(const avalue: colorty);
   procedure setgrip_colorbuttonactive(const avalue: colorty);
   procedure setgrip_colorglyphactive(const avalue: colorty);
   function getgrip_face: tface;
   procedure setgrip_face(const avalue: tface);
   function getgrip_faceactive: tface;
   procedure setgrip_faceactive(const avalue: tface);
   procedure setgrip_textflagstop(const avalue: textflagsty);
   procedure setgrip_textflagsright(const avalue: textflagsty);
   procedure setgrip_textflagsbottom(const avalue: textflagsty);
   procedure setgrip_textflagsrright(const avalue: textflagsty);
   procedure setgrip_captiondist(const avalue: integer);
   procedure setgrip_captionoffset(const avalue: integer);
  protected
   frects: array[dbr_first..dbr_last] of rectty;
   fedges: array[dbr_first..dbr_last] of edgesty;
   fgriprect: rectty;
   fgripstate: gripstatesty;
   factgripsize: integer;
   fmousebutton: dockbuttonrectty;
   procedure checkgripsize;
   procedure updatewidgetstate; override;
   procedure updaterects; override;
   procedure updatestate; override;
   procedure getpaintframe(var frame: framety); override;
   function ishintarea(const apos: pointty; var aid: int32): boolean; override;
   function calcsizingrect(const akind: sizingkindty;
                                const offset: pointty): rectty;
   procedure drawgripbutton(const acanvas: tcanvas;
                    const akind: dockbuttonrectty; const arect: rectty;
                    const acolorglyph,acolorbutton: colorty;
                    const ahiddenedges: edgesty); virtual;

    //iface
   function getclientrect: rectty;
   procedure invalidatewidget();
   procedure invalidaterect(const rect: rectty;
              const org: originty = org_client; const noclip: boolean = false);
   function translatecolor(const acolor: colorty): colorty;
   procedure setlinkedvar(const source: tmsecomponent; var dest: tmsecomponent;
              const linkintf: iobjectlink = nil);
   function getcomponentstate: tcomponentstate;
   procedure widgetregioninvalid;
    //iobjectpicker
   function getwidget: twidget;
   function getcursorshape(const sender: tobjectpicker;
                              var shape: cursorshapety): boolean;
                                       //true if found
   procedure getpickobjects(const sender: tobjectpicker;
                                                  var objects: integerarty);
   procedure beginpickmove(const sender: tobjectpicker);
   procedure pickthumbtrack(const sender: tobjectpicker);
   procedure endpickmove(const sender: tobjectpicker);
   procedure cancelpickmove(const sender: tobjectpicker);
   procedure paintxorpic(const sender: tobjectpicker; const canvas: tcanvas);
   procedure internalpaintoverlay(const canvas: tcanvas;
                                        const arect: rectty) override;

  public
   constructor create(const aintf: icaptionframe;
                                     const acontroller: tdockcontroller);
   destructor destroy; override;
   procedure createface();
   procedure createfaceactive();

   procedure checktemplate(const sender: tobject) override;
   procedure showhint(const aid: int32; var info: hintinfoty); override;
   procedure updatemousestate(const sender: twidget;
                                  const info: mouseeventinfoty); override;
   procedure mouseevent(var info: mouseeventinfoty);
   property buttonrects[const index:  dockbuttonrectty]: rectty
                                                    read getbuttonrects;
                                                                //client origin
   function getminimizedsize(out apos: captionposty): sizety;
   function griprect: rectty; //origin = pos
  published
   property grip_size: integer read fgrip_size write setgrip_size stored true;
                                                          //for optionalclass
   property grip_textflagstop: textflagsty read fgrip_textflagstop
                     write setgrip_textflagstop default defaulttextflagstop;
   property grip_textflagsleft: textflagsty read fgrip_textflagsleft
                     write setgrip_textflagsright default defaulttextflagsleft;
   property grip_textflagsbottom: textflagsty read fgrip_textflagsbottom
                  write setgrip_textflagsbottom default defaulttextflagsbottom;
   property grip_textflagsright: textflagsty read fgrip_textflagsright
                    write setgrip_textflagsrright default defaulttextflagsright;
   property grip_captiondist: integer read fgrip_captiondist
                                      write setgrip_captiondist default 1;
   property grip_captionoffset: integer read fgrip_captionoffset
                                      write setgrip_captionoffset default 0;
   property grip_grip: stockbitmapty read fgrip_grip write setgrip_grip
                                                       default defaultgripgrip;
   property grip_color: colorty read fgrip_color write setgrip_color
                                                       default defaultgripcolor;
   property grip_coloractive: colorty read fgrip_coloractive
                      write setgrip_coloractive default defaultgripcoloractive;
   property grip_colorglyph: colorty read fgrip_colorglyph write
                 setgrip_colorglyph default cl_glyph;
   property grip_colorglyphactive: colorty read fgrip_colorglyphactive write
                 setgrip_colorglyphactive default cl_glyphactive;
   property grip_colorbutton: colorty read fgrip_colorbutton write
                 setgrip_colorbutton default cl_transparent;
   property grip_colorbuttonactive: colorty read fgrip_colorbuttonactive write
                 setgrip_colorbuttonactive default cl_transparent;
   property grip_options: gripoptionsty read fgrip_options write setgrip_options
                                                     default defaultgripoptions;
   property grip_face: tface read getgrip_face write setgrip_face;
   property grip_faceactive: tface read getgrip_faceactive
                                            write setgrip_faceactive;
   property grip_hint: msestring read fgrip_hint write fgrip_hint;
 end;

 tdockpanel = class(tscalingwidget,idockcontroller,idocktarget,istatfile)
  private
   fdragdock: tnochildrendockcontroller;
   foptionswindow: windowoptionsty;
   fstatfile: tstatfile;
   fstatvarname: msestring;
   ficon: tmaskedbitmap;
   fstatpriority: integer;
   fdockingareacaption: msestring;
   procedure setdragdock(const Value: tnochildrendockcontroller);
   function getframe: tgripframe;
   procedure setframe(const Value: tgripframe);
   procedure setstatfile(const Value: tstatfile);
   procedure seticon(const avalue: tmaskedbitmap);
   procedure iconchanged(const sender: tobject);
   procedure setdockingareacaption(const avalue: msestring);
  protected
//   procedure mouseevent(var info: mouseeventinfoty); override;
   procedure childmouseevent(const sender: twidget;
                          var info: mouseeventinfoty); override;
   procedure updatewindowinfo(var info: windowinfoty); override;
   procedure internalcreateframe; override;
   procedure clientrectchanged; override;
   procedure widgetregionchanged(const sender: twidget); override;
   procedure setparentwidget(const Value: twidget); override;
   procedure dopaintforeground(const acanvas: tcanvas); override;
   procedure doactivate; override;
   procedure statechanged; override;
   procedure poschanged; override;
   procedure parentchanged; override;
   function calcminscrollsize: sizety; override;
   procedure dopaintbackground(const canvas: tcanvas); override;
    //idockcontroller
   function checkdock(var info: draginfoty): boolean;
   function getbuttonrects(const index: dockbuttonrectty): rectty;
   function getplacementrect: rectty;
   function getminimizedsize(out apos: captionposty): sizety;
   function getcaption: msestring;
   function getchildicon: tmaskedbitmap;
   procedure dolayoutchanged(const sender: tdockcontroller); virtual;
   procedure dodockcaptionchanged(const sender: tdockcontroller); virtual;
    //istatfile
   procedure dostatread(const reader: tstatreader);
   procedure dostatwrite(const writer: tstatwriter);
   procedure statreading;
   procedure statread;
   function getstatvarname: msestring;
   function getstatpriority: integer;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure dragevent(var info: draginfoty); override;
   function getdockcontroller: tdockcontroller;
  published
   property dragdock: tnochildrendockcontroller read fdragdock write setdragdock;
   property optionswidget default defaultdockpaneloptionswidget;
   property optionswindow: windowoptionsty read foptionswindow
                                               write foptionswindow default [];
   property frame: tgripframe read getframe write setframe;
   property statfile: tstatfile read fstatfile write setstatfile;
   property statvarname: msestring read fstatvarname write fstatvarname;
   property statpriority: integer read fstatpriority
                                       write fstatpriority default 0;
   property icon: tmaskedbitmap read ficon write seticon;
   property dockingareacaption: msestring read fdockingareacaption
                                                   write setdockingareacaption;
 end;

procedure paintdockingareacaption(const canvas: tcanvas; const sender: twidget;
                             const atext: msestring = 'Docking Area');

implementation
uses
 msearrayutils,sysutils,msebits,{msetabs,}mseguiintf,{mseforms,}msestream,

 mseformatstr,msekeyboard;
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
 twindow1 = class(twindow);
 tcustomframe1 = class(tcustomframe);
 tcustomtabwidget1 = class(tcustomtabwidget);
 tface1 = class(tface);
 ttabwidget1 = class(ttabwidget);

const
 useroptionsmask: optionsdockty = [od_fixsize,od_top,od_background,
                                                          od_lock,od_nolock];

type
 tchildorderevent = class(tobjectevent)
  protected
   fchildren: stringarty;
   ffocusedchild: integer;
  public
   constructor create(const sender: tdockcontroller);
 end;

 tdocktabwidget = class(ttabwidget)
  private
   fcontroller: tdockcontroller;
  protected
   procedure doclosepage(const sender: tobject); override;
   procedure dopageremoved(const apage: twidget);  override;
   procedure tabchanged(const synctabindex: boolean); override;
   procedure updateoptions;
  public
   constructor create(const acontroller: tdockcontroller;
                                         const aparent: twidget); reintroduce;
   destructor destroy; override;
 end;

 tdocktabpage = class(ttabpage,idocktarget)
  private
   fcontroller: tdockcontroller;
   ftarget: twidget;
   ftargetanchors: anchorsty;
   //idocktarget
   function getdockcontroller: tdockcontroller;
  protected
   procedure unregisterchildwidget(const child: twidget); override;
   procedure widgetregionchanged(const sender: twidget); override;
  public
   constructor create(const atabwidget: tdocktabwidget; const awidget: twidget);
              reintroduce;
   destructor destroy(); override;
 end;

procedure paintdockingareacaption(const canvas: tcanvas; const sender: twidget;
                             const atext: msestring = 'Docking Area');
begin
 if sender.visiblechildrencount = 0 then begin
  canvas.save;
  canvas.font.height:= 20;
  drawtext(canvas,atext,sender.paintclientrect(),
                                       [tf_xcentered,tf_ycentered,tf_grayed]);
  canvas.restore;
 end;
end;

{ twidgetdragobject }

constructor twidgetdragobject.create(const asender: twidget;
                           var instance: tdragobject; const apickpos: pointty);
begin
 inherited create(asender,instance,apickpos);
end;

function twidgetdragobject.getwidget: twidget;
begin
 result:= twidget(fsender);
end;

{ tdockdragobject }

constructor tdockdragobject.create(const adock: tdockcontroller;
            const asender: twidget; var instance: tdragobject;
            const apickpos: pointty);
begin
 fdock:= adock;
 inherited create(asender,instance,apickpos);
end;

destructor tdockdragobject.destroy;
begin
 if fcheckeddockcontroller <> nil then begin
  fcheckeddockcontroller.fasplitdir:= sd_none;
 end;
 inherited;
end;

procedure tdockdragobject.drawxorpic;
begin
 if fxorwidget <> nil then begin
  with fxorwidget.getcanvas(org_screen) do begin
   drawxorframe(fxorrect,-3,stockobjects.bitmaps[stb_dens50]);
  end;
 end;
end;

procedure tdockdragobject.refused(const apos: pointty);
begin
 inherited;
 drawxorpic;
 fxorwidget:= nil;
 fdock.refused(apos);
end;

procedure tdockdragobject.setxorwidget(const awidget: twidget;
                                                    const screenrect: rectty);
begin
 if (awidget <> fxorwidget) or not rectisequal(fxorrect,screenrect) then begin
  drawxorpic;
  fxorwidget:= awidget;
  fxorrect:= screenrect;
  drawxorpic;
 end;
end;

{ tdocktabwidget }

constructor tdocktabwidget.create(const acontroller: tdockcontroller;
                     const aparent: twidget);
begin
 fcontroller:= acontroller;
 inherited create(nil);
 parentwidget:= aparent;
 updateoptions;
 synctofontheight;
end;

procedure tdocktabwidget.updateoptions;
begin
 with fcontroller do begin
  self.tab_options:= ftab_options;
  self.tab_color:= ftab_color;
  self.tab_colortab:= ftab_colortab;
  self.tab_coloractivetab:= ftab_coloractivetab;
  self.tab_size:= ftab_size;
  self.tab_sizemin:= ftab_sizemin;
  self.tab_sizemax:= ftab_sizemax;
  self.tab_textflags:= ftab_textflags;
  self.tab_width:= ftab_width;
  self.tab_widthmin:= ftab_widthmin;
  self.tab_widthmax:= ftab_widthmax;
  if ftab_frame <> nil then begin
   self.tab_frame:= tstepboxframe1(1);
   self.tab_frame.assign(ftab_frame);
  end
  else begin
   self.tab_frame:= nil;
  end;
  if ftab_face <> nil then begin
   self.tab_face:= tface(1);
   self.tab_face.assign(ftab_face);
  end
  else begin
   self.tab_face:= nil;
  end;
  if ftab_frametab <> nil then begin
   self.tab_frametab:= ttabframe(1);
   self.tab_frametab.assign(ftab_frametab);
  end
  else begin
   self.tab_frametab:= nil;
  end;
  if ftab_facetab <> nil then begin
   self.tab_facetab:= tface(1);
   self.tab_facetab.assign(ftab_facetab);
  end
  else begin
   self.tab_facetab:= nil;
  end;
  if ftab_faceactivetab <> nil then begin
   self.tab_faceactivetab:= tface(1);
   self.tab_faceactivetab.assign(ftab_faceactivetab);
  end
  else begin
   self.tab_faceactivetab:= nil;
  end;
 end;
end;

destructor tdocktabwidget.destroy;
begin
 if fcontroller.ftabwidget = self then begin
  fcontroller.ftabwidget:= nil;
 end;
 inherited;
end;

procedure tdocktabwidget.doclosepage(const sender: tobject);
begin
 fcontroller.doclose(tdocktabpage(items[fpopuptab]).ftarget);
end;

procedure tdocktabwidget.dopageremoved(const apage: twidget);
begin
 inherited;
 if (count = 0) and not application.terminated then begin
  fcontroller.ftabwidget:= nil;
  fcontroller.fsplitterrects:= nil;
  release;
 end;
 fcontroller.dolayoutchanged();
end;

procedure tdocktabwidget.tabchanged(const synctabindex: boolean);
begin
 inherited;
 if fcontroller.fintf.getwidget.componentstate *
                               [csloading,csdestroying] = [] then begin
  fcontroller.dolayoutchanged();
 end;
end;

{ tdocktabpage }

constructor tdocktabpage.create(const atabwidget: tdocktabwidget;
                        const awidget: twidget);
var
 intf1: idocktarget;
begin
 fcontroller:= atabwidget.fcontroller;
 inherited create(nil);
 optionswidget:= optionswidget - [ow_destroywidgets];
 ftarget:= awidget;
 ftargetanchors:= awidget.anchors;
 if awidget.getcorbainterface(typeinfo(idocktarget),intf1) then begin
  intf1.getdockcontroller.updatetabpage(self);
//  caption:= intf1.getdockcontroller.getdockcaption;

 end
 else begin
  caption:= 'Page '+inttostrmse(atabwidget.count);
 end;
 awidget.anchors:= [];
 parentwidget:= atabwidget;
 insertwidget(awidget,paintpos);
end;

destructor tdocktabpage.destroy();
begin
 fcontroller.ftabpage:= nil;
 inherited;
end;

procedure tdocktabpage.unregisterchildwidget(const child: twidget);
begin
 inherited;
 if (child = ftarget) then begin
//  ftarget:= nil;
  child.anchors:= ftargetanchors;
  if not application.terminated then begin
   visible:= false;
   parentwidget:= nil;
   release;
  end;
 end;
end;

procedure tdocktabpage.widgetregionchanged(const sender: twidget);
var
 focusedwidgetbefore: twidget;
begin
 inherited;
 if (sender <> nil) and (sender = ftarget) and not sender.visible and
  (fparentwidget <> nil) and (fparentwidget.parentwidget <> nil) and
            not (csdestroying in sender.componentstate) then begin
   optionswidget:= optionswidget - [ow_tabfocus]; //don't accept focus
   focusedwidgetbefore:= nil;
   if entered then begin
    setlinkedvar(window.focusedwidget,tmsecomponent(focusedwidgetbefore));
   end;
   try
    sender.parentwidget:= fparentwidget.parentwidget;  //remove page
    if (focusedwidgetbefore <> nil) and (window.focusedwidget = nil) then begin
     focusedwidgetbefore.parentfocus; //restore focus
    end;
   finally
    setlinkedvar(nil,tmsecomponent(focusedwidgetbefore));
   end;
 end;
end;

function tdocktabpage.getdockcontroller: tdockcontroller;
begin
 result:= fcontroller;
end;

{ tdockcontroller }

constructor tdockcontroller.create(aintf: idockcontroller);
begin
 fr:= @rectaccessx;
 fw:= @widgetaccessx;
 fsizeindex:= -1;
 foptionsdock:= defaultoptionsdock;
 fuseroptions:= defaultoptionsdock;
 fsplitter_grip:= defaultsplittergrip;
 fsplitter_color:= defaultsplittercolor;
 fsplitter_colorgrip:= defaultsplittercolorgrip;
 fsplitter_size:= defaultsplittersize;
 ftab_options:= defaulttaboptions;
 ftab_color:= cl_default;
 ftab_colortab:= cl_transparent;
 ftab_coloractivetab:= cl_active;
 ftab_sizemin:= defaulttabsizemin;
 ftab_sizemax:= defaulttabsizemax;
 ftab_textflags:= defaultcaptiontextflags;
 fcolortab:= cl_default;
 fcoloractivetab:= cl_default;
 fmdistate:= mds_floating;
 inherited create(aintf);
end;

destructor tdockcontroller.destroy;
begin
 freeandnil(ftabwidget);
 inherited;
end;

function tdockcontroller.checksplit(const awidgets: widgetarty;
              out propsize,varsize,fixsize,fixcount: integer;
              out isprop,isfix: booleanarty;
              const fixedareprop: boolean): widgetarty;
                 //calculate order and total widths/heights of elements
var
 ar1: widgetarty;
 int1,int2,int3: integer;
 intf1: idocktarget;
 opt1: optionsdockty;
 fixend: boolean;
 banded: boolean;
// needspropref: boolean;
 dcont1: tdockcontroller;
 widget1: twidget;
 bo1: boolean;
begin
 checkdirection;
 banded:= (od_banded in foptionsdock) and (fsplitdir in [sd_vert,sd_horz]);
 if awidgets = nil then begin
  if (fsplitdir = sd_vert) then begin
   ar1:= fintf.getwidget.getsortxchildren(banded);
  end
  else begin
   if (fsplitdir = sd_horz) or (fsplitdir = sd_tabed) then begin
    ar1:= fintf.getwidget.getsortychildren(banded);
   end
   else begin
    ar1:= nil;
   end;
  end;
 end
 else begin
  if fsplitdir = sd_tabed then begin
   ar1:= nil;
  end
  else begin
   ar1:= awidgets;
  end;
 end;
 setlength(result,length(ar1));
 setlength(isprop,length(ar1));
 setlength(isfix,length(ar1));
 int2:= 0;
 propsize:= 0;
 varsize:= 0;
 fixsize:= 0;
 fixcount:= 0;
 fixend:= foptionsdock * [od_nofit] <> [];
// needspropref:= false;
 for int1:= 0 to high(ar1) do begin
  widget1:= ar1[int1];
  with twidget1(widget1) do begin
   include(fwidgetstate1,ws1_nominsize);
   if not (ow1_noautosizing in foptionswidget1) then begin
    if visible then begin
     result[int2]:= ar1[int1];
     if fixend then begin
      isfix[int2]:= true;
      inc(fixcount);
     end
     else begin
      if ar1[int1].getcorbainterface(typeinfo(idocktarget),intf1) then begin
       dcont1:= intf1.getdockcontroller;
       if dcont1.fmdistate = mds_floating then begin
        dcont1.fmdistate:= mds_normal; //placed by setparent
       end;
       opt1:= dcont1.foptionsdock;
//       needspropref:= needspropref or not (dos_proprefvalid in dcont1.fdockstate);
       dcont1.fdockstate:= dcont1.fdockstate + [{dos_proprefvalid,}dos_showed];
       bo1:= false;
       if dos_sizing in fdockstate then begin
        if fsplitdir in [sd_vert,sd_horz] then begin
         int3:= fr^.si(dcont1.fhiddensizeref);
         bo1:= int3 > 0; //widget is visible again, restore old size
         if bo1 and (opt1 * [od_propsize,od_fixsize] = [od_propsize]) then begin
          fw^.setsize(widget1,
               fw^.size(widget1)*fr^.si(fplacementrect.size) div int3);
                     //adjust to current container size
         end;
        end;
        dcont1.fhiddensizeref:= nullsize;
       end;
//       include(dcont1.fdockstate,dos_proprefvalid);
       if bo1 or not fixedareprop and (od_fixsize in opt1) then begin
        isfix[int2]:= true;
        inc(fixcount);
       end;
       if not bo1 and ((od_propsize in opt1) and not (od_fixsize in opt1) or
                              fixedareprop and (od_fixsize in opt1)) then begin
        isprop[int2]:= true;
        propsize:= propsize + fw^.size(ar1[int1]);
       end
      end;
     end;
     if not isprop[int2] then begin
      fixsize:= fixsize + fw^.size(ar1[int1]);
      if not isfix[int2] then begin
       varsize:= varsize + fw^.size(ar1[int1]);
      end;
     end;
     inc(int2);
    end
    else begin
     if ar1[int1].getcorbainterface(typeinfo(idocktarget),intf1) then begin
      dcont1:= intf1.getdockcontroller;
      if dcont1.fmdistate = mds_floating then begin
       dcont1.fmdistate:= mds_normal; //placed by setparent
      end;
      if dos_showed in dcont1.fdockstate then begin
       exclude(dcont1.fdockstate,dos_showed);
       if not (dos_updating4 in dcont1.fdockstate) then begin //no statreading
        dcont1.fhiddensizeref:= fplacementrect.size;
       end;
      end;
     end;
    end;
   end;
  end;
 end;
// if needspropref then begin
//  updaterefsize;
// end;
 setlength(result,int2);
 setlength(isprop,int2);
 setlength(isfix,int2);
 if (awidgets = nil) and not banded and (fsplitdir in [sd_vert,sd_horz]) and
       (high(result) > 0) and (fw^.pos(result[0]) = fw^.pos(result[1])) and
       (finditem(pointerarty(fwidgetsbefore),pointer(result[1])) < 0) then begin
  widget1:= result[0];        //probably revisible
  result[0]:= result[1];
  result[1]:= widget1;
  bo1:= isprop[0];
  isprop[0]:= isprop[1];
  isprop[1]:= bo1;
  bo1:= isfix[0];
  isfix[0]:= isfix[1];
  isfix[1]:= bo1;
 end;
 fwidgetsbefore:= result;
end;

function tdockcontroller.checksplit(out propsize,fixsize: integer;
                out isprop,isfix: booleanarty; const fixedareprop: boolean): widgetarty;
var
 int1,int2: integer;
begin
 result:= checksplit(nil,propsize,int1,fixsize,int2,isprop,isfix,fixedareprop);
end;

function tdockcontroller.checksplit: widgetarty;
var
 ar1,ar2: booleanarty;
 int1,int2,int3,int4: integer;
begin
 if ftabwidget <> nil then begin
  setlength(result,tdocktabwidget(ftabwidget).count);
  int2:= 0;
  for int1:= 0 to high(result) do begin
   result[int2]:= tdocktabpage(tdocktabwidget(ftabwidget)[int1]).ftarget;
   if result[int2] <> nil then begin
    inc(int2);
   end;
  end;
  setlength(result,int2);
 end
 else begin
  result:= checksplit(nil,int1,int2,int3,int4,ar1,ar2,false);
 end;
end;

procedure tdockcontroller.sizechanged(force: boolean = false;
                                          scalefixedalso: boolean = false;
                                          const awidgets: widgetarty = nil);
var
 ar1: widgetarty;
 ar2: realarty;
 prop,fix: booleanarty;
 fixsize: integer;
 propsize: integer;
 banded: boolean;
 opt1: optionsdockty;

 procedure calcsize;
 var
  int1: integer;
  rea1,rea2: real;
 begin
  int1:= fr^.size(fplacementrect) - high(ar1) * fsplitter_size - fixsize;
  if int1 < 0 then begin
   int1:= 0;
  end;
  if (frefsize > 0) and (high(ar1) = high(fsizes)) then begin
   rea1:= int1 / frefsize;
   for int1:= 0 to high(ar1) do begin
    if prop[int1] then begin
     ar2[int1]:= fsizes[int1] * rea1;
    end
    else begin
     ar2[int1]:= fw^.size(ar1[int1]);
    end;
   end;
  end
  else begin
   if (propsize = 0) then begin
    rea1:= 1;
   end
   else begin
    rea1:= int1/propsize;
   end;
   for int1:= 0 to high(ar1) do begin
    ar2[int1]:= fw^.size(ar1[int1]);
    if prop[int1] then begin
     ar2[int1]:= ar2[int1] * rea1;
    end;
   end;
  end;
  rea2:= 0;
  for int1:= 0 to high(ar2) do begin
   if (fw^.max(ar1[int1]) <> 0) and (ar2[int1] > fw^.max(ar1[int1])) then begin
    ar2[int1]:= fw^.max(ar1[int1]);
   end;
   if ar2[int1] < fw^.min(ar1[int1]) then begin
    ar2[int1]:= fw^.min(ar1[int1]);
   end;
   rea2:= rea2 + ar2[int1]; //total size
  end;
  rea1:= fr^.size(fplacementrect);
  if not nofit then begin
         //adjust sizes for fit
   rea2:= rea1 - (rea2 + high(ar2) * fsplitter_size);
               //delta
   if rea2 < 0 then begin
    for int1:= high(ar2) downto 0 do begin
     if not (fix[int1] and not scalefixedalso) and not prop[int1] then begin
      rea1:= fw^.min(ar1[int1]);
      ar2[int1]:= ar2[int1] + rea2;
      if ar2[int1] < rea1 then begin
       rea2:= ar2[int1] - rea1;
       ar2[int1]:= rea1;
      end
      else begin
       break;
      end;
     end;
    end;
   end
   else begin
    for int1:= high(ar2) downto 0 do begin
     if not fix[int1] and not prop[int1] then begin
      rea1:= fw^.max(ar1[int1]);
      ar2[int1]:= ar2[int1] + rea2;
      if (ar2[int1] > rea1) and (rea1 > 0) then begin
       rea2:= ar2[int1] - rea1;
       ar2[int1]:= rea1;
      end
      else begin
       break;
      end;
     end;
    end;
   end;
  end;
  rea2:= fr^.pos(fplacementrect);
  ar2[0]:= ar2[0] + rea2 + fsplitter_size;
  for int1:= 1 to high(ar1) do begin        //calc pos vector
   ar2[int1]:= ar2[int1-1] + fsplitter_size + ar2[int1];
  end;
 end; //calcsize

var
 minsize1: integer;

 procedure calcpos;
 var
  bandindex: integer;

  procedure calcbandheight(const aindex: integer);
  var
   int2,int3,int4: integer;
  begin
   setlength(fbands,high(fbands)+2);
   int3:= 0;
   for int2:= bandindex to aindex - 1 do begin
    int4:= fw^.osize(ar1[int2]);
    if int4 > int3 then begin
     int3:= int4;       //find biggest widget
    end;
   end;
   with fbands[high(fbands)] do begin
    first:= bandindex;
    last:= aindex-1;
    size:= int3;
   end;
   bandindex:= aindex;
  end; //calcbandheight

 var
  rea1,rea2: real;
  int1: integer;
  rect1: prectty;
  rect2: rectty;
  ar3: rectarty;
  int2: integer;
  bandpos: integer;

  procedure clipwidget;
  var
   int1: integer;
  begin
   int1:= fr^.stop(fplacementrect) - fsplitter_size;
   if fr^.stop(rect1^) > int1 then begin
    fr^.setstop(rect1^,int1);
   end;
  end; //clipwidget

 begin
  rea2:= fr^.pos(fplacementrect);
  if not nofit then begin
   setlength(fbands,1);
   with fbands[0] do begin
    first:= 0;
    last:= high(ar1);
    size:= fr^.osize(fplacementrect);
   end;
   rect2:= fplacementrect;
   for int1:= 0 to high(ar1) do begin
    fr^.setpos(rect2,round(rea2));
    fr^.setsize(rect2,round(ar2[int1] - rea2) - fsplitter_size);
    ar1[int1].widgetrect:= rect2;
    rea2:= rea2 + fw^.size(ar1[int1]) + fsplitter_size;
   end;
   minsize1:= fr^.stop(rect2) - fr^.pos(fplacementrect);
  end
  else begin
   setlength(ar3,length(ar1));
   bandindex:= 0;
   rea1:= 0;
   int2:= 0;
   for int1:= 0 to high(ar1) do begin
    rect1:= @ar3[int1];         //set size
    rect1^:= fplacementrect;
    fr^.setpos(rect1^,round(rea2));
    fr^.setsize(rect1^,round(ar2[int1] - rea2 - rea1) - fsplitter_size);
    if banded and
      (fr^.stop(rect1^) + fsplitter_size > fr^.stop(fplacementrect)) then begin
     if int1 > int2 then begin //next band
      calcbandheight(int1);
      int2:= int1;       // minimal one widget in band
      fr^.setpos(rect1^,fr^.pos(fplacementrect)); //restart
      clipwidget;
      rea1:= rea1 + rea2;
      rea2:= fr^.pos(rect1^);
      rea1:= rea1 - rea2;
     end
     else begin
      clipwidget;
     end;
    end;
    rea2:= rea2 + fr^.size(rect1^) + fsplitter_size;
   end;
   calcbandheight(length(ar1));
   if not banded then begin
    fbands[0].size:= fr^.osize(fplacementrect);
   end;
   bandpos:= fbandstart;
   for int2:= 0 to high(fbands) do begin
    with fbands[int2] do begin
     for int1:= first to last do begin
      rect1:= @ar3[int1];                      //set ortho size
      fr^.setosize(rect1^,fw^.osize(ar1[int1]));
      if opt1 = [od_aligncenter] then begin
       fr^.setopos(rect1^,
                bandpos + (size-fr^.osize(rect1^)) div 2);
      end
      else begin
       if opt1 = [od_alignend] then begin
        fr^.setopos(rect1^,bandpos + (size-fr^.osize(rect1^)));
       end
       else begin
        if opt1 = [od_alignbegin] then begin
         fr^.setopos(rect1^,bandpos);
        end
        else begin
         fr^.setopos(rect1^,bandpos + fr^.osize(rect1^));
        end;
       end;
      end;
      ar1[int1].widgetrect:= rect1^;
     end;
     bandpos:= bandpos + size + fbandgap;
    end;
   end;
  end;
 end; //calcpos

var
 needsfixscale: boolean;
 hasparent1: boolean;

 procedure updateplacement;
 var
  widget1: twidget;
  int1: integer;
 begin
  widget1:= fintf.getwidget;
  int1:= minsize1 - fr^.size(fplacementrect);
  if (int1 > 0) then begin       //extend placementrect
   if not scalefixedalso and
              not (od_expandforfixsize in foptionsdock) then begin
    needsfixscale:= true;
   end
   else begin
    if hasparent1 then begin
     fw^.setanchordsize(widget1,fw^.size(widget1)+int1); //extend size
     {
     if not fw^.anchstop(widget1) then begin
      fw^.setsize(widget1,fw^.size(widget1)+int1); //extend size
     end
     else begin
      if not fw^.anchboth(widget1) then begin //use setanchordsize?
       widget1.parentwidget.clientsize:=
           addsize(widget1.parentwidget.clientsize,fr^.makesize(int1,0));
              //not async
//      widget1.parentwidget.changeclientsize(fr^.makesize(int1,0));
      end;
     end;
     }
    end;
   end;
  end
  else begin
   if not nofit then begin
    fw^.setstop(ar1[high(ar1)],fr^.stop(fplacementrect));
   end;
  end;
 end;

var
 int1,int2: integer;
 widget1: twidget;
 widget2: twidget;

begin
 widget2:= fintf.getwidget;
 hasparent1:= widget2.parentwidget <> nil;
 widget1:= widget2.container;
 checkdirection;
 if (widget1 <> nil) and
        (widget1.ComponentState * [csloading,csdesigning] = []) then begin
  banded:= od_banded in foptionsdock;
  fplacementrect:= idockcontroller(fintf).getplacementrect;
  fbandstart:= fr^.opos(fplacementrect);
  if fsplitdir in [sd_vert,sd_horz] then begin
   ar1:= nil; //compiler warning
   if not sizeisequal(fsize,fplacementrect.size) or force then begin
    fbands:= nil;
    fsize:= fplacementrect.size;
    if fdockstate * [dos_updating1,dos_updating2,dos_updating4] <> [] then begin
     exclude(fdockstate,dos_layoutvalid);
    end
    else begin
     needsfixscale:= false;
     fdockstate:= fdockstate + [dos_layoutvalid,dos_updating2,dos_sizing];
     try
      inc(frecalclevel);
      ar1:= checksplit(awidgets,propsize,int1,fixsize,int2,prop,fix,false);
      if high(ar1) >= 0 then begin
       setlength(ar2,length(ar1));
       if not (od_proportional in foptionsdock) then begin
        for int1:= 0 to high(prop) do begin
         prop[int1]:= false;
        end;
       end;
       minsize1:= 0;
       opt1:= foptionsdock * [od_alignbegin,od_aligncenter,od_alignend];
       if fsplitdir in [sd_vert,sd_horz] then begin
        calcsize;
        calcpos;
       end;
       if (opt1 = []) and not nofit then begin
        updateplacement;
       end;
      end;
     finally
      fdockstate:= fdockstate - [dos_updating1,dos_updating2,dos_sizing];
      if (not (dos_layoutvalid in fdockstate) or needsfixscale) and
                        (frecalclevel < 4) then begin
       try
        sizechanged(force or needsfixscale,needsfixscale);
       finally
        dec(frecalclevel);
       end;
      end
      else begin
       dec(frecalclevel);
       updatesplitterrects(ar1);
      end;
     end;
    end;
   end;
  end
  else begin
   if (fsplitdir = sd_tabed) and (ws_loadedproc in widget1.widgetstate) and
          (awidgets = nil) then begin
    calclayout(nil,false);
   end;
   fbands:= nil;
   if ismdi then begin
    case fmdistate of
     mds_normal: begin
      fnormalrect:= widget2.widgetrect;
     end;
     else; // Added to make compiler happy
    end;
   end;
  end;
 end;
 doboundschanged;
end;

procedure tdockcontroller.dopaint(const acanvas: tcanvas); //canvasorigin = container.clientpos;
var
 int1: integer;
 color1: colorty;
 brush1: tsimplebitmap;
begin
 if fsplitterrects <> nil then begin
  if fsplitter_color <> cl_none then begin
   for int1:= 0 to high(fsplitterrects) do begin
    acanvas.fillrect(fsplitterrects[int1],fsplitter_color);
   end;
  end;
  if fsplitter_grip <> stb_none then begin
   with acanvas do begin
    color1:= color;
    brush1:= brush;
    brush:= stockobjects.bitmaps[fsplitter_grip];
    color:= fsplitter_colorgrip;
    for int1:= 0 to high(fsplitterrects) do begin
     fillrect(fsplitterrects[int1],cl_brushcanvas);
    end;
    brush:= brush1;
    color:= color1;
   end;
  end;
 end;
end;

procedure tdockcontroller.doactivate;
var
 size1: sizety;
 intf1: idocktarget;
 widget1: twidget;
begin
 size1:= fintf.getwidget.size;
 if (size1.cx <= 0) or (size1.cy <= 0) then begin
  widget1:= fintf.getwidget.parentwidget;
  if (widget1 <> nil) and widget1.getcorbainterface(typeinfo(idocktarget),intf1) then begin
   intf1.getdockcontroller.calclayout(nil,false);
  end;
 end;
end;

procedure tdockcontroller.updategrip(const asplitdir: splitdirty;
                       const awidget: twidget);
var
 frame1: tcustomframe;
 grippos1: captionposty;
begin
 frame1:= twidget1(awidget).fframe;
 if frame1 is tgripframe then begin
  with tgripframe(frame1) do begin
   grippos1:= fgrip_pos;
   if fgrip_options * [go_horz,go_vert] = [] then begin
    if asplitdir = sd_vert then begin
     if go_opposite in fgrip_options then begin
      fgrip_pos:= cp_bottom;
     end
     else begin
      fgrip_pos:= cp_top;
     end;
    end
    else begin
     if (asplitdir = sd_horz) or (asplitdir = sd_tabed) or
                                    (asplitdir = sd_none) then begin
      if go_opposite in fgrip_options then begin
       fgrip_pos:= cp_left;
      end
      else begin
       fgrip_pos:= cp_right;
      end;
     end;
    end;
   end;
   if grippos1 <> fgrip_pos then begin
    internalupdatestate;
   end;
  end;
 end;
end;

procedure tdockcontroller.updatesplitterrects(const awidgets: widgetarty);
var
 fixend: boolean;

 procedure calcsplitters;
 var
  rect1: rectty;
  int1,int2: integer;
  bandpos: integer;
 begin
  fr^.setsize(rect1,fsplitter_size);
  bandpos:= fbandstart;
  for int2:= 0 to high(fbands) do begin
   with fbands[int2] do begin
    fr^.setopos(rect1,bandpos);
    fr^.setosize(rect1,size);
    for int1:= first to last do begin
     fr^.setpos(rect1,fw^.stop(awidgets[int1]));
     fsplitterrects[int1]:= rect1;
    end;
    bandpos:= bandpos + size + fbandgap;
   end;
  end;
 end;

var
 po1: pointty;
 int1: integer;
 sd1: splitdirty;
begin
 sd1:= fsplitdir;
 if nofit then begin
  if sd1 = sd_vert then begin
   sd1:= sd_horz;
  end
  else begin
   sd1:= sd_vert;
  end;
 end;
 for int1:= 0 to high(awidgets) do begin
  updategrip(sd1,awidgets[int1]);
 end;
 if (high(awidgets) >= 0) and (fsplitter_size > 0) and
     ((fsplitter_color <> cl_none) or (fsplitter_grip <> stb_none)) then begin
  fixend:= foptionsdock * [od_nofit] <> [];
  setlength(fsplitterrects,length(awidgets));
  calcsplitters;
  if not fixend then begin
   setlength(fsplitterrects,high(fsplitterrects));
  end;
  po1:= fintf.getwidget.container.clientwidgetpos;
  for int1:= 0 to high(fsplitterrects) do begin
   subpoint1(fsplitterrects[int1].pos,po1); //clientorg
  end;
 end
 else begin
  fsplitterrects:= nil;
 end;
 fintf.getwidget.container.invalidate;
end;

procedure tdockcontroller.checksplitdir(var asplitdir: splitdirty);
begin
 if asplitdir = sd_none then begin
  asplitdir:= fdefaultsplitdir;
 end;
 if not (od_splitvert in foptionsdock) and (asplitdir = sd_vert) then begin
  asplitdir:= sd_none;
 end;
 if not (od_splithorz in foptionsdock) and (asplitdir = sd_horz) then begin
  asplitdir:= sd_none;
 end;
 if not (od_tabed in foptionsdock) and (asplitdir = sd_tabed) then begin
  asplitdir:= sd_none;
 end;
 if (asplitdir = sd_none) then begin
  if od_splithorz in foptionsdock then begin
   asplitdir:= sd_horz;
  end
  else begin
   if od_splitvert in foptionsdock then begin
    asplitdir:= sd_vert;
   end
   else begin
    if od_tabed in foptionsdock then begin
     asplitdir:= sd_tabed;
    end;
   end;
  end;
 end;
end;

procedure tdockcontroller.setoptionsdock(const avalue: optionsdockty);
const
 mask1: optionsdockty = [od_top,od_background];
 mask2: optionsdockty = [od_alignbegin,od_aligncenter,od_alignend];

var
 splitdirbefore: splitdirty;
 intf1: idocktarget;
 cont1: tdockcontroller;
 int1: integer;
 val1,val2{,val3}: optionsdockty;
 bo1: boolean;
 optbefore: optionsdockty;
begin
 if foptionsdock <> avalue then begin
  optbefore:= foptionsdock;
  bo1:= od_fixsize in foptionsdock;
  splitdirbefore:= fsplitdir;
  val1:= optionsdockty(
       setsinglebit({$ifdef FPC}longword{$else}longword{$endif}(avalue),
       {$ifdef FPC}longword{$else}longword{$endif}(foptionsdock),
                          {$ifdef FPC}longword{$else}longword{$endif}(mask1)));
  val2:= optionsdockty(
       setsinglebit({$ifdef FPC}longword{$else}longword{$endif}(avalue),
       {$ifdef FPC}longword{$else}longword{$endif}(foptionsdock),
                          {$ifdef FPC}longword{$else}longword{$endif}(mask2)));
  foptionsdock:= ((avalue - (mask1+mask2)) + val1*mask1 + val2*mask2) -
                                                      deprecatedoptionsdock;
  if not (od_nofit in foptionsdock) then begin
   if not (od_banded in optbefore) and (od_banded in foptionsdock) then begin
    include(foptionsdock,od_nofit);
   end
   else begin
    exclude(foptionsdock,od_banded);
   end;
  end;
  if (od_banded in foptionsdock) and (foptionsdock * mask2 = []) then begin
   include(foptionsdock,od_aligncenter);
  end;
  {
  if bo1 xor (od_fixsize in foptionsdock) then begin
   exclude(fdockstate,dos_proprefvalid);
  end;
  }
  fuseroptions:= foptionsdock;
  checksplitdir(fsplitdir);
  with fintf.getwidget do begin
   if od_top in foptionsdock then begin
    optionswidget:= optionswidget + [ow_top];
   end
   else begin
    optionswidget:= optionswidget - [ow_top];
   end;
   if od_background in foptionsdock then begin
    optionswidget:= optionswidget + [ow_background];
   end
   else begin
    optionswidget:= optionswidget - [ow_background];
   end;
   if not (csloading in componentstate) then begin
    if (splitdirbefore <> fsplitdir) then begin
     calclayout(nil,false);
     with container do begin
      if fsplitdir = sd_none then begin
       for int1:= 0 to widgetcount - 1 do begin
        with widgets[int1] do begin
         if getcorbainterface(typeinfo(idocktarget),intf1) then begin
          cont1:= intf1.getdockcontroller;
          cont1.fmdistate:= mds_normal;
          anchors:= [an_left,an_top];
          widgetrect:= cont1.fnormalrect;
         end;
        end;
       end;
      end;
     end;
     invalidate;
    end
    else begin
     if (bo1 xor (od_fixsize in foptionsdock)) and
               getparentcontroller(cont1) then begin
      cont1.updaterefsize;
     end;
    end;
   end;
  end;
 end;
end;

{
procedure tdockcontroller.invalidategripsize;

 procedure descend1(const awidget: twidget1);
 var
  int1: integer;
 begin
  if awidget.fframe is tgripframe then begin
   with tgripframe(awidget.fframe) do begin
    exclude(fgripstate,grps_sizevalid);
   end;
  end;
  for int1:= 0 to awidget.widgetcount-1 do begin
   descend1(twidget1(awidget.widgets[int1]));
  end;
 end;

 procedure descend2(const awidget: twidget1);
 var
  int1: integer;
 begin
  if awidget.fframe is tgripframe then begin
   with tgripframe(awidget.fframe) do begin
    internalupdatestate;
   end;
  end;
  for int1:= 0 to awidget.widgetcount-1 do begin
   descend2(twidget1(awidget.widgets[int1]));
  end;
 end;
var
 widget1: twidget;

begin //invalidategripsize
 widget1:= fintf.getwidget;
 if not (csloading in widget1.componentstate) then begin
  descend1(twidget1(widget1));
  descend2(twidget1(widget1));
 end;
end;
}
procedure tdockcontroller.setuseroptions(const avalue: optionsdockty);


var
 optbefore: optionsdockty;
 widget1: twidget1;
begin
 optbefore:= foptionsdock;
 optionsdock:= optionsdockty(replacebits(longword(avalue),
                         longword(foptionsdock),longword(useroptionsmask)));
 if (foptionsdock >< optbefore) * [od_lock,od_nolock] <> [] then begin
  widget1:= twidget1(fintf.getwidget);
  if not widget1.isloading then begin
   widget1.parentchanged;
  end;
 end;
end;

procedure tdockcontroller.splitterchanged;
begin
 if not (csloading in fintf.getwidget.ComponentState) then begin
  updatesplitterrects(checksplit);
 end;
end;

procedure tdockcontroller.checkdirection;
begin
 if fsplitdir = sd_horz then begin
  fr:= @rectaccessy;
  fw:= @widgetaccessy;
 end
 else begin
  fr:= @rectaccessx;
  fw:= @widgetaccessx;
 end;
end;

function tdockcontroller.getparentcontroller(
                                 out acontroller: tdockcontroller): boolean;
var
 widget1: twidget;
 intf1: idocktarget;
begin
 result:= false;
 acontroller:= nil;
 widget1:= fintf.getwidget.parentwidget;
 if widget1 <> nil then begin
  if widget1.getcorbainterface(typeinfo(idocktarget),intf1) then begin
   acontroller:= intf1.getdockcontroller;
   result:= true;
  end;
 end;
end;

function tdockcontroller.getparentcontroller: tdockcontroller;
var
 widget1: twidget;
 intf1: idocktarget;
begin
 result:= nil;
 widget1:= fintf.getwidget.parentwidget;
 if widget1 <> nil then begin
  if widget1.getcorbainterface(typeinfo(idocktarget),intf1) then begin
   result:= intf1.getdockcontroller;
  end;
 end;
end;

procedure tdockcontroller.updaterefsize;
var
 int1: integer;
 ar1: widgetarty;
 ar2,ar3: booleanarty;
begin
 if fsplitdir in [sd_vert,sd_horz] then begin
  ar1:= checksplit(frefsize,int1,ar2,ar3,false);
  setlength(fsizes,length(ar1));
  for int1:= 0 to high(ar1) do begin
   fsizes[int1]:= fw^.size(ar1[int1]);
  end;
 end
 else begin
  fsizes:= nil;
 end;
end;

function tdockcontroller.calclayout(const dragobject: tdockdragobject;
                                     const nonewplace: boolean): boolean;
var
 rect1{,rect2}: rectty;
 po1: pointty;
 ar1: widgetarty;
 int1{,int2}: integer;
 step,stepsum,pos: real;
 container1: twidget1;
 widget1,widget2: twidget;
 index: integer;
 xorrect: rectty;
 intf1: idocktarget;
 propsize,varsize,fixsize,fixcount: integer;
 prop,fix: booleanarty;
 dirchanged: boolean;
 newwidget: boolean;
 controller1: tdockcontroller;
 bo1: boolean;
label
 endlab;
begin
 result:= false;
 container1:= twidget1(fintf.getwidget.container);
 if container1.componentstate * [csdestroying,csdesigning] <> [] then begin
  exit;
 end;
 checkdirection;
 if (ftabwidget <> nil) and (fsplitdir = sd_tabed) then begin
  include(fdockstate,dos_updating5);
  int1:= 0;
  while int1 <= high(container1.fwidgets) do begin
   widget1:= container1.fwidgets[int1];
   if widget1.visible and (widget1 <> ftabwidget) then begin
    tdocktabpage.create(tdocktabwidget(ftabwidget),widget1);
   end
   else begin
    inc(int1);
   end;
  end;
  exclude(fdockstate,dos_updating5);
 end;
 ar1:= checksplit;
 if fasplitdir <> sd_none then begin
  dirchanged:= fsplitdir <> fasplitdir;
  fsplitdir:= fasplitdir;
  fasplitdir:= sd_none;
 end
 else begin
  dirchanged:= false;
 end;
 if (ar1 = nil) and (dragobject = nil) then begin
  if fsplitdir = sd_none then begin
   fsplitterrects:= nil;
  end;
  goto endlab;
 end;
 rect1:= fplacementrect;//idockcontroller(fintf).getplacementrect;
 po1:= addpoint(pointty(rect1.size),rect1.pos); //lower right
 include(fdockstate,dos_updating1);
 if dragobject <> nil then begin
  with dragobject do begin
   widget1:= widget;
   index:= findex;
   xorrect:= fxorrect;
  end;
 end
 else begin
  widget1:= nil;
  index:= 0;
 end;
 if (ftabwidget <> nil) and (fsplitdir <> sd_tabed) then begin
  with tdocktabwidget(ftabwidget) do begin
   for int1:= count - 1 downto 0 do begin
    with tdocktabpage(items[int1]) do begin
     widget2:= ftarget;
     ftarget:= nil;
     include(fdockstate,dos_tabedending);
     try
      widget2.anchors:= ftargetanchors;
      widget2.parentwidget:= container1;
     finally
      exclude(fdockstate,dos_tabedending);
     end;
    end;
   end;
   freeandnil(ftabwidget);
  end;
 end;
 if (widget1 <> nil) then begin
  newwidget:= true;
  if (widget1.parentwidget = container1) then begin
   for int1:= 0 to high(ar1) do begin
    if ar1[int1] = widget1 then begin
     deleteitem(pointerarty(ar1),int1);
     newwidget:= false;
     break;
    end;
   end;
  end
  else begin
   widget2:= widget1.parentwidget;
   if fsplitdir <> sd_tabed then begin
    widget1.size:= xorrect.size;
    widget1.parentwidget:= container1;
    if widget1.parentwidget <> container1 then begin
     exit; //probably widget can not be defocused
    end;
   end;
   if getparentcontroller(controller1) then begin
    controller1.layoutchanged; //notify removing
   end;
   if (widget2 <> nil) and widget2.getcorbainterface(typeinfo(idocktarget),intf1) then begin
    intf1.getdockcontroller.layoutchanged;
   end;
  end;
 end
 else begin
  newwidget:= false;
 end;
 if (length(ar1) > 0) or (widget1 <> nil) then begin
  step:= 0; //compiler warning
  stepsum:= 0;
  if (fsplitdir <> sd_none) then begin
   if (widget1 <> nil) then begin
    if index > length(ar1) then begin
     index:= length(ar1);
    end;
    insertitem(pointerarty(ar1),index,widget1);
    if nofit then begin
//     if not newwidget then begin
      fr^.setosize(fsizingrect,fw^.osize(widget1));
                 //don't change height
//     end;
     widget1.widgetrect:= fsizingrect;
    end;
   end;
   if fsplitdir = sd_tabed then begin //use all children
    checksplit(ar1,propsize,varsize,fixsize,fixcount,prop,fix,false);
   end
   else begin                         //use visible children only
    ar1:= checksplit(ar1,propsize,varsize,fixsize,fixcount,prop,fix,false);
   end;
   if dirchanged or (propsize = 0) and newwidget then begin
    for int1:= 0 to high(prop) do begin //split even
     prop[int1]:= true;
     fix[int1]:= false;
     propsize:= fixsize + propsize;
     fixsize:= 0;
     varsize:= 0;
     fixcount:= 0;
    end;
   end;
   if fixcount < length(ar1) then begin
    if fsplitdir = sd_horz then begin
     step:= rect1.cy;
    end
    else begin
     step:= rect1.cx;
    end;
    stepsum:= (step - fixsize + varsize - fsplitter_size * high(ar1));
    if stepsum < 0 then begin
     stepsum:= 0;
    end;
    step:= stepsum /(length(ar1) - fixcount);
   end;
  end;
  case fsplitdir of
   sd_vert,sd_horz: begin
    if not nonewplace and not nofit then begin
     pos:= fr^.pos(rect1);
     bo1:= round(stepsum) = propsize+varsize; //no change if size matches
     for int1:= 0 to high(ar1) do begin
      fr^.setpos(rect1,round(pos));
      if prop[int1] and not bo1 then begin
       pos:= pos + step;
      end
      else begin
       pos:= pos + fw^.size(ar1[int1]);
      end;
      if int1 = high(ar1) then begin
       fr^.setsize(rect1,fr^.pt(po1) - fr^.pos(rect1));
      end
      else begin
       fr^.setsize(rect1,round(pos) - fr^.pos(rect1));
      end;
      ar1[int1].widgetrect:= rect1;
      pos:= pos + fsplitter_size;
     end;
    end;
   end;
   sd_tabed: begin
    include(fdockstate,dos_updating5);
    try
     fsplitterrects:= nil;
     if ftabwidget = nil then begin
      ftabwidget:= tdocktabwidget.create(self,container1);
      include(ttabwidget1(ftabwidget).foptionswidget1,ow1_noautosizing);
      ftabwidget.anchors:= [an_left,an_right,an_top,an_bottom];
     end;
     with tdocktabwidget(ftabwidget) do begin
      widgetrect:= fplacementrect;
      for int1:= 0 to high(ar1) do begin
       if (ar1[int1] <> ftabwidget) and
             ((ar1[int1].parentwidget = nil) or
              (ar1[int1].parentwidget.parentwidget <> ftabwidget)) then begin
        tdocktabpage.create(tdocktabwidget(ftabwidget),ar1[int1]);
       end;
      end;
     end;
    finally
     exclude(fdockstate,dos_updating5);
    end;
   end;
   else begin
    if widget1 <> nil then begin
     widget1.parentwidget:= container1;
     widget1.widgetrect:= translatewidgetrect(xorrect,nil,container1);
    end;
   end;
  end;
 end;
 exclude(fdockstate,dos_updating1);
 sizechanged(true,false,ar1);
 updatesplitterrects(ar1);
endlab:
 widget1:= fintf.getwidget;
 if widget1.canevent(tmethod(foncalclayout)) and
                             not application.terminated then begin
  foncalclayout(widget1,ar1);
 end;
 dolayoutchanged;
 result:= true;
end;

procedure tdockcontroller.updateminscrollsize(var asize: sizety);
var
 rect1: rectty;
 ar1: widgetarty;
 int1,int2: integer;
 bandlength,bandsize: integer;
 placementlength{,placementsize}: integer;
 maxlength,maxsize: integer;
 bo1: boolean;
 firstband: boolean;
begin
 if (od_banded in optionsdock) and nofit then begin
  if (fsplitdir = sd_vert) then begin
   ar1:= fintf.getwidget.getsortxchildren(true);
  end
  else begin
   ar1:= fintf.getwidget.getsortychildren(true);
  end;
  rect1:= idockcontroller(fintf).getplacementrect();
  placementlength:= fr^.size(rect1);
//  placementsize:= fr^.osize(rect1);
  bandlength:= 0;
  bandsize:= 0;
  maxlength:= 0;
  maxsize:= 0;
  bo1:= true;
  firstband:= true;
  for int1:= 0 to high(ar1) do begin
   int2:= fw^.size(ar1[int1])+fsplitter_size;
   bandlength:= bandlength+int2;
   if bandlength >{=} placementlength then begin //next band
    if not bo1 then begin //shift to next band
     bandlength:= bandlength - int2;
     if bandlength > maxlength then begin
      maxlength:= bandlength;
     end;
     bandlength:= int2;
     bandsize:= bandsize+maxsize;
     if not firstband then begin
      bandsize:= bandsize + fbandgap;
     end;
     maxsize:= fw^.osize(ar1[int1]);
    end
    else begin            //at least one widget
     if bandlength > maxlength then begin
      maxlength:= bandlength;
     end;
     bandsize:= bandsize + fw^.osize(ar1[int1]);
     if not firstband and (int1 < high(ar1)) then begin
      bandsize:= bandsize + fbandgap;
     end;
     bandlength:= 0;
     maxsize:= 0;
     bo1:= true; //first widget of band
    end;
    firstband:= false;
   end
   else begin
    bo1:= false; //not first widget of band
    if bandlength > maxlength then begin
     maxlength:= bandlength;
    end;
    int2:= fw^.osize(ar1[int1]);
    if int2 > maxsize then begin
     maxsize:= int2;
    end;
   end;
  end;
  bandsize:= bandsize+maxsize;
  if not firstband then begin
   bandsize:= bandsize + fbandgap;
  end;
  fr^.setsize(rect1,maxlength);
  fr^.setosize(rect1,bandsize);
  if rect1.cx > asize.cx then begin
   asize.cx:= rect1.cx;
  end;
  if rect1.cy > asize.cy then begin
   asize.cy:= rect1.cy;
  end;
 end;
end;

function tdockcontroller.nofit: boolean;
begin
 result:= (od_nofit in foptionsdock) and (fsplitdir in [sd_vert,sd_horz]);
end;

function tdockcontroller.dockdrag(const dragobj: tdockdragobject): boolean;
var
 parentbefore: tdockcontroller;
begin
 dragobj.fdock.getparentcontroller(parentbefore);
 result:= false;
 if calclayout(tdockdragobject(dragobj),false) then begin
  updaterefsize;
  result:= dragobj.fdock.dodock(parentbefore);
 end;
end;

procedure tdockcontroller.childstatechanged(const sender: twidget;
             const newstate: widgetstatesty; const oldstate: widgetstatesty);
var
 dock1: tdockcontroller;
begin
 if getparentcontroller(dock1) then begin
  dock1.childstatechanged(sender,newstate,oldstate);
 end;
end;

function tdockcontroller.beforedragevent(var info: draginfoty): boolean;

var
 widget1: twidget;
 container1: twidget;
 rect1: rectty;
 size1: sizety;
 count1: integer;
 sd1: splitdirty;
 int1,int2: integer;
 mouseinhandle: boolean;
 ischild1: boolean;

 function checkaccept: boolean;
 var
  intf1: idocktarget;
  widget2: twidget;
 begin
  ischild1:= false;
  result:= (info.dragobjectpo^ is tdockdragobject);
  if result then begin
   ischild1:=
       (tdockdragobject(info.dragobjectpo^).fdock.getparentcontroller = self);
   result:= ischild1 or
      (od_acceptsdock in foptionsdock) and
      (od_candock in tdockdragobject(info.dragobjectpo^).fdock.foptionsdock);
  end;
  if result and not mouseinhandle and (od_dockparent in foptionsdock) and
     not widget1.checkdescendent(
          tdockdragobject(info.dragobjectpo^).fdock.fintf.getwidget) then begin
   widget2:= widget1.parentwidget;
   while widget2 <> nil do begin
    if widget2.getcorbainterface(typeinfo(idocktarget),intf1) and
           (od_acceptsdock in intf1.getdockcontroller.foptionsdock) then begin
     result:= false;
     break;
    end;
    widget2:= widget2.parentwidget;
   end;
  end;
 end;

 procedure adjustdockrect;
 var
  nofit: boolean;
  rect2: rectty;
  pt1: pointty;
  x1,y1: integer;
  f1: flo64;
 begin
  with info,tdockdragobject(dragobjectpo^) do begin
   nofit:= (od_nofit in optionsdock) and (fsplitdir in [sd_vert,sd_horz]);
   if (fcheckeddockcontroller <> self) then begin
    if fcheckeddockcontroller <> nil then begin
     fcheckeddockcontroller.fasplitdir:= sd_none;
    end;
    fcheckeddockcontroller:= self;
   end;
   if fasplitdir = sd_none then begin
    fasplitdir:= fsplitdir;
   end;
   if not widget.checkdescendent(widget1) and
      idockcontroller(fintf).checkdock(info) and
                docheckdock(info) then begin
    accept:= true;
    rect1:= makerect(pos,widget.size);
    addpoint1(rect1.pos,widget1.clientwidgetpos);
    addpoint1(rect1.pos,widget1.screenpos);
    subpoint1(rect1.pos,addpoint(pickpos,widget.clientwidgetpos));
    if not nofit then begin
//     size1:= widget1.clientsize;
//     pt1:= addpoint(info.pos,container1.clientpos); //paint origin
     pt1:= subpoint(info.pos,fplacementrect.pos); //paint origin
//     size1:= container1.paintsize;
     size1:= fplacementrect.size;
     with size1 do begin
      x1:= cx div 8;
      y1:= (cy * 7) div 8;
     end;
     if (od_splitvert in foptionsdock) and
        (pt1.x < x1) and (pt1.y < y1) then begin
      fasplitdir:= sd_vert;
     end
     else begin
      if (od_splithorz in foptionsdock) and
         (pt1.y > y1) and (pt1.x > x1) then begin
       fasplitdir:= sd_horz;
      end
      else begin
       if (od_tabed in foptionsdock) and
          (pt1.x > (size1.cx * 7) div 16) and
          (pt1.x < (size1.cx * 9) div 16) and
          (pt1.y > (size1.cy * 7) div 16) and
          (pt1.y < (size1.cy * 9) div 16) then begin
        fasplitdir:= sd_tabed;
       end;
      end;
     end;
//     size1:= container1.paintsize;
     size1:= fplacementrect.size;
     if (widget.anchors * [an_left,an_right] = []) and
                               (fsplitdir = sd_none) then begin
      rect1.x:= container1.screenpos.x + fplacementrect.x;
                                            //container1.paintpos.x;
      rect1.cx:= size1.cx;
     end;
     if (widget.anchors * [an_top,an_bottom] = []) and
                               (fsplitdir = sd_none) then begin
      rect1.y:= container1.screenpos.y + fplacementrect.y;
                                                 //container1.paintpos.y;
      rect1.cy:= size1.cy;
     end;
     sd1:= fsplitdir;
     fsplitdir:= fasplitdir;
     count1:= length(checksplit);
     fsplitdir:= sd1;
     if (widget.parentwidget <> container1) and
                 not widget1.checkdescendent(ftabwidget) then begin
      inc(count1);
     end;
     findex:= count1-1;
     case fasplitdir of
      sd_vert: begin
       rect1.y:= container1.screenpos.y + fplacementrect.y;
                                             //container1.paintpos.y;
       rect1.cy:= size1.cy;
       if count1 = 0 then begin
        exit; //should not happen
       end;
       f1:= size1.cx / count1;
       rect1.cx:= size1.cx div count1;
       if rect1.cx > 0 then begin
        findex:= (pt1.x div rect1.cx);
        rect1.x:=  round(findex * f1) +
                container1.screenpos.x + fplacementrect.x;
                                               //container1.paintpos.x;
       end;
       if count1 = 1 then begin
        dec(rect1.cx,rect1.cx div 16);
       end;
      end;
      sd_horz: begin
       rect1.x:= container1.screenpos.x + fplacementrect.x;
                                              //container1.paintpos.x;
       rect1.cx:= size1.cx;
       if count1 = 0 then begin
        exit; //should not happen
       end;
       f1:= size1.cy / count1;
       rect1.cy:= size1.cy div count1;
       if rect1.cy > 0 then begin
        findex:= (pt1.y div rect1.cy);
        rect1.y:=  round(findex * f1) +
                container1.screenpos.y + fplacementrect.y;
                                              //container1.paintpos.y;
       end;
       if count1 = 1 then begin
        int1:= rect1.cy div 16;
        dec(rect1.cy,int1);
        inc(rect1.y,int1);
       end;
      end;
      sd_tabed: begin
       int1:= size1.cy div 16;
       int2:= size1.cx div 16;
       if int2 < int1 then begin
        int1:= int2;
       end;
       rect1:= inflaterect(fplacementrect
               {idockcontroller(fintf).getplacementrect},-int1);
       translatewidgetpoint1(rect1.pos,container1,nil);
      end;
      else; // Added to make compiler happy
     end;
     if fasplitdir = sd_none then begin
//      subpoint1(rect1.pos,widget.paintpos);
      if widget1 <> container1 then begin
//       addpoint1(rect1.pos,subpoint(widget1.paintpos,widget.paintpos));
//       subpoint1(rect1.pos,container1.pos);
      end;
      setxorwidget(container1,clipinrect(rect1,
        makerect(translatewidgetpoint(container1.clientwidgetpos,
        container1,nil),container1.maxclientsize)));
     end
     else begin
      setxorwidget(container1,clipinrect(rect1,
        makerect(translatewidgetpoint(fplacementrect.pos{container1.paintpos},
        container1,nil),size1)));
     end;
    end
    else begin //nofit
//     pt1:= translateclientpoint(rect1.pos,nil,container1);
     pt1:= addpoint(info.pos,widget1.paintpos);
     if findbandwidget(pt1,int1,rect2) then begin
      findex:= int1;
      fr^.setsize(rect2,fr^.size(rect1));
      fsizingrect:= rect2;
      translatewidgetpoint1(rect2.pos,container1,nil);
      setxorwidget(container1,rect2);
     end;
    end;
    result:= true;
   end;
  end;
 end;

 procedure dockwidget;
 begin
  with info,tdockdragobject(dragobjectpo^) do begin
   if container1 = fxorwidget then begin
    with tdockdragobject(dragobjectpo^).fdock do begin
     if fmdistate = mds_floating then begin
      fmdistate:= mds_normal;
     end
     else begin
      if fmdistate = mds_maximized then begin
       fnormalrect:= widget1.widgetrect;
       mdistate:= mds_normal;
      end;
     end;
     translatewidgetpoint1(fsizingrect.pos,nil,container1);
            //used incalclayout
    end;
    fsizes:= nil;
    dockdrag(tdockdragobject(dragobjectpo^));
 {
    calclayout(tdockdragobject(dragobjectpo^),false);
    updaterefsize;
    tdockdragobject(dragobjectpo^).fdock.dodock;
//    dochilddock(widget);
}
    result:= true;
   end;
  end;
 end;

begin
 widget1:= fintf.getwidget;
 container1:= widget1.container;
 result:= false;
 ischild1:= false;
 if not(csdesigning in widget1.ComponentState) then begin
  with info do begin
   if fdockhandle <> nil then begin
    mouseinhandle:= (fdockhandle <> nil) and
    pointinrect(translateclientpoint(info.pos,
      idockcontroller(fintf).getwidget,fdockhandle),fdockhandle.gethandlerect);
   end
   else begin
    mouseinhandle:=
        pointinrect({widget1.clientpostowidgetpos(}info.pos{)},
                           idockcontroller(fintf).getbuttonrects(dbr_handle));
   end;
//   mouseinhandle:= (fdockhandle <> nil) and pointinrect(
//     translateclientpoint(info.pos,idockcontroller(fintf).getwidget,fdockhandle),
//       fdockhandle.gethandlerect) or
//      pointinrect({widget1.clientpostowidgetpos(}info.pos{)},
//                            idockcontroller(fintf).getbuttonrects(dbr_handle));
   case eventkind of
    dek_begin: begin
     if mouseinhandle then begin
      if (widget1.parentwidget <> nil)  then  begin
       if od_canmove in foptionsdock then begin
        tdockdragobject.create(self,widget1,dragobjectpo^,fpickpos);
        result:= true;
       end
       else begin
        if canfloat and not (dos_hasfloatbutton in fdockstate) and
                        not(csdesigning in widget1.componentstate) then begin
         dofloat(nullpoint);
         result:= true;
        end;
       end;
      end
      else begin
       if (od_candock in foptionsdock) and (widget1.parentwidget = nil) and
              (dragobjectpo^ = nil) then  begin
        tdockdragobject.create(self,widget1,dragobjectpo^,fpickpos);
        result:= true;
       end;
      end;
      if result then begin
       fclickedbutton:= dbr_none;
      end;
     end
    end;
    dek_check: begin
     if checkaccept then begin
      adjustdockrect;
     end;
    end;
    dek_drop: begin
     if checkaccept and (not ischild1 or
             (tdockdragobject(info.dragobjectpo^).fdock.fmdistate <>
                                                   mds_maximized)) then begin
      dockwidget;
     end;
    end;
    else; // Added to make compiler happy
   end;
  end;
 end;
 if not result then begin
  result:= inherited beforedragevent(info);
 end;
end;

procedure tdockcontroller.setdockhandle(const avalue: tdockhandle);
begin
 if fdockhandle <> nil then begin
  fdockhandle.fcontroller:= nil;
 end;
 setlinkedvar(avalue,tmsecomponent(fdockhandle));
 if fdockhandle <> nil then begin
  fdockhandle.fcontroller:= self;
 end;
end;

function tdockcontroller.dodock(const oldparent: tdockcontroller): boolean;
var
 widget1: twidget1;
 int1: integer;
 controller1: tdockcontroller;
begin
 widget1:= twidget1(fintf.getwidget);
 inc(floatdockcount);
 int1:= floatdockcount;
 if widget1.canevent(tmethod(fondock)) then begin
  fondock(widget1);
 end;
 if floatdockcount = int1 then begin
  if getparentcontroller(controller1) then begin
   if (fmdistate <> mds_minimized) or (oldparent <> controller1) then begin
    fmdistate:= mds_normal;
   end;
   if oldparent <> controller1 then begin
    controller1.dochilddock(widget1);
   end;
  end;
 end;
 result:= floatdockcount = int1;
end;

function tdockcontroller.dofloat(const adist: pointty): boolean;
var
 widget1: twidget1;
 wstr1: msestring;
 int1: integer;
 controller1: tdockcontroller;
 rect1: rectty;
begin
 widget1:= twidget1(fintf.getwidget);
 if widget1.parentwidget = nil then begin
  result:= true;
 end
 else begin
  result:= false;
  getparentcontroller(controller1);
  with widget1 do begin
   if not (fmdistate in [mds_normal,mds_floating]) then begin
    rect1.pos:= translatewidgetpoint(fnormalrect.pos,parentwidget,nil);
    rect1.size:= fnormalrect.size;
   end
   else begin
    rect1.pos:= screenpos;
    rect1.size:= size;
   end;
   addpoint1(rect1.pos,adist);
   if canevent(tmethod(fonbeforefloat)) then begin
    fonbeforefloat(widget1,rect1);
   end;
   parentwidget:= nil;
   if parentwidget <> nil then begin
    exit;
   end;
   widgetrect:= rect1;
   if fmdistate = mds_maximized then begin
    anchors:= [an_left,an_top];
   end;
  end;
  fmdistate:= mds_floating;
 // widget1.pos:= addpoint(widget1.pos,adist);
  wstr1:= getfloatcaption;
  if wstr1 <> '' then begin
   widget1.window.caption:= wstr1;
  end;
  updategrip(sd_none,widget1);
  inc(floatdockcount);
  int1:= floatdockcount;
  if widget1.canevent(tmethod(fonfloat)) then begin
   fonfloat(widget1);
  end;
  if (floatdockcount = int1) and (controller1 <> nil) then begin
   fhiddensizeref:= nullsize;
   controller1.dochildfloat(widget1);
   widget1.activate;
  end;
  result:= floatdockcount = int1;
  if result then begin
   dolayoutchanged();
  end;
 end;
end;

function tdockcontroller.float(): boolean;
                                  //false if canceled
begin
 result:= dofloat(nullpoint);
end;

function tdockcontroller.dockto(const dest: tdockcontroller;
                                        const apos: pointty): boolean;
var
 dragobj: tdockdragobject;
 widget1: twidget;
begin
 dragobj:= nil;
 widget1:= fintf.getwidget;
 dragobj:= tdockdragobject.create(self,widget1,tdragobject(dragobj),nullpoint);
 try
  with dragobj.fxorrect do begin
   size:= widget1.size;
   widget1:= dest.fintf.getwidget.container;
   pos:= translatewidgetpoint(apos,widget1,nil);
   addpoint1(pos,widget1.clientwidgetpos);
//  addpoint1(dragobj.fxorrect.pos,dest.fplacementrect.pos);
   result:= dest.dockdrag(dragobj);
  end;
 finally
  dragobj.free;
 end;
end;

function tdockcontroller.canfloat: boolean;
begin
 result:= (od_canfloat in foptionsdock) and
               not (ismdi and (mdistate = mds_minimized))
end;

function tdockcontroller.nogrip: boolean;
var
 parent: tdockcontroller;
begin
 result:= (od_lock in foptionsdock) or
         not (od_nolock in foptionsdock) and getparentcontroller(parent) and
                                                                 parent.nogrip;
end;

procedure tdockcontroller.refused(const apos: pointty);
var
 widget1: twidget;
 intf1: idocktarget;
 dir1: splitdirty;
begin
 if canfloat and not (dos_hasfloatbutton in fdockstate) then begin
  widget1:= fintf.getwidget.parentwidget;
  dir1:= sd_none; //compiler warning
  if widget1 <> nil then begin
   if widget1.getcorbainterface(typeinfo(idocktarget),intf1) then begin
    with intf1.getdockcontroller do begin
     dir1:= fasplitdir;
     fasplitdir:= fsplitdir; //no change of dir in calclayout
    end;
   end;
   dofloat(subpoint(apos,translateclientpoint(fpickpos,fintf.getwidget,nil)));
   if intf1 <> nil then begin
    with intf1.getdockcontroller do begin
     fasplitdir:= dir1;
    end;
   end;
  end;
 end;
end;

procedure tdockcontroller.dochilddock(const awidget: twidget);
var
 widget1: twidget1;
begin
 widget1:= twidget1(fintf.getwidget);
 if widget1.canevent(tmethod(fonchilddock)) then begin
  fonchilddock(widget1,awidget);
 end;
end;

procedure tdockcontroller.dochildfloat(const awidget: twidget);
var
 widget1: twidget1;
begin
 widget1:= twidget1(fintf.getwidget);
 if widget1.canevent(tmethod(fonchildfloat)) then begin
  fonchildfloat(widget1,awidget);
 end;
end;

procedure tdockcontroller.domdistatechanged(const oldstate,newstate: mdistatety);
var
 widget1: twidget1;
begin
 widget1:= twidget1(fintf.getwidget);
 if widget1.canevent(tmethod(fonmdistatechanged)) then begin
  fonmdistatechanged(widget1,oldstate,newstate);
 end;
end;

function tdockcontroller.docheckdock(const info: draginfoty): boolean;
var
 widget1: twidget1;
begin
 widget1:= twidget1(fintf.getwidget);
 if widget1.canevent(tmethod(foncheckdock)) then begin
  result:= false;
  foncheckdock(widget1,info.pos,tdockdragobject(info.dragobjectpo^),result);
 end
 else begin
  result:= true;
 end;
end;

procedure tdockcontroller.enddrag;
begin
 if fdragobject is tdockdragobject then begin
  with tdockdragobject(fdragobject) do begin
   if fxorwidget <> nil then begin
    fxorwidget.invalidatewidget;
   end;
  end;
 end;
 inherited;
end;

procedure tdockcontroller.beginplacement();
begin
 if fplacing = 0 then begin
  include(fdockstate,dos_updating4);
 end;
 inc(fplacing);
end;

procedure tdockcontroller.endplacement();
var
 int1,int2,int3: integer;
 str1: string;
 widget1: twidget;
begin
 dec(fplacing);
 if fplacing = 0 then begin
  exclude(fdockstate,dos_updating4);
  sizechanged(true);
  calclayout(nil,true);
  if (ftaborder <> nil) then begin
   if (fsplitdir = sd_tabed) and (ftabwidget <> nil) then begin
    int3:= 0;
    for int1:= 0 to high(ftaborder) do begin
     str1:= ansistring(ftaborder[int1]);
     for int2:= int3 to tdocktabwidget(ftabwidget).count - 1 do begin
      widget1:= tdocktabpage(tdocktabwidget(ftabwidget)[int2]).ftarget;
      if (widget1 <> nil) and (widget1.Name = str1) then begin
       tdocktabwidget(ftabwidget).movepage(int2,int3);
       inc(int3);
       break;
      end;
     end;
    end;
    if factivetab < tdocktabwidget(ftabwidget).count then begin
     tdocktabwidget(ftabwidget).activepageindex:= factivetab;
    end;
   end;
   ftaborder:= nil;
  end;
 end;
end;

   //istatfile
procedure tdockcontroller.statreading;
begin
 beginplacement();
// include(fdockstate,dos_updating4);
end;

procedure tdockcontroller.statread;
begin
 fsize:= idockcontroller(fintf).getplacementrect.size;
 endplacement();
// exclude(fdockstate,dos_updating4);
// calclayout(nil,true);
end;

function tdockcontroller.getdockcaption: msestring;
begin
 if fcaption = '' then begin
  result:= idockcontroller(fintf).getcaption;
 end
 else begin
  result:= fcaption
 end;
end;

function tdockcontroller.getfloatcaption: msestring;
begin
 result:= idockcontroller(fintf).getcaption;
 if result = '' then begin
  result:= fcaption
 end;
end;

procedure tdockcontroller.readchildrencount(const acount: integer);
begin
 setlength(fchildren,acount);
end;

procedure tdockcontroller.readchild(const index: integer;
               const avalue: msestring);
var
 na: ansistring;
 rect1,rect2: rectty;
 w1: twidget;
begin
 decoderecord(avalue,[@na,@rect1.x,@rect1.y,@rect1.cx,@rect1.cy],'siiii');
 with fintf.getwidget do begin
  w1:= findchild(na);
  fchildren[index]:= na;
  if w1 <> nil then begin
   rect2:= application.screenrect(window);
   shiftinrect(rect1,rect2);
   clipinrect(rect1,rect2);
   w1.widgetrect:= rect1;
  end;
 end;
end;

procedure tdockcontroller.dostatplace(const aparent: twidget;
                        const avisible: boolean; arect: rectty);
var
 intf1: idocktarget;
 widget0: twidget;
begin
 widget0:= fintf.getwidget();
 with widget0 do begin
  if not avisible then begin
   visible:= false;
  end;
  if (aparent <> nil) and
               aparent.getcorbainterface(typeinfo(idocktarget),
                                                          intf1) then begin
   intf1.getdockcontroller.frefsize:= 0; //invalid
  end;
  parentwidget:= aparent;
  if (parentwidget <> nil) then begin
   if not parentwidget.getcorbainterface(typeinfo(idocktarget),
                                                           intf1) then begin
    arect:= clipinrect(arect,parentwidget.paintrect); //shift into widget
   end;
   widgetrect:= arect;
  end
  else begin
   updategrip(sd_none,widget0);
   arect:= clipinrect(arect,application.screenrect); //shift into screen
   widgetrect:= arect;
   application.postevent(tobjectevent.create(ek_checkscreenrange,
                                                            ievent(widget0)));
  end;
  visible:= avisible;
 end;
end;

procedure tdockcontroller.updatetabpage(const sender: ttabpage);
begin
 ftabpage:= sender;
 sender.caption:= getdockcaption;
 if fcolortab <> cl_default then begin
  sender.colortab:= fcolortab;
 end;
 if fcoloractivetab <> cl_default then begin
  sender.coloractivetab:= fcoloractivetab;
 end;
 sender.facetab:= ffacetab;
 sender.faceactivetab:= ffaceactivetab;
end;

procedure tdockcontroller.dostatread(const reader: tstatreader);
var
 rect1: rectty;
 widget0,widget1: twidget;
 str1: string;
 bo1: boolean;
begin
 if not (od_banded in foptionsdock) then begin
  fsplitdir:= splitdirty(reader.readinteger('splitdir',ord(fsplitdir),
                              0,ord(high(splitdirty))));
 end;
 useroptions:= optionsdockty(longword(
     reader.readinteger('useroptions',integer(longword(fuseroptions)))));
// setoptionsdock(foptionsdock); //check valid values
 ftaborder:= reader.readarray('order',msestringarty(nil));
 factivetab:= reader.readinteger('activetab',0);
 widget0:= fintf.getwidget;
 with widget0 do begin
  if od_savepos in foptionsdock then begin
   if parentwidget = nil then begin
    str1:= '';
   end
   else begin
    str1:= ownernamepath(parentwidget);
   end;
   str1:= reader.readstring('parent',str1);
   fmdistate:= mdistatety(reader.readinteger('mdistate',ord(fmdistate)));
   with fnormalrect do begin
    x:= reader.readinteger('nx',x);
    y:= reader.readinteger('ny',y);
    cx:= reader.readinteger('ncx',cx,0);
    cy:= reader.readinteger('ncy',cy,0);
   end;
   rect1:= widgetrect;
   with rect1 do begin
    x:= reader.readinteger('x',x);
    y:= reader.readinteger('y',y);
    cx:= reader.readinteger('cx',cx,0);
    cy:= reader.readinteger('cy',cy,0);
   end;
   with fhiddensizeref do begin
    cx:= reader.readinteger('rcx',cx);
    cy:= reader.readinteger('rcy',cy);
   end;
   bo1:= visible;
   bo1:= reader.readboolean('visible',bo1);
   application.findwidget(str1,widget1);
   dostatplace(widget1,bo1,rect1);
  end;
  if od_savechildren in foptionsdock then begin
   ffocusedchild:= reader.readinteger('focusedchild',-1);
   reader.readrecordarray('children',{$ifdef FPC}@{$endif}readchildrencount,
             {$ifdef FPC}@{$endif}readchild);
   if fchildren <> nil then begin
    application.postevent(tchildorderevent.create(self));
    fchildren:= nil;
   end;
  end;
  if (parentwidget = nil) and (od_savezorder in foptionsdock) then  begin
   str1:= '~';
   str1:= reader.readstring('stackedunder',str1);
   if str1 <> '~' then begin
    if trim(str1) = '' then begin
     window.stackunder(nil);
    end
    else begin
     if application.findwidget(str1,widget1) and (widget1 <> nil) then begin
      window.stackunder(widget1.window);
     end;
    end;
   end;
   window.caption:= getfloatcaption;
  end;
 end;
end;

procedure tdockcontroller.dock(const source: tdockcontroller;
                                                   const arect: rectty);
var
 child1,parent1: twidget;
begin
 fhiddensizeref:= arect.size;
 fnormalrect:= arect;
 child1:= source.getwidget();
 parent1:= getwidget().container;
 source.dostatplace(parent1,child1.visible,arect);
end;

function tdockcontroller.writechild(const index: integer): msestring;
begin
 with twidget1(fintf.getwidget).container.widgets[index] do begin
  result:= encoderecord([name,bounds_x,bounds_y,bounds_cx,bounds_cy]);
  if entered then begin
   ffocusedchild:= index;
  end;
 end;
end;

procedure tdockcontroller.dostatwrite(const writer: tstatwriter;
                                    const bounds: prectty = nil);
var
 str1: string;
 window1: twindow;
 tabed: boolean;
 ar1: msestringarty;
 int1: integer;
 po1: prectty;
begin
 str1:= '';
 writer.writeinteger('splitdir',ord(fsplitdir));
 writer.writeinteger('useroptions',
         {$ifdef FPC}longword{$else}longword{$endif}(fuseroptions));
 if ftabwidget <> nil then begin
  with tdocktabwidget(ftabwidget) do begin
   setlength(ar1,count);
   for int1:= 0 to high(ar1) do begin
    ar1[int1]:= msestring(tdocktabpage(items[int1]).ftarget.Name);
   end;
   writer.writearray('order',ar1);
   writer.writeinteger('activetab',activepageindex);
  end;
 end;
 with twidget1(fintf.getwidget) do begin
  if od_savezorder in foptionsdock then begin
   if parentwidget = nil then begin
    str1:= '';
    window1:= window.stackedunder;
    if window1 <> nil then begin
     writer.writestring('stackedunder',ownernamepath(window1.owner));
    end
    else begin
     writer.writestring('stackedunder','');
    end;
   end;
  end;
  if od_savepos in foptionsdock then begin
   tabed:= (parentwidget is tdocktabpage) and (parentwidget.parentwidget <> nil);
   if parentwidget <> nil then begin
    if tabed then begin
     str1:= ownernamepath(parentwidget.parentwidget.parentwidget);
    end
    else begin
     str1:= ownernamepath(parentwidget);
    end;
   end;
   writer.writestring('parent',str1);
   po1:= bounds;
   if po1 = nil then begin
    po1:= @fwidgetrect;
    writer.writeboolean('visible',visible);
   end;
   writer.writeinteger('mdistate',ord(fmdistate));
   writer.writeinteger('nx',fnormalrect.x);
   writer.writeinteger('ny',fnormalrect.y);
   writer.writeinteger('ncx',fnormalrect.cx);
   writer.writeinteger('ncy',fnormalrect.cy);
   writer.writeinteger('x',po1^.x);
   writer.writeinteger('y',po1^.y);
   writer.writeinteger('cx',po1^.cx);
   writer.writeinteger('cy',po1^.cy);
   with fhiddensizeref do begin
    writer.writeinteger('rcx',cx);
    writer.writeinteger('rcy',cy);
   end;
  end;
  if od_savechildren in foptionsdock then begin
   writer.writerecordarray('children',container.widgetcount,
             {$ifdef FPC}@{$endif}writechild);
   writer.writeinteger('focusedchild',ffocusedchild);
  end;
 end;
end;

procedure tdockcontroller.setsplitter_size(const Value: integer);
begin
 if value <> fsplitter_size then begin
  fsplitter_size := Value;
  layoutchanged;
 end;
end;

procedure tdockcontroller.setsplitter_setgrip(const Value: stockbitmapty);
begin
 if fsplitter_grip <> value then begin
  fsplitter_grip:= Value;
  splitterchanged;
 end;
end;

procedure tdockcontroller.setsplitter_color(const Value: colorty);
begin
 if fsplitter_color <> value then begin
  fsplitter_color := Value;
  splitterchanged;
 end;
end;

procedure tdockcontroller.setsplitter_colorgrip(const Value: colorty);
begin
 if fsplitter_colorgrip <> value then begin
  fsplitter_colorgrip := Value;
  splitterchanged;
 end;
end;

procedure tdockcontroller.setbandgap(const avalue: integer);
begin
 if fbandgap <> avalue then begin
  fbandgap:= avalue;
  layoutchanged;
 end;
end;

procedure tdockcontroller.layoutchanged;
begin
 if not (csloading in fintf.getwidget.ComponentState) then begin
  calclayout(nil,false);
 end;
end;

procedure tdockcontroller.setpickshape(const ashape: cursorshapety);
begin
 with fintf.getwidget do begin
  if not (ds_cursorshapechanged in fstate) then begin
   fcursorbefore:= cursor;
   include(fstate,ds_cursorshapechanged);
  end;
  cursor:= ashape;
 end;
end;

procedure tdockcontroller.restorepickshape;
begin
 if ds_cursorshapechanged in fstate then begin
  fintf.getwidget.cursor:= fcursorbefore;
  exclude(fstate,ds_cursorshapechanged);
 end;
end;

function tdockcontroller.checkbuttonarea(const apos: pointty): dockbuttonrectty;
var
 dbr1: dockbuttonrectty;
begin
 result:= dbr_none;
 for dbr1:= dbr_firstbutton to dbr_lastbutton do begin
  if pointinrect(apos,idockcontroller(fintf).getbuttonrects(dbr1)) then begin
   result:= dbr1;
   break;
  end;
 end;
 if (result = dbr_none) then begin
  if fdockhandle <> nil then begin
   if pointinrect(apos,fdockhandle.paintparentrect) then begin
    result:= dbr_handle;
   end;
  end
  else begin
   if pointinrect(apos,
                 idockcontroller(fintf).getbuttonrects(dbr_handle)) then begin
    result:= dbr_handle; //handle rect can include buttons
   end;
  end;
 end;
end;

function tdockcontroller.findbandpos(const apos: integer; out aindex: integer;
                                     out arect: rectty): boolean;
var
 int1,int2: integer;
begin
 result:= false;
 int2:= fbandstart;
 for int1:= 0 to high(fbands) do begin
  with fbands[int1] do begin
   if (apos >= int2) and (apos < int2 + size) then begin
    result:= true;
    aindex:= int1;
    fr^.setopos(arect,int2);
    fr^.setosize(arect,size);
    fr^.setpos(arect,fr^.pos(fplacementrect));
    fr^.setsize(arect,fr^.size(fplacementrect));
    break;
   end;
   int2:= int2 + size + fbandgap;
  end;
 end;
end;

function tdockcontroller.findbandwidget(const apos: pointty; out aindex: integer;
                                     out arect: rectty): boolean;
             //false if not found. widget index and widget rect
var
 ar1: widgetarty;
 int1,int2,int3,int4,int5: integer;
begin
 result:= findbandpos(fr^.opt(apos),int4,arect);
 if result then begin
  ar1:= checksplit;
  aindex:= -1;
  if ar1 <> nil then begin
   int3:= fr^.pos(arect);
   int5:= fr^.pt(apos);
   with fbands[int4] do begin
    aindex:= last;
    for int1:= first to last - 1 do begin
     int2:= fw^.size(ar1[int1]) + fsplitter_size;
     if int3 + int2 >= int5 then begin
      aindex:= int1;
      break;
     end;
     int3:= int3 + int2;
    end;
   end;
   fr^.setpos(arect,int3);
   fr^.setsize(arect,fw^.size(ar1[aindex]));
  end;
 end;
end;

function tdockcontroller.findbandindex(const widgetindex: integer; out aindex: integer;
                                     out arect: rectty): boolean;
var
 int1,int2: integer;
begin
 result:= false;
 int2:= fbandstart;
 for int1:= 0 to high(fbands) do begin
  with fbands[int1] do begin
   if last >= widgetindex then begin
    result:= true;
    aindex:= int1;
    fr^.setopos(arect,int2);
    fr^.setosize(arect,size);
    fr^.setpos(arect,fr^.pos(fplacementrect));
    fr^.setsize(arect,fr^.size(fplacementrect));
    break;
   end;
   int2:= int2 + size + fbandgap;
  end;
 end;
end;

function tdockcontroller.doclose(const awidget: twidget): boolean;
begin
 result:= simulatemodalresult(awidget,mr_windowclosed);
end;

function tdockcontroller.canbegindrag: boolean;
begin
 result:= (fdockstate * [dos_moving,dos_sizing,dos_xorpic] = []) and
   not ((fmdistate = mds_maximized) and not (od_canfloat in foptionsdock));
end;

procedure tdockcontroller.drawxorpic(const ashow: boolean;
                                        var canvas1: tcanvas);
var
 rect1: rectty;
begin
 if canvas1 = nil then begin
  canvas1:= fintf.getwidget().container.getcanvas(org_widget);
 end;
 if dos_moving in fdockstate then begin
  canvas1.drawxorframe(fsizingrect,-2,stockobjects.bitmaps[stb_dens50]);
 end
 else begin
  if not (od_thumbtrack in foptionsdock) then begin
   if fsplitdir = sd_vert then begin
    rect1:= moverect(fsizingrect,makepoint(fsizeoffset,0));
   end
   else begin
    rect1:= moverect(fsizingrect,makepoint(0,fsizeoffset));
   end;
   canvas1.fillxorrect(rect1,stockobjects.bitmaps[stb_dens50]);
  end;
 end;
 if ashow then begin
  include(fdockstate,dos_xorpic);
 end
 else begin
  exclude(fdockstate,dos_xorpic);
 end;
end;

procedure tdockcontroller.endmouseop1();
var
 c1: tcanvas;
begin
 restorepickshape();
 if dos_xorpic in fdockstate then begin
  c1:= nil;
  drawxorpic(false,c1); //remove pic
 end;
 if fsizeindex >= 0 then begin
  application.unregisteronkeypress(@dokeypress);
 end;
end;

const
 resetmousedockstate =
        [{dos_closebuttonclicked,dos_maximizebuttonclicked,
          dos_normalizebuttonclicked,dos_minimizebuttonclicked,
          dos_fixsizebuttonclicked,dos_floatbuttonclicked,dos_topbuttonclicked,
          dos_backgroundbuttonclicked,
          dos_lockbuttonclicked,dos_nolockbuttonclicked,}dos_moving];

procedure tdockcontroller.endmouseop2();
begin
 fdockstate:= fdockstate - resetmousedockstate;
 fclickedbutton:= dbr_none;
end;

procedure tdockcontroller.cancelsizing();
var
 i1: int32;
begin
 endmouseop1();
 endmouseop2();
 fsizeindex:= -1;
 if (od_thumbtrack in foptionsdock) and
          (high(fwidgetrectsbefore) = high(fwidgetsbefore)) then begin
  include(fdockstate,dos_updating1);
  try
   for i1:= 0 to high(fwidgetrectsbefore) do begin
    fwidgetsbefore[i1].widgetrect:= fwidgetrectsbefore[i1];
   end;
  finally
   fwidgetrectsbefore:= nil;
   exclude(fdockstate,dos_updating1);
   calclayout(nil,true);
   updaterefsize();
  end;
 end;
 fwidgetrectsbefore:= nil;
end;

procedure tdockcontroller.clientmouseevent(var info: mouseeventinfoty);

var
 po1: pointty;
 widget1: twidget1;
 propsize,fixsize: integer;
 ar1: widgetarty;
 prop,fix: booleanarty;
 fixend: boolean;

 function checksizing(const move: boolean): integer;

  function updatesizingrect: integer;
  var
   int1,int2: integer;
   w1: twidget;
   p1: integer;
   bandnumber: integer;
   bandrect: rectty;
   lastitem: integer;
  begin
   result:= -1;
   if not findbandpos(fr^.opt(po1),bandnumber,bandrect) then begin
    exit;
   end;
   p1:= fr^.pt(po1);      //widget direction
   lastitem:= fbands[bandnumber].last;
   if not fixend then begin
    dec(lastitem);
   end;
   for int1:= fbands[bandnumber].first to lastitem do begin
    w1:= twidget1(ar1[int1]);
    int2:= fw^.stop(w1);
    if (fsplitter_size = 0) and (p1 >= int2 - sizingtol) and
                    (p1 < int2 + sizingtol) or
       (fsplitter_size <> 0) and (p1 >= int2) and
            (p1 < int2 + fsplitter_size) then begin
     fr^.setopos(fsizingrect,fr^.opos(bandrect));
     fr^.setosize(fsizingrect,fr^.osize(bandrect));
     if move then begin
      fr^.setsize(fsizingrect,fw^.size(w1));
      fr^.setpos(fsizingrect,int2-fr^.size(fsizingrect));
     end
     else begin
      if fsplitter_size = 0 then begin
       fr^.setpos(fsizingrect,int2-sizingtol);
       fr^.setsize(fsizingrect,2*sizingtol);
      end
      else begin
       fr^.setpos(fsizingrect,int2);
       fr^.setsize(fsizingrect,fsplitter_size);
      end;
     end;
     result:= int1;
     break;
    end;
   end;
  end;

 begin
  ar1:= nil; //compilerwarning
  result:= -1;
  if move and (optionsdock * [od_nofit,od_nosplitmove] <> [od_nofit]) then begin
   exit;
  end;
  if not move and (optionsdock * [od_nosplitsize] <> []) then begin
   exit;
  end;
  ar1:= checksplit;
  if fsplitdir in [sd_vert,sd_horz] then begin
   result:= updatesizingrect;
   if result >= 0 then begin
    if fsplitdir = sd_vert then begin
     setpickshape(cr_sizehor);
    end
    else begin
     setpickshape(cr_sizever);
    end;
   end;
  end;
  if result < 0 then begin
   restorepickshape;
  end;
 end;

 procedure checksizeoffset;
 var
  start,stop: integer;
  int1,int2,int4: integer;
  movestart: integer;
  rect1: rectty;
  bandindex: integer;
 begin
  stop:= 0;
  start:= 0;
  ar1:= checksplit(propsize,fixsize,prop,fix,false);
  if fsizeindex <= high(ar1) then begin
   movestart:= fr^.pos(fplacementrect);
   start:= movestart - fw^.stop(ar1[fsizeindex]);
   stop:= start + fr^.size(fplacementrect);
   if not fixend then begin
    for int1:= 0 to fsizeindex - 1 do begin
     if fix[int1] then begin
      start:= start + fw^.size(ar1[int1]);
     end
     else begin
      start:= start + fw^.min(ar1[int1]);
     end;
    end;
    for int1:= fsizeindex + 1 to high(ar1) do begin
     if fix[int1] and (int1 <> fsizeindex + 1) then begin
      stop:= stop - fw^.size(ar1[int1]);
     end
     else begin
      stop:= stop - fw^.min(ar1[int1]);
     end;
    end;
    start:= start + fsizeindex * fsplitter_size;
    stop:= stop - (high(ar1)-fsizeindex) * fsplitter_size;
   end
   else begin
    if dos_moving in fdockstate then begin
     movestart:= movestart + fsplitter_size;
     fmoveindex:= fsizeindex;
     int4:= fsizeoffset + fw^.pos(ar1[fsizeindex]); //mouse position
     if findbandpos(fr^.opt(po1),bandindex,rect1) then begin
      with fbands[bandindex] do begin
       fmoveindex:= last;
       for int1:= first to last do begin
        int2:= fw^.pos(ar1[int1]);
        movestart:= movestart + int2 + fsplitter_size;
        if movestart > int4 then begin
         fmoveindex:= int1;
         break;
        end;
       end;
      end;
     end
     else begin
      findbandindex(fsizeindex,int1,rect1);
     end;
     fr^.setopos(fsizingrect,fr^.opos(rect1));
     fr^.setosize(fsizingrect,fr^.osize(rect1));
     fr^.setpos(fsizingrect,fw^.pos(ar1[fmoveindex]));
    end
    else begin
     start:= start + fw^.pos(ar1[fsizeindex]) - fr^.pos(fplacementrect) +
                           fw^.min(ar1[fsizeindex]);
     stop:= stop - fsplitter_size;
    end;
   end;
  end;
  if fsizeoffset < start then begin
   fsizeoffset:= start;
  end;
  if fsizeoffset > stop then begin
   fsizeoffset:= stop;
  end;
 end;

 procedure calcdelta;
 var
  int1,int2,int3: integer;
  wi1: twidget;
  rect1,rect2: rectty;
 begin
  ar1:= checksplit(propsize,fixsize,prop,fix,false);
  if high(ar1) > 0 then begin
   int2:= fsizeoffset;
   include(fdockstate,dos_updating4);
   try
    if not fixend then begin
     for int1:= fsizeindex downto 0 do begin
      if not fix[int1] or (int1 = fsizeindex) then begin
       int3:= fw^.size(ar1[int1]);
       fw^.setsize(ar1[int1],int3+int2);
       int2:= int2 + int3 - fw^.size(ar1[int1]);
       if int2 = 0 then begin
        break;
       end;
      end;
     end;
     fw^.setsize(ar1[0],fw^.size(ar1[0]) + int2); //ev. rest
     int2:= - fsizeoffset;
     for int1:= fsizeindex + 1 to high(ar1) do begin
      if not fix[int1] or (int1 = fsizeindex + 1) then begin
       int3:= fw^.size(ar1[int1]);
       fw^.setsize(ar1[int1],int3+int2);
       int2:= int2 + int3 - fw^.size(ar1[int1]);
       if int2 = 0 then begin
        break;
       end;
      end;
     end;
    end;
    if dos_moving in fdockstate then begin
     findbandindex(fsizeindex,int1,rect1);
     findbandindex(fmoveindex,int2,rect2);
     int1:= fr^.opos(rect2)-fr^.opos(rect1);
     wi1:= ar1[fsizeindex];
     fw^.setopos(wi1,fw^.opos(wi1)+int1); //shift in new band;
     deleteitem(pointerarty(ar1),fsizeindex);
     insertitem(pointerarty(ar1),fmoveindex,wi1);
     int2:= 0;
     for int1:= 0 to high(ar1) do begin
      fw^.setpos(ar1[int1],int2);
      int2:= int2 + fw^.size(ar1[int1]);
     end;
    end
    else begin
     fw^.setsize(ar1[fsizeindex],fw^.size(ar1[fsizeindex]) + int2); //ev. rest
    end;
   finally
    exclude(fdockstate,dos_updating4);
   end;
  end;
  updaterefsize;
 end;

var
 canvas1: tcanvas;

 procedure dosize;
 begin
  checksizeoffset;
  if high(ar1) > 0 then begin
   calcdelta;
   sizechanged(true);
  end;
 end; //dosize

 procedure setmousebutton(const abutton: dockbuttonrectty);
 begin
  if (widget1.fframe <> nil) and (widget1.fframe is tgripframe) then begin
   with tgripframe(widget1.fframe) do begin
    if abutton <> fmousebutton then begin
     if fmousebutton <> dbr_none then begin
      widget1.invalidaterect(frects[fmousebutton],org_widget);
     end;
     fmousebutton:= abutton;
     if (fmousebutton >= dbr_first) and (fmousebutton <= dbr_last) then begin
      widget1.invalidaterect(frects[fmousebutton],org_widget);
     end;
    end;
    if (abutton <> fclickedbutton) and
      (abutton >= dbr_first) and (abutton <= dbr_last) then begin
     widget1.invalidaterect(frects[abutton],org_widget);
    end;
   end;
  end;
  if (abutton <> fclickedbutton) then begin
   fclickedbutton:= dbr_none;
  end;
 end; //setmousebutton

var
 bu1: dockbuttonrectty;
 i1: int32;

begin
 inherited;
 with info do begin
  if (eventstate * [es_processed] = []) then begin
   canvas1:= nil;
   fixend:= foptionsdock * [od_nofit] <> [];
   widget1:= twidget1(fintf.getwidget);
   po1:= translatewidgetpoint(addpoint(info.pos,widget1.clientwidgetpos),
           widget1,widget1.container); //widget origin
   case info.eventkind of
    ek_mouseleave,ek_clientmouseleave: begin
     setmousebutton(dbr_none);
     if not (ds_clicked in fstate) or
                                  (info.eventkind = ek_mouseleave) then begin
      restorepickshape;
      fsizeindex:= -1;
      if dos_xorpic in fdockstate then begin
       drawxorpic(false,canvas1); //remove pic
      end;
      exclude(fstate,ds_clicked);
      fdockstate:= fdockstate - resetmousedockstate;
      fclickedbutton:= dbr_none;
     end;
    end;
    ek_mousemove: begin
     if fsizeindex < 0 then begin
      if not (csdesigning in widget1.componentstate) then begin
       setmousebutton(checkbuttonarea(pos));
      end;
      checksizing((dos_moving in fdockstate) or
                                    (od_nosplitsize in foptionsdock));
     end
     else begin
      setmousebutton(dbr_none);
      if od_thumbtrack in optionsdock then begin
       if fsplitdir = sd_vert then begin
        fsizeoffset:= pos.x - fpickpos.x;
       end;
       if fsplitdir = sd_horz then begin
        fsizeoffset:= pos.y - fpickpos.y;
       end;
       dosize();
       if fsplitdir = sd_vert then begin
        fpickpos.x:= fpickpos.x+fsizeoffset;
       end;
       if fsplitdir = sd_horz then begin
        fpickpos.y:= fpickpos.y+fsizeoffset;
       end;
      end
      else begin
       if fsplitdir = sd_vert then begin
        drawxorpic(false,canvas1);   //remove pic
        fsizeoffset:= pos.x - fpickpos.x;
        checksizeoffset;
        drawxorpic(true,canvas1);   //draw pic
       end;
       if fsplitdir = sd_horz then begin
        drawxorpic(false,canvas1);  //remove pic
        fsizeoffset:= pos.y - fpickpos.y;
        checksizeoffset;
        drawxorpic(true,canvas1);  //draw pic
       end;
      end;
     end;
    end;
    ek_buttonpress: begin
     fsizeoffset:= 0;
     if shiftstate - [ss_left,ss_shift] = [] then begin
      fsizeindex:= checksizing((ss_shift in shiftstate) or
                                (od_nosplitsize in foptionsdock));
      if fsizeindex >= 0 then begin
       if (ss_shift in shiftstate) or
                  (od_nosplitsize in foptionsdock) then begin
        include(fdockstate,dos_moving);
       end
       else begin
        application.registeronkeypress(@dokeypress);
        exclude(fdockstate,dos_moving);
        if od_thumbtrack in foptionsdock then begin
         setlength(fwidgetrectsbefore,length(fwidgetsbefore));
         for i1:= 0 to high(fwidgetsbefore) do begin
          fwidgetrectsbefore[i1]:= fwidgetsbefore[i1].widgetrect;
         end;
        end;
       end;
       drawxorpic(true,canvas1);
      end;
      if not (ss_shift in shiftstate) then begin
       bu1:= checkbuttonarea(pos);
       setmousebutton(bu1);
       fclickedbutton:= bu1;
      end;
     end;
    end;
    ek_buttonrelease: begin
     endmouseop1();
     if fsizeindex >= 0 then begin
      fwidgetrectsbefore:= nil;
      if od_thumbtrack in foptionsdock then begin
       fsizeoffset:= 0;
      end;
      dosize();
      fsizeindex:= -1;
      fintf.getwidget.invalidate();
      checksizing((dos_moving in fdockstate) or
                         (od_nosplitsize in foptionsdock));
     end
     else begin
      case checkbuttonarea(pos) of
       dbr_close: begin
        if fclickedbutton = dbr_close then begin
         doclose(widget1);
        end;
       end;
       dbr_maximize: mdistate:= mds_maximized;
       dbr_normalize: mdistate:= mds_normal;
       dbr_minimize: mdistate:= mds_minimized;
       dbr_fixsize: begin
        if fclickedbutton = dbr_fixsize then begin
         useroptions:= optionsdockty(
          togglebit({$ifdef FPC}longword{$else}longword{$endif}(fuseroptions),
          ord(od_fixsize)));
         widget1.invalidatewidget;
        end;
       end;
       dbr_float: begin
        if fclickedbutton = dbr_float then begin
         if not (csdesigning in widget1.componentstate) then begin
          dofloat(nullpoint);
         end;
        end;
       end;
       dbr_top: begin
        if fclickedbutton = dbr_top then begin
         useroptions:= optionsdockty(
          togglebit({$ifdef FPC}longword{$else}longword{$endif}(fuseroptions),
          ord(od_top)));
         widget1.invalidatewidget;
        end;
       end;
       dbr_background: begin
        if fclickedbutton = dbr_background then begin
         useroptions:= optionsdockty(
          togglebit({$ifdef FPC}longword{$else}longword{$endif}(fuseroptions),
          ord(od_background)));
         widget1.invalidatewidget;
        end;
       end;
       dbr_lock: begin
        if fclickedbutton = dbr_lock then begin
         useroptions:= optionsdockty(
          togglebit({$ifdef FPC}longword{$else}longword{$endif}(fuseroptions),
          ord(od_lock)));
         widget1.invalidatewidget;
        end;
       end;
       dbr_nolock: begin
        if fclickedbutton = dbr_nolock then begin
         useroptions:= optionsdockty(
          togglebit({$ifdef FPC}longword{$else}longword{$endif}(fuseroptions),
          ord(od_nolock)));
         widget1.invalidatewidget;
        end;
       end;
       else; // Added to make compiler happy
      end;
     end;
     endmouseop2();
    end;
    else; // Added to make compiler happy
   end;
  end;
 end;
end;

procedure tdockcontroller.checkmouseactivate(const sender: twidget;
                                                 var info: mouseeventinfoty);
var
 widget1: twidget;
 pt1: pointty;
begin
 if (info.eventkind = ek_buttonpress) then begin
  if ismdi then begin
   widget1:= fintf.getwidget;
   widget1.bringtofront;
   if ((sender = widget1) or (sender = widget1.container)) and
                  widget1.canfocus and
          not widget1.checkdescendent(widget1.window.focusedwidget)then begin
    pt1:= sender.pos;
    widget1.setfocus;
    application.delayedmouseshift(subpoint(sender.pos,pt1));
               //follow shift in view ???
   end;
  end;
 end;
end;

procedure tdockcontroller.mouseevent(var info: mouseeventinfoty);
begin
 if ismdi then begin
  with twidget1(fintf.getwidget) do begin
   if (fframe is tgripframe) and
                         not (csdesigning in componentstate) then begin
    tgripframe(fframe).mouseevent(info);
   end;
  end;
 end;
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;

procedure tdockcontroller.childormouseevent(const sender: twidget;
               var info: mouseeventinfoty);
begin
 checkmouseactivate(sender,info);
 inherited;
end;

procedure tdockcontroller.widgetregionchanged(const sender: twidget);
begin
 if (sender <> nil) and
         (fdockstate * [dos_updating1,dos_updating2,dos_updating3,dos_updating4,
                       dos_updating5] = []) then begin
  with fintf.getwidget do begin
   if (componentstate * [csloading,csdesigning] = []) and
                        not (ws_destroying in widgetstate) and
     not (ow1_noautosizing in sender.optionswidget1) and
                              not(dos_tabedending in fdockstate)then begin
    include(fdockstate,dos_updating3);
    try
     calclayout(nil,not(ws1_parentupdating in sender.widgetstate1));
     updaterefsize;
    finally
     exclude(fdockstate,dos_updating3);
    end;
   end;
  end;
 end;
end;

procedure tdockcontroller.setcaption(const Value: msestring);
var
 widget1: twidget;
 mstr1: msestring;
begin
 mstr1:= fcaption;
 fcaption:= Value;
 widget1:= fintf.getwidget;
 if not (csdestroying in widget1.componentstate) then begin
  if widget1.ownswindow then begin
   widget1.window.caption:= fcaption;
  end
  else begin
   if istabed and (widget1.parentwidget is tdocktabpage) then begin
    tdocktabpage(widget1.parentwidget).caption:= value;
   end;
  end;
 end;
 if mstr1 <> fcaption then begin
  docaptionchanged;
 end;
end;

procedure tdockcontroller.beginclientrectchanged;
begin
 include(fdockstate,dos_updating1);
end;

procedure tdockcontroller.endclientrectchanged;
begin
 exclude(fdockstate,dos_updating1);
 if (fdockstate * [dos_updating2,dos_updating4] = []) then begin
  sizechanged;
 end
 else begin
  exclude(fdockstate,dos_layoutvalid);
 end;
end;

function tdockcontroller.isfullarea: boolean;
var
 acontroller: tdockcontroller;
begin
 result:= getparentcontroller(acontroller) and
              (acontroller.fsplitdir <> sd_none);
end;

function tdockcontroller.istabed: boolean;
var
 acontroller: tdockcontroller;
begin
 result:= getparentcontroller(acontroller) and
              (acontroller.fsplitdir = sd_tabed);
end;

function tdockcontroller.ismdi: boolean;
var
 acontroller: tdockcontroller;
begin
 result:= (fintf.getwidget.parentwidget <> nil) and
  (fmdistate <> mds_floating) and getparentcontroller(acontroller) and
        (acontroller.fsplitdir = sd_none) and
                 not (dos_tabedending in acontroller.fdockstate);
end;

function tdockcontroller.isfloating: boolean;
begin
 with fintf.getwidget do begin
  result:= (parentwidget = nil) or (csdesigning in componentstate) and
               (parentwidget = owner);
 end;
end;

function tdockcontroller.canmdisize: boolean;
begin
 result:= ismdi and (od_cansize in foptionsdock);
end;

function tdockcontroller.getitems: widgetarty; //reference count = 1
var
 int1: integer;
begin
 if ftabwidget <> nil then begin
  with tdocktabwidget(ftabwidget) do begin
   setlength(result,count);
   for int1:= 0 to high(result) do begin
    result[int1]:= tdocktabpage(items[int1]).ftarget;
   end;
  end;
 end
 else begin
  if fsplitdir = sd_horz then begin
   result:= fintf.getwidget.getsortxchildren();
  end
  else begin
   if fsplitdir = sd_tabed then begin
    result:= nil;
   end
   else begin
    result:= fintf.getwidget.getsortychildren();
   end;
  end;
 end;
end;

procedure tdockcontroller.setmdistate(const avalue: mdistatety);
var
 statebefore: mdistatety;
 rect1: rectty;
 pos1: captionposty;
begin
 if fmdistate <> avalue then begin
  if ismdi then begin
   statebefore:= fmdistate;
   with twidget1(fintf.getwidget) do begin
    if fmdistate = mds_normal then begin
     fnormalrect:= widgetrect;
    end;
    case avalue of
     mds_normal: begin
      fmdistate:= mds_normal;
      anchors:= [an_left,an_top];
      widgetrect:= fnormalrect;
     end;
     mds_minimized: begin
      if canclose(nil) then begin
       fmdistate:= mds_minimized;
       nextfocus;
       with rect1 do begin
        pos:= fnormalrect.pos;
        size:= idockcontroller(fintf).getminimizedsize(pos1);
        if cx = 0 then begin
         cx:= fnormalrect.cx;
        end;
        if cy = 0 then begin
         cy:= fnormalrect.cy;
        end;
        case pos1 of
         cp_right: inc(x,fnormalrect.cx - cx);
         cp_bottom: inc(y,fnormalrect.cy - cy);
         else; // Added to make compiler happy
        end;
       end;
       anchors:= [an_left,an_top];
       widgetrect:= rect1;
      end
      else begin
       exit;
      end;
     end;
     mds_maximized: begin
      fmdistate:= mds_maximized;
      anchors:= [];
     end;
     else; // Added to make compiler happy
    end;
    if (fframe <> nil) then begin
     tcustomframe1(fframe).updatestate;
    end;
    domdistatechanged(statebefore,fmdistate);
   end;
  end
  else begin
   fmdistate:= avalue;
  end;
 end;
end;

function tdockcontroller.placementrect: rectty;
var
 contr1: tdockcontroller;
begin
 if getparentcontroller(contr1) then begin
  result:= idockcontroller(contr1.fintf).getplacementrect;
 end
 else begin
  result:= nullrect;
 end;
end;

procedure tdockcontroller.parentchanged(const sender: twidget);
begin
 exclude(twidget1(sender).fwidgetstate1,ws1_nominsize);
 if not (csloading in sender.componentstate) and
            (twidget1(sender).fframe is tgripframe) then begin
  with tgripframe(twidget1(sender).fframe) do begin
   exclude(fgripstate,grps_sizevalid);
   internalupdatestate;
  end;
 end;
end;

procedure tdockcontroller.poschanged;
var
 pos1: captionposty;
 widget1: twidget;
begin
 if ismdi then begin
  widget1:= fintf.getwidget;
  case fmdistate of
   mds_normal: begin
    fnormalrect:= widget1.widgetrect;
   end;
   mds_minimized: begin
    idockcontroller(fintf).getminimizedsize(pos1);
    with widget1 do begin
     case pos1 of
      cp_left,cp_top: begin
       fnormalrect.pos:= pos;
      end;
      cp_right: begin
       fnormalrect.y:= bounds_y;
       fnormalrect.x:= bounds_x + bounds_cx - fnormalrect.cx;
      end;
      cp_bottom: begin
       fnormalrect.x:= bounds_x;
       fnormalrect.y:= bounds_y + bounds_cy - fnormalrect.cy;
      end;
      else; // Added to make compiler happy
     end;
    end;
   end;
   else; // Added to make compiler happy
  end;
 end;
end;

procedure tdockcontroller.statechanged(const astate: widgetstatesty);
var
 dock1: tdockcontroller;
begin
 if getparentcontroller(dock1) then begin
  dock1.childstatechanged(fintf.getwidget(),astate,fwidgetstate);
 end;
 fwidgetstate:= astate;
end;

procedure tdockcontroller.settab_options(const avalue: tabbaroptionsty);
begin
 ftab_options:= avalue;
 if ftabwidget <> nil then begin
  tdocktabwidget(ftabwidget).updateoptions;
 end;
end;

procedure tdockcontroller.settab_color(const avalue: colorty);
begin
 ftab_color:= avalue;
 if ftabwidget <> nil then begin
  tdocktabwidget(ftabwidget).updateoptions;
 end;
end;

procedure tdockcontroller.settab_colortab(const avalue: colorty);
begin
 ftab_colortab:= avalue;
 if ftabwidget <> nil then begin
  tdocktabwidget(ftabwidget).updateoptions;
 end;
end;

procedure tdockcontroller.settab_coloractivetab(const avalue: colorty);
begin
 ftab_coloractivetab:= avalue;
 if ftabwidget <> nil then begin
  tdocktabwidget(ftabwidget).updateoptions;
 end;
end;

procedure tdockcontroller.settab_size(const avalue: integer);
begin
 ftab_size:= avalue;
 if ftabwidget <> nil then begin
  tdocktabwidget(ftabwidget).updateoptions;
 end;
end;

procedure tdockcontroller.settab_sizemin(const avalue: integer);
begin
 ftab_sizemin:= avalue;
 if ftabwidget <> nil then begin
  tdocktabwidget(ftabwidget).updateoptions;
 end;
end;

procedure tdockcontroller.settab_sizemax(const avalue: integer);
begin
 ftab_sizemax:= avalue;
 if ftabwidget <> nil then begin
  tdocktabwidget(ftabwidget).updateoptions;
 end;
end;

procedure tdockcontroller.settab_textflags(const avalue: textflagsty);
begin
 ftab_textflags:= avalue;
 if ftabwidget <> nil then begin
  tdocktabwidget(ftabwidget).updateoptions;
 end;
end;

procedure tdockcontroller.settab_width(const avalue: integer);
begin
 ftab_width:= avalue;
 if ftabwidget <> nil then begin
  tdocktabwidget(ftabwidget).updateoptions;
 end;
end;

procedure tdockcontroller.settab_widthmin(const avalue: integer);
begin
 ftab_widthmin:= avalue;
 if ftabwidget <> nil then begin
  tdocktabwidget(ftabwidget).updateoptions;
 end;
end;

procedure tdockcontroller.settab_widthmax(const avalue: integer);
begin
 ftab_widthmax:= avalue;
 if ftabwidget <> nil then begin
  tdocktabwidget(ftabwidget).updateoptions;
 end;
end;

procedure tdockcontroller.settab_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftab_frame));
 if ftabwidget <> nil then begin
  tdocktabwidget(ftabwidget).updateoptions;
 end;
end;

procedure tdockcontroller.settab_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftab_face));
 if ftabwidget <> nil then begin
  tdocktabwidget(ftabwidget).updateoptions;
 end;
end;

procedure tdockcontroller.settab_facetab(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftab_facetab));
 if ftabwidget <> nil then begin
  tdocktabwidget(ftabwidget).updateoptions;
 end;
end;

procedure tdockcontroller.settab_faceactivetab(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftab_faceactivetab));
 if ftabwidget <> nil then begin
  tdocktabwidget(ftabwidget).updateoptions;
 end;
end;

procedure tdockcontroller.settab_frametab(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(ftab_frametab));
 if ftabwidget <> nil then begin
  tdocktabwidget(ftabwidget).updateoptions;
 end;
end;

function tdockcontroller.getactivetabpage: ttabpage;
begin
 result:= nil;
 if ftabwidget <> nil then begin
  result:= ttabpage(ftabwidget.activepage);
 end;
end;

procedure tdockcontroller.setcolortab(const avalue: colorty);
begin
 if fcolortab <> avalue then begin
  fcolortab:= avalue;
  if ftabpage <> nil then begin
   ftabpage.colortab:= fcolortab;
  end;
 end;
end;

procedure tdockcontroller.setcoloractivetab(const avalue: colorty);
begin
 if fcoloractivetab <> avalue then begin
  fcoloractivetab:= avalue;
  if ftabpage <> nil then begin
   ftabpage.coloractivetab:= fcoloractivetab;
  end;
 end;
end;

procedure tdockcontroller.setfacetab(const avalue: tfacecomp);
begin
 if ffacetab <> avalue then begin
  setlinkedvar(avalue,tmsecomponent(ffacetab));
  if ftabpage <> nil then begin
   ftabpage.facetab:= ffacetab;
  end;
 end;
end;

procedure tdockcontroller.setfaceactivetab(const avalue: tfacecomp);
begin
 if ffaceactivetab <> avalue then begin
  setlinkedvar(avalue,tmsecomponent(ffaceactivetab));
  if ftabpage <> nil then begin
   ftabpage.faceactivetab:= ffaceactivetab;
  end;
 end;
end;

procedure tdockcontroller.objectevent(const sender: tobject;
               const event: objecteventty);
begin
 inherited;
 if (event = oe_changed) and (ftabwidget <> nil) then begin
  tdocktabwidget(ftabwidget).updateoptions;
 end;
end;

procedure tdockcontroller.dolayoutchanged;
var
 widget1: twidget;
 intf1: idocktarget;
begin
 idockcontroller(fintf).dolayoutchanged(self);
 widget1:= fintf.getwidget;
 if widget1.canevent(tmethod(fonlayoutchanged)) then begin
  fonlayoutchanged(self);
 end;
 widget1:= widget1.parentwidget;
 while widget1 <> nil do begin
  if widget1.getcorbainterface(typeinfo(idocktarget),intf1) then begin
   intf1.getdockcontroller.dolayoutchanged;
   break;
  end;
  widget1:= widget1.parentwidget;
 end;
 doboundschanged;
end;

procedure tdockcontroller.doboundschanged;
var
 widget1: twidget;
begin
 widget1:= fintf.getwidget;
 if widget1.canevent(tmethod(fonboundschanged)) and
                                      not application.terminated then begin
  fonboundschanged(self);
 end;
end;

procedure tdockcontroller.docaptionchanged;
var
 widget1: twidget;
 intf1: idocktarget;
begin
 idockcontroller(fintf).dodockcaptionchanged(self);
 widget1:= fintf.getwidget;
 if widget1.canevent(tmethod(foncaptionchanged)) then begin
  foncaptionchanged(self);
 end;
 widget1:= widget1.parentwidget;
 while widget1 <> nil do begin
  if widget1.getcorbainterface(typeinfo(idocktarget),intf1) then begin
   intf1.getdockcontroller.docaptionchanged;
   break;
  end;
  widget1:= widget1.parentwidget;
 end;
end;


function tdockcontroller.getwidget: twidget;
begin
 result:= fintf.getwidget;
end;

function tdockcontroller.activewidget: twidget; //focused child or active tab
var
 tab1: tdocktabpage;
begin
 result:= nil;
 if ftabwidget <> nil then begin
  tab1:= tdocktabpage(tdocktabwidget(ftabwidget).activepage);
  if tab1 <> nil then begin
   result:= tab1.ftarget;
  end;
 end
 else begin
  result:= fintf.getwidget.enteredchild;
 end;
end;

function tdockcontroller.dockparentname(): string;
var
 parent: tdockcontroller;
begin
 result:= '';
 if getparentcontroller(parent) then begin
  result:= parent.getwidget.name;
 end;
end;

function tdockcontroller.childicon(): tmaskedbitmap;

 function check(const awidget: twidget; var res: tmaskedbitmap): boolean;
 var
  intf1: idockcontroller;
 begin
  result:= false;
  if getcorbainterface(awidget,typeinfo(idockcontroller),intf1) then begin
   res:= intf1.getchildicon();
   if (res <> nil) and res.hasimage() then begin
    result:= true;
   end;
  end;
 end; //check

var
 ar1: widgetarty;
 i1: int32;
begin
 if not check(activewidget,result) then begin
  ar1:= getitems;
  result:= nil;
  for i1:= 0 to high(ar1) do begin
   if check(ar1[i1],result) then begin
    break;
   end;
  end;
 end;
end;

function tdockcontroller.close: boolean; //simulates mr_windowclosed for owner
begin
 result:= doclose(fintf.getwidget);
end;

function tdockcontroller.closeactivewidget: boolean;
                   //simulates mr_windowclosed for active widget, true if ok
begin
 result:= doclose(activewidget);
end;

function tdockcontroller.checkclickstate(const info: mouseeventinfoty): boolean;
begin
 if od_nofit in foptionsdock then begin
  result:= info.shiftstate - [ss_left,ss_shift] = [];
 end
 else begin
  result:= info.shiftstate - [ss_left] = [];
 end;
end;

procedure tdockcontroller.dokeypress(const sender: twidget;
               var info: keyeventinfoty);
begin
 if (info.key = key_escape) and (fsizeindex >= 0) then begin
  include(info.eventstate,es_processed);
  cancelsizing();
 end;
 inherited;
end;

procedure tdockcontroller.setsplitdir(const avalue: splitdirty);
begin
 if avalue <> fdefaultsplitdir then begin
  fdefaultsplitdir:= avalue;
  if (avalue <> sd_none) and
              not (csloading in fintf.getwidget.componentstate) then begin
   fasplitdir:= avalue;
   checksplitdir(fasplitdir);
   if (fasplitdir <> sd_none) then begin
    calclayout(nil,false);
   end;
  end;
 end;
end;

procedure tdockcontroller.setcurrentsplitdir(const avalue: splitdirty);
begin
 if (avalue <> sd_none) and (avalue <> fsplitdir) then begin
  fasplitdir:= avalue;
  calclayout(nil,false);
 end;
end;

function tdockcontroller.getdockrect: rectty;
var
 w1: twidget;
begin
 if (ftabwidget <> nil) and
                 (tdocktabwidget(ftabwidget).activepage <> nil) then begin
  w1:= tdocktabwidget(ftabwidget).activepage.container;
  result:= w1.paintrect;
  translatewidgetpoint1(result.pos,w1,getwidget().container);
 end
 else begin
  result:= idockcontroller(fintf).getplacementrect(); //origin container.pos
 end;
end;

procedure tdockcontroller.receiveevent(const aevent: tobjectevent);
var
 int1: integer;
 ar1: widgetarty;
 widget1: twidget;
begin
 if aevent is tchildorderevent then begin
  with tchildorderevent(aevent) do begin
   setlength(ar1,length(fchildren));
   widget1:= fintf.getwidget;
   for int1:= 0 to high(fchildren) do begin
    ar1[int1]:= widget1.findchild(fchildren[int1]);
   end;
   if (ffocusedchild >= 0) and (ffocusedchild <= high(ar1)) and
       (ar1[ffocusedchild] <> nil) and ar1[ffocusedchild].canfocus then begin
    ar1[ffocusedchild].setfocus(false);
   end;
   widget1.setchildorder(ar1);
  end;
 end
 else begin
  inherited;
 end;
end;

{ tnochildrendockcontroller }

constructor tnochildrendockcontroller.create(aintf: idockcontroller);
begin
 inherited;
 foptionsdock:= defaultoptionsdocknochildren;
end;

{ tgripframe }

constructor tgripframe.create(const aintf: icaptionframe;
                       const acontroller: tdockcontroller);
begin
 fgrip_color:= defaultgripcolor;
 fgrip_coloractive:= defaultgripcoloractive;
 fgrip_colorglyph:= cl_glyph;
 fgrip_colorglyphactive:= cl_glyphactive;
 fgrip_colorbutton:= cl_transparent;
 fgrip_colorbuttonactive:= cl_transparent;
 fgrip_size:= defaultgripsize;
 fgrip_pos:= defaultgrippos;
 fgrip_grip:= defaultgripgrip;
 fgrip_options:= defaultgripoptions;
 fgrip_textflagstop:= defaulttextflagstop;
 fgrip_textflagsleft:= defaulttextflagsleft;
 fgrip_textflagsbottom:= defaulttextflagsbottom;
 fgrip_textflagsright:= defaulttextflagsright;
 fgrip_captiondist:= 1;
 fcontroller:= acontroller;
 inherited create(aintf);
 fobjectpicker:= tobjectpicker.create(iobjectpicker(self));
end;

destructor tgripframe.destroy;
begin
 fobjectpicker.free;
 fgrip_face.free;
 fgrip_faceactive.free;
 inherited;
end;

procedure tgripframe.checktemplate(const sender: tobject);
begin
 inherited;
 if fgrip_face <> nil then begin
  fgrip_face.checktemplate(sender);
 end;
 if fgrip_faceactive <> nil then begin
  fgrip_faceactive.checktemplate(sender);
 end;
end;

procedure tgripframe.showhint(const aid: int32; var info: hintinfoty);
begin
 case dockbuttonrectty(-(aid - hintidframe)) of
  dbr_handle: begin
   if fgrip_hint = '' then begin
    info.caption:= fcontroller.getfloatcaption;
   end
   else begin
    info.caption:= fgrip_hint;
   end;
  end;
{$ifdef mse_dynpo}
  dbr_close: begin
   info.caption:= lang_stockcaption[ord(sc_close)];
  end;
  dbr_maximize: begin
   info.caption:= lang_stockcaption[ord(sc_maximize)];
  end;
  dbr_normalize: begin
   info.caption:= lang_stockcaption[ord(sc_normalize)];
  end;
  dbr_minimize: begin
   info.caption:= lang_stockcaption[ord(sc_minimize)];
  end;
  dbr_fixsize: begin
   info.caption:= lang_stockcaption[ord(sc_fix_size)];
  end;
  dbr_float: begin
   info.caption:= lang_stockcaption[ord(sc_float)];
  end;
  dbr_top: begin
   info.caption:= lang_stockcaption[ord(sc_stay_on_top)];
  end;
  dbr_background: begin
   info.caption:= lang_stockcaption[ord(sc_stay_in_background)];
  end;
  dbr_lock: begin
   info.caption:= lang_stockcaption[ord(sc_lock_children)];
  end;
  dbr_nolock: begin
   info.caption:= lang_stockcaption[ord(sc_no_lock)];
{$else}
  dbr_close: begin
   info.caption:= sc(sc_close);
  end;
  dbr_maximize: begin
   info.caption:= sc(sc_maximize);
  end;
  dbr_normalize: begin
   info.caption:= sc(sc_normalize);
  end;
  dbr_minimize: begin
   info.caption:= sc(sc_minimize);
  end;
  dbr_fixsize: begin
   info.caption:= sc(sc_fix_size);
  end;
  dbr_float: begin
   info.caption:= sc(sc_float);
  end;
  dbr_top: begin
   info.caption:= sc(sc_stay_on_top);
  end;
  dbr_background: begin
   info.caption:= sc(sc_stay_in_background);
  end;
  dbr_lock: begin
   info.caption:= sc(sc_lock_children);
  end;
  dbr_nolock: begin
   info.caption:= sc(sc_no_lock);
{$endif}

  end;
  else; // Added to make compiler happy
 end;
end;

procedure tgripframe.drawgripbutton(const acanvas: tcanvas;
               const akind: dockbuttonrectty; const arect: rectty;
               const acolorglyph: colorty; const acolorbutton: colorty;
                                               const ahiddenedges: edgesty);

var
 hiddenedges1: edgesty;

 function calclevel(const aoption: optiondockty): integer;
 begin
  if (ord(aoption) >= 0) and ((aoption in fcontroller.foptionsdock) or
                      (fcontroller.fclickedbutton = akind)) then begin
   result:= -1;
   hiddenedges1:= []
  end
  else begin
   result:= 1;
  end;
 end;

var
 rect2: rectty;
 int1: integer;
 i1: int32;
begin
 if akind = fmousebutton then begin
  hiddenedges1:= [];
 end
 else begin
  hiddenedges1:= ahiddenedges;
 end;
 with acanvas,arect do begin
  fillrect(arect,acolorbutton);
  // i1:= calclevel(optiondockty(-1));
  i1:= 1;
  case akind of
   dbr_close: begin
    if factgripsize >= 8 then begin
     draw3dframe(acanvas,arect,i1,defaultframecolors.edges,hiddenedges1);
     drawcross(inflaterect(arect,-2),acolorglyph);
    end
    else begin
     drawcross(arect,acolorglyph);
    end;
   end;
   dbr_maximize: begin
    draw3dframe(acanvas,arect,i1,defaultframecolors.edges,hiddenedges1);
    drawframe(inflaterect(arect,-2),-1,acolorglyph);
    drawvect(makepoint(x+2,y+3),gd_right,cx-5,acolorglyph);
   end;
   dbr_normalize: begin
    draw3dframe(acanvas,arect,i1,defaultframecolors.edges,hiddenedges1);
    rect2.cx:= cx * 2 div 3 - 3;
    rect2.cy:= rect2.cx;
    rect2.pos:= addpoint(pos,makepoint(2,2));
    drawrect(rect2,acolorglyph);
    rect2.x:= x + cx - 3 - rect2.cx;
    rect2.y:= y + cy - 3 - rect2.cy;
    drawrect(rect2,acolorglyph);
   end;
   dbr_minimize: begin
    draw3dframe(acanvas,arect,i1,defaultframecolors.edges,hiddenedges1);
    acanvas.move(pos);
    case fgrip_pos of
     cp_left: begin
      drawvect(makepoint(2,2),gd_down,cy-5,acolorglyph);
      drawvect(makepoint(3,2),gd_down,cy-5,acolorglyph);
     end;
     cp_right: begin
      drawvect(makepoint(cx-3,2),gd_down,cy-5,acolorglyph);
      drawvect(makepoint(cx-4,2),gd_down,cy-5,acolorglyph);
     end;
     cp_bottom: begin
      drawvect(makepoint(2,cy-3),gd_right,cx-5,acolorglyph);
      drawvect(makepoint(2,cy-4),gd_right,cx-5,acolorglyph);
     end;
     else begin //cp_top
      drawvect(makepoint(2,2),gd_right,cx-5,acolorglyph);
      drawvect(makepoint(2,3),gd_right,cx-5,acolorglyph);
     end;
    end;
    acanvas.remove(pos);
   end;
   dbr_fixsize: begin
    i1:= calclevel(od_fixsize);
    draw3dframe(acanvas,arect,i1,defaultframecolors.edges,hiddenedges1);
    drawframe(inflaterect(arect,-2),-1,acolorglyph);
   end;
   dbr_float: begin
    draw3dframe(acanvas,arect,i1,defaultframecolors.edges,hiddenedges1);
    int1:= cx div 2;
    acanvas.move(pos);
    drawlines([mp(2,int1),mp(2,2),mp(int1,2)],false,acolorglyph);
    drawline(mp(cx-3,cy-3),mp(2,2),acolorglyph);
    acanvas.remove(pos);
   end;
   dbr_top: begin
    int1:= x + cx div 2;
    i1:= calclevel(od_top);
    draw3dframe(acanvas,arect,i1,defaultframecolors.edges,hiddenedges1);
    drawlines([makepoint(int1-3,y+4),makepoint(int1,y+1),
                     makepoint(int1,y+cy-1)],false,acolorglyph);
    drawline(makepoint(int1+3,y+4),makepoint(int1,y+1),acolorglyph);
   end;
   dbr_background: begin
    int1:= x + cx div 2;
    i1:= calclevel(od_background);
    draw3dframe(acanvas,arect,i1,defaultframecolors.edges,hiddenedges1);
    drawlines([makepoint(int1-3,y+cx-4),makepoint(int1,y+cy-1),
                                     makepoint(int1,y+1)],false,acolorglyph);
    drawline(makepoint(int1+3,y+cx-4),makepoint(int1,y+cy-1),acolorglyph);
   end;
   dbr_lock: begin
    i1:= calclevel(od_lock);
    draw3dframe(acanvas,arect,i1,defaultframecolors.edges,hiddenedges1);
    drawellipse1(makerect(arect.x+2,arect.y+2,arect.cx-5,arect.cy-5),
                                                               acolorglyph);
   end;
   dbr_nolock: begin
    i1:= calclevel(od_nolock);
    draw3dframe(acanvas,arect,i1,defaultframecolors.edges,hiddenedges1);
    fillellipse1(makerect(arect.x+2,arect.y+2,arect.cx-5,arect.cy-5),
                                                               acolorglyph);
    drawellipse1(makerect(arect.x+2,arect.y+2,arect.cx-5,arect.cy-5),
                                                               acolorglyph);
   end;
   else; // Added to make compiler happy
  end;
 end;
end;

procedure tgripframe.internalpaintoverlay(const canvas: tcanvas;
                                                      const arect: rectty);

var
// brushbefore: tsimplebitmap;
// colorbefore: colorty;
 po1,po2: pointty;
 int1,int2: integer;
 rect1: rectty;
 col1: colorty;
 info1: drawtextinfoty;
 floating: boolean;
 colorbutton,colorglyph: colorty;
 bo1: boolean;
 dirbefore: graphicdirectionty;
 face1: tface1;
 isactive: boolean;
label
 endlab;
begin
 inherited;
 dirbefore:= gd_none;
 checkstate;
 checkgripsize;
 with canvas do begin
  rect1:= clipbox;
  if testintersectrect(rect1,fgriprect) then begin
   isactive:= fintf.getwidget.active;
   rect1:= frects[dbr_handle];
   info1.text.text:= fcontroller.caption;
   floating:= fcontroller.isfloating;
   face1:= tface1(fgrip_face);
   if isactive and (fgrip_faceactive <> nil) then begin
    face1:= tface1(fgrip_faceactive);
   end;

   if face1 <> nil then begin
    bo1:= fgrip_pos in [cp_left,cp_right];
    if bo1 then begin
     with face1.fi do begin
      dirbefore:= fade_direction;
      fade_direction:= graphicdirectionty((ord(fade_direction) + 1) and 3);
     end;
    end;
    face1.paint(canvas,rect1);
    if bo1 then begin
     with face1.fi do begin
      fade_direction:= dirbefore;
     end;
    end;
   end;
   canvas.save();
   if isactive then begin
    colorbutton:= fgrip_colorbuttonactive;
    colorglyph:= fgrip_colorglyphactive;
   end
   else begin
    colorbutton:= fgrip_colorbutton;
    colorglyph:= fgrip_colorglyph;
   end;
   if go_closebutton in fgrip_options then begin
    drawgripbutton(canvas,dbr_close,frects[dbr_close],colorglyph,colorbutton,
                                    fedges[dbr_close]);
   end;
   if (frects[dbr_maximize].cx > 0) and
           (go_maximizebutton in fgrip_options) then begin
    drawgripbutton(canvas,dbr_maximize,frects[dbr_maximize],colorglyph,
                           colorbutton,fedges[dbr_maximize]);
   end;
   if (frects[dbr_normalize].cx > 0) and
                           (go_normalizebutton in fgrip_options) then begin
    drawgripbutton(canvas,dbr_normalize,frects[dbr_normalize],colorglyph,
                            colorbutton,fedges[dbr_normalize]);
   end;
   if (frects[dbr_minimize].cx > 0) and
                           (go_minimizebutton in fgrip_options) then begin
    drawgripbutton(canvas,dbr_minimize,frects[dbr_minimize],colorglyph,
                           colorbutton,fedges[dbr_minimize]);
   end;
   if (frects[dbr_fixsize].cx > 0) and
                           (go_fixsizebutton in fgrip_options) then begin
    drawgripbutton(canvas,dbr_fixsize,frects[dbr_fixsize],colorglyph,
                          colorbutton,fedges[dbr_fixsize]);
   end;
   if (frects[dbr_float].cx > 0) and
                           (go_floatbutton in fgrip_options) then begin
    drawgripbutton(canvas,dbr_float,frects[dbr_float],colorglyph,colorbutton,
                                    fedges[dbr_float]);
   end;
   if (frects[dbr_top].cx > 0) and
                           (go_topbutton in fgrip_options)  then begin
    drawgripbutton(canvas,dbr_top,frects[dbr_top],colorglyph,colorbutton,
                                  fedges[dbr_top]);
   end;
   if (frects[dbr_background].cx > 0) and
                           (go_backgroundbutton in fgrip_options) then begin
    drawgripbutton(canvas,dbr_background,frects[dbr_background],colorglyph,
                             colorbutton,fedges[dbr_background]);
   end;
   if (frects[dbr_lock].cx > 0) and
                           (go_lockbutton in fgrip_options) then begin
    drawgripbutton(canvas,dbr_lock,frects[dbr_lock],colorglyph,colorbutton,
                                   fedges[dbr_lock]);
   end;
   if (frects[dbr_nolock].cx > 0) and
                           (go_nolockbutton in fgrip_options) then begin
    drawgripbutton(canvas,dbr_nolock,frects[dbr_nolock],colorglyph,
                         colorbutton,fedges[dbr_nolock]);
   end;
   if (info1.text.text <> '') and
     (not floating and (go_showsplitcaption in fgrip_options) or
     floating and (go_showfloatcaption in fgrip_options) or
                                                fcontroller.ismdi) then begin
    with info1 do begin
     text.format:= nil;
     dest:= rect1;
     clip:= rect1;
     font:= self.font;
     tabulators:= nil;
     case fgrip_pos of
      cp_top: begin
       flags:= fgrip_textflagstop;
       if not ((tf_right in flags) xor (tf_rotate180 in flags)) then begin
        inc(dest.x,fgrip_captiondist);
       end;
       if not (tf_xcentered in flags) then begin
        dec(dest.cx,fgrip_captiondist);
       end;
       inc(dest.y,fgrip_captionoffset);
       if tf_clipi in flags then begin
        clip.y:= -1000; //no vertical clip
        clip.cy:= 2000;
       end;
      end;
      cp_left: begin
       flags:= fgrip_textflagsleft;
       if (tf_right in flags) xor (tf_rotate180 in flags) then begin
        inc(dest.y,fgrip_captiondist);
       end
       else begin
        dec(dest.cy,fgrip_captiondist);
        if tf_xcentered in flags then begin
         dec(dest.y,fgrip_captiondist);
        end;
       end;
       inc(dest.x,fgrip_captionoffset);
       if tf_clipi in flags then begin
        clip.x:= -1000; //no horicontal clip
        clip.cx:= 2000;
       end;
      end;
      cp_bottom: begin
       flags:= fgrip_textflagsbottom;
       if not ((tf_right in flags)  xor (tf_rotate180 in flags))then begin
        inc(dest.x,fgrip_captiondist);
       end;
       if not (tf_xcentered in flags) then begin
        dec(dest.cx,fgrip_captiondist);
       end;
       dec(dest.y,fgrip_captionoffset);
       if tf_clipi in flags then begin
        clip.y:= -1000; //no vertical clip
        clip.cy:= 2000;
       end;
      end;
      cp_right: begin
       flags:= fgrip_textflagsright;
       if (tf_right in flags) xor (tf_rotate180 in flags) then begin
        inc(dest.y,fgrip_captiondist);
       end
       else begin
        dec(dest.cy,fgrip_captiondist);
        if tf_xcentered in flags then begin
         dec(dest.y,fgrip_captiondist);
        end;
       end;
       dec(dest.x,fgrip_captionoffset);
       if tf_clipi in flags then begin
        clip.x:= -1000; //no horicontal clip
        clip.cx:= 2000;
       end;
      end;
      else; // Added to make compiler happy
     end;
     drawtext(canvas,info1);
     canvas.subcliprect(inflaterect(info1.res,1));
    end;
   end;
   if fgrip_grip = stb_none then begin
    if fintf.getwidget.active then begin
     col1:= fgrip_coloractive;
    end
    else begin
     col1:=  cl_shadow;
    end;
    with rect1 do begin
     int1:= factgripsize div 4;
     int2:= (factgripsize mod 4) div 2;
     if fgrip_pos in [cp_left,cp_right] then begin
      if cy > 4 then begin
       po1.x:= x + int2;
       po1.y:= y + 2;
       po2.x:= po1.x;
       po2.y:= y + cy - 3;
       for int2:= 1 to int1 do begin
        drawline(po1,po2,cl_highlight);
        inc(po1.x,2);
        inc(po2.x,2);
        drawline(po1,po2,col1);
        inc(po1.x,2);
        inc(po2.x,2);
       end;
      end;
     end
     else begin
      if cy > 4 then begin
       po1.y:= y + int2;
       po1.x:= x + 2;
       po2.y:= po1.y;
       po2.x:= x + cx - 3;
       for int2:= 1 to int1 do begin
        drawline(po1,po2,cl_highlight);
        inc(po1.y,2);
        inc(po2.y,2);
        drawline(po1,po2,col1);
        inc(po1.y,2);
        inc(po2.y,2);
       end;
      end;
     end;
    end;
   end
   else begin
//    brushbefore:= brush;
    brush:= stockobjects.bitmaps[fgrip_grip];
    if fintf.getwidget.active then begin
     color:= fgrip_coloractive;
    end
    else begin
     color:= fgrip_color;
    end;
    fillrect(rect1,cl_brushcanvas);
//    brush:= brushbefore;
 //  stockobjects.bitmaps[fgrip_grip].paint(canvas,fhandlerect,
 //         [al_xcentered,al_ycentered,al_tiled],fgrip_color,cl_transparent);
   end;
endlab:
   canvas.restore;//color:= colorbefore;
  end;
 end;
end;

function tgripframe.getbuttonrects(const index: dockbuttonrectty): rectty;
begin
 if (index >= dbr_first) and (index <= dbr_last) then begin
  if index = dbr_handle then begin
   result:= fgriprect;
  end
  else begin
   result:= frects[index];
  end;
  dec(result.x,fpaintrect.x+fclientrect.x);
  dec(result.y,fpaintrect.y+fclientrect.y);
 end
 else begin
  result:= nullrect;
 end;
end;

function tgripframe.getminimizedsize(out apos: captionposty): sizety;
begin
 checkstate;
 if fgrip_pos in [cp_right,cp_left] then begin
  result.cy:= 0;
  result.cx:= fpaintframe.left + fpaintframe.right;
 end
 else begin
  result.cx:= 0;
  result.cy:= fpaintframe.top + fpaintframe.bottom;;
 end;
 apos:= fgrip_pos;
end;

procedure tgripframe.getpaintframe(var frame: framety);
begin
 inherited;
 checkgripsize;
 case fgrip_pos of
  cp_right: inc(frame.right,factgripsize);
  cp_top: inc(frame.top,factgripsize);
  cp_bottom: inc(frame.bottom,factgripsize);
  else inc(frame.left,factgripsize);
 end;
end;

procedure tgripframe.setgrip_color(const avalue: colorty);
begin
 if fgrip_color <> avalue then begin
  fgrip_color := avalue;
  fintf.invalidatewidget;
 end;
end;

procedure tgripframe.setgrip_coloractive(const avalue: colorty);
begin
 if fgrip_coloractive <> avalue then begin
  fgrip_coloractive:= avalue;
  fintf.invalidatewidget;
 end;
end;

procedure tgripframe.setgrip_grip(const avalue: stockbitmapty);
begin
 if fgrip_grip <> avalue then begin
  fgrip_grip:= avalue;
  fintf.invalidatewidget;
 end;
end;

procedure tgripframe.setgrip_size(const avalue: integer);
begin
 if fgrip_size <> avalue then begin
  fgrip_size:= avalue;
  exclude(fgripstate,grps_sizevalid);
  internalupdatestate;
 end;
end;

procedure tgripframe.setgrip_options(avalue: gripoptionsty);
const
 amask: gripoptionsty = [go_horz,go_vert];
begin
 avalue:= gripoptionsty(setsinglebit(
              {$ifdef FPC}longword{$else}word{$endif}(avalue),
              {$ifdef FPC}longword{$else}word{$endif}(fgrip_options),
              {$ifdef FPC}longword{$else}word{$endif}(amask)));
 if fgrip_options <> avalue then begin
  if go_floatbutton in avalue then begin
   include(fcontroller.fdockstate,dos_hasfloatbutton);
  end
  else begin
   exclude(fcontroller.fdockstate,dos_hasfloatbutton);
  end;
  fgrip_options:= avalue;
  internalupdatestate;
 end;
end;

procedure tgripframe.setgrip_colorglyph(const avalue: colorty);
begin
 if fgrip_colorglyph <> avalue then begin
  fgrip_colorglyph := avalue;
  internalupdatestate;
 end;
end;

procedure tgripframe.setgrip_colorglyphactive(const avalue: colorty);
begin
 if fgrip_colorglyphactive <> avalue then begin
  fgrip_colorglyphactive := avalue;
  internalupdatestate;
 end;
end;

procedure tgripframe.setgrip_colorbutton(const avalue: colorty);
begin
 if fgrip_colorbutton <> avalue then begin
  fgrip_colorbutton := avalue;
  internalupdatestate;
 end;
end;

procedure tgripframe.setgrip_colorbuttonactive(const avalue: colorty);
begin
 if fgrip_colorbuttonactive <> avalue then begin
  fgrip_colorbuttonactive := avalue;
  internalupdatestate;
 end;
end;

procedure tgripframe.checkgripsize;
var
 parentcontroller: tdockcontroller;
begin
 if not (grps_sizevalid in fgripstate) then begin
  factgripsize:= fgrip_size;
  if not (od_nolock in fcontroller.foptionsdock) and
              fcontroller.getparentcontroller(parentcontroller) and
                                         parentcontroller.nogrip then begin
   factgripsize:= 0;
  end;
  include(fgripstate,grps_sizevalid);
 end;
end;

procedure tgripframe.updaterects;

var
 firstbu,lastbu: dockbuttonrectty;

 procedure initrect(const index: dockbuttonrectty);
 begin
  if firstbu = dbr_none then begin
   firstbu:= index;
  end;
  lastbu:= index;
  with frects[dbr_handle] do begin
   case fgrip_pos of
    cp_right,cp_left: begin
     frects[index].x:= x;
     frects[index].y:= y;
     inc(y,factgripsize);
     dec(cy,factgripsize);
     fedges[index]:= [edg_top,edg_bottom];
    end;
    else begin //top,bottom
     dec(cx,factgripsize);
     frects[index].x:= x + cx;
     frects[index].y:= y;
     fedges[index]:= [edg_left,edg_right];
    end;
   end;
  end;
  if go_buttonframe in fgrip_options then begin
   fedges[index]:= [];
  end;
  with frects[index] do begin
   cx:= factgripsize;
   cy:= factgripsize;
  end;
 end;

var
 bo1,bo2,bo3,designing: boolean;
 parentcontroller: tdockcontroller;

begin         //widget origin
 inherited;
 firstbu:= dbr_none;
 checkgripsize;
 with fgriprect do begin
  case fgrip_pos of
   cp_right: begin
    x:= fpaintrect.x + fpaintrect.cx;
    y:= fpaintrect.y;
    cx:= factgripsize;
    cy:= fpaintrect.cy;
   end;
   cp_left: begin
    x:= fpaintrect.x - factgripsize;
    y:= fpaintrect.y;
    cx:= factgripsize;
    cy:= fpaintrect.cy;
   end;
   cp_top: begin
    x:= fpaintrect.x;
    y:= fpaintrect.y - factgripsize;
    cx:= fpaintrect.cx;
    cy:= factgripsize;
   end;
   else begin //cp_bottom
    x:= fpaintrect.x;
    y:= fpaintrect.y + fpaintrect.cy;
    cx:= fpaintrect.cx;
    cy:= factgripsize;
   end;
  end;
 end;
 with fintf.getwidget do begin
  fillchar(frects,sizeof(frects),0);
  frects[dbr_handle]:= fgriprect;
  designing:= csdesigning in componentstate;
  bo1:= (parentwidget <> nil) and (fcontroller.fmdistate <> mds_floating) or
                                 designing;
  bo3:= fcontroller.isfullarea;
  bo2:= not bo3 or designing;
  if bo1 and (go_closebutton in fgrip_options) then begin
   initrect(dbr_close);
  end;
  if fcontroller.ismdi or designing then begin
   if (go_maximizebutton in fgrip_options) and
             ((fcontroller.mdistate <> mds_maximized) or designing) then begin
    initrect(dbr_maximize);
   end;
   if (go_normalizebutton in fgrip_options) and
           ((fcontroller.mdistate <> mds_normal) or designing) then begin
    initrect(dbr_normalize);
   end;
   if (go_minimizebutton in fgrip_options) and
        ((fcontroller.mdistate <> mds_minimized) or designing) then begin
    initrect(dbr_minimize);
   end;
  end;
  if bo1{ or designing} then begin
   if (go_fixsizebutton in fgrip_options) then begin
    if designing or
         bo3 and fcontroller.getparentcontroller(parentcontroller) and
         not parentcontroller.nofit and
                  (parentcontroller.fsplitdir <> sd_tabed)  then begin
     initrect(dbr_fixsize);
    end;
   end;
   if (go_floatbutton in fgrip_options) then begin
    initrect(dbr_float);
   end;
  end;
  if bo2 then begin
   if go_topbutton in fgrip_options then begin
    initrect(dbr_top);
   end;
   if go_backgroundbutton in fgrip_options then begin
    initrect(dbr_background);
   end;
  end;
  if go_lockbutton in fgrip_options then begin
   initrect(dbr_lock);
  end;
  if bo1 and (go_nolockbutton in fgrip_options) and
          ((fcontroller.getparentcontroller <> nil) or designing) then begin
   initrect(dbr_nolock);
  end;
 end;
 if firstbu <> dbr_none then begin
  if fgrip_pos in [cp_right,cp_left] then begin
   exclude(fedges[firstbu],edg_top);
   exclude(fedges[lastbu],edg_bottom);
  end
  else begin
   exclude(fedges[firstbu],edg_right);
   exclude(fedges[lastbu],edg_left);
  end;
 end;
end;

procedure tgripframe.updatestate;
begin
 if go_horz in fgrip_options then begin
  if go_opposite in fgrip_options then begin
   fgrip_pos:= cp_bottom;
  end
  else begin
   fgrip_pos:= cp_top;
  end;
 end
 else begin
  if go_vert in fgrip_options then begin
   if go_opposite in fgrip_options then begin
    fgrip_pos:= cp_left;
   end
   else begin
    fgrip_pos:= cp_right;
   end;
  end;
 end;
 inherited;
end;

function tgripframe.griprect: rectty;
begin
 result:= frects[dbr_handle];
end;

function tgripframe.getwidget: twidget;
begin
 result:= fcontroller.fintf.getwidget;
end;

function tgripframe.getclientrect: rectty;
begin
 result:= fcontroller.fintf.getwidget.clientrect;
end;

procedure tgripframe.invalidatewidget();
begin
 fcontroller.fintf.getwidget.invalidatewidget();
end;

procedure tgripframe.invalidaterect(const rect: rectty;
               const org: originty = org_client; const noclip: boolean = false);
begin
 fcontroller.fintf.getwidget.invalidaterect(rect,org,noclip);
end;

procedure tgripframe.setlinkedvar(const source: tmsecomponent;
               var dest: tmsecomponent; const linkintf: iobjectlink = nil);
begin
 with twidget1(fcontroller.fintf.getwidget) do begin
  if not (csdestroying in componentstate) then begin
   setlinkedvar(source,dest,linkintf);
  end;
 end;
end;

function tgripframe.getcomponentstate: tcomponentstate;
begin
 result:= fcontroller.fintf.getwidget.componentstate;
end;

procedure tgripframe.widgetregioninvalid;
begin
 twidget1(fcontroller.fintf.getwidget).widgetregioninvalid;
end;

procedure tgripframe.updatemousestate(const sender: twidget;
                                        const info: mouseeventinfoty);
begin
 inherited;
 if pointinrect(info.pos,fgriprect) or (fcontroller.canmdisize) then begin
  with twidget1(sender) do begin
   fwidgetstate:= fwidgetstate + [ws_wantmousemove,ws_wantmousebutton];
  end;
 end;
end;

procedure tgripframe.getpickobjects(const sender: tobjectpicker;
                                                  var objects: integerarty);
var
 kind1: sizingkindty;
 rect: rectty;
begin
 rect:= sender.pickrect;
 if fcontroller.canmdisize and
              (fcontroller.mdistate <> mds_minimized) and
      (not pointinrect(rect.pos,fgriprect) or
         pointinrect(rect.pos,frects[dbr_handle])) then begin
  with fintf.getwidget do begin
   kind1:= calcsizingkind(rect.pos,makerect(nullpoint,size));
   if anchors * [an_left,an_right] = [] then begin
    case kind1 of
     sik_right,sik_left: kind1:= sik_none;
     sik_topright,sik_topleft: kind1:= sik_top;
     sik_bottomright,sik_bottomleft: kind1:= sik_bottom;
     else; // Added to make compiler happy
    end;
   end;
   if anchors * [an_top,an_bottom] = [] then begin
    case kind1 of
     sik_top,sik_bottom: kind1:= sik_none;
     sik_topleft,sik_bottomleft: kind1:= sik_left;
     sik_topright,sik_bottomright: kind1:= sik_right;
     else; // Added to make compiler happy
    end;
   end;
  end;
  if kind1 <> sik_none then begin
   setlength(objects,1);
   objects[0]:= ord(kind1);
  end
  else begin
   objects:= nil;
  end;
 end
 else begin
  objects:= nil;
 end;
end;

function tgripframe.getcursorshape(const sender: tobjectpicker;
                                      var shape: cursorshapety): boolean;
var
 ar1: integerarty;
begin
 getpickobjects(sender,ar1);
 result:= ar1 <> nil;
 if result then begin
  shape:= sizingcursors[sizingkindty(ar1[0])];
 end
end;

procedure tgripframe.beginpickmove(const sender: tobjectpicker);
begin
 //dummy
end;

procedure tgripframe.pickthumbtrack(const sender: tobjectpicker);
begin
 //dummy
end;

function tgripframe.calcsizingrect(const akind: sizingkindty;
                                const offset: pointty): rectty;
var
 cxmin,cymin: integer;
 int1: integer;
begin
 with fintf.getwidget do begin
  cxmin:= bounds_cxmin;
  cymin:= bounds_cymin;
  if fgrip_pos in [cp_right,cp_left] then begin
   int1:= fpaintframe.left + fpaintframe.right;
   if cxmin < int1 then begin
    cxmin:= int1;
   end;
   int1:= fpaintframe.top + fpaintframe.bottom +
              fgriprect.cy - frects[dbr_handle].cy;
   if cymin < int1 then begin
    cymin:= int1;
   end;
  end
  else begin
   int1:= fpaintframe.top + fpaintframe.bottom;
   if cymin < int1 then begin
    cymin:= int1;
   end;
   int1:= fpaintframe.left + fpaintframe.right +
              fgriprect.cx - frects[dbr_handle].cx;
   if cxmin < int1 then begin
    cxmin:= int1;
   end;
  end;
  result:= adjustsizingrect(widgetrect,akind,offset,
                   cxmin,bounds_cxmax,cymin,bounds_cymax);
  if parentwidget <> nil then begin
   with parentwidget do begin
    intersectrect(result,makerect(clientwidgetpos,maxclientsize),result);
   end;
  end;
 end;
end;

procedure tgripframe.endpickmove(const sender: tobjectpicker);
var
 ar1: integerarty;
begin
 ar1:= sender.currentobjects;
 if ar1 <> nil then begin
  fcontroller.fnormalrect:= calcsizingrect(sizingkindty(ar1[0]),
                                                        sender.pickoffset);
  fcontroller.mdistate:= mds_normal;
  fintf.getwidget.widgetrect:= fcontroller.fnormalrect;
 end;
end;

procedure tgripframe.paintxorpic(const sender: tobjectpicker;
                                                  const canvas: tcanvas);
var
 rect1: rectty;
 ar1: integerarty;
begin
 ar1:= sender.currentobjects;
 if ar1 <> nil then begin
  rect1:= calcsizingrect(sizingkindty(ar1[0]),sender.pickoffset);
  with fintf.getwidget do begin
   subpoint1(rect1.pos,paintparentpos);
   canvas.save;
   canvas.addcliprect(paintrectparent);
   canvas.drawxorframe(rect1,-3,stockobjects.bitmaps[stb_dens50]);
   canvas.restore;
  end;
 end;
end;

procedure tgripframe.mouseevent(var info: mouseeventinfoty);
begin
 if not fcontroller.active then begin
  fobjectpicker.mouseevent(info);
 end;
end;

procedure tgripframe.updatewidgetstate;
begin
 inherited;
 fintf.getwidget.invalidaterect(fgriprect,org_widget);
end;

function tgripframe.getgrip_face: tface;
begin
 fintf.getwidget.getoptionalobject(fgrip_face,@createface);
 result:= fgrip_face;
end;

procedure tgripframe.setgrip_face(const avalue: tface);
begin
 fintf.getwidget.setoptionalobject(avalue,fgrip_face,@createface);
end;

function tgripframe.getgrip_faceactive: tface;
begin
 fintf.getwidget.getoptionalobject(fgrip_faceactive,@createfaceactive);
 result:= fgrip_faceactive;
end;

procedure tgripframe.setgrip_faceactive(const avalue: tface);
begin
 fintf.getwidget.setoptionalobject(avalue,fgrip_faceactive,@createfaceactive);
end;

procedure tgripframe.createface();
begin
 fgrip_face:= tface.create(iface(self));
end;

procedure tgripframe.createfaceactive();
begin
 fgrip_faceactive:= tface.create(iface(self));
end;

function tgripframe.translatecolor(const acolor: colorty): colorty;
begin
 result:= fintf.getwidget.translatecolor(acolor);
end;

procedure tgripframe.cancelpickmove(const sender: tobjectpicker);
begin
 //dummy
end;

function tgripframe.ishintarea(const apos: pointty; var aid: int32): boolean;
                                      //widget origin
begin
 result:= pointinrect(apos,fgriprect{frects[dbr_handle]});
 if result then begin
  if go_buttonhints in fgrip_options then begin
   aid:= hintidframe - ord(fcontroller.checkbuttonarea(
            subpoint(apos,fcontroller.getwidget.clientwidgetpos)));
   if not (od_captionhint in fcontroller.optionsdock) and
                   (aid = hintidframe-ord(dbr_handle)) then begin
    result:= false;
   end;
  end
  else begin
   if (od_captionhint in fcontroller.optionsdock) then begin
    aid:= hintidframe - ord(dbr_handle);
   end;
  end;
 end
 else begin
  result:= inherited ishintarea(apos,aid);
 end;
end;

procedure tgripframe.setgrip_textflagstop(const avalue: textflagsty);
begin
 if fgrip_textflagstop <> avalue then begin
  fgrip_textflagstop:= checktextflags(fgrip_textflagstop,avalue);
  fintf.invalidatewidget();
 end;
end;

procedure tgripframe.setgrip_textflagsright(const avalue: textflagsty);
begin
 if fgrip_textflagsleft <> avalue then begin
  fgrip_textflagsleft:= checktextflags(fgrip_textflagsleft,avalue);
  fintf.invalidatewidget();
 end;
end;

procedure tgripframe.setgrip_textflagsbottom(const avalue: textflagsty);
begin
 if fgrip_textflagsbottom <> avalue then begin
  fgrip_textflagsbottom:= checktextflags(fgrip_textflagsbottom,avalue);
  fintf.invalidatewidget();
 end;
end;

procedure tgripframe.setgrip_textflagsrright(const avalue: textflagsty);
begin
 if fgrip_textflagsright <> avalue then begin
  fgrip_textflagsright:= checktextflags(fgrip_textflagsright,avalue);
  fintf.invalidatewidget();
 end;
end;

procedure tgripframe.setgrip_captiondist(const avalue: integer);
begin
 if fgrip_captiondist <> avalue then begin
  fgrip_captiondist:= avalue;
  fintf.invalidatewidget();
 end;
end;

procedure tgripframe.setgrip_captionoffset(const avalue: integer);
begin
 if fgrip_captionoffset <> avalue then begin
  fgrip_captionoffset:= avalue;
  fintf.invalidatewidget();
 end;
end;

{ tdockhandle }

constructor tdockhandle.create(aowner: tcomponent);
begin
 fgrip_color:= defaultgripcolor;
 fgrip_pos:= cp_bottomright;
 fgrip_grip:= stb_none;
 inherited;
 foptionswidget:= defaultoptionswidget + [ow_top{,ow_noautosizing}];
 foptionswidget1:= defaultoptionswidget1 + [ow1_noautosizing];
 size:= makesize(15,15);
 anchors:= [an_right,an_bottom];
 color:= cl_transparent;
end;

function tdockhandle.gethandlerect: rectty;
begin
 result:= paintrect;
end;

procedure tdockhandle.setgrip_color(const Value: colorty);
begin
 if fgrip_color <> value then begin
  fgrip_color:= value;
  invalidate;
 end;
end;

procedure tdockhandle.setgrip_grip(const Value: stockbitmapty);
begin
 if fgrip_grip <> value then begin
  fgrip_grip:= value;
  invalidate;
 end;
end;

procedure tdockhandle.setgrip_pos(const Value: captionposty);
begin
 if fgrip_pos <> value then begin
  fgrip_pos:= value;
  invalidate;
 end;
end;

procedure tdockhandle.clientmouseevent(var info: mouseeventinfoty);
var
 po1: pointty;
begin
 inherited;
 if not (es_processed in info.eventstate) and (fcontroller <> nil) then begin
  po1:= translateclientpoint(nullpoint,self,fcontroller.fintf.getwidget);
  addpoint1(info.pos,po1);
  fcontroller.clientmouseevent(info);
  subpoint1(info.pos,po1);
 end;
end;

procedure tdockhandle.dopaintforeground(const canvas: tcanvas);
var
 rect1: rectty;
 int1,int2,x,y: integer;
begin
 inherited;
 rect1:= innerclientrect;
 if fgrip_grip <> stb_none then begin
  with canvas do begin
   brush:= stockobjects.bitmaps[fgrip_grip];
   color:= fgrip_color;
   fillrect(rect1,cl_brushcanvas);
  end;
 end
 else begin
  case fgrip_pos of
   cp_bottomright: begin
    x:= rect1.x + rect1.cx - 1;
    y:= rect1.y + rect1.cy - 1;
    if rect1.cy < rect1.cx then begin
     int2:= rect1.cy;
    end
    else begin
     int2:= rect1.cx
    end;
    dec(int2);
    int1:= 2;
    while (int1 < int2) do begin
     canvas.drawline(makepoint(x-int1,y),makepoint(x,y-int1),cl_shadow);
     canvas.drawline(makepoint(x-int1-1,y-1),makepoint(x-1,y-int1-1),cl_highlight);
     inc(int1,4);
    end;
   end;
   else; // Added to make compiler happy
  end;
 end;
end;

function tdockhandle.gethint: msestring;
begin
 result:= inherited gethint();
 if (result = '') and (fcontroller <> nil) and
                      (od_captionhint in fcontroller.optionsdock) then begin
  result:= fcontroller.caption;
 end;
end;

{ tdockpanel }

constructor tdockpanel.create(aowner: tcomponent);
begin
 ficon:= tmaskedbitmap.create(bmk_rgb);
 ficon.onchange:= {$ifdef FPC}@{$endif}iconchanged;
 if fdragdock = nil then begin
  fdragdock:= tnochildrendockcontroller.create(idockcontroller(self));
 end;
 inherited;
 optionswidget:= defaultdockpaneloptionswidget;
end;

destructor tdockpanel.destroy;
begin
 ficon.free;
 inherited;
 fdragdock.Free;
end;

function tdockpanel.checkdock(var info: draginfoty): boolean;
begin
 result:= true;
end;

procedure tdockpanel.childmouseevent(const sender: twidget;
               var info: mouseeventinfoty);
begin
 if not (es_processed in info.eventstate) then begin
  fdragdock.childormouseevent(sender,info);
  if not (es_processed in info.eventstate) then begin
   inherited;
  end;
 end;
end;

procedure tdockpanel.internalcreateframe;
begin
 tgripframe.create(iscrollframe(self),fdragdock);
end;

procedure tdockpanel.dragevent(var info: draginfoty);
begin
 if not fdragdock.beforedragevent(info) then begin
  inherited;
 end;
 fdragdock.afterdragevent(info);
end;

function tdockpanel.getframe: tgripframe;
begin
 result:= tgripframe(inherited getframe);
end;

procedure tdockpanel.setframe(const Value: tgripframe);
begin
 inherited setframe(value);
end;

procedure tdockpanel.setdragdock(const Value: tnochildrendockcontroller);
begin
 fdragdock.assign(Value);
end;

procedure tdockpanel.updatewindowinfo(var info: windowinfoty);
begin
 inherited;
 info.options:= foptionswindow;
 getwindowicon(ficon,info.icon,info.iconmask);
end;

function tdockpanel.getbuttonrects(const index: dockbuttonrectty): rectty;
begin
 if fframe = nil then begin
  if index = dbr_handle then begin
   result:= clientrect;
  end
  else begin
   result:= nullrect;
  end;
 end
 else begin
  result:= tgripframe(fframe).getbuttonrects(index);
 end;
end;

function tdockpanel.getminimizedsize(out apos: captionposty): sizety;
begin
 if fframe = nil then begin
  result:= nullsize;
 end
 else begin
  result:= tgripframe(fframe).getminimizedsize(apos);
 end;
end;

function tdockpanel.getplacementrect: rectty;
begin
 result:= innerpaintrect;
 minsize:= nullsize;
end;

function tdockpanel.getcaption: msestring;
begin
 result:= '';
end;

function tdockpanel.getchildicon: tmaskedbitmap;
begin
 result:= nil;
end;

procedure tdockpanel.setstatfile(const Value: tstatfile);
begin
 setstatfilevar(istatfile(self),value,fstatfile);
end;

procedure tdockpanel.seticon(const avalue: tmaskedbitmap);
begin
 ficon.assign(avalue);
end;

procedure tdockpanel.iconchanged(const sender: tobject);
var
 icon1,mask1: pixmapty;
begin
 if ownswindow then begin
  getwindowicon(ficon,icon1,mask1);
  gui_setwindowicon(window.winid,icon1,mask1);
 end;
end;

   //istatfile
procedure tdockpanel.dostatread(const reader: tstatreader);
begin
 fdragdock.dostatread(reader);
end;

procedure tdockpanel.dostatwrite(const writer: tstatwriter);
begin
 fdragdock.dostatwrite(writer,nil);
end;

procedure tdockpanel.statreading;
begin
 fdragdock.statreading;
end;

procedure tdockpanel.statread;
begin
 fdragdock.statread;
end;

function tdockpanel.getstatvarname: msestring;
begin
 result:= fstatvarname;
end;

procedure tdockpanel.clientrectchanged;
begin
 fdragdock.beginclientrectchanged;
 inherited;
 fdragdock.endclientrectchanged;
end;

procedure tdockpanel.widgetregionchanged(const sender: twidget);
begin
 inherited;
 fdragdock.widgetregionchanged(sender);
end;

procedure tdockpanel.setparentwidget(const Value: twidget);
begin
 if fframe <> nil then begin
  exclude(tcustomframe1(fframe).fstate,fs_rectsvalid);
 end;
 inherited;
end;

procedure tdockpanel.dopaintforeground(const acanvas: tcanvas);
begin
 inherited;
 fdragdock.dopaint(acanvas);
end;

procedure tdockpanel.doactivate;
begin
 fdragdock.doactivate;
 inherited;
end;

procedure tdockpanel.statechanged;
begin
 fdragdock.statechanged(fwidgetstate);
 inherited;
end;

procedure tdockpanel.poschanged;
begin
 fdragdock.poschanged;
end;

procedure tdockpanel.parentchanged;
begin
 inherited;
 fdragdock.parentchanged(self);
end;

function tdockpanel.getdockcontroller: tdockcontroller;
begin
 result:= fdragdock;
end;

procedure tdockpanel.dolayoutchanged(const sender: tdockcontroller);
begin
 //dummy
end;

procedure tdockpanel.dodockcaptionchanged(const sender: tdockcontroller);
begin
 //dummy
end;

function tdockpanel.getstatpriority: integer;
begin
 result:= fstatpriority;
end;

function tdockpanel.calcminscrollsize: sizety;
begin
 result:= inherited calcminscrollsize();
 if not (csdesigning in componentstate) then begin
  fdragdock.updateminscrollsize(result);
 end;
end;

procedure tdockpanel.setdockingareacaption(const avalue: msestring);
begin
 fdockingareacaption:= avalue;
 invalidate;
end;

procedure tdockpanel.dopaintbackground(const canvas: tcanvas);
begin
 inherited;
 if fdockingareacaption <> '' then begin
  paintdockingareacaption(canvas,self,fdockingareacaption);
 end;
end;

{ tchildorderevent }

constructor tchildorderevent.create(const sender: tdockcontroller);
begin
 fchildren:= sender.fchildren;
 ffocusedchild:= sender.ffocusedchild;
 inherited create(ek_object,ievent(sender));
end;

end.
