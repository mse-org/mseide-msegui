unit featureseditform;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 msegui,mseclasses,mseforms,commonrefseditform,msedbedit,msegrids,db,
 msedataedits;

type
 tfeatureseditfo = class(tmseform)
   commonrefseditfo1: tcommonrefseditfo;
   grdFeatures: tdbwidgetgrid;
   seFeature: tdbstringedit;
   procedure featureseditfocreated(const sender: TObject);
   procedure featureseditfodestroyed(const sender: TObject);
   procedure grdfeaturesupdaterowdata(const sender: tcustomgrid;
                   const arow: Integer; const adataset: TDataSet);
 end;
var
 featureseditfo: tfeatureseditfo;

implementation
uses
 featureseditform_mfm,
 refsdatamodule
;

procedure tfeatureseditfo.featureseditfocreated(const sender: TObject);
begin
  application.createdatamodule(trefsdatamo, refsdatamo);
  commonrefseditfo1.dsContents.dataset := grdFeatures.datasource.dataset;
end;

procedure tfeatureseditfo.featureseditfodestroyed(const sender: TObject);
begin
  refsdatamo.free;
end;

procedure tfeatureseditfo.grdfeaturesupdaterowdata(const sender: tcustomgrid;
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
