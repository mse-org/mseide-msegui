{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msedatalist;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface

uses
 sysutils,classes,msestrings,typinfo,msereal,msetypes,msestream,mseguiglob,
 mseclasses,mselist;

type
 datatypty = (dl_none,dl_integer,dl_int64,dl_currency,dl_real,dl_datetime,
    dl_ansistring,dl_msestring,dl_doublemsestring,dl_complex,dl_custom);

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
 internallistoptionty = (ilo_needsfree,ilo_needscopy,ilo_needsinit);
 internallistoptionsty = set of internallistoptionty;

 tdatalist = class;
 tintegerdatalist = class;

 indexeventty = procedure(sender: tdatalist; index: integer) of object;
// listlineeventty = procedure (sender: tdatalist; index: integer) of object;

 blockcopymodety = (bcm_none,bcm_copy,bcm_init,bcm_rotate);

 tdatalist = class(tnullinterfacedpersistent)
  private
   fbytelength: integer;   //pufferlaenge
   fsortio: boolean;
   fsorted: boolean;
   Fcapacity: integer;
   fonchange: notifyeventty;
   fonitemchange: indexeventty;
   fnochange: integer;
   fdeleting: integer;
   fmaxcount: integer;
   fringpointer: integer;
   procedure clearbuffer; //buffer release
   procedure Setcapacity(Value: integer);
   procedure internalsetcount(value: integer; nochangeandinit: boolean);
   procedure setcount(const value: integer);
   procedure checkcapacity; //ev. reduktion des memory
   procedure assigndata(source: tdatalist);
   procedure setmaxcount(const Value: integer);
   procedure internalfreedata(index,anzahl: integer); //gibt daten frei falls notwendig
   procedure internalcopyinstance(index,anzahl: integer);
   procedure setsorted(const Value: boolean); //datenkopieren
   procedure internalcleardata(const index: integer);
  protected
   fdatapo: pchar;
   fsize: integer;
   finternaloptions: internallistoptionsty;
   fcount: integer;
   property nochange: integer read fnochange;
   procedure internalgetasarray(datapo: pointer);
   procedure internalsetasarray(acount: integer; source: pointer);
   procedure writedata(writer: twriter);
   procedure readdata(reader: treader);
   procedure readitem(const reader: treader; var value); virtual;
   procedure writeitem(const writer: twriter; var value); virtual;

   procedure internalgetdata(index: integer; out ziel);
   procedure internalsetdata(index: integer; const quelle);
   procedure internalfill(const anzahl: integer; const wert);
   procedure getdefaultdata(var dest);
   procedure getdata(index: integer; var dest);
   procedure setdata(index: integer; const source);
   function getstatdata(const index: integer): msestring; virtual;
   procedure setstatdata(const index: integer; const value: msestring); virtual;
   procedure writestate(const writer; const name: msestring); virtual;
                      //recursive interface
   procedure readstate(const reader; const acount: integer); virtual;

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
   procedure assigntob(const dest: tdatalist); virtual;
             //assign auf 2. spalte falls vorhanden, sonst exception
   procedure doitemchange(const index: integer); virtual;
   procedure dochange; virtual;
   procedure internaldeletedata(index: integer; dofree: boolean);
  public
   constructor create; override;
   destructor destroy; override;

   function datapo: pointer; //calls normalizering,
             //do not use in copyinstance,initinstance,freedata
   function getitempo(index: integer): pointer;
             //invalid after capacity change
   procedure assignb(const source: tdatalist); virtual;
             //assign auf 2. spalte falls vorhanden, sonst exception
   procedure change(const index: integer); virtual;
                   //index -1 -> undefined
   function datatyp: datatypty; virtual;
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

   procedure rearange(const arangelist: tintegerdatalist);
   procedure movedata(const fromindex,toindex: integer);
   procedure blockmovedata(const fromindex,toindex,count: integer);
   procedure blockcopydata(const fromindex,toindex,count: integer);
   procedure deletedata(const index: integer);
   procedure deleteitems(index,acount: integer);
   procedure insertitems(index,acount: integer);
   function empty(const index: integer): boolean; virtual;         //true wenn leer
   function sort(const arangelist: tintegerdatalist; dorearange: boolean): boolean; overload;
   function sort: boolean; overload; //true if changed

   property count: integer read Fcount write Setcount;       //anzahl zeilen
   property capacity: integer read Fcapacity write Setcapacity;
   property onchange: notifyeventty read fonchange write fonchange;
   property onitemchange: indexeventty read fonitemchange write fonitemchange;

   property maxcount: integer read fmaxcount
                     write setmaxcount default bigint; //for ring buffer
   property sorted: boolean read fsorted write setsorted;
 end;

 tintegerdatalist = class(tdatalist)
  private
   function Getitems(const index: integer): integer;
   procedure Setitems(const index: integer; const Value: integer);
   procedure setasarray(const value: integerarty);
   function getasarray: integerarty;
  protected
   procedure readitem(const reader: treader; var value); override;
   procedure writeitem(const writer: twriter; var value); override;
   procedure compare(const l,r; var result: integer); override;
   procedure setstatdata(const index: integer; const value: msestring); override;
   function getstatdata(const index: integer): msestring; override;
  public
   min: integer;
   max: integer;
   constructor create; override;
   function datatyp: datatypty; override;
   procedure assign(source: tpersistent); override;
   function empty(const index: integer): boolean; override;   //true wenn leer
   function add(const value: integer): integer;
   procedure insert(const index: integer; const item: integer);
   procedure number(const start,step: integer); //numeriert daten
   function find(value: integer): integer;  //bringt index, -1 wenn nicht gefunden
   procedure fill(acount: integer; const defaultvalue: integer);

   property asarray: integerarty read getasarray write setasarray;
   property items[const index: integer]: integer read Getitems write Setitems; default;
 end;

 tint64datalist = class(tdatalist)
  private
   function Getitems(index: integer): int64;
   procedure Setitems(index: integer; const avalue: int64);
   procedure setasarray(const value: int64arty);
   function getasarray: int64arty;
  protected
   procedure readitem(const reader: treader; var value); override;
   procedure writeitem(const writer: twriter; var value); override;
   procedure compare(const l,r; var result: integer); override;
   procedure setstatdata(const index: integer; const value: msestring); override;
   function getstatdata(const index: integer): msestring; override;
  public
   constructor create; override;
   function datatyp: datatypty; override;
   procedure assign(source: tpersistent); override;
   function empty(const index: integer): boolean; override;   //true wenn leer
   function add(const avalue: int64): integer;
   procedure insert(const index: integer; const avalue: int64);
   function find(const avalue: int64): integer;  //bringt index, -1 wenn nicht gefunden
   procedure fill(const acount: integer; const defaultvalue: int64);

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
   procedure readitem(const reader: treader; var value); override;
   procedure writeitem(const writer: twriter; var value); override;
   procedure compare(const l,r; var result: integer); override;
   procedure setstatdata(const index: integer; const value: msestring); override;
   function getstatdata(const index: integer): msestring; override;
  public
   constructor create; override;
   function datatyp: datatypty; override;
   procedure assign(source: tpersistent); override;
   function empty(const index: integer): boolean; override;   //true wenn leer
   function add(const avalue: currency): integer;
   procedure insert(const index: integer; const avalue: currency);
   function find(const avalue: currency): integer;  //bringt index, -1 wenn nicht gefunden
   procedure fill(const acount: integer; const defaultvalue: currency);

   property asarray: currencyarty read getasarray write setasarray;
   property items[index: integer]: currency read Getitems write Setitems; default;
 end;
  
 datalistarty = array of tdatalist;

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
   function datatyp: datatypty; override;
   procedure assign(source: tpersistent); override;
   procedure assignre(source: tcomplexdatalist);
   procedure assignim(source: tcomplexdatalist);
   function empty(const index: integer): boolean; override;
   function add(const value: real): integer;
   procedure insert(index: integer; const item: realty);
   procedure number(start,step: real);
   procedure fill(acount: integer; const defaultvalue: realty);

   property asarray: realarty read getasarray write setasarray;
   property items[index: integer]: realty read Getitems write Setitems; default;
   property defaultzero: boolean read fdefaultzero write fdefaultzero default false;
 end;

 tdatetimedatalist = class(trealdatalist)
  protected
   function getdefault: pointer; override;
  public
   function datatyp: datatypty; override;
   function empty(const index: integer): boolean; override;   //true wenn leer
   procedure fill(acount: integer; const defaultvalue: tdatetime);
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
   procedure readitem(const reader: treader; var value); override;
   procedure writeitem(const writer: twriter; var value); override;
   function getdefault: pointer; override;
   procedure assigntob(const dest: tdatalist); override;
   procedure assignto(dest: tpersistent); override;
  public
   function datatyp: datatypty; override;
   constructor create; override;
   procedure assign(source: tpersistent); override;
   procedure assignb(const source: tdatalist); override;
   procedure assignre(const source: trealdatalist);
   procedure assignim(const source: trealdatalist);
   function add(const value: complexty): integer;
   procedure insert(const index: integer; const item: complexty);
   function empty(const index: integer): boolean; override;   //true wenn leer
   procedure fill(const acount: integer; const defaultvalue: complexty);

   property asarray: complexarty read getasarray write setasarray;
   property items[const index: integer]: complexty read Getitems write Setitems; default;
   property defaultzero: boolean read fdefaultzero write fdefaultzero default false;
 end;

 tpointerdatalist = class(tdatalist)
  private
   function Getitems(index: integer): pointer;
   procedure Setitems(index: integer; const Value: pointer);
   function getasarray: pointerarty;
   procedure setasarray(const data: pointerarty);
  protected
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
   procedure readitem(const reader: treader; var value); override;
   procedure writeitem(const writer: twriter; var value); override;
   procedure freedata(var data); override; //gibt daten frei
   procedure copyinstance(var data); override;
               //nach blockcopy aufgerufen
   procedure assignto(dest: tpersistent); override;
   procedure compare(const l,r; var result: integer); override;
   procedure setstatdata(const index: integer; const value: msestring); override;
   function getstatdata(const index: integer): msestring; override;
  public
   function datatyp: datatypty; override;
   procedure assign(source: tpersistent); override;
   procedure assignarray(const data: array of ansistring); overload;
   procedure assignarray(const data: stringarty); overload;
   procedure assignarray(const data: msestringarty); overload;
   procedure insert(index: integer; const item: ansistring);
   function add(const value: ansistring): integer; overload;
   function addtext(const value: ansistring): integer;
                //returns added linecount
   function empty(const index: integer): boolean; override;   //true wenn leer
   procedure fill(acount: integer; const defaultvalue: ansistring);
   property items[index: integer]: ansistring read Getitems write 
                        setitems; default;
   property asarray: stringarty read getasarray write setasarray;
   property asmsestringarray: msestringarty read getasmsestringarray 
                              write setasmsestringarray;
 end;

 tmsestringdatalist = class;

 tpoorstringdatalist = class(tdynamicpointerdatalist)
  private
   function Getitems(index: integer): msestring;
   procedure Setitems(index: integer; const Value: msestring);
   function getasarray: msestringarty;
   procedure setasarray(const data: msestringarty);
   function getasstringarray: stringarty;
   procedure setasstringarray(const data: stringarty);
  protected
   procedure readitem(const reader: treader; var value); override;
   procedure writeitem(const writer: twriter; var value); override;
   procedure freedata(var data); override; //gibt daten frei
   procedure copyinstance(var data); override;
               //nach blockcopy aufgerufen
   procedure assignto(dest: tpersistent); override;
   procedure setstatdata(const index: integer; const value: msestring); override;
   function getstatdata(const index: integer): msestring; override;
  public
   procedure assign(source: tpersistent); override;
   procedure assignarray(const data: array of msestring); overload;
   procedure assignarray(const data: stringarty); overload;
   procedure assignarray(const data: msestringarty); overload;
   procedure insert(const index: integer; const item: msestring); virtual; abstract;
   function add(const value: tmsestringdatalist): integer; overload;
   function add(const value: msestring): integer; overload; virtual; abstract;
   function addchars(const value: msestring; 
                            const processeditchars: boolean = true): integer;
          //haengt zeichen an letzten eintrag an, bringt index
   function indexof(const value: msestring): integer;
   function empty(const index: integer): boolean; override;   //true wenn leer
   function concatstring(const delim: msestring = '';
                            const separator: msestring = ''): msestring;
   procedure loadfromfile(const filename: string);
   procedure loadfromstream(const stream: ttextstream);
   procedure savetofile(const filename: string);
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
   function datatyp: datatypty; override;
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
   procedure assign(source: tpersistent); override;
   procedure assignb(const source: tdatalist); override;
   procedure assigntob(const dest: tdatalist); override;

   function datatyp: datatypty; override;
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

 createobjecteventty = procedure(const sender: tobject; var obj: tobject) of object;

 tobjectdatalist = class(tdynamicpointerdatalist)
  private
   foncreateobject: createobjecteventty;
   function Getitems(index: integer): tobject;
   procedure setitems(index: integer; const Value: tobject);
  protected
   fitemclass: tclass;
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
 
const
 datalistclasses: array[datatypty] of datalistclassty = 
//dl_none,dl_integer, dl_int64,       dl_currency,       dl_real,      
 (nil,tintegerdatalist,tint64datalist,tcurrencydatalist,trealdatalist,
//dl_datetime,
 trealdatalist,
//dl_ansistring,              dl_msestring,           dl_doublemsestring,
  tansistringdatalist,tmsestringdatalist,tdoublemsestringdatalist,
//dl_complex,          dl_custom);
  tcomplexdatalist,nil);
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
procedure additem(var dest: pointerarty; const value: pointer;
                             var count: integer; step: integer = 32); overload;

function incrementarraylength(var value: pointer; typeinfo: pdynarraytypeinfo;
                             increment: integer = 1): integer; overload;
  //returns new length
function additem(var value; const typeinfo: pdynarraytypeinfo; //typeinfo of dynarray
                var count: integer; step: integer = 32): integer; overload;
  //value = array of type, returns index of new item
procedure deleteitem(var value; const typeinfo: pdynarraytypeinfo;
                          const aindex: integer); overload;
  //value = array of type which needs no finalize
procedure arrayaddref(var dynamicarray);
procedure arraydecref(var dynamicarray);
procedure allocuninitedarray(count,itemsize: integer; out dynamicarray);
                 //does not init memory, dynamicarray has to be nil!

procedure additem(var dest: stringarty; const value: string); overload;
procedure additem(var dest: msestringarty; const value: msestring); overload;
procedure additem(var dest: integerarty; const value: integer); overload;
procedure additem(var dest: longboolarty; const value: longbool); overload;
procedure additem(var dest: booleanarty; const value: boolean); overload;
procedure additem(var dest: realarty; const value: real); overload;
procedure additem(var dest: pointerarty; const value: pointer); overload;
procedure deleteitem(var dest: stringarty; index: integer); overload;
procedure deleteitem(var dest: msestringarty; index: integer); overload;
procedure deleteitem(var dest: integerarty; index: integer); overload;
procedure deleteitem(var dest: realarty; index: integer); overload;
procedure deleteitem(var dest: pointerarty; index: integer); overload;
procedure insertitem(var dest: integerarty; index: integer; value: integer); overload;
procedure insertitem(var dest: realarty; index: integer; value: realty); overload;
procedure insertitem(var dest: pointerarty; index: integer; value: pointer); overload;
function removeitem(var dest: pointerarty; const aitem: pointer): integer;
                                                overload;    
                        //returns removed index, -1 if none
function finditem(const ar: pointerarty; const aitem: pointer): integer;
                                                overload;
                           //-1 if none
procedure moveitem(var dest: pointerarty; const sourceindex: integer;
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


function stackarfunc(const ar1,ar2: integerarty): integerarty;
procedure stackarray(const source: stringarty; var dest: stringarty); overload;
procedure stackarray(const source: msestringarty; var dest: msestringarty); overload;
procedure stackarray(const source: integerarty; var dest: integerarty); overload;
procedure stackarray(const source: pointerarty; var dest: pointerarty); overload;
procedure stackarray(const source: realarty; var dest: realarty); overload;
procedure insertarray(const source: integerarty; var dest: integerarty); overload;
procedure insertarray(const source: realarty; var dest: realarty); overload;
function reversearray(const source: msestringarty): msestringarty; overload;
function reversearray(const source: integerarty): integerarty; overload;
procedure removearrayduplicates(var value: pointerarty);

procedure checkarrayindex(const value; const index: integer);
          //value = dynamic array, exception bei ungueltigem index

function comparepointer(const l,r): integer;
function compareinteger(const l,r): integer;
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
procedure quicksortarray(var asortlist; const acompare: arraysortcomparety;
                            asize,alength: integer; order: boolean;
                            out aindexlist: integerarty);
                            //asortlist = array of type

function findarrayitem(const item; const ar;
               compare: arraysortcomparety; size: integer;
               out foundindex: integer): boolean;
           //ar = array of type
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
procedure sortarray(var dest: cardinalarty); overload;
procedure sortarray(var dest: cardinalarty; out indexlist: integerarty); overload;
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
                             var sortlist: msestringarty); overload;
procedure orderarray(const sourceorderlist: integerarty; 
                             var sortlist: stringarty); overload;
                             
procedure reorderarray(const destorderlist: integerarty; 
                             var sortlist; size: integer); overload;
         //sortlist = array of type
procedure reorderarray(const destorderlist: integerarty; 
                             var sortlist: pointerarty); overload;
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

procedure readstringar(const reader: treader; out avalue: stringarty);
procedure writestringar(const writer: twriter; const avalue: stringarty);

type
 getintegeritemfuncty = function(const index: integer): integer of object;
 
function newidentnum(const count: integer; getfunc: getintegeritemfuncty): integer;
 //returns lowest not used value


implementation
uses
 rtlconsts,msestreaming,msesys,msestat;

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

function DynArraySize(a: Pointer): Integer;
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
                  increment: integer = 1): integer;
  //returns new length
