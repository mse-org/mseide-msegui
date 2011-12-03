{ MSEgui Copyright (c) 2007 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mopenssl;

{$MODE OBJFPC}{$H+}

interface

uses
 msesonames;
(*
const
 {$IFDEF mswindows}
 sslnames: array[0..1] of string = ('ssleay32.dll','libssl32.dll');
 sslutilnames: array[0..0] of string = ('libeay32.dll');
 {$ELSE}
 sslnames: array[0..0] of string = ('libssl.so');
 sslutilnames: array[0..0] of string = ('libcrypto.so');  
 {$ENDIF} moved to msesonames
*)

{$IFDEF OPENSSL_EXT}
const
  SHA_DIGEST_LENGTH = 20;
  BN_CTX_NUM = 16;
  BN_CTX_NUM_POS = 12;

{$IFDEF OPENSSL_BIO}
  // These are the 'types' of BIOs
  BIO_TYPE_NONE = $0000;
  BIO_TYPE_MEM = $0001 or $0400;
  BIO_TYPE_FILE = $0002 or $0400;

  BIO_TYPE_FD = $0004 or $0400 or $0100;
  BIO_TYPE_SOCKET = $0005 or $0400 or $0100;
  BIO_TYPE_NULL = $0006 or $0400;
  BIO_TYPE_SSL = $0007 or $0200;
  BIO_TYPE_MD = $0008 or $0200;  // passive filter
  BIO_TYPE_BUFFER = $0009 or $0200;  // filter
  BIO_TYPE_CIPHER = $00010 or $0200;  // filter
  BIO_TYPE_BASE64 = $00011 or $0200;  // filter
  BIO_TYPE_CONNECT = $00012 or $0400 or $0100;  // socket - connect
  BIO_TYPE_ACCEPT = $00013 or $0400 or $0100;  // socket for accept
  BIO_TYPE_PROXY_CLIENT = $00014 or $0200;  // client proxy BIO
  BIO_TYPE_PROXY_SERVER = $00015 or $0200;  // server proxy BIO
  BIO_TYPE_NBIO_TEST = $00016 or $0200;  // server proxy BIO
  BIO_TYPE_NULL_FILTER = $00017 or $0200;
  BIO_TYPE_BER = $00018 or $0200;  // BER -> bin filter
  BIO_TYPE_BIO = $00019 or $0400;  // (half a; BIO pair
  BIO_TYPE_LINEBUFFER = $00020 or $0200;  // filter

  BIO_TYPE_DESCRIPTOR = $0100;  // socket, fd, connect or accept
  BIO_TYPE_FILTER= $0200;
  BIO_TYPE_SOURCE_SINK = $0400;

  // BIO ops constants
  // BIO_FILENAME_READ|BIO_CLOSE to open or close on free.
  // BIO_set_fp(in,stdin,BIO_NOCLOSE);
  BIO_NOCLOSE = $00;
  BIO_CLOSE = $01;
  BIO_FP_READ = $02;
  BIO_FP_WRITE = $04;
  BIO_FP_APPEND = $08;
  BIO_FP_TEXT = $10;

  BIO_C_SET_FILENAME = 108;
  BIO_CTRL_RESET = 1;  // opt - rewind/zero etc
  BIO_CTRL_EOF = 2;  // opt - are we at the eof
  BIO_CTRL_INFO = 3;  // opt - extra tit-bits
  BIO_CTRL_SET = 4;  // man - set the 'IO' type
  BIO_CTRL_GET = 5;  // man - get the 'IO' type
  BIO_CTRL_PUSH = 6;  // opt - internal, used to signify change
  BIO_CTRL_POP = 7;  // opt - internal, used to signify change
  BIO_CTRL_GET_CLOSE = 8;  // man - set the 'close' on free
  BIO_CTRL_SET_CLOSE = 9;  // man - set the 'close' on free
  BIO_CTRL_PENDING_C = 10;  // opt - is their more data buffered
  BIO_CTRL_FLUSH = 11;  // opt - 'flush' buffered output
  BIO_CTRL_DUP = 12;  // man - extra stuff for 'duped' BIO
  BIO_CTRL_WPENDING = 13;  // opt - number of bytes still to write

  BIO_C_GET_MD_CTX = 120;
{$ENDIF OPENSSL_BIO}

{$ENDIF OPENSSL_EXT}

type
  SslPtr = Pointer;
  PSslPtr = ^SslPtr;
  PSSL_CTX = SslPtr;
  PSSL = SslPtr;
  PSSL_METHOD = SslPtr;
{$IFNDEF OPENSSL_EXT}
  PX509 = SslPtr;
  PX509_NAME = SslPtr;
  PEVP_MD	= SslPtr;
{$ENDIF OPENSSL_EXT}
  PInteger = ^Integer;
  PBIO_METHOD = SslPtr;
  PBIO = SslPtr;
{$IFNDEF OPENSSL_EXT}
  EVP_PKEY = SslPtr;
{$ENDIF OPENSSL_EXT}  
  PRSA = SslPtr;
  PASN1_UTCTIME = SslPtr;
  PASN1_INTEGER = SslPtr;
  PPasswdCb = SslPtr;
  PFunction = procedure;
  PCharacter = PChar;

  DES_cblock = array[0..7] of Byte;
  PDES_cblock = ^DES_cblock;
  des_ks_struct = packed record
    ks: DES_cblock;
    weak_key: Integer;
  end;
  des_key_schedule = array[1..16] of des_ks_struct;

{$IFDEF OPENSSL_EXT}
// ASN1 types
  pASN1_OBJECT = pointer;
  pASN1_STRING = ^ASN1_STRING;
  ASN1_STRING = record
	length: integer;
	asn1_type: integer;
	data: pointer;
	flags: longint;
	end;
  pASN1_IA5STRING = pASN1_STRING;
  pASN1_ENUMERATED = pASN1_STRING;
  pASN1_TIME = pASN1_STRING;
  pASN1_OCTET_STRING = pASN1_STRING;

  pX509_NAME_ENTRY = ^X509_NAME_ENTRY;
  X509_NAME_ENTRY = record
    obj: pASN1_OBJECT;
    value: pASN1_STRING;
	_set: integer;
	size: integer; // temp variable
    end;

  pX509_NAME = ^X509_NAME;
  pDN = ^X509_NAME;
  X509_NAME = record
    entries: pointer;
    modified: integer;
    bytes: pointer;
    hash: cardinal;
  end;

  pX509_VAL = ^X509_VAL;
  X509_VAL = record
	notBefore: pASN1_TIME;
    notAfter: pASN1_TIME;
  end;

  pX509_CINF = ^X509_CINF;
  X509_CINF = record
    version: pointer;
    serialNumber: pointer;
    signature: pointer;
    issuer: pointer;
    validity: pX509_VAL;
    subject: pointer;
    key: pointer;
    issuerUID: pointer;
    subjectUID: pointer;
    extensions: pointer;
  end;

  CRYPTO_EX_DATA = record
    sk: pointer;
    dummy: integer;
  end;


  pX509 = ^X509;
  X509 = record
    cert_info: pX509_CINF;
    sig_alg: pointer;  // ^X509_ALGOR
    signature: pointer;  // ^ASN1_BIT_STRING
    valid: integer;
    references: integer;
    name: PCharacter;
    ex_data: CRYPTO_EX_DATA;
    ex_pathlen: integer;
    ex_flags: integer;
    ex_kusage: integer;
    ex_xkusage: integer;
    ex_nscert: integer;
    skid: pASN1_OCTET_STRING;
    akid: pointer;  // ?
    sha1_hash: array [0..SHA_DIGEST_LENGTH-1] of char;
    aux: pointer;  // ^X509_CERT_AUX
  end;

  pX509V3_CTX = pointer;
  
  pX509_REQ = ^X509_REQ;
  pX509_REQ_INFO = ^X509_REQ_INFO;
  X509_REQ_INFO = record
	asn1: pointer;
	length: integer;
	version: pointer;
	subject: pX509_NAME;
	pubkey: pointer;
	attributes: pointer;
	req_kludge: integer;
  end;
  X509_REQ = record
	req_info: pX509_REQ_INFO;
	sig_alg: pointer;
	signature: pointer;
	references: integer;
  end;

  pX509_EXTENSION = ^X509_EXTENSION;
  X509_EXTENSION = record
    obj: pASN1_OBJECT;
	critical: Smallint;
	netscape_hack: Smallint;
	value: pASN1_OCTET_STRING;
	method: pointer;	// struct v3_ext_method *: V3 method to use
	ext_val: pointer;	// extension value
  end;
  pSTACK_OFX509_EXTENSION = pointer;

  pX509_CRL = pointer;
  
  pX509_SIG = ^X509_SIG;
  X509_SIG = record
     algor: Pointer; // X509_ALGOR *algor;
     digest: pASN1_OCTET_STRING;
  end;

  pX509_STORE_CTX = pointer;
  // Certificate verification callback
  TCertificateVerifyFunction = function(ok: integer; ctx: pX509_STORE_CTX): integer; cdecl;
  
  pSTACK_OFX509 = pointer;
  pX509_STORE = ^X509_STORE;
  pX509_LOOKUP = pointer;
  pSTACK_OF509LOOKUP = pointer;
  pX509_LOOKUP_METHOD = pointer;
  X509_STORE = record
    cache: integer;
    objs: pSTACK_OFX509;
    get_cert_methods: pSTACK_OF509LOOKUP;
    verify: pointer;  // function called to verify a certificate
    verify_cb: TCertificateVerifyFunction;
    ex_data: pointer;
    references: integer;
    depth: integer;
  end;

  pDSA = ^DSA;
  DSA = record
	// This first variable is used to pick up errors where
	// a DSA is passed instead of of a EVP_PKEY
	pad: integer;
	version: integer;
	write_params: integer;
	p: pointer;
	q: pointer;	// = 20
	g: pointer;
	pub_key: pointer;  // y public key
	priv_key: pointer; // x private key
	kinv: pointer;	// Signing pre-calc
	r: pointer;	// Signing pre-calc
	flags: integer;
	// Normally used to cache montgomery values
	method_mont_p: PCharacter;
	references: integer;
	ex_data: record
      sk: pointer;
      dummy: integer;
      end;
	meth: pointer;
  end;

  pDH = pointer;

  pEVP_PKEY = ^EVP_PKEY;
  EVP_PKEY_PKEY = record
    case integer of
      0: (ptr: PCharacter);
      1: (rsa: pRSA);  // ^rsa_st
      2: (dsa: pDSA);  // ^dsa_st
      3: (dh: pDH);  // ^dh_st
  end;
  EVP_PKEY = record
    ktype: integer;
    save_type: integer;
    references: integer;
    pkey: EVP_PKEY_PKEY;
    save_parameters: integer;
    attributes: pSTACK_OFX509;
  end;

  pSTACK_OFPKCS7_SIGNER_INFO = pointer;
  
  pPKCS7_signed = ^PKCS7_signed;
  PKCS7_signed = record
    version: pASN1_INTEGER;
    md_algs: pointer;  // ^STACK_OF(X509_ALGOR)
    cert: pointer;  // ^STACK_OF(X509)
    crl: pointer;  // ^STACK_OF(X509_CRL)
    signer_info: pSTACK_OFPKCS7_SIGNER_INFO;
    contents: pointer;  // ^struct pkcs7_st
  end;

  pPKCS7_signedandenveloped = ^PKCS7_signedandenveloped;
  PKCS7_signedandenveloped = record
    version: pASN1_INTEGER;
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
    length: integer;
    state: integer;
    detached: integer;
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
    broken: Integer; // Flag for various broken formats */
    version: pASN1_INTEGER;
    pkeyalg: Pointer; // X509_ALGOR *pkeyalg;
    pkey: Pointer; // ASN1_TYPE *pkey; /* Should be OCTET STRING but some are broken */
    attributes: Pointer; // STACK_OF(X509_ATTRIBUTE) *attributes;
  end;

  pBN_ULONG = ^BN_ULONG;
  BN_ULONG = array of byte; // system dependent, consider it as a opaque pointer

  pBIGNUM = ^BIGNUM;
  BIGNUM = record
	d: pBN_ULONG;	// Pointer to an array of 'BN_BITS2' bit chunks.
	top: integer;	// Index of last used d +1.
                        // The next are internal book keeping for bn_expand.
	dmax: integer;	// Size of the d array.
	neg: integer;	// one if the number is negative
	flags: integer;
  end;
  
  pBN_CTX = ^BN_CTX;
  BN_CTX = record
	tos: integer;
	bn: array [0..BN_CTX_NUM-1] of BIGNUM;
	flags: integer;
	depth: integer;
	pos: array [0..BN_CTX_NUM_POS-1] of integer;
	too_many: integer;
  end;

  pBN_BLINDING = ^BN_BLINDING;
  BN_BLINDING = record
	init: integer;
	A: pBIGNUM;
	Ai: pBIGNUM;
	_mod: pBIGNUM;  // just a reference (original name: mod)
  end;

  // Used for montgomery multiplication
  pBN_MONT_CTX = ^BN_MONT_CTX;
  BN_MONT_CTX = record
	ri: integer;    // number of bits in R
	RR: BIGNUM;     // used to convert to montgomery form
	N: BIGNUM;      // The modulus
	Ni: BIGNUM;     // R*(1/R mod N) - N*Ni = 1
	                // (Ni is only stored for bignum algorithm)
	n0: BN_ULONG;   // least significant word of Ni
	flags: integer;
  end;

  // Used for reciprocal division/mod functions
  // It cannot be shared between threads
  pBN_RECP_CTX = ^BN_RECP_CTX;
  BN_RECP_CTX = record
	N: BIGNUM;	// the divisor
	Nr: BIGNUM;	// the reciprocal
	num_bits: integer;
	shift: integer;
	flags: integer;
  end;

  TProgressCallbackFunction = procedure(status: integer; progress: integer; data: pointer); 

  pBUF_MEM = pointer;

  pEVP_CIPHER = pointer;

  pEVP_MD = ^EVP_MD;
  EVP_MD = record
    _type: integer;
    pkey_type: integer;
    md_size: integer;
    init: pointer;
    update: pointer;
    final: pointer;
    sign: pointer;
    verify: pointer;
    required_pkey_type: array [0..4] of integer;
    block_size: integer;
    ctx_size: integer;
  end;

  MD2_CTX = record
    num: integer;
    data: array [0..15] of byte;
    cksm: array [0..15] of cardinal;
    state: array [0..15] of cardinal;
  end;

  MD4_CTX = record
    A, B, C, D: cardinal;
    Nl, Nh: cardinal;
    data: array [0..15] of cardinal;
    num: integer;
  end;

  MD5_CTX = record
    A, B, C, D: cardinal;
    Nl, Nh: cardinal;
    data: array [0..15] of cardinal;
    num: integer;
  end;

  RIPEMD160_CTX = record
    A, B, C, D, E: cardinal;
    Nl, Nh: cardinal;
    data: array [0..15] of cardinal;
    num: integer;
  end;

  SHA_CTX = record
    h0, h1, h2, h3, h4: cardinal;
    Nl, Nh: cardinal;
    data: array [0..16] of cardinal;
    num: integer;
  end;

  MDC2_CTX = record
    num: integer;
    data: array [0..7] of byte;
    h, hh: des_cblock;
    pad_type: integer; // either 1 or 2, default 1
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

  pEC_KEY = pointer;

  pRSA_METHOD = pointer;
  RSA = record
	// The first parameter is used to pickup errors where
	// this is passed instead of aEVP_PKEY, it is set to 0
	pad: integer;
	version: integer;
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
	references: integer;
	flags: integer;
	// Used to cache montgomery values
	_method_mod_n: pBN_MONT_CTX;
	_method_mod_p: pBN_MONT_CTX;
	_method_mod_q: pBN_MONT_CTX;
        // all BIGNUM values are actually in the following data, if it is not
	// NULL
	bignum_data: ^byte;
	blinding: ^BN_BLINDING;
  end;

  pSTACK = pointer;

  // Password ask callback for I/O function prototipe
  // It must fill buffer with password and return password length
  TPWCallbackFunction = function(buffer: PCharacter; length: integer; verify: integer; data: pointer): integer; cdecl;

  pPKCS7_SIGNER_INFO = pointer;
  pAES_KEY = pointer;

{$ENDIF OPENSSL_EXT}

const

 SSL_CTRL_OPTIONS = 32; // ssl/ssl.h
 CRYPTO_LOCK = 1;       // ssl/crypto.h
 CRYPTO_UNLOCK = 2;
 CRYPTO_READ = 4;
 CRYPTO_WRITE = 8;

  EVP_MAX_MD_SIZE = 16 + 20;

  SSL_ERROR_NONE = 0;
  SSL_ERROR_SSL = 1;
  SSL_ERROR_WANT_READ = 2;
  SSL_ERROR_WANT_WRITE = 3;
  SSL_ERROR_WANT_X509_LOOKUP = 4;
  SSL_ERROR_SYSCALL = 5; //look at error stack/return value/errno
  SSL_ERROR_ZERO_RETURN = 6;
  SSL_ERROR_WANT_CONNECT = 7;
  SSL_ERROR_WANT_ACCEPT = 8;

  SSL_OP_NO_SSLv2 = $01000000;
  SSL_OP_NO_SSLv3 = $02000000;
  SSL_OP_NO_TLSv1 = $04000000;
  SSL_OP_ALL = $000FFFFF;
  SSL_VERIFY_NONE = $00;
  SSL_VERIFY_PEER = $01;

  OPENSSL_DES_DECRYPT = 0;
  OPENSSL_DES_ENCRYPT = 1;

  X509_V_OK =	0;
  X509_V_ILLEGAL = 1;
  X509_V_ERR_UNABLE_TO_GET_ISSUER_CERT = 2;
  X509_V_ERR_UNABLE_TO_GET_CRL = 3;
  X509_V_ERR_UNABLE_TO_DECRYPT_CERT_SIGNATURE = 4;
  X509_V_ERR_UNABLE_TO_DECRYPT_CRL_SIGNATURE = 5;
  X509_V_ERR_UNABLE_TO_DECODE_ISSUER_PUBLIC_KEY = 6;
  X509_V_ERR_CERT_SIGNATURE_FAILURE = 7;
  X509_V_ERR_CRL_SIGNATURE_FAILURE = 8;
  X509_V_ERR_CERT_NOT_YET_VALID = 9;
  X509_V_ERR_CERT_HAS_EXPIRED = 10;
  X509_V_ERR_CRL_NOT_YET_VALID = 11;
  X509_V_ERR_CRL_HAS_EXPIRED = 12;
  X509_V_ERR_ERROR_IN_CERT_NOT_BEFORE_FIELD = 13;
  X509_V_ERR_ERROR_IN_CERT_NOT_AFTER_FIELD = 14;
  X509_V_ERR_ERROR_IN_CRL_LAST_UPDATE_FIELD = 15;
  X509_V_ERR_ERROR_IN_CRL_NEXT_UPDATE_FIELD = 16;
  X509_V_ERR_OUT_OF_MEM = 17;
  X509_V_ERR_DEPTH_ZERO_SELF_SIGNED_CERT = 18;
  X509_V_ERR_SELF_SIGNED_CERT_IN_CHAIN = 19;
  X509_V_ERR_UNABLE_TO_GET_ISSUER_CERT_LOCALLY = 20;
  X509_V_ERR_UNABLE_TO_VERIFY_LEAF_SIGNATURE = 21;
  X509_V_ERR_CERT_CHAIN_TOO_LONG = 22;
  X509_V_ERR_CERT_REVOKED = 23;
  X509_V_ERR_INVALID_CA = 24;
  X509_V_ERR_PATH_LENGTH_EXCEEDED = 25;
  X509_V_ERR_INVALID_PURPOSE = 26;
  X509_V_ERR_CERT_UNTRUSTED = 27;
  X509_V_ERR_CERT_REJECTED = 28;
  //These are 'informational' when looking for issuer cert
  X509_V_ERR_SUBJECT_ISSUER_MISMATCH = 29;
  X509_V_ERR_AKID_SKID_MISMATCH = 30;
  X509_V_ERR_AKID_ISSUER_SERIAL_MISMATCH = 31;
  X509_V_ERR_KEYUSAGE_NO_CERTSIGN = 32;
  X509_V_ERR_UNABLE_TO_GET_CRL_ISSUER = 33;
  X509_V_ERR_UNHANDLED_CRITICAL_EXTENSION = 34;
  //The application is not happy
  X509_V_ERR_APPLICATION_VERIFICATION = 50;

  SSL_FILETYPE_ASN1	= 2;
  SSL_FILETYPE_PEM = 1;
  EVP_PKEY_RSA = 6;
  
 var
// libssl.dll
  SSL_get_error: function(s: PSSL; ret_code: Integer):Integer; cdecl;
  SSL_library_init: function():Integer; cdecl;
  SSL_load_error_strings: procedure; cdecl;
  SSL_CTX_set_cipher_list: function(arg0: PSSL_CTX; str: PChar):Integer; cdecl;
//  SSL_CTX_set_cipher_list: function(arg0: PSSL_CTX; var str: String):Integer; cdecl;
  SSL_CTX_new: function(meth: PSSL_METHOD):PSSL_CTX; cdecl;
  SSL_CTX_free: procedure(arg0: PSSL_CTX); cdecl;
  SSL_set_fd: function(s: PSSL; fd: Integer):Integer; cdecl;
  SSL_set_rfd: function(s: PSSL; fd: Integer):Integer; cdecl;
  SSL_set_wfd: function(s: PSSL; fd: Integer):Integer; cdecl;
  SSL_set_cipher_list: function(arg0: PSSL_CTX; str: PChar):Integer; cdecl;
  SSLv2_method: function():PSSL_METHOD; cdecl;
  SSLv3_method: function():PSSL_METHOD; cdecl;
  TLSv1_method: function():PSSL_METHOD; cdecl;
  SSLv23_method: function():PSSL_METHOD; cdecl;
  SSL_CTX_use_PrivateKey: function(ctx: PSSL_CTX; pkey: SslPtr):Integer; cdecl;
  SSL_CTX_use_PrivateKey_ASN1: function(pk: integer; ctx: PSSL_CTX; d: pbyte;
                                 len: integer):Integer; cdecl;
  SSL_CTX_use_PrivateKey_file: function(ctx: PSSL_CTX; _file: PChar;
                               _type: Integer):Integer; cdecl;
//  SSL_CTX_use_PrivateKey_file: function(ctx: PSSL_CTX; const _file: String; _type: Integer):Integer; cdecl;
  SSL_CTX_use_RSAPrivateKey_file: function(ctx: PSSL_CTX; _file: pchar;
                                 _type: Integer):Integer; cdecl;
  SSL_CTX_use_certificate: function(ctx: PSSL_CTX; x: SslPtr):Integer; cdecl;
  SSL_CTX_use_certificate_ASN1: function(ctx: PSSL_CTX; len: integer;
                                               d: pbyte):Integer; cdecl;
  SSL_CTX_use_certificate_file: function(ctx: PSSL_CTX;
                         _file: pchar; _type: Integer):Integer; cdecl;
  SSL_CTX_use_certificate_chain_file: function(ctx: PSSL_CTX;
                                          _file: PChar):Integer; cdecl;
//  SSL_CTX_use_certificate_chain_file: function(ctx: PSSL_CTX;
//                                const _file: String):Integer; cdecl;
  SSL_CTX_check_private_key: function(ctx: PSSL_CTX):Integer; cdecl;
  SSL_CTX_set_default_passwd_cb: procedure(ctx: PSSL_CTX; cb: PPasswdCb); cdecl;
  SSL_CTX_set_default_passwd_cb_userdata: procedure(ctx: PSSL_CTX; u: SslPtr); cdecl;
//  function SSL_CTX_LoadVerifyLocations(ctx: PSSL_CTX; const CAfile: PChar; const CApath: PChar):Integer; cdecl;
  SSL_CTX_load_verify_locations: function(ctx: PSSL_CTX; CAfile: pchar;
                                  CApath: pchar):Integer; cdecl;
  SSL_new: function(ctx: PSSL_CTX):PSSL; cdecl;
  SSL_free: procedure(ssl: PSSL); cdecl;
  SSL_ctrl: function(ssl: PSSL; cmd: integer; larg: integer;
                                    parg: pointer): integer; cdecl;
  SSL_use_certificate_file: function(ssl: PSSL;
                         _file: pchar; _type: Integer):Integer; cdecl;
  SSL_use_PrivateKey_file: function(ssl: PSSL; _file: PChar;
                               _type: Integer):Integer; cdecl;

  SSL_accept: function(ssl: PSSL):Integer; cdecl;
  SSL_connect: function(ssl: PSSL):Integer; cdecl;
  SSL_shutdown: function(ssl: PSSL):Integer; cdecl;
  SSL_read: function(ssl: PSSL; buf: SslPtr; num: Integer):Integer; cdecl;
  SSL_peek: function(ssl: PSSL; buf: SslPtr; num: Integer):Integer; cdecl;
  SSL_write: function(ssl: PSSL; buf: SslPtr; num: Integer):Integer; cdecl;
  SSL_pending: function(ssl: PSSL):Integer; cdecl;
  SSL_get_version: function(ssl: PSSL): pchar; cdecl;
  SSL_get_peer_certificate: function(ssl: PSSL): PX509; cdecl;
  SSL_CTX_set_verify: procedure(ctx: PSSL_CTX; mode: Integer; arg2: PFunction); cdecl;
  SSL_get_current_cipher: function(s: PSSL):SslPtr; cdecl;
  SSL_CIPHER_get_name: function(c: SslPtr): pchar; cdecl;
  SSL_CIPHER_get_bits: function(c: SslPtr; var alg_bits: Integer):Integer; cdecl;
  SSL_get_verify_result: function(ssl: PSSL):Integer; cdecl;


// libeay.dll
  X509_new: function(): PX509; cdecl;
  X509_free: procedure(x: PX509); cdecl;
  X509_NAME_oneline: function(a: PX509_NAME; 
                 buf: pchar; size: Integer): pchar; cdecl;
  X509_Get_Subject_Name: function(a: PX509):PX509_NAME; cdecl;
  X509_Get_Issuer_Name: function(a: PX509):PX509_NAME; cdecl;
  X509_NAME_hash: function(x: PX509_NAME):longword; cdecl;
//  function SSL_X509Digest(data: PX509; _type: PEVP_MD; md: PChar;
//                len: PInteger):Integer; cdecl;
  X509_digest: function(data: PX509; _type: PEVP_MD; md: pchar;
                   len: pInteger):Integer; cdecl;
  X509_print: function(b: PBIO; a: PX509): integer; cdecl;
  X509_set_version: function(x: PX509; version: integer): integer; cdecl;
  X509_set_pubkey: function(x: PX509; pkey: EVP_PKEY): integer; cdecl;
  X509_set_issuer_name: function(x: PX509; name: PX509_NAME): integer; cdecl;
  X509_NAME_add_entry_by_txt: function(name: PX509_NAME; field: pchar;
    _type: integer; bytes: pbyte; len, loc, _set: integer): integer; cdecl;
  X509_sign: function(x: PX509; pkey: EVP_PKEY; const md: PEVP_MD): integer; cdecl;
  X509_gmtime_adj: function(s: PASN1_UTCTIME; adj: integer): PASN1_UTCTIME; cdecl;
  X509_set_NotBefore: function(x: PX509; tm: PASN1_UTCTIME): integer; cdecl;
  X509_set_NotAfter: function(x: PX509; tm: PASN1_UTCTIME): integer; cdecl;
  X509_get_serialNumber: function(x: PX509): PASN1_INTEGER; cdecl;
  EVP_PKEY_New: function(): EVP_PKEY; cdecl;
  EVP_PKEY_Free: procedure(pk: EVP_PKEY); cdecl;
  EVP_PKEY_Assign: function(pkey: EVP_PKEY; _type: integer;
                          key: Prsa): integer; cdecl;
  EVP_get_digestbyname: function(Name: pchar): PEVP_MD; cdecl;
  EVP_cleanup: procedure; cdecl;
//  function ErrErrorString(e: integer; buf: PChar): PChar;
  SSLeay_version: function(t: integer): pchar; cdecl;
  ERR_error_string_n: procedure(e: integer; buf: PChar; len: integer); cdecl;
  ERR_get_error: function(): integer; cdecl;
  ERR_clear_error: procedure; cdecl;
  ERR_free_strings: procedure; cdecl;
  ERR_remove_state: procedure(pid: integer); cdecl;
  OPENSSL_add_all_algorithms_noconf: procedure; cdecl;
  CRYPTO_cleanup_all_ex_data: procedure; cdecl;
//  RAND_screen: procedure; cdecl;
  BIO_new: function(b: PBIO_METHOD): PBIO; cdecl;
  BIO_free_all: procedure(b: PBIO); cdecl;
  BIO_s_mem: function(): PBIO_METHOD; cdecl;
  BIO_ctrl_pending: function(b: PBIO): integer; cdecl;
  BIO_read: function(b: PBIO; Buf: pbyte; Len: integer): integer; cdecl;
  BIO_write: function(b: PBIO; Buf: pbyte; Len: integer): integer; cdecl;
  d2i_PKCS12_bio: function(b:PBIO; Pkcs12: SslPtr): SslPtr; cdecl;
  PKCS12_parse: function(p12: SslPtr; pass: pchar; pkey,
                      cert, ca: pSslPtr): integer; cdecl;
  PKCS12_free: procedure(p12: SslPtr); cdecl;
  RSA_generate_key: function(bits, e: integer;
           callback: PFunction; cb_arg: SslPtr): PRSA; cdecl;
  ASN1_UTCTIME_New: function(): PASN1_UTCTIME; cdecl;
  ASN1_UTCTIME_Free: procedure(a: PASN1_UTCTIME); cdecl;
  ASN1_INTEGER_Set: function(a: PASN1_INTEGER; v: integer): integer; cdecl;
  i2d_X509_bio: function(b: PBIO; x: PX509): integer; cdecl;
  i2d_PrivateKey_Bio: function(b: PBIO; pkey: EVP_PKEY): integer; cdecl;
  // 3DES functions
  DES_set_odd_parity: procedure(Key: des_cblock); cdecl;
  DES_set_key_checked: function(key: des_cblock;
                   schedule: des_key_schedule): Integer; cdecl;
  DES_ecb_encrypt: procedure(Input: des_cblock; output: des_cblock;
                   ks: des_key_schedule; enc: Integer); cdecl;

  CRYPTO_num_locks: function: integer; cdecl;
  CRYPTO_set_locking_callback: procedure(cb: Sslptr); cdecl;
  CRYPTO_set_id_callback: procedure(func: pointer); cdecl;

{$IFDEF OPENSSL_EXT}
  SSLeay: function: cardinal;
  OpenSSL_add_all_ciphers: procedure; cdecl;
  OpenSSL_add_all_digests: procedure; cdecl;
  ERR_load_crypto_strings: procedure; cdecl;
  ERR_peek_error: function: cardinal; cdecl;
  ERR_peek_last_error: function: cardinal; cdecl;
  // Low level debugable memory management function
  CRYPTO_malloc: function (length: longint; const f: PCharacter; line: integer): pointer; cdecl;
  CRYPTO_realloc: function(str: PCharacter; length: longint; const f: PCharacter; line: integer): pointer; cdecl;
  CRYPTO_remalloc: function(a: pointer; length: longint; const f: PCharacter; line: integer): pointer; cdecl;
  CRYPTO_free: procedure(str: pointer); cdecl;
// OBJ functions
  OBJ_obj2nid: function(asn1_object: pointer): integer; cdecl;
  OBJ_txt2nid: function(s: PCharacter): integer; cdecl;
  OBJ_txt2obj: function(s: PCharacter; no_name: integer): integer; cdecl;
  // safestack functions
  sk_new_null: function: pointer; cdecl;
  sk_free: procedure(st: pointer); cdecl;
  sk_push: function(st: pointer; val: pointer): integer; cdecl;
  sk_num: function(st: pointer): integer; cdecl;
  sk_value: function(st: pointer; i: integer): pointer; cdecl;
  // Internal to DER and DER to internal conversion functions
  i2d_ASN1_TIME: function(a: pASN1_TIME; pp: PCharacter): integer; cdecl;
  d2i_ASN1_TIME: function(var a: pASN1_TIME; pp: PCharacter; length: longint): pASN1_TIME; cdecl;
  d2i_X509_REQ_bio: function(bp: pBIO; req: pX509_REQ): pX509_REQ; cdecl;
  i2d_X509_REQ_bio: function(bp: pBIO; req: pX509_REQ): integer; cdecl;
  d2i_X509_bio: function(bp: pBIO; x509: pX509): pX509; cdecl;
  d2i_PrivateKey_bio: function(bp: pBIO; var a: pEVP_PKEY): pEVP_PKEY; cdecl;
  d2i_PUBKEY_bio: function(bp: pBIO; var a: pEVP_PKEY): pEVP_PKEY; cdecl;
  i2d_PUBKEY_bio: function(bp: pBIO; pkey: pEVP_PKEY): integer; cdecl;
  i2d_PKCS12_bio: function(bp: pBIO; pkcs12: pPKCS12): integer; cdecl;
  d2i_PKCS7: function(var a: pPKCS7; pp: pointer; length: longint): pPKCS7; cdecl;
  d2i_PKCS7_bio: function(bp: pBIO; p7: pPKCS7): pPKCS7; cdecl;
  i2d_PKCS7_bio: function(bp: pBIO; p7: pPKCS7): integer; cdecl;
  d2i_PKCS8_bio: function(bp: pBIO; p8: pX509_SIG): pX509_SIG; cdecl;
  d2i_PKCS8_PRIV_KEY_INFO: function(var a: pPKCS8_Priv_Key_Info; pp: PCharacter; Length: LongInt): pPKCS8_Priv_Key_Info; cdecl;
  d2i_DSAPrivateKey_bio: function(bp: pBIO; dsa: pDSA): pDSA; cdecl;
  i2d_DSAPrivateKey_bio: function(bp: pBIO; dsa: pDSA): integer; cdecl;
  d2i_RSAPrivateKey_bio: function(bp: pBIO; rsa: pRSA): pRSA; cdecl;
  i2d_RSAPrivateKey_bio: function(bp: pBIO; rsa: pRSA): integer; cdecl;
  // Internal to ASN.1 and ASN.1 to internal conversion functions
  i2a_ASN1_INTEGER: function(bp: pBIO; a: pASN1_INTEGER): integer; cdecl;
  a2i_ASN1_INTEGER: function(bp: pBIO; bs: pASN1_INTEGER; buf: PCharacter; size: integer): integer; cdecl;

{$IFDEF OPENSSL_BIGNUM}
  // Big number function
  BN_new:function: pBIGNUM; cdecl;
  BN_init: procedure(bn: pBIGNUM); cdecl;
  BN_clear: procedure(bn: pBIGNUM); cdecl;
  BN_free: procedure(bn: pBIGNUM); cdecl;
  BN_clear_free: procedure(bn: pBIGNUM); cdecl;
  BN_set_params: procedure (mul, high, low, mont: integer); cdecl;
  BN_get_params: function(which: integer): integer; cdecl;
  BN_options:function: PCharacter; cdecl;
  BN_CTX_new: function: pBN_CTX; cdecl;
  BN_CTX_init: procedure(ctx: pBN_CTX); cdecl;
  BN_CTX_start: procedure(ctx: pBN_CTX); cdecl;
  BN_CTX_get: function(ctx: pBN_CTX): pBIGNUM; cdecl;
  BN_CTX_end: procedure(ctx: pBN_CTX); cdecl;
  BN_CTX_free: procedure(ctx: pBN_CTX); cdecl;
  BN_MONT_CTX_new: function: pBN_MONT_CTX; cdecl;
  BN_MONT_CTX_init: procedure(m_ctx: pBN_MONT_CTX); cdecl;
  BN_MONT_CTX_set: function(m_ctx: pBN_MONT_CTX;const modulus: pBIGNUM; ctx: pBN_CTX): integer; cdecl;
  BN_MONT_CTX_copy: function(_to: pBN_MONT_CTX; from: pBN_MONT_CTX): pBN_MONT_CTX; cdecl;
  BN_MONT_CTX_free: procedure(m_ctx: pBN_MONT_CTX); cdecl;
  BN_mod_mul_montgomery: function(r, a, b: pBIGNUM; m_ctx: pBN_MONT_CTX; ctx: pBN_CTX): integer; cdecl;
  BN_from_montgomery: function(r, a: pBIGNUM; m_ctx: pBN_MONT_CTX; ctx: pBN_CTX): integer; cdecl;
  BN_RECP_CTX_init: procedure(recp: pBN_RECP_CTX); cdecl;
  BN_RECP_CTX_set: function(recp: pBN_RECP_CTX; const rdiv: pBIGNUM; ctx: pBN_CTX): integer; cdecl;
  BN_RECP_CTX_new: function: pBN_RECP_CTX; cdecl;
  BN_RECP_CTX_free: procedure(recp: pBN_RECP_CTX); cdecl;
  BN_div_recp: function(dv, rem, a: pBIGNUM; recp: pBN_RECP_CTX; ctx: pBN_CTX): integer; cdecl;
  BN_mod_mul_reciprocal: function(r, a, b: pBIGNUM; recp: pBN_RECP_CTX; ctx: pBN_CTX): integer; cdecl;
  BN_BLINDING_new: function(a: pBIGNUM; Ai: pBIGNUM; _mod: pBIGNUM): pBN_BLINDING; cdecl;
  BN_BLINDING_update: function(b: pBN_BLINDING; ctx: pBN_CTX): pBN_BLINDING; cdecl;
  BN_BLINDING_free: procedure(b: pBN_BLINDING); cdecl;
  BN_BLINDING_convert: function(n: pBIGNUM; r: pBN_BLINDING; ctx: pBN_CTX): integer; cdecl;
  BN_BLINDING_invert: function(n: pBIGNUM; b: pBN_BLINDING; ctx: pBN_CTX): integer; cdecl;
  BN_copy: function(_to: pBIGNUM; const from: pBIGNUM): pBIGNUM; cdecl;
  BN_dup: function(const from: pBIGNUM): pBIGNUM; cdecl;
  BN_bn2bin: function(const n: pBIGNUM; _to: pointer): integer; cdecl;
  BN_bin2bn: function(const _from: pointer; len: integer; ret: pBIGNUM): pBIGNUM; cdecl;
  BN_bn2hex: function(const n: pBIGNUM): PCharacter; cdecl;
  BN_bn2dec: function(const n: pBIGNUM): PCharacter; cdecl;
  BN_hex2bn: function(var n: pBIGNUM; const str: PCharacter): integer; cdecl;
  BN_dec2bn: function(var n: pBIGNUM; const str: PCharacter): integer; cdecl;
  BN_bn2mpi: function(const a: pBIGNUM; _to: pointer): integer; cdecl;
  BN_mpi2bn: function(s: pointer; len: integer; ret: pBIGNUM): pBIGNUM; cdecl;
  BN_print: function(fp: pBIO; const a: pointer): integer; cdecl;
  // BN_print_fp: function(FILE *fp, const BIGNUM *a): integer; cdecl;
  BN_value_one: function: pBIGNUM; cdecl;
  BN_set_word: function(n: pBIGNUM; w: cardinal): integer; cdecl;
  BN_get_word: function(n: pBIGNUM): cardinal; cdecl;
  BN_cmp: function(a: pBIGNUM; b: pBIGNUM): integer; cdecl;
  BN_ucmp: function(a: pBIGNUM; b: pBIGNUM): integer; cdecl;
  BN_num_bits: function(const a: pBIGNUM): integer; cdecl;
  BN_num_bits_word: function(w: BN_ULONG): integer; cdecl;
  BN_add: function(r: pBIGNUM; const a, b: pBIGNUM): integer; cdecl;
  BN_sub: function(r: pBIGNUM; const a, b: pBIGNUM): integer; cdecl;
  BN_uadd: function(r: pBIGNUM; const a, b: pBIGNUM): integer; cdecl;
  BN_usub: function(r: pBIGNUM; const a, b: pBIGNUM): integer; cdecl;
  BN_mul: function(r: pBIGNUM; a: pBIGNUM; b: pBIGNUM; ctx: pBN_CTX): integer; cdecl;
  BN_sqr: function(r: pBIGNUM; a: pBIGNUM; ctx: pBN_CTX): integer; cdecl;
  BN_div: function(dv: pBIGNUM; rem: pBIGNUM; const a, d: pBIGNUM; ctx: pBN_CTX): integer; cdecl;
  BN_exp: function(r: pBIGNUM; a: pBIGNUM; p: pBIGNUM; ctx: pBN_CTX): integer; cdecl;
  BN_mod_exp: function(r, a: pBIGNUM; const p, m: pBIGNUM; ctx: pBN_CTX): integer; cdecl;
  BN_gcd: function(r: pBIGNUM; a: pBIGNUM; b: pBIGNUM; ctx: pBN_CTX): integer; cdecl;
  // BN_nnmod requires OpenSSL >= 0.9.7
  BN_nnmod: function(rem: pBIGNUM; const a: pBIGNUM; const m: pBIGNUM; ctx: pBN_CTX): integer; cdecl;
  // BN_mod_add requires OpenSSL >= 0.9.7
  BN_mod_add: function(r: pBIGNUM; a: pBIGNUM; b: pBIGNUM; const m: pBIGNUM; ctx: pBN_CTX): integer;cdecl;
  // BN_mod_sub requires OpenSSL >= 0.9.7
  BN_mod_sub: function(r: pBIGNUM; a: pBIGNUM; b: pBIGNUM; const m: pBIGNUM; ctx: pBN_CTX): integer; cdecl;
  // BN_mod_mul requires OpenSSL >= 0.9.7
  BN_mod_mul: function(ret, a, b: pBIGNUM; const m: pBIGNUM; ctx: pBN_CTX): integer; cdecl;
  // BN_mod_sqr requires OpenSSL >= 0.9.7
  BN_mod_sqr: function(r: pBIGNUM; a: pBIGNUM; const m: pBIGNUM; ctx: pBN_CTX): integer; cdecl;
  BN_reciprocal: function(r, m: pBIGNUM; ctx: pBN_CTX): integer; cdecl;
  BN_mod_exp2_mont: function(r, a1, p1, a2, p2, m: pBIGNUM; ctx: pBN_CTX; m_ctx: pBN_MONT_CTX): integer; cdecl;
  BN_mod_exp_mont: function(r, a: pBIGNUM; const p, m: pBIGNUM; ctx: pBN_CTX; m_ctx: pBN_MONT_CTX): integer; cdecl;
  BN_mod_exp_mont_word: function(r: pBIGNUM; a: BN_ULONG; const p, m: pBIGNUM; ctx: pBN_CTX; m_ctx: pBN_MONT_CTX): integer; cdecl;
  BN_mod_exp_simple: function(r, a, p, m: pBIGNUM; ctx: pBN_CTX): integer; cdecl;
  BN_mod_exp_recp: function(r: pBIGNUM; const a, p, m: pBIGNUM; ctx: pBN_CTX): integer; cdecl;
  BN_mod_inverse: function(ret, a: pBIGNUM; const n: pBIGNUM; ctx: pBN_CTX): pBIGNUM; cdecl;
  BN_add_word: function (a: pBIGNUM; w: BN_ULONG): integer; cdecl;  // Adds w to a ("a+=w").
  BN_sub_word: function(a: pBIGNUM; w: BN_ULONG): integer; cdecl;  // Subtracts w from a ("a-=w").
  BN_mul_word: function(a: pBIGNUM; w: BN_ULONG): integer; cdecl;  // Multiplies a and w ("a*=b").
  BN_div_word: function(a: pBIGNUM; w: BN_ULONG): BN_ULONG; cdecl;  // Divides a by w ("a/=w") and returns the remainder.
  BN_mod_word: function(const a: pBIGNUM; w: BN_ULONG): BN_ULONG; cdecl;  // Returns the remainder of a divided by w ("a%m").
  bn_mul_words: function(rp, ap: pBN_ULONG; num: integer; w: BN_ULONG): BN_ULONG; cdecl;
  bn_mul_add_words: function(rp, ap: pBN_ULONG; num: integer; w: BN_ULONG): BN_ULONG; cdecl;
  bn_sqr_words: procedure(rp, ap: pBN_ULONG; num: integer); cdecl;
  bn_div_words: function(h, l, d: BN_ULONG): BN_ULONG; cdecl;
  bn_add_words: function(rp, ap, bp: pBN_ULONG; num: integer): BN_ULONG; cdecl;
  bn_sub_words: function(rp, ap, bp: pBN_ULONG; num: integer): BN_ULONG; cdecl;
  bn_expand2: function(a: pBIGNUM; n: integer): pBIGNUM; cdecl;
  BN_set_bit: function(a: pBIGNUM; n: integer): integer; cdecl;
  BN_clear_bit: function(a: pBIGNUM; n: integer): integer; cdecl;
  BN_is_bit_set: function(const a: pBIGNUM; n: integer): integer; cdecl;
  BN_mask_bits: function(a: pBIGNUM; n: integer): integer; cdecl;
  BN_lshift: function(r: pBIGNUM; const a: pBIGNUM; n: integer): integer; cdecl;
  BN_lshift1: function(r: pBIGNUM; a: pBIGNUM): integer; cdecl;
  BN_rshift: function(r: pBIGNUM; const a: pBIGNUM; n: integer): integer; cdecl;
  BN_rshift1: function(r: pBIGNUM; a: pBIGNUM): integer; cdecl;
  BN_generate_prime: function (ret: pBIGNUM; num, safe: integer; add, rem: pBIGNUM; progress: TProgressCallbackFunction; cb_arg: pointer): pBIGNUM; cdecl;
  BN_is_prime: function(const a: pBIGNUM; checks: integer; progress: TProgressCallbackFunction; ctx: pBN_CTX; cb_arg: pointer): integer; cdecl;
  BN_is_prime_fasttest: function(const a: pBIGNUM; checks: integer; progress: TProgressCallbackFunction; ctx: pBN_CTX; cb_arg: pointer; do_trial_division: integer): integer; cdecl;
  BN_rand: function(rnd: pBIGNUM; bits, top, bottom: integer): integer; cdecl;
  BN_pseudo_rand: function(rnd: pBIGNUM; bits, top, bottom: integer): integer; cdecl;
  BN_rand_range: function(rnd, range: pBIGNUM): integer; cdecl;
  // BN_pseudo_rand_range requires OpenSSL >= 0.9.6c
  BN_pseudo_rand_range: function(rnd, range: pBIGNUM): integer; cdecl;
  BN_bntest_rand: function(rnd: pBIGNUM; bits, top, bottom: integer): integer; cdecl;
  BN_to_ASN1_INTEGER: function(bn: pBIGNUM; ai: pASN1_INTEGER): pASN1_INTEGER; cdecl;
  BN_to_ASN1_ENUMERATED: function(bn: pBIGNUM; ai: pASN1_ENUMERATED): pASN1_ENUMERATED; cdecl;
{$ENDIF OPENSSL_BIGNUM}
{$IFDEF OPENSSL_ASN1}
  // ASN.1 functions
  ASN1_IA5STRING_new: function: pASN1_IA5STRING; cdecl;
  ASN1_INTEGER_free: procedure(x: pASN1_IA5STRING); cdecl;
  ASN1_INTEGER_get: function(a: pointer): longint; cdecl;
  ASN1_STRING_set_default_mask: procedure(mask: cardinal); cdecl;
  ASN1_STRING_get_default_mask: function: cardinal; cdecl;
  ASN1_TIME_print: function(fp: pBIO; a: pASN1_TIME): integer; cdecl;
{$ENDIF OPENSSL_ASN1}
{$IFDEF OPENSSL_BIO}
  // BIO functions
  BIO_new_file: function(const filename: PCharacter; const mode: PCharacter): pBIO; cdecl;
  BIO_set: function(a: pBIO; _type: pBIO_METHOD): integer; cdecl;
  BIO_free: function(a: pBIO): integer; cdecl;
  BIO_vfree: procedure(a: pBIO); cdecl;
  BIO_push: function(b: pBIO; append: pBIO): pBIO; cdecl;
  BIO_pop: function(b: pBIO): pBIO; cdecl;
  BIO_ctrl: function(bp: pBIO; cmd: Integer; larg: Longint; parg: Pointer): Longint; cdecl;
  BIO_gets: function(b: pBIO; buf: PCharacter; size: integer): integer; cdecl;
  BIO_puts: function(b: pBIO; const buf: PCharacter): integer; cdecl;
  BIO_f_base64: function: pBIO_METHOD; cdecl;
  BIO_set_mem_eof_return: procedure(b: pBIO; v: integer); cdecl;
  BIO_set_mem_buf: procedure(b: pBIO; bm: pBUF_MEM; c: integer); cdecl;
  BIO_get_mem_ptr: procedure(b: pBIO; var pp: pBUF_MEM); cdecl;
  BIO_new_mem_buf: function(buf: pointer; len: integer): pBIO; cdecl;
  BIO_s_file: function: pBIO_METHOD; cdecl;
{$ENDIF OPENSSL_BIO}
{$IFDEF OPENSSL_EVP}
  // Hash functions
  EVP_md_null: function: pEVP_MD; cdecl;
  EVP_md2: function: pEVP_MD; cdecl;
  EVP_md5: function: pEVP_MD; cdecl;
  EVP_sha: function: pEVP_MD; cdecl;
  EVP_sha1: function: pEVP_MD; cdecl;
  EVP_dss: function: pEVP_MD; cdecl;
  EVP_dss1: function: pEVP_MD; cdecl;
  EVP_mdc2: function: pEVP_MD; cdecl;
  EVP_ripemd160: function: pEVP_MD; cdecl;
  EVP_DigestInit: procedure(ctx: pEVP_MD_CTX; const _type: pEVP_MD); cdecl;
  EVP_DigestUpdate: procedure(ctx: pEVP_MD_CTX; const d: Pointer; cnt: cardinal); cdecl;
  EVP_DigestFinal: procedure(ctx: pEVP_MD_CTX; md: PCharacter; var s: cardinal); cdecl;
  EVP_SignFinal: function(ctx: pEVP_MD_CTX; sig: pointer; var s: cardinal; key: pEVP_PKEY): integer; cdecl;
  EVP_VerifyFinal: function(ctx: pEVP_MD_CTX; sigbuf: pointer; siglen: cardinal; pkey: pEVP_PKEY): integer;  cdecl;
  EVP_MD_CTX_copy: function(_out: pEVP_MD_CTX; _in: pEVP_MD_CTX): integer; cdecl;
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
  EVP_get_cipherbyname: function(name: PCharacter): pEVP_CIPHER; cdecl;
  // EVP Key functions
  EVP_PKEY_type: function(keytype: integer): integer; cdecl;
  EVP_PKEY_assign_RSA: function(key: pEVP_PKEY; rsa: pRSA): integer; cdecl;
  EVP_PKEY_assign_DSA: function(key: pEVP_PKEY; dsa: pDSA): integer; cdecl;
  EVP_PKEY_assign_DH: function(key: pEVP_PKEY; dh: pDH): integer; cdecl;
  EVP_PKEY_assign_EC_KEY: function(key: pEVP_PKEY; ec: pEC_KEY): integer; cdecl;
  EVP_PKEY_set1_RSA: function(key: pEVP_PKEY; rsa: pRSA): integer; cdecl;
  EVP_PKEY_set1_DSA: function(key: pEVP_PKEY; dsa: pDSA): integer; cdecl;
  EVP_PKEY_set1_DH: function(key: pEVP_PKEY; dh: pDH): integer; cdecl;
  EVP_PKEY_set1_EC_KEY: function(key: pEVP_PKEY; ec: pEC_KEY): integer; cdecl;
  EVP_PKEY_size: function(key: pEVP_PKEY): integer; cdecl;
  EVP_PKEY_get1_RSA: function(key: pEVP_PKEY): pRSA; cdecl;
  EVP_PKEY_get1_DSA: function(key: pEVP_PKEY): pDSA; cdecl;
  EVP_PKEY_get1_DH: function(key: pEVP_PKEY): pDH; cdecl;
  EVP_PKEY_get1_EC_KEY: function(key: pEVP_PKEY): pEC_KEY; cdecl;
  // Password prompt for callback function
  EVP_set_pw_prompt: procedure(prompt: PCharacter);cdecl;
  EVP_get_pw_prompt: function: PCharacter;cdecl;
  // Default callback password function: replace if you want
  EVP_read_pw_string: function(buf: PCharacter; len: integer; const prompt: PCharacter; verify: integer): integer;cdecl;
{$ENDIF OPENSSL_EVP}
{$IFDEF OPENSSL_RAND}
  // pseudo-random number generator (PRNG) functions
  RAND_seed: procedure(const buf: pointer; num: integer); cdecl;
  RAND_add: procedure(const buf: pointer; num: integer; entropy: double); cdecl;
  RAND_status: function: integer; cdecl;
  // RAND_event: function(UINT iMsg, WPARAM wParam, LPARAM lParam): integer; cdecl;
  RAND_file_name: function(buf: PCharacter; size_t: cardinal): PCharacter; cdecl;
  RAND_load_file: function(const filename: PCharacter; max_bytes: longint): integer; cdecl;
  RAND_write_file: function(const filename: PCharacter): integer; cdecl;
{$ENDIF OPENSSL_RAND}
{$IFDEF OPENSSL_RSA}
  // RSA function
  RSA_new: function: pRSA; cdecl;
  RSA_free: procedure(r: pRSA); cdecl;
  RSA_new_method: function(method: pRSA_METHOD): pRSA; cdecl;
  RSA_size: function(pkey: pRSA): integer; cdecl;
  RSA_check_key: function(arg0: pRSA): integer; cdecl;
 RSA_public_encrypt: function(flen: integer; from: PCharacter; _to: PCharacter; rsa: pRSA; padding: integer): integer; cdecl;
 RSA_private_encrypt: function(flen: integer; from: PCharacter; _to: PCharacter; rsa: pRSA; padding: integer): integer; cdecl;
 RSA_public_decrypt: function(flen: integer; from: PCharacter; _to: PCharacter; rsa: pRSA; padding: integer): integer; cdecl;
 RSA_private_decrypt: function(flen: integer; from: PCharacter; _to: PCharacter; rsa: pRSA; padding: integer): integer; cdecl;
 RSA_flags: function(r: pRSA): integer; cdecl;
 RSA_set_default_method: procedure(meth: pRSA_METHOD); cdecl;
 RSA_get_default_method: function: pRSA_METHOD; cdecl;
 RSA_get_method: function(rsa: pRSA): pRSA_METHOD; cdecl;
 RSA_set_method: function(rsa: pRSA; meth: pRSA_METHOD): pRSA_METHOD; cdecl;
 RSA_memory_lock: function(r: pRSA):integer; cdecl;
 RSA_PKCS1_SSLeay: function: pRSA_METHOD; cdecl;
 ERR_load_RSA_strings: procedure;cdecl;
{$ENDIF OPENSSL_RSA}
{$IFDEF OPENSSL_DSA}
 DSA_new: function: pDSA; cdecl;
 DSA_free: procedure(r: pDSA); cdecl;
 DSA_generate_parameters: function(bits: integer; seed: pointer; seed_len: integer;var counter_ret: integer; var h_ret: cardinal; progress: TProgressCallbackFunction; cb_arg: Pointer): pDSA; cdecl;
 DSA_generate_key: function(a: pDSA): integer; cdecl;
{$ENDIF OPENSSL_DSA}
{$IFDEF OPENSSL_X509}
// X.509 names (DN)
 X509_NAME_new: function: pX509_NAME; cdecl;
 X509_NAME_free: procedure(x:pX509_NAME) cdecl;
 X509_NAME_get_entry: function(name: pX509_NAME; loc: integer): pX509_NAME_ENTRY; cdecl;
 X509_NAME_get_text_by_NID: function(name: pX509_NAME; nid: integer; buf: PCharacter; len: integer): integer; cdecl;
// X.509 function
 X509_load_cert_file: function(ctx: pX509_LOOKUP; const filename: PCharacter; _type: integer): integer; cdecl;
 X509_get1_email: function(x: pX509): pSTACK; cdecl;
 X509_get_pubkey: function(a: pX509): pEVP_PKEY; cdecl;
 X509_check_private_key: function(x509: pX509; pkey: pEVP_PKEY): integer; cdecl;
 X509_check_purpose: function(x: pX509; id: integer; ca: integer): integer; cdecl;
 X509_issuer_and_serial_cmp: function(a: pX509; b: pX509): integer; cdecl;
 X509_issuer_and_serial_hash: function(a: pX509): cardinal; cdecl;
 X509_verify_cert: function(ctx: pX509_STORE_CTX): integer; cdecl;
 X509_verify_cert_error_string: function(n: longint): PCharacter; cdecl;
 X509_email_free: procedure(sk: pSTACK); cdecl;
 X509_get_ext: function(x: pX509; loc: integer): pX509_EXTENSION; cdecl;
 X509_get_ext_by_NID: function(x: pX509; nid, lastpos: integer): integer; cdecl;
 X509_get_ext_d2i: function(x: pX509; nid: integer; var crit, idx: integer): pointer; cdecl;
 X509V3_EXT_d2i: function(ext: pX509_EXTENSION): pointer; cdecl;
 X509V3_EXT_i2d: function(ext_nid: integer; crit: integer; ext_struc: pointer):
    pX509_EXTENSION; cdecl;
 X509V3_EXT_conf_nid: function(conf: pointer; ctx: pointer;
    ext_nid: integer; value: PCharacter): pX509_EXTENSION; cdecl;
 X509_set_subject_name: function(x: pX509; name: pX509_NAME): integer; cdecl;
 X509V3_set_ctx: procedure(ctx: pX509V3_CTX; issuer: pX509; subject: pX509; req: pX509_REQ; crl: pX509_CRL; flags: integer);
 X509_SIG_free: procedure(a: pX509_SIG); cdecl;
 X509_PUBKEY_get: function(key: pointer): pEVP_PKEY; cdecl;
 X509_REQ_new: function: pX509_REQ; cdecl;
 X509_REQ_free: procedure(req: pX509_REQ); cdecl;
 X509_REQ_set_version: function(req: pX509_REQ; version: longint): integer; cdecl;
 X509_REQ_set_subject_name: function(req: pX509_REQ; name: pX509_NAME): integer; cdecl;
 X509_REQ_add1_attr_by_txt: function(req: pX509_REQ; attrname: PCharacter; asn1_type: integer; bytes: pointer; len: integer): integer; cdecl;
 X509_REQ_add_extensions: function(req: pX509_REQ;exts: pSTACK_OFX509_EXTENSION): integer; cdecl;
 X509_REQ_set_pubkey: function(req: pX509_REQ; pkey: pEVP_PKEY): integer; cdecl;
 X509_REQ_get_pubkey: function(req: pX509_REQ): pEVP_PKEY; cdecl;
 X509_REQ_sign: function(req: pX509_REQ; pkey: pEVP_PKEY; const md: pEVP_MD): integer; cdecl;
// X.509 collections
 X509_STORE_new: function: pX509_STORE; cdecl;
 X509_STORE_free: procedure(v: pX509_STORE); cdecl;
 X509_STORE_add_cert: function(ctx: pX509_STORE; x: pX509): integer; cdecl;
 X509_STORE_add_lookup: function(v: pX509_STORE; m: pX509_LOOKUP_METHOD): pX509_LOOKUP; cdecl;
 X509_STORE_CTX_new: function: pX509_STORE_CTX; cdecl;
 X509_STORE_CTX_free: procedure(ctx: pX509_STORE); cdecl;
 X509_STORE_CTX_init: procedure(ctx: pX509_STORE_CTX; store: pX509_STORE; x509: pX509; chain: pSTACK_OFX509); cdecl;
 X509_STORE_CTX_get_current_cert: function(ctx: pX509_STORE_CTX): pX509; cdecl;
 X509_STORE_CTX_get_error: function(ctx: pX509_STORE_CTX): integer; cdecl;
 X509_STORE_CTX_get_error_depth: function(ctx: pX509_STORE_CTX): integer; cdecl;
 X509_LOOKUP_new: function(method: pX509_LOOKUP_METHOD): pX509_LOOKUP; cdecl;
 X509_LOOKUP_init: function(ctx: pX509_LOOKUP): integer; cdecl;
 X509_LOOKUP_free: procedure(ctx: pX509_LOOKUP); cdecl;
 X509_LOOKUP_ctrl: function(ctx: pX509_LOOKUP; cmd: integer; const argc: PCharacter; argl: longint; ret: pointer): integer; cdecl;
 X509_LOOKUP_file: function: pX509_LOOKUP_METHOD; cdecl;
{$ENDIF OPENSSL_X509}
{$IFDEF OPENSSL_PEM}
// PEM functions
 PEM_read_bio_RSAPrivateKey: function(bp: pBIO; var x: pRSA;cb: TPWCallbackFunction; u: pointer): pRSA; cdecl;
 PEM_write_bio_RSAPrivateKey: function(bp: pBIO; x: pRSA; const enc: pEVP_CIPHER;
    kstr: PCharacter; klen: integer; cb: TPWCallbackFunction; u: pointer): integer; cdecl;
 PEM_read_bio_RSAPublicKey: function(bp: pBIO; var x: pRSA;
    cb: TPWCallbackFunction; u: pointer): pRSA; cdecl;
 PEM_write_bio_RSAPublicKey: function(bp: pBIO; x: pRSA): integer; cdecl;
 PEM_read_bio_DSAPrivateKey: function(bp: pBIO; var dsa: pDSA;
    cb: TPWCallbackFunction; data: pointer): pDSA; cdecl;
 PEM_write_bio_DSAPrivateKey: function(bp: pBIO; dsa: pDSA; const enc: pEVP_CIPHER;
    kstr: PCharacter; klen: integer; cb: TPWCallbackFunction;
    data: pointer): integer; cdecl;
 PEM_read_bio_PUBKEY: function(bp: pBIO; var x: pEVP_PKEY; cb: TPWCallbackFunction; u: pointer): pEVP_PKEY; cdecl;
 PEM_write_bio_PUBKEY: function(bp: pBIO; x: pEVP_PKEY): integer; cdecl;
 PEM_read_bio_X509: function(bp: pBIO; var x: pX509; cb: TPWCallbackFunction;
    u: pointer): pX509; cdecl;
 PEM_write_bio_X509: function(bp: pBIO; x: pX509): integer; cdecl;
 PEM_read_bio_X509_AUX: function(bp: pBIO; var x: pX509; cb: TPWCallbackFunction;
    u: pointer): pX509; cdecl;
 PEM_write_bio_X509_AUX: function(bp: pBIO; x: pX509): integer; cdecl;
 PEM_read_bio_X509_REQ: function(bp: pBIO; var x: pX509_REQ; cb: TPWCallbackFunction;
    u: pointer): pX509_REQ; cdecl;
 PEM_write_bio_X509_REQ: function(bp: pBIO; x: pX509_REQ): integer; cdecl;
 PEM_read_bio_X509_CRL: function(bp: pBIO; var x: pX509_CRL; cb: TPWCallbackFunction;
    u: pointer): pX509_CRL; cdecl;
 PEM_write_bio_X509_CRL: function(bp: pBIO; x: pX509_CRL): integer; cdecl;
 PEM_read_bio_PrivateKey: function(bp: pBIO; var x: pEVP_PKEY;
    cb: TPWCallbackFunction; u: pointer): pEVP_PKEY; cdecl;
  PEM_write_bio_PrivateKey: function(bp: pBIO; x: pEVP_PKEY;
    const enc: pEVP_CIPHER; kstr: PCharacter; klen: Integer; cb: TPWCallbackFunction;
    u: pointer): integer; cdecl;
 PEM_write_bio_PKCS7: function(bp: pBIO; x: pPKCS7): integer; cdecl;
{$ENDIF OPENSSL_PEM}
{$IFDEF OPENSSL_PKCS}
// PKCS#5 functions
 PKCS5_PBKDF2_HMAC_SHA1: function(pass: PCharacter; passlen: integer;
    salt: pointer; saltlen: integer; iter: integer;
    keylen: integer; u: pointer): integer; cdecl;
// PKCS#7 functions
 PKCS7_sign: function(signcert: pX509; pkey: pEVP_PKEY; certs: pointer;
    data: pBIO; flags: integer): pPKCS7; cdecl;
 PKCS7_get_signer_info: function(p7: pPKCS7): pSTACK_OFPKCS7_SIGNER_INFO; cdecl;
 PKCS7_verify: function(p7: pPKCS7; certs: pointer; store: pSTACK_OFX509;
    indata: pBIO; _out: pBIO; flags: integer): integer; cdecl;
 PKCS7_get0_signers: function(p7: pPKCS7; certs: pSTACK_OFX509;
    flags: integer): pSTACK_OFX509; cdecl;
 PKCS7_signatureVerify: function(bio: pBIO; p7: pPKCS7; si: pPKCS7_SIGNER_INFO;
    x509: pX509): integer; cdecl;
 PKCS7_encrypt: function(certs: pSTACK_OFX509; _in: pBIO;
    cipher: pEVP_CIPHER; flags: integer): pPKCS7; cdecl;
 PKCS7_decrypt: function(p7: pPKCS7; pkey: pEVP_PKEY; cert: pX509;
    data: pBIO; flags: integer): integer; cdecl;
 PKCS7_free: procedure(p7: pPKCS7); cdecl;
 PKCS7_ctrl: function(p7: pPKCS7; cmd: integer; larg: longint;
    parg: PCharacter): longint; cdecl;
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
 PKCS8_decrypt: function(p8: pX509_SIG; Pass: PCharacter; PassLen: integer): pPKCS8_Priv_Key_Info; cdecl;
 PKCS8_PRIV_KEY_INFO_free: procedure(var a: pPKCS8_Priv_Key_Info); cdecl;
 PKCS12_new: function: pPKCS12; cdecl;
 PEM_read_bio_PKCS7: function(bp: pBIO; data: pointer; cb: TPWCallbackFunction; u: pointer): pPKCS7; cdecl;
{$ENDIF OPENSSL_PKCS}
{$IFDEF OPENSSL_MIME}
// SMIME function
 SMIME_write_PKCS7: function(bp: pBIO; p7: pPKCS7; data: pBIO; flags: integer): integer; cdecl;
 SMIME_read_PKCS7: function(bp: pBIO; var bcont: pBIO): pPKCS7; cdecl;
{$ENDIF OPENSSL_MIME}
{$IFDEF OPENSSL_AES}
 AES_set_decrypt_key: function(userKey: PCharacter; bits: integer; key: pAES_KEY): integer; cdecl;
 AES_cbc_encrypt: procedure(buffer: PCharacter; u: PCharacter; length: longint;
    key: pAES_KEY; ivec: pointer; enc: integer); cdecl;
{$ENDIF OPENSSL_AES}
{$ENDIF OPENSSL_EXT}

function SSL_set_options(ssl: PSSL; options: integer): integer;
function IsSSLloaded: Boolean;
procedure InitSSLInterface;
procedure DestroySSLInterface;

{$IFDEF OPENSSL_EXT}
// Helper: convert standard Delphi integer in big-endian integer
function int2bin(n: integer): integer;
// High level memory management function
function OPENSSL_malloc(length: longint): pointer;
function OPENSSL_realloc(address: PCharacter; length: longint): pointer;
function OPENSSL_remalloc(var address: pointer; length: longint): pointer;
procedure OPENSSL_free(address: pointer); // cdecl; ?
{$IFDEF OPENSSL_BN}  
function BN_to_montgomery(r, a: pBIGNUM; m_ctx: pBN_MONT_CTX; ctx: pBN_CTX): integer;
function BN_zero(n: pBIGNUM): integer;
function BN_one(n: pBIGNUM): integer;
function BN_num_bytes(const a: pBIGNUM): integer;
// BN_mod redefined as BN_div in some DLL version
function BN_mod(rem: pBIGNUM; const a, m: pBIGNUM; ctx: pBN_CTX): integer;
{$ENDIF OPENSSL_BN}
{$IFDEF OPEN_BIO}  
function BIO_flush(b: pBIO): integer;
function BIO_get_mem_data(b: pBIO; var pp: PCharacter): integer; cdecl;  // long ??
function BIO_get_md_ctx(bp: pBIO; mdcp: Pointer): Longint;
function BIO_reset(bp: pBIO): integer;
function BIO_eof(bp: pBIO): integer;
function BIO_set_close(bp: pBIO; c: integer): integer;
function BIO_get_close(bp: pBIO): integer;
function BIO_pending(bp: pBIO): integer;
function BIO_wpending(bp: pBIO): integer;
function BIO_read_filename(bp: pBIO; filename: PCharacter): integer;
function BIO_write_filename(bp: pBIO; filename: PCharacter): integer;
function BIO_append_filename(bp: pBIO; filename: PCharacter): integer;
function BIO_rw_filename(bp: pBIO; filename: PCharacter): integer;
{$ENDIF OPEN_BIO}
{$IFDEF OPEN_EVP}
procedure EVP_SignInit(ctx: pEVP_MD_CTX; const _type: pEVP_MD);
procedure EVP_SignUpdate(ctx: pEVP_MD_CTX; const d: Pointer; cnt: cardinal);
procedure EVP_VerifyInit(ctx: pEVP_MD_CTX; const _type: pEVP_MD);
procedure EVP_VerifyUpdate(ctx: pEVP_MD_CTX; const d: Pointer; cnt: cardinal);
function EVP_MD_size(e: pEVP_MD): integer;
function EVP_MD_CTX_size(e: pEVP_MD_CTX): integer;
{$ENDIF OPEN_EVP}
{$IFDEF OPEN_X509}
function X509_get_version(x: pX509): integer;
function X509_get_notBefore(a: pX509): pASN1_TIME;
function X509_get_notAfter(a: pX509): pASN1_TIME;
function X509_REQ_get_version(req: pX509_REQ): integer;
function X509_REQ_get_subject_name(req: pX509_REQ): pX509_NAME;
{$ENDIF OPEN_X509}
{$IFDEF OPEN_PKCS}
function PKCS7_get_detached(p7: pPKCS7): pointer;
{$ENDIF OPEN_PKCS}
{$ENDIF OPENSSL_EXT}

implementation
uses
 msesystypes,dynlibs,msesysintf1,msesysintf,msedynload;

var
 ssllibhandle: integer;
 sslutillibhandle: integer;
 sslloaded: boolean = false;
 RAND_screen: procedure; cdecl;

function SSL_set_options(ssl: PSSL; options: integer): integer;
begin
 result:= ssl_ctrl(ssl,ssl_ctrl_options,options,nil);
end;

procedure dounload;
begin
 if ssllibhandle <> 0 then begin
  freelibrary(ssllibhandle);
  ssllibhandle:= 0;
 end;
 if sslutillibhandle <> 0 then begin
  freelibrary(sslutillibhandle);
  sslutillibhandle:= 0;
 end;
end; 

type
 mutexarty = array of mutexty;
var
 locks: mutexarty;

procedure lockingcallback(mode: integer; n: integer; afile: pchar; 
                       line: integer); cdecl;
begin
 if mode and crypto_lock <> 0 then begin
  sys_mutexlock(locks[n]);
 end
 else begin
  sys_mutexunlock(locks[n]);
 end;
end;

function idcallback: integer; cdecl;
begin
 result:= sys_getcurrentthread;
end;

procedure InitSSLInterface;
var
 int1: integer;
begin
 if not IsSSLloaded then begin
  try
   ssllibhandle:= getprocaddresses(sslnames,
    [
       'SSL_get_error',
       'SSL_library_init',
       'SSL_load_error_strings',
       'SSL_CTX_set_cipher_list',
       'SSL_CTX_new',
       'SSL_CTX_free',
       'SSL_set_fd',
       'SSL_set_rfd',
       'SSL_set_wfd',       
       'SSL_set_cipher_list',
       'SSLv2_method',
       'SSLv3_method',
       'TLSv1_method',
       'SSLv23_method',
       'SSL_CTX_use_PrivateKey',
       'SSL_CTX_use_PrivateKey_ASN1',
       'SSL_CTX_use_PrivateKey_file',
       'SSL_CTX_use_RSAPrivateKey_file',
       'SSL_CTX_use_certificate',
       'SSL_CTX_use_certificate_ASN1',
       'SSL_CTX_use_certificate_file',
       'SSL_CTX_use_certificate_chain_file',
       'SSL_CTX_check_private_key',
       'SSL_CTX_set_default_passwd_cb',
       'SSL_CTX_set_default_passwd_cb_userdata',
       'SSL_CTX_load_verify_locations',
       'SSL_new',
       'SSL_free',
       'SSL_ctrl',
       'SSL_use_certificate_file',
       'SSL_use_PrivateKey_file',
       'SSL_accept',
       'SSL_connect',
       'SSL_shutdown',
       'SSL_read',
       'SSL_peek',
       'SSL_write',
       'SSL_pending',
       'SSL_get_peer_certificate',
       'SSL_get_version',
       'SSL_CTX_set_verify',
       'SSL_get_current_cipher',
       'SSL_CIPHER_get_name',
       'SSL_CIPHER_get_bits',
       'SSL_get_verify_result'
{$IFDEF OPENSSL_EXT}
      ,'SSLeay',
       'OpenSSL_add_all_ciphers',
       'OpenSSL_add_all_digests',
       'ERR_load_crypto_strings',
       'ERR_peek_error',
       'ERR_peek_last_error',
       'CRYPTO_malloc',
       'CRYPTO_realloc',
       'CRYPTO_remalloc',
       'CRYPTO_free'
{$ENDIF OPENSSL_EXT}       
    ],
    [
       @SSL_get_error,
       @SSL_library_init,
       @SSL_load_error_strings,
       @SSL_CTX_set_cipher_list,
       @SSL_CTX_new,
       @SSL_CTX_free,
       @SSL_set_fd,
       @SSL_set_rfd,
       @SSL_set_wfd,
       @SSL_set_cipher_list,
       @SSLv2_method,
       @SSLv3_method,
       @TLSv1_method,
       @SSLv23_method,
       @SSL_CTX_use_PrivateKey,
       @SSL_CTX_use_PrivateKey_ASN1,
       @SSL_CTX_use_PrivateKey_file,
       @SSL_CTX_use_RSAPrivateKey_file,
       @SSL_CTX_use_certificate,
       @SSL_CTX_use_certificate_ASN1,
       @SSL_CTX_use_certificate_file,
       @SSL_CTX_use_certificate_chain_file,
       @SSL_CTX_check_private_key,
       @SSL_CTX_set_default_passwd_cb,
       @SSL_CTX_set_default_passwd_cb_userdata,
       @SSL_CTX_load_verify_locations,
       @SSL_new,
       @SSL_free,
       @SSL_ctrl,
       @SSL_use_certificate_file,
       @SSL_use_PrivateKey_file,
       @SSL_accept,
       @SSL_connect,
       @SSL_shutdown,
       @SSL_read,
       @SSL_peek,
       @SSL_write,
       @SSL_pending,
       @SSL_get_peer_certificate,
       @SSL_get_version,
       @SSL_CTX_set_verify,
       @SSL_get_current_cipher,
       @SSL_CIPHER_get_name,
       @SSL_CIPHER_get_bits,
       @SSL_get_verify_result        
{$IFDEF OPENSSL_EXT}
      ,@SSLeay,
       @OpenSSL_add_all_ciphers,
       @OpenSSL_add_all_digests,
       @ERR_load_crypto_strings,
       @ERR_peek_error,
       @ERR_peek_last_error,
       @CRYPTO_malloc,
       @CRYPTO_realloc,
       @CRYPTO_remalloc,
       @CRYPTO_free
{$ENDIF OPENSSL_EXT}       
    ]);

   sslutillibhandle:= getprocaddresses(sslutilnames,
    [
       'X509_new',
       'X509_free',
       'X509_NAME_oneline',
       'X509_get_subject_name',
       'X509_get_issuer_name',
       'X509_NAME_hash',
       'X509_digest',
       'X509_print',
       'X509_set_version',
       'X509_set_pubkey',
       'X509_set_issuer_name',
       'X509_NAME_add_entry_by_txt',
       'X509_sign',
       'X509_gmtime_adj',
       'X509_set_notBefore',
       'X509_set_notAfter',
       'X509_get_serialNumber',
       'EVP_PKEY_new',
       'EVP_PKEY_free',
       'EVP_PKEY_assign',
       'EVP_cleanup',
       'EVP_get_digestbyname',
       'SSLeay_version',
       'ERR_error_string_n',
       'ERR_get_error',
       'ERR_clear_error',
       'ERR_free_strings',
       'ERR_remove_state',
       'OPENSSL_add_all_algorithms_noconf',
       'CRYPTO_cleanup_all_ex_data',
//        'RAND_screen',
       'BIO_new',
       'BIO_free_all',
       'BIO_s_mem',
       'BIO_ctrl_pending',
       'BIO_read',
       'BIO_write',
       'd2i_PKCS12_bio',
       'PKCS12_parse',
       'PKCS12_free',
       'RSA_generate_key',
       'ASN1_UTCTIME_new',
       'ASN1_UTCTIME_free',
       'ASN1_INTEGER_set',
       'i2d_X509_bio',
       'i2d_PrivateKey_bio',
         // 3DES functions
       'DES_set_odd_parity',
       'DES_set_key_checked',
       'DES_ecb_encrypt',
       //
       'CRYPTO_num_locks',
       'CRYPTO_set_locking_callback',
       'CRYPTO_set_id_callback'
{$IFDEF OPENSSL_EXT}
      ,'OBJ_obj2nid',
       'OBJ_txt2nid',
       'OBJ_txt2obj',
       'sk_new_null',
       'sk_free',
       'sk_push',
       'sk_num',
       'sk_value',
       'i2d_ASN1_TIME',
       'd2i_ASN1_TIME',
       'd2i_X509_REQ_bio',
       'i2d_X509_REQ_bio',
       'd2i_X509_bio',
       'd2i_PrivateKey_bio',
       'd2i_PUBKEY_bio',
       'i2d_PUBKEY_bio',
       'i2d_PKCS12_bio',
       'd2i_PKCS7',
       'd2i_PKCS7_bio',
       'i2d_PKCS7_bio',
       'd2i_PKCS8_bio',
       'd2i_PKCS8_PRIV_KEY_INFO',
       'd2i_DSAPrivateKey_bio',
       'i2d_DSAPrivateKey_bio',
       'd2i_RSAPrivateKey_bio',
       'i2d_RSAPrivateKey_bio',
       'i2a_ASN1_INTEGER',
       'a2i_ASN1_INTEGER'
{$IFDEF OPENSSL_BIGNUM}
      ,'BN_new',
       'BN_init',
       'BN_clear',
       'BN_free',
       'BN_clear_free',
       'BN_set_params',
       'BN_get_params',
       'BN_options',
       'BN_CTX_new',
       'BN_CTX_init',
       'BN_CTX_start',
       'BN_CTX_get',
       'BN_CTX_end',
       'BN_CTX_free',
       'BN_MONT_CTX_new',
       'BN_MONT_CTX_init',
       'BN_MONT_CTX_set',
       'BN_MONT_CTX_copy',
       'BN_MONT_CTX_free',
       'BN_mod_mul_montgomery',
       'BN_from_montgomery',
       'BN_RECP_CTX_init',
       'BN_RECP_CTX_set',
       'BN_RECP_CTX_new',
       'BN_RECP_CTX_free',
       'BN_div_recp',
       'BN_mod_mul_reciprocal',
       'BN_BLINDING_new',
       'BN_BLINDING_update',
       'BN_BLINDING_free',
       'BN_BLINDING_convert',
       'BN_BLINDING_invert',
       'BN_copy',
       'BN_dup',
       'BN_bn2bin',
       'BN_bin2bn',
       'BN_bn2hex',
       'BN_bn2dec',
       'BN_hex2bn',
       'BN_dec2bn',
       'BN_bn2mpi',
       'BN_mpi2bn',
       'BN_print',
       'BN_value_one',
       'BN_set_word',
       'BN_get_word',
       'BN_cmp',
       'BN_ucmp',
       'BN_num_bits',
       'BN_num_bits_word',
       'BN_add',
       'BN_sub',
       'BN_uadd',
       'BN_usub',
       'BN_mul',
       'BN_sqr',
       'BN_div',
       'BN_exp',
       'BN_mod_exp',
       'BN_gcd',
       'BN_nnmod',
       'BN_mod_add',
       'BN_mod_sub',
       'BN_mod_mul',
       'BN_mod_sqr',
       'BN_reciprocal',
       'BN_mod_exp2_mont',
       'BN_mod_exp_mont',
       'BN_mod_exp_mont_word',
       'BN_mod_exp_simple',
       'BN_mod_exp_recp',
       'BN_mod_inverse',
       'BN_add_word',
       'BN_sub_word',
       'BN_mul_word',
       'BN_div_word',
       'BN_mod_word',
       'bn_mul_words',
       'bn_mul_add_words',
       'bn_sqr_words',
       'bn_div_words',
       'bn_add_words',
       'bn_sub_words',
       'bn_expand2',
       'BN_set_bit',
       'BN_clear_bit',
       'BN_is_bit_set',
       'BN_mask_bits',
       'BN_lshift',
       'BN_lshift1',
       'BN_rshift',
       'BN_rshift1',
       'BN_generate_prime',
       'BN_is_prime',
       'BN_is_prime_fasttest',
       'BN_rand: function',
       'BN_pseudo_rand',
       'BN_rand_range',
       'BN_pseudo_rand_range',
       'BN_bntest_rand',
       'BN_to_ASN1_INTEGER',
       'BN_to_ASN1_ENUMERATED'
{$ENDIF OPENSSL_BIGNUM}
{$IFDEF OPENSSL_ASN1}
      ,'ASN1_IA5STRING_new',
       'ASN1_INTEGER_free',
       'ASN1_INTEGER_get',
       'ASN1_STRING_set_default_mask',
       'ASN1_STRING_get_default_mask',
       'ASN1_TIME_print'
{$ENDIF OPENSSL_ASN1}
{$IFDEF OPENSSL_BIO}
      ,'BIO_new_file',
       'BIO_set',
       'BIO_free',
       'BIO_vfree',
       'BIO_push',
       'BIO_pop',
       'BIO_ctrl',
       'BIO_gets',
       'BIO_puts',
       'BIO_f_base64',
       'BIO_set_mem_eof_return',
       'BIO_set_mem_buf',
       'BIO_get_mem_ptr',
       'BIO_new_mem_buf',
       'BIO_s_file'
{$ENDIF OPENSSL_BIO}
{$IFDEF OPENSSL_EVP}
      ,'EVP_md_null',
       'EVP_md2',
       'EVP_md5',
       'EVP_sha',
       'EVP_sha1',
       'EVP_dss',
       'EVP_dss1',
       'EVP_mdc2',
       'EVP_ripemd160',
       'EVP_DigestInit',
       'EVP_DigestUpdate',
       'EVP_DigestFinal',
       'EVP_SignFinal',
       'EVP_VerifyFinal',
       'EVP_MD_CTX_copy',
       'EVP_enc_null',
       'EVP_des_ecb',
       'EVP_des_ede',
       'EVP_des_ede3',
       'EVP_des_cfb',
       'EVP_des_ede_cfb',
       'EVP_des_ede3_cfb',
       'EVP_des_ofb',
       'EVP_des_ede_ofb',
       'EVP_des_ede3_ofb',
       'EVP_des_cbc',
       'EVP_des_ede_cbc',
       'EVP_des_ede3_cbc',
       'EVP_desx_cbc',
       'EVP_idea_cbc',
       'EVP_idea_cfb',
       'EVP_idea_ecb',
       'EVP_idea_ofb',
       'EVP_get_cipherbyname',
       'EVP_PKEY_type',
       'EVP_PKEY_assign_RSA',
       'EVP_PKEY_assign_DSA',
       'EVP_PKEY_assign_DH',
       'EVP_PKEY_assign_EC_KEY',
       'EVP_PKEY_set1_RSA',
       'EVP_PKEY_set1_DSA',
       'EVP_PKEY_set1_DH',
       'EVP_PKEY_set1_EC_KEY',
       'EVP_PKEY_size',
       'EVP_PKEY_get1_RSA',
       'EVP_PKEY_get1_DSA',
       'EVP_PKEY_get1_DH',
       'EVP_PKEY_get1_EC_KEY',
       'EVP_set_pw_prompt',
       'EVP_get_pw_prompt',
       'EVP_read_pw_string'
{$ENDIF OPENSSL_EVP}
{$IFDEF OPENSSL_RAND}
      ,'RAND_seed',
       'RAND_add',
       'RAND_status',
       'RAND_file_name',
       'RAND_load_file',
       'RAND_write_file'
{$ENDIF OPENSSL_RAND}
{$IFDEF OPENSSL_RSA}
      ,'RSA_new',
       'RSA_free',
       'RSA_new_method',
       'RSA_size',
       'RSA_check_key',
       'RSA_public_encrypt',
       'RSA_private_encrypt',
       'RSA_public_decrypt',
       'RSA_private_decrypt',
       'RSA_flags',
       'RSA_set_default_method',
       'RSA_get_default_method',
       'RSA_get_method',
       'RSA_set_method',
       'RSA_memory_lock',
       'RSA_PKCS1_SSLeay',
       'ERR_load_RSA_strings'
{$ENDIF OPENSSL_RSA}
{$IFDEF OPENSSL_DSA}
      ,'DSA_new',
       'DSA_free',
       'DSA_generate_parameters',
       'DSA_generate_key'
{$ENDIF OPENSSL_DSA}
{$IFDEF OPENSSL_X509}
      ,'X509_NAME_new',
       'X509_NAME_free',
       'X509_NAME_get_entry',
       'X509_NAME_get_text_by_NID',
       'X509_load_cert_file',
       'X509_get1_email',
       'X509_get_pubkey',
       'X509_check_private_key',
       'X509_check_purpose',
       'X509_issuer_and_serial_cmp',
       'X509_issuer_and_serial_hash',
       'X509_verify_cert',
       'X509_verify_cert_error_string',
       'X509_email_free',
       'X509_get_ext',
       'X509_get_ext_by_NID',
       'X509_get_ext_d2i',
       'X509V3_EXT_d2i',
       'X509V3_EXT_i2d',
       'X509V3_EXT_conf_nid',
       'X509_set_subject_name',
       'X509V3_set_ctx',
       'X509_SIG_free',
       'X509_PUBKEY_get',
       'X509_REQ_new',
       'X509_REQ_free',
       'X509_REQ_set_version',
       'X509_REQ_set_subject_name',
       'X509_REQ_add1_attr_by_txt',
       'X509_REQ_add_extensions',
       'X509_REQ_set_pubkey',
       'X509_REQ_get_pubkey',
       'X509_REQ_sign',
       'X509_STORE_new',
       'X509_STORE_free',
       'X509_STORE_add_cert',
       'X509_STORE_add_lookup',
       'X509_STORE_CTX_new',
       'X509_STORE_CTX_free',
       'X509_STORE_CTX_init',
       'X509_STORE_CTX_get_current_cert',
       'X509_STORE_CTX_get_error',
       'X509_STORE_CTX_get_error_depth',
       'X509_LOOKUP_new',
       'X509_LOOKUP_init',
       'X509_LOOKUP_free',
       'X509_LOOKUP_ctrl',
       'X509_LOOKUP_file'
{$ENDIF OPENSSL_X509}
{$IFDEF OPENSSL_PEM}
      ,'PEM_read_bio_RSAPrivateKey',
       'PEM_write_bio_RSAPrivateKey',
       'PEM_read_bio_RSAPublicKey',
       'PEM_write_bio_RSAPublicKey',
       'PEM_read_bio_DSAPrivateKey',
       'PEM_write_bio_DSAPrivateKey',
       'PEM_read_bio_PUBKEY',
       'PEM_write_bio_PUBKEY',
       'PEM_read_bio_X509',
       'PEM_write_bio_X509',
       'PEM_read_bio_X509_AUX',
       'PEM_write_bio_X509_AUX',
       'PEM_read_bio_X509_REQ',
       'PEM_write_bio_X509_REQ',
       'PEM_read_bio_X509_CRL',
       'PEM_write_bio_X509_CRL',
       'PEM_read_bio_PrivateKey',
       'PEM_write_bio_PrivateKey',
       'PEM_write_bio_PKCS7'
{$ENDIF OPENSSL_PEM}
{$IFDEF OPENSSL_PKCS}
      ,'PKCS5_PBKDF2_HMAC_SHA1',
       'PKCS7_sign',
       'PKCS7_get_signer_info',
       'PKCS7_verify',
       'PKCS7_get0_signers',
       'PKCS7_signatureVerify',
       'PKCS7_encrypt',
       'PKCS7_decrypt',
       'PKCS7_free',
       'PKCS7_ctrl',
       'PKCS7_dataInit',
       'EVP_PKCS82PKEY',
       'PKCS8_decrypt',
       'PKCS8_PRIV_KEY_INFO_free',
       'PKCS12_new',
       'PEM_read_bio_PKCS7'
{$ENDIF OPENSSL_PKCS}
{$IFDEF OPENSSL_MIME}
      ,'SMIME_write_PKCS7',
       'SMIME_read_PKCS7'
{$ENDIF OPENSSL_MIME}
{$IFDEF OPENSSL_AES}
      ,'AES_set_decrypt_key',
       'AES_cbc_encrypt'
{$ENDIF OPENSSL_AES}
{$ENDIF OPENSSL_EXT}
    ], 
    [
       @X509_new,
       @X509_free,
       @X509_NAME_oneline,
       @X509_get_subject_name,
       @X509_get_issuer_name,
       @X509_NAME_hash,
       @X509_digest,
       @X509_print,
       @X509_set_version,
       @X509_set_pubkey,
       @X509_set_issuer_name,
       @X509_NAME_add_entry_by_txt,
       @X509_sign,
       @X509_gmtime_adj,
       @X509_set_notBefore,
       @X509_set_notAfter,
       @X509_get_serialNumber,
       @EVP_PKEY_new,
       @EVP_PKEY_free,
       @EVP_PKEY_assign,
       @EVP_cleanup,
       @EVP_get_digestbyname,
       @SSLeay_version,
       @ERR_error_string_n,
       @ERR_get_error,
       @ERR_clear_error,
       @ERR_free_strings,
       @ERR_remove_state,
       @OPENSSL_add_all_algorithms_noconf,
       @CRYPTO_cleanup_all_ex_data,
//        @RAND_screen,
       @BIO_new,
       @BIO_free_all,
       @BIO_s_mem,
       @BIO_ctrl_pending,
       @BIO_read,
       @BIO_write,
       @d2i_PKCS12_bio,
       @PKCS12_parse,
       @PKCS12_free,
       @RSA_generate_key,
       @ASN1_UTCTIME_new,
       @ASN1_UTCTIME_free,
       @ASN1_INTEGER_set,
       @i2d_X509_bio,
       @i2d_PrivateKey_bio,
         // 3DES functions
       @DES_set_odd_parity,
       @DES_set_key_checked,
       @DES_ecb_encrypt,
       //
       @CRYPTO_num_locks,
       @CRYPTO_set_locking_callback,
       @CRYPTO_set_id_callback
{$IFDEF OPENSSL_EXT}
      ,@OBJ_obj2nid,
       @OBJ_txt2nid,
       @OBJ_txt2obj,
       @sk_new_null,
       @sk_free,
       @sk_push,
       @sk_num,
       @sk_value,
       @i2d_ASN1_TIME,
       @d2i_ASN1_TIME,
       @d2i_X509_REQ_bio,
       @i2d_X509_REQ_bio,
       @d2i_X509_bio,
       @d2i_PrivateKey_bio,
       @d2i_PUBKEY_bio,
       @i2d_PUBKEY_bio,
       @i2d_PKCS12_bio,
       @d2i_PKCS7,
       @d2i_PKCS7_bio,
       @i2d_PKCS7_bio,
       @d2i_PKCS8_bio,
       @d2i_PKCS8_PRIV_KEY_INFO,
       @d2i_DSAPrivateKey_bio,
       @i2d_DSAPrivateKey_bio,
       @d2i_RSAPrivateKey_bio,
       @i2d_RSAPrivateKey_bio,
       @i2a_ASN1_INTEGER,
       @a2i_ASN1_INTEGER
{$IFDEF OPENSSL_BIGNUM}
      ,@BN_new,
       @BN_init,
       @BN_clear,
       @BN_free,
       @BN_clear_free,
       @BN_set_params,
       @BN_get_params,
       @BN_options,
       @BN_CTX_new,
       @BN_CTX_init,
       @BN_CTX_start,
       @BN_CTX_get,
       @BN_CTX_end,
       @BN_CTX_free,
       @BN_MONT_CTX_new,
       @BN_MONT_CTX_init,
       @BN_MONT_CTX_set,
       @BN_MONT_CTX_copy,
       @BN_MONT_CTX_free,
       @BN_mod_mul_montgomery,
       @BN_from_montgomery,
       @BN_RECP_CTX_init,
       @BN_RECP_CTX_set,
       @BN_RECP_CTX_new,
       @BN_RECP_CTX_free,
       @BN_div_recp,
       @BN_mod_mul_reciprocal,
       @BN_BLINDING_new,
       @BN_BLINDING_update,
       @BN_BLINDING_free,
       @BN_BLINDING_convert,
       @BN_BLINDING_invert,
       @BN_copy,
       @BN_dup,
       @BN_bn2bin,
       @BN_bin2bn,
       @BN_bn2hex,
       @BN_bn2dec,
       @BN_hex2bn,
       @BN_dec2bn,
       @BN_bn2mpi,
       @BN_mpi2bn,
       @BN_print,
       @BN_value_one,
       @BN_set_word,
       @BN_get_word,
       @BN_cmp,
       @BN_ucmp,
       @BN_num_bits,
       @BN_num_bits_word,
       @BN_add,
       @BN_sub,
       @BN_uadd,
       @BN_usub,
       @BN_mul,
       @BN_sqr,
       @BN_div,
       @BN_exp,
       @BN_mod_exp,
       @BN_gcd,
       @BN_nnmod,
       @BN_mod_add,
       @BN_mod_sub,
       @BN_mod_mul,
       @BN_mod_sqr,
       @BN_reciprocal,
       @BN_mod_exp2_mont,
       @BN_mod_exp_mont,
       @BN_mod_exp_mont_word,
       @BN_mod_exp_simple,
       @BN_mod_exp_recp,
       @BN_mod_inverse,
       @BN_add_word,
       @BN_sub_word,
       @BN_mul_word,
       @BN_div_word,
       @BN_mod_word,
       @bn_mul_words,
       @bn_mul_add_words,
       @bn_sqr_words,
       @bn_div_words,
       @bn_add_words,
       @bn_sub_words,
       @bn_expand2,
       @BN_set_bit,
       @BN_clear_bit,
       @BN_is_bit_set,
       @BN_mask_bits,
       @BN_lshift,
       @BN_lshift1,
       @BN_rshift,
       @BN_rshift1,
       @BN_generate_prime,
       @BN_is_prime,
       @BN_is_prime_fasttest,
       @BN_rand,
       @BN_pseudo_rand,
       @BN_rand_range,
       @BN_pseudo_rand_range,
       @BN_bntest_rand,
       @BN_to_ASN1_INTEGER,
       @BN_to_ASN1_ENUMERATED
{$ENDIF OPENSSL_BIGNUM}
{$IFDEF OPENSSL_ASN1}
      ,@ASN1_IA5STRING_new,
       @ASN1_INTEGER_free,
       @ASN1_INTEGER_get,
       @ASN1_STRING_set_default_mask,
       @ASN1_STRING_get_default_mask,
       @ASN1_TIME_print
{$ENDIF OPENSSL_ASN1}
{$IFDEF OPENSSL_BIO}
      ,@BIO_new_file,
       @BIO_set,
       @BIO_free,
       @BIO_vfree,
       @BIO_push,
       @BIO_pop,
       @BIO_ctrl,
       @BIO_gets,
       @BIO_puts,
       @BIO_f_base64,
       @BIO_set_mem_eof_return,
       @BIO_set_mem_buf,
       @BIO_get_mem_ptr,
       @BIO_new_mem_buf,
       @BIO_s_file
{$ENDIF OPENSSL_BIO}
{$IFDEF OPENSSL_EVP}
      ,@EVP_md_null,
       @EVP_md2,
       @EVP_md5,
       @EVP_sha,
       @EVP_sha1,
       @EVP_dss,
       @EVP_dss1,
       @EVP_mdc2,
       @EVP_ripemd160,
       @EVP_DigestInit,
       @EVP_DigestUpdate,
       @EVP_DigestFinal,
       @EVP_SignFinal,
       @EVP_VerifyFinal,
       @EVP_MD_CTX_copy,
       @EVP_enc_null,
       @EVP_des_ecb,
       @EVP_des_ede,
       @EVP_des_ede3,
       @EVP_des_cfb,
       @EVP_des_ede_cfb,
       @EVP_des_ede3_cfb,
       @EVP_des_ofb,
       @EVP_des_ede_ofb,
       @EVP_des_ede3_ofb,
       @EVP_des_cbc,
       @EVP_des_ede_cbc,
       @EVP_des_ede3_cbc,
       @EVP_desx_cbc,
       @EVP_idea_cbc,
       @EVP_idea_cfb,
       @EVP_idea_ecb,
       @EVP_idea_ofb,
       @EVP_get_cipherbyname,
       @EVP_PKEY_type,
       @EVP_PKEY_assign_RSA,
       @EVP_PKEY_assign_DSA,
       @EVP_PKEY_assign_DH,
       @EVP_PKEY_assign_EC_KEY,
       @EVP_PKEY_set1_RSA,
       @EVP_PKEY_set1_DSA,
       @EVP_PKEY_set1_DH,
       @EVP_PKEY_set1_EC_KEY,
       @EVP_PKEY_size,
       @EVP_PKEY_get1_RSA,
       @EVP_PKEY_get1_DSA,
       @EVP_PKEY_get1_DH,
       @EVP_PKEY_get1_EC_KEY,
       @EVP_set_pw_prompt,
       @EVP_get_pw_prompt,
       @EVP_read_pw_string
{$ENDIF OPENSSL_EVP}
{$IFDEF OPENSSL_RAND}
      ,@RAND_seed,
       @RAND_add,
       @RAND_status,
       @RAND_file_name,
       @RAND_load_file,
       @RAND_write_file
{$ENDIF OPENSSL_RAND}
{$IFDEF OPENSSL_RSA}
      ,@RSA_new,
       @RSA_free,
       @RSA_new_method,
       @RSA_size,
       @RSA_check_key,
       @RSA_public_encrypt,
       @RSA_private_encrypt,
       @RSA_public_decrypt,
       @RSA_private_decrypt,
       @RSA_flags,
       @RSA_set_default_method,
       @RSA_get_default_method,
       @RSA_get_method,
       @RSA_set_method,
       @RSA_memory_lock,
       @RSA_PKCS1_SSLeay,
       @ERR_load_RSA_strings
{$ENDIF OPENSSL_RSA}
{$IFDEF OPENSSL_DSA}
      ,@DSA_new,
       @DSA_free,
       @DSA_generate_parameters,
       @DSA_generate_key
{$ENDIF OPENSSL_DSA}
{$IFDEF OPENSSL_X509}
      ,@X509_NAME_new,
       @X509_NAME_free,
       @X509_NAME_get_entry,
       @X509_NAME_get_text_by_NID,
       @X509_load_cert_file,
       @X509_get1_email,
       @X509_get_pubkey,
       @X509_check_private_key,
       @X509_check_purpose,
       @X509_issuer_and_serial_cmp,
       @X509_issuer_and_serial_hash,
       @X509_verify_cert,
       @X509_verify_cert_error_string,
       @X509_email_free,
       @X509_get_ext,
       @X509_get_ext_by_NID,
       @X509_get_ext_d2i,
       @X509V3_EXT_d2i,
       @X509V3_EXT_i2d,
       @X509V3_EXT_conf_nid,
       @X509_set_subject_name,
       @X509V3_set_ctx,
       @X509_SIG_free,
       @X509_PUBKEY_get,
       @X509_REQ_new,
       @X509_REQ_free,
       @X509_REQ_set_version,
       @X509_REQ_set_subject_name,
       @X509_REQ_add1_attr_by_txt,
       @X509_REQ_add_extensions,
       @X509_REQ_set_pubkey,
       @X509_REQ_get_pubkey,
       @X509_REQ_sign,
       @X509_STORE_new,
       @X509_STORE_free,
       @X509_STORE_add_cert,
       @X509_STORE_add_lookup,
       @X509_STORE_CTX_new,
       @X509_STORE_CTX_free,
       @X509_STORE_CTX_init,
       @X509_STORE_CTX_get_current_cert,
       @X509_STORE_CTX_get_error,
       @X509_STORE_CTX_get_error_depth,
       @X509_LOOKUP_new,
       @X509_LOOKUP_init,
       @X509_LOOKUP_free,
       @X509_LOOKUP_ctrl,
       @X509_LOOKUP_file
{$ENDIF OPENSSL_X509}
{$IFDEF OPENSSL_PEM}
      ,@PEM_read_bio_RSAPrivateKey,
       @PEM_write_bio_RSAPrivateKey,
       @PEM_read_bio_RSAPublicKey,
       @PEM_write_bio_RSAPublicKey,
       @PEM_read_bio_DSAPrivateKey,
       @PEM_write_bio_DSAPrivateKey,
       @PEM_read_bio_PUBKEY,
       @PEM_write_bio_PUBKEY,
       @PEM_read_bio_X509,
       @PEM_write_bio_X509,
       @PEM_read_bio_X509_AUX,
       @PEM_write_bio_X509_AUX,
       @PEM_read_bio_X509_REQ,
       @PEM_write_bio_X509_REQ,
       @PEM_read_bio_X509_CRL,
       @PEM_write_bio_X509_CRL,
       @PEM_read_bio_PrivateKey,
       @PEM_write_bio_PrivateKey,
       @PEM_write_bio_PKCS7
{$ENDIF OPENSSL_PEM}
{$IFDEF OPENSSL_PKCS}
      ,@PKCS5_PBKDF2_HMAC_SHA1,
       @PKCS7_sign,
       @PKCS7_get_signer_info,
       @PKCS7_verify,
       @PKCS7_get0_signers,
       @PKCS7_signatureVerify,
       @PKCS7_encrypt,
       @PKCS7_decrypt,
       @PKCS7_free,
       @PKCS7_ctrl,
       @PKCS7_dataInit,
       @EVP_PKCS82PKEY,
       @PKCS8_decrypt,
       @PKCS8_PRIV_KEY_INFO_free,
       @PKCS12_new,
       @PEM_read_bio_PKCS7
{$ENDIF OPENSSL_PKCS}
{$IFDEF OPENSSL_MIME}
      ,@SMIME_write_PKCS7,
       @SMIME_read_PKCS7
{$ENDIF OPENSSL_MIME}
{$IFDEF OPENSSL_AES}
      ,@AES_set_decrypt_key,
       @AES_cbc_encrypt
{$ENDIF OPENSSL_AES}
{$ENDIF OPENSSL_EXT}
    ]);
     
   //init library
   Ssl_Library_Init;
   Ssl_Load_Error_Strings;
   OPENSSL_add_all_algorithms_noconf;
   pointer(rand_screen):= getprocedureaddress(sslutillibhandle,'RAND_screen');
   if assigned(rand_screen) then begin
    Rand_Screen; //windows, todo: better random
   end;
   setlength(locks,crypto_num_locks());
   for int1:= 0 to high(locks) do begin
    sys_mutexcreate(locks[int1]);
   end;
   crypto_set_locking_callback(@lockingcallback);
   crypto_set_id_callback(@idcallback);
   SSLloaded := True;
  except
   dounload;
   raise;
  end;
 end;
end;

procedure destroysslinterface;
var
 int1: integer;
begin
 if issslloaded then begin
      //deinit library
  evp_cleanup;
  crypto_cleanup_all_ex_data;
  err_remove_state(0);
  for int1:= 0 to high(locks) do begin
   sys_mutexdestroy(locks[int1]);
  end;
  locks:= nil;
 end;
 sslloaded := false;
 dounload;
end;

function issslloaded: boolean;
begin
 result:= sslloaded;
end;

{$IFDEF OPENSSL_EXT}

function int2bin(n: integer): integer;
begin
   result := ((cardinal(n) shr 24) and $000000FF) or
       ((cardinal(n) shr 8) and $0000FF00) or
        ((cardinal(n) shl 8) and $00FF0000) or
        ((cardinal(n) shl 24) and $FF000000);
end;

function OPENSSL_malloc(length: longint): pointer;
begin
  OPENSSL_malloc := CRYPTO_malloc(length, nil, 0);
end;

function OPENSSL_realloc(address: PCharacter; length: longint): pointer;
begin
  OPENSSL_realloc := CRYPTO_realloc(address, length, nil, 0);
end;

function OPENSSL_remalloc(var address: pointer; length: longint): pointer;
begin
  OPENSSL_remalloc := CRYPTO_remalloc(address, length, nil, 0);
end;

procedure OPENSSL_free(address: pointer);
begin
  CRYPTO_free(address);
end;

{$IFDEF OPENSSL_BIGNUM}
function BN_to_montgomery(r, a: pBIGNUM; m_ctx: pBN_MONT_CTX; ctx: pBN_CTX): integer;
begin
  result := BN_mod_mul_montgomery(r, a, @(m_ctx^.RR), m_ctx, ctx);
end;

function BN_zero(n: pBIGNUM): integer;
begin
  result := BN_set_word(n, 0)
end;

function BN_one(n: pBIGNUM): integer;
begin
  result := BN_set_word(n, 1)
end;

function BN_num_bytes(const a: pBIGNUM): integer;
begin
  result := (BN_num_bits(a) + 7) div 8;
end;

function BN_mod(rem: pBIGNUM; const a, m: pBIGNUM; ctx: pBN_CTX): integer;
begin
  result := BN_div(nil, rem, a, m, ctx);
end;
{$ENDIF OPENSSL_BIGNUM}

{$IFDEF OPENSSL_BIO}
function BIO_flush(b: pBIO): integer;
begin
  result := BIO_ctrl(b, BIO_CTRL_FLUSH, 0, nil);
end;

function BIO_get_mem_data(b: pBIO; var pp: PCharacter): integer; cdecl;
begin
  result := BIO_ctrl(b, BIO_CTRL_INFO, 0, @pp);
end;

function BIO_get_md_ctx(bp: pBIO; mdcp: Pointer): Longint;
begin
  result := BIO_ctrl(bp, BIO_C_GET_MD_CTX, 0, mdcp);
end;

function BIO_reset(bp: pBIO): integer;
begin
  result := BIO_ctrl(bp, BIO_CTRL_RESET, 0, nil);
end;

function BIO_eof(bp: pBIO): integer;
begin
  result := BIO_ctrl(bp, BIO_CTRL_EOF, 0, nil);
end;

function BIO_set_close(bp: pBIO; c: integer): integer;
begin
  result := BIO_ctrl(bp, BIO_CTRL_SET_CLOSE, c, nil);
end;

function BIO_get_close(bp: pBIO): integer;
begin
  result := BIO_ctrl(bp, BIO_CTRL_GET_CLOSE, 0, nil);
end;

function BIO_pending(bp: pBIO): integer;
begin
  result := BIO_ctrl(bp, BIO_CTRL_PENDING_C, 0, nil);
end;

function BIO_wpending(bp: pBIO): integer;
begin
  result := BIO_ctrl(bp, BIO_CTRL_WPENDING, 0, nil);
end;

function BIO_read_filename(bp: pBIO; filename: PCharacter): integer;
begin
  result := BIO_ctrl(bp, BIO_C_SET_FILENAME, BIO_CLOSE or BIO_FP_READ, filename);
end;

function BIO_write_filename(bp: pBIO; filename: PCharacter): integer;
begin
  result := BIO_ctrl(bp, BIO_C_SET_FILENAME, BIO_CLOSE or BIO_FP_WRITE, filename);
end;

function BIO_append_filename(bp: pBIO; filename: PCharacter): integer;
begin
  result := BIO_ctrl(bp, BIO_C_SET_FILENAME, BIO_CLOSE or BIO_FP_APPEND, filename);
end;

function BIO_rw_filename(bp: pBIO; filename: PCharacter): integer;
begin
  result := BIO_ctrl(bp, BIO_C_SET_FILENAME, BIO_CLOSE or BIO_FP_READ or BIO_FP_WRITE, filename);
end;
{$ENDIF OPENSSL_BIO}

{$IFDEF OPENSSL_EVP}
procedure EVP_SignInit(ctx: pEVP_MD_CTX; const _type: pEVP_MD);
begin
  EVP_DigestInit(ctx, _type);
end;

procedure EVP_SignUpdate(ctx: pEVP_MD_CTX; const d: Pointer; cnt: cardinal);
begin
  EVP_DigestUpdate(ctx, d, cnt);
end;

procedure EVP_VerifyInit(ctx: pEVP_MD_CTX; const _type: pEVP_MD);
begin
  EVP_DigestInit(ctx, _type);
end;

procedure EVP_VerifyUpdate(ctx: pEVP_MD_CTX; const d: Pointer; cnt: cardinal);
begin
  EVP_DigestUpdate(ctx, d, cnt);
end;

function EVP_MD_size(e: pEVP_MD): integer;
begin
  result := e^.md_size;
end;

function EVP_MD_CTX_size(e: pEVP_MD_CTX): integer;
begin
  result := EVP_MD_size(e^.digest);
end;
{$ENDIF OPENSSL_EVP}

{$IFDEF OPENSSL_X509}
function X509_get_version(x: pX509): integer;
begin
  result := ASN1_INTEGER_get(x^.cert_info^.version);
end;

function X509_get_notBefore(a: pX509): pASN1_TIME;
begin
  result := a^.cert_info^.validity^.notBefore;
end;

function X509_get_notAfter(a: pX509): pASN1_TIME;
begin
  result := a^.cert_info^.validity^.notAfter;
end;

function X509_REQ_get_version(req: pX509_REQ): integer;
begin
  result := ASN1_INTEGER_get(req^.req_info^.version);
end;

function X509_REQ_get_subject_name(req: pX509_REQ): pX509_NAME;
begin
  result := req^.req_info^.subject;
end;
{$ENDIF OPENSSL_X509}

{$IFDEF OPENSSL_PKCS}
function PKCS7_get_detached(p7: pPKCS7): pointer;
begin
  result := pointer(PKCS7_ctrl(p7, 2, 0, nil));
end;
{$ENDIF OPENSSL_PKCS}

{$ENDIF OPENSSL_EXT}

finalization
 destroysslinterface;
end.
