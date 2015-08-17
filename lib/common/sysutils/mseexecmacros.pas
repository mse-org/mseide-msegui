{ MSEgui Copyright (c) 2015 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}

unit mseexecmacros;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msemacros;

function execmacros(): macroinfoarty;

implementation
uses
 mseprocess,mseprocutils,msefileutils,msestrings;

var
 fexecmacros: macroinfoarty;

function execmacros(): macroinfoarty;
begin
 result:= fexecmacros;
end;

function exec_out(const sender: tmacrolist; 
                           const params: msestringarty): msestring;
var
 str1: string;
begin
 result:= '';
 if params <> nil then begin
  getprocessoutput(syscommandline(params[0]),'',str1,1000000);
  result:= msestring(str1);
 end;
end;

const
 execmacroconst: array[0..0] of macroinfoty = (
  (name: 'EXEC_OUT'; value: ''; handler: macrohandlerty(@exec_out);
                     expandlevel: 0) //processoutput
 );

procedure initexecmacros();
var
 int1: integer;
begin
 setlength(fexecmacros,length(execmacroconst));
 for int1:= 0 to high(execmacroconst) do begin
  fexecmacros[int1]:= execmacroconst[int1];
 end;
end;

initialization
 initexecmacros();
end.