begin
 result:= dynarraysize(value) + increment;
 dynarraysetlength(value,typeinfo,1,@result);
end;

function dynarrayelesize(const typinfo: pdynarraytypeinfo): integer;
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
                      decrement: integer = 1): integer;
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
  incrementarraylength(pointer(value),typeinfo,count-int1+step);
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
 refpo: pinteger;
begin
 if pointer(dynamicarray) <> nil then begin
  refpo:= pinteger(pchar(dynamicarray)-2*sizeof(integer));
  if refpo^ >= 0 then begin
   inc(refpo^);
  end;
 end;
end;

procedure arraydecref(var dynamicarray);
var
 refpo: pinteger;
begin
 if pointer(dynamicarray) <> nil then begin
  refpo:= pinteger(pchar(dynamicarray)-2*sizeof(integer));
  if refpo^ > 0 then begin
   dec(refpo^);
  end;
 end;
end;

procedure allocuninitedarray(count,itemsize: integer; out dynamicarray);
                 //does not init memory, dynamicarray has to be nil!
var
 po1: pinteger;
begin
 if pointer(dynamicarray) <> nil then begin
  raise exception.Create('allocunitedarray: dynamicarray not nil');
 end;
 getmem(po1,count * itemsize + 2 * sizeof(integer));
 po1^:= 1; //refcount
 {$ifdef FPC}
 pinteger(pchar(po1)+sizeof(cardinal))^:= count - 1; //high
 {$else}
 pinteger(pchar(po1)+sizeof(cardinal))^:= count;     //count
 {$endif}
 pointer(dynamicarray):= pointer(pchar(po1) + 2 * sizeof(integer));
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
  setlength(dest,count+step);
 end;
 dest[count]:= value;
 inc(count);
