{ MSEgui Copyright (c) 1999-2018 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msewidgets;

{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$goto on}{$endif}

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
 classes,mclasses,msegui,mseguiglob,msetypes,msestrings,msegraphutils, msefont,
 msegraphics,msesystypes,mseassistiveclient,mselist,
 mseevent,msescrollbar,msemenus,mserichstring,msedrawtext,mseglob,mseact,
 mseshapes,mseclasses,msebitmap,msetimer;

type

 sizeeventty = procedure(const sender: tobject; var asize: sizety) of object;

 tframefont = class(tparentfont)
  public
   class function getinstancepo(owner: tobject): pfont; override;
 end;

 captionframeoptionty = (cfo_fixleft,cfo_fixright,cfo_fixtop,cfo_fixbottom,
                         cfo_autowidth,cfo_autoheight,
                               //paint area as big as possible
                         cfo_captionnogray,
                         cfo_captiondistouter,cfo_captionframecentered,
                         cfo_captionnoclip,cfo_nofocusrect,cfo_forcefocusrect,
                         cfo_focusrect, //override template fso_nofocusrect
                         cfo_captionfocus,cfo_framerectfocus
                         {,cfo_captionbackground});
 captionframeoptionsty = set of captionframeoptionty;

const
 defaultcaptionframeoptions = [];

type
 doublewidgetty = record
                   a,b: twidget;
                  end;
 pdoublewidgetty = ^doublewidgetty;
 doublewidgetarty = array of doublewidgetty;
 ttaborderoverride = class;
 tabordereventty = procedure(const sender: ttaborderoverride;
                     const current: twidget; const down: boolean;
                                                  var next: twidget) of object;
 ttaborderoverride = class(tlinkedpersistent)
  private
   fontaborder: tabordereventty;
   procedure readitems(reader: treader);
   procedure writeitems(writer: twriter);
  protected
   fowner: twidget;
   fitems: doublewidgetarty;
   fwidgetnames: stringarty;
   procedure defineproperties(filer: tfiler) override;
   procedure objevent(const sender: iobjectlink;
                                const event: objecteventty) override;
   procedure endread(const reader: treader);
  public
   constructor create(const aowner: twidget); reintroduce;
   destructor destroy(); override;
   procedure clear();
   function nexttaborder(sender: twidget; const down: boolean): twidget;
   procedure add(const aa,ab: twidget);
   property owner: twidget read fowner;
  published
   property ontaborder: tabordereventty read fontaborder write fontaborder;
 end;

 tcustomcaptionframe = class(tcustomframe)
  private
   fcaptionpos: captionposty;
   fupdating: integer;
   fcaption: msestring;
//   function getcaption: msestring;
   procedure setcaption(const avalue: msestring);
   procedure fontchanged(const sender: tobject);
   function isfontstored: Boolean;
   procedure setfont(const Value: tframefont);
   function getfont: tframefont;
   procedure setcaptionpos(const avalue: captionposty);
   procedure setcaptiondist(const Value: integer);
   function iscaptiondiststored: boolean;
   procedure setcaptionoffset(const Value: integer);
   function iscaptionoffsetstored: boolean;
   procedure readouterframe(reader: treader);
   procedure writeouterframe(writer: twriter);
   procedure readcaptionnoclip(reader: treader);
   procedure readcaptiondistouter(reader: treader);
   procedure setoptions(const avalue: captionframeoptionsty);
   procedure setcaptiontextflags(const avalue: textflagsty);
  protected
   ffont: tframefont;
   finfo: drawtextinfoty;
   fcaptiondist: integer;
   fcaptionoffset: integer;
   foptions: captionframeoptionsty;
   procedure settemplateinfo(const ainfo: frameinfoty); override;
   procedure parentfontchanged; override;
   procedure fontcanvaschanged; override;
   procedure visiblechanged; override;

   function updatetextflags(const aflags: textflagsty): textflagsty;
   procedure updaterects; override;
   procedure updatehotkeys() override;
   procedure dominsize(var asize: sizety);
   procedure checkminshrinksize(var asize: sizety) override;
   procedure defineproperties(filer: tfiler); override;
   procedure setdisabled(const value: boolean); override;
   procedure dopaintfocusrect(const canvas: tcanvas;
                                              const rect: rectty); override;
   function checkfocusshortcut(var info: keyeventinfoty): boolean; override;
   function needsfocuspaint: boolean; override;
   function haspaintrectfocus(): boolean; override; //checks caption
   procedure updatemousestate(const sender: twidget;
                               const info: mouseeventinfoty); override;
   procedure internalpaintoverlay(const canvas: tcanvas;
                                          const arect: rectty) override;

    //iassistiveclient
   function getassistivecaption(): msestring; override;

  public
   constructor create(const aintf: icaptionframe);
   destructor destroy; override;
   procedure scale(const ascale: real); override;
   procedure createfont;
   function pointincaption(const point: pointty): boolean; override;
                //origin = widgetrect
   procedure checkwidgetsize(var asize: sizety); override;
                //extends to minimal size

   property options: captionframeoptionsty read foptions
                     write setoptions default defaultcaptionframeoptions;
   property caption: msestring read fcaption write setcaption;
   property captiontextflags: textflagsty read finfo.flags write
                                           setcaptiontextflags default [];
   property captionpos: captionposty read fcaptionpos
             write setcaptionpos default cp_topleft;
   property captiondist: integer read fcaptiondist write setcaptiondist
                                  stored iscaptiondiststored default 1;
   property captionoffset: integer read fcaptionoffset write setcaptionoffset
                                  stored iscaptionoffsetstored default 0 ;
   property font: tframefont read getfont
                        write setfont stored isfontstored;
 end;

 tcaptionframe = class(tcustomcaptionframe)
  published
   property options;
   property levelo;
   property leveli;
   property framewidth;
   property colorframe;
   property colorframeactive;
   property colorframedisabled;
   property colorframemouse;
   property colorframeclicked;
   property colorframedefault;
   property colordkshadow;
   property colorshadow;
   property colorlight;
   property colorhighlight;
   property colordkwidth;
   property colorhlwidth;
   property hiddenedges;
   property framei_left;
   property framei_top;
   property framei_right;
   property framei_bottom;
   property frameo_left;
   property frameo_top;
   property frameo_right;
   property frameo_bottom;

   property frameimage_list;
   property frameimage_left;
   property frameimage_top;
   property frameimage_right;
   property frameimage_bottom;
   property frameimage_offset;
   property frameimage_offset1;
   property frameimage_offsetdisabled;
   property frameimage_offsetmouse;
   property frameimage_offsetclicked;
   property frameimage_offsetactive;
   property frameimage_offsetfocused;
{
   property frameimage_offsetactivemouse;
   property frameimage_offsetactiveclicked;
}
   property frameface_list;
   property frameface_offset;
   property frameface_offset1;
   property frameface_offsetdisabled;
   property frameface_offsetmouse;
   property frameface_offsetclicked;
   property frameface_offsetactive;
   property frameface_offsetfocused;
{
   property frameface_offsetactivemouse;
   property frameface_offsetactiveclicked;
}
   property optionsskin;

   property colorclient;
   property caption;
   property captiontextflags;
   property captionpos;
   property captiondist;
   property captionoffset;
   property focusrectdist;
   property extraspace;
   property imagedist;
   property imagedist1;
   property imagedist2;
   property font;
   property localprops;  //before template
   property localprops1; //before template
   property template;
 end;

 timpressedcaptionframe = class(tcaptionframe)
  public
   constructor create(const aintf: icaptionframe);
  published
   property levelo default -2;
 end;

const
 defaultscrollboxscrollbaroptions = [sbo_thumbtrack,sbo_moveauto,sbo_showauto];
 scrollbarframestates: framestatesty = [fs_sbleft,fs_sbtop,fs_sbright,fs_sbbottom];

type
 tscrollboxscrollbar = class(tnopagesizescrollbar)
  public
   constructor create(intf: iscrollbar; org: originty = org_client;
              ondimchanged: proceventty = nil); override;
  published
   property options default defaultscrollboxscrollbaroptions;
 end;

const
 defaultthumbtrackscrollbaroptions = [sbo_thumbtrack,sbo_showauto];

type
 tthumbtrackscrollbar = class(tnomoveautoscrollbar)
  public
   constructor create(intf: iscrollbar; org: originty = org_client;
              ondimchanged: proceventty = nil); override;
  published
   property options default defaultthumbtrackscrollbaroptions;
 end;

 tthumbtracknopagesizescrollbar = class(tnomoveautonopagesizescrollbar)
  public
   constructor create(intf: iscrollbar; org: originty = org_client;
              ondimchanged: proceventty = nil); override;
  published
   property options default defaultthumbtrackscrollbaroptions;
 end;

 framescrollbarclassty = class of tcustomscrollbar;

 optionscrollty = (oscr_drag,oscr_zoomwidth,oscr_zoomheight,
                   oscr_key,oscr_mousewheel);
 optionsscrollty = set of optionscrollty;

const
 defaultoptionsscroll = [oscr_mousewheel];
 defaultdragbuttons = [ss_middle];

type
 tcustomscrollframe = class(tcustomcaptionframe)
  private
   fdragbuttons: shiftstatesty;
   procedure setsbhorz(const Value: tcustomscrollbar);
   procedure setsbvert(const Value: tcustomscrollbar);
   procedure setdragbuttons(const avalue: shiftstatesty);
  protected
   fhorz,fvert: tcustomscrollbar;
   foptionsscroll: optionsscrollty;
   procedure settemplateinfo(const ainfo: frameinfoty); override;
   procedure updatestate; override;
   procedure updatevisiblescrollbars; virtual;
   procedure updaterects; override;
   procedure getpaintframe(var frame: framety); override;
   procedure addscrollbarwidth(var asize: sizety) override;
   procedure subscrollbarwidth(var asize: sizety) override;
   function getscrollbarclass(vert: boolean): framescrollbarclassty; virtual;
   procedure activechanged; override;
   procedure updatemousestate(const sender: twidget;
                              const info: mouseeventinfoty); override;
   procedure internalpaintoverlay(const canvas: tcanvas;
                                         const arect: rectty) override;
 public
   constructor create(const aintf: iscrollframe; const scrollintf: iscrollbar);
   destructor destroy; override;
   procedure checktemplate(const sender: tobject); override;
                 //true if match
   procedure mouseevent(var info: mouseeventinfoty); virtual;
   procedure domousewheelevent(var info: mousewheeleventinfoty;
                                   const pagingreversed: boolean); virtual;
   property optionsscroll: optionsscrollty read foptionsscroll
                             write foptionsscroll default defaultoptionsscroll;
   property dragbuttons: shiftstatesty read fdragbuttons write setdragbuttons
                                       default defaultdragbuttons;
   property state: framestatesty read fstate;
   property sbhorz: tcustomscrollbar read fhorz write setsbhorz;
   property sbvert: tcustomscrollbar read fvert write setsbvert;
 end;

 tscrollframe = class(tcustomscrollframe)
  private
   procedure setsbhorz(const avalue: tscrollbar);
   function getsbhorz: tscrollbar;
   procedure setsbvert(const avalue: tscrollbar);
   function getsbvert: tscrollbar;
  protected
   function getscrollbarclass(vert: boolean): framescrollbarclassty; override;
  published
   property options;
   property levelo;
   property leveli;
   property framewidth;
   property colordkshadow;
   property colorshadow;
   property colorlight;
   property colorhighlight;
   property colorhlwidth;
   property hiddenedges;
   property colorframe;
   property colorframeactive;
   property colorframedisabled;
   property colorframemouse;
   property colorframeclicked;
   property colorframedefault;
   property framei_left;
   property framei_top;
   property framei_right;
   property framei_bottom;
   property frameo_left;
   property frameo_top;
   property frameo_right;
   property frameo_bottom;

   property frameimage_list;
   property frameimage_left;
   property frameimage_top;
   property frameimage_right;
   property frameimage_bottom;
   property frameimage_offset;
   property frameimage_offset1;
   property frameimage_offsetdisabled;
   property frameimage_offsetmouse;
   property frameimage_offsetclicked;
   property frameimage_offsetactive;
   property frameimage_offsetfocused;
{
   property frameimage_offsetactivemouse;
   property frameimage_offsetactiveclicked;
}
   property frameface_list;
   property frameface_offset;
   property frameface_offset1;
   property frameface_offsetdisabled;
   property frameface_offsetmouse;
   property frameface_offsetclicked;
   property frameface_offsetactive;
   property frameface_offsetfocused;
{
   property frameface_offsetactivemouse;
   property frameface_offsetactiveclicked;
}
   property optionsskin;

   property sbhorz: tscrollbar read getsbhorz write setsbhorz;
   property sbvert: tscrollbar read getsbvert write setsbvert;
   property colorclient;
   property caption;
   property captiontextflags;
   property captionpos;
   property captiondist;
   property captionoffset;
   property focusrectdist;
   property extraspace;
   property imagedist;
   property imagedist1;
   property imagedist2;
   property font;
   property localprops; //before template
   property localprops1; //before template
   property template;
 end;

 tcustomthumbtrackscrollframe = class(tcustomscrollframe)
  protected
   function getscrollbarclass(vert: boolean): framescrollbarclassty; override;
 end;

 iscrollbox = interface(iscrollbar)
  function getscrollsize: sizety;
 end;

type
 tcustomscrollboxframe = class(tcustomscrollframe,iscrollbox)
  private
   fscrolling: integer;
   fclientsize: sizety;
   fclientsizemin: sizety;
   fdragging: boolean;
   fpickpos: pointty;
   fpickref: pointty;
   fzoom: complexty;
   fzoomwidthstep: real;
   fzoomheightstep: real;
   fzoomwheelsensitivity: real;
   procedure clientrecttoscrollbar(const rect: rectty);
   procedure setclientsize(const avalue: sizety);
   procedure setclientheight(const avalue: integer);
   procedure setclientwidth(const avalue: integer);
   procedure setclientsizemin(const avalue: sizety);
   procedure setclientheightmin(const avalue: integer);
   procedure setclientwidthmin(const avalue: integer);
   procedure calcclientrect(var aclientrect: rectty);
   function getwidget: twidget;
   procedure setsbhorz(const avalue: tscrollboxscrollbar);
   function getsbhorz: tscrollboxscrollbar;
   procedure setsbvert(const avalue: tscrollboxscrollbar);
   function getsbvert: tscrollboxscrollbar;
   procedure setzoom1(const avalue: complexty);
   procedure setzoom(const avalue: complexty);
   procedure setzoomwidth(const avalue: real);
   procedure setzoomheight(const avalue: real);
   function getscrollpos_x: integer;
   procedure setscrollpos_x(const avalue: integer);
   function getscrollpos_y: integer;
   procedure setscrollpos_y(const avalue: integer);
   procedure readzoomwidthstep(reader: treader);
   procedure writezoomwidthstep(writer: twriter);
   procedure readzoomheightstep(reader: treader);
   procedure writezoomheightstep(writer: twriter);
   procedure readzoomwheelsensitivity(reader: treader);
   procedure writezoomwheelsensitivity(writer: twriter);
  protected
   fowner: twidget;
   procedure scrollpostoclientpos(var aclientrect: rectty); virtual;
   procedure checkminscrollsize(var asize: sizety); override;
   procedure checkminclientsize(var asize: sizety); override;
   function isdragstart(const sender: twidget;
                                  const info: mouseeventinfoty): boolean;
   procedure initinnerframe; virtual;
   function getscrollbarclass(vert: boolean): framescrollbarclassty; override;
   procedure updatevisiblescrollbars; override;
   procedure scrollevent(sender: tcustomscrollbar; event: scrolleventty); virtual;
   procedure dokeydown(var info: keyeventinfoty); override;
   function getclientpos: pointty;
   procedure setclientpos(apos: pointty);
   procedure setscrollpos(apos: pointty);
   procedure updatemousestate(const sender: twidget;
                               const info: mouseeventinfoty); override;
   procedure defineproperties(filer: tfiler); override;
    //iscrollbar
   function translatecolor(const acolor: colorty): colorty;
   procedure invalidaterect(const rect: rectty; const org: originty;
                              const noclip: boolean = false);
    //iscrollbox
   function getscrollsize: sizety;
  public
   constructor create(const aintf: iscrollframe; const owner: twidget);
   procedure childmouseevent(const sender: twidget;
                                var info: mouseeventinfoty); virtual;
   procedure domousewheelevent(var info: mousewheeleventinfoty;
                                   const pagingreversed: boolean); override;
   procedure updateclientrect; override;
   procedure showrect(const arect: rectty; const bottomright: boolean);
                           //origin paintpos
   property scrollpos: pointty read getclientpos write setscrollpos;
   property scrollpos_x: integer read getscrollpos_x write setscrollpos_x;
   property scrollpos_y: integer read getscrollpos_y write setscrollpos_y;
               //origin = paintpos
   property zoom: complexty read fzoom write setzoom; //default 1,1
   property zoomwidth: real read fzoom.re write setzoomwidth;   //default 1
   property zoomheight: real read fzoom.im write setzoomheight; //default 1
   property zoomwidthstep: real read fzoomwidthstep
                      write fzoomwidthstep stored false;
                                 //default 1
   property zoomheightstep: real read fzoomheightstep
                      write fzoomheightstep stored false;
                                 //default 1
   property zoomwheelsensitivity: real read fzoomwheelsensitivity
                      write fzoomwheelsensitivity stored false;
                                 //default 0
   property clientsize: sizety read fclientsize write setclientsize;
   property clientwidth: integer read fclientsize.cx
                                     write setclientwidth default 0;
   property clientheight: integer read fclientsize.cy
                                     write setclientheight default 0;
   property clientsizemin: sizety read fclientsizemin write setclientsizemin;
   property clientwidthmin: integer read fclientsizemin.cx
                                     write setclientwidthmin default 0;
   property clientheightmin: integer read fclientsizemin.cy
                                     write setclientheightmin default 0;
   property framei_left default 2;
   property framei_top default 2;
   property framei_right default 2;
   property framei_bottom default 2;
   property sbhorz: tscrollboxscrollbar read getsbhorz write setsbhorz;
   property sbvert: tscrollboxscrollbar read getsbvert write setsbvert;
 end;

 tscrollboxframe = class(tcustomscrollboxframe)
  published
   property options;
   property optionsscroll;
   property dragbuttons;
   property clientwidth;
   property clientheight;
   property clientwidthmin;
   property clientheightmin;
   property zoomwidthstep;
   property zoomheightstep;
   property zoomwheelsensitivity;
   property levelo;
   property leveli;
   property framewidth;
   property colorframe;
   property colorframeactive;
   property colorframedisabled;
   property colorframemouse;
   property colorframeclicked;
   property colorframedefault;
   property colordkshadow;
   property colorshadow;
   property colorlight;
   property colorhighlight;
   property colordkwidth;
   property colorhlwidth;
   property hiddenedges;
   property colorclient;
   property framei_left;
   property framei_top;
   property framei_right;
   property framei_bottom;
   property frameo_left;
   property frameo_top;
   property frameo_right;
   property frameo_bottom;

   property frameimage_list;
   property frameimage_left;
   property frameimage_top;
   property frameimage_right;
   property frameimage_bottom;
   property frameimage_offset;
   property frameimage_offset1;
   property frameimage_offsetdisabled;
   property frameimage_offsetmouse;
   property frameimage_offsetclicked;
   property frameimage_offsetactive;
   property frameimage_offsetfocused;
{
   property frameimage_offsetactivemouse;
   property frameimage_offsetactiveclicked;
}
   property frameface_list;
   property frameface_offset;
   property frameface_offset1;
   property frameface_offsetdisabled;
   property frameface_offsetmouse;
   property frameface_offsetclicked;
   property frameface_offsetactive;
   property frameface_offsetfocused;
{
   property frameface_offsetactivemouse;
   property frameface_offsetactiveclicked;
}
   property optionsskin;

   property caption;
   property captiontextflags;
   property captionpos;
   property captiondist;
   property captionoffset;
   property focusrectdist;
   property extraspace;
   property imagedist;
   property imagedist1;
   property imagedist2;
   property font;
   property localprops; //before template
   property localprops1; //before template
   property template;
   property sbhorz;
   property sbvert;
 end;

 stepkindty = (sk_right,sk_up,sk_left,sk_down,sk_first,sk_last,sk_none);
 stepkindsty = set of stepkindty;
const
 allstepkinds = [sk_right,sk_up,sk_left,sk_down,sk_first,sk_last];
type
 istepbar = interface(inullinterface)
  function translatecolor(const aclor: colorty): colorty;
  procedure invalidaterect(const rect: rectty; const org: originty;
                               const noclip: boolean = false);
  function dostep(const event: stepkindty; const adelta: real;
                  ashiftstate: shiftstatesty): boolean;
                                                 //true on action
 end;
 stepbuttonposty = (sbp_right,sbp_top,sbp_left,sbp_bottom);

 framestepinfoty = record
  down,up,pagedown,pageup,pagelast: integer;
 end;

const
 defaultstepbuttonsize = 13;

type
 stepframestatety = (sfs_spinedit,sfs_canstep);
 stepframestatesty = set of stepframestatety;

 tcustomstepframe = class(tcustomcaptionframe,iframe)
  private
   fstepintf: istepbar;
   fbuttonsize: integer;
   fbuttons: shapeinfoarty;
   fcolorbutton: colorty;
   fbuttonpos: stepbuttonposty;
   fbuttonslast: boolean;
   fdisabledbuttons: stepkindsty;
   fneededbuttons: stepkindsty;
   fbuttonsinline: boolean;
   fmousewheel: boolean;
   frepeater: tsimpletimer;
   frepeatedbutton: integer;
   fbuttonface: tface;
   fbuttonframe: tframe;
   factbuttonindex: integer;
   fcolorglyph: colorty;
   procedure setbuttonsize(const Value: integer);
   procedure setbuttonpos(const Value: stepbuttonposty);
   procedure setbuttonsinline(const value: boolean);
   procedure setbuttonslast(const avalue: boolean);
   procedure setcolorbutton(const avalue: colorty);
   procedure setdisabledbuttons(const avalue: stepkindsty);
   procedure setbuttonsinvisible(const avalue: stepkindsty);
   procedure setbuttonsvisible(const avalue: stepkindsty);
   procedure setneededbuttons(const avalue: stepkindsty);
   function getbuttonface: tface;
   procedure setbuttonface(const avalue: tface);
   function getbuttonframe: tframe;
   procedure setbuttonframe(const avalue: tframe);
   procedure setcolorglyph(const avalue: colorty);
  protected
   fforceinvisiblebuttons: stepkindsty;
   fforcevisiblebuttons: stepkindsty;
   fstepstate: stepframestatesty;
   fdim: rectty;
   procedure dorepeat(const sender: tobject);
   procedure killrepeater;
   procedure layoutchanged;
   procedure updaterects; override;
   procedure getpaintframe(var frame: framety); override;
   procedure updatelayout;
   procedure execute(const tag: integer; const info: mouseeventinfoty);
   property neededbuttons: stepkindsty read fneededbuttons
                                                     write setneededbuttons;
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
   procedure invalidaterect(const rect: rectty;
               const org: originty = org_client; const noclip: boolean = false);
   function getwidget: twidget;
   function getframestateflags: framestateflagsty; virtual;
   procedure internalpaintoverlay(const canvas: tcanvas;
                                           const arect: rectty) override;
  public
   constructor create(const aintf: icaptionframe; const stepintf: istepbar);
   destructor destroy; override;
   procedure createbuttonface;
   procedure createbuttonframe;

   procedure updatemousestate(const sender: twidget;
                                   const info: mouseeventinfoty); override;
   procedure mouseevent(var info: mouseeventinfoty); virtual;
   procedure domousewheelevent(var info: mousewheeleventinfoty); virtual;
   procedure checktemplate(const sender: tobject); override;
   procedure updatebuttonstate(const first,delta,count: integer);
   function canstep: boolean;
   function executestepevent(const event: stepkindty;
             const stepinfo: framestepinfoty; const aindex: integer): integer;
   property buttonsize: integer read fbuttonsize write setbuttonsize
                                               default defaultstepbuttonsize;
   property colorbutton: colorty read fcolorbutton
                                      write setcolorbutton default cl_default;
                                       //cl_default maps to widget color
   property colorglyph: colorty read fcolorglyph
                                      write setcolorglyph default cl_default;
                                       //cl_default maps to widget color
   property buttonface: tface read getbuttonface write setbuttonface;
   property buttonframe: tframe read getbuttonframe write setbuttonframe;

   property disabledbuttons: stepkindsty read fdisabledbuttons
              write setdisabledbuttons default [];
   property buttonsinvisible: stepkindsty read fforceinvisiblebuttons
              write setbuttonsinvisible default [sk_first,sk_last];
   property buttonsvisible: stepkindsty read fforcevisiblebuttons
              write setbuttonsvisible default [];
   property buttonpos: stepbuttonposty read fbuttonpos
                                       write setbuttonpos default sbp_right;
   property buttonslast: boolean read fbuttonslast
                                          write setbuttonslast default false;
   property buttonsinline: boolean read fbuttonsinline
                                          write setbuttonsinline default false;
   property mousewheel: boolean read fmousewheel write fmousewheel default true;
 end;

 tstepframe = class(tcustomstepframe)
  published
   property options;
   property levelo;
   property leveli;
   property framewidth;
   property colorframe;
   property colorframeactive;
   property colorframedisabled;
   property colorframemouse;
   property colorframeclicked;
   property colorframedefault;
   property colordkshadow;
   property colorshadow;
   property colorlight;
   property colorhighlight;
   property colordkwidth;
   property colorhlwidth;
   property hiddenedges;
   property colorclient;
   property colorbutton;
   property colorglyph;
   property framei_left;
   property framei_top;
   property framei_right;
   property framei_bottom;
   property frameo_left;
   property frameo_top;
   property frameo_right;
   property frameo_bottom;

   property frameimage_list;
   property frameimage_left;
   property frameimage_top;
   property frameimage_right;
   property frameimage_bottom;
   property frameimage_offset;
   property frameimage_offset1;
   property frameimage_offsetdisabled;
   property frameimage_offsetmouse;
   property frameimage_offsetclicked;
   property frameimage_offsetactive;
   property frameimage_offsetfocused;
{
   property frameimage_offsetactivemouse;
   property frameimage_offsetactiveclicked;
}
   property frameface_list;
   property frameface_offset;
   property frameface_offset1;
   property frameface_offsetdisabled;
   property frameface_offsetmouse;
   property frameface_offsetclicked;
   property frameface_offsetactive;
   property frameface_offsetfocused;
{
   property frameface_offsetactivemouse;
   property frameface_offsetactiveclicked;
}
   property optionsskin;

   property caption;
   property captiontextflags;
   property captionpos;
   property captiondist;
   property captionoffset;
   property focusrectdist;
   property extraspace;
   property imagedist;
   property imagedist1;
   property imagedist2;
   property font;
   property localprops; //before template
   property localprops1; //before template
   property template;
   property disabledbuttons;
   property buttonface;
   property buttonframe;
   property buttonsvisible;
   property buttonsinvisible;
   property buttonsize;
   property buttonpos;
   property buttonslast;
   property buttonsinline;
   property mousewheel;
 end;

 queryeventty = procedure(const sender: tobject; var answer: boolean) of object;
 popupeventty = procedure(const sender: tobject; var amenu: tpopupmenu;
                     var mouseinfo: mouseeventinfoty) of object;

 tactionwidget = class(twidget)
  private
   fpopupmenu: tpopupmenu;
   fonpopup: popupeventty;
   fonshowhint: showhinteventty;
   fonenter: notifyeventty;
   fonexit: notifyeventty;
   fonfocus: notifyeventty;
   fondefocus: notifyeventty;
   fonactivate: notifyeventty;
   fondeactivate: notifyeventty;

   fonloaded: notifyeventty;
   fonmouseevent: mouseeventty;
   fonmousewheelevent: mousewheeleventty;
   fonchildmouseevent: mouseeventty;
   fonclientmouseevent: mouseeventty;
   fonkeyup: keyeventty;
   fonkeydown: keyeventty;
   fonshortcut: shortcuteventty;
   fonpaint: painteventty;
   fonbeforepaint: painteventty;
   fonafterpaint: painteventty;
   fonmove: notifyeventty;
   fonresize: notifyeventty;
   fonhide: notifyeventty;
   fonshow: notifyeventty;
   fonclosequery: queryeventty;
   fonevent: eventeventty;
   fonasyncevent: asynceventeventty;
   fonfocusedwidgetchanged: widgetchangeeventty;
   fonpaintbackground: painteventty;

   foncomponentevent: componenteventeventty;
   procedure setpopupmenu(const Value: tpopupmenu);
   function getframe: tcaptionframe;
   procedure setframe(const value: tcaptionframe);
   function getface: tface;
   procedure setface(const Value: tface);
  protected
   procedure mouseevent(var info: mouseeventinfoty); override;
   procedure clientmouseevent(var info: mouseeventinfoty); override;
   procedure childmouseevent(const sender: twidget;
                                      var info: mouseeventinfoty); override;
   procedure domousewheelevent(var info: mousewheeleventinfoty); override;

   procedure dobeforepaint(const canvas: tcanvas); override;
   procedure doonpaintbackground(const canvas: tcanvas); override;
   procedure doonpaint(const canvas: tcanvas); override;
   procedure doafterpaint(const canvas: tcanvas); override;

   procedure showhint(const aid: int32; var info: hintinfoty); override;
   procedure getpopuppos(var apos: pointty); virtual;
   procedure updatepopupmenu(var amenu: tpopupmenu;
                                   var mouseinfo: mouseeventinfoty); virtual;
   procedure dopopup(var amenu: tpopupmenu;
                                   var mouseinfo: mouseeventinfoty); virtual;
   procedure doafterpopupmenu(var amenu: tpopupmenu;
                                   var mouseinfo: mouseeventinfoty); virtual;

   procedure poschanged; override;
   procedure sizechanged; override;

   procedure doloaded; override;
   procedure doenter; override;
   procedure doexit; override;
   procedure dofocus; override;
   procedure dodefocus; override;
   procedure dofocuschanged(const oldwidget: twidget;
                                     const newwidget: twidget); override;
   procedure doactivate; override;
   procedure dodeactivate; override;
   procedure dohide; override;
   procedure doshow; override;

   procedure doonkeydown(var info: keyeventinfoty);
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure dokeyup(var info: keyeventinfoty); override;
   procedure doshortcut(var info: keyeventinfoty; const sender: twidget); override;
   procedure receiveevent(const event: tobjectevent); override;
   procedure componentevent(const event: tcomponentevent) override;
   procedure doasyncevent(var atag: integer); override;

   procedure internalcreateframe; override;
   procedure enabledchanged; override;

   property frame: tcaptionframe read getframe write setframe;
   property face: tface read getface write setface;
   property popupmenu: tpopupmenu read fpopupmenu write setpopupmenu;
   property onpopup: popupeventty read fonpopup write fonpopup;
   property onshowhint: showhinteventty read fonshowhint write fonshowhint;
   property onenter: notifyeventty read fonenter write fonenter;
   property onexit: notifyeventty read fonexit write fonexit;
   property onfocus: notifyeventty read fonfocus write fonfocus;
   property ondefocus: notifyeventty read fondefocus write fondefocus;
   property onactivate: notifyeventty read fonactivate write fonactivate;
   property ondeactivate: notifyeventty read fondeactivate write fondeactivate;

   property onfocusedwidgetchanged: widgetchangeeventty
                     read fonfocusedwidgetchanged write fonfocusedwidgetchanged;

   property onmouseevent: mouseeventty read fonmouseevent write fonmouseevent;
   property onchildmouseevent: mouseeventty read fonchildmouseevent
                        write fonchildmouseevent;
   property onclientmouseevent: mouseeventty read fonclientmouseevent
                                             write fonclientmouseevent;
   property onmousewheelevent: mousewheeleventty read fonmousewheelevent
                                             write fonmousewheelevent;

   property onkeydown: keyeventty read fonkeydown write fonkeydown;
   property onkeyup: keyeventty read fonkeyup write fonkeyup;
   property onshortcut: shortcuteventty read fonshortcut write fonshortcut;

   property onloaded: notifyeventty read fonloaded write fonloaded;

   property onbeforepaint: painteventty read fonbeforepaint
                                                      write fonbeforepaint;
   property onpaintbackground: painteventty read fonpaintbackground
                                                      write fonpaintbackground;
   property onpaint: painteventty read fonpaint write fonpaint;
   property onafterpaint: painteventty read fonafterpaint write fonafterpaint;

   property onshow: notifyeventty read fonshow write fonshow;
   property onhide: notifyeventty read fonhide write fonhide;
   property onresize: notifyeventty read fonresize write fonresize;
   property onmove: notifyeventty read fonmove write fonmove;
   property onclosequery: queryeventty read fonclosequery write fonclosequery;

   property onevent: eventeventty read fonevent write fonevent;
   property oncomponentevent: componenteventeventty read foncomponentevent
                                                  write foncomponentevent;
   property onasyncevent: asynceventeventty read fonasyncevent write fonasyncevent;
  public
   function canclose(const newfocus: twidget = nil): boolean; override;
 end;

 tactionpublishedwidgetnwr = class(tactionwidget)
  published
   property optionswidget1; //first!
   property optionswidget;
   property optionsskin;
   property color;
   property cursor;
   property frame;
   property face;
   property taborder;
   property hint;
   property popupmenu;
   property onpopup;
   property onshowhint;
   property onmouseevent;  
   property onenter;
   property onexit;
   property onfocus;
   property ondefocus;
   property onactivate;
   property ondeactivate;
   property onbeforepaint;
   property onpaintbackground;
   property onpaint;
   property onafterpaint;
 end;

 tactionpublishedwidget = class(tactionpublishedwidgetnwr)
  published
   property bounds_x;
   property bounds_y;
   property bounds_cx;
   property bounds_cy;
   property bounds_cxmin;
   property bounds_cymin;
   property bounds_cxmax;
   property bounds_cymax;
   property anchors;
 end;

 tpublishedwidgetnwr = class(tactionpublishedwidgetnwr)
  published
   property enabled;
   property visible;
 end;

 tpublishedwidget = class(tpublishedwidgetnwr)
  published
   property bounds_x;
   property bounds_y;
   property bounds_cx;
   property bounds_cy;
   property bounds_cxmin;
   property bounds_cymin;
   property bounds_cxmax;
   property bounds_cymax;
   property anchors;
 end;

 tsimplewidget = class(tpublishedwidget)
  public
   constructor create(aowner: tcomponent); override;
  published
   property visible default false;
 end;

 tcustomeventwidgetnwr = class(tpublishedwidgetnwr)
 (*
  private
   fonloaded: notifyeventty;
   fonmouseevent: mouseeventty;
   fonmousewheelevent: mousewheeleventty;
   fonchildmouseevent: mouseeventty;
   fonclientmouseevent: mouseeventty;
   fonkeyup: keyeventty;
   fonkeydown: keyeventty;
   fonshortcut: keyeventty;
   fonpaint: painteventty;
   fonbeforepaint: painteventty;
   fonafterpaint: painteventty;
   fonmove: notifyeventty;
   fonresize: notifyeventty;
   fonhide: notifyeventty;
   fonshow: notifyeventty;
   fonclosequery: queryeventty;
   fonevent: eventeventty;
   fonasyncevent: asynceventeventty;
   fonfocusedwidgetchanged: focuschangeeventty;
   fonpaintbackground: painteventty;
  protected
   procedure poschanged; override;
   procedure sizechanged; override;
   procedure dobeforepaint(const canvas: tcanvas); override;
   procedure dopaintbackground(const canvas: tcanvas); override;
   procedure doonpaint(const canvas: tcanvas); override;
   procedure doafterpaint(const canvas: tcanvas); override;
   procedure mouseevent(var info: mouseeventinfoty); override;
   procedure clientmouseevent(var info: mouseeventinfoty); override;
   procedure childmouseevent(const sender: twidget; var info: mouseeventinfoty); override;
   procedure domousewheelevent(var info: mousewheeleventinfoty); override;
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure dokeyup(var info: keyeventinfoty); override;
   procedure doshortcut(var info: keyeventinfoty; const sender: twidget); override;
   procedure dofocuschanged(const oldwidget,newwidget: twidget); override;
   procedure doloaded; override;
   procedure dohide; override;
   procedure doshow; override;
   procedure receiveevent(const event: tobjectevent); override;
   procedure doasyncevent(var atag: integer); override;
  public
   function canclose(const newfocus: twidget): boolean; override;
   property onfocusedwidgetchanged: focuschangeeventty
                     read fonfocusedwidgetchanged write fonfocusedwidgetchanged;

   property onmouseevent: mouseeventty read fonmouseevent write fonmouseevent;
   property onchildmouseevent: mouseeventty read fonchildmouseevent
                        write fonchildmouseevent;
   property onclientmouseevent: mouseeventty read fonclientmouseevent
                                             write fonclientmouseevent;
   property onmousewheelevent: mousewheeleventty read fonmousewheelevent
                                             write fonmousewheelevent;

   property onkeydown: keyeventty read fonkeydown write fonkeydown;
   property onkeyup: keyeventty read fonkeyup write fonkeyup;
   property onshortcut: keyeventty read fonshortcut write fonshortcut;

   property onloaded: notifyeventty read fonloaded write fonloaded;

   property onbeforepaint: painteventty read fonbeforepaint write fonbeforepaint;
   property onpaintbackground: painteventty read fonpaintbackground write fonpaintbackground;
   property onpaint: painteventty read fonpaint write fonpaint;
   property onafterpaint: painteventty read fonafterpaint write fonafterpaint;

   property onshow: notifyeventty read fonshow write fonshow;
   property onhide: notifyeventty read fonhide write fonhide;
//   property onactivate: notifyeventty read fonactivate write fonactivate;
//   property ondeactivate: notifyeventty read fondeactivate write fondeactivate;
   property onresize: notifyeventty read fonresize write fonresize;
   property onmove: notifyeventty read fonmove write fonmove;
   property onclosequery: queryeventty read fonclosequery write fonclosequery;

   property onevent: eventeventty read fonevent write fonevent;
   property onasyncevent: asynceventeventty read fonasyncevent write fonasyncevent;
*)
 end;

 tcustomeventwidget = class(tcustomeventwidgetnwr)
  published
   property bounds_x;
   property bounds_y;
   property bounds_cx;
   property bounds_cy;
   property bounds_cxmin;
   property bounds_cymin;
   property bounds_cxmax;
   property bounds_cymax;
   property anchors;
 end;

 const
  defaultoptionstoplevelwidget = defaultoptionswidget + [ow_subfocus];

type

 ttoplevelwidget = class(tcustomeventwidget)
  public
   constructor create(aowner: tcomponent); override;
   property visible default false;
  published
   property optionswidget default defaultoptionstoplevelwidget;
   property optionsskin default defaultcontainerskinoptions;
 end;

 tcaptionwidget = class(ttoplevelwidget)
  private
   fcaption: msestring;
  protected
   function getcaption: msestring; virtual;
   procedure setcaption(const Value: msestring); virtual;
   procedure windowcreated; override;
    //iassistiveclient
   function getassistivecaption(): msestring; override;
  public
   property caption: msestring read getcaption write setcaption;
 end;

 tscrollbarwidget = class(tcustomeventwidget,iscrollbar)
  private
   function getframe: tscrollframe;
   procedure setframe(const Value: tscrollframe);
  protected
   procedure internalcreateframe; override;
   procedure mouseevent(var info: mouseeventinfoty); override;
   procedure scrollevent(sender: tcustomscrollbar; event: scrolleventty); virtual;
  public
   constructor create(aowner: tcomponent); override;
  published
   property frame: tscrollframe read getframe write setframe;
 end;

 iautoscrollframe = interface(inullinterface)
  function getscrollrect: rectty;
  procedure setscrollrect(const rect: rectty);
  procedure scrollevent(sender: tcustomscrollbar; event: scrolleventty);
 end;

 tcustomautoscrollframe = class(tcustomscrollboxframe)
  private
   function getscrollpos: pointty;
   procedure setscrollpos(const avalue: pointty);
   function getscrollpos_x: integer;
   procedure setscrollpos_x(const avalue: integer);
   function getscrollpos_y: integer;
   procedure setscrollpos_y(const avalue: integer);
  protected
   fintf1: iautoscrollframe;
   procedure scrollevent(sender: tcustomscrollbar; event: scrolleventty); override;
   procedure updaterects; override;
  public
   constructor create(const aintf: iscrollframe; const owner: twidget;
                 const autoscrollintf: iautoscrollframe);
   procedure updateclientrect; override;
   property scrollpos: pointty read getscrollpos write setscrollpos;
   property scrollpos_x: integer read getscrollpos_x write setscrollpos_x;
   property scrollpos_y: integer read getscrollpos_y write setscrollpos_y;
               //origin = paintpos
 end;

 fontheightdeltaeventty = procedure (const sender: tobject;
                     var delta: integer) of object;

 tscrollface = class(tface)
   procedure internalpaint(const canvas: tcanvas; const rect: rectty); override;
  public
 end;

 tscrollingwidgetnwr = class;
 calcminscrollsizeeventty = procedure(const sender: tscrollingwidgetnwr;
                                  var asize: sizety) of object;

 tscrollingwidgetnwr = class(tcustomeventwidgetnwr)
  private
   fonscroll: pointeventty;
   fonfontheightdelta: fontheightdeltaeventty;
   fonlayout: notifyeventty;
   foncalcminscrollsize: calcminscrollsizeeventty;
   fminclientsize: sizety;
   fonscrolled: pointeventty;
   function getframe: tscrollboxframe;
   procedure setframe(const Value: tscrollboxframe);
//   procedure setclientpos(const avalue: pointty);
   procedure readonchildscaled(reader: treader);
  protected
   fminminclientsize: sizety; //exteded in design mode
   procedure widgetregionchanged(const sender: twidget); override;
   procedure sizechanged; override;
   procedure minscrollsizechanged;
   procedure dofontheightdelta(var delta: integer); override;
   procedure internalcreateframe; override;
   procedure doscroll(const dist: pointty); override;
   procedure doscrolled(const dist: pointty); override;
   procedure mouseevent(var info: mouseeventinfoty); override;
   procedure childmouseevent(const sender: twidget;
                              var info: mouseeventinfoty); override;
   procedure domousewheelevent(var info: mousewheeleventinfoty); override;
   procedure internalcreateface; override;
   function calcminscrollsize: sizety; override;
   procedure setclientsize(const asize: sizety); override;
   procedure loaded; override;
                //origin paintpos
   procedure defineproperties(filer: tfiler); override;
 public
   constructor create(aowner: tcomponent); override;
   procedure clampinview(const arect: rectty;
                                  const bottomright: boolean = false); override;
   function maxclientsize: sizety; override;
   procedure writestate(writer: twriter); override;
   procedure dolayout(const sender: twidget); override;
   property onscroll: pointeventty read fonscroll write fonscroll;
   property onscrolled: pointeventty read fonscrolled write fonscrolled;
   property onfontheightdelta: fontheightdeltaeventty read fonfontheightdelta
                     write fonfontheightdelta;
   property onlayout: notifyeventty read fonlayout write fonlayout;
   property oncalcminscrollsize: calcminscrollsizeeventty
                   read foncalcminscrollsize write foncalcminscrollsize;
//   property scrollpos: pointty read getclientpos write setclientpos;
  published
   property frame: tscrollboxframe read getframe write setframe;
   property optionswidget default defaultoptionswidgetmousewheel;
   property optionsskin default defaultcontainerskinoptions;
 end;

 tscrollingwidget = class(tscrollingwidgetnwr)
  published
   property bounds_x;
   property bounds_y;
   property bounds_cx;
   property bounds_cy;
   property bounds_cxmin;
   property bounds_cymin;
   property bounds_cxmax;
   property bounds_cymax;
   property anchors;
 end;

 tpopupwidget = class(ttoplevelwidget)
  private
   ftransientfor: twindow;
  protected
   function getassistiveflags(): assistiveflagsty override;
   procedure updatewindowinfo(var info: windowinfoty); override;
   function internalshow(const modallevel: modallevelty;
           const transientfor: pwindow;
           const windowevent,transientforshow: boolean): modalresultty; override;
  public
   constructor create(aowner: tcomponent;
                             transientfor: twindow); reintroduce; overload;
   property transientfor: twindow read ftransientfor;
 end;

 const
  defaultoptionshintwidget = defaultoptionstoplevelwidget + [ow_top];

type
 tcustomhintwidget = class(tpopupwidget)
  public
   constructor create(const aowner: tcomponent; const atransientfor: twindow;
             var info: hintinfoty; const sender: tobject); virtual; reintroduce;
  published
   property optionswidget default defaultoptionshintwidget;
 end;
 hintwidgetclassty = class of tcustomhintwidget;

 thintwidget = class(tcustomhintwidget)
  private
   fcaption: captionty;
  protected
   procedure dopaintforeground(const canvas: tcanvas); override;
  public
   constructor create(const aowner: tcomponent; const atransientfor: twindow;
                     var info: hintinfoty; const sender: tobject); override;
 end;

 tmessagewidget = class(tcaptionwidget)
  private
   fpopuptransient: boolean;
   fhasaction: boolean;
  protected
   procedure updatewindowinfo(var info: windowinfoty); override;
   procedure dokeydown(var info: keyeventinfoty); override;
   function getcaption: msestring; override;
   procedure setcaption(const Value: msestring); override;
   procedure internalcreateframe; override;
  public
   constructor create(const aowner: tcomponent; const apopuptransient: boolean;
                        const ahasaction: boolean);
                               reintroduce;
   function canclose(const newfocus: twidget): boolean; override;
 end;

type
 tactionsimplebutton = class(tactionpublishedwidget)
  private
   procedure setcolorglyph(const value: colorty);
  protected
   foptions: buttonoptionsty;
   finfo: shapeinfoty;
   class function classskininfo: skininfoty; override;
   procedure setoptions(const avalue: buttonoptionsty); virtual;
   procedure internalexecute();
   procedure doshapeexecute(const atag: integer; const info: mouseeventinfoty);
   procedure doexecute; virtual;
   procedure doasyncevent(var atag: integer); override;
   procedure statechanged; override;
   procedure clientmouseevent(var info: mouseeventinfoty); override;
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure dokeyup(var info: keyeventinfoty); override;
   procedure dopaintforeground(const canvas: tcanvas); override;
   procedure clientrectchanged; override;
   function getframestateflags: framestateflagsty; override;
   function navigstartrect: rectty; override;
   function getassistiveflags(): assistiveflagsty override;
   function getdisabled(): boolean virtual;
  public
   constructor create(aowner: tcomponent); override;
   procedure execute;
   procedure pressbutton;
   function releasebutton(const aexecute: boolean): boolean;
              //true if clicked
   property options: buttonoptionsty read foptions write setoptions
                 default defaultbuttonoptions;
   property colorglyph: colorty read finfo.ca.colorglyph write setcolorglyph
                    default cl_black;
   property focusrectdist: integer read finfo.focusrectdist
                write finfo.focusrectdist default defaultshapefocusrectdist;
  published
   property optionswidget default defaultoptionswidget - [ow_mousefocus];
 end;

 tsimplebutton = class(tactionsimplebutton)
//  published
//   property enabled;
//   property visible;
 end;

type
 messagepositionty = (mepo_default,mepo_screencentered,mepo_windowcentered);

function readcaptiontoimagepos(const reader: treader): imageposty;

procedure synccaptiondistx(const awidgets: array of twidget);
                //adjusts captiondist for equal distouter
                //don't set cfo_captiondistouter!
procedure synccaptiondisty(const awidgets: array of twidget);
                //adjusts captiondist for equal distouter
                //don't set cfo_captiondistouter!

function getmaxdropdownheight(const parent: twidget): integer;
procedure getdropdownpos(const parent: twidget; const right: boolean;
                                            var rect: rectty);


//following routines are thread safe and run in main thread context
//exttext will be appended for copy to clipboard
function showmessage(const atext,caption: msestring;
                     const buttons: array of modalresultty;
                     const defaultbutton: modalresultty = mr_cancel;
                     const noshortcut: modalresultsty = [];
                     const minwidth: integer = 0;
                     const exttext: msestring = '';
                     const position: messagepositionty = mepo_default): modalresultty; overload;
function showmessage(const atext,caption: msestring;
                     const buttons: array of modalresultty;
                     const defaultbutton: modalresultty;
                     const noshortcut: modalresultsty;
                     const minwidth: integer;
                     const actions: array of notifyeventty;
                     const exttext: msestring = '';
                     const position: messagepositionty = mepo_default): modalresultty; overload;
function showmessage(const atext,caption: msestring;
                     const buttons: array of modalresultty;
                     const adest: rectty; const awidget: twidget = nil;
                     //origin = awidget.clientpos, screen if awidget = nil
                     const placement: captionposty = cp_bottomleft;
                     const defaultbutton: modalresultty = mr_cancel;
                     const noshortcut: modalresultsty = [];
                     const minwidth: integer = 0;
                     const exttext: msestring = ''): modalresultty; overload;
function showmessage(const atext: msestring; const caption: msestring = '';
                     const minwidth: integer = 0;
                     const exttext: msestring = ''): modalresultty; overload;
procedure showmessage1(const atext: msestring; const caption: msestring);
            //for ps
procedure showerror(const atext: msestring; caption: msestring = 'ERROR';
                     const minwidth: integer = 0;
                     const exttext: msestring = '';
                     const async: boolean = false);
             //no wait if not in main thread or asnyc = true
function askok(const atext: msestring; const caption: msestring = '';
                     const defaultbutton: modalresultty = mr_ok;
                     const minwidth: integer = 0): boolean;
                             //true if ok pressed
function askyesno(const atext: msestring; const caption: msestring = '';
                     const defaultbutton: modalresultty = mr_yes;
                     const minwidth: integer = 0): boolean;
                            //true if yes pressed
function askconfirmation(const atext: msestring;
                     const defaultbutton: modalresultty = mr_yes;
                     const minwidth: integer = 0): boolean;
                            //true if yes pressed
function askconfirmationcancel(const atext: msestring;
                     const defaultbutton: modalresultty = mr_yes;
                     const minwidth: integer = 0): modalresultty;
function askyesnocancel(const atext: msestring; const caption: msestring = '';
                     const defaultbutton: modalresultty = mr_yes;
                     const minwidth: integer = 0): modalresultty;
function confirmsavechangedfile(const filename: filenamety;
               out modalresult: modalresultty; multiple: boolean = false): boolean;
function showsyserrormessage(const error: syserrorty;
                            const text: msestring = ''): boolean;
                               //returns true for sye_ok
function showsyserrormessage(const error: syserrorty;
                  const sender: tobject; const text: msestring = ''): boolean;
                               //returns true for sye_ok

//end threadsave routines

procedure copytoclipboard(const value: msestring;
                            const buffer: clipboardbufferty = cbb_clipboard);
function canpastefromclipboard(
                   const buffer: clipboardbufferty = cbb_clipboard): boolean;
function pastefromclipboard(out value: msestring;
                   const buffer: clipboardbufferty = cbb_clipboard): boolean;
            //false if empty
function placepopuprect(const awindow: twindow; const adest: rectty; //screenorig
                 const placement: captionposty; const asize: sizety): rectty;
 //placement currently only cp_bottomleft and cp_center
 //todo
function placepopuprect(const awidget: twidget;
           const adest: rectty; //widgetorig
         const placement: captionposty; const asize: sizety): rectty;
function placeclientpopuprect(const awidget: twidget;
           const adest: rectty; //clientorig
         const placement: captionposty; const asize: sizety): rectty;
procedure getwindowicon(const abitmap: tmaskedbitmap; out aicon,amask: pixmapty;
                        const anodefault: boolean = false);

procedure buttonoptionstoshapestate(avalue: buttonoptionsty;
                                              var astate: shapestatesty);

var
messagefontheight : integer = 12;
messagefontname : msestring = 'stf_default';

implementation
uses
 msebits,mseguiintf,
 msestockobjects,
 msekeyboard,sysutils,msemenuwidgets,
 mseactions,msepointer,msestreaming,msesys,msearrayutils,mseassistiveserver;
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}

