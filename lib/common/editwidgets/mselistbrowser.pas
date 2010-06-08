{ MSEgui Copyright (c) 1999-2010 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mselistbrowser;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 mseglob,classes,msegrids,msedatanodes,msedatalist,msegraphics,msegraphutils,
      msetypes,msestrings,msemenus,
      msebitmap,mseclasses,mseguiglob,msedrawtext,msefileutils,msedataedits,
      mseeditglob,msewidgetgrid,msewidgets,mseedit,mseevent,msegui,msedropdownlist,
      msesys,msedrag,msestat,mseinplaceedit,msepointer,msegridsglob;

const
 defaultcellwidth = 50;
 defaultcellheight = 50;
 defaultcellwidthmin = 10;
 defaultitemedittextflags = defaulttextflags + [tf_clipo];
 defaultitemedittextflagsactive = defaulttextflagsactive + [tf_clipo];

type
 listviewoptionty = ( //matched with coloptionty
          lvo_readonly,lvo_mousemoving,lvo_keymoving,lvo_horz,
          lvo_drawfocus,lvo_mousemovefocus,lvo_leftbuttonfocusonly,
          lvo_noctrlmousefocus,
          lvo_focusselect,lvo_mouseselect,lvo_keyselect,
          lvo_multiselect,lvo_resetselectonexit,{lvo_noresetselect,}
          lvo_fill,
          lvo_locate,lvo_casesensitive,lvo_savevalue,lvo_hintclippedtext
                     );
 listviewoptionsty = set of listviewoptionty;
 filelistviewoptionty = (flvo_nodirselect,flvo_nofileselect,flvo_checksubdir);
 filelistviewoptionsty = set of filelistviewoptionty;

const
 defaultlistviewoptionsgrid = defaultoptionsgrid + [og_wraprow,og_mousescrollcol];
 defaultlistviewoptions = [lvo_focusselect,lvo_mouseselect,lvo_drawfocus,
                           lvo_leftbuttonfocusonly,lvo_locate];
 defaultfilelistviewoptions = [flvo_nodirselect];
 coloptionsmask: listviewoptionsty =
                    [lvo_readonly,{lvo_mousemoving,lvo_keymoving,lvo_horz,}
                     lvo_drawfocus,lvo_mousemovefocus,lvo_leftbuttonfocusonly,
                     lvo_noctrlmousefocus,
                     lvo_focusselect,lvo_mouseselect,lvo_keyselect,
                     lvo_multiselect,lvo_resetselectonexit{,lvo_noresetselect}];
// lvo_coloptions = lvo_drawfocus;

type
 tcustomlistview = class;

 tlistedititem = class(tlistitem)
 end;
 listedititemclassty = class of tlistedititem;

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
              const aparent: ttreelistitem = nil); override;
   procedure assign(source: ttreeitemeditlist); overload;
       //source remains owner of items, parent of items is unchanged
   procedure add(const aitem: ttreelistedititem); overload; //nil ignored
   procedure add(const aitems: treelistedititemarty); overload;
   procedure add(const acount: integer; 
               const itemclass: treelistedititemclassty = nil); overload;
   procedure add(const captions: array of msestring; 
               const itemclass: treelistedititemclassty = nil); overload;
   property activeindex: integer read getactiveindex;
 end;

 trecordtreelistedititem = class(ttreelistedititem,irecordfield)   //does not statsave subitems
  protected
   function getfieldtext(const fieldindex: integer): msestring;
   procedure setfieldtext(const fieldindex: integer; var avalue: msestring);
  public
   constructor create(const aowner: tcustomitemlist = nil;
              const aparent: ttreelistitem = nil); override;
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
   procedure doitemchange(const index: integer); override;
   procedure updatelayout; override;
   procedure invalidate; override;

   //iitemlist
   function getlayoutinfo: plistitemlayoutinfoty;
   procedure itemcountchanged;
   function getcolorglyph: colorty;
   procedure updateitemvalues(const index: integer; const acount: integer);
   function getcomponentstate: tcomponentstate;

  public
   constructor create(const alistview: tcustomlistview);
   property listview: tcustomlistview read flistview;
  published
   property oncreateitem: createlistitemeventty read getoncreateitem 
                                          write setoncreateitem;
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
   procedure docellevent(var info: celleventinfoty); override;
  public
   constructor create(const agrid: tcustomgrid;
                         const aowner: tgridarrayprop); override;
   procedure updatecellzone(const row: integer; const pos: pointty;
                            var result: cellzonety); override;
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
   procedure setselectedrange(const start,stop: gridcoordty;
                  const value: boolean;
                  const calldoselectcell: boolean = false;
                  const checkmultiselect: boolean = false); overload; override;
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
   fonitemevent: itemeventty;
   fcellwidthmax: integer;
   fcellwidthmin: integer;
   foptions: listviewoptionsty;
   fcellwidth: integer;
   fcolorglyph: colorty;
   fediting: boolean;
   fonitemsmoved: gridblockmovedeventty;
//   ffiltertext: msestring;
   fcellframe: tcellframe;
   foncopytoclipboard: updatestringeventty;
   fonpastefromclipboard: updatestringeventty;
//   fcellheight: integer;
   fcellcursor: cursorshapety;
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
//   procedure setfiltertext(const value: msestring);
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
   function getonlayoutchanged: listvieweventty;
   procedure setonlayoutchanged(const avalue: listvieweventty);
   function getcellheight: integer;
   procedure setcellheight(const avalue: integer);
   function getonbeforeupdatelayout: listvieweventty;
   procedure setonbeforeupdatelayout(const avalue: listvieweventty);
   function getcellheightmin: integer;
   procedure setcellheightmin(const avalue: integer);
   function getcellheightmax: integer;
   procedure setcellheightmax(const avalue: integer);
   procedure setcellcursor(const avalue: cursorshapety);
  protected
   fitemlist: titemviewlist;
   procedure setframeinstance(instance: tcustomframe); override;

   procedure setoptions(const avalue: listviewoptionsty); virtual;
   procedure rootchanged; override;
   procedure doitemchange(index: integer);
   procedure doitemevent(const index: integer;
                               var info: celleventinfoty); virtual;
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
   function hasselection: boolean;
   procedure updatecopytoclipboard(var atext: msestring); virtual;
   procedure updatepastefromclipboard(var atext: msestring); virtual;
   function locatecount: integer; virtual;        //number of locate values
   function locatecurrentindex: integer; virtual; //index of current row
   procedure locatesetcurrentindex(const aindex: integer);
   function edited: boolean;
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
   function findcellbycaption(const acaption: msestring;
                                               var cell: gridcoordty): boolean;
   function getselecteditems: listitemarty;

   property items[const index: integer]: tlistitem read getitems 
                                                  write setitems; default;
   property editing: boolean read fediting write setediting;
   property editor: tinplaceedit read feditor;

   property colorselect: colorty read getcolorselect 
                                    write setcolorselect default cl_default;
   property colorglyph: colorty read fcolorglyph 
                                    write setcolorglyph default cl_black;
   property cellwidth: integer read fcellwidth write setcellwidth
                   default defaultcellwidth;
   property cellheight: integer read getcellheight write setcellheight
                   default defaultcellheight;
   property cellheightmin: integer read getcellheightmin write setcellheightmin
                   default 1;
   property cellheightmax: integer read getcellheightmax write setcellheightmax
                   default maxint;
   property cellwidthmin: integer read fcellwidthmin 
                         write setcellwidthmin default defaultcellwidthmin;
   property cellwidthmax: integer read fcellwidthmax 
                         write setcellwidthmax default 0;
   property cellframe: tcellframe read getcellframe write setcellframe;
   property cellcursor: cursorshapety read fcellcursor write setcellcursor 
                                                           default cr_default;
   
   property itemlist: titemviewlist read fitemlist write setitemlist;
   property options: listviewoptionsty read foptions write setoptions
                            default defaultlistviewoptions;
   property cellfocusrectdist: integer read getcellfocusrectdist 
                                        write setcellfocusrectdist default 0;
