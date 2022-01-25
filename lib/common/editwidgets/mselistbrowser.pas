{ MSEgui Copyright (c) 1999-2018 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mselistbrowser;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
{$ifndef mse_no_ifi}
 {$define mse_with_ifi}
{$endif}

interface
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}
uses
 mseglob,classes,mclasses,msegrids,msedatanodes,msedatalist,msedragglob,
 msegraphics,msegraphutils,msetypes,msestrings,msemenus,
{$ifdef mse_dynpo}
 msestockobjects_dynpo,
{$else}
 msestockobjects,
{$endif}
 msebitmap,mseclasses,mseguiglob,msedrawtext,msefileutils,msedataedits,
 mseeditglob,msewidgetgrid,msewidgets,mseedit,mseevent,msegui,msedropdownlist,
 msesys,msedrag,msestat,mseinplaceedit,msepointer,msegridsglob,
 mserichstring,msearrayprops,msevaluenodesglob
 {$ifdef mse_with_ifi}
 ,mseificomp,mseifiglob,mseificompglob,mseifigui
 {$endif}
 ;

const
 defaultcellwidth = 50;
 defaultcellheight = 50;
 defaultcellwidthmin = 10;
 defaultitemedittextflags = defaulttextflags + [tf_clipo];
 defaultitemedittextflagsactive = defaulttextflagsactive + [tf_clipo];

type
 listviewoptionty = ( //matched with coloptionty
          lvo_readonly,lvo_mousemoving,lvo_keymoving,lvo_horz,
          lvo_drawfocus,lvo_mousemovefocus,
          lvo_leftbuttonfocusonly,lvo_middlebuttonfocus,
          lvo_noctrlmousefocus,
          lvo_focusselect,lvo_mouseselect,lvo_keyselect,
          lvo_multiselect,lvo_resetselectonexit,{lvo_noresetselect,}
          lvo_fill,
          lvo_locate,lvo_casesensitive,lvo_savevalue,lvo_savestate,
          lvo_hintclippedtext
                     );
 listviewoptionsty = set of listviewoptionty;

 filelistviewoptionty = (flvo_maskcasesensitive,   //dso_casesensitive,
                         flvo_maskcaseinsensitive, //dso_caseinsensitive
                         flvo_nodirselect,flvo_nofileselect,flvo_checksubdir);
                                  //same layout as dirstreamoptionty
 filelistviewoptionsty = set of filelistviewoptionty;

const
 defaultlistviewoptionsgrid = defaultoptionsgrid + [og_wraprow,og_mousescrollcol];
 defaultlistviewoptions = [lvo_focusselect,lvo_mouseselect,lvo_drawfocus,
                           lvo_leftbuttonfocusonly,lvo_locate];
 defaultfilelistviewoptions = [flvo_nodirselect];
 coloptionsmask: listviewoptionsty =
                    [lvo_readonly,{lvo_mousemoving,lvo_keymoving,lvo_horz,}
                     lvo_drawfocus,lvo_mousemovefocus,lvo_leftbuttonfocusonly,
                     lvo_middlebuttonfocus,
                     lvo_noctrlmousefocus,
                     lvo_focusselect,lvo_mouseselect,lvo_keyselect,
                     lvo_multiselect,lvo_resetselectonexit{,lvo_noresetselect}];
// lvo_coloptions = lvo_drawfocus;

type
 tcustomlistview = class;

 tlistedititem = class(tlistitem)
 end;

 listedititemarty = array of tlistitem;
 listedititemclassty = class of tlistedititem;

 trichlistedititem = class(tlistedititem)
  private
   function getrichcaption: richstringty;
   procedure setrichcaption(const avalue: richstringty);
   procedure setcaptionformat(const avalue: formatinfoarty);
  protected
   fformat: formatinfoarty;
  public
   procedure updatecaption(const acanvas: tcanvas;
                     var alayoutinfo: listitemlayoutinfoty;
                                        var ainfo: drawtextinfoty); override;
   property richcaption: richstringty read getrichcaption write setrichcaption;
   property captionformat: formatinfoarty read fformat write setcaptionformat;
 end;

 tlisteditvalueitem = class(tlistitem)
  protected
 end;

 ttreeitemeditlist = class;
 ttreelistedititem = class;
 treelistedititemclassty = class of ttreelistedititem;
 treelistedititemarty = array of ttreelistedititem;
 treelistedititematy = array[0..0] of ttreelistedititem;
 ptreelistedititematy = ^treelistedititematy;

 ttreeitemedit = class;

 ttreelistedititem = class(ttreelistitem)
  private
   factiveindex: integer;
   function getactiveindex: integer;
  public
   constructor create(const aowner: tcustomitemlist = nil;
              const aparent: ttreelistitem = nil); override;
   procedure assign(source: ttreeitemeditlist); overload;
       //source remains owner of items, parent of items is unchanged
   function add(const aitem: ttreelistedititem): integer; overload;
                   //returns index, nil ignored
   procedure add(const aitems: treelistedititemarty); overload;
   function add(const itemclass: treelistedititemclassty = nil):
                                             ttreelistedititem; overload;
   procedure add(const acount: integer;
               const itemclass: treelistedititemclassty = nil); overload;
   procedure add(const captions: array of msestring;
               const itemclass: treelistedititemclassty = nil); overload;
   property activeindex: integer read getactiveindex;
   function endtreerow: integer;
                //returns index of last row of tree
   function editwidget: ttreeitemedit;
   procedure activate;
 end;
 ptreelistedititem = ^ttreelistedititem;

 tdirtreenode = class(ttreelistedititem)
  protected
   procedure checkfiles(var afiles: filenamearty); virtual;
  public
   procedure loaddirtree(const apath: filenamety); virtual;
   function path(const astart: integer = 0): filenamety;
 end;

 createlistitemeventty = procedure(const sender: tcustomitemlist;
                                           var item: tlistedititem) of object;
 createtreelistitemeventty = procedure(const sender: tcustomitemlist;
                                       var item: ttreelistedititem) of object;
 nodenotificationeventty = procedure(const sender: tlistitem;
           var action: nodeactionty) of object;
 listitemeventty = procedure(const sender: tobject;
                                       const aitem: tlistitem) of object;

 titemviewlist = class;

 paintlistitemeventty = procedure(const sender: titemviewlist;
                 const canvas: tcanvas; const item: tlistedititem) of object;

const
 defaultboxids: treeitemboxidarty = (
  //tib_none,  tib_empty,   tib_expand,        tib_expanded
        -1,ord(stg_box),ord(stg_boxexpand),ord(stg_boxexpanded),
  //tib_checkbox,         tib_checkboxchecked
    ord(stg_checkbox),ord(stg_checkboxchecked),
  //tib_checkboxparentnotchecked,tib_checkboxchildchecked
    ord(stg_checkboxparentnotchecked),ord(stg_checkboxchildchecked),
  //tib_checkboxchildnotchecked
    ord(stg_checkboxchildnotchecked)
    );
type
 titemviewlist = class(tcustomitemlist,iitemlist)
  private
   flistview: tcustomlistview;
   fonpaintitem: paintlistitemeventty;
   function getoncreateitem: createlistitemeventty;
   procedure setoncreateitem(const Value: createlistitemeventty);
  protected
   flayoutinfo: listitemlayoutinfoty;
   procedure doitemchange(const index: integer); override;
   procedure updatelayout; override;
   procedure invalidate; override;

    //iitemlist
   function getgrid: tcustomgrid;
   function getlayoutinfo(const acellinfo: pcellinfoty): plistitemlayoutinfoty;
   procedure itemcountchanged;
//   function getcolorglyph: colorty;
   procedure updateitemvalues(const index: integer; const acount: integer);
   function getcomponentstate: tcomponentstate;

  public
   constructor create(const alistview: tcustomlistview);
   property listview: tcustomlistview read flistview;
   property layoutinfo: listitemlayoutinfoty read flayoutinfo;
  published
   property oncreateitem: createlistitemeventty read getoncreateitem
                                          write setoncreateitem;
   property onpaintitem: paintlistitemeventty read fonpaintitem
                                                     write fonpaintitem;
   property options;
   property captionpos;
   property fonts;
   property imnr_base;
   property imagelist;
   property imagewidth;
   property imageheight;
   property imagealignment;
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
   procedure dostatread(const reader: tstatreader;
                                      const aorder: boolean); override;
   procedure dostatwrite(const writer: tstatwriter;
                                      const aorder: boolean); override;
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

 tlistitemsdragobject = class(tdragobject)
  private
   fitems: listitemarty;
  public
   constructor create(const asender: tobject; var instance: tdragobject;
                 const apickpos: pointty; const aitems: array of tlistitem);
   property items: listitemarty read fitems;
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
   fcolorglyphactive: colorty;
   fediting: boolean;
   fonitemsmoved: gridblockmovedeventty;
   fcellframe: tcellframe;
   foncopytoclipboard: updatestringeventty;
   fonpastefromclipboard: updatestringeventty;
   fcellcursor: cursorshapety;
   fglyphversionactive: int32;
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
   procedure setcolorglyphactive(const Value: colorty);
   procedure setediting(const Value: boolean);
   function getkeystring(const index: integer): msestring;
   function getfocusedindex: integer;
   procedure setfocusedindex(const avalue: integer);
   procedure setupeditor(const newcell: gridcoordty{; posonly: boolean});
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
   function getcellsize: sizety;
   procedure setcellsize(const avalue: sizety);
   procedure setglyphversionactive(const avalue: int32);
  protected
   fitemlist: titemviewlist;
   class function classskininfo: skininfoty; override;
   procedure setframeinstance(instance: tcustomframe); override;
   procedure limitcellwidth(var avalue: integer);

   procedure setoptions(const avalue: listviewoptionsty); virtual;
   procedure rootchanged(const aflags: rootchangeflagsty); override;
   procedure doitemchange(index: integer);
   procedure doitemevent(const index: integer;
                               var info: celleventinfoty); virtual;
   procedure docellevent(var info: celleventinfoty); override;
   function createdatacols: tdatacols; override;
   procedure createdatacol(const index: integer; out item: tdatacol); override;
   procedure updatelayout; override;
   procedure drawfocusedcell(const acanvas: tcanvas); override;
   procedure loaded; override;
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure scrolled(const dist: pointty); override;

   procedure dostatread(const reader: tstatreader); override;
   procedure dostatwrite(const writer: tstatwriter); override;

    //iedit
   function getoptionsedit: optionseditty;
   procedure editnotification(var info: editnotificationinfoty);
   function hasselection: boolean;
   procedure updatecopytoclipboard(var atext: msestring); virtual;
   procedure updatepastefromclipboard(var atext: msestring); virtual;
   function locatecount: integer; virtual;        //number of locate values
   function locatecurrentindex: integer; virtual; //index of current row
   procedure locatesetcurrentindex(const aindex: integer);
   function getedited: boolean;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure synctofontheight; override;
   function internaldragevent(var info: draginfoty): boolean; override;
                                //true if processed
   procedure moveitem(const source,dest: tlistitem; focus: boolean);
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
   function getselectedindexes: integerarty;

   property items[const index: integer]: tlistitem read getitems
                                                  write setitems; default;
   property editing: boolean read fediting write setediting;
   property editor: tinplaceedit read feditor;

   property colorselect: colorty read getcolorselect
                                    write setcolorselect default cl_default;
   property colorglyph: colorty read fcolorglyph
                                    write setcolorglyph default cl_glyph;
   property colorglyphactive: colorty read fcolorglyphactive
                            write setcolorglyphactive default cl_glyphactive;
   property glyphversionactive: int32 read fglyphversionactive write
                                           setglyphversionactive default 0;
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
   property cellsize: sizety read getcellsize write setcellsize;
   property cellframe: tcellframe read getcellframe write setcellframe;
   property cellcursor: cursorshapety read fcellcursor write setcellcursor
                                                           default cr_default;

   property itemlist: titemviewlist read fitemlist write setitemlist;
   property options: listviewoptionsty read foptions write setoptions
                            default defaultlistviewoptions;
   property cellfocusrectdist: integer read getcellfocusrectdist
                                        write setcellfocusrectdist default 0;
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
   property optionsgrid1;
   property options;
   property gridframecolor;
   property itemlist;
   property cellwidthmin;
   property cellwidthmax;
   property cellheightmin;
   property cellheightmax;
   property statvarname;
   property statpriority;
   property statfile;
   property onselectionchanged;
   property oncopyselection;
   property onpasteselection;
   property onbeforeupdatelayout;
   property onlayoutchanged;
   property onitemevent;
   property drag;
   property onitemsmoved;
   property oncopytoclipboard;
   property onpastefromclipboard;
 end;

 tcustomitemedit = class;

 tcustomitemeditlist = class(tcustomitemlist,iimagelistinfo)
  private
   fcolorglyph: colorty;
   fcolorglyphactive: colorty;
   fcolorline: colorty;
   fcolorlineactive: colorty;
   fowner: tcustomitemedit;
   fonitemnotification: nodenotificationeventty;
//   fboxglyph_list: timagelist;
//   fboxglyph_listactive: timagelist;
   fboxglyph_versionactive: int32;
   procedure setcolorglyph(const avalue: colorty);
   procedure setcolorglyphactive(const avalue: colorty);
   function getboxglyph_checkbox: stockglyphty;
   procedure setboxglyph_checkbox(const avalue: stockglyphty);
   function getboxglyph_checkboxchecked: stockglyphty;
   procedure setboxglyph_checkboxchecked(const avalue: stockglyphty);
   function getboxglyph_checkboxparentnotchecked: stockglyphty;
   procedure setboxglyph_checkboxparentnotchecked(const avalue: stockglyphty);
   function getboxglyph_checkboxchildchecked: stockglyphty;
   procedure setboxglyph_checkboxchildchecked(const avalue: stockglyphty);
   function getboxglyph_checkboxchildnotchecked: stockglyphty;
   procedure setboxglyph_checkboxchildnotchecked(const avalue: stockglyphty);
//   procedure setboxglyp_list(const avalue: timagelist);
//   procedure setboxglyp_listactive(const avalue: timagelist);
   procedure setboxglyph_versionactive(const avalue: int32);
  protected
   fboxids: treeitemboxidarty;
   procedure createstatitem(const reader: tstatreader;
                                     out item: tlistitem); override;
   procedure doitemchange(const index: integer); override;
   procedure nodenotification(const sender: tlistitem;
                                      var ainfo: nodeactioninfoty); override;
   function compare(const l,r): integer; override;
   class function defaultitemclass(): listedititemclassty; virtual;
   procedure itemclasschanged();
    //iimagelistinfo
   function getimagelist: timagelist;
  public
   constructor create; overload; override;
   constructor create(const intf: iitemlist;
                         const owner: tcustomitemedit); reintroduce; overload;
   procedure assign(const aitems: listitemarty); reintroduce; overload;
   procedure insert(const aindex: integer; const anode: tlistitem);
   procedure add(const anode: tlistitem);
   procedure refreshitemvalues(aindex: integer = 0; //-1 = current grid row
                               acount: integer = -1); //-1 = all
   property owner: tcustomitemedit read fowner;
   property colorglyph: colorty read fcolorglyph
                                    write setcolorglyph default cl_glyph;
                      //for monochrome imagelist
   property colorglyphactive: colorty read fcolorglyphactive
                             write setcolorglyphactive default cl_glyphactive;
                      //for monochrome imagelist
//   property boxglyph_list: timagelist read fboxglyph_list write setboxglyp_list;
//   property boxglyph_listactive: timagelist read fboxglyph_listactive
//                                                    write setboxglyp_listactive;
   property boxglyph_versionactive: int32 read fboxglyph_versionactive write
                                           setboxglyph_versionactive default 0;
   property boxglyph_checkbox: stockglyphty read getboxglyph_checkbox
                               write setboxglyph_checkbox default stg_checkbox;
   property boxglyph_checkboxchecked: stockglyphty
                         read getboxglyph_checkboxchecked
                 write setboxglyph_checkboxchecked default stg_checkboxchecked;
   property boxglyph_checkboxparentnotchecked: stockglyphty
             read getboxglyph_checkboxparentnotchecked
                   write setboxglyph_checkboxparentnotchecked
                                   default stg_checkboxparentnotchecked;
   property boxglyph_checkboxchildchecked: stockglyphty
                          read getboxglyph_checkboxchildchecked
        write setboxglyph_checkboxchildchecked default stg_checkboxchildchecked;
   property boxglyph_checkboxchildnotchecked: stockglyphty
                          read getboxglyph_checkboxchildnotchecked
                          write setboxglyph_checkboxchildnotchecked
                                          default stg_checkboxchildnotchecked;
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
   property colorglyph;
   property colorglyphactive;
   property boxglyph_versionactive;
