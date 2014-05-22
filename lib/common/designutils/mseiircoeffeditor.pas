unit mseiircoeffeditor;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes,mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,msewidgets,mseforms,msestatfile,
 msedataedits,mseedit,msegrids,mseificomp,mseificompglob,mseifiglob,msestrings,
 msewidgetgrid,msesimplewidgets;
type
 tiircoeffeditorfo = class(tmseform)
   tstatfile1: tstatfile;
   grid: twidgetgrid;
   ok: tbutton;
   cancel: tbutton;
   numed: trealedit;
   dened: trealedit;
   numdi: trealedit;
   dendi: trealedit;
   procedure datentexe(const sender: TObject);
 end;

implementation
uses
 mseiircoeffeditor_mfm;
 
procedure tiircoeffeditorfo.datentexe(const sender: TObject);
var
 int1: integer;
 norm: real;
begin
 for int1:= 0 to grid.rowhigh do begin
  if (int1 = 0) or (grid.rowlinewidth[int1-1] > 1) then begin
   if dened[int1] = 0 then begin
    dened[int1]:= 1.0;
   end;
   norm:= dened[int1];
  end;
  numdi[int1]:= numed[int1]/norm;
  dendi[int1]:= dened[int1]/norm;
 end;
end;

end.
