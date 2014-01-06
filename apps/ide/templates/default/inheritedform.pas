unit ${%UNITNAME%};
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes,mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,msewidgets,mseforms,
 ${%ANCESTORUNIT%};

type
 t${%FORMNAME%} = class(${%ANCESTORCLASS%})
 end;
var
 ${%FORMNAME%}: t${%FORMNAME%};
implementation
uses
 ${%UNITNAME%}_mfm;
end.