//   property filtertext: msestring read ffiltertext write setfiltertext;
   property datacollinewidth: integer read getdatacollinewidth
                    write setdatacollinewidth default defaultgridlinewidth;
   property datacollinecolor: colorty read getdatacollinecolor
                    write setdatacollinecolor default defaultdatalinecolor;
   property onitemevent: itemeventty read fonitemevent write fonitemevent;

   property onitemsmoved: gridblockmovedeventty read fonitemsmoved
              write fonitemsmoved;
   property optionsgrid default defaultlistviewoptionsgrid;
   property onselectionchanged: listvieweventty read getonselectionchanged 
                                write setonselectionchanged;
   property onbeforeupdatelayout: listvieweventty read getonbeforeupdatelayout 
                                write setonbeforeupdatelayout;
   property onlayoutchanged: listvieweventty read getonlayoutchanged 
                                write setonlayoutchanged;
   property oncopytoclipboard: updatestringeventty read foncopytoclipboard 
                  write foncopytoclipboard;
   property onpastefromclipboard: updatestringeventty read fonpastefromclipboard 
                  write fonpastefromclipboard;
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
   property cellcursor;
   property cellfocusrectdist;
   property fixcols;
   property fixrows;
   property optionsgrid;
   property options;
   property gridframewidth;
   property gridframecolor;
   property itemlist;
   property cellwidthmin;
   property cellwidthmax;
   property cellheightmin;
   property cellheightmax;
   property statvarname;
   property statfile;
   property onselectionchanged;
   property onbeforeupdatelayout;
   property onlayoutchanged;
   property onitemevent;
   property drag;
   property onitemsmoved;
   property oncopytoclipboard;
   property onpastefromclipboard;
 end;

 titemedit = class;

 tcustomitemeditlist = class(tcustomitemlist)
  private
   fcolorglyph: colorty;
   fowner: titemedit;
   fonitemnotification: nodenotificationeventty;
   procedure setcolorglyph(const Value: colorty);
  protected
   procedure doitemchange(const index: integer); override;
   procedure nodenotification(const sender: tlistitem; 
                                      var ainfo: nodeactioninfoty); override;
   procedure compare(const l,r; var result: integer); override;
  public
   constructor create(const intf: iitemlist; const owner: titemedit); reintroduce;
   procedure assign(const aitems: listitemarty); reintroduce; overload;
   procedure add(const anode: tlistitem);
   procedure refreshitemvalues;
   property owner: titemedit read fowner;
   property colorglyph: colorty read fcolorglyph 
                                    write setcolorglyph default cl_black;
                      //for monochrome imagelist
   property onitemnotification: nodenotificationeventty
                 read fonitemnotification write fonitemnotification;
  published
 end;

 titemeditlist = class(tcustomitemeditlist)
  private
   procedure setoncreateitem(const value: createlistitemeventty);
   function getoncreateitem: createlistitemeventty;
   function getitemclass: listedititemclassty;
   procedure setitemclass(const avalue: listedititemclassty);
  protected
  public
   property itemclass: listedititemclassty read getitemclass write setitemclass;
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
   property oncreateitem: createlistitemeventty read getoncreateitem 
                                                    write setoncreateitem;
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
   fonclientmouseevent: mouseeventty;
   fonbuttonaction: buttoneventty;
   fonupdaterowvalues: itemindexeventty;
   foncellevent: celleventty;
   factiverow: integer;
//   ffiltertext: msestring;
   fstate: itemeditstatesty;

   fediting: boolean;
   function getitemlist: titemeditlist;
   procedure setitemlist(const Value: titemeditlist);
   function getitems(const index: integer): tlistitem;
   procedure setitems(const index: integer; const Value: tlistitem);
//   procedure updatefilterselect;
   procedure setediting(const avalue: boolean);
  protected
   flayoutinfo: listitemlayoutinfoty;
   fvalue: tlistitem;

//   procedure setfiltertext(const value: msestring); virtual;
  //igridwidget
   function getcellcursor(const arow: integer; 
                         const acellzone: cellzonety): cursorshapety; override;
   procedure updatecellzone(const row: integer; const apos: pointty;
                            var result: cellzonety); override;
   function actualcursor(const apos: pointty): cursorshapety; override;
  //iedit
   function locatecount: integer; override;        //number of locate values
   function getkeystring(const index: integer): msestring; override;

   procedure itemchanged(const index: integer); virtual;
   procedure createnode(var item: tlistitem); virtual;

  //iitemlist
   function getlayoutinfo: plistitemlayoutinfoty;
   procedure itemcountchanged;
   procedure updateitemvalues(const index: integer; const count: integer); virtual;
   function getcolorglyph: colorty;

   procedure setgridintf(const intf: iwidgetgrid); override;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   function getdatatype: listdatatypety; override;
   procedure drawcell(const canvas: tcanvas); override;
   procedure valuetogrid(arow: integer); override;
   procedure gridtovalue(arow: integer); override;
   function internaldatatotext(const data): msestring; override;
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
   procedure internalcreateframe; override;

  //ibuttonaction
   procedure buttonaction(var action: buttonactionty;
         const buttonindex: integer); virtual;

   procedure mouseevent(var info: mouseeventinfoty); override;
   procedure docellevent(const ownedcol: boolean;
                                         var info: celleventinfoty); override;

//   function islocating: boolean;
   function getoptionsedit: optionseditty; override;
   property editing: boolean read fediting write setediting;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function getvaluetext: msestring;
   procedure setvaluetext(var avalue: msestring);
   function item: tlistitem;
   procedure beginedit;
   procedure endedit;
   property items[const index: integer]: tlistitem read getitems 
                                                    write setitems; default;
   property activerow: integer read factiverow;
//   property filtertext: msestring read ffiltertext write setfiltertext;
  published
   property itemlist: titemeditlist read getitemlist write setitemlist;
   property onsetvalue: setstringeventty read fonsetvalue write fonsetvalue;
   property onclientmouseevent: mouseeventty read fonclientmouseevent 
                           write fonclientmouseevent;
   property optionsedit;
   property font;
   property passwordchar;
   property maxlength;
   property textflags default defaultitemedittextflags;
   property textflagsactive default defaultitemedittextflagsactive;
   property onchange;
   property onbuttonaction: buttoneventty read fonbuttonaction 
                                                   write fonbuttonaction;
   property onupdaterowvalues: itemindexeventty read fonupdaterowvalues 
                                       write fonupdaterowvalues;
   property oncellevent: celleventty read foncellevent write foncellevent;
 end;

 tdropdownitemedit = class(titemedit,idropdownlist)
  private
   fdropdown: tcustomdropdownlistcontroller;
   fonbeforedropdown: notifyeventty;
   fonafterclosedropdown: notifyeventty;
   procedure setdropdown(const Value: tcustomdropdownlistcontroller);
  protected
   function getframe: tdropdownbuttonframe;
   procedure setframe(const Value: tdropdownbuttonframe);
   function getdropdowncontrollerclass: dropdownlistcontrollerclassty; virtual;
//   procedure dokeydown(var info: keyeventinfoty); override;
//   procedure internalcreateframe; override;

