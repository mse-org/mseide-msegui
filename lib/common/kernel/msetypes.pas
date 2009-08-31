{ MSEgui Copyright (c) 1999-2008 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
} 
unit msetypes; 

{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}

interface
uses
 SysUtils;

type
{$ifdef FPC}
 {$ifdef ver2_3}{$define longwordbyteset}{$endif}
 {$ifdef ver2_4}{$define longwordbyteset}{$endif}
 {$ifdef ver2_5}{$define longwordbyteset}{$endif}
 {$ifdef longwordbyteset}
  byteset = byte;
  wordset = word;
  longwordset = longword;
 {$else}
  byteset = longword;
  wordset = longword;
  longwordset = longword;
 {$endif}
{$else}
  byteset = byte;
  wordset = word;
  longwordset = longword;
{$endif}
 {$ifndef FPC}
  DWord = Longword;
  SizeInt = Longint;
  psizeint = ^sizeint;
  SizeUInt = DWord;
  psizeuint = ^sizeuint;

  PtrInt = Longint;
  PPtrInt = ^PtrInt;
  PtrUInt = DWord;
  PPtrUInt = ^PtrUInt;
  ValSInt = Longint;
  ValUInt = Cardinal;
  qword = uint64;
  pqword = ^qword;
 {$endif}
 {$ifdef VER2_2_0}
  PPtrUInt = ^PtrUInt;
 {$endif}

 preal = ^real;
 realty = type double;
 prealty = ^realty;

 datetimekindty = (dtk_date,dtk_time,dtk_datetime);

const

// emptytime = 0.0;
// nulltime = 1.0;        //fuer tdateeditmse
// emptydate = 0.0;
 maxint64 = $7fffffffffffffff;
 minint = low(integer);
 bigint = maxint div 2;
 nullmethod: tmethod = (code: nil; data: nil);

type
 halfinteger = -bigint..bigint;
 posinteger = 0..maxint;

 pobject = ^tobject;
 pmethod = ^tmethod;

 booleanarty = array of boolean;
 longboolarty = array of longbool;
 bytearty = array of byte;
 pbytearty = ^bytearty;
 wordarty = array of word;
 pwordarty = ^wordarty;
 longwordarty = array of longword;
 plongwordarty = ^longwordarty;
 integerarty = array of integer;
 pintegerarty = ^integerarty;
 int64arty = array of int64;
 pint64arty = ^int64arty;
 cardinalarty = array of cardinal;
 pcardinalarty = ^cardinalarty;
 pointerarty = array of pointer;
 ppointerarty = ^pointerarty;
 objectarty = array of tobject;
 pobjectarty = ^objectarty;
 classarty = array of tclass;
 pclassarty = ^classarty;
 realarty = array of realty;
 prealarty = ^realarty;
 currencyarty = array of currency;
 pcurrencyarty = ^currencyarty;
 datetimearty = array of tdatetime;
 pdatetimearty = ^datetimearty;
 ptrintarty = array of ptrint;
 pptrintarty = ^ptrintarty;
 ptruintarty = array of ptruint;
 pptruintarty = ^ptruintarty;
 qwordarty = array of qword;
 pqwordarty = ^qwordarty;
  
 pdatetime = ^tdatetime;

 complexty = record re,im: double; end;
 pcomplexty = ^complexty;
 complexarty = array of complexty;
 pcomplexarty = ^complexarty;
 stringarty = array of string;
 pstringarty = ^stringarty;
 stringararty = array of stringarty;
 pstringararty = ^stringararty;

 pointeraty = array[0..0] of pointer;
 ppointeraty = ^pointeraty;
 charpoaty = array[0..0] of pchar;
 pcharpoaty = ^charpoaty;
 byteaty = array[0..0] of byte;
 pbyteaty = ^byteaty;
 wordaty = array[0..0] of word;
 pwordaty = ^wordaty;
 integeraty = array[0..0] of integer;
 pintegeraty = ^integeraty;
 cardinalaty = array[0..0] of cardinal;
 pcardinalaty = ^cardinalaty;
 longboolaty = array[0..0] of longbool;
 qwordaty = array[0..0] of qword;
 pqwordaty = ^qwordaty;
 plongboolaty = ^longboolaty;
 ptrintaty = array[0..0] of ptrint;
 pptrintaty = ^ptrintaty;
 ptruintaty = array[0..0] of ptruint;
 pptruintaty = ^ptruintaty;
 complexaty = array[0..0] of complexty;
 pcomplexaty = ^complexaty;
 
 methodaty = array[0..0] of tmethod;
 pmethodaty = ^methodaty;
 stringaty = array[0..0] of string;
 pstringaty = ^stringaty;

 charaty = array[0..0] of char;
 pcharaty = ^charaty;

 widecharaty = array[0..0] of widechar;
 pwidecharaty = ^widecharaty;

 objectaty = array[0..0] of tobject;
 pobjectaty = ^objectaty;

 procty = procedure; 
 objectprocty = procedure of object;
 tagprocty = procedure (const tag: integer) of object;

 integerararty = array of integerarty;

 varrecarty = array of tvarrec;

 gridcoordty = record
  col,row: integer;
 end;
 gridcoordarty = array of gridcoordty;

 gridsizety = record
  colcount,rowcount: integer;
 end;
 
 gridrectty = record
  case integer of
   0:(
    col,row: integer;
    colcount,rowcount: integer;
   );
   1:(
    pos: gridcoordty;
    size: gridsizety;
   )
 end;

// winidty = cardinal;
 winidty = ptruint;
 winidarty = array of winidty;
 winidaty = array[0..0] of winidty;
 pwinidaty = ^winidaty;
 winidararty = array of winidarty;

const
 nullcomplex: complexty = (re: 0; im: 0);
 
function mergevarrec(a,b: array of const): varrecarty;
function issamemethod(const method1,method2: tmethod): boolean;
function isemptydatetime(const avalue: tdatetime): boolean;
function emptydatetime: tdatetime;

implementation

const
{$ifdef FPC_DOUBLE_HILO_SWAPPED}
 co1: array[0..7] of byte = (0,0,$f0,$ff,$0,0,0,0);      //- inf
{$else}
 co1: array[0..7] of byte = ($0,0,0,0,0,0,$f0,$ff);      //- inf
{$endif}
 
function emptydatetime: tdatetime;
begin
 result:= tdatetime(co1);
end;
 
function isemptydatetime(const avalue: tdatetime): boolean;
begin
 result:= avalue = real(co1);
end;

function mergevarrec(a,b: array of const): varrecarty;
begin
 setlength(result,length(a));
 if result <> nil then begin
  move(a[0],result[0],length(a)*sizeof(tvarrec));
 end;
 if high(b) >= 0 then begin
  setlength(result,high(result) + high(b) + 2);
  move(b[0],result[length(a)],length(b)*sizeof(tvarrec));
 end;
end;

function issamemethod(const method1,method2: tmethod): boolean;
begin
 result:= (method1.Code = method2.code) and (method1.Data = method2.Data);
end;

end.










