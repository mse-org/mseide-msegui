{ MSEgui Copyright (c) 1999-2008 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseintegerenter;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

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

// function integerenter(var avalue: integer; const amin,amax: integer;
//         const text: msestring = ''; const acaption: msestring = ''): modalresultty;
////////////////////////////////////////////
function integerenter(var avalue: integer; const amin,amax: integer;
         const text: msestring = ''; const acaption: msestring = '';
         providedform: tintegerenterfo = nil): modalresultty;
////////////////////////////////////////////
//threadsave
implementation
uses
 mseintegerenter_mfm;

// function integerenter(var avalue: integer; const amin,amax: integer; const text: msestring = '';
//                               const acaption: msestring = ''): modalresultty;
////////////////////////////////////////////
function integerenter(var avalue: integer; const amin,amax: integer; const text: msestring = '';
                      const acaption: msestring = '';
                      providedform: tintegerenterfo = nil): modalresultty;
////////////////////////////////////////////
var
 fo: tintegerenterfo;
begin
 application.lock;
 try
////////////////////////////////////////////
  if assigned (providedform)
   then fo:= providedform
   else
////////////////////////////////////////////
  fo:= tintegerenterfo.create(nil);
  try
   with fo do begin
    value.value:= avalue;
    value.valuemin:= amin;
    value.valuemax:= amax;
    caption:= acaption;
    lab.caption:= text;
    result:= fo.show(true,nil);
    if result = mr_ok then begin
     avalue:= value.value;
    end;
   end;
  finally
////////////////////////////////////////////
   if not assigned (providedform) then
////////////////////////////////////////////
   fo.Free;
  end;
 finally
  application.unlock;
 end;
end;

end.
