{ MSEgui Copyright (c) 2007-2012 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseopensslaes;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseopenssl,msectypes;
 
var
 AES_set_decrypt_key: function(userKey: PCharacter; bits: cint;
                                             key: pAES_KEY): cint; cdecl;
 AES_cbc_encrypt: procedure(buffer: PCharacter; u: PCharacter; length: clong;
    key: pAES_KEY; ivec: pointer; enc: cint); cdecl;

implementation
uses
 msedynload;
 
procedure init(const info: dynlibinfoty);
const
 funcs: array[0..1] of funcinfoty = (
   (n: 'AES_set_decrypt_key'; d: @AES_set_decrypt_key),
   (n: 'AES_cbc_encrypt'; d: @AES_cbc_encrypt)
  );
begin
 getprocaddresses(info,funcs);
end;

initialization
 regopensslinit(@init);
end.
