unit ${%UNITNAME%};
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 mseglob,msestat,msemenus,msegui,msegraphics,mseevent,mseclasses,mseforms,
 msegraphutils,msedock;

type
 t${%FORMNAME%} = class(tdockform)
 end;
var
 ${%FORMNAME%}: t${%FORMNAME%};
implementation
uses
 ${%UNITNAME%}_mfm;
end.
