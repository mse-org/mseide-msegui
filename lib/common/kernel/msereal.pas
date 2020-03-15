{ MSEgui Copyright (c) 1999-2011 by Martin Schreiber

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
 msetypes{,classes,mclasses},msestrings;

const
 emptyrealstring = '';   //stringsymbol for empty realty
 bigreal = 1e38;

function cmprealty(const a,b: realty): integer;
//function emptyreal: realty;
function isemptyreal(const val: realty): boolean; {$ifdef FPC}inline;{$endif}
                        deprecated;
            //use x = emptyreal instead
function candiv(const val: realty): boolean; //true if not 0.0 or empty:

function addrealty(const a,b: realty): realty; //result = a - b
function subrealty(const a,b: realty): realty; //result = a + b
function mulrealty(const a,b: realty): realty; //result = a * b

function applyrange(const avalue: realty; const arange: real;
                                       const astart: real): realty;
function reapplyrange(const avalue: realty; const arange: real;
                                       const astart: real): realty;
function expscale(const value: real; const min: real; const max: real): real;

implementation
uses
 sysutils,{msesys,}sysconst;

const
{$ifdef FPC_DOUBLE_HILO_SWAPPED}
 co1: array[0..7] of byte = (0,0,$f0,$ff,$0,0,0,0);      //- inf
{$else}
 co1: array[0..7] of byte = ($0,0,0,0,0,0,$f0,$ff);      //- inf
{$endif}

function expscale(const value: real; const min: real; const max: real): real;
var
 mi,ma: real;
begin
 mi:= ln(min);
 ma:= ln(max);
 result:= exp(value*(ma-mi)+mi);
end;

function applyrange(const avalue: realty; const arange: real;
                                            const astart: real): realty;
begin
 if (avalue = emptyreal) or (arange = 0) then begin
  result:= avalue;
 end
 else begin
  result:= avalue * arange - astart;
 end;
end;

function reapplyrange(const avalue: realty; const arange: real;
                                               const astart: real): realty;
begin
 if (avalue = emptyreal) or (arange = 0) then begin
  result:= avalue;
 end
 else begin
  result:= (avalue-astart) / arange;
 end;
end;

function addrealty(const a,b: realty): realty; //result = a - b
begin
 if a = emptyreal then begin
  result:= b;
 end
 else begin
  if b = emptyreal then begin
   result:= a;
  end
  else begin
   result:= a + b;
  end;
 end;
end;

function subrealty(const a,b: realty): realty; //result = a + b
begin
 if a = emptyreal then begin
  if b = emptyreal then begin
   result:= emptyreal;
  end
  else begin
   result:= -b;
  end;
 end
 else begin
  if b = emptyreal then begin
   result:= a;
  end
  else begin
   result:= a - b;
  end;
 end;
end;

function mulrealty(const a,b: realty): realty; //result = a * b
begin
 if not (a = emptyreal) and not (b = emptyreal) then begin
  result:= a * b;
 end
 else begin
  result:= emptyreal;
 end;
end;

function isemptyreal(const val: realty): boolean; //true wenn leer
begin
 result:= val = emptyreal;
end;

{
function emptyreal: realty;
begin
 move(co1,result,sizeof(realty));
// doublepo:= @co1;
// result:= doublepo^;
end;

function isemptyreal(const val: realty): boolean; //true wenn leer
begin
 result:= comparemem(@val,@co1,sizeof(realty))
end;
}
function candiv(const val: realty): boolean; //true if not 0.0 or empty:
begin
 result:= (val <> 0.0) and not comparemem(@val,@co1,sizeof(realty));
end;

function cmprealty(const a,b: realty): integer;
       //-1 wenn a < b, 0 wenn a = b, 1 wenn a > b
begin
 if b = emptyreal then begin
  result:= 1;
  if a = emptyreal then begin
   result:= 0;
  end;
 end
 else begin
  if a = emptyreal then begin
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

end.
