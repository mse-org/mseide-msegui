{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseintegerenter;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 mseforms,msedataedits,msesimplewidgets,msetypes,mseglob,mseguiglob,msegui,
 msedialog,msestrings;

type
 tintegerenterfo = class(tdialogform)
   lab: tlabel;
   ok: tbutton;
   cancel: tbutton;
   value: tintegeredit;
 end;

function integerenter(var avalue: integer; const amin,amax: integer;
         const text: msestring = ''; const acaption: msestring = ''): modalresultty;
implementation
uses
 mseintegerenter_mfm;

function integerenter(var avalue: integer; const amin,amax: integer; const text: msestring = '';
                               const acaption: msestring = ''): modalresultty;
var
 fo: tintegerenterfo;
begin
 fo:= tintegerenterfo.create(nil);
 try
  with fo do begin
   value.value:= avalue;
   value.min:= amin;
   value.max:= amax;
   caption:= acaption;
   lab.caption:= text;
   result:= fo.show(true,nil);
   if result = mr_ok then begin
    avalue:= value.value;
   end;
  end;
 finally
  fo.Free;
 end;
end;

end.
