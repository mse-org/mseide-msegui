unit regexperimental;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
implementation
uses
 msedesignintf,msechart,msewindowwidget,msegdiprint;
 
procedure Register;
begin
 registercomponents('Exp',[twindowwidget,tchart,tchartrecorder,tgdiprinter]);
end;
initialization
 register;
end.
