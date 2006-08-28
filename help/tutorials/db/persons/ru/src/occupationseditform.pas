unit occupationseditform;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 msegui,mseclasses,mseforms,commonrefseditform,msedbedit,msegrids,db;

type
 toccupationseditfo = class(tmseform)
   commonrefseditfo1: tcommonrefseditfo;
   grdOccupations: tdbwidgetgrid;
   seOccupation: tdbstringedit;
   procedure occupationseditfocreated(const sender: TObject);
   procedure occupationseditfodestroyed(const sender: TObject);
   procedure grdoccupationsupdaterowdata(const sender: tcustomgrid;
                   const arow: Integer; const adataset: TDataSet);
 end;
var
 occupationseditfo: toccupationseditfo;

implementation

uses
 occupationseditform_mfm,
 refsdatamodule
;

procedure toccupationseditfo.occupationseditfocreated(const sender: TObject);
begin
  application.createdatamodule(trefsdatamo, refsdatamo);
  commonrefseditfo1.dsContents.dataset := grdOccupations.datasource.dataset;
end;

procedure toccupationseditfo.occupationseditfodestroyed(const sender: TObject);
begin
  refsdatamo.free;
end;

procedure toccupationseditfo.grdoccupationsupdaterowdata(const sender: tcustomgrid;
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
