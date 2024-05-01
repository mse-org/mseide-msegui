{ MSEgui Copyright (c) 1999-2008 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mserealenter;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 mseglob,mseforms,msedataedits,msesimplewidgets,msetypes,mseguiglob,msegui,msedialog,
 msereal,msestrings;

type
 trealenterfo = class(tdialogform)
   value: trealedit;
   lab: tlabel;
   ok: tbutton;
   cancel: tbutton;
 end;

// function realenter(var avalue: realty; const amin,amax: realty; const text: msestring = '';
//                               const acaption: msestring = ''): modalresultty;
////////////////////////////////////////////
function realenter(var avalue: realty; const amin,amax: realty; const text: msestring = '';
                   const acaption: msestring = '';
                   providedform: tintegerenterfo = nil): modalresultty;
////////////////////////////////////////////
//threadsave
implementation
uses
 mserealenter_mfm;

// function realenter(var avalue: realty; const amin,amax: realty; const text: msestring = '';
//                               const acaption: msestring = ''): modalresultty;
////////////////////////////////////////////
function realenter(var avalue: realty; const amin,amax: realty; const text: msestring = '';
                   const acaption: msestring = '';
                   providedform: tintegerenterfo = nil): modalresultty;
////////////////////////////////////////////
var
 fo: trealenterfo;
begin
 application.lock;
 try
////////////////////////////////////////////
  if assigned (providedform)
   then fo:= providedform
   else
////////////////////////////////////////////
  fo:= trealenterfo.create(nil);
  try
   with fo do begin
    value.min:= amin;
    value.max:= amax;
    value.value:= avalue;
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
