{ MSEgui Copyright (c) 1999-2010 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msemenus;

{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}

interface
uses
 mseact,msegui,msearrayprops,mseclasses,msegraphutils,
 msedrawtext,msegraphics,mseevent,mseglob,mseguiglob,mseshapes,mserichstring,
 msetypes,msestrings,Classes,msekeyboard,msebitmap;

type
 menuoptionty = (mo_insertfirst,mo_singleregion,mo_shortcutright,mo_commonwidth,
                 mo_activate,{mo_noanim,}mo_mainarrow,mo_updateonidle);
 menuoptionsty = set of menuoptionty;
const
 defaultmenuoptions = [mo_shortcutright];
 defaultmainmenuoptions = defaultmenuoptions + [mo_updateonidle];
 defaultmenuactoptions = [mao_shortcutcaption];
 
type
 menuinfoarty = array of actioninfoty;
 tmenuitem = class;

 menuitemeventty = procedure(const sender: tmenuitem) of object;

 tmenuitems = class(tpersistentarrayprop,ievent)
  private
   fowner: tmenuitem;
   function getmenuitems(index: integer): tmenuitem;
   procedure setmenuitems(index: integer; const Value: tmenuitem);
  protected
   procedure createitem(const index: integer; var item: tpersistent); override;
   procedure dosizechanged; override;
   procedure dochange(const aindex: integer); override;
   procedure receiveevent(const event: tobjectevent);
  public
   constructor create(const aowner: tmenuitem);
   class function getitemclasstype: persistentclassty; override;
   procedure assign(source: tpersistent); override;
   procedure insert(const index: integer; const aitem: tmenuitem); overload;
      //aitem is owned
   procedure insert(const index: integer; const aitems: tmenuitems); overload;
      //items are copied
   procedure insert(const index: integer; const captions: array of msestring;
                            //if index > count -> index:= count
                 const options: array of menuactionoptionsty;
                 const states: array of actionstatesty;
                 const onexecutes: array of notifyeventty); overload;
   procedure insertseparator(const index: integer);
   property items[index: integer]: tmenuitem read getmenuitems write setmenuitems; default;
   function itembyname(const name: ansistring): tmenuitem;
   function itemindexbyname(const name: ansistring): integer;
 end;

 tmenufont = class(tparentfont)
  public
   class function getinstancepo(owner: tobject): pfont; override;
 end;
 
 tmenufontactive = class(tparentfont)
  public
   class function getinstancepo(owner: tobject): pfont; override;
 end;
 
 tcustommenu = class;

 imenuitem = interface(ievent)
  procedure setstate(const avalue: actionstatesty);
  function getstate: actionstatesty;  
 end;
 
 tmenuitem = class(teventpersistent,iactionlink,imenuitem,iimagelistinfo)
  private
   fparentmenu: tmenuitem;
   fonchange: menuitemeventty;
   fname: string;
//   fgroup: integer;
   fsource: imenuitem;
   ffont: tmenufont;
   ffontactive: tmenufontactive;
   fcoloractive: colorty;
   function getsubmenu: tmenuitems;
   procedure setsubmenu(const Value: tmenuitems);
   procedure setcaption(const Value: captionty);
   function iscaptionstored: Boolean;
   procedure setstate(const avalue: actionstatesty);
   function getstate: actionstatesty;
   function isstatestored: Boolean;

   procedure actionchanged;
   procedure checksubmenu;
   function getitems(const index: integer): tmenuitem;
   procedure setitems(const index: integer; const Value: tmenuitem);
   procedure setaction(const avalue: tcustomaction);
   function isonexecutestored: Boolean;
   function isshortcutstored: Boolean;
   procedure setshortcut(const avalue: shortcutty);
   function isshortcut1stored: Boolean;
   procedure setshortcuts(const avalue: shortcutarty);
   procedure setshortcuts1(const avalue: shortcutarty);  
   function getshortcut: shortcutty;
   function getshortcut1: shortcutty;
   procedure setshortcut1(const avalue: shortcutty);
   procedure setonexecute(const avalue: notifyeventty);
   procedure setoptions(const avalue: menuactionoptionsty);
   function istagstored: Boolean;
   procedure settag(const avalue: integer);
   function isgroupstored: Boolean;
   procedure setgroup(const avalue: integer);
   function getchecked: boolean;
   procedure setchecked(const avalue: boolean);
   function getenabled: boolean;
   procedure setenabled(const avalue: boolean);
   function getvisible: boolean;
   procedure setvisible(const avalue: boolean);
   function getimagelist: timagelist;
   procedure setimagelist(const avalue: timagelist);
   function isimageliststored: boolean;
   procedure setimagenr(const avalue: imagenrty);
   function isimagenrstored: boolean;
   procedure setimagenrdisabled(const avalue: imagenrty);
   function isimagenrdisabledstored: boolean;
   procedure setcolor(const avalue: colorty);
   function iscolorstored: boolean;
   procedure setcolorglyph(const avalue: colorty);
   function iscolorglyphstored: boolean;

   function getfont: tmenufont;
   function getfontactive: tmenufontactive;
   procedure setfont(const avalue: tmenufont);
   procedure setfontactive(const avalue: tmenufontactive);
   function isfontstored: boolean;
   function isfontactivestored: boolean;
   procedure dofontchanged(const sender: tobject);
   procedure sethint(const avalue: msestring);
   function ishintstored: boolean;
   procedure setcoloractive(const avalue: colorty);
   function getcheckedtag: integer;
   procedure setcheckedtag(const avalue: integer);
   procedure readshortcut(reader: treader);
   procedure readshortcut1(reader: treader);
   procedure readsc(reader: treader);
   procedure writesc(writer: twriter);
   procedure readsc1(reader: treader);
   procedure writesc1(writer: twriter);
  protected
   finfo: actioninfoty;
   fowner: tcustommenu;
   fsubmenu: tmenuitems;
   procedure updatecaption;
   procedure defineproperties(filer: tfiler); override;

   //iactionlink
   function getactioninfopo: pactioninfoty;
   function loading: boolean;
   function shortcutseparator: msechar;
   procedure calccaptiontext(var ainfo: actioninfoty);
   
   procedure objectevent(const sender: tobject;
                                     const event: objecteventty); override;
   procedure receiveevent(const event: tobjectevent); override;
   function internalexecute(async: boolean): boolean;
   function canshowhint: boolean;
  public
   constructor create(const parentmenu: tmenuitem = nil;
                      const aowner: tcustommenu = nil); reintroduce;
   destructor destroy; override;
   procedure assign(source: tpersistent); override;
   procedure beginload;
   procedure endload;
   procedure doupdate;
   procedure doshortcut(var info: keyeventinfoty);
   function count: integer;
   function parentmenu: tmenuitem;
   function actualcolor: colorty;
   function actualcoloractive: colorty;
   property owner: tcustommenu read fowner; //can be nil
   function execute: boolean; //true if onexecute fired
   function asyncexecute: boolean;
   function canactivate: boolean;
   function canshow: boolean;
   procedure createfont;
   procedure createfontactive;
   property onchange: menuitemeventty read fonchange write fonchange;
   property items[const index: integer]: tmenuitem read getitems
                         write setitems; default;
   function itembyname(const name: string): tmenuitem;
   function itembynames(const names: array of string): tmenuitem;
   procedure deleteitembynames(const names: array of string);
   function index: integer; //-1 if no parent menu
   property checkedtag: integer read getcheckedtag write setcheckedtag;
                             //-1 if none checked
   property checked: boolean read getchecked write setchecked;
   property enabled: boolean read getenabled write setenabled;
   property visible: boolean read getvisible write setvisible;
   property tagpointer: pointer read finfo.tagpointer write finfo.tagpointer;
   property shortcuts: shortcutarty read finfo.shortcut write setshortcuts;
   property shortcuts1: shortcutarty read finfo.shortcut1 write setshortcuts1;
  published
   property action: tcustomaction read finfo.action write setaction;
   property submenu: tmenuitems read getsubmenu write setsubmenu;
   property caption: captionty read finfo.captiontext write setcaption
                     stored iscaptionstored;
   property hint: msestring read finfo.hint write sethint stored ishintstored;
   property name: string read fname write fname;
   property state: actionstatesty read finfo.state write setstate 
                     stored isstatestored default [];
   property options: menuactionoptionsty read finfo.options 
                   write setoptions default defaultmenuactoptions;
   property shortcut: shortcutty read getshortcut write setshortcut 
                     stored false default 0;
   property shortcut1: shortcutty read getshortcut1 write setshortcut1 
                     stored false default 0;
   property tag: integer read finfo.tag write settag stored istagstored default 0;
   property group: integer read finfo.group write setgroup 
                     stored isgroupstored default 0;
   property imagelist: timagelist read getimagelist write setimagelist
                     stored isimageliststored;
   property imagenr: imagenrty read finfo.imagenr write setimagenr
                            stored isimagenrstored default -1;
   property imagenrdisabled: imagenrty read finfo.imagenrdisabled 
                            write setimagenrdisabled
                            stored isimagenrdisabledstored default -2;
   property color: colorty read finfo.color write setcolor 
                          stored iscolorstored default cl_default;
   property colorglyph: colorty read finfo.colorglyph write setcolorglyph 
                          stored iscolorglyphstored default cl_default;
                                //cl_default maps to cl_glyph
   property coloractive: colorty read fcoloractive write setcoloractive 
                          default cl_parent;
   property font: tmenufont read getfont write setfont stored isfontstored;
   property fontactive: tmenufontactive read getfontactive write setfontactive
                            stored isfontactivestored;
   property onexecute: notifyeventty read finfo.onexecute
                     write setonexecute stored isonexecutestored;
 end;

 pmenuitem = ^tmenuitem;

 menueventty = procedure(const sender: tcustommenu) of object;

 tmenuframetemplate = class(tframetemplate)
  public
   constructor create(const owner: tmsecomponent; const onchange: notifyeventty);
           override;
  published
   property levelo default 1;
 end;

 menutemplatety = record
  frame: tframecomp;
  face: tfacecomp;
  itemframe: tframecomp;
  itemface: tfacecomp;
  itemframeactive: tframecomp;
  itemfaceactive: tfacecomp;
 end;

 tcustommenu = class(tmsecomponent)
  private
   fmenu: tmenuitem;
   fonupdate: menueventty;
   ftransient: boolean;
   fexecitem: tmenuitem;
   foptions: menuoptionsty;
   ftemplate: menutemplatety;
   procedure setmenu(const Value: tmenuitem);
   procedure setframetemplate(const avalue: tframecomp);
   procedure setfacetemplate(const avalue: tfacecomp);
   procedure setitemframetemplate(const avalue: tframecomp);
   procedure setitemfacetemplate(const avalue: tfacecomp);
   procedure setitemframetemplateactive(const avalue: tframecomp);
   procedure setitemfacetemplateactive(const avalue: tfacecomp);
   procedure setoptions(const avalue: menuoptionsty);
  protected
   ftransientfor: twidget;
   fmouseinfopo: pmouseeventinfoty;
   procedure doidle(var again: boolean);
   procedure readstate(reader: treader); override;
   procedure loaded; override;
   procedure setexecitem(const avalue: tmenuitem);
   property execitem: tmenuitem write setexecitem;
   procedure assigntemplate(const source: tcustommenu);
   procedure objectevent(const sender: tobject; const event: objecteventty); override;
   function gettemplatefont(const sender: tmenuitem): tmenufont; virtual;
   function gettemplatefontactive(
                       const sender: tmenuitem): tmenufontactive; virtual;
  public
   constructor create(aowner: tcomponent); overload; override;
   constructor createtransient(const atransientfor: twidget;
                  const amouseinfopo: pmouseeventinfoty); overload;
   destructor destroy; override;
   function checkexec: boolean;
   procedure assign(source: tpersistent); override;
   procedure doshortcut(var info: keyeventinfoty);
   procedure doupdate;
   function count: integer;
   function transientfor: twidget;
   function mouseinfopo: pmouseeventinfoty;
   function shortcutseparator: msechar;
   class function getshortcutseparator(const ainstance: tcustommenu): msechar;
   property menu: tmenuitem read fmenu write setmenu;
   property frametemplate: tframecomp read ftemplate.frame write setframetemplate;
   property facetemplate: tfacecomp read ftemplate.face write setfacetemplate;
   property itemframetemplate: tframecomp read ftemplate.itemframe 
                            write setitemframetemplate;
   property itemfacetemplate: tfacecomp read ftemplate.itemface 
                            write setitemfacetemplate;
   property itemframetemplateactive: tframecomp read ftemplate.itemframeactive 
                            write setitemframetemplateactive;
   property itemfacetemplateactive: tfacecomp read ftemplate.itemfaceactive 
                            write setitemfacetemplateactive;
   property template: menutemplatety read ftemplate;
   property options: menuoptionsty read foptions write setoptions 
                                                default defaultmenuoptions;
   property onupdate: menueventty read fonupdate write fonupdate;
 end;

 tmenu = class(tcustommenu)
  published
   property options;
   property onupdate;
   property frametemplate;
   property facetemplate;
   property itemframetemplate;
   property itemfacetemplate;
   property itemframetemplateactive;
   property itemfacetemplateactive;
   property menu; //last
 end;

 tpopupmenu = class(tmenu)
  private
   protected
    class function classskininfo: skininfoty; override;
  public
   function show(const atransientfor: twidget;
         const pos: graphicdirectionty): tmenuitem; overload;
   function show(const atransientfor: twidget;
           var mouseinfo: mouseeventinfoty): tmenuitem; overload;
                            //returns selected item, nil if none
   class procedure additems(var amenu: tpopupmenu; const atransientfor: twidget;
                 var mouseinfo: mouseeventinfoty;
                 const captions: array of msestring;
                            //if index > count -> index:= count
                 const aoptions: array of menuactionoptionsty;
                 const states: array of actionstatesty;
                 const onexecutes: array of notifyeventty;
                 const aseparator: boolean = true); overload;
   class procedure additems(var amenu: tpopupmenu; const atransientfor: twidget;
                 var mouseinfo: mouseeventinfoty; const items: tmenuitems;
                 const aseparator: boolean = true;
                 const first: boolean = false); overload;
   class procedure additems(var amenu: tpopupmenu; const atransientfor: twidget;
                 var mouseinfo: mouseeventinfoty; const items: tcustommenu;
                 const aseparator: boolean = true); overload;
 end;

 tcustommainmenu = class(tcustommenu)
  private
   fpopuptemplate: menutemplatety;
   procedure setpopupframetemplate(const avalue: tframecomp);
   procedure setpopupfacetemplate(const avalue: tfacecomp);
   procedure setpopupitemframetemplate(const avalue: tframecomp);
   procedure setpopupitemfacetemplate(const avalue: tfacecomp);
   procedure setpopupitemframetemplateactive(const avalue: tframecomp);
   procedure setpopupitemfacetemplateactive(const avalue: tfacecomp);
  protected
   class function classskininfo: skininfoty; override;
   procedure menuchanged(const sender: tmenuitem);
   function gettemplatefont(const sender: tmenuitem): tmenufont; override;
   function gettemplatefontactive(
                       const sender: tmenuitem): tmenufontactive; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property popuptemplate: menutemplatety read fpopuptemplate;
  published
   property options default defaultmainmenuoptions;
   property popupframetemplate: tframecomp read fpopuptemplate.frame
                      write setpopupframetemplate;
   property popupfacetemplate: tfacecomp read fpopuptemplate.face
                      write setpopupfacetemplate;
   property popupitemframetemplate: tframecomp read fpopuptemplate.itemframe
                      write setpopupitemframetemplate;
   property popupitemfacetemplate: tfacecomp read fpopuptemplate.itemface
                      write setpopupitemfacetemplate;
   property popupitemframetemplateactive: tframecomp read fpopuptemplate.itemframeactive
                      write setpopupitemframetemplateactive;
   property popupitemfacetemplateactive: tfacecomp read fpopuptemplate.itemfaceactive
                      write setpopupitemfacetemplateactive;
 end;
 
 tmainmenu = class(tcustommainmenu)
  published
   property options;
   property onupdate;
   property frametemplate;
   property facetemplate;
   property itemframetemplate;
   property itemfacetemplate;
   property itemframetemplateactive;
   property itemfacetemplateactive;

   property popupframetemplate;
   property popupfacetemplate;
   property popupitemframetemplate;
   property popupitemfacetemplate;
   property popupitemframetemplateactive;
   property popupitemfacetemplateactive;
   property menu; //last
 end;

 twidgetmainmenu = class(tcustommainmenu)
  published
   property options;
   property onupdate;
//   property frametemplate;
//   property facetemplate;
   property itemframetemplate;
   property itemfacetemplate;
   property itemframetemplateactive;
   property itemfacetemplateactive;

   property popupframetemplate;
   property popupfacetemplate;
   property popupitemframetemplate;
   property popupitemfacetemplate;
   property popupitemframetemplateactive;
   property popupitemfacetemplateactive;
   property menu; //last
 end; 
procedure freetransientmenu(var amenu: tcustommenu);

implementation
uses
 sysutils,msestockobjects,rtlconsts,msebits,msemenuwidgets,msedatalist,
 mseactions,msestreaming;

procedure freetransientmenu(var amenu: tcustommenu); 
begin
 if (amenu <> nil) and amenu.ftransient then begin
  freeandnil(amenu);
 end;
end;

{ tmenuframetemplate }

constructor tmenuframetemplate.create(const owner: tmsecomponent;
                   const onchange: notifyeventty);
begin
 inherited;
 fi.ba.levelo:= 1;
end;

{ tcustommenu }

constructor tcustommenu.create(aowner: tcomponent);
begin
 foptions:= defaultmenuoptions;
 inherited;
// include(fmsecomponentstate,cs_hasskin);
 fmenu:= tmenuitem.create(nil,self);
end;

constructor tcustommenu.createtransient(const atransientfor: twidget;
                        const amouseinfopo: pmouseeventinfoty);
begin
 create(nil);
 ftransient:= true;
 ftransientfor:= atransientfor;
 fmouseinfopo:= amouseinfopo;
 updateskin;
end;

destructor tcustommenu.destroy;
begin
 if mo_updateonidle in foptions then begin
  application.unregisteronidle({$ifdef FPC}@{$endif}doidle); 
 end;
 fmenu.Free;
 inherited;
end;

function tcustommenu.count: integer;
begin
 result:= fmenu.count;
end;

procedure tcustommenu.setmenu(const Value: tmenuitem);
begin
 fmenu.assign(Value);
end;

procedure tcustommenu.doidle(var again: boolean);
begin
 doupdate;
end;

procedure tcustommenu.readstate(reader: treader);
begin
 fmenu.beginload;
 inherited;
end;

procedure tcustommenu.loaded;
begin
 fmenu.endload;
 inherited;
 updateskin;
end;

procedure tcustommenu.setexecitem(const avalue: tmenuitem);
begin
 fexecitem:= avalue;
end;

function tcustommenu.checkexec: boolean;
begin
 result:= fexecitem <> nil;
 if result then begin
  doactionexecute(fexecitem,fexecitem.finfo,true,
         mao_nocandefocus in fexecitem.options);
 end;
// if result and canevent(tmethod(fexecitem.onexecute)) then begin
//  fexecitem.onexecute(fexecitem);
// end;
 fexecitem:= nil;
end;

procedure tcustommenu.doupdate;
begin
 fexecitem:= nil;
 fmenu.doupdate;
 if canevent(tmethod(fonupdate)) then begin
  fonupdate(self);
 end;
end;

procedure tcustommenu.doshortcut(var info: keyeventinfoty);
begin
 fmenu.doshortcut(info);
end;

procedure tcustommenu.assign(source: tpersistent);
begin
 if source is tcustommenu then begin
  with tcustommenu(source) do begin
   self.onupdate:= onupdate;
   self.foptions:= options;
   self.fmenu.Assign(fmenu);
  end;
 end
 else begin
  inherited;
 end;
end;

function tcustommenu.transientfor: twidget;
begin
 result:= ftransientfor;
end;

function tcustommenu.mouseinfopo: pmouseeventinfoty;
begin
 result:= fmouseinfopo;
end;

function tcustommenu.shortcutseparator: msechar;
begin
 if mo_shortcutright in foptions then begin
  result:= c_tab;
 end
 else begin
  result:= ' ';
 end;
end;

class function tcustommenu.getshortcutseparator(
                       const ainstance: tcustommenu): msechar;
begin
 if ainstance = nil then begin
  result:= c_tab;
 end
 else begin
  result:= ainstance.shortcutseparator;
 end;
end;

procedure tcustommenu.setframetemplate(const avalue: tframecomp);
begin
 if avalue <> ftemplate.frame then begin
  setlinkedvar(avalue,tmsecomponent(ftemplate.frame));
  sendchangeevent;
 end;
end;

procedure tcustommenu.setfacetemplate(const avalue: tfacecomp);
begin
 if avalue <> ftemplate.face then begin
  setlinkedvar(avalue,tmsecomponent(ftemplate.face));
  sendchangeevent;
 end;
end;

procedure tcustommenu.setitemframetemplate(const avalue: tframecomp);
begin
 if avalue <> ftemplate.itemframe then begin
  setlinkedvar(avalue,tmsecomponent(ftemplate.itemframe));
  sendchangeevent;
 end;
end;

procedure tcustommenu.setitemfacetemplate(const avalue: tfacecomp);
begin
 if avalue <> ftemplate.itemface then begin
  setlinkedvar(avalue,tmsecomponent(ftemplate.itemface));
  sendchangeevent;
 end;
end;

procedure tcustommenu.setitemframetemplateactive(const avalue: tframecomp);
begin
 if avalue <> ftemplate.itemframeactive then begin
  setlinkedvar(avalue,tmsecomponent(ftemplate.itemframeactive));
  sendchangeevent;
 end;
end;

procedure tcustommenu.setitemfacetemplateactive(const avalue: tfacecomp);
begin
 if avalue <> ftemplate.itemfaceactive then begin
  setlinkedvar(avalue,tmsecomponent(ftemplate.itemfaceactive));
  sendchangeevent;
 end;
end;
{
procedure tcustommenu.templatechanged(const sender: tobject);
begin
 sendchangeevent;
end;
}
procedure tcustommenu.objectevent(const sender: tobject; const event: objecteventty);
begin
 case event of
  oe_changed,oe_destroyed: begin
   if (sender = ftemplate.face) or (sender = ftemplate.frame) or 
      (sender = ftemplate.itemface) or (sender = ftemplate.itemframe) or 
      (sender = ftemplate.itemfaceactive) or 
      (sender = ftemplate.itemframeactive) then begin
    if event = oe_destroyed then begin
     if sender = ftemplate.face then begin
      ftemplate.face:= nil;
     end;
     if sender = ftemplate.frame then begin
      ftemplate.frame:= nil;
     end;
     if sender = ftemplate.itemface then begin
      ftemplate.itemface:= nil;
     end;
     if sender = ftemplate.itemframe then begin
      ftemplate.itemframe:= nil;
     end;
     if sender = ftemplate.itemframeactive then begin
      ftemplate.itemframeactive:= nil;
     end;
    end;
    sendchangeevent;
   end;
  end;
 end;
 inherited;
end;

procedure tcustommenu.assigntemplate(const source: tcustommenu);
begin
 ftemplate:= source.ftemplate;
end;

procedure tcustommenu.setoptions(const avalue: menuoptionsty);
var
 optionsbefore,delta: menuoptionsty;
begin
 if avalue <> foptions then begin
  optionsbefore:= foptions;
  foptions:= avalue;
  delta:= menuoptionsty(longword(optionsbefore) xor longword(foptions));
  if not (csreading in componentstate) and 
       (mo_shortcutright in delta) then begin
   fmenu.updatecaption;
  end;
  if mo_updateonidle in delta then begin
   if mo_updateonidle in foptions then begin
    application.registeronidle({$ifdef FPC}@{$endif}doidle); 
   end
   else begin
    application.unregisteronidle({$ifdef FPC}@{$endif}doidle); 
   end;
  end;
  sendchangeevent;
 end;
end;

function tcustommenu.gettemplatefont(const sender: tmenuitem): tmenufont;
begin
 result:= nil;
 if itemframetemplate <> nil then begin
  result:= tmenufont(itemframetemplate.template.font);
 end;
 if result = nil then begin
  result:= tmenufont(pointer(stockobjects.fonts[stf_menu]));
 end;
end;

function tcustommenu.gettemplatefontactive(
                             const sender: tmenuitem): tmenufontactive;
begin
 result:= nil;
 if itemframetemplateactive <> nil then begin
  result:= tmenufontactive(pointer(itemframetemplateactive.template.font));
 end;
end;

{ tmenufont }

class function tmenufont.getinstancepo(owner: tobject): pfont;
begin
 result:= @(tmenuitem(owner).ffont);
end;

{ tmenufontactive }

class function tmenufontactive.getinstancepo(owner: tobject): pfont;
begin
 result:= @(tmenuitem(owner).ffontactive);
end;

{ tmenuitem }

constructor tmenuitem.create(const parentmenu: tmenuitem = nil;
                              const aowner: tcustommenu = nil);
begin
 fparentmenu:= parentmenu;
 if fparentmenu <> nil then begin
  fowner:= fparentmenu.fowner;
 end
 else begin
  fowner:= aowner;
 end;
 initactioninfo(finfo,defaultmenuactoptions);
 finfo.color:= cl_default;
 finfo.colorglyph:= cl_default;
 fcoloractive:= cl_parent;
 inherited create;
end;

destructor tmenuitem.destroy;
begin
// if fsubmenu <> nil then begin
//  fsubmenu.count:= 0;
// end;
 fsubmenu.free;
 if (fowner = nil) or not fowner.ftransient then begin
  ffont.free;
  ffontactive.free;
 end;
 inherited destroy;
end;

function tmenuitem.count: integer;
begin
 if fsubmenu = nil then begin
  result:= 0;
 end
 else begin
  result:= fsubmenu.count;
 end;
end;

function tmenuitem.getsubmenu: tmenuitems;
begin
 if fsubmenu = nil then begin
  fsubmenu:= tmenuitems.create(self);
 end;
 result:= fsubmenu;
end;

procedure tmenuitem.setsubmenu(const Value: tmenuitems);
begin
 if value = nil then begin
  freeandnil(fsubmenu);
 end
 else begin
  getsubmenu.Assign(value);
 end;
end;

function tmenuitem.parentmenu: tmenuitem;
begin
 result:= fparentmenu;
end;

procedure tmenuitem.setcaption(const Value: msestring);
begin
 setactioncaption(iactionlink(self),value);
end;

function tmenuitem.iscaptionstored: Boolean;
begin
 result:= isactioncaptionstored(finfo);
end;

procedure tmenuitem.sethint(const avalue: msestring);
begin
 setactionhint(iactionlink(self),avalue);
end;

function tmenuitem.ishintstored: boolean;
begin
 result:= isactionhintstored(finfo);
end;

procedure tmenuitem.setstate(const avalue: actionstatesty);
begin
 setactionstate(iactionlink(self),avalue);
end;

function tmenuitem.isstatestored: Boolean;
begin
 result:= isactionstatestored(finfo);
end;

function tmenuitem.isshortcutstored: Boolean;
begin
 result:= isactionshortcutstored(finfo);
end;

procedure tmenuitem.setshortcut(const avalue: shortcutty);
begin
 setactionshortcut(iactionlink(self),avalue);
end;

function tmenuitem.isshortcut1stored: Boolean;
begin
 result:= isactionshortcut1stored(finfo);
end;

function tmenuitem.getshortcut: shortcutty;
begin
 result:= getsimpleshortcut(finfo);
end;

function tmenuitem.getshortcut1: shortcutty;
begin
 result:= getsimpleshortcut1(finfo);
end;

procedure tmenuitem.setshortcuts(const avalue: shortcutarty);
begin
 setactionshortcuts(iactionlink(self),avalue);
end;

procedure tmenuitem.setshortcuts1(const avalue: shortcutarty);  
begin
 setactionshortcuts1(iactionlink(self),avalue);
end;

procedure tmenuitem.setshortcut1(const avalue: shortcutty);
begin
 setactionshortcut1(iactionlink(self),avalue);
end;

function tmenuitem.istagstored: Boolean;
begin
 result:= isactiontagstored(finfo);
end;

procedure tmenuitem.settag(const avalue: integer);
begin
 setactiontag(iactionlink(self),avalue);
end;

function tmenuitem.isgroupstored: Boolean;
begin
 result:= isactiongroupstored(finfo);
end;

procedure tmenuitem.setgroup(const avalue: integer);
begin
 setactiongroup(iactionlink(self),avalue);
end;

procedure tmenuitem.setoptions(const avalue: menuactionoptionsty);
begin
 setactionoptions(iactionlink(self),avalue);
end;

procedure tmenuitem.setonexecute(const avalue: notifyeventty);
begin
 setactiononexecute(iactionlink(self),avalue,
                (fowner <> nil) and (csloading in fowner.componentstate));
end;

function tmenuitem.isonexecutestored: Boolean;
begin
 result:= isactiononexecutestored(finfo);
end;

procedure tmenuitem.setcoloractive(const avalue: colorty);
begin
 if avalue <> fcoloractive then begin
  fcoloractive:= avalue;
  actionchanged;
 end;
end;

procedure tmenuitem.actionchanged;
const
 mask: actionstatesty = [as_checked];
var
 state1: actionstatesty;
begin
 if assigned(fonchange) then begin
  fonchange(self);
 end;
 if (fparentmenu <> nil) and assigned(fparentmenu.fonchange) then begin
  fparentmenu.fonchange(self);
 end;
 if ([mao_checkbox,mao_radiobutton] * finfo.options <> []) and
         (fsource <> nil) and (fowner <> nil) and (fowner.ftransient) then begin
  state1:= fsource.getstate;
  state1:= actionstatesty(
          replacebits(longword(state),longword(state1),longword(mask)));
  fsource.setstate(state1);  
 end;
end;

function tmenuitem.getitems(const index: integer): tmenuitem;
begin
 checksubmenu;
 result:= fsubmenu.items[index];
end;

procedure tmenuitem.setitems(const index: integer; const Value: tmenuitem);
begin
 checksubmenu;
 fsubmenu.items[index]:= value;
end;

function tmenuitem.itembyname(const name: string): tmenuitem;
begin
 if fsubmenu = nil then begin
  result:= nil;
 end
 else begin
  result:= fsubmenu.itembyname(name);
 end;
end;

function tmenuitem.itembynames(const names: array of string): tmenuitem;
var
 int1: integer;
 sub1: tmenuitems;
begin
 result:= self;
 for int1:= 0 to high(names) do begin
  sub1:= result.fsubmenu;
  if sub1 = nil then begin
   break;
  end;
  result:= sub1.itembyname(names[int1]);
  if result = nil then begin
   break;
  end;
 end;
end;

procedure tmenuitem.deleteitembynames(const names: array of string);
var
 item1: tmenuitem;
begin
 item1:= itembynames(names);
 if item1 <> nil then begin
  item1.fparentmenu.submenu.delete(item1.index);
 end;
end;

function tmenuitem.index: integer; //-1 if no parent menu
begin
 if fparentmenu = nil then begin
  result:= -1;
 end
 else begin
  result:= fparentmenu.fsubmenu.indexof(self);
 end;
end;

procedure tmenuitem.checksubmenu;
begin
 if fsubmenu = nil then begin
  tlist.Error({$ifndef FPC}@{$endif}SListIndexError, 0);
 end;
end;

function tmenuitem.internalexecute(async: boolean): boolean;
begin
 if [mao_checkbox,mao_radiobutton] * finfo.options <> [] then begin
  if mao_checkbox in finfo.options then begin
   checked:= not checked;
  end
  else begin
   checked:= true;
  end;
 end;
 result:= canactivate {and assigned(finfo.onexecute)};
 if result then begin
  if async then begin
   doactionexecute(self,finfo,true);
//   finfo.onexecute(self);
  end
  else begin
   fowner.execitem:= self;
  end;
 end;
end;

function tmenuitem.execute: boolean;
begin
 result:= internalexecute(false);
end;

function tmenuitem.asyncexecute: boolean;
begin
 result:= canactivate {and assigned(finfo.onexecute)};
 if result then begin
  if fsource <> nil then begin
   application.postevent(tobjectevent.create(ek_execute,fsource));
  end
  else begin
   application.postevent(tobjectevent.create(ek_execute,ievent(self)));
  end;
 end;
end;

procedure tmenuitem.receiveevent(const event: tobjectevent);
begin
 if event.kind = ek_execute then begin
  internalexecute(true);
 end;
end;

procedure tmenuitem.setaction(const avalue: tcustomaction);
begin
 linktoaction(iactionlink(self),avalue,finfo);
end;

function tmenuitem.getactioninfopo: pactioninfoty;
begin
 result:= @finfo;
end;

function tmenuitem.loading: boolean;
begin
 result:= (fowner <> nil) and (csloading in fowner.componentstate);
end;

function tmenuitem.shortcutseparator: msechar;
begin
 if fowner <> nil then begin
  result:= fowner.shortcutseparator;
 end
 else begin
  result:= c_tab;
 end;
end;

procedure tmenuitem.calccaptiontext(var ainfo: actioninfoty);
begin
 mseactions.calccaptiontext(ainfo,shortcutseparator);
end;

procedure tmenuitem.beginload;
var
 int1: integer;
begin
 actionbeginload(iactionlink(self));
 for int1:= 0 to count - 1 do begin
  items[int1].beginload;
 end;
end;

procedure tmenuitem.endload;
var
 int1: integer;
begin
 actionendload(iactionlink(self));
 for int1:= 0 to count - 1 do begin
  items[int1].endload;
 end;
end;

procedure tmenuitem.doupdate;
var
 int1: integer;
begin
 for int1:= 0 to count - 1 do begin
  items[int1].doupdate;
 end;
 if finfo.action <> nil then begin
  finfo.action.doupdate;
 end;
end;

function tmenuitem.canactivate: boolean;
begin
 result:= (finfo.state * [as_disabled,as_invisible] = []) and
                (finfo.options * [mao_separator] = []);
end;

function tmenuitem.canshow: boolean;
var
 int1: integer;
begin
 result:= false;
 if fsubmenu <> nil then begin
  for int1:= 0 to fsubmenu.count - 1 do begin
   if not (as_invisible in  fsubmenu[int1].finfo.state) then begin
    result:= true;
    break;
   end;
  end;
 end;
end;

procedure tmenuitem.doshortcut(var info: keyeventinfoty);
var
 int1: integer;
begin
 if doactionshortcut(self,finfo,info) then begin
  actionchanged;
 end
 else begin
  for int1:= 0 to count -1 do begin
   if (es_processed in info.eventstate) then begin
    break;
   end;
   fsubmenu[int1].doshortcut(info);
  end;
 end;
end;

procedure tmenuitem.assign(source: tpersistent);
var
 action1: tcustomaction;
begin
 if source is tmenuitem then begin
  fsource:= imenuitem(tmenuitem(source));
  action1:= finfo.action;
  with tmenuitem(source) do begin
   self.finfo:= finfo;
   self.finfo.action:= action1;
   self.action:= finfo.action;
   self.submenu:= fsubmenu;
   self.fcoloractive:= fcoloractive;
   if self.fowner.ftransient then begin
    self.ffont:= font;
    self.ffontactive:= fontactive;
   end
   else begin
    self.font:= font;
    self.fontactive:= fontactive;
   end;
  end;
 end;
end;

function tmenuitem.getchecked: boolean;
begin
 result:= as_checked in finfo.state;
end;

procedure tmenuitem.setchecked(const avalue: boolean);
var
 bo1: boolean;
 int1: integer;
 item1: tmenuitem;
begin
 bo1:= as_checked in finfo.state;
 if bo1 <> avalue then begin
  if avalue and (mao_radiobutton in finfo.options) and (fparentmenu <> nil) then begin
   for int1:= 0 to fparentmenu.count-1 do begin
    item1:= fparentmenu[int1];
    with item1 do begin
     if (finfo.options * [{mao_checkbox,}mao_radiobutton] = [{mao_checkbox,}mao_radiobutton]) and
             (finfo.group = self.finfo.group) then begin
      setactionchecked(iactionlink(item1),false);
     end;
    end;
   end;
  end;
  setactionchecked(iactionlink(self),avalue);
 end;
end;

function tmenuitem.getenabled: boolean;
begin
 result:= not (as_disabled in finfo.state);
end;

procedure tmenuitem.setenabled(const avalue: boolean);
begin
 if avalue then begin
  state:= state - [as_disabled];
 end
 else begin
  state:= state + [as_disabled];
 end;
end;

function tmenuitem.getvisible: boolean;
begin
 result:= not (as_invisible in finfo.state);
end;

procedure tmenuitem.setvisible(const avalue: boolean);
begin
 if avalue then begin
  state:= state - [as_invisible];
 end
 else begin
  state:= state + [as_invisible];
 end;
end;

function tmenuitem.getimagelist: timagelist;
begin
 result:= timagelist(finfo.imagelist);
end;

procedure tmenuitem.setimagelist(const avalue: timagelist);
begin
 setactionimagelist(iactionlink(self),avalue);
end;

function tmenuitem.isimageliststored: Boolean;
begin
 result:= isactionimageliststored(finfo);
end;

procedure tmenuitem.setimagenr(const avalue: imagenrty);
begin
 setactionimagenr(iactionlink(self),avalue);
end;

function tmenuitem.isimagenrstored: Boolean;
begin
 result:= isactionimagenrstored(finfo);
end;

procedure tmenuitem.setimagenrdisabled(const avalue: imagenrty);
begin
 setactionimagenrdisabled(iactionlink(self),avalue);
end;

function tmenuitem.isimagenrdisabledstored: Boolean;
begin
 result:= isactionimagenrdisabledstored(finfo);
end;

procedure tmenuitem.setcolor(const avalue: colorty);
begin
 setactioncolor(iactionlink(self),avalue);
end;

function tmenuitem.iscolorstored: Boolean;
begin
 result:= isactioncolorstored(finfo);
end;

procedure tmenuitem.setcolorglyph(const avalue: colorty);
begin
 setactioncolorglyph(iactionlink(self),avalue);
end;

function tmenuitem.iscolorglyphstored: Boolean;
begin
 result:= isactioncolorglyphstored(finfo);
end;

function tmenuitem.isfontstored: boolean;
begin
 result:= ffont <> nil;
end;

function tmenuitem.isfontactivestored: boolean;
begin
 result:= ffontactive <> nil;
end;

procedure tmenuitem.dofontchanged(const sender: tobject);
begin
 actionchanged;
end;

procedure tmenuitem.createfont;
begin
 if ffont = nil then begin
  ffont:= tmenufont.create;
  ffont.onchange:= {$ifdef FPC}@{$endif}dofontchanged;
 end;
end;

procedure tmenuitem.createfontactive;
begin
 if ffontactive = nil then begin
  ffontactive:= tmenufontactive.create;
  ffontactive.onchange:= {$ifdef FPC}@{$endif}dofontchanged;
 end;
end;

function tmenuitem.getfont: tmenufont;
begin
 getoptionalobject(fowner,ffont,{$ifdef FPC}@{$endif}createfont);
 if ffont <> nil then begin
  result:= ffont;
 end
 else begin
  result:= nil;
  if (fowner <> nil) then begin
   result:= fowner.gettemplatefont(self);
  end;
  if (result = nil) then begin
   if fparentmenu <> nil then begin
    result:= fparentmenu.getfont;
   end
   else begin
    result:= tmenufont(pointer(stockobjects.fonts[stf_menu]));
   end;
  end;
 end;
end;

function tmenuitem.getfontactive: tmenufontactive;
begin
 getoptionalobject(fowner,ffontactive,
            {$ifdef FPC}@{$endif}createfontactive);
 if ffontactive <> nil then begin
  result:= ffontactive;
 end
 else begin
  result:= nil;
  if (fowner <> nil) then begin
   result:= fowner.gettemplatefontactive(self);
  end;
  if result = nil then begin
   result:= tmenufontactive(pointer(ffont));
   if result = nil then begin
    if fparentmenu <> nil then begin
     result:= fparentmenu.getfontactive;
    end
    else begin
     result:= tmenufontactive(pointer(stockobjects.fonts[stf_menu]));
    end;
   end;
  end;
 end;
end;

procedure tmenuitem.setfont(const avalue: tmenufont);
begin
 if avalue <> ffont then begin
  setoptionalobject(fowner,avalue,ffont,
                {$ifdef FPC}@{$endif}createfont);
  actionchanged;
 end;
end;

procedure tmenuitem.setfontactive(const avalue: tmenufontactive);
begin
 if avalue <> ffontactive then begin
  setoptionalobject(fowner,avalue,ffontactive,
               {$ifdef FPC}@{$endif}createfontactive);
  actionchanged;
 end;
end;

procedure tmenuitem.objectevent(const sender: tobject;
               const event: objecteventty);
begin
 inherited;
 if (event = oe_changed) and (sender = finfo.imagelist) then begin
  actionchanged;
 end;
end;

function tmenuitem.canshowhint: boolean;
var
 item1: tmenuitem;
begin
 result:= false;
 if finfo.hint <> '' then begin
  item1:= self;
  while item1 <> nil do begin
   result:= mao_showhint in item1.options;
   if item1.options * [mao_showhint,mao_noshowhint] <> []then begin
    break;
   end;
   item1:= item1.fparentmenu;
  end;
 end;
end;

procedure tmenuitem.readshortcut(reader: treader);
begin
 shortcut:= translateshortcut(reader.readinteger);
end;

procedure tmenuitem.readshortcut1(reader: treader);
begin
 shortcut1:= translateshortcut(reader.readinteger);
end;

procedure tmenuitem.readsc(reader: treader);
begin
 shortcuts:= readshortcutarty(reader);
end;

procedure tmenuitem.writesc(writer: twriter);
begin
 writeshortcutarty(writer,finfo.shortcut);
end;

procedure tmenuitem.readsc1(reader: treader);
begin
 shortcuts1:= readshortcutarty(reader);
end;

procedure tmenuitem.writesc1(writer: twriter);
begin
 writeshortcutarty(writer,finfo.shortcut1);
end;

procedure tmenuitem.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('shortcut',{$ifdef FPC}@{$endif}readshortcut,nil,false);
 filer.defineproperty('shortcut1',{$ifdef FPC}@{$endif}readshortcut1,nil,false);
 filer.defineproperty('sc',{$ifdef FPC}@{$endif}readsc,
                           {$ifdef FPC}@{$endif}writesc,
       isactionshortcutstored(finfo) and
       ((filer.ancestor = nil) and (finfo.shortcut <> nil) or
       ((filer.ancestor <> nil) and 
         not issameshortcut(finfo.shortcut,
                  tmenuitem(filer.ancestor).shortcuts))));
 filer.defineproperty('sc1',{$ifdef FPC}@{$endif}readsc1,
                           {$ifdef FPC}@{$endif}writesc1,
       isactionshortcut1stored(finfo) and
       ((filer.ancestor = nil) and (finfo.shortcut1 <> nil) or
       ((filer.ancestor <> nil) and 
         not issameshortcut(finfo.shortcut,
                  tmenuitem(filer.ancestor).shortcuts))));
end;

procedure tmenuitem.updatecaption;
var
 int1: integer;
begin
 mseactions.calccaptiontext(finfo,shortcutseparator);
 for int1:= 0 to count - 1 do begin
  fsubmenu[int1].updatecaption;
 end;
end;

function tmenuitem.actualcolor: colorty;
begin
 result:= finfo.color;
 if (result = cl_default) or (result = cl_parent) then begin
  if fparentmenu = nil then begin
   result:= cl_transparent;
  end
  else begin
   result:= fparentmenu.actualcolor;
  end;
 end;
end;

function tmenuitem.actualcoloractive: colorty;
begin
 result:= fcoloractive;
 if (result = cl_default) or (result = cl_parent) then begin
  if fparentmenu = nil then begin
   result:= actualcolor;
  end
  else begin
   result:= fparentmenu.actualcoloractive;
  end;
 end
 else begin
  if result = cl_normal then begin
   result:= actualcolor;
  end;
 end;
end;

function tmenuitem.getstate: actionstatesty;
begin
 result:= finfo.state;
end;

function tmenuitem.getcheckedtag: integer;
var
 int1: integer;
begin
 result:= -1;
 if fparentmenu <> nil then begin
  with fparentmenu.fsubmenu do begin
   for int1:= 0 to high(fitems) do begin
    with tmenuitem(fitems[int1]) do begin
     if (mao_radiobutton in finfo.options) and (finfo.group = self.finfo.group) and 
                                                          checked then begin
      result:= finfo.tag;
      break;
     end;
    end;
   end;
  end;
 end;
end;

procedure tmenuitem.setcheckedtag(const avalue: integer);
var
 int1: integer;
begin
 if fparentmenu <> nil then begin
  with fparentmenu.fsubmenu do begin
   for int1:= 0 to high(fitems) do begin
    with tmenuitem(fitems[int1]) do begin
     if (mao_radiobutton in finfo.options) and 
                             (finfo.group = self.finfo.group) then begin
      if finfo.tag = avalue then begin
       checked:= true;
       break;
      end
      else begin
       checked:= false;
      end;
     end;
    end;
   end;
  end;
 end;
end;

{ tmenuitems }

constructor tmenuitems.create(const aowner: tmenuitem);
begin
 fowner:= aowner;
 inherited create(tmenuitem);
end;

class function tmenuitems.getitemclasstype: persistentclassty;
begin
 result:= tmenuitem;
end;

procedure tmenuitems.assign(source: tpersistent);
var
 int1: integer;
begin
 if source is tmenuitems then begin
  with tmenuitems(source) do begin
   self.count:= count;
   for int1:= 0 to count - 1 do begin
    self.setmenuitems(int1,getmenuitems(int1));
   end;
  end;
 end
 else begin
  inherited;
 end;
end;

procedure tmenuitems.createitem(const index: integer; var item: tpersistent);
begin
 item:= tmenuitem.create(fowner,fowner.fowner);
end;

procedure tmenuitems.receiveevent(const event: tobjectevent);
begin
 if event.kind = ek_release then begin
  destroy;
 end;
end;

procedure tmenuitems.dosizechanged;
begin
 inherited;
 { too dangerous because of runtime submenu clear in with statement.
 if count = 0 then begin
  tmenuitem(fowner).fsubmenu:= nil;
  fowner:= nil;
  application.postevent(tobjectevent.create(ek_release,ievent(self)));
 end;
 }
end;

procedure tmenuitems.dochange(const aindex: integer);
var
 int1: integer;
begin
 if aindex = -1 then begin
  for int1:= 0 to count - 1 do begin
   items[int1].actionchanged;
  end;
 end;
 if fowner <> nil then begin
  fowner.actionchanged;
 end;
 inherited;
end;

function tmenuitems.getmenuitems(index: integer): tmenuitem;
begin
 result:= tmenuitem(getitems(index));
end;

procedure tmenuitems.insert(const index: integer; const aitem: tmenuitem);
var
 int1: integer;
begin
 int1:= index;
 if index > count then begin
  int1:= count;
 end;
 beginupdate;
 try
  insertempty(int1);
  aitem.fparentmenu:= fowner;
  aitem.fowner:= fowner.fowner;
  fitems[int1]:= aitem;
 finally
  endupdate;
 end;
end;

procedure tmenuitems.insertseparator(const index: integer);
var
 item1: tmenuitem;
begin
 item1:= tmenuitem.create;
 item1.options:= item1.options + [mao_separator];
 insert(index,item1);
end;

procedure tmenuitems.insert(const index: integer; const aitems: tmenuitems);
var
 int1,int2: integer;
 item1: tmenuitem;
begin
 int1:= index;
 if index > count then begin
  int1:= count;
 end;
 beginupdate;
 try
  for int2:= 0 to aitems.count - 1 do begin
   item1:= tmenuitem.create;
   insert(int1,item1);
   item1.assign(aitems[int2]);
   inc(int1);
  end;
 finally
  endupdate;
 end;
end;

procedure tmenuitems.insert(const index: integer; const captions: array of msestring;
                            //if index > count -> index:= count
                 const options: array of menuactionoptionsty;
                 const states: array of actionstatesty;
                 const onexecutes: array of notifyeventty);
var
 int1,int2,int3: integer;
 item1: tmenuitem;
begin
 int1:= -1;
 if high(captions) > int1 then begin
  int1:= high(captions);
 end;
 if high(options) > int1 then begin
  int1:= high(options);
 end;
 if high(states) > int1 then begin
  int1:= high(states);
 end;
 if high(onexecutes) > int1 then begin
  int1:= high(onexecutes);
 end;
 if index > count then begin
  int3:= count;
 end
 else begin
  int3:= index;
 end;
 beginupdate;
 try
  for int2:= 0 to int1 do begin
   item1:= tmenuitem.create;
   if int2 <= high(captions) then begin
    item1.caption:= captions[int2];
   end;
   if int2 <= high(options) then begin
    item1.options:= options[int2];
   end;
   if int2 <= high(states) then begin
    item1.state:= states[int2];
   end;
   if int2 <= high(onexecutes) then begin
    item1.onexecute:= onexecutes[int2];
   end;
   insert(int3,item1);
   inc(int3);
  end;
 finally
  endupdate;
 end;
end;

procedure tmenuitems.setmenuitems(index: integer; const Value: tmenuitem);
begin
 tmenuitem(getitems(index)).assign(value);
end;

function tmenuitems.itemindexbyname(const name: ansistring): integer;
var
 int1: integer;
 po1: pmenuitem;
begin
 result:= -1;
 po1:= pointer(fitems);
 for int1:= 0 to high(fitems) do begin
  if (po1^.fname = name) or
          (po1^.finfo.action <> nil) and (po1^.finfo.action.Name = name) then begin
   result:= int1;
   break;
  end;
  inc(po1);
 end;
end;

function tmenuitems.itembyname(const name: ansistring): tmenuitem;
var
 int1: integer;
begin
 int1:= itemindexbyname(name);
 if int1 < 0 then begin
  result:= nil;
 end
 else begin
  result:= tmenuitem(fitems[int1]);
 end;
end;

{ tpopupmenu }

class function tpopupmenu.classskininfo: skininfoty;
begin
 result:= inherited classskininfo;
 result.objectkind:= sok_popupmenu;
end;

function tpopupmenu.show(const atransientfor: twidget;
         const pos: graphicdirectionty): tmenuitem;
begin
 ftransientfor:= atransientfor;
 try
  doupdate;
  result:= showpopupmenu(fmenu,ftransientfor,pos,self);
  checkexec;
 finally
  ftransientfor:= nil;
 end;
end;

function tpopupmenu.show(const atransientfor: twidget;
       var mouseinfo: mouseeventinfoty): tmenuitem;
begin
 ftransientfor:= atransientfor;
 fmouseinfopo:= @mouseinfo;
 try
  doupdate;
  result:= showpopupmenu(fmenu,ftransientfor,mouseinfo.pos,self);
  include(mouseinfo.eventstate,es_processed);
  checkexec;
 finally
  ftransientfor:= nil;
  fmouseinfopo:= nil;
 end;
end;

class procedure tpopupmenu.additems(var amenu: tpopupmenu;
                 const atransientfor: twidget;
                 var mouseinfo: mouseeventinfoty;
                 const captions: array of msestring;
                            //if index > count -> index:= count
                 const aoptions: array of menuactionoptionsty;
                 const states: array of actionstatesty;
                 const onexecutes: array of notifyeventty;
                 const aseparator: boolean = true);
begin
 if amenu = nil then begin
  amenu:= tpopupmenu.createtransient(atransientfor,@mouseinfo);
 end;
 if aseparator and (amenu.menu.submenu.count > 0) then begin
  amenu.menu.submenu.insertseparator(bigint);
 end;
 amenu.menu.submenu.insert(bigint,captions,aoptions,states,onexecutes);
end;

class procedure tpopupmenu.additems(var amenu: tpopupmenu; const atransientfor: twidget;
                 var mouseinfo: mouseeventinfoty; const items: tmenuitems;
                 const aseparator: boolean = true;
                 const first: boolean = false);
begin
 if amenu = nil then begin
  amenu:= tpopupmenu.createtransient(atransientfor,@mouseinfo);
 end;
 if items <> nil then begin
  if first then begin
   amenu.menu.submenu.insert(0,items);
   if aseparator and (items.count > 0) then begin
    amenu.menu.submenu.insertseparator(items.count);
   end;
  end
  else begin
   if aseparator and (amenu.menu.count > 0) then begin
    amenu.menu.submenu.insertseparator(bigint);
   end;
   amenu.menu.submenu.insert(bigint,items);
  end;
 end;
end;

class procedure tpopupmenu.additems(var amenu: tpopupmenu; const atransientfor: twidget;
                 var mouseinfo: mouseeventinfoty; const items: tcustommenu;
                 const aseparator: boolean = true);
var
 bo1: boolean;
 widget1: twidget;
begin
 items.fmouseinfopo:= @mouseinfo;
 widget1:= items.ftransientfor;
 items.ftransientfor:= atransientfor;
 try
  items.doupdate;
 finally
  items.ftransientfor:= widget1;
 end;
 bo1:= (amenu = nil) or amenu.ftransient;
 additems(amenu,atransientfor,mouseinfo,items.fmenu.fsubmenu,aseparator,
            mo_insertfirst in items.foptions);
 if bo1 then begin
  amenu.foptions:= items.foptions;
  amenu.assigntemplate(items);
  amenu.fmenu.ffont:= items.fmenu.ffont;
  amenu.fmenu.ffontactive:= items.fmenu.ffontactive;
  amenu.fmenu.color:= items.fmenu.color;
  amenu.fmenu.coloractive:= items.fmenu.coloractive;
 end;
end;

{ tcustommainmenu }

constructor tcustommainmenu.create(aowner: tcomponent);
begin
 inherited;
 include(foptions,mo_updateonidle);
 application.registeronidle({$ifdef FPC}@{$endif}doidle); 
 fmenu.onchange:= {$ifdef FPC}@{$endif}menuchanged;
end;

destructor tcustommainmenu.destroy;
begin
 inherited;
end;

procedure tcustommainmenu.setpopupframetemplate(const avalue: tframecomp);
begin
 if avalue <> fpopuptemplate.frame then begin
  setlinkedvar(avalue,tmsecomponent(fpopuptemplate.frame));
 end;
end;

procedure tcustommainmenu.setpopupfacetemplate(const avalue: tfacecomp);
begin
 if avalue <> fpopuptemplate.face then begin
  setlinkedvar(avalue,tmsecomponent(fpopuptemplate.face));
 end;
end;

procedure tcustommainmenu.setpopupitemframetemplate(const avalue: tframecomp);
begin
 if avalue <> fpopuptemplate.itemframe then begin
  setlinkedvar(avalue,tmsecomponent(fpopuptemplate.itemframe));
 end;
end;

procedure tcustommainmenu.setpopupitemfacetemplate(const avalue: tfacecomp);
begin
 if avalue <> fpopuptemplate.itemface then begin
  setlinkedvar(avalue,tmsecomponent(fpopuptemplate.itemface));
 end;
end;

procedure tcustommainmenu.setpopupitemframetemplateactive(const avalue: tframecomp);
begin
 if avalue <> fpopuptemplate.itemframeactive then begin
  setlinkedvar(avalue,tmsecomponent(fpopuptemplate.itemframeactive));
 end;
end;

procedure tcustommainmenu.setpopupitemfacetemplateactive(const avalue: tfacecomp);
begin
 if avalue <> fpopuptemplate.itemfaceactive then begin
  setlinkedvar(avalue,tmsecomponent(fpopuptemplate.itemfaceactive));
 end;
end;

class function tcustommainmenu.classskininfo: skininfoty;
begin
 result:= inherited classskininfo;
 result.objectkind:= sok_mainmenu;
end;

procedure tcustommainmenu.menuchanged(const sender: tmenuitem);
begin
 if (fobjectlinker <> nil) and not (csloading in componentstate) then begin
  fobjectlinker.sendevent(oe_changed);
 end;
end;

function tcustommainmenu.gettemplatefont(const sender: tmenuitem): tmenufont;
begin
 if (sender.fparentmenu <> nil) and (sender.fparentmenu <> fmenu) then begin 
                            //in popup
  result:= nil;
  if popupitemframetemplate <> nil then begin
   result:= tmenufont(popupitemframetemplate.template.font);
  end;
  if result = nil then begin
   result:= tmenufont(pointer(stockobjects.fonts[stf_menu]));
  end;
 end
 else begin
  result:= inherited gettemplatefont(sender);
 end;
end;

function tcustommainmenu.gettemplatefontactive(
                                const sender: tmenuitem): tmenufontactive;
begin
 if sender.fparentmenu <> fmenu then begin //in popup
  result:= nil;
  if popupitemframetemplateactive <> nil then begin
   result:= tmenufontactive(pointer(popupitemframetemplateactive.template.font));
  end;
 end
 else begin
  result:= inherited gettemplatefontactive(sender);
 end;
end;

end.
