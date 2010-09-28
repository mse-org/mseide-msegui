unit mseparamentryform;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,mseforms,msesimplewidgets,
 msewidgets,msedataedits,mseedit,msegrids,msestrings,msetypes,msewidgetgrid,
 msememodialog,msesplitter;
type
 tmseparamentryfo = class(tmseform)
   twidgetgrid1: twidgetgrid;
   macroname: tstringedit;
   macrovalue: tmemodialogedit;
   tsplitter1: tsplitter;
   tbutton2: tbutton;
   tbutton1: tbutton;
   comment: tlabel;
 end;
var
 mseparamentryfo: tmseparamentryfo;
implementation
uses
 mseparamentryform_mfm;
end.
