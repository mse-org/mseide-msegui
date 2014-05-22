{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msedoublestringlisteditor;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 mseforms,msedataedits,msesimplewidgets,msewidgetgrid,msegrids,mseedit,mseglob,
 msegui,mseguiglob,mseifiglob,msememodialog,msemenus,msestrings,msetypes,
 msedialog,msestat,msestatfile;
type
 tdoublestringlisteditor = class(tmseform)
   cancel: tbutton;
   ok: tbutton;
   grid: twidgetgrid;
   rowcount: tintegeredit;
   textb: tmemodialogedit;
   texta: tmemodialogedit;
   tstatfile1: tstatfile;
   procedure rowcountonsetvalue(const sender: tobject; var avalue: integer;
                var accept: boolean);
   procedure gridonrowcountchanged(const sender: tcustomgrid);
  public
   constructor create(const aonclosequery: closequeryeventty); reintroduce;
 end;

implementation
uses
 msedoublestringlisteditor_mfm;

{ tdoublestringlisteditor }

constructor tdoublestringlisteditor.create(const aonclosequery: closequeryeventty);
begin
 onclosequery:= aonclosequery;
 inherited create(nil);
end;

procedure tdoublestringlisteditor.gridonrowcountchanged(
  const sender: tcustomgrid);
begin
 rowcount.value:= sender.rowcount;
end;

procedure tdoublestringlisteditor.rowcountonsetvalue(const sender: tobject;
  var avalue: integer; var accept: boolean);
begin
 grid.rowcount:= avalue;
end;

end.
