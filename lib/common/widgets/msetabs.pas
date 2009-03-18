{ MSEgui Copyright (c) 1999-2008 by Martin Schreiber

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
 msetabsglob,msewidgets,mseclasses,msearrayprops,classes,mseshapes,
 mserichstring,msetypes,msegraphics,msegraphutils,mseevent,
 mseglob,mseguiglob,msegui,msebitmap,
 mseforms,rtlconsts,msesimplewidgets,msedrag,mseact,
 mseobjectpicker,msepointer,msestat,msestatfile,msestrings,msemenus;

const
 defaulttaboptionswidget = defaultoptionswidget + [ow_subfocus,ow_fontglyphheight];
 defaulttaboptionsskin = defaultoptionsskin + [osk_colorcaptionframe];
 defaultcaptiondist = 1;
 defaultimagedist = 0;
 defaulttabshift = -100; //-> 1
 defaultcaptionpos = cp_right;
 defaulttabpageskinoptions = defaultcontainerskinoptions;

type

 tcustomtabbar = class;
 tabstatety = (ts_invisible,ts_disabled,ts_active,ts_updating);
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
   fcaption: richstringty;
   fhint: msestring;
   fstate: tabstatesty;
   fcolor: colorty;
   fcoloractive: colorty;
   fident: integer;
   fimagelist: timagelist;
   fimagenr: imagenrty;
   fimagenrdisabled: imagenrty;
   function getcaption: captionty;
   procedure setcaption(const Value: captionty);
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
   property caption: captionty read getcaption write setcaption;
   property state: tabstatesty read fstate write setstate default [];
   property color: colorty read fcolor write setcolor default cl_default;
   property coloractive: colorty read fcoloractive
                 write setcoloractive default cl_default;
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
 end;

 ttabs = class;

 createtabeventty = procedure(const sender: tcustomtabbar; const index: integer;
                         var tab: ttab) of object;

 ttabframe = class(tframe)
  public
   constructor create(const intf: iframe);
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
   fcaptionpos: captionposty;
   fcaptionframe: framety;
   fimagedist: integer;
   fframe: tframe;
   fface: tface;
   ffaceactive: tface;
   fhint: msestring;
   foncreatetab: createtabeventty;
   factcellindex: integer;
   ftabshift: integer;
   fshift: integer;
   procedure setitems(const index: integer; const Value: ttab);
   function getitems(const index: integer): ttab; reintroduce;
   function getface: tface;
   procedure setface(const avalue: tface);
   function getfaceactive: tface;
   procedure setfaceactive(const avalue: tface);
   procedure setcolor(const avalue: colorty);
   procedure setcoloractive(const avalue: colorty);
   procedure setcaptionpos(const avalue: captionposty);
   procedure setcaptionframe_left(const avalue: integer);
   procedure setcaptionframe_top(const avalue: integer);
   procedure setcaptionframe_right(const avalue: integer);
   procedure setcaptionframe_bottom(const avalue: integer);
   procedure setimagedist(const avalue: integer);
   function getframe: tframe;
   procedure setframe(const avalue: tframe);
   procedure setshift(const avalue: integer);
   function getfont: ttabsfont;
   procedure setfont(const avalue: ttabsfont);
   function isfontstored: boolean;
   function getfontactive: ttabsfontactive;
   procedure setfontactive(const avalue: ttabsfontactive);
   function isfontactivestored: boolean;
  protected
   fskinupdating: integer;
   ffont: ttabsfont;
   ffontactive: ttabsfontactive;
   procedure changed;
   procedure fontchanged(const sender: tobject);
   procedure createitem(const index: integer; var item: tpersistent); override;
   procedure dochange(const index: integer); override;
//   procedure dosizechanged; override;
   procedure checktemplate(const sender: tobject);
   //iframe
   procedure setframeinstance(instance: tcustomframe);
   procedure setstaticframe(value: boolean);
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
  public
   constructor create(const aowner: tcustomtabbar; aclasstype: indexpersistentclassty);
                                         reintroduce;
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
                  write setcolor default cl_transparent;
   property coloractive: colorty read fcoloractive
                  write setcoloractive default cl_active;
   property font: ttabsfont read getfont write setfont  stored isfontstored;
   property fontactive: ttabsfontactive read getfontactive write setfontactive
                                          stored isfontactivestored;
   
   property captionpos: captionposty read fcaptionpos write
                          setcaptionpos default defaultcaptionpos;
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
   property shift: integer read fshift write setshift default defaulttabshift;
                       //defaulttabshift (-100) -> 1
   property frame: tframe read getframe write setframe;
   property face: tface read getface write setface;
   property faceactive: tface read getfaceactive write setfaceactive;
   property hint: msestring read fhint write fhint;
 end;

 tabbarlayoutinfoty = record
  tabs: ttabs;
  dim: rectty;
  activetab: integer;
  focusedtab: integer;
  cells: shapeinfoarty;
  firsttab: integer;
  lasttab: integer;
  stepinfo: framestepinfoty;
  options: shapestatesty;
 end;

 movingeventty = procedure(const sender: tobject; var curindex: integer;
                                       var newindex: integer) of object;
 movedeventty = procedure(const sender: tobject; const curindex: integer;
                                       const newindex: integer) of object;

 tcustomtabbar = class(tcustomstepbox)
  private
   flayoutinfo: tabbarlayoutinfoty;
   fhintedbutton: integer;
   fonactivetabchange: notifyeventty;
   fupdating: integer;
   finternaltabchange: objectprocty;
   fontabmoving: movingeventty;
   fontabmoved: movedeventty;
   fonclientmouseevent: mouseeventty;
   procedure settabs(const Value: ttabs);
   procedure layoutchanged;
   procedure updatelayout;
   function getactivetab: integer;
   procedure setactivetab(const Value: integer);
   procedure tabschanged(const sender: tarrayprop; const index: integer);
   procedure setfirsttab(Value: integer);
   procedure setoptions(const avalue: tabbaroptionsty);
   function gethintpos(const aindex: integer): rectty;
   function getbuttonhint(const aindex: integer): msestring;
  protected
   foptions: tabbaroptionsty;
   class function classskininfo: skininfoty; override;
   procedure dostep(const event: stepkindty); override;
   procedure doactivetabchanged;
   procedure tabchanged(const sender: ttab);
   procedure tabclicked(const sender: ttab; const info: mouseeventinfoty);
   procedure enabledchanged; override;
   procedure loaded; override;
   procedure dopaint(const canvas: tcanvas); override;
   procedure clientmouseevent(var info: mouseeventinfoty); override;
   procedure statechanged; override;
   procedure doshortcut(var info: keyeventinfoty; const sender: twidget); override;
   procedure clientrectchanged; override;
   procedure dofontheightdelta(var delta: integer); override;
   procedure objectevent(const sender: tobject; const event: objecteventty); override;
   procedure dokeydown(var info: keyeventinfoty); override;
   function upstep(const norotate: boolean): boolean;
   function downstep(const norotate: boolean): boolean;
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
 end;

 tcustomtabbar1 = class(tcustomtabbar)
  protected
   procedure internalcreateframe; override;
 end;
 
 ttabbar = class(tcustomtabbar,istatfile)
  private
   fstatfile: tstatfile;
   fstatvarname: msestring;
   procedure setstatfile(const Value: tstatfile);
   procedure setdragcontroller(const Value: tdragcontroller);
  protected
   //istatfile
   procedure dostatread(const reader: tstatreader);
   procedure dostatwrite(const writer: tstatwriter);
   procedure statreading;
   procedure statread;
   function getstatvarname: msestring;
  published
   property statfile: tstatfile read fstatfile write setstatfile;
   property statvarname: msestring read getstatvarname write fstatvarname;

   property onstep;
//   property invisiblebuttons;

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

 itabpage = interface(inullinterface) ['{AB1D0204-1DCB-4560-99A3-C0D6020B2EA7}']
  procedure settabwidget(const value: tcustomtabwidget);
  function gettabwidget: tcustomtabwidget;
  function getwidget: twidget;
  function getcaption: msestring;
  function gettabhint: msestring;
  function getcolortab: colorty;
  function getcoloractivetab: colorty;
  function getimagelist: timagelist;
  function getimagenr: imagenrty;
  function getimagenrdisabled: imagenrty;
  function getinvisible: boolean;
  procedure doselect;
  procedure dodeselect;
 end;

 ttabpage = class(tscrollingwidget,itabpage,iimagelistinfo)
  private
   ftabwidget: tcustomtabwidget;
   fcaption: msestring;
   ftabhint: msestring;
   fimagelist: timagelist;
   fimagenr: integer;
   fimagenrdisabled: integer;
   fcolortab,fcoloractivetab: colorty;
   fonselect: notifyeventty;
   fondeselect: notifyeventty;
   finvisible: boolean;
   function getcaption: captionty;
   procedure setcaption(const Value: captionty);
   function gettabhint: msestring;
   procedure settabhint(const avalue: msestring);
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
  protected
   class function classskininfo: skininfoty; override;
   procedure changed;
   procedure visiblechanged; override;
   procedure enabledchanged; override;
   procedure registerchildwidget(const child: twidget); override;
   procedure designselected(const selected: boolean); override;
   procedure doselect; virtual;
   procedure dodeselect; virtual;
   procedure loaded; override;
   procedure objectevent(const sender: tobject;
                                     const event: objecteventty); override;
   function getisactivepage: boolean;
   procedure setisactivepage(const avalue: boolean);
  public
   constructor create(aowner: tcomponent); override;
   procedure initnewcomponent(const ascale: real); override;
   property tabwidget: tcustomtabwidget read ftabwidget;
   property tabindex: integer read gettabindex write settabindex;
   property isactivepage: boolean read getisactivepage write setisactivepage;
  published
   property invisible: boolean read getinvisible write setinvisible default false;
   property caption: captionty read getcaption write setcaption;
   property tabhint: msestring read gettabhint write settabhint;
   property colortab: colorty read getcolortab
                  write setcolortab default cl_default;
   property coloractivetab: colorty read getcoloractivetab
                  write setcoloractivetab default cl_default;
   property imagelist: timagelist read getimagelist write setimagelist;
   property imagenr: imagenrty read getimagenr write setimagenr default -1;
   property imagenrdisabled: imagenrty read getimagenrdisabled 
                                           write setimagenrdisabled default -2;
                //-2 -> same as imagenr
   property font: twidgetfont read getfont write setfont stored isfontstored;
   property optionswidget default defaulttaboptionswidget;
   property onchildscaled;
   property onfontheightdelta;
   property onshow;
   property onhide;
   property onselect: notifyeventty read fonselect write fonselect;
   property ondeselect: notifyeventty read fondeselect write fondeselect;
   property visible default false;
   property optionsskin default defaulttabpageskinoptions;
 end;

 ttabform = class(tmseform,itabpage,iimagelistinfo)
  private
   ftabwidget: tcustomtabwidget;
   fimagelist: timagelist;
   fimagenr: integer;
   fimagenrdisabled: integer;
   fcolortab,fcoloractivetab: colorty;
   ftabhint: msestring;
   fonselect: notifyeventty;
   fondeselect: notifyeventty;
   finvisible: boolean;
   procedure settabwidget(const value: tcustomtabwidget);
   function gettabwidget: tcustomtabwidget;
   procedure changed;
   function getcolortab: colorty;
   procedure setcolortab(const avalue: colorty);
   function getcoloractivetab: colorty;
   procedure setcoloractivetab(const avalue: colorty);
   function gettabindex: integer;
   procedure settabindex(const avalue: integer);
   function gettabhint: msestring;
   procedure settabhint(const avalue: msestring);
   function getimagelist: timagelist;
   procedure setimagelist(const avalue: timagelist);
   function getimagenr: imagenrty;
   procedure setimagenr(const avalue: imagenrty);
   function getimagenrdisabled: imagenrty;
   procedure setimagenrdisabled(const avalue: imagenrty);
   function getinvisible: boolean;
   procedure setinvisible(const avalue: boolean);
  protected
   procedure visiblechanged; override;
   procedure setcaption(const value: msestring); override;
   procedure doselect; virtual;
   procedure dodeselect; virtual;
   procedure loaded; override;
   procedure objectevent(const sender: tobject;
                                     const event: objecteventty); override;
   class function hasresource: boolean; override;
  public
   constructor create(aowner: tcomponent); override;
   function isactivepage: boolean;
   property tabwidget: tcustomtabwidget read ftabwidget;
   property tabindex: integer read gettabindex write settabindex;
  published
   property colortab: colorty read getcolortab
                  write setcolortab default cl_default;
   property coloractivetab: colorty read getcolortab
                  write setcoloractivetab default cl_active;
   property tabhint: msestring read gettabhint write settabhint;
   property imagelist: timagelist read getimagelist write setimagelist;
   property imagenr: imagenrty read getimagenr write setimagenr default -1;
   property imagenrdisabled: imagenrty read getimagenrdisabled
                                           write setimagenrdisabled default -2;
                //-2 -> same as imagenr
   property onselect: notifyeventty read fonselect write fonselect;
   property ondeselect: notifyeventty read fondeselect write fondeselect;
   property invisible: boolean read getinvisible write setinvisible default false;
   property visible default false;
   property optionsskin;
 end;

 tpagetab = class(ttab)
  private
   fpageintf: itabpage;
  public
   constructor create(const aowner: tcustomtabbar; const apage: itabpage);
   function page: twidget;
 end;

 tcustomtabwidget = class(tactionwidget,iobjectpicker,istatfile)
  private
   ftabs: tcustomtabbar1;
   fobjectpicker: tobjectpicker;
   factivepageindex: integer;
   fonactivepagechanged: notifyeventty;
   fonpageadded: widgeteventty;
   fonpageremoved: widgeteventty;
   ftab_size: integer;
   ftab_sizemin: integer;
   ftab_sizemax: integer;
   fstatfile: tstatfile;
   fstatvarname: msestring;
   procedure setstatfile(const value: tstatfile);
   function getitems(const index: integer): twidget;
   procedure setactivepageindex(value: integer);
   function getactivepage: twidget;
   procedure setactivepage(const value: twidget);
   procedure updatesize(const page: twidget);
   function getoptions: tabbaroptionsty;
   procedure setoptions(const avalue: tabbaroptionsty);
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
   function gettab_frametab: tframe;
   procedure settab_frametab(const avalue: tframe);
   function gettab_facetab: tface;
   procedure settab_facetab(const avalue: tface);
   function gettab_faceactivetab: tface;
   procedure settab_faceactivetab(const avalue: tface);
   function checktabsizingpos(const apos: pointty): boolean;
   function getidents: integerarty;
   function gettab_captionpos: captionposty;
   procedure settab_captionpos(const avalue: captionposty);
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
   function gettab_shift: integer;
   procedure settab_shift(const avalue: integer);
   function gettab_optionswidget: optionswidgetty;
   procedure settab_optionswidget(const avalue: optionswidgetty);
  protected
   fpopuptab: integer;
   procedure internaladd(const page: itabpage; aindex: integer);
   procedure internalremove(const page: itabpage);
   procedure registerchildwidget(const child: twidget); override;
   procedure unregisterchildwidget(const child: twidget); override;
   procedure pagechanged(const sender: itabpage);
   procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
   procedure tabchanged;
   procedure loaded; override;
   procedure clientrectchanged; override;
   procedure doactivepagechanged; virtual;
   procedure dopageadded(const apage: twidget); virtual;
   procedure dopageremoved(const apage: twidget); virtual;
   procedure createpagetab(const sender: tcustomtabbar; const index: integer; var tab: ttab);
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure childmouseevent(const sender: twidget; var info: mouseeventinfoty); override;
   procedure doafterpaint(const canvas: tcanvas); override;
   procedure dofontheightdelta(var delta: integer); override;
   procedure doclosepage(const sender: tobject); virtual;
   procedure dopopup(var amenu: tpopupmenu; var mouseinfo: mouseeventinfoty); override;

   //istatfile
   procedure dostatread(const reader: tstatreader);
   procedure dostatwrite(const writer: tstatwriter);
   procedure statreading;
   procedure statread;
   function getstatvarname: msestring;

   //iobjectpicker
   function getcursorshape(const apos: pointty;  const shiftstate: shiftstatesty;
                                var shape: cursorshapety): boolean;
    //true if found
   procedure getpickobjects(const rect: rectty;  const shiftstate: shiftstatesty;
                                var objects: integerarty);
   procedure beginpickmove(const objects: integerarty);
   procedure endpickmove(const apos,offset: pointty; const objects: integerarty);
   procedure paintxorpic(const canvas: tcanvas; const apos,offset: pointty;
                 const objects: integerarty);

   function checkpickoffset(const aoffset: pointty): pointty;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure synctofontheight; override;
   function indexof(const page: twidget): integer;
   function count: integer;
   procedure clear;
   procedure nextpage(newindex: integer; down: boolean);
   procedure changepage(step: integer);
   procedure movepage(const curindex,newindex: integer);
   procedure add(const aitem: itabpage; const aindex: integer = bigint);
   function pagebyname(const aname: string): twidget;
                   //case sensitive!
                           
   property items[const index: integer]: twidget read getitems; default;
   property activepage: twidget read getactivepage write setactivepage;
   property idents: integerarty read getidents;
   property activepageindex: integer read factivepageindex 
                      write setactivepageindex default -1;
   property onactivepagechanged: notifyeventty read fonactivepagechanged write fonactivepagechanged;
   property onpageadded: widgeteventty read fonpageadded write fonpageadded;
   property onpageremoved: widgeteventty read fonpageremoved write fonpageremoved;
   property optionswidget default defaulttaboptionswidget;
   property options: tabbaroptionsty read getoptions write setoptions default [];
   property font: twidgetfont read getfont write setfont stored isfontstored;
   property tab_frame: tstepboxframe1 read gettab_frame write settab_frame;
   property tab_face: tface read gettab_face write settab_face;
   property tab_color: colorty read gettab_color write settab_color default cl_default;
   property tab_colortab: colorty read gettab_colortab 
                        write settab_colortab default cl_transparent;
   property tab_coloractivetab: colorty read gettab_coloractivetab 
                        write settab_coloractivetab default cl_active;
   property tab_captionpos: captionposty read gettab_captionpos write
                          settab_captionpos default defaultcaptionpos;
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
   property tab_shift: integer read gettab_shift write settab_shift
                                                      default defaulttabshift;
                       //defaulttabshift (-100) -> 1
   property tab_frametab: tframe read gettab_frametab write settab_frametab;
   property tab_facetab: tface read gettab_facetab write settab_facetab;
   property tab_faceactivetab: tface read gettab_faceactivetab write settab_faceactivetab;
   property tab_size: integer read ftab_size write settab_size;
   property tab_sizemin: integer read ftab_sizemin write settab_sizemin
                            default defaulttabsizemin;
   property tab_sizemax: integer read ftab_sizemax write settab_sizemax
                            default defaulttabsizemax;
   property tab_optionswidget: optionswidgetty read gettab_optionswidget
                 write settab_optionswidget default defaultoptionswidgetnofocus;
   property statfile: tstatfile read fstatfile write setstatfile;
   property statvarname: msestring read getstatvarname write fstatvarname;
 end;

 ttabwidget = class(tcustomtabwidget)
  published
   property optionswidget;
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
   property options;
   property font;
   property tab_frame;
   property tab_face;
   property tab_color;
   property tab_captionpos;
   property tab_captionframe_left;
   property tab_captionframe_top;
   property tab_captionframe_right;
   property tab_captionframe_bottom;
   property tab_imagedist;
   property tab_shift;
   property tab_colortab;
   property tab_coloractivetab;
   property tab_frametab;
   property tab_facetab;
   property tab_faceactivetab;
   property tab_size;
   property tab_sizemin;
   property tab_sizemax;
   property tab_optionswidget;
   property statfile;
   property statvarname;
 end;
 
implementation
uses
 msedrawtext,sysutils,msedatalist,msekeyboard,msestockobjects;

type
 twidget1 = class(twidget);

procedure calctablayout(var layout: tabbarlayoutinfoty;
                     const canvas: tcanvas; const focused: boolean);

 procedure docommon(const tab: ttab; var cell: shapeinfoty; var textrect: rectty);
 begin
  with tab,cell,ca do begin
   caption:= fcaption;
   imagedist:= layout.tabs.fimagedist;
   captionpos:= layout.tabs.fcaptionpos;
   imagelist:= fimagelist;
   imagenr:= fimagenr;
   imagenrdisabled:= fimagenrdisabled;
   if imagelist <> nil then begin
    inc(textrect.cx,fimagelist.width+imagedist);
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
 int1: integer;
 aval: integer;
 endval: integer;
 rect1: rectty;
 bo1: boolean;
 cxinflate: integer;
 cyinflate: integer;
 frame1: framety;
begin
 with layout do begin
  cells:= nil;
  setlength(cells,tabs.count);
  if firsttab > high(cells) then begin
   firsttab:= 0;
  end;
  lasttab:= -1;
  cxinflate:= tabs.fcaptionframe.left + tabs.fcaptionframe.right + 2;
  cyinflate:= tabs.fcaptionframe.top + tabs.fcaptionframe.bottom + 2;
  if tabs.fframe <> nil then begin
   with tabs.fframe do begin
    frame1:= subframe(paintframe,framei);
    cxinflate:= cxinflate + frame1.left + frame1.right;
    cyinflate:= cyinflate + frame1.top + frame1.bottom;
    if fso_flat in optionsskin then begin
     cxinflate:= cxinflate - 2;
     cyinflate:= cyinflate - 2;
    end;
   end;
  end;
  if shs_vert in options then begin
   aval:= dim.y;
   endval:= dim.y + dim.cy;
   for int1:= 0 to high(cells) do begin
    with tabs[int1],cells[int1],ca do begin
     dim.y:= aval;
     dofont(tabs[int1],cells[int1]);
     rect1:= textrect(canvas,fcaption,
                        makerect(layout.dim.x,aval,layout.dim.cx,bigint),[],font);
     docommon(tabs[int1],cells[int1],rect1);
     dim.cy:= rect1.cy+cyinflate;
     if (imagelist <> nil) and (imagelist.height > dim.cy) then begin
      dim.cy:= imagelist.height;
     end;
     if (ts_invisible in fstate) or (int1 < firsttab) or (aval >= endval) then begin
      include(state,shs_invisible);
     end
     else begin
      inc(aval,dim.cy);
      if (aval < endval) then begin
       lasttab:= int1;
      end;
     end;
     if ts_active in fstate then begin
      dim.x:= tabs.ftabshift;
      if shs_opposite in options then begin
       dim.x:= -dim.x;
      end;
     end
     else begin
      dim.x:= 0;
     end;
     dim.cx:= layout.dim.cx;
    end;
   end;
  end
  else begin
   aval:= dim.x;
   endval:= dim.x + dim.cx;
   for int1:= 0 to high(cells) do begin
    with tabs[int1],cells[int1],ca do begin
     dim.x:= aval;
     dofont(tabs[int1],cells[int1]);
     rect1:= textrect(canvas,fcaption,
               makerect(aval,layout.dim.y,bigint,layout.dim.cy),[],font);
     docommon(tabs[int1],cells[int1],rect1);
     dim.cx:= rect1.cx + cxinflate;
     if (ts_invisible in fstate) or (int1 < firsttab) or (aval >= endval) then begin
      include(state,shs_invisible);
     end
     else begin
      inc(aval,dim.cx);
      if (aval < endval) then begin
       lasttab:= int1;
      end;
     end;
     if ts_active in fstate then begin
      dim.y:= tabs.ftabshift;
      if shs_opposite in options then begin
       dim.y:= -dim.y;
      end;
     end
     else begin
      dim.y:= 0;
     end;
     dim.cy:= layout.dim.cy;
    end;
   end;
  end;
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
     face:= tabs.face;
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
  if lasttab > high(cells) then begin
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

function ttab.getcaption: captionty;
begin
 result:= richstringtocaption(fcaption);
end;

procedure ttab.setcaption(const Value: captionty);
begin
 captiontorichstring(value,fcaption);
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
  if (fstate * [ts_invisible,ts_disabled] <> []) and 
       not (csdesigning in tcustomtabbar(fowner).componentstate) then begin
   exclude(fstate,ts_active);
  end;
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

function ttab.getimagelist: timagelist;
begin
 result:= fimagelist;
end;

procedure ttab.fontchanged(const sender: tobject);
begin
 changed;
end;

{ ttabframe }

constructor ttabframe.create(const intf: iframe);
begin
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
 fcolor:= cl_transparent;
 fcoloractive:= cl_active;
 fcaptionpos:= defaultcaptionpos;
 fcaptionframe.left:= defaultcaptiondist;
 fcaptionframe.top:= defaultcaptiondist;
 fcaptionframe.right:= defaultcaptiondist;
 fcaptionframe.bottom:= defaultcaptiondist;
 fimagedist:= defaultimagedist;
 fshift:= defaulttabshift;
 ftabshift:= 1;
 inherited create(aowner,aclasstype);
end;

destructor ttabs.destroy;
begin
 fface.free;
 ffaceactive.free;
 fframe.free;
 ffont.free;
 ffontactive.free;
 inherited;
end;

class function ttabs.getitemclasstype: persistentclassty;
begin
 result:= ttab;
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

procedure ttabs.setcaptionpos(const avalue: captionposty);
begin
 if avalue <> fcaptionpos then begin
  fcaptionpos:= avalue;
  changed;
 end;
end;

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
 fframe:= tframe(instance);
end;

procedure ttabs.setstaticframe(value: boolean);
begin
 //dummy
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
 result:= shapestatetoframestate(factcellindex,
                              tcustomtabbar(fowner).flayoutinfo.cells);
end;

procedure ttabs.dochange(const index: integer);
begin
 inherited;
 if (index = -1) and (fskinupdating = 0) and (count > 0) and 
            not (csloading in tcustomtabbar(fowner).componentstate) then begin
  tcustomtabbar(fowner).updateskin; 
        //could be a new item which needs skin setup
 end;
end;

function ttabs.getframe: tframe;
begin
 tcustomtabbar(fowner).getoptionalobject(fframe,
                               {$ifdef FPC}@{$endif}createframe);
 result:= fframe;
end;

procedure ttabs.setframe(const avalue: tframe);
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
  ffont.onchange:= {$ifdef FPC}@{$endif}fontchanged;
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
 flayoutinfo.lasttab:= -1;
 fhintedbutton:= -2;
 inherited;
 fwidgetrect.cy:= font.glyphheight + 4;
end;

destructor tcustomtabbar.destroy;
begin
 flayoutinfo.tabs.Free;
 inherited;
end;

procedure tcustomtabbar.settabs(const Value: ttabs);
begin
 flayoutinfo.tabs.assign(Value);
end;

procedure tcustomtabbar.updatelayout;
var
 int1,int2: integer;
begin
 with flayoutinfo do begin
  dim:= innerclientrect;
  options:= [];
  if tabo_vertical in foptions then begin
   include(options,shs_vert);
  end;
  if tabo_opposite in foptions then begin
   include(options,shs_opposite);
  end;
  calctablayout(flayoutinfo,getcanvas,focused);
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
  frame.updatebuttonstate(firsttab,stepinfo.pageup,int2);
 end;
 invalidate;
end;

procedure tcustomtabbar.layoutchanged;
begin
 if not (csloading in componentstate)  and
     not ((owner <> nil) and (csloading in owner.ComponentState)) then begin
           //todo: support for cssubcomponent in fpc
  updatelayout;
  invalidate;
 end;
end;

function comptabs(const l,r): integer;
begin
 result:= msecomparetext(ttab(l).fcaption.text,ttab(r).fcaption.text);
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
    finternaltabchange;
   end;
   if tabo_sorted in foptions then begin
    sortarray(pointerarty(flayoutinfo.tabs.fitems),{$ifdef FPC}@{$endif}comptabs);
    updateactivetabindex;
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

procedure tcustomtabbar.tabclicked(const sender: ttab; const info: mouseeventinfoty);
begin
 if (tabo_clickedtabfirst in foptions) or 
    (tabo_dblclickedtabfirst in foptions) and (ss_double in info.shiftstate) then begin
  movetab(sender.findex,0);
 end;
 sender.active:= true;
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
 updatelayout;
 doactivetabchanged;
end;

procedure tcustomtabbar.dopaint(const canvas: tcanvas);
var
 int1,int2,int3: integer;
 color1: colorty;
 rect1: rectty;
 bo1: boolean;
begin
 inherited;
 with flayoutinfo do begin
  int1:= high(cells);
  rect1:= innerclientrect;
  canvas.intersectcliprect(rect1);
  if shs_vert in options then begin
   if shs_opposite in options then begin
    int2:= rect1.x;
    color1:= defaultframecolors.shadow.color;
   end
   else begin
    int2:= rect1.x+rect1.cx-1;
    color1:= defaultframecolors.light.effectcolor;
   end;
   int3:= rect1.y+rect1.cy-1;
   canvas.drawline(makepoint(int2,rect1.y),makepoint(int2,int3),color1);
  end
  else begin
   if shs_opposite in options then begin
    int2:= rect1.y;
    color1:= defaultframecolors.shadow.color;
   end
   else begin
    int2:= rect1.y+rect1.cy-1;
    color1:= defaultframecolors.light.effectcolor;
   end;
   int3:= rect1.x+rect1.cx-1;
   canvas.drawline(makepoint(rect1.x,int2),makepoint(int3,int2),color1);
  end;
  for int1:= firsttab to lasttab do begin
   tabs.factcellindex:= int1;
   cells[int1].frame:= tabs.fframe; //todo: move to layoutcalc
   drawtab(canvas,cells[int1],@tabs.fcaptionframe);
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
begin
 if not (es_processed in info.eventstate) and 
                           canevent(tmethod(fonclientmouseevent)) then begin
  fonclientmouseevent(self,info);
 end;
 inherited;
 if updatemouseshapestate(flayoutinfo.cells,info,self,
                            flayoutinfo.focusedtab,flayoutinfo.tabs.fframe) then begin
  include(info.eventstate,es_processed);
 end;
 if not (csdesigning in componentstate) or 
                            (ws1_designactive in fwidgetstate1) then begin
  with flayoutinfo do begin
   checkbuttonhint(self,info,fhintedbutton,cells,{$ifdef FPC}@{$endif}getbuttonhint,
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

procedure tcustomtabbar.synctofontheight;
var
 int1,int2: integer;
begin
 inherited;
 if not (tabo_vertical in options) then begin
  with flayoutinfo.tabs.fcaptionframe do begin
   int2:= font.glyphheight + top + bottom;
  end;
  for int1:= 0 to flayoutinfo.tabs.count - 1 do begin
   with flayoutinfo.tabs[int1] do begin
    if (imagelist <> nil) and (imagelist.height > int2) then begin
     int2:= imagelist.height;
    end;
   end;
  end;
  bounds_cy:= int2 + fframe.innerframewidth.cy + 2;
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
end;

procedure tcustomtabbar.dostep(const event: stepkindty);
begin
 firsttab:= frame.executestepevent(event,flayoutinfo.stepinfo,flayoutinfo.firsttab);
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
begin
 if avalue <> foptions then begin
  optionsbefore:= foptions;
  foptions:= avalue;
  delta:= tabbaroptionsty({$ifdef FPC}longword{$else}word{$endif}(avalue) xor
                 {$ifdef FPC}longword{$else}word{$endif}(optionsbefore));
  if not (csloading in componentstate) then begin
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
  with info do begin
   case eventkind of
    dek_begin: begin
     if (dragobjectpo^ = nil) and not (tabo_sorted in foptions) and
      ((tabo_dragsource in foptions) or (csdesigning in componentstate)) then begin
      int1:= tabatpos(pos,(tabo_dragsourceenabledonly in foptions) and
                  not (csdesigning in componentstate));
      if int1 >= 0 then begin
       ttagdragobject.create(self,dragobjectpo^,fdragcontroller.pickpos,int1);
      end;
     end;
    end;
    dek_check: begin
     if candest then begin
      accept:= true;
     end;
    end;
    dek_drop: begin
     if candest then begin
      movetab(ttagdragobject(dragobjectpo^).tag,int1);
     end;
    end;
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
 result:= flayoutinfo.tabs[aindex].hint;
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

{ ttabbar }

procedure ttabbar.dostatread(const reader: tstatreader);
begin
 flayoutinfo.tabs.dostatread(reader);
 activetab:= reader.readinteger('activetab',activetab);
end;

procedure ttabbar.dostatwrite(const writer: tstatwriter);
begin
 flayoutinfo.tabs.dostatwrite(writer);
 writer.writeinteger('activetab',activetab);
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

{ ttabpage }

constructor ttabpage.create(aowner: tcomponent);
begin
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
 if ftabwidget <> nil then begin
  ftabwidget.pagechanged(itabpage(self));
 end;
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

function ttabpage.getcolortab: colorty;
begin
 result:= fcolortab;
end;

procedure ttabpage.setcolortab(const avalue: colorty);
begin
 fcolortab:= avalue;
 changed;
end;

function ttabpage.getcoloractivetab: colorty;
begin
 result:= fcoloractivetab;
end;

procedure ttabpage.setcoloractivetab(const avalue: colorty);
begin
 fcoloractivetab:= avalue;
 changed;
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
begin
 if canevent(tmethod(fonselect)) then begin
  fonselect(self);
 end;
end;

procedure ttabpage.dodeselect;
begin
 if canevent(tmethod(fondeselect)) then begin
  fondeselect(self);
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

{ ttabform }

constructor ttabform.create(aowner: tcomponent);
begin
 fcolortab:= cl_default;
 fcoloractivetab:= cl_active;
 fimagenr:= -1;
// fimagenractive:= -2;
 fimagenrdisabled:= -2;
 inherited create(aowner);
 exclude(fwidgetstate,ws_visible);
end;

procedure ttabform.loaded;
begin
 if fparentwidget is tcustomtabwidget then begin
  include(fwidgetstate1,ws1_nodesignvisible);
 end;
 inherited;
end;

procedure ttabform.changed;
begin
 if ftabwidget <> nil then begin
  ftabwidget.pagechanged(itabpage(self));
 end;
end;

function ttabform.getcolortab: colorty;
begin
 result:= fcolortab;
end;

procedure ttabform.setcolortab(const avalue: colorty);
begin
 fcolortab:= avalue;
 changed;
end;

function ttabform.getcoloractivetab: colorty;
begin
 result:= fcoloractivetab;
end;

procedure ttabform.setcoloractivetab(const avalue: colorty);
begin
 fcoloractivetab:= avalue;
 changed;
end;

function ttabform.gettabwidget: tcustomtabwidget;
begin
 result:= ftabwidget;
end;

function ttabform.isactivepage: boolean;
begin
 result:= (ftabwidget <> nil) and (ftabwidget.activepage = self);
end;

procedure ttabform.setcaption(const value: msestring);
begin
 inherited;
 changed;
end;

function ttabform.gettabhint: msestring;
begin
 result:= ftabhint;
end;

procedure ttabform.settabhint(const avalue: msestring);
begin
 ftabhint:= avalue;
 changed;
end;

procedure ttabform.settabwidget(const value: tcustomtabwidget);
begin
 ftabwidget:= value;
end;

procedure ttabform.visiblechanged;
begin
 inherited;
 changed;
end;

function ttabform.gettabindex: integer;
begin
 if tabwidget = nil then begin
  result:= -1;
 end
 else begin
  result:= tabwidget.indexof(self);
 end;
end;

procedure ttabform.settabindex(const avalue: integer);
begin
 if tabwidget <> nil then begin
  tabwidget.movepage(tabindex,avalue);
 end;
end;

procedure ttabform.doselect;
begin
 if canevent(tmethod(fonselect)) then begin
  fonselect(self);
 end;
end;

procedure ttabform.dodeselect;
begin
 if canevent(tmethod(fondeselect)) then begin
  fondeselect(self);
 end;
end;

function ttabform.getimagelist: timagelist;
begin
 result:= fimagelist
end;

procedure ttabform.setimagelist(const avalue: timagelist);
begin
 if fimagelist <> avalue then begin
  setlinkedvar(avalue,tmsecomponent(fimagelist));
  changed;
 end;
end;

function ttabform.getimagenr: imagenrty;
begin
 result:= fimagenr;
end;

procedure ttabform.setimagenr(const avalue: imagenrty);
begin
 if fimagenr <> avalue then begin
  fimagenr:= avalue;
  changed;
 end;
end;
{
function ttabform.getimagenractive: integer;
begin
 result:= fimagenractive;
end;

procedure ttabform.setimagenractive(const avalue: integer);
begin
 if fimagenractive <> avalue then begin
  fimagenractive:= avalue;
  changed;
 end;
end;
}
function ttabform.getimagenrdisabled: imagenrty;
begin
 result:= fimagenrdisabled;
end;

procedure ttabform.setimagenrdisabled(const avalue: imagenrty);
begin
 if fimagenrdisabled <> avalue then begin
  fimagenrdisabled:= avalue;
  changed;
 end;
end;

procedure ttabform.objectevent(const sender: tobject;
               const event: objecteventty);
begin
 inherited;
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

function ttabform.getinvisible: boolean;
begin
 result:= finvisible;
end;

procedure ttabform.setinvisible(const avalue: boolean);
begin
 if finvisible <> avalue then begin
  finvisible:= avalue;
  changed;
 end;
end;

class function ttabform.hasresource: boolean;
begin
 result:= self <> ttabform;
end;

{ tcustomtabwidget }

constructor tcustomtabwidget.create(aowner: tcomponent);
begin
 factivepageindex:= -1;
 ftab_sizemin:= defaulttabsizemin;
 ftab_sizemax:= defaulttabsizemax;
 inherited;
 foptionswidget:= defaulttaboptionswidget;
 optionsskin:= defaulttaboptionsskin;
 ftabs:= tcustomtabbar1.create(self);
 ftabs.fanchors:= [an_left,an_top,an_right];
 ftab_size:= ftabs.size.cy;
 ftabs.SetSubComponent(true);
 ftabs.tabs.oncreatetab:= {$ifdef FPC}@{$endif}createpagetab;
 exclude(ftabs.fwidgetstate,ws_iswidget);
 ftabs.setlockedparentwidget(self);
// ftabs.parentwidget:= self;
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
 while count > 0 do begin
  items[count-1].Free;
 end;
end;

function tcustomtabwidget.getitems(const index: integer): twidget;
begin
 result:= tpagetab(ftabs.tabs[index]).page;
end;

procedure tcustomtabwidget.pagechanged(const sender: itabpage);
var
 widget1: twidget1;
 int1: integer;
 activepageindexbefore: integer;
 bo1: boolean;
begin
 if not (ws_destroying in fwidgetstate) then begin
  widget1:= twidget1(sender.getwidget);
  int1:= indexof(widget1);
  with ftabs.tabs[int1] do begin
   if not (csloading in componentstate) then begin
    activepageindexbefore:= factivepageindex;
    caption:= sender.getcaption;
    hint:= sender.gettabhint;
    color:= sender.getcolortab;
    coloractive:= sender.getcoloractivetab;
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
    if not bo1 and widget1.isvisible and (widget1.enabled or 
                     (csdesigning in widget1.componentstate)) then begin
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
                 (fwindow.focusedwidget = nil))) then begin
                 //probable page destroyed
        activepage.setfocus(active);
       end;
      end;
     end;
    end;
   end
   else begin
    include(fstate,ts_updating);
    caption:= sender.getcaption; //no updatelayout
    exclude(fstate,ts_updating);
   end;
  end;
 end;