//   procedure editnotification(var info: editnotificationinfoty); override;
  //idropdown
   procedure dobeforedropdown; virtual;
   procedure doafterclosedropdown; virtual;
   function getdropdownitems: tdropdowncols;
   function getvalueempty: integer; virtual;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property frame: tdropdownbuttonframe read getframe write setframe;
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

 ttreeitemdragobject = class(tdragobject)
  private
   fitem: ttreelistitem;
   fdestrow: integer;
  public
   constructor create(const asender: tobject; var instance: tdragobject;
                          const apickpos: pointty; const aitem: ttreelistitem);
   property item: ttreelistitem read fitem;
   property destrow: integer read fdestrow;
 end;
 
 treeitemdragbegineventty = procedure(const sender: ttreeitemedit;
                    const aitem: ttreelistitem;
                    var candrag: boolean; var dragobject: ttreeitemdragobject;
                    var processed: boolean) of object;
 treeitemdragovereventty = procedure(const sender: ttreeitemedit;
            const source,dest: ttreelistitem;
            var dragobject: ttreeitemdragobject; var accept: boolean;
            var processed: boolean) of object;
 treeitemdragdropeventty = procedure(const sender: ttreeitemedit;
            const source,dest: ttreelistitem;
            var dragobject: ttreeitemdragobject; var processed: boolean) of object;

 ttreeitemeditlist = class(tcustomitemeditlist)
  private
   fchangingnode: ttreelistitem;
   finsertcount: integer;
   finsertindex: integer;
   fcolorline: colorty;
   fondragbegin: treeitemdragbegineventty;
   fondragover: treeitemdragovereventty;
   fondragdrop: treeitemdragdropeventty;
   procedure setoncreateitem(const value: createtreelistitemeventty);
   function getoncreateitem: createtreelistitemeventty;
   procedure setcolorline(const value: colorty);
   function getonstatreaditem: statreadtreeitemeventty;
   procedure setonstatreaditem(const avalue: statreadtreeitemeventty);
   function getitems1(const index: integer): ttreelistedititem;
   procedure setitems(const index: integer; const avalue: ttreelistedititem);
   function getitemclass: treelistedititemclassty;
   procedure setitemclass(const avalue: treelistedititemclassty);
  protected
   procedure change(const index: integer); override;
   procedure freedata(var data); override;
   procedure docreateobject(var instance: tobject); override;
   procedure createitem(out item: tlistitem); override;
   procedure nodenotification(const sender: tlistitem;
                  var ainfo: nodeactioninfoty); override;
   procedure compare(const l,r; var result: integer); override;
   procedure statreaditem(const reader: tstatreader;
                    var aitem: tlistitem); override;
   procedure readstate(const reader; const acount: integer); override;
   procedure writestate(const writer; const name: msestring); override;
   procedure beforedragevent(var ainfo: draginfoty; const arow: integer;
                               var processed: boolean);
   procedure afterdragevent(var ainfo: draginfoty; const arow: integer;
                               var processed: boolean);
  public
   constructor create(const intf: iitemlist; const aowner: ttreeitemedit);
   procedure beginupdate; override;
   procedure endupdate; override;
   procedure assign(const root: ttreelistedititem); reintroduce; overload;
                 //root is freed
   procedure add(const anode: ttreelistedititem); overload;
                 //adds toplevel node
   procedure add(const anodes: treelistedititemarty); overload;
   procedure add(const acount: integer; 
                             aitemclass: treelistedititemclassty = nil); overload;
   function toplevelnodes: treelistedititemarty;
   function getnodes(const must: nodestatesty; const mustnot: nodestatesty;
                 const amode: getnodemodety = gno_matching): treelistitemarty;
   function getselectednodes(const amode: getnodemodety = 
                                              gno_matching): treelistitemarty;
   function getcheckednodes(const amode: getnodemodety = 
                                              gno_matching): treelistitemarty;
   procedure updatechildcheckedtree; //slow!
   
   procedure expandall;
   procedure collapseall;
   procedure moverow(const source,dest: integer);
    //source and dest must belong to the same parent, ignored otherwise
   property itemclass: treelistedititemclassty read getitemclass write setitemclass;
   property items[const index: integer]: ttreelistedititem read getitems1
                                          write setitems; default;
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
   property ondragbegin: treeitemdragbegineventty read fondragbegin 
                                          write fondragbegin;
   property ondragover: treeitemdragovereventty read fondragover
                                          write fondragover;
   property ondragdrop: treeitemdragdropeventty read fondragdrop
                                          write fondragdrop;
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
 
 ttreeitemedit = class(titemedit,idragcontroller)
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
//   procedure setfiltertext(const value: msestring); override;

   function locatecount: integer; override;        //number of locate values
   function locatecurrentindex: integer; override; //index of current row
   procedure locatesetcurrentindex(const aindex: integer); override;
   function getkeystring(const aindex: integer): msestring; override; //locate text

//   function getkeystring1(const aindex: integer): msestring;
//   function getkeystring2(const aindex: integer): msestring;
   procedure updatelayout; override;
   function getitemclass: listitemclassty; override;
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure docellevent(const ownedcol: boolean; var info: celleventinfoty); override;
   function checkrowmove(const curindex,newindex: integer): boolean;
   procedure updateitemvalues(const index: integer; const count: integer); override;
   function fieldcanedit: boolean;
   procedure beforecelldragevent(var ainfo: draginfoty; const arow: integer;
                               var processed: boolean); override;
   procedure aftercelldragevent(var ainfo: draginfoty; const arow: integer;
                               var processed: boolean); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function item: ttreelistitem;
   property items[const index: integer]: ttreelistitem read getitems 
                                                 write setitems; default;
   function candragsource(const apos: pointty): boolean;
   procedure dragdrop(const adragobject: ttreeitemdragobject);
  published
   property itemlist: ttreeitemeditlist read getitemlist write setitemlist;
   property fieldedit: trecordfieldedit read ffieldedit write setfieldedit;
   property options: treeitemeditoptionsty read foptions write foptions default [];
   property oncheckrowmove: checkmoveeventty read foncheckrowmove write foncheckrowmove;
//   property cursor default cr_default;
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
 tdatacols1 = class(tdatacols);

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

procedure titemviewlist.doitemchange(const index: integer);
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
   tlistitem.calcitemlayout(makesize(cellwidth,cellheight),minimalframe,
                                                             self,flayoutinfo);
  end
  else begin
   tlistitem.calcitemlayout(subsize(makesize(cellwidth,cellheight),
                                       fcellframe.paintframewidth),
                           tframe1(fcellframe).fi.innerframe,self,flayoutinfo);
  end;
  layoutchanged;
 end;
// invalidate;
end;

function titemviewlist.getcolorglyph: colorty;
begin
 result:= flistview.fcolorglyph;
end;

procedure titemviewlist.updateitemvalues(const index: integer;
                                                      const acount: integer);
begin
 //dummy
end;

function titemviewlist.getcomponentstate: tcomponentstate;
begin
 result:= flistview.componentstate;
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

procedure tlistcol.updatecellzone(const row: integer; const pos: pointty;
                                  var result: cellzonety);
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
  if (item <> nil) and (item.selected <> value) then begin
   include(tcustomgrid1(fgrid).fstate,gs_selectionchanged);
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

procedure tlistcol.docellevent(var info: celleventinfoty);
var
 hintinfo: hintinfoty;
 item1: tlistitem;
begin
 with tcustomlistview(fgrid) do begin
  if (lvo_hintclippedtext in foptions) and 
         (info.eventkind = cek_firstmousepark) and application.active and 
          getshowhint and (info.cell.row >= 0) then begin
   item1:= self[info.cell.row];
   if item1 <> nil then begin
    with item1 do begin
     if captionclipped then begin
      application.inithintinfo(hintinfo,fgrid);
      hintinfo.caption:= caption;
      application.showhint(fgrid,hintinfo);
     end;
    end;
   end;
  end;
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

procedure tlistcols.setselectedrange(const start,stop: gridcoordty;
               const value: boolean;
               const calldoselectcell: boolean = false;
               const checkmultiselect: boolean = false);
var
 int1,int2,int3: integer;
 sto1: gridcoordty;
