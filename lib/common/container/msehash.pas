{ MSEgui Copyright (c) 1999-2017 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msehash;

{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}

interface
uses
 msestrings,msetypes;
//
//todo: use objects instead of records
// 
type
 identty = card32;
 pidentty = ^identty;
 hashvaluety = card32;
 phashvaluety = ^hashvaluety;
 hashoffsetty = int32;//ptruint;
 phashoffsetty = ^hashoffsetty;
 hashoffsetarty = array of hashoffsetty;

 hashheaderty = record
  prevhash: hashoffsetty; //offset from liststart
  nexthash: hashoffsetty; //offset from liststart
  prevlist: hashoffsetty; //memory offset to previous item
  nextlist: hashoffsetty; //memory offset to next item
  hash: hashvaluety;
//dummy: card32;
 end;
 phashheaderty = ^hashheaderty;
{
 hashdatadataty = record
 end;
 phashdatadataty = ^hashdatadataty;
} 
 hashdataty = record
  header: hashheaderty;
//  data: hashdatadataty;
 end;
 phashdataty = ^hashdataty;

 hashiteratorprocty = procedure(const aitem: phashdataty) of object;
 internalhashiteratorprocty = procedure(const aitem: phashdataty) of object;
 keyhashiteratorprocty = procedure(const aitem: phashdataty) of object; 
 findcheckprocty = procedure(const aitem: phashdataty;
                                          var accept: boolean) of object;

 hashliststatety = (hls_needsnull,hls_needsinit,hls_needsfinalize,
                                                       hls_destroying);
 hashliststatesty = set of hashliststatety;

 thashdatalist = class
  private
//   fdatasize: integer;
   frecsize: int32;
   fcapacity: int32;
   fcount: int32;
   fassignedfirst: hashoffsetty; //offset to fdata
   fassignedlast: hashoffsetty; //offset to fdata
   fdeletedroot: hashoffsetty;  //offset to fdata
   fcurrentitem: hashoffsetty;  //offset to fdata.data
   fdestpo: phashdataty;
   procedure setcapacity(const avalue: integer);
   procedure moveitem(const aitem: phashdataty);
  protected
   fdata: pointer;         //first record is a dummy
   fmask: hashvaluety;
   fhashtable: hashoffsetarty;//ptruintarty;
   fstate: hashliststatesty;
  {$ifdef mse_debug_hash}
   procedure checkhash;
   procedure checkexists(const aitem: phashdataty);
   procedure checknotexists(const aitem: phashdataty);
  {$endif}
   property data: pointer read fdata;
   property assignedfirst: hashoffsetty read fassignedfirst;
   property assignedlast: hashoffsetty read fassignedlast;
   function getdatapoornil(const aoffset: hashoffsetty): pointer; inline;
   function getdatapo(const aoffset: hashoffsetty): pointer; inline;
   function getdataoffs(const adata: pointer): hashoffsetty; inline;
   function internaladd(const akey): phashdataty;
   function internaladdhash(hash1: hashvaluety): phashdataty;
   procedure inserthash(ahash: hashvaluety; const adata: phashdataty);
   procedure removehash(aitem: phashdataty); // does not delete ithem
   procedure internaldeleteitem(const aitem: phashdataty); overload;
//   procedure internaldeleteitem(const aitem: phashdatadataty); overload;
   procedure internaldelete(const aoffset: hashoffsetty);
   function internaldelete(const akey; const all: boolean): boolean;
   function internalfind(const akey): phashdataty; overload;
   function internalfind(const akey;
                             hash1: hashvaluety): phashdataty; overload;
   function internalfind(const akey; out acount: integer): phashdataty; overload;
   function internalfind(const akey;
               const acheckproc: findcheckprocty): phashdataty; overload;
   function internalfind(const akey;
               const acheckproc: findcheckprocty;
               out acount: integer): phashdataty; overload;
   function internalfindexact(const akey): phashdataty; overload;
   function internalfindexact(const akey;
                           out acount: integer): phashdataty; overload;
   procedure checkexact(const aitem: phashdataty; var accept: boolean) virtual;
   function hashkey(const akey): hashvaluety; virtual; abstract;
   function checkkey(const akey;
                  const aitem: phashdataty): boolean; virtual; abstract;
   function getrecordsize(): int32 virtual abstract;
   procedure rehash;
   procedure grow;
   procedure inititem(const aitem: phashdataty) virtual;
   procedure finalizeitem(const aitem: phashdataty) virtual;
   procedure internaliterate(
                       const aiterator: internalhashiteratorprocty); overload;
   procedure iterate(const akey; 
                            const aiterator: keyhashiteratorprocty); overload;
   function internalfirstx: phashdataty;
   function internallastx: phashdataty;
   function internalnextx: phashdataty;
   function internalprevx: phashdataty;
  public
   constructor create();
   destructor destroy; override;
   procedure clear; virtual;
   procedure reset; //next next() will return first, next prev() will return last
   property capacity: integer read fcapacity write setcapacity;
   property count: integer read fcount;
   procedure mark(out ref: hashoffsetty);
   procedure release(const ref: hashoffsetty);
   function absdata(const ref: ptrint): pointer; 
                   //returns pointer to hashdataty.data from mark(ref)
   property recsize: int32 read frecsize;
   procedure iterate(const aiterator: hashiteratorprocty); overload;
 end;
 
 integerdataty = record
  key: integer;
//  data: record end;
 end;
 pintegerdataty = ^integerdataty;
 integerhashdataty = record
  header: hashheaderty;
  data: integerdataty;
 end;
 pintegerhashdataty = ^integerhashdataty;
 
 tintegerhashdatalist = class(thashdatalist)
  private
  protected
   function hashkey(const akey): hashvaluety; override;
   function checkkey(const akey; const aitem: phashdataty): boolean; override;
   function getrecordsize(): int32 override;
  public
//   constructor create();
   function add(const akey: integer): pintegerhashdataty;
   function addunique(const akey: integer): pintegerhashdataty;
   function addunique(const akey: integer; 
                           out adata: pintegerhashdataty): boolean;
                                             //true if new
   function find(const akey: integer): pintegerhashdataty;
   function delete(const akey: integer; 
                         const all: boolean = false): boolean; overload;
                         //true if found
   function first: pintegerhashdataty;
   function next: pintegerhashdataty; //wraps to first after last
   function last: pintegerhashdataty;
   function prev: pintegerhashdataty; //wraps to last after first
 end;

 doubleintegerty = record
  a: integer;
  b: integer;
 end;
 doubleintegerdataty = record
  key: doubleintegerty;
//  data: record end;
 end;
 pdoubleintegerdataty = ^doubleintegerdataty;
 doubleintegerhashdataty = record
  header: hashheaderty;
  data: doubleintegerdataty;
 end;
 pdoubleintegerhashdataty = ^doubleintegerhashdataty;
 
 tdoubleintegerhashdatalist = class(thashdatalist)
  private
  protected
   function hashkey(const akey): hashvaluety; override;
   function checkkey(const akey; const aitem: phashdataty): boolean; override;
   function getrecordsize(): int32 override;
  public
//   constructor create(const datasize: integer);
   function add(const akeya,akeyb: integer): pdoubleintegerhashdataty;
   function addunique(const akeya,akeyb: integer): pdoubleintegerhashdataty;
   function addunique(const akeya,akeyb: integer; 
                           out adata: pdoubleintegerhashdataty): boolean;
                                             //true if new
   function find(const akeya,akeyb: integer): pdoubleintegerhashdataty;
   function delete(const akeya,akeyb: integer; 
                         const all: boolean = false): boolean; overload;
                         //true if found
   function first: pdoubleintegerhashdataty;
   function next: pdoubleintegerhashdataty; //wraps to first after last
   function last: pdoubleintegerhashdataty;
   function prev: pdoubleintegerhashdataty; //wraps to last after first
 end;

 pointerdataty = record
  key: pointer;
//  data: record end;
 end;
 ppointerdataty = ^pointerdataty;
 pointerhashdataty = record
  header: hashheaderty;
  data: pointerdataty;
 end;
 ppointerhashdataty = ^pointerhashdataty;
 
 tpointerhashdatalist = class(thashdatalist)
  private
  protected
   function hashkey(const akey): hashvaluety; override;
   function checkkey(const akey; const aitem: phashdataty): boolean; override;
   function getrecordsize(): int32 override;
  public
//   constructor create(const datasize: integer);
   function add(const akey: pointer): ppointerhashdataty;
   function addunique(const akey: pointer): ppointerhashdataty;
   function find(const akey: pointer): ppointerhashdataty;
   function delete(const akey: pointer;
                         const all: boolean = false): boolean; overload;
                         //true if found
   function first: ppointerhashdataty;
   function next: ppointerhashdataty; //wraps to first after last
   function last: ppointerhashdataty;
   function prev: ppointerhashdataty; //wraps to last after first
 end;

 ptruintdataty = record
  key: ptruint;
//  data: record end;
 end;
 pptruintdataty = ^ptruintdataty;
 ptruinthashdataty = record
  header: hashheaderty;
  data: ptruintdataty;
 end;
 pptruinthashdataty = ^ptruinthashdataty;
 
 tptruinthashdatalist = class(thashdatalist)
  private
  protected
   function hashkey(const akey): hashvaluety; override;
   function checkkey(const akey; const aitem: phashdataty): boolean; override;
   function getrecordsize(): int32 override;
  public
//   constructor create(const datasize: integer);
   function add(const akey: ptruint): pptruinthashdataty;
   function addunique(const akey: ptruint): pptruinthashdataty;
   function find(const akey: ptruint): pptruinthashdataty;
   function delete(const akey: ptruint; 
                         const all: boolean = false): boolean; overload;
                         //true if found
   function first: pptruinthashdataty;
   function next: pptruinthashdataty; //wraps to first after last
   function last: pptruinthashdataty;
   function prev: pptruinthashdataty; //wraps to last after first
 end;

 pointerptruintdataty = record
  key: ptruint;
  data: pointer;
 end;
 ppointerptruintdataty = ^pointerptruintdataty;
 pointerptruinthashdataty = record
  header: hashheaderty;
  data: pointerptruintdataty;
 end;
 ppointerptruinthashdataty = ^pointerptruinthashdataty;

 pointerptruintiteratorprocty = 
           procedure(const aitem: pointerptruinthashdataty) of object;

 tpointerptruinthashdatalist = class(tptruinthashdatalist)
  private
   fpointerparam: pointer;
  protected
   procedure checkexact(const aitem: phashdataty;
                                       var accept: boolean); override;
   function getrecordsize(): int32 override;
  public
//   constructor create;
   procedure add(const akey: ptruint; const avalue: pointer);
   function addunique(const akey: ptruint; const avalue: pointer): boolean;
                   //true if found
   procedure delete(const akey: ptruint; const avalue: pointer); overload;
   function find(const akey: ptruint): pointer; overload;
   function find(const akey: ptruint; out avalue: pointer): boolean; overload;
   function first: ppointerptruinthashdataty;
   function next: ppointerptruinthashdataty; //wraps to first after last
   function last: ppointerptruinthashdataty;
   function prev: ppointerptruinthashdataty; //wraps to last after first
   procedure iterate(const akey: ptruint;
                     const aiterator: pointerptruintiteratorprocty); overload;
 end;

 ansistringptruintdataty = record
  key: ptruint;
  data: ansistring;
 end;
 pansistringptruintdataty = ^ansistringptruintdataty;
 ansistringptruinthashdataty = record
  header: hashheaderty;
  data: ansistringptruintdataty;
 end;
 pansistringptruinthashdataty = ^ansistringptruinthashdataty;

 ansistringptruintiteratorprocty = 
            procedure(const aitem: pansistringptruinthashdataty) of object;

 tansistringptruinthashdatalist = class(tptruinthashdatalist)
  private
   fansistringparam: ansistring;
  protected
   procedure checkexact(const aitem: phashdataty; var accept: boolean) override;
   procedure finalizeitem(const aitem: phashdataty) override;
   function getrecordsize(): int32 override;
  public
   constructor create;
   procedure add(const akey: ptruint; const avalue: ansistring);
   function addunique(const akey: ptruint; const avalue: ansistring): boolean;
                   //true if found
   procedure delete(const akey: ptruint; const avalue: ansistring) overload;
   function find(const akey: ptruint): ansistring overload;
   function find(const akey: ptruint; out avalue: ansistring): boolean overload;
   function first: pansistringptruinthashdataty;
   function next: pansistringptruinthashdataty; //wraps to first after last
   function last: pansistringptruinthashdataty;
   function prev: pansistringptruinthashdataty; //wraps to last after first
   procedure iterate(const akey: ptruint;
                     const aiterator: ansistringptruintiteratorprocty) overload;
   function setdata(const akey: ptruint; const avalue: ansistring): boolean;
                      //false if not found
 end;
 
 msestringptruintdataty = record
  key: ptruint;
  data: msestring;
 end;
 pmsestringptruintdataty = ^msestringptruintdataty;
 msestringptruinthashdataty = record
  header: hashheaderty;
  data: msestringptruintdataty;
 end;
 pmsestringptruinthashdataty = ^msestringptruinthashdataty;

 msestringptruintiteratorprocty = 
                procedure(const aitem: pmsestringptruinthashdataty) of object;

 tmsestringptruinthashdatalist = class(tptruinthashdatalist)
  private
   fmsestringparam: msestring;
  protected
   procedure checkexact(const aitem: phashdataty;
                                     var accept: boolean); override;
   procedure finalizeitem(const aitem: phashdataty); override;
   function getrecordsize(): int32 override;
  public
   constructor create;
   procedure add(const akey: ptruint; const avalue: msestring);
   function addunique(const akey: ptruint; const avalue: msestring): boolean;
                   //true if found
   procedure delete(const akey: ptruint; const avalue: msestring); overload;
   function find(const akey: ptruint): msestring; overload;
   function find(const akey: ptruint; out avalue: msestring): boolean; overload;
   function first: pmsestringptruinthashdataty;
   function next: pmsestringptruinthashdataty; //wraps to first after last
   function last: pmsestringptruinthashdataty;
   function prev: pmsestringptruinthashdataty; //wraps to last after first
   procedure iterate(const akey: ptruint;
                     const aiterator: msestringptruintiteratorprocty); overload;
   function setdata(const akey: ptruint; const avalue: msestring): boolean;
                      //false if not found
 end;
 
 ansistringdataty = record
  key: ansistring;
//  data: record end;
 end;
 pansistringdataty = ^ansistringdataty;
 ansistringhashdataty = record
  header: hashheaderty;
  data: ansistringdataty;
 end;
 pansistringhashdataty = ^ansistringhashdataty;
 
 ansistringhashiteratorprocty = 
                     procedure(const aitem: pansistringhashdataty) of object;

 tansistringhashdatalist = class(thashdatalist)
  private
  protected
   function hashkey(const akey): hashvaluety; override;
   function checkkey(const akey; const aitem: phashdataty): boolean; override;
   function hashlkey(const akey: lstringty): hashvaluety;
   function checklkey(const akey: lstringty; 
                                  const aitemdata: ansistringdataty): boolean;
   procedure finalizeitem(const aitem: phashdataty) override;
   function getrecordsize(): int32 override;
  public
   constructor create();
   function add(const akey: ansistring): pansistringhashdataty; 
   function addunique(const akey: ansistring): pansistringhashdataty;
   function find(const akey: ansistring): pansistringhashdataty; overload;
   function find(const akey: lstringty): pansistringhashdataty; overload;
   function delete(const akey: ansistring; 
                         const all: boolean = false): boolean; overload;
                         //true if found
   function delete(const akey: lstringty; 
                         const all: boolean = false): boolean; overload;
                         //true if found
   function first: pansistringhashdataty;
   function next: pansistringhashdataty; //wraps to first after last
   function last: pansistringhashdataty;
   function prev: pansistringhashdataty; //wraps to last after first
   procedure iterate(const akey: ansistring;
                     const aiterator: ansistringhashiteratorprocty); overload;
 end;

 pointeransistringdataty = record
  key: ansistring;
  data: pointer;
 end;
 ppointeransistringdataty = ^pointeransistringdataty;
 pointeransistringhashdataty = record
  header: hashheaderty;
  data: pointeransistringdataty;
 end;
 ppointeransistringhashdataty = ^pointeransistringhashdataty;

 pointeransistringiteratorprocty = 
             procedure(const aitem: ppointeransistringhashdataty) of object;

 tpointeransistringhashdatalist = class(tansistringhashdatalist)
  private
   fpointerparam: pointer;
  protected
   procedure checkexact(const aitem: phashdataty; var accept: boolean) override;
   function getrecordsize(): int32 override;
  public
//   constructor create;
   procedure add(const akey: ansistring; const avalue: pointer); overload;
   procedure add(const keys: array of string;
                   startindex: pointer = pointer($00000001)); overload;
                             //data = arrayindex + startindex
   function addunique(const akey: ansistring; const avalue: pointer): boolean;
                   //true if found
   procedure delete(const akey: ansistring; const avalue: pointer) overload;
   function find(const akey: ansistring): pointer; overload;
   function find(const akey: ansistring; out avalue: pointer): boolean overload;
   function find(const akey: lstringty): pointer; overload;
   function first: ppointeransistringhashdataty;
   function next: ppointeransistringhashdataty; //wraps to first after last
   function last: ppointeransistringhashdataty;
   function prev: ppointeransistringhashdataty; //wraps to last after first
   procedure iterate(const akey: ansistring;
                     const aiterator: pointeransistringiteratorprocty) overload;
 end;

 msestringdataty = record
  key: msestring;
//  data: record end;
 end;
 pmsestringdataty = ^msestringdataty;
 msestringhashdataty = record
  header: hashheaderty;
  data: msestringdataty;
 end;
 pmsestringhashdataty = ^msestringhashdataty;
 
 msestringiteratorprocty = 
               procedure(const aitem: pmsestringhashdataty) of object;

 tmsestringhashdatalist = class(thashdatalist)
  private
  protected
   function hashkey(const akey): hashvaluety; override;
   function checkkey(const akey; const aitem: phashdataty): boolean; override;
   function hashlkey(const akey: lmsestringty): hashvaluety;
   function checklkey(const akey: lmsestringty;
                                const aitemdata: msestringdataty): boolean;
   procedure finalizeitem(const aitem: phashdataty) override;
   function getrecordsize(): int32 override;
  public
   constructor create();
   function add(const akey: msestring): pmsestringhashdataty;
   function addunique(const akey: msestring): pmsestringhashdataty;
   function find(const akey: msestring): pmsestringhashdataty; overload;
   function find(const akey: lmsestringty): pmsestringhashdataty; overload;
   function find(const akey: msestring;
               out acount: integer): pmsestringhashdataty; overload;
   function delete(const akey: msestring; 
                         const all: boolean = false): boolean; overload;
                                      //true if found
   function delete(const akey: lmsestringty; 
                         const all: boolean = false): boolean; overload;
                                      //true if found
   function first: pmsestringhashdataty;
   function next: pmsestringhashdataty; //wraps to first after last
   function last: pmsestringhashdataty;
   function prev: pmsestringhashdataty; //wraps to last after first
   procedure iterate(const akey: msestring;
                     const aiterator: msestringiteratorprocty); overload;
 end;

 pointermsestringdataty = record
  key: msestring;
  data: pointer;
 end;
 ppointermsestringdataty = ^pointermsestringdataty;
 pointermsestringhashdataty = record
  header: hashheaderty;
  data: pointermsestringdataty;
 end;
 ppointermsestringhashdataty = ^pointermsestringhashdataty;

 pointermsestringiteratorprocty = 
                procedure(const aitem: ppointermsestringhashdataty) of object;

 tpointermsestringhashdatalist = class(tmsestringhashdatalist)
  private
   fpointerparam: pointer;
  protected
   procedure checkexact(const aitem: phashdataty; var accept: boolean) override;
   function getrecordsize(): int32 override;
  public
//   constructor create;
   procedure add(const akey: msestring; const avalue: pointer);
   function addunique(const akey: msestring; const avalue: pointer): boolean;
                   //true if found
   procedure delete(const akey: msestring; const avalue: pointer);
   function find(const akey: msestring): pointer; overload;
   function find(const akey: msestring; out avalue: pointer): boolean; overload;
   function find(const akey: msestring; out avalue: pointer;
                                        out acount: integer): boolean; overload;
   function find(const akey: lmsestringty): pointer; overload;
   function first: ppointermsestringhashdataty;
   function next: ppointermsestringhashdataty; //wraps to first after last
   function last: ppointermsestringhashdataty;
   function prev: ppointermsestringhashdataty; //wraps to last after first
   procedure iterate(const akey: msestring;
                     const aiterator: pointermsestringiteratorprocty); overload;
 end;

 integermsestringdataty = record
  key: msestring;
  data: integer;
 end;
 pintegermsestringdataty = ^integermsestringdataty;
 integermsestringhashdataty = record
  header: hashheaderty;
  data: integermsestringdataty;
 end;
 pintegermsestringhashdataty = ^integermsestringhashdataty;

 integermsestringiteratorprocty = 
             procedure(const aitem: pintegermsestringhashdataty) of object;

 tintegermsestringhashdatalist = class(tmsestringhashdatalist)
  private
   fintegerparam: integer;
  protected
   procedure checkexact(const aitem: phashdataty; var accept: boolean) override;
   function getrecordsize(): int32 override;
  public
//   constructor create;
   procedure add(const akey: msestring; const avalue: integer);
   function addunique(const akey: msestring; const avalue: integer): boolean;
                   //true if found
   procedure delete(const akey: msestring; const avalue: integer);
   function find(const akey: msestring): integer; overload; //-1 if not found
   function find(const akey: msestring; out avalue: integer): boolean; overload;
   function find(const akey: msestring; out avalue: integer;
                                        out acount: integer): boolean; overload;
   function find(const akey: lmsestringty): integer; overload; //-1 if not found
   function first: pintegermsestringhashdataty;
   function next: pintegermsestringhashdataty; //wraps to first after last
   function last: pintegermsestringhashdataty;
   function prev: pintegermsestringhashdataty; //wraps to last after first
   procedure iterate(const akey: msestring;
                     const aiterator: integermsestringiteratorprocty); overload;
 end;

 objectmsestringdataty = record
  key: msestring;
  data: tobject;
 end;
 pobjectmsestringdataty = ^objectmsestringdataty;
 objectmsestringhashdataty = record
  header: hashheaderty;
  data: objectmsestringdataty;
 end;
 pobjectmsestringhashdataty = ^objectmsestringhashdataty;

 objectmsestringiteratorprocty = 
              procedure(const aitem: pobjectmsestringhashdataty) of object;

 tobjectmsestringhashdatalist = class(tpointermsestringhashdatalist)
  protected
   fownsobjects: boolean;
   procedure finalizeitem(const aitem: phashdataty) override;
  public
   constructor create(const aownsobjects: boolean = true);
   procedure add(const akey: msestring; const avalue: tobject);
   function addunique(const akey: msestring; const avalue: tobject): boolean;
                   //true if found
   procedure delete(const akey: msestring; const avalue: tobject);
   function find(const akey: msestring): tobject; overload;
   function find(const akey: msestring; out avalue: tobject): boolean; overload;
   function find(const akey: msestring; out avalue: tobject;
                                        out acount: integer): boolean; overload;
   function first: pobjectmsestringhashdataty;
   function next: pobjectmsestringhashdataty; //wraps to first after last
   function last: pobjectmsestringhashdataty;
   function prev: pobjectmsestringhashdataty; //wraps to last after first
   procedure iterate(const akey: msestring;
                     const aiterator: objectmsestringiteratorprocty); overload;
 end;
 
function scramble(const avalue: hashvaluety): hashvaluety; inline;
function datahash(const data; len: integer): longword; //simple
function datahash2(const data; len: integer): longword;
function stringhash(const key: string): longword; overload;
function stringhash(const key: lstringty): longword; overload;
function stringhash(const key: msestring): longword; overload;
function stringhash(const key: lmsestringty): longword; overload;
function pointerhash(const key: pointer): longword; inline;

procedure addoffs(var dest: hashoffsetarty; const value: hashoffsetty);
 
implementation
uses
 sysutils,msebits;

function scramble(const avalue: hashvaluety): hashvaluety;
begin
 result:= ((avalue xor (avalue shr 8)) xor (avalue shr 16)) xor (avalue shr 24);
end;

function datahash(const data; len: integer): longword;
var
 po1: pbyte;
 int1: integer;
 ca1: longword;
begin
 ca1:= 0;
 po1:= @data;
 for int1:= len - 1 downto 0 do begin
  inc(ca1,po1^);
  inc(po1);
 end;
 result:= ca1;
end;

function datahash2(const data; len: integer): longword;
var
 po1: pbyte;
 int1: integer;
 ca1: longword;
begin
 ca1:= 0;
 po1:= @data;
 for int1:= len - 1 downto 0 do begin
  ca1:= ((ca1 shl 2) or (ca1 shr (sizeof(ca1) * 8 - 2))) xor po1^;
  inc(po1);
 end;
 result:= ca1;
end;

function stringhash(const key: string): longword; overload;
var
 int1: integer;
begin
 result := 0;
 for int1 := 1 to length(key) do begin
  result := ((result shl 2) or (result shr (sizeof(result) * 8 - 2))) xor
                            ord(key[int1]);
 end;
end;

function stringhash(const key: lstringty): longword; overload;
var
 int1: integer;
 po: pcharaty;
begin
 result := 0;
 po:= pointer(key.po);
 for int1:= 0 to key.len - 1 do begin;
  result:= ((result shl 2) or (result shr (sizeof(result) * 8 - 2))) xor
                            ord(po^[int1]);
 end;
end;

function stringhash(const key: msestring): longword; overload;
var
 int1: integer;
begin
 result:= 0;
 for int1 := 1 to length(key) do begin
  result := ((result shl 2) or (result shr (sizeof(result) * 8 - 2))) xor
                            ord(key[int1]);
 end;
end;

function stringhash(const key: lmsestringty): longword; overload;
var
 int1: integer;
 po: pmsecharaty;
begin
 result:= 0;
 po:= pointer(key.po);
 for int1:= 0 to key.len - 1 do begin
  result := ((result shl 2) or (result shr (sizeof(result) * 8 - 2))) xor
                            ord(po^[int1]);
 end;
end;

function pointerhash(const key: pointer): longword; inline;
begin
{$ifdef cpu64}
 result:= scramble((ptruint(key) xor (ptruint(key) shr 32)) xor 
                                                 (ptruint(key) shr 2));
{$else}
 result:= scramble(ptruint(key) xor (ptruint(key) shr 2));
{$endif}
end;

procedure addoffs(var dest: hashoffsetarty; const value: hashoffsetty);
var
 i1: int32;
begin
 i1:= length(dest);
 setlength(dest,i1+1);
 dest[i1]:= value;
end;

{ thashdatalist }

constructor thashdatalist.create();
begin
// fdatasize:= datasize;
// frecsize:= (sizeof(hashheaderty) + datasize + 3) and not 3;
 frecsize:= (getrecordsize() + 3) and not 3;
 inherited create;
end;

destructor thashdatalist.destroy;
begin
 include(fstate,hls_destroying);
 clear;
 inherited;
end;

procedure thashdatalist.moveitem(const aitem: phashdataty);
begin
 move((pointer(aitem)+sizeof(hashheaderty))^,
                     (pointer(fdestpo)+sizeof(hashheaderty))^,
                                          frecsize-sizeof(hashheaderty));
 with fdestpo^.header do begin
  nextlist:= frecsize;
  prevlist:= -frecsize;
  hash:= aitem^.header.hash;
 end;
 inc(pchar(fdestpo),frecsize);
end;

function thashdatalist.getdatapoornil(const aoffset: hashoffsetty): pointer;
begin
 result:= nil;
 if aoffset <> 0 then begin
  result:= fdata+aoffset;
 end;
end;

procedure thashdatalist.setcapacity(const avalue: int32);
var
 int1,int2: integer;
 po1: pointer;
 puint1: hashoffsetty;
begin
 if avalue <> fcapacity then begin
{$ifdef mse_debug_hash}
  checkhash;
{$endif}
  if avalue < fcount then begin
   raise exception.create('Capacity < count.');
  end;
  if avalue >= {high(ptruint)} maxint div frecsize then begin
   raise exception.create('Capacity too big.');
  end;
  
  if (avalue < fcapacity) and (fdeletedroot <> 0) and 
                                    (fcount > 0) then begin //packing necessary
   getmem(po1,(avalue+1)*frecsize);
   if po1 = nil then begin
    raise exception.create('Out of memory.');
   end;
   puint1:= frecsize*fcount;
   if fcount > 0 then begin
    fdestpo:= pointer(pchar(po1) + frecsize);
    internaliterate({$ifdef FPC}@{$endif}moveitem);
    fassignedlast:= puint1;
    fassignedfirst:= frecsize;
   end
   else begin
    fassignedlast:= 0;
    fassignedfirst:= 0;
   end;
   freemem(fdata);
   fdata:= po1;
   phashdataty(fdata+frecsize)^.header.prevlist:= 0; //end marker
   phashdataty(fdata+puint1)^.header.nextlist:= 0; //end marker
   if (hls_needsnull in fstate) and (avalue > fcount) then begin
    fillchar((pchar(fdata)+puint1+frecsize)^,(avalue-fcount)*frecsize,0);
   end;
   fdeletedroot:= 0;
  end
  else begin  
   {$ifdef FPC}
   if reallocmem(fdata,(avalue+1)*frecsize) = nil then begin
    raise exception.create('Out of memory.');
   end;
   {$else}
   reallocmem(fdata,(avalue+1)*frecsize);
  {$endif}
   if (hls_needsnull in fstate) and (avalue > fcapacity) then begin
    fillchar((pchar(fdata)+fcapacity*frecsize+frecsize)^,
                                        (avalue-fcapacity)*frecsize,0);
   end;
  end;
//  phashdataty(fdata)^.header.prevlist:= 0; //end marker
//  phashdataty(fdata)^.header.nextlist:= 0; //end marker
         //first record is a dummy so offset = 0 -> not assigned
  fcapacity:= avalue;
  int2:= highestbit(avalue);
  int1:= bits[int2];
  if int1 < avalue then begin
   int1:= int1 * 2;
   inc(int2);
  end;
  if int1 <> length(fhashtable) then begin
   if fhashtable <> nil then begin
    fillchar(pointer(fhashtable)^,length(fhashtable)*sizeof(fhashtable[0]),0);
   end;
   setlength(fhashtable,int1); //additional length nulled by setlength
   fmask:= int1 - 1;
//   fhashshift:= sizeof(hashvaluety)*8 - int2;
   rehash;
  end;
{$ifdef mse_debug_hash}
  checkhash;
{$endif}
 end; 
end;

procedure thashdatalist.rehash;
var
 puint2: hashoffsetty;
 po1: phashdataty;
 po2: phashoffsetty;
begin
 if fassignedfirst <> 0 then begin
  po1:= pointer(pchar(fdata) + fassignedfirst);
  while true do begin
   if po1^.header.prevhash >= 0 then begin //hash removed otherwise
    po2:= phashoffsetty(pchar(fhashtable) + 
                             (po1^.header.hash and fmask)*sizeof(hashoffsetty));
    puint2:= po2^;
    po1^.header.nexthash:= puint2;
    po1^.header.prevhash:= 0;
    po2^:= pchar(po1) - fdata;
    phashdataty(pchar(fdata)+puint2)^.header.prevhash:= po2^;
   end;
   if po1^.header.nextlist = 0 then begin
    break;
   end;
   inc(pchar(po1),po1^.header.nextlist);
  end;
 end;
{$ifdef mse_debug_hash}
 checkhash;
{$endif}
end;

procedure thashdatalist.grow;
begin
 capacity:= 2*capacity + 256;
end;

function thashdatalist.internaladdhash(hash1: hashvaluety): phashdataty;
var
 puint1,puint2: hashoffsetty;//ptruint;
// hash1: hashvaluety;
begin
{$ifdef mse_debug_hash}
  checkhash;
{$endif}
 if count = capacity then begin
  grow;
 end;
 if fdeletedroot <> 0 then begin
  result:= phashdataty(pchar(fdata)+fdeletedroot);
  inc(fdeletedroot,result^.header.nextlist);
  if result^.header.nextlist = 0 then begin
   fdeletedroot:= 0;
  end;
  if hls_needsnull in fstate then begin
   fillchar((pointer(result)+sizeof(hashheaderty))^,
                                     frecsize-sizeof(hashheaderty),0);
  end;
 end
 else begin
  result:= phashdataty(pchar(fdata) + count * frecsize + frecsize);
 end;
{$ifdef mse_debug_hash}
 checknotexists(result);
{$endif}
 result^.header.prevhash:= 0;
 result^.header.hash:= hash1;
 hash1:= hash1 and fmask;
 puint2:= fhashtable[hash1];
 result^.header.nexthash:= puint2;
 puint1:= pchar(result) - fdata;
 fhashtable[hash1]:= puint1;
 phashdataty(pchar(fdata)+puint2)^.header.prevhash:= puint1;
             //[0] is dummy
 if fcount = 0 then begin
  result^.header.prevlist:= 0;
  fassignedfirst:= puint1;
 end
 else begin
  result^.header.prevlist:= fassignedlast-puint1;
                          //memory offset to next item
  phashdataty(pchar(fdata)+fassignedlast)^.header.nextlist:= 
                                              -result^.header.prevlist;
                          //memory offset to previous item
 end;
 result^.header.nextlist:= 0;
 fassignedlast:= puint1; //new item is last
 inc(fcount);
 if hls_needsinit in fstate then begin
  inititem(result);
 end;
{$ifdef mse_debug_hash}
 checkhash;
{$endif}
end;

function thashdatalist.internaladd(const akey): phashdataty;
begin
 result:= internaladdhash(hashkey(akey));
end;

procedure thashdatalist.inserthash(ahash: hashvaluety;
                                          const adata: phashdataty);
var
 puint1,puint2: hashoffsetty;//ptruint;
begin
 adata^.header.prevhash:= 0;
 adata^.header.hash:= 	ahash;
 ahash:= ahash and fmask;
 puint2:= fhashtable[ahash];
 adata^.header.nexthash:= puint2;
 puint1:= pointer(adata) - fdata;
 fhashtable[ahash]:= puint1;
 phashdataty(fdata+puint2)^.header.prevhash:= puint1;
             //[0] is dummy
end;

procedure thashdatalist.removehash(aitem: phashdataty);
begin
 with aitem^.header do begin
  if nexthash <> 0 then begin
   phashdataty(pchar(fdata)+nexthash)^.header.prevhash:= prevhash;
  end;
  if prevhash <> 0 then begin
   phashdataty(pchar(fdata)+prevhash)^.header.nexthash:= nexthash;
  end
  else begin
   fhashtable[hash and fmask]:= nexthash;
  end;
  prevhash:= -1; //nothashed mrker
 end;
end;

procedure thashdatalist.internaldeleteitem(const aitem: phashdataty);
var
 puint1: hashoffsetty;
 bo1: boolean;
begin
 if aitem <> nil then begin
{$ifdef mse_debug_hash}
  checkexists(aitem);
{$endif}
  if pointer(aitem) = pointer(pchar(fdata) + fcurrentitem) then begin
   fcurrentitem:= 0;
  end;
  if hls_needsfinalize in fstate then begin
   finalizeitem(aitem);
  end;
  puint1:= pchar(aitem) - fdata;
  with aitem^.header do begin
{$ifdef mse_debug_hash}
   if nexthash <> 0 then begin
    checkexists(phashdataty(pchar(fdata)+nexthash));
   end;
   if prevhash <> 0 then begin
    checkexists(phashdataty(pchar(fdata)+prevhash));
   end;
{$endif}
   if nexthash <> 0 then begin
    phashdataty(pchar(fdata)+nexthash)^.header.prevhash:= prevhash;
   end;
   if prevhash <> 0 then begin
    phashdataty(pchar(fdata)+prevhash)^.header.nexthash:= nexthash;
   end
   else begin
    fhashtable[hash and fmask]:= nexthash;
   end;
   bo1:= false;  
   if puint1 <> fassignedfirst then begin //not first
    inc(phashdataty(pchar(aitem)+prevlist)^.header.nextlist,nextlist);
   end
   else begin
    bo1:= true;
    inc(fassignedfirst,nextlist);
    phashdataty(fdata+fassignedfirst)^.header.prevlist:= 0;
   end;
   if puint1 <> fassignedlast then begin //not last
    if not bo1 then begin
     inc(phashdataty(pchar(aitem)+nextlist)^.header.prevlist,prevlist);
    end;
   end
   else begin
    inc(fassignedlast,prevlist);
    phashdataty(fdata+fassignedlast)^.header.nextlist:= 0;
   end;

   if fdeletedroot = 0 then begin
    nextlist:= 0;
   end
   else begin
    nextlist:= fdeletedroot - puint1;
                           //memory offset to next deleted item
   end;
  end;
  fdeletedroot:= puint1;
  dec(fcount);
  if fcount = 0 then begin
   fassignedfirst:= 0;
   fassignedlast:= 0;
  end;
{$ifdef mse_debug_hash}
  checkhash;
{$endif}
 end;
end;

procedure thashdatalist.internaldelete(const aoffset: hashoffsetty);
begin
 internaldeleteitem(fdata+aoffset);
end;

procedure thashdatalist.mark(out ref: hashoffsetty);
begin
 ref:= fassignedlast;
end;

procedure thashdatalist.release(const ref: hashoffsetty);
var
 po1,pend: phashdataty;
begin
 if fassignedlast <> 0 then begin
  pend:= pointer(pchar(fdata)+ref);
  po1:= pointer(pchar(fdata)+fassignedlast);
  while po1 <> pend do begin
   internaldeleteitem(po1);
   if po1^.header.prevlist = 0 then begin
    break;
   end;
   inc(pchar(po1),po1^.header.prevlist);
  end;
 end;
end;

function thashdatalist.absdata(const ref: ptrint): pointer; 
                   //returns pointer to hashdataty.data from mark(ref)
begin
 result:= fdata + ref + sizeof(hashheaderty);
end;
{
procedure thashdatalist.internaldeleteitem(const aitem: phashdatadataty);
begin
 if aitem <> nil then begin
  internaldeleteitem(phashdataty(pchar(aitem)-sizeof(hashheaderty)));
 end;
end;
}
function thashdatalist.internaldelete(const akey; const all: boolean): boolean;
var
 po1: phashdataty;
begin
 result:= false;
 while true do begin
  po1:= internalfind(akey);
  if po1 = nil then begin
   break;
  end;
  internaldeleteitem(po1);
  result:= true;
  if not all then begin
   break;
  end;
 end;
end;

procedure thashdatalist.clear;
begin
 if fdata <> nil then begin
  if hls_needsfinalize in fstate then begin
   iterate({$ifdef FPC}@{$endif}finalizeitem);
  end;
  freemem(fdata);
  fdata:= nil;
  fhashtable:= nil;
  fcount:= 0;
  fcapacity:= 0;
  fassignedfirst:= 0; //dummy item
  fassignedlast:= 0; //dummy item
  fdeletedroot:= 0;  //dummy item
 end;
end;

procedure thashdatalist.reset;
begin
 fcurrentitem:= 0;
end;

procedure thashdatalist.iterate(const aiterator: hashiteratorprocty);
var
 puint1: hashoffsetty;
 po1: phashdataty;
begin
 if fcount > 0 then begin
  po1:= pointer(pchar(fdata) + fassignedfirst);
  while true do begin
   puint1:= phashheaderty(po1)^.nextlist;
   aiterator(po1);
   if puint1 = 0 then begin
    break;
   end;
   inc(pchar(po1),puint1);
  end;
 end;
end;

procedure thashdatalist.iterate(const akey;
                                        const aiterator: keyhashiteratorprocty);
var
 ha1: hashvaluety;
 uint1: hashoffsetty;
 po1: phashdataty;
begin
 po1:= nil;
 if count > 0 then begin
  ha1:= hashkey(akey);
  uint1:= fhashtable[ha1 and fmask];
  if uint1 <> 0 then begin
   po1:= phashdataty(pchar(fdata) + uint1);
   while true do begin
    if (po1^.header.hash = ha1) and checkkey(akey,po1) then begin
     aiterator(po1);
    end;
    if po1^.header.nexthash = 0 then begin
     break;
    end;
    po1:= phashdataty(pchar(fdata) + po1^.header.nexthash);
   end;
  end;
 end;
end;

procedure thashdatalist.internaliterate(
                                const aiterator: internalhashiteratorprocty);
var
 po1: phashdataty;
begin
 if fcount > 0 then begin
  po1:= pointer(pchar(fdata) + fassignedfirst);
  while true do begin
   aiterator(po1);
   if phashheaderty(po1)^.nextlist = 0 then begin
    break;
   end;
   inc(pchar(po1),phashheaderty(po1)^.nextlist);
  end;
 end;
end;

procedure thashdatalist.inititem(const aitem: phashdataty);
begin
 //dummy
end;

procedure thashdatalist.finalizeitem(const aitem: phashdataty);
begin
 //dummy
end;

function thashdatalist.internalfind(const akey; 
                                         hash1: hashvaluety): phashdataty;
var
// ha1: hashvaluety;
 uint1: hashoffsetty;
 po1: phashdataty;
begin
{$ifdef mse_debug_hash}
 checkhash;
{$endif}
 po1:= nil;
 if count > 0 then begin
//  ha1:= hashkey(akey);
  uint1:= fhashtable[hash1 and fmask];
  if uint1 <> 0 then begin
   po1:= phashdataty(pchar(fdata) + uint1);
   while true do begin
    if (po1^.header.hash = hash1) and checkkey(akey,po1) then begin
     break;
    end;
    if po1^.header.nexthash = 0 then begin
     po1:= nil;
     break;
    end;
    po1:= phashdataty(pchar(fdata) + po1^.header.nexthash);
   end;
  end;
 end;
 result:= po1;
end;

function thashdatalist.internalfind(const akey): phashdataty;
begin
 result:= internalfind(akey,hashkey(akey));
end;

function thashdatalist.internalfind(const akey; out acount: integer): phashdataty;
var
 ha1: hashvaluety;
 uint1: hashoffsetty;
 po1: phashdataty;
begin
 result:= nil;
 acount:= 0;
 if count > 0 then begin
  ha1:= hashkey(akey);
  uint1:= fhashtable[ha1 and fmask];
  if uint1 <> 0 then begin
   po1:= phashdataty(pchar(fdata) + uint1);
   while true do begin
    if (po1^.header.hash = ha1) and checkkey(akey,po1) then begin
     if result = nil then begin
      result:= po1;
     end;
     inc(acount);
    end
    else begin
     if result <> nil then begin
      break;
     end;
    end;
    if po1^.header.nexthash = 0 then begin
     break;
    end;
    po1:= phashdataty(pchar(fdata) + po1^.header.nexthash);
   end;
  end;
 end;
end;

function thashdatalist.internalfind(const akey; 
                             const acheckproc: findcheckprocty): phashdataty;
var
 ha1: hashvaluety;
 uint1: hashoffsetty;
 po1: phashdataty;
 bo1: boolean;
begin
 po1:= nil;
 if count > 0 then begin
  ha1:= hashkey(akey);
  uint1:= fhashtable[ha1 and fmask];
  if uint1 <> 0 then begin
   po1:= phashdataty(pchar(fdata) + uint1);
   bo1:= false;
   while true do begin
    if (po1^.header.hash = ha1) and checkkey(akey,po1) then begin
     acheckproc(po1,bo1);
     if bo1 then begin
      break;
     end;
    end;
    if po1^.header.nexthash = 0 then begin
     po1:= nil;
     break;
    end;
    po1:= phashdataty(pchar(fdata) + po1^.header.nexthash);
   end;
  end;
 end;
 result:= po1;
end;

function thashdatalist.internalfind(const akey; 
                             const acheckproc: findcheckprocty;
                             out acount: integer): phashdataty;
var
 ha1: hashvaluety;
 uint1: hashoffsetty;
 po1: phashdataty;
 bo1: boolean;
begin
 result:= nil;
 acount:= 0;
 if count > 0 then begin
  ha1:= hashkey(akey);
  uint1:= fhashtable[ha1 and fmask];
  if uint1 <> 0 then begin
   po1:= phashdataty(pchar(fdata) + uint1);
   bo1:= false;
   while true do begin
    if (po1^.header.hash = ha1) and checkkey(akey,po1) then begin
     acheckproc(po1,bo1);
     if bo1 then begin
      if result = nil then begin
       result:= po1;
      end;
      inc(acount);
     end
     else begin
      if result <> nil then begin
       break;
      end;
     end;
    end;
    if po1^.header.nexthash = 0 then begin
     break;
    end;
    po1:= phashdataty(pchar(fdata) + po1^.header.nexthash);
   end;
  end;
 end;
end;

function thashdatalist.internalfindexact(const akey): phashdataty;
begin
 result:= internalfind(akey,{$ifdef FPC}@{$endif}checkexact);
end;

function thashdatalist.internalfindexact(const akey;
                                        out acount: integer): phashdataty;
begin
 result:= internalfind(akey,{$ifdef FPC}@{$endif}checkexact,acount);
end;

function thashdatalist.internalfirstx: phashdataty;
begin
 result:= nil;
 if count > 0 then begin
  fcurrentitem:= fassignedfirst;
  result:= fdata + fcurrentitem;
 end;
end;

function thashdatalist.internallastx: phashdataty;
begin
 result:= nil;
 if count > 0 then begin
  fcurrentitem:= fassignedlast;
  result:= fdata + fcurrentitem;
 end;
end;

function thashdatalist.internalnextx: phashdataty;
var
 po1: phashdataty;
begin
 result:= nil;
 if count > 0 then begin
  po1:= phashdataty(fdata + fcurrentitem);
  if (fcurrentitem = 0) or (po1^.header.nextlist = 0) then begin
   fcurrentitem:= fassignedfirst;
  end
  else begin
   fcurrentitem:= fcurrentitem + po1^.header.nextlist;
  end;
  result:= fdata + fcurrentitem;
 end;
end;

function thashdatalist.internalprevx: phashdataty;
var
 po1: phashdataty;
begin
 result:= nil;
 if count > 0 then begin
  po1:= phashdataty(fdata + fcurrentitem);
  if (fcurrentitem = 0) or (po1^.header.prevlist = 0) then begin
   fcurrentitem:= fassignedlast;
  end
  else begin
   fcurrentitem:= fcurrentitem + po1^.header.prevlist;
  end;
  result:= fdata + fcurrentitem;
 end;
end;

procedure thashdatalist.checkexact(const aitem: phashdataty;
                                                     var accept: boolean);
begin
 accept:= false; //dummy
end;

function thashdatalist.getdatapo(const aoffset: hashoffsetty): pointer; inline;
begin
 result:= pchar(fdata)+aoffset;
end;

function thashdatalist.getdataoffs(const adata: pointer): hashoffsetty; inline;
begin
 result:= pchar(adata)-pchar(fdata);
end;

{$ifdef mse_debug_hash}
procedure thashdatalist.checkhash;
var
 int1,int2,int3: integer;
 po1,po2: phashdataty;
 uint1: hashoffsetty;
begin
 if (fmask <> 0) and (fhashtable <> nil) then begin
  int3:= 0;
  for int1:= 0 to fmask do begin
   uint1:= fhashtable[int1];
   if uint1 <> 0 then begin
    inc(int3);
    po1:= phashdataty(pchar(fdata) + uint1);
    if po1^.header.prevhash <> 0 then begin
     raise exception.create('prevhash is not 0.');
    end;
    int2:= 0;
    while po1^.header.nexthash <> 0 do begin
     po2:= po1;
     po1:= phashdataty(pchar(fdata) + po1^.header.nexthash);
     if phashdataty(pchar(fdata)+po1^.header.prevhash) <> po2 then begin
      raise exception.create('Wrong hash backlink.');
     end;
     inc(int2);
     inc(int3);
     if int2 > count then begin
      raise exception.create('Hash loop.');
     end;
    end;
   end;
  end;
  if int3 <> count then begin
   raise exception.create('Wrong hash count.');
  end;
 end;
 if (fassignedfirst <> 0) or (fassignedlast <> 0) then begin
  if (fassignedfirst = 0) then begin
   raise exception.create('fassignedfirst 0.');
  end;
  if (fassignedlast = 0) then begin
   raise exception.create('fassignedlast 0.');
  end;
   
  int1:= 0;
  po1:= fdata + fassignedfirst;
  if po1^.header.prevlist <> 0 then begin
   raise exception.create('fprevlist not 0.');
  end;
  while true do begin
   inc(int1);
   if int1 > fcount then begin
    raise exception.create('Forward List loop.');
   end;
   if po1^.header.nextlist = 0 then begin
    break;
   end;
   po1:= pointer(po1) + po1^.header.nextlist;
  end;
  if int1 <> count then begin
   raise exception.create('Wrong forward list count.');
  end;
  int1:= 0;
  po1:= fdata + fassignedlast;
  if po1^.header.nextlist <> 0 then begin
   raise exception.create('fnextlist not 0.');
  end;
  while true do begin
   inc(int1);
   if int1 > fcount then begin
    raise exception.create('Backward List loop.');
   end;
   if po1^.header.prevlist = 0 then begin
    break;
   end;
   po1:= pointer(po1) + po1^.header.prevlist;
  end;
  if int1 <> count then begin
   raise exception.create('Wrong backward list count.');
  end;
 end
 else begin
  if fcount <> 0 then begin
   raise exception.create('Wrong count.');
  end;
 end;
 int1:= 0;
 if fdeletedroot <> 0 then begin
  po1:= fdata + fdeletedroot;
  while true do begin
   inc(int1);
   if int1 > fcapacity-fcount then begin
    raise exception.create('Deleted List loop.');
   end;
   if po1^.header.nextlist = 0 then begin
    break;
   end;
   po1:= pointer(po1) + po1^.header.nextlist;
  end;
 end;
end;

procedure thashdatalist.checkexists(const aitem: phashdataty);
var
 int1: integer;
 po1: phashdataty;
 uint1: hashoffsetty;
begin
 checkhash;
 if fmask <> 0 then begin
  for int1:= 0 to fmask do begin
   uint1:= fhashtable[int1];
   if uint1 <> 0 then begin
    po1:= phashdataty(pchar(fdata) + uint1);
    if po1 = aitem then begin
     exit;
    end;
    while po1^.header.nexthash <> 0 do begin
     po1:= phashdataty(pchar(fdata) + po1^.header.nexthash);
     if po1 = aitem then begin
      exit;
     end;
    end;
   end;
  end;
  raise exception.create('Hash item does not exist.');
 end;
end;

procedure thashdatalist.checknotexists(const aitem: phashdataty);
var
 int1: integer;
 po1: phashdataty;
 uint1: hashoffsetty;
begin
 checkhash;
 if fmask <> 0 then begin
  for int1:= 0 to fmask do begin
   uint1:= fhashtable[int1];
   if uint1 <> 0 then begin
    po1:= phashdataty(pchar(fdata) + uint1);
    if po1 = aitem then begin
     raise exception.create('Hash item does exist.');
    end;
    while po1^.header.nexthash <> 0 do begin
     po1:= phashdataty(pchar(fdata) + po1^.header.nexthash);
     if po1 = aitem then begin
      raise exception.create('Hash item does exist.');
     end;
    end;
   end;
  end;
 end;
end;

{$endif}

{ tintegerhasdatalist }
{
constructor tintegerhashdatalist.create();
begin
 inherited create(datasize + sizeof(integerhashdataty)-sizeof(hashdataty));
end;
}
function tintegerhashdatalist.hashkey(const akey): hashvaluety;
// todo: optimize
begin
 result:= scramble((integer(akey) xor (integer(akey) shr 2)));
end;

function tintegerhashdatalist.add(const akey: integer): pintegerhashdataty;
begin
 result:= pintegerhashdataty(internaladd(akey));
 result^.data.key:= akey;
end;

function tintegerhashdatalist.find(const akey: integer): pintegerhashdataty;
begin
 result:= pintegerhashdataty(internalfind(akey));
end;

function tintegerhashdatalist.addunique(const akey: integer): pintegerhashdataty;
begin
 result:= find(akey);
 if result = nil then begin
  result:= add(akey);
 end;
end;

function tintegerhashdatalist.addunique(const akey: integer; 
                                       out adata: pintegerhashdataty): boolean;
                                             //true if new
begin
 adata:= find(akey);
 result:= false;
 if adata = nil then begin
  adata:= add(akey);
  result:= true;
 end;
end;

function tintegerhashdatalist.checkkey(const akey;
                                 const aitem: phashdataty): boolean;
begin
 result:= integer(akey) = pintegerhashdataty(aitem)^.data.key;
end;

function tintegerhashdatalist.getrecordsize(): int32;
begin
 result:= sizeof(integerhashdataty);
end;

function tintegerhashdatalist.first: pintegerhashdataty;
begin
 result:= pintegerhashdataty(internalfirstx);
end;

function tintegerhashdatalist.next: pintegerhashdataty;
begin
 result:= pintegerhashdataty(internalnextx);
end;

function tintegerhashdatalist.last: pintegerhashdataty;
begin
 result:= pintegerhashdataty(internallastx);
end;

function tintegerhashdatalist.prev: pintegerhashdataty;
begin
 result:= pintegerhashdataty(internalprevx);
end;

function tintegerhashdatalist.delete(const akey: integer;
               const all: boolean = false): boolean;
begin
 result:= internaldelete(akey,all);
end;

{ tdoubleintegerhashdatalist }

function mdikey(a,b: integer): doubleintegerty; inline;
begin
 result.a:= a;
 result.b:= b;
end;
{
constructor tdoubleintegerhashdatalist.create(const datasize: integer);
begin
 inherited create(datasize + sizeof(doubleintegerdataty));
end;
}
function tdoubleintegerhashdatalist.hashkey(const akey): hashvaluety;
var
 i1: int32;
begin
 with doubleintegerty(akey) do begin
  i1:= a + b;
 end;
 result:= scramble((integer(i1) xor (integer(i1) shr 2)));
end;

function tdoubleintegerhashdatalist.checkkey(const akey;
               const aitem: phashdataty): boolean;
begin
 with doubleintegerty(akey) do begin
  result:= (a = pdoubleintegerhashdataty(aitem)^.data.key.a) and
                 (b = pdoubleintegerhashdataty(aitem)^.data.key.b);
 end;
end;

function tdoubleintegerhashdatalist.getrecordsize(): int32;
begin
 result:= sizeof(doubleintegerhashdataty);
end;

function tdoubleintegerhashdatalist.add(
                      const akeya,akeyb: integer): pdoubleintegerhashdataty;
var
 k1: doubleintegerty;
begin
 k1.a:= akeya;
 k1.b:= akeyb;
 result:= pdoubleintegerhashdataty(internaladd(k1));
 result^.data.key:= k1;
end;

function tdoubleintegerhashdatalist.find(
                      const akeya,akeyb: integer): pdoubleintegerhashdataty;
begin
 result:= pdoubleintegerhashdataty(internalfind(mdikey(akeya,akeyb)));
end;

function tdoubleintegerhashdatalist.addunique(
                          const akeya,akeyb: integer): pdoubleintegerhashdataty;
begin
 result:= find(akeya,akeyb);
 if result = nil then begin
  result:= add(akeya,akeyb);
 end;
end;

function tdoubleintegerhashdatalist.addunique(const akeya,akeyb: integer; 
                                 out adata: pdoubleintegerhashdataty): boolean;
begin
 adata:= find(akeya,akeyb);
 result:= false;
 if adata = nil then begin
  adata:= add(akeya,akeyb);
  result:= true;
 end;
end;

function tdoubleintegerhashdatalist.first: pdoubleintegerhashdataty;
begin
 result:= pdoubleintegerhashdataty(internalfirstx);
end;

function tdoubleintegerhashdatalist.next: pdoubleintegerhashdataty;
begin
 result:= pdoubleintegerhashdataty(internalnextx);
end;

function tdoubleintegerhashdatalist.last: pdoubleintegerhashdataty;
begin
 result:= pdoubleintegerhashdataty(internallastx);
end;

function tdoubleintegerhashdatalist.prev: pdoubleintegerhashdataty;
begin
 result:= pdoubleintegerhashdataty(internalprevx);
end;

function tdoubleintegerhashdatalist.delete(const akeya,akeyb: integer; 
                                         const all: boolean = false): boolean;
begin
 result:= internaldelete(mdikey(akeya,akeyb),all);
end;

{ tpointerhashdatalist }
{
constructor tpointerhashdatalist.create(const datasize: integer);
begin
 inherited create(datasize + sizeof(pointerdataty));
end;
}
function tpointerhashdatalist.hashkey(const akey): hashvaluety;
begin
 result:= pointerhash(pointer(akey));
end;

function tpointerhashdatalist.checkkey(const akey;
                                    const aitem: phashdataty): boolean;
begin
 result:= pointer(akey) = ppointerhashdataty(aitem)^.data.key;
end;

function tpointerhashdatalist.getrecordsize(): int32;
begin
 result:= sizeof(pointerhashdataty);
end;

function tpointerhashdatalist.add(const akey: pointer): ppointerhashdataty;
begin
 result:= ppointerhashdataty(internaladd(akey));
 result^.data.key:= akey;
end;

function tpointerhashdatalist.addunique(
                               const akey: pointer): ppointerhashdataty;
begin
 result:= find(akey);
 if result = nil then begin
  result:= add(akey);
 end;
end;

function tpointerhashdatalist.find(const akey: pointer): ppointerhashdataty;
begin
 result:= ppointerhashdataty(internalfind(akey));
end;

function tpointerhashdatalist.delete(const akey: pointer;
               const all: boolean = false): boolean;
begin
 result:= internaldelete(akey,all);
end;

function tpointerhashdatalist.first: ppointerhashdataty;
begin
 result:= ppointerhashdataty(internalfirstx);
end;

function tpointerhashdatalist.next: ppointerhashdataty;
begin
 result:= ppointerhashdataty(internalnextx);
end;

function tpointerhashdatalist.last: ppointerhashdataty;
begin
 result:= ppointerhashdataty(internallastx);
end;

function tpointerhashdatalist.prev: ppointerhashdataty;
begin
 result:= ppointerhashdataty(internalprevx);
end;

{ tptruinthasdatalist }
{
constructor tptruinthashdatalist.create(const datasize: integer);
begin
 inherited create(datasize + sizeof(ptruintdataty));
end;
}
function tptruinthashdatalist.hashkey(const akey): hashvaluety;
// todo: optimize
begin
 result:= pointerhash(pointer(akey));
// result:= scramble(ptruint(akey) xor (ptruint(akey) shr 2));
end;

function tptruinthashdatalist.add(const akey: ptruint): pptruinthashdataty;
begin
 result:= pptruinthashdataty(internaladd(akey));
 result^.data.key:= akey;
end;

function tptruinthashdatalist.find(const akey: ptruint): pptruinthashdataty;
begin
 result:= pptruinthashdataty(internalfind(akey));
end;

function tptruinthashdatalist.addunique(
                        const akey: ptruint): pptruinthashdataty;
begin
 result:= find(akey);
 if result = nil then begin
  result:= add(akey);
 end;
end;

function tptruinthashdatalist.checkkey(const akey;
                                  const aitem: phashdataty): boolean;
begin
 result:= ptruint(akey) = pptruinthashdataty(aitem)^.data.key;
end;

function tptruinthashdatalist.getrecordsize(): int32;
begin
 result:= sizeof(ptruinthashdataty);
end;

function tptruinthashdatalist.first: pptruinthashdataty;
begin
 result:= pptruinthashdataty(internalfirstx);
end;

function tptruinthashdatalist.next: pptruinthashdataty;
begin
 result:= pptruinthashdataty(internalnextx);
end;

function tptruinthashdatalist.last: pptruinthashdataty;
begin
 result:= pptruinthashdataty(internallastx);
end;

function tptruinthashdatalist.prev: pptruinthashdataty;
begin
 result:= pptruinthashdataty(internalprevx);
end;

function tptruinthashdatalist.delete(const akey: ptruint;
               const all: boolean = false): boolean;
begin
 result:= internaldelete(akey,all);
end;

{ tpointerptruinthashdatalist }
{
constructor tpointerptruinthashdatalist.create;
begin
 inherited create(sizeof(pointer));
end;
}
procedure tpointerptruinthashdatalist.add(const akey: ptruint;
                                       const avalue: pointer);
begin
 ppointerptruinthashdataty(inherited add(akey))^.data.data:= avalue;
end;

function tpointerptruinthashdatalist.find(const akey: ptruint;
                                            out avalue: pointer): boolean;
var
 po1: ppointerptruinthashdataty;
begin
 po1:= ppointerptruinthashdataty(inherited find(akey));
 result:= po1 <> nil;
 if result then begin
  avalue:= po1^.data.data;
 end
 else begin
  avalue:= nil;
 end;
end;

function tpointerptruinthashdatalist.addunique(const akey: ptruint;
                                               const avalue: pointer): boolean;
var
 po1: ppointerptruinthashdataty;
begin
 result:= true;
 po1:= ppointerptruinthashdataty(inherited find(akey));
 if po1 = nil then begin
  result:= false;
  po1:= ppointerptruinthashdataty(inherited add(akey));
  po1^.data.data:= avalue;
 end;
end;

procedure tpointerptruinthashdatalist.checkexact(
          const aitem: phashdataty; var accept: boolean);
begin
 accept:= ppointerptruinthashdataty(aitem)^.data.data = fpointerparam;
end;

function tpointerptruinthashdatalist.getrecordsize(): int32;
begin
 result:= sizeof(pointerptruinthashdataty);
end;

procedure tpointerptruinthashdatalist.delete(const akey: ptruint;
               const avalue: pointer);
//var
// po1: phashdataty;
begin
 fpointerparam:= avalue;
 internaldeleteitem(internalfindexact(akey));
end;

function tpointerptruinthashdatalist.find(const akey: ptruint): pointer;
begin
 find(akey,result);
end;

function tpointerptruinthashdatalist.first: ppointerptruinthashdataty;
begin
 result:= ppointerptruinthashdataty(internalfirstx);
end;

function tpointerptruinthashdatalist.next: ppointerptruinthashdataty;
begin
 result:= ppointerptruinthashdataty(internalnextx);
end;

function tpointerptruinthashdatalist.last: ppointerptruinthashdataty;
begin
 result:= ppointerptruinthashdataty(internallastx);
end;

function tpointerptruinthashdatalist.prev: ppointerptruinthashdataty;
begin
 result:= ppointerptruinthashdataty(internalprevx);
end;

procedure tpointerptruinthashdatalist.iterate(const akey: ptruint;
               const aiterator: pointerptruintiteratorprocty);
begin
 iterate(akey,keyhashiteratorprocty(aiterator));
end;

{ tansistringptruinthashdatalist }

constructor tansistringptruinthashdatalist.create;
begin
 inherited create();
 fstate:= fstate + [hls_needsnull,hls_needsfinalize];
end;

procedure tansistringptruinthashdatalist.add(const akey: ptruint;
                                       const avalue: ansistring);
begin
 pansistringptruinthashdataty(inherited add(akey))^.data.data:= avalue;
end;

function tansistringptruinthashdatalist.find(const akey: ptruint;
                                             out avalue: ansistring): boolean;
var
 po1: pansistringptruinthashdataty;
begin
 po1:= pansistringptruinthashdataty(inherited find(akey));
 result:= po1 <> nil;
 if result then begin
  avalue:= po1^.data.data;
 end
 else begin
  avalue:= '';
 end;
end;

function tansistringptruinthashdatalist.addunique(const akey: ptruint;
                                               const avalue: ansistring): boolean;
var
 po1: pansistringptruinthashdataty;
begin
 result:= true;
 po1:= pansistringptruinthashdataty(inherited find(akey));
 if po1 = nil then begin
  result:= false;
  po1:= pansistringptruinthashdataty(inherited add(akey));
  po1^.data.data:= avalue;
 end;
end;

procedure tansistringptruinthashdatalist.checkexact(
          const aitem: phashdataty; var accept: boolean);
begin
 accept:= pansistringptruinthashdataty(aitem)^.data.data = fansistringparam;
end;

procedure tansistringptruinthashdatalist.delete(const akey: ptruint;
               const avalue: ansistring);
//var
// po1: phashdataty;
begin
 fansistringparam:= avalue;
 internaldeleteitem(internalfindexact(akey));
end;

function tansistringptruinthashdatalist.find(const akey: ptruint): ansistring;
begin
 find(akey,result);
end;

function tansistringptruinthashdatalist.first: pansistringptruinthashdataty;
begin
 result:= pansistringptruinthashdataty(internalfirstx);
end;

function tansistringptruinthashdatalist.next: pansistringptruinthashdataty;
begin
 result:= pansistringptruinthashdataty(internalnextx);
end;

function tansistringptruinthashdatalist.last: pansistringptruinthashdataty;
begin
 result:= pansistringptruinthashdataty(internallastx);
end;

function tansistringptruinthashdatalist.prev: pansistringptruinthashdataty;
begin
 result:= pansistringptruinthashdataty(internalprevx);
end;

procedure tansistringptruinthashdatalist.iterate(const akey: ptruint;
               const aiterator: ansistringptruintiteratorprocty);
begin
 iterate(akey,keyhashiteratorprocty(aiterator));
end;

procedure tansistringptruinthashdatalist.finalizeitem(const aitem: phashdataty);
begin
 finalize(pansistringptruinthashdataty(aitem)^.data);
end;

function tansistringptruinthashdatalist.getrecordsize(): int32;
begin
 result:= sizeof(ansistringptruinthashdataty);
end;

function tansistringptruinthashdatalist.setdata(const akey: ptruint;
                                        const avalue: ansistring): boolean;
var
 po1: pansistringptruinthashdataty;
begin
 po1:= pansistringptruinthashdataty(inherited find(akey));
 result:= po1 <> nil;
 if result then begin
  po1^.data.data:= avalue;
 end;
end;

{ tmsestringptruinthashdatalist }

constructor tmsestringptruinthashdatalist.create;
begin
 inherited create();
 fstate:= fstate + [hls_needsnull,hls_needsfinalize];
end;

procedure tmsestringptruinthashdatalist.add(const akey: ptruint;
                                       const avalue: msestring);
begin
 pmsestringptruinthashdataty(inherited add(akey))^.data.data:= avalue;
end;

function tmsestringptruinthashdatalist.find(const akey: ptruint;
                                             out avalue: msestring): boolean;
var
 po1: pmsestringptruinthashdataty;
begin
 po1:= pmsestringptruinthashdataty(inherited find(akey));
 result:= po1 <> nil;
 if result then begin
  avalue:= po1^.data.data;
 end
 else begin
  avalue:= '';
 end;
end;

function tmsestringptruinthashdatalist.addunique(const akey: ptruint;
                                               const avalue: msestring): boolean;
var
 po1: pmsestringptruinthashdataty;
begin
 result:= true;
 po1:= pmsestringptruinthashdataty(inherited find(akey));
 if po1 = nil then begin
  result:= false;
  po1:= pmsestringptruinthashdataty(inherited add(akey));
  po1^.data.data:= avalue;
 end;
end;

procedure tmsestringptruinthashdatalist.checkexact(const aitem: phashdataty;
               var accept: boolean);
begin
 accept:= pmsestringptruinthashdataty(aitem)^.data.data = fmsestringparam;
end;

procedure tmsestringptruinthashdatalist.delete(const akey: ptruint;
               const avalue: msestring);
//var
// po1: phashdataty;
begin
 fmsestringparam:= avalue;
 internaldeleteitem(internalfindexact(akey));
end;

function tmsestringptruinthashdatalist.find(const akey: ptruint): msestring;
begin
 find(akey,result);
end;

function tmsestringptruinthashdatalist.first: pmsestringptruinthashdataty;
begin
 result:= pmsestringptruinthashdataty(internalfirstx);
end;

function tmsestringptruinthashdatalist.next: pmsestringptruinthashdataty;
begin
 result:= pmsestringptruinthashdataty(internalnextx);
end;

function tmsestringptruinthashdatalist.last: pmsestringptruinthashdataty;
begin
 result:= pmsestringptruinthashdataty(internallastx);
end;

function tmsestringptruinthashdatalist.prev: pmsestringptruinthashdataty;
begin
 result:= pmsestringptruinthashdataty(internalprevx);
end;

procedure tmsestringptruinthashdatalist.iterate(const akey: ptruint;
               const aiterator: msestringptruintiteratorprocty);
begin
 iterate(akey,keyhashiteratorprocty(aiterator));
end;

procedure tmsestringptruinthashdatalist.finalizeitem(const aitem: phashdataty);
begin
 finalize(pmsestringptruinthashdataty(aitem)^.data);
end;

function tmsestringptruinthashdatalist.getrecordsize(): int32;
begin
 result:= sizeof(msestringptruinthashdataty);
end;

function tmsestringptruinthashdatalist.setdata(const akey: ptruint;
               const avalue: msestring): boolean;
var
 po1: pmsestringptruinthashdataty;
begin
 po1:= pmsestringptruinthashdataty(inherited find(akey));
 result:= po1 <> nil;
 if result then begin
  po1^.data.data:= avalue;
 end;
end;

{ tansistringhashdatalist }

constructor tansistringhashdatalist.create();
begin
 inherited create();
 fstate:= fstate + [hls_needsnull,hls_needsfinalize];
end;

procedure tansistringhashdatalist.finalizeitem(const aitem: phashdataty);
begin
 finalize(pansistringhashdataty(aitem)^.data);
end;

function tansistringhashdatalist.getrecordsize(): int32;
begin
 result:= sizeof(ansistringhashdataty);
end;

function tansistringhashdatalist.add(
                       const akey: ansistring): pansistringhashdataty;
begin
 result:= pansistringhashdataty(internaladd(akey));
 result^.data.key:= akey;
end;

function tansistringhashdatalist.find(
                               const akey: ansistring): pansistringhashdataty;
begin
 result:= pansistringhashdataty(internalfind(akey));
end;

function tansistringhashdatalist.find(
                              const akey: lstringty): pansistringhashdataty;
var
 ha1: hashvaluety;
 uint1: hashoffsetty;
 po1: phashdataty;
begin
 po1:= nil;
 if count > 0 then begin
  ha1:= hashlkey(akey);
  uint1:= fhashtable[ha1 and fmask];
  if uint1 <> 0 then begin
   po1:= phashdataty(pchar(fdata) + uint1);
   while true do begin
    if (po1^.header.hash = ha1) and checklkey(akey,
                          pansistringhashdataty(po1)^.data) then begin
     break;
    end;
    if po1^.header.nexthash = 0 then begin
     po1:= nil;
     break;
    end;
    po1:= phashdataty(pchar(fdata) + po1^.header.nexthash);
   end;
  end;
 end;
 result:= pansistringhashdataty(po1);
end;

function tansistringhashdatalist.addunique(
                        const akey: ansistring): pansistringhashdataty;
begin
 result:= find(akey);
 if result = nil then begin
  result:= add(akey);
 end;
end;

function tansistringhashdatalist.hashkey(const akey): hashvaluety;
begin
 result:= stringhash(ansistring(akey));
end;

function tansistringhashdatalist.hashlkey(const akey: lstringty): hashvaluety;
begin
 result:= stringhash(akey);
end;

function tansistringhashdatalist.checkkey(const akey;
                                   const aitem: phashdataty): boolean;
var
 int1: integer;
begin
 result:= pointer(akey) = pointer(pansistringhashdataty(aitem)^.data.key);
 if not result then begin
  int1:= length(ansistring(akey));
  result:= (int1 = length(pansistringhashdataty(aitem)^.data.key)) and
      comparemem(pointer(akey),
                    pointer(pansistringhashdataty(aitem)^.data.key),int1);
 end;
end;

function tansistringhashdatalist.checklkey(const akey: lstringty;
                             const aitemdata: ansistringdataty): boolean;
begin
 result:= (akey.len = length(aitemdata.key)) and
      comparemem(akey.po,pointer(aitemdata.key),akey.len);
end;

function tansistringhashdatalist.delete(const akey: ansistring;
               const all: boolean = false): boolean;
begin
 result:= internaldelete(akey,all);
end;

function tansistringhashdatalist.delete(const akey: lstringty;
               const all: boolean = false): boolean;
var
 str1: string;
begin
 str1:= lstringtostring(akey);
 result:= internaldelete(str1,all);
end;

function tansistringhashdatalist.first: pansistringhashdataty;
begin
 result:= pansistringhashdataty(internalfirstx);
end;

function tansistringhashdatalist.next: pansistringhashdataty;
begin
 result:= pansistringhashdataty(internalnextx);
end;

function tansistringhashdatalist.last: pansistringhashdataty;
begin
 result:= pansistringhashdataty(internallastx);
end;

function tansistringhashdatalist.prev: pansistringhashdataty;
begin
 result:= pansistringhashdataty(internalprevx);
end;

procedure tansistringhashdatalist.iterate(const akey: ansistring;
               const aiterator: ansistringhashiteratorprocty);
begin
 iterate(akey,keyhashiteratorprocty(aiterator));
end;

{ tpointeransistringhashdatalist }
{
constructor tpointeransistringhashdatalist.create;
begin
 inherited create(sizeof(pointer));
end;
}
procedure tpointeransistringhashdatalist.add(const akey: ansistring;
                                       const avalue: pointer);
begin
 ppointeransistringhashdataty(inherited add(akey))^.data.data:= avalue;
end;

procedure tpointeransistringhashdatalist.add(const keys: array of string;
                   startindex: pointer = pointer($00000001));
var
 ca1: longword;
begin
 for ca1:= 0 to high(keys) do begin
  add(keys[ca1],pointer(ca1+ptruint(startindex)));
 end;
end;

function tpointeransistringhashdatalist.find(const akey: ansistring;
                                             out avalue: pointer): boolean;
var
 po1: ppointeransistringhashdataty;
begin
 po1:= ppointeransistringhashdataty(inherited find(akey));
 result:= po1 <> nil;
 if result then begin
  avalue:= po1^.data.data;
 end
 else begin
  avalue:= nil;
 end;
end;

function tpointeransistringhashdatalist.find(const akey: lstringty): pointer;
begin
 result:= inherited find(akey);
 if result <> nil then begin
  result:= ppointeransistringhashdataty(result)^.data.data;
 end;
end;

function tpointeransistringhashdatalist.addunique(const akey: ansistring;
                                               const avalue: pointer): boolean;
var
 po1: ppointeransistringhashdataty;
begin
 result:= true;
 po1:= ppointeransistringhashdataty(inherited find(akey));
 if po1 = nil then begin
  result:= false;
  po1:= ppointeransistringhashdataty(inherited add(akey));
  po1^.data.data:= avalue;
 end;
end;

procedure tpointeransistringhashdatalist.checkexact(const aitem: phashdataty;
               var accept: boolean);
begin
 accept:= ppointeransistringhashdataty(aitem)^.data.data = fpointerparam;
end;

function tpointeransistringhashdatalist.getrecordsize(): int32;
begin
 result:= sizeof(pointeransistringhashdataty);
end;

procedure tpointeransistringhashdatalist.delete(const akey: ansistring;
               const avalue: pointer);
//var
// po1: phashdataty;
begin
 fpointerparam:= avalue;
 internaldeleteitem(internalfindexact(akey));
end;

function tpointeransistringhashdatalist.find(const akey: ansistring): pointer;
begin
 find(akey,result);
end;

function tpointeransistringhashdatalist.first: ppointeransistringhashdataty;
begin
 result:= ppointeransistringhashdataty(internalfirstx);
end;

function tpointeransistringhashdatalist.next: ppointeransistringhashdataty;
begin
 result:= ppointeransistringhashdataty(internalnextx);
end;

function tpointeransistringhashdatalist.last: ppointeransistringhashdataty;
begin
 result:= ppointeransistringhashdataty(internallastx);
end;

function tpointeransistringhashdatalist.prev: ppointeransistringhashdataty;
begin
 result:= ppointeransistringhashdataty(internalprevx);
end;

procedure tpointeransistringhashdatalist.iterate(const akey: ansistring;
               const aiterator: pointeransistringiteratorprocty);
begin
 iterate(akey,keyhashiteratorprocty(aiterator));
end;

{ tmsestringhashdatalist }

constructor tmsestringhashdatalist.create();
begin
 inherited create();
 fstate:= fstate + [hls_needsnull,hls_needsfinalize];
end;

procedure tmsestringhashdatalist.finalizeitem(
                                         const aitem: phashdataty);
begin
 finalize(pmsestringhashdataty(aitem)^.data);
end;

function tmsestringhashdatalist.getrecordsize(): int32;
begin
 result:= sizeof(msestringhashdataty);
end;

function tmsestringhashdatalist.add(
                      const akey: msestring): pmsestringhashdataty;
begin
 result:= pmsestringhashdataty(internaladd(akey));
 result^.data.key:= akey;
end;

function tmsestringhashdatalist.find(
                             const akey: msestring): pmsestringhashdataty;
begin
 result:= pmsestringhashdataty(internalfind(akey));
end;

function tmsestringhashdatalist.find(
                     const akey: lmsestringty): pmsestringhashdataty;
var
 ha1: hashvaluety;
 uint1: hashoffsetty;
 po1: phashdataty;
begin
 po1:= nil;
 if count > 0 then begin
  ha1:= hashlkey(akey);
  uint1:= fhashtable[ha1 and fmask];
  if uint1 <> 0 then begin
   po1:= phashdataty(pchar(fdata) + uint1);
   while true do begin
    if (po1^.header.hash = ha1) and checklkey(akey,
                             pmsestringhashdataty(po1)^.data) then begin
     break;
    end;
    if po1^.header.nexthash = 0 then begin
     po1:= nil;
     break;
    end;
    po1:= phashdataty(pchar(fdata) + po1^.header.nexthash);
   end;
  end;
 end;
 result:= pmsestringhashdataty(po1);
end;

function tmsestringhashdatalist.find(const akey: msestring;
                                out acount: integer): pmsestringhashdataty;
begin
 result:= pmsestringhashdataty(internalfind(akey,acount));
end;

function tmsestringhashdatalist.addunique(
                           const akey: msestring): pmsestringhashdataty;
begin
 result:= find(akey);
 if result = nil then begin
  result:= add(akey);
 end;
end;

function tmsestringhashdatalist.hashkey(const akey): hashvaluety;
begin
 result:= stringhash(msestring(akey));
end;

function tmsestringhashdatalist.hashlkey(const akey: lmsestringty): hashvaluety;
begin
 result:= stringhash(akey);
end;

function tmsestringhashdatalist.checklkey(const akey: lmsestringty;
                              const aitemdata: msestringdataty): boolean;
begin
 result:= (akey.len = length(aitemdata.key)) and
      comparemem(akey.po,pointer(aitemdata.key),
                                               akey.len*sizeof(msechar));
end;

function tmsestringhashdatalist.checkkey(const akey;
                                 const aitem: phashdataty): boolean;
var
 int1: integer;
begin
 result:= pointer(akey) = pointer(pmsestringhashdataty(aitem)^.data.key);
 if not result then begin
  int1:= length(msestring(akey));
  result:= (int1 = length(pmsestringhashdataty(aitem)^.data.key)) and
      comparemem(pointer(akey),pointer(pmsestringhashdataty(aitem)^.data.key),
                               int1*sizeof(msechar));
 end;
// result:= msestring(akey) = msestringdataty(aitemdata).key;
end;

function tmsestringhashdatalist.delete(const akey: msestring;
               const all: boolean = false): boolean;
begin
 result:= internaldelete(akey,all);
end;

function tmsestringhashdatalist.delete(const akey: lmsestringty;
               const all: boolean = false): boolean;
var
 mstr1: msestring;
begin
 mstr1:= lstringtostring(akey);
 result:= internaldelete(mstr1,all);
end;

function tmsestringhashdatalist.first: pmsestringhashdataty;
begin
 result:= pmsestringhashdataty(internalfirstx);
end;

function tmsestringhashdatalist.next: pmsestringhashdataty;
begin
 result:= pmsestringhashdataty(internalnextx);
end;

function tmsestringhashdatalist.last: pmsestringhashdataty;
begin
 result:= pmsestringhashdataty(internallastx);
end;

function tmsestringhashdatalist.prev: pmsestringhashdataty;
begin
 result:= pmsestringhashdataty(internalprevx);
end;

procedure tmsestringhashdatalist.iterate(const akey: msestring;
               const aiterator: msestringiteratorprocty);
begin
 iterate(akey,keyhashiteratorprocty(aiterator));
end;

{ tpointermsestringhashdatalist }
{
constructor tpointermsestringhashdatalist.create;
begin
 inherited create(sizeof(pointermsestringhashdataty) - 
                                      sizeof(msestringhashdataty));
end;
}
procedure tpointermsestringhashdatalist.add(const akey: msestring;
                                       const avalue: pointer);
begin
 ppointermsestringhashdataty(inherited add(akey))^.data.data:= avalue;
end;

function tpointermsestringhashdatalist.find(const akey: msestring;
                                             out avalue: pointer): boolean;
var
 po1: ppointermsestringhashdataty;
begin
 po1:= ppointermsestringhashdataty(inherited find(akey));
 result:= po1 <> nil;
 if result then begin
  avalue:= po1^.data.data;
 end
 else begin
  avalue:= nil;
 end;
end;

function tpointermsestringhashdatalist.find(const akey: msestring;
                        out avalue: pointer; out acount: integer): boolean;
var
 po1: ppointermsestringhashdataty;
begin
 po1:= ppointermsestringhashdataty(internalfind(akey,acount));
 result:= po1 <> nil;
 if result then begin
  avalue:= po1^.data.data;
 end
 else begin
  avalue:= nil;
 end;
end;

function tpointermsestringhashdatalist.find(const akey: lmsestringty): pointer;
begin
 result:= inherited find(akey);
 if result <> nil then begin
  result:= ppointermsestringhashdataty(result)^.data.data;
 end;
end;

function tpointermsestringhashdatalist.find(const akey: msestring): pointer;
begin
 find(akey,result);
end;

procedure tpointermsestringhashdatalist.delete(const akey: msestring;
               const avalue: pointer);
//var
// po1: phashdataty;
begin
 fpointerparam:= avalue;
 internaldeleteitem(internalfindexact(akey));
end;

function tpointermsestringhashdatalist.addunique(const akey: msestring;
                                               const avalue: pointer): boolean;
var
 po1: ppointermsestringhashdataty;
begin
 result:= true;
 po1:= ppointermsestringhashdataty(inherited find(akey));
 if po1 = nil then begin
  result:= false;
  po1:= ppointermsestringhashdataty(inherited add(akey));
  po1^.data.data:= avalue;
 end;
end;

procedure tpointermsestringhashdatalist.checkexact(
                      const aitem: phashdataty; var accept: boolean);
begin
 accept:= ppointermsestringhashdataty(aitem)^.data.data = fpointerparam;
end;

function tpointermsestringhashdatalist.getrecordsize(): int32;
begin
 result:= sizeof(pointermsestringhashdataty);
end;

function tpointermsestringhashdatalist.first: ppointermsestringhashdataty;
begin
 result:= ppointermsestringhashdataty(internalfirstx);
end;

function tpointermsestringhashdatalist.next: ppointermsestringhashdataty;
begin
 result:= ppointermsestringhashdataty(internalnextx);
end;

function tpointermsestringhashdatalist.last: ppointermsestringhashdataty;
begin
 result:= ppointermsestringhashdataty(internallastx);
end;

function tpointermsestringhashdatalist.prev: ppointermsestringhashdataty;
begin
 result:= ppointermsestringhashdataty(internalprevx);
end;

procedure tpointermsestringhashdatalist.iterate(const akey: msestring;
               const aiterator: pointermsestringiteratorprocty);
begin
 iterate(akey,keyhashiteratorprocty(aiterator));
end;

{ tintegermsestringhashdatalist }
{
constructor tintegermsestringhashdatalist.create;
begin
 inherited create(sizeof(integer));
end;
}
procedure tintegermsestringhashdatalist.add(const akey: msestring;
                                       const avalue: integer);
begin
 pintegermsestringhashdataty(inherited add(akey))^.data.data:= avalue;
end;

function tintegermsestringhashdatalist.find(const akey: msestring;
                                             out avalue: integer): boolean;
var
 po1: pintegermsestringhashdataty;
begin
 po1:= pintegermsestringhashdataty(inherited find(akey));
 result:= po1 <> nil;
 if result then begin
  avalue:= po1^.data.data;
 end
 else begin
  avalue:= -1;
 end;
end;

function tintegermsestringhashdatalist.find(const akey: msestring;
                        out avalue: integer; out acount: integer): boolean;
var
 po1: pintegermsestringhashdataty;
begin
 po1:= pintegermsestringhashdataty(inherited find(akey,acount));
 result:= po1 <> nil;
 if result then begin
  avalue:= po1^.data.data;
 end
 else begin
  avalue:= -1;
 end;
end;

function tintegermsestringhashdatalist.find(const akey: lmsestringty): integer;
var
 po1: pintegermsestringhashdataty;
begin
 po1:= pintegermsestringhashdataty(inherited find(akey));
 if po1 <> nil then begin
  result:= po1^.data.data;
 end
 else begin
  result:= -1;
 end;
end;

function tintegermsestringhashdatalist.find(const akey: msestring): integer;
begin
 find(akey,result);
end;

procedure tintegermsestringhashdatalist.delete(const akey: msestring;
               const avalue: integer);
//var
// po1: phashdataty;
begin
 fintegerparam:= avalue;
 internaldeleteitem(internalfindexact(akey));
end;

function tintegermsestringhashdatalist.addunique(const akey: msestring;
                                               const avalue: integer): boolean;
var
 po1: pintegermsestringhashdataty;
begin
 result:= true;
 po1:= pintegermsestringhashdataty(inherited find(akey));
 if po1 = nil then begin
  result:= false;
  po1:= pintegermsestringhashdataty(inherited add(akey));
  po1^.data.data:= avalue;
 end;
end;

procedure tintegermsestringhashdatalist.checkexact(const aitem: phashdataty;
               var accept: boolean);
begin
 accept:= pintegermsestringhashdataty(aitem)^.data.data = fintegerparam;
end;

function tintegermsestringhashdatalist.getrecordsize(): int32;
begin
 result:= sizeof(integermsestringhashdataty);
end;

function tintegermsestringhashdatalist.first: pintegermsestringhashdataty;
begin
 result:= pintegermsestringhashdataty(internalfirstx);
end;

function tintegermsestringhashdatalist.next: pintegermsestringhashdataty;
begin
 result:= pintegermsestringhashdataty(internalnextx);
end;

function tintegermsestringhashdatalist.last: pintegermsestringhashdataty;
begin
 result:= pintegermsestringhashdataty(internallastx);
end;

function tintegermsestringhashdatalist.prev: pintegermsestringhashdataty;
begin
 result:= pintegermsestringhashdataty(internalprevx);
end;

procedure tintegermsestringhashdatalist.iterate(const akey: msestring;
               const aiterator: integermsestringiteratorprocty);
begin
 iterate(akey,keyhashiteratorprocty(aiterator));
end;

{ tobjectmsestringhashdatalist }

constructor tobjectmsestringhashdatalist.create(const aownsobjects: boolean = true);
begin
 fownsobjects:= aownsobjects;
 inherited create;
end;

procedure tobjectmsestringhashdatalist.add(const akey: msestring;
               const avalue: tobject);
begin
 inherited add(akey,avalue);
end;

function tobjectmsestringhashdatalist.addunique(const akey: msestring;
               const avalue: tobject): boolean;
begin
 result:= inherited addunique(akey,avalue);
end;

procedure tobjectmsestringhashdatalist.delete(const akey: msestring;
               const avalue: tobject);
begin
 inherited delete(akey,avalue);
end;

function tobjectmsestringhashdatalist.find(const akey: msestring): tobject;
begin
 result:= tobject(inherited find(akey));
end;

function tobjectmsestringhashdatalist.find(const akey: msestring;
               out avalue: tobject): boolean;
begin
 result:= inherited find(akey,pointer(avalue));
end;

function tobjectmsestringhashdatalist.find(const akey: msestring;
               out avalue: tobject; out acount: integer): boolean;
begin
 result:= inherited find(akey,pointer(avalue),acount);
end;

function tobjectmsestringhashdatalist.first: pobjectmsestringhashdataty;
begin
 result:= pobjectmsestringhashdataty(internalfirstx);
end;

function tobjectmsestringhashdatalist.next: pobjectmsestringhashdataty;
begin
 result:= pobjectmsestringhashdataty(internalnextx);
end;

function tobjectmsestringhashdatalist.last: pobjectmsestringhashdataty;
begin
 result:= pobjectmsestringhashdataty(internallastx);
end;

function tobjectmsestringhashdatalist.prev: pobjectmsestringhashdataty;
begin
 result:= pobjectmsestringhashdataty(internalprevx);
end;

procedure tobjectmsestringhashdatalist.iterate(const akey: msestring;
               const aiterator: objectmsestringiteratorprocty);
begin
 inherited iterate(akey,pointermsestringiteratorprocty(aiterator));
end;

procedure tobjectmsestringhashdatalist.finalizeitem(const aitem: phashdataty);
begin
 inherited;
 if fownsobjects then begin
  with pobjectmsestringhashdataty(aitem)^.data do begin
   data.free;
  end;
 end;
end;

end.
