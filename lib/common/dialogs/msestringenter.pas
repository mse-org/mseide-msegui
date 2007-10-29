{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msestringenter;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 mseforms,msedataedits,msesimplewidgets,msetypes,
 msegui,mseglob,mseguiglob,msedialog,msestrings;

type
 tstringenterfo = class(tdialogform)
   value: tstringedit;
   lab: tlabel;
   ok: tbutton;
   cancel: tbutton;
 end;

function stringenter(var avalue: msestring; const text: msestring = '';
                               const acaption: msestring = ''): modalresultty;

function checkpassword(const password: msestring): boolean; overload;
function checkpassword(const password: msestring; var modalresult: modalresultty): boolean; overload;

implementation
uses
 msestringenter_mfm,msewidgets;

function stringenter(var avalue: msestring; const text: msestring = '';
                               const acaption: msestring = ''): modalresultty;
var
 fo: tstringenterfo;
begin
 fo:= tstringenterfo.create(nil);
 try
  with fo do begin
   value.value:= avalue;
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

function checkpassword(const password: msestring; var modalresult: modalresultty): boolean;
var
 fo: tstringenterfo;
begin
 fo:= tstringenterfo.create(nil);
 try
  with fo do begin
   caption:= 'PASSWORD';
   lab.caption:= 'Enter password:';
   value.passwordchar:= '*';
   value.value:= '';
   modalresult:= fo.show(true,nil);
   result:= (modalresult = mr_ok) and (password = value.value);
   if not result and (modalresult = mr_ok) then begin
    showerror('Invalid password!');
   end;
  end;
 finally
  fo.Free;
 end;
end;

function checkpassword(const password: msestring): boolean;
var
 res: modalresultty;
begin
 repeat
  result:= checkpassword(password,res);
 until result or (res <> mr_ok);
end;

end.
