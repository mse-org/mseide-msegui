{ MSEgui Copyright (c) 1999-2007 by Martin Schreiber

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
const
 defaultbucketcount = $20;
 defaultgrowstep = 8;

type
 datastatety = (ds_empty,ds_data);
 bucketty = record
  count: integer;
  keys: array of ptruint;    //0-> free
  datapo: pointer;
 end;
 pbucketty = ^bucketty;
 bucketarty = array of bucketty;

 tbucketlist = class
  private
   fbuckets: bucketarty;
   fsize: integer;
   fmask1: longword;
   fcapacitystep: integer;
   fstepbucket,fstepindex: integer;
   procedure invalidkey;
   function bucketindex(const key: ptruint): integer;
  protected
   fcount: integer;
   procedure freedata(var data); virtual;
   procedure initdata(var data); virtual;
   function add(const key: ptruint; const data): pointer; //key <> 0
               //returns pointer to new data, @data can be nil -> data inited with 0
   function internalfind(const key: ptruint; var bucket,index: integer): boolean;
   function find(const key: ptruint): pointer;
   function next: pointer;
  public
   constructor create(recordsize: integer; abucketcount: integer = defaultbucketcount);
   destructor destroy; override;
   procedure clear;
   function count: integer;
   function delete(const key: ptruint): boolean; //true if found
 end;

 datastringty = record
  key: string;
  data: pointer;
 end;
 pdatastringty = ^datastringty;

 stringbucketty = array of datastringty;
 stringbucketpoty = ^stringbucketty;
 stringbucketarty = array of stringbucketty;

 thashedstrings = class
  private
   fbuckets: stringbucketarty;
   fmask: longword;
   fcapacitystep: integer;
   fcount: integer;
   fstepbucket,fstepindex: integer;
   function getbucketcount: integer;
   procedure setbucketcount(const Value: integer);
   function internalfind(const key: string): pdatastringty; overload;
   function internalfind(const key: lstringty): pdatastringty; overload;
  public
   constructor create;
   procedure clear; virtual;
   procedure add(const key: string; data: pointer = pointer($ffffffff)); overload;
                         //nil nicht erlaubt
   procedure add(const keys: array of string;
                   startindex: pointer = pointer($00000001)); overload;
                             //data = arrayindex + startindex
   procedure delete(const key: lstringty); overload; virtual;
   procedure delete(const key: string); overload;
   function find(const key: string): pointer; overload;     //casesensitive
   function find(const key: lstringty): pointer; overload;  //casesensitive
   function findi(const key: string): pointer; overload;    //caseinsensitive
   function findi(const key: lstringty): pointer; overload; //caseinsensitive
   property bucketcount: integer read getbucketcount write setbucketcount default defaultbucketcount;
   property count: integer read fcount;
   function next: pdatastringty;
 end;

 msedatastringty = record
  key: msestring;
  data: pointer;
 end;
 pmsedatastringty = ^msedatastringty;

 msestringbucketty = array of msedatastringty;
 pmsestringbucketty = ^msestringbucketty;
 msestringbucketarty = array of msestringbucketty;

 thashedmsestrings = class
  private
   fcount: integer;
   fbuckets: msestringbucketarty;
   fmask: longword;
   fcapacitystep: integer;
   fstepbucket,fstepindex: integer;
   function getbucketcount: integer;
   procedure setbucketcount(const Value: integer);
   function internalfind(const key: msestring): pmsedatastringty;
  public
   constructor create;
   procedure clear; virtual;
   procedure add(const key: msestring; data: pointer = pointer($ffffffff)); overload;
   procedure add(const keys: array of msestring;
                       startindex:  pointer = pointer($00000001));
               overload; //data = arrayindex + startindex
   procedure delete(const key: msestring); virtual;
   function find(const key: msestring): pointer; overload;
   function find(const key: lmsestringty): pointer; overload;
   function findi(const key: msestring): pointer; overload;
   function findi(const key: lmsestringty): pointer; overload;
   property bucketcount: integer read getbucketcount write setbucketcount default defaultbucketcount;
   property count: integer read fcount;
   function next: pmsedatastringty;
 end;

 thashedmsestringobjects = class(thashedmsestrings)
  public
   destructor destroy; override;
   procedure clear; override;
   procedure add(const key: msestring; aobject: tobject);
   procedure delete(const key: msestring); override;
   function find(const key: msestring): tobject; overload;
   function find(const key: lmsestringty): tobject; overload;
   function findi(const key: msestring): tobject; overload;
   function findi(const key: lmsestringty): tobject; overload;
 end;

 thashedstringobjects = class(thashedstrings)
  public
   destructor destroy; override;
   procedure clear; override;
   procedure add(const key: string; aobject: tobject);
   procedure delete(const key: lstringty); override;
   function find(const key: string): tobject; overload;
   function find(const key: lstringty): tobject; overload;
   function findi(const key: string): tobject; overload;
   function findi(const key: lstringty): tobject; overload;
 end;

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
 findcheckprocty = procedure(const aitemdata; var accept: boolean) of object;

 hashliststatety = (hls_needsnull,hls_needsfinalize);
 hashliststatesty = set of hashliststatety;

 thashdatalist = class
  private
   fmask: hashvaluety;
   fdatasize: integer;
   frecsize: integer;
   fcapacity: integer;
   fcount: integer;
   fhashtable: ptruintarty;
   fdata: pointer; //first record is a dummy
   fassignedroot: ptruint;
   fdeletedroot: ptruint;
   fdestpo: phashdataty;
   procedure setcapacity(const avalue: integer);
   procedure moveitem(const aitem: phashdataty);
  protected
   fstate: hashliststatesty;
   function internaladd(const akey): phashdataty;
   procedure internaldeleteitem(const aitem: phashdataty);
   function internaldelete(const akey; const all: boolean): boolean;
   function internalfind(const akey): phashdataty;
   function internalfind(const akey; const acheckproc: findcheckprocty): phashdataty;
   function internalfindexact(const akey): phashdataty;
   procedure checkexact(const aitemdata; var accept: boolean); virtual; abstract;
   function hashkey(const akey): hashvaluety; virtual; abstract;
   function checkkey(const akey; const aitemdata): boolean; virtual; abstract;
   procedure rehash;
   procedure grow;
   procedure finalizeitem(var aitemdata); virtual;
   procedure internaliterate(const aiterator: internalhashiteratorprocty); overload;
   procedure iterate(const akey; const aiterator: keyhashiteratorprocty); overload;
  public
   constructor create(const datasize: integer);
   destructor destroy; override;
   procedure clear;{ virtual;}
   property capacity: integer read fcapacity write setcapacity;
   property count: integer read fcount;
   procedure iterate(const aiterator: hashiteratorprocty); overload;
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
//   function hash(const key: ptruint): hashvaluety; {$ifdef FPC}inline;{$endif}
   function hashkey(const akey): hashvaluety; override;
   function checkkey(const akey; const aitemdata): boolean; override;
//   function dohash(const aitem: phashdataty): hashvaluety; override;
  public
   constructor create(const datasize: integer);
   function add(const akey: ptruint): pointer;
   function find(const akey: ptruint): pointer;
   function addunique(const akey: ptruint): pointer;
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
   procedure finalizeitem(var aitemdata); override;
  public
   constructor create(const datasize: integer);
   function add(const akey: ansistring): pointer; 
            //returns pointer on ansistringdataty.data
   function find(const akey: ansistring): pointer;
   function addunique(const akey: ansistring): pointer;
   function delete(const akey: ansistring; 
                         const all: boolean = false): boolean; //true if found
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

 tpointeransistringhashdatalist = class(tansistringhashdatalist)
  private
   fpointerparam: pointer;
  protected
   procedure checkexact(const aitemdata; var accept: boolean); override;
  public
   constructor create;
   procedure add(const akey: ansistring; const avalue: pointer);
   procedure delete(const akey: ansistring; const avalue: pointer);
   function find(const akey: ansistring): pointer;
   function find(const akey: ansistring; out avalue: pointer): boolean;
   function addunique(const akey: ansistring; const avalue: pointer): boolean;
                   //true if found
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
 
 msestringhashiteratorprocty = procedure(var aitem: msestringdataty) of object;

 tmsestringhashdatalist = class(thashdatalist)
  private
  protected
   function hashkey(const akey): hashvaluety; override;
   function checkkey(const akey; const aitemdata): boolean; override;
   procedure finalizeitem(var aitemdata); override;
  public
   constructor create(const datasize: integer);
   function add(const akey: msestring): pointer;
                 //returns pointer on msestringdataty.data
   function find(const akey: msestring): pointer;
   function addunique(const akey: msestring): pointer;
   function delete(const akey: msestring; 
                         const all: boolean = false): boolean; //true if found
   procedure iterate(const akey: msestring;
                     const aiterator: msestringhashiteratorprocty); overload;
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

 tpointermsestringhashdatalist = class(tmsestringhashdatalist)
  private
   fpointerparam: pointer;
  protected
   procedure checkexact(const aitemdata; var accept: boolean); override;
  public
   constructor create;
   procedure add(const akey: msestring; const avalue: pointer);
   procedure delete(const akey: msestring; const avalue: pointer);
   function find(const akey: msestring): pointer; overload;
   function find(const akey: msestring; out avalue: pointer): boolean; overload;
   function addunique(const akey: msestring; const avalue: pointer): boolean;
                   //true if found
 end;

function datahash(const data; len: integer): longword;
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
 for int1:= 0 to len - 1 do begin
  inc(ca1,po1^);
 end;
 result:= ca1;
end;

function stringhash(const key: string): longword; overload;
var
 I: Integer;
begin
 Result := 0;
 for I := 1 to Length(key) do begin
  Result := ((Result shl 2) or (Result shr (SizeOf(Result) * 8 - 2))) xor
                            Ord(Key[I]);
 end;
end;

function stringhash(const key: lstringty): longword; overload;
var
 I: Integer;
 po: pchar;
begin
 Result := 0;
 po:= key.po;
 i:= key.len;
 while i > 0 do begin
  Result := ((Result shl 2) or (Result shr (SizeOf(Result) * 8 - 2))) xor
                            Ord(po^);
  inc(po);
  dec(i);
 end;
end;

function stringhash(const key: msestring): longword; overload;
var
 I: Integer;
begin
 Result := 0;
 for I := 1 to Length(key) do begin
  Result := ((Result shl 2) or (Result shr (SizeOf(Result) * 8 - 2))) xor
                            Ord(Key[I]);
 end;
end;

function stringhash(const key: lmsestringty): longword; overload;
var
 I: Integer;
 po: pmsechar;
begin
 Result := 0;
 po:= key.po;
 i:= key.len;
 while i > 0 do begin
  Result := ((Result shl 2) or (Result shr (SizeOf(Result) * 8 - 2))) xor
                            Ord(po^);
  inc(po);
  dec(i);
 end;
end;

function maxbitmask(value: longword): longword;
begin
 if value = 0 then begin
  result:= 0;
 end
 else begin
  result:= $ffffffff;
  while value and $80000000 = 0 do begin
   result:= result shr 1;
   value:= value shl 1;
  end;
 end;
end;

{ tbucketlist }

constructor tbucketlist.create(recordsize: integer;
                        abucketcount: integer = defaultbucketcount);
begin
 fcapacitystep:= defaultgrowstep;
 fsize:= recordsize;
 fmask1:= maxbitmask(abucketcount-1);
 setlength(fbuckets,fmask1+1);
end;

destructor tbucketlist.destroy;
begin
 clear;
 inherited;
end;

function tbucketlist.bucketindex(const key: ptruint): integer;
begin
 if key = 0 then begin
  invalidkey;
 end;
 result:= (key xor (key shr 4)) and fmask1;
end;

procedure tbucketlist.clear;
var
 int1,int2: integer;
 po1: pchar;
begin
 for int1:= 0 to high(fbuckets) do begin
  with fbuckets[int1] do begin
   po1:= datapo;
   if po1 <> nil then begin
    for int2:= 0 to high(keys) do begin
     if keys[int2] <> 0 then begin
      freedata(po1^);
     end;
     inc(po1,fsize);
    end;
    freemem(datapo);
    datapo:= nil;
    setlength(keys,0);
    count:= 0;
   end;
  end;
 end;
 fcount:= 0;
end;

procedure tbucketlist.freedata(var data);
begin
 //dummy
end;

function tbucketlist.count: integer;
begin
 result:= fcount;
end;

procedure tbucketlist.initdata(var data);
begin
 //dummy
end;

function tbucketlist.add(const key: ptruint; const data): pointer;
var
 int1: integer;
begin
 with fbuckets[bucketindex(key)] do begin
  if count >= length(keys) then begin
   int1:= length(keys);
   setlength(keys,length(keys)+fcapacitystep);
   reallocmem(datapo,length(keys)*fsize);
  end
  else begin
   int1:= high(keys);
   while keys[int1] <> 0 do begin
    dec(int1);
   end;
  end;
  keys[int1]:= key;
  result:= pchar(datapo) + int1*fsize;
  if @data = nil then begin
   fillchar(result^,fsize,0);
  end
  else begin
   move(data,result^,fsize);
  end;
  inc(count);
  inc(fcount);
  initdata(result^);
 end;
end;

function tbucketlist.internalfind(const key: ptruint; var bucket,index: integer): boolean;
var
 int1: integer;
begin
 result:= false;
 bucket:= bucketindex(key);
 with fbuckets[bucket] do begin
  for int1:= 0 to high(keys) do begin
   if keys[int1] = key then begin
    index:= int1;
    result:= true;
    break;
   end;
  end;
 end;
end;

function tbucketlist.delete(const key: ptruint): boolean;
       //true if found
var
 bucket,index: integer;
begin
 result:= internalfind(key,bucket,index);
 if result then begin
  with fbuckets[bucket] do begin
   freedata((pchar(datapo) + index*fsize)^);
   dec(count);
   keys[index]:= 0;
   dec(fcount);
  end;
 end;
end;

procedure tbucketlist.invalidkey;
begin
 raise exception.Create('Invalid keyvalue.');
end;

function tbucketlist.find(const key: ptruint): pointer;
var
 bucket,index: integer;
begin
 if internalfind(key,bucket,index) then begin
  result:= pchar(fbuckets[bucket].datapo) + index*fsize;
 end
 else begin
  result:= nil;
 end;
end;

function tbucketlist.next: pointer;
begin
 result:= nil;
 if fcount > 0 then begin
  inc(fstepindex);
  repeat
   if fstepbucket >= length(fbuckets) then begin
    fstepbucket:= 0;
    fstepindex:= 0;
   end;
   with fbuckets[fstepbucket] do begin
    if fstepindex >= length(keys) then begin
     inc(fstepbucket);
     fstepindex:= 0;
    end
    else begin
     if keys[fstepindex] <> 0 then begin
      result:= pchar(datapo) + fstepindex*fsize;
     end
     else begin
      inc(fstepindex);
     end;
    end;
   end;
  until result <> nil;
 end;
end;

{ thashedstrings }

constructor thashedstrings.create;
begin
 fcapacitystep:= defaultgrowstep;
 setbucketcount(defaultbucketcount);
end;

procedure thashedstrings.add(const key: string; data: pointer = pointer($ffffffff));
var
 po: stringbucketpoty;
 po1: pdatastringty;
 int1: integer;
 freefound: boolean;
begin
 if data = nil then begin
  raise exception.create('nil not allowed.');
 end;
 inc(fcount);
 po:= @fbuckets[stringhash(key) and fmask];
 po1:= @po^[0];
 freefound:= false;
 for int1:= 0 to high(po^) do begin
  if po1^.data = nil then begin
   freefound:= true;
   break;
  end;
  inc(po1)
 end;
 if not freefound then begin
  int1:= length(po^);
  setlength(po^,int1+fcapacitystep);
  po1:= @po^[int1];
 end;
 po1^.key:= key;
 po1^.data:= data;
end;

procedure thashedstrings.add(const keys: array of string;
                 startindex:  pointer = pointer($00000001));
var
 ca1: longword;
begin
 if ptruint(length(keys)) + ptruint(startindex) <= ptruint(length(keys)) then begin
  raise exception.create('nil not allowed.');
 end;
 for ca1:= 0 to high(keys) do begin
  add(keys[ca1],pointer(ca1+ptruint(startindex)));
 end;
end;

procedure thashedstrings.clear;
var
 int1: integer;
begin
 for int1:= 0 to high(fbuckets) do begin
  fbuckets[int1]:= nil;
 end;
 fcount:= 0;
end;

function thashedstrings.internalfind(const key: string): pdatastringty;
var
 po: stringbucketpoty;
 po1: pdatastringty;
 int1: integer;
begin
 result:= nil;
 if fcount > 0 then begin
  po:= @fbuckets[stringhash(key) and fmask];
  po1:= @po^[0];
  for int1:= 0 to high(po^) do begin
   if (po1^.data <> nil) and (po1^.key = key) then begin
    result:= po1;
    break;
   end;
   inc(po1)
  end;
 end;
end;

function thashedstrings.internalfind(const key: lstringty): pdatastringty;
var
 po: stringbucketpoty;
 po1: pdatastringty;
 int1,int2: integer;
begin
 result:= nil;
 if fcount > 0 then begin
  po:= @fbuckets[stringhash(key) and fmask];
  po1:= @po^[0];
  for int1:= 0 to high(po^) do begin
   if po1^.data <> nil then begin
    int2:= length(po1^.key);
    if int2 > 0 then begin
     if int2 < key.len then begin
      int2:= key.len;
     end;
     if strlcomp(key.po,pointer(po1^.key),int2) = 0 then begin
      result:= po1;
      break;
     end;
    end;
   end;
   inc(po1)
  end;
 end;
end;

function thashedstrings.find(const key: lstringty): pointer;
var
 po1: pdatastringty;
begin
 po1:= internalfind(key);
 if po1 <> nil then begin
  result:= po1^.data;
 end
 else begin
  result:= nil;
 end;
end;

function thashedstrings.find(const key: string): pointer;
var
 po1: pdatastringty;
begin
 po1:= internalfind(key);
 if po1 <> nil then begin
  result:= po1^.data;
 end
 else begin
  result:= nil;
 end;
end;


function thashedstrings.findi(const key: string): pointer;
begin
 if fcount > 0 then begin
  result:= find(struppercase(key));
 end
 else begin
  result:= nil;
 end;
end;

function thashedstrings.findi(const key: lstringty): pointer;
begin
 if fcount > 0 then begin
  result:= find(struppercase(key));
 end
 else begin
  result:= nil;
 end;
end;

procedure thashedstrings.delete(const key: lstringty);
var
 po1: pdatastringty;
begin
 while true do begin
  po1:= internalfind(key);
  if po1 = nil then begin
   break;
  end;
  po1^.data:= nil;
  dec(fcount);
 end;
end;

procedure thashedstrings.delete(const key: string);
var
 lstr1: lstringty;
begin
 lstr1.len:= length(key);
 lstr1.po:= pointer(key);
 delete(lstr1);
end;

function thashedstrings.getbucketcount: integer;
begin
 result:= length(fbuckets);
end;

procedure thashedstrings.setbucketcount(const Value: integer);
begin
 fmask:= maxbitmask(value-1);
 setlength(fbuckets,fmask+1);
end;

function thashedstrings.next: pdatastringty;
begin
 result:= nil;
 if fcount > 0 then begin
  inc(fstepindex);
  repeat
   if fstepbucket > high(fbuckets) then begin
    fstepbucket:= 0;
    fstepindex:= 0;
   end;
   if fstepindex > high(fbuckets[fstepbucket]) then begin
    inc(fstepbucket);
    fstepindex:= 0;
   end
   else begin
    if fbuckets[fstepbucket][fstepindex].data <> nil then begin
     result:= @fbuckets[fstepbucket][fstepindex];
    end
    else begin
     inc(fstepindex);
    end;
   end;
  until result <> nil;
 end;
end;

{ thashedmsestrings }

constructor thashedmsestrings.create;
begin
 fcapacitystep:= defaultgrowstep;
 setbucketcount(defaultbucketcount);
end;

procedure thashedmsestrings.add(const key: msestring;
                         data: pointer = pointer($ffffffff));
var
 po: pmsestringbucketty;
 po1: pmsedatastringty;
 int1: integer;
 freefound: boolean;
begin
 if data = nil then begin
  raise exception.create('nil not allowed.');
 end;
 inc(fcount);
 po:= @fbuckets[stringhash(key) and fmask];
 po1:= @po^[0];
 freefound:= false;
 for int1:= 0 to high(po^) do begin
  if po1^.data = nil then begin
   freefound:= true;
   break;
  end;
  inc(po1)
 end;
 if not freefound then begin
  int1:= length(po^);
  setlength(po^,int1+fcapacitystep);
  po1:= @po^[int1];
 end;
 po1^.key:= key;
 po1^.data:= data;
end;

procedure thashedmsestrings.add(const keys: array of msestring;
                  startindex:  pointer = pointer($00000001));
var
 ca1: longword;
begin
 if longword(length(keys)) + ptruint(startindex) <= longword(length(keys)) then begin
  raise exception.create('nil not alowed.');
 end;
 for ca1:= 0 to high(keys) do begin
  add(keys[ca1],pointer(ca1+ptruint(startindex)));
 end;
end;

procedure thashedmsestrings.clear;
var
 int1: integer;
begin
 for int1:= 0 to high(fbuckets) do begin
  fbuckets[int1]:= nil;
 end;
 fcount:= 0;
end;

function thashedmsestrings.internalfind(const key: msestring): pmsedatastringty;
var
 po: pmsestringbucketty;
 po1: pmsedatastringty;
 int1: integer;
begin
 result:= nil;
 if fcount > 0 then begin
  po:= @fbuckets[stringhash(key) and fmask];
  po1:= @po^[0];
  for int1:= 0 to high(po^) do begin
   if (po1^.data <> nil) and (po1^.key = key) then begin
    result:= po1;
    break;
   end;
   inc(po1)
  end;
 end;
end;

function thashedmsestrings.find(const key: lmsestringty): pointer;
var
 po: pmsestringbucketty;
 po1: pmsedatastringty;
 int1,int2: integer;
begin
 result:= nil;
 if fcount > 0 then begin
  po:= @fbuckets[stringhash(key) and fmask];
  po1:= @po^[0];
  for int1:= 0 to high(po^) do begin
   if po1^.data <> nil then begin
    int2:= length(po1^.key);
    if int2 > 0 then begin
     if int2 < key.len then begin
      int2:= key.len;
     end;
     if msestrlcomp(key.po,pointer(po1^.key),int2) = 0 then begin
      result:= po1^.data;
      break;
     end;
    end;
   end;
   inc(po1)
  end;
 end;
end;

function thashedmsestrings.find(const key: msestring): pointer;
var
 po1: pmsedatastringty;
begin
 po1:= internalfind(key);
 if po1 <> nil then begin
  result:= po1^.data;
 end
 else begin
  result:= nil;
 end;
end;

function thashedmsestrings.findi(const key: lmsestringty): pointer;
begin
 result:= find(struppercase(key));
end;

function thashedmsestrings.findi(const key: msestring): pointer;
begin
 if fcount > 0 then begin
  result:= find(struppercase(key));
 end
 else begin
  result:= nil;
 end;
end;

procedure thashedmsestrings.delete(const key: msestring);
var
 po1: pmsedatastringty;
begin
 repeat
  po1:= internalfind(key);
  if po1 <> nil then begin
   dec(fcount);
   po1^.data:= nil;
  end;
 until po1 = nil;
end;

function thashedmsestrings.getbucketcount: integer;
begin
 result:= length(fbuckets);
end;

procedure thashedmsestrings.setbucketcount(const Value: integer);
begin
 fmask:= maxbitmask(value-1);
 setlength(fbuckets,fmask+1);
end;

function thashedmsestrings.next: pmsedatastringty;
begin
 result:= nil;
 if fcount > 0 then begin
  inc(fstepindex);
  repeat
   if fstepbucket > high(fbuckets) then begin
    fstepbucket:= 0;
    fstepindex:= 0;
   end;
   if fstepindex > high(fbuckets[fstepbucket]) then begin
    inc(fstepbucket);
    fstepindex:= 0;
   end
   else begin
    if fbuckets[fstepbucket][fstepindex].data <> nil then begin
     result:= @fbuckets[fstepbucket][fstepindex];
    end
    else begin
     inc(fstepindex);
    end;
   end;
  until result <> nil;
 end;
end;

{ thashedstringobjects }

destructor thashedstringobjects.destroy;
begin
 clear;
 inherited;
end;

procedure thashedstringobjects.clear;
var
 int1,int2: integer;
begin
 for int1:= 0 to high(fbuckets) do begin
  if fbuckets[int1] <> nil then begin
   for int2:= 0 to high(fbuckets[int1]) do begin
    if fbuckets[int1][int2].data <> nil then begin
     tobject(fbuckets[int1][int2].data).free;
    end;
   end;
  end;
  fbuckets[int1]:= nil;
 end;
 fcount:= 0;
end;

procedure thashedstringobjects.add(const key: string; aobject: tobject);
begin
 inherited add(key,aobject);
end;

procedure thashedstringobjects.delete(const key: lstringty);
var
 po1: pdatastringty;
begin
 repeat
  po1:= internalfind(key);
  if po1 <> nil then begin
   tobject(po1^.data).Free;
   po1^.data:= nil;
   dec(fcount);
  end;
 until po1 = nil;
end;

function thashedstringobjects.find(const key: string): tobject;
begin
 result:= tobject(inherited find(key));
end;

function thashedstringobjects.find(const key: lstringty): tobject;
begin
 result:= tobject(inherited find(key));
end;

function thashedstringobjects.findi(const key: string): tobject;
begin
 result:= tobject(inherited findi(key));
end;

function thashedstringobjects.findi(const key: lstringty): tobject;
begin
 result:= tobject(inherited findi(key));
end;

{ thashedmsestringobjects }

destructor thashedmsestringobjects.destroy;
begin
 clear;
 inherited;
end;

procedure thashedmsestringobjects.clear;
var
 int1,int2: integer;
begin
 for int1:= 0 to high(fbuckets) do begin
  if fbuckets[int1] <> nil then begin
   for int2:= 0 to high(fbuckets[int1]) do begin
    if fbuckets[int1][int2].data <> nil then begin
     tobject(fbuckets[int1][int2].data).free;
    end;
   end;
  end;
  fbuckets[int1]:= nil;
 end;
 fcount:= 0;
end;

procedure thashedmsestringobjects.add(const key: msestring; aobject: tobject);
begin
 inherited add(key,aobject);
end;

procedure thashedmsestringobjects.delete(const key: msestring);
var
 po1: pmsedatastringty;
begin
 repeat
  po1:= internalfind(key);
  if po1 <> nil then begin
   tobject(po1^.data).Free;
   po1^.data:= nil;
   dec(fcount);
  end;
 until po1 = nil;
end;

function thashedmsestringobjects.find(const key: msestring): tobject;
begin
 result:= tobject(inherited find(key));
end;

function thashedmsestringobjects.find(const key: lmsestringty): tobject;
begin
 result:= tobject(inherited find(key));
end;

function thashedmsestringobjects.findi(const key: msestring): tobject;
begin
 result:= tobject(inherited findi(key));
end;

function thashedmsestringobjects.findi(const key: lmsestringty): tobject;
begin
 result:= tobject(inherited findi(key));
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
 int1: integer;
 po1: pointer;
 puint1: ptruint;
begin
 if avalue <> fcapacity then begin
  if avalue < fcount then begin
   raise exception.create('Capacity < count.');
  end;
  if longword(avalue) >= high(ptruint) div longword(frecsize) then begin
   raise exception.create('Capacity too big.');
  end;
  if (avalue < fcapacity) and (fdeletedroot <> 0) and 
                                    (fcount > 0) then begin //packing necessary
   po1:= getmem((avalue+1)*frecsize);
   if po1 = nil then begin
    raise exception.create('Out of memory.');
   end;
   puint1:= frecsize*fcount;
   fdestpo:= po1 + puint1;
   internaliterate(@moveitem);
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
  int1:= bits[highestbit(avalue)];
  if int1 < avalue then begin
   int1:= int1 * 2;
  end;
  if int1 <> length(fhashtable) then begin
   fillchar(pointer(fhashtable)^,length(fhashtable)*sizeof(fhashtable[0]),0);
   setlength(fhashtable,int1); //additional length nulled by setlength
   fmask:= int1 - 1;
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
 po1:= fdata + fassignedroot;
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
  phashdataty(fdata+puint2)^.header.prevhash:= po2^;
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
  result:= phashdataty(fdata+fdeletedroot);
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
 phashdataty(fdata+puint2)^.header.prevhash:= puint1;
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
  if hls_needsfinalize in fstate then begin
   finalizeitem(aitem^.data);
  end;
  puint1:= pchar(aitem) - fdata;
  with aitem^.header do begin
   if nexthash <> 0 then begin
    phashdataty(fdata+nexthash)^.header.prevhash:= prevhash;
   end;
   if prevhash <> 0 then begin
    phashdataty(fdata+prevhash)^.header.nexthash:= nexthash;
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

procedure thashdatalist.iterate(const aiterator: hashiteratorprocty);
var
 puint1: ptruint;
 po1: phashdataty;
begin
 if fcount > 0 then begin
  po1:= fdata + fassignedroot;
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

procedure thashdatalist.iterate(const akey; const aiterator: keyhashiteratorprocty);
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
  po1:= fdata + fassignedroot;
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

function thashdatalist.internalfindexact(const akey): phashdataty;
begin
 result:= internalfind(akey,@checkexact);
end;

{ tptruinthasdatalist }

constructor tptruinthashdatalist.create(const datasize: integer);
begin
 inherited create(datasize + sizeof(ptruintdataty));
end;
{
function tptruinthashdatalist.hash(const key: ptruint): hashvaluety;
// todo: optimize
begin
 result:= (key xor (key shr 2));
end;
}
function tptruinthashdatalist.hashkey(const akey): hashvaluety;
// todo: optimize
begin
 result:= (ptruint(akey) xor (ptruint(akey) shr 2));
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
var
 uint1: ptruint;
 po1: pptruinthashdataty;
begin
 result:= internalfind(akey);
 if result <> nil then begin
  result:= @pptruinthashdataty(result)^.data.data;
 end;
{
 result:= nil;
 if count > 0 then begin
  uint1:= fhashtable[hash(key) and fmask];
  if uint1 <> 0 then begin
   po1:= pptruinthashdataty(pchar(fdata) + uint1);
   while true do begin
    if po1^.data.key = key then begin
     break;
    end;
    if po1^.header.nexthash = 0 then begin
     po1:= nil;
     break;
    end;
    po1:= pptruinthashdataty(pchar(fdata) + po1^.header.nexthash);
   end;
   if po1 <> nil then begin
    result:= @po1^.data.data;
   end;
  end;
 end;
}
end;

function tptruinthashdatalist.addunique(const akey: ptruint): pointer;
begin
 result:= find(akey);
 if result = nil then begin
  result:= add(akey);
 end;
end;
{
function tptruinthashdatalist.dohash(const aitem: phashdataty): hashvaluety;
begin
 result:= hash(pptruinthashdataty(aitem)^.data.key);
end;
}
function tptruinthashdatalist.checkkey(const akey; const aitemdata): boolean;
begin
 result:= ptruint(akey) = ptruinthashdataty(aitemdata).data.key;
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
  result:= @pansistringdataty(result+sizeof(hashheaderty))^.data;
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

function tansistringhashdatalist.checkkey(const akey; const aitemdata): boolean;
begin
 result:= ansistring(akey) = ansistringdataty(aitemdata).key;
end;

function tansistringhashdatalist.delete(const akey: ansistring;
               const all: boolean = false): boolean;
begin
 result:= internaldelete(akey,all);
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
 end;
 po1^:= avalue;
end;

procedure tpointeransistringhashdatalist.checkexact(const aitemdata;
               var accept: boolean);
begin
 accept:= pointeransistringdataty(aitemdata).data = fpointerparam;
end;

procedure tpointeransistringhashdatalist.delete(const akey: ansistring;
               const avalue: pointer);
var
 po1: phashdataty;
begin
 fpointerparam:= avalue;
 internaldeleteitem(internalfindexact(akey));
end;

function tpointeransistringhashdatalist.find(const akey: ansistring): pointer;
begin
 find(akey,result);
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
  result:= @pmsestringdataty(result+sizeof(hashheaderty))^.data;
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

function tmsestringhashdatalist.checkkey(const akey; const aitemdata): boolean;
begin
 result:= msestring(akey) = msestringdataty(aitemdata).key;
end;

function tmsestringhashdatalist.delete(const akey: msestring;
               const all: boolean = false): boolean;
begin
 result:= internaldelete(akey,all);
end;

procedure tmsestringhashdatalist.iterate(const akey: msestring;
               const aiterator: msestringhashiteratorprocty);
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

function tpointermsestringhashdatalist.find(const akey: msestring): pointer;
begin
 find(akey,result);
end;

procedure tpointermsestringhashdatalist.delete(const akey: msestring;
               const avalue: pointer);
var
 po1: phashdataty;
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
 end;
 po1^:= avalue;
end;

procedure tpointermsestringhashdatalist.checkexact(const aitemdata;
               var accept: boolean);
begin
 accept:= pointermsestringdataty(aitemdata).data = fpointerparam;
end;

end.
