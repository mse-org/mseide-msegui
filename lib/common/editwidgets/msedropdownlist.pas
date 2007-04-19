{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msedropdownlist;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
 
interface
uses
 mseclasses,mseedit,mseevent,mseguiglob,msegrids,msedatalist,msegui,
 mseinplaceedit,msearrayprops,classes,msegraphics,msedrawtext,msegraphutils,
 msetimer,mseforms,msetypes,msestrings,msestockobjects,msescrollbar,
 msekeyboard;

const
 defaultdropdowncoloptions = [co_fill,co_readonly,co_focusselect,co_mousemovefocus,co_rowselect];
 defaultdropdowncoltextflags = defaultcoltextflags + [tf_noselect];
 mouseautoscrollheight = 4;
 dropdownitemselectedevent = 345;

type

 tdropdowncol = class(tmsestringdatalist)
  private
   fwidth: integer;
   foptions: coloptionsty;
   flinewidth: integer;
   flinecolor: colorty;
   ftextflags: textflagsty;
   fcolorselect: colorty;
   ffontcolorselect: colorty;
   procedure setoptions(const Value: coloptionsty);
  protected
   fowner: tobject;
  public
   constructor create(const aowner: tobject); reintroduce;
  published
   property width: integer read fwidth write fwidth default griddefaultcolwidth;
   property options: coloptionsty read foptions write setoptions
                   default defaultdropdowncoloptions;
   property textflags: textflagsty read ftextflags write ftextflags default defaultdropdowncoltextflags;
   property linewidth: integer read flinewidth write flinewidth default 0;
   property linecolor: colorty read flinecolor write flinecolor default cl_gray;
   property colorselect: colorty read fcolorselect write fcolorselect default cl_default;
   property fontcolorselect: colorty read ffontcolorselect write ffontcolorselect default cl_default;
 end;

 dropdowncolclassty = class of tdropdowncol;
 
 tdropdowncols = class(townedpersistentarrayprop)
  private
   fupdating1: integer;
   fonitemchange: indexeventty;
   function getitems(const index: integer): tdropdowncol;
  protected
   fitemindex: integer;
   fkeyvalue: msestring;
   procedure createitem(const index: integer; var item: tpersistent); override;
   procedure itemchanged(sender: tdatalist; index: integer);
             //sender = nil -> col undefined
   function maxrowcount: integer;
   function getcolclass: dropdowncolclassty; virtual;
  public
   constructor create(const aowner: tobject); reintroduce;
   procedure beginupdate;
   procedure endupdate;
   procedure clear;
   function addrow(const aitems: array of msestring): integer; //returns itemindex
   property onitemchange: indexeventty read fonitemchange write fonitemchange;
   property items[const index: integer]: tdropdowncol read getitems; default;
 end;

 dropdowncolsclassty = class of tdropdowncols;
 
 idropdown = interface(inullinterface)
  function getwidget: twidget;
  function geteditor: tinplaceedit;
  function edited: boolean;
  procedure dobeforedropdown;
  procedure doafterclosedropdown;
  function setdropdowntext(const avalue: msestring; const docheckvalue: boolean;
           const canceled: boolean; const akey: keyty): boolean; //true if accepted
  procedure buttonaction(var action: buttonactionty; const buttonindex: integer);
 end;

 idropdownlist = interface(idropdown)
  function getdropdownitems: tdropdowncols;
              //nil -> dropdowncontroller.fdropdownitems
 end;

 idropdownwidget = interface(idropdown)
  function createdropdownwidget(const atext: msestring): twidget;
  function getdropdowntext(const awidget: twidget): msestring;
 end;

 idropdowncontroller = interface(inullinterface)
  function getwidget: twidget;
  procedure updatedropdownpos;
 end;

 idropdownlistcontroller = interface(idropdowncontroller)
  procedure dropdownactivated;
  procedure dropdowndeactivated;
  procedure itemselected(const index: integer; const akey: keyty);
  procedure dropdownkeydown(var info: keyeventinfoty);
 end;

 tdropdownstringcol = class(tstringcol)
  protected
   function createdatalist: tdatalist; override;
 public
   destructor destroy; override;
   constructor create(const agrid: tcustomgrid; 
                             const aowner: tgridarrayprop); override;
 end;

 dropdownlistoptionty = (dlo_casesensitive);
 dropdownlistoptionsty = set of dropdownlistoptionty;

 dropdownliststatety = (dls_firstmousemoved,dls_mousemoved,dls_scrollup{,dls_closing});
 dropdownliststatesty = set of dropdownliststatety;

 dropdowneditoptionty = (deo_selectonly,deo_forceselect,
                        deo_autodropdown,
                        deo_keydropdown,//shift down starts dropdown
                        deo_casesensitive,
                        deo_sorted,deo_disabled,deo_autosavehistory,
                        deo_cliphint);
 dropdowneditoptionsty = set of dropdowneditoptionty;

const
 defaultdropdownoptionsedit = [deo_keydropdown];
type
 tcustomdropdownlistcontroller = class;

 titemselectedevent = class(tcomponentevent)
  private
   frow: integer;
  public 
   constructor create(const dest: tmsecomponent; const arow: integer);
 end;
 
 tdropdownlist = class(tcustomstringgrid)
  private
   foptions1: dropdownlistoptionsty;
   fdropdownstate: dropdownliststatesty;
   ffirstmousepos: pointty;
   frepeater: tsimpletimer;
   ffiltertext: msestring;
   fselectedindex: integer;
   procedure canceldropdown;
   procedure killrepeater;
   procedure startrepeater(up: boolean);
   procedure setfiltertext(const Value: msestring); virtual;
   procedure itemselected(const index: integer; const akey: keyty);
  protected
   fcontroller: tcustomdropdownlistcontroller;
   procedure updatewindowinfo(var info: windowinfoty); override;
   procedure createdatacol(const index: integer; out item: tdatacol); override;
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure clientmouseevent(var info: mouseeventinfoty); override;
   procedure mouseevent(var info: mouseeventinfoty); override;
   procedure doactivate; override;
   procedure dodeactivate; override;
   procedure docellevent(var info: celleventinfoty); override;
   function getkeystring(const aindex: integer): msestring;
   function locate(const filter: msestring): boolean; virtual;
   procedure dorepeat(const sender: tobject);
   procedure initcols(const acols: tdropdowncols); virtual;
//   procedure release; override;
//   procedure componentevent(const event: tcomponentevent); override;
  public
   constructor create(const acontroller: tcustomdropdownlistcontroller;
                             acols: tdropdowncols); reintroduce;
   destructor destroy; override;
//   function canclose(const newfocus: twidget): boolean; override;
   procedure show(awidth: integer; arowcount: integer;
                var aitemindex: integer; afiltertext: msestring); reintroduce;
   property filtertext: msestring read ffiltertext write setfiltertext;
   property options: dropdownlistoptionsty read foptions1 write foptions1;
 end;

 tdropdownbutton = class(tstockglyphframebutton)
  public
   constructor create(aowner: tobject); override;
  published
   property imagenr default ord(stg_arrowdownsmall);
 end;
 
 tcustomdropdownbuttonframe = class(tcustombuttonframe)
  private
   factivebutton: integer;
   freadonly: boolean;
   procedure setactivebutton(const avalue: integer);
   procedure setreadonly(const Value: boolean);
   function getbutton: tdropdownbutton;
   procedure setbutton(const avalue: tdropdownbutton);
  protected
   function getbuttonclass: framebuttonclassty; override;
  public
   procedure updatedropdownoptions(const avalue: dropdowneditoptionsty);
   property activebutton: integer read factivebutton write setactivebutton default 0;
   property readonly: boolean read freadonly write setreadonly default false;
   property button: tdropdownbutton read getbutton write setbutton;
 end;

 dropdownbuttonframeclassty = class of tcustomdropdownbuttonframe;

 tdropdownbuttonframe = class(tcustomdropdownbuttonframe)
  published
   property button;
 end;

 tdropdownmultibuttonframe = class(tdropdownbuttonframe)
  published
   property buttons;
   property activebutton;
 end;

 tcustomdropdowncontroller = class(teventpersistent,ibutton,ievent,idropdowncontroller)
  private
   fdataselected: boolean;
   fselectkey: keyty;
  protected
   fintf: idropdown;
   foptions: dropdowneditoptionsty;
   fforcecaret: boolean;
   procedure applicationactivechanged(const avalue: boolean); virtual;
   function getbuttonframeclass: dropdownbuttonframeclassty; virtual;
   procedure updatedropdownpos;
   procedure objectevent(const sender: tobject; const event: objecteventty); override;
   procedure setoptions(const Value: dropdowneditoptionsty); virtual;
   function getdropdownwidget: twidget; virtual;
   function getwidget: twidget;
   procedure dobeforedropdown; virtual;
   procedure doafterclosedropdown; virtual;
   procedure internaldropdown; virtual;
   function setdropdowntext(const avalue: msestring; const docheckvalue: boolean;
                                const canceled: boolean; const akey: keyty): boolean;
             //true if selected
   function candropdown: boolean; virtual;
   procedure selectnone(const akey: keyty); virtual;
   //ibutton
   procedure buttonaction(var action: buttonactionty; const buttonindex: integer);
  public
   constructor create(const intf: idropdown); reintroduce;
   destructor destroy; override;
   procedure dropdown; virtual;
   procedure canceldropdown;
   procedure createframe; virtual;
   procedure dropdownactivated;
   procedure dropdowndeactivated;
   procedure dokeydown(var info: keyeventinfoty);
   procedure editnotification(var info: editnotificationinfoty); virtual;
   function dataselected: boolean;
   procedure updatereadonlystate;
   property options: dropdowneditoptionsty read foptions write setoptions
                 default defaultdropdownoptionsedit;
 end;

 tdropdowncontroller = class(tcustomdropdowncontroller)
  protected
   function getbuttonframeclass: dropdownbuttonframeclassty; override;
  published
   property options;
 end;

 tdropdownwidgetcontroller = class(tdropdowncontroller)
  private
   fbounds_cy: integer;
   fbounds_cx: integer;
  protected
   fdropdownwidget: twidget;
   procedure internaldropdown; override;
   procedure receiveevent(const event: tobjectevent); override;
   function getdropdownwidget: twidget; override;
  public
   constructor create(const intf: idropdownwidget);
   procedure editnotification(var info: editnotificationinfoty); override;
  published
   property bounds_cx: integer read fbounds_cx write fbounds_cx default 0;
                   //0 -> ownerwidget.bounds_cx
   property bounds_cy: integer read fbounds_cy write fbounds_cy default 0;
                   //0 -> dropdownwidget.bounds_cy

 end;

 tcustomdropdownlistcontroller = class(tcustomdropdowncontroller,idropdownlistcontroller)
  private
   fdropdownrowcount: integer;
   fdropdownitems: tdropdowncols;
   fwidth: integer;
   fvaluecol: integer;
   fdatarowlinewidth: integer;
   fdatarowlinecolor: colorty;
   fbuttonlength: integer;
   fbuttonminlength: integer;
   procedure setcols(const Value: tdropdowncols);
   function getitemindex: integer;
   procedure setitemindex(const Value: integer);
   procedure setvaluecol(const avalue: integer);
  protected
   fdropdownlist: tdropdownlist;
   fcols: tdropdowncols;
   procedure valuecolchanged; virtual;
   function getdropdownwidget: twidget; override;
   procedure itemchanged(sender: tdatalist; index: integer);
   function getdropdowncolsclass: dropdowncolsclassty; virtual;
   procedure selectnone(const akey: keyty); override;
   procedure clearitemindex; //sets fcols.fitemindex to -1, no events
   
   //idropdownlist
   procedure itemselected(const index: integer; const akey: keyty); virtual;
             //-2 -> no selection, -1 -> cancel
   procedure dropdownkeydown(var info: keyeventinfoty);

   procedure receiveevent(const event: tobjectevent); override;
   function createdropdownlist: tdropdownlist; virtual;
   procedure internaldropdown; override;
  public
   constructor create(const intf: idropdownlist);
   destructor destroy; override;
   procedure editnotification(var info: editnotificationinfoty); override;
   function valuelist: tmsestringdatalist;
   property cols: tdropdowncols read fcols write setcols;
   property valuecol: integer read fvaluecol write setvaluecol default 0;
   property itemindex: integer read getitemindex write setitemindex default -1;
   property dropdownrowcount: integer read fdropdownrowcount 
                          write fdropdownrowcount default 8;
   property width: integer read fwidth write fwidth default 0;
   property datarowlinewidth: integer read fdatarowlinewidth 
                          write fdatarowlinewidth default 0;
   property datarowlinecolor: colorty read fdatarowlinecolor 
                          write fdatarowlinecolor default defaultdatalinecolor;
   property buttonlength: integer read fbuttonlength write fbuttonlength default 0;
   property buttonminlength: integer read fbuttonminlength 
                    write fbuttonminlength default defaultbuttonminlength;
 end;

 tnocolsdropdownlistcontroller = class(tcustomdropdownlistcontroller)
  protected
   function getbuttonframeclass: dropdownbuttonframeclassty; override;
  published
   property options;
   property dropdownrowcount;
   property width;
   property datarowlinewidth;
   property datarowlinecolor;
   property buttonlength;
   property buttonminlength;
 end;

 tdropdownlistcontroller = class(tnocolsdropdownlistcontroller)
  published
   property cols;
   property valuecol;
   property itemindex;
 end;
 
 dropdownlistcontrollerclassty = class of tcustomdropdownlistcontroller;

 tmbdropdownlistcontroller = class(tdropdownlistcontroller)
  protected
   function getbuttonframeclass: dropdownbuttonframeclassty; override;
 end;


implementation
uses
 sysutils,msewidgets,mseeditglob,mseguiintf;

type
 twidget1 = class(twidget);
 tcustombuttonframe1 = class(tcustombuttonframe);
 tstringcol1 = class(tstringcol);
 tframebutton1 = class(tframebutton);

{ tdropdowncol }

constructor tdropdowncol.create(const aowner: tobject);
begin
 fowner:= aowner;
 fwidth:= griddefaultcolwidth;
 foptions:= defaultdropdowncoloptions;
 flinecolor:= cl_gray;
 ftextflags:= defaultdropdowncoltextflags;
 fcolorselect:= cl_default;
 ffontcolorselect:= cl_default;
 inherited create;
end;

procedure tdropdowncol.setoptions(const Value: coloptionsty);
begin
  foptions := Value + [co_focusselect];
end;

{ tdropdowncols }

constructor tdropdowncols.create(const aowner: tobject);
begin
 inherited create(aowner,nil);
 count:= 1;
end;

function tdropdowncols.getcolclass: dropdowncolclassty;
begin
 result:= tdropdowncol;
end;

procedure tdropdowncols.createitem(const index: integer; var item: tpersistent);
begin
 item:= getcolclass.create(fowner);
 with tdropdowncol(item) do begin
  onitemchange:= {$ifdef FPC}@{$endif}itemchanged;
//  if index = 0 then begin
//   foptions:= foptions + [co_fill];
//  end;
 end;
end;

function tdropdowncols.getitems(
  const index: integer): tdropdowncol;
begin
 result:= tdropdowncol(inherited getitems(index));
end;

procedure tdropdowncols.itemchanged(sender: tdatalist; index: integer);
begin
 if (fupdating1 = 0 ) and assigned(fonitemchange) then begin
  fonitemchange(sender,index);
 end;
end;

procedure tdropdowncols.beginupdate;
begin
 inc(fupdating1);
end;

procedure tdropdowncols.endupdate;
begin
 dec(fupdating1);
 if fupdating1 = 0 then begin
  itemchanged(nil,-1);
 end;
end;

procedure tdropdowncols.clear;
var
 int1: integer;
begin
 beginupdate;
 try
  for int1:= 0 to count - 1 do begin
   items[int1].count:= 0;
  end;
 finally
  endupdate;
 end;
end;

function tdropdowncols.addrow(const aitems: array of msestring): integer;
var
 int1: integer;
begin
 result:= maxrowcount;
 beginupdate;
 try
  for int1:= 0 to count - 1 do begin
   items[int1].count:= result + 1;
   if int1 < length(aitems) then begin
    items[int1][result]:= aitems[int1];
   end;
  end;
 finally
  endupdate;
 end;
end;

function tdropdowncols.maxrowcount: integer;
var
 int1,int2: integer;
begin
 result:= 0;
 for int1:= 0 to count - 1 do begin
  int2:= items[int1].count;
  if int2 > result then begin
   result:= int2;
  end;
 end;
end;

{ tcustomdropdownbuttonframe }

procedure tcustomdropdownbuttonframe.setactivebutton(const avalue: integer);
begin
 factivebutton := avalue;
end;

procedure tcustomdropdownbuttonframe.setreadonly(const Value: boolean);
begin
 if (freadonly <> value) and (factivebutton < buttons.count) then begin
  freadonly := Value;
  buttons[factivebutton].enabled:= not value;
 end;
end;

function tcustomdropdownbuttonframe.getbutton: tdropdownbutton;
begin
 result:= tdropdownbutton(buttons[factivebutton]);
end;

procedure tcustomdropdownbuttonframe.setbutton(const avalue: tdropdownbutton);
begin
 buttons[factivebutton].assign(avalue);
end;

function tcustomdropdownbuttonframe.getbuttonclass: framebuttonclassty;
begin
 result:= tdropdownbutton;
end;

procedure tcustomdropdownbuttonframe.updatedropdownoptions(const avalue: dropdowneditoptionsty);
begin
 buttons[factivebutton].visible:= not (deo_disabled in avalue);
end;

{ tcustomdropdowncontroller }

constructor tcustomdropdowncontroller.create(const intf: idropdown);
begin
 fintf:= intf;
 foptions:= defaultdropdownoptionsedit;
 inherited create;
 createframe;
end;

destructor tcustomdropdowncontroller.destroy;
begin
 application.unregisteronapplicationactivechanged(
           {$ifdef FPC}@{$endif}applicationactivechanged);
 getdropdownwidget.Free;
 inherited;
end;

function tcustomdropdowncontroller.getbuttonframeclass: dropdownbuttonframeclassty;
begin
 result:= tcustomdropdownbuttonframe;
end;

procedure tcustomdropdowncontroller.createframe;
var
 widget: twidget;
begin
 widget:= fintf.getwidget;
 if twidget1(widget).fframe = nil then begin
  getbuttonframeclass.create(widget,ibutton(self));
 end;
 with tcustomdropdownbuttonframe(twidget1(widget).fframe) do begin
  fbuttonintf:= ibutton(self);
  buttons.count:= 1;
  setactivebutton(0);
 end;
 updatereadonlystate;
end;

procedure tcustomdropdowncontroller.setoptions(const Value: dropdowneditoptionsty);
begin
 foptions := Value;
 tcustomdropdownbuttonframe(twidget1(fintf.getwidget).fframe).updatedropdownoptions(value);
end;

procedure tcustomdropdowncontroller.updatereadonlystate;
begin
 tcustomdropdownbuttonframe(twidget1(fintf.getwidget).fframe).readonly:=
                                not fintf.geteditor.canedit;
end;

function tcustomdropdowncontroller.candropdown: boolean;
begin
 result:= fintf.geteditor.canedit;
end;

procedure tcustomdropdowncontroller.internaldropdown;
begin
 //dummy
end;

procedure tcustomdropdowncontroller.dobeforedropdown;
begin
 fintf.dobeforedropdown;
end;

procedure tcustomdropdowncontroller.doafterclosedropdown;
begin
 fintf.doafterclosedropdown;
end;

procedure tcustomdropdowncontroller.dropdown;
begin
 if not (deo_disabled in foptions) and candropdown then begin
  dobeforedropdown;
  internaldropdown;
  application.postevent(tobjectevent.create(ek_dropdown,ievent(self)));
  fintf.getwidget.window.registermovenotification(ievent(self));
 end;
end;

procedure tcustomdropdowncontroller.canceldropdown;
begin
 if getdropdownwidget <> nil then begin
//  getdropdownwidget.release;
  getdropdownwidget.window.modalresult:= mr_cancel;
 end;
end;

procedure tcustomdropdowncontroller.buttonaction(var action: buttonactionty;
  const buttonindex: integer);
begin
 fintf.buttonaction(action,buttonindex);
 if buttonindex = tcustomdropdownbuttonframe(
           twidget1(fintf.getwidget).fframe).factivebutton then begin
  with fintf.getwidget do begin
   case action of
    ba_buttonpress: begin
     if canfocus then begin
      setfocus;
     end;
    end;
    ba_click: begin
     if focused then begin
      dropdown;
     end;
    end;
   end;
  end;
 end;
end;                                    

procedure tcustomdropdowncontroller.dokeydown(var info: keyeventinfoty);
begin
 with info do begin
  if (key = key_down) and (shiftstate = [ss_shift]) and
       (deo_keydropdown in foptions) and fintf.geteditor.canedit then begin
   exclude(eventstate,es_processed);
   dropdown;
   include(eventstate,es_processed);
  end;
 end;
end;

procedure tcustomdropdowncontroller.selectnone(const akey: keyty);
begin
 fdataselected:= true;
 fintf.setdropdowntext('',true,false,akey);
end;

procedure tcustomdropdowncontroller.editnotification(var info: editnotificationinfoty);
begin
 case info.action of
  ea_textedited: begin
   fdataselected:= false;
  end;
  ea_textentered: begin
   if (deo_selectonly in foptions) and not fdataselected and 
           fintf.edited then begin
    if not (deo_forceselect in foptions) and (fintf.geteditor.text = '') then begin
     info.action:= ea_none;
     selectnone(key_return);
    end
    else begin
     if candropdown then begin
      info.action:= ea_none;
      dropdown;
     end;
    end;
   end;
  end;
 end;
end;

procedure tcustomdropdowncontroller.updatedropdownpos;
var
 widget1: twidget;
 rect1: rectty;
begin
 widget1:= getdropdownwidget;
 if widget1 <> nil then begin
  rect1:= widget1.widgetrect;
  getdropdownpos(fintf.getwidget,rect1);
  widget1.widgetrect:= rect1;
 end;
end;

procedure tcustomdropdowncontroller.objectevent(const sender: tobject;
  const event: objecteventty);
begin
 if (event = oe_destroyed) and (sender = getdropdownwidget) then begin
  fintf.getwidget.window.unregistermovenotification(ievent(self));
  application.unregisteronapplicationactivechanged(
           {$ifdef FPC}@{$endif}applicationactivechanged);
 end;
 inherited;
 if (event = oe_changed) and (sender = fintf.getwidget.window) then begin
  updatedropdownpos;
 end;
end;

function tcustomdropdowncontroller.getwidget: twidget;
begin
 result:= fintf.getwidget;
end;

function tcustomdropdowncontroller.getdropdownwidget: twidget;
begin
 result:= nil;
end;

function tcustomdropdowncontroller.dataselected: boolean;
begin
 result:= fdataselected;
end;

function tcustomdropdowncontroller.setdropdowntext(const avalue: msestring;
                        const docheckvalue: boolean; const canceled: boolean;
                        const akey: keyty): boolean;
begin
 fdataselected:= fdataselected or docheckvalue;
 fdataselected:= fintf.setdropdowntext(avalue,docheckvalue,canceled,akey);
 result:= fdataselected;
end;

procedure tcustomdropdowncontroller.applicationactivechanged(const avalue: boolean);
var
 widget1: twidget;
begin
 if not avalue then begin
  widget1:= getdropdownwidget;
  if (widget1 <> nil) and not widget1.window.hastransientfor then begin
   canceldropdown;
  end;
//  getdropdownwidget.release;
 end;
end;

procedure tcustomdropdowncontroller.dropdownactivated;
begin
 if fforcecaret then begin
  fintf.geteditor.doactivate;
 end;
end;

procedure tcustomdropdowncontroller.dropdowndeactivated;
begin
 if fforcecaret then begin
  fintf.geteditor.dodeactivate;
 end;
end;

{ tdropdowncontroller }

function tdropdowncontroller.getbuttonframeclass: dropdownbuttonframeclassty;
begin
 result:= tdropdownbuttonframe;
end;

{ tdropdownwidgetcontroller }

constructor tdropdownwidgetcontroller.create(const intf: idropdownwidget);
begin
 inherited create(intf);
end;

procedure tdropdownwidgetcontroller.internaldropdown;
begin
 inherited;
 if fdropdownwidget = nil then begin
  setlinkedvar(idropdownwidget(fintf).createdropdownwidget(fintf.geteditor.text),
                  tmsecomponent(fdropdownwidget));
   
//  setlinkedcomponent(ievent(self),
//   idropdownwidget(fintf).createdropdownwidget(fintf.geteditor.text),
//            tmsecomponent(fdropdownwidget));
 end;
end;

function tdropdownwidgetcontroller.getdropdownwidget: twidget;
begin
 result:= fdropdownwidget;
end;

procedure tdropdownwidgetcontroller.receiveevent(const event: tobjectevent);
begin
 inherited;
 if event.kind = ek_dropdown then begin
  if fdropdownwidget <> nil then begin
   if fbounds_cx > 0 then begin
    fdropdownwidget.bounds_cx:= fbounds_cx;
   end
   else begin
    fdropdownwidget.bounds_cx:= fintf.getwidget.framesize.cx;
   end;
   if fbounds_cy > 0 then begin
    fdropdownwidget.bounds_cy:= fbounds_cy;
   end;
   updatedropdownpos;
   fdropdownwidget.window.winid; //update window.options
   if wo_popup in fdropdownwidget.window.options then begin
    application.registeronapplicationactivechanged(
            {$ifdef FPC}@{$endif}applicationactivechanged);
   end;
   if fforcecaret then begin
    fintf.geteditor.forcecaret:= true;
   end;
   try
    if fdropdownwidget.show(true,fintf.getwidget.window) = mr_ok then begin
     setdropdowntext(idropdownwidget(fintf).getdropdowntext(fdropdownwidget),
                                     true,false,fselectkey);
    end;
   finally
    fintf.geteditor.forcecaret:= false;
    doafterclosedropdown;
   end;
//   setlinkedvar(nil,tmsecomponent(fdropdownwidget));
//   freeandnil(fdropdownwidget);
   fdropdownwidget.Free;
   fdropdownwidget:= nil;
  end;
 end;
end;

procedure tdropdownwidgetcontroller.editnotification(
  var info: editnotificationinfoty);
begin
 inherited;
 case info.action of
  ea_textedited: begin
   if fdropdownwidget = nil then begin
    if (deo_autodropdown in foptions) and 
      ((fintf.geteditor.text <> '') or (deo_forceselect in foptions)) then begin
     dropdown;
    end;
   end;
  end;
 end;
end;

{ tcustomdropdownlistcontroller }

constructor tcustomdropdownlistcontroller.create(const intf: idropdownlist);
begin
 fforcecaret:= true;
 fcols:= getdropdowncolsclass.create(self);
 fcols.onitemchange:= {$ifdef FPC}@{$endif}itemchanged;
 fcols.fitemindex:= -1;
 fdropdownrowcount:= 8;
 fdatarowlinecolor:= defaultdatalinecolor;
 fbuttonminlength:= defaultbuttonminlength;
 inherited create(intf);
end;

destructor tcustomdropdownlistcontroller.destroy;
begin
 inherited;
 fcols.Free;
end;

function tcustomdropdownlistcontroller.getdropdowncolsclass: dropdowncolsclassty;
begin
 result:= tdropdowncols;
end;

procedure tcustomdropdownlistcontroller.editnotification(
                  var info: editnotificationinfoty);
begin
 inherited;
 case info.action of
  ea_textedited: begin
   if fdropdownlist <> nil then begin
    fdropdownlist.filtertext:= fintf.geteditor.text;
   end
   else begin
    if (deo_autodropdown in foptions) then begin
     if candropdown and ((fintf.geteditor.text <> '') or 
                           (deo_forceselect in foptions)) then begin
      dropdown;
     end;
    end
    else begin
     fcols.fitemindex:= -1;
    end;
   end;
  end;
 end;
end;

function tcustomdropdownlistcontroller.valuelist: tmsestringdatalist;
begin
 result:= fcols[fvaluecol];
end;

procedure tcustomdropdownlistcontroller.itemchanged(sender: tdatalist; index: integer);
begin
 if (deo_selectonly in foptions) and (index = fcols.fitemindex) and 
                           (index >= 0) then begin
  setdropdowntext(valuelist[index],false,false,key_none);
 end;
end;

function tcustomdropdownlistcontroller.createdropdownlist: tdropdownlist;
begin
 result:= tdropdownlist.create(self,fdropdownitems);
end;

procedure tcustomdropdownlistcontroller.receiveevent(const event: tobjectevent);
var
 int1,int2: integer;
 str1: msestring;
begin
 inherited;
 if event.kind = ek_dropdown then begin
  if fdropdownlist = nil then begin
   fdropdownitems:= idropdownlist(fintf).getdropdownitems;
   if fdropdownitems = nil then begin
    fdropdownitems:= fcols;
   end;
   setlinkedcomponent(ievent(self),createdropdownlist,tmsecomponent(fdropdownlist));
   try
    with fdropdownlist.frame.sbvert do begin
     buttonminlength:= fbuttonminlength;
     buttonlength:= fbuttonlength;
    end;
    application.registeronapplicationactivechanged(
            {$ifdef FPC}@{$endif}applicationactivechanged);
    fintf.geteditor.forcecaret:= true;
    try
     with fdropdownlist do begin
      if deo_casesensitive in self.foptions then begin
       options:= options + [dlo_casesensitive];
      end;
      if deo_sorted in self.foptions then begin
       sort;
      end;
      if fwidth = 0 then begin
       int1:= self.fintf.getwidget.framesize.cx;
      end
      else begin
       int1:= fwidth;
      end;
      str1:= self.fintf.geteditor.text;
      int2:= fdropdownitems.fitemindex;
      if (int2 >= 0) and
           ((fdropdownitems.fitemindex >= fdropdownitems[0].count) or 
                   (str1 <> fdropdownitems[0][int2])) then begin
       int2:= -1;
      end;
      fselectkey:= key_none;
      show(int1,fdropdownrowcount,int2,str1);
      self.itemselected(int2,fselectkey);
     end;
    finally
     fintf.geteditor.forcecaret:= false;
     doafterclosedropdown;
    end;
   finally
//    fdropdownlist.release;
    fdropdownlist.free;
//    fdropdownlist:= nil;
    freeandnil(fdropdownlist);
   end;
  end;
 end;
end;

function tcustomdropdownlistcontroller.getitemindex: integer;
begin
 result:= fcols.fitemindex;
end;

procedure tcustomdropdownlistcontroller.setitemindex(const Value: integer);
begin
 if (value >= valuelist.Count) or (value < 0) then begin
  fcols.fitemindex:= -1;
 end
 else begin
  fcols.fitemindex:= Value;
 end;
 if fcols.fitemindex < 0 then begin
  setdropdowntext('',false,false,key_none);
 end
 else begin
  setdropdowntext(valuelist[fcols.fitemindex],false,false,key_none);
 end;
end;

procedure tcustomdropdownlistcontroller.setcols(const Value: tdropdowncols);
begin
 fcols.assign(value);
end;

procedure tcustomdropdownlistcontroller.dropdownkeydown(var info: keyeventinfoty);
var
 editor1: tinplaceedit;
 str1: msestring;
 widget1: twidget;
begin
 editor1:= fintf.geteditor;
 editor1.dokeydown(info);
 with info do begin
  if not (es_processed in eventstate) and (shiftstate = []) then begin
   case key of
    key_right: begin
     with fdropdownlist do begin
      if (row >= 0) then begin
       str1:= tstringcol1(fdropdownlist[fvaluecol]).getrowtext(row);
       if length(str1) > editor1.curindex then begin
        editor1.text:= copy(str1,1,editor1.curindex+1);
        editor1.curindex:= editor1.curindex + 1;
        include(eventstate,es_processed);
       end;
      end;
     end;
    end;
   end;
  end;
 end;
end;

procedure tcustomdropdownlistcontroller.itemselected(const index: integer;
                                     const akey: keyty);
var
 int1: integer;
begin
 int1:= index;
 if deo_forceselect in foptions then begin
  if int1 < 0 then begin
   int1:= fcols.fitemindex;
  end;
 end
 else begin
  if int1 = -2 then begin //empty row selected
   int1:= -1;
   if deo_selectonly in foptions then begin
    fcols.fitemindex:= int1;
    fcols.fkeyvalue:= '';
    setdropdowntext('',true,false,akey);
   end
   else begin
    setdropdowntext(fintf.geteditor.text,true,false,akey);
   end;
  end
  else begin
   if (int1 < 0) and (deo_selectonly in foptions) then begin
    setdropdowntext(fintf.geteditor.text,false,true,akey);
                    //editor.undo
   end;
  end;
 end;
 if index <> -1 then begin
  fcols.fitemindex:= int1;
 end;
 if int1 >= 0 then begin
  fcols.fkeyvalue:= valuelist[int1];
  setdropdowntext(fcols.fkeyvalue,index <> - 1,index = -1,akey);
 end;
end;

function tcustomdropdownlistcontroller.getdropdownwidget: twidget;
begin
 result:= fdropdownlist;
end;

procedure tcustomdropdownlistcontroller.setvaluecol(const avalue: integer);
begin
 if fvaluecol <> avalue then begin
  fvaluecol:= avalue;
  valuecolchanged;
 end;
end;

procedure tcustomdropdownlistcontroller.valuecolchanged;
begin
 //dummy
end;

procedure tcustomdropdownlistcontroller.selectnone(const akey: keyty);
begin
 itemselected(-2,akey);
end;

procedure tcustomdropdownlistcontroller.clearitemindex;
begin
 fcols.fitemindex:= -1;
end;

procedure tcustomdropdownlistcontroller.internaldropdown;
begin
 inherited;
end;

{ tnocolsdropdownlistcontroller }

function tnocolsdropdownlistcontroller.getbuttonframeclass: dropdownbuttonframeclassty;
begin
 result:= tdropdownbuttonframe;
end;

{ tmbdropdownlistcontroller }

function tmbdropdownlistcontroller.getbuttonframeclass: dropdownbuttonframeclassty;
begin
 result:= tdropdownmultibuttonframe;
end;

{ tdropdownstringcol }

destructor tdropdownstringcol.destroy;
begin
 fdata:= nil;
 inherited;
end;

function tdropdownstringcol.createdatalist: tdatalist;
begin
 result:= nil;
end;

constructor tdropdownstringcol.create(const agrid: tcustomgrid;
                       const aowner: tgridarrayprop);
begin
 inherited;
 include(foptions,co_readonly);
end;

{ titemselectedevent }

constructor titemselectedevent.create(const dest: tmsecomponent; const arow: integer);
begin
 frow:= arow;
 inherited create(self);
end;

{ tdropdownlist }

constructor tdropdownlist.create(const acontroller: tcustomdropdownlistcontroller;
                       acols : tdropdowncols);
var
 aparent: twidget;
begin
 fcontroller:= acontroller;
 aparent:= fcontroller.getwidget;
 inherited create(nil);
 visible:= false;
 datarowlinewidth:= acontroller.fdatarowlinewidth;
 datarowlinecolor:= acontroller.fdatarowlinecolor;
 exclude(foptionsgrid,og_focuscellonenter);
 ffocusedcell.col:= 0;
 color:= cl_background;
 fdatacols.options:= fdatacols.options + [co_focusselect,co_readonly];
 font:= twidget1(aparent).getfont;
 frame.levelo:= 0;
 fframe.framewidth:= 1;
 fframe.colorframe:= cl_black;
 initcols(acols);
end;

destructor tdropdownlist.destroy;
begin
 killrepeater;
 inherited;
end;

procedure tdropdownlist.initcols(const acols: tdropdowncols);
var
 int1: integer;
 col1: tdropdowncol;
begin
 if acols.count > 0 then begin
  rowcount:= acols[0].count;
  fdatacols.count:= acols.count;
  for int1:= 0 to acols.count - 1 do begin
   if acols[int1].count <> frowcount then begin
    error(gre_differentrowcount);
   end;
   col1:= acols[int1];
   with tstringcol1(fdatacols[int1]) do begin
    fdata:= col1;
    options:= col1.foptions;
    optionsedit:= defaultstringcoleditoptions - [scoe_autoselect,scoe_autoselectonfirstclick];
    width:= col1.fwidth;
    linewidth:= col1.flinewidth;
    linecolor:= col1.flinecolor;
    textflags:= col1.ftextflags;
    textflagsactive:= col1.ftextflags;
    colorselect:= col1.fcolorselect;
    if col1.ffontcolorselect <> cl_default then begin
     createfontselect;
     fontselect.assign(getfont);
     fontselect.color:= col1.ffontcolorselect;
    end;
   end;
  end;
 end;
end;

procedure tdropdownlist.createdatacol(const index: integer;
  out item: tdatacol);
begin
 item:= tdropdownstringcol.create(self,fdatacols);
end;

procedure tdropdownlist.doactivate;
begin
 capturemouse;
 inherited;
 fcontroller.dropdownactivated;
end;

procedure tdropdownlist.dodeactivate;
begin
 inherited;
 fcontroller.dropdowndeactivated;
end;

procedure tdropdownlist.dokeydown(var info: keyeventinfoty);
begin
 with info do begin
   if shiftstate = [] then begin
    include(eventstate,es_processed);
    case key of
     key_return,key_tab: begin
      if ffocusedcell.row < 0 then begin
       itemselected(-2,key); //nil selection
      end
      else begin
       itemselected(ffocusedcell.row,key);
      end;
     end;
     key_up,key_down: begin
      if (focusedcell.row < 0) and (frowcount > 0) then begin
       if key = key_down then begin
        row:= 0;
       end
       else begin
        row:= rowcount -1;
       end;
      end
      else begin
       exclude(eventstate,es_processed);
      end;
     end;
     key_escape: begin
      canceldropdown;
      exit;
     end;
     else begin
      exclude(eventstate,es_processed);
     end;
    end;
   end;
   if not (es_processed in eventstate) then begin
    fcontroller.dropdownkeydown(info);
    if not (es_processed in eventstate) then begin
     inherited;
    end;
   end;
  end;
end;

procedure tdropdownlist.mouseevent(var info: mouseeventinfoty);
begin
 inherited;
 if (info.eventkind = ek_buttonpress) and
      not pointinrect(translatewidgetpoint(info.pos,self,nil),fwidgetrect) then begin
  canceldropdown;
 end;
end;

procedure tdropdownlist.show(awidth: integer; arowcount: integer;
                 var aitemindex: integer; afiltertext: msestring);
var
 rect1: rectty;
begin
 fstate:= fstate * [gs_isdb];
 bounds_cx:= awidth;
 rect1:= widgetrect;
 rect1.cx:= awidth;
 if arowcount > frowcount then begin
  arowcount:= frowcount;
 end;
 datarowheight:= font.lineheight;
 rect1.cy:= arowcount * ystep + fframe.paintframewidth.cy;
 widgetrect:= rect1;
 fcontroller.updatedropdownpos;
 ffiltertext:= afiltertext;
 if aitemindex = -1 then begin
  locate(ffiltertext);
 end
 else begin
  focuscell(makegridcoord(0,aitemindex));
 end;
 if inherited show(true,fcontroller.getwidget.window) = mr_ok then begin
  aitemindex:= fselectedindex;
 end
 else begin
  aitemindex:= -1;
 end;
end;

procedure tdropdownlist.updatewindowinfo(var info: windowinfoty);
begin
 inherited;
 with info do begin
  options:= options + [wo_popup];
  transientfor:= fcontroller.getwidget.window;
 end;
end;

procedure tdropdownlist.itemselected(const index: integer; const akey: keyty);
begin
 fselectedindex:= index;
 fcontroller.fselectkey:= akey;
 window.modalresult:= mr_ok;
end;

procedure tdropdownlist.docellevent(var info: celleventinfoty);
var
 hintinfo: hintinfoty;
begin
 with info do begin
  if iscellclick(info,[ccr_buttonpress]) then begin
   itemselected(cell.row,key_none);
  end
  else begin
   if (deo_cliphint in fcontroller.foptions) and 
           (eventkind = cek_firstmousepark) and
            textclipped(cell) then begin
    application.inithintinfo(hintinfo,self);
    hintinfo.caption:= self[cell.col][cell.row];
    application.showhint(self,hintinfo);
    include(mouseeventinfopo^.eventstate,es_processed);
   end
   else begin
    inherited;
   end;
  end;
 end;
end;

procedure tdropdownlist.canceldropdown;
begin
 itemselected(-1,key_none); //canceled
end;

procedure tdropdownlist.clientmouseevent(var info: mouseeventinfoty);
begin
 if info.eventkind = ek_mousemove then begin
  if dls_mousemoved in fdropdownstate then begin
   if (info.pos.y < mouseautoscrollheight) then begin
    startrepeater(false);
   end
   else begin
    if info.pos.y >= clientrect.cy - mouseautoscrollheight then begin
     startrepeater(true);
    end
    else begin
     killrepeater;
    end;
   end;
  end
  else begin
   if not (dls_firstmousemoved in fdropdownstate) then begin
    ffirstmousepos:= info.pos;
    include(fdropdownstate,dls_firstmousemoved);
   end
   else begin
    if distance(info.pos,ffirstmousepos) > 3 then begin
     include(fdropdownstate,dls_mousemoved);
    end;
   end;
  end;
 end
 else begin
  if info.eventkind = ek_clientmouseleave then begin
   killrepeater;
  end;
 end;
 inherited;
end;

function tdropdownlist.getkeystring(const aindex: integer): msestring;
begin
 with tstringcol(fdatacols[0]) do begin
  result:= items[aindex];
 end;
end;

function tdropdownlist.locate(const filter: msestring): boolean;
var
 int1: integer;
 opt1: locatestringoptionsty;
 co1: gridcoordty;
begin
 if (rowcount > 0) and (fdatacols.count > 0) then begin
  int1:= focusedcell.row;
  if dlo_casesensitive in foptions1 then begin
   opt1:= [lso_casesensitive];
  end
  else begin
   opt1:= [];
  end;
  result:= locatestring(filter,{$ifdef FPC}@{$endif}getkeystring,opt1,
                fdatacols[0].datalist.count,int1);
  if result then begin
   co1:= makegridcoord(ffocusedcell.col,int1);
   showcell(co1,cep_top);
   focuscell(co1);
  end
  else begin
   focuscell(makegridcoord(ffocusedcell.col,-1));
  end;
 end
 else begin
  result:= false;
 end;
end;

procedure tdropdownlist.setfiltertext(const Value: msestring);
begin
 ffiltertext := Value;
 locate(ffiltertext);
end;

procedure tdropdownlist.killrepeater;
begin
 freeandnil(frepeater);
end;

procedure tdropdownlist.startrepeater(up: boolean);
begin
 if frepeater = nil then begin
  frepeater:= tsimpletimer.create(100000,{$ifdef FPC}@{$endif}dorepeat,true);
 end;
 if up then begin
  include(fdropdownstate,dls_scrollup);
 end
 else begin
  exclude(fdropdownstate,dls_scrollup);
 end;
end;

procedure tdropdownlist.dorepeat(const sender: tobject);
begin
 if dls_scrollup in fdropdownstate then begin
  rowdown(fca_focusin);
 end
 else begin
  rowup(fca_focusin);
 end;
end;

{ tdropdownbutton }

constructor tdropdownbutton.create(aowner: tobject);
begin
 inherited;
 finfo.imagenr:= ord(stg_arrowdownsmall);
end;

end.
