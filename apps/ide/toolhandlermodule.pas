unit toolhandlermodule;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseglob,mseapplication,mseclasses,msedatamodules;

type
 ttoolhandlermo = class(tmsedatamodule)
 end;
var
 toolhandlermo: ttoolhandlermo;
implementation
uses
 toolhandlermodule_mfm;
end.
