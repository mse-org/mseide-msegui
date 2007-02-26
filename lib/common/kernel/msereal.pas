{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msereal;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

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
function realtytostr(const val: realty; const format: msestring = ''): msestring;
function realtytostrdot(const val: realty): string;
{
procedure varianttorealty(const value: variant; out ziel: realty); overload;
function varianttorealty(const value: variant):realty; overload;
procedure realtytovariant(const value: realty; out ziel: variant); overload;
function realtytovariant(const value: realty): variant; overload;
}
function addrealty(const a,b: realty): realty; //result = a - b
function subrealty(const a,b: realty): realty; //result = a + b
function mulrealty(const a,b: realty): realty; //result = a * b

implementation
uses
 sysutils;

const
 co1: array[0..7] of byte = ($0,0,0,0,0,0,$f0,$ff);      //- inf

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

function realtytostr(const val: realty; const format: msestring = ''): msestring;
begin
 if isemptyreal(val) then begin
  result:= emptyrealstring;
 end
 else begin
  result:= formatfloatmse(val,format);
 end;
end;

function strtorealty(const ein: string; forcevalue: boolean = false): realty;
var
 str1: string;
begin
 if not forcevalue and (trim(ein) = emptyrealstring) then begin
  result:= emptyreal;
 end
 else begin
  str1:= ein;
  removechar(str1,thousandseparator);
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
{
procedure varianttorealty(const value: variant; out ziel: realty);
begin
 if varisnull(value) then begin
  ziel:= emptyreal;
 end
 else begin
  ziel:= value;
 end;
end;

function varianttorealty(const value: variant): realty; overload;
begin
 if varisnull(value) then begin
  result:= emptyreal;
 end
 else begin
  result:= value;
 end;
end;

procedure realtytovariant(const value: realty; out ziel: variant);
begin
 if isemptyreal(value) then begin
  ziel:= null;
 end
 else begin
  ziel:= value;
 end;
end;

function realtytovariant(const value: realty): variant; overload;
begin
 if isemptyreal(value) then begin
  result:= null;
 end
 else begin
  result:= value;
 end;
end;
}
end.
