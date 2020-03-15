{ MSEgui Copyright (c) 2016 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msehashstore;
{$ifdef FPC}{$mode objfpc}{$h+}{$goto on}{$endif}
interface
uses
 msehash,msetypes;

const
 maxidentvector = 200;

type
 identarty = card32arty;
 identvecty = record
  high: integer;
  d: array[0..maxidentvector] of identty;
 end;

 elementheaderty = record
  path: identty; //key, sum of names to root
  name: identty;
  parent: hashoffsetty; //offset in data array
  parentlevel: int32;      //max = maxidentvector-1
  refcount: int32;
 end;

 elementdataty = record
  header: elementheaderty;
 // data: record
 // end;
 end;
 pelementdataty = ^elementdataty;
 elementhashdataty = record
  header: hashheaderty;
  data: elementdataty;
 end;
 pelementhashdataty = ^elementhashdataty;

 thashstore = class(thashdatalist)
  private
   fcurparent: hashoffsetty;
  protected
   function hashkey(const akey): hashvaluety override;
   function checkkey(const akey; const aitem: phashdataty): boolean override;
   function find(const aele: elementdataty): pelementhashdataty;
//   function internalfind(const idents: identvecty): pelementhashdataty;
   function find(const idents: identvecty): pelementhashdataty;
//   function internaladd(const idents: identvecty;
//                        out aelement: pelementhashdataty): hashoffsetty;
   function add(const idents: identvecty;
                          out aelement: pelementhashdataty): hashoffsetty;
   function getrecordsize(): int32 override;
//   procedure inititem(const aitem: phashdataty) override;
 public
//   constructor create();
   function datapo(const aoffs: hashoffsetty): pelementhashdataty;
   procedure delete(const idents: identvecty);
   procedure delete(const item: hashoffsetty); //offset of datapo
 end;

 treeelementheaderty = record
  element: elementheaderty;
  children: hashoffsetty;    //offset in data array
  prevsibling: hashoffsetty; //offset in data array
  nextsibling: hashoffsetty; //offset in data array
 end;

 treeelementdataty = record
  header: treeelementheaderty;
//  data: record
//  end;
 end;
 ptreeelementdataty = ^treeelementdataty;
 treeelementhashdataty = record
  header: hashheaderty;
  data: treeelementdataty;
 end;
 ptreeelementhashdataty = ^treeelementhashdataty;

 treehashelementiteratorprocty = procedure(const aitem : ptreeelementhashdataty;
                                           const adata: pointer) of object;
 thashtree = class(thashstore)
  protected
   function add(const idents: identvecty;
                            out aelement: ptreeelementhashdataty): hashoffsetty;
   function find(const idents: identvecty): ptreeelementhashdataty;
   function find(const idents: identvecty;
                               out aoffs: hashoffsetty): ptreeelementhashdataty;
//   function find(const aele: elementdataty): ptreeelementhashdataty;
//   function add(const idents: identvecty;
//                        out aelement: pointer): hashoffsetty;
//   function find(const idents: identvecty): pointer;
   function getrecordsize(): int32 override;
   procedure inititem(const aitem: phashdataty) override;
  public
   constructor create();
   function datapo(const aoffs: hashoffsetty): ptreeelementhashdataty;
   function root(const aoffs: hashoffsetty): ptreeelementhashdataty;
   function root(const aitem: ptreeelementhashdataty): ptreeelementhashdataty;
   procedure iteratechildren(const aitem: ptreeelementhashdataty;
                             const aiterator: treehashelementiteratorprocty;
                                                         const adata: pointer);
 end;

implementation

{ thashstore }
{
constructor thashstore.create();
begin
 include(fstate,hls_needsinit);
 inherited;
end;
}
function thashstore.add(const idents: identvecty;
                        out aelement: pelementhashdataty): hashoffsetty;
var
 p1,pe: pidentty;
 ele: elementdataty;
 p2: pelementhashdataty;
// off1: hashoffsetty;
begin
 if idents.high >= 0 then begin
  ele.header.path:= 0;
  ele.header.parent:= 0;
  ele.header.parentlevel:= 0;
  ele.header.refcount:= 0;
  p1:= @idents.d;
  pe:= p1+idents.high;
  fcurparent:= 0;
  while p1 <= pe do begin
   ele.header.path:= ele.header.path+p1^;
   ele.header.name:= p1^;
   if (p1 = pe) then begin
    p2:= nil;
   end
   else begin
    p2:= find(ele);
   end;
   if (p2 = nil) then begin
    p2:= pointer(internaladdhash(ele.header.path));
    p2^.data.header:= ele.header;
    if fcurparent <> 0 then begin
     inc(pelementhashdataty(fdata+fcurparent)^.data.header.refcount);
    end;
   end;
   inc(ele.header.parentlevel);
   ele.header.parent:= getdataoffs(p2);
   fcurparent:= p2-fdata;
   inc(p1);
  end;
  inc(p2^.data.header.refcount);
//  adata:= @p2^.data.data;
  aelement:= p2;
  result:= pointer(p2)-fdata;
 end
 else begin
  result:= 0;
  aelement:= nil;
 end;
end;

function thashstore.find(const aele: elementdataty): pelementhashdataty;
var
 p1: pelementhashdataty;
 uint1: ptruint;
begin
 result:= nil;
 p1:= fdata;
 if count > 0 then begin
  uint1:= fhashtable[aele.header.path and fmask];
  while uint1 <> 0 do begin
   p1:= pelementhashdataty(fdata + uint1);
   with p1^ do begin
    if (data.header.path = aele.header.path) and
                   (data.header.parent = aele.header.parent) then begin
     result:= p1;
     break;
    end;
   end;
   uint1:= p1^.header.nexthash;
  end;
 end;
end;

function thashstore.hashkey(const akey): hashvaluety;
begin
 result:= elementdataty(akey).header.path;
end;

function thashstore.checkkey(const akey; const aitem: phashdataty): boolean;
begin
 result:= elementdataty(akey).header.path =
                   pelementhashdataty(aitem)^.data.header.path;
end;

function thashstore.find(const idents: identvecty): pelementhashdataty;
var
 c1: card32;
 p1,p2,pe,ps: pidentty;
 ph1,ph2: pelementhashdataty;
 uint1: ptruint;
label
 nextlab;
begin
 result:= nil;
 if (count > 0) and (idents.high >= 0) then begin
  ps:= @idents.d;
  p1:= ps;
  pe:= p1+idents.high;
  c1:= 0;
  while p1 <= pe do begin
   c1:= c1 + p1^;
   inc(p1);
  end;
  uint1:= fhashtable[c1 and fmask];
  while uint1 <> 0 do begin
   ph1:= pelementhashdataty(fdata + uint1);
   with ph1^ do begin
    if (data.header.path = c1) and
                   (data.header.parentlevel = idents.high) then begin
     ph2:= ph1;
     p2:= pe;
     while p2 >= ps do begin
      if p2^ <> ph2^.data.header.name then begin
       goto nextlab;
      end;
      ph2:= fdata+ph2^.data.header.parent;
      dec(p2);
     end;
     result:= ph1;//@ph1^.data.data;
     exit;
    end;
   end;
nextlab:
   uint1:= ph1^.header.nexthash;
  end;
 end;
end;
{
function thashstore.add(const idents: identvecty;
                                         out adata: pointer): hashoffsetty;
begin
 result:= internaladd(idents,adata);
 adata:= adata+sizeof(elementhashdataty);
end;
}
function thashstore.datapo(const aoffs: hashoffsetty): pelementhashdataty;
begin
 result:= fdata+aoffs;
end;

function thashstore.getrecordsize(): int32;
begin
 result:= sizeof(elementhashdataty);
end;

{
function thashstore.find(const idents: identvecty): pointer;
begin
 result:= internalfind(idents);
 if result <> nil then begin
  result:= result + sizeof(elementhashdataty);
 end;
end;
}
procedure thashstore.delete(const item: hashoffsetty);
var
 p1: pelementhashdataty;
begin
 p1:= getdatapo(item{-sizeof(elementhashdataty)});
 while true do begin
  dec(p1^.data.header.refcount);
  if p1^.data.header.refcount > 0 then begin
   break;
  end;
  internaldeleteitem(phashdataty(pointer(p1))); //memory still valid
  if p1^.data.header.parent = 0 then begin
   break;
  end;
  p1:= fdata+p1^.data.header.parent;
 end;
end;

procedure thashstore.delete(const idents: identvecty);
var
 p1: pelementhashdataty;
begin
 p1:= find(idents);
 if p1 <> nil then begin
  delete(getdataoffs(p1));
 end;
end;

{ thashtree }

const
 treeheaderext = sizeof(treeelementhashdataty) - sizeof(elementhashdataty);

constructor thashtree.create();
begin
 include(fstate,hls_needsinit);
 inherited create();
end;

procedure thashtree.inititem(const aitem: phashdataty);
var
 p1,p2: ptreeelementhashdataty;
 o1,o2: hashoffsetty;
begin
 with ptreeelementhashdataty(aitem)^.data.header do begin
  children:= 0;
  prevsibling:= 0;
  nextsibling:= 0;
  p1:= getdatapoornil(fcurparent);
  if p1 <> nil then begin
   o1:= p1^.data.header.children;
   o2:= getdataoffs(aitem);
   if o1 <> 0 then begin
    p2:= datapo(o1);
    p2^.data.header.nextsibling:= o2;
    prevsibling:= o1;
   end;
   p1^.data.header.children:= o2;
  end;
 end;
end;

function thashtree.add(const idents: identvecty;
               out aelement: ptreeelementhashdataty): hashoffsetty;
{
var
 p1,p2: ptreeelementhashdataty;
 o1: hashoffsetty;
}
begin
 result:= inherited add(idents,pelementhashdataty(aelement));
{
 with aelement^ do begin
  p1:= getdatapoornil(data.header.element.parent);
  if p1 <> nil then begin
   o1:= p1^.data.header.children;
   if o1 <> 0 then begin
    p2:= datapo(o1);
    p2^.data.header.nextsibling:= result-o1;
    data.header.prevsibling:= pointer(p2) - pointer(aelement);
   end;
   p1^.data.header.children:= result;
  end;
 end;
}
// adata:= adata+sizeof(treeelementhashdataty);
end;

procedure thashtree.iteratechildren(const aitem: ptreeelementhashdataty;
               const aiterator: treehashelementiteratorprocty;
               const adata: pointer);
var
 o1: hashoffsetty;
begin
 o1:= aitem^.data.header.children;
 while o1 <> 0 do begin
  aiterator(datapo(o1),adata);
  o1:= datapo(o1)^.data.header.prevsibling;
 end;
end;

function thashtree.find(const idents: identvecty): ptreeelementhashdataty;
begin
 result:= ptreeelementhashdataty(inherited find(idents));
end;

function thashtree.find(const idents: identvecty;
               out aoffs: hashoffsetty): ptreeelementhashdataty;
begin
 result:= ptreeelementhashdataty(inherited find(idents));
 if result = nil then begin
  aoffs:= 0;
 end
 else begin
  aoffs:= pointer(result)-fdata;
 end;
end;

function thashtree.datapo(const aoffs: hashoffsetty): ptreeelementhashdataty;
begin
 result:= fdata+aoffs;
end;

function thashtree.root(const aoffs: hashoffsetty): ptreeelementhashdataty;
var
 o1: hashoffsetty;
begin
 result:= nil;
 o1:= aoffs;
 while o1 <> 0 do begin
  result:= fdata+o1;
  o1:= result^.data.header.element.parent
 end;
end;

function thashtree.root(
              const aitem: ptreeelementhashdataty): ptreeelementhashdataty;
begin
 result:= aitem;
 if aitem <> nil then begin
  result:= root(getdataoffs(aitem));
 end;
end;

function thashtree.getrecordsize(): int32;
begin
 result:= sizeof(treeelementhashdataty);
end;

end.
