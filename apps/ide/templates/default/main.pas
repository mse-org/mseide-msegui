unit main;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes,mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,msewidgets,mseforms;

type
 tmainfo = class(tmainform)
 end;
var
 mainfo: tmainfo;
implementation
uses
 main_mfm;
end.