end;

procedure tcustomtabwidget.loaded;
var
 int1: integer;
begin
 inc(fdesignchangedlock);
 inherited;
 ftabs.loaded;
 updatesize(nil);
 int1:= factivepageindex;
 factivepageindex:= -1;
 activepageindex:= int1;
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

begin
 if not (csloading in componentstate) then begin
  rect1:= innerwidgetrect;
  if page <> nil then begin
   updatepagesize(page);
  end
  else begin
   if tabo_vertical in ftabs.options then begin
    if tabo_opposite in ftabs.options then begin
     ftabs.setwidgetrect(makerect(rect1.x+rect1.cx-ftab_size,rect1.y,
                                         ftab_size,rect1.cy));
    end
    else begin
     ftabs.setwidgetrect(makerect(rect1.x,rect1.y,ftab_size,rect1.cy));
    end;
   end
   else begin
    if tabo_opposite in ftabs.options then begin
     ftabs.setwidgetrect(makerect(rect1.x,rect1.y+rect1.cy-ftab_size,
                                         rect1.cx,ftab_size));
    end
    else begin
     ftabs.setwidgetrect(makerect(rect1.x,rect1.y,rect1.cx,ftab_size));
    end;
   end;
   for int1:= 0 to ftabs.tabs.count - 1 do begin
    updatepagesize(items[int1]);
   end;
  end;
 end;
