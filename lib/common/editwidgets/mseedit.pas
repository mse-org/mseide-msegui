{ MSEgui Copyright (c) 1999-2008 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseedit;

{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}

interface
uses
 msegui,mseeditglob,msegraphics,msegraphutils,msedatalist,
 mseevent,mseglob,mseguiglob,
 mseinplaceedit,msegrids,msetypes,mseshapes,msewidgets,
 msedrawtext,classes,msereal,mseclasses,msearrayprops,msebitmap,msemenus,
 msesimplewidgets,msepointer,msestrings,msescrollbar
         {$ifdef mse_with_ifi},mseifiglob{$endif};

const
 defaulteditwidgetoptions = defaultoptionswidget+[ow_fontglyphheight,ow_autoscale];
 defaulteditwidgetwidth = 100;
 defaulteditwidgetheight = 20;
 defaulttextflags = [tf_ycentered,tf_noselect];
 defaulttextflagsactive = [tf_ycentered];

type

 teditframe = class(tcustomcaptionframe)
  public
   constructor create(const intf: icaptionframe);
  published
   property options;
   property levelo default -2;
   property leveli;
   property framewidth;
   property colorframe;
   property colorframeactive;
   property colordkshadow;
   property colorshadow;
   property colorlight;
   property colorhighlight;
   property colordkwidth;
   property colorhlwidth;
   property framei_left default 1;
   property framei_top default 1;
   property framei_right default 1;
   property framei_bottom default 1;

   property frameimage_list;
   property frameimage_left;
   property frameimage_top;
   property frameimage_right;
   property frameimage_bottom;
   property frameimage_offset;
   property frameimage_offsetmouse;
   property frameimage_offsetclicked;
   property frameimage_offsetactive;
   property frameimage_offsetactivemouse;
   property frameimage_offsetactiveclicked;

   property colorclient default cl_foreground;
   property caption;
   property captionpos;
   property captiondist;
//   property captiondistouter;
//   property captionframecentered;
   property captionoffset;
//   property captionnoclip;
   property font;
   property localprops; //before template
   property template;
 end;
 
 tscrolleditframe = class(tcustomthumbtrackscrollframe)
  public
   constructor create(const intf: iscrollframe; const scrollintf: iscrollbar);
  published
   property levelo default -2;
   property leveli;
   property framewidth;
   property colorframe;
   property colorframeactive;
   property colordkshadow;
   property colorshadow;
   property colorlight;
   property colorhighlight;
   property colordkwidth;
   property colorhlwidth;
   property framei_left default 1;
   property framei_top default 1;
   property framei_right default 1;
   property framei_bottom default 1;
   property sbhorz; 
   property sbvert;
   property colorclient default cl_foreground;
   property caption;
   property captionpos;
   property captiondist;
//   property captiondistouter;
//   property captionframecentered;
   property captionoffset;
//   property captionnoclip;
   property font;
   property localprops; //before template
   property template;
 end;

 tscrollboxeditframe = class(tcustomscrollboxframe)
  public
   constructor create(const intf: iscrollframe; const owner: twidget);
  published
   property levelo default -2;
   property leveli;
   property framewidth;
   property colorframe;
   property colorframeactive;
   property colordkshadow;
   property colorshadow;
   property colorlight;
   property colorhighlight;
   property colordkwidth;
   property colorhlwidth;
   property framei_left default 1;
   property framei_top default 1;
   property framei_right default 1;
   property framei_bottom default 1;
   property sbhorz; 
   property sbvert;
   property colorclient default cl_foreground;
   property caption;
   property captionpos;
   property captiondist;
//   property captiondistouter;
//   property captionframecentered;
   property captionoffset;
//   property captionnoclip;
   property font;
   property localprops; //before template
   property template;
 end;

 buttonactionty = (ba_none,ba_buttonpress,ba_buttonrelease,ba_click);
 ibutton = interface(inullinterface)
  procedure buttonaction(var action: buttonactionty; const buttonindex: integer);
 end;
 buttoneventty = procedure(const sender: tobject; var action: buttonactionty;
                       const buttonindex: integer) of object;
 framebuttonoptionty = (fbo_left,fbo_invisible,fbo_disabled,fbo_flat,fbo_noanim);
 framebuttonoptionsty = set of framebuttonoptionty;

 tcustombuttonframe = class;
 
 tframebutton = class(townedeventpersistent,iframe)
  private
   fbuttonwidth: integer;
   foptions: framebuttonoptionsty;
   fonexecute: notifyeventty;
   procedure setbuttonwidth(const Value: integer);
   procedure setoptions(const Value: framebuttonoptionsty);
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
   procedure setimagenr(const Value: integer);
   function getface: tface;
   procedure setface(const avalue: tface);
   function getframe: tframe;
   procedure setframe(const avalue: tframe);
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
   
   function getframeclicked: boolean; virtual;
   function getframemouse: boolean; virtual;
   function getframeactive: boolean; virtual;
  protected
   fframerect: rectty;
   finfo: shapeinfoty;
   fframe: tframe;
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
   property color: colorty read finfo.color write setcolor default cl_parent;
   property colorglyph: colorty read finfo.colorglyph write setcolorglyph default cl_glyph;
   property face: tface read getface write setface;
   property frame: tframe read getframe write setframe;
   property imagelist: timagelist read finfo.imagelist write setimagelist;
   property imagenr: integer read finfo.imagenr write setimagenr default -1;
   property options: framebuttonoptionsty read foptions write setoptions
                                            default [];
   property onexecute: notifyeventty read fonexecute write fonexecute;
 end;

 tstockglyphframebutton = class(tframebutton)
  private
   function isimageliststored: boolean;
   procedure setimagelist(const Value: timagelist);
  public
   constructor create(aowner: tobject); override;
  published
   property imagelist read finfo.imagelist write setimagelist stored isimageliststored;
 end;

 framebuttonclassty = class of tframebutton;

 tframebuttons = class(townedeventpersistentarrayprop)
  private
   function getitems1(const index: integer): tframebutton;
  protected
   procedure dosizechanged; override;
   procedure updatestate;
  public
   constructor create(const aowner: tcustombuttonframe;
                    const buttonclass: framebuttonclassty);
   procedure updatewidgetstate;
   function wantmouseevent(const apos: pointty): boolean;
  public
   property items[const index: integer]: tframebutton read getitems1; default;
   procedure checktemplate(const sender: tobject);
 end;

 tcustombuttonframe = class(teditframe)
  private
   fbuttons: tframebuttons;
   procedure setbuttons(const Value: tframebuttons);
  protected
   fbuttonintf: ibutton;
   procedure getpaintframe(var aframe: framety); override;
   function getbuttonclass: framebuttonclassty; virtual;
   procedure checktemplate(const sender: tobject); override;
   procedure updatestate; override;
  public
   constructor create(const intf: icaptionframe; const buttonintf: ibutton);
                                                   reintroduce; virtual;
   destructor destroy; override;
   function buttonframe: framety;
   procedure updatemousestate(const sender: twidget; const apos: pointty); override;
   procedure updatewidgetstate; override;
   procedure paintoverlay(const canvas: tcanvas; const arect: rectty); override;
   procedure mouseevent(var info: mouseeventinfoty);
   procedure initgridframe; override;
   property buttons: tframebuttons read fbuttons write setbuttons;
 end;

 tbuttonframe = class(tcustombuttonframe)
 end;

 tmultibuttonframe = class(tcustombuttonframe)
  published
   property buttons;
 end;
 
 tcustomedit = class;
 texteditedeventty = procedure(const sender: tcustomedit;
                        var atext: msestring) of object;
                      
 
 tcustomedit = class(tpublishedwidget,iedit{$ifdef mse_with_ifi},iifiwidget{$endif})
  private
   fonchange: notifyeventty;
   fontextedited: texteditedeventty;
   ftextflags: textflagsty;
   ftextflagsactive: textflagsty;
   fonkeydown: keyeventty;
   fonkeyup: keyeventty;
{$ifdef mse_with_ifi}
   fifiserverintf: iifiserver;
   //iifiwidget
   procedure setifiserverintf(const aintf: iifiserver);
   function getifiserverintf: iifiserver;
{$endif}   
   function getmaxlength: integer;
   function getpasswordchar: msechar;
   procedure setmaxlength(const Value: integer);
   procedure setpasswordchar(const Value: msechar);
   function gettext: msestring;
   function getoldtext: msestring;
   procedure settext(const Value: msestring);
   procedure settextflags(const value: textflagsty);
   procedure settextflagsactive(const value: textflagsty);
   procedure updatetextflags;
   function getcaretwidth: integer;
   procedure setcaretwidth(const Value: integer);
   
  protected
   feditor: tinplaceedit;
   foptionsedit: optionseditty;
   foptionsdb: optionseditdbty;
   function geteditor: tinplaceedit;
   function geteditfont: tfont; virtual;
   procedure setupeditor; virtual;
   procedure internalcreateframe; override;
   procedure clientrectchanged; override;
   procedure fontchanged; override;
   procedure enabledchanged; override;

   class function classskininfo: skininfoty; override;
   function getoptionsedit: optionseditty; virtual;//iedit
   function getoptionsdb: optionseditdbty;
   function hasselection: boolean; virtual;
   function cangridcopy: boolean; virtual;
   procedure setoptionsedit(const avalue: optionseditty); virtual;
   procedure updatereadonlystate; virtual;
   procedure editnotification(var info: editnotificationinfoty); virtual;
     //interface to inplaceedit
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure dokeyup(var info: keyeventinfoty); override;
   procedure clientmouseevent(var info: mouseeventinfoty); override;
   procedure dopopup(var amenu: tpopupmenu; var mouseinfo: mouseeventinfoty); override;
   procedure doactivate; override;
   procedure dodeactivate; override;
   procedure dofocus; override;
   procedure dodefocus; override;
   procedure dopaint(const canvas: tcanvas); override;
   procedure rootchanged; override;
   procedure showhint(var info: hintinfoty); override;

   procedure dochange; virtual;
   procedure dotextedited; virtual;
   procedure readpwchar(reader: treader);
   procedure writepwchar(writer: twriter);
   procedure defineproperties(filer: tfiler); override;
   property optionsdb: optionseditdbty read foptionsdb write foptionsdb;   
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure initnewcomponent(const ascale: real); override;
   procedure changed;
   procedure initfocus;
   procedure synctofontheight; override;

   property editor: tinplaceedit read feditor;
   property optionsedit: optionseditty read getoptionsedit write setoptionsedit
                   default defaultoptionsedit;
   property passwordchar: msechar read getpasswordchar
                     write setpasswordchar stored false default #0;
           //FPC and Delphi bug: widechars are not streamed
   property maxlength: integer read getmaxlength write setmaxlength
                     default -1;
   property bounds_cx default defaulteditwidgetwidth;
   property bounds_cy default defaulteditwidgetheight;
   property text: msestring read gettext write settext;
   property oldtext: msestring read getoldtext;
   property textflags: textflagsty read ftextflags write settextflags
                          default defaulttextflags;
   property textflagsactive: textflagsty read ftextflagsactive
                  write settextflagsactive default defaulttextflagsactive;
   property font: twidgetfont read getfont write setfont stored isfontstored;
   property caretwidth: integer read getcaretwidth write setcaretwidth default defaultcaretwidth;
   property onchange: notifyeventty read fonchange write fonchange;
   property ontextedited: texteditedeventty read fontextedited write fontextedited;
   property onkeydown: keyeventty read fonkeydown write fonkeydown;
   property onkeyup: keyeventty read fonkeyup write fonkeyup;
  published
   property optionswidget default defaulteditwidgetoptions; //first!
   property cursor default cr_ibeam;
 end;

 tedit = class(tcustomedit)
  published
   property optionsedit;
   property font;
   property passwordchar;
   property maxlength;
   property text;
   property textflags;
   property textflagsactive;
   property caretwidth;
   property onchange;
   property ontextedited;
   property onkeydown;
   property onkeyup;
 end;

implementation
uses
 SysUtils,msekeyboard,msebits,msedataedits,msestockobjects,mseact;

type
 twidget1 = class(twidget);
 tdatacol1 = class(tdatacol);
 tcustombuttonframe1 = class(tcustombuttonframe);
 tinplaceedit1 = class(tinplaceedit);

{ teditframe }

constructor teditframe.create(const intf: icaptionframe);
begin
 inherited;
 fi.colorclient:= cl_foreground;
 fi.levelo:= -2;
 inflateframe(fi.innerframe,1);
 internalupdatestate;
end;

{ tscrolleditframe }

constructor tscrolleditframe.create(const intf: iscrollframe; const scrollintf: iscrollbar);
begin
 inherited;
 colorclient:= cl_foreground;
 fi.levelo:= -2;
 inflateframe(fi.innerframe,1);
 internalupdatestate;
end;

{ tscrollboxeditframe }

constructor tscrollboxeditframe.create(const intf: iscrollframe;
                                                  const owner: twidget);
begin
 inherited;
 colorclient:= cl_foreground;
 fi.levelo:= -2;
 inflateframe(fi.innerframe,1);
 internalupdatestate;
end;

{ tframebutton }

constructor tframebutton.create(aowner: tobject);
begin
 finfo.color:= cl_parent;
 finfo.colorglyph:= cl_glyph;
 finfo.imagenr:= -1;
 finfo.imagenrdisabled:= -2;
 include(finfo.state,ss_widgetorg);
 inherited;
end;

destructor tframebutton.destroy;
begin
 inherited;
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

procedure tframebutton.setoptions(const Value: framebuttonoptionsty);
begin
 if foptions <> value then begin
  foptions:= Value;
  updatebit(cardinal(finfo.state),ord(ss_invisible),fbo_invisible in value);
  updatebit(cardinal(finfo.state),ord(ss_disabled),fbo_disabled in value);
  updatebit(cardinal(finfo.state),ord(ss_flat),fbo_flat in value);
  updatebit(cardinal(finfo.state),ord(ss_noanimation),fbo_noanim in value);
  changed;
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
 if finfo.colorglyph <> avalue then begin
  finfo.colorglyph := avalue;
  changed;
 end;
end;

procedure tframebutton.mouseevent(var info: mouseeventinfoty;
     const intf: iframe; const buttonintf: ibutton; const index: integer);
var
 bo1: boolean;
 action: buttonactionty;
begin
 with finfo do begin
  bo1:= ss_clicked in state;
  if updatemouseshapestate(finfo,info,nil,nil) then begin
   invalidate;
  end;
  if ss_clicked in state then begin
   if not bo1 then begin
    action:= ba_buttonpress;
    buttonintf.buttonaction(action,index);
   end;
  end
  else begin
   if bo1 then begin
    action:= ba_buttonrelease;
    buttonintf.buttonaction(action,index);
   end;
  end;
  if bo1 and (info.eventkind = ek_buttonrelease) then begin
   action:= ba_click;
   buttonintf.buttonaction(action,index);
   if assigned(fonexecute) and (action = ba_click) then begin
    fonexecute(self);
   end;
  end;
 end;
end;

procedure tframebutton.setimagelist(const Value: timagelist);
begin
 setlinkedcomponent(iobjectlink(self),value,tmsecomponent(finfo.imagelist));
 changed;
end;

procedure tframebutton.setimagenr(const Value: integer);
begin
 if finfo.imagenr <> value then begin
  finfo.imagenr := Value;
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
 tcustombuttonframe(fowner).fintf.getwidget.invalidate;
end;


procedure tframebutton.updatewidgetstate(const awidget: twidget);
begin
 updatewidgetshapestate(finfo,awidget,fbo_disabled in foptions,fframe);
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

function tframebutton.getframeclicked: boolean;
begin
 result:= ss_clicked in finfo.state;
end;

function tframebutton.getframemouse: boolean;
begin
 result:= ss_mouse in finfo.state;
end;

function tframebutton.getframeactive: boolean;
begin
 result:= getwidget.active;
end;

{ tstockglyphframebutton}

constructor tstockglyphframebutton.create(aowner: tobject);
begin
 inherited;
 finfo.imagelist:= stockobjects.glyphs;
end;

function tstockglyphframebutton.isimageliststored: boolean;
begin
 result:= finfo.imagelist <> stockobjects.glyphs;
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

constructor tframebuttons.create(const aowner: tcustombuttonframe;
                      const buttonclass: framebuttonclassty);
begin
 inherited create(aowner,buttonclass{tframebutton});
end;

procedure tframebuttons.dosizechanged;
begin
 tcustombuttonframe(fowner).updatestate;
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
 widget1:= tcustombuttonframe1(fowner).fintf.getwidget;
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
   frameskinoptionstoshapestate(fframe,finfo.state);
   finfo.state:= finfo.state - [ss_showfocusrect,ss_showdefaultrect];
  end;
 end;
end;

{ tcustombuttonframe }

constructor tcustombuttonframe.create(const intf: icaptionframe; const buttonintf: ibutton);
begin
 fbuttons:= tframebuttons.create(self,getbuttonclass);
 fbuttonintf:= buttonintf;
 intf.setstaticframe(true);
 inherited create(intf);
end;

destructor tcustombuttonframe.destroy;
begin
 inherited;
 fbuttons.free;
end;

function tcustombuttonframe.getbuttonclass: framebuttonclassty;
begin
 result:= tstockglyphframebutton;
end;

function tcustombuttonframe.buttonframe: framety;
var
 int1: integer;
begin
 result:= nullframe;
 for int1:= 0 to fbuttons.count - 1 do begin
  with fbuttons[int1],finfo do begin
   if not (ss_invisible in state) then begin
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

procedure tcustombuttonframe.getpaintframe(var aframe: framety);
var
 int1: integer;
begin
 inherited;
 for int1:= 0 to fbuttons.count-1 do begin
  with fbuttons[int1],finfo,fframerect do begin
   if not (ss_invisible in state) then begin
    cy:= fintf.getwidgetrect.cy - frameframewidth.cy;
    if fbuttonwidth = 0 then begin
     cx:= cy;
    end
    else begin
     cx:= fbuttonwidth;
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
    if fframe <> nil then begin
     finfo.dim:= deflaterect(fframerect,fframe.innerframe);
    end
    else begin
     finfo.dim:= fframerect;
    end;
   end;
  end;
 end;
end;

procedure tcustombuttonframe.initgridframe;
var
 int1: integer;
begin
 inherited;
 for int1:= 0 to fbuttons.count - 1 do begin
  fbuttons.items[int1].finfo.color:= cl_background;
 end;
end;

procedure tcustombuttonframe.mouseevent(var info: mouseeventinfoty);
var
 int1: integer;
begin
 if not (csdesigning in fintf.getcomponentstate) then begin
  for int1:= 0 to fbuttons.count-1 do begin
   fbuttons[int1].mouseevent(info,fintf,fbuttonintf,int1);
  end;
 end;
end;

procedure tcustombuttonframe.paintoverlay(const canvas: tcanvas;
                                                     const arect: rectty);
var
 int1: integer;
 color2: colorty;
begin
 color2:= cl_none;
 for int1:= 0 to fbuttons.count-1 do begin
  with fbuttons[int1] do begin
   if not (fbo_invisible in foptions) then begin
    if fframe <> nil then begin
     canvas.save;
     fframe.paintbackground(canvas,fframerect);
     canvas.restore;
    end;
    if color = cl_parent then begin
     if color2 = cl_none then begin
      color2:= fintf.getwidget.parentcolor;
     end;
     finfo.color:= color2;
     drawtoolbutton(canvas,finfo);
     finfo.color:= cl_parent;
    end
    else begin
     drawtoolbutton(canvas,finfo);
    end;
    if fframe <> nil then begin
     fframe.paintoverlay(canvas,fframerect);
    end;
   end;
  end;
 end;
 inherited;
end;

procedure tcustombuttonframe.setbuttons(const Value: tframebuttons);
begin
 fbuttons.Assign(Value);
end;

procedure tcustombuttonframe.updatemousestate(const sender: twidget;
               const apos: pointty);
begin
 inherited;
 if fbuttons.wantmouseevent(apos) then begin
  with twidget1(sender) do begin
   fwidgetstate:= fwidgetstate + [ws_wantmousebutton,ws_wantmousemove];
  end;
 end;
end;

procedure tcustombuttonframe.updatewidgetstate;
begin
 inherited;
 fbuttons.updatewidgetstate;
end;

procedure tcustombuttonframe.checktemplate(const sender: tobject);
begin
 inherited;
 fbuttons.checktemplate(sender);
end;

procedure tcustombuttonframe.updatestate;
begin
 fbuttons.updatestate; //set skin options
 inherited; 
end;

{ tcustomedit }

constructor tcustomedit.create(aowner: tcomponent);
begin
 inherited;
 cursor:= cr_ibeam;
 optionsedit:= defaultoptionsedit;
 fwidgetrect.cx:= defaulteditwidgetwidth;
 fwidgetrect.cy:= defaulteditwidgetheight;
 if feditor = nil then begin
  feditor:= tinplaceedit.create(self,iedit(self));
 end;
 maxlength:= -1;
 foptionswidget:= defaulteditwidgetoptions;
 ftextflags:= defaulttextflags;
 ftextflagsactive:= defaulttextflagsactive;
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
end;

procedure tcustomedit.dodeactivate;
begin
 inherited;
 feditor.dodeactivate;
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
 if canevent(tmethod(fonkeydown)) then begin
  fonkeydown(self,info);
 end;
 if not (es_processed in info.eventstate) then begin
  feditor.dokeydown(info);
  if not (es_processed in info.eventstate) then begin
   inherited;
  end;
 end;
end;

procedure tcustomedit.dokeyup(var info: keyeventinfoty);
begin
 if canevent(tmethod(fonkeyup)) then begin
  fonkeyup(self,info);
 end;
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;

procedure tcustomedit.clientmouseevent(var info: mouseeventinfoty);
begin
 feditor.mouseevent(info);
 inherited;
end;

procedure tcustomedit.dopaint(const canvas: tcanvas);
begin
 inherited;
 feditor.dopaint(canvas);
end;

procedure tcustomedit.editnotification(var info: editnotificationinfoty);
begin
 case info.action of
  ea_textchanged: begin
   dochange;
  end;
  ea_textedited: begin
   dotextedited;
  end;
 end;
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

function tcustomedit.getoptionsdb: optionseditdbty;
begin
 result:= foptionsdb;
end;

procedure tcustomedit.setoptionsedit(const avalue: optionseditty);
begin
 if oe_autopost in avalue then begin
  include(foptionsdb,oed_autopost);
 end;
 if foptionsedit <> avalue then begin
  foptionsedit:= avalue - [oe_autopost];
  updatereadonlystate;
 end;
end;

function tcustomedit.geteditfont: tfont;
begin
 result:= font;
end;

procedure tcustomedit.setupeditor;
begin
 if not (csloading in componentstate) then begin
  with feditor do begin
   if fframe = nil then begin
    setup(text,curindex,true,inflaterect(clientrect,-1),
             clientrect,nil,nil,geteditfont);
   end
   else begin
    setup(text,curindex,true,innerclientrect,
                  makerect(nullpoint,clientsize),nil,nil,geteditfont);
   end;
  end;
 end;
end;

procedure tcustomedit.synctofontheight;
begin
 inherited;
 syncsinglelinefontheight;
end;

procedure tcustomedit.clientrectchanged;
begin
 inherited;
 setupeditor;
end;

procedure tcustomedit.fontchanged;
begin
 inherited;
 setupeditor;
end;

function tcustomedit.getmaxlength: integer;
begin
 result:= feditor.maxlength;
end;

function tcustomedit.getpasswordchar: msechar;
begin
 result:= feditor.passwordchar;
end;

procedure tcustomedit.setmaxlength(const Value: integer);
begin
 feditor.maxlength:= value;
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

procedure tcustomedit.settext(const Value: msestring);
begin
 feditor.text:= value;
end;

procedure tcustomedit.updatetextflags;
begin
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
end;

procedure tcustomedit.enabledchanged;
begin
 inherited;
 updatetextflags;
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
  ftextflagsactive:= checktextflags(ftextflagsactive,value) - ellipsemask;
  updatetextflags;
 end;
end;

procedure tcustomedit.dochange;
begin
 if not (ws_loadedproc in fwidgetstate) then begin
  if canevent(tmethod(fonchange)) then begin
   fonchange(self);
  end;
{$ifdef mse_with_ifi}
  if fifiserverintf <> nil then begin
   fifiserverintf.valuechanged(iifiwidget(self));
  end;
{$endif}
 end;
end;

procedure tcustomedit.dotextedited;
var
 mstr1: msestring;
begin
 if canevent(tmethod(fontextedited)) then begin
  mstr1:= text;
  fontextedited(self,mstr1);
  if mstr1 <> text then begin
   text:= mstr1;
  end;
  feditor.oldtext:= mstr1;
 end;
end;

procedure tcustomedit.initnewcomponent(const ascale: real);
begin
 internalcreateframe;
 fframe.scale(ascale);
 inherited;
end;

procedure tcustomedit.initfocus;
begin
 feditor.dofocus;
end;

procedure tcustomedit.rootchanged;
begin
 inherited;
 feditor.poschanged;
end;

procedure tcustomedit.changed;
begin
 dochange;
end;

function tcustomedit.geteditor: tinplaceedit;
begin
 result:= feditor;
end;
(*
procedure tcustomedit.onundo(const sender: tobject);
begin
 feditor.undo;
end;

procedure tcustomedit.oncopy(const sender: tobject);
begin
 feditor.copytoclipboard;
end;

procedure tcustomedit.oncut(const sender: tobject);
begin
 feditor.cuttoclipboard;
end;

procedure tcustomedit.onpaste(const sender: tobject);
begin
 feditor.pastefromclipboard;
end;

procedure tcustomedit.dopopup(var amenu: tpopupmenu;
                        var mouseinfo: mouseeventinfoty);
var
 states: array[0..3] of actionstatesty;
 sepchar: msechar;
 bo1: boolean;
begin
 if oe_autopopupmenu in foptionsedit then begin
  if feditor.canundo then begin
   states[0]:= []; //undo
  end
  else begin
   states[0]:= [as_disabled];
  end;
  bo1:= feditor.cancopy or hasselection;
  if bo1 or cangridcopy then begin
   states[1]:= []; //copy
   if bo1 and not (oe_readonly in foptionsedit) then begin
    states[2]:= [];
   end
   else begin
    states[2]:= [as_disabled]; //cut
   end;
  end
  else begin
   states[1]:= [as_disabled]; //copy
   states[2]:= [as_disabled]; //cut
  end;
  if feditor.canpaste then begin
   states[3]:= []; //paste
  end
  else begin
   states[3]:= [as_disabled];
  end;
  if popupmenu <> nil then begin
   sepchar:= popupmenu.shortcutseparator;
  end
  else begin
   sepchar:= tcustommenu.getshortcutseparator(amenu);
  end;
  tpopupmenu.additems(amenu,self,mouseinfo,
     [stockobjects.captions[sc_Undo]+sepchar+'(Esc)',
      stockobjects.captions[sc_Copy]+sepchar+'(Ctrl+C)',
      stockobjects.captions[sc_Cut]+sepchar+'(Ctrl+X)',
      stockobjects.captions[sc_Paste]+sepchar+'(Ctrl+V)'],
     [],states,[{$ifdef FPC}@{$endif}onundo,{$ifdef FPC}@{$endif}oncopy,
     {$ifdef FPC}@{$endif}oncut,{$ifdef FPC}@{$endif}onpaste]);
 end;
 inherited;
end;
*)
procedure tcustomedit.dopopup(var amenu: tpopupmenu;
                        var mouseinfo: mouseeventinfoty);
begin
 if oe_autopopupmenu in foptionsedit then begin
  feditor.dopopup(amenu,popupmenu,mouseinfo,hasselection,cangridcopy);
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
 //dummy
end;

function tcustomedit.hasselection: boolean;
begin
 result:= false;
end;

function tcustomedit.cangridcopy: boolean;
begin
 result:= false;
end;

procedure tcustomedit.showhint(var info: hintinfoty);
begin
 if (oe_hintclippedtext in foptionsedit) and 
                      editor.textclipped and getshowhint then begin
  info.caption:= text;
 end;
 inherited;
end;

{$ifdef mse_with_ifi}
procedure tcustomedit.setifiserverintf(const aintf: iifiserver);
begin
 fifiserverintf:= aintf;
end;

function tcustomedit.getifiserverintf: iifiserver;
begin
 result:= fifiserverintf;
end;
{$endif}

end.
