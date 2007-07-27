unit regzeoslib;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
implementation
uses
 msedesignintf,ZDataset,ZConnection,ZSqlUpdate,ZStoredProcedure,ZSqlMetadata,
 ZSqlProcessor,ZSqlMonitor,ZSequence,msezeos;
 
procedure Register;
begin
 registercomponents('Zeos',[TZConnection, tmsezreadonlyquery, tmsezquery,
         tmseztable,
         TZUpdateSQL, TZStoredProc, TZSQLMetadata, TZSQLProcessor,
         TZSQLMonitor, TZSequence]);
end;

initialization
 Register;
end.