end;

procedure tcustomtabwidget.internaladd(const page: itabpage; aindex: integer);
var
 tab: tpagetab;
 widget1: twidget1;
begin
 widget1:= twidget1(page.getwidget);
 if indexof(widget1) < 0 then begin
  if aindex > count then begin
   aindex:= count;
  end;
  widget1.visible:= false;
  tab:= tpagetab.create(ftabs,page);
  if not (csloading in componentstate) then begin
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
  if not (csloading in componentstate) then begin
   activepageindex:= aindex;
  end;
  dopageadded(widget1);
 end;
end;

procedure tcustomtabwidget.internalremove(const page: itabpage);
var
 int1: integer;
 widget1: twidget1;
 activebefore: integer;
begin
 if ftabs <> nil then begin
  widget1:= twidget1(page.getwidget);
  int1:= indexof(widget1);
  if int1 >= 0 then begin
   activebefore:= factivepageindex;
   if factivepageindex >= 0 then begin
    if factivepageindex > int1 then begin
     dec(factivepageindex);
    end
    else begin
     if factivepageindex = int1 then begin
      factivepageindex:= -1;
     end;
    end;
   end;
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

procedure tcustomtabwidget.add(const aitem: itabpage; const aindex: integer = bigint);
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
begin
 if value <> factivepageindex then begin
  if csloading in componentstate then begin
   factivepageindex:= value;
   exit;
  end;
  if (value >= 0) then begin
   ftabs.flayoutinfo.tabs.checkindex(value);
  end
  else begin
   value:= -1;
  end;
  
  parenttabfocus:= ow_parenttabfocus in foptionswidget;
  exclude(foptionswidget,ow_parenttabfocus);
  try
   if factivepageindex >= 0 then begin
    if not canparentclose(items[factivepageindex]) then begin
     ftabs.tabs[factivepageindex].active:= true;
     exit;
    end;
    int1:= factivepageindex;
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
    ftabs.tabs[int1].active:= false; //if items[int1] was already invisible
   end;
   factivepageindex := Value;
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
     visible:= true;
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
    if value >= 0 then begin
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

