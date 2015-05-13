{ MSEgui Copyright (c) 2015 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}

unit mseenvmacros;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msemacros;

function envmacros(): macroinfoarty;

implementation
uses
 msestrings,msesysintf;

var
 fenvmacros: macroinfoarty;

function envmacros(): macroinfoarty;
begin
 result:= fenvmacros;
end;

function env_var(const params: msestringarty): msestring;
begin
 result:= '';
 if params <> nil then begin
  sys_getenv(params[0],result);
 end;
end;

const
 envmacroconst: array[0..0] of macroinfoty = (
  (name: 'ENV_VAR'; value: ''; handler: macrohandlerty(@env_var);
                     expandlevel: 0)
 );

procedure initenvmacros();
var
 int1: integer;
begin
 setlength(fenvmacros,length(envmacroconst));
 for int1:= 0 to high(envmacroconst) do begin
  fenvmacros[int1]:= envmacroconst[int1];
 end;
end;

initialization
 initenvmacros();
end.
