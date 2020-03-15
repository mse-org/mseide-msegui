{ MSEgui Copyright (c) 1999-2011 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msebucketlist;
//
// deprecated, use t*hashdatalist in msehash.pas instead
//
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 msestrings;

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

implementation
uses
 sysutils,msehash;

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

end.
