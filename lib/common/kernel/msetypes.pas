{ MSEgui Copyright (c) 1999-2014 by Martin Schreiber

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
 {$ifndef mse_nounicodestring}
  {$if defined(FPC) and (fpc_fullversion >= 020300)}
   {$define mse_unicodestring}
  {$ifend}
 {$endif}
 {$ifndef mse_unicodestring}
  {$ifdef FPC_WINLIKEWIDESTRING}
   {$define msestringsarenotrefcounted}
  {$endif}
 {$endif}
{$else}
 {$ifdef mswindows}
  {$define msestringsarenotrefcounted}
 {$endif}
{$endif}

{$ifdef FPC}
 {$if defined(FPC) and (fpc_fullversion >= 020300)}
  {$define mse_fpc_2_3_0}
 {$ifend}
 {$if defined(FPC) and (fpc_fullversion >= 020402)}
  {$define mse_fpc_2_4_2}
 {$ifend}

 {$ifdef mse_fpc_2_3_0}{$define longwordbyteset}{$endif}

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

  //MSElang types
 card8 = byte;
 pcard8 = ^card8;
 card8arty = array of card8;
 pcard8arty = ^card8arty;
 card8ararty = array of card8arty;
 pcard8ararty = ^card8ararty;
 card16 = word;
 pcard16 = ^card16;
 card16arty = array of card16;
 pcard16arty = ^card16arty;
 card16ararty = array of card16arty;
 pcard16ararty = ^card16ararty;
 card32 = longword;
 pcard32 = ^card32;
 card32arty = array of card32;
 pcard32arty = ^card32arty;
 card32ararty = array of card32arty;
 pcard32ararty = ^card32ararty;
 card64 = qword;
 pcard64 = ^card64;
 card64arty = array of card64;
 pcard64arty = ^card64arty;
 card64ararty = array of card64arty;
 pcard64ararty = ^card64ararty;
 int8 = shortint;
 pint8 = ^int8;
 int8arty = array of int8;
 pint8arty = ^int8arty;
 int8ararty = array of int8arty;
 pint8ararty = ^int8ararty;
 int16 = smallint;
 pint16 = ^int16;
 int16arty = array of int16;
 pint16arty = ^int16arty;
 int16ararty = array of int16arty;
 pint16ararty = ^int16ararty;
 int32 = integer;
 pint32 = ^int32;
 int32arty = array of int32;
 pint32arty = ^int32arty;
 int32ararty = array of int32arty;
 pint32ararty = ^int32ararty;
// int64 = int64;
// pint64 = ^int64;
 int64arty = array of int64;
 pint64arty = ^int64arty;
 int64ararty = array of int64arty;
 pint64ararty = ^int64ararty;

 flo32 = single;
 pflo32 = ^flo32;
 flo32arty = array of flo32;
 pflo32arty = ^flo32arty;
 flo32ararty = array of flo32arty;
 pflo32ararty = ^flo32ararty;
 
 flo64 = double;
 pflo64 = ^flo64;
 flo64arty = array of flo64;
 pflo64arty = ^flo64arty;
 flo64ararty = array of flo64arty;
 pflo64ararty = ^flo64ararty;

 float32 = single;            //todo: remove
 pfloat32 = ^float32;
 float32arty = array of float32;
 pfloat32arty = ^float32arty;
 float64 = double;
 pfloat64 = ^float64;
 float64arty = array of float64;
 pfloat64arty = ^float64arty;
 float = float64;
 pfloat = ^float;
 floatarty = array of float;
 pfloatarty = ^floatarty;
  
 uint8 = byte;
 puint8 = ^uint8;
 uint16 = word;
 puint16 = ^uint16;
 uint32 = longword;
 puint32 = ^uint32;
 uint64 = qword;
 puint64 = ^uint64;
 sint8 = shortint;
 psint8 = ^sint8;
 sint16 = smallint;
 psint16 = ^sint16;
 sint32 = integer;
 psint32 = ^sint32;
 sint64 = int64;
 psint64 = ^sint64;

 char8 = char;
 pchar8 = ^char8;
 char16 = unicodechar;
 pchar16 = ^char16;
 char32 = ucs4char;
 pchar32 = ^char32;
  
{$ifndef FPC} //delphi
 {$ifndef mswindows}
  uint64 = type int64; //kylix
 {$endif}
  DWord = Longword;
  pdword = ^dword;
  SizeInt = Longint;
  psizeint = ^sizeint;
  SizeUInt = DWord;
  psizeuint = ^sizeuint;
  plongbool = ^longbool;
  ppdouble = ^pdouble;

  PtrInt = Longint;
  PPtrInt = ^PtrInt;
  PtrUInt = DWord;
  PPtrUInt = ^PtrUInt;
  ValSInt = Longint;
  ValUInt = Cardinal;
  qword = uint64;
  pqword = ^qword;
  size_t = dword;
  unicodestring = widestring;
  unicodechar = widechar;
  WINBOOL = longbool;
{$else}
 {$ifndef mse_fpc_2_4_2}
  ppdouble = ^pdouble;
 {$endif}
{$endif}
 {$ifdef VER2_2_0}
  PPtrUInt = ^PtrUInt;
 {$endif}

 ppsizeint = ^psizeint;
 ppppointer = ^pppointer;
 preal = ^real;
 realty = type double;
 prealty = ^realty;

 datetimekindty = (dtk_date,dtk_time,dtk_datetime);
 dayofweekty = (dw_sun,dw_mon,dw_tue,dw_wed,dw_thu,dw_fri,dw_sat);

const
 maxdatasize = $7fffffff;
 {$ifdef mswindows}
 pathdelim = '\';
 lineend = #$0d#$0a;
 {$else}
 pathdelim = '/';
 lineend = #$0a;
 {$endif}

 c_dle = #$10;
 c_stx = #$02;
 c_etx = #$03;
 c_linefeed = #$0a;
 c_formfeed = #$0c;
 c_return = #$0d;
 c_tab = #$09;
 c_backspace = #$08;
 c_esc = #$1b;
 c_delete = #$7f;
 c_softhyphen = #$ad;

type
 {$ifdef mse_unicodestring}
 msestring = unicodestring;
 msechar = unicodechar;
 pmsechar = punicodechar;
 {$else}
 msestring = widestring;
 msechar = widechar;
 pmsechar = pwidechar;
 {$endif}

 pmsestring = ^msestring;
 msestringarty = array of msestring;
 pmsestringarty = ^msestringarty;
 msestringaty = array[0..0] of msestring;
 pmsestringaty = ^msestringaty;
 msestringararty = array of msestringarty;

 widestringarty = array of widestring;
// charaty = array[0..maxdatasize-1] of char;
// pcharaty = ^charaty;
 msecharaty = array[0..maxdatasize div sizeof(msechar)-1] of msechar;
 pmsecharaty = ^msecharaty;
 captionty = msestring;
 filenamety = msestring;
 pfilenamety = ^filenamety;
 filenamearty = msestringarty;
 filenamechar = msechar;
 pfilenamechar = ^filenamechar;

const
{$ifndef FPC}
 emptyreal = -1/0;
{$else}
 emptyreal = real(-1/0);
 emptydouble = double(-1/0);
 emptyfloat64 = float64(-1/0);
{$endif}
 emptydatetime = emptyreal;

// emptytime = 0.0;
// nulltime = 1.0;        //fuer tdateeditmse
// emptydate = 0.0;
 maxint64 = $7fffffffffffffff;
 minint = low(integer);
 bigint = maxint div 2;
 nullmethod: tmethod = (code: nil; data: nil);
{$ifdef cpu64}
 pointeralignmask = ptruint($ffffffffffffffff) - $7;
{$else}
 pointeralignmask = ptruint($ffffffff) - $3;
{$endif}

type
 halfinteger = -bigint..bigint;
 posinteger = 0..maxint;

 pobject = ^tobject;
 pmethod = ^tmethod;

 booleanarty = array of boolean;
 pbooleanarty = ^booleanarty;
 longboolarty = array of longbool;
 bytearty = array of byte;
 pbytearty = ^bytearty;
 wordarty = array of word;
 pwordarty = ^wordarty;
 smallintarty = array of smallint;
 psmallintarty = ^smallintarty;
 longwordarty = array of longword;
 plongwordarty = ^longwordarty;
 integerarty = array of integer;
 pintegerarty = ^integerarty;
 cardinalarty = array of cardinal;
 pcardinalarty = ^cardinalarty;
 pointerarty = array of pointer;
 ppointerarty = ^pointerarty;
 pointerararty = array of pointerarty;
 objectarty = array of tobject;
 pobjectarty = ^objectarty;
 classarty = array of tclass;
 pclassarty = ^classarty;

 realarty = array of realty;
 prealarty = ^realarty;
 realararty = array of realarty;

 singlearty = array of single;
 singlepoarty = array of psingle;
 psinglearty = ^singlearty;
 singleararty = array of singlearty;

 doublearty = array of double;
 doublepoarty = array of pdouble;
 pdoublearty = ^doublearty;
 doubleararty = array of doublearty;

 currencyarty = array of currency;
 pcurrencyarty = ^currencyarty;
 datetimearty = array of tdatetime;
 pdatetimearty = ^datetimearty;
 datetimeaty = array[0..0] of tdatetime;
 pdatetimeaty = ^datetimeaty;
 ptrintarty = array of ptrint;
 pptrintarty = ^ptrintarty;
 ptruintarty = array of ptruint;
 pptruintarty = ^ptruintarty;
 qwordarty = array of qword;
 pqwordarty = ^qwordarty;

 pdatetime = ^tdatetime;
 ppvariant = ^pvariant;

 complexty = record re,im: real; end;
 pcomplexty = ^complexty;
 complexarty = array of complexty;
 pcomplexarty = ^complexarty;
 complexararty = array of complexarty;
 stringarty = array of string;
 pstringarty = ^stringarty;
 stringararty = array of stringarty;
 pstringararty = ^stringararty;
 ansistringarty = array of ansistring;
 pansistringarty = ^ansistringarty;
 ansistringararty = array of ansistringarty;
 pansistringararty = ^ansistringararty;

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
 longwordaty = array[0..0] of longword;
 plongwordaty = ^longwordaty;
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
 widestringaty = array[0..0] of widestring;
 pwidestringaty = ^widestringaty;
 ansistringaty = array[0..0] of ansistring;
 pansistringaty = ^ansistringaty;

 charaty = array[0..0] of char;
 pcharaty = ^charaty;

 widecharaty = array[0..0] of widechar;
 pwidecharaty = ^widecharaty;

 objectaty = array[0..0] of tobject;
 pobjectaty = ^objectaty;

 procty = procedure; 
 proceventty = procedure of object;
 proceventarty = array of proceventty;
 tageventtyty = procedure (const tag: integer) of object;

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
 winidty = type ptruint; //used in published event properties
 winidarty = array of winidty;
 winidaty = array[0..0] of winidty;
 pwinidaty = ^winidaty;
 winidararty = array of winidarty;
 filehandlety = longint;

 procedurety = procedure;
 
const
 nullcomplex: complexty = (re: 0; im: 0);
 bigdatetime = 401768.99999; //2999-12-31
 
function mergevarrec(a,b: array of const): varrecarty;
function issamemethod(const method1,method2: tmethod): boolean;
function isemptydatetime(const avalue: tdatetime): boolean;
                         {$ifdef FPC}inline;{$endif} deprecated;
            //use x = emptydatetime instead
//function emptydatetime: tdatetime;
function makecomplex(const are: real; aim: real): complexty;
         {$ifdef FPC} inline; {$endif}
function mc(const are: real; aim: real): complexty;
         {$ifdef FPC} inline; {$endif}
//procedure splitcomplexar(const acomplex: complexarty; out re,im: realarty);

implementation
//uses
// msearrayutils;
(*
const
{$ifdef FPC_DOUBLE_HILO_SWAPPED}
 co1: array[0..7] of byte = (0,0,$f0,$ff,$0,0,0,0);      //- inf
{$else}
 co1: array[0..7] of byte = ($0,0,0,0,0,0,$f0,$ff);      //- inf
{$endif}
*)
{
function emptydatetime: tdatetime;
begin
 result:= tdatetime(co1);
end;
}
function isemptydatetime(const avalue: tdatetime): boolean;
begin
 result:= avalue = emptydatetime;
// result:= avalue = real(co1);
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

function makecomplex(const are: real; aim: real): complexty;
begin
 result.re:= are;
 result.im:= aim;
end;

function mc(const are: real; aim: real): complexty;
begin
 result.re:= are;
 result.im:= aim;
end;

end.