procedure tcustomtabwidget.tabchanged;
begin
 activepageindex:= ftabs.activetab;
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
 designchanged;
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
 nextpage(activepageindex+step,step < 0);
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

procedure tcustomtabwidget.childmouseevent(const sender: twidget; var info: mouseeventinfoty);
begin
 if not ftabs.fdragcontroller.active and 
    ((sender = self) or (sender = ftabs) or (sender = activepage))  then begin
  translatewidgetpoint1(info.pos,sender,self);
  fobjectpicker.mouseevent(info);
  translatewidgetpoint1(info.pos,self,sender);
 end;
end;

procedure tcustomtabwidget.doafterpaint(const canvas: tcanvas);
begin
 inherited;
 fobjectpicker.restorexorpic(canvas);
end;

procedure tcustomtabwidget.synctofontheight;
begin
 inherited;
 if not (tabo_vertical in options) then begin
  ftabs.synctofontheight;
  tab_size:= ftabs.bounds_cy;
 end;
end;


procedure tcustomtabwidget.dofontheightdelta(var delta: integer);
begin
 if not (tabo_vertical in options) then begin
  synctofontheight;
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
 ftabs.flayoutinfo.tabs.dostatread(reader);
 if tabo_tabsizing in options then begin
  tab_size:= reader.readinteger('tabsize',tab_size);
 end;
 ftabs.firsttab:= reader.readinteger('firsttab',ftabs.firsttab);
 setactivepageindex(reader.readinteger('index',activepageindex,-1,count-1));
