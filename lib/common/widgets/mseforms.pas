{ MSEgui Copyright (c) 1999-2008 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseforms;

{$ifdef FPC}
 {$ifndef mse_no_ifi}
  {$define mse_with_ifi}
 {$endif}
 {$mode objfpc}{$h+}{$interfaces corba}
{$endif}

interface
uses
 msewidgets,msemenus,msegraphics,mseapplication,msegui,msegraphutils,mseevent,
 msetypes,msestrings,mseglob,mseguiglob,mseguiintf,
 msemenuwidgets,msestat,msestatfile,mseclasses,Classes,msedock,msesimplewidgets,
 msebitmap{$ifdef mse_with_ifi},mseifiglob{$endif};

type
 formoptionty = (fo_main,fo_terminateonclose,fo_freeonclose,
               fo_windowclosecancel,
               fo_defaultpos,fo_screencentered,fo_modal,
               fo_minimized,fo_maximized,fo_fullscreen,
               fo_closeonesc,fo_cancelonesc,fo_closeonenter,fo_closeonf10,
               fo_globalshortcuts,fo_localshortcuts,
               fo_autoreadstat,fo_autowritestat,
               fo_savepos,fo_savezorder,fo_savestate);
 formoptionsty = set of formoptionty;

const
 defaultformoptions = [fo_autoreadstat,fo_autowritestat,
                       fo_savepos,fo_savezorder,fo_savestate];
 defaultmainformoptions = defaultformoptions + [fo_main,fo_terminateonclose];
 defaultmainformoptionswindow = [wo_groupleader];
 
 defaultformwidgetoptions = (defaultoptionswidgetmousewheel - 
                         [ow_mousefocus{,ow_tabfocus}]) + [ow_subfocus,ow_hinton];
 defaultcontaineroptionswidget = defaultoptionswidgetmousewheel + 
                                        [ow_subfocus,ow_mousetransparent];

type
 tcustommseform = class;
 closequeryeventty = procedure(const sender: tcustommseform;
                               var amodalresult: modalresultty) of object;
  
 tformscrollbox = class(tscrollingwidgetnwr)
          //for internal use only
  private
   procedure readdummy(reader: treader);
   procedure writedummy(writer: twriter);
   procedure readbounds(reader: treader);
   procedure writebounds(writer: twriter);
  protected
   fboundsread: boolean;
   procedure setoptionswidget(const avalue: optionswidgetty); override;
   procedure defineproperties(filer: tfiler); override;
   procedure dochildscaled(const sender: twidget); override;
  public
   constructor create(aowner: tcustommseform); reintroduce;
  published
   property onscroll;
   property onresize;
   property onfontheightdelta;
   property onchildscaled;
   property oncalcminscrollsize;
   property onchildmouseevent;
   property onmouseevent;
   property onclientmouseevent;
   property onmousewheelevent;
   property onbeforepaint;
   property onpaint;
   property onafterpaint;
   property optionswidget default defaultcontaineroptionswidget;
 end;

 syseventeventty = procedure(const sender: tcustommseform;
                    var aevent: syseventty; var handled: boolean) of object;
                             
 tcustommseform = class(tcustomeventwidget,istatfile,idockcontroller)
  private
   foncreate: notifyeventty;
   fonloaded: notifyeventty;
   fondestroyed: notifyeventty;
   foneventloopstart: notifyeventty;
   fondestroy: notifyeventty;
   fonbeforeclosequery: closequeryeventty;
   fonclosequery: closequeryeventty;
   fonclose: notifyeventty;
   fonidle: idleeventty;
   fonterminatequery: terminatequeryeventty;
   fonterminated: notifyeventty;
   fmainmenu: tmainmenu;
   foptions: formoptionsty;
   fstatfile: tstatfile;
   fcaption: msestring;
   fmainmenuwidget: tframemenuwidget;
   foptionswindow: windowoptionsty;
   fonstatread: statreadeventty;
   fonstatafterread: notifyeventty;
   fonstatbeforeread: notifyeventty;
   fonstatafterwrite: notifyeventty;
   fonstatbeforewrite: notifyeventty;
   fonstatupdate: statupdateeventty;
   fstatvarname: msestring;
   fonstatwrite: statwriteeventty;
   fonwindowactivechanged: activechangeeventty;
   fonwindowdestroyed: windoweventty;
   fonapplicationactivechanged: booleaneventty;
   fonfontheightdelta: fontheightdeltaeventty;
   ficon: tmaskedbitmap;
   ficonchanging: integer;
   fonsysevent: syseventeventty;
   fonsyswindowevent: syseventeventty;
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
   procedure registerhandlers;
   procedure setsyseventty(const avalue: syseventeventty);
   procedure setsyswindoweventty(const avalue: syseventeventty);
  protected
   fscrollbox: tformscrollbox;
    //needed to distinguish between scrolled and unscrolled (mainmenu...) widgets
   procedure aftercreate; virtual;
   function createmainmenuwidget: tframemenuwidget; virtual;
   procedure updateoptions; virtual;
   function getoptions: formoptionsty; virtual;
   procedure updatescrollboxrect;
   procedure internalsetwidgetrect(Value: rectty;
                       const windowevent: boolean); override;
   procedure clientrectchanged; override;
   procedure updatewindowinfo(var info: windowinfoty); override;
   procedure setparentwidget(const Value: twidget); override;
   function isgroupleader: boolean; override;

   procedure readstate(reader: treader); override;
   procedure doonloaded; virtual;
   procedure doloaded; override;
   procedure loaded; override;
   procedure setoptionswidget(const avalue: optionswidgetty); override;

   function getcaption: msestring;
   procedure setcaption(const Value: msestring); virtual;
   procedure getchildren(proc: tgetchildproc; root: tcomponent); override;
   procedure doeventloopstart; virtual;
   procedure doterminated(const sender: tobject); virtual;
   procedure doterminatequery(var terminate: boolean); virtual;
   procedure doidle(var again: boolean); virtual;
   procedure dowindowactivechanged(const oldwindow,newwindow: twindow); virtual;
   procedure dowindowdestroyed(const awindow: twindow); virtual;
   procedure doapplicationactivechanged(const avalue: boolean); virtual;
   procedure dosysevent(const awindow: winidty; var aevent: syseventty;
                            var handled: boolean); virtual;
   procedure objectevent(const sender: tobject; const event: objecteventty); override;
   procedure receiveevent(const event: tobjectevent); override;
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure doshortcut(var info: keyeventinfoty; const sender: twidget); override;
   function getframe: tgripframe;
   procedure setframe(const Value: tgripframe);
   //istatfile
   procedure dostatread(const reader: tstatreader); virtual;
   procedure dostatread1(const reader: tstatreader); virtual;
   procedure dostatwrite(const writer: tstatwriter); virtual;
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
   function getminimizedsize(out apos: captionposty): sizety;
   procedure doafterload; override;
   procedure updatelayout(const sender: twidget); virtual; 
                               //called from scrollbox.onchildscaled
   //iificommand
   {$ifdef mse_with_ifi}
   procedure executeificommand(var acommand: ificommandcodety); override;
   {$endif}
   
   constructor docreate(aowner: tcomponent); virtual;
  public
   constructor create(aowner: tcomponent); overload; override;
   constructor create(aowner: tcomponent; load: boolean); reintroduce; overload;  virtual;
   destructor destroy; override;
   procedure insertwidget(const widget: twidget; const apos: pointty); override;
   procedure dochildscaled(const sender: twidget); override;
   function childrencount: integer; override;

   procedure beforeclosequery(var amodalresult: modalresultty); override;
   function canclose(const newfocus: twidget): boolean; override;
   function close(const amodalresult: modalresultty = mr_windowclosed): boolean; 
              //true if ok
   procedure beforedestruction; override;
   property optionswidget default defaultformwidgetoptions;
   property optionswindow: windowoptionsty read foptionswindow write setoptionswindow default [];
   property mainmenu: tmainmenu read fmainmenu write setmainmenu;
   property color default cl_background;
   property font: twidgetfont read getfont write setfont stored isfontstored;
   property fontempty: twidgetfontempty read getfontempty 
                  write setfontempty stored isfontemptystored;
   property options: formoptionsty read getoptions write setoptions
                         default defaultformoptions;

   property statfile: tstatfile read fstatfile write setstatfile;
   property statvarname: msestring read getstatvarname write fstatvarname;

   property caption: msestring read getcaption write setcaption;
   property icon: tmaskedbitmap read ficon write seticon;

   property oncreate: notifyeventty read foncreate write foncreate;
   property onloaded: notifyeventty read fonloaded write fonloaded;
   property oneventloopstart: notifyeventty read foneventloopstart 
                                   write foneventloopstart;
   property ondestroy: notifyeventty read fondestroy write fondestroy;
   property ondestroyed: notifyeventty read fondestroyed write fondestroyed;
   property onbeforeclosequery: closequeryeventty read fonbeforeclosequery 
                                        write fonbeforeclosequery;
   property onclosequery: closequeryeventty read fonclosequery 
                                        write fonclosequery;
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
   property onstatbeforewrite: notifyeventty read fonstatbeforewrite 
                                               write fonstatbeforewrite;
   property onstatafterwrite: notifyeventty read fonstatafterwrite 
                                               write fonstatafterwrite;

   property onwindowactivechanged: activechangeeventty read fonwindowactivechanged write fonwindowactivechanged;
   property onwindowdestroyed: windoweventty read fonwindowdestroyed write fonwindowdestroyed;
   property onapplicationactivechanged: booleaneventty 
                   read fonapplicationactivechanged write fonapplicationactivechanged;

   property onfontheightdelta: fontheightdeltaeventty read fonfontheightdelta
                     write fonfontheightdelta;
   property onchildscaled: notifyeventty read getonchildscaled write setonchildscaled;
   property onsysevent: syseventeventty read fonsysevent write setsyseventty;
   property onsyswindowevent: syseventeventty read fonsyswindowevent 
                                         write setsyswindoweventty;
  published
   property container: tformscrollbox read fscrollbox write setscrollbox;
 end;

 mseformclassty = class of tcustommseform;

 tmseformwidget = class(tcustommseform)
  published
   property optionswidget;
   property optionsskin;
   property optionswindow;
   property mainmenu;
   property color;
   property font;
   property fontempty;
   property options;
   property statfile;
   property statvarname;
   property caption;
   property icon;

   property oncreate;
   property onloaded;
   property oneventloopstart;
   property ondestroy;
   property ondestroyed;
   property onbeforeclosequery;
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
   property onmousewheelevent;
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
   property onfocusedwidgetchanged;
   property ondeactivate;
   property onhide;
   property onevent;
   property onasyncevent;

   property onstatupdate;
   property onstatread;
   property onstatbeforeread;
   property onstatafterread;
   property onstatwrite;
   property onstatbeforewrite;
   property onstatafterwrite;

   property onfontheightdelta;
   property onchildscaled;
   
   property onsysevent;
   property onsyswindowevent;
 end;

 tmseform = class(tmseformwidget)
  protected
   class function getmoduleclassname: string; override;
   class function hasresource: boolean; override;
  public
   constructor create(aowner: tcomponent; load: boolean); override;
 end;

 tmainform = class(tmseform)
  protected
   class function getmoduleclassname: string; override;
   class function hasresource: boolean; override;
   procedure aftercreate; override;
  public
  published
   property options default defaultmainformoptions;
   property optionswindow default defaultmainformoptionswindow;
 end;

 mainformclassty = class of tmainform;
  
 tformdockcontroller = class(tdockcontroller)
  protected
   procedure setoptionsdock(const avalue: optionsdockty); override;
 end;

 tcustomdockform = class(tcustommseform,idocktarget)
  private
   function getdockcontroller: tdockcontroller;
   procedure setdragdock(const Value: tformdockcontroller);
   function getframe: tgripframe;
   procedure setframe(const avalue: tgripframe);
  protected
   fdragdock: tformdockcontroller;
   procedure internalcreateframe; override;
   procedure updateoptions; override;
   function getoptions: formoptionsty; override;
   procedure statreading; override;
   procedure statread; override;
   procedure dostatread1(const reader: tstatreader); override;
   procedure dostatwrite1(const writer: tstatwriter); override;
   procedure mouseevent(var info: mouseeventinfoty); override;
   procedure childmouseevent(const sender: twidget;
                          var info: mouseeventinfoty); override;
   procedure statechanged; override;
   procedure poschanged; override;
   procedure activechanged; override;
   procedure doactivate; override;
   procedure parentchanged; override;
  public
   constructor create(aowner: tcomponent; load: boolean); override;
   destructor destroy; override;
   procedure activate(const abringtofront: boolean = true); override;
   function canfocus: boolean; override;
   procedure dragevent(var info: draginfoty); override;
  published
   property dragdock: tformdockcontroller read fdragdock write setdragdock;
   property frame: tgripframe read getframe write setframe;
 end;

 tdockformwidget = class(tcustomdockform)
  published
   property optionswidget;
   property optionsskin;
   property optionswindow;
   property mainmenu;
   property color;
   property font;
   property fontempty;
   property options;
   property statfile;
   property statvarname;
   property caption;
   property icon;

   property oncreate;
   property onloaded;
   property oneventloopstart;
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
   property onmousewheelevent;
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
   property onstatbeforewrite;
   property onstatafterwrite;

   property onfontheightdelta;
   property onchildscaled;
 end;

 tdockform = class(tdockformwidget)
  protected
   class function getmoduleclassname: string; override;
   class function hasresource: boolean; override;
  public
   constructor create(aowner: tcomponent; load: boolean); override;
 end;

 tdockformscrollbox = class(tformscrollbox,idocktarget)
  protected
   procedure clientrectchanged; override;
   procedure widgetregionchanged(const sender: twidget); override;
   procedure dopaint(const acanvas: tcanvas); override;
   function getdockcontroller: tdockcontroller;
   procedure mouseevent(var info: mouseeventinfoty); override;
  public
   constructor create(aowner: tcustomdockform); reintroduce;
 end;

 tsubform = class(tpublishedwidget)
  protected
   class function getmoduleclassname: string; override;
   class function hasresource: boolean; override;
   procedure getchildren(proc: tgetchildproc; root: tcomponent); override;
  public
   constructor create(aowner: tcomponent); overload; override;
   constructor create(aowner: tcomponent; load: boolean); 
                                     reintroduce; overload; virtual;
 end;

 subformclassty = class of tsubform;

 tscrollboxform = class(tscrollbox)
  protected
   class function getmoduleclassname: string; override;
   class function hasresource: boolean; override;
   procedure getchildren(proc: tgetchildproc; root: tcomponent); override;
  public
   constructor create(aowner: tcomponent); overload; override;
   constructor create(aowner: tcomponent; load: boolean); 
                                     reintroduce; overload; virtual;
 end;
 
 scrollboxformclassty = class of tscrollboxform;
 
function createmseform(const aclass: tclass; 
                   const aclassname: pshortstring): tmsecomponent;
function createmainform(const aclass: tclass; 
                   const aclassname: pshortstring): tmsecomponent;
function createsubform(const aclass: tclass; 
                   const aclassname: pshortstring): tmsecomponent;
function createscrollboxform(const aclass: tclass; 
                   const aclassname: pshortstring): tmsecomponent;
function simulatemodalresult(const awidget: twidget;
                              const amodres: modalresultty): boolean;

implementation
uses
 sysutils,mselist,typinfo,msekeyboard,msebits;
const
 containercommonflags: optionswidgetty = 
            [ow_arrowfocus,ow_arrowfocusin,ow_arrowfocusout,ow_destroywidgets,
             ow_parenttabfocus,ow_mousewheel{,
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

function createmainform(const aclass: tclass; 
                    const aclassname: pshortstring): tmsecomponent;

begin
 result:= tmsecomponent(aclass.newinstance);
 tcomponent1(result).setdesigning(true); //used for wo_groupleader
 tcustommseform(result).create(nil,false);
 tmsecomponent1(result).factualclassname:= aclassname;
end;

function createsubform(const aclass: tclass; 
                    const aclassname: pshortstring): tmsecomponent;
begin
 result:= subformclassty(aclass).create(nil,false);
 tmsecomponent1(result).factualclassname:= aclassname;
end;

function createscrollboxform(const aclass: tclass; 
                    const aclassname: pshortstring): tmsecomponent;
begin
 result:= scrollboxformclassty(aclass).create(nil,false);
 tmsecomponent1(result).factualclassname:= aclassname;
end;

function simulatemodalresult(const awidget: twidget;
                              const amodres: modalresultty): boolean;
begin
 result:= awidget <> nil;
 if result then begin
  with twindow1(awidget.window) do begin
   fmodalresult:= amodres;
   try
    result:= awidget.canclose(nil);
    if result then begin
     awidget.hide;
    end;
   finally
    if fmodalresult = amodres then begin
     fmodalresult:= mr_none;
    end;
   end;
  end;
 end
 else begin
  result:= false;
 end;
end;

{ tformscrollbox}

constructor tformscrollbox.create(aowner: tcustommseform);
begin
 inherited create(aowner);
 setsubcomponent(true);
 exclude(fwidgetstate,ws_iswidget);
 foptionswidget:= defaultcontaineroptionswidget;
// parentwidget:= aowner;
 setlockedparentwidget(aowner);
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

procedure tformscrollbox.readdummy(reader: treader);
begin
{$ifdef FPC}
 reader.driver.skipvalue;
{$else}
 reader.skipvalue;
{$endif}
end;

procedure tformscrollbox.writedummy(writer: twriter);
begin
 //dummy
end;

procedure tformscrollbox.readbounds(reader: treader);
var
 rect1: rectty;
begin
 reader.readlistbegin;
 rect1.x:= reader.readinteger;
 rect1.y:= reader.readinteger;
 rect1.cx:= reader.readinteger;
 rect1.cy:= reader.readinteger;
 reader.readlistend; 
 widgetrect:= rect1;
 fboundsread:= true;
end;

procedure tformscrollbox.writebounds(writer: twriter);
begin
 writer.writelistbegin;
 writer.writeinteger(fwidgetrect.x);
 writer.writeinteger(fwidgetrect.y);
 writer.writeinteger(fwidgetrect.cx);
 writer.writeinteger(fwidgetrect.cy);
 writer.writelistend; 
end;

procedure tformscrollbox.defineproperties(filer: tfiler);
begin
 filer.defineproperty('bounds_x',{$ifdef FPC}@{$endif}readdummy,
                                 {$ifdef FPC}@{$endif}writedummy,false);
 filer.defineproperty('bounds_y',{$ifdef FPC}@{$endif}readdummy,
                                 {$ifdef FPC}@{$endif}writedummy,false);
 filer.defineproperty('bounds_cx',{$ifdef FPC}@{$endif}readdummy,
                                 {$ifdef FPC}@{$endif}writedummy,false);
 filer.defineproperty('bounds_cy',{$ifdef FPC}@{$endif}readdummy,
                                 {$ifdef FPC}@{$endif}writedummy,false);
 filer.defineproperty('bounds_cxmin',{$ifdef FPC}@{$endif}readdummy,
                                 {$ifdef FPC}@{$endif}writedummy,false);
 filer.defineproperty('bounds_cymax',{$ifdef FPC}@{$endif}readdummy,
                                 {$ifdef FPC}@{$endif}writedummy,false);
 filer.defineproperty('anchors',{$ifdef FPC}@{$endif}readdummy,
                                 {$ifdef FPC}@{$endif}writedummy,false);
 filer.defineproperty('bounds',{$ifdef FPC}@{$endif}readbounds,
                                 {$ifdef FPC}@{$endif}writebounds,true);
end;

procedure tformscrollbox.dochildscaled(const sender: twidget);
begin
 tcustommseform(owner).updatelayout(sender);
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

procedure tdockformscrollbox.mouseevent(var info: mouseeventinfoty);
begin
 inherited;
 getdockcontroller.checkmouseactivate(self,info);
end;

{ tcustommseform }

constructor tcustommseform.docreate(aowner: tcomponent);
begin
 inherited create(aowner);
end;

constructor tcustommseform.create(aowner: tcomponent; load: boolean);

begin
 ficon:= tmaskedbitmap.create(false);
 ficon.onchange:= {$ifdef FPC}@{$endif}iconchanged;
 fwidgetrect.x:= 100;
 fwidgetrect.y:= 100;
 options:= defaultformoptions;
 docreate(aowner);
// inherited create(aowner);
 aftercreate;
 fwidgetrect.cx:= 100;
 fwidgetrect.cy:= 100;
 if fscrollbox = nil then begin
  fscrollbox:= tformscrollbox.create(self);
 end;
 optionswidget:= defaultformwidgetoptions;
 color:= cl_background;
 if load and not (csdesigning in componentstate) and
          (cs_ismodule in fmsecomponentstate) then begin
  loadmsemodule(self,tcustommseform);
  doafterload;
 end
 else begin
  registerhandlers;
 end;
end;

constructor tcustommseform.create(aowner: tcomponent);
begin
 create(aowner,not (cs_noload in fmsecomponentstate));
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
 if not (csdesigning in componentstate) and 
            (assigned(fonsysevent) or assigned(fonsyswindowevent)) then begin
  application.unregistersyseventhandler({$ifdef FPC}@{$endif}dosysevent);
 end;
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

procedure tcustommseform.registerhandlers;
begin
 application.registeronterminated({$ifdef FPC}@{$endif}doterminated);
 application.registeronterminate({$ifdef FPC}@{$endif}doterminatequery);
 application.registeronidle({$ifdef FPC}@{$endif}doidle);
 application.registeronactivechanged({$ifdef FPC}@{$endif}dowindowactivechanged);
 application.registeronwindowdestroyed({$ifdef FPC}@{$endif}dowindowdestroyed);
 application.registeronapplicationactivechanged(
       {$ifdef FPC}@{$endif}doapplicationactivechanged);
end;
 

procedure tcustommseform.doafterload;
begin
 if (fstatfile <> nil) and (fo_autoreadstat in foptions) then begin
  fstatfile.readstat;
 end;
 registerhandlers;
 doonloaded;
end;

{$ifdef mse_with_ifi}
procedure tcustommseform.executeificommand(var acommand: ificommandcodety);
begin
 inherited;
 case acommand of
  icc_close: begin
   application.postevent(tobjectevent.create(ek_closeform,ievent(self)));
  end;
 end;
end;
{$endif}

procedure tcustommseform.beforeclosequery(var amodalresult: modalresultty);
begin
 inherited;
 if canevent(tmethod(fonbeforeclosequery)) then begin
  fonbeforeclosequery(self,amodalresult);
 end;
 if (amodalresult = mr_windowclosed) and 
                              (fo_windowclosecancel in foptions) then begin
  amodalresult:= mr_cancel;
 end;
end;

function tcustommseform.canclose(const newfocus: twidget): boolean;
var
 modres: modalresultty;
begin
 result:= inherited canclose(newfocus);
 if result and (newfocus = nil) then begin
  if canevent(tmethod(fonclosequery)) then begin
   modres:= twindow1(window).fmodalresult;
   if modres = mr_none then begin
    modres:= mr_canclose;
   end;
   fonclosequery(self,modres);
   result:= modres <> mr_none;
   if twindow1(window).fmodalresult <> mr_canclose then begin
    twindow1(window).fmodalresult:= modres;
   end;
  end;
  if result and ((twindow1(window).fmodalresult <> mr_none) or 
                                        (application.terminating)) then begin
   if canevent(tmethod(fonclose)) then begin
    fonclose(self);
   end;
   if (fstatfile <> nil) and (fo_autowritestat in foptions) and
                 not (csdesigning in componentstate) then begin
    fstatfile.writestat;
   end;
 {$ifdef mse_with_ifi}
   if fifiserverintf <> nil then begin
    fifiserverintf.sendmodalresult(iificlient(self),window.modalresult);
   end;
 {$endif}
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

function tcustommseform.close(
        const amodalresult: modalresultty = mr_windowclosed): boolean; 
                //simulates mr_windowclose, true if ok
begin
 if ownswindow then begin
  window.modalresult:= amodalresult;
 end
 else begin
  simulatemodalresult(self,amodalresult);
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
// if (root = self) or issubcomponent(root,self) then begin
  for int1:= 0 to componentcount - 1 do begin
   comp1:= components[int1];
   if not (cssubcomponent in comp1.componentstyle) and 
                              not comp1.hasparent then begin
    proc(comp1);
   end;
  end;
 end;
end;

procedure tcustommseform.doonloaded;
begin
 if canevent(tmethod(fonloaded)) then begin
  fonloaded(self);
 end;
end;

procedure tcustommseform.doloaded;
begin
 if canevent(tmethod(foncreate)) then begin
  foncreate(self);
 end;
 inherited;
end;

procedure tcustommseform.loaded;
begin
 exclude(fscrollbox.fwidgetstate,ws_loadlock);
// if fmainmenuwidget <> nil then begin
//  fmainmenuwidget.loaded;
// end;
 if (fo_screencentered in foptions) and not (csdesigning in componentstate) then begin
  window.windowpos:= wp_screencentered;
 end;
 inherited;
 if fmainmenuwidget <> nil then begin
  fmainmenuwidget.loaded;
 end;
 updateoptions;
 updatemainmenutemplates;
 application.postevent(tobjectevent.create(ek_loaded,ievent(self)));
end;

procedure tcustommseform.setoptionswidget(const avalue: optionswidgetty);
begin
 inherited;
 replacebits1(longword(fscrollbox.foptionswidget),longword(avalue),
                   longword(containercommonflags));
end;

procedure tcustommseform.doeventloopstart;
begin
 if canevent(tmethod(foneventloopstart)) then begin
  foneventloopstart(self);
 end;
end;

procedure tcustommseform.receiveevent(const event: tobjectevent);
begin
 inherited;
 case event.kind of
  ek_loaded: begin
   doeventloopstart;
   if (fo_modal in foptions) and not (csloading in componentstate) and 
                           showing  then begin
    show(true);
   end;
  end;
  ek_closeform: begin
   close;
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
// if not (csloading in componentstate) then begin
  if (fmainmenuwidget <> nil) and
                     (fmainmenu <> nil) then begin
   fmainmenuwidget.assigntemplate(fmainmenu.template);
  end;
  updatescrollboxrect;
// end;
end;

function tcustommseform.createmainmenuwidget: tframemenuwidget;
begin
 result:= tframemenuwidget.create(self,fmainmenu);
end;

procedure tcustommseform.setmainmenu(const Value: tmainmenu);
begin
 if value <> fmainmenu then begin
  freeandnil(fmainmenuwidget);
  setlinkedvar(value,tmsecomponent(fmainmenu));
  if value <> nil then begin
   fmainmenuwidget:= createmainmenuwidget;
   twidget1(fmainmenuwidget).setdesigning(csdesigning in componentstate);
   updatemainmenutemplates;
  end
  else begin
   updatescrollboxrect;
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
    if not (csdestroying in componentstate) then begin
     updatemainmenutemplates;
     if fmainmenuwidget <> nil then begin
      fmainmenuwidget.menuchanged(nil);
     end;
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
 mask3: formoptionsty = [fo_maximized,fo_minimized,fo_fullscreen];
var
 opt1,opt2: formoptionsty;
begin
 if foptions <> value then begin
  opt1:= formoptionsty(setsinglebit(
       {$ifdef FPC}longword{$else}longword{$endif}(value),
       {$ifdef FPC}longword{$else}longword{$endif}(foptions),
       {$ifdef FPC}longword{$else}longword{$endif}(mask2)));
  opt2:= formoptionsty(setsinglebit(
       {$ifdef FPC}longword{$else}longword{$endif}(value),
       {$ifdef FPC}longword{$else}longword{$endif}(foptions),
       {$ifdef FPC}longword{$else}longword{$endif}(mask3)));
  foptions:= formoptionsty(setsinglebit(
       {$ifdef FPC}longword{$else}longword{$endif}(value),
       {$ifdef FPC}longword{$else}longword{$endif}(foptions),
       {$ifdef FPC}longword{$else}longword{$endif}(mask1)));
  foptions:= formoptionsty(replacebits(
       {$ifdef FPC}longword{$else}longword{$endif}(opt1),
       {$ifdef FPC}longword{$else}longword{$endif}(foptions),
       {$ifdef FPC}longword{$else}longword{$endif}(mask2)));
  foptions:= formoptionsty(replacebits(
       {$ifdef FPC}longword{$else}longword{$endif}(opt2),
       {$ifdef FPC}longword{$else}longword{$endif}(foptions),
       {$ifdef FPC}longword{$else}longword{$endif}(mask3)));
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
  if fo_fullscreen in foptions then begin
   fwindow.windowpos:= wp_fullscreen;
  end
  else begin
   if fo_maximized in foptions then begin
    fwindow.windowpos:= wp_maximized;
   end
   else begin
    if fo_minimized in foptions then begin
     fwindow.windowpos:= wp_minimized;
    end
    else begin
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
  end;
 end;
end;

function tcustommseform.getoptions: formoptionsty;
begin
 result:= foptions;
end;

procedure tcustommseform.setoptionswindow(const Value: windowoptionsty);
const
 mask1: windowoptionsty = [wo_taskbar,wo_notaskbar];
begin
 foptionswindow:= windowoptionsty(setsinglebit(
                    {$ifdef FPC}longword{$else}byte{$endif}(value),
                    {$ifdef FPC}longword{$else}byte{$endif}(foptionswindow),
                    {$ifdef FPC}longword{$else}byte{$endif}(mask1)));
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
 rect1,rect2: rectty;
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
//  setclippedwidgetrect(rect1);
  rect1:= clipinrect(rect1,application.screenrect); //shift into screen
  widgetrect:= rect1;
 end;
 if fo_savezorder in foptions then begin
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
    if fo_main in foptions then begin
     bo1:= true;
     if pos1 = wp_minimized then begin
      pos1:= wp_normal;
     end;
    end;
    if bo1 then begin
     if pos1 <> wp_minimized then begin
      show;
     end;
     window.windowpos:= pos1; //does not work with kde and invisible window
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
 if fparentwidget = nil then begin
  if fo_savezorder in foptions then begin
   window1:= window.stackedunder;
   if window1 <> nil then begin
    writer.writestring('stackedunder',ownernamepath(window1.owner));
   end
   else begin
    writer.writestring('stackedunder','');
   end;
  end;
  if  fo_savepos in foptions then begin
   with window.normalwindowrect do begin
    writer.writeinteger('x',x);
    writer.writeinteger('y',y);
    writer.writeinteger('cx',cx);
    writer.writeinteger('cy',cy);
   end;
  end;
 end;
end;

procedure tcustommseform.dostatwrite(const writer: tstatwriter);
begin
 if assigned(fonstatbeforewrite) then begin
  fonstatbeforewrite(self);
 end;
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
 if assigned(fonstatafterwrite) then begin
  fonstatafterwrite(self);
 end;
end;

procedure tcustommseform.updatescrollboxrect;
var
 rect1: rectty;
begin
 if not (ws_destroying in fwidgetstate) and 
                       (not (csloading in componentstate) or 
                        not fscrollbox.fboundsread) then begin
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

procedure tcustommseform.internalsetwidgetrect(Value: rectty;
                       const windowevent: boolean);
begin
 inherited;
 if csloading in componentstate then begin
  updatescrollboxrect; //no clientrectchanged
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
 if csdesigning in componentstate then begin
  exclude(info.options,wo_groupleader);
 end;
 if fo_maximized in foptions then begin
  info.initialwindowpos:= wp_maximized;
 end
 else begin
  if fo_minimized in foptions then begin
   info.initialwindowpos:= wp_minimized;
  end
  else begin   
   if fo_defaultpos in foptions then begin
    info.initialwindowpos:= wp_default;
   end;
  end;
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

function tcustommseform.getminimizedsize(out apos: captionposty): sizety;
begin
 if fframe = nil then begin
  result:= nullsize;
 end
 else begin
  result:= tgripframe(fframe).getminimizedsize(apos);
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
var
 modres1: modalresultty;
begin
 inherited;
 with info do begin
  if not (es_processed in eventstate) and (shiftstate = []) and
   (((fo_closeonesc in foptions) or (fo_cancelonesc in foptions)) and 
     (key = key_escape) or
     (fo_closeonf10 in foptions) and (key = key_f10) or
     (fo_closeonenter in foptions) and isenterkey(self,key))  then begin
   include(eventstate,es_processed);
   if key = key_f10 then begin
    modres1:= mr_f10;
   end
   else begin
    if key = key_escape then begin
     if fo_cancelonesc in foptions then begin
      modres1:= mr_cancel;
     end
     else begin
      modres1:= mr_escape;
     end;
    end
    else begin
     modres1:= mr_ok;
    end;
   end;
   close(modres1);
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
 if ficonchanging = 0 then begin
  inc(ficonchanging);
  ficon.colormask:= false;
  dec(ficonchanging); 
  if ownswindow then begin
   getwindowicon(ficon,icon1,mask1);
   gui_setwindowicon(window.winid,icon1,mask1);
   if (fo_main in foptions) and not (csdesigning in componentstate) then begin
    gui_setapplicationicon(icon1,mask1);
   end;
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

procedure tcustommseform.setsyseventty(const avalue: syseventeventty);
begin
 if not (csdesigning in componentstate) then begin
  if assigned(avalue) then begin
   if not assigned(fonsysevent) and not assigned(fonsyswindowevent) then begin
    application.registersyseventhandler({$ifdef FPC}@{$endif}dosysevent);
   end;
  end
  else begin
   if assigned(fonsysevent) and not assigned(fonsyswindowevent) then begin
    application.unregistersyseventhandler({$ifdef FPC}@{$endif}dosysevent);
   end;
  end;
 end;
 fonsysevent:= avalue;
end;

procedure tcustommseform.setsyswindoweventty(const avalue: syseventeventty);
begin
 if not (csdesigning in componentstate) then begin
  if assigned(avalue) then begin
   if not assigned(fonsysevent) and not assigned(fonsyswindowevent) then begin
    application.registersyseventhandler({$ifdef FPC}@{$endif}dosysevent);
   end;
  end
  else begin
   if assigned(fonsyswindowevent) and not assigned(fonsysevent) then begin
    application.unregistersyseventhandler({$ifdef FPC}@{$endif}dosysevent);
   end;
  end;
 end;
 fonsyswindowevent:= avalue;
end;

procedure tcustommseform.dosysevent(const awindow: winidty;
               var aevent: syseventty; var handled: boolean);
begin
 if assigned(fonsysevent) then begin
  fonsysevent(self,aevent,handled);
 end;
 if assigned(fonsyswindowevent) and not handled and 
         (awindow <> 0) and (twindow1(window).fwindow.id = awindow) then begin
  fonsyswindowevent(self,aevent,handled);
 end;
end;

procedure tcustommseform.aftercreate;
begin
 //dummy
end;

procedure tcustommseform.updatelayout(const sender: twidget);
begin
 //dummy
end;

{ tmseform }

constructor tmseform.create(aowner: tcomponent; load: boolean);
begin
 include(fmsecomponentstate,cs_ismodule);
 inherited;
end;

class function tmseform.getmoduleclassname: string;
begin
// result:= tmseform.ClassName;
 //bug in dcc32: tmseform is replaced by self
 result:= 'tmseform';
end;

class function tmseform.hasresource: boolean;
begin
 result:= self <> tmseform;
end;

{ tmainform }

class function tmainform.getmoduleclassname: string;
begin
// result:= tmseform.ClassName;
 //bug in dcc32: tmseform is replaced by self
 result:= 'tmainform';
end;

class function tmainform.hasresource: boolean;
begin
 result:= self <> tmainform;
end;

procedure tmainform.aftercreate;
begin
 inherited;
 options:= defaultmainformoptions;
 optionswindow:= defaultmainformoptionswindow;
end;

{ tformdockcontroller }

procedure tformdockcontroller.setoptionsdock(const avalue: optionsdockty);
begin
 inherited;
 updatebit({$ifdef FPC}longword{$else}longword{$endif}(tdockform(fintf.getwidget).foptions),
             ord(fo_savepos),od_savepos in foptionsdock);
 updatebit({$ifdef FPC}longword{$else}longword{$endif}(tdockform(fintf.getwidget).foptions),
             ord(fo_savezorder),od_savezorder in foptionsdock);
end;

{ tcustomdockform }

constructor tcustomdockform.create(aowner: tcomponent; load: boolean);
begin
 if fdragdock = nil then begin
  fdragdock:= tformdockcontroller.create(idockcontroller(self));
 end;
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
 tgripframe.create(iscrollframe(self),fdragdock);
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
 updatebit({$ifdef FPC}longword{$else}longword{$endif}(fdragdock.foptionsdock),
         ord(od_savepos),fo_savepos in foptions);
 updatebit({$ifdef FPC}longword{$else}longword{$endif}(fdragdock.foptionsdock),
         ord(od_savezorder),fo_savezorder in foptions);
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
 if od_savezorder in fdragdock.optionsdock then begin
  include(foptions,fo_savezorder);
 end
 else begin
  exclude(foptions,fo_savezorder);
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
// else begin
//  fdragdock.checkmouseactivate(self,info);
// end;
end;

procedure tcustomdockform.childmouseevent(const sender: twidget;
               var info: mouseeventinfoty);
var
 pt1,pt2: pointty;
begin
 pt2:= pos;
 fdragdock.checkmouseactivate(self,info);
 application.delayedmouseshift(subpoint(pos,pt2)); //follow shift in view
 if (frame <> nil) and fdragdock.ismdi and 
                       not (csdesigning in componentstate) then begin
  pt1:= info.pos;
  translatewidgetpoint1(info.pos,sender,self);
  frame.mouseevent(info);
  info.pos:= pt1;
 end;
 if not (es_processed in info.eventstate) then begin  
  fdragdock.childmouseevent(sender,info);
  inherited;
 end;
end;

procedure tcustomdockform.doactivate;
begin
 fdragdock.doactivate;
 inherited;
end;

procedure tcustomdockform.parentchanged;
begin
 inherited;
 fdragdock.parentchanged(self);
end;

function tcustomdockform.canfocus: boolean;
begin
 result:= inherited canfocus and (fdragdock.mdistate <> mds_minimized);
end;

procedure tcustomdockform.activate(const abringtofront: boolean = true);
begin
 if fdragdock.mdistate = mds_minimized then begin
  fdragdock.mdistate:= mds_normal;
 end;
 if fdragdock.ismdi then begin
  bringtofront;
 end;
 inherited;
end;

procedure tcustomdockform.activechanged;
begin
 if fframe <> nil then begin
  invalidaterect(tgripframe(fframe).griprect,org_widget);
 end;
 inherited;
end;

procedure tcustomdockform.statechanged;
begin
 fdragdock.statechanged(fwidgetstate);
 inherited;
end;

procedure tcustomdockform.poschanged;
begin
 fdragdock.poschanged;
 inherited;
end;

{ tdockform}

constructor tdockform.create(aowner: tcomponent; load: boolean);
begin
 include(fmsecomponentstate,cs_ismodule);
 inherited;
end;

class function tdockform.getmoduleclassname: string;
begin
 result:= 'tdockform';
end;

class function tdockform.hasresource: boolean;
begin
 result:= self <> tdockform;
end;

{ tsubform }

constructor tsubform.create(aowner: tcomponent);
begin
 create(aowner,not (cs_noload in fmsecomponentstate));
end;

constructor tsubform.create(aowner: tcomponent; load: boolean);
begin
 include(fmsecomponentstate,cs_ismodule);
 fwidgetrect.x:= 100;
 fwidgetrect.y:= 100;
 inherited create(aowner);
 fwidgetrect.cx:= 100;
 fwidgetrect.cy:= 100;
 if load and not (csdesigning in componentstate) and
          (cs_ismodule in fmsecomponentstate) then begin
  loadmsemodule(self,tsubform);
 end;
end;

class function tsubform.getmoduleclassname: string;
begin
 result:= 'tsubform';
end;

class function tsubform.hasresource: boolean;
begin
 result:= self <> tsubform;
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

{ tscrollboxform }

constructor tscrollboxform.create(aowner: tcomponent);
begin
 create(aowner,not (cs_noload in fmsecomponentstate));
end;

constructor tscrollboxform.create(aowner: tcomponent; load: boolean);
begin
 include(fmsecomponentstate,cs_ismodule);
 fwidgetrect.x:= 100;
 fwidgetrect.y:= 100;
 inherited create(aowner);
 fwidgetrect.cx:= 100;
 fwidgetrect.cy:= 100;
 if load and not (csdesigning in componentstate) and
          (cs_ismodule in fmsecomponentstate) then begin
  loadmsemodule(self,tscrollboxform);
 end;
end;

class function tscrollboxform.getmoduleclassname: string;
begin
 result:= 'tscrollboxform';
end;

class function tscrollboxform.hasresource: boolean;
begin
 result:= self <> tscrollboxform;
end;

procedure tscrollboxform.getchildren(proc: tgetchildproc; root: tcomponent);
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

