{ MSEgui Copyright (c) 1999-2011 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msedatalist;

{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}

interface

uses
 sysutils,classes,msestrings,typinfo,msereal,msetypes,msestream,
 mseclasses,mselist,mseglob;

type
 listdatatypety = (dl_none,dl_integer,dl_int64,dl_currency,
    dl_real,dl_realint,dl_realsum,
    dl_datetime,
    dl_ansistring,dl_msestring,dl_doublemsestring,dl_msestringint,
    dl_complex,dl_rowstate,dl_custom);
 listdatatypesty = set of listdatatypety;
 
 doublestringty = record
  a,b: string;
 end;
 pdoublestringty = ^doublestringty;
 doublestringarty = array of doublestringty;

 doublemsestringty = record
  a,b: msestring;
 end;
 pdoublemsestringty = ^doublemsestringty;
 doublemsestringarty = array of doublemsestringty;
 dataprocty = procedure(var data) of object;
{
 internallistoptionty = (ilo_needsfree,ilo_needscopy,ilo_needsinit,
                         ilo_nostreaming,ilo_nogridstreaming,
                         ilo_propertystreaming);
 internallistoptionsty = set of internallistoptionty;
}
 tdatalist = class;
 tintegerdatalist = class;

 indexeventty = procedure(const sender: tdatalist; const index: integer) of object;
// listlineeventty = procedure (sender: tdatalist; index: integer) of object;

 blockcopymodety = (bcm_none,bcm_copy,bcm_init,bcm_rotate);
{
 idatalist = interface(inullinterface)
  procedure listdestroyed(const sender: idatalist);
  getlist: tdatalist;  
 end;
 idatalistarty = array of idatalist;
}
 copyprocty = procedure(const source,dest:pointer);
 copy2procty = procedure(const source1,source2,dest:pointer);
 
 datalistarty = array of tdatalist;

 listlinkinfoty = record
  name: string; //case sensitive
  dirtystart,dirtystop: integer;
  source: tdatalist;
 end;
 plistlinkinfoty = ^listlinkinfoty;

 idatalistclient = interface(iobjectlink)
  function getobjectlinker: tobjectlinker;
  procedure itemchanged(const sender: tdatalist; const aindex: integer);
 end;

 dataliststatety = (
                    dls_needsfree,dls_needscopy,dls_needsinit,
                    dls_nostreaming,dls_nogridstreaming,
                    dls_propertystreaming,
                    dls_sorted,dls_sortio,
                    dls_forcenew, //used in tundolist
                    dls_remote,   //used in ificomp datalist
                    dls_remotelock
                    );
 dataliststatesty = set of dataliststatety;
  
 tdatalist = class(tlinkedpersistent)
  private
   fbytelength: integer;   //pufferlaenge
//   fsortio: boolean;
//   fsorted: boolean;
   Fcapacity: integer;
   fonchange: notifyeventty;
   fonitemchange: indexeventty;
   fnochange: integer;
   fdeleting: integer;
   fmaxcount: integer;
   fringpointer: integer;
   fcheckeditem: integer;
   procedure setcapacity(value: integer);
   procedure internalsetcount(value: integer; nochangeandinit: boolean);
   procedure checkcapacity; //ev. reduktion des memory
   procedure setmaxcount(const Value: integer);
   procedure internalfreedata(index,anzahl: integer); //gibt daten frei falls notwendig
   procedure internalcopyinstance(index,anzahl: integer);
   function getsorted: boolean;
   procedure setsorted(const Value: boolean); //datenkopieren
   procedure internalcleardata(const index: integer);
   procedure remoteitemchange(const alink: pointer);
   procedure setcheckeditem(const avalue: integer);
  protected
   fdatapo: pchar;
   fsize: integer;
//   finternaloptions: internallistoptionsty;
   fcount: integer;
   flinkdest: datalistarty;
   fstate: dataliststatesty;
   fintparam: integer;
   function checkassigncompatibility(const source: tpersistent): boolean; virtual;
   function assigndata(const source: tpersistent): boolean;
                       //false if not possible
   procedure assigntodata(const dest: tdatalist);
   procedure newbuffer(const acount: integer; const noinit: boolean;
                              const fillnull: boolean);
   procedure clearbuffer; virtual; //buffer release
   procedure setcount(const value: integer); virtual;
   property nochange: integer read fnochange;
   procedure internalgetasarray(const adatapo: pointer; const asize: integer);
   procedure internalsetasarray(const source: pointer; const asize: integer;
                                const acount: integer);
   procedure writedata(writer: twriter);
   procedure readdata(reader: treader);
   procedure readitem(const reader: treader; var value); virtual;
   procedure writeitem(const writer: twriter; var value); virtual;

   procedure internalgetdata(index: integer; out ziel);
   procedure internalsetdata(index: integer; const quelle);
   procedure internalfill(const anzahl: integer; const wert);
   procedure getdefaultdata(var dest);
   procedure getgriddefaultdata(var dest); virtual;
   procedure getdata(index: integer; var dest);
   procedure getgriddata(index: integer; var dest); virtual;
   procedure setdata(index: integer; const source);
   procedure setgriddata(index: integer; const source); virtual;
   function getstatdata(const index: integer): msestring; virtual;
   procedure setstatdata(const index: integer; const value: msestring); virtual;
   procedure writestate(const writer; const name: msestring); virtual;
                      //typeless because of recursive interface
   procedure readstate(const reader; const acount: integer); virtual;
   procedure writeappendix(const writer; const aname: msestring); virtual;
   procedure readappendix(const reader; const aname: msestring); virtual;

   function poptopdata(var ziel): boolean;    //top of stack, false if empty
   function popbottomdata(var ziel): boolean; //bottom of stack, false if empty
   procedure pushdata(const quelle);
   procedure checkbuffersize(increment: integer); //fuer ringpuffer
   procedure internalinsertdata(index: integer; const quelle;
                      const docopy: boolean);
   procedure insertdata(const index: integer; const quelle);
   procedure defineproperties(filer: tfiler); override;
   procedure freedata(var data); virtual;      //gibt daten frei
   procedure copyinstance(var data); virtual;  //nach blockcopy aufgerufen
   procedure initinstance(var data); virtual;  //fuer neue zeilen aufgerufen
   function internaladddata(const quelle; docopy: boolean): integer;
   function adddata(const quelle): integer;
   procedure compare(const l,r; var result: integer); virtual;
   function getdefault: pointer; virtual; //nil fuer null
   procedure normalizering; //macht ringpointer = null
   procedure blockcopymovedata(fromindex,toindex: integer;
                  const count: integer; const mode: blockcopymodety);
   procedure initdata1(const afree: boolean; index: integer;
                                const acount: integer);
                //initialisiert mit defaultwert
   procedure forall(startindex: integer; const count: integer;
                           const proc: dataprocty);
   procedure doitemchange(const index: integer); virtual;
   procedure dochange; virtual;
   procedure internaldeletedata(index: integer; dofree: boolean);
//   procedure checkindexrange(const aindex: integer);

   function getlinkdatatypes(const atag: integer): listdatatypesty; virtual;
   procedure initsource(var asource: listlinkinfoty);
   procedure removesource(var asource: listlinkinfoty);
   procedure checklistdestroyed(var ainfo: listlinkinfoty;
                                                const sender: tdatalist);
   procedure unlinksource(var alink: listlinkinfoty);
   function internallinksource(const source: tdatalist;
                 const atag: integer; var variable: tdatalist): boolean;
   function checksourcechange(var ainfo: listlinkinfoty; 
                        const sender: tdatalist; const aindex: integer): boolean;
   function checksourcecopy(var ainfo: listlinkinfoty;
                                     const copyproc: copyprocty): boolean;
   function checksourcecopy2(var ainfo: listlinkinfoty;
                const source2: tdatalist; const copyproc: copy2procty): boolean;
   procedure internalrearange(arangelist: pinteger; const acount: integer);
   function islinked(const asource: tdatalist): boolean;
   procedure datadeleted(const aindex: integer; const acount: integer);
   procedure datainserted(const aindex: integer; const acount: integer);
   procedure datamoved(const fromindex: integer; const toindex: integer;
                                  const acount: integer); virtual;
  public
   constructor create; override;
   destructor destroy; override;

   //idatalist
   procedure listdestroyed(const sender: tdatalist); virtual;
   procedure sourcechange(const sender: tdatalist;
                                         const aindex: integer); virtual;

   procedure linkclient(const aclient: idatalistclient);
   procedure unlinkclient(const aclient: idatalistclient);
   
   function getsourcecount: integer; virtual;
   function getsourceinfo(const atag: integer): plistlinkinfoty; virtual;
   function getsourcename(const atag: integer): string;
   procedure linksource(const source: tdatalist; const atag: integer); virtual;
   function canlink(const asource: tdatalist;
                                        const atag: integer): boolean; virtual;
 
   property size: integer read fsize;
   property state: dataliststatesty read fstate;
   function datapo: pointer; //calls normalizering,
             //do not use in copyinstance,initinstance,freedata
   function datahighpo: pointer; //points to last item
   function getitempo(index: integer): pointer;
             //invalid after capacity change
   function getastext(const index: integer): msestring; virtual;
   procedure setastext(const index: integer; const avalue: msestring); virtual;

   procedure assign(sender: tpersistent); override;
   procedure assignb(const source: tdatalist); virtual;
             //assign with second value if possible, exception otherwise
   procedure assigntob(const dest: tdatalist); virtual;
             //assignto with second value if possible, exception otherwise
   function getdatablock(const source: pointer; const destsize: integer): integer;
             //returns size of datablock
   function setdatablock(const dest: pointer; const sourcesize: integer;
                                       const acount: integer): integer;
             //returns size of datablock
   procedure change(const index: integer); virtual;
                   //index -1 -> undefined
   function datatype: listdatatypety; virtual;
   procedure checkindexrange(const aindex: integer; const acount: integer = 1);
   procedure checkindex(var index: integer); //bringt absolute zeilennummer in ringpuffer
   procedure beginupdate; virtual;
   procedure endupdate; virtual;
   procedure incupdate;
   procedure decupdate;
   function updating: boolean;
   procedure clear; virtual;//loescht daten
   procedure initdata(const index,anzahl: integer);
                //anzahl -> count, initialisiert mit defaultwert
   procedure cleardata(index: integer);
   function deleting: boolean;
   function checkwritedata(const filer: tfiler): boolean; virtual;

   procedure rearange(const arangelist: tintegerdatalist); overload;
   procedure rearange(const arangelist: integerarty); overload;
   procedure movedata(const fromindex,toindex: integer);
   procedure blockmovedata(const fromindex,toindex,count: integer);
   procedure blockcopydata(const fromindex,toindex,count: integer);
   procedure deletedata(const index: integer);
   procedure deleteitems(index,acount: integer);
   procedure insertitems(index,acount: integer);
   function empty(const index: integer): boolean; virtual;         //true wenn leer
   function sort(const compareproc: compareprocty; const arangelist: tintegerdatalist; dorearange: boolean): boolean; overload;
   function sort(const arangelist: tintegerdatalist; dorearange: boolean): boolean; overload;
   function sort: boolean; overload; //true if changed
   function sort(const compareproc: compareprocty): boolean; overload;
   procedure clean(const start,stop: integer); virtual;
   procedure clearmemberitem(const subitem: integer; 
                                    const index: integer); virtual;
   procedure setmemberitem(const subitem: integer; 
                         const index: integer; const avalue: integer); virtual;

   property count: integer read Fcount write Setcount;       //anzahl zeilen
   property capacity: integer read Fcapacity write Setcapacity;
   property onchange: notifyeventty read fonchange write fonchange;
   property onitemchange: indexeventty read fonitemchange write fonitemchange;

   property maxcount: integer read fmaxcount
                     write setmaxcount default bigint; //for ring buffer
   property sorted: boolean read getsorted write setsorted;
   property checkeditem: integer read fcheckeditem write setcheckeditem; 
                           //-1 if none
 end;
 
 pdatalist = ^tdatalist;
 
 subdatainfoty = record
  list: tdatalist;
  subindex: integer; //0 = main
 end;
 subdatainfoarty = array of subdatainfoty;

 tintegerdatalist = class(tdatalist)
  private
   function Getitems(const index: integer): integer;
   procedure Setitems(const index: integer; const Value: integer);
   procedure setasarray(const avalue: integerarty);
   function getasarray: integerarty;
   procedure setasbooleanarray(const avalue: booleanarty);
   function getasbooleanarray: booleanarty;
  protected
   function checkassigncompatibility(
                            const source: tpersistent): boolean; override;
   procedure readitem(const reader: treader; var value); override;
   procedure writeitem(const writer: twriter; var value); override;
   procedure compare(const l,r; var result: integer); override;
   procedure setstatdata(const index: integer; const value: msestring); override;
   function getstatdata(const index: integer): msestring; override;
   procedure writeappendix(const writer; const aname: msestring); override;
   procedure readappendix(const reader; const aname: msestring); override;
  public
   min: integer;
   max: integer;
   constructor create; override;
   function datatype: listdatatypety; override;
   function empty(const index: integer): boolean; override;   //true wenn leer
   function add(const value: integer): integer;
   procedure insert(const index: integer; const item: integer);
   procedure number(const start,step: integer); //numeriert daten
   function find(value: integer): integer;  //bringt index, -1 wenn nicht gefunden
   procedure fill(acount: integer; const defaultvalue: integer); overload;
   procedure fill(const defaultvalue: integer); overload;
   function getastext(const index: integer): msestring; override;
   procedure setastext(const index: integer; const avalue: msestring); override;

   property asarray: integerarty read getasarray write setasarray;
   property asbooleanarray: booleanarty read getasbooleanarray write setasbooleanarray;
   property items[const index: integer]: integer read Getitems write Setitems; default;
 end;

 tbooleandatalist = class(tintegerdatalist)
  private
   procedure setasarray(const avalue: longboolarty);
   function getasarray: longboolarty;
   function getitems(const index: integer): boolean;
   procedure setitems(const index: integer; const avalue: boolean);
  public
   procedure fill(acount: integer; const defaultvalue: boolean); overload;
   procedure fill(const defaultvalue: boolean); overload;
   property asarray: longboolarty read getasarray 
                                                  write setasarray;
   property items[const index: integer]: boolean read Getitems write Setitems; default;
 end;
 
 tint64datalist = class(tdatalist)
  private
   function Getitems(index: integer): int64;
   procedure Setitems(index: integer; const avalue: int64);
   procedure setasarray(const value: int64arty);
   function getasarray: int64arty;
  protected
   function checkassigncompatibility(
                            const source: tpersistent): boolean; override;
   procedure readitem(const reader: treader; var value); override;
   procedure writeitem(const writer: twriter; var value); override;
   procedure compare(const l,r; var result: integer); override;
   procedure setstatdata(const index: integer; const value: msestring); override;
   function getstatdata(const index: integer): msestring; override;
  public
   constructor create; override;
   function datatype: listdatatypety; override;
//   procedure assign(source: tpersistent); override;
   function empty(const index: integer): boolean; override;   //true wenn leer
   function add(const avalue: int64): integer;
   procedure insert(const index: integer; const avalue: int64);
   function find(const avalue: int64): integer;  //bringt index, -1 wenn nicht gefunden
   procedure fill(const acount: integer; const defaultvalue: int64); overload;
   procedure fill(const defaultvalue: int64); overload;
   function getastext(const index: integer): msestring; override;
   procedure setastext(const index: integer; const avalue: msestring); override;

   property asarray: int64arty read getasarray write setasarray;
   property items[index: integer]: int64 read Getitems write Setitems; default;
 end;
 
 tcurrencydatalist = class(tdatalist)
  private
   function Getitems(index: integer): currency;
   procedure Setitems(index: integer; const avalue: currency);
   procedure setasarray(const value: currencyarty);
   function getasarray: currencyarty;
  protected
   function checkassigncompatibility(
                            const source: tpersistent): boolean; override;
   procedure readitem(const reader: treader; var value); override;
   procedure writeitem(const writer: twriter; var value); override;
   procedure compare(const l,r; var result: integer); override;
   procedure setstatdata(const index: integer; const value: msestring); override;
   function getstatdata(const index: integer): msestring; override;
  public
   constructor create; override;
   function datatype: listdatatypety; override;
//   procedure assign(source: tpersistent); override;
   function empty(const index: integer): boolean; override;   //true wenn leer
   function add(const avalue: currency): integer;
   procedure insert(const index: integer; const avalue: currency);
   function find(const avalue: currency): integer;  //bringt index, -1 wenn nicht gefunden
   procedure fill(const acount: integer; const defaultvalue: currency); overload;
   procedure fill(const defaultvalue: currency); overload;
   function getastext(const index: integer): msestring; override;
   procedure setastext(const index: integer; const avalue: msestring); override;

   property asarray: currencyarty read getasarray write setasarray;
   property items[index: integer]: currency read Getitems write Setitems; default;
 end;
  
 tenumdatalist = class(tintegerdatalist)
  private
   fgetdefault: getintegereventty;
   fdefaultval: integer;
  protected
   function getdefault: pointer; override;
  public
   constructor create(agetdefault: getintegereventty); reintroduce;
   function empty(const index: integer): boolean; override;   //true wenn leer
 end;

 tenum64datalist = class(tint64datalist)
  private
   fgetdefault: getint64eventty;
   fdefaultval: int64;
  protected
   function getdefault: pointer; override;
  public
   constructor create(agetdefault: getint64eventty); reintroduce;
   function empty(const index: integer): boolean; override;   //true wenn leer
 end;

 tcomplexdatalist = class;

 trealdatalist = class(tdatalist)
  private
   fdefaultzero: boolean;
   fdefaultval: realty;
   function Getitems(index: integer): realty;
   procedure Setitems(index: integer; const Value: realty);
   function getasarray: realarty;
   procedure setasarray(const data: realarty);
  protected
   function checkassigncompatibility(
                            const source: tpersistent): boolean; override;
   procedure readitem(const reader: treader; var value); override;
   procedure writeitem(const writer: twriter; var value); override;
   function getdefault: pointer; override;
   procedure compare(const l,r; var result: integer); override;
   procedure setstatdata(const index: integer; const value: msestring); override;
   function getstatdata(const index: integer): msestring; override;
  public
   min: realty;
   max: realty;
   constructor create; override;
   function datatype: listdatatypety; override;
   procedure assignre(source: tcomplexdatalist);
   procedure assignim(source: tcomplexdatalist);
   function empty(const index: integer): boolean; override;
   function add(const value: real): integer;
   procedure insert(index: integer; const item: realty);
   procedure number(start,step: real);
   procedure fill(acount: integer; const defaultvalue: realty); overload;
   procedure fill(const defaultvalue: realty); overload;
   procedure minmax(out minval,maxval: realty);
   function getastext(const index: integer): msestring; override;
   procedure setastext(const index: integer; const avalue: msestring); override;

   property asarray: realarty read getasarray write setasarray;
   property items[index: integer]: realty read Getitems write Setitems; default;
   property defaultzero: boolean read fdefaultzero write fdefaultzero default false;
 end;

 tdatetimedatalist = class(trealdatalist)
  protected
   function getdefault: pointer; override;
  public
   function datatype: listdatatypety; override;
   function empty(const index: integer): boolean; override;   //true wenn leer
   procedure fill(acount: integer; const defaultvalue: tdatetime); overload;
   procedure fill(const defaultvalue: tdatetime); overload;
 end;

 tcomplexdatalist = class(tdatalist)
  private
   fdefaultzero: boolean;
   fdefaultval: complexty;
   function Getitems(const index: integer): complexty;
   procedure Setitems(const index: integer; const Value: complexty);
   procedure setasarray(const data: complexarty);
   function getasarray: complexarty;
  protected
   function checkassigncompatibility(
                            const source: tpersistent): boolean; override;
   procedure readitem(const reader: treader; var value); override;
   procedure writeitem(const writer: twriter; var value); override;
   function getdefault: pointer; override;
   procedure assignto(dest: tpersistent); override;
  public
   min: realty;      //for property editor
   max: realty;
   
   constructor create; override;
   function datatype: listdatatypety; override;
   procedure assign(source: tpersistent); override;
   procedure assignb(const source: tdatalist); override;
   procedure assignre(const source: trealdatalist);
   procedure assignim(const source: trealdatalist);
   procedure assigntoa(const dest: tdatalist);
   procedure assigntob(const dest: tdatalist); override;
   function add(const value: complexty): integer;
   procedure insert(const index: integer; const item: complexty);
   function empty(const index: integer): boolean; override;   //true wenn leer
   procedure fill(const acount: integer; const defaultvalue: complexty); overload;
   procedure fill(const defaultvalue: complexty); overload;

   property asarray: complexarty read getasarray write setasarray;
   property items[const index: integer]: complexty read Getitems write Setitems; default;
   property defaultzero: boolean read fdefaultzero write fdefaultzero default false;
 end;

 realintty = record
              rea: realty;
              int: integer;
             end;
 prealintty = ^realintty;
 realintarty = array of realintty;
 realintaty = array[0..0] of realintty;
                   
 trealintdatalist = class(trealdatalist)
  private
   fdefaultval1: realintty;
   function Getdoubleitems(index: integer): realintty;
   procedure Setdoubleitems(index: integer; const Value: realintty);
   function Getitemsb(index: integer): integer;
   procedure Setitemsb(index: integer; const Value: integer);
   function getasarray: realintarty;
   procedure setasarray(const data: realintarty);
   function getasarraya: realarty;
   procedure setasarraya(const data: realarty);
   function getasarrayb: integerarty;
   procedure setasarrayb(const data: integerarty);
  protected
   procedure readitem(const reader: treader; var value); override;
   procedure writeitem(const writer: twriter; var value); override;
   procedure compare(const l,r; var result: integer); override;
   procedure setstatdata(const index: integer; const value: msestring); override;
   function getstatdata(const index: integer): msestring; override;
   function getdefault: pointer; override;
  public
   constructor create; override;
//   procedure assign(source: tpersistent); override;
   procedure assignb(const source: tdatalist); override;
   procedure assigntob(const dest: tdatalist); override;

   function datatype: listdatatypety; override;
   function add(const valuea: realty; const valueb: integer = 0): integer; overload;
   function add(const value: realintty): integer; overload;
   procedure insert(const index: integer; const item: realty;
                               const itemint: integer);
   procedure fill(const acount: integer; const defaultvalue: realty;
                     const defaultint: integer); overload;
   procedure fill(const defaultvalue: realty;
                     const defaultint: integer); overload;

   property asarray: realintarty read getasarray write setasarray;
   property asarraya: realarty read getasarraya write setasarraya;
   property asarrayb: integerarty read getasarrayb write setasarrayb;
   property itemsb[index: integer]: integer read Getitemsb write Setitemsb;
   property doubleitems[index: integer]: realintty read Getdoubleitems
                   write Setdoubleitems; default;
 end;
 
 tpointerdatalist = class(tdatalist)
  private
   function Getitems(index: integer): pointer;
   procedure Setitems(index: integer; const Value: pointer);
   function getasarray: pointerarty;
   procedure setasarray(const data: pointerarty);
  protected
   function checkassigncompatibility(
                            const source: tpersistent): boolean; override;
  public
   constructor create; override;
   property items[index: integer]: pointer read Getitems write Setitems; default;
   property asarray: pointerarty read getasarray write setasarray;
 end;

 tdynamicdatalist = class(tdatalist)
  protected
  public
   constructor create; override;
 end;

 tdynamicpointerdatalist = class(tdynamicdatalist)
  public
   constructor create; override;
 end;

 tansistringdatalist = class(tdynamicpointerdatalist)
  private
   function Getitems(index: integer): ansistring;
   procedure Setitems(index: integer; const Value: ansistring);
   function getasarray: stringarty;
   procedure setasarray(const avalue: stringarty);
   function getasmsestringarray: msestringarty;
   procedure setasmsestringarray(const avalue: msestringarty);
  protected
   function checkassigncompatibility(
                            const source: tpersistent): boolean; override;
   procedure readitem(const reader: treader; var value); override;
   procedure writeitem(const writer: twriter; var value); override;
   procedure freedata(var data); override; //gibt daten frei
   procedure copyinstance(var data); override;
               //nach blockcopy aufgerufen
   procedure assignto(dest: tpersistent); override;
   procedure compare(const l,r; var result: integer); override;
   procedure setstatdata(const index: integer; const value: msestring); override;
   function getstatdata(const index: integer): msestring; override;
   function textlength: integer;
  public
   function datatype: listdatatypety; override;
   procedure assign(source: tpersistent); override;
   procedure assignopenarray(const data: array of ansistring);
//   procedure assignarray(const data: stringarty); overload;
///   procedure assignarray(const data: msestringarty); overload;
   procedure insert(index: integer; const item: ansistring);
   function add(const value: ansistring): integer; overload;
   function addtext(const value: ansistring): integer;
                //returns added linecount
   function empty(const index: integer): boolean; override;   //true wenn leer
   procedure fill(acount: integer; const defaultvalue: ansistring);
   function getastext(const index: integer): msestring; override;
   procedure setastext(const index: integer; const avalue: msestring); override;

   function gettext: ansistring;
   procedure settext(const avalue: ansistring);
   
   property items[index: integer]: ansistring read Getitems write 
                        setitems; default;
   property asarray: stringarty read getasarray write setasarray;
   property asmsestringarray: msestringarty read getasmsestringarray
                              write setasmsestringarray;
 end;

 tmsestringdatalist = class;

 tpoorstringdatalist = class(tdynamicpointerdatalist)
  private
   feditcharindex: integer;
   function Getitems(index: integer): msestring;
   procedure Setitems(index: integer; const Value: msestring);
   function getasarray: msestringarty;
   procedure setasarray(const data: msestringarty);
   function getasstringarray: stringarty;
   procedure setasstringarray(const data: stringarty);
  protected
   function checkassigncompatibility(
                            const source: tpersistent): boolean; override;
   procedure readitem(const reader: treader; var value); override;
   procedure writeitem(const writer: twriter; var value); override;
   procedure freedata(var data); override; //gibt daten frei
   procedure copyinstance(var data); override;
               //nach blockcopy aufgerufen
   procedure assignto(dest: tpersistent); override;
   procedure setstatdata(const index: integer; const value: msestring); override;
   function getstatdata(const index: integer): msestring; override;
   function getnoparagraphs(index: integer): boolean; virtual;
   function textlength: integer;
  public
   procedure assign(source: tpersistent); override;
   procedure assignopenarray(const data: array of msestring); overload;
//   procedure assignarray(const data: stringarty); overload;
//   procedure assignarray(const data: msestringarty); overload;
   procedure insert(const index: integer; const item: msestring); virtual; abstract;
   function add(const value: tmsestringdatalist): integer; overload;
   function add(const value: msestring): integer; overload; virtual; abstract;
   function add(const avalue: msestring; const anoparagraph: boolean): integer; 
                                                              overload; virtual;
   function addchars(const value: msestring; 
                            const processeditchars: boolean = true;
                            const maxchars: integer = 0): integer;
          //adds characters to last row, returns index
          //maxchars = 0 -> no limitation, inserts line breaks otherwise
   function getastext(const index: integer): msestring; override;
   procedure setastext(const index: integer;
                         const avalue: msestring); override;

   function gettext: msestring;
   procedure settext(const avalue: msestring);
   
   function indexof(const value: msestring): integer;
   function empty(const index: integer): boolean; override;   //true wenn leer
   function concatstring(const delim: msestring = '';
                            const separator: msestring = '';
                            const separatornoparagraph: msestring = ''): msestring;
   procedure loadfromfile(const filename: string;
                              const aencoding: charencodingty = ce_locale);
   procedure loadfromstream(const stream: ttextstream);
   procedure savetofile(const filename: string;
                              const aencoding: charencodingty = ce_locale);
   procedure savetostream(const stream: ttextstream);
   function dataastextstream: ttextstream;
                     //chars truncated to 8bit, not null terminated

   property asarray: msestringarty read getasarray write setasarray;
   property asstringarray:stringarty read getasstringarray write setasstringarray;
   property items[index: integer]: msestring read Getitems write Setitems; default;
 end;

 tmsestringdatalist = class(tpoorstringdatalist)
  private
  protected
   procedure compare(const l,r; var result: integer); override;
  public
   function datatype: listdatatypety; override;
   function add(const value: msestring): integer; override;
   procedure insert(const index: integer; const item: msestring); override;
   procedure fill(acount: integer; const defaultvalue: msestring);
 end;

 tdoublemsestringdatalist = class(tpoorstringdatalist)
  private
   function Getdoubleitems(index: integer): doublemsestringty;
   procedure Setdoubleitems(index: integer; const Value: doublemsestringty);
   function Getitemsb(index: integer): msestring;
   procedure Setitemsb(index: integer; const Value: msestring);
   function getasarray: doublemsestringarty;
   procedure setasarray(const data: doublemsestringarty);
   function getasarraya: msestringarty;
   procedure setasarraya(const data: msestringarty);
   function getasarrayb: msestringarty;
   procedure setasarrayb(const data: msestringarty);
  protected
   procedure readitem(const reader: treader; var value); override;
   procedure writeitem(const writer: twriter; var value); override;
   procedure compare(const l,r; var result: integer); override;
   procedure freedata(var data); override; //gibt daten frei
   procedure copyinstance(var data); override;
  public
   constructor create; override;
//   procedure assign(source: tpersistent); override;
   procedure assignb(const source: tdatalist); override;
   procedure assigntob(const dest: tdatalist); override;

   function datatype: listdatatypety; override;
   function add(const valuea: msestring; const valueb: msestring = ''): integer; overload;
   function add(const value: doublemsestringty): integer; overload;
   procedure insert(const index: integer; const item: msestring); override;
   procedure fill(const acount: integer; const defaultvalue: msestring);

   property asarray: doublemsestringarty read getasarray write setasarray;
   property asarraya: msestringarty read getasarraya write setasarraya;
   property asarrayb: msestringarty read getasarrayb write setasarrayb;
   property itemsb[index: integer]: msestring read Getitemsb write Setitemsb;
   property doubleitems[index: integer]: doublemsestringty read Getdoubleitems
                   write Setdoubleitems; default;
 end;

 msestringintty = record
                   mstr: msestring;
                   int: integer;
                  end;
 pmsestringintty = ^msestringintty;
 msestringintarty = array of msestringintty;
 msestringintaty = array[0..0] of msestringintty;
                   
 tmsestringintdatalist = class(tpoorstringdatalist)
  private
   function Getdoubleitems(index: integer): msestringintty;
   procedure Setdoubleitems(index: integer; const Value: msestringintty);
   function Getitemsb(index: integer): integer;
   procedure Setitemsb(index: integer; const Value: integer);
   function getasarray: msestringintarty;
   procedure setasarray(const data: msestringintarty);
   function getasarraya: msestringarty;
   procedure setasarraya(const data: msestringarty);
   function getasarrayb: integerarty;
   procedure setasarrayb(const data: integerarty);
  protected
   procedure readitem(const reader: treader; var value); override;
   procedure writeitem(const writer: twriter; var value); override;
   procedure compare(const l,r; var result: integer); override;
//   procedure freedata(var data); override;
//   procedure copyinstance(var data); override;
   procedure setstatdata(const index: integer; const value: msestring); override;
   function getstatdata(const index: integer): msestring; override;
  public
   constructor create; override;
//   procedure assign(source: tpersistent); override;
   procedure assignb(const source: tdatalist); override;
   procedure assigntob(const dest: tdatalist); override;

   function datatype: listdatatypety; override;
   function add(const valuea: msestring; const valueb: integer = 0): integer; overload;
   function add(const value: msestringintty): integer; overload;
   procedure insert(const index: integer; const item: msestring;
                               const itemint: integer);
   procedure fill(const acount: integer; const defaultvalue: msestring;
                     const defaultint: integer);

   property asarray: msestringintarty read getasarray write setasarray;
   property asarraya: msestringarty read getasarraya write setasarraya;
   property asarrayb: integerarty read getasarrayb write setasarrayb;
   property itemsb[index: integer]: integer read Getitemsb write Setitemsb;
   property doubleitems[index: integer]: msestringintty read Getdoubleitems
                   write Setdoubleitems; default;
 end;

const
 foldhiddenbit = 7;
 foldhiddenmask = 1 shl foldhiddenbit;
 currentfoldhiddenbit = 6;
 currentfoldhiddenmask = 1 shl currentfoldhiddenbit;
 foldlevelmask = byte(not (foldhiddenmask or currentfoldhiddenmask));
 foldissumbit = 0;
 foldissummask = $01;
 rowstatemask = $7f;

 selectedcolmax = 30; //32 bitset, bit31 -> whole row
 wholerowselectedmask = $80000000;
 mergedcolmax = 32;
 mergedcolall = $ffffffff;

type
 rowstatenumty = -1..126; //msb = row readonly flag for rowfontstate,
            //reserved for rowcolorstate (used in tcustomstringgrid)

 rowinfolevelty = (ril_normal,ril_colmerge,ril_rowheight);
 rowstatety = packed record
  selected: longword; //bitset lsb = col 0, msb-1 = col 30, msb = whole row
                      //adressed by fcreateindex
  color: byte; //index in rowcolors, 0 = none, 1 = rowcolors[0]
  font: byte;  //index in rowfonts, 0 = none, 1 = rowfonts[0]
  fold: byte;  // hc nnnnnn  h = hidden c = current hidden,
               //    nnnnnn = fold level, 0 -> top
  flags: byte; // 0000000s s = issum
 end;
 prowstatety = ^rowstatety;
 rowstateaty = array[0..0] of rowstatety;
 prowstateaty  = ^rowstateaty;

 colmergety = packed record
  merged: longword; //bitset lsb = col 1, msb = col32, 
                    //$ffffffff = first col fills whole row
                    //addressed by column index
 end;
 rowstatecolmergety = packed record
  normal: rowstatety;
  colmerge: colmergety;
 end;
 prowstatecolmergety = ^rowstatecolmergety;
 rowstatecolmergeaty = array[0..0] of rowstatecolmergety;
 prowstatecolmergeaty  = ^rowstatecolmergeaty;

 rowheightty = packed record
  height: integer;
  ypos: integer;
  linewidth: byte; //0 -> default, 1 -> 0, 2 -> 1...
  linecolor: byte; //index in rowcolors, 0 = none, 1 = rowcolors[0]
  linecolorfix: byte; //index in rowcolors, 0 = none, 1 = rowcolors[0]
 end;
 rowstaterowheightty = packed record
  normal: rowstatety;
  colmerge: colmergety;
  rowheight: rowheightty;
 end;
 prowstaterowheightty = ^rowstaterowheightty;
 rowstaterowheightaty = array[0..0] of rowstaterowheightty;
 prowstaterowheightaty  = ^rowstaterowheightaty;

 rowstatememberty = (rsm_select,rsm_color,rsm_font,rsm_readonly,
                     rsm_foldlevel,rsm_foldissum,
                     rsm_hidden,rsm_merged,rsm_height);

const
 rowinfosizes: array[rowinfolevelty] of integer = 
            (sizeof(rowstatety),sizeof(rowstatecolmergety),
            sizeof(rowstaterowheightty));
type
 tcustomrowstatelist = class(tdatalist)
  private
   function getrowstate(const index: integer): rowstatety;
   procedure setrowstate(const index: integer; const Value: rowstatety);
   function getrowstatecolmerge(const index: integer): rowstatecolmergety;
   procedure setrowstatecolmerge(const index: integer;
                                        const Value: rowstatecolmergety);
   function getrowstaterowheight(const index: integer): rowstaterowheightty;
   procedure setrowstaterowheight(const index: integer;
                                        const Value: rowstaterowheightty);
   function getfoldinfoar: bytearty;
   function getcolor(const index: integer): rowstatenumty;
   procedure setcolor(const index: integer; const avalue: rowstatenumty);
   function getfont(const index: integer): rowstatenumty;
   procedure setfont(const index: integer; const avalue: rowstatenumty);
   function getreadonly(const index: integer): boolean;
   procedure setreadonly(const index: integer; const avalue: boolean);
   function getflag1(const index: integer): boolean;
   procedure setflag1(const index: integer; const avalue: boolean);
   function getselected(const index: integer): longword;
   procedure setselected(const index: integer; const avalue: longword);
   function getmerged(const index: integer): longword;
   procedure setmerged(const index: integer; const avalue: longword);
   function getlinecolor(const index: integer): rowstatenumty;
   procedure setlinecolor(const index: integer; const avalue: rowstatenumty);
   function getlinecolorfix(const index: integer): rowstatenumty;
   procedure setlinecolorfix(const index: integer; const avalue: rowstatenumty);
   function getcolorar: integerarty;
   procedure setcolorar(const avalue: integerarty);
   function getfontar: integerarty;
   procedure setfontar(const avalue: integerarty);
   function getfoldlevelar: integerarty;
   procedure setfoldlevelar(const avalue: integerarty);
   procedure setfoldlevel(const index: integer; const avalue: byte);
   function gethiddenar: longboolarty;
   procedure sethiddenar(const avalue: longboolarty);
   function getfoldissumar: longboolarty;
   procedure setfoldissumar(const avalue: longboolarty);
  protected
   finfolevel: rowinfolevelty;
   procedure sethidden(const index: integer; const avalue: boolean); virtual;
   procedure setfoldissum(const index: integer; const avalue: boolean); virtual;
   procedure checkdirty(const arow: integer); virtual;
   function checkwritedata(const filer: tfiler): boolean; override;
   function gethidden(const index: integer): boolean;
   function getfoldlevel(const index: integer): byte;
   function getfoldissum(const index: integer): boolean;
   function getheight(const index: integer): integer;
   function getlinewidth(const index: integer): integer;
   procedure checkinfolevel(const wantedlevel: rowinfolevelty);
   procedure change(const aindex: integer); override;
   procedure initdirty; virtual;
   procedure recalchidden; virtual;
   function checkassigncompatibility(const source: tpersistent): boolean; override;
   procedure readstate(const reader; const acount: integer); override;
   property flag1[const index: integer]: boolean read getflag1
                                                            write setflag1;
  public
   constructor create; overload; override;
   constructor create(const ainfolevel: rowinfolevelty); overload;
   procedure assign(source: tpersistent); override;
   property infolevel: rowinfolevelty read finfolevel;
//   procedure assign(source: tpersistent); override;
   function datatype: listdatatypety; override;
   function datapocolmerge: pointer;
   function dataporowheight: pointer;
   function getitempo(const index: integer): prowstatety;
   function getitempocolmerge(const index: integer): prowstatecolmergety;
   function getitemporowheight(const index: integer): prowstaterowheightty;
   property items[const index: integer]: rowstatety read getrowstate 
                                              write setrowstate; default;
   property itemscolmerge[const index: integer]: rowstatecolmergety
            read getrowstatecolmerge write setrowstatecolmerge;
   property itemsrowheight[const index: integer]: rowstaterowheightty
            read getrowstaterowheight write setrowstaterowheight;

   function mergecols(const arow: integer; const astart: longword;
                                 const acount: longword): boolean;
   function unmergecols(const arow: integer): boolean;

   property color[const index: integer]: rowstatenumty read getcolor
                                                            write setcolor;
   property colorar: integerarty read getcolorar write setcolorar;
   property font[const index: integer]: rowstatenumty read getfont
                                                            write setfont;
   property fontar: integerarty read getfontar write setfontar;
   property readonly[const index: integer]: boolean read getreadonly
                                                            write setreadonly;
   property selected[const index: integer]: longword read getselected 
                                                            write setselected;
   property hidden[const index: integer]: boolean read gethidden write sethidden;
   property hiddenar: longboolarty read gethiddenar write sethiddenar;
   property foldlevel[const index: integer]: byte read getfoldlevel 
                                                 write setfoldlevel; //0..64
   property foldlevelar: integerarty read getfoldlevelar write setfoldlevelar;
   property foldissum[const index: integer]: boolean read getfoldissum 
                                                 write setfoldissum;
   property foldissumar: longboolarty read getfoldissumar write setfoldissumar;

   property height[const index: integer]: integer read getheight;
   property merged[const index: integer]: longword read getmerged 
                                                            write setmerged;
   property linewidth[const index: integer]: integer 
                                  read getlinewidth{ write setlineheight};
   property linecolorfix[const index: integer]: rowstatenumty 
                                  read getlinecolorfix write setlinecolorfix;
   property linecolor[const index: integer]: rowstatenumty 
                                  read getlinecolor write setlinecolor;
   property foldinfoar: bytearty read getfoldinfoar;
 end;

 createobjecteventty = procedure(const sender: tobject; var obj: tobject) of object;

 tobjectdatalist = class(tdynamicpointerdatalist)
  private
   foncreateobject: createobjecteventty;
   function Getitems(index: integer): tobject;
   procedure setitems(index: integer; const Value: tobject);
  protected
   fitemclass: tclass;
   function checkassigncompatibility(
                            const source: tpersistent): boolean; override;
   procedure checkitemclass(const aitem: tobject);
   procedure freedata(var data); override;
   procedure copyinstance(var data); override;
   procedure initinstance(var data); override;
   procedure docreateobject(var instance: tobject); virtual;
  public
   constructor create; overload; override;
   function add(const aitem: tobject): integer;
   function extract(const index: integer): tobject; //no finalize
   property oncreateobject: createobjecteventty read foncreateobject write foncreateobject;
   property items[index: integer]: tobject read Getitems write setitems; default;
 end;

 datalistclassty = class of tdatalist;

type
 indexcomparety = function(item1,item2: pointer): integer of object;

 tlinindexmse = class(tlist)
  private
   fcomparefunc: indexcomparety;
   fsortvalid: boolean;
   fsortnums: integerarty;
   procedure Setcomparefunc(const Value: indexcomparety);
   procedure QuickSort(L, R: Integer);
  public
   procedure reindex;
   function find(key: pointer; nearest: boolean): integer;
   function insert(value: pointer): integer; overload;
   property comparefunc: indexcomparety read Fcomparefunc write Setcomparefunc;
 end;

 stringsortmodety = (sms_none,sms_upascii,sms_up,sms_upi);

function firstitem(const source: stringarty): string; overload;
function firstitem(const source: msestringarty): msestring; overload;

procedure additem(var dest: stringarty; const value: string;
                             var count: integer; step: integer = 32); overload;
procedure additem(var dest: msestringarty; const value: msestring;
                             var count: integer; step: integer = 32); overload;
procedure additem(var dest: lstringarty; const value: lstringty;
                             var count: integer; step: integer = 32); overload;
procedure additem(var dest: lmsestringarty; const value: lmsestringty;
                             var count: integer; step: integer = 32); overload;
procedure additem(var dest: integerarty; const value: integer;
                             var count: integer; step: integer = 32); overload;
procedure additem(var dest: realarty; const value: real;
                             var count: integer; step: integer = 32); overload;
procedure additem(var dest: pointerarty; const value: pointer;
                             var count: integer; step: integer = 32); overload;
{$ifndef FPC}
procedure addpointeritem(var dest: pointerarty; const value: pointer;
                             var count: integer; step: integer = 32);
{$endif}
procedure additem(var dest: winidarty; const value: winidty;
                             var count: integer; step: integer = 32); overload;

function incrementarraylength(var value: pointer; typeinfo: pdynarraytypeinfo;
                             increment: integer = 1): sizeint; overload;
  //returns new length
function additem(var value; const typeinfo: pdynarraytypeinfo; 
                                  //typeinfo of dynarray
                var count: integer; step: integer = 32): integer; overload;
  //value = array of type, returns index of new item
procedure deleteitem(var value; const typeinfo: pdynarraytypeinfo;
                          const aindex: integer); overload;
  //value = array of type which needs no finalize
procedure arrayaddref(var dynamicarray);
procedure arraydecref(var dynamicarray); 
                 //no finalize and freemem if refcount = 0
procedure allocuninitedarray(count,itemsize: integer; out dynamicarray);
                 //does not init memory, dynamicarray must be nil!
function arrayrefcount(var dynamicarray): sizeint;

procedure additem(var dest: stringarty; const value: string); overload;
procedure additem(var dest: msestringarty; const value: msestring); overload;
procedure additem(var dest: integerarty; const value: integer); overload;
procedure additem(var dest: longboolarty; const value: longbool); overload;
procedure additem(var dest: booleanarty; const value: boolean); overload;
procedure additem(var dest: realarty; const value: real); overload;
procedure additem(var dest: pointerarty; const value: pointer); overload;
procedure additem(var dest: winidarty; const value: winidty); overload;
procedure deleteitem(var dest: stringarty; index: integer); overload;
procedure deleteitem(var dest: msestringarty; index: integer); overload;
procedure deleteitem(var dest: integerarty; index: integer); overload;
procedure deleteitem(var dest: realarty; index: integer); overload;
procedure deleteitem(var dest: complexarty; index: integer); overload;
procedure deleteitem(var dest: pointerarty; index: integer); overload;
procedure deleteitem(var dest: winidarty; index: integer); overload;
procedure insertitem(var dest: integerarty; index: integer; value: integer); overload;
procedure insertitem(var dest: realarty; index: integer; value: realty); overload;
procedure insertitem(var dest: complexarty; index: integer;
                                                value: complexty); overload;
procedure insertitem(var dest: pointerarty; index: integer; value: pointer); overload;
procedure insertitem(var dest: winidarty; index: integer; value: winidty); overload;
procedure insertitem(var dest: stringarty; index: integer; value: string); overload;
procedure insertitem(var dest: msestringarty; index: integer; value: msestring); overload;

procedure removeitems(var dest: pointerarty; const aitem: pointer);
                            //removes all matching items
function removeitem(var dest: pointerarty; const aitem: pointer): integer;
                                                overload;
                            //returns removed index, -1 if none
                            
function finditem(const ar: pointerarty; const aitem: pointer): integer;
                                                overload;
                           //-1 if none
procedure moveitem(var dest: pointerarty; const sourceindex: integer;
                       destindex: integer); overload;

function removeitem(var dest: stringarty; const aitem: string): integer;
                                            overload;
                        //returns removed index, -1 if none
function finditem(const ar: stringarty; const aitem: string): integer;
                                                overload;
                           //-1 if none
procedure moveitem(var dest: stringarty; const sourceindex: integer;
                       destindex: integer); overload;

function removeitem(var dest: msestringarty; const aitem: msestring): integer;
                                            overload;
                        //returns removed index, -1 if none
function finditem(const ar: msestringarty; const aitem: msestring): integer;
                                                overload;
                           //-1 if none
procedure moveitem(var dest: msestringarty; const sourceindex: integer;
                       destindex: integer); overload;


function removeitem(var dest: integerarty; const aitem: integer): integer;
                                            overload;
                        //returns removed index, -1 if none
function finditem(const ar: integerarty; const aitem: integer): integer;
                                            overload; //-1 if none  
procedure moveitem(var dest: integerarty; const sourceindex: integer;
                       destindex: integer); overload;

function adduniqueitem(var dest: pointerarty; const value: pointer): integer;
                        //returns index

function isequalarray(const a: integerarty; const b: integerarty): boolean;

procedure minmax(const ar: realarty; out minval,maxval: realty);

function stackarfunc(const ar1,ar2: integerarty): integerarty;
procedure stackarray(const source: stringarty; var dest: stringarty); overload;
procedure stackarray(const source: msestringarty; var dest: msestringarty); overload;
procedure stackarray(const source: integerarty; var dest: integerarty); overload;
procedure stackarray(const source: pointerarty; var dest: pointerarty); overload;
procedure stackarray(const source: winidarty; var dest: winidarty); overload;
procedure stackarray(const source: realarty; var dest: realarty); overload;
procedure insertarray(const source: integerarty; var dest: integerarty); overload;
procedure insertarray(const source: realarty; var dest: realarty); overload;
function reversearray(const source: msestringarty): msestringarty; overload;
function reversearray(const source: integerarty): integerarty; overload;
function reversearray(const source: pointerarty): pointerarty; overload;
procedure removearrayduplicates(var value: pointerarty);
function packarray(source: pointerarty): pointerarty; overload;
               //remove nil items
function packarray(source: msestringarty): msestringarty; overload;
               //remove '' items

procedure checkarrayindex(const value; const index: integer);
          //value = dynamic array, exception bei ungueltigem index

function comparepointer(const l,r): integer;
function compareinteger(const l,r): integer;
function compareint64(const l,r): integer;
function comparerealty(const l,r): integer;
function compareasciistring(const l,r): integer;
function compareiasciistring(const l,r): integer;
function compareansistring(const l,r): integer;
function compareiansistring(const l,r): integer;
function comparemsestring(const l,r): integer;
function compareimsestring(const l,r): integer;

function findarrayvalue(const item; const items; const count: integer;
               compare: arraysortcomparety; size: integer;
               out foundindex: integer): boolean; overload;
function findarrayvalue(const item; const items; const index: integerarty;
               compare: arraysortcomparety; size: integer;
               out foundindex: integer): boolean; overload;
           //true if exact else next bigger
           //for compare: l is item, r are tablevalues
           //array must be sorted
procedure quicksortarray(var asortlist; const acompare: arraysortcomparety;
                            asize,alength: integer; order: boolean;
                            out aindexlist: integerarty);
                            //asortlist = array of type

function findarrayitem(const item; const ar;
               compare: arraysortcomparety; size: integer;
               out foundindex: integer): boolean;
           //ar = sorted array of type
           //true if exact else next bigger
           //for compare: l is item, r are tablevalues
procedure sortarray(var sortlist; compare: arraysortcomparety;
                             size: integer); overload;
         //sortlist = array of type
procedure sortarray(var sortlist; compare: arraysortcomparety;
                             size: integer; out indexlist: integerarty); overload;
         //sortlist = array of type
procedure sortarray(var dest: pointerarty; compare: arraysortcomparety); overload;
procedure sortarray(var dest: pointerarty; compare: arraysortcomparety;
                    out indexlist: integerarty); overload;
procedure sortarray(var dest: pointerarty); overload; //compares adresses
procedure sortarray(var dest: integerarty); overload;
procedure sortarray(var dest: integerarty; out indexlist: integerarty); overload;
procedure sortarray(var dest: longwordarty); overload;
procedure sortarray(var dest: longwordarty; out indexlist: integerarty); overload;
procedure sortarray(var dest: realarty); overload;
procedure sortarray(var dest: realarty; out indexlist: integerarty); overload;

procedure sortarray(var dest: msestringarty; compare: arraysortcomparety); overload;
procedure sortarray(var dest: msestringarty; compare: arraysortcomparety;
                    out indexlist: integerarty); overload;
procedure sortarray(var dest: stringarty; compare: arraysortcomparety); overload;
procedure sortarray(var dest: stringarty; compare: arraysortcomparety;
                    out indexlist: integerarty); overload;

procedure sortarray(var dest: msestringarty; sortmode: stringsortmodety = sms_up); overload;
procedure sortarray(var dest: msestringarty;
         sortmode: stringsortmodety; out indexlist: integerarty); overload;
procedure sortarray(var dest: stringarty; sortmode: stringsortmodety = sms_upascii); overload;
procedure sortarray(var dest: stringarty;
         sortmode: stringsortmodety; out indexlist: integerarty); overload;

procedure orderarray(const sourceorderlist: integerarty; var sortlist; size: integer); overload;
         //sortlist = array of type
procedure orderarray(const sourceorderlist: integerarty; 
                             var sortlist: pointerarty); overload;
procedure orderarray(const sourceorderlist: integerarty; 
                             var sortlist: integerarty); overload;
procedure orderarray(const sourceorderlist: integerarty;
                             var sortlist: msestringarty); overload;
procedure orderarray(const sourceorderlist: integerarty;
                             var sortlist: stringarty); overload;
                             
procedure reorderarray(const destorderlist: integerarty; 
                             var sortlist; size: integer); overload;
         //sortlist = array of type
procedure reorderarray(const destorderlist: integerarty; 
                             var sortlist: pointerarty); overload;
procedure reorderarray(const destorderlist: integerarty; 
                             var sortlist: integerarty); overload;
procedure reorderarray(const destorderlist: integerarty; 
                             var sortlist: msestringarty); overload;
procedure reorderarray(const destorderlist: integerarty; 
                             var sortlist: stringarty); overload;

function cmparray(const a,b: msestringarty): boolean;
               //true if equal

function opentodynarraym(const items: array of msestring): msestringarty;
function opentodynarrays(const items: array of string): stringarty;
function opentodynarrayi(const items: array of integer): integerarty;
function opentodynarrayr(const items: array of realty): realarty;
function opentodynarraybo(const items: array of boolean): booleanarty;
function opentodynarrayby(const items: array of byte): bytearty;

function datalisttocomplexar(const re,im: trealdatalist): complexarty;

procedure readstringar(const reader: treader; out avalue: stringarty);
procedure writestringar(const writer: twriter; const avalue: stringarty);

type
 getintegeritemfuncty = function(const index: integer): integer of object;

function newidentnum(const count: integer;
                                  getfunc: getintegeritemfuncty): integer;
                        //returns lowest not used value
function getdatalistclass(const adatatype: listdatatypety): datalistclassty;
procedure registerdatalistclass(const adatatype: listdatatypety;
                                    const aclass: datalistclassty);

procedure setremotedatalist(const aintf: idatalistclient;
                    const source: tdatalist; var dest: tdatalist);

implementation
uses
 rtlconsts,msestreaming,msesys,msestat,msebits,msefloattostr;

var
 datalistclasses: array[listdatatypety] of datalistclassty =
//dl_none,dl_integer,  dl_int64,      dl_currency,
 (nil,tintegerdatalist,tint64datalist,tcurrencydatalist,
//dl_real,     dl_realint,      dl_realsum
 trealdatalist,trealintdatalist,nil,
//dl_datetime,
 trealdatalist,
//dl_ansistring,      dl_msestring,      dl_doublemsestring,
  tansistringdatalist,tmsestringdatalist,tdoublemsestringdatalist,
//dl_msestringint
  tmsestringintdatalist,
//dl_complex,      dl_rowstate        
  tcomplexdatalist,tcustomrowstatelist,
//dl_custom
  nil);

procedure setremotedatalist(const aintf: idatalistclient;
                    const source: tdatalist; var dest: tdatalist);
begin
 aintf.getobjectlinker.setlinkedvar(aintf,source,tlinkedpersistent(dest),
                                               typeinfo(idatalistclient));
 if dest <> nil then begin
  include(dest.fstate,dls_remote);
 end;
 if dest <> nil then begin
  aintf.itemchanged(dest,-1);
 end;
end;

function getdatalistclass(const adatatype: listdatatypety): datalistclassty;
begin
 if adatatype <= high(datalistclasses) then begin
  result:= datalistclasses[adatatype];
 end
 else begin
  result:= nil;
 end;
end;

procedure registerdatalistclass(const adatatype: listdatatypety;
                                    const aclass: datalistclassty);
begin
 if adatatype > high(datalistclasses) then begin
  raise exception.create('Invalid datalist class.');
 end;
 datalistclasses[adatatype]:= aclass;
end;

function opentodynarraym(const items: array of msestring): msestringarty;
var
 int1: integer;
begin
 setlength(result,length(items));
 for int1:= 0 to high(items) do begin
  result[int1]:= items[int1];
 end;
end;

function opentodynarrays(const items: array of string): stringarty;
var
 int1: integer;
begin
 setlength(result,length(items));
 for int1:= 0 to high(items) do begin
  result[int1]:= items[int1];
 end;
end;

function opentodynarrayi(const items: array of integer): integerarty;
var
 int1: integer;
begin
 setlength(result,length(items));
 for int1:= 0 to high(items) do begin
  result[int1]:= items[int1];
 end;
end;

function opentodynarrayr(const items: array of realty): realarty;
var
 int1: integer;
begin
 setlength(result,length(items));
 for int1:= 0 to high(items) do begin
  result[int1]:= items[int1];
 end;
end;

function opentodynarraybo(const items: array of boolean): booleanarty;
var
 int1: integer;
begin
 setlength(result,length(items));
 for int1:= 0 to high(items) do begin
  result[int1]:= items[int1];
 end;
end;

function opentodynarrayby(const items: array of byte): bytearty;
var
 int1: integer;
begin
 setlength(result,length(items));
 for int1:= 0 to high(items) do begin
  result[int1]:= items[int1];
 end;
end;

function datalisttocomplexar(const re,im: trealdatalist): complexarty;
var
 int1: integer;
 pre,pim: preal;
 pres: pcomplexty;
 intre,intim: integer;
begin
 int1:= re.count;
 if im.count < int1 then begin
  int1:= im.count;
 end;
 setlength(result,int1);
 pre:= re.datapo;
 intre:= re.size;
 pim:= im.datapo;
 intim:= im.size;
 pres:= pointer(result);
 for int1:= high(result) downto 0 do begin
  pres^.re:= pre^;
  pres^.im:= pim^;
  inc(pchar(pre),intre);
  inc(pchar(pim),intim);
  inc(pchar(pres),sizeof(complexty));
 end;
end;

procedure readstringar(const reader: treader; out avalue: stringarty);
var
 int1: integer;
begin
 reader.readlistbegin;
 int1:= 0;
 while not reader.endoflist do begin
  additem(avalue,reader.readstring,int1);
 end;
 reader.readlistend;
 setlength(avalue,int1);
end;

procedure writestringar(const writer: twriter; const avalue: stringarty);
var
 int1: integer;
begin
 writer.writelistbegin;
 for int1:= 0 to high(avalue) do begin
  writer.writestring(avalue[int1]);
 end;
 writer.writelistend;
end;

function newidentnum(const count: integer; getfunc: getintegeritemfuncty): integer;
var
 list1: tintegerdatalist;
 int1: integer;
begin
 list1:= tintegerdatalist.create;
 try
  list1.count:= count;
  for int1:= 0 to count - 1 do begin
   list1[int1]:= getfunc(int1);
  end;
  list1.sort;
  for int1:= 0 to count -1 do begin
   if list1[int1] > int1 then begin
    result:= int1;
    exit;
   end;
  end;
  result:= count;
 finally
  list1.Free;
 end;
end;

procedure variantsnotsupported;
begin
 raise exception.create('Variants not supported');
end;

function DynArraySize(a: Pointer): sizeint;
{$ifdef FPC}
begin
 result:= length(bytearty(a));
end;
{$else}
asm
        TEST EAX, EAX
        JZ   @@exit
        MOV  EAX, [EAX-4]
@@exit:
end;
{$endif}

function incrementarraylength(var value: pointer; typeinfo: pdynarraytypeinfo;
                  increment: integer = 1): sizeint;
  //returns new length
begin
 result:= dynarraysize(value) + increment;
 dynarraysetlength(value,typeinfo,1,@result);
end;

function dynarrayelesize(const typinfo: pdynarraytypeinfo): sizeint;
var
 ti: pdynarraytypeinfo;
begin
 ti:= typinfo;
{$ifdef FPC}
 inc(pchar(ti),ord(ti^.namelen));
 result:= ti^.elesize;
{$else}
 inc(pchar(ti),length(ti^.name));
 result:= ti^.elsize;
{$endif}
end;

function decrementarraylength(var value: pointer; const typeinfo: pdynarraytypeinfo;
                      decrement: integer = 1): sizeint;
  //returns new length
begin
 result:= dynarraysize(value) - decrement;
 dynarraysetlength(value,typeinfo,1,@result);
end;

function additem(var value; const typeinfo: pdynarraytypeinfo;
                             var count: integer; step: integer = 32): integer;
var
 int1: integer;
begin
 int1:= high(pointerarty(value)) + 1;
 if int1 <= count then begin
  incrementarraylength(pointer(value),typeinfo,2*count+step);
//  incrementarraylength(pointer(value),typeinfo,count-int1+step);
 end;
 result:= count;
 inc(count);
end;

procedure deleteitem(var value; const typeinfo: pdynarraytypeinfo;
                         const aindex: integer);
  //value = array of type which needs no finalize
var
 int1: integer;
begin
 int1:= dynarrayelesize(pdynarraytypeinfo(typeinfo));
 move((pchar(value)+int1*(aindex+1))^,(pchar(value)+int1*aindex)^,
             int1*(high(bytearty(value))-aindex));
 decrementarraylength(pointer(value),typeinfo);
end;

procedure arrayaddref(var dynamicarray);
var
 refpo: psizeint;
begin
 if pointer(dynamicarray) <> nil then begin
  refpo:= psizeint(pchar(dynamicarray)-2*sizeof(sizeint));
  if refpo^ >= 0 then begin
   {$ifdef CPU64}
   interlockedincrement64(refpo^);
   {$else}
   interlockedincrement(refpo^);
   {$endif}
  end;
 end;
end;

function arrayrefcount(var dynamicarray): sizeint;
begin
 result:= 0;
 if pointer(dynamicarray) <> nil then begin
  result:= psizeint(pchar(dynamicarray)-2*sizeof(sizeint))^;
 end;
end;

procedure arraydecref(var dynamicarray);
var
 refpo: psizeint;
begin
 if pointer(dynamicarray) <> nil then begin
  refpo:= psizeint(pchar(dynamicarray)-2*sizeof(sizeint));
  if refpo^ > 0 then begin
  {$ifdef CPU64}
   interlockeddecrement64(refpo^);
  {$else}
   interlockeddecrement(refpo^);
  {$endif}
  end;
 end;
end;

procedure allocuninitedarray(count,itemsize: integer; out dynamicarray);
                 //does not init memory, dynamicarray has to be nil!
var
 po1: psizeint;
begin
 if pointer(dynamicarray) <> nil then begin
  raise exception.Create('allocunitedarray: dynamicarray not nil');
 end;
 getmem(po1,count * itemsize + 2 * sizeof(sizeint));
 po1^:= 1; //refcount
 {$ifdef FPC}
 psizeint(pchar(po1)+sizeof(sizeint))^:= count - 1; //high
 {$else}
 psizeint(pchar(po1)+sizeof(sizeint))^:= count;     //count
 {$endif}
 pointer(dynamicarray):= pointer(pchar(po1) + 2 * sizeof(sizeint));
end;

function firstitem(const source: stringarty): string; overload;
begin
 if length(source) > 0 then begin
  result:= source[0];
 end
 else begin
  result:= '';
 end;
end;

function firstitem(const source: msestringarty): msestring; overload;
begin
 if length(source) > 0 then begin
  result:= source[0];
 end
 else begin
  result:= '';
 end;
end;

procedure additem(var dest: stringarty; const value: string;
                             var count: integer; step: integer = 32);
begin
 if length(dest) <= count then begin
  setlength(dest,count+step+2*length(dest));
 end;
 dest[count]:= value;
 inc(count);
end;

procedure additem(var dest: msestringarty; const value: msestring;
                             var count: integer; step: integer = 32);
begin
 if length(dest) <= count then begin
  setlength(dest,count+step+2*length(dest));
 end;
 dest[count]:= value;
 inc(count);
end;

procedure additem(var dest: lstringarty; const value: lstringty;
                             var count: integer; step: integer = 32);
begin
 if length(dest) <= count then begin
  setlength(dest,count+step+2*length(dest));
 end;
 dest[count]:= value;
 inc(count);
end;

procedure additem(var dest: lmsestringarty; const value: lmsestringty;
                             var count: integer; step: integer = 32);
begin
 if length(dest) <= count then begin
  setlength(dest,count+step+2*length(dest));
 end;
 dest[count]:= value;
 inc(count);
end;

procedure additem(var dest: integerarty; const value: integer;
                             var count: integer; step: integer = 32);
begin
 if length(dest) <= count then begin
  setlength(dest,count+step+2*length(dest));
 end;
 dest[count]:= value;
 inc(count);
end;

procedure additem(var dest: realarty; const value: real;
                             var count: integer; step: integer = 32);
begin
 if length(dest) <= count then begin
  setlength(dest,count+step+2*length(dest));
 end;
 dest[count]:= value;
 inc(count);
end;

procedure additem(var dest: pointerarty; const value: pointer;
                             var count: integer; step: integer = 32);
begin
 if length(dest) <= count then begin
  setlength(dest,count+step+2*length(dest));
 end;
 dest[count]:= value;
 inc(count);
end;

{$ifndef FPC}
procedure addpointeritem(var dest: pointerarty; const value: pointer;
                             var count: integer; step: integer = 32);
begin
 if length(dest) <= count then begin
  setlength(dest,count+step+2*length(dest));
 end;
 dest[count]:= value;
 inc(count);
end;
{$endif}

procedure additem(var dest: winidarty; const value: winidty;
                             var count: integer; step: integer = 32);
begin
 if length(dest) <= count then begin
  setlength(dest,count+step+2*length(dest));
 end;
 dest[count]:= value;
 inc(count);
end;

procedure additem(var dest: stringarty; const value: string);
begin
 setlength(dest,high(dest)+2);
 dest[high(dest)]:= value;
end;

procedure additem(var dest: msestringarty; const value: msestring);
begin
 setlength(dest,high(dest)+2);
 dest[high(dest)]:= value;
end;

procedure additem(var dest: integerarty; const value: integer);
begin
 setlength(dest,high(dest)+2);
 dest[high(dest)]:= value;
end;

procedure additem(var dest: longboolarty; const value: longbool);
begin
 setlength(dest,high(dest)+2);
 dest[high(dest)]:= value;
end;

procedure additem(var dest: booleanarty; const value: boolean);
begin
 setlength(dest,high(dest)+2);
 dest[high(dest)]:= value;
end;

procedure additem(var dest: realarty; const value: real);
begin
 setlength(dest,high(dest)+2);
 dest[high(dest)]:= value;
end;

procedure additem(var dest: pointerarty; const value: pointer);
begin
 setlength(dest,high(dest)+2);
 dest[high(dest)]:= value;
end;

procedure additem(var dest: winidarty; const value: winidty);
begin
 setlength(dest,high(dest)+2);
 dest[high(dest)]:= value;
end;

procedure deleteitem(var dest: stringarty; index: integer);
begin
 if (index < 0) or (index > high(dest)) then begin
  tlist.Error(SListIndexError, Index);
 end;
 dest[index]:= '';
 move(dest[index+1],dest[index],sizeof(dest[0])*(high(dest)-index));
 pointer(dest[high(dest)]):= nil;
 setlength(dest,high(dest));
end;

procedure deleteitem(var dest: msestringarty; index: integer);
begin
 if (index < 0) or (index > high(dest)) then begin
  tlist.Error(SListIndexError, Index);
 end;
 dest[index]:= '';
 move(dest[index+1],dest[index],sizeof(dest[0])*(high(dest)-index));
 pointer(dest[high(dest)]):= nil;
 setlength(dest,high(dest));
end;

procedure deleteitem(var dest: integerarty; index: integer);
begin
 if (index < 0) or (index > high(dest)) then begin
  tlist.Error(SListIndexError, Index);
 end;
 move(dest[index+1],dest[index],sizeof(dest[0])*(high(dest)-index));
 setlength(dest,high(dest));
end;

procedure deleteitem(var dest: realarty; index: integer);
begin
 if (index < 0) or (index > high(dest)) then begin
  tlist.Error(SListIndexError, Index);
 end;
 move(dest[index+1],dest[index],sizeof(dest[0])*(high(dest)-index));
 setlength(dest,high(dest));
end;

procedure deleteitem(var dest: complexarty; index: integer);
begin
 if (index < 0) or (index > high(dest)) then begin
  tlist.Error(SListIndexError, Index);
 end;
 move(dest[index+1],dest[index],sizeof(dest[0])*(high(dest)-index));
 setlength(dest,high(dest));
end;

procedure deleteitem(var dest: pointerarty; index: integer);
begin
 if (index < 0) or (index > high(dest)) then begin
  tlist.Error(SListIndexError, Index);
 end;
 move(dest[index+1],dest[index],sizeof(dest[0])*(high(dest)-index));
 setlength(dest,high(dest));
end;

procedure deleteitem(var dest: winidarty; index: integer);
begin
 if (index < 0) or (index > high(dest)) then begin
  tlist.Error(SListIndexError, Index);
 end;
 move(dest[index+1],dest[index],sizeof(dest[0])*(high(dest)-index));
 setlength(dest,high(dest));
end;

procedure insertitem(var dest: integerarty; index: integer; value: integer);
begin
 setlength(dest,high(dest) + 2);
 move(dest[index],dest[index+1],(high(dest)-index) * sizeof(dest[0]));
 dest[index]:= value;
end;

procedure insertitem(var dest: realarty; index: integer; value: realty);
begin
 setlength(dest,high(dest) + 2);
 move(dest[index],dest[index+1],(high(dest)-index) * sizeof(dest[0]));
 dest[index]:= value;
end;

procedure insertitem(var dest: complexarty; index: integer; value: complexty);
begin
 setlength(dest,high(dest) + 2);
 move(dest[index],dest[index+1],(high(dest)-index) * sizeof(dest[0]));
 dest[index]:= value;
end;

procedure insertitem(var dest: pointerarty; index: integer; value: pointer);
begin
 setlength(dest,high(dest) + 2);
 move(dest[index],dest[index+1],(high(dest)-index) * sizeof(dest[0]));
 dest[index]:= value;
end;

procedure insertitem(var dest: winidarty; index: integer; value: winidty);
begin
 setlength(dest,high(dest) + 2);
 move(dest[index],dest[index+1],(high(dest)-index) * sizeof(dest[0]));
 dest[index]:= value;
end;

procedure insertitem(var dest: stringarty; index: integer; value: string);
begin
 setlength(dest,high(dest) + 2);
 move(dest[index],dest[index+1],(high(dest)-index) * sizeof(dest[0]));
 pointer(dest[index]):= nil;
 dest[index]:= value;
end;

procedure insertitem(var dest: msestringarty; index: integer; value: msestring);
begin
 setlength(dest,high(dest) + 2);
 move(dest[index],dest[index+1],(high(dest)-index) * sizeof(dest[0]));
 pointer(dest[index]):= nil;
 dest[index]:= value;
end;

procedure removeitems(var dest: pointerarty; const aitem: pointer);
                            //removes all matching items
var
 int1,int2: integer;
 ar1: pointerarty;
begin
 setlength(ar1,length(dest));
 int2:= 0;
 for int1:= 0 to high(dest) do begin
  if dest[int1] <> aitem then begin
   ar1[int2]:= dest[int1];
   inc(int2);
  end;
 end;
 setlength(ar1,int2);
 dest:= ar1;
end;

function removeitem(var dest: pointerarty; const aitem: pointer): integer;
var
 int1: integer;
begin
 result:= -1;
 for int1:= 0 to high(dest) do begin
  if dest[int1] = aitem then begin
   result:= int1;
   deleteitem(dest,int1);
   break;
  end;
 end;
end;

function isequalarray(const a: integerarty; const b: integerarty): boolean;
var
 int1: integer;
 po1,po2: pintegeraty;
begin
 result:= pointer(a) = pointer(b);
 if not result and (high(a) = high(b)) then begin
  po1:= pointer(a);
  po2:= pointer(b);
  for int1:= high(a) downto 0 do begin
   if po1^[int1] <> po2^[int1] then begin
    exit;
   end;
  end;
  result:= true;
 end;
end;

function finditem(const ar: pointerarty; const aitem: pointer): integer;
                           //-1 if none
var
 int1: integer;
begin
 result:= -1;
 for int1:= 0 to high(ar) do begin
  if ar[int1] = aitem then begin
   result:= int1;
   break;
  end;
 end;
end;

procedure moveitem(var dest: pointerarty; const sourceindex: integer;
                              destindex: integer);
var
 po1: pointer;
begin
 po1:= dest[sourceindex];
 deleteitem(dest,sourceindex);
 insertitem(dest,destindex,po1);
end;


function removeitem(var dest: stringarty; const aitem: string): integer;
var
 int1: integer;
begin
 result:= -1;
 for int1:= 0 to high(dest) do begin
  if dest[int1] = aitem then begin
   result:= int1;
   deleteitem(dest,int1);
   break;
  end;
 end;
end;

function finditem(const ar: stringarty; const aitem: string): integer;
                           //-1 if none
var
 int1: integer;
begin
 result:= -1;
 for int1:= 0 to high(ar) do begin
  if ar[int1] = aitem then begin
   result:= int1;
   break;
  end;
 end;
end;

procedure moveitem(var dest: stringarty; const sourceindex: integer;
                              destindex: integer);
var
 po1: string;
begin
 po1:= dest[sourceindex];
 deleteitem(dest,sourceindex);
 insertitem(dest,destindex,po1);
end;

function removeitem(var dest: msestringarty; const aitem: msestring): integer;
var
 int1: integer;
begin
 result:= -1;
 for int1:= 0 to high(dest) do begin
  if dest[int1] = aitem then begin
   result:= int1;
   deleteitem(dest,int1);
   break;
  end;
 end;
end;

function finditem(const ar: msestringarty; const aitem: msestring): integer;
                           //-1 if none
var
 int1: integer;
begin
 result:= -1;
 for int1:= 0 to high(ar) do begin
  if ar[int1] = aitem then begin
   result:= int1;
   break;
  end;
 end;
end;

procedure moveitem(var dest: msestringarty; const sourceindex: integer;
                              destindex: integer);
var
 po1: msestring;
begin
 po1:= dest[sourceindex];
 deleteitem(dest,sourceindex);
 insertitem(dest,destindex,po1);
end;

function removeitem(var dest: integerarty; const aitem: integer): integer;
var
 int1: integer;
begin
 result:= -1;
 for int1:= 0 to high(dest) do begin
  if dest[int1] = aitem then begin
   result:= int1;
   deleteitem(dest,int1);
   break;
  end;
 end;
end;

function finditem(const ar: integerarty; const aitem: integer): integer;
                           //-1 if none
var
 int1: integer;
begin
 result:= -1;
 for int1:= 0 to high(ar) do begin
  if ar[int1] = aitem then begin
   result:= int1;
   break;
  end;
 end;
end;

procedure moveitem(var dest: integerarty; const sourceindex: integer;
                              destindex: integer);
var
 int1: integer;
begin
 int1:= dest[sourceindex];
 deleteitem(dest,sourceindex);
 insertitem(dest,destindex,int1);
end;

function adduniqueitem(var dest: pointerarty; const value: pointer): integer;
                        //returns index
var
 int1: integer;
begin
 for int1:= 0 to high(dest) do begin
  if dest[int1] = value then begin
   result:= int1;
   exit;
  end;
 end;
 result:= high(dest) + 1;
 setlength(dest,result+1);
 dest[result]:= value;
end;

procedure minmax(const ar: realarty; out minval,maxval: realty);
var
 int1: integer;
 min1,max1: realty;
begin
 min1:= bigreal;
 max1:= emptyreal;
 for int1:= high(ar) downto 0 do begin
  if isemptyreal(ar[int1]) then begin
   min1:= ar[int1];
  end
  else begin
   if isemptyreal(max1) or (ar[int1] > max1) then begin
    max1:= ar[int1];
   end;
   if not isemptyreal(min1) and (min1 > ar[int1]) then begin
    min1:= ar[int1];
   end;
  end;
 end;
 minval:= min1;
 maxval:= max1;
end;

function stackarfunc(const ar1,ar2: integerarty): integerarty;
begin
 setlength(result,length(ar1) + length(ar2));
 move(ar1[0],result[0],length(ar1)*sizeof(ar1[0]));
 move(ar2[0],result[length(ar1)],length(ar2)*sizeof(ar2[0]));
end;

procedure stackarray(const source: stringarty; var dest: stringarty);
var
 laengevorher: integer;
 int1: integer;
begin
 laengevorher:= length(dest);
 setlength(dest,laengevorher+length(source));
 for int1:= 0 to high(source) do begin
  dest[laengevorher]:= source[int1];
  inc(laengevorher);
 end;
end;

procedure stackarray(const source: msestringarty; var dest: msestringarty);
var
 laengevorher: integer;
 int1: integer;
begin
 laengevorher:= length(dest);
 setlength(dest,laengevorher+length(source));
 for int1:= 0 to high(source) do begin
  dest[laengevorher]:= source[int1];
  inc(laengevorher);
 end;
end;

procedure stackarray(const source: integerarty; var dest: integerarty);
var
 laengevorher: integer;
begin
 laengevorher:= length(dest);
 setlength(dest,laengevorher+length(source));
 move(source[0],dest[laengevorher],length(source)*sizeof(source[0]));
end;

procedure stackarray(const source: pointerarty; var dest: pointerarty);
var
 laengevorher: integer;
begin
 laengevorher:= length(dest);
 setlength(dest,laengevorher+length(source));
 move(source[0],dest[laengevorher],length(source)*sizeof(source[0]));
end;

procedure stackarray(const source: winidarty; var dest: winidarty);
var
 laengevorher: integer;
begin
 laengevorher:= length(dest);
 setlength(dest,laengevorher+length(source));
 move(source[0],dest[laengevorher],length(source)*sizeof(source[0]));
end;

procedure insertarray(const source: integerarty; var dest: integerarty);
var
 laengevorher: integer;
begin
 laengevorher:= length(dest);
 setlength(dest,laengevorher+length(source));
 move(dest[0],dest[length(source)],laengevorher*sizeof(dest[0]));
 move(source[0],dest[0],length(source)*sizeof(source[0]));
end;

procedure stackarray(const source: realarty; var dest: realarty);
var
 laengevorher: integer;
begin
 laengevorher:= length(dest);
 setlength(dest,laengevorher+length(source));
 move(source[0],dest[laengevorher],length(source)*sizeof(source[0]));
end;

procedure insertarray(const source: realarty; var dest: realarty);
var
 laengevorher: integer;
begin
 laengevorher:= length(dest);
 setlength(dest,laengevorher+length(source));
 move(dest[0],dest[length(source)],laengevorher*sizeof(dest[0]));
 move(source[0],dest[0],length(source)*sizeof(source[0]));
end;

function reversearray(const source: msestringarty): msestringarty;
var
 ar1: msestringarty;
 int1,int2: integer;
begin
 if pointer(source) = pointer(result) then begin
  ar1:= copy(source);
 end
 else begin
  ar1:= source;
 end;
 int2:= high(source);
 setlength(result,int2+1);
 for int1:= 0 to int2 do begin
  result[int1]:= source[int2];
  dec(int2);
 end;
end;

function reversearray(const source: integerarty): integerarty; overload;
var
 ar1: integerarty;
 int1,int2: integer;
begin
 if pointer(source) = pointer(result) then begin
  ar1:= copy(source);
 end
 else begin
  ar1:= source;
 end;
 int2:= high(source);
 setlength(result,int2+1);
 for int1:= 0 to int2 do begin
  result[int1]:= source[int2];
  dec(int2);
 end;
end;

function reversearray(const source: pointerarty): pointerarty; overload;
var
 ar1: pointerarty;
 int1,int2: integer;
begin
 if pointer(source) = pointer(result) then begin
  ar1:= copy(source);
 end
 else begin
  ar1:= source;
 end;
 int2:= high(source);
 setlength(result,int2+1);
 for int1:= 0 to int2 do begin
  result[int1]:= source[int2];
  dec(int2);
 end;
end;

procedure removearrayduplicates(var value: pointerarty);
var
 int1,int2: integer;
begin
 for int1:= 0 to high(value) do begin //remove duplicates
  if value[int1] <> nil then begin
   for int2:= int1 + 1 to high(value) do begin
    if value[int2] = value[int1] then begin
     value[int2]:= nil
    end;
   end;
  end;
 end;
 int2:= 0;
 for int1:= 0 to high(value) do begin
  if value[int1] <> nil then begin
   value[int2]:= value[int1];
   inc(int2);
  end;
 end;
 setlength(value,int2);
end;

function packarray(source: pointerarty): pointerarty; //removes nil items
var
 int1,int2: integer;
begin
 setlength(result,length(source));
 int2:= 0;
 for int1:= 0 to high(source) do begin
  result[int2]:= source[int1];
  if source[int1] <> nil then begin
   inc(int2);
  end;
 end;
 setlength(result,int2);
end;

function packarray(source: msestringarty): msestringarty;
var
 int1,int2: integer;
begin
 setlength(result,length(source));
 int2:= 0;
 for int1:= 0 to high(source) do begin
  result[int2]:= source[int1];
  if source[int1] <> '' then begin
   inc(int2);
  end;
 end;
 setlength(result,int2);
end;

procedure checkarrayindex(const value; const index: integer);
          //value = dynamic array, exception bei ungueltigem index
begin
 if (index < 0) or (index > high(bytearty(value))) then begin
  raise exception.Create('Invalid arrayindex: '+inttostr(index)+ ' max: ' + 
                   inttostr(high(bytearty(value)))+'.');
 end;
end;

type
 sortinfoty = record
  indexlist: integerarty;
  sortlist: pchar;
  compare: arraysortcomparety;
  size: integer;
 end;
 
function findarrayvalue(const item; const items; const count: integer;
               compare: arraysortcomparety; size: integer;
               out foundindex: integer): boolean;
           //true if exact else next bigger
           //for compare: l is item, r are tablevalues
var
 ilo,ihi:integer;
 int1,int2: integer;
// bo1: boolean;
begin
 foundindex:= count;
 result:= false;
 if foundindex > 0 then begin
  ilo:= 0;
  ihi:= foundindex - 1;
//  bo1:= false;
  while true do begin
   int1:= (ilo + ihi) div 2;
   int2:= compare(item,(pchar(items)+int1*size)^);
    if int2 >= 0 then begin //item <= pivot
     if int2 = 0 then begin
      result:= true; //found
     end;
     if ihi = ilo then begin
      foundindex:= ihi + 1;
      break;
     end;
     if ilo = int1 then begin
      inc(ilo);
     end
     else begin
      ilo:= int1;
     end;
    end
    else begin            //item > pivot
     if ihi = ilo then begin
      foundindex:= ihi;
      break;
     end;
     ihi:= int1;
   end;
  end;
  if result then begin
   dec(foundindex);
  end;
 end;
end;

function findarrayitem(const item; const ar;
               compare: arraysortcomparety; size: integer;
               out foundindex: integer): boolean;
           //ar = array of type
           //true if exact else next bigger
           //for compare: l is item, r are tablevalues
begin
 result:= findarrayvalue(item,ar,length(pointerarty(ar)),compare,size,foundindex);
end;

function findarrayvalue(const item; const items; const index: integerarty;
               compare: arraysortcomparety; size: integer;
               out foundindex: integer): boolean;
           //true if exact else next bigger
           //for compare: l is item, r are tablevalues
var
 ilo,ihi:integer;
 int1,int2: integer;
// bo1: boolean;
begin
 foundindex:= length(index);
 result:= false;
 if foundindex > 0 then begin
  ilo:= 0;
  ihi:= foundindex - 1;
//  bo1:= false;
  while true do begin
   int1:= (ilo + ihi) div 2;
   int2:= compare(item,(pchar(items)+index[int1]*size)^);
   if int2 >= 0 then begin //item <= pivot
    if int2 = 0 then begin
     result:= true; //found
    end;
    if ihi = ilo then begin
     foundindex:= ihi + 1;
     break;
    end;
    if ilo = int1 then begin
     inc(ilo);
    end
    else begin
     ilo:= int1;
    end;
   end
   else begin            //item > pivot
    if ihi = ilo then begin
     foundindex:= ihi;
     break;
    end;
    ihi:= int1;
   end;
  end;
  if result then begin
   dec(foundindex);
  end;
 end;
end;

function comparepointer(const l,r): integer;
var
 pint1: ptrint;
begin
 result:= 1;
 pint1:= ptrint(l) - ptrint(r);
 if pint1 < 0 then begin
  result:= -1
 end
 else begin
  if pint1 = 0 then begin
   result:= 0;
  end;
 end;
end;

function compareinteger(const l,r): integer;
begin
 result:= integer(l) - integer(r);
end;

function compareint64(const l,r): integer;
begin
 result:= int64(l) - int64(r);
end;

procedure doquicksortarray(var info: sortinfoty; l, r: Integer);
var
  i, j: Integer;
  p: integer;
  int1: integer;
begin
 with info do begin
  repeat
   i := l;
   j := r;
   p := (l + r) shr 1;
   repeat
    repeat
     int1:= compare((sortlist + indexlist[i] *size)^,(sortlist + indexlist[p] *size)^);
     if int1 = 0 then begin
      int1:= indexlist[i]-indexlist[p];
     end;
     if int1 >= 0 then break;
     inc(i);
    until false;
    repeat
     int1:= compare((sortlist + indexlist[j] *size)^,(sortlist + indexlist[p] *size)^);
     if int1 = 0 then begin
      int1:= indexlist[j]-indexlist[p];
     end;
     if int1 <= 0 then break;
     dec(j);
    until false;
    if i <= j then  begin
     int1:= indexlist[i];
     indexlist[i]:= indexlist[j];
     indexlist[j]:= int1;
     if p = i then begin
      p := j
     end
     else begin
      if p = j then begin
       p := i;
      end;
     end;
     Inc(i);
     Dec(j);
    end;
   until i > j;
   if l < j then begin
    doquickSortarray(info,l, j);
   end;
   l := i;
  until i >= r;
 end;
end;

procedure quicksortarray(var asortlist; const acompare: arraysortcomparety;
                            asize,alength: integer; order: boolean;
                            out aindexlist: integerarty);
                            //asortlist = array of type
var
 info: sortinfoty;
 int1: integer;
 
begin
 if alength > 0 then begin
  setlength(aindexlist,alength);
  dec(alength);
  for int1:= 0 to alength do begin
   aindexlist[int1]:= int1;
  end;
  with info do begin
   indexlist:= aindexlist;
   sortlist:= pointer(asortlist);
   compare:= acompare;
   size:= asize;
  end;
  doquicksortarray(info,0,alength);
  if order then begin
   orderarray(aindexlist,asortlist,asize);
  end;
 end;
end;

const
 adsize = 2*sizeof(sizeint);

function initorderbuffer(var sortlist; const size: integer; clear: boolean;
                             out destpo: pchar): boolean;
begin
 if pointer(sortlist) = nil then begin
  result:= false;
 end
 else begin
  getmem(destpo,size*length(bytearty(sortlist))+adsize);
  psizeint(destpo)^:= 1; //refcount
  inc(destpo,sizeof(sizeint));
  psizeint(destpo)^:= pinteger(pchar(sortlist)-sizeof(sizeint))^; //length or high
  inc(destpo,sizeof(sizeint));
  result:= true;
  if clear then begin
   fillchar(destpo^,size*length(bytearty(sortlist)),0);
  end;
 end;
end;

procedure storebuffer(const asource: pchar; var sortlist);
var
 po1: psizeint;
begin
 po1:= psizeint(pchar(sortlist) - 2*sizeof(sizeint));
 dec(po1^);
 if po1^ >= 0 then begin
  if po1^ = 0 then begin
   freemem(po1);
  end
 end
 else begin
  inc(po1^) //constant
 end;
 pointer(sortlist):= asource;
end;

procedure orderarray(const sourceorderlist: integerarty; var sortlist; size: integer);
         //sortlist = array of type
var
 po2: pchar;
 po3: pchar;
 int1: integer;
begin
 if initorderbuffer(sortlist,size,false,po2) then begin
  po3:= po2;
  for int1:= 0 to high(sourceorderlist) do begin
   move((pchar(sortlist)+sourceorderlist[int1] * size)^,po3^,size);
   inc(po3,size);
  end;
  storebuffer(po2,sortlist);
 end;
end;

procedure reorderarray(const destorderlist: integerarty; var sortlist; size: integer);
         //sortlist = array of type
var
 po2: pchar;
 po3: pchar;
 int1: integer;
begin
 if initorderbuffer(sortlist,size,false,po2) then begin
  po3:= pchar(sortlist);
  for int1:= 0 to high(destorderlist) do begin
   move(po3^,(po2+destorderlist[int1] * size)^,size);
   inc(po3,size);
  end;
  storebuffer(po2,sortlist);
 end;
end;

procedure orderarray(const sourceorderlist: integerarty; var sortlist: pointerarty);
var
 po2: pchar;
 int1: integer;
begin
 if initorderbuffer(sortlist,sizeof(pointer),false,po2) then begin
  for int1:= 0 to high(sourceorderlist) do begin
   pointerarty(pointer(po2))[int1]:= sortlist[sourceorderlist[int1]];
  end;
  storebuffer(po2,sortlist);
 end;
end;

procedure orderarray(const sourceorderlist: integerarty;
                                   var sortlist: integerarty);
var
 po2: pchar;
 int1: integer;
begin
 if initorderbuffer(sortlist,sizeof(integer),false,po2) then begin
  for int1:= 0 to high(sourceorderlist) do begin
   integerarty(pointer(po2))[int1]:= sortlist[sourceorderlist[int1]];
  end;
  storebuffer(po2,sortlist);
 end;
end;

procedure reorderarray(const destorderlist: integerarty; var sortlist: pointerarty);
var
 po2: pchar;
 int1: integer;
begin
 if initorderbuffer(sortlist,sizeof(pointer),false,po2) then begin
  for int1:= 0 to high(destorderlist) do begin
   pointerarty(pointer(po2))[destorderlist[int1]]:= sortlist[int1];
  end;
  storebuffer(po2,sortlist);
 end;
end;

procedure reorderarray(const destorderlist: integerarty;
                                              var sortlist: integerarty);
var
 po2: pchar;
 int1: integer;
begin
 if initorderbuffer(sortlist,sizeof(integer),false,po2) then begin
  for int1:= 0 to high(destorderlist) do begin
   integerarty(pointer(po2))[destorderlist[int1]]:= sortlist[int1];
  end;
  storebuffer(po2,sortlist);
 end;
end;

procedure orderarray(const sourceorderlist: integerarty; var sortlist: stringarty);
var
 ar1: stringarty;
 int1: integer;
begin
 setlength(ar1,length(sourceorderlist));
 for int1:= 0 to high(sourceorderlist) do begin
  ar1[int1]:= sortlist[sourceorderlist[int1]];
 end;
 sortlist:= ar1;
end;

procedure reorderarray(const destorderlist: integerarty; var sortlist: stringarty);
var
 ar1: stringarty;
 int1: integer;
begin
 setlength(ar1,length(destorderlist));
 for int1:= 0 to high(destorderlist) do begin
  ar1[destorderlist[int1]]:= sortlist[int1];
 end;
 sortlist:= ar1;
end;

procedure orderarray(const sourceorderlist: integerarty; var sortlist: msestringarty);
var
 ar1: msestringarty;
 int1: integer;
begin
 setlength(ar1,length(sourceorderlist));
 for int1:= 0 to high(sourceorderlist) do begin
  ar1[int1]:= sortlist[sourceorderlist[int1]];
 end;
 sortlist:= ar1;
end;

procedure reorderarray(const destorderlist: integerarty; var sortlist: msestringarty);
var
 ar1: msestringarty;
 int1: integer;
begin
 setlength(ar1,length(destorderlist));
 for int1:= 0 to high(destorderlist) do begin
  ar1[destorderlist[int1]]:= sortlist[int1];
 end;
 sortlist:= ar1;
end;

procedure sortarray(var sortlist; compare: arraysortcomparety; size: integer;
                       out indexlist: integerarty);
begin
 quicksortarray(sortlist,compare,size,length(bytearty(sortlist)),true,indexlist);
end;

procedure sortarray(var sortlist; compare: arraysortcomparety; size: integer);
var
 indexlist: integerarty;
begin
 sortarray(sortlist,compare,size,indexlist);
end;

procedure sortarray(var dest: pointerarty; compare: arraysortcomparety;
                    out indexlist: integerarty);
begin
 quicksortarray(dest,compare,sizeof(pointer),length(dest),false,indexlist);
 orderarray(indexlist,dest);
end;

procedure sortarray(var dest: pointerarty; compare: arraysortcomparety);
var
 indexlist: integerarty;
begin
 sortarray(dest,compare,indexlist);
end;

procedure sortarray(var dest: msestringarty; compare: arraysortcomparety;
                    out indexlist: integerarty);
begin
 quicksortarray(dest,compare,sizeof(pointer),length(dest),false,indexlist);
 orderarray(indexlist,dest);
end;

procedure sortarray(var dest: msestringarty; compare: arraysortcomparety);
var
 indexlist: integerarty;
begin
 sortarray(dest,compare,indexlist);
end;

procedure sortarray(var dest: stringarty; compare: arraysortcomparety;
                    out indexlist: integerarty);
begin
 quicksortarray(dest,compare,sizeof(pointer),length(dest),false,indexlist);
 orderarray(indexlist,dest);
end;

procedure sortarray(var dest: stringarty; compare: arraysortcomparety);
var
 indexlist: integerarty;
begin
 sortarray(dest,compare,indexlist);
end;
                    
procedure sortarray(var dest: pointerarty);
begin
 sortarray(dest,{$ifdef FPC}@{$endif}comparepointer,sizeof(pointer));
end;

procedure sortarray(var dest: integerarty);
begin
 sortarray(dest,{$ifdef FPC}@{$endif}compareinteger,sizeof(integer));
end;

procedure sortarray(var dest: integerarty; out indexlist: integerarty);
begin
 sortarray(dest,{$ifdef FPC}@{$endif}compareinteger,sizeof(integer),indexlist);
end;

function comparelongword(const l,r): integer;
begin
 if longword(l) > longword(r) then begin
  result:= 1;
 end
 else begin
  if longword(l) < longword(r) then begin
   result:= -1;
  end
  else begin
   result:= 0;
  end;
 end;
end;

procedure sortarray(var dest: longwordarty);
begin
 sortarray(dest,{$ifdef FPC}@{$endif}comparelongword,sizeof(longword));
end;

procedure sortarray(var dest: longwordarty; out indexlist: integerarty);
begin
 sortarray(dest,{$ifdef FPC}@{$endif}comparelongword,sizeof(longword),indexlist);
end;

function comparereal(const l,r): integer;
var
 rea1: real;
begin
 rea1:= real(l) - real(r);
 if rea1 < 0 then begin
  result:= -1;
 end
 else begin
  if rea1 > 0 then begin
   result:= 1;
  end
  else begin
   result:= 0;
  end;
 end;
end;

function comparerealty(const l,r): integer;
begin
 result:= cmprealty(realty(l),realty(r));
end;

procedure sortarray(var dest: realarty); overload;
begin
 sortarray(dest,{$ifdef FPC}@{$endif}comparerealty,sizeof(realty));
end;

procedure sortarray(var dest: realarty; out indexlist: integerarty); overload;
begin
 sortarray(dest,{$ifdef FPC}@{$endif}comparerealty,sizeof(realty),indexlist);
end;

function comparemsestring(const l,r): integer;
begin
// {$ifdef FPC}
// result:= comparestr(msestring(l),msestring(r)); //!!!todo optimize
// {$else}
 result:= msecomparestr(msestring(l),msestring(r));
// {$endif}
end;

function compareimsestring(const l,r): integer;
begin
// {$ifdef FPC}
// result:= comparetext(msestring(l),msestring(r));
// {$else}
 result:= msecomparetext(msestring(l),msestring(r));
// {$endif}
end;

function compareasciistring(const l,r): integer;
begin
 result:= comparestr(ansistring(l),ansistring(r));
end;

function compareiasciistring(const l,r): integer;
begin
 result:= comparetext(ansistring(l),ansistring(r));
end;

function compareansistring(const l,r): integer;
begin
 result:= ansicomparestr(ansistring(l),ansistring(r));
end;

function compareiansistring(const l,r): integer;
begin
 result:= ansicomparetext(ansistring(l),ansistring(r));
end;

procedure sortarray(var dest: msestringarty; sortmode: stringsortmodety = sms_up);
begin
 setlength(dest,length(dest)); //refcount1
 case sortmode of
  sms_up: sortarray(dest,{$ifdef FPC}@{$endif}comparemsestring,sizeof(msestring));
  sms_upi: sortarray(dest,{$ifdef FPC}@{$endif}compareimsestring,sizeof(msestring));
 end;
end;

procedure sortarray(var dest: msestringarty; sortmode: stringsortmodety;
                            out indexlist: integerarty);
begin
 setlength(dest,length(dest)); //refcount1
 case sortmode of
  sms_up: sortarray(dest,{$ifdef FPC}@{$endif}comparemsestring,sizeof(msestring),indexlist);
  sms_upi: sortarray(dest,{$ifdef FPC}@{$endif}compareimsestring,sizeof(msestring),indexlist);
//   sms_upi: quicksortarray(ziel,0,length(ziel)-1,compareimsestring,sizeof(msestring));
 end;
end;

procedure sortarray(var dest: stringarty; sortmode: stringsortmodety = sms_upascii);
begin
 setlength(dest,length(dest)); //refcount1
 case sortmode of
  sms_up: sortarray(dest,{$ifdef FPC}@{$endif}compareansistring,sizeof(string));
  sms_upi: sortarray(dest,{$ifdef FPC}@{$endif}compareiansistring,sizeof(string));
//   sms_upi: quicksortarray(ziel,0,length(ziel)-1,compareistringansi,sizeof(string));
  sms_upascii: sortarray(dest,{$ifdef FPC}@{$endif}compareasciistring,sizeof(string));
//   sms_upiascii: quicksortarray(ziel,0,length(ziel)-1,compareistringascii,sizeof(string));
 end;
end;

procedure sortarray(var dest: stringarty; sortmode: stringsortmodety;
              out indexlist: integerarty);
begin
 setlength(dest,length(dest)); //refcount1
 case sortmode of
  sms_up: sortarray(dest,{$ifdef FPC}@{$endif}compareansistring,sizeof(string),indexlist);
  sms_upi: sortarray(dest,{$ifdef FPC}@{$endif}compareiansistring,sizeof(string),indexlist);
//   sms_upi: quicksortarray(ziel,0,length(ziel)-1,compareistringansi,sizeof(string));
  sms_upascii: sortarray(dest,{$ifdef FPC}@{$endif}compareasciistring,sizeof(string),indexlist);
//   sms_upiascii: quicksortarray(ziel,0,length(ziel)-1,compareistringascii,sizeof(string));
 end;
end;
{
procedure sortarray(var dest: pointeraty; length: integer; acompare: arraysortcomparety); overload;
var
 info: sortinfoty;
 int1: integer;
begin
 if length > 0 then begin
  with info do begin
   setlength(indexlist,length);
   for int1:= 0 to high(indexlist) do begin
    indexlist[int1]:= int1;
   end;
   sortlist:= @dest;
   compare:= acompare;
   size:= sizeof(pointer);
   doquicksortarray(info,0,high(indexlist));
   orderarray(indexlist,dest);
  end;
 end;
end;
}
function cmparray(const a,b: msestringarty): boolean;
               //true if equal
var
 int1: integer;
begin
 result:= a = b;
 if not result and (high(a) = high(b)) then begin
  for int1:= 0 to high(a) do begin
   if a[int1] <> b[int1] then begin
    exit;
   end;
  end;
  result:= true;
 end;
end;

{ tdatalist }

constructor tdatalist.create;
begin
 fsize:= 1;
 fmaxcount:= bigint;
// fsourcedirtystop:= maxint;
end;

destructor tdatalist.destroy;
var
 int1: integer;
begin
 for int1:= 0 to high(flinkdest) do begin
  flinkdest[int1].listdestroyed(self);
 end;
 flinkdest:= nil;
 clearbuffer;
 inherited;
end;

procedure tdatalist.listdestroyed(const sender: tdatalist);
begin
 removeitems(pointerarty(flinkdest),sender);
end;

function tdatalist.checksourcechange(var ainfo: listlinkinfoty;
                const sender: tdatalist; const aindex: integer): boolean;
begin
 with ainfo do begin
  result:= (source = sender) and (sender <> nil);
  if result then begin
   if aindex < 0 then begin
    dirtystart:= 0;
    dirtystop:= sender.count-1;
   end
   else begin
    if aindex < dirtystart then begin
     dirtystart:= aindex;
    end;
    if aindex > ainfo.dirtystop then begin
     dirtystop:= aindex;
    end;
   end;
  end;
 end;
end;

procedure tdatalist.sourcechange(const sender: tdatalist; const aindex: integer);
begin
 //dummy
// checksourcechange(flinksource,sender,index,fsourcedirtystart,fsourcedirtystop);
end;

function tdatalist.islinked(const asource: tdatalist): boolean;
var
 int1: integer;
 po1: plistlinkinfoty;
begin
 result:= asource = self; 
 if not result then begin
  for int1:= 0 to getsourcecount - 1 do begin
   po1:= getsourceinfo(int1);
   if (po1 <> nil) and (po1^.source <> nil) then begin
    result:= po1^.source.islinked(asource);
    if result then begin
     break;
    end;
   end;
  end;
 end;
end;

function tdatalist.canlink(const asource: tdatalist;
                                        const atag: integer): boolean;
begin
 result:= (asource <> nil) and (asource.datatype in getlinkdatatypes(atag)) and 
               not asource.islinked(self);
end;

function tdatalist.checksourcecopy(var ainfo: listlinkinfoty;
                                      const copyproc: copyprocty): boolean;
var
 int1: integer;
 int2,int3: ptruint;
 po1,po2: pchar; //delphi needs pchar for pointer arithmetic
begin
 with ainfo do begin
  result:= (source <> nil) and (dirtystop >= dirtystart);
  if result then begin
   if dirtystop >= source.count then begin
    dirtystop:= source.count - 1;
   end;
   if dirtystop >= count then begin
    dirtystop:= count  - 1;
   end;
   int2:= source.size;
   po1:= pchar(source.datapo) + int2 * dirtystart;
   int3:= size;
   po2:= pchar(datapo) + int3 * dirtystart;
   for int1:= dirtystop - dirtystart downto 0 do begin
    copyproc(po1,po2);
    inc(po1,int2);
    inc(po2,int3);
   end;
   dirtystart:= maxint;
   dirtystop:= -1;
  end;
 end;
end;

function tdatalist.checksourcecopy2(var ainfo: listlinkinfoty;
           const source2: tdatalist; const copyproc: copy2procty): boolean;
var
 int1: integer;
 int2,int3,int4: ptruint;
 po1,po2,po3: pchar; //delphi needs pchar for pointer arithmetic
begin
 with ainfo do begin
  result:= (source <> nil) and (source2 <> nil) and (dirtystop >= dirtystart);
  if result then begin
   if dirtystop >= source.count then begin
    dirtystop:= source.count - 1;
   end;
   if dirtystop >= source2.count then begin
    dirtystop:= source2.count - 1;
   end;
   if dirtystop >= count then begin
    dirtystop:= count  - 1;
   end;
   int2:= source.size;
   po1:= pchar(source.datapo) + int2 * dirtystart;
   int3:= source2.size;
   po2:= pchar(source2.datapo) + int3 * dirtystart;
   int4:= size;
   po3:= pchar(datapo) + int4 * dirtystart;
   for int1:= dirtystop - dirtystart downto 0 do begin
    copyproc(po1,po2,po3);
    inc(po1,int2);
    inc(po2,int3);
    inc(po3,int4);
   end;
   dirtystart:= maxint;
   dirtystop:= -1;
  end;
 end;
end;

{
procedure tdatalist.linkdest(const dest: tdatalist);
begin
 if dest.flinksource <> nil then begin
  dest.flinksource.unlinkdest(dest);
 end;
 if dest.canlink(self) then begin
  dest.flinksource:= self;
  additem(pointerarty(flinkdest),dest);
  dest.sourcechange(self,-1);
 end;
end;

procedure tdatalist.unlinkdest(const dest: tdatalist);
begin
 removeitems(pointerarty(flinkdest),dest);
 dest.flinksource:= nil;
end;
}

procedure tdatalist.unlinksource(var alink: listlinkinfoty);
begin
 if alink.source <> nil then begin
  removeitem(pointerarty(alink.source.flinkdest),self);
  alink.source:= nil;
 end;
end;

function tdatalist.internallinksource(const source: tdatalist;
                 const atag: integer; var variable: tdatalist): boolean;
begin
 if variable <> nil then begin
  removeitem(pointerarty(variable.flinkdest),self);
 end;
 result:= (source <> nil) and canlink(source,atag);
 if result then begin
  variable:= source;
  additem(pointerarty(source.flinkdest),self);
  sourcechange(source,-1);
 end;
end;

procedure tdatalist.linksource(const source: tdatalist; const atag: integer);
begin
 //dummy
end;

procedure tdatalist.clearbuffer;
begin
 internalfreedata(0,fcount);
 if fdatapo <> nil then begin
  freemem(fdatapo);
 end;
 fdatapo:= nil;
 fbytelength:= 0;
 fcapacity:= 0;
 fcount:= 0;
 fringpointer:= 0;
end;

function tdatalist.sort(const compareproc: compareprocty; 
              const arangelist: tintegerdatalist; dorearange: boolean): boolean;
  //true wenn bewegt, refrow erhaelt neue indexpos

 procedure QuickSort(var arangelist: integeraty; L, R: Integer);
 var
   I, J: Integer;
   P, T: integer;
   int1: integer;
   pp: pointer;
 begin
  if r >= l then begin
   repeat
     I := L;
     J := R;
     P := arangelist[(L + R) shr 1];
     pp:= fdatapo+p*fsize;
     repeat
       repeat
        int1:= 0;
        compareproc((fdatapo+arangeList[I]*fsize)^, pp^,int1);
        if int1 = 0 then begin
         int1:= arangelist[i] - p;
        end;
        if int1 >= 0 then break;
        inc(i);
       until false;
       repeat
        int1:= 0;
        compareproc((fdatapo+arangeList[J]*fsize)^, pp^,int1);
        if int1 = 0 then begin
         int1:= arangelist[j] - p;
        end;
        if int1 <= 0 then break;
        dec(j);
       until false;
       if I <= J then
       begin
        if i <> j then begin
         result:= true;
         T := arangeList[I];
         arangeList[I] := arangeList[J];
         arangeList[J] := T;
        end;
        Inc(I);
        Dec(J);
       end;
     until I > J;
     if L < J then QuickSort(arangelist,L, J);
     L := I;
   until I >= R;
  end;
 end;

begin
 arangelist.count:= fcount;
 result:= false;
 if fcount > 0 then begin
  arangelist.number(0,1);
  quicksort(pintegeraty(arangelist.datapo)^,0,arangelist.count-1);
  if result and dorearange then begin
   include(fstate,dls_sortio);
   rearange(arangelist);
  end;
 end
 else begin
  include(fstate,dls_sortio);
 end;
end;

function tdatalist.sort(
              const arangelist: tintegerdatalist; dorearange: boolean): boolean;
begin
 result:= sort({$ifdef FPC}@{$endif}compare,arangelist,dorearange);
end;

function tdatalist.sort(const compareproc: compareprocty): boolean;
var
 arangelist: tintegerdatalist;
begin
 arangelist:= tintegerdatalist.create;
 try
  result:= sort(compareproc,arangelist,true);
 finally
  arangelist.free;
 end;
end;

function tdatalist.sort: boolean;
begin
 result:= sort({$ifdef FPC}@{$endif}compare);
end;

procedure tdatalist.checkindexrange(const aindex: integer;
                                             const acount: integer = 1);
begin
 if (aindex < 0) or (aindex >= fcount) then begin
  tlist.error(slistindexerror, aindex);
 end;
 if (aindex+acount > fcount) then begin
  tlist.error(slistindexerror, aindex);
 end;
end;

procedure tdatalist.checkindex(var index: integer);
begin
 if (Index < 0) or (Index >= FCount) then begin
  tlist.Error(SListIndexError, Index);
 end;
 index:= index + fringpointer;
 if index >= fmaxcount then begin
  index:= index - fmaxcount;
 end;
end;

function tdatalist.internaladddata(const quelle; docopy: boolean): integer;
var
 int1: integer;
 po1: pointer;
begin
 beginupdate;
 try
  internalsetcount(fcount + 1,true);
  int1:= fcount - 1 + fringpointer;
  if int1 >= fmaxcount then begin
   dec(int1,fmaxcount);
  end;
  po1:= fdatapo + int1*fsize;
  move(quelle,po1^,fsize);
  if (dls_needscopy in fstate) and docopy then begin
   copyinstance(po1^);
  end;
 finally
  endupdate;
 end;
 result:= fcount-1;
end;

function tdatalist.adddata(const quelle): integer;
begin
 result:= internaladddata(quelle,true);
end;

procedure tdatalist.internaldeletedata(index: integer; dofree: boolean);
var
 int1: integer;
begin
 checkindex(index);
 if dofree then begin
  internalcleardata(index);
 end;
 int1:= (index+1)*fsize;
 if fringpointer = 0 then begin
  move((fdatapo+int1)^,(fdatapo+int1-fsize)^,fcount*fsize-int1);
 end
 else begin
  if index < fringpointer then begin //im unteren bereich
   move((fdatapo+int1)^,(fdatapo+int1-fsize)^,
             (fcount+fringpointer-fmaxcount)*fsize-int1);
  end
  else begin     //im oberen bereich
   move((fdatapo+int1)^,(fdatapo+int1-fsize)^,fmaxcount*fsize-int1); //start
   move(fdatapo^,(fdatapo+(fmaxcount-1)*fsize)^,fsize); //ueberlauf
   move((fdatapo+fsize)^,fdatapo^,(fcount+fringpointer-fmaxcount-1)*fsize);
   //rest
  end;
 end;
 fcount:= fcount-1;
 datadeleted(index,1);
 change(-1);
end;

procedure tdatalist.deletedata(const index: integer);
begin
 internaldeletedata(index,true);
end;

procedure tdatalist.deleteitems(index,acount: integer);
begin
 if index + acount > fcount then begin
  acount:= fcount - index;
 end;
 if acount > 0 then begin
  inc(fdeleting);
  try
   internalfreedata(index,acount);
   blockcopymovedata(index+acount,index,fcount-index-acount,bcm_none);
   fcount:= fcount-acount;
   checkcapacity;
   datadeleted(index,acount);
   change(-1);
  finally
   dec(fdeleting);
  end;
 end;
end;

procedure tdatalist.clear;
begin
// beginupdate;
 inc(fdeleting);
 try
  clearbuffer;
  change(-1);
 finally
  dec(fdeleting);
//  endupdate;
 end;
end;

procedure tdatalist.insertitems(index,acount: integer);
var
 countbefore: integer;
begin
 if acount > 0 then begin
  countbefore:= fcount;
  internalsetcount(fcount + acount,true);
  dec(index,acount+countbefore-fcount); //adjust for maxcount
  blockcopymovedata(index,index+acount,fcount-index-acount,bcm_none);
  initdata1(false,index,acount);
  datainserted(index,acount);
  change(-1);
 {
  capacity:= fcount + acount;
  fcount:= fcount + acount;
  blockcopymovedata(index,index+acount,fcount-index-acount,bcm_none);
  initdata1(false,index,acount);
  change(-1);
  }
 end;
end;

function tdatalist.checkassigncompatibility(const source: tpersistent): boolean;
begin
 result:= false;
end;

function tdatalist.assigndata(const source: tpersistent): boolean;
begin
 if source = self then begin
  result:= true;
  exit;
 end;
 result:= checkassigncompatibility(source);
// result:= (datatype < dl_custom) and (source is tdatalist) and 
//                      (tdatalist(source).datatype = datatype) or 
//                       source.inheritsfrom(classtype) or 
//                       inheritsfrom(source.classtype);
 if result then begin
  tdatalist(source).assigntodata(self);
 end;
end;

procedure tdatalist.assigntodata(const dest: tdatalist);
var
 int1: integer;
 po1,po2: pointer;
 s0,s1,s2: integer;
begin
 with dest do begin
  newbuffer(self.count,true,size < self.size);
  if size = self.size then begin
   move(self.datapo^,fdatapo^,fcount*fsize);
  end
  else begin
   po1:= self.datapo;
   po2:= fdatapo;
   s1:= self.size;
   s2:= size;
   s0:= s1;
   if s0 > s2 then begin
    s0:= s2;
   end;
   for int1:= 0 to fcount-1 do begin
    move(po1^,po2^,s0);
    inc(pchar(po1),s1);
    inc(pchar(po2),s2);
   end;
  end;
  internalcopyinstance(0,fcount);
  change(-1);
 end;
end;

procedure tdatalist.internalgetasarray(const adatapo: pointer;
                                                    const asize: integer);
var
 int1: integer;
 po1,po2: pointer;
 s1,s2: integer;
begin
 if fcount > 0 then begin
  normalizering;
  if asize < size then begin
   po1:= fdatapo;
   po2:= adatapo;
   s1:= size;
   s2:= asize;
   for int1:= 0 to count - 1 do begin
    move(po1^,po2^,s2);
    inc(pchar(po1),s1);
    inc(pchar(po2),s2);
   end;
  end
  else begin
   move(fdatapo^,adatapo^,fcount*fsize);
  end;
  if dls_needscopy in fstate then begin
   po1:= adatapo;
   s1:= asize;
   for int1:= 0 to fcount - 1 do begin
    copyinstance(po1^);
    inc(pchar(po1),s1);
   end;
  end;
 end;
end;

procedure tdatalist.internalsetasarray(const source: pointer; 
                            const asize: integer; const acount: integer);
var
 int1: integer;
 po1,po2: pointer;
 s1,s2,s3: integer;
begin
 newbuffer(acount,true,size > asize);
 if fcount > 0 then begin
  if size <> asize then begin
   po1:= fdatapo;
   po2:= source;
   s1:= size;
   s2:= asize;
   s3:= size;
   if s3 > asize then begin
    s3:= asize;
   end;
   for int1:= 0 to fcount - 1 do begin
    move(po2^,po1^,s3);
    inc(pchar(po1),s1);
    inc(pchar(po2),s2);
   end;
  end
  else begin
   move(source^,fdatapo^,fcount*fsize);
  end;
  internalcopyinstance(0,fcount);
 end;
 change(-1); 
end;

function tdatalist.getdatablock(const source: pointer; const destsize: integer): integer;
             //returns size of datablock
begin
 internalgetasarray(source,destsize);
 result:= count * destsize;
end;

function tdatalist.setdatablock(const dest: pointer; const sourcesize: integer;
                                         const acount: integer): integer;
             //returns size of datablock
begin
 internalsetasarray(dest,sourcesize,acount);
 result:= acount * sourcesize;
end;

procedure tdatalist.internalgetdata(index: integer; out ziel);
begin
 checkindex(index);
 move((fdatapo+index*fsize)^,ziel,fsize);
end;

procedure tdatalist.getdata(index: integer; var dest);
var
 po1: pointer;
begin
 checkindex(index);
 if dls_needsfree in fstate then begin
  freedata(dest);
 end;  
 po1:= fdatapo+index*fsize;
 move(po1^,dest,fsize);
 if dls_needscopy in fstate then begin
  copyinstance(dest);
 end;
end;

procedure tdatalist.getgriddata(index: integer; var dest);
begin
 getdata(index,dest);
end;

procedure tdatalist.internalsetdata(index: integer; const quelle);
var
 po1: pointer;
 int1: integer;
begin
 int1:= index;
 checkindex(index);
 po1:= fdatapo+index*fsize;
 if dls_needsfree in fstate then begin
  freedata(po1^);
 end;
 move(quelle,po1^,fsize);
 if dls_needscopy in fstate then begin
  copyinstance(po1^);
 end;
 change(int1);
end;

procedure tdatalist.setdata(index: integer; const source);
begin
 internalsetdata(index,source);
end;

procedure tdatalist.setgriddata(index: integer; const source);
begin
 internalsetdata(index,source);
end;

function tdatalist.getstatdata(const index: integer): msestring;
begin
 result:= ''; //dummy
end;

procedure tdatalist.setstatdata(const index: integer; const value: msestring);
begin
 //dummy
end;

procedure tdatalist.writestate(const writer; const name: msestring);
var
 int1: integer;
begin
 with tstatwriter(writer) do begin
  writeinteger(name,fcount);
  for int1:= 0 to count - 1 do begin
   writelistitem(getstatdata(int1));
  end;
 end;
end;

procedure tdatalist.readstate(const reader; const acount: integer);
var
 int1: integer;
 str1: msestring;
begin
 with tstatreader(reader) do begin
  try
   beginupdate;
   count:= acount;
   for int1:= 0 to acount - 1 do begin
    str1:= readlistitem;
    setstatdata(int1,str1);
   end;
  finally
   endupdate;
  end;
 end;
end;

procedure tdatalist.writeappendix(const writer; const aname: msestring);
begin
 //dummy
end;

procedure tdatalist.readappendix(const reader; const aname: msestring);
begin
 //dummy 
end;

function tdatalist.popbottomdata(var ziel): boolean;
begin
 result:= fcount > 0;
 if result then begin
  checkbuffersize(0);
  if @ziel <> nil then begin
   getdata(0,ziel);
  end;
  cleardata(0);
  inc(fringpointer);
  if fringpointer >= fmaxcount then begin
   dec(fringpointer,fmaxcount);
  end;
  dec(fcount);
 end;
end;

function tdatalist.poptopdata(var ziel): boolean;
begin
 result:= fcount > 0;
 if result then begin
  if @ziel <> nil then begin
   getdata(fcount-1,ziel);
  end;
  count:= fcount-1;
 end;
end;

procedure tdatalist.pushdata(const quelle);
begin
 checkbuffersize(1);
 adddata(quelle);
end;

procedure tdatalist.internalinsertdata(index: integer; const quelle;
                                           const docopy: boolean);
var
 int1: integer;
begin
 if index = fcount then begin
  internaladddata(quelle,docopy);
 end
 else begin
  beginupdate;
  try
   internalsetcount(fcount+1,true);
//   count:= fcount+1;
   checkindex(index);
   int1:= (index)*fsize;
   move((fdatapo+int1)^,(fdatapo+int1+fsize)^,(fcount-index-1)*fsize);
   if @quelle = nil then begin
 //   fillchar(datapoty(fdatapo)^[int1],fsize,0);
    initdata1(false,index,1);
   end
   else begin
    move(quelle,(fdatapo+int1)^,fsize);
    if (dls_needscopy in fstate) and docopy then begin
     copyinstance((fdatapo+int1)^);
    end;
   end;
  finally
   endupdate;
  end;
 end;
end;

procedure tdatalist.insertdata(const index: integer; const quelle);
begin
 internalinsertdata(index,quelle,true);
end;

procedure tdatalist.Setcapacity(Value: integer);
begin
 if value < fcount then begin
  value:= fcount;
 end;
 if value < fmaxcount then begin
  normalizering;
 end;
 fbytelength:= value*fsize;
 reallocmem(fdatapo,fbytelength);
 fcapacity:= value;
end;

procedure tdatalist.initdata1(const afree: boolean; index: integer;
                            const acount: integer);
    //initialisiert mit defaultwert
var
 int1,int2: integer;
 default,po: pchar;
begin
 if acount <= 0 then begin
  exit;
 end;
 if afree then begin
  internalfreedata(index,acount);
 end;
 int1:= index+acount-1;
 checkindex(index);
 checkindex(int1);
 default:= getdefault;
 if default = nil then begin
  if int1 >= index then begin
   fillchar((fdatapo+index*fsize)^,acount*fsize,0);
   if dls_needsinit in fstate then begin
    for int2:= index to index + acount - 1 do begin
     initinstance((fdatapo+int2*fsize)^);
    end;
   end;
  end
  else begin
   fillchar((fdatapo)^,int1*fsize,0);
   fillchar((fdatapo+index*fsize)^,(fmaxcount-index)*fsize,0);
   if dls_needsinit in fstate then begin
    for int2:= 0 to int1 - 1 do begin
     initinstance((fdatapo+int2*fsize)^);
    end;
    for int2:= index to fmaxcount-index - 1 do begin
     initinstance((fdatapo+int2*fsize)^);
    end;
   end;
  end;
 end
 else begin
  po:= fdatapo;
  inc(po,index*fsize);
  if int1 >= index then begin   //one piece
   for int1:= 0 to acount-1 do begin
    move(default^,po^,fsize);
    inc(po,fsize);
   end;
   if dls_needscopy in fstate then begin
    for int2:= index to index + acount - 1 do begin
     copyinstance((fdatapo+int2*fsize)^);
    end;
   end;
  end
  else begin
   for int1:= 0 to fmaxcount - acount - 1 do begin
    move(default^,po^,fsize);
    inc(po,fsize);
   end;
   po:= fdatapo;
   for int2:= 0 to int1 do begin
    move(default^,po^,fsize);
    inc(po,fsize);
   end;
   if dls_needscopy in fstate then begin
    for int2:= 0 to int1 - 1 do begin
     copyinstance((fdatapo+int2*fsize)^);
    end;
    for int2:= index to fmaxcount-index - 1 do begin
     copyinstance((fdatapo+int2*fsize)^);
    end;
   end;
  end;
 end;
end;

procedure tdatalist.getdefaultdata(var dest);
var
 po: pointer;
begin
 if dls_needsfree in fstate then begin
  freedata(dest);
 end;
 po:= getdefault;
 if po = nil then begin
  fillchar(dest,fsize,0);
 end
 else begin
  move(po^,dest,fsize);
  if dls_needscopy in fstate then begin
   copyinstance(dest);
  end;
 end;
end;

procedure tdatalist.getgriddefaultdata(var dest);
begin
 getdefaultdata(dest);
end;

procedure tdatalist.internalcleardata(const index: integer);
var
 default,po1: pointer;
begin
 po1:= fdatapo+index*fsize;
 if dls_needsfree in fstate then begin
  freedata(po1^);
 end;
 default:= getdefault;
 if default <> nil then begin
  move(default^,po1^,fsize);
 end
 else begin
  fillchar(po1^,fsize,0);
 end;
end;

procedure tdatalist.cleardata(index: integer);
begin
 checkindex(index);
 internalcleardata(index);
end;


function tdatalist.deleting: boolean;
begin
 result:= fdeleting > 0;
end;

procedure tdatalist.checkcapacity;
var
 int1: integer;
begin
// int1:= ((fcount*12) div 10) + 5;
 int1:= fcount*2 + 32;
 if fcapacity > int1 then begin
  capacity:= fcount;
 end;
end;

procedure tdatalist.internalsetcount(value: integer; nochangeandinit: boolean);
var
 int1: integer;
 countvorher: integer;
begin
 if value < 0 then begin
  tlist.Error(SListCountError, value);
 end;

 countvorher:= fcount;
 if value > fmaxcount then begin
  int1:= value-fmaxcount;        //last item to init
  if int1 > fcount then begin 
   int1:= fcount;               
  end;
  value:= fmaxcount;
  if value > fcapacity then begin
   capacity:= value;
  end;
  fcount:= value;
  if not nochangeandinit then begin
   initdata1(true,0,int1); //free lost oldbuffer
   initdata1(false,countvorher,value-countvorher); //init newbuffer
  end
  else begin
   internalfreedata(0,int1);
  end;
  fringpointer:= fringpointer + int1;
  if fringpointer >= fmaxcount then begin
   fringpointer:= fringpointer - fmaxcount;
  end;
  if not nochangeandinit then begin
   change(-1);
  end;
 end
 else begin
  if value > fcapacity then begin
   capacity:= value*2 + 32; 
//   capacity:= ((value*12) div 10) + 5; //in 20% schritten
  end;
  if value > countvorher then begin
   Fcount := Value;
 //  fillchar(datapoty(fdatapo)^[countvorher*fsize],(value-countvorher)*fsize,0);
   if not nochangeandinit then begin
    initdata1(false,countvorher,value-countvorher);    //mit defaultdaten fuellen
   end;
  end
  else begin
   if value < countvorher then begin
    internalfreedata(value,countvorher-value);
    Fcount := Value;
    checkcapacity;
   end;
  end;
  if countvorher > value then begin
   datadeleted(count,countvorher-count);
  end;
  if not nochangeandinit and (countvorher <> value) then begin
   change(-1);
  end;
 end;
end;

procedure tdatalist.newbuffer(const acount: integer; const noinit: boolean;
                                                       const fillnull: boolean);
begin
 clearbuffer;
 fcount:= acount;
 if fcount > fmaxcount then begin
  fcount:= fmaxcount;
 end;
 setcapacity(fcount);
 if not noinit then begin
  initdata1(false,0,fcount);
 end
 else begin
  fillchar(fdatapo^,fcount*fsize,0);
 end;
end;

procedure tdatalist.Setcount(const Value: integer);
begin
 internalsetcount(value,false);
end;

procedure tdatalist.checkbuffersize(increment: integer);
var
 int1: integer;
begin
 increment:= fcount + increment;
 int1:= 2*increment;
 if increment > fmaxcount then begin
  maxcount:= int1;
 end
 else begin
  if fmaxcount > int1 + increment + 40 then begin
   maxcount:= int1;
  end
 end;
 if fcapacity < fmaxcount then begin
  capacity:= fmaxcount;
 end;
end;

procedure tdatalist.internalfill(const anzahl: integer; const wert);
  //initialisiert mit wert
var
 int1: integer;
 po1: pchar;
begin
 beginupdate;
 try
  count:= anzahl;
  normalizering;
  po1:= fdatapo;
  if dls_needsfree in fstate then begin
   for int1:= 0 to fcount - 1 do begin
    freedata(po1^);
    inc(po1,fsize);
   end;
  end;
  if @wert = nil then begin
   fillchar(fdatapo^,anzahl*fsize,0);
  end
  else begin
   po1:= fdatapo;
   if dls_needscopy in fstate then begin
    for int1:= 0 to fcount - 1 do begin
     move(wert,po1^,fsize);
     copyinstance(po1^);
     inc(po1,fsize);
    end;
   end
   else begin
    for int1:= 0 to fcount - 1 do begin
     move(wert,po1^,fsize);
     inc(po1,fsize);
    end;
   end;
  end;
 finally
  endupdate;
 end;
end;

procedure tdatalist.movedata(const fromindex, toindex: integer);
var
 po1: pointer;
begin
 if fromindex <> toindex then begin
  beginupdate;
  getmem(po1,fsize);
  try
   internalgetdata(fromindex,po1^);
   internaldeletedata(fromindex,false);
   internalinsertdata(toindex,po1^,false);
   datamoved(fromindex,toindex,1);
  finally
   freemem(po1);
   endupdate;
  end;
 end;
// change(-1);
end;

procedure tdatalist.blockcopymovedata(fromindex, toindex: integer; 
                            const count: integer; const mode: blockcopymodety);
var
 ueberlappung,freestart,freecount,initstart: integer;
 int1,int2: integer;
begin
 if (count > 0) and (fromindex <> toindex) then begin
  normalizering;
  checkindex(fromindex);
  checkindex(toindex);
  int1:= fromindex+count-1;
  checkindex(int1);
  if (mode <> bcm_rotate) then begin
   int2:= toindex+count-1;
   checkindex(int2);
  end;
  if fromindex > toindex then begin
   ueberlappung:= toindex+count-fromindex;
   if ueberlappung < 0 then begin
    ueberlappung:= 0;
   end;
   freestart:= toindex;
   initstart:= fromindex + ueberlappung;
  end
  else begin
   ueberlappung:= fromindex+count-toindex;
   if ueberlappung < 0 then begin
    ueberlappung:= 0;
   end;
   freestart:= toindex+ueberlappung;
   initstart:= fromindex;
  end;
  freecount:= count-ueberlappung;
  if mode = bcm_rotate then begin
   if toindex < fromindex then begin
    internalsetcount(fcount + freecount,true);
    move((fdatapo+freestart*fsize)^,
                (fdatapo+(fcount-freecount)*fsize)^,freecount*fsize);
    move((fdatapo+fromindex*fsize)^,
                 (fdatapo+toindex*fsize)^,count*fsize);
    if ueberlappung = 0 then begin
       move((fdatapo+(toindex+count)*fsize)^,
            (fdatapo+(toindex+count+count)*fsize)^,
            (fromindex-toindex-count)*fsize);
    end;
    move((fdatapo+(self.count-freecount)*fsize)^,
            (fdatapo+(toindex+count)*fsize)^,
            freecount*fsize);
   end
   else begin
    if ueberlappung = 0 then begin
     internalsetcount(fcount + freecount,true);
     move((fdatapo+fromindex*fsize)^,
                (fdatapo+(fcount-freecount)*fsize)^,freecount*fsize);
     move((fdatapo+(fromindex+freecount)*fsize)^,
                 (fdatapo+fromindex*fsize)^,(toindex-fromindex-count+1)*fsize);
     move((fdatapo+(self.count-freecount)*fsize)^,
             (fdatapo+(toindex-freecount+1)*fsize)^,
             freecount*fsize);
    end
    else begin
     if toindex + count > fcount then begin
      toindex:= fcount-count;
     end;
     freecount:= toindex-fromindex;
     internalsetcount(fcount + freecount,true);
     move((fdatapo+(fromindex+count)*fsize)^,
                (fdatapo+(fcount-freecount)*fsize)^,freecount*fsize);
     move((fdatapo+(fromindex)*fsize)^,
                 (fdatapo+toindex*fsize)^,count*fsize);
     move((fdatapo+(self.count-freecount)*fsize)^,
             (fdatapo+fromindex*fsize)^,
             freecount*fsize);
    end;
   end;
   fcount:= fcount-freecount; //no free
   checkcapacity;
  end
  else begin
   if mode <> bcm_none then begin
    internalfreedata(freestart,freecount);
   end;
   move((fdatapo+fromindex*fsize)^,
                (fdatapo+toindex*fsize)^,count*fsize);
   if mode = bcm_copy then begin
    internalcopyinstance(initstart,freecount);
   end
   else begin
    if mode = bcm_init then begin
     initdata1(false,initstart,freecount);
    end
   end;
  end;
 end;
end;

procedure tdatalist.blockmovedata(const fromindex, toindex, count: integer);
begin
 if fromindex <> toindex then begin
  if count = 1 then begin
   movedata(fromindex,toindex);
  end
  else begin
   blockcopymovedata(fromindex,toindex,count,bcm_rotate);
   datamoved(fromindex,toindex,count);
   change(-1);
  end;
 end;
end;

procedure tdatalist.blockcopydata(const fromindex, toindex, count: integer);
begin
 blockcopymovedata(fromindex,toindex,count,bcm_copy);
 change(-1);
end;

procedure tdatalist.readdata(reader: treader);
begin
 beginupdate;
 try
  clear;
  reader.readlistbegin;
  while not reader.EndOfList do begin
   internalsetcount(fcount + 1,false);
   readitem(reader,(fdatapo+(fcount-1)*fsize)^);
  end;
  reader.ReadListEnd;
 finally
  endupdate;
 end;
end;

procedure tdatalist.writedata(writer: twriter);
var
 int1: integer;
 po1: pchar;
begin
 writer.WriteListBegin;
 normalizering;
 po1:= fdatapo;
 for int1:= 0 to count-1 do begin
  writeitem(writer,po1^);
  inc(po1,fsize);
 end;
 writer.writelistend;
end;

procedure tdatalist.readitem(const reader: treader; var value);
begin
 //dummy
end;

procedure tdatalist.writeitem(const writer: twriter; var value);
begin
 //dummy
end;

function tdatalist.checkwritedata(const filer: tfiler): boolean;
var
 int1,int2: integer;
 po1: pointer;
begin
 if filer.ancestor = nil then begin
  result:= (fcount <> 0);
 end
 else begin
  result:= tdatalist(filer.ancestor).fcount <> fcount;
  if not result and (filer is twriter) then begin
   datapo; //normalize ring
   po1:= tdatalist(filer.ancestor).datapo;
   for int1:= 0 to fcount-1 do begin
    compare((fdatapo+int1*fsize)^,(pchar(po1)+int1*fsize)^,int2);
    if int2 <> 0 then begin
     result:= true;
     break;
    end;
   end;
  end;
 end;
end;

procedure tdatalist.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('data',
  {$ifdef FPC}@{$endif}readdata,{$ifdef FPC}@{$endif}writedata,
           not (dls_nostreaming in fstate) and checkwritedata(filer));
end;

procedure tdatalist.freedata(var data);
begin
 //dummy
end;

procedure tdatalist.internalfreedata(index, anzahl: integer);
begin
 if dls_needsfree in fstate then begin
  forall(index,anzahl,{$ifdef FPC}@{$endif}freedata);
 end;
end;

procedure tdatalist.copyinstance(var data);
begin
 //dumy
end;

procedure tdatalist.initinstance(var data);
begin
 //dummy
end;

procedure tdatalist.internalcopyinstance(index, anzahl: integer);
begin
 if dls_needscopy in fstate then begin
  forall(index,anzahl,{$ifdef FPC}@{$endif}copyinstance);
 end;
end;

procedure tdatalist.remoteitemchange(const alink: pointer);
begin
 with idatalistclient(alink) do begin
  itemchanged(self,fintparam);
 end;
end;

procedure tdatalist.doitemchange(const index: integer);
begin
 if assigned(fonitemchange) then begin
  fonitemchange(self,index);
 end;
 fintparam:= index;
 if (dls_remote in fstate) and (fobjectlinker <> nil) then begin
  fobjectlinker.forall({$ifdef FPC}@{$endif}remoteitemchange,
                                               typeinfo(idatalistclient));
 end;
end;

procedure tdatalist.dochange;
begin
 if assigned(fonchange) then begin
  fonchange(self);
 end;
end;

procedure tdatalist.change(const index: integer);
var
 int1: integer;
begin
 exclude(fstate,dls_sortio);
 if fnochange = 0 then begin
  doitemchange(index);
  if sorted then begin
   sort;
  end;
  dochange;
  if flinkdest <> nil then begin
   for int1:= 0 to high(flinkdest) do begin
    flinkdest[int1].sourcechange(self,index);
   end;
  end;
 end;
end;

procedure tdatalist.beginupdate;
begin
 inc(fnochange);
end;

procedure tdatalist.endupdate;
begin
 dec(fnochange);
 if fnochange = 0 then begin
  change(-1);
 end;
end;

procedure tdatalist.incupdate;
begin
 inc(fnochange);
end;

procedure tdatalist.decupdate;
begin
 dec(fnochange);
end;
{
procedure tdatalist.resetupdate;
begin
 fnochange:= 0;
end;
}
function tdatalist.updating: boolean;
begin
 result:= fnochange > 0;
end;

procedure tdatalist.internalrearange(arangelist: pinteger;
                                                       const acount: integer);
var
 datapo1: pchar;
// po1: pinteger;
 int1: integer;
begin
 normalizering;
 getmem(datapo1,fbytelength);
 try
//  po1:= arangelist.datapo;
  for int1:= 0 to acount -1 do begin
   move((fdatapo+arangelist^*fsize)^,(datapo1+int1*fsize)^,fsize);
   inc(arangelist);
  end;
  move((fdatapo+acount*fsize)^,
         (datapo1+acount*fsize)^,
              (fcount-acount)*fsize);      //rest kopieren
 finally
  freemem(fdatapo);
  fdatapo:= datapo1;
 end;
 change(-1);
end;

procedure tdatalist.rearange(const arangelist: tintegerdatalist);
begin
 internalrearange(arangelist.datapo,arangelist.count);
end;

procedure tdatalist.rearange(const arangelist: integerarty);
begin
 internalrearange(pointer(arangelist),length(arangelist));
end;

function tdatalist.empty(const index: integer): boolean;
var
 int1: integer;
 po1: pbyte;
begin
 po1:= getitempo(index);
 for int1:= 0 to fsize-1 do begin
  if po1^ <> 0 then begin
   result:= false;
   exit;
  end;
  inc(po1);
 end;
 result:= true;
end;

function tdatalist.datatype: listdatatypety;
begin
 result:= dl_custom;
end;

procedure tdatalist.compare(const l, r; var result: integer);
begin
 //dummy
end;

procedure tdatalist.setmaxcount(const Value: integer);
begin
 if fmaxcount <> value then begin
  normalizering;
  if fcount > value then begin
   count:= value;
  end;
  fmaxcount := Value;
 end;
end;

function tdatalist.getdefault: pointer;
begin
 result:= nil;
end;

procedure tdatalist.normalizering;
var
 po: pbyte;
 int1,int2,int3: integer;
begin
 if fringpointer <> 0 then begin
  int1:= fringpointer*fsize;
  int2:= fringpointer + fcount;
  if int2 > fmaxcount then begin //2 pieces
   int2:= (int2 - fmaxcount) * fsize;
   getmem(po,int2);
   move(fdatapo^,po^,int2);
   int3:= fmaxcount * fsize-int1;
   move((fdatapo+int1)^,fdatapo^,int3);
   move(po^,(fdatapo+int3)^,int2);
   freemem(po);
  end
  else begin
   move((fdatapo+int1)^,fdatapo^,int1);
  end;
  fringpointer:= 0;
 end;
end;

procedure tdatalist.initdata(const index, anzahl: integer);
begin
 initdata1(true,index,anzahl);
end;

procedure tdatalist.forall(startindex: integer; const count: integer;
             const proc: dataprocty);
var
 int1: integer;
 po1: pchar;
begin if count > 0 then begin
  int1:= startindex+count-1;
  checkindex(startindex);
  checkindex(int1);
  po1:= fdatapo;
  if (fringpointer = 0) or (int1 >= startindex) then begin  //ein stueck
   inc(po1,startindex*fsize);
   for int1:= startindex to int1 do begin
    proc(po1^);
    inc(po1,fsize);
   end;
  end
  else begin
   for int1:= 0 to int1 do begin
    proc(po1^);
    inc(po1,fsize);
   end;
   po1:= fdatapo;
   inc(po1,startindex*fsize);
   for int1:= startindex to fmaxcount-1 do begin
    proc(po1^);
    inc(po1,fsize);
   end;
  end;
 end;
end;

function tdatalist.getsorted: boolean;
begin
 result:= dls_sorted in fstate;
end;

procedure tdatalist.setsorted(const Value: boolean);
begin
 if sorted <> value then begin
  if value then begin
   include(fstate,dls_sorted);
   sort;
  end
  else begin
   exclude(fstate,dls_sorted);
  end;
 end;
end;
{
function tdatalist.Getasvarrec(index: integer): tvarrec;
begin
 result.VType:= vtpointer;  //dummy
 result.VPointer:= nil;
end;

procedure tdatalist.Setasvarrec(index: integer; const Value: tvarrec);
begin
 //dummy
end;
}
{
procedure tdatalist.invalidateline(index: integer);
begin
 if assigned(foninvalidateline) then begin
  foninvalidateline(self,index);
 end;
end;
}

procedure tdatalist.assignb(const source: tdatalist);
begin
 source.assigntob(self);
end;

procedure tdatalist.assigntob(const dest: tdatalist);
begin
 raise exception.Create('Can not assigntob.');
end;

function tdatalist.datapo: pointer;
begin
 normalizering;
 result:= fdatapo;
end;

function tdatalist.datahighpo: pointer;
begin
 result:= nil;
 if fcount > 0 then begin
  result:= pchar(datapo) + (fcount-1)*fsize;
 end;
end;

function tdatalist.getitempo(index: integer): pointer;
begin
 checkindex(index);
 result:= fdatapo + index*fsize;
end;

procedure tdatalist.assign(sender: tpersistent);
begin
 if not assigndata(sender) then begin
  inherited;
 end;
end;

procedure tdatalist.clean(const start,stop: integer);
begin
 //dummy
end;

function tdatalist.getsourcecount: integer;
begin
 result:= 0;
end;

function tdatalist.getsourceinfo(const atag: integer): plistlinkinfoty;
begin
 result:= nil;
end;

function tdatalist.getsourcename(const atag: integer): string;
var
 po1: plistlinkinfoty;
begin
 po1:= getsourceinfo(atag);
 if po1 <> nil then begin
  result:= po1^.name;
 end
 else begin
  result:= '';
 end;
end;

function tdatalist.getlinkdatatypes(const atag: integer): listdatatypesty;
begin
 result:= [datatype];
end;

procedure tdatalist.initsource(var asource: listlinkinfoty);
begin
 fillchar(asource,sizeof(asource),0);
 with asource do begin
  dirtystop:= maxint;
 end;
end;

procedure tdatalist.removesource(var asource: listlinkinfoty);
begin
 with asource do begin
  if source <> nil then begin
   source.listdestroyed(self);
   source:= nil;
  end;
 end;
end;

procedure tdatalist.checklistdestroyed(var ainfo: listlinkinfoty;
                                                const sender: tdatalist);
begin
 if sender = ainfo.source then begin
  ainfo.source:= nil;
 end;
end;

procedure tdatalist.clearmemberitem(const subitem: integer;
               const index: integer);
begin
 //dummy
end;

procedure tdatalist.setmemberitem(const subitem: integer;
               const index: integer; const avalue: integer);
begin
 //dummy
end;

procedure tdatalist.setcheckeditem(const avalue: integer);
begin
 if (avalue < 0) or (avalue > fcount) then begin
  fcheckeditem:= -1;
 end
 else begin
  fcheckeditem:= avalue;
 end;
end;

procedure tdatalist.datadeleted(const aindex: integer; const acount: integer);
begin
 if fcheckeditem >= 0 then begin
  if fcheckeditem >= aindex then begin
   if fcheckeditem < aindex + acount then begin
    fcheckeditem:= -1;
   end
   else begin
    fcheckeditem:= fcheckeditem - acount;
    if fcheckeditem < 0 then begin
     fcheckeditem:= -1;
    end;
   end;
  end;
 end;
end;

procedure tdatalist.datainserted(const aindex: integer; const acount: integer);
begin
 if (fcheckeditem >= 0) and (fcheckeditem >= aindex) then begin
  fcheckeditem:= fcheckeditem + acount;
  if fcheckeditem >= fcount then begin
   fcheckeditem:= -1;
  end;
 end;
end;

procedure tdatalist.datamoved(const fromindex: integer; const toindex: integer;
               const acount: integer);
begin
 if (fcheckeditem >= 0) and (fcheckeditem >= fromindex) and 
                        (fcheckeditem < fromindex+acount) then begin
  fcheckeditem:= fcheckeditem + toindex - fromindex;
  if (fcheckeditem < 0) or (fcheckeditem >= fcount) then begin
   fcheckeditem:= -1;
  end;
 end;
end;

procedure tdatalist.linkclient(const aclient: idatalistclient);
begin
 aclient.getobjectlinker.link(aclient,iobjectlink(self),nil,
                                                   typeinfo(idatalistclient));
 include(fstate,dls_remote);
 aclient.itemchanged(self,-1);
end;

procedure tdatalist.unlinkclient(const aclient: idatalistclient);
begin
 aclient.getobjectlinker.unlink(aclient,iobjectlink(self),nil);
end;

function tdatalist.getastext(const index: integer): msestring;
begin
 result:= '';
end;

procedure tdatalist.setastext(const index: integer; const avalue: msestring);
begin
 //dummy
end;

{ tintegerdatalist }

constructor tintegerdatalist.create;
begin
 inherited;
 fsize:= sizeof(integer);
 min:= minint;
 max:= maxint;
 fcheckeditem:= -1;
end;

procedure tintegerdatalist.number(const start,step: integer);
var
 int1,int2: integer;
begin
 int2:= start;
 beginupdate;
 try
  for int1:= 0 to count-1 do begin
   internalsetdata(int1,int2);
   int2:= int2 + step;
  end;
 finally
  endupdate;
 end;
end;

function tintegerdatalist.add(const value: integer): integer;
begin
 result:= adddata(value);
end;
{
procedure tintegerdatalist.assign(source: tpersistent);
begin
 if not assigndata(source) then begin
  inherited;
 end;
end;
}
function tintegerdatalist.Getitems(const index: integer): integer;
begin
 internalgetdata(index,result);
end;

procedure tintegerdatalist.insert(const index: integer; const item: integer);
begin
 insertdata(index,item);
end;

procedure tintegerdatalist.Setitems(const index: integer; const Value: integer);
begin
 internalsetdata(index,value);
end;

function tintegerdatalist.datatype: listdatatypety;
begin
 result:= dl_integer;
end;

function tintegerdatalist.empty(const index: integer): boolean;
var
 po1: pointer;
begin
 po1:= getdefault;
 if po1 = nil then begin
  result:= pinteger(getitempo(index))^ = 0;
 end
 else begin
  result:= pinteger(getitempo(index))^ = pinteger(po1)^;
 end;
end;

procedure tintegerdatalist.compare(const l, r; var result: integer);
begin
 result:= integer(l)-integer(r);
end;

function tintegerdatalist.find(value: integer): integer;
var
 int1: integer;
begin
 result:= -1;
 for int1:= 0 to fcount-1 do begin
  if integer(pointer(fdatapo+int1*fsize)^) = value then begin
   result:= int1;
   break;
  end;
 end;
end;

procedure tintegerdatalist.fill(acount: integer; const defaultvalue: integer);
begin
 internalfill(count,defaultvalue);
end;

function tintegerdatalist.getasarray: integerarty;
begin
 setlength(result,fcount);
 internalgetasarray(pointer(result),sizeof(integer));
end;

procedure tintegerdatalist.setasarray(const avalue: integerarty);
begin
 internalsetasarray(pointer(avalue),sizeof(integer),length(avalue));
end;

function tintegerdatalist.getasbooleanarray: booleanarty;
var
 po1: pinteger;
 int1: integer;
begin
 setlength(result,fcount);
 po1:= datapo;
 for int1:= 0 to high(result) do begin
  result[int1]:= po1^ <> 0;
  inc(pchar(po1),fsize);
 end;
end;

procedure tintegerdatalist.setasbooleanarray(const avalue: booleanarty);
var
 int1: integer;
 po1: plongbool;
begin
 newbuffer(length(avalue),true,size > sizeof(integer));
 po1:= pointer(fdatapo);
 for int1:= 0 to high(avalue) do begin
  po1^:= avalue[int1];
  inc(pchar(po1),fsize);
 end;
 change(-1); 
end;

function tintegerdatalist.getstatdata(const index: integer): msestring;
begin
 result:= inttostr(items[index]);
end;

procedure tintegerdatalist.setstatdata(const index: integer; const value: msestring);
var
 int1: integer;
begin
 int1:= strtoint(value);
 if int1 < min then begin
  int1:= min;
 end
 else begin
  if int1 > max then begin
   int1:= max;
  end;
 end;
 setdata(index,int1);
end;

procedure tintegerdatalist.writeappendix(const writer; const aname: msestring);
begin
 with tstatwriter(writer) do begin
  writeinteger(aname+'_ci',fcheckeditem);
 end; 
end;

procedure tintegerdatalist.readappendix(const reader; const aname: msestring);
begin
 with tstatreader(reader) do begin
  fcheckeditem:= readinteger(aname+'_ci',fcheckeditem,-1,count-1);
 end;
end;

procedure tintegerdatalist.readitem(const reader: treader; var value);
begin
 integer(value):= reader.ReadInteger;
end;

procedure tintegerdatalist.writeitem(const writer: twriter; var value);
begin
 writer.writeinteger(integer(value))
end;

function tintegerdatalist.checkassigncompatibility(const source: tpersistent): boolean;
begin
 result:= source.inheritsfrom(tintegerdatalist);
end;

function tintegerdatalist.getastext(const index: integer): msestring;
begin
 result:= inttostr(items[index]);
end;

procedure tintegerdatalist.setastext(const index: integer;
               const avalue: msestring);
var
 int1: integer;
begin
 if trystrtoint(avalue,int1) then begin
  items[index]:= int1;
 end;
end;

procedure tintegerdatalist.fill(const defaultvalue: integer);
begin
 fill(count,defaultvalue);
end;

{ tbooleandatalist }

procedure tbooleandatalist.setasarray(const avalue: longboolarty);
begin
 inherited asarray:= integerarty(avalue);
end;

function tbooleandatalist.getasarray: longboolarty;
begin
 result:= longboolarty(inherited asarray);
end;

function tbooleandatalist.getitems(const index: integer): boolean;
begin
 result:= inherited items[index] <> 0;
end;

procedure tbooleandatalist.setitems(const index: integer;
               const avalue: boolean);
begin
 inherited items[index]:= longint(longbool(avalue));
end;

procedure tbooleandatalist.fill(acount: integer; const defaultvalue: boolean);
begin
 inherited fill(acount,ord(longbool(defaultvalue)));
end;

procedure tbooleandatalist.fill(const defaultvalue: boolean);
begin
 fill(count,defaultvalue);
end;

{ tint64datalist }

constructor tint64datalist.create;
begin
 inherited;
 fsize:= sizeof(int64);
// min:= minint;
// max:= maxint;
end;

function tint64datalist.datatype: listdatatypety;
begin
 result:= dl_int64;
end;
{
procedure tint64datalist.assign(source: tpersistent);
begin
 if not assigndata(source) then begin
  inherited;
 end;
end;
}
function tint64datalist.Getitems(index: integer): int64;
begin
 internalgetdata(index,result);
end;

procedure tint64datalist.Setitems(index: integer; const avalue: int64);
begin
 internalsetdata(index,avalue);
end;

procedure tint64datalist.setasarray(const value: int64arty);
begin
 internalsetasarray(pointer(value),sizeof(int64),length(value));
end;

function tint64datalist.getasarray: int64arty;
begin
 setlength(result,fcount);
 internalgetasarray(pointer(result),sizeof(int64));
end;

procedure tint64datalist.readitem(const reader: treader; var value);
begin
 int64(value):= reader.ReadInt64;
end;

procedure tint64datalist.writeitem(const writer: twriter; var value);
begin
 writer.writeinteger(int64(value))
end;

procedure tint64datalist.compare(const l; const r; var result: integer);
begin
 result:= int64(l)-int64(r);
end;

procedure tint64datalist.setstatdata(const index: integer;
               const value: msestring);
var
 int1: int64;
begin
 int1:= strtoint64(value);
 setdata(index,int1);
end;

function tint64datalist.getstatdata(const index: integer): msestring;
begin
 result:= inttostr(items[index]);
end;

function tint64datalist.empty(const index: integer): boolean;
var
 po1: pointer;
begin
 po1:= getdefault;
 if po1 = nil then begin
  result:= pint64(getitempo(index))^ = 0;
 end
 else begin
  result:= pint64(getitempo(index))^ = pinteger(po1)^;
 end;
end;

function tint64datalist.add(const avalue: int64): integer;
begin
 result:= adddata(avalue);
end;

procedure tint64datalist.insert(const index: integer; const avalue: int64);
begin
 insertdata(index,avalue);
end;

function tint64datalist.find(const avalue: int64): integer;
var
 int1: integer;
begin
 result:= -1;
 for int1:= 0 to fcount-1 do begin
  if int64(pointer(fdatapo+int1*fsize)^) = avalue then begin
   result:= int1;
   break;
  end;
 end;
end;

procedure tint64datalist.fill(const acount: integer; const defaultvalue: int64);
begin
 internalfill(count,defaultvalue);
end;

function tint64datalist.checkassigncompatibility(const source: tpersistent): boolean;
begin
 result:= source.inheritsfrom(tint64datalist);
end;

function tint64datalist.getastext(const index: integer): msestring;
begin
 result:= inttostr(items[index]);
end;

procedure tint64datalist.setastext(const index: integer;
               const avalue: msestring);
var
 int1: int64;
begin
 if trystrtoint64(avalue,int1) then begin
  items[index]:= int1;
 end;
end;

procedure tint64datalist.fill(const defaultvalue: int64);
begin
 fill(count,defaultvalue);
end;

{ tcurrencydatalist }

constructor tcurrencydatalist.create;
begin
 inherited;
 fsize:= sizeof(currency);
// min:= minint;
// max:= maxint;
end;

function tcurrencydatalist.datatype: listdatatypety;
begin
 result:= dl_currency;
end;
{
procedure tcurrencydatalist.assign(source: tpersistent);
begin
 if not assigndata(source) then begin
  inherited;
 end;
end;
}
function tcurrencydatalist.Getitems(index: integer): currency;
begin
 internalgetdata(index,result);
end;

procedure tcurrencydatalist.Setitems(index: integer; const avalue: currency);
begin
 internalsetdata(index,avalue);
end;

procedure tcurrencydatalist.setasarray(const value: currencyarty);
begin
 internalsetasarray(pointer(value),sizeof(currency),length(value));
end;

function tcurrencydatalist.getasarray: currencyarty;
begin
 setlength(result,fcount);
 internalgetasarray(pointer(result),sizeof(currency));
end;

procedure tcurrencydatalist.readitem(const reader: treader; var value);
begin
 currency(value):= reader.Readcurrency;
end;

procedure tcurrencydatalist.writeitem(const writer: twriter; var value);
begin
 writer.writecurrency(currency(value))
end;

procedure tcurrencydatalist.compare(const l; const r; var result: integer);
var
 cur1: currency;
begin
 result:= 0;
 cur1:= currency(l)-currency(r);
 if cur1 < 0 then begin
  result:= -1;
 end
 else begin
  if cur1 > 0 then begin
   result:= 1;
  end;
 end;
end;

procedure tcurrencydatalist.setstatdata(const index: integer;
               const value: msestring);
var
 int1: currency;
begin
 int1:= strtocurr(value);
 setdata(index,int1);
end;

function tcurrencydatalist.getstatdata(const index: integer): msestring;
begin
 result:= currtostr(items[index]);
end;

function tcurrencydatalist.empty(const index: integer): boolean;
var
 po1: pointer;
begin
 po1:= getdefault;
 if po1 = nil then begin
  result:= pcurrency(getitempo(index))^ = 0;
 end
 else begin
  result:= pcurrency(getitempo(index))^ = pinteger(po1)^;
 end;
end;

function tcurrencydatalist.add(const avalue: currency): integer;
begin
 result:= adddata(avalue);
end;

procedure tcurrencydatalist.insert(const index: integer; const avalue: currency);
begin
 insertdata(index,avalue);
end;

function tcurrencydatalist.find(const avalue: currency): integer;
var
 int1: integer;
begin
 result:= -1;
 for int1:= 0 to fcount-1 do begin
  if currency(pointer(fdatapo+int1*fsize)^) = avalue then begin
   result:= int1;
   break;
  end;
 end;
end;

procedure tcurrencydatalist.fill(const acount: integer; const defaultvalue: currency);
begin
 internalfill(count,defaultvalue);
end;

function tcurrencydatalist.checkassigncompatibility(const source: tpersistent): boolean;
begin
 result:= source.inheritsfrom(tcurrencydatalist);
end;

function tcurrencydatalist.getastext(const index: integer): msestring;
begin
 result:= currtostr(items[index]);
end;

procedure tcurrencydatalist.setastext(const index: integer;
               const avalue: msestring);
var
 cu1: currency;
begin
 if trystrtocurr(avalue,cu1) then begin
  items[index]:= cu1;
 end;
end;

procedure tcurrencydatalist.fill(const defaultvalue: currency);
begin
 fill(count,defaultvalue);
end;

{ tenumdatalist }

constructor tenumdatalist.create(agetdefault: getintegereventty);
begin
 inherited create;
 fgetdefault:= agetdefault;
end;

function tenumdatalist.empty(const index: integer): boolean;
begin
 result:= integer(getitempo(index)^) = fgetdefault();
end;

function tenumdatalist.getdefault: pointer;
begin
 fdefaultval:= fgetdefault();
 result:= @fdefaultval;
end;

{ tenum64datalist }

constructor tenum64datalist.create(agetdefault: getint64eventty);
begin
 inherited create;
 fgetdefault:= agetdefault;
end;

function tenum64datalist.empty(const index: integer): boolean;
begin
 result:= int64(getitempo(index)^) = fgetdefault();
end;

function tenum64datalist.getdefault: pointer;
begin
 fdefaultval:= fgetdefault();
 result:= @fdefaultval;
end;

{ trealdatalist }

constructor trealdatalist.create;
begin
 inherited;
 fsize:= sizeof(real);
 min:= emptyreal;
 max:= bigreal;
 fdefaultval:= emptyreal;
end;

function trealdatalist.getdefault: pointer;
begin
 if fdefaultzero then begin
  result:= nil;
 end
 else begin
  result:= @fdefaultval;
 end;
end;

procedure trealdatalist.number(start,step: real);
var
 int1: integer;
 rea1: real;
begin
 beginupdate;
 try
  for int1:= 0 to count-1 do begin
   rea1:= start+int1*step;
   internalsetdata(int1,rea1);
  end;
 finally
  endupdate;
 end;
end;

function trealdatalist.add(const value: real): integer;
begin
 result:= adddata(value);
end;
{
procedure trealdatalist.assign(source: tpersistent);
begin
 if not assigndata(source) then begin
  inherited;
 end;
end;
}
procedure trealdatalist.assignre(source: tcomplexdatalist);
begin
 source.assigntodata(self);
end;

procedure trealdatalist.assignim(source: tcomplexdatalist);
begin
 source.assigntob(self);
end;

procedure trealdatalist.insert(index: integer; const item: realty);
begin
 insertdata(index,item);
end;

function trealdatalist.Getitems(index: integer): realty;
begin
 checkindex(index);
 result:= prealty(pointer(fdatapo+index*fsize))^;
// internalgetdata(index,result);
end;

procedure trealdatalist.Setitems(index: integer; const Value: realty);
var
 int1: integer;
begin
 int1:= index;
 checkindex(index);
 prealty(pointer(fdatapo+index*fsize))^:= value;
 change(int1);
// internalsetdata(index,value);
end;

function trealdatalist.getasarray: realarty;
begin
 setlength(result,fcount);
 internalgetasarray(pointer(result),sizeof(realty));
end;

procedure trealdatalist.setasarray(const data: realarty);
begin
 internalsetasarray(pointer(data),sizeof(realty),length(data));
end;

function trealdatalist.datatype: listdatatypety;
begin
 result:= dl_real;
end;

function trealdatalist.empty(const index: integer): boolean;
var
 po1: preal;
begin
 po1:= preal(getitempo(index));
 result:= isemptyreal(po1^);
 if fdefaultzero then begin
  result:= result or (po1^ = 0);
 end;
end;

procedure trealdatalist.compare(const l, r; var result: integer);
begin
 result:= cmprealty(real(l),real(r));
end;

procedure trealdatalist.fill(acount: integer; const defaultvalue: realty);
begin
 internalfill(count,defaultvalue);
end;

procedure trealdatalist.minmax(out minval,maxval: realty);
var
 int1: integer;
 po1: prealty;
 min1,max1: realty;
begin
 min1:= bigreal;
 max1:= emptyreal;
 po1:= datapo;
 for int1:= count-1 downto 0 do begin
  if isemptyreal(po1^) then begin
   min1:= po1^;
  end
  else begin
   if isemptyreal(max1) or (po1^ > max1) then begin
    max1:= po1^;
   end;
   if not isemptyreal(min1) and (min1 > po1^) then begin
    min1:= po1^;
   end;
  end;
  inc(pchar(po1),fsize);
 end;
 minval:= min1;
 maxval:= max1;
end;

function trealdatalist.getstatdata(const index: integer): msestring;
begin
 result:= realtytostrdot(items[index]);
end;

procedure trealdatalist.setstatdata(const index: integer; const value: msestring);
var
 rea1: realty;
begin
 rea1:= strtorealtydot(value);
 if cmprealty(rea1,min) < 0 then begin
  rea1:= min;
 end
 else begin
  if cmprealty(rea1,max) > 0 then begin
   rea1:= max;
  end;
 end;
 items[index]:= rea1;
end;

procedure trealdatalist.readitem(const reader: treader; var value);
begin
 realty(value):= readrealty(reader);
end;

procedure trealdatalist.writeitem(const writer: twriter; var value);
begin
 writer.writefloat(double(value));
// writerealty(writer,realty(value));
end;

function trealdatalist.checkassigncompatibility(const source: tpersistent): boolean;
begin
 result:= source.inheritsfrom(trealdatalist);
end;

function trealdatalist.getastext(const index: integer): msestring;
var
 rea1: realty;
begin
 result:= '';
 rea1:= items[index];
 if not isemptyreal(rea1) then begin
  result:= doubletostring(rea1,0,fsm_default,
                              defaultformatsettingsmse.decimalseparator);
 end;
end;

procedure trealdatalist.setastext(const index: integer;
               const avalue: msestring);
var
 rea1: realty;
begin
 if avalue = '' then begin
  items[index]:= emptyreal;
 end
 else begin
  if trystrtofloat(avalue,double(rea1)) then begin
   items[index]:= rea1;
  end;
 end;
end;

procedure trealdatalist.fill(const defaultvalue: realty);
begin
 fill(count,defaultvalue);
end;

{ tdatetimedatalist }

function tdatetimedatalist.datatype: listdatatypety;
begin
 result:= dl_datetime;
end;

function tdatetimedatalist.empty(const index: integer): boolean;
begin
 result:= preal(getitempo(index))^ = 0;
end;

procedure tdatetimedatalist.fill(acount: integer;
  const defaultvalue: tdatetime);
begin
 internalfill(count,defaultvalue);
end;

function tdatetimedatalist.getdefault: pointer;
begin
 result:= nil; //-> 0.0
end;

procedure tdatetimedatalist.fill(const defaultvalue: tdatetime);
begin
 fill(count,defaultvalue);
end;

{ tcomplexdatalist }

constructor tcomplexdatalist.create;
begin
 min:= emptyreal;
 max:= bigreal;
 fdefaultval.re:= emptyreal;
 fdefaultval.im:= emptyreal;
 inherited;
 fsize:= sizeof(complexty);
end;

function tcomplexdatalist.add(const value: complexty): integer;
begin
 result:= adddata(value);
end;

procedure tcomplexdatalist.assign(source: tpersistent);
begin
 if not assigndata(source) then begin
  if source is trealdatalist then begin
   assignre(trealdatalist(source));
  end
  else begin
   inherited;
  end;
 end;
end;

procedure tcomplexdatalist.assignb(const source: tdatalist);
var
 int1: integer;
 po1,po2: pcomplexty;
 s1,s2: integer;
begin
 if source = self then begin
  exit;
 end;
 if source is tcomplexdatalist then begin
  beginupdate;
  count:= source.count;
  po1:= datapo;
  po2:= source.datapo;
  s1:= size;
  s2:= source.size;
  for int1:= 0 to fcount-1 do begin
   po1^.im:= po2^.im;
   inc(pchar(po1),s1);
   inc(pchar(po2),s2);
  end;
  endupdate;
 end
 else begin
  if source is trealdatalist then begin
   assignim(trealdatalist(source));
  end
  else begin
   inherited;
  end;
 end;
end;

procedure tcomplexdatalist.assignre(const source: trealdatalist);
begin
 source.assigntodata(self);
end;

procedure tcomplexdatalist.assignim(const source: trealdatalist);
var
 int1: integer;
 po1: pcomplexty;
 po2: prealty;
 s1,s2: integer;
begin
 beginupdate;
 count:= source.count;
 po1:= datapo;
 po2:= source.datapo;
 s1:= size;
 s2:= source.size;
 for int1:= 0 to fcount-1 do begin
  po1^.im:= po2^;
  inc(pchar(po1),s1);
  inc(pchar(po2),s2);
 end;
 endupdate;
end;

procedure tcomplexdatalist.assigntoa(const dest: tdatalist);
begin
 dest.assign(self);
end;

procedure tcomplexdatalist.assigntob(const dest: tdatalist);
var
 int1: integer;
 po1: pcomplexty;
 po2: prealty;
 s1,s2: integer;
begin
 if dest is trealdatalist then begin
  with trealdatalist(dest) do begin
   newbuffer(count,true,dest.size > sizeof(real));
   po1:= self.datapo;
   po2:= pointer(fdatapo);
   s1:= self.size;
   s2:= size;
   for int1:= 0 to fcount-1 do begin
    po2^:= po1^.im;
    inc(pchar(po1),s1);
    inc(pchar(po2),s2);
   end;
   change(-1);
  end;
 end
 else begin
  inherited;
 end;
end;

procedure tcomplexdatalist.assignto(dest: tpersistent);
begin
 if dest is trealdatalist then begin
  assigntodata(trealdatalist(dest));
 end
 else begin
  inherited;
 end;
end;

function tcomplexdatalist.Getitems(const index: integer): complexty;
begin
 internalgetdata(index,result);
end;

procedure tcomplexdatalist.insert(const index: integer; const item: complexty);
begin
 insertdata(index,item);
end;

procedure tcomplexdatalist.Setitems(const index: integer; const Value: complexty);
begin
 internalsetdata(index,value);
end;

function tcomplexdatalist.datatype: listdatatypety;
begin
 result:= dl_complex;
end;

function tcomplexdatalist.empty(const index: integer): boolean;
var
 po1: pcomplexty;
begin
 po1:= getitempo(index);
 result:= isemptyreal(po1^.re) and isemptyreal(po1^.im);
 if fdefaultzero then begin
  result:= result or (po1^.re = 0) and (po1^.im = 0);
 end;
end;

function tcomplexdatalist.getdefault: pointer;
begin
 if fdefaultzero then begin
  result:= nil;
 end
 else begin
//  fdefaultval.re:= emptyreal;
//  fdefaultval.im:= emptyreal;
  result:= @fdefaultval;
 end;
end;

function tcomplexdatalist.getasarray: complexarty;
begin
 setlength(result,fcount);
 internalgetasarray(pointer(result),sizeof(complexty));
end;

procedure tcomplexdatalist.setasarray(const data: complexarty);
begin
 internalsetasarray(pointer(data),sizeof(complexty),length(data));
end;

procedure tcomplexdatalist.fill(const acount: integer;
  const defaultvalue: complexty);
begin
 internalfill(count,defaultvalue);
end;

procedure tcomplexdatalist.readitem(const reader: treader; var value);
begin
 reader.ReadListBegin;
 complexty(value).re:= readrealty(reader);
 complexty(value).im:= readrealty(reader);
 reader.readlistend;
end;

procedure tcomplexdatalist.writeitem(const writer: twriter; var value);
begin
 with writer do begin
  writelistbegin;
  writer.writefloat(complexty(value).re);
  writer.writefloat(complexty(value).im);
//  writerealty(writer,complexty(value).re);
//  writerealty(writer,complexty(value).im);
  writelistend;
 end;
end;

function tcomplexdatalist.checkassigncompatibility(const source: tpersistent): boolean;
begin
 result:= source.inheritsfrom(tcomplexdatalist);
end;

procedure tcomplexdatalist.fill(const defaultvalue: complexty);
begin
 fill(count,defaultvalue);
end;

{ tpointerdatalist }

constructor tpointerdatalist.create;
begin
 inherited;
 fsize:= sizeof(pointer);
end;

function tpointerdatalist.Getitems(index: integer): pointer;
begin
 internalgetdata(index,result);
end;

procedure tpointerdatalist.Setitems(index: integer; const Value: pointer);
begin
 internalsetdata(index,value);
end;

function tpointerdatalist.getasarray: pointerarty;
begin
 setlength(result,fcount);
 internalgetasarray(pointer(result),sizeof(pointer));
end;

procedure tpointerdatalist.setasarray(const data: pointerarty);
begin
 internalsetasarray(pointer(data),sizeof(pointer),length(data));
end;

function tpointerdatalist.checkassigncompatibility(const source: tpersistent): boolean;
begin
 result:= source.inheritsfrom(tpointerdatalist);
end;

{ tdynamicdatalist }

constructor tdynamicdatalist.create;
begin
 inherited;
 fstate:= fstate + [dls_needsfree,dls_needscopy];
end;
{
destructor tdynamicdatalistmse.destroy;
begin
 clear;
 inherited;
end;
}

{ tdynamicpointerdatalist }

constructor tdynamicpointerdatalist.create;
begin
 inherited;
 fsize:= sizeof(pointer);
end;

{ tansistringdatalist }

function tansistringdatalist.add(const value: ansistring): integer;
begin
 result:= adddata(value);
end;

function tansistringdatalist.addtext(const value: ansistring): integer;
                //returns added linecount
var
 ar1: stringarty;
 int1,int2: integer;
begin
 ar1:= nil; //compiler warning
 if value <> '' then begin
  beginupdate;
  ar1:= breaklines(value);
  int1:= count;
  if int1 = 0 then begin
   result:= length(ar1);
  end
  else begin
   result:= high(ar1);
  end;
  count:= count + result;
  items[int1]:= items[int1] + ar1[0];
  for int2:= 1 to high(ar1) do begin
   items[int1+int2]:= ar1[int2];
  end;
  endupdate;
 end
 else begin
  result:= 0;
 end;
end;

procedure tansistringdatalist.assign(source: tpersistent);
var
 int1: integer;
 po1,po2: pansistring;
 s1,s2: integer;
begin
 if not assigndata(source) then begin
  if source is tstringlist then begin
   with tstringlist(source) do begin
    self.newbuffer(count,false,true);
    po1:= self.datapo;
    s1:= self.size;
    for int1:= 0 to self.fcount - 1 do begin
     po1^:= strings[int1];
     inc(pchar(po1),s1);
    end;
   end;
   change(-1);
  end
  else begin
   inherited;
  end;
 end;
end;

procedure tansistringdatalist.assignopenarray(const data: array of ansistring);
var
 po1: pstring;
 int1: integer;
 s1: integer;
begin
 newbuffer(length(data),true,true);
 po1:= pointer(fdatapo);
 s1:= size;
 for int1:= 0 to fcount - 1 do begin
  po1^:= data[int1];
  inc(pchar(po1),s1);
 end;
 change(-1);
end;
{
procedure tansistringdatalist.assignarray(const data: stringarty);
var
 int1: integer;
 po1: pansistring;
 s1: integer;
begin
 beginupdate;
 try
  count:= 0;
  count:= length(data);
  po1:= pointer(fdatapo);
  s1:= size;
  for int1:= 0 to length(data)-1 do begin
   po1^:= data[int1];
   inc(pchar(po1),s1);
  end;
 finally
  endupdate;
 end;
end;

procedure tansistringdatalist.assignarray(const data: msestringarty);
var
 int1: integer;
 po1: pansistring;
 s1: integer;
begin
 beginupdate;
 try
  count:= 0;
  count:= length(data);
  po1:= datapo;
  s1:= size;
  for int1:= 0 to length(data)-1 do begin
   po1^:= ansistring(data[int1]);
   inc(pchar(po1),s1);
  end;
 finally
  endupdate;
 end;
end;
}
function tansistringdatalist.Getitems(index: integer): ansistring;
begin
 result:= pansistring(getitempo(index))^;
end;

procedure tansistringdatalist.insert(index: integer; const item: ansistring);
begin
 insertdata(index,item);
end;

procedure tansistringdatalist.Setitems(index: integer; const Value: ansistring);
begin
 pansistring(getitempo(index))^:= value;
 change(index);
end;

function tansistringdatalist.datatype: listdatatypety;
begin
 result:= dl_ansistring;
end;

function tansistringdatalist.empty(const index: integer): boolean;
begin
 result:=  pansistring(getitempo(index))^ = '';
end;

procedure tansistringdatalist.freedata(var data);
begin
 ansistring(data):= '';
end;

procedure tansistringdatalist.copyinstance(var data);
begin
 stringaddref(ansistring(data));
// reallocstring(ansistring(data));
end;

procedure tansistringdatalist.assignto(dest: tpersistent);
var
 int1: integer;
 po1: pansistring;
 s1: integer;
begin
 if dest is tstringlist then begin
  po1:= datapo;
  s1:= size;
  with tstringlist(dest) do begin
   clear;
   capacity:= self.count;
   for int1:= 0 to self.count-1 do begin
    add(po1^);
    inc(pchar(po1),s1);
   end;
  end;
 end
 else begin
  inherited;
 end;
end;

procedure tansistringdatalist.compare(const l, r; var result: integer);
begin
 result:= comparestr(ansistring(l),ansistring(r));
end;
{$define fpcbug4519read}
(*
{$ifdef FPC} {$define fpcbug4519} {$endif}

{$ifdef fpcbug4519}
type
 tbynaryobjectwriter1 = class(tbinaryobjectwriter);
 treader1 = class(treader);
 
procedure writestring4519(const writer: twriter; const avalue: string);
begin
 if avalue = '' then begin
  tbynaryobjectwriter1(writer.driver).writeinteger(0);
 end
 else begin
  writer.writestring(avalue);
 end;
end;

procedure writewidestring4519(const writer: twriter; const avalue: msestring);
begin
 if avalue = '' then begin
  tbynaryobjectwriter1(writer.driver).writeinteger(0);
 end
 else begin
  writer.writewidestring(avalue);
 end;
end;

{$endif}
*)

{$ifdef fpcbug4519read}
function readstring4519(const reader: treader): string;
begin
 if reader.nextvalue = vaint8 then begin
  reader.readinteger;
  result:= '';
 end
 else begin
  result:= reader.readstring;
 end;
end;

function readwidestring4519(const reader: treader): msestring;
begin
 if reader.nextvalue = vaint8 then begin
  reader.readinteger;
  result:= '';
 end
 else begin
  result:= treader_readmsestring(reader);
// {$ifdef mse_unicodestring}
//  result:= reader.readunicodestring;
// {$else}
//  result:= reader.readwidestring;
// {$endif}
 end;
end;
{$endif}

procedure tansistringdatalist.readitem(const reader: treader; var value);
begin
 {$ifdef fpcbug4519read}
 string(value):= ReadString4519(reader);
 {$else}
 string(value):= reader.ReadString;
 {$endif}
end;

procedure tansistringdatalist.writeitem(const writer: twriter; var value);
begin
// {$ifdef fpcbug4519}
// WriteString4519(writer,string(value));
// {$else}
 writer.WriteString(string(value));
// {$endif}
end;
{
function tansistringdatalist.Getasvarrec(index: integer): tvarrec;
begin
 ansistringvar:= items[index];
 msestrtotvarrec(ansistringvar,result);
end;

procedure tansistringdatalist.Setasvarrec(index: integer;
  const Value: tvarrec);
begin
 items[index]:= tvarrectoansistring(value);
end;
}
procedure tansistringdatalist.fill(acount: integer;
  const defaultvalue: ansistring);
begin
 internalfill(count,defaultvalue);
end;

function tansistringdatalist.getstatdata(const index: integer): msestring;
begin
 result:= items[index];
end;

procedure tansistringdatalist.setstatdata(const index: integer; const value: msestring);
begin
 items[index]:= value;
end;

function tansistringdatalist.getasarray: stringarty;
begin
 setlength(result,fcount);
 internalgetasarray(pointer(result),sizeof(string));
end;

procedure tansistringdatalist.setasarray(const avalue: stringarty);
begin
 internalsetasarray(pointer(avalue),sizeof(string),length(avalue));
end;

function tansistringdatalist.getasmsestringarray: msestringarty;
var
 po1: pstring;
 int1: integer;
 s1: integer;
begin
 setlength(result,fcount);
 po1:= datapo;
 for int1:= 0 to fcount - 1 do begin
  result[int1]:= po1^;
  inc(pchar(po1),s1);
 end;
end;

procedure tansistringdatalist.setasmsestringarray(const avalue: msestringarty);
var
 po1: pstring;
 s1: integer;
 int1: integer;
begin
 newbuffer(length(avalue),true,true);
 po1:= pointer(fdatapo);
 s1:= size;
 for int1:= 0 to high(avalue) do begin
  po1^:= avalue[int1];
  inc(pchar(po1),s1);
 end;
 change(-1);
end;

function tansistringdatalist.checkassigncompatibility(const source: tpersistent): boolean;
begin
 result:= source.inheritsfrom(tansistringdatalist);
end;

function tansistringdatalist.getastext(const index: integer): msestring;
begin
 result:= items[index];
end;

procedure tansistringdatalist.setastext(const index: integer;
               const avalue: msestring);
begin
 items[index]:= avalue;
end;

function tansistringdatalist.textlength: integer;
var
 int1,int2: integer;
 po1: pchar;
begin 
 po1:= datapo;
 int2:= 0;
 for int1:= 0 to fcount - 1 do begin
  inc(int2,length(ansistring(pointer(po1)^)));
  inc(po1,fsize);
 end;
 result:= int2;
end;

function tansistringdatalist.gettext: ansistring;
var
 po1: pansistring;
 po2: pansichar;
 int1: integer;
 int2: integer;
 ch1,ch2: ansichar;
begin
 if count = 0 then begin
  result:='';
  exit;
 end;
 int2:= textlength;
 int2:= int2 + count * length(lineend);
 setlength(result,int2);
 ch1:= string(lineend)[1];
 if length(lineend) > 1 then begin
  ch2:= string(lineend)[2];
 end;
 po1:= datapo;
 po2:= pointer(result);
 for int1:= count-1 downto 0 do begin
  int2:= length(po1^);
  if int2 <> 0 then begin
   move(pointer(po1^)^,po2^,int2*sizeof(ansichar));
   inc(po2,int2);
  end;
  po2^:= ch1;
  inc(po2);
  if length(lineend) > 1 then begin
   po2^:= ch2;
   inc(po2);
  end;
  inc(pchar(po1),fsize);
 end;
 setlength(result,length(result)-length(lineend)); //remove last lineend
end;

procedure tansistringdatalist.settext(const avalue: ansistring);
begin
 asarray:= breaklines(avalue);
end;

{ tpoorstringdatalist }

function tpoorstringdatalist.add(const value: tmsestringdatalist): integer;
var
 int1,int2: integer;
begin
 result:= fcount;
 beginupdate;
 with value do begin
  self.count:= fcount+self.fcount;
  int2:= self.fcount-fcount;
  int1:= 0;
  if int2 < 0 then begin
   int1:= int1-int2;
   int2:= 0;
  end;
  for int1:= int1 to fcount - 1 do begin
   self.items[int2]:= items[int1];
   inc(int2);
  end;
 end;
 endupdate;
end;

function tpoorstringdatalist.add(const avalue: msestring;
                                 const anoparagraph: boolean): integer; 
begin
 add(avalue);
end;                                                              

function tpoorstringdatalist.addchars(const value: msestring;
                    const processeditchars: boolean = true;
                    const maxchars: integer = 0): integer;		
var
 int1,int2,int3,int4: integer;
 ar1,ar2: msestringarty;
 ar3,ar4: booleanarty;
 first: pmsestring;
 mstr1: msestring; 
begin
 ar1:= nil; //compilerwarning
 if value <> '' then begin
  ar1:= breaklines(value);
  if fcount = 0 then begin
   count:= 1;
  end;
  int1:= fcount - 1;
  int2:= int1;
  checkindex(int1);
  first:= pmsestring(fdatapo+int1*fsize);
  if processeditchars then begin
   mstr1:= first^;
   addeditchars(ar1[0],mstr1,feditcharindex);
   ar1[0]:= mstr1;
   for int1:= 1 to high(ar1) do begin
    mstr1:= '';
    feditcharindex:= 0;
    addeditchars(ar1[int1],mstr1,feditcharindex);
    ar1[int1]:= mstr1;
   end;
  end
  else begin
   ar1[0]:=first^ + ar1[0];
   for int1:= 1 to high(ar1) do begin
    add(ar1[int1]);
   end;
  end;
  if maxchars <> 0 then begin
   int2:= 0;
   for int1:= 0 to high(ar1) do begin        //calc new linecount
    int2:= int2 + length(ar1[int1]) div maxchars + 1;
   end;
   if int2 <> length(ar1) then begin    //break lines
    setlength(ar2,int2);
    setlength(ar4,int2);
    setlength(ar3,int2+1);
    int2:= 0;
    for int1:= 0 to high(ar1) do begin
     ar4[int2]:= true;
     int3:= length(ar1[int1]);
     if int3 > maxchars then begin
      int4:= 1;
      while int4 <= int3 do begin
       ar2[int2]:= copy(ar1[int1],int4,maxchars);
       int4:= int4 + maxchars;
       inc(int2);
       ar3[int2]:= true;
      end;
     end
     else begin
      ar2[int2]:= ar1[int1];
      inc(int2);
     end;
    end;  
    ar1:= ar2;
   end;
  end;
  setlength(ar3,length(ar1));
  setlength(ar4,length(ar1));
  if high(ar1) > 0 then begin
   beginupdate;
  end;
  first^:= ar1[0];
  for int1:= 1 to high(ar1) do begin
   add(ar1[int1],ar3[int1] and not ar4[int1]);
  end;
  if high(ar1) > 0 then begin
   endupdate;
  end
  else begin
   change(fcount-1);
  end;
 end;
 result:= fcount-1;
end;

{
function tpoorstringdatalist.addchars(const value: msestring;
                    const processeditchars: boolean = true;
                    const maxchars: integer = 0): integer;		
var
 int1,int2: integer;
 ar1: msestringarty;
 first: pmsestring;
 mstr1: msestring; 
begin
 ar1:= nil; //compilerwarning
 if value <> '' then begin
  ar1:= breaklines(value);
  if high(ar1) > 0 then begin
   beginupdate;
  end;
  if fcount = 0 then begin
   count:= 1;
  end;
  int1:= fcount - 1;
  int2:= int1;
  checkindex(int1);
  first:= pmsestring(fdatapo+int1*fsize);
  if processeditchars then begin
   addeditchars(ar1[0],first^,feditcharindex);
   for int1:= 1 to high(ar1) do begin
    mstr1:= '';
    feditcharindex:= 0;
    addeditchars(ar1[int1],mstr1,feditcharindex);
    add(mstr1);
   end;
  end
  else begin
   first^:= first^ + ar1[0];
   for int1:= 1 to high(ar1) do begin
    add(ar1[int1]);
   end;
  end;
  if high(ar1) > 0 then begin
   endupdate;
  end
  else begin
   change(int2);
  end;
 end;
 result:= fcount-1;
end;
}

(*
function tpoorstringdatalist.addchars(const value: msestring;
                    const processeditchars: boolean = true): integer;		
var
 int1,int2: integer;
 po1: pmsestring;
 ar1: msestringarty;
 backdelete: integer;
begin
 ar1:= nil; //compilerwarning
 if value <> '' then begin
  ar1:= breaklines(value);
  backdelete:= 0;
  if processeditchars then begin
   for int1:= 0 to high(ar1) do begin
    int2:= msestrings.processeditchars(ar1[int1],false);
    if int1 = 0 then begin
     backdelete:= int2;
    end;
   end;
  end;
  if high(ar1) > 0 then begin
   beginupdate;
  end;
  for int2:= 0 to high(ar1) do begin
   if (fcount = 0) or (int2 > 0) then begin
    add(ar1[int2]);
   end
   else begin
    int1:= fcount - 1;
    checkindex(int1);
    po1:= pointer(fdatapo+int1*fsize);
    po1^:= copy(po1^,1,length(po1^)+backdelete) + ar1[int2];
    change(int1);
//    doitemchange(int1);
   end;
  end;
  if high(ar1) > 0 then begin
   endupdate;
  end;
 end;
 result:= fcount-1;
end;
*)
procedure tpoorstringdatalist.assign(source: tpersistent);
var
 int1: integer;
 po1,po2: pmsestring;
 po3: pstring;
 s1,s2: integer;
begin
 if not assigndata(source) then begin
  if source is tansistringdatalist then begin
   with tansistringdatalist(source) do begin
    self.newbuffer(count,true,true);
    po3:= datapo;
    po1:= self.datapo;
    s1:= self.size;
    s2:= size;
    for int1:= 0 to count - 1 do begin
     po1^:= po3^;
     inc(pchar(po1),s1);
     inc(pchar(po3),s2);
    end;
   end;
   change(-1);
  end
  else begin
   inherited;
  end;
 end;
end;

function tpoorstringdatalist.Getitems(index: integer): msestring;
var
 po1: pmsestring;
begin
 checkindex(index);
 po1:= pointer(fdatapo+index*fsize);
 result:= po1^;
end;

procedure tpoorstringdatalist.Setitems(index: integer; const Value: msestring);
var
 po1: pmsestring;
 int1: integer;
begin
 int1:= index;
 checkindex(index);
 po1:= pointer(fdatapo+index*fsize);
 po1^:= value;
 change(int1);
end;

function tpoorstringdatalist.empty(const index: integer): boolean;
begin
 result:=  pmsestring(getitempo(index))^ = '';
end;
{
function tpoorstringdatalist.empty(const index: integer): boolean;
var
 po1: pmsestring;
begin
 checkindex(index);
 po1:= pointer(fdatapo+index*fsize);
 result:=  po1^ = '';
end;
}
procedure tpoorstringdatalist.freedata(var data);
begin
 msestring(data):= '';
end;

procedure tpoorstringdatalist.copyinstance(var data);
begin
 stringaddref(msestring(data));
// reallocstring(msestring(data));
end;

procedure tpoorstringdatalist.assignto(dest: tpersistent);
var
 int1: integer;
 po1: pmsestring;
 s1: integer;
begin
 if dest is tstringlist then begin
  normalizering;
  s1:= size;
  with tstringlist(dest) do begin
   clear;
   capacity:= self.fcount;
   po1:= pointer(fdatapo);
   for int1:= 0 to self.count-1 do begin
    add(po1^);
    inc(pchar(po1),fsize);
   end;
  end;
 end
 else begin
  inherited;
 end;
end;

procedure tpoorstringdatalist.readitem(const reader: treader; var value);
begin
{$ifdef fpcbug4519read}
 msestring(value):= readwidestring4519(reader);
{$else}
 msestring(value):= treader_readmsestring
// {$ifdef mse_unicodestring}
// msestring(value):= reader.ReadunicodeString;
// {$else}
// msestring(value):= reader.ReadwideString;
// {$endif}
{$endif}
end;

procedure tpoorstringdatalist.writeitem(const writer: twriter; var value);
begin
// {$ifdef fpcbug4519}
// writewidestring4519(writer,msestring(value));
// {$else}
 twriter_writemsestring(writer,msestring(value));
// {$ifdef mse_unicodestring}
// writer.writeunicodestring(msestring(value));
// {$else}
// writer.WritewideString(msestring(value));
// {$endif}
// {$endif}
end;

procedure tpoorstringdatalist.loadfromstream(const stream: ttextstream);
var
 mstr1: msestring;
 first: boolean;
begin
 beginupdate;
 try
  clear;
  first:= true;
  while stream.readln(mstr1) do begin
   add(mstr1);
   first:= false;
  end;
  if not first or (mstr1 <> '') then begin
   add(mstr1);
  end;
 finally
  endupdate;
 end;
end;

procedure tpoorstringdatalist.loadfromfile(const filename: string;
                                    const aencoding: charencodingty = ce_locale);
var
 stream: ttextstream;
begin
 stream:= ttextstream.Create(filename,fm_read);
 stream.encoding:= aencoding;
 try
  loadfromstream(stream);
 finally
  stream.Free;
 end;
end;

procedure tpoorstringdatalist.savetofile(const filename: string;
                              const aencoding: charencodingty = ce_locale);
var
 stream: ttextstream;
begin
 stream:= ttextstream.Create(filename,fm_create);
 stream.encoding:= aencoding;
 try
  savetostream(stream);
 finally
  stream.Free;
 end;
end;

procedure tpoorstringdatalist.savetostream(const stream: ttextstream);
var
 int1: integer;
 po1: pmsestring;
begin
 if fcount > 0 then begin
  po1:= datapo;
  for int1:= count - 2 downto 0 do begin
   stream.writeln(po1^);
   inc(pchar(po1),fsize);
  end;
  stream.write(po1^);
 end;
end;

function tpoorstringdatalist.textlength: integer;
var
 int1,int2: integer;
 po1: pchar;
begin 
 po1:= datapo;
 int2:= 0;
 for int1:= 0 to fcount - 1 do begin
  inc(int2,length(msestring(pointer(po1)^)));
  inc(po1,fsize);
 end;
 result:= int2;
end;

function tpoorstringdatalist.dataastextstream: ttextstream; 
                       //chars truncated to 8bit
var
 len: integer;
 int1,int2,int3,int4: integer;
 po1,po2: pchar;
 bo1: boolean;
 ch1,ch2: char;
 wch1: widechar;
begin
 result:= ttextstream.create; //memorystream
 int2:= textlength;
 if int2 > 0 then begin
  len:= int2+(fcount-1)*length(lineend);
  result.setsize(len+sizeof(lineend));
//  getmem(result,len+sizeof(lineend));
  po2:= result.memory;
  po1:= datapo;
  bo1:= length(lineend) > 1;
  ch1:= string(lineend)[1];
  if bo1 then begin
   ch2:= string(lineend)[2];
  end
  else begin
   ch2:= ' '; //compiler warning
  end;
  for int1:= 0 to fcount - 1 do begin
   int4:= length(msestring(pointer(po1)^));
   for int3:= int4 - 1 downto 0 do begin
    wch1:= msecharaty(pointer(pointer(po1)^)^)[int3];
    if wch1 > #$ff then begin
     wch1:= #$ff;
    end;
    (po2 + int3)^:= char(byte(wch1));
   end;
   inc(po2,int4);
   po2^:= ch1;
   if bo1 then begin
    (po2 + 1)^:= ch2;
    inc(po2,2);
   end
   else begin
    inc(po2,1);
   end;
   inc(po1,fsize);
  end;
  result.setsize(len+sizeof(lineend)); //remove last newline
 end;
end;

function tpoorstringdatalist.getasarray: msestringarty;
begin
 setlength(result,fcount);
 internalgetasarray(pointer(result),sizeof(msestring));
end;

procedure tpoorstringdatalist.setasarray(const data: msestringarty);
begin
 internalsetasarray(pointer(data),sizeof(msestring),length(data));
end;

function tpoorstringdatalist.getasstringarray: stringarty;
var
 int1: integer;
 po1: pmsestring;
begin
 setlength(result,count);
 po1:= datapo;
 for int1:= 0 to count - 1 do begin
  result[int1]:= po1^;
  pchar(po1):= pchar(po1)+fsize;
 end;
end;

procedure tpoorstringdatalist.setasstringarray(const data: stringarty);
var
 po1: pmsestring;
 int1: integer;
 s1: integer;
begin
 newbuffer(length(data),true,true);
 po1:= pointer(fdatapo);
 s1:= size;
 for int1:= 0 to high(data) do begin
  po1^:= data[int1];
  inc(pchar(po1),s1);
 end;
 change(-1);
end;

procedure tpoorstringdatalist.assignopenarray(const data: array of msestring);
var
 po1: pmsestring;
 s1: integer;
 int1: integer;
begin
 newbuffer(length(data),true,true);
 po1:= datapo;
 s1:= size;
 for int1:= 0 to high(data) do begin
  po1^:= data[int1];
  inc(pchar(po1),s1);
 end;
 change(-1);
end;
{
procedure tpoorstringdatalist.assignarray(const data: stringarty);
var
 int1: integer;
 po1: pmsestring;
begin
 beginupdate;
 try
  count:= 0;
  count:= length(data);
  po1:= pointer(fdatapo);
  for int1:= 0 to length(data)-1 do begin
   po1^:= msestring(data[int1]);
   inc(pchar(po1),fsize);
  end;
 finally
  endupdate;
 end;
end;

procedure tpoorstringdatalist.assignarray(const data: msestringarty);
var
 int1: integer;
 po1: pmsestring;
begin
 beginupdate;
 try
  count:= 0;
  count:= length(data);
  po1:= pointer(fdatapo);
  for int1:= 0 to high(data) do begin
   po1^:= data[int1];
   inc(pchar(po1),fsize);
  end;
 finally
  endupdate;
 end;
end;
}
function tpoorstringdatalist.indexof(const value: msestring): integer;
var
 int1: integer;
 po1: pmsestring;
begin
 result:= -1;
 normalizering;
 po1:= pointer(fdatapo);
 for int1:= 0 to fcount -1 do begin
  if po1^ = value then begin
   result:= int1;
   break;
  end;
  inc(pchar(po1),fsize);
 end;
end;

function tpoorstringdatalist.concatstring(const delim: msestring = '';
                   const separator: msestring = '';
                   const separatornoparagraph: msestring = ''): msestring;
var
 int1: integer;
 po1: pmsestring;
begin
 if fcount > 0 then begin
  normalizering;
  result:= delim + pmsestring(fdatapo)^ + delim;
  for int1:= 1 to fcount-1 do begin
   po1:= @separator;
   if getnoparagraphs(int1) then begin
    po1:= @separatornoparagraph;
   end;
   result:= result + po1^ + delim + pmsestring(fdatapo+int1*fsize)^ + delim;
  end;
 end
 else begin
  result:= '';
 end;
end;

function tpoorstringdatalist.getstatdata(const index: integer): msestring;
begin
 result:= items[index];
end;

procedure tpoorstringdatalist.setstatdata(const index: integer; const value: msestring);
begin
 items[index]:= value;
end;

function tpoorstringdatalist.checkassigncompatibility(
                                      const source: tpersistent): boolean;
begin
 result:= source.inheritsfrom(tpoorstringdatalist);
end;

function tpoorstringdatalist.getnoparagraphs(index: integer): boolean;
begin
 result:= false;
end;

function tpoorstringdatalist.getastext(const index: integer): msestring;
begin
 result:= items[index];
end;

procedure tpoorstringdatalist.setastext(const index: integer;
               const avalue: msestring);
begin
 items[index]:= avalue;
end;

function tpoorstringdatalist.gettext: msestring;
var
 po1: pmsestring;
 po2: pmsechar;
 int1: integer;
 int2: integer;
 ch1,ch2: msechar;
begin
 if count = 0 then begin
  result:='';
  exit;
 end;
 int2:= textlength;
 int2:= int2 + count * length(lineend);
 setlength(result,int2);
 ch1:= msechar(byte(string(lineend)[1]));
 if length(lineend) > 1 then begin
  ch2:= msechar(byte(string(lineend)[2]));
 end;
 po1:= datapo;
 po2:= pointer(result);
 for int1:= count-1 downto 0 do begin
  int2:= length(po1^);
  if int2 <> 0 then begin
   move(pointer(po1^)^,po2^,int2*sizeof(msechar));
   inc(po2,int2);
  end;
  po2^:= ch1;
  inc(po2);
  if length(lineend) > 1 then begin
   po2^:= ch2;
   inc(po2);
  end;
  inc(pchar(po1),fsize);
 end;
 setlength(result,length(result)-length(lineend)); //remove last lineend
end;

procedure tpoorstringdatalist.settext(const avalue: msestring);
begin
 asarray:= breaklines(avalue);
end;

{ tmsestringdatalist }

function tmsestringdatalist.datatype: listdatatypety;
begin
 result:= dl_msestring;
end;

function tmsestringdatalist.add(const value: msestring): integer;
begin
 result:= adddata(value);
end;

procedure tmsestringdatalist.insert(const index: integer; const item: msestring);
begin
 insertdata(index,item);
end;

procedure tmsestringdatalist.compare(const l, r; var result: integer);
begin
 result:= msecomparestr(msestring(l),msestring(r));
end;

procedure tmsestringdatalist.fill(acount: integer; const defaultvalue: msestring);
begin
 internalfill(count,defaultvalue);
end;

{ tdoublemsestringdatalist }

function tdoublemsestringdatalist.add(const valuea: msestring; const valueb: msestring = ''): integer;
var
 dstr1: doublemsestringty;
begin
 dstr1.a:= valuea;
 dstr1.b:= valueb;
 result:= adddata(dstr1);
end;

function tdoublemsestringdatalist.add(const value: doublemsestringty): integer;
begin
 result:= adddata(value);
end;

procedure tdoublemsestringdatalist.copyinstance(var data);
begin
 inherited;
 stringaddref(doublemsestringty(data).b);
// reallocstring(doublemsestringty(data).b);
end;

constructor tdoublemsestringdatalist.create;
begin
 inherited;
 fsize:= sizeof(doublemsestringty);
end;

function tdoublemsestringdatalist.datatype: listdatatypety;
begin
 result:= dl_doublemsestring;
end;

procedure tdoublemsestringdatalist.fill(const acount: integer;
  const defaultvalue: msestring);
var
 dstr1: doublemsestringty;
begin
 dstr1.a:= defaultvalue;
 dstr1.b:= '';
 internalfill(count,dstr1);
end;

procedure tdoublemsestringdatalist.freedata(var data);
begin
 inherited;
 doublemsestringty(data).b:= '';
end;

function tdoublemsestringdatalist.Getitemsb(index: integer): msestring;
begin
 result:= pdoublemsestringty(getitempo(index))^.b;
end;

procedure tdoublemsestringdatalist.Setitemsb(index: integer;
  const Value: msestring);
begin
 pdoublemsestringty(getitempo(index))^.b:= value;
end;

function tdoublemsestringdatalist.Getdoubleitems(index: integer): doublemsestringty;
begin
 result:= pdoublemsestringty(getitempo(index))^;
end;

procedure tdoublemsestringdatalist.Setdoubleitems(index: integer;
  const Value: doublemsestringty);
begin
 pdoublemsestringty(getitempo(index))^:= value;
end;

procedure tdoublemsestringdatalist.insert(const index: integer;
  const item: msestring);
var
 dstr1: doublemsestringty;
begin
 dstr1.a:= item;
 dstr1.b:= '';
 insertdata(index,dstr1);
end;

procedure tdoublemsestringdatalist.compare(const l, r; var result: integer);
begin
 result:= msecomparestr(doublemsestringty(l).a,doublemsestringty(r).a);
end;
{
procedure tdoublemsestringdatalist.assign(source: tpersistent);
var
 int1: integer;
 po1,po2: pdoublemsestringty;
 s1,s2: integer;
begin
 if source = self then begin
  exit;
 end;
 if source is tdoublemsestringdatalist then begin
  beginupdate;
  with tdoublemsestringdatalist(source) do begin
   po2:= datapo;
   self.clear;
   self.count:= count;
   po1:= self.datapo;
   s1:= self.size;
   s2:= size;
   for int1:= 0 to count - 1 do begin
    po1^:= po2^;
    inc(pchar(po1),s1);
    inc(pchar(po2),s2);
   end;
  end;
  endupdate;
 end
 else begin
  inherited;
 end;
end;
}
procedure tdoublemsestringdatalist.assignb(const source: tdatalist);
var
 int1: integer;
 po1,po2: pdoublemsestringty;
 po3: pmsestring;
 s1,s2: integer;
begin
 if source is tdoublemsestringdatalist then begin
  beginupdate;
  with tdoublemsestringdatalist(source) do begin
   self.count:= fcount;
   po1:= self.datapo;
   po2:= datapo;
   s1:= self.size;
   s2:= size;
   for int1:= 0 to fcount-1 do begin
    po1^.b:= po2^.b;
    inc(pchar(po1),s1);
    inc(pchar(po2),s2);
   end;
  end;
  endupdate;
 end
 else begin
  if source is tmsestringdatalist then begin
   beginupdate;
   with tmsestringdatalist(source) do begin
    self.count:= fcount;
    po1:= self.datapo;
    po3:= datapo;
    s1:= self.size;
    s2:= size;
    for int1:= 0 to fcount-1 do begin
     po1^.b:= po3^;
     inc(pchar(po1),s1);
     inc(pchar(po3),s2);
    end;
   end;
   endupdate;
  end
  else begin
   inherited;
  end;
 end;
end;

procedure tdoublemsestringdatalist.assigntob(const dest: tdatalist);
var
 int1: integer;
 po1: pdoublemsestringty;
 po2: pmsestring;
 s1,s2: integer;
begin
 if dest is tmsestringdatalist then begin
  with tmsestringdatalist(dest) do begin
   beginupdate;
   clear;
   count:= self.fcount;
   po1:= self.datapo;
   po2:= datapo;
   s1:= self.size;
   s2:= size;
   for int1:= 0 to fcount-1 do begin
    po2^:= po1^.b;
    inc(pchar(po1),s1);
    inc(pchar(po2),s2);
   end;
   endupdate;
  end
 end
 else begin
  inherited;
 end;
end;

procedure tdoublemsestringdatalist.setasarray(const data: doublemsestringarty);
begin
 internalsetasarray(pointer(data),sizeof(doublemsestringty),length(data));
end;

function tdoublemsestringdatalist.getasarray: doublemsestringarty;
begin
 setlength(result,fcount);
 internalgetasarray(pointer(result),sizeof(doublemsestringty));
end;

function tdoublemsestringdatalist.getasarraya: msestringarty;
var
 int1: integer;
 po1: pdoublemsestringty;
 s1: integer;
begin
 setlength(result,fcount);
 po1:= datapo;
 s1:= size;
 for int1:= 0 to fcount - 1 do begin
  result[int1]:= po1^.a;
  inc(pchar(po1),s1);
 end;
end;

procedure tdoublemsestringdatalist.setasarraya(const data: msestringarty);
var
 int1: integer;
 po1: pdoublemsestringty;
 s1: integer;
begin
 beginupdate;
 count:= length(data);
 po1:= datapo;
 s1:= size;
 for int1:= 0 to fcount - 1 do begin
  po1^.a:= data[int1];
  inc(pchar(po1),s1);
 end;
 endupdate;
end;

procedure tdoublemsestringdatalist.setasarrayb(const data: msestringarty);
var
 int1: integer;
 po1: pdoublemsestringty;
 s1: integer;
begin
 beginupdate;
 count:= length(data);
 po1:= datapo;
 s1:= size;
 for int1:= 0 to fcount - 1 do begin
  po1^.b:= data[int1];
  inc(pchar(po1),s1);
 end;
 endupdate;
end;

function tdoublemsestringdatalist.getasarrayb: msestringarty;
var
 int1: integer;
 po1: pdoublemsestringty;
 s1: integer;
begin
 setlength(result,fcount);
 po1:= datapo;
 s1:= size;
 for int1:= 0 to fcount - 1 do begin
  result[int1]:= po1^.b;
  inc(pchar(po1),s1);
 end;
end;

procedure tdoublemsestringdatalist.readitem(const reader: treader; var value);
begin
 with reader do begin
  readlistbegin;
 {$ifdef fpcbug4519read}
  doublemsestringty(value).a:= readwidestring4519(reader); 
  doublemsestringty(value).b:= readwidestring4519(reader);
 {$else}
  doublemsestringty(value).a:= treader_readmsestring(reader); 
  doublemsestringty(value).b:= treader_readmsestring(reader);
//  {$ifdef mse_unicodestring}
//  doublemsestringty(value).a:= readunicodestring; 
//  doublemsestringty(value).b:= readunicodestring;
//  {$else}
//  doublemsestringty(value).a:= readwidestring; 
//  doublemsestringty(value).b:= readwidestring;
//  {$endif}
 {$endif}
  readlistend;
 end;
end;

procedure tdoublemsestringdatalist.writeitem(const writer: twriter; var value);
begin
 with writer do begin
  writelistbegin;
// {$ifdef fpcbug4519}
//  writewidestring4519(writer,doublemsestringty(value).a);
//  writewidestring4519(writer,doublemsestringty(value).b);
// {$else}
 twriter_writemsestring(writer,doublemsestringty(value).a);
 twriter_writemsestring(writer,doublemsestringty(value).b);
// {$ifdef mse_unicodestring}
//  writeunicodestring(doublemsestringty(value).a);
//  writeunicodestring(doublemsestringty(value).b);
// {$else}
//  writewidestring(doublemsestringty(value).a);
//  writewidestring(doublemsestringty(value).b);
// {$endif}
// {$endif}
  writelistend;
 end;
end;

{ tmsestringintdatalist }

constructor tmsestringintdatalist.create;
begin
 inherited;
 fsize:= sizeof(msestringintty);
end;

function tmsestringintdatalist.datatype: listdatatypety;
begin
 result:= dl_msestringint;
end;

function tmsestringintdatalist.add(const valuea: msestring; const valueb: integer = 0): integer;
var
 dstr1: msestringintty;
begin
 dstr1.mstr:= valuea;
 dstr1.int:= valueb;
 result:= adddata(dstr1);
end;

function tmsestringintdatalist.add(const value: msestringintty): integer;
begin
 result:= adddata(value);
end;

procedure tmsestringintdatalist.fill(const acount: integer;
                   const defaultvalue: msestring; const defaultint: integer);
var
 dstr1: msestringintty;
begin
 dstr1.mstr:= defaultvalue;
 dstr1.int:= defaultint;
 internalfill(count,dstr1);
end;

function tmsestringintdatalist.Getitemsb(index: integer): integer;
begin
 result:= pmsestringintty(getitempo(index))^.int;
end;

procedure tmsestringintdatalist.Setitemsb(index: integer;
                                             const Value: integer);
begin
 pmsestringintty(getitempo(index))^.int:= value;
 change(index);
end;

function tmsestringintdatalist.Getdoubleitems(index: integer): msestringintty;
begin
 result:= pmsestringintty(getitempo(index))^;
end;

procedure tmsestringintdatalist.Setdoubleitems(index: integer;
                         const Value: msestringintty);
begin
 pmsestringintty(getitempo(index))^:= value;
 change(index);
end;

procedure tmsestringintdatalist.insert(const index: integer;
                    const item: msestring; const itemint: integer);
var
 dstr1: msestringintty;
begin
 dstr1.mstr:= item;
 dstr1.int:= itemint;
 insertdata(index,dstr1);
end;

procedure tmsestringintdatalist.compare(const l, r; var result: integer);
begin
 result:= msecomparestr(msestringintty(l).mstr,msestringintty(r).mstr);
end;
{
procedure tmsestringintdatalist.assign(source: tpersistent);
begin
 if not assigndata(source) then begin
  inherited;
 end;
end;
}
procedure tmsestringintdatalist.assignb(const source: tdatalist);
var
 int1: integer;
 po1,po2: pmsestringintty;
 po3: pinteger;
 s1,s2: integer;
begin
 if source is tmsestringintdatalist then begin
  beginupdate;
  count:= source.count;
  with tmsestringintdatalist(source) do begin
   po1:= self.datapo;
   po2:= datapo;
   s1:= self.size;
   s2:= size;
   for int1:= 0 to self.fcount-1 do begin
    po1^.int:= po2^.int;
    inc(pchar(po1),s1);
    inc(pchar(po2),s2);
   end;
  end;
  endupdate;
 end
 else begin
  if source is tintegerdatalist then begin
   beginupdate;
   count:= source.count;
   with tintegerdatalist(source) do begin
    po1:= self.datapo;
    po3:= datapo;
    s1:= self.size;
    s2:= size;
    for int1:= 0 to fcount-1 do begin
     po1^.int:= po3^;
     inc(pchar(po1),s1);
     inc(pchar(po3),s2);
    end;
   end;
   endupdate;
  end
  else begin
   inherited;
  end;
 end;
end;

procedure tmsestringintdatalist.assigntob(const dest: tdatalist);
var
 int1: integer;
 po1: pmsestringintty;
 po2: pinteger;
 s1,s2: integer;
begin
 if dest is tintegerdatalist then begin
  with tintegerdatalist(dest) do begin
   newbuffer(self.count,true,dest.size > sizeof(integer));
   po1:= self.datapo;
   po2:= pointer(fdatapo);
   s1:= self.size;
   s2:= size;
   for int1:= 0 to fcount-1 do begin
    po2^:= po1^.int;
    inc(pchar(po1),s1);
    inc(pchar(po2),s2);
   end;
   change(-1);
  end
 end
 else begin
  inherited;
 end;
end;

procedure tmsestringintdatalist.setasarray(const data: msestringintarty);
begin
 internalsetasarray(pointer(data),sizeof(msestringintty),length(data));
end;

function tmsestringintdatalist.getasarray: msestringintarty;
begin
 setlength(result,fcount);
 internalgetasarray(pointer(result),sizeof(msestringintty));
end;

function tmsestringintdatalist.getasarraya: msestringarty;
var
 int1: integer;
 po1: pmsestringintty;
 s1: integer;
begin
 setlength(result,fcount);
 po1:= datapo;
 s1:= size;
 for int1:= 0 to fcount - 1 do begin
  result[int1]:= po1^.mstr;
  inc(pchar(po1),s1);
 end;
end;

procedure tmsestringintdatalist.setasarraya(const data: msestringarty);
var
 int1: integer;
 po1: pmsestringintty;
 s1: integer;
begin
 beginupdate;
 count:= length(data);
 po1:= datapo;
 s1:= size;
 for int1:= 0 to fcount - 1 do begin
  po1^.mstr:= data[int1];
  inc(pchar(po1),s1);
 end;
 endupdate;
end;

procedure tmsestringintdatalist.setasarrayb(const data: integerarty);
var
 int1: integer;
 po1: pmsestringintty;
 s1: integer;
begin
 beginupdate;
 count:= length(data);
 po1:= datapo;
 s1:= size;
 for int1:= 0 to fcount - 1 do begin
  po1^.int:= data[int1];
  inc(pchar(po1),s1);
 end;
 endupdate;
end;

function tmsestringintdatalist.getasarrayb: integerarty;
var
 int1: integer;
 po1: pmsestringintty;
 s1: integer;
begin
 setlength(result,fcount);
 po1:= datapo;
 s1:= size;
 for int1:= 0 to fcount - 1 do begin
  result[int1]:= po1^.int;
  inc(pchar(po1),s1);
 end;
end;

procedure tmsestringintdatalist.readitem(const reader: treader; var value);
begin
 with reader do begin
  readlistbegin;
 {$ifdef fpcbug4519read}
  msestringintty(value).mstr:= readwidestring4519(reader); 
 {$else}
  msestringintty(value).mstr:= treader_readmsestring(reader); 
//  {$ifdef mse_unicodestring}
//  msestringintty(value).mstr:= readunicodestring; 
//  {$else}
//  msestringintty(value).mstr:= readwidestring; 
//  {$endif}
 {$endif}
  msestringintty(value).int:= readinteger;
  readlistend;
 end;
end;

procedure tmsestringintdatalist.writeitem(const writer: twriter; var value);
begin
 with writer do begin
  writelistbegin;
// {$ifdef fpcbug4519}
//  writewidestring4519(writer,doublemsestringty(value).a);
//  writewidestring4519(writer,doublemsestringty(value).b);
// {$else}
  twriter_writemsestring(writer,msestringintty(value).mstr);
// {$ifdef mse_unicodestring}
//  writeunicodestring(msestringintty(value).mstr);
// {$else}
//  writewidestring(msestringintty(value).mstr);
// {$endif}
  writeinteger(msestringintty(value).int);
// {$endif}
  writelistend;
 end;
end;

procedure tmsestringintdatalist.setstatdata(const index: integer;
               const value: msestring);
var
 strint1: msestringintty;
 int1: integer;
begin
 int1:= findchar(value,',');
 if int1 > 0 then begin
  strint1.int:= strtoint(copy(value,1,int1-1));
  strint1.mstr:= copy(value,int1+1,bigint);
  setdata(index,strint1);
 end;
end;

function tmsestringintdatalist.getstatdata(const index: integer): msestring;
begin
 with pmsestringintty(getitempo(index))^ do begin
  result:= inttostr(int)+','+mstr;
 end;
end;

{ trealintdatalist }

constructor trealintdatalist.create;
begin
 fdefaultval1.rea:= emptyreal;
 inherited;
 fsize:= sizeof(realintty);
end;

function trealintdatalist.datatype: listdatatypety;
begin
 result:= dl_realint;
end;

function trealintdatalist.add(const valuea: realty; 
                                     const valueb: integer = 0): integer;
var
 d1: realintty;
begin
 d1.rea:= valuea;
 d1.int:= valueb;
 result:= adddata(d1);
end;

function trealintdatalist.add(const value: realintty): integer;
begin
 result:= adddata(value);
end;

procedure trealintdatalist.fill(const acount: integer;
                   const defaultvalue: realty; const defaultint: integer);
var
 d1: realintty;
begin
 d1.rea:= defaultvalue;
 d1.int:= defaultint;
 internalfill(count,d1);
end;

function trealintdatalist.Getitemsb(index: integer): integer;
begin
 result:= prealintty(getitempo(index))^.int;
end;

procedure trealintdatalist.Setitemsb(index: integer;
                                             const Value: integer);
begin
 prealintty(getitempo(index))^.int:= value;
 change(index);
end;

function trealintdatalist.Getdoubleitems(index: integer): realintty;
begin
 result:= prealintty(getitempo(index))^;
end;

procedure trealintdatalist.Setdoubleitems(index: integer;
                         const Value: realintty);
begin
 prealintty(getitempo(index))^:= value;
 change(index);
end;

procedure trealintdatalist.insert(const index: integer;
                    const item: realty; const itemint: integer);
var
 d1: realintty;
begin
 d1.rea:= item;
 d1.int:= itemint;
 insertdata(index,d1);
end;

procedure trealintdatalist.compare(const l, r; var result: integer);
begin
 result:= cmprealty(realintty(l).rea,realintty(r).rea);
end;
{
procedure trealintdatalist.assign(source: tpersistent);
begin
 if not assigndata(source) then begin
  inherited;
 end;
end;
}
procedure trealintdatalist.assignb(const source: tdatalist);
var
 int1: integer;
 po1,po2: prealintty;
 po3: pinteger;
 s1,s2: integer;
begin
 if source is trealintdatalist then begin
  beginupdate;
  count:= source.count;
  with trealintdatalist(source) do begin
   po1:= self.datapo;
   po2:= datapo;
   s1:= self.size;
   s2:= size;
   for int1:= 0 to self.fcount-1 do begin
    po1^.int:= po2^.int;
    inc(pchar(po1),s1);
    inc(pchar(po2),s2);
   end;
  end;
  endupdate;
 end
 else begin
  if source is tintegerdatalist then begin
   beginupdate;
   count:= source.count;
   with tintegerdatalist(source) do begin
    po1:= self.datapo;
    po3:= datapo;
    s1:= self.size;
    s2:= size;
    for int1:= 0 to fcount-1 do begin
     po1^.int:= po3^;
     inc(pchar(po1),s1);
     inc(pchar(po3),s2);
    end;
   end;
   endupdate;
  end
  else begin
   inherited;
  end;
 end;
end;

procedure trealintdatalist.assigntob(const dest: tdatalist);
var
 int1: integer;
 po1: prealintty;
 po2: pinteger;
 s1,s2: integer;
begin
 if dest is tintegerdatalist then begin
  with tintegerdatalist(dest) do begin
   newbuffer(self.count,true,dest.size > sizeof(integer));
   po1:= self.datapo;
   po2:= pointer(fdatapo);
   s1:= self.size;
   s2:= size;
   for int1:= 0 to fcount-1 do begin
    po2^:= po1^.int;
    inc(pchar(po1),s1);
    inc(pchar(po2),s2);
   end;
   change(-1);
  end
 end
 else begin
  inherited;
 end;
end;

procedure trealintdatalist.setasarray(const data: realintarty);
begin
 internalsetasarray(pointer(data),sizeof(realintty),length(data));
end;

function trealintdatalist.getasarray: realintarty;
begin
 setlength(result,fcount);
 internalgetasarray(pointer(result),sizeof(realintty));
end;

function trealintdatalist.getasarraya: realarty;
var
 int1: integer;
 po1: prealintty;
 s1: integer;
begin
 setlength(result,fcount);
 po1:= datapo;
 s1:= size;
 for int1:= 0 to fcount - 1 do begin
  result[int1]:= po1^.rea;
  inc(pchar(po1),s1);
 end;
end;

procedure trealintdatalist.setasarraya(const data: realarty);
var
 int1: integer;
 po1: prealintty;
 s1: integer;
begin
 beginupdate;
 count:= length(data);
 po1:= pointer(fdatapo);
 s1:= size;
 for int1:= 0 to fcount - 1 do begin
  po1^.rea:= data[int1];
  inc(pchar(po1),s1);
 end;
 endupdate;
end;

procedure trealintdatalist.setasarrayb(const data: integerarty);
var
 int1: integer;
 po1: prealintty;
 s1: integer;
begin
 beginupdate;
 count:= length(data);
 po1:= pointer(fdatapo);
 s1:= size;
 for int1:= 0 to fcount - 1 do begin
  po1^.int:= data[int1];
  inc(pchar(po1),s1);
 end;
 endupdate;
end;

function trealintdatalist.getasarrayb: integerarty;
var
 int1: integer;
 po1: prealintty;
 s1: integer;
begin
 setlength(result,fcount);
 po1:= datapo;
 s1:= size;
 for int1:= 0 to fcount - 1 do begin
  result[int1]:= po1^.int;
  inc(pchar(po1),s1);
 end;
end;

procedure trealintdatalist.readitem(const reader: treader; var value);
begin
 with reader do begin
  readlistbegin;
  realintty(value).rea:= readrealty(reader); 
  realintty(value).int:= readinteger;
  readlistend;
 end;
end;

procedure trealintdatalist.writeitem(const writer: twriter; var value);
begin
 with writer do begin
  writelistbegin;
  writer.writefloat(realintty(value).rea);
//  writerealty(writer,realintty(value).rea);
  writeinteger(realintty(value).int);
  writelistend;
 end;
end;

procedure trealintdatalist.setstatdata(const index: integer;
               const value: msestring);
var
 d1: realintty;
 int1: integer;
begin
 int1:= findchar(value,',');
 if int1 > 0 then begin
  d1.rea:= strtorealtydot(copy(value,1,int1-1));
  if cmprealty(d1.rea,min) < 0 then begin
   d1.rea:= min;
  end
  else begin
   if cmprealty(d1.rea,max) > 0 then begin
    d1.rea:= max;
   end;
  end;
  d1.int:= strtoint(copy(value,int1+1,bigint));
  setdata(index,d1);
 end;
end;

function trealintdatalist.getstatdata(const index: integer): msestring;
begin
 with prealintty(getitempo(index))^ do begin
  result:=  realtytostrdot(rea)+','+inttostr(int);
 end;
end;

function trealintdatalist.getdefault: pointer;
begin
 if fdefaultzero then begin
  result:= nil;
 end
 else begin
  result:= @fdefaultval1;
 end;
end;

procedure trealintdatalist.fill(const defaultvalue: realty;
               const defaultint: integer);
begin
 fill(count,defaultvalue,defaultint);
end;

{ tcustomrowstatelist }

constructor tcustomrowstatelist.create;
begin
 inherited;
 fsize:= sizeof(rowstatety);
end;

constructor tcustomrowstatelist.create(const ainfolevel: rowinfolevelty);
begin
 finfolevel:= ainfolevel;
 inherited create;
 case finfolevel of
  ril_colmerge: begin
   fsize:= sizeof(rowstatecolmergety);
  end;
  ril_rowheight: begin
   fsize:= sizeof(rowstaterowheightty);
  end;
  else begin
   fsize:= sizeof(rowstatety);
  end;
 end;
end;

function tcustomrowstatelist.datatype: listdatatypety;
begin
 result:= dl_rowstate;
end;

function tcustomrowstatelist.getitempo(const index: integer): prowstatety;
begin
 result:= prowstatety(inherited getitempo(index));
end;

function tcustomrowstatelist.getrowstate(const index: integer): rowstatety;
begin
 getdata(index,result);
end;

procedure tcustomrowstatelist.setrowstate(const index: integer;
  const Value: rowstatety);
begin
 setdata(index,value);
end;

function tcustomrowstatelist.getrowstatecolmerge(const index: integer): rowstatecolmergety;
begin
 checkinfolevel(ril_colmerge);
 getdata(index,result);
end;

procedure tcustomrowstatelist.setrowstatecolmerge(const index: integer;
  const Value: rowstatecolmergety);
begin
 checkinfolevel(ril_colmerge);
 setdata(index,value);
end;

function tcustomrowstatelist.getrowstaterowheight(const index: integer): rowstaterowheightty;
begin
 checkinfolevel(ril_rowheight);
 getdata(index,result);
end;

procedure tcustomrowstatelist.setrowstaterowheight(const index: integer;
  const Value: rowstaterowheightty);
begin
 checkinfolevel(ril_rowheight);
 setdata(index,value);
end;

function tcustomrowstatelist.mergecols(const arow: integer; const astart: longword;
                                 const acount: longword): boolean;
var
 ca1,ca2: longword;
begin
 result:= false;
 if (astart < mergedcolmax - 1) and (acount > 0) then begin
  with getitempocolmerge(arow)^ do begin
   if (astart = 0) and (acount > mergedcolmax) then begin
    ca2:= mergedcolall;
   end
   else begin
    ca1:= acount;
    if ca1 + astart > mergedcolmax then begin
     ca1:= mergedcolmax - astart;
    end;
    ca2:= colmerge.merged or (bitmask[ca1] shl astart);
   end;
   if colmerge.merged <> ca2 then begin
    colmerge.merged:= ca2;
    result:= true;
   end;
  end;
 end;
end;

function tcustomrowstatelist.unmergecols(const arow: integer): boolean;
var
 int1: integer;
 po1: prowstatecolmergeaty;
begin
 result:= false;
 if arow = invalidaxis then begin
  po1:= datapocolmerge;
  for int1:= 0 to count - 1 do begin
   if po1^[int1].colmerge.merged <> 0 then begin
    result:= true;
    po1^[int1].colmerge.merged:= 0;
   end;
  end;
 end
 else begin
  with getitempocolmerge(arow)^ do begin
   if colmerge.merged <> 0 then begin
    result:= true;
    colmerge.merged:= 0;
   end;
  end;
 end;
end;

function tcustomrowstatelist.gethidden(const index: integer): boolean;
begin
 result:= getitempo(index)^.fold and foldhiddenmask <> 0;
end;

function tcustomrowstatelist.getfoldinfoar: bytearty;
var
 int1: integer;
 po1: prowstatety;
begin
 setlength(result,count);
 po1:= datapo;
 inc(po1,count);
 for int1:= high(result) downto 0 do begin
  dec(po1);
  result[int1]:= po1^.fold;
 end;
end;

function tcustomrowstatelist.getfoldlevel(const index: integer): byte;
begin
 result:= getitempo(index)^.fold and foldlevelmask;
end;

procedure tcustomrowstatelist.setfoldlevel(const index: integer;
                                            const avalue: byte);
begin
 with getitempo(index)^ do begin
  fold:= replacebits(avalue,fold,foldlevelmask);
 end;
 checkdirty(index);
end;

procedure tcustomrowstatelist.sethidden(const index: integer;
                                                     const avalue: boolean);
begin
 with getitempo(index)^ do begin
  updatebit(fold,foldhiddenbit,avalue);
 end;
 checkdirty(index);
end;

procedure tcustomrowstatelist.setfoldissum(const index: integer;
                                                     const avalue: boolean);
begin
 with getitempo(index)^ do begin
  updatebit(fold,foldissumbit,avalue);
 end;
 checkdirty(index);
end;

function tcustomrowstatelist.getfoldissum(const index: integer): boolean;
begin
 result:= getitempo(index)^.flags and foldissummask <> 0;
end;

{
procedure tcustomrowstatelist.assign(source: tpersistent);
begin
 if source is tcustomrowstatelist then begin
  with tcustomrowstatelist(source) do begin
   self.beginupdate;
   self.count:= count;
   move(datapo^,self.datapo^,count*sizeof(rowstatety));
   self.endupdate;
  end;
 end
 else begin
  inherited;
 end;
end;
}
function tcustomrowstatelist.getcolor(const index: integer): rowstatenumty;
begin
 result:= (getitempo(index)^.color and rowstatemask) - 1;
end;

procedure tcustomrowstatelist.setcolor(const index: integer;
                                            const avalue: rowstatenumty);
begin
 with getitempo(index)^ do begin
  color:= replacebits(avalue + 1,color,rowstatemask);
 end;
end;

function tcustomrowstatelist.getlinecolor(const index: integer): rowstatenumty;
begin
 result:= (getitemporowheight(index)^.rowheight.linecolor and rowstatemask) - 1;
end;

procedure tcustomrowstatelist.setlinecolor(const index: integer;
                                            const avalue: rowstatenumty);
begin
 with getitemporowheight(index)^.rowheight do begin
  linecolor:= replacebits(avalue + 1,linecolor,rowstatemask);
 end;
end;

function tcustomrowstatelist.getlinecolorfix(const index: integer): rowstatenumty;
begin
 result:= (getitemporowheight(index)^.rowheight.linecolorfix and
                                                          rowstatemask) - 1;
end;

procedure tcustomrowstatelist.setlinecolorfix(const index: integer;
                                            const avalue: rowstatenumty);
begin
 with getitemporowheight(index)^.rowheight do begin
  linecolorfix:= replacebits(avalue + 1,linecolorfix,rowstatemask);
 end;
end;

function tcustomrowstatelist.getfont(const index: integer): rowstatenumty;
begin
 result:= (getitempo(index)^.font and rowstatemask) - 1;
end;

procedure tcustomrowstatelist.setfont(const index: integer;
               const avalue: rowstatenumty);
begin
 with getitempo(index)^ do begin
  font:= replacebits(avalue + 1,font,rowstatemask);
 end;
end;

function tcustomrowstatelist.getreadonly(const index: integer): boolean;
begin
 result:= getitempo(index)^.font and $80 <> 0;
end;

procedure tcustomrowstatelist.setreadonly(const index: integer;
               const avalue: boolean);
begin
 with getitempo(index)^ do begin
  if avalue then begin
   font:= font or $80;
  end
  else begin
   font:= font and not $80;
  end;
 end;
end;

function tcustomrowstatelist.getflag1(const index: integer): boolean;
begin
 result:= getitempo(index)^.color and $80 <> 0;
end;

procedure tcustomrowstatelist.setflag1(const index: integer;
               const avalue: boolean);
begin
 with getitempo(index)^ do begin
  if avalue then begin
   color:= color or $80;
  end
  else begin
   color:= color and not $80;
  end;
 end;
end;

function tcustomrowstatelist.getselected(const index: integer): longword;
begin
 result:= getitempo(index)^.selected;
end;

procedure tcustomrowstatelist.setselected(const index: integer;
               const avalue: longword);
begin
 getitempo(index)^.selected:= avalue;
end;

function tcustomrowstatelist.getmerged(const index: integer): longword;
begin
 result:= getitempocolmerge(index)^.colmerge.merged;
end;

procedure tcustomrowstatelist.setmerged(const index: integer;
               const avalue: longword);
begin
 getitempocolmerge(index)^.colmerge.merged:= avalue;
end;

function tcustomrowstatelist.getheight(const index: integer): integer;
begin
 result:= getitemporowheight(index)^.rowheight.height;
 if result < 0 then begin
  result:= 0;
 end;
end;

function tcustomrowstatelist.getlinewidth(const index: integer): integer;
begin
 result:= getitemporowheight(index)^.rowheight.linewidth;
end;

procedure tcustomrowstatelist.checkinfolevel(const wantedlevel: rowinfolevelty);
begin
 if wantedlevel > finfolevel then begin
  raise exception.create('Wrong rowinfolevel.');
 end;
end;

function tcustomrowstatelist.datapocolmerge: pointer;
begin
 checkinfolevel(ril_colmerge);
 result:= datapo;
end;

function tcustomrowstatelist.dataporowheight: pointer;
begin
 checkinfolevel(ril_rowheight);
 result:= datapo;
end;

function tcustomrowstatelist.getitempocolmerge(const index: integer): prowstatecolmergety;
begin
 checkinfolevel(ril_colmerge);
 result:= prowstatecolmergety(inherited getitempo(index));
end;

function tcustomrowstatelist.getitemporowheight(const index: integer): prowstaterowheightty;
begin
 checkinfolevel(ril_rowheight);
 result:= prowstaterowheightty(inherited getitempo(index));
end;

procedure tcustomrowstatelist.initdirty;
begin
 //dummy
end;

procedure tcustomrowstatelist.recalchidden;
begin
 //dummy
end;

function tcustomrowstatelist.checkassigncompatibility(
                                   const source: tpersistent): boolean;
begin
 result:= source.inheritsfrom(tcustomrowstatelist);
end;

procedure tcustomrowstatelist.change(const aindex: integer);
begin
 if aindex < 0 then begin
  initdirty;
 end;
 inherited;
end;

procedure tcustomrowstatelist.readstate(const reader; const acount: integer);
begin
 initdirty;
 inherited;
 recalchidden;
end;

procedure tcustomrowstatelist.assign(source: tpersistent);
begin
 inherited;
 recalchidden;
end;

function tcustomrowstatelist.checkwritedata(const filer: tfiler): boolean;
begin
 result:= false;
end;

function tcustomrowstatelist.getcolorar: integerarty;
var
 po1: prowstatety;
 int1: integer;
begin
 setlength(result,count);
 po1:= datapo;
 for int1:= 0 to high(result) do begin
  result[int1]:= (po1^.color and rowstatemask) - 1;
  inc(pchar(po1),fsize);
 end;
end;

procedure tcustomrowstatelist.setcolorar(const avalue: integerarty);
var
 po1: prowstatety;
 int1: integer;
begin
// beginupdate;
 count:= length(avalue);
 po1:= datapo;
 for int1:= 0 to high(avalue) do begin
  po1^.color:= replacebits(avalue[int1] + 1,po1^.color,rowstatemask);
  inc(pchar(po1),fsize);
 end;
// endupdate;
end;

function tcustomrowstatelist.getfontar: integerarty;
var
 po1: prowstatety;
 int1: integer;
begin
 setlength(result,count);
 po1:= datapo;
 for int1:= 0 to high(result) do begin
  result[int1]:= (po1^.font and rowstatemask) - 1;
  inc(pchar(po1),fsize);
 end;
end;

procedure tcustomrowstatelist.setfontar(const avalue: integerarty);
var
 po1: prowstatety;
 int1: integer;
begin
// beginupdate;
 count:= length(avalue);
 po1:= datapo;
 for int1:= 0 to high(avalue) do begin
  po1^.font:= replacebits(avalue[int1] + 1,po1^.font,rowstatemask);
  inc(pchar(po1),fsize);
 end;
// endupdate;
end;

function tcustomrowstatelist.getfoldlevelar: integerarty;
var
 po1: prowstatety;
 int1: integer;
begin
 setlength(result,count);
 po1:= datapo;
 for int1:= 0 to high(result) do begin
  result[int1]:= (po1^.fold and foldlevelmask);
  inc(pchar(po1),fsize);
 end;
end;

procedure tcustomrowstatelist.setfoldlevelar(const avalue: integerarty);
var
 po1: prowstatety;
 int1: integer;
begin
// beginupdate;
 count:= length(avalue);
 po1:= datapo;
 for int1:= 0 to high(avalue) do begin
  po1^.fold:= replacebits(avalue[int1] + 1,po1^.fold,foldlevelmask);
  inc(pchar(po1),fsize);
 end;
 if avalue <> nil then begin
  checkdirty(0);
 end;
// endupdate;
end;

function tcustomrowstatelist.gethiddenar: longboolarty;
var
 po1: prowstatety;
 int1: integer;
begin
 setlength(result,count);
 po1:= datapo;
 for int1:= 0 to high(result) do begin
  result[int1]:= (po1^.fold and foldhiddenmask) <> 0;
  inc(pchar(po1),fsize);
 end;
end;

procedure tcustomrowstatelist.sethiddenar(const avalue: longboolarty);
var
 po1: prowstatety;
 int1: integer;
begin
// beginupdate;
 count:= length(avalue);
 po1:= datapo;
 for int1:= 0 to high(avalue) do begin
  updatebit(po1^.fold,foldhiddenbit,avalue[int1]);
  inc(pchar(po1),fsize);
 end;
 if avalue <> nil then begin
  checkdirty(0);
 end;
// endupdate;
end;

function tcustomrowstatelist.getfoldissumar: longboolarty;
var
 po1: prowstatety;
 int1: integer;
begin
 setlength(result,count);
 po1:= datapo;
 for int1:= 0 to high(result) do begin
  result[int1]:= (po1^.fold and foldissummask) <> 0;
  inc(pchar(po1),fsize);
 end;
end;

procedure tcustomrowstatelist.setfoldissumar(const avalue: longboolarty);
var
 po1: prowstatety;
 int1: integer;
begin
// beginupdate;
 count:= length(avalue);
 po1:= datapo;
 for int1:= 0 to high(avalue) do begin
  updatebit(po1^.fold,foldissumbit,avalue[int1]);
  inc(pchar(po1),fsize);
 end;
 if avalue <> nil then begin
  checkdirty(0);
 end;
// endupdate;
end;

procedure tcustomrowstatelist.checkdirty(const arow: integer);
begin
 //dummy
end;

{ tlinindexmse }

function tlinindexmse.find(key: pointer; nearest : boolean): integer;
var
 l,r,p: integer;
 int1: integer;
begin
 l:= 0;
 r:= count-1;
 result:= -1;
 if assigned(fcomparefunc) and (r > 0) then begin
  p:= 0; int1:= 0; //compilerwarnungen verhindern
  while true do begin
   p:= (l+r) shr 1;
   int1:= fcomparefunc(list^[p],key);
   if l = r then begin
    break;
   end;
   if int1 < 0 then begin
    l:= p+1;
   end
   else begin
    r:= p;
   end;
  end;
  if int1 < 0 then begin
   inc(p);
  end;
  if nearest or (int1 = 0) then begin
   result:= p;
  end;
 end;
end;

function tlinindexmse.insert(value: pointer): integer;
var
 int1: integer;
begin
 int1:= find(value,true);
 if int1 < 0 then begin
  int1:= 0;
 end;
 insert(int1,value);
 result:= int1;
end;

procedure tlinindexmse.QuickSort(L, R: Integer);
var
  I, J: Integer;
  P,T: Pointer;
  pivotnum,pivotsortnum: integer;
  int1: integer;
begin
  repeat
    I := L;
    J := R;
    pivotnum:= (L + R) shr 1;
    pivotsortnum:= fsortnums[pivotnum];
    P := self.list^[pivotnum];
    repeat
      while true do begin
       int1:= fcomparefunc(self.list^[I], P);
       if int1 = 0 then begin
        int1:= fsortnums[I]-pivotsortnum;
       end;
       if int1 >= 0 then begin
        break;
       end;
       Inc(I);
      end;
      while true do begin
       int1:= fcomparefunc(self.list^[J], P);
       if int1 = 0 then begin
        int1:= fsortnums[J]-pivotsortnum;
       end;
       if int1 <= 0 then begin
        break;
       end;
       Dec(J);
      end;
      if I <= J then      begin
       T := self.list^[I];
       self.list^[I] := self.list^[J];
       self.list^[J] := T;
       int1:= fsortnums[I];
       fsortnums[I]:= fsortnums[J];
       fsortnums[J]:= int1;
       Inc(I);
       Dec(J);
      end;
    until I > J;
    if L < J then
      QuickSort(L, J);
    L := I;
  until I >= R;
end;

procedure tlinindexmse.reindex;
var
 int1: integer;
begin
 if assigned(fcomparefunc) and (self.list <> nil) then begin
  setlength(fsortnums,count);
  for int1:= 0 to count-1 do begin
   fsortnums[int1]:= int1;
  end;
  quicksort(0,count-1);
  setlength(fsortnums,0);
 end;
end;

procedure tlinindexmse.Setcomparefunc(const Value: indexcomparety);
begin
 if @fcomparefunc <>  @value then begin
  Fcomparefunc:= Value;
  fsortvalid:= false;
 end;
end;

{ tobjectdatalist }

constructor tobjectdatalist.create;
begin
 inherited;
 fstate:= (fstate - [dls_needscopy]) + [dls_needsinit];
end;

procedure tobjectdatalist.checkitemclass(const aitem: tobject);
begin
 if (fitemclass <> nil) and not (aitem is fitemclass) then begin
  raise exception.create('Item must be "'+fitemclass.classname+'".');
 end;
end;

function tobjectdatalist.add(const aitem: tobject): integer;
begin
 checkitemclass(aitem);
 result:= adddata(aitem);
end;

function tobjectdatalist.extract(const index: integer): tobject; //no finalize
begin
 result:= self[index];
 internaldeletedata(index,false);
end;

procedure tobjectdatalist.copyinstance(var data);
begin
 tobject(data):= nil;
 initinstance(data);
end;

procedure tobjectdatalist.freedata(var data);
begin
 freeandnil(tobject(data));
end;

procedure tobjectdatalist.docreateobject(var instance: tobject);
begin
 if instance = nil then begin
  if assigned(foncreateobject) then begin
   foncreateobject(self,instance);
  end;
 end;
end;

procedure tobjectdatalist.initinstance(var data);
begin
 docreateobject(tobject(data));
end;

function tobjectdatalist.Getitems(index: integer): tobject;
begin
 internalgetdata(index,result);
end;


procedure tobjectdatalist.setitems(index: integer; const Value: tobject);
var
 po1: pobject;
begin
 po1:= getitempo(index);
 freedata(po1^);
 po1^:= value;
end;

function tobjectdatalist.checkassigncompatibility(const source: tpersistent): boolean;
begin
 result:= source.inheritsfrom(tobjectdatalist);
end;

end.