begin
 sto1:= stop;
 if sto1.col < start.col then begin
  inc(sto1.col);
 end
 else begin
  if sto1.col = start.col then begin
   exit;
  end;
  dec(sto1.col);
 end;
 if sto1.row < start.row then begin
  inc(sto1.row);
 end
 else begin
  if sto1.row = start.row then begin
   exit;
  end;
  dec(sto1.row);
 end;

 if value and checkmultiselect and 
       not (lvo_multiselect in tcustomlistview(fgrid).foptions) then begin
  with tcustomlistview(fgrid) do begin
   if calldoselectcell then begin
    selectcell(invalidcell,csm_deselect);
    selectcell(sto1,csm_select);
   end
   else begin
    selected[invalidcell]:= false;
    selected[sto1]:= true;
   end;
  end;
  exit;
 end;

 with tcustomlistview(fgrid) do begin
  int1:= celltoindex(start,true);
  int2:= celltoindex(sto1,true);
  if int1 > int2 then begin //swap values
   int3:= int1;
   int1:= int2;
   int2:= int3;
  end;
  if calldoselectcell and value then begin
   for int1:= int1 to int2 do begin
    selectcell(indextocell(int1),csm_select);
   end;
  end
  else begin
   for int1:= int1 to int2 do begin
    selected[indextocell(int1)]:= value;
   end;
  end;
 end;
end;

procedure tlistcols.changeselectedrange(const start,oldend,newend: gridcoordty;
             calldoselectcell: boolean);

 procedure select(start,stop: integer; value: boolean);
 var
  int1: integer;
  mo1: cellselectmodety;
 begin
  with tcustomlistview(fgrid) do begin
   if calldoselectcell then begin
    if value then begin
     mo1:= csm_select;
    end
    else begin
     mo1:= csm_deselect;
    end;
    for int1:= start to stop do begin
     selectcell(indextocell(int1),mo1{value,false});
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
  if not (lvo_multiselect in options) then begin
   if calldoselectcell then begin
    selectcell(invalidcell,csm_deselect);
    selectcell(newend,csm_select);
   end
   else begin
    selected[invalidcell]:= false;
    selected[newend]:= true;
   end;
   exit;
  end;
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
 fcellcursor:= cr_default;
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
      {$ifdef FPC}longword{$else}longword{$endif}(foptions),
      {$ifdef FPC}longword{$else}longword{$endif}(item.options),
      {$ifdef FPC}longword{$else}longword{$endif}(coloptionsmask)));
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
 tcellframe.create(iscrollframe(self));
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
 if locatestring(acaption,{$ifdef FPC}@{$endif}getkeystring,locopt,
                               fitemlist.count,int1) then begin
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
 width1,height1: integer;
begin
 indexbefore:= celltoindex(ffocusedcell,true);
 fitemlist.updatelayout;
 width1:= fcellwidth;
 height1:= datarowheight;
 if lvo_fill in foptions then begin
  inherited;
  if lvo_horz in foptions then begin
   width1:= finnerdatarect.cx - datacollinewidth;
  end
  else begin
   height1:= finnerdatarect.cy - datarowlinewidth;
  end;
 end;
 if (width1 <> 0) and (fcellwidthmin > width1) then begin
  width1:= fcellwidthmin;
 end;
 if (fcellwidthmax <> 0) and (fcellwidthmax < width1) then begin
  width1:= fcellwidthmax;
 end;
 datarowheight:= height1;
 for int1:= 0 to fdatacols.count-1 do begin
  fdatacols[int1].width:= width1;
  fdatacols[int1].cursor:= fcellcursor;
 end;
 repeat
  inherited;
  bo1:= false;
  if lvo_horz in foptions then begin
   int1:=  tlistcol.defaultstep(width1);
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
  fcellwidthmax:= Value;
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
 item1: tlistitem1;
begin
 canvas.save;
 drawcellbackground(canvas);
 item1:= tlistitem1(focuseditem);
 if item1 <> nil then begin
  item1.drawimage(canvas);
  po1:= cellrect(ffocusedcell,cil_paint).pos;
  canvas.remove(po1);
  feditor.dopaint(canvas);
  canvas.move(po1);
  if feditor.lasttextclipped then begin
   include(item1.fstate1,ns1_captionclipped);   
  end
  else begin
   exclude(item1.fstate1,ns1_captionclipped);   
  end;
 end;
 canvas.restore;
 drawcelloverlay(canvas);
end;

procedure tcustomlistview.setoptions(const avalue: listviewoptionsty);
const
 mask: listviewoptionsty = [lvo_horz,lvo_fill];
var
 optbefore: listviewoptionsty;
begin
 if foptions <> avalue then begin
  optbefore:= foptions;
  foptions:= avalue;
  updatecoloptions;
  if (longword(foptions) xor longword(optbefore)) and 
                                         longword(mask) <> 0 then begin
   layoutchanged;
  end;
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

function tcustomlistview.locatecount: integer;        //number of locate values
begin
 result:= fitemlist.count;
end;

function tcustomlistview.locatecurrentindex: integer; //index of current row
begin
 result:= celltoindex(ffocusedcell,false);
end;

procedure tcustomlistview.locatesetcurrentindex(const aindex: integer);
begin
 focuscell(indextocell(aindex));
end;

function tcustomlistview.edited: boolean;
begin
 result:= false;
end;

function tcustomlistview.getkeystring(const index: integer): msestring;
begin
 result:= fitemlist[index].caption;
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
   feditor.updatecaret;
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
//     filtertext:= '';
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
  fcellwidth:= Value;
  layoutchanged;
 end;
end;

function tcustomlistview.getcellheight: integer;
begin
 result:= datarowheight;
end;

procedure tcustomlistview.setcellheight(const avalue: integer);
begin
 datarowheight:= avalue;
{
 if fcellheight <> avalue then begin
  fcellheight:= avalue;
  layoutchanged;
 end;
}
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
 result:= [oe_autoselect,oe_resetselectonexit,oe_exitoncursor];
 if lvo_locate in foptions then begin
  include(result,oe_locate);
 end;
 if lvo_casesensitive in foptions then begin
  include(result,oe_casesensitive);
 end;
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
      tlistitemdragobject.create(self,dragobjectpo^,fdragcontroller.pickpos,item);
     end;
     dek_check: begin
      accept:= item <> focuseditem;
     end;
     dek_drop: begin
      moveitem(tlistitemdragobject(dragobjectpo^).item,item,true);
     end;
    end;
   end;
  end;
 end;
 inherited;
end;
(*
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
*)
procedure tcustomlistview.dokeydown(var info: keyeventinfoty);
var
 item: tlistitem;
 int1: integer;
 str1: msestring;
 action1: focuscellactionty;
begin
 with info do begin
  feditor.dokeydown(info);
//  if fediting then begin
//   if ((key = key_left) or (key = key_right)) and (shiftstate - [ss_shift] = []) then begin
//    include(eventstate,es_processed);
//   end;
//  end
//  else begin
  {
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
   }
//  end;
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
    if (shiftstate = []) and isenterkey(nil,key) then begin
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

procedure tcustomlistview.setcellcursor(const avalue: cursorshapety);
var
 int1: integer;
begin
 if avalue <> fcellcursor then begin
  fcellcursor:= avalue;
  with tdatacols1(fdatacols) do begin
   cursor:= avalue;
   for int1:= 0 to count-1 do begin
    tdatacol(fitems[int1]).cursor:= avalue;
   end;
  end;
 end;
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

function tcustomlistview.hasselection: boolean;
begin
 result:= false;
end;

procedure tcustomlistview.updatecopytoclipboard(var atext: msestring);
begin
 if canevent(tmethod(foncopytoclipboard)) then begin
  foncopytoclipboard(self,atext);
 end;
end;

procedure tcustomlistview.updatepastefromclipboard(var atext: msestring);
begin
 if canevent(tmethod(fonpastefromclipboard)) then begin
  fonpastefromclipboard(self,atext);
 end;
end;

function tcustomlistview.getonlayoutchanged: listvieweventty;
begin
 result:= listvieweventty(inherited onlayoutchanged);
