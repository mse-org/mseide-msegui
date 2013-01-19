{ MSEgui Copyright (c) 2009-2012 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msestringintlisteditor;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 mseforms,msedataedits,msesimplewidgets,msewidgetgrid,msegrids,mseclasses,
 msedialog,mseedit,mseglob,msegraphics,msegraphutils,msegui,
 mseguiglob,msemenus,msestrings,msetypes;
type
 tmsestringintlisteditor = class(tmseform)
   cancel: tbutton;
   ok: tbutton;
   grid: twidgetgrid;
   texta: tstringedit;
   rowcount: tintegeredit;
   textb: tintegeredit;
   procedure rowcountonsetvalue(const sender: tobject; var avalue: integer;
                var accept: boolean);
   procedure gridonrowcountchanged(const sender: tcustomgrid);
  public
   constructor create(const aonclosequery: closequeryeventty); reintroduce;
 end;

implementation
uses
 msestringintlisteditor_mfm;

{ tmsestringintlisteditor }

constructor tmsestringintlisteditor.create(const aonclosequery: closequeryeventty);
begin
 onclosequery:= aonclosequery;
 inherited create(nil);
end;

procedure tmsestringintlisteditor.gridonrowcountchanged(
  const sender: tcustomgrid);
begin
 rowcount.value:= sender.rowcount;
end;

procedure tmsestringintlisteditor.rowcountonsetvalue(const sender: tobject;
  var avalue: integer; var accept: boolean);
begin
 grid.rowcount:= avalue;
end;

end.
