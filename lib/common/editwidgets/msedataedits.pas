{ MSEgui Copyright (c) 1999-2011 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msedataedits;

{$ifdef FPC}
 {$mode objfpc}{$h+}{$goto on}
{$endif}
{$ifndef mse_no_ifi}
 {$define mse_with_ifi}
{$endif}

interface
uses
 Classes,msegui,mseinplaceedit,mseeditglob,msegraphics,mseedit,
 msetypes,msestrings,msedatalist,mseglob,mseguiglob,
 mseevent,msegraphutils,msedrawtext,msestat,msestatfile,mseclasses,
 msearrayprops,msegrids,msewidgetgrid,msedropdownlist,msedrag,mseforms,
 mseformatstr,typinfo,msemenus,
 msescrollbar,msewidgets,msepopupcalendar,msekeyboard,msepointer,msegridsglob
 {$ifdef mse_with_ifi}
 ,mseificomp,mseifiglob,mseificompglob
 {$endif}
 ;

const
 emptyinteger = minint;
 valuevarname = 'value';
 defaulttextflagsempty = [tf_ycentered,tf_xcentered];
 
type
 tcustomdataedit = class;
 
 checkvalueeventty = procedure(const sender: tcustomdataedit; const quiet: boolean;
                           var accept: boolean) of object;

 gettexteventty = procedure(const sender: tcustomdataedit; var atext: msestring;
                               const aedit: boolean) of object;
 settexteventty = procedure(const sender: tcustomdataedit;
                           var atext: msestring; var accept: boolean) of object;
 textchangeeventty = procedure(const sender: tcustomdataedit;
                                      const atext: msestring) of object;
 dataeditstatety = (des_edited,des_emptytext,des_grayed,des_isdb,des_dbnull,
                    des_actualcursor,des_updating);
 dataeditstatesty = set of dataeditstatety;

 emptyoptionty = (eo_defaulttext); //use text of tfacecontroller
 emptyoptionsty = set of emptyoptionty;

 tcustomdataedit = class(tcustomedit,igridwidget,istatfile,idragcontroller
                         {$ifdef mse_with_ifi},iifidatalink{$endif})
  private
   fontextchange: textchangeeventty;
   fondataentered: notifyeventty;
   foncheckvalue: checkvalueeventty;
   fnullchecking: integer;
   fvaluechecking: integer;
   fstatfile: tstatfile;
   fstatvarname: msestring;
   fongettext: gettexteventty;
   fonsettext: settexteventty;
   fempty_text: msestring;
   fempty_textflags: textflagsty;
   fempty_textcolor: colorty;
   fempty_textcolorbackground: colorty;
   fempty_fontstyle: fontstylesty;
   fempty_color: colorty;
   fempty_options: emptyoptionsty;
{$ifdef mse_with_ifi}
   fifilink: tifivaluelinkcomp;
   function getifidatalinkintf: iifidatalink; virtual;
    //iifidatalink
   procedure ifisetvalue(var avalue; var accept: boolean);
   function getifilinkkind: ptypeinfo; virtual;
   procedure setifilink(const avalue: tifilinkcomp);
   procedure updateifigriddata(const sender: tobject; const alist: tdatalist);
   function getgriddata: tdatalist;
   function getvalueprop: ppropinfo;
{$endif}
   procedure emptychanged;
   
   procedure setstatfile(const Value: tstatfile);
   function getreadonly: boolean;
   procedure setreadonly(const avalue: boolean);
   procedure setempty_text(const avalue: msestring);
   procedure setempty_textflags(const avalue: textflagsty);
   procedure setempty_textcolor(const avalue: colorty);
   procedure setempty_textcolorbackground(const avalue: colorty);
   procedure setempty_fontstyle(const avalue: fontstylesty);
   procedure setempty_color(const avalue: colorty);
  protected
   fstate: dataeditstatesty;
   fgridintf: iwidgetgrid;
   fdatalist: tdatalist;
   fcontrollerintf: idataeditcontroller;
   procedure setisdb;
   procedure updateedittext(const force: boolean);
   function getgridintf: iwidgetgrid;
   function checkgrid: tdatalist; overload;
   function checkgrid(var index: integer): tdatalist; overload; 
                        //index -1 -> grid.row, nil if no focused row
   procedure internalgetgridvalue(index: integer; out value);
   procedure internalsetgridvalue(index: integer; const Value);
   procedure internalfillcol(const value);
   procedure internalassigncol(const value);
   function getinnerframe: framety; override;
   function actualcursor(const apos: pointty): cursorshapety; override;
   procedure valuechanged; virtual;
   procedure dotextchange; virtual;
   procedure modified; virtual; //for dbedits
   procedure checktext(var atext: msestring; var accept: boolean);
   procedure texttovalue(var accept: boolean; const quiet: boolean); virtual; abstract;
   procedure texttodata(const atext: msestring; var data); virtual;
             //used for clipboard paste in widgetgrid
   function datatotext(const data): msestring;
   function internaldatatotext(const data): msestring; virtual; abstract;
   procedure valuetotext;
   procedure setenabled(const avalue: boolean); override;
   procedure updatetextflags; override;
   procedure dodefocus; override;
   procedure dofocus; override;
   procedure formatchanged;
   procedure loaded; override;
   procedure fontchanged; override;
   procedure dofontheightdelta(var delta: integer); override;
   procedure initnewwidget(const ascale: real); override;
   function geteditfont: tfont; override;
   class function classskininfo: skininfoty; override;
   procedure dopaintbackground(const canvas: tcanvas); override;

   function setdropdowntext(const avalue: msestring; const docheckvalue: boolean;
                const canceled: boolean; const akey: keyty): boolean;
   procedure initeditfocus;
   {$ifdef mse_with_ifi}
   procedure setifilink0(const avalue: tifilinkcomp);
   {$endif}

    //mirrored to fcontrollerintf
   procedure mouseevent(var info: mouseeventinfoty); override;
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure internalcreateframe; override;
   procedure updatereadonlystate; override;
   procedure editnotification(var info: editnotificationinfoty); override;
   procedure domousewheelevent(var info: mousewheeleventinfoty); override;

    //iedit
   function locatecount: integer; override;        //number of locate values
   function locatecurrentindex: integer; override; //index of current row
   procedure locatesetcurrentindex(const aindex: integer); override;
   function getkeystring(const aindex: integer): msestring; override; //locate text
                   
    //igridwidget
   procedure setfirstclick;
   function createdatalist(const sender: twidgetcol): tdatalist; virtual; abstract;
   function getdatatype: listdatatypety; virtual; abstract;
   function getdefaultvalue: pointer; virtual;
   function getrowdatapo(const info: cellinfoty): pointer; virtual;
   procedure setgridintf(const intf: iwidgetgrid); virtual;
   function getcellframe: framety; virtual;
   function getcellcursor(const arow: integer;
                      const acellzone: cellzonety): cursorshapety; virtual;
   procedure updatecellzone(const row: integer; const apos: pointty;
                                           var result: cellzonety); virtual;
   function getnulltext: msestring; virtual;
   procedure drawcell(const canvas: tcanvas); virtual;
   procedure updateautocellsize(const canvas: tcanvas); virtual;
   procedure beforecelldragevent(var ainfo: draginfoty; const arow: integer;
                               var handled: boolean); virtual;
   procedure aftercelldragevent(var ainfo: draginfoty; const arow: integer;
                               var handled: boolean); virtual;
   procedure valuetogrid(row: integer); virtual; abstract;
   procedure gridtovalue(row: integer); virtual;
   procedure docellevent(const ownedcol: boolean; var info: celleventinfoty); virtual;
   procedure sortfunc(const l,r; var result: integer); virtual;
   procedure gridvaluechanged(const index: integer); virtual;
   procedure updatecoloptions(const aoptions: coloptionsty);
   procedure setoptionsedit(const avalue: optionseditty); override;
   procedure statdataread; virtual;
   procedure griddatasourcechanged; virtual;
  {$ifdef mse_with_ifi}
   function getifilink: tifilinkcomp;
  {$endif}

   procedure formaterror(const quiet: boolean);
   procedure rangeerror(const min,max; const quiet: boolean);
   procedure notnullerror(const quiet: boolean);
   
   procedure doafterpaint(const canvas: tcanvas); override;
   function needsfocuspaint: boolean; override;

    //istatfile
   procedure dostatread(const reader: tstatreader); virtual;
   procedure dostatwrite(const writer: tstatwriter); virtual;
   procedure statreading;
   procedure statread;
   function getstatvarname: msestring;

   procedure readstatvalue(const reader: tstatreader); virtual;
   procedure readstatstate(const reader: tstatreader); virtual;
   procedure readstatoptions(const reader: tstatreader); virtual;
   procedure writestatvalue(const writer: tstatwriter); virtual;
   procedure writestatstate(const writer: tstatwriter); virtual;
   procedure writestatoptions(const writer: tstatwriter); virtual;

   function cangridcopy: boolean; override;
   function isempty (const atext: msestring): boolean; virtual;
   procedure setnullvalue; virtual; //for dbedits
   function nullcheckneeded(const newfocus: twidget): boolean; virtual;
   function textcellcopy: boolean; virtual;
  public
   constructor create(aowner: tcomponent); override;
   
   procedure initgridwidget; virtual;
   procedure synctofontheight; override;
   function actualcolor: colorty; override;
   function widgetcol: twidgetcol;
   function gridrow: integer;
   function griddata: tdatalist;
   property gridintf: iwidgetgrid read fgridintf;
   function textclipped(const arow: integer; out acellrect: rectty): boolean; overload;
   function textclipped(const arow: integer): boolean; overload;

   function checkvalue(const quiet: boolean = false): boolean; virtual;
   function canclose(const newfocus: twidget): boolean; override;
   function edited: boolean; override;
   function emptytext: boolean;
   function seteditfocus: boolean;
   
   property readonly: boolean read getreadonly write setreadonly;
   property statfile: tstatfile read fstatfile write setstatfile;
   property statvarname: msestring read getstatvarname write fstatvarname;
   property empty_options: emptyoptionsty read fempty_options 
                                           write fempty_options default [];
   property empty_color: colorty read fempty_color write setempty_color 
                                           default cl_none;
   property empty_font: twidgetfontempty read getfontempty write setfontempty 
                                                  stored isfontemptystored;
   property empty_fontstyle: fontstylesty read fempty_fontstyle 
                    write setempty_fontstyle default [];
   property empty_textflags: textflagsty read fempty_textflags 
                    write setempty_textflags default defaulttextflagsempty;
   property empty_text: msestring read fempty_text write setempty_text;
   property empty_textcolor: colorty read fempty_textcolor 
                                   write setempty_textcolor default cl_none;
   property empty_textcolorbackground: colorty read fempty_textcolorbackground
                          write setempty_textcolorbackground default cl_none;
   property oncheckvalue: checkvalueeventty read foncheckvalue write foncheckvalue;
   property ondataentered: notifyeventty read fondataentered write fondataentered;
   property ongettext: gettexteventty read fongettext write fongettext;
   property onsettext: settexteventty read fonsettext write fonsettext;
   property ontextchange: textchangeeventty read fontextchange 
                                                     write fontextchange;
 end;

 tdataedit = class(tcustomdataedit)
  published
   property statfile;
   property statvarname;
   property empty_color;
   property empty_font;
   property empty_fontstyle;
   property empty_textflags;
   property empty_text;
   property empty_options;
   property empty_textcolor;
   property empty_textcolorbackground;

   property optionsedit;
   property optionsedit1;
   property font;
   property textflags;
   property textflagsactive;
   property caretwidth;
   property cursorreadonly;
   property onchange;
   property ontextchange;
   property onkeydown;
   property onkeyup;
   property oncopytoclipboard;
   property onpastefromclipboard;
   
   property ontextedited;
   property oncheckvalue;
   property ondataentered;
   property ongettext;
   property onsettext;
 end;
 
 tcustomstringedit = class(tdataedit)
  private
   fonsetvalue: setstringeventty;
   procedure setvalue(const Value: msestring);
   function getgridvalue(const index: integer): msestring;
   procedure setgridvalue(const index: integer; const Value: msestring);
   function getgridvalues: msestringarty;
   procedure setgridvalues(const Value: msestringarty);
  {$ifdef mse_with_ifi}
   function getifilink: tifistringlinkcomp;
   procedure setifilink(const avalue: tifistringlinkcomp);
  {$endif}
  protected
   fvalue: msestring;
   fvaluedefault: msestring;
   function getvaluetext: msestring; virtual;
   procedure updatedisptext(var avalue: msestring); virtual;

   procedure dosetvalue(var avalue: msestring; var accept: boolean); virtual;
   procedure texttovalue(var accept: boolean; const quiet: boolean); override;
   function internaldatatotext(const data): msestring; override;
   procedure texttodata(const atext: msestring; var data); override;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   function getdatatype: listdatatypety; override;
   procedure valuetogrid(arow: integer); override;
   procedure gridtovalue(arow: integer); override;
   procedure readstatvalue(const reader: tstatreader); override;
   procedure writestatvalue(const writer: tstatwriter); override;
   procedure sortfunc(const l,r; var result: integer); override;
   function getdefaultvalue: pointer; override;
   function checkvalue(const quiet: boolean = false): boolean; override;

  public
   procedure dragevent(var info: draginfoty); override;
   procedure fillcol(const value: msestring);
   procedure assigncol(const value: tmsestringdatalist);
   property onsetvalue: setstringeventty read fonsetvalue write fonsetvalue;
   property value: msestring read fvalue write setvalue;
   property valuedefault: msestring read fvaluedefault write fvaluedefault;
   property gridvalue[const index: integer]: msestring
        read getgridvalue write setgridvalue; default;
   property gridvalues: msestringarty read getgridvalues write setgridvalues;
{$ifdef mse_with_ifi}
   property ifilink: tifistringlinkcomp read getifilink write setifilink;
{$endif}
 end;

 tstringedit = class(tcustomstringedit)
  published
   property passwordchar;
   property maxlength;
   property value;
   property valuedefault;
   property onsetvalue;
{$ifdef mse_with_ifi}
   property ifilink;
{$endif}
 end;
 
const
 defaultmemotextflags = (defaulttextflags - [tf_ycentered]) + [tf_wordbreak];
 defaultmemotextflagsactive = (defaulttextflagsactive - [tf_ycentered]) + 
                              [tf_wordbreak];
 defaultmemooptionsedit = (defaultoptionsedit - 
         [oe_undoonesc,oe_exitoncursor,oe_shiftreturn,
          oe_endonenter,oe_homeonenter,
          oe_autoselect,oe_autoselectonfirstclick]) + [oe_linebreak];
 
type

 tcustommemoedit = class(tcustomstringedit,iscrollbar)
  private
   ftextrectbefore: rectty;
   fclientsizebefore: sizety;
   fcreated: boolean;
   fxpos: integer;
   fupdatescrollbarcount: integer;
   function getframe: tscrolleditframe;
   procedure setframe(const avalue: tscrolleditframe);
   procedure updatescrollbars;
  protected
   procedure setupeditor; override;
   procedure editnotification(var info: editnotificationinfoty); override;
   procedure internalcreateframe; override;
   procedure mouseevent(var info: mouseeventinfoty); override;
   procedure domousewheelevent(var info: mousewheeleventinfoty); override;
   procedure dokeydown(var info: keyeventinfoty); override;
  //iscrollbar
   procedure scrollevent(sender: tcustomscrollbar; event: scrolleventty);
  public
   constructor create(aowner: tcomponent); override;
   procedure afterconstruction; override;
   property frame: tscrolleditframe read getframe write setframe;
   property textflags default defaultmemotextflags;
   property textflagsactive default defaultmemotextflagsactive;
  published
   property optionsedit default defaultmemooptionsedit;
   property optionswidget default defaultoptionswidgetmousewheel;
 end;

 tmemoedit = class(tcustommemoedit)
  published
   property value;
   property valuedefault;
   property onsetvalue;
   property frame;
   property textflags;
   property textflagsactive;
{$ifdef mse_with_ifi}
   property ifilink;
{$endif}
 end;
  
 thexstringedit = class(tdataedit)
  private
   fonsetvalue: setansistringeventty;
   procedure setvalue(const Value: string);
   function getgridvalue(const index: integer): ansistring;
   procedure setgridvalue(const index: integer; const Value: ansistring);
   function getgridvalues: stringarty;
   procedure setgridvalues(const Value: stringarty);
  protected
   fvalue: ansistring;
   procedure dosetvalue(var avalue: ansistring; var accept: boolean); virtual;
   procedure texttovalue(var accept: boolean; const quiet: boolean); override;
   function internaldatatotext(const data): msestring; override;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   function getdatatype: listdatatypety; override;
   procedure valuetogrid(arow: integer); override;
   procedure gridtovalue(arow: integer); override;
   procedure readstatvalue(const reader: tstatreader); override;
   procedure writestatvalue(const writer: tstatwriter); override;
   procedure sortfunc(const l,r; var result: integer); override;
  public
   procedure fillcol(const value: string);
   procedure assigncol(const value: tansistringdatalist);
   property gridvalue[const index: integer]: ansistring
        read getgridvalue write setgridvalue; default;
   property gridvalues: stringarty read getgridvalues write setgridvalues;
  published
   property value: ansistring read fvalue write setvalue;
   property onsetvalue: setansistringeventty read fonsetvalue write fonsetvalue;
 end;
 
const
 defaultenumdropdownoptions = [deo_selectonly,deo_autodropdown,deo_keydropdown];
 defaultkeystringdropdownoptions = [deo_selectonly,deo_autodropdown,deo_keydropdown];

type

 tcustomdropdownedit = class(tcustomstringedit,idropdown
                 {$ifdef mse_with_ifi},iifidropdownlistdatalink{$endif})
  private
   fonbeforedropdown: notifyeventty;
   fonafterclosedropdown: notifyeventty;
   function getframe: tdropdownbuttonframe;
   procedure setframe(const avalue: tdropdownbuttonframe);
  protected
   fdropdown: tcustomdropdowncontroller;
   function createdropdowncontroller: tcustomdropdowncontroller; virtual;
   procedure texttovalue(var accept: boolean; const quiet: boolean); override;
   procedure dohide; override;
   {$ifdef mse_with_ifi}
   function getifidatalinkintf: iifidatalink; override;
    //iifidropdownlistdatalink
   procedure ifidropdownlistchanged(const acols: tifidropdowncols);
   {$endif}
    //idropdown
   procedure buttonaction(var action: buttonactionty; const buttonindex: integer); virtual;
   procedure dobeforedropdown; virtual;
   procedure doafterclosedropdown; virtual;
   function getvalueempty: integer; virtual;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property onbeforedropdown: notifyeventty read fonbeforedropdown write fonbeforedropdown;
   property onafterclosedropdown: notifyeventty read fonafterclosedropdown
                   write fonafterclosedropdown;
  published
   property frame: tdropdownbuttonframe read getframe write setframe;
 end;

 tcustomdropdownwidgetedit = class(tcustomdropdownedit,idropdownwidget)
  private
   function getdropdown: tdropdownwidgetcontroller;
   procedure setdropdown(const avalue: tdropdownwidgetcontroller);
  protected
   function createdropdowncontroller: tcustomdropdowncontroller; override;
    //idropdownwidget
   procedure createdropdownwidget(const atext: msestring;
                        out awidget: twidget); virtual; abstract;
   function getdropdowntext(const awidget: twidget): msestring; virtual; abstract;
  public
   property dropdown: tdropdownwidgetcontroller read getdropdown write setdropdown;
 end;

 tdropdownwidgetedit = class(tcustomdropdownwidgetedit)
  published
   property value;
   property valuedefault;
   property dropdown;
   property onsetvalue;
   property onbeforedropdown;
   property onafterclosedropdown;
 end;

 tcustomdropdownlistedit = class(tcustomdropdownedit,idropdownlist
                {$ifdef mse_with_ifi},iifidropdownlistdatalink{$endif})
  private
   procedure setdropdown(const avalue: tdropdownlistcontroller);
   function getdropdown: tdropdownlistcontroller;
  {$ifdef mse_with_ifi}
   function getifilink: tifidropdownlistlinkcomp;
   procedure setifilink1(const avalue: tifidropdownlistlinkcomp);
   procedure ifidropdownlistchanged(const acols: tifidropdowncols);
  {$endif}
  protected
  {$ifdef mse_with_ifi}
   function getifidatalinkintf: iifidatalink; override;
    //iifidatalink
   function getifilinkkind: ptypeinfo; override;
  {$endif}
    //idropdownlist
   function getdropdownitems: tdropdowncols; virtual;
   function createdropdowncontroller: tcustomdropdowncontroller; override;
   procedure internalsort(const acol: integer; const sortlist: tintegerdatalist); virtual;
  public
   procedure sort(const acol: integer = 0);
   property dropdown: tdropdownlistcontroller read getdropdown write setdropdown;
{$ifdef mse_with_ifi}
   property ifilink: tifidropdownlistlinkcomp read getifilink write setifilink1;
{$endif}
 end;

 tdropdownlistedit = class(tcustomdropdownlistedit)
  published
   property maxlength;
   property value;
   property valuedefault;
   property onsetvalue;
   property dropdown;
   property onbeforedropdown;
   property onafterclosedropdown;
{$ifdef mse_with_ifi}
   property ifilink;
{$endif}
 end;

const
 defaulthistorymaxcount = 10;
 defaulthistoryeditoptions = defaultdropdownoptionsedit + [deo_autosavehistory];

type

 thistorycontroller = class(tdropdownlistcontroller)
  private
   fhistorymaxcount: integer;
   procedure sethistorymaxcount(const avalue: integer);
  protected
   procedure checkmaxcount;
  public
   constructor create(const intf: idropdownlist);
   procedure readstate(const reader: tstatreader);
   procedure writestate(const writer: tstatwriter);
   procedure savehistoryvalue(const avalue: msestring);
  published
   property dropdownrowcount; //first
   property historymaxcount: integer read fhistorymaxcount
                      write sethistorymaxcount default defaulthistorymaxcount;
   procedure clearhistory;
   property options default defaulthistoryeditoptions;
   property width;
   property cols;
 end;

 tcustomhistoryedit = class(tcustomdropdownlistedit)
  private
   procedure setdropdown(const avalue: thistorycontroller);
   function getdropdown: thistorycontroller;
  protected
   procedure texttovalue(var accept: boolean; const quiet: boolean); override;
   procedure loaded; override;
   procedure readstatstate(const reader: tstatreader); override;
   procedure writestatstate(const writer: tstatwriter); override;
   function createdropdowncontroller: tcustomdropdowncontroller; override;
  public
   constructor create(aowner: tcomponent); override;
   procedure savehistoryvalue;
   property dropdown: thistorycontroller read getdropdown write setdropdown;
 end;

 thistoryedit = class(tcustomhistoryedit)
  published
   property maxlength;
   property value;
   property valuedefault;
   property onsetvalue;
   property dropdown;
   property onbeforedropdown;
   property onafterclosedropdown;

 end;

const
 defaultnumedittextflags = defaulttextflags + [tf_right];

type

 tnumedit = class(tdataedit)
  public
   constructor create(aowner: tcomponent); override;
  published
   property textflags default defaultnumedittextflags;
 end;

 tcustomintegeredit = class(tnumedit)
  private
   fonsetvalue: setintegereventty;
   fvalue: integer;
   fbase: numbasety;
   fbitcount: integer;
   fmin: integer;
   fmax: integer;
   fvaluedefault: integer;
   procedure setvalue(const Value: integer);
   procedure setbase(const Value: numbasety);
   procedure setbitcount(const Value: integer);
   function getgridvalue(const index: integer): integer;
   procedure setgridvalue(const index, Value: integer);
   function getgridvalues: integerarty;
   procedure setgridvalues(const Value: integerarty);
  {$ifdef mse_with_ifi}
   function getifilink: tifiintegerlinkcomp;
   procedure setifilink(const avalue: tifiintegerlinkcomp);
  {$endif}
  protected
   fisnull: boolean; //used in tdbintegeredit
   function gettextvalue(var accept: boolean; const quiet: boolean): integer;
   procedure texttovalue(var accept: boolean; const quiet: boolean); override;
   function internaldatatotext(const data): msestring; override;
   procedure texttodata(const atext: msestring; var data); override;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   function getdatatype: listdatatypety; override;
   procedure valuetogrid(arow: integer); override;
   procedure gridtovalue(arow: integer); override;
   procedure readstatvalue(const reader: tstatreader); override;
   procedure writestatvalue(const writer: tstatwriter); override;
   procedure setnullvalue; override;
   function getdefaultvalue: pointer; override;
  public
   constructor create(aowner: tcomponent); override;
   procedure fillcol(const value: integer);
   procedure assigncol(const value: tintegerdatalist);
   property onsetvalue: setintegereventty read fonsetvalue write fonsetvalue;
   property value: integer read fvalue write setvalue default 0;
   property valuedefault: integer read fvaluedefault write fvaluedefault default 0;
   property base: numbasety read fbase write setbase default nb_dec;
   property bitcount: integer read fbitcount write setbitcount default 32;
   property min: integer read fmin write fmin default 0;
   property max: integer read fmax write fmax default maxint;

   property gridvalue[const index: integer]: integer
        read getgridvalue write setgridvalue; default;
   property gridvalues: integerarty read getgridvalues write setgridvalues;
{$ifdef mse_with_ifi}
   property ifilink: tifiintegerlinkcomp read getifilink write setifilink;
{$endif}
 end;

 tintegeredit = class(tcustomintegeredit)
  published
   property onsetvalue;
   property value;
   property valuedefault;
   property base;
   property bitcount;
   property min;
   property max;
  {$ifdef mse_with_ifi}
   property ifilink;
  {$endif}
 end;

 tcustomint64edit = class(tnumedit)
  private
   fonsetvalue: setint64eventty;
   fvalue: int64;
   fbase: numbasety;
   fbitcount: integer;
   fmin: int64;
   fmax: int64;
   fvaluedefault: int64;
   procedure setvalue(const Value: int64);
   procedure setbase(const Value: numbasety);
   procedure setbitcount(const Value: integer);
   function getgridvalue(const index: integer): int64;
   procedure setgridvalue(const index: integer; const Value: int64);
   function getgridvalues: int64arty;
   procedure setgridvalues(const Value: int64arty);
  protected
   fisnull: boolean; //used in tdbintegeredit
   procedure texttovalue(var accept: boolean; const quiet: boolean); override;
   function internaldatatotext(const data): msestring; override;
   procedure texttodata(const atext: msestring; var data); override;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   function getdatatype: listdatatypety; override;
   procedure valuetogrid(arow: integer); override;
   procedure gridtovalue(arow: integer); override;
   procedure readstatvalue(const reader: tstatreader); override;
   procedure writestatvalue(const writer: tstatwriter); override;
   procedure setnullvalue; override;
   function getdefaultvalue: pointer; override;
  public
   constructor create(aowner: tcomponent); override;
   procedure fillcol(const value: int64);
   procedure assigncol(const value: tint64datalist);
   property onsetvalue: setint64eventty read fonsetvalue write fonsetvalue;
   property value: int64 read fvalue write setvalue default 0;
   property valuedefault: int64 read fvaluedefault write fvaluedefault default 0;
   property base: numbasety read fbase write setbase default nb_dec;
   property bitcount: integer read fbitcount write setbitcount default 64;
   property min: int64 read fmin write fmin default 0;
   property max: int64 read fmax write fmax; // {$ifdef FPC}default maxint64{$endif};

   property gridvalue[const index: integer]: int64
        read getgridvalue write setgridvalue; default;
   property gridvalues: int64arty read getgridvalues write setgridvalues;
 end;

 tint64edit = class(tcustomint64edit)
  published
   property onsetvalue;
   property value;
   property valuedefault;
   property base;
   property bitcount;
   property min;
   property max;
 end;
 
 tkeystringdropdowncontroller = class(tdropdownlistcontroller)
  protected
  public
   constructor create(const intf: idropdownlist);
   function getindex(const akey: msestring): integer;
            //todo: non linear search
  published
   property options default defaultkeystringdropdownoptions;
   property valuecol default 1;
 end;
 
 tcustomkeystringedit = class;
 keystringediteventty = procedure(const sender: tcustomkeystringedit) of object;

 tcustomkeystringedit = class(tcustomdropdownlistedit)
  private
//   fvaluedefault: msestring;
   foninit: keystringediteventty;
  protected
   fvalue1: msestring;
   procedure setvalue(const avalue: msestring);
   function createdropdowncontroller: tcustomdropdowncontroller; override;
   procedure texttovalue(var accept: boolean; const quiet: boolean); override;
   procedure setnullvalue; override; //for dbedits
   function internaldatatotext(const data): msestring; override;
   procedure texttodata(const atext: msestring; var data); override;
//   function getdefaultvalue: pointer; override;
   procedure valuetogrid(arow: integer); override;
   procedure gridtovalue(arow: integer); override;

   procedure readstatvalue(const reader: tstatreader); override;
   procedure writestatvalue(const writer: tstatwriter); override;
   procedure loaded; override;
  public
   property value: msestring read fvalue1 write setvalue;
//   property valuedefault: msestring read fvaluedefault write fvaluedefault;
   property oninit: keystringediteventty read foninit write foninit;
 end;

 
 tkeystringedit = class(tcustomkeystringedit)
  published
   property value;
   property valuedefault;
   property onsetvalue;
   property dropdown;
   property onbeforedropdown;
   property onafterclosedropdown;
   property oninit;
 end;
  
 tenumdropdowncontroller = class(tdropdownlistcontroller)
  protected
  public
   constructor create(const intf: idropdownlist);
  published
   property options default defaultenumdropdownoptions;
 end;
 
 tcustomenuedit = class(tcustomdropdownlistedit)
  private
   fbitcount: integer;
   fbase: numbasety;
   fmin,fmax: integer;
   fvalueoffset: integer;
   function getgridvalue(const index: integer): integer;
   procedure setgridvalue(const index, aValue: integer);
   function getgridvalues: integerarty;
   procedure setgridvalues(const avalue: integerarty);
   function getindex(avalue: integer): integer;
   procedure setbase(const avalue: numbasety);
   procedure setbitcount(const avalue: integer);
   procedure setvalueoffset(avalue: integer);
  {$ifdef mse_with_ifi}
   function getifilink: tifienumlinkcomp;
   procedure setifilink1(const avalue: tifienumlinkcomp);
  {$endif}
  protected
   fonsetvalue1: setintegereventty;
   fvalue1: integer;
   fvaluedefault1: integer;
   fvalueempty: integer;
   procedure setvalue(const avalue: integer);
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   function getdatatype: listdatatypety; override;
   function getdefaultvalue: pointer; override;
   procedure texttovalue(var accept: boolean; const quiet: boolean); override;
   procedure texttodata(const atext: msestring; var data); override;
   function internaldatatotext(const data): msestring; override;
   procedure valuetogrid(arow: integer); override;
   procedure gridtovalue(arow: integer); override;
   procedure readstatvalue(const reader: tstatreader); override;
   procedure writestatvalue(const writer: tstatwriter); override;
   function createdropdowncontroller: tcustomdropdowncontroller; override;
   procedure internalsort(const acol: integer; const sortlist: tintegerdatalist); override;

   function getvalueempty: integer; override;
   function textcellcopy: boolean; override;
  public
   enums: integerarty; //nil -> enum = item rowindex + valueoffset
   constructor create(aowner: tcomponent); override;
   procedure clear;
   function enumname(const avalue: integer): msestring;
   function addrow(const aitems: array of msestring; const enum: integer = -1): integer; //returns itemindex
                   //enum = -1 -> no enum set
   procedure fillcol(const avalue: integer);
   procedure assigncol(const avalue: tintegerdatalist);
   property valueoffset: integer read fvalueoffset write setvalueoffset default 0;
                                   //before value
   property value: integer read fvalue1 write setvalue default -1;
   property valuedefault: integer read fvaluedefault1 write fvaluedefault1 default -1;
   property valueempty: integer read fvalueempty write fvalueempty default -1;
   property base: numbasety read fbase write setbase default nb_dec;
   property bitcount: integer read fbitcount write setbitcount default 32;
   property min: integer read fmin write fmin default -1;
   property max: integer read fmax write fmax default maxint;
   property gridvalue[const index: integer]: integer
        read getgridvalue write setgridvalue; default;
   property gridvalues: integerarty read getgridvalues write setgridvalues;
   property onsetvalue: setintegereventty read fonsetvalue1 write fonsetvalue1;
{$ifdef mse_with_ifi}
   property ifilink: tifienumlinkcomp read getifilink write setifilink1;
{$endif}
 end;

 tcustomenumedit = class;
 enumediteventty = procedure (const sender: tcustomenumedit) of object;

 tcustomenumedit = class(tcustomenuedit)
  private
   foninit: enumediteventty;
  protected
   procedure loaded; override;
  public
   property oninit: enumediteventty read foninit write foninit;
 end; 
 
 tenumedit = class(tcustomenumedit)
  published
   property valueoffset; //before value
   property value;
   property valuedefault;
   property valueempty;
   property base;
   property bitcount;
   property min;
   property max;
   property onsetvalue;
   property dropdown;
   property onbeforedropdown;
   property onafterclosedropdown;
   property oninit;
{$ifdef mse_with_ifi}
   property ifilink;
{$endif}
 end;
 
 tenumtypeedit = class;
 enumtypeediteventty = procedure (const sender: tenumtypeedit) of object;

 tenumtypeedit = class(tcustomenumedit)
  private
   ftypeinfopo: ptypeinfo;
   procedure settypeinfopo(const avalue: ptypeinfo);
   procedure setoninit(const aValue: enumtypeediteventty);
   function getoninit: enumtypeediteventty;
  protected
  public
   property typeinfopo: ptypeinfo read ftypeinfopo write settypeinfopo;
  published
   property value;
   property valuedefault;
   property base;
   property bitcount;
   property min;
   property max;
   property onsetvalue;
   property dropdown;
   property onbeforedropdown;
   property onafterclosedropdown;
   property oninit: enumtypeediteventty read getoninit write setoninit;
 end;

 tcustomselector = class(tcustomenuedit)
  private
   fdropdownitems: tdropdowncols;
   fdropdownenums: integerarty;
  protected
   procedure texttovalue(var accept: boolean; const quiet: boolean); override;
   procedure dobeforedropdown; override;
   procedure getdropdowninfo(var aenums: integerarty;
         const names: tdropdowncols); virtual; abstract;
   function getdropdownitems: tdropdowncols; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
 end;

 tselector = class;
 selectoreventty = procedure (const sender: tselector) of object;

 tselector = class(tcustomselector)
  private
   fongetdropdowninfo: selectoreventty;
   foninit: selectoreventty;
   procedure setdropdownitems(const avalue: tdropdowncols);
  protected
   procedure getdropdowninfo(var aenums: integerarty;
         const names: tdropdowncols); override;
   procedure loaded; override;
  public
  published
   property dropdownitems: tdropdowncols read getdropdownitems write setdropdownitems;
   property ongetdropdowninfo: selectoreventty read fongetdropdowninfo write fongetdropdowninfo;
   property oninit: selectoreventty read foninit write foninit;
   property valueoffset; //before value
   property value;
   property onsetvalue;
   property dropdown;
   property onbeforedropdown;
   property onafterclosedropdown;
 end;

 gettypeeventty = procedure(const sender: tobject; var atype: ptypeinfo) of object;

 tcustomrealedit = class(tnumedit)
  private
   fonsetvalue: setrealeventty;
   fonsetintvalue: setintegereventty;
   fformatdisp: msestring;
   fformatedit: msestring;
   fvaluerange: real;
   procedure setvalue(const Value: realty);
   procedure setformatdisp(const Value: msestring);
   procedure setformatedit(const Value: msestring);
   procedure readvalue(reader: treader);
   procedure readvaluedefault(reader: treader);
   procedure readmin(reader: treader);
   procedure readmax(reader: treader);
   function getgridvalue(const index: integer): realty;
   function getgridintvalue(const index: integer): integer;
   procedure setgridvalue(const index: integer; const avalue: realty);
   procedure setgridintvalue(const index: integer; const avalue: integer);
   function getgridvalues: realarty;
   function getgridintvalues: integerarty;
   procedure setgridvalues(const avalue: realarty);
   procedure setgridintvalues(const avalue: integerarty);
   procedure setvaluerange(const avalue: real);
   function getasinteger: integer;
   procedure setasinteger(const avalue: integer);
   function getascurrency: currency;
   procedure setascurrency(const avalue: currency);
   procedure readvaluescale(reader: treader);
  {$ifdef mse_with_ifi}
   function getifilink: tifireallinkcomp;
   procedure setifilink(const avalue: tifireallinkcomp);
  {$endif}
  protected
   fvalue: realty;
   fvaluedefault: realty;
   fmin: realty;
   fmax: realty;
   procedure setmin(const avalue: realty); virtual;
   procedure setmax(const avalue: realty); virtual;
   function gettextvalue(var accept: boolean; const quiet: boolean): realty; virtual;
   procedure texttovalue(var accept: boolean; const quiet: boolean); override;
   function internaldatatotext(const data): msestring; override;
   procedure texttodata(const atext: msestring; var data); override;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   function getdatatype: listdatatypety; override;
   procedure valuetogrid(arow: integer); override;
   procedure gridtovalue(arow: integer); override;
   procedure defineproperties(filer: tfiler); override;
   procedure readstatvalue(const reader: tstatreader); override;
   procedure writestatvalue(const writer: tstatwriter); override;
   function getdefaultvalue: pointer; override;
  public
   constructor create(aowner: tcomponent); override;
   function griddata: trealdatalist;
   procedure fillcol(const value: realty);
   procedure assigncol(const value: trealdatalist);
   function isnull: boolean;
   property asinteger: integer read getasinteger write setasinteger;
                    //returns minint for empty value
   property ascurrency: currency read getascurrency write setascurrency;
   property onsetvalue: setrealeventty read fonsetvalue write fonsetvalue;
   property onsetintvalue: setintegereventty read fonsetintvalue 
                                  write fonsetintvalue;
                    //overrides onsetvalue
   property value: realty read fvalue write setvalue {stored false};
   property valuedefault: realty read fvaluedefault 
                                    write fvaluedefault {stored false};
   property formatedit: msestring read fformatedit write setformatedit;
   property formatdisp: msestring read fformatdisp write setformatdisp;
   property valuerange: real read fvaluerange write setvaluerange;
   property min: realty read fmin write setmin;
   property max: realty read fmax write setmax;
   property gridvalue[const index: integer]: realty
        read getgridvalue write setgridvalue; default;
   property gridintvalue[const index: integer]: integer
        read getgridintvalue write setgridintvalue;
   property gridvalues: realarty read getgridvalues write setgridvalues;
   property gridintvalues: integerarty read getgridintvalues 
                                                 write setgridintvalues;
{$ifdef mse_with_ifi}
   property ifilink: tifireallinkcomp read getifilink write setifilink;
{$endif}
  published
   property optionswidget default defaulteditwidgetoptions + [ow_mousewheel]; //first!
 end;

 trealedit = class(tcustomrealedit)
  published
   property onsetvalue;
   property onsetintvalue;
   property value {stored false};
   property valuedefault {stored false};
   property formatedit;
   property formatdisp;
   property valuerange;
   property min {stored false};
   property max {stored false};
  {$ifdef mse_with_ifi}
   property ifilink;
  {$endif}
 end;

const
 spinstepbuttons = [sk_up,sk_down,sk_first,sk_last];
 
type
 tspineditframe = class(tcustomstepframe)
  private
   procedure setbuttonsvisible(const avalue: stepkindsty);
  public
   constructor create(const intf: icaptionframe; const stepintf: istepbar);
   property buttonsinvisible default [];
  published
   property options;
   property levelo default -2;
   property leveli;
   property framewidth;
   property colorframe;
   property colorframeactive;
   property colordkshadow;
   property colorshadow;
   property colorlight;
   property colorhighlight;
   property colordkwidth;
   property colorhlwidth;
   property hiddenedges;
   property colorclient default cl_foreground;
   property colorbutton;
   property framei_left default -1;
   property framei_top default -1;
   property framei_right default -1;
   property framei_bottom default -1;

   property frameimage_list;
   property frameimage_left;
   property frameimage_top;
   property frameimage_right;
   property frameimage_bottom;
   property frameimage_offset;
   property frameimage_offset1;
   property frameimage_offsetdisabled;
   property frameimage_offsetmouse;
   property frameimage_offsetclicked;
   property frameimage_offsetactive;
   property frameimage_offsetactivemouse;
   property frameimage_offsetactiveclicked;
   
   property frameface_list;
   property frameface_offset;
   property frameface_offset1;
   property frameface_offsetdisabled;
   property frameface_offsetmouse;
   property frameface_offsetclicked;
   property frameface_offsetactive;
   property frameface_offsetactivemouse;
   property frameface_offsetactiveclicked;

   property optionsskin;
 
   property caption;
   property captionpos;
   property font;
   property localprops; //before template
   property localprops1; //before template
   property template;
   property buttonface;
   property buttonframe;
   property buttonsvisible read fforcevisiblebuttons write setbuttonsvisible 
                                                    default [sk_up,sk_down];
   property buttonsize;
   property buttonpos;
   property buttonslast;
   property buttonsinline;
 end;
 
 tcustomrealspinedit = class(tcustomrealedit,istepbar)
  private
   fstep: real;
   fstepflag: stepkindty;
   function getframe: tspineditframe;
   procedure setframe(const avalue: tspineditframe);
  protected
   function gettextvalue(var accept: boolean; 
                                      const quiet: boolean): realty; override;
   procedure internalcreateframe; override;
   procedure mouseevent(var info: mouseeventinfoty); override;
   procedure domousewheelevent(var info: mousewheeleventinfoty); override;
   procedure updatereadonlystate; override;
  //istepbar
   procedure dostep(const event: stepkindty);
  public
   constructor create(aowner: tcomponent); override;
   property step: real read fstep write fstep; //default 1
  published
   property frame: tspineditframe read getframe write setframe;
 end;
 
 trealspinedit = class(tcustomrealspinedit)
  published
   property onsetvalue;
   property value {stored false};
   property formatedit;
   property formatdisp;
   property valuerange;
   property min {stored false};
   property max {stored false};
   property step;
 end;

 tcustomdatetimeedit = class(tnumedit)
  private
   fonsetvalue: setdatetimeeventty;
   fvalue: tdatetime;
   fvaluedefault: tdatetime;
   fformatdisp: msestring;
   fformatedit: msestring;
   fmin: tdatetime;
   fmax: tdatetime;
   fkind: datetimekindty;
   procedure setvalue(const Value: tdatetime);
   procedure setformatdisp(const Value: msestring);
   procedure setformatedit(const Value: msestring);
   function getgridvalue(const index: integer): tdatetime;
   procedure setgridvalue(const index: integer; const Value: tdatetime);
   function getgridvalues: datetimearty;
   procedure setgridvalues(const Value: datetimearty);
   function checkkind(const avalue: tdatetime): tdatetime;
   procedure setkind(const avalue: datetimekindty);
   procedure readvalue(reader: treader);
   procedure readvaluedefault(reader: treader);
   procedure readmin(reader: treader);
   procedure readmax(reader: treader);
  {$ifdef mse_with_ifi}
   function getifilink: tifidatetimelinkcomp;
   procedure setifilink(const avalue: tifidatetimelinkcomp);
  {$endif}
  protected
   function gettextvalue(var accept: boolean; const quiet: boolean): tdatetime;
   procedure texttovalue(var accept: boolean; const quiet: boolean); override;
   function internaldatatotext(const data): msestring; override;
   procedure texttodata(const atext: msestring; var data); override;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   function getdatatype: listdatatypety; override;
   procedure valuetogrid(arow: integer); override;
   procedure gridtovalue(arow: integer); override;
   procedure defineproperties(filer: tfiler); override;
   procedure readstatvalue(const reader: tstatreader); override;
   procedure writestatvalue(const writer: tstatwriter); override;
   function isempty (const atext: msestring): boolean; override;
   function getdefaultvalue: pointer; override;
  public
   constructor create(aowner: tcomponent); override;
   function griddata: trealdatalist;
   procedure fillcol(const value: tdatetime);
   procedure assigncol(const value: trealdatalist);
   function isnull: boolean;
   property onsetvalue: setdatetimeeventty read fonsetvalue write fonsetvalue;
   property value: tdatetime read fvalue write setvalue {stored false};
   property valuedefault: tdatetime read fvaluedefault 
                                             write fvaluedefault {stored false};
   property formatedit: msestring read fformatedit write setformatedit;
   property formatdisp: msestring read fformatdisp write setformatdisp;
   property min: tdatetime read fmin write fmin;
   property max: tdatetime read fmax write fmax;
   property kind: datetimekindty read fkind write setkind default dtk_date;
   property gridvalue[const index: integer]: tdatetime 
                 read getgridvalue write setgridvalue; default;
   property gridvalues: datetimearty read getgridvalues write setgridvalues;
{$ifdef mse_with_ifi}
   property ifilink: tifidatetimelinkcomp read getifilink write setifilink;
{$endif}
 end;
 
 tdatetimeedit = class(tcustomdatetimeedit)
  published
   property onsetvalue;
   property value {stored false};
   property valuedefault {stored false};
   property formatedit;
   property formatdisp;
   property min {stored false};
   property max {stored false};
   property kind;
  {$ifdef mse_with_ifi}
   property ifilink;
  {$endif}
 end;

function realtytoint(const avalue: realty): integer;
function inttorealty(const avalue: integer): realty; 

implementation
uses
 sysutils,msereal,msebits,msestreaming,msestockobjects;

type
 tdatalist1 = class(tdatalist);
 twidget1 = class(twidget);
 tcustombuttonframe1 = class(tcustombuttonframe);
 twidgetcol1 = class(twidgetcol);
 tdropdowncols1 = class(tdropdowncols);
 tcustomframe1 = class(tcustomframe);
 tcustomgrid1 = class(tcustomgrid);

function realtytoint(const avalue: realty): integer;
begin
 if isemptyreal(avalue) then begin
  result:= emptyinteger;
 end
 else begin
  result:= round(avalue);
 end;
end;

function inttorealty(const avalue: integer): realty; 
begin
 if avalue = emptyinteger then begin
  result:= emptyreal;
 end
 else begin
  result:= avalue;
 end;
end;

 { teditemptyfont }
{ 
class function teditemptyfont.getinstancepo(owner: tobject): pfont;
begin
 result:= @tcustomdataedit(owner).fempty_font;
end;
}
{ tcustomdataedit }

constructor tcustomdataedit.create(aowner: tcomponent);
begin
 fempty_textflags:= defaulttextflagsempty;
 fempty_textcolor:= cl_none;
 fempty_textcolorbackground:= cl_none;
 fempty_color:= cl_none;
 inherited;
end;
{
destructor tcustomdataedit.destroy;
begin
 inherited;
 fempty_font.free;
end;
}
function tcustomdataedit.checkvalue(const quiet: boolean = false): boolean;
begin
 result:= true;
 if not ((oe_checkmrcancel in foptionsedit) and
             (window.modalresult = mr_cancel)) and (fvaluechecking = 0) then begin
  inc(fvaluechecking);
  try
   if canevent(tmethod(foncheckvalue)) then begin
    foncheckvalue(self,quiet,result);
   end;
   if result then begin
    if (oe_notnull in foptionsedit) and nullcheckneeded(nil) and isempty(text) then begin
     result:= false;
     notnullerror(quiet);
     if fgridintf = nil then begin
      show;
      setfocus;
     end;
     exit;
    end;
    texttovalue(result,quiet);
    if result then begin
     exclude(fstate,des_edited);
     if not quiet and canevent(tmethod(fondataentered)) then begin
      fondataentered(self);
     end;
     if focused then begin
      initfocus;
     end;
    end;
   end;
  finally
   dec(fvaluechecking);
  end;
 end;
end;

function tcustomdataedit.canclose(const newfocus: twidget): boolean;
var
 widget1: twidget;
begin
 result:= true;
 if not (csdesigning in componentstate) and 
                        (oe_closequery in foptionsedit) and isenabled then begin
  if (oe_notnull in foptionsedit) and (fnullchecking = 0) and 
                 nullcheckneeded(newfocus) and isempty(text) and
                 (not(ow1_nocancloseifhidden in foptionswidget1) or 
                                                    showing) then begin
   widget1:= window.focusedwidget;
   result:= checkvalue;
   if not result and (widget1 = window.focusedwidget) then begin
    inc(fnullchecking);
    try
     if fgridintf <> nil then begin
      with fgridintf.getcol do begin
       tcustomgrid1(grid).beginnullchecking;
       try
        grid.col:= index;
        grid.show;
        if not focused then begin
         tcustomgrid1(grid).beginnonullcheck;
         try
          grid.setfocus;
         finally
          tcustomgrid1(grid).endnonullcheck;
         end;
        end;
       finally
        tcustomgrid1(grid).endnullchecking;
       end;        
      end;
     end;
    finally
     dec(fnullchecking);
    end;
   end;
  end
  else begin
   if focused and (des_edited in fstate) and 
       ((fgridintf = nil) or not fgridintf.nocheckvalue) then begin
    result:= checkvalue;
   end;
  end;
 end;
 if result then begin
  result:= inherited canclose(newfocus);
 end;
end;

procedure tcustomdataedit.valuetotext;
begin
 updateedittext(false);
 feditor.initfocus;
 exclude(fstate,des_edited);
end;

procedure tcustomdataedit.gridtovalue(row: integer);
begin
 valuetotext;
end;

procedure tcustomdataedit.dofocus;
begin
 valuetotext;
 inherited;
end;

procedure tcustomdataedit.synctofontheight;
begin 
 inherited;
 if (fgridintf <> nil) and not (tf_rotate90 in textflags) then begin
  fgridintf.getcol.grid.datarowheight:= bounds_cy;
 end;
end;

function tcustomdataedit.actualcolor: colorty;
begin
 if (fgridintf <> nil) and (fcolor = cl_default) and 
                              not (csdestroying in componentstate) then begin
  result:= fgridintf.getcol.rowcolor(fgridintf.getrow);
  if result = cl_transparent then begin
   result:= fgridintf.getcol.actualcolor;
   if result = cl_transparent then begin
    result:= inherited actualcolor;
   end;
  end;
 end
 else begin
  result:= inherited actualcolor;
 end;
end;

function tcustomdataedit.edited: boolean;
begin
 result:= des_edited in fstate;
end;

function tcustomdataedit.emptytext: boolean;
begin
 result:= des_emptytext in fstate;
end;

procedure tcustomdataedit.setisdb;
begin
 include(fstate,des_isdb);
end;

procedure tcustomdataedit.updatetextflags;
var
 aflags: textflagsty;
begin
 if not (csloading in componentstate) then begin
  if (des_emptytext in fstate) and (fempty_text <> '') then begin
   aflags:= fempty_textflags;
  end
  else begin
   aflags:= textflags;
  end;
  if isenabled or (oe_nogray in foptionsedit) then begin
   exclude(fstate,des_grayed);
   feditor.textflags:= aflags;
   feditor.textflagsactive:= textflagsactive;
  end
  else begin
   include(fstate,des_grayed);
   feditor.textflags:= aflags + [tf_grayed];
   feditor.textflagsactive:= textflagsactive + [tf_grayed];
  end;
 end;
end;

procedure tcustomdataedit.updateedittext(const force: boolean);
var
 mstr1: msestring;
 state1: dataeditstatesty;
begin
 state1:= fstate;
 {$ifdef FPC} {$checkpointer off} {$endif}
 mstr1:= datatotext(nil^);
 {$ifdef FPC} {$checkpointer default} {$endif}
 if (not(des_isdb in fstate) and (mstr1 = '') or (des_dbnull in fstate)) and 
                                    not focused then begin
  mstr1:= fempty_text;
  include(fstate,des_emptytext);
 end
 else begin
  exclude(fstate,des_emptytext);
 end;
 feditor.text:= mstr1;
 if force or ((des_emptytext in fstate) xor (des_emptytext in state1)) then begin
  if des_emptytext in fstate then begin
   feditor.font:= getfontempty1{fempty_font};
   if fempty_textcolor <> cl_none then begin
    feditor.fontcolor:= fempty_textcolor;
   end;
   if fempty_textcolorbackground <> cl_none then begin
    feditor.fontcolorbackground:= fempty_textcolorbackground;
   end;
   if fempty_fontstyle <> [] then begin
    feditor.fontstyle:= fempty_fontstyle;
   end;
  end
  else begin
   feditor.font:= geteditfont;
   feditor.fontcolor:= cl_none;
   feditor.fontcolorbackground:= cl_none;
   feditor.fontstyle:= [];
  end;
  updatetextflags;
 end;
end;

procedure tcustomdataedit.dopaintbackground(const canvas: tcanvas);
begin
 inherited;
 if (fempty_color <> cl_none) and 
         (fstate * [des_emptytext,des_grayed] = [des_emptytext]) and 
                                                      not focused then begin
  canvas.fillrect(paintclientrect,fempty_color);
 end;
end;

procedure tcustomdataedit.emptychanged;
begin
 if not (csloading in componentstate) then begin
  updateedittext(true);
 end;
end;

procedure tcustomdataedit.setempty_textflags(const avalue: textflagsty);
begin
 if avalue <> fempty_textflags then begin
  fempty_textflags:= checktextflags(fempty_textflags,avalue);
  emptychanged;
 end;
end;

procedure tcustomdataedit.dodefocus;
begin
 updateedittext(false);
 exclude(fstate,des_edited);
 inherited;
end;

function tcustomdataedit.cangridcopy: boolean;
begin
 result:= (fgridintf <> nil) and fgridintf.cangridcopy;
end;

procedure tcustomdataedit.initgridwidget;
begin
 defaultinitgridwidget(self,fgridintf);
end;

function tcustomdataedit.getinnerframe: framety;
begin
 if fgridintf <> nil then begin
  result:= fgridintf.getcol.innerframe;
 end
 else begin
  result:= inherited getinnerframe;
 end;
end;

procedure tcustomdataedit.formatchanged;
begin
 if not (csloading in componentstate) then begin
  if fgridintf <> nil then begin
   fgridintf.changed;
  end;
  updateedittext(false);
  invalidate;
 end;
end;

procedure tcustomdataedit.formaterror(const quiet: boolean);
begin
 if not quiet then begin
  showmessage(''''+text+''' '+stockobjects.captions[sc_is_invalid]+'.',
        stockobjects.captions[sc_Format_error]);
 end;
end;

procedure tcustomdataedit.notnullerror(const quiet: boolean);
begin
 if not quiet then begin
  showmessage(stockobjects.captions[sc_Value_is_required]+'.',
               stockobjects.captions[sc_Error]);
 end;
end;

procedure tcustomdataedit.rangeerror(const min, max; const quiet: boolean);
begin
 if not quiet then begin
  showmessage(stockobjects.captions[sc_min]+': '+datatotext(min)+' '+
             stockobjects.captions[sc_Max]+': ' +
            datatotext(max) + '.',stockobjects.captions[sc_Range_error]);
 end;
end;

procedure tcustomdataedit.loaded;
begin
 inherited;
 include(fwidgetstate,ws_loadedproc);
 try
  valuechanged;
  formatchanged;
 finally
  exclude(fwidgetstate,ws_loadedproc);
 end;
end;

procedure tcustomdataedit.fontchanged;
begin
 inherited;
 if fgridintf <> nil then begin
  fgridintf.getcol.changed;
 end;
end;

procedure tcustomdataedit.dofontheightdelta(var delta: integer);
begin
 inherited;
 gridwidgetfontheightdelta(self,fgridintf,delta);
end;

function tcustomdataedit.geteditfont: tfont;
begin
 if {(fempty_font <> nil) and} (des_emptytext in fstate) then begin
  result:= getfontempty1{fempty_font};
 end
 else begin
  if (fgridintf <> nil) and (ffont = nil) then begin
   with fgridintf.getcol do begin
    result:= rowfont(grid.row);
   end;
  end
  else begin
   result:= inherited geteditfont;
  end;
 end;
end;

class function tcustomdataedit.classskininfo: skininfoty;
begin
 result:= inherited classskininfo;
 result.objectkind:= sok_dataedit;
end;

function tcustomdataedit.setdropdowntext(const avalue: msestring;
                const docheckvalue: boolean; const canceled: boolean;
                const akey: keyty): boolean;
var
 bo1: boolean;
begin
 result:= true;
 if canceled then begin
  feditor.undo;
 end
 else begin
  text:= avalue;
  if docheckvalue then begin
   result:= checkvalue;
   if not result then begin
    feditor.undo;
   end
   else begin
    if akey = key_tab then begin
     window.postkeyevent(akey,[],false);
    end;
   end;
  end
  else begin
   if not canceled then begin
    bo1:= true;
    texttovalue(bo1,true);
   end;
  end;
 end;
end;

procedure tcustomdataedit.setgridintf(const intf: iwidgetgrid);
begin
 fgridintf:= intf;
 if fgridintf <> nil then begin
{$ifdef mse_with_ifi}
{
  if (fifilink <> nil) and (fifilink.controller.datalist <> nil) then begin
   updateifigriddata(fifilink.controller.datalist);
  end;
}
{$endif}
  fdatalist:= fgridintf.getcol.datalist;
  fgridintf.updateeditoptions(foptionsedit);
  if (ow_autoscale in foptionswidget) and
              (foptionswidget * [ow_fontglyphheight,ow_fontlineheight] <> []) then begin
   fgridintf.getcol.grid.datarowheight:= bounds_cy;
  end;
 end
 else begin
  fdatalist:= nil;
 end;
end;

function tcustomdataedit.getcellframe: framety;
begin
 if fframe <> nil then begin
  result:= frame.cellframe;
 end
 else begin
  result:= tgridarrayprop(fgridintf.getcol.prop).innerframe;
 end;
end;

procedure tcustomdataedit.updatecoloptions(const aoptions: coloptionsty);
begin
 fgridintf.coloptionstoeditoptions(foptionsedit);
end;

procedure tcustomdataedit.setoptionsedit(const avalue: optionseditty);
begin
 if foptionsedit <> avalue then begin
  inherited;
  if fgridintf <> nil then begin
   fgridintf.updateeditoptions(foptionsedit);
  end;
 end;
end;

procedure tcustomdataedit.statdataread;
begin
 //dummy
end;

procedure tcustomdataedit.griddatasourcechanged;
begin
 //dummy
end;

procedure tcustomdataedit.modified;
begin
 //dummy
end;

procedure tcustomdataedit.valuechanged;
begin
 if not (csloading in componentstate) then begin
  exclude(fstate,des_dbnull);
  if (fgridintf <> nil) and not (csdesigning in componentstate) then begin
   valuetogrid(fgridintf.getrow);
  end;
  updateedittext(false);
  if focused then begin
   feditor.initfocus;
  end
  else begin
   feditor.sellength:= 0;
   feditor.curindex:= bigint;
  end;
  if not (ws_loadedproc in fwidgetstate) then begin
   modified;
  end;
  dochange;
 end;
end;

procedure tcustomdataedit.dotextchange;
begin
 if canevent(tmethod(fontextchange)) then begin
  fontextchange(self,text);
 end;
end;

procedure tcustomdataedit.checktext(var atext: msestring; var accept: boolean);
begin
 if canevent(tmethod(fonsettext)) then begin
  fonsettext(self,atext,accept);
 end;
end;

procedure tcustomdataedit.texttodata(const atext: msestring; var data);
begin
 //dummy
end;

procedure tcustomdataedit.setstatfile(const Value: tstatfile);
begin
 setstatfilevar(istatfile(self),value,fstatfile);
end;

procedure tcustomdataedit.dostatwrite(const writer: tstatwriter);
begin
 if (fgridintf = nil) and canstatvalue(foptionsedit,writer) then begin
  writestatvalue(writer);
 end;
 if canstatstate(foptionsedit,writer) then begin
  writestatstate(writer);
 end;
 if canstatoptions(foptionsedit,writer) then begin
  writestatoptions(writer);
 end;
end;

procedure tcustomdataedit.dostatread(const reader: tstatreader);
begin
 if canstatvalue(foptionsedit,reader) then begin
  readstatvalue(reader);
 end;
 if canstatstate(foptionsedit,reader) then begin
  readstatstate(reader);
 end;
 if canstatoptions(foptionsedit,reader) then begin
  readstatoptions(reader);
 end;
end;

procedure tcustomdataedit.statreading;
begin
 //dummy
end;

procedure tcustomdataedit.statread;
begin
 if oe_checkvaluepaststatread in foptionsedit then begin
  checkvalue;
 end;
end;

function tcustomdataedit.getstatvarname: msestring;
begin
 result:= fstatvarname;
end;

procedure tcustomdataedit.readstatoptions(const reader: tstatreader);
begin
 //dummy
end;

procedure tcustomdataedit.readstatstate(const reader: tstatreader);
begin
 //dummy
end;

procedure tcustomdataedit.readstatvalue(const reader: tstatreader);
begin
 //dummy
end;

procedure tcustomdataedit.writestatoptions(const writer: tstatwriter);
begin
 //dummy
end;

procedure tcustomdataedit.writestatstate(const writer: tstatwriter);
begin
 //dummy
end;

procedure tcustomdataedit.writestatvalue(const writer: tstatwriter);
begin
 //dummy
end;

procedure tcustomdataedit.setnullvalue; //for dbedits
var
 bo1: boolean;
begin
 text:= getnulltext;
 bo1:= true;
 texttovalue(bo1,true); //sevalue call
 include(fstate,des_dbnull);
 updateedittext(true);  //change to textempty
end;

procedure tcustomdataedit.setfirstclick;
begin
 feditor.setfirstclick;
end;

function tcustomdataedit.getdefaultvalue: pointer;
begin
 result:= nil;
end;

function tcustomdataedit.getrowdatapo(const info: cellinfoty): pointer;
begin
 result:= nil;
end;

function tcustomdataedit.getnulltext: msestring;
begin
 result:= '';
end;

procedure tcustomdataedit.drawcell(const canvas: tcanvas);
var
 mstr1: msestring;
 atextflags: textflagsty;
 bo1: boolean;
 int1: integer;
 rect1: rectty;
begin
 atextflags:= textflags;
 bo1:= false;
 with cellinfoty(canvas.drawinfopo^) do begin
  if datapo <> nil then begin
   mstr1:= internaldatatotext(datapo^);
   if passwordchar <> #0 then begin
    mstr1:= charstring(passwordchar,length(mstr1));
   end;
   if not (des_isdb in fstate) and (mstr1 = '') and 
                                   (fempty_text <> '') then begin
    bo1:= true;
    mstr1:= fempty_text;
   end;
  end
  else begin
   bo1:= true;
   mstr1:= fempty_text;
  end;
  if canevent(tmethod(fongettext)) then begin
   fongettext(self,mstr1,false);
  end;
  if bo1 then begin    
   if fempty_fontstyle <> [] then begin
    canvas.font.style:= fempty_fontstyle;
   end;
  end;
  if calcautocellsize then begin
   rect1:= textrect(canvas,mstr1,innerrect,atextflags);
   int1:= rect1.cx - innerrect.cx + rect.cx;
   if int1 > autocellsize.cx then begin
    autocellsize.cx:= int1;
   end;
   int1:= rect1.cy - innerrect.cy + rect.cy;
   if int1 > autocellsize.cy then begin
    autocellsize.cy:= int1;
   end;
  end
  else begin
   if bo1 and (fempty_color <> cl_none) and not (des_grayed in fstate) then begin
    canvas.fillrect(rect,fempty_color);
   end;
   if mstr1 <> '' then begin
    if bo1 then begin    
     canvas.font:= getfontempty1{fempty_font};
     atextflags:= fempty_textflags;
     if fempty_textcolor <> cl_none then begin
      canvas.font.color:= fempty_textcolor;
     end;
     if fempty_textcolorbackground <> cl_none then begin
      canvas.font.color:= fempty_textcolorbackground;
     end;
    end;
    if des_grayed in fstate then begin
     include(atextflags,tf_grayed);
    end;
    drawtext(canvas,mstr1,innerrect,rect,atextflags);
   end;
  end;
 end;
end;

procedure tcustomdataedit.updateautocellsize(const canvas: tcanvas);
begin
 drawcell(canvas);
end;

procedure tcustomdataedit.doafterpaint(const canvas: tcanvas);
begin
 inherited;
 if (fgridintf <> nil) and not (csdesigning in componentstate) then begin
  fgridintf.widgetpainted(canvas);
 end;
end;

function tcustomdataedit.needsfocuspaint: boolean;
begin
 result:= (fgridintf = nil) and inherited needsfocuspaint;
end;

function tcustomdataedit.getgridintf: iwidgetgrid;
begin
 result:= fgridintf;
end;

function tcustomdataedit.checkgrid: tdatalist;
begin
 if fgridintf = nil then begin
  raise exception.Create('No grid.');
 end;
 result:= fgridintf.getcol.datalist;
 if result = nil then begin
  raise exception.Create('No datalist.');
 end;
end;

function tcustomdataedit.checkgrid(var index: integer): tdatalist;
                        //index -1 -> grid.row, nil if no focused row
begin
 result:= checkgrid();
 if index = -1 then begin
  index:= fgridintf.getcol.grid.row;
 end;
 if index < 0 then begin
  result:= nil;
 end;
end;

procedure tcustomdataedit.internalgetgridvalue(index: integer; out value);
begin
 checkgrid;
 fgridintf.getdata(index,value);
end;

procedure tcustomdataedit.internalsetgridvalue(index: integer;
  const Value);
begin
 checkgrid;
 fgridintf.setdata(index,value);
end;

procedure tcustomdataedit.internalfillcol(const value);
begin
 checkgrid;
 with tdatalist1(fgridintf.getcol.datalist) do begin
  tdatalist1(fgridintf.getcol.datalist).internalfill(count,value);
 end;
end;

procedure tcustomdataedit.internalassigncol(const value);
begin
 checkgrid;
 with fgridintf.getcol do begin
  datalist.Assign(tdatalist(value));
 end;
end;

function tcustomdataedit.widgetcol: twidgetcol;
begin
 if fgridintf = nil then begin
  result:= nil;
 end
 else begin
  result:= fgridintf.getcol;
 end;
end;

function tcustomdataedit.gridrow: integer;
begin
 if fgridintf = nil then begin
  result:= -1;
 end
 else begin
  result:= fgridintf.getcol.grid.row;
 end;
end;

procedure tcustomdataedit.sortfunc(const l, r; var result: integer);
begin
 tdatalist1(twidgetcol1(fgridintf.getcol).fdata).compare(l,r,result);
end;

function tcustomdataedit.griddata: tdatalist;
begin
 checkgrid;
 result:= fdatalist;
end;

function tcustomdataedit.textclipped(const arow: integer; out acellrect: rectty): boolean;
var
 rect2: rectty;
 canvas1: tcanvas;
 cell1: gridcoordty;
 grid1: tcustomgrid;
begin
 checkgrid;
 with fgridintf.getcol do begin
  grid1:= grid;
  cell1.row:= arow;
  cell1.col:= colindex;
  result:= grid1.isdatacell(cell1);
  if result then begin
   acellrect:= grid1.clippedcellrect(cell1,cil_inner);
   canvas1:= getcanvas;
   rect2:= textrect(canvas1,datatotext(datalist.getitempo(arow)^),
                   acellrect,feditor.textflags,font);
   result:= not rectinrect(rect2,acellrect);
  end
  else begin
   acellrect:= nullrect;
  end;
 end;
end;

function tcustomdataedit.textclipped(const arow: integer): boolean;
var
 rect1: rectty;
begin
 result:= textclipped(arow,rect1);
end;

procedure tcustomdataedit.docellevent(const ownedcol: boolean; var info: celleventinfoty);

var
 hintinfo: hintinfoty;
begin
 if ownedcol then begin
  if (info.eventkind = cek_enter) then begin
   setupeditor; //setrowfont
   feditor.initfocus; 
  end;
  if (oe_hintclippedtext in foptionsedit) and 
         (info.eventkind = cek_firstmousepark) and application.active and 
         textclipped(info.cell.row) and 
         ((info.grid.row <> info.cell.row) or (info.grid.col <> info.cell.col)) and
         twidget1(info.grid).getshowhint then begin
   application.inithintinfo(hintinfo,info.grid);
   hintinfo.caption:= datatotext(fgridintf.getcol.datalist.getitempo(info.cell.row)^);
   application.showhint(info.grid,hintinfo);
  end; 
 end;
end;

procedure tcustomdataedit.gridvaluechanged(const index: integer);
begin
 //dummy
end;

function tcustomdataedit.isempty(const atext: msestring): boolean;
begin
 result:= trim(atext) = getnulltext;
end;

function tcustomdataedit.nullcheckneeded(const newfocus: twidget): boolean;
begin
 result:= false;
 if (newfocus <> self) and not ((oe_checkmrcancel in foptionsedit) and 
                            (window.modalresult = mr_cancel)) then begin
  if fgridintf = nil then begin
   result:= newfocus = nil;
  end
  else begin
   result:= fgridintf.nullcheckneeded(newfocus);
  end;
 end;
end;

procedure tcustomdataedit.setenabled(const avalue: boolean);
begin
 inherited;
 if (fgridintf <> nil) and not (csloading in componentstate) then begin
  fgridintf.getcol.enabled:= avalue;
 end;
end;

function tcustomdataedit.getreadonly: boolean;
begin
 result:= oe_readonly in foptionsedit;
end;

procedure tcustomdataedit.setreadonly(const avalue: boolean);
begin
 if avalue <> (oe_readonly in foptionsedit) then begin
  if avalue then begin
   optionsedit:= optionsedit + [oe_readonly];
  end
  else begin
   optionsedit:= optionsedit - [oe_readonly];
  end;  
  setupeditor;
 end;
end;

function tcustomdataedit.seteditfocus: boolean;
begin
 if not readonly then begin
  if fgridintf = nil then begin
   if canfocus then begin
    setfocus;
   end;
  end
  else begin
   with fgridintf.getcol do begin
    grid.col:= index;
    if grid.canfocus then begin
     if not focused then begin
      grid.setfocus;
     end;
    end; 
   end;
  end;
 end;
 result:= focused;
end;

procedure tcustomdataedit.beforecelldragevent(var ainfo: draginfoty; const arow: integer;
               var handled: boolean);
begin
 //dummy
end;

procedure tcustomdataedit.aftercelldragevent(var ainfo: draginfoty; const arow: integer;
               var handled: boolean);
begin
 //dummy
end;

procedure tcustomdataedit.initeditfocus;
begin
 exclude(fstate,des_edited);
 initfocus;
end;

function tcustomdataedit.datatotext(const data): msestring;
begin
 result:= internaldatatotext(data);
 if canevent(tmethod(fongettext)) then begin
  fongettext(self,result,focused);
 end;
end;

procedure tcustomdataedit.setempty_text(const avalue: msestring);
begin
 fempty_text:= avalue;
 formatchanged;
end;
(*
procedure tcustomdataedit.createfontempty;
begin
 if fempty_font = nil then begin
  fempty_font:= teditemptyfont.create;
  fempty_font.onchange:= {$ifdef FPC}@{$endif}fontemptychanged;
 end;
end;

function tcustomdataedit.getempty_font: teditemptyfont;
begin
 getoptionalobject(fempty_font,{$ifdef FPC}@{$endif}createfontempty);
 result:= fempty_font;
 if result = nil then begin
  result:= teditemptyfont(getfont1);
 end;
end;

procedure tcustomdataedit.setempty_font(const avalue: teditemptyfont);
begin
 if fempty_font <> avalue then begin
  setoptionalobject(avalue,fempty_font,{$ifdef FPC}@{$endif}createfontempty);
 end;
end;

function tcustomdataedit.isempty_fontstored: boolean;
begin
 result:= fempty_font <> nil;
end;

procedure tcustomdataedit.fontemptychanged(const sender: tobject);
begin
 emptychanged;
end;
*)
procedure tcustomdataedit.setempty_textcolor(const avalue: colorty);
begin
 if avalue <> fempty_textcolor then begin
  fempty_textcolor:= avalue;
  emptychanged;
 end;
end;

procedure tcustomdataedit.setempty_textcolorbackground(const avalue: colorty);
begin
 if avalue <> fempty_textcolorbackground then begin
  fempty_textcolorbackground:= avalue;
  emptychanged;
 end;
end;

procedure tcustomdataedit.setempty_fontstyle(const avalue: fontstylesty);
begin
 if avalue <> fempty_fontstyle then begin
  fempty_fontstyle:= avalue;
  emptychanged;
 end;
end;

procedure tcustomdataedit.setempty_color(const avalue: colorty);
begin
 if avalue <> fempty_color then begin
  fempty_color:= avalue;
  invalidate;
 end;
end;

function tcustomdataedit.locatecount: integer;
var
 datalist1: tdatalist;
begin
 result:= 0;
 if fgridintf <> nil then begin
  datalist1:= fgridintf.getcol.datalist;
  if datalist1 <> nil then begin
   result:= datalist1.count;
  end;
 end;
end;

function tcustomdataedit.locatecurrentindex: integer;
begin
 result:= fgridintf.getcol.grid.row;
end;

procedure tcustomdataedit.locatesetcurrentindex(const aindex: integer);
begin
 fgridintf.getcol.grid.row:= aindex;
end;

function tcustomdataedit.getkeystring(const aindex: integer): msestring;
begin
 with fgridintf.getcol do begin
  if grid.rowhidden[aindex] then begin
   result:= '';
  end
  else begin
   result:= datatotext(datalist.getitempo(aindex)^);
  end;
 end;
end;

function tcustomdataedit.actualcursor(const apos: pointty): cursorshapety;
var
 zone1: cellzonety;
 int1: integer;
begin
 if (fgridintf <> nil) and not (des_actualcursor in fstate) then begin 
  include(fstate,des_actualcursor);
  try
   zone1:= cz_default;
   int1:= fgridintf.grid.row;
   if int1 >= 0 then begin
    updatecellzone(int1,widgetpostoclientpos(apos),zone1);
//    result:= getcellcursor(int1,zone1);
    result:= getcellcursor(-1,zone1);
    exit;
   end;
  finally
   exclude(fstate,des_actualcursor);
  end;
 end;
 result:= inherited actualcursor(apos);
end;

function tcustomdataedit.getcellcursor(const arow: integer; 
                                 const acellzone: cellzonety): cursorshapety;
var
 bo1: boolean;
begin
 bo1:= des_actualcursor in fstate;
 include(fstate,des_actualcursor);
 result:= actualcursor(nullpoint);
 if not bo1 then begin
  exclude(fstate,des_actualcursor);
 end;
end;

procedure tcustomdataedit.updatecellzone(const row: integer; const apos: pointty;
                                                  var result: cellzonety);
begin
 //dummy
end;

procedure tcustomdataedit.mouseevent(var info: mouseeventinfoty);
begin
 if fcontrollerintf <> nil then begin
  fcontrollerintf.mouseevent(info);
 end;
 inherited;
end;

procedure tcustomdataedit.domousewheelevent(var info: mousewheeleventinfoty);
begin
 if fcontrollerintf <> nil then begin
  fcontrollerintf.domousewheelevent(info);
 end;
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;


procedure tcustomdataedit.dokeydown(var info: keyeventinfoty);
begin
 if fcontrollerintf <> nil then begin
  fcontrollerintf.dokeydown(info);
 end;
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;

procedure tcustomdataedit.updatereadonlystate;
begin
 inherited;
 if fcontrollerintf <> nil then begin
  fcontrollerintf.updatereadonlystate;
 end;
end;

procedure tcustomdataedit.internalcreateframe;
begin
 if (fframe = nil) and (fcontrollerintf <> nil) then begin
  fcontrollerintf.internalcreateframe;
 end;
 if fframe = nil then begin
  inherited;
 end;
end;

procedure tcustomdataedit.editnotification(var info: editnotificationinfoty);
var
 bo1: boolean;
begin
 if fcontrollerintf <> nil then begin
  fcontrollerintf.editnotification(info);
 end;
 case info.action of
  ea_textentered: begin
   bo1:= true;
   if (des_edited in fstate) or 
                       (oe_forcereturncheckvalue in foptionsedit) then begin
    bo1:= checkvalue;
    if not bo1 or (oe_eatreturn in foptionsedit) then begin
     info.action:= ea_none;
    end;
   end;
   if bo1 then begin
    if (fgridintf <> nil) and 
       (og_colchangeonreturnkey in fgridintf.getcol.grid.optionsgrid)then begin
     info.action:= ea_none;    
     fgridintf.getcol.grid.colstep(fca_focusin,1,true,false,true);
    end;
   end;
  end;
  ea_textedited: begin
   include(fstate,des_edited);
   modified;
   inherited;
  end;
  ea_textchanged: begin
   dotextchange;
  end;
  ea_undo: begin
   exclude(fstate,des_edited);
  end;
  ea_caretupdating: begin
   if (fgridintf <> nil) and focused then begin
    fgridintf.showcaretrect(info.caretrect,fframe);
   end;
  end;
 end;
end;

procedure tcustomdataedit.initnewwidget(const ascale: real);
begin
 if fgridintf <> nil then begin
  fgridintf.getcol.options:= fgridintf.getcol.grid.datacols.options;
               //restore default options
 end;
 inherited;
end;

function tcustomdataedit.textcellcopy: boolean;
begin
 result:= true;
end;

{$ifdef mse_with_ifi}
function tcustomdataedit.getifilinkkind: ptypeinfo;
begin
 result:= typeinfo(iifidatalink);
end;

procedure tcustomdataedit.setifilink0(const avalue: tifilinkcomp);
begin
 mseificomp.setifilinkcomp(getifidatalinkintf,avalue,tifilinkcomp(fifilink));
end;

procedure tcustomdataedit.setifilink(const avalue: tifilinkcomp);
begin
 setifilink0(avalue);
end;
{
function tcustomdataedit.ifigriddata: tdatalist;
begin
 result:= fdatalist;
end;
}
procedure tcustomdataedit.updateifigriddata(const sender: tobject; 
                                                      const alist: tdatalist);
begin
 if fgridintf <> nil then begin
  fgridintf.updateifigriddata(alist);
  fdatalist:= alist;
 end;
end;

function tcustomdataedit.getgriddata: tdatalist;
begin
 result:= fdatalist;
end;

function tcustomdataedit.getvalueprop: ppropinfo;
begin
 result:= getpropinfo(self,'value');
end;

function tcustomdataedit.getifidatalinkintf: iifidatalink;
begin
 result:= iifidatalink(self);
end;

procedure tcustomdataedit.ifisetvalue(var avalue; var accept: boolean);
begin
 if accept and (fifiserverintf <> nil) then begin
  fifiserverintf.setvalue(getifidatalinkintf,avalue,accept);
 end;
end;

function tcustomdataedit.getifilink: tifilinkcomp;
begin
 result:= fifilink;
end;

{$endif mse_with_ifi}

{ tcustomstringedit }

function tcustomstringedit.internaldatatotext(const data): msestring;
begin
 if @data = nil then begin
  result:= fvalue;
 end
 else begin
  result:= msestring(data);
 end;
 updatedisptext(result);
end;

procedure tcustomstringedit.texttodata(const atext: msestring; var data);
begin
 msestring(data):= atext;
end;

function tcustomstringedit.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= tgridmsestringdatalist.create(sender);
end;

function tcustomstringedit.getdatatype: listdatatypety;
begin
 result:= dl_msestring;
end;

procedure tcustomstringedit.setvalue(const Value: msestring);
begin
 fvalue:= Value;
 valuechanged;
end;

function tcustomstringedit.getvaluetext: msestring;
begin
 result:= feditor.text;
end;

procedure tcustomstringedit.updatedisptext(var avalue: msestring);
begin
 updateflagtext(avalue);
end;

procedure tcustomstringedit.dosetvalue(var avalue: msestring; var accept: boolean);
begin
 if canevent(tmethod(fonsetvalue)) then begin
  fonsetvalue(self,avalue,accept);
 end;
end;

procedure tcustomstringedit.texttovalue(var accept: boolean;
                                                       const quiet: boolean);
var
 mstr1: msestring;
begin
 mstr1:= getvaluetext;
 updateflagtext(mstr1);
 checktext(mstr1,accept);
 if not accept then begin
  exit;
 end;
 if not quiet then begin
  dosetvalue(mstr1,accept);
{$ifdef mse_with_ifi}
  ifisetvalue(mstr1,accept);
{$endif}
 end;
 if accept then begin
  value:= mstr1;
 end;
end;

function tcustomstringedit.checkvalue(const quiet: boolean = false): boolean;
var
 mstr1: msestring;
begin
 if optionsedit * 
         [oe_trimleft,oe_trimright,oe_uppercase,oe_lowercase] <> [] then begin
  mstr1:= getvaluetext;
  updateflagtext(mstr1);
  text:= mstr1;
 end;
 result:= inherited checkvalue(quiet);
end;

procedure tcustomstringedit.valuetogrid(arow: integer);
begin
 fgridintf.setdata(arow,fvalue);
end;

procedure tcustomstringedit.gridtovalue(arow: integer);
begin
 fgridintf.getdata(arow,fvalue);
 inherited;
end;

procedure tcustomstringedit.readstatvalue(const reader: tstatreader);
//var
// ar1: msestringarty;
begin
// ar1:= nil; //compiler warning
// if fgridintf = nil then begin
//  ar1:= nil;
//  ar1:= reader.readarray(valuevarname+'ar',ar1);
//  if high(ar1) >= 0 then begin
//   value:= concatstrings(ar1,lineend);
//  end
//  else begin
   value:= reader.readmsestrings(valuevarname,value);
//  end;
// end;
end;

procedure tcustomstringedit.writestatvalue(const writer: tstatwriter);
//var
// ar1: msestringarty;
begin
// ar1:= breaklines(value);
// if high(ar1) > 0 then begin
//  writer.writearray(valuevarname+'ar',ar1);
// end
// else begin
  writer.writemsestrings(valuevarname,value);
// end;
end;

procedure tcustomstringedit.dragevent(var info: draginfoty);
begin
 with info do begin
  case eventkind of
   dek_check: begin
    inherited;
    accept:= accept or (dragobjectpo^ is tstringdragobject);
   end;
   dek_drop: begin
    if dragobjectpo^ is tstringdragobject then begin
     value:= tstringdragobject(dragobjectpo^).data;
    end
    else begin
     inherited;
    end;
   end;
   else begin
    inherited;
   end;
  end;
 end;
end;

procedure tcustomstringedit.fillcol(const value: msestring);
begin
 internalfillcol(value);
end;

procedure tcustomstringedit.assigncol(const value: tmsestringdatalist);
begin
 internalassigncol(value);
end;

function tcustomstringedit.getgridvalue(const index: integer): msestring;
begin
 internalgetgridvalue(index,result);
end;

procedure tcustomstringedit.setgridvalue(const index: integer;
  const Value: msestring);
begin
 internalsetgridvalue(index,value);
end;

procedure tcustomstringedit.sortfunc(const l, r; var result: integer);
begin
 if oe_casesensitive in foptionsedit then begin
  result:= msecomparestr(msestring(l),msestring(r));
 end
 else begin
  result:= msecomparetext(msestring(l),msestring(r));
 end;
end;

function tcustomstringedit.getgridvalues: msestringarty;
begin
 result:= tmsestringdatalist(fgridintf.getcol.datalist).asarray;
end;

procedure tcustomstringedit.setgridvalues(const Value: msestringarty);
begin
 tmsestringdatalist(fgridintf.getcol.datalist).asarray:= value;
end;
{
function tcustomstringedit.isempty(const atext: msestring): boolean;
begin
 if fvaluedefault <> '' then begin
  result:= atext = fvaluedefault;
 end
 else begin
  result:= atext = getnulltext;
 end;
end;
}

function tcustomstringedit.getdefaultvalue: pointer;
begin
 result:= @fvaluedefault;
end;

{$ifdef mse_with_ifi}
function tcustomstringedit.getifilink: tifistringlinkcomp;
begin
 result:= tifistringlinkcomp(fifilink);
end;

procedure tcustomstringedit.setifilink(const avalue: tifistringlinkcomp);
begin
 inherited setifilink(avalue);
end;

{$endif}

{ tstringedit }

{ tcustommemoedit }

constructor tcustommemoedit.create(aowner: tcomponent);
begin
 inherited;
 foptionswidget:= defaultoptionswidgetmousewheel;
 foptionsedit:= defaultmemooptionsedit;
 textflags:= defaultmemotextflags;
 textflagsactive:= defaultmemotextflagsactive;
end;

procedure tcustommemoedit.afterconstruction;
begin
 inherited;
 fcreated:= true;
end;

procedure tcustommemoedit.internalcreateframe;
begin
 tscrolleditframe.create(iscrollframe(self),iscrollbar(self));
 with frame do begin
  sbhorz.pagesize:= 1;
  sbvert.pagesize:= 1;
 end;
end;

procedure tcustommemoedit.mouseevent(var info: mouseeventinfoty);
begin
 tscrolleditframe(fframe).mouseevent(info);
 inherited;
end;

function tcustommemoedit.getframe: tscrolleditframe;
begin
 result:= tscrolleditframe(inherited getframe);
end;

procedure tcustommemoedit.setframe(const avalue: tscrolleditframe);
begin
 inherited setframe(avalue);
end;

procedure tcustommemoedit.scrollevent(sender: tcustomscrollbar; event: scrolleventty);
var
 pagesize: integer;
 stepsize: integer;
 
 procedure init;
 begin
  if sender = frame.sbvert then begin
   stepsize:= feditor.font.lineheight;
   if stepsize > 0 then begin
    pagesize:= ((innerclientsize.cy - stepsize div 2) div stepsize) * stepsize;
   end
   else begin
    pagesize:= innerclientsize.cy;
   end;
  end
  else begin
   stepsize:= innerclientsize.cx div 10;
   pagesize:= innerclientsize.cx - stepsize;
  end;
  if stepsize < 2 then begin
   stepsize:= 2;
  end;
  if pagesize < stepsize then begin
   pagesize:= stepsize;
  end;
 end;

var 
 int1: integer;
 size1: sizety;
 
begin
 int1:= 0;
 case event of
  sbe_stepup: begin
   init;
   int1:= stepsize;
  end;
  sbe_stepdown: begin
   init;
   int1:= -stepsize;
  end;
  sbe_pageup,sbe_wheelup: begin
   init;
   int1:=  pagesize;
  end;
  sbe_pagedown,sbe_wheeldown: begin
   init;
   int1:=  -pagesize;
  end;
  sbe_valuechanged: begin
   feditor.setscrollvalue(sender.value,sender = frame.sbhorz);
  end;
 end;
 if int1 <> 0 then begin
  size1:= feditor.textrect.size;
  subsize1(size1,innerclientsize);
  if sender = frame.sbvert then begin
   if size1.cy > 0 then begin
    sender.value:= sender.value + int1 / size1.cy;
   end;
  end
  else begin
   if size1.cx > 0 then begin
    sender.value:= sender.value + int1 / size1.cx;
   end;
  end;
 end;
end;

procedure tcustommemoedit.updatescrollbars;
var
 rect1: rectty;
 size1: sizety;
begin
 rect1:= feditor.textrect;
 size1:= innerclientsize;
 if (ftextrectbefore.cx <> rect1.cx) or 
                (ftextrectbefore.cy <> rect1.cy) or
                (size1.cx <> fclientsizebefore.cx) or 
                (size1.cy <> fclientsizebefore.cy) then begin
  ftextrectbefore:= rect1;
  fclientsizebefore:= size1;
  with frame do begin
   if rect1.cx > 0 then begin
    sbhorz.pagesize:= size1.cx / rect1.cx;
   end
   else begin
    sbhorz.pagesize:= 1;
   end;
   if rect1.cy > 0 then begin
    sbvert.pagesize:= size1.cy / rect1.cy;
   end
   else begin
    sbvert.pagesize:= 1;
   end;
   if fupdatescrollbarcount < 10 then begin //limit recursions
    inc(fupdatescrollbarcount);
    try
     tcustomframe1(fframe).updatestate;
    finally
     dec(fupdatescrollbarcount);
    end;
   end;
  end;
 end;
end;

procedure tcustommemoedit.editnotification(var info: editnotificationinfoty);
var
 rect1: rectty;
begin
 inherited;
 if fcreated and windowallocated then begin
  case info.action of
   ea_textchanged: begin
    updatescrollbars;
   end;
   ea_caretupdating: begin
    if fframe <> nil then begin
     rect1.size:= feditor.textrect.size;
     subsize1(rect1.size,feditor.destrect.size);
     rect1.pos:= feditor.destrect.pos;
     subpoint1(rect1.pos,innerclientpos);
     with frame do begin
      if rect1.cx > 0 then begin
       sbhorz.value:= -rect1.x / rect1.cx;
      end
      else begin
       sbhorz.value:= 0;
      end;
      if rect1.cy > 0 then begin
       sbvert.value:= -rect1.y / rect1.cy;
      end
      else begin
       sbvert.value:= 0;
      end;
     end;
    end;
   end;
   ea_indexmoved: begin
    fxpos:= feditor.caretpos.x;
   end;
  end; 
 end;
end;

procedure tcustommemoedit.dokeydown(var info: keyeventinfoty);
var
 int1,int2: integer;
 rect1: rectty;
 indexbefore: integer;
begin
 if not (es_processed in info.eventstate) then begin
  if info.shiftstate * shiftstatesmask - [ss_shift] = [] then begin
   include(info.eventstate,es_processed);
   with feditor do begin
    int2:= fxpos;
    int1:= 0;
    case info.key of
     key_pageup: begin
      int1:= -(innerpaintrect.cy - self.font.lineheight);
     end;
     key_pagedown: begin
      int1:= (innerpaintrect.cy - self.font.lineheight);
     end;
     key_up: begin
      int1:= - self.font.lineheight;
     end;
     key_down: begin
      int1:= self.font.lineheight; 
     end;
     else begin
      exclude(info.eventstate,es_processed);
     end;
    end;
    if int1 <> 0 then begin
     int1:= caretpos.y + int1;
     rect1:= textrect;
     if int1 < rect1.y then begin
      int1:= rect1.y;
     end;
     if int1 >= rect1.y + rect1.cy then begin
      int1:= rect1.y + rect1.cy - 1;
     end;
     indexbefore:= curindex;
     moveindex(mousepostotextindex(makepoint(fxpos,int1)),
                      ss_shift in info.shiftstate);
     if ss_shift in info.shiftstate then begin
      invalidate;
     end;
     if fxpos < int2 then begin
      fxpos:= int2;
     end;
     if (oe_exitoncursor in foptionsedit) and (indexbefore = curindex) and
             (info.shiftstate = []) and
             ((info.key = key_down) or (info.key = key_up)) then begin
      exclude(info.eventstate,es_processed);
     end;
    end;
   end;
  end;
  if not (es_processed in info.eventstate) then begin
   inherited;
  end;
 end;
end;

procedure tcustommemoedit.setupeditor;
begin
 inherited;
 updatescrollbars;
end;

procedure tcustommemoedit.domousewheelevent(var info: mousewheeleventinfoty);
begin
 if fframe <> nil then begin
  frame.domousewheelevent(info,false);
 end;
 inherited;
end;

{ thexstringedit }

function thexstringedit.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= tgridansistringdatalist.create(sender);
end;

function thexstringedit.getdatatype: listdatatypety;
begin
 result:= dl_ansistring;
end;

function thexstringedit.getgridvalue(const index: integer): ansistring;
begin
 internalgetgridvalue(index,result);
end;

procedure thexstringedit.setgridvalue(const index: integer; const Value: ansistring);
begin
 internalsetgridvalue(index,value);
end;

function thexstringedit.getgridvalues: stringarty;
begin
 result:= tansistringdatalist(fgridintf.getcol.datalist).asarray;
end;

procedure thexstringedit.setgridvalues(const Value: stringarty);
begin
 tansistringdatalist(fgridintf.getcol.datalist).asarray:= value;
end;

procedure thexstringedit.fillcol(const value: string);
begin
 internalfillcol(value);
end;

procedure thexstringedit.assigncol(const value: tansistringdatalist);
begin
 internalassigncol(value);
end;

procedure thexstringedit.dosetvalue(var avalue: ansistring; var accept: boolean);
begin
 if accept and canevent(tmethod(fonsetvalue)) then begin
  fonsetvalue(self,avalue,accept);
 end;
end;

procedure thexstringedit.texttovalue(var accept: boolean; const quiet: boolean);
var
 mstr1: msestring;
 str1: ansistring;
begin
 try
  mstr1:= feditor.text;
  checktext(mstr1,accept);
  if not accept then begin
   exit;
  end;
  str1:= strtobytestr(printableascii(mstr1))
 except
  formaterror(quiet);
  accept:= false
 end;
 if accept then begin
  if not quiet then begin
   dosetvalue(str1,accept);
  end;
  if accept then begin
   value:= str1;
  end;
 end;
end;

function thexstringedit.internaldatatotext(const data): msestring;
var
 str1: ansistring;
begin
 if @data = nil then begin
  str1:= fvalue;
 end
 else begin
  str1:= ansistring(data);
 end;
 result:= bytestrtostr(str1,nb_hex,true);
end;

procedure thexstringedit.valuetogrid(arow: integer);
begin
 fgridintf.setdata(arow,fvalue);
end;

procedure thexstringedit.gridtovalue(arow: integer);
begin
 fgridintf.getdata(arow,fvalue);
 inherited;
end;

procedure thexstringedit.readstatvalue(const reader: tstatreader);
begin
// if fgridintf = nil then begin
  value:= reader.readstring(valuevarname,value);
// end;
end;

procedure thexstringedit.writestatvalue(const writer: tstatwriter);
begin
 writer.writestring(valuevarname,value);
end;

procedure thexstringedit.sortfunc(const l ; const r ; var result: integer);
begin
 result:= stringcomp(ansistring(l),ansistring(r)); 
end;

procedure thexstringedit.setvalue(const Value: string);
begin
 fvalue := Value;
 valuechanged;
end;

{ tcustomdropdownedit }

constructor tcustomdropdownedit.create(aowner: tcomponent);
begin
 inherited;
 fdropdown:= createdropdowncontroller;
 fcontrollerintf:= idataeditcontroller(fdropdown);
end;

destructor tcustomdropdownedit.destroy;
begin
 inherited;
 fdropdown.Free;
end;
{
procedure tcustomdropdownedit.editnotification(var info: editnotificationinfoty);
begin
 if fdropdown <> nil then begin
  fdropdown.editnotification(info);
 end;
 inherited;
end;
}
{
procedure tcustomdropdownedit.dokeydown(var info: keyeventinfoty);
begin
 fdropdown.dokeydown(info);
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;
}
{
procedure tcustomdropdownedit.domousewheelevent(var info: mousewheeleventinfoty);
begin
 fdropdown.domousewheelevent(info);
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;
}
function tcustomdropdownedit.createdropdowncontroller: tcustomdropdowncontroller;
begin
 result:= tdropdowncontroller.create(idropdown(self));
end;

procedure tcustomdropdownedit.dobeforedropdown;
begin
 if canevent(tmethod(fonbeforedropdown)) then begin
  fonbeforedropdown(self);
 end;
end;

procedure tcustomdropdownedit.doafterclosedropdown;
begin
 if canevent(tmethod(fonafterclosedropdown)) then begin
  fonafterclosedropdown(self);
 end;
end;

procedure tcustomdropdownedit.buttonaction(var action: buttonactionty;
  const buttonindex: integer);
begin
 //dummy
end;
{
procedure tcustomdropdownedit.mouseevent(var info: mouseeventinfoty);
begin
 tcustombuttonframe(fframe).mouseevent(info);
 inherited;
end;
}
procedure tcustomdropdownedit.texttovalue(var accept: boolean;
                       const quiet: boolean);
begin
 if (deo_selectonly in fdropdown.options) and not fdropdown.dataselected and 
                       (text <> '') then begin
  accept:= false;
  if not quiet and not (deo_autodropdown in fdropdown.options) then begin
   fdropdown.dropdown;
  end
  else begin
   feditor.undo;
  end;
 end
 else begin
  inherited;
 end;
end;
{
function tcustomdropdownedit.getcellframe: framety;
begin
 result:= fframe.cellframe;
end;
}
function tcustomdropdownedit.getframe: tdropdownbuttonframe;
begin
 result:= tdropdownbuttonframe(inherited getframe);
end;

procedure tcustomdropdownedit.setframe(const avalue: tdropdownbuttonframe);
begin
 inherited setframe(avalue);
end;
{
procedure tcustomdropdownedit.internalcreateframe;
begin
 fdropdown.createframe;
end;
}
procedure tcustomdropdownedit.dohide;
begin
 fdropdown.canceldropdown;
 inherited;
end;
{
procedure tcustomdropdownedit.updatereadonlystate;
begin
 inherited;
 if fdropdown <> nil then begin
  fdropdown.updatereadonlystate;
 end;
end;
}
function tcustomdropdownedit.getvalueempty: integer;
begin
 result:= -1;
end;

{$ifdef mse_with_ifi}
function tcustomdropdownedit.getifidatalinkintf: iifidatalink;
begin
 result:= iifidropdownlistdatalink(self);
end;

procedure tcustomdropdownedit.ifidropdownlistchanged(const acols: tifidropdowncols);
begin
end;
{$endif}

{
function tcustomdropdownedit.getbutton: tdropdownbutton;
begin
 with tdropdownbuttonframe(fframe) do begin
  result:= tdropdownbutton(buttons[activebutton]);
 end;
end;

procedure tcustomdropdownedit.setbutton(const avalue: tdropdownbutton);
begin
 with tdropdownbuttonframe(fframe) do begin
  tdropdownbutton(buttons[activebutton]).assign(avalue);
 end;
end;
}
{ tcustomdropdownwidgetedit }

function tcustomdropdownwidgetedit.createdropdowncontroller: tcustomdropdowncontroller;
begin
 result:= tdropdownwidgetcontroller.create(idropdownwidget(self));
end;

function tcustomdropdownwidgetedit.getdropdown: tdropdownwidgetcontroller;
begin
 result:= tdropdownwidgetcontroller(fdropdown);
end;

procedure tcustomdropdownwidgetedit.setdropdown(
                     const avalue: tdropdownwidgetcontroller);
begin
 fdropdown.Assign(avalue);
end;

{ tcustomdropdownlistedit }

function tcustomdropdownlistedit.getdropdownitems: tdropdowncols;
begin
 result:= nil;
end;

function tcustomdropdownlistedit.getdropdown: tdropdownlistcontroller;
begin
 result:= tdropdownlistcontroller(fdropdown);
end;

procedure tcustomdropdownlistedit.setdropdown(
  const avalue: tdropdownlistcontroller);
begin
 fdropdown.Assign(avalue);
end;

function tcustomdropdownlistedit.createdropdowncontroller: tcustomdropdowncontroller;
begin
 result:= tdropdownlistcontroller.create(idropdownlist(self));
end;

procedure tcustomdropdownlistedit.internalsort(const acol: integer;
                                            const sortlist: tintegerdatalist);
var
 list: tintegerdatalist;
 int1: integer;
begin
 with tdropdownlistcontroller(fdropdown) do begin
  cols.beginupdate;
  if sortlist = nil then begin
   list:= tintegerdatalist.create;
  end
  else begin
   list:= sortlist;
  end;
  try
   cols[acol].sort(list,false);
   for int1:= 0 to cols.count - 1 do begin
    cols[int1].rearange(list);
   end;
  finally
   if sortlist = nil then begin
    list.free;
   end;
   cols.endupdate;
  end;
 end;
end;

procedure tcustomdropdownlistedit.sort(const acol: integer);
begin
 internalsort(acol,nil);
end;

{$ifdef mse_with_ifi}
function tcustomdropdownlistedit.getifilink: tifidropdownlistlinkcomp;
begin
 result:= tifidropdownlistlinkcomp(fifilink);
end;

procedure tcustomdropdownlistedit.setifilink1(const avalue: tifidropdownlistlinkcomp);
begin
 setifilink0(avalue);
end;

function tcustomdropdownlistedit.getifidatalinkintf: iifidatalink;
begin
 result:= iifidropdownlistdatalink(self);
end;

function tcustomdropdownlistedit.getifilinkkind: ptypeinfo;
begin
 result:= typeinfo(iifidropdownlistdatalink);
end;

procedure tcustomdropdownlistedit.ifidropdownlistchanged(
                                   const acols: tifidropdowncols);
begin
 dropdown.cols.assign(acols);
end;

{$endif}

{ thistorycontroller }

constructor thistorycontroller.create(const intf: idropdownlist);
begin
 inherited;
 fhistorymaxcount:= defaulthistorymaxcount;
 foptions:= defaulthistoryeditoptions;
end;

procedure thistorycontroller.checkmaxcount;
begin
 if valuelist.count > fhistorymaxcount then begin
  valuelist.count:= fhistorymaxcount;
 end;
end;

procedure thistorycontroller.sethistorymaxcount(const aValue: integer);
begin
 fhistorymaxcount := avalue;
 checkmaxcount;
end;

procedure thistorycontroller.clearhistory;
begin
 cols.clear;
end;
{
function thistorycontroller.gethistory: tmsestringdatalist;
begin
 result:= valuelist;
end;
}
procedure thistorycontroller.savehistoryvalue(const avalue: msestring);
var
 int1: integer;
 list: tmsestringdatalist;
begin
 list:= valuelist;
 list.insert(0,avalue);
 int1:= 1;
 while int1 < list.count do begin
  if list[int1] = avalue then begin
   list.deletedata(int1);
  end
  else begin
   inc(int1);
  end;
 end;
 checkmaxcount;
end;

procedure thistorycontroller.readstate(const reader: tstatreader);
begin
 reader.readdatalist('history',valuelist);
end;

procedure thistorycontroller.writestate(const writer: tstatwriter);
begin
 writer.writedatalist('history',valuelist);
end;

{ tcustomhistoryedit }

constructor tcustomhistoryedit.create(aowner: tcomponent);
begin
 inherited;
end;

procedure tcustomhistoryedit.savehistoryvalue;
begin
 thistorycontroller(fdropdown).savehistoryvalue(fvalue);
end;

procedure tcustomhistoryedit.loaded;
begin
 inherited;
// checkmaxcount;
end;

procedure tcustomhistoryedit.readstatstate(const reader: tstatreader);
begin
 inherited;
 thistorycontroller(fdropdown).readstate(reader);
end;

procedure tcustomhistoryedit.writestatstate(const writer: tstatwriter);
begin
 inherited;
 thistorycontroller(fdropdown).writestate(writer);
end;

procedure tcustomhistoryedit.setdropdown(const avalue: thistorycontroller);
begin
 fdropdown.Assign(avalue);
end;

function tcustomhistoryedit.getdropdown: thistorycontroller;
begin
 result:= thistorycontroller(fdropdown);
end;

procedure tcustomhistoryedit.texttovalue(var accept: boolean; const quiet: boolean);
begin
 inherited;
 if not quiet and accept and
      (deo_autosavehistory in thistorycontroller(fdropdown).foptions) then begin
  savehistoryvalue;
 end;
end;

function tcustomhistoryedit.createdropdowncontroller: tcustomdropdowncontroller;
begin
 result:= thistorycontroller.create(idropdownlist(self));
end;

{ tnumedit }

constructor tnumedit.create(aowner: tcomponent);
begin
 inherited;
 textflags:= defaultnumedittextflags;
end;

{ tcustomintegeredit }

constructor tcustomintegeredit.create(aowner: tcomponent);
begin
 fbase:= nb_dec;
 fbitcount:= 32;
 fmax:= maxint;
 inherited;
end;

function tcustomintegeredit.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= tgridintegerdatalist.create(sender);
end;

function tcustomintegeredit.getdatatype: listdatatypety;
begin
 result:= dl_integer;
end;

procedure tcustomintegeredit.valuetogrid(arow: integer);
begin
 fgridintf.setdata(arow,fvalue);
end;

procedure tcustomintegeredit.gridtovalue(arow: integer);
begin
 fgridintf.getdata(arow,fvalue);
 inherited;
end;

procedure tcustomintegeredit.setvalue(const Value: integer);
begin
 fvalue := Value;
 if fvaluechecking = 0 then begin
  fisnull:= false;
 end;
 valuechanged;
end;

function tcustomintegeredit.gettextvalue(var accept: boolean;
                                            const quiet: boolean): integer;
var
 mstr1: msestring;
begin
 if fisnull then begin
  result:= 0;
 end
 else begin
  try
   mstr1:= feditor.text;
   checktext(mstr1,accept);
   if not accept then begin
    exit;
   end;
   result:= strtointvalue(mstr1,fbase);
  except
   formaterror(quiet);
   accept:= false
  end;
 end;
end;

procedure tcustomintegeredit.texttovalue(var accept: boolean; const quiet: boolean);
var
 int1: integer;
// mstr1: msestring;
begin
 int1:= gettextvalue(accept,quiet);
{
 if fisnull then begin
  int1:= 0;
 end
 else begin
  try
   mstr1:= feditor.text;
   checktext(mstr1,accept);
   if not accept then begin
    exit;
   end;
   int1:= strtointvalue(mstr1,fbase);
  except
   formaterror(quiet);
   accept:= false
  end;
 end;
}
 if accept then begin
  if not fisnull then begin
   if fmax < fmin then begin //unsigned
    if (longword(int1) < longword(fmin)) or (longword(int1) > longword(fmax)) then begin
     rangeerror(fmin,fmax,quiet);
     accept:= false;
    end;
   end
   else begin
    if (int1 < fmin) or (int1 > fmax) then begin
     rangeerror(fmin,fmax,quiet);
     accept:= false;
    end;
   end;
  end;
  if accept then begin
   if not quiet and canevent(tmethod(fonsetvalue)) then begin
    fonsetvalue(self,int1,accept);
   end;
   if accept then begin
    value:= int1;
   end;
  end;
 end;
end;

procedure tcustomintegeredit.texttodata(const atext: msestring; var data);
var
 int1: integer;
begin
 try
  int1:= strtointvalue(atext,fbase);
 except
  int1:= 0;
 end;
 if int1 < fmin then begin
  int1:= fmin;
 end;
 if int1 > fmax then begin
  int1:= fmax;
 end;
 integer(data):= int1;
end;

procedure tcustomintegeredit.readstatvalue(const reader: tstatreader);
begin
// if fgridintf <> nil then begin
//  with fgridintf.getcol do begin
//   with tintegerdatalist(datalist) do begin
//    min:= fmin;
//    max:= fmax;
//   end;
//   dostatread(reader);
//  end;
//  reader.readintegerdatalist(valuevarname,tintegerdatalist(fgridintf.getcol.datalist),fmin,fmax);
// end
// else begin
  value:= reader.readinteger(valuevarname,value,fmin,fmax);
// end;
end;

procedure tcustomintegeredit.writestatvalue(const writer: tstatwriter);
begin
 writer.writeinteger(valuevarname,value);
end;

procedure tcustomintegeredit.setnullvalue;
begin
 value:= 0;
 text:= '';
 fisnull:= true;
end;

procedure tcustomintegeredit.setbase(const Value: numbasety);
begin
 if fbase <> value then begin
  fbase := Value;
  formatchanged;
 end;
end;

procedure tcustomintegeredit.setbitcount(const Value: integer);
begin
 if fbitcount <> value then begin
  fbitcount := Value;
  formatchanged;
 end;
end;

function tcustomintegeredit.internaldatatotext(const data): msestring;
begin
 if @data = nil then begin
  result:= intvaluetostr(fvalue,fbase,fbitcount);
 end
 else begin
  result:= intvaluetostr(integer(data),fbase,fbitcount);
 end;
end;

function tcustomintegeredit.getgridvalue(const index: integer): integer;
begin
 internalgetgridvalue(index,result);
end;

procedure tcustomintegeredit.setgridvalue(const index, Value: integer);
begin
 internalsetgridvalue(index,value);
end;

function tcustomintegeredit.getgridvalues: integerarty;
begin
 result:= tintegerdatalist(fgridintf.getcol.datalist).asarray;
end;

procedure tcustomintegeredit.setgridvalues(const Value: integerarty);
begin
 tintegerdatalist(fgridintf.getcol.datalist).asarray:= value;
end;

procedure tcustomintegeredit.fillcol(const value: integer);
begin
 internalfillcol(value);
end;

procedure tcustomintegeredit.assigncol(const value: tintegerdatalist);
begin
 internalassigncol(value);
end;

{$ifdef mse_with_ifi}
function tcustomintegeredit.getifilink: tifiintegerlinkcomp;
begin
 result:= tifiintegerlinkcomp(fifilink);
end;

procedure tcustomintegeredit.setifilink(const avalue: tifiintegerlinkcomp);
begin
 inherited setifilink(avalue);
end;

{$endif}

function tcustomintegeredit.getdefaultvalue: pointer;
begin
 result:= @fvaluedefault;
end;

{ tcustomint64edit }

constructor tcustomint64edit.create(aowner: tcomponent);
begin
 fbase:= nb_dec;
 fbitcount:= 64;
 fmax:= maxint64;
 inherited;
end;

function tcustomint64edit.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= tgridint64datalist.create(sender);
end;

function tcustomint64edit.getdatatype: listdatatypety;
begin
 result:= dl_int64;
end;

procedure tcustomint64edit.valuetogrid(arow: integer);
begin
 fgridintf.setdata(arow,fvalue);
end;

procedure tcustomint64edit.gridtovalue(arow: integer);
begin
 fgridintf.getdata(arow,fvalue);
 inherited;
end;

procedure tcustomint64edit.setvalue(const Value: int64);
begin
 fvalue := Value;
 if fvaluechecking = 0 then begin
  fisnull:= false;
 end;
 valuechanged;
end;

procedure tcustomint64edit.texttovalue(var accept: boolean; const quiet: boolean);
var
 int1: int64;
 mstr1: msestring;
begin
 if fisnull then begin
  int1:= 0;
 end
 else begin
  try
   mstr1:= feditor.text;
   checktext(mstr1,accept);
   if not accept then begin
    exit;
   end;
   int1:= strtointvalue64(mstr1,fbase);
  except
   formaterror(quiet);
   accept:= false
  end;
 end;
 if accept then begin
  if not fisnull then begin
   if fmax < fmin then begin //unsigned
    if (uint64(int1) < uint64(fmin)) or (uint64(int1) > uint64(fmax)) then begin
     rangeerror(fmin,fmax,quiet);
     accept:= false;
    end;
   end
   else begin
    if (int1 < fmin) or (int1 > fmax) then begin
     rangeerror(fmin,fmax,quiet);
     accept:= false;
    end;
   end;
  end;
  if accept then begin
   if not quiet and canevent(tmethod(fonsetvalue)) then begin
    fonsetvalue(self,int1,accept);
   end;
   if accept then begin
    value:= int1;
   end;
  end;
 end;
end;

procedure tcustomint64edit.texttodata(const atext: msestring; var data);
var
 int1: int64;
begin
 try
  int1:= strtointvalue64(atext,fbase);
 except
  int1:= 0;
 end;
 if int1 < fmin then begin
  int1:= fmin;
 end;
 if int1 > fmax then begin
  int1:= fmax;
 end;
 int64(data):= int1;
end;

procedure tcustomint64edit.readstatvalue(const reader: tstatreader);
begin
// if fgridintf <> nil then begin
//  with fgridintf.getcol do begin
//   with tint64datalist(datalist) do begin
//    min:= fmin;
//    max:= fmax;
//   end;
//   dostatread(reader);
//  end;
//  reader.readintegerdatalist(valuevarname,tintegerdatalist(fgridintf.getcol.datalist),fmin,fmax);
// end
// else begin
  value:= reader.readint64(valuevarname,value,fmin,fmax);
// end;
end;

procedure tcustomint64edit.writestatvalue(const writer: tstatwriter);
begin
 writer.writeint64(valuevarname,value);
end;

procedure tcustomint64edit.setnullvalue;
begin
 value:= 0;
 text:= '';
 fisnull:= true;
end;

procedure tcustomint64edit.setbase(const Value: numbasety);
begin
 if fbase <> value then begin
  fbase := Value;
  formatchanged;
 end;
end;

procedure tcustomint64edit.setbitcount(const Value: integer);
begin
 if fbitcount <> value then begin
  fbitcount := Value;
  formatchanged;
 end;
end;

function tcustomint64edit.internaldatatotext(const data): msestring;
begin
 if @data = nil then begin
  result:= intvaluetostr(fvalue,fbase,fbitcount);
 end
 else begin
  result:= intvaluetostr(int64(data),fbase,fbitcount);
 end;
end;

function tcustomint64edit.getgridvalue(const index: integer): int64;
begin
 internalgetgridvalue(index,result);
end;

procedure tcustomint64edit.setgridvalue(const index: integer; 
                      const Value: int64);
begin
 internalsetgridvalue(index,value);
end;

function tcustomint64edit.getgridvalues: int64arty;
begin
 result:= tint64datalist(fgridintf.getcol.datalist).asarray;
end;

procedure tcustomint64edit.setgridvalues(const Value: int64arty);
begin
 tint64datalist(fgridintf.getcol.datalist).asarray:= value;
end;

procedure tcustomint64edit.fillcol(const value: int64);
begin
 internalfillcol(value);
end;

procedure tcustomint64edit.assigncol(const value: tint64datalist);
begin
 internalassigncol(value);
end;

function tcustomint64edit.getdefaultvalue: pointer;
begin
 result:= @fvaluedefault;
end;


{ tkeystringdropdowncontroller }

constructor tkeystringdropdowncontroller.create(const intf: idropdownlist);
begin
 inherited;
 options:= defaultkeystringdropdownoptions;
 cols.count:= 2;
 valuecol:= 1;
 cols[1].options:= cols[1].options + [co_invisible];
end;

function tkeystringdropdowncontroller.getindex(const akey: msestring): integer;
            //todo: non linear search
var
 int1: integer;
 po1: pmsestringaty;
begin
 result:= -1;
 with cols[valuecol] do begin
  po1:= datapo;
  for int1:= 0 to count - 1 do begin
   if po1^[int1] = akey then begin
    result:= int1;
    break;
   end;
  end;
 end;
end;

{ tcustomkeystringedit }

procedure tcustomkeystringedit.setvalue(const avalue: msestring);
begin
 with tkeystringdropdowncontroller(fdropdown) do begin
  with tdropdowncols1(cols) do begin
   fitemindex:= getindex(avalue);
   if fitemindex >= 0 then begin
    fkeyvalue:= avalue;
   end;
  end;
 end;
 fvalue1:= avalue;
 valuechanged;
end;

procedure tcustomkeystringedit.readstatvalue(const reader: tstatreader);
begin
 value:= reader.readmsestring(valuevarname,value);
end;

procedure tcustomkeystringedit.writestatvalue(const writer: tstatwriter);
begin
 writer.writemsestring(valuevarname,value);
end;

function tcustomkeystringedit.createdropdowncontroller: tcustomdropdowncontroller;
begin
 result:= tkeystringdropdowncontroller.create(idropdownlist(self));
end;

procedure tcustomkeystringedit.texttovalue(var accept: boolean;
                      const quiet: boolean);
var
 mstr1: msestring;
 int1: integer;
begin
 with tdropdownlistcontroller(fdropdown) do begin
  int1:= itemindex;
  if (int1 >= 0) and (text <> '') then begin
//   mstr1:= cols[valuecol][int1];
   mstr1:= tdropdowncols1(cols).fkeyvalue;
  end
  else begin
   mstr1:= '';
  end;
 end;
 checktext(mstr1,accept);
 if not accept then begin
  exit;
 end;
 if not quiet and canevent(tmethod(fonsetvalue)) then begin
  fonsetvalue(self,mstr1,accept);
 end;
 if accept then begin
  value:= mstr1;
 end;
 if int1 < 0 then begin
  text:= ''; //for setnullvalue
 end;
end;

procedure tcustomkeystringedit.setnullvalue;
begin
 dropdown.itemindex:= -1;
end;

function tcustomkeystringedit.internaldatatotext(const data): msestring;
var
 int1: integer;
begin
 with tkeystringdropdowncontroller(fdropdown) do begin
  if @data = nil then begin
   int1:= itemindex;
   if int1 = -3 then begin
    int1:= getindex(fvalue1);
    tdropdowncols1(cols).fitemindex:= int1;
   end;    
  end
  else begin
   int1:= getindex(msestring(data));
  end;
  if int1 >= 0 then begin
   result:= cols[0][int1];
  end
  else begin
   result:= '';
  end;
 end;
end;

procedure tcustomkeystringedit.texttodata(const atext: msestring; var data);
begin
 //not supported
end;

//function tcustomkeystringedit.getdefaultvalue: pointer;
//begin
// result:= @fvaluedefault;
//end;

procedure tcustomkeystringedit.valuetogrid(arow: integer);
begin
 fgridintf.setdata(arow,fvalue1);
end;

procedure tcustomkeystringedit.gridtovalue(arow: integer);
begin
 fgridintf.getdata(arow,fvalue1);
 tdropdowncols1(tkeystringdropdowncontroller(fdropdown).cols).fitemindex:= -3;
 valuetotext;
end;

procedure tcustomkeystringedit.loaded;
begin
 inherited;
 if canevent(tmethod(foninit)) then begin
  foninit(self);
 end;
end;

{ tcustomenuedit }

constructor tcustomenuedit.create(aowner: tcomponent);
begin
 fvalue1:= -1;
 fvaluedefault1:= -1;
 fvalueempty:= -1;
 fbase:= nb_dec;
 fbitcount:= 32;
 fmin:= -1;
 fmax:= maxint;
 inherited;
end;

function getindex1(const avalue: integer; 
                       const enums: integerarty; const offset: integer): integer;
var
 int1: integer;
begin
 if enums <> nil then begin
  result:= -1;
  for int1:= 0 to high(enums) do begin
   if avalue = enums[int1] then begin
    result:= int1;
    break;
   end;
  end;
 end
 else begin
  result:= avalue - offset;
  if result < 0 then begin
   result:= -1;
  end;
 end;
end;

function tcustomenuedit.getindex(avalue: integer): integer;
begin
 if avalue = fvalueempty then begin
  result:= -1;
 end
 else begin
  result:= getindex1(avalue,enums,fvalueoffset);
  if result < 0 then begin
   result:= -1;
  end;
 end;
end;

procedure tcustomenuedit.texttodata(const atext: msestring; var data);
begin
 //not supported
end;

function tcustomenuedit.internaldatatotext(const data): msestring;
var
 int1,int2: integer;
begin
 with tdropdownlistcontroller(fdropdown) do begin
  if @data = nil then begin
   int1:= fvalue1;
  end
  else begin
   int1:= integer(data);
  end;
  int2:= getindex(int1);
  if (int2 < 0) or (int2 >= valuelist.count) then begin
   if not (deo_selectonly in options) and (int1 <> fvalueempty) then begin
    result:= intvaluetostr(int1,fbase,fbitcount);
   end
   else begin
    result:= '';
   end;
  end
  else begin
   result:= valuelist[int2];
  end;
 end;
end;

function tcustomenuedit.enumname(const avalue: integer): msestring;
begin
 result:= datatotext(avalue);
end;

procedure tcustomenuedit.clear;
begin
 enums:= nil;
 tdropdownlistcontroller(fdropdown).cols.clear;
end;

function tcustomenuedit.addrow(const aitems: array of msestring;
           const enum: integer = -1): integer; //returns itemindex
                   //enum = -1 -> no enum set
var
 int1,int2: integer;
begin
 result:= tdropdownlistcontroller(fdropdown).cols.addrow(aitems);
 if enum >= 0 then begin
  int1:= length(enums);
  if int1 <= result then begin
   setlength(enums,result+1);
   for int2:= int1 to result-1 do begin
    enums[int2]:= -1;
   end;
  end;
  enums[result]:= enum;
 end;
end;

procedure tcustomenuedit.fillcol(const avalue: integer);
begin
 internalfillcol(avalue);
end;

function tcustomenuedit.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= tgridenumdatalist.create(sender);
end;

function tcustomenuedit.getdatatype: listdatatypety;
begin
 result:= dl_integer;
end;

procedure tcustomenuedit.setvalue(const avalue: integer);
begin
 tdropdowncols1(tcustomdropdownlistcontroller(fdropdown).cols).fitemindex:= 
                         getindex(avalue);
 fvalue1:= avalue;
 valuechanged;
end;

function tcustomenuedit.getgridvalue(const index: integer): integer;
begin
 internalgetgridvalue(index,result);
end;

procedure tcustomenuedit.setgridvalue(const index, aValue: integer);
begin
 internalsetgridvalue(index,avalue);
end;

function tcustomenuedit.getgridvalues: integerarty;
begin
 result:= tintegerdatalist(fgridintf.getcol.datalist).asarray;
end;

procedure tcustomenuedit.setgridvalues(const avalue: integerarty);
begin
 tintegerdatalist(fgridintf.getcol.datalist).asarray:= avalue;
end;

function tcustomenuedit.getdefaultvalue: pointer;
begin
 result:= @fvaluedefault1;
end;

procedure tcustomenuedit.gridtovalue(arow: integer);
begin
 fgridintf.getdata(arow,fvalue1);
 valuetotext;
end;

procedure tcustomenuedit.texttovalue(var accept: boolean; const quiet: boolean);
var
 int1: integer;
 mstr1: msestring;
begin
 if trim(text) = '' then begin
  int1:= fvalueempty;
 end
 else begin
  int1:= tdropdownlistcontroller(fdropdown).itemindex;
  if (int1 >= 0) and (int1 <= high(enums)) then begin
   int1:= enums[int1];
  end
  else begin
   if int1 >= 0 then begin
    int1:= int1 + fvalueoffset;
   end
   else begin
    if not (deo_selectonly in fdropdown.options) and 
                                   not (des_isdb in fstate) then begin
     try
      mstr1:= feditor.text;
      checktext(mstr1,accept);
      if not accept then begin
       exit;
      end;
      int1:= strtointvalue(mstr1,fbase);
     except
      accept:= false;
      formaterror(quiet);
     end;
    end;
   end;
  end;
 end;
 if not ({(des_isdb in fstate) and} (int1 = fvalueempty)) and (int1 < fmin) or (int1 > fmax) then begin
  rangeerror(fmin,fmax,quiet);
  accept:= false;
 end;
 if accept then begin
  if not quiet and canevent(tmethod(fonsetvalue1)) then begin
   fonsetvalue1(self,int1,accept);
  end;
  if accept then begin
   value:= int1;
  end;
 end;
end;

procedure tcustomenuedit.valuetogrid(arow: integer);
begin
 fgridintf.setdata(arow,fvalue1);
end;

procedure tcustomenuedit.readstatvalue(const reader: tstatreader);
var
 min1,max1: integer;
begin
// if fgridintf <> nil then begin
//  fgridintf.getcol.dostatread(reader);
// end
// else begin
  if enums <> nil then begin
   min1:= fmin;
   max1:= fmax;
  end
  else begin
   if deo_forceselect in fdropdown.options then begin
    min1:= 0;
   end
   else begin
    min1:= fvalueempty;
   end;
   with tenumdropdowncontroller(fdropdown) do begin
    max1:= cols[valuecol].count - 1;
   end;
  end;
  value:= reader.readinteger(valuevarname,value,min1,max1);
// end;
end;

procedure tcustomenuedit.writestatvalue(const writer: tstatwriter);
begin
 writer.writeinteger(valuevarname,value);
end;

function tcustomenuedit.createdropdowncontroller: tcustomdropdowncontroller;
begin
 result:= tenumdropdowncontroller.create(idropdownlist(self));
end;

procedure tcustomenuedit.internalsort(const acol: integer;
  const sortlist: tintegerdatalist);
var
 list: tintegerdatalist;
 enum1: integerarty;
 po1: pinteger;
 int1: integer;
begin
 if sortlist = nil then begin
  list:= tintegerdatalist.create;
 end
 else begin
  list:= sortlist;
 end;
 try
  tdropdownlistcontroller(fdropdown).cols.beginupdate;
  inherited internalsort(acol,list);
  if enums <> nil then begin
   setlength(enum1,list.count);
   po1:= pinteger(tdatalist1(list).fdatapo);
   for int1:= 0 to high(enum1) do begin
    if po1^ > high(enums) then begin
     enum1[int1]:= -1;
    end
    else begin
     enum1[int1]:= enums[po1^];
    end;
    inc(po1);
   end;
   enums:= enum1;
  end;
 finally
  if sortlist = nil then begin
   list.free;
  end;
  tdropdownlistcontroller(fdropdown).cols.endupdate;
 end;
end;

procedure tcustomenuedit.setbase(const avalue: numbasety);
begin
 if fbase <> avalue then begin
  fbase:= avalue;
  formatchanged;
 end;
end;

procedure tcustomenuedit.setbitcount(const avalue: integer);
begin
 if fbitcount <> avalue then begin
  fbitcount:= avalue;
  formatchanged;
 end;
end;

procedure tcustomenuedit.setvalueoffset(avalue: integer);
begin
 if avalue < 0 then begin
  avalue:= 0;
 end;
 if avalue <> fvalueoffset then begin
  fvalueoffset:= avalue;
  value:= value; //update itemindex  
 end;
end;

procedure tcustomenuedit.assigncol(const avalue: tintegerdatalist);
begin
 internalassigncol(avalue);
end;

function tcustomenuedit.getvalueempty: integer;
begin
 result:= fvalueempty;
end;

function tcustomenuedit.textcellcopy: boolean;
begin
 result:= false;
end;

{$ifdef mse_with_ifi}
function tcustomenuedit.getifilink: tifienumlinkcomp;
begin
 result:= tifienumlinkcomp(fifilink);
end;

procedure tcustomenuedit.setifilink1(const avalue: tifienumlinkcomp);
begin
 setifilink0(avalue);
end;
{$endif}

{ tenumdropdowncontroller }

constructor tenumdropdowncontroller.create(const intf: idropdownlist);
begin
 inherited;
 options:= defaultenumdropdownoptions;
end;

{ tcustomenumedit }

procedure tcustomenumedit.loaded;
begin
 inherited;
 if canevent(tmethod(foninit)) then begin
  foninit(self);
 end;
end;

{ tenumtypeedit }

procedure tenumtypeedit.setoninit(const aValue: enumtypeediteventty);
begin
 foninit:= enumediteventty(avalue);
end;

function tenumtypeedit.getoninit: enumtypeediteventty;
begin
 result:= enumtypeediteventty(foninit);
end;

procedure tenumtypeedit.settypeinfopo(const avalue: ptypeinfo);
begin
 if avalue <> ftypeinfopo then begin
  if avalue <> nil then begin
   dropdown.cols[dropdown.valuecol].asarray:= getenumnames(avalue);
  end
  else begin
   dropdown.cols[dropdown.valuecol].clear;
  end;
 end;
end;

{ tcustomselector }

constructor tcustomselector.create(aowner: tcomponent);
begin
 fdropdownitems:= tdropdowncols.create(nil);
 inherited;
end;

destructor tcustomselector.destroy;
begin
 inherited;
 fdropdownitems.Free;
end;

procedure tcustomselector.dobeforedropdown;
begin
 inherited;
 fdropdownenums:= copy(enums);
 getdropdowninfo(fdropdownenums,fdropdownitems);
 tdropdowncols1(fdropdownitems).fitemindex:= 
                         getindex1(fvalue1,fdropdownenums,fvalueoffset);
end;

function tcustomselector.getdropdownitems: tdropdowncols;
begin
 result:= fdropdownitems;
end;

procedure tcustomselector.texttovalue(var accept: boolean; const quiet: boolean);
var
 int1: integer;
begin
 with tdropdownlistcontroller(fdropdown) do begin
  if (trim(text) = '') or (itemindex < 0) or
         (itemindex >= length(fdropdownenums)) and (length(fdropdownenums) <> 0) then begin
   int1:= -1;
  end
  else begin
   if length(fdropdownenums) = 0 then begin
    int1:= itemindex + fvalueoffset;
   end
   else begin
    int1:= fdropdownenums[itemindex];
   end;
  end;
  fdropdownenums:= nil;
  if not quiet and canevent(tmethod(fonsetvalue1)) then begin
   fonsetvalue1(self,int1,accept);
  end;
  if accept then begin
   value:= int1;
  end;
 end;
end;

{ tselector }

procedure tselector.getdropdowninfo(var aenums: integerarty;
  const names: tdropdowncols);
begin
 if canevent(tmethod(fongetdropdowninfo)) then begin
  fongetdropdowninfo(self)
 end;
end;

procedure tselector.loaded;
begin
 inherited;
 if canevent(tmethod(foninit)) then begin
  foninit(self);
 end;
end;

procedure tselector.setdropdownitems(const avalue: tdropdowncols);
begin
 fdropdownitems.Assign(avalue);
end;

{ tcustomrealedit }

constructor tcustomrealedit.create(aowner: tcomponent);
begin
 fvalue:= emptyreal;
 fvaluedefault:= emptyreal;
 fmin:= emptyreal;
 fmax:= bigreal;
 fvaluerange:= 1;
 inherited;
 include(foptionswidget,ow_mousewheel);
end;

function tcustomrealedit.griddata: trealdatalist;
begin
 checkgrid;
 result:= trealdatalist(fdatalist);
end;

procedure tcustomrealedit.setformatdisp(const Value: msestring);
begin
 fformatdisp := Value;
 formatchanged;
end;

procedure tcustomrealedit.setformatedit(const Value: msestring);
begin
 fformatedit := Value;
 formatchanged;
end;

function tcustomrealedit.internaldatatotext(const data): msestring;
var
 rea1: real;
begin
 if @data = nil then begin
  rea1:= fvalue;
 end
 else begin
  rea1:= realty(data);
 end;
 if (@data = nil) and focused then begin
  result:= realtytostrrange(rea1,fformatedit,fvaluerange);
 end
 else begin
  result:= realtytostrrange(rea1,fformatdisp,fvaluerange);
 end;
end;

function tcustomrealedit.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= tgridrealdatalist.create(sender);
end;

function tcustomrealedit.getdatatype: listdatatypety;
begin
 result:= dl_real;
end;

procedure tcustomrealedit.gridtovalue(arow: integer);
begin
 fgridintf.getdata(arow,fvalue);
 inherited;
end;

procedure tcustomrealedit.valuetogrid(arow: integer);
begin
 fgridintf.setdata(arow,fvalue);
end;

procedure tcustomrealedit.setvalue(const Value: realty);
begin
 fvalue := Value;
 valuechanged;
end;

function tcustomrealedit.gettextvalue(var accept: boolean; 
                                             const quiet: boolean): realty;
var
 mstr1: msestring;
begin
 try
  if focused then begin
   mstr1:= feditor.text;
  end
  else begin
   mstr1:= realtytostrrange(fvalue,fformatedit,fvaluerange)
  end;
  checktext(mstr1,accept);
  if not accept then begin
   result:= emptyreal; //compiler warning
   exit;
  end;
  result:= strtorealty(mstr1);
 except
  formaterror(quiet);
  accept:= false
 end;
end;

procedure tcustomrealedit.texttovalue(var accept: boolean; const quiet: boolean);
var
 rea1,rea2: realty;
 str1: msestring;
 int1: integer;
begin
 rea1:= gettextvalue(accept,quiet);
 if accept then begin
  str1:= realtytostr(rea1,fformatedit);
  try
   rea2:= strtorealty(str1); //round to editformat
   rea1:= rea2;
  except
  end;
  rea1:= reapplyrange(rea1,fvaluerange);
  if not ((des_isdb in fstate) and isemptyreal(rea1)) then begin
   if (cmprealty(fmin,rea1) > 0) or (cmprealty(fmax,rea1) < 0) then begin
    rangeerror(fmin,fmax,quiet);
    accept:= false;
   end;
  end;
  if accept then begin
   if not quiet then begin
    if canevent(tmethod(fonsetintvalue)) then begin
     int1:= realtytoint(rea1);
     fonsetintvalue(self,int1,accept);
     rea1:= inttorealty(int1);
    end
    else begin
     if canevent(tmethod(fonsetvalue)) then begin
      fonsetvalue(self,rea1,accept);
     end;
    end;
   end;
   if accept then begin
    value:= rea1;
   end;
  end;
 end;
end;

procedure tcustomrealedit.texttodata(const atext: msestring; var data);
var
 rea1: realty;
begin
 try
  rea1:= reapplyrange(strtorealty(atext),fvaluerange);
 except
  rea1:= emptyreal;
 end;
 if cmprealty(fmin,rea1) > 0 then begin
  rea1:= fmin;
 end;
 if cmprealty(fmax,rea1) < 0 then begin
  rea1:= fmax;
 end;
 realty(data):= rea1;
end;

procedure tcustomrealedit.readvalue(reader: treader);
begin
 value:= readrealty(reader);
end;

procedure tcustomrealedit.readvaluedefault(reader: treader);
begin
 valuedefault:= readrealty(reader);
end;

procedure tcustomrealedit.readmin(reader: treader);
begin
 fmin:= readrealty(reader);
end;

procedure tcustomrealedit.readmax(reader: treader);
begin
 fmax:= readrealty(reader);
end;

procedure tcustomrealedit.readvaluescale(reader: treader);
begin
 valuerange:= valuescaletorange(reader);
end;

procedure tcustomrealedit.defineproperties(filer: tfiler);
var
 bo1,bo2,bo3,bo4: boolean;
begin
 inherited;
 
 filer.DefineProperty('val',
             {$ifdef FPC}@{$endif}readvalue,nil,false);
 filer.DefineProperty('mi',{$ifdef FPC}@{$endif}readmin,nil,false);
 filer.DefineProperty('ma',{$ifdef FPC}@{$endif}readmax,nil,false);
 filer.DefineProperty('def',{$ifdef FPC}@{$endif}readvaluedefault,nil,false);
 filer.defineproperty('valuescale',{$ifdef FPC}@{$endif}readvaluescale,nil,false);
end;

procedure tcustomrealedit.readstatvalue(const reader: tstatreader);
begin
// if fgridintf <> nil then begin
//  with fgridintf.getcol do begin
//   with trealdatalist(datalist) do begin
//    min:= fmin;
//    max:= fmax;
//   end;
//   dostatread(reader);
//  end;
//  reader.readrealdatalist(valuevarname,trealdatalist(fgridintf.getcol.datalist),fmin,fmax);
// end
// else begin
  value:= reader.readreal(valuevarname,value,fmin,fmax)
// end;
end;

procedure tcustomrealedit.writestatvalue(const writer: tstatwriter);
begin
 writer.writereal(valuevarname,value);
end;

function tcustomrealedit.getgridvalue(const index: integer): realty;
begin
 internalgetgridvalue(index,result);
end;

function tcustomrealedit.getgridintvalue(const index: integer): integer;
var
 rea1: realty;
begin
 internalgetgridvalue(index,rea1);
 result:= realtytoint(rea1);
end;

procedure tcustomrealedit.setgridvalue(const index: integer;
                                          const avalue: realty);
begin
 internalsetgridvalue(index,avalue);
end;

procedure tcustomrealedit.setgridintvalue(const index: integer;
                                           const avalue: integer);
var
 rea1: realty;
begin
 rea1:= inttorealty(avalue); //avoid FPC crash
 internalsetgridvalue(index,rea1);
end;

function tcustomrealedit.getgridvalues: realarty;
begin
 result:= trealdatalist(fgridintf.getcol.datalist).asarray;
end;

function tcustomrealedit.getgridintvalues: integerarty;
var
 ar1: realarty;
 int1: integer;
begin
 ar1:= trealdatalist(fgridintf.getcol.datalist).asarray;
 setlength(result,length(ar1));
 for int1:= 0 to high(ar1) do begin
  result[int1]:= realtytoint(ar1[int1]);
 end;
end;

procedure tcustomrealedit.setgridvalues(const avalue: realarty);
begin
 trealdatalist(fgridintf.getcol.datalist).asarray:= avalue;
end;

procedure tcustomrealedit.setgridintvalues(const avalue: integerarty);
var
 ar1: realarty;
 int1: integer;
begin
 setlength(ar1,length(avalue));
 for int1:= 0 to high(ar1) do begin
  ar1[int1]:= inttorealty(avalue[int1]);
 end;
 trealdatalist(fgridintf.getcol.datalist).asarray:= ar1;
end;

procedure tcustomrealedit.setvaluerange(const avalue: real);
begin
 if fvaluerange <> avalue then begin
  fvaluerange:= avalue;
  valuetotext;
 end;
end;

procedure tcustomrealedit.fillcol(const value: realty);
begin
 internalfillcol(value);
end;

procedure tcustomrealedit.assigncol(const value: trealdatalist);
begin
 internalassigncol(value);
end;

function tcustomrealedit.getasinteger: integer;
begin
 result:= realtytoint(value);
end;

procedure tcustomrealedit.setasinteger(const avalue: integer);
begin
 value:= inttorealty(avalue);
end;

function tcustomrealedit.getascurrency: currency;
begin
 if isnull then begin
  result:= 0;
 end
 else begin
  result:= value;
 end;
end;

procedure tcustomrealedit.setascurrency(const avalue: currency);
begin
 value:= avalue;
end;

function tcustomrealedit.isnull: boolean;
begin
 result:= isemptyreal(value);
end;

{$ifdef mse_with_ifi}

function tcustomrealedit.getifilink: tifireallinkcomp;
begin
 result:= tifireallinkcomp(fifilink);
end;

procedure tcustomrealedit.setifilink(const avalue: tifireallinkcomp);
begin
 inherited setifilink(avalue);
end;

{$endif}

function tcustomrealedit.getdefaultvalue: pointer;
begin
 result:= @fvaluedefault;
end;

procedure tcustomrealedit.setmin(const avalue: realty);
begin
 fmin:= avalue;
end;

procedure tcustomrealedit.setmax(const avalue: realty);
begin
 fmax:= avalue;
end;

{ tspineditframe }

constructor tspineditframe.create(const intf: icaptionframe;
               const stepintf: istepbar);
begin
 include(fstepstate,sfs_spinedit);
 inherited;
 fi.colorclient:= cl_foreground;
 fi.levelo:= -2;
 inflateframe(fi.innerframe,1);
 fforcevisiblebuttons:= [sk_up,sk_down];
 fforceinvisiblebuttons:= [];
 internalupdatestate;
end;

procedure tspineditframe.setbuttonsvisible(const avalue: stepkindsty);
begin
 inherited buttonsvisible:= avalue * spinstepbuttons;
end;

{ tcustomrealspinedit }

constructor tcustomrealspinedit.create(aowner: tcomponent);
begin
 fstep:= 1;
 inherited;
end;

procedure tcustomrealspinedit.internalcreateframe;
begin
 tspineditframe.create(iscrollframe(self),istepbar(self));
end;

function tcustomrealspinedit.gettextvalue(var accept: boolean;
               const quiet: boolean): realty;
 function initvalue: realty;
 begin
  result:= 0;
  if result < fmin then begin
   result:= fmin;
  end;
  if result > fmax then begin
   result:= fmax;
  end;
 end;
 
label
 endlab,endlab1;
begin
 case fstepflag of
  sk_last: begin
   result:= fmax;
  end;
  sk_first: begin
   result:= fmin;
  end;
  sk_up: begin
   result:= fvalue;
   if isemptyreal(fvalue) then begin
    result:= initvalue;
//    result:= fmin;
//    if isemptyreal(result) then begin
//     result:= 0;
//    end;
    goto endlab;
   end;
   result:= result + fstep;
  end;
  sk_down: begin
   result:= fvalue;
   if isemptyreal(fvalue) then begin
    result:= initvalue;
//    result:= fmax;
//    if isemptyreal(result) then begin
//     result:= 0;
//    end;
    goto endlab;
   end;
   result:= result - fstep;
  end;
  else begin
   result:= inherited gettextvalue(accept,quiet);
   goto endlab1;
  end;   
 end;
endlab:
 if result < fmin then begin
  result:= fmin;
 end;
 if result > fmax then begin
  result:= fmax;
 end;
endlab1:
 fstepflag:= stepkindty(-1);
end;

procedure tcustomrealspinedit.dostep(const event: stepkindty);
begin
 if not (csdesigning in componentstate) then begin
  if event in [sk_up,sk_down,sk_first,sk_last] then begin
   if edited then begin
    if not checkvalue then begin
     exit;
    end;
   end;
   fstepflag:= event; 
   checkvalue;
  end;
 end;
end;

procedure tcustomrealspinedit.mouseevent(var info: mouseeventinfoty);
begin
 tspineditframe(fframe).mouseevent(info);
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;

function tcustomrealspinedit.getframe: tspineditframe;
begin
 result:= tspineditframe(pointer(inherited frame));
end;

procedure tcustomrealspinedit.setframe(const avalue: tspineditframe);
begin
 inherited frame:= tcaptionframe(pointer(avalue));
end;

procedure tcustomrealspinedit.domousewheelevent(var info: mousewheeleventinfoty);
begin
 tspineditframe(fframe).domousewheelevent(info);
 inherited;
end;

procedure tcustomrealspinedit.updatereadonlystate;
begin
 inherited;
 if fframe <> nil then begin
  if readonly then begin
   frame.disabledbuttons:= allstepkinds;
  end
  else begin
   frame.disabledbuttons:= [];
  end;
 end;
end;

{ tcustomdatetimeedit }

constructor tcustomdatetimeedit.create(aowner: tcomponent);
begin
 fvalue:= emptydatetime;
 fvaluedefault:= emptydatetime;
 fmin:= emptydatetime;
 fmax:= bigdatetime;
 inherited;
end;

procedure tcustomdatetimeedit.setvalue(const Value: tdatetime);
begin
 fvalue := Value;
 valuechanged;
end;

procedure tcustomdatetimeedit.setformatdisp(const Value: msestring);
begin
 fformatdisp := Value;
 formatchanged;
end;

procedure tcustomdatetimeedit.setformatedit(const Value: msestring);
begin
 fformatedit := Value;
 formatchanged;
end;

function tcustomdatetimeedit.getgridvalue(const index: integer): tdatetime;
begin
 internalgetgridvalue(index,result);
end;

procedure tcustomdatetimeedit.setgridvalue(const index: integer; const Value: tdatetime);
begin
 internalsetgridvalue(index,value);
end;

function tcustomdatetimeedit.getgridvalues: datetimearty;
begin
 result:= datetimearty(trealdatalist(fgridintf.getcol.datalist).asarray);
end;

procedure tcustomdatetimeedit.setgridvalues(const Value: datetimearty);
begin
 trealdatalist(fgridintf.getcol.datalist).asarray:= realarty(value);
end;

function tcustomdatetimeedit.checkkind(const avalue: tdatetime): tdatetime;
begin
 if isemptydatetime(avalue) then begin
  result:= avalue;
 end
 else begin
  case fkind of
   dtk_date: result:= trunc(avalue);
   dtk_time: result:= frac(avalue);
   else result:= avalue;
  end;
 end;
end;

function tcustomdatetimeedit.gettextvalue(var accept: boolean; 
                                             const quiet: boolean): tdatetime;
var
 mstr1: msestring;
begin
 try
  mstr1:= feditor.text;
  checktext(mstr1,accept);
  if not accept then begin
   result:= emptydatetime; //compiler warning
   exit;
  end;
  case fkind of
   dtk_time: begin
    result:= stringtotime(mstr1,fformatedit);
   end;
   dtk_date: begin
    result:= stringtodate(mstr1,fformatedit);
   end;
   else begin
    result:= stringtodatetime(mstr1,fformatedit);
   end;
  end;
 except
  formaterror(quiet);
  accept:= false
 end;
end;

procedure tcustomdatetimeedit.texttovalue(var accept: boolean; 
                                                 const quiet: boolean);
var
 dat1: tdatetime;
 mstr1: msestring;
begin
 dat1:= gettextvalue(accept,quiet);
 if accept then begin
  if not ((des_isdb in fstate) and isemptydatetime(dat1)) then begin
   if fkind = dtk_time then begin
    if isemptydatetime(fmax) and not isemptydatetime(dat1) or
         not isemptydatetime(fmin) and (dat1 < frac(fmin)) or 
                    (dat1 > frac(fmax)) then begin
     rangeerror(fmin,fmax,quiet);
     accept:= false;
    end;
   end
   else begin
    if (cmprealty(fmin,dat1) > 0) or (cmprealty(fmax,dat1) < 0) then begin
     rangeerror(fmin,fmax,quiet);
     accept:= false;
    end;
   end;
  end;
  if accept then begin
   if not quiet and canevent(tmethod(fonsetvalue)) then begin
    fonsetvalue(self,dat1,accept);
   end;
   if accept then begin
    value:= dat1;
   end;
  end;
 end;
end;

procedure tcustomdatetimeedit.texttodata(const atext: msestring; var data);
var
 dat1: tdatetime;
begin
 try
  if fkind = dtk_time then begin
   dat1:= stringtotime(atext);
  end
  else begin
   dat1:= stringtodatetime(atext);
  end;
 except
  try
   dat1:= strtorealty(atext);
  except
   dat1:= emptyreal;
  end;
 end;
 if cmprealty(fmin,dat1) > 0 then begin
  dat1:= fmin;
 end;
 if cmprealty(fmax,dat1) < 0 then begin
  dat1:= fmax;
 end;
 tdatetime(data):= dat1;
end;

function tcustomdatetimeedit.internaldatatotext(const data): msestring;
var
 dat1: tdatetime;
 mstr1: msestring;
begin
 if @data = nil then begin
  dat1:= fvalue;
 end
 else begin
  dat1:= tdatetime(data);
 end;
 if (@data = nil) and focused then begin
  mstr1:= fformatedit;
 end
 else begin
  mstr1:= fformatdisp;
 end;
 case fkind of 
  dtk_time: begin
   result:= mseformatstr.timetostring(dat1,mstr1);
  end;
  dtk_date: begin
   result:= mseformatstr.datetostring(dat1,mstr1);
  end;
  else begin
   result:= mseformatstr.datetimetostring(dat1,mstr1);
  end;
 end;
end;

function tcustomdatetimeedit.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= tgridrealdatalist.create(sender);
end;

function tcustomdatetimeedit.getdatatype: listdatatypety;
begin
 result:= dl_datetime;
end;

procedure tcustomdatetimeedit.valuetogrid(arow: integer);
begin
 fgridintf.setdata(arow,fvalue);
end;

procedure tcustomdatetimeedit.gridtovalue(arow: integer);
begin
 fgridintf.getdata(arow,fvalue);
 inherited;
end;

procedure tcustomdatetimeedit.readstatvalue(const reader: tstatreader);
begin
// if fgridintf <> nil then begin
//  with fgridintf.getcol do begin
//   with trealdatalist(datalist) do begin
//    min:= fmin;
//    max:= fmax;
//   end;
//   dostatread(reader);
//  end;
// end
// else begin
  value:= reader.readreal(valuevarname,value,fmin,fmax)
// end;
end;

procedure tcustomdatetimeedit.writestatvalue(const writer: tstatwriter);
begin
 writer.writereal(valuevarname,value);
end;

procedure tcustomdatetimeedit.fillcol(const value: tdatetime);
begin
 internalfillcol(value);
end;

procedure tcustomdatetimeedit.assigncol(const value: trealdatalist);
begin
 internalassigncol(value);
end;

procedure tcustomdatetimeedit.setkind(const avalue: datetimekindty);
begin
 if fkind <> avalue then begin
  fkind:= avalue;
  formatchanged;
 end;
end;

procedure tcustomdatetimeedit.readvalue(reader: treader);
begin
 value:= readrealty(reader);
end;

procedure tcustomdatetimeedit.readvaluedefault(reader: treader);
begin
 valuedefault:= readrealty(reader);
end;

procedure tcustomdatetimeedit.readmin(reader: treader);
begin
 fmin:= readrealty(reader);
end;

procedure tcustomdatetimeedit.readmax(reader: treader);
begin
 fmax:= readrealty(reader);
end;

procedure tcustomdatetimeedit.defineproperties(filer: tfiler);
begin
 inherited;
 
 filer.DefineProperty('val',
             {$ifdef FPC}@{$endif}readvalue,nil,false);
 filer.DefineProperty('mi',{$ifdef FPC}@{$endif}readmin,nil,false);
 filer.DefineProperty('ma',{$ifdef FPC}@{$endif}readmax,nil,false);
 filer.DefineProperty('def',
             {$ifdef FPC}@{$endif}readvaluedefault,nil,false);
end;

function tcustomdatetimeedit.isempty(const atext: msestring): boolean;
begin
 result:= (atext <> ' ') and inherited isempty(atext);
end;

function tcustomdatetimeedit.isnull: boolean;
begin
 result:= isemptydatetime(value);
end;

function tcustomdatetimeedit.griddata: trealdatalist;
begin
 result:= trealdatalist(fdatalist);
end;

{$ifdef mse_with_ifi}
function tcustomdatetimeedit.getifilink: tifidatetimelinkcomp;
begin
 result:= tifidatetimelinkcomp(fifilink);
end;

procedure tcustomdatetimeedit.setifilink(const avalue: tifidatetimelinkcomp);
begin
 inherited setifilink(avalue);
end;
{$endif}

function tcustomdatetimeedit.getdefaultvalue: pointer;
begin
 result:= @fvaluedefault;
end;

end.
