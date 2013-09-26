{ MSEgui Copyright (c) 2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseellipsetria;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msegraphics,msegraphutils,msetriaglob;
 
procedure fillellipsetria(var drawinfo: drawinfoty; out apoints: ppointty;
                                         out apointcount: integer);
                 //returns trifan
procedure fillarctria(var drawinfo: drawinfoty; out apoints: ppointty;
                                         out apointcount: integer);
                 //returns trifan
function arctria(var drawinfo: drawinfoty; out apoints: ppointty;
                                         out apointcount: integer): boolean;
           //true if triangles, tristrip otherwise
function ellipsetria(var drawinfo: drawinfoty; out apoints: ppointty;
                                         out apointcount: integer): boolean;
           //true if triangles, tristrip otherwise
                 

implementation
uses
 mselinetria;
 
procedure adjustellipsecenter(const drawinfo: drawinfoty;
                                        var center: pointty);
begin
 with drawinfo,rect.rect^ do begin
  center.x:= (x+origin.x) shl 16;
  if not odd(cx) then begin
   center.x:= center.x + $8000;
  end
  else begin
   center.x:= center.x + $10000;
  end;
  center.y:= (y+origin.y) shl 16;
  if not odd(cy) then begin
   center.y:= center.y + $8000;
  end
  else begin
   center.y:= center.y + $10000;
  end;
 end;
end;

procedure fillellipsetria(var drawinfo: drawinfoty; out apoints: ppointty;
                                         out apointcount: integer);
//todo: optimize
var
 rea1,sx,sy,f,si,co: real;
 x1,y1: integer;
 q0,q1,q2,q3: ppointty;
 npoints: integer;
 int1: integer;
 center: pointty;
begin
 with drawinfo,drawinfo.rect.rect^ do begin
  int1:= cx;
  if cy > int1 then begin
   int1:= cy;
  end;
  if int1 = 0 then begin
   apointcount:= 0;
   apoints:= nil;
   exit;
  end;
  int1:= (int1+1) div 2; //samples per quadrant
  rea1:= pi/(2*int1);
  npoints:= 2+4*int1; //center + endpoint
  allocbuffer(buffer,npoints*sizeof(pointty));
  si:= sin(rea1);
  co:= cos(rea1);
  adjustellipsecenter(drawinfo,center);
  q0:= buffer.buffer;
  q0^:= center;
  inc(q0);
  q1:= q0+int1;
  q2:= q1+int1;
  q3:= q2+int1;
  if cx > cy then begin
   f:= cy/cx;
   sx:= cx*(65536/2);
   sy:= 0;    
   for int1:= int1-1 downto 0 do begin
    y1:= round(sy*f);
    x1:= round(sx);
    q0^.x:= center.x + x1;
    q0^.y:= center.y - y1;
    inc(q0);
    q2^.x:= center.x - x1;
    q2^.y:= center.y + y1;
    inc(q2);
    x1:= round(sx*f);
    y1:= round(sy);
    q1^.x:= center.x - y1;
    q1^.y:= center.y - x1;
    inc(q1);
    q3^.x:= center.x + y1;
    q3^.y:= center.y + x1;
    inc(q3);
    rea1:= sx;
    sx:= co*sx-si*sy;
    sy:= co*sy+si*rea1;
   end;
  end
  else begin
   f:= cx/cy;
   sy:= cy*(65536/2);
   sx:= 0;    
   for int1:= int1-1 downto 0 do begin
    x1:= round(sx*f);
    y1:= round(sy);
    q0^.y:= center.y - y1;
    q0^.x:= center.x + x1;
    inc(q0);
    q2^.y:= center.y + y1;
    q2^.x:= center.x - x1;
    inc(q2);
    y1:= round(sy*f);
    x1:= round(sx);
    q1^.y:= center.y - x1;
    q1^.x:= center.x - y1;
    inc(q1);
    q3^.y:= center.y + x1;
    q3^.x:= center.x + y1;
    inc(q3);
    rea1:= sx;
    sx:= co*sx-si*sy;
    sy:= co*sy+si*rea1;
   end;
  end;
  q3^:= (ppointty(buffer.buffer)+1)^; //endpoint
  apoints:= buffer.buffer;
  apointcount:= npoints;
 end;
end;

procedure fillarctria(var drawinfo: drawinfoty; out apoints: ppointty;
                                         out apointcount: integer);
                 //returns trifan
var
 rea1,sx,sy,cx1,cy1,si,co: real;
 x1,y1: integer;
 q0: ppointty;
 npoints: integer;
 int1: integer;
 center: pointty;
begin
 with drawinfo,triagcty(gc.platformdata).d,drawinfo.arc,rect^ do begin
  int1:= cx;
  if cy > int1 then begin
   int1:= cy;
  end;
  if int1 = 0 then begin
   apointcount:= 0;
   apoints:= nil;
   exit;
  end;
  int1:= round(int1*abs(extentang)/pi); //steps
  adjustellipsecenter(drawinfo,center);
  cx1:= cx * (65536 div 2);
  cy1:= cy * (65536 div 2);
  sx:= cos(startang);
  sy:= sin(startang);
  rea1:= extentang/int1; //step
  si:= sin(rea1);
  co:= cos(rea1);
  npoints:= int1+2; //center + endpoint
  allocbuffer(buffer,npoints*sizeof(pointty));
  q0:= ppointty(buffer.buffer)+1;
  for int1:= int1 downto 0 do begin
   x1:= round(cx1*sx);
   y1:= round(cy1*sy);
   q0^.x:= center.x + x1;
   q0^.y:= center.y - y1;
   inc(q0);
   rea1:= sx;
   sx:= co*sx-si*sy;
   sy:= co*sy+si*rea1;
  end;
  if not pieslice then begin
   dec(q0);
   with (ppointty(buffer.buffer)+1)^ do begin
    center.x:= (q0^.x + x) div 2;
    center.y:= (q0^.y + y) div 2;
   end;
  end;
  ppointty(buffer.buffer)^:= center;   
  apoints:= buffer.buffer;
  apointcount:= npoints;
 end;
end;

function arctria(var drawinfo: drawinfoty; out apoints: ppointty;
                                         out apointcount: integer): boolean;
var
 rea1,sx,sy,w,cxw,cyw,cx1,cy1,cx2,cy2,{xdy,ydx,}si,co: real;
 x1,y1,x2,y2,x3,y3,x4,y4: integer;
 q0: ppointty;
// po1: ptrianglety;
 npoints: integer;
 int1: integer;
 center: pointty;
 circle: boolean;
 step,dashstep,dashsum: real;
 dashindex: integer;
 wasoff: boolean;
 li: lineshiftinfoty;
 shiftfact: integer;
begin
 result:= false;
 with drawinfo,drawinfo.arc,rect^,triagcty(gc.platformdata).d do begin
  li.offsx:= 0;
  li.offsy:= 0;
  int1:= cx;
  if cy > int1 then begin
   int1:= cy;
  end;
  if int1 = 0 then begin
   apoints:= nil;
   apointcount:= 0;
   exit;
  end;
  li.reverse:= extentang >= 0;
  if li.reverse then begin
   shiftfact:= -2;
  end
  else begin
   shiftfact:= 2;
  end;
  int1:= round(int1*abs(extentang)/pi); //steps
  if int1 = 0 then begin
   int1:= 1;
  end;
  adjustellipsecenter(drawinfo,center);
  cx1:= cx * (65536 div 2);
  cx2:= cx1*cx1;
  cy1:= cy * (65536 div 2);
  cy2:= cy1*cy1;
  w:= linewidth16 div 2;
  cxw:= cx1*w;
  cyw:= cy1*w;
  sx:= cos(startang);
  sy:= sin(startang);
  if df_dashed in gc.drawingflags then begin
   result:= true;
   int1:= int1*4; //quarter pixel resolution
   circle:= cx = cy;
   step:= extentang/int1; //step
   si:= sin(step);
   co:= cos(step);
   if circle then begin
    dashstep:= cx*step/2;
   end
   else begin
    step:= step / 65536;
   end;
   dashsum:= -ord(xftdashes[1]);
   dashindex:= 1;
   wasoff:= false;
   allocbuffer(buffer,(6*int1+12)*sizeof(pointty));
           //+ start dummy + endpoint, max
   q0:= ppointty(buffer.buffer)+2;
   for int1:= int1 downto 0 do begin
    x1:= round(cx1*sx);
    y1:= round(cy1*sy);
    rea1:= sqrt(cx2*sy*sy+cy2*sx*sx);
    if odd(dashindex) then begin
     if rea1 = 0 then begin
      x2:= round(w);
      y2:= 0;
     end
     else begin
      x2:= round(cyw*sx/rea1);
      y2:= round(cxw*sy/rea1);
     end;
     x3:= center.x + x1 + x2;
     y3:= center.y - y1 - y2;
     x4:= center.x + x1 - x2;
     y4:= center.y - y1 + y2;
     if not wasoff then begin
      q0^.x:= x3;
      q0^.y:= y3;
      inc(q0);
      q0^:= (q0-2)^;
      inc(q0);
      q0^.x:= x3;
      q0^.y:= y3;
      inc(q0);
      q0^.x:= x4;
      q0^.y:= y4;
      inc(q0);
     end
     else begin
      wasoff:= false;
     end;
     q0^.x:= x3;
     q0^.y:= y3;
     inc(q0);
     q0^.x:= x4;
     q0^.y:= y4;
     inc(q0);
    end
    else begin
     if not wasoff then begin
      wasoff:= true;
      dec(q0,2);
     end;
    end;
    if not circle then begin
     dashstep:= rea1*step;
    end;
    dashsum:= dashsum + dashstep;
    if dashsum >= 0 then begin
     inc(dashindex);
     if dashindex > length(xftdashes) then begin
      dashindex:= 1;
     end;
     dashsum:= dashsum-ord(xftdashes[dashindex]);
    end;
    rea1:= sx;
    sx:= co*sx-si*sy;
    sy:= co*sy+si*rea1;
   end;
//    po1:= pxtriangle(buffer.buffer)+2;
   apoints:= ppointty(ptrianglety(buffer.buffer)+2);
   apointcount:= q0-apoints;
  end
  else begin
   rea1:= extentang/int1; //step
   si:= sin(rea1);
   co:= cos(rea1);
   npoints:= 2*(int1+linewidth1)+2; //+ endpoint + round caps
   allocbuffer(buffer,npoints*sizeof(pointty));
   q0:= buffer.buffer;
   for int1:= 0 to int1 do begin
    x1:= round(cx1*sx);
    y1:= round(cy1*sy);
    rea1:= sqrt(cx2*sy*sy+cy2*sx*sx);
    if rea1 = 0 then begin
     x2:= round(w);
     y2:= 0;
    end
    else begin
     x2:= round(cyw*sx/rea1);
     y2:= round(cxw*sy/rea1);
    end;
    q0^.x:= center.x + x1 + x2;
    q0^.y:= center.y - y1 - y2;
    inc(q0);
    q0^.x:= center.x + x1 - x2;
    q0^.y:= center.y - y1 + y2;
    inc(q0);
    if int1 = 0 then begin
     if not (trf_capbutt in triaflags) then begin
      li.v.shift.x:= shiftfact*x2;
      li.v.shift.y:= shiftfact*y2;
      li.dest:= q0;
      updatestartstrip(drawinfo,li);
      q0:= li.dest;
     end;
    end;
    rea1:= sx;
    sx:= co*sx-si*sy;
    sy:= co*sy+si*rea1;
   end;
   if not (trf_capbutt in triaflags) then begin
    li.v.shift.x:= shiftfact*x2;
    li.v.shift.y:= shiftfact*y2;
    li.dest:= q0;
    updateendstrip(drawinfo,li);
    q0:= li.dest;
   end;
   apoints:= buffer.buffer;
   apointcount:= q0-apoints;
  end;
 end;
end;

function ellipsetria(var drawinfo: drawinfoty; out apoints: ppointty;
                                         out apointcount: integer): boolean;
var
 rea1,sx,sy,w,cxw,cyw,cx1,cy1,cx2,cy2,{xdy,ydx,}si,co: real;
 x1,y1,x2,y2: integer;
 q0,q1,q2,q3: ppointty;
 npoints: integer;
 int1,int2: integer;
 center: pointty;
 circle: boolean;
begin
 result:= false;
 with drawinfo,rect.rect^,triagcty(gc.platformdata).d do begin
  if df_dashed in gc.drawingflags then begin
   arc.startang:= 0;
   arc.extentang:= 2*pi;
   result:= arctria(drawinfo,apoints,apointcount);
   exit;
  end;
  circle:= cx = cy;
  int1:= cx;
  if cy > int1 then begin
   int1:= cy;
  end;
  if int1 = 0 then begin
   apoints:= nil;
   apointcount:= 0;
   exit;
  end;
  int1:= (int1+1) div 2; //samples per quadrant
  rea1:= pi/(2*int1);
  npoints:= 8*int1+2; //+ endpoint
  allocbuffer(buffer,npoints*sizeof(pointty));
  si:= sin(rea1);
  co:= cos(rea1);
  adjustellipsecenter(drawinfo,center);
  int2:= int1*2;
  q0:= buffer.buffer;
  q1:= q0+int2;
  q2:= q1+int2;
  q3:= q2+int2;
  cx1:= cx * (65536 div 2);
  cx2:= cx1*cx1;
  cy1:= cy * (65536 div 2);
  cy2:= cy1*cy1;
  w:= linewidth16 div 2;
  cxw:= cx1*w;
  cyw:= cy1*w;
  sx:= 1;
  sy:= 0;    
  for int1:= int1-1 downto 0 do begin
   x1:= round(cx1*sx);
   y1:= round(cy1*sy);
   rea1:= sqrt(cx2*sy*sy+cy2*sx*sx);
   if rea1 = 0 then begin
    x2:= round(w);
    y2:= 0;
   end
   else begin
    x2:= round(cyw*sx/rea1);
    y2:= round(cxw*sy/rea1);
   end;
   q0^.x:= center.x + x1 + x2;
   q0^.y:= center.y - y1 - y2;
   inc(q0);
   q0^.x:= center.x + x1 - x2;
   q0^.y:= center.y - y1 + y2;
   inc(q0);
   q2^.x:= center.x - x1 - x2;
   q2^.y:= center.y + y1 + y2;
   inc(q2);
   q2^.x:= center.x - x1 + x2;
   q2^.y:= center.y + y1 - y2;
   inc(q2);
   if not circle then begin
    x1:= round(cy1*sx);
    y1:= round(cx1*sy);
    rea1:= sqrt(cy2*sy*sy+cx2*sx*sx);
    if rea1 <> 0 then begin
     x2:= round(cxw*sx/rea1);
     y2:= round(cyw*sy/rea1);
    end;
   end;
   q1^.x:= center.x - y1 - y2;
   q1^.y:= center.y - x1 - x2;
   inc(q1);
   q1^.x:= center.x - y1 + y2;
   q1^.y:= center.y - x1 + x2;
   inc(q1);
   q3^.x:= center.x + y1 + y2;
   q3^.y:= center.y + x1 + x2;
   inc(q3);
   q3^.x:= center.x + y1 - y2;
   q3^.y:= center.y + x1 - x2;
   inc(q3);
   rea1:= sx;
   sx:= co*sx-si*sy;
   sy:= co*sy+si*rea1;
  end;
  q3^:= ppointty(buffer.buffer)^;   //endpoint
  inc(q3);
  q3^:= (ppointty(buffer.buffer)+1)^;
  apoints:= buffer.buffer;
  apointcount:= npoints;
 end;
end;

end.
