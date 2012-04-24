{ MSEgui Copyright (c) 2007-2012 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseopensslx509;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseopenssl,msectypes;
 
type
 pEVP_PKEY = SslPtr; //todo
 pASN1_OBJECT = SslPtr;
 pASN1_STRING = SslPtr;
 pASN1_TIME = SslPtr;

const
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

type 
  pX509_NAME_ENTRY = ^X509_NAME_ENTRY;
  X509_NAME_ENTRY = record
    obj: pASN1_OBJECT;
    value: pASN1_STRING;
	_set: cint;
	size: cint; // temp variable
    end;

  pX509_NAME = ^X509_NAME;
  pDN = ^X509_NAME;
  X509_NAME = record
    entries: pointer;
    modified: cint;
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

  pX509 = ^X509;
  X509 = record
    cert_info: pX509_CINF;
    sig_alg: pointer;  // ^X509_ALGOR
    signature: pointer;  // ^ASN1_BIT_STRING
    valid: cint;
    references: cint;
    name: PCharacter;
    ex_data: CRYPTO_EX_DATA;
    ex_pathlen: cint;
    ex_flags: cint;
    ex_kusage: cint;
    ex_xkusage: cint;
    ex_nscert: cint;
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
	length: cint;
	version: pointer;
	subject: pX509_NAME;
	pubkey: pointer;
	attributes: pointer;
	req_kludge: cint;
  end;
  X509_REQ = record
	req_info: pX509_REQ_INFO;
	sig_alg: pointer;
	signature: pointer;
	references: cint;
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
  TCertificateVerifyFunction = function(ok: cint; ctx: pX509_STORE_CTX): cint; cdecl;
  
  pSTACK_OFX509 = pointer;
  pX509_STORE = ^X509_STORE;
  pX509_LOOKUP = pointer;
  pSTACK_OF509LOOKUP = pointer;
  pX509_LOOKUP_METHOD = pointer;
  X509_STORE = record
    cache: cint;
    objs: pSTACK_OFX509;
    get_cert_methods: pSTACK_OF509LOOKUP;
    verify: pointer;  // function called to verify a certificate
    verify_cb: TCertificateVerifyFunction;
    ex_data: pointer;
    references: cint;
    depth: cint;
  end;

var
  X509_new: function(): PX509; cdecl;
  X509_free: procedure(x: PX509); cdecl;
  X509_NAME_oneline: function(a: PX509_NAME; 
                 buf: pchar; size: cint): pchar; cdecl;
  X509_Get_Subject_Name: function(a: PX509):PX509_NAME; cdecl;
  X509_Get_Issuer_Name: function(a: PX509):PX509_NAME; cdecl;
  X509_NAME_hash: function(x: PX509_NAME):longword; cdecl;
//  function SSL_X509Digest(data: PX509; _type: PEVP_MD; md: PChar;
//                len: Pcint):cint; cdecl;
  X509_digest: function(data: PX509; _type: PEVP_MD; md: pchar;
                   len: pcint):cint; cdecl;
  X509_print: function(b: PBIO; a: PX509): cint; cdecl;
  X509_set_version: function(x: PX509; version: cint): cint; cdecl;
  X509_set_pubkey: function(x: PX509; pkey: pEVP_PKEY): cint; cdecl;
  X509_set_issuer_name: function(x: PX509; name: PX509_NAME): cint; cdecl;
  X509_NAME_add_entry_by_txt: function(name: PX509_NAME; field: pchar;
    _type: cint; bytes: pbyte; len, loc, _set: cint): cint; cdecl;
  X509_sign: function(x: PX509; pkey: pEVP_PKEY; const md: PEVP_MD): cint; cdecl;
  X509_gmtime_adj: function(s: PASN1_UTCTIME; adj: cint): PASN1_UTCTIME; cdecl;
  X509_set_NotBefore: function(x: PX509; tm: PASN1_UTCTIME): cint; cdecl;
  X509_set_NotAfter: function(x: PX509; tm: PASN1_UTCTIME): cint; cdecl;
  X509_get_serialNumber: function(x: PX509): PASN1_INTEGER; cdecl;

// X.509 names (DN)
 X509_NAME_new: function: pX509_NAME; cdecl;
 X509_NAME_free: procedure(x:pX509_NAME) cdecl;
 X509_NAME_get_entry: function(name: pX509_NAME;
                                      loc: cint): pX509_NAME_ENTRY; cdecl;
 X509_NAME_get_text_by_NID: function(name: pX509_NAME; nid: cint;
                                      buf: PCharacter; len: cint): cint; cdecl;
// X.509 function
 X509_load_cert_file: function(ctx: pX509_LOOKUP;
                         const filename: PCharacter; _type: cint): cint; cdecl;
 X509_get1_email: function(x: pX509): pSTACK; cdecl;
 X509_get_pubkey: function(a: pX509): pEVP_PKEY; cdecl;
 X509_check_private_key: function(x509: pX509; pkey: pEVP_PKEY): cint; cdecl;
 X509_check_purpose: function(x: pX509; id: cint; ca: cint): cint; cdecl;
 X509_issuer_and_serial_cmp: function(a: pX509; b: pX509): cint; cdecl;
 X509_issuer_and_serial_hash: function(a: pX509): cardinal; cdecl;
 X509_verify_cert: function(ctx: pX509_STORE_CTX): cint; cdecl;
 X509_verify_cert_error_string: function(n: clong): PCharacter; cdecl;
 X509_email_free: procedure(sk: pSTACK); cdecl;
 X509_get_ext: function(x: pX509; loc: cint): pX509_EXTENSION; cdecl;
 X509_get_ext_by_NID: function(x: pX509; nid, lastpos: cint): cint; cdecl;
 X509_get_ext_d2i: function(x: pX509; nid: cint;
                                         var crit, idx: cint): pointer; cdecl;
 X509V3_EXT_d2i: function(ext: pX509_EXTENSION): pointer; cdecl;
 X509V3_EXT_i2d: function(ext_nid: cint; crit: cint; ext_struc: pointer):
    pX509_EXTENSION; cdecl;
 X509V3_EXT_conf_nid: function(conf: pointer; ctx: pointer;
    ext_nid: cint; value: PCharacter): pX509_EXTENSION; cdecl;
 X509_set_subject_name: function(x: pX509; name: pX509_NAME): cint; cdecl;
 X509V3_set_ctx: procedure(ctx: pX509V3_CTX; issuer: pX509; 
                 subject: pX509; req: pX509_REQ; crl: pX509_CRL; flags: cint);
 X509_SIG_free: procedure(a: pX509_SIG); cdecl;
 X509_PUBKEY_get: function(key: pointer): pEVP_PKEY; cdecl;
 X509_REQ_new: function: pX509_REQ; cdecl;
 X509_REQ_free: procedure(req: pX509_REQ); cdecl;
 X509_REQ_set_version: function(req: pX509_REQ; version: clong): cint; cdecl;
 X509_REQ_set_subject_name: function(req: pX509_REQ;
                                               name: pX509_NAME): cint; cdecl;
 X509_REQ_add1_attr_by_txt: function(req: pX509_REQ; attrname: PCharacter; 
                       asn1_type: cint; bytes: pointer; len: cint): cint; cdecl;
 X509_REQ_add_extensions: function(req: pX509_REQ;
                                   exts: pSTACK_OFX509_EXTENSION): cint; cdecl;
 X509_REQ_set_pubkey: function(req: pX509_REQ; pkey: pEVP_PKEY): cint; cdecl;
 X509_REQ_get_pubkey: function(req: pX509_REQ): pEVP_PKEY; cdecl;
 X509_REQ_sign: function(req: pX509_REQ; pkey: pEVP_PKEY;
                                              const md: pEVP_MD): cint; cdecl;
// X.509 collections
 X509_STORE_new: function: pX509_STORE; cdecl;
 X509_STORE_free: procedure(v: pX509_STORE); cdecl;
 X509_STORE_add_cert: function(ctx: pX509_STORE; x: pX509): cint; cdecl;
 X509_STORE_add_lookup: function(v: pX509_STORE;
                                  m: pX509_LOOKUP_METHOD): pX509_LOOKUP; cdecl;
 X509_STORE_CTX_new: function: pX509_STORE_CTX; cdecl;
 X509_STORE_CTX_free: procedure(ctx: pX509_STORE); cdecl;
 X509_STORE_CTX_init: procedure(ctx: pX509_STORE_CTX; 
                store: pX509_STORE; x509: pX509; chain: pSTACK_OFX509); cdecl;
 X509_STORE_CTX_get_current_cert: function(ctx: pX509_STORE_CTX): pX509; cdecl;
 X509_STORE_CTX_get_error: function(ctx: pX509_STORE_CTX): cint; cdecl;
 X509_STORE_CTX_get_error_depth: function(ctx: pX509_STORE_CTX): cint; cdecl;
 X509_LOOKUP_new: function(method: pX509_LOOKUP_METHOD): pX509_LOOKUP; cdecl;
 X509_LOOKUP_init: function(ctx: pX509_LOOKUP): cint; cdecl;
 X509_LOOKUP_free: procedure(ctx: pX509_LOOKUP); cdecl;
 X509_LOOKUP_ctrl: function(ctx: pX509_LOOKUP; cmd: cint;
              const argc: PCharacter; argl: clong; ret: pointer): cint; cdecl;
 X509_LOOKUP_file: function: pX509_LOOKUP_METHOD; cdecl;
 d2i_X509_REQ_bio: function(bp: pBIO; req: pX509_REQ): pX509_REQ; cdecl;
 i2d_X509_REQ_bio: function(bp: pBIO; req: pX509_REQ): cint; cdecl;
 d2i_X509_bio: function(bp: pBIO; x509: pX509): pX509; cdecl;

function X509_get_version(x: pX509): cint;
function X509_get_notBefore(a: pX509): pASN1_TIME;
function X509_get_notAfter(a: pX509): pASN1_TIME;
function X509_REQ_get_version(req: pX509_REQ): cint;
function X509_REQ_get_subject_name(req: pX509_REQ): pX509_NAME;

implementation
uses
 msedynload,mseopensslasn;
 
function X509_get_version(x: pX509): cint;
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

function X509_REQ_get_version(req: pX509_REQ): cint;
begin
  result := ASN1_INTEGER_get(req^.req_info^.version);
end;

function X509_REQ_get_subject_name(req: pX509_REQ): pX509_NAME;
begin
  result := req^.req_info^.subject;
end;

procedure init(const info: dynlibinfoty);
const
 funcs: array[0..67] of funcinfoty = (
   (n: 'X509_new'; d: @X509_new),
   (n: 'X509_free'; d: @X509_free),
   (n: 'X509_NAME_oneline'; d: @X509_NAME_oneline),
   (n: 'X509_get_subject_name'; d: @X509_get_subject_name),
   (n: 'X509_get_issuer_name'; d: @X509_get_issuer_name),
   (n: 'X509_NAME_hash'; d: @X509_NAME_hash),
   (n: 'X509_digest'; d: @X509_digest),
   (n: 'X509_print'; d: @X509_print),
   (n: 'X509_set_version'; d: @X509_set_version),
   (n: 'X509_set_pubkey'; d: @X509_set_pubkey),
   (n: 'X509_set_issuer_name'; d: @X509_set_issuer_name),
   (n: 'X509_NAME_add_entry_by_txt'; d: @X509_NAME_add_entry_by_txt),
   (n: 'X509_sign'; d: @X509_sign),
   (n: 'X509_gmtime_adj'; d: @X509_gmtime_adj),
   (n: 'X509_set_notBefore'; d: @X509_set_notBefore),
   (n: 'X509_set_notAfter'; d: @X509_set_notAfter),
   (n: 'X509_get_serialNumber'; d: @X509_set_notAfter),
   (n: 'X509_NAME_new'; d: @X509_NAME_new),
   (n: 'X509_NAME_free'; d: @X509_NAME_free),
   (n: 'X509_NAME_get_entry'; d: @X509_NAME_get_entry),
   (n: 'X509_NAME_get_text_by_NID'; d: @X509_NAME_get_text_by_NID),
   (n: 'X509_load_cert_file'; d: @X509_load_cert_file),
   (n: 'X509_get1_email'; d: @X509_get1_email),
   (n: 'X509_get_pubkey'; d: @X509_get_pubkey),
   (n: 'X509_check_private_key'; d: @X509_check_private_key),
   (n: 'X509_check_purpose'; d: @X509_check_purpose),
   (n: 'X509_issuer_and_serial_cmp'; d: @X509_issuer_and_serial_cmp),
   (n: 'X509_issuer_and_serial_hash'; d: @X509_issuer_and_serial_hash),
   (n: 'X509_verify_cert'; d: @X509_verify_cert),
   (n: 'X509_verify_cert_error_string'; d: @X509_verify_cert_error_string),
   (n: 'X509_email_free'; d: @X509_email_free),
   (n: 'X509_get_ext'; d: @X509_get_ext),
   (n: 'X509_get_ext_by_NID'; d: @X509_get_ext_by_NID),
   (n: 'X509_get_ext_d2i'; d: @X509_get_ext_d2i),
   (n: 'X509V3_EXT_d2i'; d: @X509V3_EXT_d2i),
   (n: 'X509V3_EXT_i2d'; d: @X509V3_EXT_i2d),
   (n: 'X509V3_EXT_conf_nid'; d: @X509V3_EXT_conf_nid),
   (n: 'X509_set_subject_name'; d: @X509_set_subject_name),
   (n: 'X509V3_set_ctx'; d: @X509V3_set_ctx),
   (n: 'X509_SIG_free'; d: @X509_SIG_free),
   (n: 'X509_PUBKEY_get'; d: @X509_PUBKEY_get),
   (n: 'X509_REQ_new'; d: @X509_REQ_new),
   (n: 'X509_REQ_free'; d: @X509_REQ_free),
   (n: 'X509_REQ_set_version'; d: @X509_REQ_set_version),
   (n: 'X509_REQ_set_subject_name'; d: @X509_REQ_set_subject_name),
   (n: 'X509_REQ_add1_attr_by_txt'; d: @X509_REQ_add1_attr_by_txt),
   (n: 'X509_REQ_add_extensions'; d: @X509_REQ_add_extensions),
   (n: 'X509_REQ_set_pubkey'; d: @X509_REQ_set_pubkey),
   (n: 'X509_REQ_get_pubkey'; d: @X509_REQ_get_pubkey),
   (n: 'X509_REQ_sign'; d: @X509_REQ_sign),
   (n: 'X509_STORE_new'; d: @X509_STORE_new),
   (n: 'X509_STORE_free'; d: @X509_STORE_free),
   (n: 'X509_STORE_add_cert'; d: @X509_STORE_add_cert),
   (n: 'X509_STORE_add_lookup'; d: @X509_STORE_add_lookup),
   (n: 'X509_STORE_CTX_new'; d: @X509_STORE_CTX_new),
   (n: 'X509_STORE_CTX_free'; d: @X509_STORE_CTX_free),
   (n: 'X509_STORE_CTX_init'; d: @X509_STORE_CTX_init),
   (n: 'X509_STORE_CTX_get_current_cert'; d: @X509_STORE_CTX_get_current_cert),
   (n: 'X509_STORE_CTX_get_error'; d: @X509_STORE_CTX_get_error),
   (n: 'X509_STORE_CTX_get_error_depth'; d: @X509_STORE_CTX_get_error_depth),
   (n: 'X509_LOOKUP_new'; d: @X509_LOOKUP_new),
   (n: 'X509_LOOKUP_init'; d: @X509_LOOKUP_init),
   (n: 'X509_LOOKUP_free'; d: @X509_LOOKUP_free),
   (n: 'X509_LOOKUP_ctrl'; d: @X509_LOOKUP_ctrl),
   (n: 'X509_LOOKUP_file'; d: @X509_LOOKUP_file),
   (n:  'd2i_X509_REQ_bio'; d: @d2i_X509_REQ_bio),
   (n:  'i2d_X509_REQ_bio'; d: @i2d_X509_REQ_bio),
   (n:  'd2i_X509_bio'; d: @d2i_X509_bio)
  );

begin
 getprocaddresses(info,funcs);
end;

initialization
 regopensslinit(@init);
end.