end;

procedure tcustomlistview.setonlayoutchanged(const avalue: listvieweventty);
begin
 inherited onlayoutchanged:= gridnotifyeventty(avalue);
end;

function tcustomlistview.getonbeforeupdatelayout: listvieweventty;
begin
 result:= listvieweventty(inherited onbeforeupdatelayout);
end;

procedure tcustomlistview.setonbeforeupdatelayout(const avalue: listvieweventty);
begin
 inherited onbeforeupdatelayout:= gridnotifyeventty(avalue);
end;

function tcustomlistview.getcellheightmin: integer;
begin
 result:= datarowheightmin;
end;

procedure tcustomlistview.setcellheightmin(const avalue: integer);
begin
 datarowheightmin:= avalue;
end;

function tcustomlistview.getcellheightmax: integer;
begin
 result:= datarowheightmax;
end;

procedure tcustomlistview.setcellheightmax(const avalue: integer);
begin
 datarowheightmax:= avalue;
end;

{ tcustomitemeditlist }

constructor tcustomitemeditlist.create(const intf: iitemlist; const owner: titemedit);
begin
 fcolorglyph:= cl_black;
 fowner:= owner;
 inherited create(intf);
 fitemclass:= tlistedititem;
 include(fstate,dls_nogridstreaming);
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
  exclude(fitemstate,ils_subnodecountupdating); //free nodes
  clear;
  include(fitemstate,ils_subnodecountupdating);
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
 checkitemclass(anode);
 beginupdate;
 try
  int1:= internaladddata(anode,false);
  tlistitem1(anode).findex:= int1;
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

procedure tcustomitemeditlist.doitemchange(const index: integer);
begin
 fowner.itemchanged(index);
 inherited;
end;

procedure tcustomitemeditlist.nodenotification(const sender: tlistitem;
                     var ainfo: nodeactioninfoty);
var
 grid: tcustomgrid;
begin
 if ainfo.action = na_destroying then begin
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
   fonitemnotification(sender,ainfo.action);
  end;
  inherited;
  if ainfo.action in [na_expand,na_collapse] then begin
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

function titemeditlist.getitemclass: listedititemclassty;
begin
 result:= listedititemclassty(fitemclass);
end;

procedure titemeditlist.setitemclass(const avalue: listedititemclassty);
begin
 fitemclass:= avalue;
end;

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
 fediting:= true;
 if fitemlist = nil then begin
  fitemlist:=  titemeditlist.create(iitemlist(self),self);
 end;
 inherited;
 textflags:= defaultitemedittextflags;
 textflagsactive:= defaultitemedittextflagsactive;
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

function titemedit.getdatatype: listdatatypety;
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
   rowdatachanged(makegridcoord(invalidaxis,0),fitemlist.count);
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

procedure titemedit.gridtovalue(arow: integer);
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
   fitemlist.incupdate;
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

procedure titemedit.valuetogrid(arow: integer);
begin
 fitemlist.incupdate;
 try
  updateitemvalues(arow,1);
 finally
  fitemlist.decupdate;
 end;
end;

procedure titemedit.drawcell(const canvas: tcanvas);
begin
 with cellinfoty(canvas.drawinfopo^) do begin
  flayoutinfo.textflags:= textflags;
  tlistitem(datapo^).drawcell(canvas);
 end;
end;

function titemedit.internaldatatotext(const data): msestring;
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
 mstr1: msestring;
begin
 mstr1:= feditor.text;
 checktext(mstr1,accept);
 if not accept then begin
  exit;
 end;
 if not quiet then begin
  dosetvalue(mstr1,accept);
 end;
 if accept and (fvalue <> nil) then begin
  fvalue.caption:= mstr1;
 end;
end;

procedure titemedit.updatelayout;
begin
 if fgridintf <> nil then begin
  if fframe <> nil then begin
   getitemclass.calcitemlayout(paintrect.size,tframe1(fframe).fi.innerframe,
                                                        fitemlist,flayoutinfo);
  end
  else begin
   getitemclass.calcitemlayout(paintrect.size,minimalframe,fitemlist,
                                                                  flayoutinfo);
  end;
  invalidate;
  if not fitemlist.updating then begin
   fgridintf.getcol.changed;
  end;
 end;
end;

procedure titemedit.clientrectchanged;
begin
 updatelayout;
 inherited;
end;

procedure titemedit.doitembuttonpress(var info: mouseeventinfoty);
begin
 //dummy
end;

procedure titemedit.clientmouseevent(var info: mouseeventinfoty);
var
 po1: pointty;
 cursor1: cursorshapety;
 zone1: cellzonety;
begin
 if (fvalue <> nil) and (info.eventkind in mouseposevents) then begin
  zone1:= cz_default;
  fvalue.updatecellzone(info.pos,zone1);
  application.widgetcursorshape:= getcellcursor(-1,zone1);
 {
  if not editing then begin
   application.widgetcursorshape:= cursorreadonly;
  end
  else begin
   application.widgetcursorshape:= getcellcursor(-1,zone1);
  end;
 }
 end;
 if canevent(tmethod(fonclientmouseevent)) then begin
  fonclientmouseevent(self,info);
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
  if fgridintf <> nil then begin
   acanvas.rootbrushorigin:= fgridintf.getbrushorigin;
  end;
  with tlistitem1(fvalue) do begin
   drawimage(acanvas);
   if feditor.lasttextclipped then begin
    include(fstate1,ns1_captionclipped);
   end
   else begin
    exclude(fstate1,ns1_captionclipped);
   end;
  end;
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
 doonkeydown(info);
 with info do begin
  if not(es_processed in eventstate) then begin
   if (oe_locate in foptionsedit) and isenterkey(nil,key) and 
                       (shiftstate = []) then begin
    if not editing then begin
     editing:= (item <> nil) and not (ns_readonly in item.state) and 
                  not (oe_readonly in foptionsedit);
     if editing then begin
      include(eventstate,es_processed);
     end;
    end
    else begin
     inherited;
     editing:= false;
     include(eventstate,es_processed);
    end;
   end;
{   
   if not(es_processed in eventstate) and islocating then begin
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
}
  end;
 end;
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;
{
procedure titemedit.dokeyup(var info: keyeventinfoty);
begin
 if canevent(tmethod(fonkeyup)) then begin
  fonkeyup(self,info);
 end;
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;
}
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

procedure titemedit.internalcreateframe;
begin
 tcustombuttonframe.create(iscrollframe(self),ibutton(self));
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
 if fframe <> nil then begin
  tcustombuttonframe(fframe).mouseevent(info);
 end;
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

function titemedit.locatecount: integer;        //number of locate values
begin
 result:= fitemlist.count;
end;

function titemedit.getkeystring(const index: integer): msestring;
begin
 result:= fitemlist[index].caption;
end;
{
function titemedit.islocating: boolean;
begin
 result:= not editing and (oe_locate in foptionsedit)
end;
}
(*
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
 updatefilterselect;
end;
*)

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
//    if eventkind = cek_exit then begin
//     filtertext:= '';
//    end;
   end;
  end;
  if (info.eventkind = cek_enter) or 
                    (info.eventkind = cek_exit) then begin
   if oe_locate in foptionsedit then begin
    editing:= false;
   end;
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
procedure titemedit.updatefilterselect;
begin
 if islocating then begin
  feditor.selstart:= 0;
  feditor.sellength:= length(ffiltertext);
 end;
end;
}
procedure titemedit.setediting(const avalue: boolean);
begin
 if fediting <> avalue then begin
  if avalue or (oe_locate in foptionsedit) then begin
   fediting:= avalue;
   setupeditor;
   if fediting then begin
//    ffiltertext:= '';
    feditor.selectall;
   end
   else begin
    if foptionsedit * [oe_autoselect,oe_locate] = [oe_autoselect] then begin
     feditor.selectall;
    end;
