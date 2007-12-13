unit mseregdbcomp;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
implementation
uses
 classes,msedbedit,mselookupbuffer,msedb,msedbf,msesdfdata,msememds,msesqldb,
 msqldb,msesqlresult,mseibconnection,msepqconnection,msesqlite3conn,
 mseodbcconn,msemysql40conn,msemysql41conn,msemysql50conn
  {$ifdef mse_with_sqlite}
 ,msesqlite3ds
 {$endif}
;
begin
 registerclasses([tdbnavigator,tdbstringgrid,
      tlookupbuffer,tdblookupbuffer,tdbmemolookupbuffer,
      tmsedatasource,
      tmsedbf,tmsefixedformatdataset,tmsesdfdataset,tmsememdataset,
      tmsesqlquery,tmsesqltransaction,
      tsqlstatement,tmsesqlscript,tsqlresult,tsqllookupbuffer,
      tmseibconnection,tmsepqconnection,tsqlite3connection,tmseodbcconnection,
      tmsemysql40connection,tmsemysql41connection,tmsemysql50connection
      {$ifdef mse_with_sqlite}
       ,tmsesqlite3dataset
      {$endif}]);
end.