//   property boxglyph_list;
//   property boxglyph_listactive;
   property boxglyph_checkbox;
   property boxglyph_checkboxchecked;
   property boxglyph_checkboxparentnotchecked;
   property boxglyph_checkboxchildchecked;
   property imnr_base;
   property imnr_expanded;
   property imnr_selected;
   property imnr_readonly;
   property imnr_checked;
   property imnr_subitems;
   property imnr_focused;
   property imnr_active;
   property imagelist;
   property imagewidth;
   property imageheight;
   property imagealignment;
   property defaultnodestate;
   property captionpos;
   property fonts;
   property options;
   property onitemnotification;
   property oncreateitem: createlistitemeventty read getoncreateitem
                                                    write setoncreateitem;
   property onstatreaditem;
   property onstatwrite;
   property onstatread;
 end;

 trecordfielditem = class(tlistedititem)
  protected
   fvalueitem: tlistitem;
   function getvalueitem: tlistitem; override;
   procedure setvalueitem(const avalue: tlistitem); override;
  public
  end;

 trecordfielditemeditlist = class(titemeditlist)
  protected
   class function defaultitemclass(): listedititemclassty; override;
 end;

 valueeditinfoty = record
  datatype: listdatatypety;
  valueindex: int32;
  editwidget: twidget;
  gridintf: igridwidget;
  visible: boolean;
 end;
 pvalueeditinfoty = ^valueeditinfoty;

 tvalueedititem = class(townedpersistent)
  private
   finfo: valueeditinfoty;
   procedure seteditwidget(const avalue: twidget);
   procedure setvalueindex(const avalue: int32);
  protected
   procedure changed();
  public
   destructor destroy(); override;
  published
   property valueindex: int32 read finfo.valueindex write
                                        setvalueindex default 0;
   property editwidget: twidget read finfo.editwidget write seteditwidget;
 end;

 tvalueedits = class(townedpersistentarrayprop)
  public
   constructor create(const aowner: tcustomitemedit); reintroduce;
   class function getitemclasstype: persistentclassty; override;
  published
 end;

 itemindexeventty = procedure(const sender: tobject; const aindex: integer;
                     const aitem: tlistitem) of object;
 itemcanediteventty = procedure(const sender: tobject;
                  const aitem: tlistitem; var canedit: boolean) of object;

 extendimageeventty = procedure(const sender: twidget;
                        const cellinfopo: pcellinfoty; //nil for non cell call
                                   var ainfo: extrainfoty) of object;
 tcustomitemedit = class(tdataedit,iitemlist,ibutton)
  private
   fitemlist: tcustomitemeditlist;
   fonsetvalue: setstringeventty;
   fonclientmouseevent: mouseeventty;
   fonbuttonaction: buttoneventty;
   fonupdaterowvalues: itemindexeventty;
   foncellevent: celleventty;
   factiverow: integer;
   fcalcsize: sizety;
   foncheckcanedit: itemcanediteventty;
   fonextendimage: extendimageeventty;

   fvalueedits: tvalueedits;
  {$ifdef mse_with_ifi}
   fitemifilink: boolean;
  {$endif}
   function getframe: tbuttonsframe;
   procedure setframe(const avalue: tbuttonsframe);
   function getitemlist: titemeditlist;
   procedure setitemlist(const Value: titemeditlist);
   function getitems(const index: integer): tlistitem;
   procedure setitems(const index: integer; const Value: tlistitem);
   function getediting: boolean;
   procedure setediting(const avalue: boolean);
  {$ifdef mse_with_ifi}
   function getifilink: tifistringlinkcomp;
   procedure setifilink(const avalue: tifistringlinkcomp);
   function getifilink1: tifilinkcomp;
   procedure setifilink1(const avalue: tifilinkcomp);
//   function getifiitemlink: tifiitemlinkcomp;
//   procedure setifiitemlink(const avalue: tifiitemlinkcomp);
  {$endif}
   procedure setvalueedits(const avalue: tvalueedits);
  protected
   factiveinfo: valueeditinfoty;
   fvisiblevalueeditcount: int32;
   flastzonewidget: twidget;
   flayoutinfofocused: listitemlayoutinfoty;
   flayoutinfocell: listitemlayoutinfoty;
   fentryedge: graphicdirectionty;
   fvalue: tlistitem;

   procedure valueeditchanged();
   procedure unregisterchildwidget(const child: twidget); override;
                        //track removing of field edits
   procedure loaded(); override;
   procedure dofocus; override;

   function valuecanedit: boolean;
   procedure doextendimage(const cellinfopo: pcellinfoty;
                                        var ainfo: extrainfoty); virtual;
   procedure getautopaintsize(var asize: sizety); override;
   procedure getautocellsize(const acanvas: tcanvas;
                                      var asize: sizety); override;
   procedure calclayout(const asize: sizety;
                                       out alayout: listitemlayoutinfoty);
   function finddataedits(aitem: tlistitem; out ainfos: recvaluearty): boolean;
   function updateeditwidget(): boolean; //true if editwidgetactivated
   procedure childdataentered(const sender: igridwidget); override;
   procedure childfocused(const sender: igridwidget); override;

  {$ifdef mse_with_ifi}
    //iifidatalink
   procedure updateifigriddata(const sender: tobject;
                                           const alist: tdatalist); override;
  {$endif}

    //iedit
   function locatecount: integer; override;        //number of locate values
   function getkeystring(const index: integer): msestring; override;

   procedure itemchanged(const index: integer); virtual;
   procedure createnode(var item: tlistitem); virtual;

   procedure doupdatelayout(const nocolinvalidate: boolean); virtual;
   procedure doupdatecelllayout; virtual;

    //iitemlist
   function getgrid: tcustomgrid;
   function getlayoutinfo(const acellinfo: pcellinfoty): plistitemlayoutinfoty;
   procedure itemcountchanged;
//   function getcolorglyph: colorty;

    //igridwidget
   procedure setfirstclick(var ainfo: mouseeventinfoty); override;
   function getcellcursor(const arow: integer; const acellzone: cellzonety;
                                 const apos: pointty): cursorshapety; override;
   procedure updatecellzone(const row: integer; const apos: pointty;
                            var result: cellzonety); override;
   procedure setgridintf(const intf: iwidgetgrid); override;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   procedure datalistdestroyed; override;
   function getdatalistclass: datalistclassty; override;
   procedure drawcell(const canvas: tcanvas); override;
   procedure valuetogrid(arow: integer); override;
   procedure gridtovalue(arow: integer); override;
   function internaldatatotext(const data): msestring; override;
   procedure dosetvalue(var avalue: msestring; var accept: boolean); virtual;
   procedure storevalue(var avalue: msestring); virtual;
   procedure texttovalue(var accept: boolean; const quiet: boolean); override;
   procedure clientrectchanged; override;
   procedure updatelayout();
   procedure doitembuttonpress(var info: mouseeventinfoty); virtual;
   procedure clientmouseevent(var info: mouseeventinfoty); override;
   function getitemclass: listitemclassty; virtual;
   procedure setupeditor; override;
   procedure dopaintforeground(const acanvas: tcanvas); override;
   procedure dokeydown(var info: keyeventinfoty); override;

   procedure getitemvalues; virtual;
   procedure internalcreateframe; override;

    //ibuttonaction
   procedure buttonaction(var action: buttonactionty;
         const buttonindex: integer); virtual;

   procedure mouseevent(var info: mouseeventinfoty); override;
   procedure docellevent(const ownedcol: boolean;
                                         var info: celleventinfoty); override;

   function getoptionsedit: optionseditty; override;
   property editing: boolean read getediting write setediting;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure insertwidget(const awidget: twidget;
                                            const apos: pointty); override;
   function textclipped(const arow: integer;
                       out acellrect: rectty): boolean; overload; override;
   function getvaluetext: msestring;
   procedure setvaluetext(var avalue: msestring);
   function isnull: boolean; override;
   function item: tlistedititem;
   property items[const index: integer]: tlistitem read getitems
                                                    write setitems; default;
   function selecteditems: listedititemarty;

   procedure beginedit;
   procedure endedit;
   procedure updateitemvalues(const index: integer;
                                       const count: integer); virtual;
   procedure updateitemvalues;
              //calls updateitemvalues for current grid row
   property activerow: integer read factiverow;
  published
   property itemlist: titemeditlist read getitemlist
                                       write setitemlist stored false;
{$ifdef mse_with_ifi}
   property ifilink: tifistringlinkcomp read getifilink write setifilink;
//   property ifiitemlink: tifiitemlinkcomp read getifiitemlink
//                                                      write setifiitemlink;
{$endif}
   property onsetvalue: setstringeventty read fonsetvalue write fonsetvalue;
   property onclientmouseevent: mouseeventty read fonclientmouseevent
                           write fonclientmouseevent;
   property optionsedit1; //before optionsedit!
   property optionsedit;
   property font;
   property passwordchar;
   property maxlength;
   property textflags default defaultitemedittextflags;
   property textflagsactive default defaultitemedittextflagsactive;
   property frame: tbuttonsframe read getframe write setframe;
   property valueedits: tvalueedits read fvalueedits write setvalueedits;
   property onchange;
//   property onbeforepaint;
//   property onpaintbackground;
//   property onpaint;
   property onpaintimage;
   property onextendimage: extendimageeventty read fonextendimage
                                                     write fonextendimage;
//   property onafterpaint;
   property onbuttonaction: buttoneventty read fonbuttonaction
                                                   write fonbuttonaction;
   property onupdaterowvalues: itemindexeventty read fonupdaterowvalues
                                       write fonupdaterowvalues;
   property oncellevent: celleventty read foncellevent write foncellevent;
   property oncheckcanedit: itemcanediteventty read foncheckcanedit
                                                         write foncheckcanedit;
 end;

 titemedit = class;

 titemclientcontroller = class(tvalueclientcontroller)
  private
   fitemedit: tcustomitemedit;
   function getitemlist(): titemeditlist;
   function getitemedit: titemedit;
  protected
   function createdatalist: tdatalist override;
   function getlistdatatypes: listdatatypesty override;
   function getlistitem(): tlistedititem;
   procedure linkset(const alink: iificlient); override;
  public
   property item: tlistedititem read getlistitem;
   property itemlist: titemeditlist read getitemlist;
   property itemedit: titemedit read getitemedit;
 end;

 tifiitemlinkcomp = class(tifivaluelinkcomp)
  private
   function getcontroller: titemclientcontroller;
   procedure setcontroller(const avalue: titemclientcontroller);
  protected
   function getcontrollerclass: customificlientcontrollerclassty; override;
  public
   property c: titemclientcontroller read getcontroller
                                                         write setcontroller;
  published
   property controller: titemclientcontroller read getcontroller
                                                         write setcontroller;
 end;

 titemedit = class(tcustomitemedit)
  private
  {$ifdef mse_with_ifi}
   function getifiitemlink: tifiitemlinkcomp;
   procedure setifiitemlink(const avalue: tifiitemlinkcomp);
  {$endif}
  published
{$ifdef mse_with_ifi}
   property ifiitemlink: tifiitemlinkcomp read getifiitemlink
                                                      write setifiitemlink;
{$endif}
 end;

 tdropdownitemedit = class(titemedit,idropdownlist)
  private
   fdropdown: tcustomdropdownlistcontroller;
   fonbeforedropdown: notifyeventty;
   fonafterclosedropdown: notifyeventty;
   procedure setdropdown(const Value: tcustomdropdownlistcontroller);
  protected
   procedure doupdatecelllayout; override;
   function getframe: tdropdownmultibuttonframe;
   procedure setframe(const avalue: tdropdownmultibuttonframe);
   function getdropdowncontrollerclass: dropdownlistcontrollerclassty; virtual;
    //idropdown
   procedure dobeforedropdown; virtual;
   procedure doafterclosedropdown; virtual;
   function getdropdownitems: tdropdowndatacols;
   function getvalueempty: integer; virtual;
   procedure imagelistchanged; virtual;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property frame: tdropdownmultibuttonframe read getframe write setframe;
   property dropdown: tcustomdropdownlistcontroller read fdropdown
                                                    write setdropdown;
   property onbeforedropdown: notifyeventty read fonbeforedropdown
                                                    write fonbeforedropdown;
   property onafterclosedropdown: notifyeventty read fonafterclosedropdown
                  write fonafterclosedropdown;
 end;

 tmbdropdownitemedit = class(tdropdownitemedit)
                //redundant, all dropdowns are multibutton
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
   function converttotreelistitem(flat: boolean = false;
                withrootnode: boolean =  false;
                filterfunc: treenodefilterfuncty = nil): ttreelistedititem;
 end;

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
            var dragobject: ttreeitemdragobject;
                                          var processed: boolean) of object;

 expandedinfoty = record
  path: msestringarty;
 end;
 expandedinfoarty = array of expandedinfoty;

 ttreeitemeditlist = class(tcustomitemeditlist)
  private
   fchangingnode: ttreelistitem;
   finsertcount: integer;
   finsertindex: integer;
   fondragbegin: treeitemdragbegineventty;
   fondragover: treeitemdragovereventty;
   fondragdrop: treeitemdragdropeventty;
   frootnode: ttreelistedititem;
   finsertparent: ttreelistedititem;
   finsertparentindex: integer;
//   foptionsdraw: itemdrawoptionsty;
   procedure setoncreateitem(const value: createtreelistitemeventty);
   function getoncreateitem: createtreelistitemeventty;
   procedure setcolorline(const value: colorty);
   procedure setcolorlineactive(const value: colorty);
   function getonstatreaditem: statreadtreeitemeventty;
   procedure setonstatreaditem(const avalue: statreadtreeitemeventty);
   function getitems1(const index: integer): ttreelistedititem;
   procedure setitems(const index: integer; const avalue: ttreelistedititem);
   function getitemclass: treelistedititemclassty;
   procedure setitemclass(const avalue: treelistedititemclassty);
   function getexpandedstate: expandedinfoarty;
   procedure setexpandedstate(const avalue: expandedinfoarty);
   function getonstatwriteitem: statwritetreeitemeventty;
   procedure setonstatwriteitem(const avalue: statwritetreeitemeventty);
   procedure setrootnode(const avalue: ttreelistedititem);
   function getboxglyph_empty: stockglyphty;
   procedure setboxglyph_empty(const avalue: stockglyphty);
   function getboxglyph_expand: stockglyphty;
   procedure setboxglyph_expand(const avalue: stockglyphty);
   function getboxglyph_expanded: stockglyphty;
   procedure setboxglyph_expanded(const avalue: stockglyphty);
//   procedure setoptionsdraw(const avalue: itemdrawoptionsty);
{
   function getboxglyphactive_empty: stockglyphty;
   procedure setboxglyphactive_empty(const avalue: stockglyphty);
   function getboxglyphactive_expand: stockglyphty;
   procedure setboxglyphactive_expand(const avalue: stockglyphty);
   function getboxglyphactive_expanded: stockglyphty;
   procedure setboxglyphactive_expanded(const avalue: stockglyphty);
}
  protected
//   fboxidsactive: treeitemboxidarty;
   procedure freedata(var data); override;
   procedure docreateobject(var instance: tobject); override;
   procedure createitem(out item: tlistitem); override;
   procedure nodenotification(const sender: tlistitem;
                  var ainfo: nodeactioninfoty); override;
   function compare(const l,r): integer; override;
   procedure statreaditem(const reader: tstatreader;
                    var aitem: tlistitem); override;
   procedure statwriteitem(const writer: tstatwriter;
                    const aitem: tlistitem); override;
   procedure readstate(const reader; const acount: integer;
                                        const aname: msestring); override;
   procedure writestate(const writer; const name: msestring); override;
   procedure beforedragevent(var ainfo: draginfoty; const arow: integer;
                               var processed: boolean);
   procedure afterdragevent(var ainfo: draginfoty; const arow: integer;
                               var processed: boolean);
  public
   constructor create; overload; override;
   constructor create(const intf: iitemlist; const aowner: ttreeitemedit);
                                     reintroduce; overload;
   procedure beginupdate; override;
   procedure endupdate; override;
   procedure change(const index: integer); override;
   procedure deleteitems(index,acount: integer); override;
   procedure insertitems(index,acount: integer); override;

   procedure assign(const root: ttreelistedititem;
                      const freeroot: boolean = true); reintroduce; overload;
   procedure assign(const aitems: treelistedititemarty); reintroduce; overload;
   procedure add(const anode: ttreelistedititem;
                                 const freeroot: boolean = true); overload;

                 //adds toplevel node
   procedure add(const anodes: treelistedititemarty); overload;
   procedure add(const acount: integer;
                          aitemclass: treelistedititemclassty = nil); overload;
   procedure addchildren(const anode: ttreelistedititem);
                 //adds children as toplevel nodes
   procedure insert(const aindex: integer;const anode: ttreelistedititem;
                                             const freeroot: boolean = true);
                //inserts in parent of items[aindex]
   procedure delete(const aindex: integer);
   procedure readnode(const aname: msestring; const reader: tstatreader;
                                            const anode: ttreelistitem);
   procedure writenode(const aname: msestring; const writer: tstatwriter;
                                            const anode: ttreelistitem);
   procedure updatenode(const aname: msestring; const filer: tstatfiler;
                                            const anode: ttreelistitem);

   function toplevelnodes: treelistedititemarty;
   function getnodes(const must: nodestatesty; const mustnot: nodestatesty;
                 const amode: getnodemodety = gno_matching): treelistitemarty;
   function getselectednodes(const amode: getnodemodety =
                                              gno_matching): treelistitemarty;
   function getcheckednodes(const amode: getnodemodety =
                                              gno_matching): treelistitemarty;
   procedure updatechildcheckedtree; //slow!
   procedure updatechildnotcheckedtree; //slow!
   procedure updateparentnotcheckedtree; //slow!

   procedure expandall;
   procedure collapseall;
   procedure moverow(const source,dest: integer);
    //source and dest must belong to the same parent, ignored otherwise
   property itemclass: treelistedititemclassty read getitemclass
                                                          write setitemclass;
   property items[const index: integer]: ttreelistedititem read getitems1
                                          write setitems; default;
   property expandedstate: expandedinfoarty read getexpandedstate
                                                write setexpandedstate;

   property rootnode: ttreelistedititem read frootnode write setrootnode;
                           //clears list and adds children
   property insertparent: ttreelistedititem read finsertparent;
                                  //valid in oncreateitem
   property insertparentindex: integer read finsertparentindex;
                                  //valid in oncreateitem
  published
   property colorglyph;
   property colorglyphactive;
   property boxglyph_versionactive;
//   property boxglyph_list;
//   property boxglyph_listactive;
   property boxglyph_checkbox;
   property boxglyph_checkboxchecked;
   property boxglyph_checkboxparentnotchecked;
   property boxglyph_checkboxchildchecked;
   property imnr_base;
   property imnr_expanded;
   property imnr_selected;
   property imnr_readonly;
   property imnr_checked;
   property imnr_subitems;
   property imnr_focused;
   property imnr_active;
   property imagelist;
   property imagewidth;
   property imageheight;
   property imagealignment;
   property defaultnodestate;
   property captionpos;
   property fonts;
   property options;
   property onitemnotification;
