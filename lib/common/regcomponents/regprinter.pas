unit regprinter;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
implementation
uses
 msepostscriptprinter,msegdiprint,msedesignintf;
 
procedure Register;
begin
 registercomponents('Gui',[tpostscriptprinter,tgdiprinter]);
end;

initialization
 register;
end.