end;

procedure additem(var dest: msestringarty; const value: msestring;
                             var count: integer; step: integer = 32);
begin
 if length(dest) <= count then begin
  setlength(dest,count+step);
 end;
 dest[count]:= value;
 inc(count);
end;

procedure additem(var dest: lstringarty; const value: lstringty;
                             var count: integer; step: integer = 32);
begin
 if length(dest) <= count then begin
  setlength(dest,count+step);
 end;
 dest[count]:= value;
 inc(count);
end;

procedure additem(var dest: lmsestringarty; const value: lmsestringty;
                             var count: integer; step: integer = 32);
begin
 if length(dest) <= count then begin
  setlength(dest,count+step);
 end;
 dest[count]:= value;
 inc(count);
end;

procedure additem(var dest: integerarty; const value: integer;
                             var count: integer; step: integer = 32);
begin
 if length(dest) <= count then begin
  setlength(dest,count+step);
 end;
 dest[count]:= value;
 inc(count);
end;

procedure additem(var dest: pointerarty; const value: pointer;
                             var count: integer; step: integer = 32);
begin
 if length(dest) <= count then begin
  setlength(dest,count+step);
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

procedure deleteitem(var dest: stringarty; index: integer);
begin
 if (index < 0) or (index > high(dest)) then begin
  tlist.Error(SListIndexError, Index);
 end;
 dest[index]:= '';
 move(dest[index+1],dest[index],sizeof(pointer)*(high(dest)-index));
 pointer(dest[high(dest)]):= nil;
 setlength(dest,high(dest));
