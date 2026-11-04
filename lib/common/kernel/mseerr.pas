{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseerr;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
{$R-}{$Q-}
//helpers for errormessages
interface

uses
 SysUtils;

type
 eerror = class(exception)
  protected
   ferror: integer;
  public
   text: string;
   constructor create(error: integer; atext: string;
                           const errortexts: array of string);
   property error: integer read ferror;
 end;

implementation
uses
 msetypes{msestrings};

{ eerror }

constructor eerror.create(error: integer; atext: string;
                const errortexts: array of string);
var
 ch1: char;
begin
 ferror:= error;
 text:= atext;
 if text = '' then begin
  inherited create(errortexts[error]+'.');
 end
  else begin
  if (error >= 0) and (error <= high(errortexts)) then begin
   text:= errortexts[error]+ ' ' + text;
  end
  else begin
   text:= 'unknown error '+inttostr(error)+' '+ text;
  end;
  inherited create(text);
 end;
end;

end.





