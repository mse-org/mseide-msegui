unit mseindexlookupeditor;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes,mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,msewidgets,mseforms,msesplitter,
 msesimplewidgets,msedataedits,mseedit,mseificomp,mseificompglob,mseifiglob,
 msestatfile,msestream,msestrings,sysutils,msegrids,msewidgetgrid,msegraphedits,
 msescrollbar;
type
 tmseindexlookupeditorfo = class(tmseform)
   tsplitter1: tsplitter;
   tbutton2: tbutton;
   tbutton1: tbutton;
   tspacer2: tspacer;
   grid: twidgetgrid;
   index: tintegeredit;
   tstockglyphdatabutton1: tstockglyphdatabutton;
   icondi: tdataicon;
   statfile1: tstatfile;
   procedure rowdatacha(const sender: tcustomgrid; const acell: gridcoordty);
 end;
var
 mseindexlookupeditorfo: tmseindexlookupeditorfo;
implementation
uses
 mseindexlookupeditor_mfm;
 
procedure tmseindexlookupeditorfo.rowdatacha(const sender: tcustomgrid;
               const acell: gridcoordty);
begin
 icondi[acell.row]:= index[acell.row];
end;

end.
