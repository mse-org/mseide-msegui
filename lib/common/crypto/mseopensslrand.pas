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

implementation
uses
 msedynload;

procedure init(const info: dynlibinfoty);
const
 funcs: array[0..5] of funcinfoty = (
   (n: 'RAND_seed'; d: @RAND_seed),
   (n: 'RAND_add'; d: @RAND_add),
   (n: 'RAND_status'; d: @RAND_status),
   (n: 'RAND_file_name'; d: @RAND_file_name),
   (n: 'RAND_load_file'; d: @RAND_load_file),
   (n: 'RAND_write_file'; d: @RAND_write_file)
  );
begin
 getprocaddresses(info.libhandle,funcs);
end;

initialization
 regopensslinit(@init);
end.
