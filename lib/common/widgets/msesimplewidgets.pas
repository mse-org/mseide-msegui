{ MSEgui Copyright (c) 1999-2018 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msesimplewidgets;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface

uses
 msegui,mseglob,mseguiglob,msetypes,msestrings,msegraphics,mseevent,
 mseact,msewidgets,
 mserichstring,mseshapes,classes,mclasses,mseclasses,msebitmap,msedrawtext,
 msedrag,
 {$ifdef mse_dynpo}
 msestockobjects_dynpo,
{$else}
 msestockobjects,
{$endif}
 msegraphutils,msemenus,msetimer;

const
 defaultbuttonwidth = 50;
 defaultbuttonheight = 20;
 defaultlabeltextflags = [tf_ycentered];
 defaultlabeloptionswidget = (defaultoptionswidget {+
                            [ow_fontglyphheight]}) -
              [ow_mousefocus,ow_tabfocus,ow_arrowfocus];
 defaultlabeloptionswidget1 = defaultoptionswidget1 +
                  [ow1_autowidth,ow1_autoheight,ow1_fontglyphheight];
 defaultlabelwidgetwidth = 100;
 defaultlabelwidgetheight = 20;

 defaulticonoptionswidget = defaultoptionswidget -
                                [ow_mousefocus,ow_tabfocus,ow_arrowfocus];
 defaulticonoptionswidget1 = defaultoptionswidget1 +
                                [ow1_autowidth,ow1_autoheight];
 defaulticonwidgetwidth = 16;
 defaulticonwidgetheight = 16;

type

 teventwidget = class(tcustomeventwidget)
  published
   property onfocusedwidgetchanged;
   property onenter;
   property onexit;
   property onfocus;
   property ondefocus;

   property onmouseevent;
   property onchildmouseevent;
   property onclientmouseevent;
   property onmousewheelevent;

   property onkeydown;
   property onkeyup;
   property onshortcut;

   property onloaded;

   property onbeforepaint;
   property onpaintbackground;
   property onpaint;
   property onafterpaint;

   property onshow;
   property onhide;
   property onactivate;
   property ondeactivate;
   property onresize;
   property onmove;
   property onclosequery;

   property onasyncevent;
   property oncomponentevent;
 end;

 tcustombutton = class;
 buttoneventty = procedure(const sender: tcustombutton) of object;

 tcustombutton = class(tactionsimplebutton,iactionlink,iimagelistinfo)
  private
   fmodalresult: modalresultty;
   factioninfo: actioninfoty;
   fautosize_cx: integer;
   fautosize_cy: integer;
   fonupdate: buttoneventty;
   procedure setcaption(const Value: captionty);
   function getframe: tframe;
   procedure setframe(const Value: tframe);
   function getcaption: captionty;
   procedure setonexecute(const value: notifyeventty);
   function isonexecutestored: boolean;
   procedure setonbeforeexecute(const avalue: accepteventty);
   function isonbeforeexecutestored: boolean;
   procedure setonafterexecute(const value: notifyeventty);
   function isonafterexecutestored: boolean;
   procedure setaction(const value: tcustomaction); virtual;
   function iscaptionstored: boolean;
   function getstate: actionstatesty;
   procedure setstate(const value: actionstatesty); virtual;
   function isstatestored: boolean;
   function getimagelist: timagelist;
   procedure setimagelist(const Value: timagelist);
   function isimageliststored: Boolean;
   procedure setimagenr(const Value: imagenrty);
   function isimagenrstored: boolean;
   procedure setimagenrdisabled(const avalue: imagenrty);
   function isimagenrdisabledstored: Boolean;
   procedure setcolorglyph(const avalue: colorty);
   function iscolorglyphstored: boolean;
   procedure setimagepos(const avalue: imageposty);
   procedure setcaptiondist(const avalue: integer);
   procedure setautosize_cx(const avalue: integer);
   procedure setautosize_cy(const avalue: integer);
   procedure setimagedist(const avalue: integer);
   procedure setimagedist1(const avalue: integer);
   procedure setimagedist2(const avalue: integer);
   procedure setshortcut(const avalue: shortcutty);
   function isshortcutstored: boolean;
   function getshortcut: shortcutty;
   function getshortcut1: shortcutty;
   procedure setshortcut1(const avalue: shortcutty);
   function isshortcut1stored: boolean;
   procedure readcaptionpos(reader: treader);
   procedure settextflags(const avalue: textflagsty);
   procedure setshortcuts(const avalue: shortcutarty);
   procedure setshortcuts1(const avalue: shortcutarty);
   procedure readshortcut(reader: treader);
   procedure readshortcut1(reader: treader);
   procedure readsc(reader: treader);
   procedure writesc(writer: twriter);
   procedure readsc1(reader: treader);
   procedure writesc1(writer: twriter);
   procedure setdisabled(const avalue: boolean);
   function isenabledstored(): boolean;
  protected
   fexeccanceled: boolean;
   function getdisabled(): boolean override;
   procedure defineproperties(filer: tfiler); override;
   procedure fontchanged; override;
   procedure setcolor(const avalue: colorty); override;
   procedure doidle(var again: boolean);
    //iactionlink
   function getactioninfopo: pactioninfoty;
   function shortcutseparator: msechar;
   procedure calccaptiontext(var ainfo: actioninfoty) virtual;
   procedure actionchanged;

   procedure setoptions(const avalue: buttonoptionsty); override;
   function gethint: msestring; override;
   procedure sethint(const Value: msestring); override;
   function ishintstored: boolean; override;
    //iassistiveclient
   function getassistivecaption(): msestring; override;

   procedure setenabled(const avalue: boolean); override;
   procedure setvisible(const avalue: boolean); override;
   procedure readstate(reader: treader); override;
   procedure loaded; override;
   procedure clientrectchanged; override;
   procedure doexecute; override;
   procedure doenter; override;
   procedure doexit; override;
   procedure dopaintforeground(const canvas: tcanvas); override;
   function checkfocusshortcut(var info: keyeventinfoty): boolean; override;
   procedure doshortcut(var info: keyeventinfoty; const sender: twidget); override;
   procedure getautopaintsize(var asize: sizety); override;
   procedure objectevent(const sender: tobject;
                                     const event: objecteventty); override;
   function verticalfontheightdelta: boolean; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure synctofontheight; override;
   procedure doupdate;
   procedure updatehotkeys() override;

   property bounds_cx default defaultbuttonwidth;
   property bounds_cy default defaultbuttonheight;
//   property frame: tframe read getframe write setframe;
   property font: twidgetfont read getfont write setfont stored isfontstored;
   property modalresult: modalresultty read fmodalresult write fmodalresult
                                default mr_none;
   property action: tcustomaction read factioninfo.action write setaction;
   property caption: captionty read getcaption write setcaption stored iscaptionstored;
   property textflags: textflagsty read finfo.ca.textflags
                         write settextflags default defaultcaptiontextflags;
   property imagepos: imageposty read finfo.ca.imagepos write setimagepos
                              default ip_center;
   property captiondist: integer read finfo.ca.captiondist write setcaptiondist
                            default defaultshapecaptiondist;
   property imagelist: timagelist read getimagelist write setimagelist
                    stored isimageliststored;
   property imagenr: imagenrty read factioninfo.imagenr write setimagenr
                            stored isimagenrstored default -1;
   property imagenrdisabled: imagenrty read factioninfo.imagenrdisabled
                              write setimagenrdisabled
                            stored isimagenrdisabledstored default -2;

   property imagedist: integer read finfo.ca.imagedist
                                              write setimagedist default 0;
   property imagedist1: integer read finfo.ca.imagedist1
                                         write setimagedist1 default 0;
   property imagedist2: integer read finfo.ca.imagedist2
                                         write setimagedist2 default 0;
   property colorglyph: colorty read factioninfo.colorglyph write setcolorglyph
                                   stored iscolorglyphstored default cl_default;
   property shortcut: shortcutty read getshortcut write setshortcut
                                    stored false default 0;
   property shortcut1: shortcutty read getshortcut1 write setshortcut1
                                    stored false default 0;
   property shortcuts: shortcutarty read factioninfo.shortcut write setshortcuts;
   property shortcuts1: shortcutarty read factioninfo.shortcut1
                                                        write setshortcuts1;
   property onupdate: buttoneventty read fonupdate write fonupdate;
   property onexecute: notifyeventty read factioninfo.onexecute
              write setonexecute stored isonexecutestored;
   property onbeforeexecute: accepteventty read factioninfo.onbeforeexecute
              write setonbeforeexecute stored isonbeforeexecutestored;
   property onafterexecute: notifyeventty read factioninfo.onafterexecute
              write setonafterexecute stored isonafterexecutestored;
   property autosize_cx: integer read fautosize_cx
                                            write setautosize_cx default 0;
   property autosize_cy: integer read fautosize_cy
                                            write setautosize_cy default 0;
   property disabled: boolean read getdisabled write setdisabled;
                             //sets as_disabled
  published
   property options; //before state!
   property visible stored false;
   property enabled stored isenabledstored;
   property state: actionstatesty read getstate write setstate
            stored isstatestored  default [];
 end;

 tbutton = class(tcustombutton)
  published
   property autosize_cx;
   property autosize_cy;
   property action;
   property caption;
   property textflags;
   property shortcut;
   property shortcut1;
   property imagepos;
   property captiondist;
   property font;
   property modalresult;
   property imagelist;
   property imagenr;
   property imagenrdisabled;
   property imagedist;
   property imagedist1;
   property imagedist2;
   property colorglyph;
   property focusrectdist;
   property onupdate;
   property onexecute;
   property onbeforeexecute;
   property onafterexecute;
 end;

 tstockglyphbutton = class(tcustombutton)
  private
   fglyph: stockglyphty;
   procedure setglyph(const avalue: stockglyphty);
   procedure setstate(const avalue: actionstatesty); override;
   procedure setaction(const avalue: tcustomaction); override;
  public
   constructor create(aowner: tcomponent); override;
  published
   property glyph: stockglyphty read fglyph write setglyph default stg_none;
   property autosize_cx;
   property autosize_cy;
   property action;
   property caption;
   property textflags;
   property shortcut;
   property shortcut1;
   property imagepos;
   property captiondist;
   property font;
   property modalresult;
   property colorglyph;
   property imagedist;
   property imagedist1;
   property imagedist2;
   property options;
   property focusrectdist;
   property onupdate;
   property onexecute;
   property onbeforeexecute;
   property onafterexecute;
 end;

 tcustomrichbutton = class(tcustombutton,irichstringprop)
  private
   ffaceactive: tcustomface;
   ffacedisabled: tcustomface;
   ffacemouse: tcustomface;
   ffaceclicked: tcustomface;
   fimagenrmouse: imagenrty;
   fimagenrclicked: imagenrty;
   fcaptionrich: msestring;
   function getfaceactive: tcustomface;
   procedure setfaceactive(const avalue: tcustomface);
   function getfacemouse: tcustomface;
   procedure setfacemouse(const avalue: tcustomface);
   function getfaceclicked: tcustomface;
   procedure setfaceclicked(const avalue: tcustomface);
   function getfacedisabled: tcustomface;
   procedure setfacedisabled(const avalue: tcustomface);
   procedure setimagenrmouse(const avalue: imagenrty);
   procedure setimagenrclicked(const avalue: imagenrty);
   procedure setcaptionrich(const avalue: msestring);
   procedure setrichvalue(const avalue: richstringty);
   function getrichvalue(): richstringty;
   procedure readrichcaption(reader: treader);
   procedure writerichcaption(writer: twriter);
  protected
   function getactface: tcustomface override;
   procedure dopaintforeground(const canvas: tcanvas) override;
   procedure objectchanged(const sender: tobject) override;
   procedure richcaptionchanged();
   procedure calccaptiontext(var ainfo: actioninfoty) override;
   procedure defineproperties(filer: tfiler) override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure createfaceactive;
   procedure createfacedisabled;
   procedure createfacemouse;
   procedure createfaceclicked;
   property faceactive: tcustomface read getfaceactive write setfaceactive;
   property facemouse: tcustomface read getfacemouse write setfacemouse;
   property faceclicked: tcustomface read getfaceclicked write setfaceclicked;
   property facedisabled: tcustomface read getfacedisabled write setfacedisabled;
   property imagenrmouse: imagenrty read fimagenrmouse
                                        write setimagenrmouse default -1;
   property imagenrclicked: imagenrty read fimagenrclicked
                                        write setimagenrclicked default -1;
   property captionrich: msestring read fcaptionrich
                                   write setcaptionrich stored false;
   property richcaption: richstringty read finfo.ca.caption write setrichvalue;
  published
   property onmouseevent;
   property onbeforepaint;
   property onpaintbackground;
   property onpaint;
   property onafterpaint;
 end;

 trichbutton = class(tcustomrichbutton)
  published
   property faceactive;
   property facemouse;
   property faceclicked;
   property facedisabled;
   property onmouseevent;
   property onclientmouseevent;
   property onbeforepaint;
   property onpaintbackground;
   property onpaint;
   property onafterpaint;

   property autosize_cx;
   property autosize_cy;
   property action;
   property caption;
   property captionrich;
   property textflags;
   property shortcut;
   property shortcut1;
   property imagepos;
   property captiondist;
   property font;
   property modalresult;
   property imagelist;
   property imagenr;
   property imagenrdisabled;
   property imagenrmouse;
   property imagenrclicked;
   property imagedist;
   property imagedist1;
   property imagedist2;
   property colorglyph;
   property options;
   property focusrectdist;
   property onupdate;
   property onexecute;
   property onbeforeexecute;
   property onafterexecute;
 end;

 trichstockglyphbutton = class(tcustomrichbutton)
  private
   fglyph: stockglyphty;
   procedure setglyph(const avalue: stockglyphty);
   procedure setstate(const avalue: actionstatesty); override;
   procedure setaction(const avalue: tcustomaction); override;
  public
   constructor create(aowner: tcomponent); override;
  published
   property glyph: stockglyphty read fglyph write setglyph default stg_none;
   property faceactive;
   property facemouse;
   property faceclicked;
   property facedisabled;
   property onmouseevent;
   property onclientmouseevent;
   property onbeforepaint;
   property onpaintbackground;
   property onpaint;
   property onafterpaint;

   property autosize_cx;
   property autosize_cy;
   property action;
   property caption;
   property captionrich;
   property textflags;
   property shortcut;
   property shortcut1;
   property imagepos;
   property captiondist;
   property font;
   property modalresult;
   property imagedist;
   property imagedist1;
   property imagedist2;
   property colorglyph;
   property options;
   property focusrectdist;
   property onupdate;
   property onexecute;
   property onbeforeexecute;
   property onafterexecute;
 end;

 labeloptionty = (lao_nogray,lao_nounderline);
 labeloptionsty = set of labeloptionty;

type
 tcustomlabel = class(tpublishedwidget)
  private
   frichcaption: richstringty;
   fcaption: msestring;
   factualtextflags: textflagsty;
   ftextflags: textflagsty;
   foptions: labeloptionsty;
   procedure setcaption(const avalue: msestring);
//   function getcaption: msestring;
   procedure updatetextflags;
   procedure settextflags(const Value: textflagsty);
   procedure setoptions(const avalue: labeloptionsty);
  protected
   procedure dopaintforeground(const canvas: tcanvas); override;
   procedure enabledchanged; override;
   procedure getautopaintsize(var asize: sizety); override;
   procedure fontchanged; override;
   procedure clientrectchanged; override;
   function verticalfontheightdelta: boolean; override;
   function checkfocusshortcut(var info: keyeventinfoty): boolean; override;
  public
   constructor create(aowner: tcomponent); override;
   procedure synctofontheight; override;
   procedure updatehotkeys() override;
   procedure initnewcomponent(const ascale: real); override;
   property caption: msestring read fcaption write setcaption;
   property font: twidgetfont read getfont write setfont stored isfontstored;
   property fontempty: twidgetfontempty read getfontempty
                            write setfontempty stored isfontemptystored;
   property textflags: textflagsty read ftextflags write settextflags default
                             defaultlabeltextflags;
   property options: labeloptionsty read foptions write setoptions default [];
  published
   property optionswidget default defaultlabeloptionswidget;
   property optionswidget1 default defaultlabeloptionswidget1;
   property bounds_cx default defaultlabelwidgetwidth;
   property bounds_cy default defaultlabelwidgetheight;
 end;

 tlabel = class(tcustomlabel)
  published
   property options; //first
   property caption;
   property font;
   property textflags;
 end;

 animationoptionty = (ano_singleshot,ano_designactive);
 animationoptionsty = set of animationoptionty;

 tcustomicon = class(tpublishedwidget)
  private
   fimagelist: timagelist;
   fimagenum: integer;
   fcolorglyph: colorty;
   fcolorbackground: colorty;
   falignment: alignmentsty;
   fopacity: colorty;
   fimagesize: sizety;
   fanim_intervalus: int32;
   fanim_count: int32;
   fanim_enabled: boolean;
   fanim_options: animationoptionsty;
   procedure setimagelist(const avalue: timagelist);
   procedure setimagenum(const avalue: integer);
   procedure setcolorglyph(const avalue: colorty);
   procedure setcolorbackground(const avalue: colorty);
   procedure setalignment(const avalue: alignmentsty);
   procedure setopacity(const avalue: colorty);
   procedure readtransparency(reader: treader);
   procedure setanim_intervalus(const avalue: int32);
   procedure setanim_count(const avalue: int32);
   procedure setanim_enabled(const avalue: boolean);
   procedure setanim_options(const avalue: animationoptionsty);
   procedure setcurrentanimoffset(const avalue: int32);
  protected
   fanimimagenum: int32;
   fcurrentanimoffset: int32;
   ftimer: tsimpletimer;
   procedure resetanim();
   procedure animtick(const sender: tobject);
   procedure updateanim();
   procedure dopaintforeground(const canvas: tcanvas); override;
   procedure enabledchanged; override;
   procedure getautopaintsize(var asize: sizety); override;
   procedure clientrectchanged; override;
   procedure objectevent(const sender: tobject;
                             const event: objecteventty); override;
   procedure defineproperties(filer: tfiler); override;
   procedure loaded(); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy(); override;
   property imagelist: timagelist read fimagelist write setimagelist;
   property imagenum: integer read fimagenum write setimagenum default -1;
   property colorglyph: colorty read fcolorglyph
                           write setcolorglyph default cl_default;
   property colorbackground: colorty read fcolorbackground
                           write setcolorbackground default cl_default;
   property opacity: colorty read fopacity
                           write setopacity default cl_default;
   property alignment: alignmentsty read falignment
                        write setalignment default [al_xcentered,al_ycentered];
   property currentanimoffset: int32 read fcurrentanimoffset
                                             write setcurrentanimoffset;
   procedure animrestart();
   property anim_intervalus: int32 read fanim_intervalus
                                 write setanim_intervalus default 0;
                         //micro seconds, 0 = animation off
   property anim_count: int32 read fanim_count write setanim_count default 0;
                         //starts from imagenum, < 2 -> animation off
   property anim_enabled: boolean read fanim_enabled write
                                      setanim_enabled default false;
   property anim_options: animationoptionsty read fanim_options write
                                      setanim_options default [];
  published
   property optionswidget default defaulticonoptionswidget;
   property optionswidget1 default defaulticonoptionswidget1;
   property bounds_cx default defaulticonwidgetwidth;
   property bounds_cy default defaulticonwidgetheight;
 end;

 ticon = class(tcustomicon)
  published
   property imagelist;
   property imagenum;
   property colorglyph;
   property colorbackground;
   property opacity;
   property alignment;
   property anim_intervalus;
   property anim_count;
   property anim_enabled;
   property anim_options;
 end;

 tgroupboxframe = class(tcaptionframe)
  public
   constructor create(const aintf: icaptionframe);
  published
   property framei_left default 2;
   property framei_top default 2;
   property framei_right default 2;
   property framei_bottom default 2;
   property levelo default -1;
   property leveli default 1;
   property captiondist default 0;
   property options
           default defaultcaptionframeoptions + [cfo_captionframecentered];
   property captionoffset default 4;
 end;

 optionscalety = (osc_expandx,osc_shrinkx,osc_expandy,osc_shrinky,
                  osc_invisishrinkx,osc_invisishrinky,
                  osc_expandshrinkx,osc_expandshrinky);
                   //expand minshrinksize to minscrollsize
 optionsscalety = set of optionscalety;
const
 defaultoptionsscale = [osc_expandshrinkx,osc_expandshrinky];
type
 tcustomscalingwidget = class(tpublishedwidget)
  private
   fonfontheightdelta: fontheightdeltaeventty;
   fonlayout: notifyeventty;
   fscaling: integer;
   fonresize: notifyeventty;
   fonmove: notifyeventty;
   fsizebefore: sizety;
   procedure setoptionsscale(const avalue: optionsscalety);
   procedure readonchildscaled(reader: treader);
   procedure settaborderoverride(const avalue: ttaborderoverride);
  protected
   foptionsscale: optionsscalety;
   ftaborderoverride: ttaborderoverride;
   procedure beginscaling;
   procedure endscaling;
   procedure updateoptionsscale();
   procedure dofontheightdelta(var delta: integer); override;
   procedure widgetregionchanged(const sender: twidget); override;
   procedure clientrectchanged; override;
   procedure poschanged; override;
   procedure sizechanged; override;
   procedure loaded; override;
   procedure visiblepropchanged; override;
   function calcminshrinksize(): sizety; override;
   function nexttaborderoverride(const sender: twidget;
                                      const down: boolean): twidget override;
   procedure defineproperties(filer: tfiler); override;
   procedure readstate(reader: treader); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy(); override;
   procedure writestate(writer: twriter); override;
   procedure dolayout(const sender: twidget); override;
   property onresize: notifyeventty read fonresize write fonresize;
   property onmove: notifyeventty read fonmove write fonmove;
  published
   property taborderoverride: ttaborderoverride read ftaborderoverride
                                                  write settaborderoverride;
   property optionsscale: optionsscalety read foptionsscale write setoptionsscale
                  default defaultoptionsscale;
   property onfontheightdelta: fontheightdeltaeventty read fonfontheightdelta
                     write fonfontheightdelta;
   property onlayout: notifyeventty read fonlayout write fonlayout;
 end;

 tscalingwidget = class(tcustomscalingwidget)
  published
   property font: twidgetfont read getfont write setfont stored isfontstored;
   property optionsscale;
   property onfontheightdelta;
   property onlayout;
   property onresize;
   property onmove;
 end;

const
 defaultgroupboxoptionswidget = (defaultoptionswidget +
        [ow_arrowfocusin,ow_arrowfocusout,ow_parenttabfocus,ow_subfocus])-
        [ow_mousefocus];

type
 tgroupbox = class(tscalingwidget)
  private
   fonfocusedwidgetchanged: widgetchangeeventty;
  protected
   procedure internalcreateframe; override;
   procedure dofocuschanged(const oldwidget,newwidget: twidget); override;
   class function classskininfo: skininfoty; override;
  public
   constructor create(aowner: tcomponent); override;
   procedure initnewcomponent(const ascale: real); override;
  published
   property optionswidget default defaultgroupboxoptionswidget;
   property onfocusedwidgetchanged: widgetchangeeventty
                     read fonfocusedwidgetchanged write fonfocusedwidgetchanged;
 end;

const
 defaultscrollboxoptionsscale =
        defaultoptionsscale - [osc_expandshrinkx,osc_expandshrinky];
 defaultscrollboxoptionswidget = defaultoptionswidgetmousewheel + [ow_subfocus];

type
 tscrollbox = class(tscalingwidget)
  private
   fonscroll: pointeventty;
   fonscrolled: pointeventty;
   function getframe: tscrollboxframe;
   procedure setframe(const value: tscrollboxframe);
  protected
   procedure internalcreateframe; override;
   procedure widgetregionchanged(const sender: twidget); override;
   procedure mouseevent(var info: mouseeventinfoty); override;
   procedure childmouseevent(const sender: twidget;
                              var info: mouseeventinfoty); override;
   procedure domousewheelevent(var info: mousewheeleventinfoty); override;
   procedure doscroll(const dist: pointty); override;
   procedure doscrolled(const dist: pointty); override;
//   procedure setclientpos(const avalue: pointty);
  public
   constructor create(aowner: tcomponent); override;
   procedure clampinview(const arect: rectty;
                           const bottomright: boolean = false); override;
  published
   property frame: tscrollboxframe read getframe write setframe;
   property onscroll: pointeventty read fonscroll write fonscroll;
   property onscrolled: pointeventty read fonscrolled write fonscrolled;
   property optionswidget default defaultscrollboxoptionswidget;
   property optionsscale default defaultscrollboxoptionsscale;
 end;

 tpaintbox = class(tscrollbox)
  private
  protected
  published
   property font: twidgetfont read getfont write setfont stored isfontstored;
   property onbeforepaint;
   property onpaintbackground;
   property onpaint;
   property onafterpaint;

   property onmouseevent;
   property onchildmouseevent;
   property onclientmouseevent;
   property onmousewheelevent;

   property onkeydown;
   property onkeyup;
   property onshortcut;

   property onresize;
   property onmove;
 end;

 tstepboxframe = class(tcustomstepframe)
  published
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

   property options;
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
   property buttonface;
   property buttonframe;
   property buttonsize;
   property buttonpos;
   property buttonslast;
   property buttonsinline;
   property buttonsinvisible;
   property buttonsvisible;
   property localprops;
   property localprops1; //before template
   property template;
 end;

 tstepboxframe1 = class(tstepboxframe)
  published
   property mousewheel;
 end;

 stepdirty = (sd_right,sd_up,sd_left,sd_down);

 stepeventty = procedure (const sender: tobject; const stepkind: stepkindty;
                              var handled: boolean) of object;

 tcustomstepbox = class(tpublishedwidget,istepbar,idragcontroller)
  private
   fonstep: stepeventty;
   function getframe: tstepboxframe;
   procedure setframe(const value: tstepboxframe);
  protected
   fdragcontroller: tdragcontroller;
   procedure internalcreateframe; override;
   procedure widgetregionchanged(const sender: twidget); override;
   procedure clientmouseevent(var info: mouseeventinfoty); override;
   procedure mouseevent(var info: mouseeventinfoty); override;
   procedure mousewheelevent(var info: mousewheeleventinfoty); override;
   function dostep(const event: stepkindty; const adelta: real;
                       ashiftstate: shiftstatesty): boolean; virtual;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property onstep: stepeventty read fonstep write fonstep;
  published
   property optionswidget default defaultoptionswidgetnofocus;
   property frame: tstepboxframe read getframe write setframe;
 end;

 tstepbox = class(tcustomstepbox)
  published
   property onstep;
 end;

implementation
uses
 msekeyboard,sysutils,mseactions,msestreaming,mseassistiveserver;
type
 tcustomframe1 = class(tcustomframe);
 ttaborderoverride1 = class(ttaborderoverride);

{ tcustombutton }

constructor tcustombutton.create(aowner: tcomponent);
begin
 initcaptioninfo(finfo.ca);
 finfo.ca.imagepos:= ip_center;
 initactioninfo(factioninfo);
 inherited;
 include(fwidgetstate1,ws1_nodesignframe);
 size:= makesize(defaultbuttonwidth,defaultbuttonheight);
end;

destructor tcustombutton.destroy;
begin
 if bo_updateonidle in foptions then begin
  application.unregisteronidle({$ifdef FPC}@{$endif}doidle);
 end;
 inherited;
end;

procedure tcustombutton.setoptions(const avalue: buttonoptionsty);
var
 delta: buttonoptionsty;
begin
 if avalue <> foptions then begin
  delta:= buttonoptionsty(
        {$ifdef FPC}longword{$else}longword{$endif}(foptions) xor
        {$ifdef FPC}longword{$else}longword{$endif}(avalue));
  if bo_updateonidle in delta then begin
   if (bo_updateonidle in avalue) and
                            not (csdesigning in componentstate) then begin
    application.registeronidle({$ifdef FPC}@{$endif}doidle);
   end
   else begin
    application.unregisteronidle({$ifdef FPC}@{$endif}doidle);
   end;
  end;
 end;
 inherited;
 if bo_shortcutcaption in avalue then begin
  setactionoptions(iactionlink(self),factioninfo.options + [mao_shortcutcaption]);
 end
 else begin
  setactionoptions(iactionlink(self),factioninfo.options - [mao_shortcutcaption]);
 end;
end;

function tcustombutton.verticalfontheightdelta: boolean;
begin
 result:= tf_rotate90 in textflags;
end;

procedure tcustombutton.updatehotkeys();
begin
 inherited;
 calccaptiontext(factioninfo);
end;

procedure tcustombutton.synctofontheight;
begin
 inherited;
 if tf_rotate90 in textflags then begin
  bounds_cx:= font.glyphheight + innerclientframewidth.cx + 6;
 end
 else begin
  bounds_cy:= font.glyphheight + innerclientframewidth.cy + 6;
 end;
end;

procedure tcustombutton.doexecute;
var
 b1: boolean;
begin
 if (fmodalresult <> mr_none) or
  (options * [bo_nocandefocus,bo_candefocuswindow] <> [bo_candefocuswindow]) or
                                            rootwidget.canparentclose then begin
  fexeccanceled:= not doactionexecute1(
         self,factioninfo,b1,false,(fmodalresult <> mr_none) or
                  (options * [bo_nocandefocus,bo_candefocuswindow] <> []));
 end
 else begin
  fexeccanceled:= true;
 end;
 if fmodalresult <> mr_none then begin
  window.modalresult:= fmodalresult;
 end;
end;

procedure tcustombutton.dopaintforeground(const canvas: tcanvas);
begin
 finfo.ca.font:= getfont;
 inherited;
end;

function tcustombutton.checkfocusshortcut(var info: keyeventinfoty): boolean;
begin
 result:= inherited checkfocusshortcut(info) or
               (bo_focusonshortcut in options) and
                     msegui.checkshortcut(info,factioninfo.captiontext,
                                     bo_altshortcut in options) and canfocus;
end;

procedure tcustombutton.doshortcut(var info: keyeventinfoty; const sender: twidget);
var
 bo1,bo2: boolean;
begin
 if not (es_processed in info.eventstate) and
               not (csdesigning in componentstate) and
                            not (shs_disabled in finfo.state) then begin
{
  if checkfocusshortcut(info) then begin
   setfocus();
  end;
}
  bo1:= doactionshortcut(self,factioninfo,info);
  if bo1 then begin
   if (bo_focusonactionshortcut in foptions) and canfocus then begin
    setfocus();
   end;
   if fmodalresult <> mr_none then begin
    window.modalresult:= fmodalresult;
   end;
  end;
  if not bo1 and not (es_preview in info.eventstate) then begin
//   bo2:= es_processed in info.eventstate;
//   exclude(info.eventstate,es_processed);
   bo2:= msegui.checkshortcut(info,factioninfo.captiontext,
                                         bo_altshortcut in options);
   exclude(info.eventstate,es_processed);
   bo1:= (bo_executeonshortcut in options) and bo2 or
   ((finfo.state * [shs_invisible,shs_disabled,shs_default] = [shs_default]) and
       (info.key = key_return) and
        ((info.shiftstate = []) or
         (bo_executedefaultonenterkey in options) and
         (info.shiftstate = [ss_second]))) and
            not (aso_nodefaultbutton in assistiveoptions);
                                   //no default button if assisted
   if bo1 then begin
    fexeccanceled:= false;
    internalexecute();
    if not fexeccanceled then begin
     if checkfocusshortcut(info) then begin
      setfocus();
     end;
    end;
    include(info.eventstate,es_processed);
   end;
  end;
  if not (es_processed in info.eventstate) then begin
   inherited;
  end;
 end
 else begin
  inherited;
 end;
end;

function tcustombutton.getframe: tframe;
begin
 result:= tframe(fframe);
end;

procedure tcustombutton.setframe(const Value: tframe);
begin
 fframe.Assign(value);
end;
{
procedure tcustombutton.enabledchanged;
begin
 inherited;
 invalidate;
end;
}
procedure tcustombutton.actionchanged;
begin
 finfo.color:= fcolor;
 actioninfotoshapeinfo(self,factioninfo,finfo,foptions);
 inherited setcolor(finfo.color);
 finfo.color:= cl_transparent;
// if csdesigning in componentstate then begin
  exclude(finfo.state,shs_invisible);
// end;
 checkautosize;
end;

procedure tcustombutton.readcaptionpos(reader: treader);
begin
 imagepos:= readcaptiontoimagepos(reader);
end;

procedure tcustombutton.readshortcut(reader: treader);
begin
 shortcut:= translateshortcut(reader.readinteger);
end;

procedure tcustombutton.readshortcut1(reader: treader);
begin
 shortcut1:= translateshortcut(reader.readinteger);
end;

procedure tcustombutton.readsc(reader: treader);
begin
 shortcuts:= readshortcutarty(reader);
end;

procedure tcustombutton.writesc(writer: twriter);
begin
 writeshortcutarty(writer,factioninfo.shortcut);
end;

procedure tcustombutton.readsc1(reader: treader);
begin
 shortcuts1:= readshortcutarty(reader);
end;

procedure tcustombutton.writesc1(writer: twriter);
begin
 writeshortcutarty(writer,factioninfo.shortcut1);
end;

procedure tcustombutton.setdisabled(const avalue: boolean);
begin
 if avalue then begin
  state:= state + [as_disabled];
 end
 else begin
  state:= state - [as_disabled];
 end;
end;

function tcustombutton.isenabledstored(): boolean;
begin
 result:= bo_noassistivedisabled in foptions;
end;

procedure tcustombutton.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('captionpos',
                             {$ifdef FPC}@{$endif}readcaptionpos,nil,false);
 filer.defineproperty('shortcut',{$ifdef FPC}@{$endif}readshortcut,nil,false);
 filer.defineproperty('shortcut1',{$ifdef FPC}@{$endif}readshortcut1,nil,false);
 filer.defineproperty('sc',{$ifdef FPC}@{$endif}readsc,
                           {$ifdef FPC}@{$endif}writesc,
       isactionshortcutstored(factioninfo) and
       ((filer.ancestor = nil) and (factioninfo.shortcut <> nil) or
       ((filer.ancestor <> nil) and
         not issameshortcut(factioninfo.shortcut,
                  tcustombutton(filer.ancestor).shortcuts))));
 filer.defineproperty('sc1',{$ifdef FPC}@{$endif}readsc1,
                           {$ifdef FPC}@{$endif}writesc1,
       isactionshortcut1stored(factioninfo) and
       ((filer.ancestor = nil) and (factioninfo.shortcut1 <> nil) or
       ((filer.ancestor <> nil) and
         not issameshortcut(factioninfo.shortcut,
                  tcustombutton(filer.ancestor).shortcuts))));
end;

procedure tcustombutton.fontchanged;
begin
 inherited;
 checkautosize;
end;

procedure tcustombutton.setcolor(const avalue: colorty);
begin
 if csloading in componentstate then begin
  inherited;      //no actionchanged
 end;
 setactioncolor(iactionlink(self),avalue);
end;

function tcustombutton.getactioninfopo: pactioninfoty;
begin
 result:= @factioninfo;
end;

function tcustombutton.shortcutseparator: msechar;
begin
 result:= ' ';
end;

procedure tcustombutton.calccaptiontext(var ainfo: actioninfoty);
begin
 mseactions.calccaptiontext(ainfo,shortcutseparator);
end;

procedure tcustombutton.setaction(const value: tcustomaction);
begin
 linktoaction(iactionlink(self),value,factioninfo);
end;

procedure tcustombutton.setonexecute(const value: notifyeventty);
begin
 setactiononexecute(iactionlink(self),value,csloading in componentstate);
end;

function tcustombutton.isonexecutestored: boolean;
begin
 result:= isactiononexecutestored(factioninfo);
end;

procedure tcustombutton.setonbeforeexecute(const avalue: accepteventty);
begin
 setactiononbeforeexecute(iactionlink(self),avalue,csloading in componentstate);
end;

function tcustombutton.isonbeforeexecutestored: boolean;
begin
 result:= isactiononbeforeexecutestored(factioninfo);
end;

procedure tcustombutton.setonafterexecute(const value: notifyeventty);
begin
 setactiononafterexecute(iactionlink(self),value,csloading in componentstate);
end;

function tcustombutton.isonafterexecutestored: boolean;
begin
 result:= isactiononafterexecutestored(factioninfo);
end;

function tcustombutton.getcaption: captionty;
begin
 result:= factioninfo.captiontext;
end;

procedure tcustombutton.setcaption(const Value: captionty);
begin
 setactioncaption(iactionlink(self),value);
end;

function tcustombutton.iscaptionstored: boolean;
begin
 result:= isactioncaptionstored(factioninfo);
end;

function tcustombutton.getimagelist: timagelist;
begin
 result:= timagelist(factioninfo.imagelist);
end;

procedure tcustombutton.setimagelist(const Value: timagelist);
begin
 setactionimagelist(iactionlink(self),Value);
end;

function tcustombutton.isimageliststored: Boolean;
begin
 result:= isactionimageliststored(factioninfo);
end;

procedure tcustombutton.setimagenr(const Value: imagenrty);
begin
 setactionimagenr(iactionlink(self),Value);
end;

function tcustombutton.isimagenrstored: Boolean;
begin
 result:= isactionimagenrstored(factioninfo);
end;

procedure tcustombutton.setimagenrdisabled(const avalue: imagenrty);
begin
 setactionimagenrdisabled(iactionlink(self),avalue);
end;

function tcustombutton.isimagenrdisabledstored: Boolean;
begin
 result:= isactionimagenrdisabledstored(factioninfo);
end;

procedure tcustombutton.setcolorglyph(const avalue: colorty);
begin
 setactioncolorglyph(iactionlink(self),avalue);
end;

function tcustombutton.iscolorglyphstored: boolean;
begin
 result:= isactioncolorglyphstored(factioninfo);
end;

function tcustombutton.gethint: msestring;
begin
 result:= factioninfo.hint;
end;

procedure tcustombutton.sethint(const Value: msestring);
begin
 setactionhint(iactionlink(self),value);
end;

function tcustombutton.ishintstored: boolean;
begin
 result:= isactionhintstored(factioninfo);
end;

function tcustombutton.getassistivecaption(): msestring;
begin
 result:= factioninfo.captiontext;
 if result = '' then begin
  result:= inherited getassistivecaption();
 end;
end;

function tcustombutton.getdisabled(): boolean;
begin
 result:= as_disabled in factioninfo.state;
end;

procedure tcustombutton.setshortcut(const avalue: shortcutty);
begin
 setactionshortcut(iactionlink(self),avalue);
end;

function tcustombutton.isshortcutstored: boolean;
begin
 result:= isactionshortcutstored(factioninfo);
end;

function tcustombutton.getshortcut: shortcutty;
begin
 result:= getsimpleshortcut(factioninfo);
end;

function tcustombutton.getshortcut1: shortcutty;
begin
 result:= getsimpleshortcut1(factioninfo);
end;

procedure tcustombutton.setshortcut1(const avalue: shortcutty);
begin
 setactionshortcut1(iactionlink(self),avalue);
end;

function tcustombutton.isshortcut1stored: boolean;
begin
 result:= isactionshortcut1stored(factioninfo);
end;

function tcustombutton.getstate: actionstatesty;
begin
 result:= factioninfo.state;
end;

procedure tcustombutton.setstate(const value: actionstatesty);
begin
 setactionstate(iactionlink(self),value);
 visible:= not (as_invisible in factioninfo.state);
 if (bo_noassistivedisabled in foptions){ and canassistive()} then begin
  if not disabled then begin
   enabled:= true;
  end;
 end
 else begin
  enabled:= not (as_disabled in factioninfo.state);
 end;
end;

procedure tcustombutton.setenabled(const avalue: boolean);
begin
 if not isenabledstored then begin
  if avalue then begin
   setactionstate(iactionlink(self),state - [as_disabled]);
  end
  else begin
   setactionstate(iactionlink(self),state + [as_disabled]);
  end;
 end;
 inherited;
end;

procedure tcustombutton.setvisible(const avalue: boolean);
begin
 if avalue then begin
  setactionstate(iactionlink(self),state - [as_invisible]);
 end
 else begin
  setactionstate(iactionlink(self),state + [as_invisible]);
 end;
 inherited;
end;

function tcustombutton.isstatestored: boolean;
begin
 result:= isactionstatestored(factioninfo);
end;

procedure tcustombutton.setimagepos(const avalue: imageposty);
begin
 if avalue <> finfo.ca.imagepos then begin
//  if avalue in [ip_left,ip_right,ip_top,ip_bottom,
//                ip_leftcenter,ip_rightcenter,
//                ip_topcenter,ip_bottomcenter] then begin
   finfo.ca.imagepos:= avalue;
//  end
//  else begin
//   finfo.ca.imagepos:= ip_center;
//  end;
  checkautosize;
  invalidate;
 end;
end;

procedure tcustombutton.setcaptiondist(const avalue: integer);
begin
 if avalue <> finfo.ca.captiondist then begin
  finfo.ca.captiondist:= avalue;
  checkautosize();
 end;
end;

procedure tcustombutton.setimagedist(const avalue: integer);
begin
 if avalue <> finfo.ca.imagedist then begin
  finfo.ca.imagedist:= avalue;
  checkautosize();
 end;
end;

procedure tcustombutton.setimagedist1(const avalue: integer);
begin
 if avalue <> finfo.ca.imagedist1 then begin
  finfo.ca.imagedist1:= avalue;
  checkautosize();
 end;
end;

procedure tcustombutton.setimagedist2(const avalue: integer);
begin
 if avalue <> finfo.ca.imagedist2 then begin
  finfo.ca.imagedist2:= avalue;
  checkautosize();
 end;
end;

{
procedure tcustombutton.setenabled(const Value: boolean);
begin
 inherited;
 if value then begin
  state:= state -[ss_disabled];
 end
 else begin
  state:= state +[ss_disabled];
 end;
end;

function tcustombutton.isenabledstored: Boolean;
begin
 result:= isactionenabledstored(factioninfo);
end;


procedure tcustombutton.setvisible(const Value: boolean);
begin
 inherited;
 setactionvisible(iactionlink(self),value);
end;

function tcustombutton.isvisiblestored: Boolean;
begin
 result:= isactionvisiblestored(factioninfo);
end;
}
procedure tcustombutton.readstate(reader: treader);
begin
 actionbeginload(iactionlink(self));
 inherited;
end;

procedure tcustombutton.loaded;
begin
 inherited;
 actionendload(iactionlink(self));
// actionchanged;
end;
{
procedure tcustombutton.doidle;
begin
 actiondoidle(factioninfo);
 inherited;
end;
}
procedure tcustombutton.doenter;
var
 int1: integer;
 widget1: twidget;
begin
 if fparentwidget <> nil then begin
  for int1:= 0 to fparentwidget.widgetcount - 1 do begin
   widget1:= fparentwidget.widgets[int1];
   if widget1 is tcustombutton then begin
    with tcustombutton(widget1) do begin
     if shs_default in finfo.state then begin
      exclude(finfo.state,shs_default);
      invalidateframestate();
     end;
    end;
   end;
  end;
 end;
 inherited;
end;

procedure tcustombutton.doexit;
var
 int1: integer;
 widget1: twidget;
begin
 if fparentwidget <> nil then begin
  for int1:= 0 to fparentwidget.widgetcount - 1 do begin
   widget1:= fparentwidget.widgets[int1];
   if widget1 is tcustombutton then begin
    with tcustombutton(widget1) do begin
     if as_default in factioninfo.state then begin
      if not (shs_default in finfo.state) then begin
       include(finfo.state,shs_default);
       invalidateframestate();
      end;
     end;
    end;
   end;
  end;
 end;
 inherited;
end;

procedure tcustombutton.getautopaintsize(var asize: sizety);
begin
 if fframe <> nil then begin
  asize:= calccaptionsize(getcanvas,finfo.ca,@tcustomframe1(fframe).fi.innerframe);
 end
 else begin
  asize:= calccaptionsize(getcanvas,finfo.ca,nil);
 end;
 inc(asize.cx,8+fautosize_cx);
 inc(asize.cy,6+fautosize_cy);
 if (fframe <> nil) then begin
  if fso_flat in fframe.optionsskin then begin
   dec(asize.cx,2);
   dec(asize.cy,2);
  end;
  if fso_noanim in fframe.optionsskin then begin
   dec(asize.cx,2);
   dec(asize.cy,2);
  end;
 end;
 if not (shs_noinnerrect in finfo.state) then begin
  outertopaintsize(asize);
//  innertopaintsize(asize);
 end;
 inherited; //check min/max size
end;

procedure tcustombutton.clientrectchanged;
begin
 inherited;
 checkautosize; //for frame.framei
end;

procedure tcustombutton.setautosize_cx(const avalue: integer);
begin
 if fautosize_cx <> avalue then begin
  fautosize_cx:= avalue;
  checkautosize;
 end;
end;

procedure tcustombutton.setautosize_cy(const avalue: integer);
begin
 if fautosize_cy <> avalue then begin
  fautosize_cy:= avalue;
  checkautosize;
 end;
end;

procedure tcustombutton.objectevent(const sender: tobject;
               const event: objecteventty);
begin
 inherited;
 if sender = finfo.ca.imagelist then begin
  if (event = oe_changed) then begin
   actionchanged;
  end;
  if (event = oe_destroyed) then begin
   finfo.ca.imagelist:= nil;
  end;
 end;
end;

procedure tcustombutton.settextflags(const avalue: textflagsty);
begin
 if finfo.ca.textflags <> avalue then begin
  finfo.ca.textflags:= checktextflags(finfo.ca.textflags,avalue);
  invalidate;
  checkautosize;
 end;
end;

procedure tcustombutton.setshortcuts(const avalue: shortcutarty);
begin
 setactionshortcuts(iactionlink(self),avalue);
end;

procedure tcustombutton.setshortcuts1(const avalue: shortcutarty);
begin
 setactionshortcuts1(iactionlink(self),avalue);
end;

procedure tcustombutton.doupdate;
begin
 if factioninfo.action <> nil then begin
  factioninfo.action.doupdate;
 end;
 if canevent(tmethod(fonupdate)) then begin
  fonupdate(self);
 end;
end;

procedure tcustombutton.doidle(var again: boolean);
begin
 doupdate;
end;

{ tcustomrichbutton }

constructor tcustomrichbutton.create(aowner: tcomponent);
begin
 fimagenrmouse:= -1;
 fimagenrclicked:= -1;
 inherited;
end;

destructor tcustomrichbutton.destroy;
begin
 inherited;
 ffaceactive.free;
 ffacedisabled.free;
 ffacemouse.free;
 ffaceclicked.free;
end;

procedure tcustomrichbutton.setimagenrmouse(const avalue: imagenrty);
begin
 if fimagenrmouse <> avalue then begin
  fimagenrmouse:= avalue;
  invalidate;
 end;
end;

procedure tcustomrichbutton.setimagenrclicked(const avalue: imagenrty);
begin
 if fimagenrclicked <> avalue then begin
  fimagenrclicked:= avalue;
  invalidate;
 end;
end;

procedure tcustomrichbutton.setcaptionrich(const avalue: msestring);
begin
 fcaptionrich:= avalue;
 factioninfo.caption1.text:= avalue;
 if avalue = '' then begin
  factioninfo.caption1.format:= nil;
 end;
 richcaptionchanged();
end;

procedure tcustomrichbutton.setrichvalue(const avalue: richstringty);
begin
 factioninfo.caption1:= avalue;
 fcaptionrich:= avalue.text;
 richcaptionchanged();
end;

function tcustomrichbutton.getrichvalue(): richstringty;
begin
 result:= factioninfo.caption1;
end;

function tcustomrichbutton.getfaceactive: tcustomface;
begin
 getoptionalobject(ffaceactive,{$ifdef FPC}@{$endif}createfaceactive);
 result:= ffaceactive;
end;

procedure tcustomrichbutton.setfaceactive(const avalue: tcustomface);
begin
 setoptionalobject(avalue,ffaceactive,{$ifdef FPC}@{$endif}createfaceactive);
 invalidate;
end;

function tcustomrichbutton.getfacemouse: tcustomface;
begin
 getoptionalobject(ffacemouse,{$ifdef FPC}@{$endif}createfacemouse);
 result:= ffacemouse;
end;

procedure tcustomrichbutton.setfacemouse(const avalue: tcustomface);
begin
 setoptionalobject(avalue,ffacemouse,{$ifdef FPC}@{$endif}createfacemouse);
 invalidate;
end;

function tcustomrichbutton.getfaceclicked: tcustomface;
begin
 getoptionalobject(ffaceclicked,{$ifdef FPC}@{$endif}createfaceclicked);
 result:= ffaceclicked;
end;

procedure tcustomrichbutton.setfaceclicked(const avalue: tcustomface);
begin
 setoptionalobject(avalue,ffaceclicked,{$ifdef FPC}@{$endif}createfaceclicked);
 invalidate;
end;

function tcustomrichbutton.getfacedisabled: tcustomface;
begin
 getoptionalobject(ffacedisabled,{$ifdef FPC}@{$endif}createfacedisabled);
 result:= ffacedisabled;
end;

procedure tcustomrichbutton.setfacedisabled(const avalue: tcustomface);
begin
 setoptionalobject(avalue,ffacedisabled,{$ifdef FPC}@{$endif}createfacedisabled);
 invalidate;
end;


procedure tcustomrichbutton.createfaceactive;
begin
 ffaceactive:= tface.create(iface(self));
end;

procedure tcustomrichbutton.createfacedisabled;
begin
 ffacedisabled:= tface.create(iface(self));
end;

procedure tcustomrichbutton.createfacemouse;
begin
 ffacemouse:= tface.create(iface(self));
end;

procedure tcustomrichbutton.createfaceclicked;
begin
 ffaceclicked:= tface.create(iface(self));
end;

function tcustomrichbutton.getactface: tcustomface;
begin
 result:= inherited getactface;
 if active then begin
  if ffaceactive <> nil then begin
   result:= ffaceactive;
  end;
 end
 else begin
  if not isenabled then begin
   if ffacedisabled <> nil then begin
    result:= ffacedisabled;
   end;
  end
  else begin
   if (shs_clicked in finfo.state) and (ffaceclicked <> nil) then begin
    result:= ffaceclicked;
   end
   else begin
    if (shs_mouse in finfo.state) and (ffacemouse <> nil) then begin
     result:= ffacemouse;
    end;
   end;
  end;
 end;
end;

procedure tcustomrichbutton.dopaintforeground(const canvas: tcanvas);
begin
 finfo.ca.imagenr:= factioninfo.imagenr;
 if shs_mouse in finfo.state then begin
  if fimagenrmouse <> -1 then begin
   finfo.ca.imagenr:= fimagenrmouse;
  end;
 end;
 if shs_clicked in finfo.state then begin
  if fimagenrclicked <> -1 then begin
   finfo.ca.imagenr:= fimagenrclicked;
  end;
 end;
 inherited;
end;

procedure tcustomrichbutton.objectchanged(const sender: tobject);
begin
 inherited;
 if ffaceactive <> nil then begin
  ffaceactive.checktemplate(sender);
 end;
 if ffacedisabled <> nil then begin
  ffacedisabled.checktemplate(sender);
 end;
 if ffacemouse <> nil then begin
  ffacemouse.checktemplate(sender);
 end;
 if ffaceclicked <> nil then begin
  ffaceclicked.checktemplate(sender);
 end;
end;

procedure tcustomrichbutton.richcaptionchanged();
begin
 if not (csloading in componentstate) then begin
  calccaptiontext(factioninfo);
  actioninfotoshapeinfo(self,factioninfo,finfo,foptions);
  invalidate();
  checkautosize();
 end;
end;

procedure tcustomrichbutton.calccaptiontext(var ainfo: actioninfoty);
begin
 if fcaptionrich = '' then begin //else don't display text of fcaption
  inherited;
 end;
end;

procedure tcustomrichbutton.readrichcaption(reader: treader);
begin
 richcaption:= readrichstring(reader);
end;

procedure tcustomrichbutton.writerichcaption(writer: twriter);
begin
 writerichstring(writer,finfo.ca.caption);
end;

procedure tcustomrichbutton.defineproperties(filer: tfiler);
var
 b1: boolean;
begin
 inherited;
 if filer.ancestor <> nil then begin
  b1:= isequalrichstring(
      tcustomrichbutton(filer.ancestor).factioninfo.caption1,
                                            factioninfo.caption1);
 end
 else begin
  b1:= not isemptyrichstring(factioninfo.caption1);
 end;
 filer.defineproperty('richcaption',@readrichcaption,@writerichcaption,b1);
end;

{
procedure tcustomrichbutton.dobeforepaint(const canvas: tcanvas);
begin
 inherited;
 if canevent(tmethod(fonbeforepaint)) then begin
  fonbeforepaint(self,canvas);
 end;
end;

procedure tcustomrichbutton.dopaintbackground(const canvas: tcanvas);
begin
 inherited;
 if canevent(tmethod(fonpaintbackground)) then begin
  fonpaintbackground(self,canvas);
 end;
end;

procedure tcustomrichbutton.doonpaint(const canvas: tcanvas);
begin
 inherited;
 if canevent(tmethod(fonpaint)) then begin
  fonpaint(self,canvas);
 end;
end;

procedure tcustomrichbutton.doafterpaint(const canvas: tcanvas);
begin
 inherited;
 if canevent(tmethod(fonafterpaint)) then begin
  fonafterpaint(self,canvas);
 end;
end;

procedure tcustomrichbutton.mouseevent(var info: mouseeventinfoty);
begin
 if canevent(tmethod(fonmouseevent)) then begin
  fonmouseevent(self,info);
 end;
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;
}
{ tstockglyphbutton }

constructor tstockglyphbutton.create(aowner: tcomponent);
begin
 inherited;
 imagelist:= stockobjects.glyphs;
 glyph:= stg_none;
end;

procedure tstockglyphbutton.setglyph(const avalue: stockglyphty);
begin
 fglyph:= avalue;
 imagenr:= ord(avalue);
end;

procedure tstockglyphbutton.setstate(const avalue: actionstatesty);
begin
 inherited setstate(avalue + [as_localimagelist,as_localimagenr]);
end;

procedure tstockglyphbutton.setaction(const avalue: tcustomaction);
begin
 inherited;
 glyph:= glyph;
 imagelist:= stockobjects.glyphs;
end;

{ trichstockglyphbutton }

constructor trichstockglyphbutton.create(aowner: tcomponent);
begin
 inherited;
 imagelist:= stockobjects.glyphs;
 glyph:= stg_none;
end;

procedure trichstockglyphbutton.setglyph(const avalue: stockglyphty);
begin
 fglyph:= avalue;
 imagenr:= ord(avalue);
end;

procedure trichstockglyphbutton.setstate(const avalue: actionstatesty);
begin
 inherited setstate(avalue + [as_localimagelist,as_localimagenr]);
end;

procedure trichstockglyphbutton.setaction(const avalue: tcustomaction);
begin
 inherited;
 glyph:= glyph;
 imagelist:= stockobjects.glyphs;
end;

{ tcustomlabel }

constructor tcustomlabel.create(aowner: tcomponent);
begin
 ftextflags:= defaultlabeltextflags;
 inherited;
 foptionswidget:= defaultlabeloptionswidget;
 foptionswidget1:= defaultlabeloptionswidget1;
 fwidgetrect.cx:= defaultlabelwidgetwidth;
 fwidgetrect.cy:= defaultlabelwidgetheight;
end;

procedure tcustomlabel.dopaintforeground(const canvas: tcanvas);
begin
 inherited;
 drawtext(canvas,frichcaption,innerclientrect,factualtextflags,font);
end;
{
function tcustomlabel.getcaption: msestring;
begin
 if lao_nounderline in foptions then begin
  result:= fcaption.text;
 end
 else begin
  result:= richstringtocaption(fcaption);
 end;
end;
}
procedure tcustomlabel.setcaption(const avalue: msestring);
begin
 fcaption:= avalue;
 if lao_nounderline in foptions then begin
  frichcaption.text:= avalue;
 end
 else begin
  captiontorichstring(avalue,frichcaption);
 end;
 checkautosize;
 invalidate;
end;

procedure tcustomlabel.updatehotkeys();
begin
 inherited;
 setcaption(fcaption);
end;

procedure tcustomlabel.settextflags(const Value: textflagsty);
begin
 if ftextflags <> value then begin
  ftextflags:= Value;
  updatetextflags;
  checkautosize;
  invalidate;
 end;
end;

function tcustomlabel.verticalfontheightdelta: boolean;
begin
 result:= tf_rotate90 in textflags
end;

procedure tcustomlabel.synctofontheight;
begin
 syncsinglelinefontheight;
end;

procedure tcustomlabel.updatetextflags;
begin
 if not (csloading in componentstate) then begin
  if isenabled or (lao_nogray in foptions) then begin
   factualtextflags:= ftextflags;
  end
  else begin
   factualtextflags:= ftextflags + [tf_grayed];
  end;
 end;
end;

procedure tcustomlabel.enabledchanged;
begin
 inherited;
 updatetextflags;
 invalidate;
end;

procedure tcustomlabel.setoptions(const avalue: labeloptionsty);
var
 opt1: labeloptionsty;
begin
 if foptions <> avalue then begin
  opt1:= foptions >< avalue;
  foptions:= avalue;
  updatetextflags;
  invalidate;
  if (lao_nounderline in opt1) and not(csreading in componentstate) then begin
   if lao_nounderline in avalue then begin
    frichcaption.text:= fcaption;
    frichcaption.format:= nil;
   end
   else begin
    captiontorichstring(fcaption,frichcaption);
   end;
   checkautosize();
  end;
 end;
end;

procedure tcustomlabel.getautopaintsize(var asize: sizety);
begin
 asize:= textrect(getcanvas,frichcaption,innerclientrect,ftextflags).size;
 innertopaintsize(asize);
end;

procedure tcustomlabel.fontchanged;
begin
 inherited;
 checkautosize;
end;

procedure tcustomlabel.clientrectchanged;
begin
 inherited;
 checkautosize; //for frame.framei
end;

procedure tcustomlabel.initnewcomponent(const ascale: real);
begin
 inherited;
 caption:= msestring(name);
end;

function tcustomlabel.checkfocusshortcut(var info: keyeventinfoty): boolean;
begin
 result:= canfocus and checkshortcut(info,fcaption,true);
end;

{ tcustomicon }

constructor tcustomicon.create(aowner: tcomponent);
begin
 fimagenum:= -1;
 fcolorglyph:= cl_default;
 fcolorbackground:= cl_default;
 fopacity:= cl_default;
 falignment:= [al_xcentered,al_ycentered];
 inherited;
 foptionswidget:= defaulticonoptionswidget;
 foptionswidget1:= defaulticonoptionswidget1;
 fwidgetrect.cx:= defaulticonwidgetwidth;
 fwidgetrect.cy:= defaulticonwidgetheight;
end;

destructor tcustomicon.destroy;
begin
 freeandnil(ftimer);
 inherited;
end;

procedure tcustomicon.setimagelist(const avalue: timagelist);
begin
 if fimagelist <> avalue then begin
  setlinkedvar(avalue,tmsecomponent(fimagelist));
  checkautosize;
  invalidate;
 end;
end;

procedure tcustomicon.setimagenum(const avalue: integer);
begin
 if fimagenum <> avalue then begin
  fimagenum:= avalue;
  invalidate;
 end;
end;

procedure tcustomicon.dopaintforeground(const canvas: tcanvas);
var
 i1: int32;
begin
 inherited;
 if fimagelist <> nil then begin
  i1:= fimagenum;
  if ftimer <> nil then begin
   i1:= i1 + fcurrentanimoffset;
  end;
  fimagelist.paint(canvas,i1,innerclientrect,falignment,fcolorglyph,
                   fcolorbackground,fopacity);
 end;
end;

procedure tcustomicon.enabledchanged;
begin
 inherited;
 invalidate;
end;

procedure tcustomicon.getautopaintsize(var asize: sizety);
begin
 inherited;
 if fimagelist <> nil then begin
  if frame <> nil then begin
   with tcustomframe1(fframe) do begin
    asize.cx:= fimagelist.width + fi.innerframe.left + fi.innerframe.right;
    asize.cy:= fimagelist.height + fi.innerframe.top + fi.innerframe.bottom;
   end;
  end
  else begin
   asize:= fimagelist.size;
  end;
 end;
end;

procedure tcustomicon.clientrectchanged;
begin
 inherited;
 checkautosize; //for framei
end;

procedure tcustomicon.setcolorglyph(const avalue: colorty);
begin
 if fcolorglyph <> avalue then begin
  fcolorglyph:= avalue;
  invalidate;
 end;
end;

procedure tcustomicon.setcolorbackground(const avalue: colorty);
begin
 if fcolorbackground <> avalue then begin
  fcolorbackground:= avalue;
  invalidate;
 end;
end;

procedure tcustomicon.setopacity(const avalue: colorty);
begin
 if fopacity <> avalue then begin
  fopacity:= avalue;
  invalidate;
 end;
end;

procedure tcustomicon.setalignment(const avalue: alignmentsty);
begin
 if falignment <> avalue then begin
  falignment:= avalue;
  checkautosize;
  invalidate;
 end;
end;

procedure tcustomicon.objectevent(const sender: tobject;
               const event: objecteventty);
var
 size1: sizety;
begin
 inherited;
 if (sender = fimagelist) and (event = oe_changed) then begin
  size1:= fimagelist.size;
  if (size1.cx <> fimagesize.cx) or (size1.cy <> fimagesize.cy) then begin
   fimagesize:= size1;
   checkautosize;
  end;
  invalidate;
 end;
end;

procedure tcustomicon.readtransparency(reader: treader);
begin
 opacity:= transparencytoopacity(reader.readinteger);
end;

procedure tcustomicon.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('transparency',@readtransparency,nil,false);
end;

procedure tcustomicon.setanim_intervalus(const avalue: int32);
begin
 if avalue <> fanim_intervalus then begin
  fanim_intervalus:= avalue;
  updateanim();
 end;
end;

procedure tcustomicon.setanim_count(const avalue: int32);
begin
 if avalue <> fanim_count then begin
  fanim_count:= avalue;
  updateanim();
 end;
end;

procedure tcustomicon.setanim_enabled(const avalue: boolean);
begin
 if avalue <> fanim_enabled then begin
  fanim_enabled:= avalue;
  updateanim();
 end;
end;

procedure tcustomicon.setanim_options(const avalue: animationoptionsty);
begin
 if avalue <> fanim_options then begin
  fanim_options:= avalue;
  updateanim();
 end;
end;

procedure tcustomicon.animtick(const sender: tobject);
begin
 inc(fcurrentanimoffset);
 if fcurrentanimoffset >= fanim_count then begin
  if ano_singleshot in fanim_options then begin
   dec(fcurrentanimoffset);
   if ftimer <> nil then begin
    ftimer.enabled:= false;
   end;
  end
  else begin
   fcurrentanimoffset:= 0;
  end;
 end;
 invalidate();
end;

procedure tcustomicon.resetanim();
begin
 fcurrentanimoffset:= -1;
 animtick(nil);
end;

procedure tcustomicon.setcurrentanimoffset(const avalue: int32);
begin
 fcurrentanimoffset:= avalue;
 invalidate();
end;

procedure tcustomicon.updateanim;
begin
 if not (csloading in componentstate) then begin
  if (fanim_intervalus > 0) and (fanim_count > 1) and
          (not (csdesigning in componentstate) or
                          (ano_designactive in fanim_options)) then begin
   if fanim_enabled  then begin
    if ftimer = nil then begin
     resetanim();
     ftimer:= tsimpletimer.create(fanim_intervalus,@animtick,false);
    end
    else begin
     ftimer.interval:= fanim_intervalus;
    end;
    if ano_singleshot in fanim_options then begin
     resetanim();
    end;
    ftimer.enabled:= true;
   end
   else begin
    if ftimer <> nil then begin
     ftimer.enabled:= false;
    end;
   end;
  end
  else begin
   freeandnil(ftimer);
  end;
 end
end;

procedure tcustomicon.loaded();
begin
 inherited;
 updateanim();
end;

procedure tcustomicon.animrestart();
begin
 updateanim();
 resetanim();
end;

{ tgroupboxframe }

constructor tgroupboxframe.create(const aintf: icaptionframe);
begin
 inherited;
 fi.levelo:= -1;
 fi.leveli:= 1;
 fi.innerframe.left:= 2;
 fi.innerframe.top:= 2;
 fi.innerframe.right:= 2;
 fi.innerframe.bottom:= 2;
 fcaptiondist:= 0;
 fcaptionoffset:= 4;
 include(foptions,cfo_captionframecentered);
end;

{ tcustomscalingwidget }

constructor tcustomscalingwidget.create(aowner: tcomponent);
begin
 ftaborderoverride:= ttaborderoverride.create(self);
 inherited;
 foptionsscale:= defaultoptionsscale;
end;

destructor tcustomscalingwidget.destroy();
begin
 inherited;
 ftaborderoverride.free();
end;

procedure tcustomscalingwidget.dolayout(const sender: twidget);
begin
 if canevent(tmethod(fonlayout)) then begin
  fonlayout(self);
 end
 else begin
  inherited;
 end;
end;

procedure tcustomscalingwidget.dofontheightdelta(var delta: integer);
begin
 if canevent(tmethod(fonfontheightdelta)) then begin
  fonfontheightdelta(self,delta);
 end;
 inherited;
end;

procedure tcustomscalingwidget.setoptionsscale(const avalue: optionsscalety);
begin
 if foptionsscale <> avalue then begin
  foptionsscale:= avalue;
  updateoptionsscale;
 end;
end;

procedure tcustomscalingwidget.updateoptionsscale();
var
 size1,size2: sizety;
 rect1: rectty;
 bo1: boolean;
 box,boy: boolean;
begin
 if foptionsscale * [osc_expandx,osc_expandy,
                    osc_shrinkx,osc_shrinky,
                    osc_invisishrinkx,osc_invisishrinky] <> [] then begin
  if (componentstate * [csloading,csdestroying] = []) then begin
   if fscaling <> 0 then begin
    include(fwidgetstate1,ws1_scaled);
   end
   else begin
    inc(fscaling);
    try
     exclude(fwidgetstate1,ws1_scaled);
     size1:= calcminscrollsize;
     bo1:= not isvisible;
     size2:= paintsize;
     box:= false;
     boy:= false;
     if (osc_invisishrinkx in foptionsscale) then begin
      if bo1 then begin
       if fsizebefore.cx = 0 then begin
        fsizebefore.cx:= size2.cx;
       end;
       size1.cx:= paintsize.cx-bounds_cx;
      end
      else begin
       if fsizebefore.cx <> 0 then begin
        if foptionsscale * [osc_shrinkx,osc_expandx] <>
                                         [osc_shrinkx,osc_expandx] then begin
         size1.cx:= fsizebefore.cx;
        end;
        fsizebefore.cx:= 0;
        box:= true;
       end;
      end;
     end;
     if (osc_invisishrinky in foptionsscale) then begin
      if bo1 then begin
       if fsizebefore.cy = 0 then begin
        fsizebefore.cy:= size2.cy;
       end;
       size1.cy:= paintsize.cy-bounds_cy;
      end
      else begin
       if fsizebefore.cy <> 0 then begin
        if foptionsscale * [osc_shrinky,osc_expandy] <>
                                         [osc_shrinky,osc_expandy] then begin
         size1.cy:= fsizebefore.cy;
        end;
        fsizebefore.cy:= 0;
        boy:= true;
       end;
      end;
     end;
     rect1.cx:= size1.cx - size2.cx;
     rect1.cy:= size1.cy - size2.cy;
     if not (bo1 and (osc_invisishrinkx in foptionsscale)) then begin
      if not (osc_expandx in foptionsscale) and not box then begin
       if rect1.cx > 0 then begin
        rect1.cx:= 0;
       end;
      end;
      if not (osc_shrinkx in foptionsscale) then begin
       if rect1.cx < 0 then begin
        rect1.cx:= 0;
       end;
      end;
     end;
     if not (bo1 and (osc_invisishrinky in foptionsscale)) then begin
      if not (osc_expandy in foptionsscale) and not boy then begin
       if rect1.cy > 0 then begin
        rect1.cy:= 0;
       end;
      end;
      if not (osc_shrinky in foptionsscale) then begin
       if rect1.cy < 0 then begin
        rect1.cy:= 0;
       end;
      end;
     end;
     rect1.pos:= fwidgetrect.pos;
     if fanchors*[an_right,an_left] = [an_right] then begin
      dec(rect1.x,rect1.cx);
     end;
     if fanchors*[an_bottom,an_top] = [an_bottom] then begin
      dec(rect1.y,rect1.cy);
     end;
     addsize1(rect1.size,fwidgetrect.size);
     internalsetwidgetrect(rect1,false);
     if bo1 then begin
      parentwidgetregionchanged(self);
     end;
    finally
     dec(fscaling)
    end;
   end;
  end;
 end;
end;

function tcustomscalingwidget.calcminshrinksize(): sizety;
var
 size1: sizety;
 box,boy: boolean;
begin
 result:= inherited calcminshrinksize;
 box:= (fanchors * [an_left,an_right] = [an_left,an_right]) and
            (osc_expandshrinkx in foptionsscale) or
                                            (osc_expandx in foptionsscale);
 boy:= (fanchors * [an_top,an_bottom] = [an_top,an_bottom]) and
            (osc_expandshrinky in foptionsscale) or
                                            (osc_expandy in foptionsscale);
 if box or boy then begin
  size1:= minscrollsize;
  addsize1(size1,framedim);
  if box and (result.cx < size1.cx) then begin
   result.cx:= size1.cx;
  end;
  if boy and (result.cy < size1.cy) then begin
   result.cy:= size1.cy;
  end;
 end;
end;

function tcustomscalingwidget.nexttaborderoverride(const sender: twidget;
               const down: boolean): twidget;
begin
 result:= ftaborderoverride.nexttaborder(sender,down);
 if result = nil then begin
  result:= inherited nexttaborderoverride(sender,down);
 end;
end;

procedure tcustomscalingwidget.beginscaling;
begin
 if fscaling = 0 then begin
  exclude(fwidgetstate1,ws1_scaled);
 end;
 inc(fscaling);
end;

procedure tcustomscalingwidget.endscaling;
begin
 dec(fscaling);
 if (fscaling = 0) and (ws1_scaled in fwidgetstate1) then begin
  updateoptionsscale;
 end;
end;

procedure tcustomscalingwidget.widgetregionchanged(const sender: twidget);
begin
 inherited;
 if not (ws_loadlock in fwidgetstate) then begin
  updateoptionsscale;
 end;
end;

procedure tcustomscalingwidget.clientrectchanged;
begin
 inherited;
 updateoptionsscale;
end;

procedure tcustomscalingwidget.poschanged;
begin
 inherited;
 if canevent(tmethod(fonmove)) then begin
  fonmove(self);
 end;
end;

procedure tcustomscalingwidget.sizechanged;
begin
 inherited;
 if canevent(tmethod(fonresize)) then begin
  fonresize(self);
 end;
end;

procedure tcustomscalingwidget.visiblepropchanged;
begin
 inherited;
 if foptionsscale * [osc_invisishrinkx,osc_invisishrinky] <> [] then begin
  updateoptionsscale;
 end;
end;

procedure tcustomscalingwidget.writestate(writer: twriter);
begin
 if (fframe <> nil) and (fframe is tcustomscrollboxframe) then begin
  tcustomscrollboxframe(fframe).showrect(nullrect,false);
 end;
 inherited;
end;

procedure tcustomscalingwidget.readonchildscaled(reader: treader);
begin
 onlayout:= notifyeventty(readmethod(reader));
end;

procedure tcustomscalingwidget.settaborderoverride(
              const avalue: ttaborderoverride);
begin
 ftaborderoverride.assign(avalue);
end;

procedure tcustomscalingwidget.readstate(reader: treader);
begin
 inherited;
 ttaborderoverride1(ftaborderoverride).endread(reader);
end;

procedure tcustomscalingwidget.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('onchildscaled',
                          {$ifdef FPC}@{$endif}readonchildscaled,nil,false);
end;

procedure tcustomscalingwidget.loaded;
begin
 inherited;
 if canevent(tmethod(fonlayout)) then begin
  postchildscaled;
 end;
end;

{ tgroupbox }

constructor tgroupbox.create(aowner: tcomponent);
begin
 inherited;
 optionswidget:= defaultgroupboxoptionswidget;
end;

procedure tgroupbox.initnewcomponent(const ascale: real);
begin
 inherited;
 internalcreateframe;
 fframe.scale(ascale);
end;

procedure tgroupbox.internalcreateframe;
begin
 tgroupboxframe.create(iscrollframe(self));
end;

procedure tgroupbox.dofocuschanged(const oldwidget: twidget;
               const newwidget: twidget);
begin
 inherited;
 if canevent(tmethod(fonfocusedwidgetchanged)) and
  (checkdescendent(oldwidget) or checkdescendent(newwidget)) then begin
  fonfocusedwidgetchanged(oldwidget,newwidget);
 end;
end;

class function tgroupbox.classskininfo: skininfoty;
begin
 result:= inherited classskininfo;
 result.objectkind:= sok_groupbox;
end;

{ tscrollbox }

constructor tscrollbox.create(aowner: tcomponent);
begin
 inherited;
 include(fwidgetstate1,ws1_designactive);
 foptionswidget:= defaultoptionswidgetmousewheel;
 foptionsscale:= defaultscrollboxoptionsscale;
 internalcreateframe;
end;

procedure tscrollbox.internalcreateframe;
begin
 tscrollboxframe.create(iscrollframe(self),self);
end;

function tscrollbox.getframe: tscrollboxframe;
begin
 result:= tscrollboxframe(inherited getframe);
end;

procedure tscrollbox.mouseevent(var info: mouseeventinfoty);
begin
 inherited;
 if not (es_processed in info .eventstate) then begin
  tscrollboxframe(fframe).mouseevent(info);
 end;
end;

procedure tscrollbox.childmouseevent(const sender: twidget;
                              var info: mouseeventinfoty);
begin
 frame.childmouseevent(sender,info);
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;

procedure tscrollbox.domousewheelevent(var info: mousewheeleventinfoty);
begin
 tscrollboxframe(fframe).domousewheelevent(info,false);
 inherited;
end;

procedure tscrollbox.setframe(const value: tscrollboxframe);
begin
 inherited setframe(value);
end;

procedure tscrollbox.widgetregionchanged(const sender: twidget);
begin
 inherited;
 if not (ws_loadlock in fwidgetstate) and not (csdestroying in componentstate) then begin
  tscrollboxframe(fframe).updateclientrect;
 end;
end;

procedure tscrollbox.doscroll(const dist: pointty);
begin
 inherited;
 if canevent(tmethod(fonscroll)) then begin
  fonscroll(self,dist);
 end;
end;

procedure tscrollbox.doscrolled(const dist: pointty);
begin
 inherited;
 if canevent(tmethod(fonscrolled)) then begin
  fonscrolled(self,dist);
 end;
end;

procedure tscrollbox.clampinview(const arect: rectty; const bottomright: boolean);
begin
 frame.showrect(removerect(arect,clientpos),bottomright);
// frame.showrect(removerect(arect,clientwidgetpos));
// frame.showrect(arect);
end;
{
procedure tscrollbox.setclientpos(const avalue: pointty);
begin
 tscrollboxframe(fframe).setclientpos(avalue);
end;
}
{ tcustomstepbox }

constructor tcustomstepbox.create(aowner: tcomponent);
begin
 inherited;
 internalcreateframe;
 if fdragcontroller = nil then begin
  fdragcontroller:= tdragcontroller.create(idragcontroller(self));
 end;
 optionswidget:= defaultoptionswidgetnofocus;
end;

destructor tcustomstepbox.destroy;
begin
 inherited;
 fdragcontroller.Free;
end;

procedure tcustomstepbox.internalcreateframe;
begin
 tstepboxframe.create(iscrollframe(self),istepbar(self));
end;

procedure tcustomstepbox.clientmouseevent(var info: mouseeventinfoty);
begin
 inherited;
 if not (es_processed in info.eventstate) then begin
  fdragcontroller.clientmouseevent(info);
 end;
end;

procedure tcustomstepbox.mouseevent(var info: mouseeventinfoty);
begin
 tstepboxframe(fframe).mouseevent(info);
 inherited;
end;

function tcustomstepbox.getframe: tstepboxframe;
begin
 result:= tstepboxframe(inherited getframe);
end;

procedure tcustomstepbox.setframe(const value: tstepboxframe);
begin
 inherited setframe(value);
end;

procedure tcustomstepbox.widgetregionchanged(const sender: twidget);
begin
 inherited;
 tscrollboxframe(fframe).updateclientrect;
end;

function tcustomstepbox.dostep(const event: stepkindty;
                      const adelta: real; ashiftstate: shiftstatesty): boolean;
begin
 result:= false;
 if canevent(tmethod(fonstep)) then begin
  result:= true;
  fonstep(self,event,result);
 end;
end;

procedure tcustomstepbox.mousewheelevent(var info: mousewheeleventinfoty);
begin
 frame.domousewheelevent(info);
 inherited;
end;

{ tpaintbox }
{
procedure tpaintbox.dobeforepaint(const canvas: tcanvas);
var
 pt1: pointty;
begin
 inherited;
 if canevent(tmethod(fonbeforepaint)) then begin
  pt1:= clientwidgetpos;
  canvas.move(pt1);
  fonbeforepaint(self,canvas);
  canvas.remove(pt1);
 end;
end;

procedure tpaintbox.dopaintbackground(const canvas: tcanvas);
begin
 inherited;
 if canevent(tmethod(fonpaintbackground)) then begin
  fonpaintbackground(self,canvas);
 end;
end;

procedure tpaintbox.doonpaint(const canvas: tcanvas);
begin
 inherited;
 if canevent(tmethod(fonpaint)) then begin
  fonpaint(self,canvas);
 end;
end;

procedure tpaintbox.doafterpaint(const canvas: tcanvas);
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
}
end.

