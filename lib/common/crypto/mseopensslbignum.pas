{ MSEgui Copyright (c) 2007-2012 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseopensslbignum;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseopenssl,msectypes;
 
type
  pBN_ULONG = ^BN_ULONG;
  BN_ULONG = culong; // system dependent, consider it as a opaque pointer

  pBIGNUM = ^BIGNUM;
  BIGNUM = record
	d: pBN_ULONG;	// Pointer to an array of 'BN_BITS2' bit chunks.
	top: cint;	// Index of last used d +1.
                        // The next are internal book keeping for bn_expand.
	dmax: cint;	// Size of the d array.
	neg: cint;	// one if the number is negative
	flags: cint;
  end;
  
  pBN_CTX = ^BN_CTX;
  BN_CTX = record
	tos: cint;
	bn: array [0..BN_CTX_NUM-1] of BIGNUM;
	flags: cint;
	depth: cint;
	pos: array [0..BN_CTX_NUM_POS-1] of cint;
	too_many: cint;
  end;

  pBN_BLINDING = ^BN_BLINDING;
  BN_BLINDING = record
	init: cint;
	A: pBIGNUM;
	Ai: pBIGNUM;
	_mod: pBIGNUM;  // just a reference (original name: mod)
  end;

  // Used for montgomery multiplication
  pBN_MONT_CTX = ^BN_MONT_CTX;
  BN_MONT_CTX = record
	ri: cint;    // number of bits in R
	RR: BIGNUM;     // used to convert to montgomery form
	N: BIGNUM;      // The modulus
	Ni: BIGNUM;     // R*(1/R mod N) - N*Ni = 1
	                // (Ni is only stored for bignum algorithm)
	n0: BN_ULONG;   // least significant word of Ni
	flags: cint;
  end;

  // Used for reciprocal division/mod functions
  // It cannot be shared between threads
  pBN_RECP_CTX = ^BN_RECP_CTX;
  BN_RECP_CTX = record
	N: BIGNUM;	// the divisor
	Nr: BIGNUM;	// the reciprocal
	num_bits: cint;
	shift: cint;
	flags: cint;
  end;

var
  // Big number function
  BN_new:function: pBIGNUM; cdecl;
  BN_init: procedure(bn: pBIGNUM); cdecl;
  BN_clear: procedure(bn: pBIGNUM); cdecl;
  BN_free: procedure(bn: pBIGNUM); cdecl;
  BN_clear_free: procedure(bn: pBIGNUM); cdecl;
  BN_set_params: procedure (mul, high, low, mont: cint); cdecl;
  BN_get_params: function(which: cint): cint; cdecl;
  BN_options:function: PCharacter; cdecl;
  BN_CTX_new: function: pBN_CTX; cdecl;
  BN_CTX_init: procedure(ctx: pBN_CTX); cdecl;
  BN_CTX_start: procedure(ctx: pBN_CTX); cdecl;
  BN_CTX_get: function(ctx: pBN_CTX): pBIGNUM; cdecl;
  BN_CTX_end: procedure(ctx: pBN_CTX); cdecl;
  BN_CTX_free: procedure(ctx: pBN_CTX); cdecl;
  BN_MONT_CTX_new: function: pBN_MONT_CTX; cdecl;
  BN_MONT_CTX_init: procedure(m_ctx: pBN_MONT_CTX); cdecl;
  BN_MONT_CTX_set: function(m_ctx: pBN_MONT_CTX;const modulus: pBIGNUM;
                                            ctx: pBN_CTX): cint; cdecl;
  BN_MONT_CTX_copy: function(_to: pBN_MONT_CTX;
                                  from: pBN_MONT_CTX): pBN_MONT_CTX; cdecl;
  BN_MONT_CTX_free: procedure(m_ctx: pBN_MONT_CTX); cdecl;
  BN_mod_mul_montgomery: function(r, a, b: pBIGNUM; m_ctx: pBN_MONT_CTX;
                                                 ctx: pBN_CTX): cint; cdecl;
  BN_from_montgomery: function(r, a: pBIGNUM; m_ctx: pBN_MONT_CTX;
                                                ctx: pBN_CTX): cint; cdecl;
  BN_RECP_CTX_init: procedure(recp: pBN_RECP_CTX); cdecl;
  BN_RECP_CTX_set: function(recp: pBN_RECP_CTX; const rdiv: pBIGNUM; 
                                             ctx: pBN_CTX): cint; cdecl;
  BN_RECP_CTX_new: function: pBN_RECP_CTX; cdecl;
  BN_RECP_CTX_free: procedure(recp: pBN_RECP_CTX); cdecl;
  BN_div_recp: function(dv, rem, a: pBIGNUM; recp: pBN_RECP_CTX;
                                               ctx: pBN_CTX): cint; cdecl;
  BN_mod_mul_reciprocal: function(r, a, b: pBIGNUM; recp: pBN_RECP_CTX;
                                                ctx: pBN_CTX): cint; cdecl;
  BN_BLINDING_new: function(a: pBIGNUM; Ai: pBIGNUM;
                                         _mod: pBIGNUM): pBN_BLINDING; cdecl;
  BN_BLINDING_update: function(b: pBN_BLINDING;
                                          ctx: pBN_CTX): pBN_BLINDING; cdecl;
  BN_BLINDING_free: procedure(b: pBN_BLINDING); cdecl;
  BN_BLINDING_convert: function(n: pBIGNUM; r: pBN_BLINDING;
                                                ctx: pBN_CTX): cint; cdecl;
  BN_BLINDING_invert: function(n: pBIGNUM; b: pBN_BLINDING;
                                               ctx: pBN_CTX): cint; cdecl;
  BN_copy: function(_to: pBIGNUM; const from: pBIGNUM): pBIGNUM; cdecl;
  BN_dup: function(const from: pBIGNUM): pBIGNUM; cdecl;
  BN_bn2bin: function(const n: pBIGNUM; _to: pointer): cint; cdecl;
  BN_bin2bn: function(const _from: pointer; len: cint;
                                               ret: pBIGNUM): pBIGNUM; cdecl;
  BN_bn2hex: function(const n: pBIGNUM): PCharacter; cdecl;
  BN_bn2dec: function(const n: pBIGNUM): PCharacter; cdecl;
  BN_hex2bn: function(var n: pBIGNUM; const str: PCharacter): cint; cdecl;
  BN_dec2bn: function(var n: pBIGNUM; const str: PCharacter): cint; cdecl;
  BN_bn2mpi: function(const a: pBIGNUM; _to: pointer): cint; cdecl;
  BN_mpi2bn: function(s: pointer; len: cint; ret: pBIGNUM): pBIGNUM; cdecl;
  BN_print: function(fp: pBIO; const a: pointer): cint; cdecl;
  // BN_print_fp: function(FILE *fp, const BIGNUM *a): cint; cdecl;
  BN_value_one: function: pBIGNUM; cdecl;
  BN_set_word: function(n: pBIGNUM; w: cardinal): cint; cdecl;
  BN_get_word: function(n: pBIGNUM): cardinal; cdecl;
  BN_cmp: function(a: pBIGNUM; b: pBIGNUM): cint; cdecl;
  BN_ucmp: function(a: pBIGNUM; b: pBIGNUM): cint; cdecl;
  BN_num_bits: function(const a: pBIGNUM): cint; cdecl;
  BN_num_bits_word: function(w: BN_ULONG): cint; cdecl;
  BN_add: function(r: pBIGNUM; const a, b: pBIGNUM): cint; cdecl;
  BN_sub: function(r: pBIGNUM; const a, b: pBIGNUM): cint; cdecl;
  BN_uadd: function(r: pBIGNUM; const a, b: pBIGNUM): cint; cdecl;
  BN_usub: function(r: pBIGNUM; const a, b: pBIGNUM): cint; cdecl;
  BN_mul: function(r: pBIGNUM; a: pBIGNUM; b: pBIGNUM;
                                             ctx: pBN_CTX): cint; cdecl;
  BN_sqr: function(r: pBIGNUM; a: pBIGNUM; ctx: pBN_CTX): cint; cdecl;
  BN_div: function(dv: pBIGNUM; rem: pBIGNUM; const a, d: pBIGNUM;
                                               ctx: pBN_CTX): cint; cdecl;
  BN_exp: function(r: pBIGNUM; a: pBIGNUM; p: pBIGNUM;
                                                 ctx: pBN_CTX): cint; cdecl;
  BN_mod_exp: function(r, a: pBIGNUM; const p, m: pBIGNUM;
                                                ctx: pBN_CTX): cint; cdecl;
  BN_gcd: function(r: pBIGNUM; a: pBIGNUM; b: pBIGNUM;
                                               ctx: pBN_CTX): cint; cdecl;
  // BN_nnmod requires OpenSSL >= 0.9.7
  BN_nnmod: function(rem: pBIGNUM; const a: pBIGNUM;
                             const m: pBIGNUM; ctx: pBN_CTX): cint; cdecl;
  // BN_mod_add requires OpenSSL >= 0.9.7
  BN_mod_add: function(r: pBIGNUM; a: pBIGNUM; b: pBIGNUM; 
                                const m: pBIGNUM; ctx: pBN_CTX): cint;cdecl;
  // BN_mod_sub requires OpenSSL >= 0.9.7
  BN_mod_sub: function(r: pBIGNUM; a: pBIGNUM; b: pBIGNUM;
                               const m: pBIGNUM; ctx: pBN_CTX): cint; cdecl;
  // BN_mod_mul requires OpenSSL >= 0.9.7
  BN_mod_mul: function(ret, a, b: pBIGNUM; const m: pBIGNUM;
                                                 ctx: pBN_CTX): cint; cdecl;
  // BN_mod_sqr requires OpenSSL >= 0.9.7
  BN_mod_sqr: function(r: pBIGNUM; a: pBIGNUM;
                               const m: pBIGNUM; ctx: pBN_CTX): cint; cdecl;
  BN_reciprocal: function(r, m: pBIGNUM; ctx: pBN_CTX): cint; cdecl;
  BN_mod_exp2_mont: function(r, a1, p1, a2, p2, m: pBIGNUM;
                             ctx: pBN_CTX; m_ctx: pBN_MONT_CTX): cint; cdecl;
  BN_mod_exp_mont: function(r, a: pBIGNUM; const p, m: pBIGNUM;
                            ctx: pBN_CTX; m_ctx: pBN_MONT_CTX): cint; cdecl;
  BN_mod_exp_mont_word: function(r: pBIGNUM; a: BN_ULONG;
        const p, m: pBIGNUM; ctx: pBN_CTX; m_ctx: pBN_MONT_CTX): cint; cdecl;
  BN_mod_exp_simple: function(r, a, p, m: pBIGNUM;
                                               ctx: pBN_CTX): cint; cdecl;
  BN_mod_exp_recp: function(r: pBIGNUM; const a, p, m: pBIGNUM;
                                           ctx: pBN_CTX): cint; cdecl;
  BN_mod_inverse: function(ret, a: pBIGNUM; const n: pBIGNUM;
                                             ctx: pBN_CTX): pBIGNUM; cdecl;
  BN_add_word: function (a: pBIGNUM; w: BN_ULONG): cint; cdecl; 
                                         // Adds w to a ("a+=w").
  BN_sub_word: function(a: pBIGNUM; w: BN_ULONG): cint; cdecl;
                                         // Subtracts w from a ("a-=w").
  BN_mul_word: function(a: pBIGNUM; w: BN_ULONG): cint; cdecl;
                                       // Multiplies a and w ("a*=b").
  BN_div_word: function(a: pBIGNUM; w: BN_ULONG): BN_ULONG; cdecl; 
                    // Divides a by w ("a/=w") and returns the remainder.
  BN_mod_word: function(const a: pBIGNUM; w: BN_ULONG): BN_ULONG; cdecl;
    // Returns the remainder of a divided by w ("a%m").
  bn_mul_words: function(rp, ap: pBN_ULONG; num: cint;
                                          w: BN_ULONG): BN_ULONG; cdecl;
  bn_mul_add_words: function(rp, ap: pBN_ULONG; num: cint; 
                                           w: BN_ULONG): BN_ULONG; cdecl;
  bn_sqr_words: procedure(rp, ap: pBN_ULONG; num: cint); cdecl;
  bn_div_words: function(h, l, d: BN_ULONG): BN_ULONG; cdecl;
  bn_add_words: function(rp, ap, bp: pBN_ULONG; num: cint): BN_ULONG; cdecl;
  bn_sub_words: function(rp, ap, bp: pBN_ULONG; num: cint): BN_ULONG; cdecl;
  bn_expand2: function(a: pBIGNUM; n: cint): pBIGNUM; cdecl;
  BN_set_bit: function(a: pBIGNUM; n: cint): cint; cdecl;
  BN_clear_bit: function(a: pBIGNUM; n: cint): cint; cdecl;
  BN_is_bit_set: function(const a: pBIGNUM; n: cint): cint; cdecl;
  BN_mask_bits: function(a: pBIGNUM; n: cint): cint; cdecl;
  BN_lshift: function(r: pBIGNUM; const a: pBIGNUM; n: cint): cint; cdecl;
  BN_lshift1: function(r: pBIGNUM; a: pBIGNUM): cint; cdecl;
  BN_rshift: function(r: pBIGNUM; const a: pBIGNUM; n: cint): cint; cdecl;
  BN_rshift1: function(r: pBIGNUM; a: pBIGNUM): cint; cdecl;
  BN_generate_prime: function (ret: pBIGNUM; num, safe: cint;
                          add, rem: pBIGNUM;
                           progress: TProgressCallbackFunction;
                                   cb_arg: pointer): pBIGNUM; cdecl;
  BN_is_prime: function(const a: pBIGNUM; checks: cint; 
                       progress: TProgressCallbackFunction; ctx: pBN_CTX;
                                            cb_arg: pointer): cint; cdecl;
  BN_is_prime_fasttest: function(const a: pBIGNUM; checks: cint;
                 progress: TProgressCallbackFunction; ctx: pBN_CTX;
                 cb_arg: pointer; do_trial_division: cint): cint; cdecl;
  BN_rand: function(rnd: pBIGNUM; bits, top, bottom: cint): cint; cdecl;
  BN_pseudo_rand: function(rnd: pBIGNUM;
                               bits, top, bottom: cint): cint; cdecl;
  BN_rand_range: function(rnd, range: pBIGNUM): cint; cdecl;
  // BN_pseudo_rand_range requires OpenSSL >= 0.9.6c
  BN_pseudo_rand_range: function(rnd, range: pBIGNUM): cint; cdecl;
  BN_bntest_rand: function(rnd: pBIGNUM;
                                bits, top, bottom: cint): cint; cdecl;
  BN_to_ASN1_INTEGER: function(bn: pBIGNUM;
                                   ai: pASN1_INTEGER): pASN1_INTEGER; cdecl;
  BN_to_ASN1_ENUMERATED: function(bn: pBIGNUM;
                             ai: pASN1_ENUMERATED): pASN1_ENUMERATED; cdecl;

function BN_to_montgomery(r, a: pBIGNUM; m_ctx: pBN_MONT_CTX;
                                                ctx: pBN_CTX): cint;
function BN_zero(n: pBIGNUM): cint;
function BN_one(n: pBIGNUM): cint;
function BN_num_bytes(const a: pBIGNUM): cint;
// BN_mod redefined as BN_div in some DLL version
function BN_mod(rem: pBIGNUM; const a, m: pBIGNUM; ctx: pBN_CTX): cint;

implementation
uses
 msedynload;
 
function BN_to_montgomery(r, a: pBIGNUM; m_ctx: pBN_MONT_CTX;
                                                  ctx: pBN_CTX): cint;
begin
  result := BN_mod_mul_montgomery(r, a, @(m_ctx^.RR), m_ctx, ctx);
end;

function BN_zero(n: pBIGNUM): cint;
begin
  result := BN_set_word(n, 0)
end;

function BN_one(n: pBIGNUM): cint;
begin
  result := BN_set_word(n, 1)
end;

function BN_num_bytes(const a: pBIGNUM): cint;
begin
  result := (BN_num_bits(a) + 7) div 8;
end;

function BN_mod(rem: pBIGNUM; const a, m: pBIGNUM; ctx: pBN_CTX): cint;
begin
  result := BN_div(nil, rem, a, m, ctx);
end;

procedure init(const info: dynlibinfoty);
const
 funcs: array[0..101] of funcinfoty = (
   (n: 'BN_new'; d: @BN_new),
   (n: 'BN_init'; d: @BN_init),
   (n: 'BN_clear'; d: @BN_clear),
   (n: 'BN_free'; d: @BN_free),
   (n: 'BN_clear_free'; d: @BN_clear_free),
   (n: 'BN_set_params'; d: @BN_set_params),
   (n: 'BN_get_params'; d: @BN_get_params),
   (n: 'BN_options'; d: @BN_options),
   (n: 'BN_CTX_new'; d: @BN_CTX_new),
   (n: 'BN_CTX_init'; d: @BN_CTX_init),
   (n: 'BN_CTX_start'; d: @BN_CTX_start),
   (n: 'BN_CTX_get'; d: @BN_CTX_get),
   (n: 'BN_CTX_end'; d: @BN_CTX_end),
   (n: 'BN_CTX_free'; d: @BN_CTX_free),
   (n: 'BN_MONT_CTX_new'; d: @BN_MONT_CTX_new),
   (n: 'BN_MONT_CTX_init'; d: @BN_MONT_CTX_init),
   (n: 'BN_MONT_CTX_set'; d: @BN_MONT_CTX_set),
   (n: 'BN_MONT_CTX_copy'; d: @BN_MONT_CTX_copy),
   (n: 'BN_MONT_CTX_free'; d: @BN_MONT_CTX_free),
   (n: 'BN_mod_mul_montgomery'; d: @BN_mod_mul_montgomery),
   (n: 'BN_from_montgomery'; d: @BN_from_montgomery),
   (n: 'BN_RECP_CTX_init'; d: @BN_RECP_CTX_init),
   (n: 'BN_RECP_CTX_set'; d: @BN_RECP_CTX_set),
   (n: 'BN_RECP_CTX_new'; d: @BN_RECP_CTX_new),
   (n: 'BN_RECP_CTX_free'; d: @BN_RECP_CTX_free),
   (n: 'BN_div_recp'; d: @BN_div_recp),
   (n: 'BN_mod_mul_reciprocal'; d: @BN_mod_mul_reciprocal),
   (n: 'BN_BLINDING_new'; d: @BN_BLINDING_new),
   (n: 'BN_BLINDING_update'; d: @BN_BLINDING_update),
   (n: 'BN_BLINDING_free'; d: @BN_BLINDING_free),
   (n: 'BN_BLINDING_convert'; d: @BN_BLINDING_convert),
   (n: 'BN_BLINDING_invert'; d: @BN_BLINDING_invert),
   (n: 'BN_copy'; d: @BN_copy),
   (n: 'BN_dup'; d: @BN_dup),
   (n: 'BN_bn2bin'; d: @BN_bn2bin),
   (n: 'BN_bin2bn'; d: @BN_bin2bn),
   (n: 'BN_bn2hex'; d: @BN_bn2hex),
   (n: 'BN_bn2dec'; d: @BN_bn2dec),
   (n: 'BN_hex2bn'; d: @BN_hex2bn),
   (n: 'BN_dec2bn'; d: @BN_dec2bn),
   (n: 'BN_bn2mpi'; d: @BN_bn2mpi),
   (n: 'BN_mpi2bn'; d: @BN_mpi2bn),
   (n: 'BN_print'; d: @BN_print),
   (n: 'BN_value_one'; d: @BN_value_one),
   (n: 'BN_set_word'; d: @BN_set_word),
   (n: 'BN_get_word'; d: @BN_get_word),
   (n: 'BN_cmp'; d: @BN_cmp),
   (n: 'BN_ucmp'; d: @BN_ucmp),
   (n: 'BN_num_bits'; d: @BN_num_bits),
   (n: 'BN_num_bits_word'; d: @BN_num_bits_word),
   (n: 'BN_add'; d: @BN_add),
   (n: 'BN_sub'; d: @BN_sub),
   (n: 'BN_uadd'; d: @BN_uadd),
   (n: 'BN_usub'; d: @BN_usub),
   (n: 'BN_mul'; d: @BN_mul),
   (n: 'BN_sqr'; d: @BN_sqr),
   (n: 'BN_div'; d: @BN_div),
   (n: 'BN_exp'; d: @BN_exp),
   (n: 'BN_mod_exp'; d: @BN_mod_exp),
   (n: 'BN_gcd'; d: @BN_gcd),
   (n: 'BN_nnmod'; d: @BN_nnmod),
   (n: 'BN_mod_add'; d: @BN_mod_add),
   (n: 'BN_mod_sub'; d: @BN_mod_sub),
   (n: 'BN_mod_mul'; d: @BN_mod_mul),
   (n: 'BN_mod_sqr'; d: @BN_mod_sqr),
   (n: 'BN_reciprocal'; d: @BN_reciprocal),
   (n: 'BN_mod_exp2_mont'; d: @BN_mod_exp2_mont),
   (n: 'BN_mod_exp_mont'; d: @BN_mod_exp_mont),
   (n: 'BN_mod_exp_mont_word'; d: @BN_mod_exp_mont_word),
   (n: 'BN_mod_exp_simple'; d: @BN_mod_exp_simple),
   (n: 'BN_mod_exp_recp'; d: @BN_mod_exp_recp),
   (n: 'BN_mod_inverse'; d: @BN_mod_inverse),
   (n: 'BN_add_word'; d: @BN_add_word),
   (n: 'BN_sub_word'; d: @BN_sub_word),
   (n: 'BN_mul_word'; d: @BN_mul_word),
   (n: 'BN_div_word'; d: @BN_div_word),
   (n: 'BN_mod_word'; d: @BN_mod_word),
   (n: 'bn_mul_words'; d: @bn_mul_words),
   (n: 'bn_mul_add_words'; d: @bn_mul_add_words),
   (n: 'bn_sqr_words'; d: @bn_sqr_words),
   (n: 'bn_div_words'; d: @bn_div_words),
   (n: 'bn_add_words'; d: @bn_add_words),
   (n: 'bn_sub_words'; d: @bn_sub_words),
   (n: 'bn_expand2'; d: @bn_expand2),
   (n: 'BN_set_bit'; d: @BN_set_bit),
   (n: 'BN_clear_bit'; d: @BN_clear_bit),
   (n: 'BN_is_bit_set'; d: @BN_is_bit_set),
   (n: 'BN_mask_bits'; d: @BN_mask_bits),
   (n: 'BN_lshift'; d: @BN_lshift),
   (n: 'BN_lshift1'; d: @BN_lshift1),
   (n: 'BN_rshift'; d: @BN_rshift),
   (n: 'BN_rshift1'; d: @BN_rshift1),
   (n: 'BN_generate_prime'; d: @BN_generate_prime),
   (n: 'BN_is_prime'; d: @BN_is_prime),
   (n: 'BN_is_prime_fasttest'; d: @BN_is_prime_fasttest),
   (n: 'BN_rand'; d: @BN_rand),
   (n: 'BN_pseudo_rand'; d: @BN_pseudo_rand),
   (n: 'BN_rand_range'; d: @BN_rand_range),
   (n: 'BN_pseudo_rand_range'; d: @BN_pseudo_rand_range),
   (n: 'BN_bntest_rand'; d: @BN_bntest_rand),
   (n: 'BN_to_ASN1_INTEGER'; d: @BN_to_ASN1_INTEGER),
   (n: 'BN_to_ASN1_ENUMERATED'; d: @BN_to_ASN1_ENUMERATED)
   );
begin
 getprocaddresses(info.libhandle,funcs);
end;

initialization
 regopensslinit(@init);
end.
