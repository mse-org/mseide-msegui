{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseforms;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 msewidgets,msemenus,msegraphics,msegui,msegraphutils,mseevent,msetypes,msestrings,
 mseguiglob,msemenuwidgets,msestat,msestatfile,mseclasses,Classes,msedock,
 msebitmap;

type
 formoptionty = (fo_main,fo_terminateonclose,fo_freeonclose,fo_defaultpos,fo_screencentered,
               fo_closeonesc,fo_cancelonesc,fo_closeonenter,fo_closeonf10,
               fo_globalshortcuts,fo_localshortcuts,
               fo_autoreadstat,fo_autowritestat,fo_savepos,fo_savestate);
 formoptionsty = set of formoptionty;

const
 defaultformoptions = [fo_autoreadstat,fo_autowritestat,fo_savepos,fo_savestate];
 defaultformwidgetoptions = (defaultoptionswidget - [ow_mousefocus,ow_tabfocus]) +
   [ow_subfocus,ow_hinton];

type

 tcustommseform = class;
 closequeryeventty = procedure(const sender: tcustommseform; var amodalresult: modalresultty) of object;
 
 tformscrollbox = class(tscrollingwidget)
          //for internal use only
  protected
   procedure setoptionswidget(const avalue: optionswidgetty); override;
  public
   constructor create(aowner: tcustommseform); reintroduce;
  published
   property onscroll;
   property onfontheightdelta;
   property onchildscaled;
   property oncalcminscrollsize;
 end;

 tcustommseform = class(tcustomeventwidget,istatfile,idockcontroller)
  private
   foncreate: notifyeventty;
//   fonaftercreate: notifyeventty;
   fondestroyed: notifyeventty;
   fonloaded: notifyeventty;
   fondestroy: notifyeventty;
   fonclosequery: closequeryeventty;
   fonclose: notifyeventty;
   fonidle: idleeventty;
   fonterminatequery: terminatequeryeventty;
   fonterminated: notifyeventty;
   fmainmenu: tmainmenu;
   foptions: formoptionsty;
   fstatfile: tstatfile;
   fcaption: msestring;
   fmainmenuwidget: tmainmenuwidget;
   foptionswindow: windowoptionsty;
   fonstatread: statreadeventty;
   fonstatafterread: notifyeventty;
   fonstatbeforeread: notifyeventty;
   fonstatupdate: statupdateeventty;
   fstatvarname: msestring;
   fonstatwrite: statwriteeventty;
   fonwindowactivechanged: activechangeeventty;
   fonwindowdestroyed: windoweventty;
   fonapplicationactivechanged: booleaneventty;
   fonfontheightdelta: fontheightdeltaeventty;
   ficon: tmaskedbitmap;
   function getonchildscaled: notifyeventty;
   procedure setonchildscaled(const avalue: notifyeventty);
   procedure setmainmenu(const Value: tmainmenu);
   procedure updatemainmenutemplates;
   procedure setoptions(const Value: formoptionsty);
   procedure setoptionswindow(const Value: windowoptionsty);
   procedure setstatfile(const avalue: tstatfile);
   procedure setscrollbox(const avalue: tformscrollbox);
   function getonafterpaint: painteventty;
   function getonbeforepaint: painteventty;
   function getonpaint: painteventty;
   procedure setonafterpaint(const Value: painteventty);
   procedure setonbeforepaint(const Value: painteventty);
   procedure setonpaint(const Value: painteventty);
   procedure seticon(const avalue: tmaskedbitmap);
   procedure iconchanged(const sender: tobject);
  protected
   fscrollbox: tformscrollbox;
    //needed to distinguish between scrolled and unscrolled (mainmenu...) widgets
   procedure updateoptions; virtual;
   function getoptions: formoptionsty; virtual;
   procedure updatescrollboxrect;
   procedure clientrectchanged; override;
   procedure updatewindowinfo(var info: windowinfoty); override;
   procedure setparentwidget(const Value: twidget); override;
   function isgroupleader: boolean; override;

   procedure ReadState(Reader: TReader); override;
   procedure loaded; override;
   procedure setoptionswidget(const avalue: optionswidgetty); override;

   function getcaption: msestring;
   procedure setcaption(const Value: msestring); virtual;
   procedure getchildren(proc: tgetchildproc; root: tcomponent); override;
   procedure doterminated(const sender: tobject);
   procedure doterminatequery(var terminate: boolean);
   procedure doidle(var again: boolean);
   procedure dowindowactivechanged(const oldwindow,newwindow: twindow);
   procedure dowindowdestroyed(const awindow: twindow);
   procedure doapplicationactivechanged(const avalue: boolean);
   procedure objectevent(const sender: tobject; const event: objecteventty); override;
   procedure receiveevent(const event: tobjectevent); override;
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure doshortcut(var info: keyeventinfoty; const sender: twidget); override;
   function getframe: tgripframe;
   procedure setframe(const Value: tgripframe);
   //istatfile
   procedure dostatread(const reader: tstatreader);
   procedure dostatread1(const reader: tstatreader); virtual;
   procedure dostatwrite(const writer: tstatwriter);
   procedure dostatwrite1(const writer: tstatwriter); virtual;
   procedure statreading; virtual;
   procedure statread; virtual;
   function getstatvarname: msestring;

   procedure windowcreated; override;
   procedure dofontheightdelta(var delta: integer); override;
   procedure widgetregionchanged(const sender: twidget); override;

   function getcontainer: twidget; override;
   function getchildwidgets(const index: integer): twidget; override;
   //idockcontroller
   function checkdock(var info: draginfoty): boolean;
   function getbuttonrects(const index: dockbuttonrectty): rectty;  
   function getplacementrect: rectty;
  public
   constructor create(aowner: tcomponent); overload; override;
   constructor create(aowner: tcomponent; load: boolean); reintroduce; overload;  virtual;
   destructor destroy; override;
   procedure insertwidget(const widget: twidget; const apos: pointty); override;
   procedure dochildscaled(const sender: twidget); override;
   function childrencount: integer; override;

   function canclose(const newfocus: twidget): boolean; override;
   procedure beforedestruction; override;
   property optionswidget default defaultformwidgetoptions;
   property optionswindow: windowoptionsty read foptionswindow write setoptionswindow default [];
   property mainmenu: tmainmenu read fmainmenu write setmainmenu;
   property color default cl_background;
   property font: twidgetfont read getfont write setfont stored isfontstored;
   property options: formoptionsty read getoptions write setoptions
                         default defaultformoptions;

   property statfile: tstatfile read fstatfile write setstatfile;
   property statvarname: msestring read getstatvarname write fstatvarname;

   property caption: msestring read getcaption write setcaption;
   property icon: tmaskedbitmap read ficon write seticon;

   property oncreate: notifyeventty read foncreate write foncreate;
//   property onaftercreate: notifyeventty read fonaftercreate write fonaftercreate;
   property onloaded: notifyeventty read fonloaded write fonloaded;
   property ondestroy: notifyeventty read fondestroy write fondestroy;
   property ondestroyed: notifyeventty read fondestroyed write fondestroyed;
   property onclosequery: closequeryeventty read fonclosequery write fonclosequery;
   property onclose: notifyeventty read fonclose write fonclose;
   property onidle: idleeventty read fonidle write fonidle;
   property onterminatequery: terminatequeryeventty read fonterminatequery 
                 write fonterminatequery;
   property onterminated: notifyeventty read fonterminated 
                 write fonterminated;

   property onbeforepaint: painteventty read getonbeforepaint write setonbeforepaint;
   property onpaint: painteventty read getonpaint write setonpaint;
   property onafterpaint: painteventty read getonafterpaint write setonafterpaint;

   property onstatupdate: statupdateeventty read fonstatupdate write fonstatupdate;
   property onstatread: statreadeventty read fonstatread write fonstatread;
   property onstatbeforeread: notifyeventty read fonstatbeforeread write fonstatbeforeread;
   property onstatafterread: notifyeventty read fonstatafterread write fonstatafterread;
   property onstatwrite: statwriteeventty read fonstatwrite write fonstatwrite;

   property onwindowactivechanged: activechangeeventty read fonwindowactivechanged write fonwindowactivechanged;
   property onwindowdestroyed: windoweventty read fonwindowdestroyed write fonwindowdestroyed;
   property onapplicationactivechanged: booleaneventty 
                   read fonapplicationactivechanged write fonapplicationactivechanged;

   property onfontheightdelta: fontheightdeltaeventty read fonfontheightdelta
                     write fonfontheightdelta;
   property onchildscaled: notifyeventty read getonchildscaled write setonchildscaled;
  published
   property container: tformscrollbox read fscrollbox write setscrollbox;
 end;

 mseformclassty = class of tcustommseform;

 tmseformwidget = class(tcustommseform)
  published
   property optionswidget;
   property optionswindow;
   property mainmenu;
   property color;
   property font;
   property options;
   property statfile;
   property statvarname;
   property caption;
   property icon;

   property oncreate;
//   property onaftercreate;
   property onloaded;
   property ondestroy;
   property ondestroyed;
   property onclosequery;
   property onclose;
   property onidle;
   property onwindowactivechanged;
   property onwindowdestroyed;
   property onapplicationactivechanged;
   property onterminatequery;
   property onterminated;

   property onmouseevent;
   property onclientmouseevent;
   property onchildmouseevent;
   property onkeydown;
   property onkeyup;
   property onshortcut;

   property onbeforepaint;
   property onpaint;
   property onafterpaint;
//   property onscroll;

   property onmove;
   property onresize;
   property onshow;
   property onactivate;
   property onenter;
   property onexit;
   property ondeactivate;
   property onhide;
   property onevent;
   property onasyncevent;

   property onstatupdate;
   property onstatread;
   property onstatbeforeread;
   property onstatafterread;
   property onstatwrite;

   property onfontheightdelta;
   property onchildscaled;
 end;

 tmseform = class(tmseformwidget)
  protected
   class function getmoduleclassname: string; override;
  public
   constructor create(aowner: tcomponent; load: boolean); override;
 end;

 tformdockcontroller = class(tdockcontroller)
  protected
   procedure setoptionsdock(const avalue: optionsdockty); override;
 end;

 tcustomdockform = class(tcustommseform,idocktarget)
  private
   fdragdock: tformdockcontroller;
   function getdockcontroller: tdockcontroller;
   procedure setdragdock(const Value: tformdockcontroller);
   function getframe: tgripframe;
   procedure setframe(const avalue: tgripframe);
  protected
   procedure internalcreateframe; override;
   procedure updateoptions; override;
   function getoptions: formoptionsty; override;
   procedure statreading; override;
   procedure statread; override;
   procedure dostatread1(const reader: tstatreader); override;
   procedure dostatwrite1(const writer: tstatwriter); override;
   procedure mouseevent(var info: mouseeventinfoty); override;
   procedure doactivate; override;
  public
   constructor create(aowner: tcomponent; load: boolean); override;
   destructor destroy; override;
   procedure dragevent(var info: draginfoty); override;
  published
   property dragdock: tformdockcontroller read fdragdock write setdragdock;
   property frame: tgripframe read getframe write setframe;
 end;

 tdockformwidget = class(tcustomdockform)
  published
   property optionswidget;
   property optionswindow;
   property mainmenu;
   property color;
   property font;
   property options;
   property statfile;
   property statvarname;
   property caption;
   property icon;

   property oncreate;
//   property onaftercreate;
   property onloaded;
   property ondestroy;
   property ondestroyed;
   property onclosequery;
   property onclose;
   property onidle;
   property onwindowactivechanged;
   property onwindowdestroyed;
   property onapplicationactivechanged;
   property onterminatequery;
   property onterminated;

   property onmouseevent;
   property onclientmouseevent;
   property onchildmouseevent;
   property onkeydown;
   property onkeyup;
   property onshortcut;

   property onbeforepaint;
   property onpaint;
   property onafterpaint;

   property onmove;
   property onresize;
   property onshow;
   property onactivate;
   property onenter;
   property onexit;
   property ondeactivate;
   property onhide;
   property onevent;
   property onasyncevent;

   property onstatupdate;
   property onstatread;
   property onstatbeforeread;
   property onstatafterread;
   property onstatwrite;

   property onfontheightdelta;
   property onchildscaled;
 end;

 tdockform = class(tdockformwidget)
  protected
   class function getmoduleclassname: string; override;
  public
   constructor create(aowner: tcomponent; load: boolean); override;
 end;

 tdockformscrollbox = class(tformscrollbox,idocktarget)
  protected
   procedure clientrectchanged; override;
   procedure widgetregionchanged(const sender: twidget); override;
   procedure dopaint(const acanvas: tcanvas); override;
   function getdockcontroller: tdockcontroller;
  public
   constructor create(aowner: tcustomdockform); reintroduce;
 end;

 tsubform = class(tpublishedwidget)
  protected
   class function getmoduleclassname: string; override;
   procedure getchildren(proc: tgetchildproc; root: tcomponent); override;
  public
   constructor create(aowner: tcomponent); overload; override;
   constructor create(aowner: tcomponent; load: boolean); reintroduce; overload;  virtual;
 end;
 
 subformclassty = class of tsubform;
 
function createmseform(const aclass: tclass; 
                   const aclassname: pshortstring): tmsecomponent;
function createsubform(const aclass: tclass; 
                   const aclassname: pshortstring): tmsecomponent;

implementation
uses
 sysutils,mselist,mseguiintf,typinfo,msekeyboard,msebits;
const
 containercommonflags: optionswidgetty = 
            [ow_arrowfocus,ow_arrowfocusin,ow_arrowfocusout,ow_destroywidgets,
             ow_parenttabfocus{,
             ow_subfocus,ow_mousefocus,ow_tabfocus}];
 
type
 tcomponent1 = class(tcomponent);
 tmsecomponent1 = class(tmsecomponent);
 twidget1 = class(twidget);
 twindow1 = class(twindow);
 tcustomframe1 = class(tcustomframe);

 {$ifdef FPC}
  TReadercracker = class(TFiler)
  private
    FDriver: TAbstractObjectReader;
    FOwner: TComponent;
    FParent: TComponent;
    FFixups: TList;
    FLoaded: TList;
  end;
  TComponentcracker = class(TPersistent)
  private
    FOwner: TComponent;
    FName: TComponentName;
    FTag: Longint;
    FComponents: TList;
    FFreeNotifies: TList;
    FDesignInfo: Longint;
    FVCLComObject: Pointer;
    FComponentState: TComponentState;
  end;
 {$else}
  TReadercracker = class(TFiler)
  private
    FOwner: TComponent;
    FParent: TComponent;
    FFixups: TList;
    FLoaded: TList;
  end;
  TComponentcracker = class(TPersistent{, IInterface, IInterfaceComponentReference})
  private
    FOwner: TComponent;
    FName: TComponentName;
    FTag: Longint;
    FComponents: TList;
    FFreeNotifies: TList;
    FDesignInfo: Longint;
    FComponentState: TComponentState;
  end;
  {$endif}

function createmseform(const aclass: tclass; 
                    const aclassname: pshortstring): tmsecomponent;

begin
 result:= mseformclassty(aclass).create(nil,false);
 tmsecomponent1(result).factualclassname:= aclassname;
end;

function createsubform(const aclass: tclass; 
                    const aclassname: pshortstring): tmsecomponent;
begin
 result:= subformclassty(aclass).create(nil,false);
 tmsecomponent1(result).factualclassname:= aclassname;
end;

{ tformscrollbox}

constructor tformscrollbox.create(aowner: tcustommseform);
begin
// inherited create(nil);
 inherited create(aowner);
 setsubcomponent(true);
 exclude(fwidgetstate,ws_iswidget);
 include(foptionswidget,ow_subfocus);
 include(foptionswidget,ow_mousetransparent);
 parentwidget:= aowner;
 name:= 'container';
end;

procedure tformscrollbox.setoptionswidget(const avalue: optionswidgetty);
begin
 if fparentwidget <> nil then begin
  replacebits1(longword(twidget1(fparentwidget).foptionswidget),longword(avalue),
                   longword(containercommonflags));
 end;
 inherited;
end;


{ tdockformscrollbox }

constructor tdockformscrollbox.create(aowner: tcustomdockform);
begin
 inherited create(aowner);
end;

procedure tdockformscrollbox.clientrectchanged;
begin
 if not (ws_loadlock in fwidgetstate) and (owner <> nil) then begin
  tcustomdockform(owner).fdragdock.beginclientrectchanged;
 end;
 inherited;
 if not (ws_loadlock in fwidgetstate)  and (owner <> nil) then begin
  tcustomdockform(owner).fdragdock.endclientrectchanged;
 end;
end;

procedure tdockformscrollbox.widgetregionchanged(const sender: twidget);
begin
 inherited;
 if not (ws_loadlock in fwidgetstate) then begin
  tcustomdockform(owner).fdragdock.widgetregionchanged(sender);
 end;
end;

procedure tdockformscrollbox.dopaint(const acanvas: tcanvas);
begin
 inherited;
 tcustomdockform(owner).fdragdock.dopaint(acanvas);
end;

function tdockformscrollbox.getdockcontroller: tdockcontroller;
begin
 result:= tcustomdockform(owner).fdragdock;
end;

{ tcustommseform }

constructor tcustommseform.create(aowner: tcomponent; load: boolean);
begin
 ficon:= tmaskedbitmap.create(false);
 ficon.onchange:= {$ifdef FPC}@{$endif}iconchanged;
 fwidgetrect.x:= 100;
 fwidgetrect.y:= 100;
 options:= defaultformoptions;
 inherited create(aowner);
 fwidgetrect.cx:= 100;
 fwidgetrect.cy:= 100;
 if fscrollbox = nil then begin
  fscrollbox:= tformscrollbox.create(self);
 end;
 optionswidget:= defaultformwidgetoptions;
 color:= cl_background;
 if load and not (csdesigning in componentstate) and
          (cs_ismodule in fmsecomponentstyle) then begin
  loadmsemodule(self,tcustommseform);
  if (fstatfile <> nil) and (fo_autoreadstat in foptions) then begin
   fstatfile.readstat;
  end;
 end;
 application.registeronterminated({$ifdef FPC}@{$endif}doterminated);
 application.registeronterminate({$ifdef FPC}@{$endif}doterminatequery);
 application.registeronidle({$ifdef FPC}@{$endif}doidle);
 application.registeronactivechanged({$ifdef FPC}@{$endif}dowindowactivechanged);
 application.registeronwindowdestroyed({$ifdef FPC}@{$endif}dowindowdestroyed);
 application.registeronapplicationactivechanged(
       {$ifdef FPC}@{$endif}doapplicationactivechanged);
end;

constructor tcustommseform.create(aowner: tcomponent);
begin
 create(aowner,true);
end;

destructor tcustommseform.destroy;
var
 bo1: boolean;
begin
 bo1:= csdesigning in componentstate;
 include(fwidgetstate,ws_destroying);
 application.unregisteronterminated({$ifdef FPC}@{$endif}doterminated);
 application.unregisteronterminate({$ifdef FPC}@{$endif}doterminatequery);
 application.unregisteronidle({$ifdef FPC}@{$endif}doidle);
 application.unregisteronactivechanged({$ifdef FPC}@{$endif}dowindowactivechanged);
 application.unregisteronwindowdestroyed({$ifdef FPC}@{$endif}dowindowdestroyed);
 application.unregisteronapplicationactivechanged(
       {$ifdef FPC}@{$endif}doapplicationactivechanged);
 mainmenu:= nil;
 ficon.free;
 fscrollbox.free;
 fmainmenuwidget.free;
 inherited; //csdesigningflag is removed
 if not bo1 and candestroyevent(tmethod(fondestroyed)) then begin
  fondestroyed(self);
 end;
end;

procedure tcustommseform.beforedestruction;
begin
 inherited;
 if candestroyevent(tmethod(fondestroy)) then begin
  fondestroy(self);
 end;
end;

function tcustommseform.canclose(const newfocus: twidget): boolean;
var
 modres: modalresultty;
begin
 result:= inherited canclose(newfocus);
 if result and (newfocus = nil) then begin
  if canevent(tmethod(fonclosequery)) then begin
   if twindow1(window).fmodalresult = mr_none then begin
    modres:= mr_canclose;
   end
   else begin
    modres:= twindow1(window).fmodalresult;
   end;
   fonclosequery(self,modres);
   result:= modres <> mr_none;
   if twindow1(window).fmodalresult <> mr_canclose then begin
    twindow1(window).fmodalresult:= modres;
   end;
  end;
  if result and (twindow1(window).fmodalresult <> mr_none) then begin
   if canevent(tmethod(fonclose)) then begin
    fonclose(self);
   end;
   if (fstatfile <> nil) and (fo_autowritestat in foptions) and
                 not (csdesigning in componentstate) then begin
    fstatfile.writestat;
   end;
   if (fo_terminateonclose in foptions) and not application.terminating and
                  not (csdesigning in componentstate) then begin
    application.terminate(window);
    result:= application.terminated;
   end;
   if result and (fo_freeonclose in foptions) and 
             not (csdesigning in componentstate) then begin
    release;
   end;
  end;
 end;
end;

procedure tcustommseform.doterminated(const sender: tobject);
begin
 if canevent(tmethod(fonterminated)) then begin
  fonterminated(sender);
 end;
end;

procedure tcustommseform.doterminatequery(var terminate: boolean);
begin
 if canevent(tmethod(fonterminatequery)) then begin
  fonterminatequery(terminate);
 end;
end;

procedure tcustommseform.doidle(var again: boolean);
begin
 if canevent(tmethod(fonidle)) then begin
  fonidle(again);
 end;
end;

procedure tcustommseform.dowindowactivechanged(const oldwindow,newwindow: twindow);
begin
 if canevent(tmethod(fonwindowactivechanged)) then begin
  fonwindowactivechanged(oldwindow,newwindow);
 end;
end;

procedure tcustommseform.dowindowdestroyed(const awindow: twindow);
begin
 if canevent(tmethod(fonwindowdestroyed)) then begin
  fonwindowdestroyed(awindow);
 end;
end;

procedure tcustommseform.doapplicationactivechanged(const avalue: boolean);
begin
 if canevent(tmethod(fonapplicationactivechanged)) then begin
  fonapplicationactivechanged(avalue);
 end;
end;

procedure tcustommseform.getchildren(proc: tgetchildproc; root: tcomponent);
var
 int1: integer;
 comp1: tcomponent;
begin
 inherited;
 fscrollbox.getchildren(proc,root);
 if root = self then begin
  for int1:= 0 to componentcount - 1 do begin
   comp1:= components[int1];
   if not comp1.hasparent then begin
    proc(comp1);
   end;
  end;
 end;
end;

procedure tcustommseform.loaded;
begin
 exclude(fscrollbox.fwidgetstate,ws_loadlock);
 if fmainmenuwidget <> nil then begin
  fmainmenuwidget.loaded;
 end;
 if (fo_screencentered in foptions) and not (csdesigning in componentstate) then begin
  window.windowpos:= wp_screencentered;
 end;
// if assigned(foncreate) and not(csdesigning in componentstate) then begin
//  foncreate(self);
// end;
 inherited;
 updateoptions;
 updatemainmenutemplates;
 if canevent(tmethod(foncreate)) then begin
  foncreate(self);
 end;
 application.postevent(tobjectevent.create(ek_loaded,ievent(self)));
end;

procedure tcustommseform.setoptionswidget(const avalue: optionswidgetty);
begin
 inherited;
 replacebits1(longword(fscrollbox.foptionswidget),longword(avalue),
                   longword(containercommonflags));
end;

procedure tcustommseform.receiveevent(const event: tobjectevent);
begin
 inherited;
 if event.kind = ek_loaded then begin
  if canevent(tmethod(fonloaded)) then begin
   fonloaded(self);
  end;
 end;
end;

function tcustommseform.getonchildscaled: notifyeventty;
begin
 result:= fscrollbox.onchildscaled;
end;

procedure tcustommseform.setonchildscaled(const avalue: notifyeventty);
begin
 fscrollbox.onchildscaled:= avalue;
end;

procedure tcustommseform.updatemainmenutemplates;
begin
 if not (csloading in componentstate) then begin
  if (fmainmenuwidget <> nil) and
                     (fmainmenu <> nil) then begin
   fmainmenuwidget.assigntemplate(fmainmenu.template);
  end;
  updatescrollboxrect;
 end;
end;

procedure tcustommseform.setmainmenu(const Value: tmainmenu);
begin
 if value <> fmainmenu then begin
  freeandnil(fmainmenuwidget);
  setlinkedvar(value,tmsecomponent(fmainmenu));
  if value <> nil then begin
   fmainmenuwidget:= tmainmenuwidget.create(self,fmainmenu);
   twidget1(fmainmenuwidget).setdesigning(csdesigning in componentstate);
   updatemainmenutemplates;
  end;
 end;
end;

procedure tcustommseform.objectevent(const sender: tobject; 
                                         const event: objecteventty);
begin
 if sender = fmainmenu then begin
  case event of
   oe_destroyed: begin
    setmainmenu(nil);
   end;
   oe_changed: begin
//    if fmainmenuwidget <> nil then begin
//     fmainmenuwidget.updatetemplates;
//    end;
    updatemainmenutemplates;
    if (sender = fmainmenu) and (fmainmenuwidget <> nil) then begin
     fmainmenuwidget.menuchanged(nil);
    end;
   end;
  end;
 end;
 inherited;
end;

procedure tcustommseform.setoptions(const Value: formoptionsty);
const
 mask1: formoptionsty = [fo_screencentered,fo_defaultpos];
 mask2: formoptionsty = [fo_closeonesc,fo_cancelonesc];
var
 opt1: formoptionsty;
begin
 if foptions <> value then begin
  opt1:= formoptionsty(setsinglebit(
       {$ifdef FPC}longword{$else}word{$endif}(value),
       {$ifdef FPC}longword{$else}word{$endif}(foptions),
       {$ifdef FPC}longword{$else}word{$endif}(mask2)));
  foptions:= formoptionsty(setsinglebit(
       {$ifdef FPC}longword{$else}word{$endif}(value),
       {$ifdef FPC}longword{$else}word{$endif}(foptions),
       {$ifdef FPC}longword{$else}word{$endif}(mask1)));
  foptions:= formoptionsty(replacebits(
       {$ifdef FPC}longword{$else}word{$endif}(opt1),
       {$ifdef FPC}longword{$else}word{$endif}(foptions),
       {$ifdef FPC}longword{$else}word{$endif}(mask2)));
  updateoptions;
 end;
end;

procedure tcustommseform.updateoptions;
begin
 if componentstate * [csloading,csdestroying,csdesigning] = [] then begin
  window.globalshortcuts:= fo_globalshortcuts in foptions;
  fwindow.localshortcuts:= fo_localshortcuts in foptions;
  if (fo_main in foptions) and not (csdesigning in componentstate) then begin
   application.mainwindow:= fwindow;
  end;
  if fo_screencentered in foptions then begin
   fwindow.windowpos:= wp_screencentered;
  end
  else begin
   if fo_defaultpos in foptions then begin
    fwindow.windowpos:= wp_default;
   end;
  end;
 end;
end;

function tcustommseform.getoptions: formoptionsty;
begin
 result:= foptions;
end;

procedure tcustommseform.setoptionswindow(const Value: windowoptionsty);
begin
 foptionswindow:= value;
end;

procedure tcustommseform.setstatfile(const avalue: tstatfile);
begin
 setstatfilevar(istatfile(self),avalue,fstatfile);
end;

function tcustommseform.getstatvarname: msestring;
begin
 result:= fstatvarname;
end;

procedure tcustommseform.dostatread1(const reader: tstatreader);
var
 rect1: rectty;
 str1: string;
 widget1: twidget;
begin
 if fo_savepos in foptions then begin
  rect1:= widgetrect;
  with rect1 do begin
   x:= reader.readinteger('x',x);
   y:= reader.readinteger('y',y);
   cx:= reader.readinteger('cx',cx,0);
   cy:= reader.readinteger('cy',cy,0);
  end;
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
  widgetrect:= rect1;
 end;
end;

procedure tcustommseform.dostatread(const reader: tstatreader);
var
 bo1: boolean;
 pos1: windowposty;
begin
 if canevent(tmethod(fonstatupdate)) then begin
  fonstatupdate(self,reader);
 end;
 if canevent(tmethod(fonstatread)) then begin
  fonstatread(self,reader);
 end;
 dostatread1(reader);
 if fparentwidget = nil then begin
  with reader do begin
   if fo_savestate in foptions then begin
    pos1:= windowposty(readinteger('wsize',ord(window.windowpos),0,
                              ord(high(windowposty))));
    bo1:= readboolean('visible',visible);
    bo1:= visible or bo1;
    if bo1 then begin
     window.windowpos:= pos1;
     if pos1 <> wp_minimized then begin
      show;
     end;
    end;
    if readboolean('active',active) then begin
     activate;
    end;
   end;
  end;
 end;
end;

procedure tcustommseform.statreading;
begin
 if canevent(tmethod(fonstatbeforeread)) then begin
  fonstatbeforeread(self);
 end;
end;

procedure tcustommseform.statread;
begin
 if canevent(tmethod(fonstatafterread)) then begin
  fonstatafterread(self);
 end;
end;

procedure tcustommseform.dostatwrite1(const writer: tstatwriter);
var
 window1: twindow;
begin
 if (fparentwidget = nil) and (fo_savepos in foptions) then begin
  window1:= window.stackedunder;
  if window1 <> nil then begin
   writer.writestring('stackedunder',ownernamepath(window1.owner));
  end
  else begin
   writer.writestring('stackedunder','');
  end;
  with window.normalwindowrect do begin
   writer.writeinteger('x',x);
   writer.writeinteger('y',y);
   writer.writeinteger('cx',cx);
   writer.writeinteger('cy',cy);
  end;
 end;
end;

procedure tcustommseform.dostatwrite(const writer: tstatwriter);
begin
 if assigned(fonstatupdate) then begin
  fonstatupdate(self,writer);
 end;
 if assigned(fonstatwrite) then begin
  fonstatwrite(self,writer);
 end;
 dostatwrite1(writer);
 if fparentwidget = nil then begin
  with writer do begin
   if fo_savestate in foptions then begin
    writeinteger('wsize',ord(window.windowpos));
    writeboolean('active',active);
    writeboolean('visible',visible);
   end;
  end;
 end;
end;

procedure tcustommseform.updatescrollboxrect;
var
 rect1: rectty;
begin
 if not (ws_destroying in fwidgetstate) then begin
  rect1:= innerwidgetrect;
  if fmainmenuwidget <> nil then begin
   twidget1(fmainmenuwidget).setwidgetrect(
         makerect(paintpos,makesize(paintsize.cx,fmainmenuwidget.bounds_cy)));
   inc(rect1.y,fmainmenuwidget.bounds_cy);
   dec(rect1.cy,fmainmenuwidget.bounds_cy);
  end;
  fscrollbox.setwidgetrect(rect1);
 end;
end;

procedure tcustommseform.clientrectchanged;
begin
 inherited;
 updatescrollboxrect;
end;

procedure tcustommseform.updatewindowinfo(var info: windowinfoty);
begin
 inherited;
 info.options:= foptionswindow;
 if fo_defaultpos in foptions then begin
  info.initialwindowpos:= wp_default;
 end;
 getwindowicon(ficon,info.icon,info.iconmask);
end;

procedure tcustommseform.setparentwidget(const Value: twidget);
begin
 if fframe <> nil then begin
  exclude(tcustomframe1(fframe).fstate,fs_rectsvalid);
 end;
 inherited;
end;

function tcustommseform.isgroupleader: boolean;
begin
 result:= (wo_groupleader in foptionswindow) or (fo_main in foptions);
end;

procedure tcustommseform.ReadState(Reader: TReader);
var
 bo1: boolean;
begin
 include(fscrollbox.fwidgetstate,ws_loadlock);
 bo1:= false;
 with treadercracker(reader) do begin
  if floaded <> nil then begin
   bo1:= floaded.IndexOf(fscrollbox) < 0;
   if bo1 then begin
    floaded.add(fscrollbox);
    tcomponentcracker(fscrollbox).FComponentState:=
     tcomponentcracker(fscrollbox).FComponentState + [csreading,csloading];
   end;
  end;
 end;
 inherited;
 if bo1 then begin
  exclude(tcomponentcracker(fscrollbox).FComponentState,csreading);
 end;
end;

procedure tcustommseform.insertwidget(const widget: twidget; const apos: pointty);
begin
 if not (csloading in widget.componentstate) then begin
  fscrollbox.insertwidget(widget,subpoint(apos,fscrollbox.fwidgetrect.pos));
 end
 else begin
  fscrollbox.insertwidget(widget,apos);
 end;
end;

function tcustommseform.getcontainer: twidget;
begin
 result:= fscrollbox;
end;

function tcustommseform.getchildwidgets(const index: integer): twidget;
begin
 result:= fscrollbox.getchildwidgets(index);
end;

function tcustommseform.childrencount: integer;
begin
 result:= fscrollbox.childrencount;
end;

procedure tcustommseform.dochildscaled(const sender: twidget);
begin
 inherited;
 if (fmainmenuwidget <> nil) and (fmainmenuwidget = sender) then begin
  updatescrollboxrect;
 end;
end;

function tcustommseform.checkdock(var info: draginfoty): boolean;
begin
 result:= true;
end;

function tcustommseform.getbuttonrects(const index: dockbuttonrectty): rectty;  
begin
 if fframe = nil then begin
  result:= nullrect;
 end
 else begin
  result:= tgripframe(fframe).buttonrects[index];
 end;
end;

function tcustommseform.getplacementrect: rectty;
begin
 with fscrollbox do begin
  result:= paintrect;
  deflaterect1(result,tcustomframe1(fframe).fi.innerframe);
  addpoint1(result.pos,clientpos);
 end;
end;

function tcustommseform.getcaption: msestring;
begin
 result:= fcaption;
end;

procedure tcustommseform.setcaption(const Value: msestring);
begin
 fcaption := Value;
 if ownswindow then begin
  window.caption:= fcaption;
 end;
end;

procedure tcustommseform.windowcreated;
begin
 inherited;
 if fcaption <> '' then begin
  caption:= fcaption;                //set windowcaption
 end;
end;

procedure tcustommseform.dofontheightdelta(var delta: integer);
begin
 if canevent(tmethod(fonfontheightdelta)) then begin
  fonfontheightdelta(self,delta);
 end;
end;

procedure tcustommseform.dokeydown(var info: keyeventinfoty);
begin
 inherited;
 with info do begin
  if not (es_processed in eventstate) and (shiftstate = []) and
   (((fo_closeonesc in foptions) or (fo_cancelonesc in foptions)) and 
     (key = key_escape) or
     (fo_closeonf10 in foptions) and (key = key_f10) or
     (fo_closeonenter in foptions) and 
              ((key = key_enter) or (key = key_return)))  then begin
   include(eventstate,es_processed);
   if key = key_f10 then begin
    window.modalresult:= mr_f10;
   end
   else begin
    if key = key_escape then begin
     if fo_cancelonesc in foptions then begin
      window.modalresult:= mr_cancel;
     end
     else begin
      window.modalresult:= mr_escape;
     end;
    end
    else begin
     window.modalresult:= mr_ok;
    end;
   end;
  end;
 end;
end;

procedure tcustommseform.doshortcut(var info: keyeventinfoty; const sender: twidget);
begin
 if not (es_processed in info.eventstate) then begin
  if (fmainmenu <> nil) and not ((csdesigning) in componentstate) then begin
   fmainmenu.doshortcut(info);
  end;
  if not (es_processed in info.eventstate) then begin
   inherited;
//   if not info.processed and (fmainmenuwidget <> nil) and (info.shiftstate = [ss_alt]) then begin
//    fmainmenuwidget.keydown
//   end;
  end;
 end;
end;

function tcustommseform.getframe: tgripframe;
begin
 result:= tgripframe(inherited getframe);
end;

procedure tcustommseform.setframe(const Value: tgripframe);
begin
 inherited setframe(value);
end;
{
function tcustommseform.getframescrollbox: tscrollboxframe;
begin
 result:= fscrollbox.frame;
end;

procedure tcustommseform.setframescrollbox(const Value: tscrollboxframe);
begin
 fscrollbox.frame:= value;
end;
}
procedure tcustommseform.setscrollbox(const avalue: tformscrollbox);
begin
 fscrollbox.Assign(avalue);
end;

function tcustommseform.getonbeforepaint: painteventty;
begin
 result:= fscrollbox.onbeforepaint;
end;

procedure tcustommseform.setonbeforepaint(const Value: painteventty);
begin
 fscrollbox.onbeforepaint:= value;
end;

function tcustommseform.getonpaint: painteventty;
begin
 result:= fscrollbox.onpaint;
end;

procedure tcustommseform.setonpaint(const Value: painteventty);
begin
 fscrollbox.onpaint:= value;
end;

function tcustommseform.getonafterpaint: painteventty;
begin
 result:= fscrollbox.onafterpaint;
end;

procedure tcustommseform.setonafterpaint(const Value: painteventty);
begin
 fscrollbox.onafterpaint:= value;
end;

procedure tcustommseform.seticon(const avalue: tmaskedbitmap);
begin
 ficon.assign(avalue);
end;

procedure tcustommseform.iconchanged(const sender: tobject);
var
 icon1,mask1: pixmapty;
begin
 if ownswindow then begin
  getwindowicon(ficon,icon1,mask1);
  gui_setwindowicon(window.winid,icon1,mask1);
  if (fo_main in foptions) and not (csdesigning in componentstate) then begin
   gui_setapplicationicon(icon1,mask1);
  end;
 end;
end;

procedure tcustommseform.widgetregionchanged(const sender: twidget);
begin
 inherited;
 if (fmainmenuwidget <> nil) and (sender = fmainmenuwidget) then begin
  updatescrollboxrect;
 end;
end;

{ tmseform }

constructor tmseform.create(aowner: tcomponent; load: boolean);
begin
 include(fmsecomponentstyle,cs_ismodule);
 inherited;
end;

class function tmseform.getmoduleclassname: string;
begin
// result:= tmseform.ClassName;
 //bug in dcc32: tmseform is replaced by self
 result:= 'tmseform';
end;

{ tformdockcontroller }

procedure tformdockcontroller.setoptionsdock(const avalue: optionsdockty);
begin
 inherited;
 updatebit({$ifdef FPC}longword{$else}word{$endif}(tdockform(fintf.getwidget).foptions),
             ord(fo_savepos),od_savepos in foptionsdock);
end;

{ tcustomdockform }

constructor tcustomdockform.create(aowner: tcomponent; load: boolean);
begin
 fdragdock:= tformdockcontroller.create(idockcontroller(self));
 if fscrollbox = nil then begin
  fscrollbox:= tdockformscrollbox.create(self);
 end;
 inherited;
end;

destructor tcustomdockform.destroy;
begin
 inherited;
 fdragdock.Free;
end;

function tcustomdockform.getdockcontroller: tdockcontroller;
begin
 result:= fdragdock;
end;

procedure tcustomdockform.setdragdock(const value: tformdockcontroller);
begin
 fdragdock.assign(value);
end;

function tcustomdockform.getframe: tgripframe;
begin
 result:= tgripframe(inherited getframe);
end;

procedure tcustomdockform.setframe(const avalue: tgripframe);
begin
 inherited setframe(avalue);
end;

procedure tcustomdockform.internalcreateframe;
begin
 tgripframe.create(iframe(self),fdragdock);
end;

procedure tcustomdockform.dragevent(var info: draginfoty);
begin
 if not fdragdock.beforedragevent(info) then begin
  inherited;
 end;
 fdragdock.afterdragevent(info);
end;

procedure tcustomdockform.updateoptions;
begin
 updatebit({$ifdef FPC}longword{$else}word{$endif}(fdragdock.foptionsdock),
         ord(od_savepos),fo_savepos in foptions);
 if fo_savepos in foptions then begin
  fdragdock.optionsdock:= fdragdock.optionsdock + [od_savepos];
 end
 else begin
  fdragdock.optionsdock:= fdragdock.optionsdock - [od_savepos];
 end;
 inherited;
end;

function tcustomdockform.getoptions: formoptionsty;
begin
 if od_savepos in fdragdock.optionsdock then begin
  include(foptions,fo_savepos);
 end
 else begin
  exclude(foptions,fo_savepos);
 end;
 result:= inherited getoptions;
end;

procedure tcustomdockform.dostatread1(const reader: tstatreader);
begin
 tdockcontroller(fdragdock).dostatread(reader);
end;

procedure tcustomdockform.dostatwrite1(const writer: tstatwriter);
var
 rect1: rectty;
begin
 if fparentwidget = nil then begin
  rect1:= window.normalwindowrect;
  fdragdock.dostatwrite(writer,@rect1);
 end
 else begin
  fdragdock.dostatwrite(writer,nil);
 end;
end;

procedure tcustomdockform.statreading;
begin
 tdockcontroller(fdragdock).statreading;
 inherited;
end;

procedure tcustomdockform.statread;
begin
 tdockcontroller(fdragdock).statread;
 inherited;
end;

procedure tcustomdockform.mouseevent(var info: mouseeventinfoty);
begin
 inherited;
 if not (es_processed in info.eventstate) then begin
  fdragdock.mouseevent(info);
 end;
end;

procedure tcustomdockform.doactivate;
begin
 fdragdock.doactivate;
 inherited;
end;

{ tdockform}

constructor tdockform.create(aowner: tcomponent; load: boolean);
begin
 include(fmsecomponentstyle,cs_ismodule);
 inherited;
end;

class function tdockform.getmoduleclassname: string;
begin
 result:= 'tdockform';
end;

{ tsubform }

constructor tsubform.create(aowner: tcomponent);
begin
 create(aowner,true);
end;

constructor tsubform.create(aowner: tcomponent; load: boolean);
begin
 include(fmsecomponentstyle,cs_ismodule);
 fwidgetrect.x:= 100;
 fwidgetrect.y:= 100;
 inherited create(aowner);
 fwidgetrect.cx:= 100;
 fwidgetrect.cy:= 100;
 if load and not (csdesigning in componentstate) and
          (cs_ismodule in fmsecomponentstyle) then begin
  loadmsemodule(self,tsubform);
 end;
end;

class function tsubform.getmoduleclassname: string;
begin
 result:= 'tsubform';
end;

procedure tsubform.getchildren(proc: tgetchildproc; root: tcomponent);
var
 int1: integer;
 comp1: tcomponent;
begin
 inherited;
 if root = self then begin
  for int1:= 0 to componentcount - 1 do begin
   comp1:= components[int1];
   if not comp1.hasparent then begin
    proc(comp1);
   end;
  end;
 end;
end;

end.