end;

procedure deleteitem(var dest: msestringarty; index: integer);
begin
 if (index < 0) or (index > high(dest)) then begin
  tlist.Error(SListIndexError, Index);
 end;
 dest[index]:= '';
 move(dest[index+1],dest[index],sizeof(pointer)*(high(dest)-index));
 pointer(dest[high(dest)]):= nil;
 setlength(dest,high(dest));
end;

procedure deleteitem(var dest: integerarty; index: integer);
begin
 if (index < 0) or (index > high(dest)) then begin
  tlist.Error(SListIndexError, Index);
 end;
 move(dest[index+1],dest[index],sizeof(integer)*(high(dest)-index));
 setlength(dest,high(dest));
end;

procedure deleteitem(var dest: realarty; index: integer);
begin
 if (index < 0) or (index > high(dest)) then begin
  tlist.Error(SListIndexError, Index);
 end;
 move(dest[index+1],dest[index],sizeof(real)*(high(dest)-index));
 setlength(dest,high(dest));
end;

procedure deleteitem(var dest: pointerarty; index: integer);
begin
 if (index < 0) or (index > high(dest)) then begin
  tlist.Error(SListIndexError, Index);
 end;
 move(dest[index+1],dest[index],sizeof(integer)*(high(dest)-index));
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

procedure insertitem(var dest: pointerarty; index: integer; value: pointer);
begin
 setlength(dest,high(dest) + 2);
 move(dest[index],dest[index+1],(high(dest)-index) * sizeof(dest[0]));
 dest[index]:= value;
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
 adsize = 2*sizeof(integer);

function initorderbuffer(var sortlist; const size: integer; clear: boolean;
                             out destpo: pchar): boolean;
begin
 if pointer(sortlist) = nil then begin
  result:= false;
 end
 else begin
  getmem(destpo,size*length(bytearty(sortlist))+adsize);
  pinteger(destpo)^:= 1; //refcount
  inc(destpo,4);
  pinteger(destpo)^:= pinteger(pchar(sortlist)-4)^; //length or high
  inc(destpo,4);
  result:= true;
  if clear then begin
   fillchar(destpo^,size*length(bytearty(sortlist)),0);
  end;
 end;
end;

procedure storebuffer(const asource: pchar; var sortlist);
var
 po1: pinteger;
begin
 po1:= pinteger(pchar(sortlist) - 8);
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

function comparecardinal(const l,r): integer;
begin
 if cardinal(l) > cardinal(r) then begin
  result:= 1;
 end
 else begin
  if cardinal(l) < cardinal(r) then begin
   result:= -1;
  end
  else begin
   result:= 0;
  end;
 end;
end;

procedure sortarray(var dest: cardinalarty);
begin
 sortarray(dest,{$ifdef FPC}@{$endif}comparecardinal,sizeof(cardinal));
end;

procedure sortarray(var dest: cardinalarty; out indexlist: integerarty);
begin
 sortarray(dest,{$ifdef FPC}@{$endif}comparecardinal,sizeof(cardinal),indexlist);
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
end;

destructor tdatalist.destroy;
begin
 clearbuffer;
 inherited;
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

function tdatalist.sort(const arangelist: tintegerdatalist; dorearange: boolean): boolean;
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
        compare((fdatapo+arangeList[I]*fsize)^, pp^,int1);
        if int1 = 0 then begin
         int1:= arangelist[i] - p;
        end;
        if int1 >= 0 then break;
        inc(i);
       until false;
       repeat
        int1:= 0;
        compare((fdatapo+arangeList[J]*fsize)^, pp^,int1);
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
  quicksort(pintegeraty(arangelist.fdatapo)^,0,arangelist.count-1);
  if result and dorearange then begin
   rearange(arangelist);
   fsortio:= true;
  end;
 end
 else begin
  fsortio:= true;
 end;
end;

function tdatalist.sort: boolean;
var
 arangelist: tintegerdatalist;
begin
 arangelist:= tintegerdatalist.create;
 try
  result:= sort(arangelist,true);
 finally
  arangelist.free;
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
  if (ilo_needscopy in finternaloptions) and docopy then begin
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
 change(-1);
end;

procedure tdatalist.deletedata(const index: integer);
begin
 internaldeletedata(index,true);
end;

procedure tdatalist.deleteitems(index,acount: integer);
begin
 inc(fdeleting);
 try
  internalfreedata(index,acount);
  blockcopymovedata(index+acount,index,fcount-index-acount,bcm_none);
  fcount:= fcount-acount;
  checkcapacity;
  change(-1);
 finally
  dec(fdeleting);
 end;
end;

procedure tdatalist.clear;
begin
 beginupdate;
 inc(fdeleting);
 try
  clearbuffer;
 finally
  dec(fdeleting);
  endupdate;
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

procedure tdatalist.assigndata(source: tdatalist);
begin
 if source = self then begin
  exit;
 end;
 clearbuffer;
 with source do begin
  self.fsize:= fsize;
  if fcount > 0 then begin
   self.count:= fcount;
   move(datapo^,self.fdatapo^,fcount*fsize);
  end;
 end;
 change(-1);
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
 if ilo_needsfree in finternaloptions then begin
  freedata(dest);
 end;  
 po1:= fdatapo+index*fsize;
 move(po1^,dest,fsize);
 if ilo_needscopy in finternaloptions then begin
  copyinstance(dest);
 end;
end;

procedure tdatalist.internalsetdata(index: integer; const quelle);
var
 po1: pointer;
 int1: integer;
