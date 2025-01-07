{ MSEgui Copyright (c) 1999-2016 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}

{ msefiledialogx by fredvs 2020 - 2022 }

unit msefiledialogx;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface

{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
 {$if fpc_fullversion >= 030300}
  {$warn 6060 off}
  {$warn 6018 off}
  {$endif}
{$endif}

uses
 SysUtils,Classes,{$ifdef unix}baseunix,{$endif}Math,mclasses,mseclasses,mseglob,mseguiglob,
 msekeyboard,mseforms,msewidgets, msegrids,mselistbrowser,mseedit,msesimplewidgets,
 msedataedits,msedialog,msetypes,msestrings,msesystypes,msesys,msedispwidgets,msedatalist,
 msestat,msestatfile,msebitmap,msedatanodes,msefileutils,msedropdownlist,mseevent,
 {$ifdef BGRABITMAP_USE_MSEGUI}BGRABitmap,BGRADefaultBitmap,BGRABitmapTypes,{$endif}
 msegraphedits,mseeditglob,msesplitter,msemenus,msegridsglob,msegraphics,
 msegraphutils,msedirtree,msewidgetgrid,mseact,mseapplication,msegui,mseificomp,
 mseificompglob,mseifiglob,msestream,msemenuwidgets,msescrollbar,msedragglob,
 mserichstring,msetimer,mseformatbmpicoread,mseformatjpgread,mseformatpngread,
 mseformatpnmread,mseformattgaread,mseformatxpmread,mseimage;

const
  defaultlistviewoptionsfile = defaultlistviewoptions + [lvo_readonly];

type
  tfilelistitem = class(tlistitem)
  private
  protected
  public
   constructor create(const aowner: tcustomitemlist); override;
  end;

  pfilelistitem = ^tfilelistitem;

  tfileitemlist = class(titemviewlist)
  protected
   procedure createitem(out item: tlistitem); override;
  end;

  getfileiconeventty = procedure(const Sender: TObject; const ainfo: fileinfoty; var imagelist: timagelist; var imagenr: integer) of object;

  tfilelistviewx = class(tlistview)
  private
    ffilelist: tfiledatalist;
    foptionsfile: filelistviewoptionsty;
    fmaskar: filenamearty;
    fdirectory: filenamety;
    ffilecount: integer;
    fincludeattrib, fexcludeattrib: fileattributesty;
    fonlistread: notifyeventty;
    ffocusmoved: Boolean;
    fongetfileicon: getfileiconeventty;
    foncheckfile: checkfileeventty;
    procedure filelistchanged(const Sender: TObject);
    procedure setfilelist(const Value: tfiledatalist);
    function getpath: msestring;
    procedure setpath(const Value: msestring);
    procedure setdirectory(const Value: msestring);
    function getmask: filenamety;
    procedure setmask(const Value: filenamety);
    function getselectednames: filenamearty;
    procedure setselectednames(const avalue: filenamearty);
    function getchecksubdir: Boolean;
    procedure setchecksubdir(const avalue: Boolean);
    procedure setoptionsfile(const avalue: filelistviewoptionsty);
    procedure checkcasesensitive;
  protected
    foptionsdir: dirstreamoptionsty;
    fcaseinsensitive: Boolean;
    //   procedure setoptions(const Value: listviewoptionsty); override;
    procedure docellevent(var info: celleventinfoty); override;
  public

    constructor Create(aowner: TComponent); override;
    destructor Destroy; override;
    procedure readlist;
    procedure updir;
    function filecount: integer;
    property directory: filenamety read fdirectory write setdirectory;
    property includeattrib: fileattributesty read fincludeattrib write fincludeattrib default [fa_all];
    property excludeattrib: fileattributesty read fexcludeattrib write fexcludeattrib default [fa_hidden];
    property maskar: filenamearty read fmaskar write fmaskar; //nil -> all
////////////////////////////////////
//// WHY MOVED HERE ????
////????    property mask: filenamety read getmask write setmask;     //'' -> all
////////////////////////////////////
    property path: filenamety read getpath write setpath;
    //calls readlist
    property selectednames: filenamearty read getselectednames write setselectednames;
    property checksubdir: Boolean read getchecksubdir write setchecksubdir;
  published
    property mask: filenamety read getmask write setmask;     //'' -> all
    property options default defaultlistviewoptionsfile;
    property optionsfile: filelistviewoptionsty read foptionsfile write setoptionsfile default defaultfilelistviewoptions;
    property filelist: tfiledatalist read ffilelist write setfilelist;
    property onlistread: notifyeventty read fonlistread write fonlistread;
    property ongetfileicon: getfileiconeventty read fongetfileicon write fongetfileicon;
    property oncheckfile: checkfileeventty read foncheckfile write foncheckfile;
  end;

const
  defaulthistorymaxcount = 50;

type
  filedialogxoptionty  = (fdo_filtercasesensitive,    //flvo_maskcasesensitive
    fdo_filtercaseinsensitive,  //flvo_maskcaseinsensitive
    fdo_save,
    fdo_dispname, fdo_dispnoext, fdo_sysfilename, fdo_params,
    fdo_directory, fdo_file,
    fdo_absolute, fdo_relative, fdo_lastdirrelative,
    fdo_basedirrelative,
    fdo_quotesingle,
    fdo_link, //links lastdir of controllers with same group
    fdo_checkexist, fdo_acceptempty, fdo_single,
    fdo_chdir, fdo_savelastdir,
    fdo_checksubdir);
  filedialogoptionsty = set of filedialogxoptionty;

const
  defaultfiledialogoptions = [fdo_savelastdir];

type
  filedialogkindty = (fdk_none,fdk_open,fdk_save,fdk_new);

  tfiledialogxfo = class;
  tfiledialogxcontroller = class;

  filedialogbeforeexecuteeventty = procedure(const Sender: tfiledialogxcontroller; var dialogkind: filedialogkindty; var aresult: modalresultty) of object;
  filedialogafterexecuteeventty  = procedure(const Sender: tfiledialogxcontroller; var aresult: modalresultty) of object;

  tfiledialogxcontroller = class(tlinkedpersistent)
  private
    fowner: tmsecomponent;
    fgroup: integer;
{-}//    ffontname: msestring;
{-}//    ffontheight: integer;
{-}//    fsplitterplaces: integer;
{-}//    fsplitterlateral: integer;
{-}//    ffontcolor: colorty;
{-}//    fbackcolor: colorty;
    fonchange: proceventty;
    ffilenames: filenamearty;
    ffilterlist: tdoublemsestringdatalist;
    ffilter: filenamety;
{-}//    fnopanel: Boolean;
{-}//    ficon: tmaskedbitmap;
{-}//    fcompact: Boolean;
{-}//    fshowoptions: Boolean;
{-}//    fhidehistory: Boolean;
{-}//    fhideicons: Boolean;
{-}//    ffilenamescust: filenamearty;
{-}//    fshowhidden: Boolean;
    ffilterindex: integer;
{+}//    fcolwidth: integer;
{-}//    fcolnamewidth: integer;
{-}//    fcolsizewidth: integer;
{-}//    fcolextwidth: integer;
{-}//    fcoldatewidth: integer;
////////////////////////////////////
//   fwindowrect: rectty;
////////////////////////////////////
    fhistorymaxcount: integer;
    fhistory: msestringarty;
    fcaptionopen: msestring;
    fcaptionsave: msestring;
    fcaptionnew: msestring;
{-??}    fcaptiondir: msestring;
    finclude: fileattributesty;
    fexclude: fileattributesty;
    fonbeforeexecute: filedialogbeforeexecuteeventty;
    fonafterexecute: filedialogafterexecuteeventty;
    fongetfilename: setstringeventty;
    fongetfileicon: getfileiconeventty;
    foncheckfile: checkfileeventty;
    fimagelist: timagelist;
    fparams: msestring;
{-}//    procedure seticon(const avalue: tmaskedbitmap);
    procedure setfilterlist(const Value: tdoublemsestringdatalist);
    procedure sethistorymaxcount(const Value: integer);
    function getfilename: filenamety;
    procedure setfilename(const avalue: filenamety);
    procedure dochange;
    procedure setdefaultext(const avalue: filenamety);
    procedure setoptions(Value: filedialogoptionsty);
    procedure checklink;
    procedure setlastdir(const avalue: filenamety);
    procedure setimagelist(const avalue: timagelist);
    function getsysfilename: filenamety;
  protected
    flastdir: filenamety;
    fbasedir: filenamety;
    fdefaultext: filenamety;
    foptions: filedialogoptionsty;
////////////////////////////////////
   fwindowrect: rectty;
////////////////////////////////////
  public
////////////////////////////////////
   DialogPlacement: dialogposty;
////////////////////////////////////

    constructor Create(const aowner: tmsecomponent = nil; const onchange: proceventty = nil);
      reintroduce;

    destructor Destroy; override;
    procedure readstatvalue(const reader: tstatreader);
    procedure readstatstate(const reader: tstatreader);
    procedure readstatoptions(const reader: tstatreader);
    procedure writestatvalue(const writer: tstatwriter);
    procedure writestatstate(const writer: tstatwriter);
    procedure writestatoptions(const writer: tstatwriter);
    function actcaption(const dialogkind: filedialogkindty): msestring;

//    function Execute (dialogkind: filedialogkindty = fdk_none): modalresultty; overload;
//    //fdk_none -> use options fdo_save
//////////////////////////////////// - 1p
    function Execute (dialogkind: filedialogkindty = fdk_none;
                      providedform: tfiledialogxfo = nil): modalresultty; overload;
//////////////////////////////////// - 3p
//    function Execute (dialogkind: filedialogkindty; const acaption: msestring; aoptions: filedialogoptionsty): modalresultty; overload;
////////////////////////////////////
    function Execute (dialogkind: filedialogkindty; const acaption: msestring; aoptions: filedialogoptionsty;
                      providedform: tfiledialogxfo = nil): modalresultty; overload;
//////////////////////////////////// - 2p
//    function Execute (const dialogkind: filedialogkindty; const acaption: msestring): modalresultty; overload;
////////////////////////////////////
    function Execute (const dialogkind: filedialogkindty; const acaption: msestring;
                      providedform: tfiledialogxfo = nil): modalresultty; overload;
//////////////////////////////////// - 2p
//    function Execute (const dialogkind: filedialogkindty; const aoptions: filedialogoptionsty): modalresultty; overload;
////////////////////////////////////
    function Execute (const dialogkind: filedialogkindty; const aoptions: filedialogoptionsty;
                      providedform: tfiledialogxfo = nil): modalresultty; overload;
//////////////////////////////////// - 2p
//    function Execute (var avalue: filenamety; dialogkind: filedialogkindty = fdk_none): Boolean; overload;
////////////////////////////////////
    function Execute (var avalue: filenamety; dialogkind: filedialogkindty = fdk_none;
                      providedform: tfiledialogxfo = nil): Boolean; overload;
//////////////////////////////////// - 3p
//    function Execute (var avalue: filenamety; const dialogkind: filedialogkindty; const acaption: msestring): Boolean; overload;
////////////////////////////////////
    function Execute (var avalue: filenamety; const dialogkind: filedialogkindty; const acaption: msestring;
                      providedform: tfiledialogxfo = nil): Boolean; overload;
//////////////////////////////////// - 4p
//    function Execute (var avalue: filenamety; const dialogkind: filedialogkindty; const acaption: msestring; aoptions: filedialogoptionsty): Boolean; overload;
////////////////////////////////////
    function Execute (var avalue: filenamety; const dialogkind: filedialogkindty; const acaption: msestring; aoptions: filedialogoptionsty;
                      providedform: tfiledialogxfo = nil): Boolean; overload;
////////////////////////////////////
    function canoverwrite(): Boolean;
    //true if current filename is allowed to write
    procedure Clear;
    procedure componentevent(const event: tcomponentevent);
    property history: msestringarty read fhistory write fhistory;
    property filenames: filenamearty read ffilenames write ffilenames;
{-}//    property filenamescust: filenamearty read ffilenamescust write ffilenamescust;
    property syscommandline: filenamety read getsysfilename; deprecated;
    property sysfilename: filenamety read getsysfilename;
    property params: msestring read fparams;
  published
    property filename: filenamety read getfilename write setfilename;
    property lastdir: filenamety read flastdir write setlastdir;
    property basedir: filenamety read fbasedir write fbasedir;
{-}//    property fontheight: integer read ffontheight write ffontheight;
{-}//    property fontname: msestring read ffontname write ffontname;
{-}//    property fontcolor: colorty read ffontcolor write ffontcolor;
{-}//    property backcolor: colorty read fbackcolor write fbackcolor;
    property filter: filenamety read ffilter write ffilter;
{-}//    property nopanel: Boolean read fnopanel write fnopanel;
{-}//    property icon: tmaskedbitmap read ficon write seticon;
{-}//    property compact: Boolean read fcompact write fcompact;
{-}//    property showoptions: Boolean read fshowoptions write fshowoptions;
{-}//    property hidehistory: Boolean read fhidehistory write fhidehistory;
{-}//    property hideicons: Boolean read fhideicons write fhideicons;
{-}//    property showhidden: Boolean read fshowhidden write fshowhidden;
    property filterlist: tdoublemsestringdatalist read ffilterlist write setfilterlist;
    property filterindex: integer read ffilterindex write ffilterindex default 0;
    property include: fileattributesty read finclude write finclude default [fa_all];
    property exclude: fileattributesty read fexclude write fexclude default [fa_hidden];
{+}//    property colwidth: integer read fcolwidth write fcolwidth default 0;
    property defaultext: filenamety read fdefaultext write setdefaultext;
    property options: filedialogoptionsty read foptions write setoptions default defaultfiledialogoptions;
    property historymaxcount: integer read fhistorymaxcount write sethistorymaxcount default defaulthistorymaxcount;
    property captionopen: msestring read fcaptionopen write fcaptionopen;
    property captionsave: msestring read fcaptionsave write fcaptionsave;
    property captionnew: msestring read fcaptionnew write fcaptionnew;
{-}    property captiondir: msestring read fcaptiondir write fcaptiondir;
    property group: integer read fgroup write fgroup default 0;
    property imagelist: timagelist read fimagelist write setimagelist;
    property ongetfilename: setstringeventty read fongetfilename write fongetfilename;
    property ongetfileicon: getfileiconeventty read fongetfileicon write fongetfileicon;
    property oncheckfile: checkfileeventty read foncheckfile write foncheckfile;
    property onbeforeexecute: filedialogbeforeexecuteeventty read fonbeforeexecute write fonbeforeexecute;
    property onafterexecute: filedialogafterexecuteeventty read fonafterexecute write fonafterexecute;
////////////////////////////////////////////
   PROPERTY onchange: proceventty READ fonchange WRITE fonchange;
////////////////////////////////////////////
  end;

const
  defaultfiledialogoptionsedit1 = defaultoptionsedit1 +
    [oe1_savevalue, oe1_savestate, oe1_saveoptions];

type
  tfiledialogx = class(tdialog, istatfile)
  private
    fcontroller: tfiledialogxcontroller;
    fstatvarname: msestring;
    fstatfile: tstatfile;
    fdialogkind: filedialogkindty;
    //   foptionsedit: optionseditty;
    foptionsedit1: optionsedit1ty;
    fstatpriority: integer;
    procedure setcontroller(const Value: tfiledialogxcontroller);
    procedure setstatfile(const Value: tstatfile);
    procedure readoptionsedit(reader: treader);
  protected
    procedure defineproperties(filer: tfiler);
      override;
    //istatfile
    procedure dostatread(const reader: tstatreader);
    procedure dostatwrite(const writer: tstatwriter);
    procedure statreading;
    procedure statread;
    function getstatvarname: msestring;
    function getstatpriority: integer;
  public

    constructor Create(aowner: TComponent); override;
    destructor Destroy; override;
    function Execute: modalresultty; overload; override;
    function Execute(const akind: filedialogkindty): modalresultty;
      reintroduce; overload;
    function Execute(const akind: filedialogkindty; const aoptions: filedialogoptionsty): modalresultty;
      reintroduce; overload;
    procedure componentevent(const event: tcomponentevent); override;
  published
    property statfile: tstatfile read fstatfile write setstatfile;
    property statvarname: msestring read getstatvarname write fstatvarname;
    property statpriority: integer read fstatpriority write fstatpriority default 0;
    property controller: tfiledialogxcontroller read fcontroller write setcontroller;
    property dialogkind: filedialogkindty read fdialogkind write fdialogkind default fdk_none;
    property optionsedit1: optionsedit1ty read foptionsedit1 write foptionsedit1 default defaultfiledialogoptionsedit1;

  end;

  tcustomfilenameedit1 = class;

  tfilenameeditcontroller = class(tstringdialogcontroller)
  protected
    function Execute(var avalue: msestring): Boolean; override;
  public

    constructor Create(const aowner: tcustomfilenameedit1);
  end;

  tcustomfilenameedit1 = class(tcustomdialogstringed)
  private
    fcontroller: tfiledialogxcontroller;
    procedure setcontroller(const avalue: tfiledialogxcontroller);
    function getsysvalue: filenamety;
    procedure setsysvalue(const avalue: filenamety);
    function getsysvaluequoted: filenamety;
  protected
    function createdialogcontroller: tstringdialogcontroller; override;
    procedure texttovalue(var accept: Boolean; const quiet: Boolean); override;
    procedure updatedisptext(var avalue: msestring); override;
    function getvaluetext: msestring; override;
    procedure readstatvalue(const reader: tstatreader); override;
    procedure readstatstate(const reader: tstatreader); override;
    procedure readstatoptions(const reader: tstatreader); override;
    procedure writestatvalue(const writer: tstatwriter); override;
    procedure writestatstate(const writer: tstatwriter); override;
    procedure writestatoptions(const writer: tstatwriter); override;
    procedure valuechanged; override;
    procedure updatecopytoclipboard(var atext: msestring); override;
    procedure updatepastefromclipboard(var atext: msestring); override;
  public

    constructor Create(aowner: TComponent); override;
    destructor Destroy; override;
    procedure componentevent(const event: tcomponentevent); override;
    property controller: tfiledialogxcontroller read fcontroller write setcontroller;
    property sysvalue: filenamety read getsysvalue write setsysvalue;
    property sysvaluequoted: filenamety read getsysvaluequoted write setsysvalue;
  published
    property optionsedit1 default defaultfiledialogoptionsedit1;
  end;

  tcustomfilenameedit = class(tcustomfilenameedit1)
  public

    constructor Create(aowner: TComponent); override;
    destructor Destroy; override;
  end;

  tcustomremotefilenameedit = class(tcustomfilenameedit1)
  private
    fdialog: tfiledialogx;
    procedure setfiledialog(const avalue: tfiledialogx);
  protected
    procedure objectevent(const Sender: TObject; const event: objecteventty); override;
  public
    property dialog: tfiledialogx read fdialog write setfiledialog;
  end;

  tfilenameeditx = class(tcustomfilenameedit)
  published
    property frame;
    property passwordchar;
    property maxlength;
    property Value;
    property onsetvalue;
    property controller;
  end;

  tremotefilenameeditx = class(tcustomremotefilenameedit)
  published
    property frame;
    property passwordchar;
    property maxlength;
    property Value;
    property onsetvalue;
    property dialog;
  end;

  dirdropdowneditoptionty  = (ddeo_showhiddenfiles, ddeo_checksubdir);
  dirdropdowneditoptionsty = set of dirdropdowneditoptionty;

  tdirdropdownedit = class(tdropdownwidgetedit)
  private
    foptions: dirdropdowneditoptionsty;
    function getshowhiddenfiles: Boolean;
    procedure setshowhiddenfiles(const avalue: Boolean);
    function getchecksubdir: Boolean;
    procedure setchecksubdir(const avalue: Boolean);
  protected
    procedure createdropdownwidget(const atext: msestring; out awidget: twidget); override;
    function getdropdowntext(const awidget: twidget): msestring; override;
    procedure pathchanged(const Sender: TObject);
    procedure doafterclosedropdown; override;
    procedure updatecopytoclipboard(var atext: msestring); override;
    procedure updatepastefromclipboard(var atext: msestring); override;
  public
    property showhiddenfiles: Boolean read getshowhiddenfiles write setshowhiddenfiles;
    property checksubdir: Boolean read getchecksubdir write setchecksubdir;
  published
    property options: dirdropdowneditoptionsty read foptions write foptions default [];
  end;

  dirtreepatheventty = procedure(const Sender: TObject; const avalue: msestring) of object;

  tdirtreeview = class(tpublishedwidget, icaptionframe)
  private
    fonpathchanged: dirtreepatheventty;
    fonpathselected: dirtreepatheventty;
    fonselectionchanged: listitemeventty;
    function getoptions: dirtreeoptionsty;
    procedure setoptions(const avalue: dirtreeoptionsty);
    function getpath: filenamety;
    procedure setpath(const avalue: filenamety);
    procedure setroot(const avalue: filenamety);
    function getgrid: twidgetgrid;
    procedure setgrid(const avalue: twidgetgrid);
    function getoptionstree: treeitemeditoptionsty;
    procedure setoptionstree(const avalue: treeitemeditoptionsty);
    function getoptionsedit: optionseditty;
    procedure setoptionsedit(const avalue: optionseditty);
    function getcol_color: colorty;
    procedure setcol_color(const avalue: colorty);
    function getcol_coloractive: colorty;
    procedure setcol_coloractive(const avalue: colorty);
    function getcol_colorfocused: colorty;
    procedure setcol_colorfocused(const avalue: colorty);
    function getcell_options: coloptionsty;
    procedure setcell_options(const avalue: coloptionsty);

{
   function getcell_frame: tcellframe;
   procedure setcell_frame(const avalue: tcellframe);
   function getcell_face: tcellface;
   procedure setcell_face(const avalue: tcellface);
   function getcell_datalist: ttreeitemeditlist;
   procedure setcell_datalist(const avalue: ttreeitemeditlist);
  }
  protected
    fdirview: tdirtreefo;
    fpath: filenamety;
    froot: filenamety;
    procedure dopathchanged(const Sender: TObject);
    procedure dopathselected(const Sender: TObject);
    procedure doselectionchanged(const Sender: TObject; const aitem: tlistitem);
    procedure internalcreateframe; override;
    procedure loaded(); override;
    class function classskininfo: skininfoty; override;
  public

    constructor Create(aowner: TComponent); override;
    destructor Destroy(); override;
    procedure refresh();
    property dirview: tdirtreefo read fdirview;
    property path: filenamety read getpath write setpath;
    property root: filenamety read froot write setroot;
  published
    property font: twidgetfont read getfont write setfont stored isfontstored;
    property options: dirtreeoptionsty read getoptions write setoptions default [];
    property optionstree: treeitemeditoptionsty read getoptionstree write setoptionstree default [teo_treecolnavig, teo_enteronimageclick];
    property optionsedit: optionseditty read getoptionsedit write setoptionsedit default [oe_readonly, oe_undoonesc, oe_checkmrcancel, oe_forcereturncheckvalue, oe_hintclippedtext, oe_locate];
    property col_color: colorty read getcol_color write setcol_color default cl_default;
    property col_coloractive: colorty read getcol_coloractive write setcol_coloractive default cl_none;
    property col_colorfocused: colorty read getcol_colorfocused write setcol_colorfocused default cl_active;
    property col_options: coloptionsty read getcell_options write setcell_options default [co_readonly, co_fill, co_savevalue];
    //   property col_frame: tcellframe read getcell_frame write setcell_frame;
    //   property col_face: tcellface read getcell_face write setcell_face;
    //   property col_datalist: ttreeitemeditlist read getcell_datalist
    //                                                   write setcell_datalist;
    property onpathchanged: dirtreepatheventty read fonpathchanged write fonpathchanged;
    property onpathselected: dirtreepatheventty read fonpathselected write fonpathselected;
    property onselectionchanged: listitemeventty read fonselectionchanged write fonselectionchanged;
    //for checkboxes
    property optionswidget default defaultoptionswidgetsubfocus;
  end;

  tfiledialogxfo = class (tdialogform)  // tmseform)
    back:         tstockglyphbutton;
    forward:      tstockglyphbutton;
    up:           tstockglyphbutton;
    home:         TButton;
    createdir:    TButton;
    cancel:       TButton;
    ok:           TButton;
    dir:          tdirdropdownedit;
    tsplitter2:   tsplitter;
    filter:       tdropdownlistedit;
    placespan:    tstringdisp;
    places:       tstringgrid;
    tsplitter3:   tsplitter;
    placescust:   tstringgrid;
    tsplitter1:   tsplitter;
    list_log:     tstringgrid;
    listview:     tfilelistviewx;
    imImage:      timage;
    filename:     thistoryedit;
    labtest:      tlabel;
    tlayouter2:   tlayouter;
    iconslist:    timagelist;
////////////////////////////////////////////
    Settings:     tpopupmenu;
////////////////////////////////////////////
    fController:  tfiledialogxcontroller;
////////////////////////////////////////////

    {$ifdef BGRABITMAP_USE_MSEGUI}
    tbitmapcomp1: TBGRABitmap;
    function LoadImagebgra(const AFileName: msestring): msestring;
    {$else}
    tbitmapcomp1: tbitmapcomp;
    function LoadImage(const AFileName: msestring): msestring;
   {$endif}

    procedure createdironexecute(const Sender: TObject);
    procedure listviewselectionchanged(const Sender: tcustomlistview);
    procedure listviewitemevent(const Sender: tcustomlistview; const index: integer; var info: celleventinfoty);
    procedure listviewonkeydown(const Sender: twidget; var info: keyeventinfoty);
    procedure upaction(const Sender: TObject);
    procedure dironsetvalue(const Sender: TObject; var avalue: mseString; var accept: Boolean);
    procedure filenamesetvalue(const Sender: TObject; var avalue: mseString; var accept: Boolean);
    procedure listviewonlistread(const Sender: TObject);
    procedure filteronafterclosedropdown(const Sender: TObject);
    procedure filteronsetvalue(const Sender: TObject; var avalue: msestring; var accept: Boolean);
    procedure filepathentered(const Sender: TObject);
    procedure okonexecute(const Sender: TObject);
    procedure layoutev(const Sender: TObject);
////////////////////////////////////////////
////    procedure list_logselectionchanged (const Sender: TObject);
////////////////////////////////////////////
    procedure showhiddenonsetvalue(const Sender: TObject; var avalue: Boolean; var accept: Boolean);
////////////////////////////////////////////
    procedure dirshowhint(const Sender: TObject; var info: hintinfoty);
    procedure copytoclip(const Sender: TObject; var avalue: msestring);
    procedure pastefromclip(const Sender: TObject; var avalue: msestring);
    procedure homeaction(const Sender: TObject);
    procedure backexe(const Sender: TObject);
    procedure forwardexe(const Sender: TObject);
    procedure buttonshowhint(const Sender: TObject; var ainfo: hintinfoty);
    procedure oncellev(const Sender: TObject; var info: celleventinfoty);
    procedure ondrawcell(const Sender: tcol; const Canvas: tcanvas; var cellinfo: cellinfoty);
    procedure onsetcomp(const Sender: TObject; var avalue: Boolean; var accept: Boolean);
////////////////////////////////////////////
    procedure oncreat(const Sender: TObject);
    procedure onbefdrop(const Sender: TObject);
    procedure oncellevplaces(const Sender: TObject; var info: celleventinfoty);
    procedure ondrawcellplace(const Sender: tcol; const Canvas: tcanvas; var cellinfo: cellinfoty);
    procedure onlayout(const Sender: tcustomgrid);
    procedure onformcreated(const Sender: TObject);
    procedure onlateral(const Sender: TObject; var avalue: Boolean; var accept: Boolean);
////////////////////////////////////////////
    procedure afterclosedrop(const Sender: TObject);
    procedure onresize(const Sender: TObject);
    procedure onchangdir(const Sender: TObject);
    procedure ondrawcellplacescust(const Sender: tcol; const Canvas: tcanvas; var cellinfo: cellinfoty);
    procedure oncellevcustplaces(const Sender: TObject; var info: celleventinfoty);
    procedure onmovesplit(const Sender: TObject);
    procedure onsetvalnoicon(const Sender: TObject; var avalue: Boolean; var accept: Boolean);
////////////////////////////////////////////
    procedure afclosedropdir(const sender: TObject);
    procedure onpain(const sender: twidget; const acanvas: tcanvas);
////////////////////////////////////////////
    procedure onswitchvalnoicon   (const Sender: TObject);
    procedure onswitchcomp        (const Sender: TObject);
    procedure onswitchlateral     (const Sender: TObject);
////    procedure onswitchhidehistory (const Sender: TObject);
    procedure onswitchshowhidden  (const Sender: TObject);
    procedure onswitchpreview     (const Sender: TObject);
////////////////////////////////////////////

////////////////////////////////////////////
   procedure StateRead  (const sender: TObject; const reader: tStatReader); VIRTUAL;
   procedure StateWrite (const sender: TObject; const writer: tStatWriter); VIRTUAL;
////////////////////////////////////////////
//   procedure resized    (const sender: TObject);
////////////////////////////////////////////
//   procedure componentevent(const event: tcomponentevent); override;
////////////////////////////////////////////

  private
    fselectednames: filenamearty;
    finit: Boolean;
////????    fisfixedrow: Boolean;
    fsplitterpanpos: integer;
    fcourse: filenamearty;
    fcourseid: int32;
    fcourselock: Boolean;
////////////////////////////////////////////
(*    last_row:   integer; *)
////////////////////////////////////////////
    ffCaption: msestring;
////////////////////////////////////////////
    UserPopup: tpopupmenu;
////////////////////////////////////////////

////////////////////////////////////////////
//// Configuration flags:
////    bnoicon,
////    blateral,
////    bcompact,
////    showhidden,
////    bhidehistory: boolean;
////////////////////////////////////////////

    procedure updatefiltertext;
    function tryreadlist(const adir: filenamety; const errormessage: Boolean): Boolean;
    //restores old dir on error
    function changedir(const adir: filenamety): Boolean;
    procedure checkcoursebuttons();
    procedure course(const adir: filenamety);
    procedure doup();
////////////////////////////////////////////
   FUNCTION  getDialogOptions: filedialogoptionsty;
   PROCEDURE setDialogOptions (FileOptions: filedialogoptionsty);
////////////////////////////////////////////
   PROCEDURE setUserPopup (Popup: tpopupmenu);
////////////////////////////////////////////
//   FUNCTION  getFilenames: filenamearty;
//   PROCEDURE setFilenames (Files: filenamearty);
////////////////////////////////////////////
    PROCEDURE realizeSelection;
////////////////////////////////////////////
    PROCEDURE showpreview;
////////////////////////////////////////////

  public
////////////////////////////////////////////
   CONSTRUCTOR Create (CONST Sender: TComponent; ControlIn: tfiledialogxcontroller;
                       CONST StatName: msestring; where: dialogposty = dp_none); OVERLOAD; REINTRODUCE;
   CONSTRUCTOR Create (CONST Sender: TComponent; ControlIn: tfiledialogxcontroller; where: dialogposty); OVERLOAD; REINTRODUCE;
   CONSTRUCTOR Create (CONST Sender: TComponent; ControlIn: tfiledialogxcontroller); OVERLOAD; REINTRODUCE;
////////////////////////////////////////////
   CONSTRUCTOR Create (CONST Sender: TComponent; CONST StatName: msestring;
                       where: dialogposty = dp_none); OVERLOAD; REINTRODUCE;
   CONSTRUCTOR Create (CONST Sender: TComponent; where: dialogposty); OVERLOAD; REINTRODUCE;
   CONSTRUCTOR Create (CONST Sender: TComponent); OVERLOAD; REINTRODUCE;
   DESTRUCTOR  Destroy; OVERRIDE;
////////////////////////////////////////////
   FUNCTION Execute (dialogkind: filedialogkindty = fdk_none): modalresultty; REINTRODUCE;  // ??
////////////////////////////////////////////

   PROPERTY Controller:    tfiledialogxcontroller READ fController; // NO WRITE HERE!
   PROPERTY DialogCaption: msestring              READ ffCaption        WRITE ffCaption;
   PROPERTY DialogOptions: filedialogoptionsty    READ getDialogOptions WRITE setDialogOptions;

////////////////////////////////////////////
   PROPERTY PopupMenu:     tpopupmenu             READ UserPopup        WRITE setUserPopup;
////////////////////////////////////////////

//   PROPERTY Filenames: filenamearty READ getFilenames WRITE setFilenames;
//   PROPERTY DefaultExt: filenamety READ fController.getdefaultext WRITE fController.setdefaultext;

////////////////////////////////////////////
  end;

function filedialogx(var afilenames: filenamearty; const aoptions: filedialogoptionsty; const acaption: msestring;    //'' -> 'Open' or 'Save'
  const filterdesc: array of msestring; const filtermask: array of msestring; const adefaultext: filenamety = ''; const filterindex: pinteger = nil;     //nil -> 0
  const filter: pfilenamety = nil;       //nil -> unused
  const colwidth: pinteger = nil;        //nil -> default
  const includeattrib: fileattributesty = [fa_all]; const excludeattrib: fileattributesty = [fa_hidden]; const history: pmsestringarty = nil; const historymaxcount: integer = defaulthistorymaxcount;
  const imagelist: timagelist = nil; const ongetfileicon: getfileiconeventty = nil; const oncheckfile: checkfileeventty = nil): modalresultty;
  overload;
//threadsafe
function filedialogx(var afilename: filenamety; const aoptions: filedialogoptionsty; const acaption: msestring; const filterdesc: array of msestring; const filtermask: array of msestring;
  const adefaultext: filenamety = ''; const filterindex: pinteger = nil;     //nil -> 0
  const filter: pfilenamety = nil;       //nil -> unused
  const colwidth: pinteger = nil;        //nil -> default
  const includeattrib: fileattributesty = [fa_all]; const excludeattrib: fileattributesty = [fa_hidden]; const history: pmsestringarty = nil; const historymaxcount: integer = defaulthistorymaxcount;
  const imagelist: timagelist = nil; const ongetfileicon: getfileiconeventty = nil; const oncheckfile: checkfileeventty = nil): modalresultty;
  overload;
//threadsafe

procedure getfileicon(const info: fileinfoty; var imagelist: timagelist; out imagenr: integer);
procedure updatefileinfo(const item: tlistitem; const info: fileinfoty; const withicon: Boolean);

var
  theimagelist: timagelist = nil;
  theboolicon: Boolean = False;
 // thehistoryarray: msestringarty;

implementation

uses
  StrUtils,
{$ifdef BGRABITMAP_USE_MSEGUI}
  msefiledialogxbgra_mfm,
{$else}
  msefiledialogx_mfm,
{$endif}
  msebits,
  mseactions,
  msestringenter,
  msestockobjects,
  msesysintf,
  msearrayutils;

{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
 {$if fpc_fullversion >= 030300}
  {$warn 6060 off}
  {$warn 6018 off}
  {$endif}
{$endif}

////////////////////////////////////////////
{$Macro On}
// defined as macros here for easier adaptation to layout changes
{$define IconsSetting:=   Settings.Menu.SubMenu [1]}
{$define PlacesSetting:=  Settings.Menu.SubMenu [2]}
{$define CompactSetting:= Settings.Menu.SubMenu [3]}
{$define HiddenSetting:=  Settings.Menu.SubMenu [5]}
{$define HistorySetting:= Settings.Menu.SubMenu [6]}
{$define PreviewSetting:= Settings.Menu.SubMenu [7]}
////////////////////////////////////////////

TYPE
  SizeMark = RECORD
               Text: msestring;
               Sign: char;
             END;
CONST
  sizeSign: ARRAY OF SizeMark =
    ((Text: ' B '; Sign: '!'), (Text: ' KB'; Sign: '^'), (Text: ' MB'; Sign: '_'),
     (Text: ' GB'; Sign: '~'), (Text: ' TB'; Sign: '"'), (Text: ' PB'; Sign: ''''));

TYPE
  ExtIcons = RECORD
      Icon: integer;
      Ext:  string [9];
    END;

  ExtIconTable = ARRAY OF ExtIcons;

CONST
  ExtIcon: ExtIconTable =
{2} ((Icon:  2; Ext: '.txt'),   (Icon:  2; Ext: '.pdf'),   (Icon:  2; Ext: '.ini'),
     (Icon:  2; Ext: '.md'),    (Icon:  2; Ext: '.html'),  (Icon:  2; Ext: '.inc'),
{8}  (Icon:  8; Ext: '.pas'),   (Icon:  8; Ext: '.lpi'),   (Icon:  8; Ext: '.lpr'),
     (Icon:  8; Ext: '.prj'),   (Icon:  8; Ext: '.pp'),
{9}  (Icon:  9; Ext: '.lps'),   (Icon:  9; Ext: '.mfm'),
{10} (Icon: 10; Ext: '.java'),  (Icon: 10; Ext: '.js'),    (Icon: 10; Ext: '.class'),
{11} (Icon: 11; Ext: '.c'),     (Icon: 11; Ext: '.cc'),    (Icon: 11; Ext: '.cpp'),
     (Icon: 11; Ext: '.h'),
{12} (Icon: 12; Ext: '.py'),    (Icon: 12; Ext: '.pyc'),
{3}  (Icon:  3; Ext: '.wav'),   (Icon:  3; Ext: '.m4a'),   (Icon:  3; Ext: '.mp3'),
     (Icon:  3; Ext: '.opus'),  (Icon:  3; Ext: '.flac'),  (Icon:  3; Ext: '.ogg'),
{4}  (Icon:  4; Ext: '.avi'),   (Icon:  4; Ext: '.flv'),   (Icon:  4; Ext: '.mov'),
     (Icon:  4; Ext: '.mpg'),   (Icon:  4; Ext: '.mpeg'),  (Icon:  4; Ext: '.mkv'),
     (Icon:  4; Ext: '.webm'),  (Icon:  4; Ext: '.wmv'),   (Icon:  4; Ext: '.mp4'),
{7}  (Icon:  7; Ext: '.png'),   (Icon:  7; Ext: '.jpg'),   (Icon:  7; Ext: '.jpeg'),  // can shpw image
     (Icon:  7; Ext: '.ico'),   (Icon:  7; Ext: '.xpm'),   (Icon:  7; Ext: '.bmp'),   // can shpw image
     (Icon:  7; Ext: '.tiff'),                                                        // can shpw image
{$ifdef BGRABITMAP_USE_MSEGUI}
     (Icon:  7; Ext: '.gif'),   (Icon:  7; Ext: '.svg'),   (Icon:  7; Ext: '.webp'),
{$ELSE}
     (Icon: -7; Ext: '.gif'),   (Icon: -7; Ext: '.svg'),   (Icon: -7; Ext: '.webp'),
{$ENDIF}
{5}  (Icon:  5; Ext: ''),       (Icon:  5; Ext: '.exe'),   (Icon:  5; Ext: '.dbg'),
     (Icon:  5; Ext: '.com'),   (Icon:  5; Ext: '.bat'),   (Icon:  5; Ext: '.bin'),
     (Icon:  5; Ext: '.dll'),   (Icon:  5; Ext: '.res'),   (Icon:  5; Ext: '.so'),
     (Icon:  5; Ext: '.dylib'),
{6}  (Icon:  6; Ext: '.zip'),   (Icon:  6; Ext: '.iso'),   (Icon:  6; Ext: '.cab'),
     (Icon:  6; Ext: '.7z'),    (Icon:  6; Ext: '.txz'),   (Icon:  6; Ext: '.rpm'),
     (Icon:  6; Ext: '.tar'),   (Icon:  6; Ext: '.gz'),    (Icon:  6; Ext: '.deb'),
     (Icon:  6; Ext: '.torrent'),
{1}  (Icon:  1; Ext: ''));

CONST
  ImageList =37;   // Index of first image type entry, TO BE UPDATED ON CHANGES!

TYPE
  PlaceIcons = RECORD
      Icon:  integer;
      Place: string [9];
    END;

  SubPlaces = (SysRoot, DataDir, atHome, Desktop, Music, Sound, Pictures, Videos, Documents, Downloads, no_more);

  PlaceIconTable = ARRAY [SubPlaces] OF PlaceIcons;

CONST
  SubPlace: PlaceIconTable = (
  {$ifdef windows}
    (Icon:  0; Place: ':\'),       (Icon:  0; Place: ':\users'),
  {$else}
    (Icon:  0; Place: '/'),         (Icon:  0; Place: '/usr'),
  {$endif}
    (Icon: 13; Place: 'Home'),      (Icon: 14; Place: 'Desktop'),
    (Icon:  3; Place: 'Music'),     (Icon:  3; Place: 'Sound'),
    (Icon:  7; Place: 'Pictures'),  (Icon:  4; Place: 'Videos'),
    (Icon:  2; Place: 'Documents'), (Icon: 15; Place: 'Downloads'),
    (Icon:  0; Place: ''));

type
  tdirtreefo1 = class(tdirtreefo);

procedure getfileicon(const info: fileinfoty; var imagelist: timagelist; out imagenr: integer);
begin
  if assigned(theimagelist) then
  begin
  imagelist := theimagelist;
  with info do
  begin
    //  imagelist:= nil;
    imagenr := -1;
    if fis_typevalid in state then
      case extinfo1.filetype of
        ft_dir:
          if theboolicon = False then
            imagenr := 0
          else
            imagenr := 17;
        ft_reg, ft_lnk:
          if theboolicon = False then
            imagenr := 1
          else
            imagenr := 18;
      end;
  end;
  end else
  begin
  imagenr := -1;
  imagelist := nil;
  end;
end;

procedure updatefileinfo(const item: tlistitem; const info: fileinfoty; const withicon: Boolean);
var
  aimagelist: timagelist;
  aimagenr: integer;
begin
  aimagelist   := item.imagelist;
  item.Caption := info.Name;
  if withicon then
  begin
    getfileicon(info, aimagelist, aimagenr);
    item.imagelist := aimagelist;
    if aimagelist <> nil then
      item.imagenr := aimagenr;
  end;
end;

function filedialogx1 (dialog: tfiledialogxfo;
                       var afilenames: filenamearty;
                       const filterdesc: array of msestring;
                       const filtermask: array of msestring;
                       const filterindex: pinteger;
                       const afilter: pfilenamety;      //nil -> unused
                       const colwidth: pinteger;        //nil -> default
                       const includeattrib: fileattributesty;
                       const excludeattrib: fileattributesty;
                       const history: pmsestringarty;
                       const historymaxcount: integer;
                       const acaption: msestring;
                       const aoptions: filedialogoptionsty;
                       const adefaultext: filenamety;
                       const imagelist: timagelist;
                       const ongetfileicon: getfileiconeventty;
                       const oncheckfile: checkfileeventty
                       ): modalresultty;
var
  int1:  integer;
  abool: Boolean;
begin
  with dialog do
  begin
    dir.checksubdir      := fdo_checksubdir in aoptions;
    listview.checksubdir := fdo_checksubdir in aoptions;
    dialogoptions        := aoptions;
    if fdo_filtercasesensitive in aoptions then
      listview.optionsfile := listview.optionsfile + [flvo_maskcasesensitive];
    if fdo_filtercaseinsensitive in aoptions then
      listview.optionsfile := listview.optionsfile + [flvo_maskcaseinsensitive];
////////////////////////////////////////////
////    if fdo_single in aoptions then
////      listview.options     := listview.options - [lvo_multiselect];
    setDialogOptions (aoptions);    // set selection options for both displays
////////////////////////////////////////////
    fController.defaultext := adefaultext;
    Caption := acaption;
    //caption := 'Select a file';
    listview.includeattrib := includeattrib;
    listview.excludeattrib      := excludeattrib;
    listview.itemlist.imagelist := imagelist;
    if imagelist <> nil then
      listview.itemlist.imagesize := imagelist.size;
    listview.ongetfileicon        := ongetfileicon;
    listview.oncheckfile          := oncheckfile;
    filter.dropdown.cols[0].Count := high(filtermask) + 1;
    for int1 := 0 to high(filtermask) do
      if (int1 <= high(filterdesc)) and (filterdesc[int1] <> '') then
        filter.dropdown.cols[0][int1] := filterdesc[int1] + ' (' +
          filtermask[int1] + ')'
      else
        filter.dropdown.cols[0][int1] := filtermask[int1];
    filter.dropdown.cols[1].assignopenarray(filtermask);
    if filterindex <> nil then
      filter.dropdown.ItemIndex := filterindex^
    else
      filter.dropdown.ItemIndex := 0;
    if (afilter = nil) or (afilter^ = '') or
      (filter.dropdown.ItemIndex >= 0) and
      (afilter^ = filter.dropdown.cols[1][filter.dropdown.ItemIndex]) then
      updatefiltertext
    else
    begin
      filter.Value  := afilter^;
      listview.mask := afilter^;
    end;
    if history <> nil then
    begin
      filename.dropdown.valuelist.asarray := history^;
      filename.dropdown.historymaxcount := historymaxcount;
    end
//// DO NOT disable the history display HERE! You DON'T KNOW YET whether it's wanted!
////    else
////      filename.dropdown.options := [deo_disabled];
;
    if (high(afilenames) = 0) and (fdo_directory in aoptions) then
      filename.Value     := filepath(afilenames[0])
    else
      filename.Value     := quotefilename(afilenames);

    if (colwidth <> nil) and (colwidth^ <> 0) then
      listview.cellwidth := colwidth^;

    finit := True;
    try
      filename.checkvalue;
    finally
      finit := False;
    end;

    if filename.tag = 1 then
      filename.Value := ExtractFilePath(filename.Value);

////    abool := True;

////    if bhidehistory.Value then filename.visible := false
////    else filename.visible := true;
   filename.visible := NOT HistorySetting.checked;

////??    if blateral.Value then
////??      onlateral(nil, abool, abool);
////??    if bcompact.Value then
////??      onsetcomp(nil, abool, abool);
////??    if showhidden.Value then
////??      showhiddenonsetvalue(nil, abool, abool);
    //  showhidden := not (fa_hidden in excludeattrib);
////////////////////////////////////////////
    abool:= PlacesSetting.checked;
    onlateral (nil, abool, abool {not used});
    abool:= CompactSetting.checked;
    onsetcomp (nil, abool, abool {not used});
    abool:= HiddenSetting.checked;
    showhiddenonsetvalue (nil, abool, abool {not used});
////////////////////////////////////////////

////////////////////////////////////////////
////    if bshowoptions.value then
////    begin
////      bnoicon.visible := true;
////      bcompact.visible := true;
////      showhidden.visible := true;
////      blateral.visible := true;
////      filename.top := list_log.bottom + 8;
////      imimage.top := filename.top - 4;
////      imimage.height := filename.height + 8;
////    end else
////    begin
////      dir.top := back.bottom + 8;
////      filter.top := dir.top;
////      tsplitter2.top := dir.top;
////      placespan.top := filter.bottom + 8;
////      tsplitter1.top := placespan.top;
////      list_log.top := placespan.top;
////      listview.top := list_log.top;
      filename.top := list_log.bottom + 8;
      tsplitter1.height := list_log.height;
      filename.top := list_log.bottom + 8;
      imimage.top := filename.top - 4;
////      imimage.height := filename.height + 8;
////      bnoicon.visible := false;
////      bcompact.visible := false;
////      showhidden.visible := false;
////      blateral.visible := false;
////    end;
////////////////////////////////////////////

    if filename.visible = false then
      height := list_log.bottom + 8
    else
      height := filename.bottom + 8;

    placespan.anchors := [an_left,an_top, an_bottom];
    list_log.anchors := [an_left,an_top, an_bottom];
    listview.anchors := [an_left,an_top, an_bottom];
////////////////////////////////////////////
//    Show(True);
  Result:= Show (True, Window);
//    Result      := window.modalresult;
////////////////////////////////////////////
////????    if Result <> mr_ok then
    if (Result <> mr_ok) AND (Result <> mr_none) then
      Result    := mr_cancel;

    if (colwidth <> nil) then
      colwidth^ := listview.cellwidth;

////????    if Result = mr_ok then
    if (Result = mr_ok) OR (Result = mr_none{gnrfzg...}) then
    begin
      Result:= mr_ok;

      afilenames     := fController.filenames;

      if filterindex <> nil then
        filterindex^ := filter.dropdown.ItemIndex;

      if afilter <> nil then
        afilter^     := listview.mask;

      if high(afilenames) = 0 then
        filename.dropdown.savehistoryvalue(afilenames[0]);

      if history <> nil then
        history^ := filename.dropdown.valuelist.asarray;

      if fdo_chdir in aoptions then
        setcurrentdirmse(listview.directory);
    end;
  end;
end;

function filedialogx(var afilenames: filenamearty;
  const aoptions: filedialogoptionsty;
  const acaption: msestring;
  const filterdesc: array of msestring;
  const filtermask: array of msestring;
  const adefaultext: filenamety = '';
  const filterindex: pinteger = nil;
  const filter: pfilenamety = nil;       //nil -> unused
  const colwidth: pinteger = nil;        //nil -> default
  const includeattrib: fileattributesty = [fa_all];
  const excludeattrib: fileattributesty = [fa_hidden];
  const history: pmsestringarty = nil;
  const historymaxcount: integer = defaulthistorymaxcount;
  const imagelist: timagelist = nil;
  const ongetfileicon: getfileiconeventty = nil;
  const oncheckfile: checkfileeventty = nil): modalresultty;
var
  dialog: tfiledialogxfo;
  str1: msestring;
begin
  application.lock;
  try
    dialog := tfiledialogxfo.Create(nil);

    dialog.PlacesSetting.checked := true;
    dialog.CompactSetting.checked:= true;

    if acaption = '' then
    begin
   {$ifdef mse_dynpo}
   if length(lang_stockcaption) > ord(sc_save) then
   begin
    if fdo_save in aoptions then
         str1 := lang_stockcaption[ord(sc_save)]
        else
          str1 := lang_stockcaption[ord(sc_open)];
    end else
    begin
    if fdo_save in aoptions then
         str1 := 'Save'
        else
          str1 := 'Open';
    end;

   {$else}
    if fdo_save in aoptions then
          str1 := sc(sc_save)
        else
          str1 := sc(sc_open);
   {$endif}

    end
    else
      str1 := acaption;
    try
      Result := filedialogx1(dialog, afilenames, filterdesc, filtermask,
        filterindex, filter, colwidth,
        includeattrib, excludeattrib, history, historymaxcount, str1, aoptions,
        adefaultext, imagelist, ongetfileicon, oncheckfile);
    finally
      dialog.Free;
    end;
  finally
    application.unlock;
  end;
end;

function filedialogx(var afilename: filenamety; const aoptions: filedialogoptionsty; const acaption: msestring; const filterdesc: array of msestring; const filtermask: array of msestring;
  const adefaultext: filenamety = ''; const filterindex: pinteger = nil; const filter: pfilenamety = nil;       //nil -> unused
  const colwidth: pinteger = nil;        //nil -> default
  const includeattrib: fileattributesty = [fa_all]; const excludeattrib: fileattributesty = [fa_hidden]; const history: pmsestringarty = nil; const historymaxcount: integer = defaulthistorymaxcount;
  const imagelist: timagelist = nil; const ongetfileicon: getfileiconeventty = nil; const oncheckfile: checkfileeventty = nil): modalresultty;
var
  ar1: filenamearty;
begin
  setlength(ar1, 1);
  ar1[0] := afilename;
  Result := filedialogx(ar1, aoptions, acaption, filterdesc, filtermask, adefaultext,
    filterindex,
    filter, colwidth, includeattrib, excludeattrib, history, historymaxcount,
    imagelist, ongetfileicon, oncheckfile);

  if Result = mr_ok then
    if (high(ar1) > 0) or (fdo_quotesingle in aoptions) then
      afilename := quotefilename(ar1)
    else if high(ar1) = 0 then
      afilename := ar1[0]
    else
      afilename := '';
end;

{ tfilelistviewx }

constructor tfilelistviewx.Create(aowner: TComponent);
begin
  fcaseinsensitive := filesystemiscaseinsensitive;
  fincludeattrib   := [fa_all];
  fexcludeattrib   := [fa_hidden];
  fitemlist        := tfileitemlist.Create(self);
  foptionsfile     := defaultfilelistviewoptions;

  ffilelist          := tfiledatalist.Create;
  ffilelist.onchange :=
{$ifdef FPC}
    @
{$endif}
    filelistchanged;

  inherited;
  options := defaultlistviewoptionsfile;
  checkcasesensitive;
end;

destructor tfilelistviewx.Destroy;
begin
  inherited;
  ffilelist.Free;
end;

procedure tfilelistviewx.checkcasesensitive;
begin
  fcaseinsensitive   := filesystemiscaseinsensitive;
  if flvo_maskcasesensitive in foptionsfile then
    fcaseinsensitive := False;
  if flvo_maskcaseinsensitive in foptionsfile then
    fcaseinsensitive := True;
  // options:= options; //set casesensitive
end;

{
procedure tfilelistviewx.setoptions(const Value: listviewoptionsty);
begin
 if fcaseinsensitive then begin
  inherited setoptions(value - [lvo_casesensitive]);
 end
 else begin
  inherited setoptions(value + [lvo_casesensitive]);
 end;
end;
}
procedure tfilelistviewx.docellevent(var info: celleventinfoty);
var
  index: integer;
begin
  with info do
  begin
    if iscellclick(info, [ccr_buttonpress]) then
      options := options + [lvo_focusselect];
    case eventkind of
      cek_enter:
      begin
        if ffocusmoved then
          options     := options + [lvo_focusselect]
        else
          ffocusmoved := True;
        inherited;
      end;
      cek_select:
      begin
        index := celltoindex(cell, False);
        if index >= 0 then
        begin
          if (flvo_nofileselect in foptionsfile) and
            (ffilelist[index].extinfo1.filetype <> ft_dir) then
            accept := False
          else
          begin
            if (flvo_nodirselect in foptionsfile) and
              (ffilelist[index].extinfo1.filetype = ft_dir) then
              accept := False;
          end;
          inherited;
        end
        else
          inherited;
      end;
      else
        inherited;
    end;
  end;
end;

procedure tfilelistviewx.filelistchanged(const Sender: TObject);
var
  int1: integer;
  po1: pfilelistitem;
  po2: pfileinfoty;
  imlist1: timagelist;
  imnr1: integer;
  bo1: Boolean;
begin
  options := options - [lvo_focusselect];
////  options := options + [lvo_horz];

  ffocusmoved := False;
  with ffilelist do
  begin
    self.beginupdate;
    self.fitemlist.beginupdate;
    try
      self.fitemlist.Clear;
      self.fitemlist.Count := Count;
      po1 := pfilelistitem(self.fitemlist.datapo);
      po2 := pfileinfoty(datapo);
      bo1 := checksubdir;
      for int1 := 0 to Count - 1 do
      begin
        if bo1 and (po2^.extinfo1.filetype = ft_dir) and
          dirhasentries(path + '/' + po2^.Name, includeattrib, excludeattrib) then
          include(po2^.state, fis_hasentry);
        updatefileinfo(po1^, po2^, True);
        if Assigned(fongetfileicon) then
        begin
          imlist1        := po1^.imagelist;
          imnr1          := po1^.imagenr;
          fongetfileicon(self, po2^, imlist1, imnr1);
          po1^.imagelist := imlist1;
          po1^.imagenr   := imnr1;
        end;
        Inc(po1);
        Inc(po2);
      end;
    finally
      self.fitemlist.endupdate;
      self.endupdate;
    end;
  end;
end;

function tfilelistviewx.getselectednames: msestringarty;
var
  int1, int2: integer;
begin
  int2   := 0;
  Result := nil;
  for int1 := 0 to ffilelist.Count - 1 do
    if fitemlist[int1].selected then
      additem(Result, ffilelist[int1].Name, int2);
  setlength(Result, int2);
end;

procedure tfilelistviewx.setselectednames(const avalue: filenamearty);
var
  int1: integer;
  item1: tlistitem;
  po1: plistitematy;
  // cell1: gridcoordty;
begin
  po1 := fitemlist.datapo;
  fitemlist.beginupdate;
  try
    for int1 := 0 to fitemlist.Count - 1 do
      po1^[int1].selected := False;
    for int1 := 0 to high(avalue) do
    begin
      item1  := finditembycaption(avalue[int1]);
      if item1 <> nil then
        item1.selected := True;
    end;
  finally
    fitemlist.endupdate;
  end;

{
 for int1:= 0 to high(avalue) do begin
  if findcellbycaption(avalue[int1],cell1) then begin
   fdatacols.selected[cell1]:= true;
  end;
 end;
 }
  // focuscell(cell1);
end;

procedure tfilelistviewx.setfilelist(const Value: tfiledatalist);
begin
  if ffilelist <> Value then
    ffilelist.Assign(Value);
end;

procedure tfilelistviewx.readlist;
var
  int1: integer;
  po1: pfileinfoty;
  level1: fileinfolevelty;
begin
  beginupdate;
  try
    defocuscell;
    fdatacols.clearselection;
    ffilelist.Clear;


    ffilecount := 0;
    level1     := fil_type;
    if Assigned(foncheckfile) then
      level1 := fil_ext2;
    if fmaskar = nil then
    begin
      ffilelist.adddirectory(fdirectory, level1, fmaskar,
        fincludeattrib, fexcludeattrib, foptionsdir,
        foncheckfile);
      if ffilelist.Count > 0 then
      begin
        po1      := ffilelist.itempo(0);
        for int1 := 0 to ffilelist.Count - 1 do
        begin
          if not (fa_dir in po1^.extinfo1.attributes) then
            Inc(ffilecount);
          Inc(po1);
        end;
      end;
    end
    else if (fincludeattrib = [fa_all]) or not (fa_dir in fincludeattrib) then
    begin
      ffilelist.adddirectory(fdirectory, level1, nil, [fa_dir],
        fexcludeattrib * [fa_hidden], foptionsdir, foncheckfile);
      int1       := ffilelist.Count;
      ffilelist.adddirectory(fdirectory, level1, fmaskar, fincludeattrib,
        fexcludeattrib + [fa_dir], foptionsdir, foncheckfile);
      ffilecount := ffilelist.Count - int1;
    end
    else
    begin
      ffilelist.adddirectory(fdirectory, level1, fmaskar,
        fincludeattrib, fexcludeattrib, foptionsdir, foncheckfile);
      ffilecount := ffilelist.Count;
    end;
  finally
    endupdate;
  end;
  if Assigned(fonlistread) then
    fonlistread(self);
end;

procedure tfilelistviewx.updir;
var
  str1: msestring;
  int1: integer;
begin
  str1 := removelastdir(fdirectory, fdirectory);
  if str1 <> '' then
  begin
    readlist;
    int1 := ffilelist.indexof(str1);
    if int1 >= 0 then
      focuscell(indextocell(int1), fca_focusin);
  end;
end;

procedure tfilelistviewx.setdirectory(const Value: msestring);
begin
  fdirectory := filepath(Value, fk_dir);
end;

function tfilelistviewx.getpath: msestring;
begin
  if fmaskar = nil then
    Result := filepath(fdirectory)
  else
    Result := filepath(fdirectory, fmaskar[0]);
end;

procedure tfilelistviewx.setpath(const Value: filenamety);
var
  str1: msestring;
begin
  splitfilepath(Value, fdirectory, str1);
  mask := str1;
  readlist;
end;

procedure tfilelistviewx.setmask(const Value: filenamety);
begin
  unquotefilename(Value, fmaskar);
end;

function tfilelistviewx.getmask: filenamety;
begin
  Result := quotefilename(fmaskar);
end;

function tfilelistviewx.filecount: integer;
begin
  if ffilelist.Count < ffilecount then
    ffilecount := 0;
  Result       := ffilecount;
end;

function tfilelistviewx.getchecksubdir: Boolean;
begin
  Result := flvo_checksubdir in foptionsfile;
end;

procedure tfilelistviewx.setchecksubdir(const avalue: Boolean);
begin
  if avalue then
    include(foptionsfile, flvo_checksubdir)
  else
    exclude(foptionsfile, flvo_checksubdir);
end;

procedure tfilelistviewx.setoptionsfile(const avalue: filelistviewoptionsty);
const
  mask1: filelistviewoptionsty = [flvo_maskcasesensitive, flvo_maskcaseinsensitive];
begin
  if avalue <> foptionsfile then
  begin
    foptionsfile := filelistviewoptionsty(
      setsinglebit(
{$ifdef FPC}
      longword
{$else}byte{$endif}
      (avalue),
                               {$ifdef FPC}
      longword
{$else}byte{$endif}
      (foptionsfile),
                               {$ifdef FPC}
      longword
{$else}byte{$endif}
      (mask1)));
    foptionsdir  := dirstreamoptionsty(foptionsfile) *
      [dso_casesensitive, dso_caseinsensitive];
    checkcasesensitive;
  end;
end;

{ tfilelistitem }

constructor tfilelistitem.Create(const aowner: tcustomitemlist);
begin
  inherited;
end;

{ tfileitemlist }

procedure tfileitemlist.createitem(out item: tlistitem);
begin
  item := tfilelistitem.Create(self);
end;

{ tfiledialogxfo }

////////////////////////////////////////////
CONST  //// "list_log" column selection index constants
  LabelCol = -1;
  NameCol =   0;
  ExtCol =    1;
  SizeCol =   2;
  DateCol =   3;
  IconFudge = 4;   //// additional space needed in column...
////////////////////////////////////////////

////////////////////////////////////////////
CONSTRUCTOR tfiledialogxfo.Create (CONST Sender: TComponent; ControlIn: tfiledialogxcontroller;
                                   CONST StatName: msestring; where: dialogposty);
 BEGIN
   fcontroller:= ControlIn;
   INHERITED Create (Sender, StatName, where);
   fcontroller.DialogPlacement:= where;
 END;

CONSTRUCTOR tfiledialogxfo.Create (CONST Sender: TComponent; ControlIn: tfiledialogxcontroller; where: dialogposty);
 BEGIN
   fcontroller:= ControlIn;
   INHERITED Create (Sender, where);
 END;

CONSTRUCTOR tfiledialogxfo.Create (CONST Sender: TComponent; ControlIn: tfiledialogxcontroller);
 BEGIN
   fcontroller:= ControlIn;
   INHERITED Create (Sender);
 END;
////////////////////////////////////////////
CONSTRUCTOR tfiledialogxfo.Create (CONST Sender: TComponent; CONST StatName: msestring;
                                  where: dialogposty);
 BEGIN
   fcontroller:= tfiledialogxcontroller.create (Self);
   INHERITED Create (Sender, StatName, where);
   fcontroller.DialogPlacement:= where;
 END;

CONSTRUCTOR tfiledialogxfo.Create (CONST Sender: TComponent; where: dialogposty);
 BEGIN
   fcontroller:= tfiledialogxcontroller.create (Self);
   INHERITED Create (Sender, where);
 END;

CONSTRUCTOR tfiledialogxfo.Create (CONST Sender: TComponent);
 BEGIN
   fcontroller:= tfiledialogxcontroller.create (Self);
   INHERITED Create (Sender);
 END;

DESTRUCTOR tfiledialogxfo.Destroy;
 BEGIN
   fcontroller.free;
   INHERITED;
 END;
////////////////////////////////////////////
FUNCTION  tfiledialogxfo.getDialogOptions: filedialogoptionsty;
 BEGIN
   Result:= fController.fOptions;
 END;

PROCEDURE tfiledialogxfo.setDialogOptions (FileOptions: filedialogoptionsty);
 BEGIN
   fController.Options:= FileOptions;
   IF fdo_single IN FileOptions THEN BEGIN
     WITH List_Log.dataCols DO Options:= Options- [co_multiselect];
     WITH ListView DO Options:= Options- [lvo_multiselect];
   END
   ELSE BEGIN
     WITH List_Log.dataCols DO Options:= Options+ [co_multiselect, co_rowselect];
     WITH ListView DO Options:= Options+ [lvo_multiselect];
   END;
 END;

////////////////////////////////////////////
PROCEDURE tfiledialogxfo.setUserPopup (Popup: tpopupmenu);
 BEGIN
   UserPopup:= Popup;
   ListView.PopupMenu:= Popup; List_Log.PopupMenu:= Popup; Filename.PopupMenu:= Popup;
 END;
////////////////////////////////////////////

// FUNCTION tfiledialogxfo.getFilenames: filenamearty;
//  BEGIN
//    Result:= fController.fFilenames;
//  END;

// PROCEDURE tfiledialogxfo.setFilenames (Files: filenamearty);
//  BEGIN
//    fController.fFilenames:= Files;
//  END;

////////////////////////////////////////////
////////////////////////////////////////////
PROCEDURE tfiledialogxfo.realizeSelection;
  VAR
    i:         integer;
    selection: integerarty;
  BEGIN
    SetLength (selection, 0);
    FOR i:= 0 TO pred (list_log.rowcount) DO
      IF finditem (fselectednames, list_log [NameCol][i]) >= 0
      THEN additem (selection, i);   // add to selection

    listview.selectednames:= fselectednames;
////????    filename.value:= quotefilename (fselectednames);
    list_log.datacols.selectedrows:= selection;
    IF PreviewSetting.checked AND (Length (selection) = 1) THEN showpreview;
  END;
////////////////////////////////////////////
////////////////////////////////////////////
FUNCTION tfiledialogxfo.Execute (dialogkind: filedialogkindty = fdk_none): modalresultty;
// main part copied from dialog function definition
 BEGIN
   Application.lock;
   TRY
     IF assigned (doPrepareDialog) THEN doPrepareDialog (Self);
     WITH fController DO
       Result:= Execute (dialogkind, ffCaption, fOptions, Self);

     IF Result IN acceptingResults THEN BEGIN
      Result:= mr_Ok;
      IF assigned (doEvaluateDialog) THEN doEvaluateDialog (self, Result);
     END;
   FINALLY
     Application.unlock;
   end;
 END;

procedure tfiledialogxfo.StateRead (const sender: TObject; const reader: tStatReader);
 VAR
   i:          integer;
   CustPlaces: mseStringArTy;
 begin
   IF sender = self THEN        // I.e. when run "stand alone"
     WITH fController DO BEGIN
       ReadStatOptions (Reader);  // LastDir, FileHistory
       ReadStatValue   (Reader);  // Filenames, Params (??)
       ReadStatState   (Reader);  // Position, Size, FileColWidth, Filter
     END;

   WITH reader DO BEGIN
////////////////////////////////////////////
     WITH Font DO BEGIN
       ColorBackground:=          ReadInteger ('BgColor',         integer (cl_default));
       Name:=                     ReadString  ('FontName',        'stf_default');
       Height:=                   ReadInteger ('FontSize',        0);
       Style:=      fontstylesty (ReadInteger ('FontStyle',       integer (style)));
       Color:=                    ReadInteger ('FontColor',       integer (cl_black));
       ColorSelect:=              ReadInteger ('SelColor',        integer (cl_selectedtext));
       ColorSelectBackground:=    ReadInteger ('SelBgColor',      integer (cl_selectedtextbackground));
     END;
     SetLength (CustPlaces, 0);
     CustPlaces:=                 readarray('filenamescust',      CustPlaces);
////////////////////////////////////////////
     PlacesSetting.checked:=      readboolean ('nopanel',         PlacesSetting.checked);
     CompactSetting.checked:=     readboolean ('compact',         CompactSetting.checked);
     HiddenSetting.checked:=      readboolean ('showhidden',      HiddenSetting.checked);
     HistorySetting.checked:=     readboolean ('hidehistory',     HistorySetting.checked);
     IconsSetting.checked:=       readboolean ('hideicons',       IconsSetting.checked);
     PreviewSetting.checked:=     readboolean ('imagepreview',    PreviewSetting.checked);

     listview.cellwidth:=         readinteger ('filecolwidth',    listview.cellwidth);
     list_log.datacols[0].Width:= readinteger ('colnamewidth',    list_log.datacols [0].Width);
     list_log.datacols[1].Width:= readinteger ('colextwidth',     list_log.datacols [1].Width);
     list_log.datacols[2].Width:= readinteger ('colsizewidth',    list_log.datacols [2].Width);
     list_log.datacols[3].Width:= readinteger ('coldatewidth',    list_log.datacols [3].Width);
     tsplitter1.left:=            readinteger ('splitterlateral', tsplitter1.left);
     tsplitter3.top:=             readinteger ('splitterplaces',  tsplitter3.top);
   END;
   fsplitterpanpos:= tsplitter1.left;

   placescust.rowcount:= succ (Length (CustPlaces));  //// ????
   placescust [0][0]:= '';              // flag place names "column" empty
   FOR i:= 0 TO high (CustPlaces) DO
     placescust [1][i]:= CustPlaces [i];
   SetLength (CustPlaces, 0);          // goes away soon anyway ...

   onswitchcomp (NIL);
   onswitchlateral (NIL);
   onswitchpreview (NIL);
   onswitchvalnoicon (NIL);
   onswitchshowhidden (NIL);

   filename.visible:= NOT HistorySetting.checked;

   IF filename.visible THEN BEGIN
     WITH Filename.dropdown DO
       IF dropdownrowcount > 0
         THEN itemindex:= 0;

     IF Length (fController.ffilenames) > 0 THEN BEGIN
       fselectednames:=  fcontroller.ffilenames;
       filename.value:=  quotefilename (fselectednames);
     END;
   END;
 end;

procedure tfiledialogxfo.StateWrite (const sender: TObject; const writer: tStatWriter);
 VAR
   i:          integer;
   CustPlaces: mseStringArTy;
 begin
   IF sender = self THEN        // I.e. when run "stand alone"
     WITH fController DO BEGIN
////////////////////////////////////////////
       ffilterindex:= self.filter.dropdown.itemindex;
       IF high (ffilenames) = 0 THEN
         self.filename.dropdown.savehistoryvalue (ffilenames [0]);
       IF fdo_chdir IN options THEN
         setCurrentDirmse (listview.directory);
////////////////////////////////////////////
       WriteStatOptions (Writer);  // LastDir, FileHistory, Filter
       WriteStatValue (Writer);    // Filenames, Params (??)
       WriteStatState (Writer);    // Position, Size, FileColWidth
     END (* WITH FController *);

   SetLength (CustPlaces, pred (placescust.rowcount));
   FOR i:= 0 TO high (CustPlaces) DO
     CustPlaces [i]:= placescust [1][i];

   WITH writer DO BEGIN
////////////////////////////////////////////
     WITH Font DO BEGIN
       WriteInteger ('BgColor',       ColorBackground);
       WriteString  ('FontName',      Name);
       WriteInteger ('FontSize',      Height);
       WriteInteger ('FontStyle',     integer (Style));
       WriteInteger ('FontColor',     Color);
       WriteInteger ('SelColor',      ColorSelect);
       WriteInteger ('SelBgColor',    ColorSelectBackground);
     END;
     writearray   ('filenamescust',   CustPlaces); SetLength (CustPlaces, 0);
////////////////////////////////////////////
     writeboolean ('nopanel',         PlacesSetting.checked);
     writeboolean ('compact',         CompactSetting.checked);
     writeboolean ('hidehistory',     HistorySetting.checked);
     writeboolean ('hideicons',       IconsSetting.checked);
     writeboolean ('showhidden',      HiddenSetting.checked);
     writeboolean ('imagepreview',    PreviewSetting.checked);

     writeinteger ('filecolwidth',    listview.cellwidth);
     writeinteger ('colnamewidth',    list_log.datacols [0].Width);
     writeinteger ('colextwidth',     list_log.datacols [1].Width);
     writeinteger ('colsizewidth',    list_log.datacols [2].Width);
     writeinteger ('coldatewidth',    list_log.datacols [3].Width);

     IF PlacesSetting.checked
       THEN writeinteger ('splitterlateral', fsplitterpanpos)
       ELSE writeinteger ('splitterlateral', tsplitter1.left);

     writeinteger ('splitterplaces',  tsplitter3.top);
   END;
 end;
////////////////////////////////////////////

{$ifdef BGRABITMAP_USE_MSEGUI}
function tfiledialogxfo.LoadImagebgra(const AFileName: msestring): msestring;
begin
 tbitmapcomp1.free;
 tbitmapcomp1 := TBGRABitmap.Create(tosysfilepath(AFileName));
// imImage.Bitmap := tbitmapcomp1.bitmap;
  Result := '0' ;
end;
{$else}
function tfiledialogxfo.LoadImage(const AFileName: msestring): msestring;
begin
 result := imImage.bitmap.tryLoadFromFile(tosysfilepath(AFileName));
// if result <> '' then imImage.Bitmap := tbitmapcomp2.bitmap;
end;
{$endif}

procedure tfiledialogxfo.createdironexecute(const Sender: TObject);
var
  mstr1: msestring;
begin
  mstr1 := '';

{$ifdef mse_dynpo}
if length(lang_stockcaption) > ord(sc_name) then
begin
    if stringenter(mstr1, lang_stockcaption[ord(sc_name)],
      lang_stockcaption[ord(sc_create_new_directory)]) = mr_ok then
      begin
      places.defocuscell;
      places.datacols.clearselection;
      mstr1 := filepath(listview.directory, mstr1, fk_file);
      msefileutils.createdir(mstr1);
      changedir(mstr1);
      filename.SetFocus;
    end;
end else
begin
    if stringenter(mstr1, 'Name', 'Create new directory') = mr_ok then
      begin
      places.defocuscell;
      places.datacols.clearselection;
      mstr1 := filepath(listview.directory, mstr1, fk_file);
      msefileutils.createdir(mstr1);
      changedir(mstr1);
      filename.SetFocus;
    end;
end

{$else}
    if stringenter(mstr1, sc(sc_name),
      sc(sc_create_new_directory)) = mr_ok then
     begin
      places.defocuscell;
      places.datacols.clearselection;
      mstr1 := filepath(listview.directory, mstr1, fk_file);
      msefileutils.createdir(mstr1);
      changedir(mstr1);
      filename.SetFocus;
    end;
{$endif}
end;

procedure tfiledialogxfo.listviewselectionchanged(const Sender: tcustomlistview);
var
////////////////////////////////////////////
////  ar1: msestringarty;
////////////////////////////////////////////
  Ext: string;
  i:   integer;
begin
////////////////////////////////////////////
////  ar1 := nil;
////////////////////////////////////////////
  //compiler warning
  if not (fdo_directory in dialogoptions) then
  begin
////////////////////////////////////////////
////    ar1 := listview.selectednames;
////    if length(ar1) > 0 then
////    begin
////      if length(ar1) > 1 then
////        filename.Value := quotefilename(ar1)
////      else
////      begin
////        filename.Value := ar1[0];
////      end;
////    end
////////////////////////////////////////////
    fselectednames := listview.selectednames;
    if length (fselectednames) > 0 then
    begin
      if length (fselectednames) > 1 then
        filename.Value:= quotefilename (fselectednames)
      else
      begin
        filename.Value:= fselectednames [0];
      end;
      realizeselection;
    end
////////////////////////////////////////////
    else
      ////////////////////////////////////////////
      EXIT;   //// Nothing more to do here ---- ????
      ////////////////////////////////////////////
      //   filename.value:= ''; //dir chanaged
    ;
  end;

////////////////////////////////////////////
////   imImage.visible := false;
////   filename.left := 4 ;
////   filename.width := width - 8 ;
////
////  if filename.tag = 1 then
////    filename.Value := dir.Value
////////////////////////////////////////////
////  else                                              //// no images for directories ---- ????
////  if fileexists(dir.Value + filename.Value) then    //// why bother further otherwise ---- ????
////  begin
////
////    Ext:= '.'+ lowercase (FileExt (filename.Value));
////    i:= ImageList;
////    WHILE (ExtIcon [i].Icon = 7) AND (ExtIcon [i].Ext <> Ext) DO Inc (i);
////    {$ifdef BGRABITMAP_USE_MSEGUI}
////    if loadimagebgra(dir.Value + filename.Value) <> '' then
////    {$else}
////    if loadimage(dir.Value + filename.Value) <> '' then
////    {$endif}
////    begin
////      imImage.visible := true;
////      filename.left := imImage.right + 2 ;
////      filename.width := width - imImage.right - 6 ;
////      imImage.invalidate;
////    end
////
////////////!!!!!!!!!!
//////// if (lowercase(fileext(filename.Value)) = 'xpm') or
////////    (lowercase(fileext(filename.Value)) = 'jpeg') or
////////  //   (lowercase(fileext(filename.Value)) = 'ico') or
////////      (lowercase(fileext(filename.Value)) = 'bmp') or
////////      (lowercase(fileext(filename.Value)) ='png') or
////////      (lowercase(fileext(filename.Value)) = 'jpg') then
//////// begin
////////  if fileexists(dir.Value + filename.Value) then
////////  {$ifdef BGRABITMAP_USE_MSEGUI}
////////  if loadimagebgra(dir.Value + filename.Value) <> '' then
////////  {$else}
////////  if loadimage(dir.Value + filename.Value) <> '' then
////////  {$endif}
////////       begin
////////         imImage.visible := true;
////////         filename.left := imImage.right + 2 ;
////////         filename.width := width - imImage.right - 6 ;
////////         imImage.invalidate;
////////      end
////////////////////////////////////////////
////  end;
////////////////////////////////////////////
end;

function tfiledialogxfo.changedir(const adir: filenamety): Boolean;
begin
  Result := tryreadlist(filepath(adir), True);
  if Result then
    course(adir);

  with listview do
    if filelist.Count > 0 then
      focuscell(makegridcoord(0, 0));

end;

procedure tfiledialogxfo.listviewitemevent(const Sender: tcustomlistview; const index: integer; var info: celleventinfoty);
var
  str1: filenamety;
begin
  with tfilelistviewx(Sender) do
    if iscellclick(info) then
      if filelist.isdir(index) then
      begin
        str1 := tosysfilepath(filepath(directory + filelist[index].Name));
        changedir(str1);
      end
      else
      begin
        if info.eventkind = cek_keydown then
          system.exclude(info.keyeventinfopo^.eventstate, es_processed)//do not eat key_return
        ;
        if iscellclick(info, [ccr_dblclick, ccr_nokeyreturn]) and
          (length(fdatacols.selectedcells) = 1) then
          okonexecute(nil);
      end;
end;

procedure tfiledialogxfo.doup();
begin
  listview.updir();
  course(listview.directory);
end;

procedure tfiledialogxfo.listviewonkeydown(const Sender: twidget; var info: keyeventinfoty);
begin
  with info do
    if (key = key_pageup) and (shiftstate = [ss_ctrl]) then
    begin
      doup();
      include(info.eventstate, es_processed);
////////////////////////////////////////////
    END
    ELSE IF key = key_return THEN BEGIN
      okonexecute (Sender);
      window.modalresult:= mr_ok;
////////////////////////////////////////////
    end;
end;

procedure tfiledialogxfo.upaction(const Sender: TObject);
begin
  places.defocuscell;
  places.datacols.clearselection;
  doup();
end;

function tfiledialogxfo.tryreadlist(const adir: filenamety; const errormessage: Boolean): Boolean;
  //restores old dir on error
var
  dirbefore: filenamety;
begin
  dirbefore := listview.directory;
  listview.directory := adir;
  Result := False;
  try
    listview.readlist;
    Result := True;
  except
    on ex: esys do
    begin
      Result := False;
      if errormessage then
{$ifdef mse_dynpo}
if length(lang_stockcaption) > ord(sc_can_not_read_directory) then
          showerror(lang_stockcaption[ord(sc_can_not_read_directory)] + ' ' +
            msestring(esys(ex).Text), lang_stockcaption[ord(sc_error)]) else
         showerror('Can not read directory ' +
            msestring(esys(ex).Text), 'ERROR');
{$else}
          showerror(sc(sc_can_not_read_directory) + ' ' +
            msestring(esys(ex).Text), sc(sc_error));
{$endif}
    end;
    else
    begin
      Result := False;
      application.handleexception(self);
    end;
  end;
  if not Result then
  begin
    listview.directory := dirbefore;
    try
      listview.readlist;
    except
      listview.directory := '';
      listview.readlist;
    end;
  end;
end;

procedure tfiledialogxfo.filenamesetvalue(const Sender: TObject; var avalue: msestring; var accept: Boolean);
var
  str1, str2, str3: filenamety;
  // ar1: msestringarty;
  bo1: Boolean;
  newdir: filenamety;
  theint, theexist : integer;
  sel : gridcoordty;
begin
  newdir := '';
  avalue := trim(avalue);
  unquotefilename(avalue, fselectednames);

  if (fdo_single in dialogoptions) and (high(fselectednames) > 0) then
  begin
{$ifdef mse_dynpo}
if length(lang_stockcaption) > ord(sc_single_item_only) then
      ShowMessage(lang_stockcaption[ord(sc_single_item_only)] +
       '.', lang_stockcaption[ord(sc_error)]) else
      ShowMessage('Single item only.', 'ERROR') ;
{$else}
      ShowMessage(sc(sc_single_item_only) + '.', sc(sc_error));
{$endif}
    accept := False;
    Exit;
  end;
  bo1 := False;
  if high(fselectednames) > 0 then
  begin
    str1 := extractrootpath(fselectednames);
    if str1 <> '' then
    begin
      bo1    := True;
      newdir := str1;
      avalue := quotefilename(fselectednames);
    end;
  end
  else
  begin
    str3   := filepath(listview.directory, avalue);
    splitfilepath(str3, str1, str2);
    newdir := str1;
    if hasmaskchars(str2) then
    begin
      filter.Value  := str2;
      listview.mask := str2;
      str2          := '';
    end
    else if searchfile(str3, True) <> '' then
    begin
      newdir := str3;
      str2   := '';
    end;
    avalue := str2;
    if str2 = '' then
      fselectednames    := nil
    else
    begin
      setlength(fselectednames, 1);
      fselectednames[0] := str2;
    end;
    bo1 := True;
  end;
  if bo1 then
  begin
    if tryreadlist(newdir, not finit) then
      if finit then
      begin
        setlength(fcourse, 1);
        fcourse[0] := newdir;
        fcourseid  := 0;
      end
      else
        course(newdir);
    if fdo_directory in dialogoptions then
      avalue := listview.directory;
  end;
  listview.selectednames := fselectednames;
  theexist := -1;
(*------------------------
  for theint := 0 to list_log.rowcount - 1 do
         if trim(copy(list_log[0][theint], 2, length(list_log[0][theint])))  = str2 then
                 theexist := theint;

  if theexist > 0 then
    begin
        sel.col := 0;
        sel.row := theexist;
////????        fisfixedrow := true;
        list_log.defocuscell;
        list_log.datacols.clearselection;
        list_log.selectcell(sel,csm_select);
        list_log.frame.sbvert.value := theexist/ (list_log.rowcount-1);
      end;
------------------------*)
   places.defocuscell;
   places.datacols.clearselection;
   placescust.defocuscell;
   placescust.datacols.clearselection;

end;

procedure tfiledialogxfo.filepathentered(const Sender: TObject);
begin
  tryreadlist(listview.directory, True);
  // readlist;
  if filename.tag = 1 then
    filename.Value := dir.Value;
end;

procedure tfiledialogxfo.dironsetvalue(const Sender: TObject; var avalue: mseString; var accept: Boolean);
begin
  places.defocuscell;
  places.datacols.clearselection;

  accept := tryreadlist(avalue, True);
  if accept then
    course(avalue);
  listview.directory := avalue;

//////// Is this REALLY useful ???????
 if filename.tag <> 2 then begin // save file
  if filename.tag = 1 then
    filename.Value   := dir.Value
////  else
////    filename.Value   := '';
    end;
end;

procedure tfiledialogxfo.listviewonlistread(const Sender: TObject);
var
  x, x2, y, y2, z: integer;
  fsize : longint;
  {$ifdef unix}
  info: Stat;
   {$else}
  info: fileinfoty;
  {$endif}
  thedir, thestrnum, thestrfract, {thestrx,} thestrext, tmp, tmp2, tmp3: msestring;
begin
////////////////////////////////////////////

  IF listview.rowcount <= 0 THEN exit;  //// Nothing more to do here ...
////////////////////////////////////////////

////////////////////////////////////////////
////  listview.Width := 30;
////  listview.invalidate;
////////////////////////////////////////////
  labtest.Width := 30;
  labtest.invalidate;
////////////////////////////////////////////

  if NOT IconsSetting.checked then
  begin
////////////////////////////////////////////
//    x := 30;
//    labtest.Caption := ' ';
//////!!!!
//    while labtest.Width < x do
//    begin
//      labtest.Caption := labtest.caption + ' ';
//      labtest.invalidate;
//    end;
//
//    tmp2 := labtest.Caption;
////////////////////////////////////////////
    labtest.Caption := ' ';
    tmp2:= StringOfChar (' ', Max (1, pred (30 DIV labtest.Width)));
    labtest.Caption := tmp2;
////////////////////////////////////////////
    tmp3 := '';

  end
  else
    labtest.Caption := ' ';

  tmp2 := labtest.Caption;

  {
  labtest.Caption := ' .';

  while labtest.Width < x do
  begin
    labtest.Caption := labtest.Caption + ' ';
  end;

   labtest.invalidate;
  tmp2 := labtest.Caption;
   }

////////////////////////////////////////////
   IF IconsSetting.checked THEN BEGIN
     labtest.Caption:= 'D |';
     list_log.fixcols [LabelCol].width:= labtest.Width;
   END
   ELSE list_log.fixcols [LabelCol].width:= iconslist.width+ IconFudge;

////////////////////////////////////////////

  with listview do
  begin
    dir.Value        := tosysfilepath(directory);
    if fdo_directory in self.dialogoptions then
      filename.Value := tosysfilepath(directory);
  end;
////////////////////////////////////////////
       listview.rowcount:= listview.filelist.count;   ////!!!!
       list_log.rowcount:= listview.rowcount;

       list_log.fixcols [-1].Captions.Count:= listview.rowcount;  //// for selection ????
////////////////////////////////////////////
//// if list_log.rowcount = listview.rowcount then exit;    //// Data set already ---- ????
//// Zus. Spalte fuer Icons oder Kennung einrichten, nur die umschalten ????

////////////////////////////////////////////
//  list_log.rowcount := listview.rowcount;
//  for x := 0 to listview.rowcount - 1 do
//  begin
//    list_log[0][x] := '';
//    list_log[1][x] := '';
//    list_log[2][x] := '';
//    list_log[3][x] := '';
//////????    list_log[4][x] := '';
//  end;
////////////////////////////////////////////

  y  := 0;
  x2 := 0;

  if listview.rowcount > 0 then
    for x := 0 to listview.rowcount - 1 do
    begin
////????      list_log[4][x] := msestring(IntToStr(x));

////////////////////////////////////////////
     if listview.filelist.count > 0 then begin
////       for x := 0 to listview.rowcount - 1 do
       begin
////////////////////////////////////////////
//// ----         list_log.fixcols [LabelCol].Captions [x]:= inttostr (x);  //// for selection ????
////////////////////////////////////////////
         list_log[NameCol][x] := '';
         list_log[ExtCol][x] := '';
         list_log[SizeCol][x] := '';
         list_log[DateCol][x] := '';
////????    list_log[4][x] := '';
       end;
////////////////////////////////////////////
      if listview.filelist.isdir(x) then
      begin
        Inc(x2);
        if IconsSetting.checked then
          tmp3 := 'D |'
        else
          tmp3 := '.';
////////////////////////////////////////////
////        list_log[NameCol][x] := {tmp3 + tmp2 +} msestring(listview.itemlist[x].Caption);
        list_log.fixcols [LabelCol].Captions [x]:= tmp3;
        list_log [NameCol][x]:= msestring (listview.itemlist [x].Caption);
////////////////////////////////////////////
        list_log[ExtCol][x] := '';
      end
      else
      begin
        if IconsSetting.checked then
          tmp3 := 'F |'
        else
          tmp3 := ':';
//// XXXX zus. Einstellung mit/ohne Extension?
////////////////////////////////////////////
////        list_log[NameCol][x] := tmp3 + tmp2 + msestring(filenamebase(listview.itemlist[x].Caption));
        list_log.fixcols [LabelCol].Captions [x]:= tmp3;
        list_log [NameCol][x]:=  msestring(filenamebase (listview.itemlist [x].Caption));
////////////////////////////////////////////
        tmp := fileext(listview.itemlist[x].Caption);
        if tmp <> '' then
          tmp          := '.' + tmp;
        list_log[ExtCol][x] := msestring(tmp);
        list_log[NameCol][x] := list_log[NameCol][x] + list_log[ExtCol][x];
       {
        if (lowercase(list_log[1][x]) = '.png')
            or (lowercase(list_log[1][x]) = '.jpg')
            or (lowercase(list_log[1][x]) = '.jpeg')
            or (lowercase(list_log[1][x]) = '.bmp') then
            begin
            writeln(dir.Value + listview.itemlist[x].Caption);
            // tbitmapcomp2.bitmap.LoadFromFile(dir.Value + listview.itemlist[x].Caption);
             timagelist2.addimage(tbitmapcomp2.bitmap);
             list_log[5][x] := inttostr(x);
            end;
        }
       end;

      dir.Value := tosysfilepath(dir.Value);

      thedir := tosysfilepath(dir.Value + (listview.itemlist[x].Caption));

        {$ifdef unix}
       FpStat(RawByteString(thedir), info);
        {$else}
         getfileinfo(msestring(trim(thedir)), info);
        {$endif}

      if not listview.filelist.isdir(x) then
      begin
        {$ifdef unix}
        fsize := info.st_size;
        {$else}
         fsize := info.extinfo1.size;
        {$endif}
(*************************
        if fsize div 1000000000 > 0 then
        begin
          y2        := Trunc(Frac(fsize / 1000000000) * Power(10, 1));
          y         := fsize div 1000000000;
          thestrx   := '~';
          thestrext := ' GB ';
        end
        else if fsize div 1000000 > 0 then
        begin
          y2        := Trunc(Frac(fsize / 1000000) * Power(10, 1));
          y         := fsize div 1000000;
          thestrx   := '_';
          thestrext := ' MB ';
        end
        else if fsize div 1000 > 0 then
        begin
          y2        := Trunc(Frac(fsize / 1000) * Power(10, 1));
          y         := fsize div 1000;
          thestrx   := '^';
          thestrext := ' KB ';
        end
        else
        begin
          y2        := 0;
          y         := fsize;
          thestrx   := '!';
          thestrext := ' B ';
        end;
*************************)
        IF fsize > 0
          THEN y:= min (floor (log10 (fsize)) DIV 3, High (sizeSign))
          ELSE y:= 0;

        thestrext:= SizeSign [y].Text;
////        thestrx:= SizeSign [y].Sign;    //// DOES that have any meaning AT ALL ???? It's not used anywhere!
        IF y > 0 THEN BEGIN
          y2:= 10 ** (3* y); y:= fsize DIV y2; y2:= (((10* fsize)+ (y2 DIV 2)) DIV y2) MOD 10;
        END                             //                       ^^^^^^^^^^^ optional rounding
        ELSE BEGIN
          y2:= 0; y:= fsize;
        END;

        thestrnum := msestring(IntToStr(y));

        z := Length(thestrnum);

        if z < 15 then
          for y := 0 to 14 - z do
            thestrnum := ' ' + thestrnum;

        if y2 > 0 then
          thestrfract := '.' + msestring(IntToStr(y2))
        else
          thestrfract := '';

        list_log[SizeCol][x] := {thestrx +} thestrnum + thestrfract + thestrext;  //// looks MUCH cleaner that way!
      end
      else
        list_log[SizeCol][x] := ' ';

      {$ifdef unix}
       list_log[DateCol][x] := msestring(formatdatetime('YY-MM-DD hh:mm:ss', FileDateToDateTime(info.st_mtime)));
      {$else}
      list_log[DateCol][x] := msestring(formatdatetime('YY-MM-DD hh:mm:ss', info.extinfo1.modtime));
      {$endif}

      if listview.filelist.isdir(x) then
        list_log[DateCol][x] := ' ' + list_log[DateCol][x];
    end; // else dir.frame.caption := 'Directory with 0 files';

////////////////////////////////////////////
    //// NO files selected here yet ---- ????
////    SetLength (fselectednames, 0);
    listview.selectednames:= fselectednames;
    list_log.datacols.clearselection;
////////////////////////////////////////////

    if CompactSetting.checked then
    begin
      listview.Width := list_log.Width;
      listview.invalidate;
    end;

////----  list_log.defocuscell;
////----  list_log.datacols.clearselection;

 // dir.frame.Caption := 'Directory with ' + msestring(IntToStr(list_log.rowcount - x2)) + ' files';

//////// Is this REALLY useful ???????
    if filename.tag <> 2 then begin // save file
      if filename.tag = 1 then
        filename.Value := (dir.Value)
////      else
////        filename.Value := '';
    end;

    filename.Value := tosysfilepath(filename.Value);

////////////////////////////////////////////
  end;
////////////////////////////////////////////
end;

procedure tfiledialogxfo.updatefiltertext;
begin
  with filter, dropdown do
    if ItemIndex >= 0 then
    begin
      Value         := cols[0][ItemIndex];
      listview.mask := cols[1][ItemIndex];
    end;
end;

procedure tfiledialogxfo.filteronafterclosedropdown(const Sender: TObject);
begin
  updatefiltertext;
  filter.initfocus;
//  filter.left  := 422;
//  filter.Width := 182;
  //filter.frame.Caption := '&Filter';
end;

procedure tfiledialogxfo.filteronsetvalue(const Sender: TObject; var avalue: msestring; var accept: Boolean);
var
  rootdir: msestring;
  bool: Boolean;
begin

  listview.mask := avalue;
  rootdir       := dir.Value;

  bool := True;

////----  list_log.defocuscell;
////----  list_log.datacols.clearselection;

  dironsetvalue(Sender, rootdir, bool);

////????  fisfixedrow := True;

////----  list_log.defocuscell;
////----  list_log.datacols.clearselection;
////////////////////////////////////////////
  list_log.row:= -1; listview.row:= -1;
////////////////////////////////////////////
end;

procedure tfiledialogxfo.okonexecute(const Sender: TObject);
var
  bo1: Boolean;
  int1: integer;
  str1: filenamety;
begin
  if (filename.Value <> '') or (fdo_acceptempty in dialogoptions) or (filename.tag = 1) then
  begin

     if (fdo_directory in dialogoptions) or (filename.tag = 1) then
      str1 := tosysfilepath(quotefilename(listview.directory))
    else
    begin
      str1 := tosysfilepath(quotefilename(listview.directory, filename.Value));
    end;
    unquotefilename(str1, Controller.ffilenames);
    if (fController.defaultext <> '') then
      for int1 := 0 to high(fController.filenames) do
        if not hasfileext(fController.filenames[int1]) then
          fController.filenames[int1] := tosysfilepath(fController.filenames[int1] + '.' + fController.defaultext);
    if (fdo_checkexist in dialogoptions) and not ((filename.Value = '') and (fdo_acceptempty in dialogoptions)) then
    begin
      if fdo_directory in dialogoptions then
        bo1 := finddir(tosysfilepath(fController.filenames[0]))
      else
        bo1 := findfile(tosysfilepath(fController.filenames[0]));
      if fdo_save in dialogoptions then
      begin
        if bo1 then
{$ifdef mse_dynpo}
if length(lang_stockcaption) > ord(sc_file) then
  begin
           if not askok(lang_stockcaption[ord(sc_file)]  + ' "' + tosysfilepath(filenames[0]) +
              '" ' + lang_stockcaption[ord(sc_exists_overwrite)],
              lang_stockcaption[ord(sc_warningupper)]) then
            begin
              filename.SetFocus;
              Exit;
            end;
   end else
   begin
           if not askok('File "' + tosysfilepath(filenames[0]) +
              '" exists, do you want to overwrite?',
              'WARNING') then
            begin
              filename.SetFocus;
              Exit;
            end;
   end;


{$else}
           if not askok(sc(sc_file)  + ' "' + tosysfilepath(fController.filenames[0]) +
              '" ' + sc(sc_exists_overwrite),
              sc(sc_warningupper)) then
          begin
             filename.SetFocus;
             Exit;
            end;

{$endif}

      end
      else if not bo1 then
      begin
{$ifdef mse_dynpo}
if length(lang_stockcaption) > ord(sc_file) then
             showerror(lang_stockcaption[ord(sc_file)] + ' "' + tosysfilepath(fController.filenames[0]) + '" ' +
            lang_stockcaption[ord(sc_does_not_exist)] + '.',
            uppercase(lang_stockcaption[ord(sc_error)]))
            else
             showerror('File "' + tosysfilepath(filenames[0]) +
            '" does not exist.',
            'ERROR');

{$else}
             showerror(sc(sc_file) + ' "' + tosysfilepath(fController.filenames[0]) + '" ' +
            sc(sc_does_not_exist) + '.',
            uppercase(sc(sc_error)));
{$endif}
        //      showerror('File "'+filenames[0]+'" does not exist.');
        filename.SetFocus;
        Exit;
      end;
    end;
    window.modalresult := mr_ok;
  end
  else
if filename.value <> '' then {????}    filename.SetFocus;
  // end;
end;

procedure tfiledialogxfo.layoutev(const Sender: TObject);
begin
  listview.synctofontheight;
end;

////////////////////////////////////////////
procedure tfiledialogxfo.onswitchpreview (const Sender: TObject);
////var
////  fakebool: boolean;
 begin
   showpreview;
////  fakebool:= PreviewSetting.checked;
////  bimgpreview:= fakebool;  // avalue;
 end;
////////////////////////////////////////////
////procedure tfiledialogxfo.onswitchhidehistory (const Sender: TObject);
////var
////  fakebool: boolean;
////begin
////  fakebool:= HistorySetting.checked;  // showhidden.value;
//////  showhiddenonsetvalue (Sender, fakebool, fakebool {not used?});
////  bhidehistory:= fakebool;  // avalue;
////end;
////////////////////////////////////////////
procedure tfiledialogxfo.onswitchshowhidden (const Sender: TObject);
var
  fakebool: boolean;
begin
  fakebool:= HiddenSetting.checked;  // showhidden.value;
  showhiddenonsetvalue (Sender, fakebool, fakebool {not used});
end;
////////////////////////////////////////////

procedure tfiledialogxfo.showhiddenonsetvalue(const Sender: TObject; var avalue: Boolean; var accept: Boolean);
begin
  {showhidden}HiddenSetting.checked:= avalue;

  dir.showhiddenfiles      := avalue;
  if avalue then
    listview.excludeattrib := listview.excludeattrib - [fa_hidden]
  else
    listview.excludeattrib := listview.excludeattrib + [fa_hidden];
  listview.readlist;
  accept:= true;
end;

procedure tfiledialogxfo.dirshowhint(const Sender: TObject; var info: hintinfoty);
begin
  if dir.editor.textclipped then
    info.Caption := dir.Value;
end;

procedure tfiledialogxfo.copytoclip(const Sender: TObject; var avalue: msestring);
begin
  tosysfilepath1(avalue);
end;

procedure tfiledialogxfo.pastefromclip(const Sender: TObject; var avalue: msestring);
begin
  tomsefilepath1(avalue);
end;

procedure tfiledialogxfo.homeaction(const Sender: TObject);
begin
  places.defocuscell;
  places.datacols.clearselection;
  if tryreadlist(sys_getuserhomedir, True) then
  begin
    dir.Value := tosysfilepath(listview.directory);
    course(listview.directory);
  end;
end;

procedure tfiledialogxfo.checkcoursebuttons();
begin
  back.Enabled    := fcourseid > 0;
  forward.Enabled := fcourseid < high(fcourse);
end;

procedure tfiledialogxfo.course(const adir: filenamety);
begin
  if not fcourselock then
  begin
    Inc(fcourseid);
    setlength(fcourse, fcourseid + 1);
    fcourse[fcourseid] := adir;
    checkcoursebuttons();
  end;
end;

procedure tfiledialogxfo.backexe(const Sender: TObject);
begin
  places.defocuscell;
  places.datacols.clearselection;

  fcourselock := True;
  try
    Dec(fcourseid);
    if changedir(fcourse[fcourseid]) then
      checkcoursebuttons()
    else
      Inc(fcourseid);
  finally
    fcourselock := False;
  end;
end;

procedure tfiledialogxfo.forwardexe(const Sender: TObject);
begin
  places.defocuscell;
  places.datacols.clearselection;

  fcourselock := True;
  try
    Inc(fcourseid);
    if changedir(fcourse[fcourseid]) then
      checkcoursebuttons()
    else
      Dec(fcourseid);
  finally
    fcourselock := False;
  end;
end;

procedure tfiledialogxfo.buttonshowhint(const Sender: TObject; var ainfo: hintinfoty);
begin
  with tcustombutton(Sender) do
{$ifdef mse_dynpo}
if length(lang_stockcaption) > ord(tag) then
    ainfo.Caption := lang_stockcaption[ord(stockcaptionty(tag))] +
      ' (' + encodeshortcutname(shortcut) + ')' else
    ainfo.Caption := 'Tag (' + encodeshortcutname(shortcut) + ')' ;
{$else}
    ainfo.Caption := sc(stockcaptionty(tag)) +
      ' (' + encodeshortcutname(shortcut) + ')';
{$endif}

end;

////////////////////////////////////////////
PROCEDURE tfiledialogxfo.showpreview;
//// to be called with single regular file selected ONLY !!!!
 VAR
   i:   integer = 0;
   Ext: filenamety;
 BEGIN
   //// Check whether a preview image should be displayed (just for safety)
   IF PreviewSetting.checked AND
      (Length (fselectednames) = 1) AND
      NOT listview.filelist.isdir (list_log.datacols.selectedrows [0])
   THEN BEGIN
     IF fileexists (dir.Value+ filename.Value) THEN BEGIN
       Ext:= lowercase (list_log [ExtCol][list_log.datacols.selectedrows [0]]);
       i:= ImageList;
       WHILE (ExtIcon [i].Icon = 7) AND (ExtIcon [i].Ext <> Ext) DO Inc (i);
       IF (ExtIcon [i].Icon = 7) AND
          {$ifdef BGRABITMAP_USE_MSEGUI}
          (loadimagebgra (dir.Value+ filename.Value) <> '')
          {$else}
          (loadimage (dir.Value+ filename.Value) <> '')
          {$endif}
       THEN BEGIN   //// image file found
         imImage.visible:= true;
         filename.left:= imImage.right+ 2;
         filename.width:= width- imImage.right- 6;
         imImage.invalidate;
         i:= 7;
       END
       ELSE i:= 0;  //// flag no such image
     END;
   END;
   //// no such image, file not found, or is directory
   IF i = 0 THEN BEGIN
     //// Remove preview image field
     imImage.visible:= false;
     filename.left:= 4;
     filename.width:= width- 8;
   END;
 END;

procedure tfiledialogxfo.oncellev (const Sender: TObject; var info: celleventinfoty);
////////////////////////////////////////////
//// celleventinfoty = record //same layout as ificelleventinfoty
////   cell: gridcoordty;
////   grid: tcustomgrid;
////
////   case eventkind: celleventkindty of
////    cek_exit, cek_enter, cek_focusedcellchanged:
////       (cellbefore,
////        newcell: gridcoordty;
////        selectaction: focuscellactionty);
////    cek_select:
////       (selected: boolean;
////        accept: boolean);
////    cek_mousemove, cek_mousepark, cek_firstmousepark, cek_buttonpress, cek_buttonrelease:
////       (zone: cellzonety;
////        mouseeventinfopo: pmouseeventinfoty;
////        gridmousepos: pointty);
////    cek_keydown, cek_keyup:
////       (keyeventinfopo: pkeyeventinfoty);
//// end;
////
//// keyeventinfoty = record
////  eventkind: eventkindty;
////  key,keynomod: keyty;
////  chars: msestring;
////  shiftstate: shiftstatesty;
////  eventstate: eventstatesty;
////  timestamp: longword; //usec
////  serial: card32; //0 -> invalid
//// end;
////
//// mouseeventinfoty = record //same layout as mousewheeleventinfoty!
////  eventkind: eventkindty;
////  shiftstate: shiftstatesty;
////  pos: pointty;
////  eventstate: eventstatesty;
////  timestamp: longword; //usec, 0 -> invalid
////  serial: card32; //0 -> invalid
////  button: mousebuttonty;
//// end;
////
////////////////////////////////////////////
//// From "tdatacols":
////   property selectedrowcount: int32 read fselectedrowcount;
////   function hascolselection: boolean;
////   property selectedrows: integerarty read getselectedrows write setselectedrows;
////////////////////////////////////////////
////  var
////   y: integer;
////  cellpos{, cellpos2}: gridcoordty;
////i, k,
////  y: integer;
////  str1: msestring;
 VAR
   i: integer;
   r: gridcoordty;

 PROCEDURE activateSelection (selection: integerarty);
  BEGIN
    IF Length (fselectednames) > 0
    THEN filename.value:= quotefilename (fselectednames);
    listview.selectednames:= fselectednames;
    list_log.datacols.selectedrows:= selection;
    IF PreviewSetting.checked AND (Length (selection) = 1) THEN showpreview;
  END;

 PROCEDURE changeSelection (atRow: integer; single: boolean);
  VAR
    i, k:      integer;
    newfile:   msestring;
    selection: integerarty;
  BEGIN
    IF single THEN BEGIN
      setLength (fselectednames, 0); realizeselection;
    END;
    setLength (selection, 0);
    FOR i:= 0 TO pred (list_log.rowcount) DO BEGIN
      IF NOT listview.filelist.isdir (i) THEN BEGIN
        newfile:= list_log [NameCol][i];
        k:= finditem (fselectednames, newfile);
        IF i = atRow THEN BEGIN   // current row, check selection
          IF k >= 0 THEN                  // already selected, remove
            deleteitem (fselectednames, k)
          ELSE BEGIN                      // select newly
            additem (selection, i); additem (fselectednames, newfile);
          END;
        END
        ELSE                              // just transfer selection
          IF k >= 0 THEN additem (selection, i);   // add to selection
      END;
    END;
    activateSelection (selection);
  END;

 PROCEDURE BlockSelection;
  VAR
    i:         integer;
    selection: integerarty;
  BEGIN
////????
    IF NOT (co_multiselect IN List_Log.dataCols.Options)
////????
    THEN changeSelection (info.cell.row, true)
////????
    ELSE
    WITH info DO BEGIN
      IF Length (fselectednames) >= 1 THEN BEGIN
        i:= finditem (list_log.datacols [NameCol].datalist.asStringArray, fselectednames [0]);
      END
      ELSE i:= cell.row;

      IF Length (fselectednames) = 0 THEN BEGIN
        //// no selection yet, assume start point in directory area
        setLength (selection, 0);
        i:= 0;
        FOR i:= i TO cell.row DO        //// select all rows in block
          IF NOT listview.filelist.isdir (i) THEN BEGIN
            additem (selection, i); additem (fselectednames, list_log [NameCol][i]);
          END;

        activateSelection (selection);
      END
      ELSE
      IF (Length (fselectednames) >= 1) AND (i <> cell.row)
      THEN BEGIN
        //// no selection yet, assume start point in directory area or
        //// single selection only and not current row ----
        //// select all entries between current and selected one
        setLength (fselectednames, 0); setLength (selection, 0);

        IF i > cell.row THEN BEGIN      //// must change direction
          FOR i:= i DOWNTO cell.row DO  //// select all rows in block
            IF NOT listview.filelist.isdir (i) THEN BEGIN
              additem (selection, i); additem (fselectednames, list_log [NameCol][i]);
            END;
        END
        ELSE                      
          FOR i:= i TO cell.row DO      //// select all rows in block
            IF NOT listview.filelist.isdir (i) THEN BEGIN
              additem (selection, i); additem (fselectednames, list_log [NameCol][i]);
            END;

        activateSelection (selection);
      END
      ELSE BEGIN
        //// multiple selection existing ----- clear and select current entry
        changeSelection (cell.row, true);
      END;
    END;
  END;

 PROCEDURE multiselect_down;
  BEGIN
////????
    IF NOT (co_multiselect IN List_Log.dataCols.Options)
////????
    THEN changeSelection (info.cell.row, true)
////????
    ELSE
    WITH info DO BEGIN
      // if cell "outside" is unselected: unselect current cell
      IF Length (fselectednames) > 1 THEN BEGIN
        IF (cell.row = 0) OR listview.filelist.isdir (pred (cell.row)) OR
           (finditem (fselectednames, list_log [NameCol][pred (cell.row)]) < 0)
        THEN BEGIN                                        // switched direction?
          i:= finditem (fselectednames, list_log [NameCol][cell.row]);
          IF i >= 0 THEN deleteitem (fselectednames, i);  // already selected, remove
        END;
      END;
      // Now, add the "new" cell to the selection
      IF cell.row < pred (list_log.rowcount)
      THEN Inc (cell.row);
      // if cell "outside" is selected: select current cell
      IF listview.filelist.isdir (pred (cell.row)) OR
         (finditem (fselectednames, list_log [NameCol][pred (cell.row)]) >= 0)
      THEN IF finditem (fselectednames, list_log [NameCol][cell.row]) < 0
        THEN additem (fselectednames, list_log [NameCol][cell.row]);
    END;
  END;

 PROCEDURE multiselect_up;
  BEGIN
////????
    IF NOT (co_multiselect IN List_Log.dataCols.Options)
////????
    THEN changeSelection (info.cell.row, true)
////????
    ELSE
    WITH info DO BEGIN
      // if cell "outside" is unselected: unselect current cell
      IF listview.filelist.isdir (pred (cell.row)) THEN BEGIN
        IF NOT (ss_shift IN keyeventinfopo^.shiftstate)
        THEN setLength (fselectednames, 0);
      END
      ELSE
      IF Length (fselectednames) > 1 THEN BEGIN
        IF (cell.row >= pred (list_log.rowcount)) OR
           (finditem (fselectednames, list_log [NameCol][succ (cell.row)]) < 0)
        THEN BEGIN                                        // switched direction?
          i:= finditem (fselectednames, list_log [NameCol][cell.row]);
          IF i >= 0 THEN deleteitem (fselectednames, i);  // already selected, remove
        END;
      END;
      // Now, add the "new" cell to the selection
      IF (cell.row > 0) AND (NOT listview.filelist.isdir (pred (cell.row)))
      THEN Dec (cell.row);
      // if cell "outside" is selected: select current cell
      IF finditem (fselectednames, list_log [NameCol][succ (cell.row)]) >= 0
        THEN IF finditem (fselectednames, list_log [NameCol][cell.row]) < 0
        THEN additem (fselectednames, list_log [NameCol][cell.row]);
    END;
  END;

BEGIN
  IF (list_log.rowcount > 0) AND (info.cell.row > -1) THEN BEGIN
//    IF info.eventkind = cek_select THEN BEGIN    //// does never occur ---- ????
//      IF info.selected {row selected} THEN BEGIN  // deselect
//      END
//      ELSE BEGIN  // select new
//      END;
//      //// propagate selection to listview
//    END
//    ELSE

////    list_log.beginUpdate;  //// not really neccessary, but do it anyway ...

    WITH info DO
      CASE eventkind OF
        cek_buttonpress:  ;   //// no action to take ---- ????
        cek_buttonrelease:
          IF listview.filelist.isdir (cell.row) THEN BEGIN
            (**** >>>> change directory key <<<< ****)
            changedir (tosysfilepath (filepath (dir.Value+ list_log [NameCol][cell.row])));  ////str1);
          END
          ELSE BEGIN
            IF ss_double in mouseeventinfopo^.shiftstate THEN BEGIN
              IF Length (fselectednames) = 0 THEN  (* no selection yet *)
                changeselection (info.cell.row, false);           // select current file
              okonexecute (Sender);
            END
            ELSE IF mouseeventinfopo^.shiftstate = [{clicked?}] THEN BEGIN
              (**** >>>> new selection action <<<< ****)
              changeSelection (info.cell.row, true);
              WITH mouseeventinfopo^ DO
                eventstate:= eventstate+ [es_processed];  // make mouse action invalid
            END
            ELSE IF mouseeventinfopo^.shiftstate = [ss_ctrl]  THEN BEGIN
              (**** >>>> add selection action <<<< ****)
              changeSelection (info.cell.row, NOT (co_multiselect IN List_Log.dataCols.Options));
              WITH mouseeventinfopo^ DO
                eventstate:= eventstate+ [es_processed];  // make mouse action invalid
            END
            ELSE IF mouseeventinfopo^.shiftstate = [ss_shift]  THEN BEGIN
              (**** >>>> block selection action <<<< ****)
              IF cell.row >= 0 THEN BlockSelection;
              WITH mouseeventinfopo^ DO
                eventstate:= eventstate+ [es_processed];  // make mouse action invalid
            END
            ELSE realizeSelection;
          END;
        cek_keydown {press}:
          BEGIN
            IF listview.filelist.isdir (cell.row) THEN
              CASE keyeventinfopo^.key OF
                key_return:
                  WITH keyeventinfopo^ DO
                    eventstate:= eventstate+ [es_processed];    // make key invalid
                key_pagedown:
                  IF keyeventinfopo^.shiftstate = [ss_shift]
                    (**** >>>> block selection key <<<< ****)
                    THEN setLength (fselectednames, 0);
                key_down:
                  IF NOT (keyeventinfopo^.shiftstate = [ss_shift])
                  THEN setLength (fselectednames, 0);
                key_up:
                  IF (NOT (keyeventinfopo^.shiftstate = [ss_shift])) AND
                     (Length (fselectednames) = 1)
                  THEN BEGIN
                    // when got here, must have reached upermost file entry
                    setLength (fselectednames, 0); i:= 0;
                    WHILE (listview.filelist.isdir (i)) AND (i < list_log.rowcount)  DO Inc (i);
                    IF i < list_log.rowcount THEN BEGIN
                      additem (fselectednames, list_log [NameCol][i]);
                      filename.value:= quotefilename (fselectednames);
                    END;
                  END;
              END
            ELSE
            CASE keyeventinfopo^.key OF
              key_space:                                   //// ignore here
                WITH keyeventinfopo^ DO
                  eventstate:= eventstate+ [es_processed];      // make key invalid
              key_down:
                IF keyeventinfopo^.shiftstate = [{none}] THEN BEGIN
                  setLength (fselectednames, 0);
                END
                // ELSE IF keyeventinfopo^.shiftstate = [ss_ctrl] THEN BEGIN
                // END
                // ELSE IF keyeventinfopo^.shiftstate = [ss_shift] THEN BEGIN -- or
                ELSE IF ss_shift IN keyeventinfopo^.shiftstate THEN BEGIN
                  IF co_multiselect IN List_Log.dataCols.Options THEN BEGIN
                    multiselect_down;
                  END
                  ELSE  BEGIN
                    setLength (fselectednames, 0);
                  END;
                END;
              key_up:
                IF keyeventinfopo^.shiftstate = [{none}] THEN BEGIN
                  setLength (fselectednames, 0);
                END
                // ELSE IF keyeventinfopo^.shiftstate = [ss_ctrl] THEN BEGIN
                // END
                // ELSE IF keyeventinfopo^.shiftstate = [ss_shift] THEN BEGIN -- or
                ELSE IF ss_shift IN keyeventinfopo^.shiftstate THEN BEGIN
                  IF co_multiselect IN List_Log.dataCols.Options THEN BEGIN
                    multiselect_up;
                  END
                  ELSE  BEGIN
                    setLength (fselectednames, 0);
                  END;
                END;
              ELSE
            END (* CASE keyeventinfopo^.key *);
          END;
        cek_keyup {release}:
          IF listview.filelist.isdir (cell.row) THEN BEGIN
            CASE keyeventinfopo^.key OF
              key_return:
                BEGIN
                  (**** >>>> change directory key <<<< ****)
                  changedir (tosysfilepath (filepath (dir.Value+ list_log [NameCol][info.cell.row])));  ////str1);
                END;
              key_pageup:
                IF keyeventinfopo^.shiftstate = [ss_ctrl] THEN BEGIN
                  (**** >>>> directory up key <<<< ****)
                  doup ();
                  WITH info.keyeventinfopo^ DO
                    eventstate:= eventstate+ [es_processed];  // make key invalid
                END
                ELSE IF keyeventinfopo^.shiftstate = [ss_shift] THEN BEGIN
                  (**** >>>> block selection key <<<< ****)
                  BlockSelection;
                END
                ELSE changeSelection (info.cell.row, true);
              key_down,
              key_up:
                BEGIN
                  IF keyeventinfopo^.shiftstate = [{none}]
                  THEN setLength (fselectednames, 0);
                  realizeselection;
                END;
              ELSE
            END (* CASE keyeventinfopo^.key *);
          END
          ELSE BEGIN
            CASE keyeventinfopo^.key OF
              key_space:
                // listview function:
                // shiftstate = []:                  select current cell
                // shiftstate = [ss_ctrl]:           switch current cell state
                // shiftstate = [ss_shift]:          no action
                // shiftstate = [ss_ctrl, ss_shift]: execute
                //
                BEGIN
                  IF info.keyeventinfopo^.shiftstate = [{none}] THEN BEGIN
                    (**** >>>> new selection key <<<< ****)
                    changeSelection (info.cell.row, true);
                  END
                  ELSE IF info.keyeventinfopo^.shiftstate = [ss_ctrl] THEN BEGIN
                     (**** >>>> add selection key <<<< ****)
                     changeSelection (info.cell.row, NOT (co_multiselect IN List_Log.dataCols.Options));
                  END
                  ELSE realizeselection;

                  IF info.keyeventinfopo^.shiftstate <> [ss_ctrl, ss_shift] THEN
                    WITH info.keyeventinfopo^ DO
                      eventstate:= eventstate+ [es_processed];  // make key invalid
                END;
              key_return:
                BEGIN
                  IF info.keyeventinfopo^.shiftstate = [{none}] THEN BEGIN
                    (**** >>>> execute action key <<<< ****)
                    IF Length (fselectednames) = 0 THEN  (* no selection yet *)
                      changeselection (info.cell.row, false);           // select current file
                    okonexecute (Sender);
                  END
                  ELSE realizeselection;

                  WITH info.keyeventinfopo^ DO
                    eventstate:= eventstate+ [es_processed];  // make key invalid
                END;
              key_home,
              key_end:
                IF info.keyeventinfopo^.shiftstate = [ss_ctrl]
                THEN changeSelection (info.cell.row, true);
              key_pagedown:
                IF keyeventinfopo^.shiftstate = [ss_shift] THEN BEGIN
                  (**** >>>> block selection key <<<< ****)
                  BlockSelection;
                END
                ELSE changeSelection (info.cell.row, true);
              key_pageup:
                IF keyeventinfopo^.shiftstate = [ss_ctrl] THEN BEGIN
                  (**** >>>> directory up key <<<< ****)
                  doup ();
                END
                ELSE IF keyeventinfopo^.shiftstate = [ss_shift] THEN BEGIN
                  (**** >>>> block selection key <<<< ****)
                  BlockSelection;
                END
                ELSE changeSelection (info.cell.row, true);
              key_down, ////:
              key_up:
                BEGIN
                  IF (keyeventinfopo^.shiftstate = [ss_shift]) AND (length (fselectednames) = 0)
                  THEN BlockSelection
                  ELSE
                    IF finditem (fselectednames, list_log [NameCol][cell.row]) < 0
                    THEN additem (fselectednames, list_log [NameCol][cell.row]);

                  filename.value:= quotefilename (fselectednames);
                  realizeselection;
                END;
              ELSE
            END (* CASE keyeventinfopo^.key *);
          END;
        ELSE          ;   //// no action to take ---- ????
      END (* CASE eventkind *);

    list_log.invalidate;
////    list_log.endUpdate;   //// undo begin of this
  END;
////////////////////////////////////////////
///////////////// old code: ////////////////
////  if (list_log.rowcount > 0) and
////     ((info.eventkind = cek_buttonrelease) or (info.eventkind = cek_keyup))
////  then
////    if (info.cell.row > -1) then
////    begin
////////????      if ((listview.visible) AND (listview.row >= 0)) OR
////////????         ((list_log.visible) AND (list_log.row >= 0)) THEN   ////???? OR
////      IF ////???? ((listview.visible) AND (listview.row IN [0..pred (listview.rowcount)])) OR
////         ((list_log.visible) AND (list_log.row IN [0..pred (list_log.rowcount)])) THEN
////////????         (fisfixedrow = False) then
////      begin
////        cellpos := info.cell;
////        cellpos.col := 0;
////////????        cellpos2.col := 0;
////        places.defocuscell;
////        places.datacols.clearselection;
//////// ???? WHAT SHOULD  T H A T  EFFECT ????
////////????        y := StrToInt(ansistring(list_log[4][cellpos.row]));
////        y:= cellpos.row;
////////????        cellpos2.row := y;
////
////        if listview.filelist.isdir(y) then
////        begin
////          listview.defocuscell;
////////----          listview.datacols.clearselection;
////          str1 := tosysfilepath(filepath(dir.Value + listview.filelist[y].Name));
////
////          if (info.eventkind = cek_buttonrelease) then
////          begin
////            if (ss_double in info.mouseeventinfopo^.shiftstate) then
////              okonexecute(Sender)
////            else
////            begin
////              changedir(str1);
////
////////               if filename.tag <> 2 then  // save file
////////              filename.Value := '';
////            end;
////          end
////          else if info.keyeventinfopo^.key = key_return then
////          begin
////            changedir(str1);
////////            if filename.tag <> 2 then  // save file
////////            filename.Value := '';
////          end;
////        end
////        else
////        begin
////          listview.defocuscell;
////////----          listview.datacols.clearselection;
////////          listview.selectcell(cellpos2, csm_select, False);
////
////////////////////////////////////////////////
////
////str1:= trim (copy (list_log.datacols [0][y], 2, length (list_log.datacols [0][y])));
////
////WITH listview DO
////for y:= 0 to high (selectednames) do writeln (y:2, ':: ', selectednames [y]);
////y:= cellpos.row;
////
////WITH listview DO
////writeln (str1, ': ', finditem (selectednames, str1) < 0);
////
////          WITH listview DO
////            IF finditem (selectednames, str1) < 0  // not included
////            THEN selectcell (cellpos{2}, csm_select,   lvo_multiselect IN options)
////            ELSE selectcell (cellpos{2}, csm_deselect, lvo_multiselect IN options);
////////////////////////////////////////////////
////
////          if (info.eventkind = cek_buttonrelease) then
////          begin
////            if (listview.rowcount > 0) and (list_log.rowcount > 0) and
////              (not listview.filelist.isdir(y)) and
////              (ss_double in info.mouseeventinfopo^.shiftstate) then
////              okonexecute(Sender);
////          end
////          else if (listview.rowcount > 0) and (list_log.rowcount > 0) and
////            (not listview.filelist.isdir(y)) and
////            (info.keyeventinfopo^.key = key_return) then
////            okonexecute(Sender);
////////////////////////////////////////////////
////
////////          WITH listview DO BEGIN
////////            FOR y:= 0 TO pred (rowcount) DO
///////////////              IF listview.itemlist [y].Caption = list_log [0{filename field}][y]
////////              IF itemlist [y].selected
////////              THEN list_log.datacols [0].selected [y];
////////          END;
////////          list_log.invalidate;
////
////////////////////////////////////////////////
////
////
////////////////////////////////////////////////
////writeln ('oncellev (selected): ', length (listview.selectednames));
////      WITH list_log DO BEGIN
////        datacols.clearselection; i:= 0; k:= 0;
////        WHILE (i < datacols.Count) AND (k < Length (listview.selectednames)) DO BEGIN
////          IF datacols [0][i] = listview.selectednames [k] THEN BEGIN
////            datacols.rowselected [i]:= true; Inc (k);
////writeln ('oncellev: ', datacols [0][i], ' - ', datacols.rowselected [i]);
////          END;
////          Inc (i);
////        END;
////      END;
////////////////////////////////////////////////
////
////
////        end;
////
////        dir.Value        := tosysfilepath(dir.Value);
////        if filename.tag = 1 then
////          filename.Value := dir.Value;
////        filename.Value := tosysfilepath(filename.Value);
////
////////----      end
////////----      else
////////----      begin
////////----        listview.defocuscell;
////////----        listview.datacols.clearselection;
////////----        list_log.defocuscell;
////////----        list_log.datacols.clearselection;
////////----////????        fisfixedrow := False;
////      end;
////    end
////////????    else
////////????      fisfixedrow := True;
end;

procedure tfiledialogxfo.ondrawcell(const Sender: tcol; const Canvas: tcanvas; var cellinfo: cellinfoty);
var
  i,
  aicon: integer;
  apoint: pointty;
  recti: rectty;
  // tbitmapcompico: tbitmapcomp;
   thefilename : msestring;
   Ext:    String;
begin
 if list_log.visible then
 begin
   IF NOT IconsSetting.checked THEN BEGIN
     Ext:= List_Log [ExtCol][cellinfo.cell.row];

     IF (trim (Ext) <> '') OR (trim (List_Log [SizeCol][cellinfo.cell.row]) <> '')
     THEN BEGIN
       i:= 0; Ext:= lowercase (List_Log [ExtCol][cellinfo.cell.row]);
       WHILE (i < {ExtCount}High  (ExtIcon)) AND (Ext <> ExtIcon [i].Ext) DO Inc (i);
       aicon:= abs (ExtIcon [i].Icon);
     END (* IF (trim (Ext) <> '') OR ... *)
     ELSE aicon := 0;
(*************************
  if bnoicon.Value = False then
  begin

    if (trim(list_log[1][cellinfo.cell.row]) = '') and (trim(list_log[2][cellinfo.cell.row]) = '') then
      aicon := 0
    else if (lowercase(list_log[1][cellinfo.cell.row]) = '.txt') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.pdf') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.ini') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.md') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.html') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.inc') then
      aicon := 2
    else if (lowercase(list_log[1][cellinfo.cell.row]) = '.pas') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.lpi') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.lpr') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.prj') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.pp') then
      aicon := 8
    else if (lowercase(list_log[1][cellinfo.cell.row]) = '.lps') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.mfm') then
      aicon := 9
    else if (lowercase(list_log[1][cellinfo.cell.row]) = '.java') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.js') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.class') then
      aicon := 10
    else if (lowercase(list_log[1][cellinfo.cell.row]) = '.c') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.cc') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.cpp') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.h') then
      aicon := 11
    else if (lowercase(list_log[1][cellinfo.cell.row]) = '.py') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.pyc') then
      aicon := 12
    else if (lowercase(list_log[1][cellinfo.cell.row]) = '.wav') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.m4a') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.mp3') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.opus') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.flac') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.ogg') then
      aicon := 3
    else if (lowercase(list_log[1][cellinfo.cell.row]) = '.avi') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.mp4') then
      aicon := 4
    else if
      (lowercase(list_log[1][cellinfo.cell.row]) = '.ico') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.webp') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.tiff') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.svg') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.gif') then
      aicon := 7
      else if (lowercase(list_log[1][cellinfo.cell.row]) = '.png') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.jpeg') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.bmp') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.jpg') then
      aicon := 7 // 13 for icons in grid
      else if (lowercase(list_log[1][cellinfo.cell.row]) = '') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.exe') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.dbg') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.com') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.bat') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.bin') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.dll') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.pyc') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.res') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.dylib') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.so') then
      aicon := 5
    else if (lowercase(list_log[1][cellinfo.cell.row]) = '.zip') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.iso') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.cab') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.torrent') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.7z') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.txz') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.rpm') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.tar') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.gz') or
      (lowercase(list_log[1][cellinfo.cell.row]) = '.deb') then
      aicon := 6
    else
      aicon := 1;
*************************)
    apoint.x := 2;
    apoint.y := 1;

  if aicon <> 13 then
    iconslist.paint(Canvas, aicon, apoint, cl_default,
      cl_default, cl_default, 0)

   else
    begin

    thefilename := list_log[NameCol][cellinfo.cell.row];
    thefilename := dir.value + trim(copy(thefilename,2,length(thefilename)));

//    writeln(thefilename);

    {$ifdef BGRABITMAP_USE_MSEGUI}
    tbitmapcomp1.free;
    tbitmapcomp1 := TBGRABitmap.Create(tosysfilepath(thefilename));
    {$else}
    tbitmapcomp1.bitmap.LoadFromFile(tosysfilepath(thefilename));
    {$endif}

    recti.x := 0;
    recti.y := 0;
    recti.cx := list_log.datarowheight;
    recti.cy := recti.cx;

      tbitmapcomp1.bitmap.paint(Canvas, Recti);

    end;

   end;

  end;

end;

////////////////////////////////////////////
procedure tfiledialogxfo.onswitchcomp (const Sender: TObject);
var
  fakebool: boolean;
begin
  fakebool:= CompactSetting.checked;  // bcompact.value;
  onsetcomp (Sender, fakebool, fakebool {not used});
end;
////////////////////////////////////////////

procedure tfiledialogxfo.onsetcomp(const Sender: TObject; var avalue: Boolean; var accept: Boolean);
////var
//// theint{, theexist }: integer;
////  sel : gridcoordty;
begin
  CompactSetting.checked := avalue;

  if avalue then
  begin
    listview.Width   := list_log.Width;
    listview.invalidate;
    list_log.Visible := False;
////////////////////////////////////////////

    listview.beginupdate;
    listview.row:= list_log.focusedcell.row;
    listview.selectednames:= fselectednames;
    listview.endupdate;

    listview.show;    //// REQUIRED for "setFocus" here!
    listview.setFocus;
////////////////////////////////////////////
  end
  else
  begin
    listview.Visible := False;
    listview.Width   := 40;

////////////////////////////////////////////
    list_log.row:= listview.focusedcell.row;
    realizeselection;
////////////////////////////////////////////

////////////////////////////////////////////
////    theexist := -1;

////    for theint := 0 to list_log.rowcount - 1 do
////      if trim (copy(list_log[NameCol][theint], 2,
////               length(list_log[NameCol][theint]))) = filename.value then
////        theexist := theint;

////    if theexist > 0 then
////    begin
////      sel.col := 0;
////      sel.row := theexist;
////////----      list_log.defocuscell;
////////----      list_log.datacols.clearselection;
////////----      list_log.selectcell(sel,csm_select);
////      list_log.frame.sbvert.value := theexist/ (list_log.rowcount-1);
////    end;
////////////////////////////////////////////
////////////////////////////////////////////
    list_log.show;    //// REQUIRED for "setFocus" here!
    list_log.setFocus;
////////////////////////////////////////////
  end;
  accept:= true;
end;

procedure tfiledialogxfo.oncreat(const Sender: TObject);
begin
  {$if defined(netbsd) or defined(darwin) or defined(nomask)}
  iconslist.options := [bmo_masked];
  {$endif}
  theimagelist    := iconslist;
  fsplitterpanpos := tsplitter1.left;
////????  fisfixedrow     := False;
end;

procedure tfiledialogxfo.onbefdrop(const Sender: TObject);
begin
  filter.left  := 190;
  filter.Width := 414;
  //filter.frame.Caption := '';
end;

procedure tfiledialogxfo.oncellevplaces(const Sender: TObject; var info: celleventinfoty);
var
  cellpos: gridcoordty;
begin

  if (info.eventkind = cek_buttonrelease) or (info.eventkind = cek_keyup) then
  begin
    cellpos := info.cell;

    if directoryexists(tosysfilepath(places[1][cellpos.row] + directoryseparator)) then
    begin

      dir.Value := tosysfilepath(places[1][cellpos.row] + directoryseparator);

      if tryreadlist(dir.Value, True) then
      begin
        dir.Value := tosysfilepath(listview.directory);
        course(listview.directory);
      end;

      //////// Is this REALLY useful ???????
      if filename.tag <> 2 then begin // save file
        if filename.tag = 1 then
          filename.Value := dir.Value
////        else
////          filename.Value := '';
      end;

      filename.Value := tosysfilepath(filename.Value);

////----      list_log.defocuscell;
////----      list_log.datacols.clearselection;

      placescust.defocuscell;
      placescust.datacols.clearselection;

    end
    else
    begin
      places.defocuscell;
      places.datacols.clearselection;
    end;

  end;
end;

procedure tfiledialogxfo.ondrawcellplace(const Sender: tcol; const Canvas: tcanvas; var cellinfo: cellinfoty);
var
  aicon:  integer = -1;
  apoint: pointty;
  astr:   msestring;
  select: SubPlaces;
//  {$ifdef windows}
//  achar : char;
//  {$endif}
begin
  if NOT IconsSetting.checked then
  begin
    astr := trim(places[0][cellinfo.cell.row]);
(*************************
  {$ifdef windows}
  for achar := 'A' to 'Z' do
   if (uppercase(astr) = achar + ':\') then aicon := 0;
  {$endif}
  if aicon <> 0 then
  if (astr = '/') or (lowercase(astr) = '/usr') or
     (lowercase(astr) = 'c:\users') then aicon := 0;

  if aicon <> 0 then
    if astr = 'Home' then
      aicon := 13
    else if astr = 'Desktop' then
      aicon := 14
    else if astr = 'Music' then
      aicon := 3
    else if astr = 'Pictures' then
      aicon := 7
    else if astr = 'Videos' then
      aicon := 4
    else if astr = 'Documents' then
      aicon := 2
    else if astr = 'Downloads' then
      aicon := 15;
*************************)
    select:= SysRoot;
  {$ifdef windows}
    WHILE (select < atHome) AND
          NOT ((astr [1]) IN ['A'..'Z', 'a'..'z']) AND (System.Pos (SubPlace [select].Place, astr) = 2)))
    DO Inc (select);

    IF select >= atHome THEN
  {$endif}
     WHILE (select < no_more) AND (astr <> SubPlace [select].Place) DO Inc (select);
    aicon:= SubPlace [select].Icon;


    apoint.x := 2;
    apoint.y := 3;

    iconslist.paint(Canvas, aicon, apoint, cl_default,
      cl_default, cl_default, 0);
  end;
end;

procedure tfiledialogxfo.onlayout(const Sender: tcustomgrid);
begin
  list_log.left     := tsplitter1.left;
  listview.left     := list_log.left;
  tsplitter1.Height := list_log.Height;
  tsplitter3.Width  := placespan.Width;
end;

procedure tfiledialogxfo.onformcreated(const Sender: TObject);
var
strz : string = '';
begin
 if MSEFallbackLang = 'zh' then strz := '             ';
 fcourseid := -1;

     // caption := 'Select a file';

 {$ifdef mse_dynpo}
 if length(lang_stockcaption) > 0 then
 begin
   dir.frame.caption:= lang_stockcaption[ord(sc_directory)] + strz ;
    home.Caption         := lang_stockcaption[ord(sc_homehk)] + strz ;
    //  up.caption:= lang_stockcaption[ord(sc_uphk)] + strz ;
    createdir.Caption    := lang_stockcaption[ord(sc_new_dirhk)] + strz ;
    createdir.hint    := lang_stockcaption[ord(sc_create_new_directory)] + strz ;
    filename.frame.caption:= lang_stockcaption[ord(sc_namehk)] + strz ;
    filter.frame.Caption := lang_stockcaption[ord(sc_filterhk)] + strz ;
    ok.Caption           := lang_modalresult[Ord(mr_ok)] + strz ;
    cancel.Caption       := lang_modalresult[Ord(mr_cancel)] + strz ;
////////////////////////////////////////////
    PlacesSetting.Caption:=  lang_stockcaption [ord (sc_nolateral)]+ strz;
    CompactSetting.Caption:= lang_stockcaption [ord (sc_compact)]+ strz;
    HiddenSetting.Caption:=  lang_stockcaption [ord (sc_show_hidden_fileshk)]+ strz;
////????    HistorySetting:= 
////????    PreviewSetting:= 
////    bnoicon.frame.caption:= lang_stockcaption[ord(sc_noicons)] + strz ;
////    blateral.frame.caption:= lang_stockcaption[ord(sc_nolateral)] + strz ;
////    bcompact.frame.caption:= lang_stockcaption[ord(sc_compact)] + strz ;
////    showhidden.frame.caption:= lang_stockcaption[ord(sc_show_hidden_fileshk)] + strz ;
////////////////////////////////////////////
    end;
{$else}
    dir.frame.caption:= sc(sc_directory) + strz ;
    home.Caption         := sc(sc_homehk) + strz ;
    //  up.caption:= lang_stockcaption[ord(sc_uphk)] + strz ;
    createdir.Caption    := sc(sc_new_dirhk) + strz ;
    createdir.hint    := sc(sc_create_new_directory) + strz ;
    filename.frame.caption:= sc(sc_namehk) + strz ;
    filter.frame.Caption := sc(sc_filterhk) + strz ;
    ok.caption:= stockobjects.modalresulttext[mr_ok] + strz ;
    cancel.caption:= stockobjects.modalresulttext[mr_cancel] + strz ;
////////////////////////////////////////////
    PlacesSetting.Caption:=  sc (sc_nolateral)+ strz;
    CompactSetting.Caption:= sc (sc_compact)+ strz;
    HiddenSetting.Caption:=  sc (sc_show_hidden_fileshk)+ strz;
////????    HistorySetting:= 
////????    PreviewSetting:= 
////    bnoicon.frame.caption:= sc(sc_noicons) + strz ;
////    blateral.frame.caption:= sc(sc_nolateral) + strz ;
////    bcompact.frame.caption:= sc(sc_compact) + strz ;
////    showhidden.frame.caption:= sc(sc_show_hidden_fileshk) + strz ;
////////////////////////////////////////////
{$endif}

  back.tag    := Ord(sc_back);
  forward.tag := Ord(sc_forward);
  up.tag      := Ord(sc_up);

/////????////  application.ProcessMessages;

end;

////////////////////////////////////////////
procedure tfiledialogxfo.onswitchlateral (const Sender: TObject);
var
  fakebool: boolean;
begin
  fakebool:= PlacesSetting.checked;  // blateral.value;
  onlateral (Sender, fakebool, fakebool {not used});
end;
////////////////////////////////////////////

procedure tfiledialogxfo.onlateral(const Sender: TObject; var avalue: Boolean; var accept: Boolean);
begin
  {blateral}PlacesSetting.checked:= avalue;

  if not avalue then
  begin
    placespan.Visible  := True;
    tsplitter1.left    := fsplitterpanpos;
    tsplitter1.Visible := True;
    list_log.left      := tsplitter1.left + tsplitter1.Width;
    list_log.Width     := Width - list_log.left - 2;
  end
  else
  begin
    placespan.Visible  := False;
    tsplitter1.left    := 0;
    list_log.Width     := Width - 4;
    tsplitter1.Visible := False;
    list_log.left      := tsplitter1.Width;
  end;

  list_log.invalidate;

  listview.left := list_log.left;

  if not list_log.Visible then
    listview.Width := list_log.Width
  else
    listview.Width := 30;

  tsplitter1.invalidate;

  listview.invalidate;
  list_log.invalidate;
  accept:= true;
end;

procedure tfiledialogxfo.afterclosedrop(const Sender: TObject);
begin
   if filename.tag = 1 then
    filename.Value := dir.Value;
  filename.Value   := tosysfilepath(filename.Value);  //// ????
end;

procedure tfiledialogxfo.onresize(const Sender: TObject);
begin
{
  list_log.datacols[0].Width := list_log.Width -
    list_log.datacols[1].Width - list_log.datacols[2].Width -
    list_log.datacols[3].Width - 20;

  application.ProcessMessages;
}

  filename.Width := Width - filename.left - 4;
  list_log.Width := Width - list_log.left - 2;
  if list_log.Visible = False then
    listview.Width := list_log.Width;
    tsplitter1.height := list_log.height;

////////////////////////////////////////////
    list_log [0].Width:= list_log.Width- (list_log [1].Width+ list_log [3].Width+ list_log [3].Width+
                                          list_log.fixcols [-1].Width);
////////////////////////////////////////////

   filename.top := height - filename.height - 8;
   imimage.top := filename.top - 4;

end;

procedure tfiledialogxfo.onchangdir(const Sender: TObject);
begin
  //dir.value := tosysfilepath(dir.value);
end;

procedure tfiledialogxfo.ondrawcellplacescust(const Sender: tcol; const Canvas: tcanvas; var cellinfo: cellinfoty);
var
  aicon: integer;
  apoint: pointty;
 begin
  if NOT IconsSetting.checked then
    if cellinfo.cell.row < placescust.rowcount - 1 then
    begin
      aicon := 19;

      apoint.x := 2;
      apoint.y := 3;

      iconslist.paint(Canvas, aicon, apoint, cl_default,
        cl_default, cl_default, 0);
    end;
end;

procedure tfiledialogxfo.oncellevcustplaces(const Sender: TObject; var info: celleventinfoty);
var
  theint, theexist: integer;
  thestr, tmp: msestring;
  doexist: Boolean = False;
  sel: gridcoordty;
begin

  if (info.eventkind = cek_buttonrelease) or (info.eventkind = cek_keyup) then
    if (info.eventkind = cek_keyup) then
    begin
      if (info.keyeventinfopo^.key = key_delete) then
        if (placescust.rowcount > 1) and (info.cell.row < placescust.rowcount - 1) then
          placescust.deleterow(info.cell.row);
    end
    else if (info.eventkind = cek_buttonrelease) then
      if (ss_double in info.mouseeventinfopo^.shiftstate) and
        (info.cell.row = placescust.rowcount - 1) then
      begin

        for theint := 0 to placescust.rowcount - 2 do
          if placescust[1][theint] = dir.Value then
          begin
            doexist  := True;
            theexist := theint;
          end;

        if doexist = False then
        begin
          if NOT IconsSetting.checked then
          begin
            labtest.Caption := '';

            while labtest.Width < 30 do
            begin
              labtest.Caption := labtest.Caption + ' ';
              labtest.invalidate;
            end;

            tmp := labtest.Caption;

          end
          else
            tmp := ' ';

          thestr := copy(dir.Value, 1, length(dir.Value) - 1);
          theint := lastdelimiter(directoryseparator, ansistring(thestr));
          placescust[0][placescust.rowcount - 1] := tmp + copy(thestr, theint + 1, 14);
          placescust[1][placescust.rowcount - 1] := dir.Value;
          placescust.rowcount := placescust.rowcount + 1;
          places.defocuscell;
          places.datacols.clearselection;
        end
        else
        begin
          sel.col := 0;
          sel.row := theexist;
          placescust.defocuscell;
          placescust.datacols.clearselection;
          placescust.selectcell(sel, csm_select);
        end;
      end
      else if (info.cell.row < placescust.rowcount - 1) then
        if directoryexists(tosysfilepath(placescust[1][info.cell.row] + directoryseparator)) then
        begin

          dir.Value := tosysfilepath(placescust[1][info.cell.row] + directoryseparator);

          if tryreadlist(dir.Value, True) then
          begin
            dir.Value := tosysfilepath(listview.directory);
            course(listview.directory);
          end;

          //////// Is this REALLY useful ???????
          if filename.tag <> 2 then begin // save file

            if filename.tag = 1 then
              filename.Value := dir.Value
////            else
////              filename.Value := '';
          end;

          filename.Value := tosysfilepath(filename.Value);

////----          list_log.defocuscell;
////----          list_log.datacols.clearselection;

          places.defocuscell;
          places.datacols.clearselection;

        end
        else
        begin
          placescust.defocuscell;
          placescust.datacols.clearselection;
        end;
end;

procedure tfiledialogxfo.onmovesplit(const Sender: TObject);
begin
  if tsplitter1.left > 0 then
    fsplitterpanpos := tsplitter1.left;
  if places.Width > 10 then
  begin
    places.datacols[0].Width     := places.Width - 4;
    placescust.datacols[0].Width := places.Width - 4;
  end;
  tsplitter3.width := placespan.width;
  listview.left := list_log.left;

end;

////////////////////////////////////////////
procedure tfiledialogxfo.onswitchvalnoicon (const Sender: TObject);
var
  fakebool: boolean;
begin
  fakebool:= IconsSetting.checked;  // bnoicon.value;
  onsetvalnoicon (Sender, fakebool, fakebool {not used});
end;
////////////////////////////////////////////

procedure tfiledialogxfo.onsetvalnoicon(const Sender: TObject; var avalue: Boolean; var accept: Boolean);
var
  tmp: msestring;
  x: integer;
begin
  {bnoicon}IconsSetting.checked:= avalue;
  theboolicon   := avalue;

  if avalue = False then
  begin
    labtest.Caption := '';

    while labtest.Width < 30 do
    begin
      labtest.Caption := labtest.Caption + ' ';
      labtest.invalidate;
    end;

    tmp := labtest.Caption;

  end
  else
    tmp := ' ';

  for x := 0 to places.rowcount - 1 do
    places[0][x] := tmp + trim(places[0][x]);

  for x := 0 to placescust.rowcount - 1 do
    placescust[0][x] := tmp + trim(placescust[0][x]);

  listview.readlist;
  accept:= true;
end;

procedure tfiledialogxfo.afclosedropdir(const sender: TObject);
begin
dir.value:= tosysfilepath(dir.value,true);
end;

procedure tfiledialogxfo.onpain(const sender: twidget; const acanvas: tcanvas);
{$ifdef BGRABITMAP_USE_MSEGUI}
var stretched: TBGRABitmap;
{$endif}
begin
{$ifdef BGRABITMAP_USE_MSEGUI}
  stretched := tbitmapcomp1.Resample(imImage.Width, imImage.Height) as TBGRABitmap;
  stretched.Draw(aCanvas,0,0,True);
  stretched.Free;
{$endif}
end;

////////////////////////////////////////////
{$Macro Off}
////////////////////////////////////////////

{ tfiledialogxcontroller }

constructor tfiledialogxcontroller.Create(const aowner: tmsecomponent = nil; const onchange: proceventty = nil);
begin
////////////////////////////////////
//  ficon       := tmaskedbitmap.Create(bmk_rgb);
//  fbackcolor  := cl_default;
//  ffontname   := 'stf_default';
//  ffontheight := 0;
//  ffontcolor  := cl_black;
////////////////////////////////////
  foptions    := defaultfiledialogoptions;
  fhistorymaxcount := defaulthistorymaxcount;
  fowner      := aowner;
  ffilterlist := tdoublemsestringdatalist.Create;
  finclude    := [fa_all];
  fexclude    := [fa_hidden];
  fonchange   := onchange;
  inherited Create;
end;

destructor tfiledialogxcontroller.Destroy;
begin
  inherited;
////////////////////////////////////
//  ficon.Free;
////////////////////////////////////
  ffilterlist.Free;
end;

procedure tfiledialogxcontroller.readstatvalue(const reader: tstatreader);
begin
  ffilenames     := reader.readarray('filenames', ffilenames);
////////////////////////////////////
 // If multiple files, but single selectiononly cut off all beyond first
 IF (fdo_single IN fOptions) AND (high (ffilenames) > 0)
   THEN setLength (ffilenames, 1);
////////////////////////////////////
//  ffilenamescust := reader.readarray('filenamescust', ffilenamescust);
////////////////////////////////////
  if fdo_params in foptions then
    fparams := reader.readmsestring('params', fparams);
end;

procedure tfiledialogxcontroller.readstatstate(const reader: tstatreader);
begin
  ffilterindex     := reader.readinteger('filefilterindex', ffilterindex);
  ffilter          := reader.readmsestring('filefilter', ffilter);
  fwindowrect.x    := reader.readinteger('x', fwindowrect.x);
  fwindowrect.y    := reader.readinteger('y', fwindowrect.y);
  fwindowrect.cx   := reader.readinteger('cx', fwindowrect.cx);
  fwindowrect.cy   := reader.readinteger('cy', fwindowrect.cy);

////////////////////////////////////
//  fshowhidden      := reader.readboolean('showhidden', fshowhidden);
//  fcompact         := reader.readboolean('compact', fcompact);
//  fshowoptions     := reader.readboolean('showoptions', fshowoptions);
//  fhidehistory     := reader.readboolean('hidehistory', fhidehistory);
//  fhideicons       := reader.readboolean('hideicons', fhideicons);
//  fnopanel         := reader.readboolean('nopanel', fnopanel);
//  fcolwidth        := reader.readinteger('filecolwidth', fcolwidth);  //// ????
//  fcolnamewidth    := reader.readinteger('colnamewidth', fcolnamewidth);
//  fcolsizewidth    := reader.readinteger('colsizewidth', fcolsizewidth);
//  fcolextwidth     := reader.readinteger('colextwidth', fcolextwidth);
//  fcoldatewidth    := reader.readinteger('coldatewidth', fcoldatewidth);
//  fsplitterplaces  := reader.readinteger('splitterplaces', fsplitterplaces);
//  fsplitterlateral := reader.readinteger('splitterlateral', fsplitterlateral);
////////////////////////////////////

  if fdo_chdir in foptions then
    trysetcurrentdirmse(flastdir);
end;

procedure tfiledialogxcontroller.readstatoptions(const reader: tstatreader);
begin
  if fdo_savelastdir in foptions then
    flastdir := reader.readmsestring('lastdir', flastdir);
  if fhistorymaxcount > 0 then
    fhistory := reader.readarray('filehistory', fhistory);
end;

procedure tfiledialogxcontroller.writestatvalue(const writer: tstatwriter);
begin
  writer.writearray('filenames', ffilenames);
////////////////////////////////////
//  writer.writearray('filenamescust', ffilenamescust);
////////////////////////////////////
  if fdo_params in foptions then
    writer.writemsestring('params', fparams);
end;

procedure tfiledialogxcontroller.writestatstate(const writer: tstatwriter);
begin
  writer.writeinteger('x', fwindowrect.x);
  writer.writeinteger('y', fwindowrect.y);
  writer.writeinteger('cx', fwindowrect.cx);
  writer.writeinteger('cy', fwindowrect.cy);
////////////////////////////////////
//  writer.writeboolean('nopanel', fnopanel);
//  writer.writeboolean('compact', fcompact);
//  writer.writeboolean('showoptions', fshowoptions);
//  writer.writeboolean('hidehistory', fhidehistory);
//  writer.writeboolean('hideicons', fhideicons);
//  writer.writeboolean('showhidden', fshowhidden);

////////////////////////////////////
//  writer.writeinteger('filecolwidth', fcolwidth);
//  writer.writeinteger('colnamewidth', fcolnamewidth);
//  writer.writeinteger('colsizewidth', fcolsizewidth);
//  writer.writeinteger('colextwidth', fcolextwidth);
//  writer.writeinteger('coldatewidth', fcoldatewidth);
//  writer.writeinteger('splitterplaces', fsplitterplaces);
//  writer.writeinteger('splitterlateral', fsplitterlateral);
////////////////////////////////////
end;

procedure tfiledialogxcontroller.writestatoptions(const writer: tstatwriter);
begin
  if fdo_savelastdir in foptions then
    writer.writemsestring('lastdir', flastdir);
  if fhistorymaxcount > 0 then
    writer.writearray('filehistory', fhistory);
  writer.writeinteger('filefilterindex', ffilterindex);
  writer.writemsestring('filefilter', ffilter);
end;

procedure tfiledialogxcontroller.componentevent(const event: tcomponentevent);
begin
  if (fdo_link in foptions) and (event.Sender <> self) and
    (event.Sender is tfiledialogxcontroller) then
    with tfiledialogxcontroller(event.Sender) do
      if fgroup = self.fgroup then
        self.flastdir := flastdir;
end;

procedure tfiledialogxcontroller.checklink;
begin
  if (fdo_link in foptions) and (fowner <> nil) then
    fowner.sendrootcomponentevent(tcomponentevent.Create(self), True);
end;

// function tfiledialogxcontroller.Execute (dialogkind: filedialogkindty; const acaption: msestring; aoptions: filedialogoptionsty): modalresultty;
////////////////////////////////////
function tfiledialogxcontroller.Execute (dialogkind: filedialogkindty; const acaption: msestring; aoptions: filedialogoptionsty;
                                         providedform: tfiledialogxfo = nil): modalresultty;
////////////////////////////////////
var
  po1: pmsestringarty;
  fo: tfiledialogxfo;
  ara, arb: msestringarty;
  //acaption2: msestring;
  rectbefore: rectty;
  x: integer;
////  theint: integer;  //// no (longer) in use
  thestr, tmp: msestring;
  {$ifdef windows}
  achar : char;
  {$endif}

////////////////////////////////////
 PROCEDURE SetSubplaces (CONST Prefix: msestring);
  VAR
    place:   SubPlaces;
    SubDir,
    HomeDir: msestring;
  BEGIN
    place:= SysRoot; HomeDir:= ''; SubDir:= SubPlace [place].Place;
    fo.places.clear;
    REPEAT
  {$ifdef windows}
        SubDir:= 'A'+ SubDir;     // Search drive letters for candidate...
        WHILE SubDir [1] <= 'Z' DO BEGIN
          IF DirectoryExists (SubDir) THEN BEGIN
            fo.places.appendrow ([Prefix+ SubDir, SubDir]);
            SubDir [1]:= succ ('Z');
          END
          ELSE Inc (SubDir [1]);
        END;
  {$else}
      IF DirectoryExists (SubDir) THEN BEGIN
        fo.places.appendrow ([Prefix+ SubDir, SubDir]);
      END;
  {$endif}
      Inc (place);
      SubDir:= SubPlace [Place].Place;
    UNTIL place >= atHome;

    place:= atHome; SubDir:= ''; HomeDir:= sys_getUserHomedir;
    REPEAT
      IF DirectoryExists (HomeDir+ SubDir) THEN
        fo.places.appendrow ([Prefix+ SubPlace [place].Place{SubDir}, HomeDir+ SubDir]);

      Inc (place);
      SubDir:= DirectorySeparator+ SubPlace [Place].Place;
    UNTIL place = no_more;
{?
    WITH fo.Places DO BEGIN
      Bounds_cy:= RowCount* (DatarowHeight+ DatarowLinewidth)+ 2* DatarowLinewidth;
      Bounds_cymin:= Bounds_cy;
    END (* WITH Places *);

    WITH fo.PlacesCust DO BEGIN
      Bounds_cy:= RowCount* (DatarowHeight+ DatarowLinewidth)+ 2* DatarowLinewidth;
      Bounds_cymin:= Bounds_cy;
    END (* WITH PlacesCust *);
?}
  END;
////////////////////////////////////

begin
  //acaption2 := acaption;
  ara    := nil;
  //compiler warning
  arb    := nil;
  //compiler warning
  Result := mr_ok;

  if Assigned(fonbeforeexecute) then
  begin
    fonbeforeexecute(self, dialogkind, Result);
    if Result <> mr_ok then
      Exit;
  end;
////  if fhistorymaxcount > 0 then
////  if assigned (history) AND (fhistorymaxcount > 0) then
    po1 := @fhistory
////  else
////    po1 := nil
;

////////////////////////////////////
 if assigned (providedform) then begin
   fo:= providedform; fo.setposition (DialogPlacement);
 end
 else begin
   IF assigned (fOwner) AND (fowner IS tmseForm)  ///??? tFileDialogX)
     THEN fo:= tfiledialogxfo.create ({?nil?}fowner, Self, (fOwner AS tmseForm).Name, DialogPlacement)
     ELSE fo:= tfiledialogxfo.create ({?nil?}fowner, Self, 'FiledialogXForm', DialogPlacement);

////   IF assigned (fOwner) AND (fowner IS tmseForm)  ///??? tFileDialogX)
////     THEN fo.StatFile:= (fOwner AS tmseForm {tFileDialogX}).Statfile;
//   IF assigned (fOwner) AND (fowner IS tmseForm) AND
//      assigned ((fOwner AS tmseForm).StatFile)
//     THEN fo:= tfiledialogxfo.create (fowner, (fOwner AS tmseForm).StatFile.Name, DialogPlacement)
//     ELSE fo:= tfiledialogxfo.create (fowner, DialogPlacement);
//// ???? Set "self" as the responsible controller ---- ????
//// ####   fo.fController:= self;
 end;
 fwindowrect:= fo.widgetrect;
////////////////////////////////////
// fo:= tfiledialogxfo.create(nil);

  try
 {$ifdef FPC} {$checkpointer off} {$endif}
    //todo!!!!! bug 3348
    ara := ffilterlist.asarraya;
    arb := ffilterlist.asarrayb;

////////////////////////////////////
//    if fontheight = 0 then
//      fo.font.Height := 12;

//    if fontheight > 0 then
//      if fontheight < 21 then
//        fo.font.Height := fontheight
//      else
//        fo.font.Height := 20;

    // Limit allowed font sizes -- better do it in font setting code ??
    WITH fo.font DO
      IF Height = 0 THEN Height:= 12
      ELSE // IF Height > 0 THEN
        IF Height > 20 THEN Height:= 20;
////////////////////////////////////

    fo.list_log.datacols[2].widthmax := fo.font.Height * 7;

//--    fo.font.color := fontcolor;

//--    fo.container.color := backcolor;

//--    if fontname <> '' then
//--      fo.font.Name := ansistring(fontname);

//--    fo.bnoicon.Value := fhideicons;
//--    fhideicons:= fo.bnoicon.Value;

    //// Macro doesn't work here !!!!
    theboolicon := fo.Settings.Menu.SubMenu [1].checked;   // fhideicons;

//    if fhideicons = False then
    //// Macro doesn't work here !!!!
    IF NOT fo.Settings.Menu.SubMenu [1].checked THEN
    begin
      fo.labtest.Caption := '';

      while fo.labtest.Width < 30 do
      begin
        fo.labtest.Caption := fo.labtest.Caption + ' ';
        fo.labtest.invalidate;
      end;

      tmp := fo.labtest.Caption;

    end
    else
      tmp := ' ';

    SetSubplaces (tmp);
(*************************
    x := -1;
    fo.places.rowcount := 0;

    {$ifdef windows}
    for achar := 'A' to 'Z' do
       begin
        if directoryexists(achar + ':\') then
          begin
           Inc(x);
           fo.places.rowcount := x+1;
           fo.places[0][x] := tmp + achar + ':\';
           fo.places[1][x] := msestring(achar + ':\');
          end;
      end;

    if directoryexists('C:\users') then
    begin
      Inc(x);
      fo.places.rowcount := x+1;
      fo.places[0][x] := tmp + 'C:\users';
      fo.places[1][x] := msestring('C:\users');
    end;
    {$else}
    if directoryexists('/') then
    begin
      Inc(x);
      fo.places.rowcount := x+1;
      fo.places[0][x] := tmp + '/';
      fo.places[1][x] := msestring('/');
    end;
    if directoryexists('/usr') then
    begin
      Inc(x);
      fo.places.rowcount := x+1;
      fo.places[0][x] := tmp + '/usr';
      fo.places[1][x] := msestring('/usr');
    end;
    {$endif}

    if directoryexists(tosysfilepath(sys_getuserhomedir)) then
    begin
      Inc(x);
      fo.places.rowcount := x+1;
      fo.places[0][x] := tmp + 'Home';
      fo.places[1][x] := msestring(tosysfilepath(sys_getuserhomedir));
    end;
    if directoryexists(tosysfilepath(sys_getuserhomedir + directoryseparator + 'Desktop')) then
    begin
      Inc(x);
      fo.places.rowcount := x+1;
      fo.places[0][x] := tmp + 'Desktop';
      fo.places[1][x] := msestring(tosysfilepath(sys_getuserhomedir + directoryseparator + 'Desktop'));
    end;
    if directoryexists(tosysfilepath(sys_getuserhomedir + directoryseparator + 'Music')) then
    begin
      Inc(x);
      fo.places.rowcount := x+1;
      fo.places[0][x] := tmp + 'Music';
      fo.places[1][x] := msestring(tosysfilepath(sys_getuserhomedir + directoryseparator + 'Music'));
    end;
    if directoryexists(tosysfilepath(sys_getuserhomedir + directoryseparator + 'Pictures')) then
    begin
      Inc(x);
      fo.places.rowcount := x+1;
      fo.places[0][x] := tmp + 'Pictures';
      fo.places[1][x] := msestring(tosysfilepath(sys_getuserhomedir + directoryseparator + 'Pictures'));
    end;
    if directoryexists(tosysfilepath(sys_getuserhomedir + directoryseparator + 'Videos')) then
    begin
      Inc(x);
      fo.places.rowcount := x+1;
      fo.places[0][x] := tmp + 'Videos';
      fo.places[1][x] := msestring(tosysfilepath(sys_getuserhomedir + directoryseparator + 'Videos'));
    end;
    if directoryexists(tosysfilepath(sys_getuserhomedir + directoryseparator + 'Documents')) then
    begin
      Inc(x);
      fo.places.rowcount := x+1;
      fo.places[0][x] := tmp + 'Documents';
      fo.places[1][x] := msestring(tosysfilepath(sys_getuserhomedir + directoryseparator + 'Documents'));
    end;
    if directoryexists(tosysfilepath(sys_getuserhomedir + directoryseparator + 'Downloads')) then
    begin
      Inc(x);
      fo.places.rowcount := x+1;
      fo.places[0][x] := tmp + 'Downloads';
      fo.places[1][x] := msestring(tosysfilepath(sys_getuserhomedir + directoryseparator + 'Downloads'));
    end;

    fo.places.rowcount := fo.places.rowcount +1;;
*************************)

////////////////////////////////////
//    if length(ffilenamescust) > 0 then
//    begin
//      fo.placescust.rowcount := length(ffilenamescust) + 1;
//      for x    := 0 to length(ffilenamescust) - 1 do
//      begin
//        thestr := copy(ffilenamescust[x], 1, length(ffilenamescust[x]) - 1);
//        theint := lastdelimiter(directoryseparator, ansistring(thestr));
//        fo.placescust[1][x] := ffilenamescust[x];
//        fo.placescust[0][x] := tmp + copy(thestr, theint + 1, 14);
//      end;
//    end;
////////////////////////////////////
    WITH fo DO
      FOR x:= 0 TO pred (placescust.rowhigh) DO BEGIN
        thestr:= placescust [1][x];
         IF thestr [Length (thestr)] = DirectorySeparator THEN
          SetLength (thestr, pred (Length (thestr)));
        thestr:= ExtractFilename (thestr); //// SetLength (thestr, 14);  // ??
        IF thestr <> ''
          THEN placescust [0][x]:= tmp+ thestr
          ELSE placescust [0][x]:= tmp+ SubPlace [SysRoot].Place;
      END;
//////////////////////////////////////

//--    fo.blateral.Value := fnopanel;
//--    fnopanel:= fo.blateral.Value;

//--    if ficon <> nil then
//--      fo.icon := ficon;

//--    fo.bcompact.Value   := fcompact;
//--    fo.showhidden.Value := fshowhidden;
//--    fo.bshowoptions.Value := fshowoptions;
//--    fo.bhidehistory.Value := fhidehistory;
//--    fo.bnoicon.Value := fhideicons;
//    fcompact:=     fo.bcompact.Value;
//    fshowhidden:=  fo.showhidden.Value;
//    fshowoptions:= fo.bshowoptions.Value;
//    fhidehistory:= fo.bhidehistory.Value;
//    fhideicons:=   fo.bnoicon.Value;

//--    if fcolnamewidth > 0 then
//--      fo.list_log.datacols[0].Width := fcolnamewidth;
//--    if fcolextwidth > 0 then
//--      fo.list_log.datacols[1].Width := fcolextwidth;
//--    if fcolsizewidth > 0 then
//--      fo.list_log.datacols[2].Width := fcolsizewidth;
//--    if fcoldatewidth > 0 then
//--      fo.list_log.datacols[3].Width := fcoldatewidth;

    // fo.list_log.datacols[0].Width := fo.list_log.Width -
    //   fo.list_log.datacols[1].Width - fo.list_log.datacols[2].Width -
    //   fo.list_log.datacols[3].Width - 20;

//// filename.tag meanings:
////  1 - fdo_directory in aoptions
////  2 - dialogkind = fdk_save

    fo.filename.tag:= 0;      //// Just to be sure ---- ????

    if (fdo_directory in aoptions) then
    begin
      fo.filename.tag           := 1;
      fo.filename.Value         := fo.dir.Value;
{$ifdef mse_dynpo}
     if length(lang_stockcaption) > 0 then
      fo.filename.frame.Caption := lang_stockcaption[ord(sc_dirhk)];
    end
////    else if (dialogkind in [fdk_save]) then
    else if (dialogkind = fdk_save) then
    begin
      if length(lang_stockcaption) > 0 then
      fo.filename.frame.Caption :=  lang_stockcaption[ord(sc_namehk)];
      fo.filename.tag           := 2;
    end
////    else if (dialogkind in [fdk_new]) then
    else if (dialogkind = fdk_new) then
      if length(lang_stockcaption) > 0 then
      fo.filename.frame.Caption := lang_stockcaption[ord(sc_newfile)]
      else
        if length(lang_stockcaption) > 0 then
        fo.filename.frame.Caption := lang_stockcaption[ord(sc_namehk)];
{$else}
      fo.filename.frame.Caption := sc(sc_dirhk);
    end
////    else if (dialogkind in [fdk_save]) then
    else if (dialogkind = fdk_save) then
    begin
      fo.filename.frame.Caption :=  sc(sc_namehk);
      fo.filename.tag           := 2;
    end
////    else if (dialogkind in [fdk_new]) then
    else if (dialogkind = fdk_new) then
      fo.filename.frame.Caption := sc(sc_newfile)
      else
        fo.filename.frame.Caption := sc(sc_namehk);
{$endif}

    if dialogkind <> fdk_none then
      if dialogkind in [fdk_save, fdk_new] then
        system.include(aoptions, fdo_save)
      else
        system.exclude(aoptions, fdo_save);
    if fdo_relative in foptions then
      fo.listview.directory := getcurrentdirmse
    else 
      fo.listview.directory := flastdir;
    if (fwindowrect.cx > 0) and (fwindowrect.cy > 0) then
      fo.widgetrect         := clipinrect(fwindowrect, application.screenrect(fo.window));
    rectbefore := fo.widgetrect;
////////////////////////////////////
//    if fsplitterplaces > 0 then
//      fo.tsplitter3.top := fsplitterplaces;
//
//    if fnopanel = True then
//      fo.tsplitter1.left := 0
//    else if fsplitterlateral > 0 then
//      fo.tsplitter1.left := fsplitterlateral;
////////////////////////////////////

    Result:=
    filedialogx1
     (fo,
      ffilenames,
      ara,
      arb,
      @ffilterindex,
      @ffilter,
      NIL,  //// @fcolwidth, --- not used here, nor applicable here
      finclude,
      fexclude,
      po1,
      fhistorymaxcount,
      acaption,
      aoptions,
      fdefaultext,
      fimagelist,
      fongetfileicon,
      foncheckfile);

    if not rectisequal(fo.widgetrect, rectbefore) then
      fwindowrect := fo.widgetrect;

    if Assigned(fonafterexecute) then
      fonafterexecute(self, Result);
 {$ifdef FPC} {$checkpointer default} {$endif}
    if Result = mr_ok then
      if fdo_relative in foptions then
        flastdir := getcurrentdirmse
      else
        flastdir := fo.dir.Value;

//    fnopanel        := fo.blateral.Value;
//    fcompact        := fo.bcompact.Value;
//    fshowoptions    := fo.bshowoptions.Value;
//    fshowhidden     := fo.showhidden.Value;
//    fhidehistory    := fo.bhidehistory.Value;
//    fhideicons      := fo.bnoicon.Value;

//    fcolnamewidth   := fo.list_log.datacols[0].Width;
//    fcolextwidth    := fo.list_log.datacols[1].Width;
//    fcolsizewidth   := fo.list_log.datacols[2].Width;
//    fcoldatewidth   := fo.list_log.datacols[3].Width;
//    fsplitterplaces := fo.tsplitter3.top;

//    if fo.tsplitter1.left > 0 then
//      fsplitterlateral := fo.tsplitter1.left;

////////////////////////////////////
//    if fo.placescust.rowcount > 1 then
//    begin
//      setlength(ffilenamescust, fo.placescust.rowcount - 1);
//      for x := 0 to length(ffilenamescust) - 1 do
//        ffilenamescust[x] := fo.placescust[1][x];
//    end
//    else
//      setlength(ffilenamescust, 0);
////////////////////////////////////

  finally
////////////////////////////////////////////
   if not assigned (providedform) then begin
       fo.fController:= NIL;
       if self = nil then ;
////////////////////////////////////////////
    fo.Free;
////////////////////////////////////////////
    end;
////////////////////////////////////////////
  end;
end;

// function tfiledialogxcontroller.Execute (const dialogkind: filedialogkindty; const acaption: msestring): modalresultty;
////////////////////////////////////
function tfiledialogxcontroller.Execute (const dialogkind: filedialogkindty; const acaption: msestring;
                                         providedform: tfiledialogxfo = nil): modalresultty;
////////////////////////////////////
begin
  Result := Execute(dialogkind, acaption, foptions, providedform);
end;

function tfiledialogxcontroller.actcaption (const dialogkind: filedialogkindty): msestring;
begin
  case dialogkind of
    fdk_save:
      Result := fcaptionsave;
    fdk_new:
      Result := fcaptionnew;
    fdk_open:
      Result := fcaptionopen;
    //fdk_dir:
    //  Result := fcaptiondir;
   // fdk_none:
   //   Result := '';
    else
      Result := fcaptionopen;
  end;
end;

// function tfiledialogxcontroller.Execute (const dialogkind: filedialogkindty; const aoptions: filedialogoptionsty): modalresultty;
////////////////////////////////////
function tfiledialogxcontroller.Execute (const dialogkind: filedialogkindty; const aoptions: filedialogoptionsty;
                                         providedform: tfiledialogxfo = nil): modalresultty;
////////////////////////////////////
begin
 if fdo_directory in aoptions then
  Result := Execute(dialogkind, fcaptiondir, aoptions, providedform) else
  Result := Execute(dialogkind, actcaption(dialogkind), aoptions, providedform);
end;

// function tfiledialogxcontroller.Execute (dialogkind: filedialogkindty = fdk_none): modalresultty;
////////////////////////////////////
function tfiledialogxcontroller.Execute (dialogkind: filedialogkindty = fdk_none;
                                         providedform: tfiledialogxfo = nil): modalresultty;
////////////////////////////////////
begin
  if dialogkind = fdk_none then
    if fdo_save in foptions then
      dialogkind := fdk_save
    else
      dialogkind := fdk_none;

  if fdo_directory in foptions then
  Result := Execute(dialogkind, fcaptiondir, providedform) else
  Result := Execute(dialogkind, actcaption(dialogkind), providedform);
end;

// function tfiledialogxcontroller.Execute (var avalue: filenamety; dialogkind: filedialogkindty = fdk_none): Boolean;
////////////////////////////////////
function tfiledialogxcontroller.Execute (var avalue: filenamety; dialogkind: filedialogkindty = fdk_none;
                                         providedform: tfiledialogxfo = nil): Boolean;
////////////////////////////////////
begin
  if dialogkind = fdk_none then
    if fdo_save in foptions then
      dialogkind := fdk_save
    else
      dialogkind := fdk_none;

  if fdo_directory in foptions then
  Result := Execute(avalue, dialogkind, fcaptiondir, providedform) else
  Result := Execute(avalue, dialogkind, actcaption(dialogkind), providedform);
end;

// function tfiledialogxcontroller.Execute (var avalue: filenamety; const dialogkind: filedialogkindty; const acaption: msestring; aoptions: filedialogoptionsty): Boolean;
////////////////////////////////////
function tfiledialogxcontroller.Execute (var avalue: filenamety; const dialogkind: filedialogkindty; const acaption: msestring; aoptions: filedialogoptionsty;
                                         providedform: tfiledialogxfo = nil): Boolean;
////////////////////////////////////
var
  wstr1: filenamety;
begin
  wstr1 := filename;
  if Assigned(fongetfilename) then
  begin
    Result := True;
    fongetfilename(self, avalue, Result);
    if not Result then
      Exit;
  end;
  filename := avalue;
  Result   := Execute(dialogkind, acaption, aoptions, providedform) = mr_ok;
  if Result then
  begin
    avalue := filename;
    checklink;
  end
  else
    filename := wstr1;
end;

function tfiledialogxcontroller.canoverwrite(): Boolean;
begin
{$ifdef mse_dynpo}
if length(lang_stockcaption) > ord(sc_file) then
 begin
      Result := not findfile(filename) or
      askok(lang_stockcaption[ord(sc_file)] + ' "' + filename +
      '" ' + lang_stockcaption[ord(sc_exists_overwrite)],
      lang_stockcaption[ord(sc_warningupper)]);
  end else
  begin
      Result := not findfile(filename) or
      askok('File "' + filename +
      '" exists, do you want to overwrite?',
      'WARNING');
  end;

{$else}
      Result := not findfile(filename) or
      askok(sc(sc_file) + ' "' + filename +
      '" ' + sc(sc_exists_overwrite),
      sc(sc_warningupper));
{$endif}
end;

// function tfiledialogxcontroller.Execute (var avalue: filenamety; const dialogkind: filedialogkindty; const acaption: msestring): Boolean;
////////////////////////////////////
function tfiledialogxcontroller.Execute (var avalue: filenamety; const dialogkind: filedialogkindty; const acaption: msestring;
                                         providedform: tfiledialogxfo = nil): Boolean;
////////////////////////////////////
begin
  Result := Execute(avalue, dialogkind, acaption, foptions, providedform);
end;

function tfiledialogxcontroller.getfilename: filenamety;
begin
  if (high(ffilenames) > 0) or (fdo_quotesingle in foptions) or
    (fdo_params in foptions) and (high(ffilenames) = 0) and
    (findchar(pmsechar(ffilenames[0]), ' ') > 0) then
    Result := quotefilename(ffilenames)
  else if high(ffilenames) = 0 then
    Result := ffilenames[0]
  else
    Result := '';
  if (fdo_params in foptions) and (fparams <> '') then
  begin
    if fdo_sysfilename in foptions then
      tosysfilepath1(Result);
    Result := Result + ' ' + fparams;
  end
  else if fdo_sysfilename in foptions then
    tosysfilepath1(Result);
end;

const
  quotechar = msechar('"');

////////////////////////////////////
//procedure tfiledialogxcontroller.seticon(const avalue: tmaskedbitmap);
//begin
//  ficon.Assign(avalue);
//end;
////////////////////////////////////

procedure tfiledialogxcontroller.setfilename(const avalue: filenamety);
var
  int1: integer;
  akind: filekindty;
begin
  unquotefilename(avalue, ffilenames);
  if fdo_params in foptions then
  begin
    fparams := '';
    if high(ffilenames) >= 0 then
      if avalue[1] = quotechar then
      begin
        fparams := copy(avalue, length(ffilenames[0]) + 3, bigint);
        if (fparams <> '') and (fparams[1] = ' ') then
          Delete(fparams, 1, 1);
        setlength(ffilenames, 1);
      end
      else
      begin
        int1 := findchar(ffilenames[0], ' ');
        if int1 > 0 then
        begin
          fparams := copy(ffilenames[0], int1 + 1, bigint);
          setlength(ffilenames[0], int1 - 1);
        end;
      end;
  end;
  akind := fk_default;
  if fdo_directory in foptions then
  begin
    akind   := fk_dir;
    if fdo_file in foptions then
      akind := fk_file;
  end
  else if fdo_file in foptions then
    akind := fk_file;
  if [fdo_relative, fdo_lastdirrelative, fdo_basedirrelative] *
    foptions <> [] then
  begin
    if fdo_relative in foptions then
      flastdir := getcurrentdirmse
    else
    begin
      if fdo_basedirrelative in foptions then
        flastdir := fbasedir;
    end;
    for int1 := 0 to high(ffilenames) do
      if isrootpath(filenames[int1]) then
        ffilenames[int1] := relativepath(filenames[int1], flastdir, akind);
  end
  else
  begin
    if high(ffilenames) = 0 then
      if fdo_directory in foptions{akind = fk_dir} then
        flastdir := filepath(avalue, fk_dir)
      else
        flastdir := filedir(avalue);
    for int1 := 0 to high(ffilenames) do
      ffilenames[int1] := filepath(filenames[int1], akind, not (fdo_absolute in foptions));
  end;
end;

procedure tfiledialogxcontroller.setfilterlist(const Value: tdoublemsestringdatalist);
begin
  ffilterlist.Assign(Value);
end;

procedure tfiledialogxcontroller.sethistorymaxcount(const Value: integer);
begin
  fhistorymaxcount := Value;
  if length(fhistory) > fhistorymaxcount then
    setlength(fhistory, fhistorymaxcount);
end;

procedure tfiledialogxcontroller.dochange;
begin
  if Assigned(fonchange) then
    fonchange;
end;

procedure tfiledialogxcontroller.setdefaultext(const avalue: filenamety);
begin
  if fdefaultext <> avalue then
  begin
    fdefaultext := avalue;
    dochange;
  end;
end;

procedure tfiledialogxcontroller.setoptions(Value: filedialogoptionsty);

(*
const
 mask1: filedialogoptionsty = [fdo_absolute,fdo_relative)];
// mask2: filedialogoptionsty = [fdo_directory,fdo_file)];
 mask3: filedialogoptionsty = [fdo_filtercasesensitive,fdo_filtercaseinsensitive)];
*)
begin
  Value := filedialogoptionsty(setsinglebit(card32(Value), card32(foptions),
    [card32([fdo_absolute, fdo_relative, fdo_lastdirrelative,
    fdo_basedirrelative]),
    card32([fdo_filtercasesensitive, fdo_filtercaseinsensitive])]));

(*
 {$ifdef FPC}longword{$else}longword{$endif}(value):=
      setsinglebit({$ifdef FPC}longword{$else}longword{$endif}(value),
      {$ifdef FPC}longword{$else}longword{$endif}(foptions),
      {$ifdef FPC}longword{$else}longword{$endif}(mask1));
// {$ifdef FPC}longword{$else}longword{$endif}(value):=
//      setsinglebit({$ifdef FPC}longword{$else}longword{$endif}(value),
//      {$ifdef FPC}longword{$else}longword{$endif}(foptions),
//      {$ifdef FPC}longword{$else}longword{$endif}(mask2));
 {$ifdef FPC}longword{$else}longword{$endif}(value):=
      setsinglebit({$ifdef FPC}longword{$else}longword{$endif}(value),
      {$ifdef FPC}longword{$else}longword{$endif}(foptions),
      {$ifdef FPC}longword{$else}longword{$endif}(mask3));
 *)
  if foptions <> Value then
  begin
    foptions  := Value;
    if not (fdo_params in foptions) then
      fparams := '';
    dochange;
  end;
end;

procedure tfiledialogxcontroller.Clear;
begin
  ffilenames     := nil;
  flastdir       := '';
  fhistory       := nil;
////////////////////////////////////////////
//  ffilenamescust := nil;
////////////////////////////////////////////
end;

procedure tfiledialogxcontroller.setlastdir(const avalue: filenamety);
begin
  flastdir := avalue;
  checklink;
end;

procedure tfiledialogxcontroller.setimagelist(const avalue: timagelist);
begin
  setlinkedvar(avalue, tmsecomponent(fimagelist));
end;

function tfiledialogxcontroller.getsysfilename: filenamety;
var
  bo1: Boolean;
begin
  bo1    := fdo_sysfilename in foptions;
  system.include(foptions, fdo_sysfilename);
  Result := getfilename;
  if not bo1 then
    system.exclude(foptions, fdo_sysfilename);
end;

{ tfiledialogx }

constructor tfiledialogx.Create(aowner: TComponent);
begin
  // foptionsedit:= defaultfiledialogoptionsedit;
  foptionsedit1 := defaultfiledialogoptionsedit1;
////////////////////////////////////
  fcontroller   := tfiledialogxcontroller.Create({Self);  ///??? ?nil?}aowner AS tmsecomponent);
////////////////////////////////////
  inherited;
end;

destructor tfiledialogx.Destroy;
begin
  inherited;
  fcontroller.Free;
end;

function tfiledialogx.Execute: modalresultty;
begin
  Result := fcontroller.Execute(fdialogkind);
end;

function tfiledialogx.Execute(const akind: filedialogkindty): modalresultty;
begin
  Result := fcontroller.Execute(akind);
end;

function tfiledialogx.Execute(const akind: filedialogkindty; const aoptions: filedialogoptionsty): modalresultty;
begin
  Result := fcontroller.Execute(akind, aoptions);
end;

procedure tfiledialogx.setcontroller(const Value: tfiledialogxcontroller);
begin
  fcontroller.Assign(Value);
end;

procedure tfiledialogx.dostatread(const reader: tstatreader);
begin
  if canstatvalue(foptionsedit1, reader) then
    fcontroller.readstatvalue(reader);
  if canstatstate(foptionsedit1, reader) then
    fcontroller.readstatstate(reader);
  if canstatoptions(foptionsedit1, reader) then
    fcontroller.readstatoptions(reader);
end;

procedure tfiledialogx.dostatwrite(const writer: tstatwriter);
begin
  if canstatvalue(foptionsedit1, writer) then
    fcontroller.writestatvalue(writer);
  if canstatstate(foptionsedit1, writer) then
    fcontroller.writestatstate(writer);
  if canstatoptions(foptionsedit1, writer) then
    fcontroller.writestatoptions(writer);
end;

function tfiledialogx.getstatvarname: msestring;
begin
  Result := fstatvarname;
end;

procedure tfiledialogx.setstatfile(const Value: tstatfile);
begin
  setstatfilevar(istatfile(self), Value, fstatfile);
end;

procedure tfiledialogx.statreading;
begin
  //dummy
end;

procedure tfiledialogx.statread;
begin
  //dummy
end;

procedure tfiledialogx.componentevent(const event: tcomponentevent);
begin
  fcontroller.componentevent(event);
  inherited;
end;

function tfiledialogx.getstatpriority: integer;
begin
  Result := fstatpriority;
end;

procedure tfiledialogx.readoptionsedit(reader: treader);
var
  opt1: optionseditty;
begin
  opt1 := optionseditty(reader.readset(typeinfo(optionseditty)));
  updatebit(longword(foptionsedit1), Ord(oe1_savevalue), oe_savevalue in opt1);
  updatebit(longword(foptionsedit1), Ord(oe1_savestate), oe_savestate in opt1);
  updatebit(longword(foptionsedit1), Ord(oe1_saveoptions), oe_saveoptions in opt1);
  updatebit(longword(foptionsedit1), Ord(oe1_checkvalueafterstatread),
    oe_checkvaluepaststatread in opt1);
end;

procedure tfiledialogx.defineproperties(filer: tfiler);
begin
  inherited;
  filer.defineproperty('optionsedit', @readoptionsedit, nil, False);
end;

{ tfilenameeditcontroller }

constructor tfilenameeditcontroller.Create(const aowner: tcustomfilenameedit1);
begin
  inherited Create(aowner);
////////////////////////////////////
//  aowner.controller.fbackcolor  := cl_default;
//  aowner.controller.ffontname   := 'stf_default';
//  aowner.controller.ffontheight := 0;
//  aowner.controller.ffontcolor  := cl_black;
////////////////////////////////////
 end;

function tfilenameeditcontroller.Execute(var avalue: msestring): Boolean;
begin
  with tcustomfilenameedit1(fowner) do
    if fcontroller <> nil then
      Result := fcontroller.Execute(avalue)
    else
      Result := False;
end;

{ tcustomfilenameedit1 }

constructor tcustomfilenameedit1.Create(aowner: TComponent);
begin
  // fcontroller:= tfiledialogxcontroller.create(self,{$ifdef FPC}@{$endif}formatchanged);
  inherited;
  optionsedit1 := defaultfiledialogoptionsedit1;
end;

destructor tcustomfilenameedit1.Destroy;
begin
  inherited;
  // fcontroller.Free;
end;

{
function tcustomfilenameedit.execute(var avalue: msestring): boolean;
begin
 result:= fcontroller.execute(avalue);
end;
}
procedure tcustomfilenameedit1.setcontroller(const avalue: tfiledialogxcontroller);
begin
  if fcontroller <> nil then
    fcontroller.Assign(avalue);
end;

procedure tcustomfilenameedit1.readstatvalue(const reader: tstatreader);
begin
  if fgridintf <> nil then
    inherited
  else if fcontroller <> nil then
  begin
    fcontroller.readstatvalue(reader);
    Value := fcontroller.filename;
  end;
end;

procedure tcustomfilenameedit1.readstatstate(const reader: tstatreader);
begin
  if fcontroller <> nil then
    fcontroller.readstatstate(reader);
end;

procedure tcustomfilenameedit1.readstatoptions(const reader: tstatreader);
begin
  if fcontroller <> nil then
    fcontroller.readstatoptions(reader);
end;

procedure tcustomfilenameedit1.writestatvalue(const writer: tstatwriter);
begin
  if fgridintf <> nil then
    inherited
  else if fcontroller <> nil then
    fcontroller.writestatvalue(writer);
end;

procedure tcustomfilenameedit1.writestatstate(const writer: tstatwriter);
begin
  if fcontroller <> nil then
    fcontroller.writestatstate(writer);
end;

procedure tcustomfilenameedit1.writestatoptions(const writer: tstatwriter);
begin
  if fcontroller <> nil then
    fcontroller.writestatoptions(writer);
end;

function tcustomfilenameedit1.getvaluetext: msestring;
begin
  // result:= filepath(fcontroller.filename);
  if fcontroller <> nil then
    Result := fcontroller.filename
  else
    Result := '';
end;

procedure tcustomfilenameedit1.texttovalue(var accept: Boolean; const quiet: Boolean);
var
  ar1: filenamearty;
  mstr1: filenamety;
  int1: integer;
begin
  if fcontroller <> nil then
  begin
    if (fcontroller.defaultext <> '') then
    begin
      unquotefilename(Text, ar1);
      for int1 := 0 to high(ar1) do
        if not hasfileext(ar1[int1]) then
          ar1[int1] := ar1[int1] + '.' + controller.defaultext;
      mstr1         := quotefilename(ar1);
    end
    else
      mstr1         := Text;
    fcontroller.filename := mstr1;
  end;
  inherited;
end;

procedure tcustomfilenameedit1.updatedisptext(var avalue: msestring);
begin
  if fcontroller <> nil then
    with fcontroller do
    begin
      if fdo_dispname in foptions then
        avalue := msefileutils.filename(avalue);
      if fdo_dispnoext in foptions then
        avalue := removefileext(avalue);
    end;
end;

procedure tcustomfilenameedit1.valuechanged;
begin
  if fcontroller <> nil then
    fcontroller.filename := Value;
  inherited;
end;

procedure tcustomfilenameedit1.componentevent(const event: tcomponentevent);
begin
  if fcontroller <> nil then
    fcontroller.componentevent(event);
  inherited;
end;

procedure tcustomfilenameedit1.updatecopytoclipboard(var atext: msestring);
begin
  tosysfilepath1(atext);
  inherited;
end;

procedure tcustomfilenameedit1.updatepastefromclipboard(var atext: msestring);
begin
  tomsefilepath1(atext);
  inherited;
end;

function tcustomfilenameedit1.createdialogcontroller: tstringdialogcontroller;
begin
  Result := tfilenameeditcontroller.Create(self);
end;

function tcustomfilenameedit1.getsysvalue: filenamety;
begin
  Result := tosysfilepath(Value);
end;

procedure tcustomfilenameedit1.setsysvalue(const avalue: filenamety);
begin
  Value := tomsefilepath(avalue);
end;

function tcustomfilenameedit1.getsysvaluequoted: filenamety;
begin
  Result := tosysfilepath(Value, True);
end;

{ tcustomfilenameedit }

constructor tcustomfilenameedit.Create(aowner: TComponent);
begin
  fcontroller := tfiledialogxcontroller.Create(self,
                                {$ifdef FPC}
    @
{$endif}
    formatchanged);
  inherited;
end;

destructor tcustomfilenameedit.Destroy;
begin
  inherited;
  fcontroller.Free;
end;

{ tdirdropdownedit }

procedure tdirdropdownedit.createdropdownwidget(const atext: msestring; out awidget: twidget);
begin
  awidget := tdirtreefo.Create(nil);
  with tdirtreefo(awidget) do
  begin
    showhiddenfiles := ddeo_showhiddenfiles in foptions;
    checksubdir   := ddeo_checksubdir in foptions;
    path          := atext;
    onpathchanged :=
{$ifdef FPC}
      @
{$endif}
      pathchanged;
    Text          := path;
    if deo_colsizing in fdropdown.options then
      optionssizing := [osi_right];
  end;
  feditor.sellength := 0;
end;

procedure tdirdropdownedit.doafterclosedropdown;
begin
  Text := Value;
  feditor.selectall;
  inherited;
end;

function tdirdropdownedit.getdropdowntext(const awidget: twidget): msestring;
begin
  Result := tdirtreefo(awidget).path;
end;

procedure tdirdropdownedit.pathchanged(const Sender: TObject);
begin
  Text := tdirtreefo(Sender).path;
end;

function tdirdropdownedit.getshowhiddenfiles: Boolean;
begin
  Result := ddeo_showhiddenfiles in foptions;
end;

procedure tdirdropdownedit.setshowhiddenfiles(const avalue: Boolean);
begin
  if avalue then
    include(foptions, ddeo_showhiddenfiles)
  else
    exclude(foptions, ddeo_showhiddenfiles);
end;

function tdirdropdownedit.getchecksubdir: Boolean;
begin
  Result := ddeo_checksubdir in foptions;
end;

procedure tdirdropdownedit.setchecksubdir(const avalue: Boolean);
begin
  if avalue then
    include(foptions, ddeo_checksubdir)
  else
    exclude(foptions, ddeo_checksubdir);
end;

procedure tdirdropdownedit.updatecopytoclipboard(var atext: msestring);
begin
  tosysfilepath1(atext);
  inherited;
end;

procedure tdirdropdownedit.updatepastefromclipboard(var atext: msestring);
begin
  tomsefilepath1(atext);
  inherited;
end;

{ tcustomremotefilenameedit }

procedure tcustomremotefilenameedit.setfiledialog(const avalue: tfiledialogx);
begin
  setlinkedvar(avalue, tmsecomponent(fdialog));
  if avalue = nil then
    fcontroller := nil
  else
    fcontroller := avalue.fcontroller;
end;

procedure tcustomremotefilenameedit.objectevent(const Sender: TObject; const event: objecteventty);
begin
  if (event = oe_destroyed) and (Sender = fdialog) then
    fcontroller := nil;
  inherited;
end;

{ tdirtreeview }

constructor tdirtreeview.Create(aowner: TComponent);
begin
  inherited;
  createframe();
  foptionswidget   := defaultoptionswidgetsubfocus;
  fdirview         := tdirtreefo.Create(nil, self, False);
  //owner must be nil because of streaming
  fdirview.onpathchanged := @dopathchanged;
  fdirview.onselectionchanged := @doselectionchanged;
  fdirview.treeitem.ondataentered := @dopathselected;
  fdirview.grid.frame.framewidth := 0;
  fdirview.bounds_cxmin := 0;
  fdirview.anchors := [];
  fdirview.Visible := True;
end;

destructor tdirtreeview.Destroy();
begin
  fdirview.Free();
  inherited;
  //fdirview destroyed by destroy children
end;

procedure tdirtreeview.refresh();
begin
  tdirtreefo1(fdirview).updatepath();
end;

function tdirtreeview.getoptions: dirtreeoptionsty;
begin
  Result := fdirview.optionsdir;
end;

procedure tdirtreeview.setoptions(const avalue: dirtreeoptionsty);
begin
  fdirview.optionsdir := avalue;
end;

function tdirtreeview.getpath: filenamety;
begin
  if csdesigning in componentstate then
    Result := fpath
  else
    Result := fdirview.path;
end;

procedure tdirtreeview.setpath(const avalue: filenamety);
begin
  fpath           := avalue;
  if componentstate * [csdesigning, csloading] = [] then
    fdirview.path := avalue;
end;

procedure tdirtreeview.setroot(const avalue: filenamety);
begin
  froot           := avalue;
  if componentstate * [csdesigning, csloading] = [] then
    fdirview.root := avalue;
end;

function tdirtreeview.getgrid: twidgetgrid;
begin
  Result := fdirview.grid;
end;

procedure tdirtreeview.setgrid(const avalue: twidgetgrid);
begin
  //dummy
end;

function tdirtreeview.getoptionstree: treeitemeditoptionsty;
begin
  Result := fdirview.treeitem.options;
end;

procedure tdirtreeview.setoptionstree(const avalue: treeitemeditoptionsty);
begin
  fdirview.treeitem.options := avalue;
end;

function tdirtreeview.getoptionsedit: optionseditty;
begin
  Result := fdirview.treeitem.optionsedit;
end;

procedure tdirtreeview.setoptionsedit(const avalue: optionseditty);
begin
  fdirview.treeitem.optionsedit := avalue;
end;

function tdirtreeview.getcol_color: colorty;
begin
  Result := fdirview.grid.datacols[0].color;
end;

procedure tdirtreeview.setcol_color(const avalue: colorty);
begin
  fdirview.grid.datacols[0].color := avalue;
end;

function tdirtreeview.getcol_coloractive: colorty;
begin
  Result := fdirview.grid.datacols[0].coloractive;
end;

procedure tdirtreeview.setcol_coloractive(const avalue: colorty);
begin
  fdirview.grid.datacols[0].coloractive := avalue;
end;

function tdirtreeview.getcol_colorfocused: colorty;
begin
  Result := fdirview.grid.datacols[0].colorfocused;
end;

procedure tdirtreeview.setcol_colorfocused(const avalue: colorty);
begin
  fdirview.grid.datacols[0].colorfocused := avalue;
end;

function tdirtreeview.getcell_options: coloptionsty;
begin
  Result := fdirview.grid.datacols[0].options;
end;

procedure tdirtreeview.setcell_options(const avalue: coloptionsty);
begin
  fdirview.grid.datacols[0].options := avalue;
end;

{
function tdirtreeview.getcell_frame: tcellframe;
begin
 if csreading in componentstate then begin
  fdirview.grid.datacols[0].createframe();
 end;
 result:= fdirview.grid.datacols[0].frame;
end;

procedure tdirtreeview.setcell_frame(const avalue: tcellframe);
begin
 fdirview.grid.datacols[0].frame:= avalue;
end;

function tdirtreeview.getcell_face: tcellface;
begin
 if csreading in componentstate then begin
  fdirview.grid.datacols[0].createface();
 end;
 result:= fdirview.grid.datacols[0].face;
end;

procedure tdirtreeview.setcell_face(const avalue: tcellface);
begin
 if avalue <> nil then begin
  fdirview.grid.datacols[0].createface();
 end;
 fdirview.grid.datacols[0].face:= avalue;
end;

function tdirtreeview.getcell_datalist: ttreeitemeditlist;
begin
 result:= ttreeitemeditlist(fdirview.grid.datacols[0].datalist);
end;

procedure tdirtreeview.setcell_datalist(const avalue: ttreeitemeditlist);
begin
 fdirview.grid.datacols[0].datalist:= avalue;
end;
}
procedure tdirtreeview.dopathchanged(const Sender: TObject);
begin
  if canevent(tmethod(fonpathchanged)) then
    fonpathchanged(self, fdirview.path);
end;

procedure tdirtreeview.dopathselected(const Sender: TObject);
begin
  if canevent(tmethod(fonpathselected)) then
    fonpathselected(self, fdirview.path);
end;

procedure tdirtreeview.doselectionchanged(const Sender: TObject; const aitem: tlistitem);
begin
  if canevent(tmethod(fonselectionchanged)) then
    fonselectionchanged(self, aitem);
end;

procedure tdirtreeview.internalcreateframe;
begin
  timpressedcaptionframe.Create(icaptionframe(self));
end;

procedure tdirtreeview.loaded();
begin
  inherited;
  if not (csdesigning in componentstate) then
    with tdirtreefo1(fdirview) do
    begin
      froot := self.froot;
      path  := self.fpath;
    end;
end;

class function tdirtreeview.classskininfo: skininfoty;
begin
  Result := inherited classskininfo;
  Result.objectkind := sok_dataedit;
end;

end.