//    updatefilterselect;
   end;
  end
  else begin
   fediting:= false;
  end;
 end;
 if application.clientmousewidget = self then begin
  if not fediting then begin
   application.widgetcursorshape:= cursorreadonly;
  end
  else begin
   application.widgetcursorshape:= cursor;
  end;
 end;
end;

function titemedit.getoptionsedit: optionseditty;
begin
 result:= inherited getoptionsedit;
 if oe_readonly in result then begin
  editing:= false;
 end;
 if not editing and not (csdesigning in componentstate) then begin
  include(result,oe_readonly);
 end;
end;

procedure titemedit.beginedit;
begin
 editing:= true;
end;

procedure titemedit.endedit;
begin
 editing:= false;
end;

function titemedit.getcellcursor(const arow: integer;
                                  const acellzone: cellzonety): cursorshapety;
begin
 if (acellzone = cz_caption) and 
                       ((foptionsedit * [oe_locate,oe_readonly] = []) or
                       (arow < 0) and (editing)) then begin
  result:= cursor;
 end
 else begin
  if (acellzone = cz_caption) and 
                       (foptionsedit * [oe_locate,oe_readonly] <> []) then begin
   result:= cursorreadonly;
  end
  else begin
   result:= cr_arrow;
//   result:= cr_default;
  end;
 end;
end;

procedure titemedit.updatecellzone(const row: integer; const apos: pointty;
                            var result: cellzonety);
begin
 inherited;
 if fitemlist <> nil then begin
  fitemlist[row].updatecellzone(apos,result);
 end;
end;

function titemedit.actualcursor(const apos: pointty): cursorshapety;
var
 zone1: cellzonety;
 int1: integer;
begin
 if fgridintf <> nil then begin 
  zone1:= cz_default;
  int1:= fgridintf.grid.row;
  updatecellzone(int1,widgetpostoclientpos(apos),zone1);
  result:= getcellcursor(int1,zone1);
 end
 else begin
  result:= inherited actualcursor(apos);
 end;
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
 fcontrollerintf:= idataeditcontroller(fdropdown);
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
{
procedure tdropdownitemedit.internalcreateframe;
begin
 fdropdown.createframe;
end;
}
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
{
procedure tdropdownitemedit.editnotification(var info: editnotificationinfoty);
begin
 if fdropdown <> nil then begin
  fdropdown.editnotification(info);
 end;
 inherited;
end;
}
procedure tdropdownitemedit.dobeforedropdown;
begin
 if canevent(tmethod(fonbeforedropdown)) then begin
  fonbeforedropdown(self);
 end;
end;
{
procedure tdropdownitemedit.dokeydown(var info: keyeventinfoty);
begin
 fdropdown.dokeydown(info);
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;
}
function tdropdownitemedit.getdropdownitems: tdropdowncols;
begin
 result:= nil;
end;

procedure tdropdownitemedit.setdropdown(const Value: tcustomdropdownlistcontroller);
begin
 fdropdown.assign(Value);
end;

function tdropdownitemedit.getvalueempty: integer;
begin
 result:= -1;
end;
{
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
}
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
 include(fstate1,ns1_noowner);
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

procedure ttreelistedititem.add(const acount: integer;
                   const itemclass: treelistedititemclassty = nil);
begin
 inherited add(acount,itemclass);
end;

procedure ttreelistedititem.add(const captions: array of msestring; 
               const itemclass: treelistedititemclassty = nil);
var
 countbefore: integer;
 int1: integer;
begin
 countbefore:= count;
 inherited add(length(captions),itemclass);
 for int1:= countbefore to count-1 do begin
  ttreelistedititem(fitems[int1]).caption:= captions[int1-countbefore];
 end;
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
 fitemclass:= ttreelistedititem;
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

procedure ttreeitemeditlist.createitem(out item: tlistitem);
begin
 item:= treelistedititemclassty(fitemclass).create(self);
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

procedure ttreeitemeditlist.change(const index: integer);
begin
 if (index < 0) and (no_updatechildchecked in foptions) and 
                                         (nochange = 0) then begin
  inherited beginupdate; //no ils_subnodecountupdating
  try
   updatechildcheckedtree;
  finally
   decupdate;
  end;
 end;
 inherited change(index);
end;

procedure ttreeitemeditlist.freedata(var data);
var
 int1: integer;
 po1: ptreelistitem;
begin
 if not (ils_freelock in fitemstate) then begin
  if pointer(data) <> nil then begin
   with ttreelistitem1(data) do begin
    if fowner <> nil then begin
     ttreelistitem1(data).setowner(nil);
    end;
    if fparent = nil then begin
     for int1:= findex + 1 to self.fcount - 1 do begin
      po1:= ptreelistitem(getitempo(int1));
      if ttreelistitem1(po1^).ftreelevel = 0 then begin
       break; //next root node
      end;
      po1^:= nil;
     end;
     if not (ils_subnodecountupdating in self.fitemstate) then begin
      inherited; //free node
     end;
    end
   end;
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
    exclude(fitemstate,ils_subnodecountupdating); //free nodes
    clear;
    include(fitemstate,ils_subnodecountupdating);
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
 beginupdate;
 try
  for int1:= 0 to high(anodes) do begin
   add(anodes[int1]);
  end;
 finally
  endupdate;
 end;
end;

procedure ttreeitemeditlist.add(const acount: integer; 
                              aitemclass: treelistedititemclassty = nil);
var
 int1: integer;
begin
 beginupdate;
 if aitemclass = nil then begin
  aitemclass:= itemclass; //default
 end;
 try
  for int1:= 0 to acount - 1 do begin
   add(aitemclass.create);
  end;
 finally
  endupdate;
 end;
end;

function ttreeitemeditlist.getoncreateitem: createtreelistitemeventty;
begin
 result:= createtreelistitemeventty(oncreateobject);
end;

procedure ttreeitemeditlist.nodenotification(const sender: tlistitem;
  var ainfo: nodeactioninfoty);

 procedure expand;
 var
  int1,int2: integer;
  grid1: tcustomgrid;
  po1: ptreelistedititematy;
 begin
  with ttreeitemedit(fowner) do begin
   if ttreelistitem1(sender).fcount > 0 then begin
    fchangingnode:= ttreelistitem(sender);
    int2:= sender.index+1; //list row insert position
    finsertcount:= int2;   //list row insert position counter
    finsertindex:= 0;
    int1:= ttreelistitem(sender).treeheight;
    try
     include(fstate,ies_updating);
     grid1:= fgridintf.getcol.grid;
     incupdate;
     grid1.insertrow(finsertcount,int1);      
     decupdate;
     exclude(fstate,ies_updating);
     fintf.updateitemvalues(int2,int1);
     int1:= int2+int1;
     if int2 < fcount then begin
      po1:= datapo;
      for int1:= int1 to fcount - 1 do begin
       po1^[int1].findex:= int1;
      end;
     end;
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
 int1,int2: integer;

