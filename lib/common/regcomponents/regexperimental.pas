unit regexperimental;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
implementation
uses
 msedesignintf,msechart,msewindowwidget,msegdiprint,msesqlresult,
 mseopenglwidget;
 
procedure Register;
begin
 registercomponents('Exp',[twindowwidget,
                    topenglwidget,tchart,tchartrecorder,tgdiprinter,
                    tsqlresult]);
end;
initialization
 register;
end.
