{ MSEgui Copyright (c) 2007-2012 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseopenssldes;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseopenssl,msectypes;

type
 DES_cblock = array[0..7] of Byte;
 PDES_cblock = ^DES_cblock;
 des_ks_struct = packed record
   ks: DES_cblock;
   weak_key: cint;
 end;
 des_key_schedule = array[0..15] of des_ks_struct;

var
 DES_set_odd_parity: procedure(Key: des_cblock); cdecl;
 DES_set_key_checked: function(key: des_cblock;
                  schedule: des_key_schedule): cint; cdecl;
 DES_ecb_encrypt: procedure(Input: des_cblock; output: des_cblock;
                  ks: des_key_schedule; enc: cint); cdecl;

implementation
uses
 msedynload;
 
procedure init(const info: dynlibinfoty);
const
 funcs: array[0..2] of funcinfoty = (
   (n: 'DES_set_odd_parity'; d: {$ifndef FPC}@{$endif}@DES_set_odd_parity),
   (n: 'DES_set_key_checked'; d: {$ifndef FPC}@{$endif}@DES_set_key_checked),
   (n: 'DES_ecb_encrypt'; d: {$ifndef FPC}@{$endif}@DES_ecb_encrypt)
  );
begin
 getprocaddresses(info,funcs);
end;

initialization
 regopensslinit(@init);
end.
