unit reportdesigner;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 msegui,mseclasses,mseforms,formdesigner;

type
 treportdesignerfo = class(Tformdesignerfo)
 end;
var
 reportdesignerfo: treportdesignerfo;
implementation
uses
 reportdesigner_mfm;
end.