begin
 int1:= index;
 checkindex(index);
 po1:= fdatapo+index*fsize;
 if ilo_needsfree in finternaloptions then begin
  freedata(po1^);
 end;
 move(quelle,po1^,fsize);
 if ilo_needscopy in finternaloptions then begin
  copyinstance(po1^);
 end;
 change(int1);
end;

procedure tdatalist.setdata(index: integer; const source);
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
    if (ilo_needscopy in finternaloptions) and docopy then begin
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
   if ilo_needsinit in finternaloptions then begin
    for int2:= index to index + acount - 1 do begin
     initinstance((fdatapo+int2*fsize)^);
    end;
   end;
  end
  else begin
   fillchar((fdatapo)^,int1*fsize,0);
   fillchar((fdatapo+index*fsize)^,(fmaxcount-index)*fsize,0);
   if ilo_needsinit in finternaloptions then begin
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
   if ilo_needscopy in finternaloptions then begin
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
   if ilo_needscopy in finternaloptions then begin
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
 if ilo_needsfree in finternaloptions then begin
  freedata(dest);
 end;
 po:= getdefault;
 if po = nil then begin
  fillchar(dest,fsize,0);
 end
 else begin
  move(po^,dest,fsize);
  if ilo_needscopy in finternaloptions then begin
   copyinstance(dest);
  end;
 end;
end;

procedure tdatalist.internalcleardata(const index: integer);
var
 default,po1: pointer;
begin
 po1:= fdatapo+index*fsize;
 if ilo_needsfree in finternaloptions then begin
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
 int1:= ((fcount*12) div 10) + 5;
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
   capacity:= ((value*12) div 10) + 5; //in 20% schritten
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
  if not nochangeandinit and (countvorher <> value) then begin
   change(-1);
  end;
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
  if ilo_needsfree in finternaloptions then begin
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
   if ilo_needscopy in finternaloptions then begin
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
    self.count:= fcount + freecount;
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
     self.count:= fcount + freecount;
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
     self.count:= fcount + freecount;
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

procedure tdatalist.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('data',
  {$ifdef FPC}@{$endif}readdata,{$ifdef FPC}@{$endif}writedata,fcount <> 0);
end;

procedure tdatalist.freedata(var data);
begin
 //dummy
end;

procedure tdatalist.internalfreedata(index, anzahl: integer);
begin
 if ilo_needsfree in finternaloptions then begin
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
 if ilo_needscopy in finternaloptions then begin
  forall(index,anzahl,{$ifdef FPC}@{$endif}copyinstance);
 end;
end;

procedure tdatalist.internalgetasarray(datapo: pointer);
var
 int1: integer;
begin
 if fcount > 0 then begin
  normalizering;
  move(fdatapo^,datapo^,fcount*fsize);
  if ilo_needscopy in finternaloptions then begin
   for int1:= 0 to fcount - 1 do begin
    copyinstance(datapo^);
    inc(pchar(datapo),fsize);
   end;
  end;
 end;
end;

procedure tdatalist.internalsetasarray(acount: integer; source: pointer);
begin
 try
  beginupdate;
  clear;
  count:= acount;
  if acount > 0 then begin
   move(source^,fdatapo^,acount*fsize);
   internalcopyinstance(0,acount);
  end;
 finally
  endupdate;
 end;
end;

procedure tdatalist.doitemchange(const index: integer);
begin
 if assigned(fonitemchange) then begin
  fonitemchange(self,index);
 end;
end;

procedure tdatalist.dochange;
begin
 if assigned(fonchange) then begin
  fonchange(self);
 end;
end;

procedure tdatalist.change(const index: integer);
begin
 fsortio:= false;
 if fnochange = 0 then begin
  doitemchange(index);
  if fsorted then begin
   sort;
  end;
  dochange;
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

procedure tdatalist.rearange(const arangelist: tintegerdatalist);
var
 datapo1: pchar;
 po1: pinteger;
 int1: integer;
begin
 normalizering;
 getmem(datapo1,fbytelength);
 try
  po1:= pointer(arangelist.fdatapo);
  for int1:= 0 to arangelist.fcount -1 do begin
   move((fdatapo+po1^*fsize)^,(datapo1+int1*fsize)^,fsize);
   inc(po1);
  end;
  move((fdatapo+arangelist.fcount*fsize)^,
         (datapo1+arangelist.fcount*fsize)^,
              (fcount-arangelist.fcount)*fsize);      //rest kopieren
 finally
  freemem(fdatapo);
  fdatapo:= datapo1;
 end;
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

function tdatalist.datatyp: datatypty;
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

procedure tdatalist.setsorted(const Value: boolean);
begin
 if fsorted <> value then begin
  fsorted := Value;
  if fsorted then begin
   sort;
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

function tdatalist.getitempo(index: integer): pointer;
begin
 checkindex(index);
 result:= fdatapo + index*fsize;
end;

{ tintegerdatalist }

constructor tintegerdatalist.create;
begin
 inherited;
 fsize:= sizeof(integer);
 min:= minint;
 max:= maxint;
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

procedure tintegerdatalist.assign(source: tpersistent);
begin
 if source = self then begin
  exit;
 end;
 if source is tintegerdatalist then begin
  assigndata(tdatalist(source));
 end
 else begin
  inherited;
 end;
end;

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

function tintegerdatalist.datatyp: datatypty;
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
 internalgetasarray(pointer(result));
end;

procedure tintegerdatalist.setasarray(const value: integerarty);
begin
 internalsetasarray(length(value),pointer(value));
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

procedure tintegerdatalist.readitem(const reader: treader; var value);
begin
 integer(value):= reader.ReadInteger;
end;

procedure tintegerdatalist.writeitem(const writer: twriter; var value);
begin
 writer.writeinteger(integer(value))
end;

{ tint64datalist }

constructor tint64datalist.create;
begin
 inherited;
 fsize:= sizeof(int64);
// min:= minint;
// max:= maxint;
end;

function tint64datalist.datatyp: datatypty;
begin
 result:= dl_int64;
end;

procedure tint64datalist.assign(source: tpersistent);
begin
 if source = self then begin
  exit;
 end;
 if source is tint64datalist then begin
  assigndata(tdatalist(source));
 end
 else begin
  inherited;
 end;
end;

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
 internalsetasarray(length(value),pointer(value));
end;

function tint64datalist.getasarray: int64arty;
begin
 setlength(result,fcount);
 internalgetasarray(pointer(result));
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

{ tcurrencydatalist }

constructor tcurrencydatalist.create;
begin
 inherited;
 fsize:= sizeof(currency);
// min:= minint;
// max:= maxint;
end;

function tcurrencydatalist.datatyp: datatypty;
begin
 result:= dl_currency;
end;

