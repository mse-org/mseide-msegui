
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
 {$ifdef unix}baseunix,{$endif}Math,mseglob,mseguiglob,mseforms,Classes,
 mclasses,mseclasses,msewidgets,msegrids,mselistbrowser,mseedit,
 msesimplewidgets,msedataedits,msedialog,msetypes,msestrings,msesystypes,msesys,
 msedispwidgets,msedatalist,msestat,msestatfile,msebitmap,msedatanodes,
 msefileutils,msedropdownlist,mseevent,msegraphedits,mseeditglob,msesplitter,
 msemenus,msegridsglob,msegraphics,msegraphutils,msedirtree,msewidgetgrid,
 mseact,mseapplication,msegui,mseificomp,mseificompglob,mseifiglob,msestream,
 SysUtils,msemenuwidgets,msescrollbar,msedragglob,mserichstring,msetimer,
 mseimage;

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

  tfiledialogxcontroller = class;

  filedialogbeforeexecuteeventty = procedure(const Sender: tfiledialogxcontroller; var dialogkind: filedialogkindty; var aresult: modalresultty) of object;
  filedialogafterexecuteeventty  = procedure(const Sender: tfiledialogxcontroller; var aresult: modalresultty) of object;

  tfiledialogxcontroller = class(tlinkedpersistent)
  private
    fowner: tmsecomponent;
    fgroup: integer;
    ffontname: msestring;
    ffontheight: integer;
    fsplitterplaces: integer;
    fsplitterlateral: integer;
    ffontcolor: colorty;
    fbackcolor: colorty;
    fonchange: proceventty;
    ffilenames: filenamearty;
    ffilterlist: tdoublemsestringdatalist;
    ffilter: filenamety;
    fnopanel: Boolean;
    ficon: tmaskedbitmap;
    fcompact: Boolean;
    fshowoptions: Boolean;
    fhidehistory: Boolean;
    fhideicons: Boolean;
    ffilenamescust: filenamearty;
    fshowhidden: Boolean;
    ffilterindex: integer;
    fcolwidth: integer;
    fcolnamewidth: integer;
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
    property icon: tmaskedbitmap read ficon write seticon;
    property compact: Boolean read fcompact write fcompact;
    property showoptions: Boolean read fshowoptions write fshowoptions;
    property hidehistory: Boolean read fhidehistory write fhidehistory;
    property hideicons: Boolean read fhideicons write fhideicons;
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
    property controller: tfiledialogxcontroller read fcontroller write setcontroller;
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
    fcontroller: tfiledialogxcontroller;
    procedure setcontroller(const avalue: tfiledialogxcontroller);
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
    property controller: tfiledialogxcontroller read fcontroller write setcontroller;
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

  tfiledialogxfo = class(tmseform)
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
    listview: tfilelistviewx;
    blateral: tbooleanedit;
    placespan: tstringdisp;
    places: tstringgrid;
    tsplitter3: tsplitter;
    placescust: tstringgrid;
    labtest: tlabel;
    bnoicon: tbooleanedit;
   bshowoptions: tbooleanedit;
   tsplitter2: tsplitter;
   bhidehistory: tbooleanedit;
   tbitmapcomp1: tbitmapcomp;
   imImage: timage;
   iconslist: timagelist;
    procedure LoadImage(const AFileName: msestring);
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
    procedure onmovesplit(const Sender: TObject);
    procedure onsetvalnoicon(const Sender: TObject; var avalue: Boolean; var accept: Boolean);
  private
    fselectednames: filenamearty;
    finit: Boolean;
    fisfixedrow: Boolean;
    fsplitterpanpos: integer;
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
  msefiledialogx_mfm,
  msebits,
  mseactions,
  msestringenter,
  msekeyboard,
{$ifdef mse_dynpo}
  msestockobjects_dynpo,
{$else}
  msestockobjects,
{$endif}
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

