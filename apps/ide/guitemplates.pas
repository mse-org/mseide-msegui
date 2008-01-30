unit guitemplates;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 mseglob,mseapplication,mseclasses,msedatamodules,msegui,mseskin;

type
 tguitemplatesmo = class(tmsedatamodule)
   fadevertkonvex: tfacecomp;
   fadehorzconvex: tfacecomp;
   fadehorzconcave: tfacecomp;
   fadevertconcave: tfacecomp;
   tskincontroller1: tskincontroller;
 end;
var
 guitemplatesmo: tguitemplatesmo;
implementation
uses
 guitemplates_mfm;
end.