end;

procedure tcustomtabwidget.dostatwrite(const writer: tstatwriter);
begin
 ftabs.flayoutinfo.tabs.dostatwrite(writer);
 if tabo_tabsizing in options then begin
  writer.writeinteger('tabsize',tab_size);
 end;
 writer.writeinteger('firsttab',ftabs.firsttab);
 writer.writeinteger('index',activepageindex);
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
function tcustomtabwidget.getcursorshape(const apos: pointty;  const shiftstate: shiftstatesty;
                                var shape: cursorshapety): boolean;
    //true if found
begin
 result:= checktabsizingpos(apos);
 if result then begin
  if tabo_vertical in ftabs.foptions then begin
   shape:= cr_sizehor;
  end
  else begin
   shape:= cr_sizever;
  end;
 end
end;

procedure tcustomtabwidget.getpickobjects(const rect: rectty;  const shiftstate: shiftstatesty;
                                 var objects: integerarty);
begin
 if checktabsizingpos(rect.pos) then begin
  setlength(objects,1);
 end;
end;

procedure tcustomtabwidget.beginpickmove(const objects: integerarty);
begin
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

procedure tcustomtabwidget.endpickmove(const apos,offset: pointty; const objects: integerarty);
var
 offset1: pointty;
begin
 offset1:= checkpickoffset(offset);
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

