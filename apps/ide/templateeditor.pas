unit templateeditor;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,mseforms,msestatfile,
 msesimplewidgets,msewidgets,msedataedits,mseedit,msegrids,msestrings,msetypes,
 msewidgetgrid,msegraphedits,msesplitter,mseeditglob,msetextedit;
type
 ttemplateeditorfo = class(tmseform)
   tstatfile1: tstatfile;
   tlabel1: tlabel;
   tbutton1: tbutton;
   tbutton2: tbutton;
   nameed: tstringedit;
   commented: tstringedit;
   tstringgrid1: tstringgrid;
   tspacer1: tspacer;
   tsplitter1: tsplitter;
   twidgetgrid1: twidgetgrid;
   templedit: ttextedit;
   procedure onlo(const sender: TObject);
  private
   findex: integer;
  public
   constructor create(const aindex: integer); reintroduce;
 end;

implementation
uses
 templateeditor_mfm,msecodetemplates,projectoptionsform;
 
constructor ttemplateeditorfo.create(const aindex: integer);
begin
 findex:= aindex;
 inherited create(nil);
end;

procedure ttemplateeditorfo.onlo(const sender: TObject);
var
 int1: integer;
begin
 projectoptionstofont(templedit.font);
end;

end.