//   property optionsdraw: itemdrawoptionsty read foptionsdraw
//                                           write setoptionsdraw default [];
   property colorline: colorty read fcolorline write setcolorline
                                                        default cl_treeline;
   property colorlineactive: colorty read fcolorlineactive
                          write setcolorlineactive default cl_treelineactive;
   property boxglyph_empty: stockglyphty read getboxglyph_empty
                               write setboxglyph_empty default stg_box;
   property boxglyph_expand: stockglyphty read getboxglyph_expand
                               write setboxglyph_expand default stg_boxexpand;
   property boxglyph_expanded: stockglyphty read getboxglyph_expanded
                             write setboxglyph_expanded default stg_boxexpanded;
{
   property boxglyphactive_empty: stockglyphty read getboxglyphactive_empty
                               write setboxglyphactive_empty default stg_box;
   property boxglyphactive_expand: stockglyphty read getboxglyphactive_expand
                           write setboxglyphactive_expand default stg_boxexpand;
   property boxglyphactive_expanded: stockglyphty
                            read getboxglyphactive_expanded
                    write setboxglyphactive_expanded default stg_boxexpanded;
}
   property oncreateitem: createtreelistitemeventty read getoncreateitem
                      write setoncreateitem;
   property onstatwriteitem: statwritetreeitemeventty read getonstatwriteitem
                      write setonstatwriteitem;
   property onstatreaditem: statreadtreeitemeventty read getonstatreaditem
                      write setonstatreaditem;
   property onstatwrite;
   property onstatread;
   property ondragbegin: treeitemdragbegineventty read fondragbegin
                                          write fondragbegin;
   property ondragover: treeitemdragovereventty read fondragover
                                          write fondragover;
   property ondragdrop: treeitemdragdropeventty read fondragdrop
                                          write fondragdrop;
   property levelstep;
 end;

 treeitemeditoptionty = (teo_treecolnavig,teo_treerownavig,teo_keyrowmoving,
                         teo_enteronimageclick,teo_enterondoubleclick);
 treeitemeditoptionsty = set of treeitemeditoptionty;

 checkmoveeventty = procedure(const curindex,newindex: integer;
                                            var accept: boolean) of object;

 trecordfieldedit = class(tmbdropdownitemedit)
  private
   fitemedit: ttreeitemedit;
  protected
   procedure storevalue(var avalue: msestring); override;
//   procedure dosetvalue(var avalue: msestring; var accept: boolean); override;
   function getoptionsedit: optionseditty; override;
  public
   constructor create(aowner: tcomponent); override;
 end;

 ttreeitemclientcontroller = class(titemclientcontroller)
  private
  protected
   function getlistitem(): ttreelistedititem;
   function getitemlist(): ttreeitemeditlist;
   function getitemedit(): ttreeitemedit;
  public
   property item: ttreelistedititem read getlistitem;
   property itemlist: ttreeitemeditlist read getitemlist;
   property itemedit: ttreeitemedit read getitemedit;
 end;

 tifitreeitemlinkcomp = class(tifivaluelinkcomp)
  private
   function getcontroller: ttreeitemclientcontroller;
   procedure setcontroller(const avalue: ttreeitemclientcontroller);
  protected
   function getcontrollerclass: customificlientcontrollerclassty; override;
  public
   property c: ttreeitemclientcontroller read getcontroller
                                                         write setcontroller;
  published
   property controller: ttreeitemclientcontroller read getcontroller
                                                         write setcontroller;
 end;

 ttreeitemedit = class(tcustomitemedit,idragcontroller)
  private
   foptions: treeitemeditoptionsty;
   foncheckrowmove: checkmoveeventty;
   ffieldedit: trecordfieldedit;
   function getitemlist: ttreeitemeditlist;
   procedure setitemlist(const Value: ttreeitemeditlist);
   function getitems(const index: integer): ttreelistedititem;
   procedure setitems(const index: integer; const Value: ttreelistedititem);
   procedure expandedchanged(const avalue: boolean);
   procedure setfieldedit(const avalue: trecordfieldedit);
  private
  {$ifdef mse_with_ifi}
   function getifiitemlink: tifitreeitemlinkcomp;
   procedure setifiitemlink(const avalue: tifitreeitemlinkcomp);
  {$endif}
  protected
   procedure doitembuttonpress(var info: mouseeventinfoty); override;
   function locatecount: integer; override;        //number of locate values
   function locatecurrentindex: integer; override; //index of current row
   procedure locatesetcurrentindex(const aindex: integer); override;
   function getkeystring(const aindex: integer): msestring; override;
                                                   //locate text
   procedure doupdatelayout(const nocolinvalidate: boolean); override;
//   function getitemclass: listitemclassty; override;
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure docellevent(const ownedcol: boolean;
                                       var info: celleventinfoty); override;
   function checkrowmove(const curindex,newindex: integer): boolean;
   procedure beforecelldragevent(var ainfo: draginfoty; const arow: integer;
                               var processed: boolean); override;
   procedure aftercelldragevent(var ainfo: draginfoty; const arow: integer;
                               var processed: boolean); override;
   function getdatalistclass: datalistclassty; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function item: ttreelistedititem;
   property items[const index: integer]: ttreelistedititem read getitems
                                                 write setitems; default;
   function selecteditems: treelistedititemarty;

   function candragsource(const apos: pointty): boolean;
   procedure dragdrop(const adragobject: ttreeitemdragobject);
   procedure comparerow(const lindex,rindex: integer; var aresult: integer);
   procedure updateitemvalues(const index: integer;
                                    const count: integer); override;
   procedure updateitemvalues();
   procedure updateparentvalues(const index: integer);
  published
   property itemlist: ttreeitemeditlist read getitemlist
                                        write setitemlist stored false;
   property fieldedit: trecordfieldedit read ffieldedit write setfieldedit;
   property options: treeitemeditoptionsty read foptions
                                                    write foptions default [];
{$ifdef mse_with_ifi}
   property ifiitemlink: tifitreeitemlinkcomp read getifiitemlink
                                                      write setifiitemlink;
{$endif}
   property oncheckrowmove: checkmoveeventty read foncheckrowmove
                                                        write foncheckrowmove;
 end;

implementation
uses
 sysutils,msebits,msekeyboard,msearrayutils,msevaluenodes;
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}

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
 twidget1 = class(twidget);

{ titemviewlist }

constructor titemviewlist.create(const alistview: tcustomlistview);
begin
 flistview:= alistview;
 with flayoutinfo do begin
  widget:= alistview;
  boxids:= defaultboxids;
 end;
 inherited create(iitemlist(self));
end;

function titemviewlist.getlayoutinfo(
                          const acellinfo: pcellinfoty): plistitemlayoutinfoty;
begin
 if acellinfo <> nil then begin
  flayoutinfo.variable.glyphversion:= 0;
  if cds_usecoloractive in acellinfo^.drawstate then begin
   flayoutinfo.variable.colorglyph:= flistview.colorglyph;
   if flistview.glyphversionactive < stockobjects.glyphs.versioncount then begin
    flayoutinfo.variable.glyphversion:= flistview.glyphversionactive;
   end;
  end
  else begin
   flayoutinfo.variable.colorglyph:= flistview.colorglyphactive;
  end;
 end;
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
{$warnings off}
   tlistitem.calcitemlayout(subsize(makesize(cellwidth,cellheight),
                                       fcellframe.paintframedim),
                           tframe1(fcellframe).fi.innerframe,self,flayoutinfo);
{$warnings on}
  end;
  layoutchanged;
 end;
// invalidate;
end;
{
function titemviewlist.getcolorglyph: colorty;
begin
 result:= flistview.fcolorglyph;
end;
}
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

function titemviewlist.getgrid: tcustomgrid;
begin
 result:= flistview;
end;

{ tlistcol }

constructor tlistcol.create(const agrid: tcustomgrid;
                                     const aowner: tgridarrayprop);
begin
 inherited;
 fwidth:= tcustomlistview(fcellinfo.grid).cellwidth;
 foptions:= (foptions - [co_savestate]) + [co_mousescrollrow];
end;

procedure tlistcol.setwidth(const Value: integer);
var
 int1: integer;
begin
 int1:= value;
 tcustomlistview(fcellinfo.grid).limitcellwidth(int1);
 inherited setwidth(int1);
 tcustomlistview(fcellinfo.grid).cellwidth:= fwidth;
end;

procedure tlistcol.setoptions(const Value: coloptionsty);
begin
 inherited setoptions(value - [co_savevalue]);
end;

procedure tlistcol.drawcell(const acanvas: tcanvas);
var
 item1: tlistitem;
begin
 inherited;
 with cellinfoty(acanvas.drawinfopo^) do begin
  item1:= items[cell.row];
  if item1 <> nil then begin
   item1.drawcell(acanvas);
   with tcustomlistview(grid),fitemlist do begin
    if assigned(fonpaintitem) then begin
     fonpaintitem(fitemlist,acanvas,tlistedititem(pointer(item1)));
    end;
   end;
  end;
 end;
end;

function tlistcol.getitems(const aindex: integer): tlistitem;
var
 int1: integer;
begin
 int1:= tcustomlistview(fcellinfo.grid).celltoindex(
                              makegridcoord(colindex,aindex),false);
 if int1 >= 0 then begin
  result:= tcustomlistview(fcellinfo.grid).fitemlist[int1];
 end
 else begin
  result:= nil;
 end;
end;

procedure tlistcol.setitems(const aindex: integer; const Value: tlistitem);
var
 int1: integer;
begin
 int1:= tcustomlistview(fcellinfo.grid).celltoindex(
                               makegridcoord(colindex,aindex),false);
 if int1 >= 0 then begin
  tcustomlistview(fcellinfo.grid).fitemlist[int1]:= value;
 end;
end;

procedure tlistcol.updatecellzone(const row: integer; const pos: pointty;
                                  var result: cellzonety);
begin
 if pointinrect(pos,tcustomlistview(
                fcellinfo.grid).fitemlist.flayoutinfo.captionrect) then begin
  result:= cz_caption;
 end
 else begin
  if pointinrect(pos,
     tcustomlistview(fcellinfo.grid).fitemlist.flayoutinfo.imagerect) then begin
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
 int1:= tcustomlistview(fcellinfo.grid).celltoindex(makegridcoord(colindex,row),
                                                                         false);
 if int1 >= 0 then begin
  result:= tcustomlistview(fcellinfo.grid).fitemlist[int1].selected;
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
   include(tcustomgrid1(fcellinfo.grid).fstate,gs_selectionchanged);
   item.selected:= value;
  end;
 end;

var
 int1: integer;
begin
 if row < 0 then begin
  for int1:= 0 to fcellinfo.grid.rowcount-1 do begin
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
 with tcustomlistview(fcellinfo.grid) do begin
  if (lvo_hintclippedtext in foptions) and
         (info.eventkind = cek_firstmousepark) and application.active and
          getshowhint and (info.cell.row >= 0) then begin
   item1:= self[info.cell.row];
   if item1 <> nil then begin
    with item1 do begin
     if captionclipped then begin
      application.inithintinfo(hintinfo,fcellinfo.grid);
      hintinfo.caption:= caption;
      application.showhint(fcellinfo.grid,hintinfo);
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

procedure tlistcols.dostatread(const reader: tstatreader;
                                      const aorder: boolean);
begin
 inherited;
 with tcustomlistview(fgrid) do begin
  if (lvo_savevalue in foptions) and reader.candata then begin
   reader.readdatalist('values',fitemlist);
  end;
 end;
end;

procedure tlistcols.dostatwrite(const writer: tstatwriter;
                                      const aorder: boolean);
begin
 inherited;
 with tcustomlistview(fgrid) do begin
  if (lvo_savevalue in foptions) and writer.candata then begin
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

{ tlistitemsdragobject }

constructor tlistitemsdragobject.create(const asender: tobject;
               var instance: tdragobject; const apickpos: pointty;
               const aitems: array of tlistitem);
var
 i1: int32;
begin
 setlength(fitems,length(aitems));
 for i1:= 0 to high(fitems) do begin
  fitems[i1]:= aitems[i1];
 end;
 inherited create(asender,instance,apickpos);
end;

{ tcustomlistview }

constructor tcustomlistview.create(aowner: tcomponent);
begin
 foptions:= defaultlistviewoptions;
 fcolorglyph:= cl_glyph;
 fcolorglyphactive:= cl_glyphactive;
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
var
 opt1: coloptionsty;
begin
// item.options:= coloptionsty(
//      replacebits(
//      {$ifdef FPC}longword{$else}word{$endif}(foptionslist) shl listviewoptionshift,
//      {$ifdef FPC}longword{$else}longword{$endif}(item.options),
//      {$ifdef FPC}longword{$else}longword{$endif}(bitmask[integer(lvo_coloptions)+1])
//               shl listviewoptionshift));
 opt1:= coloptionsty(
      replacebits(
      {$ifdef FPC}longword{$else}longword{$endif}(foptions),
      {$ifdef FPC}longword{$else}longword{$endif}(item.options),
      {$ifdef FPC}longword{$else}longword{$endif}(coloptionsmask)));
// updatebit(longword(opt1),ord(co_savestate),lvo_savestate in foptions);
 item.options:= opt1;
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

procedure tcustomlistview.limitcellwidth(var avalue: integer);
begin
 if (avalue <> 0) and (fcellwidthmin > avalue) then begin
  avalue:= fcellwidthmin;
 end;
 if (fcellwidthmax <> 0) and (fcellwidthmax < avalue) then begin
  avalue:= fcellwidthmax;
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
// fitemlist.updatelayout;
 width1:= fcellwidth;
 height1:= datarowheight;
 if lvo_fill in foptions then begin
  inherited;
  if lvo_horz in foptions then begin
   width1:= fdatarect.cx - datacollinewidth;
  end
  else begin
   height1:= fdatarect.cy - datarowlinewidth;
  end;
 end;
 limitcellwidth(width1);
 datarowheight:= height1;
 for int1:= 0 to fdatacols.count-1 do begin
  fdatacols[int1].width:= width1;
  fdatacols[int1].cursor:= fcellcursor;
 end;
 fitemlist.updatelayout;
 repeat
  inherited;
  bo1:= false;
  if lvo_horz in foptions then begin
   int1:=  tlistcol.defaultstep(width1);
   if int1 = 0 then begin
    int1:= 1;
   end;
   int2:= fdatarect.cx div int1;
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
   int2:= fdatarect.cy div int1;
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
  setupeditor(ffocusedcell{,true});
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

procedure tcustomlistview.drawfocusedcell(const acanvas: tcanvas);
var
 pt1: pointty;
 item1: tlistitem1;
begin
 if cellinfoty(acanvas.drawinfopo^).calcautocellsize then begin
  if focuseditem <> nil then begin
   focuseditem.drawcell(acanvas);
  end;
 end
 else begin
  acanvas.save;
  drawcellbackground(acanvas);
  item1:= tlistitem1(focuseditem);
  if item1 <> nil then begin
   fitemlist.flayoutinfo.variable.calcautocellsize:= false;
   item1.drawimage(acanvas,fitemlist.flayoutinfo);
   if assigned(fitemlist.fonpaintitem) then begin
    fitemlist.fonpaintitem(fitemlist,acanvas,tlistedititem(pointer(item1)));
   end;
   pt1:= cellrect(ffocusedcell,cil_paint).pos;
   acanvas.remove(pt1);
   feditor.dopaint(acanvas);
   acanvas.move(pt1);
   if feditor.lasttextclipped then begin
    include(item1.fstate1,ns1_captionclipped);
   end
   else begin
    exclude(item1.fstate1,ns1_captionclipped);
   end;
  end;
  acanvas.restore;
  drawcelloverlay(acanvas);
 end;
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

function tcustomlistview.getedited: boolean;
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

procedure tcustomlistview.setupeditor(const newcell: gridcoordty{;
                                                    posonly: boolean});
var
 pt1: pointty;
// rect1,rect2: rectty;
 int1: integer;
begin
// rect1:= moverect(fitemlist.flayoutinfo.captionrect,po1);
// rect2:= moverect(fitemlist.flayoutinfo.captioninnerrect,po1);
 int1:= celltoindex(newcell,false);
 if int1 >= 0 then begin
//  if posonly then begin
//   feditor.updatepos(rect2,rect1);
//  end
//  else begin
//   feditor.setup(fitemlist[int1].caption,0,false,rect2,rect1,nil,nil,getfont);

  pt1:= cellrect(newcell,cil_paint).pos;
  with fitemlist[int1] do begin
//   if not posonly then begin
    feditor.textflags:= fitemlist.flayoutinfo.textflags + [tf_clipo];
    feditor.textflagsactive:= feditor.textflags;
    feditor.text:= caption;
//   end;
   setupeditor(feditor,getfont,true);
   feditor.movepos(pt1);
  end;

//  end;
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
     setupeditor(newcell{,false});
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
    else; // Case statment added to make compiler happy...
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

procedure tcustomlistview.rootchanged(const aflags: rootchangeflagsty);
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
 if index < 0 then begin
  layoutchanged;
  updatelayout;
  beginupdate;
  try
   for int1:= fitemlist.count to rowcount * datacols.count - 1 do begin
    fdatacols.selected[indextocell(int1)]:= false; //empty cells
   end;
   if focusedcellvalid() then begin
    int1:= celltoindex(ffocusedcell,false);
    if int1 >= 0 then begin
     if (lvo_focusselect in foptions) then begin
      itemlist[int1].selected:= true;
     end;
     itemstatetocellstate(int1,ffocusedcell);
    end;
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
  fcolorglyph:= Value;
  invalidate;
 end;
