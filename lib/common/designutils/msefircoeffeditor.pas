unit msefircoeffeditor;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes,mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,msewidgets,mseforms,msestatfile,
 msedataedits,mseedit,msegrids,mseificomp,mseificompglob,mseifiglob,msestrings,
 msewidgetgrid,msesimplewidgets;
type
 tfircoeffeditorfo = class(tmseform)
   tstatfile1: tstatfile;
   grid: twidgetgrid;
   ok: tbutton;
   cancel: tbutton;
   coeffed: trealedit;
 end;

implementation
uses
 msefircoeffeditor_mfm;
 
end.
