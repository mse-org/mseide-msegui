{ MSEgui Copyright (c) 2007-2012 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseopensslrand;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseopenssl,msectypes;

var
 // pseudo-random number generator (PRNG) functions
 RAND_seed: procedure(const buf: pointer; num: cint); cdecl;
 RAND_add: procedure(const buf: pointer; num: cint; entropy: double); cdecl;
 RAND_status: function: cint; cdecl;
 // RAND_event: function(UINT iMsg, WPARAM wParam, LPARAM lParam): cint; cdecl;
 RAND_file_name: function(buf: PCharacter; size_t: cardinal): PCharacter; cdecl;
 RAND_load_file: function(const filename: PCharacter; max_bytes: clong): cint; cdecl;
 RAND_write_file: function(const filename: PCharacter): cint; cdecl;

 RAND_set_rand_engine: function(engine: pENGINE): cint; cdecl;

 RAND_bytes: function(buf: pbyte; num: cint): cint; cdecl;
 RAND_pseudo_bytes: function(buf: pbyte; num: cint): cint; cdecl;

 RAND_egd: function(path: pchar): cint; cdecl;

 RAND_set_rand_method: procedure(meth: pRAND_METHOD); cdecl;
 RAND_get_rand_method: function(): pRAND_METHOD; cdecl;
 RAND_SSLeay: function(): pRAND_METHOD; cdecl;

 RAND_cleanup: procedure(); cdecl;

implementation
uses
 msedynload;

procedure init(const info: dynlibinfoty);
const
 funcs: array[0..13] of funcinfoty = (
   (n: 'RAND_seed'; d: {$ifndef FPC}@{$endif}@RAND_seed),
   (n: 'RAND_add'; d: {$ifndef FPC}@{$endif}@RAND_add),
   (n: 'RAND_status'; d: {$ifndef FPC}@{$endif}@RAND_status),
   (n: 'RAND_file_name'; d: {$ifndef FPC}@{$endif}@RAND_file_name),
   (n: 'RAND_load_file'; d: {$ifndef FPC}@{$endif}@RAND_load_file),
   (n: 'RAND_write_file'; d: {$ifndef FPC}@{$endif}@RAND_write_file),
   (n: 'RAND_set_rand_engine'; d: {$ifndef FPC}@{$endif}@RAND_set_rand_engine),
   (n: 'RAND_bytes'; d: {$ifndef FPC}@{$endif}@RAND_bytes),
   (n: 'RAND_pseudo_bytes'; d: {$ifndef FPC}@{$endif}@RAND_pseudo_bytes),
   (n: 'RAND_egd'; d: {$ifndef FPC}@{$endif}@RAND_egd),
   (n: 'RAND_set_rand_method'; d: {$ifndef FPC}@{$endif}@RAND_set_rand_method),
   (n: 'RAND_get_rand_method'; d: {$ifndef FPC}@{$endif}@RAND_get_rand_method),
   (n: 'RAND_SSLeay'; d: {$ifndef FPC}@{$endif}@RAND_SSLeay),
   (n: 'RAND_cleanup'; d: {$ifndef FPC}@{$endif}@RAND_cleanup)
  );
begin
 getprocaddresses(info,funcs);
end;

initialization
 regopensslinit(@init);
end.