procedure tcurrencydatalist.assign(source: tpersistent);
begin
 if source = self then begin
  exit;
 end;
 if source is tcurrencydatalist then begin
  assigndata(tdatalist(source));
 end
 else begin
  inherited;
 end;
end;

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
 internalsetasarray(length(value),pointer(value));
end;

function tcurrencydatalist.getasarray: currencyarty;
begin
 setlength(result,fcount);
 internalgetasarray(pointer(result));
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

{ trealdatalist }

function trealdatalist.getdefault: pointer;
begin
 if fdefaultzero then begin
  result:= nil;
 end
 else begin
  fdefaultval:= emptyreal;
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

procedure trealdatalist.assign(source: tpersistent);
begin
 if source = self then begin
  exit;
 end;
 if source is trealdatalist then begin
  assigndata(tdatalist(source));
 end
 else begin
  inherited;
 end;
end;

procedure trealdatalist.assignre(source: tcomplexdatalist);      //clx
var
 int1: integer;
begin
 beginupdate;
 try
  count:= source.count;
  for int1:= 0 to count-1 do begin
   real(pointer(fdatapo+int1*fsize)^):= source.items[int1].re;
  end;
 finally
  endupdate;
 end;
end;

procedure trealdatalist.assignim(source: tcomplexdatalist);      //clx
var
 int1: integer;
begin
 beginupdate;
 try
  count:= source.count;
  for int1:= 0 to count-1 do begin
   real(pointer(fdatapo+int1+fsize)^):= source.items[int1].im;
  end;
 finally
  endupdate;
 end;
end;

constructor trealdatalist.create;
begin
 inherited;
// foptions:= foptions + [ilo_needsinit];
 fsize:= sizeof(real);
 min:= emptyreal;
 max:= bigreal;
end;

function trealdatalist.Getitems(index: integer): realty;
begin
 internalgetdata(index,result);
end;

procedure trealdatalist.insert(index: integer; const item: realty);
begin
 insertdata(index,item);
end;

procedure trealdatalist.Setitems(index: integer; const Value: realty);
begin
 internalsetdata(index,value);
end;

function trealdatalist.getasarray: realarty;
begin
 setlength(result,fcount);
 internalgetasarray(pointer(result));
end;

procedure trealdatalist.setasarray(const data: realarty);
begin
 internalsetasarray(length(data),pointer(data));
end;

function trealdatalist.datatyp: datatypty;
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
{
function trealdatalist.Getasvarrec(index: integer): tvarrec;
begin
 if isemptyreal(items[index]) then begin
  result.vtype:= vtvariant;
  result.vvariant:= pvariant(@null);
 end
 else begin
  result.vtype:= vtextended;
  extendedvar:= real(pointer(fdatapo+index*fsize)^);
  result.vextended:= @extendedvar;
 end;
end;
procedure trealdatalist.Setasvarrec(index: integer; const Value: tvarrec);
begin
 items[index]:= value.vextended^;
end;
}
procedure trealdatalist.compare(const l, r; var result: integer);
begin
 result:= cmprealty(real(l),real(r));
end;

procedure trealdatalist.fill(acount: integer; const defaultvalue: realty);
begin
 internalfill(count,defaultvalue);
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
 writerealty(writer,realty(value));
end;

{ tdatetimedatalist }

function tdatetimedatalist.datatyp: datatypty;
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

{ tcomplexdatalist }

constructor tcomplexdatalist.create;
begin
 inherited;
 fsize:= sizeof(complexty);
end;

function tcomplexdatalist.add(const value: complexty): integer;
begin
 result:= adddata(value);
end;

procedure tcomplexdatalist.assign(source: tpersistent);
begin
 if source = self then begin
  exit;
 end;
 if source is tcomplexdatalist then begin
  assigndata(tdatalist(source));
 end
 else begin
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
begin
 if source = self then begin
  exit;
 end;
 if source is tcomplexdatalist then begin
  beginupdate;
  with tcomplexdatalist(source) do begin
   self.count:= fcount;
   normalizering;
   self.normalizering;
   po1:= pointer(self.fdatapo);
   po2:= pointer(fdatapo);
   for int1:= 0 to fcount-1 do begin
    po1^.im:= po2^.im;
    inc(po1);
    inc(po2);
   end;
  end;
  endupdate;
 end
 else begin
  if source is trealdatalist then begin
   assignim(trealdatalist(source));
  end;
  inherited;
 end;
end;

procedure tcomplexdatalist.assignre(const source: trealdatalist);
var
 int1: integer;
 po1: pcomplexty;
 po2: prealty;
begin
 beginupdate;
 with source do begin
  self.count:= fcount;
  normalizering;
  self.normalizering;
  po1:= pointer(self.fdatapo);
  po2:= pointer(fdatapo);
  for int1:= 0 to fcount-1 do begin
   po1^.re:= po2^;
   inc(po1);
   inc(po2);
  end;
 end;
 endupdate;
end;

procedure tcomplexdatalist.assignim(const source: trealdatalist);
var
 int1: integer;
 po1: pcomplexty;
 po2: prealty;
begin
 beginupdate;
 with source do begin
  self.count:= fcount;
  normalizering;
  self.normalizering;
  po1:= pointer(self.fdatapo);
  po2:= pointer(fdatapo);
  for int1:= 0 to fcount-1 do begin
   po1^.im:= po2^;
   inc(po1);
   inc(po2);
  end;
 end;
 endupdate;
end;

procedure tcomplexdatalist.assigntob(const dest: tdatalist);
var
 int1: integer;
 po1: pcomplexty;
 po2: prealty;
begin
 if dest is trealdatalist then begin
  with trealdatalist(dest) do begin
   beginupdate;
   clear;
   count:= self.fcount;
   self.normalizering;
   po1:= pointer(self.fdatapo);
   po2:= pointer(fdatapo);
   for int1:= 0 to fcount-1 do begin
    po2^:= po1^.im;
    inc(po1);
    inc(po2);
   end;
   endupdate;
  end;
 end
 else begin
  inherited;
 end;
end;

procedure tcomplexdatalist.assignto(dest: tpersistent);
var
 int1: integer;
 po1: pcomplexty;
 po2: prealty;
begin
 if dest is trealdatalist then begin
  with trealdatalist(dest) do begin
   beginupdate;
   clear;
   count:= self.fcount;
   self.normalizering;
   po1:= pointer(self.fdatapo);
   po2:= pointer(fdatapo);
   for int1:= 0 to fcount-1 do begin
    po2^:= po1^.re;
    inc(po1);
    inc(po2);
   end;
   endupdate;
  end;
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

function tcomplexdatalist.datatyp: datatypty;
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
  fdefaultval.re:= emptyreal;
  fdefaultval.im:= emptyreal;
  result:= @fdefaultval;
 end;
end;

