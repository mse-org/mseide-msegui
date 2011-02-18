{ MSEgui Copyright (c) 2011 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msegenericgdi;
//
// under construction
// 
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface

uses
 mseguiglob,msegraphics,msetypes,msegraphutils;
  
procedure gdinotimplemented;
function gdi_regiontorects(const aregion: regionty): rectarty;

procedure gdi_createemptyregion(var drawinfo: drawinfoty);
procedure gdi_createrectregion(var drawinfo: drawinfoty);
procedure gdi_createrectsregion(var drawinfo: drawinfoty);
procedure gdi_destroyregion(var drawinfo: drawinfoty);
procedure gdi_copyregion(var drawinfo: drawinfoty);
procedure gdi_moveregion(var drawinfo: drawinfoty);
procedure gdi_regionisempty(var drawinfo: drawinfoty);
procedure gdi_regionclipbox(var drawinfo: drawinfoty);
procedure gdi_regsubrect(var drawinfo: drawinfoty);
procedure gdi_regsubregion(var drawinfo: drawinfoty);
procedure gdi_regaddrect(var drawinfo: drawinfoty);
procedure gdi_regaddregion(var drawinfo: drawinfoty);
procedure gdi_regintersectrect(var drawinfo: drawinfoty);
procedure gdi_regintersectregion(var drawinfo: drawinfoty);

implementation

//todo: optimize, especially memory handling
 
type
 rectextentty = integer;
 prectextentty = ^rectextentty;

 rectdataty = record
  width: rectextentty;
  gap: rectextentty;
 end;
 prectdataty = ^rectdataty;
  
 stripedataty = record //width0,width1... (cellextentty)
 end;

 stripeheaderty = record
  height: rectextentty; 
  colstart: rectextentty;
  data: stripedataty;
 end;                  //               
 pstripeheaderty = ^stripeheaderty;

 regiondataty = record 
 end;
 //array of cellextentty rows:
 // height, colstart, width, gap, width,...,gap, width, 0
 // ...
 //empty row:
 // height, emptyrowmark
 regionrectstripety = record
  header: stripeheaderty;
  data: rectdataty;
 end;
 
const
 emptyrowmark = high(rectextentty);
 rowheadersize = 2*sizeof(rectextentty);      //height, colstart
 celldatasize = 2*sizeof(rectextentty);       //width, gap or 0
type

 regioninfoty = record
  datasize: ptruint;
  rectcount: integer;
  stripecount: integer;
  stripestart: rectextentty;
  pdata: pstripeheaderty;
 end;
 pregioninfoty = ^regioninfoty;
 
procedure gdinotimplemented;
begin
 guierror(gue_notimplemented);
end;

function calcdatasize(const rowcount,rectcount: integer): ptruint;
begin
 result:= rowcount*rowheadersize + rectcount*celldatasize;
end;

function getregmem(const astripecount,arectcount: integer): pregioninfoty;
var
 int1: ptruint;
begin
 getmem(result,sizeof(regioninfoty));
 int1:= calcdatasize(astripecount,arectcount);
 with result^ do begin
  getmem(pdata,int1);
  datasize:= int1;
  stripecount:= astripecount;
  rectcount:= arectcount;
 end;
end;

procedure updatedatasize(var reg: regioninfoty);
begin
 with reg do begin
  datasize:=  calcdatasize(stripecount,rectcount);
 end;
end;

procedure splitstripes(const reg: pregioninfoty; 
                 const stripestart: integer; const stripe: pstripeheaderty;
                 out start,stop: pstripeheaderty);
begin
 
end;

procedure regaddstripe(var reg: pregioninfoty;
                             const stripestart: rectextentty; 
                                       const stripe: pstripeheaderty);
var
 po1,po2: pstripeheaderty;
begin
 splitstripes(reg,stripestart,stripe,po1,po2);
 while po1 < po2 do begin
 end;
end;

procedure recttostripe(const rect: rectty; out rowstart: rectextentty;
                                              out stripe: regionrectstripety);
begin
 rowstart:= rect.y;
 with stripe do begin
  header.height:= rect.cy;
  header.colstart:= rect.x;
  data.width:= rect.cx;
  data.gap:= 0;
 end;
end;

function gdi_regiontorects(const aregion: regionty): rectarty;
var
 po1: prectextentty;
 po2: prectty;
 int1: integer;
 c1,s1,h1: rectextentty;
begin
 if aregion = 0 then begin
  result:= nil;
  exit;
 end;
 with pregioninfoty(aregion)^ do begin
  setlength(result,rectcount);
  po1:= pointer(pdata);
  po2:= pointer(result);
  s1:= stripestart;
  for int1:= stripecount-1 downto 0 do begin
   h1:= po1^;       //rowheight
   inc(po1);
   c1:= po1^;       //col start
   if c1 <> emptyrowmark then begin
    repeat
     inc(po1);       //width
     po2^.x:= c1;
     po2^.cx:= po1^;
     c1:= c1 + po1^; //gapstart
     po2^.y:= s1;
     po2^.cy:= h1;
     inc(po2);
     inc(po1);       //gap
     c1:= c1 + po1^;
    until po1^ = 0;  //eol marker    
   end;
   s1:= s1 + h1;     //next row
   inc(po1);     
  end;
 end;
end;

procedure gdi_createemptyregion(var drawinfo: drawinfoty); //gdifunc
begin
 with drawinfo.regionoperation do begin
  pointer(dest):= getregmem(0,0);
 end;
end;

procedure gdi_createrectsregion(var drawinfo: drawinfoty); //gdifunc
begin
 gdinotimplemented;
end;

procedure gdi_createrectregion(var drawinfo: drawinfoty); //gdifunc
var
 int1: ptruint;
begin
 with drawinfo.regionoperation do begin
  pointer(dest):= getregmem(1,1);
  with pregioninfoty(dest)^ do begin
   stripestart:= rect.y;
   stripecount:= 1;
   rectcount:= 1;
   with pdata^ do begin
    height:= rect.cy;
    colstart:= rect.x;
    with prectdataty(@data)^ do begin
     width:= rect.cx;
     gap:= 0;
    end;
   end;
  end;
 end;
end;

procedure gdi_destroyregion(var drawinfo: drawinfoty); //gdifunc
begin
 with drawinfo.regionoperation do begin
  if source <> 0 then begin
   freemem(pointer(source));
  end;
 end;
end;

procedure gdi_copyregion(var drawinfo: drawinfoty); //gdifunc
var
 int1: integer;
begin
 with drawinfo.regionoperation do begin
  getmem(pointer(dest),sizeof(regioninfoty));
  move(pointer(dest)^,pointer(source)^,sizeof(regioninfoty));
  int1:= pregioninfoty(source)^.datasize;
  if int1 > 0 then begin
   getmem(pregioninfoty(dest)^.pdata,int1);
   move(pregioninfoty(dest)^.pdata^,pregioninfoty(source)^.pdata,int1);
  end;
 end;
end;

procedure gdi_moveregion(var drawinfo: drawinfoty); //gdifunc
begin
 gdinotimplemented;
end;

procedure gdi_regionisempty(var drawinfo: drawinfoty); //gdifunc
begin
 with pregioninfoty((drawinfo.regionoperation.source))^ do begin
  drawinfo.regionoperation.dest:= rectcount;
 end;
end;

procedure gdi_regionclipbox(var drawinfo: drawinfoty); //gdifunc
begin
 gdinotimplemented;
end;

procedure gdi_regsubrect(var drawinfo: drawinfoty); //gdifunc
begin
 gdinotimplemented;
end;

procedure gdi_regsubregion(var drawinfo: drawinfoty); //gdifunc
begin
 gdinotimplemented;
end;

procedure gdi_regaddrect(var drawinfo: drawinfoty); //gdifunc
var
 stri1: regionrectstripety;
 ext1: rectextentty;
begin
 with drawinfo.regionoperation do begin
  recttostripe(rect,ext1,stri1);
  regaddstripe(pregioninfoty(dest),ext1,@stri1);
 end;
end;

procedure gdi_regaddregion(var drawinfo: drawinfoty); //gdifunc
begin
 gdinotimplemented;
end;

procedure gdi_regintersectrect(var drawinfo: drawinfoty); //gdifunc
begin
 gdinotimplemented;
end;

procedure gdi_regintersectregion(var drawinfo: drawinfoty); //gdifunc
begin
 gdinotimplemented;
end;

end.
