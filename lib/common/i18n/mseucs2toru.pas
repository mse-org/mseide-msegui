{ MSEgui Copyright (c) 2007 by IvankoB

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseucs2toru;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 msestrings;
 
function ucs2to866(const avalue: msechar): char;
function ucs2to866(const avalue: msestring): ansistring;

implementation

const 

 cp866_2: array[$2550..$256C] of byte = (
  $cd,$ba,$d5,$d6,$c9,$b8,$b7,$bb,$d4,$d3,$c8,$be,$bd,$bc,$c6,
  $c7,$cc,$b5,$b6,$b9,$d1,$d2,$cb,$cf,$d0,$ca,$d8,$d7,$ce
    );

function ucs2to866(const avalue: msechar): char;
var
    i: longword;
begin
    i:= longword(avalue);

		case i of
  $0..$7f:      result:= char(avalue);
  $A0:          result:= char($ff);
  $A4:          result:= char($fd);
  $B0,$BA:      result:= char($f8);
  $B7:          result:= char($fa);
  $401:         result:= char($f0);
  $404:         result:= char($f2);
  $407:         result:= char($f4);
  $40E:         result:= char($f6);
  $410..$43f:   result:= char(i-$390);
  $440..$44f:   result:= char(i-$360);
  $451:         result:= char($f1);
  $454:         result:= char($f3);
  $457:         result:= char($f5);
  $45E:         result:= char($f7);
  $2116:        result:= char($fc);
  $2219:        result:= char($f9);
  $221A:        result:= char($fb);
  $2500:        result:= char($c4);
  $2502:        result:= char($b3);
  $250C:        result:= char($da);
  $2510:        result:= char($bf);
  $2514:        result:= char($c0);
  $2518:        result:= char($d9);
  $251C:        result:= char($c3);
  $2524:        result:= char($b4);
  $252C:        result:= char($c2);
  $2534:        result:= char($c1);
  $253C:        result:= char($c5);
  $2550..$256C: result:= char(cp866_2[i]);
  $2580:        result:= char($df);
  $2584:        result:= char($dc);
  $2588:        result:= char($db);
  $258C:        result:= char($dd);
  $2590:        result:= char($de);
  $2591:        result:= char($b0);
  $2592:        result:= char($b1);
  $2593:        result:= char($b2);
  $25A0:        result:= char($fe);
 else
  result:= char($20);
    end;

end;


function ucs2to866(const avalue: msestring): ansistring;
var
    i,i1: integer;
begin
    i1:= length(avalue);
    setlength(result,i1);

 for i:= 1 to i1 do begin
		result[i]:= ucs2to866(avalue[i]);
    end;

end;


end.
