{ MSEgui Copyright (c) 2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mselinetria;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msegraphics,msegraphutils,msetriaglob;
 
procedure linestria(var drawinfo: drawinfoty; out apoints: ppointty;
                                                     out apointcount: integer);
procedure linesegmentstria(var drawinfo: drawinfoty;
                  out atriangles: ptrianglety; out atrianglecount: integer);

implementation
type
 lineshiftvectorty = record
  shift: pointty;
  d: pointty;  //delta
  c: integer;  //length
 end;
 lineshiftinfoty = record
  dist: integer;
  offsx,offsy: integer;
  pointa: ppointty;
  pointb: ppointty;
  linestart: ppointty;
  v: lineshiftvectorty;
  offs: pointty;
  dest: ppointty;
  dashlen: integer;
  dashind: integer;
  dashpos: integer;
  dashref: integer;
 end;
 plineshiftinfoty = ^lineshiftinfoty;

const
 arctablesize = 20; // max diameter
 arcrowsize = arctablesize div 2 - 2;
 arcscalefact = 256;  //value scaling = 128
type
 arctablety = array[0..arctablesize,0..arcrowsize] of byte;
const
 arctable: arctablety = (
 (0,0,0,0,0,0,0,0,0), //0
 (0,0,0,0,0,0,0,0,0), //1
 (0,0,0,0,0,0,0,0,0), //2
 (33,0,0,0,0,0,0,0,0), //3
 (17,0,0,0,0,0,0,0,0), //4
 (11,51,0,0,0,0,0,0,0), //5
 (7,33,0,0,0,0,0,0,0), //6
 (5,23,62,0,0,0,0,0,0), //7
 (4,17,43,0,0,0,0,0,0), //8
 (3,13,33,69,0,0,0,0,0), //9
 (3,11,26,51,0,0,0,0,0), //10
 (2,9,21,40,75,0,0,0,0), //11
 (2,7,17,33,57,0,0,0,0), //12
 (2,6,14,27,46,79,0,0,0), //13
 (1,5,12,23,38,62,0,0,0), //14
 (1,5,11,20,33,51,82,0,0), //15
 (1,4,9,17,28,43,66,0,0), //16
 (1,4,8,15,24,37,55,85,0), //17
 (1,3,7,13,22,33,48,69,0), //18
 (1,3,7,12,19,29,41,59,87), //19
 (1,3,6,11,17,26,37,51,72) //20
);
//
//todo: optimize smooth line generation
//
procedure calclineshift(const drawinfo: drawinfoty; var info: lineshiftinfoty);
begin
 with info do begin
  v.d.x:= pointb^.x - pointa^.x;
  v.d.y:= pointb^.y - pointa^.y;
  v.c:= round(sqrt(v.d.x*v.d.x + v.d.y*v.d.y)); //todo: optimize
  offsx:= 0;
  offsy:= 0;
  if v.c = 0 then begin
   v.shift.x:= 0;
   v.shift.y:= 0;
  end
  else begin
   v.shift.x:= (v.d.y*dist) div v.c;
   v.shift.y:= (v.d.x*dist) div v.c;
   if dist and $10000 <> 0 then begin //odd, shift 0.5 pixel
    offsx:= abs(v.d.y shl 15) div v.c;
    offsy:= abs(v.d.x shl 15) div v.c;
   end;
  end;
  offs.x:= (drawinfo.origin.x shl 16) + v.shift.x div 2 + offsx;
  offs.y:= (drawinfo.origin.y shl 16) - v.shift.y div 2 + offsy;
  linestart:= pointa;
 end;
end;

procedure shiftpoint(var info: lineshiftinfoty);
var
 x1,y1: integer;
begin
 with info do begin
  x1:= (pointa^.x shl 16) + offs.x;
  y1:= (pointa^.y shl 16) + offs.y;
  dest^.x:= x1;
  dest^.y:= y1;
  inc(dest);
  dest^.x:= x1 - v.shift.x;
  dest^.y:= y1 + v.shift.y;
  inc(dest);
  pointa:= pointb;
  inc(pointb);
 end;
end;

type
 intersectinfoty = record
  da,db: pointty;
  p0,p1: ppointty;
  isect: pointty;
  axbx,axby,aybx,ayby: int64;
  q: integer;
 end;

procedure intersect2(var info: intersectinfoty);
begin
 with info do begin
//xa == (dxa*dxb*y0 - dxa*dxb*y1 + dxa*dyb*x1 - dxb*dya*x0)/(dxa*dyb - dxb*dya)
  isect.x:= (axbx*p0^.y - axbx*p1^.y + axby*p1^.x - aybx*p0^.x) div q;
//ya == (dxa*dyb*y0 - dxb*dya*y1 - dya*dyb*x0 + dya*dyb*x1)/(dxa*dyb - dxb*dya)
  isect.y:= (axby*p0^.y - aybx*p1^.y - ayby*p0^.x + ayby*p1^.x) div q;
 end;
end;
 
function intersect(var info: intersectinfoty): boolean;
begin
 result:= false;
 with info do begin
  axby:= da.x*db.y;
  aybx:= da.y*db.x;
  q:= axby - aybx;
  if q <> 0 then begin
   result:= true;
   axbx:= da.x*db.x;
   ayby:= da.y*db.y;
   intersect2(info);
  end;
 end;
end;

procedure updatestarttria(var drawinfo: drawinfoty; var li: lineshiftinfoty);
var
 sx1,sy1,sx2,sy2: integer;
 int1: integer;
 po1: ppointty;
 po2: pbyte;
 pt1,pt2: pointty;
 first: boolean;
begin
 with triagcty(drawinfo.gc.platformdata).d do begin
  if (linewidth = 0) or (capstyle = cs_projecting) then begin
   sx1:= li.v.shift.y div 2 - li.offsy;
   sy1:= li.v.shift.x div 2 - li.offsx;
   with (li.dest-2)^ do begin
    x:= x - sx1;
    y:= y - sy1;
   end;
   with (li.dest-1)^ do begin
    x:= x - sx1;
    y:= y - sy1;
   end;
  end
  else begin
   if capstyle = cs_round then begin
    po1:= li.dest;
    dec(po1);
    pt2:= (po1)^;
    dec(po1);
    pt1:= (po1)^;
    if linewidth <= arctablesize then begin
     sx1:= (li.v.shift.y) div 2;      //axial
     sy1:= (li.v.shift.x) div 2;      
     po1^.x:= (pt1.x + pt2.x) div 2 - sx1;
     po1^.y:= (pt1.y + pt2.y) div 2 - sy1;
     inc(po1);
     po2:= @arctable[linewidth];
     inc(po2,linewidth1 div 2 - 2);
     first:= true;
     for int1:= linewidth div 2 - 1 downto 1 do begin
      if not first then begin
       po1^:= (po1-2)^;            //0
       inc(po1);
       po1^:= (po1-2)^;            //1
       inc(po1);
      end;
      sx1:= (li.v.shift.y*int1) div linewidth1;      //axial
      sy1:= (li.v.shift.x*int1) div linewidth1;
      sx2:= (li.v.shift.x*po2^) div arcscalefact;    //orthogonal
      sy2:= (li.v.shift.y*po2^) div arcscalefact;
      po1^.x:= pt1.x - sx1 - sx2; //2
      po1^.y:= pt1.y - sy1 + sy2;
      inc(po1);
      if not first then begin
       po1^:= (po1-2)^;            //3
       inc(po1);
       po1^:= (po1-2)^;            //4
       inc(po1);
      end;
      po1^.x:= pt2.x - sx1 + sx2; //5
      po1^.y:= pt2.y - sy1 - sy2;
      inc(po1);
      dec(po2);
      first:= false;
     end;
     if not first then begin
      po1^:= (po1-2)^;     //0
      inc(po1);
      po1^:= (po1-2)^;     //1
      inc(po1);
      po1^:= pt1;          //2
      inc(po1);
      po1^:= (po1-2)^;     //3
      inc(po1);
     end;
     po1^:= pt1;          //4
     inc(po1);
     po1^:= pt2;          //5
     inc(po1);
     po1^:= pt1;          //0
     inc(po1);
     po1^:= pt2;          //1
     inc(po1);
     li.dest:= po1;
    end;
   end;   
  end;
 end;
end;

procedure updatestartstrip(var drawinfo: drawinfoty; var li: lineshiftinfoty);
var
 sx1,sy1,sx2,sy2: integer;
 int1: integer;
 po1: ppointty;
 po2: pbyte;
 pt1,pt2: pointty;
begin
 with triagcty(drawinfo.gc.platformdata).d do begin
  if capstyle = cs_projecting then begin
   sx1:= li.v.shift.y div 2 - li.offsy;
   sy1:= li.v.shift.x div 2 - li.offsx;
   with (li.dest-2)^ do begin
    x:= x - sx1;
    y:= y - sy1;
   end;
   with (li.dest-1)^ do begin
    x:= x - sx1;
    y:= y - sy1;
   end;
  end
  else begin
   if capstyle = cs_round then begin
    po1:= li.dest;
    dec(po1);
    pt2:= (po1)^;
    dec(po1);
    pt1:= (po1)^;
    if linewidth <= arctablesize then begin
     sx1:= (li.v.shift.y) div 2;      //axial
     sy1:= (li.v.shift.x) div 2;      
     po1^.x:= (pt1.x + pt2.x) div 2 - sx1;
     po1^.y:= (pt1.y + pt2.y) div 2 - sy1;
     inc(po1);
     po2:= @arctable[linewidth];
     inc(po2,linewidth1 div 2 - 2);
     for int1:= linewidth div 2 - 1 downto 1 do begin
      sx1:= (li.v.shift.y*int1) div linewidth1;      //axial
      sy1:= (li.v.shift.x*int1) div linewidth1;
      sx2:= (li.v.shift.x*po2^) div arcscalefact;    //orthogonal
      sy2:= (li.v.shift.y*po2^) div arcscalefact;
      po1^.x:= pt1.x - sx1 - sx2;
      po1^.y:= pt1.y - sy1 + sy2;
      inc(po1);      
      po1^.x:= pt2.x - sx1 + sx2;
      po1^.y:= pt2.y - sy1 - sy2;
      inc(po1);
      dec(po2);
     end;
     po1^:= pt1;
     inc(po1);
     po1^:= pt2;
     inc(po1);
     li.dest:= po1;
    end;
   end;
  end;
 end;
end;

procedure updateendtria(var drawinfo: drawinfoty; var li: lineshiftinfoty);
var
 sx1,sy1,sx2,sy2: integer;
 int1: integer;
 po1: ppointty;
 po2: pbyte;
 pt1,pt2: pointty;
begin
 with triagcty(drawinfo.gc.platformdata).d do begin
  if (linewidth = 0) or (capstyle = cs_projecting) then begin
   sx1:= li.v.shift.y div 2  + li.offsy;
   sy1:= li.v.shift.x div 2  + li.offsx;
   with (li.dest-2)^ do begin
    x:= x + sx1;
    y:= y + sy1;
   end;
   with (li.dest-1)^ do begin
    x:= x + sx1;
    y:= y + sy1;
   end;
  end
  else begin
   if capstyle = cs_round then begin
    if linewidth <= arctablesize then begin
     po1:= li.dest;
     (po1-4)^:= (po1-2)^;
     pt1:= (po1-2)^;
     pt2:= (po1-1)^;
     po1^:= pt1;
     inc(po1);
     po1^:= pt2;
     inc(po1);
     po2:= @arctable[linewidth];
     for int1:= 1 to linewidth div 2 - 1 do begin
      sx1:= (li.v.shift.y*int1) div linewidth1;      //axial
      sy1:= (li.v.shift.x*int1) div linewidth1;
      sx2:= (li.v.shift.x*po2^) div arcscalefact;    //orthogonal
      sy2:= (li.v.shift.y*po2^) div arcscalefact;
      po1^.x:= pt1.x + sx1 - sx2;       //0
      po1^.y:= pt1.y + sy1 + sy2;
      inc(po1);      
      po1^:= (po1-2)^;                  //1
      inc(po1);      
      po1^:= (po1-2)^;                  //2
      inc(po1);
      po1^.x:= pt2.x + sx1 + sx2;       //3
      po1^.y:= pt2.y + sy1 - sy2;
      inc(po1);
      po1^:= (po1-2)^;                  //4
      inc(po1);      
      po1^:= (po1-2)^;                  //5      
      inc(po1);
      inc(po2);
     end;
     sx1:= (li.v.shift.y) div 2;      //axial
     sy1:= (li.v.shift.x) div 2;      
     po1^.x:= (pt1.x + pt2.x) div 2 + sx1;
     po1^.y:= (pt1.y + pt2.y) div 2 + sy1;
     inc(po1);
     li.dest:= po1;
     exit;
    end;
   end;
  end;
 end;
 (li.dest-4)^:= (li.dest-2)^;
end;

procedure updateendstrip(var drawinfo: drawinfoty; var li: lineshiftinfoty);
var
 sx1,sy1,sx2,sy2: integer;
 int1: integer;
 po1: ppointty;
 po2: pbyte;
 pt1,pt2: pointty;
begin
 with triagcty(drawinfo.gc.platformdata).d do begin
  if (linewidth = 0) or (capstyle = cs_projecting) then begin
   sx1:= li.v.shift.y div 2  + li.offsy;
   sy1:= li.v.shift.x div 2  + li.offsx;
   with (li.dest-2)^ do begin
    x:= x + sx1;
    y:= y + sy1;
   end;
   with (li.dest-1)^ do begin
    x:= x + sx1;
    y:= y + sy1;
   end;
  end
  else begin
   if capstyle = cs_round then begin
    if linewidth <= arctablesize then begin
     po1:= li.dest;
     pt1:= (po1-2)^;
     pt2:= (po1-1)^;
     po2:= @arctable[linewidth];
     for int1:= 1 to linewidth div 2 - 1 do begin
      sx1:= (li.v.shift.y*int1) div linewidth1;      //axial
      sy1:= (li.v.shift.x*int1) div linewidth1;
      sx2:= (li.v.shift.x*po2^) div arcscalefact;    //orthogonal
      sy2:= (li.v.shift.y*po2^) div arcscalefact;
      po1^.x:= pt1.x + sx1 - sx2;
      po1^.y:= pt1.y + sy1 + sy2;
      inc(po1);      
      po1^.x:= pt2.x + sx1 + sx2;
      po1^.y:= pt2.y + sy1 - sy2;
      inc(po1);
      inc(po2);
     end;
     sx1:= (li.v.shift.y) div 2;      //axial
     sy1:= (li.v.shift.x) div 2;      
     po1^.x:= (pt1.x + pt2.x) div 2 + sx1;
     po1^.y:= (pt1.y + pt2.y) div 2 + sy1;
     inc(po1);
     li.dest:= po1;
    end;
   end;
  end;
 end;
end;

procedure dashinit(var drawinfo: drawinfoty; var li: lineshiftinfoty);
var
 int1: integer;
begin
 with drawinfo,triagcty(gc.platformdata).d do begin
//  allocbuffer(buffer,3*sizeof(pointty)); //possible first triangle
  buffer.cursize:= 0;
  li.dest:= buffer.buffer;
  li.dashlen:= 0;
  for int1:= 1 to length(xftdashes) do begin
   li.dashlen:= li.dashlen + ord(xftdashes[int1]);
  end;
 end;
end;

procedure dash(var drawinfo: drawinfoty; var li: lineshiftinfoty;
                  const start: boolean; const endpoint: boolean);
var
 po3: ppointty;
 pt0: pointty;
 dx,dy: integer;
 dashstop,dashpos,dashind: integer;
 x1,y1: integer;
 int1: integer;
begin
 with drawinfo,triagcty(gc.platformdata).d do begin
  if start then begin
   dashpos:= ord(xftdashes[1]);
   dashind:= 1;
   li.dashref:= 0;
  end
  else begin
   dashpos:= li.dashpos-li.dashref;
   dashind:= li.dashind;
  end;
  dashstop:= li.v.c;
  int1:= ((dashstop-dashpos) div li.dashlen + 1)*length(xftdashes) + 3*2;
                     //+3*2 -> additional memory for ends and vertex
  if capstyle = cs_round then begin
   int1:= int1*linewidth1;
  end;
  int1:= int1 * 6*sizeof(pointty); //2 triangles per segment
  extendbuffer(buffer,int1,li.dest);
  po3:= li.dest;
  pt0.x:= (li.linestart^.x shl 16) + li.offs.x;
  pt0.y:= (li.linestart^.y shl 16) + li.offs.y;
  dx:= (li.v.d.x shl 16) div li.v.c;
  dy:= (li.v.d.y shl 16) div li.v.c;
  while dashpos < dashstop do begin
   if odd(dashind) then begin //end dash
    x1:= pt0.x + dashpos*dx; 
    y1:= pt0.y + dashpos*dy; 
    po3^.x:= x1;
    po3^.y:= y1; 
    inc(po3);
    po3^:= (po3-2)^;
    inc(po3);
    po3^.x:= x1; 
    po3^.y:= y1; 
    inc(po3);
    po3^.x:= x1 - li.v.shift.x;
    po3^.y:= y1 + li.v.shift.y;
    inc(po3);
    li.dest:= po3;
    if linewidth <> 0 then begin
     updateendtria(drawinfo,li);
     po3:= li.dest;
    end;
   end
   else begin               //start dash
    x1:= pt0.x + dashpos*dx; 
    y1:= pt0.y + dashpos*dy; 
    po3^.x:= x1;
    po3^.y:= y1;
    inc(po3);
    po3^.x:= x1 - li.v.shift.x;
    po3^.y:= y1 + li.v.shift.y;
    inc(po3);
    li.dest:= po3;
    if linewidth <> 0 then begin
     updatestarttria(drawinfo,li);
     po3:= li.dest;
    end;
   end;
   inc(dashind);
   if dashind > length(xftdashes) then begin
    dashind:= 1;
   end;
   dashpos:= dashpos + ord(xftdashes[dashind]);
  end;
  if odd(dashind) and endpoint then begin //end dash
   x1:= pt0.x + (li.v.d.x shl 16);
   y1:= pt0.y + (li.v.d.y shl 16);
   po3^.x:= x1;
   po3^.y:= y1;
   inc(po3);
   po3^:= (po3-2)^;
   inc(po3);
   po3^.x:= x1;
   po3^.y:= y1;
   inc(po3);
   po3^.x:= x1 - li.v.shift.x;
   po3^.y:= y1 + li.v.shift.y;
   inc(po3);
   li.dest:= po3;
   if linewidth <> 0 then begin
    updateendtria(drawinfo,li);
    po3:= li.dest;
   end;
  end;
  li.dest:= po3;
  li.dashind:= dashind;
  li.dashpos:= dashpos+li.dashref;
  li.dashref:= li.dashref+li.v.c;
 end;
end;

procedure linestria(var drawinfo: drawinfoty; out apoints: ppointty;
                                                     out apointcount: integer);
var
 li: lineshiftinfoty;
 pt0,pt1: pointty;

 procedure pushdashend;
 var
  po0: ppointty;
 begin
  po0:= li.dest;
  po0^:= pt0;
  inc(po0);
  po0^:= (po0-2)^;
  inc(po0);
  po0^:= pt0;
  inc(po0);
  po0^:= pt1;
  inc(po0);
  po0^:= pt0;
  inc(po0);
  po0^:= pt1;
  inc(po0);
  li.dest:= po0;
 end; //pushdashend

var
 int1,int2: integer;
 pointcount: integer;
 ints: intersectinfoty;
 pend: ppointty;
 bo1: boolean;
 singlepoint: array[0..1] of pointty;
 pointsbefore: ppointty;

begin
 with drawinfo,points,triagcty(gc.platformdata).d do begin
  pointsbefore:= points;
  pointcount:= count;
  if count = 1 then begin
   singlepoint[0]:= points^;    
   singlepoint[1]:= points^; //dummy segment
   points:= @singlepoint[0];
   inc(pointcount);
  end;
  if closed then begin
   inc(pointcount);
  end;
  pointcount:= pointcount*2;
  li.pointa:= points;
  pend:= points+count;
  li.pointb:= li.pointa+1;
  li.dist:= linewidth16;
  if closed then begin
   int2:= count-1;
  end
  else begin
   int2:= count-3;
  end;
  if df_dashed in gc.drawingflags then begin
   allocbuffer(buffer,(pointcount+2*linewidth)*sizeof(pointty)*3);
                                 //for round caps
   dashinit(drawinfo,li);
   calclineshift(drawinfo,li);
   shiftpoint(li);
   if (linewidth <> 0) and not closed then begin
    updatestarttria(drawinfo,li);
   end;
   bo1:= true; //start dash
   for int1:= 0 to int2 do begin
    if li.pointb = pend then begin
     li.pointb:= points;
    end;
    dash(drawinfo,li,bo1,false);
    bo1:= false;

    ints.da:= li.v.d;
    calclineshift(drawinfo,li);
    shiftpoint(li);
    ints.db:= li.v.d;
    ints.p0:= li.dest-4;
    ints.p1:= li.dest-2;
    if intersect(ints) then begin
     pt0:= ints.isect;
     inc(ints.p0);
     inc(ints.p1);
     intersect2(ints);
     pt1:= ints.isect;
    end
    else begin
     pt0:= (li.dest-2)^;
     pt1:= (li.dest-1)^;
    end;
    dec(li.dest,2);
    if odd(li.dashind) then begin //dash
     pushdashend;
    end;
   end;
   if closed then begin
    (ppointty(buffer.buffer))^:= pt0;
    (ppointty(buffer.buffer)+1)^:= pt1;
    (ppointty(buffer.buffer)+3)^:= pt1;
   end
   else begin
    dash(drawinfo,li,bo1,true);
   end;
  end
  else begin
   allocbuffer(buffer,(pointcount+2*linewidth)*sizeof(pointty));
                                 //for round caps
   li.dest:= buffer.buffer;
   calclineshift(drawinfo,li);
   shiftpoint(li);
   if not closed then begin
    updatestartstrip(drawinfo,li);
   end;
   for int1:= 0 to int2 do begin
    if li.pointb = pend then begin
     li.pointb:= points;
    end;
    ints.da:= li.v.d;
    calclineshift(drawinfo,li);
    shiftpoint(li);
    ints.db:= li.v.d;
    ints.p0:= li.dest-4;
    ints.p1:= li.dest-2;
    if intersect(ints) then begin
     ints.p1^:= ints.isect;
     inc(ints.p0);
     inc(ints.p1);
     intersect2(ints);
     ints.p1^:= ints.isect;
    end;
   end;
   if closed then begin
    (ppointty(buffer.buffer))^:= (ints.p1-1)^;
    (ppointty(buffer.buffer)+1)^:= ints.p1^;
   end
   else begin
    shiftpoint(li);
    updateendstrip(drawinfo,li);
   end;
  end;
  points:= pointsbefore;
  apoints:= buffer.buffer;
  apointcount:= li.dest-ppointty(buffer.buffer);
 end;
end;

procedure linesegmentstria(var drawinfo: drawinfoty;
                  out atriangles: ptrianglety; out atrianglecount: integer);
var
 int1: integer;
 li: lineshiftinfoty; 
begin   
 with drawinfo,drawinfo.points,triagcty(gc.platformdata).d do begin
  li.pointa:= points;
  li.pointb:= li.pointa+1;
  li.dist:= linewidth16;
  allocbuffer(buffer,count*(6+6*linewidth)*sizeof(pointty));
                         //for round caps
  if df_dashed in gc.drawingflags then begin
   dashinit(drawinfo,li);
   for int1:= 0 to (count div 2)-1 do begin
    calclineshift(drawinfo,li);
    shiftpoint(li);
    if linewidth <> 0 then begin
     updatestarttria(drawinfo,li);
    end;
    dash(drawinfo,li,true,true);
    li.pointa:= li.pointb;
    inc(li.pointb);
   end;
  end
  else begin
   li.dest:= buffer.buffer;
   for int1:= 0 to (count div 2)-1 do begin
    calclineshift(drawinfo,li);
    shiftpoint(li);
    updatestarttria(drawinfo,li);
    inc(li.dest);
    li.dest^:= (li.dest-2)^;
    inc(li.dest);
    shiftpoint(li);
    updateendtria(drawinfo,li);
//    (li.dest-4)^:= (li.dest-2)^;
   end;
  end;
  atriangles:= buffer.buffer;
  atrianglecount:= (li.dest-ppointty(buffer.buffer)) div 3;
 end;
end;

end.