function filedialogx1(dialog: tfiledialogxfo; var afilenames: filenamearty;
 const filterdesc: array of msestring;
  const filtermask:
 array of msestring; const filterindex: pinteger;
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
     const oncheckfile: checkfileeventty): modalresultty;
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

    if bhidehistory.Value then filename.visible := false
    else filename.visible := true;

    if blateral.Value then
      onlateral(nil, abool, abool);
    if bcompact.Value then
      onsetcomp(nil, abool, abool);
    if showhidden.Value then
      showhiddenonsetvalue(nil, abool, abool);
    //  showhidden.Value := not (fa_hidden in excludeattrib);

    if bshowoptions.value then
    begin
    bnoicon.visible := true;
    bcompact.visible := true;
    showhidden.visible := true;
    blateral.visible := true;
    filename.top := list_log.bottom + 8;
    imimage.top := filename.top - 4;
    imimage.height := filename.height + 8;

    end else
    begin
    dir.top := back.bottom + 8;
    filter.top := dir.top;
    tsplitter2.top := dir.top;
    placespan.top := filter.bottom + 8;
    tsplitter1.top := placespan.top;
    list_log.top := placespan.top;
    listview.top := list_log.top;
    filename.top := list_log.bottom + 8;
    tsplitter1.height := list_log.height;
    filename.top := list_log.bottom + 8;
    imimage.top := filename.top - 4;
    imimage.height := filename.height + 8;
    bnoicon.visible := false;
    bcompact.visible := false;
    showhidden.visible := false;
    blateral.visible := false;
    end;

    if filename.visible = false then
    height := list_log.bottom + 8
    else
    height := filename.bottom + 8;

    placespan.anchors := [an_left,an_top, an_bottom];
    list_log.anchors := [an_left,an_top, an_bottom];
    listview.anchors := [an_left,an_top, an_bottom];

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

    dialog.blateral.value  := true;
    dialog.bcompact.value  := true;

    if acaption = '' then
    begin
        if fdo_save in aoptions then
   {$ifdef mse_dynpo}
          str1 := lang_stockcaption[ord(sc_save)]
        else
          str1 := lang_stockcaption[ord(sc_open)];
   {$else}
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

procedure tfiledialogxfo.LoadImage(const AFileName: msestring);

begin
  tbitmapcomp1.bitmap.LoadFromFile(tosysfilepath(AFileName));
  imImage.Bitmap := tbitmapcomp1.bitmap;
end;

procedure tfiledialogxfo.createdironexecute(const Sender: TObject);
var
  mstr1: msestring;
begin
  mstr1 := '';

{$ifdef mse_dynpo}
    if stringenter(mstr1, lang_stockcaption[ord(sc_name)],
      lang_stockcaption[ord(sc_create_new_directory)]) = mr_ok then
{$else}
    if stringenter(mstr1, sc(sc_name),
      sc(sc_create_new_directory)) = mr_ok then
{$endif}

    begin
      places.defocuscell;
      places.datacols.clearselection;
      mstr1 := filepath(listview.directory, mstr1, fk_file);
      msefileutils.createdir(mstr1);
      changedir(mstr1);
      filename.SetFocus;
    end;
end;

procedure tfiledialogxfo.listviewselectionchanged(const Sender: tcustomlistview);
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

  //  writeln(dir.Value + filename.Value);

  //    writeln(fileext(filename.Value));

 if (lowercase(fileext(filename.Value)) = 'xpm') or
    (lowercase(fileext(filename.Value)) = 'jpeg') or
  //   (lowercase(fileext(filename.Value)) = 'ico') or
      (lowercase(fileext(filename.Value)) = 'bmp') or
      (lowercase(fileext(filename.Value)) ='png') or
      (lowercase(fileext(filename.Value)) = 'jpg') then
 begin
  if fileexists(dir.Value + filename.Value) then
   loadimage(dir.Value + filename.Value);
   imImage.visible := true;
   filename.left := imImage.right + 2 ;
   filename.width := width - imImage.right - 6 ;
  end else
  begin
   imImage.visible := false;
   filename.left := 4 ;
   filename.width := width - 8 ;
  end;
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
          showerror(lang_stockcaption[ord(sc_can_not_read_directory)] + ' ' +
            msestring(esys(ex).Text), lang_stockcaption[ord(sc_error)]);
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
      ShowMessage(lang_stockcaption[ord(sc_single_item_only)] + '.', lang_stockcaption[ord(sc_error)]);
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

  for theint := 0 to list_log.rowcount - 1 do
         if trim(copy(list_log[0][theint], 2, length(list_log[0][theint])))  = str2 then
                 theexist := theint;

    if theexist > 0 then
      begin
          sel.col := 0;
          sel.row := theexist;
          fisfixedrow := true;
          list_log.defocuscell;
          list_log.datacols.clearselection;
          list_log.selectcell(sel,csm_select);
          list_log.frame.sbvert.value := theexist/ (list_log.rowcount-1);
        end;
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

 if filename.tag <> 2 then begin // save file
  if filename.tag = 1 then
    filename.Value   := dir.Value
  else
    filename.Value   := '';
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
  thedir, thestrnum, thestrfract, thestrx, thestrext, tmp, tmp2, tmp3: msestring;
