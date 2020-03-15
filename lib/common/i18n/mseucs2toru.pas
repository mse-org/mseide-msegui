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

function cp866toUCS2(const avalue: char): msechar;
function cp866toUCS2(const avalue: ansistring): msestring;

implementation

const

 cp866_2: array[$2550..$256C] of byte = (
  $cd,$ba,$d5,$d6,$c9,$b8,$b7,$bb,$d4,$d3,$c8,$be,$bd,$bc,$c6,
  $c7,$cc,$b5,$b6,$b9,$d1,$d2,$cb,$cf,$d0,$ca,$d8,$d7,$ce
 );

 cpUCS2_1: array[$b5..$be] of longword = (
  $2561,$2562,$2556,$2555,$2563,$2551,$2557,$255D,$255C,$255B
 );

 cpUCS2_2: array[$c6..$d8] of longword = (
  $255E,$255F,$255A,$2554,$2569,$2566,$2560,$2550,$256C,$2567,
  $2568,$2564,$2565,$2559,$2558,$2552,$2553,$256B,$256A
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


function cp866toUCS2(const avalue: char): msechar;
var
  i: byte;
begin
i:= byte(avalue);
case i of
  $0..$7f:    result:= widechar(avalue);
  $80..$af:   result:= widechar(i + $390);
  $b0:        result:= widechar($2591);
  $b1:        result:= widechar($2592);
  $b2:        result:= widechar($2593);
  $b3:        result:= widechar($2502);
  $b4:        result:= widechar($2524);
  $b5..$be:   result:= widechar(cpUCS2_1[i]);
  $bf:        result:= widechar($2510);
  $c0:        result:= widechar($2514);
  $c1:        result:= widechar($2534);
  $c2:        result:= widechar($252C);
  $c3:        result:= widechar($251C);
  $c4:        result:= widechar($2500);
  $c5:        result:= widechar($253C);
  $c6..$d8:   result:= widechar(cpUCS2_2[i]);
  $d9:        result:= widechar($2518);
  $da:        result:= widechar($250C);
  $db:        result:= widechar($2588);
  $dc:        result:= widechar($2584);
  $dd:        result:= widechar($258C);
  $de:        result:= widechar($2590);
  $df:        result:= widechar($2580);
  $e0..$ef:   result:= widechar(i + $360);
  $f0:        result:= widechar($401);
  $f1:        result:= widechar($451);
  $f2:        result:= widechar($404);
  $f3:        result:= widechar($454);
  $f4:        result:= widechar($407);
  $f5:        result:= widechar($457);
  $f6:        result:= widechar($40E);
  $f7:        result:= widechar($45E);
  $f8:        result:= widechar($B0);
  $f9:        result:= widechar($2219);
  $fa:        result:= widechar($b7);
  $fb:        result:= widechar($221A);
  $fc:        result:= widechar($2116);
  $fd:        result:= widechar($a4);
  $fe:        result:= widechar($25A0);
  $ff:        result:= widechar($a0);
 else
  result:= widechar($20);
end;
end;

function cp866toUCS2(const avalue: ansistring): msestring;
var
  i,i1: integer;
begin
i1:= length(avalue);
setlength(result,i1);
for i:= 1 to i1 do begin
  result[i]:= cp866toUCS2(avalue[i]);
end;
end;

end.
