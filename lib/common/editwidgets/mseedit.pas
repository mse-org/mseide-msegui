{ MSEgui Copyright (c) 1999-2017 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseedit;

{$ifdef FPC}
 {$mode objfpc}{$h+}{$interfaces corba}
{$endif}
{$ifndef mse_no_ifi}
 {$define mse_with_ifi}
{$endif}

interface
uses
 msegui,mseeditglob,msegraphics,msegraphutils,msedatalist,
 mseevent,mseglob,mseguiglob,msestat,msestatfile,mserichstring,
 mseinplaceedit,msegrids,msetypes,mseshapes,msewidgets,
 msedrawtext,classes,mclasses,msereal,mseclasses,msearrayprops,
 msebitmap,msemenus,msetimer,mseactions,msekeyboard,
 msesimplewidgets,msepointer,msestrings,msescrollbar,mseassistiveclient
         {$ifdef mse_with_ifi},mseifiglob{$endif};

const
 defaulteditwidgetoptions = defaultoptionswidget
                                {+[ow_fontglyphheight,ow_autoscale]};
 defaulteditwidgetoptions1 = defaultoptionswidget1+
                                  [ow1_fontglyphheight,ow1_autoscale];
 defaulteditwidgetwidth = 100;
 defaulteditwidgetheight = 20;
 defaulttextflags = [tf_ycentered,tf_noselect];
 defaulttextflagsactive = [tf_ycentered];
 defaulttextflagsnoycentered = defaulttextflags - [tf_ycentered];
 defaulttextflagsactivenoycentered = defaulttextflagsactive - [tf_ycentered];
 defaulttextflagsempty = [tf_ycentered,tf_xcentered];

type

 teditframe = class(tcustomcaptionframe)
  protected
   function actualcolorclient(): colorty override;
  public
   constructor create(const aintf: icaptionframe);
  published
   property options;
   property levelo default -2;
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
   property framei_left default 1;
   property framei_top default 1;
   property framei_right default 1;
   property framei_bottom default 1;
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
   property colorclient {default cl_foreground};
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

 tscrolleditframe = class(tcustomthumbtrackscrollframe)
  protected
   function actualcolorclient(): colorty override;
  public
   constructor create(const aintf: iscrollframe; const scrollintf: iscrollbar);
  published
   property options;
   property optionsscroll;
   property dragbuttons;
   property levelo default -2;
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
   property colorclient {default cl_foreground};
   property framei_left default 1;
   property framei_top default 1;
   property framei_right default 1;
   property framei_bottom default 1;
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

 tscrollboxeditframe = class(tcustomscrollboxframe)
  protected
   function actualcolorclient(): colorty override;
  public
   constructor create(const aintf: iscrollframe; const owner: twidget);
  published
   property levelo default -2;
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
   property framei_left default 1;
   property framei_top default 1;
   property framei_right default 1;
   property framei_bottom default 1;
   property sbhorz;
   property sbvert;
   property colorclient {default cl_foreground};
   property caption;
   property captiontextflags;
   property captionpos;
   property captiondist;
   property captionoffset;
   property font;
   property localprops; //before template
   property localprops1; //before template
   property template;
 end;

 buttonactionty = (ba_none,ba_buttonpress,ba_buttonrelease,ba_click);
 ibutton = interface(inullinterface)
  procedure buttonaction(var action: buttonactionty; const buttonindex: integer);
 end;
 buttoneventty = procedure(const sender: tobject; var action: buttonactionty;
                       const buttonindex: integer) of object;
 framebuttonoptionty =
       (fbo_left,fbo_invisible,fbo_inactiveinvisible,
        fbo_disabled,fbo_enabled, //overrides frame readonly state
        fbo_executeonclientdblclick,
        fbo_flat,fbo_noanim,fbo_nomouseanim,fbo_noclickanim,fbo_nofocusanim);
 framebuttonoptionsty = set of framebuttonoptionty;

 tcustombuttonsframe = class;

 tframebutton = class(townedeventpersistent,iframe,iimagelistinfo)
  private
   fbuttonwidth: integer;
   foptions: framebuttonoptionsty;
   fonexecute: notifyeventty;
   faction: taction;
   fshortcut: shortcutty;
   procedure setbuttonwidth(const Value: integer);
   procedure setoptions(const Value: framebuttonoptionsty);
   procedure optionstostate();
   procedure changed;
   function getleft: boolean;
   procedure setleft(const Value: boolean);
   function getvisible: boolean;
   procedure setvisible(const Value: boolean);
   function getenabled: boolean;
   procedure setenabled(const Value: boolean);
   procedure setcolor(const avalue: colorty);
   procedure setcolorglyph(const avalue: colorty);
   procedure setimagelist(const Value: timagelist);
   procedure setimagenr(const avalue: imagenrty);
   procedure setimagenrdisabled(const avalue: imagenrty);
   function getface: tface;
   procedure setface(const avalue: tface);
   function getframe: tframe;
   procedure setframe(const avalue: tframe);
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
   function getimagelist: timagelist;
   procedure setaction(const avalue: taction);
  protected
   fframerect: rectty;
   finfo: shapeinfoty;
   fframe: tframe;
   freadonly: boolean; //for checkreadonlystate of tbuttonframe
   procedure doexec();
   procedure mouseevent(var info: mouseeventinfoty;
                 const intf: iframe; const buttonintf: ibutton;
                 const index: integer);
  public
   constructor create(aowner: tobject); override;
   destructor destroy; override;
   procedure createface;
   procedure createframe;
   procedure checktemplate(const sender: tobject);
   procedure updatewidgetstate(const awidget: twidget);
   procedure assign(source: tpersistent); override;
   property visible: boolean read getvisible write setvisible default true;
   property enabled: boolean read getenabled write setenabled default true;
   property left: boolean read getleft write setleft default false;
  published
   property width: integer read fbuttonwidth write setbuttonwidth default 0;
   property color: colorty read finfo.color write setcolor default cl_default;
   property colorglyph: colorty read finfo.ca.colorglyph
                             write setcolorglyph default cl_default;
                                 //cl_default maps to cl_glyph
   property face: tface read getface write setface;
   property frame: tframe read getframe write setframe;
   property imagelist: timagelist read finfo.ca.imagelist write setimagelist;
   property imagenr: imagenrty read finfo.ca.imagenr write setimagenr
                                                                  default -1;
   property imagenrdisabled: imagenrty read finfo.imagenrdisabled
                                 write setimagenrdisabled default -2; //grayed
   property options: framebuttonoptionsty read foptions write setoptions
                                            default [];
   property shortcut: shortcutty read fshortcut write fshortcut
                                                    default ord(key_none) ;
   property action: taction read faction write setaction;
   property onexecute: notifyeventty read fonexecute write fonexecute;
                                //executed after action execute
 end;

 tstockglyphframebutton = class(tframebutton)
  private
   function isimageliststored: boolean;
   procedure setimagelist(const Value: timagelist);
  public
   constructor create(aowner: tobject); override;
  published
   property imagelist read finfo.ca.imagelist write setimagelist
                                                     stored isimageliststored;
 end;

 framebuttonclassty = class of tframebutton;

 tframebuttons = class(townedeventpersistentarrayprop)
  private
   function getitems1(const index: integer): tframebutton;
  protected
   procedure dosizechanged; override;
   procedure checkcount(var acount: integer); override;
   procedure updatestate;
  public
   constructor create(const aowner: tcustombuttonsframe;
                    const buttonclass: framebuttonclassty);
   class function getitemclasstype: persistentclassty; override;
   procedure updatewidgetstate;
   function wantmouseevent(const apos: pointty): boolean;
   procedure dokeydown(var info: keyeventinfoty);
  public
   property items[const index: integer]: tframebutton read getitems1; default;
   procedure checktemplate(const sender: tobject);
 end;

 tcustombuttonsframe = class(teditframe)
  private
   fbuttons: tframebuttons;
   procedure setbuttons(const Value: tframebuttons);
  protected
   factivebutton: integer;
   fbuttonintf: ibutton;
   procedure getpaintframe(var aframe: framety); override;
   function getbuttonclass: framebuttonclassty; virtual;
   procedure updatestate; override;
   procedure internalpaintoverlay(const canvas: tcanvas;
                                           const arect: rectty) override;
   procedure dokeydown(var info: keyeventinfoty) override;
  public
   constructor create(const aintf: icaptionframe; const buttonintf: ibutton);
                                                   reintroduce; virtual;
   destructor destroy; override;
   procedure checktemplate(const sender: tobject); override;
   function buttonframe: framety;
   procedure updatemousestate(const sender: twidget;
                                 const info: mouseeventinfoty); override;
   procedure updatewidgetstate; override;
   procedure mouseevent(var info: mouseeventinfoty);
   procedure initgridframe; override;
   property buttons: tframebuttons read fbuttons write setbuttons;
 end;

 tbuttonsframe = class(tcustombuttonsframe)
  published
   property buttons;
 end;

 tcustombuttonframe = class(tcustombuttonsframe) //has at least one button
  private
  protected
   procedure setactivebutton(avalue: integer);
   function getbutton: tframebutton;
   procedure setbutton(const avalue: tframebutton);
  public
   constructor create(const aintf: icaptionframe; const buttonintf: ibutton);
                                                                     override;
   property activebutton: integer read factivebutton write setactivebutton
                                                                    default 0;
   property button: tframebutton read getbutton write setbutton;
 end;

 tbuttonframe = class(tcustombuttonframe)
 end;

 tmultibuttonframe = class(tcustombuttonframe)
  published
   property activebutton;
   property buttons;
 end;

 tcustomedit = class;
 texteditedeventty = procedure(const sender: tcustomedit;
                                      var atext: msestring) of object;

 emptyoptionty = (eo_defaulttext,   //use text of tfacecontroller
                  eo_showfocused,     //show empty_text if focused
                  eo_nocolorfocused); //do not show empty_color if focused
 emptyoptionsty = set of emptyoptionty;

 tcustomedit = class(tpublishedwidget,iedit)
  private
   fonchange: notifyeventty;
   fontextedited: texteditedeventty;
   foncopytoclipboard: updatestringeventty;
   fonpastefromclipboard: updatestringeventty;
   fcursorreadonly: cursorshapety;
   fonpaintimage: painteventty;
   fempty_text: msestring;
   fempty_textflags: textflagsty;
   fempty_textcolor: colorty;
   fempty_textcolorbackground: colorty;
   fempty_fontstyle: fontstylesty;
   fempty_color: colorty;
   fempty_options: emptyoptionsty;
   function getmaxlength: integer;
   function getpasswordchar: msechar;
   procedure setpasswordchar(const Value: msechar);
   function getoldtext: msestring;
   procedure settextflags(const value: textflagsty);
   procedure settextflagsactive(const value: textflagsty);
   function getcaretwidth: integer;
   procedure setcaretwidth(const Value: integer);
   procedure setcursorreadonly(const avalue: cursorshapety);
   function getoptionsedit1: optionsedit1ty;
   procedure setempty_text(const avalue: msestring);
   procedure setempty_textflags(const avalue: textflagsty);
   procedure setempty_textcolor(const avalue: colorty);
   procedure setempty_textcolorbackground(const avalue: colorty);
   procedure setempty_fontstyle(const avalue: fontstylesty);
   procedure setempty_color(const avalue: colorty);
  protected
   ftextflags: textflagsty;
   ftextflagsactive: textflagsty;
   feditor: tinplaceedit;
   foptionsedit: optionseditty;
   fstate: dataeditstatesty;
   function gettext: msestring virtual;
   procedure settext(const avalue: msestring) virtual;
//   procedure setcurrenttext(const avalue: msestring);
   function getreadonly: boolean; virtual;
   procedure setreadonly(const avalue: boolean); virtual;
   procedure setmaxlength(const avalue: integer);
   procedure updatetextflags; virtual;
   function getedittext: msestring; virtual;
   procedure updateedittext(const force: boolean);
   procedure updateemptytext();
   procedure updateflagtext(var avalue: msestring);
   function geteditor: tinplaceedit;
   function geteditfont: tfont; virtual;
   function getinnerframe: framety; virtual;
   function geteditframe: framety; virtual;
   procedure gettextrects(out outer: rectty; out inner: rectty);
   procedure setupeditor; virtual;
   function getformat(): formatinfoarty virtual;
   procedure internalcreateframe; override;
   procedure clientrectchanged; override;
   procedure getautopaintsize(var asize: sizety); override;
   procedure fontchanged; override;
   procedure enabledchanged; override;
   procedure dragstarted; override;
   function navigrect: rectty; override;

   class function classskininfo: skininfoty; override;

    //interface to inplaceedit
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure clientmouseevent(var info: mouseeventinfoty); override;
   procedure updatepopupmenu(var amenu: tpopupmenu;
                                      var mouseinfo: mouseeventinfoty); override;
   procedure doactivate; override;
   procedure dodeactivate; override;
   procedure dofocus; override;
   procedure dodefocus; override;
   procedure dopaintforeground(const canvas: tcanvas); override;
   procedure dopaintbackground(const canvas: tcanvas); override;
   procedure paintimage(const canvas: tcanvas); virtual;
   procedure painttext(const canvas: tcanvas); virtual;
   function needsfocuspaint: boolean; override;
//   procedure doafterpaint(const canvas: tcanvas); override;
   procedure rootchanged(const aflags: rootchangeflagsty); override;
   function gettextcliprect(): rectty; virtual;
   procedure showhint(const aid: int32; var info: hintinfoty); override;

   procedure dochange; virtual;
   procedure formatchanged; virtual;
   procedure internaltextedited(const aevent: texteditedeventty);
   procedure dotextedited; virtual;
   procedure emptychanged;
   procedure readpwchar(reader: treader);
   procedure writepwchar(writer: twriter);
   procedure defineproperties(filer: tfiler); override;
   function verticalfontheightdelta: boolean; override;
   procedure setoptionsedit1(const avalue: optionsedit1ty); virtual;
     //iassistiveclient
   function getassistivecaretindex(): int32 override;
   function getassistiveflags(): assistiveflagsty override;
     //iedit
   function getoptionsedit: optionseditty; virtual;
   function hasselection: boolean; virtual;
   function cangridcopy: boolean; virtual;
   procedure setoptionsedit(const avalue: optionseditty); virtual;
   procedure updatereadonlystate; virtual;
   procedure editnotification(var info: editnotificationinfoty); virtual;
   procedure updatecopytoclipboard(var atext: msestring); virtual;
   procedure updatepastefromclipboard(var atext: msestring); virtual;
   function locatecount: integer; virtual;        //number of locate values
   function locatecurrentindex: integer; virtual; //index of current row
   procedure locatesetcurrentindex(const aindex: integer); virtual;
   function getkeystring(const aindex: integer): msestring; virtual; //locate text
   function getedited: boolean; virtual;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure initnewcomponent(const ascale: real); override;
   procedure changed;
   procedure initfocus;
   procedure synctofontheight; override;
   function actualcursor(const apos: pointty): cursorshapety; override;

   property editor: tinplaceedit read feditor;
   property readonly: boolean read getreadonly write setreadonly;
   property optionsedit: optionseditty read getoptionsedit write setoptionsedit
                                                     default defaultoptionsedit;
   property optionsedit1: optionsedit1ty read getoptionsedit1
                             write setoptionsedit1 default defaultoptionsedit1;
   property passwordchar: msechar read getpasswordchar
                     write setpasswordchar stored false default #0;
           //FPC and Delphi bug: widechars are not streamed
   property cursorreadonly: cursorshapety read fcursorreadonly
                                write setcursorreadonly default cr_default;
   property maxlength: integer read getmaxlength write setmaxlength
                     default -1;
   property text: msestring read gettext write settext;
   property oldtext: msestring read getoldtext;
   property textflags: textflagsty read ftextflags write settextflags
                          default defaulttextflags;
   property textflagsactive: textflagsty read ftextflagsactive
                  write settextflagsactive default defaulttextflagsactive;
   property font: twidgetfont read getfont write setfont stored isfontstored;
   property caretwidth: integer read getcaretwidth write setcaretwidth
                                                    default defaultcaretwidth;

   property empty_options: emptyoptionsty read fempty_options
                                           write fempty_options default [];
   property empty_color: colorty read fempty_color write setempty_color
                                           default cl_none;
   property empty_font: twidgetfontempty read getfontempty write setfontempty
                                                  stored isfontemptystored;
   property empty_fontstyle: fontstylesty read fempty_fontstyle
                    write setempty_fontstyle default [];
   property empty_textflags: textflagsty read fempty_textflags
                    write setempty_textflags default defaulttextflagsempty;
   property empty_text: msestring read fempty_text write setempty_text;
   property empty_textcolor: colorty read fempty_textcolor
                                   write setempty_textcolor default cl_none;
   property empty_textcolorbackground: colorty read fempty_textcolorbackground
                          write setempty_textcolorbackground default cl_none;

   property onchange: notifyeventty read fonchange write fonchange;
   property ontextedited: texteditedeventty read fontextedited
                                                           write fontextedited;
   property oncopytoclipboard: updatestringeventty read foncopytoclipboard
                  write foncopytoclipboard;
   property onpastefromclipboard: updatestringeventty
                read fonpastefromclipboard write fonpastefromclipboard;
   property onpaintimage: painteventty read fonpaintimage write fonpaintimage;
  published
   property optionswidget1 default defaulteditwidgetoptions1; //first!
   property optionswidget default defaulteditwidgetoptions;   //first!
   property bounds_cx default defaulteditwidgetwidth;
   property bounds_cy default defaulteditwidgetheight;
 end;

 tedit = class(tcustomedit,istatfile)
  private
   ftimer: tsimpletimer;
   fontextediteddelayed: texteditedeventty;
   fstatfile: tstatfile;
   fstatvarname: msestring;
   fstatpriority: integer;
   procedure dotimer(const sender: tobject); virtual;
   function getdelay: integer;
   procedure setdelay(const avalue: integer);
   procedure setstatfile(const avalue: tstatfile);
  protected
   function gettext: msestring override;
   procedure settext(const avalue: msestring) override;
   procedure dotextedited; override;
   procedure editnotification(var info: editnotificationinfoty); override;
   procedure loaded() override;
   procedure dofocus() override;
   procedure dodefocus() override;

    //istatfile
   procedure dostatread(const reader: tstatreader); virtual;
   procedure dostatwrite(const writer: tstatwriter); virtual;
   procedure statreading;
   procedure statread;
   function getstatvarname: msestring;
   function getstatpriority: integer;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property statfile: tstatfile read fstatfile write setstatfile;
   property statvarname: msestring read getstatvarname write fstatvarname;
   property statpriority: integer read fstatpriority
                                       write fstatpriority default 0;
   property delay: integer read getdelay write setdelay default 0; //ms
   property ontextediteddelayed: texteditedeventty read fontextediteddelayed
                                                   write fontextediteddelayed;
   property optionsedit1; //before optionsedit!
   property optionsedit;
   property font;
   property textflags;
   property textflagsactive;
   property passwordchar;

   property empty_options;
   property empty_color;
   property empty_font;
   property empty_fontstyle;
   property empty_textflags;
   property empty_text;
   property empty_textcolor;
   property empty_textcolorbackground;

   property maxlength;
   property caretwidth;
   property cursorreadonly;
   property text;
   property onchange;
   property ontextedited;
   property onkeydown;
   property onkeyup;
   property oncopytoclipboard;
   property onpastefromclipboard;
 end;

implementation
uses
 sysutils,msebits,msedataedits,
 {$ifdef mse_dynpo}
 msestockobjects_dynpo,
{$else}
 msestockobjects,
{$endif}
 mseact,
 mseassistiveserver;

type
 twidget1 = class(twidget);
 tdatacol1 = class(tdatacol);
// tcustombuttonframe1 = class(tcustombuttonframe);
 tinplaceedit1 = class(tinplaceedit);

{ teditframe }

constructor teditframe.create(const aintf: icaptionframe);
begin
 inherited;
 fi.levelo:= -2;
 inflateframe1(fi.innerframe,1);
 internalupdatestate;
end;

function teditframe.actualcolorclient(): colorty;
begin
 result:= fi.colorclient;
 if result = cl_default then begin
  result:= cl_foreground;
 end;
end;


{ tscrolleditframe }

constructor tscrolleditframe.create(const aintf: iscrollframe;
                                             const scrollintf: iscrollbar);
begin
 inherited;
 fi.levelo:= -2;
 inflateframe1(fi.innerframe,1);
 internalupdatestate;
end;

function tscrolleditframe.actualcolorclient(): colorty;
begin
 result:= fi.colorclient;
 if result = cl_default then begin
  result:= cl_foreground;
 end;
end;

{ tscrollboxeditframe }

constructor tscrollboxeditframe.create(const aintf: iscrollframe;
                                                  const owner: twidget);
begin
 inherited;
 fi.levelo:= -2;
 inflateframe1(fi.innerframe,1);
 internalupdatestate;
end;

function tscrollboxeditframe.actualcolorclient(): colorty;
begin
 result:=  fi.colorclient;
 if result = cl_default then begin
  result:= cl_foreground;
 end;
end;

{ tframebutton }

constructor tframebutton.create(aowner: tobject);
begin
 finfo.color:= cl_default;
 finfo.ca.colorglyph:= cl_default;
 finfo.ca.imagenr:= -1;
 finfo.imagenrdisabled:= -2;
 fshortcut:= ord(key_none);
 include(finfo.state,shs_widgetorg);
 inherited;
end;

destructor tframebutton.destroy;
begin
 inherited;
 action:= nil; //remove link
 finfo.face.free;
 fframe.free;
end;

procedure tframebutton.changed;
begin
 if not (csloading in tcustombuttonframe(fowner).
                        fintf.getwidget.componentstate) then begin
  tcustombuttonframe(fowner).updatestate;
 end;
end;

procedure tframebutton.optionstostate();
begin
 updatebit(longword(finfo.state),ord(shs_invisible),
                                          (fbo_invisible in foptions));
 updatebit(longword(finfo.state),ord(shs_disabled),fbo_disabled in foptions);
 updatebit(longword(finfo.state),ord(shs_flat),fbo_flat in foptions);
 updatebit(longword(finfo.state),ord(shs_noanimation),fbo_noanim in foptions);
 updatebit(longword(finfo.state),ord(shs_nomouseanimation),
                                                  fbo_nomouseanim in foptions);
 updatebit(longword(finfo.state),ord(shs_noclickanimation),
                                                  fbo_noclickanim in foptions);
 updatebit(longword(finfo.state),ord(shs_nofocusanimation),
                                                  fbo_nofocusanim in foptions);
end;

procedure tframebutton.setoptions(const Value: framebuttonoptionsty);
var
 statebefore: shapestatesty;
 optionsbefore: framebuttonoptionsty;
begin
 statebefore:= finfo.state;
 optionsbefore:= foptions;
 card32(foptions):= setsinglebit(card32(Value),card32(foptions),
                          card32([fbo_disabled,fbo_enabled]));;
 optionstostate();
 if (statebefore <> finfo.state) or
       ((optionsbefore >< foptions) *
          [fbo_left,fbo_invisible,fbo_inactiveinvisible] <> []) then begin
  changed();
 end;
end;

function tframebutton.getleft: boolean;
begin
 result:= fbo_left in foptions;
end;

procedure tframebutton.setleft(const Value: boolean);
begin
 if value then begin
  setoptions(foptions + [fbo_left]);
 end
 else begin
  setoptions(foptions - [fbo_left]);
 end;
end;

function tframebutton.getvisible: boolean;
begin
 result:= not (fbo_invisible in foptions);
end;

procedure tframebutton.setvisible(const Value: boolean);
begin
 if value then begin
  setoptions(foptions - [fbo_invisible]);
 end
 else begin
  setoptions(foptions + [fbo_invisible]);
 end;
end;

function tframebutton.getenabled: boolean;
begin
 result:= not (fbo_disabled in foptions);
end;

procedure tframebutton.setenabled(const Value: boolean);
begin
 if value then begin
  setoptions(foptions - [fbo_disabled]);
 end
 else begin
  setoptions(foptions + [fbo_disabled]);
 end;
end;

procedure tframebutton.setbuttonwidth(const Value: integer);
begin
 if fbuttonwidth <> value then begin
  fbuttonwidth := Value;
  changed;
 end;
end;

procedure tframebutton.setcolor(const avalue: colorty);
begin
 if finfo.color <> avalue then begin
  finfo.color := avalue;
  changed;
 end;
end;

procedure tframebutton.setcolorglyph(const avalue: colorty);
begin
 if finfo.ca.colorglyph <> avalue then begin
  finfo.ca.colorglyph := avalue;
  changed;
 end;
end;

procedure tframebutton.doexec();
begin
 if faction <> nil then begin
  faction.execute();
 end;
 if assigned(fonexecute) then begin
  fonexecute(self);
 end;
end; //doexe

procedure tframebutton.mouseevent(var info: mouseeventinfoty;
     const intf: iframe; const buttonintf: ibutton; const index: integer);

var
 bo1,bo2: boolean;
 action1: buttonactionty;
begin
 bo2:= false;
 with finfo do begin
  bo1:= shs_clicked in state;
  if updatemouseshapestate(finfo,info,nil,nil) then begin
   invalidate;
  end;
  if shs_clicked in state then begin
   if not bo1 then begin
    action1:= ba_buttonpress;
    buttonintf.buttonaction(action1,index);
   end;
  end
  else begin
   if bo1 then begin
    action1:= ba_buttonrelease;
    buttonintf.buttonaction(action1,index);
   end;
  end;
  if bo1 and (info.eventkind = ek_buttonrelease) then begin
   action1:= ba_click;
   buttonintf.buttonaction(action1,index);
   if action1 = ba_click then begin
    doexec();
    bo2:= true;
   end;
  end;
 end;
 if (fbo_executeonclientdblclick in foptions) and not bo2 and
                (finfo.state * [shs_disabled,shs_invisible] = []) then begin
  with getwidget() do begin
   if iswidgetdblclicked(info) then begin
    doexec();
   end;
  end;
 end;
end;

procedure tframebutton.setimagelist(const Value: timagelist);
begin
 setlinkedcomponent(iobjectlink(self),value,tmsecomponent(finfo.ca.imagelist));
 changed;
end;

procedure tframebutton.setimagenr(const avalue: imagenrty);
begin
 if finfo.ca.imagenr <> avalue then begin
  finfo.ca.imagenr := avalue;
  changed;
 end;
end;

procedure tframebutton.setimagenrdisabled(const avalue: imagenrty);
begin
 if finfo.imagenrdisabled <> avalue then begin
  finfo.imagenrdisabled := avalue;
  changed;
 end;
end;


procedure tframebutton.createface;
begin
 if finfo.face = nil then begin
  finfo.face:= tface.create(iface(tcustombuttonframe(fowner).fintf.getwidget));
 end;
end;

procedure tframebutton.createframe;
begin
 if fframe = nil then begin
  tframe.create(iframe(self));
 end;
end;

function tframebutton.getface: tface;
begin
 tcustombuttonframe(fowner).fintf.getwidget.getoptionalobject(finfo.face,
                               {$ifdef FPC}@{$endif}createface);
 result:= tface(finfo.face);
end;

procedure tframebutton.setface(const avalue: tface);
begin
 tcustombuttonframe(fowner).fintf.getwidget.setoptionalobject(avalue,finfo.face,
                               {$ifdef FPC}@{$endif}createface);
 tcustombuttonframe(fowner).fintf.getwidget.invalidate;
end;

function tframebutton.getframe: tframe;
begin
 tcustombuttonframe(fowner).fintf.getwidget.getoptionalobject(fframe,
                               {$ifdef FPC}@{$endif}createframe);
 result:= fframe;
end;

procedure tframebutton.setframe(const avalue: tframe);
begin
 tcustombuttonframe(fowner).fintf.getwidget.setoptionalobject(avalue,fframe,
                               {$ifdef FPC}@{$endif}createframe);
// tcustombuttonframe(fowner).fintf.getwidget.invalidate;
 changed();
end;

procedure tframebutton.updatewidgetstate(const awidget: twidget);
//var
// invisiblebefore: boolean;
begin
// invisiblebefore:= ss_invisible in finfo.state;
 updatewidgetshapestate(finfo,awidget,(fbo_disabled in foptions) or
           freadonly and not (fbo_enabled in foptions),
                                 {fbo_invisible in foptions,}fframe);
 if (fbo_inactiveinvisible in foptions) and
  (awidget.componentstate * [csdesigning,csdestroying] = []) then begin
  if awidget.active xor not(shs_invisible in finfo.state) then begin
   togglebit1(longword(finfo.state),ord(shs_invisible));
   tcustombuttonframe(fowner).internalupdatestate();
  end;
 end;
// updatebit(longword(finfo.state),ord(ss_invisible),invisiblebefore);
end;

procedure tframebutton.assign(source: tpersistent);
begin
 if source is tframebutton then begin
  with tframebutton(source) do begin
   self.setoptions(foptions);
   self.left:= left;
   self.color:= color;
   self.imagelist:= imagelist;
   self.imagenr:= imagenr;
   self.onexecute:= onexecute;
   self.frame:= frame;
   self.face:= face;
  end;
 end;
end;

procedure tframebutton.checktemplate(const sender: tobject);
begin
 if finfo.face <> nil then begin
  finfo.face.checktemplate(sender);
 end;
 if fframe <> nil then begin
  fframe.checktemplate(sender);
 end;
end;

procedure tframebutton.setframeinstance(instance: tcustomframe);
begin
 fframe:= tframe(instance);
end;

procedure tframebutton.setstaticframe(value: boolean);
begin
 //dummy
end;

function tframebutton.getstaticframe: boolean;
begin
 result:= false;
end;

function tframebutton.getwidgetrect: rectty;
begin
 result:= nullrect;
end;

function tframebutton.getcomponentstate: tcomponentstate;
begin
 result:= tcustombuttonframe(fowner).fintf.getwidget.componentstate;
end;

function tframebutton.getmsecomponentstate: msecomponentstatesty;
begin
 result:= tcustombuttonframe(fowner).fintf.getwidget.msecomponentstate;
end;

procedure tframebutton.scrollwidgets(const dist: pointty);
begin
 //dummy
end;

procedure tframebutton.clientrectchanged;
begin
 changed;
end;

procedure tframebutton.invalidate;
begin
 tcustombuttonframe(fowner).fintf.getwidget.invalidaterect(
                                                 fframerect,org_widget);
end;

procedure tframebutton.invalidatewidget;
begin
 invalidate;
end;

procedure tframebutton.invalidaterect(const rect: rectty;
               const org: originty = org_client; const noclip: boolean = false);
begin
 invalidate;
end;

function tframebutton.getwidget: twidget;
begin
 result:= tcustombuttonframe(fowner).fintf.getwidget
end;

function tframebutton.getframestateflags: framestateflagsty;
begin
 with getwidget,finfo do begin
  result:= combineframestateflags(shs_disabled in state,focused,active,
             shs_mouse in state,shs_clicked in state);
 end;
end;

function tframebutton.getimagelist: timagelist;
begin
 result:= finfo.ca.imagelist;
end;

procedure tframebutton.setaction(const avalue: taction);
begin
 twidget1(iframe(tcustombuttonsframe(fowner).fintf).getwidget).
                          setlinkedvar(avalue,tmsecomponent(faction));
end;

{ tstockglyphframebutton}

constructor tstockglyphframebutton.create(aowner: tobject);
begin
 inherited;
 finfo.ca.imagelist:= stockobjects.glyphs;
end;

function tstockglyphframebutton.isimageliststored: boolean;
begin
 result:= finfo.ca.imagelist <> stockobjects.glyphs;
end;

procedure tstockglyphframebutton.setimagelist(const Value: timagelist);
begin
 if value = nil then begin
  inherited setimagelist(stockobjects.glyphs);
 end
 else begin
  inherited setimagelist(value);
 end;
end;

{ tframebuttons }

constructor tframebuttons.create(const aowner: tcustombuttonsframe;
                      const buttonclass: framebuttonclassty);
begin
 inherited create(aowner,buttonclass{tframebutton});
end;

class function tframebuttons.getitemclasstype: persistentclassty;
begin
 result:= tframebutton;
end;

procedure tframebuttons.dosizechanged;
begin
 if not (csloading in
         tcustombuttonframe(fowner).fintf.getwidget.componentstate) then begin
  tcustombuttonframe(fowner).updatestate;
 end;
 inherited;
end;

function tframebuttons.getitems1(const index: integer): tframebutton;
begin
 result:= tframebutton(inherited getitems(index));
end;

procedure tframebuttons.updatewidgetstate;
var
 int1: integer;
 widget1: twidget;
begin
 widget1:= tcustombuttonsframe(fowner).fintf.getwidget;
 for int1:= 0 to high(fitems) do begin
//  updatewidgetshapestate(tframebutton(fitems[int1]).finfo,widget1);
  tframebutton(fitems[int1]).updatewidgetstate(widget1);
 end;
end;

function tframebuttons.wantmouseevent(const apos: pointty): boolean;
var
 int1: integer;
begin
 result:= false;
 for int1:= 0 to high(fitems) do begin
  with tframebutton(fitems[int1]) do begin
   if not (fbo_invisible in foptions) and pointinrect(apos,fframerect) then begin
    result:= true;
    break;
   end;
  end;
 end;
end;

procedure tframebuttons.dokeydown(var info: keyeventinfoty);
var
 i1: int32;
begin
 for i1:= 0 to high(fitems) do begin
  with tframebutton(fitems[i1]) do begin
   if (finfo.state * [shs_disabled,shs_invisible] = []) and
               checkshortcutcode(fshortcut,info) then begin
    include(info.eventstate,es_processed);
    doexec();
    break;
   end;
  end;
 end;
end;

procedure tframebuttons.checktemplate(const sender: tobject);
var
 int1: integer;
begin
 for int1:= 0 to high(fitems) do begin
  tframebutton(fitems[int1]).checktemplate(sender);
 end;
end;

procedure tframebuttons.updatestate;
var
 int1: integer;
begin
 for int1:= 0 to high(fitems) do begin
  with tframebutton(fitems[int1]) do begin
   frameskinoptionstoshapestate(fframe,finfo);
   finfo.state:= finfo.state - [shs_showfocusrect,shs_showdefaultrect];
   if (fframe = nil) then begin
    optionstostate(); //restore flat and anim settings
   end;
  end;
 end;
 updatewidgetstate(); //restore disabled state
end;

procedure tframebuttons.checkcount(var acount: integer);
begin
 inherited;
 if acount <= tcustombuttonsframe(fowner).factivebutton then begin
  acount:= tcustombuttonsframe(fowner).factivebutton+1;
 end;
end;

{ tcustombuttonsframe }

constructor tcustombuttonsframe.create(const aintf: icaptionframe;
                                             const buttonintf: ibutton);
begin
 factivebutton:= -1; //none
 fbuttons:= tframebuttons.create(self,getbuttonclass);
 fbuttonintf:= buttonintf;
 aintf.setstaticframe(true);
 inherited create(aintf);
end;

destructor tcustombuttonsframe.destroy;
begin
 inherited;
 fbuttons.free;
end;

function tcustombuttonsframe.getbuttonclass: framebuttonclassty;
begin
 result:= tstockglyphframebutton;
end;

function tcustombuttonsframe.buttonframe: framety;
var
 int1: integer;
begin
 result:= nullframe;
 for int1:= 0 to fbuttons.count - 1 do begin
  with fbuttons[int1],finfo do begin
   if not (shs_invisible in state) then begin
    if fbo_left in foptions then begin
     inc(result.left,fframerect.cx);
    end
    else begin
     inc(result.right,fframerect.cx);
    end;
   end;
  end;
 end;
end;

procedure tcustombuttonsframe.getpaintframe(var aframe: framety);
var
 int1: integer;
begin
 inherited;
 for int1:= 0 to fbuttons.count-1 do begin
  with fbuttons[int1],finfo,fframerect do begin
   if not (shs_invisible in state) then begin
    cy:= fintf.getwidgetrect.cy - frameframedim.cy;
    if fbuttonwidth = 0 then begin
     cx:= cy;
    end
    else begin
     cx:= fbuttonwidth;
     if cx < 0 then begin
      cx:= 0;
     end;
    end;
    y:= fouterframe.top + fwidth.top;
    if fbo_left in foptions then begin
     x:= fouterframe.left + fwidth.left + aframe.left;
     inc(aframe.left,cx);
    end
    else begin
     x:= fintf.getwidgetrect.cx -
       (fouterframe.right + fwidth.right + cx + aframe.right);
     inc(aframe.right,cx);
    end;
    if (fframe <> nil) and
                 not (fso_noinnerrect in fframe.optionsskin) then begin
     finfo.ca.dim:= deflaterect(fframerect,fframe.paintframe);
     deflaterect1(finfo.ca.dim,fframe.frameo);
//     finfo.ca.dim:= deflaterect(fframerect,fframe.innerframe);
    end
    else begin
     finfo.ca.dim:= fframerect;
    end;
   end;
  end;
 end;
end;

procedure tcustombuttonsframe.initgridframe;
var
 int1: integer;
begin
 inherited;
 for int1:= 0 to fbuttons.count - 1 do begin
  fbuttons.items[int1].finfo.color:= cl_background;
 end;
end;

procedure tcustombuttonsframe.mouseevent(var info: mouseeventinfoty);
var
 int1: integer;
begin
 if not (csdesigning in fintf.getcomponentstate) then begin
  for int1:= 0 to fbuttons.count-1 do begin
   fbuttons[int1].mouseevent(info,fintf,fbuttonintf,int1);
  end;
 end;
end;

procedure tcustombuttonsframe.internalpaintoverlay(const canvas: tcanvas;
                                                        const arect: rectty);
var
 int1: integer;
 color1,color2: colorty;
begin
 color2:= cl_none;
 for int1:= 0 to fbuttons.count-1 do begin
  with fbuttons[int1] do begin
   if not (shs_invisible in finfo.state)
                            {(fbo_invisible in foptions)} then begin
    if fframe <> nil then begin
     canvas.save;
     fframe.paintbackground(canvas,fframerect,true,false);
    end;
    if  (color = cl_default) or (color = cl_parent) then begin
     if color2 = cl_none then begin
      color2:= fintf.getwidget.parentcolor;
     end;
     color1:= finfo.color;
     finfo.color:= color2;
     drawtoolbutton(canvas,finfo);
     finfo.color:= color1;
    end
    else begin
     drawtoolbutton(canvas,finfo);
    end;
    if fframe <> nil then begin
     canvas.restore;
     fframe.paintoverlay(canvas,fframerect);
    end;
   end;
  end;
 end;
 inherited;
end;

procedure tcustombuttonsframe.dokeydown(var info: keyeventinfoty);
begin
 if not (es_processed in info.eventstate) then begin
  fbuttons.dokeydown(info);
  if not (es_processed in info.eventstate) then begin
   inherited;
  end;
 end;
end;

procedure tcustombuttonsframe.setbuttons(const Value: tframebuttons);
begin
 fbuttons.Assign(Value);
end;

procedure tcustombuttonsframe.updatemousestate(const sender: twidget;
                             const info: mouseeventinfoty);
begin
 inherited;
 if fbuttons.wantmouseevent(info.pos) then begin
  with twidget1(sender) do begin
   fwidgetstate:= fwidgetstate + [ws_wantmousebutton,ws_wantmousemove,
                                                        ws_wantmousefocus];
  end;
 end;
end;

procedure tcustombuttonsframe.updatewidgetstate;
begin
 inherited;
 fbuttons.updatewidgetstate;
end;

procedure tcustombuttonsframe.checktemplate(const sender: tobject);
begin
 inherited;
 fbuttons.checktemplate(sender);
end;

procedure tcustombuttonsframe.updatestate;
begin
 fbuttons.updatestate; //set skin options
 inherited;
end;

{ tcutombuttonframe }

constructor tcustombuttonframe.create(const aintf: icaptionframe;
                                             const buttonintf: ibutton);
begin
 inherited;
 buttons.count:= 1;
 setactivebutton(0);
end;

procedure tcustombuttonframe.setactivebutton(avalue: integer);
begin
 if avalue < 0 then begin
  avalue:= 0;
 end;
 if avalue >= fbuttons.count then begin
  avalue:= fbuttons.count-1;
 end;
 factivebutton:= avalue;
end;

function tcustombuttonframe.getbutton: tframebutton;
begin
 result:= buttons[factivebutton];
end;

procedure tcustombuttonframe.setbutton(const avalue: tframebutton);
begin
 buttons[factivebutton].assign(avalue);
end;

{ tcustomedit }

constructor tcustomedit.create(aowner: tcomponent);
begin
 inherited;
// cursor:= cr_ibeam;
 fcursorreadonly:= cr_default;
 foptionsedit:= defaultoptionsedit;
 fwidgetrect.cx:= defaulteditwidgetwidth;
 fwidgetrect.cy:= defaulteditwidgetheight;
 if feditor = nil then begin
  feditor:= tinplaceedit.create(self,iedit(self),true);
 end;
 maxlength:= -1;
 foptionswidget:= defaulteditwidgetoptions;
 foptionswidget1:= defaulteditwidgetoptions1;
 ftextflags:= defaulttextflags;
 ftextflagsactive:= defaulttextflagsactive;
 fempty_textflags:= defaulttextflagsempty;
 fempty_textcolor:= cl_none;
 fempty_textcolorbackground:= cl_none;
 fempty_color:= cl_none;
 updatetextflags;
end;

destructor tcustomedit.destroy;
begin
 inherited;
 feditor.free;
end;

procedure tcustomedit.doactivate;
begin
 inherited;
 feditor.doactivate;
 if (oe_focusrectonreadonly in foptionsedit) and
                         (oe_readonly in optionsedit) and focused then begin
  invalidate;
 end;
end;

procedure tcustomedit.dodeactivate;
begin
 inherited;
 feditor.dodeactivate;
 if (oe_focusrectonreadonly in foptionsedit) and
                         (oe_readonly in optionsedit) and focused then begin
  invalidate;
 end;
end;

procedure tcustomedit.dofocus;
begin
 inherited;
 initfocus;
end;

procedure tcustomedit.dodefocus;
begin
 if not (csdestroying in componentstate) and (fwindow <> nil) and
    fwindow.haswinid
    then begin
  feditor.dodefocus;
 end;
 inherited;
end;

procedure tcustomedit.dokeydown(var info: keyeventinfoty);
begin
 doonkeydown(info);
 if not (es_processed in info.eventstate) then begin
  if not (es_child in info.eventstate) then begin
   feditor.dokeydown(info);
  end;
  if not (es_processed in info.eventstate) then begin
   inherited;
  end;
 end;
end;
{
procedure tcustomedit.dokeyup(var info: keyeventinfoty);
begin
 if canevent(tmethod(fonkeyup)) then begin
  fonkeyup(self,info);
 end;
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;
}
procedure tcustomedit.clientmouseevent(var info: mouseeventinfoty);
begin
 feditor.mouseevent(info);
 inherited;
end;

procedure tcustomedit.painttext(const canvas: tcanvas);
begin
 feditor.dopaint(canvas);
end;

procedure tcustomedit.dopaintforeground(const canvas: tcanvas);
begin
 inherited;
 paintimage(canvas);
 painttext(canvas);
end;

procedure tcustomedit.dopaintbackground(const canvas: tcanvas);
begin
 inherited;
 if (fempty_color <> cl_none) and
         (fstate * [des_emptytext,des_grayed] = [des_emptytext]) and
         (not (eo_nocolorfocused in fempty_options) or not focused)then begin
  canvas.fillrect(paintclientrect,fempty_color);
 end;
end;

function tcustomedit.needsfocuspaint: boolean;
begin
 result:= inherited needsfocuspaint or
           ([oe_focusrectonreadonly,oe_readonly] * optionsedit =
                                 [oe_focusrectonreadonly,oe_readonly]);
end;
{
procedure tcustomedit.doafterpaint(const canvas: tcanvas);
begin
 if ([oe_focusrectonreadonly,oe_readonly] * optionsedit =
        [oe_focusrectonreadonly,oe_readonly]) and focused and active then begin
  drawfocusrect(canvas,paintrect);
 end;
 inherited;
end;
}
procedure tcustomedit.editnotification(var info: editnotificationinfoty);
begin
 case info.action of
  ea_textchanged: begin
   dochange;
  end;
  ea_textedited,ea_undone: begin
   dotextedited;
  end;
  ea_resetemptytext: begin
   if des_emptytext in fstate then begin
    exclude(fstate,des_emptytext);
    updateemptytext();
   end;
  end;
  else; // Added to make compiler happy
 end;
end;

procedure tcustomedit.updatecopytoclipboard(var atext: msestring);
begin
 if canevent(tmethod(foncopytoclipboard)) then begin
  foncopytoclipboard(self,atext);
 end;
end;

procedure tcustomedit.updatepastefromclipboard(var atext: msestring);
begin
 if canevent(tmethod(fonpastefromclipboard)) then begin
  fonpastefromclipboard(self,atext);
 end;
end;

function tcustomedit.locatecount: integer;        //number of locate values
begin
 result:= 0;
end;

function tcustomedit.locatecurrentindex: integer; //index of current row
begin
 result:= -1;
end;

procedure tcustomedit.locatesetcurrentindex(const aindex: integer);
begin
 //dummy
end;

function tcustomedit.getkeystring(const aindex: integer): msestring; //locate text
begin
 result:= '';
end;

class function tcustomedit.classskininfo: skininfoty;
begin
 result:= inherited classskininfo;
 result.objectkind:= sok_edit;
end;

function tcustomedit.getoptionsedit: optionseditty;
begin
 result:= foptionsedit;
end;

function tcustomedit.getreadonly: boolean;
begin
 result:= oe_readonly in foptionsedit;
end;

procedure tcustomedit.setreadonly(const avalue: boolean);
begin
 if avalue <> (oe_readonly in foptionsedit) then begin
  if avalue then begin
   optionsedit:= optionsedit + [oe_readonly];
  end
  else begin
   optionsedit:= optionsedit - [oe_readonly];
  end;
  setupeditor;
 end;
end;

procedure tcustomedit.setoptionsedit(const avalue: optionseditty);
var
 opt1: optionsedit1ty;
 opt: optionseditty;
begin
 if foptionsedit <> avalue then begin
  opt1:= feditor.optionsedit1;
  transferoptionsedit(self,avalue,opt,opt1);
  feditor.optionsedit1:= opt1;
  foptionsedit:= optionseditty(setsinglebit(card32(opt),card32(foptionsedit),
                                 card32([oe_homeonenter,oe_endonenter])));
  updatereadonlystate;
 end;
end;

function tcustomedit.getoptionsedit1: optionsedit1ty;
begin
 result:= feditor.optionsedit1;
end;

procedure tcustomedit.setempty_text(const avalue: msestring);
begin
 fempty_text:= avalue;
 formatchanged;
end;

procedure tcustomedit.setempty_textflags(const avalue: textflagsty);
begin
 if avalue <> fempty_textflags then begin
  fempty_textflags:= checktextflags(fempty_textflags,avalue);
  emptychanged;
 end;
end;

procedure tcustomedit.setempty_textcolor(const avalue: colorty);
begin
 if avalue <> fempty_textcolor then begin
  fempty_textcolor:= avalue;
  emptychanged;
 end;
end;

procedure tcustomedit.setempty_textcolorbackground(const avalue: colorty);
begin
 if avalue <> fempty_textcolorbackground then begin
  fempty_textcolorbackground:= avalue;
  emptychanged;
 end;
end;

procedure tcustomedit.setempty_fontstyle(const avalue: fontstylesty);
begin
 if avalue <> fempty_fontstyle then begin
  fempty_fontstyle:= avalue;
  emptychanged;
 end;
end;

procedure tcustomedit.setempty_color(const avalue: colorty);
begin
 if avalue <> fempty_color then begin
  fempty_color:= avalue;
  invalidate;
 end;
end;

procedure tcustomedit.setoptionsedit1(const avalue: optionsedit1ty);
var
 optbefore: optionsedit1ty;
begin
 optbefore:= feditor.optionsedit1;
 feditor.optionsedit1:= avalue;
 if oe1_readonlydialog in optionsedit1ty(
          {$ifdef FPC}longword{$else}byte{$endif}(avalue) xor
          {$ifdef FPC}longword{$else}byte{$endif}(optbefore)) then begin
  updatereadonlystate;
 end;
end;

function tcustomedit.getassistivecaretindex(): int32;
begin
 result:= feditor.curindex;
end;

function tcustomedit.getassistiveflags(): assistiveflagsty;
begin
 result:= inherited getassistiveflags + [asf_textedit];
 if not feditor.canedit then begin
  include(result,asf_readonly);
 end;
end;

function tcustomedit.geteditfont: tfont;
begin
 result:= getfont1;
end;

function tcustomedit.getinnerframe: framety;
begin
 result:= minimalframe;
end;

function tcustomedit.geteditframe: framety;
begin
 result:= nullframe;
end;

procedure tcustomedit.gettextrects(out outer: rectty; out inner: rectty);
var
 fra1: framety;
begin
 fra1:= geteditframe;
 if fframe = nil then begin
  outer:= deflaterect(clientrect,fra1);
  inner:= deflaterect(outer,getinnerframe);
 end
 else begin
  outer:= deflaterect(clientsizerect,fra1);
  inner:= deflaterect(innerclientrect,fra1);
 end;
end;

procedure tcustomedit.setupeditor;
var
 outer1,inner1: rectty;
begin
 if not (csloading in componentstate) then begin
  gettextrects(outer1,inner1);
  with feditor do begin
   setup(text,curindex,true,inner1,outer1,getformat(),nil,geteditfont);
  end;
 end;
end;

function tcustomedit.getformat(): formatinfoarty;
begin
 result:= nil;
end;

{
procedure tcustomedit.setupeditor;
var
 fra1: framety;
begin
 if not (csloading in componentstate) then begin
  fra1:= geteditframe;
  with feditor do begin
   if fframe = nil then begin
    setup(text,curindex,true,
         deflaterect(clientrect,addframe(fra1,getinnerframe)),
                             deflaterect(clientrect,fra1),nil,nil,geteditfont);
   end
   else begin
    setup(text,curindex,true,deflaterect(innerclientrect,fra1),
         deflaterect(makerect(nullpoint,clientsize),fra1),nil,nil,geteditfont);
   end;
  end;
 end;
end;
}
function tcustomedit.verticalfontheightdelta: boolean;
begin
 result:= tf_rotate90 in textflags;
end;

procedure tcustomedit.synctofontheight;
var
// int1: integer;
 fram1: framety;
begin
 inherited;
 fram1:= getinnerframe;
 if tf_rotate90 in ftextflags then begin
  syncsinglelinefontheight(false,fram1.left + fram1.right);
 end
 else begin
  syncsinglelinefontheight(false,fram1.top + fram1.bottom);
 end;
end;

procedure tcustomedit.clientrectchanged;
begin
 inherited;
 setupeditor;
end;

procedure tcustomedit.getautopaintsize(var asize: sizety);
var
 fram1: framety;
begin
 if fframe = nil then begin
  fram1:= getinnerframe;
 end
 else begin
//  fram1:= fframe.innerframe;
  fram1:= fframe.framei;
 end;
 asize:= feditor.textrect.size;
 asize.cx:= asize.cx + fram1.left + fram1.right;
 asize.cy:= asize.cy + fram1.top + fram1.bottom;
 fram1:= geteditframe;
 asize.cx:= asize.cx + fram1.left+fram1.right;
 asize.cy:= asize.cy + fram1.top+fram1.bottom;
end;

procedure tcustomedit.fontchanged;
begin
 inherited;
 setupeditor;
 checkautosize();
end;

function tcustomedit.getmaxlength: integer;
begin
 result:= feditor.maxlength;
end;

function tcustomedit.getpasswordchar: msechar;
begin
 result:= feditor.passwordchar;
end;

procedure tcustomedit.setmaxlength(const avalue: integer);
begin
 feditor.maxlength:= avalue;
end;

procedure tcustomedit.setpasswordchar(const Value: msechar);
begin
 feditor.passwordchar:= value;
end;

procedure tcustomedit.internalcreateframe;
begin
 teditframe.create(iscrollframe(self));
end;

function tcustomedit.gettext: msestring;
begin
 result:= feditor.text;
end;

function tcustomedit.getoldtext: msestring;
begin
 result:= feditor.oldtext;
end;

procedure tcustomedit.settext(const avalue: msestring);
begin
 feditor.text:= avalue;
 if (avalue = '') and (not focused or
                         (eo_showfocused in fempty_options)) then begin
  if not (des_emptytext in fstate) then begin
   include(fstate,des_emptytext);
   updateemptytext();
  end;
 end
 else begin
  if des_emptytext in fstate then begin
   exclude(fstate,des_emptytext);
   updateemptytext();
  end;
 end;
end;
{
procedure tcustomedit.setcurrenttext(const avalue: msestring);
begin
 feditor.text:= avalue;
 if avalue <> '' then begin
  exclude(fstate,des_emptytext);
 end;
end;
}
function tcustomedit.getedittext: msestring;
begin
 result:= text;
end;

procedure tcustomedit.updateemptytext();
begin
 if des_emptytext in fstate then begin
  include(tinplaceedit1(feditor).fstate,ies_emptytext);
  feditor.font:= getfontempty1{fempty_font};
  if fempty_textcolor <> cl_none then begin
   feditor.fontcolor:= fempty_textcolor;
  end;
  if fempty_textcolorbackground <> cl_none then begin
   feditor.fontcolorbackground:= fempty_textcolorbackground;
  end;
  if fempty_fontstyle <> [] then begin
   feditor.fontstyle:= fempty_fontstyle;
  end;
 end
 else begin
  exclude(tinplaceedit1(feditor).fstate,ies_emptytext);
  feditor.font:= geteditfont;
  feditor.fontcolor:= cl_none;
  feditor.fontcolorbackground:= cl_none;
  feditor.fontstyle:= [];
 end;
 updatetextflags();
end;

procedure tcustomedit.updateedittext(const force: boolean);
var
 mstr1: msestring;
 state1: dataeditstatesty;
begin
 state1:= fstate;
 mstr1:= getedittext();
 if (not(des_isdb in fstate) and (mstr1 = '') or (des_dbnull in fstate)) and
            (not focused or (eo_showfocused in fempty_options)) then begin
  mstr1:= fempty_text;
  include(fstate,des_emptytext);
 end
 else begin
  exclude(fstate,des_emptytext);
 end;
 feditor.text:= mstr1;
 if force or ((des_emptytext in fstate) xor
                               (des_emptytext in state1)) then begin
  updateemptytext();
 end;

{
 if not (csloading in componentstate) then begin
  if isenabled or (oe_nogray in foptionsedit) then begin
   feditor.textflags:= ftextflags;
   feditor.textflagsactive:= ftextflagsactive;
  end
  else begin
   feditor.textflags:= ftextflags + [tf_grayed];
   feditor.textflagsactive:= ftextflagsactive + [tf_grayed];
  end;
 end;
}
end;

procedure tcustomedit.updatetextflags;
var
 aflags,aflagsactive: textflagsty;
begin
 if not (csloading in componentstate) then begin
  if (des_emptytext in fstate) {and (fempty_text <> '')} and
                                         (fempty_textflags <> []) then begin
   aflags:= fempty_textflags;
   aflagsactive:= aflags;
  end
  else begin
   aflags:= textflags;
   aflagsactive:= textflagsactive;
  end;
  if isenabled or (oe_nogray in foptionsedit) then begin
   exclude(fstate,des_grayed);
   feditor.textflags:= aflags;
   feditor.textflagsactive:= aflagsactive;
  end
  else begin
   include(fstate,des_grayed);
   feditor.textflags:= aflags + [tf_grayed];
   feditor.textflagsactive:= aflagsactive + [tf_grayed];
  end;
 end;
end;

procedure tcustomedit.enabledchanged;
begin
 inherited;
 updatetextflags;
 if (fempty_color <> cl_none) and (des_emptytext in fstate) then begin
  invalidate();
 end;
end;

procedure tcustomedit.settextflags(const value: textflagsty);
begin
 if ftextflags <> value then begin
  ftextflags:= checktextflags(ftextflags,value);
  updatetextflags;
 end;
end;

procedure tcustomedit.settextflagsactive(const value: textflagsty);
begin
 if ftextflagsactive <> value then begin
  ftextflagsactive:= checktextflags(ftextflagsactive,value) {- ellipsemask};
  updatetextflags;
 end;
end;

procedure tcustomedit.dochange;
begin
 checkautosize();
 if not (ws_loadedproc in fwidgetstate) then begin
  if assistiveserver <> nil then begin
   assistiveserver.dochange(getiassistiveclient());
  end;
  if canevent(tmethod(fonchange)) then begin
   fonchange(self);
  end;
  (*
{$ifdef mse_with_ifi}
  if fifiserverintf <> nil then begin
   fifiserverintf.valuechanged(iificlient(self));
  end;
{$endif}
  *)
 end;
end;

procedure tcustomedit.formatchanged();
begin
 if not (csloading in componentstate) then begin
  invalidate();
  checkautosize();
 end;
end;

procedure tcustomedit.internaltextedited(const aevent: texteditedeventty);
var
 mstr1: msestring;
begin
 if canevent(tmethod(aevent)) then begin
  mstr1:= text;
  aevent(self,mstr1);
  if mstr1 <> text then begin
   text:= mstr1;
  end;
//  feditor.oldtext:= mstr1;
 end;
end;

procedure tcustomedit.dotextedited;
begin
 internaltextedited(fontextedited);
end;

procedure tcustomedit.emptychanged;
begin
 if not (csloading in componentstate) then begin
  updateedittext(true);
 end;
end;

procedure tcustomedit.initnewcomponent(const ascale: real);
begin
 createframe;
 fframe.scale(ascale);
 inherited;
end;

procedure tcustomedit.initfocus;
begin
 feditor.dofocus;
end;

procedure tcustomedit.rootchanged(const aflags: rootchangeflagsty);
begin
 inherited;
 feditor.poschanged;
end;

function tcustomedit.getedited: boolean;
begin
 result:= false;
end;

procedure tcustomedit.changed;
begin
 dochange;
end;

procedure tcustomedit.updateflagtext(var avalue: msestring);
begin
 if oe_trimleft in foptionsedit then begin
  avalue:= trimleft(avalue);
 end;
 if oe_trimright in foptionsedit then begin
  avalue:= trimright(avalue);
 end;
 if oe_uppercase in foptionsedit then begin
  avalue:= mseuppercase(avalue);
 end
 else begin
  if oe_lowercase in foptionsedit then begin
   avalue:= mselowercase(avalue);
  end;
 end;
end;

function tcustomedit.geteditor: tinplaceedit;
begin
 result:= feditor;
end;

procedure tcustomedit.updatepopupmenu(var amenu: tpopupmenu;
                                        var mouseinfo: mouseeventinfoty);
begin
 if oe1_autopopupmenu in feditor.optionsedit1 then begin
  feditor.updatepopupmenu(amenu,popupmenu,mouseinfo,hasselection);
 end;
 inherited;
end;

function tcustomedit.getcaretwidth: integer;
begin
 result:= feditor.caretwidth;
end;

procedure tcustomedit.setcaretwidth(const Value: integer);
begin
 feditor.caretwidth:= value;
end;

procedure tcustomedit.readpwchar(reader: treader);
begin
 passwordchar:= msechar(reader.readinteger);
end;

procedure tcustomedit.writepwchar(writer: twriter);
begin
 writer.writeinteger(ord(passwordchar));
end;

procedure tcustomedit.defineproperties(filer: tfiler);
var
 bo1: boolean;
begin
 inherited;
 if filer.ancestor <> nil then begin
  bo1:= tcustomedit(filer.ancestor).passwordchar <> passwordchar;
 end
 else begin
  bo1:= passwordchar <> #0;
 end;
 filer.defineproperty('pwchar',{$ifdef FPC}@{$endif}readpwchar,
                                   {$ifdef FPC}@{$endif}writepwchar,bo1);
end;

procedure tcustomedit.updatereadonlystate;
begin
 if feditor <> nil then begin
  feditor.updatecaret;
 end;
 cursorchanged;
 if (oe_focusrectonreadonly in foptionsedit) and focused and active then begin
  invalidate;
 end;
end;

function tcustomedit.hasselection: boolean;
begin
 result:= false;
end;

function tcustomedit.cangridcopy: boolean;
begin
 result:= false;
end;

function tcustomedit.gettextcliprect(): rectty;
begin
 result:= clippedpaintrect();
 subpoint1(result.pos,paintpos);
end;

procedure tcustomedit.showhint(const aid: int32; var info: hintinfoty);
begin
 if (oe_hintclippedtext in foptionsedit) and
          editor.lasttextclipped(gettextcliprect) and getshowhint then begin
  info.caption:= text;
 end;
 inherited;
end;

procedure tcustomedit.dragstarted;
begin
 feditor.dragstarted;
 inherited;
end;

procedure tcustomedit.setcursorreadonly(const avalue: cursorshapety);
begin
 if fcursorreadonly <> avalue then begin
  fcursorreadonly:= avalue;
  cursorchanged;
 end;
end;

function tcustomedit.actualcursor(const apos: pointty): cursorshapety;
begin
 if oe_readonly in foptionsedit then begin
  result:= fcursorreadonly;
 end
 else begin
  result:= inherited actualcursor(apos);
  if result = cr_default then begin
   result:= cr_ibeam;
  end;
 end;
end;

procedure tcustomedit.paintimage(const canvas: tcanvas);
begin
 if canevent(tmethod(fonpaintimage)) then begin
  fonpaintimage(self,canvas);
 end;
end;

function tcustomedit.navigrect: rectty;
begin
 result:= inherited navigrect();
// result:= frameinnerrect;
// result:= paintframerect;
end;

{ tedit }

constructor tedit.create(aowner: tcomponent);
begin
 inherited;
 ftimer:= tsimpletimer.create(0,@dotimer,false,[to_single]);
end;

destructor tedit.destroy;
begin
 ftimer.free;
 inherited;
end;

procedure tedit.dotimer(const sender: tobject);
begin
 internaltextedited(fontextediteddelayed);
end;

function tedit.getdelay: integer;
begin
 result:= ftimer.interval div 1000;
end;

procedure tedit.setdelay(const avalue: integer);
begin
 ftimer.interval:= avalue * 1000;
end;

procedure tedit.dotextedited;
begin
 inherited;
 ftimer.restart;
end;

procedure tedit.editnotification(var info: editnotificationinfoty);
var
 mstr1: msestring;
begin
 inherited;
 case info.action of
  ea_textentered: begin
   mstr1:= text;
   updateflagtext(mstr1);
   text:= mstr1;
   ftimer.fireandstop;
   initfocus;
  end;
  ea_undone: begin
   updateedittext(false);
  end;
  else;
 end;
end;

procedure tedit.loaded();
begin
 inherited;
 updateedittext(false);
end;

procedure tedit.dofocus();
begin
 updateedittext(false);
 inherited;
end;

procedure tedit.dodefocus();
var
 info1: editnotificationinfoty;
begin
 with tinplaceedit1(feditor) do begin
  if ies_edited in fstate then begin
   info1:= initactioninfo(ea_textentered);
   editnotification(info1);
  end
  else begin
   updateedittext(false);
  end;
 end;
 inherited;
end;

procedure tedit.setstatfile(const avalue: tstatfile);
begin
 setstatfilevar(istatfile(self),avalue,fstatfile);
end;

function tedit.gettext: msestring;
begin
 result:= inherited gettext();
 if des_emptytext in fstate then begin
  result:= '';
 end;
end;

procedure tedit.settext(const avalue: msestring);
begin
 inherited;
 if not (csloading in componentstate) then begin
  if avalue <> '' then begin
   exclude(fstate,des_emptytext);
  end;
  updateedittext(true);
 end;
end;

procedure tedit.dostatwrite(const writer: tstatwriter);
begin
 writer.writemsestring('text',text);
end;

procedure tedit.dostatread(const reader: tstatreader);
begin
 text:= reader.readmsestring('text',text);
end;

procedure tedit.statreading;
begin
 //dummy
end;

procedure tedit.statread;
begin
 if (oe1_checkvalueafterstatread in optionsedit1) then begin
  dotextedited;
 end;
end;

function tedit.getstatvarname: msestring;
begin
 result:= fstatvarname;
end;

function tedit.getstatpriority: integer;
begin
 result:= fstatpriority;
end;

end.
