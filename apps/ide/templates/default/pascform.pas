unit ${%UNITNAME%};
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes,mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,msewidgets,mseforms,
 msepascalscript;
type
 t${%FORMNAME%} = class(tpascform)
 end;
var
 ${%FORMNAME%}: t${%FORMNAME%};
implementation
uses
 ${%UNITNAME%}_mfm;
end.