end;

procedure tcustomlistview.setcolorglyphactive(const Value: colorty);
begin
 if fcolorglyphactive <> value then begin
  fcolorglyphactive:= Value;
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

procedure tcustomlistview.dostatread(const reader: tstatreader);
begin
 if lvo_savestate in foptions then begin
  cellwidth:= reader.readinteger('cellwidth',cellwidth);
 end;
 inherited;
end;

procedure tcustomlistview.dostatwrite(const writer: tstatwriter);
begin
 if (lvo_savestate in foptions) and writer.canstate then begin
  writer.writeinteger('cellwidth',cellwidth);
 end;
 inherited;
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
 //dummy
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
  int1:= font.glyphheight + cellframe.innerframedim.cy;
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

function tcustomlistview.internaldragevent(var info: draginfoty): boolean;
var
 item: tlistitem;
begin
 if lvo_mousemoving in foptions then begin
  result:= true;
  with info do begin
   item:= itematpos(pos);
   if item <> nil then begin
    case eventkind of
     dek_begin: begin
      tlistitemdragobject.create(self,dragobjectpo^,fdragcontroller.pickpos,item);
     end;
     dek_check: begin
      accept:= (item <> focuseditem) and (info.dragobjectpo <> nil) and
        isobjectdrag(info.dragobjectpo^,tlistitem) and
        (tlistitem(tobjectdragobject(info.dragobjectpo^).data).owner =
                                                                  fitemlist);
     end;
     dek_drop: begin
      moveitem(tlistitemdragobject(dragobjectpo^).item,item,true);
     end;
     else; // Case statment added to make compiler happy...
    end;
   end;
  end;
 end
 else begin
  result:= inherited internaldragevent(info);
 end;
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
// str1: msestring;
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
     else; // Case statment added to make compiler happy...
    end;
    if item <> nil then begin
     moveitem(focuseditem,item,true);
     include(eventstate,es_processed);
    end;
   end;
   if not (es_processed in info.eventstate) then begin
    if (shiftstate = []) and isenterkey(nil,key) then begin
     if not editing then begin
      editing:= (focuseditem <> nil) and tlistitem1(focuseditem).cancaptionedit();
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

function tcustomlistview.getcellsize: sizety;
begin
 result:= ms(cellwidth,cellheight);
end;

procedure tcustomlistview.setcellsize(const avalue: sizety);
begin
 cellwidth:= avalue.cx;
 cellheight:= avalue.cy;
end;

procedure tcustomlistview.setglyphversionactive(const avalue: int32);
begin
 if fglyphversionactive <> avalue then begin
  fglyphversionactive:= avalue;
  if fglyphversionactive < 0 then begin
   fglyphversionactive:= 0;
  end;
 end;
end;

class function tcustomlistview.classskininfo: skininfoty;
begin
 result:= inherited classskininfo;
 result.objectkind:= sok_dataedit;
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

function tcustomlistview.getselectedindexes: integerarty;
begin
 if datacols.hasselection then begin
  result:= fitemlist.getselectedindexes();
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

constructor tcustomitemeditlist.create;
begin
 fcolorglyph:= cl_glyph;
 fcolorglyphactive:= cl_glyphactive;
 fboxids:= defaultboxids;
 inherited;
 fitemclass:= defaultitemclass();
 fstate:= fstate + [dls_nogridstreaming,dls_propertystreaming];
end;

constructor tcustomitemeditlist.create(const intf: iitemlist;
                                                  const owner: tcustomitemedit);
begin
 fowner:= owner;
 inherited create(intf);
end;

class function tcustomitemeditlist.defaultitemclass(): listedititemclassty;
begin
 result:= tlistedititem;
end;

procedure tcustomitemeditlist.itemclasschanged();
begin
 fowner.updatelayout();
end;

function tcustomitemeditlist.getimagelist: timagelist;
begin
 result:= nil;
// result:= fboxglyph_list;
end;

procedure tcustomitemeditlist.setcolorglyph(const avalue: colorty);
begin
 if fcolorglyph <> avalue then begin
  fcolorglyph:= avalue;
  fowner.itemchanged(-1);
 end;
end;

procedure tcustomitemeditlist.setcolorglyphactive(const avalue: colorty);
begin
 if fcolorglyphactive <> avalue then begin
  fcolorglyphactive:= avalue;
  fowner.itemchanged(-1);
 end;
end;

function tcustomitemeditlist.getboxglyph_checkbox: stockglyphty;
begin
 result:= stockglyphty(fboxids[tib_checkbox]);
end;

procedure tcustomitemeditlist.setboxglyph_checkbox(const avalue: stockglyphty);
begin
 if stockglyphty(fboxids[tib_checkbox]) <> avalue then begin
  stockglyphty(fboxids[tib_checkbox]):= avalue;
  if fowner <> nil then begin
   fowner.itemchanged(-1);
  end;
 end;
end;

function tcustomitemeditlist.getboxglyph_checkboxchecked: stockglyphty;
begin
 result:= stockglyphty(fboxids[tib_checkboxchecked]);
end;

procedure tcustomitemeditlist.setboxglyph_checkboxchecked(
              const avalue: stockglyphty);
begin
 if stockglyphty(fboxids[tib_checkboxchecked]) <> avalue then begin
  stockglyphty(fboxids[tib_checkboxchecked]):= avalue;
  if fowner <> nil then begin
   fowner.itemchanged(-1);
  end;
 end;
end;

function tcustomitemeditlist.getboxglyph_checkboxparentnotchecked: stockglyphty;
begin
 result:= stockglyphty(fboxids[tib_checkboxparentnotchecked]);
end;

procedure tcustomitemeditlist.setboxglyph_checkboxparentnotchecked(
              const avalue: stockglyphty);
begin
 if stockglyphty(fboxids[tib_checkboxparentnotchecked]) <> avalue then begin
  stockglyphty(fboxids[tib_checkboxparentnotchecked]):= avalue;
  if fowner <> nil then begin
   fowner.itemchanged(-1);
  end;
 end;
end;

function tcustomitemeditlist.getboxglyph_checkboxchildchecked: stockglyphty;
begin
 result:= stockglyphty(fboxids[tib_checkboxchildchecked]);
end;

procedure tcustomitemeditlist.setboxglyph_checkboxchildchecked(
              const avalue: stockglyphty);
begin
 if stockglyphty(fboxids[tib_checkboxchildchecked]) <> avalue then begin
  stockglyphty(fboxids[tib_checkboxchildchecked]):= avalue;
  if fowner <> nil then begin
   fowner.itemchanged(-1);
  end;
 end;
end;

function tcustomitemeditlist.getboxglyph_checkboxchildnotchecked: stockglyphty;
begin
 result:= stockglyphty(fboxids[tib_checkboxchildnotchecked]);
end;

procedure tcustomitemeditlist.setboxglyph_checkboxchildnotchecked(
              const avalue: stockglyphty);
begin
 if stockglyphty(fboxids[tib_checkboxchildnotchecked]) <> avalue then begin
  stockglyphty(fboxids[tib_checkboxchildnotchecked]):= avalue;
  if fowner <> nil then begin
   fowner.itemchanged(-1);
  end;
 end;
end;
{
procedure tcustomitemeditlist.setboxglyp_list(const avalue: timagelist);
begin
 setlinkedvar(avalue,tmsecomponent(fboxglyph_list));
end;

procedure tcustomitemeditlist.setboxglyp_listactive(const avalue: timagelist);
begin
 setlinkedvar(avalue,tmsecomponent(fboxglyph_listactive));
end;
}
procedure tcustomitemeditlist.setboxglyph_versionactive(const avalue: int32);
begin
 if fboxglyph_versionactive <> avalue then begin
  fboxglyph_versionactive:= avalue;
  if fboxglyph_versionactive < 0 then begin
   fboxglyph_versionactive:= 0;
  end;
  if fowner <> nil then begin
   fowner.itemchanged(-1);
  end;
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
  tlistitem1(anode).setowner(self);
  tlistitem1(anode).findex:= int1;
  fintf.itemcountchanged;
  fintf.updateitemvalues(int1,1);
 finally
  endupdate;
 end;
// adddata(anode);
end;

procedure tcustomitemeditlist.insert(const aindex: integer;
                                               const anode: tlistitem);
begin
 checkitemclass(anode);
 with fintf.getgrid do begin
  insertrow(aindex);
 end;
 tlistitem1(anode).setowner(self);
 tlistitem1(anode).findex:= aindex;
 items[aindex]:= anode;
 fintf.updateitemvalues(aindex,1);
{
 beginupdate;
 try
  internalinsertdata(aindex,anode,false);
  tlistitem1(anode).setowner(self);
  tlistitem1(anode).findex:= aindex;
  fintf.itemcountchanged;
  fintf.updateitemvalues(aindex,1);
 finally
  endupdate;
 end;
}
end;

procedure tcustomitemeditlist.refreshitemvalues(aindex: integer = 0;
                                                        acount: integer = -1);
begin
 beginupdate;
 try
  if aindex < 0 then begin
   aindex:= fowner.gridrow;
  end;
  if (aindex >= 0) and (aindex < fcount) then begin
   if acount < 0 then begin
    acount:= fcount;
   end;
   if acount + aindex > fcount then begin
    acount:= fcount - aindex;
   end;
   fintf.updateitemvalues(aindex,acount);
  end;
 finally
  endupdate;
 end;
end;

procedure tcustomitemeditlist.doitemchange(const index: integer);
begin
 if fowner <> nil then begin
  fowner.itemchanged(index);
 end;
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
  if not (ainfo.action in [na_change,na_valuechange,na_checkedchange]) or
                                              (nochange = 0) then begin
   if fowner.canevent(tmethod(fonitemnotification)) then begin
    fonitemnotification(sender,ainfo.action);
   end;
  end;
  inherited;
  if ainfo.action in [na_expand,na_collapse] then begin
   change(sender);
  end;
  if (nochange = 0) and
             (ainfo.action in [na_valuechange,na_checkedchange]) and
                         not (ils_updateitemvalues in fitemstate) then begin
   include(fitemstate,ils_updateitemvalues);
   try
    fintf.updateitemvalues(sender.index,1);
   finally
    exclude(fitemstate,ils_updateitemvalues);
   end;
  end;
 end;
end;

function tcustomitemeditlist.compare(const l,r): integer;
begin
 result:= tlistitem1(l).compare(tlistitem(r),
                           oe_casesensitive in fowner.foptionsedit);
{
 if oe_casesensitive in fowner.foptionsedit then begin
  result:= msecomparestr(tlistitem1(l).fcaption,tlistitem1(r).fcaption);
 end
 else begin
  result:= msecomparetext(tlistitem1(l).fcaption,tlistitem1(r).fcaption);
 end;
}
end;

procedure tcustomitemeditlist.createstatitem(const reader: tstatreader;
                                                       out item: tlistitem);
var
 i1: int32;
begin
 if no_createvalueitems in foptions then begin
  i1:= reader.readinteger(valuenodetypename);
  if (i1 <= 0) or (i1 > ord(high(valuenodeclasses))) then begin
   inherited;
  end
  else begin
   item:= valuenodeclasses[listdatatypety(i1)].create(self);
  end;
 end
 else begin
  inherited;
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
 itemclasschanged();
end;

function titemeditlist.getoncreateitem: createlistitemeventty;
begin
 result:= createlistitemeventty(oncreateobject);
end;

procedure titemeditlist.setoncreateitem(const value: createlistitemeventty);
begin
 oncreateobject:= createobjecteventty(value);
end;

{ tvalueedititem }

destructor tvalueedititem.destroy;
begin
 editwidget:= nil; //remove link, objectlinker of owner is used.
 inherited;
end;

procedure tvalueedititem.changed;
begin
 with tcustomitemedit(fowner) do begin
  if componentstate * [csloading,csdestroying] = [] then begin
   valueeditchanged();
  end;
 end;
end;

procedure tvalueedititem.seteditwidget(const avalue: twidget);
begin
 if avalue <> finfo.editwidget then begin
  if (avalue <> nil) and (not getcorbainterface(avalue,typeinfo(igridwidget),
                                                           finfo.gridintf) or
                                 (avalue.parentwidget <> fowner)) then begin
   raise exception.create('Invalid item field edit widget "'+avalue.name+'".');
  end;
  if (finfo.editwidget <> nil) and (finfo.gridintf <> nil) then begin
   finfo.gridintf.setparentgridwidget(nil);
  end;
  tcustomitemedit(fowner).setlinkedvar(avalue,tmsecomponent(finfo.editwidget));
  if avalue = nil then begin
   finfo.gridintf:= nil;
   finfo.datatype:= dl_none;
  end
  else begin
   finfo.gridintf.setparentgridwidget(igridwidget(tcustomitemedit(fowner)));
   finfo.datatype:= finfo.gridintf.getdatalistclass().datatype();
  end;
  changed();
 end;
end;

procedure tvalueedititem.setvalueindex(const avalue: int32);
begin
 if finfo.valueindex <> avalue then begin
  finfo.valueindex:= avalue;
  changed();
 end;
end;

{ tvalueedits }

constructor tvalueedits.create(const aowner: tcustomitemedit);
begin
 inherited create(aowner,tvalueedititem);
end;

class function tvalueedits.getitemclasstype: persistentclassty;
begin
 result:= tvalueedititem;
end;

{ tcustomitemedit }

constructor tcustomitemedit.create(aowner: tcomponent);
begin
 fentryedge:= gd_none;
 fvalueedits:= tvalueedits.create(self);
 include(fstate,des_editing);
// fediting:= true;
 if fitemlist = nil then begin
  fitemlist:=  titemeditlist.create(iitemlist(self),self);
 end;
 flayoutinfofocused.widget:= self;
 inherited;
 textflags:= defaultitemedittextflags;
 textflagsactive:= defaultitemedittextflagsactive;
// createframe;
end;

destructor tcustomitemedit.destroy;
begin
 if fgridintf = nil then begin
  freeandnil(fitemlist);
 end;
 fvalueedits.free();
 inherited;
end;

function tcustomitemedit.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= fitemlist;
end;

function tcustomitemedit.getdatalistclass: datalistclassty;
begin
 result:= titemeditlist;
end;

procedure tcustomitemedit.setgridintf(const intf: iwidgetgrid);
var
 li1: tcustomitemeditlist;
begin
 inherited;
 if intf <> nil then begin
  li1:= tcustomitemeditlist(intf.getcol.datalist);
  if li1 <> nil then begin
   if fitemlist = nil then begin //changed inherited grid col
    fitemlist:= tcustomitemeditlist(intf.getcol.datalist);
   end
   else begin
    if fitemlist <> li1 then begin
     fitemlist.free;
     fitemlist:= li1;
    end;
   end;
   fitemlist.fowner:= self;
   fitemlist.fintf:= iitemlist(self);
  end;
  if fitemlist.count > 0 then begin
   itemcountchanged;
  end
  else begin
   fitemlist.count:= intf.getcol.grid.rowcount;
  end;
  updatelayout;
 end;
end;

procedure tcustomitemedit.createnode(var item: tlistitem);
begin
 item:= tlistitem.create(fitemlist);
end;

function tcustomitemedit.getlayoutinfo(
                       const acellinfo: pcellinfoty): plistitemlayoutinfoty;
begin
 if (ws1_painting in fwidgetstate1) or (des_updatelayout in fstate) then begin
  result:= @flayoutinfofocused;                     //active
  with result^.variable do begin
   colorglyph:= fitemlist.fcolorglyphactive;
   colorline:= fitemlist.fcolorlineactive;
   glyphversion:= fitemlist.boxglyph_versionactive;
  end;
 end
 else begin
  result:= @flayoutinfocell;
  if (acellinfo <> nil) and
          ((acellinfo^.rect.cx <> fcalcsize.cx) or
           (acellinfo^.rect.cy <> fcalcsize.cy)) then begin
   fcalcsize:= acellinfo^.rect.size;
   calclayout(fcalcsize,flayoutinfocell);
  end;
 end;
 with result^.variable do begin
  if acellinfo <> nil then begin
   if cds_usecoloractive in acellinfo^.drawstate then begin
    colorglyph:= fitemlist.fcolorglyphactive;
    colorline:= fitemlist.fcolorlineactive;
    glyphversion:= fitemlist.boxglyph_versionactive;
   end
   else begin
    colorglyph:= fitemlist.fcolorglyph;
    colorline:= fitemlist.fcolorline;
    glyphversion:= 0;
   end;
  end;
  if stockobjects.glyphs.versioncount <= glyphversion then begin
   glyphversion:= 0;
  end;
 end;
end;

procedure tcustomitemedit.updateitemvalues(const index: integer; const count: integer);
var
 int1,int2: integer;
 po1: plistitem;
 po2: plistitematy;
 col1: tdatacol;
begin
 if (no_cellitemselect in fitemlist.options) and (fgridintf <> nil) then begin
  col1:= fgridintf.getcol;
  po2:= fitemlist.datapo;
  for int1:= index to index + count - 1 do begin
   col1.selected[int1]:= ns_selected in tlistitem1(po2^[int1]).fstate;
  end;
 end;
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
 if (fgridintf <> nil) then begin
 {$warnings off}
  with tcustomgrid1(fgridintf.getcol.grid) do begin
 {$warnings on}
//    sortinvalid(invalidaxis,invalidaxis);
   rowdatachanged(makegridcoord(invalidaxis,index),count);
//   if not fitemlist.updating then begin
//    checksort;
//   end;
  end;
 end;
end;

procedure tcustomitemedit.updateitemvalues();
        //calls updateitemvalues for current grid row
var
 int1: integer;
begin
 if fgridintf <> nil then begin
  int1:= fgridintf.getrow;
  if int1 >= 0 then begin
   updateitemvalues(int1,1);
  end;
 end;
end;

