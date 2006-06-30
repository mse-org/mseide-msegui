{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mselistbrowser;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 classes,msegrids,msedatanodes,msedatalist,msegraphics,msegraphutils,
      msetypes,msestrings,
      msebitmap,mseclasses,mseguiglob,msedrawtext,msefileutils,msedataedits,
      mseeditglob,msewidgetgrid,msewidgets,mseedit,mseevent,msegui,msedropdownlist,
      msesys,msedrag,msestat,mseinplaceedit,msepointer;

const
 defaultcellwidth = 50;
 defaultcellheight = 50;
 defaultcellwidthmin = 10;

type
 listviewoptionty = (lvo_readonly,lvo_mousemoving,lvo_keymoving,lvo_horz,
                     lvo_drawfocus,lvo_mousemovefocus,lvo_leftbuttonfocusonly,
                     lvo_focusselect,lvo_mouseselect,lvo_keyselect,
                     lvo_multiselect,lvo_resetselectonexit,
                     lvo_casesensitive,lvo_savevalue
                     );
 listviewoptionsty = set of listviewoptionty;
 filelistviewoptionty = (flvo_nodirselect,flvo_nofileselect);
 filelistviewoptionsty = set of filelistviewoptionty;

const
 defaultlistviewoptionsgrid = defaultoptionsgrid + [og_rotaterow,og_mousescrollcol];
 defaultlistviewoptions = [lvo_focusselect,lvo_mouseselect,lvo_drawfocus,
                           lvo_leftbuttonfocusonly];
 defaultfilelistviewoptions = [flvo_nodirselect];
 coloptionsmask: listviewoptionsty =
                    [lvo_readonly,{lvo_mousemoving,lvo_keymoving,lvo_horz,}
                     lvo_drawfocus,lvo_mousemovefocus,lvo_leftbuttonfocusonly,
                     lvo_focusselect,lvo_mouseselect,lvo_keyselect,
                     lvo_multiselect,lvo_resetselectonexit];
// lvo_coloptions = lvo_drawfocus;

type
 tcustomlistview = class;

 tlistedititem = class(tlistitem)
 end;

 ttreeitemeditlist = class;
 ttreelistedititem = class;
 treelistedititemclassty = class of ttreelistedititem;
 treelistedititemarty = array of ttreelistedititem;
 treelistedititematy = array[0..0] of ttreelistedititem;
 ptreelistedititematy = ^treelistedititematy;

 ttreelistedititem = class(ttreelistitem)
  private
   factiveindex: integer;
   function getactiveindex: integer;
  public
   constructor create(const aowner: tcustomitemlist = nil;
              const aparent: ttreelistitem = nil);
   procedure assign(source: ttreeitemeditlist); overload;
       //source remains owner of items, parent of items is unchanged
   procedure add(const aitem: ttreelistedititem); overload; //nil ignored
   procedure add(const aitems: treelistedititemarty); overload;
   procedure add(const acount: integer; itemclass: treelistedititemclassty = nil); overload;
   property activeindex: integer read getactiveindex;
 end;

 trecordtreelistedititem = class(ttreelistedititem,irecordfield)   //does not statsave subitems
  protected
   function getfieldtext(const fieldindex: integer): msestring;
   procedure setfieldtext(const fieldindex: integer; var avalue: msestring);
  public
   constructor create(const aowner: tcustomitemlist = nil;
              const aparent: ttreelistitem = nil);
 end;

 createlistitemeventty = procedure(const sender: tcustomitemlist; var item: tlistedititem) of object;
 createtreelistitemeventty = procedure(const sender: tcustomitemlist; var item: ttreelistedititem) of object;
 nodenotificationeventty = procedure(const sender: tlistitem;
           var action: nodeactionty) of object;

 titemviewlist = class(tcustomitemlist,iitemlist)
  private
   flistview: tcustomlistview;
   function getoncreateitem: createlistitemeventty;
   procedure setoncreateitem(const Value: createlistitemeventty);
  protected
   flayoutinfo: listitemlayoutinfoty;
   procedure doitemchange(index: integer); override;
   procedure updatelayout; override;
   procedure invalidate; override;

   //iitemlist
   function getlayoutinfo: plistitemlayoutinfoty;
   procedure itemcountchanged;
   function getcolorglyph: colorty;
   procedure updateitemvalues(const index: integer; const acount: integer);

  public
   constructor create(const alistview: tcustomlistview);
   property listview: tcustomlistview read flistview;
  published
   property oncreateitem: createlistitemeventty read getoncreateitem write setoncreateitem;
   property options;
   property captionpos;
   property imnr_base;
   property imagelist;
   property imagewidth;
   property imageheight;
 end;


 tlistcol = class(tdatacol)
  private
   function getitems(const aindex: integer): tlistitem;
   procedure setitems(const aindex: integer; const Value: tlistitem);
  protected
   function getselected(const row: integer): boolean; override;
   procedure setselected(const row: integer; value: boolean); override;
   procedure drawcell(const acanvas: tcanvas); override;
   procedure setwidth(const Value: integer); override;
   procedure setoptions(const Value: coloptionsty); override;
  public
   constructor create(const agrid: tcustomgrid;
                         const aowner: tgridarrayprop); override;
   procedure updatecellzone(const pos: pointty; var result: cellzonety); override;
   property items[const aindex: integer]: tlistitem read getitems write setitems;
                    default;
 end;

 tlistcols = class(tdatacols)
  protected
   procedure changeselectedrange(const start,oldend,newend: gridcoordty;
            calldoselectcell: boolean); override;
   procedure gridrecttoindex(const rect: gridrectty; out start,stop: integer);
   procedure dostatread(const reader: tstatreader); override;
   procedure dostatwrite(const writer: tstatwriter); override;
  public
   constructor create(aowner: tcustomlistview);
   procedure setselectedrange(const rect: gridrectty; value: boolean;
             calldoselectcell: boolean = false); overload; override;
 end;

 itemeventty = procedure(const sender: tcustomlistview; const index: integer;
                       var info: celleventinfoty) of object;

 tlistitemdragobject = class(tobjectdragobject)
  public
   constructor create(const asender: tobject; var instance: tdragobject;
                          const apickpos: pointty; const aitem: tlistitem);
   function item: tlistitem;
 end;

 listvieweventty = procedure(const sender: tcustomlistview) of object;
 
 tcustomlistview = class(tcellgrid,iedit)
  private
   feditor: tinplaceedit;
   fonafterupdatelayout: notifyeventty;
   fonbeforeupdatelayout: notifyeventty;
   fonitemevent: itemeventty;
   fcellwidthmax: integer;
   fcellwidthmin: integer;
   foptions: listviewoptionsty;
//   ffocusrectdist: integer;
   fcellwidth: integer;
//   fcolorselect: colorty;
   fcolorglyph: colorty;
   fediting: boolean;
   fonitemsmoved: griddatamovedeventty;
   ffiltertext: msestring;
   fcellframe: tcellframe;
   procedure createcellframe;
   function getcellframe: tcellframe;
   procedure setcellframe(const avalue: tcellframe);
   function getitems(const index: integer): tlistitem;
   procedure setitems(const index: integer; const Value: tlistitem);
   procedure setitemlist(value: titemviewlist);
   procedure setcellwidthmax(const Value: integer);
   procedure setcellwidthmin(Value: integer);
   procedure initdatacol(const item: tdatacol);
   procedure updatecoloptions;
   procedure setcellwidth(const Value: integer);
   function getcolorselect: colorty;
   procedure setcolorselect(const Value: colorty);
   procedure setcolorglyph(const Value: colorty);
   procedure setediting(const Value: boolean);
   procedure setfiltertext(const value: msestring);
   function getkeystring(const index: integer): msestring;
   function getfocusedindex: integer;
   procedure setfocusedindex(const avalue: integer);
   procedure setupeditor(const newcell: gridcoordty; posonly: boolean);
   function getdatacollinecolor: colorty;
   function getdatacollinewidth: integer;
   procedure setdatacollinecolor(const Value: colorty);
   procedure setdatacollinewidth(const Value: integer);
   function getcellfocusrectdist: integer;
   procedure setcellfocusrectdist(const avalue: integer);
   function getonselectionchanged: listvieweventty;
   procedure setonselectionchanged(const avalue: listvieweventty);
  protected
   fitemlist: titemviewlist;
   procedure setframeinstance(instance: tcustomframe); override;

   procedure setoptions(const Value: listviewoptionsty); virtual;
   procedure rootchanged; override;
   procedure doitemchange(index: integer);
   procedure doitemevent(const index: integer; var info: celleventinfoty); virtual;
   procedure docellevent(var info: celleventinfoty); override;
   function createdatacols: tdatacols; override;
   procedure createdatacol(const index: integer; out item: tdatacol); override;
   procedure updatelayout; override;
   procedure drawfocusedcell(const canvas: tcanvas); override;
   procedure loaded; override;
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure moveitem(const source,dest: tlistitem; focus: boolean);
   procedure scrolled(const dist: pointty); override;

  //iedit
   function getoptionsedit: optionseditty;
   procedure editnotification(var info: editnotificationinfoty);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure synctofontheight; override;
   procedure dragevent(var info: draginfoty); override;
   function indextocell(const index: integer): gridcoordty;
   function celltoindex(const cell: gridcoordty; limit: boolean): integer;
   function itematpos(const apos: pointty): tlistitem;
   function focuseditem: tlistitem;
   property focusedindex: integer read getfocusedindex write setfocusedindex;
   function celltoitem(const acell: gridcoordty): tlistitem;
   function finditembycaption(const acaption: msestring): tlistitem;
   function findcellbycaption(const acaption: msestring; var cell: gridcoordty): boolean;
   function getselecteditems: listitemarty;

   property items[const index: integer]: tlistitem read getitems write setitems;
   property editing: boolean read fediting write setediting;

   property colorselect: colorty read getcolorselect write setcolorselect default cl_default;
   property colorglyph: colorty read fcolorglyph write setcolorglyph default cl_black;
   property cellwidth: integer read fcellwidth write setcellwidth
                   default defaultcellwidth;
   property cellheight: integer read fdatarowheight write setdatarowheight
                   default defaultcellheight;
   property cellwidthmin: integer read fcellwidthmin write setcellwidthmin default defaultcellwidthmin;
   property cellwidthmax: integer read fcellwidthmax write setcellwidthmax default 0;
   property cellframe: tcellframe read getcellframe write setcellframe;
   property itemlist: titemviewlist read fitemlist write setitemlist;
   property options: listviewoptionsty read foptions write setoptions
                            default defaultlistviewoptions;
   property cellfocusrectdist: integer read getcellfocusrectdist write setcellfocusrectdist default 0;
   property filtertext: msestring read ffiltertext write setfiltertext;
   property datacollinewidth: integer read getdatacollinewidth
                    write setdatacollinewidth default defaultgridlinewidth;
   property datacollinecolor: colorty read getdatacollinecolor
                    write setdatacollinecolor default defaultdatalinecolor;
   property onbeforeupdatelayout: notifyeventty read fonbeforeupdatelayout
                  write fonbeforeupdatelayout;
   property onafterupdatelayout: notifyeventty read fonafterupdatelayout
                  write fonafterupdatelayout;
   property onitemevent: itemeventty read fonitemevent write fonitemevent;

   property onitemsmoved: griddatamovedeventty read fonitemsmoved
              write fonitemsmoved;
   property optionsgrid default defaultlistviewoptionsgrid;
   property onselectionchanged: listvieweventty read getonselectionchanged 
                                write setonselectionchanged;
 end;

 tlistview = class(tcustomlistview)
  published
   property datarowlinewidth;
   property datarowlinecolorfix;
   property datarowlinecolor;
   property datacollinewidth;
   property datacollinecolor;
   property colorselect;
   property colorglyph;
   property cellwidth;
   property cellheight;
   property cellframe;
   property cellfocusrectdist;
   property fixcols;
   property fixrows;
   property optionsgrid;
   property options;
   property itemlist;
   property cellwidthmin;
   property cellwidthmax;
   property statvarname;
   property statfile;
   property onselectionchanged;
   property onitemevent;
   property drag;
   property onitemsmoved;
 end;

 titemedit = class;

 tcustomitemeditlist = class(tcustomitemlist)
  private
   fcolorglyph: colorty;
   fowner: titemedit;
   fonitemnotification: nodenotificationeventty;
   procedure setcolorglyph(const Value: colorty);
  protected
   procedure doitemchange(index: integer); override;
   procedure nodenotification(const sender: tlistitem; var action: nodeactionty);
                   override;
   procedure compare(const l,r; var result: integer); override;
  public
   constructor create(const intf: iitemlist; const owner: titemedit); reintroduce;
   procedure assign(const aitems: listitemarty); reintroduce; overload;
   procedure add(const anode: tlistitem);
   procedure refreshitemvalues;
   property owner: titemedit read fowner;
   property colorglyph: colorty read fcolorglyph write setcolorglyph default cl_black;
                      //for monochrome imagelist
   property onitemnotification: nodenotificationeventty
                 read fonitemnotification write fonitemnotification;
  published
 end;

 titemeditlist = class(tcustomitemeditlist)
  private
   procedure setoncreateitem(const value: createlistitemeventty);
   function getoncreateitem: createlistitemeventty;
  protected
  published
   property imnr_base;
   property imnr_expanded;
   property imnr_selected;
   property imnr_readonly;
   property imnr_checked;
   property imnr_subitems;
   property imagelist;
   property imagewidth;
   property imageheight;
   property defaultnodestate;
   property captionpos;
   property options;
   property onitemnotification;
   property oncreateitem: createlistitemeventty read getoncreateitem write setoncreateitem;
   property onstatreaditem;
 end;

 itemindexeventty = procedure(const sender: tobject; const aindex: integer;
                     const aitem: tlistitem) of object;

 itemeditstatety = (ies_updating);
 itemeditstatesty = set of itemeditstatety;

 titemedit = class(tdataedit,iitemlist,ibutton)
  private
   fitemlist: tcustomitemeditlist;
   fonsetvalue: setstringeventty;
   fonkeydown: keyeventty;
   fonmouseevent: mouseeventty;
   fonbuttonaction: buttoneventty;
   fonupdaterowvalues: itemindexeventty;
   foncellevent: celleventty;
   factiverow: integer;
   ffiltertext: msestring;
   fstate: itemeditstatesty;

   function getitemlist: titemeditlist;
   procedure setitemlist(const Value: titemeditlist);
   function getitems(const index: integer): tlistitem;
   procedure setitems(const index: integer; const Value: tlistitem);
  protected
   flayoutinfo: listitemlayoutinfoty;
   fvalue: tlistitem;

   procedure setfiltertext(const value: msestring); virtual;
   function getkeystring(const index: integer): msestring;
   procedure itemchanged(const index: integer); virtual;
   procedure createnode(var item: tlistitem); virtual;

   //iitemlist
   function getlayoutinfo: plistitemlayoutinfoty;
   procedure itemcountchanged;
   procedure updateitemvalues(const index: integer; const count: integer); virtual;
   function getcolorglyph: colorty;

   procedure setgridintf(const intf: iwidgetgrid); override;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   function getdatatyp: datatypty; override;
   procedure drawcell(const canvas: tcanvas); override;
   procedure valuetogrid(const arow: integer); override;
   procedure gridtovalue(const arow: integer); override;
   function datatotext(const data): msestring; override;
   procedure dosetvalue(var avalue: msestring; var accept: boolean); virtual;
   procedure texttovalue(var accept: boolean; const quiet: boolean); override;
   procedure clientrectchanged; override;
   procedure updatelayout; virtual;
   procedure doitembuttonpress(var info: mouseeventinfoty); virtual;
   procedure clientmouseevent(var info: mouseeventinfoty); override;
   function getitemclass: listitemclassty; virtual;
   procedure setupeditor; override;
   procedure dopaint(const acanvas: tcanvas); override;
   procedure dokeydown(var info: keyeventinfoty); override;

   procedure getitemvalues; virtual;
   procedure createframe; override;

   //ibuttonaction
   procedure buttonaction(var action: buttonactionty;
         const buttonindex: integer); virtual;

   procedure mouseevent(var info: mouseeventinfoty); override;
   procedure docellevent(const ownedcol: boolean; var info: celleventinfoty); override;

//   procedure dostatread(const reader: tstatreader); override;
//   procedure dostatwrite(const writer: tstatwriter); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function getvaluetext: msestring;
   procedure setvaluetext(var avalue: msestring);
   function item: tlistitem;
   property items[const index: integer]: tlistitem read getitems write setitems; default;
   property activerow: integer read factiverow;
   property filtertext: msestring read ffiltertext write setfiltertext;
  published
   property itemlist: titemeditlist read getitemlist write setitemlist;
   property onsetvalue: setstringeventty read fonsetvalue write fonsetvalue;
   property onmouseevent: mouseeventty read fonmouseevent write fonmouseevent;
   property onkeydown: keyeventty read fonkeydown write fonkeydown;
   property optionsedit;
   property font;
   property passwordchar;
   property maxlength;
   property textflags;
   property textflagsactive;
   property onchange;
   property onbuttonaction: buttoneventty read fonbuttonaction write fonbuttonaction;
   property onupdaterowvalues: itemindexeventty read fonupdaterowvalues write fonupdaterowvalues;
   property oncellevent: celleventty read foncellevent write foncellevent;
 end;

 tdropdownitemedit = class(titemedit,idropdownlist)
  private
   fdropdown: tcustomdropdownlistcontroller;
   fonbeforedropdown: notifyeventty;
   fonafterclosedropdown: notifyeventty;
   procedure setdropdown(const Value: tcustomdropdownlistcontroller);
//   function getbutton: tdropdownbutton;
//   procedure setbutton(const avalue: tdropdownbutton);
  protected
   function getframe: tdropdownbuttonframe;
   procedure setframe(const Value: tdropdownbuttonframe);
   function getdropdowncontrollerclass: dropdownlistcontrollerclassty; virtual;
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure createframe; override;

   procedure editnotification(var info: editnotificationinfoty); override;
   //idropdown
   procedure dobeforedropdown; virtual;
   procedure doafterclosedropdown; virtual;
   function setdropdowntext(const value: msestring; const docheckvalue: boolean;
                            const canceled: boolean): boolean;
   function getdropdownitems: tdropdowncols;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property frame: tdropdownbuttonframe read getframe write setframe;
//   property button: tdropdownbutton read getbutton write setbutton;
   property dropdown: tcustomdropdownlistcontroller read fdropdown write setdropdown;
   property onbeforedropdown: notifyeventty read fonbeforedropdown write fonbeforedropdown;
   property onafterclosedropdown: notifyeventty read fonafterclosedropdown
                  write fonafterclosedropdown;
 end;

 tmbdropdownitemedit = class(tdropdownitemedit)
  private
  protected
   function getframe: tdropdownmultibuttonframe;
   procedure setframe(const Value: tdropdownmultibuttonframe);
   function getdropdowncontrollerclass: dropdownlistcontrollerclassty; override;
  published
   property frame: tdropdownmultibuttonframe read getframe write setframe;
 end;

 ttreeeditnode = class(ttreenode)
  protected
   function listitemclass: treelistitemclassty; override;
  public
   function converttotreelistitem(flat: boolean = false; withrootnode: boolean =  false;
                filterfunc: treenodefilterfuncty = nil): ttreelistedititem;
 end;

 ttreeitemedit = class;

 ttreeitemeditlist = class(tcustomitemeditlist)
  private
   fchangingnode: ttreelistitem;
   finsertcount: integer;
   finsertindex: integer;
   fcolorline: colorty;
   procedure setoncreateitem(const value: createtreelistitemeventty);
   function getoncreateitem: createtreelistitemeventty;
   procedure setcolorline(const value: colorty);
   function getonstatreaditem: statreadtreeitemeventty;
   procedure setonstatreaditem(const avalue: statreadtreeitemeventty);
  protected
   procedure freedata(var data); override;
   procedure docreateobject(var instance: tobject); override;
   procedure createitem(var item: tlistitem); override;
   procedure nodenotification(const sender: tlistitem;
                  var action: nodeactionty); override;
   procedure compare(const l,r; var result: integer); override;
   procedure statreaditem(const reader: tstatreader;
                    var aitem: tlistitem); override;
   procedure readstate(const reader; const acount: integer); override;
   procedure writestate(const writer; const name: msestring); override;
  public
   constructor create(const intf: iitemlist; const aowner: ttreeitemedit);
   procedure endupdate; override;
   procedure assign(const root: ttreelistedititem); reintroduce; overload;
                 //root is freed
   procedure add(const anode: ttreelistedititem); overload;
                 //adds toplevel node
   procedure add(const anodes: treelistedititemarty); overload;
   function toplevelnodes: treelistedititemarty;

  published
   property imnr_base;
   property imnr_expanded;
   property imnr_selected;
   property imnr_readonly;
   property imnr_checked;
   property imnr_subitems;
   property imagelist;
   property imagewidth;
   property imageheight;
   property defaultnodestate;
   property captionpos;
   property options;
   property onitemnotification;
   property colorline: colorty read fcolorline write setcolorline default cl_dkgray;
   property oncreateitem: createtreelistitemeventty read getoncreateitem
                      write setoncreateitem;
   property onstatreaditem: statreadtreeitemeventty read getonstatreaditem
                      write setonstatreaditem;
   property levelstep;
 end;

 treeitemeditoptionty = (teo_treecolnavig,teo_treerownavig,teo_keyrowmoving,teo_enteronimageclick);
 treeitemeditoptionsty = set of treeitemeditoptionty;

 checkmoveeventty = procedure(const curindex,newindex: integer; var accept: boolean) of object;

 trecordfieldedit = class(titemedit)
  private
   fitemedit: ttreeitemedit;
  protected
   procedure dosetvalue(var avalue: msestring; var accept: boolean); override;
   function getoptionsedit: optionseditty; override;
 end;

 ttreeitemedit = class(titemedit)
  private
   foptions: treeitemeditoptionsty;
   foncheckrowmove: checkmoveeventty;
   ffieldedit: trecordfieldedit;
   function getitemlist: ttreeitemeditlist;
   procedure setitemlist(const Value: ttreeitemeditlist);
   function getitems(const index: integer): ttreelistitem;
   procedure setitems(const index: integer; const Value: ttreelistitem);
   procedure expandedchanged(const avalue: boolean);
   procedure setfieldedit(const avalue: trecordfieldedit);
  protected
   procedure doitembuttonpress(var info: mouseeventinfoty); override;
   procedure setfiltertext(const value: msestring); override;
   function getkeystring1(const aindex: integer): msestring;
   function getkeystring2(const aindex: integer): msestring;
   procedure updatelayout; override;
   function getitemclass: listitemclassty; override;
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure docellevent(const ownedcol: boolean; var info: celleventinfoty); override;
   function checkrowmove(const curindex,newindex: integer): boolean;
   procedure updateitemvalues(const index: integer; const count: integer); override;
   function fieldcanedit: boolean;
  public
   constructor create(aowner: tcomponent); override;
   function item: ttreelistitem;
   property itemlist: ttreeitemeditlist read getitemlist write setitemlist;
   property items[const index: integer]: ttreelistitem read getitems write setitems; default;
   function candragsource(const apos: pointty): boolean;
  published
   property fieldedit: trecordfieldedit read ffieldedit write setfieldedit;
   property options: treeitemeditoptionsty read foptions write foptions default [];
   property oncheckrowmove: checkmoveeventty read foncheckrowmove write foncheckrowmove;
   property cursor default cr_default;
 end;

implementation
uses
 sysutils,msebits,msekeyboard;

type
 tdatalist1 = class(tdatalist);
 tcustomgrid1 = class(tcustomgrid);
 twidgetgrid1 = class(twidgetgrid);
 ttreelistitem1 = class(ttreelistitem);
 tlistitem1 = class(tlistitem);
 tdatacol1 = class(tdatacol);
 tframe1 = class(tcustomframe);
 twidgetcol1 = class(twidgetcol);

{ titemviewlist }

constructor titemviewlist.create(const alistview: tcustomlistview);
begin
 flistview:= alistview;
 inherited create(iitemlist(self));
end;

function titemviewlist.getlayoutinfo: plistitemlayoutinfoty;
begin
 result:= @flayoutinfo;
end;

procedure titemviewlist.itemcountchanged;
begin
 flistview.layoutchanged;
end;

procedure titemviewlist.doitemchange(index: integer);
begin
 inherited;
 flistview.doitemchange(index);
end;

procedure titemviewlist.invalidate;
begin
 flistview.invalidate;
end;

procedure titemviewlist.updatelayout;
begin
 with flistview do begin
  if fcellframe = nil then  begin
   tlistitem.calcitemlayout(makesize(cellwidth,cellheight),minimalframe,self,flayoutinfo);
  end
  else begin
   tlistitem.calcitemlayout(subsize(makesize(cellwidth,cellheight),fcellframe.paintframewidth),
             tframe1(fcellframe).fi.innerframe,self,flayoutinfo);
  end;
 end;
 invalidate;
end;

function titemviewlist.getcolorglyph: colorty;
begin
 result:= flistview.fcolorglyph;
end;

procedure titemviewlist.updateitemvalues(const index: integer; const acount: integer);
begin
 //dummy
end;

function titemviewlist.getoncreateitem: createlistitemeventty;
begin
 result:= createlistitemeventty(oncreateobject);
end;

procedure titemviewlist.setoncreateitem(const value: createlistitemeventty);
begin
 oncreateobject:= createobjecteventty(value);
end;

{ tlistcol }

constructor tlistcol.create(const agrid: tcustomgrid; 
                                     const aowner: tgridarrayprop);
begin
 inherited;
 fwidth:= tcustomlistview(fgrid).cellwidth;
 foptions:= (foptions - [co_savestate]) + [co_mousescrollrow];
end;

procedure tlistcol.setwidth(const Value: integer);
begin
 inherited;
 tcustomlistview(fgrid).cellwidth:= fwidth;
end;

procedure tlistcol.setoptions(const Value: coloptionsty);
begin
 inherited setoptions(value - [co_savevalue]);
end;

procedure tlistcol.drawcell(const acanvas: tcanvas);
var
 item: tlistitem;
begin
 inherited;
 item:= items[cellinfoty(acanvas.drawinfopo^).cell.row];
 if item <> nil then begin
  item.drawcell(acanvas);
 end;
end;

function tlistcol.getitems(const aindex: integer): tlistitem;
var
 int1: integer;
begin
 int1:= tcustomlistview(fgrid).celltoindex(makegridcoord(colindex,aindex),false);
 if int1 >= 0 then begin
  result:= tcustomlistview(fgrid).fitemlist[int1];
 end
 else begin
  result:= nil;
 end;
end;

procedure tlistcol.setitems(const aindex: integer; const Value: tlistitem);
var
 int1: integer;
begin
 int1:= tcustomlistview(fgrid).celltoindex(makegridcoord(colindex,aindex),false);
 if int1 >= 0 then begin
  tcustomlistview(fgrid).fitemlist[int1]:= value;
 end;
end;

procedure tlistcol.updatecellzone(const pos: pointty; var result: cellzonety);
begin
 if pointinrect(pos,tcustomlistview(fgrid).fitemlist.flayoutinfo.captionrect) then begin
  result:= cz_caption;
 end
 else begin
  if pointinrect(pos,tcustomlistview(fgrid).fitemlist.flayoutinfo.imagerect) then begin
   result:= cz_image;
  end
  else begin
   inherited;
  end;
 end;
end;

function tlistcol.getselected(const row: integer): boolean;
var
 int1: integer;
begin
 int1:= tcustomlistview(fgrid).celltoindex(makegridcoord(colindex,row),false);
 if int1 >= 0 then begin
  result:= tcustomlistview(fgrid).fitemlist[int1].selected;
 end
 else begin
  result:= false;
 end;
end;

procedure tlistcol.setselected(const row: integer; value: boolean);

 procedure updateselected(const index: integer);
 var
  item: tlistitem;
 begin
  item:= items[index];
  if item <> nil then begin
   item.selected:= value;
  end;
 end;

var
 int1: integer;
begin
 if row < 0 then begin
  for int1:= 0 to fgrid.rowcount-1 do begin
   updateselected(int1);
  end;
 end
 else begin
  updateselected(row);
 end;
 inherited;
end;

{ tlistcols}

constructor tlistcols.create(aowner: tcustomlistview);
begin
 inherited create(aowner,tlistcol);
end;

procedure tlistcols.gridrecttoindex(const rect: gridrectty; out start,stop: integer);
begin
 if (rect.rowcount <= 0) or (rect.colcount <= 0) then begin
  start:= -1;
  stop:= -2;
 end
 else begin
  with tcustomlistview(fgrid),rect do begin
   start:= celltoindex(pos,true);
   stop:= celltoindex(makegridcoord(col+colcount-1,row+rowcount-1),true);
   if stop < 0 then begin
    stop:= fitemlist.count-1;
    if start < 0 then begin
     stop:= start - 1;
    end;
   end;
  end;
 end;
end;

procedure tlistcols.dostatread(const reader: tstatreader);
begin
 inherited;
 with tcustomlistview(fgrid) do begin
  if lvo_savevalue in foptions then begin
   reader.readdatalist('values',fitemlist);
  end;
 end;
end;

procedure tlistcols.dostatwrite(const writer: tstatwriter);
begin
 inherited;
 with tcustomlistview(fgrid) do begin
  if lvo_savevalue in foptions then begin
   writer.writedatalist('values',fitemlist);
  end;
 end;
end;

procedure tlistcols.setselectedrange(const rect: gridrectty; value,
  calldoselectcell: boolean);
var
 int1,int2: integer;
begin
 with tcustomlistview(fgrid) do begin
  with rect do begin
   int1:= celltoindex(rect.pos,true);
   int2:= celltoindex(makegridcoord(col+colcount-1,row+rowcount-1),true);
  end;
  if calldoselectcell and value then begin
   for int1:= int1 to int2 do begin
    selectcell(indextocell(int1),value,false);
   end;
  end
  else begin
   for int1:= int1 to int2 do begin
    selected[indextocell(int1)]:= value;
//    fitemlist[int1].selected:= value;
   end;
  end;
 end;
end;

procedure tlistcols.changeselectedrange(const start,oldend,newend: gridcoordty;
             calldoselectcell: boolean);

 procedure select(start,stop: integer; value: boolean);
 var
  int1: integer;
 begin
  with tcustomlistview(fgrid) do begin
   if calldoselectcell then begin
    for int1:= start to stop do begin
     selectcell(indextocell(int1),value,false);
    end;
   end
   else begin
    for int1:= start to stop do begin
     selected[indextocell(int1)]:= value;
    end;
   end;
  end;
 end;

var
 int1,int2,int3,int4,int5: integer;
begin
 with tcustomlistview(fgrid) do begin
  int1:= celltoindex(start,true);
  int2:= celltoindex(oldend,true);
  int4:= celltoindex(newend,true);
  int3:= int1;
  if int2 < int1 then begin
   int1:= int2;
   int2:= int3;
  end;
  if int4 < int3 then begin
   int5:= int4;
   int4:= int3;
   int3:= int5;
  end;
 end;
 if (oldend.col >= 0) and (oldend.row >= 0) then begin
  if (int1 > int4) or (int3 > int2) then begin
   select(int1,int2,false);
   select(int3,int4,true);
  end
  else begin
   if int1 < int3 then begin
    select(int1,int3-1,false)
   end
   else begin
    if int1 > int3 then begin
     select(int3,int1-1,true);
    end;
   end;
   if int4 < int2 then begin
    select(int4+1,int2,false)
   end
   else begin
    if int4 > int2 then begin
     select(int2+1,int4,true);
    end;
   end;
  end;
 end;
end;

{ tlistitemdragobject }

constructor tlistitemdragobject.create(const asender: tobject;
  var instance: tdragobject; const apickpos: pointty; const aitem: tlistitem);
begin
 inherited create(asender,instance,apickpos,aitem);
end;

function tlistitemdragobject.item: tlistitem;
begin
 result:= tlistitem(fdata);
end;

{ tcustomlistview }

constructor tcustomlistview.create(aowner: tcomponent);
begin
 foptions:= defaultlistviewoptions;
 fcolorglyph:= cl_black;
 if fitemlist = nil then begin
  fitemlist:= titemviewlist.create(self);
 end;
 inherited;
 fstate:= fstate + [gs_islist];
 fcellwidthmin:= defaultcellwidthmin;
 cellwidth:= defaultcellwidth;
 cellheight:= defaultcellheight;
 optionsgrid:= defaultlistviewoptionsgrid;
 feditor:= tinplaceedit.create(self,iedit(self));
end;

destructor tcustomlistview.destroy;
begin
 inherited;
 feditor.Free;
 fitemlist.Free;
 fcellframe.free;
end;

function tcustomlistview.createdatacols: tdatacols;
begin
 result:= tlistcols.create(self);
end;

procedure tcustomlistview.createdatacol(const index: integer;
  out item: tdatacol);
begin
 item:= tlistcol.create(self,fdatacols);
 initdatacol(item);
end;

procedure tcustomlistview.initdatacol(const item: tdatacol);
begin
// item.options:= coloptionsty(
//      replacebits(
//      {$ifdef FPC}longword{$else}word{$endif}(foptionslist) shl listviewoptionshift,
//      {$ifdef FPC}longword{$else}longword{$endif}(item.options),
//      {$ifdef FPC}longword{$else}longword{$endif}(bitmask[integer(lvo_coloptions)+1])
//               shl listviewoptionshift));
 item.options:= coloptionsty(
      replacebits(
      {$ifdef FPC}longword{$else}word{$endif}(foptions),
      {$ifdef FPC}longword{$else}longword{$endif}(item.options),
      {$ifdef FPC}longword{$else}word{$endif}(coloptionsmask)));
 if fcellframe <> nil then begin
  item.frame:= fcellframe;
 end;
// tdatacol1(item).fcolorselect:= fcolorselect;
end;

procedure tcustomlistview.updatecoloptions;
var
 int1: integer;
begin
 if not (csloading in componentstate) then begin
  for int1:= 0 to fdatacols.count - 1 do begin
   initdatacol(fdatacols[int1]);
  end;
  invalidate;
 end;
end;

procedure tcustomlistview.setframeinstance(instance: tcustomframe);
begin
 if instance is tcellframe then begin
  fcellframe:= tcellframe(instance);
 end
 else begin
  inherited;
 end;
end;

procedure tcustomlistview.createcellframe;
begin
 tcellframe.create(iframe(self));
end;

function tcustomlistview.getcellframe: tcellframe;
begin
 getoptionalobject(fcellframe,{$ifdef FPC}@{$endif}createcellframe);
 result:= fcellframe;
end;

procedure tcustomlistview.setcellframe(const avalue: tcellframe);
begin
 setoptionalobject(avalue,fcellframe,{$ifdef FPC}@{$endif}createcellframe);
end;

function tcustomlistview.getitems(const index: integer): tlistitem;
var
 cell: gridcoordty;
begin
 cell:= indextocell(index);
 result:= tlistcol(fdatacols[cell.col])[cell.row];
end;

procedure tcustomlistview.setitems(const index: integer; const Value: tlistitem);
var
 cell: gridcoordty;
begin
 cell:= indextocell(index);
 tlistcol(fdatacols[cell.col])[cell.row]:= value;
end;

function tcustomlistview.celltoindex(const cell: gridcoordty; limit: boolean): integer;
begin
 if (cell.row < 0) or (cell.col < 0) then begin
  result:= -1;
 end
 else begin
  internalupdatelayout;
  if lvo_horz in foptions then begin
   result:= cell.row*fdatacols.count + cell.col;
  end
  else begin
   result:= cell.col*frowcount + cell.row;
  end;
  if result >= fitemlist.count then begin
   if limit then begin
    result:= fitemlist.count - 1;
   end
   else begin
    result:= -1;
   end;
  end;
 end;
end;

function tcustomlistview.indextocell(const index: integer): gridcoordty;
begin
 internalupdatelayout;
 if (frowcount > 0) and (fdatacols.count > 0) then begin
  if lvo_horz in foptions then begin
   result.row:= index div fdatacols.count;
   result.col:= index mod fdatacols.count;
  end
  else begin
   result.col:= index div frowcount;
   result.row:= index mod frowcount;
  end;
 end
 else begin
  result:= invalidcell;
 end;
end;

function tcustomlistview.itematpos(const apos: pointty): tlistitem;
var
 int1: integer;
begin
 int1:= celltoindex(cellatpos(apos),false);
 if int1 >= 0 then begin
  result:= fitemlist[int1];
 end
 else begin
  result:= nil;
 end;
end;

function tcustomlistview.celltoitem(const acell: gridcoordty): tlistitem;
var
 int1: integer;
begin
 int1:= celltoindex(acell,false);
 if int1 >= 0 then begin
  result:= fitemlist[int1];
 end
 else begin
  result:= nil;
 end;
end;

function tcustomlistview.focuseditem: tlistitem;
begin
 result:= celltoitem(ffocusedcell);
end;

function tcustomlistview.getfocusedindex: integer;
begin
 result:= celltoindex(ffocusedcell,true);
end;

procedure tcustomlistview.setfocusedindex(const avalue: integer);
begin
 if (avalue < 0) or (avalue >= fitemlist.count) then begin
  focuscell(invalidcell);
 end
 else begin
  focuscell(indextocell(avalue));
 end;
end;

function tcustomlistview.finditembycaption(const acaption: msestring): tlistitem;
var
 int1: integer;
 locopt: locatestringoptionsty;
begin
 int1:= -1;
 if lvo_casesensitive in foptions then begin
  locopt:= [lso_exact,lso_casesensitive];
 end
 else begin
  locopt:= [lso_exact];
 end;
 if locatestring(acaption,{$ifdef FPC}@{$endif}getkeystring,locopt,fitemlist.count,int1) then begin
  result:= fitemlist[int1];
 end
 else begin
  result:= nil;
 end;
end;

function tcustomlistview.findcellbycaption(const acaption: msestring; var cell: gridcoordty): boolean;
var
 item1: tlistitem;
begin
 item1:= finditembycaption(acaption);
 if item1 <> nil then begin
  result:= true;
  cell:= indextocell(item1.index);
 end
 else begin
  result:= false;
 end;
end;

procedure tcustomlistview.updatelayout;
var
 int1,int2: integer;
 bo1: boolean;
 indexbefore: integer;
 cell1: gridcoordty;
begin
 indexbefore:= celltoindex(ffocusedcell,true);
 if (fcellwidthmin <> 0) and (fcellwidthmin > fcellwidth) then begin
  fcellwidth:= fcellwidthmin;
 end;
 if (fcellwidthmax <> 0) and (fcellwidthmax < fcellwidth) then begin
  fcellwidth:= fcellwidthmax;
 end;
 fitemlist.updatelayout;
 for int1:= 0 to fdatacols.count-1 do begin
  fdatacols[int1].width:= fcellwidth;
 end;
 repeat
  inherited;
  bo1:= false;
  if lvo_horz in foptions then begin
   int1:=  tlistcol.defaultstep(fcellwidth);
   if int1 = 0 then begin
    int1:= 1;
   end;
   int2:= finnerdatarect.cx div int1;
   if int2 = 0 then begin
    int2:= 1;
   end;
   if fdatacols.count <> int2 then begin
    fdatacols.count:= int2;
    bo1:= true;
   end;
   int1:= (fitemlist.count + int2 - 1) div int2;
   if int1 <> frowcount then begin
    rowcount:= int1;
    bo1:= true;
   end;
  end
  else begin
   int1:=  ystep;
   if int1 = 0 then begin
    int1:= 1;
   end;
   int2:= finnerdatarect.cy div int1;
   if int2 = 0 then begin
    int2:= 1;
   end;
   if rowcount <> int2 then begin
    rowcount:= int2;
    bo1:= true;
   end;
   int1:= (fitemlist.count + int2 - 1) div int2;
   if int1 <> fdatacols.count then begin
    fdatacols.count:= int1;
    bo1:= true;
   end;
  end;
 until not bo1;
 if (indexbefore >= 0) then begin
  cell1:= indextocell(indexbefore);
  if (cell1.col <> ffocusedcell.col) or (cell1.row <> ffocusedcell.row) then begin
   focuscell(cell1);
  end;
  setupeditor(ffocusedcell,true);
 end;
end;

procedure tcustomlistview.setitemlist(value: titemviewlist);
begin
 fitemlist.Assign(value);
end;

procedure tcustomlistview.setcellwidthmax(const Value: integer);
begin
 if fcellwidthmax <> value then begin
  fcellwidthmax := Value;
  layoutchanged;
 end;
end;

procedure tcustomlistview.setcellwidthmin(Value: integer);
begin
 if value < 1 then begin
  value:= 1;
 end;
 if fcellwidthmin <> value then begin
  fcellwidthmin := Value;
  layoutchanged;
 end;
end;

procedure tcustomlistview.drawfocusedcell(const canvas: tcanvas);
var
 po1: pointty;
 item1: tlistitem;
begin
 drawcellbackground(canvas);
 item1:= focuseditem;
 if item1 <> nil then begin
  item1.drawimage(canvas);
  po1:= cellrect(ffocusedcell,cil_paint).pos;
  canvas.remove(po1);
  feditor.dopaint(canvas);
  canvas.move(po1);
 end;
end;

procedure tcustomlistview.setoptions(const Value: listviewoptionsty);
begin
 if foptions <> value then begin
  foptions:= Value;
  updatecoloptions;
 end;
end;

function tcustomlistview.getcellfocusrectdist: integer;
begin
 result:= fdatacols.focusrectdist;
end;

procedure tcustomlistview.setcellfocusrectdist(const avalue: integer);
begin
 fdatacols.focusrectdist:= avalue;
end;

procedure tcustomlistview.loaded;
begin
 inherited;
 updatecoloptions;
end;

function tcustomlistview.getkeystring(const index: integer): msestring;
begin
 result:= fitemlist[index].caption;
{
 if index < fitemlist.count then begin
  result:= true;
  astring:= fitemlist[index].caption;
 end
 else begin
  result:= false;
 end;
 }
end;

procedure tcustomlistview.setediting(const Value: boolean);
var
 item1: tlistitem;
begin
 if fediting <> value then begin
  if not (value and (lvo_readonly in foptions)) then begin
   fediting := Value;
   invalidatefocusedcell;
   if not value then begin
    if feditor.canundo then begin
     item1:= focuseditem;
     if item1 <> nil then begin
      item1.caption:= feditor.text;
     end;
    end;
    feditor.dodefocus;
   end
   else begin
    feditor.dofocus;
   end;
  end;
 end;
end;

procedure tcustomlistview.setupeditor(const newcell: gridcoordty; posonly: boolean);
var
 po1: pointty;
 rect1,rect2: rectty;
 int1: integer;
begin
 po1:= cellrect(newcell,cil_paint).pos;
 rect1:= moverect(fitemlist.flayoutinfo.captionrect,po1);
 rect2:= moverect(fitemlist.flayoutinfo.captioninnerrect,po1);
 int1:= celltoindex(newcell,false);
 if int1 >= 0 then begin
  if posonly then begin
   feditor.updatepos(rect2,rect1);
  end
  else begin
   feditor.setup(fitemlist[int1].caption,0,false,rect2,rect1,nil,nil,getfont);
   feditor.textflags:= fitemlist.flayoutinfo.textflags + [tf_clipo];
   feditor.textflagsactive:= feditor.textflags;
  end;
 end;
end;

procedure tcustomlistview.docellevent(var info: celleventinfoty);
var
 int1: integer;

begin
 if not (gs_layoutupdating in fstate) then begin
  with info do begin
   case eventkind of
    cek_enter: begin
     int1:= celltoindex(newcell,false);
     if int1 < 0 then begin
      focuscell(indextocell(fitemlist.count - 1),info.selectaction);
      exit;
     end;
     setupeditor(newcell,false);
    end;
    cek_exit: begin
     editing:= false;
     filtertext:= '';
    end;
    cek_select: begin
     if selected and (celltoindex(cell,false) < 0) then begin
      accept:= false;
     end;
    end;
   end;
  end;
  inherited;
  int1:= celltoindex(info.cell,false);
  if int1 >= 0 then begin
   doitemevent(int1,info);
  end;
 end
 else begin
  inherited;
 end;
end;

procedure tcustomlistview.doitemevent(const index: integer; var info: celleventinfoty);
var
 po1: pointty;
begin
 with info do begin
  if eventkind in mousecellevents then begin
   fitemlist[index].mouseevent(mouseeventinfopo^);
   if not (es_processed in mouseeventinfopo^.eventstate) then begin
    po1:= mouseeventinfopo^.pos;
    mouseeventinfopo^.pos:= gridmousepos;
    if editing or (eventkind = cek_buttonrelease) or 
                (info.mouseeventinfopo^.shiftstate * keyshiftstatesmask = []) then begin
     feditor.mouseevent(mouseeventinfopo^);
    end;
    if isdblclick(mouseeventinfopo^) then begin
     editing:= true;
    end;
    mouseeventinfopo^.pos:= po1;
   end;
  end;
 end;
 if canevent(tmethod(fonitemevent)) then begin
  fonitemevent(self,index,info);
 end;
end;

procedure tcustomlistview.setcellwidth(const Value: integer);
begin
 if fcellwidth <> value then begin
  fcellwidth := Value;
  layoutchanged;
 end;
end;

procedure tcustomlistview.rootchanged;
begin
 inherited;
 feditor.poschanged;
end;

procedure tcustomlistview.doitemchange(index: integer);

 procedure itemstatetocellstate(const itemindex: integer; const cell: gridcoordty);
 begin
  with fitemlist[itemindex] do begin
   fdatacols.selected[cell]:= selected;
   if (cell.row = ffocusedcell.row) and (cell.col = ffocusedcell.col) then begin
    feditor.text:= caption;
   end;
  end;
 end;

var
 cell: gridcoordty;
 int1: integer;
begin
 if index = -1 then begin
  layoutchanged;
  updatelayout;
  beginupdate;
  try
//   for int1:= 0 to fitemlist.count - 1 do begin
//    itemstatetocellstate(int1,indextocell(int1));
//   end;
   for int1:= fitemlist.count to rowcount * datacols.count - 1 do begin
    fdatacols.selected[indextocell(int1)]:= false;
   end;
  finally
   endupdate;
  end;
 end
 else begin
  cell:= indextocell(index);
  invalidatecell(cell);
  itemstatetocellstate(index,cell);
 end;
end;

function tcustomlistview.getcolorselect: colorty;
begin
 result:= fdatacols.colorselect;
end;

procedure tcustomlistview.setcolorselect(const Value: colorty);
begin
 fdatacols.colorselect:= value;
end;

procedure tcustomlistview.setcolorglyph(const Value: colorty);
begin
 if fcolorglyph <> value then begin
  fcolorglyph := Value;
  invalidate;
 end;
end;

procedure tcustomlistview.moveitem(const source,dest: tlistitem; focus: boolean);
var
 int1: integer;
begin
 int1:= source.index;
 fitemlist.movedata(int1,dest.index);
 if focus then begin
  focuscell(indextocell(source.index));
 end;
 if canevent(tmethod(fonitemsmoved)) then begin
  fonitemsmoved(self,int1,source.index,1);
 end;
end;

procedure tcustomlistview.scrolled(const dist: pointty);
begin
 inherited;
 if focusedcellvalid then begin
  feditor.scroll(dist);
 end;
end;

function tcustomlistview.getoptionsedit: optionseditty;
begin
 result:= [oe_autoselect,oe_resetselectonexit];
 if not fediting then begin
  include(result,oe_readonly);
 end;
end;

procedure tcustomlistview.editnotification(var info: editnotificationinfoty);
begin
end;

procedure tcustomlistview.synctofontheight;
var
 int1: integer;
begin
 inherited;
 if cellframe = nil then begin
  int1:= font.glyphheight + 2;
 end
 else begin
  int1:= font.glyphheight + cellframe.innerframewidth.cy;
 end;
 if (itemlist.imagelist <> nil) then begin
  if itemlist.captionpos in [cp_left,cp_center,cp_right] then begin
   if itemlist.imagelist.size.cy > int1 then begin
    int1:= itemlist.imagelist.size.cy;
   end;
  end
  else begin
   int1:= int1 + itemlist.imagelist.size.cy;
  end;
 end;
 cellheight:= int1;
end;

procedure tcustomlistview.dragevent(var info: draginfoty);
var
 item: tlistitem;
begin
 with info do begin
  if lvo_mousemoving in foptions then begin
   item:= itematpos(pos);
   if item <> nil then begin
    case eventkind of
     dek_begin: begin
      tlistitemdragobject.create(self,dragobject^,fdragcontroller.pickpos,item);
     end;
     dek_check: begin
      accept:= item <> focuseditem;
     end;
     dek_drop: begin
      moveitem(tlistitemdragobject(dragobject^).item,item,true);
     end;
    end;
   end;
  end;
 end;
 inherited;
end;

procedure tcustomlistview.setfiltertext(const value: msestring);
var
 int1: integer;
begin
 if value = '' then begin
  ffiltertext:= '';
 end
 else begin
  int1:= celltoindex(ffocusedcell,false);
  fitemlist.datapo; //normalize ring
  if locatestring(value,{$ifdef FPC}@{$endif}getkeystring,[],fitemlist.count,int1) then begin
   focuscell(indextocell(int1));
   ffiltertext:= value;
  end;
 end;
 if not editing then begin
  feditor.selstart:= 0;
  feditor.sellength:= length(ffiltertext);
 end;
end;

procedure tcustomlistview.dokeydown(var info: keyeventinfoty);
var
 item: tlistitem;
 int1: integer;
 str1: msestring;
 action1: focuscellactionty;
begin
 with info do begin
  if fediting then begin
   feditor.dokeydown(info);
   if ((key = key_left) or (key = key_right)) and (shiftstate - [ss_shift] = []) then begin
    include(eventstate,es_processed);
   end;
  end
  else begin
   if (key = key_backspace) and (shiftstate = []) then begin
    filtertext:= copy(ffiltertext,1,length(ffiltertext)-1);
   end
   else begin
    if (key = key_home) and (shiftstate = []) then begin
     filtertext:= '';
    end
    else begin
     str1:= mseextractprintchars(info.chars);
     if (str1 <> '') and (shiftstate - [ss_shift] = []) then begin
      filtertext:= ffiltertext + str1;
      include(eventstate,es_processed);
     end;
    end;
   end;
  end;
  if not (es_processed in eventstate) then begin
   if (lvo_keymoving in foptions) and (shiftstate = [ss_ctrl])
              and (focuseditem <> nil) then begin
    item:= nil;
    case info.key of
     key_up: begin
      if ffocusedcell.row > 0 then begin
       item:= celltoitem(makegridcoord(ffocusedcell.col,ffocusedcell.row - 1));
      end;
     end;
     key_down: begin
      if ffocusedcell.row < frowcount - 1 then begin
       item:= celltoitem(makegridcoord(ffocusedcell.col,ffocusedcell.row + 1));
      end;
     end;
     key_left: begin
      if ffocusedcell.col > 0 then begin
       item:= celltoitem(makegridcoord(ffocusedcell.col - 1,ffocusedcell.row));
      end;
     end;
     key_right: begin
      if ffocusedcell.col < fdatacols.count - 1 then begin
       item:= celltoitem(makegridcoord(ffocusedcell.col + 1,ffocusedcell.row));
      end;
     end;
    end;
    if item <> nil then begin
     moveitem(focuseditem,item,true);
     include(eventstate,es_processed);
    end;
   end;
   if not (es_processed in info.eventstate) then begin
    if (shiftstate = []) and (key = key_return) then begin
     if not editing then begin
      editing:= (focuseditem <> nil) and not (ns_readonly in focuseditem.state);
      if editing then begin
       include(eventstate,es_processed);
      end;
     end
     else begin
      editing:= false;
      include(eventstate,es_processed);
     end;
    end
    else begin
     if not editing and (ss_ctrl in shiftstate) and (shiftstate - [ss_ctrl,ss_shift] = []) and 
               ((key = key_home) or (key = key_end)) and (fitemlist.count > 0) then begin
      include(eventstate,es_processed);
      if ss_shift in shiftstate then begin
       if lvo_keyselect in foptions then begin       
        action1:= fca_selectend;
       end
       else begin
        action1:= fca_focusinshift;
       end;
      end
      else begin
       action1:= fca_focusin;
      end;
      if key = key_home then begin
       focuscell(indextocell(0),action1);
      end
      else begin
       focuscell(indextocell(fitemlist.count - 1),action1);
      end;
     end;
     if not (es_processed in eventstate) and (shiftstate - [ss_shift] = []) and 
                    (og_colchangeontabkey in foptionsgrid) and
            (fitemlist.count > 0) then begin
      int1:= celltoindex(ffocusedcell,true);
      case key of
       key_tab: begin
        inc(int1);
        if int1 = fitemlist.count then begin
         int1:= 0;
        end;
       end;
       key_backtab: begin
        dec(int1);
        if int1 < 0 then begin
         int1:= fitemlist.count - 1;
        end;
       end;
       else begin
        int1:= -1;
       end;
      end;
      if int1 >= 0 then begin
       include(eventstate,es_processed);
       focuscell(indextocell(int1));
      end;
     end;
    end;
    if not (es_processed in eventstate) then begin
     inherited;
    end;
   end;
  end;
 end;
end;

function tcustomlistview.getdatacollinecolor: colorty;
begin
 result:= fdatacols.linecolor;
end;

procedure tcustomlistview.setdatacollinecolor(const Value: colorty);
begin
 fdatacols.linecolor:= value;
end;

function tcustomlistview.getdatacollinewidth: integer;
begin
 result:= fdatacols.linewidth;
end;

procedure tcustomlistview.setdatacollinewidth(const Value: integer);
begin
 fdatacols.linewidth:= value;
end;

function tcustomlistview.getonselectionchanged: listvieweventty;
begin
 result:= listvieweventty(inherited onselectionchanged);
end;

procedure tcustomlistview.setonselectionchanged(const avalue: listvieweventty);
begin
 inherited onselectionchanged:= notifyeventty(avalue);
end;

function tcustomlistview.getselecteditems: listitemarty;
begin
 if datacols.hasselection then begin
  result:= fitemlist.getselecteditems;
 end
 else begin
  result:= nil;
 end;
end;

{ tcustomitemeditlist }

constructor tcustomitemeditlist.create(const intf: iitemlist; const owner: titemedit);
begin
 fcolorglyph:= cl_black;
 fowner:= owner;
 inherited create(intf);
end;

procedure tcustomitemeditlist.setcolorglyph(const Value: colorty);
begin
 if fcolorglyph <> value then begin
  fcolorglyph:= value;
  fowner.itemchanged(-1);
 end;
end;

procedure tcustomitemeditlist.assign(const aitems: listitemarty);
var
 po1: plistitem;
 int1: integer;
begin
 beginupdate;
 try
  clear;
  capacity:= length(aitems);
  fcount:= length(aitems);
  if fcount > 0 then begin
   move(aitems[0],fdatapo^,length(aitems)*fsize);
  end;
  po1:= plistitem(fdatapo);
  for int1:= 0 to fcount - 1 do begin
   tlistitem1(po1^).setowner(self);
   inc(po1);
  end;
  fintf.itemcountchanged;
  fintf.updateitemvalues(0,fcount);
 finally
  endupdate;
 end;
end;

procedure tcustomitemeditlist.add(const anode: tlistitem);
var
 int1: integer;
begin
 beginupdate;
 try
  int1:= internaladddata(anode,false);
  tlistitem1(anode).setowner(self);
  fintf.itemcountchanged;
  fintf.updateitemvalues(int1,1);
 finally
  endupdate;
 end;
// adddata(anode);
end;

procedure tcustomitemeditlist.refreshitemvalues;
begin
 beginupdate;
 try
  fintf.updateitemvalues(0,fcount);
 finally
  endupdate;
 end;
end;

procedure tcustomitemeditlist.doitemchange(index: integer);
begin
 fowner.itemchanged(index);
 inherited;
end;

procedure tcustomitemeditlist.nodenotification(const sender: tlistitem;
  var action: nodeactionty);
var
 grid: tcustomgrid;
begin
 if action = na_destroying then begin
  tlistitem1(sender).setowner(nil);
  if not deleting then begin
   grid:= fowner.fgridintf.getcol.grid;
   if sender.index < grid.rowcount then begin
    grid.deleterow(sender.index);
   end;
  end;
 end
 else begin
  if fowner.canevent(tmethod(fonitemnotification)) then begin
   fonitemnotification(sender,action);
  end;
  inherited;
  if action in [na_expand,na_collapse] then begin
   change(sender);
  end;
 end;
end;

procedure tcustomitemeditlist.compare(const l, r; var result: integer);
begin
 if oe_casesensitive in fowner.foptionsedit then begin
  result:= msecomparestr(tlistitem1(l).fcaption,tlistitem1(r).fcaption);
 end
 else begin
  result:= msecomparetext(tlistitem1(l).fcaption,tlistitem1(r).fcaption);
 end;
end;

{ titemeditlist}

function titemeditlist.getoncreateitem: createlistitemeventty;
begin
 result:= createlistitemeventty(oncreateobject);
end;

procedure titemeditlist.setoncreateitem(const value: createlistitemeventty);
begin
 oncreateobject:= createobjecteventty(value);
end;

{ titemedit }

constructor titemedit.create(aowner: tcomponent);
begin
 if fitemlist = nil then begin
  fitemlist:=  titemeditlist.create(iitemlist(self),self);
 end;
 inherited;
// createframe;
end;

destructor titemedit.destroy;
begin
 if fgridintf = nil then begin
  freeandnil(fitemlist);
 end;
 inherited;
end;

function titemedit.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= fitemlist;
end;

function titemedit.getdatatyp: datatypty;
begin
 result:= dl_none;
end;

procedure titemedit.createnode(var item: tlistitem);
begin
 item:= tlistitem.create(fitemlist);
end;

function titemedit.getlayoutinfo: plistitemlayoutinfoty;
begin
 result:= @flayoutinfo;
end;

procedure titemedit.updateitemvalues(const index: integer; const count: integer);
var
 int1,int2: integer;
 po1: plistitem;
begin
 if canevent(tmethod(fonupdaterowvalues)) then begin
  if index >= 0 then begin
   if count > 1 then begin
    fitemlist.beginupdate;
   end;
   try
    po1:= fitemlist.datapo;
    inc(po1,index);
    int2:= index + count - 1;
    if int2 >= fitemlist.fcount then begin
     int2:= fitemlist.fcount - 1;
    end;
    for int1:= index to int2 do begin
     fonupdaterowvalues(self,int1,po1^);
     inc(po1);
    end;
   finally
    if count > 1 then begin
     fitemlist.endupdate;
    end;
   end;
  end;
 end;
end;

procedure titemedit.itemcountchanged;
begin
 if fgridintf <> nil then begin
  with fgridintf.getcol.grid do begin
   rowcount:= fitemlist.count;
   rowdatachanged(0,fitemlist.count);
  end;
 end;
end;

procedure titemedit.getitemvalues;
begin
 if fvalue = nil then begin
  text:= '';
 end
 else begin
  text:= fvalue.caption;
 end;
 setupeditor;
end;

procedure titemedit.gridtovalue(const arow: integer);
var
 int1: integer;
begin
 int1:= arow;
 if int1 = -1 then begin
  int1:= fgridintf.getcol.grid.row;
 end;
 if int1 < 0 then begin
  fvalue:= nil;
 end
 else begin
  fvalue:= fitemlist[int1];
  if not (ies_updating in fstate) then begin
   fitemlist.beginupdate;
   try
    updateitemvalues(int1,1);
   finally
    fitemlist.decupdate;
   end;
  end;
 end;
 getitemvalues;
 inherited;
end;

procedure titemedit.valuetogrid(const arow: integer);
begin
 fitemlist.beginupdate;
 try
  updateitemvalues(arow,1);
 finally
  fitemlist.decupdate;
 end;
end;

procedure titemedit.drawcell(const canvas: tcanvas);
begin
 with cellinfoty(canvas.drawinfopo^) do begin
  tlistitem(datapo^).drawcell(canvas);
 end;
end;

function titemedit.datatotext(const data): msestring;
var
 po: plistitem;
begin
 if @data = nil then begin
  po:= @fvalue;
 end
 else begin
  po:= @data;
 end;
 if po^ <> nil then begin
  result:= po^.caption;
 end
 else begin
  result:= '';
 end;
end;

procedure titemedit.dosetvalue(var avalue: msestring; var accept: boolean);
begin
 if canevent(tmethod(fonsetvalue)) then begin
  fonsetvalue(self,avalue,accept);
 end;
end;

procedure titemedit.texttovalue(var accept: boolean; const quiet: boolean);
var
 str1: msestring;
begin
 str1:= feditor.text;
 if not quiet then begin
  dosetvalue(str1,accept);
 end;
 if accept and (fvalue <> nil) then begin
  fvalue.caption:= str1;
 end;
end;

procedure titemedit.updatelayout;
begin
 if fgridintf <> nil then begin
  if fframe <> nil then begin
   getitemclass.calcitemlayout(paintrect.size,tframe1(fframe).fi.innerframe,fitemlist,flayoutinfo);
  end
  else begin
   getitemclass.calcitemlayout(paintrect.size,minimalframe,fitemlist,flayoutinfo);
  end;
  invalidate;
  if not fitemlist.updating then begin
   fgridintf.getcol.changed;
  end;
 end;
end;

procedure titemedit.clientrectchanged;
begin
 inherited;
 updatelayout;
end;

procedure titemedit.doitembuttonpress(var info: mouseeventinfoty);
begin
 //dummy
end;

procedure titemedit.clientmouseevent(var info: mouseeventinfoty);
var
 po1: pointty;

begin
 if canevent(tmethod(fonmouseevent)) then begin
  fonmouseevent(self,info);
 end;
 if not (es_processed in info.eventstate) then begin
  if fvalue <> nil then begin
   if (info.eventkind = ek_buttonpress) and (fgridintf <> nil) then begin
    with fgridintf.getcol.grid,frame do begin
     po1:= scrollpos;
     fvalue.mouseevent(info);
     if not (es_processed in info.eventstate) then begin
      doitembuttonpress(info);
     end;
//     po2:= subpoint(cellrect(focusedcell).pos,fwidgetrect.pos);
     po1:= subpoint(scrollpos,po1);
     if (po1.x <> 0) or (po1.y <> 0) then begin
      self.releasemouse;
      addpoint1(info.pos,po1);
     end;
    end;
   end
   else begin
    fvalue.mouseevent(info);
   end;
  end;
  if not (es_processed in info.eventstate) then begin
   inherited;
  end;
 end;
end;

function titemedit.getitemclass: listitemclassty;
begin
 result:= tlistitem;
end;

procedure titemedit.setupeditor;
begin
 if not (csloading in componentstate) then begin
  if fvalue = nil then begin
   with feditor,flayoutinfo do begin
    feditor.setup(text,curindex,false,captioninnerrect,captionrect,nil,nil,
              geteditfont);
   end;
  end
  else begin
   fvalue.setupeditor(feditor,geteditfont);
  end;
 end;
end;

procedure titemedit.dopaint(const acanvas: tcanvas);
begin
 inherited;
 if fvalue <> nil then begin
  fvalue.drawimage(acanvas);
 end;
end;

procedure titemedit.itemchanged(const index: integer);
begin
 if (fgridintf <> nil) then begin
  if (factiverow < 0) or (factiverow >= fitemlist.count) then begin
   fvalue:= nil;
  end;
  fgridintf.getcol.cellchanged(index);
 end;
 changed;
end;

function titemedit.getitemlist: titemeditlist;
begin
 result:= titemeditlist(fitemlist);
end;

procedure titemedit.setitemlist(const Value: titemeditlist);
begin
 fitemlist.Assign(Value);
end;
{
procedure titemedit.updatecellzone(const pos: pointty; var result: cellzonety);
begin
 if fvalue <> nil then begin
  fvalue.updatecellzone(pos,result);
 end;
end;
}
procedure titemedit.setgridintf(const intf: iwidgetgrid);
begin
 inherited;
 if intf <> nil then begin
  if fitemlist.count > 0 then begin
   itemcountchanged;
  end
  else begin
   fitemlist.count:= intf.getcol.grid.rowcount;
  end;
  updatelayout;
 end;
end;

procedure titemedit.dokeydown(var info: keyeventinfoty);
var
 str1: msestring;
begin
 if canevent(tmethod(fonkeydown)) then begin
  fonkeydown(self,info);
 end;
 with info do begin
  if foptionsedit * [oe_readonly,oe_locate] = [oe_readonly,oe_locate] then begin
   if (key = key_backspace) and (shiftstate = []) then begin
    filtertext:= copy(ffiltertext,1,length(ffiltertext)-1);
   end
   else begin
    if (key = key_home) and (shiftstate = []) then begin
     filtertext:= '';
    end
    else begin
     str1:= mseextractprintchars(info.chars);
     if (str1 <> '') and (shiftstate - [ss_shift] = []) then begin
      filtertext:= ffiltertext + str1;
      include(eventstate,es_processed);
     end;
    end;
   end;
  end;
 end;
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;

function titemedit.getvaluetext: msestring;
begin
 if (fvalue <> nil) then begin
  result:= fvalue.getvaluetext;
 end
 else begin
  result:= '';
 end;
end;

procedure titemedit.setvaluetext(var avalue: msestring);
begin
 if (fvalue <> nil) then begin
  fvalue.setvaluetext(avalue);
 end;
end;

function titemedit.item: tlistitem;
begin
 result:= fvalue;
end;

procedure titemedit.createframe;
begin
 tcustombuttonframe.create(self,ibutton(self));
end;

procedure titemedit.buttonaction(var action: buttonactionty;
  const buttonindex: integer);
begin
 if canevent(tmethod(fonbuttonaction)) then begin
  fonbuttonaction(self,action,buttonindex);
 end;
end;

procedure titemedit.mouseevent(var info: mouseeventinfoty);
begin
 tcustombuttonframe(fframe).mouseevent(info);
 inherited;
end;

{
procedure titemedit.sortfunc(const l, r; var result: integer);
begin
 if oe_casesensitive in foptionsedit then begin
  result:= msecomparestr(tlistitem1(l).fcaption,tlistitem1(r).fcaption);
 end
 else begin
  result:= msecomparetext(tlistitem1(l).fcaption,tlistitem1(r).fcaption);
 end;
end;
}
function titemedit.getitems(const index: integer): tlistitem;
begin
 result:= tlistitem(fitemlist[index]);
end;

procedure titemedit.setitems(const index: integer; const Value: tlistitem);
begin
 fitemlist[index]:= value;
end;

function titemedit.getkeystring(const index: integer): msestring;
begin
 result:= fitemlist[index].caption;
{
 if index < fitemlist.count then begin
  astring:= fitemlist[index].caption;
  result:= true;
 end
 else begin
  result:= false;
 end;
 }
end;

procedure titemedit.setfiltertext(const value: msestring);
var
 int1: integer;
 opt1: locatestringoptionsty;
begin
 if value = '' then begin
  ffiltertext:= '';
 end
 else begin
  int1:= factiverow;
  if oe_casesensitive in foptionsedit then begin
   opt1:= [lso_casesensitive];
  end
  else begin
   opt1:= [];
  end;
  fitemlist.datapo; //normalize ring
  if locatestring(value,{$ifdef FPC}@{$endif}getkeystring,opt1,
           fitemlist.count,int1) then begin
   with tcustomgrid1(fgridintf.getcol.grid) do begin
    focuscell(makegridcoord(ffocusedcell.col,int1));
   end;
   ffiltertext:= value;
  end;
 end;
 if foptionsedit * [oe_readonly,oe_locate] = [oe_readonly,oe_locate] then begin
  feditor.selstart:= 0;
  feditor.sellength:= length(ffiltertext);
 end;
end;

function titemedit.getcolorglyph: colorty;
begin
 result:= fitemlist.fcolorglyph;
end;

procedure titemedit.docellevent(const ownedcol: boolean;
  var info: celleventinfoty);
begin
 with info do begin
  if ownedcol then begin
   if eventkind in mousecellevents then begin
    if fvalue <> nil then begin
     fvalue.updatecellzone(info.mouseeventinfopo^.pos,info.zone);
    end;
   end
   else begin
    if eventkind = cek_exit then begin
     filtertext:= '';
    end;
   end;
  end;
  if (info.eventkind = cek_enter) or (info.eventkind = cek_exit) then begin
   factiverow:= info.newcell.row;
   if fvalue <> nil then begin
    if info.eventkind = cek_enter then begin
     updateitemvalues(info.newcell.row,1);
    end
    else begin
     updateitemvalues(info.cellbefore.row,1);
    end;
   end;
  end;
 end;
 if canevent(tmethod(foncellevent)) then begin
   foncellevent(self,info);
 end;
 inherited;
end;

{
procedure titemedit.dostatwrite(const writer: tstatwriter);
begin
 fitemlist.statwrite(writer);
end;

procedure titemedit.dostatread(const reader: tstatreader);
begin
 fitemlist.statread(reader);
end;
}
{ tdropdownitemedit }

constructor tdropdownitemedit.create(aowner: tcomponent);
begin
 inherited;
 fdropdown:= getdropdowncontrollerclass.create(idropdownlist(self));
end;

destructor tdropdownitemedit.destroy;
begin
 inherited;
 fdropdown.free;
end;

function tdropdownitemedit.getdropdowncontrollerclass: dropdownlistcontrollerclassty;
begin
 result:= tdropdownlistcontroller;
end;

procedure tdropdownitemedit.createframe;
begin
 fdropdown.createframe;
end;

function tdropdownitemedit.getframe: tdropdownbuttonframe;
begin
 result:= tdropdownbuttonframe(inherited getframe);
end;

procedure tdropdownitemedit.setframe(const Value: tdropdownbuttonframe);
begin
 inherited setframe(value);
end;
{
function tdropdownitemedit.getbutton: tdropdownbutton;
begin
 with tdropdownbuttonframe(fframe) do begin
  result:= tdropdownbutton(buttons[activebutton]);
 end;
end;

procedure tdropdownitemedit.setbutton(const avalue: tdropdownbutton);
begin
 with tdropdownbuttonframe(fframe) do begin
  tdropdownbutton(buttons[activebutton]).assign(avalue);
 end;
end;
}
procedure tdropdownitemedit.doafterclosedropdown;
begin
 if canevent(tmethod(fonafterclosedropdown)) then begin
  fonafterclosedropdown(self);
 end;
end;

procedure tdropdownitemedit.editnotification(var info: editnotificationinfoty);
begin
 if fdropdown <> nil then begin
  fdropdown.editnotification(info);
 end;
 inherited;
end;

procedure tdropdownitemedit.dobeforedropdown;
begin
 if canevent(tmethod(fonbeforedropdown)) then begin
  fonbeforedropdown(self);
 end;
end;

procedure tdropdownitemedit.dokeydown(var info: keyeventinfoty);
begin
 fdropdown.dokeydown(info);
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;

function tdropdownitemedit.getdropdownitems: tdropdowncols;
begin
 result:= nil;
end;

procedure tdropdownitemedit.setdropdown(const Value: tcustomdropdownlistcontroller);
begin
 fdropdown.assign(Value);
end;

function tdropdownitemedit.setdropdowntext(const value: msestring;
              const docheckvalue: boolean;const canceled: boolean): boolean;
begin
 result:= true;
 if canceled then begin
  feditor.undo;
 end
 else begin
  feditor.text:= value;
  if docheckvalue then begin
   result:= checkvalue;
  end;
 end;
end;

{ tmbdropdownitemedit }

function tmbdropdownitemedit.getframe: tdropdownmultibuttonframe;
begin
 result:= tdropdownmultibuttonframe(inherited getframe);
end;

procedure tmbdropdownitemedit.setframe(const Value: tdropdownmultibuttonframe);
begin
 inherited setframe(value);
end;

function tmbdropdownitemedit.getdropdowncontrollerclass: dropdownlistcontrollerclassty;
begin
 result:= tmbdropdownlistcontroller;
end;

{ ttreeeditnode }

function ttreeeditnode.converttotreelistitem(flat, withrootnode: boolean;
  filterfunc: treenodefilterfuncty): ttreelistedititem;
begin
 result:= ttreelistedititem(inherited
      converttotreelistitem(flat,withrootnode,filterfunc));
end;

function ttreeeditnode.listitemclass: treelistitemclassty;
begin
 result:= ttreelistedititem;
end;

{ ttreelistedititem }

constructor ttreelistedititem.create(const aowner: tcustomitemlist;
  const aparent: ttreelistitem);
begin
 factiveindex:= -1;
 inherited;
end;

procedure ttreelistedititem.assign(source: ttreeitemeditlist);
var
 int1,int2: integer;
 po1: ptreelistitem;
begin
 clear;
 include(fstate,ns_noowner);
 if source.count > 0 then begin
  po1:= source.datapo;
  setlength(fitems,source.count);
  int2:= 0;
  for int1:= 0 to high(fitems) do begin
   if ttreelistitem1(po1^).fparent = nil then begin
    fitems[int2]:= po1^;
    ttreelistitem1(po1^).fparentindex:= int2;
    inc(int2);
   end;
   inc(po1);
  end;
  setlength(fitems,int2);
  fcount:= int2;
 end;
end;

procedure ttreelistedititem.add(const aitem: ttreelistedititem);
begin
 inherited add(aitem);
end;

procedure ttreelistedititem.add(const aitems: treelistedititemarty);
begin
 inherited add(treelistitemarty(aitems));
end;

procedure ttreelistedititem.add(const acount: integer; itemclass: treelistedititemclassty = nil);
begin
 inherited add(acount,itemclass);
end;

function ttreelistedititem.getactiveindex: integer;
begin
 if factiveindex < fcount then begin
  result:= factiveindex;
 end
 else begin
  result:= -1;
 end;
end;

{ trecordtreelistedititem }

constructor trecordtreelistedititem.create(const aowner: tcustomitemlist;
  const aparent: ttreelistitem);
begin
 inherited;
 include(fstate,ns_nosubnodestat);
end;

function trecordtreelistedititem.getfieldtext(const fieldindex: integer): msestring;
begin
 result:= '';
end;

procedure trecordtreelistedititem.setfieldtext(const fieldindex: integer;
                var avalue: msestring);
begin
 //dummy
end;

{ ttreeitemeditlist }

constructor ttreeitemeditlist.create(const intf: iitemlist; const aowner: ttreeitemedit);
begin
 fcolorline:= cl_dkgray;
 inherited create(intf,aowner);
end;

procedure ttreeitemeditlist.setcolorline(const value: colorty);
begin
 if fcolorline <> value then begin
  fcolorline:= value;
  fowner.itemchanged(-1);
 end;
end;

function ttreeitemeditlist.getonstatreaditem: statreadtreeitemeventty;
begin
 result:= onstatreadtreeitem;
end;

procedure ttreeitemeditlist.setonstatreaditem(const avalue: statreadtreeitemeventty);
begin
 onstatreadtreeitem:= avalue;
end;

procedure ttreeitemeditlist.createitem(var item: tlistitem);
begin
 item:= ttreelistedititem.create(self);
end;

procedure ttreeitemeditlist.docreateobject(var instance: tobject);
begin
 if fchangingnode = nil then begin
  inherited;
 end
 else begin
  instance:= fchangingnode[finsertindex];
  with ttreelistitem1(instance) do begin
   fowner:= self;
   findex:= finsertcount;
   inc(finsertcount);
   if expanded and (fcount > 0) then begin
    fchangingnode:= ttreelistitem(instance);
    finsertindex:= 0;
   end
   else begin
    inc(finsertindex);
    while (fchangingnode <> nil) and
            (finsertindex >= ttreelistitem1(fchangingnode).fcount) do begin
     finsertindex:= ttreelistitem1(fchangingnode).fparentindex + 1;
     fchangingnode:= ttreelistitem1(fchangingnode).fparent;
    end;
   end;
  end;
 end;
end;

procedure ttreeitemeditlist.freedata(var data);
var
 int1: integer;
 po1: ptreelistitem;
begin
 if pointer(data) <> nil then begin
  with ttreelistitem1(data) do begin
   if fowner <> nil then begin
    ttreelistitem1(data).setowner(nil);
   end;
   if fparent = nil then begin
    for int1:= findex + 1 to self.fcount - 1 do begin
     po1:= ptreelistitem(getitempo(int1));
     if ttreelistitem1(po1^).ftreelevel = 0 then begin
      break;
     end;
     po1^:= nil;
    end;
    if not (ils_subnodecountupdating in self.fstate) then begin
     inherited; //free node
    end;
   end
  end;
 end;
end;

procedure ttreeitemeditlist.writestate(const writer; const name: msestring);
var
 int1,int2: integer;
 po1: ^ttreelistitem1;
begin
 with tstatwriter(writer) do begin
  po1:= datapo;
  int2:= 0;
  for int1:= 0 to fcount - 1 do begin
   if po1^.ftreelevel = 0 then begin
    inc(int2);
   end;
   inc(po1);
  end;
//  writeinteger('value',int2);
  writeinteger(name,int2);
  po1:= datapo;
  for int1:= 0 to count - 1 do begin
   if po1^.ftreelevel = 0 then begin
    beginlist;
    po1^.dostatwrite(tstatwriter(writer));
    endlist;
   end;
   inc(po1);
  end;
 end;
end;

procedure ttreeitemeditlist.readstate(const reader; const acount: integer);
type
 expandedinfoty = record
  item: ttreelistitem;
  exp: boolean;
 end;

var
 int1: integer;
 po1: ^ttreelistitem1;
 expanded: array of expandedinfoty;
begin
 with tstatreader(reader) do begin
 // int1:= reader.readinteger('value',-1,0);
  int1:= acount;
  if int1 >= 0 then begin
   beginupdate;
   try
    clear;
    count:= int1;
    setlength(expanded,count);
    po1:= datapo;
    for int1:= 0 to count - 1 do begin
     beginlist;
     po1^.dostatread(tstatreader(reader));
     endlist;
     if ns_expanded in po1^.fstate then begin
      with expanded[int1] do begin
       item:= po1^;
       exp:= true;
      end;
      exclude(po1^.fstate,ns_expanded);
     end;
     inc(po1);
    end;
   finally
    endupdate;
   end;
   for int1:= 0 to high(expanded) do begin
    with expanded[int1] do begin
     if exp then begin
      item.expanded:= true;
     end;
    end;
   end;
  end;
 end;
end;

procedure ttreeitemeditlist.assign(const root: ttreelistedititem);
var
 ar1: listitemarty;
 int1: integer;
begin
 with ttreelistitem1(root) do begin
  if fcount > 0 then begin
   setlength(ar1,fcount);
   for int1:= fcount-1 downto 0 do begin
    ar1[int1]:= remove(int1);
   end;
   self.assign(ar1);
  end
  else begin
   self.clear;
  end;
 end;
 root.Free;
end;

procedure ttreeitemeditlist.add(const anode: ttreelistedititem); //adds toplevel node
var
 bo1: boolean;
begin
 bo1:= anode.expanded;
 anode.expanded:= false;
 inherited add(anode);
 anode.expanded:= bo1;
end;

procedure ttreeitemeditlist.add(const anodes: treelistedititemarty);
var
 int1: integer;
begin
 for int1:= 0 to high(anodes) do begin
  add(anodes[int1]);
 end;
end;

function ttreeitemeditlist.getoncreateitem: createtreelistitemeventty;
begin
 result:= createtreelistitemeventty(oncreateobject);
end;

procedure ttreeitemeditlist.nodenotification(const sender: tlistitem;
  var action: nodeactionty);

 procedure expand;
 var
  int1,int2: integer;
 begin
  with ttreeitemedit(fowner) do begin
   if ttreelistitem1(sender).fcount > 0 then begin
    fchangingnode:= ttreelistitem(sender);
    int2:= sender.index+1;
    finsertcount:= int2;
    finsertindex:= 0;
    int1:= ttreelistitem(sender).treeheight;
    try
     include(fstate,ies_updating);
     fgridintf.getcol.grid.insertrow(finsertcount,int1);
     exclude(fstate,ies_updating);
     fintf.updateitemvalues(int2,int1);
    finally
     exclude(fstate,ies_updating);
     fchangingnode:= nil;
    end;
    if fvalue = sender then begin
     expandedchanged(true);
    end;
   end;
  end;
 end;

var
 po1: ^ttreelistitem1;
 int1: integer;

begin
 if action = na_destroying then begin
  tlistitem1(sender).setowner(nil);
  if not deleting then begin
   with ttreelistitem(sender) do begin
    if expanded then begin
     int1:= treeheight+1;
    end
    else begin
     int1:= 1;
    end;
   end;
   fowner.fgridintf.getcol.grid.deleterow(sender.index,int1);
  end;
 end
 else begin
  inherited;
  case action of
   na_countchange: begin
    if not updating then begin
     with ttreelistitem1(sender) do begin
      if (findex < self.fcount-1) and (ns_expanded in fstate)  then begin
       int1:= findex+1;
       po1:= getitempo(int1);
       while (int1 < self.fcount) and (po1^.ftreelevel > ftreelevel) do begin
        inc(int1);
        inc(po1);
       end;
       self.fowner.fgridintf.getcol.grid.deleterow(findex+1,int1-findex-1);
       expand;
      end;
     end;
    end
    else begin
     include(fstate,ils_subnodecountinvalid);
    end;
   end;
   na_expand: begin
    expand;
   end;
   na_collapse: begin
    if not (ils_subnodecountupdating in fstate) then begin
     with ttreeitemedit(fowner) do begin
      fgridintf.getcol.grid.deleterow(sender.index+1,ttreelistitem(sender).treeheight);
      if fvalue = sender then begin
       expandedchanged(false);
      end;
     end;
    end;
   end;
  end;
 end;
end;

function ttreeitemeditlist.toplevelnodes: treelistedititemarty;
var
 int1,int2: integer;
 po1: ptreelistedititematy;
begin
 result:= nil;
 int2:= 0;
 po1:= datapo;
 for int1:= 0 to count - 1 do begin
  if po1^[int1].ftreelevel = 0 then begin
   additem(pointerarty(result),po1^[int1],int2);
  end;
 end;
 setlength(result,int2);
end;

procedure ttreeitemeditlist.endupdate;
var
 ar1: treelistedititemarty;
begin
 ar1:= nil; //compilerwarning
 if (nochange = 1) and (ils_subnodecountinvalid in fstate) then begin
  ar1:= toplevelnodes;
  include(fstate,ils_subnodecountupdating);
  try
   fowner.fgridintf.getcol.grid.rowcount:= 0;
   add(ar1);
  finally
   fstate:= fstate - [ils_subnodecountinvalid,ils_subnodecountupdating];
  end;
 end;
 inherited;
end;

procedure ttreeitemeditlist.setoncreateitem(const value: createtreelistitemeventty);
begin
 oncreateobject:= createobjecteventty(value);
end;

procedure ttreeitemeditlist.compare(const l, r; var result: integer);
var
 pathl,pathr: treelistitemarty;
 int1,int2,int3: integer;
begin
 pathl:= ttreelistitem(l).rootpath;
 pathr:= ttreelistitem(r).rootpath;
 int1:= length(pathl);
 if int1 > length(pathr) then begin
  int1:= length(pathr);
 end;
 int3:= -1;
 for int2:= 0 to int1-1 do begin
  if pathl[int2] <> pathr[int2] then begin
   int3:= int2;
   break;
  end;
 end;
 if int3 >= 0 then begin
  inherited compare(pathl[int3],pathr[int3],result);
 end
 else begin
  result:= length(pathl) - length(pathr);
 end;
end;

procedure ttreeitemeditlist.statreaditem(const reader: tstatreader;
                 var aitem: tlistitem);
begin
 statreadtreeitem(reader,nil,ttreelistitem(aitem));
end;

{ trecordfieldedit }

function trecordfieldedit.getoptionsedit: optionseditty;
begin
 result:= inherited getoptionsedit;
 if not (csdesigning in componentstate) and (fitemedit <> nil) and
                 not fitemedit.fieldcanedit then begin
  include(result,oe_readonly);
 end;
end;

procedure trecordfieldedit.dosetvalue(var avalue: msestring; var accept: boolean);
begin
 inherited;
 if accept and (fitemedit <> nil) then begin
  fitemedit.setvaluetext(avalue);
 end;
end;

{ ttreeitemedit }

constructor ttreeitemedit.create(aowner: tcomponent);
begin
 if fitemlist = nil then begin
  fitemlist:=  ttreeitemeditlist.create(iitemlist(self),self);
 end;
 inherited;
 cursor:= cr_default;
end;

function ttreeitemedit.candragsource(const apos: pointty): boolean;
var
 zone1: cellzonety;
begin
 result:= item <> nil;
 if result then begin
  zone1:= cz_none;
  item.updatecellzone(apos,zone1);
  result:= zone1 = cz_caption;
 end;
end;

function ttreeitemedit.getitemclass: listitemclassty;
begin
 result:= ttreelistedititem;
end;

function ttreeitemedit.getkeystring1(const aindex: integer): msestring;
begin
// if (aindex < fitemlist.count) then begin
//  result:= true;
  with ttreelistitem1(fitemlist[aindex]) do begin
   if treelevel = 0 then begin
    result:= caption;
   end
   else begin
    result:= '';
   end;
  end;
// end
// else begin
//  result:= false;
// end;
end;

function ttreeitemedit.getkeystring2(const aindex: integer): msestring;
begin
 with ttreelistitem1(ttreelistitem1(fvalue).fparent) do begin
//  if aindex < fcount then begin
   result:= fitems[aindex].caption;
//   result:= true;
//  end
//  else begin
//   result:= false;
//  end;
 end;
end;

procedure ttreeitemedit.setfiltertext(const value: msestring);
var
 int1: integer;
 opt1: locatestringoptionsty;
// func1: getkeystringfuncty;
begin
 if value = '' then begin
  ffiltertext:= '';
 end
 else begin
  if oe_casesensitive in foptionsedit then begin
   opt1:= [lso_casesensitive];
  end
  else begin
   opt1:= [];
  end;
  if (fvalue = nil) or (ttreelistitem1(fvalue).treelevel = 0) then begin
   int1:= factiverow;
   if locatestring(value,{$ifdef FPC}@{$endif}getkeystring1,opt1,
          fitemlist.count,int1) then begin
    with tcustomgrid1(fgridintf.getcol.grid) do begin
     focuscell(makegridcoord(ffocusedcell.col,int1));
    end;
    ffiltertext:= value;
   end;
  end
  else begin
   int1:= ttreelistitem1(fvalue).fparentindex;
   if locatestring(value,{$ifdef FPC}@{$endif}getkeystring2,opt1,
        ttreelistitem1(ttreelistitem1(fvalue).fparent).count,int1) then begin
    with tcustomgrid1(fgridintf.getcol.grid) do begin
     focuscell(makegridcoord(ffocusedcell.col,
        ttreelistitem1(ttreelistitem1(ttreelistitem1(fvalue).fparent).
                 fitems[int1]).findex));
    end;
    ffiltertext:= value;
   end;
  end;
 end;
 if foptionsedit * [oe_readonly,oe_locate] = [oe_readonly,oe_locate] then begin
  feditor.selstart:= 0;
  feditor.sellength:= length(ffiltertext);
 end;
end;

procedure ttreeitemedit.updatelayout;
begin
 inherited;
 flayoutinfo.colorline:= ttreeitemeditlist(fitemlist).fcolorline;
end;

{
procedure ttreeitemedit.itemchanged(const index: integer);
var
 state1: nodestatesty;
 node1: ttreelistitem;
begin
 inherited;
 if index >= 0 then begin
  node1:= ttreelistitem(fitemlist[index]);
  with node1 do begin
   state1:= changedstates;
   if ns_expanded in state1 then begin
    if ns_expanded in state then begin
     factnode:= node1;
     factindex:= 0;
     try
      fgridintf.getcol.grid.insertrow(index+1,node1.count);
     finally
      factnode:= nil;
     end;
    end
    else begin
     fgridintf.getcol.grid.deleterow(index+1,node1.count);
    end;
   end;
  end;
 end;
end;
}
function ttreeitemedit.getitemlist: ttreeitemeditlist;
begin
 result:= ttreeitemeditlist(fitemlist);
end;

procedure ttreeitemedit.setitemlist(const Value: ttreeitemeditlist);
begin
 fitemlist.assign(value);
end;

function ttreeitemedit.item: ttreelistitem;
begin
 result:= ttreelistitem(fvalue);
end;

function ttreeitemedit.getitems(const index: integer): ttreelistitem;
begin
 result:= ttreelistitem(fitemlist[index]);
end;

procedure ttreeitemedit.setitems(const index: integer;
  const Value: ttreelistitem);
begin
 fitemlist[index]:= value;
end;
{
procedure ttreeitemedit.sortfunc(const l, r; var result: integer);
var
 pathl,pathr: treelistitemarty;
 int1,int2,int3: integer;
begin
 pathl:= ttreelistitem(l).rootpath;
 pathr:= ttreelistitem(r).rootpath;
 int1:= length(pathl);
 if int1 > length(pathr) then begin
  int1:= length(pathr);
 end;
 int3:= -1;
 for int2:= 0 to int1-1 do begin
  if pathl[int2] <> pathr[int2] then begin
   int3:= int2;
   break;
  end;
 end;
 if int3 >= 0 then begin
  while true do begin
   inherited sortfunc(pathl[int3],pathr[int3],result);
   if result = 0 then begin
    inc(int3);
    if int3 >= length(pathl) then begin
     if int3 = length(pathr) then begin
      break;
     end
     else begin
      result:= -1;
     end;
    end
    else begin
     if int3 = length(pathr) then begin
      result:= 1;
      break;
     end;
    end;
   end
   else begin
    break;
   end;
  end;
 end;
end;
}
procedure ttreeitemedit.expandedchanged(const avalue: boolean);
var
 int1: integer;
begin
 with ttreelistitem1(fvalue) do begin
  if avalue and (fcount > 0) then begin
   int1:= treeheight+1;
   with fgridintf.getcol.grid do begin
    if int1 > rowsperpage then begin
     showcell(makegridcoord(col,index),cep_top);
    end
    else begin
     int1:= index+int1-1;
     if rowvisible(int1) > 0 then begin
      showcell(makegridcoord(col,int1),cep_bottom);
     end;
    end;
    focuscell(makegridcoord(col,index+1));
   end;
  end;
 end;
end;

procedure ttreeitemedit.setfieldedit(const avalue: trecordfieldedit);
begin
 setlinkedvar(avalue,tmsecomponent(ffieldedit));
 if avalue <> nil then begin
  avalue.setlinkedvar(self,tmsecomponent(avalue.fitemedit));
 end;
end;

function ttreeitemedit.checkrowmove(const curindex,
  newindex: integer): boolean;
begin
 if canevent(tmethod(foncheckrowmove)) then begin
  result:= false;
  foncheckrowmove(curindex,newindex,result);
 end
 else begin
  result:= true;
 end;
end;

procedure ttreeitemedit.updateitemvalues(const index: integer; const count: integer);
var
 int1: integer;
 po1: ptreelistedititematy;
begin
 if ffieldedit <> nil then begin
  po1:= fitemlist.datapo;
  for int1:= index to index + count - 1 do begin
   ffieldedit[int1].valuetext:= po1^[int1].valuetext;
  end;
 end;
 inherited;
end;

function ttreeitemedit.fieldcanedit: boolean;
begin
 result:= (fvalue <> nil) and not (ns_readonly in fvalue.state);
end;

procedure ttreeitemedit.dokeydown(var info: keyeventinfoty);
var
 int1,int2: integer;
 equallevelindex,atreelevel: integer;
 cellbefore: gridcoordty;

begin
 with info do begin
  if (fgridintf <> nil) and not (es_processed in eventstate) and (fvalue <> nil) then begin
   with twidgetgrid1(fgridintf.getcol.grid),ttreelistitem1(fvalue) do begin
    if shiftstate = [] then begin
     atreelevel:= treelevel;
     equallevelindex:= -1;
     cellbefore:= ffocusedcell;
     if teo_treecolnavig in self.foptions then begin
      include(eventstate,es_processed);
      case key of
       key_right: begin
        if expanded then begin
         if count > 0 then begin
          row:= row + 1;
         end;
        end
        else begin
         if ns_subitems in fstate then begin
          expanded:= true;
          dec(cellbefore.col);//no processed reset
         end;
        end;
       end;
       key_left: begin
        if ns_expanded in state then begin
         expanded:= false;
         dec(cellbefore.col);//no processed reset
        end
        else begin
         if fparent <> nil then begin
          row:= fparent.index;
         end;
//         int1:= fitemlist.indexof(parent);
//         if int1 >= 0 then begin
//          row:= int1;
//         end;
        end;
       end;
      end;
     end;
     if teo_treerownavig in self.foptions then begin
      include(eventstate,es_processed);
      case key of
       key_up: begin
        for int1:= ffocusedcell.row - 1 downto 0 do begin
         int2:= ttreelistitem(fitemlist[int1]).treelevel;
         if int2 <= atreelevel then begin
          equallevelindex:= int1;
          break;
         end;
        end;
        if equallevelindex >= 0 then begin
         row:= equallevelindex;
        end;
       end;
       key_down: begin
        for int1:= ffocusedcell.row + 1 to frowcount - 1 do begin
         int2:= ttreelistitem(fitemlist[int1]).treelevel;
         if int2 = atreelevel then begin
          equallevelindex:= int1;
          break;
         end;
         if int2 < atreelevel then begin
          break;
         end;
        end;
        if equallevelindex >= 0 then begin
         row:= equallevelindex;
        end;
       end;
      end;
     end;
     if (ffocusedcell.row = cellbefore.row) and
              (ffocusedcell.col = cellbefore.col) then begin
      exclude(eventstate,es_processed);
     end;
    end
    else begin
     if (teo_keyrowmoving in foptions) and (shiftstate = [ss_ctrl]) and
      ((key = key_up) or (key = key_down)) then begin
      include(eventstate,es_processed);
      if (ftreelevel > 0) and ((count = 0) or not expanded) then begin
       int1:= parentindex;
       if key = key_up then begin
        if (int1 > 0) and checkrowmove(row,row-1) then begin
         ttreelistitem1(fparent).swap(int1,int1-1);
         moverow(row,row-1,1);
        end;
       end
       else begin //key_down
        if (int1 < fparent.count-1) and checkrowmove(row,row+1) then begin
         ttreelistitem1(fparent).swap(int1,int1+1);
         moverow(row,row+1,1);
        end;
       end;
      end;
     end;
    end;
   end
  end;
  if not (es_processed in eventstate) then begin
   inherited;
  end;
 end;
end;

procedure ttreeitemedit.doitembuttonpress(var info: mouseeventinfoty);
var
 cellzone: cellzonety;
begin
 if (teo_enteronimageclick in foptions) then begin
  cellzone:= cz_none;
  with ttreelistedititem(fvalue) do begin
   updatecellzone(info.pos,cellzone);
   if cellzone = cz_image then begin
    expanded:= true;
    include(info.eventstate,es_processed);
   end;
  end;
 end;
end;


procedure ttreeitemedit.docellevent(const ownedcol: boolean; var info: celleventinfoty);
begin
 inherited;
 if fvalue <> nil then begin
  with info,ttreelistedititem(fvalue) do begin
   if (eventkind = cek_enter) and (fparent <> nil) then begin
    ttreelistedititem(fparent).factiveindex:= fparentindex;
   end;
  end;
 end;
end;

end.
