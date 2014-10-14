{ MSEgui Copyright (c) 1999-2014 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msedropdownlist;

{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}
 
interface
uses
 mseclasses,mseedit,mseevent,mseglob,mseguiglob,msegrids,msedatalist,msegui,
 mseinplaceedit,msearrayprops,classes,mclasses,msegraphics,msedrawtext,
 msegraphutils,
 msetimer,mseforms,msetypes,msestrings,msestockobjects,msescrollbar,
 msekeyboard,msegridsglob,mseeditglob,msestat,msebitmap;

const
 defaultdropdowncoloptions = [co_fill,co_readonly,co_focusselect,
                                        co_mousemovefocus,co_rowselect];
 defaultdropdowncoltextflags = defaultcoltextflags + [tf_noselect];
 mouseautoscrollheight = 4;
 dropdownitemselectedevent = 345;

type

 dropdownlistoptionty = (dlo_casesensitive,dlo_posinsensitive,dlo_livefilter);
 dropdownlistoptionsty = set of dropdownlistoptionty;

 dropdownliststatety = (dls_firstmousemoved,dls_mousemoved,dls_scrollup);
 dropdownliststatesty = set of dropdownliststatety;

 dropdowneditoptionty = (deo_selectonly,deo_forceselect,
                        deo_autodropdown,
                        deo_keydropdown,//shift down starts dropdown
                        deo_modifiedbeforedropdown, 
                        //edit.modified called before dropdown
                        deo_casesensitive,deo_posinsensitive,deo_livefilter,
                        deo_sorted,deo_disabled,deo_autosavehistory,
                        deo_cliphint,deo_right,deo_colsizing,deo_savestate);
 dropdowneditoptionsty = set of dropdowneditoptionty;

const
 defaultdropdownoptionsedit = [deo_keydropdown];
type
 tcustomdropdownlistcontroller = class;

 tdropdowncolfont = class(tparentfont)
  public
   class function getinstancepo(owner: tobject): pfont; override;
 end;
 
 tdropdowncolfontselect = class(tparentfont)
  public
   class function getinstancepo(owner: tobject): pfont; override;
 end;

 tdropdowncol = class(tmsestringdatalist)
  private
   fwidth: integer;
   foptions: coloptionsty;
   flinewidth: integer;
   flinecolor: colorty;
   ftextflags: textflagsty;
   fcolor: colorty;
   fcolorselect: colorty;
//   ffontcolorselect: colorty;
   fcaption: msestring;
   fpasswordchar: msechar;
   ffont: tdropdowncolfont;
   ffontselect: tdropdowncolfontselect;
   procedure setoptions(const avalue: coloptionsty);
   function getfont: tdropdowncolfont;
   procedure setfont(const avalue: tdropdowncolfont);
   function getfontselect: tdropdowncolfontselect;
   procedure setfontselect(const avalue: tdropdowncolfontselect);
   procedure readfontcolorselect(reader: treader);
  protected
   fowner: tobject;
   procedure defineproperties(filer: tfiler); override;
  public
   constructor create(const aowner: tcustomdropdownlistcontroller); reintroduce;
   destructor destroy(); override;
   procedure createfont();
   procedure createfontselect();
  published
   property width: integer read fwidth write fwidth default griddefaultcolwidth;
   property options: coloptionsty read foptions write setoptions
                   default defaultdropdowncoloptions;
   property textflags: textflagsty read ftextflags write ftextflags 
                                           default defaultdropdowncoltextflags;
   property passwordchar: msechar read fpasswordchar write fpasswordchar 
                                           default #0;
   property linewidth: integer read flinewidth write flinewidth default 0;
   property linecolor: colorty read flinecolor write flinecolor default cl_gray;
   property color: colorty read fcolor write fcolor default cl_default;
   property colorselect: colorty read fcolorselect write fcolorselect 
                                           default cl_default;
//   property fontcolorselect: colorty read ffontcolorselect 
//                                      write ffontcolorselect default cl_default;
   property font: tdropdowncolfont read getfont write setfont;
   property fontselect: tdropdowncolfontselect read getfontselect 
                                                       write setfontselect;
   property caption: msestring read fcaption write fcaption;
 end;

 dropdowncolclassty = class of tdropdowncol;

 tdropdownfont = class(tparentfont)
  public
   class function getinstancepo(owner: tobject): pfont; override;
 end;

 tdropdownfontselect = class(tparentfont)
  public
   class function getinstancepo(owner: tobject): pfont; override;
 end;
 
 tdropdowncols = class(townedpersistentarrayprop)
  private
   fupdating1: integer;
   fonitemchange: indexeventty;
   fnostreaming: boolean;
//   maxrowcount: integer;
   fwidth: integer;
   foptions: coloptionsty;
   ftextflags: textflagsty;
   flinewidth: integer;
   flinecolor: colorty;
   fcolor: colorty;
   fcolorselect: colorty;
//   ffontcolorselect: colorty;
   ffont: tdropdownfont;
   ffontselect: tdropdownfontselect;
   function getitems(const index: integer): tdropdowncol;
   procedure setrowcount(const avalue: integer);
   procedure setnostreaming(const avalue: boolean);
   procedure setwidth(const avalue: integer);
   procedure setoptions(const avalue: coloptionsty);
   procedure settextflags(const avalue: textflagsty);
   procedure setlinewidth(const avalue: integer);
   procedure setlinecolor(const avalue: colorty);
   procedure setcolor(const avalue: colorty);
   procedure setcolorselect(const avalue: colorty);
//   procedure setfontcolorselect(const avalue: colorty);
   function getfont: tdropdownfont;
   procedure setfont(const avalue: tdropdownfont);
   function getfontselect: tdropdownfontselect;
   procedure setfontselect(const avalue: tdropdownfontselect);
   procedure readfontcolorselect(reader: treader);
  protected
   fitemindex: integer;
   fkeyvalue64: int64;
   fkeyvalue: msestring;
   procedure setcount1(acount: integer; doinit: boolean); override;
   procedure createitem(const index: integer; var item: tpersistent); override;
   procedure itemchanged(const sender: tdatalist; const index: integer);
             //sender = nil -> col undefined
   function maxrowcount: integer;
   function minrowcount: integer;
   function getcolclass: dropdowncolclassty; virtual;
   procedure checkrowindex(const aindex: integer);
   procedure defineproperties(filer: tfiler); override;
  public
   constructor create(const aowner: tcustomdropdownlistcontroller); reintroduce;
   destructor destroy(); override;
   class function getitemclasstype: persistentclassty; override;
   procedure createfont();
   procedure createfontselect();
   procedure beginupdate;
   procedure endupdate;
   procedure clear;
   function addrow(const aitems: array of msestring): integer; //returns itemindex
   procedure insertrow(const aindex: integer; const aitems: array of msestring);
   procedure deleterow(const aindex: integer);
   function getrow(const aindex: integer): msestringarty;
   property nostreaming: boolean read fnostreaming 
                                          write setnostreaming;
   property rowcount: integer read maxrowcount write setrowcount;
   property onitemchange: indexeventty read fonitemchange write fonitemchange;
   property items[const index: integer]: tdropdowncol read getitems; default;
  published
   property width: integer read fwidth write setwidth default griddefaultcolwidth;
   property options: coloptionsty read foptions write setoptions
                   default defaultdropdowncoloptions;
   property textflags: textflagsty read ftextflags write settextflags 
                                           default defaultdropdowncoltextflags;
   property linewidth: integer read flinewidth write setlinewidth default 0;
   property linecolor: colorty read flinecolor write setlinecolor default cl_gray;
   property color: colorty read fcolor write setcolor default cl_default;
   property colorselect: colorty read fcolorselect write setcolorselect 
                                           default cl_default;
//   property fontcolorselect: colorty read ffontcolorselect 
//                           write setfontcolorselect default cl_default;
   property font: tdropdownfont read getfont write setfont;
   property fontselect: tdropdownfontselect read getfontselect 
                                                       write setfontselect;
 end;

 dropdowncolsclassty = class of tdropdowncols;
 
 idropdown = interface(inullinterface)
  function getvalueempty: integer;
  function getwidget: twidget;
  function geteditor: tinplaceedit;
  function getedited: boolean;
  procedure modified;
  procedure dobeforedropdown;
  procedure doafterclosedropdown;
  function setdropdowntext(const avalue: msestring; const docheckvalue: boolean;
           const canceled: boolean; const akey: keyty): boolean; //true if accepted
  procedure buttonaction(var action: buttonactionty; const buttonindex: integer);
 end;

 idropdownlist = interface(idropdown)
  function getdropdownitems: tdropdowncols;
              //nil -> dropdowncontroller.fdropdownitems
  procedure imagelistchanged;
 end;

 idropdownwidget = interface(idropdown)
  procedure createdropdownwidget(const atext: msestring; out awidget: twidget);
  function getdropdowntext(const awidget: twidget): msestring;
 end;

 idropdowncontroller = interface(inullinterface)
  function getwidget: twidget;
  procedure updatedropdownpos(const arect: rectty);
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

 titemselectedevent = class(tcomponentevent)
  private
   frow: integer;
  public 
   constructor create(const dest: tmsecomponent; const arow: integer);
 end;
 
 tdropdownfixcol = class(tfixcol)
  protected
   fcontroller: tcustomdropdownlistcontroller;
  public
   constructor create(const agrid: tcustomgrid;
              const aowner: tgridarrayprop;
      const acontroller: tcustomdropdownlistcontroller); reintroduce; virtual;
 end;
 dropdownfixcolclassty = class of tdropdownfixcol;

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
   procedure itemselected(const index: integer; const akey: keyty);
  protected
   fcontroller: tcustomdropdownlistcontroller;
   fdropdownrowcount: integer;
   procedure setfiltertext(const Value: msestring); virtual;
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
   function updatevisiblerows(): integer; virtual;
                          //returns first visible row
   procedure dorepeat(const sender: tobject);
   procedure initcols(const acols: tdropdowncols); virtual;
   procedure updatelayout; override;
   function dropdownheight: integer; virtual;
   procedure setactiveitem(const aitemindex: integer); virtual;
  public
   constructor create(const acontroller: tcustomdropdownlistcontroller;
              const acols: tdropdowncols;
                   const afixcolclass: dropdownfixcolclassty); reintroduce;
   destructor destroy; override;
   procedure show(awidth: integer; const arowcount: integer;
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
   constructor create(const intf: icaptionframe;
                                         const buttonintf: ibutton); override;                                                  
   procedure updatedropdownoptions(const avalue: dropdowneditoptionsty);
   property activebutton: integer read factivebutton write setactivebutton 
                                                                    default 0;
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

 dropdowncontrollerstatety = (dcs_forcecaret,dcs_itemselecting,dcs_isstringkey);
 dropdowncontrollerstatesty = set of dropdowncontrollerstatety;

 tcustomdropdowncontroller = class(teventpersistent,ibutton,ievent,
                                   idropdowncontroller,idataeditcontroller)
  private
  protected
   fowner: twidget;
   fdataselected: boolean;
   fcolor: colorty;
   fcolorclient: colorty;
   fdropdowncount: integer;
   fselectkey: keyty;
   fintf: idropdown;
   foptions: dropdowneditoptionsty;
   fstate: dropdowncontrollerstatesty;
//   fforcecaret: boolean;
   procedure applicationactivechanged(const avalue: boolean); virtual;
   function getbuttonframeclass: dropdownbuttonframeclassty; virtual;
   procedure updatedropdownbounds(var arect: rectty); virtual;
   procedure updatedropdownpos(const arect: rectty);
   procedure objectevent(const sender: tobject;
                               const event: objecteventty); override;
   procedure setoptions(const Value: dropdowneditoptionsty); virtual;
   function getdropdownwidget: twidget; virtual;
   function getwidget: twidget;
   procedure dobeforedropdown; virtual;
   procedure doafterclosedropdown; virtual;
   procedure internaldropdown; virtual;
   function setdropdowntext(const avalue: msestring;
                         const docheckvalue: boolean; const canceled: boolean;
                                                   const akey: keyty): boolean;
             //true if selected
   function candropdown: boolean; virtual;
   procedure selectnone(const akey: keyty); virtual;
   function isloading: boolean;
   procedure resetselection; virtual;
   function componentstate: tcomponentstate;
    //ibutton
   procedure buttonaction(var action: buttonactionty;
                                                const buttonindex: integer);
   
    //idataeditcontroller
   procedure mouseevent(var info: mouseeventinfoty);
   procedure dokeydown(var info: keyeventinfoty);
   procedure internalcreateframe; virtual;
   procedure updatereadonlystate;
   procedure domousewheelevent(var info: mousewheeleventinfoty);
   procedure editnotification(var info: editnotificationinfoty); virtual;
  public
   constructor create(const intf: idropdown); reintroduce;
   destructor destroy; override;
   procedure dropdown; virtual;
   procedure canceldropdown;
   procedure dropdownactivated;
   procedure dropdowndeactivated;
   function dataselected: boolean;
   property options: dropdowneditoptionsty read foptions write setoptions
                 default defaultdropdownoptionsedit;
  published
   property color: colorty read fcolor write fcolor default cl_default;
   property colorclient: colorty read fcolorclient write fcolorclient
                                                       default cl_default;
 end;

 tdropdowncontroller = class(tcustomdropdowncontroller)
  protected
   function getbuttonframeclass: dropdownbuttonframeclassty; override;
  published
   property options;
 end;

 tdropdownwidgetcontroller = class(tdropdowncontroller)
  private
  protected
   fbounds_cy: integer;
   fbounds_cx: integer;
   fdropdownwidget: twidget;
   procedure internaldropdown; override;
   procedure updatedropdownbounds(var arect: rectty); override;
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

 tcustomdropdownlistcontroller = class(tcustomdropdowncontroller,
                                                      idropdownlistcontroller)
  private
   procedure setcols(const Value: tdropdowncols);
   function getitemindex: integer;
   procedure setitemindex(const Value: integer);
   procedure setvaluecol(const avalue: integer);
   procedure setimagelist(const avalue: timagelist);
   procedure imagelistchanged;
   procedure setimageframe(const avalue: framety);
   procedure setimageframe_left(const avalue: integer);
   procedure setimageframe_top(const avalue: integer);
   procedure setimageframe_right(const avalue: integer);
   procedure setimageframe_bottom(const avalue: integer);
   function getdelay: integer;
   procedure setdelay(avalue: integer);
  protected
   ftimer: tsimpletimer;
   fimagelist: timagelist;
   fimageframe: framety;
   fdropdownrowcount: integer;
   fwidth: integer;
   fvaluecol: integer;
   fdatarowlinewidth: integer;
   fdatarowlinecolor: colorty;
   fbuttonlength: integer;
   fbuttonendlength: integer;
   fbuttonminlength: integer;
   fdropdownitems: tdropdowncols;
   fdropdownlist: tdropdownlist;
   fcols: tdropdowncols;
   procedure dotimer(const sender: tobject);
   procedure objectevent(const sender: tobject;
                               const event: objecteventty); override;
   procedure valuecolchanged; virtual;
   function getdropdownwidget: twidget; override;
   procedure itemchanged(const sender: tdatalist; const index: integer);
   function getdropdowncolsclass: dropdowncolsclassty; virtual;
   procedure selectnone(const akey: keyty); override;
   procedure resetselection; override; //sets fcols.fitemindex to -1, no events
   function reloadlist: integer; virtual;
                            //returns first visible row
   function getremoterowcount: integer; virtual;
   procedure dobeforedropdown; override;
   procedure doafterclosedropdown; override;
   
    //idropdownlist
   procedure itemselected(const index: integer; const akey: keyty); virtual;
             //-2 -> no selection, -1 -> cancel
   procedure dropdownkeydown(var info: keyeventinfoty);
 
   function getautowidth: integer;
   procedure updatedropdownbounds(var arect: rectty); override;
   procedure receiveevent(const event: tobjectevent); override;
   function createdropdownlist: tdropdownlist; virtual;
   function getfixcolclass: dropdownfixcolclassty; virtual;
   procedure internaldropdown; override;
   procedure editnotification(var info: editnotificationinfoty); override;
  public
   constructor create(const intf: idropdownlist);
   destructor destroy; override;
   procedure dostatread(const reader: tstatreader);
   procedure dostatwrite(const writer: tstatwriter);
   function valuelist: tmsestringdatalist;
   property cols: tdropdowncols read fcols write setcols;
   property valuecol: integer read fvaluecol write setvaluecol default 0;
   property itemindex: integer read getitemindex write setitemindex default -1;
   property delay: integer read getdelay write setdelay default 0;
                     //ms, -1 = idle
   property dropdownrowcount: integer read fdropdownrowcount 
                          write fdropdownrowcount default 8;
   property width: integer read fwidth write fwidth default 0;
   property datarowlinewidth: integer read fdatarowlinewidth 
                          write fdatarowlinewidth default 0;
   property datarowlinecolor: colorty read fdatarowlinecolor 
                          write fdatarowlinecolor default defaultdatalinecolor;
   property buttonlength: integer read fbuttonlength 
                                      write fbuttonlength default 0;
   property buttonendlength: integer read fbuttonendlength 
                                      write fbuttonendlength default 0;
   property buttonminlength: integer read fbuttonminlength 
                    write fbuttonminlength default defaultbuttonminlength;
   property imagelist: timagelist read fimagelist write setimagelist;
   property imageframe: framety read fimageframe write setimageframe;
   property imageframe_left: integer read fimageframe.left 
                                         write setimageframe_left default 0;
   property imageframe_top: integer read fimageframe.top
                                         write setimageframe_top default 0;
   property imageframe_right: integer read fimageframe.right 
                                         write setimageframe_right default 0;
   property imageframe_bottom: integer read fimageframe.bottom 
                                         write setimageframe_bottom default 0;
 end;

 tnocolsdropdownlistcontroller = class(tcustomdropdownlistcontroller)
  protected
   function getbuttonframeclass: dropdownbuttonframeclassty; override;
  published
   property options;
   property dropdownrowcount;
   property delay;
   property width;
   property datarowlinewidth;
   property datarowlinecolor;
   property buttonlength;
   property buttonminlength;
   property buttonendlength;
 end;

 tdropdownlistcontroller = class(tnocolsdropdownlistcontroller)
  published
   property imagelist;
   property imageframe_left;
   property imageframe_top;
   property imageframe_right;
   property imageframe_bottom;
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
 sysutils,msewidgets,mseguiintf,rtlconsts,msebits;

type 
 timagefixcol = class(tdropdownfixcol)
  private
   fimagelist: timagelist;
   fimageframe: framety;
  protected
   procedure drawcell(const canvas: tcanvas); override;
  public
   constructor create(const agrid: tcustomgrid; const aowner: tgridarrayprop;
             const acontroller: tcustomdropdownlistcontroller); override;
 end;

 twidget1 = class(twidget);
 tcustombuttonframe1 = class(tcustombuttonframe);
 tstringcol1 = class(tstringcol);
 tframebutton1 = class(tframebutton);
 tdatacols1 = class(tdatacols);
 
const
 defaultdropdowncellinnerframe: framety = 
                      (left: 1; top: 0; right: 1; bottom: 0);
 
{ tdropdowncolfont }

class function tdropdowncolfont.getinstancepo(owner: tobject): pfont;
begin
 result:= @tdropdowncol(owner).ffont;
end;

{ tdropdowncolfontselect }

class function tdropdowncolfontselect.getinstancepo(owner: tobject): pfont;
begin
 result:= @tdropdowncol(owner).ffontselect;
end;

{ tdropdowncol }

constructor tdropdowncol.create(const aowner: tcustomdropdownlistcontroller);
begin
 fowner:= aowner;
 fwidth:= griddefaultcolwidth;
 foptions:= defaultdropdowncoloptions;
 flinecolor:= cl_gray;
 ftextflags:= defaultdropdowncoltextflags;
 fcolor:= cl_default;
 fcolorselect:= cl_default;
// ffontcolorselect:= cl_default;
 inherited create;
end;

destructor tdropdowncol.destroy;
begin
 inherited;
 ffont.free();
end;

procedure tdropdowncol.setoptions(const avalue: coloptionsty);
begin
 foptions:= avalue + [co_focusselect];
end;

procedure tdropdowncol.createfont;
begin
 if ffont = nil then begin
  ffont:= tdropdowncolfont.create();
 end;
end;

procedure tdropdowncol.createfontselect;
begin
 if ffontselect = nil then begin
  ffontselect:= tdropdowncolfontselect.create();
 end;
end;

function tdropdowncol.getfont: tdropdowncolfont;
begin
 if fowner <> nil then begin
  getoptionalobject(tcustomdropdownlistcontroller(fowner).componentstate,
                                                          ffont,@createfont);
 end;
 result:= ffont;
end;

procedure tdropdowncol.setfont(const avalue: tdropdowncolfont);
begin
 if fowner <> nil then begin
  if avalue <> ffont then begin
   setoptionalobject(tcustomdropdownlistcontroller(fowner).componentstate,avalue,
                                                             ffont,@createfont);
  end;
 end;
end;

function tdropdowncol.getfontselect: tdropdowncolfontselect;
begin
 if fowner <> nil then begin
  getoptionalobject(tcustomdropdownlistcontroller(fowner).componentstate,
                                                ffontselect,@createfontselect);
 end;
 result:= ffontselect;
end;

procedure tdropdowncol.setfontselect(const avalue: tdropdowncolfontselect);
begin
 if fowner <> nil then begin
  if avalue <> ffontselect then begin
   setoptionalobject(
   tcustomdropdownlistcontroller(fowner).componentstate,avalue,
                                                ffontselect,@createfontselect);
  end;
 end;
end;

procedure tdropdowncol.readfontcolorselect(reader: treader);
var
 co1: colorty;
begin
 co1:= reader.readinteger();
 if co1 <> cl_default then begin
  createfontselect();
  ffontselect.color:= co1;
 end;
end;

procedure tdropdowncol.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('fontcolorselect',@readfontcolorselect,nil,false);
end;

{ tdropdownfont }

class function tdropdownfont.getinstancepo(owner: tobject): pfont;
begin
 result:= @tdropdowncols(owner).ffont;
end;

{ tdropdownfontselect }

class function tdropdownfontselect.getinstancepo(owner: tobject): pfont;
begin
 result:= @tdropdowncols(owner).ffontselect;
end;

{ tdropdowncols }

constructor tdropdowncols.create(const aowner: tcustomdropdownlistcontroller);
begin
 fwidth:= griddefaultcolwidth;
 foptions:= defaultdropdowncoloptions;
 flinecolor:= cl_gray;
 ftextflags:= defaultdropdowncoltextflags;
 fcolor:= cl_default;
 fcolorselect:= cl_default;
// ffontcolorselect:= cl_default;

 inherited create(aowner,nil);
 count:= 1;
// items[0].options:= items[0].options + [co_fill];
end;

destructor tdropdowncols.destroy;
begin
 inherited;
 ffont.free();
 ffontselect.free();
end;

class function tdropdowncols.getitemclasstype: persistentclassty;
begin
 result:= tdropdowncol;
end;

function tdropdowncols.getcolclass: dropdowncolclassty;
begin
 result:= tdropdowncol;
end;

procedure tdropdowncols.createitem(const index: integer; var item: tpersistent);
begin
 item:= getcolclass.create(tcustomdropdownlistcontroller(fowner));
 with tdropdowncol(item) do begin
  onitemchange:= {$ifdef FPC}@{$endif}itemchanged;
  if fnostreaming then begin
   include(fstate,dls_nostreaming);
  end;
  fwidth:= self.fwidth;
  foptions:= self.foptions;
  ftextflags:= self.ftextflags;
  flinewidth:= self.flinewidth;
  flinecolor:= self.flinecolor;
  fcolor:= self.fcolor;
  fcolorselect:= self.fcolorselect;
//  ffontcolorselect:= self.ffontcolorselect;
 end;
end;

procedure tdropdowncols.createfont();
begin
 if ffont = nil then begin
  ffont:= tdropdownfont.create();
 end;
end;

procedure tdropdowncols.createfontselect();
begin
 if ffontselect = nil then begin
  ffontselect:= tdropdownfontselect.create();
 end;
end;

function tdropdowncols.getfont: tdropdownfont;
begin
 if fowner <> nil then begin
  getoptionalobject(tcustomdropdownlistcontroller(fowner).componentstate,
                                                          ffont,@createfont);
 end;
 result:= ffont;
end;

procedure tdropdowncols.setfont(const avalue: tdropdownfont);
begin
 if fowner <> nil then begin
  if avalue <> ffont then begin
   setoptionalobject(
           tcustomdropdownlistcontroller(fowner).componentstate,avalue,
                                                           ffont,@createfont);
  end;
 end;
end;

function tdropdowncols.getfontselect: tdropdownfontselect;
begin
 if fowner <> nil then begin
  getoptionalobject(tcustomdropdownlistcontroller(fowner).componentstate,
                                              ffontselect,@createfontselect);
 end;
 result:= ffontselect;
end;

procedure tdropdowncols.setfontselect(const avalue: tdropdownfontselect);
begin
 if fowner <> nil then begin
  if avalue <> ffontselect then begin
   setoptionalobject(
          tcustomdropdownlistcontroller(fowner).componentstate,avalue,
                                             ffontselect,@createfontselect);
  end;
 end;
end;

procedure tdropdowncols.setnostreaming(const avalue: boolean);
var
 int1: integer;
begin
 if fnostreaming <> avalue then begin
  fnostreaming:= avalue;
  if avalue then begin
   for int1:= 0 to count - 1 do begin
    include(tdropdowncol(items[int1]).fstate,dls_nostreaming);
   end;
  end
  else begin
   for int1:= 0 to count - 1 do begin
    exclude(tdropdowncol(items[int1]).fstate,dls_nostreaming);
   end;
  end;
 end;
end;

function tdropdowncols.getitems(
  const index: integer): tdropdowncol;
begin
 result:= tdropdowncol(inherited getitems(index));
end;

procedure tdropdowncols.itemchanged(const sender: tdatalist;
                                                     const index: integer);
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

function tdropdowncols.minrowcount: integer;
var
 int1,int2: integer;
begin
 if count > 0 then begin
  result:= bigint;
  for int1:= 0 to count - 1 do begin
   int2:= items[int1].count;
   if int2 < result then begin
    result:= int2;
   end;
  end;
 end
 else begin
  result:= 0;
 end;
end;

procedure tdropdowncols.setcount1(acount: integer; doinit: boolean);
begin
 if not (aps_destroying in fstate) and (fowner <> nil) and
    (acount <= tcustomdropdownlistcontroller(fowner).fvaluecol) then begin
  acount:= tcustomdropdownlistcontroller(fowner).fvaluecol + 1;
 end;
 inherited;
end;

function tdropdowncols.getrow(const aindex: integer): msestringarty;
var
 int1: integer;
begin
 if (aindex < 0) or (aindex >= minrowcount) then begin
  tlist.error({$ifndef fpc}@{$endif}slistindexerror, aindex);
 end;
 setlength(result,count);
 for int1:= 0 to high(fitems) do begin
  result[int1]:= pmsestring(tdropdowncol(fitems[int1]).fdatapo +
                                          aindex * sizeof(msestring))^;
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

procedure tdropdowncols.setrowcount(const avalue: integer);
var
 int1: integer;
begin
 for int1:= 0 to high(fitems) do begin
  tdropdowncol(fitems[int1]).count:= avalue;
 end;
end;

procedure tdropdowncols.checkrowindex(const aindex: integer);
begin
 if count = 0 then begin
  raise exception.create('No columns.');
 end;
 if (aindex < 0) or (aindex >= maxrowcount) then begin
  tlist.error(slistindexerror,aindex);
 end; 
end;

procedure tdropdowncols.insertrow(const aindex: integer;
               const aitems: array of msestring);
var
 int1,int2: integer;
begin
 int2:= maxrowcount;
 if aindex = int2 then begin
  addrow(aitems);
 end
 else begin
  checkrowindex(aindex);  
  beginupdate;
  try
   for int1:= 0 to count - 1 do begin
    with items[int1] do begin
     count:= int2;
     if int1 <= high(aitems) then begin
      insert(aindex,aitems[int1]);
     end
     else begin
      insert(aindex,'');
     end;
    end;
   end;
  finally
   endupdate;
  end;
 end;
end;

procedure tdropdowncols.deleterow(const aindex: integer);
var
 int1,int2: integer;
begin
 checkrowindex(aindex);
 int2:= maxrowcount;
 beginupdate;
 try
  for int1:= 0 to count - 1 do begin
   with items[int1] do begin
    count:= int2;
    deletedata(aindex);
   end;
  end;
 finally
  endupdate;
 end;
end;

procedure tdropdowncols.setwidth(const avalue: integer);
var
 int1: integer;
begin
 if fwidth <> avalue then begin
  fwidth:= avalue;
  if not tcustomdropdownlistcontroller(fowner).isloading then begin
   for int1:= 0 to count - 1 do begin
    tdropdowncol(fitems[int1]).width:= avalue;
   end;
  end;
 end;
end;

procedure tdropdowncols.setoptions(const avalue: coloptionsty);
var
 int1: integer;
 mask: longword;
begin
 if foptions <> avalue then begin
  mask:= longword(avalue) xor longword(foptions);
  foptions:= avalue;
  if not tcustomdropdownlistcontroller(fowner).isloading then begin
   for int1:= 0 to count - 1 do begin
    tdropdowncol(fitems[int1]).options:= 
                     coloptionsty(replacebits(longword(foptions),
                        longword(tdropdowncol(fitems[int1]).options),mask));
   end;
  end;
 end;
end;

procedure tdropdowncols.settextflags(const avalue: textflagsty);
var
 int1: integer;
 mask: longword;
begin
 if ftextflags <> avalue then begin
  mask:= longword(avalue) xor longword(ftextflags);
  ftextflags:= avalue;
  if not tcustomdropdownlistcontroller(fowner).isloading then begin
   for int1:= 0 to count - 1 do begin
    tdropdowncol(fitems[int1]).textflags:= 
                     textflagsty(replacebits(longword(ftextflags),
                        longword(tdropdowncol(fitems[int1]).textflags),mask));
   end;
  end;
 end;
end;

procedure tdropdowncols.setlinewidth(const avalue: integer);
var
 int1: integer;
begin
 if fwidth <> avalue then begin
  flinewidth:= avalue;
  if not tcustomdropdownlistcontroller(fowner).isloading then begin
   for int1:= 0 to count - 1 do begin
    tdropdowncol(fitems[int1]).linewidth:= avalue;
   end;
  end;
 end;
end;

procedure tdropdowncols.setlinecolor(const avalue: colorty);
var
 int1: integer;
begin
 if flinecolor <> avalue then begin
  flinecolor:= avalue;
  if not tcustomdropdownlistcontroller(fowner).isloading then begin
   for int1:= 0 to count - 1 do begin
    tdropdowncol(fitems[int1]).linecolor:= avalue;
   end;
  end;
 end;
end;

procedure tdropdowncols.setcolor(const avalue: colorty);
var
 int1: integer;
begin
 if fcolor <> avalue then begin
  fcolor:= avalue;
  if not tcustomdropdownlistcontroller(fowner).isloading then begin
   for int1:= 0 to count - 1 do begin
    tdropdowncol(fitems[int1]).color:= avalue;
   end;
  end;
 end;
end;

procedure tdropdowncols.setcolorselect(const avalue: colorty);
var
 int1: integer;
begin
 if fcolorselect <> avalue then begin
  fcolorselect:= avalue;
  if not tcustomdropdownlistcontroller(fowner).isloading then begin
   for int1:= 0 to count - 1 do begin
    tdropdowncol(fitems[int1]).colorselect:= avalue;
   end;
  end;
 end;
end;

procedure tdropdowncols.readfontcolorselect(reader: treader);
var
 co1: colorty;
begin
 co1:= reader.readinteger();
 if co1 <> cl_default then begin
  createfontselect();
  ffontselect.color:= co1;
 end;
end;

procedure tdropdowncols.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('fontcolorselect',@readfontcolorselect,nil,false);
end;

{
procedure tdropdowncols.setfontcolorselect(const avalue: colorty);
var
 int1: integer;
begin
 if ffontcolorselect <> avalue then begin
  ffontcolorselect:= avalue;
  if not tcustomdropdownlistcontroller(fowner).isloading then begin
   for int1:= 0 to count - 1 do begin
    tdropdowncol(fitems[int1]).fontcolorselect:= avalue;
   end;
  end;
 end;
end;
}
{ tcustomdropdownbuttonframe }

constructor tcustomdropdownbuttonframe.create(const intf: icaptionframe;
               const buttonintf: ibutton);
begin
 inherited;
 buttons.count:= 1;
 setactivebutton(0);
end;

procedure tcustomdropdownbuttonframe.setactivebutton(const avalue: integer);
begin
 factivebutton:= avalue;
end;

procedure tcustomdropdownbuttonframe.setreadonly(const Value: boolean);
var
 int1: integer;
begin
 if (freadonly <> value) then begin
  freadonly:= Value;
  for int1:= 0 to buttons.count - 1 do begin
   buttons[int1].enabled:= not value;
  end;
 end;
{
 if (freadonly <> value) and (factivebutton < buttons.count) then begin
  freadonly:= Value;
  buttons[factivebutton].enabled:= not value;
 end;
}
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

procedure tcustomdropdownbuttonframe.updatedropdownoptions(
                                         const avalue: dropdowneditoptionsty);
begin
 buttons[factivebutton].visible:= not (deo_disabled in avalue);
end;

{ tcustomdropdowncontroller }

constructor tcustomdropdowncontroller.create(const intf: idropdown);
begin
 fintf:= intf;
 fowner:= intf.getwidget;
 foptions:= defaultdropdownoptionsedit;
 fcolor:= cl_default;
 fcolorclient:= cl_default;
 inherited create;
 internalcreateframe;
end;

destructor tcustomdropdowncontroller.destroy;
begin
 application.unregisteronapplicationactivechanged(
           {$ifdef FPC}@{$endif}applicationactivechanged);
 getdropdownwidget.Free;
 inherited;
end;

function tcustomdropdowncontroller.getbuttonframeclass: 
                                                  dropdownbuttonframeclassty;
begin
 result:= tcustomdropdownbuttonframe;
end;

procedure tcustomdropdowncontroller.internalcreateframe;
var
 widget: twidget;
begin
 widget:= fintf.getwidget;
 if twidget1(widget).fframe = nil then begin
  getbuttonframeclass.create(iscrollframe(widget),ibutton(self));
 end;
 updatereadonlystate;
end;

procedure tcustomdropdowncontroller.setoptions(
                                           const Value: dropdowneditoptionsty);
begin
 foptions := Value;
 tcustomdropdownbuttonframe(
                twidget1(fintf.getwidget).fframe).updatedropdownoptions(value);
end;

procedure tcustomdropdowncontroller.updatereadonlystate;
begin
 tcustomdropdownbuttonframe(twidget1(fintf.getwidget).fframe).readonly:=
                                not fintf.geteditor.canedit or not candropdown;
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
 if deo_modifiedbeforedropdown in foptions then begin
  fintf.modified;
 end;
end;

procedure tcustomdropdowncontroller.doafterclosedropdown;
begin
 fintf.doafterclosedropdown;
end;

procedure tcustomdropdowncontroller.dropdown;
begin
 if not (deo_disabled in foptions) and candropdown and 
                   (fdropdowncount = 0) then begin
  dobeforedropdown;
  internaldropdown;
  application.postevent(tobjectevent.create(ek_dropdown,ievent(self)));
  inc(fdropdowncount);
  fintf.getwidget.window.registermovenotification(ievent(self));
 end;
end;

procedure tcustomdropdowncontroller.canceldropdown;
var
 widget1: twidget;
begin
 widget1:= getdropdownwidget;
 if widget1 <> nil then begin
  widget1.window.modalresult:= mr_cancel;
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

procedure tcustomdropdowncontroller.mouseevent(var info: mouseeventinfoty);
begin
 tcustombuttonframe( twidget1(fowner).fframe).mouseevent(info);
end;

procedure tcustomdropdowncontroller.dokeydown(var info: keyeventinfoty);
begin
 with info do begin
  if (key = key_down) and (shiftstate = [ss_alt]) and
       (deo_keydropdown in foptions) and fintf.geteditor.canedit then begin
   exclude(eventstate,es_processed);
   dropdown;
   include(eventstate,es_processed);
  end;
 end;
end;

procedure tcustomdropdowncontroller.domousewheelevent(
                              var info: mousewheeleventinfoty);
begin
 with info do begin
  if not (es_processed in info.eventstate) then begin
   if (wheel = mw_down) and fintf.getwidget.active then begin
    dropdown;
    include(info.eventstate,es_processed);
   end
   else begin
    if (wheel = mw_up) and (getdropdownwidget <> nil) then begin
     canceldropdown;
     include(info.eventstate,es_processed);
    end;
   end;
  end;
 end;
end;

procedure tcustomdropdowncontroller.selectnone(const akey: keyty);
begin
 fdataselected:= true;
 fintf.setdropdowntext('',true,false,akey);
end;

procedure tcustomdropdowncontroller.editnotification(
                                          var info: editnotificationinfoty);
begin
 case info.action of
  ea_textedited: begin
   fdataselected:= false;
  end;
  ea_textentered: begin
   if (deo_selectonly in foptions) and not fdataselected and 
           fintf.getedited then begin
    if not (deo_forceselect in foptions) and 
                                     (fintf.geteditor.text = '') then begin
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

procedure tcustomdropdowncontroller.updatedropdownbounds(var arect: rectty);
begin
 //dummy
end;

procedure tcustomdropdowncontroller.updatedropdownpos(const arect: rectty);
var
 widget1: twidget;
 rect1: rectty;
begin
 widget1:= getdropdownwidget;
 if widget1 <> nil then begin
  rect1:= arect; //widget1.widgetrect;
  updatedropdownbounds(rect1);
  getdropdownpos(fintf.getwidget,deo_right in foptions,rect1);
  widget1.widgetrect:= rect1;
 end;
end;

procedure tcustomdropdowncontroller.objectevent(const sender: tobject;
  const event: objecteventty);
begin
 if (event = oe_destroyed) and (sender = getdropdownwidget) then begin
  dec(fdropdowncount);
  fintf.getwidget.window.unregistermovenotification(ievent(self));
  application.unregisteronapplicationactivechanged(
           {$ifdef FPC}@{$endif}applicationactivechanged);
 end;
 inherited;
 if (event = oe_changed) and (sender = fintf.getwidget.window) and 
         (getdropdownwidget <> nil) then begin
  updatedropdownpos(getdropdownwidget.widgetrect);
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
 if dcs_forcecaret in fstate then begin
  fintf.geteditor.doactivate;
 end;
end;

procedure tcustomdropdowncontroller.dropdowndeactivated;
begin
 if dcs_forcecaret in fstate then begin
  fintf.geteditor.dodeactivate;
 end;
end;

function tcustomdropdowncontroller.isloading: boolean;
begin
 result:= csloading in fintf.getwidget.componentstate;
end;

procedure tcustomdropdowncontroller.resetselection;
begin
 //dummy
end;

function tcustomdropdowncontroller.componentstate: tcomponentstate;
begin
 result:= fintf.getwidget.componentstate;
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
var
 widget1: twidget;
begin
 inherited;
 if fdropdownwidget = nil then begin
  widget1:= nil;
  try
   idropdownwidget(fintf).createdropdownwidget(fintf.geteditor.text,widget1);
   setlinkedvar(widget1,tmsecomponent(fdropdownwidget));
  except
   if widget1 <> nil then begin
    widget1.release;
   end;
   raise;
  end;
 end;
 fdropdownwidget.name:= '_dropdownwidget'; //debug purposes
end;

function tdropdownwidgetcontroller.getdropdownwidget: twidget;
begin
 result:= fdropdownwidget;
end;

procedure tdropdownwidgetcontroller.updatedropdownbounds(var arect: rectty);
begin
 if fbounds_cx > 0 then begin
  arect.cx:= fbounds_cx;
 end
 else begin
  arect.cx:= fintf.getwidget.framesize.cx;
 end;
 if fbounds_cy > 0 then begin
  arect.cy:= fbounds_cy;
 end;
end;

procedure tdropdownwidgetcontroller.receiveevent(const event: tobjectevent);
begin
 inherited;
 if event.kind = ek_dropdown then begin
  if fdropdownwidget <> nil then begin
  {
   if fbounds_cx > 0 then begin
    fdropdownwidget.bounds_cx:= fbounds_cx;
   end
   else begin
    fdropdownwidget.bounds_cx:= fintf.getwidget.framesize.cx;
   end;
   if fbounds_cy > 0 then begin
    fdropdownwidget.bounds_cy:= fbounds_cy;
   end;
   }
   updatedropdownpos(fdropdownwidget.widgetrect);
   fdropdownwidget.window.winid; //update window.options
   if fdropdownwidget.window.ispopup then begin
    application.registeronapplicationactivechanged(
            {$ifdef FPC}@{$endif}applicationactivechanged);
   end;
   if dcs_forcecaret in fstate then begin
    fintf.geteditor.forcecaret:= true;
   end;
   try
    if fdropdownwidget.show(true,fintf.getwidget.window) = mr_ok then begin
     fintf.geteditor.forcecaret:= false;
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
 include(fstate,dcs_forcecaret);
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
 freeandnil(ftimer);
 inherited;
 fcols.Free;
end;

function tcustomdropdownlistcontroller.getdropdowncolsclass: dropdowncolsclassty;
begin
 result:= tdropdowncols;
end;

procedure tcustomdropdownlistcontroller.dotimer(const sender: tobject);
begin
 if fdropdownlist <> nil then begin
  if not (dcs_itemselecting in fstate) then begin
   fdropdownlist.filtertext:= fintf.geteditor.text;
  end;
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

procedure tcustomdropdownlistcontroller.editnotification(
                                        var info: editnotificationinfoty);
begin
 inherited;
 case info.action of
  ea_textedited: begin
   if ftimer = nil then begin
    dotimer(nil);
   end
   else begin
    ftimer.restart;
   end;
  end;
 end;
end;

function tcustomdropdownlistcontroller.valuelist: tmsestringdatalist;
begin
 result:= fcols[fvaluecol];
end;

procedure tcustomdropdownlistcontroller.itemchanged(
               const sender: tdatalist; const index: integer);
begin
 if (deo_selectonly in foptions) and (index = fcols.fitemindex) and 
                           (index >= 0) then begin
  setdropdowntext(valuelist[index],false,false,key_none);
 end;
end;

function tcustomdropdownlistcontroller.createdropdownlist: tdropdownlist;
begin
 result:= tdropdownlist.create(self,fdropdownitems,getfixcolclass);
 result.name:= '_dropdownlist'; //debug purposes
end;

procedure tcustomdropdownlistcontroller.updatedropdownbounds(var arect: rectty);
begin
 if fwidth = 0 then begin
  arect.cx:= fintf.getwidget.framesize.cx;
 end
 else begin
  if fwidth = -1 then begin
   arect.cx:= getautowidth;
  end
  else begin
   arect.cx:= fwidth;
  end;
 end;
end;

function tcustomdropdownlistcontroller.getautowidth: integer;
var
 int1: integer;
begin
 result:= 0;
 if fdropdownlist = nil then begin
  for int1:= 0 to high(fcols.fitems) do begin
   with tdropdowncol(fcols.fitems[int1]) do begin
    if not (co_invisible in foptions) then begin
     result:= result+fwidth+flinewidth;
    end;
   end;
  end;
 end
 else begin
  for int1:= 0 to fdropdownlist.datacols.count -1 do begin
   with tdatacol(tdatacols1(fdropdownlist.fdatacols).fitems[int1]) do begin
    if not (co_invisible in options) then begin
     result:= result+width+linewidth;
    end;
   end;
  end;
  result:= result + fdropdownlist.framedim.cx;
 end;
end;

procedure tcustomdropdownlistcontroller.receiveevent(const event: tobjectevent);
var
 int1,int2{,int3,int4}: integer;
// rect1: rectty;
 str1: msestring;
 widget1: twidget;
begin
 inherited;
 if event.kind = ek_dropdown then begin
  if fdropdownlist = nil then begin
   fdropdownitems:= idropdownlist(fintf).getdropdownitems;
   if fdropdownitems = nil then begin
    fdropdownitems:= fcols;
   end;
   setlinkedcomponent(ievent(self),createdropdownlist,
                                         tmsecomponent(fdropdownlist));
   fdropdownlist.name:= '_dropdownlist'; //debug purpose
   fdropdownlist.updateskin;
   try
    with fdropdownlist.frame.sbvert do begin
     buttonminlength:= fbuttonminlength;
     buttonlength:= fbuttonlength;
     buttonendlength:= fbuttonendlength;
    end;
    application.registeronapplicationactivechanged(
            {$ifdef FPC}@{$endif}applicationactivechanged);
    fintf.geteditor.forcecaret:= true;
    try
     widget1:= self.fintf.getwidget;
     with fdropdownlist do begin
      if deo_casesensitive in self.foptions then begin
       options:= options + [dlo_casesensitive];
      end;
      if deo_posinsensitive in self.foptions then begin
       options:= options + [dlo_posinsensitive];
      end;
      if deo_livefilter in self.foptions then begin
       options:= options + [dlo_livefilter];
      end;
      if deo_sorted in self.foptions then begin
       sort;
      end;
      if fwidth = 0 then begin
       int1:= widget1.framesize.cx;
      end
      else begin
       if fwidth = -1 then begin
        int1:= getautowidth;
       end
       else begin
        int1:= fwidth;
       end;
      end;
      str1:= self.fintf.geteditor.text;
      int2:= fdropdownitems.fitemindex;
      if (int2 >= 0) and
           ((fdropdownitems.fitemindex >= fdropdownitems[0].count) or 
                   (str1 <> fdropdownitems[0][int2])) then begin
       int2:= -1;
      end;
      fselectkey:= key_none;
      show(int1,self.fdropdownrowcount,int2,str1);
      fintf.geteditor.forcecaret:= false;
      include(self.fstate,dcs_itemselecting);
      self.itemselected(int2,fselectkey);
     end;
    finally
     exclude(self.fstate,dcs_itemselecting);
     fintf.geteditor.forcecaret:= false;
     doafterclosedropdown;
    end;
    if deo_colsizing in options then begin
     for int1:= 0 to high(fcols.fitems) do begin
      tdropdowncol(fcols.fitems[int1]).width:=
         tdatacol(tdatacols1(fdropdownlist.fdatacols).fitems[int1]).width;
     end;
    end;
   finally
    fdropdownlist.free;
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
  fcols.fkeyvalue:= '';
  setdropdowntext('',false,false,key_none);
 end
 else begin
  fcols.fkeyvalue:= valuelist[fcols.fitemindex];
  fdataselected:= true;
  setdropdowntext(fcols.fkeyvalue,false,false,key_none);
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
begin
 editor1:= fintf.geteditor;
 editor1.dokeydown(info);
 with info do begin
  if not (es_processed in eventstate) and (shiftstate*shiftstatesmask = []) then begin
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
   fcols.fitemindex:= int1;
   if deo_selectonly in foptions then begin
//    fcols.fitemindex:= int1;
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
  fcols.checkindex(avalue);
  fvaluecol:= avalue;
  valuecolchanged;
 end;
end;

procedure tcustomdropdownlistcontroller.objectevent(const sender: tobject;
               const event: objecteventty);
begin
 inherited;
 if (sender = fimagelist) then begin
  case event of
   oe_destroyed: begin
    fimagelist:= nil;
    imagelistchanged;
   end;
   oe_changed: begin
    imagelistchanged;
   end;
  end;
 end;
end;

procedure tcustomdropdownlistcontroller.setimagelist(const avalue: timagelist);
begin
 if fimagelist <> avalue then begin
  setlinkedvar(avalue,tmsecomponent(fimagelist));
  imagelistchanged;
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

procedure tcustomdropdownlistcontroller.resetselection;
begin
 fcols.fitemindex:= -1;
end;

function tcustomdropdownlistcontroller.reloadlist: integer;
begin
 result:= fdropdownlist.updatevisiblerows();
end;

function tcustomdropdownlistcontroller.getremoterowcount: integer;
begin
 result:= 0; //dummy
end;

procedure tcustomdropdownlistcontroller.internaldropdown;
begin
 inherited;
end;

procedure tcustomdropdownlistcontroller.dostatread(const reader: tstatreader);
var
 ar1: integerarty;
 int1: integer;
begin
 if deo_savestate in foptions then begin
  ar1:= reader.readarray('dropdowncolwidths',integerarty(nil));
  for int1:= 0 to high(ar1) do begin
   if int1 > high(fcols.fitems) then begin
    break;
   end;
   tdropdowncol(fcols.fitems[int1]).fwidth:= ar1[int1];
  end;
 end;
end;

procedure tcustomdropdownlistcontroller.dostatwrite(const writer: tstatwriter);
var
 int1: integer;
 ar1: integerarty;
begin
 if deo_savestate in foptions then begin
  setlength(ar1,fcols.count);
  for int1:= 0 to high(ar1) do begin
   ar1[int1]:= tdropdowncol(fcols.fitems[int1]).fwidth;
  end;
  writer.writearray('dropdowncolwidths',ar1);
 end;
end;

procedure tcustomdropdownlistcontroller.imagelistchanged;
begin
 idropdownlist(fintf).imagelistchanged;
end;

procedure tcustomdropdownlistcontroller.setimageframe(const avalue: framety);
begin
 fimageframe:= avalue;
 imagelistchanged; 
end;

procedure tcustomdropdownlistcontroller.setimageframe_left(const avalue: integer);
begin
 fimageframe.left:= avalue;
 imagelistchanged;
end;

procedure tcustomdropdownlistcontroller.setimageframe_top(const avalue: integer);
begin
 fimageframe.top:= avalue;
 imagelistchanged;
end;

procedure tcustomdropdownlistcontroller.setimageframe_right(const avalue: integer);
begin
 fimageframe.right:= avalue;
 imagelistchanged;
end;

procedure tcustomdropdownlistcontroller.setimageframe_bottom(const avalue: integer);
begin
 fimageframe.bottom:= avalue;
 imagelistchanged;
end;

function tcustomdropdownlistcontroller.getfixcolclass: dropdownfixcolclassty;
begin
 result:= nil; //dummy
end;

procedure tcustomdropdownlistcontroller.dobeforedropdown;
begin
 if deo_livefilter in foptions then begin
  with fintf.geteditor do begin
   if not canundo then begin
    text:= '';
   end;
  end;
 end;
 inherited;
end;

procedure tcustomdropdownlistcontroller.doafterclosedropdown;
begin
 if ftimer <> nil then begin
  ftimer.enabled:= false; //cancel pending updates
 end;
 inherited;
end;

function tcustomdropdownlistcontroller.getdelay: integer;
begin
 result:= 0;
 if ftimer <> nil then begin
  result:= ftimer.interval div 1000;
  if result = 0 then begin
   result:= -1;
  end;
 end;
end;

procedure tcustomdropdownlistcontroller.setdelay(avalue: integer);
begin
 if avalue = 0 then begin
  freeandnil(ftimer);
 end
 else begin
  if avalue < 0 then begin
   avalue:= 0;
  end;
  avalue:= avalue * 1000;
  if ftimer = nil then begin
   ftimer:= tsimpletimer.create(avalue,@dotimer,false,[to_single]);
  end;
  ftimer.interval:= avalue;
 end;
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

constructor tdropdownlist.create(
              const acontroller: tcustomdropdownlistcontroller;
              const acols : tdropdowncols;
              const afixcolclass: dropdownfixcolclassty);
var
 aparent: twidget;
 widget1: twidget;
 col1: colorty;
 int1: integer;
begin
 fcontroller:= acontroller;
 aparent:= fcontroller.getwidget;
 inherited create(nil);
 fdatacols.innerframe:= defaultdropdowncellinnerframe;
 visible:= false;
 beginupdate;
 try
  datarowlinewidth:= acontroller.fdatarowlinewidth;
  datarowlinecolor:= acontroller.fdatarowlinecolor;
  exclude(foptionsgrid,og_focuscellonenter);
  ffocusedcell.col:= 0;
  if fcontroller.color = cl_default then begin
   widget1:= aparent;
   repeat
    col1:= widget1.parentcolor;
    widget1:= widget1.parentwidget;
   until (col1 <> cl_transparent) or (widget1 = nil);
   if col1 = cl_transparent then begin
    col1:= cl_background;
   end;
   color:= col1;
  end
  else begin
   color:= fcontroller.color;
  end;
  if (fcontroller.colorclient <> cl_default) and (fframe <> nil) then begin
   fframe.colorclient:= fcontroller.colorclient;
  end;
  fdatacols.options:= fdatacols.options + [co_focusselect,co_readonly];
  font:= twidget1(aparent).getfont;
  frame.levelo:= 0;
  fframe.framewidth:= 1;
  fframe.colorframe:= cl_black;
  initcols(acols);
  if afixcolclass <> nil then begin
   ffixcols.add(afixcolclass.create(self,ffixcols,fcontroller));
  end;
  if acontroller.imagelist <> nil then begin
   ffixcols.add(timagefixcol.create(self,ffixcols,fcontroller));
   int1:= fcontroller.imagelist.height + fcontroller.fimageframe.top + 
                fcontroller.fimageframe.bottom;
   if datarowheight < int1 then begin
    datarowheight:= int1;
   end;
  end;
 finally
  endupdate;
 end;
end;

destructor tdropdownlist.destroy;
begin
 killrepeater;
 inherited;
end;

procedure tdropdownlist.initcols(const acols: tdropdowncols);
var
 int1,int2: integer;
 col1: tdropdowncol;
begin
 if acols.font <> nil then begin
  createfont();
  font.assign(acols.font);
 end;
 if acols.fontselect <> nil then begin
  fdatacols.createfontselect();
  datacols.fontselect.assign(acols.fontselect);
 end;
 if acols.count > 0 then begin
  if deo_colsizing in fcontroller.options then begin
   optionsgrid:= optionsgrid + [og_colsizing];
  end;
  rowcount:= acols[0].count;
  fdatacols.count:= acols.count;
  int2:= acols.maxrowcount;
  for int1:= 0 to acols.count - 1 do begin  
   col1:= acols[int1];
   col1.count:= int2;
   with tstringcol1(fdatacols[int1]) do begin
    fdata:= col1;
    options:= col1.foptions;
    optionsedit:= defaultstringcoleditoptions - [scoe_autoselect,scoe_autoselectonfirstclick];
    width:= col1.fwidth;
    linewidth:= col1.flinewidth;
    linecolor:= col1.flinecolor;
    textflags:= col1.ftextflags;
    passwordchar:= col1.passwordchar;
    textflagsactive:= col1.ftextflags;
    if col1.fcolor <> cl_default then begin
     color:= col1.fcolor;
    end;
    if col1.fcolorselect <> cl_default then begin
     colorselect:= col1.fcolorselect;
    end;
    {
    if col1.ffontcolorselect <> cl_default then begin
     createfontselect;
     fontselect.assign(getfont);
     fontselect.color:= col1.ffontcolorselect;
    end;
    }
    if col1.font <> nil then begin
     createfont();
     font.assign(col1.font);
    end;
    if col1.fontselect <> nil then begin
     createfontselect();
     fontselect.assign(col1.fontselect);
    end;
   end;
   if col1.caption <> '' then begin
    fixrows.count:= 1;
    with fixrows[-1] do begin
     captions.count:= int1 + 1;
     captions[int1].caption:= col1.caption;
    end;
   end;    
  end;
  synctofontheight;
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
     key_return,{key_enter,}key_tab: begin
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

procedure tdropdownlist.setactiveitem(const aitemindex: integer);
begin
 focuscell(makegridcoord(0,aitemindex));
end;

function tdropdownlist.dropdownheight: integer;
var
 int1,int2: integer;
begin
 int2:= fdatacols.rowstate.visiblerowcount;
 if fdropdownrowcount = 0 then begin
  int1:= int2;
 end
 else begin
  int1:= fdropdownrowcount;
 end;
 if (int1 > int2){ and not 
                      (deo_livefilter in fcontroller.foptions)} then begin
  int1:= int2;
 end;
 if int1 = 0 then begin
  result:= ystep div 2;
 end
 else begin
  result:= int1 * ystep;
 end;
 if fixrows.count > 0 then begin
  with fixrows[-1] do begin
   result:= result+ height + linewidth;
  end;
 end;
 result:= result + fframe.paintframedim.cy;
end;

procedure tdropdownlist.show(awidth: integer; const arowcount: integer;
                 var aitemindex: integer; afiltertext: msestring);
var
 rect1: rectty;
 int1: integer;
begin
 fstate:= fstate * [gs_isdb];
 bounds_cx:= awidth;
 rect1:= widgetrect;
 rect1.cx:= awidth;
 fdropdownrowcount:= arowcount;
// rect1.cy:= dropdownheight;
// fcontroller.updatedropdownpos(rect1);
 ffiltertext:= afiltertext;
 if deo_livefilter in fcontroller.foptions then begin
  int1:= updatevisiblerows();
  if afiltertext <> '' then begin
   setactiveitem(int1);
  end
  else begin
   setactiveitem(aitemindex);
  end;
 end
 else begin
  if (aitemindex = -1) and (ffiltertext <> '') then begin
   application.beginnoignorewaitevents;
   try
    locate(ffiltertext);
   finally
    application.endnoignorewaitevents;
   end;
  end
  else begin
   setactiveitem(aitemindex);
  end;
 end;
 rect1.cy:= dropdownheight;
 fcontroller.updatedropdownpos(rect1);
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
    hintinfo.caption:= tdropdownstringcol(self[cell.col]).getrowtext(cell.row);
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
   with fdatarecty do begin
    if (info.pos.y < y + mouseautoscrollheight) and (info.pos.y >= y) then begin
     startrepeater(false);
    end
    else begin
     if info.pos.y >= y + cy - mouseautoscrollheight then begin
      startrepeater(true);
     end
     else begin
      killrepeater;
     end;
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
  opt1:= [];
  if dlo_casesensitive in foptions1 then begin
   opt1:= [lso_casesensitive];
  end;
  if dlo_posinsensitive in foptions1 then begin
   include(opt1,lso_posinsensitive);
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

function tdropdownlist.updatevisiblerows(): integer;
var
 int1,int2,int3,count1: integer;
 opt1: locatestringoptionsty;
 bo1: boolean;
begin
 result:= invalidaxis;
 if (rowcount > 0) and (fdatacols.count > 0) then begin
  folded:= true;
  beginupdate;
  int1:= 0;
  opt1:= [lso_nodown];
  if dlo_casesensitive in foptions1 then begin
   include(opt1,lso_casesensitive);
  end;
  if dlo_posinsensitive in foptions1 then begin
   include(opt1,lso_posinsensitive);
  end;
  count1:= fdatacols[0].datalist.count;
  repeat
   int2:= int1;
   bo1:= locatestring(ffiltertext,{$ifdef FPC}@{$endif}getkeystring,opt1,
                                                                  count1,int1);
   if not bo1 then begin
    int1:= fdatacols[0].datalist.count;
   end;
   for int3:= int2 to int1 - 1 do begin
    rowhidden[int3]:= true;
   end;
   if bo1 then begin
    rowhidden[int1]:= false;
    if result = invalidaxis then begin
     result:= int1;
    end;
    inc(int1);
   end;
  until not bo1 or (int1 >= count1);
  endupdate;
 end;
end;

procedure tdropdownlist.setfiltertext(const Value: msestring);
var
 li1: tdatalist;
 rect1: rectty;
 int1: integer;
begin
 ffiltertext:= Value;
 if dlo_livefilter in foptions1 then begin
  int1:= fcontroller.reloadlist();
  if (fdatacols.count > 0) then begin
   li1:= tdropdownstringcol(fdatacols[0]).fdata;
   if li1 <> nil then begin
    rowcount:= li1.count;
   end;
  end;
  rect1:= widgetrect;
  rect1.cy:= dropdownheight;
  fcontroller.updatedropdownpos(rect1);
  invalidate;
  row:= int1;
  setupeditor(ffocusedcell,true);
 end
 else begin
  locate(ffiltertext);
 end;
end;

procedure tdropdownlist.killrepeater;
begin
 freeandnil(frepeater);
end;

procedure tdropdownlist.startrepeater(up: boolean);
begin
 if frepeater = nil then begin
  frepeater:= tsimpletimer.create(100000,{$ifdef FPC}@{$endif}dorepeat,true,[]);
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

procedure tdropdownlist.updatelayout;
var
 int1: integer;
begin
 inherited;
 if fcontroller.width = -1 then begin
  int1:= fcontroller.getautowidth;
  if width <> int1 then begin
   width:= int1;
   updatelayout;
  end;
 end;
end;

{ tdropdownbutton }

constructor tdropdownbutton.create(aowner: tobject);
begin
 inherited;
 finfo.ca.imagenr:= ord(stg_arrowdownsmall);
end;

{ tdropdownfixcol }

constructor tdropdownfixcol.create(const agrid: tcustomgrid;
               const aowner: tgridarrayprop;
               const acontroller: tcustomdropdownlistcontroller);
begin
 fcontroller:= acontroller;
 inherited create(agrid,aowner);
 linewidth:= 0;
 color:= acontroller.color;
end;

{ timagefixcol }

constructor timagefixcol.create(const agrid: tcustomgrid;
                                   const aowner: tgridarrayprop;
                            const acontroller: tcustomdropdownlistcontroller);
begin
 inherited create(agrid,aowner,acontroller);
 fimagelist:= acontroller.imagelist;
 fimageframe:= acontroller.imageframe;
 width:= fimagelist.width + acontroller.fimageframe.left +
                                      acontroller.fimageframe.right;
end;

procedure timagefixcol.drawcell(const canvas: tcanvas);
begin
 inherited;
 with cellinfoty(canvas.drawinfopo^) do begin
  fimagelist.paint(canvas,cell.row,deflaterect(rect,fimageframe),
                                                        [al_ycentered]);
 end; 
end;

end.
