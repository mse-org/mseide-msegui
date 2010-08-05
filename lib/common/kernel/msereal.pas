{ MSEgui Copyright (c) 1999-2008 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msereal;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 msetypes,mseformatstr,Classes,msestrings;

const
 emptyrealstring = '';   //stringsymbol for empty realty
 bigreal = 1e38;

function cmprealty(const a,b: realty): integer;
function emptyreal: realty;
function isemptyreal(const val: realty): boolean; //true if empty
function candiv(const val: realty): boolean; //true if not 0.0 or empty:

function strtorealty(const ein: string; forcevalue: boolean = false): realty;
function strtorealtydot(const ein: string): realty;
//function realtytostr(const val: realty; const format: msestring = ''): msestring;
function realtytostr(const val: realty; const format: msestring = '';
                                            const scale: real = 1): msestring;
function realtytostrrange(const val: realty; const format: msestring = '';
                                            const range: real = 1): msestring;
function realtytostrdot(const val: realty): string;

function addrealty(const a,b: realty): realty; //result = a - b
function subrealty(const a,b: realty): realty; //result = a + b
function mulrealty(const a,b: realty): realty; //result = a * b

function applyrange(const avalue: realty; const arange: real): realty;
function reapplyrange(const avalue: realty; const arange: real): realty;
function valuescaletorange(const reader: treader): real;

implementation
uses
 sysutils,msesys;

const
{$ifdef FPC_DOUBLE_HILO_SWAPPED}
 co1: array[0..7] of byte = (0,0,$f0,$ff,$0,0,0,0);      //- inf
{$else}
 co1: array[0..7] of byte = ($0,0,0,0,0,0,$f0,$ff);      //- inf
{$endif}

function applyrange(const avalue: realty; const arange: real): realty;
begin
 if isemptyreal(avalue) or (arange = 0) then begin
  result:= avalue;
 end
 else begin
  result:= avalue * arange;
 end;  
end;

function reapplyrange(const avalue: realty; const arange: real): realty;
begin
 if isemptyreal(avalue) or (arange = 0) then begin
  result:= avalue;
 end
 else begin
  result:= avalue / arange;
 end;  
end;

function valuescaletorange(const reader: treader): real;
begin
 result:= reader.readfloat;
 if result <> 0 then begin
  result:= 1/result;
 end;
end;

function addrealty(const a,b: realty): realty; //result = a - b
begin
 if isemptyreal(a) then begin
  result:= b;
 end
 else begin
  if isemptyreal(b) then begin
   result:= a;
  end
  else begin
   result:= a + b;
  end;
 end;
end;

function subrealty(const a,b: realty): realty; //result = a + b
begin
 if isemptyreal(a) then begin
  if isemptyreal(b) then begin
   result:= emptyreal;
  end
  else begin
   result:= -b;
  end;
 end
 else begin
  if isemptyreal(b) then begin
   result:= a;
  end
  else begin
   result:= a - b;
  end;
 end;
end;

function mulrealty(const a,b: realty): realty; //result = a * b
begin
 if not isemptyreal(a) and not isemptyreal(b) then begin
  result:= a * b;
 end
 else begin
  result:= emptyreal;
 end;
end;

function emptyreal: realty;
begin
 move(co1,result,sizeof(realty));
// doublepo:= @co1;
// result:= doublepo^;
end;
{
function isleerdouble(val: double): boolean; //true wenn leer
begin
 result:= comparemem(@val,@co1,sizeof(double))
end;
}
function isemptyreal(const val: realty): boolean; //true wenn leer
begin
 result:= comparemem(@val,@co1,sizeof(realty))
end;

function candiv(const val: realty): boolean; //true if not 0.0 or empty:
begin
 result:= (val <> 0.0) and not comparemem(@val,@co1,sizeof(realty));
end;

function cmprealty(const a,b: realty): integer;
       //-1 wenn a < b, 0 wenn a = b, 1 wenn a > b
begin
 if isemptyreal(b) then begin
  result:= 1;
  if isemptyreal(a) then begin
   result:= 0;
  end;
 end
 else begin
  if isemptyreal(a) then begin
   result:= -1;
  end
  else begin
   if a > b then begin
    result:= 1;
   end
   else begin
    if a < b then begin
     result:= -1;
    end
    else begin
     result:= 0;
    end;
   end;
  end;
 end;
end;
{
function realtytostr(const val: realty; const format: msestring = ''): msestring;
begin
 if isemptyreal(val) then begin
  result:= emptyrealstring;
 end
 else begin
  result:= formatfloatmse(val,format,defaultformatsettingsmse);
 end;
end;
}
function realtytostr(const val: realty; const format: msestring = '';
                                            const scale: real = 1): msestring;
var
 rea1: real;
begin
 if isemptyreal(val) then begin
  result:= emptyrealstring;
 end
 else begin
  if scale <> 0 then begin
   rea1:= val/scale;
  end
  else begin
   rea1:= val;
  end;
  result:= formatfloatmse(rea1,format,defaultformatsettingsmse);
 end;
end;

function realtytostrrange(const val: realty; const format: msestring = '';
                                            const range: real = 1): msestring;
var
 rea1: real;
begin
 if isemptyreal(val) then begin
  result:= emptyrealstring;
 end
 else begin
  if range <> 0 then begin
   rea1:= val*range;
  end
  else begin
   rea1:= val;
  end;
  result:= formatfloatmse(rea1,format,defaultformatsettingsmse);
 end;
end;

const
 expos: array[ord('A')..ord('z')] of shortint =
 //    A    B    C    D    E    F    G    H    I    J    K    L    M  
  (    0,   0,   0,   0, 6*3,   0, 3*3,   0,   0,   0,   0,   0, 2*3,
 //    N    O    P    Q    R    S    T    U    V    W    X    Y    Z  
       0,   0, 5*3,   0,   0,   0, 4*3,   0,   0,   0,   0, 8*3, 7*3,
 //[ \ ] ^ _ '
   0,0,0,0,0,0,
 //   a    b    c    d    e    f    g    h    i    j    k    l    m  
   -6*3,   0,   0,   0,   0,-5*3,   0,   0,   0,   0, 1*3,   0,-1*3,
 //   n    o    p    q    r    s    t    u    v    w    x    y    z  
   -3*3,   0,-4*3,   0,   0,   0,   0,-2*3,   0,   0,   0,-8*3,-7*3);
 
function strtorealty(const ein: string; forcevalue: boolean = false): realty;
var
 str1: string;
 ch1: char;
 sint1: shortint;
begin
 str1:= trim(ein);
 if not forcevalue and (str1 = emptyrealstring) then begin
  result:= emptyreal;
 end
 else begin
  removechar(str1,thousandseparator);
  if length(str1) > 0 then begin
   ch1:= str1[length(str1)];
   if (ch1 >= 'A') and (ch1 <= 'z') then begin
    sint1:= expos[ord(ch1)];
    if sint1 <> 0 then begin
     setlength(str1,length(str1)-1);
     str1:= str1 + 'E'+inttostr(sint1);
    end;
   end;
  end;
  result:= strtofloat(str1);
 end;
end;

function realtytostrdot(const val: realty): string;
begin
 if isemptyreal(val) then begin
  result:= emptyrealstring;
 end
 else begin
 {$ifdef withformatsettings}
  result:= floattostr(val,defaultformatsettings);
 {$else}
  result:= replacechar(floattostr(val),decimalseparator,'.');
 {$endif}
 end;
end;

function strtorealtydot(const ein: string): realty;

begin
 if trim(ein) = emptyrealstring then begin
  result:= emptyreal;
 end
 else begin
 {$ifdef withformatsettings}
  result:= strtofloat(ein,defaultformatsettings);
 {$else}
  result:= strtofloat(replacechar(ein,'.',decimalseparator));
 {$endif}
 end;
end;

end.
