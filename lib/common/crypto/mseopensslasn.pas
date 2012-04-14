{ MSEgui Copyright (c) 2007-2012 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseopensslasn;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseopenssl,msectypes;
type
// ASN1 types
  pASN1_OBJECT = pointer;
  pASN1_STRING = ^ASN1_STRING;
  ASN1_STRING = record
	length: cint;
	asn1_type: cint;
	data: pointer;
	flags: clong;
	end;
  pASN1_IA5STRING = pASN1_STRING;
  pASN1_ENUMERATED = pASN1_STRING;
  pASN1_TIME = pASN1_STRING;
  pASN1_OCTET_STRING = pASN1_STRING;

var
 // ASN.1 functions
 ASN1_UTCTIME_New: function(): PASN1_UTCTIME; cdecl;
 ASN1_UTCTIME_Free: procedure(a: PASN1_UTCTIME); cdecl;
 ASN1_INTEGER_Set: function(a: PASN1_INTEGER; v: cint): cint; cdecl;
 ASN1_IA5STRING_new: function: pASN1_IA5STRING; cdecl;
 ASN1_INTEGER_free: procedure(x: pASN1_IA5STRING); cdecl;
 ASN1_INTEGER_get: function(a: pointer): clong; cdecl;
 ASN1_STRING_set_default_mask: procedure(mask: cardinal); cdecl;
 ASN1_STRING_get_default_mask: function: cardinal; cdecl;
 ASN1_TIME_print: function(fp: pBIO; a: pASN1_TIME): cint; cdecl;
 i2d_ASN1_TIME: function(a: pASN1_TIME; pp: PCharacter): cint; cdecl;
 d2i_ASN1_TIME: function(var a: pASN1_TIME; pp: PCharacter;
                                            length: clong): pASN1_TIME; cdecl;
  // Internal to ASN.1 and ASN.1 to internal conversion functions
  i2a_ASN1_INTEGER: function(bp: pBIO; a: pASN1_INTEGER): cint; cdecl;
  a2i_ASN1_INTEGER: function(bp: pBIO; bs: pASN1_INTEGER; buf: PCharacter;
                                        size: cint): cint; cdecl;
implementation
uses
 msedynload;
 
procedure init(const info: dynlibinfoty);
const
 funcs: array[0..12] of funcinfoty = (
   (n: 'ASN1_UTCTIME_new'; d: @ASN1_UTCTIME_new),
   (n: 'ASN1_UTCTIME_free'; d: @ASN1_UTCTIME_free),
   (n: 'ASN1_INTEGER_set'; d: @ASN1_INTEGER_set),
   (n: 'ASN1_IA5STRING_new'; d: @ASN1_IA5STRING_new),
   (n: 'ASN1_INTEGER_free'; d: @ASN1_INTEGER_free),
   (n: 'ASN1_INTEGER_get'; d: @ASN1_INTEGER_get),
   (n: 'ASN1_STRING_set_default_mask'; d: @ASN1_STRING_set_default_mask),
   (n: 'ASN1_STRING_get_default_mask'; d: @ASN1_STRING_get_default_mask),
   (n: 'ASN1_TIME_print'; d: @ASN1_TIME_print),
   (n:  'i2d_ASN1_TIME'; d: @i2d_ASN1_TIME),
   (n:  'd2i_ASN1_TIME'; d: @d2i_ASN1_TIME),
   (n:  'i2a_ASN1_INTEGER'; d: @i2a_ASN1_INTEGER),
   (n:  'a2i_ASN1_INTEGER'; d: @a2i_ASN1_INTEGER)
   );
begin
 getprocaddresses(info.libhandle,funcs);
end;

initialization
 regopensslinit(@init);
end.
