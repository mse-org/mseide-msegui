{ MSEgui Copyright (c) 1999-2011 by Martin Schreiber

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
 
type
 hashvaluety = longword;
 phashvaluety = ^hashvaluety;

 hashheaderty = record
  prevhash: ptruint; //offset from liststart
  nexthash: ptruint; //offset from liststart
  prevlist: ptruint; //-memory offset to previous item
  nextlist: ptruint; //memory offset to next item
  hash: hashvaluety;
 end;
 phashheaderty = ^hashheaderty;

 hashdatadataty = record
 end;
 phashdatadataty = ^hashdatadataty;
  
 hashdataty = record
  header: hashheaderty;
  data: hashdatadataty;
 end;
 phashdataty = ^hashdataty;

 hashiteratorprocty = procedure(var aitemdata) of object;
 internalhashiteratorprocty = procedure(const aitem: phashdataty) of object;
 keyhashiteratorprocty = procedure(var aitemdata) of object; 
                                       //hashdatadataty
 findcheckprocty = procedure(const aitemdata; var accept: boolean) of object;

 hashliststatety = (hls_needsnull,hls_needsfinalize);
 hashliststatesty = set of hashliststatety;

 thashdatalist = class
  private
   fmask: hashvaluety;
//   fhashshift: integer;
   fdatasize: integer;
   frecsize: integer;
   fcapacity: integer;
   fcount: integer;
   fhashtable: ptruintarty;
   fdata: pointer;         //first record is a dummy
   fassignedroot: ptruint; //offset to fdata
   fdeletedroot: ptruint;  //offset to fdata
   fcurrentitem: ptruint;  //offset to fdata.data
   fdestpo: phashdataty;
   procedure setcapacity(const avalue: integer);
   procedure moveitem(const aitem: phashdataty);
  protected
   fstate: hashliststatesty;
   function getdatapo(const aoffset: longword): pointer;
   function getdataoffset(const adata: pointer): longword;
   function internaladd(const akey): phashdataty;
   procedure internaldeleteitem(const aitem: phashdataty); overload;
   procedure internaldeleteitem(const aitem: phashdatadataty); overload;
   function internaldelete(const akey; const all: boolean): boolean;
   function internalfind(const akey): phashdataty; overload;
   function internalfind(const akey; out acount: integer): phashdataty; overload;
   function internalfind(const akey;
               const acheckproc: findcheckprocty): phashdataty; overload;
   function internalfind(const akey;
               const acheckproc: findcheckprocty;
               out acount: integer): phashdataty; overload;
   function internalfindexact(const akey): phashdataty; overload;
   function internalfindexact(const akey;
                           out acount: integer): phashdataty; overload;
   procedure checkexact(const aitemdata; var accept: boolean); virtual;
   function scramble(const avalue: hashvaluety): hashvaluety; inline;
   function hashkey(const akey): hashvaluety; virtual; abstract;
   function checkkey(const akey; const aitemdata): boolean; virtual; abstract;
   procedure rehash;
   procedure grow;
   procedure finalizeitem(var aitemdata); virtual;
   procedure internaliterate(
                       const aiterator: internalhashiteratorprocty); overload;
   procedure iterate(const akey; 
                            const aiterator: keyhashiteratorprocty); overload;
   function internalfirst: phashdatadataty;
   function internalnext: phashdatadataty;
  public
   constructor create(const datasize: integer);
   destructor destroy; override;
   procedure clear;{ virtual;}
   procedure reset; //net next will return first
   property capacity: integer read fcapacity write setcapacity;
   property count: integer read fcount;
   procedure iterate(const aiterator: hashiteratorprocty); overload;
 end;
 
 integerdataty = record
  key: integer;
  data: record end;
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
   function checkkey(const akey; const aitemdata): boolean; override;
  public
   constructor create(const datasize: integer);
   function add(const akey: integer): pointer;
   function addunique(const akey: integer): pointer;
   function find(const akey: integer): pointer;
   function delete(const akey: integer; 
                         const all: boolean = false): boolean; overload;
                         //true if found
   function first: pintegerdataty;
   function next: pintegerdataty;
 end;

 ptruintdataty = record
  key: ptruint;
  data: record end;
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
   function checkkey(const akey; const aitemdata): boolean; override;
  public
   constructor create(const datasize: integer);
   function add(const akey: ptruint): pointer;
   function addunique(const akey: ptruint): pointer;
   function find(const akey: ptruint): pointer;
   function delete(const akey: ptruint; 
                         const all: boolean = false): boolean; overload;
                         //true if found
   function first: pptruintdataty;
   function next: pptruintdataty;
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
                     procedure(var aitem: pointerptruintdataty) of object;

 tpointerptruinthashdatalist = class(tptruinthashdatalist)
  private
   fpointerparam: pointer;
  protected
   procedure checkexact(const aitemdata; var accept: boolean); override;
  public
   constructor create;
   procedure add(const akey: ptruint; const avalue: pointer);
   function addunique(const akey: ptruint; const avalue: pointer): boolean;
                   //true if found
   procedure delete(const akey: ptruint; const avalue: pointer);
   function find(const akey: ptruint): pointer; overload;
   function find(const akey: ptruint; out avalue: pointer): boolean; overload;
   function first: ppointerptruintdataty;
   function next: ppointerptruintdataty;
   procedure iterate(const akey: ptruint;
                     const aiterator: pointerptruintiteratorprocty); overload;
 end;
 
 ansistringdataty = record
  key: ansistring;
  data: record end;
 end;
 pansistringdataty = ^ansistringdataty;
 ansistringhashdataty = record
  header: hashheaderty;
  data: ansistringdataty;
 end;
 pansistringhashdataty = ^ansistringhashdataty;
 
 ansistringhashiteratorprocty = procedure(var aitem: ansistringdataty) of object;

 tansistringhashdatalist = class(thashdatalist)
  private
  protected
   function hashkey(const akey): hashvaluety; override;
   function checkkey(const akey; const aitemdata): boolean; override;
   function hashlkey(const akey: lstringty): hashvaluety;
   function checklkey(const akey: lstringty; const aitemdata): boolean;
   procedure finalizeitem(var aitemdata); override;
  public
   constructor create(const datasize: integer);
   function add(const akey: ansistring): pointer; 
            //returns pointer on ansistringdataty.data
   function addunique(const akey: ansistring): pointer;
   function find(const akey: ansistring): pointer;
   function find(const akey: lstringty): pointer;
   function delete(const akey: ansistring; 
                         const all: boolean = false): boolean; overload;
                         //true if found
   function delete(const akey: lstringty; 
                         const all: boolean = false): boolean; overload;
                         //true if found
   function first: pansistringdataty;
   function next: pansistringdataty;
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
                     procedure(var aitem: pointeransistringdataty) of object;

 tpointeransistringhashdatalist = class(tansistringhashdatalist)
  private
   fpointerparam: pointer;
  protected
   procedure checkexact(const aitemdata; var accept: boolean); override;
  public
   constructor create;
   procedure add(const akey: ansistring; const avalue: pointer); overload;
   procedure add(const keys: array of string;
                   startindex: pointer = pointer($00000001)); overload;
                             //data = arrayindex + startindex
   function addunique(const akey: ansistring; const avalue: pointer): boolean;
                   //true if found
   procedure delete(const akey: ansistring; const avalue: pointer); overload;
   function find(const akey: ansistring): pointer; overload;
   function find(const akey: ansistring; out avalue: pointer): boolean; overload;
   function first: ppointeransistringdataty;
   function next: ppointeransistringdataty;
   procedure iterate(const akey: ansistring;
                     const aiterator: pointeransistringiteratorprocty); overload;
 end;

 msestringdataty = record
  key: msestring;
  data: record end;
 end;
 pmsestringdataty = ^msestringdataty;
 msestringhashdataty = record
  header: hashheaderty;
  data: msestringdataty;
 end;
 pmsestringhashdataty = ^msestringhashdataty;
 
 msestringiteratorprocty = procedure(var aitem: msestringdataty) of object;

 tmsestringhashdatalist = class(thashdatalist)
  private
  protected
   function hashkey(const akey): hashvaluety; override;
   function checkkey(const akey; const aitemdata): boolean; override;
   function hashlkey(const akey: lmsestringty): hashvaluety;
   function checklkey(const akey: lmsestringty; const aitemdata): boolean;
   procedure finalizeitem(var aitemdata); override;
  public
   constructor create(const datasize: integer);
   function add(const akey: msestring): pointer;
                 //returns pointer on msestringdataty.data
   function addunique(const akey: msestring): pointer;
   function find(const akey: msestring): pointer; overload;
   function find(const akey: lmsestringty): pointer; overload;
   function find(const akey: msestring; out acount: integer): pointer; overload;
   function delete(const akey: msestring; 
                         const all: boolean = false): boolean; overload;
                                      //true if found
   function delete(const akey: lmsestringty; 
                         const all: boolean = false): boolean; overload;
                                      //true if found
   function first: pmsestringdataty;
   function next: pmsestringdataty; //wraps to first after last
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
                       procedure(var aitem: pointermsestringdataty) of object;

 tpointermsestringhashdatalist = class(tmsestringhashdatalist)
  private
   fpointerparam: pointer;
  protected
   procedure checkexact(const aitemdata; var accept: boolean); override;
  public
   constructor create;
   procedure add(const akey: msestring; const avalue: pointer);
   function addunique(const akey: msestring; const avalue: pointer): boolean;
                   //true if found
   procedure delete(const akey: msestring; const avalue: pointer);
   function find(const akey: msestring): pointer; overload;
   function find(const akey: msestring; out avalue: pointer): boolean; overload;
   function find(const akey: msestring; out avalue: pointer;
                                        out acount: integer): boolean; overload;
   function first: ppointermsestringdataty;
   function next: ppointermsestringdataty;
   procedure iterate(const akey: msestring;
                     const aiterator: pointermsestringiteratorprocty); overload;
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
                       procedure(var aitem: objectmsestringdataty) of object;

 tobjectmsestringhashdatalist = class(tpointermsestringhashdatalist)
  protected
   procedure finalizeitem(var aitemdata); override;
  public
   procedure add(const akey: msestring; const avalue: tobject);
   function addunique(const akey: msestring; const avalue: tobject): boolean;
                   //true if found
   procedure delete(const akey: msestring; const avalue: tobject);
   function find(const akey: msestring): tobject; overload;
   function find(const akey: msestring; out avalue: tobject): boolean; overload;
   function find(const akey: msestring; out avalue: tobject;
                                        out acount: integer): boolean; overload;
   function first: pobjectmsestringdataty;
   function next: pobjectmsestringdataty;
   procedure iterate(const akey: msestring;
                     const aiterator: objectmsestringiteratorprocty); overload;
 end;
 
function datahash(const data; len: integer): longword; //simple
function datahash2(const data; len: integer): longword;
function stringhash(const key: string): longword; overload;
function stringhash(const key: lstringty): longword; overload;
function stringhash(const key: msestring): longword; overload;
function stringhash(const key: lmsestringty): longword; overload;
 
implementation
uses
 sysutils,msebits;

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

{ thashdatalist }

constructor thashdatalist.create(const datasize: integer);
begin
 fdatasize:= datasize;
 frecsize:= sizeof(hashheaderty) + 
              ((datasize + 3) and not 3) + fdatasize; //round up to 4 byte
 inherited create;
end;

destructor thashdatalist.destroy;
begin
 clear;
 inherited;
end;

procedure thashdatalist.moveitem(const aitem: phashdataty);
begin
 move(aitem^.data,fdestpo^.data,frecsize-sizeof(hashheaderty));
 with fdestpo^.header do begin
  nextlist:= 0-ptruint(frecsize);
  prevlist:= nextlist;
  hash:= aitem^.header.hash;
 end;
 dec(pchar(fdestpo),frecsize);
end;

procedure thashdatalist.setcapacity(const avalue: integer);
var
 int1,int2: integer;
 po1: pointer;
 puint1: ptruint;
begin
 if avalue <> fcapacity then begin
  if avalue < fcount then begin
   raise exception.create('Capacity < count.');
  end;
  if longword(avalue) >= {high(ptruint)}
                       high(longword) div longword(frecsize) then begin
   raise exception.create('Capacity too big.');
  end;
  
  if (avalue < fcapacity) and (fdeletedroot <> 0) and 
                                    (fcount > 0) then begin //packing necessary
   getmem(po1,(avalue+1)*frecsize);
   if po1 = nil then begin
    raise exception.create('Out of memory.');
   end;
   puint1:= frecsize*fcount;
   fdestpo:= pointer(pchar(po1) + puint1);
   internaliterate({$ifdef FPC}@{$endif}moveitem);
   freemem(fdata);
   fdata:= po1;
   if (hls_needsnull in fstate) and (avalue > fcount) then begin
    fillchar((pchar(fdata)+puint1+frecsize)^,(avalue-fcount)*frecsize,0);
   end;
   fdeletedroot:= 0;
   fassignedroot:= puint1;
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
  phashdataty(fdata)^.header.nextlist:= 0; //end marker
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
 end; 
end;

procedure thashdatalist.rehash;
var
 puint1,puint2: ptruint;
 po1: phashdataty;
 po2: phashvaluety;
begin
 po1:= pointer(pchar(fdata) + fassignedroot);
 while true do begin
  puint1:= po1^.header.nextlist;
  if puint1 = 0 then begin
   break;
  end;
  po2:= phashvaluety(pchar(fhashtable) + 
                       (po1^.header.hash and fmask)*sizeof(hashvaluety));
  puint2:= po2^;
  po1^.header.nexthash:= puint2;
  po2^:= pchar(po1) - fdata;
  phashdataty(pchar(fdata)+puint2)^.header.prevhash:= po2^;
  inc(pchar(po1),puint1);
 end;
end;

procedure thashdatalist.grow;
begin
 capacity:= 2*capacity + 256;
end;

function thashdatalist.internaladd(const akey): phashdataty;
var
 puint1,puint2: ptruint;
 hash1: hashvaluety;
begin
 if count = capacity then begin
  grow;
 end;
 if fdeletedroot <> 0 then begin
  result:= phashdataty(pchar(fdata)+fdeletedroot);
  inc(fdeletedroot,result^.header.nextlist);
  if hls_needsnull in fstate then begin
   fillchar(result^.data,frecsize-sizeof(hashheaderty),0);
  end;
 end
 else begin
  result:= phashdataty(pchar(fdata) + count * frecsize + frecsize);
 end;
 result^.header.prevhash:= 0;
 hash1:= hashkey(akey);
 result^.header.hash:= hash1;
 hash1:= hash1 and fmask;
 puint2:= fhashtable[hash1];
 result^.header.nexthash:= puint2;
 puint1:= pchar(result) - fdata;
 fhashtable[hash1]:= puint1;
 phashdataty(pchar(fdata)+puint2)^.header.prevhash:= puint1;
 inc(fcount);
 result^.header.nextlist:= fassignedroot - puint1;
                         //memory offset to next item
 phashdataty(pchar(fdata)+fassignedroot)^.header.prevlist:= 
                                             result^.header.nextlist;
                         //-memory offset to previous item
 fassignedroot:= puint1; //new item is root
end;

procedure thashdatalist.internaldeleteitem(const aitem: phashdataty);
var
 puint1: ptruint;
begin
 if aitem <> nil then begin
  if pointer(aitem) = pointer(pchar(fdata) + fcurrentitem) then begin
   fcurrentitem:= 0;
  end;
  if hls_needsfinalize in fstate then begin
   finalizeitem(aitem^.data);
  end;
  puint1:= pchar(aitem) - fdata;
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
  
   if puint1 <> fassignedroot then begin //not root
    inc(phashdataty(pchar(aitem)-prevlist)^.header.nextlist,nextlist);
    inc(phashdataty(pchar(aitem)+nextlist)^.header.prevlist,prevlist);
   end
   else begin
    inc(fassignedroot,nextlist);
   end;
   nextlist:= fdeletedroot - puint1;
                           //memory offset to next item
  end;
  fdeletedroot:= puint1;
  dec(fcount);
 end;
end;

procedure thashdatalist.internaldeleteitem(const aitem: phashdatadataty);
begin
 if aitem <> nil then begin
  internaldeleteitem(phashdataty(pchar(aitem)-sizeof(hashheaderty)));
 end;
end;

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
  fassignedroot:= 0; //dummy item
  fdeletedroot:= 0;  //dummy item
 end;
end;

procedure thashdatalist.reset;
begin
 fcurrentitem:= 0;
end;

procedure thashdatalist.iterate(const aiterator: hashiteratorprocty);
var
 puint1: ptruint;
 po1: phashdataty;
begin
 if fcount > 0 then begin
  po1:= pointer(pchar(fdata) + fassignedroot);
  while true do begin
   puint1:= phashheaderty(po1)^.nextlist;
   if puint1 = 0 then begin
    break;
   end;
   aiterator(pointer(pchar(po1)+sizeof(hashheaderty))^);
   inc(pchar(po1),puint1);
  end;
 end;
end;

procedure thashdatalist.iterate(const akey;
                                        const aiterator: keyhashiteratorprocty);
var
 ha1: hashvaluety;
 uint1: ptruint;
 po1: phashdataty;
begin
 po1:= nil;
 if count > 0 then begin
  ha1:= hashkey(akey);
  uint1:= fhashtable[ha1 and fmask];
  if uint1 <> 0 then begin
   po1:= phashdataty(pchar(fdata) + uint1);
   while true do begin
    if (po1^.header.hash = ha1) and checkkey(akey,po1^.data) then begin
     aiterator(pointer(@po1^.data)^);
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
 puint1: ptruint;
 po1: phashdataty;
begin
 if fcount > 0 then begin
  po1:= pointer(pchar(fdata) + fassignedroot);
  while true do begin
   puint1:= phashheaderty(po1)^.nextlist;
   if puint1 = 0 then begin
    break;
   end;
   aiterator(po1);
   inc(pchar(po1),puint1);
  end;
 end;
end;

procedure thashdatalist.finalizeitem(var aitemdata);
begin
 //dummy
end;

function thashdatalist.internalfind(const akey): phashdataty;
var
 ha1: hashvaluety;
 uint1: ptruint;
 po1: phashdataty;
begin
 po1:= nil;
 if count > 0 then begin
  ha1:= hashkey(akey);
  uint1:= fhashtable[ha1 and fmask];
  if uint1 <> 0 then begin
   po1:= phashdataty(pchar(fdata) + uint1);
   while true do begin
    if (po1^.header.hash = ha1) and checkkey(akey,po1^.data) then begin
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

function thashdatalist.internalfind(const akey; out acount: integer): phashdataty;
var
 ha1: hashvaluety;
 uint1: ptruint;
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
    if (po1^.header.hash = ha1) and checkkey(akey,po1^.data) then begin
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
 uint1: ptruint;
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
    if (po1^.header.hash = ha1) and checkkey(akey,po1^.data) then begin
     acheckproc(pointer(@po1^.data)^,bo1);
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
 uint1: ptruint;
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
    if (po1^.header.hash = ha1) and checkkey(akey,po1^.data) then begin
     acheckproc(pointer(@po1^.data)^,bo1);
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

function thashdatalist.internalfirst: phashdatadataty;
begin
 result:= nil;
 if count > 0 then begin
  fcurrentitem:= fassignedroot;
  result:= phashdatadataty(pchar(fdata) + fcurrentitem + sizeof(hashheaderty));
 end;
end;

function thashdatalist.internalnext: phashdatadataty;
begin
 result:= nil;
 if count > 0 then begin
  if fcurrentitem = 0 then begin
   fcurrentitem:= fassignedroot;
  end
  else begin
   inc(fcurrentitem,phashdataty(pchar(fdata) + fcurrentitem)^.header.nextlist);
   if fcurrentitem = 0 then begin
    fcurrentitem:= fassignedroot;
   end;
  end;
  result:= phashdatadataty(pchar(fdata) + fcurrentitem + sizeof(hashheaderty));
 end;
end;

procedure thashdatalist.checkexact(const aitemdata; var accept: boolean);
begin
 accept:= false; //dummy
end;

function thashdatalist.getdatapo(const aoffset: longword): pointer;
begin
 result:= pchar(fdata)+aoffset;
end;

function thashdatalist.getdataoffset(const adata: pointer): longword;
begin
 result:= pchar(adata)-pchar(fdata);
end;

function thashdatalist.scramble(const avalue: hashvaluety): hashvaluety;
begin
 result:= ((avalue xor (avalue shr 8)) xor (avalue shr 16)) xor (avalue shr 24);
end;

{ tintegerhasdatalist }

constructor tintegerhashdatalist.create(const datasize: integer);
begin
 inherited create(datasize + sizeof(integerdataty));
end;

function tintegerhashdatalist.hashkey(const akey): hashvaluety;
// todo: optimize
begin
 result:= scramble((integer(akey) xor (integer(akey) shr 2)));
end;

function tintegerhashdatalist.add(const akey: integer): pointer;
var
 po1: pintegerhashdataty;
begin
 po1:= pintegerhashdataty(internaladd(akey));
 po1^.data.key:= akey;
 result:= @po1^.data.data;
end;

function tintegerhashdatalist.find(const akey: integer): pointer;
begin
 result:= internalfind(akey);
 if result <> nil then begin
  result:= @pintegerhashdataty(result)^.data.data;
 end;
end;

function tintegerhashdatalist.addunique(const akey: integer): pointer;
begin
 result:= find(akey);
 if result = nil then begin
  result:= add(akey);
 end;
end;

function tintegerhashdatalist.checkkey(const akey; const aitemdata): boolean;
begin
 result:= integer(akey) = integerdataty(aitemdata).key;
end;

function tintegerhashdatalist.first: pintegerdataty;
begin
 result:= pintegerdataty(internalfirst);
end;

function tintegerhashdatalist.next: pintegerdataty;
begin
 result:= pintegerdataty(internalnext);
end;

function tintegerhashdatalist.delete(const akey: integer;
               const all: boolean = false): boolean;
begin
 result:= internaldelete(akey,all);
end;

{ tptruinthasdatalist }

constructor tptruinthashdatalist.create(const datasize: integer);
begin
 inherited create(datasize + sizeof(ptruintdataty));
end;

function tptruinthashdatalist.hashkey(const akey): hashvaluety;
// todo: optimize
begin
 result:= scramble(ptruint(akey) xor (ptruint(akey) shr 2));
end;

function tptruinthashdatalist.add(const akey: ptruint): pointer;
var
 po1: pptruinthashdataty;
begin
 po1:= pptruinthashdataty(internaladd(akey));
 po1^.data.key:= akey;
 result:= @po1^.data.data;
end;

function tptruinthashdatalist.find(const akey: ptruint): pointer;
begin
 result:= internalfind(akey);
 if result <> nil then begin
  result:= @pptruinthashdataty(result)^.data.data;
 end;
end;

function tptruinthashdatalist.addunique(const akey: ptruint): pointer;
begin
 result:= find(akey);
 if result = nil then begin
  result:= add(akey);
 end;
end;

function tptruinthashdatalist.checkkey(const akey; const aitemdata): boolean;
begin
 result:= ptruint(akey) = ptruintdataty(aitemdata).key;
end;

function tptruinthashdatalist.first: pptruintdataty;
begin
 result:= pptruintdataty(internalfirst);
end;

function tptruinthashdatalist.next: pptruintdataty;
begin
 result:= pptruintdataty(internalnext);
end;

function tptruinthashdatalist.delete(const akey: ptruint;
               const all: boolean = false): boolean;
begin
 result:= internaldelete(akey,all);
end;

{ tpointerptruinthashdatalist }

constructor tpointerptruinthashdatalist.create;
begin
 inherited create(sizeof(pointer));
end;

procedure tpointerptruinthashdatalist.add(const akey: ptruint;
                                       const avalue: pointer);
begin
 ppointer(inherited add(akey))^:= avalue;
end;

function tpointerptruinthashdatalist.find(const akey: ptruint;
                                             out avalue: pointer): boolean;
var
 po1: ppointer;
begin
 po1:= inherited find(akey);
 result:= po1 <> nil;
 if result then begin
  avalue:= po1^;
 end
 else begin
  avalue:= nil;
 end;
end;

function tpointerptruinthashdatalist.addunique(const akey: ptruint;
                                               const avalue: pointer): boolean;
var
 po1: ppointer;
begin
 result:= true;
 po1:= inherited find(akey);
 if po1 = nil then begin
  result:= false;
  po1:= inherited add(akey);
  po1^:= avalue;
 end;
end;

procedure tpointerptruinthashdatalist.checkexact(const aitemdata;
               var accept: boolean);
begin
 accept:= pointerptruintdataty(aitemdata).data = fpointerparam;
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

function tpointerptruinthashdatalist.first: ppointerptruintdataty;
begin
 result:= ppointerptruintdataty(internalfirst);
end;

function tpointerptruinthashdatalist.next: ppointerptruintdataty;
begin
 result:= ppointerptruintdataty(internalnext);
end;

procedure tpointerptruinthashdatalist.iterate(const akey: ptruint;
               const aiterator: pointerptruintiteratorprocty);
begin
 iterate(akey,keyhashiteratorprocty(aiterator));
end;

{ tansistringhashdatalist }

constructor tansistringhashdatalist.create(const datasize: integer);
begin
 inherited create(datasize + sizeof(ansistringdataty));
 fstate:= fstate + [hls_needsnull,hls_needsfinalize];
end;

procedure tansistringhashdatalist.finalizeitem(var aitemdata);
begin
 finalize(ansistringdataty(aitemdata));
end;

function tansistringhashdatalist.add(const akey: ansistring): pointer;
var
 po1: pansistringhashdataty;
begin
 po1:= pansistringhashdataty(internaladd(akey));
 po1^.data.key:= akey;
 result:= @po1^.data.data;
end;

function tansistringhashdatalist.find(const akey: ansistring): pointer;
begin
 result:= internalfind(akey);
 if result <> nil then begin
  result:= @pansistringdataty(pchar(result)+sizeof(hashheaderty))^.data;
 end;
end;

function tansistringhashdatalist.find(const akey: lstringty): pointer;
var
 ha1: hashvaluety;
 uint1: ptruint;
 po1: phashdataty;
begin
 po1:= nil;
 if count > 0 then begin
  ha1:= hashlkey(akey);
  uint1:= fhashtable[ha1 and fmask];
  if uint1 <> 0 then begin
   po1:= phashdataty(pchar(fdata) + uint1);
   while true do begin
    if (po1^.header.hash = ha1) and checklkey(akey,po1^.data) then begin
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
 if result <> nil then begin
  result:= @pmsestringdataty(pchar(result)+sizeof(hashheaderty))^.data;
 end;
end;

function tansistringhashdatalist.addunique(const akey: ansistring): pointer;
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

function tansistringhashdatalist.checkkey(const akey; const aitemdata): boolean;
var
 int1: integer;
begin
 result:= pointer(akey) = pointer(ansistringdataty(aitemdata).key);
 if not result then begin
  int1:= length(ansistring(akey));
  result:= (int1 = length(ansistringdataty(aitemdata).key)) and
      comparemem(pointer(akey),pointer(ansistringdataty(aitemdata).key),int1);
 end;
end;

function tansistringhashdatalist.checklkey(const akey: lstringty;
                                                const aitemdata): boolean;
begin
 result:= (akey.len = length(ansistringdataty(aitemdata).key)) and
      comparemem(akey.po,pointer(ansistringdataty(aitemdata).key),akey.len);
end;

function tansistringhashdatalist.delete(const akey: ansistring;
               const all: boolean = false): boolean;
begin
 result:= internaldelete(akey,all);
end;

function tansistringhashdatalist.delete(const akey: lstringty;
               const all: boolean = false): boolean;
begin
 result:= internaldelete(lstringtostring(akey),all);
end;

function tansistringhashdatalist.first: pansistringdataty;
begin
 result:= pansistringdataty(internalfirst);
end;

function tansistringhashdatalist.next: pansistringdataty;
begin
 result:= pansistringdataty(internalnext);
end;

procedure tansistringhashdatalist.iterate(const akey: ansistring;
               const aiterator: ansistringhashiteratorprocty);
begin
 iterate(akey,keyhashiteratorprocty(aiterator));
end;

{ tpointeransistringhashdatalist }

constructor tpointeransistringhashdatalist.create;
begin
 inherited create(sizeof(pointer));
end;

procedure tpointeransistringhashdatalist.add(const akey: ansistring;
                                       const avalue: pointer);
begin
 ppointer(inherited add(akey))^:= avalue;
end;

procedure tpointeransistringhashdatalist.add(const keys: array of string;
                   startindex: pointer = pointer($00000001)); overload;
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
 po1: ppointer;
begin
 po1:= inherited find(akey);
 result:= po1 <> nil;
 if result then begin
  avalue:= po1^;
 end
 else begin
  avalue:= nil;
 end;
end;

function tpointeransistringhashdatalist.addunique(const akey: ansistring;
                                               const avalue: pointer): boolean;
var
 po1: ppointer;
begin
 result:= true;
 po1:= inherited find(akey);
 if po1 = nil then begin
  result:= false;
  po1:= inherited add(akey);
  po1^:= avalue;
 end;
end;

procedure tpointeransistringhashdatalist.checkexact(const aitemdata;
               var accept: boolean);
begin
 accept:= pointeransistringdataty(aitemdata).data = fpointerparam;
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

function tpointeransistringhashdatalist.first: ppointeransistringdataty;
begin
 result:= ppointeransistringdataty(internalfirst);
end;

function tpointeransistringhashdatalist.next: ppointeransistringdataty;
begin
 result:= ppointeransistringdataty(internalnext);
end;

procedure tpointeransistringhashdatalist.iterate(const akey: ansistring;
               const aiterator: pointeransistringiteratorprocty);
begin
 iterate(akey,keyhashiteratorprocty(aiterator));
end;

{ tmsestringhashdatalist }

constructor tmsestringhashdatalist.create(const datasize: integer);
begin
 inherited create(datasize + sizeof(msestringdataty));
 fstate:= fstate + [hls_needsnull,hls_needsfinalize];
end;

procedure tmsestringhashdatalist.finalizeitem(var aitemdata);
begin
 finalize(msestringdataty(aitemdata));
end;

function tmsestringhashdatalist.add(const akey: msestring): pointer;
var
 po1: pmsestringhashdataty;
begin
 po1:= pmsestringhashdataty(internaladd(akey));
 po1^.data.key:= akey;
 result:= @po1^.data.data;
end;

function tmsestringhashdatalist.find(const akey: msestring): pointer;
begin
 result:= internalfind(akey);
 if result <> nil then begin
  result:= @pmsestringdataty(pchar(result)+sizeof(hashheaderty))^.data;
 end;
end;

function tmsestringhashdatalist.find(const akey: lmsestringty): pointer;
var
 ha1: hashvaluety;
 uint1: ptruint;
 po1: phashdataty;
begin
 po1:= nil;
 if count > 0 then begin
  ha1:= hashlkey(akey);
  uint1:= fhashtable[ha1 and fmask];
  if uint1 <> 0 then begin
   po1:= phashdataty(pchar(fdata) + uint1);
   while true do begin
    if (po1^.header.hash = ha1) and checklkey(akey,po1^.data) then begin
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
 if result <> nil then begin
  result:= @pmsestringdataty(pchar(result)+sizeof(hashheaderty))^.data;
 end;
end;

function tmsestringhashdatalist.find(const akey: msestring;
                                                out acount: integer): pointer;
begin
 result:= internalfind(akey,acount);
 if result <> nil then begin
  result:= @pmsestringdataty(pchar(result)+sizeof(hashheaderty))^.data;
 end;
end;

function tmsestringhashdatalist.addunique(const akey: msestring): pointer;
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

function tmsestringhashdatalist.checklkey(const akey: lmsestringty; const aitemdata): boolean;
begin
 result:= (akey.len = length(msestringdataty(aitemdata).key)) and
      comparemem(akey.po,pointer(msestringdataty(aitemdata).key),
                                               akey.len*sizeof(msechar));
end;

function tmsestringhashdatalist.checkkey(const akey; const aitemdata): boolean;
var
 int1: integer;
begin
 result:= pointer(akey) = pointer(msestringdataty(aitemdata).key);
 if not result then begin
  int1:= length(msestring(akey));
  result:= (int1 = length(msestringdataty(aitemdata).key)) and
      comparemem(pointer(akey),pointer(msestringdataty(aitemdata).key),
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
begin
 result:= internaldelete(lstringtostring(akey),all);
end;

function tmsestringhashdatalist.first: pmsestringdataty;
begin
 result:= pmsestringdataty(internalfirst);
end;

function tmsestringhashdatalist.next: pmsestringdataty;
begin
 result:= pmsestringdataty(internalnext);
end;

procedure tmsestringhashdatalist.iterate(const akey: msestring;
               const aiterator: msestringiteratorprocty);
begin
 iterate(akey,keyhashiteratorprocty(aiterator));
end;

{ tpointermsestringhashdatalist }

constructor tpointermsestringhashdatalist.create;
begin
 inherited create(sizeof(pointer));
end;

procedure tpointermsestringhashdatalist.add(const akey: msestring;
                                       const avalue: pointer);
begin
 ppointer(inherited add(akey))^:= avalue;
end;

function tpointermsestringhashdatalist.find(const akey: msestring;
                                             out avalue: pointer): boolean;
var
 po1: ppointer;
begin
 po1:= inherited find(akey);
 result:= po1 <> nil;
 if result then begin
  avalue:= po1^;
 end
 else begin
  avalue:= nil;
 end;
end;

function tpointermsestringhashdatalist.find(const akey: msestring;
                        out avalue: pointer; out acount: integer): boolean;
var
 po1: ppointer;
begin
 po1:= inherited find(akey,acount);
 result:= po1 <> nil;
 if result then begin
  avalue:= po1^;
 end
 else begin
  avalue:= nil;
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
 po1: ppointer;
begin
 result:= true;
 po1:= inherited find(akey);
 if po1 = nil then begin
  result:= false;
  po1:= inherited add(akey);
  po1^:= avalue;
 end;
end;

procedure tpointermsestringhashdatalist.checkexact(const aitemdata;
               var accept: boolean);
begin
 accept:= pointermsestringdataty(aitemdata).data = fpointerparam;
end;

function tpointermsestringhashdatalist.first: ppointermsestringdataty;
begin
 result:= ppointermsestringdataty(internalfirst);
end;

function tpointermsestringhashdatalist.next: ppointermsestringdataty;
begin
 result:= ppointermsestringdataty(internalnext);
end;

procedure tpointermsestringhashdatalist.iterate(const akey: msestring;
               const aiterator: pointermsestringiteratorprocty);
begin
 iterate(akey,keyhashiteratorprocty(aiterator));
end;

{ tobjectmsestringhashdatalist }

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

function tobjectmsestringhashdatalist.first: pobjectmsestringdataty;
begin
 result:= pobjectmsestringdataty(inherited first);
end;

function tobjectmsestringhashdatalist.next: pobjectmsestringdataty;
begin
 result:= pobjectmsestringdataty(inherited next);
end;

procedure tobjectmsestringhashdatalist.iterate(const akey: msestring;
               const aiterator: objectmsestringiteratorprocty);
begin
 inherited iterate(akey,pointermsestringiteratorprocty(aiterator));
end;

procedure tobjectmsestringhashdatalist.finalizeitem(var aitemdata);
begin
 inherited;
 with objectmsestringdataty(aitemdata) do begin
  data.free;
 end;
end;

end.
