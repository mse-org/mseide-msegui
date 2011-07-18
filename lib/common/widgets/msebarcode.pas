{ MSEgui Copyright (c) 2011 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msebarcode;
//under construction

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 classes,msewidgets,msebitmap,msegraphics,mseclasses,msegraphutils,msestrings;
 
type
 barcodestatety = (bcs_bitmapvalid);
 barcodestatesty = set of barcodestatety;
 
 tcustombarcode = class(tpublishedwidget)
  private
   fbitmap: tbitmap;
   fcellcount: integer;
   fcelldata: pbyte;
   fcolorbar: colorty;
   fcolorspace: colorty;
   fcode: msestring;
   procedure setcolorbar(const avalue: colorty);
   procedure setcolorspace(const avalue: colorty);
   procedure setcode(const avalue: msestring);
  protected
   fstate: barcodestatesty;
   procedure checkbitmap;
   procedure calcbitmap; virtual; abstract;
   procedure checkcode; virtual;
   procedure dopaint(const acanvas: tcanvas); override;
   procedure change;
   procedure loaded; override;
   function getbarrect: rectty; virtual;
   function getcellcount: integer; virtual;
   procedure setcell(const aindex: integer; const avalue: boolean = true); overload;
   procedure setcell(const aindex: array of integer); overload;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property colorbar: colorty read fcolorbar write setcolorbar 
                                               default cl_black;
   property colorspace: colorty read fcolorspace write setcolorspace 
                                               default cl_transparent;
   property code: msestring read fcode write setcode;
 end;

 barcodekindty = (bk_none,bk_gtin_13);
 
 tbarcode = class(tcustombarcode)
  private
   fkind: barcodekindty;
   procedure setkind(const avalue: barcodekindty);
  protected
   procedure checkcode; override;
   function getcellcount: integer; override;
   procedure calcbitmap; override;
  published
   property kind: barcodekindty read fkind write setkind default bk_none;
   property colorbar;
   property colorspace;
   property code;
 end;
 
implementation
uses
 rtlconsts,msebits;

type
  patterngtin13ty = (pgt13_l0,pgt13_l1,pgt13_r,pgt13_13);

const
 cellcounts: array[barcodekindty] of integer =
  //bk_none,bk_gtin_13
  (0,       95);
  patterngtin13: array[patterngtin13ty,0..9] of byte =
//    0       1       2       3       4       5       6       7       8       9
//0001101 0011001 0010011 0111101 0100011 0110001 0101111 0111011 0110111 0001011 _l0
 (($0d,    $19,    $13,    $3d,    $23,    $31,    $2f,    $3b,    $37,    $0b),//_13 0
//0100111 0110011 0011011 0100001 0011101 0111001 0000101 0010001 0001001 0010111 _l1
  ($27,    $33,    $1b,    $21,    $1d,    $39,    $05,    $11,    $09,    $17),//_13 1
//1110010 1100110 1101100 1000010 1011100 1001110 1010000 1000100 1001000 1110100 _r
  ($72,    $66,    $6a,    $42,    $5c,    $4e,    $50,    $44,    $48,    $74),
// 000000  001011  001101  001110  010011  011001  011100  010101  010110  011010 _13
  ($00,    $0b,    $0d,    $0e,    $13,    $19,    $1c,    $15,    $16,    $1a)
     );
                      
 patternmask: array[0..6] of byte = 
 //1000000 0100000 0010000 0001000 0000100 0000010 0000001
 (  $40,    $20,    $10,    $08,    $04,    $02,    $01);
 digit13mask: array[0..5] of byte = 
 //0100000 0010000 0001000 0000100 0000010 0000001
 (  $20,    $10,    $08,    $04,    $02,    $01);
    
{ tcustombarcode }

constructor tcustombarcode.create(aowner: tcomponent);
begin
 fcolorbar:= cl_black;
 fcolorspace:= cl_transparent;
 inherited;
 fbitmap:= tbitmap.create(true);
end;

destructor tcustombarcode.destroy;
begin
 fbitmap.free;
 inherited;
end;

procedure tcustombarcode.checkbitmap;
begin
 if not (bcs_bitmapvalid in fstate) then begin
  fcelldata:= nil;
  fcellcount:= 0;
  if fcode = '' then begin
   fbitmap.clear;
  end
  else begin   
   fcellcount:= getcellcount;
   fbitmap.size:= ms(fcellcount,1);
   if fcellcount > 0 then begin
    fcelldata:= fbitmap.scanline[0];
    fillchar(fcelldata^,((fcellcount+31) div 32) * 4,0);
    calcbitmap;
   end;
  end;
  include(fstate,bcs_bitmapvalid);
 end; 
end;

procedure tcustombarcode.dopaint(const acanvas: tcanvas);
begin
 checkbitmap;
 fbitmap.paint(acanvas,getbarrect,[al_stretchx,al_stretchy,al_or],
                    fcolorbar,fcolorspace);
end;

procedure tcustombarcode.change;
begin
 if not (csloading in componentstate) then begin
  exclude(fstate,bcs_bitmapvalid);
  invalidate;
 end;
end;

procedure tcustombarcode.loaded;
begin
 inherited;
 change;
end;

function tcustombarcode.getbarrect: rectty;
begin
 result:= innerclientrect;
end;

function tcustombarcode.getcellcount: integer;
begin
 result:= 0;
end;

procedure tcustombarcode.setcell(const aindex: integer;
               const avalue: boolean = true);
var
 po1: pbyte;
begin
 if (aindex < 0) or (aindex >= fcellcount) then begin
  tlist.error(slistindexerror,aindex);
 end;
 po1:= pbyte(pchar(fcelldata)+(aindex div 8));
 if avalue then begin
  po1^:= po1^ or bits[aindex and $07];
 end
 else begin
  po1^:= po1^ and not bits[aindex and $07];
 end;
end;

procedure tcustombarcode.setcolorbar(const avalue: colorty);
begin
 if fcolorbar <> avalue then begin
  fcolorbar:= avalue;
  invalidate;
 end;
end;

procedure tcustombarcode.setcolorspace(const avalue: colorty);
begin
 if fcolorspace <> avalue then begin
  fcolorspace:= avalue;
  invalidate;
 end;
end;

procedure tcustombarcode.setcode(const avalue: msestring);
begin
 if fcode <> avalue then begin
  fcode:= avalue;
  if fcode <> '' then begin
   checkcode;
  end;
  change;
 end;
end;

procedure tcustombarcode.setcell(const aindex: array of integer);
var
 int1: integer;
begin
 for int1:= 0 to high(aindex) do begin
  setcell(aindex[int1]);
 end;
end;

procedure tcustombarcode.checkcode;
begin
 //dummy
end;

{ tbarcode }

function tbarcode.getcellcount: integer;
begin
 result:= cellcounts[fkind];
end;

procedure tbarcode.calcbitmap;
var
 cellindex: integer;
 
 procedure putcells(const apattern: byte);
 var
  int1: integer;
 begin
  for int1:= 0 to high(patternmask) do begin
   if apattern and patternmask[int1] <> 0 then begin
    setcell(cellindex);
   end;
   inc(cellindex);
  end;
 end;
 
var
 int1: integer;
// int2,int3: integer;
 digits: array[0..11] of byte;
 {by1,}by2: byte;
 ch1: msechar;
 pat1: patterngtin13ty;
begin
 case fkind of
  bk_gtin_13: begin
   setcell([0,2,46,48,92,94]); //start, center, stop
   for int1:= 2 to 13 do begin
    digits[int1-2]:= ord(fcode[int1])-ord('0');
   end;
   {
   int2:= 0;
   int3:= 0;
   for int1:= 0 to high(digits) do begin
    if odd(int1) then begin
     int3:= int3 + digits[int1];  //*3
    end
    else begin
     int2:= int2 + digits[int1];  //*1
    end;
   end;
   by1:= (3*int3+int2) mod 10;
   if by1 <> 0 then begin
    by1:= 10-by1;         //controllsum
   end;
   }
   by2:= patterngtin13[pgt13_13,ord(fcode[1])-ord('0')];
   cellindex:= 3;
   for int1:= 0 to 5 do begin
    pat1:= pgt13_l0;
    if by2 and digit13mask[int1] <> 0 then begin
     pat1:= pgt13_l1;
    end;
    putcells(patterngtin13[pat1,digits[int1]]);
   end;
   cellindex:= 50;
   for int1:= 6 to 11 do begin
    putcells(patterngtin13[pgt13_r,digits[int1]]);
   end;
  end;
 end;
end;

procedure tbarcode.setkind(const avalue: barcodekindty);
begin
 if fkind <> avalue then begin
  fkind:= avalue;
  change;
 end;
end;

procedure tbarcode.checkcode;
var
 int1: integer;
begin
 case fkind of
  bk_gtin_13: begin
   if length(fcode) > 13 then begin
    setlength(fcode,13);
   end;
   for int1:= 1 to length(fcode) do begin
    if (fcode[int1] < '0') or (fcode[int1] > '9') then begin
     fcode[int1]:= '0';
    end;     
   end;
   if length(fcode) < 13 then begin
    fcode:= charstring(msechar('0'),13-length(fcode))+fcode;
   end;
  end;
 end;
end;

end.
