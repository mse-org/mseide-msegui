{ MSEgui Copyright (c) 2007 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msebintree;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
type
 tavlnode = class
  private
   fup: tavlnode;
   fleft: tavlnode;
   fright: tavlnode;
   fbalance: integer;
  public
   destructor destroy; override;
   property balance: integer read fbalance;
   property up: tavlnode read fup;
   property left: tavlnode read fleft;
   property right: tavlnode read fright;
 end;

 tintegeravlnode = class(tavlnode)
  private
   fkey: integer;
  public 
   constructor create(const akey: integer);
   property key: integer read fkey;
 end;
 
 tint64avlnode = class(tavlnode)
  private
   fkey: int64;
  public 
   constructor create(const akey: int64);
   property key: int64 read fkey;
 end;
 
 avlnodeclassty = class of tavlnode; 
 pavlnode = ^tavlnode;

 nodecomparefuncty = function(const left,right: tavlnode): integer;
 nodeprocty = procedure(const anode: tavlnode) of object;
 
 tavltree = class
  private
   froot: tavlnode;
   fcompare: nodecomparefuncty;
   fcount: integer;
//   fnodeclass: avlnodeclassty;
//   procedure freenode(const anode: tavlnode);
  protected
   function parentpo(const anode: tavlnode): pavlnode;
   procedure dobalance(const anode: tavlnode; const deleted: boolean);
   procedure addnode(const anode: tavlnode);
   function find(const aleft: tavlnode; out anode: tavlnode): boolean;
             //true if exact
  public
   destructor destroy; override;
   procedure clear; virtual;//frees the nodes
   procedure removenode(const anode: tavlnode); //does not free node
   procedure traverse(const aproc: nodeprocty);
   property count: integer read fcount;
   property root: tavlnode read froot;
 end;

 integernodeprocty = procedure(const anode: tintegeravlnode) of object;
  
 tintegeravltree = class(tavltree)
  public
   constructor create;
   function addnode(const akey: integer): tintegeravlnode;
   function find(const akey: integer; out anode: tintegeravlnode): boolean; overload;
   procedure traverse(const aproc: integernodeprocty);
 end;

 int64nodeprocty = procedure(const anode: tint64avlnode) of object;
 
 tint64avltree = class(tavltree)
  public
   constructor create;
   function addnode(const akey: int64): tint64avlnode; overload;
   function find(const akey: int64; out anode: tint64avlnode): boolean; overload;
   procedure traverse(const aproc: int64nodeprocty);
 end;

 tcachenode = class(tint64avlnode)
  private
   fprev: tcachenode;
   fnext: tcachenode;
  protected
   fsize: integer;
 end;
 
 tdatacachenode = class(tcachenode)
  private
   fdata: pointer;
  public
   constructor create(const akey: int64; const adata: pointer; const asize: integer);
   destructor destroy; override;
   property data: pointer read fdata;
   property size: integer read fsize;
 end;

 tcacheavltree = class(tint64avltree)
  private
   fsize: integer;
   ffirst: tcachenode;
   flast: tcachenode;
   fmaxsize: integer;
   procedure setmaxsize(const avalue: integer);
   procedure checkbuffersize;
  protected
   procedure addnode(const anode: tcachenode);   
  public
   procedure clear; override;
   procedure removenode(const anode: tcachenode); //does not free node
   function find(const akey: int64; out anode: tcachenode): boolean;
   property maxsize: integer read fmaxsize write setmaxsize; //0 -> no limit
   property size: integer read fsize;
 end;

 tdatacacheavltree = class(tcacheavltree)
  public
   function addnode(const akey: int64; const adata: pointer;
                           const asize: integer): tdatacachenode;
 end;
 
 tstringcachenode = class(tcachenode)
  private
   fdata: string;
  public
   constructor create(const akey: int64; const adata: string);
   property data: string read fdata;
 end;
 
 tstringcacheavltree = class(tcacheavltree)
  public
   function addnode(const akey: int64; const adata: string): tstringcachenode;
 end;
 
implementation
uses
 sysutils;
 
{ tavlnode }

destructor tavlnode.destroy;
begin
 fleft.free;
 fright.free;
end;

{ tavltree }

destructor tavltree.destroy;
begin
 clear;
 inherited;
end;

procedure tavltree.clear;
begin
 fcount:= 0;
 freeandnil(froot);
end;
{
procedure tavltree.freenode(const anode: tavlnode);
begin
 if anode <> nil then begin
  freenode(anode.fleft);
  freenode(anode.fright);
  anode.free;
 end;
end;
}
function tavltree.find(const aleft: tavlnode; out anode: tavlnode): boolean;
var
 n1: tavlnode;
 int1: integer;
begin
 anode:= nil;
 result:= false; 
 if froot <> nil then begin
  n1:= froot;
  while true do begin
   int1:= fcompare(n1,aleft);
   if int1 = 0 then begin  //exact
    anode:= n1;
    result:= true;
    break;
   end;
   if int1 > 0 then begin //too big
    if n1.fleft = nil then begin
     anode:= n1;
     break;
    end;
    n1:= n1.fleft;        
   end
   else begin             //too small
    if n1.fright = nil then begin
     anode:= n1.fup;
     if (anode <> nil) and (anode.fleft <> n1) then begin
      anode:= nil;
     end;
     break;
    end;
    n1:= n1.fright;
   end;
  end;
 end;
end;

function tavltree.parentpo(const anode: tavlnode): pavlnode;
var
 n1: tavlnode;
begin
 n1:= anode.fup; 
 if n1 = nil then begin
  result:= @froot;
 end
 else begin
  if anode = n1.fleft then begin
   result:= @n1.fleft;
  end
  else begin
   result:= @n1.fright;
  end;
 end;
end;

procedure tavltree.dobalance(const anode: tavlnode; const deleted: boolean);
var
 n3,n4,n5: tavlnode;
 po1: pavlnode;
 
 procedure initpointer;
 begin     
  n5:= n4.fup;
  po1:= parentpo(n4);
 end;
 
begin            //balance
 n3:= anode;
 while true do begin
  n4:= n3.fup;
  if n4 = nil then begin
   break; //root reached
  end;
  if (n4.fleft = n3) xor deleted then begin
   if (n4.fbalance < 0) then begin  //left heavy
    initpointer;
    if n4.fleft.fbalance > 0 then begin
                    //rotate left right
                    //                      A=n4           B
                    //                     / \           /  \
                    //                    C   a         C    A=n4
                    //                   / \           / \  / \
                    //                  c   B         c b2 b1  a
                    //                     / \
                    //                    b2 b1
     po1^:= n4.fleft.fright;           //B -> top
     po1^.fup:= n4.fup;                //A.up -> B.up
     n4.fleft.fright:= po1^.fleft;     //b2 -> C.right
     if n4.fleft.fright <> nil then begin
      n4.fleft.fright.fup:= n4.fleft;  //C -> b2.up
     end;
     po1^.fleft:= n4.fleft;            //C -> B.left
     n4.fleft.fup:= po1^;              //B -> C.up
     n4.fleft:= po1^.fright;           //b1 -> A.left
     if n4.fleft <> nil then begin
      n4.fleft.fup:= n4;
     end;
     po1^.fright:= n4;                 //A -> B.right
     n4.fup:= po1^;                    //B -> A.up
     
                                       //before A  B  C  after A  B  C
                                       //      -2 +1 +1        0  0 -1 
                                       //      -2  0 +1        0  0  0
                                       //      -2 -1 +1       +1  0  0
     if po1^.fbalance = 0 then begin   //B
      n4.fbalance:= 0;                 //A
      po1^.fleft.fbalance:= 0;         //C
     end
     else begin
      if po1^.fbalance < 0 then begin  //B
       n4.fbalance:= 1;                //A
       po1^.fleft.fbalance:= 0;        //C
      end
      else begin
       n4.fbalance:= 0;                //A
       po1^.fleft.fbalance:= -1;       //C
      end;
     end; 
     po1^.fbalance:= 0;
     if not deleted then begin
      exit;         //new height compensated
     end;
    end
    else begin
                    //rotate right          A=n4         B 
                    //                     / \          / \
                    //                    B   a        c   A=n4
                    //                   / \              / \
                    //                  c  b             b  a
     po1^:= n4.fleft;                 //B -> top 
     po1^.fup:= n4.fup;               //A.up -> B.up
     n4.fleft:= po1^.fright;          //b -> A.left
     po1^.fright:= n4;                //A -> B.right
     
                                      //before A   B  after A   B
                                      //      -2  -1        0   0
                                      //      -2   0       -1  +1
     if po1^.fbalance = 0 then begin
      n4.fbalance:= -1;
      po1^.fbalance:= 1;
     end
     else begin
      n4.fbalance:= 0;
      po1^.fbalance:= 0;
     end;
    end;            
    po1^.fup:= n5;                   //up -> B.up
    n4.fup:= po1^;                   //B -> A.up
    if n4.fleft <> nil then begin
     n4.fleft.fup:= n4;              //A -> b1.up ¦ A -> b.up
    end;
    if (po1^.fbalance = 0) xor deleted then begin
     exit;        //B was unbalanced;
    end;
    n4:= po1^;
   end
   else begin
    dec(n4.fbalance);
    if (n4.fbalance = 0) xor deleted then begin
     exit;
    end;
   end;
  end
  else begin
   if (n4.fbalance > 0) then begin  //right heavy
    initpointer;
    if n4.fright.fbalance < 0 then begin
                    //rotate right left
                    //                      A=n4           B
                    //                     / \           /  \
                    //                    a   C         A=n4 C
                    //                      / \        / \  / \
                    //                     B   c      a b1 b2  c
                    //                    / \
                    //                   b1 b2
     po1^:= n4.fright.fleft;            //B -> top
     po1^.fup:= n4.fup;                 //A.up -> B.up
     n4.fright.fleft:= po1^.fright;     //b2 -> C.left
     if n4.fright.fleft <> nil then begin
      n4.fright.fleft.fup:= n4.fright;  //C -> b2.up
     end;
     po1^.fright:= n4.fright;           //C -> B.right
     n4.fright.fup:= po1^;              //B -> C.up
     n4.fright:= po1^.fleft;            //b1 -> A.right
     if n4.fright <> nil then begin
      n4.fright.fup:= n4;
     end;
     po1^.fleft:= n4;                   //A -> B.left
     n4.fup:= po1^;                     //B -> A.up
     
                                       //before A  B  C  after A  B  C
                                       //      +2 +1 -1       -1  0  0 
                                       //      +2  0 -1        0  0  0
                                       //      +2 -1 -1        0  0  1
     if po1^.fbalance = 0 then begin   //B
      n4.fbalance:= 0;                 //A
      po1^.fright.fbalance:= 0;        //C
     end
     else begin
      if po1^.fbalance < 0 then begin  //B
       n4.fbalance:= 0;                //A
       po1^.fright.fbalance:= 1;       //C
      end
      else begin
       n4.fbalance:= -1;               //A
       po1^.fright.fbalance:= 0;       //C
      end;
     end; 
     po1^.fbalance:= 0;
     if not deleted then begin
      exit;         //new height compensated
     end;
    end
    else begin
                    //rotate left           A=n4          B 
                    //                     / \          /  \
                    //                    a   B        A=n4 c
                    //                      / \       / \
                    //                     b  c      a  b
     po1^:= n4.fright;                //B -> top 
     po1^.fup:= n4.fup;               //A.up -> B.up
     n4.fright:= po1^.fleft;          //b -> A.right
     po1^.fleft:= n4;                 //A -> B.left
     
                                      //before A   B  after A   B
                                      //      +2  +1        0   0
                                      //      +2   0       +1  -1
     if po1^.fbalance = 0 then begin
      n4.fbalance:= 1;
      po1^.fbalance:= -1;
     end
     else begin
      n4.fbalance:= 0;
      po1^.fbalance:= 0;
     end;
    end;
    po1^.fup:= n5;
    n4.fup:= po1^;
    if n4.fright <> nil then begin
     n4.fright.fup:= n4;                //A -> b1.up ¦ A -> b.up
    end;
    if (po1^.fbalance = 0) xor deleted then begin
     exit;        //B was unbalanced;
    end;
    n4:= po1^;
   end
   else begin
    inc(n4.fbalance);
    if (n4.fbalance = 0) xor deleted then begin
     exit;
    end;
   end;
  end;
  {
  if (n4.fbalance = 0) and (anode <> n3) then begin
   exit;
  end;
  }
  n3:= n4;
 end;
end;

procedure tavltree.addnode(const anode: tavlnode);
var
 n1,n2: tavlnode;
 
begin
 inc(fcount);
 if froot = nil then begin
  froot:= anode;
 end
 else begin
  n1:= froot;
  while true do begin
   if fcompare(anode,n1) >= 0 then begin
    if n1.fright = nil then begin
     n1.fright:= anode;
     anode.fup:= n1;
     if n1.fleft = nil then begin
      dobalance(anode,false);
     end
     else begin
      n1.fbalance:= 0;
     end;
     break;
    end
    else begin
     n1:= n1.fright;
    end;
   end
   else begin
    if n1.fleft = nil then begin
     n1.fleft:= anode;
     anode.fup:= n1;
     if n1.fright = nil then begin
      dobalance(anode,false);
     end
     else begin
      n1.fbalance:= 0;
     end;
     break;
    end
    else begin
     n1:= n1.fleft;
    end;
   end;
  end;
 end;
end;

procedure tavltree.removenode(const anode: tavlnode);

 procedure checkbalance;
 begin
  if anode.fup <> nil then begin
   with anode.fup do begin
    if anode = fright then begin
     if (fleft.fleft = nil) and (fleft.fright = nil) or (fbalance < 0) then begin
      dobalance(anode,true);
     end
     else begin
      fbalance:= -1;
     end;
    end
    else begin
     if (fright.fleft = nil) and (fright.fright = nil) or (fbalance > 0) then begin
      dobalance(anode,true);
     end
     else begin
      fbalance:= 1;
     end;
    end;
   end;
  end;
 end;
 
var
 n1,n2: tavlnode;
 int1: integer;
begin
 dec(fcount);
 n1:= anode;
 if (n1.fleft <> nil) and (n1.fright <> nil) then begin
  n1:= n1.fright;
  while n1.fleft <> nil do begin
   n1:= n1.fleft;      //find smallest in right branch
  end;
  int1:= anode.fbalance;               //swap values
  anode.fbalance:= n1.fbalance;
  n1.fbalance:= int1;
  parentpo(anode)^:= n1;
  n2:= anode.fleft;
  anode.fleft:= n1.fleft;
  n1.fleft:= n2;
  if n2 <> nil then begin
   n2.fup:= n1;
  end;
  if n1.fup = anode then begin         
   anode.fright:= n1.fright;
   n1.fright:= anode;
   n1.fup:= anode.fup;
   anode.fup:= n1;
  end
  else  begin
   parentpo(n1)^:= anode;
   n2:= anode.fup;
   anode.fup:= n1.fup;
   n1.fup:= n2;
   n2:= anode.fright;
   anode.fright:= n1.fright;
   n1.fright:= n2;
   n2.fup:= n1;
  end;
 end;
 if anode.fleft = nil then begin
  if anode.fright <> nil then begin
   checkbalance;
   anode.fright.fup:= anode.fup;
  end
  else begin
   if (anode.fup <> nil) then begin      //leaf
    with anode.fup do begin
     if fleft = anode then begin
      if (fright = nil) or (fright.fright <> nil) or (fright.fleft <> nil) or 
                                      (fbalance > 0) then begin
       dobalance(anode,true);
      end
      else begin
       fbalance:= 1;
      end;
     end
     else  begin
      if (fleft = nil) or (fleft.fright <> nil) or (fleft.fleft <> nil) or 
                                      (fbalance < 0) then begin
       dobalance(anode,true);
      end
      else begin
       fbalance:= -1;
      end;
     end;
    end;
   end;
  end;
  parentpo(anode)^:= anode.fright;
 end
 else begin
  checkbalance;
  anode.fleft.fup:= anode.fup;
  parentpo(anode)^:= anode.fleft;
 end;
 anode.fleft:= nil;
 anode.fright:= nil;
end;

procedure tavltree.traverse(const aproc: nodeprocty);
label
 down;
var
 n1: tavlnode;
begin
 if froot <> nil then begin
  n1:= froot;
down:
  while n1.fleft <> nil do begin
   n1:= n1.fleft;     //find smallest leaf
  end;
  aproc(n1);
  if (n1.fleft = nil) and (n1.fright <> nil) then begin
   n1:= n1.fright;
   goto down;
  end;
  while n1.fup <> nil do begin
   if n1 = n1.fup.fleft then begin
    n1:= n1.fup;
    aproc(n1);
    if n1.fright <> nil then begin
     n1:= n1.fright;
     goto down;
    end;
   end
   else begin
    n1:= n1.fup;
   end;
  end;
 end; 
end;

{ tintegeravlnode }

constructor tintegeravlnode.create(const akey: integer);
begin
 fkey:= akey;
 inherited create;
end;

{ tintegeravltree }

function compareintegeravl(const left,right: tavlnode): integer;
begin
 result:= tintegeravlnode(left).fkey - tintegeravlnode(right).fkey;
end;

constructor tintegeravltree.create;
begin
// fnodeclass:= tintegeravlnode;
 fcompare:= {$ifdef FPC}@{$endif}compareintegeravl;
 inherited;
end;

function tintegeravltree.addnode(const akey: integer): tintegeravlnode;
begin
 result:= tintegeravlnode.create(akey);
 inherited addnode(result);
end;

function tintegeravltree.find(const akey: integer;
               out anode: tintegeravlnode): boolean;
var
 n1: tintegeravlnode;
begin
 n1:= tintegeravlnode.create(akey);
 result:= find(n1,anode);
 n1.free;
end;

procedure tintegeravltree.traverse(const aproc: integernodeprocty);
begin
 inherited traverse(nodeprocty(aproc));
end;

{ tint64avlnode }

constructor tint64avlnode.create(const akey: int64);
begin
 fkey:= akey;
 inherited create;
end;

{ tint64avltree }

function compareint64avl(const left,right: tavlnode): integer;
var
 lint1: int64;
begin
 result:= 0;
 lint1:= tint64avlnode(left).fkey - tint64avlnode(right).fkey;
 if lint1 > 0 then begin
  result:= 1;
 end
 else begin
  if lint1 < 0 then begin
   result:= -1;
  end;
 end;
end;

constructor tint64avltree.create;
begin
 fcompare:= {$ifdef FPC}@{$endif}compareint64avl;
 inherited;
end;

function tint64avltree.addnode(const akey: int64): tint64avlnode;
begin
 result:= tint64avlnode.create(akey);
 inherited addnode(result);
end;

function tint64avltree.find(const akey: int64;
               out anode: tint64avlnode): boolean;
var
 n1: tint64avlnode;
begin
 n1:= tint64avlnode.create(akey);
 result:= find(n1,anode);
 n1.free;
end;

procedure tint64avltree.traverse(const aproc: int64nodeprocty);
begin
 inherited traverse(nodeprocty(aproc));
end;

{ tdatacachenode }

constructor tdatacachenode.create(const akey: int64; const adata: pointer;
               const asize: integer);
begin
 fdata:= adata;
 fsize:= asize;
 inherited create(akey);
end;

destructor tdatacachenode.destroy;
begin
 if fsize > 0 then begin
  freemem(fdata);
 end;
 inherited;
end;

{ tcacheavltree }

procedure tcacheavltree.checkbuffersize;
var
 n1: tcachenode;
begin
 if fmaxsize > 0 then begin
  while (fsize > fmaxsize) and (fcount > 1) do begin
   n1:= ffirst;
   removenode(n1);
   n1.free;
  end;
 end;
end;

procedure tcacheavltree.addnode(const anode: tcachenode);
begin
 fsize:= fsize + anode.fsize;
 if ffirst = nil then begin
  ffirst:= anode;
  flast:= anode;
 end
 else begin
  anode.fprev:= flast;
  flast.fnext:= anode;
  flast:= anode;
 end;
 inherited addnode(anode);
 checkbuffersize;
end;

function tcacheavltree.find(const akey: int64; out anode: tcachenode): boolean;
begin
 result:= inherited find(akey,tint64avlnode(anode));
 if result and (anode <> flast) then begin
  if anode.fprev <> nil then begin
   anode.fprev.fnext:= anode.fnext;
  end
  else begin
   ffirst:= anode.fnext;
  end;
  if anode.fnext <> nil then begin
   anode.fnext.fprev:= anode.fprev;
  end;
  flast.fnext:= anode;
  anode.fprev:= flast;
  anode.fnext:= nil;
  flast:= anode;
 end;
end;

procedure tcacheavltree.clear;
begin
 fsize:= 0;
 inherited;
end;

procedure tcacheavltree.removenode(const anode: tcachenode);
begin
 fsize:= fsize - anode.fsize;
 if fcount > 1 then begin
  if anode = ffirst then begin
   ffirst:= anode.fnext;
   ffirst.fprev:= nil;
  end
  else begin
   if anode = flast then begin
    flast:= anode.fprev;
    flast.fnext:= nil;
   end;
  end;
 end
 else begin
  ffirst:= nil;
  flast:= nil;  
 end;
 anode.fprev:= nil;
 anode.fnext:= nil;
 inherited;
end;

procedure tcacheavltree.setmaxsize(const avalue: integer);
begin
 if fmaxsize <> avalue then begin
  fmaxsize:= avalue;
  checkbuffersize;
 end;
end;

{ tdatacacheavltree }

function tdatacacheavltree.addnode(const akey: int64; const adata: pointer;
               const asize: integer): tdatacachenode;
begin
 result:= tdatacachenode.create(akey,adata,asize);
 inherited addnode(result);
end;

{ tstringcachenode }

constructor tstringcachenode.create(const akey: int64; const adata: string);
begin
 fdata:= adata;
 fsize:= length(adata);
 inherited create(akey);
end;

{ tstringcacheavltree }

function tstringcacheavltree.addnode(const akey: int64;
               const adata: string): tstringcachenode;
begin
 result:= tstringcachenode.create(akey,adata);
 inherited addnode(result);
end;

end.
