unit regifi;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
implementation
uses
 mseifi,msedesignintf;
 
procedure register;
begin
 registercomponents('Ifi',[tformlink]); 
end;

initialization
 register;
end.
