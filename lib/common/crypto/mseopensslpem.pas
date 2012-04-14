{ MSEgui Copyright (c) 2007-2012 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseopensslpem;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseopenssl,msectypes;
var
// PEM functions
 PEM_read_bio_RSAPrivateKey: function(bp: pBIO; var x: pRSA;cb: TPWCallbackFunction; u: pointer): pRSA; cdecl;
 PEM_write_bio_RSAPrivateKey: function(bp: pBIO; x: pRSA; const enc: pEVP_CIPHER;
    kstr: PCharacter; klen: cint; cb: TPWCallbackFunction; u: pointer): cint; cdecl;
 PEM_read_bio_RSAPublicKey: function(bp: pBIO; var x: pRSA;
    cb: TPWCallbackFunction; u: pointer): pRSA; cdecl;
 PEM_write_bio_RSAPublicKey: function(bp: pBIO; x: pRSA): cint; cdecl;
 PEM_read_bio_DSAPrivateKey: function(bp: pBIO; var dsa: pDSA;
    cb: TPWCallbackFunction; data: pointer): pDSA; cdecl;
 PEM_write_bio_DSAPrivateKey: function(bp: pBIO; dsa: pDSA; const enc: pEVP_CIPHER;
    kstr: PCharacter; klen: cint; cb: TPWCallbackFunction;
    data: pointer): cint; cdecl;
 PEM_read_bio_PUBKEY: function(bp: pBIO; var x: pEVP_PKEY; cb: TPWCallbackFunction; u: pointer): pEVP_PKEY; cdecl;
 PEM_write_bio_PUBKEY: function(bp: pBIO; x: pEVP_PKEY): cint; cdecl;
 PEM_read_bio_X509: function(bp: pBIO; var x: pX509; cb: TPWCallbackFunction;
    u: pointer): pX509; cdecl;
 PEM_write_bio_X509: function(bp: pBIO; x: pX509): cint; cdecl;
 PEM_read_bio_X509_AUX: function(bp: pBIO; var x: pX509; cb: TPWCallbackFunction;
    u: pointer): pX509; cdecl;
 PEM_write_bio_X509_AUX: function(bp: pBIO; x: pX509): cint; cdecl;
 PEM_read_bio_X509_REQ: function(bp: pBIO; var x: pX509_REQ; cb: TPWCallbackFunction;
    u: pointer): pX509_REQ; cdecl;
 PEM_write_bio_X509_REQ: function(bp: pBIO; x: pX509_REQ): cint; cdecl;
 PEM_read_bio_X509_CRL: function(bp: pBIO; var x: pX509_CRL; cb: TPWCallbackFunction;
    u: pointer): pX509_CRL; cdecl;
 PEM_write_bio_X509_CRL: function(bp: pBIO; x: pX509_CRL): cint; cdecl;
 PEM_read_bio_PrivateKey: function(bp: pBIO; var x: pEVP_PKEY;
    cb: TPWCallbackFunction; u: pointer): pEVP_PKEY; cdecl;
  PEM_write_bio_PrivateKey: function(bp: pBIO; x: pEVP_PKEY;
    const enc: pEVP_CIPHER; kstr: PCharacter; klen: cint; cb: TPWCallbackFunction;
    u: pointer): cint; cdecl;
 PEM_write_bio_PKCS7: function(bp: pBIO; x: pPKCS7): cint; cdecl;

implementation
uses
 msedynload;
 
procedure init(const info: dynlibinfoty);
const
 funcs: array[0..18] of funcinfoty = (
   (n: 'PEM_read_bio_RSAPrivateKey'; d: @PEM_read_bio_RSAPrivateKey),
   (n: 'PEM_write_bio_RSAPrivateKey'; d: @PEM_write_bio_RSAPrivateKey),
   (n: 'PEM_read_bio_RSAPublicKey'; d: @PEM_read_bio_RSAPublicKey),
   (n: 'PEM_write_bio_RSAPublicKey'; d: @PEM_write_bio_RSAPublicKey),
   (n: 'PEM_read_bio_DSAPrivateKey'; d: @PEM_read_bio_DSAPrivateKey),
   (n: 'PEM_write_bio_DSAPrivateKey'; d: @PEM_write_bio_DSAPrivateKey),
   (n: 'PEM_read_bio_PUBKEY'; d: @PEM_read_bio_PUBKEY),
   (n: 'PEM_write_bio_PUBKEY'; d: @PEM_write_bio_PUBKEY),
   (n: 'PEM_read_bio_X509'; d: @PEM_read_bio_X509),
   (n: 'PEM_write_bio_X509'; d: @PEM_write_bio_X509),
   (n: 'PEM_read_bio_X509_AUX'; d: @PEM_read_bio_X509_AUX),
   (n: 'PEM_write_bio_X509_AUX'; d: @PEM_write_bio_X509_AUX),
   (n: 'PEM_read_bio_X509_REQ'; d: @PEM_read_bio_X509_REQ),
   (n: 'PEM_write_bio_X509_REQ'; d: @PEM_write_bio_X509_REQ),
   (n: 'PEM_read_bio_X509_CRL'; d: @PEM_read_bio_X509_CRL),
   (n: 'PEM_write_bio_X509_CRL'; d: @PEM_write_bio_X509_CRL),
   (n: 'PEM_read_bio_PrivateKey'; d: @PEM_read_bio_PrivateKey),
   (n: 'PEM_write_bio_PrivateKey'; d: @PEM_write_bio_PrivateKey),
   (n: 'PEM_write_bio_PKCS7'; d: @PEM_write_bio_PKCS7)
  );
begin
 getprocaddresses(info.libhandle,funcs);
end;

initialization
 regopensslinit(@init);
end.
