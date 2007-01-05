unit ${%UNITNAME%};
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 msegui,mseclasses,msereport;

type
 t${%FORMNAME%} = class(treport)
 end;
var
 ${%FORMNAME%}: t${%FORMNAME%};
implementation
uses
 ${%UNITNAME%}_mfm;
end.
