{ MSEgui Copyright (c) 2007-2012 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseopensslrsa;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseopenssl,msectypes;

const
 RSA_PKCS1_PADDING =	1;
 RSA_SSLV23_PADDING =	2;
 RSA_NO_PADDING	=	3;
 RSA_PKCS1_OAEP_PADDING	= 4;
 RSA_X931_PADDING	= 5;
//* EVP_PKEY_ only */
 RSA_PKCS1_PSS_PADDING =	6;

 RSA_PKCS1_PADDING_SIZE	= 11;

type
  pRSA_METHOD = pointer;
  RSA = record
	// The first parameter is used to pickup errors where
	// this is passed instead of aEVP_PKEY, it is set to 0
	pad: cint;
	version: cint;
	meth: pRSA_METHOD;
	n: pBIGNUM;
	e: pBIGNUM;
	d: pBIGNUM;
	p: pBIGNUM;
	q: pBIGNUM;
	dmp1: pBIGNUM;
	dmq1: pBIGNUM;
	iqmp: pBIGNUM;
	// be careful using this if the RSA structure is shared
	ex_data: CRYPTO_EX_DATA;
	references: cint;
	flags: cint;
	// Used to cache montgomery values
	_method_mod_n: pBN_MONT_CTX;
	_method_mod_p: pBN_MONT_CTX;
	_method_mod_q: pBN_MONT_CTX;
        // all BIGNUM values are actually in the following data, if it is not
	// NULL
	bignum_data: ^byte;
	blinding: pBN_BLINDING;
  end;


var
  // RSA function
 RSA_new: function: pRSA; cdecl;
 RSA_free: procedure(r: pRSA); cdecl;
 RSA_new_method: function(method: pRSA_METHOD): pRSA; cdecl;
 RSA_size: function(pkey: pRSA): cint; cdecl;
 RSA_check_key: function(arg0: pRSA): cint; cdecl;
 RSA_public_encrypt: function(flen: cint; from: pcuchar; _to: pcuchar;
                                        rsa: pRSA; padding: cint): cint; cdecl;
 RSA_private_encrypt: function(flen: cint; from: pcuchar; _to: pcuchar;
                                        rsa: pRSA; padding: cint): cint; cdecl;
 RSA_public_decrypt: function(flen: cint; from: pcuchar; _to: pcuchar;
                                        rsa: pRSA; padding: cint): cint; cdecl;
 RSA_private_decrypt: function(flen: cint; from: pcuchar; _to: pcuchar;
                                        rsa: pRSA; padding: cint): cint; cdecl;
 RSA_flags: function(r: pRSA): cint; cdecl;
 RSA_set_default_method: procedure(meth: pRSA_METHOD); cdecl;
 RSA_get_default_method: function: pRSA_METHOD; cdecl;
 RSA_get_method: function(rsa: pRSA): pRSA_METHOD; cdecl;
 RSA_set_method: function(rsa: pRSA; meth: pRSA_METHOD): pRSA_METHOD; cdecl;
 RSA_memory_lock: function(r: pRSA):cint; cdecl;
 RSA_PKCS1_SSLeay: function: pRSA_METHOD; cdecl;
 ERR_load_RSA_strings: procedure;cdecl;
 RSA_generate_key: function(bits, e: cint;
           callback: PFunction; cb_arg: SslPtr): PRSA; cdecl;
 d2i_RSAPrivateKey_bio: function(bp: pBIO; rsa: pRSA): pRSA; cdecl;
 i2d_RSAPrivateKey_bio: function(bp: pBIO; rsa: pRSA): cint; cdecl;

implementation
uses
 msedynload;
 
procedure init(const info: dynlibinfoty);
const
 funcs: array[0..19] of funcinfoty = (
   (n: 'RSA_new'; d: @RSA_new),
   (n: 'RSA_free'; d: @RSA_free),
   (n: 'RSA_new_method'; d: @RSA_new_method),
   (n: 'RSA_size'; d: @RSA_size),
   (n: 'RSA_check_key'; d: @RSA_check_key),
   (n: 'RSA_public_encrypt'; d: @RSA_public_encrypt),
   (n: 'RSA_private_encrypt'; d: @RSA_private_encrypt),
   (n: 'RSA_public_decrypt'; d: @RSA_public_decrypt),
   (n: 'RSA_private_decrypt'; d: @RSA_private_decrypt),
   (n: 'RSA_flags'; d: @RSA_flags),
   (n: 'RSA_set_default_method'; d: @RSA_set_default_method),
   (n: 'RSA_get_default_method'; d: @RSA_get_default_method),
   (n: 'RSA_get_method'; d: @RSA_get_method),
   (n: 'RSA_set_method'; d: @RSA_set_method),
   (n: 'RSA_memory_lock'; d: @RSA_memory_lock),
   (n: 'RSA_PKCS1_SSLeay'; d: @RSA_PKCS1_SSLeay),
   (n: 'ERR_load_RSA_strings'; d: @ERR_load_RSA_strings),
   (n: 'RSA_generate_key'; d: @RSA_generate_key),
   (n:  'd2i_RSAPrivateKey_bio'; d: @d2i_RSAPrivateKey_bio),
   (n:  'i2d_RSAPrivateKey_bio'; d: @i2d_RSAPrivateKey_bio)
  );
begin
 getprocaddresses(info,funcs);
end;

initialization
 regopensslinit(@init);
end.
