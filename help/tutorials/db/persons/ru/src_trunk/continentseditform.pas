unit continentseditform;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 msegui,mseclasses,mseforms,commonrefseditform,msedbedit,
 msegrids,
 db;

type
 tcontinentseditfo = class(tmseform)
   commonrefseditfo1: tcommonrefseditfo;
   grdContinents: tdbwidgetgrid;
   lbnePlanet: tdbenumeditlb;
   seContinent: tdbstringedit;
   procedure continentseditfocreated(const sender: TObject);
   procedure continentseditfodestroyed(const sender: TObject);
   procedure grdcontinentsupdaterowdata(const sender: tcustomgrid;
                   const arow: Integer; const adataset: TDataSet);
 end;
var
 continentseditfo: tcontinentseditfo;

implementation
uses
 continentseditform_mfm,
 refsdatamodule;

procedure tcontinentseditfo.continentseditfocreated(const sender: TObject);
begin
  application.createdatamodule(trefsdatamo, refsdatamo);
  commonrefseditfo1.dsContents.dataset := grdContinents.datasource.dataset;
end;

procedure tcontinentseditfo.continentseditfodestroyed(const sender: TObject);
begin
  refsdatamo.free;
end;

procedure tcontinentseditfo.grdcontinentsupdaterowdata(const sender: tcustomgrid;
               const arow: Integer; const adataset: TDataSet);
begin
  case adataset.updatestatus of
    usInserted: 
      sender.rowcolorstate[arow]:= 0;
    usModified: 
      sender.rowcolorstate[arow]:= 1;
    else
      sender.rowcolorstate[arow]:= 255;
  end;
end;

end.
