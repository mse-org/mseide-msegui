unit main;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 msegui,mseclasses,mseevent,mseforms,msegraphics,msemenus,msestat;

type
 tmainfo = class(tmseform)
 end;
var
 mainfo: tmainfo;
implementation
uses
 main_mfm;
end.
