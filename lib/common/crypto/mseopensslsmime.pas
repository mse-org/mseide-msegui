{ MSEgui Copyright (c) 2007-2012 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseopensslsmime;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseopenssl,msectypes;
 
var
// SMIME function
 SMIME_write_PKCS7: function(bp: pBIO; p7: pPKCS7;
                                data: pBIO; flags: cint): cint; cdecl;
 SMIME_read_PKCS7: function(bp: pBIO; var bcont: pBIO): pPKCS7; cdecl;

implementation
uses
 msedynload;
 
procedure init(const info: dynlibinfoty);
const
 funcs: array[0..1] of funcinfoty = (
   (n: 'SMIME_write_PKCS7'; d: @SMIME_write_PKCS7),
   (n: 'SMIME_read_PKCS7'; d: @SMIME_read_PKCS7)
  );
begin
 getprocaddresses(info,funcs);
end;

initialization
 regopensslinit(@init);
end.