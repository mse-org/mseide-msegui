{ MSEgui Copyright (c) 2007-2012 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseopenssl;

{$MODE OBJFPC}{$H+}

interface

uses
 msedynload,msestrings,msectypes;
const
{$ifdef mswindows}
 openssllib: array[0..1] of filenamety = ('ssleay32.dll','libssl32.dll');
 opensslutillib: array[0..0] of filenamety = ('libeay32.dll');
{$else}
 openssllib: array[0..4] of filenamety = (
     'libssl.so.1.0.0','libssl.so.0.9.8','libssl.so.0.9.7','libssl.so.0.9.6',
     'libssl.so');
 opensslutillib: array[0..4] of filenamety = (
           'libcrypto.so.1.0.0','libcrypto.so.0.9.8','libcrypto.so.0.9.7',
           'libcrypto.so.0.9.6','libcrypto.so');
{$endif}

const
 SHA_DIGEST_LENGTH = 20;
 BN_CTX_NUM = 16;
 BN_CTX_NUM_POS = 12;

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

 SSL_FILETYPE_ASN1	= 2;
 SSL_FILETYPE_PEM = 1;
 EVP_PKEY_RSA = 6;
 
type
 sslsize_t = culong;
 SslPtr = Pointer;
 pSslPtr = ^SslPtr;
 pSSL_CTX = SslPtr;
 pSSL = SslPtr;
 pSSL_METHOD = SslPtr;
 pBIO_METHOD = SslPtr;
 pBIO = SslPtr;
 pX509 = SslPtr;
 ppX509 = ^pX509;
 pX509_NAME = SslPtr;
 pEVP_MD	= SslPtr;
//  PInteger = ^Integer;
// EVP_PKEY = SslPtr;
 pEVP_CIPHER = SslPtr;
 pEVP_PKEY = SslPtr;
 ppEVP_PKEY = ^pEVP_PKEY;
 pX509_REQ = SslPtr;
 ppX509_REQ = ^pX509_REQ;
 pX509_CRL = SslPtr;
 ppX509_CRL = pX509_CRL;
 pPKCS7 = SslPtr;
 pASN1_cint = SslPtr;
 pSTACK_OFX509 = SslPtr;
 pX509_SIG = SslPtr;
 pBIGNUM = SslPtr;
 pBN_MONT_CTX = SslPtr;
 pBN_BLINDING = SslPtr;
 pRSA = SslPtr;
 ppRSA = ^pRSA;
 pDSA = SslPtr;
 ppDSA = ^pDSA;
 pASN1_UTCTIME = SslPtr;
 pASN1_INTEGER = SslPtr;
 pASN1_ENUMERATED = SslPtr;
 pASN1_OCTET_STRING = SslPtr;
 pPasswdCb = SslPtr;
 pDH = SslPtr;
 pBUF_MEM = SslPtr;
 pEC_KEY = SslPtr;
 pSTACK = SslPtr;
 pPKCS7_SIGNER_INFO = SslPtr;
 pAES_KEY = SslPtr;
 pENGINE = SslPtr;
 pRAND_METHOD = SslPtr;

 pFunction = procedure; cdecl;
 pCharacter = PChar;

 CRYPTO_EX_DATA = record
   sk: pointer;
   dummy: cint;
 end;

 TProgressCallbackFunction = procedure(status: cint; progress: cint;
                                                             data: pointer); 

 // Password ask callback for I/O function prototipe
 // It must fill buffer with password and return password length
 TPWCallbackFunction = function(buffer: PCharacter; length: cint;
                                verify: cint; data: pointer): cint; cdecl;

  
var
 SSL_new: function(ctx: PSSL_CTX):PSSL; cdecl;
 SSL_free: procedure(ssl: PSSL); cdecl;
 SSL_ctrl: function(ssl: PSSL; cmd: cint; larg: cint;
                                   parg: pointer): cint; cdecl;
 SSL_get_error: function(s: PSSL; ret_code: cint):cint; cdecl;
 SSL_library_init: function():cint; cdecl;
 SSL_load_error_strings: procedure; cdecl;
 SSL_set_cipher_list: function(arg0: PSSL_CTX; str: PChar):cint; cdecl;

 SSL_CTX_set_cipher_list: function(arg0: PSSL_CTX; str: PChar):cint; cdecl;
//  SSL_CTX_set_cipher_list: function(arg0: PSSL_CTX; 
//                                    var str: String):cint; cdecl;
 SSL_CTX_new: function(meth: PSSL_METHOD):PSSL_CTX; cdecl;
 SSL_CTX_free: procedure(arg0: PSSL_CTX); cdecl;
 SSL_CTX_use_PrivateKey: function(ctx: PSSL_CTX; pkey: SslPtr):cint; cdecl;
 SSL_CTX_use_PrivateKey_ASN1: function(pk: cint; ctx: PSSL_CTX; d: pbyte;
                                len: cint):cint; cdecl;
 SSL_CTX_use_PrivateKey_file: function(ctx: PSSL_CTX; _file: PChar;
                              _type: cint):cint; cdecl;
//  SSL_CTX_use_PrivateKey_file: function(ctx: PSSL_CTX;
//                        const _file: String; _type: cint):cint; cdecl;
 SSL_CTX_use_RSAPrivateKey_file: function(ctx: PSSL_CTX; _file: pchar;
                                _type: cint):cint; cdecl;
 SSL_CTX_use_certificate: function(ctx: PSSL_CTX; x: SslPtr):cint; cdecl;
 SSL_CTX_use_certificate_ASN1: function(ctx: PSSL_CTX; len: cint;
                                              d: pbyte):cint; cdecl;
 SSL_CTX_use_certificate_file: function(ctx: PSSL_CTX;
                        _file: pchar; _type: cint):cint; cdecl;
 SSL_CTX_use_certificate_chain_file: function(ctx: PSSL_CTX;
                                         _file: PChar):cint; cdecl;
//  SSL_CTX_use_certificate_chain_file: function(ctx: PSSL_CTX;
//                                const _file: String):cint; cdecl;
 SSL_CTX_check_private_key: function(ctx: PSSL_CTX):cint; cdecl;
 SSL_CTX_set_default_passwd_cb: procedure(ctx: PSSL_CTX; cb: PPasswdCb); cdecl;
 SSL_CTX_set_default_passwd_cb_userdata: procedure(
                                        ctx: PSSL_CTX; u: SslPtr); cdecl;
//  function SSL_CTX_LoadVerifyLocations(ctx: PSSL_CTX;
//                   const CAfile: PChar; const CApath: PChar):cint; cdecl;
 SSL_CTX_load_verify_locations: function(ctx: PSSL_CTX; CAfile: pchar;
                                 CApath: pchar):cint; cdecl;
 SSL_CTX_set_verify: procedure(ctx: PSSL_CTX; mode: cint;
                                                arg2: PFunction); cdecl;

 SSLv2_method: function():PSSL_METHOD; cdecl;
 SSLv3_method: function():PSSL_METHOD; cdecl;
 TLSv1_method: function():PSSL_METHOD; cdecl;
 SSLv23_method: function():PSSL_METHOD; cdecl;
 SSL_use_certificate_file: function(ssl: PSSL;
                        _file: pchar; _type: cint):cint; cdecl;
 SSL_use_PrivateKey_file: function(ssl: PSSL; _file: PChar;
                              _type: cint):cint; cdecl;

 SSL_set_fd: function(s: PSSL; fd: cint):cint; cdecl;
 SSL_set_rfd: function(s: PSSL; fd: cint):cint; cdecl;
 SSL_set_wfd: function(s: PSSL; fd: cint):cint; cdecl;
 SSL_accept: function(ssl: PSSL):cint; cdecl;
 SSL_connect: function(ssl: PSSL):cint; cdecl;
 SSL_shutdown: function(ssl: PSSL):cint; cdecl;
 SSL_read: function(ssl: PSSL; buf: SslPtr; num: cint):cint; cdecl;
 SSL_peek: function(ssl: PSSL; buf: SslPtr; num: cint):cint; cdecl;
 SSL_write: function(ssl: PSSL; buf: SslPtr; num: cint):cint; cdecl;
 SSL_pending: function(ssl: PSSL):cint; cdecl;
 SSL_get_version: function(ssl: PSSL): pchar; cdecl;
 SSL_get_peer_certificate: function(ssl: PSSL): PX509; cdecl;
 SSL_get_current_cipher: function(s: PSSL):SslPtr; cdecl;
 SSL_CIPHER_get_name: function(c: SslPtr): pchar; cdecl;
 SSL_CIPHER_get_bits: function(c: SslPtr; var alg_bits: cint):cint; cdecl;
 SSL_get_verify_result: function(ssl: PSSL):cint; cdecl;

 SSLeay: function: cardinal;
 OpenSSL_add_all_ciphers: procedure; cdecl;
 OpenSSL_add_all_digests: procedure; cdecl;
 ERR_load_crypto_strings: procedure; cdecl;
 ERR_peek_error: function: cardinal; cdecl;
 ERR_peek_last_error: function: cardinal; cdecl;
 // Low level debugable memory management function
 CRYPTO_malloc: function (length: clong; const f: PCharacter;
                                              line: cint): pointer; cdecl;
 CRYPTO_realloc: function(str: PCharacter; length: clong;
                          const f: PCharacter; line: cint): pointer; cdecl;
 CRYPTO_remalloc: function(a: pointer; length: clong;
                           const f: PCharacter; line: cint): pointer; cdecl;
 CRYPTO_free: procedure(str: pointer); cdecl;
//util
 SSLeay_version: function(t: cint): pchar; cdecl;
 ERR_error_string_n: procedure(e: cint; buf: PChar; len: cint); cdecl;
 ERR_get_error: function(): cint; cdecl;
 ERR_clear_error: procedure; cdecl;
 ERR_free_strings: procedure; cdecl;
 ERR_remove_state: procedure(pid: cint); cdecl;
 OPENSSL_add_all_algorithms_noconf: procedure; cdecl;
 CRYPTO_cleanup_all_ex_data: procedure; cdecl;
//  RAND_screen: procedure; cdecl;
 i2d_X509_bio: function(b: PBIO; x: PX509): cint; cdecl;
 i2d_PrivateKey_Bio: function(b: PBIO; pkey: pEVP_PKEY): cint; cdecl;

 CRYPTO_num_locks: function: cint; cdecl;
 CRYPTO_set_locking_callback: procedure(cb: Sslptr); cdecl;
 CRYPTO_set_id_callback: procedure(func: pointer); cdecl;


// OBJ functions
 OBJ_obj2nid: function(asn1_object: pointer): cint; cdecl;
 OBJ_txt2nid: function(s: PCharacter): cint; cdecl;
 OBJ_txt2obj: function(s: PCharacter; no_name: cint): cint; cdecl;
 // safestack functions
 sk_new_null: function: pointer; cdecl;
 sk_free: procedure(st: pointer); cdecl;
 sk_push: function(st: pointer; val: pointer): cint; cdecl;
 sk_num: function(st: pointer): cint; cdecl;
 sk_value: function(st: pointer; i: cint): pointer; cdecl;
 // Internal to DER and DER to internal conversion functions


// Helper: convert standard Delphi integer in big-endian integer
function int2bin(n: cint): cint;
// High level memory management function
function OPENSSL_malloc(length: clong): pointer;
function OPENSSL_realloc(address: PCharacter; length: clong): pointer;
function OPENSSL_remalloc(var address: pointer; length: clong): pointer;
procedure OPENSSL_free(address: pointer); // cdecl; ?

function SSL_set_options(ssl: PSSL; options: cint): cint;
//function IsSSLloaded: Boolean;

procedure initsslinterface; //calls initializeopenssl once
procedure initializeopenssl(const sonames: array of filenamety;
                             const sonamesutil: array of filenamety);
                                     //[] = default
procedure releaseopenssl;
procedure regopensslinit(const initproc: dynlibprocty);
procedure regopenssldeinit(const deinitproc: dynlibprocty);

implementation
uses
 msesystypes,dynlibs,msesysintf1,msesysintf;
var 
 libinfo,libinfoutil: dynlibinfoty;

var
// ssllibhandle: integer;
// sslutillibhandle: integer;
// sslloaded: boolean = false;
 RAND_screen: procedure; cdecl;

function SSL_set_options(ssl: PSSL; options: cint): cint;
begin
 result:= ssl_ctrl(ssl,ssl_ctrl_options,options,nil);
end;

function int2bin(n: cint): cint;
begin
   result := ((cardinal(n) shr 24) and $000000FF) or
       ((cardinal(n) shr 8) and $0000FF00) or
        ((cardinal(n) shl 8) and $00FF0000) or
        ((cardinal(n) shl 24) and $FF000000);
end;

function OPENSSL_malloc(length: clong): pointer;
begin
  OPENSSL_malloc := CRYPTO_malloc(length, nil, 0);
end;

function OPENSSL_realloc(address: PCharacter; length: clong): pointer;
begin
  OPENSSL_realloc := CRYPTO_realloc(address, length, nil, 0);
end;

function OPENSSL_remalloc(var address: pointer; length: clong): pointer;
begin
  OPENSSL_remalloc := CRYPTO_remalloc(address, length, nil, 0);
end;

procedure OPENSSL_free(address: pointer);
begin
  CRYPTO_free(address);
end;
{
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
}
type
 mutexarty = array of mutexty;
var
 locks: mutexarty;

procedure lockingcallback(mode: cint; n: cint; afile: pchar; 
                       line: cint); cdecl;
begin
 if mode and crypto_lock <> 0 then begin
  sys_mutexlock(locks[n]);
 end
 else begin
  sys_mutexunlock(locks[n]);
 end;
end;

function idcallback: cint; cdecl;
begin
 result:= sys_getcurrentthread;
end;

procedure initssllib;
var
 int1: cint;
begin
 //init library
 Ssl_Library_Init;
 Ssl_Load_Error_Strings;
 OPENSSL_add_all_algorithms_noconf;
 pointer(rand_screen):= getprocedureaddress(
                      libinfoutil.libhandle,'RAND_screen');
 if assigned(rand_screen) then begin
  Rand_Screen; //windows, todo: better random
 end;
 setlength(locks,crypto_num_locks());
 for int1:= 0 to high(locks) do begin
  sys_mutexcreate(locks[int1]);
 end;
 crypto_set_locking_callback(@lockingcallback);
 crypto_set_id_callback(@idcallback);
end;

procedure initializeopenssl(const sonames: array of filenamety;
                                 const sonamesutil: array of filenamety);
                                     //[] = default
const
 funcs: array[0..54] of funcinfoty = (
   (n: 'SSL_get_error'; d: @SSL_get_error),
   (n: 'SSL_library_init'; d: @SSL_library_init),
   (n: 'SSL_load_error_strings'; d: @SSL_load_error_strings),
   (n: 'SSL_CTX_set_cipher_list'; d: @SSL_CTX_set_cipher_list),
   (n: 'SSL_CTX_new'; d: @SSL_CTX_new),
   (n: 'SSL_CTX_free'; d: @SSL_CTX_free),
   (n: 'SSL_set_fd'; d: @SSL_set_fd),
   (n: 'SSL_set_rfd'; d: @SSL_set_rfd),
   (n: 'SSL_set_wfd'; d: @SSL_set_wfd),
   (n: 'SSL_set_cipher_list'; d: @SSL_set_cipher_list),
   (n: 'SSLv2_method'; d: @SSLv2_method),
   (n: 'SSLv3_method'; d: @SSLv3_method),
   (n: 'TLSv1_method'; d: @TLSv1_method),
   (n: 'SSLv23_method'; d: @SSLv23_method),
   (n: 'SSL_CTX_use_PrivateKey'; d: @SSL_CTX_use_PrivateKey),
   (n: 'SSL_CTX_use_PrivateKey_ASN1'; d: @SSL_CTX_use_PrivateKey_ASN1),
   (n: 'SSL_CTX_use_PrivateKey_file'; d: @SSL_CTX_use_PrivateKey_file),
   (n: 'SSL_CTX_use_RSAPrivateKey_file'; d: @SSL_CTX_use_RSAPrivateKey_file),
   (n: 'SSL_CTX_use_certificate'; d: @SSL_CTX_use_certificate),
   (n: 'SSL_CTX_use_certificate_ASN1'; d: @SSL_CTX_use_certificate_ASN1),
   (n: 'SSL_CTX_use_certificate_file'; d: @SSL_CTX_use_certificate_file),
   (n: 'SSL_CTX_use_certificate_chain_file'; d: @SSL_CTX_use_certificate_chain_file),
   (n: 'SSL_CTX_check_private_key'; d: @SSL_CTX_check_private_key),
   (n: 'SSL_CTX_set_default_passwd_cb'; d: @SSL_CTX_set_default_passwd_cb),
   (n: 'SSL_CTX_set_default_passwd_cb_userdata'; d: @SSL_CTX_set_default_passwd_cb_userdata),
   (n: 'SSL_CTX_load_verify_locations'; d: @SSL_CTX_load_verify_locations),
   (n: 'SSL_new'; d: @SSL_new),
   (n: 'SSL_free'; d: @SSL_free),
   (n: 'SSL_ctrl'; d: @SSL_ctrl),
   (n: 'SSL_use_certificate_file'; d: @SSL_use_certificate_file),
   (n: 'SSL_use_PrivateKey_file'; d: @SSL_use_PrivateKey_file),
   (n: 'SSL_accept'; d: @SSL_accept),
   (n: 'SSL_connect'; d: @SSL_connect),
   (n: 'SSL_shutdown'; d: @SSL_shutdown),
   (n: 'SSL_read'; d: @SSL_read),
   (n: 'SSL_peek'; d: @SSL_peek),
   (n: 'SSL_write'; d: @SSL_write),
   (n: 'SSL_pending'; d: @SSL_pending),
   (n: 'SSL_get_peer_certificate'; d: @SSL_get_peer_certificate),
   (n: 'SSL_get_version'; d: @SSL_get_version),
   (n: 'SSL_CTX_set_verify'; d: @SSL_CTX_set_verify),
   (n: 'SSL_get_current_cipher'; d: @SSL_get_current_cipher),
   (n: 'SSL_CIPHER_get_name'; d: @SSL_CIPHER_get_name),
   (n: 'SSL_CIPHER_get_bits'; d: @SSL_CIPHER_get_bits),
   (n: 'SSL_get_verify_result'; d: @SSL_get_verify_result),
   (n: 'SSLeay'; d: @SSLeay),
   (n: 'OpenSSL_add_all_ciphers'; d: @OpenSSL_add_all_ciphers),
   (n: 'OpenSSL_add_all_digests'; d: @OpenSSL_add_all_digests),
   (n: 'ERR_load_crypto_strings'; d: @ERR_load_crypto_strings),
   (n: 'ERR_peek_error'; d: @ERR_peek_error),
   (n: 'ERR_peek_last_error'; d: @ERR_peek_last_error),
   (n: 'CRYPTO_malloc'; d: @CRYPTO_malloc),
   (n: 'CRYPTO_realloc'; d: @CRYPTO_realloc),
   (n: 'CRYPTO_remalloc'; d: @CRYPTO_remalloc),
   (n: 'CRYPTO_free'; d: @CRYPTO_free)
  );
 funcsutil: array[0..20] of funcinfoty = (
   (n: 'SSLeay_version'; d: @SSLeay_version),
   (n: 'ERR_error_string_n'; d: @ERR_error_string_n),
   (n: 'ERR_get_error'; d: @ERR_get_error),
   (n: 'ERR_clear_error'; d: @ERR_clear_error),
   (n: 'ERR_free_strings'; d: @ERR_free_strings),
   (n: 'ERR_remove_state'; d: @ERR_remove_state),
   (n: 'OPENSSL_add_all_algorithms_noconf'; d: @OPENSSL_add_all_algorithms_noconf),
   (n: 'CRYPTO_cleanup_all_ex_data'; d: @CRYPTO_cleanup_all_ex_data),
//        'RAND_screen',
   (n: 'i2d_X509_bio'; d: @i2d_X509_bio),
   (n: 'i2d_PrivateKey_bio'; d: @i2d_PrivateKey_bio),
        // 3DES functions
      //
   (n: 'CRYPTO_num_locks'; d: @CRYPTO_num_locks),
   (n: 'CRYPTO_set_locking_callback'; d: @CRYPTO_set_locking_callback),
   (n: 'CRYPTO_set_id_callback'; d: @CRYPTO_set_id_callback),

   (n:  'OBJ_obj2nid'; d: @OBJ_obj2nid),
   (n:  'OBJ_txt2nid'; d: @OBJ_txt2nid),
   (n:  'OBJ_txt2obj'; d: @OBJ_txt2obj),
   (n:  'sk_new_null'; d: @sk_new_null),
   (n:  'sk_free'; d: @sk_free),
   (n:  'sk_push'; d: @sk_push),
   (n:  'sk_num'; d: @sk_num),
   (n:  'sk_value'; d: @sk_value)

   );

 errormessage = 'Can not load OpneSSL library, ';
begin
 initializedynlib(libinfo,sonames,openssllib,funcs,[],errormessage);
 initializedynlib(libinfoutil,sonamesutil,opensslutillib,
                          funcsutil,[],errormessage,@initssllib);
end;

var
 libloaded: boolean;
 
procedure initsslinterface; //calls initializeopenssl once
begin
 if not libloaded then begin
  initializeopenssl([],[]);
  libloaded:= true;
 end;
end;

procedure deinitssllib;
var
 int1: cint;
begin
 crypto_cleanup_all_ex_data;
 err_remove_state(0);
 for int1:= 0 to high(locks) do begin
  sys_mutexdestroy(locks[int1]);
 end;
 locks:= nil;
end;

procedure releaseopenssl;
begin
 releasedynlib(libinfoutil);
 releasedynlib(libinfo,@deinitssllib);
end;

procedure regopensslinit(const initproc: dynlibprocty);
begin
 regdynlibinit(libinfoutil,initproc);
end;

procedure regopenssldeinit(const deinitproc: dynlibprocty);
begin
 regdynlibdeinit(libinfoutil,deinitproc);
end;

{
function issslloaded: boolean;
begin
 result:= sslloaded;
end;
}

{
finalization
 destroysslinterface;
}
initialization
 initializelibinfo(libinfo);
 initializelibinfo(libinfoutil);
finalization
 if libloaded then begin
  releaseopenssl;
 end;
 finalizelibinfo(libinfo);
 finalizelibinfo(libinfoutil);
end.