begin

  listview.Width := 30;
  listview.invalidate;

  if bnoicon.Value = False then
  begin
    x := 30;
    labtest.Caption := '';

    while labtest.Width < x do
    begin
      labtest.Caption := labtest.caption + ' ';
      labtest.invalidate;
    end;

    tmp2 := labtest.Caption;
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
      list_log[4][x] := msestring(IntToStr(x));

      if listview.filelist.isdir(x) then
      begin
        Inc(x2);
        if bnoicon.Value = True then
          tmp3 := 'D |'
        else
          tmp3 := '.';
        list_log[0][x] := tmp3 + tmp2 + msestring(listview.itemlist[x].Caption);
        list_log[1][x] := '';
      end
      else
      begin
        if bnoicon.Value = True then
          tmp3 := 'F |'
        else
          tmp3 := ':';
        list_log[0][x] := tmp3 + tmp2 + msestring(filenamebase(listview.itemlist[x].Caption));
        tmp := fileext(listview.itemlist[x].Caption);
        if tmp <> '' then
          tmp          := '.' + tmp;
        list_log[1][x] := msestring(tmp);
        list_log[0][x] := list_log[0][x] + list_log[1][x];
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

        thestrnum := msestring(IntToStr(y));

        z := Length(thestrnum);

        if z < 15 then
          for y := 0 to 14 - z do
            thestrnum := ' ' + thestrnum;

        if y2 > 0 then
          thestrfract := '.' + msestring(IntToStr(y2))
        else
          thestrfract := '';

        list_log[2][x] := thestrx + thestrnum + thestrfract + thestrext;
      end
      else
        list_log[2][x] := ' ';

      {$ifdef unix}
       list_log[3][x] := msestring(formatdatetime('YY-MM-DD hh:mm:ss', FileDateToDateTime(info.st_mtime)));
      {$else}
      list_log[3][x] := msestring(formatdatetime('YY-MM-DD hh:mm:ss', info.extinfo1.modtime));
      {$endif}

      if listview.filelist.isdir(x) then
        list_log[3][x] := ' ' + list_log[3][x];
    end; // else dir.frame.caption := 'Directory with 0 files';

  if bcompact.Value then
  begin
    listview.Width := list_log.Width;
    listview.invalidate;
  end;

  list_log.defocuscell;
  list_log.datacols.clearselection;

 // dir.frame.Caption := 'Directory with ' + msestring(IntToStr(list_log.rowcount - x2)) + ' files';

 if filename.tag <> 2 then begin // save file
  if filename.tag = 1 then
    filename.Value := (dir.Value)
  else
    filename.Value := '';
    end;

  filename.Value := tosysfilepath(filename.Value);

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

  list_log.defocuscell;
  list_log.datacols.clearselection;

  dironsetvalue(Sender, rootdir, bool);

  fisfixedrow := True;

  list_log.defocuscell;
  list_log.datacols.clearselection;

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
{$ifdef mse_dynpo}
           if not askok(lang_stockcaption[ord(sc_file)]  + ' "' + filenames[0] +
              '" ' + lang_stockcaption[ord(sc_exists_overwrite)],
              lang_stockcaption[ord(sc_warningupper)]) then
{$else}
           if not askok(sc(sc_file)  + ' "' + filenames[0] +
              '" ' + sc(sc_exists_overwrite),
              sc(sc_warningupper)) then
{$endif}
            begin
              //      if not askok('File "'+filenames[0]+
              //            '" exists, do you want to overwrite?','WARNING') then begin
              filename.SetFocus;
              Exit;
            end;
      end
      else if not bo1 then
      begin
{$ifdef mse_dynpo}
             showerror(lang_stockcaption[ord(sc_file)] + ' "' + filenames[0] + '" ' +
            lang_stockcaption[ord(sc_does_not_exist)] + '.',
            uppercase(lang_stockcaption[ord(sc_error)]));
{$else}
             showerror(sc(sc_file) + ' "' + filenames[0] + '" ' +
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
    filename.SetFocus;
  // end;
end;

procedure tfiledialogxfo.layoutev(const Sender: TObject);
begin
  listview.synctofontheight;
end;

procedure tfiledialogxfo.showhiddenonsetvalue(const Sender: TObject; var avalue: Boolean; var accept: Boolean);
begin
  dir.showhiddenfiles      := avalue;
  if avalue then
    listview.excludeattrib := listview.excludeattrib - [fa_hidden]
  else
    listview.excludeattrib := listview.excludeattrib + [fa_hidden];
  listview.readlist;
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
    ainfo.Caption := lang_stockcaption[ord(stockcaptionty(tag))] + ' ' +
{$else}
    ainfo.Caption := sc(stockcaptionty(tag)) + ' ' +
{$endif}
      '(' + encodeshortcutname(shortcut) + ')';
end;

procedure tfiledialogxfo.oncellev(const Sender: TObject; var info: celleventinfoty);
var
  cellpos, cellpos2: gridcoordty;
  y: integer;
  str1: msestring;
begin

  if (list_log.rowcount > 0) and ((info.eventkind = cek_buttonrelease) or
    (info.eventkind = cek_keyup)) then
    if (info.cell.row > -1) then
    begin
      if (fisfixedrow = False) then
      begin
        cellpos := info.cell;
        cellpos.col := 0;
        cellpos2.col := 0;
        places.defocuscell;
        places.datacols.clearselection;
        y := StrToInt(ansistring(list_log[4][cellpos.row]));
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

               if filename.tag <> 2 then  // save file
              filename.Value := '';
            end;
          end
          else if info.keyeventinfopo^.key = key_return then
          begin
            changedir(str1);
            if filename.tag <> 2 then  // save file
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

        dir.Value        := tosysfilepath(dir.Value);
        if filename.tag = 1 then
          filename.Value := dir.Value;
        filename.Value := tosysfilepath(filename.Value);

      end
      else
      begin
        listview.defocuscell;
        listview.datacols.clearselection;
        list_log.defocuscell;
        list_log.datacols.clearselection;
        fisfixedrow := False;
      end;
    end
    else
      fisfixedrow := True;
end;

procedure tfiledialogxfo.ondrawcell(const Sender: tcol; const Canvas: tcanvas; var cellinfo: cellinfoty);
var
  aicon: integer;
  apoint: pointty;
  recti: rectty;
  // tbitmapcompico: tbitmapcomp;
   thefilename : msestring;
begin
 if list_log.visible then
 begin
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

  if aicon <> 13 then
    iconslist.paint(Canvas, aicon, apoint, cl_default,
      cl_default, cl_default, 0)

   else
    begin

    thefilename := list_log[0][cellinfo.cell.row];
    thefilename := dir.value + trim(copy(thefilename,2,length(thefilename)));

//    writeln(thefilename);
     tbitmapcomp1.bitmap.LoadFromFile(tosysfilepath(thefilename));

    recti.x := 0;
    recti.y := 0;
    recti.cx := list_log.datarowheight;
    recti.cy := recti.cx;

      tbitmapcomp1.bitmap.paint(Canvas, Recti);

    end;

   end;

  end;

end;

procedure tfiledialogxfo.onsetcomp(const Sender: TObject; var avalue: Boolean; var accept: Boolean);
var
 theint, theexist : integer;
  sel : gridcoordty;
begin
  if avalue then
  begin
    listview.Width   := list_log.Width;
    listview.invalidate;
    list_log.Visible := False;
    listview.Visible := true;
  end
  else
  begin
    listview.Visible := False;
    listview.Width   := 40;
    listview.invalidate;
    list_log.Visible := True;
     theexist := -1;

  for theint := 0 to list_log.rowcount - 1 do
         if trim(copy(list_log[0][theint], 2,
          length(list_log[0][theint]))) = filename.value then
                 theexist := theint;

    if theexist > 0 then
      begin
          sel.col := 0;
          sel.row := theexist;
          list_log.defocuscell;
          list_log.datacols.clearselection;
          list_log.selectcell(sel,csm_select);
          list_log.frame.sbvert.value := theexist/ (list_log.rowcount-1);
      end;
  end;
end;

procedure tfiledialogxfo.oncreat(const Sender: TObject);
begin
  theimagelist    := iconslist;
  fsplitterpanpos := tsplitter1.left;
  fisfixedrow     := False;
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

       if filename.tag <> 2 then begin // save file

      if filename.tag = 1 then
        filename.Value := dir.Value
      else
        filename.Value := '';
        end;

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

procedure tfiledialogxfo.ondrawcellplace(const Sender: tcol; const Canvas: tcanvas; var cellinfo: cellinfoty);
var
  aicon: integer;
  apoint: pointty;
  astr: msestring;
begin
  if bnoicon.Value = False then
  begin
    astr := trim(places[0][cellinfo.cell.row]);

    if (lowercase(astr) = 'c:\') or (lowercase(astr) = 'd:\') or
    (astr = '/') or (lowercase(astr) = '/usr') or
     (lowercase(astr) = 'c:\users') then
      aicon := 0
    else if astr = 'Home' then
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
   dir.frame.caption:= lang_stockcaption[ord(sc_directory)] + strz ;
    home.Caption         := lang_stockcaption[ord(sc_homehk)] + strz ;
    //  up.caption:= lang_stockcaption[ord(sc_uphk)] + strz ;
    createdir.Caption    := lang_stockcaption[ord(sc_new_dirhk)] + strz ;
    createdir.hint    := lang_stockcaption[ord(sc_create_new_directory)] + strz ;
    filename.frame.caption:= lang_stockcaption[ord(sc_namehk)] + strz ;
    filter.frame.Caption := lang_stockcaption[ord(sc_filterhk)] + strz ;
    showhidden.frame.caption:= lang_stockcaption[ord(sc_show_hidden_fileshk)] + strz ;
    ok.Caption           := lang_modalresult[Ord(mr_ok)] + strz ;
    cancel.Caption       := lang_modalresult[Ord(mr_cancel)] + strz ;
    bnoicon.frame.caption:= lang_stockcaption[ord(sc_noicons)] + strz ;
    blateral.frame.caption:= lang_stockcaption[ord(sc_nolateral)] + strz ;
    bcompact.frame.caption:= lang_stockcaption[ord(sc_compact)] + strz ;
{$else}
    dir.frame.caption:= sc(sc_directory) + strz ;
    home.Caption         := sc(sc_homehk) + strz ;
    //  up.caption:= lang_stockcaption[ord(sc_uphk)] + strz ;
    createdir.Caption    := sc(sc_new_dirhk) + strz ;
    createdir.hint    := sc(sc_create_new_directory) + strz ;
    filename.frame.caption:= sc(sc_namehk) + strz ;
    filter.frame.Caption := sc(sc_filterhk) + strz ;
    showhidden.frame.caption:= sc(sc_show_hidden_fileshk) + strz ;
    ok.caption:= stockobjects.modalresulttext[mr_ok] + strz ;
    cancel.caption:= stockobjects.modalresulttext[mr_cancel] + strz ;
    bnoicon.frame.caption:= sc(sc_noicons) + strz ;
    blateral.frame.caption:= sc(sc_nolateral) + strz ;
    bcompact.frame.caption:= sc(sc_compact) + strz ;
{$endif}

  back.tag    := Ord(sc_back);
  forward.tag := Ord(sc_forward);
  up.tag      := Ord(sc_up);

  application.ProcessMessages;

end;

procedure tfiledialogxfo.onlateral(const Sender: TObject; var avalue: Boolean; var accept: Boolean);
begin
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
end;

procedure tfiledialogxfo.afterclosedrop(const Sender: TObject);
begin
   if filename.tag = 1 then
    filename.Value := dir.Value;
  filename.Value   := tosysfilepath(filename.Value);
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
  if bnoicon.Value = False then
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
          if bnoicon.Value = False then
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

           if filename.tag <> 2 then begin // save file

          if filename.tag = 1 then
            filename.Value := dir.Value
          else
            filename.Value := '';
            end;

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

procedure tfiledialogxfo.onsetvalnoicon(const Sender: TObject; var avalue: Boolean; var accept: Boolean);
var
  tmp: msestring;
  x: integer;
begin
  bnoicon.Value := avalue;
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
end;

{ tfiledialogxcontroller }

constructor tfiledialogxcontroller.Create(const aowner: tmsecomponent = nil; const onchange: proceventty = nil);
begin
  ficon       := tmaskedbitmap.Create(bmk_rgb);
  fbackcolor  := cl_default;
  ffontname   := 'stf_default';
  ffontheight := 0;
  ffontcolor  := cl_black;
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
  ficon.Free;
  ffilterlist.Free;
end;

procedure tfiledialogxcontroller.readstatvalue(const reader: tstatreader);
begin
  ffilenames     := reader.readarray('filenames', ffilenames);
  ffilenamescust := reader.readarray('filenamescust', ffilenamescust);
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
  fcolwidth        := reader.readinteger('filecolwidth', fcolwidth);
  fshowhidden      := reader.readboolean('showhidden', fshowhidden);
  fcompact         := reader.readboolean('compact', fcompact);
  fshowoptions     := reader.readboolean('showoptions', fshowoptions);
  fhidehistory     := reader.readboolean('hidehistory', fhidehistory);
  fhideicons     := reader.readboolean('hideicons', fhideicons);
  fnopanel         := reader.readboolean('nopanel', fnopanel);
  fcolnamewidth    := reader.readinteger('colnamewidth', fcolnamewidth);
  fcolsizewidth    := reader.readinteger('colsizewidth', fcolsizewidth);
  fcolextwidth     := reader.readinteger('colextwidth', fcolextwidth);
  fcoldatewidth    := reader.readinteger('coldatewidth', fcoldatewidth);
  fsplitterplaces  := reader.readinteger('splitterplaces', fsplitterplaces);
  fsplitterlateral := reader.readinteger('splitterlateral', fsplitterlateral);
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
  writer.writearray('filenamescust', ffilenamescust);
  if fdo_params in foptions then
    writer.writemsestring('params', fparams);
end;

procedure tfiledialogxcontroller.writestatstate(const writer: tstatwriter);
begin
  writer.writeinteger('filecolwidth', fcolwidth);
  writer.writeinteger('x', fwindowrect.x);
  writer.writeinteger('y', fwindowrect.y);
  writer.writeinteger('cx', fwindowrect.cx);
  writer.writeinteger('cy', fwindowrect.cy);
  writer.writeboolean('nopanel', fnopanel);
  writer.writeboolean('compact', fcompact);
  writer.writeboolean('showoptions', fshowoptions);
  writer.writeboolean('hidehistory', fhidehistory);
  writer.writeboolean('hideicons', fhideicons);
  writer.writeboolean('showhidden', fshowhidden);
  writer.writeinteger('colnamewidth', fcolnamewidth);
  writer.writeinteger('colsizewidth', fcolsizewidth);
  writer.writeinteger('colextwidth', fcolextwidth);
  writer.writeinteger('coldatewidth', fcoldatewidth);
  writer.writeinteger('splitterplaces', fsplitterplaces);
  writer.writeinteger('splitterlateral', fsplitterlateral);
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

function tfiledialogxcontroller.Execute(dialogkind: filedialogkindty; const acaption: msestring; aoptions: filedialogoptionsty): modalresultty;
var
  po1: pmsestringarty;
  fo: tfiledialogxfo;
  ara, arb: msestringarty;
  //acaption2: msestring;
  rectbefore: rectty;
  x: integer;
  theint: integer;
  thestr, tmp: msestring;
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
  fo := tfiledialogxfo.Create(nil);

  try
 {$ifdef FPC} {$checkpointer off} {$endif}
    //todo!!!!! bug 3348
    ara := ffilterlist.asarraya;
    arb := ffilterlist.asarrayb;

    if fontheight = 0 then
      fo.font.Height := 12;

    if fontheight > 0 then
      if fontheight < 21 then
        fo.font.Height := fontheight
      else
        fo.font.Height := 20;

    fo.list_log.datacols[2].widthmax := fo.font.Height * 7;

    fo.font.color := fontcolor;

    fo.container.color := backcolor;

    if fontname <> '' then
      fo.font.Name := ansistring(fontname);

    fo.bnoicon.Value := fhideicons;

    theboolicon := fhideicons;

    if fhideicons = False then
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

    x := -1;

    {$ifdef windows}
    if directoryexists('C:\') then
    begin
      Inc(x);
      fo.places[0][x] := tmp + 'C:\';
      fo.places[1][x] := msestring('C:\');
    end;
    if directoryexists('D:\') then
    begin
      Inc(x);
      fo.places[0][x] := tmp + 'D:\';
      fo.places[1][x] := msestring('D:\');
    end;
    if directoryexists('C:\users') then
    begin
      Inc(x);
      fo.places[0][x] := tmp + 'C:\users';
      fo.places[1][x] := msestring('C:\users');
    end;
    {$else}
    if directoryexists('/') then
    begin
      Inc(x);
      fo.places[0][x] := tmp + '/';
      fo.places[1][x] := msestring('/');
    end;
    if directoryexists('/usr') then
    begin
      Inc(x);
      fo.places[0][x] := tmp + '/usr';
      fo.places[1][x] := msestring('/usr');
    end;
    {$endif}

    if directoryexists(tosysfilepath(sys_getuserhomedir)) then
    begin
      Inc(x);
      fo.places[0][x] := tmp + 'Home';
      fo.places[1][x] := msestring(tosysfilepath(sys_getuserhomedir));
    end;
    if directoryexists(tosysfilepath(sys_getuserhomedir + directoryseparator + 'Desktop')) then
    begin
      Inc(x);
      fo.places[0][x] := tmp + 'Desktop';
      fo.places[1][x] := msestring(tosysfilepath(sys_getuserhomedir + directoryseparator + 'Desktop'));
    end;
    if directoryexists(tosysfilepath(sys_getuserhomedir + directoryseparator + 'Music')) then
    begin
      Inc(x);
      fo.places[0][x] := tmp + 'Music';
      fo.places[1][x] := msestring(tosysfilepath(sys_getuserhomedir + directoryseparator + 'Music'));
    end;
    if directoryexists(tosysfilepath(sys_getuserhomedir + directoryseparator + 'Pictures')) then
    begin
      Inc(x);
      fo.places[0][x] := tmp + 'Pictures';
      fo.places[1][x] := msestring(tosysfilepath(sys_getuserhomedir + directoryseparator + 'Pictures'));
    end;
    if directoryexists(tosysfilepath(sys_getuserhomedir + directoryseparator + 'Videos')) then
    begin
      Inc(x);
      fo.places[0][x] := tmp + 'Videos';
      fo.places[1][x] := msestring(tosysfilepath(sys_getuserhomedir + directoryseparator + 'Videos'));
    end;
    if directoryexists(tosysfilepath(sys_getuserhomedir + directoryseparator + 'Documents')) then
    begin
      Inc(x);
      fo.places[0][x] := tmp + 'Documents';
      fo.places[1][x] := msestring(tosysfilepath(sys_getuserhomedir + directoryseparator + 'Documents'));
    end;
    if directoryexists(tosysfilepath(sys_getuserhomedir + directoryseparator + 'Downloads')) then
    begin
      Inc(x);
      fo.places[0][x] := tmp + 'Downloads';
      fo.places[1][x] := msestring(tosysfilepath(sys_getuserhomedir + directoryseparator + 'Downloads'));
    end;

    fo.places.rowcount := x + 1;

    if length(ffilenamescust) > 0 then
    begin
      fo.placescust.rowcount := length(ffilenamescust) + 1;
      for x    := 0 to length(ffilenamescust) - 1 do
      begin
        thestr := copy(ffilenamescust[x], 1, length(ffilenamescust[x]) - 1);
        theint := lastdelimiter(directoryseparator, ansistring(thestr));
        fo.placescust[1][x] := ffilenamescust[x];
        fo.placescust[0][x] := tmp + copy(thestr, theint + 1, 14);
      end;
    end;

    fo.blateral.Value := fnopanel;

    if ficon <> nil then
      fo.icon := ficon;

    fo.bcompact.Value   := fcompact;
    fo.showhidden.Value := fshowhidden;
    fo.bshowoptions.Value := fshowoptions;
    fo.bhidehistory.Value := fhidehistory;
    fo.bnoicon.Value := fhideicons;

    if fcolnamewidth > 0 then
      fo.list_log.datacols[0].Width := fcolnamewidth;
    if fcolextwidth > 0 then
      fo.list_log.datacols[1].Width := fcolextwidth;
    if fcolsizewidth > 0 then
      fo.list_log.datacols[2].Width := fcolsizewidth;
    if fcoldatewidth > 0 then
      fo.list_log.datacols[3].Width := fcoldatewidth;

    // fo.list_log.datacols[0].Width := fo.list_log.Width -
    //   fo.list_log.datacols[1].Width - fo.list_log.datacols[2].Width -
    //   fo.list_log.datacols[3].Width - 20;

    if (fdo_directory in aoptions) then
    begin
      fo.filename.tag           := 1;
      fo.filename.Value         := fo.dir.Value;
{$ifdef mse_dynpo}
      fo.filename.frame.Caption := lang_stockcaption[ord(sc_dirhk)];
    end
    else if (dialogkind in [fdk_save]) then
    begin
      fo.filename.frame.Caption :=  lang_stockcaption[ord(sc_namehk)];
      fo.filename.tag           := 2;
    end
    else if (dialogkind in [fdk_new]) then
      fo.filename.frame.Caption := lang_stockcaption[ord(sc_newfile)]
    else
      fo.filename.frame.Caption := lang_stockcaption[ord(sc_namehk)];
{$else}
      fo.filename.frame.Caption := sc(sc_dirhk);
    end
    else if (dialogkind in [fdk_save]) then
    begin
      fo.filename.frame.Caption :=  sc(sc_namehk);
      fo.filename.tag           := 2;
    end
    else if (dialogkind in [fdk_new]) then
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

    if fsplitterplaces > 0 then
      fo.tsplitter3.top := fsplitterplaces;

    if fnopanel = True then
      fo.tsplitter1.left := 0
    else if fsplitterlateral > 0 then
      fo.tsplitter1.left := fsplitterlateral;

    Result        := filedialogx1(fo, ffilenames, ara, arb, @ffilterindex, @ffilter, @fcolwidth, finclude,
      fexclude, po1, fhistorymaxcount, acaption, aoptions, fdefaultext,
      fimagelist, fongetfileicon, foncheckfile);
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

    fnopanel        := fo.blateral.Value;
    fcompact        := fo.bcompact.Value;
    fshowoptions    := fo.bshowoptions.Value;
    fshowhidden     := fo.showhidden.Value;
    fhidehistory    := fo.bhidehistory.Value ;
    fhideicons       := fo.bnoicon.Value ;

    fcolnamewidth   := fo.list_log.datacols[0].Width;
    fcolextwidth    := fo.list_log.datacols[1].Width;
    fcolsizewidth   := fo.list_log.datacols[2].Width;
    fcoldatewidth   := fo.list_log.datacols[3].Width;
    fsplitterplaces := fo.tsplitter3.top;

    if fo.tsplitter1.left > 0 then
      fsplitterlateral := fo.tsplitter1.left;

    if fo.placescust.rowcount > 1 then
    begin
      setlength(ffilenamescust, fo.placescust.rowcount - 1);
      for x := 0 to length(ffilenamescust) - 1 do
        ffilenamescust[x] := fo.placescust[1][x];
    end
    else
      setlength(ffilenamescust, 0);

  finally
    fo.Free;
  end;
end;

function tfiledialogxcontroller.Execute(const dialogkind: filedialogkindty; const acaption: msestring): modalresultty;
begin
  Result := Execute(dialogkind, acaption, foptions);
end;

function tfiledialogxcontroller.actcaption(const dialogkind: filedialogkindty): msestring;
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

function tfiledialogxcontroller.Execute(const dialogkind: filedialogkindty; const aoptions: filedialogoptionsty): modalresultty;
begin
 if fdo_directory in aoptions then
 Result := Execute(dialogkind, fcaptiondir, aoptions) else
  Result := Execute(dialogkind, actcaption(dialogkind), aoptions);
end;

function tfiledialogxcontroller.Execute(dialogkind: filedialogkindty = fdk_none): modalresultty;
begin
  if dialogkind = fdk_none then
    if fdo_save in foptions then
      dialogkind := fdk_save
    else
      dialogkind := fdk_none;
   if fdo_directory in foptions then
   Result := Execute(dialogkind, fcaptiondir) else
  Result := Execute(dialogkind, actcaption(dialogkind));
end;

function tfiledialogxcontroller.Execute(var avalue: filenamety; dialogkind: filedialogkindty = fdk_none): Boolean;
begin
  if dialogkind = fdk_none then
    if fdo_save in foptions then
      dialogkind := fdk_save
    else
      dialogkind := fdk_none;

    if fdo_directory in foptions then
   Result := Execute(avalue, dialogkind, fcaptiondir) else
  Result := Execute(avalue, dialogkind, actcaption(dialogkind));
end;

function tfiledialogxcontroller.Execute(var avalue: filenamety; const dialogkind: filedialogkindty; const acaption: msestring; aoptions: filedialogoptionsty): Boolean;
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

function tfiledialogxcontroller.canoverwrite(): Boolean;
begin
     Result := not findfile(filename) or
{$ifdef mse_dynpo}
      askok(lang_stockcaption[ord(sc_file)] + ' "' + filename +
      '" ' + lang_stockcaption[ord(sc_exists_overwrite)],
      lang_stockcaption[ord(sc_warningupper)]);
{$else}
      askok(sc(sc_file) + ' "' + filename +
      '" ' + sc(sc_exists_overwrite),
      sc(sc_warningupper));
{$endif}
end;

function tfiledialogxcontroller.Execute(var avalue: filenamety; const dialogkind: filedialogkindty; const acaption: msestring): Boolean;
begin
  Result := Execute(avalue, dialogkind, acaption, foptions);
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

procedure tfiledialogxcontroller.seticon(const avalue: tmaskedbitmap);
begin
  ficon.Assign(avalue);
end;

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
  ffilenamescust := nil;
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

{ tfiledialog }

constructor tfiledialogx.Create(aowner: TComponent);
begin
  // foptionsedit:= defaultfiledialogoptionsedit;
  foptionsedit1 := defaultfiledialogoptionsedit1;
  fcontroller   := tfiledialogxcontroller.Create(nil);
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
  aowner.controller.fbackcolor  := cl_default;
  aowner.controller.ffontname   := 'stf_default';
  aowner.controller.ffontheight := 0;
  aowner.controller.ffontcolor  := cl_black;
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

