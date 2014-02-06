{ MSEgui Copyright (c) 1999-2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msetoolbar;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 classes,mclasses,msewidgets,msearrayprops,mseclasses,msebitmap,
 mseact,mseshapes,msemenus,msedragglob,
 msegraphutils,msegraphics,mseevent,
 mseglob,mseguiglob,msegui,msesimplewidgets,
 msestat,msestatfile,msedrag,msestrings;

type

 tcustomtoolbar = class;

 tcustomtoolbutton = class(tindexpersistent,iactionlink,iimagelistinfo)
  private
   finfo: actioninfoty;
//   fonupdate: actioneventty;
   procedure setaction(const Value: tcustomaction);
   procedure setimagenr(const Value: imagenrty);
   procedure setimagenrdisabled(const Value: imagenrty);
   procedure setcolorglyph(const avalue: colorty);
   function iscolorglyphstored: boolean;
   procedure setcolor(const avalue: colorty);
   function iscolorstored: boolean;
   procedure setimagecheckedoffset(const Value: integer);
   function getstate: actionstatesty;
   function isstatestored: Boolean;
   procedure setstate(const Value: actionstatesty);
   function isimagenrstored: Boolean;
   function isimagenrdisabledstored: Boolean;
   function isimagecheckedoffsetstored: Boolean;
   function isimageliststored: Boolean; virtual;
   function getimagelist: timagelist;
   procedure setimagelist(const Value: timagelist); virtual;
   function isgroupstored: Boolean;
   procedure setgroup(const Value: integer);
   procedure changed;
   function getchecked: boolean;
   procedure setchecked(const Value: boolean);
   procedure sethint(const Value: msestring);
   function ishintstored: Boolean;
   procedure setonexecute(const Value: notifyeventty);
   function isonexecutestored: Boolean;
   procedure setonbeforeexecute(const avalue: accepteventty);
   function isonbeforeexecutestored: Boolean;
   procedure setoptions(const Value: menuactionoptionsty);
   procedure setshortcut(const value: shortcutty);
   function isshortcutstored: boolean;
   function getshortcut: shortcutty;
   function getshortcut1: shortcutty;
   procedure setshortcut1(const value: shortcutty);
   function isshortcut1stored: boolean;
   function getenabled: boolean;
   function getvisible: boolean;
   procedure setenabled(const avalue: boolean);
   procedure setvisible(const avalue: boolean);
   procedure readbool(reader: treader);
   procedure writebool(writer: twriter);
   procedure setshortcuts(const avalue: shortcutarty);
   procedure setshortcuts1(const avalue: shortcutarty);  
  protected
   ftag: integer;
   ftagpointer: pointer;
   procedure doexecute(const tag: integer; const info: mouseeventinfoty);
   procedure objectevent(const sender: tobject; const event: objecteventty); override;
   procedure defineproperties(filer: tfiler); override;
   //iactionlink
   procedure actionchanged;
   function getactioninfopo: pactioninfoty;
   procedure doshortcut(var info: keyeventinfoty);
   function getinstance: tobject; override;
   function loading: boolean;
   function shortcutseparator: msechar;
   procedure calccaptiontext(var ainfo: actioninfoty);
   
  public
   constructor create(const aowner: tobject;
         const aprop: tindexpersistentarrayprop); overload; override;
   constructor create(aowner: tcustomtoolbar); reintroduce; overload;
   function toolbar: tcustomtoolbar;
   function index: integer;
   procedure execute;
   procedure doupdate;
   property checked: boolean read getchecked write setchecked;
   property visible: boolean read getvisible write setvisible default true;
   property enabled: boolean read getenabled write setenabled default true;
   property tagpointer: pointer read ftagpointer write ftagpointer;
   property shortcuts: shortcutarty read finfo.shortcut write setshortcuts;
   property shortcuts1: shortcutarty read finfo.shortcut1 write setshortcuts1;
   property imagelist: timagelist read getimagelist write setimagelist
                    stored isimageliststored;
   property imagenr: imagenrty read finfo.imagenr write setimagenr
                            stored isimagenrstored default -1;
   property imagenrdisabled: imagenrty read finfo.imagenrdisabled 
                                     write setimagenrdisabled
                                     stored isimagenrdisabledstored default -2;
   property colorglyph: colorty read finfo.colorglyph write setcolorglyph 
                       stored iscolorglyphstored default cl_glyph;
   property color: colorty read finfo.color write setcolor 
                       stored iscolorstored default cl_transparent;
   property imagecheckedoffset: integer read finfo.imagecheckedoffset
              write setimagecheckedoffset
                            stored isimagecheckedoffsetstored default 0;
   property hint: msestring read finfo.hint write sethint stored ishintstored;
   property action: tcustomaction read finfo.action write setaction;
   property state: actionstatesty read getstate write setstate
                             stored isstatestored default [];
   property shortcut: shortcutty read getshortcut write setshortcut
                        stored isshortcutstored default 0;
   property shortcut1: shortcutty read getshortcut1 write setshortcut1
                        stored isshortcut1stored default 0;
   property tag: integer read ftag write ftag default 0;
   property options: menuactionoptionsty read finfo.options write setoptions default [];
   property group: integer read finfo.group write setgroup
                             stored isgroupstored default 0;
   property onexecute: notifyeventty read finfo.onexecute write setonexecute
                               stored isonexecutestored;
   property onbeforeexecute: accepteventty read finfo.onbeforeexecute
                   write setonbeforeexecute stored isonbeforeexecutestored;
//   property onupdate: actioneventty read fonupdate write fonupdate;
 end;
 
 ttoolbutton = class(tcustomtoolbutton)
  published
   property imagelist;
   property imagenr;
   property imagenrdisabled;
   property colorglyph;
   property color;
   property imagecheckedoffset;
   property hint;
   property action;
   property state;
   property shortcut;
   property shortcut1;
   property tag;
   property options;
   property group;
   property onexecute;
   property onbeforeexecute;
 end;
 ptoolbutton = ^ttoolbutton;

 tcustomstockglyphtoolbutton = class(tcustomtoolbutton)
  private
   function isimageliststored: boolean; override;
   procedure setimagelist(const Value: timagelist); override;
  public
   constructor create(const aowner: tobject;
         const aprop: tindexpersistentarrayprop); overload; override;
 end;
 
 tstockglyphtoolbutton = class(tcustomstockglyphtoolbutton)
  published
   property imagelist;
   property imagenr;
   property imagenrdisabled;
   property colorglyph;
   property color;
   property imagecheckedoffset;
   property hint;
   property action;
   property state;
   property shortcut;
   property shortcut1;
   property tag;
   property options;
   property group;
   property onexecute;
   property onbeforeexecute; 
 end;
  
 toolbuttonsstatety = (tbs_nocandefocus);
 toolbuttonsstatesty = set of toolbuttonsstatety;
 toolbuttonclassty = class of tcustomtoolbutton;
 
 tcustomtoolbuttons = class(tindexpersistentarrayprop)
  private
   fheight: integer;
   fwidth: integer;
   fimagelist: timagelist;
   fcolorglyph: colorty;
   fcolor: colorty;
   fface: tface;
   procedure setitems(const index: integer; const Value: tcustomtoolbutton);
   function getitems(const index: integer): tcustomtoolbutton; reintroduce;
   procedure setheight(const Value: integer);
   procedure setwidth(const Value: integer);
   procedure setimagelist(const avalue: timagelist);
   procedure setcolorglyph(const avalue: colorty);
   procedure setcolor(const avalue: colorty);
   function getface: tface;
   procedure setface(const avalue: tface);
  protected
   fbuttonstate: toolbuttonsstatesty;
   procedure createitem(const index: integer; var item: tpersistent); override;
   procedure dochange(const index: integer); override;
   procedure objectchanged(const sender: tobject);
   class function getbuttonclass: toolbuttonclassty; virtual;
  public
   constructor create(const aowner: tcustomtoolbar); reintroduce;
   destructor destroy; override;
   class function getitemclasstype: persistentclassty; override;
   procedure createface;
   procedure doupdate;
   procedure resetradioitems(const group: integer);
   function getcheckedradioitem(const group: integer): tcustomtoolbutton;
   function add: tcustomtoolbutton;
   property items[const index: integer]: tcustomtoolbutton read getitems write setitems; default;
  published
   property width: integer read fwidth write setwidth default 0;
   property height: integer read fheight write setheight default 0;
   property imagelist: timagelist read fimagelist write setimagelist;
   property colorglyph: colorty read fcolorglyph write setcolorglyph default cl_glyph;
   property color: colorty read fcolor write setcolor default cl_transparent;
   property face: tface read getface write setface;
 end;

 ttoolbuttons = class(tcustomtoolbuttons)
  protected
   class function getbuttonclass: toolbuttonclassty; override;
  published
   property width;
   property height;
   property imagelist;
   property colorglyph;
   property color;
   property face;
 end;
 
 tstockglyphtoolbuttons = class(ttoolbuttons)
  protected
   class function getbuttonclass: toolbuttonclassty; override;
 end;
 
 toolbaroptionty = (tbo_dragsource,tbo_dragdest,
                    tbo_dragsourceenabledonly,tbo_dragdestenabledonly,
                    tbo_nohorz,tbo_novert,
                    tbo_shortcuthint);
 toolbaroptionsty = set of toolbaroptionty;

 toolbarlayoutinfoty = record
  vert: boolean;
  buttons: ttoolbuttons;
  cells: shapeinfoarty;
  stepinfo: framestepinfoty;
//  maxbuttons: integer;
  focusedbutton: integer;
  lines: integer;
  buttonsize: sizety;
  defaultsize: sizety;
 end;

 toolbuttoneventty = procedure(const sender: tobject;
              const button: tcustomtoolbutton) of object;

 tcustomtoolbar = class(tcustomstepbox,istatfile)
  private
   flayoutok: boolean;
   foptions: toolbaroptionsty;
   fonbuttonchanged: toolbuttoneventty;
   fhintedbutton: integer;
   fupdating: integer;
   ffirstbutton: integer;
   fstatfile: tstatfile;
   fstatvarname: msestring;
   fstatpriority: integer;
   procedure setbuttons(const Value: ttoolbuttons);
   procedure setoptions(const Value: toolbaroptionsty);
   function gethintpos(const aindex: integer): rectty;
   function getbuttonhint(const aindex: integer): msestring;
   procedure setfirstbutton(value: integer);
   procedure buttonschanged(const sender: tarrayprop; const index: integer);
   procedure setstatfile(const Value: tstatfile);
   procedure setdragcontroller(const Value: tdragcontroller);
  protected
   flayout: toolbarlayoutinfoty;
   class function classskininfo: skininfoty; override;
   procedure buttonchanged(sender: tcustomtoolbutton);
   procedure checkvert(const asize: sizety);
   procedure getautopaintsize(var asize: sizety); override;
   procedure updatelayout;
   procedure clientrectchanged; override;
   procedure dopaintforeground(const canvas: tcanvas); override;
   procedure clientmouseevent(var info: mouseeventinfoty); override;
   procedure showhint(var info: hintinfoty); override;
   function dostep(const event: stepkindty; const adelta: real;
                      ashiftstate: shiftstatesty): boolean; override;
   procedure doshortcut(var info: keyeventinfoty; const sender: twidget); override;
   procedure objectchanged(const sender: tobject); override;
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
   procedure dragevent(var info: draginfoty); override;
   procedure beginupdate;
   procedure endupdate;
   function buttonatpos(const apos: pointty; const enabledonly: boolean = false): tcustomtoolbutton;

   property buttons: ttoolbuttons read flayout.buttons write setbuttons;
   property firstbutton: integer read ffirstbutton write setfirstbutton default 0;
   property options: toolbaroptionsty read foptions write setoptions default [];
   property statfile: tstatfile read fstatfile write setstatfile;
   property statvarname: msestring read getstatvarname write fstatvarname;
   property statpriority: integer read fstatpriority 
                                       write fstatpriority default 0;

   property onbuttonchanged: toolbuttoneventty read fonbuttonchanged write fonbuttonchanged;
   property drag: tdragcontroller read fdragcontroller write setdragcontroller;

 end;

 ttoolbar = class(tcustomtoolbar)
  published
   property frame;
   property onstep;

   property optionswidget default defaultoptionswidgetnofocus;
   property buttons;
   property firstbutton;
   property options;
   property statfile;
   property statvarname;
   property statpriority;
   property onbuttonchanged;
   property drag;
  end;

implementation
uses
 sysutils,msebits,mseactions,msestockobjects;
 
const
 separatorwidth = 3;
type
 tcustomstepframe1 = class(tcustomstepframe);
 twidget1 = class(twidget);
 
procedure drawtoolbuttons(const canvas: tcanvas;
           var layout: toolbarlayoutinfoty);
var
 int1: integer;
begin
 with layout do begin
  for int1:= 0 to high(cells) do begin
   cells[int1].face:= buttons.fface;
   drawtoolbutton(canvas,cells[int1]);
  end;
 end;
end;

{ tcustomtoolbutton }

constructor tcustomtoolbutton.create(const aowner: tobject;
         const aprop: tindexpersistentarrayprop);
begin
 initactioninfo(finfo);
 finfo.color:= ttoolbuttons(aprop).color;
 inherited;
end;

constructor tcustomtoolbutton.create(aowner: tcustomtoolbar);
begin
 create(aowner,aowner.buttons);
end;

procedure tcustomtoolbutton.objectevent(const sender: tobject; const event: objecteventty);
begin
 inherited;
 if sender = finfo.imagelist then begin
  if event = oe_destroyed then begin
   finfo.imagelist:= nil;
  end;
  changed;
 end;
end;

procedure tcustomtoolbutton.actionchanged;
begin
 changed;
end;

function tcustomtoolbutton.getactioninfopo: pactioninfoty;
begin
 result:= @finfo;
end;

function tcustomtoolbutton.toolbar: tcustomtoolbar;
begin
 result:= tcustomtoolbar(fowner);
end;

procedure tcustomtoolbutton.setaction(const Value: tcustomaction);
begin
 linktoaction(iactionlink(self),value,finfo);
end;

function tcustomtoolbutton.getstate: actionstatesty;
begin
 result:= finfo.state;
end;

procedure tcustomtoolbutton.setstate(const Value: actionstatesty);
begin
 setactionstate(iactionlink(self),value);
end;

function tcustomtoolbutton.isstatestored: Boolean;
begin
 result:= isactionstatestored(finfo);
end;

function tcustomtoolbutton.getimagelist: timagelist;
begin
 result:= timagelist(finfo.imagelist);
end;

procedure tcustomtoolbutton.setimagelist(const Value: timagelist);
begin
 setactionimagelist(iactionlink(self),value);
end;

function tcustomtoolbutton.isimageliststored: Boolean;
begin
 result:= isactionimageliststored(finfo);
end;

function tcustomtoolbutton.getshortcut: shortcutty;
begin
 result:= getsimpleshortcut(finfo);
end;

function tcustomtoolbutton.getshortcut1: shortcutty;
begin
 result:= getsimpleshortcut1(finfo);
end;

procedure tcustomtoolbutton.setshortcut(const Value: shortcutty);
begin
 setactionshortcut(iactionlink(self),value);
end;

function tcustomtoolbutton.isshortcutstored: Boolean;
begin
 result:= isactionshortcutstored(finfo);
end;

procedure tcustomtoolbutton.setshortcut1(const Value: shortcutty);
begin
 setactionshortcut1(iactionlink(self),value);
end;

function tcustomtoolbutton.isshortcut1stored: Boolean;
begin
 result:= isactionshortcut1stored(finfo);
end;

procedure tcustomtoolbutton.setimagenr(const Value: imagenrty);
begin
 setactionimagenr(iactionlink(self),value);
end;

procedure tcustomtoolbutton.setimagenrdisabled(const Value: imagenrty);
begin
 setactionimagenrdisabled(iactionlink(self),value);
end;

procedure tcustomtoolbutton.setcolorglyph(const avalue: colorty);
begin
 setactioncolorglyph(iactionlink(self),avalue);
end;

function tcustomtoolbutton.iscolorglyphstored: boolean;
begin
 result:= isactioncolorglyphstored(finfo);
end;

procedure tcustomtoolbutton.setcolor(const avalue: colorty);
begin
 setactioncolor(iactionlink(self),avalue);
end;

function tcustomtoolbutton.iscolorstored: boolean;
begin
 result:= isactioncolorstored(finfo);
end;

procedure tcustomtoolbutton.setimagecheckedoffset(const Value: integer);
begin
 setactionimagecheckedoffset(iactionlink(self),value);
end;

function tcustomtoolbutton.isimagenrstored: Boolean;
begin
 result:= isactionimagenrstored(finfo);
end;

function tcustomtoolbutton.isimagenrdisabledstored: Boolean;
begin
 result:= isactionimagenrdisabledstored(finfo);
end;

function tcustomtoolbutton.isimagecheckedoffsetstored: Boolean;
begin
 result:= isactionimagecheckedoffsetstored(finfo);
end;

procedure tcustomtoolbutton.sethint(const Value: msestring);
begin
 setactionhint(iactionlink(self),value);
end;

function tcustomtoolbutton.ishintstored: Boolean;
begin
 result:= isactionhintstored(finfo);
end;

procedure tcustomtoolbutton.setonexecute(const Value: notifyeventty);
begin
 setactiononexecute(iactionlink(self),value,csloading in toolbar.componentstate);
end;

function tcustomtoolbutton.isonexecutestored: Boolean;
begin
 result:= isactiononexecutestored(finfo);
end;

procedure tcustomtoolbutton.setonbeforeexecute(const avalue: accepteventty);
begin
 setactiononbeforeexecute(iactionlink(self),avalue,csloading in toolbar.componentstate);
end;

function tcustomtoolbutton.isonbeforeexecutestored: Boolean;
begin
 result:= isactiononbeforeexecutestored(finfo);
end;

procedure tcustomtoolbutton.setgroup(const Value: integer);
begin
 setactiongroup(iactionlink(self),value);
end;

function tcustomtoolbutton.isgroupstored: Boolean;
begin
 result:= isactiongroupstored(finfo);
end;

procedure tcustomtoolbutton.changed;
begin
 tcustomtoolbar(fowner).buttonchanged(self);
end;

function tcustomtoolbutton.index: integer;
begin
 result:= findex;
end;

function tcustomtoolbutton.getchecked: boolean;
begin
 result:= as_checked in finfo.state;
end;

procedure tcustomtoolbutton.setchecked(const Value: boolean);
begin
 if value then begin
  state:= state + [as_checked];
 end
 else begin
  state:= state - [as_checked];
 end;
end;

procedure tcustomtoolbutton.doexecute(const tag: integer;
                                                const info: mouseeventinfoty);
begin
 if doactionexecute(self,finfo,false,
      tbs_nocandefocus in ttoolbuttons(prop).fbuttonstate) then begin
  changed;
 end;
end;

procedure tcustomtoolbutton.execute;
begin
 doexecute(-1,pmouseeventinfoty(nil)^);
end;

procedure tcustomtoolbutton.setoptions(const Value: menuactionoptionsty);
begin
 if finfo.options <> value then begin
  finfo.options := Value;
  changed;
 end;
end;

procedure tcustomtoolbutton.doshortcut(var info: keyeventinfoty);
begin
 if doactionshortcut(self,finfo,info) then begin
  changed;
 end;
end;

function tcustomtoolbutton.getenabled: boolean;
begin
 result:= not (as_disabled in finfo.state);
end;

procedure tcustomtoolbutton.setenabled(const avalue: boolean);
begin
 if avalue then begin
  state:= state - [as_disabled];
 end
 else begin
  state:= state + [as_disabled];
 end;
end;

function tcustomtoolbutton.getvisible: boolean;
begin
 result:= not (as_invisible in finfo.state);
end;

procedure tcustomtoolbutton.setvisible(const avalue: boolean);
begin
 if avalue then begin
  state:= state - [as_invisible];
 end
 else begin
  state:= state + [as_invisible];
 end;
end;

function tcustomtoolbutton.getinstance: tobject;
begin
 result:= fowner;
end;

function tcustomtoolbutton.loading: boolean;
begin
 result:= (fowner is tcomponent) and 
               (csloading in tcomponent(fowner).componentstate);
end;

function tcustomtoolbutton.shortcutseparator: msechar;
begin
 result:= ' ';
end;

procedure tcustomtoolbutton.calccaptiontext(var ainfo: actioninfoty);
begin
 mseactions.calccaptiontext(ainfo,shortcutseparator);
end;

procedure tcustomtoolbutton.readbool(reader: treader);
begin
 reader.readboolean; //dummy
end;

procedure tcustomtoolbutton.writebool(writer: twriter);
begin
 //dummy
end;

procedure tcustomtoolbutton.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('visible',{$ifdef FPC}@{$endif}readbool,
                                {$ifdef FPC}@{$endif}writebool,false);
 filer.defineproperty('enabled',{$ifdef FPC}@{$endif}readbool,
                                {$ifdef FPC}@{$endif}writebool,false);
end;

procedure tcustomtoolbutton.setshortcuts(const avalue: shortcutarty);
begin
 setactionshortcuts(iactionlink(self),avalue);
end;

procedure tcustomtoolbutton.setshortcuts1(const avalue: shortcutarty);
begin
 setactionshortcuts1(iactionlink(self),avalue);
end;

procedure tcustomtoolbutton.doupdate;
begin
 if finfo.action <> nil then begin
  finfo.action.doupdate;
 end;
end;

{ tcustomtoolbuttons }

constructor tcustomtoolbuttons.create(const aowner: tcustomtoolbar);
begin
 fcolorglyph:= cl_glyph;
 fcolor:= cl_transparent;
 inherited create(aowner,getbuttonclass);
end;

destructor tcustomtoolbuttons.destroy;
begin
 inherited;
 fface.free;
end;

class function tcustomtoolbuttons.getitemclasstype: persistentclassty;
begin
 result:= ttoolbutton;
end;

function tcustomtoolbuttons.add: tcustomtoolbutton;
begin
 count:= count + 1;
 result:= items[count-1];
end;

procedure tcustomtoolbuttons.createitem(const index: integer; var item: tpersistent);
begin
 inherited;
 if not (csloading in tcustomtoolbar(fowner).componentstate) then begin
  with tcustomtoolbutton(item) do begin
   if fimagelist <> nil then begin
    imagelist:= fimagelist;
   end;
   if fcolorglyph <> cl_glyph then begin
    colorglyph:= fcolorglyph;
   end;
   if fcolor <> cl_transparent then begin
    color:= fcolor;
   end;
//   state:= state - [as_localimagelist,as_localcolorglyph,as_localcolor];
  end;
 end;
end;

procedure tcustomtoolbuttons.dochange(const index: integer);
var
 int1: integer;
 po1: ptoolbutton;
begin
 if index < 0 then begin
  po1:= pointer(fitems);
  for int1:= 0 to high(fitems) do begin
   po1^.findex:= int1;
   inc(po1);
  end;
 end
 else begin
  tcustomtoolbutton(fitems[index]).findex:= index;
 end;
 inherited;
end;

function tcustomtoolbuttons.getcheckedradioitem(
  const group: integer): tcustomtoolbutton;
var
 int1: integer;
begin
 result:= nil;
 for int1:= 0 to count - 1 do begin
  with items[int1] do begin
   if (finfo.group = group) and
     (mao_radiobutton in finfo.options) and (as_checked in finfo.state) then begin
    result:= items[int1];
    break;
   end;
  end;
 end;
end;

procedure tcustomtoolbuttons.resetradioitems(const group: integer);
var
 int1: integer;
begin
 for int1:= 0 to count - 1 do begin
  with items[int1] do begin
   if (finfo.group = group) and (as_checked in finfo.state) then begin
    state:= finfo.state - [as_checked];
   end;
  end;
 end;
end;

function tcustomtoolbuttons.getitems(const index: integer): tcustomtoolbutton;
begin
 result:= tcustomtoolbutton(inherited items[index]);
end;

procedure tcustomtoolbuttons.setitems(const index: integer;
  const Value: tcustomtoolbutton);
begin
 inherited items[index].assign(value);
end;

procedure tcustomtoolbuttons.setheight(const Value: integer);
begin
 if fheight <> value then begin
  fheight:= Value;
  dochange(-1);
 end;
end;

procedure tcustomtoolbuttons.setwidth(const Value: integer);
begin
 if fwidth <> value then begin
  fwidth:= Value;
  dochange(-1);
 end;
end;

procedure tcustomtoolbuttons.setimagelist(const avalue: timagelist);
var
 int1: integer;
begin
 setlinkedvar(avalue,tmsecomponent(fimagelist));
 if not (csloading in tcomponent(fowner).componentstate) then begin
  for int1:= 0 to count - 1 do begin
   items[int1].imagelist:= avalue;
  end;
 end;
end;

procedure tcustomtoolbuttons.setcolorglyph(const avalue: colorty);
var
 int1: integer;
begin
 fcolorglyph:= avalue;
 if not (csloading in tcomponent(fowner).componentstate) then begin
  for int1:= 0 to count - 1 do begin
   items[int1].colorglyph:= avalue;
  end;
 end;
end;

procedure tcustomtoolbuttons.setcolor(const avalue: colorty);
var
 int1: integer;
begin
 fcolor:= avalue;
 if not (csloading in tcomponent(fowner).componentstate) then begin
  for int1:= 0 to count - 1 do begin
   items[int1].color:= avalue;
  end;
 end;
end;

procedure tcustomtoolbuttons.createface;
begin
 if fface = nil then begin
  fface:= tface.create(iface(tcustomtoolbar(fowner)));
 end;
end;

function tcustomtoolbuttons.getface: tface;
begin
 tcustomtoolbar(fowner).getoptionalobject(fface,
                               {$ifdef FPC}@{$endif}createface);
 result:= fface;
end;

procedure tcustomtoolbuttons.setface(const avalue: tface);
begin
 tcustomtoolbar(fowner).setoptionalobject(avalue,fface,
                               {$ifdef FPC}@{$endif}createface);
 tcustomtoolbar(fowner).invalidate;
end;

procedure tcustomtoolbuttons.objectchanged(const sender: tobject);
begin
 if fface <> nil then begin
  fface.checktemplate(sender);
 end;
end;

class function tcustomtoolbuttons.getbuttonclass: toolbuttonclassty;
begin
 result:= tcustomtoolbutton;
end;

procedure tcustomtoolbuttons.doupdate;
var
 int1: integer;
begin
 for int1:= 0 to high(fitems) do begin
  with tcustomtoolbutton(fitems[int1]) do begin
   doupdate;
  end;
 end;
end;

{ ttoolbuttons }

class function ttoolbuttons.getbuttonclass: toolbuttonclassty;
begin
 result:= ttoolbutton;
end;

{ tcustomtoolbar }

constructor tcustomtoolbar.create(aowner: tcomponent);
begin
 if flayout.buttons = nil then begin
  flayout.buttons:= ttoolbuttons.create(self);
 end;
 flayout.buttons.onchange:= {$ifdef FPC}@{$endif}buttonschanged;
 fhintedbutton:= -2;
 inherited;
end;

destructor tcustomtoolbar.destroy;
begin
 inherited;
 flayout.buttons.Free;
end;

procedure tcustomtoolbar.checkvert(const asize: sizety);
begin
 with flayout do begin
  vert:= asize.cy > asize.cx;
  if (tbo_novert in foptions) then begin
   vert:= false;
  end;
  if (tbo_nohorz in foptions) then begin
   vert:= true;
  end;
  buttonsize:= asize;
  if vert then begin
   if buttons.fwidth > 0 then begin
    buttonsize.cx:= buttons.fwidth;
   end;
   if buttons.fheight = 0 then begin
    buttonsize.cy:= buttonsize.cx;
   end
   else begin
    buttonsize.cy:= buttons.fheight;
   end;
  end
  else begin
   if buttons.fheight > 0 then begin
    buttonsize.cy:= buttons.fheight;
   end;
   if buttons.fwidth = 0 then begin
    buttonsize.cx:= buttonsize.cy;
   end
   else begin
    buttonsize.cx:= buttons.fwidth;
   end;
  end;
 end;
end;

procedure tcustomtoolbar.getautopaintsize(var asize: sizety);
var
 int1: integer;
 size1: sizety;
begin
 with flayout do begin
  if (defaultsize.cx = 0) or (buttons.width = 0) or 
           (defaultsize.cy = 0) or (buttons.height = 0) then begin
   size1:= asize;
   if fframe <> nil then begin
    size1.cx:= size1.cx - fframe.framei_left - fframe.framei_right;
    size1.cy:= size1.cy - fframe.framei_top - fframe.framei_bottom;
   end;
   checkvert(size1);
   if vert then begin
    defaultsize.cx:= buttonsize.cx;
    defaultsize.cy:= 0;
    for int1:= 0 to buttons.count - 1 do begin
     with buttons[int1] do begin
      if not (as_invisible in state) then begin
       if mao_separator in options then begin
        inc(defaultsize.cy,separatorwidth);
       end
       else begin
        inc(defaultsize.cy,buttonsize.cy);
       end;
      end;
     end;
    end;
   end
   else begin
    defaultsize.cy:= buttonsize.cy;
    defaultsize.cx:= 0;
    for int1:= 0 to buttons.count - 1 do begin
     with buttons[int1] do begin
      if not (as_invisible in state) then begin
       if mao_separator in options then begin
        inc(defaultsize.cx,separatorwidth);
       end
       else begin
        inc(defaultsize.cx,buttonsize.cx);
       end;
      end;
     end;
    end;
   end;
   if fframe <> nil then begin
    defaultsize.cx:= defaultsize.cx + fframe.framei_left + fframe.framei_right;
    defaultsize.cy:= defaultsize.cy + fframe.framei_top + fframe.framei_bottom;
   end;
  end;
  asize:= defaultsize;
 end;
end;

procedure tcustomtoolbar.updatelayout;
var
 int1,int2,int3: integer;
 rect1,rect2: rectty;
 endxy: integer;
 buttonsizecxy: integer;
// bu1: stepbuttonposty;
 loopcount: integer;
 size1: sizety; 
begin
 if fupdating <> 0 then begin
  flayoutok:= false;
 end
 else begin
  inc(fupdating);
  try
   loopcount:= 0;
   tcustomstepframe1(fframe).neededbuttons:= [];
   repeat
    flayoutok:= true;
    rect1:= innerclientrect;
    rect2:= rect1;
    inc(loopcount);
    with flayout do begin
     defaultsize:= nullsize;
     checkvert(rect1.size);
//     bu1:= frame.buttonpos;
     if frame.buttonpos in [sbp_top,sbp_right] then begin
      if vert then begin
       frame.buttonpos:= sbp_top;
      end
      else begin
       frame.buttonpos:= sbp_right;
      end;
     end
     else begin
      if vert then begin
       frame.buttonpos:= sbp_bottom;
      end
      else begin
       frame.buttonpos:= sbp_left;
      end;
     end;
     rect1.size:= buttonsize;
     if vert then begin
      if rect1.cx > 0 then begin
       lines:= rect2.cx div rect1.cx;
       if lines <= 0 then begin
        lines:= 1;
       end;
      end
      else begin
       lines:= 1;
      end;
     end
     else begin
      if rect1.cy > 0 then begin
       lines:= rect2.cy div rect1.cy;
       if lines <= 0 then begin
        lines:= 1;
       end;
      end
      else begin
       lines:= 1;
      end;
     end;
  
     cells:= nil; //finalize
     setlength(cells,buttons.count); //max
     if vert then begin
      endxy:= rect2.y + rect2.cy;
     end
     else begin
      endxy:= rect2.x + rect2.cx;
     end;
     if vert then begin
      buttonsizecxy:= rect1.cy;
     end
     else begin
      buttonsizecxy:= rect1.cx;
     end;
     int3:= lines - 1;
     with stepinfo do begin
      pagelast:= buttons.count;
      pageup:= stepinfo.pagelast;
      up:= 0;
      if ffirstbutton >= pagelast then begin
       ffirstbutton:= 0; //count changed
      end;
      for int1:= ffirstbutton to pagelast - 1 do begin
       with cells[int1] do begin
        color:= cl_parent;
        actioninfotoshapeinfo(buttons[int1].finfo,cells[int1]);
        include(state,shs_flat);
        if state * [shs_checkbox,shs_radiobutton] <> [] then begin
         include(state,shs_checkbutton);
        end;
        doexecute:= {$ifdef FPC}@{$endif}buttons[int1].doexecute;
        if not (as_invisible in buttons[int1].state) then begin
         if mao_separator in buttons[int1].options then begin
          if vert then begin
           rect1.cy:= separatorwidth;
          end
          else begin
           rect1.cx:= separatorwidth;
          end;
         end
         else begin
          if vert then begin
           rect1.cy:= buttonsizecxy;
          end
          else begin
           rect1.cx:= buttonsizecxy;
          end;
          if up = 0 then begin
           up:= int1 - ffirstbutton;
          end;
         end;
         if vert and (rect1.y + rect1.cy > endxy) or
             not vert and (rect1.x + rect1.cx > endxy) then begin
          if stepinfo.pageup = buttons.count then begin //first loop
           pageup:= int1;
          end;
          if (int3 > 0) then begin
           dec(int3);
           if vert then begin
            inc(rect1.x,rect1.cx);
            rect1.y:= rect2.y;
           end
           else begin
            inc(rect1.y,rect1.cy);
            rect1.x:= rect2.x;
           end;
          end
          else begin
           pagelast:= int1;
           break;
          end;
         end;
         ca.dim:= rect1;
         if vert then begin
          inc(rect1.y,rect1.cy);
         end
         else begin
          inc(rect1.x,rect1.cx);
         end;
        end
        else begin
         include(state,shs_invisible);
        end;
       end;
      end;
      pagedown:= 0;
      down:= 0;
      if vert then begin
       int2:= rect2.cy;
      end
      else begin
       int2:= rect2.cx;
      end;
      for int1:= ffirstbutton - 1 downto 0 do begin
       if not (as_invisible in buttons[int1].state)then begin
        if mao_separator in buttons[int1].options then begin
         dec(int2,separatorwidth);
        end
        else begin
         if vert then begin
          dec(int2,buttons.height);
         end
         else begin
          dec(int2,buttons.fwidth);
         end;
         if down = 0 then begin
          down:= int1 - ffirstbutton;
         end;
        end;
        if int2 < 0 then begin
         pagedown:= int1 + 1;
         break;
        end;
       end;
      end;
      pagelast:= pagelast - ffirstbutton;
      pageup:= pageup - ffirstbutton;
      pagedown:= pagedown - ffirstbutton;
      if up = 0 then begin
       up:= 1;
      end;
      if down = 0 then begin
       down:= -1;
      end;
      frame.updatebuttonstate(ffirstbutton,pagelast,buttons.count);
     end;
     if flayoutok then begin
      size1:= self.size;
      checkautosize;
      if (size1.cx <> bounds_cx) or (size1.cy <> bounds_cy) then begin
       tcustomstepframe1(fframe).neededbuttons:= [];
                  //try again
      end;
     end;
    end;
   until flayoutok or (loopcount > 8);
   invalidate;
  finally
   dec(fupdating);
  end;
 end;
end;

class function tcustomtoolbar.classskininfo: skininfoty;
begin
 result:= inherited classskininfo;
 result.objectkind:= sok_toolbar;
end;

procedure tcustomtoolbar.buttonchanged(sender: tcustomtoolbutton);
var
 int1: integer;
 button1: tcustomtoolbutton;
 bo1: boolean;
begin
 with flayout do begin
  if sender.checked and (mao_radiobutton in sender.options) then begin
   for int1:= 0 to buttons.count -1 do begin
    button1:= buttons[int1];
    if (button1 <> sender) and (button1.checked) and 
         (button1.group = sender.group) then begin
     button1.checked:= false;
    end;
   end; 
  end;
  for int1:= 0 to buttons.count - 1 do begin
   button1:= buttons[int1];
   if int1 >= length(cells) then begin
    break;
   end;
   if button1 = sender then begin
    with cells[int1] do begin
     bo1:= (shs_invisible in state) xor (as_invisible in button1.finfo.state) or 
         ((shs_separator in state) xor (mao_separator in button1.options)) or
         ((shs_checkbox in state) xor (mao_checkbox in button1.options)) or
         ((shs_radiobutton in state) xor (mao_radiobutton in button1.options));
     actionstatestoshapestates(button1.finfo,state);
     ca.imagenr:= buttons[int1].finfo.imagenr;
     ca.colorglyph:= buttons[int1].finfo.colorglyph;
     color:= buttons[int1].finfo.color;
     ca.imagelist:= timagelist(buttons[int1].finfo.imagelist);
     doexecute:= {$ifdef FPC}@{$endif}buttons[int1].doexecute;
     invalidaterect(ca.dim);
     if bo1 then begin
      updatelayout;
     end;
    end;
    break;
   end;
  end;
 end;
 if canevent(tmethod(fonbuttonchanged)) then begin
  fonbuttonchanged(self,sender);
 end;
end;

procedure tcustomtoolbar.setbuttons(const Value: ttoolbuttons);
begin
 flayout.buttons.assign(Value);
end;
{
procedure ttoolbar.setimagebase(const Value: integer);
begin
 if fimagebase <> value then begin
  fimagebase:= Value;
  invalidate;
 end;
end;

procedure ttoolbar.setimagelist(const Value: timagelist);
begin
 setcomponentvar(value,tmsecomponent(fimagelist));
 invalidate;
end;
}
procedure tcustomtoolbar.setoptions(const Value: toolbaroptionsty);
const
 mask: toolbaroptionsty = [tbo_nohorz,tbo_novert];
var
 valbefore: toolbaroptionsty;
begin
 if foptions <> value then begin
  valbefore:= foptions;
  foptions:= toolbaroptionsty(setsinglebit(
       {$ifdef FPC}longword{$else}byte{$endif}(value),
       {$ifdef FPC}longword{$else}byte{$endif}(foptions),
       {$ifdef FPC}longword{$else}byte{$endif}(mask)));
  if ({$ifdef FPC}longword{$else}byte{$endif}(valbefore) xor 
       {$ifdef FPC}longword{$else}byte{$endif}(foptions)) and 
       {$ifdef FPC}longword{$else}byte{$endif}(mask) <> 0 then begin
   updatelayout;
  end;
 end;
end;

procedure tcustomtoolbar.setfirstbutton(value: integer);
begin
 if value >= flayout.buttons.count - 1 then begin
  value:= flayout.buttons.count - 1;
 end;
 if value < 0 then begin
  value:= 0;
 end;
 if ffirstbutton <> value then begin
  ffirstbutton:= value;
  updatelayout;
 end;
end;

procedure tcustomtoolbar.buttonschanged(const sender: tarrayprop; const index: integer);
begin
 updatelayout;
end;

procedure tcustomtoolbar.clientrectchanged;
begin
 inherited;
 updatelayout;
end;

procedure tcustomtoolbar.dopaintforeground(const canvas: tcanvas);
begin
 inherited;
 drawtoolbuttons(canvas,flayout)
end;

function tcustomtoolbar.gethintpos(const aindex: integer): rectty;
begin
 result:= flayout.cells[aindex].ca.dim;
 inc(result.cy,12);
end;

function tcustomtoolbar.getbuttonhint(const aindex: integer): msestring;
begin
 with buttons[aindex] do begin
  result:= hint;
  if (tbo_shortcuthint in self.foptions) and (shortcut <> 0) then begin
   if result <> '' then begin
    result:= result + ' ';
   end;
   result:= result + '('+encodeshortcutname(shortcut)+')';
  end;
 end;
end;

procedure tcustomtoolbar.clientmouseevent(var info: mouseeventinfoty);
begin
 inherited;
 if not (csdesigning in componentstate) or 
                            (ws1_designactive in fwidgetstate1) then begin
  with flayout do begin
   if updatemouseshapestate(cells,info,self,flayout.focusedbutton) then begin
   end;
   checkbuttonhint(self,info,fhintedbutton,flayout.cells,
          {$ifdef FPC}@{$endif}getbuttonhint,{$ifdef FPC}@{$endif}gethintpos);
  end;
 end;
end;

procedure tcustomtoolbar.showhint(var info: hintinfoty);
begin
 inherited;
end;

function tcustomtoolbar.dostep(const event: stepkindty;
                  const adelta: real;ashiftstate: shiftstatesty): boolean;
begin
 result:= false;
 if frame.canstep then begin
  firstbutton:= frame.executestepevent(event,flayout.stepinfo,ffirstbutton);
  result:= true;
 end;
end;

procedure tcustomtoolbar.beginupdate;
begin
 inc(fupdating);
end;

procedure tcustomtoolbar.endupdate;
begin
 dec(fupdating);
 updatelayout;
end;
{
procedure tcustomtoolbar.setinvisiblebuttons(const Value: stepkindsty);
begin
 inherited;
 if not (csloading in componentstate) then begin
  updatelayout;
 end;
end;
}
function tcustomtoolbar.buttonatpos(const apos: pointty; const enabledonly: boolean = false): tcustomtoolbutton;
var
 int1: integer;
begin
 begin
  if enabledonly then begin
   int1:= findshapeatpos(flayout.cells,apos,[shs_invisible,shs_disabled]);
  end
  else begin
   int1:= findshapeatpos(flayout.cells,apos,[shs_invisible]);
  end;
  if int1 >= 0 then begin
   result:= flayout.buttons[int1];
  end
  else begin
   result:= nil;
  end;
 end;
end;

procedure tcustomtoolbar.dragevent(var info: draginfoty);
var
 button1: tcustomtoolbutton;

 function candest: boolean;
 begin
  with info do begin
   if (tbo_dragdest in foptions) and (dragobjectpo^.sender = self) and
     (dragobjectpo^ is tobjectdragobject) then begin
    button1:= buttonatpos(pos,tbo_dragdestenabledonly in foptions);
    result:= (button1 <> nil) and (tobjectdragobject(dragobjectpo).data <> button1);
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
     if (dragobjectpo^ = nil) and (tbo_dragsource in foptions) then begin
      button1:= buttonatpos(pos,tbo_dragsourceenabledonly in foptions);
      if button1 <> nil then begin
       tobjectdragobject.create(self,dragobjectpo^,fdragcontroller.pickpos,button1);
      end;
     end;
    end;
    dek_check: begin
     if candest then begin
      accept:= true;
     end
     else begin
      inherited;
     end;
    end;
    dek_drop: begin
     if candest then begin
      buttons.move(tcustomtoolbutton(tobjectdragobject(dragobjectpo^).data).index,button1.index);
     end
     else begin
      inherited;
     end;
    end;
   end;
  end;
 end;
 fdragcontroller.afterdragevent(info);
end;

procedure tcustomtoolbar.doshortcut(var info: keyeventinfoty; const sender: twidget);
var
 int1: integer;
begin
 for int1:= 0 to flayout.buttons.count - 1 do begin
  if es_processed in info.eventstate then begin
   exit;
  end;
  flayout.buttons[int1].doshortcut(info);
 end;
 inherited;
end;

function tcustomtoolbar.getstatvarname: msestring;
begin
 result:= fstatvarname;
end;

procedure tcustomtoolbar.setstatfile(const Value: tstatfile);
begin
 setstatfilevar(istatfile(self),value,fstatfile);
end;

procedure tcustomtoolbar.dostatread(const reader: tstatreader);
begin
 flayout.buttons.dostatread(reader);
end;

procedure tcustomtoolbar.dostatwrite(const writer: tstatwriter);
begin
 flayout.buttons.dostatwrite(writer);
end;

procedure tcustomtoolbar.statreading;
begin
 //dummy
end;

procedure tcustomtoolbar.statread;
begin
 //dummy
end;

procedure tcustomtoolbar.setdragcontroller(const Value: tdragcontroller);
begin
 fdragcontroller.Assign(Value);
end;

procedure tcustomtoolbar.objectchanged(const sender: tobject);
begin
 inherited;
 flayout.buttons.objectchanged(sender);
end;

function tcustomtoolbar.getstatpriority: integer;
begin
 result:= fstatpriority;
end;

{ tdocktoolbar }
{
constructor tdocktoolbar.create(aowner: tcomponent);
begin
 if fdragcontroller = nil then begin
  fdragcontroller:= tdockcontroller.create(idockcontroller(self));
 end;
 inherited;
end;

procedure tdocktoolbar.createframe;
begin
 tgripframe.create(iframe(self));
end;

function tdocktoolbar.getframe: tgripframe;
begin
 result:= tgripframe(inherited getframe);
end;

procedure tdocktoolbar.setframe(const avalue: tgripframe);
begin
 inherited setframe(avalue);
end;

function tdocktoolbar.getdrag: tdockcontroller;
begin
 result:= tdockcontroller(fdragcontroller);
end;

procedure tdocktoolbar.setdragcontroller(const avalue: tdockcontroller);
begin
 inherited setdragcontroller(avalue);
end;

function tdocktoolbar.checkdock(var info: draginfoty): boolean;
begin
 result:= true;
end;

function tdocktoolbar.gethandlerect: rectty;
begin
 if fframe = nil then begin
  result:= clientrect;
 end
 else begin
  result:= tgripframe(fframe).handlerect;
 end;
end;

function tdocktoolbar.gethidebuttonrect: rectty;
begin
 if fframe = nil then begin
  result:= nullrect;
 end
 else begin
  result:= tgripframe(fframe).hidebuttonrect;
 end;
end;

function tdocktoolbar.getplacementrect: rectty;
begin
 result:= innerpaintrect;
end;
 }

{ tcustomstockglyphtoolbutton }

constructor tcustomstockglyphtoolbutton.create(const aowner: tobject;
         const aprop: tindexpersistentarrayprop);
begin
 inherited;
 finfo.imagelist:= stockobjects.glyphs;
end;

function tcustomstockglyphtoolbutton.isimageliststored: boolean;
begin
 result:= inherited isimageliststored and 
              (finfo.imagelist <> stockobjects.glyphs);
end;

procedure tcustomstockglyphtoolbutton.setimagelist(const Value: timagelist);
begin
 if value = nil then begin
  inherited setimagelist(stockobjects.glyphs);
 end
 else begin
  inherited setimagelist(value);
 end; 
end;

{ tstockglyphtoolbuttons }

class function tstockglyphtoolbuttons.getbuttonclass: toolbuttonclassty;
begin
 result:= tstockglyphtoolbutton;
end;

end.
