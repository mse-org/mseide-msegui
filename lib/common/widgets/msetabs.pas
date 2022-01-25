{ MSEgui Copyright (c) 1999-2017 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msetabs;

{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}

interface
uses
 msetabsglob,msewidgets,mseclasses,msearrayprops,classes,mclasses,mseshapes,
 mserichstring,msetypes,msegraphics,msegraphutils,mseevent,mseinterfaces,
 mseglob,mseguiglob,msegui,msebitmap,msedragglob,
 {mseforms,}rtlconsts,msesimplewidgets,msedrag,mseact,
 mseobjectpicker,msepointer,msestat,msestatfile,msestrings,msemenus,
 msedrawtext,msetimer;

const
 defaulttaboptionswidget = defaultoptionswidgetmousewheel +
                                 [ow_subfocus{,ow_fontglyphheight}];
 defaulttaboptionsskin = defaultoptionsskin + [osk_colorcaptionframe];
 defaultcaptiondist = 1;
 defaultimagedist = 0;
 defaulttabshift = -100; //-> 1
 defaultedgelevel = -100; //-> -1
 defaultimagepos = ip_right;
 defaulttabpageskinoptions = defaultcontainerskinoptions;
 defaultoptionswidgettab = defaultoptionswidgetnofocus;
 defaultoptionswidget1tab = [ow1_autoheight];
 defaultcolortab = cl_transparent;
 defaultcoloractivetab = cl_active;

type
 tcustomtabbar = class;
 tabstatety = (ts_invisible,ts_disabled,ts_active,ts_updating,ts_captionclipped,
               ts_noface);
 tabstatesty = set of tabstatety;

 ttabfont = class(tparentfont)
  public
   class function getinstancepo(owner: tobject): pfont; override;
 end;

 ttabfontactive = class(tparentfont)
  public
   class function getinstancepo(owner: tobject): pfont; override;
 end;

 ttab = class(tindexpersistent,iimagelistinfo)
  private
   frichcaption: richstringty;
   fcaption: msestring;
   fhint: msestring;
   fwidth: integer;
   fstate: tabstatesty;
   fcolor: colorty;
   fcoloractive: colorty;
   fident: integer;
   fimagelist: timagelist;
   fimagenr: imagenrty;
   fimagenrdisabled: imagenrty;
//   function getcaption: captionty;
   fface: tfacecomp;
   ffaceactive: tfacecomp;
   procedure setcaption(const avalue: captionty);
   procedure changed;
   procedure setstate(const Value: tabstatesty);
   procedure setcolor(const Value: colorty);
   procedure setcoloractive(const Value: colorty);
   function getactive: boolean;
   procedure setactive(const Value: boolean);
   procedure setimagelist(const avalue: timagelist);
   procedure setimagenr(const avalue: imagenrty);
   procedure setimagenrdisabled(const avalue: imagenrty);
   function getimagelist: timagelist;
   function getfont: ttabfont;
   procedure setfont(const avalue: ttabfont);
   function isfontstored: boolean;
   function getfontactive: ttabfontactive;
   procedure setfontactive(const avalue: ttabfontactive);
   function isfontactivestored: boolean;
   procedure setface(const avalue: tfacecomp);
   procedure setfaceactive(const avalue: tfacecomp);
  protected
   ftag: integer;
   ffont: ttabfont;
   ffontactive: ttabfontactive;
   procedure fontchanged(const sender: tobject);
   procedure execute(const tag: integer; const info: mouseeventinfoty);
   procedure doshortcut(var info: keyeventinfoty; const sender: twidget);
   procedure objectevent(const sender: tobject;
                                     const event: objecteventty); override;
  public
   constructor create(const aowner: tcustomtabbar); reintroduce;
   destructor destroy; override;
   procedure createfont;
   procedure createfontactive;
   function tabbar: tcustomtabbar;
   property ident: integer read fident;
   property active: boolean read getactive write setactive;
  published
   property caption: captionty read fcaption write setcaption;
   property state: tabstatesty read fstate write setstate default [];
   property color: colorty read fcolor write setcolor default cl_default;
   property coloractive: colorty read fcoloractive
                 write setcoloractive default cl_default;
   property face: tfacecomp read fface write setface;
   property faceactive: tfacecomp read ffaceactive write setfaceactive;
   property font: ttabfont read getfont write setfont  stored isfontstored;
   property fontactive: ttabfontactive read getfontactive write setfontactive
                                          stored isfontactivestored;
   property imagelist: timagelist read fimagelist write setimagelist;
   property imagenr: imagenrty read fimagenr write setimagenr default -1;
   property imagenrdisabled: imagenrty read fimagenrdisabled
                                           write setimagenrdisabled default -2;
                //-2 -> same as imagenr
   property tag: integer read ftag write ftag default 0;
   property hint: msestring read fhint write fhint;
   property width: integer read fwidth write fwidth;
 end;
 tabarty = array of ttab;
 tabaty = array[0..0] of ttab;
 ptabaty = ^tabaty;

 ttabs = class;

 createtabeventty = procedure(const sender: tcustomtabbar; const index: integer;
                         var tab: ttab) of object;

 ttabframe = class(tframe)
  public
   constructor create(const aintf: iframe);
  published
   property framei_left default defaultcaptiondist;
   property framei_top default defaultcaptiondist;
   property framei_right default defaultcaptiondist;
   property framei_bottom default defaultcaptiondist;
   property imagedist default defaultimagedist;
 end;

 ttabsfont = class(tparentfont)
  public
   class function getinstancepo(owner: tobject): pfont; override;
 end;

 ttabsfontactive = class(tparentfont)
  public
   class function getinstancepo(owner: tobject): pfont; override;
 end;

 ttabs = class(tindexpersistentarrayprop,iframe)
  private
   fcolor: colorty;
   fcoloractive: colorty;
   fimagepos: imageposty;
   flabel: Tlabel;
   //   fcaptionframe: framety;
   //   fimagedist: integer;
   fframe: ttabframe;
   fface: tface;
   ffaceactive: tface;
   fhint: msestring;
   foncreatetab: createtabeventty;
   factcellindex: integer;
   ftabshift: integer;
   fshift: integer;
   ftextflags: textflagsty;
   fwidth: integer;
   fwidthmin: integer;
   fwidthmax: integer;
   fedge_level: int32;
   fedge: edgecolorpairinfoty;
   fedge_imagelist: timagelist;
   fedge_imageoffset: int32;
   fedge_imagepaintshift: int32;
   procedure setitems(const index: integer; const Value: ttab);
   function getitems(const index: integer): ttab; reintroduce;
   function getface: tface;
   procedure setface(const avalue: tface);
   function getfaceactive: tface;
   procedure setfaceactive(const avalue: tface);
   procedure setcolor(const avalue: colorty);
   procedure setcoloractive(const avalue: colorty);
   procedure setimagepos(const avalue: imageposty);
   {
   procedure setcaptionframe_left(const avalue: integer);
   procedure setcaptionframe_top(const avalue: integer);
   procedure setcaptionframe_right(const avalue: integer);
   procedure setcaptionframe_bottom(const avalue: integer);
   procedure setimagedist(const avalue: integer);
   }
   function getframe: ttabframe;
   procedure setframe(const avalue: ttabframe);
   procedure setshift(const avalue: integer);
   function getfont: ttabsfont;
   procedure setfont(const avalue: ttabsfont);
   function isfontstored: boolean;
   function getfontactive: ttabsfontactive;
   procedure setfontactive(const avalue: ttabsfontactive);
   function isfontactivestored: boolean;
   procedure readcaptionpos(reader: treader);
   procedure readcaptionframe_left(reader: treader);
   procedure readcaptionframe_top(reader: treader);
   procedure readcaptionframe_right(reader: treader);
   procedure readcaptionframe_bottom(reader: treader);
   procedure readimagedist(reader: treader);
   procedure settextflags(const avalue: textflagsty);
   procedure setwidth(const avalue: integer);
   procedure setwidthmin(const avalue: integer);
   procedure setwidthmax(const avalue: integer);
   procedure setedge_level(const avalue: int32);
   procedure setedge_colordkshadow(const avalue: colorty);
   procedure setedge_colorshadow(const avalue: colorty);
   procedure setedge_colorlight(const avalue: colorty);
   procedure setedge_colorhighlight(const avalue: colorty);
   procedure setedge_colordkwidth(const avalue: int32);
   procedure setedge_colorhlwidth(const avalue: int32);
   procedure setedge_imagelist(const avalue: timagelist);
   procedure setedge_imageoffset(const avalue: int32);
   procedure setedge_imagepaintshift(const avalue: int32);
  protected
   fskinupdating: integer;
   ffont: ttabsfont;
   ffontactive: ttabsfontactive;
   procedure defineproperties(filer: tfiler); override;
   procedure changed;
   procedure fontchanged(const sender: tobject);
   procedure createitem(const index: integer; var item: tpersistent); override;
   procedure dochange(const index: integer); override;
   procedure checktemplate(const sender: tobject);
    //iframe
   procedure setframeinstance(instance: tcustomframe);
   procedure setstaticframe(value: boolean);
   function getstaticframe: boolean;
   function getwidgetrect: rectty;
   function getcomponentstate: tcomponentstate;
   function getmsecomponentstate: msecomponentstatesty;
   procedure scrollwidgets(const dist: pointty);
   procedure clientrectchanged;
   procedure invalidate;
   procedure invalidatewidget;
   procedure invalidaterect(const rect: rectty; const org: originty = org_client;
                               const noclip: boolean = false);
   function getwidget: twidget;
   function getframestateflags: framestateflagsty; virtual;
   function getedgeshift(): int32;
  public

   constructor create(const aowner: tcustomtabbar;
                           aclasstype: indexpersistentclassty); reintroduce;
   destructor destroy; override;
   class function getitemclasstype: persistentclassty; override;
   procedure createfont;
   procedure createfontactive;
   procedure createframe;
   procedure createface;
   procedure createfaceactive;
   procedure add(const item: ttab);
   procedure insert(const item: ttab; const aindex: integer);
   procedure additems(const aitems: msestringarty);
   function indexof(const item: ttab): integer;
   property items[const index: integer]: ttab read getitems write setitems; default;
   property oncreatetab: createtabeventty read foncreatetab write foncreatetab;
  published
   property color: colorty read fcolor
                  write setcolor default cl_default;
   property coloractive: colorty read fcoloractive
                  write setcoloractive default cl_default;
   property font: ttabsfont read getfont write setfont  stored isfontstored;
   property fontactive: ttabsfontactive read getfontactive write setfontactive
                                          stored isfontactivestored;

   property width: integer read fwidth write setwidth default 0;
   property widthmin: integer read fwidthmin write setwidthmin default 0;
   property widthmax: integer read fwidthmax write setwidthmax default 0;
   property textflags: textflagsty read ftextflags write settextflags
                                                default defaultcaptiontextflags;
   property imagepos: imageposty read fimagepos write
                          setimagepos default defaultimagepos;
{
   property captionframe_left: integer read fcaptionframe.left write
                          setcaptionframe_left default defaultcaptiondist;
   property captionframe_top: integer read fcaptionframe.top write
                          setcaptionframe_top default defaultcaptiondist;
   property captionframe_right: integer read fcaptionframe.right write
                          setcaptionframe_right default defaultcaptiondist;
   property captionframe_bottom: integer read fcaptionframe.bottom write
                          setcaptionframe_bottom default defaultcaptiondist;
   property imagedist: integer read fimagedist write setimagedist
                                                       default defaultimagedist;
}
   property shift: integer read fshift write setshift default defaulttabshift;
                       //defaulttabshift (-100) -> 1
   property edge_level: int32 read fedge_level write setedge_level
                                             default defaultedgelevel;
                       //defaultedgelevel (-100) -> -1
   property edge_colordkshadow: colorty read fedge.shadow.effectcolor
                      write setedge_colordkshadow default cl_default;
   property edge_colorshadow: colorty read fedge.shadow.color
                      write setedge_colorshadow default cl_default;
   property edge_colorlight: colorty read fedge.light.color
                      write setedge_colorlight default cl_default;
   property edge_colorhighlight: colorty read fedge.light.effectcolor
                      write setedge_colorhighlight default cl_default;
   property edge_colordkwidth: int32 read fedge.shadow.effectwidth
                      write setedge_colordkwidth default -1;
                                  //-1 = default
   property edge_colorhlwidth: int32 read fedge.light.effectwidth
                      write setedge_colorhlwidth default -1;
                                  //-1 = default
   property edge_imagelist: timagelist read fedge_imagelist
                    write setedge_imagelist;
                   //imagenr 0 -> startpoint, 1 -> edge, imagenr 2 -> endpoint
   property edge_imageoffset: int32 read fedge_imageoffset
                    write setedge_imageoffset default 0;
   property edge_imagepaintshift: int32 read fedge_imagepaintshift
                                     write setedge_imagepaintshift default 0;

   property frame: ttabframe read getframe write setframe;
                  //frameimage_offset1 active for first tab
   property face: tface read getface write setface;
   property faceactive: tface read getfaceactive write setfaceactive;
   property hint: msestring read fhint write fhint;
 end;

 tabbarlayoutinfoty = record
  tabs: ttabs;
  dim: rectty;
  captionframe: framety;
  totsize: sizety;
  activetab: integer;
  focusedtab: integer;
  cells: shapeinfoarty;
  firsttab: integer;
  lasttab: integer;
  notfull: boolean;
  stepinfo: framestepinfoty;
  options: shapestatesty;
 end;

 movingeventty = procedure(const sender: tobject; var curindex: integer;
                                       var newindex: integer) of object;
 movedeventty = procedure(const sender: tobject; const curindex: integer;
                                       const newindex: integer) of object;
 tabschangedeventty = procedure(const synctabindex: boolean) of object;

 tabbarstatety = (tbs_layoutvalid,tbs_designdrag,tbs_shrinktozero,
                  tbs_updatesizing,tbs_repeatup);
 tabbarstatesty = set of tabbarstatety;

 tcustomtabbar = class(tcustomstepbox)
  private
   flayoutinfo: tabbarlayoutinfoty;
   fhintedbutton: integer;
   fonactivetabchange: notifyeventty;
   fupdating: integer;
   finternaltabchange: tabschangedeventty;
   fontabmoving: movingeventty;
   fontabmoved: movedeventty;
   fonclientmouseevent: mouseeventty;
   frepeater: trepeater;
   procedure settabs(const Value: ttabs);
   procedure layoutchanged;
   procedure checklayout;
   procedure updatelayout();
   function getactivetab: integer;
   procedure setactivetab(const Value: integer);
   procedure tabschanged(const sender: tarrayprop; const index: integer);
   procedure setfirsttab(Value: integer);
   procedure setoptions(const avalue: tabbaroptionsty);
   function gethintpos(const aindex: integer): rectty;
   function getbuttonhint(const aindex: integer): msestring;
   procedure repeatproc(const sender: tobject);
   procedure startrepeater(const up: boolean);
   procedure killrepeater();
  protected
   fstate: tabbarstatesty;
   foptions: tabbaroptionsty;
   class function classskininfo: skininfoty; override;
   function dostep(const event: stepkindty; const adelta: real;
                           ashiftstate: shiftstatesty): boolean; override;
   procedure doactivetabchanged;
   procedure tabchanged(const sender: ttab);
   procedure tabclicked(const sender: ttab; const info: mouseeventinfoty);
   procedure enabledchanged; override;
   procedure loaded; override;
   procedure dopaintforeground(const canvas: tcanvas); override;
   procedure clientmouseevent(var info: mouseeventinfoty); override;
   procedure statechanged; override;
   procedure fontchanged; override;
   procedure doshortcut(var info: keyeventinfoty;
                                     const sender: twidget); override;
   procedure clientrectchanged; override;
   procedure getautopaintsize(var asize: sizety); override;
   procedure objectevent(const sender: tobject;
                                const event: objecteventty); override;
   procedure dokeydown(var info: keyeventinfoty); override;
   function upstep(const norotate: boolean): boolean;
   function downstep(const norotate: boolean): boolean;
    //iassistiveclient
   function getassistivecaption(): msestring; override;
   function getassistivehint(): msestring; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure synctofontheight; override;
   procedure beginupdate;
   procedure endupdate;
   function tabatpos(const apos: pointty; const enabledonly: boolean = false): integer;
   procedure movetab(curindex,newindex: integer);
   function activetag: integer; //0 if no activetab, activetab.tag otherwise
   procedure dragevent(var info: draginfoty); override;
   property activetab: integer read getactivetab write setactivetab;
   property tabs: ttabs read flayoutinfo.tabs write settabs;
   property firsttab: integer read flayoutinfo.firsttab write setfirsttab default 0;
   property onactivetabchange: notifyeventty read fonactivetabchange
                  write fonactivetabchange;
   property font: twidgetfont read getfont write setfont stored isfontstored;
   property options: tabbaroptionsty read foptions write setoptions default [];
   property ontabmoving: movingeventty read fontabmoving write fontabmoving;
   property ontabmoved: movedeventty read fontabmoved write fontabmoved;
   property onclientmouseevent: mouseeventty read fonclientmouseevent write fonclientmouseevent;
  published
   property optionswidget default defaultoptionswidgettab;
   property optionswidget1 default defaultoptionswidget1tab;
 end;

 tcustomtabbar1 = class(tcustomtabbar)
  protected
   procedure internalcreateframe; override;
 end;

 ttabbar = class(tcustomtabbar,istatfile)
  private
   fstatfile: tstatfile;
   fstatvarname: msestring;
   fstatpriority: integer;
   procedure setstatfile(const Value: tstatfile);
   procedure setdragcontroller(const Value: tdragcontroller);
  protected
    //istatfile
   procedure dostatread(const reader: tstatreader);
   procedure dostatwrite(const writer: tstatwriter);
   procedure statreading;
   procedure statread;
   function getstatvarname: msestring;
   function getstatpriority: integer;
  published
   property statfile: tstatfile read fstatfile write setstatfile;
   property statvarname: msestring read getstatvarname write fstatvarname;
   property statpriority: integer read fstatpriority
                                       write fstatpriority default 0;
   property onstep;
   property tabs;
   property firsttab;
   property onactivetabchange;
   property ontabmoving;
   property ontabmoved;
   property onclientmouseevent;
   property font;
   property options;
   property drag: tdragcontroller read fdragcontroller write setdragcontroller;
 end;

 tcustomtabwidget = class;

 itabpage = interface(inullinterface)[miid_itabpage]
  procedure settabwidget(const value: tcustomtabwidget);
  function gettabwidget: tcustomtabwidget;
  function getwidget: twidget;
  function getcaption: msestring;
  function gettabhint: msestring;
  function gettabnoface: boolean;
  function getcolortab: colorty;
  function getcoloractivetab: colorty;
  function getfacetab: tfacecomp;
  function getfaceactivetab: tfacecomp;
  function getfonttab: tfont;
  function getfontactivetab: tfont;
  function getimagelist: timagelist;
  function getimagenr: imagenrty;
  function getimagenrdisabled: imagenrty;
  function getinvisible: boolean;
  procedure setcolortab(const avalue: colorty);
  procedure setcoloractivetab(const avalue: colorty);
  procedure setfacetab(const avalue: tfacecomp);
  procedure setfaceactivetab(const avalue: tfacecomp);
  procedure setfonttab(const avalue: tfont);
  procedure setfontactivetab(const avalue: tfont);
  procedure doselect;
  procedure dodeselect;
 end;

 ttabpagefonttab = class(tparentfont)
  public
   class function getinstancepo(owner: tobject): pfont; override;
 end;

 ttabpagefontactivetab = class(tparentfont)
  public
   class function getinstancepo(owner: tobject): pfont; override;
 end;

 ttabpage = class;
 getsubformeventty = procedure(const sender: ttabpage;
                          var submoduleclass: widgetclassty;
                          var instancevarpo: pwidget) of object;
 initsubformeventty = procedure(const sender: ttabpage;
                          const asubform: twidget) of object;

 ttabpage = class(tscrollingwidget,itabpage,iimagelistinfo)
  private
   ftabwidget: tcustomtabwidget;
   fcaption: msestring;
   ftabhint: msestring;
   ftabnoface: boolean;
   fimagelist: timagelist;
   fimagenr: integer;
   fimagenrdisabled: integer;
   fcolortab,fcoloractivetab: colorty;
   fonselect: notifyeventty;
   fondeselect: notifyeventty;
   finvisible: boolean;
   ffonttab: ttabpagefonttab;
   ffontactivetab: ttabpagefontactivetab;
   fongetsubform: getsubformeventty;
   fsubform: twidget;
   fsubforminstancevarpo: pwidget;
   foninitsubform: initsubformeventty;
   ffacetab: tfacecomp;
   ffaceactivetab: tfacecomp;
   ftaborderoverride: ttaborderoverride;
   function getcaption: captionty;
   procedure setcaption(const Value: captionty);
   function gettabhint: msestring;
   procedure settabhint(const avalue: msestring);
   function gettabnoface: boolean;
   procedure settabnoface(const avalue: boolean);
   function getcolortab: colorty;
   procedure setcolortab(const avalue: colorty);
   function getcoloractivetab: colorty;
   procedure setcoloractivetab(const avalue: colorty);
   procedure settabwidget(const value: tcustomtabwidget);
   function gettabwidget: tcustomtabwidget;
   function gettabindex: integer;
   procedure settabindex(const avalue: integer);
   function getimagelist: timagelist;
   procedure setimagelist(const avalue: timagelist);
   function getimagenr: imagenrty;
   procedure setimagenr(const avalue: imagenrty);
   function getimagenrdisabled: imagenrty;
   procedure setimagenrdisabled(const avalue: imagenrty);
   function getinvisible: boolean;
   procedure setinvisible(const avalue: boolean);
   function getfonttab: tfont;
   function getfontactivetab: tfont;
   function getfonttab1: ttabpagefonttab;
   procedure setfonttab1(const avalue: ttabpagefonttab);
   procedure setfonttab(const avalue: tfont);
   function isfonttabstored: boolean;
   function getfontactivetab1: ttabpagefontactivetab;
   procedure setfontactivetab1(const avalue: ttabpagefontactivetab);
   procedure setfontactivetab(const avalue: tfont);
   function isfontactivetabstored: boolean;
   procedure setfacetab(const avalue: tfacecomp);
   procedure setfaceactivetab(const avalue: tfacecomp);
   function getfacetab: tfacecomp;
   function getfaceactivetab: tfacecomp;
   function isvisiblestored: boolean;
   procedure settaborderoverride(const avalue: ttaborderoverride);
  protected
   class function classskininfo: skininfoty; override;
   procedure changed;
   procedure fontchanged1(const sender: tobject);
   procedure visiblechanged; override;
   procedure enabledchanged; override;
   procedure objectevent(const sender: tobject;
                              const event: objecteventty); override;
   procedure registerchildwidget(const child: twidget); override;
   procedure designselected(const selected: boolean); override;
   procedure doselect; virtual;
   procedure dodeselect; virtual;
   procedure loaded; override;
   function getisactivepage: boolean;
   procedure setisactivepage(const avalue: boolean);
   function nexttaborderoverride(const sender: twidget;
                                      const down: boolean): twidget override;
   procedure readstate(reader: treader) override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure initnewcomponent(const ascale: real); override;
   procedure createfonttab;
   procedure createfontactivetab;
   property tabwidget: tcustomtabwidget read ftabwidget;
   property tabindex: integer read gettabindex write settabindex;
   property isactivepage: boolean read getisactivepage write setisactivepage;
   property subform: twidget read fsubform;
  published
   property invisible: boolean read getinvisible
                                       write setinvisible default false;
   property taborderoverride: ttaborderoverride read ftaborderoverride
                                                  write settaborderoverride;

   property caption: captionty read getcaption write setcaption;
   property tabhint: msestring read gettabhint write settabhint;
   property tabnoface: boolean read gettabnoface
                                 write settabnoface default false;
   property colortab: colorty read getcolortab
                  write setcolortab default cl_default;
   property coloractivetab: colorty read getcoloractivetab
                  write setcoloractivetab default cl_default;
   property facetab: tfacecomp read getfacetab write setfacetab;
   property faceactivetab: tfacecomp read getfaceactivetab
                                                 write setfaceactivetab;
   property fonttab: ttabpagefonttab read getfonttab1 write setfonttab1
                                                        stored isfonttabstored;
   property fontactivetab: ttabpagefontactivetab read getfontactivetab1
                          write setfontactivetab1 stored isfontactivetabstored;
   property imagelist: timagelist read getimagelist write setimagelist;
   property imagenr: imagenrty read getimagenr write setimagenr default -1;
   property imagenrdisabled: imagenrty read getimagenrdisabled
                                           write setimagenrdisabled default -2;
                //-2 -> same as imagenr
   property font: twidgetfont read getfont write setfont stored isfontstored;
   property optionswidget default defaulttaboptionswidget;
   property onlayout;
   property onfontheightdelta;
   property onshow;
   property onhide;
   property onselect: notifyeventty read fonselect write fonselect;
   property ondeselect: notifyeventty read fondeselect write fondeselect;
   property ongetsubform: getsubformeventty read fongetsubform
                                                   write fongetsubform;
   property oninitsubform: initsubformeventty read foninitsubform
                                                   write foninitsubform;
   property visible stored isvisiblestored default false;
   property optionsskin default defaulttabpageskinoptions;
 end;


 tpagetab = class(ttab)
  private
   fpageintf: itabpage;
  public
   constructor create(const aowner: tcustomtabbar; const apage: itabpage);
   function page: twidget;
 end;
 pagetabaty = array[0..0] of tpagetab;
 ppagetabaty = ^pagetabaty;

 ttab_font = class(tparentfont)
  public
   class function getinstancepo(owner: tobject): pfont; override;
 end;

 ttab_fonttab = class(tparentfont)
  public
   class function getinstancepo(owner: tobject): pfont; override;
 end;

 ttab_fontactivetab = class(tparentfont)
  public
   class function getinstancepo(owner: tobject): pfont; override;
 end;

 tcustomtabwidget = class(tactionwidget,iobjectpicker,istatfile)
  private
   fobjectpicker: tobjectpicker;
   factivepageindex: integer;
   factivepageindex1: integer;
   fonactivepagechanged: notifyeventty;
   fonpageadded: widgeteventty;
   fonpageremoved: widgeteventty;
   ftab_size: integer;
   ftab_sizemin: integer;
   ftab_sizemax: integer;
   fstatfile: tstatfile;
   fstatvarname: msestring;
   fvisiblepage: integer;
   fstatpriority: integer;
   procedure setstatfile(const value: tstatfile);
   function getitems(const index: integer): twidget;
   function getitemsintf(const index: integer): itabpage;
   function getactivepageindex: integer;
   procedure setactivepageindex(value: integer);
   procedure setactivepageindex1(const avalue: integer);
   function getactivepage: twidget;
   function getactivepageintf: itabpage;
   procedure setactivepage(const value: twidget);
   procedure updatesize(const page: twidget);
   function gettab_options: tabbaroptionsty;
   procedure settab_options(const avalue: tabbaroptionsty);
   function gettab_color: colorty;
   procedure settab_color(const avalue: colorty);
   function gettab_frame: tstepboxframe1;
   procedure settab_frame(const avalue: tstepboxframe1);
   function gettab_face: tface;
   procedure settab_face(const avalue: tface);
   procedure settab_size(const avalue: integer);
   procedure settab_sizemin(const avalue: integer);
   procedure settab_sizemax(const avalue: integer);
   function gettab_colortab: colorty;
   procedure settab_colortab(const avalue: colorty);
   function gettab_coloractivetab: colorty;
   procedure settab_coloractivetab(const avalue: colorty);
   function gettab_frametab: ttabframe;
   procedure settab_frametab(const avalue: ttabframe);
   function gettab_facetab: tface;
   procedure settab_facetab(const avalue: tface);
   function gettab_faceactivetab: tface;
   procedure settab_faceactivetab(const avalue: tface);
   function checktabsizingpos(const apos: pointty): boolean;
   function getidents: integerarty;
   function gettab_imagepos: imageposty;
   procedure settab_imagepos(const avalue: imageposty);
   {
   function gettab_captionframe_left: integer;
   procedure settab_captionframe_left(const avalue: integer);
   function gettab_captionframe_top: integer;
   procedure settab_captionframe_top(const avalue: integer);
   function gettab_captionframe_right: integer;
   procedure settab_captionframe_right(const avalue: integer);
   function gettab_captionframe_bottom: integer;
   procedure settab_captionframe_bottom(const avalue: integer);
   function gettab_imagedist: integer;
   procedure settab_imagedist(const avalue: integer);
   }
   function gettab_shift: integer;
   procedure settab_shift(const avalue: integer);
   function gettab_optionswidget: optionswidgetty;
   procedure settab_optionswidget(const avalue: optionswidgetty);
   function gettab_optionswidget1: optionswidget1ty;
   procedure settab_optionswidget1(const avalue: optionswidget1ty);
   function gettab_font: ttab_font;
   procedure settab_font(const avalue: ttab_font);
   function istab_fontstored: boolean;
   function gettab_fonttab: ttab_fonttab;
   procedure settab_fonttab(const avalue: ttab_fonttab);
   function istab_fonttabstored: boolean;
   function gettab_fontactivetab: ttab_fontactivetab;
   procedure set_tabfontactivetab(const avalue: ttab_fontactivetab);
   function istab_fontactivetabstored: boolean;
   procedure readtab_captionpos(reader: treader);
   procedure readoptions(reader: treader);
   procedure readtab_captionframe_left(reader: treader);
   procedure readtab_captionframe_top(reader: treader);
   procedure readtab_captionframe_right(reader: treader);
   procedure readtab_captionframe_bottom(reader: treader);
   procedure readtab_imagedist(reader: treader);
   function gettab_textflags: textflagsty;
   procedure settab_textflags(const avalue: textflagsty);
   function gettab_width: integer;
   procedure settab_width(const avalue: integer);
   function gettab_widthmin: integer;
   procedure settab_widthmin(const avalue: integer);
   function gettab_widthmax: integer;
   procedure settab_widthmax(const avalue: integer);
   function gettab_optionsskin: optionsskinty;
   procedure settab_optionsskin(const avalue: optionsskinty);
   function getedge_level: int32;
   procedure setedge_level(const avalue: int32);
   function getedge_colordkshadow: colorty;
   procedure setedge_colordkshadow(const avalue: colorty);
   function getedge_colorshadow: colorty;
   procedure setedge_colorshadow(const avalue: colorty);
   function getedge_colorlight: colorty;
   procedure setedge_colorlight(const avalue: colorty);
   function getedge_colorhighlight: colorty;
   procedure setedge_colorhighlight(const avalue: colorty);
   function getedge_colordkwidth: int32;
   procedure setedge_colordkwidth(const avalue: int32);
   function getedge_colorhlwidth: int32;
   procedure setedge_colorhlwidth(const avalue: int32);
   function getedge_imagelist: timagelist;
   procedure setedge_imagelist(const avalue: timagelist);
   function getedge_imageoffset: int32;
   procedure setedge_imageoffset(const avalue: int32);
   function getedge_imagepaintshift: int32;
   procedure setedge_imagepaintshift(const avalue: int32);
  protected
   ftabs: tcustomtabbar1;
   fupdating: integer;
   fpopuptab: integer;
   factivepageindexdesign: integer;
   procedure defineproperties(filer: tfiler) override;
   procedure internaladd(const page: itabpage; aindex: integer);
   procedure internalremove(const page: itabpage);
   procedure registerchildwidget(const child: twidget); override;
   procedure unregisterchildwidget(const child: twidget); override;
   procedure pagechanged(const sender: itabpage);
   procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
   procedure tabchanged(const synctabindex: boolean); virtual;
   procedure loaded; override;
   procedure clientrectchanged; override;
   procedure widgetregionchanged(const sender: twidget); override;
   procedure doactivepagechanged; virtual;
   procedure dopageadded(const apage: twidget); virtual;
   procedure dopageremoved(const apage: twidget); virtual;
   procedure createpagetab(const sender: tcustomtabbar;
                                           const index: integer; var tab: ttab);
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure childmouseevent(const sender: twidget;
                                          var info: mouseeventinfoty); override;
   procedure dobeforepaint(const canvas: tcanvas); override;
   procedure doafterpaint(const canvas: tcanvas); override;
//   procedure dofontheightdelta(var delta: integer); override;
   procedure doclosepage(const sender: tobject); virtual;
   procedure updatepopupmenu(var amenu: tpopupmenu;
                                     var mouseinfo: mouseeventinfoty); override;

    //istatfile
   procedure dostatread(const reader: tstatreader);
   procedure dostatwrite(const writer: tstatwriter);
   procedure statreading;
   procedure statread;
   function getstatvarname: msestring;
   function getstatpriority: integer;

   function checkpickoffset(const aoffset: pointty): pointty;
    //iobjectpicker
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

  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure createtabframe();
   procedure createtabface();
   procedure createtabfont();
   procedure createtabframetab();
   procedure createtabfacetab();
   procedure createtabfonttab();
   procedure createtabfaceactivetab();
   procedure createtabfontactivetab();

   procedure beginupdate;
   procedure endupdate;
   procedure synctofontheight; override;
   function indexof(const page: twidget): integer;
   function count: integer;
   procedure clear;
   procedure clearorder; //ident order = indexorder
   procedure nextpage(newindex: integer; down: boolean);
   procedure changepage(step: integer);
   procedure movepage(const curindex,newindex: integer);
   procedure add(const aitem: itabpage; const aindex: integer = bigint);
   function pagebyname(const aname: string): twidget;
                   //case sensitive!

   property items[const index: integer]: twidget read getitems; default;
   property itemsintf[const index: integer]: itabpage read getitemsintf;
   property activepage: twidget read getactivepage write setactivepage;
   property activepageintf: itabpage read getactivepageintf;
   property idents: integerarty read getidents;
   property activepageindex: integer read getactivepageindex
                      write setactivepageindex1 default -1;
   property onactivepagechanged: notifyeventty read fonactivepagechanged
                                                     write fonactivepagechanged;
   property onpageadded: widgeteventty read fonpageadded write fonpageadded;
   property onpageremoved: widgeteventty read fonpageremoved
                                                           write fonpageremoved;
   property optionswidget default defaulttaboptionswidget;
   property font: twidgetfont read getfont write setfont stored isfontstored;
   property fontempty: twidgetfontempty read getfontempty
                                 write setfontempty stored isfontemptystored;
   property tab_options: tabbaroptionsty read gettab_options write
                                                     settab_options default [];
   property tab_frame: tstepboxframe1 read gettab_frame write settab_frame;
   property tab_face: tface read gettab_face write settab_face;
   property tab_color: colorty read gettab_color
                                   write settab_color default cl_default;
   property tab_colortab: colorty read gettab_colortab
                                   write settab_colortab default cl_default;
   property tab_coloractivetab: colorty read gettab_coloractivetab
                        write settab_coloractivetab default cl_default;
   property tab_font: ttab_font read gettab_font write settab_font
                                                        stored istab_fontstored;
   property tab_fonttab: ttab_fonttab read gettab_fonttab write settab_fonttab
                                                    stored istab_fonttabstored;
   property tab_fontactivetab: ttab_fontactivetab read gettab_fontactivetab
                   write set_tabfontactivetab stored istab_fontactivetabstored;
   property tab_imagepos: imageposty read gettab_imagepos write
                          settab_imagepos default defaultimagepos;
   property tab_textflags: textflagsty read gettab_textflags write
                          settab_textflags default defaultcaptiontextflags;
   property tab_width: integer read gettab_width write settab_width default 0;
   property tab_widthmin: integer read gettab_widthmin
                                                write settab_widthmin default 0;
   property tab_widthmax: integer read gettab_widthmax
                                                write settab_widthmax default 0;
{
   property tab_captionframe_left: integer read gettab_captionframe_left write
                          settab_captionframe_left default defaultcaptiondist;
   property tab_captionframe_top: integer read gettab_captionframe_top write
                          settab_captionframe_top default defaultcaptiondist;
   property tab_captionframe_right: integer read gettab_captionframe_right write
                          settab_captionframe_right default defaultcaptiondist;
   property tab_captionframe_bottom: integer read gettab_captionframe_bottom write
                          settab_captionframe_bottom default defaultcaptiondist;
   property tab_imagedist: integer read gettab_imagedist write settab_imagedist
                                                       default defaultimagedist;
}
   property tab_shift: integer read gettab_shift write settab_shift
                                                      default defaulttabshift;
                       //defaulttabshift (-100) -> 1
   property tab_edge_level: int32 read getedge_level write setedge_level
                                             default defaultedgelevel;
                       //defaultedgelevel (-100) -> -1
   property tab_edge_colordkshadow: colorty read getedge_colordkshadow
                      write setedge_colordkshadow default cl_default;
   property tab_edge_colorshadow: colorty read getedge_colorshadow
                      write setedge_colorshadow default cl_default;
   property tab_edge_colorlight: colorty read getedge_colorlight
                      write setedge_colorlight default cl_default;
   property tab_edge_colorhighlight: colorty read getedge_colorhighlight
                      write setedge_colorhighlight default cl_default;
   property tab_edge_colordkwidth: int32 read getedge_colordkwidth
                      write setedge_colordkwidth default -1;
                                  //-1 = default
   property tab_edge_colorhlwidth: int32 read getedge_colorhlwidth
                      write setedge_colorhlwidth default -1;
                                  //-1 = default
   property tab_edge_imagelist: timagelist read getedge_imagelist
                    write setedge_imagelist;
                   //imagenr 0 -> startpoint, 1 -> edge, imagenr 2 -> endpoint
   property tab_edge_imageoffset: int32 read getedge_imageoffset
                    write setedge_imageoffset default 0;
   property tab_edge_imagepaintshift: int32 read getedge_imagepaintshift
                                     write setedge_imagepaintshift default 0;

   property tab_frametab: ttabframe read gettab_frametab write settab_frametab;
   property tab_facetab: tface read gettab_facetab write settab_facetab;
   property tab_faceactivetab: tface read gettab_faceactivetab
                                                    write settab_faceactivetab;
   property tab_size: integer read ftab_size write settab_size;
   property tab_sizemin: integer read ftab_sizemin write settab_sizemin
                            default defaulttabsizemin;
   property tab_sizemax: integer read ftab_sizemax write settab_sizemax
                            default defaulttabsizemax;
   property tab_optionswidget: optionswidgetty read gettab_optionswidget
                 write settab_optionswidget default defaultoptionswidgettab;
   property tab_optionsskin: optionsskinty read gettab_optionsskin
                 write settab_optionsskin default [];
   property tab_optionswidget1: optionswidget1ty read gettab_optionswidget1
                 write settab_optionswidget1 default defaultoptionswidget1tab;

   property statfile: tstatfile read fstatfile write setstatfile;
   property statvarname: msestring read getstatvarname write fstatvarname;
   property statpriority: integer read fstatpriority
                                       write fstatpriority default 0;
 end;

 ttabwidget = class(tcustomtabwidget)
  published
   property optionswidget;
   property optionswidget1;
   property optionsskin default defaulttaboptionsskin;
   property bounds_x;
   property bounds_y;
   property bounds_cx;
   property bounds_cy;
   property bounds_cxmin;
   property bounds_cymin;
   property bounds_cxmax;
   property bounds_cymax;
   property color;
   property cursor;
   property frame;
   property face;
   property anchors;
   property taborder;
   property hint;
   property popupmenu;
   property onpopup;
   property onshowhint;

   property enabled;
   property visible;

   property activepageindex;
   property onactivepagechanged;
   property onpageadded;
   property onpageremoved;
   property font;
   property fontempty;
   property tab_options;
   property tab_font;
   property tab_fonttab;
   property tab_fontactivetab;
   property tab_frame;
   property tab_face;
   property tab_color;
   property tab_imagepos;
   property tab_textflags;
   property tab_width;
   property tab_widthmin;
   property tab_widthmax;
   {
   property tab_captionframe_left;
   property tab_captionframe_top;
   property tab_captionframe_right;
   property tab_captionframe_bottom;
   property tab_imagedist;
   }
   property tab_shift;
   property tab_edge_level;
   property tab_edge_colordkshadow;
   property tab_edge_colorshadow;
   property tab_edge_colorlight;
   property tab_edge_colorhighlight;
   property tab_edge_colordkwidth;
   property tab_edge_colorhlwidth;
   property tab_edge_imagelist;
   property tab_edge_imageoffset;
   property tab_colortab;
   property tab_coloractivetab;
   property tab_frametab;
   property tab_facetab;
   property tab_faceactivetab;
   property tab_sizemin;
   property tab_sizemax;
   property tab_size;
   property tab_optionswidget;
   property tab_optionswidget1;
   property tab_optionsskin;
   property tab_edge_imagepaintshift;
   property statfile;
   property statvarname;
   property statpriority;
 end;

var
 tabcloser: boolean = false;

implementation
uses
 sysutils,msearrayutils,msekeyboard,
{$ifdef mse_dynpo}
 msestockobjects_dynpo,
{$else}
 msestockobjects,
{$endif}
 msebits;

type
 twidget1 = class(twidget);
 tmsecomponent1 = class(tmsecomponent);
 tcustomstepframe1 = class(tcustomstepframe);
 ttabframe1 = class(ttabframe);
 ttaborderoverride1 = class(ttaborderoverride);

procedure calctablayout(var layout: tabbarlayoutinfoty;
                     const canvas: tcanvas; const focused: boolean);

var
 horzimage: boolean;
 vertimage: boolean;
 imagedi: int32;
 imagedi1: int32;
 imagedi2: int32;

 procedure docommon(const tab: ttab; var cell: shapeinfoty; var textrect: rectty);
 begin
  with tab,cell,ca do begin
   caption:= frichcaption;
   textflags:= layout.tabs.ftextflags;
   imagedist:= imagedi;
   imagedist1:= imagedi1;
   imagedist2:= imagedi2;
   imagepos:= layout.tabs.fimagepos;//captiontoimagepos[layout.tabs.fcaptionpos];
   imagelist:= fimagelist;
   imagenr:= fimagenr;
   imagenrdisabled:= fimagenrdisabled;
   if imagelist <> nil then begin
    if not vertimage then begin
     inc(textrect.cx,fimagelist.width+imagedist);
    end;
    if not horzimage then begin
     inc(textrect.cy,fimagelist.height+imagedist);
    end;
   end;
   facetemplate:= nil;
   if ts_active in fstate then begin
    if tab.faceactive <> nil then begin
     facetemplate:= tab.faceactive.template;
    end;
   end
   else begin
    if tab.face <> nil then begin
     facetemplate:= tab.face.template;
    end;
   end;
  end;
 end; //docommon

 procedure dofont(const tab: ttab; var cell: shapeinfoty);
 begin
  with tab,cell,ca do begin
   if ts_active in tab.state then begin
    font:= tab.fontactive;
   end
   else begin
    font:= tab.font;
   end;
  end;
 end; //dofont

var
 int1,int2: integer;
 asize: integer;
 aval: integer;
 endval: integer;
 rect1: rectty;
 bo1: boolean;
 cxinflate: integer;
 cyinflate: integer;
 cxsizeinflate: integer;
 cysizeinflate: integer;
 frame1: framety;
 textflags1: textflagsty;
 negtabshift1: boolean;
 tabshift1: int32;
 edgesize: int32;
 normpos,normsize: int32;
 extraspace1: int32;
 extra1: int32;
 imageinflate: int32;
 i1: int32;
 maximagesize: int32;

begin
 with layout do begin
  horzimage:= tabs.imagepos in horzimagepos;
  vertimage:= tabs.imagepos in vertimagepos;
  cells:= nil;
  setlength(cells,tabs.count);
  if firsttab > high(cells) then begin
   firsttab:= 0;
  end;
  lasttab:= -1;
  edgesize:= tabs.getedgeshift();
  textflags1:= tabs.textflags - [tf_ellipseleft,tf_ellipseright];
  tabshift1:= tabs.ftabshift;
  negtabshift1:= tabshift1 < 0;
  if tabs.fframe <> nil then begin
   with tabs.fframe do begin
    extraspace1:= extraspace;
//    captionframe:= nullframe;
    captionframe:= framei;
    imagedi:= imagedist;
    imagedi1:= imagedist1;
    imagedi2:= imagedist2;
   end;
  end
  else begin
   extraspace1:= 0;
   captionframe.left:= defaultcaptiondist;
   captionframe.top:= defaultcaptiondist;
   captionframe.right:= defaultcaptiondist;
   captionframe.bottom:= defaultcaptiondist;
   imagedi:= defaultimagedist;
   imagedi1:= 0;
   imagedi2:= 0;
  end;
  cxinflate:= captionframe.left + captionframe.right + 2; //for not flat button
  cyinflate:= captionframe.top + captionframe.bottom + 2; //for not flat button
  imageinflate:= imagedi1 + imagedi2 + 2;                 //for not flat button
  if tabs.fframe <> nil then begin
   with tabs.fframe do begin
    frame1:= frameo;
    cxinflate:= cxinflate + frame1.left + frame1.right + frameframecx;
    cyinflate:= cyinflate + frame1.top + frame1.bottom + frameframecy;
    if fso_flat in optionsskin then begin
     cxinflate:= cxinflate - 2;
     cyinflate:= cyinflate - 2;
     imageinflate:= imageinflate - 2;
    end;
   end;
  end;

  cxsizeinflate:= cxinflate;
  cysizeinflate:= cyinflate;
  if shs_vert in options then begin
   cxsizeinflate:= cxsizeinflate + edgesize;
   normsize:= dim.cx - edgesize;
   normpos:= dim.x;
   if negtabshift1 then begin
    cxsizeinflate:= cxsizeinflate - tabshift1;
    normsize:= normsize + tabshift1;
   end;
   if shs_opposite in options then begin
    normpos:= normpos + edgesize;
   end
   else begin
    if negtabshift1 then begin
     normpos:= normpos - tabshift1;
    end;
   end;
  end
  else begin
   cysizeinflate:= cysizeinflate + edgesize;
   normsize:= dim.cy - edgesize;
   normpos:= dim.y;
   if negtabshift1 then begin
    cysizeinflate:= cysizeinflate - tabshift1;
    normsize:= normsize + tabshift1;
   end;
   if shs_opposite in options then begin
    normpos:= normpos + edgesize;
   end
   else begin
    if negtabshift1 then begin
     normpos:= normpos - tabshift1;
    end;
   end;
  end;
  if shs_vert in options then begin
   totsize.cx:= 0;
   aval:= dim.y;
   asize:= aval;
   endval:= dim.y + dim.cy;
   for int1:= 0 to high(cells) do begin
    with tabs[int1],cells[int1],ca do begin
     extra1:= 0;
     if int1 <> 0 then begin
      aval:= aval + extraspace1;
     end;
     if int1 <> high(cells) then begin
      extra1:= extraspace1;
     end;
     dim.y:= aval;
     dofont(tabs[int1],cells[int1]);
     rect1:= textrect(canvas,frichcaption,
                makerect(normpos,aval,normsize-cxinflate,bigint),
                                                              textflags1,font);
     docommon(tabs[int1],cells[int1],rect1);
     if rect1.cx > totsize.cx then begin
      totsize.cx:= rect1.cx;
     end;
     if rect1.cx <= layout.dim.cx - cxinflate then begin
      textflags:= textflags - [tf_ellipseleft,tf_ellipseright];
      exclude(fstate,ts_captionclipped);
     end
     else begin
      include(fstate,ts_captionclipped);
     end;
     dim.cy:= rect1.cy+cyinflate;
     if (imagelist <> nil) and not vertimage and
                           (imagelist.height+imageinflate > dim.cy) then begin
      dim.cy:= imagelist.height+imageinflate;
     end;
     bo1:= (ts_invisible in fstate) or (int1 < firsttab);
     if bo1 or (aval >= endval) then begin
      include(state,shs_invisible);
      if not bo1 then begin
       inc(asize,dim.cy+extra1);
      end;
     end
     else begin
      inc(aval,dim.cy);
      inc(asize,dim.cy+extra1);
      if (aval <= endval) then begin
       lasttab:= int1;
      end;
     end;
     if ts_active in fstate then begin
      dim.cx:= layout.dim.cx;
      if not negtabshift1 then begin
       dim.cx:= dim.cx - tabshift1;
       if not (shs_opposite in options) then begin
        dim.x:= tabshift1;
       end;
      end;
     end
     else begin
      dim.x:= normpos;
      dim.cx:= normsize;
     end;
     dim.x:= dim.x + layout.dim.x;
    end;
   end;
   totsize.cy:= asize-dim.y;
   totsize.cx:= totsize.cx + cxsizeinflate;
  end
  else begin //horizontal
   aval:= dim.x;
   asize:= aval;
   endval:= dim.x + dim.cx;
   totsize.cy:= 0;
   maximagesize:= 0;
   for int1:= 0 to high(cells) do begin
    with tabs[int1],cells[int1],ca do begin
     extra1:= 0;
     if int1 <> 0 then begin
      aval:= aval + extraspace1;
     end;
     if int1 <> high(cells) then begin
      extra1:= extraspace1;
     end;
     dim.x:= aval;
     dofont(tabs[int1],cells[int1]);
     rect1:= textrect(canvas,frichcaption,
                makerect(aval,normpos,bigint,normsize-cyinflate),
                                                              textflags1,font);
     docommon(tabs[int1],cells[int1],rect1);
     if rect1.cy > totsize.cy then begin
      totsize.cy:= rect1.cy;
     end;
     int2:= rect1.cx;
     with layout.tabs do begin
      if width <> 0 then begin
       int2:= width;
      end;
      if (widthmax <> 0) and (rect1.cx > widthmax) then begin
       int2:= widthmax;
      end;
      if (widthmin <> 0) and (rect1.cx < widthmin) then begin
       int2:= widthmin;
      end;
     end;
     if int2 >= rect1.cx then begin
      textflags:= textflags - [tf_ellipseleft,tf_ellipseright];
      exclude(fstate,ts_captionclipped);
     end
     else begin
      include(fstate,ts_captionclipped);
     end;
     rect1.cx:= int2;

     dim.cx:= rect1.cx + cxinflate;
     if (imagelist <> nil) then begin
      i1:= imagelist.height;
      if not vertimage then begin
       i1:= i1 + imageinflate;
       if i1 > maximagesize then begin
        maximagesize:= i1;
       end;
      end;
     end;
     bo1:= (ts_invisible in fstate) or (int1 < firsttab);
     if bo1 or (aval >= endval) then begin
      include(state,shs_invisible);
      if not bo1 then begin
       inc(asize,dim.cx+extra1);
      end;
     end
     else begin
      inc(aval,dim.cx);
      inc(asize,dim.cx+extra1);
      if (aval <= endval) then begin
       lasttab:= int1;
      end;
     end;
     if ts_active in fstate then begin
      dim.cy:= layout.dim.cy;
      if not negtabshift1 then begin
       dim.cy:= dim.cy - tabshift1;
       if not (shs_opposite in options) then begin
        dim.y:= tabshift1;
       end;
      end;
     end
     else begin
      dim.y:= normpos;
      dim.cy:= normsize;
     end;
     dim.y:= dim.y + layout.dim.y;
    end;
   end;
   totsize.cx:= asize-dim.x;
   if totsize.cy = 0 then begin
    totsize.cy:= twidget1(tabs.fowner).getfont1.glyphheight;
   end;
   totsize.cy:= totsize.cy + cysizeinflate;
   maximagesize:= maximagesize + cysizeinflate - cyinflate;
                                         //space for tabshift and edge
   if totsize.cy < maximagesize then begin
    totsize.cy:= maximagesize;
   end;
  end; //horizontal
  bo1:= not twidget(tabs.fowner).isenabled;
  for int1:= 0 to high(cells) do begin
   with tabs[int1],cells[int1],ca do begin
    state:= (state + [shs_showfocusrect] + options * [shs_vert,shs_opposite]) -
                                                      [shs_focused];
    if ts_active in fstate then begin
     include(state,shs_active);
     if focused then begin
      state:= state + [shs_focused];
     end;
     if fcoloractive = cl_default then begin
      color:= tabs.fcoloractive;
     end
     else begin
      color:= fcoloractive;
     end;
     if color = cl_default then begin
      color:= defaultcoloractivetab;
     end;
     coloractive:= color;
     face:= tabs.ffaceactive;
    end
    else begin
     exclude(state,shs_active);
     if fcolor = cl_default then begin
      color:= tabs.fcolor;
     end
     else begin
      color:= fcolor;
     end;
     if color = cl_default then begin
      color:= defaultcolortab;
     end;
     face:= tabs.face;
    end;
    if ts_noface in fstate then begin
     face:= nil;
    end;
    if bo1 or (ts_disabled in fstate) then begin
     include(state,shs_disabled);
    end;
    doexecute:= {$ifdef FPC}@{$endif}execute;
   end;
  end;
  with stepinfo do begin
   up:= 0;
   for int1:= firsttab to high(cells) do begin
    if not (shs_invisible in cells[int1].state) and (up = 0) then begin
     up:= int1-firsttab;
     break;
    end;
   end;
   if up = 0 then begin
    up:= 1;
   end;
   pageup:= lasttab - firsttab + 1;
   if firsttab = 0 then begin
    pagedown:= 0;
   end
   else begin
    pagedown:= 1;
   end;
   aval:= 0;
   pagelast:= 0;
   endval:= 0;
   down:= 0;
   if shs_vert in options then begin
    for int1:= firsttab - 1 downto 0 do begin
     with cells[int1].ca do begin
      dec(pagedown);
      if not (ts_invisible in tabs[int1].fstate) then begin
       inc(aval,dim.cy);
       if down = 0 then begin
        down:= int1-firsttab;
       end;
      end;
     end;
     if aval >= dim.cy then begin
      break;
     end;
     if int1 = 0 then begin
      dec(pagedown);
     end;
    end;
    for int1:= high(cells) downto 0 do begin
     with cells[int1].ca do begin
      inc(pagelast);
      if not (ts_invisible in tabs[int1].fstate) then begin
       inc(endval,dim.cy);
      end;
     end;
     if endval >= dim.cy then begin
      break;
     end;
    end;
    if endval > dim.cy then begin
     dec(pagelast);
    end;
   end
   else begin
    for int1:= firsttab - 1 downto 0 do begin
     with cells[int1].ca do begin
      dec(pagedown);
      if not (ts_invisible in tabs[int1].fstate) then begin
       inc(aval,dim.cx);
       if down = 0 then begin
        down:= int1-firsttab;
       end;
      end;
     end;
     if aval >= dim.cx then begin
      break;
     end;
     if int1 = 0 then begin
      dec(pagedown);
     end;
    end;
    for int1:= high(cells) downto 0 do begin
     with cells[int1].ca do begin
      inc(pagelast);
      if not (ts_invisible in tabs[int1].fstate) then begin
       inc(endval,dim.cx);
      end;
     end;
     if endval >= dim.cx then begin
      break;
     end;
    end;
    if endval > dim.cx then begin
     dec(pagelast);
    end;
   end;
   if down = 0 then begin
    down:= -1;
   end;
   pagelast:= length(cells)-pagelast-firsttab;
  end;
  inc(lasttab);
  notfull:= lasttab > high(cells);
  if notfull then begin
   lasttab:= high(cells);
  end;
 end;
end;

{ ttabfont }

class function ttabfont.getinstancepo(owner: tobject): pfont;
begin
 result:= @ttab(owner).ffont;
end;

{ ttabfontactive }

class function ttabfontactive.getinstancepo(owner: tobject): pfont;
begin
 result:= @ttab(owner).ffontactive;
end;

{ ttab }

constructor ttab.create(const aowner: tcustomtabbar);
begin
 fcolor:= cl_default;
 fcoloractive:= cl_default;
 fimagenr:= -1;
 fimagenrdisabled:= -2;
 inherited create(aowner,aowner.flayoutinfo.tabs);
end;

destructor ttab.destroy;
begin
 ffont.free;
 ffontactive.free;
 inherited;
end;

procedure ttab.changed;
begin
 if not (ts_updating in fstate) then begin
  tcustomtabbar(fowner).tabchanged(self);
 end;
end;

procedure ttab.createfont;
begin
 if ffont = nil then begin
  ffont:= ttabfont.create;
  ffont.onchange:= {$ifdef FPC}@{$endif}fontchanged;
 end;
end;

function ttab.getfont: ttabfont;
begin
 getoptionalobject(ttabbar(fowner).componentstate,ffont,
                            {$ifdef FPC}@{$endif}createfont);
 if ffont <> nil then begin
  result:= ffont;
 end
 else begin
  result:= ttabfont(pointer(ttabs(prop).getfont));
 end;
end;

procedure ttab.setfont(const avalue: ttabfont);
begin
 if avalue <> ffont then begin
  setoptionalobject(ttabbar(fowner).ComponentState,avalue,ffont,
                                       {$ifdef FPC}@{$endif}createfont);
  changed;
 end;
end;

function ttab.isfontstored: boolean;
begin
 result:= ffont <> nil;
end;

procedure ttab.createfontactive;
begin
 if ffontactive = nil then begin
  ffontactive:= ttabfontactive.create;
  ffontactive.onchange:= {$ifdef FPC}@{$endif}fontchanged;
 end;
end;

function ttab.getfontactive: ttabfontactive;
begin
 getoptionalobject(ttabbar(fowner).componentstate,ffontactive,
                            {$ifdef FPC}@{$endif}createfontactive);
 if ffontactive <> nil then begin
  result:= ffontactive;
 end
 else begin
  result:= ttabfontactive(pointer(ttabs(prop).getfontactive));
 end;
end;

procedure ttab.setfontactive(const avalue: ttabfontactive);
begin
 if avalue <> ffontactive then begin
  setoptionalobject(ttabbar(fowner).ComponentState,avalue,ffontactive,
                                       {$ifdef FPC}@{$endif}createfontactive);
  changed;
 end;
end;

function ttab.isfontactivestored: boolean;
begin
 result:= ffontactive <> nil;
end;

{
function ttab.getcaption: captionty;
begin
 result:= richstringtocaption(fcaption);
end;
}
procedure ttab.setcaption(const avalue: captionty);
begin
 fcaption:= avalue;
 captiontorichstring(avalue,frichcaption);
 changed;
end;

function ttab.tabbar: tcustomtabbar;
begin
 result:= tcustomtabbar(fowner);
end;

procedure ttab.setstate(const Value: tabstatesty);
begin
 if fstate <> value then begin
  fstate := Value;
 {
  if (fstate * [ts_invisible,ts_disabled] <> []) and
       not (csdesigning in tcustomtabbar(fowner).componentstate) then begin
   exclude(fstate,ts_active);
  end;
 }
  changed;
 end;
end;

procedure ttab.execute(const tag: integer; const info: mouseeventinfoty);
begin
 tabbar.tabclicked(self,info);
end;

procedure ttab.doshortcut(var info: keyeventinfoty; const sender: twidget);
begin
 if checkshortcut(info,fcaption,true) then begin
  active:= true;
 end;
end;

procedure ttab.setcolor(const Value: colorty);
begin
 if fcolor <> value then begin
  fcolor := Value;
  changed;
 end;
end;

procedure ttab.setcoloractive(const Value: colorty);
begin
 if fcoloractive <> value then begin
  fcoloractive := Value;
  changed;
 end;
end;

procedure ttab.setface(const avalue: tfacecomp);
begin
 if fface <> avalue then begin
  setlinkedvar(avalue,tmsecomponent(fface));
  changed();
 end;
end;

procedure ttab.setfaceactive(const avalue: tfacecomp);
begin
 if ffaceactive <> avalue then begin
  setlinkedvar(avalue,tmsecomponent(ffaceactive));
  changed();
 end;
end;

function ttab.getactive: boolean;
begin
 result:= ts_active in fstate;
end;

procedure ttab.setactive(const Value: boolean);
begin
 if value then begin
  state:= fstate + [ts_active];
 end
 else begin
  state:= fstate - [ts_active];
 end;
end;

procedure ttab.setimagelist(const avalue: timagelist);
begin
 if avalue <> fimagelist then begin
  setlinkedvar(avalue,tmsecomponent(fimagelist));
  changed;
 end;
end;

procedure ttab.setimagenr(const avalue: imagenrty);
begin
 if fimagenr <> avalue then begin
  fimagenr:= avalue;
  changed;
 end;
end;

procedure ttab.setimagenrdisabled(const avalue: imagenrty);
begin
 if fimagenrdisabled <> avalue then begin
  fimagenrdisabled:= avalue;
  changed;
 end;
end;

procedure ttab.objectevent(const sender: tobject; const event: objecteventty);
begin
 inherited;
 if event = oe_destroyed then begin
  if sender = fimagelist then begin
   fimagelist:= nil;
   changed();
  end;
  if sender = fface then begin
   fface:= nil;
   changed();
  end;
  if sender = ffaceactive then begin
   ffaceactive:= nil;
   changed();
  end;
 end
 else begin
  if event = oe_changed then begin
   changed;
  end;
 end;
end;

function ttab.getimagelist: timagelist;
begin
 result:= fimagelist;
end;

procedure ttab.fontchanged(const sender: tobject);
begin
 changed;
end;
{
procedure ttab.setwidth(const avalue: integer);
begin
 if fwidth <> avalue then begin
  fwidth:= avalue;
  changed;
 end;
end;

procedure ttab.setwidthmin(const avalue: integer);
begin
 if fwidthmin <> avalue then begin
  fwidthmin:= avalue;
  changed;
 end;
end;

procedure ttab.setwidthmax(const avalue: integer);
begin
 if fwidthmax <> avalue then begin
  fwidthmax:= avalue;
  changed;
 end;
end;
}
{ ttabframe }

constructor ttabframe.create(const aintf: iframe);
begin
 fi.innerframe.left:= defaultcaptiondist;
 fi.innerframe.top:= defaultcaptiondist;
 fi.innerframe.right:= defaultcaptiondist;
 fi.innerframe.bottom:= defaultcaptiondist;
 fi.imagedist:= defaultimagedist;
 inherited;
 include(fstate,fs_needsmouseinvalidate);
end;

{ ttabsfont }

class function ttabsfont.getinstancepo(owner: tobject): pfont;
begin
 result:= @ttabs(owner).ffont;
end;

{ ttabsfontactive }

class function ttabsfontactive.getinstancepo(owner: tobject): pfont;
begin
 result:= @ttabs(owner).ffontactive;
end;

{ ttabs }

constructor ttabs.create(const aowner: tcustomtabbar;
                                  aclasstype: indexpersistentclassty);
begin
 flabel := Tlabel.create(nil);
 flabel.visible := false;
 fcolor:= cl_default;
 fcoloractive:= cl_default;
 fimagepos:= defaultimagepos;
 ftextflags:= defaultcaptiontextflags;
 {
 fcaptionframe.left:= defaultcaptiondist;
 fcaptionframe.top:= defaultcaptiondist;
 fcaptionframe.right:= defaultcaptiondist;
 fcaptionframe.bottom:= defaultcaptiondist;
 fimagedist:= defaultimagedist;
 }
 fshift:= defaulttabshift;
 ftabshift:= 1;
 fedge_level:= defaultedgelevel;
 initdefaultvalues(fedge);
 inherited create(aowner,aclasstype);
end;

destructor ttabs.destroy;
begin
 fface.free;
 ffaceactive.free;
 fframe.free;
 ffont.free;
 ffontactive.free;
 flabel.free;

 inherited;
end;

class function ttabs.getitemclasstype: persistentclassty;
begin
 result:= ttab;
end;

procedure ttabs.readcaptionpos(reader: treader);
begin
 imagepos:= readcaptiontoimagepos(reader);
end;

procedure ttabs.readcaptionframe_left(reader: treader);
begin
 createframe();
 ttabframe1(fframe).fi.innerframe.left:= reader.readinteger;
end;

procedure ttabs.readcaptionframe_top(reader: treader);
begin
 createframe();
 ttabframe1(fframe).fi.innerframe.top:= reader.readinteger;
end;

procedure ttabs.readcaptionframe_right(reader: treader);
begin
 createframe();
 ttabframe1(fframe).fi.innerframe.right:= reader.readinteger;
end;

procedure ttabs.readcaptionframe_bottom(reader: treader);
begin
 createframe();
 ttabframe1(fframe).fi.innerframe.bottom:= reader.readinteger;
end;

procedure ttabs.readimagedist(reader: treader);
begin
 createframe();
 ttabframe1(fframe).fi.imagedist:= reader.readinteger;
end;

procedure ttabs.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('captionpos', @readcaptionpos,nil,false);
 filer.defineproperty('captionframe_left', @readcaptionframe_left,nil,false);
 filer.defineproperty('captionframe_top', @readcaptionframe_top,nil,false);
 filer.defineproperty('captionframe_right', @readcaptionframe_right,nil,false);
 filer.defineproperty('captionframe_bottom', @readcaptionframe_bottom,nil,false);
 filer.defineproperty('imagedist', @readimagedist,nil,false);
end;

procedure ttabs.changed;
begin
 tcustomtabbar(fowner).layoutchanged;
end;

procedure ttabs.createface;
begin
 if fface = nil then begin
  fface:= tface.create(iface(tcustomtabbar(fowner)));
 end;
end;

procedure ttabs.createfaceactive;
begin
 if ffaceactive = nil then begin
  ffaceactive:= tface.create(iface(tcustomtabbar(fowner)));
 end;
end;

function ttabs.getface: tface;
begin
 tcustomtabbar(fowner).getoptionalobject(fface,{$ifdef FPC}@{$endif}createface);
 result:= fface;
end;

procedure ttabs.setface(const avalue: tface);
begin
 tcustomtabbar(fowner).setoptionalobject(avalue,fface,{$ifdef FPC}@{$endif}createface);
 changed;
end;

function ttabs.getfaceactive: tface;
begin
 tcustomtabbar(fowner).getoptionalobject(ffaceactive,
                               {$ifdef FPC}@{$endif}createfaceactive);
 result:= ffaceactive;
end;

procedure ttabs.setfaceactive(const avalue: tface);
begin
 tcustomtabbar(fowner).setoptionalobject(avalue,ffaceactive,
                               {$ifdef FPC}@{$endif}createfaceactive);
 changed;
end;

procedure ttabs.setcolor(const avalue: colorty);
begin
 if avalue <> fcolor then begin
  fcolor:= avalue;
  changed;
 end;
end;

procedure ttabs.setcoloractive(const avalue: colorty);
begin
 if avalue <> fcoloractive then begin
  fcoloractive:= avalue;
  changed;
 end;
end;

procedure ttabs.setimagepos(const avalue: imageposty);
begin
 if avalue <> fimagepos then begin
  fimagepos:= avalue;
  changed;
 end;
end;

procedure ttabs.settextflags(const avalue: textflagsty);
begin
 if avalue <> ftextflags then begin
  ftextflags:= checktextflags(ftextflags,avalue);
  changed;
 end;
end;

procedure ttabs.setwidth(const avalue: integer);
begin
 if avalue <> fwidth then begin
  fwidth:= avalue;
  changed;
 end;
end;

procedure ttabs.setwidthmin(const avalue: integer);
begin
 if avalue <> fwidthmin then begin
  fwidthmin:= avalue;
  changed;
 end;
end;

procedure ttabs.setwidthmax(const avalue: integer);
begin
 if avalue <> fwidthmax then begin
  fwidthmax:= avalue;
  changed;
 end;
end;

procedure ttabs.setedge_level(const avalue: int32);
begin
 if avalue <> fedge_level then begin
  fedge_level:= avalue;
  changed();
 end;
end;

procedure ttabs.setedge_colordkshadow(const avalue: colorty);
begin
 if avalue <> fedge.shadow.effectcolor then begin
  fedge.shadow.effectcolor:= avalue;
  changed();
 end;
end;

procedure ttabs.setedge_colorshadow(const avalue: colorty);
begin
 if avalue <> fedge.shadow.color then begin
  fedge.shadow.color:= avalue;
  changed();
 end;
end;

procedure ttabs.setedge_colorlight(const avalue: colorty);
begin
 if avalue <> fedge.light.color then begin
  fedge.light.color:= avalue;
  changed();
 end;
end;

procedure ttabs.setedge_colorhighlight(const avalue: colorty);
begin
 if avalue <> fedge.light.effectcolor then begin
  fedge.light.effectcolor:= avalue;
  changed();
 end;
end;

procedure ttabs.setedge_colordkwidth(const avalue: int32);
begin
 if avalue <> fedge.shadow.effectwidth then begin
  fedge.shadow.effectwidth:= avalue;
  changed();
 end;
end;

procedure ttabs.setedge_colorhlwidth(const avalue: int32);
begin
 if avalue <> fedge.light.effectwidth then begin
  fedge.light.effectwidth:= avalue;
  changed();
 end;
end;

procedure ttabs.setedge_imagelist(const avalue: timagelist);
begin
 if avalue <> fedge_imagelist then begin
  tcustomtabbar(fowner).setlinkedvar(avalue,tmsecomponent(fedge_imagelist));
  changed();
 end;
end;

procedure ttabs.setedge_imageoffset(const avalue: int32);
begin
 if avalue <> fedge_imageoffset then begin
  fedge_imageoffset:= avalue;
  changed();
 end;
end;

procedure ttabs.setedge_imagepaintshift(const avalue: int32);
begin
 if avalue <> fedge_imagepaintshift then begin
  fedge_imagepaintshift:= avalue;
  changed();
 end;
end;
{
procedure ttabs.setcaptionframe_left(const avalue: integer);
begin
 if avalue <> fcaptionframe.left then begin
  fcaptionframe.left:= avalue;
  changed;
 end;
end;

procedure ttabs.setcaptionframe_top(const avalue: integer);
begin
 if avalue <> fcaptionframe.top then begin
  fcaptionframe.top:= avalue;
  changed;
 end;
end;

procedure ttabs.setcaptionframe_right(const avalue: integer);
begin
 if avalue <> fcaptionframe.right then begin
  fcaptionframe.right:= avalue;
  changed;
 end;
end;

procedure ttabs.setcaptionframe_bottom(const avalue: integer);
begin
 if avalue <> fcaptionframe.bottom then begin
  fcaptionframe.bottom:= avalue;
  changed;
 end;
end;

procedure ttabs.setimagedist(const avalue: integer);
begin
 if avalue <> fimagedist then begin
  fimagedist:= avalue;
  changed;
 end;
end;
}
procedure ttabs.setshift(const avalue: integer);
begin
 if avalue <> fshift then begin
  fshift:= avalue;
  if avalue = defaulttabshift then begin
   ftabshift:= 1;
  end
  else begin
   ftabshift:= avalue;
  end;
  changed;
 end;
end;

procedure ttabs.add(const item: ttab);
begin
 inherited add(item);
end;

procedure ttabs.insert(const item: ttab; const aindex: integer);
begin
 tcustomtabbar(fowner).beginupdate;
 try
  inherited add(item);
  move(count-1,aindex);
 finally
  tcustomtabbar(fowner).endupdate
 end;
end;

procedure ttabs.additems(const aitems: msestringarty);
var
 int1,int2: integer;

begin
 tcustomtabbar(fowner).beginupdate;
 try
  int1:= count;
  count:= count + length(aitems);
  for int2:= 0 to high(aitems) do begin
   items[int1].caption:= aitems[int2];
   inc(int1);
  end;
 finally
  tcustomtabbar(fowner).endupdate;
 end;
end;

procedure ttabs.createitem(const index: integer; var item: tpersistent);
begin
 if item = nil then begin
  if assigned(foncreatetab) then begin
   foncreatetab(tcustomtabbar(fowner),index,ttab(item));
  end;
  if item = nil then begin
   item:= ttab.create(tcustomtabbar(fowner));
  end;
 end;
 ttab(item).findex:= index;
end;

function ttabs.getitems(const index: integer): ttab;
begin
 result:= ttab(inherited items[index]);
end;

function ttabs.indexof(const item: ttab): integer;
var
 int1: integer;
begin
 result:= -1;
 for int1:= 0 to high(fitems) do begin
  if items[int1] = item then begin
   result:= int1;
   break;
  end;
 end;
end;

procedure ttabs.setitems(const index: integer; const Value: ttab);
begin
 inherited items[index].assign(value);
end;

procedure ttabs.checktemplate(const sender: tobject);
begin
 if frame <> nil then begin
  fframe.checktemplate(sender);
 end;
 if fface <> nil then begin
  fface.checktemplate(sender);
 end;
 if ffaceactive <> nil then begin
  ffaceactive.checktemplate(sender);
 end;
end;

// iframe

procedure ttabs.setframeinstance(instance: tcustomframe);
begin
 fframe:= ttabframe(instance);
end;

procedure ttabs.setstaticframe(value: boolean);
begin
 //dummy
end;

function ttabs.getstaticframe: boolean;
begin
 result:= false;
end;

function ttabs.getwidgetrect: rectty;
begin
 result:= nullrect;
end;

function ttabs.getcomponentstate: tcomponentstate;
begin
 result:= tcustomtabbar(fowner).componentstate;
end;

function ttabs.getmsecomponentstate: msecomponentstatesty;
begin
 result:= tcustomtabbar(fowner).msecomponentstate;
end;

procedure ttabs.scrollwidgets(const dist: pointty);
begin
 //dummy
end;

procedure ttabs.clientrectchanged;
begin
 changed;
end;

procedure ttabs.invalidate;
begin
 tcustomtabbar(fowner).invalidate;
end;

procedure ttabs.invalidatewidget;
begin
 tcustomtabbar(fowner).invalidatewidget;
end;

procedure ttabs.invalidaterect(const rect: rectty;
               const org: originty = org_client; const noclip: boolean = false);
begin
 tcustomtabbar(fowner).invalidaterect(rect,org,noclip);
end;

function ttabs.getwidget: twidget;
begin
 result:= tcustomtabbar(fowner);
end;

function ttabs.getframestateflags: framestateflagsty;
begin
 with tcustomtabbar(fowner).flayoutinfo do begin
  result:= shapestatetoframestate(factcellindex,cells);
  if factcellindex = firsttab then begin
   include(result,fsf_offset1);
  end;
 end;
end;

function ttabs.getedgeshift(): int32;
begin
 result:= 1; //default
 if fedge_imagelist <> nil then begin
  if tabo_vertical in tcustomtabbar(fowner).foptions then begin
   result:= fedge_imagelist.height;
  end
  else begin
   result:= fedge_imagelist.width;
  end;
  result:= result + fedge_imagepaintshift;
 end
 else begin
  if fedge_level <> defaultedgelevel then begin
   result:= fedge_level;
  end;
 end;
end;

procedure ttabs.dochange(const index: integer);
begin
 inherited;
 if (index < 0) and (fskinupdating = 0) and (count > 0) and
            not (csloading in tcustomtabbar(fowner).componentstate) then begin
  tcustomtabbar(fowner).updateskin;
        //could be a new item which needs skin setup
 end;
end;

function ttabs.getframe: ttabframe;
begin
 tcustomtabbar(fowner).getoptionalobject(fframe,
                               {$ifdef FPC}@{$endif}createframe);
 result:= fframe;
end;

procedure ttabs.setframe(const avalue: ttabframe);
var int1: integer;
begin
 tcustomtabbar(fowner).setoptionalobject(avalue,fframe,
                               {$ifdef FPC}@{$endif}createframe);
 if fframe = nil then begin
  with tcustomtabbar(fowner).flayoutinfo do begin
   for int1:= 0 to high(cells) do begin
    with cells[int1] do begin
     state:= state - [shs_flat,shs_noanimation];
    end;
   end;
  end;
 end;
 changed;
// tcustomtabbar(fowner).invalidatewidget;
end;

procedure ttabs.createframe;
begin
 if fframe = nil then begin
  fframe:= ttabframe.create(iframe(self));
 end;
end;

procedure ttabs.createfont;
begin
 if ffont = nil then begin
  ffont:= ttabsfont.create;
  ffont.onchange:= {$ifdef FPC}@{$endif}fontchanged;
 end;
end;

function ttabs.getfont: ttabsfont;
begin
 getoptionalobject(ttabbar(fowner).componentstate,ffont,
                            {$ifdef FPC}@{$endif}createfont);
 if ffont <> nil then begin
  result:= ffont;
 end
 else begin
  result:= ttabsfont(pointer(ttabbar(fowner).getfont));
 end;
end;

procedure ttabs.setfont(const avalue: ttabsfont);
begin
 if avalue <> ffont then begin
  setoptionalobject(ttabbar(fowner).ComponentState,avalue,ffont,
                                       {$ifdef FPC}@{$endif}createfont);
  changed;
 end;
end;

function ttabs.isfontstored: boolean;
begin
 result:= ffont <> nil;
end;

procedure ttabs.createfontactive;
begin
 if ffontactive = nil then begin
  ffontactive:= ttabsfontactive.create;
  ffontactive.onchange:= {$ifdef FPC}@{$endif}fontchanged;
 end;
end;

function ttabs.getfontactive: ttabsfontactive;
begin
 getoptionalobject(ttabbar(fowner).componentstate,ffontactive,
                            {$ifdef FPC}@{$endif}createfontactive);
 if ffontactive <> nil then begin
  result:= ffontactive;
 end
 else begin
  result:= ttabsfontactive(pointer(ttabbar(fowner).getfont));
 end;
end;

procedure ttabs.setfontactive(const avalue: ttabsfontactive);
begin
 if avalue <> ffontactive then begin
  setoptionalobject(ttabbar(fowner).ComponentState,avalue,ffontactive,
                                       {$ifdef FPC}@{$endif}createfontactive);
  changed;
 end;
end;

function ttabs.isfontactivestored: boolean;
begin
 result:= ffontactive <> nil;
end;

procedure ttabs.fontchanged(const sender: tobject);
begin
 changed;
end;

{ tcustomtabbar }

constructor tcustomtabbar.create(aowner: tcomponent);
begin
 flayoutinfo.tabs:= ttabs.create(self,nil);
 flayoutinfo.tabs.onchange:= {$ifdef FPC}@{$endif}tabschanged;
 flayoutinfo.activetab:= -1;
 flayoutinfo.focusedtab:= -1;
 flayoutinfo.lasttab:= -1;
 fhintedbutton:= -2;
 inherited;
 fwidgetrect.cy:= font.glyphheight + 4;
 foptionswidget1:= defaultoptionswidget1tab;
end;

destructor tcustomtabbar.destroy;
begin
 killrepeater();
 flayoutinfo.tabs.free();
 inherited;
end;

procedure tcustomtabbar.settabs(const Value: ttabs);
begin
 flayoutinfo.tabs.assign(Value);
end;

procedure tcustomtabbar.updatelayout();
var
 int1,int2,int3: integer;
begin
 with flayoutinfo do begin
  options:= [];
  if tabo_vertical in foptions then begin
   include(options,shs_vert);
  end;
  if tabo_opposite in foptions then begin
   include(options,shs_opposite);
  end;
  if tabo_vertical in foptions then begin
   frame.buttonpos:= sbp_top;
   frame.buttonslast:= ((tabo_opposite in foptions) xor
                   (tabo_buttonsoutside in foptions));
  end
  else begin
   frame.buttonpos:= sbp_right;
   frame.buttonslast:= ((tabo_opposite in foptions) xor
                   (tabo_buttonsoutside in foptions));
  end;
  for int3:= 7 downto 0 do begin;
   dim:= innerclientrect;
   calctablayout(flayoutinfo,getcanvas,focused);

   int2:= tabs.count;
   for int1:= int2 - 1 downto 0 do begin
    if not (ts_invisible in tabs[int1].fstate) then begin
     int2:= int1+1; //count to last visible
     break;
    end
    else begin
     if int1 = 0 then begin
      int2:= 0;
     end;
    end;
   end;
{
   if shs_vert in options then begin
    int4:= dim.size.cy - totsize.cy + tcustomstepframe1(fframe).fdim.cy;
   end
   else begin
    int4:= dim.size.cx - totsize.cx + tcustomstepframe1(fframe).fdim.cx;
   end;
   notfull:= int4 >= 0;
}
   if (firsttab = 0) and notfull then begin
    int2:= 0;
   end;
   frame.updatebuttonstate(firsttab,stepinfo.pageup,int2);
   include(fstate,tbs_layoutvalid);
   checkautosize;
   if sizeisequal(dim.size,innerclientsize) then begin
    break;
   end;
  end;
 end;
end;

procedure tcustomtabbar.checklayout;
begin
 if not (tbs_layoutvalid in fstate) then begin
  updatelayout;
 end;
end;

procedure tcustomtabbar.layoutchanged;
begin
 exclude(fstate,tbs_layoutvalid);
 invalidate;
 {
 if not (csloading in componentstate) and
                        not (ws_loadedproc in fwidgetstate) and
     not ((owner <> nil) and
          ([csloading,csdestroying]*owner.ComponentState <> [])) and
     not ((fparentwidget <> nil) and
          (ws_loadedproc in twidget1(fparentwidget).fwidgetstate)) then begin
           //todo: support for cssubcomponent in fpc
//  updatelayout;
//  checkautosize;
  invalidate;
 end;
 }
end;

function comptabs(const l,r): integer;
begin
 result:= msecomparetext(ttab(l).frichcaption.text,ttab(r).frichcaption.text);
end;

procedure tcustomtabbar.tabchanged(const sender: ttab);

 procedure updateactivetabindex;
 var
  int1: integer;
  bo1: boolean;
 begin
  with flayoutinfo do begin
   bo1:= false;
   for int1:= 0 to tabs.count - 1 do begin
    with tabs[int1] do begin
     if ts_active in fstate then begin
      bo1:= true;
      if (activetab <> int1) then begin
       if (activetab >= 0) and (activetab <= high(tabs.fitems)) then begin
        exclude(tabs.items[activetab].fstate,ts_active);
       end;
       activetab:= int1;
      end;
     end;
    end;
   end;
   if not bo1 then begin
    activetab:= -1;
   end;
  end;
 end;

var
 int1,int2: integer;
 bo1: boolean;
 activetabbefore: integer;
begin
 if fupdating = 0 then begin
  with flayoutinfo do begin
   activetabbefore:= activetab;
   updateactivetabindex;
   bo1:= activetabbefore <> activetab;
   if bo1 and assigned(finternaltabchange) then begin
    finternaltabchange(false);
   end;
   if tabo_sorted in foptions then begin
    sortarray(pointerarty(flayoutinfo.tabs.fitems),
                                     {$ifdef FPC}@{$endif}comptabs);
    updateactivetabindex;
    if assigned(finternaltabchange) then begin
     finternaltabchange(true);
    end;
   end;
   if bo1 then begin
    if (activetab >= 0) and (activetab <= high(cells)) then begin
     if (tabo_acttabfirst in foptions) and (activetab <> 0) then begin
      flayoutinfo.tabs.move(activetab,0);
      updateactivetabindex;
     end;
     if activetab < firsttab then begin
      firsttab:= activetab;
     end
     else begin
      if activetab >= firsttab + stepinfo.pageup then begin
       firsttab:= activetab + 1;
       int2:= 0;
       if shs_vert in options then begin
        for int1:= activetab downto 0 do begin
         if not (ts_invisible in tabs[int1].fstate) then begin
          inc(int2,cells[int1].ca.dim.cy);
          if int2 >= dim.cy then begin
           break;
          end;
          dec(firsttab);
         end;
        end;
       end
       else begin
        for int1:= activetab downto 0 do begin
         if not (ts_invisible in tabs[int1].fstate) then begin
          inc(int2,cells[int1].ca.dim.cx);
          if int2 >= dim.cx then begin
           break;
          end;
          dec(firsttab);
         end;
        end;
       end;
       if firsttab > activetab then begin
        firsttab:= activetab;
       end;
      end;
     end;
    end;
    doactivetabchanged;
   end;
   layoutchanged;
  end;
 end;
end;

procedure tcustomtabbar.tabclicked(const sender: ttab;
                                             const info: mouseeventinfoty);
begin
 if (tabo_clickedtabfirst in foptions) or
    (tabo_dblclickedtabfirst in foptions) and
                          (ss_double in info.shiftstate) then begin
  movetab(sender.findex,0);
 end;
 sender.active:= true;
 checklayout();
 include(flayoutinfo.cells[sender.index].state,shs_mouse);
end;

procedure tcustomtabbar.tabschanged(const sender: tarrayprop;
  const index: integer);
begin
 tabchanged(nil);
end;

procedure tcustomtabbar.loaded;
begin
 inherited;
// updatelayout;
 doactivetabchanged;
end;

procedure tcustomtabbar.dopaintforeground(const canvas: tcanvas);
var
 int1{,int2,int3}: integer;
// color1: colorty;
 rect1: rectty;
 size1: sizety;
 edgelevel1: int32;
 hiddenedges1: edgesty;
 actcell1: int32;
 po1: pshapeinfoty;
begin
 inherited;
 checklayout;
 with flayoutinfo do begin
//  int1:= high(cells);
  edgelevel1:= tabs.fedge_level;
  if edgelevel1 = defaultedgelevel then begin
   edgelevel1:= -1;
  end;
  actcell1:= -1;
  po1:= @cells[firsttab];
  for int1:= firsttab to lasttab do begin
   with po1^ do begin
    if int1 = activetab then begin
     actcell1:= int1;
    end
    else begin
     tabs.factcellindex:= int1;
     frame:= tabs.fframe; //todo: move to layoutcalc
     if frame <> nil then begin
      drawtab(canvas,po1^,nil);
     end
     else begin
      drawtab(canvas,po1^,@captionframe);
     end;
    end;
   end;
   inc(po1);
  end;
  if (tabs.fedge_imagelist <> nil) or (edgelevel1 <> 0) then begin
   if shs_vert in options then begin
    if shs_opposite in options then begin
     int1:= -4; //imagebase
     hiddenedges1:= [edg_top,edg_bottom,edg_right];
    end
    else begin
     int1:= 0;
     hiddenedges1:= [edg_left,edg_top,edg_bottom];
    end;
   end
   else begin
    if shs_opposite in options then begin
     int1:= -6;
     hiddenedges1:= [edg_left,edg_bottom,edg_right];
    end
    else begin
     int1:= -2;
    end;
   end;
   rect1:= paintsizerect;
   size1:= tcustomstepframe1(fframe).fdim.size; //todo: button positions
   if shs_vert in options then begin
    rect1.y:= rect1.y - size1.cy;
    rect1.cy:= rect1.cy + size1.cy;
    if shs_opposite in options then begin
     hiddenedges1:= [edg_top,edg_bottom,edg_right];
    end
    else begin
     hiddenedges1:= [edg_left,edg_top,edg_bottom];
    end;
   end
   else begin
    rect1.cx:= rect1.cx + size1.cx;
    if shs_opposite in options then begin
     hiddenedges1:= [edg_left,edg_bottom,edg_right];
    end
    else begin
     hiddenedges1:= [edg_left,edg_top,edg_right];
    end;
   end;
   if edgelevel1 <> 0 then begin
    draw3dframe(canvas,rect1,edgelevel1,
                                  tabs.fedge,hiddenedges1);
   end;
   if tabs.fedge_imagelist <> nil then begin
    drawimageframe(canvas,tabs.fedge_imagelist,tabs.fedge_imageoffset+int1,
                   rect1,hiddenedges1);
   end;
  end;
  if actcell1 >= 0 then begin
   tabs.factcellindex:= actcell1;
   po1:= @cells[actcell1];
   po1^.frame:= tabs.fframe; //todo: move to layoutcalc
   if tabs.fframe = nil then begin
    drawtab(canvas,po1^,@captionframe);
   end
   else begin
    drawtab(canvas,po1^,nil);
   end;
  end;
 end;
end;

function tcustomtabbar.getactivetab: integer;
begin
 result:= flayoutinfo.activetab;
end;

procedure tcustomtabbar.setactivetab(const Value: integer);
var
 int1: integer;

begin
 if value < 0 then begin
  if activetab >= 0 then begin
   flayoutinfo.tabs.items[activetab].state:=
       flayoutinfo.tabs.items[activetab].state - [ts_active];
  end;
 end
 else begin
  int1:= value;
  if int1 >= tabs.count then begin
   int1:= tabs.count - 1
  end;
  if int1 >= 0 then begin
   flayoutinfo.tabs.items[int1].state:=
      flayoutinfo.tabs.items[int1].state + [ts_active];
  end;
 end;
end;

function tcustomtabbar.activetag: integer;
   //0 if no activetab, activetab.tag otherwise
begin
 with flayoutinfo do begin
  if activetab < 0 then begin
   result:= 0;
  end
  else begin
   result:= tabs[activetab].ftag;
  end;
 end;
end;

procedure tcustomtabbar.clientmouseevent(var info: mouseeventinfoty);
var
i, w1, w2 : integer;
found : boolean = false;
begin

 if not (es_processed in info.eventstate) and
                           canevent(tmethod(fonclientmouseevent)) then begin
  fonclientmouseevent(self,info);
 end;
 inherited;
 if updatemouseshapestate(flayoutinfo.cells,info,self,
        flayoutinfo.focusedtab,flayoutinfo.tabs.fframe) and
      (not (csdesigning in componentstate) or
                        (tbs_designdrag in fstate)) then begin
  include(info.eventstate,es_processed);
 end;
 if not (csdesigning in componentstate) or
                            (ws1_designactive in fwidgetstate1) then begin
  with flayoutinfo do begin

    if  (tabcloser = true) and  (info.eventkind = ek_buttonrelease) and (tabs.count > 1) then
      begin

       w1 := 0;
       w2 := 0;
       i := flayoutinfo.firsttab ;

      // writeln('flayoutinfo.firsttab = ' + inttostr(i));

       while (i < tabs.count) and (found = false)  do
       begin

         tabs.flabel.font.width := tabs[i].font.width;
         tabs.flabel.font.height := tabs[i].font.height;
         tabs.flabel.caption := tabs[i].caption;

         w2 := w2 + tabs.flabel.width + 20;

         w1 := w2 + 1;
         inc(i);

        end;
     end else
        checkbuttonhint(self,info,fhintedbutton,cells,
                           {$ifdef FPC}@{$endif}getbuttonhint,
                           {$ifdef FPC}@{$endif}gethintpos);
   end;
 end;
end;

procedure tcustomtabbar.statechanged;
begin
 inherited;
 with flayoutinfo do begin
  if (activetab >= 0) and (activetab <= high(cells)) then begin
   updatewidgetshapestate(flayoutinfo.cells[activetab],self,false,fframe);
  end;
 end;
end;

procedure tcustomtabbar.doshortcut(var info: keyeventinfoty; const sender: twidget);
var
 int1,int2: integer;
begin
 if not (csdesigning in componentstate) then begin
  int2:= activetab + 1;
  if int2 >= tabs.count then begin
   int2:= 0;
  end;
  for int1:= int2 to tabs.count - 1 do begin
   if es_processed in info.eventstate then begin
    break;
   end;
   flayoutinfo.tabs[int1].doshortcut(info,sender);
  end;
  for int1:= 0 to int2 - 1 do begin
   if es_processed in info.eventstate then begin
    break;
   end;
   flayoutinfo.tabs[int1].doshortcut(info,sender);
  end;
 end;
 inherited;
end;

procedure tcustomtabbar.clientrectchanged;
begin
 inherited;
 layoutchanged;
end;
{
procedure tcustomtabbar.dofontheightdelta(var delta: integer);
begin
 if not (tabo_vertical in foptions) then begin
  inherited;
  if delta <> 0 then begin
   synctofontheight;
  end;
 end
 else begin
  layoutchanged;
 end;
end;
}
procedure tcustomtabbar.fontchanged;
begin
 inherited;
 layoutchanged;
end;

procedure tcustomtabbar.getautopaintsize(var asize: sizety);
begin
 inherited;
 checklayout;
 asize.cx:= flayoutinfo.totsize.cx;
 asize.cy:= flayoutinfo.totsize.cy;
 addsize1(asize,innerframewidth);
 if tbs_shrinktozero in fstate then begin
  if tabo_vertical in foptions then begin
   asize.cx:= 0;
  end
  else begin
   asize.cy:= 0;
  end;
 end;
end;

procedure tcustomtabbar.synctofontheight;
var
 size1: sizety;
begin
 inherited;
 if not (tabo_vertical in options) then begin
  size1:= paintsize;
  getautopaintsize(size1);
  size1:= addsize(size1,fframe.paintframedim);
  bounds_cy:= size1.cy;
 end;
end;

procedure tcustomtabbar.doactivetabchanged;
begin
 if canevent(tmethod(fonactivetabchange)) then begin
  fonactivetabchange(self);
 end;
end;

procedure tcustomtabbar.beginupdate;
begin
 inc(fupdating);
end;

procedure tcustomtabbar.endupdate;
begin
 dec(fupdating);
 if fupdating = 0 then begin
  tabchanged(nil);
 end;
end;

function tcustomtabbar.tabatpos(const apos: pointty; const enabledonly: boolean = false): integer;
begin
 begin
  checklayout;
  if enabledonly then begin
   result:= findshapeatpos(flayoutinfo.cells,apos,[shs_invisible,shs_disabled]);
  end
  else begin
   result:= findshapeatpos(flayoutinfo.cells,apos,[shs_invisible]);
  end;
 end;
end;

procedure tcustomtabbar.movetab(curindex,newindex: integer);
begin
 if canevent(tmethod(fontabmoving)) then begin
  fontabmoving(self,curindex,newindex);
 end;
 flayoutinfo.tabs.move(curindex,newindex);
 if canevent(tmethod(fontabmoved)) then begin
  fontabmoved(self,curindex,newindex);
 end;
 if csdesigning in componentstate then begin
  designchanged;
 end;
end;

function tcustomtabbar.dostep(const event: stepkindty; const adelta: real;
                               ashiftstate: shiftstatesty): boolean;
var
 stepinfo1: framestepinfoty;
 i1: int32;
begin
 result:= false;
 if frame.canstep then begin
  stepinfo1:= flayoutinfo.stepinfo;
  if ss_ctrl in ashiftstate then begin
   with stepinfo1 do begin  //reverst step height
    i1:= pagedown;
    pagedown:= down;
    down:= i1;
    i1:= pageup;
    pageup:= up;
    up:= i1;
   end;
   if stepinfo1.pagedown < -1 then begin
    stepinfo1.pagedown:= -1;
   end;
   if stepinfo1.pageup > 1 then begin
    stepinfo1.pageup:= 1;
   end;
  end;
  firsttab:= frame.executestepevent(event,stepinfo1,flayoutinfo.firsttab);
  result:= true;
 end;
end;

procedure tcustomtabbar.setfirsttab(Value: integer);
begin
 with flayoutinfo do begin
  if value >= tabs.count - 1 then begin
   value:= tabs.count - 1;
  end;
  if value < 0 then begin
   value:= 0;
  end;
  if firsttab <> value then begin
   firsttab:= value;
   layoutchanged;
  end;
 end;
end;

procedure tcustomtabbar.setoptions(const avalue: tabbaroptionsty);
var
 optionsbefore: tabbaroptionsty;
 delta: tabbaroptionsty;
 ow1: optionswidget1ty;
begin
 if avalue <> foptions then begin
  optionsbefore:= foptions;
  foptions:= avalue;
  delta:= avalue >< optionsbefore;
  if not (csloading in componentstate) then begin
   if (csdesigning in componentstate) and
                                 (delta * [tabo_vertical] <> []) then begin
    ow1:= optionswidget1;
    if tabo_vertical in avalue then begin
     exclude(ow1,ow1_autowidth);
     if ow1_autowidth in optionswidget1 then begin
      include(ow1,ow1_autoheight);
     end
     else begin
      exclude(ow1,ow1_autoheight);
     end;
    end
    else begin
     include(ow1,ow1_autoheight);
     if ow1_autoheight in optionswidget1 then begin
      include(ow1,ow1_autowidth);
     end
     else begin
      exclude(ow1,ow1_autowidth);
     end;
    end;
    optionswidget1:= ow1;
   end;
   if (delta * [tabo_sorted,tabo_acttabfirst] <> []) then begin
    tabchanged(nil);
   end;
  end;
  if delta * [tabo_vertical,tabo_opposite,tabo_buttonsoutside] <> [] then begin
   layoutchanged;
  end;
 end;
end;

procedure tcustomtabbar.dragevent(var info: draginfoty);
var
 int1: integer;

 function candest: boolean;
 begin
  with info do begin
   if (dragobjectpo^ is ttagdragobject) and (dragobjectpo^.sender = self) and
    ((tabo_dragdest in foptions) or (csdesigning in componentstate)) then begin
    int1:= tabatpos(pos,(tabo_dragdestenabledonly in foptions) and
                            not(csdesigning in componentstate));
    result:= (ttagdragobject(dragobjectpo^).tag <> int1) and
                ((int1 >= 0) {or (csdesigning in componentstate)});
   end
   else begin
    result:= false;
   end;
  end;
 end;

begin
 if not fdragcontroller.beforedragevent(info) then begin
  int1:= 0;
  with info do begin
   case eventkind of
    dek_begin: begin
     if (not (csdesigning in componentstate) or (tbs_designdrag in fstate)) and
                (dragobjectpo^ = nil) and not (tabo_sorted in foptions) and
      ((tabo_dragsource in foptions) or (csdesigning in componentstate)) then begin
      int1:= tabatpos(pos,(tabo_dragsourceenabledonly in foptions) and
                  not (csdesigning in componentstate));
      if int1 >= 0 then begin
       ttagdragobject.create(self,dragobjectpo^,fdragcontroller.pickpos,int1);
      end;
     end;
    end;
    dek_check: begin
     int1:= tabatpos(pos,false);
     with flayoutinfo do begin
      if (int1 < 0) or not ((int1 = firsttab) or (int1 = lasttab)) then begin
       killrepeater;
      end
      else begin
       if (frepeater = nil) or
                  (not(int1 = firsttab) xor (tbs_repeatup in fstate)) then begin
        startrepeater(int1 <> firsttab);
       end;
      end;
     end;
     if candest then begin
      accept:= true;
     end;
    end;
    dek_drop: begin
     killrepeater();
     if candest then begin
      movetab(ttagdragobject(dragobjectpo^).tag,int1);
     end;
    end;
    dek_leavewidget: begin
     killrepeater();
    end;
    else; // Added to make compiler happy
   end;
  end;
 end;
 fdragcontroller.afterdragevent(info);
 if not info.accept then begin
  inherited;
 end;
end;

procedure tcustomtabbar.objectevent(const sender: tobject;
               const event: objecteventty);
begin
 inherited;
 if event = oe_changed then begin
  flayoutinfo.tabs.checktemplate(sender);
 end;
end;

function tcustomtabbar.gethintpos(const aindex: integer): rectty;
begin
 result:= flayoutinfo.cells[aindex].ca.dim;
 inc(result.cy,12);
end;

function tcustomtabbar.getbuttonhint(const aindex: integer): msestring;
begin
 result:= '';
 with flayoutinfo.tabs[aindex] do begin
  if hint <> '' then begin
   result:= hint;
  end
  else begin
   if (ts_captionclipped in fstate) and
                  (tabo_hintclippedtext in options) then begin
    result:= caption;
   end;
  end;
 end;
end;

procedure tcustomtabbar.enabledchanged;
begin
 inherited;
 if not (ws_loadedproc in fwidgetstate) then begin
  layoutchanged;
 end;
end;

class function tcustomtabbar.classskininfo: skininfoty;
begin
 result:= inherited classskininfo;
 result.objectkind:= sok_tabbar;
end;

function tcustomtabbar.upstep(const norotate: boolean): boolean;
var
 int1: integer;
begin
 result:= false;
 with flayoutinfo do begin
  for int1:= activetab + 1 to high(cells) do begin
   if tabs[int1].state * [ts_invisible,ts_disabled] = [] then begin
    result:= true;
    self.activetab:= int1;
    exit;
   end;
  end;
  if not norotate then begin
   for int1:= 0 to activetab - 1 do begin
    if tabs[int1].state * [ts_invisible,ts_disabled] = [] then begin
     result:= true;
     self.activetab:= int1;
     exit;
    end;
   end;
  end;
 end;
end;

function tcustomtabbar.downstep(const norotate: boolean): boolean;
var
 int1: integer;
begin
 result:= false;
 with flayoutinfo do begin
  for int1:= activetab -1 downto 0 do begin
   if tabs[int1].state * [ts_invisible,ts_disabled] = [] then begin
    result:= true;
    self.activetab:= int1;
    exit;
   end;
  end;
  if not norotate then begin
   for int1:= high(cells) downto activetab + 1 do begin
    if tabs[int1].state * [ts_invisible,ts_disabled] = [] then begin
     result:= true;
     self.activetab:= int1;
     exit;
    end;
   end;
  end;
 end;
end;

function tcustomtabbar.getassistivecaption(): msestring;
begin
 with flayoutinfo do begin
  if (focusedtab >= 0) and (focusedtab < tabs.count) then begin
   result:= tabs[focusedtab].caption;
  end
  else begin
   result:= inherited getassistivecaption();
  end;
 end;
end;

function tcustomtabbar.getassistivehint(): msestring;
begin
 with flayoutinfo do begin
  if (focusedtab >= 0) and (focusedtab < tabs.count) then begin
   result:= tabs[focusedtab].hint;
  end
  else begin
   result:= inherited getassistivehint();
  end;
 end;
end;

procedure tcustomtabbar.dokeydown(var info: keyeventinfoty);
var
 bo1: boolean;
begin
 if not (es_processed in info.eventstate) then begin
  bo1:= false;
  if shs_vert in flayoutinfo.options then begin
   case info.key of
    key_down: begin
     bo1:= upstep(ow_arrowfocusout in optionswidget);
    end;
    key_up: begin
     bo1:= downstep(ow_arrowfocusout in optionswidget);
    end;
    else; // Added to make compiler happy
   end;
  end
  else begin
   case info.key of
    key_right: begin
     bo1:= upstep(ow_arrowfocusout in optionswidget);
    end;
    key_left: begin
     bo1:= downstep(ow_arrowfocusout in optionswidget);
    end;
    else; // Added to make compiler happy
   end;
  end;
  if bo1 then begin
   include(info.eventstate,es_processed);
  end
  else begin
   inherited;
  end;
 end;
end;

procedure tcustomtabbar.startrepeater(const up: boolean);
begin
 killrepeater;
 updatebit(longword(fstate),ord(tbs_repeatup),up);
 frepeater:= trepeater.create(500000,200000,@repeatproc);
end;

procedure tcustomtabbar.killrepeater;
begin
 freeandnil(frepeater);
end;

procedure tcustomtabbar.repeatproc(const sender: tobject);
begin
 if tbs_repeatup in fstate then begin
  checklayout();
  if flayoutinfo.notfull then begin
   killrepeater;
  end
  else begin
   firsttab:= firsttab + 1;
  end;
 end
 else begin
  firsttab:= firsttab - 1;
 end;
end;

{ ttabbar }

procedure ttabbar.dostatread(const reader: tstatreader);
begin
 flayoutinfo.tabs.dostatread(reader,tabo_dragdest in foptions);
 if reader.canstate then begin
  activetab:= reader.readinteger('activetab',activetab);
 end;
end;

procedure ttabbar.dostatwrite(const writer: tstatwriter);
begin
 flayoutinfo.tabs.dostatwrite(writer,tabo_dragdest in foptions);
 if writer.canstate then begin
  writer.writeinteger('activetab',activetab);
 end;
end;

function ttabbar.getstatvarname: msestring;
begin
 result:= fstatvarname;
end;

procedure ttabbar.setdragcontroller(const Value: tdragcontroller);
begin
 fdragcontroller.assign(Value);
end;

procedure ttabbar.setstatfile(const Value: tstatfile);
begin
 setstatfilevar(istatfile(self),value,fstatfile);
end;

procedure ttabbar.statreading;
begin
 //dummy
end;

procedure ttabbar.statread;
begin
 //dummy
end;

function ttabbar.getstatpriority: integer;
begin
 result:= fstatpriority;
end;

{ ttabpagefonttab }

class function ttabpagefonttab.getinstancepo(owner: tobject): pfont;
begin
 result:= @ttabpage(owner).ffonttab;
end;

{ ttabpagefontactivetab }

class function ttabpagefontactivetab.getinstancepo(owner: tobject): pfont;
begin
 result:= @ttabpage(owner).ffontactivetab;
end;

{ ttabpage }

constructor ttabpage.create(aowner: tcomponent);
begin
 ftaborderoverride:= ttaborderoverride.create(self);
 inherited;
 fcolortab:= cl_default;
 fcoloractivetab:= cl_default;
 fimagenr:= -1;
// fimagenractive:= -2;
 fimagenrdisabled:= -2;
 foptionswidget:= defaulttaboptionswidget;
 optionsskin:= defaulttabpageskinoptions;
 exclude(fwidgetstate,ws_visible);
end;

destructor ttabpage.destroy;
begin
 inherited;
 freeandnil(ffonttab);
 freeandnil(ffontactivetab);
 ftaborderoverride.free();
end;

class function ttabpage.classskininfo: skininfoty;
begin
 result:= inherited classskininfo;
 result.objectkind:= sok_tabpage;
end;

procedure ttabpage.loaded;
begin
 if fparentwidget is tcustomtabwidget then begin
  include(fwidgetstate1,ws1_nodesignvisible);
 end;
 inherited;
end;

procedure ttabpage.changed;
begin
 if (ftabwidget <> nil) then begin
  ftabwidget.pagechanged(itabpage(self));
 end;
end;

procedure ttabpage.fontchanged1(const sender: tobject);
begin
 changed;
end;

function ttabpage.getcaption: captionty;
begin
 result:= fcaption;
end;

procedure ttabpage.setcaption(const Value: captionty);
begin
 fcaption:= value;
 changed;
end;

function ttabpage.gettabhint: msestring;
begin
 result:= ftabhint;
end;

procedure ttabpage.settabhint(const avalue: msestring);
begin
 ftabhint:= avalue;
 changed;
end;

function ttabpage.gettabnoface: boolean;
begin
 result:= ftabnoface;
end;

procedure ttabpage.settabnoface(const avalue: boolean);
begin
 if ftabnoface <> avalue then begin
  ftabnoface:= avalue;
  changed;
 end;
end;

function ttabpage.getcolortab: colorty;
begin
 result:= fcolortab;
end;

procedure ttabpage.setcolortab(const avalue: colorty);
begin
 if fcolortab <> avalue then begin
  fcolortab:= avalue;
  changed;
 end;
end;

function ttabpage.getcoloractivetab: colorty;
begin
 result:= fcoloractivetab;
end;

procedure ttabpage.setcoloractivetab(const avalue: colorty);
begin
 if fcoloractivetab <> avalue then begin
  fcoloractivetab:= avalue;
  changed;
 end;
end;

procedure ttabpage.setfacetab(const avalue: tfacecomp);
begin
 if ffacetab <> avalue then begin
  setlinkedvar(avalue,tmsecomponent(ffacetab));
  changed();
 end;
end;

procedure ttabpage.setfaceactivetab(const avalue: tfacecomp);
begin
 if ffaceactivetab <> avalue then begin
  setlinkedvar(avalue,tmsecomponent(ffaceactivetab));
  changed();
 end;
end;

function ttabpage.getfacetab: tfacecomp;
begin
 result:= ffacetab;
end;

function ttabpage.getfaceactivetab: tfacecomp;
begin
 result:= ffaceactivetab;
end;

function ttabpage.isvisiblestored: boolean;
begin
 result:= not (fparentwidget is tcustomtabwidget);
end;

procedure ttabpage.settaborderoverride(const avalue: ttaborderoverride);
begin
 ftaborderoverride.assign(avalue);
end;

procedure ttabpage.registerchildwidget(const child: twidget);
begin
 if child is ttabpage then begin
  child.parentwidget:= parentwidget;
 end
 else begin
  inherited;
 end;
end;

function ttabpage.gettabwidget: tcustomtabwidget;
begin
 result:= ftabwidget;
end;

procedure ttabpage.settabwidget(const value: tcustomtabwidget);
begin
 ftabwidget:= value;
end;

procedure ttabpage.visiblechanged;
begin
 inherited;
 changed;
end;

procedure ttabpage.enabledchanged;
begin
 inherited;
 changed;
end;

procedure ttabpage.designselected(const selected: boolean);
begin
 inherited;
 if selected then begin
  if ftabwidget <> nil then begin
   ftabwidget.activepage:= self;
  end;
 end;
end;

function ttabpage.getisactivepage: boolean;
begin
 result:= (ftabwidget <> nil) and (ftabwidget.activepage = self);
end;

procedure ttabpage.setisactivepage(const avalue: boolean);
begin
 if ftabwidget <> nil then begin
  ftabwidget.activepage:= self;
 end;
end;

function ttabpage.nexttaborderoverride(const sender: twidget;
               const down: boolean): twidget;
begin
 result:= ftaborderoverride.nexttaborder(sender,down);
 if result = nil then begin
  result:= inherited nexttaborderoverride(sender,down);
 end;
end;

procedure ttabpage.readstate(reader: treader);
begin
 inherited;
 ttaborderoverride1(ftaborderoverride).endread(reader);
end;

function ttabpage.gettabindex: integer;
begin
 if tabwidget = nil then begin
  result:= -1;
 end
 else begin
  result:= tabwidget.indexof(self);
 end;
end;

procedure ttabpage.settabindex(const avalue: integer);
begin
 if tabwidget <> nil then begin
  tabwidget.movepage(tabindex,avalue);
 end;
end;

procedure ttabpage.doselect;
var
 subformclass: widgetclassty;
 po1: pwidget;
 wi1: twidget;
begin
 if assigned(fongetsubform) then begin
  if fsubform = nil then begin
   subformclass:= nil;
   fsubforminstancevarpo:= nil;
   fongetsubform(self,subformclass,fsubforminstancevarpo);
   if subformclass <> nil then begin
    po1:= fsubforminstancevarpo;
    if po1 = nil then begin
     po1:= @wi1;
    end;
    mseclasses.createmodule(self,subformclass,po1^);
    setlinkedvar(po1^,tmsecomponent(fsubform));
//    setlinkedvar(subformclass.create(self),tmsecomponent(fsubform));
    insertwidget(fsubform,nullpoint);
//    if fsubforminstancevarpo <> nil then begin
//     fsubforminstancevarpo^:= fsubform;
//    end;
    if assigned(foninitsubform) then begin
     foninitsubform(self,fsubform);
    end;
    fsubform.visible:= true;
   end;
  end;
 end;
 if assigned(fonselect) then begin
  fonselect(self);
 end;
end;

procedure ttabpage.dodeselect;
begin
 if canevent(tmethod(fondeselect)) then begin
  fondeselect(self);
 end;
 if fsubform <> nil then begin
  if fsubform.forceclose then begin
   fsubform.free;
  end
  else begin
   tabwidget.activepageindex:= tabindex; //reactivate
  end;
 end;
end;

function ttabpage.getimagelist: timagelist;
begin
 result:= fimagelist
end;

procedure ttabpage.setimagelist(const avalue: timagelist);
begin
 if fimagelist <> avalue then begin
  setlinkedvar(avalue,tmsecomponent(fimagelist));
  changed;
 end;
end;

function ttabpage.getimagenr: imagenrty;
begin
 result:= fimagenr;
end;

procedure ttabpage.setimagenr(const avalue: imagenrty);
begin
 if fimagenr <> avalue then begin
  fimagenr:= avalue;
  changed;
 end;
end;
{
function ttabpage.getimagenractive: integer;
begin
 result:= fimagenractive;
end;

procedure ttabpage.setimagenractive(const avalue: integer);
begin
 if fimagenractive <> avalue then begin
  fimagenractive:= avalue;
  changed;
 end;
end;
}
function ttabpage.getimagenrdisabled: imagenrty;
begin
 result:= fimagenrdisabled;
end;

procedure ttabpage.setimagenrdisabled(const avalue: imagenrty);
begin
 if fimagenrdisabled <> avalue then begin
  fimagenrdisabled:= avalue;
  changed;
 end;
end;

function ttabpage.getinvisible: boolean;
begin
 result:= finvisible;
end;

procedure ttabpage.setinvisible(const avalue: boolean);
begin
 if finvisible <> avalue then begin
  finvisible:= avalue;
  changed;
 end;
end;

procedure ttabpage.objectevent(const sender: tobject;
               const event: objecteventty);
begin
 inherited;
 if (event = oe_destroyed) and (sender = fsubform) then begin
  if fsubforminstancevarpo <> nil then begin
   fsubforminstancevarpo^:= nil;
  end;
 end;
 if sender = fimagelist then begin
  if event = oe_destroyed then begin
   fimagelist:= nil;
   changed;
  end
  else begin
   if event = oe_changed then begin
    changed;
   end;
  end;
 end;
end;

procedure ttabpage.initnewcomponent(const ascale: real);
begin
 inherited;
 caption:= 'caption';
end;

procedure ttabpage.createfonttab;
begin
 if ffonttab = nil then begin
  ffonttab:= ttabpagefonttab.create;
  ffonttab.onchange:= {$ifdef FPC}@{$endif}fontchanged1;
 end;
end;

procedure ttabpage.createfontactivetab;
begin
 if ffontactivetab = nil then begin
  ffontactivetab:= ttabpagefontactivetab.create;
  ffontactivetab.onchange:= {$ifdef FPC}@{$endif}fontchanged1;
 end;
end;

function ttabpage.getfonttab: tfont;
begin
 result:= ffonttab;
end;

function ttabpage.getfontactivetab: tfont;
begin
 result:= ffontactivetab;
end;

function ttabpage.getfonttab1: ttabpagefonttab;
begin
 getoptionalobject(ffonttab,
                            {$ifdef FPC}@{$endif}createfonttab);
 result:= ffonttab;
end;

procedure ttabpage.setfonttab1(const avalue: ttabpagefonttab);
begin
 if avalue <> ffonttab then begin
  setoptionalobject(avalue,ffonttab,
                                       {$ifdef FPC}@{$endif}createfonttab);
  changed;
 end;
end;

procedure ttabpage.setfonttab(const avalue: tfont);
begin
 setfonttab1(ttabpagefonttab(avalue));
end;

function ttabpage.isfonttabstored: boolean;
begin
 result:= ffonttab <> nil;
end;

function ttabpage.getfontactivetab1: ttabpagefontactivetab;
begin
 getoptionalobject(ffontactivetab,
                            {$ifdef FPC}@{$endif}createfontactivetab);
 result:= ffontactivetab;
end;

procedure ttabpage.setfontactivetab1(const avalue: ttabpagefontactivetab);
begin
 if avalue <> ffontactivetab then begin
  setoptionalobject(avalue,ffontactivetab,
                                       {$ifdef FPC}@{$endif}createfontactivetab);
  changed;
 end;
end;

procedure ttabpage.setfontactivetab(const avalue: tfont);
begin
 setfontactivetab1(ttabpagefontactivetab(avalue));
end;

function ttabpage.isfontactivetabstored: boolean;
begin
 result:= ffontactivetab <> nil;
end;


{
function ttabpage.gettabwidth: integer;
begin
 result:= ftabwidth;
end;

procedure ttabpage.settabwidth(const avalue: integer);
begin
 ftabwidth:= avalue;
 changed;
end;

function ttabpage.gettabwidthmin: integer;
begin
 result:= ftabwidthmin;
end;

procedure ttabpage.settabwidthmin(const avalue: integer);
begin
 ftabwidthmin:= avalue;
 changed;
end;

function ttabpage.gettabwidthmax: integer;
begin
 result:= ftabwidthmax;
end;

procedure ttabpage.settabwidthmax(const avalue: integer);
begin
 ftabwidthmax:= avalue;
 changed;
end;
}
{ ttab_font }

class function ttab_font.getinstancepo(owner: tobject): pfont;
begin
 result:= @tcustomtabwidget(owner).ftabs.ffont;
end;

{ ttab_fonttab }

class function ttab_fonttab.getinstancepo(owner: tobject): pfont;
begin
 result:= @tcustomtabwidget(owner).ftabs.tabs.ffont;
end;

{ ttab_fontactivetab }

class function ttab_fontactivetab.getinstancepo(owner: tobject): pfont;
begin
 result:= @tcustomtabwidget(owner).ftabs.tabs.ffontactive;
end;

{ tcustomtabwidget }

constructor tcustomtabwidget.create(aowner: tcomponent);
begin
 factivepageindex:= -1;
 factivepageindexdesign:= -1;
 ftab_sizemin:= defaulttabsizemin;
 ftab_sizemax:= defaulttabsizemax;
 inherited;
 foptionswidget:= defaulttaboptionswidget;
 optionsskin:= defaulttaboptionsskin;
 ftabs:= tcustomtabbar1.create(self,nil,true);
 include(ftabs.fwidgetstate1,ws1_designactive);
 include(ftabs.fstate,tbs_designdrag);
 ftabs.fanchors:= [an_left,an_top,an_right];
 ftab_size:= ftabs.size.cy;
 ftabs.SetSubComponent(true);
 ftabs.tabs.oncreatetab:= {$ifdef FPC}@{$endif}createpagetab;
 exclude(ftabs.fwidgetstate,ws_iswidget);
 ftabs.setlockedparentwidget(self);
 ftabs.finternaltabchange:= {$ifdef FPC}@{$endif}tabchanged;
 fobjectpicker:= tobjectpicker.create(iobjectpicker(self),org_widget);
end;

destructor tcustomtabwidget.destroy;
begin
 fobjectpicker.free;
 ftabs.free;
 inherited;
end;

procedure tcustomtabwidget.clear;
begin
 beginupdate();
 try
  while count > 0 do begin
   items[count-1].Free;
  end;
 finally
  endupdate();
 end;
end;

function tcustomtabwidget.getitems(const index: integer): twidget;
begin
 result:= tpagetab(ftabs.tabs[index]).page;
end;

function tcustomtabwidget.getitemsintf(const index: integer): itabpage;
begin
 result:= tpagetab(ftabs.tabs[index]).fpageintf;
end;

procedure tcustomtabwidget.pagechanged(const sender: itabpage);
var
 widget1: twidget1;
 int1: integer;
 activepageindexbefore: integer;
 bo1: boolean;
 updatingbefore: boolean;
begin
 if not (ws_destroying in fwidgetstate) then begin
  widget1:= twidget1(sender.getwidget);
  int1:= indexof(widget1);
  if widget1.visible then begin
   fvisiblepage:= int1;
  end;
  with ftabs.tabs[int1] do begin
   updatingbefore:= ts_updating in fstate;
   include(fstate,ts_updating);
   if not (csloading in componentstate) and
            not (ws_loadedproc in fwidgetstate) and (fupdating <= 0) then begin
    activepageindexbefore:= factivepageindex;
    caption:= sender.getcaption;
    hint:= sender.gettabhint;
    color:= sender.getcolortab;
    coloractive:= sender.getcoloractivetab;
    face:= sender.getfacetab;
    faceactive:= sender.getfaceactivetab;
    bo1:= sender.gettabnoface;
    if bo1 then begin
     state:= state + [ts_noface];
    end
    else begin
     state:= state - [ts_noface];
    end;
    font:= ttabfont(sender.getfonttab);
    fontactive:= ttabfontactive(sender.getfontactivetab);
    imagelist:= sender.getimagelist;
    imagenr:= sender.getimagenr;
    imagenrdisabled:= sender.getimagenrdisabled;
    bo1:= not (csdesigning in componentstate) and sender.getinvisible;

    if not widget1.enabled then begin
     state:= state + [ts_disabled];
    end
    else begin
     state:= state - [ts_disabled];
    end;
    if bo1 then begin
     state:= state + [ts_invisible]
    end
    else begin
     state:= state - [ts_invisible]
    end;
    if (not bo1 or (activepageindexbefore <> int1)) and widget1.isvisible and
        (widget1.enabled or (csdesigning in widget1.componentstate)) then begin
     state:= state - [ts_invisible];
     setactivepageindex(int1);
    end
    else begin
     if (activepageindexbefore = int1) and
                            not (csdestroying in componentstate) then begin
      changepage(1);
      if factivepageindex = activepageindexbefore then begin
       setactivepageindex(-1); //select none
      end
      else begin
       if (activepage <> nil) and not activepage.entered and
        (entered or ((fwindow <> nil) and
        (fwindow.focusedwidget = nil))) and activepage.canfocus then begin
                 //probably page destroyed
        activepage.setfocus(active);
       end;
      end;
     end;
    end;
    if not updatingbefore then begin
     exclude(fstate,ts_updating);
     changed;
    end;
   end
   else begin
    caption:= sender.getcaption; //no updatelayout
    if not updatingbefore then begin
     exclude(fstate,ts_updating);
    end;
   end;
  end;
 end;
end;

procedure tcustomtabwidget.loaded;
var
 int1: integer;
 po1: ppagetabaty;
begin
 inc(fdesignchangedlock);
 if factivepageindexdesign >= count then begin
  factivepageindex:= -1;
  factivepageindexdesign:= -1;
 end;
 if not (csdesigning in componentstate) and (factivepageindexdesign >= 0) then begin
  factivepageindex:= factivepageindexdesign;
 end;
 if factivepageindex >= 0 then begin
  if (fvisiblepage >= 0) and  (fvisiblepage <> factivepageindex) and
                       (fvisiblepage < count) then begin
   items[fvisiblepage].visible:= false;
  end;
  items[factivepageindex].visible:= true;
 end;
 inherited;
 ftabs.loaded;
 updatesize(nil);
// int1:= factivepageindex;
 factivepageindex:= -1;
// setactivepageindex(int1);
 with ftabs.flayoutinfo.tabs do begin
  po1:= pointer(fitems);
  for int1:= 0 to high(fitems) do begin
   pagechanged(po1^[int1].fpageintf);
  end;
 end;
// ftabs.loaded;
 dec(fdesignchangedlock);
end;

procedure tcustomtabwidget.updatesize(const page: twidget);
var
 rect1: rectty;

 procedure updatepagesize(const apage: twidget);
 var
  rect2: rectty;
 begin
  with rect2 do begin
   if tabo_vertical in ftabs.options then begin
    cx:= rect1.cx - ftabs.bounds_cx;
    y:= rect1.y;
    cy:= rect1.cy;
    if tabo_opposite in ftabs.options then begin
     x:= rect1.x;
    end
    else begin
     x:= rect1.x + ftabs.bounds_cx;
    end;
   end
   else begin
    cy:= rect1.cy - ftabs.bounds_cy;
    x:= rect1.x;
    cx:= rect1.cx;
    if tabo_opposite in ftabs.options then begin
     y:= rect1.y;
    end
    else begin
     y:= rect1.y + ftabs.bounds_cy;
    end;
   end;
  end;
  apage.widgetrect:= rect2;
 end;

var
 int1: integer;
 bo1: boolean;
begin
 if not (csloading in componentstate) and
                not (tbs_updatesizing in ftabs.fstate) then begin
                     //recursion lock
  include(ftabs.fstate,tbs_updatesizing);
  try
   rect1:= innerwidgetrect;
   if page <> nil then begin
    updatepagesize(page);
   end
   else begin
    bo1:= (tabo_notabsdesign in ftabs.options) or
             not (csdesigning in componentstate) and
             ((tabo_multitabsonly in ftabs.options) and (count < 2) or
                                       (tabo_notabs in ftabs.options));
    if bo1 then begin
     include(ftabs.fstate,tbs_shrinktozero);
    end
    else begin
     exclude(ftabs.fstate,tbs_shrinktozero);
    end;
    if tabo_vertical in ftabs.options then begin
     if tabo_opposite in ftabs.options then begin
      if bo1 then begin
       ftabs.setwidgetrect(makerect(rect1.x+rect1.cx,rect1.y,
                                           0,rect1.cy));
      end
      else begin
       ftabs.setwidgetrect(makerect(rect1.x+rect1.cx-ftab_size,rect1.y,
                                           ftab_size,rect1.cy));
      end;
     end
     else begin
      if bo1 then begin
       ftabs.setwidgetrect(makerect(rect1.x,rect1.y,0,rect1.cy));
      end
      else begin
       ftabs.setwidgetrect(makerect(rect1.x,rect1.y,ftab_size,rect1.cy));
      end;
     end;
    end
    else begin
     if tabo_opposite in ftabs.options then begin
      if bo1 then begin
       ftabs.setwidgetrect(makerect(rect1.x,rect1.y+rect1.cy,
                                          rect1.cx,0));
      end
      else begin
       ftabs.setwidgetrect(makerect(rect1.x,rect1.y+rect1.cy-ftab_size,
                                          rect1.cx,ftab_size));
      end;
     end
     else begin
      if bo1 then begin
       ftabs.setwidgetrect(makerect(rect1.x,rect1.y,rect1.cx,0));
      end
      else begin
       ftabs.setwidgetrect(makerect(rect1.x,rect1.y,rect1.cx,ftab_size));
      end;
     end;
    end;
    for int1:= 0 to ftabs.tabs.count - 1 do begin
     updatepagesize(items[int1]);
    end;
   end;
  finally
   exclude(ftabs.fstate,tbs_updatesizing);
  end;
 end;
end;

procedure tcustomtabwidget.readtab_captionpos(reader: treader);
begin
 tab_imagepos:= readcaptiontoimagepos(reader);
end;

procedure tcustomtabwidget.readoptions(reader: treader);
begin
 tab_options:= tabbaroptionsty(
              {$ifndef FPC}word(integer({$endif}
                readset(reader,typeinfo(tabbaroptionsty))
              {$ifndef FPC})){$endif});
 if tabo_vertical in tab_options then begin
  tab_optionswidget1:= [];
 end;
end;

procedure tcustomtabwidget.readtab_captionframe_left(reader: treader);
begin
 ftabs.flayoutinfo.tabs.createframe();
 ttabframe1(ftabs.flayoutinfo.tabs.fframe).fi.innerframe.left:=
                                                         reader.readinteger();
end;

procedure tcustomtabwidget.readtab_captionframe_top(reader: treader);
begin
 ftabs.flayoutinfo.tabs.createframe();
 ttabframe1(ftabs.flayoutinfo.tabs.fframe).fi.innerframe.top:=
                                                         reader.readinteger();
end;

procedure tcustomtabwidget.readtab_captionframe_right(reader: treader);
begin
 ftabs.flayoutinfo.tabs.createframe();
 ttabframe1(ftabs.flayoutinfo.tabs.fframe).fi.innerframe.right:=
                                                         reader.readinteger();
end;

procedure tcustomtabwidget.readtab_captionframe_bottom(reader: treader);
begin
 ftabs.flayoutinfo.tabs.createframe();
 ttabframe1(ftabs.flayoutinfo.tabs.fframe).fi.innerframe.bottom:=
                                                         reader.readinteger();
end;

procedure tcustomtabwidget.readtab_imagedist(reader: treader);
begin
 ftabs.flayoutinfo.tabs.createframe();
 ttabframe1(ftabs.flayoutinfo.tabs.fframe).fi.imagedist:= reader.readinteger();
end;

procedure tcustomtabwidget.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('tab_captionpos',@readtab_captionpos,nil,false);
 filer.defineproperty('options',@readoptions,nil,false);
 filer.defineproperty('tab_captionframe_left',
                                      @readtab_captionframe_left,nil,false);
 filer.defineproperty('tab_captionframe_top',
                                      @readtab_captionframe_top,nil,false);
 filer.defineproperty('tab_captionframe_right',
                                      @readtab_captionframe_right,nil,false);
 filer.defineproperty('tab_captionframe_bottom',
                                      @readtab_captionframe_bottom,nil,false);
 filer.defineproperty('tab_imagedist', @readtab_imagedist,nil,false);
end;

procedure tcustomtabwidget.internaladd(const page: itabpage; aindex: integer);
var
 tab: tpagetab;
 widget1: twidget1;
begin
 widget1:= twidget1(page.getwidget);
 if indexof(widget1) < 0 then begin
  include(widget1.fmsecomponentstate,cs_parentwidgetrect);
  if aindex > count then begin
   aindex:= count;
  end;
  widget1.visible:= false;
  tab:= tpagetab.create(ftabs,page);
  if not (csreading in componentstate) then begin
//  if not (csloading in componentstate) then begin
   ftabs.tabs.insert(tab,aindex);
   with widget1 do begin
    parentwidget:= self;
    anchors:= [an_bottom,an_top,an_left,an_right];
   end;
   updatesize(widget1);
  end
  else begin
   ftabs.tabs.beginupdate;
   ftabs.tabs.insert(tab,aindex);
   ftabs.tabs.endupdate(true);
  end;
  include(widget1.fwidgetstate1,ws1_nodesignvisible);
  page.settabwidget(self);
  pagechanged(page);
//  if not (csloading in componentstate) then begin
  if not (csreading in componentstate) then begin
//   activepageindex:= aindex;
   setactivepageindex(aindex);
  end;
  dopageadded(widget1);
 end;
end;

procedure tcustomtabwidget.internalremove(const page: itabpage);
var
 int1: integer;
 widget1: twidget1;
 activebefore: integer;

 procedure check(var aindex: integer);
 begin
  if aindex >= 0 then begin
   if aindex > int1 then begin
    dec(aindex);
   end
   else begin
    if aindex = int1 then begin
     aindex:= -1;
    end;
   end;
  end;
 end; //check

begin
 if ftabs <> nil then begin
  widget1:= twidget1(page.getwidget);
  int1:= indexof(widget1);
  if int1 >= 0 then begin
   exclude(widget1.fmsecomponentstate,cs_parentwidgetrect);
   activebefore:= factivepageindex;
   check(factivepageindex);
   check(factivepageindexdesign);
   ftabs.flayoutinfo.activetab:= factivepageindex;
   ftabs.tabs.delete(int1);
   with widget1 do begin
    exclude(fwidgetstate1,ws1_nodesignvisible);
    if page.gettabwidget = self then begin
     page.settabwidget(nil);
    end;
   end;
   dopageremoved(widget1);
   if (activebefore <> factivepageindex) and (factivepageindex = -1) then begin
    nextpage(activebefore,true);
    if factivepageindex = -1 then begin
     doactivepagechanged;
    end;
   end;
  end;
 end;
end;

procedure tcustomtabwidget.registerchildwidget(const child: twidget);
var
 intf: itabpage;
begin
 inherited;
 if twidget1(child).getcorbainterface(typeinfo(itabpage),intf) then begin
  internaladd(intf,bigint);
 end;
end;

procedure tcustomtabwidget.add(const aitem: itabpage;
                                      const aindex: integer = bigint);
begin
 internaladd(aitem,aindex);
end;

procedure tcustomtabwidget.unregisterchildwidget(const child: twidget);
var
 intf: itabpage;
begin
 inherited;
 if not (csdestroying in componentstate) and
              twidget1(child).getcorbainterface(typeinfo(itabpage),intf) then begin
  internalremove(intf);
 end;
end;

function tcustomtabwidget.indexof(const page: twidget): integer;
var
 int1: integer;
begin
 result:= -1;
 for int1:= 0 to count-1 do begin
  if items[int1] = page then begin
   result:= int1;
   break;
  end;
 end;
end;

procedure tcustomtabwidget.GetChildren(Proc: TGetChildProc; Root: TComponent);
var
 int1: integer;
 widget1: twidget1;
begin
 for int1:= 0 to high(fwidgets) do begin
  exclude(twidget1(fwidgets[int1]).fwidgetstate1,ws1_isstreamed);
 end;
 for int1:= 0 to count-1 do begin
  widget1:= twidget1(items[int1]);
  if widget1.owner = root then begin
   proc(widget1);
   include(widget1.fwidgetstate1,ws1_isstreamed);
  end;
 end;
 for int1:= 0 to widgetcount - 1 do begin
  widget1:= twidget1(fwidgets[int1]);
  if not (ws1_isstreamed in widget1.fwidgetstate1) and
    (widget1.owner = root) and
              (ws_iswidget in widget1.fwidgetstate) then begin
   proc(widget1);
  end;
 end;
end;

procedure tcustomtabwidget.setactivepageindex(Value: integer);
var
 int1: integer;
 parenttabfocus: boolean;
 widget1,widget2: twidget;
begin
 if (value <> factivepageindex) or (fupdating > 0) then begin
  if csloading in componentstate then begin
   factivepageindex:= value;
   factivepageindex1:= value;
   exit;
  end;
  if (value >= 0) then begin
   ftabs.flayoutinfo.tabs.checkindex(value);
  end
  else begin
   value:= -1;
  end;
  if fupdating > 0 then begin
   factivepageindex1:= value;
  end
  else begin
   parenttabfocus:= ow_parenttabfocus in foptionswidget;
   exclude(foptionswidget,ow_parenttabfocus);
   try
    if factivepageindex >= 0 then begin
     widget1:= items[factivepageindex];
     int1:= factivepageindex;
     if not (csdestroying in widget1.componentstate) then begin
      widget2:= widget1;
      if ow1_canclosenil in widget1.optionswidget1 then begin
       widget2:= nil;
      end;
      if not widget1.canparentclose(widget2) then begin
       ftabs.tabs[factivepageindex].active:= true;
       exit;
      end;
      factivepageindex:= -1;
      if not (csloading in componentstate) then begin
       tpagetab(ftabs.tabs[int1]).fpageintf.dodeselect;
       if (factivepageindex <> -1) then begin
        exit;
       end;
      end;
      items[int1].visible:= false;
      if (factivepageindex <> -1) or items[int1].visible then begin
       exit;
      end;
     end;
     ftabs.tabs[int1].active:= false; //if items[int1] was already invisible
    end;
    factivepageindex:= Value;
    if value >= 0 then begin
     defaultfocuschild:= items[value];
     if not (csloading in componentstate) then begin
      tpagetab(ftabs.tabs[value]).fpageintf.doselect;
      if factivepageindex <> value then begin
       exit;
      end;
     end;
     with items[value] do begin
      bringtofront; //needed in design mode where all widgets are visible
      inc(fupdating);
      try
       visible:= true;
      finally
       dec(fupdating);
      end;
      if self.entered and canfocus and not ftabs.focused then begin
       setfocus(false);
      end;
     end;
    end
    else begin
     defaultfocuschild:= nil;
    end;
    if (value = factivepageindex) then begin
     doactivepagechanged;
     if (value >= 0) and (value = factivepageindex) then begin
      ftabs.tabs[value].active:= true
     end;
    end;
   finally
    if parenttabfocus then begin
     include(foptionswidget,ow_parenttabfocus);
    end;
   end;
  end;
 end;
end;

procedure tcustomtabwidget.tabchanged(const synctabindex: boolean);
begin
 if synctabindex and (factivepageindex >= 0) then begin
  factivepageindex:= ftabs.activetab;
 end
 else begin
  setactivepageindex(ftabs.activetab);
 end;
// activepageindex:= ftabs.activetab;
end;

function tcustomtabwidget.count: integer;
begin
 result:= ftabs.tabs.count;
end;

function tcustomtabwidget.getactivepage: twidget;
begin
 if factivepageindex >= 0 then begin
  result:= items[factivepageindex];
 end
 else begin
  result:= nil;
 end;
end;

function tcustomtabwidget.getactivepageintf: itabpage;
begin
 if factivepageindex >= 0 then begin
  result:= itemsintf[factivepageindex];
 end
 else begin
  result:= nil;
 end;
end;

procedure tcustomtabwidget.setactivepage(const value: twidget);
begin
 if value = nil then begin
  setactivepageindex(-1);
 end
 else begin
  setactivepageindex(indexof(value));
 end;
end;

procedure tcustomtabwidget.clientrectchanged;
var
 size1: sizety;
begin
 inherited;
 if not (csloading in componentstate) then begin
  size1:= innerclientsize;
  if tabo_vertical in ftabs.foptions then begin
   if size1.cx < tab_size then begin
    tab_size:= size1.cx
   end
   else begin
    updatesize(nil);
   end;
  end
  else begin
   if size1.cy < tab_size then begin
    tab_size:= size1.cy
   end
   else begin
    updatesize(nil);
   end;
  end;
 end;
end;

procedure tcustomtabwidget.doactivepagechanged;
begin
 if canevent(tmethod(fonactivepagechanged)) then begin
  fonactivepagechanged(self);
 end;
// designchanged;
end;

procedure tcustomtabwidget.dopageadded(const apage: twidget);
begin
 if canevent(tmethod(fonpageadded)) then begin
  fonpageadded(self,apage);
 end;
end;

procedure tcustomtabwidget.dopageremoved(const apage: twidget);
begin
 if canevent(tmethod(fonpageremoved)) then begin
  fonpageremoved(self,apage);
 end;
end;

procedure tcustomtabwidget.nextpage(newindex: integer; down: boolean);
var
 int1: integer;
begin
 if count > 0 then begin
  if (newindex >= count) or (newindex < 0) then begin
   if down then begin
    newindex:= count - 1;
   end
   else begin
    newindex:= 0;
   end;
  end;
  int1:= newindex;
  repeat
   if (items[int1].enabled) and not (ts_invisible in ftabs.tabs[int1].state) or
            (csdesigning in componentstate) then begin
    setactivepageindex(int1);
    break;
   end
   else begin
    if down then begin
     dec(int1);
     if int1 < 0 then begin
      int1:= count - 1;
     end;
    end
    else begin
     inc(int1);
     if int1 >= count then begin
      int1:= 0;
     end;
    end;
   end;
  until int1 = newindex;
  if int1 = factivepageindex then begin
   if not ((items[int1].enabled) and not (ts_invisible in ftabs.tabs[int1].state)
                 or (csdesigning in componentstate)) then begin
    setactivepageindex(-1);
   end;
  end;
 end;
end;

procedure tcustomtabwidget.changepage(step: integer);
begin
 nextpage(factivepageindex+step,step < 0);
end;

procedure tcustomtabwidget.movepage(const curindex,newindex: integer);
begin
 ftabs.movetab(curindex,newindex);
end;

procedure tcustomtabwidget.dokeydown(var info: keyeventinfoty);
begin
 with info do begin
  if (shiftstate = [ss_ctrl]) or (shiftstate = [ss_shift,ss_ctrl]) then begin
   include(eventstate,es_processed);
   case key of
    key_tab: begin
     changepage(1);
    end;
    key_backtab: begin
     changepage(-1);
    end
    else begin
     exclude(eventstate,es_processed);
    end;
   end;
  end;
  if not (es_processed in eventstate) then begin
   inherited;
  end;
 end;
end;

procedure tcustomtabwidget.childmouseevent(const sender: twidget;
                                                 var info: mouseeventinfoty);
begin
 inherited;
 if not (es_processed in info.eventstate) and
                     not ftabs.fdragcontroller.active and
    ((sender = self) or (sender = ftabs) or (sender = activepage))  then begin
  translatewidgetpoint1(info.pos,sender,self);
  fobjectpicker.mouseevent(info);
  translatewidgetpoint1(info.pos,self,sender);
 end;
end;

procedure tcustomtabwidget.dobeforepaint(const canvas: tcanvas);
begin
 fobjectpicker.dobeforepaint(canvas);
 inherited;
end;

procedure tcustomtabwidget.doafterpaint(const canvas: tcanvas);
begin
 inherited;
 fobjectpicker.doafterpaint(canvas);
end;

procedure tcustomtabwidget.synctofontheight;
begin
 inherited;
 if not (tabo_vertical in tab_options) then begin
  ftabs.synctofontheight;
  tab_size:= ftabs.bounds_cy;
 end;
end;

function tcustomtabwidget.checktabsizingpos(const apos: pointty): boolean;
begin
 with ftabs,moverect(ftabs.paintrect,ftabs.fwidgetrect.pos) do begin
  if tabo_tabsizing in foptions then begin
   if tabo_vertical in foptions then begin
    if tabo_opposite in foptions then begin
     result:= pointinrect(apos,makerect(x-sizingtol,y,sizingwidth,cy));
    end
    else begin
     result:= pointinrect(apos,makerect(x+cx-sizingtol,y,sizingwidth,cy));
    end;
   end
   else begin
    if tabo_opposite in foptions then begin
     result:= pointinrect(apos,makerect(y,y-sizingtol,cx,sizingwidth));
    end
    else begin
     result:= pointinrect(apos,makerect(y,y+cy-sizingtol,cx,sizingwidth));
    end;
   end;
  end
  else begin
   result:= false;
  end;
 end;
end;

function tcustomtabwidget.getidents: integerarty;
begin
 result:= ftabs.flayoutinfo.tabs.idents;
end;

procedure tcustomtabwidget.setstatfile(const Value: tstatfile);
begin
 setstatfilevar(istatfile(self),value,fstatfile);
end;

   //istatfile
procedure tcustomtabwidget.dostatread(const reader: tstatreader);
begin
 ftabs.flayoutinfo.tabs.dostatread(reader,tabo_dragdest in tab_options);
 if reader.canstate then begin
  if tabo_tabsizing in tab_options then begin
   tab_size:= reader.readinteger('tabsize',tab_size);
  end;
  ftabs.firsttab:= reader.readinteger('firsttab',ftabs.firsttab);
  setactivepageindex(reader.readinteger('index',activepageindex,-1,count-1));
 end;
end;

procedure tcustomtabwidget.dostatwrite(const writer: tstatwriter);
begin
 ftabs.flayoutinfo.tabs.dostatwrite(writer,tabo_dragdest in tab_options);
 if writer.canstate then begin
  if tabo_tabsizing in tab_options then begin
   writer.writeinteger('tabsize',tab_size);
  end;
  writer.writeinteger('firsttab',ftabs.firsttab);
  writer.writeinteger('index',activepageindex);
 end;
end;

procedure tcustomtabwidget.statreading;
begin
 //dummy;
end;

procedure tcustomtabwidget.statread;
begin
 //dummy;
end;

function tcustomtabwidget.getstatvarname: msestring;
begin
 result:= fstatvarname;
end;

   //iobjectpicker
function tcustomtabwidget.getcursorshape(const sender: tobjectpicker;
                                             var shape: cursorshapety): boolean;
    //true if found
begin
 result:= checktabsizingpos(sender.pos);
 if result then begin
  if tabo_vertical in ftabs.foptions then begin
   shape:= cr_sizehor;
  end
  else begin
   shape:= cr_sizever;
  end;
 end
end;

procedure tcustomtabwidget.getpickobjects(const sender: tobjectpicker;
                                 var objects: integerarty);
begin
 if checktabsizingpos(sender.pos) then begin
  setlength(objects,1);
 end;
end;

procedure tcustomtabwidget.beginpickmove(const sender: tobjectpicker);
begin
 //dummy
end;

function tcustomtabwidget.checkpickoffset(const aoffset: pointty): pointty;
begin
 result:= aoffset;
 with ftabs do begin
  if tabo_opposite in foptions then begin
   result.x:= -result.x;
   result.y:= -result.y;
  end;
  if tabo_vertical in foptions then begin
   if tab_size + result.x > tab_sizemax then begin
    result.x:= tab_sizemax - tab_size;
   end;
   if tab_size + result.x > self.paintrect.cx then begin
    result.x:= self.paintrect.cx - tab_size;
   end;
   if tab_size + result.x < tab_sizemin then begin
    result.x:= tab_sizemin - tab_size;
   end;
  end
  else begin
   if tab_size + result.y > tab_sizemax then begin
    result.y:= tab_sizemax - tab_size;
   end;
   if tab_size + result.y > self.paintrect.cy then begin
    result.y:= self.paintrect.cy - tab_size;
   end;
   if tab_size + result.y < tab_sizemin then begin
    result.y:= tab_sizemin - tab_size;
   end;
  end;
  if tabo_opposite in foptions then begin
   result.x:= -result.x;
   result.y:= -result.y;
  end;
 end;
end;

procedure tcustomtabwidget.endpickmove(const sender: tobjectpicker);
var
 offset1: pointty;
begin
 offset1:= checkpickoffset(sender.pickoffset);
 with ftabs do begin
  if tabo_vertical in foptions then begin
   if tabo_opposite in foptions then begin
    tab_size:= tab_size - offset1.x;
   end
   else begin
    tab_size:= tab_size + offset1.x;
   end;
  end
  else begin
   if tabo_opposite in foptions then begin
    tab_size:= tab_size - offset1.y;
   end
   else begin
    tab_size:= tab_size + offset1.y;
   end;
  end;
 end;
end;

procedure tcustomtabwidget.paintxorpic(const sender: tobjectpicker;
                                                const canvas: tcanvas);
var
 offset1: pointty;
begin
 offset1:= checkpickoffset(sender.pickoffset);
 with ftabs,ftabs.fwidgetrect do begin
  if tabo_vertical in options then begin
   if tabo_opposite in foptions then begin
    canvas.fillxorrect(makepoint(x+offset1.x,y),cy,gd_down,2,
                                           stockobjects.bitmaps[stb_dens50]);
   end
   else begin
    canvas.fillxorrect(makepoint(x+cx+offset1.x,y),cy,gd_down,2,
                                           stockobjects.bitmaps[stb_dens50]);
   end;
  end
  else begin
   if tabo_opposite in foptions then begin
    canvas.fillxorrect(makepoint(x,y+offset1.y),cx,gd_right,2,
                                           stockobjects.bitmaps[stb_dens50]);
   end
   else begin
    canvas.fillxorrect(makepoint(x,y+cy+offset1.y),cx,gd_right,2,
                                           stockobjects.bitmaps[stb_dens50]);
   end;
  end;
 end;
end;

function tcustomtabwidget.gettab_options: tabbaroptionsty;
begin
 result:= ftabs.options;
end;

procedure tcustomtabwidget.settab_options(const avalue: tabbaroptionsty);
var
 optionsbefore: tabbaroptionsty;
begin
 optionsbefore:= ftabs.options;
 ftabs.options:= avalue;
 if (optionsbefore >< ftabs.options) *
    [tabo_vertical,tabo_opposite,
           tabo_multitabsonly,tabo_notabs,tabo_notabsdesign] <> [] then begin
  if tabo_vertical in avalue then begin
   ftabs.anchors:= [an_left,an_top,an_bottom];
  end
  else begin
   ftabs.anchors:= [an_left,an_top,an_right];
  end;
  updatesize(nil);
 end;
end;

function tcustomtabwidget.gettab_color: colorty;
begin
 Result := ftabs.color;
end;

procedure tcustomtabwidget.settab_color(const avalue: colorty);
begin
 ftabs.color:= avalue;
end;

function tcustomtabwidget.gettab_frame: tstepboxframe1;
begin
 result:= tstepboxframe1(ftabs.frame);
end;

procedure tcustomtabwidget.settab_frame(const avalue: tstepboxframe1);
begin
 ftabs.frame:= avalue;
end;

function tcustomtabwidget.gettab_face: tface;
begin
 Result:= ftabs.face;
end;

procedure tcustomtabwidget.settab_face(const avalue: tface);
begin
 ftabs.face:= avalue;
end;

function tcustomtabwidget.gettab_colortab: colorty;
begin
 result:= ftabs.tabs.color;
end;

procedure tcustomtabwidget.settab_colortab(const avalue: colorty);
begin
 ftabs.tabs.color:= avalue;
end;

function tcustomtabwidget.gettab_coloractivetab: colorty;
begin
 result:= ftabs.tabs.coloractive;
end;

procedure tcustomtabwidget.settab_coloractivetab(const avalue: colorty);
begin
 ftabs.tabs.coloractive:= avalue;
end;

function tcustomtabwidget.gettab_frametab: ttabframe;
begin
 result:= ftabs.tabs.frame;
end;

procedure tcustomtabwidget.settab_frametab(const avalue: ttabframe);
begin
 ftabs.tabs.frame:= avalue;
end;

function tcustomtabwidget.gettab_facetab: tface;
begin
 result:= ftabs.tabs.face;
end;

procedure tcustomtabwidget.settab_facetab(const avalue: tface);
begin
 ftabs.tabs.face:= avalue;
end;

function tcustomtabwidget.gettab_faceactivetab: tface;
begin
 result:= ftabs.tabs.faceactive;
end;

procedure tcustomtabwidget.settab_faceactivetab(const avalue: tface);
begin
 ftabs.tabs.faceactive:= avalue;
end;

function tcustomtabwidget.gettab_imagepos: imageposty;
begin
 result:= ftabs.tabs.imagepos;
end;

procedure tcustomtabwidget.settab_imagepos(const avalue: imageposty);
begin
 ftabs.tabs.imagepos:= avalue;
end;
{
function tcustomtabwidget.gettab_captionframe_left: integer;
begin
 result:= ftabs.tabs.captionframe_left;
end;

procedure tcustomtabwidget.settab_captionframe_left(const avalue: integer);
begin
 ftabs.tabs.captionframe_left:= avalue;
end;

function tcustomtabwidget.gettab_captionframe_top: integer;
begin
 result:= ftabs.tabs.captionframe_top;
end;

procedure tcustomtabwidget.settab_captionframe_top(const avalue: integer);
begin
 ftabs.tabs.captionframe_top:= avalue;
end;

function tcustomtabwidget.gettab_captionframe_right: integer;
begin
 result:= ftabs.tabs.captionframe_right;
end;

procedure tcustomtabwidget.settab_captionframe_right(const avalue: integer);
begin
 ftabs.tabs.captionframe_right:= avalue;
end;

function tcustomtabwidget.gettab_captionframe_bottom: integer;
begin
 result:= ftabs.tabs.captionframe_bottom;
end;

procedure tcustomtabwidget.settab_captionframe_bottom(const avalue: integer);
begin
 ftabs.tabs.captionframe_bottom:= avalue;
end;

function tcustomtabwidget.gettab_imagedist: integer;
begin
 result:= ftabs.tabs.imagedist;
end;

procedure tcustomtabwidget.settab_imagedist(const avalue: integer);
begin
 ftabs.tabs.imagedist:= avalue;
end;
}
function tcustomtabwidget.gettab_shift: integer;
begin
 result:= ftabs.tabs.shift;
end;

procedure tcustomtabwidget.settab_shift(const avalue: integer);
begin
 ftabs.tabs.shift:= avalue;
end;

procedure tcustomtabwidget.createpagetab(const sender: tcustomtabbar;
  const index: integer; var tab: ttab);
begin
 tab:= tpagetab.create(sender,nil);
end;

procedure tcustomtabwidget.settab_size(const avalue: integer);
begin
 if ftab_size <> avalue then begin
  ftab_size:= avalue;
  if ftab_size < ftab_sizemin then begin
   ftab_size:= ftab_sizemin;
  end
  else begin
   if ftab_size > ftab_sizemax then begin
    ftab_size:= ftab_sizemax;
   end;
  end;
  if not (csloading in componentstate) then begin
   updatesize(nil);
  end;
 end;
end;

procedure tcustomtabwidget.widgetregionchanged(const sender: twidget);
begin
 inherited;
 if not (csdestroying in componentstate) and (sender = ftabs) and
        not (ws1_updateopaque in twidget1(sender).fwidgetstate1) and
                          not (tbs_shrinktozero in ftabs.fstate) then begin
  if tabo_vertical in ftabs.options then begin
   tab_size:= ftabs.bounds_cx;
  end
  else begin
   tab_size:= ftabs.bounds_cy;
  end;
 end;
end;


procedure tcustomtabwidget.settab_sizemin(const avalue: integer);
begin
 ftab_sizemin:= avalue;
 if avalue > ftab_size then begin
  tab_size:= avalue;
 end;
end;

procedure tcustomtabwidget.settab_sizemax(const avalue: integer);
begin
 ftab_sizemax:= avalue;
 if avalue < ftab_size then begin
  tab_size:= avalue;
 end;
end;

function tcustomtabwidget.pagebyname(const aname: string): twidget;
var
 int1: integer;
begin
 for int1:= 0 to count - 1 do begin
  result:= items[int1];
  if result.name = aname then begin
   exit;
  end;
 end;
 raise exception.create('Tabpage '''+aname+''' not found.');
end;

procedure tcustomtabwidget.doclosepage(const sender: tobject);
begin
 items[fpopuptab].visible:= false;
 ftabs.tabs[fpopuptab].state:= ftabs.tabs[fpopuptab].state + [ts_invisible];
end;

procedure tcustomtabwidget.updatepopupmenu(var amenu: tpopupmenu;
               var mouseinfo: mouseeventinfoty);
begin
 if (tabo_autopopup in tab_options) then begin
  fpopuptab:= ftabs.tabatpos(translateclientpoint(mouseinfo.pos,self,ftabs));
  if fpopuptab >= 0 then begin
   tpopupmenu.additems(amenu,self,mouseinfo,
{$ifdef mse_dynpo}
      [lang_stockcaption[ord(sc_close_page)]],
{$else}
      [sc(sc_close_page)],
{$endif}
      [],[],[{$ifdef FPC}@{$endif}doclosepage]);
  end;
 end;
 inherited;
end;

function tcustomtabwidget.gettab_optionswidget: optionswidgetty;
begin
 result:= ftabs.optionswidget;
end;

procedure tcustomtabwidget.settab_optionswidget(const avalue: optionswidgetty);
begin
 ftabs.optionswidget:= avalue;
end;

function tcustomtabwidget.gettab_optionswidget1: optionswidget1ty;
begin
 result:= ftabs.optionswidget1;
end;

procedure tcustomtabwidget.settab_optionswidget1(const avalue: optionswidget1ty);
begin
 ftabs.optionswidget1:= avalue;
end;

function tcustomtabwidget.gettab_optionsskin: optionsskinty;
begin
 result:= ftabs.optionsskin;
end;

procedure tcustomtabwidget.settab_optionsskin(const avalue: optionsskinty);
begin
 ftabs.optionsskin:= avalue;
end;

function tcustomtabwidget.getedge_level: int32;
begin
 result:= ftabs.tabs.edge_level;
end;

procedure tcustomtabwidget.setedge_level(const avalue: int32);
begin
 ftabs.tabs.edge_level:= avalue;
end;

function tcustomtabwidget.getedge_colordkshadow: colorty;
begin
 result:= ftabs.tabs.edge_colordkshadow;
end;

procedure tcustomtabwidget.setedge_colordkshadow(const avalue: colorty);
begin
 ftabs.tabs.edge_colordkshadow:= avalue;
end;

function tcustomtabwidget.getedge_colorshadow: colorty;
begin
 result:= ftabs.tabs.edge_colorshadow;
end;

procedure tcustomtabwidget.setedge_colorshadow(const avalue: colorty);
begin
 ftabs.tabs.edge_colorshadow:= avalue;
end;

function tcustomtabwidget.getedge_colorlight: colorty;
begin
 result:= ftabs.tabs.edge_colorlight;
end;

procedure tcustomtabwidget.setedge_colorlight(const avalue: colorty);
begin
 ftabs.tabs.edge_colorlight:= avalue;
end;

function tcustomtabwidget.getedge_colorhighlight: colorty;
begin
 result:= ftabs.tabs.edge_colorhighlight;
end;

procedure tcustomtabwidget.setedge_colorhighlight(const avalue: colorty);
begin
 ftabs.tabs.edge_colorhighlight:= avalue;
end;

function tcustomtabwidget.getedge_colordkwidth: int32;
begin
 result:= ftabs.tabs.edge_colordkwidth;
end;

procedure tcustomtabwidget.setedge_colordkwidth(const avalue: int32);
begin
 ftabs.tabs.edge_colordkwidth:= avalue;
end;

function tcustomtabwidget.getedge_colorhlwidth: int32;
begin
 result:= ftabs.tabs.edge_colorhlwidth;
end;

procedure tcustomtabwidget.setedge_colorhlwidth(const avalue: int32);
begin
 ftabs.tabs.edge_colorhlwidth:= avalue;
end;

function tcustomtabwidget.getedge_imagelist: timagelist;
begin
 result:= ftabs.tabs.edge_imagelist;
end;

procedure tcustomtabwidget.setedge_imagelist(const avalue: timagelist);
begin
 ftabs.tabs.edge_imagelist:= avalue;
end;

function tcustomtabwidget.getedge_imageoffset: int32;
begin
 result:= ftabs.tabs.edge_imageoffset;
end;

procedure tcustomtabwidget.setedge_imageoffset(const avalue: int32);
begin
 ftabs.tabs.edge_imageoffset:= avalue;
end;

function tcustomtabwidget.getedge_imagepaintshift: int32;
begin
 result:= ftabs.tabs.edge_imagepaintshift;
end;

procedure tcustomtabwidget.setedge_imagepaintshift(const avalue: int32);
begin
 ftabs.tabs.edge_imagepaintshift:= avalue;
end;

function tcustomtabwidget.gettab_font: ttab_font;
begin
{$warnings off}
 result:= ttab_font(ftabs.font);
{$warnings on}
end;

procedure tcustomtabwidget.settab_font(const avalue: ttab_font);
begin
{$warnings off}
 ftabs.font:= twidgetfont(avalue);
{$warnings on}
end;

function tcustomtabwidget.istab_fontstored: boolean;
begin
 result:=  ftabs.ffont <> nil;
end;

function tcustomtabwidget.gettab_fonttab: ttab_fonttab;
begin
{$warnings off}
 result:= ttab_fonttab(ftabs.tabs.font);
{$warnings on}
end;

procedure tcustomtabwidget.settab_fonttab(const avalue: ttab_fonttab);
begin
{$warnings off}
 ftabs.tabs.font:= ttabsfont(avalue);
{$warnings on}
end;

function tcustomtabwidget.istab_fonttabstored: boolean;
begin
 result:=  ftabs.tabs.ffont <> nil;
end;

function tcustomtabwidget.gettab_fontactivetab: ttab_fontactivetab;
begin
{$warnings off}
 result:= ttab_fontactivetab(ftabs.tabs.fontactive);
{$warnings on}
end;

procedure tcustomtabwidget.set_tabfontactivetab(const avalue: ttab_fontactivetab);
begin
{$warnings off}
 ftabs.tabs.fontactive:= ttabsfontactive(avalue);
{$warnings on}
end;

function tcustomtabwidget.istab_fontactivetabstored: boolean;
begin
 result:=  ftabs.tabs.ffontactive <> nil;
end;

function tcustomtabwidget.gettab_textflags: textflagsty;
begin
 result:= ftabs.tabs.ftextflags;
end;

procedure tcustomtabwidget.settab_textflags(const avalue: textflagsty);
begin
 ftabs.tabs.textflags:= avalue;
end;

function tcustomtabwidget.gettab_width: integer;
begin
 result:= ftabs.tabs.width;
end;

procedure tcustomtabwidget.settab_width(const avalue: integer);
begin
 ftabs.tabs.width:= avalue;
end;

function tcustomtabwidget.gettab_widthmin: integer;
begin
 result:= ftabs.tabs.widthmin;
end;

procedure tcustomtabwidget.settab_widthmin(const avalue: integer);
begin
 ftabs.tabs.widthmin:= avalue;
end;

function tcustomtabwidget.gettab_widthmax: integer;
begin
 result:= ftabs.tabs.widthmax;
end;

procedure tcustomtabwidget.settab_widthmax(const avalue: integer);
begin
 ftabs.tabs.widthmax:= avalue;
end;

procedure tcustomtabwidget.pickthumbtrack(const sender: tobjectpicker);
begin
 //dummy
end;

procedure tcustomtabwidget.cancelpickmove(const sender: tobjectpicker);
begin
 //dummy
end;

function tcustomtabwidget.getactivepageindex: integer;
begin
 if fupdating > 0 then begin
  result:= factivepageindex1;
 end
 else begin
  result:= factivepageindex;
 end;
 if csdesigning in componentstate then begin
  result:= factivepageindexdesign;
 end;
end;

procedure tcustomtabwidget.setactivepageindex1(const avalue: integer);
begin
 setactivepageindex(avalue);
 factivepageindexdesign:= avalue;//factivepageindex;
end;

procedure tcustomtabwidget.beginupdate;
begin
 if fupdating = 0 then begin
  factivepageindex1:= factivepageindex;
 end;
 inc(fupdating);
 ftabs.beginupdate;
end;

procedure tcustomtabwidget.endupdate;
var
 int1: integer;
begin
 dec(fupdating);
 if fupdating = 0 then begin
  if factivepageindex1 < count then begin
   activepageindex:= factivepageindex1;
  end;
  with ftabs.tabs do begin
   for int1:= 0 to high(fitems) do begin
    with tpagetab(fitems[int1]) do begin
     self.pagechanged(fpageintf);
    end;
   end;
  end;
 end;
 ftabs.endupdate;
 if fupdating = 0 then begin
  updatesize(nil);
 end;
end;

procedure tcustomtabwidget.clearorder;
begin
 ftabs.tabs.clearorder;
end;

function tcustomtabwidget.getstatpriority: integer;
begin
 result:= fstatpriority;
end;

procedure tcustomtabwidget.createtabframe();
begin
 ftabs.createframe();
end;

procedure tcustomtabwidget.createtabface();
begin
 ftabs.createface();
end;

procedure tcustomtabwidget.createtabfont();
begin
 ftabs.createfont();
end;

procedure tcustomtabwidget.createtabframetab();
begin
 ftabs.tabs.createframe();
end;

procedure tcustomtabwidget.createtabfacetab();
begin
 ftabs.tabs.createface();
end;

procedure tcustomtabwidget.createtabfonttab();
begin
 ftabs.tabs.createfont();
end;

procedure tcustomtabwidget.createtabfaceactivetab;
begin
 ftabs.tabs.createfaceactive();
end;

procedure tcustomtabwidget.createtabfontactivetab;
begin
 ftabs.tabs.createfontactive();
end;

{ tpagetab }

constructor tpagetab.create(const aowner: tcustomtabbar; const apage: itabpage);
begin
 fpageintf:= apage;
 inherited create(aowner);
end;

function tpagetab.page: twidget;
begin
 result:= fpageintf.getwidget;
end;

{ tcustomtabbar1 }

procedure tcustomtabbar1.internalcreateframe;
begin
 tstepboxframe1.create(iscrollframe(self),istepbar(self));
end;

end.
