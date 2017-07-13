{ MSEgui Copyright (c) 2015 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}

unit msestrmacros;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msemacros;

function strmacros(): macroinfoarty;

implementation
uses
 mseprocess,mseprocutils,msefileutils,msetypes{msestrings},sysutils;

var
 fstrmacros: macroinfoarty;

function strmacros(): macroinfoarty;
begin
 result:= fstrmacros;
end;

function str_trim(const sender: tmacrolist; 
                           const params: msestringarty): msestring;
begin
 result:= '';
 if params <> nil then begin
  result:= trim(sender.expandmacros(params[0]));
 end;
end;

function str_trimleft(const sender: tmacrolist; 
                           const params: msestringarty): msestring;
begin
 result:= '';
 if params <> nil then begin
  result:= trimleft(sender.expandmacros(params[0]));
 end;
end;

function str_trimright(const sender: tmacrolist; 
                           const params: msestringarty): msestring;
begin
 result:= '';
 if params <> nil then begin
  result:= trimright(sender.expandmacros(params[0]));
 end;
end;

function str_coalesce(const sender: tmacrolist; 
                           const params: msestringarty): msestring;
var
 i1: int32;
begin
 result:= '';
 if params <> nil then begin
  for i1:= 0 to high(params) do begin
   result:= sender.expandmacros(params[i1]);
   if result <> '' then begin
    break;
   end;
  end;
 end;
end;

const
 strmacroconst: array[0..3] of macroinfoty = (
  (name: 'STR_TRIM'; value: ''; handler: macrohandlerty(@str_trim);
                     expandlevel: 0),
  (name: 'STR_TRIMLEFT'; value: ''; handler: macrohandlerty(@str_trimleft);
                     expandlevel: 0),
  (name: 'STR_TRIMRIGHT'; value: ''; handler: macrohandlerty(@str_trimright);
                     expandlevel: 0),
  (name: 'STR_COALESCE'; value: ''; handler: macrohandlerty(@str_coalesce);
                     expandlevel: 0)
 );

procedure initexecmacros();
var
 int1: integer;
begin
 setlength(fstrmacros,length(strmacroconst));
 for int1:= 0 to high(strmacroconst) do begin
  fstrmacros[int1]:= strmacroconst[int1];
 end;
end;

initialization
 initexecmacros();
end.