procedure tcustomitemedit.itemcountchanged;
begin
 fvalue:= nil; //invalid
 if fgridintf <> nil then begin
  with fgridintf.getcol.grid do begin
   rowcount:= fitemlist.count;
//   rowdatachanged(makegridcoord(invalidaxis,0),fitemlist.count);
  end;
 end;
end;

procedure tcustomitemedit.getitemvalues;
begin
 if fvalue = nil then begin
  text:= '';
 end
 else begin
  text:= fvalue.caption;
 end;
 updateeditwidget();
 setupeditor;
end;

procedure tcustomitemedit.gridtovalue(arow: integer);
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
 end;
 getitemvalues;
 inherited;
end;

procedure tcustomitemedit.valuetogrid(arow: integer);
begin
 if arow >= 0 then begin
  fitemlist.incupdate;
  try
   updateitemvalues(arow,1);
  finally
   fitemlist.decupdate;
  end;
 end;
end;

function tcustomitemedit.finddataedits(aitem: tlistitem;
                          out ainfos: recvaluearty): boolean;
var
 i1,i2: int32;
 po1: precvaluety;
 intf1: irecordvaluefield;
begin
 result:= false;
 if (fvalueedits.count > 0) and (aitem <> nil) and
   mseclasses.getcorbainterface(aitem.valueitem,
                       typeinfo(irecordvaluefield),intf1) then begin

//         (aitem is trecordlistedititem) then begin
//  with irecordvaluefield(trecordlistedititem(aitem)) do begin
  with intf1 do begin
   getvalueinfo(ainfos);
   for i1:= 0 to high(ainfos) do begin
    po1:= @ainfos[i1];
    po1^.dummypointer:= nil;
    if po1^.datatype <> dl_none then begin
     if (po1^.valueindex >= 0) then begin
      for i2:= 0 to fvalueedits.count - 1 do begin
       with tvalueedititem(fvalueedits.fitems[i2]) do begin
        if (finfo.datatype = po1^.datatype) and
                             (finfo.valueindex = po1^.valueindex) then begin
         po1^.dummypointer:= @finfo; //check index match
         result:= true;
         break;
        end;
       end;
      end;
     end;
     if po1^.dummypointer = nil then begin
      for i2:= 0 to fvalueedits.count - 1 do begin
       with tvalueedititem(fvalueedits.fitems[i2]) do begin
        if finfo.datatype = po1^.datatype then begin
         po1^.dummypointer:= @finfo; //check any match
         result:= true;
         break;
        end;
       end;
      end;
     end;
    end;
   end;
  end;
 end;
end;

function tcustomitemedit.updateeditwidget(): boolean;
                                        //true if editwidgetactivated
var
 infos1: recvaluearty;
 i1: int32;
 bo1: boolean;
 widget1: twidget;
begin
 result:= finddataedits(fvalue,infos1);
 if result then begin
  for i1:= 0 to fvalueedits.count - 1 do begin
   with tvalueedititem(fvalueedits.fitems[i1]) do begin
    finfo.visible:= false;
   end;
  end;
  bo1:= false;
  fvisiblevalueeditcount:= 0;
  for i1:= 0 to high(infos1) do begin
   with infos1[i1] do begin
    if dummypointer <> nil then begin
     with pvalueeditinfoty(dummypointer)^ do begin
      if gridintf <> nil then begin
       visible:= true;
       gridintf.setvaluedata(valuead^);
       editwidget.visible:= true;
       inc(fvisiblevalueeditcount);
       if not bo1 then begin
        bo1:= true;
        factiveinfo:= pvalueeditinfoty(dummypointer)^;
{
        if focused then begin
         editwidget.setfocus();
        end;
}
       end;
      end;
     end;
    end;
   end;
  end;
  for i1:= 0 to fvalueedits.count - 1 do begin
   with tvalueedititem(fvalueedits.fitems[i1]) do begin
    if not finfo.visible and (finfo.editwidget <> nil) then begin
     finfo.editwidget.visible:= false;
    end;
   end;
  end;
  if focused then begin
   widget1:= getcornerwidget(fentryedge,true);
   if widget1 <> nil then begin
    widget1.setfocus();
   end
   else begin
    if factiveinfo.editwidget <> nil then begin
     factiveinfo.editwidget.setfocus();
    end;
   end;
  end;
 end
 else begin
  fillchar(factiveinfo,sizeof(factiveinfo),0);
  for i1:= 0 to fvalueedits.count - 1 do begin
   with tvalueedititem(fvalueedits.fitems[i1]) do begin
    finfo.visible:= false;
    if finfo.editwidget <> nil then begin
     finfo.editwidget.visible:= false;
    end;
   end;
  end;
 end;
end;

procedure tcustomitemedit.drawcell(const canvas: tcanvas);
var
 databefore: pointer;
 infos1: recvaluearty;
 i1: int32;
 fra1,fra2: framety;
 fs1: widgetstatesty;
begin
 with cellinfoty(canvas.drawinfopo^) do begin
  fs1:= [];
  if focused then begin
   include(fs1,ws_focused);
   if active then begin
    include(fs1,ws_active);
   end;
  end;
  flayoutinfocell.variable.widgetstate:= fs1;
  doextendimage(canvas.drawinfopo,flayoutinfocell.variable.extra);
  flayoutinfocell.variable.rowindex:= cell.row;
  flayoutinfocell.textflags:= textflags;
  if finddataedits(tlistitem(datapo^),infos1) then begin
   databefore:= datapo;
   fra1:= getcellframe;
   inflaterect1(innerrect,fra1);
   for i1:= 0 to high(infos1) do begin
    with infos1[i1] do begin
     if dummypointer <> nil then begin
      with pvalueeditinfoty(dummypointer)^ do begin
       datapo:= valuead;
       fra2:= gridintf.getcellframe;
       deflaterect1(innerrect,fra2);
       gridintf.drawcell(canvas);
       inflaterect1(innerrect,fra2);
      end;
     end;
    end;
    datapo:= databefore;
    deflaterect1(innerrect,fra1);
   end;
  end
  else begin
   tlistitem(datapo^).drawcell(canvas);
  end;
 end;
 paintimage(canvas);
end;

procedure tcustomitemedit.childdataentered(const sender: igridwidget);
var
 intf1: irecordvaluefield;
begin
 if sender = factiveinfo.gridintf then begin
  if (fvalue <> nil) and mseclasses.getcorbainterface(fvalue.valueitem,
                       typeinfo(irecordvaluefield),intf1) then begin
//  if fvalue is trecordlistedititem then begin
//   with irecordvaluefield(trecordlistedititem(fvalue)) do begin
   with intf1 do begin
    setvalue(factiveinfo.datatype,factiveinfo.valueindex,@sender.getvaluedata);
   end;
  end;
 end;
end;

procedure tcustomitemedit.childfocused(const sender: igridwidget);
var
 infos1: recvaluearty;
 i1: int32;
 widget1: twidget;
 intf1: irecordvaluefield;
begin
 if mseclasses.getcorbainterface(fvalue,
                       typeinfo(irecordvaluefield),intf1) then begin
// if fvalue is trecordlistedititem then begin
  if finddataedits(tlistitem(fvalue),infos1) then begin
   widget1:= sender.getwidget;
   for i1:= 0 to high(infos1) do begin
    with infos1[i1] do begin
     if (dummypointer <> nil) then begin
      with pvalueeditinfoty(dummypointer)^ do begin
       if editwidget = widget1 then begin
        factiveinfo:= pvalueeditinfoty(dummypointer)^;
        break;
       end;
      end;
     end;
    end;
   end;
  end;
 end;
end;

function tcustomitemedit.internaldatatotext(const data): msestring;
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

procedure tcustomitemedit.dosetvalue(var avalue: msestring; var accept: boolean);
begin
 if canevent(tmethod(fonsetvalue)) then begin
  fonsetvalue(self,avalue,accept);
 end;
end;

procedure tcustomitemedit.storevalue(var avalue: msestring);
begin
 fvalue.caption:= avalue;
end;

procedure tcustomitemedit.texttovalue(var accept: boolean; const quiet: boolean);
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
  storevalue(mstr1);
 end;
end;

procedure tcustomitemedit.calclayout(const asize: sizety;
                                           out alayout: listitemlayoutinfoty);
begin
 if fframe <> nil then begin
  getitemclass.calcitemlayout(asize,tframe1(fframe).fi.innerframe,
                                             fitemlist,alayout);
 end
 else begin
  getitemclass.calcitemlayout(asize,minimalframe,fitemlist,alayout);
 end;
 alayout.textflags:= textflags;
end;

procedure tcustomitemedit.doupdatelayout(const nocolinvalidate: boolean);
begin
 if (fgridintf <> nil) and (fitemlist <> nil) then begin
  calclayout(paintrect.size,flayoutinfofocused);
  invalidate;
  if not fitemlist.updating and not nocolinvalidate then begin
   fgridintf.getcol.changed;
  end;
 end;
end;

procedure tcustomitemedit.doupdatecelllayout;
begin
 flayoutinfocell:= flayoutinfofocused;
 fcalcsize:= flayoutinfofocused.cellsize;
end;

procedure tcustomitemedit.updatelayout;
begin
 doupdatelayout(false);
 doupdatecelllayout;
end;

procedure tcustomitemedit.clientrectchanged;
var
 bo1: boolean;
begin
 doupdatelayout(true); //col invalidated by grid
 doupdatecelllayout;
 bo1:= des_updatelayout in fstate;
 include(fstate,des_updatelayout); //for setupeditor
 try
  inherited;
 finally
  if not bo1 then begin
   exclude(fstate,des_updatelayout);
  end;
 end;
end;

procedure tcustomitemedit.doitembuttonpress(var info: mouseeventinfoty);
begin
 //dummy
end;

procedure tcustomitemedit.clientmouseevent(var info: mouseeventinfoty);
var
 po1: pointty;
 zone1: cellzonety;
begin
 if (fvalue <> nil) and (info.eventkind in mouseposevents) then begin
  zone1:= cz_default;
  fvalue.updatecellzone(info.pos,zone1);
  application.widgetcursorshape:= getcellcursor(-1,zone1,info.pos);
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

function tcustomitemedit.getitemclass: listitemclassty;
begin
// result:= tlistitem;
 result:= listitemclassty(fitemlist.fitemclass);
end;

procedure tcustomitemedit.setupeditor;
var
 bo1: boolean;
begin
 if not (csloading in componentstate) then begin
  if fvalue = nil then begin
   with feditor,flayoutinfofocused do begin
    feditor.setup(text,curindex,false,captioninnerrect,captionrect,nil,nil,
              geteditfont);
   end;
  end
  else begin
   bo1:= des_updatelayout in fstate;
   include(fstate,des_updatelayout);
   doextendimage(nil,flayoutinfofocused.variable.extra);
   fvalue.setupeditor(feditor,geteditfont,true);
   if not bo1 then begin
    exclude(fstate,des_updatelayout);
   end;
  end;
 end;
end;

procedure tcustomitemedit.dopaintforeground(const acanvas: tcanvas);
begin
 if fvalue <> nil then begin
  doextendimage(acanvas.drawinfopo,flayoutinfofocused.variable.extra);
 end;
 inherited;
 if fvalue <> nil then begin
  if fgridintf <> nil then begin
   acanvas.rootbrushorigin:= fgridintf.getbrushorigin;
   flayoutinfofocused.variable.rowindex:= fgridintf.grid.row;
  end;
  with tlistitem1(fvalue) do begin
   flayoutinfofocused.variable.calcautocellsize:= false;
   flayoutinfofocused.variable.widgetstate:= widgetstate;
   drawimage(acanvas,flayoutinfofocused);
   if feditor.lasttextclipped then begin
    include(fstate1,ns1_captionclipped);
   end
   else begin
    exclude(fstate1,ns1_captionclipped);
   end;
  end;
 end;
end;

procedure tcustomitemedit.itemchanged(const index: integer);
begin
 if (fgridintf <> nil) then begin
  if (factiverow < 0) or (factiverow >= fitemlist.count) then begin
   fvalue:= nil;
  end;
  fgridintf.getcol.cellchanged(index);
 end;
 changed;
end;

function tcustomitemedit.getitemlist: titemeditlist;
begin
 result:= titemeditlist(fitemlist);
end;

procedure tcustomitemedit.setitemlist(const Value: titemeditlist);
begin
 fitemlist.Assign(Value);
end;

procedure tcustomitemedit.dokeydown(var info: keyeventinfoty);
var
 widget1: twidget;
begin
 doonkeydown(info);
 with info do begin
  if not(es_processed in eventstate) then begin
   if not (es_child in info.eventstate) then begin
    if (oe_locate in foptionsedit) and isenterkey(nil,key) and
                        (shiftstate = []) then begin
     if not editing then begin
      editing:= not (oe_readonly in foptionsedit) and valuecanedit() and
                      ((fvalue = nil) or tlistitem1(fvalue).cancaptionedit());

                   ;
      if editing then begin
       include(eventstate,es_processed);
      end;
     end
     else begin
      if not editing then begin
       include(eventstate,es_processed); //trigger checkvalue otherwise
      end;
      editing:= false;
     end;
    end
    else begin
     if (key = key_space) and
        (shiftstate * shiftstatesrepeatmask = []) and
        not (es_processed in eventstate) and
        (not editing)  and valuecanedit() and
                   (ns_checkbox in fvalue.state) and
                   (editor.filtertext = '') then begin
      fvalue.checked:= not fvalue.checked;
     end;
    end;
   end
   else begin
    if (fvisiblevalueeditcount > 0) then begin
     widget1:= window.focusedwidget;
     if checkdescendent(widget1) then begin
      twidget1(widget1).handlenavigkeys(info,true); //nowrap
     end;
     if window.focusedwidget = widget1 then begin
      exclude(info.eventstate,es_processed);
     end;
    end;
   end;
  end;
 end;
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;

function tcustomitemedit.getvaluetext: msestring;
begin
 if (fvalue <> nil) then begin
  result:= fvalue.getvaluetext;
 end
 else begin
  result:= '';
 end;
end;

procedure tcustomitemedit.setvaluetext(var avalue: msestring);
begin
 if (fvalue <> nil) then begin
  fvalue.setvaluetext(avalue);
 end;
end;

function tcustomitemedit.item: tlistedititem;
begin
 result:= tlistedititem(fvalue);
end;

procedure tcustomitemedit.internalcreateframe;
begin
 tbuttonsframe.create(iscrollframe(self),ibutton(self));
end;

{$ifdef mse_with_ifi}
function tcustomitemedit.getifilink: tifistringlinkcomp;
begin
 if fitemifilink then begin
  result:= nil;
 end
 else begin
  result:= tifistringlinkcomp(fifilink);
 end;
end;

procedure tcustomitemedit.setifilink(const avalue: tifistringlinkcomp);
begin
 fitemifilink:= false;
 inherited setifilink(avalue);
end;

function tcustomitemedit.getifilink1: tifilinkcomp;
begin
 if not fitemifilink then begin
  result:= nil;
 end
 else begin
  result:= fifilink;
 end;
end;

procedure tcustomitemedit.setifilink1(const avalue: tifilinkcomp);
begin
 fitemifilink:= true;
 inherited setifilink(avalue);
end;

procedure tcustomitemedit.updateifigriddata(const sender: tobject;
               const alist: tdatalist);
begin
 //dummy, common datalist not possible
end;

{$endif}

function tcustomitemedit.isnull: boolean;
begin
 result:= (item = nil) or (item.caption = '');
end;

procedure tcustomitemedit.buttonaction(var action: buttonactionty;
  const buttonindex: integer);
begin
 if canevent(tmethod(fonbuttonaction)) then begin
  fonbuttonaction(self,action,buttonindex);
 end;
end;

procedure tcustomitemedit.mouseevent(var info: mouseeventinfoty);
begin
 if fframe <> nil then begin
  tcustombuttonframe(fframe).mouseevent(info);
 end;
 inherited;
end;

{
procedure tcustomitemedit.sortfunc(const l, r; var result: integer);
begin
 if oe_casesensitive in foptionsedit then begin
  result:= msecomparestr(tlistitem1(l).fcaption,tlistitem1(r).fcaption);
 end
 else begin
  result:= msecomparetext(tlistitem1(l).fcaption,tlistitem1(r).fcaption);
 end;
end;
}
function tcustomitemedit.getitems(const index: integer): tlistitem;
begin
 result:= tlistitem(fitemlist[index]);
end;

procedure tcustomitemedit.setitems(const index: integer; const Value: tlistitem);
begin
 fitemlist[index]:= value;
end;

function tcustomitemedit.locatecount: integer;        //number of locate values
begin
 result:= fitemlist.count;
end;

function tcustomitemedit.getkeystring(const index: integer): msestring;
begin
 result:= fitemlist[index].caption;
