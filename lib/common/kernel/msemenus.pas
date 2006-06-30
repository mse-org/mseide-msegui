{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msemenus;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 mseactions,msegui,msearrayprops,mseclasses,msegraphutils,
 msedrawtext,msegraphics,mseevent,mseguiglob,mseshapes,mserichstring,
 msetypes,msestrings,Classes,msekeyboard,msebitmap;
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
   procedure createitem(const index: integer; out item: tpersistent); override;
   procedure dosizechanged; override;
   procedure dochange(const aindex: integer); override;
   procedure receiveevent(const event: tobjectevent);
  public
   constructor create(const aowner: tmenuitem);
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
   function itembyname(const name: string): tmenuitem;
 end;

 tmenufont = class(tparentfont)
  public
   class function getinstancepo(owner: tobject): pfont; override;
 end;
 
 tcustommenu = class;

 tmenuitem = class(teventpersistent,iactionlink)
  private
   fparentmenu: tmenuitem;
   fonchange: menuitemeventty;
   fname: string;
   fgroup: integer;
   fsource: ievent;
   ffont: tmenufont;
   function getsubmenu: tmenuitems;
   procedure setsubmenu(const Value: tmenuitems);
   procedure setcaption(const Value: captionty);
   function iscaptionstored: Boolean;
   procedure setstate(const Value: actionstatesty);
   function isstatestored: Boolean;

   procedure actionchanged;
   procedure checksubmenu;
   function getitems(const index: integer): tmenuitem;
   procedure setitems(const index: integer; const Value: tmenuitem);
   procedure setaction(const avalue: tcustomaction);
   function isonexecutestored: Boolean;
   function isshortcutstored: Boolean;
   procedure setshortcut(const avalue: shortcutty);
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
   procedure setimagelist(const avalue: timagelist);
   function isimageliststored: Boolean;
   procedure setimagenr(const avalue: integer);
   function isimagenrstored: Boolean;
   function getfont: tmenufont;
   procedure createfont;
   procedure dofontchanged(const sender: tobject);
   procedure setfont(const avalue: tmenufont);
   function isfontstored: boolean;
  protected
   finfo: actioninfoty;
   fowner: tcustommenu;
   fsubmenu: tmenuitems;
   function getactioninfopo: pactioninfoty;
   procedure receiveevent(const event: tobjectevent); override;
   function internalexecute(async: boolean): boolean;
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
   function owner: tcustommenu;
   function execute: boolean; //true if onexecute fired
   function asyncexecute: boolean;
   function canactivate: boolean;
   function canshow: boolean;
   property onchange: menuitemeventty read fonchange write fonchange;
   property items[const index: integer]: tmenuitem read getitems
                         write setitems; default;
   function itembyname(const name: string): tmenuitem;
   function index: integer; //-1 if no parent menu
   property checked: boolean read getchecked write setchecked;
   property enabled: boolean read getenabled write setenabled;
   property visible: boolean read getvisible write setvisible;
  published
   property action: tcustomaction read finfo.action write setaction;
   property submenu: tmenuitems read getsubmenu write setsubmenu;
   property caption: captionty read finfo.captiontext write setcaption
                     stored iscaptionstored;
   property name: string read fname write fname;
   property state: actionstatesty read finfo.state write setstate 
                     stored isstatestored default [];
   property options: menuactionoptionsty read finfo.options write setoptions default [mao_shortcutcaption];
   property shortcut: shortcutty read finfo.shortcut write setshortcut 
                     stored isshortcutstored default 0;
   property tag: integer read finfo.tag write settag stored istagstored default 0;
   property group: integer read finfo.group write setgroup 
                     stored isgroupstored default 0;
   property imagelist: timagelist read finfo.imagelist write setimagelist
                     stored isimageliststored;
   property imagenr: integer read finfo.imagenr write setimagenr
                            stored isimagenrstored default -1;
   property font: tmenufont read getfont write setfont stored isfontstored;
   property onexecute: notifyeventty read finfo.onexecute
                     write setonexecute stored isonexecutestored;
 end;

 pmenuitem = ^tmenuitem;

 menueventty = procedure(const sender: tcustommenu) of object;

 menuoptionty = (mo_insertfirst,mo_singleregion);
 menuoptionsty = set of menuoptionty;

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
  protected
   ftransientfor: twidget;
   fmouseinfopo: pmouseeventinfoty;
   procedure readstate(reader: treader); override;
   procedure loaded; override;
   procedure setexecitem(const avalue: tmenuitem);
   property execitem: tmenuitem write setexecitem;
   procedure assigntemplate(const source: tcustommenu);
   procedure objectevent(const sender: tobject; const event: objecteventty); override;
  public
   constructor create(aowner: tcomponent); overload; override;
   constructor createtransient(atransientfor: twidget;
                  amouseinfopo: pmouseeventinfoty); overload;
   destructor destroy; override;
   function checkexec: boolean;
   procedure assign(source: tpersistent); override;
   procedure doshortcut(var info: keyeventinfoty);
   procedure doupdate;
   function count: integer;
   function transientfor: twidget;
   function mouseinfopo: pmouseeventinfoty;
   property menu: tmenuitem read fmenu write setmenu;
   property frametemplate: tframecomp read ftemplate.frame write setframetemplate;
   property facetemplate: tfacecomp read ftemplate.face write setfacetemplate;
   property itemframetemplate: tframecomp read ftemplate.itemframe 
                            write setitemframetemplate;
   property itemfacetemplate: tfacecomp read ftemplate.itemface 
                            write setitemfacetemplate;
   property template: menutemplatety read ftemplate;
   property options: menuoptionsty read foptions write foptions default [];
   property onupdate: menueventty read fonupdate write fonupdate;
 end;

 tmenu = class(tcustommenu)
  published
   property menu;
   property options;
   property onupdate;
   property frametemplate;
   property facetemplate;
   property itemframetemplate;
   property itemfacetemplate;
 end;

 tpopupmenu = class(tmenu)
  private
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

 tmainmenu = class(tmenu)
  private
   fpopuptemplate: menutemplatety;
   procedure setpopupframetemplate(const avalue: tframecomp);
   procedure setpopupfacetemplate(const avalue: tfacecomp);
   procedure setpopupitemframetemplate(const avalue: tframecomp);
   procedure setpopupitemfacetemplate(const avalue: tfacecomp);
  protected
   procedure doidle(var again: boolean);
   procedure menuchanged(const sender: tmenuitem);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property popuptemplate: menutemplatety read fpopuptemplate;
  published
   property popupframetemplate: tframecomp read fpopuptemplate.frame
                      write setpopupframetemplate;
   property popupfacetemplate: tfacecomp read fpopuptemplate.face
                      write setpopupfacetemplate;
   property popupitemframetemplate: tframecomp read fpopuptemplate.itemframe
                      write setpopupitemframetemplate;
   property popupitemfacetemplate: tfacecomp read fpopuptemplate.itemface
                      write setpopupitemfacetemplate;
 end;

procedure freetransientmenu(var amenu: tcustommenu);

implementation
uses
 sysutils,msestockobjects,rtlconsts,msebits,msemenuwidgets,msedatalist;

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
 fi.levelo:= 1;
end;

{ tcustommenu }

constructor tcustommenu.create(aowner: tcomponent);
begin
 inherited;
 fmenu:= tmenuitem.create(nil,self);
end;

constructor tcustommenu.createtransient(atransientfor: twidget;
                        amouseinfopo: pmouseeventinfoty);
begin
 create(nil);
 ftransient:= true;
 ftransientfor:= atransientfor;
 fmouseinfopo:= amouseinfopo;
end;

destructor tcustommenu.destroy;
begin
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

procedure tcustommenu.readstate(reader: treader);
begin
 fmenu.beginload;
 inherited;
end;

procedure tcustommenu.loaded;
begin
 fmenu.endload;
 inherited;
end;

procedure tcustommenu.setexecitem(const avalue: tmenuitem);
begin
 fexecitem:= avalue;
end;

function tcustommenu.checkexec: boolean;
begin
 result:= fexecitem <> nil;
 if result then begin
  fexecitem.onexecute(fexecitem);
 end;
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
{
procedure tcustommenu.templatechanged(const sender: tobject);
begin
 sendchangeevent;
end;
}
procedure tcustommenu.objectevent(const sender: tobject; const event: objecteventty);
begin
 if (event = oe_changed) then begin
  if (sender = ftemplate.face) or (sender = ftemplate.frame) then begin
   sendchangeevent;
  end;
 end;
 inherited;
end;

procedure tcustommenu.assigntemplate(const source: tcustommenu);
begin
 ftemplate:= source.ftemplate;
end;

{ tmenufont }

class function tmenufont.getinstancepo(owner: tobject): pfont;
begin
 result:= @(tmenuitem(owner).ffont);
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
 initactioninfo(finfo,[mao_shortcutcaption]);
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

function tmenuitem.owner: tcustommenu;
begin
 result:= fowner;
end;

procedure tmenuitem.setcaption(const Value: msestring);
begin
 setactioncaption(iactionlink(self),value);
end;

function tmenuitem.iscaptionstored: Boolean;
begin
 result:= isactioncaptionstored(finfo);
end;

procedure tmenuitem.setstate(const Value: actionstatesty);
begin
 setactionstate(iactionlink(self),value);
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
 setactiononexecute(iactionlink(self),avalue);
end;

function tmenuitem.isonexecutestored: Boolean;
begin
 result:= isactiononexecutestored(finfo);
end;

procedure tmenuitem.actionchanged;
begin
 if assigned(fonchange) then begin
  fonchange(self);
 end;
 if (fparentmenu <> nil) and assigned(fparentmenu.fonchange) then begin
  fparentmenu.fonchange(self);
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
 if mao_checkbox in finfo.options then begin
  if mao_radiobutton in finfo.options then begin
   checked:= true;
  end
  else begin
   checked:= not checked;
  end;
 end;
 result:= canactivate and assigned(finfo.onexecute);
 if result then begin
  if async then begin
   finfo.onexecute(self);
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
 result:= canactivate and assigned(finfo.onexecute);
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
  fsource:= ievent(tmenuitem(source));
  action1:= finfo.action;
  with tmenuitem(source) do begin
   self.finfo:= finfo;
   self.finfo.action:= action1;
   self.action:= finfo.action;
   self.submenu:= fsubmenu;
   if self.fowner.ftransient then begin
    self.ffont:= font;
   end
   else begin
    self.font:= font;
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
     if (finfo.options * [mao_checkbox,mao_radiobutton] = [mao_checkbox,mao_radiobutton]) and
             (fgroup = self.fgroup) then begin
      setactionchecked(iactionlink(self),false);
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

procedure tmenuitem.setimagelist(const avalue: timagelist);
begin
 setactionimagelist(iactionlink(self),avalue);
end;

function tmenuitem.isimageliststored: Boolean;
begin
 result:= isactionimageliststored(finfo);
end;

procedure tmenuitem.setimagenr(const avalue: integer);
begin
 setactionimagenr(iactionlink(self),avalue);
end;

function tmenuitem.isimagenrstored: Boolean;
begin
 result:= isactionimagenrstored(finfo);
end;

function tmenuitem.isfontstored: boolean;
begin
 result:= ffont <> nil;
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

function tmenuitem.getfont: tmenufont;
begin
 getoptionalobject(fowner.componentstate,ffont,{$ifdef FPC}@{$endif}createfont);
 if ffont <> nil then begin
  result:= ffont;
 end
 else begin
  if fparentmenu <> nil then begin
   result:= fparentmenu.getfont;
  end
  else begin
   result:= tmenufont(stockobjects.fonts[stf_menu]);
  end;
 end;
end;

procedure tmenuitem.setfont(const avalue: tmenufont);
begin
 if avalue <> ffont then begin
  setoptionalobject(fowner.componentstate,avalue,ffont,
               {$ifdef FPC}@{$endif}createfont);
  actionchanged;
 end;
end;

{ tmenuitems }

constructor tmenuitems.create(const aowner: tmenuitem);
begin
 fowner:= aowner;
 inherited create(tmenuitem);
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

procedure tmenuitems.createitem(const index: integer; out item: tpersistent);
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
 if count = 0 then begin
  tmenuitem(fowner).fsubmenu:= nil;
  fowner:= nil;
  application.postevent(tobjectevent.create(ek_release,ievent(self)));
 end;
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

function tmenuitems.itembyname(const name: string): tmenuitem;
var
 int1: integer;
 po1: pmenuitem;
begin
 result:= nil;
 po1:= pointer(fitems);
 for int1:= 0 to high(fitems) do begin
  if (po1^.fname = name) or
          (po1^.finfo.action <> nil) and (po1^.finfo.action.Name = name) then begin
   result:= po1^;
   break;
  end;
  inc(po1);
 end;
end;

{ tpopupmenu }

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
  checkexec;
 finally
  ftransientfor:= nil;
  fmouseinfopo:= nil;
 end;
end;

class procedure tpopupmenu.additems(var amenu: tpopupmenu; const atransientfor: twidget;
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
begin
 items.fmouseinfopo:= @mouseinfo;
 items.doupdate;
 bo1:= (amenu = nil) or amenu.ftransient;
 additems(amenu,atransientfor,mouseinfo,items.fmenu.fsubmenu,aseparator,
            mo_insertfirst in items.foptions);
 if bo1 then begin
  amenu.assigntemplate(items);
  amenu.fmenu.ffont:= items.fmenu.ffont;
 end;
end;

{ tmainmenu }

constructor tmainmenu.create(aowner: tcomponent);
begin
 inherited;
 application.registeronidle({$ifdef FPC}@{$endif}doidle);
 fmenu.onchange:= {$ifdef FPC}@{$endif}menuchanged;
end;

destructor tmainmenu.destroy;
begin
 application.unregisteronidle({$ifdef FPC}@{$endif}doidle);
 inherited;
end;

procedure tmainmenu.setpopupframetemplate(const avalue: tframecomp);
begin
 if avalue <> fpopuptemplate.frame then begin
  setlinkedvar(avalue,tmsecomponent(fpopuptemplate.frame));
 end;
end;

procedure tmainmenu.setpopupfacetemplate(const avalue: tfacecomp);
begin
 if avalue <> fpopuptemplate.face then begin
  setlinkedvar(avalue,tmsecomponent(fpopuptemplate.face));
 end;
end;

procedure tmainmenu.setpopupitemframetemplate(const avalue: tframecomp);
begin
 if avalue <> fpopuptemplate.itemframe then begin
  setlinkedvar(avalue,tmsecomponent(fpopuptemplate.itemframe));
 end;
end;

procedure tmainmenu.setpopupitemfacetemplate(const avalue: tfacecomp);
begin
 if avalue <> fpopuptemplate.itemface then begin
  setlinkedvar(avalue,tmsecomponent(fpopuptemplate.itemface));
 end;
end;

procedure tmainmenu.doidle(var again: boolean);
begin
 doupdate;
end;

procedure tmainmenu.menuchanged(const sender: tmenuitem);
begin
 if (fobjectlinker <> nil) and not (csloading in componentstate) then begin
  fobjectlinker.sendevent(oe_changed);
 end;
end;

end.
