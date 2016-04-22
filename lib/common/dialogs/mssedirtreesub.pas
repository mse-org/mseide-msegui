unit msedirtreesub;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes,mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,msewidgets,mseforms,
 dirtree;

type
 tdirtreesubfo = class(tdirtreefo)
 end;
var
 dirtreesubfo: tdirtreesubfo;
implementation
uses
 msedirtreesub_mfm;
end.