const
 captionmargin = 1; //distance focusrect to caption in tcaptionframe

type
 twidget1 = class(twidget);
 twindow1 = class(twindow);
 tcustomscrollbar1 = class(tcustomscrollbar);
 tbitmap1 = class(tbitmap);
 tcustomframe1 = class(tcustomframe);

 tmessagebutton = class(tsimplebutton)
  private
   fcaption: msestring;
   procedure setcaption(const avalue: msestring);
  protected
   modalresult: modalresultty;
   procedure doexecute; override;
   procedure doshortcut(var info: keyeventinfoty;
                                   const sender: twidget); override;
   function getassistivecaption(): msestring override;
  public
   onexecute: notifyeventty;
   property caption: msestring read fcaption write setcaption;
 end;

 showmessageinfoty = record
  atext,caption: msestring;
  buttons: array of modalresultty;
  defaultbutton: modalresultty;
  noshortcut: modalresultsty;
  placementrect: prectty; placement: captionposty;
  minwidth: integer; actions: array of notifyeventty;
  exttext: msestring;
  async: boolean;
  result: modalresultty;
 end;
 pshowmessageinfoty = ^showmessageinfoty;

 tshowmessagewidget = class(tmessagewidget)
  protected
   info: drawtextinfoty;
   fexttext: msestring;
   finfo: pshowmessageinfoty;
   procedure dopaintforeground(const canvas: tcanvas); override;
   procedure dokeydown(var ainfo: keyeventinfoty); override;
   procedure doidle(var again: boolean);
    //iassistiveclient
   function getassistivetext(): msestring override;
   function getassistiveflags(): assistiveflagsty override;
  public
   constructor create(const aowner: tcomponent; const apopuptransient: boolean;
                        const ahasaction: boolean; const exttext: msestring;
                        const ainfo: pshowmessageinfoty);
   destructor destroy(); override;
 end;

