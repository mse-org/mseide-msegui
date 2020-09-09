
{ MSEgui Copyright (c) 1999-2016 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}

{ msefiledialogx by fredvs 2020 }

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
  Math,
  mseglob,
  mseguiglob,
  mseforms,
  Classes,
  mclasses,
  mseclasses,
  msewidgets,
  msegrids,
  mselistbrowser,
  mseedit,
  msesimplewidgets,
  msedataedits,
  msedialog,
  msetypes,
  msestrings,
  msesystypes,
  msesys,
  msedispwidgets,
  msedatalist,
  msestat,
  msestatfile,
  msebitmap,
  msedatanodes,
  msefileutils,
  msedropdownlist,
  mseevent,
  msegraphedits,
  mseeditglob,
  msesplitter,
  msemenus,
  msegridsglob,
  msegraphics,
  msegraphutils,
  msedirtree,
  msewidgetgrid,
  mseact,
  mseapplication,
  msegui,
  mseificomp,
  mseificompglob,
  mseifiglob,
  msestream,
  SysUtils,
  msemenuwidgets,
  msescrollbar,
  msedragglob,
  msefiledialog,
  mserichstring;

const
  defaultlistviewoptionsfile = defaultlistviewoptions + [lvo_readonly, lvo_horz];

type
  tfilelistitem = class(tlistitem)
  private
  protected
  public

    constructor Create(const aowner: tcustomitemlist);
      override;
  end;

  pfilelistitem = ^tfilelistitem;

  tfileitemlist = class(titemviewlist)
  protected
    procedure createitem(out item: tlistitem);
      override;
  end;

  getfileiconeventty = procedure(const Sender: TObject; const ainfo: fileinfoty; var imagelist: timagelist; var imagenr: integer) of object;

  tfilelistview = class(tlistview)
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
    procedure docellevent(var info: celleventinfoty);
      override;
  public

    constructor Create(aowner: TComponent);
      override;

    destructor Destroy;
      override;
    procedure readlist;
    procedure updir;
    function filecount: integer;
    property directory: filenamety read fdirectory write setdirectory;
    property includeattrib: fileattributesty read fincludeattrib write fincludeattrib default [fa_all];
    property excludeattrib: fileattributesty read fexcludeattrib write fexcludeattrib default [fa_hidden];
    property maskar: filenamearty read fmaskar write fmaskar;
    //nil -> all
    property mask: filenamety read getmask write setmask;
    //'' -> all
    property path: filenamety read getpath write setpath;
    //calls readlist
    property selectednames: filenamearty read getselectednames write setselectednames;
    property checksubdir: Boolean read getchecksubdir write setchecksubdir;
  published
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
  filedialogoptionty  = (fdo_filtercasesensitive,    //flvo_maskcasesensitive
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
  filedialogoptionsty = set of filedialogoptionty;

const
  defaultfiledialogoptions = [fdo_savelastdir];

type
  filedialogkindty = (fdk_none, fdk_open, fdk_save, fdk_new, fdk_dir);

  tfiledialogcontroller = class;

  filedialogbeforeexecuteeventty = procedure(const Sender: tfiledialogcontroller; var dialogkind: filedialogkindty; var aresult: modalresultty) of object;
  filedialogafterexecuteeventty  = procedure(const Sender: tfiledialogcontroller; var aresult: modalresultty) of object;

  tfiledialogcontroller = class(tlinkedpersistent)
  private
    fowner: tmsecomponent;
    fgroup: integer;
    ffontname: msestring;
    ffontheight: integer;
    fsplitterplaces: integer;
    ffontcolor: colorty;
    fbackcolor: colorty;
    fonchange: proceventty;
    ffilenames: filenamearty;
    ffilterlist: tdoublemsestringdatalist;
    ffilter: filenamety;
    fnopanel: Boolean;
    ficon : tmaskedbitmap;
    fcompact: Boolean;
    ffilenamescust: filenamearty;
    fshowhidden: Boolean;
    ffilterindex: integer;
    fcolwidth: integer;
    fcolsizewidth: integer;
    fcolextwidth: integer;
    fcoldatewidth: integer;
    fwindowrect: rectty;
    fhistorymaxcount: integer;
    fhistory: msestringarty;
    fcaptionopen: msestring;
    fcaptionsave: msestring;
    fcaptionnew: msestring;
    fcaptiondir: msestring;
    finclude: fileattributesty;
    fexclude: fileattributesty;
    fonbeforeexecute: filedialogbeforeexecuteeventty;
    fonafterexecute: filedialogafterexecuteeventty;
    fongetfilename: setstringeventty;
    fongetfileicon: getfileiconeventty;
    foncheckfile: checkfileeventty;
    fimagelist: timagelist;
    fparams: msestring;
    procedure seticon(const avalue: tmaskedbitmap);
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
  public

    constructor Create(const aowner: tmsecomponent = nil; const onchange: proceventty = nil);
      reintroduce;

    destructor Destroy;
      override;
    procedure readstatvalue(const reader: tstatreader);
    procedure readstatstate(const reader: tstatreader);
    procedure readstatoptions(const reader: tstatreader);
    procedure writestatvalue(const writer: tstatwriter);
    procedure writestatstate(const writer: tstatwriter);
    procedure writestatoptions(const writer: tstatwriter);
    function actcaption(const dialogkind: filedialogkindty): msestring;
    function Execute(dialogkind: filedialogkindty = fdk_none): modalresultty;
      overload;
    //fdk_none -> use options fdo_save
    function Execute(dialogkind: filedialogkindty; const acaption: msestring; aoptions: filedialogoptionsty): modalresultty;
      overload;
    function Execute(const dialogkind: filedialogkindty; const acaption: msestring): modalresultty;
      overload;
    function Execute(const dialogkind: filedialogkindty; const aoptions: filedialogoptionsty): modalresultty;
      overload;
    function Execute(var avalue: filenamety; dialogkind: filedialogkindty = fdk_none): Boolean;
      overload;
    function Execute(var avalue: filenamety; const dialogkind: filedialogkindty; const acaption: msestring): Boolean;
      overload;
    function Execute(var avalue: filenamety; const dialogkind: filedialogkindty; const acaption: msestring; aoptions: filedialogoptionsty): Boolean;
      overload;
    function canoverwrite(): Boolean;
    //true if current filename is allowed to write
    procedure Clear;
    procedure componentevent(const event: tcomponentevent);
    property history: msestringarty read fhistory write fhistory;
    property filenames: filenamearty read ffilenames write ffilenames;
    property filenamescust: filenamearty read ffilenamescust write ffilenamescust;
    property syscommandline: filenamety read getsysfilename; deprecated;
    property sysfilename: filenamety read getsysfilename;
    property params: msestring read fparams;
  published
    property filename: filenamety read getfilename write setfilename;
    property lastdir: filenamety read flastdir write setlastdir;
    property basedir: filenamety read fbasedir write fbasedir;
    property fontheight: integer read ffontheight write ffontheight;
    property fontname: msestring read ffontname write ffontname;
    property fontcolor: colorty read ffontcolor write ffontcolor;
    property backcolor: colorty read fbackcolor write fbackcolor;
    property filter: filenamety read ffilter write ffilter;
    property nopanel: Boolean read fnopanel write fnopanel;
    property icon : tmaskedbitmap read ficon write seticon;
    property compact: Boolean read fcompact write fcompact;
    property showhidden: Boolean read fshowhidden write fshowhidden;
    property filterlist: tdoublemsestringdatalist read ffilterlist write setfilterlist;
    property filterindex: integer read ffilterindex write ffilterindex default 0;
    property include: fileattributesty read finclude write finclude default [fa_all];
    property exclude: fileattributesty read fexclude write fexclude default [fa_hidden];
    property colwidth: integer read fcolwidth write fcolwidth default 0;
    property defaultext: filenamety read fdefaultext write setdefaultext;
    property options: filedialogoptionsty read foptions write setoptions default defaultfiledialogoptions;
    property historymaxcount: integer read fhistorymaxcount write sethistorymaxcount default defaulthistorymaxcount;
    property captionopen: msestring read fcaptionopen write fcaptionopen;
    property captionsave: msestring read fcaptionsave write fcaptionsave;
    property captionnew: msestring read fcaptionnew write fcaptionnew;
    property captiondir: msestring read fcaptiondir write fcaptiondir;
    property group: integer read fgroup write fgroup default 0;
    property imagelist: timagelist read fimagelist write setimagelist;
    property ongetfilename: setstringeventty read fongetfilename write fongetfilename;
    property ongetfileicon: getfileiconeventty read fongetfileicon write fongetfileicon;
    property oncheckfile: checkfileeventty read foncheckfile write foncheckfile;
    property onbeforeexecute: filedialogbeforeexecuteeventty read fonbeforeexecute write fonbeforeexecute;
    property onafterexecute: filedialogafterexecuteeventty read fonafterexecute write fonafterexecute;
  end;

const
  defaultfiledialogoptionsedit1 = defaultoptionsedit1 +
    [oe1_savevalue, oe1_savestate, oe1_saveoptions];

type
  tfiledialogx = class(tdialog, istatfile)
  private
    fcontroller: tfiledialogcontroller;
    fstatvarname: msestring;
    fstatfile: tstatfile;
    fdialogkind: filedialogkindty;
    //   foptionsedit: optionseditty;
    foptionsedit1: optionsedit1ty;
    fstatpriority: integer;
    procedure setcontroller(const Value: tfiledialogcontroller);
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

    constructor Create(aowner: TComponent);
      override;

    destructor Destroy;
      override;
    function Execute: modalresultty;
      overload;
      override;
    function Execute(const akind: filedialogkindty): modalresultty;
      reintroduce;
      overload;
    function Execute(const akind: filedialogkindty; const aoptions: filedialogoptionsty): modalresultty;
      reintroduce;
      overload;
    procedure componentevent(const event: tcomponentevent);
      override;
  published
    property statfile: tstatfile read fstatfile write setstatfile;
    property statvarname: msestring read getstatvarname write fstatvarname;
    property statpriority: integer read fstatpriority write fstatpriority default 0;
    property controller: tfiledialogcontroller read fcontroller write setcontroller;
    property dialogkind: filedialogkindty read fdialogkind write fdialogkind default fdk_none;
    property optionsedit1: optionsedit1ty read foptionsedit1 write foptionsedit1 default defaultfiledialogoptionsedit1;

  end;

  tcustomfilenameedit1 = class;

  tfilenameeditcontroller = class(tstringdialogcontroller)
  protected
    function Execute(var avalue: msestring): Boolean;
      override;
  public

    constructor Create(const aowner: tcustomfilenameedit1);
  end;

  tcustomfilenameedit1 = class(tcustomdialogstringed)
  private
    fcontroller: tfiledialogcontroller;
    procedure setcontroller(const avalue: tfiledialogcontroller);
    function getsysvalue: filenamety;
    procedure setsysvalue(const avalue: filenamety);
    function getsysvaluequoted: filenamety;
  protected
    function createdialogcontroller: tstringdialogcontroller;
      override;
    procedure texttovalue(var accept: Boolean; const quiet: Boolean);
      override;
    procedure updatedisptext(var avalue: msestring);
      override;
    function getvaluetext: msestring;
      override;
    procedure readstatvalue(const reader: tstatreader);
      override;
    procedure readstatstate(const reader: tstatreader);
      override;
    procedure readstatoptions(const reader: tstatreader);
      override;
    procedure writestatvalue(const writer: tstatwriter);
      override;
    procedure writestatstate(const writer: tstatwriter);
      override;
    procedure writestatoptions(const writer: tstatwriter);
      override;
    procedure valuechanged;
      override;
    procedure updatecopytoclipboard(var atext: msestring);
      override;
    procedure updatepastefromclipboard(var atext: msestring);
      override;
  public

    constructor Create(aowner: TComponent);
      override;

    destructor Destroy;
      override;
    procedure componentevent(const event: tcomponentevent);
      override;
    property controller: tfiledialogcontroller read fcontroller write setcontroller;
    property sysvalue: filenamety read getsysvalue write setsysvalue;
    property sysvaluequoted: filenamety read getsysvaluequoted write setsysvalue;
  published
    property optionsedit1 default defaultfiledialogoptionsedit1;
  end;

  tcustomfilenameedit = class(tcustomfilenameedit1)
  public

    constructor Create(aowner: TComponent);
      override;

    destructor Destroy;
      override;
  end;

  tcustomremotefilenameedit = class(tcustomfilenameedit1)
  private
    fdialog: tfiledialogx;
    procedure setfiledialog(const avalue: tfiledialogx);
  protected
    procedure objectevent(const Sender: TObject; const event: objecteventty);
      override;
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
    procedure createdropdownwidget(const atext: msestring; out awidget: twidget);
      override;
    function getdropdowntext(const awidget: twidget): msestring;
      override;
    procedure pathchanged(const Sender: TObject);
    procedure doafterclosedropdown;
      override;
    procedure updatecopytoclipboard(var atext: msestring);
      override;
    procedure updatepastefromclipboard(var atext: msestring);
      override;
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
    procedure internalcreateframe;
      override;
    procedure loaded();
      override;
    class function classskininfo: skininfoty;
      override;
  public

    constructor Create(aowner: TComponent);
      override;

    destructor Destroy();
      override;
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

  tfiledialogfo = class(tmseform)
    tlayouter2: tlayouter;
    dir: tdirdropdownedit;
    up: tstockglyphbutton;
    back: tstockglyphbutton;
    forward: tstockglyphbutton;
    filename: thistoryedit;
    filter: tdropdownlistedit;
    showhidden: tbooleanedit;
    list_log: tstringgrid;
    home: TButton;
    createdir: TButton;
    cancel: TButton;
    ok: TButton;
    bcompact: tbooleanedit;
    tsplitter1: tsplitter;
    listview: tfilelistview;
    blateral: tbooleanedit;
    iconslist: timagelist;
    tsplitter2: tsplitter;
    placespan: tstringdisp;
    places: tstringgrid;
    tsplitter3: tsplitter;
    placescust: tstringgrid;
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
    procedure showhiddenonsetvalue(const Sender: TObject; var avalue: Boolean; var accept: Boolean);
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
    procedure oncreat(const Sender: TObject);
    procedure onbefdrop(const Sender: TObject);
    procedure oncellevplaces(const Sender: TObject; var info: celleventinfoty);
    procedure ondrawcellplace(const Sender: tcol; const Canvas: tcanvas; var cellinfo: cellinfoty);
    procedure onlayout(const Sender: tcustomgrid);
    procedure onformcreated(const Sender: TObject);
    procedure onlateral(const Sender: TObject; var avalue: Boolean; var accept: Boolean);
    procedure afterclosedrop(const Sender: TObject);
    procedure onresize(const Sender: TObject);
    procedure onchangdir(const Sender: TObject);
    procedure ondrawcellplacescust(const Sender: tcol; const Canvas: tcanvas; var cellinfo: cellinfoty);
    procedure oncellevcustplaces(const Sender: TObject; var info: celleventinfoty);
  private
    fselectednames: filenamearty;
    finit: Boolean;
    fcourse: filenamearty;
    fcourseid: int32;
    fcourselock: Boolean;
    procedure updatefiltertext;
    function tryreadlist(const adir: filenamety; const errormessage: Boolean): Boolean;
    //restores old dir on error
    function changedir(const adir: filenamety): Boolean;
    procedure checkcoursebuttons();
    procedure course(const adir: filenamety);
    procedure doup();
  public
    dialogoptions: filedialogoptionsty;
    defaultext: filenamety;
    filenames: filenamearty;
  end;

function filedialog(var afilenames: filenamearty; const aoptions: filedialogoptionsty; const acaption: msestring;    //'' -> 'Open' or 'Save'
  const filterdesc: array of msestring; const filtermask: array of msestring; const adefaultext: filenamety = ''; const filterindex: pinteger = nil;     //nil -> 0
  const filter: pfilenamety = nil;       //nil -> unused
  const colwidth: pinteger = nil;        //nil -> default
  const includeattrib: fileattributesty = [fa_all]; const excludeattrib: fileattributesty = [fa_hidden]; const history: pmsestringarty = nil; const historymaxcount: integer = defaulthistorymaxcount;
  const imagelist: timagelist = nil; const ongetfileicon: getfileiconeventty = nil; const oncheckfile: checkfileeventty = nil): modalresultty;
  overload;
//threadsafe
function filedialog(var afilename: filenamety; const aoptions: filedialogoptionsty; const acaption: msestring; const filterdesc: array of msestring; const filtermask: array of msestring;
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
  theimagelist: timagelist;

implementation

uses
  msefiledialogx_mfm,
  msebits,
  mseactions,
  msestringenter,
  msekeyboard,
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

type
  tdirtreefo1 = class(tdirtreefo);
  tcomponent1 = class(TComponent);

// not needed anymore
procedure getfileicon(const info: fileinfoty; var imagelist: timagelist; out imagenr: integer);
begin
  imagelist := theimagelist;
  with info do
  begin
    //  imagelist:= nil;
    imagenr := -1;
    if fis_typevalid in state then
      case extinfo1.filetype of
        ft_dir: imagenr         := 0;
        ft_reg, ft_lnk: imagenr := 1;
      end;
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

function filedialog1(dialog: tfiledialogfo; var afilenames: filenamearty; const filterdesc: array of msestring; const filtermask: array of msestring; const filterindex: pinteger; const afilter: pfilenamety;      //nil -> unused
  const colwidth: pinteger;        //nil -> default
  const includeattrib: fileattributesty; const excludeattrib: fileattributesty; const history: pmsestringarty; const historymaxcount: integer; const acaption: msestring; const aoptions: filedialogoptionsty;
  const adefaultext: filenamety; const imagelist: timagelist; const ongetfileicon: getfileiconeventty; const oncheckfile: checkfileeventty): modalresultty;
var
  int1: integer;
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
      listview.optionsfile := listview.optionsfile + [flvo_maskcaseinsensitive
        ];
    if fdo_single in aoptions then
      listview.options     := listview.options - [lvo_multiselect];
    defaultext := adefaultext;
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
    else
      filename.dropdown.options := [deo_disabled];
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

    abool := True;

    if blateral.Value then
      onlateral(nil, abool, abool);
    if bcompact.Value then
      onsetcomp(nil, abool, abool);
    if showhidden.Value then
      showhiddenonsetvalue(nil, abool, abool);
    //  showhidden.Value := not (fa_hidden in excludeattrib);

    Show(True);
    Result      := window.modalresult;
    if Result <> mr_ok then
      Result    := mr_cancel;
    if (colwidth <> nil) then
      colwidth^ := listview.cellwidth;
    if Result = mr_ok then
    begin
      afilenames     := filenames;
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

function filedialog(var afilenames: filenamearty; const aoptions: filedialogoptionsty; const acaption: msestring; const filterdesc: array of msestring; const filtermask: array of msestring;
  const adefaultext: filenamety = ''; const filterindex: pinteger = nil; const filter: pfilenamety = nil;       //nil -> unused
  const colwidth: pinteger = nil;        //nil -> default
  const includeattrib: fileattributesty = [fa_all]; const excludeattrib: fileattributesty = [fa_hidden]; const history: pmsestringarty = nil; const historymaxcount: integer = defaulthistorymaxcount;
  const imagelist: timagelist = nil; const ongetfileicon: getfileiconeventty = nil; const oncheckfile: checkfileeventty = nil): modalresultty;
var
  dialog: tfiledialogfo;
  str1: msestring;
begin
  application.lock;
  try
    dialog := tfiledialogfo.Create(nil);
    if acaption = '' then
    begin
      with stockobjects do
        if fdo_save in aoptions then
          str1 := captions[sc_save]
        else
          str1 := captions[sc_open];
    end
    else
      str1 := acaption;
    try
      Result := filedialog1(dialog, afilenames, filterdesc, filtermask,
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

function filedialog(var afilename: filenamety; const aoptions: filedialogoptionsty; const acaption: msestring; const filterdesc: array of msestring; const filtermask: array of msestring;
  const adefaultext: filenamety = ''; const filterindex: pinteger = nil; const filter: pfilenamety = nil;       //nil -> unused
  const colwidth: pinteger = nil;        //nil -> default
  const includeattrib: fileattributesty = [fa_all]; const excludeattrib: fileattributesty = [fa_hidden]; const history: pmsestringarty = nil; const historymaxcount: integer = defaulthistorymaxcount;
  const imagelist: timagelist = nil; const ongetfileicon: getfileiconeventty = nil; const oncheckfile: checkfileeventty = nil): modalresultty;
var
  ar1: filenamearty;
begin
  setlength(ar1, 1);
  ar1[0] := afilename;
  Result := filedialog(ar1, aoptions, acaption, filterdesc, filtermask, adefaultext,
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

{ tfilelistview }

constructor tfilelistview.Create(aowner: TComponent);
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

destructor tfilelistview.Destroy;
begin
  inherited;
  ffilelist.Free;
end;

procedure tfilelistview.checkcasesensitive;
begin
  fcaseinsensitive   := filesystemiscaseinsensitive;
  if flvo_maskcasesensitive in foptionsfile then
    fcaseinsensitive := False;
  if flvo_maskcaseinsensitive in foptionsfile then
    fcaseinsensitive := True;
  // options:= options; //set casesensitive
end;

{
procedure tfilelistview.setoptions(const Value: listviewoptionsty);
begin
 if fcaseinsensitive then begin
  inherited setoptions(value - [lvo_casesensitive]);
 end
 else begin
  inherited setoptions(value + [lvo_casesensitive]);
 end;
end;
}
procedure tfilelistview.docellevent(var info: celleventinfoty);
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

procedure tfilelistview.filelistchanged(const Sender: TObject);
var
  int1: integer;
  po1: pfilelistitem;
  po2: pfileinfoty;
  imlist1: timagelist;
  imnr1: integer;
  bo1: Boolean;
begin
  options := options - [lvo_focusselect];
  options := options + [lvo_horz];

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

function tfilelistview.getselectednames: msestringarty;
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

procedure tfilelistview.setselectednames(const avalue: filenamearty);
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

procedure tfilelistview.setfilelist(const Value: tfiledatalist);
begin
  if ffilelist <> Value then
    ffilelist.Assign(Value);
end;

procedure tfilelistview.readlist;
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

procedure tfilelistview.updir;
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

procedure tfilelistview.setdirectory(const Value: msestring);
begin
  fdirectory := filepath(Value, fk_dir);
end;

function tfilelistview.getpath: msestring;
begin
  if fmaskar = nil then
    Result := filepath(fdirectory)
  else
    Result := filepath(fdirectory, fmaskar[0]);
end;

procedure tfilelistview.setpath(const Value: filenamety);
var
  str1: msestring;
begin
  splitfilepath(Value, fdirectory, str1);
  mask := str1;
  readlist;
end;

procedure tfilelistview.setmask(const Value: filenamety);
begin
  unquotefilename(Value, fmaskar);
end;

function tfilelistview.getmask: filenamety;
begin
  Result := quotefilename(fmaskar);
end;

function tfilelistview.filecount: integer;
begin
  if ffilelist.Count < ffilecount then
    ffilecount := 0;
  Result       := ffilecount;
end;

function tfilelistview.getchecksubdir: Boolean;
begin
  Result := flvo_checksubdir in foptionsfile;
end;

procedure tfilelistview.setchecksubdir(const avalue: Boolean);
begin
  if avalue then
    include(foptionsfile, flvo_checksubdir)
  else
    exclude(foptionsfile, flvo_checksubdir);
end;

procedure tfilelistview.setoptionsfile(const avalue: filelistviewoptionsty);
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

{ tfiledialogfo }

procedure Tfiledialogfo.createdironexecute(const Sender: TObject);
var
  mstr1: msestring;
begin
  mstr1 := '';
  with stockobjects do
    if stringenter(mstr1, captions[sc_name],
      captions[sc_create_new_directory]) = mr_ok then
    begin
      places.defocuscell;
      places.datacols.clearselection;
      mstr1 := filepath(listview.directory, mstr1, fk_file);
      msefileutils.createdir(mstr1);
      changedir(mstr1);
      filename.SetFocus;
    end;
end;

procedure tfiledialogfo.listviewselectionchanged(const Sender: tcustomlistview);
var
  ar1: msestringarty;
begin
  ar1 := nil;
  //compiler warning
  if not (fdo_directory in dialogoptions) then
  begin
    ar1 := listview.selectednames;
    if length(ar1) > 0 then
    begin
      if length(ar1) > 1 then
        filename.Value := quotefilename(ar1)
      else
      begin
        filename.Value := ar1[0];
      end;
    end
    else
      //   filename.value:= ''; //dir chanaged
    ;
  end;

  if filename.tag = 1 then
    filename.Value := dir.Value;
end;

function tfiledialogfo.changedir(const adir: filenamety): Boolean;
begin
  Result := tryreadlist(filepath(adir), True);
  if Result then
    course(adir);


  with listview do
    if filelist.Count > 0 then
      focuscell(makegridcoord(0, 0));

end;

procedure tfiledialogfo.listviewitemevent(const Sender: tcustomlistview; const index: integer; var info: celleventinfoty);
var
  str1: filenamety;
begin
  with tfilelistview(Sender) do
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

procedure tfiledialogfo.doup();
begin
  listview.updir();
  course(listview.directory);
end;

procedure tfiledialogfo.listviewonkeydown(const Sender: twidget; var info: keyeventinfoty);
begin
  with info do
    if (key = key_pageup) and (shiftstate = [ss_ctrl]) then
    begin
      doup();
      include(info.eventstate, es_processed);
    end;
end;

procedure Tfiledialogfo.upaction(const Sender: TObject);
begin
  places.defocuscell;
  places.datacols.clearselection;
  doup();
end;

{
function tfiledialogfo.readlist: boolean;
begin
 result:= true;
 try
  with listview do begin
   readlist;
  end;
 except
  on ex: esys do begin
   result:= false;
  // if esys(ex).error = sye_dirstream then begin
    listview.directory:= '';
    with stockobjects do begin
     showerror(captions[sc_can_not_read_directory]+ ' ' + esys(ex).text,
               captions[sc_error]);
//     showerror('Can not read directory '''+ esys(ex).text+'''.','Error');
    end;
    try
     listview.readlist;
    except
     application.handleexception(self);
    end;
//   end
//   else begin
//    application.handleexception(self);
//   end;
  end;
  else begin
   result:= false;
   application.handleexception(self);
  end;
 end;
end;
}
function tfiledialogfo.tryreadlist(const adir: filenamety; const errormessage: Boolean): Boolean;
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
        with stockobjects do
          showerror(captions[sc_can_not_read_directory] + ' ' +
            msestring(esys(ex).Text), captions[sc_error]);
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

procedure Tfiledialogfo.filenamesetvalue(const Sender: TObject; var avalue: msestring; var accept: Boolean);
var
  str1, str2, str3: filenamety;
  // ar1: msestringarty;
  bo1: Boolean;
  newdir: filenamety;
begin
  newdir := '';
  avalue := trim(avalue);
  unquotefilename(avalue, fselectednames);

  if (fdo_single in dialogoptions) and (high(fselectednames) > 0) then
  begin
    with stockobjects do
      ShowMessage(captions[sc_single_item_only] + '.', captions[sc_error]);
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
end;

procedure tfiledialogfo.filepathentered(const Sender: TObject);
begin
  tryreadlist(listview.directory, True);
  // readlist;
  if filename.tag = 1 then
    filename.Value := dir.Value;
end;

procedure tfiledialogfo.dironsetvalue(const Sender: TObject; var avalue: mseString; var accept: Boolean);
begin
  places.defocuscell;
  places.datacols.clearselection;

  accept := tryreadlist(avalue, True);
  if accept then
    course(avalue);
  listview.directory := avalue;
  if filename.tag = 1 then
    filename.Value   := dir.Value
  else
    filename.Value   := '';
end;

procedure tfiledialogfo.listviewonlistread(const Sender: TObject);
var
  x, x2, y, y2, z: integer;
  info: fileinfoty;
  thedir, thestrnum, thestrfract, thestrx, thestrext, tmp, tmp2: string;
begin

  listview.Width := 40;
  listview.invalidate;

  with listview do
  begin
    dir.Value        := tosysfilepath(directory);
    if fdo_directory in self.dialogoptions then
      filename.Value := tosysfilepath(directory);
  end;

  list_log.rowcount := listview.rowcount;

  for x := 0 to listview.rowcount - 1 do
  begin
    list_log[0][x] := '';
    list_log[1][x] := '';
    list_log[2][x] := '';
    list_log[3][x] := '';
    list_log[4][x] := '';
  end;

  y  := 0;
  x2 := 0;

  if listview.rowcount > 0 then
    for x := 0 to listview.rowcount - 1 do
    begin
      list_log[4][x] := IntToStr(x);

      if listview.filelist.isdir(x) then
      begin
        Inc(x2);
        list_log[0][x] := '       ' + msestring(listview.itemlist[x].Caption);
        list_log[1][x] := '';
      end
      else
      begin
        list_log[0][x] := '  .    ' + msestring(filenamebase(listview.itemlist[x].Caption));
        tmp := fileext(listview.itemlist[x].Caption);
        if tmp <> '' then
          tmp := '.' + tmp;
        list_log[1][x] := msestring(tmp);
        list_log[0][x] := list_log[0][x] + list_log[1][x];
      end;

      dir.Value := tosysfilepath(dir.Value);

      thedir := tosysfilepath(dir.Value + (listview.itemlist[x].Caption));

      getfileinfo(msestring(trim(thedir)), info);

      if not listview.filelist.isdir(x) then
      begin

        if info.extinfo1.size div 1000000000 > 0 then
        begin
          y2        := Trunc(Frac(info.extinfo1.size / 1000000000) * Power(10, 1));
          y         := info.extinfo1.size div 1000000000;
          thestrx   := '~';
          thestrext := ' GB ';
        end
        else if info.extinfo1.size div 1000000 > 0 then
        begin
          y2        := Trunc(Frac(info.extinfo1.size / 1000000) * Power(10, 1));
          y         := info.extinfo1.size div 1000000;
          thestrx   := '_';
          thestrext := ' MB ';
        end
        else if info.extinfo1.size div 1000 > 0 then
        begin
          y2        := Trunc(Frac(info.extinfo1.size / 1000) * Power(10, 1));
          y         := info.extinfo1.size div 1000;
          thestrx   := '^';
          thestrext := ' KB ';
        end
        else
        begin
          y2        := 0;
          y         := info.extinfo1.size;
          thestrx   := ' ';
          thestrext := ' B ';
        end;

        thestrnum := IntToStr(y);

        z := Length(thestrnum);

        if z < 15 then
          for y := 0 to 14 - z do
            thestrnum := ' ' + thestrnum;

        if y2 > 0 then
          thestrfract := '.' + IntToStr(y2)
        else
          thestrfract := '';

        list_log[2][x] := thestrx + thestrnum + thestrfract + thestrext;
      end;

      list_log[3][x] := formatdatetime('YY-MM-DD hh:mm:ss', info.extinfo1.modtime);

    end; // else dir.frame.caption := 'Directory with 0 files';

  if bcompact.Value then
  begin
    listview.Width := list_log.Width;
    listview.invalidate;
  end;

  list_log.defocuscell;
  list_log.datacols.clearselection;

  dir.frame.Caption := 'Directory with ' + IntToStr(list_log.rowcount - x2) + ' files';

  if filename.tag = 1 then
    filename.Value := (dir.Value)
  else
    filename.Value := '';

  filename.Value := tosysfilepath(filename.Value);

end;

procedure tfiledialogfo.updatefiltertext;
begin
  with filter, dropdown do
    if ItemIndex >= 0 then
    begin
      Value         := cols[0][ItemIndex];
      listview.mask := cols[1][ItemIndex];
    end;
end;

procedure tfiledialogfo.filteronafterclosedropdown(const Sender: TObject);
begin
  updatefiltertext;
  filter.initfocus;
  tsplitter2.left      := 420;
  filter.frame.Caption := '&Filter';
end;

procedure tfiledialogfo.filteronsetvalue(const Sender: TObject; var avalue: msestring; var accept: Boolean);
begin
  listview.mask := avalue;
end;

procedure tfiledialogfo.okonexecute(const Sender: TObject);
var
  bo1: Boolean;
  int1: integer;
  str1: filenamety;
begin

  if (filename.Value <> '') or (fdo_acceptempty in dialogoptions) or (filename.tag = 1) then
  begin
    if (fdo_directory in dialogoptions) or (filename.tag = 1) then
      str1 := quotefilename(listview.directory)
    else
    begin
      str1 := quotefilename(listview.directory, filename.Value);
    end;
    unquotefilename(str1, filenames);
    if (defaultext <> '') then
      for int1 := 0 to high(filenames) do
        if not hasfileext(filenames[int1]) then
          filenames[int1] := filenames[int1] + '.' + defaultext;
    if (fdo_checkexist in dialogoptions) and not ((filename.Value = '') and (fdo_acceptempty in dialogoptions)) then
    begin
      if fdo_directory in dialogoptions then
        bo1 := finddir(filenames[0])
      else
        bo1 := findfile(filenames[0]);
      if fdo_save in dialogoptions then
      begin
        if bo1 then
          with stockobjects do
            if not askok(captions[sc_file] + ' "' + filenames[0] +
              '" ' + captions[sc_exists_overwrite],
              captions[sc_warningupper]) then
            begin
              //      if not askok('File "'+filenames[0]+
              //            '" exists, do you want to overwrite?','WARNING') then begin
              filename.SetFocus;
              Exit;
            end;
      end
      else if not bo1 then
      begin
        with stockobjects do
          showerror(captions[sc_file] + ' "' + filenames[0] + '" ' +
            captions[sc_does_not_exist] + '.',
            captions[sc_errorupper]);
        //      showerror('File "'+filenames[0]+'" does not exist.');
        filename.SetFocus;
        Exit;
      end;
    end;
    window.modalresult := mr_ok;
  end
  else
    filename.SetFocus;
  // end;
end;

procedure tfiledialogfo.layoutev(const Sender: TObject);
begin
  listview.synctofontheight;
end;

procedure tfiledialogfo.showhiddenonsetvalue(const Sender: TObject; var avalue: Boolean; var accept: Boolean);
begin
  dir.showhiddenfiles      := avalue;
  if avalue then
    listview.excludeattrib := listview.excludeattrib - [fa_hidden]
  else
    listview.excludeattrib := listview.excludeattrib + [fa_hidden];
  listview.readlist;
end;

procedure tfiledialogfo.dirshowhint(const Sender: TObject; var info: hintinfoty);
begin
  if dir.editor.textclipped then
    info.Caption := dir.Value;
end;

procedure tfiledialogfo.copytoclip(const Sender: TObject; var avalue: msestring);
begin
  tosysfilepath1(avalue);
end;

procedure tfiledialogfo.pastefromclip(const Sender: TObject; var avalue: msestring);
begin
  tomsefilepath1(avalue);
end;

procedure tfiledialogfo.homeaction(const Sender: TObject);
begin
  places.defocuscell;
  places.datacols.clearselection;
  if tryreadlist(sys_getuserhomedir, True) then
  begin
    dir.Value := tosysfilepath(listview.directory);
    course(listview.directory);
  end;
end;

procedure tfiledialogfo.checkcoursebuttons();
begin
  back.Enabled    := fcourseid > 0;
  forward.Enabled := fcourseid < high(fcourse);
end;

procedure tfiledialogfo.course(const adir: filenamety);
begin
  if not fcourselock then
  begin
    Inc(fcourseid);
    setlength(fcourse, fcourseid + 1);
    fcourse[fcourseid] := adir;
    checkcoursebuttons();
  end;
end;

procedure tfiledialogfo.backexe(const Sender: TObject);
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

procedure tfiledialogfo.forwardexe(const Sender: TObject);
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

procedure tfiledialogfo.buttonshowhint(const Sender: TObject; var ainfo: hintinfoty);
begin
  with tcustombutton(Sender) do
    ainfo.Caption := sc(stockcaptionty(tag)) + ' ' +
      '(' + encodeshortcutname(shortcut) + ')';
end;

procedure tfiledialogfo.oncellev(const Sender: TObject; var info: celleventinfoty);
var
  cellpos, cellpos2: gridcoordty;
  x, y: integer;
  str1: string;
begin

  if (list_log.rowcount > 0) and ((info.eventkind = cek_buttonrelease) or (info.eventkind = cek_keyup)) then
    if (info.cell.row > -1) then
    begin

      cellpos := info.cell;

      cellpos.col  := 0;
      cellpos2.col := 0;

      places.defocuscell;
      places.datacols.clearselection;

      y := StrToInt(list_log[4][cellpos.row]);
      cellpos2.row := y;

      if listview.filelist.isdir(y) then
      begin
        listview.defocuscell;
        listview.datacols.clearselection;
        str1 := tosysfilepath(filepath(dir.Value + listview.filelist[y].Name));

        if (info.eventkind = cek_buttonrelease) then
        begin
          if (ss_double in info
            .mouseeventinfopo^.shiftstate) then
            okonexecute(Sender)
          else
          begin
            changedir(str1);
            filename.Value := '';
          end;
        end
        else if info.keyeventinfopo^.key = key_return then
        begin
          changedir(str1);
          filename.Value := '';
        end;
      end
      else
      begin
        listview.defocuscell;
        listview.datacols.clearselection;
        listview.selectcell(cellpos2, csm_select, False);
        if (info.eventkind = cek_buttonrelease) then
        begin
          if (listview.rowcount > 0) and (list_log.rowcount > 0) and
            (not listview.filelist.isdir(y)) and
            (ss_double in info.mouseeventinfopo^.shiftstate) then
            okonexecute(Sender);
        end
        else if (listview.rowcount > 0) and (list_log.rowcount > 0) and
          (not listview.filelist.isdir(y)) and
          (info.keyeventinfopo^.key = key_return) then
          okonexecute(Sender);
      end;

      dir.Value := tosysfilepath(dir.Value);

      if filename.tag = 1 then
        filename.Value := dir.Value;

      filename.Value := tosysfilepath(filename.Value);

    end;
end;

procedure tfiledialogfo.ondrawcell(const Sender: tcol; const Canvas: tcanvas; var cellinfo: cellinfoty);
var
  aicon: integer;
  apoint: pointty;
begin

  if (list_log[1][cellinfo.cell.row] = '') and (list_log[2][cellinfo.cell.row] = '') then
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
  else if (lowercase(list_log[1][cellinfo.cell.row]) = '.png') or
    (lowercase(list_log[1][cellinfo.cell.row]) = '.jpeg') or
    (lowercase(list_log[1][cellinfo.cell.row]) = '.ico') or
    (lowercase(list_log[1][cellinfo.cell.row]) = '.webp') or
    (lowercase(list_log[1][cellinfo.cell.row]) = '.bmp') or
    (lowercase(list_log[1][cellinfo.cell.row]) = '.tiff') or
    (lowercase(list_log[1][cellinfo.cell.row]) = '.gif') or
    (lowercase(list_log[1][cellinfo.cell.row]) = '.svg') or
    (lowercase(list_log[1][cellinfo.cell.row]) = '.jpg') then
    aicon := 7
  else if (lowercase(list_log[1][cellinfo.cell.row]) = '') or
    (lowercase(list_log[1][cellinfo.cell.row]) = '.exe') or
    (lowercase(list_log[1][cellinfo.cell.row]) = '.dbg') or
    (lowercase(list_log[1][cellinfo.cell.row]) = '.com') or
    (lowercase(list_log[1][cellinfo.cell.row]) = '.bat') or
    (lowercase(list_log[1][cellinfo.cell.row]) = '.bin') or
    (lowercase(list_log[1][cellinfo.cell.row]) = '.dll') or
    (lowercase(list_log[1][cellinfo.cell.row]) = '.pyc') or
    (lowercase(list_log[1][cellinfo.cell.row]) = '.res') or
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

  apoint.x := 2;
  apoint.y := 1;

  iconslist.paint(Canvas, aicon, apoint, cl_default,
    cl_default, cl_default, 0);

end;

procedure tfiledialogfo.onsetcomp(const Sender: TObject; var avalue: Boolean; var accept: Boolean);
begin
  if avalue then
  begin
    listview.Width   := list_log.Width;
    listview.invalidate;
    list_log.Visible := False;
  end
  else
  begin
    listview.Width   := 40;
    listview.invalidate;
    list_log.Visible := True;
  end;
end;

procedure tfiledialogfo.oncreat(const Sender: TObject);
begin
  theimagelist := iconslist;
end;

procedure tfiledialogfo.onbefdrop(const Sender: TObject);
begin
  tsplitter2.left      := 200;
  filter.frame.Caption := '';
end;

procedure tfiledialogfo.oncellevplaces(const Sender: TObject; var info: celleventinfoty);
var
  cellpos, cellpos2: gridcoordty;
  x, y: integer;
  str1: string;
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

      if filename.tag = 1 then
        filename.Value := dir.Value
      else
        filename.Value := '';

      filename.Value := tosysfilepath(filename.Value);

      list_log.defocuscell;
      list_log.datacols.clearselection;
      
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

procedure tfiledialogfo.ondrawcellplace(const Sender: tcol; const Canvas: tcanvas; var cellinfo: cellinfoty);
var
  aicon: integer;
  apoint: pointty;
  astr: msestring;
begin

  astr := trim(places[0][cellinfo.cell.row]);


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

  apoint.x := 2;
  apoint.y := 3;

  iconslist.paint(Canvas, aicon, apoint, cl_default,
    cl_default, cl_default, 0);

end;

procedure tfiledialogfo.onlayout(const Sender: tcustomgrid);
begin
  listview.left     := list_log.left;
  tsplitter1.Height := list_log.Height;
  tsplitter3.width := placespan.width;
  list_log.datacols[0].Width := list_log.Width -
    list_log.datacols[1].Width - list_log.datacols[2].Width -
    list_log.datacols[3].Width - 20;

  // application.processmessages;
end;

procedure tfiledialogfo.onformcreated(const Sender: TObject);
var
  x: integer = 0;
begin
  fcourseid := -1;

  with stockobjects do
  begin
    // dir.frame.caption:= captions[sc_dirhk];
    home.Caption         := captions[sc_homehk];
    //  up.caption:= captions[sc_uphk];
    createdir.Caption    := captions[sc_new_dirhk];
    // filename.frame.caption:= captions[sc_namehk];
    filter.frame.Caption := captions[sc_filterhk];
    //  showhidden.frame.caption:= captions[sc_show_hidden_fileshk];
    ok.Caption           := modalresulttext[mr_ok];
    cancel.Caption       := modalresulttext[mr_cancel];

    // caption := 'Select a file';
  end;

  back.tag    := Ord(sc_back);
  forward.tag := Ord(sc_forward);
  up.tag      := Ord(sc_up);

  if directoryexists(tosysfilepath(sys_getuserhomedir)) then
  begin
    places[0][x] := '       Home';
    places[1][x] := msestring(tosysfilepath(sys_getuserhomedir));
    Inc(x);
  end;
  if directoryexists(tosysfilepath(sys_getuserhomedir + directoryseparator + 'Desktop')) then
  begin
    places[0][x] := '       Desktop';
    places[1][x] := msestring(tosysfilepath(sys_getuserhomedir + directoryseparator + 'Desktop'));
    Inc(x);
  end;
  if directoryexists(tosysfilepath(sys_getuserhomedir + directoryseparator + 'Music')) then
  begin
    places[0][2] := '       Music';
    places[1][2] := msestring(tosysfilepath(sys_getuserhomedir + directoryseparator + 'Music'));
    Inc(x);
  end;
  if directoryexists(tosysfilepath(sys_getuserhomedir + directoryseparator + 'Pictures')) then
  begin
    places[0][3] := '       Pictures';
    places[1][3] := msestring(tosysfilepath(sys_getuserhomedir + directoryseparator + 'Pictures'));
    Inc(x);
  end;
  if directoryexists(tosysfilepath(sys_getuserhomedir + directoryseparator + 'Videos')) then
  begin
    places[0][x] := '       Videos';
    places[1][x] := msestring(tosysfilepath(sys_getuserhomedir + directoryseparator + 'Videos'));
    Inc(x);
  end;
  if directoryexists(tosysfilepath(sys_getuserhomedir + directoryseparator + 'Documents')) then
  begin
    places[0][x] := '       Documents';
    places[1][x] := msestring(tosysfilepath(sys_getuserhomedir + directoryseparator + 'Documents'));
    Inc(x);
  end;
  if directoryexists(tosysfilepath(sys_getuserhomedir + directoryseparator + 'Downloads')) then
  begin
    places[0][x] := '       Downloads';
    places[1][x] := msestring(tosysfilepath(sys_getuserhomedir + directoryseparator + 'Downloads'));
  end;

  places.rowcount := x + 1;

  application.ProcessMessages;

end;

procedure tfiledialogfo.onlateral(const Sender: TObject; var avalue: Boolean; var accept: Boolean);
begin

  if not avalue then
  begin
    placespan.Visible  := True;
    //places.Visible     := True;
    tsplitter1.left    := 110;
    tsplitter1.Visible := True;
    list_log.left      := tsplitter1.left + tsplitter1.Width;
  end
  else
  begin
    placespan.Visible  := False;
    tsplitter1.left    := 0;
    list_log.Width     := Width;
    tsplitter1.Visible := False;
    list_log.left      := 0;
  end;

  tsplitter1.invalidate;
  list_log.invalidate;

  listview.left := list_log.left;

  if not list_log.Visible then
    listview.Width := list_log.Width
  else
    listview.Width := 40;

  list_log.datacols[0].Width := list_log.Width -
    list_log.datacols[1].Width - list_log.datacols[2].Width -
    list_log.datacols[3].Width - 20;

  listview.invalidate;
  list_log.invalidate;
  tsplitter1.invalidate;

end;

procedure tfiledialogfo.afterclosedrop(const Sender: TObject);
begin
  if filename.tag = 1 then
    filename.Value := dir.Value;
  filename.Value   := tosysfilepath(filename.Value);
end;

procedure tfiledialogfo.onresize(const Sender: TObject);
begin
  list_log.datacols[0].Width := list_log.Width -
    list_log.datacols[1].Width - list_log.datacols[2].Width -
    list_log.datacols[3].Width - 20;

  application.ProcessMessages;
end;

procedure tfiledialogfo.onchangdir(const Sender: TObject);
begin
  //dir.value := tosysfilepath(dir.value);
end;

procedure tfiledialogfo.ondrawcellplacescust(const Sender: tcol; const Canvas: tcanvas; var cellinfo: cellinfoty);
var
  aicon: integer;
  apoint: pointty;
  astr: msestring;
begin

  if cellinfo.cell.row < placescust.rowcount - 1 then
  begin
    aicon := 16;

    apoint.x := 2;
    apoint.y := 3;

    iconslist.paint(Canvas, aicon, apoint, cl_default,
      cl_default, cl_default, 0);
  end;
end;

procedure tfiledialogfo.oncellevcustplaces(const Sender: TObject; var info: celleventinfoty);
var
  theint: integer;
  thestr: msestring;
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
        thestr := copy(dir.Value, 1, length(dir.Value) - 1);
        theint := lastdelimiter(directoryseparator, thestr);
        placescust[0][placescust.rowcount - 1] := '       ' + copy(thestr, theint + 1, 14);
        placescust[1][placescust.rowcount - 1] := dir.Value;
        placescust.rowcount := placescust.rowcount + 1;
        places.defocuscell;
        places.datacols.clearselection;
      end
      else
      if (info.cell.row < placescust.rowcount - 1) then
        if directoryexists(tosysfilepath(placescust[1][info.cell.row] + directoryseparator)) then
        begin

          dir.Value := tosysfilepath(placescust[1][info.cell.row] + directoryseparator);

          if tryreadlist(dir.Value, True) then
          begin
            dir.Value := tosysfilepath(listview.directory);
            course(listview.directory);
          end;

          if filename.tag = 1 then
            filename.Value := dir.Value
          else
            filename.Value := '';

          filename.Value := tosysfilepath(filename.Value);

          list_log.defocuscell;
          list_log.datacols.clearselection;
          
          places.defocuscell;
         places.datacols.clearselection;

        end
        else
        begin
          placescust.defocuscell;
          placescust.datacols.clearselection;
        end;

end;

{ tfiledialogcontroller }

constructor tfiledialogcontroller.Create(const aowner: tmsecomponent = nil; const onchange: proceventty = nil);
begin 
  ficon:= tmaskedbitmap.create(bmk_rgb);
  fbackcolor       := cl_default;
  ffontname        := 'stf_default';
  ffontheight      := 0;
  ffontcolor       := cl_black;
  fnopanel         := false;
  fcompact         := false;
  fshowhidden      := false;
  foptions         := defaultfiledialogoptions;
  fhistorymaxcount := defaulthistorymaxcount;
  fowner           := aowner;
  ffilterlist      := tdoublemsestringdatalist.Create;
  finclude         := [fa_all];
  fexclude         := [fa_hidden];
  fonchange        := onchange;
  inherited Create;
end;

destructor tfiledialogcontroller.Destroy;
begin
  inherited;
  ficon.free;
  ffilterlist.Free;
end;

procedure tfiledialogcontroller.readstatvalue(const reader: tstatreader);
begin
  ffilenames := reader.readarray('filenames', ffilenames);
  ffilenamescust := reader.readarray('filenamescust', ffilenamescust);
  if fdo_params in foptions then
    fparams  := reader.readmsestring('params', fparams);
end;

procedure tfiledialogcontroller.readstatstate(const reader: tstatreader);
begin
  ffilterindex   := reader.readinteger('filefilterindex', ffilterindex);
  ffilter        := reader.readmsestring('filefilter', ffilter);
  fwindowrect.x  := reader.readinteger('x', fwindowrect.x);
  fwindowrect.y  := reader.readinteger('y', fwindowrect.y);
  fwindowrect.cx := reader.readinteger('cx', fwindowrect.cx);
  fwindowrect.cy := reader.readinteger('cy', fwindowrect.cy);
  fcolwidth      := reader.readinteger('filecolwidth', fcolwidth);
  fshowhidden    := reader.readboolean('showhidden', fshowhidden);
  fcompact       := reader.readboolean('compact', fcompact);
  fnopanel         := reader.readboolean('nopanel', fnopanel);
  fcolsizewidth  := reader.readinteger('colsizewidth', fcolsizewidth);
  fcolextwidth   := reader.readinteger('colextwidth', fcolextwidth);
  fcoldatewidth  := reader.readinteger('coldatewidth', fcoldatewidth);
  fsplitterplaces := reader.readinteger('splitterplaces', fsplitterplaces);
  if fdo_chdir in foptions then
    trysetcurrentdirmse(flastdir);
end;

procedure tfiledialogcontroller.readstatoptions(const reader: tstatreader);
begin
  if fdo_savelastdir in foptions then
    flastdir := reader.readmsestring('lastdir', flastdir);
  if fhistorymaxcount > 0 then
    fhistory := reader.readarray('filehistory', fhistory);
end;

procedure tfiledialogcontroller.writestatvalue(const writer: tstatwriter);
begin
  writer.writearray('filenames', ffilenames);
  writer.writearray('filenamescust', ffilenamescust);
  if fdo_params in foptions then
    writer.writemsestring('params', fparams);
end;

procedure tfiledialogcontroller.writestatstate(const writer: tstatwriter);
begin
  writer.writeinteger('filecolwidth', fcolwidth);
  writer.writeinteger('x', fwindowrect.x);
  writer.writeinteger('y', fwindowrect.y);
  writer.writeinteger('cx', fwindowrect.cx);
  writer.writeinteger('cy', fwindowrect.cy);
  writer.writeboolean('nopanel', fnopanel);
  writer.writeboolean('compact', fcompact);
  writer.writeboolean('showhidden', fshowhidden);
  writer.writeinteger('colsizewidth', fcolsizewidth);
  writer.writeinteger('colextwidth', fcolextwidth);
  writer.writeinteger('coldatewidth', fcoldatewidth);
  writer.writeinteger('splitterplaces', fsplitterplaces);
end;

procedure tfiledialogcontroller.writestatoptions(const writer: tstatwriter);
begin
  if fdo_savelastdir in foptions then
    writer.writemsestring('lastdir', flastdir);
  if fhistorymaxcount > 0 then
    writer.writearray('filehistory', fhistory);
  writer.writeinteger('filefilterindex', ffilterindex);
  writer.writemsestring('filefilter', ffilter);
end;

procedure tfiledialogcontroller.componentevent(const event: tcomponentevent);
begin
  if (fdo_link in foptions) and (event.Sender <> self) and
    (event.Sender is tfiledialogcontroller) then
    with tfiledialogcontroller(event.Sender) do
      if fgroup = self.fgroup then
        self.flastdir := flastdir;
end;

procedure tfiledialogcontroller.checklink;
begin
  if (fdo_link in foptions) and (fowner <> nil) then
    fowner.sendrootcomponentevent(tcomponentevent.Create(self), True);
end;

function tfiledialogcontroller.Execute(dialogkind: filedialogkindty; const acaption: msestring; aoptions: filedialogoptionsty): modalresultty;
var
  po1: pmsestringarty;
  fo: tfiledialogfo;
  ara, arb: msestringarty;
  //acaption2: msestring;
  rectbefore: rectty;
  x : integer;
  theint: integer;
  thestr: msestring;
  
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
  if fhistorymaxcount > 0 then
    po1 := @fhistory
  else
    po1 := nil;
  fo := tfiledialogfo.Create(nil);

  try
 {$ifdef FPC} {$checkpointer off} {$endif}
    //todo!!!!! bug 3348
    ara := ffilterlist.asarraya;
    arb := ffilterlist.asarrayb;
    
    if length(ffilenamescust) > 0 then
    begin
    fo.placescust.rowcount := length(ffilenamescust) + 1;
    for x:= 0 to length(ffilenamescust) - 1 do
    begin
    thestr := copy(ffilenamescust[x], 1, length(ffilenamescust[x]) - 1);
    theint := lastdelimiter(directoryseparator, thestr);
    fo.placescust[1][x] := ffilenamescust[x];
    fo.placescust[0][x] :=  '       ' + copy(thestr, theint + 1, 14);
    end;
    end;

    fo.blateral.Value := fnopanel;
    
    if ficon <> nil then
    fo.icon := ficon;
   
    fo.bcompact.Value   := fcompact;
    fo.showhidden.Value := fshowhidden;

    if fcolextwidth > 0 then
      fo.list_log.datacols[1].Width := fcolextwidth;
    if fcolsizewidth > 0 then
      fo.list_log.datacols[2].Width := fcolsizewidth;
    if fcoldatewidth > 0 then
      fo.list_log.datacols[3].Width := fcoldatewidth;

    fo.list_log.datacols[0].Width := fo.list_log.Width -
      fo.list_log.datacols[1].Width - fo.list_log.datacols[2].Width -
      fo.list_log.datacols[3].Width - 20;

    if fontheight > 0 then
      if fontheight < 21 then
        fo.font.Height := fontheight
      else
        fo.font.Height := 20;

    fo.font.color := fontcolor;

    fo.container.color := backcolor;

    if fontname <> '' then
      fo.font.Name := ansistring(fontname);
      
       if (dialogkind in [fdk_dir]) or (fdo_directory in aoptions) then
    begin
      fo.filename.tag           := 1;
      fo.filename.Value         := fo.dir.Value;
      fo.filename.frame.Caption := 'Selected Directory';
    end
    else if (dialogkind in [fdk_save]) then
      fo.filename.frame.Caption := 'Save File as'
    else if (dialogkind in [fdk_new]) then
      fo.filename.frame.Caption := 'New File Name'
    else
      fo.filename.frame.Caption := 'Selected File';

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

      if fsplitterplaces > 2 then
    fo.tsplitter3.top := fsplitterplaces;
 
   Result := filedialog1(fo, ffilenames, ara, arb, @ffilterindex, @ffilter, @fcolwidth, finclude,
      fexclude, po1, fhistorymaxcount, acaption, aoptions, fdefaultext,
      fimagelist, fongetfileicon, foncheckfile);
    if not rectisequal(fo.widgetrect, rectbefore) then
      fwindowrect := fo.widgetrect;

    if Assigned(fonafterexecute) then
      fonafterexecute(self, Result);
 {$ifdef FPC} {$checkpointer default} {$endif}
    if Result = mr_ok then
    begin
      if fdo_relative in foptions then
        flastdir := getcurrentdirmse
      else
        flastdir := fo.dir.Value;
    end;
    
      fnopanel        := fo.blateral.Value;
      fcompact      := fo.bcompact.Value;
      fshowhidden   := fo.showhidden.Value;
      fcolextwidth  := fo.list_log.datacols[1].Width;
      fcolsizewidth := fo.list_log.datacols[2].Width;
      fcoldatewidth := fo.list_log.datacols[3].Width;
      fsplitterplaces := fo.tsplitter3.top;
    
      if fo.placescust.rowcount > 1 then
    begin
    setlength(ffilenamescust,fo.placescust.rowcount -1); 
     for x:= 0 to length(ffilenamescust) - 1 do
    begin
    ffilenamescust[x] := fo.placescust[1][x] ;  
    end;
    end;

  finally
     fo.Free;
  end;
end;

function tfiledialogcontroller.Execute(const dialogkind: filedialogkindty; const acaption: msestring): modalresultty;
begin
  Result := Execute(dialogkind, acaption, foptions);
end;

function tfiledialogcontroller.actcaption(const dialogkind: filedialogkindty): msestring;
begin
  case dialogkind of
    fdk_save:
      Result := fcaptionsave;
    fdk_new:
      Result := fcaptionnew;
    fdk_open:
      Result := fcaptionopen;
    fdk_dir:
      Result := fcaptiondir;
    fdk_none:
      Result := '';
    else
      Result := fcaptionopen;
  end;
end;

function tfiledialogcontroller.Execute(const dialogkind: filedialogkindty; const aoptions: filedialogoptionsty): modalresultty;
begin
  Result := Execute(dialogkind, actcaption(dialogkind), aoptions);
end;

function tfiledialogcontroller.Execute(dialogkind: filedialogkindty = fdk_none): modalresultty;
begin
  if dialogkind = fdk_none then
    if fdo_save in foptions then
      dialogkind := fdk_save
    else
      dialogkind := fdk_none;
  Result := Execute(dialogkind, actcaption(dialogkind));
end;

function tfiledialogcontroller.Execute(var avalue: filenamety; dialogkind: filedialogkindty = fdk_none): Boolean;
begin
  if dialogkind = fdk_none then
    if fdo_save in foptions then
      dialogkind := fdk_save
    else
      dialogkind := fdk_none;
  Result := Execute(avalue, dialogkind, actcaption(dialogkind));
end;

function tfiledialogcontroller.Execute(var avalue: filenamety; const dialogkind: filedialogkindty; const acaption: msestring; aoptions: filedialogoptionsty): Boolean;
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
  Result   := Execute(dialogkind, acaption, aoptions) = mr_ok;
  if Result then
  begin
    avalue := filename;
    checklink;
  end
  else
    filename := wstr1;
end;

function tfiledialogcontroller.canoverwrite(): Boolean;
begin
  with stockobjects do
    Result := not findfile(filename) or
      askok(captions[sc_file] + ' "' + filename +
      '" ' + captions[sc_exists_overwrite],
      captions[sc_warningupper]);
end;

function tfiledialogcontroller.Execute(var avalue: filenamety; const dialogkind: filedialogkindty; const acaption: msestring): Boolean;
begin
  Result := Execute(avalue, dialogkind, acaption, foptions);
end;

function tfiledialogcontroller.getfilename: filenamety;
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
  
procedure tfiledialogcontroller.seticon(const avalue: tmaskedbitmap);
begin
 ficon.assign(avalue);
end;  

procedure tfiledialogcontroller.setfilename(const avalue: filenamety);
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

procedure tfiledialogcontroller.setfilterlist(const Value: tdoublemsestringdatalist);
begin
  ffilterlist.Assign(Value);
end;

procedure tfiledialogcontroller.sethistorymaxcount(const Value: integer);
begin
  fhistorymaxcount := Value;
  if length(fhistory) > fhistorymaxcount then
    setlength(fhistory, fhistorymaxcount);
end;

procedure tfiledialogcontroller.dochange;
begin
  if Assigned(fonchange) then
    fonchange;
end;

procedure tfiledialogcontroller.setdefaultext(const avalue: filenamety);
begin
  if fdefaultext <> avalue then
  begin
    fdefaultext := avalue;
    dochange;
  end;
end;

procedure tfiledialogcontroller.setoptions(Value: filedialogoptionsty);

(*
const
 mask1: filedialogoptionsty = [fdo_absolute,fdo_relative];
// mask2: filedialogoptionsty = [fdo_directory,fdo_file];
 mask3: filedialogoptionsty = [fdo_filtercasesensitive,fdo_filtercaseinsensitive];
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

procedure tfiledialogcontroller.Clear;
begin
  ffilenames := nil;
  flastdir   := '';
  fhistory   := nil;
  ffilenamescust := nil;
end;

procedure tfiledialogcontroller.setlastdir(const avalue: filenamety);
begin
  flastdir := avalue;
  checklink;
end;

procedure tfiledialogcontroller.setimagelist(const avalue: timagelist);
begin
  setlinkedvar(avalue, tmsecomponent(fimagelist));
end;

function tfiledialogcontroller.getsysfilename: filenamety;
var
  bo1: Boolean;
begin
  bo1    := fdo_sysfilename in foptions;
  system.include(foptions, fdo_sysfilename);
  Result := getfilename;
  if not bo1 then
    system.exclude(foptions, fdo_sysfilename);
end;

{ tfiledialog }

constructor tfiledialogx.Create(aowner: TComponent);
begin
  // foptionsedit:= defaultfiledialogoptionsedit;
  foptionsedit1 := defaultfiledialogoptionsedit1;
  fcontroller   := tfiledialogcontroller.Create(nil);
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

procedure tfiledialogx.setcontroller(const Value: tfiledialogcontroller);
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
  aowner.controller.fbackcolor       := cl_default;
  aowner.controller.ffontname        := 'stf_default';
  aowner.controller.ffontheight      := 0;
  aowner.controller.ffontcolor       := cl_black;
  aowner.controller.fnopanel         := false;
  aowner.controller.fcompact         := false;
  aowner.controller.fshowhidden      := false;
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
  // fcontroller:= tfiledialogcontroller.create(self,{$ifdef FPC}@{$endif}formatchanged);
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
procedure tcustomfilenameedit1.setcontroller(const avalue: tfiledialogcontroller);
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
  fcontroller := tfiledialogcontroller.Create(self,
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

