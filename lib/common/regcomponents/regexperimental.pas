unit regexperimental;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
implementation
uses
 msedesignintf,msechart,msewindowwidget,msegdiprint,msesqlresult;
 
procedure Register;
begin
 registercomponents('Exp',[twindowwidget,tchart,tchartrecorder,tgdiprinter,
                    tsqlresult]);
end;
initialization
 register;
end.