procedure buttonoptionstoshapestate(avalue: buttonoptionsty;
                                              var astate: shapestatesty);
begin
 if bo_ellipsemouse in avalue then begin
  include(astate,shs_ellipsemouse);
 end
 else begin
  exclude(astate,shs_ellipsemouse);
 end;
 if bo_coloractive in avalue then begin
  include(astate,shs_focuscolor);
 end
 else begin
  exclude(astate,shs_focuscolor);
 end;
end;

function readcaptiontoimagepos(const reader: treader): imageposty;
begin
 result:= captiontoimagepos[captionposty(
                              readenum(reader,typeinfo(captionposty)))];
end;

procedure synccaptiondistx(const awidgets: array of twidget);
                //adjusts captiondist for equal distouter to paintrect
                //don't set cfo_captiondistouter
var
 int1,int2,int3,int4: integer;
begin
 int2:= bigint;
 int3:= 0;
 for int1:= 0 to high(awidgets) do begin
  with twidget1(awidgets[int1]) do begin
   if (fframe <> nil) and
              (fs_cancaptionsyncx in tcustomframe1(fframe).fstate) then begin
    with tcustomcaptionframe(fframe) do begin
     checkstate();
     if fcaptiondist < int2 then begin
      int2:= fcaptiondist;
     end;
     int4:= finfo.dest.cx;
     if fcaptionpos in rightcaptionpos then begin
      int4:= int4 + fwidth.right;
     end
     else begin
      int4:= int4 + fwidth.left;
     end;
     if int4 > int3 then begin
      int3:= int4;
     end;
    end;
   end;
  end;
 end;
 int3:= int3 + int2; //max outer dist
 for int1:= 0 to high(awidgets) do begin
  with twidget1(awidgets[int1]) do begin
   if (fframe <> nil) and
              (fs_cancaptionsyncx in tcustomframe1(fframe).fstate) then begin
    with tcustomcaptionframe(fframe) do begin
     if fcaptionpos in rightcaptionpos then begin
      captiondist:= int3 - finfo.dest.cx - fwidth.right;
     end
     else begin
      captiondist:= int3 - finfo.dest.cx - fwidth.left;
     end;
    end;
   end;
  end;
 end;
end;

procedure synccaptiondisty(const awidgets: array of twidget);
                //adjusts captiondist for equal distouter
                //don't set cfo_captiondistouter
var
 int1,int2,int3,int4: integer;
begin
 int2:= bigint;
 int3:= 0;
 for int1:= 0 to high(awidgets) do begin
  with twidget1(awidgets[int1]) do begin
   if (fframe <> nil) and
              (fs_cancaptionsyncy in tcustomframe1(fframe).fstate) then begin
    with tcustomcaptionframe(fframe) do begin
     checkstate();
     if fcaptiondist < int2 then begin
      int2:= fcaptiondist;
     end;
     int4:= finfo.dest.cy;
     if fcaptionpos in bottomcaptionpos then begin
      int4:= int4 + fwidth.bottom;
     end
     else begin
      int4:= int4 + fwidth.top;
     end;
     if  int4 > int3 then begin
      int3:= int4;
     end;
    end;
   end;
  end;
 end;
 int3:= int3 + int2; //max outer dist
 for int1:= 0 to high(awidgets) do begin
  with twidget1(awidgets[int1]) do begin
   if (fframe <> nil) and
            (fs_cancaptionsyncy in tcustomframe1(fframe).fstate) then begin
    with tcustomcaptionframe(fframe) do begin
     if fcaptionpos in bottomcaptionpos then begin
      captiondist:= int3 - finfo.dest.cy - fwidth.bottom;
     end
     else begin
      captiondist:= int3 - finfo.dest.cy - fwidth.top;
     end;
    end;
   end;
  end;
 end;
end;

procedure copytoclipboard(const value: msestring;
          const buffer: clipboardbufferty = cbb_clipboard);
begin
{$ifdef usesdl}
gui_copytoclipboard(value);
{$else}
gui_copytoclipboard(value,buffer);
{$endif}
end;

function canpastefromclipboard(
             const buffer: clipboardbufferty = cbb_clipboard): boolean;
begin
{$ifdef usesdl}
 result:= gui_canpastefromclipboard();
{$else}
 result:= gui_canpastefromclipboard(buffer);
{$endif}
end;

function pastefromclipboard(out value: msestring;
          const buffer: clipboardbufferty = cbb_clipboard): boolean;
begin
{$ifdef usesdl}
 result:= gui_pastefromclipboard(value) = gue_ok;
{$else}
 result:= gui_pastefromclipboard(value,buffer) = gue_ok;
{$endif} 
 
end;

function confirmsavechangedfile(const filename: filenamety;
         out modalresult: modalresultty; multiple: boolean = false): boolean;
begin

  if multiple then begin
  modalresult:= showmessage(sc(sc_file) +' '+filename+' '+
                  sc(sc_is_modified_save),sc(sc_confirmation),
                   [mr_yes,mr_all,mr_no,mr_noall,mr_cancel],mr_yes);
  end
  else begin
   modalresult:= showmessage(sc(sc_file)+' '+filename+' '+
                  sc(sc_is_modified_save),sc(sc_confirmation),
                   [mr_yes,mr_no,mr_cancel],mr_yes);
  end;

{
 if multiple then begin
  modalresult:= showmessage('File '+filename+' is modified. Save?','Confirmation',
                  [mr_yes,mr_all,mr_no,mr_noall,mr_cancel],mr_yes);
 end
 else begin
  modalresult:= showmessage('File '+filename+' is modified. Save?','Confirmation',
                  [mr_yes,mr_no,mr_cancel],mr_yes);
 end;
}
 if modalresult = mr_windowclosed then begin
  modalresult:= mr_cancel;
 end;
 result:= modalresult in [mr_yes,mr_all];
end;

function showsyserrormessage(const error: syserrorty;
                            const text: msestring = ''): boolean;
                               //returns true for sye_ok
begin
 result:= error = sye_ok;
 if not result then begin
  showerror(buildsyserrormessage(error,text));
 end;
end;

function showsyserrormessage(const error: syserrorty;
                 const sender: tobject; const text: msestring = ''): boolean;
                               //returns true for sye_ok
begin
 result:= error = sye_ok;
 if not result then begin
  showerror(buildsyserrormessage(error,sender,text));
 end;
end;

function getmaxdropdownheight(const parent: twidget): integer;
var
 rect1: rectty;
 int1: integer;
begin
 rect1:= application.workarea(parent.window);
 int1:= translatewidgetpoint(parent.framerect.pos,parent,nil).y;
 result:= int1 - rect1.y;
 int1:= rect1.y + rect1.cy - (int1 + parent.framerect.cy);
 if int1 > result then begin
  result:= int1;
 end;
end;

procedure getdropdownpos(const parent: twidget; const right: boolean;
                                                  var rect: rectty);
var
 int1,int2: integer;
 size1: sizety;
 workarea: rectty;
begin
 size1:= parent.framesize;
 rect.pos:= translatewidgetpoint(parent.framerect.pos,parent,nil);
 if right then begin
  rect.x:= rect.x + size1.cx - rect.cx;
 end;
 workarea:= application.workarea(parent.window);
 inc(rect.y,size1.cy);
 int1:= (workarea.y + workarea.cy);
 int2:= rect.y + rect.cy;
 if (int2 > int1) and (rect.y - rect.cy - workarea.y > int1 - int2) then begin
  dec(rect.y,size1.cy);
  int1:= rect.y - workarea.y;
  if rect.cy > int1 then begin
   rect.cy:= int1;
  end;
  dec(rect.y,rect.cy); //shift above
 end
 else begin
  int1:= workarea.y + workarea.cy - rect.y;
  if rect.cy > int1 then begin
   rect.cy:= int1;
  end;
 end;
 int1:= (workarea.x + workarea.cx) - (rect.x + rect.cx);
 if int1 < 0 then begin
  inc(rect.x,int1);
 end;
 if rect.x < workarea.x then begin
  rect.x:= workarea.x;
 end;
end;

function placepopuprect(const awindow: twindow; const adest: rectty;
                 const placement: captionposty; const asize: sizety): rectty;
 //placement currently cp_bottomleft and cp_center only,
 //todo

var
 int1: integer;
 rect1: rectty;
begin
 result.size:= asize;
 with adest do begin
  if placement = cp_bottomleft then begin
   result.x:= x;
   result.y:= y + cy;
  end
  else begin
   result.x:= x + (cx - asize.cx) div 2;
   result.y:= y + (cy - asize.cy) div 2;
  end;
  rect1:= application.workarea(awindow);
  with result do begin //shift in workarea
   int1:= (rect1.x + rect1.cx) - (x + cx);
   if int1 < 0 then begin
    inc(x,int1);
   end;
   if x < rect1.x then begin
    x:= rect1.x;
   end;
   if y + cy > rect1.y + rect1.cy then begin
    if placement = cp_bottomleft then begin
     y:= adest.y - asize.cy; //above destrect
    end
    else begin
     y:= rect1.y + rect1.cy - asize.cy;
    end;
    if y < rect1.y then begin
     y:= rect1.y;
    end;
   end;
  end;
 end;
end;

function placepopuprect(const awidget: twidget; const adest: rectty; //widgetorig
                 const placement: captionposty; const asize: sizety): rectty;
begin
 result:= placepopuprect(awidget.window,moverect(adest,
               translatewidgetpoint(nullpoint,awidget,nil)),placement,asize);
end;

function placeclientpopuprect(const awidget: twidget;
                 const adest: rectty; //clientorig
                 const placement: captionposty; const asize: sizety): rectty;
begin
 result:= placepopuprect(awidget.window,moverect(adest,
               translateclientpoint(nullpoint,awidget,nil)),placement,asize);
end;

procedure getwindowicon(const abitmap: tmaskedbitmap; out aicon,amask: pixmapty;
                        const anodefault: boolean = false);
var
 bmp: tmaskedbitmap;
begin
 aicon:= 0;
 amask:= 0;
 if abitmap <> nil then begin
  if abitmap.source <> nil then begin
   bmp:= abitmap.source.bitmap;
  end
  else begin
   bmp:= abitmap;
  end;
  if not bmp.isempty then begin
   if bmp.masked then begin
    amask:= bmp.mask.handle; //first because it possibly destroys bmp.handle
   end;
   aicon:= bmp.handle;
  end;
 end;
 if (aicon = 0) and not anodefault then begin
  getwindowicon(stockobjects.mseicon,aicon,amask);
 end;
end;

function messagerect(const position: messagepositionty;
                                        out arect: rectty): prectty;
var
 window1: twindow;
begin
 application.lockifnotmainthread;
 try
  result:= nil;
  if position <> mepo_screencentered then begin
   window1:= application.unreleasedactivewindow;
   if (window1 <> nil) and
          ((position = mepo_windowcentered) or
           (wo_windowcentermessage in window1.options)) then begin
    arect:= window1.owner.widgetrect;
    result:= @arect;
   end
   else begin
    result:= nil;
   end;
  end;
 finally
  application.unlockifnotmainthread;
 end;
end;


procedure syncshowmessage(const adata: pointer);
const
 maxtextwidth = 500;
 verttextdist = 10;
 horztextdist = 10;
 buttondist = 10;
var
 buttonheight: integer;
 buttonwidth: integer;
 widget: tshowmessagewidget;
 widget1: twidget; //dummy parent to get invisible canvas
 but: array[0..integer(high(modalresultty))] of tmessagebutton;
 int1,int2: integer;
 rect1{,rect2}: rectty;
 acanvas: tcanvas;
 textoffset: integer;
 transientfor: twindow;

begin
 with pshowmessageinfoty(adata)^ do begin
  application.lockifnotmainthread;
  try
   transientfor:= application.unreleasedactivewindow;
   widget1:= twidget.create(nil);
   widget1.visible:= false;
         //stays invisible, no wm_configured processing on win32
   widget:= tshowmessagewidget.create(nil,(transientfor <> nil) and
               (transientfor.ispopup) and transientfor.owner.visible,
               high(actions) >= 0,exttext,pshowmessageinfoty(adata));
   widget.name:= '_showmessage'; //debug purpose
   widget.parentwidget:= widget1; //do not create window handle of widget

   try
    acanvas:= widget1.getcanvas;
    acanvas.font.color := cl_black;
    buttonheight:= acanvas.font.glyphheight + 6;
    buttonwidth:= 50;
    for int1:= 0 to ord(high(buttons)) do begin
         int2:= acanvas.getstringwidth(
               stockobjects.modalresulttextnoshortcut[buttons[int1]]) + 10;
    if int2 > buttonwidth then begin
      buttonwidth:= int2;
     end;
    end;
    widget.caption:= caption;
    acanvas.font:= stockobjects.fonts[stf_message];
    acanvas.font.color := cl_black;
    rect1:= textrect(acanvas,atext);
    if rect1.cx > maxtextwidth then begin
     rect1.cx:= maxtextwidth;
     rect1.cy:= bigint;
     rect1:= textrect(acanvas,atext,rect1,[tf_wordbreak]);
     widget.info.flags:= [tf_wordbreak];
    end;
    rect1.x:= horztextdist;
    rect1.y:= verttextdist;
    textoffset:= minwidth - rect1.cx;
    if textoffset > 0 then begin
     rect1.cx:= minwidth;
    end
    else begin
     textoffset:= 0;
    end;
    with widget.info do begin
     font:= stockobjects.fonts[stf_message];
     font.height := messagefontheight;
     font.name := ansistring(messagefontname);
     font.color := cl_black;
     dest:= rect1;
     text.text:= atext;
    end;
    int1:= length(buttons);

    if int1 > 0 then begin
     int2:= int1 * buttonwidth;
     int2:= int2 + buttondist * (int1 - 1);
     inc(rect1.cy,buttonheight+verttextdist);
    end
    else begin
     int2:= 0;
    end;
    if int2 > rect1.cx then begin
     rect1.cx:= int2;         //width of buttons greater then text width
     widget.info.dest.cx:= int2;
    end;

    inc(rect1.cx,2*horztextdist);
    inc(rect1.cy,2*verttextdist);

    widget.parentwidget:= nil;  //remove dummy parent
    widget.clientsize:= rect1.size;
    if placementrect = nil then begin
     widget.window.windowpos:= wp_screencentered;
    end
    else begin
//     rect2:= placementrect^;
     {
     if placement = cp_bottomleft then begin
      dec(rect2.y,8);
      inc(rect2.cy,28); //for windowdecoration
     end;
     }
     widget.widgetrect:= placepopuprect(transientfor,
                                       placementrect^,placement,widget.size);
    end;

    with widget.info.dest do begin
     rect1.x:= x + (cx - int2) div 2;
     rect1.y:= y + cy + verttextdist + widget.paintpos.y;
     rect1.cx:= buttonwidth;
     rect1.cy:= buttonheight;
    end;
    for int1:= 0 to high(buttons) do begin
     but[int1]:= tmessagebutton.create(widget);
     with but[int1] do begin
      widgetrect:= rect1;
      parentwidget:= widget;
      if buttons[int1] in noshortcut then begin
       caption:=
               stockobjects.modalresulttextnoshortcut[buttons[int1]];
     end
      else begin
       caption:=  stockobjects.modalresulttext[buttons[int1]];
      end;
      if int1 <= high(actions) then begin
       onexecute:= actions[int1];
      end;
      modalresult:= buttons[int1];
     end;
     if buttons[int1] = defaultbutton then begin
      widget.defaultfocuschild:= but[int1];
     end;
     inc(rect1.x,buttonwidth + buttondist);
    end;
    inc(widget.info.dest.x,textoffset div 2);
    dec(widget.info.dest.cx,textoffset);
    widget.updateskin(true);
   {
    if placementrect <> nil then begin
     widget.visible:= true;
     application.processmessages(); //decorate window
     widget.window.decoratedwidgetrect:= placepopuprect(transientfor,
                        placementrect^,placement,widget.window.decoratedsize);
    end;
   }
    result:= widget.show(true,transientfor);
   finally
    widget1.free;
    widget.Free;
   end;
  finally
   application.unlockifnotmainthread;
  end;
 end;
end;

function internalshowmessage(const atext_,caption_: msestring;
                  buttons_: array of modalresultty;
                  defaultbutton_: modalresultty;
                  noshortcut_: modalresultsty;
                  placementrect_: prectty; placement_: captionposty;
                  minwidth_: integer; actions_: array of notifyeventty;
                  const exttext_: msestring;
                  const async_: boolean = false): modalresultty;
var
 info: showmessageinfoty;
begin
 with info do begin
  atext:= atext_;
  caption:= caption_;
  setlength(buttons,length(buttons_));
  move(buttons_[0],buttons[0],length(buttons)*sizeof(buttons[0]));
  defaultbutton:= defaultbutton_;
  noshortcut:= noshortcut_;
  placementrect:= placementrect_;
  placement:= placement_;
  minwidth:= minwidth_;
  setlength(actions,length(actions_));
  move(actions_[0],actions[0],length(actions)*
                             sizeof({$ifndef FPC}@{$endif}actions[0]));
  exttext:= exttext_;
  async:= async_;
 end;
 if application.ismainthread then  begin
  syncshowmessage(@info);
 end
 else begin
  application.synchronize(@syncshowmessage,@info);
 end;
 result:= info.result;
end;

function showmessage(const atext,caption: msestring;
                     const buttons: array of modalresultty;
                     const defaultbutton: modalresultty = mr_cancel;
                     const noshortcut: modalresultsty = [];
                     const minwidth: integer = 0;
                     const exttext: msestring = '';
              const position: messagepositionty = mepo_default): modalresultty;
var
 rect1: rectty;
begin
 result:= internalshowmessage(atext,caption,buttons,defaultbutton,
          noshortcut,messagerect(position,rect1),cp_center,minwidth,[],exttext);
end;

function showmessage(const atext,caption: msestring;
                     const buttons: array of modalresultty;
                     const defaultbutton: modalresultty;
                     const noshortcut: modalresultsty;
                     const minwidth: integer;
                     const actions: array of notifyeventty;
                     const exttext: msestring = '';
             const position: messagepositionty = mepo_default): modalresultty;
var
 rect1: rectty;
begin
 result:= internalshowmessage(atext,caption,buttons,defaultbutton,
                 noshortcut,messagerect(position,rect1),cp_center,
                                                 minwidth,actions,exttext);
end;

function showmessage(const atext,caption: msestring;
                     const buttons: array of modalresultty;
                     const adest: rectty; const awidget: twidget = nil;
                     //origin = awidget.clientpos, screen if awidget = nil
                     const placement: captionposty = cp_bottomleft;
                     const defaultbutton: modalresultty = mr_cancel;
                     const noshortcut: modalresultsty = [];
                     const minwidth: integer = 0;
                     const exttext: msestring = ''): modalresultty; overload;
var
 rect1: rectty;
begin
 if awidget = nil then begin
  rect1.pos:= adest.pos;
 end
 else begin
  application.lockifnotmainthread;
  try
   rect1.pos:= translateclientpoint(adest.pos,awidget,nil);
  finally
   application.unlockifnotmainthread;
  end;
 end;
 rect1.size:= adest.size;
 result:= internalshowmessage(atext,caption,buttons,defaultbutton,noshortcut,
                @rect1,placement,minwidth,[],exttext);
end;

function showmessage(const atext: msestring; const caption: msestring = '';
                        const minwidth: integer = 0;
                        const exttext: msestring = ''): modalresultty;
begin
 result:= showmessage(atext,caption,[mr_ok],mr_ok,[],minwidth,exttext);
end;

procedure showmessage1(const atext: msestring; const caption: msestring);
            //for ps
begin
 showmessage(atext,caption);
end;

type
 tshowerrormessageevent = class(texecuteevent)
  private
   ftext: msestring;
   fcaption: msestring;
   fminwidth: integer;
   fexttext: msestring;
  protected
   procedure execute; override;
  public
   constructor create(const text: msestring; const caption: msestring;
              const minwidth: integer; const exttext: msestring);
 end;

{ tshowerrormessageevent }

constructor tshowerrormessageevent.create(const text: msestring;
               const caption: msestring; const minwidth: integer;
               const exttext: msestring);
begin
 ftext:= text;
 fcaption:= caption;
 fminwidth:= minwidth;
 fexttext:= exttext;
 inherited create;
 application.postevent(self);
end;

procedure tshowerrormessageevent.execute;
var
 rect1: rectty;
begin
 internalshowmessage(ftext,fcaption,[mr_ok],mr_ok,
          [],messagerect(mepo_default,rect1),cp_center,0,[],fexttext,true);
// showmessage(ftext,fcaption,fminwidth,fexttext);
end;

procedure showerror(const atext: msestring; caption: msestring = 'ERROR';
                    const minwidth: integer = 0;
                    const exttext: msestring = '';
                    const async: boolean = false);
begin
 if caption = 'ERROR' then begin
 caption:= uppercase(sc(sc_error));
 end;
 if async or not application.ismainthread then begin
  tshowerrormessageevent.create(atext,caption,minwidth,exttext);
 end
 else begin
  showmessage(atext,caption,minwidth,exttext);
 end;
end;

function askok(const atext: msestring; const caption: msestring = '';
               const defaultbutton: modalresultty = mr_ok;
               const minwidth: integer = 0): boolean;
                  //true if ok pressed
begin
 result:= showmessage(atext,caption,[mr_ok,mr_cancel],defaultbutton,[],
                    minwidth) = mr_ok;
end;

function askyesno(const atext: msestring; const caption: msestring = '';
                    const defaultbutton: modalresultty = mr_yes;
                    const minwidth: integer = 0): boolean;
                  //true if yes pressed
begin
 result:= showmessage(atext,caption,[mr_yes,mr_no],defaultbutton,[],
                          minwidth) = mr_yes;
end;

function askyesnocancel(const atext: msestring; const caption: msestring = '';
                    const defaultbutton: modalresultty = mr_yes;
                    const minwidth: integer = 0 ): modalresultty;
begin
 result:= showmessage(atext,caption,[mr_yes,mr_no,mr_cancel],defaultbutton,[],
                          minwidth);
 if not (result in [mr_yes,mr_no]) then begin
  result:= mr_cancel;
 end;
end;

function askconfirmation(const atext: msestring;
                    const defaultbutton: modalresultty = mr_yes;
                    const minwidth: integer = 0): boolean;
                  //true if yes pressed
