unit countrieseditform;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 msegui,mseclasses,mseforms,commonrefseditform,msedbedit,msegrids,db;

type
 tcountrieseditfo = class(tmseform)
   commonrefseditfo1: tcommonrefseditfo;
   grdCountries: tdbwidgetgrid;
   lbneContinent: tdbenumeditlb;
   seCountry: tdbstringedit;
   procedure countrieseditfocreated(const sender: TObject);
   procedure countrieseditfodestroyed(const sender: TObject);
   procedure grdcountriesupdaterowdata(const sender: tcustomgrid;
                   const arow: Integer; const adataset: TDataSet);
 end;
var
 countrieseditfo: tcountrieseditfo;

implementation

uses
 countrieseditform_mfm,
 refsdatamodule;

procedure tcountrieseditfo.countrieseditfocreated(const sender: TObject);
begin
  application.createdatamodule(trefsdatamo, refsdatamo);
  commonrefseditfo1.dsContents.dataset := grdCountries.datasource.dataset;
end;

procedure tcountrieseditfo.countrieseditfodestroyed(const sender: TObject);
begin
  refsdatamo.free;
end;

procedure tcountrieseditfo.grdcountriesupdaterowdata(const sender: tcustomgrid;
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