begin
 if ainfo.action = na_destroying then begin
  int2:= sender.index;
  tlistitem1(sender).setowner(nil);
  if not deleting and (ttreelistitem(sender).parent = nil) then begin
   with ttreelistitem(sender) do begin
    if expanded then begin
     int1:= treeheight+1;
    end
    else begin
     int1:= 1;
    end;
   end;
   incupdate;
   fowner.fgridintf.getcol.grid.deleterow(int2,int1);
   decupdate;
  end;
 end
 else begin
  inherited;
  case ainfo.action of
   na_countchange: begin
    if not updating then begin
     with ttreelistitem1(sender) do begin
      if ns_expanded in fstate then begin
       int1:= findex+1;
       if (findex < self.fcount-1)  then begin
       {
        po1:= getitempo(int1);
        int1:= findex+1;
        po1:= getitempo(int1);
        while (int1 < self.fcount) and (po1^.ftreelevel > ftreelevel) do begin
         inc(int1);
         inc(po1);
        end;
        self.fowner.fgridintf.getcol.grid.deleterow(findex+1,int1-findex-1);
        }
        int2:= ainfo.treeheightbefore;
        if int2 > 0 then begin
         include(self.fitemstate,ils_freelock);
         try
          self.fowner.fgridintf.getcol.grid.deleterow(int1,int2);
         finally
          exclude(self.fitemstate,ils_freelock);
         end;
        end;
       end;
       expand;
       {
       po1:= getitempo(int1);
       for int1:= int1 to self.fcount-1 do begin
        po1^.findex:= int1;
        inc(po1);
       end;
       }
      end;
     end;
    end
    else begin
     include(fitemstate,ils_subnodecountinvalid);
    end;
   end;
   na_expand: begin
    if not (ils_subnodecountupdating in fitemstate) then begin
     expand;
    end
    else begin
     include(fitemstate,ils_subnodecountinvalid);
    end;
   end;
   na_collapse: begin
    if not (ils_subnodecountupdating in fitemstate) then begin
     with ttreeitemedit(fowner) do begin
      fgridintf.getcol.grid.deleterow(sender.index+1,ttreelistitem(sender).treeheight);
      if fvalue = sender then begin
       expandedchanged(false);
      end;
     end;
    end
    else begin
     include(fitemstate,ils_subnodecountinvalid);
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

function ttreeitemeditlist.getnodes(const must: nodestatesty; 
                   const mustnot: nodestatesty;
                   const amode: getnodemodety = gno_matching): treelistitemarty;
var
 int1,int2: integer; 
 po1: ptreelistitematy;
begin
 result:= nil;
 int2:= 0;
 po1:= datapo;
 for int1:= 0 to count - 1 do begin
  if po1^[int1].parent = nil then begin
   ttreelistitem1(po1^[int1]).internalgetnodes(result,int2,must,
                                                      mustnot,amode,true);
  end;
 end;
 setlength(result,int2);
end;

function ttreeitemeditlist.getselectednodes(
                     const amode: getnodemodety = gno_matching): treelistitemarty;
begin
 result:= getnodes([ns_selected],[],amode);
end;

function ttreeitemeditlist.getcheckednodes(
                     const amode: getnodemodety = gno_matching): treelistitemarty;
begin
 result:= getnodes([ns_checked],[],amode);
end;

procedure ttreeitemeditlist.updatechildcheckedtree;
var
 int1: integer;
 po1: ptreelistedititematy;
begin
 beginupdate;
 try
  po1:= datapo;
  for int1:= 0 to count - 1 do begin
   with po1^[int1] do begin
    if ftreelevel = 0 then begin
     updatechildcheckedtree;
    end;
   end;
  end;
 finally
  endupdate;
 end;
end;

procedure ttreeitemeditlist.expandall;
var
 int1: integer;
 po1: ptreelistedititematy;
begin
 beginupdate;
 try
  po1:= datapo;
  for int1:= 0 to count - 1 do begin
   with po1^[int1] do begin
    if ftreelevel = 0 then begin
     expandall;
    end;
   end;
  end;
 finally
  endupdate;
 end;
end;

procedure ttreeitemeditlist.collapseall;
var
 int1: integer;
 po1: ptreelistedititematy;
begin
 beginupdate;
 try
  po1:= datapo;
  for int1:= 0 to count - 1 do begin
   with po1^[int1] do begin
    if ftreelevel = 0 then begin
     collapseall;
    end;
   end;
  end;
 finally
  endupdate;
 end;
end;

procedure ttreeitemeditlist.beginupdate;
begin
 if nochange = 0 then begin
  include(fitemstate,ils_subnodecountupdating);
 end;
 inherited;
end;

procedure ttreeitemeditlist.endupdate;
var
 ar1: treelistedititemarty;
begin
 ar1:= nil; //compilerwarning
 if (nochange = 1) then begin
  if (ils_subnodecountinvalid in fitemstate) then begin
   exclude(fitemstate,ils_subnodecountinvalid);
   ar1:= toplevelnodes;
   include(fitemstate,ils_subnodecountupdating);
   fowner.fgridintf.getcol.grid.rowcount:= 0;
   clear;
   exclude(fitemstate,ils_subnodecountupdating);
   add(ar1);
  end
  else begin
   exclude(fitemstate,ils_subnodecountupdating);
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

function istreeitemdrag(const ainfo: draginfoty): boolean;
begin
 result:= (ainfo.dragobjectpo <> nil) and 
                       (ainfo.dragobjectpo^ is ttreeitemdragobject);
end;

procedure ttreeitemeditlist.beforedragevent(var ainfo: draginfoty;
               const arow: integer; var processed: boolean);
var
 bo1: boolean;
 item1: ttreelistitem;
 zone1: cellzonety;
 rect1: rectty;
begin
 item1:= ttreelistitem(items[arow]);
 case ainfo.eventkind of
  dek_begin: begin
   zone1:= cz_none;
   item1.updatecellzone(fowner.fgridintf.getcol.translatetocell(arow,
                              ainfo.clientpickpos),zone1);
   if zone1 = cz_caption then begin
    bo1:= item1.candrag;
    if assigned(fondragbegin) then begin
     fondragbegin(ttreeitemedit(fowner),item1,bo1,
                     ttreeitemdragobject(ainfo.dragobjectpo^),processed);
    end;
    if not processed and bo1 then begin
     if ainfo.dragobjectpo^ = nil then begin
      ttreeitemdragobject.create(ttreeitemedit(fowner),ainfo.dragobjectpo^,
                      ainfo.pickpos,item1);
      processed:= true;
     end;
    end;
//    if ainfo.dragobjectpo^ <> nil then begin
//     ttreeitemdragobject(ainfo.dragobjectpo^).fsourcerow:= arow;
//    end;
   end;
  end;
  dek_check: begin
   if istreeitemdrag(ainfo) then begin
    with ttreeitemdragobject(ainfo.dragobjectpo^) do begin
     if item <> item1 then begin
      bo1:= item1.candrop(item);
      if assigned(fondragover) then begin
       fdestrow:= arow;
       fondragover(ttreeitemedit(fowner),item,item1,
                      ttreeitemdragobject(ainfo.dragobjectpo^),bo1,processed);
       ainfo.accept:= bo1;
      end;
     end;
    end;
   end;
  end;
  dek_drop: begin
   if istreeitemdrag(ainfo) then begin
    with ttreeitemdragobject(ainfo.dragobjectpo^) do begin
     if (item.owner = self) and assigned(fondragdrop) then begin
      fdestrow:= arow;
      fondragdrop(ttreeitemedit(fowner),item,item1,
                     ttreeitemdragobject(ainfo.dragobjectpo^),processed);
     end;
    end;
   end;
  end;
 end;
end;

procedure ttreeitemeditlist.afterdragevent(var ainfo: draginfoty;
               const arow: integer; var processed: boolean);
begin
 //dummy
end;

procedure ttreeitemeditlist.moverow(const source: integer; const dest: integer);
var
 so,de: ttreelistitem1;
begin
 so:= ttreelistitem1(items[source]);
 de:= ttreelistitem1(items[dest]);
 if so.parent = de.parent then begin
  if so.parent <> nil then begin
   ttreelistitem1(so.parent).move(so.parentindex,de.parentindex);
  end;
  fowner.fgridintf.getcol.grid.moverow(so.index,de.index,so.treeheight+1);
  de.findex:= source;
  so.findex:= dest;
 end;
end;

function ttreeitemeditlist.getitems1(const index: integer): ttreelistedititem;
begin
 result:= ttreelistedititem(inherited getitems1(index));
end;

procedure ttreeitemeditlist.setitems(const index: integer;
               const avalue: ttreelistedititem);
begin
 inherited setitems(index,avalue);
end;

