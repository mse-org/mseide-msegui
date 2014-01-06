unit ${%UNITNAME%};
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes,mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,msewidgets,mseforms,msetabs;
type
 t${%FORMNAME%} = class(ttabform)
 end;
var
 ${%FORMNAME%}: t${%FORMNAME%};
implementation
uses
 ${%UNITNAME%}_mfm;
end.
