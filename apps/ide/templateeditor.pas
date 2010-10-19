unit templateeditor;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,mseforms,msestatfile,
 msesimplewidgets,msewidgets,msedataedits,mseedit,msegrids,msestrings,msetypes,
 msewidgetgrid,msegraphedits;
type
 ttemplateeditorfo = class(tmseform)
   tstatfile1: tstatfile;
   tlabel1: tlabel;
   procedure onlo(const sender: TObject);
  public
   constructor create(const aindex: integer); reintroduce;
 end;
var
 templateeditorfo: ttemplateeditorfo;
implementation
uses
 templateeditor_mfm,msecodetemplates,projectoptionsform;
 
constructor ttemplateeditorfo.create(const aindex: integer);
begin
 inherited create(nil);
end;

procedure ttemplateeditorfo.onlo(const sender: TObject);
var
 int1: integer;
begin
end;

end.
