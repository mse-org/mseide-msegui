{ MSEgui Copyright (c) 2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mselinklist;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes;

type

 linkheaderty = record
  next: ptruint; //offset in data
 end;
 plinkheaderty = ^linkheaderty;
 linkinfoty = record
  header: linkheaderty;
  data: record
  end;
 end;

 doublelinkheaderty = record
  lh: linkheaderty;
  prev: ptruint; //offset in data
 end;
 pdoublelinkheaderty = ^doublelinkheaderty;
 doublelinkinfoty = record
  header: doublelinkheaderty;
  data: record
  end;
 end;

 tlinklist = class(tobject)
  private
   fcapacity: ptruint;
   flast: ptruint;
   fdeleted: ptruint;
   fcount: integer;
   function getcapacity: integer;
   procedure setcapacity(const avalue: integer);
  protected
   fdata: pointer; //dummy item at 0
   fheadersize: integer;
   fitemsize: integer;
   function getheadersize: integer; virtual;
   procedure grow;
   function add(out aoffset: ptruint): pointer;
   procedure delete(const aoffset: ptruint);
  public
   constructor create(const adatasize: integer);
   destructor destroy; override;
   procedure clear;
   property count: integer read fcount;
   property capacity: integer read getcapacity write setcapacity;
                    //grow only
 end;

 tsinglelinklist = class(tlinklist)
  protected
  public
 end;

 tdoublelinklist = class(tlinklist)
  protected
   function getheadersize: integer; override;
   procedure delete(const aoffset: ptruint);
  public
 end;

 listadty = card32;
 linklistheaderty = record
  next: listadty; //offset from list
 end;
 plinklistheaderty = ^linkheaderty;
 linkdataty = record
  header: linkheaderty;
  data: record
  end;
 end;
 plinkdataty = ^linkdataty;

 linklistty = record
  itemsize: integer;
  mincapacity: integer;
  list: pointer;
  current: listadty;  //offset from list
  capacity: listadty; //offset from list
  deleted: listadty;
 end;

 resolvehandlerty = procedure(var item);
 resolvehandlerdataty = procedure(var item; var data);
 checkresolvehandlerty = procedure(var item; var data; var resolved: boolean);

procedure clearlist(var alist: linklistty; const aitemsize: integer;
                                              const amincapacity: integer);
procedure freelist(var alist: linklistty);
function addlistitem(var alist: linklistty; var aitem: listadty): pointer;
function getlistitem(const alist: linklistty; const aitem: listadty): pointer;
function getnextlistitem(const alist: linklistty;
                                              const aitem: listadty): pointer;
procedure deletelistitem(var alist: linklistty; var achain: listadty);
procedure deletelistchain(var alist: linklistty; var achain: listadty);
procedure invertlist(const alist: linklistty; var achain: listadty);
procedure resolvelist(var alist: linklistty; const handler: resolvehandlerty;
                                                         var achain: listadty);
procedure checkresolve(var alist: linklistty;
                   const handler: checkresolvehandlerty; var achain: listadty;
                   const data: pointer);
procedure foralllistitems(var alist: linklistty;
                    const handler: resolvehandlerty; const achain: listadty);
procedure foralllistitemsdata(var alist: linklistty;
                    const handler: resolvehandlerdataty; const achain: listadty;
                    const data: pointer);

implementation

procedure clearlist(var alist: linklistty; const aitemsize: integer;
                                                 const amincapacity: integer);
begin
 with alist do begin
  itemsize:= aitemsize;
  mincapacity:= amincapacity*aitemsize;
  if list <> nil then begin
   freemem(list);
  end;
  list:= nil;
  current:= 0;
  capacity:= 0;
  deleted:= 0;
 end;
end;

procedure freelist(var alist: linklistty);
begin
 with alist do begin
  if list <> nil then begin
   freemem(list);
  end;
  fillchar(alist,sizeof(alist),0);
 end;
end;

function addlistitem(var alist: linklistty; var aitem: listadty): pointer;
var
 li1: listadty;
begin
 with alist do begin
  li1:= deleted;
  if li1 = 0 then begin
   current:= current + itemsize;
   if current >= capacity then begin
    capacity:= 2*capacity + mincapacity;
    reallocmem(list,capacity);
   end;
   li1:= current;
   result:= list+li1;
  end
  else begin
   result:= list+li1;
   deleted:= plinkheaderty(result)^.next;
  end;
  plinkheaderty(result)^.next:= aitem;
  aitem:= li1;
 end;
end;

function getlistitem(const alist: linklistty; const aitem: listadty): pointer;
begin
 result:= alist.list+aitem;
end;

function getnextlistitem(const alist: linklistty;
                                 const aitem: listadty): pointer;
var
 i1: listadty;
begin
 result:= alist.list+aitem;
 i1:= plinkdataty(result)^.header.next;
 if i1 = 0 then begin
  result:= nil;
 end
 else begin
  result:= alist.list+i1;
 end;
end;

procedure deletelistitem(var alist: linklistty; var achain: listadty);
var
 next1: listadty;
begin
 if achain <> 0 then begin
  with alist do begin
   next1:= plinkheaderty(list+achain)^.next;
   plinkheaderty(list+achain)^.next:= deleted;
   deleted:= achain;
  end;
  achain:= next1;
 end;
end;

procedure deletelistchain(var alist: linklistty; var achain: listadty);
var
 ad1: listadty;
 po1: plinkheaderty;
begin
 if achain <> 0 then begin
  with alist do begin
   ad1:= achain;
   repeat
    po1:= alist.list+ad1;
    ad1:= po1^.next;
   until ad1 = 0;
   po1^.next:= deleted;
   deleted:= achain;
  end;
  achain:= 0;
 end;
end;

procedure invertlist(const alist: linklistty; var achain: listadty);
var
 s,s1,d: listadty;
begin
 if achain <> 0 then begin
  d:= 0;
  s:= achain;
  repeat
   with plinkheaderty(alist.list+s)^ do begin
    s1:= next;
    next:= d;
   end;
   d:= s;
   s:= s1;
  until s = 0;
  achain:= d;
 end;
end;

procedure resolvelist(var alist: linklistty; const handler: resolvehandlerty;
                                                         var achain: listadty);
var
 ad1: listadty;
 po1: plinkheaderty;
begin
 if achain <> 0 then begin
  ad1:= achain;
  with alist do begin
   while ad1 <> 0 do begin
    po1:= alist.list+ad1;
    handler(po1^);
    ad1:= po1^.next;
   end;
   plinkheaderty(list+achain)^.next:= deleted;
   deleted:= achain;
   achain:= 0;
  end;
 end;
end;

procedure checkresolve(var alist: linklistty;
                   const handler: checkresolvehandlerty; var achain: listadty;
                   const data: pointer);
var
 ad1: listadty;
 po2: pointer;
 po1,po3: plinkheaderty;
 bo1: boolean;
begin
 if achain <> 0 then begin
  po3:= nil;
  ad1:= achain;
  po2:= alist.list;
  while ad1 <> 0 do begin
   po1:= po2+ad1;
   bo1:= false;
   handler(po1^,data^,bo1);
   if bo1 then begin
    if po3 <> nil then begin
     po3^.next:= po1^.next;
    end
    else begin
     achain:= po1^.next;
    end;
    if alist.deleted <> 0 then begin
     plinkheaderty(alist.list+alist.deleted)^.next:= ad1;
    end;
    alist.deleted:= ad1;
    ad1:= po1^.next;
    po1^.next:= 0;
   end
   else begin
    ad1:= po1^.next;
   end;
   po3:= po1;
  end;
 end;
end;

procedure foralllistitems(var alist: linklistty;
                    const handler: resolvehandlerty; const achain: listadty);
var
 ad1: listadty;
 po2: pointer;
 po1: plinkheaderty;
begin
 if achain <> 0 then begin
  ad1:= achain;
  po2:= alist.list;
  while ad1 <> 0 do begin
   po1:= po2+ad1;
   handler(po1^);
   ad1:= po1^.next;
  end;
 end;
end;

procedure foralllistitemsdata(var alist: linklistty;
                    const handler: resolvehandlerdataty; const achain: listadty;
                    const data: pointer);
var
 ad1: listadty;
 po2: pointer;
 po1: plinkheaderty;
begin
 if achain <> 0 then begin
  ad1:= achain;
  po2:= alist.list;
  while ad1 <> 0 do begin
   po1:= po2+ad1;
   handler(po1^,data^);
   ad1:= po1^.next;
  end;
 end;
end;

{ tlinklist }

constructor tlinklist.create(const adatasize: integer);
begin
 fheadersize:= getheadersize;
 fitemsize:= adatasize + fheadersize;
end;

destructor tlinklist.destroy;
begin
 clear;
 inherited;
end;

function tlinklist.getheadersize: integer;
begin
 result:= sizeof(linkheaderty);
end;

function tlinklist.getcapacity: integer;
begin
 result:= fcapacity div fitemsize
end;

procedure tlinklist.setcapacity(const avalue: integer);
var
 ca1: ptruint;
begin
 ca1:= avalue * fitemsize;
 if ca1 > fcapacity then begin
  reallocmem(fdata,ca1+fitemsize);
  fcapacity:= ca1;
 end;
end;

procedure tlinklist.grow;
begin
 capacity:= 2*count+256;
end;

function tlinklist.add(out aoffset: ptruint): pointer;
begin
 if fdeleted = 0 then begin
  flast:= flast+fitemsize;
  if flast >= fcapacity then begin
   grow;
  end;
  aoffset:= flast;
 end
 else begin
  aoffset:= fdeleted;
  fdeleted:= plinkheaderty(fdata + fdeleted)^.next;
 end;
 inc(fcount);
 result:= fdata+aoffset;
end;

procedure tlinklist.delete(const aoffset: ptruint);
begin
 plinkheaderty(fdata+aoffset)^.next:= fdeleted;
 fdeleted:= aoffset;
 dec(fcount);
end;

procedure tlinklist.clear;
begin
 if fdata <> nil then begin
  freemem(fdata);
  fdata:= nil;
 end;
 fcount:= 0;
 fdeleted:= 0;
 fcapacity:= 0;
end;

{ tsinglelinklist }


{ tdoublelinklist }

function tdoublelinklist.getheadersize: integer;
begin
 result:= sizeof(doublelinkheaderty);
end;

procedure tdoublelinklist.delete(const aoffset: ptruint);
begin
 with pdoublelinkheaderty(fdata+aoffset)^ do begin
  pdoublelinkheaderty(fdata+prev)^.lh.next:= lh.next;
  pdoublelinkheaderty(fdata+lh.next)^.prev:= prev;
 end;
 inherited;
end;

end.
