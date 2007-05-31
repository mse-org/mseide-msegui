unit regexperimental;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
implementation
uses
 msedesignintf,msechart,msewindowwidget;
 
procedure Register;
begin
 registercomponents('Exp',[twindowwidget,tchart]);
end;
initialization
 register;
end.
