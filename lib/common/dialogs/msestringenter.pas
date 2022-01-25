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
 msedialog,msestrings,msestringcontainer,msemenus,msesplitter,msegraphics,
 msegraphutils,msewidgets,mseapplication,mseedit,mseificomp,mseificompglob,
 mseifiglob,msestat,msestatfile,msestream,sysutils;

type
 tstringenterfo = class(tdialogform)
   lab: tlabel;
   tlayouter1: tlayouter;
   cancel: tbutton;
   ok: tbutton;
   value: tstringedit;
   procedure layoutexe(const sender: TObject);
 end;

//functions below are threadsave
function stringenter(var avalue: msestring; const text: msestring = '';
                               const acaption: msestring = ''): modalresultty;

function checkpassword(const password: msestring): boolean; overload;
function checkpassword(const password: msestring; var modalresult: modalresultty): boolean; overload;

implementation
uses
 msestringenter_mfm,
{$ifdef mse_dynpo}
 msestockobjects_dynpo;
{$else}
 msestockobjects;
{$endif}

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
{$ifdef mse_dynpo}
    caption:= lang_stockcaption[ord(sc_passwordupper)];
    lab.caption:= lang_stockcaption[ord(sc_enterpassword)]+':';
{$else}
    caption:= sc(sc_passwordupper);
    lab.caption:= sc(sc_enterpassword)+':';
{$endif}
    value.passwordchar:= '*';
    value.value:= '';
    modalresult:= fo.show(true,nil);
    result:= (modalresult = mr_ok) and (password = value.value);
    if not result and (modalresult = mr_ok) then begin
{$ifdef mse_dynpo}
     showerror(lang_stockcaption[ord(sc_invalidpassword)]);
{$else}
     showerror(sc(sc_invalidpassword));
{$endif}
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
 res:= mr_none;
 repeat
  result:= checkpassword(password,res);
 until result or (res <> mr_ok);
end;

procedure tstringenterfo.layoutexe(const sender: TObject);
begin
 optionswidget1:= optionswidget1-[ow1_autoheight]; //only on startup
end;

end.
