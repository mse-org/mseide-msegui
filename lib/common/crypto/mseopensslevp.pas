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
      0: (ptr: PCharacter);
      1: (rsa: pRSA);  // ^rsa_st
      2: (dsa: pDSA);  // ^dsa_st
      3: (dh: pDH);  // ^dh_st
  end;
  pSTACK_OFX509 = SslPtr; //todo
  EVP_PKEY = record
    ktype: cint;
    save_type: cint;
    references: cint;
    pkey: EVP_PKEY_PKEY;
    save_parameters: cint;
    attributes: pSTACK_OFX509;
  end;

  pEVP_CIPHER = pointer;

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


var
// libeay.dll
  EVP_PKEY_New: function(): EVP_PKEY; cdecl;
  EVP_PKEY_Free: procedure(pk: EVP_PKEY); cdecl;
  EVP_PKEY_Assign: function(pkey: EVP_PKEY; _type: cint;
                          key: Prsa): cint; cdecl;
  EVP_get_digestbyname: function(Name: pchar): PEVP_MD; cdecl;
  EVP_cleanup: procedure; cdecl;
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
  EVP_DigestUpdate: procedure(ctx: pEVP_MD_CTX; const d: Pointer;
                                                        cnt: sslsize_t); cdecl;
  EVP_DigestFinal: procedure(ctx: pEVP_MD_CTX; md: PCharacter;
                                                       var s: cuint); cdecl;
  EVP_SignFinal: function(ctx: pEVP_MD_CTX; sig: pointer;
                              var s: cuint; key: pEVP_PKEY): cint; cdecl;
  EVP_VerifyFinal: function(ctx: pEVP_MD_CTX; sigbuf: pointer;
                         siglen: cuint; pkey: pEVP_PKEY): cint;  cdecl;
  EVP_MD_CTX_copy: function(_out: pEVP_MD_CTX; _in: pEVP_MD_CTX): cint; cdecl;
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
  EVP_set_pw_prompt: procedure(prompt: PCharacter);cdecl;
  EVP_get_pw_prompt: function: PCharacter;cdecl;
  // Default callback password function: replace if you want
  EVP_read_pw_string: function(buf: PCharacter; len: cint;
                      const prompt: PCharacter; verify: cint): cint;cdecl;
  d2i_PrivateKey_bio: function(bp: pBIO; var a: pEVP_PKEY): pEVP_PKEY; cdecl;
  d2i_PUBKEY_bio: function(bp: pBIO; var a: pEVP_PKEY): pEVP_PKEY; cdecl;
  i2d_PUBKEY_bio: function(bp: pBIO; pkey: pEVP_PKEY): cint; cdecl;

procedure EVP_SignInit(ctx: pEVP_MD_CTX; const _type: pEVP_MD);
procedure EVP_SignUpdate(ctx: pEVP_MD_CTX; const d: Pointer; cnt: cuint);
procedure EVP_VerifyInit(ctx: pEVP_MD_CTX; const _type: pEVP_MD);
procedure EVP_VerifyUpdate(ctx: pEVP_MD_CTX; const d: Pointer; cnt: cuint);
function EVP_MD_size(e: pEVP_MD): cint;
function EVP_MD_CTX_size(e: pEVP_MD_CTX): cint;

implementation
uses
 msedynload;
 
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
 funcs: array[0..49] of funcinfoty = (
   (n: 'EVP_PKEY_new'; d: @EVP_PKEY_new),
   (n: 'EVP_PKEY_free'; d: @EVP_PKEY_free),
   (n: 'EVP_PKEY_assign'; d: @EVP_PKEY_assign),
   (n: 'EVP_cleanup'; d: @EVP_cleanup),
   (n: 'EVP_get_digestbyname'; d: @EVP_get_digestbyname),
   (n: 'EVP_md_null'; d: @EVP_md_null),
   (n: 'EVP_md2'; d: @EVP_md2),
   (n: 'EVP_md5'; d: @EVP_md5),
   (n: 'EVP_sha'; d: @EVP_sha),
   (n: 'EVP_sha1'; d: @EVP_sha1),
   (n: 'EVP_dss'; d: @EVP_dss),
   (n: 'EVP_dss1'; d: @EVP_dss1),
   (n: 'EVP_ripemd160'; d: @EVP_ripemd160),
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
   (n:  'd2i_PrivateKey_bio'; d: @d2i_PrivateKey_bio),
   (n:  'd2i_PUBKEY_bio'; d: @d2i_PUBKEY_bio),
   (n:  'i2d_PUBKEY_bio'; d: @i2d_PUBKEY_bio)
  );
 funcsopt: array[0..7] of funcinfoty = (
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
 getprocaddresses(info.libhandle,funcs);
 getprocaddresses(info.libhandle,funcsopt,true);
end;
  
procedure deinit(const info: dynlibinfoty);
begin
 evp_cleanup;
end;

initialization
 regopensslinit(@init);
 regopenssldeinit(@deinit);
end.
