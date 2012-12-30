{ MSEgui Copyright (c) 1999-2008 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msestringenter;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 mseforms,msedataedits,msesimplewidgets,msetypes,msegui,mseglob,mseguiglob,
 msedialog,msestrings,msestringcontainer;

type
 tstringenterfo = class(tdialogform)
   value: tstringedit;
   lab: tlabel;
   ok: tbutton;
   cancel: tbutton;
   c: tstringcontainer;
 end;

//functions below are threadsave
function stringenter(var avalue: msestring; const text: msestring = '';
                               const acaption: msestring = ''): modalresultty;

function checkpassword(const password: msestring): boolean; overload;
function checkpassword(const password: msestring; var modalresult: modalresultty): boolean; overload;

implementation
uses
 msestringenter_mfm,msewidgets;

type
 stringconststy = (
  str_password,       //0 PASSWORD
  enterpassword,      //1 Enter password
  invalidpassword     //2 Invalid password!
 );
 
function stringenter(var avalue: msestring; const text: msestring = '';
                               const acaption: msestring = ''): modalresultty;
var
 fo: tstringenterfo;
begin
 application.lock;
 try
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
 finally
  application.unlock;
 end;
end;

function checkpassword(const password: msestring; var modalresult: modalresultty): boolean;
var
 fo: tstringenterfo;
begin
 application.lock;
 try
  fo:= tstringenterfo.create(nil);
  try
   with fo do begin
    caption:= c[ord(str_password)];
    lab.caption:= c[ord(enterpassword)]+':';
    value.passwordchar:= '*';
    value.value:= '';
    modalresult:= fo.show(true,nil);
    result:= (modalresult = mr_ok) and (password = value.value);
    if not result and (modalresult = mr_ok) then begin
     showerror(c[ord(invalidpassword)]);
    end;
   end;
  finally
   fo.Free;
  end;
 finally
  application.unlock;
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
