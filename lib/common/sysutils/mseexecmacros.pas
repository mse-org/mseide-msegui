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
 mseprocess,mseprocutils,msefileutils,msetypes{msestrings},mseformatstr;

var
 fexecmacros: macroinfoarty;

function execmacros(): macroinfoarty;
begin
 result:= fexecmacros;
end;

function exec_out(const sender: tmacrolist;
                           const params: msestringarty): msestring;
const
 defaulttimeout = 1000000; //1 second
var
 str1: string;
 i1: int32;
begin
 result:= '';
 if params <> nil then begin
  i1:= defaulttimeout;
  if high(params) >= 1 then begin
   if trystrtoint(params[1],i1) then begin
    i1:= i1 * 1000;
   end
   else begin
    i1:= defaulttimeout;
   end;
  end;
  getprocessoutput(syscommandline(params[0]),'',str1,i1);
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
