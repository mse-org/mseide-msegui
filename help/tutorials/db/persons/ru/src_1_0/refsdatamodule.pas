unit refsdatamodule;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 msegui,mseclasses,mseforms,msesqldb,msedb,mselookupbuffer,msedatamodules,db;

type
 trefsdatamo = class(tmsedatamodule)
   qryPlanets: tmsesqlquery;
   qryContinents: tmsesqlquery;
   qryCountries: tmsesqlquery;
   qryOccupations: tmsesqlquery;
   qryFeatures: tmsesqlquery;
   dsPlanets: tmsedatasource;
   dsContinents: tmsedatasource;
   dsOccupations: tmsedatasource;
   dsFeatures: tmsedatasource;
   dsCountries: tmsedatasource;
   lbufPlanets: tdblookupbuffer;
   lbufContinents: tdblookupbuffer;
   lbufCountries: tdblookupbuffer;
   lbufOccupations: tdblookupbuffer;
   lbufFeatures: tdblookupbuffer;
   procedure qrycountriesbeforeopen(DataSet: TDataSet);
   procedure qrycontinentsbeforeopen(DataSet: TDataSet);
 end;
var
 refsdatamo: trefsdatamo;
implementation
uses
 refsdatamodule_mfm;

procedure trefsdatamo.qrycountriesbeforeopen(DataSet: TDataSet);
begin
  qryContinents.active:= true;
end;

procedure trefsdatamo.qrycontinentsbeforeopen(DataSet: TDataSet);
begin
  qryPlanets.active:= true;
end;



end.