procedure tcustomtabwidget.paintxorpic(const canvas: tcanvas; const apos,offset: pointty;
                 const objects: integerarty);
var
 offset1: pointty;
begin
 offset1:= checkpickoffset(offset);
 with ftabs,ftabs.fwidgetrect do begin
  if tabo_vertical in options then begin
   if tabo_opposite in foptions then begin
    canvas.drawline(makepoint(x+offset1.x,y),makepoint(x+offset1.x,y+cy-1),cl_white);
   end
   else begin
    canvas.drawline(makepoint(x+cx+offset1.x,y),makepoint(x+cx+offset1.x,y+cy-1),cl_white);
   end;
  end
  else begin
   if tabo_opposite in foptions then begin
    canvas.drawline(makepoint(x,y+offset1.y),makepoint(cx-1,y+offset1.y),cl_white);
   end
   else begin
    canvas.drawline(makepoint(x,y+cy+offset1.y),makepoint(cx-1,y+cy+offset1.y),cl_white);
   end;
  end;
 end;
end;

function tcustomtabwidget.getoptions: tabbaroptionsty;
begin
 result:= ftabs.options;
end;

procedure tcustomtabwidget.setoptions(const avalue: tabbaroptionsty);
var
 optionsbefore: tabbaroptionsty;
begin
 optionsbefore:= ftabs.options;
 ftabs.options:= avalue;
 if (tabbaroptionsty({$ifdef FPC}longword{$else}word{$endif}(optionsbefore) xor
            {$ifdef FPC}longword{$else}word{$endif}(ftabs.options)) *
    [tabo_vertical,tabo_opposite] <> []) then begin
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

function tcustomtabwidget.gettab_frametab: tframe;
begin
 result:= ftabs.tabs.frame;
end;

procedure tcustomtabwidget.settab_frametab(const avalue: tframe);
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

function tcustomtabwidget.gettab_captionpos: captionposty;
begin
 result:= ftabs.tabs.captionpos;
end;

procedure tcustomtabwidget.settab_captionpos(const avalue: captionposty);
begin
 ftabs.tabs.captionpos:= avalue;
end;

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

procedure tcustomtabwidget.dopopup(var amenu: tpopupmenu;
               var mouseinfo: mouseeventinfoty);
begin
 if (tabo_autopopup in options) then begin
  fpopuptab:= ftabs.tabatpos(translateclientpoint(mouseinfo.pos,self,ftabs));
  if fpopuptab >= 0 then begin
   tpopupmenu.additems(amenu,self,mouseinfo,
      [stockobjects.captions[sc_close_page]],
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
