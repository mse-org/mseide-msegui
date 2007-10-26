{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msegraphutils;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 msetypes;

type
 graphicdirectionty = (gd_right,gd_up,gd_left,gd_down,gd_none);
 graphicdirectionsty = set of graphicdirectionty;

 pointty = record
            x,y: integer;
           end;
 ppointty = ^pointty;
 pointarty = array of pointty;
 ppointarty = ^pointarty;
 pointaty = array[0..0] of pointty;
 ppointaty = ^pointaty;

 segmentty = record a,b: pointty end;
 segmentarty = array of segmentty;

 graphicvectorty = record
  start: pointty;
  direction: graphicdirectionty;
  length: integer;
 end;

 sizety = record
            cx,cy: integer;
          end;

 rectty = record
           case integer of
            0: (x,y,cx,cy: integer);
            1: (pos: pointty; size: sizety);
          end;
 framety = record
            case integer of
             0: (left,top,right,bottom: integer);
             1: (topleft,bottomright: sizety);
           end;
 pframety = ^framety;
 prectty = ^rectty;
 rectarty = array of rectty;
 prectarty = ^rectarty;

const
 nullpoint: pointty = (x: 0; y: 0);
 nullsize: sizety = (cx: 0; cy: 0);
 nullrect: rectty = (x: 0; y: 0; cx: 0; cy: 0);
 nullframe: framety = (left: 0; top: 0; right: 0; bottom: 0);
 minimalframe: framety = (left: 1; top: 1; right: 1; bottom: 1);


function makepoint(const x,y: integer): pointty;
function makesize(const cx,cy: integer): sizety;
function makerect(const x,y,cx,cy: integer): rectty; overload;
function makerect(const pos: pointty; const size: sizety): rectty; overload;

function isnullpoint(const point: pointty): boolean;
function isnullsize(const size: sizety): boolean;
function isnullrect(const rect: rectty): boolean;
function isnullframe(const frame: framety): boolean;
function pointisequal(const a,b: pointty): boolean;
function sizeisequal(const a,b: sizety): boolean;
function rectisequal(const a,b: rectty): boolean;
function frameisequal(const a,b: framety): boolean;

function addpoint(const a,b: pointty): pointty; //result:= a+b
procedure addpoint1(var dest: pointty; const point: pointty);
function subpoint(const a,b: pointty): pointty; //result:= a-b
procedure subpoint1(var dest: pointty; const point: pointty);
function distance(const a,b: pointty): integer;

function addsize(const a,b: sizety): sizety; //result:= a+b
procedure addsize1(var dest: sizety; const size: sizety);
function subsize(const a,b: sizety): sizety; //result:= a-b
procedure subsize1(var dest: sizety; const size: sizety);

function rectcenter(const arect: rectty): pointty;
procedure centerrect(apos: pointty; asize: integer; out rect: rectty);
function inflaterect(const rect: rectty; value: integer): rectty; overload;
function inflaterect(const rect: rectty; const frame: framety): rectty; overload;
procedure inflaterect1(var rect: rectty; value: integer); overload;
procedure inflaterect1(var rect: rectty; const frame: framety); overload;
function deflaterect(const rect: rectty; const frame: framety): rectty;
procedure deflaterect1(var rect: rectty; const frame: framety);

function addframe(const a,b: framety): framety;
procedure addframe1(var dest: framety; const frame: framety);
function subframe(const a,b: framety): framety;
procedure subframe1(var dest: framety; const frame: framety);

procedure inflateframe(var frame: framety; value: integer);
function inflateframe1(const frame: framety; value: integer): framety;
function moverect(const rect: rectty; const dist: pointty): rectty;
procedure moverect1(var rect: rectty; const dist: pointty);
function removerect(const rect: rectty; const dist: pointty): rectty;
procedure removerect1(var rect: rectty; const dist: pointty);
procedure shiftinrect(var rect: rectty; const outerrect: rectty);
procedure centerinrect(var rect: rectty; const outerrect: rectty);
function changerectdirection(const arect: rectty;
                const olddirction,newdirection: graphicdirectionty): rectty;
function rotateframe(const aframe: framety; const olddirection,
                  newdirection: graphicdirectionty): framety;
procedure rotateframe1(var aframe: framety; const olddirection,
                  newdirection: graphicdirectionty);
                
function intersectrect(const a,b: rectty; out dest: rectty): boolean; overload;
function intersectrect(const a,b: rectty): rectty; overload;
function testintersectrect(const a,b: rectty): boolean;
     //true on intersection
function clipinrect(const point: pointty; const boundsrect: rectty): pointty; overload;
function clipinrect(const rect: rectty; const boundsrect: rectty): rectty; overload;
procedure clipinrect1(var point: pointty; const boundsrect: rectty); overload;
procedure clipinrect1(var rect: rectty; const boundsrect: rectty); overload;

function pointinrect(const point: pointty; const rect: rectty): boolean;
     //true if point is in rect
function rectinrect(const inner,outer: rectty): boolean;
     //true if inner in outer

function segment(const a,b: pointty): segmentty;

procedure vectortoline(const vector: graphicvectorty; out a,b: pointty);

function rotatedirection(const olddest,newvalue,
                            oldvalue: graphicdirectionty): graphicdirectionty;

implementation
uses
 SysUtils;

function rotateframe(const aframe: framety; const olddirection,
                  newdirection: graphicdirectionty): framety;
begin
 result:= aframe;
 rotateframe1(result,olddirection,newdirection);
end;

procedure rotateframe1(var aframe: framety; const olddirection,
                  newdirection: graphicdirectionty);
var
 int1: integer;
 frame1: framety;
begin
 if olddirection <> newdirection then begin
  frame1:= aframe;
  int1:= (ord(newdirection) - ord(olddirection)) and $3;
  case int1 of
   1: begin
    aframe.top:= frame1.right;
    aframe.left:= frame1.top;
    aframe.bottom:= frame1.left;
    aframe.right:= frame1.bottom;
   end;
   2: begin
    aframe.left:= frame1.right;
    aframe.bottom:= frame1.top;
    aframe.right:= frame1.left;
    aframe.top:= frame1.bottom;
   end;
   3: begin
    aframe.bottom:= frame1.right;
    aframe.right:= frame1.top;
    aframe.top:= frame1.left;
    aframe.left:= frame1.bottom;
   end;
  end;
 end;
end;

function rotatedirection(const olddest,newvalue,
                    oldvalue: graphicdirectionty): graphicdirectionty;
begin
 result:= graphicdirectionty(((ord(olddest)+ord(newvalue)-ord(oldvalue)) and $3));
end;

procedure shiftinrect(var rect: rectty; const outerrect: rectty);
var
 int1: integer;
begin
 with rect do begin
  int1:= outerrect.x + outerrect.cx - (x + cx);
  if int1 < 0 then begin
   inc(x,int1);
  end;
  int1:= outerrect.y + outerrect.cy - (y + cy);
  if int1 < 0 then begin
   inc(y,int1);
  end;
  if x < outerrect.x then begin
   x:= outerrect.x;
  end;
  if y < outerrect.y then begin
   y:= outerrect.y;
  end;
 end;
end;

procedure centerinrect(var rect: rectty; const outerrect: rectty);
begin
 with outerrect do begin
  rect.x:= x + (cx - rect.cx) div 2;
  rect.y:= y + (cy - rect.cy) div 2;
 end;
end;

function changerectdirection(const arect: rectty;
                const olddirction,newdirection: graphicdirectionty): rectty;
begin
 result.pos:= arect.pos;
 if (olddirction in [gd_left,gd_right]) xor 
                (newdirection in [gd_left,gd_right]) then begin
  result.cx:= arect.cy;
  result.cy:= arect.cx;
 end
 else begin
  result.size:= arect.size;
 end;
end;

function makepoint(const x,y: integer): pointty;
begin
 result.x:= x;
 result.y:= y;
end;

function makesize(const cx,cy: integer): sizety;
begin
 result.cx:= cx;
 result.cy:= cy;
end;

function makerect(const x,y,cx,cy: integer): rectty;
begin
 result.x:= x;
 result.y:= y;
 result.cx:= cx;
 result.cy:= cy;
end;

function makerect(const pos: pointty; const size: sizety): rectty; overload;
begin
 result.pos:= pos;
 result.size:= size;
end;

function isnullpoint(const point: pointty): boolean;
begin
 with point do begin
  result:= (x = 0) and (y = 0);
 end;
end;

function isnullsize(const size: sizety): boolean;
begin
 with size do begin
  result:= (cx = 0) and (cy = 0);
 end;
end;

function isnullrect(const rect: rectty): boolean;
begin
 with rect do begin
  result:= (x = 0) and (y = 0) and (cx = 0) and (cy = 0);
 end;
end;

function isnullframe(const frame: framety): boolean;
begin
 with frame do begin
  result:= (left = 0) and (top = 0) and (right = 0) and (bottom = 0);
 end;
end;

function pointisequal(const a,b: pointty): boolean;
begin
 result:= comparemem(@a,@b,sizeof(pointty));
end;

function sizeisequal(const a,b: sizety): boolean;
begin
 result:= comparemem(@a,@b,sizeof(sizety));
end;

function rectisequal(const a,b: rectty): boolean;
begin
 result:= comparemem(@a,@b,sizeof(rectty));
end;

function frameisequal(const a,b: framety): boolean;
begin
 result:= comparemem(@a,@b,sizeof(framety));
end;

function addpoint(const a,b: pointty): pointty; //result:= a-b
begin
 result.x:= a.x+b.x;
 result.y:= a.y+b.y;
end;

procedure addpoint1(var dest: pointty; const point: pointty);
begin
 inc(dest.x,point.x);
 inc(dest.y,point.y);
end;

function subpoint(const a,b: pointty): pointty; //result:= a-b
begin
 result.x:= a.x-b.x;
 result.y:= a.y-b.y;
end;

procedure subpoint1(var dest: pointty; const point: pointty);
begin
 dec(dest.x,point.x);
 dec(dest.y,point.y);
end;

function distance(const a,b: pointty): integer;
begin
 result:= abs(a.x-b.x) + abs(a.y-b.y);
end;

function addsize(const a,b: sizety): sizety; //result:= a+b
begin
 result.cx:= a.cx+b.cx;
 result.cy:= a.cy+b.cy;
end;

procedure addsize1(var dest: sizety; const size: sizety);
begin
 inc(dest.cx,size.cx);
 inc(dest.cy,size.cy);
end;

function subsize(const a,b: sizety): sizety; //result:= a-b
begin
 result.cx:= a.cx-b.cx;
 result.cy:= a.cy-b.cy;
end;

procedure subsize1(var dest: sizety; const size: sizety);
begin
 dec(dest.cx,size.cx);
 dec(dest.cy,size.cy);
end;

function segment(const a,b: pointty): segmentty;
begin
 result.a:= a;
 result.b:= b;
end;

procedure vectortoline(const vector: graphicvectorty; out a,b: pointty);
begin
 with vector do begin
  a:= start;
  case direction of
   gd_right: begin
    b.x:= start.x+length;
    b.y:= start.y;
   end;
   gd_up: begin
    b.x:= start.x;
    b.y:= start.y - length;
   end;
   gd_left: begin
    b.x:= start.x - length;
    b.y:= start.y;
   end;
   gd_down: begin
    b.x:= start.x;
    b.y:= start.y + length;
   end;
  end;
 end;
end;

function deflaterect(const rect: rectty; const frame: framety): rectty;
begin
 result.x:= rect.x + frame.left;
 result.cx:= rect.cx - frame.left - frame.right;
 result.y:= rect.y + frame.top;
 result.cy:= rect.cy - frame.top - frame.bottom;
end;

procedure deflaterect1(var rect: rectty; const frame: framety);
begin
 inc(rect.x,frame.left);
 dec(rect.cx,frame.left);
 inc(rect.y,frame.top);
 dec(rect.cy,frame.top);
 dec(rect.cx,frame.right);
 dec(rect.cy,frame.bottom);
end;

function addframe(const a,b: framety): framety;
begin
 with result do begin
  left:= a.left + b.left;
  top:= a.top + b.top;
  right:= a.right + b.right;
  bottom:= a.bottom + b.bottom;
 end;
end;

procedure addframe1(var dest: framety; const frame: framety);
begin
 with dest do begin
  left:= left + frame.left;
  top:= top + frame.top;
  right:= right + frame.right;
  bottom:= bottom + frame.bottom;
 end;
end;

function subframe(const a,b: framety): framety;
begin
 with result do begin
  left:= a.left - b.left;
  top:= a.top - b.top;
  right:= a.right - b.right;
  bottom:= a.bottom - b.bottom;
 end;
end;

procedure subframe1(var dest: framety; const frame: framety);
begin
 with dest do begin
  left:= left - frame.left;
  top:= top - frame.top;
  right:= right - frame.right;
  bottom:= bottom - frame.bottom;
 end;
end;

function pointinrect(const point: pointty; const rect: rectty): boolean;
     //true if point is in rect
begin
 result:= (point.x >= rect.x) and (point.x < rect.x + rect.cx) and
          (point.y >= rect.y) and (point.y < rect.y + rect.cy);
end;

function rectcenter(const arect: rectty): pointty;
begin
 with arect do begin
  result.x:= x + cx div 2;
  result.y:= y + cy div 2;
 end;
end;

procedure centerrect(apos: pointty; asize: integer; out rect: rectty);
var
 int1: integer;
begin
 int1:= asize div 2;
 with rect do begin
  x:= apos.x - int1;
  y:= apos.y - int1;
  cx:= asize;
  cy:= asize;
 end;
end;

function inflaterect(const rect: rectty; value: integer): rectty;
begin
 with rect do begin
  result.x:= x - value;
  result.y:= y - value;
  result.cx:= cx + value + value;
  result.cy:= cy + value + value;
 end;
end;

function inflaterect(const rect: rectty; const frame: framety): rectty;
begin
 result.x:= rect.x - frame.left;
 result.cx:= rect.cx + frame.left + frame.right;
 result.y:= rect.y - frame.top;
 result.cy:= rect.cy + frame.top + frame.bottom;
end;

procedure inflaterect1(var rect: rectty; value: integer);
begin
 with rect do begin
  dec(x,value);
  dec(y,value);
  inc(cx,value);
  inc(cx,value);
  inc(cy,value);
  inc(cy,value);
 end;
end;

procedure inflaterect1(var rect: rectty; const frame: framety);
begin
 dec(rect.x,frame.left);
 inc(rect.cx,frame.left);
 dec(rect.y,frame.top);
 inc(rect.cy,frame.top);
 inc(rect.cx,frame.right);
 inc(rect.cy,frame.bottom);
end;


procedure inflateframe(var frame: framety; value: integer);
begin
 inc(frame.left,value);
 inc(frame.top,value);
 inc(frame.right,value);
 inc(frame.bottom,value);
end;

function inflateframe1(const frame: framety; value: integer): framety;
begin
 result.left:= frame.left + value;
 result.top:= frame.top + value;
 result.right:= frame.right + value;
 result.bottom:= frame.bottom + value;
end;


function moverect(const rect: rectty; const dist: pointty): rectty;
begin
 result.x:= rect.x + dist.x;
 result.y:= rect.y + dist.y;
 result.size:= rect.size;
end;

procedure moverect1(var rect: rectty; const dist: pointty);
begin
 inc(rect.x,dist.x);
 inc(rect.y,dist.y);
end;

function removerect(const rect: rectty; const dist: pointty): rectty;
begin
 result.x:= rect.x - dist.x;
 result.y:= rect.y - dist.y;
 result.size:= rect.size;
end;

procedure removerect1(var rect: rectty; const dist: pointty);
begin
 dec(rect.x,dist.x);
 dec(rect.y,dist.y);
end;

function intersectrect(const a,b: rectty; out dest: rectty): boolean;
var
 rect1: rectty;
begin
 with rect1 do begin
  if a.x > b.x then begin
   x:= a.x;
   if a.x + a.cx > b.x + b.cx then begin
    cx:= b.x + b.cx - a.x;
   end
   else begin
    cx:= a.cx;
   end;
  end
  else begin
   x:= b.x;
   if b.x + b.cx > a.x + a.cx then begin
    cx:= a.x + a.cx - b.x;
   end
   else begin
    cx:= b.cx;
   end;
  end;
  if a.y > b.y then begin
   y:= a.y;
   if a.y + a.cy > b.y + b.cy then begin
    cy:= b.y + b.cy - a.y;
   end
   else begin
    cy:= a.cy;
   end;
  end
  else begin
   y:= b.y;
   if b.y + b.cy > a.y + a.cy then begin
    cy:= a.y + a.cy - b.y;
   end
   else begin
    cy:= b.cy;
   end;
  end;
  if (cx <= 0) or (cy <= 0) then begin
   result:= false;
   dest:= nullrect;
  end
  else begin
   result:= true;
   dest:= rect1;
  end;
 end;
end;

function intersectrect(const a,b: rectty): rectty;
begin
 intersectrect(a,b,result);
end;

function testintersectrect(const a,b: rectty): boolean;
     //true on intersection
var
 rect1: rectty;
begin
 result:= intersectrect(a,b,rect1);
end;

function rectinrect(const inner,outer: rectty): boolean;

 procedure normalize(const rect: rectty; out topleft,bottomright: pointty);
 begin
  with rect do begin
   if cx < 0 then begin
    topleft.x:= x + cx;
    bottomright.x:= x;
   end
   else begin
    topleft.x:= x;
    bottomright.x:= x + cx;
   end;
   if cy < 0 then begin
    topleft.y:= y + cy;
    bottomright.y:= y;
   end
   else begin
    topleft.y:= y;
    bottomright.y:= y + cy;
   end;
  end;
 end;

var
 itopleft,ibottomright: pointty;
 otopleft,obottomright: pointty;
begin
 normalize(inner,itopleft,ibottomright);
 normalize(outer,otopleft,obottomright);
 result:= (itopleft.x >= otopleft.x) and (ibottomright.x <= obottomright.x) and
          (itopleft.y >= otopleft.y) and (ibottomright.y <= obottomright.y);
end;

procedure clipinrect1(var point: pointty; const boundsrect: rectty);
begin
 with boundsrect do begin
  if point.x < x then begin
   point.x:= x;
  end;
  if point.x >= x + cx then begin
   point.x:= x + cx - 1;
  end;
  if point.y < y then begin
   point.y:= y;
  end;
  if point.y >= y + cy then begin
   point.y:= y + cy - 1;
  end;
 end;
end;

function clipinrect(const point: pointty; const boundsrect: rectty): pointty;
begin
 result:= point;
 clipinrect1(result,boundsrect);
end;

procedure clipinrect1(var rect: rectty; const boundsrect: rectty);
begin
 with boundsrect do begin
  if rect.x < x then begin
   rect.x:= x;
  end;
  if rect.x + rect.cx > x + cx then begin
   rect.x:= x + cx - rect.cx;
   if rect.x < x then begin
    rect.x:= x;
    rect.cx:= cx;
   end;
  end;
  if rect.y < y then begin
   rect.y:= y;
  end;
  if rect.y + rect.cy > y + cy then begin
   rect.y:= y + cy - rect.cy;
   if rect.y < y then begin
    rect.y:= y;
    rect.cy:= cy;
   end;
  end;
 end;
end;

function clipinrect(const rect: rectty; const boundsrect: rectty): rectty;
begin
 result:= rect;
 clipinrect1(result,boundsrect);
end;

end.