begin
result:= showmessage(atext,sc(sc_confirmation),[mr_yes,mr_no],defaultbutton,[],
                         minwidth) = mr_yes;
end;

function askconfirmationcancel(const atext: msestring;
                     const defaultbutton: modalresultty = mr_yes;
                     const minwidth: integer = 0): modalresultty;
begin
 result:= askyesnocancel(atext,sc(sc_confirmation),defaultbutton,minwidth);
end;

{ tframefont}

class function tframefont.getinstancepo(owner: tobject): pfont;
begin
 result:= @tcustomcaptionframe(owner).ffont;
end;

{ tactionsimplebutton}

constructor tactionsimplebutton.create(aowner: tcomponent);
begin
 foptions:= defaultbuttonoptions;
 inherited;
 optionswidget:= defaultoptionswidget - [ow_mousefocus];
 initshapeinfo(finfo);
 finfo.ca.dim:= innerclientrect;
 finfo.color:= cl_transparent;
 finfo.ca.colorglyph:= cl_black;
 finfo.doexecute:= {$ifdef FPC}@{$endif}doshapeexecute;
 finfo.state:= finfo.state+[shs_showfocusrect,shs_showdefaultrect];
end;
{
procedure tactionsimplebutton.setoptionswidget(const avalue: optionswidgetty);
begin
 if ow_nofocusrect in avalue then begin
  exclude(finfo.state,ss_showfocusrect);
 end
 else begin
  include(finfo.state,ss_showfocusrect);
 end;
 inherited;
end;
}
procedure tactionsimplebutton.clientrectchanged;
begin
 inherited;
 frameskinoptionstoshapestate(fframe,finfo);
 finfo.ca.dim:= clientrect;
 if (fframe <> nil) and not(shs_noinnerrect in finfo.state)  then begin
                                  //otherwise mouse rect
  deflaterect1(finfo.ca.dim,fframe.frameo);
 end;
{
 if shs_noinnerrect in finfo.state then begin
  finfo.ca.dim:= clientrect;
 end
 else begin
  finfo.ca.dim:= innerclientrect;
 end;
}
 if shs_flat in finfo.state then begin
  exclude(fwidgetstate1,ws1_nodesignframe);
 end
 else begin
  include(fwidgetstate1,ws1_nodesignframe);
 end;
end;

procedure tactionsimplebutton.doexecute;
begin
 //dummy
end;

procedure tactionsimplebutton.doasyncevent(var atag: integer);
begin
 if atag = 0 then begin
  doexecute;
 end;
end;

procedure tactionsimplebutton.internalexecute();
begin
 if bo_asyncexecute in foptions then begin
  asyncevent;
 end
 else begin
  doexecute;
 end;
end;

procedure tactionsimplebutton.doshapeexecute(const atag: integer;
                  const info: mouseeventinfoty);
begin
 internalexecute;
end;

procedure tactionsimplebutton.dopaintforeground(const canvas: tcanvas);
begin
 inherited;
 finfo.frame:= fframe;
 drawbutton(canvas,finfo);
end;

procedure tactionsimplebutton.clientmouseevent(var info: mouseeventinfoty);
begin
 inherited;
 if not (csdesigning in componentstate) and
        not (es_processed in info.eventstate) then begin
  updatemouseshapestate(finfo,info,self,fframe,nil,bo_executeonclick in foptions);
 end;
end;

procedure tactionsimplebutton.execute;
begin
 if not (shs_disabled in finfo.state) then begin
  internalexecute;
 end;
end;

procedure tactionsimplebutton.pressbutton;
begin
 include(finfo.state,shs_clicked);
 invalidateframestaterect(finfo.ca.dim,fframe);
end;

function tactionsimplebutton.releasebutton(const aexecute: boolean): boolean;
                 //true if clicked
begin
 result:= shs_clicked in finfo.state;
 exclude(finfo.state,shs_clicked);
 if result then begin
  invalidateframestaterect(finfo.ca.dim,fframe);
  if aexecute then begin
   internalexecute;
  end;
 end;
end;

procedure tactionsimplebutton.dokeydown(var info: keyeventinfoty);
begin
// inherited;
 with info do begin
  if not getdisabled() and (shiftstate * shiftstatesrepeatmask = []) and
                              (bo_executeonkey in foptions) then begin
   if (key = key_space) then begin
    include(info.eventstate,es_processed);
    pressbutton;
   end
   else begin
    if (isenterkey(self,key) or (key = key_period)) and
                   not (aso_noreturnbutton in assistiveoptions) then begin
                                       //only space key if assisted
     include(eventstate,es_processed);
     internalexecute;
    end;
   end;
  end;
 end;
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;

procedure tactionsimplebutton.dokeyup(var info: keyeventinfoty);
begin
 inherited;
 if not getdisabled() and (info.key = key_space) and
                     releasebutton((info.shiftstate = []) and
                     (bo_executeonkey in foptions)) then begin
  include(info.eventstate,es_processed);
 end;
end;

procedure tactionsimplebutton.statechanged;
begin
 inherited;
 updatewidgetshapestate(finfo,self,getdisabled(),{false,}fframe);
end;

procedure tactionsimplebutton.setcolorglyph(const value: colorty);
begin
 if finfo.ca.colorglyph <> value then begin
  finfo.ca.colorglyph := value;
  invalidate;
 end;
end;

class function tactionsimplebutton.classskininfo: skininfoty;
begin
 result:= inherited classskininfo;
 result.objectkind:= sok_simplebutton;
end;

procedure tactionsimplebutton.setoptions(const avalue: buttonoptionsty);
begin
 if foptions <> avalue then begin
  foptions:= avalue;
  buttonoptionstoshapestate(avalue,finfo.state);
  invalidate;
 end;
end;

function tactionsimplebutton.getframestateflags: framestateflagsty;
begin
 result:= combineframestateflags(not isenabled,focused,active,
                     shs_mouse in finfo.state,shs_clicked in finfo.state);
 if not (bo_nodefaultframeactive in foptions) and
               ((shs_default in finfo.state) or focused) then begin
  include(result,fsf_offset1);
  include(result,fsf_default);
 end;
end;

function tactionsimplebutton.navigstartrect: rectty;
begin
 result:= inherited navigstartrect;
// result.x:= result.x + result.cx div 2;
// result. cx:= 0;
end;

function tactionsimplebutton.getassistiveflags(): assistiveflagsty;
begin
 result:= inherited getassistiveflags() + [asf_button];
 if getdisabled() then begin
  include(result,asf_disabled);
 end;
end;

function tactionsimplebutton.getdisabled(): boolean;
begin
 result:= false;
end;

{
function tactionsimplebutton.getframeclicked: boolean;
begin
 result:= ss_clicked in finfo.state;
end;

function tactionsimplebutton.getframemouse: boolean;
begin
 result:= ss_mouse in finfo.state;
end;

function tactionsimplebutton.getframeactive: boolean;
begin
 result:= not (bo_nodefaultframeactive in foptions) and
                           (ss_default in finfo.state) or active;
end;
}
{ tmessagebutton }

procedure tmessagebutton.setcaption(const avalue: msestring);
begin
 fcaption:= avalue;
 captiontorichstring(avalue,finfo.ca.caption);
 invalidate();
end;

procedure tmessagebutton.doexecute;
begin
 if assigned(onexecute) then begin
  onexecute(self);
 end;
 window.modalresult:= modalresult;
end;

procedure tmessagebutton.doshortcut(var info: keyeventinfoty; const sender: twidget);
begin
 if checkshortcut(info,caption,bo_altshortcut in options) then begin
  include(info.eventstate,es_processed);
  internalexecute;
 end
 else begin
  inherited;
 end;
end;

function tmessagebutton.getassistivecaption(): msestring;
//var
// capt1: richstringty;
begin
 result:= fcaption;
// captiontorichstring(fcaption,capt1);
// result:= capt1.text;
end;

{ tshowmessagewidget }

constructor tshowmessagewidget.create(const aowner: tcomponent;
           const apopuptransient: boolean; const ahasaction: boolean;
           const exttext: msestring; const ainfo: pshowmessageinfoty);
begin
 fexttext:= exttext;
 finfo:= ainfo;
 inherited create(aowner,apopuptransient,ahasaction);
 if finfo^.placementrect <> nil then begin
  application.registeronidle(@doidle);
 end;
end;

destructor tshowmessagewidget.destroy();
begin
 application.unregisteronidle(@doidle);
 inherited;
end;

procedure tshowmessagewidget.dopaintforeground(const canvas: tcanvas);
begin
 inherited;
 canvas.font:= stockobjects.fonts[stf_message];
 drawtext(canvas,info);
end;