function ttreeitemeditlist.getitemclass: treelistedititemclassty;
begin
 result:= treelistedititemclassty(fitemclass);
end;

procedure ttreeitemeditlist.setitemclass(const avalue: treelistedititemclassty);
begin
 fitemclass:= avalue;
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
// fdragcontroller:= ttreeitemdragcontroller.create(self);
 if fitemlist = nil then begin
  fitemlist:=  ttreeitemeditlist.create(iitemlist(self),self);
 end;
 inherited;
// cursor:= cr_default;
end;

destructor ttreeitemedit.destroy;
begin
// fdragcontroller.free;
 inherited;
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

(*
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
*)

function ttreeitemedit.locatecount: integer;        //number of locate values
begin
 if (fvalue = nil) or (ttreelistitem1(fvalue).treelevel = 0) then begin
  result:= fitemlist.count;
 end
 else begin
  result:= ttreelistitem1(ttreelistitem1(fvalue).fparent).count
 end;
end;

function ttreeitemedit.locatecurrentindex: integer; //index of current row
begin
 if (fvalue = nil) or (ttreelistitem1(fvalue).treelevel = 0) then begin
  result:= factiverow;
 end
 else begin
  result:= ttreelistitem1(fvalue).fparentindex
 end;
end;

procedure ttreeitemedit.locatesetcurrentindex(const aindex: integer);
begin
 if (fvalue = nil) or (ttreelistitem1(fvalue).treelevel = 0) then begin
  inherited;
 end
 else begin
  fgridintf.getcol.grid.row:=
        ttreelistitem1(ttreelistitem1(ttreelistitem1(fvalue).fparent).
                                                      fitems[aindex]).findex;
 end;
end;

function ttreeitemedit.getkeystring(const aindex: integer): msestring; //locate text
begin
 if (fvalue = nil) or (ttreelistitem1(fvalue).treelevel = 0) then begin
  with ttreelistitem1(fitemlist[aindex]) do begin
   if treelevel = 0 then begin
    result:= caption;
   end
   else begin
    result:= '';
   end;
  end;
 end
 else begin
  with ttreelistitem1(ttreelistitem1(fvalue).fparent) do begin
   result:= fitems[aindex].caption;
  end;
 end;
end;

(*
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
 if islocating then begin
  feditor.selstart:= 0;
  feditor.sellength:= length(ffiltertext);
 end;
end;
*)

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

procedure ttreeitemedit.updateitemvalues(const index: integer; 
                                           const count: integer);
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
 doonkeydown(info);
 with info do begin
  if (fgridintf <> nil) and not (es_processed in eventstate) and
                                                  (fvalue <> nil) then begin
   with twidgetgrid1(fgridintf.getcol.grid),ttreelistitem1(fvalue) do begin
    if shiftstate = [] then begin
     atreelevel:= treelevel;
     equallevelindex:= -1;
     cellbefore:= ffocusedcell;
     if (teo_treecolnavig in self.foptions) and 
                    not editing then begin
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
      if ((count = 0) or not expanded) then begin
       if ftreelevel > 0 then begin
        int1:= parentindex;
        if key = key_up then begin
         if (int1 > 0) and (itemlist[row].parent = itemlist[row-1].parent) and 
                    checkrowmove(row,row-1) then begin
          ttreelistitem1(fparent).swap(int1,int1-1);
          moverow(row,row-1,1);
         end;
        end
        else begin //key_down
         if (int1 < fparent.count-1) and 
              (itemlist[row].parent = itemlist[row+1].parent) and
               checkrowmove(row,row+1) then begin
          ttreelistitem1(fparent).swap(int1,int1+1);
          moverow(row,row+1,1);
         end;
        end;
       end
       else begin
        if key = key_up then begin
         if (row > 0) then begin
          if ttreelistitem(itemlist[row-1]).issinglerootrow and 
                                             checkrowmove(row,row-1) then begin
           moverow(row,row-1,1);
          end;
         end;
        end
        else begin //key_down
         if (row < rowhigh) then begin
          if ttreelistitem(itemlist[row+1]).issinglerootrow and 
                                             checkrowmove(row,row+1) then begin
           moverow(row,row+1,1);
          end;
         end;
        end;
       end;
      end;
      showcell(focusedcell);
     end;
    end;
   end
  end;
  if not (es_processed in eventstate) then begin
   inherited;
  end;
 end;
end;

procedure ttreeitemedit.dragdrop(const adragobject: ttreeitemdragobject);
var
 bo1: boolean;
 de,pa: ttreelistitem;
 sourcer: integer;
 destr: integer;
begin
 if fgridintf <> nil then begin
  with adragobject do begin
   de:= items[destrow];
   pa:= de.parent;
   if pa <> nil then begin
    fitemlist.beginupdate;
    bo1:= (item.owner = fitemlist) and 
                   not (ils_subnodecountinvalid in fitemlist.fitemstate);
    sourcer:= item.index;
    pa.insert(item,de.parentindex);
    if bo1 then begin
     destr:= destrow;
     if destr > sourcer then begin
      destr:= destr + de.rowheight - 1;
     end;
     fgridintf.getcol.grid.moverow(sourcer,destr,item.rowheight);
     exclude(fitemlist.fitemstate,ils_subnodecountinvalid);
    end;
    fitemlist.endupdate;
   end;
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

procedure ttreeitemedit.docellevent(const ownedcol: boolean;
                                                   var info: celleventinfoty);
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
{
procedure ttreeitemedit.setdrag(const avalue: ttreeitemdragcontroller);
begin
 fdragcontroller.assign(avalue);
end;
}
(*
procedure ttreeitemedit.clientmouseevent(var info: mouseeventinfoty);
begin
 inherited;
 {
 if not (es_processed in info.eventstate) then begin
  fdragcontroller.clientmouseevent(info);
 end;
 }
end;
*)
{
procedure ttreeitemedit.dragevent(var info: draginfoty);
begin
 if not fdragcontroller.beforedragevent(info) then begin
  inherited;
 end;
 fdragcontroller.afterdragevent(info);
end;
}
procedure ttreeitemedit.beforecelldragevent(var ainfo: draginfoty;
               const arow: integer; var processed: boolean);
begin
 ttreeitemeditlist(fitemlist).beforedragevent(ainfo,arow,processed);
end;

procedure ttreeitemedit.aftercelldragevent(var ainfo: draginfoty;
               const arow: integer; var processed: boolean);
begin
 ttreeitemeditlist(fitemlist).afterdragevent(ainfo,arow,processed);
end;

(*
{ ttreeitemdragcontroller }

constructor ttreeitemdragcontroller.create(const aowner: ttreeitemedit);
begin
 fowner:= aowner;
 inherited create(idragcontroller(aowner));
end;

function ttreeitemdragcontroller.beforedragevent(var info: draginfoty): boolean;
var
 bo1: boolean;
 item1: ttreelistitem;
begin
 result:= false;
 item1:= fowner.item;
 case info.eventkind of
  dek_begin: begin
   bo1:= item1.candrag;
   if assigned(fondragbegin) then begin
    fondragbegin(fowner,item1,bo1,ttreeitemdragobject(info.dragobjectpo^),result);
   end;
   if not result and bo1 and (info.dragobjectpo^ = nil) then begin
    ttreeitemdragobject.create(fowner,info.dragobjectpo^,info.pickpos,item1);
    result:= true;
   end;
  end;
 end;
end;

function ttreeitemdragcontroller.afterdragevent(var info: draginfoty): boolean;
begin
 result:= false;
end;
*)
{ ttreeitemdragobject }

constructor ttreeitemdragobject.create(const asender: tobject;
               var instance: tdragobject; const apickpos: pointty;
               const aitem: ttreelistitem);
begin
 fitem:= aitem;
// fsourcerow:= invalidaxis;
 fdestrow:= invalidaxis;
 inherited create(asender,instance,apickpos);
end;

end.
