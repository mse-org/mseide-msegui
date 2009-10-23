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

type
  SslPtr = Pointer;
  PSslPtr = ^SslPtr;
  PSSL_CTX = SslPtr;
  PSSL = SslPtr;
  PSSL_METHOD = SslPtr;
  PX509 = SslPtr;
  PX509_NAME = SslPtr;
  PEVP_MD	= SslPtr;
  PInteger = ^Integer;
  PBIO_METHOD = SslPtr;
  PBIO = SslPtr;
  EVP_PKEY = SslPtr;
  PRSA = SslPtr;
  PASN1_UTCTIME = SslPtr;
  PASN1_INTEGER = SslPtr;
  PPasswdCb = SslPtr;
  PFunction = procedure;

  DES_cblock = array[0..7] of Byte;
  PDES_cblock = ^DES_cblock;
  des_ks_struct = packed record
    ks: DES_cblock;
    weak_key: Integer;
  end;
  des_key_schedule = array[1..16] of des_ks_struct;

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

function SSL_set_options(ssl: PSSL; options: integer): integer;

function IsSSLloaded: Boolean;
procedure InitSSLInterface;
procedure DestroySSLInterface;

implementation
uses
 msesys,dynlibs,msesysintf;
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

finalization
 destroysslinterface;
end.