procedure tshowmessagewidget.dokeydown(var ainfo: keyeventinfoty);
begin
 if issysshortcut(sho_copy,ainfo) or issysshortcut(sho_cut,ainfo) then begin
  copytoclipboard(replacechar(info.text.text+fexttext,#0 ,' '));
 end;
 inherited;
end;

procedure tshowmessagewidget.doidle(var again: boolean);
begin
 application.unregisteronidle(@doidle);
 if finfo^.placementrect <> nil then begin
  window.decoratedwidgetrect:= placepopuprect(window.transientfor,
                  finfo^.placementrect^,finfo^.placement,window.decoratedsize);
 end;
end;

function tshowmessagewidget.getassistivetext(): msestring;
begin
 result:= info.text.text;
end;

function tshowmessagewidget.getassistiveflags(): assistiveflagsty;
begin
 result:= inherited getassistiveflags + [asf_message];
 if finfo^.async then begin
  include(result,asf_async);
 end;
end;

{ tcustomcaptionframe }

constructor tcustomcaptionframe.create(const aintf: icaptionframe);
begin
 fcaptionpos:= cp_topleft;
 fcaptiondist:= 1;
 inherited create(aintf);
 if ffont = nil then begin
{$push}
{$objectChecks off} 
  finfo.font:= icaptionframe(fintf).getframefont;
{$pop} 
 end;
end;

destructor tcustomcaptionframe.destroy;
begin
 inherited;
 ffont.free;
end;
{
function tcustomcaptionframe.getcaption: msestring;
begin
 result:= richstringtocaption(finfo.text);
end;
}
procedure tcustomcaptionframe.setcaption(const avalue: msestring);
begin
 fcaption:= avalue;
 captiontorichstring(avalue,finfo.text);
 internalupdatestate();
end;

procedure tcustomcaptionframe.setcaptionpos(const avalue: captionposty);
begin
 if (fcaptionpos <> avalue) then begin
 {
  case avalue of
   cp_leftcenter: fcaptionpos:= cp_left;
   cp_rightcenter: fcaptionpos:= cp_right;
   cp_topcenter: fcaptionpos:= cp_top;
   cp_bottomcenter: fcaptionpos:= cp_bottom;
   else fcaptionpos:= avalue;
  end;
 }
  fcaptionpos:= avalue;
  internalupdatestate;
 end;
end;

procedure tcustomcaptionframe.fontchanged(const sender: tobject);
begin
 internalupdatestate;
end;

procedure tcustomcaptionframe.fontcanvaschanged;
begin
 exclude(fstate,fs_rectsvalid);
end;

function tcustomcaptionframe.haspaintrectfocus(): boolean;
begin
 result:= inherited haspaintrectfocus() or (finfo.text.text = '');
end;

procedure tcustomcaptionframe.dopaintfocusrect(const canvas: tcanvas;
                            const rect: rectty);
begin
 if haspaintrectfocus then begin
  inherited;
 end
 else begin
  drawfocusrect(canvas,inflaterect(finfo.dest,captionmargin));
 end;
end;

procedure tcustomcaptionframe.internalpaintoverlay(const canvas: tcanvas;
                                                          const arect: rectty);
var
 reg1: regionty;
 flagsbefore: textflagsty;
begin
 reg1:= 0;
 if not (cfo_captionnoclip in foptions) and (finfo.text.text <> '') then begin
  reg1:= canvas.copyclipregion;
  canvas.subcliprect(inflaterect(finfo.dest,captionmargin));
 end;
 inherited;
 if reg1 <> 0 then begin
  canvas.clipregion:= reg1;
 end;
 if finfo.text.text <> '' then begin
  flagsbefore:= finfo.flags;
  finfo.flags:= updatetextflags(finfo.flags);
  drawtext(canvas,finfo);
  finfo.flags:= flagsbefore;
 end;
end;
{
procedure tcustomcaptionframe.afterpaint(const canvas: tcanvas);
begin
 if finfo.text.text <> '' then begin
  drawtext(canvas,finfo);
 end;
 inherited;
end;
}
procedure tcustomcaptionframe.createfont;
begin
 if ffont = nil then begin
  ffont:= tframefont.create;
  ffont.onchange:= {$ifdef FPC}@{$endif}fontchanged;
  finfo.font:= ffont;
 end;
end;

function tcustomcaptionframe.getfont: tframefont;
begin
// getoptionalobject(fintf.getcomponentstate,ffont,{$ifdef FPC}@{$endif}createfont);
{$push}
{$objectChecks off}
 icaptionframe(fintf).getwidget.getoptionalobject(ffont,
                                         {$ifdef FPC}@{$endif}createfont);
 
 {$pop}
 if ffont <> nil then begin
  result:= ffont;
 end
 else begin
{$push}
{$objectChecks off} 
  result:= tframefont(icaptionframe(fintf).getframefont);
  {$pop}
 end;
end;

procedure tcustomcaptionframe.setfont(const Value: tframefont);
begin
 if value <> ffont then begin
  setoptionalobject(fintf.getcomponentstate,value,ffont,{$ifdef FPC}@{$endif}createfont);
  if ffont <> nil then begin
   finfo.font:= ffont;
  end
  else begin
{$push}
{$objectChecks off}  
   finfo.font:= icaptionframe(fintf).getframefont;
   {$pop}
  end;
  internalupdatestate();
 end;
end;

function tcustomcaptionframe.isfontstored: Boolean;
begin
 result:= ffont <> nil;
end;

procedure tcustomcaptionframe.parentfontchanged;
begin
 inherited;
 if ffont = nil then begin
{$push}
{$objectChecks off} 
  finfo.font:= icaptionframe(fintf).getframefont;
  
  if not (ws_loadedproc in icaptionframe(fintf).getwidget.widgetstate) then begin
   internalupdatestate;
  end
{$pop};
 end;
end;

procedure tcustomcaptionframe.visiblechanged;
begin
 inherited;
 if finfo.text.text <> '' then begin
  internalupdatestate;
 end;
end;

function tcustomcaptionframe.updatetextflags(
                          const aflags: textflagsty): textflagsty;
begin
 result:= finfo.flags;
 if (fs_disabled in fstate) and not (cfo_captionnogray in foptions) then begin
  include(result,tf_grayed);
 end;
end;

procedure tcustomcaptionframe.updaterects;
var
 canvas: tcanvas;
 fra1: framety;
 rect1,rect2: rectty;
 bo1,bo2: boolean;
 widget1: twidget1;
 flagsbefore: textflagsty;
begin
 inherited;
 fra1:= fouterframe;
 fstate:= fstate - [fs_cancaptionsyncx,fs_cancaptionsyncy];
 if finfo.text.text <> '' then begin
  flagsbefore:= finfo.flags;
  finfo.flags:= updatetextflags(finfo.flags);
{$push}
{$objectChecks off}  
  canvas:= icaptionframe(fintf).getcanvas;
  canvas.font:= getfont;
  finfo.dest.size:= icaptionframe(fintf).getwidgetrect.size;
{$pop}  
  rect1:= deflaterect(makerect(nullpoint,finfo.dest.size),fouterframe);
  textrect(canvas,finfo);
  finfo.flags:= flagsbefore;
//  finfo.flags:= flagsbefore-[tf_xcentered,tf_ycentered,tf_right,tf_bottom];
  finfo.dest:= finfo.res;
  bo1:= cfo_captiondistouter in foptions;
  bo2:= cfo_captionframecentered in foptions;
  rect2:= inflaterect(finfo.dest,captionmargin);
  with rect2 do begin
   if fcaptionpos = cp_center then begin //precision position for record
    x:= (rect1.x + rect1.x + rect1.cx - rect2.cx) div 2 + fcaptiondist;
    y:= (rect1.y + rect1.y + rect1.cy - rect2.cy) div 2 + fcaptionoffset;
//    finfo.flags:= finfo.flags + [tf_xcentered,tf_ycentered];
   end
   else begin
   {
    if fcaptionpos in [cp_left,cp_right] then begin
     include(finfo.flags,tf_ycentered);
    end
    else begin
     if fcaptionpos in [cp_top,cp_bottom] then begin
      include(finfo.flags,tf_xcentered);
     end;
    end;
    if fcaptionpos in [cp_left,cp_lefttop,cp_leftbottom] then begin
     include(finfo.flags,tf_right);
    end
    else begin
     if fcaptionpos in [cp_top,cp_topleft,cp_topright] then begin
      include(finfo.flags,tf_bottom);
     end;
    end;
    }
    case fcaptionpos of
     cp_lefttop,cp_left,cp_leftbottom: begin
      include(fstate,fs_cancaptionsyncx);
      x:= rect1.x - fcaptiondist;
      if not bo1 then begin
       x:= x - cx;
       if bo2 then begin
        x:= x + (cx + fwidth.left) div 2;
       end;
      end;
     end;
     cp_topleft,cp_bottomleft: begin
      include(fstate,fs_cancaptionsyncy);
      x:=  rect1.x + fcaptionoffset;
     end;
     cp_top,cp_bottom: begin
      include(fstate,fs_cancaptionsyncy);
      x:= rect1.x + (rect1.cx - cx) div 2 + fcaptionoffset;
     end;
     cp_topright,cp_bottomright: begin
      include(fstate,fs_cancaptionsyncy);
      x:= rect1.x + rect1.cx - cx + fcaptionoffset;
     end;
     cp_righttop,cp_right,cp_rightbottom: begin
      include(fstate,fs_cancaptionsyncx);
      x:= rect1.x + rect1.cx + fcaptiondist;
      if bo1 then begin
       x:= x - cx;
      end
      else begin
       if bo2 then begin
        x:= x - (fwidth.right + cx) div 2;
       end;
      end;
     end;
     else;
    end;
    case fcaptionpos of
     cp_topleft,cp_top,cp_topright: begin
      y:= rect1.y - fcaptiondist;
      if not bo1 then begin
       y:= y - cy;
       if bo2 then begin
        y:= y + (cy+fwidth.top) div 2;
       end;
      end;
     end;
     cp_lefttop,cp_righttop: begin
      y:= rect1.y + fcaptionoffset;
     end;
     cp_left,cp_right: begin
      y:= rect1.y + (rect1.cy - cy) div 2 + fcaptionoffset;
     end;
     cp_leftbottom,cp_rightbottom: begin
      y:= rect1.y + rect1.cy - cy + fcaptionoffset;
     end;
     cp_bottomleft,cp_bottom,cp_bottomright: begin
      y:= rect1.y + rect1.cy + fcaptiondist;
      if bo1 then begin
       y:= y - cy;
      end
      else begin
       if bo2 then begin
        y:= y - (cy + fwidth.bottom) div 2;
       end;
      end;
     end;
     else;
    end;
   end;
   fouterframe.left:= rect1.x - x;
   if fouterframe.left < 0 then begin
    fouterframe.left:= 0;
   end;
   fouterframe.top:= rect1.y - y;
   if fouterframe.top < 0 then begin
    fouterframe.top:= 0;
   end;
   fouterframe.right:= x + cx - (rect1.x + rect1.cx);
   if fouterframe.right < 0 then begin
    fouterframe.right:= 0;
   end;
   fouterframe.bottom:= y + cy - (rect1.y + rect1.cy);
   if fouterframe.bottom < 0 then begin
    fouterframe.bottom:= 0;
   end;
  end;
  finfo.dest:= inflaterect(rect2,-captionmargin);
  if bo1 then begin
   fstate:= fstate - [fs_cancaptionsyncx,fs_cancaptionsyncy];
                 //captiondistouter set
  end;
 end
 else begin //caption = '' or invisible
  fouterframe:= nullframe;
  finfo.dest:= nullrect;
 end;
 subframe1(fra1,fouterframe);
{$push}
{$objectChecks off}
 widget1:= twidget1(icaptionframe(fintf).getwidget);
{$pop}
 if (cfo_autowidth in foptions) or
        (widget1.anchors * [an_left,an_right] = [an_left,an_right]) then begin
  if fcaptionpos in [cp_topleft,cp_bottomleft,
                          cp_top,cp_bottom,cp_center] then begin
   fouterframe.right:= 0;
  end;
  if fcaptionpos in [cp_topright,cp_bottomright,
                         cp_top,cp_bottom,cp_center] then begin
   fouterframe.left:= 0;
  end;
 end;
 if (cfo_autoheight in foptions) or
        (widget1.anchors * [an_top,an_bottom] = [an_top,an_bottom]) then begin
  if fcaptionpos in [cp_lefttop,cp_righttop,
                          cp_left,cp_right,cp_center] then begin
   fouterframe.bottom:= 0;
  end;
  if fcaptionpos in [cp_leftbottom,cp_rightbottom,
                         cp_left,cp_right,cp_center] then begin
   fouterframe.top:= 0;
  end;
 end;

 if not isnullframe(fra1) then begin
  if widget1.fwidgetstate1 *
                        [ws1_anchorsizing,ws1_layoutplacing] = [] then begin
   subpoint1(finfo.dest.pos,pointty(fra1.topleft));
   if fupdating < 16 then begin
    inc(fupdating);
    try
{$push}
{$objectChecks off}    
     rect1:= icaptionframe(fintf).getwidgetrect;
{$pop}
     rect2:= deflaterect(rect1,fra1);
     if cfo_fixleft in foptions then begin
      rect2.x:= rect1.x;
      if cfo_fixright in foptions then begin
       rect2.cx:= rect1.cx;
      end;
     end
     else begin
      if cfo_fixright in foptions then begin
       rect2.x:= rect1.x+rect1.cx-rect2.cx;
      end;
     end;
     if cfo_fixtop in foptions then begin
      rect2.y:= rect1.y;
      if cfo_fixbottom in foptions then begin
       rect2.cy:= rect1.cy;
      end;
     end
     else begin
      if cfo_fixbottom in foptions then begin
       rect2.y:= rect1.y+rect1.cy-rect2.cy;
      end;
     end;
{$push}
{$objectChecks off}        
     if (fupdating = 1) and
           rectisequal(icaptionframe(fintf).getwidgetrect,rect2) then begin
      if widget1.fparentwidget <> nil then begin
       twidget1(widget1.fparentwidget).childautosizechanged(widget1);
      end; //activate tlayouter
     end
     else begin
      icaptionframe(fintf).setwidgetrect(rect2);
     end;
{$pop}     
    finally
     dec(fupdating);
    end;
   end;
  end;
 end;
 inherited;
end;

procedure tcustomcaptionframe.updatehotkeys();
begin
 captiontorichstring(fcaption,finfo.text);
 internalupdatestate();
end;

procedure tcustomcaptionframe.dominsize(var asize: sizety);
var
 si1: sizety;
 framesi1: sizety;
begin
 framesi1.cx:= fpaintframe.left + fpaintframe.right -
                                   (fouterframe.left + fouterframe.right);
 framesi1.cy:= fpaintframe.top + fpaintframe.bottom -
                                   (fouterframe.top + fouterframe.bottom);
 if asize.cx < framesi1.cx then begin
  asize.cx:= framesi1.cx;
 end;
 if asize.cy < framesi1.cy then begin
  asize.cy:= framesi1.cy;
 end;
 if finfo.text.text <> '' then begin
  checkstate();
  si1.cx:= finfo.dest.size.cx + 2*captionmargin;
  si1.cy:= finfo.dest.size.cy + 2*captionmargin;
  case captionpos of
   cp_center: begin
    si1.cx:= si1.cx + abs(fcaptiondist);
    si1.cy:= si1.cy + abs(fcaptionoffset);
   end;
   cp_righttop,cp_right,cp_rightbottom,cp_lefttop,cp_left,cp_leftbottom: begin
    si1.cx:= framesi1.cx + si1.cx + abs(fcaptiondist);
    if fcaptionoffset > 0 then begin
     si1.cy:= si1.cy + fcaptionoffset;
    end;
   end
   else begin
    si1.cy:= framesi1.cy + si1.cy + abs(fcaptiondist);
    if fcaptionoffset > 0 then begin
     si1.cx:= si1.cx + fcaptionoffset;
    end;
   end;
  end;
  if asize.cx < si1.cx then begin
   asize.cx:= si1.cx;
  end;
  if asize.cy < si1.cy then begin
   asize.cy:= si1.cy;
  end;
 end;
end;

procedure tcustomcaptionframe.checkminshrinksize(var asize: sizety);
begin
 inherited;
 dominsize(asize);
end;

procedure tcustomcaptionframe.checkwidgetsize(var asize: sizety);
begin        //for autosize
 dominsize(asize);
end;

procedure tcustomcaptionframe.setcaptiondist(const Value: integer);
begin
 include(flocalprops1,frl1_captiondist);
 if fcaptiondist <> value then begin
  fcaptiondist := Value;
  internalupdatestate;
 end;
end;

function tcustomcaptionframe.iscaptiondiststored: boolean;
begin
 result:= (ftemplate = nil) or (frl1_captiondist in flocalprops1);
end;

procedure tcustomcaptionframe.setcaptionoffset(const Value: integer);
begin
 include(flocalprops1,frl1_captionoffset);
 if fcaptionoffset <> value then begin
  fcaptionoffset:= Value;
  internalupdatestate();
 end;
end;

procedure tcustomcaptionframe.setcaptiontextflags(const avalue: textflagsty);
begin
 if finfo.flags <> avalue then begin
  finfo.flags:= checktextflags(finfo.flags,avalue);
  internalupdatestate();
 end;
end;


function tcustomcaptionframe.iscaptionoffsetstored: boolean;
begin
 result:= (ftemplate = nil) or (frl1_captionoffset in flocalprops1);
end;

procedure tcustomcaptionframe.setoptions(const avalue: captionframeoptionsty);
const
// mask1: captionframeoptionsty = [cfo_captiondistouter,cfo_captionframecentered];
 mask2: captionframeoptionsty = [cfo_captiondistouter];
var
 optionsbefore: captionframeoptionsty;
 size1: sizety;
begin
 if avalue <> foptions then begin
  optionsbefore:= foptions;
 (*
  foptions:= captionframeoptionsty(setsinglebit(
            {$ifdef FPC}longword{$else}word{$endif}(avalue),
            {$ifdef FPC}longword{$else}word{$endif}(foptions),
            {$ifdef FPC}longword{$else}word{$endif}(mask1)));
  *)
  foptions:= captionframeoptionsty(
                setsinglebit(longword(avalue),longword(foptions),
                  [longword([cfo_captiondistouter,cfo_captionframecentered]),
                   longword([cfo_focusrect,cfo_nofocusrect])]));
  if (({$ifdef FPC}longword{$else}word{$endif}(optionsbefore) xor
       {$ifdef FPC}longword{$else}word{$endif}(foptions)) and
       {$ifdef FPC}longword{$else}word{$endif}(mask2) <> 0) and
     (fintf.getcomponentstate * [csdesigning,csloading] = [csdesigning]) and
     (caption <> '') then begin
   size1.cy:= font.glyphheight + 2 * captionmargin;
{$push}
{$objectChecks off}   
   size1.cx:= icaptionframe(fintf).getcanvas.getstringwidth(caption,getfont) +
                        2 * captionmargin;

{$pop}
   case captionpos of
    cp_center: begin
    end;
    cp_lefttop,cp_left,cp_leftbottom,cp_rightbottom,cp_right,cp_righttop: begin
     if cfo_captiondistouter in foptions then begin
      fcaptiondist:= fcaptiondist + size1.cx;
     end
     else begin
      fcaptiondist:= fcaptiondist - size1.cx;
     end;
    end;
    cp_topright,cp_top,cp_topleft,cp_bottomleft,cp_bottom,cp_bottomright: begin
     if cfo_captiondistouter in foptions then begin
      fcaptiondist:= fcaptiondist + size1.cy;
     end
     else begin
      fcaptiondist:= fcaptiondist - size1.cy;
     end;
    end;
   end;
  end;
  internalupdatestate;
 end;
end;

(*
function tcustomcaptionframe.getcaptiondistouter: boolean;
begin
 result:= fs_captiondistouter in fstate;
end;

function tcustomcaptionframe.getcaptionframecentered: boolean;
begin
 result:= fs_captionframecentered in fstate;
end;

procedure tcustomcaptionframe.setcaptionframecentered(const avalue: boolean);
begin
 if updatebit({$ifdef FPC}longword{$else}longword{$endif}(fstate),
       ord(fs_captionframecentered),avalue) then begin
  if avalue then begin
   exclude(fstate,fs_captiondistouter);
  end;
  internalupdatestate;
 end;
end;

procedure tcustomcaptionframe.setcaptiondistouter(const Value: boolean);
var
 size1: sizety;
begin
 if updatebit({$ifdef FPC}longword{$else}longword{$endif}(fstate),
       ord(fs_captiondistouter),value) then begin
  if value then begin
   exclude(fstate,fs_captionframecentered);
  end;
  if (fintf.getcomponentstate * [csdesigning,csloading] = [csdesigning]) and
                            (caption <> '') then begin
   size1.cy:= font.glyphheight + 2 * captionmargin;
   size1.cx:= icaptionframe(fintf).getcanvas.getstringwidth(caption,getfont) +
                        2 * captionmargin;
   case captionpos of
    cp_center: begin
    end;
    cp_lefttop,cp_left,cp_leftbottom,cp_rightbottom,cp_right,cp_righttop: begin
     if fs_captiondistouter in fstate then begin
      fcaptiondist:= fcaptiondist + size1.cx;
     end
     else begin
      fcaptiondist:= fcaptiondist - size1.cx;
     end;
    end;
    cp_topright,cp_top,cp_topleft,cp_bottomleft,cp_bottom,cp_bottomright: begin
     if fs_captiondistouter in fstate then begin
      fcaptiondist:= fcaptiondist + size1.cy;
     end
     else begin
      fcaptiondist:= fcaptiondist - size1.cy;
     end;
    end;
   end;
  end;
  internalupdatestate;
 end;
end;

function tcustomcaptionframe.getcaptionnoclip: boolean;
begin
 result:= fs_captionnoclip in fstate;
end;

procedure tcustomcaptionframe.setcaptionnoclip(const avalue: boolean);
begin
 if updatebit({$ifdef FPC}longword{$else}longword{$endif}(fstate),
       ord(fs_captionnoclip),avalue) then begin
  internalupdatestate;
 end;
end;
*)
procedure tcustomcaptionframe.defineproperties(filer: tfiler);
var
 bo1: boolean;
begin
 inherited;
 if filer.ancestor <> nil then begin
  bo1:= not frameisequal(fouterframe,tcustomcaptionframe(filer.ancestor).fouterframe);
 end
 else begin
  bo1:= not isnullframe(fouterframe);
 end;
 filer.DefineProperty('outerframe',{$ifdef FPC}@{$endif}readouterframe,
                  {$ifdef FPC}@{$endif}writeouterframe,bo1);
 filer.DefineProperty('captiondistouter',  //backward compatibility
            {$ifdef FPC}@{$endif}readcaptiondistouter,nil,false);
 filer.DefineProperty('captionnoclip', //backward compatibility
            {$ifdef FPC}@{$endif}readcaptionnoclip,nil,false);
end;

procedure tcustomcaptionframe.readouterframe(reader: treader);
begin
 with fouterframe,reader do begin
  readlistbegin;
  left:= ReadInteger;
  top:= ReadInteger;
  right:= ReadInteger;
  bottom:= ReadInteger;
  readlistend;
 end;
end;

procedure tcustomcaptionframe.writeouterframe(writer: twriter);
begin
 with fouterframe,writer do begin
  writelistbegin;
  writeinteger(left);
  writeinteger(top);
  writeinteger(right);
  writeinteger(bottom);
  writelistend;
 end;
end;

procedure tcustomcaptionframe.readcaptionnoclip(reader: treader);
begin
 if reader.readboolean then begin
  options:= options + [cfo_captionnoclip];
 end
 else begin
  options:= options - [cfo_captionnoclip];
 end;
end;

procedure tcustomcaptionframe.readcaptiondistouter(reader: treader);
begin
 if reader.readboolean then begin
  options:= options + [cfo_captiondistouter];
 end
 else begin
  options:= options - [cfo_captiondistouter];
 end;
end;

function tcustomcaptionframe.checkfocusshortcut(
                                      var info: keyeventinfoty): boolean;
begin
 result:= msegui.checkshortcut(info,fcaption,true);
end;

procedure tcustomcaptionframe.setdisabled(const value: boolean);
begin
 if (finfo.text.text <> '') and ((fs_disabled in fstate) xor value) then begin
  fintf.invalidatewidget;
 end;
 inherited;
end;

function tcustomcaptionframe.pointincaption(const point: pointty): boolean;
var
 rect1: rectty;
 int1: integer;
begin
 if finfo.text.text = '' then begin
  result:= false;
 end
 else begin
  checkstate;
  rect1:= finfo.dest;
  with rect1 do begin
   case fcaptionpos of
    cp_left,cp_lefttop,cp_leftbottom: begin
     int1:= fpaintrect.x - (x + cx);
     if int1 > 0 then begin
      inc(rect1.cx,int1);
     end;
    end;
    cp_top,cp_topleft,cp_topright: begin
     int1:= fpaintrect.y - (y + cy);
     if int1 > 0 then begin
      inc(rect1.cy,int1);
     end;
    end;
    cp_right,cp_righttop,cp_rightbottom: begin
     int1:= x - (fpaintrect.x + fpaintrect.cx);
     if int1 > 0 then begin
      dec(rect1.x,int1);
      inc(rect1.cx,int1);
     end;
    end;
    cp_bottom,cp_bottomleft,cp_bottomright: begin
     int1:= y - (fpaintrect.y + fpaintrect.cy);
     if int1 > 0 then begin
      dec(rect1.y,int1);
      inc(rect1.cy,int1);
     end;
    end;
    else; // Added to make compiler happy
   end;
  end;
  result:= pointinrect(point,rect1);
 end;
end;

procedure tcustomcaptionframe.updatemousestate(const sender: twidget;
        const info: mouseeventinfoty);
begin
 inherited;
 with twidget1(sender) do begin
  if not (ow_mousetransparent in foptionswidget) then begin
   if pointincaption(info.pos) then begin
    include(fwidgetstate,ws_wantmousebutton);    //for twidget.iswidgetclick
    if cfo_captionfocus in foptions then begin
     include(fwidgetstate,ws_wantmousefocus);
    end;
    if fs_captionhint in fstate then begin
     include(fwidgetstate,ws_wantmousemove);
    end;
   end;
   if (cfo_framerectfocus in foptions) and
             pointinrect(info.pos,framerect) then begin
    include(fwidgetstate,ws_wantmousefocus);
   end;
  end;
 end;
end;

function tcustomcaptionframe.getassistivecaption(): msestring;
begin
 result:= fcaption;
end;

procedure tcustomcaptionframe.scale(const ascale: real);
begin
 if ffont <> nil then begin
  ffont.scale(ascale);
 end;
 inherited;
end;

function tcustomcaptionframe.needsfocuspaint: boolean;
begin
 result:= (inherited needsfocuspaint or
            (ftemplate <> nil) and
               (fso_forcefocusrect in ftemplate.template.optionsskin)) and
     not (cfo_nofocusrect in foptions) and
     ((cfo_focusrect in foptions) or (ftemplate = nil) or
                       not (fso_nofocusrect in ftemplate.template.optionsskin));
 result:= result or (cfo_forcefocusrect in foptions);
 if result then begin
  if cfo_captionfocus in foptions then begin
   include(fstate,fs_captionfocus);
   exclude(fstate,fs_paintrectfocus);
  end
  else begin
   include(fstate,fs_paintrectfocus);
   exclude(fstate,fs_captionfocus);
  end;
 end;
end;

procedure tcustomcaptionframe.settemplateinfo(const ainfo: frameinfoty);
begin
 if not (frl1_font in flocalprops1) and (ainfo.capt.font <> nil) then begin
  createfont;
  ffont.assign(ainfo.capt.font);
  if not (frl1_captiondist in flocalprops1) then begin
   fcaptiondist:= ainfo.capt.captiondist;
  end;
  if not (frl1_captionoffset in flocalprops1) then begin
   fcaptionoffset:= ainfo.capt.captionoffset;
  end;
 end;
 inherited;
end;

{ tcustomscrollframe }

constructor tcustomscrollframe.create(const aintf: iscrollframe;
                                                const scrollintf: iscrollbar);
begin
 aintf.setstaticframe(true);
 foptionsscroll:= defaultoptionsscroll;
 fdragbuttons:= defaultdragbuttons;
 inherited create(aintf);
 fhorz:= getscrollbarclass(false).create(scrollintf,org_widget,
             {$ifdef FPC}@{$endif}updatestate);
 fvert:= getscrollbarclass(true).create(scrollintf,org_widget,
             {$ifdef FPC}@{$endif}updatestate);
 fvert.tag:= 1;
 fvert.direction:= gd_down;
end;

destructor tcustomscrollframe.destroy;
begin
 fhorz.Free;
 fvert.free;
 inherited;
end;

procedure tcustomscrollframe.checktemplate(const sender: tobject);
                 //true if match
begin
 inherited;
 fhorz.checktemplate(sender);
 fvert.checktemplate(sender);
end;

function tcustomscrollframe.getscrollbarclass(vert: boolean): framescrollbarclassty;
begin
 result:= tcustomscrollbar;
end;

procedure tcustomscrollframe.getpaintframe(var frame: framety);
begin
 with frame do begin
  if fs_sbleft in fstate then inc(left,fvert.width);
  if fs_sbtop in fstate then inc(top,fhorz.width);
  if fs_sbright in fstate then inc(right,fvert.width);
  if fs_sbbottom in fstate then inc(bottom,fhorz.width);
 end;
end;

procedure tcustomscrollframe.addscrollbarwidth(var asize: sizety);
begin
 with asize do begin
  if fs_sbleft in fstate then inc(cx,fvert.width);
  if fs_sbtop in fstate then inc(cy,fhorz.width);
  if fs_sbright in fstate then inc(cx,fvert.width);
  if fs_sbbottom in fstate then inc(cy,fhorz.width);
 end;
end;

procedure tcustomscrollframe.subscrollbarwidth(var asize: sizety);
begin
 with asize do begin
  if fs_sbleft in fstate then inc(cx,fvert.width);
  if fs_sbtop in fstate then inc(cy,fhorz.width);
  if fs_sbright in fstate then inc(cx,fvert.width);
  if fs_sbbottom in fstate then inc(cy,fhorz.width);
 end;
end;

procedure tcustomscrollframe.mouseevent(var info: mouseeventinfoty);
begin
{$push}
{$objectChecks off}   
 if not (ws_clientmousecaptured in iscrollframe(fintf).widgetstate) then begin
  if fs_sbhorzon in fstate then begin
   fhorz.mouseevent(info);
  end;
  if fs_sbverton in fstate then begin
   fvert.mouseevent(info);
  end;
 end;
{$pop}
end;

procedure tcustomscrollframe.domousewheelevent(var info: mousewheeleventinfoty;
                                const pagingreversed: boolean);
var
 scrollbar: tcustomscrollbar;
begin
 with info do begin
  if not (es_processed in eventstate) then begin
   scrollbar:= nil;
   if (fs_sbverton in fstate) and pointinrect(info.pos,sbvert.dim) then begin
    scrollbar:= sbvert;
   end
   else begin
    if (fs_sbhorzon in fstate) and pointinrect(info.pos,sbhorz.dim) then begin
     scrollbar:= sbhorz;
    end
    else begin
     if oscr_mousewheel in foptionsscroll then begin
      if (fs_sbverton in fstate) then begin
       scrollbar:= sbvert;
      end
      else begin
       if fs_sbhorzon in fstate then begin
        scrollbar:= sbhorz;
       end
       else begin
       end;
      end;
     end;
    end;
   end;
   if scrollbar <> nil then begin
    scrollbar.mousewheelevent(info,pagingreversed);
   end;
  end;
 end;
end;

procedure tcustomscrollframe.internalpaintoverlay(const canvas: tcanvas;
                                                         const arect: rectty);
begin
 inherited;
 if fs_sbverton in fstate then begin
  fvert.paint(canvas);
 end;
 if fs_sbhorzon in fstate then begin
  fhorz.paint(canvas);
 end;
end;

procedure tcustomscrollframe.updatemousestate(const sender: twidget;
         const info: mouseeventinfoty);
begin
 inherited;
 if (fs_sbverton in fstate) and fvert.wantmouseevent(info.pos) or
    (fs_sbhorzon in fstate) and fhorz.wantmouseevent(info.pos) then begin
  with twidget1(sender) do begin
   fwidgetstate:= (fwidgetstate - [ws_mouseinclient]) +
                      [ws_wantmousebutton,ws_wantmousemove];
  end;
 end;
end;

procedure tcustomscrollframe.updaterects;
var
 rect1: rectty;
 int1,int2: integer;

 procedure checkvert;
 begin
  with tcustomscrollbar1(fvert) do begin
   if findentstart < 0 then begin
    int1:= 0;
   end
   else begin
    if findentstart = 0 then begin
     int1:= fpaintframedelta.top;
    end
    else begin
     int1:= findentstart;
    end;
   end;
   if findentend < 0 then begin
    int2:= 0;
   end
   else begin
    if findentend = 0 then begin
     int2:= fpaintframedelta.bottom;
    end
    else begin
     int2:= findentend;
    end;
   end;
  end;
 end;

 procedure checkhorz;
 begin
  with tcustomscrollbar1(fhorz) do begin
   if findentstart < 0 then begin
    int1:= 0;
   end
   else begin
    if findentstart = 0 then begin
     int1:= fpaintframedelta.left;
    end
    else begin
     int1:= findentstart;
    end;
   end;
   if findentend < 0 then begin
    int2:= 0;
   end
   else begin
    if findentend = 0 then begin
     int2:= fpaintframedelta.right;
    end
    else begin
     int2:= findentend;
    end;
   end;
  end;
 end;

begin
 int1:= 0;
 int2:= 0;
 fstate:= fstate - [fs_sbleft,fs_sbtop,fs_sbright,fs_sbbottom];
 if fs_sbhorzon in fstate then begin
  if fs_sbhorztop in fstate then begin
   include(fstate,fs_sbtop);
  end
  else begin
   include(fstate,fs_sbbottom);
  end;
 end;
 if fs_sbverton in fstate then begin
  if fs_sbvertleft in fstate then begin
   include(fstate,fs_sbleft);
  end
  else begin
   include(fstate,fs_sbright);
  end;
 end;
 inherited;
 rect1:= inflaterect(fpaintrect,fpaintframedelta);
 with rect1 do begin
  if fs_sbleft in fstate then begin
   checkvert;
   with fvert do begin
    dim:= makerect(x,y+int1,width,cy-int1-int2);
   end;
  end;
  if fs_sbright in fstate then begin
   checkvert;
   with fvert do begin
    dim:= makerect(x + cx-width,y+int1,width,cy-int1-int2);
   end;
  end;
  if fs_sbtop in fstate then begin
   checkhorz;
   with fhorz do begin
    dim:= makerect(x+int1,y,cx-int1-int2,width);
   end;
  end;
  if fs_sbbottom in fstate then begin
   checkhorz;
   with fhorz do begin
    dim:= makerect(x+int1,y+cy-width,cx-int1-int2,width);
   end;
  end;
 end;
end;

procedure tcustomscrollframe.updatevisiblescrollbars;
begin
 updatebit({$ifdef FPC}longword{$else}longword{$endif}(fstate),ord(fs_sbhorztop),
                sbo_opposite in fhorz.options);
 updatebit({$ifdef FPC}longword{$else}longword{$endif}(fstate),ord(fs_sbvertleft),
                sbo_opposite in fvert.options);
 if sbo_show in fhorz.options then begin
  include(fstate,fs_sbhorzon);
 end
 else begin
  if not (sbo_showauto in fhorz.options) then begin
   exclude(fstate,fs_sbhorzon);
  end
  else begin
   if fhorz.pagesize = 1 then begin
    exclude(fstate,fs_sbhorzon);
   end
   else begin
    include(fstate,fs_sbhorzon);
   end;
  end;
 end;
 if sbo_show in fvert.options then begin
  include(fstate,fs_sbverton);
 end
 else begin
  if not (sbo_showauto in fvert.options) then begin
   exclude(fstate,fs_sbverton);
  end
  else begin
   if fvert.pagesize = 1 then begin
    exclude(fstate,fs_sbverton);
   end
   else begin
    include(fstate,fs_sbverton);
   end;
  end;
 end;
end;

procedure tcustomscrollframe.updatestate;
var
 statebefore: framestatesty;
begin
 statebefore:= fstate;
 updatevisiblescrollbars;
 inherited;
 if ({$ifdef FPC}longword{$else}longword{$endif}(statebefore) xor
     {$ifdef FPC}longword{$else}longword{$endif}(fstate)) and
     {$ifdef FPC}longword{$else}longword{$endif}(scrollbarframestates) <> 0 then begin
{$push}
{$objectChecks off}   
 iscrollframe(fintf).getwidget.invalidatewidget;
{$pop}
 end;
end;
{
function tcustomscrollframe.getsbhorz: tcustomscrollbar;
begin
 result:= fhorz;
end;
}
procedure tcustomscrollframe.setsbhorz(const Value: tcustomscrollbar);
begin
 fhorz.assign(Value);
end;
{
function tcustomscrollframe.getsbvert: tcustomscrollbar;
begin
 result:= fvert;
end;
}
procedure tcustomscrollframe.setsbvert(const Value: tcustomscrollbar);
begin
 fvert.assign(Value);
end;

procedure tcustomscrollframe.setdragbuttons(const avalue: shiftstatesty);
begin
 fdragbuttons:= avalue * buttonshiftstatesmask;
end;

procedure tcustomscrollframe.activechanged;
begin
 inherited;
 fvert.activechanged;
 fhorz.activechanged;
end;

procedure tcustomscrollframe.settemplateinfo(const ainfo: frameinfoty);
begin
 inherited;
 if not (frl1_colorglyph in flocalprops1) and
                          (ainfo.ba.colorglyph <> cl_default) then begin
  sbhorz.colorglyph:= ainfo.ba.colorglyph;
  sbvert.colorglyph:= ainfo.ba.colorglyph;
 end;
 if not (frl1_colorpattern in flocalprops1) and
                          (ainfo.ba.colorpattern <> cl_default) then begin
  sbhorz.colorpattern:= ainfo.ba.colorpattern;
  sbvert.colorpattern:= ainfo.ba.colorpattern;
 end;
end;

{ tcustomstepframe }

constructor tcustomstepframe.create(const aintf: icaptionframe;
  const stepintf: istepbar);
begin
 fstepintf:= stepintf;
 fbuttonsize:= defaultstepbuttonsize;
 fforceinvisiblebuttons:= [sk_first,sk_last];
 fcolorbutton:= cl_default;
 fcolorglyph:= cl_default;
 aintf.setstaticframe(true);
 fmousewheel:= true;
 frepeatedbutton:= -1;
 inherited create(aintf);
end;

destructor tcustomstepframe.destroy;
begin
 killrepeater;
 inherited;
 fbuttonface.free;
 fbuttonframe.free;
end;

procedure tcustomstepframe.killrepeater;
begin
 freeandnil(frepeater);
 frepeatedbutton:= -1;
end;

procedure tcustomstepframe.execute(const tag: integer;
                                      const info: mouseeventinfoty);
begin
 if @info = nil then begin
  fstepintf.dostep(stepkindty(tag),0,application.lastshiftstate);
 end
 else begin
  fstepintf.dostep(stepkindty(tag),0,info.shiftstate);
 end;
end;

procedure tcustomstepframe.getpaintframe(var frame: framety);
begin
 case fbuttonpos of
  sbp_right: begin
   inc(frame.right,fdim.cx);
  end;
  sbp_top: begin
   inc(frame.top,fdim.cy);
  end;
  sbp_left: begin
   inc(frame.left,fdim.cx);
  end;
  sbp_bottom: begin
   inc(frame.bottom,fdim.cy);
  end;
 end;
end;

procedure tcustomstepframe.layoutchanged;
var
 widget: twidget;
begin
{$push}
{$objectChecks off}   
 widget:= icaptionframe(fintf).getwidget;
 if not (csloading in widget.ComponentState) then begin
  updatestate;
  widget.invalidaterect(fdim,org_widget);
 end;
{$pop}
end;

procedure tcustomstepframe.dorepeat(const sender: tobject);
begin
 with tsimpletimer(sender) do begin
//  if interval < 0 then begin
  if singleshot then begin
   interval:= repeatrepeattime;
   enabled:= true;
  end;
  execute(frepeatedbutton,pmouseeventinfoty(nil)^);
 end;
end;

procedure tcustomstepframe.mouseevent(var info: mouseeventinfoty);
var
 int1: integer;
 clickedbutton: integer;
begin
 clickedbutton:= -1;
 for int1:= 0 to high(fbuttons) do begin
  if updatemouseshapestate(fbuttons[int1],info,nil,nil) then begin
  {$push}
{$objectChecks off}   
   icaptionframe(fintf).getwidget.invalidaterect(
                                 fbuttons[int1].ca.dim,org_widget);
 
{$pop}
   if info.eventkind in [ek_buttonpress,ek_buttonrelease] then begin
    include(info.eventstate,es_processed);
   end;
  end;
  if shs_clicked in fbuttons[int1].state then begin
   clickedbutton:= int1;
  end;
 end;
 if frepeatedbutton <> clickedbutton then begin
  killrepeater;
  if clickedbutton >= 0 then begin
   frepeatedbutton:= clickedbutton;
   frepeater:= tsimpletimer.create(repeatdelaytime,
               {$ifdef FPC}@{$endif}dorepeat,true,[to_single]);
  end;
 end;
end;

procedure tcustomstepframe.internalpaintoverlay(const canvas: tcanvas;
                                                         const arect: rectty);
var
 int1: integer;
 po1: pshapeinfoty;
begin
 inherited;
 for int1:= 0 to high(fbuttons) do begin
  factbuttonindex:= int1; //widgetstateflags for button frame
  po1:= @fbuttons[int1];
  po1^.face:= fbuttonface;
  po1^.frame:= fbuttonframe;
  drawtoolbutton(canvas,po1^);
 end;
end;

procedure tcustomstepframe.updatebuttonstate(const first,delta,count: integer);
var
 disabled: stepkindsty;
begin
 disabled:= [];
 if first = 0 then begin
  include(disabled,sk_left);
  include(disabled,sk_up);
  include(disabled,sk_first);
 end;
 if first+delta >= count then begin
  include(disabled,sk_right);
  include(disabled,sk_down);
  {
  if (frepeatedbutton >= 0) and
            (stepkindty(frepeatedbutton) in [sk_right,sk_down]) then begin
   killrepeater();
  end;
  }
 end;
 disabledbuttons:= disabled;
 if (first+delta >= count) and (first <= 0) then begin
  neededbuttons:= [];
//  invisiblebuttons:= [sk_right,sk_up,sk_left,sk_down];
 end
 else begin
  neededbuttons:= [sk_right,sk_up,sk_left,sk_down,sk_first,sk_last];
//  invisiblebuttons:= forceinvisiblebuttons;
 end;
end;

function tcustomstepframe.executestepevent(const event: stepkindty;
           const stepinfo: framestepinfoty; const aindex: integer): integer;
var
 steps: array[stepkindty] of integer;
begin
 with stepinfo do begin
  steps[sk_first]:= -bigint;
  steps[sk_last]:= pagelast;
  case fbuttonpos of
   sbp_right,sbp_left: begin
    steps[sk_right]:= 0;
    if not (sk_right in disabledbuttons) then begin
     steps[sk_right]:= up;
    end;
    steps[sk_left]:= down;
    steps[sk_up]:= pagedown;
    steps[sk_down]:= 0;
    if not (sk_down in disabledbuttons) then begin
     steps[sk_down]:= pageup;
    end;
   end;
   sbp_top: begin
    steps[sk_right]:= 0;
    if not (sk_down in disabledbuttons) then begin
     steps[sk_right]:= pageup;
    end;
    steps[sk_left]:= pagedown;
    steps[sk_up]:= down;
    steps[sk_down]:= 0;
    if not (sk_right in disabledbuttons) then begin
     steps[sk_down]:= up;
    end;
   end;
   else begin //sbp_bottom
    steps[sk_right]:= 0;
    if not (sk_down in disabledbuttons) then begin
     steps[sk_right]:= pageup;
    end;
    steps[sk_left]:= pagedown;
    steps[sk_up]:= down;
    steps[sk_down]:= 0;
    if not (sk_right in disabledbuttons) then begin
     steps[sk_down]:= up;
    end;
   end;
  end;
 end;
 result:= aindex + steps[event];
end;

procedure tcustomstepframe.setbuttonsize(const Value: integer);
begin
 if fbuttonsize <> value then begin
  fbuttonsize := Value;
  layoutchanged;
 end;
end;

procedure tcustomstepframe.setbuttonpos(const Value: stepbuttonposty);
begin
 if fbuttonpos <> value then begin
  fbuttonpos := Value;
  layoutchanged;
 end;
end;

procedure tcustomstepframe.setbuttonsinline(const Value: boolean);
begin
 if fbuttonsinline <> value then begin
  fbuttonsinline := Value;
  layoutchanged;
 end;
end;

procedure tcustomstepframe.setbuttonslast(const avalue: boolean);
begin
 if fbuttonslast <> avalue then begin
  fbuttonslast:= avalue;
  layoutchanged;
 end;
end;

procedure tcustomstepframe.setcolorbutton(const avalue: colorty);
begin
 if fcolorbutton <> avalue then begin
  fcolorbutton:= avalue;
  updatelayout;
{$push}
{$objectChecks off}   
  icaptionframe(fintf).getwidget.invalidaterect(fdim,org_widget);  
{$pop}

 end;
end;

procedure tcustomstepframe.setcolorglyph(const avalue: colorty);
begin
 if fcolorglyph <> avalue then begin
  fcolorglyph:= avalue;
  updatelayout;
{$push}
{$objectChecks off}   
  icaptionframe(fintf).getwidget.invalidaterect(fdim,org_widget);
{$pop}
 end;
end;

procedure tcustomstepframe.setdisabledbuttons(const avalue: stepkindsty);
begin
 if fdisabledbuttons <> avalue then begin
  fdisabledbuttons:= avalue;
  layoutchanged;
 end;
end;

procedure tcustomstepframe.setbuttonsinvisible(const avalue: stepkindsty);
begin
 if fforceinvisiblebuttons <> avalue then begin
  fforceinvisiblebuttons:= avalue;
  layoutchanged;
 end;
end;

procedure tcustomstepframe.setbuttonsvisible(const avalue: stepkindsty);
begin
 if fforcevisiblebuttons <> avalue then begin
  fforcevisiblebuttons:= avalue;
  layoutchanged;
 end;
end;

procedure tcustomstepframe.setneededbuttons(const avalue: stepkindsty);
begin
 if fneededbuttons <> avalue then begin
  fneededbuttons:= avalue;
  layoutchanged;
 end;
end;

type
 buttonarty = array[stepkindty] of stepkindty;
 buttonposarty = array[boolean,stepbuttonposty] of buttonarty;
const
 buttonposstep: buttonposarty =
    (
     (                                   //not fbuttonsinline
      (sk_left,sk_right,sk_up,sk_down,sk_first,sk_last,sk_none),  //sbp_right
      (sk_left,sk_up,sk_right,sk_down,sk_first,sk_last,sk_none),  //sbp_top
      (sk_left,sk_right,sk_up,sk_down,sk_first,sk_last,sk_none),  //sbp_left
      (sk_up,sk_left,sk_down,sk_right,sk_first,sk_last,sk_none)   //sbp_bottom
     ),
     (                                   //fbuttonsinline
      (sk_left,sk_right,sk_up,sk_down,sk_first,sk_last,sk_none),  //sbp_right
      (sk_up,sk_down,sk_left,sk_right,sk_first,sk_last,sk_none),  //sbp_top
      (sk_left,sk_right,sk_up,sk_down,sk_first,sk_last,sk_none),  //sbp_left
      (sk_up,sk_down,sk_left,sk_right,sk_first,sk_last,sk_none)   //sbp_bottom
     )
    );
 buttonposspin: buttonposarty =
    (
     (                                   //not fbuttonsinline
      (sk_left,sk_right,sk_up,sk_last,sk_down,sk_first,sk_none),  //sbp_right
      (sk_left,sk_up,sk_right,sk_down,sk_last,sk_first,sk_none),  //sbp_top
      (sk_left,sk_right,sk_up,sk_last,sk_down,sk_first,sk_none),  //sbp_left
      (sk_up,sk_left,sk_down,sk_right,sk_last,sk_first,sk_none)   //sbp_bottom
     ),
     (                                   //fbuttonsinline
      (sk_left,sk_right,sk_up,sk_down,sk_last,sk_first,sk_none),  //sbp_right
      (sk_up,sk_down,sk_left,sk_right,sk_first,sk_last,sk_none),  //sbp_top
      (sk_left,sk_right,sk_up,sk_down,sk_last,sk_first,sk_none),  //sbp_left
      (sk_up,sk_down,sk_left,sk_right,sk_first,sk_last,sk_none)   //sbp_bottom
     )
    );

 images: array[stepkindty] of stockglyphty =
  ( stg_arrowrightsmall,stg_arrowupsmall,stg_arrowleftsmall,stg_arrowdownsmall,
    stg_arrowfirstsmall,stg_arrowlastsmall,stg_none);
 imagesedit: array[stepkindty] of stockglyphty =
  ( stg_arrowrightsmall,stg_arrowupsmall,stg_arrowleftsmall,stg_arrowdownsmall,
    stg_arrowbottomsmall,stg_arrowtopsmall,stg_none);

procedure tcustomstepframe.updatelayout;
var
 buttoncount: integer;
 acx,acy: integer;
 ax,ay: integer;

 procedure checkbutton(button: stepkindty; vert: boolean);
 begin
  with fbuttons[ord(button)] do begin
   if button in fdisabledbuttons then begin
    include(state,shs_disabled);
   end
   else begin
    exclude(state,shs_disabled);
   end;
   if (button in fforcevisiblebuttons) or
        not (button in fforceinvisiblebuttons) and (button in fneededbuttons) then begin
    inc(buttoncount);
    ca.dim.x:= ax;
    ca.dim.y:= ay;
    if vert then begin
     inc(ay,acy);
    end
    else begin
     inc(ax,acx);
    end;
   end;
  end;
 end;

var
 a,b: integer;
 int1: integer;
 akind: stepkindty;
 bo1: boolean;
 bo2: boolean;
 color1: colorty;
 buttonpos1: ^buttonposarty;

begin             //updatelayout
 if sfs_spinedit in fstepstate then begin
  buttonpos1:= @buttonposspin;
 end
 else begin
  buttonpos1:= @buttonposstep;
 end;

// setlength(fbuttons,ord(high(stepkindty)) + 1);
 setlength(fbuttons,ord(high(stepkindty)));
 buttoncount:= 0;
 a:= 0; //compilerwarning
 b:= 0; //compilerwarning
// for akind:= low(stepkindty) to high(stepkindty) do begin
 for akind:= low(stepkindty) to sk_last do begin

//  if not (akind in finvisiblebuttons) or (akind in fvisiblebuttons) then begin
  if (akind in fforcevisiblebuttons) or
        not (akind in fforceinvisiblebuttons) and (akind in fneededbuttons) then begin
   inc(buttoncount);
   exclude(fbuttons[ord(akind)].state,shs_invisible);
  end
  else begin
   include(fbuttons[ord(akind)].state,shs_invisible);
  end;
 end;
 if buttoncount = 0 then begin
  fdim.cx:= 0;
  fdim.cy:= 0;
 end
 else begin
  if not fbuttonsinline then begin
   a:= (buttoncount + 1) div 2;
   b:= (buttoncount + a - 1) div a;
   bo2:= a > 1;
  end
  else begin
   bo2:= false;
  end;
  if not bo2 then begin
   a:= buttoncount;
   b:= 1;
  end;
  if fbuttonpos in [sbp_left,sbp_right] then begin
   acy:= fpaintrect.cy div a;
   if acy > fbuttonsize then begin
    acy:= fbuttonsize;
   end;
   if fbuttonslast then begin
    ay:= fpaintrect.y + fpaintrect.cy - a * acy;
   end
   else begin
    ay:= fpaintrect.y;
   end;
   acx:= fbuttonsize;
   if fbuttonpos = sbp_left then begin
    ax:= fpaintrect.x - acx * b;
   end
   else begin
    ax:= fpaintrect.x + fpaintrect.cx;
   end;
  end
  else begin
   acx:= fpaintrect.cx div a;
   if acx > fbuttonsize then begin
    acx:= fbuttonsize;
   end;
   if fbuttonslast then begin
    ax:= fpaintrect.x;
   end
   else begin
    ax:= fpaintrect.x + fpaintrect.cx - a * acx;
   end;
   acy:= fbuttonsize;
   if fbuttonpos = sbp_top then begin
    ay:= fpaintrect.y - acy * b;
   end
   else begin
    ay:= fpaintrect.y + fpaintrect.cy;
   end;
  end;
  color1:= fcolorbutton;
  if (color1 = cl_parent) or (color1 = cl_default) then begin
{$push}
{$objectChecks off}   
  
   color1:= icaptionframe(fintf).getwidget.actualcolor;

{$pop}
  end;
  for int1:= 0 to high(fbuttons) do begin
   with fbuttons[int1] do begin
    ca.imagelist:= stockobjects.glyphs;
    if sfs_spinedit in fstepstate then begin
     ca.imagenr:= ord(imagesedit[stepkindty(int1)]);
    end
    else begin
     ca.imagenr:= ord(images[stepkindty(int1)]);
    end;
    imagenrdisabled:= -2;
    color:= color1;
    ca.colorglyph:= fcolorglyph;
    tag:= int1;
    doexecute:= {$ifdef FPC}@{$endif}execute;
    ca.dim.cx:= acx;
    ca.dim.cy:= acy;
   end;
  end;
  fdim.x:= ax;
  fdim.y:= ay;
  bo1:= fbuttonpos in [sbp_left,sbp_right];
  buttoncount:= 0;
 // for akind:= low(stepkindty) to high(stepkindty) do begin
   for akind:= low(stepkindty) to sk_last do begin
   if bo2 then begin
    if not odd(buttoncount) and (akind <> low(stepkindty)) then begin
     if bo1 then begin
      ax:= fdim.x;
     end
     else begin
      ay:= fdim.y;
     end;
    end;
     checkbutton(buttonpos1^[fbuttonsinline][fbuttonpos][akind],not odd(buttoncount) xor bo1);
   end
   else begin
    checkbutton(buttonpos1^[fbuttonsinline][fbuttonpos][akind],bo1);
   end;
  end;
  if bo1 then begin  //left or right
   fdim.cx:= acx * b;
   fdim.cy:= acy * a;
  end
  else begin
   fdim.cx:= acx * a;
   fdim.cy:= acy * b;
  end;
 end;
 if (buttoncount > 0) or (fneededbuttons <> []) then begin
  include(fstepstate,sfs_canstep);
 end
 else begin
  exclude(fstepstate,sfs_canstep);
 end;
end;

procedure tcustomstepframe.updaterects;
begin
 updatelayout;
 inherited;
 updatelayout;
end;

procedure tcustomstepframe.updatemousestate(const sender: twidget;
                      const info: mouseeventinfoty);
begin
 inherited;
 if pointinrect(info.pos,fdim) then begin
  with twidget1(sender) do begin
   fwidgetstate:= fwidgetstate + [ws_wantmousebutton,ws_wantmousemove];
  end;
 end;
end;

const
 stepdirstep: array[stepbuttonposty,boolean] of stepkindty =
                  //down     //up
             ((sk_down,        sk_up),          //sbp_right
              (sk_right,      sk_left),       //sbp_top
              (sk_down,        sk_up),          //sbp_left
              (sk_right,      sk_left));      //sbp_bottom
 stepdirspin: array[boolean] of stepkindty = (sk_down,sk_up);

procedure tcustomstepframe.domousewheelevent(var info: mousewheeleventinfoty);
var
 sk1: stepkindty;
begin
 if fmousewheel and (info.wheel <> mw_none) and
                       not (es_transientfor in info.eventstate)then begin
  if sfs_spinedit in fstepstate then begin
   sk1:= stepdirspin[info.wheel = mw_up];
  end
  else begin
   if fneededbuttons = [] then begin
    exit;
   end;
   sk1:= stepdirstep[fbuttonpos][info.wheel = mw_up]
  end;
  if canstep and fstepintf.dostep(sk1,info.delta,info.shiftstate) then begin
   include(info.eventstate,es_processed);
  end;
 end;
end;

procedure tcustomstepframe.createbuttonface;
begin
 if fbuttonface = nil then begin
  fbuttonface:= tface.create(iface(fintf.getwidget));
 end;
end;

procedure tcustomstepframe.createbuttonframe;
begin
 if fbuttonframe = nil then begin
  fbuttonframe:= tframe.create(iframe(self));
 end;
end;

function tcustomstepframe.getbuttonface: tface;
begin
 fintf.getwidget.getoptionalobject(fbuttonface,
                               {$ifdef FPC}@{$endif}createbuttonface);
 result:= fbuttonface;
end;

procedure tcustomstepframe.setbuttonface(const avalue: tface);
begin
 fintf.getwidget.setoptionalobject(avalue,fbuttonface,
                               {$ifdef FPC}@{$endif}createbuttonface);
 fintf.invalidatewidget;
end;

function tcustomstepframe.getbuttonframe: tframe;
begin
 fintf.getwidget.getoptionalobject(fbuttonframe,
                               {$ifdef FPC}@{$endif}createbuttonframe);
 result:= fbuttonframe;
end;

procedure tcustomstepframe.setbuttonframe(const avalue: tframe);
var
 int1: integer;
begin
 fintf.getwidget.setoptionalobject(avalue,fbuttonframe,
                               {$ifdef FPC}@{$endif}createbuttonframe);
 if fbuttonframe = nil then begin
  for int1:= 0 to high(fbuttons) do begin
   with fbuttons[int1] do begin
    state:= state - [shs_flat,shs_noanimation];
   end;
  end;
 end;
 fintf.invalidatewidget;
end;

procedure tcustomstepframe.checktemplate(const sender: tobject);
begin
 inherited;
 if fbuttonface <> nil then begin
  fbuttonface.checktemplate(sender);
 end;
 if fbuttonframe <> nil then begin
  fbuttonframe.checktemplate(sender);
 end;
end;

procedure tcustomstepframe.setframeinstance(instance: tcustomframe);
begin
 fbuttonframe:= tframe(instance);
end;

procedure tcustomstepframe.setstaticframe(value: boolean);
begin
 //dummy
end;

function tcustomstepframe.getstaticframe: boolean;
begin
 result:= false;
end;

function tcustomstepframe.getwidgetrect: rectty;
begin
 result:= nullrect;
end;

function tcustomstepframe.getcomponentstate: tcomponentstate;
begin
 result:= fintf.getwidget.componentstate;
end;

function tcustomstepframe.getmsecomponentstate: msecomponentstatesty;
begin
 result:= fintf.getwidget.msecomponentstate;
end;

procedure tcustomstepframe.scrollwidgets(const dist: pointty);
begin
 //dummy
end;

procedure tcustomstepframe.clientrectchanged;
begin
 fintf.invalidatewidget;
end;

procedure tcustomstepframe.invalidate;
begin
 fintf.getwidget.invalidaterect(fdim,org_widget);
end;

procedure tcustomstepframe.invalidatewidget;
begin
 fintf.invalidatewidget;
end;

procedure tcustomstepframe.invalidaterect(const rect: rectty;
               const org: originty = org_client; const noclip: boolean = false);
begin
 fintf.getwidget.invalidaterect(rect,org,noclip);
end;

function tcustomstepframe.getwidget: twidget;
begin
 result:= fintf.getwidget
end;

function tcustomstepframe.getframestateflags: framestateflagsty;
begin
 result:= shapestatetoframestate(factbuttonindex,fbuttons);
end;

function tcustomstepframe.canstep: boolean;
begin
 result:= sfs_canstep in fstepstate;
end;

{ tscrollboxscrollbar }

constructor tscrollboxscrollbar.create(intf: iscrollbar; org: originty;
  ondimchanged: proceventty);
begin
 inherited;
 foptions:= defaultscrollboxscrollbaroptions;
end;

{ tthumbtrackscrollbar }

constructor tthumbtrackscrollbar.create(intf: iscrollbar; org: originty;
  ondimchanged: proceventty);
begin
 inherited;
 foptions:= defaultthumbtrackscrollbaroptions;
end;

{ tthumbtracknopagesizescrollbar }

constructor tthumbtracknopagesizescrollbar.create(intf: iscrollbar; org: originty;
  ondimchanged: proceventty);
begin
 inherited;
 foptions:= defaultthumbtrackscrollbaroptions;
end;

{ tcustomscrollboxframe }

constructor tcustomscrollboxframe.create(const aintf: iscrollframe;
                                                      const owner: twidget);
begin
 fzoom.re:= 1;
 fzoom.im:= 1;
 fzoomwidthstep:= 1;
 fzoomheightstep:= 1;
// fzoomwheelsensitivity:= 1;
 fowner:= owner;
 inherited create(aintf,iscrollbox(self));
 fstate:= fstate+ [fs_canclientextendx,fs_canclientextendy];
 initinnerframe;
 internalupdatestate;
// options:= defaultscrolloptions;
end;

procedure tcustomscrollboxframe.initinnerframe;
begin
 fi.innerframe.left:= 2;
 fi.innerframe.top:= 2;
 fi.innerframe.right:= 2;
 fi.innerframe.bottom:= 2;
end;

procedure tcustomscrollboxframe.clientrecttoscrollbar(const rect: rectty);
var
 int1: integer;
begin
 inc(fscrolling);
 with rect do begin
  if fstate * [fs_sbhorzon,fs_sbhorzfix] = [fs_sbhorzon] then begin
   if cx = 0 then begin
    fhorz.pagesize:= 1;
   end
   else begin
    fhorz.pagesize:= fpaintrect.cx/cx;
   end;
   int1:= cx - fpaintrect.cx;
   if int1 = 0 then begin
    fhorz.value:= 0;
   end
   else begin
    fhorz.value:= ({fpaintrect.x}-x)/int1;
   end;
  end;
  if fstate * [fs_sbverton,fs_sbvertfix] = [fs_sbverton] then begin
   if cy = 0 then begin
    fvert.pagesize:= 1;
   end
   else begin
    fvert.pagesize:= fpaintrect.cy/cy;
   end;
   int1:= cy - fpaintrect.cy;
   if int1 = 0 then begin
    fvert.value:= 0;
   end
   else begin
    fvert.value:= ({fpaintrect.y}-y)/int1;
   end;
  end;
 end;
 dec(fscrolling);
end;

procedure tcustomscrollboxframe.scrollpostoclientpos(var aclientrect: rectty);
begin
 with aclientrect do begin
  x:= - round(fhorz.value * (cx-fpaintrect.cx));
  y:= - round(fvert.value * (cy-fpaintrect.cy));
//  inc(x,fpaintrect.x);
//  inc(y,fpaintrect.y);
 end;
end;

procedure tcustomscrollboxframe.updatevisiblescrollbars;
begin
 updatebit({$ifdef FPC}longword{$else}longword{$endif}(fstate),
             ord(fs_sbhorztop),sbo_opposite in fhorz.options);
 updatebit({$ifdef FPC}longword{$else}longword{$endif}(fstate),
             ord(fs_sbvertleft),sbo_opposite in fvert.options);
 updatebit({$ifdef FPC}longword{$else}longword{$endif}(fstate),
             ord(fs_sbhorzon),sbo_show in fhorz.options);
 updatebit({$ifdef FPC}longword{$else}longword{$endif}(fstate),
             ord(fs_sbverton),sbo_show in fvert.options);
end;

function tcustomscrollboxframe.getwidget: twidget;
begin
 result:= fowner;
end;

procedure tcustomscrollboxframe.calcclientrect(var aclientrect: rectty);

var
 asize: sizety;
 statebefore: framestatesty;
 int1: integer;

begin
 updatevisiblescrollbars;
 updaterects;
 inc(fscrolling);
 int1:= 0;
 repeat
  statebefore:= fstate;
  asize:= twidget1(fowner).calcminscrollsize;
  with asize do begin
   if fclientsize.cx <> 0 then begin
    cx:= fclientsize.cx;
   end;
   if fclientsize.cy <> 0 then begin
    cy:= fclientsize.cy;
   end;
   if sbo_showauto in fhorz.options then begin
    if cx > fpaintrect.cx then begin
     include(fstate,fs_sbhorzon);
    end
    else begin
     exclude(fstate,fs_sbhorzon);
     fhorz.value:= 0;
    end;
   end;
   if sbo_showauto in fvert.options then begin
    if cy > fpaintrect.cy then begin
     include(fstate,fs_sbverton);
    end
    else begin
     exclude(fstate,fs_sbverton);
     fvert.value:= 0;
    end;
   end;
  end;
  if state = statebefore then begin
   break;
  end;
  updaterects;
  inc(int1);
 until int1 > 16; //emergency brake
 dec(fscrolling);

 aclientrect.size:= asize;
 with aclientrect.size do begin
  if cx < fpaintrect.cx then begin
   cx:= fpaintrect.cx;
  end;
  if cy < fpaintrect.cy then begin
   cy:= fpaintrect.cy;
  end;
  int1:= fpaintrect.cx {+ fpaintrect.x} - aclientrect.cx - aclientrect.x;
  if int1 > 0 then begin
   inc(aclientrect.x,int1);
  end;
  int1:= fpaintrect.cy {+ fpaintrect.y} - aclientrect.cy - aclientrect.y;
  if int1 > 0 then begin
   inc(aclientrect.y,int1);
  end;
 end;
 clientrecttoscrollbar(aclientrect);
end;

procedure tcustomscrollboxframe.updateclientrect;
var
 rect1: rectty;
begin
 rect1:= fclientrect;
 calcclientrect(fclientrect);
 finnerclientrect:= deflaterect(fclientrect,fi.innerframe);
 twidget1(fowner).scroll(subpoint(fclientrect.pos,rect1.pos));
 if (rect1.cx <> fclientrect.cx) or (rect1.cy <> fclientrect.cy) then begin
  twidget1(fowner).clientrectchanged;
 end;
end;

function tcustomscrollboxframe.getclientpos: pointty;
begin
 checkstate;
 result:= fclientrect.pos;
end;

procedure tcustomscrollboxframe.setclientpos(apos: pointty);
var
 pt1: pointty;
begin
 if apos.x + fclientrect.cx < fpaintrect.cx then begin
  apos.x:= fpaintrect.cx-fclientrect.cx;
 end;
 if apos.y + fclientrect.cy < fpaintrect.cy then begin
  apos.y:= fpaintrect.cy-fclientrect.cy;
 end;
 if apos.x > 0 then begin
  apos.x:= 0;
 end;
 if apos.y > 0 then begin
  apos.y:= 0;
 end;
 pt1:= subpoint(apos,fclientrect.pos);
// twidget1(fowner).scroll(pt1);
 fclientrect.pos:= apos;
 addpoint1(finnerclientrect.pos,pt1);
 twidget1(fowner).scroll(pt1);
end;

procedure tcustomscrollboxframe.setscrollpos(apos: pointty);
begin
 setclientpos(apos);
 clientrecttoscrollbar(fclientrect);
end;

procedure tcustomscrollboxframe.scrollevent(sender: tcustomscrollbar;
                  event: scrolleventty);
var
 rect1: rectty;
begin
 if fscrolling = 0 then begin
  if event = sbe_setvalue{valuechanged} then begin
   rect1:= fclientrect;
   scrollpostoclientpos(rect1);
   setclientpos(rect1.pos);
{
   po1:= fclientrect.pos;
   scrollpostoclientpos(fclientrect);
   po1:= subpoint(fclientrect.pos,po1);
   addpoint1(finnerclientrect.pos,po1);
   twidget1(fowner).scroll(po1);
}
  end;
 end;
end;

procedure tcustomscrollboxframe.dokeydown(var info: keyeventinfoty);
begin
 with info do begin
  if (oscr_key in foptionsscroll) and not (es_processed in info.eventstate) and
           (((shiftstate * shiftstatesmask) - [ss_ctrl]) = []) then begin
   include(eventstate,es_processed);
   case key of
    key_pageup: begin
     if ss_ctrl in shiftstate then begin
      fvert.value:= 0;
     end
     else begin
      fvert.pagedown;
     end;
    end;
    key_pagedown: begin
     if ss_ctrl in shiftstate then begin
      fvert.value:= 1;
     end
     else begin
      fvert.pageup;
     end;
    end;
    else begin
     exclude(eventstate,es_processed);
    end;
   end;
   if ss_ctrl in shiftstate then begin
    include(eventstate,es_processed);
    case key of
     key_right: begin
      fhorz.stepup;
     end;
     key_left: begin
      fhorz.stepdown;
     end;
     key_down: begin
      fvert.stepup;
     end;
     key_up: begin
      fvert.stepdown;
     end;
     else begin
      exclude(eventstate,es_processed);
     end;
    end;
   end;
  end;
 end;
end;

function tcustomscrollboxframe.translatecolor(const acolor: colorty): colorty;
begin
 result:= fowner.translatecolor(acolor);
end;

procedure tcustomscrollboxframe.invalidaterect(const rect: rectty;
                 const org: originty; const noclip: boolean = false);
begin
 fowner.invalidaterect(rect,org,noclip);
end;

function tcustomscrollboxframe.getscrollsize: sizety;
begin
 checkstate;
 result:= fclientrect.size;
end;

procedure tcustomscrollboxframe.setclientsize(const avalue: sizety);
begin
 if (fclientsize.cx <> avalue.cx) or (fclientsize.cy <> avalue.cy) then begin
  fclientsize:= avalue;
  if fclientsize.cx < 0 then begin
   fclientsize.cx:= 0;
  end;
  if fclientsize.cy < 0 then begin
   fclientsize.cy:= 0;
  end;
  internalupdatestate;
 end;
end;

procedure tcustomscrollboxframe.setclientwidth(const avalue: integer);
begin
 setclientsize(ms(avalue,fclientsize.cy));
end;

procedure tcustomscrollboxframe.setclientheight(const avalue: integer);
begin
 setclientsize(ms(fclientsize.cx,avalue));
end;

procedure tcustomscrollboxframe.setclientsizemin(const avalue: sizety);
begin
 if (fclientsizemin.cx <> avalue.cx) or
                             (fclientsizemin.cy <> avalue.cy) then begin
  fclientsizemin:= avalue;
  if fclientsizemin.cx < 0 then begin
   fclientsizemin.cx:= 0;
  end;
  if fclientsizemin.cy < 0 then begin
   fclientsizemin.cy:= 0;
  end;
  internalupdatestate;
 end;
end;

procedure tcustomscrollboxframe.setclientwidthmin(const avalue: integer);
begin
 setclientsizemin(ms(avalue,fclientsizemin.cy));
end;

procedure tcustomscrollboxframe.setclientheightmin(const avalue: integer);
begin
 setclientsizemin(ms(fclientsizemin.cx,avalue));
end;

procedure tcustomscrollboxframe.showrect(const arect: rectty;
                                     const bottomright: boolean);
var
 scrollvalue: pointty;
// po1: pointty;
 int1: integer;

 procedure adjuststart;
 begin
  int1:= fclientrect.x + scrollvalue.x + arect.x;
  if int1 < 0 then begin
   dec(scrollvalue.x,int1);
  end;
  int1:= fclientrect.x + scrollvalue.x;
  if int1 > 0 then begin
   dec(scrollvalue.x,int1);
  end;
  int1:= fclientrect.y + scrollvalue.y + arect.y;
  if int1 < 0 then begin
   dec(scrollvalue.y,int1);
  end;
  int1:= fclientrect.y + scrollvalue.y;
  if int1 > 0 then begin
   dec(scrollvalue.y,int1);
  end;
 end;

 procedure adjustend;
 begin
  int1:= fclientrect.x + scrollvalue.x + arect.x + arect.cx - fpaintrect.cx;
  if int1 > 0 then begin
   dec(scrollvalue.x,int1);
  end;
  int1:= fclientrect.x + scrollvalue.x + fclientrect.cx - fpaintrect.cx;
  if int1 < 0 then begin
   dec(scrollvalue.x,int1);
  end;
  int1:= fclientrect.y + scrollvalue.y + arect.y + arect.cy - fpaintrect.cy;
  if int1 > 0 then begin
   dec(scrollvalue.y,int1);
  end;
  int1:= fclientrect.y + scrollvalue.y + fclientrect.cy - fpaintrect.cy;
  if int1 < 0 then begin
   dec(scrollvalue.y,int1);
  end;
 end;

begin
 scrollvalue:= nullpoint;
 checkstate;
// po1:= addpoint(fclientrect.pos,arect.pos);
 if bottomright then begin
  adjuststart;
  adjustend;
 end
 else begin
  adjustend;
  adjuststart;
 end;
 if (scrollvalue.y <> 0) or (scrollvalue.x <> 0) then begin
  addpoint1(fclientrect.pos,scrollvalue);
  addpoint1(finnerclientrect.pos,scrollvalue);
  twidget1(fowner).scroll(scrollvalue);
  clientrecttoscrollbar(fclientrect);
 end;
end;

function tcustomscrollboxframe.getscrollbarclass(
                             vert: boolean): framescrollbarclassty;
begin
 result:= tscrollboxscrollbar;
end;

procedure tcustomscrollboxframe.setsbhorz(const avalue: tscrollboxscrollbar);
begin
 inherited setsbhorz(avalue);
end;

function tcustomscrollboxframe.getsbhorz: tscrollboxscrollbar;
begin
 result:= tscrollboxscrollbar(inherited sbhorz);
end;

procedure tcustomscrollboxframe.setsbvert(const avalue: tscrollboxscrollbar);
begin
 inherited setsbvert(avalue);
end;

function tcustomscrollboxframe.getsbvert: tscrollboxscrollbar;
begin
 result:= tscrollboxscrollbar(inherited sbvert);
end;

procedure tcustomscrollboxframe.updatemousestate(const sender: twidget;
               const info: mouseeventinfoty);
begin
 inherited;
 with twidget1(sender) do begin
  if fdragging then begin
   fwidgetstate:= fwidgetstate + [ws_wantmousemove,ws_wantmousebutton];
  end
  else begin
   if (oscr_drag in foptionsscroll) and isdragstart(sender,info) then begin
    include(fwidgetstate,ws_wantmousebutton);
   end;
  end;
 end;
end;

procedure tcustomscrollboxframe.childmouseevent(const sender: twidget;
                                var info: mouseeventinfoty);
var
 po1: pointty;
begin
 with info do begin
  if not (es_processed in eventstate) then begin
   po1:= translatewidgetpoint(pos,sender,fowner);
   if fdragging then begin
    case eventkind of
     ek_mouseleave,ek_buttonrelease: begin
      application.cursorshape:= cr_default;
      fowner.releasemouse;
      fdragging:= false;
      include(eventstate,es_processed);
     end;
     ek_mousemove: begin
      showrect(makerect(subpoint(subpoint(fpickpos,po1),fpickref),
                             fclientrect.size),false);
      include(eventstate,es_processed);
    end;
    else;
    end;
   end
   else begin
    if isdragstart(sender,info) then begin
     fowner.capturemouse;
     fpickpos:= po1;
     fpickref:= fclientrect.pos;
     application.cursorshape:= cr_sizeall;
     fdragging:= true;
     include(eventstate,es_processed);
    end;
   end;
  end;
 end;
end;

function tcustomscrollboxframe.isdragstart(const sender: twidget;
                             const info: mouseeventinfoty): boolean;
var
 ss1: shiftstatesty;
begin
 with info do begin
  ss1:= (shiftstate*buttonshiftstatesmask)*fdragbuttons;
  result:= (oscr_drag in foptionsscroll) and
            (eventkind = ek_buttonpress) and (ss1 <> []) and
             pointinrect(translatewidgetpoint(pos,sender,fowner),fpaintrect) and
               ((fclientrect.cx <> fpaintrect.cx) or
                     (fclientrect.cy <> fpaintrect.cy));
 end;
 if result and not ((ss1 = [ss_middle]) or (sender = fowner)) then begin
  twidget1(sender).updatemousestate(info);
  result:= not (ws_wantmousebutton in twidget1(sender).fwidgetstate);
 end;
end;

procedure tcustomscrollboxframe.checkminscrollsize(var asize: sizety);
begin
 inherited;
 if (clientwidthmin > 0) and (clientwidthmin > asize.cx) then begin
  asize.cx:= clientwidthmin;
 end;
 if (clientheightmin > 0) and (clientheightmin > asize.cy) then begin
  asize.cy:= clientheightmin;
 end;
end;

procedure tcustomscrollboxframe.checkminclientsize(var asize: sizety);
begin
 if clientwidth <> 0 then begin
  asize.cx:= clientwidth;
 end;
 if clientheight <> 0 then begin
  asize.cy:= clientheight;
 end;
 inherited;
end;

procedure tcustomscrollboxframe.setzoom1(const avalue: complexty);
var
 size1: sizety;
begin
 fzoom:= avalue;
 if fzoom.re < 1 then begin
  fzoom.re:= 1;
 end;
 if fzoom.im < 1 then begin
  fzoom.im:= 1;
 end;
 checkstate;
 size1:= nullsize;
 with fpaintframedelta do begin
  if avalue.re > 1 then begin
   size1.cx:= round((fpaintrect.cx+left+right)*avalue.re);
                                        //do not use scrollbarwidth
  end;
  if avalue.im > 1 then begin
   size1.cy:= round((fpaintrect.cy+top+bottom)*avalue.im);
                                        //do not use scrollbarwidth
  end;
 end;
 fclientsize:= size1;
end;

procedure tcustomscrollboxframe.setzoom(const avalue: complexty);
begin
 setzoom1(avalue);
 internalupdatestate;
end;

procedure tcustomscrollboxframe.setzoomwidth(const avalue: real);
begin
 setzoom(makecomplex(avalue,fzoom.im));
end;

procedure tcustomscrollboxframe.setzoomheight(const avalue: real);
begin
 setzoom(makecomplex(fzoom.re,avalue));
end;

function tcustomscrollboxframe.getscrollpos_x: integer;
begin
 result:= getclientpos.x;
end;

procedure tcustomscrollboxframe.setscrollpos_x(const avalue: integer);
begin
 setscrollpos(makepoint(avalue,getclientpos.y));
end;

function tcustomscrollboxframe.getscrollpos_y: integer;
begin
 result:= getclientpos.y;
end;

procedure tcustomscrollboxframe.setscrollpos_y(const avalue: integer);
begin
 setscrollpos(makepoint(getclientpos.x,avalue));
end;

procedure tcustomscrollboxframe.domousewheelevent(var info: mousewheeleventinfoty;
               const pagingreversed: boolean);
var
 size1: sizety;
 pt1,pt2: pointty;
 co1: complexty;
 bo1: boolean;
 ma1: shiftstatesty;
 rea1: real;
 fra1: framety;
begin
 with info do begin
  if not (es_processed in eventstate) then begin
   if (oscr_mousewheel in foptionsscroll) and (ss_ctrl in shiftstate) and
             (foptionsscroll*[oscr_zoomwidth,oscr_zoomheight] <> []) then begin
    ma1:= shiftstatesmask - [ss_ctrl];
    if foptionsscroll*[oscr_zoomwidth,oscr_zoomheight] =
                              [oscr_zoomwidth,oscr_zoomheight] then begin
     ma1:= ma1 - [ss_alt,ss_shift];
    end;
    if shiftstate * ma1 = [] then begin
     include(eventstate,es_processed);
     size1:= fclientrect.size;
     co1:= fzoom;
     bo1:= false;
     rea1:= 1 + (abs(delta) - application.mousewheeldeltamin)*
               fzoomwheelsensitivity*application.mousewheeldeltamin;
     if (fzoomwidthstep <> 1) and (fzoomwidthstep > 0) and
                          (oscr_zoomwidth in foptionsscroll) and
          not (ss_shift in shiftstate) then begin
      bo1:= true;
      if wheel = mw_down then begin
       co1.re:= zoomwidth / (fzoomwidthstep*rea1);
      end
      else begin
       co1.re:= zoomwidth * (fzoomwidthstep*rea1);
      end;
     end;
     if (fzoomheightstep <> 1) and (fzoomheightstep > 0) and
                          (oscr_zoomheight in foptionsscroll) and
                                  not (ss_alt in shiftstate) then begin
      bo1:= true;
      if wheel = mw_down then begin
       co1.im:= zoomheight / (fzoomheightstep*rea1);
      end
      else begin
       co1.im:= zoomheight * (fzoomheightstep*rea1);
      end;
     end;
     if bo1 then begin
      setzoom1(co1);
      pt1:= fclientrect.pos;
{$push}
{$objectChecks off}   
      
      fra1:= iscrollframe(fintf).getzoomrefframe;

{$pop}
      with fra1 do begin
       size1.cx:= size1.cx - left - right;
       size1.cy:= size1.cy - top - bottom;
       if size1.cx > 0 then begin
        pt1.x:= info.pos.x - fpaintrect.x - left -
        round((info.pos.x - fpaintrect.x - fclientrect.x - left)*
          (fclientsize.cx-left-right)/size1.cx);
       end;
       if size1.cy > 0 then begin
        pt1.y:= info.pos.y - fpaintrect.y - top -
        round((info.pos.y - fpaintrect.y - fclientrect.y - top)*
                (fclientsize.cy-top-bottom)/size1.cy);
       end;
      end;
    {
      pt1:= nullpoint;
      with pt2 do begin
       x:= info.pos.x-fpaintrect.x;
       if x < 0 then begin
        x:= 0;
       end;
       if x > fpaintrect.cx then begin
        x:= fpaintrect.cx;
       end;
       x:= x - fclientrect.x;
       y:= info.pos.y-fpaintrect.y;
       if y < 0 then begin
        y:= 0;
       end;
       if y > fpaintrect.cy then begin
        y:= fpaintrect.cy;
       end;
       y:= y - fclientrect.y;
      end;
      if (size1.cx > 0) and (fclientsize.cx > 0) then begin
       pt1.x:= -round(pt2.x*((fclientsize.cx/size1.cx)-1.0));
      end;
      if (size1.cy > 0) and (fclientsize.cy > 0) then begin
       pt1.y:= -round(pt2.y*((fclientsize.cy/size1.cy)-1.0));
      end;
//      setscrollpos(addpoint(fclientrect.pos,pt1));
}
      pt2:= fclientrect.pos;
      fclientrect.pos:= pt1;
      if fclientrect.x > 0 then begin
       fclientrect.x:= 0;
      end;
      if fclientrect.y > 0 then begin
       fclientrect.y:= 0;
      end;
      fowner.scrollwidgets(subpoint(fclientrect.pos,pt2));
      internalupdatestate;
     end;
    end;
   end
   else begin
    inherited;
   end;
  end;
 end;
end;

procedure tcustomscrollboxframe.readzoomwidthstep(reader: treader);
begin
 zoomwidthstep:= reader.readfloat;
end;

procedure tcustomscrollboxframe.writezoomwidthstep(writer: twriter);
begin
 writer.writefloat(zoomwidthstep);
end;

procedure tcustomscrollboxframe.readzoomheightstep(reader: treader);
begin
 zoomheightstep:= reader.readfloat;
end;

procedure tcustomscrollboxframe.writezoomheightstep(writer: twriter);
begin
 writer.writefloat(zoomheightstep);
end;

procedure tcustomscrollboxframe.readzoomwheelsensitivity(reader: treader);
begin
 zoomwheelsensitivity:= reader.readfloat;
end;

procedure tcustomscrollboxframe.writezoomwheelsensitivity(writer: twriter);
begin
 writer.writefloat(zoomwheelsensitivity);
end;

procedure tcustomscrollboxframe.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('zoomwidthstep',@readzoomwidthstep,@writezoomwidthstep,
                      (filer.ancestor = nil) and (fzoomwidthstep <> 1) or
   (filer.ancestor <> nil) and
      (tcustomscrollboxframe(filer.ancestor).fzoomwidthstep <> fzoomwidthstep));
 filer.defineproperty('zoomheightstep',@readzoomheightstep,@writezoomheightstep,
                      (filer.ancestor = nil) and (fzoomheightstep <> 1) or
 (filer.ancestor <> nil) and
    (tcustomscrollboxframe(filer.ancestor).fzoomheightstep <> fzoomheightstep));
 filer.defineproperty('zoomwheelsensitivity',
     @readzoomwheelsensitivity,@writezoomwheelsensitivity,
         (filer.ancestor = nil) and (fzoomwheelsensitivity <> 0) or
   (filer.ancestor <> nil) and
      (tcustomscrollboxframe(filer.ancestor).fzoomwheelsensitivity <>
                                        fzoomwheelsensitivity));
end;

{ tcustomautoscrollframe }

constructor tcustomautoscrollframe.create(const aintf: iscrollframe;
             const owner: twidget; const autoscrollintf: iautoscrollframe);
begin
 fintf1:= autoscrollintf;
 inherited create(aintf,owner);
end;

function tcustomautoscrollframe.getscrollpos: pointty;
begin
 result:= fintf1.getscrollrect.pos;
end;

procedure tcustomautoscrollframe.setscrollpos(const avalue: pointty);
var
 rect1: rectty;
begin
 rect1:= fintf1.getscrollrect;
 if (rect1.x <> avalue.x) or (rect1.y <> avalue.y) then begin
  rect1.pos:= avalue;
  with rect1 do begin
   if x + cx < fpaintrect.cx then begin
    x:= fpaintrect.cx - rect1 .cx;
   end;
   if x > 0{fpaintrect.x} then begin
    x:= 0{fpaintrect.x};
   end;
   if y + cy < fpaintrect.cy then begin
    y:= fpaintrect.cy - cy;
   end;
   if y > 0{fpaintrect.y} then begin
    y:= 0{fpaintrect.y};
   end;
  end;
  clientrecttoscrollbar(rect1);
  fintf1.setscrollrect(rect1);
 end;
end;

function tcustomautoscrollframe.getscrollpos_x: integer;
begin
 result:= getscrollpos.x;
end;

procedure tcustomautoscrollframe.setscrollpos_x(const avalue: integer);
begin
 setscrollpos(makepoint(avalue,getscrollpos.y));
end;

function tcustomautoscrollframe.getscrollpos_y: integer;
begin
 result:= getscrollpos.y;
end;

procedure tcustomautoscrollframe.setscrollpos_y(const avalue: integer);
begin
 setscrollpos(makepoint(getscrollpos.x,avalue));
end;

procedure tcustomautoscrollframe.scrollevent(sender: tcustomscrollbar;
                  event: scrolleventty);
var
 rect1: rectty;
begin
 if fscrolling = 0 then begin
  if event = sbe_valuechanged then begin
   rect1:= fintf1.getscrollrect;
   scrollpostoclientpos(rect1);
   fintf1.setscrollrect(rect1);
  end
  else begin
   fintf1.scrollevent(sender,event);
  end;
 end;
end;

procedure tcustomautoscrollframe.updaterects;
begin
 inherited;
 fclientrect.pos:= nullpoint;
 fclientrect.size:= fpaintrect.size;
 finnerclientrect:= deflaterect(fclientrect,fi.innerframe);
end;

procedure tcustomautoscrollframe.updateclientrect;
var
 rect1: rectty;
begin
 rect1:= fintf1.getscrollrect;
 calcclientrect(rect1);
 fintf1.setscrollrect(rect1);
end;


{ tactionwidget }

procedure tactionwidget.updatepopupmenu(var amenu: tpopupmenu;
                                        var mouseinfo: mouseeventinfoty);
begin
 if (fpopupmenu <> nil) and not ((es_child in mouseinfo.eventstate) and
                              (mo_noinsert in fpopupmenu.options)) then begin
  tpopupmenu.additems(amenu,self,mouseinfo,fpopupmenu);
  amenu.menu.caption:= fpopupmenu.menu.caption; //for tassistivehandler
 end;

end;

procedure tactionwidget.dopopup(var amenu: tpopupmenu;
                                        var mouseinfo: mouseeventinfoty);
 procedure doparent(const after: boolean);
 var
  widget1: twidget;
  bo1: boolean;
 begin
  if (fpopupmenu = nil) or not (mo_stopinsert in fpopupmenu.options) then begin
   widget1:= fparentwidget;
   while widget1 <> nil do begin
    if widget1 is tactionwidget then begin
     translateclientpoint1(mouseinfo.pos,self,widget1);
     bo1:= not (es_child in mouseinfo.eventstate);
     include(mouseinfo.eventstate,es_child);
     try
      if after then begin
       tactionwidget(widget1).doafterpopupmenu(amenu,mouseinfo);
      end
      else begin
       tactionwidget(widget1).dopopup(amenu,mouseinfo);
      end;
     finally
      if bo1 then begin
       exclude(mouseinfo.eventstate,es_child);
      end;
      translateclientpoint1(mouseinfo.pos,widget1,self);
     end;
     break;
    end;
    widget1:= twidget1(widget1).fparentwidget;
   end;
  end;
 end; //doparent()

var
 menu1: tpopupmenu;

begin
 menu1:= amenu;
 try
  updatepopupmenu(amenu,mouseinfo);
  if canevent(tmethod(fonpopup)) then begin
   fonpopup(self,amenu,mouseinfo);
  end;
  if not (es_parent in mouseinfo.eventstate) then begin
   doparent(false);
   if (amenu <> nil) and
              (mouseinfo.eventstate * [es_processed,es_child] = []) then begin
    amenu.show(self,mouseinfo);
    doafterpopupmenu(amenu,mouseinfo);
    doparent(true);
   end;
  end;
 finally
  if not (es_child in mouseinfo.eventstate) then begin
   if amenu <> menu1 then begin
    freetransientmenu(tcustommenu(menu1)); //if amenu overwritten
   end;
   freetransientmenu(tcustommenu(amenu));
  end;
 end;
end;

procedure tactionwidget.mouseevent(var info: mouseeventinfoty);
begin
 if canevent(tmethod(fonmouseevent)) then begin
  fonmouseevent(self,info);
 end;
 inherited;
end;

procedure tactionwidget.clientmouseevent(var info: mouseeventinfoty);
var
 dummy: tpopupmenu;
 po1: pointty;
begin
 if canevent(tmethod(fonclientmouseevent)) then begin
  fonclientmouseevent(self,info);
 end;
 inherited;
 with info do begin
  if (eventkind = ek_buttonrelease) and (ws_rclicked in fwidgetstate) and
             not (csdesigning in componentstate) and
             (eventstate * [es_processed,es_child] = []) and
             (button = mb_right) then begin
   dummy:= nil;
   po1:= pos;
   dopopup(dummy,info);
   pos:= po1; //no mousemove by change of popup pos
  end;
 end;
end;

procedure tactionwidget.childmouseevent(const sender: twidget;
                var info: mouseeventinfoty);
begin
 if canevent(tmethod(fonchildmouseevent)) then begin
  fonchildmouseevent(sender,info);
 end;
 inherited;
end;

procedure tactionwidget.domousewheelevent(var info: mousewheeleventinfoty);
begin
 if canevent(tmethod(fonmousewheelevent)) then begin
  fonmousewheelevent(self,info);
 end;
 inherited;
end;

procedure tactionwidget.dobeforepaint(const canvas: tcanvas);
var
 pt1: pointty;
begin
 inherited;
// canvas.font:= getfont;
 if canevent(tmethod(fonbeforepaint)) then begin
  pt1:= clientwidgetpos;
  canvas.move(pt1);
  fonbeforepaint(self,canvas);
  canvas.remove(pt1);
 end;
end;

procedure tactionwidget.doonpaintbackground(const canvas: tcanvas);
begin
 inherited;
 if canevent(tmethod(fonpaintbackground)) then begin
  fonpaintbackground(self,canvas);
 end;
end;

procedure tactionwidget.doonpaint(const canvas: tcanvas);
begin
 inherited;
 if canevent(tmethod(fonpaint)) then begin
  fonpaint(self,canvas);
 end;
end;

procedure tactionwidget.doafterpaint(const canvas: tcanvas);
var
 pt1: pointty;
begin
 inherited;
 if canevent(tmethod(fonafterpaint)) then begin
  pt1:= clientwidgetpos;
  canvas.move(pt1);
  fonafterpaint(self,canvas);
  canvas.remove(pt1);
 end;
end;

procedure tactionwidget.doonkeydown(var info: keyeventinfoty);
begin
 if not (ws1_onkeydowncalled in fwidgetstate1) then begin
  include(fwidgetstate1,ws1_onkeydowncalled);
  if canevent(tmethod(fonkeydown)) then begin
   fonkeydown(self,info);
  end;
 end;
end;

procedure tactionwidget.dokeydown(var info: keyeventinfoty);
var
 dummy: tpopupmenu;
 mouseinfo: mouseeventinfoty;
begin
 if not (es_processed in info.eventstate) then begin
  doonkeydown(info);
 end;
 with info do begin
  if (key = key_menu) and (shiftstate = []) and
                    not(es_processed in eventstate) then begin
   dummy:= nil;
   fillchar(mouseinfo,sizeof(mouseinfo),0);
   with mouseinfo do begin
    with application.caret do begin
     if active then begin
      mouseinfo.pos:= pos;
      mouseinfo.pos.y:= mouseinfo.pos.y + height;
     end
     else begin
      mouseinfo.pos:= rectcenter(clippedpaintrect);
     end;
    end;
    getpopuppos(pos);
    button:= mb_none;
   end;
   dummy:= nil;
   dopopup(dummy,mouseinfo);
   if not (es_processed in mouseinfo.eventstate) then begin
    inherited;
   end;
  end
  else begin
   inherited;
  end;
 end;
end;

procedure tactionwidget.dokeyup(var info: keyeventinfoty);
begin
 if not (es_processed in info.eventstate) and canevent(tmethod(fonkeyup)) then begin
  fonkeyup(self,info);
 end;
 inherited;
end;

procedure tactionwidget.showhint(const aid: int32; var info: hintinfoty);
begin
 inherited;
 if canevent(tmethod(fonshowhint)) then begin
  fonshowhint(self,info);
 end;
end;

procedure tactionwidget.internalcreateframe;
begin
 tcaptionframe.create(iscrollframe(self));
end;

procedure tactionwidget.enabledchanged;
begin
 inherited;
 if (fframe <> nil) and
      (tcustomcaptionframe(fframe).finfo.text.text <> '') then begin
  invalidatewidget;
 end;
end;

function tactionwidget.getframe: tcaptionframe;
begin
 result:= tcaptionframe(inherited getframe);
end;

procedure tactionwidget.setframe(const value: tcaptionframe);
begin
 inherited setframe(value);
end;

function tactionwidget.getface: tface;
begin
 result:= tface(inherited getface);
end;

procedure tactionwidget.setface(const Value: tface);
begin
 inherited setface(value);
end;

procedure tactionwidget.setpopupmenu(const Value: tpopupmenu);
begin
 setlinkedvar(value,tmsecomponent(fpopupmenu));
end;

procedure tactionwidget.poschanged;
begin
 inherited;
 if canevent(tmethod(fonmove)) then begin
  fonmove(self);
 end;
end;

procedure tactionwidget.sizechanged;
begin
 inherited;
 if canevent(tmethod(fonresize)) then begin
  fonresize(self);
 end;
end;

procedure tactionwidget.doloaded;
begin
 inherited;
 if canevent(tmethod(fonloaded)) then begin
  fonloaded(self);
 end;
end;

procedure tactionwidget.doenter;
begin
 inherited;
 if canevent(tmethod(fonenter)) then begin
  fonenter(self);
 end;
end;

procedure tactionwidget.doexit;
begin
 inherited;
 if canevent(tmethod(fonexit)) then begin
  fonexit(self);
 end;
end;

function tactionwidget.canclose(const newfocus: twidget): boolean;
begin
 result:= inherited canclose(newfocus);
 if result and assigned(fonclosequery) then begin
  fonclosequery(self,result);
 end;
end;

procedure tactionwidget.dofocus;
begin
 inherited;
 if canevent(tmethod(fonfocus)) then begin
  fonfocus(self);
 end;
end;

procedure tactionwidget.dodefocus;
begin
 inherited;
 if canevent(tmethod(fondefocus)) then begin
  fondefocus(self);
 end;
end;

procedure tactionwidget.dofocuschanged(const oldwidget: twidget;
               const newwidget: twidget);
begin
 inherited;
 if canevent(tmethod(fonfocusedwidgetchanged)) and
  (checkdescendent(oldwidget) or checkdescendent(newwidget)) then begin
  fonfocusedwidgetchanged(oldwidget,newwidget);
 end;
end;

procedure tactionwidget.doactivate;
begin
 inherited;
 if canevent(tmethod(fonactivate)) and
         ((ow1_modalcallonactivate in foptionswidget1) or
          not (tws_modalcalling in twindow1(window).fstate)) then begin
  fonactivate(self);
 end;
end;

procedure tactionwidget.dodeactivate;
begin
 inherited;
 if canevent(tmethod(fondeactivate)) and
         ((ow1_modalcallondeactivate in foptionswidget1) or
          not (tws_modalcalling in twindow1(window).fstate)) then begin
  fondeactivate(self);
 end;
end;

procedure tactionwidget.dohide;
begin
 if canevent(tmethod(fonhide)) then begin
  fonhide(self);
 end;
 inherited;
// include(fwidgetstate,ws_hidden);
// exclude(fwidgetstate,ws_showed);
end;

procedure tactionwidget.doshow;
begin
// inherited;
 if canevent(tmethod(fonshow)) then begin
  fonshow(self);
 end;
 inherited;
// include(fwidgetstate,ws_showed);
// exclude(fwidgetstate,ws_hidden);
end;


procedure tactionwidget.getpopuppos(var apos: pointty);
begin
 //dummy
end;

procedure tactionwidget.doshortcut(var info: keyeventinfoty;
               const sender: twidget);
begin
 if not (es_processed in info.eventstate) and canevent(tmethod(fonshortcut)) then begin
  fonshortcut(self,info,sender);
 end;
 if (fpopupmenu <> nil) and (sender <> nil) //no broadcast
                          and not(csdesigning in componentstate) then begin
  fpopupmenu.doshortcut(info);
 end;
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;

procedure tactionwidget.receiveevent(const event: tobjectevent);
begin
 if canevent(tmethod(fonevent)) then begin
  fonevent(self,event);
 end;
 inherited;
end;

procedure tactionwidget.componentevent(const event: tcomponentevent);
begin
 if canevent(tmethod(foncomponentevent)) then begin
  foncomponentevent(self,event);
 end;
 inherited;
end;

procedure tactionwidget.doasyncevent(var atag: integer);
begin
 if canevent(tmethod(fonasyncevent)) then begin
  fonasyncevent(self,atag);
 end;
 inherited;
end;

procedure tactionwidget.doafterpopupmenu(var amenu: tpopupmenu;
               var mouseinfo: mouseeventinfoty);
begin
 //dummy
end;

{ ttoplevelwidget }

constructor ttoplevelwidget.create(aowner: tcomponent);
begin
 inherited;
 visible:= false;
 foptionswidget:= defaultoptionstoplevelwidget;
 optionsskin:= defaultcontainerskinoptions;
// fcolor:= cl_background;
end;

{ tcaptionwidget }

function tcaptionwidget.getcaption: msestring;
begin
 result:= fcaption;
end;

procedure tcaptionwidget.setcaption(const Value: msestring);
begin
 fcaption := Value;
 if (fwindow <> nil) and (fwindow.winid <> 0) then begin
  gui_setwindowcaption(fwindow.winid,fcaption);
 end;
end;

procedure tcaptionwidget.windowcreated;
begin
 inherited;
 if fcaption <> '' then begin
  caption:= fcaption;                //set windowcaption
 end;
end;

function tcaptionwidget.getassistivecaption(): msestring;
begin
 result:= getcaption();
end;

{ tscrollface }

procedure tscrollface.internalpaint(const canvas: tcanvas; const rect: rectty);
begin
 inherited internalpaint(canvas,fintf.getclientrect);
end;

{ tscrollingwidgetnwr }

constructor tscrollingwidgetnwr.create(aowner: tcomponent);
begin
 inherited;
 include(fwidgetstate1,ws1_designactive);
 foptionswidget:= defaultoptionswidgetmousewheel;
 optionsskin:= defaultcontainerskinoptions;
 internalcreateframe;
 setstaticframe(true);
end;

procedure tscrollingwidgetnwr.internalcreateframe;
begin
 tscrollboxframe.create(iscrollframe(self),self);
end;

function tscrollingwidgetnwr.getframe: tscrollboxframe;
begin
 result:= tscrollboxframe(pointer(inherited getframe));
end;

procedure tscrollingwidgetnwr.setframe(const Value: tscrollboxframe);
begin
 inherited setframe(tcaptionframe(pointer(value)));
end;

procedure tscrollingwidgetnwr.mouseevent(var info: mouseeventinfoty);
begin
 inherited;
 if not (es_processed in info.eventstate) then begin
  tscrollframe(fframe).mouseevent(info);
 end;
end;

procedure tscrollingwidgetnwr.childmouseevent(const sender: twidget;
                              var info: mouseeventinfoty);
//var
// po1: pointty;
begin
 frame.childmouseevent(sender,info);
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;

procedure tscrollingwidgetnwr.domousewheelevent(var info: mousewheeleventinfoty);
begin
 inherited;
 if not (es_processed in info.eventstate) then begin
  tscrollframe(fframe).domousewheelevent(info,false);
 end;
end;

procedure tscrollingwidgetnwr.doscroll(const dist: pointty);
begin
 inherited;
 if canevent(tmethod(fonscroll)) then begin
  fonscroll(self,dist);
 end;
end;

procedure tscrollingwidgetnwr.doscrolled(const dist: pointty);
begin
 inherited;
 if canevent(tmethod(fonscroll)) then begin
  fonscroll(self,dist);
 end;
end;

procedure tscrollingwidgetnwr.widgetregionchanged(const sender: twidget);
begin
 inherited;
 if ((sender = nil) or
         not (ws1_anchorsizing in twidget1(sender).fwidgetstate1)) and
           not (ws_destroying in fwidgetstate) and
                      (componentstate*[csloading,csdestroying] = []) then begin
  tcustomscrollboxframe(fframe).updateclientrect;
 end;
// else begin
//  tscrollboxframe(fframe).updatestate; ww
// end;
end;

procedure tscrollingwidgetnwr.writestate(writer: twriter);
begin
 frame.sbhorz.value:= 0;
 frame.sbvert.value:= 0;
 inherited;
end;

procedure tscrollingwidgetnwr.internalcreateface;
begin
 tscrollface.create(twidget(self));
end;

procedure tscrollingwidgetnwr.sizechanged;
begin
 inherited;
 tcustomscrollboxframe(fframe).updatestate;
// tcustomscrollboxframe(fframe).updateclientrect;
    //set endresult of autosizing
end;

procedure tscrollingwidgetnwr.minscrollsizechanged;
begin
 tcustomscrollboxframe(fframe).updatestate;
end;

function tscrollingwidgetnwr.calcminscrollsize: sizety;
begin
 result:= inherited calcminscrollsize;
 if result.cx < fminclientsize.cx then begin
  result.cx:= fminclientsize.cx;
 end;
 if result.cy < fminclientsize.cy then begin
  result.cy:= fminclientsize.cy;
 end;
// result:= inherited calcminscrollsize;
 if checkcanevent(owner,tmethod(foncalcminscrollsize)) then begin
  foncalcminscrollsize(self,result);
 end;
end;

procedure tscrollingwidgetnwr.setclientsize(const asize: sizety);
begin
 with tcustomscrollboxframe(fframe) do begin
  fminclientsize:= fminminclientsize;
  if (asize.cx > fclientrect.cx) then begin
   fminclientsize.cx:= asize.cx;
  end;
  if (asize.cy > fclientrect.cy) then begin
   fminclientsize.cy:= asize.cy;
  end;
  if (fminclientsize.cx > 0) or (fminclientsize.cy > 0) then begin
   updatestate;
   fminclientsize:= fminminclientsize;
  end;
 end;
end;

procedure tscrollingwidgetnwr.dolayout(const sender: twidget);
begin
 if canevent(tmethod(fonlayout)) then begin
  fonlayout(self);
 end
 else begin
  inherited;
 end;
end;

procedure tscrollingwidgetnwr.loaded;
begin
 inherited;
 if canevent(tmethod(fonlayout)) then begin
  postchildscaled;
 end;
end;

procedure tscrollingwidgetnwr.dofontheightdelta(var delta: integer);
begin
 if canevent(tmethod(fonfontheightdelta)) then begin
  fonfontheightdelta(self,delta);
 end;
 inherited;
end;

procedure tscrollingwidgetnwr.clampinview(const arect: rectty; const bottomright: boolean);
begin
 updateroot;
 frame.showrect(removerect(arect,clientpos),bottomright);
 inherited;
// frame.showrect(removerect(arect,clientwidgetpos));
// frame.showrect(arect);
end;

function tscrollingwidgetnwr.maxclientsize: sizety;
begin
 result:= makesize(bigint,bigint);
end;
{
procedure tscrollingwidgetnwr.setclientpos(const avalue: pointty);
begin
 frame.showrect(makerect(avalue,paintsize),false);
end;
}
procedure tscrollingwidgetnwr.readonchildscaled(reader: treader);
begin
 onlayout:= notifyeventty(readmethod(reader));
end;

procedure tscrollingwidgetnwr.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('onchildscaled',{$ifdef FPC}@{$endif}readonchildscaled,
                                                                   nil,false)
end;

{ tscrollbarwidget }

constructor tscrollbarwidget.create(aowner: tcomponent);
begin
 inherited;
 internalcreateframe;
end;

procedure tscrollbarwidget.internalcreateframe;
begin
 tscrollframe.create(self,iscrollbar(self));
end;

function tscrollbarwidget.getframe: tscrollframe;
begin
 result:= tscrollframe(pointer(inherited getframe));
end;

procedure tscrollbarwidget.setframe(const Value: tscrollframe);
begin
 inherited setframe(tcaptionframe(pointer(value)));
end;

procedure tscrollbarwidget.scrollevent(sender: tcustomscrollbar;
  event: scrolleventty);
begin
 //dummy
end;

procedure tscrollbarwidget.mouseevent(var info: mouseeventinfoty);
begin
 tscrollframe(fframe).mouseevent(info);
 inherited;
end;

{ tpopupwidget }

function tpopupwidget.getassistiveflags(): assistiveflagsty;
begin
 result:= inherited getassistiveflags();
 if ownswindow then begin
  result:= result + [asf_popup];
 end;
end;

constructor tpopupwidget.create(aowner: tcomponent; transientfor: twindow);
begin
 inherited create(aowner);
 if transientfor <> nil then begin
  getobjectlinker.setlinkedvar(ievent(self),transientfor,tlinkedobject(ftransientfor));
 end;
 window.localshortcuts:= true;
end;

function tpopupwidget.internalshow(const modallevel: modallevelty;
                   const transientfor: pwindow;
                   const windowevent,transientforshow: boolean): modalresultty;
begin
 if transientfor^ = nil then begin
  result:=  inherited internalshow(modallevel,@ftransientfor,windowevent,
                                                             transientforshow);
 end
 else begin
  result:= inherited internalshow(modallevel,transientfor,windowevent,
                                                             transientforshow);
 end;
end;

procedure tpopupwidget.updatewindowinfo(var info: windowinfoty);
begin
 with info do begin
  options:= [wo_popup];
  transientfor:= ftransientfor;
 end;
end;

{ tcustomhintwidget }

constructor tcustomhintwidget.create(const aowner: tcomponent;
                 const atransientfor: twindow;
                 var info: hintinfoty; const sender: tobject);
var
 rect1,rect2: rectty;
 hintfont: tfont;
begin
 inherited create(aowner,atransientfor);
 foptionswidget:= defaultoptionshintwidget;
 if atransientfor = nil then begin
  include(foptionswidget,ow_ultratop);
 end;
 internalcreateframe;
 fframe.levelo:= 1;
 fframe.framei_left:= 1;
 fframe.framei_top:= 1;
 fframe.framei_right:= 1;
 fframe.framei_bottom:= 1;
 color:= cl_infobackground;

  rect2:= deflaterect(application.workarea(atransientfor),fframe.innerframe);

  hintfont := tfont.create;
  hintfont.height := messagefontheight;
  hintfont.name := ansistring(messagefontname);

 rect1:= textrect(getcanvas,info.caption,rect2,[tf_wordbreak],hintfont);

 hintfont.free;
 addsize1(rect1.size,fframe.innerframedim);
// inc(rect1.cx,fframe.innerframedim.cx);
// inc(rect1.cy,fframe.innerframedim.cy);
 widgetrect:= placepopuprect(atransientfor,info.posrect,info.placement,
                                                                 rect1.size);
end;

{ thintwidget}

constructor thintwidget.create(const aowner: tcomponent;
               const atransientfor: twindow; var info: hintinfoty;
               const sender: tobject);
begin
 fcaption:= info.caption;
 inherited;
end;

procedure thintwidget.dopaintforeground(const canvas: tcanvas);
var
 hintfont: tfont;

begin
 inherited;
  hintfont := tfont.create;
  hintfont.height := messagefontheight;
  hintfont.name := ansistring(messagefontname);

// drawtext(canvas,fcaption,innerclientrect,[tf_wordbreak],
//                                      stockobjects.fonts[stf_hint]);

  drawtext(canvas,fcaption,innerclientrect,[tf_wordbreak],hintfont);
  hintfont.free;

end;

{ tmessagewidget }

constructor tmessagewidget.create(const aowner: tcomponent;
               const apopuptransient: boolean; const ahasaction: boolean);
begin
 fpopuptransient:= apopuptransient;
 fhasaction:= ahasaction;
 inherited create(aowner);
 if apopuptransient then begin
  color:= cl_active;
//exit;
  createframe;
  with tcustomcaptionframe(fframe) do begin
   colorframe:= cl_black;
   framewidth:= 2;
   captionpos:= cp_top;
  end;
 end;
end;

procedure tmessagewidget.dokeydown(var info: keyeventinfoty);
begin
 with info do begin
  if not((key = key_escape) and (shiftstate = []) and window.close) then begin
   inherited;
  end;
 end;
end;

procedure tmessagewidget.updatewindowinfo(var info: windowinfoty);
begin
 inherited;
 info.options:= [wo_message];
 if fpopuptransient then begin
  include(info.options,wo_popup);
 end;
 window.localshortcuts:= true;
end;

function tmessagewidget.getcaption: msestring;
begin
 if fframe <> nil then begin
  result:= tcustomcaptionframe(fframe).caption;
 end
 else begin
  result:= inherited getcaption;
 end;
end;

procedure tmessagewidget.setcaption(const Value: msestring);
begin
 if fframe <> nil then begin
  tcustomcaptionframe(fframe).caption:= value;
 end
 else begin
  inherited;
 end;
end;

procedure tmessagewidget.internalcreateframe;
begin
 tcustomcaptionframe.create(iscrollframe(self));
end;

function tmessagewidget.canclose(const newfocus: twidget): boolean;
begin
 result:= not fhasaction or (window.modalresult <> mr_windowclosed);
end;

{ tcustomthumbtrackscrollframe }

function tcustomthumbtrackscrollframe.getscrollbarclass(vert: boolean): framescrollbarclassty;
begin
 result:= tthumbtrackscrollbar;
end;

{ tscrollframe }

function tscrollframe.getscrollbarclass(vert: boolean): framescrollbarclassty;
begin
 result:= tscrollbar;
end;

procedure tscrollframe.setsbhorz(const avalue: tscrollbar);
begin
 inherited setsbhorz(avalue);
end;

function tscrollframe.getsbhorz: tscrollbar;
begin
 result:= tscrollbar(inherited sbhorz);
end;

procedure tscrollframe.setsbvert(const avalue: tscrollbar);
begin
 inherited setsbvert(avalue);
end;

function tscrollframe.getsbvert: tscrollbar;
begin
 result:= tscrollbar(inherited sbvert);
end;

{ tsimplewidget }

constructor tsimplewidget.create(aowner: tcomponent);
begin
 inherited;
 exclude(fwidgetstate,ws_visible);
end;

{ timpressedcaptionframe }

constructor timpressedcaptionframe.create(const aintf: icaptionframe);
begin
 inherited;
 fi.levelo:= -2;
 internalupdatestate();
end;

{ ttaborderoverride }

constructor ttaborderoverride.create(const aowner: twidget);
begin
 fowner:= aowner;
 inherited create();
end;

destructor ttaborderoverride.destroy();
begin
// clear();
 inherited;
end;

procedure ttaborderoverride.clear();
var
 p1,pe: pdoublewidgetty;
begin
 p1:= pointer(fitems);
 if p1 <> nil then begin
  pe:= p1 + high(fitems);
  while p1 <= pe do begin
   setlinkedvar(nil,tmsecomponent(p1^.a));
   setlinkedvar(nil,tmsecomponent(p1^.b));
   inc(p1);
  end;
  fitems:= nil;
 end;
end;

procedure ttaborderoverride.readitems(reader: treader);
begin
 clear();
 fwidgetnames:= nil;
 reader.readlistbegin();
 while not reader.endoflist() do begin
  additem(fwidgetnames,reader.readstring());
 end;
 reader.readlistend();
end;

procedure ttaborderoverride.writeitems(writer: twriter);
var
 p1,pe: pdoublewidgetty;
begin
 writer.writelistbegin();
 p1:= pointer(fitems);
 pe:= p1 + length(fitems);
 while p1 < pe do begin
  writer.writestring(ownernamepath(writer.root,p1^.a));
  writer.writestring(ownernamepath(writer.root,p1^.b));
  inc(p1);
 end;
 writer.writelistend();
end;

procedure ttaborderoverride.defineproperties(filer: tfiler);
var
 b1: boolean;
 p1,p2,pe: pdoublewidgetty;
begin
 inherited;
 b1:= fitems <> nil;
 if (filer is twriter) and (filer.ancestor <> nil) then begin
  with ttaborderoverride(filer.ancestor) do begin
   b1:= high(fitems) <> high(self.fitems);
   if not b1 then begin
    p1:= pointer(fitems);
    pe:= p1 + length(fitems);
    p2:= pointer(self.fitems);
    while p1 < pe do begin
     if ((p1^.a = nil) <> (p2^.a = nil)) or
        ((p1^.b = nil) <> (p2^.b = nil)) or
        (p1^.a <> nil) and (p1^.a.name <> p2^.a.name) or
        (p1^.b <> nil) and (p1^.b.name <> p2^.b.name) then begin
                   //todo: better check for changed owner
      b1:= true;
      break;
     end;
     inc(p1);
     inc(p2);
    end;
   end;
  end;
 end;
 filer.defineproperty('items',@readitems,@writeitems,b1);
end;

procedure ttaborderoverride.objevent(const sender: iobjectlink;
               const event: objecteventty);
var
 p1,pe: pdoublewidgetty;
 w1: tobject;
begin
 if event = oe_destroyed then begin
  if csdestroying in fowner.componentstate then begin
   fitems:= nil;
  end
  else begin
   w1:= sender.getinstance();
   p1:= pointer(fitems);
   if p1 <> nil then begin
    pe:= p1 + high(fitems);
    while p1 <= pe do begin
     if p1^.a = w1 then begin
      p1^.a:= nil;
     end;
     if p1^.b = w1 then begin
      p1^.b:= nil;
     end;
     inc(p1);
    end;
   end;
  end;
 end;
 inherited;
end;

procedure ttaborderoverride.endread(const reader: treader);
var
 p1,pe: pstring;
 compa,compb: tcomponent;
begin
 if (fwidgetnames <> nil) then begin
  clear;
  p1:= pointer(fwidgetnames);
  pe:= p1+high(fwidgetnames);
  while p1 < pe do begin
   compa:= findsubcomponentbynamepath(p1^,reader.root);
   inc(p1);
   compb:= findsubcomponentbynamepath(p1^,reader.root);
   inc(p1);
   if ((compa = nil) or (compa is twidget)) and
                         ((compb = nil) or (compb is twidget)) then begin
    add(twidget(compa),twidget(compb));
   end;
  end;
  fwidgetnames:= nil;
 end;
end;

function ttaborderoverride.nexttaborder(sender: twidget;
               const down: boolean): twidget;
var
 ar1: doublewidgetarty;
 p1,pe: pdoublewidgetty;
label
 restartlab,endlab;
begin
 result:= nil;
 if fitems <> nil then begin
  ar1:= copy(fitems);
  while true do begin
restartlab:
   if down then begin
    pe:= pointer(ar1);
    p1:= pe+high(ar1);
    while p1 >= pe do begin
     if p1^.b = sender then begin
      result:= p1^.a;
      if (result <> nil) and not result.canfocus() then begin
       p1^.b:= nil; //avoid circles
       sender:= result;
       goto restartlab; //next try
      end
      else begin
       goto endlab;
      end;
     end;
     dec(p1);
    end;
    goto endlab; //no match
   end
   else begin
    p1:= pointer(ar1);
    pe:= p1+high(ar1);
    while p1 <= pe do begin
     if p1^.a = sender then begin
      result:= p1^.b;
      if (result <> nil) and not result.canfocus() then begin
       p1^.a:= nil; //avoid circles
       sender:= result;
       goto restartlab; //next try
      end
      else begin
       goto endlab;
      end;
     end;
     inc(p1);
    end;
    goto endlab; //no match
   end;
  end;
 end;
endlab:
 if (result <> nil) and not result.canfocus() then begin
  result:= result.nexttaborder(down)
 end;
 if fowner.canevent(tmethod(fontaborder)) then begin
  fontaborder(self,sender,down,result);
 end;
end;

procedure ttaborderoverride.add(const aa: twidget; const ab: twidget);
begin
 if (aa <> nil) or (ab <> nil) then begin
  setlength(fitems,high(fitems)+2);
  with fitems[high(fitems)] do begin
   a:= aa;
   b:= ab;
   if aa <> nil then begin
    getobjectlinker.link(iobjectlink(self),ievent(aa));
   end;
  end;
 end;
end;

end.
