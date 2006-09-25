{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseintegerlisteditor;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 mseforms,msedataedits,msesimplewidgets,msewidgetgrid,msegrids,msetextedit,
 msestat,msestatfile;
 
const
 integerlisteditorstatname =  'integerlisteditor.sta';
 
type
 tintegerlisteditor = class(tmseform)
   cancel: tbutton;
   ok: tbutton;
   grid: twidgetgrid;
   rowcount: tintegeredit;
   valueedit: trealedit;
   tstatfile1: tstatfile;
   procedure rowcountonsetvalue(const sender: tobject; var avalue: integer;
                var accept: boolean);
   procedure gridonrowcountchanged(const sender: tcustomgrid);
  public
   constructor create(const aonclosequery: closequeryeventty); reintroduce;
 end;

implementation
uses
 mseintegerlisteditor_mfm;
 
{ tintegerlisteditor }

constructor tintegerlisteditor.create(const aonclosequery: closequeryeventty);
begin
 inherited create(nil);
 onclosequery:= aonclosequery;
end;

procedure tintegerlisteditor.gridonrowcountchanged(
  const sender: tcustomgrid);
begin
 rowcount.value:= sender.rowcount;
end;

procedure tintegerlisteditor.rowcountonsetvalue(const sender: tobject;
  var avalue: integer; var accept: boolean);
begin
 grid.rowcount:= avalue;
end;

end.
