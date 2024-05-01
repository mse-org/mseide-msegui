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
////////////////////////////////////////////
   FUNCTION  getvalue: string;
   PROCEDURE setvalue (text: string);
   FUNCTION  gettagname: string;
   PROCEDURE settagname (text: string);
////////////////////////////////////////////
  published
   property text:    string read getvalue   write setvalue;
   property tagname: string read gettagname write settagname;
////////////////////////////////////////////
 end;

//functions below are threadsave
// function stringenter(var avalue: msestring; const text: msestring = '';
//                               const acaption: msestring = ''): modalresultty;
////////////////////////////////////////////
function stringenter(var avalue: msestring; const text: msestring = '';
                               const acaption: msestring = '';
                               providedform: tstringenterfo = nil): modalresultty;
////////////////////////////////////////////

// function checkpassword(const password: msestring): boolean; overload;
////////////////////////////////////////////
function checkpassword(const password: msestring;
                       providedform: tstringenterfo = nil): boolean; overload;
////////////////////////////////////////////
// function checkpassword(const password: msestring; var modalresult: modalresultty): boolean;
////////////////////////////////////////////
function checkpassword(const password: msestring; var modalresult: modalresultty;
                       providedform: tstringenterfo = nil): boolean;
////////////////////////////////////////////

implementation
uses
 msestringenter_mfm,msestockobjects;

// function stringenter(var avalue: msestring; const text: msestring = '';
//                               const acaption: msestring = ''): modalresultty;
////////////////////////////////////////////
function stringenter(var avalue: msestring; const text: msestring = '';
                               const acaption: msestring = '';
                               providedform: tstringenterfo = nil): modalresultty;
////////////////////////////////////////////
var
 fo: tstringenterfo;
begin
 application.lock;
 try
////////////////////////////////////////////
  if assigned (providedform)
   then fo:= providedform
   else
////////////////////////////////////////////
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
////////////////////////////////////////////
   if not assigned (providedform) then
////////////////////////////////////////////
   fo.Free;
  end;
 finally
  application.unlock;
 end;
end;

// function checkpassword(const password: msestring; var modalresult: modalresultty): boolean;
////////////////////////////////////////////
function checkpassword(const password: msestring; var modalresult: modalresultty;
                       providedform: tstringenterfo = nil): boolean;
////////////////////////////////////////////
var
 fo: tstringenterfo;
begin
 application.lock;
 try
////////////////////////////////////////////
  if assigned (providedform)
   then fo:= providedform
   else
////////////////////////////////////////////
  fo:= tstringenterfo.create(nil);
  try
   with fo do begin
    caption:= sc(sc_passwordupper);
    lab.caption:= sc(sc_enterpassword)+':';
    value.passwordchar:= '*';
    value.value:= '';
    modalresult:= fo.show(true,nil);
    result:= (modalresult = mr_ok) and (password = value.value);
    if not result and (modalresult = mr_ok) then begin
     showerror(sc(sc_invalidpassword));
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

////////////////////////////////////////////
FUNCTION tstringenterfo.getvalue: string;
 begin
   getvalue:= value.value;
 end;

PROCEDURE tstringenterfo.setvalue (text: string);
 begin
   value.value:= text;
 end;

FUNCTION tstringenterfo.gettagname: string;
 begin
   gettagname:= lab.caption;
 end;

PROCEDURE tstringenterfo.settagname (text: string);
 begin
   lab.caption:= text;
 end;
////////////////////////////////////////////

// function checkpassword(const password: msestring): boolean;
////////////////////////////////////////////
function checkpassword(const password: msestring;
                       providedform: tstringenterfo = nil): boolean; overload;
////////////////////////////////////////////
var
 res: modalresultty;
begin
 res:= mr_none;
 repeat
  result:= checkpassword(password,res, providedform);
 until result or (res <> mr_ok);
end;

procedure tstringenterfo.layoutexe(const sender: TObject);
begin
 optionswidget1:= optionswidget1-[ow1_autoheight]; //only on startup
end;

end.
