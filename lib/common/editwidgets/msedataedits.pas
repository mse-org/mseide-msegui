{ MSEgui Copyright (c) 1999-2007 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msedataedits;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 Classes,msegui,mseinplaceedit,mseeditglob,msegraphics,mseedit,
 msetypes,msestrings,msedatalist,
 mseguiglob,mseevent,msegraphutils,msedrawtext,msestat,msestatfile,mseclasses,
 msearrayprops,msegrids,msewidgetgrid,msedropdownlist,msedrag,mseforms,
 mseformatstr,typinfo,
 msescrollbar,msewidgets,msepopupcalendar,msekeyboard;

type
 tdataedit = class;
 
 checkvalueeventty = procedure(const sender: tdataedit; const quiet: boolean;
                           var accept: boolean) of object;
 
 tdataedit = class(tcustomedit,igridwidget,istatfile,idragcontroller)
  private
   fondataentered: notifyeventty;
   foncheckvalue: checkvalueeventty;
   fedited: boolean;
   fnullchecking: integer;
   fvaluechecking: integer;
   fstatfile: tstatfile;
   fstatvarname: msestring;
   procedure setstatfile(const Value: tstatfile);
  protected
   fgridintf: iwidgetgrid;
   function getgridintf: iwidgetgrid;
   procedure checkgrid;
   procedure internalgetgridvalue(const index: integer; out value);
   procedure internalsetgridvalue(const index: integer; const Value);
   procedure internalfillcol(const value);
   procedure internalassigncol(const value);
   procedure editnotification(var info: editnotificationinfoty); override;
   procedure valuechanged; virtual;
   procedure modified; virtual; //for dbedits
   procedure texttovalue(var accept: boolean; const quiet: boolean); virtual; abstract;
   procedure texttodata(const atext: msestring; var data); virtual;
             //used for clipboard paste in widgetgrid
   function datatotext(const data): msestring; virtual; abstract;
   procedure valuetotext;
   procedure dodefocus; override;
   procedure dofocus; override;
   procedure formatchanged;
   procedure loaded; override;
   procedure fontchanged; override;
   procedure dofontheightdelta(var delta: integer); override;
   function geteditfont: tfont; override;

   function setdropdowntext(const avalue: msestring; const docheckvalue: boolean;
                const canceled: boolean; const akey: keyty): boolean;
                
   //igridwidget
   procedure setfirstclick;
   function createdatalist(const sender: twidgetcol): tdatalist; virtual; abstract;
   function getdatatyp: datatypty; virtual; abstract;
   function getdefaultvalue: pointer; virtual;
   function getrowdatapo(const info: cellinfoty): pointer; virtual;
   procedure setgridintf(const intf: iwidgetgrid); virtual;
   function getcellframe: framety; virtual;
   procedure drawcell(const canvas: tcanvas); virtual;
   procedure valuetogrid(const row: integer); virtual; abstract;
   procedure gridtovalue(const row: integer); virtual;
   procedure docellevent(const ownedcol: boolean; var info: celleventinfoty); virtual;
   procedure sortfunc(const l,r; var result: integer); virtual;
   procedure gridvaluechanged(const index: integer); virtual;
   procedure updatecoloptions(var aoptions: coloptionsty);
   procedure setoptionsedit(const avalue: optionseditty); override;
   procedure statdataread; virtual;
   procedure griddatasourcechanged; virtual;

   procedure formaterror(const quiet: boolean);
   procedure rangeerror(const min,max; const quiet: boolean);
   procedure notnullerror(const quiet: boolean);
   
   procedure dopaint(const canvas: tcanvas); override;
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

   function isempty (const atext: msestring): boolean; virtual;
   procedure setnullvalue; virtual; //for dbedits
   function nullcheckneeded(const newfocus: twidget): boolean; virtual;
  public
   procedure initgridwidget; virtual;
   procedure synctofontheight; override;
   function actualcolor: colorty; override;
   function widgetcol: twidgetcol;
   function gridrow: integer;
   function griddata: tdatalist;
   function textclipped(const arow: integer; out acellrect: rectty): boolean; overload;
   function textclipped(const arow: integer): boolean; overload;

   function checkvalue(const quiet: boolean = false): boolean; virtual;
   function canclose(const newfocus: twidget): boolean; override;
   function edited: boolean;
  published
   property statfile: tstatfile read fstatfile write setstatfile;
   property statvarname: msestring read getstatvarname write fstatvarname;
   property optionsedit;
   property font;
   property textflags;
   property textflagsactive;
   property caretwidth;
   property onchange;
   property ontextedited;
   property oncheckvalue: checkvalueeventty read foncheckvalue write foncheckvalue;
   property ondataentered: notifyeventty read fondataentered write fondataentered;
   property onkeydown;
 end;

 tcustomstringedit = class(tdataedit)
  private
   fonsetvalue: setstringeventty;
   procedure setvalue(const Value: msestring);
   function getgridvalue(const index: integer): msestring;
   procedure setgridvalue(const index: integer; const Value: msestring);
   function getgridvalues: msestringarty;
   procedure setgridvalues(const Value: msestringarty);
  protected
   fvalue: msestring;
   function getvaluetext: msestring; virtual;
   procedure updatedisptext(var avalue: msestring); virtual;

   procedure dosetvalue(var avalue: msestring; var accept: boolean); virtual;
   procedure texttovalue(var accept: boolean; const quiet: boolean); override;
   function datatotext(const data): msestring; override;
   procedure texttodata(const atext: msestring; var data); override;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   function getdatatyp: datatypty; override;
   procedure valuetogrid(const arow: integer); override;
   procedure gridtovalue(const arow: integer); override;
   procedure readstatvalue(const reader: tstatreader); override;
   procedure writestatvalue(const writer: tstatwriter); override;
   procedure sortfunc(const l,r; var result: integer); override;
   function isempty (const atext: msestring): boolean; override;

  public
   procedure dragevent(var info: draginfoty); override;
   procedure fillcol(const value: msestring);
   procedure assigncol(const value: tmsestringdatalist);
   property onsetvalue: setstringeventty read fonsetvalue write fonsetvalue;
   property value: msestring read fvalue write setvalue;
   property gridvalue[const index: integer]: msestring
        read getgridvalue write setgridvalue; default;
   property gridvalues: msestringarty read getgridvalues write setgridvalues;
 end;

 tstringedit = class(tcustomstringedit)
  published
   property passwordchar;
   property maxlength;
   property value;
   property onsetvalue;
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
   property onsetvalue;
   property frame;
   property textflags;
   property textflagsactive;
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
   function datatotext(const data): msestring; override;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   function getdatatyp: datatypty; override;
   procedure valuetogrid(const arow: integer); override;
   procedure gridtovalue(const arow: integer); override;
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

 tcustomdropdownedit = class(tcustomstringedit,idropdown)
  private
   fonbeforedropdown: notifyeventty;
   fonafterclosedropdown: notifyeventty;
   function getframe: tdropdownbuttonframe;
   procedure setframe(const avalue: tdropdownbuttonframe);
  protected
   fdropdown: tcustomdropdowncontroller;
   procedure internalcreateframe; override;
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure mouseevent(var info: mouseeventinfoty); override;
   procedure editnotification(var info: editnotificationinfoty); override;
   function createdropdowncontroller: tcustomdropdowncontroller; virtual;
   procedure texttovalue(var accept: boolean; const quiet: boolean); override;
   function getcellframe: framety; override;
   procedure dohide; override;
   procedure updatereadonlystate; override;
   //idropdown
   procedure buttonaction(var action: buttonactionty; const buttonindex: integer); virtual;
   procedure dobeforedropdown; virtual;
   procedure doafterclosedropdown; virtual;
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
   function createdropdownwidget(const atext: msestring): twidget; virtual; abstract;
   function getdropdowntext(const awidget: twidget): msestring; virtual; abstract;
  public
   property dropdown: tdropdownwidgetcontroller read getdropdown write setdropdown;
 end;

 tdropdownwidgetedit = class(tcustomdropdownwidgetedit)
  published
   property value;
   property dropdown;
   property onsetvalue;
   property onbeforedropdown;
   property onafterclosedropdown;
 end;

 tcustomdropdownlistedit = class(tcustomdropdownedit,idropdownlist)
  private
   procedure setdropdown(const avalue: tdropdownlistcontroller);
   function getdropdown: tdropdownlistcontroller;
  protected

   //idropdownlist
   function getdropdownitems: tdropdowncols; virtual;
   function createdropdowncontroller: tcustomdropdowncontroller; override;
   procedure internalsort(const acol: integer; const sortlist: tintegerdatalist); virtual;
  public
   procedure sort(const acol: integer = 0);
   property dropdown: tdropdownlistcontroller read getdropdown write setdropdown;
 end;

 tdropdownlistedit = class(tcustomdropdownlistedit)
  published
   property maxlength;
   property value;
   property onsetvalue;
   property dropdown;
   property onbeforedropdown;
   property onafterclosedropdown;
 end;

const
 defaulthistorymaxcount = 10;
 defaulthistoryeditoptions = defaultdropdownoptionsedit + [deo_autosavehistory];

type

 thistorycontroller = class(tcustomdropdownlistcontroller)
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
   procedure setvalue(const Value: integer);
   procedure setbase(const Value: numbasety);
   procedure setbitcount(const Value: integer);
   function getgridvalue(const index: integer): integer;
   procedure setgridvalue(const index, Value: integer);
   function getgridvalues: integerarty;
   procedure setgridvalues(const Value: integerarty);
  protected
   fisnull: boolean; //used in tdbintegeredit
   procedure texttovalue(var accept: boolean; const quiet: boolean); override;
   function datatotext(const data): msestring; override;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   function getdatatyp: datatypty; override;
   procedure valuetogrid(const arow: integer); override;
   procedure gridtovalue(const arow: integer); override;
   procedure readstatvalue(const reader: tstatreader); override;
   procedure writestatvalue(const writer: tstatwriter); override;
   procedure setnullvalue; override;
  public
   constructor create(aowner: tcomponent); override;
   procedure fillcol(const value: integer);
   procedure assigncol(const value: tintegerdatalist);
   property onsetvalue: setintegereventty read fonsetvalue write fonsetvalue;
   property value: integer read fvalue write setvalue default 0;
   property base: numbasety read fbase write setbase default nb_dec;
   property bitcount: integer read fbitcount write setbitcount default 32;
   property min: integer read fmin write fmin default 0;
   property max: integer read fmax write fmax default maxint;

   property gridvalue[const index: integer]: integer
        read getgridvalue write setgridvalue; default;
   property gridvalues: integerarty read getgridvalues write setgridvalues;
 end;

 tintegeredit = class(tcustomintegeredit)
  published
   property onsetvalue;
   property value;
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
   fvaluedefault: msestring;
   foninit: keystringediteventty;
  protected
   fvalue1: msestring;
   procedure setvalue(const avalue: msestring);
   function createdropdowncontroller: tcustomdropdowncontroller; override;
   procedure texttovalue(var accept: boolean; const quiet: boolean); override;
   function datatotext(const data): msestring; override;
   procedure texttodata(const atext: msestring; var data); override;
   function getdefaultvalue: pointer; override;
   procedure valuetogrid(const arow: integer); override;
   procedure gridtovalue(const arow: integer); override;

   procedure readstatvalue(const reader: tstatreader); override;
   procedure writestatvalue(const writer: tstatwriter); override;
   procedure loaded; override;
  public
   property value: msestring read fvalue1 write setvalue;
   property valuedefault: msestring read fvaluedefault write fvaluedefault;
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
   function getgridvalue(const index: integer): integer;
   procedure setgridvalue(const index, aValue: integer);
   function getgridvalues: integerarty;
   procedure setgridvalues(const avalue: integerarty);
   function getindex(const avalue: integer): integer;
   procedure setbase(const avalue: numbasety);
   procedure setbitcount(const avalue: integer);
  protected
   fonsetvalue1: setintegereventty;
   fvalue1: integer;
   fvaluedefault: integer;
   fisdb: boolean;
   procedure setvalue(const avalue: integer);
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   function getdatatyp: datatypty; override;
   function getdefaultvalue: pointer; override;
   procedure texttovalue(var accept: boolean; const quiet: boolean); override;
   procedure texttodata(const atext: msestring; var data); override;
   function datatotext(const data): msestring; override;
   procedure valuetogrid(const arow: integer); override;
   procedure gridtovalue(const arow: integer); override;
   procedure readstatvalue(const reader: tstatreader); override;
   procedure writestatvalue(const writer: tstatwriter); override;
   function createdropdowncontroller: tcustomdropdowncontroller; override;
   procedure internalsort(const acol: integer; const sortlist: tintegerdatalist); override;
  public
   enums: integerarty; //nil -> enum = item rowindex
   constructor create(aowner: tcomponent); override;
   procedure clear;
   function enumname(const avalue: integer): msestring;
   function addrow(const aitems: array of msestring; const enum: integer = -1): integer; //returns itemindex
                   //enum = -1 -> no enum set
   procedure fillcol(const avalue: integer);
   procedure assigncol(const avalue: tintegerdatalist);
   property value: integer read fvalue1 write setvalue default -1;
   property valuedefault: integer read fvaluedefault write fvaluedefault default -1;
   property base: numbasety read fbase write setbase default nb_dec;
   property bitcount: integer read fbitcount write setbitcount default 32;
   property min: integer read fmin write fmin default -1;
   property max: integer read fmax write fmax default maxint;
   property gridvalue[const index: integer]: integer
        read getgridvalue write setgridvalue; default;
   property gridvalues: integerarty read getgridvalues write setgridvalues;
   property onsetvalue: setintegereventty read fonsetvalue1 write fonsetvalue1;
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
   property oninit;
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
 selectoreventty =
  procedure (const sender: tselector) of object;

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
   fvalue: realty;
   fformatdisp: string;
   fformatedit: string;
   fscale: real;
   fmin: realty;
   fmax: realty;
   procedure setvalue(const Value: realty);
   procedure setformatdisp(const Value: string);
   procedure setformatedit(const Value: string);
   procedure readvalue(reader: treader);
   procedure writevalue(writer: twriter);
   procedure readmin(reader: treader);
   procedure writemin(writer: twriter);
   procedure readmax(reader: treader);
   procedure writemax(writer: twriter);
   function getgridvalue(const index: integer): realty;
   procedure setgridvalue(const index: integer; const Value: realty);
   function getgridvalues: realarty;
   procedure setgridvalues(const Value: realarty);
   procedure setscale(const Value: real);
   function getasinteger: integer;
   procedure setasinteger(const avalue: integer);
  protected
   fisdb: boolean;
   procedure texttovalue(var accept: boolean; const quiet: boolean); override;
   function datatotext(const data): msestring; override;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   function getdatatyp: datatypty; override;
   procedure valuetogrid(const arow: integer); override;
   procedure gridtovalue(const arow: integer); override;
   procedure defineproperties(filer: tfiler); override;
   procedure readstatvalue(const reader: tstatreader); override;
   procedure writestatvalue(const writer: tstatwriter); override;
  public
   constructor create(aowner: tcomponent); override;
   procedure fillcol(const value: realty);
   procedure assigncol(const value: trealdatalist);
   function isnull: boolean;
   property asinteger: integer read getasinteger write setasinteger;
   property onsetvalue: setrealeventty read fonsetvalue write fonsetvalue;
   property value: realty read fvalue write setvalue stored false;
   property formatedit: string read fformatedit write setformatedit;
   property formatdisp: string read fformatdisp write setformatdisp;
   property scale: real read fscale write setscale;
   property min: realty read fmin write fmin stored false;
   property max: realty read fmax write fmax stored false;
   property gridvalue[const index: integer]: realty
        read getgridvalue write setgridvalue; default;
   property gridvalues: realarty read getgridvalues write setgridvalues;
 end;

 trealedit = class(tcustomrealedit)
  published
   property onsetvalue;
   property value stored false;
   property formatedit;
   property formatdisp;
   property scale;
   property min stored false;
   property max stored false;
 end;

 tcustomdatetimeedit = class(tnumedit)
  private
   fonsetvalue: setdatetimeeventty;
   fvalue: tdatetime;
   fformatdisp: string;
   fformatedit: string;
   fmin: tdatetime;
   fmax: tdatetime;
   fkind: datetimekindty;
   procedure setvalue(const Value: tdatetime);
   procedure setformatdisp(const Value: string);
   procedure setformatedit(const Value: string);
   function getgridvalue(const index: integer): tdatetime;
   procedure setgridvalue(const index: integer; const Value: tdatetime);
   function getgridvalues: datetimearty;
   procedure setgridvalues(const Value: datetimearty);
   function checkkind(const avalue: tdatetime): tdatetime;
   procedure setkind(const avalue: datetimekindty);
   procedure readvalue(reader: treader);
   procedure writevalue(writer: twriter);
   procedure readmin(reader: treader);
   procedure writemin(writer: twriter);
   procedure readmax(reader: treader);
   procedure writemax(writer: twriter);
  protected
   fisdb: boolean;
   procedure texttovalue(var accept: boolean; const quiet: boolean); override;
   function datatotext(const data): msestring; override;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   function getdatatyp: datatypty; override;
   procedure valuetogrid(const arow: integer); override;
   procedure gridtovalue(const arow: integer); override;
   procedure defineproperties(filer: tfiler); override;
   procedure readstatvalue(const reader: tstatreader); override;
   procedure writestatvalue(const writer: tstatwriter); override;
   function isempty (const atext: msestring): boolean; override;
  public
   constructor create(aowner: tcomponent); override;
   procedure fillcol(const value: tdatetime);
   procedure assigncol(const value: trealdatalist);
   function isnull: boolean;
   property onsetvalue: setdatetimeeventty read fonsetvalue write fonsetvalue;
   property value: tdatetime read fvalue write setvalue stored false;
   property formatedit: string read fformatedit write setformatedit;
   property formatdisp: string read fformatdisp write setformatdisp;
   property min: tdatetime read fmin write fmin;
   property max: tdatetime read fmax write fmax;
   property kind: datetimekindty read fkind write setkind default dtk_date;
   property gridvalue[const index: integer]: tdatetime 
                 read getgridvalue write setgridvalue; default;
   property gridvalues: datetimearty read getgridvalues write setgridvalues;
 end;
 
 tdatetimeedit = class(tcustomdatetimeedit)
  published
   property onsetvalue;
   property value stored false;
   property formatedit;
   property formatdisp;
   property min stored false;
   property max stored false;
   property kind;
 end;

 tcustomcalendardatetimeedit = class(tcustomdatetimeedit,idropdowncalendar)
  private
   fdropdown: tcalendarcontroller;
   procedure setframe(const avalue: tdropdownbuttonframe);
   function getframe: tdropdownbuttonframe;
  protected
   procedure internalcreateframe; override;
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure mouseevent(var info: mouseeventinfoty); override;
   procedure editnotification(var info: editnotificationinfoty); override;
   procedure updatereadonlystate; override;
   //idropdownwidget
   procedure buttonaction(var action: buttonactionty; const buttonindex: integer);
   procedure dobeforedropdown;
   procedure doafterclosedropdown;
   function createdropdownwidget(const atext: msestring): twidget;
   function getdropdowntext(const awidget: twidget): msestring;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property dropdown: tcalendarcontroller read fdropdown write fdropdown;
  published
   property frame: tdropdownbuttonframe read getframe write setframe;
 end;
  
 tcalendardatetimeedit = class(tcustomcalendardatetimeedit)
  published
   property onsetvalue;
   property value stored false;
   property formatedit;
   property formatdisp;
   property min stored false;
   property max stored false;
   property kind;
   property dropdown;
 end;
 
implementation
uses
 sysutils,msereal,msebits,msepointer,msestreaming,msestockobjects;

const
 valuevarname = 'value';
type
 tdatalist1 = class(tdatalist);
 twidget1 = class(twidget);
 tcustombuttonframe1 = class(tcustombuttonframe);
 twidgetcol1 = class(twidgetcol);
 tdropdowncols1 = class(tdropdowncols);
 tcustomframe1 = class(tcustomframe);
 tcustomgrid1 = class(tcustomgrid);

{ tdataedit }

function tdataedit.checkvalue(const quiet: boolean = false): boolean;
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
     fedited:= false;
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

function tdataedit.canclose(const newfocus: twidget): boolean;
var
 widget1: twidget;
begin
 result:= true;
 if not (csdesigning in componentstate) and 
                        (oe_closequery in foptionsedit) and isenabled then begin
  if (oe_notnull in foptionsedit) and (fnullchecking = 0) and 
                 nullcheckneeded(newfocus) and isempty(text) then begin
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
        if {grid.canfocus and} not focused then begin
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
//     show;
//     setfocus;
    finally
     dec(fnullchecking);
    end;
   end;
  end
  else begin
   if focused and fedited then begin
    result:= checkvalue;
   end;
  end;
 end;
 if result then begin
  result:= inherited canclose(newfocus);
 end;
end;

procedure tdataedit.valuetotext;
begin
 {$ifdef FPC} {$checkpointer off} {$endif}
 feditor.text:= datatotext(nil^);
 {$ifdef FPC} {$checkpointer default} {$endif}
 feditor.initfocus;
 {
 feditor.clearundo;
 if active and (oe_autoselect in foptionsedit) then begin
  feditor.selectall;
 end
 else begin
  feditor.moveindex(bigint,false,false);
 end;
 }
 fedited:= false;
end;

procedure tdataedit.gridtovalue(const row: integer);
begin
 valuetotext;
end;

procedure tdataedit.dofocus;
begin
 valuetotext;
 inherited;
end;

procedure tdataedit.synctofontheight;
begin 
 inherited;
 if fgridintf <> nil then begin
  fgridintf.getcol.grid.datarowheight:= bounds_cy;
 end;
end;

function tdataedit.actualcolor: colorty;
begin
 if (fgridintf <> nil) and (fcolor = cl_default) then begin
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

function tdataedit.edited: boolean;
begin
 result:= fedited;
end;

procedure tdataedit.dodefocus;
begin
 {$ifdef FPC} {$checkpointer off} {$endif}
 feditor.text:= datatotext(nil^);
 {$ifdef FPC} {$checkpointer default} {$endif}
 fedited:= false;
 inherited;
end;

procedure tdataedit.initgridwidget;
begin
 optionswidget:= optionswidget - [ow_autoscale];
 if fframe <> nil then begin
  fframe.initgridframe;
 end;
 synctofontheight;
end;

procedure tdataedit.editnotification(var info: editnotificationinfoty);

var
 rect1: rectty;
// ar4,ar5: msestringarty;

begin
 case info.action of
  ea_textentered: begin
   if fedited or (oe_forcereturncheckvalue in foptionsedit) then begin
    checkvalue;
    if oe_eatreturn in foptionsedit then begin
     info.action:= ea_none;
    end;
   end;
  end;
  ea_textedited: begin
   fedited:= true;
   modified;
   inherited;
  end;
  ea_undo: begin
   fedited:= false;
  end;
  ea_caretupdating: begin
   if (fgridintf <> nil) and focused then begin 
    fgridintf.showcaretrect(info.caretrect,fframe);
   end;
  end;
  ea_copyselection: begin
   if (fgridintf <> nil) and (feditor.sellength = 0) then begin
    if fgridintf.getcol.grid.copyselection then begin
     info.action:= ea_none;
    end;
   end;
  end;
  ea_pasteselection: begin
   if fgridintf <> nil then begin
    if fgridintf.getcol.grid.pasteselection then begin
     info.action:= ea_none;
    end;
   end;
  end;
 end;
end;

procedure tdataedit.formatchanged;
begin
 if not (csloading in componentstate) then begin
  if fgridintf <> nil then begin
   fgridintf.changed;
  end;
 {$ifdef FPC} {$checkpointer off} {$endif}
  feditor.text:= datatotext(nil^);
 {$ifdef FPC} {$checkpointer default} {$endif}
  invalidate;
 end;
end;

procedure tdataedit.formaterror(const quiet: boolean);
begin
 if not quiet then begin
  showmessage(''''+text+''' '+stockobjects.captions[sc_is_invalid]+'.',
        stockobjects.captions[sc_Format_error]);
 end;
end;

procedure tdataedit.notnullerror(const quiet: boolean);
begin
 if not quiet then begin
  showmessage(stockobjects.captions[sc_Value_is_required]+'.',
               stockobjects.captions[sc_Error]);
 end;
end;

procedure tdataedit.rangeerror(const min, max; const quiet: boolean);
begin
 if not quiet then begin
  showmessage(stockobjects.captions[sc_min]+': '+datatotext(min)+' '+
             stockobjects.captions[sc_Max]+': ' +
            datatotext(max) + '.',stockobjects.captions[sc_Range_error]);
 end;
end;

procedure tdataedit.loaded;
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

procedure tdataedit.fontchanged;
begin
 inherited;
 if fgridintf <> nil then begin
  fgridintf.getcol.changed;
 end;
end;

procedure tdataedit.dofontheightdelta(var delta: integer);
begin
 inherited;
 gridwidgetfontheightdelta(self,fgridintf,delta);
end;

function tdataedit.geteditfont: tfont;
begin
 if (fgridintf <> nil) and (ffont = nil) then begin
  with fgridintf.getcol do begin
   result:= rowfont(grid.row);
  end;
 end
 else begin
  result:= inherited geteditfont;
 end;
end;

function tdataedit.setdropdowntext(const avalue: msestring;
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

procedure tdataedit.setgridintf(const intf: iwidgetgrid);
begin
 fgridintf:= intf;
 if fgridintf <> nil then begin
  fgridintf.updateeditoptions(foptionsedit);
  if (ow_autoscale in foptionswidget) and
              (foptionswidget * [ow_fontglyphheight,ow_fontlineheight] <> []) then begin
   fgridintf.getcol.grid.datarowheight:= bounds_cy;
  end;
 end;
end;

function tdataedit.getcellframe: framety;
begin
 if fframe <> nil then begin
  result:= getinnerstframe;
 end
 else begin
  result:= minimalframe;
 end;
end;

procedure tdataedit.updatecoloptions(var aoptions: coloptionsty);
begin
 coloptionstoeditoptions(aoptions,foptionsedit);
end;

procedure tdataedit.setoptionsedit(const avalue: optionseditty);
begin
 if foptionsedit <> avalue then begin
  inherited;
  if fgridintf <> nil then begin
   fgridintf.updateeditoptions(foptionsedit);
  end;
 end;
end;

procedure tdataedit.statdataread;
begin
 //dummy
end;

procedure tdataedit.griddatasourcechanged;
begin
 //dummy
end;
{
procedure tdataedit.clientmouseevent(var info: mouseeventinfoty);
begin
 if fgridintf <> nil then begin
  fgridintf.childmouseevent(self,info);
 end;
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;
}
procedure tdataedit.modified;
begin
 //dummy
end;

procedure tdataedit.valuechanged;
begin
 if not (csloading in componentstate) then begin
  if (fgridintf <> nil) and not (csdesigning in componentstate) then begin
   valuetogrid(fgridintf.getrow);
  end;
  {$ifdef FPC} {$checkpointer off} {$endif}
  feditor.text:= datatotext(nil^);
  {$ifdef FPC} {$checkpointer default} {$endif}
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

procedure tdataedit.texttodata(const atext: msestring; var data);
begin
 //dummy
end;

procedure tdataedit.setstatfile(const Value: tstatfile);
begin
 setstatfilevar(istatfile(self),value,fstatfile);
end;

procedure tdataedit.dostatwrite(const writer: tstatwriter);
begin
 if fgridintf = nil then begin
  if oe_savevalue in foptionsedit then begin
   writestatvalue(writer);
  end;
 end;
 if oe_savestate in foptionsedit then begin
  writestatstate(writer);
 end;
 if oe_saveoptions in foptionsedit then begin
  writestatoptions(writer);
 end;
end;
{
function tdataedit.getobjectlink: iobjectlink;
begin
 result:= istatfile(self);
end;
}
procedure tdataedit.dostatread(const reader: tstatreader);
begin
 if oe_savevalue in foptionsedit then begin
  readstatvalue(reader);
 end;
 if oe_savestate in foptionsedit then begin
  readstatstate(reader);
 end;
 if oe_saveoptions in foptionsedit then begin
  readstatoptions(reader);
 end;
end;

procedure tdataedit.statreading;
begin
 //dummy
end;

procedure tdataedit.statread;
begin
 if oe_checkvaluepaststatread in foptionsedit then begin
  checkvalue;
 end;
end;

function tdataedit.getstatvarname: msestring;
begin
 result:= fstatvarname;
end;

procedure tdataedit.readstatoptions(const reader: tstatreader);
begin
 //dummy
end;

procedure tdataedit.readstatstate(const reader: tstatreader);
begin
 //dummy
end;

procedure tdataedit.readstatvalue(const reader: tstatreader);
begin
 //dummy
end;

procedure tdataedit.writestatoptions(const writer: tstatwriter);
begin
 //dummy
end;

procedure tdataedit.writestatstate(const writer: tstatwriter);
begin
 //dummy
end;

procedure tdataedit.writestatvalue(const writer: tstatwriter);
begin
 //dummy
end;

procedure tdataedit.setnullvalue; //for dbedits
var
 bo1: boolean;
begin
 text:= '';
 bo1:= true;
 texttovalue(bo1,true); //sevalue call
end;

procedure tdataedit.setfirstclick;
begin
 feditor.setfirstclick;
end;

function tdataedit.getdefaultvalue: pointer;
begin
 result:= nil;
end;

function tdataedit.getrowdatapo(const info: cellinfoty): pointer;
begin
 result:= nil;
end;

procedure tdataedit.drawcell(const canvas: tcanvas);
begin
 with cellinfoty(canvas.drawinfopo^) do begin
  if datapo <> nil then begin
   drawtext(canvas,datatotext(datapo^),innerrect,feditor.textflags);
  end;
 end;
end;

procedure tdataedit.dopaint(const canvas: tcanvas);
begin
 inherited;
 if (fgridintf <> nil) and not (csdesigning in componentstate) then begin
  fgridintf.widgetpainted(canvas);
 end;
end;

function tdataedit.needsfocuspaint: boolean;
begin
 result:= (fgridintf = nil) and inherited needsfocuspaint;
end;

function tdataedit.getgridintf: iwidgetgrid;
begin
 result:= fgridintf;
end;

procedure tdataedit.checkgrid;
begin
 if fgridintf = nil then begin
  raise exception.Create('No grid.');
 end;
 if fgridintf.getcol = nil then begin
  raise exception.Create('No datalist.');
 end;
end;

procedure tdataedit.internalgetgridvalue(const index: integer; out value);
begin
 checkgrid;
 fgridintf.getdata(index,value);
end;

procedure tdataedit.internalsetgridvalue(const index: integer;
  const Value);
begin
 checkgrid;
 fgridintf.setdata(index,value);
end;

procedure tdataedit.internalfillcol(const value);
begin
 checkgrid;
 with tdatalist1(fgridintf.getcol.datalist) do begin
  tdatalist1(fgridintf.getcol.datalist).internalfill(count,value);
 end;
end;

procedure tdataedit.internalassigncol(const value);
begin
 checkgrid;
 with fgridintf.getcol do begin
  datalist.Assign(tdatalist(value));
 end;
end;

function tdataedit.widgetcol: twidgetcol;
begin
 if fgridintf = nil then begin
  result:= nil;
 end
 else begin
  result:= fgridintf.getcol;
 end;
end;

function tdataedit.gridrow: integer;
begin
 if fgridintf = nil then begin
  result:= -1;
 end
 else begin
  result:= fgridintf.getcol.grid.row;
 end;
end;

procedure tdataedit.sortfunc(const l, r; var result: integer);
begin
 tdatalist1(twidgetcol1(fgridintf.getcol).fdata).compare(l,r,result);
end;

function tdataedit.griddata: tdatalist;
begin
 checkgrid;
 result:= fgridintf.getcol.datalist;
end;

function tdataedit.textclipped(const arow: integer; out acellrect: rectty): boolean;
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
   translateclientpoint1(acellrect.pos,grid1,self);
  end
  else begin
   acellrect:= nullrect;
  end;
 end;
end;

function tdataedit.textclipped(const arow: integer): boolean;
var
 rect1: rectty;
begin
 result:= textclipped(arow,rect1);
end;

procedure tdataedit.docellevent(const ownedcol: boolean; var info: celleventinfoty);

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

procedure tdataedit.gridvaluechanged(const index: integer);
begin
 //dummy
end;

function tdataedit.isempty(const atext: msestring): boolean;
begin
 result:= trim(atext) = '';
end;

function tdataedit.nullcheckneeded(const newfocus: twidget): boolean;
begin
 if newfocus = self then begin
  result:= false;
 end
 else begin
  if fgridintf = nil then begin
   result:= newfocus = nil;
   {
   if fparentwidget = nil then begin
    result:= not checkdescendent(newfocus);
   end
   else begin
    result:= not fparentwidget.checkdescendent(newfocus);
   end;
   }
  end
  else begin
   result:= (edited and (oe_autopost in foptionsedit)){ and 
                          not (fgridintf.nonullcheck)} or 
              fgridintf.nullcheckneeded(newfocus);
  end;
 end;
end;

{ tcustomstringedit }

function tcustomstringedit.datatotext(const data): msestring;
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

function tcustomstringedit.getdatatyp: datatypty;
begin
 result:= dl_msestring;
end;

procedure tcustomstringedit.setvalue(const Value: msestring);
begin
 fvalue := Value;
 valuechanged;
end;

function tcustomstringedit.getvaluetext: msestring;
begin
 result:= feditor.text;
end;

procedure tcustomstringedit.updatedisptext(var avalue: msestring);
begin
 //dummy
end;

procedure tcustomstringedit.dosetvalue(var avalue: msestring; var accept: boolean);
begin
 if canevent(tmethod(fonsetvalue)) then begin
  fonsetvalue(self,avalue,accept);
 end;
end;

procedure tcustomstringedit.texttovalue(var accept: boolean; const quiet: boolean);
var
 str1: msestring;
begin
 str1:= getvaluetext;
 if oe_trimleft in foptionsedit then begin
  str1:= trimleft(str1);
 end;
 if oe_trimright in foptionsedit then begin
  str1:= trimright(str1);
 end;
 if oe_uppercase in foptionsedit then begin
  str1:= mseuppercase(str1);
 end
 else begin
  if oe_lowercase in foptionsedit then begin
   str1:= mselowercase(str1);
  end;
 end;
 if not quiet then begin
  dosetvalue(str1,accept);
 end;
 if accept then begin
  value:= str1;
 end;
end;

procedure tcustomstringedit.valuetogrid(const arow: integer);
begin
 fgridintf.setdata(arow,fvalue);
end;

procedure tcustomstringedit.gridtovalue(const arow: integer);
begin
 fgridintf.getdata(arow,fvalue);
 inherited;
end;

procedure tcustomstringedit.readstatvalue(const reader: tstatreader);
var
 ar1: msestringarty;
begin
 if fgridintf = nil then begin
  ar1:= nil;
  ar1:= reader.readarray(valuevarname+'ar',ar1);
  if high(ar1) >= 0 then begin
   value:= concatstrings(ar1,lineend);
  end
  else begin
   value:= reader.readmsestring(valuevarname,value);
  end;
 end;
end;

procedure tcustomstringedit.writestatvalue(const writer: tstatwriter);
var
 ar1: msestringarty;
begin
 ar1:= breaklines(value);
 if high(ar1) > 0 then begin
  writer.writearray(valuevarname+'ar',ar1);
 end
 else begin
  writer.writemsestring(valuevarname,value);
 end;
end;

procedure tcustomstringedit.dragevent(var info: draginfoty);
begin
 with info do begin
  case eventkind of
   dek_check: begin
    inherited;
    accept:= accept or (dragobject^ is tstringdragobject);
   end;
   dek_drop: begin
    if dragobject^ is tstringdragobject then begin
     value:= tstringdragobject(dragobject^).data;
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
 tmsestringdatalist(fgridintf.getcol.datalist).assignarray(value);
end;

function tcustomstringedit.isempty(const atext: msestring): boolean;
begin
 result:= atext = '';
end;

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
 tscrolleditframe.create(iframe(self),iscrollbar(self));
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
  sbe_pageup: begin
   init;
   int1:=  pagesize;
  end;
  sbe_pagedown: begin
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
 if fcreated and not (csloading in componentstate) then begin
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
begin
 if not (es_processed in info.eventstate) then begin
  if info.shiftstate - [ss_shift] = [] then begin
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
//      if (info.key = key_wheelup) and not (ow_mousewheel in optionswidget) then begin
//       exclude(info.eventstate,es_processed);
//      end
//      else begin
       int1:= - self.font.lineheight;
//      end;
     end;
     key_down: begin
//      if (info.key = key_wheeldown) and not (ow_mousewheel in optionswidget) then begin
//       exclude(info.eventstate,es_processed);
//      end
//      else begin
       int1:= self.font.lineheight; 
//      end;
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
     moveindex(mousepostotextindex(makepoint(fxpos,int1)),
                      ss_shift in info.shiftstate);
     if ss_shift in info.shiftstate then begin
      invalidate;
     end;
     if fxpos < int2 then begin
      fxpos:= int2;
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
var
 rect1: rectty;
begin
 inherited;
 updatescrollbars;
end;

procedure tcustommemoedit.domousewheelevent(var info: mousewheeleventinfoty);
begin
 if fframe <> nil then begin
  frame.domousewheelevent(info);
 end;
 inherited;
end;

{ thexstringedit }

function thexstringedit.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= tgridansistringdatalist.create(sender);
end;

function thexstringedit.getdatatyp: datatypty;
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
 tansistringdatalist(fgridintf.getcol.datalist).assignarray(value);
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
 if canevent(tmethod(fonsetvalue)) then begin
  fonsetvalue(self,avalue,accept);
 end;
end;

procedure thexstringedit.texttovalue(var accept: boolean; const quiet: boolean);
var
 str1: ansistring;
begin
 try
  str1:= strtobytestr(printableascii(feditor.text))
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

function thexstringedit.datatotext(const data): msestring;
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

procedure thexstringedit.valuetogrid(const arow: integer);
begin
 fgridintf.setdata(arow,fvalue);
end;

procedure thexstringedit.gridtovalue(const arow: integer);
begin
 fgridintf.getdata(arow,fvalue);
 inherited;
end;

procedure thexstringedit.readstatvalue(const reader: tstatreader);
begin
 if fgridintf = nil then begin
  value:= reader.readstring(valuevarname,value);
 end;
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
end;

destructor tcustomdropdownedit.destroy;
begin
 inherited;
 fdropdown.Free;
end;

procedure tcustomdropdownedit.editnotification(var info: editnotificationinfoty);
begin
 if fdropdown <> nil then begin
  fdropdown.editnotification(info);
 end;
 inherited;
end;

procedure tcustomdropdownedit.dokeydown(var info: keyeventinfoty);
begin
 fdropdown.dokeydown(info);
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;

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

procedure tcustomdropdownedit.mouseevent(var info: mouseeventinfoty);
begin
 tcustombuttonframe(fframe).mouseevent(info);
 inherited;
end;

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

function tcustomdropdownedit.getcellframe: framety;
begin
 result:= subframe(getinnerstframe,tcustombuttonframe(fframe).buttonframe);
end;

function tcustomdropdownedit.getframe: tdropdownbuttonframe;
begin
 result:= tdropdownbuttonframe(inherited getframe);
end;

procedure tcustomdropdownedit.setframe(const avalue: tdropdownbuttonframe);
begin
 inherited setframe(avalue);
end;

procedure tcustomdropdownedit.internalcreateframe;
begin
 fdropdown.createframe;
end;

procedure tcustomdropdownedit.dohide;
begin
 fdropdown.canceldropdown;
 inherited;
end;

procedure tcustomdropdownedit.updatereadonlystate;
begin
 inherited;
 if fdropdown <> nil then begin
  fdropdown.updatereadonlystate;
 end;
end;


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

procedure tcustomdropdownlistedit.internalsort(const acol: integer; const sortlist: tintegerdatalist);
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

function tcustomintegeredit.getdatatyp: datatypty;
begin
 result:= dl_integer;
end;

procedure tcustomintegeredit.valuetogrid(const arow: integer);
begin
 fgridintf.setdata(arow,fvalue);
end;

procedure tcustomintegeredit.gridtovalue(const arow: integer);
begin
 fgridintf.getdata(arow,fvalue);
 inherited;
end;

procedure tcustomintegeredit.setvalue(const Value: integer);
begin
 fvalue := Value;
 valuechanged;
end;

procedure tcustomintegeredit.texttovalue(var accept: boolean; const quiet: boolean);
var
 int1: integer;
begin
 if fisnull then begin
  int1:= 0;
 end
 else begin
  try
   int1:= strtointvalue(feditor.text,fbase);
  except
   formaterror(quiet);
   accept:= false
  end;
 end;
 if accept then begin
  if not fisnull then begin
   if fmax < fmin then begin //unsigned
    if (cardinal(int1) < cardinal(fmin)) or (cardinal(int1) > cardinal(fmax)) then begin
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

procedure tcustomintegeredit.readstatvalue(const reader: tstatreader);
begin
 if fgridintf <> nil then begin
  with fgridintf.getcol do begin
   with tintegerdatalist(datalist) do begin
    min:= fmin;
    max:= fmax;
   end;
   dostatread(reader);
  end;
//  reader.readintegerdatalist(valuevarname,tintegerdatalist(fgridintf.getcol.datalist),fmin,fmax);
 end
 else begin
  value:= reader.readinteger(valuevarname,value,fmin,fmax);
 end;
end;

procedure tcustomintegeredit.writestatvalue(const writer: tstatwriter);
begin
 writer.writeinteger(valuevarname,value);
end;

procedure tcustomintegeredit.setnullvalue;
begin
 value:= 0;
 text:= '';
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

function tcustomintegeredit.datatotext(const data): msestring;
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
  tdropdowncols1(cols).fitemindex:= getindex(avalue);
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
 if not quiet and canevent(tmethod(fonsetvalue)) then begin
  fonsetvalue(self,mstr1,accept);
 end;
 if accept then begin
  value:= mstr1;
 end;
end;

function tcustomkeystringedit.datatotext(const data): msestring;
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

function tcustomkeystringedit.getdefaultvalue: pointer;
begin
 result:= @fvaluedefault;
end;

procedure tcustomkeystringedit.valuetogrid(const arow: integer);
begin
 fgridintf.setdata(arow,fvalue1);
end;

procedure tcustomkeystringedit.gridtovalue(const arow: integer);
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
 fvaluedefault:= -1;
 fbase:= nb_dec;
 fbitcount:= 32;
 fmin:= -1;
 fmax:= maxint;
 inherited;
// options:= foptions; //add defaultoptions
end;

function getindex1(const avalue: integer; 
                       const enums: integerarty): integer;
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
  result:= avalue;
 end;
end;

function tcustomenuedit.getindex(const avalue: integer): integer;
begin
 result:= getindex1(avalue,enums);
end;

procedure tcustomenuedit.texttodata(const atext: msestring; var data);
begin
 //not supported
end;

function tcustomenuedit.datatotext(const data): msestring;
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
//  if (int2 = -1) or (int2 >= valuelist.count) then begin
   if not (deo_selectonly in options) and (int1 <> -1) then begin
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

function tcustomenuedit.getdatatyp: datatypty;
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
 result:= @fvaluedefault;
end;

procedure tcustomenuedit.gridtovalue(const arow: integer);
begin
 fgridintf.getdata(arow,fvalue1);
 valuetotext;
end;

procedure tcustomenuedit.texttovalue(var accept: boolean; const quiet: boolean);
var
 int1: integer;
begin
 if trim(text) = '' then begin
  int1:= -1;
 end
 else begin
  int1:= tdropdownlistcontroller(fdropdown).itemindex;
  if (int1 >= 0) and (int1 <= high(enums)) then begin
   int1:= enums[int1];
  end
  else begin
   if not (deo_selectonly in fdropdown.options) then begin
    try
     int1:= strtointvalue(feditor.text,fbase);
    except
     accept:= false;
     formaterror(quiet);
    end;
   end;
  end;
 end;
 if not (fisdb and (int1 = -1)) and (int1 < fmin) or (int1 > fmax) then begin
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

procedure tcustomenuedit.valuetogrid(const arow: integer);
begin
 fgridintf.setdata(arow,fvalue1);
end;

procedure tcustomenuedit.readstatvalue(const reader: tstatreader);
var
 min1,max1: integer;
begin
 if fgridintf <> nil then begin
  fgridintf.getcol.dostatread(reader);
//  reader.readintegerdatalist(valuevarname,tintegerdatalist(fgridintf.getcol.datalist));
 end
 else begin
  if enums <> nil then begin
   min1:= fmin;
   max1:= fmax;
  end
  else begin
   if deo_forceselect in fdropdown.options then begin
    min1:= 0;
   end
   else begin
    min1:= -1;
   end;
   with tenumdropdowncontroller(fdropdown) do begin
    max1:= cols[valuecol].count - 1;
   end;
  end;
  value:= reader.readinteger(valuevarname,value,min1,max1);
 end;
end;

procedure tcustomenuedit.writestatvalue(const writer: tstatwriter);
begin
 writer.writeinteger(valuevarname,value);
end;
{
procedure tcustomenumedit.setoptions(const Value: dropdowneditoptionsty);
begin
 inherited setoptions(value + [deo_autodropdown,deo_selectonly]);
end;
}
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

procedure tcustomenuedit.assigncol(const avalue: tintegerdatalist);
begin
 internalassigncol(avalue);
end;

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
   dropdown.cols[dropdown.valuecol].assignarray(getenumnames(avalue));
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
 fdropdownenums:= nil;
 getdropdowninfo(fdropdownenums,fdropdownitems);
 tdropdowncols1(fdropdownitems).fitemindex:= getindex1(fvalue1,fdropdownenums);
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
    int1:= itemindex;
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
 fmin:= emptyreal;
 fmax:= bigreal;
 inherited;
end;

procedure tcustomrealedit.setformatdisp(const Value: string);
begin
 fformatdisp := Value;
 formatchanged;
end;

procedure tcustomrealedit.setformatedit(const Value: string);
begin
 fformatedit := Value;
 formatchanged;
end;

function tcustomrealedit.datatotext(const data): msestring;
var
 rea1: real;
begin
 if @data = nil then begin
  rea1:= fvalue;
 end
 else begin
  rea1:= realty(data);
 end;
 if (fscale <> 0) and not (isemptyreal(rea1)) then begin
  rea1:= rea1/fscale;
 end;
 if (@data = nil) and focused then begin
  result:= realtytostr(rea1,fformatedit);
 end
 else begin
  result:= realtytostr(rea1,fformatdisp);
 end;
end;

function tcustomrealedit.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= tgridrealdatalist.create(sender);
end;

function tcustomrealedit.getdatatyp: datatypty;
begin
 result:= dl_real;
end;

procedure tcustomrealedit.gridtovalue(const arow: integer);
begin
 fgridintf.getdata(arow,fvalue);
 inherited;
end;

procedure tcustomrealedit.valuetogrid(const arow: integer);
begin
 fgridintf.setdata(arow,fvalue);
end;

procedure tcustomrealedit.setvalue(const Value: realty);
begin
 fvalue := Value;
 valuechanged;
end;

procedure tcustomrealedit.texttovalue(var accept: boolean; const quiet: boolean);
var
 rea1,rea2: realty;
 str1: msestring;
begin
 try
  rea1:= strtorealty(feditor.text);
 except
  formaterror(quiet);
  accept:= false
 end;
 if accept then begin
  str1:= realtytostr(rea1,fformatedit);
  try
   rea2:= strtorealty(str1); //round to editformat
   rea1:= rea2;
  except
  end;
  if (fscale <> 0) and not isemptyreal(rea1) then begin
   rea1:= rea1*fscale;
  end;
  if not (fisdb and isemptyreal(rea1)) then begin
   if (cmprealty(fmin,rea1) > 0) or (cmprealty(fmax,rea1) < 0) then begin
    rangeerror(fmin,fmax,quiet);
    accept:= false;
   end;
  end;
  if accept then begin
   if not quiet and canevent(tmethod(fonsetvalue)) then begin
    fonsetvalue(self,rea1,accept);
   end;
   if accept then begin
    value:= rea1;
   end;
  end;
 end;
end;

procedure tcustomrealedit.readvalue(reader: treader);
begin
 value:= readrealty(reader);
end;

procedure tcustomrealedit.writevalue(writer: twriter);
begin
 writerealty(writer,fvalue);
end;

procedure tcustomrealedit.readmin(reader: treader);
begin
 fmin:= readrealty(reader);
end;

procedure tcustomrealedit.writemin(writer: twriter);
begin
 writerealty(writer,fmin);
end;

procedure tcustomrealedit.readmax(reader: treader);
begin
 fmax:= readrealty(reader);
end;

procedure tcustomrealedit.writemax(writer: twriter);
begin
 writerealty(writer,fmax);
end;

procedure tcustomrealedit.defineproperties(filer: tfiler);
var
 bo1,bo2,bo3: boolean;
begin
 inherited;
 if filer.ancestor <> nil then begin
  with tcustomrealedit(filer.ancestor) do begin
   bo1:= self.fvalue <> fvalue;
   bo2:= self.fmin <> fmin;
   bo3:= self.fmax <> fmax;
  end;
 end
 else begin
  bo1:= not isemptyreal(fvalue);
  bo2:= not isemptyreal(fmin);
  bo3:= cmprealty(fmax,0.99*bigreal) < 0;
 end;
 
 filer.DefineProperty('val',
             {$ifdef FPC}@{$endif}readvalue,
             {$ifdef FPC}@{$endif}writevalue,bo1);
 filer.DefineProperty('mi',{$ifdef FPC}@{$endif}readmin,
          {$ifdef FPC}@{$endif}writemin,bo2);
 filer.DefineProperty('ma',{$ifdef FPC}@{$endif}readmax,
          {$ifdef FPC}@{$endif}writemax,bo3);
end;

procedure tcustomrealedit.readstatvalue(const reader: tstatreader);
begin
 if fgridintf <> nil then begin
  with fgridintf.getcol do begin
   with trealdatalist(datalist) do begin
    min:= fmin;
    max:= fmax;
   end;
   dostatread(reader);
  end;
//  reader.readrealdatalist(valuevarname,trealdatalist(fgridintf.getcol.datalist),fmin,fmax);
 end
 else begin
  value:= reader.readreal(valuevarname,value,fmin,fmax)
 end;
end;

procedure tcustomrealedit.writestatvalue(const writer: tstatwriter);
begin
 writer.writereal(valuevarname,value);
end;

function tcustomrealedit.getgridvalue(const index: integer): realty;
begin
 internalgetgridvalue(index,result);
end;

procedure tcustomrealedit.setgridvalue(const index: integer;
  const Value: realty);
begin
 internalsetgridvalue(index,value);
end;

function tcustomrealedit.getgridvalues: realarty;
begin
 result:= trealdatalist(fgridintf.getcol.datalist).asarray;
end;

procedure tcustomrealedit.setgridvalues(const Value: realarty);
begin
 trealdatalist(fgridintf.getcol.datalist).asarray:= value;
end;

procedure tcustomrealedit.setscale(const Value: real);
begin
 if fscale <> value then begin
  fscale := Value;
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
 if isnull then begin
  result:= 0;
 end
 else begin
  result:= round(value);
 end;
end;

procedure tcustomrealedit.setasinteger(const avalue: integer);
begin
 value:= avalue;
end;

function tcustomrealedit.isnull: boolean;
begin
 result:= isemptyreal(value);
end;

{ tcustomdatetimeedit }

constructor tcustomdatetimeedit.create(aowner: tcomponent);
begin
 fvalue:= emptydatetime;
 fmin:= emptydatetime;
 fmax:= 365000.99999;
 inherited;
end;

procedure tcustomdatetimeedit.setvalue(const Value: tdatetime);
begin
 fvalue := Value;
 valuechanged;
end;

procedure tcustomdatetimeedit.setformatdisp(const Value: string);
begin
 fformatdisp := Value;
 formatchanged;
end;

procedure tcustomdatetimeedit.setformatedit(const Value: string);
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

procedure tcustomdatetimeedit.texttovalue(var accept: boolean; 
                                                 const quiet: boolean);
var
 dat1: tdatetime;
 str1: string;
begin
 try
  if fkind = dtk_time then begin
   dat1:= stringtotime(feditor.text);
  end
  else begin
   dat1:= stringtodatetime(feditor.text);
  end;
 except
  formaterror(quiet);
  accept:= false
 end;
 if accept then begin
  dat1:= checkkind(dat1);
  if not (fisdb and isemptydatetime(dat1)) then begin
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

function tcustomdatetimeedit.datatotext(const data): msestring;
var
 dat1: tdatetime;
begin
 if @data = nil then begin
  dat1:= fvalue;
 end
 else begin
  dat1:= tdatetime(data);
 end;
 if fkind = dtk_time then begin
  if (@data = nil) and focused then begin
   result:= mseformatstr.timetostring(dat1,fformatedit);
  end
  else begin
   result:= mseformatstr.timetostring(dat1,fformatdisp);
  end;
 end
 else begin
  if (@data = nil) and focused then begin
   result:= mseformatstr.datetimetostring(dat1,fformatedit);
  end
  else begin
   result:= mseformatstr.datetimetostring(dat1,fformatdisp);
  end;
 end;
end;

function tcustomdatetimeedit.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= tgridrealdatalist.create(sender);
end;

function tcustomdatetimeedit.getdatatyp: datatypty;
begin
 result:= dl_datetime;
end;

procedure tcustomdatetimeedit.valuetogrid(const arow: integer);
begin
 fgridintf.setdata(arow,fvalue);
end;

procedure tcustomdatetimeedit.gridtovalue(const arow: integer);
begin
 fgridintf.getdata(arow,fvalue);
 inherited;
end;

procedure tcustomdatetimeedit.readstatvalue(const reader: tstatreader);
begin
 if fgridintf <> nil then begin
  with fgridintf.getcol do begin
   with trealdatalist(datalist) do begin
    min:= fmin;
    max:= fmax;
   end;
   dostatread(reader);
  end;
 end
 else begin
  value:= reader.readreal(valuevarname,value,fmin,fmax)
 end;
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

procedure tcustomdatetimeedit.writevalue(writer: twriter);
begin
 writerealty(writer,fvalue);
end;

procedure tcustomdatetimeedit.readmin(reader: treader);
begin
 fmin:= readrealty(reader);
end;

procedure tcustomdatetimeedit.writemin(writer: twriter);
begin
 writerealty(writer,fmin);
end;

procedure tcustomdatetimeedit.readmax(reader: treader);
begin
 fmax:= readrealty(reader);
end;

procedure tcustomdatetimeedit.writemax(writer: twriter);
begin
 writerealty(writer,fmax);
end;

procedure tcustomdatetimeedit.defineproperties(filer: tfiler);
var
 bo1,bo2,bo3: boolean;
begin
 inherited;
 if filer.ancestor <> nil then begin
  with tcustomdatetimeedit(filer.ancestor) do begin
   bo1:= self.fvalue <> fvalue;
   bo2:= self.fmin <> fmin;
   bo3:= self.fmax <> fmax;
  end;
 end
 else begin
  bo1:= not isemptyreal(fvalue);
  bo2:= not isemptyreal(fmin);
  bo3:= cmprealty(fmax,0.99*bigreal) < 0;
 end;
 
 filer.DefineProperty('val',
             {$ifdef FPC}@{$endif}readvalue,
             {$ifdef FPC}@{$endif}writevalue,bo1);
 filer.DefineProperty('mi',{$ifdef FPC}@{$endif}readmin,
          {$ifdef FPC}@{$endif}writemin,bo2);
 filer.DefineProperty('ma',{$ifdef FPC}@{$endif}readmax,
          {$ifdef FPC}@{$endif}writemax,bo3);
end;

function tcustomdatetimeedit.isempty(const atext: msestring): boolean;
begin
 result:= (atext <> ' ') and inherited isempty(atext);
end;

function tcustomdatetimeedit.isnull: boolean;
begin
 result:= isemptydatetime(value);
end;

{ tcustomcalendardatetimeedit }

constructor tcustomcalendardatetimeedit.create(aowner: tcomponent);
begin
 inherited;
 fdropdown:= tcalendarcontroller.create(idropdowncalendar(self));
end;

destructor tcustomcalendardatetimeedit.destroy;
begin
 fdropdown.free;
 inherited;
end;

procedure tcustomcalendardatetimeedit.setframe(const avalue: tdropdownbuttonframe);
begin
 inherited setframe(avalue);
end;

function tcustomcalendardatetimeedit.getframe: tdropdownbuttonframe;
begin
 result:= tdropdownbuttonframe(inherited getframe);
end;

procedure tcustomcalendardatetimeedit.internalcreateframe;
begin
 fdropdown.createframe;
end;

procedure tcustomcalendardatetimeedit.dokeydown(var info: keyeventinfoty);
begin
 fdropdown.dokeydown(info);
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;

procedure tcustomcalendardatetimeedit.mouseevent(var info: mouseeventinfoty);
begin
 tcustombuttonframe(fframe).mouseevent(info);
 inherited;
end;

procedure tcustomcalendardatetimeedit.buttonaction(var action: buttonactionty;
               const buttonindex: integer);
begin
 //dummy
end;

procedure tcustomcalendardatetimeedit.dobeforedropdown;
begin
 //dummy
end;

procedure tcustomcalendardatetimeedit.doafterclosedropdown;
begin
 //dummy
end;

function tcustomcalendardatetimeedit.createdropdownwidget(const atext: msestring): twidget;
var
 dat1: tdatetime;
begin
 result:= tpopupcalendarfo.create(nil,fdropdown);
 dat1:= now;
 if trim(atext) <> '' then begin
  try
   dat1:= strtodate(atext);
  except
  end;
 end;
 tpopupcalendarfo(result).value:= dat1;
end;

function tcustomcalendardatetimeedit.getdropdowntext(const awidget: twidget): msestring;
begin
 result:= text;
end;

procedure tcustomcalendardatetimeedit.editnotification(var info: editnotificationinfoty);
begin
 if fdropdown <> nil then begin
  fdropdown.editnotification(info);
 end;
 inherited;
end;

procedure tcustomcalendardatetimeedit.updatereadonlystate;
begin
 inherited;
 if fdropdown <> nil then begin
  fdropdown.updatereadonlystate;
 end;
end;

end.
