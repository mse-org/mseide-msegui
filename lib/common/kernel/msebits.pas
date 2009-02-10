{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msebits;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
//bitmanipulationhelpers
interface
type
 bitnumty = 0..32;
const
 twoexp32 = 4294967296.0;
 bytebits: array[0..8] of byte = ($01,$02,$04,$08,$10,$20,$40,$80,$00);
 bytemask: array[0..8] of byte = ($00,$01,$03,$07,$0f,$1f,$3f,$7f,$ff);
 bytebitsreverse: array[0..8] of byte = ($80,$40,$20,$10,$08,$04,$02,$01,$00);
         
 bits: array[bitnumty] of longword = (
         $00000001,$00000002,$00000004,$00000008,
         $00000010,$00000020,$00000040,$00000080,
         $00000100,$00000200,$00000400,$00000800,
         $00001000,$00002000,$00004000,$00008000,
         $00010000,$00020000,$00040000,$00080000,
         $00100000,$00200000,$00400000,$00800000,
         $01000000,$02000000,$04000000,$08000000,
         $10000000,$20000000,$40000000,$80000000,
         $00000000);
 bitmask: array[bitnumty] of longword = (
         $00000000,$00000001,$00000003,$00000007,
         $0000000f,$0000001f,$0000003f,$0000007f,
         $000000ff,$000001ff,$000003ff,$000007ff,
         $00000fff,$00001fff,$00003fff,$00007fff,
         $0000ffff,$0001ffff,$0003ffff,$0007ffff,
         $000fffff,$001fffff,$003fffff,$007fffff,
         $00ffffff,$01ffffff,$03ffffff,$07ffffff,
         $0fffffff,$1fffffff,$3fffffff,$7fffffff,
         $ffffffff);
 bitreverse: array[byte] of byte = (
             $00,$80,$40,$c0,$20,$a0,$60,$e0,$10,$90,$50,$d0,$30,$b0,$70,$f0,
             $08,$88,$48,$c8,$28,$a8,$68,$e8,$18,$98,$58,$d8,$38,$b8,$78,$f8,
             $04,$84,$44,$c4,$24,$a4,$64,$e4,$14,$94,$54,$d4,$34,$b4,$74,$f4,
             $0c,$8c,$4c,$cc,$2c,$ac,$6c,$ec,$1c,$9c,$5c,$dc,$3c,$bc,$7c,$fc,
             $02,$82,$42,$c2,$22,$a2,$62,$e2,$12,$92,$52,$d2,$32,$b2,$72,$f2,
             $0a,$8a,$4a,$ca,$2a,$aa,$6a,$ea,$1a,$9a,$5a,$da,$3a,$ba,$7a,$fa,
             $06,$86,$46,$c6,$26,$a6,$66,$e6,$16,$96,$56,$d6,$36,$b6,$76,$f6,
             $0e,$8e,$4e,$ce,$2e,$ae,$6e,$ee,$1e,$9e,$5e,$de,$3e,$be,$7e,$fe,
             $01,$81,$41,$c1,$21,$a1,$61,$e1,$11,$91,$51,$d1,$31,$b1,$71,$f1,
             $09,$89,$49,$c9,$29,$a9,$69,$e9,$19,$99,$59,$d9,$39,$b9,$79,$f9,
             $05,$85,$45,$c5,$25,$a5,$65,$e5,$15,$95,$55,$d5,$35,$b5,$75,$f5,
             $0d,$8d,$4d,$cd,$2d,$ad,$6d,$ed,$1d,$9d,$5d,$dd,$3d,$bd,$7d,$fd,
             $03,$83,$43,$c3,$23,$a3,$63,$e3,$13,$93,$53,$d3,$33,$b3,$73,$f3,
             $0b,$8b,$4b,$cb,$2b,$ab,$6b,$eb,$1b,$9b,$5b,$db,$3b,$bb,$7b,$fb,
             $07,$87,$47,$c7,$27,$a7,$67,$e7,$17,$97,$57,$d7,$37,$b7,$77,$f7,
             $0f,$8f,$4f,$cf,$2f,$af,$6f,$ef,$1f,$9f,$5f,$df,$3f,$bf,$7f,$ff);
type
 int64recty = record
  lsw: cardinal;
  msw: cardinal;
 end;
 
function highestbit(value: cardinal): integer;
//0-> first, 31-> last($80000000), -1-> none ($00000000)
function lowestbit(value: cardinal): integer;
//0-> first, 31-> last($80000000), -1-> none ($00000000)

function replacebits(const new,old,mask: byte): byte; overload;
function replacebits(const new,old,mask: word): word; overload;
function replacebits(const new,old,mask: longword): longword; overload;
function replacebits1(var dest: byte; const value,mask: byte): boolean; overload;
function replacebits1(var dest: word; const value,mask: word): boolean; overload;
function replacebits1(var dest: longword;
                                   const value,mask: longword): boolean; overload;
                            //true if modified
function bitschanged(const a,b,mask: byte): boolean; overload;
function bitschanged(const a,b,mask: word): boolean; overload;
function bitschanged(const a,b,mask: longword): boolean; overload;

function setsinglebit(const new,old,mask: byte): byte; overload;
function setsinglebit(const new,old,mask: word): word; overload;
function setsinglebit(const new,old,mask: longword): longword; overload;

function checkbit(const value: byte; const bitnum: integer): boolean; overload;
function checkbit(const value: word; const bitnum: integer): boolean; overload;
function checkbit(const value: longword; const bitnum: integer): boolean; overload;

function updatebit(var dest: byte; bitnum: integer; value: boolean): boolean; overload;
             //true if changed
function updatebit(var dest: word; bitnum: integer; value: boolean): boolean; overload;
             //true if changed
function updatebit(var dest: longword; bitnum: integer; value: boolean):boolean; overload;
             //true if changed

procedure setbit1(var dest: byte; bitnum: integer); overload;
procedure setbit1(var dest: word; bitnum: integer); overload;
procedure setbit1(var dest: longword; bitnum: integer); overload;
function setbit(const source: byte; bitnum: integer): byte; overload;
function setbit(const source: word; bitnum: integer): word; overload;
function setbit(const source: longword; bitnum: integer): longword; overload;

procedure clearbit1(var dest: byte; bitnum: integer); overload;
procedure clearbit1(var dest: word; bitnum: integer); overload;
procedure clearbit1(var dest: longword; bitnum: integer); overload;
function clearbit(const source: byte; bitnum: integer): byte; overload;
function clearbit(const source: word; bitnum: integer): word; overload;
function clearbit(const source: longword; bitnum: integer): longword; overload;

procedure togglebit1(var dest: byte; bitnum: integer); overload;
procedure togglebit1(var dest: word; bitnum: integer); overload;
procedure togglebit1(var dest: longword; bitnum: integer); overload;
function togglebit(const source: byte; bitnum: integer): byte; overload;
function togglebit(const source: word; bitnum: integer): word; overload;
function togglebit(const source: longword; bitnum: integer): longword; overload;

function iszero(address: pointer; count: integer): boolean;

function swapbytes(const value: word): word; overload;
 //value and result at different adresses!
function swapbytes(const value: cardinal): cardinal; overload;
 //value and result at different adresses!
procedure swapbytes1(var value: word); overload;
procedure swapbytes1(var value: cardinal); overload;
procedure swaprgb1(var value: cardinal);
function swaprgb(const value: cardinal): cardinal;

function roundint(const value: integer; const step: integer): integer;

implementation

function updatebit(var dest: byte; bitnum: integer; value: boolean): boolean;
var
 by1: byte;
begin
 by1:= dest;
 if value then begin
  dest:= dest or bits[bitnum];
 end
 else begin
  dest:= dest and not bits[bitnum];
 end;
 result:= dest <> by1;
end;

function updatebit(var dest: word; bitnum: integer; value: boolean): boolean;
var
 wo1: word;
begin
 wo1:= dest;
 if value then begin
  dest:= dest or bits[bitnum];
 end
 else begin
  dest:= dest and not bits[bitnum];
 end;
 result:= dest <> wo1;
end;

function updatebit(var dest: longword; bitnum: integer; value: boolean): boolean;
var
 wo1: longword;
begin
 wo1:= dest;
 if value then begin
  dest:= dest or bits[bitnum];
 end
 else begin
  dest:= dest and not bits[bitnum];
 end;
 result:= dest <> wo1;
end;

procedure setbit1(var dest: byte; bitnum: integer);
begin
 dest:= dest or bits[bitnum];
end;

procedure setbit1(var dest: word; bitnum: integer);
begin
 dest:= dest or bits[bitnum];
end;

procedure setbit1(var dest: longword; bitnum: integer);
begin
 dest:= dest or bits[bitnum];
end;

procedure clearbit1(var dest: byte; bitnum: integer);
begin
 dest:= dest and not bits[bitnum];
end;

procedure clearbit1(var dest: word; bitnum: integer);
begin
 dest:= dest and not bits[bitnum];
end;

procedure clearbit1(var dest: longword; bitnum: integer);
begin
 dest:= dest and not bits[bitnum];
end;

procedure togglebit1(var dest: byte; bitnum: integer);
begin
 dest:= dest xor byte(bits[bitnum]);
end;

procedure togglebit1(var dest: word; bitnum: integer);
begin
 dest:= dest xor word(bits[bitnum]);
end;

procedure togglebit1(var dest: longword; bitnum: integer);
begin
 dest:= dest xor bits[bitnum];
end;

function setbit(const source: byte; bitnum: integer): byte;
begin
 result:= source or bits[bitnum];
end;

function setbit(const source: word; bitnum: integer): word;
begin
 result:= source or bits[bitnum];
end;

function setbit(const source: longword; bitnum: integer): longword;
begin
 result:= source or bits[bitnum];
end;

function clearbit(const source: byte; bitnum: integer): byte;
begin
 result:= source and not bits[bitnum];
end;

function clearbit(const source: word; bitnum: integer): word;
begin
 result:= source and not bits[bitnum];
end;

function clearbit(const source: longword; bitnum: integer): longword;
begin
 result:= source and not bits[bitnum];
end;

function togglebit(const source: byte; bitnum: integer): byte;
begin
 result:= source xor byte(bits[bitnum]);
end;

function togglebit(const source: word; bitnum: integer): word;
begin
 result:= source xor word(bits[bitnum]);
end;

function togglebit(const source: longword; bitnum: integer): longword;
begin
 result:= source xor bits[bitnum];
end;

function replacebits(const new,old,mask: byte): byte;
begin
 result:= old and not mask or new and mask;
end;

function replacebits(const new,old,mask: word): word;
begin
 result:= old and not mask or new and mask;
end;

function replacebits(const new,old,mask: cardinal): cardinal;
begin
 result:= old and not mask or new and mask;
end;

function replacebits1(var dest: byte; const value,mask: byte): boolean;
begin
 result:= (dest xor value) and mask <> 0;
 if result then begin
  dest:= dest and not mask or value and mask
 end;
end;

function replacebits1(var dest: word;
                              const value,mask: word): boolean; overload;
begin
 result:= (dest xor value) and mask <> 0;
 if result then begin
  dest:= dest and not mask or value and mask
 end;
end;

function replacebits1(var dest: longword;
                              const value,mask: longword): boolean; overload;
begin
 result:= (dest xor value) and mask <> 0;
 if result then begin
  dest:= dest and not mask or value and mask
 end;
end;

function bitschanged(const a,b,mask: byte): boolean; overload;
begin
 result:= (a xor b) and mask <> 0;
end;

function bitschanged(const a,b,mask: word): boolean; overload;
begin
 result:= (a xor b) and mask <> 0;
end;

function bitschanged(const a,b,mask: cardinal): boolean; overload;
begin
 result:= (a xor b) and mask <> 0;
end;

function setsinglebit(const new,old,mask: byte): byte; overload;
var
 v1: byte;
begin
 if new and mask = 0 then begin
  result:= new and not mask;
 end
 else begin
  v1:= (old xor new) and mask;
  if v1 = 0 then begin
   result:= new; //no change
  end
  else begin
//   result:= new and  not mask or
//            v1 and bitmask[lowestbit(v1)+1];
   result:= (new and  not mask) or
            bits[lowestbit(v1 and new)];
  end;
 end;
end;

function setsinglebit(const new,old,mask: word): word; overload;
var
 v1: word;
begin
 if new and mask = 0 then begin
  result:= new and not mask;
 end
 else begin
  v1:= (old xor new) and mask;
  if v1 = 0 then begin
   result:= new; //no change
  end
  else begin
//   result:= new and  not mask or
//            v1 and bitmask[lowestbit(v1)+1];
   result:= (new and  not mask) or
            bits[lowestbit(v1 and new)];
  end;
 end;
end;

function setsinglebit(const new,old,mask: cardinal): cardinal; overload;
var
 v1: cardinal;
begin
 if new and mask = 0 then begin
  result:= new and not mask;
 end
 else begin
  v1:= (old xor new) and mask;
  if v1 = 0 then begin
   result:= new; //no change
  end
  else begin
//   result:= new and  not mask or
//            v1 and bitmask[lowestbit(v1)+1];
   result:= (new and  not mask) or
            bits[lowestbit(v1 and new)];
  end;
 end;
end;

function checkbit(const value: byte; const bitnum: integer): boolean; overload;
begin
 result:= value and bits[bitnum] <> 0;
end;

function checkbit(const value: word; const bitnum: integer): boolean; overload;
begin
 result:= value and bits[bitnum] <> 0;
end;

function checkbit(const value: longword; const bitnum: integer): boolean; overload;
begin
 result:= value and bits[bitnum] <> 0;
end;



function roundint(const value: integer; const step: integer): integer;
var
 int1: integer;
begin
 int1:= step div 2;
 if value < 0 then begin
  int1:= -int1;
 end;
 result:= ((value + int1) div step) * step;
end;

procedure swaprgb1(var value: cardinal);
var
 by1: byte;
begin
 by1:= byte(value);
 pchar(@value)^:= (pchar(@value)+2)^;
 byte((pchar(@value)+2)^):= by1;
end;

function swaprgb(const value: cardinal): cardinal;
begin
 result:= value;
 pchar(@result)^:= (pchar(@value)+2)^;
 byte((pchar(@result)+2)^):= byte(value);
end;

procedure swapbytes1(var value: word); overload;
var
 wo1: word;
begin
 wo1:= value;
 (pchar(@value))^:= (pchar(@wo1)+1)^;
 (pchar(@value)+1)^:= (pchar(@wo1))^;
end;

procedure swapbytes1(var value: cardinal); overload;
var
 ca1: cardinal;
 po1,po2: pchar;
begin
 ca1:= value;
 po1:= @value;
 po2:= pchar(@ca1)+3;
 po1^:= po2^; inc(po1); dec(po2);
 po1^:= po2^; inc(po1); dec(po2);
 po1^:= po2^; inc(po1); dec(po2);
 po1^:= po2^;
end;

function swapbytes(const value: word): word; overload;
begin
 (pchar(@result))^:= (pchar(@value)+1)^;
 (pchar(@result)+1)^:= (pchar(@value))^;
end;

function swapbytes(const value: cardinal): cardinal; overload;
var
 po1,po2: pchar;
begin
 po1:= @result;
 po2:= pchar(@value)+3;
 po1^:= po2^; inc(po1); dec(po2);
 po1^:= po2^; inc(po1); dec(po2);
 po1^:= po2^; inc(po1); dec(po2);
 po1^:= po2^;
end;

function iszero(address: pointer; count: integer): boolean;
var
 int1: integer;
begin
 result:= false;
 for int1:= 0 to count - 1 do begin
  if pbyte(address)^ <> 0 then begin
   exit;
  end;
  inc(pbyte(address));
 end;
 result:= true;
end;

function highestbit(value: cardinal): integer;
//0-> first, 31-> last($80000000), -1-> none ($00000000)
begin
 result:= -1;
 while value <> 0 do begin
  inc(result);
  value:= value shr 1;
 end;
end;

function lowestbit(value: cardinal): integer;
//0-> first, 31-> last($80000000), -1-> none ($00000000)
begin
 result:= -1;
 if value <> 0 then begin
  result:= 32;
  while value <> 0 do begin
   dec(result);
   value:= value shl 1;
  end;
 end;
end;

function getmask(const mask: array of bitnumty): cardinal;
var
 int1: integer;
begin
 result:= 0;
 for int1:= 0 to high(mask) do begin
  result:= result or bits[mask[int1]];
 end;
end;

end.
