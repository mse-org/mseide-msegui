{ MSEgui Copyright (c) 2007-2012 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseopensslevp;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseopenssl,msectypes,mseopenssldes;
const
 EVP_MAX_MD_SIZE = 64; //* longest known is SHA512 */
 EVP_MAX_KEY_LENGTH = 32;
 EVP_MAX_IV_LENGTH = 16;
 EVP_MAX_BLOCK_LENGTH	=	32;

 PKCS5_SALT_LEN = 8;
 PKCS5_DEFAULT_ITER	=	2048; //* Default PKCS#5 iteration count */

//* Values for cipher flags */

//* Modes for ciphers */

	EVP_CIPH_STREAM_CIPHER	=	$0;
	EVP_CIPH_ECB_MODE	=	$1;
	EVP_CIPH_CBC_MODE	=	$2;
	EVP_CIPH_CFB_MODE	=	$3;
	EVP_CIPH_OFB_MODE	=	$4;
	EVP_CIPH_MODE	= $7;
//* Set if variable length cipher */
	EVP_CIPH_VARIABLE_LENGTH =	$8;
//* Set if the iv handling should be done by the cipher itself */
	EVP_CIPH_CUSTOM_IV	=	$10;
//* Set if the cipher's init() function should be called if key is NULL */
	EVP_CIPH_ALWAYS_CALL_INIT	= $20;
//* Call ctrl() to init cipher parameters */
	EVP_CIPH_CTRL_INIT	=	$40;
//* Don't use standard key length function */
	EVP_CIPH_CUSTOM_KEY_LENGTH	= $80;
//* Don't use standard block padding */
	EVP_CIPH_NO_PADDING	=	$100;
//* cipher handles random key generation */
	EVP_CIPH_RAND_KEY	=	$200;

//* ctrl() values */

	EVP_CTRL_INIT	=	$0;
	EVP_CTRL_SET_KEY_LENGTH	=	$1;
	EVP_CTRL_GET_RC2_KEY_BITS	= $2;
	EVP_CTRL_SET_RC2_KEY_BITS	= $3;
	EVP_CTRL_GET_RC5_ROUNDS	=	$4;
	EVP_CTRL_SET_RC5_ROUNDS	=	$5;
	EVP_CTRL_RAND_KEY	=	$6;


type
  MD2_CTX = record
    num: cint;
    data: array [0..15] of byte;
    cksm: array [0..15] of cardinal;
    state: array [0..15] of cardinal;
  end;

  MD4_CTX = record
    A, B, C, D: cardinal;
    Nl, Nh: cardinal;
    data: array [0..15] of cardinal;
    num: cint;
  end;

  MD5_CTX = record
    A, B, C, D: cardinal;
    Nl, Nh: cardinal;
    data: array [0..15] of cardinal;
    num: cint;
  end;

  RIPEMD160_CTX = record
    A, B, C, D, E: cardinal;
    Nl, Nh: cardinal;
    data: array [0..15] of cardinal;
    num: cint;
  end;

  SHA_CTX = record
    h0, h1, h2, h3, h4: cardinal;
    Nl, Nh: cardinal;
    data: array [0..16] of cardinal;
    num: cint;
  end;

  MDC2_CTX = record
    num: cint;
    data: array [0..7] of byte;
    h, hh: des_cblock;
    pad_type: cint; // either 1 or 2, default 1
  end;

  // Superfluo? No, in EVP_MD ci sono le dimensioni del risultato
  pEVP_MD_CTX = ^EVP_MD_CTX;
  EVP_MD_CTX = record
    digest: pEVP_MD;
    case integer of
      0: (base: array [0..3] of byte);
      1: (md2: MD2_CTX);
      8: (md4: MD4_CTX);
      2: (md5: MD5_CTX);
      16: (ripemd160: RIPEMD160_CTX);
      4: (sha: SHA_CTX);
      32: (mdc2: MDC2_CTX);
  end;

  pEVP_PKEY = ^EVP_PKEY;
  EVP_PKEY_PKEY = record
    case integer of
      0: (ptr: pcuchar);
      1: (rsa: pRSA);  // ^rsa_st
      2: (dsa: pDSA);  // ^dsa_st
      3: (dh: pDH);  // ^dh_st
  end;
  ppEVP_PKEY = ^pEVP_PKEY;
  pSTACK_OFX509 = SslPtr; //todo
  EVP_PKEY = record       //for version 1.0
    _type: cint;
    save_type: cint;
    references: cint;
    ameth: SslPtr;
    engine: pENGINE;
    pkey: EVP_PKEY_PKEY;
    save_parameters: cint;
    attributes: pSTACK_OFX509;
  end;

 ASN1_TYPE = record      //todo
 end;
 pASN1_TYPE = ^ASN1_TYPE;
 
 pEVP_CIPHER_CTX = ^EVP_CIPHER_CTX;
 EVP_CIPHER = record
	 nid: cint;
	 block_size: cint;
 	key_len: cint;		//* Default value for variable length ciphers */
	 iv_len: cint;
	 flags: culong;	//* Various flags */
	 init: function(ctx: pEVP_CIPHER_CTX; key: pcuchar; iv: pcuchar;
	                  enc: cint): cint;
//	int (*init)(EVP_CIPHER_CTX *ctx, const unsigned char *key,
//		    const unsigned char *iv, int enc);	/* init key */
  do_cipher: function (ctx: pEVP_CIPHER_CTX; _out: pcuchar; _in: pcuchar;
                   inl: cint): cint; //* encrypt/decrypt data */
//	int (*do_cipher)(EVP_CIPHER_CTX *ctx, unsigned char *out,
//			 const unsigned char *in, unsigned int inl);/* encrypt/decrypt data */
  cleanup: function(ctx: pEVP_CIPHER_CTX): cint; //* cleanup ctx */
//	int (*cleanup)(EVP_CIPHER_CTX *); /* cleanup ctx */
	 ctx_size: cint;		//* how big ctx->cipher_data needs to be */
  set_asn1_parameters: function (ctx: pEVP_CIPHER_CTX; _type: pASN1_TYPE): cint;
                   //* Populate a ASN1_TYPE with parameters */
//	int (*set_asn1_parameters)(EVP_CIPHER_CTX *, ASN1_TYPE *); /* Populate a ASN1_TYPE with parameters */
	 get_asn1_parameters: function(ctx: pEVP_CIPHER_CTX; _type: pASN1_TYPE): cint;
                                  //* Get parameters from a ASN1_TYPE */
//	int (*get_asn1_parameters)(EVP_CIPHER_CTX *, ASN1_TYPE *); /* Get parameters from a ASN1_TYPE */
  ctrl: function(ctx: pEVP_CIPHER_CTX; _type: cint; arg: cint;
                                   ptr: pointer): cint; //* Miscellaneous operations */
//	int (*ctrl)(EVP_CIPHER_CTX *, int type, int arg, void *ptr); /* Miscellaneous operations */
 	app_data: pointer;		//* Application data */
 end;
 pEVP_CIPHER = ^EVP_CIPHER;

  pEVP_MD = ^EVP_MD;
  EVP_MD = record
    _type: cint;
    pkey_type: cint;
    md_size: cint;
    init: pointer;
    update: pointer;
    final: pointer;
    sign: pointer;
    verify: pointer;
    required_pkey_type: array [0..4] of cint;
    block_size: cint;
    ctx_size: cint;
  end;

  pENGINE = SslPtr;
  EVP_CIPHER_CTX = record
  	cipher: pEVP_CIPHER;
  	engine: pENGINE;	//* functional reference if 'cipher' is ENGINE-provided */
  	encrypt: cint;		//* encrypt or decrypt */
  	buf_len: cint;		//* number we have left */
  
  	iov: array[0..EVP_MAX_IV_LENGTH-1] of byte;	   //* original iv */
  	iv: array[0..EVP_MAX_IV_LENGTH-1] of byte;	   //* working iv */
  	buf: array[0..EVP_MAX_BLOCK_LENGTH-1] of byte; //* saved partial block */
  	num: cint;				                       //* used by cfb/ofb mode */
  
  	app_data: pointer;        		//* application stuff */
  	key_len: cint;		            //* May change for variable length cipher */
  	flags: culong;	                //* Various flags */
  	cipher_data: pointer;           //* per EVP data */
  	final_used: cint;
  	block_mask: cint;
  	final: array[0..EVP_MAX_BLOCK_LENGTH-1] of byte; 
	                                //* possible final block */
  end;
//  pEVP_CIPHER_CTX = ^EVP_CIPHER_CTX;
   
var
  EVP_cleanup: procedure; cdecl;
  EVP_CIPHER_CTX_init: procedure(ctx: pEVP_CIPHER_CTX); cdecl;
  EVP_CIPHER_CTX_cleanup: function(ctx: pEVP_CIPHER_CTX): cint; cdecl;
  EVP_CIPHER_CTX_set_padding: function(ctx: pEVP_CIPHER_CTX;
                                                padding: cint): cint; cdecl;
  EVP_CIPHER_CTX_set_key_length: function(ctx: pEVP_CIPHER_CTX;
                                                keylen: cint): cint; cdecl;
  EVP_get_digestbyname: function(Name: pcchar): pEVP_MD; cdecl;
  EVP_get_cipherbyname: function(name: pcchar): pEVP_CIPHER; cdecl;
  
  EVP_CipherInit: function(ctc: pEVP_CIPHER_CTX; cipher: pEVP_CIPHER;
             		       key: pcuchar; iv: pcuchar; enc: cint): cint; cdecl;
 	EVP_CipherInit_ex: function(ctx: pEVP_CIPHER_CTX; cipher: pEVP_CIPHER;
     impl: pENGINE; key: pcuchar; iv: pcuchar; enc: cint): cint; cdecl;
	 EVP_CipherUpdate: function(ctx: pEVP_CIPHER_CTX; _out: pcuchar;
           		        var outl: cint; _in: pcuchar; inl: cint): cint; cdecl;
 	EVP_CipherFinal: function(ctx: pEVP_CIPHER_CTX; outm: pcuchar;
                       	                     var outl: cint): cint; cdecl;
 	EVP_CipherFinal_ex: function(ctx: pEVP_CIPHER_CTX; outm: pcuchar;
                        	                     var outl: cint): cint; cdecl;

  EVP_EncryptInit: function(ctx: pEVP_CIPHER_CTX; _type: pEVP_CIPHER;
                                key: pcuchar; iv: pcuchar): cint; cdecl;
  EVP_EncryptInit_ex: function(ctx: pEVP_CIPHER_CTX; _type: pEVP_CIPHER;
                 impl: pENGINE; key: pcuchar; iv: pcuchar): cint; cdecl;
  EVP_EncryptUpdate: function(ctx: pEVP_CIPHER_CTX;_out: pcuchar;
    		              var outl: cint; _in: pcuchar; inl: cint): cint; cdecl;
  EVP_EncryptFinal: function(ctx: pEVP_CIPHER_CTX; _out: pcuchar;
                                                var outl: cint): cint; cdecl;
  EVP_EncryptFinal_ex: function(ctx: pEVP_CIPHER_CTX; _out: pcuchar;
                                                 var outl: cint): cint; cdecl;
  
  EVP_DecryptInit: function(ctx: pEVP_CIPHER_CTX; cipher: pEVP_CIPHER;
              	                  key: pcuchar; iv: pcuchar): cint; cdecl;
  EVP_DecryptInit_ex: function(ctx: pEVP_CIPHER_CTX; cipher: pEVP_CIPHER;
                 impl: pENGINE; key: pcuchar; iv: pcuchar): cint; cdecl;
  EVP_DecryptUpdate: function(ctx: pEVP_CIPHER_CTX; _out: pcuchar;
                    var outl: cint; _in: pcuchar; inl: cint): cint; cdecl;
  EVP_DecryptFinal: function(ctx: pEVP_CIPHER_CTX; outm: pcuchar;
                                                var outl: cint): cint; cdecl;
  EVP_DecryptFinal_ex: function(ctx: pEVP_CIPHER_CTX; outm: pcuchar;
                                                 var outl: cint): cint; cdecl;

  EVP_DigestInit: function(ctx: pEVP_MD_CTX; const _type: pEVP_MD): cint; cdecl;
  EVP_DigestUpdate: function(ctx: pEVP_MD_CTX; const d: Pointer;
                                              cnt: sslsize_t): cint; cdecl;
  EVP_DigestFinal: function(ctx: pEVP_MD_CTX; md: pcuchar;
                                               var s: cuint): cint; cdecl;
  EVP_SignFinal: function(ctx: pEVP_MD_CTX; sig: pointer;
                               var s: cuint; key: pEVP_PKEY): cint; cdecl;
  EVP_VerifyFinal: function(ctx: pEVP_MD_CTX; sigbuf: pointer;
                          siglen: cuint; pkey: pEVP_PKEY): cint;  cdecl;

  EVP_MD_CTX_copy: function(_out: pEVP_MD_CTX; _in: pEVP_MD_CTX): cint; cdecl;
  EVP_CIPHER_CTX_rand_key: function(ctx: pEVP_CIPHER_CTX;
                                             key: pcuchar): cint; cdecl;

  // Hash functions
  EVP_md_null: function: pEVP_MD; cdecl;
  EVP_md2: function: pEVP_MD; cdecl;  //optional!
  EVP_md5: function: pEVP_MD; cdecl;
  EVP_sha: function: pEVP_MD; cdecl;
  EVP_sha1: function: pEVP_MD; cdecl;
  EVP_dss: function: pEVP_MD; cdecl;
  EVP_dss1: function: pEVP_MD; cdecl;
  EVP_mdc2: function: pEVP_MD; cdecl;
  EVP_ripemd160: function: pEVP_MD; cdecl;
  // Crypt functions
  EVP_enc_null: function: pEVP_CIPHER; cdecl;
  EVP_des_ecb: function: pEVP_CIPHER; cdecl;
  EVP_des_ede: function: pEVP_CIPHER; cdecl;
  EVP_des_ede3: function: pEVP_CIPHER; cdecl;
  EVP_des_cfb: function: pEVP_CIPHER; cdecl;
  EVP_des_ede_cfb: function: pEVP_CIPHER; cdecl;
  EVP_des_ede3_cfb: function: pEVP_CIPHER; cdecl;
  EVP_des_ofb: function: pEVP_CIPHER; cdecl;
  EVP_des_ede_ofb: function: pEVP_CIPHER; cdecl;
  EVP_des_ede3_ofb: function: pEVP_CIPHER; cdecl;
  EVP_des_cbc: function: pEVP_CIPHER; cdecl;
  EVP_des_ede_cbc: function: pEVP_CIPHER; cdecl;
  EVP_des_ede3_cbc: function: pEVP_CIPHER; cdecl;
  EVP_desx_cbc: function: pEVP_CIPHER; cdecl;
  EVP_idea_cbc: function: pEVP_CIPHER; cdecl;
  EVP_idea_cfb: function: pEVP_CIPHER; cdecl;
  EVP_idea_ecb: function: pEVP_CIPHER; cdecl;
  EVP_idea_ofb: function: pEVP_CIPHER; cdecl;

  // EVP Key functions
  EVP_PKEY_New: function(): pEVP_PKEY; cdecl;
  EVP_PKEY_Free: procedure(pk: pEVP_PKEY); cdecl;
  EVP_PKEY_Assign: function(pkey: pEVP_PKEY; _type: cint;
                          key: pRSA): cint; cdecl;
  EVP_PKEY_type: function(keytype: cint): cint; cdecl;
  EVP_PKEY_assign_RSA: function(key: pEVP_PKEY; rsa: pRSA): cint; cdecl;
  EVP_PKEY_assign_DSA: function(key: pEVP_PKEY; dsa: pDSA): cint; cdecl;
  EVP_PKEY_assign_DH: function(key: pEVP_PKEY; dh: pDH): cint; cdecl;
  EVP_PKEY_assign_EC_KEY: function(key: pEVP_PKEY; ec: pEC_KEY): cint; cdecl;
  EVP_PKEY_set1_RSA: function(key: pEVP_PKEY; rsa: pRSA): cint; cdecl;
  EVP_PKEY_set1_DSA: function(key: pEVP_PKEY; dsa: pDSA): cint; cdecl;
  EVP_PKEY_set1_DH: function(key: pEVP_PKEY; dh: pDH): cint; cdecl;
  EVP_PKEY_set1_EC_KEY: function(key: pEVP_PKEY; ec: pEC_KEY): cint; cdecl;
  EVP_PKEY_size: function(key: pEVP_PKEY): cint; cdecl;
  EVP_PKEY_get1_RSA: function(key: pEVP_PKEY): pRSA; cdecl;
  EVP_PKEY_get1_DSA: function(key: pEVP_PKEY): pDSA; cdecl;
  EVP_PKEY_get1_DH: function(key: pEVP_PKEY): pDH; cdecl;
  EVP_PKEY_get1_EC_KEY: function(key: pEVP_PKEY): pEC_KEY; cdecl;
  // Password prompt for callback function
  EVP_set_pw_prompt: procedure(prompt: pcchar);cdecl;
  EVP_get_pw_prompt: function: pcchar;cdecl;
  // Default callback password function: replace if you want
  EVP_read_pw_string: function(buf: pcchar; len: cint;
                      const prompt: pcchar; verify: cint): cint; cdecl;
  EVP_read_pw_string_min: function(buf: pcchar; minlen: cint; maxlen: cint;
              prompt: pcchar; verify: cint): cint; cdecl; //openssl 1.0+
  d2i_PrivateKey_bio: function(bp: pBIO; var a: pEVP_PKEY): pEVP_PKEY; cdecl;
  d2i_PUBKEY_bio: function(bp: pBIO; var a: pEVP_PKEY): pEVP_PKEY; cdecl;
  i2d_PUBKEY_bio: function(bp: pBIO; pkey: pEVP_PKEY): cint; cdecl;

  EVP_MD_type: function(const md: pEVP_MD): cint; cdecl;
  EVP_MD_pkey_type: function(const md: pEVP_MD): cint; cdecl;	
  EVP_MD_block_size: function(const md: pEVP_MD): cint; cdecl;
  EVP_MD_flags: function(const md: pEVP_MD): cardinal; cdecl; //openssl 1.0 +
  EVP_MD_CTX_md: function(const ctx: pEVP_MD_CTX): pEVP_MD;cdecl;

  EVP_MD_CTX_init: procedure(ctx: pEVP_MD_CTX);cdecl;
  EVP_MD_CTX_cleanup: function(ctx: pEVP_MD_CTX): cint;cdecl;
  EVP_MD_CTX_create: function: pEVP_MD_CTX;cdecl;
  EVP_MD_CTX_destroy: procedure(ctx: pEVP_MD_CTX);cdecl;

  EVP_BytesToKey: function(const _type: pEVP_CIPHER; const md: pEVP_MD;
             		salt: pcuchar; const data: pcuchar; datalen: cint;
            		 count: cint; key: pcuchar; iv: pcuchar): cint; cdecl;
  EVP_SealInit: function(ctx: pEVP_CIPHER_CTX; _type: pEVP_CIPHER;
                           ek: ppcuchar; ekl: pcint; iv: pcuchar;
                              pubkey: ppEVP_PKEY; npubk: cint): cint; cdecl;
  EVP_SealFinal: function(ctx: pEVP_CIPHER_CTX; _out: pcuchar;
                                           var outl: cint): cint; cdecl;
  EVP_OpenInit: function(ctx: pEVP_CIPHER_CTX;_type: pEVP_CIPHER;
                 ek: pcuchar; ekl: cint; iv: pcuchar;
                                            priv: pEVP_PKEY): cint; cdecl;
  EVP_OpenFinal: function(ctx: pEVP_CIPHER_CTX; _out: pcuchar;
                                              var outl: cint): cint; cdecl;

function EVP_SealUpdate(ctx: pEVP_CIPHER_CTX; _out: pcuchar;
                            var outl: cint; _in: pcuchar; inl: cint): cint;
function EVP_OpenUpdate(ctx: pEVP_CIPHER_CTX; _out: pcuchar;
                 var outl: cint; _in: pcuchar; inl: cint): cint;
function EVP_SignInit(ctx: pEVP_MD_CTX; const _type: pEVP_MD): cint;
function EVP_SignUpdate(ctx: pEVP_MD_CTX; const d: Pointer; cnt: cuint): cint;
function EVP_VerifyInit(ctx: pEVP_MD_CTX; const _type: pEVP_MD): cint;
function EVP_VerifyUpdate(ctx: pEVP_MD_CTX; const d: Pointer; cnt: cuint): cint;
function EVP_MD_size(e: pEVP_MD): cint;
function EVP_MD_CTX_size(e: pEVP_MD_CTX): cint;

function encryptsymkeyrsa(ek: pcuchar; key: pcuchar; key_len: integer;
                           	                     pubk: pEVP_PKEY): integer;
                //like EVP_PKEY_encrypt_old(), -2 if no rsa key, -1 on error
function decryptsymkeyrsa(key: pcuchar; ek: pcuchar; ekl: integer;
                           	                     priv: pEVP_PKEY): integer;
                //like EVP_PKEY_decrypt_old(), -2 if no rsa key, -1 on error

implementation
uses
 msedynload,mseopensslrsa;
 
function encryptsymkeyrsa(ek: pcuchar; key: pcuchar; key_len: cint;
                           	                     pubk: pEVP_PKEY): cint;
begin
 result:= -2;
 if pubk^._type = EVP_PKEY_RSA then begin
  result:= RSA_public_encrypt(key_len,key,ek,EVP_PKEY_get1_RSA(pubk),
                               RSA_PKCS1_OAEP_PADDING{RSA_PKCS1_PADDING});
 end;
end;

function decryptsymkeyrsa(key: pcuchar; ek: pcuchar; ekl: integer;
                           	                     priv: pEVP_PKEY): integer;
begin
 result:= -2;
 if priv^._type = EVP_PKEY_RSA then begin
  result:= RSA_private_decrypt(ekl,ek,key,EVP_PKEY_get1_RSA(priv),
                      RSA_PKCS1_OAEP_PADDING{RSA_PKCS1_PADDING});
 end;
end;

function EVP_SealUpdate(ctx: pEVP_CIPHER_CTX; _out: pcuchar;
                            var outl: cint; _in: pcuchar; inl: cint): cint;
begin
 result:= evp_encryptupdate(ctx,_out,outl,_in,inl);
end;
 
function EVP_OpenUpdate(ctx: pEVP_CIPHER_CTX; _out: pcuchar;
                 var outl: cint; _in: pcuchar; inl: cint): cint;
begin
 result:= evp_decryptupdate(ctx,_out,outl,_in,inl);
end;

function EVP_SignInit(ctx: pEVP_MD_CTX; const _type: pEVP_MD): cint;
begin
 result:= EVP_DigestInit(ctx, _type);
end;

function EVP_SignUpdate(ctx: pEVP_MD_CTX; const d: Pointer; cnt: cardinal): cint;
begin
 result:= EVP_DigestUpdate(ctx, d, cnt);
end;

function EVP_VerifyInit(ctx: pEVP_MD_CTX; const _type: pEVP_MD): cint;
begin
 result:= EVP_DigestInit(ctx, _type);
end;

function EVP_VerifyUpdate(ctx: pEVP_MD_CTX; const d: Pointer; cnt: cardinal): cint;
begin
 result:= EVP_DigestUpdate(ctx, d, cnt);
end;

function EVP_MD_size(e: pEVP_MD): cint;
begin
  result := e^.md_size;
end;

function EVP_MD_CTX_size(e: pEVP_MD_CTX): cint;
begin
  result := EVP_MD_size(e^.digest);
end;

procedure init(const info: dynlibinfoty);
const
 funcs: array[0..81] of funcinfoty = (
   (n: 'EVP_PKEY_new'; d: @EVP_PKEY_new),
   (n: 'EVP_PKEY_free'; d: @EVP_PKEY_free),
   (n: 'EVP_PKEY_assign'; d: @EVP_PKEY_assign),
   (n: 'EVP_CIPHER_CTX_init'; d: @EVP_CIPHER_CTX_init),
   (n: 'EVP_CIPHER_CTX_cleanup'; d: @EVP_CIPHER_CTX_cleanup),
   (n: 'EVP_CIPHER_CTX_set_padding'; d: @EVP_CIPHER_CTX_set_padding),
   (n: 'EVP_CIPHER_CTX_set_key_length'; d: @EVP_CIPHER_CTX_set_key_length),
   (n: 'EVP_cleanup'; d: @EVP_cleanup),
   (n: 'EVP_get_digestbyname'; d: @EVP_get_digestbyname),
   (n: 'EVP_md_null'; d: @EVP_md_null),
   (n: 'EVP_md5'; d: @EVP_md5),
   (n: 'EVP_sha'; d: @EVP_sha),
   (n: 'EVP_sha1'; d: @EVP_sha1),
   (n: 'EVP_dss'; d: @EVP_dss),
   (n: 'EVP_dss1'; d: @EVP_dss1),
   (n: 'EVP_ripemd160'; d: @EVP_ripemd160),
   (n: 'EVP_CipherInit'; d: @EVP_CipherInit),
   (n: 'EVP_CipherInit_ex'; d: @EVP_CipherInit_ex),
   (n: 'EVP_CipherUpdate'; d: @EVP_CipherUpdate),
   (n: 'EVP_CipherFinal'; d: @EVP_CipherFinal),
   (n: 'EVP_CipherFinal_ex'; d: @EVP_CipherFinal_ex),
   (n: 'EVP_EncryptInit'; d: @EVP_EncryptInit),
   (n: 'EVP_EncryptInit_ex'; d: @EVP_EncryptInit_ex),
   (n: 'EVP_EncryptUpdate'; d: @EVP_EncryptUpdate),
   (n: 'EVP_EncryptFinal'; d: @EVP_EncryptFinal),
   (n: 'EVP_EncryptFinal_ex'; d: @EVP_EncryptFinal_ex),
   (n: 'EVP_DecryptInit'; d: @EVP_DecryptInit),
   (n: 'EVP_DecryptInit_ex'; d: @EVP_DecryptInit_ex),
   (n: 'EVP_DecryptUpdate'; d: @EVP_DecryptUpdate),
   (n: 'EVP_DecryptFinal'; d: @EVP_DecryptFinal),
   (n: 'EVP_DecryptFinal_ex'; d: @EVP_DecryptFinal_ex),
   (n: 'EVP_DigestInit'; d: @EVP_DigestInit),
   (n: 'EVP_DigestUpdate'; d: @EVP_DigestUpdate),
   (n: 'EVP_DigestFinal'; d: @EVP_DigestFinal),
   (n: 'EVP_SignFinal'; d: @EVP_SignFinal),
   (n: 'EVP_VerifyFinal'; d: @EVP_VerifyFinal),
   (n: 'EVP_MD_CTX_copy'; d: @EVP_MD_CTX_copy),
   (n: 'EVP_enc_null'; d: @EVP_enc_null),
   (n: 'EVP_des_ecb'; d: @EVP_des_ecb),
   (n: 'EVP_des_ede'; d: @EVP_des_ede),
   (n: 'EVP_des_ede3'; d: @EVP_des_ede3),
   (n: 'EVP_des_cfb'; d: @EVP_des_cfb),
   (n: 'EVP_des_ede_cfb'; d: @EVP_des_ede_cfb),
   (n: 'EVP_des_ede3_cfb'; d: @EVP_des_ede3_cfb),
   (n: 'EVP_des_ofb'; d: @EVP_des_ofb),
   (n: 'EVP_des_ede_ofb'; d: @EVP_des_ede_ofb),
   (n: 'EVP_des_ede3_ofb'; d: @EVP_des_ede3_ofb),
   (n: 'EVP_des_cbc'; d: @EVP_des_cbc),
   (n: 'EVP_des_ede_cbc'; d: @EVP_des_ede_cbc),
   (n: 'EVP_des_ede3_cbc'; d: @EVP_des_ede3_cbc),
   (n: 'EVP_desx_cbc'; d: @EVP_desx_cbc),
   (n: 'EVP_get_cipherbyname'; d: @EVP_get_cipherbyname),
   (n: 'EVP_PKEY_type'; d: @EVP_PKEY_type),
   (n: 'EVP_PKEY_set1_RSA'; d: @EVP_PKEY_set1_RSA),
   (n: 'EVP_PKEY_set1_DSA'; d: @EVP_PKEY_set1_DSA),
   (n: 'EVP_PKEY_set1_DH'; d: @EVP_PKEY_set1_DH),
   (n: 'EVP_PKEY_set1_EC_KEY'; d: @EVP_PKEY_set1_EC_KEY),
   (n: 'EVP_PKEY_size'; d: @EVP_PKEY_size),
   (n: 'EVP_PKEY_get1_RSA'; d: @EVP_PKEY_get1_RSA),
   (n: 'EVP_PKEY_get1_DSA'; d: @EVP_PKEY_get1_DSA),
   (n: 'EVP_PKEY_get1_DH'; d: @EVP_PKEY_get1_DH),
   (n: 'EVP_PKEY_get1_EC_KEY'; d: @EVP_PKEY_get1_EC_KEY),
   (n: 'EVP_set_pw_prompt'; d: @EVP_set_pw_prompt),
   (n: 'EVP_get_pw_prompt'; d: @EVP_get_pw_prompt),
   (n: 'EVP_read_pw_string'; d: @EVP_read_pw_string),
   (n: 'd2i_PrivateKey_bio'; d: @d2i_PrivateKey_bio),
   (n: 'd2i_PUBKEY_bio'; d: @d2i_PUBKEY_bio),
   (n: 'i2d_PUBKEY_bio'; d: @i2d_PUBKEY_bio),
   (n: 'EVP_MD_type'; d: @EVP_MD_type),
   (n: 'EVP_MD_pkey_type'; d: @EVP_MD_pkey_type),
   (n: 'EVP_MD_block_size'; d: @EVP_MD_block_size),
   (n: 'EVP_MD_CTX_md'; d: @EVP_MD_CTX_md),
   (n: 'EVP_MD_CTX_init'; d: @EVP_MD_CTX_init),
   (n: 'EVP_MD_CTX_cleanup'; d: @EVP_MD_CTX_cleanup),
   (n: 'EVP_MD_CTX_create'; d: @EVP_MD_CTX_create),
   (n: 'EVP_MD_CTX_destroy'; d: @EVP_MD_CTX_destroy),
   (n: 'EVP_BytesToKey'; d: @EVP_BytesToKey),
   (n: 'EVP_SealInit'; d: @EVP_SealInit),
//   (n: 'EVP_SealUpdate'; d: @EVP_SealUpdate), //macro
   (n: 'EVP_SealFinal'; d: @EVP_SealFinal),
   (n: 'EVP_OpenInit'; d: @EVP_OpenInit),
   (n: 'EVP_OpenFinal'; d: @EVP_OpenFinal),
   (n: 'EVP_CIPHER_CTX_rand_key'; d: @EVP_CIPHER_CTX_rand_key)
//   (n: 'EVP_PKEY_encrypt_old'; d: @EVP_PKEY_encrypt_old) //version dependent
  );
 funcsopt: array[0..10] of funcinfoty = (
   (n: 'EVP_MD_flags'; d: @EVP_MD_flags),
   (n: 'EVP_read_pw_string_min'; d: @EVP_read_pw_string_min),
   (n: 'EVP_md2'; d: @EVP_md2),
   (n: 'EVP_mdc2'; d: @EVP_mdc2),
   (n: 'EVP_idea_cbc'; d: @EVP_idea_cbc),
   (n: 'EVP_idea_ecb'; d: @EVP_idea_ecb),
   (n: 'EVP_idea_ofb'; d: @EVP_idea_ofb),
   (n: 'EVP_PKEY_assign_RSA'; d: @EVP_PKEY_assign_RSA), //todo: macros
   (n: 'EVP_PKEY_assign_DSA'; d: @EVP_PKEY_assign_DSA),
   (n: 'EVP_PKEY_assign_DH'; d: @EVP_PKEY_assign_DH),
   (n: 'EVP_PKEY_assign_EC_KEY'; d: @EVP_PKEY_assign_EC_KEY)
  );

begin
 getprocaddresses(info,funcs);
 getprocaddresses(info,funcsopt,true);
end;
  
procedure deinit(const info: dynlibinfoty);
begin
 evp_cleanup;
end;

initialization
 regopensslinit(@init);
 regopenssldeinit(@deinit);
end.
