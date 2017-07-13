{ MSEgui Copyright (c) 2015 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}

unit msemacmacros;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msemacros;

function macmacros(): macroinfoarty;

implementation
uses
 msetypes{msestrings},msesysintf;

var
 fmacmacros: macroinfoarty;

function macmacros(): macroinfoarty;
begin
 result:= fmacmacros;
end;

function mac_ifdef(const sender: tmacrolist; 
                                      const params: msestringarty): msestring;
                                      //name,[ifndef value[,ifdef value]]
var
 po1: pmacroinfoty;
begin
 result:= '';
 if params <> nil then begin
  if sender.find(params[0],po1) then begin
   if high(params) > 1 then begin
    result:= params[2];
   end
   else begin
    result:= po1^.value;
   end;
  end
  else begin
   if high(params) > 0 then begin
    result:= params[1];
   end;
  end;
 end;
end;

const
 macmacroconst: array[0..0] of macroinfoty = (
  (name: 'MAC_IFDEF'; value: ''; handler: macrohandlerty(@mac_ifdef);
                     expandlevel: 0)
 );

procedure initmacmacros();
var
 int1: integer;
begin
 setlength(fmacmacros,length(macmacroconst));
 for int1:= 0 to high(macmacroconst) do begin
  fmacmacros[int1]:= macmacroconst[int1];
 end;
end;

initialization
 initmacmacros();
end.
