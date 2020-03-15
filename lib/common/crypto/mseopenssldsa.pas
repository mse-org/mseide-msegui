{ MSEgui Copyright (c) 2007-2012 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseopenssldsa;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseopenssl,msectypes;
type
  pDSA = ^DSA;
  DSA = record
	// This first variable is used to pick up errors where
	// a DSA is passed instead of of a EVP_PKEY
	pad: cint;
	version: cint;
	write_params: cint;
	p: pointer;
	q: pointer;	// = 20
	g: pointer;
	pub_key: pointer;  // y public key
	priv_key: pointer; // x private key
	kinv: pointer;	// Signing pre-calc
	r: pointer;	// Signing pre-calc
	flags: cint;
	// Normally used to cache montgomery values
	method_mont_p: PCharacter;
	references: cint;
	ex_data: record
      sk: pointer;
      dummy: cint;
      end;
	meth: pointer;
  end;

var
 DSA_new: function: pDSA; cdecl;
 DSA_free: procedure(r: pDSA); cdecl;
 DSA_generate_parameters: function(bits: cint; seed: pointer;
           seed_len: cint;var counter_ret: cint; var h_ret: culong;
            progress: TProgressCallbackFunction; cb_arg: Pointer): pDSA; cdecl;
 DSA_generate_key: function(a: pDSA): cint; cdecl;
 d2i_DSAPrivateKey_bio: function(bp: pBIO; dsa: pDSA): pDSA; cdecl;
 i2d_DSAPrivateKey_bio: function(bp: pBIO; dsa: pDSA): cint; cdecl;

implementation
uses
 msedynload;

procedure init(const info: dynlibinfoty);
const
 funcs: array[0..5] of funcinfoty = (
   (n: 'DSA_new'; d: @DSA_new),
   (n: 'DSA_free'; d: @DSA_free),
   (n: 'DSA_generate_parameters'; d: @DSA_generate_parameters),
   (n: 'DSA_generate_key'; d: @DSA_generate_key),
   (n:  'd2i_DSAPrivateKey_bio'; d: @d2i_DSAPrivateKey_bio),
   (n:  'i2d_DSAPrivateKey_bio'; d: @i2d_DSAPrivateKey_bio)
  );
begin
 getprocaddresses(info,funcs);
end;

initialization
 regopensslinit(@init);
end.