function tcomplexdatalist.getasarray: complexarty;
begin
 setlength(result,fcount);
 internalgetasarray(pointer(result));
end;

procedure tcomplexdatalist.setasarray(const data: complexarty);
begin
 internalsetasarray(length(data),pointer(data));
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
  writerealty(writer,complexty(value).re);
  writerealty(writer,complexty(value).im);
  writelistend;
 end;
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
 internalgetasarray(pointer(result));
end;

procedure tpointerdatalist.setasarray(const data: pointerarty);
begin
 internalsetasarray(length(data),data[0]);
end;

{ tdynamicdatalist }

constructor tdynamicdatalist.create;
begin
 inherited;
 finternaloptions:= finternaloptions + [ilo_needsfree,ilo_needscopy];
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
begin
 if source = self then begin
  exit;
 end;
 if source is tansistringdatalist then begin
  beginupdate;
  with source as tansistringdatalist do begin
   self.count:= count;
   po1:= pointer(self.fdatapo);
   po2:= pointer(fdatapo);
   for int1:= 0 to count - 1 do begin
    po1^:= po2^;
    inc(po1);
    inc(po2);
   end;
  end;
  endupdate;
 end
 else begin
  if source is tstringlist then begin
   beginupdate;
   with source as tstringlist do begin
    self.count:= count;
    po1:= pointer(self.fdatapo);
    for int1:= 0 to count - 1 do begin
     po1^:= strings[int1];
     inc(po1);
    end;
   end;
   endupdate;
  end
  else begin
   inherited;
  end;
 end;
end;

procedure tansistringdatalist.assignarray(const data: array of ansistring);
var
 ar1: stringarty;
 int1: integer;
begin
 setlength(ar1,length(data));
 for int1:= 0 to high(data) do begin
  ar1[int1]:= data[int1];
 end;
 assignarray(ar1);
end;

procedure tansistringdatalist.assignarray(const data: stringarty);
var
 int1: integer;
 po1: pansistring;
begin
 beginupdate;
 try
  count:= 0;
  count:= length(data);
  po1:= pointer(fdatapo);
  for int1:= 0 to length(data)-1 do begin
   po1^:= data[int1];
   inc(pchar(po1),fsize);
  end;
 finally
  endupdate;
 end;
end;

procedure tansistringdatalist.assignarray(const data: msestringarty);
var
 int1: integer;
 po1: pansistring;
begin
 beginupdate;
 try
  count:= 0;
  count:= length(data);
  po1:= pointer(fdatapo);
  for int1:= 0 to length(data)-1 do begin
   po1^:= ansistring(data[int1]);
   inc(pchar(po1),fsize);
  end;
 finally
  endupdate;
 end;
end;

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

function tansistringdatalist.datatyp: datatypty;
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
begin
 if dest is tstringlist then begin
  normalizering;
  po1:= pointer(fdatapo);
  with dest as tstringlist do begin
   clear;
   capacity:= self.count;
   for int1:= 0 to self.count-1 do begin
    add(po1^);
    inc(po1);
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

{$ifdef FPC} {$define fpcbug4519} {$endif}
{$define fpcbug4519read}

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
  result:= reader.readwidestring;
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
 {$ifdef fpcbug4519}
 WriteString4519(writer,string(value));
 {$else}
 writer.WriteString(string(value));
 {$endif}
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
 internalgetasarray(pointer(result));
end;

procedure tansistringdatalist.setasarray(const avalue: stringarty);
begin
 internalsetasarray(length(avalue),pointer(avalue));
end;

function tansistringdatalist.getasmsestringarray: msestringarty;
var
 po1: pstringaty;
 int1: integer;
begin
 setlength(result,fcount);
 po1:= datapo;
 for int1:= 0 to fcount - 1 do begin
  result[int1]:= po1^[int1];
 end;
end;

procedure tansistringdatalist.setasmsestringarray(const avalue: msestringarty);
var
 int1: integer;
begin
 try
  beginupdate;
  clear;
  count:= length(avalue);
  for int1:= 0 to count - 1 do begin
   pstringaty(fdatapo)^[int1]:= avalue[int1];
  end;
 finally
  endupdate;
 end;
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
    doitemchange(int1);
   end;
  end;
  if high(ar1) > 0 then begin
   endupdate;
  end;
 end;
 result:= fcount-1;
end;

procedure tpoorstringdatalist.assign(source: tpersistent);
var
 int1: integer;
 po1,po2: pmsestring;
 po3: pstringaty;
begin
 if source = self then begin
  exit;
 end;
 if source is tpoorstringdatalist then begin
  beginupdate;
  with source as tpoorstringdatalist do begin
   po2:= pointer(datapo);
   self.clear;
   self.count:= count;
   po1:= pointer(self.fdatapo);
   for int1:= 0 to count - 1 do begin
    po1^:= po2^;
    inc(pchar(po1),self.fsize);
    inc(pchar(po2),fsize);
   end;
  end;
  endupdate;
 end
 else begin
  if source is tansistringdatalist then begin
   beginupdate;
   with source as tansistringdatalist do begin
    po3:= pstringaty(datapo);
    self.clear;
    self.count:= count;
    po1:= pointer(self.fdatapo);
    for int1:= 0 to count - 1 do begin
     po1^:= po3^[int1];
     inc(pchar(po1),fsize);
    end;
   end;
   endupdate;
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
begin
 if dest is tstringlist then begin
  normalizering;
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
 msestring(value):= reader.ReadwideString;
 {$endif}
end;

procedure tpoorstringdatalist.writeitem(const writer: twriter; var value);
begin
 {$ifdef fpcbug4519}
 writewidestring4519(writer,msestring(value));
 {$else}
 writer.WritewideString(msestring(value));
 {$endif}
end;

procedure tpoorstringdatalist.loadfromstream(const stream: ttextstream);
var
 mstr1: msestring;
begin
 beginupdate;
 try
  clear;
  while stream.readln(mstr1) do begin
   add(mstr1);
  end;
  if mstr1 <> '' then begin
   add(mstr1);
  end;
 finally
  endupdate;
 end;
end;

procedure tpoorstringdatalist.loadfromfile(const filename: string);
var
 stream: ttextstream;
begin
 stream:= ttextstream.Create(filename,fm_read);
 try
  loadfromstream(stream);
 finally
  stream.Free;
 end;
end;

procedure tpoorstringdatalist.savetofile(const filename: string);
var
 stream: ttextstream;
begin
 stream:= ttextstream.Create(filename,fm_create);
 try
  savetostream(stream);
 finally
  stream.Free;
 end;
end;

procedure tpoorstringdatalist.savetostream(const stream: ttextstream);
var
 int1: integer;
begin
 for int1:= 0 to count - 1 do begin
  stream.writeln(items[int1]);
 end;
end;

