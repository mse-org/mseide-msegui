unit msectypes;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
{$ifndef FPC}
 {$ifndef mswindows}
uses
 msetypes; //for uint64 in kylix
 {$endif}
{$endif}
//todo: win64
type
// from bits/types.h
 __S16_TYPE = smallint;
 __U16_TYPE = word;
 __S32_TYPE = longint;
 __U32_TYPE = longword;
 __S64_TYPE = int64;
 __U64_TYPE = uint64;
 
{$ifndef CPU64}
 __ULONGLONGWORD_TYPE = uint64;
 __SLONGLONGWORD_TYPE = int64;
 __SLONGWORD_TYPE = longint;
 __ULONGWORD_TYPE = longword;
 __SQUAD_TYPE = int64;
 __UQUAD_TYPE = uint64;
 __SWORD_TYPE = integer;
 __UWORD_TYPE = longword;
 __SLONG32_TYPE = integer;
 __ULONG32_TYPE = longword;
{$else}
 __ULONGLONGWORD_TYPE = uint64;
 __SLONGLONGWORD_TYPE = int64;
 __SLONGWORD_TYPE = int64;
 __ULONGWORD_TYPE = uint64;
 __SQUAD_TYPE = int64;
 __UQUAD_TYPE = uint64;
 __SWORD_TYPE = int64;
 __UWORD_TYPE = uint64;
 __SLONG32_TYPE = integer;
 __ULONG32_TYPE = longword;
{$endif}

 cchar = char;
 pcchar = ^cchar;
 ppcchar = ^pcchar;
 cuchar = byte;
 pcuchar = ^cuchar;
 ppcuchar = ^pcuchar;
 culonglong = __ULONGLONGWORD_TYPE;
 clonglong = __SLONGLONGWORD_TYPE;
 culong = __ULONGWORD_TYPE;
 pculong = ^culong;
 clong = __SLONGWORD_TYPE;
 pclong = ^clong;
 cint = __S32_TYPE;
 pcint = ^cint;
 cuint = __U32_TYPE;
 pcuint = ^cuint;
 cshort = __S16_TYPE;
 csshort  = __S16_TYPE;
 pcshort = ^cshort;
 cushort = __U16_TYPE;
 pcushort = ^cushort;
 cuint16 = __U16_TYPE;
 cint64 = __SQUAD_TYPE;

 cfloat = single;
 pcfloat = ^cfloat;
 cdouble = double;
 pcdouble = ^cdouble;

implementation
end.