end;
{
function tcustomitemedit.islocating: boolean;
begin
 result:= not editing and (oe_locate in foptionsedit)
end;
}
(*
procedure tcustomitemedit.setfiltertext(const value: msestring);
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
{
function tcustomitemedit.getcolorglyph: colorty;
begin
 result:= fitemlist.fcolorglyph;
end;
}
procedure tcustomitemedit.docellevent(const ownedcol: boolean;
                                            var info: celleventinfoty);
begin
 with info do begin
  if ownedcol then begin
   if eventkind in mousecellevents then begin
    if fvalue <> nil then begin
     fvalue.updatecellzone(info.mouseeventinfopo^.pos,info.zone);
    end;
   end;
   if (info.eventkind = cek_enter) then begin
    if (widgetcount > 1) and (cellbefore.col >= 0) and
                                            (cellbefore.row >= 0) then begin
    fentryedge:= gd_none;
     if cellbefore.row < cell.row then begin
      fentryedge:= gd_up;
     end
     else begin
      if cellbefore.row > cell.row then begin
       fentryedge:= gd_down;
      end
      else begin
       if cellbefore.col < cell.col then begin
        fentryedge:= gd_left;
       end
       else begin
        if cellbefore.col > cell.col then begin
         fentryedge:= gd_right;
        end;
       end;
      end;
     end;
    end;
   end
   else begin
    if eventkind = cek_exit then begin
     fentryedge:= gd_none;
    end;
   end;
  end;
  if (info.eventkind = cek_enter) or
                            (info.eventkind = cek_exit) then begin
   if oe_locate in foptionsedit then begin
    editing:= false;
   end;
   factiverow:= info.newcell.row;
  end;
 end;
 if canevent(tmethod(foncellevent)) then begin
   foncellevent(self,info);
 end;
 inherited;
end;

function tcustomitemedit.getediting: boolean;
begin
 result:= des_editing in fstate;
end;

procedure tcustomitemedit.setediting(const avalue: boolean);
begin
 if editing <> avalue then begin
  if avalue or (oe_locate in foptionsedit) then begin
   if avalue then begin
    include(fstate,des_editing);
   end
   else begin
    exclude(fstate,des_editing);
   end;
   setupeditor;
   if editing then begin
    feditor.selectall;
   end
   else begin
    if foptionsedit * [oe_autoselect,oe_locate] = [oe_autoselect] then begin
     feditor.selectall;
    end;
   end;
  end
  else begin
   exclude(fstate,des_editing);
  end;
//  cursorchanged;
  updatereadonlystate;
 end;
end;

function tcustomitemedit.getoptionsedit: optionseditty;
begin
 result:= inherited getoptionsedit;
 if oe_readonly in result then begin
  editing:= false;
 end;
 if not editing and not (csdesigning in componentstate) then begin
  include(result,oe_readonly);
 end;
end;

procedure tcustomitemedit.beginedit;
begin
 editing:= true;
end;

procedure tcustomitemedit.endedit;
begin
 editing:= false;
end;

function tcustomitemedit.valuecanedit: boolean;
begin
 result:= (fvalue <> nil) and tlistitem1(fvalue).canvalueedit();
 if (fvalue <> nil) and canevent(tmethod(foncheckcanedit)) then begin
  foncheckcanedit(self,fvalue,result);
 end;
end;

procedure tcustomitemedit.doextendimage(const cellinfopo: pcellinfoty;
                                               var ainfo: extrainfoty);
begin
 fillchar(ainfo,sizeof(ainfo),#0);
 if canevent(tmethod(fonextendimage)) then begin
  fonextendimage(self,cellinfopo,ainfo);
 end;
end;

procedure tcustomitemedit.getautopaintsize(var asize: sizety);
begin
 inherited;
 if (fvalue <> nil) and (fvalue.owner <> nil) then begin
  with flayoutinfofocused.variable do begin
   calcautocellsize:= true;
   fillchar(extra,sizeof(extra),#0);
  end;
  fvalue.drawimage(editor.getfontcanvas(),flayoutinfofocused);
 end;
 with flayoutinfofocused do begin
  asize.cx:= asize.cx + imagerect.cx + variable.imageextend.cx +
                   {imageextra.cx +}
                     variable.treelevelshift; //???
  if asize.cy < minsize.cy then begin
   asize.cy:= minsize.cy;
  end;
  if asize.cx < minsize.cx then begin
   asize.cx:= minsize.cx;
  end;
 end;
end;

procedure tcustomitemedit.getautocellsize(const acanvas: tcanvas;
                                      var asize: sizety);
begin
 if fvalue <> nil then begin
  drawcell(acanvas); //called from twidgetcol.drawfocusedcell()
  asize:= cellinfoty(acanvas.drawinfopo^).autocellsize;
 end
 else begin
  inherited;
 end;
end;

function tcustomitemedit.getcellcursor(const arow: integer;
            const acellzone: cellzonety; const apos: pointty): cursorshapety;
begin
 if acellzone = cz_child then begin
  if flastzonewidget <> nil then begin
   result:= flastzonewidget.actualcursor(apos);
  end
  else begin
   result:= cr_default;
  end;
 end
 else begin
  if (acellzone = cz_caption) and
                        ((foptionsedit * [oe_locate,oe_readonly] = []) or
                        (arow < 0) and (editing)) then begin
   result:= cursor;
   if result = cr_default then begin
    result:= cr_ibeam;
   end;
  end
  else begin
   if (acellzone = cz_caption) and
                     (foptionsedit * [oe_locate,oe_readonly] <> []) then begin
    result:= cursorreadonly;
    if result = cr_default then begin
     result:= cr_arrow;
    end;
   end
   else begin
    result:= cr_arrow;
 //   result:= cr_default;
   end;
  end;
 end;
end;

procedure tcustomitemedit.updatecellzone(const row: integer; const apos: pointty;
                            var result: cellzonety);
var
 ar1: recvaluearty;
 i1: int32;
begin
 inherited;
 if fitemlist <> nil then begin
  flastzonewidget:= nil;
  if (fvalueedits.count > 0) and finddataedits(fitemlist[row],ar1) then begin
   for i1:= 0 to high(ar1) do begin
    with ar1[i1] do begin
     if dummypointer <> nil then begin
      with pvalueeditinfoty(dummypointer)^ do begin
       if (editwidget <> nil) and
           pointinrect(apos,editwidget.widgetrect) then begin
        result:= cz_child;
        flastzonewidget:= editwidget;
       end;
      end;
     end;
    end;
   end;
  end;
  if flastzonewidget = nil then begin
   fitemlist[row].updatecellzone(apos,result);
  end;
 end;
end;

function tcustomitemedit.getgrid: tcustomgrid;
begin
 result:= nil;
 if fgridintf <> nil then begin
  result:= fgridintf.getcol.grid;
 end;
end;

function tcustomitemedit.selecteditems: listedititemarty;
var
 int1: integer;
 ar1: integerarty;
 po1: ppointeraty;
begin
 result:= nil;
 if fgridintf <> nil then begin
  with fgridintf.getcol do begin
   if datalist <> nil then begin
    ar1:= selectedcells;
    setlength(result,length(ar1));
    po1:= datalist.datapo;
    for int1:= 0 to high(result) do begin
     result[int1]:= tlistitem(po1^[ar1[int1]]);
    end;
   end;
  end;
 end;
end;

procedure tcustomitemedit.datalistdestroyed;
begin
 fitemlist:= nil;
end;

function tcustomitemedit.textclipped(const arow: integer;
               out acellrect: rectty): boolean;
var
 cell1: gridcoordty;
 grid1: tcustomgrid;
// bo1: boolean;
begin
 checkgrid;
 with twidgetcol1(fgridintf.getcol) do begin
  grid1:= grid;
  cell1.row:= arow;
  cell1.col:= colindex;
  result:= grid1.isdatacell(cell1);
  if result then begin
   acellrect:= grid1.clippedcellrect(cell1,cil_inner);
   if focused and (arow = grid1.row) then begin
    result:= feditor.lasttextclipped; //todo: check value edit widget
   end
   else begin
    result:= ns1_captionclipped in tlistitem1(fitemlist[arow]).fstate1;
   end;
  end
  else begin
   acellrect:= nullrect;
  end;
 end;
end;

function tcustomitemedit.getframe(): tbuttonsframe;
begin
 result:= tbuttonsframe(inherited getframe());
end;

procedure tcustomitemedit.setframe(const avalue: tbuttonsframe);
begin
 inherited setframe(avalue);
end;

procedure tcustomitemedit.insertwidget(const awidget: twidget; const apos: pointty);
var
 intf1: igridwidget;
begin
 inherited;
 if not (csloading in componentstate) then begin
  if awidget.getcorbainterface(typeinfo(igridwidget),intf1) then begin
   awidget.visible:= false;
   intf1.initgridwidget();
   awidget.anchors:= [];
  end;
 end;
end;

procedure tcustomitemedit.setvalueedits(const avalue: tvalueedits);
begin
 fvalueedits.assign(avalue);
end;

procedure tcustomitemedit.valueeditchanged();
begin
end;

procedure tcustomitemedit.loaded();
begin
 inherited;
 valueeditchanged();
end;

procedure tcustomitemedit.setfirstclick(var ainfo: mouseeventinfoty);
begin
 if (factiveinfo.editwidget <> nil) and
      pointinrect(ainfo.pos,factiveinfo.editwidget.paintparentrect) then begin
  factiveinfo.gridintf.setfirstclick(ainfo);
 end
 else begin
  inherited;
 end;
end;

procedure tcustomitemedit.dofocus();
var
 widget1: twidget;
begin
 widget1:= getcornerwidget(fentryedge,true);
 if widget1 <> nil then begin
  widget1.setfocus();
 end
 else begin
  if factiveinfo.editwidget <> nil then begin
   factiveinfo.editwidget.setfocus();
  end
  else begin
   inherited;
  end;
 end;
end;

procedure tcustomitemedit.unregisterchildwidget(const child: twidget);
var
 i1: int32;
begin
 if not (csdestroying in componentstate) then begin
  if child = factiveinfo.editwidget then begin
   factiveinfo.gridintf.setparentgridwidget(nil);
   fillchar(factiveinfo,sizeof(factiveinfo),0);
  end;
  for i1:= 0 to fvalueedits.count - 1 do begin
   with tvalueedititem(fvalueedits.fitems[i1]) do begin
    if finfo.editwidget = child then begin
     editwidget:= nil;
    end;
   end;
  end;
  if child = flastzonewidget then begin
   flastzonewidget:= nil;
  end;
 end;
 inherited;
end;

{
function tcustomitemedit.actualcursor(const apos: pointty): cursorshapety;
var
 zone1: cellzonety;
 int1: integer;
begin
 if fgridintf <> nil then begin
  zone1:= cz_default;
  int1:= fgridintf.grid.row;
  if int1 >= 0 then begin
   updatecellzone(int1,widgetpostoclientpos(apos),zone1);
   result:= getcellcursor(int1,zone1);
   exit;
  end;
 end;
 result:= inherited actualcursor(apos);
end;
}
{
procedure tcustomitemedit.dostatwrite(const writer: tstatwriter);
begin
 fitemlist.statwrite(writer);
end;

procedure tcustomitemedit.dostatread(const reader: tstatreader);
begin
 fitemlist.statread(reader);
end;
}

{ titemedit }

function titemedit.getifiitemlink: tifiitemlinkcomp;
begin
 result:= tifiitemlinkcomp(getifilink1());
end;

procedure titemedit.setifiitemlink(const avalue: tifiitemlinkcomp);
begin
 setifilink1(avalue);
// inherited setifilink(avalue);
end;

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

function tdropdownitemedit.getdropdowncontrollerclass():
                                             dropdownlistcontrollerclassty;
begin
 result:= tdropdownlistcontroller;
end;
{
procedure tdropdownitemedit.internalcreateframe;
begin
 fdropdown.createframe;
end;
}
function tdropdownitemedit.getframe: tdropdownmultibuttonframe;
begin
 result:= tdropdownmultibuttonframe(pointer(inherited getframe));
end;

procedure tdropdownitemedit.setframe(const avalue: tdropdownmultibuttonframe);
begin
 inherited setframe(tbuttonsframe(pointer(avalue)));
end;
{
function tdropdownitemedit.getbutton: tdropdownbutton;
begin
 with tdropdownmultibuttonframe(fframe) do begin
  result:= tdropdownbutton(buttons[activebutton]);
 end;
end;

procedure tdropdownitemedit.setbutton(const avalue: tdropdownbutton);
begin
 with tdropdownmultibuttonframe(fframe) do begin
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
function tdropdownitemedit.getdropdownitems: tdropdowndatacols;
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

procedure tdropdownitemedit.doupdatecelllayout;
begin
 inherited;
 if fframe <> nil then begin
  with tframe1(fframe) do begin
   inflaterect1(flayoutinfocell.captionrect,fpaintframe); //remove buttons
   inflaterect1(flayoutinfocell.captioninnerrect,fpaintframe); //remove buttons
  end;
 end;
end;

procedure tdropdownitemedit.imagelistchanged;
begin
 //dummy
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

function tmbdropdownitemedit.getdropdowncontrollerclass:
                                            dropdownlistcontrollerclassty;
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

function ttreelistedititem.add(const aitem: ttreelistedititem): integer;
begin
 result:= inherited add(aitem);
end;

function ttreelistedititem.add(
           const itemclass: treelistedititemclassty = nil): ttreelistedititem;
begin
 result:= ttreelistedititem(inherited add(itemclass));
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

function ttreelistedititem.endtreerow: integer;
begin
 result:= findex;
 if expanded then begin
  result:= result + treeheight;
 end;
end;

function ttreelistedititem.editwidget: ttreeitemedit;
var
 node1: ttreelistedititem;
begin
 result:= nil;
 node1:= self;
 repeat
  if node1.fowner <> nil then begin
   result:= ttreeitemedit(ttreeitemeditlist(node1.fowner).fowner);
   break;
  end;
  node1:= ttreelistedititem(node1.parent);
 until not (node1 is ttreelistedititem);
end;

procedure ttreelistedititem.activate;
var
 wi1: ttreeitemedit;
begin
 wi1:= editwidget;
 if wi1 <> nil then begin
  rootexpanded:= true;
  with wi1.widgetcol do begin;
   grid.focuscell(mgc(index,self.findex));
   grid.activate;
  end;
//  wi1.activate;
 end;
end;

{ ttreeitemeditlist }

constructor ttreeitemeditlist.create;
begin
 fcolorline:= cl_treeline;
 fcolorlineactive:= cl_treelineactive;
 inherited;
 fitemclass:= ttreelistedititem;
end;

constructor ttreeitemeditlist.create(const intf: iitemlist;
                                               const aowner: ttreeitemedit);
begin
// inherited;
 inherited create(intf,aowner);
end;
{
procedure ttreeitemeditlist.setoptionsdraw(const avalue: itemdrawoptionsty);
begin
 if foptionsdraw <> avalue then begin
  foptionsdraw:= avalue;
  if fowner <> nil then begin
   fowner.itemchanged(-1);
  end;
 end;
end;
}
procedure ttreeitemeditlist.setcolorline(const value: colorty);
begin
 if fcolorline <> value then begin
  fcolorline:= value;
  if fowner <> nil then begin
   fowner.itemchanged(-1);
  end;
 end;
end;

procedure ttreeitemeditlist.setcolorlineactive(const value: colorty);
begin
 if fcolorlineactive <> value then begin
  fcolorlineactive:= value;
  if fowner <> nil then begin
   fowner.itemchanged(-1);
  end;
 end;
end;

function ttreeitemeditlist.getboxglyph_empty: stockglyphty;
begin
 result:= stockglyphty(fboxids[tib_empty]);
end;

procedure ttreeitemeditlist.setboxglyph_empty(const avalue: stockglyphty);
begin
 if stockglyphty(fboxids[tib_empty]) <> avalue then begin
  stockglyphty(fboxids[tib_empty]):= avalue;
  if fowner <> nil then begin
   fowner.itemchanged(-1);
  end;
 end;
end;

function ttreeitemeditlist.getboxglyph_expand: stockglyphty;
begin
 result:= stockglyphty(fboxids[tib_expand]);
end;

procedure ttreeitemeditlist.setboxglyph_expand(const avalue: stockglyphty);
begin
 if stockglyphty(fboxids[tib_expand]) <> avalue then begin
  stockglyphty(fboxids[tib_expand]):= avalue;
  if fowner <> nil then begin
   fowner.itemchanged(-1);
  end;
 end;
end;

function ttreeitemeditlist.getboxglyph_expanded: stockglyphty;
begin
 result:= stockglyphty(fboxids[tib_expanded]);
end;

procedure ttreeitemeditlist.setboxglyph_expanded(const avalue: stockglyphty);
begin
 if stockglyphty(fboxids[tib_expanded]) <> avalue then begin
  stockglyphty(fboxids[tib_expanded]):= avalue;
  if fowner <> nil then begin
   fowner.itemchanged(-1);
  end;
 end;
end;
{
function ttreeitemeditlist.getboxglyphactive_empty: stockglyphty;
begin
 result:= stockglyphty(fboxidsactive[tib_empty]);
end;

procedure ttreeitemeditlist.setboxglyphactive_empty(const avalue: stockglyphty);
begin
 if stockglyphty(fboxidsactive[tib_empty]) <> avalue then begin
  stockglyphty(fboxidsactive[tib_empty]):= avalue;
  if fowner <> nil then begin
   fowner.itemchanged(-1);
  end;
 end;
end;

function ttreeitemeditlist.getboxglyphactive_expand: stockglyphty;
begin
 result:= stockglyphty(fboxidsactive[tib_expand]);
end;

procedure ttreeitemeditlist.setboxglyphactive_expand(
              const avalue: stockglyphty);
begin
 if stockglyphty(fboxidsactive[tib_expand]) <> avalue then begin
  stockglyphty(fboxids[tib_expand]):= avalue;
  if fowner <> nil then begin
   fowner.itemchanged(-1);
  end;
 end;
end;

function ttreeitemeditlist.getboxglyphactive_expanded: stockglyphty;
begin
 result:= stockglyphty(fboxidsactive[tib_expanded]);
end;

procedure ttreeitemeditlist.setboxglyphactive_expanded(
              const avalue: stockglyphty);
begin
 if stockglyphty(fboxidsactive[tib_expanded]) <> avalue then begin
  stockglyphty(fboxidsactive[tib_expanded]):= avalue;
  if fowner <> nil then begin
   fowner.itemchanged(-1);
  end;
 end;
end;
}
function ttreeitemeditlist.getonstatreaditem: statreadtreeitemeventty;
begin
 result:= onstatreadtreeitem;
end;

procedure ttreeitemeditlist.setonstatreaditem(const avalue: statreadtreeitemeventty);
begin
 onstatreadtreeitem:= avalue;
end;

function ttreeitemeditlist.getonstatwriteitem: statwritetreeitemeventty;
begin
 result:= onstatwritetreeitem;
end;

procedure ttreeitemeditlist.setonstatwriteitem(const avalue: statwritetreeitemeventty);
begin
 onstatwritetreeitem:= avalue;
end;

procedure ttreeitemeditlist.createitem(out item: tlistitem);
begin
 item:= treelistedititemclassty(fitemclass).create(self);
end;

procedure ttreeitemeditlist.docreateobject(var instance: tobject);
begin
 if fchangingnode = nil then begin
  inherited;
  if (finsertparent <> nil) and
          (ttreelistitem1(instance).parent = finsertparent) then begin
   inc(finsertparentindex);
  end;
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
 if (index < 0) and (nochange = 0) and
  ((no_updatechildchecked in foptions) or
               (no_updatechildnotchecked in foptions) or
                         (no_updateparentnotchecked in foptions)) then begin
  inherited beginupdate; //no ils_subnodecountupdating
  try
   if (no_updatechildchecked in foptions) then begin
    updatechildcheckedtree();
   end;
   if (no_updatechildnotchecked in foptions) then begin
    updatechildnotcheckedtree();
   end;
   if (no_updateparentnotchecked in foptions) then begin
    updateparentnotcheckedtree();
   end;
  finally
   decupdate;
  end;
 end;
 inherited change(index);
end;

procedure ttreeitemeditlist.freedata(var data);
var
 int1,int2: integer;
 po1: ptreelistitem;
begin
 if not (ils_freelock in fitemstate) then begin
  if pointer(data) <> nil then begin
   with ttreelistitem1(data) do begin
    int2:= findex+1;
    if fowner <> nil then begin
     setowner(nil);
    end;
    if not (ils_subnodecountupdating in self.fitemstate) then begin
     int1:= int2;
     while int1 < self.fcount do begin
      po1:= ptreelistitem(getitempo(int1));
      if (po1^ <> nil) and
                   (ttreelistitem1(po1^).ftreelevel <= ftreelevel) then begin
       break; //next same level node
      end;
      po1^:= nil;
      inc(int1);
     end;
     self.fitemstate:= self.fitemstate + [ils_subnodecountupdating,
                                            ils_subnodedeleting];
     if (fparent <> nil) and
           ((ttreelistitem1(fparent).fowner = self) or
                                (fparent = frootnode)) then begin
      if dls_rowdeleting in self.fstate then begin
       inherited; //destroy node
      end;
     end
     else begin
    {
      if not updating and not(ils_destroying in self.fitemstate) then begin
       int1:= int1 - int2;
       if int1 > 0 then begin
        include(self.fitemstate,ils_freelock);
        try
         self.fowner.fgridintf.getcol.grid.deleterow(int2,int1);
        finally
         exclude(self.fitemstate,ils_freelock);
        end;
       end;
      end;
    }
      if not (ns1_nofreeroot in fstate1) then begin
       inherited; //free node
      end;
     end;
     self.fitemstate:= self.fitemstate - [ils_subnodecountupdating,
                                            ils_subnodedeleting];
    end;
   end;
  end;
 end
 else begin
  if pointer(data) <> nil then begin
   ttreelistitem1(data).findex:= -1;
  end;
 end;
end;

procedure ttreeitemeditlist.writestate(const writer; const name: msestring);
var
 int1,int2: integer;
 po1: ^ttreelistitem1;
begin
 dostatwrite(tstatwriter(writer),name);
 with tstatwriter(writer) do begin
  po1:= datapo;
  int2:= 0;
  for int1:= 0 to fcount - 1 do begin
   if po1^.ftreelevel = 0 then begin
    inc(int2);
   end;
   inc(po1);
  end;
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

procedure ttreeitemeditlist.readstate(const reader; const acount: integer;
                                        const aname: msestring);
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
 dostatread(tstatreader(reader),aname);
 with tstatreader(reader) do begin
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

procedure ttreeitemeditlist.readnode(const aname: msestring;
                       const reader: tstatreader; const anode: ttreelistitem);
begin
 if reader.beginlist(aname) then begin
  anode.expanded:= false; //remove existing bindings
  beginupdate;
  try
   anode.dostatread(reader);
   reader.endlist;
  finally
   endupdate;
  end;
 end;
end;

procedure ttreeitemeditlist.writenode(const aname: msestring;
               const writer: tstatwriter; const anode: ttreelistitem);
begin
 writer.beginlist(aname);
 anode.dostatwrite(writer);
 writer.endlist;
end;

procedure ttreeitemeditlist.updatenode(const aname: msestring;
               const filer: tstatfiler; const anode: ttreelistitem);
begin
 if filer.iswriter then begin
  writenode(aname,tstatwriter(filer),anode);
 end
 else begin
  readnode(aname,tstatreader(filer),anode);
 end;
end;

procedure ttreeitemeditlist.assign(const root: ttreelistedititem;
                                            const freeroot: boolean = true);
var
 ar1: treelistedititemarty;
 int1: integer;
begin
{$warnings off}
 with ttreelistitem1(root) do begin
{$warnings on}
  if fcount > 0 then begin
   setlength(ar1,fcount);
   for int1:= fcount-1 downto 0 do begin
    ar1[int1]:= ttreelistedititem(remove(int1));
   end;
   self.assign(ar1);
  end
  else begin
   self.clear;
  end;
 end;
 if freeroot then begin
  root.Free;
 end;
end;

procedure ttreeitemeditlist.assign(const aitems: treelistedititemarty);
var
 int1,int2: integer;
 ar1: listitemarty;

 procedure doadd(const aitem: ttreelistedititem);
 var
  int1: integer;
 begin
  additem(pointerarty(ar1),aitem,int2);
  if aitem.expanded then begin
   for int1:= 0 to aitem.count-1 do begin
    doadd(ttreelistedititem(aitem.fitems[int1]));
   end;
  end;
 end;

begin
 int2:= 0;
 setlength(ar1,length(aitems)); //min
 int2:= 0;
 for int1:= 0 to high(aitems) do begin
  doadd(aitems[int1]);
 end;
 setlength(ar1,int2);
 inherited assign(listitemarty(ar1));
end;

procedure ttreeitemeditlist.add(const anode: ttreelistedititem;
                       const freeroot: boolean = true); //adds toplevel node
var
 bo1: boolean;
begin
 if freeroot then begin
  exclude(anode.fstate1,ns1_nofreeroot);
 end
 else begin
  include(anode.fstate1,ns1_nofreeroot);
 end;
 bo1:= anode.expanded;
 anode.expanded:= false;
 inherited add(anode);
 anode.expanded:= bo1;
end;

procedure ttreeitemeditlist.insert(const aindex: integer;
                                    const anode: ttreelistedititem;
                                            const freeroot: boolean = true);
var
 int1: integer;
 rowbefore: integer;
 n1,n2: ttreelistitem;
// po1: ptreelistitem;
 bo1: boolean;
 grid1: tcustomgrid;
begin
// beginupdate();
// try
  if freeroot then begin
   exclude(anode.fstate1,ns1_nofreeroot);
  end
  else begin
   include(anode.fstate1,ns1_nofreeroot);
  end;
  int1:= aindex;
  n1:= nil;
  if int1 >= count then begin
   int1:= count;
   if int1 > 0 then begin
    n1:= items[int1-1];
    int1:= n1.parentindex+1;
   end
   else begin
    int1:= 0;
   end;
  end
  else begin
   if int1 < 0 then begin
    int1:= 0;
   end;
   if int1 < count then begin
    n1:= items[int1];
    int1:= n1.parentindex;
   end;
  end;
  n2:= nil;
  if n1 <> nil then begin
   n2:= n1.parent;
  end;
  if n2 = nil then begin
   n2:= frootnode;
  end;
  bo1:= anode.expanded;
  grid1:= nil;
  grid1:= fintf.getgrid();
  rowbefore:= -1;
  if grid1 <> nil then begin
   rowbefore:= grid1.row;
   if rowbefore <= aindex then begin
    grid1.row:= invalidaxis;
   end;
  end;
  anode.expanded:= false;
  if n2 <> nil then begin
   n2.insert(int1,anode);
   if n2.owner <> self then begin
    inherited insert(aindex,anode); //top level node
   end;
   if ns_showparentnotchecked in anode.fstate then begin
    if n2.checked and not (ns1_parentnotchecked in n2.state1) then begin
     exclude(anode.fstate1,ns1_parentnotchecked);
     anode.doupdateparentnotcheckedstate(false);
    end
    else begin
     include(anode.fstate1,ns1_parentnotchecked);
     anode.doupdateparentnotcheckedstate(true);
    end;
   end;
   if ns_showchildchecked in n2.state then begin
    anode.updatechildcheckedstate();
   end;
   if ns_showchildnotchecked in n2.state then begin
    anode.updatechildnotcheckedstate();
   end;
  end
  else begin
   inherited insert(aindex,anode); //top level node
  end;
  anode.expanded:= bo1;
  if grid1 <> nil then begin
   if (rowbefore <= aindex) and (rowbefore >= 0) then begin
    grid1.row:= rowbefore+anode.rowheight;
   end;
  end;
// finally
//  endupdate();
// end;
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

procedure ttreeitemeditlist.addchildren(const anode: ttreelistedititem);
                 //adds children as toplevel nodes
var
 int1: integer;
 po1: ptreelistedititematy;
 n1: ttreelistedititem;
begin
 beginupdate;
 try
  po1:= pointer(anode.fitems);
  for int1:= 0 to anode.count-1 do begin
   n1:= ttreelistedititem(po1^[int1]);
   n1.settreelevel(0);
   add(n1);
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
     include(fstate,des_updating);
     grid1:= fgridintf.getcol.grid;
     incupdate;
     try
      grid1.insertrow(finsertcount,int1);
     finally
      decupdate;
      exclude(fstate,des_updating);
     end;
     fintf.updateitemvalues(int2,int1);
     int1:= int2+int1;
     if int2 < fcount then begin
      po1:= datapo;
      if ils_subnodedeleting in fitemstate then begin
       for int1:= int1 to fcount - 1 do begin
        if po1^[int1] <> nil then begin
         po1^[int1].findex:= int1;
        end;
       end;
      end
      else begin
       for int1:= int1 to fcount - 1 do begin
        po1^[int1].findex:= int1;
       end;
      end;
     end;
    finally
     exclude(fstate,des_updating);
     fchangingnode:= nil;
    end;
   end;
  end;
 end;

var
 curnode: ttreelistedititem;
 newrow: integer;
 ind1: integer;
 po1: ptreelistitem;

 procedure scan(const anode: ttreelistedititem);
 var
  int1: integer;
 begin
  po1^:= anode;
  anode.findex:= ind1;
  if anode = curnode then begin
   newrow:= ind1;
  end;
  inc(po1);
  inc(ind1);
  if ns_expanded in anode.fstate then begin
   for int1:= 0 to anode.count-1 do begin
    scan(ttreelistedititem(anode.fitems[int1]));
   end;
  end;
 end;

var
 int1,int2: integer;
 bo1: boolean;
 po2: ptreelistedititematy;
 i1: int32;
 g1: tcustomgrid;

begin
 if ainfo.action = na_destroying then begin
  int2:= sender.index;
  tlistitem1(sender).setowner(nil);
  if not deleting {and (ttreelistitem(sender).parent = nil)} then begin
   with ttreelistitem(sender) do begin
    if expanded then begin
     int1:= treeheight+1;
    end
    else begin
     int1:= 1;
    end;
   end;
   incupdate;
   include(self.fitemstate,ils_freelock);
   with fowner.fgridintf.getcol.grid do begin
//    if (row >= int1) and (row < int2+int1) then begin
//     fowner.fvalue:= nil; //invalid
//    end;
    deleterow(int2,int1);
    po2:= datapo;
    for int1:= int2 to fcount-1 do begin
     po2^[int1].findex:= int1;
    end;
   end;
   exclude(self.fitemstate,ils_freelock);
   decupdate;
  end;
 end
 else begin
  if ainfo.action in [na_expand,na_collapse] then begin
{$warnings off}
   with tcustomgrid1(self.fowner.fgridintf.getcol.grid) do begin
{$warnings on}
    if not(docheckcellvalue and container.canclose) then begin
     ainfo.action:= na_none;
     exit;
    end;
   end;
  end;
  inherited;
  case ainfo.action of
   na_valuechange: begin
    if not updating and (ttreeitemedit(fowner).fieldedit <> nil) then begin
     int1:= sender.index;
     ttreeitemedit(fowner).ffieldedit[int1].valuetext:= fowner[int1].valuetext;
    end;
   end;
   na_countchange: begin
    if not updating then begin
     with ttreelistitem1(sender) do begin
      if ns_expanded in fstate then begin
       g1:= nil;
       if self.fowner <> nil then begin
        g1:= self.fowner.grid;
       end;
       if g1 <> nil then begin
        i1:= g1.row;
       end;
       int1:= findex+1;
       if (findex < self.fcount-1)  then begin
        int2:= ainfo.treeheightbefore;
        if ils_subnodedeleting in fitemstate then begin
         dec(int2);
        end;
        if int2 > 0 then begin
         include(self.fitemstate,ils_freelock);
        {$warnings off}
         with tcustomgrid1(self.fowner.fgridintf.getcol.grid) do begin
        {$warnings on}
          try
           bo1:= gs1_autoappendlock in fstate1;
           include(fstate1,gs1_autoappendlock);
           if (g1 <> nil) and
                     (g1.row >= int1) and (g1.row > int1 + int2) then begin
            g1.row:= invalidaxis;
           end;
           deleterow(int1,int2);
          finally
           if not bo1 then begin
            exclude(fstate1,gs1_autoappendlock);
           end;
           exclude(self.fitemstate,ils_freelock);
          end;
         end;
        end;
       end;
       expand;
       if g1 <> nil then begin
        g1.row:= i1;
       end;
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
     with ttreeitemedit(fowner) do begin
      if fvalue = sender then begin
       expandedchanged(true);
      end;
     end;
    end
    else begin
     include(fitemstate,ils_subnodecountinvalid);
    end;
   end;
   na_collapse: begin
    if not (ils_subnodecountupdating in fitemstate) then begin
     with ttreeitemedit(fowner) do begin
      include(fitemstate,ils_subnodecountupdating);
      fgridintf.getcol.grid.deleterow(sender.index+1,
                                      ttreelistitem(sender).treeheight);
      exclude(fitemstate,ils_subnodecountupdating);
      if fvalue = sender then begin
       expandedchanged(false);
      end;
     end;
    end
    else begin
     include(fitemstate,ils_subnodecountinvalid);
    end;
   end;
   na_aftersort: begin
    if not updating and ttreelistedititem(sender).rootexpanded then begin
     curnode:= ttreelistedititem(ttreeitemedit(fowner).item);
     newrow:= -1;
     po1:= datapo;
     ind1:= ttreelistedititem(sender).findex;
     int2:= ind1+1;
     inc(po1,ind1);
     scan(ttreelistedititem(sender));
     fintf.updateitemvalues(int2,ind1-int2);
     if newrow >= 0 then begin
{$warnings off}
     with tcustomgrid1(fowner.fgridintf.getcol.grid) do begin
{$warnings on}
       ffocusedcell.row:= newrow;
       layoutchanged;
      end;
     end;
     change(-1);
    end;
   end;
   else; // Case statment added to make compiler happy...
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
 int2: integer;
 po1,pe: ptreelistitem;
begin
 result:= nil;
 int2:= 0;
 po1:= datapo;
 pe:= po1 + count;
 while po1 < pe do begin
  if (po1^.parent = nil) or (po1^.parent.owner <> self) then begin
   ttreelistitem1(po1^).internalgetnodes(result,int2,must,
                                                      mustnot,amode,true);
  end;
  inc(po1);
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
 po1,pe: ptreelistedititem;
begin
 beginupdate;
 try
  po1:= datapo;
  pe:= po1 + count;
  while po1 < pe do begin
   if po1^ <> nil then begin
    with po1^ do begin
     if ftreelevel = 0 then begin
      updatechildcheckedtree;
     end;
    end;
   end;
   inc(po1);
  end;
 finally
  endupdate;
 end;
end;

procedure ttreeitemeditlist.updatechildnotcheckedtree;
var
 po1,pe: ptreelistedititem;
begin
 beginupdate;
 try
  po1:= datapo;
  pe:= po1 + count;
  while po1 < pe do begin
   if po1^ <> nil then begin
    with po1^ do begin
     if ftreelevel = 0 then begin
      updatechildnotcheckedtree;
     end;
    end;
   end;
   inc(po1);
  end;
 finally
  endupdate;
 end;
end;

procedure ttreeitemeditlist.updateparentnotcheckedtree;
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
     updateparentnotcheckedtree;
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

function ttreeitemeditlist.compare(const l,r): integer;
var
 pathl,pathr: treelistitemarty;
 int1,int2,int3: integer;
begin
 pathl:= ttreelistitem(l).rootpath;
 pathr:= ttreelistitem(r).rootpath;
 int1:= high(pathl);
 if int1 > high(pathr) then begin
  int1:= high(pathr);
 end;
 int3:= -1;
 for int2:= 0 to int1 do begin
  if pathl[int2] <> pathr[int2] then begin
   int3:= int2;
   break;
  end;
 end;
 if int3 >= 0 then begin
  result:= inherited compare(pathl[int3],pathr[int3]);
 end
 else begin
  result:= length(pathl) - length(pathr);
  if fgridsortdescend then begin
   result:= -result;
  end;
 end;
end;
{
function ttreeitemeditlist.compare(const l,r): integer;
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
  result:= inherited compare(pathl[int3],pathr[int3]);
 end
 else begin
  result:= length(pathl) - length(pathr);
 end;
end;
}
procedure ttreeitemeditlist.statreaditem(const reader: tstatreader;
                 var aitem: tlistitem);
begin
 statreadtreeitem(reader,nil,ttreelistitem(aitem));
end;

procedure ttreeitemeditlist.statwriteitem(const writer: tstatwriter;
               const aitem: tlistitem);
begin
 statwritetreeitem(writer,ttreelistitem(aitem));
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
// rect1: rectty;
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
  else; // Case statment added to make compiler happy...
 end;
end;

procedure ttreeitemeditlist.afterdragevent(var ainfo: draginfoty;
               const arow: integer; var processed: boolean);
begin
 //dummy
end;

procedure ttreeitemeditlist.moverow(const source: integer; const dest: integer);
var
 so,de,si: ttreelistitem1;
 int1,int2,int3: integer;
 po1: ppointeraty;

begin
 if source <> dest then begin
 {$warnings off}
  so:= ttreelistitem1(items[source]);
  de:= ttreelistitem1(items[dest]);
  si:= ttreelistitem1(de.findsibling(so));
 {$warnings on}
  if si <> nil then begin
   int1:= source;
   if (source < dest) then begin
    if si = so then begin
     int3:= si.findex+1;
     if si.expanded then begin
      int3:= int3 + si.treeheight;
     end;
     if int3 < fcount then begin
     {$warnings off}
      si:= ttreelistitem1(items[int3]); //next equal or higher level
     {$warnings on}
      if si.parent <> so.parent then begin
       si:= so; //invalid
      end;
     end;
    end;
   end;
   if si <> so then begin
    if si.fparent <> nil then begin
     ttreelistitem1(si.parent).internalmove(so.parentindex,si.parentindex);
    end;
    int2:= si.findex;
    int3:= 1;
    if so.expanded then begin
     int3:= int3 + so.treeheight;
     if source < dest then begin
      int2:= int2 - so.treeheight;
     end;
    end;
    if si.expanded and (source < dest) then begin
     int2:= int2 + si.treeheight;
    end;
    fowner.fgridintf.getcol.grid.moverow(int1,int2,int3);
    po1:= datapo;
    dec(int3);
    if int2 < int1 then begin
     for int1:= int2 to int1 + int3 do begin
      ttreelistedititem(po1^[int1]).findex:= int1;
     end;
    end
    else begin
     for int1:= int1 to int2 + int3 do begin
      ttreelistedititem(po1^[int1]).findex:= int1;
     end;
    end;
   end;
  end;
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
 itemclasschanged();
end;

function ttreeitemeditlist.getexpandedstate: expandedinfoarty;
var
 grid: tcustomgrid;
 po1: ptreelistitematy;
 int1,int2: integer;
begin
 result:= nil;
 grid:= fintf.getgrid;
 if grid <> nil then begin
  setlength(result,count+1); //max
  po1:= datapo;
  if grid.row >= 0 then begin
   result[0].path:= po1^[grid.row].rootcaptions(self); //focused row
  end;
  int2:= 1;
  for int1:= 0 to count-1 do begin
   if po1^[int1].expanded then begin
    result[int2].path:= po1^[int1].rootcaptions(self);
    inc(int2);
   end;
  end;
  setlength(result,int2);
 end;
end;

procedure ttreeitemeditlist.setexpandedstate(const avalue: expandedinfoarty);
var
 ar1: treelistedititemarty;

 function find(const acaption: msestring): ttreelistedititem;
 var
  int1: integer;
 begin
  result:= nil;
  for int1:= 0 to high(ar1) do begin
   if ar1[int1].caption = acaption then begin
    result:= ar1[int1];
    break;
   end;
  end;
 end; //find

var
 grid: tcustomgrid;
 n1: ttreelistedititem;
 int1,int2: integer;
begin
 grid:= fintf.getgrid;
 if grid <> nil then begin
  grid.row:= invalidaxis;
  if avalue <> nil then begin
   ar1:= toplevelnodes;
   for int1:= 1 to high(avalue) do begin
    n1:= find(avalue[int1].path[0]);
    if n1 <> nil then begin
     n1.expanded:= true;
     for int2:= 1 to high(avalue[int1].path) do begin
      n1:= ttreelistedititem(n1.finditembycaption(avalue[int1].path[int2]));
      if n1 = nil then begin
       break;
      end;
      n1.expanded:= true;
     end;
    end;
   end;
   if (ar1 <> nil) and (avalue[0].path <> nil) then begin
    n1:= find(avalue[0].path[0]); //restore focused row
    if n1 <> nil then begin
     int1:= n1.findex;
     for int2:= 1 to high(avalue[0].path) do begin
      n1:= ttreelistedititem(n1.finditembycaption(avalue[0].path[int2]));
      if n1 = nil then begin
       break;
      end;
      int1:= n1.findex;
     end;
     grid.row:= int1;
    end;
   end;
  end;
 end;
end;

procedure ttreeitemeditlist.setrootnode(const avalue: ttreelistedititem);
begin
 beginupdate();
 try
  clear();
  frootnode:= avalue;
  if frootnode <> nil then begin
   frootnode.ftreelevel:= -1;
   addchildren(frootnode);
  end;
 finally
  endupdate();
 end;
end;

procedure ttreeitemeditlist.deleteitems(index: integer; acount: integer);
var
 bo1: boolean;
begin
 bo1:= dls_rowdeleting in fstate;
 include(fstate,dls_rowdeleting);
 try
  inherited;
 finally
  if not bo1 then begin
   exclude(fstate,dls_rowdeleting);
  end;
 end;
end;

procedure ttreeitemeditlist.insertitems(index: integer; acount: integer);
var
 int1: integer;
begin
 int1:= index;
 if int1 >= count then begin
  int1:= count - 1;
 end;
 if int1 >= 0 then begin
  with items[int1] do begin
   finsertparent:= ttreelistedititem(parent);
   finsertparentindex:= parentindex;
  end;
 end
 else begin
  finsertparent:= rootnode;
  finsertparentindex:= 0;
 end;
 try
  inherited;
 finally
  finsertparent:= nil;
  finsertparentindex:= -1;
 end;
end;

procedure ttreeitemeditlist.delete(const aindex: integer);
begin
 ttreelistedititem(items[aindex]).expanded:= false;
 fintf.getgrid.deleterow(aindex);
// deleteitems(aindex,1);
end;

{ trecordfielditem }

function trecordfielditem.getvalueitem: tlistitem;
begin
 if fvalueitem <> nil then begin
  result:= fvalueitem;
 end
 else begin
  result:= self;
 end;
end;

procedure trecordfielditem.setvalueitem(const avalue: tlistitem);
begin
 fvalueitem:= avalue;
end;

{ trecordfielditemeditlist }

class function trecordfielditemeditlist.defaultitemclass: listedititemclassty;
begin
 result:= trecordfielditem;
end;

{ trecordfieldedit }

constructor trecordfieldedit.create(aowner: tcomponent);
begin
 if fitemlist = nil then begin
  fitemlist:=  trecordfielditemeditlist.create(iitemlist(self),self);
 end;
 inherited;
end;

function trecordfieldedit.getoptionsedit: optionseditty;
begin
 result:= inherited getoptionsedit;
 if not (csdesigning in componentstate) and (fitemedit <> nil) and
                 not fitemedit.valuecanedit then begin
  include(result,oe_readonly);
 end;
end;

procedure trecordfieldedit.storevalue(var avalue: msestring);
begin
 inherited;
 if fitemedit <> nil then begin
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

function ttreeitemedit.getdatalistclass: datalistclassty;
begin
 result:= ttreeitemeditlist;
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
{
function ttreeitemedit.getitemclass: listitemclassty;
begin
 result:= ttreelistedititem;
end;
}
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

procedure ttreeitemedit.doupdatelayout(const nocolinvalidate: boolean);
begin
 inherited;
// flayoutinfofocused.drawoptions:= ttreeitemeditlist(fitemlist).foptionsdraw;
// flayoutinfofocused.colorline:= ttreeitemeditlist(fitemlist).fcolorline;
 flayoutinfofocused.boxids:= ttreeitemeditlist(fitemlist).fboxids;
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

function ttreeitemedit.item: ttreelistedititem;
begin
 result:= ttreelistedititem(fvalue);
end;

function ttreeitemedit.getitems(const index: integer): ttreelistedititem;
begin
 result:= ttreelistedititem(fitemlist[index]);
end;

procedure ttreeitemedit.setitems(const index: integer;
  const Value: ttreelistedititem);
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

function ttreeitemedit.getifiitemlink: tifitreeitemlinkcomp;
begin
 result:= tifitreeitemlinkcomp(getifilink1());
end;

procedure ttreeitemedit.setifiitemlink(const avalue: tifitreeitemlinkcomp);
begin
 setifilink1(avalue);
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
 po1: ptreelistedititem;
begin
 if ffieldedit <> nil then begin
  po1:= fitemlist.getitempo(index);
  for int1:= index to index + count - 1 do begin
   with tlistitem1(ffieldedit[int1]) do begin
    valuetext:= po1^.valuetext;
    setvalueitem(po1^);
   end;
   inc(po1);
  end;
 end;
 inherited;
end;

procedure ttreeitemedit.updateitemvalues();
begin
 inherited;
end;

procedure ttreeitemedit.updateparentvalues(const index: integer);
var
 n1: ttreelistitem;
begin
 n1:= ttreelistitem(fitemlist.items[index]).parent;
 while (n1 <> nil) and (n1.owner = fitemlist) do begin
  updateitemvalues(n1.index,1);
  n1:= n1.parent;
 end;
end;

procedure ttreeitemedit.dokeydown(var info: keyeventinfoty);
var
 int1,int2: integer;
 equallevelindex,atreelevel: integer;
 cellbefore: gridcoordty;

begin
 doonkeydown(info);
 with info do begin
  if not (es_child in eventstate) and (fgridintf <> nil) and
                not (es_processed in eventstate) and (fvalue <> nil) then begin
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
         if (fstate * [ns_subitems,ns_drawemptyexpand] <> []) or
                         (no_drawemptyexpand in fitemlist.foptions) then begin
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
         if (fparent <> nil) and (fparent.owner = fitemlist) then begin
          row:= fparent.index;
         end;
//         int1:= fitemlist.indexof(parent);
//         if int1 >= 0 then begin
//          row:= int1;
//         end;
        end;
       end;
       else; // Case statment added to make compiler happy...
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
       else; // Case statment added to make compiler happy...
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
          ttreelistitem1(fparent).internalswap(int1,int1-1);
          moverow(row,row-1,1);
         end;
        end
        else begin //key_down
         if (int1 < fparent.count-1) and
              (itemlist[row].parent = itemlist[row+1].parent) and
               checkrowmove(row,row+1) then begin
          ttreelistitem1(fparent).internalswap(int1,int1+1);
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
    pa.insert(de.parentindex,item);
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
 if (info.button = mb_left) and (info.shiftstate*keyshiftstatesmask = []) and
  ([teo_enteronimageclick,teo_enterondoubleclick]*foptions <> []) then begin
  cellzone:= cz_none;
  with ttreelistedititem(fvalue) do begin
   updatecellzone(info.pos,cellzone);
   if (cellzone = cz_image) and (teo_enteronimageclick in foptions) or
      (teo_enterondoubleclick in foptions) and
                   (ss_double in info.shiftstate) then begin
    expanded:= not expanded;
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

function ttreeitemedit.selecteditems: treelistedititemarty;
begin
 result:= treelistedititemarty(inherited selecteditems);
end;

procedure ttreeitemedit.comparerow(const lindex: integer;
               const rindex: integer; var aresult: integer);
var
 pol,por: ptreelistitem;
 col1: tdatacol;
begin
 if fitemlist <> nil then begin
  col1:= fgridintf.getcol;
  pol:= fitemlist.datapo;
  por:= @ppointeraty(pol)[rindex];
  pol:= @ppointeraty(pol)[lindex];
  if (col1.grid.datacols.sortcol = col1.index) or
           (pol^.count = 0) and (por^.count = 0) and
                             (pol^.parent = por^.parent) then begin
   aresult:= col1.grid.datacols.sortfunc(lindex,rindex);
  end;
 end;
end;
{
procedure ttreeitemedit.updateitemvalues;
begin
 inherited;
end;
}
{
procedure ttreeitemedit.drawcell(const canvas: tcanvas);
begin
 with cellinfoty(canvas.drawinfopo^) do begin
  flayoutinfocell.islast:= (cell.row >= grid.rowhigh) or
          (fitemlist <> nil) and
          (ptreelistitem(datapo)^.treelevel = 0) or
          (ptreelistitem(datapo)^.treelevel >
                   (ptreelistitem(datapo)+1)^.treelevel);
 end;
 flayoutinfofocused.islast:= flayoutinfocell.islast;
 inherited;
end;
}
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

{ tdirtreenode }

procedure tdirtreenode.loaddirtree(const apath: filenamety);

 procedure doload(const anode: tdirtreenode; const apath: filenamety);
 var
  ar1: filenamearty;
  int1: integer;
 begin
  ar1:= searchfiles('*',apath,[fa_dir]);
  if ar1 <> nil then begin
   checkfiles(ar1);
  end;
  with anode do begin
   add(length(ar1));
   for int1:= 0 to high(ar1) do begin
    fitems[int1].caption:= filename(ar1[int1]);
    doload(tdirtreenode(fitems[int1]),ar1[int1]);
   end;
  end;
 end;

begin
 beginupdate;
 clear;
 try
  doload(self,apath);
 finally
  endupdate;
 end;
end;

procedure tdirtreenode.checkfiles(var afiles: filenamearty);
begin
 //dummy
end;

function tdirtreenode.path(const astart: integer = 0): filenamety;
var
 ar1: treelistitemarty;
 int1: integer;
begin
 result:= '';
 ar1:= rootpath;
 if high(ar1) >= astart then begin
  result:= ar1[astart].caption;
  for int1:= astart+1 to high(ar1) do begin
   result:= result+'/'+ar1[int1].caption;
  end;
  if (result <> '') and (result <> '/') then begin
   result:= result + '/';
  end;
 end;
end;

function createtitemeditlist(const aowner: twidgetcol): tdatalist;
begin
 result:= titemeditlist.create;
end;

function createtrecordfielditemeditlist(const aowner: twidgetcol): tdatalist;
begin
 result:= trecordfielditemeditlist.create;
end;

function createttreeitemeditlist(const aowner: twidgetcol): tdatalist;
begin
 result:= ttreeitemeditlist.create;
end;

{ trichlistedititem }

function trichlistedititem.getrichcaption: richstringty;
begin
 result.text:= fcaption;
 result.format:= fformat;
end;

procedure trichlistedititem.setrichcaption(const avalue: richstringty);
begin
 fformat:= avalue.format;
 caption:= avalue.text;
end;

procedure trichlistedititem.updatecaption(const acanvas: tcanvas;
             var alayoutinfo: listitemlayoutinfoty; var ainfo: drawtextinfoty);
begin
 inherited;
 ainfo.text.format:= fformat;
end;

procedure trichlistedititem.setcaptionformat(const avalue: formatinfoarty);
begin
 fformat:= avalue;
 change;
end;

{ titemclientcontroller }

function titemclientcontroller.getitemlist(): titemeditlist;
begin
 result:= nil;
 if fitemedit <> nil then begin
  result:= tcustomitemedit(fitemedit).itemlist;
 end;
end;

function titemclientcontroller.getitemedit: titemedit;
begin
 pointer(result):= fitemedit;
end;

function titemclientcontroller.createdatalist: tdatalist;
begin
 result:= nil;
end;

function titemclientcontroller.getlistdatatypes: listdatatypesty;
begin
 result:= [];
end;

function titemclientcontroller.getlistitem(): tlistedititem;
begin
 result:= nil;
 if fitemedit <> nil then begin
  result:= tcustomitemedit(fitemedit).item;
 end;
end;

procedure titemclientcontroller.linkset(const alink: iificlient);
var
 obj1: tobject;
begin
 inherited;
 obj1:= alink.getinstance;
 if obj1 is tcustomitemedit then begin
  setlinkedvar(tcustomitemedit(obj1),tmsecomponent(fitemedit));
 end;
end;

{ ttreeitemclientcontroller }

function ttreeitemclientcontroller.getlistitem(): ttreelistedititem;
begin
 pointer(result):= inherited getlistitem();
end;

function ttreeitemclientcontroller.getitemlist(): ttreeitemeditlist;
begin
 pointer(result):= inherited getitemlist();
end;

function ttreeitemclientcontroller.getitemedit(): ttreeitemedit;
begin
 pointer(result):= fitemedit;
end;

{ tifiitemlinkcomp }

function tifiitemlinkcomp.getcontroller: titemclientcontroller;
begin
 result:= titemclientcontroller(inherited controller);
end;

procedure tifiitemlinkcomp.setcontroller(const avalue: titemclientcontroller);
begin
 inherited setcontroller(avalue);
end;

function tifiitemlinkcomp.getcontrollerclass: customificlientcontrollerclassty;
begin
 result:= titemclientcontroller;
end;

{ tifitreeitemlinkcomp }

function tifitreeitemlinkcomp.getcontroller: ttreeitemclientcontroller;
begin
 result:= ttreeitemclientcontroller(inherited controller);
end;

procedure tifitreeitemlinkcomp.setcontroller(
                                  const avalue: ttreeitemclientcontroller);
begin
 inherited setcontroller(avalue);
end;

function tifitreeitemlinkcomp.getcontrollerclass:
                                     customificlientcontrollerclassty;
begin
 result:= ttreeitemclientcontroller;
end;

initialization
 registergriddatalistclass(titemeditlist.classname,
                                      @createtitemeditlist);
 registergriddatalistclass(trecordfielditemeditlist.classname,
                                      @createtrecordfielditemeditlist);
 registergriddatalistclass(ttreeitemeditlist.classname,
                                      @createttreeitemeditlist);
end.
