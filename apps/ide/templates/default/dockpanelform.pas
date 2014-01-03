unit ${%UNITNAME%};
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes,mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,mseforms,msedock,msedockpanelform;

type
 t${%FORMNAME%} = class(tdockpanelform)
 end;

implementation
uses
 ${%UNITNAME%}_mfm;
end.
