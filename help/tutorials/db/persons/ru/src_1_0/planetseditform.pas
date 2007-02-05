unit planetseditform;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 msegui,mseclasses,mseforms,commonrefseditform,msedbedit,
 msegrids, // provides "tcustomgrid"
 db // // provides "tdataset"
;

type
 tplanetseditfo = class(tmseform)
   commonrefseditfo1: tcommonrefseditfo;
   grdPlanets: tdbwidgetgrid;
   seName: tdbstringedit;
   procedure planetseditfodestroyed(const sender: TObject);
   procedure planetseditfocreated(const sender: TObject);
   procedure grdplanetsupdaterowdata(const sender: tcustomgrid;
                   const arow: Integer; const adataset: TDataSet);
 end;

var
 planetseditfo: tplanetseditfo;

implementation

uses
 planetseditform_mfm,
 refsdatamodule
;

procedure tplanetseditfo.planetseditfodestroyed(const sender: TObject);
begin
  refsdatamo.free;
end;

procedure tplanetseditfo.planetseditfocreated(const sender: TObject);
begin
  application.createdatamodule(trefsdatamo, refsdatamo);
  commonrefseditfo1.dsContents.dataset := grdPlanets.datasource.dataset;
end;

procedure tplanetseditfo.grdplanetsupdaterowdata(const sender: tcustomgrid;
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
