{ MSEgui Copyright (c) 1999-2011 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mselist;

{$ifdef FPC}{$mode objfpc}{$h+}{$GOTO ON}{$interfaces corba}{$endif}

interface

uses
 msetypes,msestrings,mseglob,Classes,sysutils,msesystypes,msearrayutils;

type
// compareprocty = procedure (const l,r; var result: integer) of object;

 recordliststatety = (rels_needsinitialize,rels_needsfinalize,rels_needscopy,
                      rels_destroying);
 recordliststatesty = set of recordliststatety;

 trecordlist = class(tnullinterfacedobject)
  private
   fcapacity: integer;
   procedure checkindex(const index: integer);
   procedure checkcapacity;
   procedure setcapacity(Value: integer);
   procedure inccount;
  protected
   frecordsize: integer;
   fcount: integer;
   fdata: pchar;
   fstate: recordliststatesty;
   procedure setcount(const Value: integer);
   procedure setitem(const index: integer; const source);
   procedure getitem(const index: integer; out dest);
   function add(const source): integer;
   procedure insert(const source; const index: integer);
   function getitempo(const index: integer): pointer;
       //nil if index < 0
       //will be invalid after capacity change!
   function isempty(var item): boolean; virtual;
   procedure finalizerecord(var item); virtual;
   procedure initializerecord(var item); virtual;
   procedure copyrecord(var item); virtual;
   procedure change; virtual;
   property recordsize: integer read frecordsize;
  public
   constructor create(const arecordsize: integer; const aoptions: recordliststatesty = []);
   destructor destroy; override;
   procedure assign(const source: trecordlist);
   function datapo: pointer;
   function dataend: pointer; //after datablock
   function newitem: pointer; virtual;
   function newitems(const acount: integer): pointer; virtual;
   procedure deletelast;
   procedure pack;
   procedure clear; virtual;
   procedure delete(const index: integer); //indexes < 0 are ignored
   property count: integer read fcount write setcount;
   property capacity: integer read fcapacity write setcapacity;
 end;

 torderedrecordlist = class(trecordlist)
  private
   fsorted: boolean;
   procedure setsorted(const avalue: boolean);
//   procedure quicksort(var arangelist: integerarty; L, R: Integer);
   procedure sort;
  protected
   fcomparefunc: sortcomparemethodty;
   function internalfind(const item; out index: integer): boolean;
           //true if exact else next bigger
           //for comp: l is item, r are tablevalues
   function add(const source): integer;
   function indexof(const item): integer;
   function deleteitem(const item): integer;
   function getcomparefunc: sortcomparemethodty; virtual; abstract;
  public
   function newitem: pointer; override;
   function newitems(const acount: integer): pointer; override;
   property sorted: boolean read fsorted write setsorted;
 end;

 trecordmap = class(trecordlist)
  private
   procedure setorder(const avalue: integer);
  protected
   fcomparefuncs: sortcomparemethodarty;
   findexes: pointerararty;
   fhasindex: boolean;
   forder: integer;
   procedure setitem(const index: integer; const source);
   procedure getitem(const index: integer; out dest);
   function internalgetitempo(const aorder: integer;
                                     const index: integer): pointer;
   function getitempo(const index: integer): pointer;
       //nil if index < 0
       //will be invalid after capacity change!
   procedure sort(const aindexnum: integer);
   function internalfind(const aindexnum: integer; const item; 
                            out aindex: integer; out adata: pointer): boolean;
           //true if exact else next bigger
           //for comp: l is item, r are tablevalues
   procedure change; override;
   procedure setcomparefuncs(const afuncs: array of sortcomparemethodty);
  public
   constructor create(const arecordsize: integer;
                     const aoptions: recordliststatesty = []);
   property order: integer read forder write setorder default -1;
 end;
 
 tpointerlist = class(tnullinterfacedobject)
  private
   fringpointer: integer; //for queue
   function getcapacity: integer;
   procedure inccount;
  protected
   fitems: pointerarty;
   fcount: integer;
   procedure normalizering;
   procedure setitems(index: integer; const Value: pointer);
   function getitems(index: integer): pointer;
   procedure checkindex(var index: integer); virtual;
   procedure setcapacity(Value: integer); virtual;
  public
   destructor destroy; override;
   procedure clear; virtual;
   function datapo: ppointeraty;
   function add(const value: pointer): integer;
   function remove(const item: pointer): integer;
   function delete(index: integer): pointer; virtual;
   procedure insert(index: integer; const value: pointer); virtual;
   function indexof(const item: pointer): integer;
   function extract(const item: pointer): pointer;
   
   procedure order(const sourceorderlist: integerarty);
   procedure reorder(const destorderlist: integerarty);
   procedure sort(compare: arraysortcomparety); overload;
   procedure sort(compare: arraysortcomparety; out indexlist: integerarty); overload;
   
   property items[index: integer]: pointer read getitems write setitems; default;
   property count: integer read fcount;
   property capacity: integer read getcapacity write setcapacity;
 end;

 tpointerqueue = class(tpointerlist)
  private
   fmaxcount: integer;
   procedure setmaxcount(const Value: integer);
  protected
   fnofinalize: integer;
   procedure checkindex(var index: integer); override;
   procedure setcapacity(value: integer); override;
   procedure finalizeitem(var item: pointer); virtual;
  public
   function datapo: ppointeraty; virtual;
   procedure clear; override;
   function delete(index: integer): pointer; override;
   function add(const value: pointer): integer;
   function indexof(const item: pointer): integer;
   //-1 if not found
   procedure insert(index: integer; const value: pointer); override;
   function getfirst: pointer;
   function getlast: pointer;
   property maxcount: integer read fmaxcount write setmaxcount;
 end;

 tmethodlist = class(trecordlist)
  private
   function getitems(index: integer): tmethod;
   procedure setitems(index: integer; const avalue: tmethod);
  protected
   factitem: integer;
  public
   constructor create;
   function indexof(const value: tmethod): integer;
   function add(const value: tmethod): integer;
          //creates no duplicates
   function remove(const value: tmethod): integer;
   property items[index: integer]: tmethod read getitems
                                          write setitems; default;
 end;

 tobjectqueue = class(tpointerqueue)
  private
  protected
   function getitems(index: integer): tobject;
   procedure setitems(index: integer; const Value: tobject);
   procedure finalizeitem(var item: pointer); override;
  public
   ownsobjects: boolean;
   constructor create(aownsobjects: boolean);
   procedure add(value: tobject);
   procedure insert(const index: integer; const value: tobject); reintroduce;
   function getfirst: tobject;
   function getlast: tobject;
   property items[index: integer]: tobject read getitems write setitems;
 end;

 tlockedobjectqueue = class(tobjectqueue)
  private
   fmutex: mutexty;
   function getitems(index: integer): tobject;
   procedure setitems(index: integer; const Value: tobject);
  protected
   procedure lock;
   procedure unlock;
   procedure setcapacity(Value: integer); override;
  public
   constructor create(aownsobjects: boolean);
   destructor destroy; override;
              //items below are thread safe
   procedure add(value: tobject);
   procedure insert(const index: integer; const value: tobject); reintroduce;
   function getfirst: tobject;
   function getlast: tobject;
   property items[index: integer]: tobject read getitems write setitems;
 end;
 
 nameidty = integer;

 indexednameinfoty = record
  name: string;
  id: nameidty
 end;
 pindexednameinfoty = ^indexednameinfoty;
 indexednameinfoaty = array[0..0] of indexednameinfoty;
 pindexednameinfoaty = ^indexednameinfoaty;

 tindexednamelist = class(torderedrecordlist)
  private
   fidnames: stringarty;
   function comp(const l,r): integer;
  protected
   procedure finalizerecord(var item); override;
   procedure copyrecord(var item); override;
   function getcomparefunc: sortcomparemethodty; override;
  public
   constructor create;
   function add(const avalue: string): integer;
         //returns id
   function find(const avalue: string): integer;
         //returns id, -1 if not found
   function getname(const id: integer): string;
 end;

 mseindexednameinfoty = record
  name: msestring;
  id: nameidty
 end;
 pmseindexednameinfoty = ^mseindexednameinfoty;
 mseindexednameinfoaty = array[0..0] of mseindexednameinfoty;
 pmseindexednameinfoaty = ^mseindexednameinfoaty;

 tmseindexednamelist = class(torderedrecordlist)
  private
   fidnames: msestringarty;
   function comp(const l,r): integer;
  protected
   procedure finalizerecord(var item); override;
   procedure copyrecord(var item); override;
   function getcomparefunc: sortcomparemethodty; override;
  public
   constructor create;
   function add(const avalue: msestring): integer; virtual;
         //returns id
   function find(const avalue: msestring): integer; virtual;
         //returns id, -1 if not found
   function getname(const id: integer): msestring;
 end;

 tindexedfilenamelist = class(tmseindexednamelist)
  public
   function add(const avalue: msestring): integer; override;
         //returns id
   function find(const avalue: msestring): integer; override;
         //returns id, -1 if not found
 end;
 
implementation
uses
 rtlconsts,msebits,msedatalist,msesysintf1,msesysintf;
const
 growstep = 32;

{
procedure QuickSort1(var indexlist: array of integer; SortList: PPointerList; L, R: Integer;
                       SCompare: TListSortCompare);
                       //bei compareresult = 0 wird urspruengliche ordnung beibehalten
var
  I, J: Integer;
  P, T: Pointer;
  pivotindex: integer;
  pivotoffset: integer;
  int1: integer;
label
 1,2;
begin
  repeat
    I := L;
    J := R;
    pivotindex:= (L + R) shr 1;
    pivotoffset:= indexlist[pivotindex];
    P := SortList^[pivotindex];
    repeat
1:
      int1:= SCompare(SortList^[I], P);
      if int1 = 0 then begin
       int1:= indexlist[i]-pivotoffset;
      end;
      if int1 < 0 then begin
       inc(i);
       goto 1;
      end;

//      while SCompare(SortList^[I], P) < 0 do
//        Inc(I);
2:
      int1:= SCompare(SortList^[J], P);
      if int1 = 0 then begin
       int1:= indexlist[j]-pivotoffset;
      end;
      if int1 > 0 then begin
       dec(j);
       goto 2;
      end;
//      while SCompare(SortList^[J], P) > 0 do
//        Dec(J);
      if I <= J then
      begin
        T := SortList^[I];
        int1:= indexlist[i];
        SortList^[I] := SortList^[J];
        indexlist[I] := indexList[J];
        SortList^[J] := T;
        indexlist[J] := int1;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then
      QuickSort1(indexlist,SortList, L, J, SCompare);
    L := I;
  until I >= R;
end;

procedure QuickSortmse(SortList: PPointerList; count: integer;
                       SCompare: TListSortCompare; out indexlist: integerarty);
       //on compareresult = 0 order remains unchanged
var
 int1: integer;
begin
 setlength(indexlist,count);
 if count > 0 then begin
  for int1:= 0 to count -1 do begin
   indexlist[int1]:= int1;
  end;
  quicksort1(indexlist,sortlist,0,count-1,scompare);
 end;
end;
}
{ tlistmse }
{
procedure tlistmse.Sort(Compare: TListSortCompare);
var
 indexlist: integerarty;
begin
 sort(compare,indexlist)
end;

procedure tlistmse.Sort(Compare: TListSortCompare; out indexlist: integerarty);
begin
 if (List <> nil) and (Count > 0) then begin
  QuickSortmse(List, Count, Compare,indexlist);
 end;
end;
}

{ trecordlist }

constructor trecordlist.create(const arecordsize: integer; 
                                const aoptions: recordliststatesty = []);
begin
 frecordsize:= arecordsize;
 fstate:= aoptions;
end;

destructor trecordlist.destroy;
begin
 clear;
 if fdata <> nil then begin
  freemem(fdata);
 end;
 inherited;
end;

procedure trecordlist.assign(const source: trecordlist);
var
 int1: integer;
 po1: pchar;
begin
 if (rels_needsinitialize in fstate) or (source.ClassType <> self.ClassType) then begin
  raise exception.Create('Can not assign');
 end;
 clear;
 count:= source.count;
 move(source.datapo^,fdata^,count*frecordsize);
 if rels_needscopy in fstate then begin
  po1:= fdata;
  for int1:= 0 to fcount - 1 do begin
   copyrecord(po1^);
   inc(po1,frecordsize);
  end;
 end;
end;

function trecordlist.datapo: pointer;
begin
 result:= fdata;
end;

function trecordlist.dataend: pointer;
begin
 result:= fdata+fcount*frecordsize;
end;

function trecordlist.newitem: pointer;
begin
 inccount;
 result:= getitempo(fcount - 1);
end;

function trecordlist.newitems(const acount: integer): pointer;
var
 int1: integer;
begin
 if acount > 0 then begin
  int1:= fcount;
  count:= count + acount;
  result:= fdata + int1 * frecordsize;
 end
 else begin
  result:= nil;
 end;
end;

procedure trecordlist.deletelast;
begin
 delete(fcount - 1);
end;

procedure trecordlist.setcapacity(Value: integer);
begin
 if value < fcount then begin
  value:= fcount;
 end;
 if fcapacity <> value then begin
  fcapacity := Value;
  reallocmem(fdata,value*frecordsize);
 end;
end;

procedure trecordlist.checkcapacity;
begin
 if fcapacity > fcount + fcount div 4 + 2*growstep then begin
  capacity:= fcount + fcount div 8 + growstep;
 end;
end;

procedure trecordlist.setcount(const Value: integer);
var
 int1: integer;
 po1: pchar;
begin
 if value <> fcount then begin
  if value > fcount then begin
   if fcapacity < value then begin
    capacity:= value + value div 8 + growstep;
   end;
   fillchar((fdata+fcount*frecordsize)^,(value-fcount)*frecordsize,0);
   if rels_needsinitialize in fstate then begin
    po1:= fdata + fcount * frecordsize;
    for int1:= fcount to value - 1 do begin
     initializerecord(po1^);
     inc(po1,frecordsize);
    end;
   end;
   fcount:= value;
  end
  else begin
   if rels_needsfinalize in fstate then begin
    po1:= fdata + value * frecordsize;
    for int1:= value to fcount - 1 do begin
     finalizerecord(po1^);
     inc(po1,frecordsize);
    end;
   end;
   fcount:= value;
   checkcapacity;
  end;
  change;
 end;
end;

procedure trecordlist.inccount;
begin
 count:= fcount + 1;
 {
 inc(fcount);
 if fcapacity < fcount then begin
  capacity:= fcount + fcount div 8 + growstep;
 end;
}
end;

function trecordlist.add(const source): integer;
var
 po1: pointer;
begin
 result:= fcount;
 inccount;
 po1:= fdata + result * frecordsize;
 move(source,po1^,frecordsize);
 if rels_needscopy in fstate then begin
  copyrecord(po1^);
 end;
end;

procedure trecordlist.insert(const source; const index: integer);
var
 po1: pchar;
begin
 inccount;
 po1:= fdata+index*frecordsize;
 move(po1^,(po1+frecordsize)^,(count-index-1)*frecordsize);
 move(source,po1^,frecordsize);
 if rels_needscopy in fstate then begin
  copyrecord(po1^);
 end;
end;

procedure trecordlist.checkindex(const index: integer);
begin
 if (index < 0) or (index >= fcount) then begin
  tlist.error(slistindexerror,index);
 end;
end;

procedure trecordlist.getitem(const index: integer; out dest);
var
 po1: pchar;
begin
 checkindex(index);
 po1:= fdata+index*frecordsize;
 move(po1^,dest,frecordsize);
 if rels_needscopy in fstate then begin
  copyrecord(po1^);
 end;
end;

function trecordlist.getitempo(const index: integer): pointer;
//var
// int1: integer;
begin
 if index < 0 then begin
  result:= nil;
 end
 else begin
//  int1:= index;
  checkindex(index);
  result:= fdata + index * frecordsize;
 end;
end;

procedure trecordlist.setitem(const index: integer; const source);
var
 po1: pchar;
begin
 checkindex(index);
 po1:= fdata+index*frecordsize;
 if rels_needsfinalize in fstate then begin
  finalizerecord(po1^);
 end;
 move(source,(po1)^,frecordsize);
 if rels_needscopy in fstate then begin
  copyrecord(po1^);
 end;
 change;
end;

procedure trecordlist.clear;
begin
 count:= 0;
end;

procedure trecordlist.delete(const index: integer);
begin
 if index >= 0 then begin
  checkindex(index);
  if rels_needsfinalize in fstate then begin
   finalizerecord((fdata+index*frecordsize)^);
  end;
  if index < count-1 then begin
   move((fdata+(index+1)*frecordsize)^,(fdata+index*frecordsize)^,
         (fcount-index-1)*frecordsize);
  end;
  fcount:= fcount-1;
  checkcapacity;
 end;
end;

function trecordlist.isempty(var item): boolean;
begin
 result:= iszero(@item,frecordsize);
end;

procedure trecordlist.pack;
var
 po1,po2,po3: pchar;
 int1,int2: integer;
begin
 if fcount <> 0 then begin
  getmem(po1,fcount*frecordsize);
  po3:= po1;
  po2:= fdata;
  int2:= 0;
  for int1:= 0 to fcount -1 do begin
   if not isempty(po2^) then begin
    move(po2^,po3^,frecordsize);
    inc(int2);
    inc(po3,frecordsize);
   end;
   inc(po2,frecordsize);
  end;
  freemem(fdata);
  fdata:= po1;
  fcount:= int2;
  fcapacity:= fcount;
  if fcount > 0 then begin
   reallocmem(fdata,fcount*frecordsize);
  end
  else begin
   freemem(fdata);
   fdata:= nil;
  end;
  change;
 end;
end;

procedure trecordlist.initializerecord(var item);
begin
 //dummy
end;

procedure trecordlist.finalizerecord(var item);
begin
 //dummy
end;

procedure trecordlist.copyrecord(var item);
begin
 //dummy
end;

procedure trecordlist.change;
begin
 //dummy
end;

{ torderedrecordlist }

function torderedrecordlist.add(const source): integer;
begin
 if fsorted then begin
  internalfind(source,result);
  insert(source,result);
 end
 else begin
  result:= inherited add(source);
 end;
end;

procedure torderedrecordlist.setsorted(const avalue: boolean);
begin
 if avalue <> fsorted then begin
  if avalue then begin
   sort;
  end;
  fsorted:= avalue;
 end;
end;
(*
procedure torderedrecordlist.quicksort(var arangelist: integerarty; L, R: Integer);
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
   pp:= fdata+p*frecordsize;
   repeat
    repeat
     int1:= fcomparefunc((fdata+arangeList[I]*frecordsize)^, pp^);
     if int1 = 0 then begin
      int1:= arangelist[i] - p;
     end;
     if int1 >= 0 then break;
     inc(i);
    until false;
    repeat
     int1:= fcomparefunc((fdata+arangeList[J]*frecordsize)^, pp^);
     if int1 = 0 then begin
      int1:= arangelist[j] - p;
     end;
     if int1 <= 0 then break;
     dec(j);
    until false;
//       while (sortfunc(List.items[I], P,self) < 0) do Inc(I);
//       while (sortfunc(List.items[J], P,self) > 0) do Dec(J);
    if I <= J then
    begin
     if i <> j then begin
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
*)
procedure torderedrecordlist.sort;


var
 arangelist: integerarty;
 int1: integer;
 po1,po2: pchar;
begin
 fcomparefunc:= getcomparefunc();
 if fcount > 0 then begin
//  setlength(arangelist,fcount);
//  for int1:= 0 to high(arangelist) do begin
//   arangelist[int1]:= int1;
//  end;
//  quicksort(arangelist,0,fcount-1);
  mergesort(fdata,frecordsize,fcount,fcomparefunc,arangelist);
  getmem(po1,fcount*frecordsize);
  po2:= po1;
  for int1:= 0 to high(arangelist) do begin
   move((fdata+arangelist[int1]*frecordsize)^,po2^,frecordsize);
   inc(po2,frecordsize);
  end;
  freemem(fdata);
  fdata:= po1;
  fcapacity:= fcount;
 end;
end;

function torderedrecordlist.internalfind(const item; out index: integer): boolean;
var
 ilo,ihi:integer;
 int1,int2: integer;
// bo1: boolean;
begin
 sorted:= true;
 index:= fcount;
 result:= false;
 if fcount > 0 then begin
  ilo:= 0;
  ihi:= fcount - 1;
//  bo1:= false;
  while true do begin
   int1:= (ilo + ihi) div 2;
   int2:= fcomparefunc(item,(fdata+int1*frecordsize)^);
//   if int2 = 0 then begin
//    index:= int1;
//    result:= true;
//    break;
//   end
//   else begin
    if int2 >= 0 then begin //item <= pivot
     if int2 = 0 then begin
      result:= true; //found
     end;
     if ihi = ilo then begin
      index:= ihi + 1;
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
      index:= ihi;
      break;
     end;
     ihi:= int1;
//    end;
   end;
  end;
  if result then begin
   dec(index);
  end;
 end;
end;

function torderedrecordlist.indexof(const item): integer;
begin
 if not internalfind(item,result) then begin
  result:= -1;
 end;
end;

function torderedrecordlist.deleteitem(const item): integer;
begin
 result:= indexof(item);
 if result >= 0 then begin
  delete(result);
 end;
end;

function torderedrecordlist.newitem: pointer;
begin
 fsorted:= false;
 result:= inherited newitem;
end;

function torderedrecordlist.newitems(const acount: integer): pointer;
begin
 fsorted:= false;
 result:= inherited newitems(acount);
end;

{ tpointerlist }

destructor tpointerlist.destroy;
begin
 clear;
 inherited;
end;
function tpointerlist.getcapacity: integer;
begin
 result:= length(fitems);
end;

procedure tpointerlist.setcapacity(Value: integer);
begin
 if value < fcount then begin
  value:= fcount;
 end;
 setlength(fitems,value);
end;

procedure tpointerlist.checkindex(var index: integer);
begin
 if (index < 0) or (index >= fcount) then begin
  tlist.error(slistindexerror,index);
 end;
end;

procedure tpointerlist.setitems(index: integer; const Value: pointer);
begin
 checkindex(index);
 fitems[index]:= value;
end;

function tpointerlist.getitems(index: integer): pointer;
begin
 checkindex(index);
 result:= fitems[index];
end;

procedure tpointerlist.normalizering;
var
 ar1: pointerarty;
 int1: integer;
begin
 if fringpointer <> 0 then begin
  if fringpointer + fcount > length(fitems) then begin //2 pieces
   setlength(ar1,count);
   int1:= length(fitems)-fringpointer;
   move(fitems[fringpointer],ar1[0],
        int1*sizeof(pointer));
   move(fitems[0],ar1[int1],
        (fcount-int1)*sizeof(pointer));
   fitems:= ar1;
  end
  else begin
   move(fitems[fringpointer],fitems[0],fcount*sizeof(pointer));
  end;
  fringpointer:= 0;
 end;
end;

procedure tpointerlist.inccount;
begin
 if fcount >= length(fitems) then begin
  capacity:= fcount + fcount div 4 + 32;
 end;
 inc(fcount);
end;

function tpointerlist.add(const value: pointer): integer;
begin
 inccount;
 result:= fcount - 1;
 setitems(result,value);
end;

procedure tpointerlist.clear;
begin
 fcount:= 0;
end;

function tpointerlist.indexof(const item: pointer): integer;
var
 int1: integer;
begin
 result:= -1;
 for int1:= 0 to fcount - 1 do begin
  if fitems[int1] = item then begin
   result:= int1;
   exit;
  end;
 end;
end;

function tpointerlist.delete(index: integer): pointer;
begin
 checkindex(index);
 result:= fitems[index];
 move(fitems[index+1],fitems[index],(fcount-index-1)*sizeof(pointer));
 dec(fcount);
end;

function tpointerlist.remove(const item: pointer): integer;
begin
 result:= indexof(item);
 if result >= 0 then begin
  delete(result);
 end;
end;

procedure tpointerlist.insert(index: integer; const value: pointer);
begin
 if index = fcount then begin
  add(value);
 end
 else begin
  checkindex(index);
  inccount;
  move(fitems[index],fitems[index+1],(fcount-index-1)*sizeof(pointer));
  fitems[index]:= value;
 end;
end;

function tpointerlist.extract(const item: pointer): pointer;
var
 int1: integer;
begin
 int1:= indexof(item);
 if int1 >= 0 then begin
  result:= fitems[int1];
  delete(int1);
 end
 else begin
  result:= nil;
 end;
end;

procedure tpointerlist.order(const sourceorderlist: integerarty);
var
 int1: integer;
 ar1: pointerarty;
begin
 normalizering;
 allocuninitedarray(length(fitems),sizeof(pointer),ar1);
 for int1:= 0 to fcount - 1 do begin
  ar1[int1]:= fitems[sourceorderlist[int1]];
 end;
 fitems:= ar1;
end;

procedure tpointerlist.reorder(const destorderlist: integerarty);
var
 int1: integer;
 ar1: pointerarty;
begin
 normalizering;
 allocuninitedarray(length(fitems),sizeof(pointer),ar1);
 for int1:= 0 to fcount - 1 do begin
  ar1[destorderlist[int1]]:= fitems[int1];
 end;
 fitems:= ar1;
end;

procedure tpointerlist.sort(compare: arraysortcomparety;
                    out indexlist: integerarty);
begin
 mergesortarray(fitems,sizeof(pointer),fcount,compare,indexlist,false);
 order(indexlist);
end;

procedure tpointerlist.sort(compare: arraysortcomparety);
var
 indexlist: integerarty;
begin
 sort(compare,indexlist);
end;

function tpointerlist.datapo: ppointeraty;
begin
 result:= ppointeraty(pointer(fitems));
end;

{ tpointerqueue }

procedure tpointerqueue.checkindex(var index: integer);
begin
 inherited;
 inc(index,fringpointer);
 if index >= length(fitems) then begin
  dec(index,length(fitems));
 end;
end;

function tpointerqueue.delete(index: integer): pointer;
begin
 normalizering;
 result:= inherited delete(index);
 if fnofinalize = 0 then begin
  finalizeitem(result);
 end;
end;

procedure tpointerqueue.clear;
var
 int1: integer;
begin
 normalizering;
 if fnofinalize = 0 then begin
  for int1:= 0 to fcount - 1 do begin
   finalizeitem(fitems[int1]);
  end;
 end;
 inherited;
end;

procedure tpointerqueue.insert(index: integer; const value: pointer);
begin
 normalizering;
 inherited;
end;

function tpointerqueue.getfirst: pointer;
begin
 if fcount = 0 then begin
  result:= nil;
 end
 else begin
  result:= fitems[fringpointer];
  dec(fcount);
  inc(fringpointer);
  if fringpointer >= length(fitems) then begin
   dec(fringpointer,length(fitems));
  end;
 end;
end;

function tpointerqueue.getlast: pointer;
begin
 if fcount = 0 then begin
  result:= nil;
 end
 else begin
  result:= items[fcount-1];
  dec(fcount);
 end;
end;

function tpointerqueue.indexof(const item: pointer): integer;
var
 int1: integer;
begin
 result:= -1;
 for int1:= fringpointer to fcount - 1 do begin
  if int1 >= length(fitems) then begin
   break;
  end;
  if fitems[int1] = item then begin
   result:= int1;
   exit;
  end;
 end;
 for int1:= 0 to count - (length(fitems) - fringpointer) - 1 do begin
  if fitems[int1] = item then begin
   result:= int1;
   exit;
  end;
 end;
end;

procedure tpointerqueue.setcapacity(Value: integer);
begin
 normalizering;
 inherited;
end;

function tpointerqueue.add(const value: pointer): integer;
begin
 if (fmaxcount <> 0) and (fcount >= fmaxcount) then begin
  finalizeitem(fitems[fringpointer]);
  getfirst;
 end;
 result:= inherited add(value);
end;

procedure tpointerqueue.setmaxcount(const Value: integer);
var
 int1: integer;
begin
 fmaxcount := Value;
 if (fmaxcount <> 0) and (fcount > fmaxcount) then begin
  normalizering;
  for int1:= 0 to fcount-fmaxcount-1 do begin
   finalizeitem(fitems[int1]);
  end;
  fringpointer:= fcount-fmaxcount;
  fcount:= fmaxcount;
  capacity:= fmaxcount;
 end;
end;

procedure tpointerqueue.finalizeitem(var item: pointer);
begin
 //dummy
end;

function tpointerqueue.datapo: ppointeraty;
begin
 normalizering;
 result:= inherited datapo;
end;

{ tobjectqueue }

procedure tobjectqueue.finalizeitem(var item: pointer);
begin
 if ownsobjects then begin
  tobject(item).Free;
  item:= nil;
 end;
end;

function tobjectqueue.getitems(index: integer): tobject;
begin
 result:= tobject(inherited getitems(index));
end;

procedure tobjectqueue.setitems(index: integer; const Value: tobject);
begin
 inherited setitems(index,value);
end;

function tobjectqueue.getfirst: tobject;
begin
 result:= tobject(inherited getfirst);
end;

function tobjectqueue.getlast: tobject;
begin
 result:= tobject(inherited getlast);
end;

procedure tobjectqueue.add(value: tobject);
begin
 inherited add(value);
end;

procedure tobjectqueue.insert(const index: integer; const value: tobject);
begin
 inherited insert(index,value);
end;

constructor tobjectqueue.create(aownsobjects: boolean);
begin
 ownsobjects:= aownsobjects;
 inherited create;
end;

{ tmethodlist }

function tmethodlist.add(const value: tmethod): integer;
begin
 result:= indexof(value);
 if result < 0 then begin
  result:= inherited add(value);
 end;
end;

constructor tmethodlist.create;
begin
 inherited create(sizeof(tmethod));
end;

function tmethodlist.indexof(const value: tmethod): integer;
var
 po1: pmethod;
 int1: integer;

begin
 result:= -1;
 po1:= pmethod(fdata);
 for int1:= 0 to fcount - 1 do begin
  if issamemethod(value,po1^) then begin
   result:= int1;
   break;
  end;
  inc(po1);
 end;
end;

function tmethodlist.remove(const value: tmethod): integer;
begin
 result:= indexof(value);
 if result >= 0 then begin
  delete(result);
  if result <= factitem then begin
   dec(factitem);
  end;
 end;
end;

function tmethodlist.getitems(index: integer): tmethod;
begin
 checkindex(index);
 result:= pmethod(fdata+index*sizeof(tmethod))^;
end;

procedure tmethodlist.setitems(index: integer; const avalue: tmethod);
begin
 checkindex(index);
 pmethod(fdata+index*sizeof(tmethod))^:= avalue;
end;

{ tindexednamelist }

constructor tindexednamelist.create;
begin
 inherited create(sizeof(indexednameinfoty),[rels_needsfinalize,rels_needscopy]);
end;

function tindexednamelist.add(const avalue: string): integer;
var
 info: indexednameinfoty;
begin
 info.name:= avalue;
 result:= find(avalue);
 if result < 0 then begin
  additem(fidnames,avalue);
  info.id:= high(fidnames);
  result:= info.id;
  inherited add(info);
 end;
end;

procedure tindexednamelist.finalizerecord(var item);
begin
 finalize(indexednameinfoty(item));
end;

procedure tindexednamelist.copyrecord(var item);
begin
 with mseindexednameinfoty(item) do begin
  stringaddref(name);
 end;
end;

function tindexednamelist.comp(const l,r): integer;
var
 int1: integer;
begin
 result:= (length(indexednameinfoty(l).name) -
             length(indexednameinfoty(r).name)) shl 16;
 if result = 0 then begin
  for int1:= length(indexednameinfoty(l).name) - 1 downto 0 do begin
   result:= integer(pcharaty(indexednameinfoty(l).name)^[int1]) -
            integer(pcharaty(indexednameinfoty(r).name)^[int1]);
   if result <> 0 then begin
    break;
   end;
  end;
 end;
end;

function tindexednamelist.getcomparefunc: sortcomparemethodty;
begin
 result:= {$ifdef FPC}@{$endif}comp;
end;

function tindexednamelist.find(const avalue: string): integer;
var
 info: indexednameinfoty;
 int1: integer;
begin
 info.name:= avalue;
 if internalfind(info,int1) then begin
  result:= pindexednameinfoaty(datapo)^[int1].id;
 end
 else begin
  result:= -1;
 end;
end;

function tindexednamelist.getname(const id: integer): string;
begin
 if (id < 0) or (id > high(fidnames)) then begin
  result:= '';
 end
 else begin
  result:= fidnames[id];
 end;
end;


{ tmseindexednamelist }

constructor tmseindexednamelist.create;
begin
 inherited create(sizeof(mseindexednameinfoty),[rels_needsfinalize,rels_needscopy]);
end;

function tmseindexednamelist.add(const avalue: msestring): integer;
var
 info: mseindexednameinfoty;
begin
 info.name:= avalue;
 result:= find(avalue);
 if result < 0 then begin
  additem(fidnames,avalue);
  info.id:= high(fidnames);
  result:= info.id;
  inherited add(info);
 end;
end;

procedure tmseindexednamelist.finalizerecord(var item);
begin
 finalize(mseindexednameinfoty(item));
end;

procedure tmseindexednamelist.copyrecord(var item);
begin
 with mseindexednameinfoty(item) do begin
  stringaddref(name);
 end;
end;

function tmseindexednamelist.comp(const l,r): integer;
var
 int1: integer;
begin
 result:= (length(mseindexednameinfoty(l).name) -
             length(mseindexednameinfoty(r).name)) shl 16;
 if result = 0 then begin
  for int1:= length(mseindexednameinfoty(l).name) - 1 downto 0 do begin
   result:= integer(pmsecharaty(mseindexednameinfoty(l).name)^[int1]) -
            integer(pmsecharaty(mseindexednameinfoty(r).name)^[int1]);
   if result <> 0 then begin
    break;
   end;
  end;
 end;
end;

function tmseindexednamelist.getcomparefunc: sortcomparemethodty;
begin
 result:= {$ifdef FPC}@{$endif}comp;
end;

function tmseindexednamelist.find(const avalue: msestring): integer;
var
 info: mseindexednameinfoty;
 int1: integer;
begin
 info.name:= avalue;
 if internalfind(info,int1) then begin
  result:= pmseindexednameinfoaty(datapo)^[int1].id;
 end
 else begin
  result:= -1;
 end;
end;

function tmseindexednamelist.getname(const id: integer): msestring;
begin
 if (id < 0) or (id > high(fidnames)) then begin
  result:= '';
 end
 else begin
  result:= fidnames[id];
 end;
end;

{ tindexedfilenamelist }

function tindexedfilenamelist.add(const avalue: msestring): integer;
begin
 if sys_filesystemiscaseinsensitive then begin
  result:= inherited add(mselowercase(avalue));
 end
 else begin
  result:= inherited add(avalue);
 end;
end;

function tindexedfilenamelist.find(const avalue: msestring): integer;
begin
 if sys_filesystemiscaseinsensitive then begin
  result:= inherited find(mselowercase(avalue));
 end
 else begin
  result:= inherited find(avalue);
 end;
end;

{ tlockedobjectqueue }

constructor tlockedobjectqueue.create(aownsobjects: boolean);
begin
 sys_mutexcreate(fmutex);
 inherited;
end;

destructor tlockedobjectqueue.destroy;
begin
 inherited;
 sys_mutexdestroy(fmutex);
end;

function tlockedobjectqueue.getitems(index: integer): tobject;
begin
 lock;
 result:= inherited getitems(index);
 unlock;
end;

procedure tlockedobjectqueue.setitems(index: integer; const Value: tobject);
begin
 lock;
 inherited setitems(index,value);
 unlock;
end;

procedure tlockedobjectqueue.lock;
begin
 sys_mutexlock(fmutex);
end;

procedure tlockedobjectqueue.unlock;
begin
 sys_mutexunlock(fmutex);
end;

procedure tlockedobjectqueue.setcapacity(Value: integer);
begin
 lock;
 inherited;
 unlock;
end;

procedure tlockedobjectqueue.add(value: tobject);
begin
 lock;
 inherited add(value);
 unlock;
end;

procedure tlockedobjectqueue.insert(const index: integer; const value: tobject);
begin
 lock;
 inherited insert(index,value);
 unlock;
end;

function tlockedobjectqueue.getfirst: tobject;
begin
 lock;
 result:= inherited getfirst;
 unlock;
end;

function tlockedobjectqueue.getlast: tobject;
begin
 lock;
 result:= inherited getlast;
 unlock;
end;

{ trecordmap }

constructor trecordmap.create(const arecordsize: integer;
                                 const aoptions: recordliststatesty = []);
begin
 forder:= -1;
 inherited;
end;

procedure trecordmap.change;
var
 int1: integer;
begin
 if fhasindex then begin
  for int1:= 0 to high(findexes) do begin
   findexes[int1]:= nil;
  end;
  fhasindex:= false;
 end;
end;

procedure trecordmap.setcomparefuncs(const afuncs: array of sortcomparemethodty);
var
 int1: integer;
begin
 if forder > high(afuncs) then begin
  forder:= -1;
 end;
 change;
 setlength(findexes,length(afuncs));
 setlength(fcomparefuncs,length(afuncs));
 for int1:= 0 to high(fcomparefuncs) do begin
  fcomparefuncs[int1]:= afuncs[int1];
 end;
end;

procedure trecordmap.sort(const aindexnum: integer);
begin
 mergesortpointer(fdata,frecordsize,fcount,fcomparefuncs[aindexnum],
                                                      findexes[aindexnum]);
 fhasindex:= true;
end;

function trecordmap.internalfind(const aindexnum: integer; const item;
               out aindex: integer; out adata: pointer): boolean;
begin
 result:= false;
 aindex:= -1;
 adata:= nil;
 if fcount > 0 then begin
  if findexes[aindexnum] = nil then begin
   sort(aindexnum);
  end;
  result:= findarrayitem(item,findexes[aindexnum],
                                fcomparefuncs[aindexnum],aindex);
  if aindex < fcount then begin
   adata:= findexes[aindexnum][aindex];
  end;
 end;
end;

function trecordmap.internalgetitempo(const aorder: integer;
                                             const index: integer): pointer;
begin
 checkindex(index);
 if aorder >= 0 then begin
  if findexes[aorder] = nil then begin
   sort(aorder);
  end;
  result:= findexes[aorder][index];
 end
 else begin
  result:= fdata + index * frecordsize;
 end;
end;

procedure trecordmap.setitem(const index: integer; const source);
var
 po1: pointer;
begin
 po1:= internalgetitempo(forder,index);
 if rels_needsfinalize in fstate then begin
  finalizerecord(po1^);
 end;
 move(source,(po1)^,frecordsize);
 if rels_needscopy in fstate then begin
  copyrecord(po1^);
 end;
 change;
end;

procedure trecordmap.getitem(const index: integer; out dest);
var
 po1: pointer;
begin
 po1:= internalgetitempo(forder,index);
 move(po1^,dest,frecordsize);
 if rels_needscopy in fstate then begin
  copyrecord(po1^);
 end;
end;

function trecordmap.getitempo(const index: integer): pointer;
begin
 result:= nil;
 if index >= 0 then begin
  result:= internalgetitempo(forder,index);
 end;
end;

procedure trecordmap.setorder(const avalue: integer);
begin
 if (avalue < -1) or (avalue > high(findexes)) then begin
  raise exception.create('Invalid order index '+inttostr(avalue)+'.');
 end;
 forder:= avalue;
end;

end.





