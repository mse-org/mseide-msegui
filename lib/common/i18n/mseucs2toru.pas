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

function ucs2to866(const avalue: widechar): char;
function ucs2to866(const avalue: widestring): ansistring;


implementation

const 

    cp866_1: array[1040..1103] of byte = (
		128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,
		144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,
		160,161,162,163,164,165,166,167,167,169,170,171,172,173,174,175,
		224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239
    );


    cp866_2: array[9552..9580] of byte = (
		205,186,213,214,201,184,183,187,212,211,200,190,189,188,198,
		199,204,181,182,185,209,210,203,207,208,202,216,215,206
    );


function ucs2to866(const avalue: widechar): char;
var
    i: cardinal;
begin
    result:= char(32);
    i:= cardinal(avalue);

    if (i < 127) then begin
		result:= char(avalue);
    end else if (i >= 1040) and (i <= 1087) then begin
		result:= char(cp866_1[i]);
    end else if (i >= 9552) and (i <= 9580) then begin
		result:= char(cp866_2[i]);
    end else begin
		case i of
	    	164:	result:= char(253);
	    	176,186:	result:= char(248);  
	    	183:	result:= char(250);	 
	    	9472:	result:= char(196);
	    	9474:	result:= char(179);
	    	9484:	result:= char(218);
	    	9488:	result:= char(191);
	    	9492:	result:= char(192);
	    	9496:	result:= char(217);
	    	9500:	result:= char(195);
	    	9508:	result:= char(180);
	    	9516:	result:= char(194);
	    	9524:	result:= char(193);
	    	9532:	result:= char(197);
	    	9600:	result:= char(223);
	    	9604:	result:= char(220);
	    	9608:	result:= char(219);
	    	9612:	result:= char(221);
	    	9616:	result:= char(222);
	    	9617:	result:= char(176);
	    	9618:	result:= char(177);
	    	9619:	result:= char(178);
	    	9632:	result:= char(254);
	    	9642:	result:= char(249);
	    	8730:	result:= char(251);
	    	8470:	result:= char(252);
		end;
    end;

end;


function ucs2to866(const avalue: widestring): ansistring;
var
    i,i1: integer;
begin
    i1:= length(avalue);
    setlength(result,i1);
    for i:= 0 to i1 do begin
		result[i]:= ucs2to866(avalue[i]);
    end;
end;

end.
