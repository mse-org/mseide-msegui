unit regexperimental;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
implementation
uses
 msedesignintf,msechart,msewindowwidget,msegdiprint,msesqlresult
 {$ifdef unix},mseopenglwidget{$endif};
 
procedure Register;
begin
 registercomponents('Exp',[twindowwidget,
         {$ifdef unix}topenglwidget,{$endif}tchart,tchartrecorder,tgdiprinter,
                    tsqlresult]);
end;
initialization
 register;
end.
