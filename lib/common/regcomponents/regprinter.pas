unit regprinter;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
implementation
uses
 msepostscriptprinter,msegdiprint,msedesignintf;
 
procedure Register;
begin
 registercomponents('Gui',[tpostscriptprinter
    {$ifdef mswindows},tgdiprinter,twmfprinter{$endif}]);
end;

initialization
 register;
end.
