{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseedit;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 msegui,mseeditglob,msegraphics,msegraphutils,msedatalist,
 mseevent,mseguiglob,mseinplaceedit,msegrids,msetypes,mseshapes,msewidgets,
 msedrawtext,classes,msereal,mseclasses,msearrayprops,msebitmap,msemenus,
 msesimplewidgets,msepointer,msestrings,msescrollbar;

const
 defaulteditwidgetoptions = defaultoptionswidget+[ow_fontglyphheight,ow_autoscale];
 defaulteditwidgetwidth = 100;
 defaulteditwidgetheight = 20;
 defaulttextflags = [tf_ycentered,tf_noselect];
 defaulttextflagsactive = [tf_ycentered];

type

 teditframe = class(tcustomcaptionframe)
  public
   constructor create(const intf: iframe);
  published
   property levelo default -2;
   property leveli;
   property framewidth;
   property colorframe;
   property framei_left default 1;
   property framei_top default 1;
   property framei_right default 1;
   property framei_bottom default 1;
   property colorclient default cl_foreground;
   property caption;
   property captionpos;
   property captiondist;
   property captiondistouter;
   property captionoffset;
   property font;
   property localprops; //before template
   property template;
 end;
 
 tscrolleditframe = class(tcustomthumbtrackscrollframe)
  public
   constructor create(const intf: iframe; const scrollintf: iscrollbar);
  published
   property levelo default -2;
   property leveli;
   property framewidth;
   property colorframe;
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
   property captiondistouter;
   property captionoffset;
   property font;
   property localprops; //before template
   property template;
 end;

 tscrollboxeditframe = class(tcustomscrollboxframe)
  public
   constructor create(const intf: iframe; const owner: twidget);
  published
   property levelo default -2;
   property leveli;
   property framewidth;
   property colorframe;
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
   property captiondistouter;
   property captionoffset;
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
 framebuttonoptionty = (fbo_left,fbo_invisible,fbo_disabled);
 framebuttonoptionsty = set of framebuttonoptionty;

 tcustombuttonframe = class;

 tframebutton = class(townedeventpersistent)
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
   procedure createface;
   function getface: tface;
   procedure setface(const avalue: tface);
  protected
   finfo: shapeinfoty;
   procedure mouseevent(var info: mouseeventinfoty;
                 const intf: iframe; const buttonintf: ibutton;
                 const index: integer);
  public
   constructor create(aowner: tobject); override;
   destructor destroy; override;
   procedure updatewidgetstate(const awidget: twidget);
   procedure assign(source: tpersistent); override;
  published
   property width: integer read fbuttonwidth write setbuttonwidth default 0;
   property visible: boolean read getvisible write setvisible default true;
   property enabled: boolean read getenabled write setenabled default true;
   property left: boolean read getleft write setleft default false;
   property color: colorty read finfo.color write setcolor default cl_parent;
   property colorglyph: colorty read finfo.colorglyph write setcolorglyph default cl_glyph;
   property face: tface read getface write setface;
   property imagelist: timagelist read finfo.imagelist write setimagelist;
   property imagenr: integer read finfo.imagenr write setimagenr default -1;
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
  public
   constructor create(const aowner: tcustombuttonframe;
                    const buttonclass: framebuttonclassty);
   procedure updatewidgetstate;
   function wantmouseevent(const apos: pointty): boolean;
  public
   property items[const index: integer]: tframebutton read getitems1; default;
 end;

 tcustombuttonframe = class(teditframe)
  private
   fbuttons: tframebuttons;
   procedure setbuttons(const Value: tframebuttons);
  protected
   fbuttonintf: ibutton;
   procedure getpaintframe(var frame: framety); override;
   function getbuttonclass: framebuttonclassty; virtual;
  public
   constructor create(const intf: iframe; const buttonintf: ibutton); reintroduce;
   destructor destroy; override;
   function buttonframe: framety;
   procedure updatemousestate(const sender: twidget; const apos: pointty); override;
   procedure updatewidgetstate; override;
   procedure dopaintframe(const canvas: tcanvas; const rect: rectty); override;
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
                      
 
 tcustomedit = class(tpublishedwidget,iedit)
  private
   fonchange: notifyeventty;
   fontextedited: texteditedeventty;
   ftextflags: textflagsty;
   ftextflagsactive: textflagsty;
   fonkeydown: keyeventty;
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
   procedure onundo(const sender: tobject);
   procedure oncopy(const sender: tobject);
   procedure oncut(const sender: tobject);
   procedure onpaste(const sender: tobject);
   function getcaretwidth: integer;
   procedure setcaretwidth(const Value: integer);
  protected
   feditor: tinplaceedit;
   foptionsedit: optionseditty;
   function geteditor: tinplaceedit;
   function geteditfont: tfont; virtual;
   procedure setupeditor; virtual;
   procedure createframe; override;
   procedure clientrectchanged; override;
   procedure fontchanged; override;
   procedure enabledchanged; override;

   function getoptionsedit: optionseditty; virtual;//iedit
   procedure setoptionsedit(const avalue: optionseditty); virtual;
   procedure editnotification(var info: editnotificationinfoty); virtual;
     //interface to inplaceedit
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure clientmouseevent(var info: mouseeventinfoty); override;
   procedure dopopup(var amenu: tpopupmenu; var mouseinfo: mouseeventinfoty); override;
   procedure doactivate; override;
   procedure dodeactivate; override;
   procedure dofocus; override;
   procedure dodefocus; override;
   procedure dopaint(const canvas: tcanvas); override;
   procedure rootchanged; override;

   procedure dochange; virtual;
   procedure dotextedited; virtual;
   procedure readpwchar(reader: treader);
   procedure writepwchar(writer: twriter);
   procedure defineproperties(filer: tfiler); override;
   
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure initnewcomponent; override;
   procedure changed;
   procedure initfocus;
   procedure synctofontheight; override;

   property optionswidget default defaulteditwidgetoptions; //first!

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
  published
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
 end;

implementation
uses
 SysUtils,msekeyboard,msebits,msedataedits,msestockobjects;

type
 twidget1 = class(twidget);
 tdatacol1 = class(tdatacol);
 tcustombuttonframe1 = class(tcustombuttonframe);
 tinplaceedit1 = class(tinplaceedit);

{ teditframe }

constructor teditframe.create(const intf: iframe);
begin
 inherited;
 fi.colorclient:= cl_foreground;
 fi.levelo:= -2;
 inflateframe(fi.innerframe,1);
 internalupdatestate;
end;

{ tscrolleditframe }

constructor tscrolleditframe.create(const intf: iframe; const scrollintf: iscrollbar);
begin
 inherited;
 colorclient:= cl_foreground;
 fi.levelo:= -2;
 inflateframe(fi.innerframe,1);
 internalupdatestate;
end;

{ tscrollboxeditframe }

constructor tscrollboxeditframe.create(const intf: iframe; const owner: twidget);
begin
 inherited;
 colorclient:= cl_foreground;
 fi.levelo:= -2;
 inflateframe(fi.innerframe,1);
 internalupdatestate;
end;

{ tframebutton }

procedure tframebutton.changed;
begin
 if not (csloading in tcustombuttonframe(fowner).fintf.getwidget.componentstate) then begin
  tcustombuttonframe(fowner).updatestate;
 end;
end;

procedure tframebutton.setoptions(const Value: framebuttonoptionsty);
begin
 if foptions <> value then begin
  foptions:= Value;
  updatebit(cardinal(finfo.state),ord(ss_invisible),fbo_invisible in value);
  updatebit(cardinal(finfo.state),ord(ss_disabled),fbo_disabled in value);
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
  if updatemouseshapestate(finfo,info,nil) then begin
   intf.invalidaterect(dim,org_widget);
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

constructor tframebutton.create(aowner: tobject);
begin
 finfo.color:= cl_parent;
 finfo.colorglyph:= cl_glyph;
 finfo.imagenr:= -1;
 include(finfo.state,ss_widgetorg);
 inherited;
end;

destructor tframebutton.destroy;
begin
 inherited;
 finfo.face.free;
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
 finfo.face:= tface.create(iface(tcustombuttonframe(fowner).fintf.getwidget));
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

procedure tframebutton.updatewidgetstate(const awidget: twidget);
begin
 updatewidgetshapestate(finfo,awidget,fbo_disabled in foptions);
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
  end;
 end;
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
   if not (fbo_invisible in foptions) and pointinrect(apos,finfo.dim) then begin
    result:= true;
    break;
   end;
  end;
 end;
end;

{ tcustombuttonframe }

constructor tcustombuttonframe.create(const intf: iframe; const buttonintf: ibutton);
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
     inc(result.left,dim.cx);
    end
    else begin
     inc(result.right,dim.cx);
    end;
   end;
  end;
 end;
end;

procedure tcustombuttonframe.getpaintframe(var frame: framety);
var
 int1: integer;
begin
 inherited;
 for int1:= 0 to fbuttons.count-1 do begin
  with fbuttons[int1],finfo do begin
   if not (ss_invisible in state) then begin
    dim.cy:= fintf.getwidgetrect.cy - frameframewidth.cy;
    if fbuttonwidth = 0 then begin
     dim.cx:= dim.cy;
    end
    else begin
     dim.cx:= fbuttonwidth;
    end;
    dim.y:= fouterframe.top + fwidth.top;
    if fbo_left in foptions then begin
     dim.x:= fouterframe.left + fwidth.left + frame.left;
     inc(frame.left,dim.cx);
    end
    else begin
     dim.x:= fintf.getwidgetrect.cx -
       (fouterframe.right + fwidth.right + dim.cx + frame.right);
     inc(frame.right,dim.cx);
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

procedure tcustombuttonframe.dopaintframe(const canvas: tcanvas; const rect: rectty);
var
 int1: integer;
 color1,color2: colorty;
begin
 color2:= cl_none;
 for int1:= 0 to fbuttons.count-1 do begin
  with fbuttons[int1] do begin
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
 feditor.dodefocus;
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

function tcustomedit.getoptionsedit: optionseditty;
begin
 result:= foptionsedit;
end;

procedure tcustomedit.setoptionsedit(const avalue: optionseditty);
begin
 foptionsedit:= avalue;
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

procedure tcustomedit.createframe;
begin
 teditframe.create(self);
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
  if enabled or (oe_nogray in foptionsedit) then begin
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
 if canevent(tmethod(fonchange)) then begin
  fonchange(self);
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

procedure tcustomedit.initnewcomponent;
begin
 createframe;
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

begin
 if oe_autopopupmenu in foptionsedit then begin
  if feditor.canundo then begin
   states[0]:= [];
  end
  else begin
   states[0]:= [as_disabled];
  end;
  if feditor.cancopy then begin
   states[1]:= [];
   if oe_readonly in foptionsedit then begin
    states[2]:= [as_disabled];
   end
   else begin
    states[2]:= [];
   end;
  end
  else begin
   states[1]:= [as_disabled];
   states[2]:= [as_disabled];
  end;
  if feditor.canpaste then begin
   states[3]:= [];
  end
  else begin
   states[3]:= [as_disabled];
  end;
  tpopupmenu.additems(amenu,self,mouseinfo,
     [stockobjects.captions[sc_Undo]+' (Esc)',
      stockobjects.captions[sc_Copy]+' (Ctrl+C)',
      stockobjects.captions[sc_Cut]+' (Ctrl+X)',
      stockobjects.captions[sc_Paste]+' (Ctrl+V)'],
     [],states,[{$ifdef FPC}@{$endif}onundo,{$ifdef FPC}@{$endif}oncopy,
     {$ifdef FPC}@{$endif}oncut,{$ifdef FPC}@{$endif}onpaste]);
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

end.