function tpoorstringdatalist.dataastextstream: ttextstream; //chars truncated to 8bit
var
 len: integer;
 int1,int2,int3,int4: integer;
 po1,po2: pchar;
 bo1: boolean;
 ch1,ch2: char;
 wch1: widechar;
begin
 result:= ttextstream.create; //memorystream
 po1:= datapo;
 int2:= 0;
 for int1:= 0 to fcount - 1 do begin
  inc(int2,length(msestring(pointer(po1)^)));
  inc(po1,fsize);
 end;
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
    (po2 + int3)^:= char(wch1);
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
 internalgetasarray(pointer(result));
end;

procedure tpoorstringdatalist.setasarray(const data: msestringarty);
begin
 internalsetasarray(length(data),pointer(data));
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
 ar1: msestringarty;
 int1: integer;
begin
 setlength(ar1,length(data));
 for int1:= 0 to high(data) do begin
  ar1[int1]:= data[int1];
 end;
 setasarray(ar1);
end;

procedure tpoorstringdatalist.assignarray(const data: array of msestring);
var
 ar1: msestringarty;
 int1: integer;
begin
 setlength(ar1,length(data));
 for int1:= 0 to high(data) do begin
  ar1[int1]:= data[int1];
 end;
 assignarray(ar1);
end;

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
                   const separator: msestring = ''): msestring;
var
 int1: integer;
begin
 if fcount > 0 then begin
  normalizering;
  result:= delim + pmsestring(fdatapo)^ + delim;
  for int1:= 1 to fcount-1 do begin
   result:= result + separator + delim +
         pmsestring(fdatapo+int1*fsize)^ + delim;
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

{ tmsestringdatalist }

function tmsestringdatalist.datatyp: datatypty;
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

function tdoublemsestringdatalist.datatyp: datatypty;
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
{$ifdef FPC}
 result:= comparestr(doublemsestringty(l).a,doublemsestringty(r).a); //!!!!todo
{$else}
 result:= msecomparestr(doublemsestringty(l).a,doublemsestringty(r).a);
{$endif}
end;
{
function tdoublestringdatalist.Getdoubleitemspo(index: integer): pdoublemsestringty;
begin
 checkindex(index);
 result:= @lidoublemsestringarty(fdatapo^)[index];
end;
}
procedure tdoublemsestringdatalist.assign(source: tpersistent);
var
 int1: integer;
 po1,po2: pdoublemsestringty;
begin
 if source = self then begin
  exit;
 end;
 if source is tdoublemsestringdatalist then begin
  beginupdate;
  with source as tdoublemsestringdatalist do begin
   po2:= pointer(fdatapo);
   self.clear;
   self.count:= count;
   po1:= pointer(self.fdatapo);
   for int1:= 0 to count - 1 do begin
    po1^:= po2^;
    inc(pchar(po1),self.fsize);
    inc(pchar(po2),fsize);
   end;
  end;
  endupdate;
 end
 else begin
  inherited;
 end;
end;

procedure tdoublemsestringdatalist.assignb(const source: tdatalist);
var
 int1: integer;
 po1,po2: pdoublemsestringty;
 po3: pmsestring;
begin
 if source is tdoublemsestringdatalist then begin
  beginupdate;
  with tdoublemsestringdatalist(source) do begin
   self.count:= fcount;
   normalizering;
   self.normalizering;
   po1:= pointer(self.fdatapo);
   po2:= pointer(fdatapo);
   for int1:= 0 to fcount-1 do begin
    po1^.b:= po2^.b;
    inc(po1);
    inc(po2);
   end;
  end;
  endupdate;
 end
 else begin
  if source is tmsestringdatalist then begin
   beginupdate;
   with tmsestringdatalist(source) do begin
    self.count:= fcount;
    normalizering;
    self.normalizering;
    po1:= pointer(self.fdatapo);
    po3:= pointer(fdatapo);
    for int1:= 0 to fcount-1 do begin
     po1^.b:= po3^;
     inc(po1);
     inc(po3);
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
begin
 if dest is tmsestringdatalist then begin
  with tmsestringdatalist(dest) do begin
   beginupdate;
   clear;
   count:= self.fcount;
   self.normalizering;
   po1:= pointer(self.fdatapo);
   po2:= pointer(fdatapo);
   for int1:= 0 to fcount-1 do begin
    po2^:= po1^.b;
    inc(po1);
    inc(po2);
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
 internalsetasarray(length(data),pointer(data));
end;

function tdoublemsestringdatalist.getasarray: doublemsestringarty;
begin
 setlength(result,fcount);
 internalgetasarray(pointer(result));
end;

function tdoublemsestringdatalist.getasarraya: msestringarty;
var
 int1: integer;
 po1: pdoublemsestringty;
begin
 setlength(result,fcount);
 po1:= pdoublemsestringty(datapo);
 for int1:= 0 to fcount - 1 do begin
  result[int1]:= po1^.a;
  inc(po1);
 end;
end;

procedure tdoublemsestringdatalist.setasarraya(const data: msestringarty);
var
 int1: integer;
 po1: pdoublemsestringty;
begin
 beginupdate;
  count:= length(data);
  po1:= pdoublemsestringty(datapo);
  for int1:= 0 to fcount - 1 do begin
   po1^.a:= data[int1];
   inc(po1);
  end;
 endupdate;
end;

procedure tdoublemsestringdatalist.setasarrayb(const data: msestringarty);
var
 int1: integer;
 po1: pdoublemsestringty;
begin
 beginupdate;
  count:= length(data);
  po1:= pdoublemsestringty(datapo);
  for int1:= 0 to fcount - 1 do begin
   po1^.b:= data[int1];
   inc(po1);
  end;
 endupdate;
end;

function tdoublemsestringdatalist.getasarrayb: msestringarty;
var
 int1: integer;
 po1: pdoublemsestringty;
begin
 setlength(result,fcount);
 normalizering;
 po1:= pdoublemsestringty(fdatapo);
 for int1:= 0 to fcount - 1 do begin
  result[int1]:= po1^.b;
  inc(po1);
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
  doublemsestringty(value).a:= readwidestring; 
  doublemsestringty(value).b:= readwidestring;
  {$endif}
  readlistend;
 end;
end;

procedure tdoublemsestringdatalist.writeitem(const writer: twriter; var value);
begin
 with writer do begin
  writelistbegin;
 {$ifdef fpcbug4519}
  writewidestring4519(writer,doublemsestringty(value).a);
  writewidestring4519(writer,doublemsestringty(value).b);
 {$else}
  writewidestring(doublemsestringty(value).a);
  writewidestring(doublemsestringty(value).b);
 {$endif}
  writelistend;
 end;
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
 finternaloptions:= (finternaloptions - [ilo_needscopy]) + [ilo_needsinit];
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

end.
