unit msectypes;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
//todo: win64
type
// from bits/types.h
 __S16_TYPE = smallint;
 __U16_TYPE = word;
 __S32_TYPE = longint;
 __U32_TYPE = longword;
{$ifndef CPU64}
 __SLONGWORD_TYPE = longint;
 __ULONGWORD_TYPE = longword;
 __SQUAD_TYPE = int64;
 __UQUAD_TYPE = uint64;
 __SWORD_TYPE = integer;
 __UWORD_TYPE = longword;
 __SLONG32_TYPE = integer;
 __ULONG32_TYPE = longword;
 __S64_TYPE = int64;
 __U64_TYPE = uint64;
{$else}
 __SLONGWORD_TYPE = int64;
 __ULONGWORD_TYPE = uint64;
 __SQUAD_TYPE = int64;
 __UQUAD_TYPE = uint64;
 __SWORD_TYPE = int64;
 __UWORD_TYPE = uint64;
 __SLONG32_TYPE = integer;
 __ULONG32_TYPE = longword;
 __S64_TYPE = int64;
 __U64_TYPE = uint64;
{$endif}

 culong = __ULONGWORD_TYPE;
 pculong = ^culong;
 clong = __SLONGWORD_TYPE;
 pclong = ^clong;
 cint = __S32_TYPE;
 pcint = ^cint;
 cuint = __U32_TYPE;
 pcuint = ^cuint;
 cshort = __S16_TYPE;
 pcshort = ^cshort;
 cushort = __U16_TYPE;
 pcushort = ^cushort;


implementation
end.
