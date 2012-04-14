{ MSEgui Copyright (c) 2007-2012 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseopensslpkcs;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseopenssl,msectypes;
 
type
 
  pSTACK_OFPKCS7_SIGNER_INFO = pointer;
  
  pPKCS7_signed = ^PKCS7_signed;
  PKCS7_signed = record
    version: pASN1_cint;
    md_algs: pointer;  // ^STACK_OF(X509_ALGOR)
    cert: pointer;  // ^STACK_OF(X509)
    crl: pointer;  // ^STACK_OF(X509_CRL)
    signer_info: pSTACK_OFPKCS7_SIGNER_INFO;
    contents: pointer;  // ^struct pkcs7_st
  end;

  pPKCS7_signedandenveloped = ^PKCS7_signedandenveloped;
  PKCS7_signedandenveloped = record
    version: pASN1_cint;
    md_algs: pointer;  // ^STACK_OF(X509_ALGOR)
    cert: pointer;  // ^STACK_OF(X509)
    crl: pointer;  // ^STACK_OF(X509_CRL)
    signer_info: pSTACK_OFPKCS7_SIGNER_INFO;
    enc_data: pointer;  // ^PKCS7_ENC_CONTENT
    recipientinfo: pointer;  // ^STACK_OF(PKCS7_RECIP_INFO)
  end;

  pPKCS7 = ^PKCS7;
  PKCS7 = record
    asn1: PCharacter;
    length: cint;
    state: cint;
    detached: cint;
    asn1_type: pointer; // ^ASN1_OBJECT
    case integer of
      0: (ptr: pASN1_OCTET_STRING);
      1: (data: pointer);  // ^PKCS7_SIGNED
      2: (sign: pPKCS7_signed);  // ^PKCS7_SIGNED
      3: (enveloped: pointer);  // ^PKCS7_ENVELOPE
      4: (signed_and_enveloped: pPKCS7_signedandenveloped);
      5: (digest: pointer);  // ^PKCS7_DIGEST
      6: (encrypted: pointer);  // ^PKCS7_ENCRYPT
      7: (other: pointer);  // ^ASN1_TYPE
  end;

  pPKCS12 = ^PKCS12;
  PKCS12 = record
    version: pointer;
    mac: pointer;
    authsafes: pPKCS7;
  end;
  
  pPKCS8_Priv_Key_Info = ^PKCS8_Priv_Key_Info;
  PKCS8_Priv_Key_Info = record
    broken: cint; // Flag for various broken formats */
    version: pASN1_INTEGER;
    pkeyalg: Pointer; // X509_ALGOR *pkeyalg;
    pkey: Pointer; // ASN1_TYPE *pkey; /* Should be OCTET STRING but some are broken */
    attributes: Pointer; // STACK_OF(X509_ATTRIBUTE) *attributes;
  end;

var
// PKCS#5 functions
 PKCS5_PBKDF2_HMAC_SHA1: function(pass: PCharacter; passlen: cint;
    salt: pointer; saltlen: cint; iter: cint;
    keylen: cint; u: pointer): cint; cdecl;
// PKCS#7 functions
 PKCS7_sign: function(signcert: pX509; pkey: pEVP_PKEY; certs: pointer;
    data: pBIO; flags: cint): pPKCS7; cdecl;
 PKCS7_get_signer_info: function(p7: pPKCS7): pSTACK_OFPKCS7_SIGNER_INFO; cdecl;
 PKCS7_verify: function(p7: pPKCS7; certs: pointer; store: pSTACK_OFX509;
    indata: pBIO; _out: pBIO; flags: cint): cint; cdecl;
 PKCS7_get0_signers: function(p7: pPKCS7; certs: pSTACK_OFX509;
    flags: cint): pSTACK_OFX509; cdecl;
 PKCS7_signatureVerify: function(bio: pBIO; p7: pPKCS7; si: pPKCS7_SIGNER_INFO;
    x509: pX509): cint; cdecl;
 PKCS7_encrypt: function(certs: pSTACK_OFX509; _in: pBIO;
    cipher: pEVP_CIPHER; flags: cint): pPKCS7; cdecl;
 PKCS7_decrypt: function(p7: pPKCS7; pkey: pEVP_PKEY; cert: pX509;
    data: pBIO; flags: cint): cint; cdecl;
 PKCS7_free: procedure(p7: pPKCS7); cdecl;
 PKCS7_ctrl: function(p7: pPKCS7; cmd: cint; larg: clong;
    parg: PCharacter): clong; cdecl;
 PKCS7_dataInit: function(p7: pPKCS7; bio: pBIO): pBIO; cdecl;
// PKCS#7 DER/PEM to internal conversion function
{
    d2i_PKCS7_DIGEST                        @737
    d2i_PKCS7_ENCRYPT                       @738
    d2i_PKCS7_ENC_CONTENT                   @739
    d2i_PKCS7_ENVELOPE                      @740
    d2i_PKCS7_ISSUER_AND_SERIAL             @741
    d2i_PKCS7_RECIP_INFO                    @742
    d2i_PKCS7_SIGNED                        @743
    d2i_PKCS7_SIGNER_INFO                   @744
    d2i_PKCS7_SIGN_ENVELOPE                 @745 }
 EVP_PKCS82PKEY: function(p8 : pPKCS8_Priv_Key_Info) : pEVP_PKEY; cdecl;
 PKCS8_decrypt: function(p8: pX509_SIG;
          Pass: PCharacter; PassLen: cint): pPKCS8_Priv_Key_Info; cdecl;
 PKCS8_PRIV_KEY_INFO_free: procedure(var a: pPKCS8_Priv_Key_Info); cdecl;
 PKCS12_new: function: pPKCS12; cdecl;
 PEM_read_bio_PKCS7: function(bp: pBIO; data: pointer;
                       cb: TPWCallbackFunction; u: pointer): pPKCS7; cdecl;
 PKCS12_parse: function(p12: SslPtr; pass: pchar; pkey,
                      cert, ca: pSslPtr): cint; cdecl;
 PKCS12_free: procedure(p12: SslPtr); cdecl;
 i2d_PKCS12_bio: function(bp: pBIO; pkcs12: pPKCS12): cint; cdecl;
 d2i_PKCS7: function(var a: pPKCS7; pp: pointer;
                                         length: clong): pPKCS7; cdecl;
 d2i_PKCS7_bio: function(bp: pBIO; p7: pPKCS7): pPKCS7; cdecl;
 i2d_PKCS7_bio: function(bp: pBIO; p7: pPKCS7): cint; cdecl;
 d2i_PKCS8_bio: function(bp: pBIO; p8: pX509_SIG): pX509_SIG; cdecl;
 d2i_PKCS8_PRIV_KEY_INFO: function(var a: pPKCS8_Priv_Key_Info; pp: PCharacter;
                                 Length: clong): pPKCS8_Priv_Key_Info; cdecl;

function PKCS7_get_detached(p7: pPKCS7): pointer;

implementation
uses
 msedynload;
 
function PKCS7_get_detached(p7: pPKCS7): pointer;
begin
  result := pointer(PKCS7_ctrl(p7, 2, 0, nil));
end;

procedure init(const info: dynlibinfoty);
const
 funcs: array[0..23] of funcinfoty = (
   (n: 'PKCS5_PBKDF2_HMAC_SHA1'; d: @PKCS5_PBKDF2_HMAC_SHA1),
   (n: 'PKCS7_sign'; d: @PKCS7_sign),
   (n: 'PKCS7_get_signer_info'; d: @PKCS7_get_signer_info),
   (n: 'PKCS7_verify'; d: @PKCS7_verify),
   (n: 'PKCS7_get0_signers'; d: @PKCS7_get0_signers),
   (n: 'PKCS7_signatureVerify'; d: @PKCS7_signatureVerify),
   (n: 'PKCS7_encrypt'; d: @PKCS7_encrypt),
   (n: 'PKCS7_decrypt'; d: @PKCS7_decrypt),
   (n: 'PKCS7_free'; d: @PKCS7_free),
   (n: 'PKCS7_ctrl'; d: @PKCS7_ctrl),
   (n: 'PKCS7_dataInit'; d: @PKCS7_dataInit),
   (n: 'EVP_PKCS82PKEY'; d: @EVP_PKCS82PKEY),
   (n: 'PKCS8_decrypt'; d: @PKCS8_decrypt),
   (n: 'PKCS8_PRIV_KEY_INFO_free'; d: @PKCS8_PRIV_KEY_INFO_free),
   (n: 'PKCS12_new'; d: @PKCS12_new),
   (n: 'PEM_read_bio_PKCS7'; d: @PEM_read_bio_PKCS7),
   (n: 'PKCS12_parse'; d: @PKCS12_parse),
   (n: 'PKCS12_free'; d: @PKCS12_free),
   (n:  'i2d_PKCS12_bio'; d: @i2d_PKCS12_bio),
   (n:  'd2i_PKCS7'; d: @d2i_PKCS7),
   (n:  'd2i_PKCS7_bio'; d: @d2i_PKCS7_bio),
   (n:  'i2d_PKCS7_bio'; d: @i2d_PKCS7_bio),
   (n:  'd2i_PKCS8_bio'; d: @d2i_PKCS8_bio),
   (n:  'd2i_PKCS8_PRIV_KEY_INFO'; d: @d2i_PKCS8_PRIV_KEY_INFO)
  );
begin
 getprocaddresses(info.libhandle,funcs);
end;

initialization
 regopensslinit(@init);
end.
